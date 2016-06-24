/**
* Class Name: <invoiceProcessForStopSubscription>
* @authors: <Rom Edison Reyes>
* Date: <03/17/2015>
* Requirement/Project Name: <SPH>
* @description: 
        * Generate Invoice for Stop Subscriptions.
* History: 01/08/15 D-1592 Wenjun: Add support for Postage Charges and also fix Usage Bugs
*/

public class InvoiceProcessForStopSubscription {
    
    /*START: D-812 12/06/14 Added by J.Sarion – Charge Usage to the Billing Account.
    * Generate Invoice for Recurring Subscriptions.
    * Create Payment for the Invoice.
    */
    public static Set<Id> lsubIdSet = new Set<Id>();        
    //START UD-3002 12/10/2015 Added by J.Sarion - Record Type Id for Direct Corporate
    public static Id ACCOUNT_DIRECTCORPORATE = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRCORP);
    //END UD-3002 12/10/2015 Added by J.Sarion - Record Type Id for Direct Corporate    

    //START UD-3002 12/11/2015 Added by J.Sarion - added Boolean for calling createBillRun method if from Start
    public static Boolean isStart = false;
    //END UD-3002 12/11/2015 Added by J.Sarion - added Boolean for calling createBillRun method if from Start
    
    public void callInvoice(Set<Id> subIdSet) {
        invoicePaymentProcess(subIdSet);
    }
    
    //START UD-1595 6/23/15 AddedBy FBenzon/JTeves : Call START process for Recurring Subscriptions subject to COS
    @future
    //START UD-3676 RReyes - Bulkify, changed parameter to orderIdSet
    public static void callCosQueueableClass(Set<Id> orderIdSet) {
        //system.debug(':::callCosQueueableClass' + ' ' + orderId);
        Id jobID = System.enqueueJob(new SM_ChangeOfSubStartStopProcess(orderIdSet));
    }
    //END UD-3676 RReyes - Bulkify, changed parameter to orderIdSet
    //END UD-1595 6/23/15 AddedBy FBenzon/JTeves : Call START process for Recurring Subscriptions subject to COS
    
    
    // START D-3236 11-07-2015 Marvin/John - Rolling back to its original structure
    // START UD-1544 Marvin/John
    /* @future(callout=true)
    public static void loadUsagesAndGeneratenvoice(Set<Id> subIdSet, Set<Id> UsagesIDs) {
        //List<Usage__c> usageList = new List<Usage__c>();
        //UsageHelper.loadUniqueUsages(usageList,false);
        UsageHelper.isByPassUsageUpdateInSFDC = true;
        
        UsageHelper.sentToZuoraCalloutNonFuture(UsagesIDs);
        invoicePaymentProcessNonFuture(subIdSet);
        
        try {
            Database.update(UsageHelper.usageListForUpdateInSFDC, false);               
        } catch (exception e) {
            ExceptionLogger.log(new list<exception> { e });
        }
        
        UsageHelper.isByPassUsageUpdateInSFDC = false;
        UsageHelper.usageListForUpdateInSFDC = new list<Usage__c>();
    } */
    
    
    @future(callout=true)
    public static void invoicePaymentProcess(Set<Id> subIdSet) {
        invoicePaymentProcessNonFuture(subIdSet);     
    }
    // END UD-1544 Marvin/John
    static Logger logger;  //Start-END K. Tan 1/4/2016 UD-3433 
    // START UD-1544 Marvin/John
    public static void invoicePaymentProcessNonFuture(Set<Id> subIdSet) {
        logger = new Logger(InvoiceProcessForStopSubscription.class.getName()); //START END UD-2854 08/Oct/15 Wenjun : Error Logging //Start-END K. Tan 1/4/2016 UD-3433 
        
        if(subIdSet.contains(null)) {
            subIdSet.remove(null);
        }
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c>();
        Map<String, Object> updateInvoiceMap;
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        List<Zuora.zObject> zobjs = new List<Zuora.zObject>();
        List<Map<String, Object>> usageMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> invoiceMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> paymentMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> updateInvoiceMapList = new List<Map<String, Object>>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<Map<String, Object>> negativeInvoiceMapList = new List<Map<String, Object>>(); //START/END D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
        Set<String> paymentZuoraIdSet = new Set<String>();
        Set<String> invoiceIdSet = new Set<String>();
        Set<String> updateInvoiceIdSet = new Set<String>();
        Order_Line_Item__c oli = new Order_Line_Item__c();
        String invoiceZuoraId;
        String updateInvoiceZuoraId;
        String zoql;
        ZuoraCallOut zCallOut; //START END UD-2854 08/Oct/15 Wenjun: Perform initialisation in try catch block for error handling
        
        //START UD-3002 12/10/2015 Added by J.Sarion - Set of Ids for Direct Corporate
        Set<Id> directCorpSubIdSet = new Set<Id>();
        //END UD-3002 12/10/2015 Added by J.Sarion - Set of Ids for Direct Corporate
 
        //START 01/08/15 D-1592 Wenjun : Query Main Package ID, Subscription Type 
        //START UD-1595 6/18/15 AddedBy Fritz/Jeff : query orders of new Subscriptions related to Stopped Subscriptions for COS
        List<Order__c> orderRec = new List<Order__c>();
        Set<String> orderTypes = new Set<String>();
        orderTypes.add('Change of Subscription Quantity');
        orderTypes.add('Change of Subscription Package');
        String orderStatNew = 'New';
        String orderStatDraft = 'Draft';
        String orderStatClose = 'Close';//START/END UD-3676 01/20/16 RReyes
        //START UD-3337 16Dec15 FrancisBenzon : list of accts to update
        List<Account> acctsToUpdate = new List<Account>();
        //END UD-3337 16Dec15 FrancisBenzon : list of accts to update
        //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates -- added Account__C, Billing_Type__c field in query
        //START UD-3676 RReyes 01/20/16 - exclude orders with direct corporate accounts, added filter where status != close
        orderRec = [Select Id, Name, Account__c, Billing_Type__c From Order__c Where Subscription__c IN :subIdSet AND Account__r.RecordTypeId !=: ACCOUNT_DIRECTCORPORATE AND Order_Type__c IN :orderTypes AND Status__c != :orderStatNew AND Status__c != :orderStatDraft AND Status__c != :orderStatClose];
        //END UD-3676 RReyes 01/20/16 - exclude orders with direct corporate accounts, added filter where status != close
        //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        //END UD-1595 6/18/15 AddedBy Fritz/Jeff : query orders of new Subscriptions related to Stopped Subscriptions for COS
        
        //START UD-3002 12/10/2015 Added by J.Sarion - Added Account Record Type
        subList = [SELECT Id, Name, Order_Number_1__c, Order_Line_Item_Number_1__c, Zuora__SubscriptionStartDate__c, Main_Package_1__c, 
                   Subscription_Type_1__c, Zuora__Zuora_Id__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Term_Length__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__Account__r.RecordTypeId
                   FROM Zuora__Subscription__c WHERE Id IN : subIdSet];
        //END UD-3002 12/10/2015 Added by J.Sarion - Added Account Record Type
        //END 01/08/15 D-1592 Wenjun
        
        for (Zuora__Subscription__c sub :subList) {
            //START UD-3002 12/10/2015 Added by J.Sarion - Check account if not Direct Corporate
            if(sub.Zuora__Account__r.RecordTypeId != ACCOUNT_DIRECTCORPORATE) {
                lsubIdSet.add(sub.Id);
            }
            else {
                directCorpSubIdSet.add(sub.Id);
            }
            //END UD-3002 12/10/2015 Added by J.Sarion - Check account if not Direct Corporate
        }
        
        if (!orderIdSet.isEmpty()) {
            orderIdToOrderMap = new Map<Id, Order__c>([SELECT Id, Recipient_Type__c, Delivery_Charge_Type__c FROM Order__c WHERE Id IN :orderIdSet]);
        }
        
        system.debug('>>>>>>>>>>>>>>lsubIdSet' + lsubIdSet);
        if (!lsubIdSet.isEmpty()) {
            system.debug('>>>>>>>>>>>>>>Generate Invoice');
            invoiceMapList = generateInvoice(lsubIdSet);
        }
        
        //START UD-3002 12/11/2015 Added by J.Sarion - Create Bill Run record in Zuora for Accounts with large number of Subscriptions e.g. Direct Corporate
        if(!directCorpSubIdSet.isEmpty()) {
            createBillRun(directCorpSubIdSet);
        }
        //END UD-3002 12/11/2015 Added by J.Sarion - Create Bill Run record in Zuora for Accounts with large number of Subscriptions e.g. Direct Corporate

        //actual callout
        //START UD-2854 08/Oct/15 Wenjun : Error Logging
        if (!invoiceMapList.isEmpty()) {
            try
            {
                zCallOut = new ZuoraCallOut(); 
                List<Map<String,String>> results = zCallOut.generateInvoiceList(invoiceMapList);
                system.debug('>>>>>results ' + results);
                for (Map<String,String> resultMap :results) {           
                    if (resultMap.get('Status') == 'Success') {
                        invoiceZuoraId = resultMap.get('Id');
                        invoiceIdSet.add(invoiceZuoraId);
                    }
                    else {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            catch (Exception e)
            {
                logger.log(e);
            }
        }
        //END UD-2854 08/Oct/15 Wenjun : Error Logging
        
        //prepare map to post invoices
        if (!invoiceIdSet.isEmpty()) {
            for (String invoiceId :invoiceIdSet) {
                updateInvoiceMap = new Map<String, Object>();
                
                updateInvoiceMap.put('Id', invoiceId);
                updateInvoiceMap.put('Status', 'Posted');
                updateInvoiceMapList.add(updateInvoiceMap);
            }
        }
        
        //callout to post invoices
        //START UD-2854 08/Oct/15 Wenjun : Error Logging
        if (!updateInvoiceMapList.isEmpty()) {
            try
            {
                List<Map<String,String>> results = zCallOut.updateZObjects(updateInvoiceMapList, 'Invoice');
                for (Map<String,String> resultMap :results) {           
                    if (resultMap.get('Status') == 'Success') {
                        updateInvoiceZuoraId = resultMap.get('Id');
                        updateInvoiceIdSet.add(updateInvoiceZuoraId);
                    }
                    else {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            catch (Exception e)
            {
                logger.log(e);
            }
        }
        //END UD-2854 08/Oct/15 Wenjun : Error Logging
        //START UD-0790 4/22/2015 Added by Manolo Valena - Callout to create Credit Balance Adjustment records in Zuora.
        //String invRecordId; //START/END UD-3676 01/25/16 RReyes - commented out - not needed anymore
        Map<String, Object> toAdjust;
        List<Map<String, Object>> listToAdjust = new List<Map<String, Object>>();
        Decimal negOne = -1.00;
        
        //START UD-3676 01/25/16 RReyes - commented out - not needed anymore
        /*for(String inv : updateInvoiceIdSet) {
            invRecordId = inv;
            break;
        } */                             
        //END UD-3676 01/25/16 RReyes - commented out - not needed anymore
        //START UD-3002 12/15/2015 Added by J.Sarion - check if null
        List<Zuora.zObject> lZInvoice = new List<Zuora.zObject>();
        //START UD-3676 RReyes - 01/20/16 Bulkify
        if(!updateInvoiceIdSet.isEmpty()) {
            lZInvoice = zCallOut.bulkQueryInvoices(updateInvoiceIdSet);
        }
        //END UD-3676 RReyes - 01/20/16 Bulkify
        //END UD-3002 12/15/2015 Added by J.Sarion - check if null
        
        //START UD-2854 10/03/15 RReyes - Credit balance shall be increased only if the invoice amount < 0
        for(Zuora.zObject zOb : lZInvoice) {
            if(Decimal.valueOf(String.valueOf(zOb.getValue('Amount'))) < 0){
                toAdjust = new Map<String, Object>();
                Decimal amount;
                
                toAdjust.put('Type', 'Increase');
                toAdjust.put('SourceTransactionNumber', zOb.getValue('InvoiceNumber'));
                amount = math.abs(Decimal.valueOf(String.valueOf(zOb.getValue('Amount'))));
                toAdjust.put('Amount', amount);
                toAdjust.put('ReferenceId', zOb.getValue('Id'));
                listToAdjust.add(toAdjust);
                
                //START D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
                Map<String, Object> invoiceMap = new Map<String, Object>();         
                invoiceMap.put('Id', zOb.getValue('Id'));
                invoiceMap.put('Immediate_CB__c', 'Y');
                negativeInvoiceMapList.add(invoiceMap);
                //END D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
            }
        }
        
        if(!listToAdjust.isEmpty())
        {
            try
            {
                List<Map<String,String>> results = zCallOut.bulkCreateZObjects(listToAdjust, 'CreditBalanceAdjustment');

                for (Map<String,String> resultMap :results) {           
                    if (resultMap.get('Status') != 'Success') 
                        logger.log(false, resultMap.get('Message'));
                }
            }
            catch (Exception e)
            {
                logger.log(e);
            }
        }
        //END UD-2854 10/03/15 RReyes
        //END UD-0790 4/22/2015 Added by Manolo Valena
        
        //START D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
        //START 11 March 2016 UD-3247 Kevin Evasco - Immediate CB to true for Negative Invoices
        try{
            invoicePostProcessingForDirectCorp.updateInvoiceImmediateCB(negativeInvoiceMapList);
        }catch(Exception e){
            logger.log(e);
        }
        //END 11 March 2016 UD-3247 Kevin Evasco - Immediate CB to true for Negative Invoices
        //END D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
        
        //START UD-3337 16Dec15 FrancisBenzon : bulkify
        //START UD-1595 AddedBy FrancisBenzon : call Queueable class for sending of quotes for new Subs
        //Assumption for COS: no bulk creation
        if(orderRec.size() > 0)
        {
            //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            /*Account accToUpd = new Account(Id = orderRec[0].Account__c);
            accToUpd.Billing_Type__c = SM_SubscriptionHelper.getBillingTypeForBA(orderRec[0].Billing_Type__c);
            UPDATE accToUpd;
            //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            system.debug(':::INVOICESTOPORDER' + ' ' + orderRec[0].Id);
            Id jobID = System.enqueueJob(new SM_ChangeOfSubStartStopProcess(orderRec[0].Id));*/
            for(Order__c thisOrder : orderRec)
            {
                Account accToUpd = new Account(Id = thisOrder.Account__c);
                accToUpd.Billing_Type__c = SM_SubscriptionHelper.getBillingTypeForBA(thisOrder.Billing_Type__c);
                acctsToUpdate.add(accToUpd);                
            }
            if(acctsToUpdate.size() > 0)
            {
                try
                {
                    update acctsToUpdate;
                }
                catch(exception e) {
                    logger.log(e);
                }
            }       
            
            //START UD-3676 01/21/16 RReyes - bulkify, changed parameter from thisOrder.id to orderIds
            Set<Id> orderIds = new Set<Id>();
            for(Order__c thisOrder : orderRec)
            {
                orderIds.add(thisOrder.Id);
                //Id jobID = System.enqueueJob(new SM_ChangeOfSubStartStopProcess(orderRec));
            }
            if(!orderIds.isEmpty()){
                Id jobID = System.enqueueJob(new SM_ChangeOfSubStartStopProcess(orderIds));
            }
            //END UD-3676 01/21/16 RReyes - bulkify, changed parameter from thisOrder.id to orderIds
        }        
        //END UD-1595 AddedBy FrancisBenzon : call Queueable class for sending of quotes for new Subs
        //END UD-3337 16Dec15 FrancisBenzon : bulkify
        
        logger.save(); //START END UD-2854 08/Oct/15 Wenjun : Error Logging
    }
    // END UD-1544 Marvin/John
    // END D-3236 11-07-2015 Marvin/John - Rolling back to its original structure

    public static List<Map<String, Object>> generateInvoice(Set<Id> subIdSet) {
        //START 02/18/2015 JTeves - Code Optimization - Removal of NULL value in Query Filter Sets
        if(subIdSet.contains(null)) {
            subIdSet.remove(null);
        }
        //END 02/18/2015 JTeves - Code Optimization
        //ZuoraCallOut zCallOut = new ZuoraCallOut(); //START END UD-2854 08/Oct/15 Wenjun : Not in use
        List<Map<String, Object>> invoiceMapList = new List<Map<String, Object>>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Map<String, Object> invoiceMap;
        Set<Id> billAccIdSet = new Set<Id>();
        String invoiceZuoraId;
        //START UD-2854 08/Oct/15 Wenjun : Code Optimization to use Zuora Date
        /*
        Date d = system.today();
        string dFormat = (string.valueOf(d)) + 'T00:00:00'; 
        String sadFormat;
        String targetFormat;
        */
        //END UD-2854 08/Oct/15 Wenjun
        
        //START: D-2734 4/15/15 J. Teves â€“ add Zuora__SubscriptionEndDate__c in Query
        //START UD-1595 AddedBy FrancisBenzon : added customer acct in query
        subList = [SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE Id IN :subIdSet];
        //END UD-1595 AddedBy FrancisBenzon : added customer acct in query
        //END: D-2734 4/15/15 J. Teves
        for (Zuora__Subscription__c sub : subList) {
            if (!billAccIdSet.contains(sub.Zuora__CustomerAccount__c)) {
                invoiceMap = new Map<String, Object>();
                //Date serviceActivationDate; //START END UD-2854 08/Oct/15 Wenjun : Not in use
                //Date startDate; //START END UD-2854 08/Oct/15 Wenjun : Not in use
                Date targetDate;
                
                //START: D-2734 4/15/15 J. Teves â€“ set Invoice target date to Subscription Cancellation date.
                //targetDate = date.newinstance(Date.today().year(), Date.today().month()+1, 1);
                //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates -- set target date as Sub End Date + 1
                targetDate = sub.Zuora__SubscriptionEndDate__c.addDays(1);
                //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
                //targetFormat = string.valueOf(targetDate) + 'T00:00:00';//START/END UD-2854 08/Oct/15 Wenjun : Not in use
                //END: D-2734 4/15/15 J. Teves
                
                //START UD-2854 08/Oct/15 Wenjun : Not in use
                /*
                if(sub.Zuora__SubscriptionStartDate__c<>null){
                    serviceActivationDate = date.newinstance(sub.Zuora__SubscriptionStartDate__c.year(), sub.Zuora__SubscriptionStartDate__c.month()+1, sub.Zuora__SubscriptionStartDate__c.day()-1);
                    sadFormat = (string.valueOf(serviceActivationDate)) + 'T00:00:00';              
                }
                */
                //END UD-2854 08/Oct/15 Wenjun
                
        //START UD-2657/D-3414/D-3711 Wenjun 19 Oct 15: handle stop before start
        if(sub.Zuora__SubscriptionEndDate__c < sub.Zuora__SubscriptionStartDate__c)
            targetDate = sub.Zuora__SubscriptionStartDate__c.addDays(1);
        //END UD-2657/D-3414/D-3711 Wenjun 19 Oct 15                
                
                invoiceMap.put('AccountId', (sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c != null ? sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c : null));
                
                //START D-3212 03/Jul/15 Wenjun : Roll Back of D-3181
                //START D-3181 29-06-2015 Marvin Gatchalian - setting invoice date to cancelation date
                invoiceMap.put('InvoiceDate', Zuora.Zutil.getZuoraDate(Date.today())); //START END UD-2854 08/Oct/15 Wenjun : Use Zuora Date Util
                //invoiceMap.put('InvoiceDate', (targetFormat != null ? targetFormat : null));
                //END D-3181 29-06-2015 Marvin Gatchalian - setting invoice date to cancelation date
                //END D-3212 03/Jul/15 Wenjun
                
                invoiceMap.put('TargetDate', Zuora.Zutil.getZuoraDate(targetDate)); //START END UD-2854 08/Oct/15 Wenjun : Use Zuora Date Util
                
                invoiceMapList.add(invoiceMap);
            }
            billAccIdSet.add(sub.Zuora__CustomerAccount__c);
        }
        return invoiceMapList;
    }

    //START UD-3002 12/11/2015 Added by J.Sarion - Create Bill Run record in Zuora for Accounts with large number of Subscriptions e.g. Direct Corporate
    public static void createBillRun(Set<Id> subIdSet) {
        Map<String, Object> billRunMap;
        Map<String, String> billingAccountZuoraId_billingAccountId = new Map<String, String>(); 
        Map<String, String> billingAccountZuoraId_billingAccountNumber = new Map<String, String>();
        List<Map<String, Object>> billRunMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> failedBillRunMapList = new List<Map<String, Object>>();
        Set<Id> processedBAsSet = new Set<Id>();
        Integer index;
        String logMessage = '';
        String billingAccountZuoraId;
        String billingAccountId;
        String billingAccountNumber;
        ZuoraCallOut zCallOut;
        //Logger logger = new Logger(InvoiceProcessForStopSubscription.class.getName()); //Start-END K. Tan 1/4/2016 UD-3433 
        system.debug('>>>>>isStart ' + isStart);
        system.debug('>>>>>subIdSet ' + subIdSet);
        List<Zuora__Subscription__c> subList = [SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, 
                        Billing_Type__c, Order_Number_1__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, 
                        Zuora__CustomerAccount__r.Name FROM Zuora__Subscription__c 
                        WHERE Id IN :subIdSet AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION Order By Zuora__SubscriptionStartDate__c DESC];
        system.debug('>>>>>subList ' + subList);
        for(Zuora__Subscription__c sub :subList) {
            if(!processedBAsSet.contains(sub.Zuora__CustomerAccount__c)) {
                Date targetDate;
                
                if(isStart) {
                    if(sub.Zuora__SubscriptionStartDate__c != null)
                        targetDate = sub.Zuora__SubscriptionStartDate__c.toStartOfMonth().addMonths(1);                       
                }
                else {
                    targetDate = sub.Zuora__SubscriptionEndDate__c.addDays(1);
                    
                    //handle stop before start
                    if(sub.Zuora__SubscriptionEndDate__c < sub.Zuora__SubscriptionStartDate__c)
                        targetDate = sub.Zuora__SubscriptionStartDate__c.addDays(1);
                }
                
                billingAccountZuoraId_billingAccountId.put((String) sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, sub.Zuora__CustomerAccount__c);   
                billingAccountZuoraId_billingAccountNumber.put((String) sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c);
                
                billRunMap = new Map<String, Object>();
                billRunMap.put('AccountId', sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);
                billRunMap.put('AutoPost', True);
                billRunMap.put('InvoiceDate', Zuora.Zutil.getZuoraDate(Date.today()));
                billRunMap.put('TargetDate', Zuora.Zutil.getZuoraDate(targetDate));
                billRunMapList.add(billRunMap);
                failedBillRunMapList.add(billRunMap);
            }
            processedBAsSet.add(sub.Zuora__CustomerAccount__c);
        }
        system.debug('>>>>>billRunMapList ' + billRunMapList);
        if (!billRunMapList.isEmpty()) {
            try
            {
                index = 0;
                zCallOut = new ZuoraCallOut();
                List<Map<String,String>> results = zCallOut.loadZObjects(billRunMapList, 'BillRun');
                for (Map<String,String> resultMap :results) {
                    if (resultMap.get('Status') == 'Success') {
                        failedBillRunMapList.remove(index);
                    }
                    index++;
                }
                system.debug('>>>>>results ' + results);
                //retry 3x
                if (!failedBillRunMapList.isEmpty()) {
                    
                    Integer attempt = 1;
                    List<Map<String, Object>> billRunMapListTmp = new List<Map<String, Object>>();  

                    while (attempt < 4) {
                        
                        if (failedBillRunMapList.isEmpty()) break;
                        
                        index = 0;
                        billRunMapListTmp = failedBillRunMapList;
                        List<Map<String, String>> responseList = new List<Map<String, String>>();
                        if (!Test.isRunningTest()) {
                            responseList = zCallOut.loadZObjects(failedBillRunMapList, 'BillRun');
                        } else {
                            Map<String, String> fakeResponse = new Map<String, String>();
                            fakeResponse.put('Status', 'Failed');
                            fakeResponse.put('Message', 'for code coverage');
                            responseList.add(fakeResponse);
                        }
                        
                        for (Map<String, String> resultMap : responseList) {
                            if (resultMap.get('Status') == 'Success') {
                                failedBillRunMapList.remove(index); 
                            } else {
                                if (attempt == 3) {
                                    
                                    Map<String, Object> requestField_requestValue = billRunMapListTmp[index];
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
            }
            catch (Exception e)
            {
                //logging logic
                for (Map<String, Object> requestField_requestValue : failedBillRunMapList) {
                    
                    billingAccountZuoraId = (string)requestField_requestValue.get('AccountId');
                    billingAccountId = billingAccountZuoraId_billingAccountId.get(billingAccountZuoraId);
                    billingAccountNumber = billingAccountZuoraId_billingAccountNumber.get(billingAccountZuoraId);
                    logMessage = '[Invoice Creation - ' + billingAccountNumber + '] ' + e.getMessage();
                    logger.log(false, logMessage, billingAccountId);
                }
            }
        }   
    }
    
    //END UD-3002 12/11/2015 Added by J.Sarion - Create Bill Run record in Zuora for Accounts with large number of Subscriptions e.g. Direct Corporate
}