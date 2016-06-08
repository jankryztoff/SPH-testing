/**
 * Class Name: ExternalPaymentTriggerHandler
 * @author: Jayson Sarion
 * Date: 
 * Requirement/Project Name: <SPH>
 * @description 
 * 
**/

/*History 1: Added logic for new implementation for Contact. - K. Tan / D- 0597*/
     
public class ExternalPaymentTriggerHandler implements TriggerHandlerInterface {

    //Letter Type
    public static final String invoiceLetter = 'Invoice Letter';
    //START UD-1544 03-07-2015 Marvin Gatchalian
    public static List<Log__c> logList = new List<Log__c>();
    //END UD-1544 03-07-2015 Marvin Gatchalian
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    /*------------------- Key Id's -------------------*/ 
    public static String PayPal = (String) ConstantsSLB.getKeyId('PayPal');
    
    //START D-3236 11-07-2015 Marvin/John
    public static String Other = (String) ConstantsSLB.getKeyId('Other');
    public static String PMTHD_INV_ID = ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other');
    //END D-3236 11-07-2015 Marvin/John
    
    public static String caseStop = (String) ConstantsSLB.getKeyId('Case_Stop');
    
    /*----------------- End Key Id's -----------------*/

    Boolean ownerTransfer;
    public static Set<Id> extCCIdSet = new Set<Id>();
    public static Set<Id> accIdWithInvoice = new Set<Id>();
    public static Set<Id> allExtIdSet = new Set<Id>();
    public static Set<Id> extIdSet = new Set<Id>();
    public static Set<Id> stopExtIdSet = new Set<Id>();
    public static Set<Id> stopExtIdCCSet = new Set<Id>();
    public static Set<Id> acctIdSet = new Set<Id>();
    public static Set<Id> packageIdSet = new Set<Id>();
    public static Set<Id> subIdSet = new Set<Id>();
    //START D-3236 10-07-2015 Marvin/John
    public static Set<String> subNameSet = new Set<String>();
    //END D-3236 10-07-2015 Marvin/John    
    public static Set<Id> subIdAmendSet = new Set<Id>();
    public static Set<String> ratePlanNameSet = new Set<String>();
    public static Set<String> ratePlanId = new Set<String>();
    public static Set<Id> accIdSet = new Set<Id>();
    public static Set<String> publicationCodeSet = new Set<String>();
    public static Set<String> billingAccountIdSet = new Set<String>();
    
    /*------------------- External Payment For Paypal -------------------*/
    public static Map<String, String> pTransIdToZuoraIdMap = new Map<String, String>();
    public static Map<String, Id> pTransIdToAcctIdMap = new Map<String, Id>();
    public static Map<Id, External_Payment__c> idToExtMap = new Map<Id, External_Payment__c>();
    public static Map<Id, Order__c> acctIdToOrderMap = new Map<Id, Order__c>();
    public static Map<String, Zuora__Subscription__c> pTransIdToSubMap = new Map<String, Zuora__Subscription__c>();
    public static Map<Id, Package__c> idToPackageMap = new Map<Id, Package__c>();
    public static Map<String, Zuora__SubscriptionProductCharge__c> subProdChargeMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    public static Map<String, zqu__ProductRatePlan__c> prodRatePlanMap = new Map<String, zqu__ProductRatePlan__c>();
    public static Map<String, zqu__ProductRatePlanCharge__c> prodRatePlanChargeMap = new Map<String, zqu__ProductRatePlanCharge__c>();
    public static Map<Id, String> subIdToDOWPattern = new Map<Id, String>();
    public static Map<Id, List<Publication__c>> subIdToPubMap = new Map<Id, List<Publication__c>>();
    public static Map<Id, Date> subIdToEarliestStartDateMap = new Map<Id, Date>();
    public static Map<String, Publication__c> publicationMap = new Map<String, Publication__c>();
    public static Map<Id, Zuora__CustomerAccount__c> billAccIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
    public static Map<Id, External_Payment__c> extIdToExtDetailedMap = new Map<Id, External_Payment__c>();
    public static Map<Id, Id> billAccIdToExtIdMap = new Map<Id, Id>();
    public static Map<Id, Id> acctIdToExtIdMap = new Map<Id, Id>();
    public static Map<Id, Id> extIdToAccIdMapCC = new Map<Id, Id>();
    public static Map<Id, List<Zuora__Subscription__c>> extIdToSubListMapCC = new Map<Id, List<Zuora__Subscription__c>>();
    public static Map<Id, String> accIdToBillAccZuoraId = new Map<Id, String>();
    public static List<zqu__ProductRatePlanCharge__c> publicationCode = new List<zqu__ProductRatePlanCharge__c>();
    public static List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
    public static List<zqu__ProductRatePlan__c> ratePlanList = new List<zqu__ProductRatePlan__c>();
    public static List<Order__c> orderList = new List<Order__c>();
    public static List <Publication__c> publication = new List<Publication__c>();
    public static List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
    public static List<Package__c> packageList = new List<Package__c>();
    public static List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
    public static List<Case> caseList = new List<Case>();
    public static List<String> billingAccountList = new List<String>();
    public static List<External_Payment__c> extList = new List<External_Payment__c>();
    public static List<Zuora__CustomerAccount__c> billAccList = new List<Zuora__CustomerAccount__c>();
    public static Set<String> parentTransactionIdSet = new Set<String>();
    
    /*------------------- External Payment For Paypal -------------------*/
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !ExternalPaymentTriggerHandler.isBeforeInsertTriggerCalled;
        ExternalPaymentTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !ExternalPaymentTriggerHandler.isBeforeUpdateTriggerCalled;
        ExternalPaymentTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !ExternalPaymentTriggerHandler.isBeforeDeleteTriggerCalled;
        ExternalPaymentTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !ExternalPaymentTriggerHandler.isAfterInsertTriggerCalled;
        ExternalPaymentTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !ExternalPaymentTriggerHandler.isAfterUpdateTriggerCalled;
        ExternalPaymentTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !ExternalPaymentTriggerHandler.isAfterDeleteTriggerCalled;
        ExternalPaymentTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public void bulkBefore() {
        
    }
    
    public void bulkAfter() {
        for (sObject ext :Trigger.new) {
            if (trigger.isInsert) {
                External_Payment__c newExtPayment = (External_Payment__c) ext;
                idToExtMap.put(newExtPayment.Id, newExtPayment);
                allExtIdSet.add(newExtPayment.Id);
                
                //Payment Method: Credit Card
                if (newExtPayment.Billing_Account__c != null && (newExtPayment.Payment_Method__c == 'Credit Card' || (newExtPayment.Payment_Method__c == 'PayPal' && newExtPayment.PayPal_BAID__c != null && newExtPayment.PayPal_BAID__c != ''))) { //START-END UD-2806 10/12/2015 Added by K.Tan/J.Sarion - implement retry failure for Paypal
                    billingAccountIdSet.add(newExtPayment.Billing_Account__c);
                    billingAccountList.add(newExtPayment.Billing_Account__c);
                }
                //Payment Method: PayPal
                if (newExtPayment.Parent_Transaction_ID__c != null) {
                    parentTransactionIdSet.add(newExtPayment.Parent_Transaction_ID__c);
                    if (newExtPayment.Transaction_Type__c == 'F' || newExtPayment.Transaction_Type__c == 'R') {
                        extIdSet.add(newExtPayment.Id);
                    }
                    else if (newExtPayment.Transaction_Type__c == 'C') {
                        stopExtIdSet.add(newExtPayment.Id);
                    }
                }
            }
        }       
        if (!allExtIdSet.isEmpty()) {
            checkExtIdforSubStop();
        }
        if (!accIdSet.isEmpty() || !parentTransactionIdSet.isEmpty()) {
            getSubscriptions();
        }   
        if (!stopExtIdSet.isEmpty() || !stopExtIdCCSet.isEmpty()) {
            prepareValues();
        }
    }
   
