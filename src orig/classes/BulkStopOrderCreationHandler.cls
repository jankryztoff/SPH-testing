public class BulkStopOrderCreationHandler {
 
    final id CASE_RECORD_TYPE_ID = [select Id from RecordType where sObjectType = 'Case' and DeveloperName ='Stop_Subscription'].Id;
    final string CREATION_MODE = 'Auto PStop';
    final string STATUS = 'Pending';
    final string SUB_STATUS = 'Ready for Submission';
    final string SUBJECT = 'Stop Subscription';
    final string SUB_CATEGORY = 'Stop Subscription';
    final string CATEGORY = 'Subscription Request';
    final string ORDER_TYPE = 'Stop';
    final string TERMINATION_REASON = 'Payment failure - '; //START-END UD-2549 3/24/2016 Added by J.Sarion 
    final string ACQUISITION_TYPE = 'System Generated';
    final string ERR_LOCK_ROW ='UNABLE_TO_LOCK_ROW';    //START-END UD-2549 4/6/2016 Added by John D - retry mechanism for unable to lock row error
    final date EFFECTIVE_DATE = date.today();
    
    map<id, list<Zuora__Subscription__c>> accountId_subscriptionList = new map<id, list<Zuora__Subscription__c>>();
    map<string, string> caseIdentifier_orderIdentifier = new map<string, string>();
    map<string, string> orderLineItemIdentifier_orderIdentifier = new map<string, string>();
    map<string, string> orderLineItemIdentifier_caseIdentifier = new map<string, string>();
    map<string, Order__c> orderIdentifier_order = new map<string, Order__c>();
    map<string, Case> caseIdentifier_case = new map<string, Case>();
    map<string, Order_Line_Item__c> orderLineItemIdentifier_orderLineItem = new map<string, Order_Line_Item__c>();
    map<id, id> subscriptionId_caseId = new map<id, id>();
    map<id, string> subscriptionId_caseIdentifier = new map<id, string>();
    map<string, date> productCode_earliestStartDate = new map<string, date>();
    map<id, Package__c> packageId_package = new map<id, Package__c>();
    map<Id, Id> subIdToAccountIdMap = new map<Id, Id>(); //START-END UD-2549 4/10/2016 Added by J.Sarion
    list<Zuora__Subscription__c> subscriptionList = new list<Zuora__Subscription__c>();
    list<Case_Subscription__c> caseSubscriptionList = new list<Case_Subscription__c>();
    list<string> billingAccountIdList = new list<string>();
    set<id> subscriptionIdSet = new set<id>();  //START-END UD-2549 4/6/2016 Added by John D - retry mechanism for unable to lock row error
    string orderIdentifier;
    string orderLineItemIdentifier;
    string caseIdentifier;
    boolean isExecuteCancellation = true;
    
    //START UD-2549 4/11/2016 Added by J.Sarion - Set PStop Testing Date
    public Boolean isBillRun = boolean.valueOf(ConstantsSLB.getKeyId('BILL_RUN_TESTING').toLowerCase());
    Date_Configuration__c dateConfig = Date_Configuration__c.getInstance('PAYMENT_FAILURE_TEST_PSTOP_DATE');
    public Date testingPSTOPDate = dateConfig.Date__c;
    //END UD-2549 4/11/2016 Added by J.Sarion - Set PStop Testing Date

    Logger logger = new Logger(BulkStopOrderCreationHandler.class.getName());
    
    public map<id, id> createRelatedRecords(List<Zuora__Subscription__c> subList) { //START-END UD-2549 3/23/2016 Added by J.Sarion - changed param
        system.debug('>>>>>subList ' + subList);
        system.debug('>>>>>subList ' + subList.size());
        prepareRecords(subList); //START-END UD-2549 3/23/2016 Added by J.Sarion - changed param
        executeRecordCreation();
        //executeCancellation();
        
        logger.save();
        
        return subscriptionId_caseId;
    }
    
    // invoke SP057 - selective approach
    private void executeCancellation() {
        
        if (isExecuteCancellation) {
            SP_CancelSubscriptionInZuora batchCancel = new SP_CancelSubscriptionInZuora(billingAccountIdList, 2, date.today());
            Database.executeBatch(batchCancel);
        }
    }
    
    private void retrieveCrossReferrenceData() {
        system.debug('>>>>>productCode_earliestStartDate ' + productCode_earliestStartDate);
        //START UD-2549 3/30/2016 Added by J.Sarion - Order by desc
        // start - retrieve publication earliest start date
        for (Product_Publication__c pp : [select ZProduct__r.ProductCode__c, Publication_Code__r.Earliest_Start_Date__c
                from Product_Publication__c where ZProduct__r.ProductCode__c in :productCode_earliestStartDate.keySet()
                order by Publication_Code__r.Earliest_Start_Date__c desc]) {
            
            productCode_earliestStartDate.put(pp.ZProduct__r.ProductCode__c, pp.Publication_Code__r.Earliest_Start_Date__c);
            
            //START UD-2549 4/11/2016 Added by J.Sarion - Set PStop Date
            if(isBillRun) {
                productCode_earliestStartDate.put(pp.ZProduct__r.ProductCode__c, testingPSTOPDate);
            }
            //END UD-2549 4/11/2016 Added by J.Sarion - Set PStop Date
        }
        // end - retrieve publication earliest start date
        //END UD-2549 3/30/2016 Added by J.Sarion - Order by desc       
        system.debug('>>>>>productCode_earliestStartDate ' + productCode_earliestStartDate);
    }
    
    
    private void prepareRecords(List<Zuora__Subscription__c> subList) { //START-END UD-2549 3/23/2016 Added by J.Sarion - changed param
        
        // start - map subscriptions under the same account
        for (Zuora__Subscription__c sub :subList) { //START-END UD-2549 3/23/2016 Added by J.Sarion - changed param
            
            if (accountId_subscriptionList.get(sub.Zuora__Account__c) == null) {
                accountId_subscriptionList.put(sub.Zuora__Account__c, new list<Zuora__Subscription__c>{sub});
            } else {
                accountId_subscriptionList.get(sub.Zuora__Account__c).add(sub);
            }
            
            sub.Zuora__SubscriptionEndDate__c = date.today();
            subscriptionList.add(sub);
            
            productCode_earliestStartDate.put(sub.Product_Code__c, null);
            billingAccountIdList.add(sub.Zuora__CustomerAccount__c);
            
            subscriptionIdSet.add(sub.Id);  //START-END UD-2549 4/6/2016 Added by John D - retry mechanism for unable to lock row error
            
            subIdToAccountIdMap.put(sub.Id, sub.Zuora__Account__c); //START-END UD-2549 4/10/2016 Added by J.Sarion - added sub Id to account Id 
        }
        // end - map subscriptions under the same account
        
        retrieveCrossReferrenceData(); //START-END UD-2549 3/30/2016 Added by J.Sarion - moved method 
        
        // start - create related objects
        for (id accountId : accountId_subscriptionList.keySet()) {
            
            // start - create order
            orderIdentifier = accountId;
            
            Order__c orderx = new Order__c();
            orderx.Account__c = accountId;
            orderx.Acquisition_Type__c = ACQUISITION_TYPE;
            orderx.Category__c = CATEGORY;
            orderx.Sub_Category__c =  SUB_CATEGORY;
            orderx.Status__c = STATUS;
            orderx.Order_Type__c = ORDER_TYPE;
            orderx.credit_balance__c = 0;
            orderx.delivery_charge__c = 0;
            orderx.monthly_delivery_charge_for_full_payment__c = 0;
            //orderx.Effective_Date__c = EFFECTIVE_DATE;
            
            orderIdentifier_order.put(orderIdentifier, orderx);
            // end - create order
            
            // start - create case
            caseIdentifier = accountId;
            
            Case casex = new Case();
            casex.RecordTypeId = CASE_RECORD_TYPE_ID;
            casex.AccountId = accountId;
            casex.Category__c = CATEGORY;
            casex.Sub_Category__c = SUB_CATEGORY;
            casex.Subject = SUBJECT;
            casex.Status = STATUS;
            casex.Sub_Status__c = SUB_STATUS;
            casex.Creation_Mode__c = CREATION_MODE;
            casex.Admin_Charges__c = 0;
            //casex.Subscriber__c = sub.Subscriber_Contact__c; 
            
            caseIdentifier_case.put(caseIdentifier, casex);
            caseIdentifier_orderIdentifier.put(caseIdentifier, orderIdentifier);
            // end - create case
            
            // start - create order line item
            for (Zuora__Subscription__c sub : accountId_subscriptionList.get(accountId)) {
                
                orderLineItemIdentifier = orderIdentifier + sub.Id;
                
                Order_Line_Item__c orderLineItemx = new Order_Line_Item__c();
                orderLineItemx.Subscription__c = sub.Id;
                orderLineItemx.Main_Package_Id__c = sub.Main_Package_1__c;
                orderLineItemx.Main_Package_Billing_Type__c = sub.Billing_Type__c;
                orderLineItemx.Main_Package_Type__c = sub.Main_Package_1__r.Package_Type__c;
                orderLineItemx.Delivered_By__c = sub.Delivered_By__c;
                orderLineItemx.Earliest_Stop_Date__c = productCode_earliestStartDate.get(sub.Product_Code__c);
                //START UD-2549 3/29/2016 Added by J.Sarion - Set fields
                orderLineItemx.Stop_Request_Date__c = productCode_earliestStartDate.get(sub.Product_Code__c); 
                orderLineItemx.Subscription_Name__c = sub.Name;
                //END UD-2549 3/29/2016 Added by J.Sarion - Set fields
                //START UD-2549 3/24/2016 Added by J.Sarion 
                if (sub.Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c == 'CreditCard') {
                    orderLineItemx.Terminating_Reason__c = TERMINATION_REASON + 'Credit card';  
                } else if (sub.Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c == 'Paypal') {
                    orderLineItemx.Terminating_Reason__c = TERMINATION_REASON + 'Paypal';   
                }
                //END UD-2549 3/24/2016 Added by J.Sarion 
                orderLineItemx.Amount_To_Refund__c = 0;
                //system.assertequals('asdf' + productCode_earliestStartDate, 'qwer ' + productCode_earliestStartDate.get(sub.Product_Code__c));
                system.debug('>>>>>orderLineItemx ' + orderLineItemx);
                orderLineItemIdentifier_orderLineItem.put(orderLineItemIdentifier, orderLineItemx);
                orderLineItemIdentifier_orderIdentifier.put(orderLineItemIdentifier, orderIdentifier);
                orderLineItemIdentifier_caseIdentifier.put(orderLineItemIdentifier, caseIdentifier);
                subscriptionId_caseIdentifier.put(sub.Id, caseIdentifier);
            }
            // end - create order line item
        }
        // end - create related objects
    }
    
    private void executeRecordCreation() {
        
        savepoint sp = Database.setSavepoint();
        
        try {
            system.debug('>>>>>orderIdentifier_order.values() ' + orderIdentifier_order.values());
            system.debug('>>>>>caseIdentifier_case.values() ' + caseIdentifier_case.values());
            system.debug('>>>>>orderLineItemIdentifier_orderLineItem.values() ' + orderLineItemIdentifier_orderLineItem.values());
            
            insert orderIdentifier_order.values();
            
            populateCaseLookupFields();
            insert caseIdentifier_case.values();
            
            populateOrderLineItemLookupFields();
            
            insert orderLineItemIdentifier_orderLineItem.values();
            system.debug('>>>>>orderLineItemIdentifier_orderLineItem.values() ' + orderLineItemIdentifier_orderLineItem.values());
            prepareCaseSubscriptions();
            
            system.debug('>>>>>caseSubscriptionList ' + caseSubscriptionList);
            system.debug('>>>>>subscriptionList ' + subscriptionList);
            insert caseSubscriptionList;
            update subscriptionList;
                
        } catch (exception e) {
            
            Database.rollback(sp);
            logger.log(e);
            isExecuteCancellation = false;
            
            //START UD-2549 4/6/2016 Added by John D - retry mechanism for unable to lock row error
            if (e.getMessage() != null && e.getMessage().contains(ERR_LOCK_ROW)) {
                System.enqueueJob(new BulkStopOrderCreationQueueable(subscriptionIdSet));
            }
            //END UD-2549 4/6/2016 Added by John D - retry mechanism for unable to lock row error
        }
        
    }
    
    
    private void populateCaseLookupFields() {
        
        for (string identifier : caseIdentifier_case.keySet()) {
            
            Order__c orderx = orderIdentifier_order.get(caseIdentifier_orderIdentifier.get(identifier));
            Case casex = caseIdentifier_case.get(identifier);
            casex.Order__c = orderx.Id;
            casex.Order_Number__c = orderx.Id;
            
            caseIdentifier_case.put(identifier, casex);
        }
    }
    

    private void populateOrderLineItemLookupFields() {
        
        for (string identifier : orderLineItemIdentifier_orderLineItem.keySet()) {
            
            Order__c orderx = orderIdentifier_order.get(orderLineItemIdentifier_orderIdentifier.get(identifier));
            Case casex = caseIdentifier_case.get(orderLineItemIdentifier_caseIdentifier.get(identifier));
            
            Order_Line_Item__c orderLineItemx = orderLineItemIdentifier_orderLineItem.get(identifier);
            orderLineItemx.Order__c = orderx.Id;
            orderLineItemx.Case__c = casex.Id;
            
            orderLineItemIdentifier_orderLineItem.put(identifier, orderLineItemx);
            subscriptionId_caseId.put(orderLineItemx.Subscription__c, casex.Id);
        }
    }
    
    
    private void prepareCaseSubscriptions() {
        
        string identifier;
        for (id subId : subscriptionId_caseIdentifier.keySet()) {
            
            identifier = subscriptionId_caseIdentifier.get(subId);
            Case casex = caseIdentifier_case.get(identifier);
            
            Case_Subscription__c cs = new Case_Subscription__c();
            cs.Case__c = casex.Id;
            cs.Account__c = subIdToAccountIdMap.get(subId); //START-END UD-2549 4/10/2016 Added by J.Sarion - get account id from map
            cs.Subscription__c = subId;
            
            caseSubscriptionList.add(cs);
            
            subscriptionId_caseId.put(subId, casex.Id);
        }
    }
}