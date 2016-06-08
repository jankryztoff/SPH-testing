/**
 * Class Name:  BatchCODC
 * @author: Zhu, Wenjun
 * Date: 21 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: Adhoc Batch to be run in the event of changing Delivery Rate
 */
 
global class BatchCODC_Target implements Database.Batchable<sObject>, Database.AllowsCallouts {    

    global final Decimal HDB_PRICE;
    global final Decimal APT_PRICE;
    global final Decimal LANDED_PRICE;
    global final String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global final String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    global final String SUB_TYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
  
    global BatchCODC_Target(Decimal hdbPrice, Decimal aptPrice, Decimal landedPrice){
      HDB_PRICE = hdbPrice; APT_PRICE = aptPrice; LANDED_PRICE = landedPrice;
    }
    
    global String getQueryString(){
        List<String> lstConditions = new List<String>();
        if(HDB_PRICE > 0)
            lstConditions.add('(Delivery_Charge_Type_1__c = \'H\' AND Subscription_Charge__c != :HDB_PRICE)');
        if(APT_PRICE > 0)
            lstConditions.add('(Delivery_Charge_Type_1__c = \'C\' AND Subscription_Charge__c != :APT_PRICE)');
        if(LANDED_PRICE > 0)
            lstConditions.add('(Delivery_Charge_Type_1__c = \'L\' AND Subscription_Charge__c != :LANDED_PRICE)');
        
        if(!lstConditions.isEmpty())
        {
            //START D-3028 Wenjun 15/06/15: add Order_Line_Item_Number_1__c field
            String query = 'SELECT Id, Name, Zuora__Zuora_Id__c, Delivery_Charge_Type_1__c, Zuora__CustomerAccount__c, Order_Line_Item_Number_1__c, '; 
            //END D-3028 Wenjun 15/06/15
            query += 'Contract_End_Date_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c ';
            query += 'WHERE Subscription_Type_1__c = : SUB_TYPE_DEL AND Zuora__Status__c = \'Active\' ';
            query += 'AND (Billing_Type__c = :MR_PRE OR Billing_Type__c = :MR_POST) AND Zuora__CustomerAccount__c in (\'a019000000tcZMW\',\'a019000000td5UC\') ';
            query += 'AND (';
            if(lstConditions.size() == 1)
                query += lstConditions[0];
            else if(lstConditions.size() == 2)
                query += lstConditions[0] + ' OR ' + lstConditions[1];
            else if(lstConditions.size() == 3)
                query += lstConditions[0] + ' OR ' + lstConditions[1] +' OR ' + lstConditions[2];
            query += ') LIMIT 1000';
            return query;
        }
        else
            return null;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(getQueryString());
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstSubs){
        
        //Break Sub List into 3 Categories
        List<Zuora__Subscription__c> lstHSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstCSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstLSubs = new List<Zuora__Subscription__c> ();
        Set<Id> setBillingAccountId = new Set<Id>();
        zqu__ProductRatePlan__c deliveryRatePlan_HDB;
        zqu__ProductRatePlan__c deliveryRatePlan_Apartment;
        zqu__ProductRatePlan__c deliveryRatePlan_Landed;
        List <Zuora.zApi.AmendRequest> lstAmendReqs = new List <Zuora.zApi.AmendRequest>();
        //START D-3085 JTeves 6/10/2015 Try/Catch modification
        List<Exception> exceptionList = new List<Exception>();
        //END D-3085 JTeves 6/10/2015 Try/Catch modification
        
        //START D-3028 Wenjun 15/06/15
        List<Map<String, Object>> lstUpdMap = new List<Map<String, Object>>();
        Set<ID> setOliIDs = new Set<ID>();
        //END D-3028 Wenjun 15/06/15
        
        for(Zuora__Subscription__c delSub : lstSubs)
        {
            //START D-3003 Wenjun 21/05/15 : To support Evergreen
            if(delSub.Contract_End_Date_1__c != delSub.Zuora__SubscriptionEndDate__c || delSub.Zuora__SubscriptionEndDate__c == NULL)
            //END D-3003 Wenjun 21/05/15
            {
                if(delSub.Delivery_Charge_Type_1__c == 'H')
                    lstHSubs.add(delSub);
                else if(delSub.Delivery_Charge_Type_1__c == 'C')
                    lstCSubs.add(delSub);
                else if(delSub.Delivery_Charge_Type_1__c == 'L')
                    lstLSubs.add(delSub);
                
                if(delSub.Zuora__CustomerAccount__c != null)
                    setBillingAccountId.add(delSub.Zuora__CustomerAccount__c);
                
                //START D-3028 Wenjun 15/06/15: Retrieve Order Line Item Record IDs for fetching Pub Subs
                if(delSub.Order_Line_Item_Number_1__c != null)
                    setOliIDs.add(delSub.Order_Line_Item_Number_1__c);
                //END D-3028 Wenjun 15/06/15
            }
        }
        
        //START D-3028 Wenjun 15/06/15 : Update Vendor Credit Debit
        //Retrieve all relevant Subs for updating Vendor Credit Debit 
        for(Zuora__Subscription__c sub:[SELECT Id, Name, Zuora__Zuora_Id__c, Delivery_Charge_Type_1__c 
                                        FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c in :setOliIDs])
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
        
        if(!lstUpdMap.isEmpty())
        {
            ZuoraCallOut zCallOut = new ZuoraCallOut(); 
            List<Map<String,String>> lstCallOutResult = zCallOut.updateZObjects(lstUpdMap, 'Subscription');
            
            for(Map<String,String> resultMap :lstCallOutResult){
                if (resultMap .get('Status') != 'Success') 
                {
                    exceptionList.add(new CustomException('Error: ' + resultMap));
                }
            }
        }
        //END D-3028 Wenjun 15/06/15
        
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
        
        Zuora.zApi zuorApi = new Zuora.zApi();
        //START D-3268 Modified By C.I.Salas - Test Coverage
        if (!Test.isRunningTest()) {
            zuorApi.zlogin();
        }
        //END D-3268 Modified By C.I.Salas - Test Coverage
        System.debug('=====>' + lstAmendReqs.size());
        
        //Send Amendment Request one by one
        //START D-3085 MGaelo 6/5/2015 Try/Catch modification
        for(Zuora.zApi.AmendRequest amendRequest :lstAmendReqs)
        {
            try{
                System.debug('=====> Amend Request :' + amendRequest );
                Zuora.zApi.AmendResult amendResult = zuorApi.zamend(new List<Zuora.zApi.AmendRequest>{amendRequest});
                System.debug('=====> Amend Result :' + amendResult );
                //START D-3028 Wenjun 15/06/15 : Log Error to System
                if(!amendResult.success)
                {
                    System.debug(Logginglevel.ERROR, System.Label.ERR_CODC_AMEND + ' : ' + amendResult);
                    exceptionList.add(new CustomException(System.Label.ERR_CODC_AMEND + ' : ' + amendResult));
                }
                //END D-3028 Wenjun 15/06/15
            } catch (exception e) {
                //START D-3085 JTeves 6/10/2015 Try/Catch modification
                exceptionList.add(e);
                //END D-3085 JTeves 6/10/2015 Try/Catch modification
                system.debug('Exception e: ' + e);
            }
        }
        //END D-3085 MGaelo 6/5/2015 Try/Catch modification
        
        //Perform Zuora Sync
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncObjectIdSet  = setBillingAccountId;
        
        //START D-3003 Wenjun 21/05/15 - Disable Email Notification for On-demand Sync
        syncManager.emailNotificationEnabled = false;
        //END D-3003 Wenjun 21/05/15
        
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        System.debug('>>>>> Sync Result:' + syncResult);

        //START D-3085 JTeves 6/10/2015 Try/Catch modification
        if(!exceptionList.isEmpty()) {
            ExceptionLogger.log(exceptionList);
        }
        //END D-3085 JTeves 6/10/2015 Try/Catch modification
    }
    
    global void finish(Database.BatchableContext BC) {  
        //Query for pending updates - this job may be scheduled one more time due to Zuora Sync. 
        //But the job will do nothing if the Sync result is back within the period
        sObject[] lstPendingSubs = Database.query(getQueryString());
        
        System.debug('=====>' + HDB_PRICE + ' | ' + APT_PRICE + ' | ' + LANDED_PRICE);
        //Schedule 10 minutes Batch Job to overcome Zuora Call Limit
        if(lstPendingSubs != null && !lstPendingSubs.isEmpty())
        {
            BatchCODC batch = new BatchCODC(HDB_PRICE, APT_PRICE, LANDED_PRICE);
            //START D-3028 Wenjun 20/06/15 - Reduce Batch Size for Email Limit
            System.scheduleBatch(batch, 'Change of Delivery Charge Rate', 10, 8);
            //END D-3028 Wenjun 20/06/15
        }
    }
}