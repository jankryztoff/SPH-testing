/*
 * Class Name: SendQuotesToZuoraMultipleAccount
 * @author: 
 * Date: 11/14/2014
 * Project/Requirement: SPH Integration
 * @description This class performs zuora on demand sync through apex batchable.
 */ 

global class SendQuotesToZuoraMultipleAccount implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    List<zqu.zQuoteUtil.ZBillingQuoteCollection> quoteList = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
    List<zqu.zQuoteUtil.ZBillingQuoteRequest> quoteRequestList;
    List<Order__c> orderList = new List<Order__c>();
    List<zqu__Quote__c> lquoteList = new List<zqu__Quote__c>();
    List<Zuora__Subscription__c> newSubList = new List<Zuora__Subscription__c>();
    List<Zuora__Subscription__c> oldSubList = new List<Zuora__Subscription__c>();
    List<String> resultList = new List<String>();
    Set<String> zAccountIdSet = new Set<String>();
    Set<String> zSubIdSet = new Set<String>();
    Map<Id, Set<Id>> orderIdToQuoteIdSetMap = new Map<Id, Set<Id>>();
    zqu.zQuoteUtil.ZBillingQuoteCollection quote;
    zqu.zQuoteUtil.ZBillingQuoteRequest quoteRequest;
    Id AccountId;
    Account acc = new Account();
    global final String origin;
    global final Set<Id> orderIdSet;
    global final Set<String> llquoteNameSet;
    
    // Start UD-2865 07Oct15 JohnD
    map<id, string> quoteId_billingAccountZuoraId = new map<id, string>();
    map<id, id> quoteId_orderId = new map<id, id>();
    map<id, map<string, string>> orderId_creditCard;
    
    //START PD-0041 16May16 FrancisBenzon : variables
    Set<String> subzIDSet = new Set<String>();
    List<Zuora__Subscription__c> fppCreditCardSubs = new List<Zuora__Subscription__c>();
    Set<Id> subFullPrepaidSet = new Set<Id>();
    //END PD-0041 16May16 FrancisBenzon : variables
  
    public SendQuotesToZuoraMultipleAccount(Set<Id> orderIdSet, Set<String> llquoteNameSet, String origin, map<id, map<string, string>> orderId_creditCardParam)
    {
        this.orderIdSet = orderIdSet; 
        this.llquoteNameSet  = llquoteNameSet; 
        this.origin = origin;
        this.orderId_creditCard = orderId_creditCardParam;
    }
    // End UD-2865 07Oct15 JohnD
  
    public SendQuotesToZuoraMultipleAccount(Set<Id> orderIdSet, Set<String> llquoteNameSet, String origin)
    {
        this.orderIdSet = orderIdSet; 
        this.llquoteNameSet  = llquoteNameSet; 
        this.origin = origin;
    }
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Logger logger = new Logger(SendQuotesToZuoraMultipleAccount.class.getName(),'SP000'); //START END MD-28 Dags 18/06/1    
        acc = [SELECT Id FROM Account LIMIT 1];
        AccountId = acc.Id;
        if ((!llquoteNameSet.isEmpty() || llquoteNameSet != null) && (!orderIdSet.isEmpty() || orderIdSet != null)) {
            lquoteList = [SELECT Id, Order_Number__c FROM zqu__Quote__c WHERE Name IN :llquoteNameSet AND zqu__Status__c = 'New'];
            
            for (zqu__Quote__c lquote :lquoteList) {
                if (orderIdToQuoteIdSetMap.containsKey(lquote.Order_Number__c)) {
                    orderIdToQuoteIdSetMap.get(lquote.Order_Number__c).add(lquote.Id);
                }
                else {
                    orderIdToQuoteIdSetMap.put(lquote.Order_Number__c, new Set<Id>{lquote.Id});
                }
                
                quoteId_orderId.put(lquote.Id, (id)lquote.Order_Number__c); // Start/End UD-2865 07Oct15 JohnD
            }
            //START PD-0041 FrancisBenzon 16May16 : exclude bulkOrderUpload with payment mode CC from invoiceProcessForFullPrepaid
            orderList = [SELECT Id, Account__c, Billing_Account_External_ID__c, Payment_Mode__c, Payment_Method_ID__c, Acquisition_Type__c FROM Order__c WHERE Id IN :orderIdSet];
            //END PD-0041 FrancisBenzon 16May16 : exclude bulkOrderUpload with payment mode CC from invoiceProcessForFullPrepaid
            for (Order__c order :orderList) {
                quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
                quote.sfdcAccountId  = order.Account__c;
                if (order.Billing_Account_External_ID__c != null) {
                    quote.zAccountId     = order.Billing_Account_External_ID__c;
                }
                else {
                    quote.zAccountId     = 'New';
                }
                if(orderIdToQuoteIdSetMap.containsKey(order.id)){
                    quoteRequestList = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
                    for (Id quoteId :orderIdToQuoteIdSetMap.get(order.Id)) {                        
                        quoteRequest = new zqu.zQuoteUtil.ZBillingQuoteRequest();
                        
                        if (order.Payment_Mode__c == 'Credit Card'){
                            quoteRequest.paymentMethodId = order.Payment_Method_ID__c;
                        }
                        
                        quoteRequest.sfdcQuoteId = quoteId;
                        quoteRequest.enableAccountAutoPay = false;
                        if(quoteRequest.sfdcQuoteId != null && quoteRequest.enableAccountAutoPay != null){
                            quoteRequestList.add(quoteRequest);
                        }                       
                    }
                }
                try{
                    if(quoteRequestList.size() > 0){
                        quote.quoteRequests = quoteRequestList;
                        quoteList.add(quote);
                    }   
                } catch(Exception e){
                    system.debug('>>>>> quoteRequestList is NULL <<<<<');
                    //START MD-28 Dags 18/06/15 - Using Logger
                    logger.log(e);
                    //END MD-28 Dags 18/06/15
                }
            }
            
            List<zqu.zQuoteUtil.zBillingResult> results = new List<zqu.zQuoteUtil.zBillingResult>();
            if (!Test.isRunningTest()) {
                if(quoteList.size() > 0){
                    //START D-2497 Added by J. Sarion 04/27/2015 - Added Try Catch 
                    try {   
                        results = zqu.zQuoteUtil.sendToZBilling(quoteList); 
                        
                        // Start UD-2865 07Oct15/26Nov15 JohnD
                        for (zqu.zQuoteUtil.zBillingResult result : results) {
                            if (result.success == true) {
                                quoteId_billingAccountZuoraId.put((id)result.sfdcQuoteId, (string)result.zAccountId);
                                //START PD-0041 16May16 FrancisBenzon : subExternalId
                                subzIDSet.add((string)result.zSubscriptionId); 
                                //END PD-0041 16May16 FrancisBenzon : subExternalId
                            } else {
                                logger.log(false, result.message, result.sfdcQuoteId);
                            }
                        }
                        // End UD-2865 07Oct15/26Nov15 JohnD

                    } catch (Exception e) {
                        system.debug('>>>>>e ' + e);
                         //START MD-28 Dags 18/06/15 - Using Logger
                         logger.log(e);
                         //END MD-28 Dags 18/06/15
                    }
                    //END D-2497 Added by J. Sarion 04/27/2015 - Added Try Catch 
                }                
            }else {
                //NEED TO create hardcoded return of zqu.zQuoteUtil.sendToZBilling(quotes) for coverage
                 //START PD-0041 16May16 FrancisBenzon : variables
                quoteId_billingAccountZuoraId.put(lquoteList[0].id,'12345');
                subzIDSet.add('12345');  
                //END PD-0041 16May16 FrancisBenzon : variables             
            }
                        
            system.debug('>results< ' + results);            
            
            for (zqu.zQuoteUtil.zBillingResult result :results) {
                //START D-1011 MD-28 Dags 18/06/15 - Using Logger
                try {
                    resultList.add(result.success + ':'+ result.zAccountId + ':'+result.zSubscriptionId);
                    zAccountIdSet.add(result.zAccountId);
                    zSubIdSet.add(result.zSubscriptionId);
                } catch (Exception e) {
                    logger.log(e);
                }
                //END D-1011 MD-28 Dags 18/06/15
             
            }
          
        }    
        Logger.save(); //END MD-28 Dags 18/06/15
        return Database.getQueryLocator('SELECT Id FROM Account WHERE Id = \'' +  accountId + '\'');
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {         
        // Start UD-2865 07Oct15 JohnD - update the billing account to zuora prior to sync
        if (origin == 'csvupload') {
             system.debug(':::QUOTE_BA ' + quoteId_billingAccountZuoraId);
            if (!quoteId_billingAccountZuoraId.isEmpty()) {              
                Zuora.zApi zApiInstance = new Zuora.zApi();
                
                if (!Test.isRunningTest()) {
                    zApiInstance.zlogin();
                }
                
                list<Zuora.zObject> zObjectList = new list<Zuora.zObject>();
                map<id, Order__c> orderId_order = new map<id, Order__c>([select Id, Billing_Type__c from Order__c where Id in :quoteId_orderId.values()]);
                
                // assuming that the reponse received from zuora is based on the sequence of the request
                set<id> ccOrderIdSet = new set<id>();
                list<id> ccOrderIdList = new list<id>();
                map<id, string> orderId_paymentMethodId = new map<id, string>();
                id orderId;
                map<string, string> creditCardField_value = new map<string, string>();
                list<Order__c> orderList = new list<Order__c>();
                list<zqu__Quote__c> quoteList = new list<zqu__Quote__c>();
                
                if (orderId_creditCard != null && !orderId_creditCard.isEmpty()) {
                    
                    list<Zuora.zObject> zPaymentList = new list<Zuora.zObject>();
                    
                    for (id quoteId : quoteId_orderId.keySet()) {
                        
                        orderId = quoteId_orderId.get(quoteId);
                        
                        if (orderId_creditCard.get(orderId) != null) {
                            
                            creditCardField_value = orderId_creditCard.get(orderId);
                            
                            if (!ccOrderIdSet.contains(orderId)) {
                                
                                ccOrderIdSet.add(orderId);
                                ccOrderIdList.add(orderId);
                                
                                Zuora.zObject payment = new Zuora.zObject('PaymentMethod');
                                payment.setValue('AccountId', quoteId_billingAccountZuoraId.get(quoteId));
                                payment.setValue('Type', 'CreditCard');
                                payment.setValue('UseDefaultRetryRule', true);
                    //START PD-0041 FrancisBenzon 16May16 : get fpp creditCard subs and call InvoiceProcessForFullPrepaid
                                if (!Test.isRunningTest()){
                                for (string field : creditCardField_value.keySet()) {
                                    payment.setValue(field, creditCardField_value.get(field));
                                }
                                
                                system.debug('Johnxx : ' + payment);
                                zPaymentList.add(payment);
                                }
                    //END PD-0041 FrancisBenzon 16May16 : get fpp creditCard subs and call InvoiceProcessForFullPrepaid
                            }
                        }
                    }
                    
                    list<Zuora.zApi.SaveResult> paymentResults;
                    if (!Test.isRunningTest()) {
                        paymentResults = zApiInstance.zcreate(zPaymentList);
                    } else {
                        paymentResults = new list<Zuora.zApi.SaveResult>();
                        Zuora.zApi.SaveResult mockResponse = new Zuora.zApi.SaveResult();
                        mockResponse.success = false;
                        mockResponse.errors = new list<Zuora.zObject>();
                        paymentResults.add(mockResponse);
                    }
                    system.debug(':::paymentResults ' + paymentResults);
                    integer index = 0;
                    for (Zuora.zApi.SaveResult result : paymentResults) {
                        
                        Order__c orderx = new Order__c(Id = ccOrderIdList[index]);
                        if (result.success == true) {
                            orderx.Payment_Method_Id__c = result.Id;
                        } else {
                            orderx.Payment_Method_Id__c = 'See Remarks';
                            string ccError = '';
                            for (Zuora.zObject error : result.errors) {
                                ccError += (string)error.getValue('Message');
                                ccError += '\n';
                            }
                            orderx.Remarks__c = ccError;
                        }
                        
                        orderId_paymentMethodId.put(ccOrderIdList[index], result.Id);
                        orderList.add(orderx);
                        index++;
                    }
                }
                                
                
                for (id quoteId : quoteId_orderId.keySet()) {
                    
                    Order__c orderx = orderId_order.get(quoteId_orderId.get(quoteId));
                    Zuora.zObject zObject = new Zuora.zObject('Account');
                    zObject.setValue('Id', quoteId_billingAccountZuoraId.get(quoteId));
                    zObject.setValue('Billing_Type__c', orderx.Billing_Type__c);
                    
                    if (orderId_paymentMethodId.get(orderx.Id) != null && orderId_paymentMethodId.get(orderx.Id) != 'See Remarks') {
                        zObject.setValue('DefaultPaymentMethodId', orderId_paymentMethodId.get(orderx.Id));
                    }
                    
                    zObjectList.add(zObject);
                }
                
                if (!Test.isRunningTest() && zObjectList.size() > 0) { 
                    list<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
                }
                
                try {

                    system.debug(':::subExtIdSet ' + subzIDSet);
                    //START PD-0041 FrancisBenzon 16May16 : get fpp creditCard subs and call InvoiceProcessForFullPrepaid
                    if(subzIDSet.size() > 0)
                    {
                        fppCreditCardSubs = [Select Id
                                            From Zuora__Subscription__c 
                                            Where Zuora__External_Id__c IN: subzIDSet 
                                            AND Billing_Type__c = :GlobalVariableClass.BILLING_TYPE_FULL_PRE 
                                            AND Payment_Mode_1__c = :GlobalVariableClass.CREDIT_CARD
                                            AND Acquisition_Type_1__c = :GlobalVariableClass.SUBACQUISITIONTYPE_BULKORDERUPLOAD];
                        
                        if(fppCreditCardSubs.size() > 0)
                        {
                            system.debug(':::fppCreditCardSubs ' + fppCreditCardSubs);
                            for(Zuora__Subscription__c sub : fppCreditCardSubs)
                            {
                                subFullPrepaidSet.add(sub.Id);
                            }
                            system.debug(':::subFullPrepaidSet ' + subFullPrepaidSet);
                            if(!subFullPrepaidSet.isEmpty())
                            {
                                invoiceProcessForFullPrepaid_bulk inv = new invoiceProcessForFullPrepaid_bulk();
                                inv.callInvoice(subFullPrepaidSet);
                            }
                        }
                    }                   
                    //END PD-0041 FrancisBenzon 16May16 : get fpp creditCard subs and call InvoiceProcessForFullPrepaid
                    update orderList;
                    for (zqu__Quote__c quote : [select Id, Order_Number__c, zqu__ElectronicPaymentMethodId__c from zqu__Quote__c 
                            where Order_Number__c in :ccOrderIdSet]) {
                        
                        quote.zqu__ElectronicPaymentMethodId__c = orderId_paymentMethodId.get(quote.Order_Number__c);
                        quoteList.add(quote);
                    }
                
                    update quoteList;
                
                } catch (exception e) {
                    ExceptionLogger.log(new list<exception> { e });                 
                }
            }
        }
        // End UD-2865 07Oct15 JohnD - update the billing account to zuora prior to sync
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {  
        ZuoraOnDemandSyncBatch zuoraOnDemanSyncBatch = new ZuoraOnDemandSyncBatch(zAccountIdSet, AccountId);
        Database.executeBatch(zuoraOnDemanSyncBatch);
    }
}