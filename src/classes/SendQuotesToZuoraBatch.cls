/*
 * Class Name: SendQuotesToZuoraBatch
 * @author: Kevin H. Evasco
 * Date: 10/16/2014
 * Project/Requirement: SPH Integration
 * @description This class performs zuora on demand sync through apex batchable.
 * 
 * History: 09/12/2014 Kevin Evasco Created Apex Batchable
 * History: 04/20/2015 D-2743 Kevin Evasco - Reconstructed class
 */


global class SendQuotesToZuoraBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    list<Id> lQuoteIds; 
    string PaymentMode; 
    string PaymentModeOther; 
    string sDeliveryChargeType; 
    boolean bCreateNewBillingAccount; 
    boolean bCreateDeliverySubscription; 
    boolean bPayDeliveryChargeNow; 
    ID ExistingDeliverySubscriptionId; 
    ID SFBillingAccount; 
    string zBillingAccount; 
    decimal SubscriberCharge; 
    ID AccountId; 
    ID OrderId; 
    decimal DeliveryFPSubscriptionUsage; 
    string CCPaymentMethodID;
    set<string> zAccountId = new set<string>();
    Set<Id> orderLineItemIdSet = new Set<Id>();
    
    Order__c orderRecord;
    
    Boolean isSuccessful = true;
    
    public SendQuotesToZuoraBatch(list<Id> lQuoteIds,string PaymentMode, string PaymentModeOther, string sDeliveryChargeType,
                                        boolean bCreateNewBillingAccount, boolean bCreateDeliverySubscription, boolean bPayDeliveryChargeNow,
                                        ID ExistingDeliverySubscriptionId, ID SFBillingAccount, string zBillingAccount, decimal SubscriberCharge,
                                        ID AccountId, ID OrderId, decimal DeliveryFPSubscriptionUsage, string CCPaymentMethodID)
    {
            this.lQuoteIds = lQuoteIds; 
            this.PaymentMode = PaymentMode; 
            this.PaymentModeOther = PaymentModeOther; 
            this.sDeliveryChargeType = sDeliveryChargeType; 
            this.bCreateNewBillingAccount = bCreateNewBillingAccount; 
            this.bCreateDeliverySubscription = bCreateDeliverySubscription; 
            this.bPayDeliveryChargeNow = bPayDeliveryChargeNow; 
            this.ExistingDeliverySubscriptionId = ExistingDeliverySubscriptionId; 
            this.SFBillingAccount = SFBillingAccount; 
            this.zBillingAccount = zBillingAccount; 
            this.SubscriberCharge = SubscriberCharge; 
            this.AccountId = AccountId; 
            this.OrderId = OrderId; 
            this.DeliveryFPSubscriptionUsage = DeliveryFPSubscriptionUsage; 
            this.CCPaymentMethodID = CCPaymentMethodID;
    }
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {                   
        System.debug('this.bCreateNewBillingAccount start' + this.bCreateNewBillingAccount);
        orderRecord = [SELECT Id FROM Order__c WHERE Id = :OrderId LIMIT 1];
        return Database.getQueryLocator([SELECT Id, Order__r.Billing_Account_Creation_Mode__c FROM Order_Line_Item__c WHERE Order__c = :OrderId]);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<Order_Line_Item__c> scope)
    {              
        Order_Line_Item__c orderLineItemRecord = scope.get(0);
        Quote_Handler quoteHandler = new Quote_Handler();
        quoteHandler.Create_Quotes(orderRecord,'ESHOP Webservice',orderLineItemRecord.Id);
        orderLineItemIdSet.add(orderLineItemRecord.Id);
        if(orderLineItemRecord.Order__r.Billing_Account_Creation_Mode__c == 'Create New Billing Account') {
            bCreateNewBillingAccount = true;
        }
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
        lQuoteIds = new List<Id>();
        Logger logger = new Logger(SendQuotesToZuoraBatch.class.getName(),'SP000'); //START END D-1011MD-28 Dags 18/06/15       
        for (zqu__Quote__c QuoteList: [select id from zqu__Quote__c where Order_Line_Item_Number_1__c IN :orderLineItemIdSet]) {
                lQuoteIds.add(QuoteList.id);
        }
        
        Set<Id> quoteIDSet = new Set<Id>();
        list<zqu.zQuoteUtil.ZBillingQuoteCollection> quotes = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
        System.debug('bCreateNewBillingAccount ' + bCreateNewBillingAccount);
        zqu.zQuoteUtil.ZBillingQuoteCollection quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
        quote.sfdcAccountId  = AccountId;   
        
        System.debug('BEFORE bCreateNewBillingAccount: ' + bCreateNewBillingAccount);   
        System.debug('BEFORE AccountId: ' + AccountId);     
        System.debug('BEFORE zBillingAccount: ' + zBillingAccount);
        
        if (bCreateNewBillingAccount){ 
            quote.zAccountId     = 'new';       
        }else{
            quote.zAccountId     = zBillingAccount;         
            PaypalHelper.linkZAccountToSF(zBillingAccount,AccountId);
        }
        
        list<zqu.zQuoteUtil.ZBillingQuoteRequest> lQReq = new list<zqu.zQuoteUtil.ZBillingQuoteRequest>();
        for(Id i: lQuoteIds){
            zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
            
            if (PaymentMode == 'Credit Card' || PaymentMode == 'Paypal'){ //KRITHIKA PAYPAL
                req.paymentMethodId = CCPaymentMethodID;
            }
            req.sfdcQuoteId = i;
            req.enableAccountAutoPay = false;
            lQReq.add(req);
            quoteIDSet.add(i);
        }
                
        List<zqu__QuoteCharge__c> quoteChargesList = [SELECT Id, Name, zqu__Quote__c, zqu__ProductName__c, zqu__ProductRatePlanName__c, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Name FROM zqu__QuoteCharge__c WHERE zqu__Quote__c IN :quoteIDSet];
        
        Map<Id, List<zqu__QuoteCharge__c>> quote_quoteCharges_map = new Map<Id, List<zqu__QuoteCharge__c>>();
        
        for(zqu__QuoteCharge__c qCharge : quoteChargesList)
        {
            if(quote_quoteCharges_map.get(qCharge.zqu__Quote__c) == null)
            {
                quote_quoteCharges_map.put(qCharge.zqu__Quote__c, new List<zqu__QuoteCharge__c>());
            }
            quote_quoteCharges_map.get(qCharge.zqu__Quote__c).add(qCharge);
        }
        
        for(Id idValue : quote_quoteCharges_map.keySet())
        {
            List<zqu__QuoteCharge__c> qChargeList = quote_quoteCharges_map.get(idValue);
            Integer counter = 1;
            for(zqu__QuoteCharge__c qCharge : qChargeList)
            {               
                System.debug('Quote Charge #' + counter + ' for Quote ' + idValue + ': ' + qCharge);
                counter++;
            }
        }
        
        system.debug('QUOTE REQUESTS:::' + lQReq);
        
        
        quote.quoteRequests = lQReq;
        quotes.add(quote);
        
        for(Id idValue : quote_quoteCharges_map.keySet())
        {       
            List<zqu.zChargeGroup> quoteChgGrps = zqu.zQuoteUtil.getChargeGroups(idValue);
            for( zqu.ZChargeGroup oneChgGrp : quoteChgGrps )
            {
                system.debug('oneChgGrp.groupID = ' + oneChgGrp.groupID ) ;
                system.debug('oneChgGrp.productName = ' + oneChgGrp.productName) ;
                system.debug('oneChgGrp.rateplanName = ' + oneChgGrp.rateplanName ) ;
                system.debug('oneChgGrp.zCharges size = ' + oneChgGrp.zCharges.size( ) ) ;
            }       
        }
        System.debug('quotes ' + quotes); 
        List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quotes);
        
        list<string> lResult = new list<string>();
        set<string> zSubId = new set<string>();
        
        for (zqu.zQuoteUtil.zBillingResult result : results ) {
            //Returns are: Status:zAccountId:zSubscriptionId
            
            System.debug('RESULTS > '+ result);
            System.debug('SEND RESULT > '+ result.success + ':'+ result.zAccountId + ':'+result.zSubscriptionId);           
            lResult.add(result.success + ':'+ result.zAccountId + ':'+result.zSubscriptionId);
            zAccountId.add(result.zAccountId);
            zSubId.add(result.zSubscriptionId);
            
            //START D-1011 MD-28 Dags 18/06/15
            if (result.success != true) {
                logger.log(false,''+result); 
                // START 18 January 2015 D-4234 Kevin Evasco - Update Case Status to Zuora Issue - Subscription Creation
                isSuccessful = false;
                // END 18 January 2015 D-4234 Kevin Evasco - Update Case Status to Zuora Issue - Subscription Creation      

            }
            //END D-1011 MD-28 Dags 18/06/15
            
        }   
        
        // START 18 January 2015 D-4234 Kevin Evasco - Update Case Status to Zuora Issue - Subscription Creation
        if(isSuccessful == false) {        
            Logger.save(); //START END D-1011 MD-28 Dags 18/06/15
            updateCaseStatus();         
        }       
        // END 18 January 2015 D-4234 Kevin Evasco - Update Case Status to Zuora Issue - Subscription Creation
    }
    
    // START 18 January 2015 D-4234 Kevin Evasco - Update Case Status to Zuora Issue - Subscription Creation
    public void updateCaseStatus() {
        List<Case> caseList = [SELECT Id, Sub_Status__c FROM Case WHERE Order__c = :OrderId AND RecordTypeID = :ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION)];
        if(caseList.isEmpty() == false) {
            for(Case caseElement : caseList) {
                caseElement.Sub_Status__c = GlobalVariableClass.SEND_TO_ZUORA_ISSUE;            
            }
        }
    }
    // END 18 January 2015 D-4234 Kevin Evasco - Update Case Status to Zuora Issue - Subscription Creation
}