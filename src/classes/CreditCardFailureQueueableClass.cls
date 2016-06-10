/**
* Class Name: <CreditCardFailureQueueableClass>
* @authors: <JaysonSarion>
* Date: <3/21/16>
* Requirement/Project Name: <SPH>
* @description: Implement Credit Card Failure 
* START-END UD-2549 3/22/2016 Createdby J.Sarion
*/

public class CreditCardFailureQueueableClass implements queueable, Database.AllowsCallouts {
    
    //Lists
    List<Usage__c> usageList = new List<Usage__c>();
    
    //Maps
    Map<String, String> subZuoraIdToUomTypeMap = new Map<String, String>();
    Map<String, Zuora__SubscriptionProductCharge__c> spcIdentifierToSpcMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    Map<String, Set<String>> subZuoraIdToPubCodeSetMap = new Map<String, Set<String>>();
    Map<String, String> subZuoraIdToNewBAMap =new Map<String, String>();
    Map<String, String> subZuoraIdToSubNameMap = new Map<String, String>();
    Map<String, String> subNameToNewBAMap = new Map<String, String>();
    Map<String, String> subNameToAccountNumberMap = new Map<String, String>();
    
    //Sets
    public Set<Id> billAccIdSet {get;set;}
    
    public Boolean isBillRun = boolean.valueOf(ConstantsSLB.getKeyId('BILL_RUN_TESTING').toLowerCase());//START-END UD-2549 4/3/2016 Added By J.Sarion - Set Bill Run boolean
    //START UD-2549 4/8/2016 Added by J.Sarion - Set PStop Testing Date
    Date_Configuration__c dateConfig = Date_Configuration__c.getInstance('PAYMENT_FAILURE_TEST_PSTOP_DATE');
    public Date testingPSTOPDate = dateConfig.Date__c;
    //END UD-2549 4/8/2016 Added by J.Sarion - Set PStop Testing Date
    
    public CreditCardFailureQueueableClass(Set<Id> billAccIds) {
        this.billAccIdSet = billAccIds;
    }
      
