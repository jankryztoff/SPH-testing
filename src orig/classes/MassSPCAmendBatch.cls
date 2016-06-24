/**
 * Class Name:  MassSPCAmendBatch
 * @author: Kevin Evasco
 * Date: 30 September 2015
 * Requirement/Project Name: CRSM Project
 * @description: This will update all the SPCs given the new price value.
 */
 
global class MassSPCAmendBatch implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts {    

    global String query;    
    global String lastUpdatedByProcessed = 'Kevin Evasco';
    global String lastUpdatedByUnprocessed = 'Migration - For Amendment';
    global String filterStatus = 'Active';
    global String hardCodedId = 'a0C9000000T4lraEAB';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        query = ' Select Billing_Type__c, Subscription_Type_1__c, Zuora__CustomerAccount__c, Zuora__SubscriptionEndDate__c, ';
        query +=' Zuora__SubscriptionStartDate__c, Zuora__Zuora_Id__c, Contract_End_Date_1__c, Product_Code__c, CreatedDate ';
        query +=' FROM Zuora__Subscription__c ';
        query +=' Where (Legacy_Update_By__c = :lastUpdatedByUnprocessed) ';
        query +=' AND Zuora__Status__c = :filterStatus ';
        //query +=' AND Id = :hardCodedId ';
        query +=' Limit 1000';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) {
    
        List<Exception> exceptionList = new List<Exception>();
        List<Zuora.zApi.AmendRequest> listAmendmentRequest = new List<Zuora.zApi.AmendRequest>();
        Set<Id> setBillingAccountId = new Set<Id>();
        List<Zuora__Subscription__c> listSubscriptionRecords = new List<Zuora__Subscription__c>();
            
        for(Zuora__Subscription__c subRec : scope){
            subRec.Legacy_Update_By__c = lastUpdatedByProcessed;
            
            listSubscriptionRecords.add(subRec);
            setBillingAccountId.add(subRec.Zuora__CustomerAccount__c);
        }
        if(!listSubscriptionRecords.isEmpty()){
            listAmendmentRequest.addAll(createCoverPriceAmendmentReqs(listSubscriptionRecords));
        }
        System.debug('=====> listAmendmentRequest ' + listAmendmentRequest);
        Zuora.zApi zuorApi = new Zuora.zApi();
        
        if (!Test.isRunningTest()) {
            zuorApi.zlogin();
        }
        
        if(!listAmendmentRequest.isEmpty()){
            System.debug('=====>' + listAmendmentRequest.size());
            for(Zuora.zApi.AmendRequest amendRequest :listAmendmentRequest)
            {
                try{
                System.debug('=====> Amend Request :' + amendRequest );
                Zuora.zApi.AmendResult amendResult = zuorApi.zamend(new List<Zuora.zApi.AmendRequest>{amendRequest});
                System.debug('=====> Amend Result :' + amendResult );
                if(!amendResult.success)
                   System.debug(Logginglevel.ERROR, System.Label.ERR_CODC_AMEND + ' : ' + amendResult);
                } catch (exception e) {
                    exceptionList.add(e);
                 } 
            }
        }
        /*
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncObjectIdSet  = setBillingAccountId;
        syncManager.emailNotificationEnabled = false;
        
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        System.debug('>>>>> Sync Result:' + syncResult);
        */
        if(!exceptionList.isEmpty()) {
            ExceptionLogger.log(exceptionList);
        }
        
        update scope;
    }        
               
    global void finish(Database.BatchableContext BC) {   
        //Query for pending updates - this job may be scheduled one more time due to Zuora Sync. 
        //But the job will do nothing if the Sync result is back within the period
        system.debug('Query------------'+query);
        sObject[] lstPendingSubs = Database.query(query);
        
        //Schedule 10 minutes Batch Job to overcome Zuora Call Limit
        if(lstPendingSubs != null && !lstPendingSubs.isEmpty())
        {
            MassSPCAmendBatch batch = new MassSPCAmendBatch();
            System.scheduleBatch(batch, 'Mass SPC Amendment', 10, 10);
        }
    }
    
    public static List<Zuora.zApi.AmendRequest> createCoverPriceAmendmentReqs(List<Zuora__Subscription__c> lstSubs)
    {
        List<Zuora.zApi.AmendRequest> lstAmendReqs = new List<Zuora.zApi.AmendRequest>();
        Map<String,zqu__ProductRatePlanCharge__c> mapNameProdRatePlanCharge = new Map<String,zqu__ProductRatePlanCharge__c>();      
        Map<String, List<Zuora__SubscriptionProductCharge__c>> mapZRatePlanIdToSPCLst = new Map<String, List<Zuora__SubscriptionProductCharge__c>>();
        Map<Id, Set<String>> mapSubToRatePlanIdList = new Map<Id, Set<String>>();
        Set<String> setProductSKU = new Set<String>();
        Set<String> setChargeName = new Set<String>();
        Set<String> setRatePlanName = new Set<String>();
        //START D-2992 Wenjun 22/05/15 : Query Subscription Base Discount
        Map<Id, SPCDiscWrapper> mapSubToDisc = new Map<Id, SPCDiscWrapper>();
        
        if(!lstSubs.isEmpty())
        {
            for(Zuora__SubscriptionProductCharge__c spcObj: [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__RatePlanName__c,  
                           Zuora__RatePlanId__c, Zuora__ProductSKU__c, Zuora__Subscription__c, Zuora__Model__c, Zuora__Quantity__c, 
                           Zuora__EffectiveStartDate__c, Zuora__Price__c 
                           FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c in : lstSubs AND Zuora__Model__c = :GlobalVariableClass.SPC_MODEL_UNIT])
             {
                    setProductSKU.add(spcObj.Zuora__ProductSKU__c);
                    setChargeName.add(spcObj.Name);
                    setRatePlanName.add(spcObj.Zuora__RatePlanName__c);
                    
                    if(mapSubToRatePlanIdList.containsKey(spcObj.Zuora__Subscription__c))
                        mapSubToRatePlanIdList.get(spcObj.Zuora__Subscription__c).add(spcObj.Zuora__RatePlanId__c);
                    else
                        mapSubToRatePlanIdList.put(spcObj.Zuora__Subscription__c, new Set<String> {spcObj.Zuora__RatePlanId__c});
                    
                    if(mapZRatePlanIdToSPCLst.containsKey(spcObj.Zuora__RatePlanId__c))
                         mapZRatePlanIdToSPCLst.get(spcObj.Zuora__RatePlanId__c).add(spcObj);
                    else
                         mapZRatePlanIdToSPCLst.put(spcObj.Zuora__RatePlanId__c, new List<Zuora__SubscriptionProductCharge__c> {spcObj});
             }
            //END D-2992 Wenjun 22/05/15
            
            //Get Rate Plan Charges
            for(zqu__ProductRatePlanCharge__c prpc : [Select Id, Name, zqu__ZuoraId__c,zqu__UOM__c, zqu__Type__c, 
                        sum__c, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c
                 From zqu__ProductRatePlanCharge__c Where Name in :setChargeName AND zqu__Deleted__c = false
                 AND zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c IN:setProductSKU 
                 AND zqu__ProductRatePlan__r.Name in : setRatePlanName])
            {
                String key = prpc.Name + prpc.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c;
                mapNameProdRatePlanCharge.put(key,prpc);
            }
            
            Date effectiveDate = Date.today().toStartOfMonth().addMonths(1);

            for(Zuora__Subscription__c zSub : lstSubs)      
            {       
                System.debug('===> ' + zSub.Id);
                if(mapSubToRatePlanIdList.containsKey(zSub.Id))
                {  
                    // Amend Request
                    Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
                    Zuora.zObject[] amendments = new List < Zuora.zObject > {};
                    
                    if (zSub.Zuora__SubscriptionStartDate__c > effectiveDate)
                        effectiveDate = zSub.Zuora__SubscriptionStartDate__c;
                    
                    System.debug('===> ' + mapSubToRatePlanIdList.get(zSub.Id).size());
                    
                    //Create Amendment Object for each Rate Plan                    
                    for(String spcRatePlanID : mapSubToRatePlanIdList.get(zSub.Id))
                    {
                        Zuora.zObject amendObj = new Zuora.zObject('Amendment');
                        List<Zuora.zObject> ratePlanChargeDataList = new List<Zuora.zObject>();
                        
                        amendObj.setValue('Description', 'Mass SPC Amend');
                        amendObj.setValue('ContractEffectiveDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                        amendObj.setValue('Name', 'Mass SPC Amendment');
                        amendObj.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c);        
                        amendObj.setValue('Type', 'UpdateProduct');
                        amendObj.setValue('ServiceActivationDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                        
                        //Prepare Rate Plan Data
                        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
                        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
                        ratePlan.setValue('AmendmentSubscriptionRatePlanId', spcRatePlanID);
                        ratePlan.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c); 

                        for(Zuora__SubscriptionProductCharge__c zSubProductCharge:mapZRatePlanIdToSPCLst.get(spcRatePlanID))
                        {
                            Zuora.zObject ratePlanChargeObj = new Zuora.zObject('RatePlanCharge');
                            String key = zSubProductCharge.Name + zSubProductCharge.Zuora__ProductSKU__c;
                            zqu__ProductRatePlanCharge__c zProdRatePlanCh = mapNameProdRatePlanCharge.get(key);
                            
                            if(zProdRatePlanCh == null) continue; //START END D-2699 27/03/15 Wenjun
                                                        
                            ratePlanChargeObj.setValue('ProductRatePlanChargeId', zProdRatePlanCh.zqu__ZuoraId__c); 
                            ratePlanChargeObj.setValue('Id', zSubProductCharge.Zuora__Zuora_Id__c); 
                            ratePlanChargeObj.setValue('RatePlanId', zSubProductCharge.Zuora__RatePlanId__c);           
                            ratePlanChargeObj.setValue('Price', zSubProductCharge.Zuora__Price__c); 
                            //END D-2992 Wenjun 22/05/15
                            ratePlanChargeObj.setValue('Quantity', zSubProductCharge.Zuora__Quantity__c);
                                
                            Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
                            ratePlanChargeData.setValue('RatePlanCharge',ratePlanChargeObj);         
                            ratePlanChargeDataList.add(ratePlanChargeData);     
                        }

                        ratePlanData.setValue('RatePlan', ratePlan);
                        ratePlanData.setValue('RatePlanChargeData', ratePlanChargeDataList);
                        
                        amendObj.setValue('RatePlanData', ratePlanData); 
                        amendments.add(amendObj);                   
                    }

                    amendRequest.amendments = amendments;
                    // Amend Options
                    amendRequest.AmendOptions = createAmendOption();          
                    // Amend Preview
                    amendRequest.previewOptions = createPreviewOption();
        
                    lstAmendReqs.add(amendRequest);
                } // End of If
            } //End of For
        } //End of If
        return lstAmendReqs;
    }
    
    public static Zuora.zApi.AmendOptions createAmendOption()
    {
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;
        
        return amendmentOption;
    }
    
    public static Zuora.zApi.PreviewOptions createPreviewOption()
    {
        Zuora.zApi.PreviewOptions previewOptions = new Zuora.zApi.PreviewOptions();
        previewOptions.EnablePreviewMode = false;
        
        return previewOptions;
    }
    
    Class SPCDiscWrapper
    {
        Date effectiveDT {get;set;}
        Decimal discRate {get;set;}
        
        SPCDiscWrapper(Date inputDT, Decimal inputRate)
        {
            effectiveDT = inputDT;
            discRate = inputRate;
        }
    }
}