    public void beforeInsert(SObject so) {
    
    }
       
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
               
    }
    
    public void afterInsert(SObject so) {
        External_Payment__c lNewExtPayment = (External_Payment__c) so;
        idToExtMap.put(lNewExtPayment.Id, lNewExtPayment);
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        /*Includes Creation of Billing Account with Payment Method Invoice, Update Customer Account to the New Billing Account,
        * and Set Billing Account to Active
        */
        
		//START UD-2549 3/23/2016 Added by J.Sarion - Remove Transfer and Cancellation
        //START D-3236 13-07-2015 Marvin/John
        if (trigger.isAfter) {
            if (!extCCIdSet.isEmpty()) {
                //createBillingAccountToZuora(extCCIdSet, subIdSet, subNameSet);
            }
            //END D-3236 13-07-2015 Marvin/John

            if (!stopExtIdCCSet.isEmpty()) {
                ownerTransfer = true;
                //setOrder(stopExtIdSet);
                //setOLI(stopExtIdSet);
                //setCase();          
                //amendZuora(stopExtIdCCSet, ownerTransfer, accIdToBillAccZuoraId);
            }
            if (!stopExtIdSet.isEmpty()) {
                ownerTransfer = false;
                //setOrder(stopExtIdSet);
                //setOLI(stopExtIdSet);
                //setCase();
                //amendZuora(stopExtIdSet, ownerTransfer, accIdToBillAccZuoraId);
            }
            if (!extIdSet.isEmpty()) {
                paymentToZuora(extIdSet, parentTransactionIdSet);
            }
			//START UD-1544 03-07-2015 Marvin Gatchalian
            if(!logList.isEmpty()){
                insert logList;
            }
			//END UD-1544 03-07-2015 Marvin Gatchalian
        }
		//END UD-2549 3/23/2016 Added by J.Sarion - Remove Transfer and Cancellation
    }

    /*Create Payment in Zuora. Existing unpaid Invoices will be considered. Remaining Balance will 
    * will be added as Credit Balance. Prepare the values to be used during CallOut.
    */
    @future(callout = true)
    public static void paymentToZuora(Set<Id> extId, Set<String> parentTransIdSet) {
        
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        List<External_Payment__c> extPaymentList = new List<External_Payment__c>();
        List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>();
        //END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        List<Map<String, Object>> paymentList = new List<Map<String, Object>>();
        List<Zuora__ZInvoice__c> zInvoiceList = new List<Zuora__ZInvoice__c>();
        Map<String, String> parentTransIdToZuoraIdMap = new Map<String, String>();
        Map<Id, List<Zuora__ZInvoice__c>> billAcctIdToZInvoiceListMap = new Map<Id, List<Zuora__ZInvoice__c>>();
        Map<String, External_Payment__c> parentTransIdToExtMap = new Map<String, External_Payment__c>();
        Map<Id, External_Payment__c> billAcctIdToExtMap = new Map<Id, External_Payment__c>();
        Map<Id, Decimal> extIdToBalanceMap = new Map<Id, Decimal>();
        Map<Id, Decimal> extIdToRemainingBalMap = new Map<Id, Decimal>();
        Map<Id, List<Zuora__ZInvoice__c>> extIdToPaidZInvoiceListMap = new Map<Id, List<Zuora__ZInvoice__c>>();
        Map<Id, List<Zuora__ZInvoice__c>> extIdToSemiPaidZInvoiceListMap = new Map<Id, List<Zuora__ZInvoice__c>>();
        Map<String, Object> paymentMap;
        Set<Id> billingAcctIdSet = new Set<Id>();
        Boolean paid;
        Boolean partial;
        Boolean withBal;
        
        //START 02/18/2015 - Code Review -  Added by Rom Edison Reyes - Checks if extId is not empty.
        if(extId.size()>0){
            extPaymentList = [SELECT Id, Parent_Transaction_ID__c, Transaction_Amount__c, Transaction_Date__c, Reference_ID__c FROM External_Payment__c WHERE Id IN :extId];
        }//END 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if extId is not empty.
        
        //START 02/18/2015 - Code Review -  Added by Rom Edison Reyes - Checks if parentTransIdSet is not empty.
        if (parentTransIdSet.size() >0) {
        subsList = [SELECT Id, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__Account__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Parent_Transaction_ID__c, Main_Package_1__c, Effective_Start_Date__c, New_Contract_Period_1__c, Number_of_Copies__c, Term_Length__c 
                   FROM Zuora__Subscription__c 
                   WHERE Parent_Transaction_ID__c IN :parentTransIdSet];
        }//END 02/18/2015 - Code Review -  Added by Rom Edison Reyes - Checks if parentTransIdSet is not empty.
        
        for (External_Payment__c ext :extPaymentList) {
            parentTransIdToExtMap.put(ext.Parent_Transaction_ID__c, ext);
        }
        
        for (Zuora__Subscription__c sub :subsList) {
            parentTransIdToZuoraIdMap.put(sub.Parent_Transaction_ID__c, sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);
            //START: 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if sub.Zuora__CustomerAccount__c is not null before adding to billingAccountIdSet
            if(sub.Zuora__CustomerAccount__c != null){
                billingAcctIdSet.add(sub.Zuora__CustomerAccount__c);
            }//END: 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if sub.Zuora__CustomerAccount__c is not null before adding to billingAccountIdSet
            External_Payment__c ext = parentTransIdToExtMap.get(sub.Parent_Transaction_ID__c);
            billAcctIdToExtMap.put(sub.Zuora__CustomerAccount__c, ext);
        }
        
        //START 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if billingAcctIdSet is not empty
        if(billingAcctIdSet.size()>0){
        
            zInvoiceList = [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__BillingAccount__c, Zuora__DueDate__c, Zuora__Balance2__c 
                            FROM Zuora__ZInvoice__c 
                            WHERE Zuora__BillingAccount__c IN :billingAcctIdSet AND Zuora__Balance2__c > 0 Order By Zuora__DueDate__c];
        }//END 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if billingAcctIdSet is not empty
        
        for (Zuora__ZInvoice__c zInvoice :zInvoiceList) {
            if (billAcctIdToZInvoiceListMap.containsKey(zInvoice.Zuora__BillingAccount__c)) {
                billAcctIdToZInvoiceListMap.get(zInvoice.Zuora__BillingAccount__c).add(zInvoice);
            }
            else {
                billAcctIdToZInvoiceListMap.put(zInvoice.Zuora__BillingAccount__c, new List<Zuora__ZInvoice__c>{zInvoice});
            }
        }
        
        /*Create a Map of External Payment with Fully Paid and Partially Paid Invoices.
        *Remaining Balance will be added as Credit Balance to the respective Billing Account
        */
        for (Id key :billAcctIdToExtMap.keySet()) {
            External_Payment__c ext = billAcctIdToExtMap.get(key);
            Decimal Balance = ext.Transaction_Amount__c;
            if (billAcctIdToZInvoiceListMap.containsKey(key)) {
                for (Zuora__ZInvoice__c zInvoice :billAcctIdToZInvoiceListMap.get(key)) {
                    if (zInvoice.Zuora__Balance2__c <= Balance) {
                        Balance -= zInvoice.Zuora__Balance2__c;
                        if (extIdToPaidZInvoiceListMap.containsKey(ext.Id)) {
                            extIdToPaidZInvoiceListMap.get(ext.Id).add(zInvoice);
                        }
                        else {
                            extIdToPaidZInvoiceListMap.put(ext.Id, new List<Zuora__ZInvoice__c>{zInvoice});
                        }
                    }
                    else if (zInvoice.Zuora__Balance2__c > Balance && Balance > 0) {
                        extIdToSemiPaidZInvoiceListMap.put(ext.Id, new List<Zuora__ZInvoice__c>{zInvoice});
                        extIdToBalanceMap.put(ext.Id, Balance); 
                        Balance = 0;
                    }
                }
            }
            if (Balance > 0 && Balance != ext.Transaction_Amount__c) {
                extIdToRemainingBalMap.put(ext.Id, Balance);
            }
        }

        for (External_Payment__c ext :extPaymentList) {
            if (extIdToPaidZInvoiceListMap.containsKey(ext.Id)) {
                for (Zuora__ZInvoice__c zInvoice :extIdToPaidZInvoiceListMap.get(ext.Id)) {
                    paid = true;
                    paymentMap = createPaymentMap(ext, zInvoice, parentTransIdToZuoraIdMap, extIdToBalanceMap, extIdToRemainingBalMap, extIdToPaidZInvoiceListMap, extIdToSemiPaidZInvoiceListMap, paid, partial, withBal);
                    paymentList.add(paymentMap);
                    paid = false;
                }
            }
            if (extIdToSemiPaidZInvoiceListMap.containsKey(ext.Id)) {
                for (Zuora__ZInvoice__c zInvoice :extIdToSemiPaidZInvoiceListMap.get(ext.Id)) {
                    partial = true;
                    paymentMap = createPaymentMap(ext, zInvoice, parentTransIdToZuoraIdMap, extIdToBalanceMap, extIdToRemainingBalMap, extIdToPaidZInvoiceListMap, extIdToSemiPaidZInvoiceListMap, paid, partial, withBal);
                    paymentList.add(paymentMap);
                    partial = false;
                }
            }
            if (extIdToRemainingBalMap.containsKey(ext.Id)) {
                withBal = true;
                Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
                paymentMap = createPaymentMap(ext, zInvoice, parentTransIdToZuoraIdMap, extIdToBalanceMap, extIdToRemainingBalMap, extIdToPaidZInvoiceListMap, extIdToSemiPaidZInvoiceListMap, paid, partial, withBal);
                paymentList.add(paymentMap);
                withBal = false;
            }
            if (!extIdToPaidZInvoiceListMap.containsKey(ext.Id) && !extIdToSemiPaidZInvoiceListMap.containsKey(ext.Id) && !extIdToRemainingBalMap.containsKey(ext.Id)) {
                Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
                paymentMap = createPaymentMap(ext, zInvoice, parentTransIdToZuoraIdMap, extIdToBalanceMap, extIdToRemainingBalMap, extIdToPaidZInvoiceListMap, extIdToSemiPaidZInvoiceListMap, paid, partial, withBal);
                paymentList.add(paymentMap);
            }
        }
        if (!paymentList.isEmpty()) {
          ZuoraCallOut paymentCallOut = new ZuoraCallOut();
            List<Map<String,String>> returnVarPayPal = paymentCallOut.loadZObjects(paymentList, 'Payment'); 
            for(Map<String,String> resultMapPayPal :returnVarPayPal){ 
                if (resultMapPayPal.get('Status') == 'Success') {
                    //TBD
                }
                else {
                    //TBD
                }
            }
        }
    }
    
    /*Create Amendment to the Subscription. Selected Subscription will be Cancelled.
    * Stop Subscription Process will be used.
    */
    
    //START D-3236 10-07-2015 Marvin/John: loading usages new billing account
    @future(callout = true)
    public static void amendZuora(Set<Id> extId, Boolean forTransfer, Map<Id, String> accIdToNewBillAccZuoraId) {
        List<Map<String, Object>> amendList = new List<Map<String, Object>>();
        Set<String> newSubscriptionZuoraIdSet = new Set<String>();
        ZuoraCallOut amendCallOut = new ZuoraCallOut();
        
        //START UD-1544 10/08/2015 Added by K.Tan/J.Sarion - added variables
        Integer count = 0;
        Set<String> zuoraIdSet = new Set<String>();
        Map<String, Zuora__Subscription__c> subZuoraIdToSubMap = new Map<String, Zuora__Subscription__c>();
        List<Zuora__Subscription__c> subList2 = new List<Zuora__Subscription__c>();
        List<String> subZuoraIdList = new List<String>();
        Map<String, Date> subIdToLatestInvoiceDateMap = new Map<String, Date>();
        //END UD-1544 10/08/2015 Added by K.Tan/J.Sarion - added variables
        
        amendList = ownerTransferAndStopSub(extId, forTransfer, accIdToNewBillAccZuoraId);
        
        //START UD-1544 10/08/2015 Added by K.Tan/J.Sarion - create zuora id to sub map
        for(Map<String, Object> amendMap :amendList){
            zuoraIdSet.add(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)));
        }
        
        if(!zuoraIdSet.isEmpty()){
            for(Zuora__Subscription__c sub :[SELECT Id, Zuora__Zuora_Id__c, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :zuoraIdSet]){
                subZuoraIdToSubMap.put(sub.Zuora__Zuora_Id__c, sub);
            }
            
            subIdToLatestInvoiceDateMap = getRelatedInvoice(zuoraIdSet);
        }
        
        for(Map<String, Object> amendMap :amendList){
            if(subZuoraIdToSubMap.containsKey(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)))){
                subList2.add(subZuoraIdToSubMap.get(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID))));
                subZuoraIdList.add(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)));
            }
        }
        
        if (!amendList.isEmpty()) {
            List<Map<String,String>> returnVarStopSub = amendCallOut.amendZObjects(amendList); 
            for(Map<String,String> resultMapStopSub :returnVarStopSub){ 
                if (resultMapStopSub.get('Status') == 'Success') {
                    //TBD
                    newSubscriptionZuoraIdSet.add(resultMapStopSub.get('SubId'));
                    subZuoraIdToSubMap.put(resultMapStopSub.get('SubId'), subZuoraIdToSubMap.get(subZuoraIdList[count]));
                }
                else {
                    //TBD
                }
                count++;
            }
        }
        
        if (!newSubscriptionZuoraIdSet.isEmpty()) {
            amendList = new List<Map<String, Object>>();
            //amendList = cancelSubscription(newSubscriptionZuoraIdSet); //START-END UD-2806 11/09/2015 Added by J.Sarion - Commented Subscription Cancellation
            
            //UD-1544
            for(Map<String, Object> amendMap :amendList){
                if(subZuoraIdToSubMap.containsKey(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)))){
                    Zuora__Subscription__c sub = subZuoraIdToSubMap.get(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)));
                    
                    if(subIdToLatestInvoiceDateMap.containsKey(sub.Zuora__Zuora_Id__c)){
                        amendMap.put(globalvariableclass.EFFECTIVE_DATE, Zuora.Zutil.getZuoraDate(subIdToLatestInvoiceDateMap.get(sub.Zuora__Zuora_Id__c)));
                    }
                }
            }
            //UD-1544
            if (!amendList.isEmpty()) {
                List<Map<String,String>> returnVarStopSub = amendCallOut.amendZObjects(amendList); 
                for(Map<String,String> resultMapStopSub :returnVarStopSub){ 
                    if (resultMapStopSub.get('Status') == 'Success') {
                        //TBD
                        newSubscriptionZuoraIdSet.add(resultMapStopSub.get('SubId'));
                    }
                    else {
                        //TBD
                    }
                }
            }
        }
       
        //END D-3236 10-07-2015 Marvin/John : loading usages new billing account
        
        
    }
    
    public void setOrder(Set<Id> lExtId) {
        for (Id key :lExtId) {
            External_Payment__c ext = idToExtMap.get(key);
            if (!pTransIdToAcctIdMap.isEmpty() || !extIdToAccIdMapCC.isEmpty()) {
                if (!acctIdSet.contains(pTransIdToAcctIdMap.get(ext.Parent_Transaction_ID__c)) || !acctIdSet.contains(extIdToAccIdMapCC.get(ext.Id))) {
                    Order__c order = new Order__c();
                    order.status__c = 'New';
                    order.case_record_type__c = 'Stop Subscription';
                    order.category__c = 'Subscription Request';
                    order.Sub_Category__c = 'Stop Subscription';
                    order.credit_balance__c = 0;
                    order.delivery_charge__c = 0;
                    order.monthly_delivery_charge_for_full_payment__c = 0;
                    orderList.add(order);
                    
                    if (pTransIdToAcctIdMap.containsKey(ext.Parent_Transaction_ID__c)) {
                        order.account__c = pTransIdToAcctIdMap.get(ext.Parent_Transaction_ID__c);
                        acctIdSet.add(pTransIdToAcctIdMap.get(ext.Parent_Transaction_ID__c));
                    }
                    else if (acctIdSet.contains(extIdToAccIdMapCC.get(ext.Id))) {
                        order.account__c = extIdToAccIdMapCC.get(ext.Id);
                        acctIdSet.add(extIdToAccIdMapCC.get(ext.Id));
                    }
                }
            }
        }
        
        try {
            insert orderList;
            for (Order__c order :orderList) {
                if (acctIdSet.contains(order.Account__c)) {
                    acctIdToOrderMap.put(order.Account__c, order);
                }
            }
        } 
        catch(DmlException e) {
            //TBD
        }
    }
    
    public void setOLI(Set<Id> lExtId) {
        for (Id key :lExtId) {
            List<Zuora__Subscription__c> lsubList = new List<Zuora__Subscription__c>();
            External_Payment__c ext = idToExtMap.get(key);
            if (!pTransIdToSubMap.isEmpty() || !extIdToSubListMapCC.isEmpty()) {
                if (!pTransIdToSubMap.isEmpty()) {
                    Zuora__Subscription__c lsub = pTransIdToSubMap.get(ext.Parent_Transaction_ID__c);
                    lsubList.add(lsub);
                }
                else if(!extIdToSubListMapCC.isEmpty()) {
                    lsubList = extIdToSubListMapCC.get(ext.Id);
                }
                if (lsubList != null) {
                    for (Zuora__Subscription__c sub :lsubList) {
                        if (!subIdAmendSet.contains(sub.Id)) {
                            if (!pTransIdToAcctIdMap.isEmpty() || !extIdToAccIdMapCC.isEmpty()) {
                                if (acctIdToOrderMap.containsKey(pTransIdToAcctIdMap.get(ext.Parent_Transaction_ID__c)) || acctIdToOrderMap.containsKey(extIdToAccIdMapCC.get(ext.Id))) {
                                    Order__c order = new Order__c();
                                    if (pTransIdToAcctIdMap.containsKey(ext.Parent_Transaction_ID__c)) {
                                        order = acctIdToOrderMap.get(pTransIdToAcctIdMap.get(ext.Parent_Transaction_ID__c));
                                    }
                                    else if(extIdToAccIdMapCC.containsKey(ext.Id)) {
                                        order = acctIdToOrderMap.get(extIdToAccIdMapCC.get(ext.Id));
                                    }
                                    Package__c p = idToPackageMap.get(sub.Main_Package_1__c);
                                    Order_Line_Item__c OLIinstance = new Order_Line_Item__c();
                                    OLIinstance.order__c = order.id; 
                                    OLIinstance.Earliest_Start_Date__c = subIdToEarliestStartDateMap.get(sub.Id);
                                    OLIinstance.Start_Date__c = sub.Effective_Start_Date__c;
                                    OLIinstance.Main_Package_Period__c = sub.New_Contract_Period_1__c;
                                    OLIinstance.Qty__c = sub.Number_of_Copies__c;
                                    OLIinstance.Term_Length__c = sub.Term_Length__c;
                                    OLIinstance.Subscription__c = order.Subscription__c;
                                    OLIinstance.Delivered_By__c = '--None--';
                                    OLIinstance.earliest_stop_date__c = date.today() + 1;
                                    OLIinstance.Stop_Request_Date__c = date.today() + 1;
                                    OLIinstance.Terminating_Reason__c = 'Payment failure - PayPal';
                                    OLIinstance.Main_Package_Billing_Type__c = p.Billing_Type__c;  
                                    OLIinstance.Main_Package_Sub_Type__c = p.Package_Sub_Type__c;
                                    OLIinstance.Main_Package_Type__c = p.Package_Type__c;
                                    OLIinstance.Main_Package_ID__c = sub.Main_Package_1__c;
                                    OLIinstance.Main_Package_Frequency__c = subIdToDOWPattern.get(sub.Id);
                                    oliList.add(OLIinstance);
                                    subIdAmendSet.add(sub.Id);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        try {
            insert oliList;
        }
        catch(DmlException e) {
            //TBD
        }
    }
    
    public void setCase() {
        for(Order__c order :orderList) {   
            Case caseRec = new Case();
            caseRec.Subject = 'Stop Subscription';      
            caseRec.RecordTypeID = caseStop;
            caseRec.Category__c = 'Subscription Request';
            caseRec.Sub_Category__c = 'Stop Subscription';
            caseRec.Status = 'Pending';
            caseRec.Order__c = order.Id;
            caseRec.Order_Number__c = order.Id;
            caseRec.AccountId = order.Account__c;        
            caseList.add(caseRec);
        }
        
        try {
            insert caseList;
        } 
        catch(DmlException e) {
            //TBD
        }
    }
    
    //CallOut to Zuora to create a Payment for a specific Billing Account 
    public static Map<String, Object> createPaymentMap(sObject extPayment, sObject zInvoiceRec, Map<String, String> parentTransIdToZuoraIdMap, Map<Id, Decimal> extIdToBalanceMap, Map<Id, Decimal> extIdToRemainingBalMap, Map<Id, List<Zuora__ZInvoice__c>> extIdToPaidZInvoiceListMap, Map<Id, List<Zuora__ZInvoice__c>> extIdToSemiPaidZInvoiceListMap, Boolean paid, Boolean partial, Boolean withBal) {
        External_Payment__c ext = (External_Payment__c) extPayment;
        Zuora__ZInvoice__c zInvoice = (Zuora__ZInvoice__c) zInvoiceRec;
        Map<String, Object> paymentMap = new Map<String, Object>();
        date d = ext.Transaction_Date__c;
        datetime dt = datetime.newinstance(d.year(), d.month(), d.day());
        string dFormat = (string.valueOf(dt)).replaceAll( '\\s+', 'T');
        if (extIdToPaidZInvoiceListMap.containsKey(ext.Id) && paid) {
            paymentMap.put('Amount', zInvoice.Zuora__Balance2__c);
            paymentMap.put('AppliedInvoiceAmount', zInvoice.Zuora__Balance2__c);
        }
        else if (extIdToSemiPaidZInvoiceListMap.containsKey(ext.Id) && partial) {
            paymentMap.put('Amount', extIdToBalanceMap.get(ext.Id));
            paymentMap.put('AppliedInvoiceAmount', extIdToBalanceMap.get(ext.Id));
        }
        else if (extIdToRemainingBalMap.containsKey(ext.Id) && withBal) {
            paymentMap.put('Amount', extIdToRemainingBalMap.get(ext.Id));
            paymentMap.put('AppliedCreditBalanceAmount', extIdToRemainingBalMap.get(ext.Id));
        }
        else {
            paymentMap.put('Amount', ext.Transaction_Amount__c);
            paymentMap.put('AppliedCreditBalanceAmount', ext.Transaction_Amount__c);
        }
        
        if (zInvoice.Zuora__Zuora_Id__c != null && zInvoice.Name != null) {
            paymentMap.put('InvoiceId', zInvoice.Zuora__Zuora_Id__c);
            paymentMap.put('InvoiceNumber', zInvoice.Name);
        }

        paymentMap.put('AccountId', (ext.Parent_Transaction_ID__c != null ? parentTransIdToZuoraIdMap.get(ext.Parent_Transaction_ID__c) : ''));
        paymentMap.put('EffectiveDate', dFormat);
        paymentMap.put('PaymentMethodId', Other);
        paymentMap.put('Status', 'Processed');
        paymentMap.put('Type', 'External');
        paymentMap.put('OtherPaymentMethod__c', 'PayPal');
        paymentMap.put('ReferenceId', ext.Reference_ID__c);
        return paymentMap;
    }
    
    //START D-3236 13-07-2015 Marvin/JOHN
    @future(callout = true)
    public static void createBillingAccountToZuora(Set<Id> extId, Set<Id> subriptionIdSet, Set<String> subscriptionNameSet) {
    //public void createBillingAccountToZuora(Set<Id> extId) {
    //END D-3236 13-07-2015 Marvin/JOHN
	
    //START D-3236 11-07-2015 Marvin/Jonh
    //START UD-1544 03-07-2015 Marvin Gatchalian
    String BillingAcctId;
    String newBillingAcctNumber;
    List<Zuora__CustomerAccount__c> newBAlist = new List<Zuora__CustomerAccount__c>();
    Zuora__CustomerAccount__c newBA = new Zuora__CustomerAccount__c();
    //END UD-1544 03-07-2015 Marvin Gatchalian
    //END D-3236 11-07-2015 Marvin/Jonh
        ZuoraCallOut accountCallOut = new ZuoraCallOut();
        Set<String> newBillAccIdSet = new Set<String>();
        Set<String> newSubscriptionZuoraIdSet = new Set<String>();
        // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
        //List<String> contactNameZuoraIdList = new List<String>();
        // END : CCB 002 12/2/2014
        Map<Id, String> laccIdToBillAccZuoraId = new Map<Id, String>();
        List<Map<String, Object>> accList = new List<Map<String, Object>>();
        Map<String, String> contactTypeToZuoraIdMap = new Map<String, String>();
        List<Map<String, Object>> amendList;
        List<Map<String, Object>> updateAccountMapList = new List<Map<String, Object>>();
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        External_Payment__c ext = new External_Payment__c();
        //END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        
        //START UD-1544 10/08/2015 Added by K.Tan/J.Sarion - added variables
        Integer count = 0;
        Set<String> zuoraIdSet = new Set<String>();
        Map<String, Zuora__Subscription__c> subZuoraIdToSubMap = new Map<String, Zuora__Subscription__c>();
        List<Zuora__Subscription__c> subList2 = new List<Zuora__Subscription__c>();
        List<String> subZuoraIdList = new List<String>();
        Map<String, Date> subIdToLatestInvoiceDateMap = new Map<String, Date>();
        //END UD-1544 10/08/2015 Added by K.Tan/J.Sarion - added variables
        //START 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if extId is not empty  | Transferred declaration of 'ext' on start of method
        if(extId.size()>0){
            //START UD-1544 03-07-2015 Marvin Gatchalian / K. Tan/ J. Sarion 10/14/2015                                                      
            ext = [SELECT Id, Name, Account_Name__r.Name, 
                            Billing_Account__c, Billing_Account__r.Zuora__Currency__c, 
                            Payment_Method__c, Billing_Account__r.Zuora__BillCycleDay__c, 
                            Billing_Account__r.Zuora__PaymentTerm__c, Billing_Account__r.Zuora__SoldToName__c, 
                            Billing_Account__r.Zuora__BillToName__c,
                                                        Billing_Account__r.Other_PaymentMethod__c, 
                                                        Billing_Account__r.Zuora__BillToId__c, Billing_Account__r.Zuora__SoldToId__c, 
                                                        Billing_Account__r.Zuora__Account__r.Name, Billing_Account__r.Zuora__Account__c, 
                                                        Billing_Account__r.Zuora__Batch__c,
                                                        Billing_Account__r.Zuora__BillToAddress1__c, Billing_Account__r.Zuora__BillToAddress2__c, 
                                                        Billing_Account__r.Zuora__BillToCountry__c, Billing_Account__r.Zuora__BillToCity__c, 
                                                        Billing_Account__r.Zuora__BillToState__c, Billing_Account__r.Zuora__BillToPostalCode__c,
                                                        Billing_Account__r.Billing_Contact__c, 
                                                        Billing_Account__r.Billing_Type__c, Bank_Name__c, Sold_To_Contact_Name__c,
                                                        Account_Name__c
                                                FROM External_Payment__c 
                                                WHERE Id IN :extId];
            
            //END UD-1544 03-07-2015 Marvin Gatchalian   K. Tan/ J. Sarion 10/14/2015                                                       
        }//END 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if extId is not empty
		
        accList = createAccount(ext);
        if (!accList.isEmpty()) {
            List<Map<String,String>> returnVarAccount = accountCallOut.loadZObjects(accList, 'Account'); 
            for(Map<String,String> resultMapAccount :returnVarAccount){ 
                if (resultMapAccount.get('Status') == 'Success') {
                    //TBD
                    newBillAccIdSet.add(resultMapAccount.get('Id'));
                    laccIdToBillAccZuoraId.put(ext.Billing_Account__r.Zuora__Account__c, resultMapAccount.get('Id'));
                    
                 //START D-3236 11-07-2015 Marvin/John
                    
                    
                    BillingAcctId = (String) resultMapAccount.get('Id');
                    
                    
                    //START UD-1544 03-07-2015 Marvin Gatchalian
                    //List<String> ARMSDetails = new List<String>();
                    //ARMSDetails = string.valueof(ext.Bank_Name__c).Split(',');
                    
                   /* //START: D-3852 K.Tan 11/2/2015
                    newBA.Zuora__External_Id__c      = BillingAcctId;
                    newBA.Zuora__Zuora_Id__c         = BillingAcctId;
                    newBA.Zuora__Account__c          = ext.Account_Name__c;
                    //newBA.ARMS_Customer_Number__c    = ARMSDetails[1];
                    newBA.ARMS_Business_Profile__c   = 'NORM';
                    newBA.ARMS_Debt_Management__c    = 'SUBH';
                    newBA.Other_PaymentMethod__c     = GlobalVariableClass.INVOICE;
                    newBA.Billing_Contact__c         = ext.Billing_Account__r.Billing_Contact__c;
                    newBA.Payment_Mode__c            = 'Other';
                    newBA.name                       = ext.Account_Name__r.name;
                    newBAlist.add(newBA);
                    //newBA.ARMS_Return_Status__c      = 'ccFailure';
                    //END: D-3852 K.Tan 11/2/2015*/
                    
                }
                else {
                    //TBD
                    Log__c newLog = new Log__c();
                    newLog.Message__c = (String) resultMapAccount.get('Message');
                    newLog.Record_ID__c = (String) resultMapAccount.get('Id');
                    newLog.Detail__c = (String) resultMapAccount.get('Code');
                    logList.add(newLog);
                }
                //END UD-1544 03-07-2015 Marvin Gatchalian
                
                //END D-3236 11-07-2015 Marvin/John
            }
        }
        
        contactTypeToZuoraIdMap = createContact(ext, laccIdToBillAccZuoraId);
        
        updateAccountMapList = updateBillingAccount(ext, laccIdToBillAccZuoraId, contactTypeToZuoraIdMap);

        if (!updateAccountMapList.isEmpty()) {
            List<Map<String,String>> returnVarUpdateAccount = accountCallOut.updateZObjects(updateAccountMapList, 'Account'); 
            for(Map<String,String> resultUpdateMapAccount :returnVarUpdateAccount){ 
                if (resultUpdateMapAccount.get('Status') == 'Success') {
                    //TBD
                }
                else {
                    //TBD
                }
            }
        }
        Boolean forTransfer = true;
        amendList = new List<Map<String, Object>>();
        amendList = ownerTransferAndStopSub(extId, forTransfer, laccIdToBillAccZuoraId);
        //START UD-1544 10/08/2015 Added by K.Tan/J.Sarion - create zuora id to sub map
        for(Map<String, Object> amendMap :amendList){
            zuoraIdSet.add(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)));
        }
        
        if(!zuoraIdSet.isEmpty()){
            for(Zuora__Subscription__c sub :[SELECT Id, Zuora__Zuora_Id__c, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :zuoraIdSet]){
                subZuoraIdToSubMap.put(sub.Zuora__Zuora_Id__c, sub);
            }
            
            subIdToLatestInvoiceDateMap = getRelatedInvoice(zuoraIdSet);
        }
        
        for(Map<String, Object> amendMap :amendList){
            if(subZuoraIdToSubMap.containsKey(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)))){
                subList2.add(subZuoraIdToSubMap.get(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID))));
                subZuoraIdList.add(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)));
            }
        }

        if (!amendList.isEmpty()) {
            List<Map<String,String>> returnVarStopSub = accountCallOut.amendZObjects(amendList);

            for(Map<String,String> resultMapStopSub :returnVarStopSub){ 
                if (resultMapStopSub.get('Status') == 'Success') {
                    //TBD
                    newSubscriptionZuoraIdSet.add(resultMapStopSub.get('SubId'));
                    subZuoraIdToSubMap.put(resultMapStopSub.get('SubId'), subZuoraIdToSubMap.get(subZuoraIdList[count]));
                }
                else {
                    //TBD
                }
                count++;
            }
        }
        //END UD-1544 10/08/2015 Added by K.Tan/J.Sarion - create zuora id to sub map
        if (!newSubscriptionZuoraIdSet.isEmpty()) {
            amendList = new List<Map<String, Object>>();
            //amendList = cancelSubscription(newSubscriptionZuoraIdSet); //START-END UD-2806 11/09/2015 Added by J.Sarion - Commented Subscription Cancellation
            //UD-1544
            for(Map<String, Object> amendMap :amendList){
                if(subZuoraIdToSubMap.containsKey(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)))){
                    Zuora__Subscription__c sub = subZuoraIdToSubMap.get(String.valueOf(amendMap.get(globalvariableclass.SUBSCRIPTION_ID)));
                    
                    if(subIdToLatestInvoiceDateMap.containsKey(sub.Zuora__Zuora_Id__c)){
                        amendMap.put(globalvariableclass.EFFECTIVE_DATE, Zuora.Zutil.getZuoraDate(subIdToLatestInvoiceDateMap.get(sub.Zuora__Zuora_Id__c)));
                    }
                }
            }
            //UD-1544
            if (!amendList.isEmpty()) {
                List<Map<String,String>> returnVarStopSub = accountCallOut.amendZObjects(amendList); 
                for(Map<String,String> resultMapStopSub :returnVarStopSub){ 
                    if (resultMapStopSub.get('Status') == 'Success') {
                        //TBD
                        newSubscriptionZuoraIdSet.add(resultMapStopSub.get('SubId'));
                        
                        //START D-3236 13-07-2015 Marvin/JOHN
                        //START UD-1544 03-07-2015 Marvin Gatchalian
                        //date fDateToday = date.today();
                        //Map<String, Date> stopDate = new Map<String, Date>();
                        //for (string zuoraID :newSubscriptionZuoraIdSet) {
                        //    stopDate.put(zuoraID, fDateToday);
                        //}
                        
                        //usageCreationForStopSubscription  xX = new usageCreationForStopSubscription();
                        //xX.createUsage(stopdate);
                        //END UD-1544 03-07-2015 Marvin Gatchalian
                        //END  D-3236 13-07-2015 Marvin/JOHN
                    }
                    else {
                        //TBD
                    }
                }
            }
        }
        
        //START D-3236 11-07-2015 Marvin/John : create usages
        //START UD-1544 03-07-2015 Marvin Gatchalian
        //if (newBA != null) {
        //    insert newBA;
        //}
        
        //Create Usage to be assined to New Billing Account
        
        if (BillingAcctId != null) {
            String myQuery;
            List<Zuora.zObject> results = new List<Zuora.zObject>();
            ZuoraCallOut zCallout = new ZuoraCallOut();
            
            myQuery = 'select AccountNumber from Account where id=\'' + BillingAcctId + '\'';
            results = zCallout.queryZObject(myQuery);
    
            for (Zuora.zObject o : results) {
                newBillingAcctNumber = (String)o.getValue('AccountNumber');
            }
        }
                    
        if (newBillingAcctNumber != null) {
            usageCreationforCCFailure usageCreation = new usageCreationforCCFailure();
            usageCreation.createUsageForCreditCardFailure (subriptionIdSet, newBillingAcctNumber);
        }
        else {
            system.debug('>>> No new billing account created.... creating usages not performed ');
        }
        
        //END UD-1544 03-07-2015 Marvin Gatchalian
        //END D-3236 11-07-2015 Marvin/John : create usages
        
    }
    
    public static List<Map<String, Object>> createAccount(External_Payment__c extNewAcc) {
        Map<String, Object> accMap = new Map<String, Object>();
        List<Map<String, Object>> laccList = new List<Map<String, Object>>();
        
        //START D-3236 11-07-2015 Marvin/John
        //START UD-1544 03-07-2015 Marvin Gatchalian
        //List<String> ARMSDetails = new List<String>();
        //ARMSDetails = string.valueof(extNewAcc.Arms_Details__c).Split(',');
                    
        accMap.put('Name', extNewAcc.Billing_Account__r.Zuora__Account__r.Name);
        accMap.put('PaymentTerm', extNewAcc.Billing_Account__r.Zuora__PaymentTerm__c);
        accMap.put('BillCycleDay', extNewAcc.Billing_Account__r.Zuora__BillCycleDay__c);
        accMap.put('Batch', extNewAcc.Billing_Account__r.Zuora__Batch__c);
        
        accMap.put('CrmId', extNewAcc.Billing_Account__r.Zuora__Account__c);
        accMap.put('Billing_Type__c', extNewAcc.Billing_Account__r.Billing_Type__c);
        accMap.put('Link_Prev_Billing_Contact__c', extNewAcc.Billing_Account__r.Billing_Contact__c); // START-END D-3852 11/3/2015
        //accMap.put('ARMS_Account_Number__c', ARMSDetails[0]);
        //accMap.put('ARMS_ID__c', ARMSDetails[1]);
        // START D-3852 11/5/2015
        //accMap.put('ARMS_Business_Profile__c', 'NORM');
        //accMap.put('ARMS_Debt_Management__c', 'SUBH');
        // END D-3852 11/5/2015
        //END UD-1544 03-07-2015 Marvin Gatchalian
        
        accMap.put('DefaultPaymentMethodId', PMTHD_INV_ID);
        accMap.put('Other_PaymentMethod__c', 'Invoice');

        accMap.put('Currency', extNewAcc.Billing_Account__r.Zuora__Currency__c);
        accMap.put('Status', 'Draft');
        laccList.add(accMap);
        
        return laccList;
        
        //END D-3236 11-07-2015 Marvin/John
    }
    
    public static Map<String, String> createContact(External_Payment__c lExt, Map<Id, String> accountIdForContact) {    
        List<Map<String, Object>> lConList;
        Map<String, String> contactTypeToZuoraIdMap = new Map<String, String>();
        Map<String, Object> lconMap;
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        List<Contact> conBillToSoldTo  = new List<Contact>();
        //END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        
        //START 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if lExt.Billing_Account__r.Billing_Contact__c is not null | Transferred declaration of 'conBillToSoldTo' on start of method
        if(lExt.Billing_Account__r.Billing_Contact__c!=null){
            conBillToSoldTo = [SELECT Id, Name, FirstName, LastName, Address__r.Street_Name__c, Address__r.Block_House_Number__c, RecordTypeId,
                                                 Address__r.Country_Name__c, Address__r.Postal_Code__r.Name, Address__r.City__r.Name, Address__r.Building_Name__c
                                            FROM Contact 
                                            WHERE id =: lExt.Billing_Account__r.Billing_Contact__c]; 
        }//END 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks if lExt.Billing_Account__r.Billing_Contact__c is not null
        
        for (Contact con :conBillToSoldTo) {
            //if (conBillToSoldTo.size() == 1 || con.RecordTypeId == billingContact) {
                lConList = new List<Map<String, Object>>();
                lconMap = new Map<String, Object>();
                lconMap.put('FirstName', con.FirstName);
                lconMap.put('LastName', con.LastName);
                lconMap.put('Address1', lExt.Billing_Account__r.Zuora__BillToAddress1__c);
                lconMap.put('Address2', lExt.Billing_Account__r.Zuora__BillToAddress2__c);
                lconMap.put('City', lExt.Billing_Account__r.Zuora__BillToCity__c);
                lconMap.put('Country', lExt.Billing_Account__r.Zuora__BillToCountry__c);
                lconMap.put('PostalCode', lExt.Billing_Account__r.Zuora__BillToPostalCode__c);
                lconMap.put('State', lExt.Billing_Account__r.Zuora__BillToState__c);
                lconMap.put('AccountId', accountIdForContact.get(lExt.Billing_Account__r.Zuora__Account__c));
                lConList.add(lconMap);
                contactTypeToZuoraIdMap.put('Customer Contact', createContactCallOut(lConList));
                
            //}
        }
        return contactTypeToZuoraIdMap;
    }       
    public static String createContactCallOut(List<Map<String, Object>> conList) {
        ZuoraCallOut contactCallOut = new ZuoraCallOut();
        List<Map<String,String>> returnVarContact = contactCallOut.loadZObjects(conList, 'Contact');
        String contactId;
        for(Map<String,String> resultMapContact :returnVarContact){ 
            if (resultMapContact.get('Status') == 'Success') {
                //TBD
                contactId = resultMapContact.get('Id');
            }
            else {
                //TBD
                system.debug('>>>>>>>>>>>>>>>Failed' + resultMapContact);
            }
        }
        return contactId;
    }
    
    public static List<Map<String, Object>> updateBillingAccount(External_Payment__c extAcc, Map<Id, String> accountIdForUpdate, Map<String, String> contactTypeToZuoraIdMap) {
        Map<String, Object> updateAccountMap = new Map<String, Object>();
        List<Map<String, Object>> lupdateAccountMapList = new List<Map<String, Object>>();
        updateAccountMap.put('Id', accountIdForUpdate.get(extAcc.Billing_Account__r.Zuora__Account__c));
        updateAccountMap.put('Status', 'Active');
            updateAccountMap.put('BillToId', contactTypeToZuoraIdMap.get('Customer Contact'));
            updateAccountMap.put('SoldToId', contactTypeToZuoraIdMap.get('Customer Contact'));
        lupdateAccountMapList.add(updateAccountMap);
        
        return lupdateAccountMapList;
    }

    public static List<Map<String, Object>> ownerTransferAndStopSub(Set<Id> extAmendId, Boolean isTransfer, Map<Id, String> laccIdToNewBillAccZuoraId) {
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        List<External_Payment__c> extAmendList = new List<External_Payment__c>();
        //END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
		
        //START 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks id extAmendId is not empty | Transferred declaration of 'extAmendList' on start of method
        if(extAmendId.size()>0){
            extAmendList = [SELECT Id, Billing_Account__c, Payment_Method__c, Billing_Account__r.Zuora__Account__c, Parent_Transaction_ID__c, Transaction_Amount__c, Transaction_Date__c, PayPal_Email__c, PayPal_BAID__c FROM External_Payment__c WHERE Id IN :extAmendId]; //START-END UD-2806 10/12/2015 Added by K.Tan/J.Sarion - implement retry failure for paypal
        }//END 02/18/2015 - Code Review - Added by Rom Edison Reyes - Checks id extAmendId is not empty
		
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes   
        List<Zuora__Subscription__c> subAmendList = new List<Zuora__Subscription__c>();
        //END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        List<Zuora__Subscription__c> allSubAmendList = new List<Zuora__Subscription__c>();
        List<Map<String, Object>> lamendList = new List<Map<String, Object>>();
        Map<String, Zuora__Subscription__c> pTransIdToSubToZuoraMap = new Map<String, Zuora__Subscription__c>();
        Map<Id, List<Zuora__Subscription__c>> extIdToSubListMap = new Map<Id, List<Zuora__Subscription__c>>();
        Map<Id, Id> amendAccIdToExtIdMap = new Map<Id, Id>();
        Map<String, Object> subStopMap;
        Map<String, Object> subOwnerTransferMap;
        Set<String> extParentTransIdSet = new Set<String>();
        Set<Id> extBillingAccountIdSet = new Set<Id>();
        date d = date.today();
        datetime dt = datetime.newinstance(d.year(), d.month(), d.day());
        string dFormat = (string.valueOf(dt)).replaceAll( '\\s+', 'T');
        
        for (External_Payment__c ext :extAmendList) {
            if (ext.Parent_Transaction_ID__c != null) {
                extParentTransIdSet.add(ext.Parent_Transaction_ID__c);
            }
            else if(ext.Billing_Account__c != null && (ext.Payment_Method__c == 'Credit Card' || (ext.Payment_Method__c == 'PayPal' && ext.PayPal_BAID__c != null && ext.PayPal_BAID__c != ''))) { //START-END UD-2806 10/12/2015 Added by K.Tan/J.Sarion - implement retry failure for paypal
                extBillingAccountIdSet.add(ext.Billing_Account__c);
                amendAccIdToExtIdMap.put(ext.Billing_Account__r.Zuora__Account__c, ext.Id);
            }
        }
        
        if (!extParentTransIdSet.isEmpty()) {
            subAmendList = [SELECT Id, Zuora__Account__c, Zuora__Zuora_Id__c, Parent_Transaction_ID__c FROM Zuora__Subscription__c WHERE Parent_Transaction_ID__c IN :extParentTransIdSet];
            
            for (Zuora__Subscription__c sub :subAmendList) {
                pTransIdToSubToZuoraMap.put(sub.Parent_Transaction_ID__c, sub);
            }
        }
        else if(!extBillingAccountIdSet.isEmpty()) {
            subAmendList = [SELECT Id, Zuora__Account__c, Zuora__Zuora_Id__c, Parent_Transaction_ID__c FROM Zuora__Subscription__c WHERE Zuora__CustomerAccount__c IN :extBillingAccountIdSet AND Zuora__Status__c = 'Active'];
            for (Zuora__Subscription__c sub :subAmendList) {
                if (extIdToSubListMap.containsKey(amendAccIdToExtIdMap.get(sub.Zuora__Account__c))) {
                    extIdToSubListMap.get(amendAccIdToExtIdMap.get(sub.Zuora__Account__c)).add(sub);
                }
                else {
                    extIdToSubListMap.put(amendAccIdToExtIdMap.get(sub.Zuora__Account__c), new List<Zuora__Subscription__c>{sub});
                }
            }
            if (isTransfer) {
                /*Transfer Subscription to the Billing Account with Payment Method Invoice
                */
                for (Zuora__Subscription__c sub :subAmendList) {
                    subOwnerTransferMap = new Map<String, Object>();
                    subOwnerTransferMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, dFormat);
                    subOwnerTransferMap.put(globalvariableclass.DESCRIPTION, 'Subscription Owner Transfer');
                    subOwnerTransferMap.put(globalvariableclass.EFFECTIVE_DATE, dFormat);
                    subOwnerTransferMap.put(globalvariableclass.NAME, 'Subscription Owner Transfer');
                    subOwnerTransferMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
                    subOwnerTransferMap.put(globalvariableclass.SUBSCRIPTION_ID, sub.Zuora__Zuora_Id__c);
                    subOwnerTransferMap.put(globalvariableclass.TYPE, 'OwnerTransfer');
                    subOwnerTransferMap.put('DestinationAccountId', laccIdToNewBillAccZuoraId.get(sub.Zuora__Account__c));
                    
                    //START UD-1544 02-07-2015 Marvin Gatchalian
                    subOwnerTransferMap.put('DestinationInvoiceOwnerId', laccIdToNewBillAccZuoraId.get(sub.Zuora__Account__c));
                    //START UD-1544 02-07-2015 Marvin Gatchalian

                    lamendList.add(subOwnerTransferMap);
                }
            }
        }
		//START UD-2806 11/09/2015 Added by J.Sarion - Commented Subscription Cancellation
		/*
        if (!pTransIdToSubToZuoraMap.isEmpty()) {
            for (External_Payment__c ext :extAmendList) {
                //Zuora Standard Fields. Required for the Cancellation of Subscription
                if (pTransIdToSubToZuoraMap.containsKey(ext.Parent_Transaction_ID__c)) {
                    Zuora__Subscription__c sub = pTransIdToSubToZuoraMap.get(ext.Parent_Transaction_ID__c);
                    allSubAmendList.add(sub);
                }
                
                for (Zuora__Subscription__c sub :allSubAmendList) {
                    subStopMap = new Map<String, Object>();
                    subStopMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, dFormat);
                    subStopMap.put(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
                    subStopMap.put(globalvariableclass.EFFECTIVE_DATE, dFormat);
                    subStopMap.put(globalvariableclass.NAME, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
                    subStopMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
                    subStopMap.put(globalvariableclass.SUBSCRIPTION_ID, sub.Zuora__Zuora_Id__c);
                    subStopMap.put(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
                    lamendList.add(subStopMap);
                }
            }
        }
		*/
		//END UD-2806 11/09/2015 Added by J.Sarion - Commented Subscription Cancellation
        return lamendList;
    }

    public static List<Map<String, Object>> cancelSubscription(Set<String> newSubscriptionZuoraIdSet) {
        Map<String, Object> subStopMap;
        List<Map<String, Object>> lamendList = new List<Map<String, Object>>();
        date d = date.today();
        datetime dt = datetime.newinstance(d.year(), d.month(), d.day());
        string dFormat = (string.valueOf(dt)).replaceAll( '\\s+', 'T');
        
        for (String key : newSubscriptionZuoraIdSet) {
            subStopMap = new Map<String, Object>();
            subStopMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, dFormat);
            subStopMap.put(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
            subStopMap.put(globalvariableclass.EFFECTIVE_DATE, dFormat);
            subStopMap.put(globalvariableclass.NAME, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
            subStopMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
            subStopMap.put(globalvariableclass.SUBSCRIPTION_ID, key);
            subStopMap.put(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
            lamendList.add(subStopMap);
        }
        
        return lamendList;
    }
    
    public void getSubscriptions() {
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        if (parentTransactionIdSet.size()> 0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
             //START D-3236 10-07-2015 Marvin/John
            subList = [SELECT Id, name, Zuora__CustomerAccount__r.Zuora__Account__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Parent_Transaction_ID__c, Main_Package_1__c, Effective_Start_Date__c, New_Contract_Period_1__c, Number_of_Copies__c, Term_Length__c 
                       FROM Zuora__Subscription__c 
                       WHERE Parent_Transaction_ID__c IN :parentTransactionIdSet];
             //END D-3236 10-07-2015 Marvin/John
        }//START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        else if (accIdSet.size()> 0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
            
             //START D-3236 10-07-2015 Marvin/John
            subList = [SELECT Id, name, Zuora__Zuora_Id__c, Zuora__CustomerAccount__r.Zuora__Account__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Parent_Transaction_ID__c, Main_Package_1__c, Effective_Start_Date__c, New_Contract_Period_1__c, Number_of_Copies__c, Term_Length__c 
                       FROM Zuora__Subscription__c 
                       WHERE Zuora__Account__c IN :accIdSet];
             //END D-3236 10-07-2015 Marvin/John
        }
        
        for (Zuora__Subscription__c sub :subList) {
            if (!parentTransactionIdSet.isEmpty()) {
                pTransIdToZuoraIdMap.put(sub.Parent_Transaction_ID__c, sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);
                pTransIdToAcctIdMap.put(sub.Parent_Transaction_ID__c, sub.Zuora__CustomerAccount__r.Zuora__Account__c);
                pTransIdToSubMap.put(sub.Parent_Transaction_ID__c, sub);
            }
            else if (!accIdSet.isEmpty()) {
                if (extIdToSubListMapCC.containsKey(acctIdToExtIdMap.get(sub.Zuora__CustomerAccount__r.Zuora__Account__c))) {
                    extIdToSubListMapCC.get(acctIdToExtIdMap.get(sub.Zuora__CustomerAccount__r.Zuora__Account__c)).add(sub);
                }
                else {
                    extIdToSubListMapCC.put(acctIdToExtIdMap.get(sub.Zuora__CustomerAccount__r.Zuora__Account__c), new List<Zuora__Subscription__c>{sub});
                }
            }
            //START 02/18/2015 Code Review - Rom Edison Reyes - Checks if sub.Main_Package_1__c is not null before adding to packageIdSet
            if(sub.Main_Package_1__c != null){
            packageIdSet.add(sub.Main_Package_1__c);
            }//END 02/18/2015 Code Review - Rom Edison Reyes - Checks if sub.Main_Package_1__c is not null before adding to packageIdSet
            subIdSet.add(sub.Id);
            
            //START D-3236 10-07-2015 Marvin/John
            subNameSet.add(sub.name);
            //END D-3236 10-07-2015 Marvin/John
        }
    }
    
    public void prepareValues() {
        SubscriptionUtil subUtil = new SubscriptionUtil();
        subIdToPubMap = subUtil.subIdToPubListMap(subIdSet);
        
        for (Zuora__Subscription__c sub :subList) {
            if (!subIdSet.isEmpty()) {
                if (subIdToPubMap.containsKey(sub.Id)) {
                    for (Publication__c pub :subIdToPubMap.get(sub.Id)) {
                        if (subIdToEarliestStartDateMap.containsKey(sub.Id)) {
                            if (subIdToEarliestStartDateMap.get(sub.Id) > pub.Earliest_Start_Date__c) {
                                subIdToEarliestStartDateMap.put(sub.Id, pub.Earliest_Start_Date__c);
                            }
                        }
                        else {
                            subIdToEarliestStartDateMap.put(sub.Id, pub.Earliest_Start_Date__c);
                        }
                    }
                }
            }
        }
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        if (subIdSet.size()>0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
            spcList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c FROM Zuora__SubscriptionProductCharge__c  WHERE Zuora__Subscription__c IN :subIdSet];
        }
        
        for(Zuora__SubscriptionProductCharge__c spc : spcList) {
            ratePlanNameSet.add(spc.Zuora__RatePlanName__c);
            subProdChargeMap.put(spc.Zuora__Subscription__c, spc);
        }
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        if (ratePlanNameSet.size()>0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
            ratePlanList = [SELECT id, name, SubscriptionFrequency__c FROM zqu__ProductRatePlan__c  WHERE name IN :ratePlanNameSet];
        }
        
        for(zqu__ProductRatePlan__c ratePlanAccess : ratePlanList){
            ratePlanId.add(ratePlanAccess.id);
            prodRatePlanMap.put(ratePlanAccess.name, ratePlanAccess);
        }
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        if (ratePlanId.size()>0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
            publicationCode = [SELECT publicationcode__c, zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN :ratePlanId];
        }
        
        for(zqu__ProductRatePlanCharge__c pubCodeAccess : publicationCode){
            //START: 02/18/2015 Code Review - Added by Rom Edison Reyes - Checks if pubCodeAccess.publicationcode__c is not null before adding to publicationCodeSet
            if(pubCodeAccess.publicationcode__c != null){
                publicationCodeSet.add(pubCodeAccess.publicationcode__c);
            }//END: 02/18/2015 Code Review - Added by Rom Edison Reyes - Checks if pubCodeAccess.publicationcode__c is not null before adding to publicationCodeSet
            prodRatePlanChargeMap.put(pubCodeAccess.id, pubCodeAccess);
        }
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        if (publicationCodeSet.size()>0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
            publication = [SELECT earliest_start_date__c, publication_code__c FROM publication__c WHERE publication_code__c IN :publicationCodeSet];
        }
        
        for(Publication__c pub : publication){
            publicationMap.put(pub.publication_code__c,pub);
        }
        
        for(Integer counter = publication.size() - 1; counter >= 0; counter--){
            if(publication[counter].publication_code__c == null){
                publication.remove(counter);
            }
        }
        
        for(Zuora__Subscription__c sub : subList){                                                    
            if(subProdChargeMap.containsKey(sub.Id)){
                Zuora__SubscriptionProductCharge__c subProdCharge = subProdChargeMap.get(sub.Id);
                String ratePlan = subProdCharge.Zuora__RatePlanName__c;
                if(prodRatePlanMap.containsKey(subProdCharge.Zuora__RatePlanName__c)){
                    zqu__ProductRatePlan__c prodRatePlan = prodRatePlanMap.get(subProdCharge.Zuora__RatePlanName__c);
                    if(prodRatePlan.SubscriptionFrequency__c == '0'){
                        subIdToDOWPattern.put(sub.Id, 'Default');
                    } else if(prodRatePlan.SubscriptionFrequency__c == '1'){
                        subIdToDOWPattern.put(sub.Id, 'Mon-Fri');
                    } else if(prodRatePlan.SubscriptionFrequency__c == '2'){
                        subIdToDOWPattern.put(sub.Id, 'Fri-Sun');
                    } else if(prodRatePlan.SubscriptionFrequency__c == '3'){
                        subIdToDOWPattern.put(sub.Id, 'Sat-Sun');
                    } else {
                        subIdToDOWPattern.put(sub.Id, '');
                    }
                }
            }
        }
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        if (packageIdSet.size()>0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
            packageList = [SELECT Id, Billing_Type__c, Package_Type__c, Package_Sub_Type__c FROM Package__c WHERE ID IN :packageIdSet];
        }
        
        for (Package__c p :packageList) {
            idToPackageMap.put(p.Id, p);
        }   
    }
    
    public void checkExtIdforSubStop() {
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        if (allExtIdSet.size()>0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
            extList = [SELECT Id, Name, Account_Name__r.Name, Billing_Account__c, Billing_Account__r.Zuora__Account__c, Billing_Account__r.Zuora__Account__r.Name, Payment_Method__c FROM External_Payment__c WHERE Id IN :allExtIdSet];
        }
        //Map of External Payment ID to External Payment Record with related fields
        for (External_Payment__c ext :extList) {
            extIdToExtDetailedMap.put(ext.Id, ext);
            //Payment Method: Credit Card
            if (billingAccountIdSet.contains(ext.Billing_Account__c)) {
                extIdToAccIdMapCC.put(ext.Id, ext.Billing_Account__r.Zuora__Account__c); 
                //START 02/18/2015 - Code Review - Added by Rom Edison Reyes - checks if ext.Billing_Account__r.Zuora__Account__c is not null before adding to accIdSet
                if(ext.Billing_Account__r.Zuora__Account__c != null){
                accIdSet.add(ext.Billing_Account__r.Zuora__Account__c);
                }//END 02/18/2015 - Code Review - Added by Rom Edison Reyes - checks if ext.Billing_Account__r.Zuora__Account__c is not null before adding to accIdSet
                acctIdToExtIdMap.put(ext.Billing_Account__r.Zuora__Account__c, ext.Id);
            }
        }
        //START: Code Review - 02/18/2015 - Added by Rom Edison Reyes
        if (accIdSet.size()>0) {//END: Code Review - 02/18/2015 - Added by Rom Edison Reyes
            billAccList = [SELECT Id, Name, Other_PaymentMethod__c, Zuora__Account__c, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN :accIdSet];
        }
        
        for (Zuora__CustomerAccount__c billAcc :billAccList) {
            if (acctIdToExtIdMap.containsKey(billAcc.Zuora__Account__c)) {
                billAccIdToExtIdMap.put(billAcc.Id, acctIdToExtIdMap.get(billAcc.Zuora__Account__c));
            }
        }
        /*Check Accounts if there are existing Billing Accounts with Payment Method Invoice
        * Account with no existing Billing Accounts with Payment Method Invoice. 
        * Create Set of External Payment Ids for creation of Billing Accounts in Zuora Callout      
        */
        for (Zuora__CustomerAccount__c billAcc :billAccList) {
            if (billAcc.Other_PaymentMethod__c == 'Invoice') {
                if (!accIdWithInvoice.contains(billAcc.Zuora__Account__c)) {
                    accIdWithInvoice.add(billAcc.Zuora__Account__c);
                    accIdToBillAccZuoraId.put(billAcc.Zuora__Account__c, billAcc.Zuora__Zuora_Id__c);
                }
            }
        }
        for (Zuora__CustomerAccount__c billAcc :billAccList) {
            if (!accIdWithInvoice.contains(billAcc.Zuora__Account__c)) {
                if (!extCCIdSet.contains(billAccIdToExtIdMap.get(billAcc.Id))) {
                    extCCIdSet.add(billAccIdToExtIdMap.get(billAcc.Id));
                }
            }
            if (!stopExtIdCCSet.contains(billAccIdToExtIdMap.get(billAcc.Id))) {
                stopExtIdCCSet.add(billAccIdToExtIdMap.get(billAcc.Id));
            }
        }
    }
    
    //START UD-1544 10/07/2015 Added by K.Tan/J.Sarion - get related Invoices
    public static Map<String, Date> getRelatedInvoice(Set<String> zuoraIdSet){
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
        invoiceLineItemList = [Select Invoice_ID__c, Subscription_ID__c From Invoice_Line_Item__c Where Subscription_ID__c IN : zuoraIdSet];
        Map<String, Date> subIdToLatestInvoiceDateMap2 = new Map<String, Date>();
        
        Set<String> invoiceIds = new Set<String>();
        for(Invoice_Line_Item__c ili : invoiceLineItemList) {
            if(ili.Invoice_ID__c != NULL && ili.Invoice_ID__c != '') {
                invoiceIds.add(ili.Invoice_ID__c);
            }
        }
        
        Map<String, Zuora__ZInvoice__c> invoiceMap = new Map<String, Zuora__ZInvoice__c>();
        for(Zuora__ZInvoice__c inv : [SELECT Id, Zuora__TargetDate__c, Zuora__BillingAccount__c, Zuora__Zuora_Id__c
                                        From Zuora__ZInvoice__c 
                                        Where Zuora__Zuora_Id__c IN :invoiceIds 
                                        ORDER by Zuora__TargetDate__c Desc]) {
            invoiceMap.put(inv.Zuora__Zuora_Id__c, inv);
        }
        
        for(Invoice_Line_Item__c ili : invoiceLineItemList) {
            if(invoiceMap.containsKey(ili.Invoice_ID__c)) {
                //subscription already in Map
                if(subIdToLatestInvoiceDateMap2.containsKey(ili.Subscription_ID__c)) {
                    if(invoiceMap.get(ili.Invoice_ID__c).Zuora__TargetDate__c > subIdToLatestInvoiceDateMap2.get(ili.Subscription_ID__c)) 
                    {
                        subIdToLatestInvoiceDateMap2.put(ili.Subscription_ID__c, invoiceMap.get(ili.Invoice_ID__c).Zuora__TargetDate__c);
                    }
                }
                else {
                    subIdToLatestInvoiceDateMap2.put(ili.Subscription_ID__c, invoiceMap.get(ili.Invoice_ID__c).Zuora__TargetDate__c);
                }
            }
        }
        
        return subIdToLatestInvoiceDateMap2;
    }
    //END UD-1544 10/07/2015 Added by K.Tan/J.Sarion - get related Invoices
}