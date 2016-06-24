/**
* Class Name: <InvoicePaymentQueueableClass>
* @authors: <FrancisBenzon>
* Date: <4/10/15>
* Requirement/Project Name: <SPH>
* @description: 
    * Generate Invoice for Fully Prepaid Subscriptions.
    * Create Payment for the Invoice.
* History: 4/10/15 D-2618 
    *this is the Queueable class so that usage can be tied to Invoice. 
    *Billrun AddedBy FrancisBenzon : reconstructed class, made a queueable apex class for Invoice and Payment Creation.
    *Apex Class: InvoicePaymentQueueableClass
*Reason: Usage creation should be prior to Invoice creation, but upon encountering dml in usage creation, callout in Invoice cannot proceed.
* History: 08/Oct/15 UD-2854 RReyes/Wenjun : reconstructure the class
*/

public class InvoicePaymentQueueableClass implements queueable, Database.AllowsCallouts {
    
    public Set<Id> setSubIDs {get;set;}
    Map<String, Id> mapBAZuoraIdToAccountId = new Map<String, Id>();
    Map<String, Decimal> mapInvBAToTotalOtherCBAmt = new Map<String, Decimal>();
    Map<String, Decimal> mapInvBAToTotalCBAmt = new Map<String, Decimal>();
    Map<String, Decimal> mapInvBAToRemainingAmt = new Map<String, Decimal>();
    Map<String, Zuora__CustomerAccount__c> mapBAZuoraIdToBA = new Map<String, Zuora__CustomerAccount__c> ();
    Map<String, Id> mapBAZuoraIdToOrderID = new Map<String, Id>();
    Map<Id, Decimal> mapOrderIdToCashAmount = new Map<Id, Decimal>();
    Map<Id, Decimal> mapOrderIdToCheckAmount = new Map<Id, Decimal>(); //START-END D-3831 10/29/2015 Added by J.Sarion - set var name from mapOrderIdToCashAmount to mapOrderIdToCheckAmount
    //Logger logger = new Logger(InvoicePaymentQueueableClass.class.getName());
  // Start D-3809 27Oct15 JohnD
  map<string, string> billingAccountZuoraId_billingAccountId = new map<string, string>();  
  map<string, string> billingAccountZuoraId_billingAccountNumber = new map<string, string>();
  // End D-3809 27Oct15 JohnD
    //START UD-3002 12/10/2015 Added by J.Sarion - Record Type Id for Direct Corporate
    public Id ACCOUNT_DIRECTCORPORATE = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRCORP);
    //END UD-3002 12/10/2015 Added by J.Sarion - Record Type Id for Direct Corporate
    static map<string, decimal> invoiceZuoraId_adjustedBalance = new map<string, decimal>();    // Start/End 23May16 JohnD
    
    public static Logger logger = new Logger(InvoicePaymentQueueableClass.class.getName()); //START/END 04 October 2015 UD-2504 Kevin Evasco - Initialize Invoice Previous Balance
    public InvoicePaymentQueueableClass(Set<Id> subIDs) {
        this.setSubIDs = subIDs;
    }
      
    public void execute(QueueableContext context){
        List<Zuora.zObject> zobjs;      
        List<Map<String, Object>> invoiceMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> updateInvoiceMapList = new List<Map<String, Object>>();       
        Set<String> setNewInvoiceIds = new Set<String>();
        Set<String> setInvIdsToUpd = new Set<String>();        
        Set<Id> setSubsToInvoice = new Set<Id>();    
        ZuoraCallOut zCallOut;
    // Start D-3809 27Oct15 JohnD
    list<map<string, object>> failedInvoiceMapList = new list<map<string, object>>();  
    list<map<string, object>> failedUpdateInvoiceMapList = new list<map<string, object>>();
    string billingAccountZuoraId;
    string billingAccountId;
    string billingAccountNumber;
    string invoiceZuoraId;
    string logMessage;
    integer index;
    // End D-3809 27Oct15 JohnD
        //START UD-3002 12/10/2015 Added by J.Sarion - Set of Ids for Direct Corporate
        Set<Id> directCorpSubIdSet = new Set<Id>();
        //END UD-3002 12/10/2015 Added by J.Sarion - Set of Ids for Direct Corporate
        
        //START UD-3002 12/10/2015 Added by J.Sarion - added account record type Id
        List<Zuora__Subscription__c> lstSubs = [SELECT Id, Name, Zuora__Account__c, Order_Number_1__c, Zuora__Account__r.RecordTypeId, Order_Line_Item_Number_1__c, Zuora__SubscriptionStartDate__c, Term_Length__c,
                   Subscription_Type_1__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Order_Number_1__r.DTL_Date__c,
                   Order_Number_1__r.Amount_Paid__c, Order_Number_1__r.Full_Prepaid_Inc_Del_Charge__c, Order_Number_1__r.Check_Amount__c, Order_Number_1__r.Payment_Mode__c 
                   FROM Zuora__Subscription__c WHERE Id IN : setSubIDs ORDER BY Order_Number_1__r.DTL_Date__c ASC]; 
        //END UD-3002 12/10/2015 Added by J.Sarion - added account record type Id
        system.debug('>>>>>>> whaaaaaaaaaaaaaaaaaa' + setSubIDs);
        for(Zuora__Subscription__c sub :lstSubs)
        {
            mapBAZuoraIdToAccountId.put(sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, sub.Zuora__Account__c);
            
            if (sub.Order_Number_1__c != null) 
            {
                //START UD-3002 12/10/2015 Added by J.Sarion - Check account if not Direct Corporate
                if(sub.Zuora__Account__r.RecordTypeId != ACCOUNT_DIRECTCORPORATE) {
                    setSubsToInvoice.add(sub.Id);
                }
                else {
                    directCorpSubIdSet.add(sub.Id);
                }
                //END UD-3002 12/10/2015 Added by J.Sarion - Check account if not Direct Corporate
                mapBAZuoraIdToOrderID.put(sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, sub.Order_Number_1__c);
            }
          
            if (sub.Order_Number_1__r.Amount_Paid__c != null && sub.Order_Number_1__r.Payment_Mode__c == GlobalVariableClass.CASH) 
                mapOrderIdToCashAmount.put(sub.Order_Number_1__c, sub.Order_Number_1__r.Amount_Paid__c);

            if (sub.Order_Number_1__r.Check_Amount__c != null && sub.Order_Number_1__r.Payment_Mode__c == GlobalVariableClass.CHEQUE) 
                mapOrderIdToCheckAmount.put(sub.Order_Number_1__c, sub.Order_Number_1__r.Check_Amount__c); //START-END D-3831 10/29/2015 Added by J.Sarion - set var name from mapOrderIdToCashAmount to mapOrderIdToCheckAmount
        }
        System.debug('>>>rr 1. setSubsToInvoice ' + setSubsToInvoice); //UD2854
        if (!setSubsToInvoice.isEmpty()) {
            invoiceMapList = generateInvoice(setSubsToInvoice);          
            failedInvoiceMapList = invoiceMapList; // Start/End D-3809 27Oct15 JohnD - all invoices will be added first. successful invoice will be removed from this list
        }
        
        //START UD-3002 12/11/2015 Added by J.Sarion - Create Bill Run record in Zuora for Accounts with large number of Subscriptions e.g. Direct Corporate
        if(!directCorpSubIdSet.isEmpty()) {
            InvoiceProcessForStopSubscription inv = new InvoiceProcessForStopSubscription();
            InvoiceProcessForStopSubscription.isStart = true;
            InvoiceProcessForStopSubscription.createBillRun(directCorpSubIdSet);
        }
        //END UD-3002 12/11/2015 Added by J.Sarion - Create Bill Run record in Zuora for Accounts with large number of Subscriptions e.g. Direct Corporate
        system.debug(':::InvoiceMapLst ' + invoiceMapList);
        if (!invoiceMapList.isEmpty()) {
            try
            {
                index = 0;  // Start/End D-3809 28Oct15 JohnD
                zCallOut = new ZuoraCallOut();
                List<Map<String,String>> results = zCallOut.generateInvoiceList(invoiceMapList);
                system.debug('John >>>>> ' + results);
                for (Map<String,String> resultMap :results) {
                    if (resultMap.get('Status') == 'Success') {
                        setNewInvoiceIds.add(resultMap.get('Id'));
                        failedInvoiceMapList.remove(index);  // Start/End D-3809 27Oct15 JohnD
                    } else {
                        system.debug(':::results ' + results);
                        System.debug( ':::SOAP Request = ' + Zuora.zApi.currentLogger.request );
                        System.debug( ':::SOAP Response = ' + Zuora.zApi.currentLogger.response );
                        System.debug( ':::logger = ' + Zuora.zApi.currentLogger.toString() );
                    }
                    index++; // Start/End D-3809 27Oct15 JohnD
                }
        
        // Start D-3809 27Oct15 JohnD - retry 3x
       
        if (!failedInvoiceMapList.isEmpty()) {
          
          integer attempt = 1;
          list<map<string, object>> invoiceMapListTmp = new list<map<string, object>>();  

          while (attempt < 4) {
            
            if (failedInvoiceMapList.isEmpty()) break;
            
            index = 0;
            invoiceMapListTmp = failedInvoiceMapList;
            list<map<string, string>> responseList = new list<map<string, string>>();
            if (!Test.isRunningTest()) {
              responseList = zCallOut.generateInvoiceList(failedInvoiceMapList);
            } else {
              map<string, string> fakeResponse = new map<string, string>();
              fakeResponse.put('Status', 'Failed');
              fakeResponse.put('Message', 'for code coverage');
              responseList.add(fakeResponse);
            }
            
            for (map<string, string> resultMap : responseList) {
              if (resultMap.get('Status') == 'Success') {
                setNewInvoiceIds.add(resultMap.get('Id'));
                failedInvoiceMapList.remove(index);  
              } else {
                if (attempt == 3) {
                  
                  map<string, object> requestField_requestValue = invoiceMapListTmp[index];
                  billingAccountZuoraId = (string)requestField_requestValue.get('AccountId');
                  billingAccountId = billingAccountZuoraId_billingAccountId.get(billingAccountZuoraId);
                  billingAccountNumber = billingAccountZuoraId_billingAccountNumber.get(billingAccountZuoraId);
                  logMessage = '[Invoice Creation - ' + billingAccountNumber + '] ' + (string)resultMap.get('Message');
                  logger.log(false, logMessage, billingAccountId);
                }
              }
              index++;
            }
            attempt++;
          }
        }
        // End D-3809 27Oct15 JohnD - retry 3x
            }
            catch (Exception e)
            {
        // Start D-3809 27Oct15 JohnD - improved logging logic
        for (map<string, object> requestField_requestValue : failedInvoiceMapList) {
          
          billingAccountZuoraId = (string)requestField_requestValue.get('AccountId');
          billingAccountId = billingAccountZuoraId_billingAccountId.get(billingAccountZuoraId);
          billingAccountNumber = billingAccountZuoraId_billingAccountNumber.get(billingAccountZuoraId);
          logMessage = '[Invoice Creation - ' + billingAccountNumber + '] ' + e.getMessage();
          logger.log(false, logMessage, billingAccountId);
        }
        // End D-3809 27Oct15 JohnD - improved logging logic
            }
        }
        if (!setNewInvoiceIds.isEmpty()) {
            for (String invoiceId :setNewInvoiceIds) {
                Map<String, Object> updateInvoiceMap = new Map<String, Object>();
                updateInvoiceMap.put('Id', invoiceId);
                updateInvoiceMap.put('Status', 'Posted');
                updateInvoiceMapList.add(updateInvoiceMap);
            }
        }
        if (!updateInvoiceMapList.isEmpty()) {
            try
            {
        index = 0;  // Start/End D-3809 27Oct15 JohnD
        failedUpdateInvoiceMapList = updateInvoiceMapList;  // Start/End D-3809 27Oct15 JohnD - all invoices will be added first. successful invoice will be removed from this list
        List<Map<String,String>> results = zCallOut.updateZObjects(updateInvoiceMapList, 'Invoice');
                for (Map<String,String> resultMap :results) {                       
                    if (resultMap.get('Status') == 'Success') {
                        setInvIdsToUpd.add(resultMap.get('Id'));
            failedUpdateInvoiceMapList.remove(index);  // Start/End D-3809 27Oct15 JohnD
                    }
                    }
                
        
        // Start D-3809 27Oct15 JohnD - retry 3x
        if (!failedUpdateInvoiceMapList.isEmpty()) {

          integer attempt = 1;
          list<map<string, object>> invoiceMapListTmp = new list<map<string, object>>();  

          while (attempt < 4) {
            
            if (failedUpdateInvoiceMapList.isEmpty()) break;
            
            index = 0;
            invoiceMapListTmp = failedUpdateInvoiceMapList;
            list<map<string, string>> responseList = new list<map<string, string>>();
            if (!Test.isRunningTest()) {
              responseList = zCallOut.updateZObjects(failedUpdateInvoiceMapList, 'Invoice');
            } else {
              map<string, string> fakeResponse = new map<string, string>();
              fakeResponse.put('Status', 'Failed');
              fakeResponse.put('Message', 'for code coverage');
              responseList.add(fakeResponse);
            }
            
            for (map<string, string> resultMap : responseList) {
              if (resultMap.get('Status') == 'Success') {
                setInvIdsToUpd.add(resultMap.get('Id'));
                failedUpdateInvoiceMapList.remove(index);  
              } else {
                if (attempt == 3) {
                  
                  map<string, object> requestField_requestValue = invoiceMapListTmp[index];
                  invoiceZuoraId = (string)requestField_requestValue.get('Id');
                  logMessage = '[Unposted Invoice] ' + (string)resultMap.get('Message');
                  logger.log(false, logMessage, invoiceZuoraId);
                }
              }
              index++;
            }
            attempt++;
          }        
        }
        // End D-3809 27Oct15 JohnD - retry 3x
        
                if (!setInvIdsToUpd.isEmpty()) {
                    zobjs = zCallOut.bulkQueryInvoices(setInvIdsToUpd);
                }       
            }
            catch (Exception e)
            {
        // Start D-3809 27Oct15 JohnD - improved logging logic
        for (map<string, object> requestField_requestValue : failedUpdateInvoiceMapList) {
          
          invoiceZuoraId = (string)requestField_requestValue.get('Id');
          logMessage = '[Unposted Invoice] ' + (string)e.getMessage();
          logger.log(false, logMessage, invoiceZuoraId);
        }
        // End D-3809 27Oct15 JohnD - improved logging logic
            }
        }
        if (zobjs != null && !zobjs.isEmpty()) {
            //Start/End UD-3890 09-Apr-2016 Added by S.Puli - Remove updateZInvoice(zobjs); //START/END 05 October 2015 Kevin Evasco UD-2504 - Call Update ZInvoice
            //Transfer Credit Balance from other Billing Accounts if any
            transferCreditBalances(zobjs, zCallOut); 
            
            updateInvPrevBalance(zobjs, zCallOut);//Start/End UD-3890 09-Apr-2016 Added by S.Puli - Update Invoice Previous balance
            
            //Apply Credit Balance to Invoice if any
            applyCreditBalance(zobjs, zCallOut);
            
            //Create Payment Records for Outstanding Amounts if any
            processPayment(zobjs, zCallOut);    
        }
        
        logger.save();  
    }

    public List<Map<String, Object>> generateInvoice(Set<Id> subIdSet) {

        //START 02/18/2015 JTeves - Code Optimization - Removal of NULL value in Query Filter Sets
        if(subIdSet.contains(null)) {
            subIdSet.remove(null);
        }
        //END 02/18/2015 JTeves - Code Optimization
        
        // Start D-2952 18May15 JohnD - checked if all subscriptions were created
        Map<Id, Integer> orderId_totalNumberOfExpectedSubscriptions = new Map<Id, Integer>();
        Map<Id, Integer> orderId_totalNumberOfSuscriptions = new Map<Id, Integer>();
        Set<Id> setOrderIDsToProcess = new set<Id>();
        List<zqu__Quote__c> quoteList; // Start/End UD-1324 26May15 JohnD
        Integer oliCounter = 0;
        
        // Start D-3111 (HotFix) 13Jun15 JohnD - added logic for no invoice issue
        Set<Id> tmpOrderIdSet = new Set<Id>();
        
        for (Zuora__Subscription__c sub : [select Order_Number_1__c from Zuora__Subscription__c where Id in :subIdSet]) {   
            tmpOrderIdSet.add(sub.Order_Number_1__c);
        }        
        // End D-3111 (HotFix) 13Jun15 JohnD - added logic for no invoice issue
        
        for (AggregateResult ar : [select Order_Number_1__c, count(Id) total from Zuora__Subscription__c 
                where order_number_1__c in :tmpOrderIdSet group by Order_Number_1__c]) {    // Start/End D-3111 (HotFix) 13Jun15 JohnD - changed filter criteria
            
            orderId_totalNumberOfSuscriptions.put((Id)ar.get('Order_Number_1__c'), (Integer)ar.get('total'));
        }

        // Start UD-1324 26May15 JohnD - revised source data
        for (Order_Line_Item__c oli : [select Order__c, (select Id from Quotes__r) from Order_Line_Item__c 
                where Order__c in :orderId_totalNumberOfSuscriptions.keySet()]) {
            
            //START UD-3660 29Mar16 FrancisBenzon : reinitiate counter
            oliCounter = 0;
            //END UD-3660 29Mar16 FrancisBenzon : reinitiate counter
            if (orderId_totalNumberOfExpectedSubscriptions.get(oli.Order__c) != null) {
                
                oliCounter = orderId_totalNumberOfExpectedSubscriptions.get(oli.Order__c);
            }
            
            quoteList = oli.Quotes__r;
            
            if (quoteList != null && !quoteList.isEmpty()) {
                oliCounter += quoteList.size();
            }
            
            orderId_totalNumberOfExpectedSubscriptions.put(oli.Order__c, oliCounter);
        }

        for (Id orderId : orderId_totalNumberOfExpectedSubscriptions.keySet()) {
            if (orderId_totalNumberOfExpectedSubscriptions.get(orderId) == orderId_totalNumberOfSuscriptions.get(orderId)) {
                setOrderIDsToProcess.add(orderId);
            }   
        }
        // End D-2952 18May15 JohnD - checked if all subscriptions were created
        
        List<Map<String, Object>> invoiceMapList = new List<Map<String, Object>>();
        Map<String, Object> invoiceMap;
        Set<Id> setBAProcessed = new Set<Id>();

        //START UD-3119 10/19/15 AddedBy FrancisBenzon : loop in the latest sub start date first to set latest inv target date for multiple start
        List<Zuora__Subscription__c> subList = [SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, 
                        Billing_Type__c, Order_Number_1__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, 
                        Zuora__CustomerAccount__r.Name FROM Zuora__Subscription__c 
                        WHERE Order_Number_1__c in :setOrderIDsToProcess AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION Order By Zuora__SubscriptionStartDate__c DESC];  // Start/End D-3809 27Oct15 JohnD - added Zuora__AccountNumber__c, Zuora__CustomerAccount__r.Name
        //END UD-3119 10/19/15 AddedBy FrancisBenzon : loop in the latest sub start date first to set latest inv target date for multiple start
        
        for (Zuora__Subscription__c sub : subList) {
            if (!setBAProcessed.contains(sub.Zuora__CustomerAccount__c)) {
                invoiceMap = new Map<String, Object>();
                Date serviceActivationDate;
                if(sub.Zuora__SubscriptionStartDate__c != null)
                        serviceActivationDate = sub.Zuora__SubscriptionStartDate__c.toStartOfMonth().addMonths(1);                                                       
        
        // Start D-3809 27Oct15 JohnD - added logic for error retries and logging
        string billingAccountZuoraId = sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
                if (sub.Zuora__CustomerAccount__r.Name.contains('ForNegativeTesting')) {
                  billingAccountZuoraId += 'negative';
                }
        billingAccountZuoraId_billingAccountId.put(billingAccountZuoraId, sub.Zuora__CustomerAccount__c);  
        billingAccountZuoraId_billingAccountNumber.put(billingAccountZuoraId, sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c);
                invoiceMap.put('AccountId', billingAccountZuoraId);
                // End D-3809 27Oct15 JohnD - added logic for error retries and logging
                invoiceMap.put('InvoiceDate', Zuora.Zutil.getZuoraDate(Date.today()));
                invoiceMap.put('TargetDate', Zuora.Zutil.getZuoraDate(serviceActivationDate));
                invoiceMapList.add(invoiceMap);
            }
            
            setBAProcessed.add(sub.Zuora__CustomerAccount__c);
        }
        system.debug('<>invoiceMapList : ' + invoiceMapList);
        return invoiceMapList;
    }
 
    public void transferCreditBalances(list<Zuora.zObject> zobjs, ZuoraCallOut zCallOut) {     
        Set<String> setBAIdsForInv = new Set<String>(); //These are the BAs where the generated Invoices belongs to
        Set<Id> setSFAccountIDs = new Set<Id>(); 
        List<Zuora__CustomerAccount__c> lstBAs;
        Map<Id, List<Zuora__CustomerAccount__c>> mapAccIdToAllBAs = new Map<Id, List<Zuora__CustomerAccount__c>>();
        List<Map<String, Object>> listRefundMap = new List<Map<String, Object>>();
        List<Map<String, Object>> listPaymentMap = new List<Map<String, Object>>();
                
        for(Zuora.zObject zObj: zobjs)
        {
            String targetBAId = (String)zObj.getValue('AccountId');
            if (targetBAId != null) {
                setBAIdsForInv.add(targetBAId);
                setSFAccountIDs.add(mapBAZuoraIdToAccountId.get(targetBAId));
                system.debug(targetBAId+'<-->'+mapBAZuoraIdToAccountId.get(targetBAId));
            }
        }
        system.debug(setSFAccountIDs + '<->'+mapBAZuoraIdToAccountId);
        
        if(!setSFAccountIDs.isEmpty()){
             //START 04 October 2015 UD-2504 Kevin Evasco - Added Zuora__Balance__c for Invoice Previous Balance initialization
            lstBAs = [SELECT Zuora__AccountNumber__c, Zuora__External_Id__c, Zuora__Credit_Balance__c, Zuora__Account__c, Other_PaymentMethod__c,
                      Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c, 
                      Zuora__Balance__c, Payment_Mode__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN: setSFAccountIDs];
            //END 04 October 2015 UD-2504 Kevin Evasco - Added Zuora__Balance__c for Invoice Previous Balance initialization //START-END UD-2498 by K.Tan added needed field
        }
        system.debug('>>>> ' + lstBAs);
        
        if(lstBAs != null && !lstBAs.isEmpty()){
            for(Zuora__CustomerAccount__c billingAccount : lstBAs)
            {
                if(!mapAccIdToAllBAs.containsKey(billingAccount.Zuora__Account__c))
                {
                    mapAccIdToAllBAs.put(billingAccount.Zuora__Account__c, new List<Zuora__CustomerAccount__c>());
                }
                mapAccIdToAllBAs.get(billingAccount.Zuora__Account__c).add(billingAccount);
                mapBAZuoraIdToBA.put(billingAccount.Zuora__External_Id__c, billingAccount);
            }
        }
        
        //Transfer Credit Balance Step 1: Perform Refund Transactions to withdraw Credit Balance from Other Billing Accounts
        for(String targetBAId : setBAIdsForInv)
        {
            ID accountID = mapBAZuoraIdToAccountId.get(targetBAId);
            List<Zuora__CustomerAccount__c> lstSameAcctBAs = mapAccIdToAllBAs.get(accountID);
            Decimal totalBalanceFromOtherBillingAccounts = 0.0;
            Decimal totalCreditBalance = 0.0;
            
            if(lstSameAcctBAs != null && !lstSameAcctBAs.isEmpty())
            {
                for (Zuora__CustomerAccount__c billAcct:lstSameAcctBAs) {
                    if (targetBAId != billAcct.Zuora__External_Id__c && billAcct.Zuora__Credit_Balance__c > 0)
                    {
                        Map<String,Object> refundMap = new Map<String, Object>();
                        refundMap.put('AccountId', billAcct.Zuora__External_Id__c);                 
                        refundMap.put('Amount', billAcct.Zuora__Credit_Balance__c); 
                        refundMap.put('SourceType', 'CreditBalance'); 
                        // START UD-2498 10/21/2015  by Dags K. Tan correct the refund type for report purposes
                        //START UD-3676 01/20/16 RReyes - all refunds due to CB transfer should be external
                        /*if (billAcct.Payment_Mode__c == 'CreditCard' || billAcct.Payment_Mode__c == 'Paypal') {
                            refundMap.put('Type', 'Electronic' );
                            refundMap.put('PaymentMethodId', billAcct.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
                        }                         
                        else {
                        */                          
                            refundMap.put('Type', 'External' );  
                            refundMap.put('MethodType', 'Other' );
                        //}
                        //END UD-3676 01/20/16 RReyes - all refunds due to CB transfer should be external
                        // END UD-2498 10/21/2015  by Dags  K. Tan correct the refund type for report purposes                     
                        listRefundMap.add(refundMap);
                        totalBalanceFromOtherBillingAccounts += billAcct.Zuora__Credit_Balance__c;
                    } 
                    totalCreditBalance += billAcct.Zuora__Credit_Balance__c;
                }
            }
            mapInvBAToTotalOtherCBAmt.put(targetBAId, totalBalanceFromOtherBillingAccounts);
            mapInvBAToTotalCBAmt.put(targetBAId, totalCreditBalance);
        }
        
        //Perform Refund Callouts
        if (!listRefundMap.isEmpty()) {
            try
            {
                List<Map<String,String>> results = zCallOut.loadZObjects(listRefundMap, 'Refund');
        
                for (Map<String,String> resultMap :results) {           
                    if (resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            catch (Exception e)
            {
                logger.log(e);
            }
        }
        
        //Transfer Credit Balance Step 2: Perform Payment Transaction to deposit the Refunded Credit Balance to Target BA
        for(String targetBAId : setBAIdsForInv)
        {
            Decimal totalBalanceFromOtherBillingAccounts = mapInvBAToTotalOtherCBAmt.get(targetBAId);
            
            if(totalBalanceFromOtherBillingAccounts != null && totalBalanceFromOtherBillingAccounts > 0)
            {
                Map<String, Object> paymentMap = new Map<String, Object>();
                paymentMap.put('AccountId', targetBAId);
                paymentMap.put('EffectiveDate', Zuora.Zutil.getZuoraDate(Date.Today()));    
                paymentMap.put('Amount', totalBalanceFromOtherBillingAccounts);
                paymentMap.put('AppliedCreditBalanceAmount', totalBalanceFromOtherBillingAccounts);
                paymentMap.put('Status', 'Processed');  
                paymentMap.put('Type', 'External');
                paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other'));
                listPaymentMap.add(paymentMap);
            }
        }
        
        //Perform Payment Callouts
        if (!listPaymentMap.isEmpty()) {
            try
            {
                List<Map<String,String>> results = zCallOut.loadZObjects(listPaymentMap, 'Payment');
        
                for (Map<String,String> resultMap :results) {           
                    if (resultMap.get('Status') != 'Success') {
                        logger.log(false, '[transferCreditBalances] Payment Creation Error: ' + resultMap.get('Message') + ' - PaymentMap: ' + listPaymentMap); //START/END D-4235 01/07/15 RReyes - added paymentMap on logs
                    }
                }
            }
            catch (Exception e)
            {
                logger.log(e);
            }
        }
    }
    
    public void applyCreditBalance(List<Zuora.zObject> zobjs, ZuoraCallOut zCallOut) 
    {
        List<Map<String, Object>> listCBMap = new List<Map<String, Object>>();
                
        for(Zuora.zObject zObj: zobjs)
        {
            String targetBAId = (String)zObj.getValue('AccountId');
            Decimal totalCreditBalance = mapInvBAToTotalCBAmt.get(targetBAId);
            Decimal invoiceAmt = (Decimal) zObj.getValue('Balance');
            Decimal creditAmtToApply = 0.0;
            Decimal remainingAmt = invoiceAmt; //Outstanding amount requires further payments
            decimal newCreditBalance = 0.0; // Start/End PD-0266 21May16 JohnD
            
            if(totalCreditBalance != null && totalCreditBalance > 0 && invoiceAmt != null && invoiceAmt > 0)
            {
                creditAmtToApply = (totalCreditBalance > invoiceAmt) ? invoiceAmt : totalCreditBalance;
                remainingAmt = (totalCreditBalance > invoiceAmt) ? 0 : invoiceAmt - totalCreditBalance;
            }
            system.debug('------------creditAmtToApply : '+creditAmtToApply );
            system.debug('------------totalCreditBalance : '+totalCreditBalance );
            if(creditAmtToApply > 0)
            {
                Map<String, Object> creditBalanceMap = new Map<String, Object>();
                creditBalanceMap.put('Amount', creditAmtToApply); 
                creditBalanceMap.put('Type', 'Decrease');
                creditBalanceMap.put('SourceTransactionId', zObj.getValue('Id'));
                listCBMap.add(creditBalanceMap);
                // Start PD-0266 23May16 JohnD - added logic for credit balance deduction
                newCreditBalance = totalCreditBalance - creditAmtToApply;
                mapInvBAToTotalCBAmt.put(targetBAId, newCreditBalance);
                system.debug('------------newCreditBalance: '+newCreditBalance);
                // End PD-0266 23May16 JohnD - added logic for credit balance deduction
            }
            
            invoiceZuoraId_adjustedBalance.put((string)zObj.getValue('Id'), remainingAmt);  // Start/End PD-0266 22May16 JohnD
            //mapInvBAToRemainingAmt.put(targetBAId, remainingAmt); // Start/End PD-0266 22May16 JohnD - commented out
        }                     

        //Perform Apply Credit Balance Callout
        if (!listCBMap.isEmpty()) {
            try
            {
                List<Map<String,String>> results = zCallOut.loadZObjects(listCBMap, 'CreditBalanceAdjustment');
        
                for (Map<String,String> resultMap :results) {           
                    if (resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            catch (Exception e)
            {
                logger.log(e);
            }
        }
    }
   
    public void processPayment (List<Zuora.zObject> zobjs, ZuoraCallOut zCallOut) {
        Set<Id> setENetsAcctID = new Set<Id>();
        List<BT_CO_STPPRS_StopPressSubscription__c> lstStopPress;
        Map<Id, String> mapAcctIdToPayNum = new Map<Id, String>();
        List<Map<String, Object>> lstPaymentMap = new List<Map<String, Object>>();
        //START rom 10/12
        Set<Id> baIds = new Set<Id>();
        List<Zuora__CustomerAccount__c> lstBillAcc = new List<Zuora__CustomerAccount__c>();
        Map<String, String> mapBAToPayMet = new Map<String, String>();
        Set<String> setBAExId = new Set<String>();
        List<Zuora.zObject> zobjsPayMet = new List<Zuora.zObject>();
        final string BA_CREATION_MODE_EXISTING = 'Use existing Billing Account';    // Start/End PD-0194 18May16 JohnD
        //END rom 10/12
        
        for(Zuora.zObject zObj: zobjs)
        {
            String targetBAId = (String)zObj.getValue('AccountId');
            Zuora__CustomerAccount__c billingAcct = mapBAZuoraIdToBA.get(targetBAId);
            
            system.debug(billingAcct+'=='+targetBAId+'=='+mapBAZuoraIdToBA);
            if(billingAcct != null && billingAcct .Zuora__Account__c != null && billingAcct .Other_PaymentMethod__c == 'eNets')
                setENetsAcctID.add(billingAcct .Zuora__Account__c);
        }
        
        if(!setENetsAcctID.isEmpty()){
            lstStopPress = [SELECT Id, Payment_Number__c, Order__r.Account__c FROM BT_CO_STPPRS_StopPressSubscription__c WHERE Order__r.Account__c IN: setENetsAcctID];
        }
        
        if(lstStopPress != null && !lstStopPress.isEmpty()){
            for(BT_CO_STPPRS_StopPressSubscription__c spl: lstStopPress){
                mapAcctIdToPayNum.put(spl.Order__r.Account__c, spl.Payment_Number__c);
            }
        }
        
        //start rom 10/12
        for(Zuora__CustomerAccount__c billAcc: mapBAZuoraIdToBA.values()){
            baIds.add(billAcc.Id);
        }
        //START D-4591 4-19-2016 Added by Jason A.
        if(baIds.size() > 0){
            lstBillAcc = [SELECT Id, Zuora__External_Id__c, Zuora__DefaultPaymentMethod__c,(SELECT id, Order_Number_1__r.Payment_Method_ID__c, Order_Number_1__r.Billing_Account_Creation_Mode__c 
                    From Zuora__Subscriptions__r order by createddate desc LIMIT 1)
                          FROM Zuora__CustomerAccount__c WHERE Id IN:baIds];
        }
        //END D-4591 4-19-2016 Added by Jason A.
        for(Zuora__CustomerAccount__c ba : lstBillAcc){
        //START D-3966 12/02/15 RReyes - removed condition if null and is blank
            if(ba.Zuora__DefaultPaymentMethod__c != GlobalVariableClass.CASH
            && ba.Zuora__DefaultPaymentMethod__c != GlobalVariableClass.CHEQUE && ba.Zuora__DefaultPaymentMethod__c != GlobalVariableClass.OTHER){
               
               // Start PD-0194 18May16 JohnD - commented out 
                /*
                if(!setBAExId.contains(ba.Zuora__External_Id__c)){
                    setBAExId.add(ba.Zuora__External_Id__c);
                }
                */
                // End PD-0194 18May16 JohnD - commented out
                //START D-4591 4-19-2016 Added by Jason A.
                for(Zuora__Subscription__c subsMap : ba.Zuora__Subscriptions__r) {
                    // Start PD-0194 18May16 JohnD
                    if (subsMap.Order_Number_1__r.Billing_Account_Creation_Mode__c == BA_CREATION_MODE_EXISTING) {
                        setBAExId.add(ba.Zuora__External_Id__c);
                    } else {
                        mapBAToPayMet.put(ba.Zuora__External_Id__c, subsMap.Order_Number_1__r.Payment_Method_ID__c);
                    }
                    // End PD-0194 18May16 JohnD
                }
                //END D-4591 4-19-2016 Added by Jason A.
            }
        //END D-3966 12/02/15 RReyes - removed condition if null and is blank
        }
        
        //START D-4591 4-19-2016 Removed by Jason A.
        /*
        if(setBAExId.size() > 0){
            zobjsPayMet = zCallOut.bulkQueryPayMet(setBAExId);
        }
        if(zobjsPayMet.size() > 0){
            for(Zuora.zObject zo: zobjsPayMet){
                String baId = (String)zo.getValue('Id');
                if(!mapBAToPayMet.containsKey(baId)){
                    mapBAToPayMet.put(baId,(String)zo.getValue('DefaultPaymentMethodId'));
                    system.debug('John>>>>y ' + (String)zo.getValue('DefaultPaymentMethodId'));
                }
            }
        }
        */
        // Start PD-0194 18May16 JohnD
        if (!setBAExId.isEmpty()) {

            for (Zuora__CustomerAccount__c billingAccount : [select Zuora__External_Id__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c 
                    from Zuora__CustomerAccount__c where Zuora__External_Id__c in :setBAExId]) {
                
                mapBAToPayMet.put(billingAccount.Zuora__External_Id__c, billingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);     
            }           
        }
        // End PD-0194 18May16 JohnD
        
        //START D-4591 4-19-2016 Removed by Jason A.
        //end rom 10/12
        
        for(Zuora.zObject zObj: zobjs)
        {
            String targetBAId = (String)zObj.getValue('AccountId');
            //Decimal remainingAmt = mapInvBAToRemainingAmt.get(targetBAId);    // Start/End PD-0266 23May16 JohnD - commented out
            Decimal remainingAmt = invoiceZuoraId_adjustedBalance.get((String)zObj.getValue('Id')); // Start/End PD-0266 23May16 JohnD
            Zuora__CustomerAccount__c billingAcct = mapBAZuoraIdToBA.get(targetBAId);
            Id orderId = mapBAZuoraIdToOrderID.get(targetBAId);
            if(targetBAId != null && remainingAmt != null && billingAcct != null && orderId != null && remainingAmt >= 0) //start/end rom 10/13 //START-END D-3601 10/29/2015 Added by J.Sarion - create payment for non-negative reamaining amount
            {
                Map<String, Object> paymentMap = new Map<String, Object>();
                
                if(billingAcct.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.CASH) {
                    paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Cash'));
                    paymentMap.put('Amount', mapOrderIdToCashAmount.get(orderId));
                    paymentMap.put('AppliedCreditBalanceAmount', mapOrderIdToCashAmount.get(orderId) - remainingAmt);
                    paymentMap.put('Type', 'External');
                } 
                else if (billingAcct.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.CHEQUE) {
                    paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Check'));
                    paymentMap.put('Amount', mapOrderIdToCheckAmount.get(orderId));
                    paymentMap.put('AppliedCreditBalanceAmount', mapOrderIdToCheckAmount.get(orderId) - remainingAmt);
                    paymentMap.put('Type', 'External'); 
                }
                else if (billingAcct.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.OTHER && remainingAmt > 0) { // Start/End PD-0266 23May16 JohnD - added " && remainingAmt > 0" 
                    paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other'));
                    paymentMap.put('Amount', remainingAmt);                 
                    paymentMap.put('Type', 'External');

                    if(billingAcct.Other_PaymentMethod__c == 'eNets'){
                        if(billingAcct.Zuora__Account__c != null && mapAcctIdToPayNum.containsKey(billingAcct.Zuora__Account__c))
                            paymentMap.put('Comment', 'eNets Payment Number: ' + mapAcctIdToPayNum.get(billingAcct.Zuora__Account__c));
                    }
                }
                else if(remainingAmt > 0) { // Start/End PD-0266 23May16 JohnD - added "if(remainingAmt > 0)"
                    paymentMap.put('PaymentMethodId', mapBAToPayMet.get(billingAcct.Zuora__External_Id__c)); //start/end rom 10/20
                    paymentMap.put('Amount', remainingAmt);
                    paymentMap.put('Type', 'Electronic');
                }

                paymentMap.put('AccountId', targetBAId);
                paymentMap.put('EffectiveDate', Zuora.Zutil.getZuoraDate(Date.today()));    
                //START D-3601 10/29/2015 Added by J.Sarion - Invoice Id will not be set if the Invoice amount is 0 / the remaining amount to be paid is 0
                if(remainingAmt > 0){
                    paymentMap.put('InvoiceId', zobj.getValue('Id'));
                    paymentMap.put('AppliedInvoiceAmount', remainingAmt);
                }
                //END D-3601 10/29/2015 Added by J.Sarion - Invoice Id will not be set if the Invoice amount is 0 / the remaining amount to be paid is 0
                paymentMap.put('Status', 'Processed');   
                
                lstPaymentMap.add(paymentMap);
            }
        }
        //Perform Payment Callout
        if (!lstPaymentMap.isEmpty()) {
            try
            {
                List<Map<String,String>> results = zCallOut.loadZObjects(lstPaymentMap, 'Payment');
        
                for (Map<String,String> resultMap :results) {           
                    if (resultMap.get('Status') != 'Success') {
                        logger.log(false, '[processPayment] Payment Creation Error: ' + resultMap.get('Message') + ' - PaymentMap: ' + lstPaymentMap); //START/END D-4235 01/07/15 RReyes - added paymentMap on logs
                    }
                }
            }
            catch (Exception e)
            {
                logger.log(e);
            }
        } // End of If
    } // End of Method 
    //Start UD-3890 09-Apr-2016 Added by S.Puli - Replace updateZInvoice by UpdateInvPrevBalance
    /*******
    //START 04 October 2015 UD-2504 Kevin Evasco - Initialize Invoice Previous Balance
    public static void updateZInvoice(list<Zuora.zObject> zobjs) {
    
        String billingAccountZID = (String) zobjs.get(0).getValue('AccountId');
        Decimal previousBalance = 0.00;
        if (billingAccountZID != null) {
            
            Zuora__CustomerAccount__c fullprepaidBillingAccount;
            //Start UD-3890 06-Apr-2016 Added By S.Puli 
            string invZuoraId = (String) zobjs.get(0).getValue('Id');
            String directCorp = GlobalVariableClass.ACCRECTYPEDC;
            String fullPrep = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
            List<Zuora__CustomerAccount__c> fullPrepaidBillingAccountList = [SELECT Id, Zuora__Balance__c, Zuora__Account__c, Zuora__Account__r.RecordType.Name  
                     FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = :billingAccountZID];
            List<Zuora__CustomerAccount__c> recurringBillingAccountList = new List<Zuora__CustomerAccount__c>();
            //Start UD-3890 08-Apr-2016 Added By S.Puli - fixed issue for previous balance
            List<Zuora__ZInvoice__c> zInv = [select id, Zuora__TotalAmount__c, Zuora__Zuora_Id__c from Zuora__ZInvoice__c where Zuora__Zuora_Id__c = :invZuoraId];
            //End UD-3890 08-Apr-2016 Added By S.Puli - fixed issue for previous balance
            if(fullPrepaidBillingAccountList.size() > 0) {
                fullprepaidBillingAccount = fullPrepaidBillingAccountList.get(0);           
                
                recurringBillingAccountList = [SELECT Id, Zuora__Balance__c, Zuora__Account__c 
                     FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c = :fullprepaidBillingAccount.Zuora__Account__c AND Zuora__Balance__c < 0 
                     AND (Billing_Type__c = :GlobalVariableClass.BILLING_TYPE_MR_POST OR Billing_Type__c = :GlobalVariableClass.BILLING_TYPE_MR_PRE)];
                
                List<Zuora__CustomerAccount__c> existingBillingAccountList = [SELECT Id, Zuora__Balance__c, Zuora__Account__c, Zuora__Account__r.RecordType.Name  
                     FROM Zuora__CustomerAccount__c WHERE Zuora__Account__r.RecordType.Name = :directCorp AND Zuora__Account__c = :fullprepaidBillingAccount.Zuora__Account__c AND ID <> :fullprepaidBillingAccount.Id AND Zuora__Balance__c <> 0 order by createddate desc];
                
                List<Zuora__Subscription__c> sublist = [select id, Zuora__CustomerAccount__c, Order_Number_1__r.Billing_Account_Creation_Mode__c, 
                                                        Order_Number_1__r.Amount_Paid__c, Order_Number_1__r.Check_Amount__c 
                                                        from Zuora__Subscription__c where Zuora__CustomerAccount__c = :fullprepaidBillingAccount.Id order by createddate desc];
                
                if(fullprepaidBillingAccount.Zuora__Account__r.RecordType.Name == directCorp){
                    if(!sublist.isEmpty()){
                        if(existingBillingAccountList.isEmpty()){   
                            
                            if(sublist[0].Order_Number_1__r.Billing_Account_Creation_Mode__c == GlobalVariableClass.CREATE_NEW_BILLACC){    
                                previousBalance = 0.00;
                            }else{
                                //Start UD-3890 08-Apr-2016 Added By S.Puli - fixed issue for previous balance
                                if(!zInv.isEmpty()){
                                    previousBalance += fullprepaidBillingAccount.Zuora__Balance__c - zInv[0].Zuora__TotalAmount__c;
                                }
                                //End UD-3890 08-Apr-2016 Added By S.Puli
                            }
                            
                        }else{
                            previousBalance = existingBillingAccountList[0].Zuora__Balance__c;/* + fullprepaidBillingAccount.Zuora__Balance__c;
                            if(sublist[0].Order_Number_1__r.Amount_Paid__c <> null){
                                previousBalance = Math.ABS(previousBalance - sublist[0].Order_Number_1__r.Amount_Paid__c);
                            }
                            if(sublist[0].Order_Number_1__r.Check_Amount__c <> null){
                                previousBalance = Math.ABS(previousBalance - sublist[0].Order_Number_1__r.Check_Amount__c);
                            }*//*********
                        }
                    }
                }else{
                    previousBalance += fullprepaidBillingAccount.Zuora__Balance__c;
                }
            }
              
            if(!recurringBillingAccountList.isEmpty() && fullprepaidBillingAccount.Zuora__Account__r.RecordType.Name <> directCorp) {
                for(Zuora__CustomerAccount__c recurringBillingAccountElem : recurringBillingAccountList)
                    previousBalance += recurringBillingAccountElem.Zuora__Balance__c;
            }
            //End UD-3890 06-Apr-2016 Added By S.Puli
        }
    
    
        ZInvoiceHelper.ZInvoiceWrapper zInvoiceWrapperInstance = new ZInvoiceHelper.ZInvoiceWrapper();
        zInvoiceWrapperInstance.invoiceId = (String) zobjs.get(0).getValue('Id');
        zInvoiceWrapperInstance.previousBalance = String.valueOf(previousBalance); 
        
        List<ZInvoiceHelper.ZInvoiceWrapper> zInvoiceWrapperList = new List<ZInvoiceHelper.ZInvoiceWrapper>();
        zInvoiceWrapperList.add(zInvoiceWrapperInstance);       
        
        ZInvoiceHelper.adjustInvoicePreviousBalance(zInvoiceWrapperList,logger);
        //logger.save();
    }   
    //END 04 October 2015 UD-2504 Kevin Evasco - Initialize Invoice Previous Balance
    *******/
    public void updateInvPrevBalance(List<Zuora.zObject> zobjs, ZuoraCallOut zCallOut){
        
        List<Map<String, Object>> invoiceList = new List<Map<String, Object>>();
        for(Zuora.zObject zObj : zobjs){
            Decimal prevBalance = 0.00;
            if(mapInvBAToTotalCBAmt.containsKey((String)zObj.getValue('AccountId'))){
                prevBalance = 0 - mapInvBAToTotalCBAmt.get((String)zObj.getValue('AccountId'));
            }
            Map<String, Object> invoiceMap = new Map<String, Object>();         
            invoiceMap.put('Id', (String) zObj.getValue('Id'));
            invoiceMap.put('Previous_Balance__c', string.valueOf(prevBalance));
            invoiceList.add(invoiceMap);
        }
        try {   
            List<Map<String,String>> resultMap = zCallout.updateZObjects(invoiceList, 'Invoice');
             for(Map<String,String> result :resultMap){
                if(result.get('Status') == 'Success') {                      
                    system.debug('Successful adjustInvoicePreviousBalance'); 
                }
                else {
                    logger.log(false,result.get('Message'));                                                     
                } 
             }
        } catch (exception ze) {
              logger.log(ze);
        }
    }
    //End UD-3890 09-Apr-2016 Added by S.Puli
}