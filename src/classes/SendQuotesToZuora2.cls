/**
 * Class Name: SendQuotesToZuora2 
 * @History: D-3396 Wenjun 16 Sep 15 - Code Fix and Code Optimization 
 */

global class SendQuotesToZuora2 {
    
    public void RecievedData(list<Id> lQuoteIds,string PaymentMode, string PaymentModeOther, string sDeliveryChargeType,
                                        boolean bCreateNewBillingAccount, boolean bCreateDeliverySubscription, boolean bPayDeliveryChargeNow,
                                        ID ExistingDeliverySubscriptionId, ID SFBillingAccount, string zBillingAccount, decimal SubscriberCharge,
                                        ID AccountId, ID OrderId, decimal DeliveryFPSubscriptionUsage, string CCPaymentMethodID){
        
        SendQuoteToZBilling(lQuoteIds, PaymentMode, PaymentModeOther, sDeliveryChargeType, 
                                    bCreateNewBillingAccount, bCreateDeliverySubscription, bPayDeliveryChargeNow, 
                                    ExistingDeliverySubscriptionId, SFBillingAccount, zBillingAccount, SubscriberCharge,
                                    AccountId, OrderId, DeliveryFPSubscriptionUsage, CCPaymentMethodID);
        
    }
    
    
    //START: UD-1595 - JTeves - 18-June-2015 - moved actual callout to a synchronous method
    @future (callout=true)
    static void SendQuoteToZBilling(list<Id> lQuoteIds,string PaymentMode, string PaymentModeOther, string sDeliveryChargeType,
                                        boolean bCreateNewBillingAccount, boolean bCreateDeliverySubscription, boolean bPayDeliveryChargeNow,
                                        ID ExistingDeliverySubscriptionId, ID SFBillingAccount, string zBillingAccount, decimal SubscriberCharge,
                                        ID AccountId, ID OrderId, decimal DeliveryFPSubscriptionUsage, string CCPaymentMethodID){
        
        performCallout(lQuoteIds, PaymentMode, PaymentModeOther, sDeliveryChargeType, 
                                    bCreateNewBillingAccount, bCreateDeliverySubscription, bPayDeliveryChargeNow, 
                                    ExistingDeliverySubscriptionId, SFBillingAccount, zBillingAccount, SubscriberCharge,
                                    AccountId, OrderId, DeliveryFPSubscriptionUsage, CCPaymentMethodID);
    }    
    
    
    
    public static void performCallout(list<Id> lQuoteIds,string PaymentMode, string PaymentModeOther, string sDeliveryChargeType,
                                        boolean bCreateNewBillingAccount, boolean bCreateDeliverySubscription, boolean bPayDeliveryChargeNow,
                                        ID ExistingDeliverySubscriptionId, ID SFBillingAccount, string zBillingAccount, decimal SubscriberCharge,
                                        ID AccountId, ID OrderId, decimal DeliveryFPSubscriptionUsage, string CCPaymentMethodID) 
    {
        Logger logger = new Logger(SendQuotesToZuora2.class.getName());
        Boolean isZuoraFailed = false;
        Map<Id, Id> mapQuoteIdToCaseId = new Map<Id, Id>();
        Map<Id, Boolean> mapQuoteIdResult = new Map<Id, Boolean>();
        Map<Id, Boolean> mapCaseIdResult = new Map<Id, Boolean>();
        List<Case> lstCasesToUpd = new List<Case>();
        List<zqu.zQuoteUtil.ZBillingQuoteCollection> lstQuoteCollections = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
        zqu.zQuoteUtil.ZBillingQuoteCollection quoteCollection = new zqu.zQuoteUtil.ZBillingQuoteCollection();
        List<zqu.zQuoteUtil.ZBillingQuoteRequest> lstQuoteReqs = new list<zqu.zQuoteUtil.ZBillingQuoteRequest>();
        List<zqu.zQuoteUtil.zBillingResult> results = new List<zqu.zQuoteUtil.zBillingResult>();
        
        Set<Id> failedQuoteIdSet = new Set<Id>(); //START-END UD-3315 11/27/2015 Added by J.Sarion - Set of Ids for failed quotes
        String zAcctId; //START-END UD-3567 1/06/2016 Added by K.Tan - declare id to store successful quotes
        /******************** Prepare QuoteCollection ******************/
        quoteCollection.sfdcAccountId  = AccountId;   
        
        if (bCreateNewBillingAccount){ 
               quoteCollection.zAccountId = 'new';
        }else{
            quoteCollection.zAccountId = zBillingAccount;
        }
        
        for(Id quoteID: lQuoteIds){
            failedQuoteIdSet = new Set<Id>(); //START-END UD-3567 1/06/2016 Added by K.Tan - Instantiate failed Quotes
            zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
            
            if (PaymentMode == 'Credit Card'){
                req.paymentMethodId = CCPaymentMethodID;
            }
            
            req.sfdcQuoteId = quoteID;
            req.enableAccountAutoPay = false;
            lstQuoteReqs.add(req);
        }
        
        quoteCollection.quoteRequests = lstQuoteReqs;
        lstQuoteCollections.add(quoteCollection);
        
        if (!Test.isRunningTest()) 
        {
            /*START UD-3315 11/26/2015 Added by J.Sarion
            *Assumption: SendtoZBilling is an All-in-One operation. In case there's an error in the set of Quote Ids, the result will return the list of quotes that failed 
            *with the corresponding error message. Quotes that successfully processed will be pulled back.
            */
            for(Integer numberOfRetries = 0; numberOfRetries < 5; numberOfRetries++){
                try{
                    if(!lstQuoteReqs.isEmpty()){
                        results = zqu.zQuoteUtil.sendToZBilling(lstQuoteCollections);
            //Start UD-3446 28-Dec-2015 Added S.Puli
            String messageResults = '';
            messageResults = String.valueOf(results);
            logger.log(false, messageResults);
            //End UD-3446 28-Dec-2015 Added S.Puli
                    }
                } catch(Exception e) {
                    system.debug(':::ERRORSEND ' + e);
                    logger.log(e);
                    isZuoraFailed = true;
                    break;
                }
                system.debug(':::RESULTSSENDING ' + results);
                //Process sendToZBilling results
                for (zqu.zQuoteUtil.zBillingResult result : results ) 
                {
                  if (result.success == true) {
                    mapQuoteIdResult.put(result.sfdcQuoteId, true);
                    zAcctId = result.zAccountId; //START-END UD-3567 1/06/2016 Added by K.Tan - Update lQuoteIds to failedQuoteIdSet
                  } else {
                    mapQuoteIdResult.put(result.sfdcQuoteId, false);
                    logger.log(false, result.message, result.sfdcQuoteId);
                    
                    failedQuoteIdSet.add(result.sfdcQuoteId);
                  }
                }
                system.debug(':::FAILEDQUOTES ' + failedQuoteIdSet);
                if(!failedQuoteIdSet.isEmpty()){
                    lstQuoteReqs = new list<zqu.zQuoteUtil.ZBillingQuoteRequest>();
                    lstQuoteCollections = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
                    
                    for(Id quoteID: failedQuoteIdSet){ //START-END UD-3567 1/06/2016 Added by K.Tan - Update lQuoteIds to failedQuoteIdSet
                        zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
                        
                        if (PaymentMode == 'Credit Card'){
                            req.paymentMethodId = CCPaymentMethodID;
                            //req.setNewPaymentAsDefault = true;
                        }
                        
                        req.sfdcQuoteId = quoteID;
                        req.enableAccountAutoPay = false;
                        lstQuoteReqs.add(req);
                    }
                    
                    quoteCollection.quoteRequests = lstQuoteReqs;
                    quoteCollection.zAccountId = zAcctId; //START-END UD-3567 1/06/2016 Added by K.Tan - Update lQuoteIds to failedQuoteIdSet
                    lstQuoteCollections.add(quoteCollection);
                }
                else{
                    break;
                }
            }
        }
        //END UD-3315 11/27/2015 Added by J.Sarion
        
        /******************** Update Case **********************/
        for(zqu__Quote__c quote: [select Id, zqu__Status__c, Order_Line_Item_Number_1__r.Case__c from zqu__Quote__c where Id in :lQuoteIds])
        {
            if(quote.Order_Line_Item_Number_1__r.Case__c != NULL)
            {
                Id caseId = quote.Order_Line_Item_Number_1__r.Case__c;
                
                if(isZuoraFailed) //Send to Zuora Exception
                {
                    mapCaseIdResult.put(caseId, false);
                } 
                else { //Process sendToBilling Results
                    if(!mapCaseIdResult.containsKey(caseId) || mapCaseIdResult.get(caseId))
                    {
                        if(mapQuoteIdResult.containsKey(quote.Id))
                        {
                            if(mapQuoteIdResult.get(quote.Id))
                                mapCaseIdResult.put(caseId, true);
                            else
                                mapCaseIdResult.put(caseId, false);
                        }
                    }
                }
            }
        }
        system.debug(':::MAPCASEID ' + mapCaseIdResult);
        for(Id caseIdToUpd : mapCaseIdResult.keySet())
        {
            Case caseRec = new Case (Id = caseIdToUpd);
            if(mapCaseIdResult.get(caseIdToUpd))
            {
                caseRec.Status = GlobalVariableClass.STATUS_PENDING;
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            }
            else {
                caseRec.Status = GlobalVariableClass.STATUS_PENDING;
                caseRec.Sub_Status__c = GlobalVariableClass.SEND_TO_ZUORA_ISSUE;
            }
            lstCasesToUpd.add(caseRec);
        }

        if (!lstCasesToUpd.isEmpty()) {
            try {
                UPDATE lstCasesToUpd;
            } catch (Exception e) {
                system.debug('ERRORCAS ' + e);
                logger.log(e);
            } 
        }
        
        try
        {
            logger.save(); //Save the log
        }
        catch (Exception e) {
            system.debug('ERROR ' + e);
        }
    }    
    //END: UD-1595 - JTeves - 18-June-2015 - moved actual callout to a synchronous method
}