    public void execute(QueueableContext context){
        //Maps
        Map<String, Set<String>> oldZuoraIdToSubIdSetMap = new Map<String, Set<String>>();
        Map<String, Zuora__CustomerAccount__c> accIdBillTypeToBillAccMap = new Map<String, Zuora__CustomerAccount__c>();
        Map<Id, Contact> conIdToConMap = new Map<Id, Contact>();
        Map<Id, String> accIdToInvZuoraIdMap = new Map<Id, String>();
        Map<String, Set<String>> zuoraIdToSubIdSetMap = new Map<String, Set<String>>();
        //Map<String, Set<String>> zuoraIdToSubIdSetMap2 = new Map<String, Set<String>>();
        //Map<String, Set<String>> zuoraIdToSubIdSetMap3 = new Map<String, Set<String>>();
        Map<String, Map<String, Object>> zuoraIdToNewBAMap = new Map<String, Map<String, Object>>();
        Map<String, Zuora__CustomerAccount__c> billAccZuoraIdToBillAccMap = new Map<String, Zuora__CustomerAccount__c>();
        Map<String, Contact> billAccZuoraIdToContactMap = new Map<String, Contact>();
        //START UD-2549 3/15/2016 Added by J.Sarion - Added Map
        //Map<String, Zuora__Subscription__c> subZuoraIdToSubMap = new Map<String, Zuora__Subscription__c>();
        Map<String, Publication__c> pubCodeToPubMap = new Map<String, Publication__c>();
        Map<String, Date> subZuoraIdToEarliestDateMap = new Map<String, Date>();
        Map<String, Date> subZuoraIdToEarliestDateMap2 = new Map<String, Date>(); //START-END UD-2549 4/3/2016 Added by J.Sarion
        Map<String, Date> subNameToEarliestDateMap = new Map<String, Date>();
        Map<String, Decimal> subZuoraIdToAdminChargeMap = new Map<String, Decimal>();
        Map<String, Zuora__ZInvoice__c> billAccZuoraIdToInvMap = new Map<String, Zuora__ZInvoice__c>();
        Map<String, Object> objMap = new Map<String, Object>();
        Map<Id, String> oliIdToPubIdMap = new Map<Id, String>();
        Map<String, String> billAccZuoraIdToNumberMap = new Map<String, String>();
        //END UD-2549 3/15/2016 Added by J.Sarion - Added Map
        //START D-4672 4/15/2016 Added by J.Sarion
        Map<String, String> iliZuoraIdToSubZuoraIdMap = new Map<String, String>(); //START-END UD-2549 4/6/2016 Added by J.Sarion
        Map<String, Decimal> invIdToAmountMap = new Map<String, Decimal>();
        Map<String, List<Invoice_Line_Item__c>> invIdToIliListMap = new Map<String, List<Invoice_Line_Item__c>>();
        Map<String, Set<String>> invIdToIliIdSetMap = new Map<String, Set<String>>();
        Map<String, List<Zuora.ZObject>> invIdToTaxListMap = new Map<String, List<Zuora.ZObject>>();
        //END D-4672 4/15/2016 Added by J.Sarion
        
        //Sets
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> oldBAZuoraIdSet = new Set<String>();
        //START UD-2549 3/15/2016 Added by J.Sarion - Added set
        Set<Id> subIdSet = new Set<Id>();
        Set<String> subNameSet = new Set<String>();
        Set<String> invoiceZuoraIdSet = new Set<String>();
        Set<String> allPubCodeSet = new Set<String>();
        Set<String> newBillAccZuoraIdSet = new Set<String>();
        //END UD-2549 3/15/2016 Added by J.Sarion - Added set
        //START UD-2549 4/5/2016 Added  by J.Sarion
        Set<String> recPrepaidInvoiceSet = new Set<String>();
        Set<String> invoiceItemIdSet = new Set<String>();
        //END UD-2549 4/5/2016 Added  by J.Sarion
        
        //Lists
        List<Contact> contactList = new List<Contact>();
        List<Zuora__CustomerAccount__c> billAccList = new List<Zuora__CustomerAccount__c>();
        List<Zuora__CustomerAccount__c> existingInvBillAccList = new List<Zuora__CustomerAccount__c>();
        List<Map<String, Object>> amendmentTransferMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> invBAMapList = new List<Map<String, Object>>();
        List<Map<String, String>> resultMapList = new List<Map<String, String>>();
        List<Map<String, String>> resultMapForContactList = new List<Map<String, String>>();
        List<Map<String, Object>> billingContactMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> activateAccountMapList = new List<Map<String, Object>>();
        List<String> oldBAZuoraIdList = new List<String>();
        //START UD-2549 3/15/2016 Added by J.Sarion - Added List
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<Publication__c> pubList = new List<Publication__c>();
        List<Map<String, Object>> amendmentCancelMapList = new List<Map<String, Object>>();
        List<Zuora.zObject> invoiceLineItemList = new List<Zuora.zObject>();
        List<Zuora.zObject> creditBalanceAdjustmentList = new List<Zuora.zObject>();
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        List<Zuora__ZInvoice__c> updatedInvoiceList = new List<Zuora__ZInvoice__c>();
        List<Map<String, Object>> invAdjustmentMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> creditBalanceAdjustmentMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> unpostInvoiceMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> cancelInvoiceMapList = new List<Map<String, Object>>();
        List<Zuora__Subscription__c> subDelList = new List<Zuora__Subscription__c>();
        List<Zuora__Subscription__c> subForCaseCreationList = new List<Zuora__Subscription__c>(); //START-END UD-2549 3/29/2016 Added by J.Sarion
        //END UD-2549 3/15/2016 Added by J.Sarion - Added List
        //START UD-2549 4/5/2016 Added by J.Sarion
        List<Invoice_Line_Item__c> invoiceLineItemSFList = new List<Invoice_Line_Item__c>();
        List<Map<String, Object>> invItemAdjustmentMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> cancelPaymentMapList = new List<Map<String, Object>>();
        //END UD-2549 4/5/2016 Added by J.Sarion
        List<Map<String, Object>> taxItemAdjustmentMapList = new List<Map<String, Object>>(); //START-END UD-2549 4/9/2016 Added by J.Sarion 
        
        //Variables
        String queryStr = '';
        String zoqlString = '';
        Integer x = 0;
        
        //START UD-2549 3/23/2016 Added by J.Sarion - added logger
        Logger logger = new Logger(CreditCardFailureQueueableClass.class.getName());
        
        try {
            ZuoraCallOut zCallout = new ZuoraCallOut();
            
            system.debug('>>>>>billAccIdSet ' + billAccIdSet);
            billAccList = [SELECT Id, Name, Zuora__BillCycleDay__c, Zuora__Currency__c, Zuora__PaymentTerm__c, Zuora__Account__c, Billing_Type__c, Other_PaymentMethod__c, 
                                Zuora__Zuora_Id__c, Billing_Contact__c, Zuora__Default_Payment_Method__r.Zuora__NumConsecutiveFailures__c, (SELECT Id, Name, Zuora__Zuora_Id__c FROM Zuora__Subscriptions__r WHERE Zuora__Status__c = 'Active') 
                           FROM Zuora__CustomerAccount__c 
                           WHERE ID IN: billAccIdSet AND Billing_Type__c != 'Full Prepaid']; //START-END UD-2549 3/15/2016 Added by J.Sarion - Added checking for Billing Type
            system.debug('>>>>>billAccList ' + billAccList);
            for(Zuora__CustomerAccount__c billAcc :billAccList) {
                contactIdSet.add(billAcc.Billing_Contact__c);
                accountIdSet.add(billAcc.Zuora__Account__c);
                billAccZuoraIdToBillAccMap.put(billAcc.Zuora__Zuora_Id__c, billAcc);
                
                for(Zuora__Subscription__c sub :billAcc.Zuora__Subscriptions__r) {
                    subIdSet.add(sub.Id); //START-END UD-2549 3/15/2016 Added by J.Sarion - set map zuora Id to sub
                    subZuoraIdToSubNameMap.put(sub.Zuora__Zuora_Id__c, sub.Name);
                    if(oldZuoraIdToSubIdSetMap.containsKey(billAcc.Zuora__Zuora_Id__c)) {
                        oldZuoraIdToSubIdSetMap.get(billAcc.Zuora__Zuora_Id__c).add(sub.Zuora__Zuora_Id__c);
                    }
                    else {
                        oldZuoraIdToSubIdSetMap.put(billAcc.Zuora__Zuora_Id__c, new Set<String> {sub.Zuora__Zuora_Id__c});
                    }
                }
            }
            
            //START UD-2549 3/15/2016 Added by J.Sarion - set map zuora id to sub
            if(!subIdSet.isEmpty()) {
                subList = [SELECT Id, Name, Zuora__Account__c, Product_Code__c, Main_Package_1__c, Zuora__Zuora_Id__c, Billing_Type__c, Delivered_By__c, 
                                Zuora__SubscriptionEndDate__c, Main_Package_1__r.Package_Type__c, Subscriber_Contact__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c, Subscription_Type_1__c, Order_Line_Item_Number_1__c, Zuora__SubscriptionStartDate__c, (SELECT Id, PublicationCode__c FROM Zuora__Subscription_Product_Charges__r WHERE Zuora__Subscription__r.Subscription_Type_1__c = 'Publication') 
                           FROM Zuora__Subscription__c 
                           WHERE Id IN :subIdSet]; //START-END UD-2549 3/29/2016 Added by J.Sarion
                           
                for(Zuora__Subscription__c sub :subList) {
                    Set<String> pubCodeSet = new Set<String>();
                    
                    subNameSet.add(sub.Name);
                    //subZuoraIdToSubMap.put(sub.Zuora__Zuora_Id__c, sub);
                    
                    if(sub.Subscription_Type_1__c == 'Publication') {
                        subForCaseCreationList.add(sub); //START-END UD-2549 3/29/2016 Added by J.Sarion
                        oliIdToPubIdMap.put(sub.Order_Line_Item_Number_1__c, sub.Zuora__Zuora_Id__c);
                    }
                    
                    for(Zuora__SubscriptionProductCharge__c spc :sub.Zuora__Subscription_Product_Charges__r) {
                        if(spc.PublicationCode__c != null) {
                            pubCodeSet.add(spc.PublicationCode__c);
                            allPubCodeSet.add(spc.PublicationCode__c);
                        }
                    }
                    
                    pubCodeSet.remove(null);
                    subZuoraIdToPubCodeSetMap.put(sub.Zuora__Zuora_Id__c, new Set<String>(pubCodeSet));
                }
            }
            system.debug('>>>>>subZuoraIdToPubCodeSetMap ' + subZuoraIdToPubCodeSetMap);
            system.debug('>>>>>allPubCodeSet ' + allPubCodeSet);
            if(!allPubCodeSet.isEmpty()) {
                pubList = [SELECT Id, Earliest_Start_Date__c, Publication_Code__c 
                           FROM Publication__c 
                           WHERE Publication_Code__c IN :allPubCodeSet];
                           
                for(Publication__c pub :pubList) {
                    pubCodeToPubMap.put(pub.Publication_Code__c, pub);
                }
            }
            system.debug('>>>>>pubCodeToPubMap ' + pubCodeToPubMap);
            //START UD-2549 4/3/2016 Added by J.Sarion - Set cancellation date. Check if for bill run testing
            system.debug('>>>>>isBillRun ' + isBillRun);
            if(!subZuoraIdToPubCodeSetMap.isEmpty()) {
                for(String subZuoraId :subZuoraIdToPubCodeSetMap.keySet()) {
                    List<Date> earliestDateList = new List<Date>();
                    
                    for(String pubCode :subZuoraIdToPubCodeSetMap.get(subZuoraId)) {
                        if(pubCodeToPubMap.containsKey(pubCode)) {
                            system.debug('>>>>>Earliest_Start_Date__c ' + pubCodeToPubMap.get(pubCode).Earliest_Start_Date__c);
                            if(pubCodeToPubMap.get(pubCode).Earliest_Start_Date__c != null) {
                                earliestDateList.add(pubCodeToPubMap.get(pubCode).Earliest_Start_Date__c);
                            }
                        }
                    }
                    system.debug('>>>>>earliestDateList ' + earliestDateList);
                    if(!earliestDateList.isEmpty()) {
                        earliestDateList.sort();
                        subZuoraIdToEarliestDateMap.put(subZuoraId, earliestDateList[0]);
                        subZuoraIdToEarliestDateMap2.put(subZuoraId, earliestDateList[0]);
                        
                        //START UD-2549 4/8/2016 Added by J.Sarion - Set Cancel date from Custom Setting
                        if(isBillRun) {
                            subZuoraIdToEarliestDateMap.put(subZuoraId, testingPSTOPDate);
                            subZuoraIdToEarliestDateMap2.put(subZuoraId, testingPSTOPDate);
                        }
                        //END UD-2549 4/8/2016 Added by J.Sarion - Set Cancel date from Custom Setting
                    }
                    
                    
                }
            }
            
            //START UD-2549 4/8/2016 Added by J.Sarion - commented out
            /*
            if(isBillRun) {
                subZuoraIdToEarliestDateMap = new Map<String, Date>();
                if(!subZuoraIdToPubCodeSetMap.isEmpty()) {
                    subZuoraIdToEarliestDateMap = getRelatedInvoice(subZuoraIdToPubCodeSetMap.keySet());
                }
                system.debug('>>>>>subZuoraIdToEarliestDateMap ' + subZuoraIdToEarliestDateMap);
            }
            */
            //END UD-2549 4/8/2016 Added by J.Sarion - commented out
            //END UD-2549 4/3/2016 Added by J.Sarion - Set cancellation date. Check if for bill run testing
            
            if(!oliIdToPubIdMap.isEmpty()) {
                subDelList = [SELECT Id, Name, Zuora__Zuora_Id__c, Order_Line_Item_Number_1__c 
                              FROM Zuora__Subscription__c 
                              WHERE Order_Line_Item_Number_1__c IN :oliIdToPubIdMap.keySet() AND Subscription_Type_1__c != 'Publication'];
                              
                for(Zuora__Subscription__c sub :subDelList) {
                    if(subZuoraIdToEarliestDateMap.containsKey(oliIdToPubIdMap.get(sub.Order_Line_Item_Number_1__c))) {
                        subZuoraIdToEarliestDateMap.put(sub.Zuora__Zuora_Id__c, subZuoraIdToEarliestDateMap.get(oliIdToPubIdMap.get(sub.Order_Line_Item_Number_1__c)));
                    }
                }
            }
            
            system.debug('>>>>>subNameSet ' + subNameSet);
            system.debug('>>>>>subZuoraIdToEarliestDateMap ' + subZuoraIdToEarliestDateMap);
            queryStr = '';
            zoqlString = '';
            
            for(String subName :subNameSet) {
                queryStr += ' OR SubscriptionNumber=\'' + subName + '\'';
            }
            
            if(queryStr != '') {
                queryStr = queryStr.substring(4);
                queryStr += ' AND ChargeAmount > 0';
                zoqlString = 'SELECT Id, SubscriptionId, InvoiceId FROM InvoiceItem Where ' + queryStr;
                
                invoiceLineItemList = zCallout.bulkQueryZObjects(zoqlString); //START-END UD-2549 3/15/2016 Added by J.Sarion - added params
            }

            system.debug('>>>>>invoiceLineItemList ' + invoiceLineItemList);
            if(!invoiceLineItemList.isEmpty()) {
                for(Zuora.zObject zobj :invoiceLineItemList) {
                    invoiceZuoraIdSet.add((String) zobj.getValue('InvoiceId'));
                }
            }
            system.debug('>>>>>invoiceZuoraIdSet ' + invoiceZuoraIdSet);
            //START UD-2549 4/5/2016 Added by J.Sarion - create Invoice Item adjustment
            if(!invoiceZuoraIdSet.isEmpty()) {
                invoiceList = [SELECT Id, Name, Zuora__BillingAccount__r.Zuora__Zuora_Id__c, Zuora__Zuora_Id__c, Zuora__Balance2__c, Zuora__TotalAmount__c, 
                                    Is_CN_Processed__c, CreatedDate, Zuora__BillingAccount__r.Billing_Type__c, (SELECT Zuora__Payment__r.Zuora__EXT_ID__c, Zuora__Payment__r.Zuora__Type__c FROM Zuora__PaymentInvoices__r WHERE Zuora__Payment__r.Zuora__Status__c = 'Processed') 
                               FROM Zuora__ZInvoice__c 
                               WHERE Zuora__Zuora_Id__c IN :invoiceZuoraIdSet];
                               
                for(Zuora__ZInvoice__c inv :invoiceList) {
                    invIdToAmountMap.put(inv.Zuora__Zuora_Id__c, inv.Zuora__TotalAmount__c); //START-END D-4672 4/15/2016 Added by J.Sarion - Set Invoice Id to Total Amount
                    
                    if(billAccZuoraIdToInvMap.containsKey(inv.Zuora__BillingAccount__r.Zuora__Zuora_Id__c)) {
                        if(billAccZuoraIdToInvMap.get(inv.Zuora__BillingAccount__r.Zuora__Zuora_Id__c).CreatedDate < inv.CreatedDate) {
                            billAccZuoraIdToInvMap.put(inv.Zuora__BillingAccount__r.Zuora__Zuora_Id__c, inv);
                        }
                    }
                    else {
                        billAccZuoraIdToInvMap.put(inv.Zuora__BillingAccount__r.Zuora__Zuora_Id__c, inv);
                    }
                    
                    //START UD-2549 4/5/2016 Added by J.Sarion - Get Recurring Prepaid Invoices
                    if(inv.Zuora__BillingAccount__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE) {
                        recPrepaidInvoiceSet.add(inv.Zuora__Zuora_Id__c);
                    }
                    //END UD-2549 4/5/2016 Added by J.Sarion - Get Recurring Prepaid Invoices
                    
                    //START UD-2549 4/8/2016 Added by J.Sarion - cancel payment if bill run testing
                    if(isBillRun) {
                        for(Zuora__PaymentInvoice__c invPayment :inv.Zuora__PaymentInvoices__r) {
                            objMap = new Map<String, Object>();
                            if(invPayment.Zuora__Payment__r.Zuora__Type__c == 'Electronic') {
                                objMap = cancelPayment(invPayment.Zuora__Payment__r.Zuora__EXT_ID__c, 'Voided');
                                cancelPaymentMapList.add(objMap);
                            }
                            else if(invPayment.Zuora__Payment__r.Zuora__Type__c == 'External') {
                                objMap = cancelPayment(invPayment.Zuora__Payment__r.Zuora__EXT_ID__c, 'Canceled');
                                cancelPaymentMapList.add(objMap);
                            }
                        }
                    }
                    //END UD-2549 4/8/2016 Added by J.Sarion - cancel payment if bill run testing
                }
            }
            
            //START UD-2549 4/8/2016 Added by J.Sarion - Query Invoice Line Item
            if(!invoiceZuoraIdSet.isEmpty()) {
                //START D-4672 4/15/2016 Added by J.Sarion - Create maps for invoie to ili
                invoiceLineItemSFList = [SELECT Id, Charge_Amount__c, Tax_Amount__c, Invoice_ID__c, ID__c, Subscription_ID__c FROM Invoice_Line_Item__c WHERE Invoice_ID__c IN :invoiceZuoraIdSet ORDER BY Charge_Amount__c ASC];
                system.debug('>>>>>invoiceLineItemSFList ' + invoiceLineItemSFList);
                for(Invoice_Line_Item__c ili :invoiceLineItemSFList) {
                    invoiceItemIdSet.add(ili.ID__c);
                    iliZuoraIdToSubZuoraIdMap.put(ili.ID__c, ili.Subscription_ID__c);
                    
                    if(invIdToIliListMap.containsKey(ili.Invoice_ID__c)) {
                        invIdToIliListMap.get(ili.Invoice_ID__c).add(ili);
                    }
                    else {
                        invIdToIliListMap.put(ili.Invoice_ID__c, new List<Invoice_Line_Item__c>{ili});
                    }
                    if(invIdToIliIdSetMap.containsKey(ili.Invoice_ID__c)) {
                        invIdToIliIdSetMap.get(ili.Invoice_ID__c).add(ili.ID__c);
                    }
                    else {
                        invIdToIliIdSetMap.put(ili.Invoice_ID__c, new Set<String>{ili.ID__c});
                    }
                    
                    //START D-4672 4/15/2016 Added by J.Sarion - Commented out
                    /*
                    if(ili.Charge_Amount__c > 0) {
                        objMap = new Map<String, Object>();
                        objMap = createInvAdjMap(ili.Invoice_ID__c, ili.ID__c, 'InvoiceDetail', 'Credit', ili.Charge_Amount__c, (isBillRun ? subZuoraIdToEarliestDateMap.get(ili.Subscription_ID__c) : Date.Today()));
                        invItemAdjustmentMapList.add(objMap);
                    }
                    else if(ili.Charge_Amount__c < 0) {
                        objMap = new Map<String, Object>();
                        objMap = createInvAdjMap(ili.Invoice_ID__c, ili.ID__c, 'InvoiceDetail', 'Charge', ili.Charge_Amount__c, (isBillRun ? subZuoraIdToEarliestDateMap.get(ili.Subscription_ID__c) : Date.Today()));
                        invItemAdjustmentMapList.add(objMap);
                    }
                    */
                    //END D-4672 4/15/2016 Added by J.Sarion - Commented out
                }
                //END D-4672 4/15/2016 Added by J.Sarion - Create maps for invoie to ili
            }
            //END UD-2549 4/8/2016 Added by J.Sarion - Query Invoice Line Item
            
            queryStr = '';
            zoqlString = '';
            
            //START D-4672 4/18/2016 Added by J.Sarion - Change query to InvoiceId
            for(String invoiceId :invoiceZuoraIdSet) {
                queryStr += ' OR InvoiceId=\'' + invoiceId + '\'';
            }
            //END D-4672 4/18/2016 Added by J.Sarion - Change query to InvoiceId
            system.debug('>>>>>queryStr ' + queryStr);
            if(queryStr != '') {
                queryStr = queryStr.substring(4);
                zoqlString = 'SELECT Id, TaxAmount, InvoiceItemId, InvoiceId FROM TaxationItem Where ' + queryStr;
                system.debug('>>>>>zoqlString ' + zoqlString);
                List<Zuora.ZObject> taxationItemList = zCallout.bulkQueryZObjects(zoqlString); //START-END UD-2549 3/15/2016 Added by J.Sarion - added params
                system.debug('>>>>>taxationItemList ' + taxationItemList);
                
                for(Zuora.ZObject zobj :taxationItemList) {
                    //START D-4672 4/15/2016 Added by J.Sarion - Commented out
                    if(invIdToTaxListMap.containsKey((String) zobj.getValue('InvoiceId'))) {
                        invIdToTaxListMap.get((String) zobj.getValue('InvoiceId')).add(zobj);
                    }
                    else {
                        invIdToTaxListMap.put((String) zobj.getValue('InvoiceId'), new List<Zuora.ZObject>{zobj});
                    }
                    
                    if(invIdToIliIdSetMap.containsKey((String) zobj.getValue('InvoiceId'))) {
                        invIdToIliIdSetMap.get((String) zobj.getValue('InvoiceId')).add((String) zobj.getValue('Id'));
                    }
                    else {
                        invIdToIliIdSetMap.put((String) zobj.getValue('InvoiceId'), new Set<String>{(String) zobj.getValue('Id')});
                    }
                    
                    /*
                    if(((Decimal) zobj.getValue('TaxAmount')) > 0) {
                        objMap = new Map<String, Object>();
                        objMap = createInvAdjMap((String) zobj.getValue('InvoiceId'), (String) zobj.getValue('Id'), 'Tax', 'Credit', (Decimal) zobj.getValue('TaxAmount'), (isBillRun ? subZuoraIdToEarliestDateMap.get(iliZuoraIdToSubZuoraIdMap.get((String) zobj.getValue('InvoiceItemId'))) : Date.Today()));
                        taxItemAdjustmentMapList.add(objMap); //START-END UD-2549 4/9/2016 Added by J.Sarion - Set to different list
                    }
                    //START UD-2549 4/9/2016 Added by J.Sarion - For Negative amount
                    else if(((Decimal) zobj.getValue('TaxAmount')) < 0) {
                        objMap = new Map<String, Object>();
                        objMap = createInvAdjMap((String) zobj.getValue('InvoiceId'), (String) zobj.getValue('Id'), 'Tax', 'Charge', (Decimal) zobj.getValue('TaxAmount'), (isBillRun ? subZuoraIdToEarliestDateMap.get(iliZuoraIdToSubZuoraIdMap.get((String) zobj.getValue('InvoiceItemId'))) : Date.Today()));
                        taxItemAdjustmentMapList.add(objMap); //START-END UD-2549 4/9/2016 Added by J.Sarion - Set to different list
                    }
                    //END UD-2549 4/9/2016 Added by J.Sarion - For Negative amount
                    */
                    //END D-4672 4/15/2016 Added by J.Sarion - Commented out
                }
            }
            
            //START D-4672 4/15/2016 Added by J.Sarion - Adjust Invoice Line Items
            for(String invId :invIdToIliListMap.keySet()) {
                Set<String> iliIdSet = new Set<String>();
                iliIdSet = invIdToIliIdSetMap.get(invId);
                Decimal invoiceAmount = invIdToAmountMap.get(invId);
                Decimal totalBal = invIdToAmountMap.get(invId);
                Boolean isNotZero = true;
                system.debug('>>>>>totalBal ' + totalBal);
                system.debug('>>>>>iliIdSet ' + iliIdSet.size());
                while(isNotZero && !iliIdSet.isEmpty()) {
                    if(!iliIdSet.isEmpty()) {
                        for(Invoice_Line_Item__c ili :invIdToIliListMap.get(invId)) {
                            Decimal chargeAmount = Math.Abs(ili.Charge_Amount__c);
                            if(iliIdSet.contains(ili.ID__c)) {
                                if(ili.Charge_Amount__c > 0) {
                                    if(totalBal - chargeAmount >= 0 ) {
                                        totalBal = totalBal - chargeAmount;
                                        iliIdSet.remove(ili.ID__c);
                                        objMap = new Map<String, Object>();
                                        objMap = createInvAdjMap(ili.Invoice_ID__c, ili.ID__c, 'InvoiceDetail', 'Credit', chargeAmount, (isBillRun ? subZuoraIdToEarliestDateMap.get(ili.Subscription_ID__c) : Date.Today()));
                                        invItemAdjustmentMapList.add(objMap);
                                        system.debug('>>>>>ili.Charge_Amount__c ' + ili.Charge_Amount__c);
                                    }
                                }
                                else if(ili.Charge_Amount__c < 0) {
                                    if(totalBal + chargeAmount >= 0 && totalBal + chargeAmount <= invoiceAmount) {
                                        totalBal = totalBal + chargeAmount;
                                        iliIdSet.remove(ili.ID__c);
                                        objMap = new Map<String, Object>();
                                        objMap = createInvAdjMap(ili.Invoice_ID__c, ili.ID__c, 'InvoiceDetail', 'Charge', chargeAmount, (isBillRun ? subZuoraIdToEarliestDateMap.get(ili.Subscription_ID__c) : Date.Today()));
                                        invItemAdjustmentMapList.add(objMap);
                                        system.debug('>>>>>ili.Charge_Amount__c ' + ili.Charge_Amount__c);
                                    }
                                }
                                system.debug('>>>>>totalBal ' + totalBal);
                            }
                        }
                        
                        for(Zuora.ZObject zobj :invIdToTaxListMap.get(invId)) {
                            Decimal taxAmount = (Decimal) zobj.getValue('TaxAmount');
                            Decimal taxAmountAbs = Math.Abs((Decimal) zobj.getValue('TaxAmount'));
                            String taxItemId = (String) zobj.getValue('Id');
                            
                            if(iliIdSet.contains(taxItemId)) {
                                if(taxAmount > 0) {
                                    if(totalBal - taxAmountAbs >= 0) {
                                        totalBal = totalBal - taxAmountAbs;
                                        iliIdSet.remove(taxItemId);
                                        objMap = new Map<String, Object>();
                                        objMap = createInvAdjMap((String) zobj.getValue('InvoiceId'), (String) zobj.getValue('Id'), 'Tax', 'Credit', taxAmountAbs, (isBillRun ? subZuoraIdToEarliestDateMap.get(iliZuoraIdToSubZuoraIdMap.get((String) zobj.getValue('InvoiceItemId'))) : Date.Today()));
                                        invItemAdjustmentMapList.add(objMap);
                                        system.debug('>>>>>taxAmount ' + taxAmount);
                                    }
                                }
                                else if(taxAmount < 0) {
                                    if(totalBal + taxAmountAbs >= 0 && totalBal + taxAmountAbs <= invoiceAmount) {
                                        totalBal = totalBal + taxAmountAbs;
                                        iliIdSet.remove(taxItemId);
                                        objMap = new Map<String, Object>();
                                        objMap = createInvAdjMap((String) zobj.getValue('InvoiceId'), (String) zobj.getValue('Id'), 'Tax', 'Charge', taxAmountAbs, (isBillRun ? subZuoraIdToEarliestDateMap.get(iliZuoraIdToSubZuoraIdMap.get((String) zobj.getValue('InvoiceItemId'))) : Date.Today()));
                                        invItemAdjustmentMapList.add(objMap);
                                        system.debug('>>>>>taxAmount ' + taxAmount);
                                    }
                                }
                            }
                        }
                        
                        system.debug('>>>>>iliIdSet ' + iliIdSet.size());
                        system.debug('>>>>>iliIdSet ' + iliIdSet);
                        system.debug('>>>>>totalBal ' + totalBal);
                        system.debug('>>>>>isNotZero ' + isNotZero);
                        if(totalBal == 0) {
                            isNotZero = false;
                        }
                    }
                }
            }
            //END D-4672 4/15/2016 Added by J.Sarion - Adjust Invoice Line Items
            
            system.debug('>>>>>invItemAdjustmentMapList ' + invItemAdjustmentMapList);
            system.debug('>>>>>taxItemAdjustmentMapList ' + taxItemAdjustmentMapList);
            queryStr = '';
            zoqlString = '';
            
            //END UD-2549 4/5/2016 Added by J.Sarion - create Invoice Item adjustment
            if(!billAccZuoraIdToInvMap.isEmpty()) {
                for(Zuora__ZInvoice__c inv :billAccZuoraIdToInvMap.values()) {
                    //START UD-2549 4/5/2016 Added by J.Sarion - Set InvoicePaymentFailure__c to Y
                    inv.Is_CN_Processed__c  = false;
                    
                    //START UD-2549 4/10/2016 Added by J.Sarion - commented out and 
                    objMap = new Map<String, Object>();
                    objMap = updateInvoice(inv.Zuora__Zuora_Id__c);
                    unpostInvoiceMapList.add(objMap); //reuse unpostInvoiceMapList for a single zuora callout
                    system.debug('>>>>>objMap ' + objMap);
                    
                    /*
                    if(inv.Zuora__BillingAccount__r.Billing_Type__c == 'Recurring Prepaid') {                        
                        objMap = new Map<String, Object>();
                        objMap = updateInvoice(inv.Zuora__Zuora_Id__c);
                        unpostInvoiceMapList.add(objMap); //reuse unpostInvoiceMapList for a single zuora callout
                        system.debug('>>>>>objMap ' + objMap);
                    }
                    else if(inv.Zuora__BillingAccount__r.Billing_Type__c == 'Recurring Postpaid') {
                        inv.Zuora__Status__c = 'Cancelled';
                        
                        //START UD-2549 4/8/2016 Added by J.Sarion - commented out
                        
                        objMap = new Map<String, Object>();
                        objMap = unpostInvoice(inv.Zuora__Zuora_Id__c);
                        unpostInvoiceMapList.add(objMap);
                        system.debug('>>>>>objMap ' + objMap);
                        
                        objMap = new Map<String, Object>();
                        objMap = cancelInvoice(inv.Zuora__Zuora_Id__c);
                        cancelInvoiceMapList.add(objMap);
                        system.debug('>>>>>objMap ' + objMap);
                        
                        //END UD-2549 4/8/2016 Added by J.Sarion - commented out
                    }
                    */
                    //END UD-2549 4/10/2016 Added by J.Sarion - commented out
                    
                    if(inv.Zuora__TotalAmount__c != inv.Zuora__Balance2__c) {
                        queryStr += ' OR SourceTransactionId=\'' + inv.Zuora__Zuora_Id__c + '\'';
                    }
                    
                    updatedInvoiceList.add(inv);
                    //END UD-2549 4/5/2016 Added by J.Sarion - Set InvoicePaymentFailure__c to Y
                }
            }
            
            if(queryStr != '') {
                queryStr = queryStr.substring(4);
                zoqlString = 'SELECT Id FROM CreditBalanceAdjustment Where ' + queryStr;
                
                creditBalanceAdjustmentList = zCallOut.bulkQueryZObjects(zoqlString);
                system.debug('>>>>>creditBalanceAdjustmentList ' + creditBalanceAdjustmentList);
                if(!creditBalanceAdjustmentList.isEmpty()) {
                    for(Zuora.zObject zobj :creditBalanceAdjustmentList) {
                        objMap =new Map<String, Object>();
                        objMap = cancelCreditBalAdjMap((String) zobj.getValue('Id'));
                        
                        creditBalanceAdjustmentMapList.add(objMap);
                    }
                }
            }
            system.debug('>>>>>creditBalanceAdjustmentMapList ' + creditBalanceAdjustmentMapList);
            if(!creditBalanceAdjustmentMapList.isEmpty()) {
                resultMapList =  new List<Map<String, String>>();
                resultMapList = zCallOut.updateZObjects(creditBalanceAdjustmentMapList, 'CreditBalanceAdjustment');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            
            //START UD-2549 4/5/2016 Added by J.Sarion - create invoice item adjustment
            if(!cancelPaymentMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                resultMapList = zCallOut.updateZObjects(cancelPaymentMapList, 'Payment');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            
            //START D-4672 4/15/2016 Added by J.Sarion - commented out
            //START UD-2549 4/9/2016 Added by J.Sarion - create taxation item adjustment first before invoice item
            /*
            if(!taxItemAdjustmentMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                resultMapList = zCallOut.loadZObjects(taxItemAdjustmentMapList, 'InvoiceItemAdjustment');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            */
            //END UD-2549 4/9/2016 Added by J.Sarion - create taxation item adjustment first before invoice item
            //END D-4672 4/15/2016 Added by J.Sarion - commented out
            
            if(!invItemAdjustmentMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                resultMapList = zCallOut.loadZObjects(invItemAdjustmentMapList, 'InvoiceItemAdjustment');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            //END UD-2549 4/5/2016 Added by J.Sarion - create invoice item adjustment
            
            if(!unpostInvoiceMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                resultMapList = zCallOut.updateZObjects(unpostInvoiceMapList, 'Invoice');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            
            if(!cancelInvoiceMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                resultMapList = zCallOut.updateZObjects(cancelInvoiceMapList, 'Invoice');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            //END UD-2549 3/15/2016 Added by J.Sarion - set map zuora id to sub
            
            if(!contactIdSet.isEmpty()) {
                conIdToConMap = new Map<Id, Contact>([SELECT Id, Name, AccountId, MailingCountry, FirstName, 
                                                            LastName, Email, Mailing_Address__c, City_Code__c, Address__r.Postal_Code__r.Name, 
                                                            Address__r.City__r.City_Name__c 
                                                      FROM Contact 
                                                      WHERE Id IN: contactIdSet]);
            }
            
            if(!accountIdSet.isEmpty()) {
                existingInvBillAccList = [SELECT Id, Name, Zuora__Account__c, Billing_Contact__c, Billing_Type__c, Other_PaymentMethod__c, Payment_Mode__c, ARMS_Account_Number__c, ARMS_ID__c, 
                                            ARMS_Business_Profile__c, ARMS_Debt_Management__c, ARMS_Customer_Number__c,Zuora__Zuora_Id__c, Zuora__PaymentTerm__c, Zuora__BillCycleDay__c, 
                                            Zuora__Currency__c 
                                          FROM Zuora__CustomerAccount__c 
                                          WHERE Zuora__Account__c IN: accountIdSet AND Payment_Mode__c = 'Other' AND Other_PaymentMethod__c = 'Invoice'];
                
                for(Zuora__CustomerAccount__c billAcc :existingInvBillAccList) {
                    String ref = 'Id=' + billAcc.Zuora__Account__c + ';BillingType=' + billAcc.Billing_Type__c;
                    accIdBillTypeToBillAccMap.put(ref, billAcc);
                    billAccZuoraIdToBillAccMap.put(billAcc.Zuora__Zuora_Id__c, billAcc);
                    
                    if(!accIdToInvZuoraIdMap.containsKey(billAcc.Zuora__Account__c)) {
                        accIdToInvZuoraIdMap.put(billAcc.Zuora__Account__c, billAcc.Zuora__Zuora_Id__c);
                    }
                }
            }
            system.debug('>>>>>accIdBillTypeToBillAccMap ' + accIdBillTypeToBillAccMap);
            system.debug('>>>>>billAccList ' + billAccList);
            system.debug('>>>>>accIdToInvZuoraIdMap ' + accIdToInvZuoraIdMap);
            system.debug('>>>>>billAccZuoraIdToBillAccMap ' + billAccZuoraIdToBillAccMap);
            for(Zuora__CustomerAccount__c billAcc :billAccList) {
                String ref = 'Id=' + billAcc.Zuora__Account__c + ';BillingType=' + billAcc.Billing_Type__c;
                
                if(conIdToConMap.containsKey(billAcc.Billing_Contact__c)) {
                    billAccZuoraIdToContactMap.put(billAcc.Zuora__Zuora_Id__c, conIdToConMap.get(billAcc.Billing_Contact__c));
                }
                
                if(accIdBillTypeToBillAccMap.containsKey(ref)) {
                    if(oldZuoraIdToSubIdSetMap.containsKey(billAcc.Zuora__Zuora_Id__c)) {
                        zuoraIdToSubIdSetMap.put(accIdBillTypeToBillAccMap.get(ref).Zuora__Zuora_Id__c, new Set<String>(oldZuoraIdToSubIdSetMap.get(billAcc.Zuora__Zuora_Id__c)));
                    }
                }
                else {
                    if(accIdToInvZuoraIdMap.containsKey(billAcc.Zuora__Account__c)) {
                        if(oldZuoraIdToSubIdSetMap.containsKey(billAcc.Zuora__Zuora_Id__c)) {
                            system.debug('>>>>>billAcc.Zuora__Account__c ' + billAcc.Zuora__Account__c);
                            //zuoraIdToSubIdSetMap2.put(billAcc.Zuora__Zuora_Id__c, new Set<String>(oldZuoraIdToSubIdSetMap.get(billAcc.Zuora__Zuora_Id__c)));
                            zuoraIdToNewBAMap.put(billAcc.Zuora__Zuora_Id__c, new Map<String, Object>(createInvoiceBA(billAcc, billAccZuoraIdToBillAccMap.get(accIdToInvZuoraIdMap.get(billAcc.Zuora__Account__c)).Zuora__PaymentTerm__c)));
                            //zuoraIdToNewBAMap.put(billAcc.Zuora__Zuora_Id__c, new Map<String, Object>(createInvoiceBA(billAcc), billAccZuoraIdToBillAccMap.get(accIdToInvZuoraIdMap.get(billAcc.Zuora__Account__c)).Zuora__PaymentTerm__c));
                            oldBAZuoraIdSet.add(billAcc.Zuora__Zuora_Id__c);
                        }
                    }
                    else {
                        if(oldZuoraIdToSubIdSetMap.containsKey(billAcc.Zuora__Zuora_Id__c)) {
                            //zuoraIdToSubIdSetMap3.put(billAcc.Zuora__Zuora_Id__c, new Set<String>(oldZuoraIdToSubIdSetMap.get(billAcc.Zuora__Zuora_Id__c)));
                            zuoraIdToNewBAMap.put(billAcc.Zuora__Zuora_Id__c, new Map<String, Object>(createInvoiceBA(billAcc, null)));
                            oldBAZuoraIdSet.add(billAcc.Zuora__Zuora_Id__c);
                        }
                    }
                }
            }
            
            if(!oldBAZuoraIdSet.isEmpty()) {
                oldBAZuoraIdList.addAll(oldBAZuoraIdSet);
            }
            system.debug('>>>>>zuoraIdToNewBAMap ' + zuoraIdToNewBAMap);
            if(!zuoraIdToNewBAMap.isEmpty()) {
                for(String zuoraId :zuoraIdToNewBAMap.keySet()) {
                    invBAMapList.add(zuoraIdToNewBAMap.get(zuoraId));
                }
            }
            system.debug('>>>>>invBAMapList ' + invBAMapList);
            if(!invBAMapList.isEmpty()) {
                resultMapList = zCallout.loadZObjects(invBAMapList, 'Account');
                
                x = 0;
                for(Map<String, String> resultMap :resultMapList) {         
                    if(billAccZuoraIdToContactMap.containsKey(oldBAZuoraIdList[x])) {
                        billingContactMapList.add(createContactBilling(billAccZuoraIdToContactMap.get(oldBAZuoraIdList[x]), resultMap.get('Id')));
                    }
                    
                    if(resultMap.get('Status') == 'Success') {
                        amendmentTransferMapList.addAll(createTransferAmendments(oldZuoraIdToSubIdSetMap.get(oldBAZuoraIdList[x]), resultMap.get('Id')));
                    }
                    else if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                    
                    x++;
                }
            }
            system.debug('>>>>>invBAMapList ' + invBAMapList);
            system.debug('>>>>>resultMapList ' + resultMapList);
            system.debug('>>>>>amendmentTransferMapList ' + amendmentTransferMapList);
            if(!billingContactMapList.isEmpty()) {
                resultMapForContactList = zCallout.loadZObjects(billingContactMapList, 'Contact');
                
                x = 0;
                for(Map<String, String> resultMap :resultMapForContactList) {               
                    if(resultMap.get('Status') == 'Success') {
                        activateAccountMapList.add(activateAccount(resultMapList[x].get('Id'), resultMap.get('Id'), billAccZuoraIdToBillAccMap.get(oldBAZuoraIdList[x]).Zuora__Account__c));
                    }
                    else if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                    
                    x++; //START-END UD-2549 3/15/2016 Added by J.Sarion - counter
                }
            }
            system.debug('>>>>>billingContactMapList ' + billingContactMapList);
            system.debug('>>>>>resultMapForContactList ' + resultMapForContactList);
            system.debug('>>>>>activateAccountMapList ' + activateAccountMapList);
            if(!activateAccountMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                
                resultMapList = zCallout.updateZObjects(activateAccountMapList, 'Account');
                
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            system.debug('>>>>>zuoraIdToSubIdSetMap ' + zuoraIdToSubIdSetMap);
            if(!zuoraIdToSubIdSetMap.isEmpty()) {
                for(String zuoraId :zuoraIdToSubIdSetMap.keySet()) {
                    amendmentTransferMapList.addAll(createTransferAmendments(zuoraIdToSubIdSetMap.get(zuoraId), zuoraId));
                }
            }
            system.debug('>>>>>amendmentTransferMapList ' + amendmentTransferMapList);
            if(!amendmentTransferMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                
                resultMapList = zCallout.amendZObjects(amendmentTransferMapList);
                system.debug('>>>>>resultMapList ' + resultMapList);
                x = 0;
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') == 'Success') {
                        objMap = new Map<String, Object>();
                        objMap = amendmentTransferMapList[x];
                        
                        newBillAccZuoraIdSet.add((String) objMap.get('DestinationAccountId'));
                        system.debug('>>>>>subId ' + objMap.get(GlobalVariableClass.SUBSCRIPTION_ID));
                        system.debug('>>>>>resultMap ' + resultMap.get('SubId'));
                        amendmentCancelMapList.add(createCancelAmendment((String) resultMap.get('SubId'), subZuoraIdToEarliestDateMap.get((String) objMap.get(GlobalVariableClass.SUBSCRIPTION_ID))));
                        
                        if(subZuoraIdToSubNameMap.containsKey((String) objMap.get(GlobalVariableClass.SUBSCRIPTION_ID))) {
                            subNameToNewBAMap.put(subZuoraIdToSubNameMap.get((String) objMap.get(GlobalVariableClass.SUBSCRIPTION_ID)), (String) objMap.get('DestinationAccountId'));
                        }
                    }
                    else if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                    x++;
                }
            }
            system.debug('>>>>>newBillAccZuoraIdSet ' + newBillAccZuoraIdSet);
            if(!newBillAccZuoraIdSet.isEmpty()) {
                List<Zuora.zObject> zuoraAccountList = new List<Zuora.zObject>();
                
                zuoraAccountList = zCallOut.bulkQueryForAccount(newBillAccZuoraIdSet);
                
                for(Zuora.zObject zobj :zuoraAccountList) {
                    billAccZuoraIdToNumberMap.put((String) zobj.getValue('Id'), (String) zobj.getValue('AccountNumber'));
                }
            }
            system.debug('>>>>>billAccZuoraIdToNumberMap ' + billAccZuoraIdToNumberMap);
            if(!subNameToNewBAMap.isEmpty()) {
                for(String subName :subNameToNewBAMap.keySet()) {
                    if(billAccZuoraIdToNumberMap.containsKey(subNameToNewBAMap.get(subName))) {
                        subNameToAccountNumberMap.put(subName, billAccZuoraIdToNumberMap.get(subNameToNewBAMap.get(subName)));
                    }
                }
            }
            system.debug('>>>>>subNameToAccountNumberMap ' + subNameToAccountNumberMap);
            system.debug('>>>>>subNameToNewBAMap ' + subNameToNewBAMap);
            if(!subZuoraIdToEarliestDateMap.isEmpty()) {
                subZuoraIdToAdminChargeMap = AdminFeeComputation.computeAdminChargeBulk(subZuoraIdToEarliestDateMap);
                system.debug('>>>>>subZuoraIdToEarliestDateMap ' + subZuoraIdToEarliestDateMap);
                usageDataPrep(subZuoraIdToEarliestDateMap2); //START-END UD-2549 4/3/2016 Added by J.Sarion
            
                if(!subZuoraIdToAdminChargeMap.isEmpty()) {
                    AdminCharge_Amendment adminChargeCall = new AdminCharge_Amendment();
                    List<Map<String, Object>> adminChargeMapList = adminChargeCall.bulkAdminChargeAmendment(subZuoraIdToAdminChargeMap, subZuoraIdToEarliestDateMap);
                
                    if(!adminChargeMapList.isEmpty()) {
                        resultMapList = new List<Map<String, String>>();
                    
                        resultMapList = zCallout.amendZObjects(adminChargeMapList);
                        system.debug('>>>>>resultMapList ' + resultMapList);
                        for(Map<String, String> resultMap :resultMapList) {
                            if(resultMap.get('Status') != 'Success') {
                                logger.log(false, resultMap.get('Message'));
                            }
                        }
                    }
                }
            }
            
            if(!amendmentCancelMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                
                resultMapList = zCallout.amendZObjects(amendmentCancelMapList);
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            
            if(!usageList.isEmpty()) {
                try{
                    database.insert(usageList, false);
                }
                catch(Exception e) {
                    system.debug('>>>>>error ' + e);
                    logger.log(e);
                }
                
            }
            
            if(!updatedInvoiceList.isEmpty()) {
                try{
                    database.update(updatedInvoiceList, false);
                }
                catch(Exception e) {
                    system.debug('>>>>>error ' + e);
                    logger.log(e);
                }
            }
            
            //START UD-2549 3/29/2016 Added by J.Sarion - change param
            //START UD-2549 3/23/2016 Added by J.Sarion - create case, order, and order line item
            if(!subForCaseCreationList.isEmpty()) {
                system.debug('>>>>>subForCaseCreationList ' + subForCaseCreationList);
                BulkStopOrderCreationHandler bulkStop = new BulkStopOrderCreationHandler();
                map<id, id> subscriptionId_caseId = new map<id, id>();
                subscriptionId_caseId = bulkStop.createRelatedRecords(subForCaseCreationList);
            }
            //END UD-2549 3/23/2016 Added by J.Sarion - create case, order, and order line item
            //END UD-2549 3/29/2016 Added by J.Sarion - change param
            
            system.debug('>>>>>usageList ' + usageList);
            system.debug('>>>>>updatedInvoiceList ' + updatedInvoiceList);
        }
        catch(Exception e) {
            logger.log(e);
        }
        logger.save();
        //END UD-2549 3/23/2016 Added by J.Sarion - added logger
    }
    
        //START UD-2549 4/5/2016 Added by J.Sarion - create invoice item adjustment
    public static Map<String, Object> createInvAdjMap(String invoiceId, String sourceId, String srcType, String Type, Decimal amount, Date adjustmentDate){
        Map<String, Object> invoiceAdjustmentMap = new Map<String, Object>();
        //START UD-2549 4/6/2016 Added by J.Sarion - check null
        String adjustmentZuoraDate = '';
        if(adjustmentDate != null) {
            adjustmentZuoraDate = zuora.zUtil.getZuoraDate(adjustmentDate);
        }
        //END UD-2549 4/6/2016 Added by J.Sarion - check null
        
        //invoiceAdjustmentMap.put('AccountId', ili.Zuora__BillingAccount__r.Zuora__Zuora_Id__c); // not available in create call
        invoiceAdjustmentMap.put('InvoiceId', invoiceId);
        invoiceAdjustmentMap.put('SourceId', sourceId);
        invoiceAdjustmentMap.put('SourceType', srcType);
        invoiceAdjustmentMap.put('Type', Type);
        invoiceAdjustmentMap.put('AdjustmentDate', adjustmentZuoraDate);
        invoiceAdjustmentMap.put('Amount', amount);
        //if(invZuoraIdToCaseNumberMap.containsKey(inv.Zuora__Zuora_Id__c)) {
            //invoiceAdjustmentMap.put('ReferenceId', invZuoraIdToCaseNumberMap.get(inv.Zuora__Zuora_Id__c));
        //}
        invoiceAdjustmentMap.put('Comment', 'Payment failure - Credit card / Paypal');
        //END UD-2549 4/5/2016 Added by J.Sarion - create invoice item adjustment
        
        return invoiceAdjustmentMap;
    }
    
    public static Map<String, Object> cancelCreditBalAdjMap(String invZuoraId){
        Map<String, Object> creditBalAdjustmentMap = new Map<String, Object>();
        
        creditBalAdjustmentMap.put('Id', invZuoraId);
        creditBalAdjustmentMap.put('Status', 'Canceled');
        
        return creditBalAdjustmentMap;
    }
    
    public static Map<String, Object> unpostInvoice(String invZuoraId){
        Map<String, Object> unpostInvoiceMap = new Map<String, Object>();
        
        unpostInvoiceMap.put('Id', invZuoraId);
        unpostInvoiceMap.put('Status', 'Draft');
        unpostInvoiceMap.put('InvoicePaymentFailure__c', 'Y'); //START-END UD-2549 4/5/2016 Added by J.Sarion
        
        return unpostInvoiceMap;
    }
    
    //START UD-2549 4/5/2016 Added by J.Sarion - set InvoicePaymentFailure__c to Y
    public static Map<String, Object> updateInvoice(String invZuoraId){
        Map<String, Object> updateInvoiceMap = new Map<String, Object>();
        
        updateInvoiceMap.put('Id', invZuoraId);
        updateInvoiceMap.put('InvoicePaymentFailure__c', 'Y');
        
        return updateInvoiceMap;
    }
    
    public static Map<String, Object> cancelPayment(String paymentId, String status){
        Map<String, Object> cancelPaymentMap = new Map<String, Object>();
        
        cancelPaymentMap.put('Id', paymentId);
        cancelPaymentMap.put('Status', status);
        
        return cancelPaymentMap;
    }
    //END UD-2549 4/5/2016 Added by J.Sarion - set InvoicePaymentFailure__c to Y
    
    public static Map<String, Object> cancelInvoice(String invZuoraId){
        Map<String, Object> cancelInvoiceMap = new Map<String, Object>();
        
        cancelInvoiceMap.put('Id', invZuoraId);
        cancelInvoiceMap.put('Status', 'Canceled');
        
        return cancelInvoiceMap;
    }
    
    //START UD-3863
    public static Map<String, Object> createInvoiceBA(Zuora__CustomerAccount__c billAcc, String paymentTerm) {
        final String PMTHD_INV_ID = ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other');
        Map<String, Object> billAccMap = new Map<String, Object>();
        
        system.debug('>>>>>billAcc ' + billAcc);
        
        billAccMap.put('BillCycleDay',billAcc.Zuora__BillCycleDay__c);
        billAccMap.put('Currency',billAcc.Zuora__Currency__c );
        billAccMap.put('Name', billAcc.Name );
        if(paymentTerm != null) {
            billAccMap.put('PaymentTerm', paymentTerm);
        }
        else {
            billAccMap.put('PaymentTerm', 'Net 15');
        }
        billAccMap.put('Status','Draft');
        billAccMap.put('Batch', ConstantsSLB.getKeyId('Batch Number'));
        billAccMap.put('CrmId', billAcc.Zuora__Account__c );
        billAccMap.put('DefaultPaymentMethodId', PMTHD_INV_ID);
        billAccMap.put('Billing_Type__c', billAcc.Billing_Type__c);
        billAccMap.put('Other_PaymentMethod__c', 'Invoice');
        billAccMap.put('Link_Prev_Billing_Contact__c', billAcc.Billing_Contact__c);
        
        system.debug('>>>>>billAccMap ' + billAccMap);
       return billAccMap;
    }
    
    public static Map<String, Object> createContactBilling(Contact con, String zuoraId){
        Map<String, Object> billingContactMap = new Map<String, Object>();
        
        billingContactMap.put('AccountId', zuoraId);
        billingContactMap.put('Country',con.MailingCountry );
        billingContactMap.put('FirstName',con.FirstName );
        billingContactMap.put('LastName',con.LastName);                              
        billingContactMap.put('WorkEmail',con.Email);
        billingContactMap.put('City', con.Address__r.City__r.City_Name__c);
        billingContactMap.put('PostalCode', con.Address__r.Postal_Code__r.Name);
        system.debug('>>>>>billingContactMap ' + billingContactMap);
        return billingContactMap;
    }
    
    public static List<Map<String, Object>> createTransferAmendments(Set<String> subZuoraIdSet, String BAZuoraId) {
        List<Map<String, Object>> amendmentMapList = new List<Map<String, Object>>();
        Map<String,Object> amendmentMap;
        String startDate = ''; //START UD-2549 4/8/2016 Added by J.Sarion
        startDate = zuora.zUtil.getZuoraDate(date.today());

        system.debug('=====Before Loop SelectedSubscription====>>');
        for(String subZuoraId: subZuoraIdSet)
        {                       
            system.debug('=====Inside Loop SelectedSubscription====>>');
            amendmentMap = new Map<String, Object>();
            amendmentMap.put('Code', null);
            amendmentMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, startDate);
            amendmentMap.put(globalvariableclass.DESCRIPTION, 'Subscription Owner Transfer');
            amendmentMap.put(globalvariableclass.EFFECTIVE_DATE, startDate);
            amendmentMap.put(globalvariableclass.NAME, 'Subscription Owner Transfer');
            amendmentMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
            amendmentMap.put(globalvariableclass.SUBSCRIPTION_ID, subZuoraId);
            amendmentMap.put(globalvariableclass.TYPE, 'OwnerTransfer');
            amendmentMap.put('DestinationAccountId', BAZuoraId);
            amendmentMap.put('DestinationInvoiceOwnerId', BAZuoraId);
            amendmentMapList.add(amendmentMap);
        }
        
        return amendmentMapList;
    }
    
    //START UD-2549 3/15/2016 Added by J.Sarion - Create Cancel Amendment
    public static Map<String, Object> createCancelAmendment(String subZuoraId, Date stopDate) {
        Map<String,Object> amendmentMap = new Map<String, Object>();
        //START UD-2549 4/6/2016 - avoid empty
        String stopZuoraDate = '';
        if(stopDate != null) {
            stopZuoraDate = zuora.zUtil.getZuoraDate(stopDate);
        }
        //END UD-2549 4/6/2016 - avoid empty
        
        system.debug('=====Inside Loop SelectedSubscription====>>');
        amendmentMap = new Map<String, Object>();
        amendmentMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, stopZuoraDate);
        amendmentMap.put(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
        amendmentMap.put(globalvariableclass.EFFECTIVE_DATE, stopZuoraDate);
        amendmentMap.put(globalvariableclass.NAME, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
        amendmentMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
        amendmentMap.put(globalvariableclass.SUBSCRIPTION_ID, subZuoraId);
        amendmentMap.put(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
        system.debug('>>>>>createCancelAmendment ' + amendmentMap);
        
        return amendmentMap;
    }
    //END UD-2549 3/15/2016 Added by J.Sarion - Create Cancel Amendment
    
    public static Map<String, Object> activateAccount(String billAccZuoraId, String billConZuoraId, String accountId){
        Map<String,Object> activateBillAccMap = new Map<String,Object>();
        
        activateBillAccMap.put('Id', billAccZuoraId);
        activateBillAccMap.put('Status', 'Active');
        activateBillAccMap.put('BillToId', billConZuoraId);
        activateBillAccMap.put('SoldToId', billConZuoraId);
        activateBillAccMap.put('CrmId', accountId);
        activateBillAccMap.put('Batch', ConstantsSLB.getKeyId('Batch Number'));
        
        return activateBillAccMap;
    }
    
    public void usageDataPrep(Map<String, Date> subZuoraIdToStopDate) {
        //Variables
        final String COPY_USAGE = 'Copy';
        final String ISSUE_USAGE = 'Issue';
        Date usageStartDate;
        Date usageEndDate;
        String usageType;
        system.debug('>>>>>subZuoraIdToStopDate ' + subZuoraIdToStopDate);
        //Lists
        List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        
        //Sets
        Set<Usage__c> usageSet = new Set<Usage__c>();
        
        UsageHelper.initialize();
        
        subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,Frequency_1__c, Grace_End_Date__c, Zuora__Status__c, Zuora__SubscriptionStartDate__c, 
                        Zuora__SubscriptionEndDate__c, Number_of_Copies__c, Billing_Type__c, Grace_Period_Subscription__c, Grace_Days__c, 
                        Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c, 
                        Zuora__TermSettingType__c, Term_Length__c, Zuora__Zuora_Id__c 
                   FROM Zuora__Subscription__c 
                   WHERE Zuora__Zuora_Id__c IN :subZuoraIdToStopDate.keySet() AND Subscription_Type_1__c = 'Publication'];
        
        spcList = [SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name,Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c, 
                        Zuora__Subscription__c, PublicationCode__c, Zuora__Subscription__r.Zuora__Zuora_Id__c, Zuora__Subscription__r.Billing_Type__c
                   FROM Zuora__SubscriptionProductCharge__c 
                   WHERE Zuora__Type__c = 'Usage' AND Zuora__Subscription__r.Zuora__Zuora_Id__c IN :subZuoraIdToStopDate.keySet() AND Zuora__Subscription__r.Subscription_Type_1__c = 'Publication'];
        system.debug('>>>>>test2');
        system.debug('>>>>>subList ' + subList);
        system.debug('>>>>>spcList ' + spcList);
        for(Zuora__SubscriptionProductCharge__c spc :spcList) {         
            if(spc.PublicationCode__c != null) {
                if(subZuoraIdToPubCodeSetMap.get(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c) == null) { //START-END UD-2549 4/8/2016 Added by J.Sarion - Set Zuora Id
                    subZuoraIdToPubCodeSetMap.put(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c, new Set<String>());
                }
                subZuoraIdToPubCodeSetMap.get(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c).add(spc.PublicationCode__c);
                
                if(spc.Zuora__Subscription__r.Billing_Type__c == 'Recurring Prepaid') {
                    spcIdentifierToSpcMap.put(generateSpcIndentifierKey(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c, spc.Zuora__UOM__c, spc.PublicationCode__c), spc);
                }
                else if(spc.Zuora__Subscription__r.Billing_Type__c == 'Recurring Postpaid') {
                    spcIdentifierToSpcMap.put(generateSpcIndentifierKey(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c, spc.Zuora__UOM__c, spc.PublicationCode__c), spc);
                }
            }
        }
        system.debug('>>>>>spcList ' + spcList);
        system.debug('>>>>>spcIdentifierToSpcMap ' + spcIdentifierToSpcMap);
        system.debug('>>>>>test1');
        for(Zuora__Subscription__c sub :subList) {
            //START UD-2549 3/29/2016 Added by J.Sarion - Set usageStartDate to Sub Start Date if it's first payment failure
            if(sub.Zuora__SubscriptionStartDate__c.monthsBetween(subZuoraIdToStopDate.get(sub.Zuora__Zuora_Id__c)) == 1) {
                usageStartDate = sub.Zuora__SubscriptionStartDate__c;
            }
            else {
                //START UD-2549 4/8/2016 Added by J.Sarion - set usage Start Date
                usageStartDate = subZuoraIdToStopDate.get(sub.Zuora__Zuora_Id__c).toStartOfMonth(); //for Recurring Prepaid
                if(sub.Billing_Type__c == 'Recurring Postpaid') {
                    usageStartDate = subZuoraIdToStopDate.get(sub.Zuora__Zuora_Id__c).addMonths(-1).toStartOfMonth();
                }
                //END UD-2549 4/8/2016 Added by J.Sarion - set usage Start Date
            }
            usageEndDate = subZuoraIdToStopDate.get(sub.Zuora__Zuora_Id__c).addDays(-1);
            //END UD-2549 3/29/2016 Added by J.Sarion - Set usageStartDate to Sub Start Date if it's first payment failure
            
            if(sub.Billing_Type__c == 'Recurring Prepaid') {
                subZuoraIdToUomTypeMap.put(sub.Zuora__Zuora_Id__c, COPY_USAGE);
            }
            else if(sub.Billing_Type__c == 'Recurring Postpaid') {
                subZuoraIdToUomTypeMap.put(sub.Zuora__Zuora_Id__c, ISSUE_USAGE);
            }
            system.debug('>>>>>usageStartDate ' + usageStartDate);
            system.debug('>>>>>usageEndDate ' + usageEndDate);
            createUsageFirst(sub, usageStartDate, usageEndDate);
        }
        system.debug('>>>>>test');
    }
    
    public void createUsageFirst (Zuora__Subscription__c sub, Date startDate, Date endDate) { 
        PublicationIssueWrapper pubIssueWrapperObject;
        if (subZuoraIdToPubCodeSetMap.containsKey(sub.Zuora__Zuora_Id__c)) {
            for (String pubCode :subZuoraIdToPubCodeSetMap.get(sub.Zuora__Zuora_Id__c)) {
                pubIssueWrapperObject = UsageHelper.IssueCalculation(pubCode, startDate, endDate, sub, Integer.valueOf(sub.Number_of_Copies__c));
                system.debug('>>>>>pubIssueWrapperObject ' + pubIssueWrapperObject);
                createUsagePrep(sub, pubIssueWrapperObject.weekday_no_of_copies, 'Weekday', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.sat_no_of_copies, 'Sat', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.sun_no_of_copies, 'Sun', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Online', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Smartphone', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Tablet', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Online', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Smartphone', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Tablet', endDate, pubCode);
            }
        }
    }
    
    public void createUsagePrep (Zuora__Subscription__c sub, Integer quantity, String uom, Date usageDate, String pubCode) {             
        Usage__c usage = new Usage__c();
        usage = createUsage(sub, quantity, uom, usageDate, pubCode);
        
        if (usage.Quantity__c != 0 && usage != null)
            usageList.add(usage);
    }
    
    private Usage__c createUsage (Zuora__Subscription__c sub, Integer quantity, String uom, Date usageDate, String pubCode) {
        String spcIdentifier = generateSpcIndentifierKey(sub.Zuora__Zuora_Id__c, subZuoraIdToUomTypeMap.get(sub.Zuora__Zuora_Id__c) + ' ' + uom, pubCode);
        system.debug('>>>>>spcIdentifier ' + spcIdentifier);
        Usage__c usage = new Usage__c();
        system.debug('>>>>>spcIdentifier ' + spcIdentifierToSpcMap.containsKey(spcIdentifier));
        if (spcIdentifierToSpcMap.containsKey(spcIdentifier)) {
            Zuora__SubscriptionProductCharge__c spc = spcIdentifierToSpcMap.get(spcIdentifier);

            if(subNameToAccountNumberMap.containsKey(sub.Name)) {
                usage.Account_Id__c = subNameToAccountNumberMap.get(sub.Name);
            }
            usage.Subscription_Id__c = sub.Name;
            usage.End_Date__c = usageDate;
            usage.Status__c = UsageHelper.USAGE_STATUS;
            usage.UOM__c = spc.Zuora__UOM__c;
            usage.Rate_Plan_Charge_Id__c = spc.Zuora__ChargeNumber__c;                 
            usage.Publication_Code__c = spc.PublicationCode__c;
            usage.Quantity__c = quantity;
            
            if(sub.Billing_Type__c == 'Recurring Prepaid') {
                usage.Usage_Type__c = UsageHelper.USAGE_TYPE_RECURRING_PREPAID_STOP;
            }
            else if(sub.Billing_Type__c == 'Recurring Postpaid') {
                usage.Usage_Type__c = 'RecurringPostpaid_Stop';
            }
            
            usage.Start_Date__c = usageDate.toStartOfMonth();
            
            usage.StopType__c = 'PStop';
        }
        return usage;
    }
    
    public static string generateSpcIndentifierKey(string subscriptionId, string uom, String pubCode) {
        return subscriptionId + ' ' + uom + ' ' + pubCode;
    }
    
    //START UD-2549 4/3/2016 Added by J.Sarion - get latest invoiceAdjustmentMap
    /*
    * Name: getRelatedInvoice
    * Param: Set<String> of Subscription Zuora Ids
    * Return: Map<String, Date> of Subscription Zuora Id to Latest Invoice Target Date
    * Description: Get lates invoice target date per subscription
    */
    public static Map<String, Date> getRelatedInvoice(Set<String> zuoraIdSet){
        //Lists
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
        
        //Maps
        Map<String, Zuora__ZInvoice__c> invoiceMap = new Map<String, Zuora__ZInvoice__c>();
        Map<String, Date> subIdToLatestInvoiceDateMap2 = new Map<String, Date>();
        
        //Sets
        Set<String> invoiceIds = new Set<String>();
        
        invoiceLineItemList = [Select Invoice_ID__c, Subscription_ID__c, CreatedDate From Invoice_Line_Item__c Where Subscription_ID__c IN : zuoraIdSet AND CreatedDate >= LAST_90_DAYS];
        
        for(Invoice_Line_Item__c ili : invoiceLineItemList) {
            if(ili.Invoice_ID__c != NULL && ili.Invoice_ID__c != '') {
                invoiceIds.add(ili.Invoice_ID__c);
            }
        }
        
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
    //END UD-2549 4/3/2016 Added by J.Sarion - get latest invoiceAdjustmentMap
}