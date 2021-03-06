/**
 * Class Name:  BatchCODCMain
 * @author: Zhu, Wenjun
 * Date: 21 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: Main execution class for Mass Delivery Charge Change Batch. 
    This batch will auto-schedule itself few minutes later to process the remaining. This is to overcome the Zuora API Limit
 * History: 19/04/2016 [D-4382] Wenjun : Restructure the class
 */
 
global class BatchCODCMain implements Database.Batchable<sObject>, Database.AllowsCallouts {    

    global final Decimal HDB_PRICE;
    global final Decimal APT_PRICE;
    global final Decimal LANDED_PRICE;
    global final String SUB_TYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    global final String SUB_TYPE_PUB = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    
    global BatchCODCMain(Decimal hdbPrice, Decimal aptPrice, Decimal landedPrice){
        HDB_PRICE = hdbPrice; APT_PRICE = aptPrice; LANDED_PRICE = landedPrice;
    }
    
    global String getQueryString(){
        String query = ' Select Billing_Type__c, Subscription_Type_1__c, Zuora__CustomerAccount__c, Product_Code__c, ';
        query +=' Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__Zuora_Id__c, Contract_End_Date_1__c, ';
        query +=' Order_Line_Item_Number_1__c, Delivery_Charge_Type_1__c ';
        query +=' FROM Zuora__Subscription__c Where Subscription_Type_1__c = : SUB_TYPE_DEL and For_Mass_Update__c = true Limit 1000';
        
        return query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(getQueryString());
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstSubs){
        
        //Break Sub List into 3 Categories
        List<Zuora__Subscription__c> lstHSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstCSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstLSubs = new List<Zuora__Subscription__c> ();
        zqu__ProductRatePlan__c deliveryRatePlan_HDB;
        zqu__ProductRatePlan__c deliveryRatePlan_Apartment;
        zqu__ProductRatePlan__c deliveryRatePlan_Landed;
        List <Zuora.zApi.AmendRequest> lstAmendReqs = new List <Zuora.zApi.AmendRequest>();
        Logger logger = new Logger(BatchCODCMain.class.getName()); 
        
        List<Map<String, Object>> lstUpdMap = new List<Map<String, Object>>();
        Set<ID> setOliIDs = new Set<ID>();
        
        for(Zuora__Subscription__c delSub : lstSubs)
        {
            if(delSub.Delivery_Charge_Type_1__c == 'H')
                lstHSubs.add(delSub);
            else if(delSub.Delivery_Charge_Type_1__c == 'C')
                lstCSubs.add(delSub);
            else if(delSub.Delivery_Charge_Type_1__c == 'L')
                lstLSubs.add(delSub);
            
            //START D-3028 Wenjun 15/06/15: Retrieve Order Line Item Record IDs for fetching Pub Subs
            if(delSub.Order_Line_Item_Number_1__c != null)
                setOliIDs.add(delSub.Order_Line_Item_Number_1__c);
            //END D-3028 Wenjun 15/06/15
            
            delSub.For_Mass_Update__c = false;
        }
        
        //Retrieve all relevant Subs for updating Vendor Credit Debit 
        for(Zuora__Subscription__c sub:[SELECT Id, Name, Zuora__Zuora_Id__c, Delivery_Charge_Type_1__c FROM Zuora__Subscription__c 
                    WHERE (Subscription_Type_1__c = : SUB_TYPE_DEL OR Subscription_Type_1__c = :SUB_TYPE_PUB) AND Order_Line_Item_Number_1__c in :setOliIDs])
        {
            Map<String, Object> mapVendorCredit = new Map<String, Object>();
            
            if(sub.Delivery_Charge_Type_1__c == 'H' && HDB_PRICE != null && HDB_PRICE > 0){         
                mapVendorCredit.put('Id', sub.Zuora__Zuora_ID__c);
                mapVendorCredit.put('Vendor_Credit__c', HDB_PRICE);
            }
            else if(sub.Delivery_Charge_Type_1__c == 'C' && APT_PRICE != null && APT_PRICE > 0){
                mapVendorCredit.put('Id', sub.Zuora__Zuora_ID__c);
                mapVendorCredit.put('Vendor_Credit__c', APT_PRICE);
            }
            else if(sub.Delivery_Charge_Type_1__c == 'L' && LANDED_PRICE != null && LANDED_PRICE > 0){
                mapVendorCredit.put('Id', sub.Zuora__Zuora_ID__c);
                mapVendorCredit.put('Vendor_Credit__c', LANDED_PRICE);                 
            }
            
            if(!mapVendorCredit.isEmpty()) lstUpdMap.add(mapVendorCredit);
        }
        
        try
        {
            ZuoraCallOut zCallOut = new ZuoraCallOut(); 
            
            if(!lstUpdMap.isEmpty())
            {
                List<Map<String,String>> lstCallOutResult = zCallOut.updateZObjects(lstUpdMap, 'Subscription');
                
                for(Map<String,String> resultMap :lstCallOutResult){
                    if (resultMap.get('Status') != 'Success') 
                        logger.log(false, ''+resultMap);
                }
            }
            
             /*------------------------------- Get Rate Plans for Delivery Charges----------------------------------*/
            for(zqu__ProductRatePlan__c drp: [Select Id, Name, zqu__ZuoraId__c From zqu__ProductRatePlan__c
                                            Where zqu__ZProduct__r.ProductCode__c =: GlobalVariableClass.PRODUCT_CODE_DELCHG and zqu__Deleted__c = false])
            {
                if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE')))
                    deliveryRatePlan_HDB = drp;
                else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('APT DELIVERY CHARGE')))
                    deliveryRatePlan_Apartment = drp;
                else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('LANDED DELIVERY CHARGE')))
                    deliveryRatePlan_Landed = drp;
            }
            
            
            /*-------------------------------- Create Amendment Requests ------------------------------------------*/
            if(!lstHSubs.isEmpty())
                lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstHSubs, deliveryRatePlan_HDB.Id));
            if(!lstCSubs.isEmpty())
                lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstCSubs, deliveryRatePlan_Apartment.Id));
            if(!lstLSubs.isEmpty())
                lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstLSubs, deliveryRatePlan_Landed.Id));
            
            System.debug('=====>' + lstAmendReqs.size());
            
            //Send Amendment Request one by one
            for(Zuora.zApi.AmendRequest amendRequest :lstAmendReqs)
            {
                try{
                    System.debug('=====> Amend Request :' + amendRequest );
                    Zuora.zApi.AmendResult amendResult = zCallOut.zApiInstance.zamend(new List<Zuora.zApi.AmendRequest>{amendRequest});
                    System.debug('=====> Amend Result :' + amendResult );
                    if(!amendResult.success)
                    {
                        System.debug(Logginglevel.ERROR, System.Label.ERR_CODC_AMEND + ' : ' + amendResult);
                        logger.log(false, System.Label.ERR_CODC_AMEND + ' : ' + amendResult);
                    }
                } catch (exception e) {
                    logger.log(e);
                }
            }
        }
        catch (exception e) {
            logger.log(e);
        }
        
        //Uncheck the Mass Update
        SubscriptionTriggerHandler.preventExecution = true;
        Database.update(lstSubs, false);
        
        //Save logs
        logger.save();
    }
    
    global void finish(Database.BatchableContext BC) {  
        //Query for pending updates - this job will auto-schedule itself few minutes later if there is remaining 
        sObject[] lstPendingSubs = Database.query(getQueryString());
        
        //Schedule 5 minutes Batch Job to overcome Zuora Call Limit
        if(lstPendingSubs != null && !lstPendingSubs.isEmpty())
        {
            BatchCODCMain batch = new BatchCODCMain(HDB_PRICE, APT_PRICE, LANDED_PRICE);
            System.scheduleBatch(batch, 'Mass Delivery Charge Update', 1, 8);
        }
    }
}