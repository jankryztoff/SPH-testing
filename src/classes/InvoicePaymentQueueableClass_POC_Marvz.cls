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
*/

public class InvoicePaymentQueueableClass_POC_Marvz  {
    
    //START D-2787 04-29-2015 VPernica/MGatchalian
    public Set<Id> subscriptionIDs {get;set;}
    public static Decimal OrderAmountPaid;  
    public static Decimal OrderCheckAmountPaid;  
    public static Decimal orderOtherAmountPaid;
    //START UD-1315 25-05-2015 MarvinG/Von  
    public static Decimal RemainingBalance;  
    //END UD-1315 25-05-2015 MarvinG/Von 
    public static map<Order__c,List<Map<String, Object>>> OrderInvoices;
    static map<id, string> orderId_zouraFormattedDtlDate = new map<id, string>(); //Start/End UD-1521
    static map<string, string> billingAccountId_zouraFormattedDtlDate = new map<string, string>(); //Start/End UD-1521
    
    public InvoicePaymentQueueableClass_POC_Marvz () {
       // this.subscriptionIDs = subIDs;
    }
    
    
    public void execute(Set<Id> subIDs){
        system.debug(':::EXECUTE');
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Map<String, Object> updateInvoiceMap;
        List<Zuora.zObject> zobjs = new List<Zuora.zObject>();      
        List<Map<String, Object>> invoiceMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> paymentMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> updateInvoiceMapList = new List<Map<String, Object>>();       
        Set<String> paymentZuoraIdSet = new Set<String>();
        Set<String> invoiceIdSet = new Set<String>();
        Set<String> updateInvoiceIdSet = new Set<String>();        
        String invoiceZuoraId;
        String updateInvoiceZuoraId;  
        Set<Id> useSubIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();       
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        
        
        //Start D-2824 VPernica/MGatchalian
        orderOtherAmountPaid =0;
        orderAmountPaid =0;
        orderCheckAmountPaid =0;
        set<id> OrderId = new set<id>();
        //End D-2824 VPernica/MGatchalian
       
        subList = [SELECT Id, Name, Order_Number_1__c, Order_Line_Item_Number_1__c, Zuora__SubscriptionStartDate__c, Main_Package_1__c, 
                   Subscription_Type_1__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Term_Length__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                   Order_Number_1__r.Amount_Paid__c, Order_Number_1__r.Full_Prepaid_Inc_Del_Charge__c, Order_Number_1__r.Check_Amount__c, 
                   Order_Number_1__r.DTL_Date__c FROM Zuora__Subscription__c WHERE Id IN : subIDs order by Order_Number_1__r.DTL_Date__c asc]; // Start/End UD-1521 16Jun15 JohnD - added DTL_Date__c
        
        for(Zuora__Subscription__c sub :subList)
        {
            if (sub.Order_Number_1__c != null) 
            {
                useSubIdSet.add(sub.Id);
                orderIdSet.add(sub.Order_Number_1__c);
                // Start UD-1521 16Jun15 JohnD - added for DTL Date
                if (sub.Order_Number_1__r.DTL_Date__c != null) {
                    orderId_zouraFormattedDtlDate.put(sub.Order_Number_1__c,  Zuora.Zutil.getZuoraDate(sub.Order_Number_1__r.DTL_Date__c));
                }
                // End UD-1521 16Jun15 JohnD - added for DTL Date
            }
            if (sub.Order_Line_Item_Number_1__c != null) 
            {
                oliIdSet.add(sub.Order_Line_Item_Number_1__c);
            }
            
            //Start D-2824 VPernicia/MGatchalian
            if (sub.Order_Number_1__r.Amount_Paid__c != null && !OrderId.contains(sub.Order_Number_1__c)) {
                OrderAmountPaid = OrderAmountPaid + sub.Order_Number_1__r.Amount_Paid__c;
                orderOtherAmountPaid = orderOtherAmountPaid + sub.Order_Number_1__r.Full_Prepaid_Inc_Del_Charge__c;
                OrderId.add(sub.Order_Number_1__c);
            }
            
            // Start UD-0721 04/09/2015 ronald Dagaraga: Add a new variable to pull the value for Check payment
            if (sub.Order_Number_1__r.Check_Amount__c != null && !OrderId.contains(sub.Order_Number_1__c)) {
                OrderCheckAmountPaid = OrderCheckAmountPaid + sub.Order_Number_1__r.Check_Amount__c;
                OrderId.add(sub.Order_Number_1__c);
            }
            // End UD-0721 04/09/2015 ronald Dagaraga: Add a new variable to pull the value for Check payment
            //End D-2824 VPernicia/MGatchalian
        }
        //END D-2787 04-29-2015 VPernica/MGatchalian
        
        
        if (!useSubIdSet.isEmpty()) {
            invoiceMapList = generateInvoice(useSubIdSet);
        }

        
        if (!invoiceMapList.isEmpty()) {
            List<Map<String,String>> results = zCallOut.generateInvoiceList(invoiceMapList);
            for (Map<String,String> resultMap :results) {
                system.debug('JohnD ::: ' + resultMap);           
                if (resultMap.get('Status') == 'Success') {
                    invoiceZuoraId = resultMap.get('Id');
                    invoiceIdSet.add(invoiceZuoraId);
                }
                else {
                    system.debug('>>>>>>>>>>>>>>invoiceStatus' + resultMap.get('Status'));
                    system.debug('>>>>>>>>>>>>>>invoiceError' + resultMap.get('Error'));
                    system.debug('>>>>>>>>>>>>>>invoiceMEssage' + resultMap.get('Message'));
                    system.debug('>>>>>>>>>>>>>>invoiceCode' + resultMap.get('Code'));
                }
            }
        }
        if (!invoiceIdSet.isEmpty()) {
            for (String invoiceId :invoiceIdSet) {
                updateInvoiceMap = new Map<String, Object>();
                
                updateInvoiceMap.put('Id', invoiceId);
                updateInvoiceMap.put('Status', 'Posted');
                updateInvoiceMapList.add(updateInvoiceMap);
            }
        }
        
        
        
        if (!updateInvoiceMapList.isEmpty()) {
            List<Map<String,String>> results = zCallOut.updateZObjects(updateInvoiceMapList, 'Invoice');
            for (Map<String,String> resultMap :results) {           
                if (resultMap.get('Status') == 'Success') {
                    updateInvoiceZuoraId = resultMap.get('Id');
                    updateInvoiceIdSet.add(updateInvoiceZuoraId);
                }
                else {
                    system.debug('>>>>>>>>>>>>>>invoiceStatus' + resultMap.get('Status'));
                    system.debug('>>>>>>>>>>>>>>invoiceError' + resultMap.get('Error'));
                    system.debug('>>>>>>>>>>>>>>invoiceMEssage' + resultMap.get('Message'));
                    system.debug('>>>>>>>>>>>>>>invoiceCode' + resultMap.get('Code'));
                }
            }
        }
        
       
        if (updateInvoiceZuoraId != null) {
            zobjs = zCallOut.zquerymoreInvoice(updateInvoiceZuoraId);
        }
             
        if (!zobjs.isEmpty()) {
            //START UD-1315 25-05-2015 MarvinG/Von 
            //call createPayment using Credit Balance

             
            createPaymentUsingCreditBalance(zobjs);
            
           
            
            if (RemainingBalance > 0){
           
                paymentMapList = createPayment(zobjs);
            }
            //END UD-1315 25-05-2015 MarvinG/Von
        }

        if (!paymentMapList.isEmpty()) {
            List<Map<String,String>> returnVar = zCallOut.loadZObjects(paymentMapList, 'Payment');
            
            for(Map<String,String> resultMap :returnVar){ 
                if (resultMap.get('Status') == 'Success') {
                    //TBD
                    paymentZuoraIdSet.add(resultMap.get('Id'));
                }
                else {
                    //TBD
                    system.debug('>>>>>>>>>>>>>>paymentStatus' + resultMap.get('Status'));
                    system.debug('>>>>>>>>>>>>>>paymentError' + resultMap.get('Error'));
                    system.debug('>>>>>>>>>>>>>>paymentError' + resultMap.get('Error'));
                    system.debug('>>>>>>>>>>>>>>paymentMEssage' + resultMap.get('Message'));
                    system.debug('>>>>>>>>>>>>>>paymentCode' + resultMap.get('Code'));
                }
            }
        }       
    }

    public static List<Map<String, Object>> generateInvoice(Set<Id> subIdSet) {

        //START 02/18/2015 JTeves - Code Optimization - Removal of NULL value in Query Filter Sets
        if(subIdSet.contains(null)) {
            subIdSet.remove(null);
        }
        //END 02/18/2015 JTeves - Code Optimization
        
        // Start D-2952 18May15 JohnD - checked if all subscriptions were created
        map<id, integer> orderId_totalNumberOfExpectedSubscriptions = new map<id, integer>();
        map<id, integer> orderId_totalNumberOfSuscriptions = new map<id, integer>();
        set<id> orderIdSet = new set<id>();
        list<zqu__Quote__c> quoteList; // Start/End UD-1324 26May15 JohnD
        integer oliCounter = 0;
        
        // Start D-3111 (HotFix) 13Jun15 JohnD - added logic for no invoice issue
        set<id> tmpOrderIdSet = new set<id>();
        
        for (Zuora__Subscription__c sub : [select Order_Number_1__c from Zuora__Subscription__c where Id in :subIdSet]) {   
            tmpOrderIdSet.add(sub.Order_Number_1__c);
        }        
        // End D-3111 (HotFix) 13Jun15 JohnD - added logic for no invoice issue
        
        for (AggregateResult ar : [select Order_Number_1__c, count(Id) total from Zuora__Subscription__c 
                where order_number_1__c in :tmpOrderIdSet group by Order_Number_1__c]) {    // Start/End D-3111 (HotFix) 13Jun15 JohnD - changed filter criteria
            
            orderId_totalNumberOfSuscriptions.put((id)ar.get('Order_Number_1__c'), (integer)ar.get('total'));
        }
        
        system.debug('JohnD :: ' + orderId_totalNumberOfSuscriptions);
        
        // Start UD-1324 26May15 JohnD - revised source data
        for (Order_Line_Item__c oli : [select Order__c, (select Id from Quotes__r) from Order_Line_Item__c 
                where Order__c in :orderId_totalNumberOfSuscriptions.keySet()]) {
            
            if (orderId_totalNumberOfExpectedSubscriptions.get(oli.Order__c) != null) {
                
                oliCounter = orderId_totalNumberOfExpectedSubscriptions.get(oli.Order__c);
            }
            
            quoteList = oli.Quotes__r;
            
            if (quoteList != null && !quoteList.isEmpty()) {
                oliCounter += quoteList.size();
            }
            
            orderId_totalNumberOfExpectedSubscriptions.put(oli.Order__c, oliCounter);
        }
        // End UD-1324 26May15 JohnD - revised source data
        
        system.debug('JohnD :: ' + orderId_totalNumberOfExpectedSubscriptions);
        
        // Start UD-1324 26May15 JohnD - commented out
        /*
        for (Order_Line_Item__c oli : [select Id, Addon_Package__c, Delivered_By__c, Order__c, Total_Postage_Charge__c from Order_Line_Item__c // Start/End UD-1324 26May15 JohnD - added Total_Postage_Charge__c
                where Order__c in :orderId_totalNumberOfSuscriptions.keySet()]) {
            
            if (orderId_totalNumberOfExpectedSubscriptions.get(oli.Order__c) != null) {
                
                oliCounter = orderId_totalNumberOfExpectedSubscriptions.get(oli.Order__c);
            }
            
            oliCounter++;
            
            if (oli.Addon_Package__c != null) {
                oliCounter++;
            }
            
            if (oli.Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_VENDOR 
                    || (oli.Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT 
                    && oli.Total_Postage_Charge__c > 0)) {  // Start/End UD-1324 26May15 JohnD - added expression in the condition
                
                oliCounter++;           
            }
            
            orderId_totalNumberOfExpectedSubscriptions.put(oli.Order__c, oliCounter);
        }
        */
        // End UD-1324 26May15 JohnD - commented out
        
        for (id orderId : orderId_totalNumberOfExpectedSubscriptions.keySet()) {
            if (orderId_totalNumberOfExpectedSubscriptions.get(orderId) == orderId_totalNumberOfSuscriptions.get(orderId)) {
                orderIdSet.add(orderId);
            }   
        }
        // End D-2952 18May15 JohnD - checked if all subscriptions were created
        
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        List<Map<String, Object>> invoiceMapList = new List<Map<String, Object>>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Map<String, Object> invoiceMap;
        Set<Id> billAccIdSet = new Set<Id>();
        String invoiceZuoraId;
        // Start UD-1521 16Jun15 JohnD - commented out
        /*
        Date d = system.today();
        string dFormat = (string.valueOf(d)) + 'T00:00:00';
        */
        // End UD-1521 16Jun15 JohnD - commented out
        String sadFormat;
        
        //START 05/04/2015 S.Puli D-2798
        //START D-2993 6/4/15 Kestoya : added Billing_Type__c in query
        // Start UD-1591 16Jun15 JohnD - added Order_Number_1__c
        subList = [SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Billing_Type__c, 
                    Order_Number_1__c FROM Zuora__Subscription__c 
                    WHERE Order_Number_1__c in :orderIdSet Order by Zuora__SubscriptionStartDate__c DESC];  // Start/End D-2952 18May15 JohnD - revised expression in where clause
        // End UD-1591 16Jun15 JohnD - added Order_Number_1__c
        //END-2993 6/4/15 Kestoya: added Billing_Type__c in query
        //END 05/04/2015 S.Puli D-2798
        
        for (Zuora__Subscription__c sub : subList) {
            if (!billAccIdSet.contains(sub.Zuora__CustomerAccount__c)) {
                invoiceMap = new Map<String, Object>();
                Date serviceActivationDate;
                Date startDate;
                //START D-2681 4/1/15 AddedBy FrancisBenzon : sets target date to 1st day of next month for Invoice
                if(sub.Zuora__SubscriptionStartDate__c<>null){
                    //START D-2993 6/4/15 Kestoya : sets target date to 1 day after sub start date as per invoice creation is on demand for full prepaid subs                                                            
                    if(sub.Billing_Type__c != GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID)
                    {
                        //START D-2902 K. Tan 5/13/2015 added condition for Invoice Target Date For Recurring Packs
                        if(sub.Zuora__SubscriptionStartDate__c == sub.Zuora__SubscriptionStartDate__c.toStartOfMonth()){                    
                        serviceActivationDate = date.newinstance(sub.Zuora__SubscriptionStartDate__c.year(), sub.Zuora__SubscriptionStartDate__c.month()+1, 2);
                        }
                        else {
                            serviceActivationDate = date.newinstance(sub.Zuora__SubscriptionStartDate__c.year(), sub.Zuora__SubscriptionStartDate__c.month()+1, 1);     
                        }
                        //END D-2902 K. Tan 5/13/2015 added condition for Invoice Target Date for Recurring Packs
                    }
                    else {
                        serviceActivationDate = sub.Zuora__SubscriptionStartDate__c.addDays(1);
                    }                                                       
                    sadFormat = (string.valueOf(serviceActivationDate)) + 'T00:00:00';                  
                    //END D-2993 6/4/15 Kestoya : sets target date to 1 day after sub start date as per invoice creation is on demand for full prepaid subs                               
                }
                //END D-2681 4/1/15 AddedBy FrancisBenzon : sets target date to 1st day of next month for Invoice
                invoiceMap.put('AccountId', (sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c != null ? sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c : null));
                //Zuora.Zutil.getZuoraDate(date.today())
                
                //invoiceMap.put('InvoiceDate', orderId_zouraFormattedDtlDate.get(sub.Order_Number_1__c));
                
                //START D-3193 30-06-2015 Marvin Gatchalian
                //START UD-1595 23-06-2015 Marvin Gatchalian
                invoiceMap.put('InvoiceDate', Zuora.Zutil.getZuoraDate(date.today()));
                //END UD-1595 23-06-2015 Marvin Gatchalian
                //END D-3193 30-06-2015 Marvin Gatchalian
                
                invoiceMap.put('TargetDate', (sadFormat != null ? sadFormat : null));
                invoiceMapList.add(invoiceMap);
                
                if (sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c != null) {
                    billingAccountId_zouraFormattedDtlDate.put(sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c,  orderId_zouraFormattedDtlDate.get(sub.Order_Number_1__c));
                }
                
            }
            
            billAccIdSet.add(sub.Zuora__CustomerAccount__c);
        }
        return invoiceMapList;
    }
    
    //START UD-1315 25-05-2015 MarvinG/Von 
    public void createPaymentUsingCreditBalance(List<Zuora.zObject> zobjs) {
        
        Map<String, Object> creditBalanceMap = new Map<String, Object>();
        List<Map<String, Object>> creditBalanceList = new List<Map<String, Object>>();
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
        string zuoraId;
        Decimal TotalBalance = 0;
        
        //START UD-1595 23-06-2015 Marvin Gatchalian
        Decimal UserCashPayment = 0;
        UserCashPayment = OrderAmountPaid;
        //END UD-1595 23-06-2015 Marvin Gatchalian


        if (zobjs.get(0).getValue('AccountId') != null) {
            
            zuoraId = (String) zobjs.get(0).getValue('AccountId');
            
            billAcc = [SELECT Id, Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__c, 
                    Zuora__Default_Payment_Method__r.Zuora__External_Id__c, Zuora__Credit_Balance__c 
                     FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = :zuoraId];
                     
            
            if ((Decimal) zobjs.get(0).getValue('Balance') > billAcc.Zuora__Credit_Balance__c) {
                
                TotalBalance = billAcc.Zuora__Credit_Balance__c;
                RemainingBalance = (Decimal) zobjs.get(0).getValue('Balance') - billAcc.Zuora__Credit_Balance__c;
                
            } else {

                //START UD-1595 23-06-2015 Marvin Gatchalian
                TotalBalance = (Decimal) zobjs.get(0).getValue('Balance') - UserCashPayment;
                RemainingBalance = UserCashPayment;
                
                if (TotalBalance <= 0 ) {
                    RemainingBalance = (Decimal) zobjs.get(0).getValue('Balance');
                }
                //TotalBalance = (Decimal) zobjs.get(0).getValue('Balance');
                //RemainingBalance = 0;
                //END UD-1595 23-06-2015 Marvin Gatchalian
                
            }
         }
         
        if (billAcc.Zuora__Credit_Balance__c != 0  && TotalBalance > 0 ) {
        
            ZuoraCallOut zCallOut = new ZuoraCallOut();
            
            creditBalanceMap.put('Amount', TotalBalance);
            creditBalanceMap.put('Type', 'Decrease');
            creditBalanceMap.put('SourceTransactionId', zobjs.get(0).getValue('Id'));
            creditBalanceList.add(creditBalanceMap);
            
            List<Map<String,String>> results = zCallOut.loadZObjects(creditBalanceList, 'CreditBalanceAdjustment');
        }
        
        
        
    } 
    //END UD-1315 25-05-2015 MarvinG/Von  
    
    public static List<Map<String, Object>> createPayment(List<Zuora.zObject> zobjs) {
        List<Map<String, Object>> paymentMapList = new List<Map<String, Object>>();
        List<Zuora__CustomerAccount__c> billAccList = new List<Zuora__CustomerAccount__c>();
        List<Zuora__PaymentMethod__c> paymentMethodList = new List<Zuora__PaymentMethod__c>();
        Map<Id, Zuora__PaymentMethod__c> paymentMethodIdToPaymentMethod = new Map<Id, Zuora__PaymentMethod__c>();
        Map<String, Zuora__CustomerAccount__c> zuoraIdToBillAccMap = new Map<String, Zuora__CustomerAccount__c>();
        //Map<String, Object> paymentMap;
        Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
        String paymentMethodId;
        String zuoraId;
        Set<String> zuoraIdSet = new Set<String>();
        Set<Id> paymentMethodIdSet = new Set<Id>();
        datetime d = system.now();
        datetime dt = datetime.newinstance(d.year(), d.month(), d.day(), 00, 00, 00);
        string dFormat = (string.valueOf(dt)).replaceAll( '\\s+', 'T'); 
        
        if (zobjs.get(0).getValue('AccountId') != null) {
            zuoraId = (String) zobjs.get(0).getValue('AccountId');
            
            // Start D-2451 03/27/2015 VPernicia: Add new field Zuora__DefaultPaymentMethod__c to handle cash payment
            billAcc = [SELECT Id, Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c, Other_PaymentMethod__c, Zuora__Account__r.Id FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = :zuoraId]; //START/END 05/26/2015 UD-1310 Kevin Evasco - StopPress eNets transaction
            // End D-2451 03/27/2015 VPernicia: Add new field Zuora__DefaultPaymentMethod__c to handle cash payment
            
        }
        if (billAcc.Zuora__Default_Payment_Method__c != null) {
            paymentMethodId = billAcc.Zuora__Default_Payment_Method__c;
        }
        if (paymentMethodId != null) {
            paymentMethod = [SELECT Id, Zuora__External_Id__c FROM Zuora__PaymentMethod__c WHERE Id = :paymentMethodId];
        }
        
        // Start D-2451 03/27/2015 VPernicia: Add a condition to handle cash payment
        Map<String, Object> paymentMap = new Map<String, Object>();
        paymentMap.put('AccountId', zuoraId);
        paymentMap.put('EffectiveDate', dFormat);    
        paymentMap.put('InvoiceId', zobjs.get(0).getValue('Id'));

        if (billAcc.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.CASH) {
            paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Cash'));//von
            paymentMap.put('Amount', OrderAmountPaid );
            //START UD-1315 25-05-2015 MarvinG/Von  
            paymentMap.put('AppliedInvoiceAmount', RemainingBalance);
            paymentMap.put('AppliedCreditBalanceAmount', OrderAmountPaid - RemainingBalance);
            //END UD-1315 25-05-2015 MarvinG/Von  
            paymentMap.put('Type', 'External');
        } 
        else if (billAcc.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.CHEQUE) {
            paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Check'));
            paymentMap.put('Amount', OrderCheckAmountPaid );
            paymentMap.put('AppliedInvoiceAmount', zobjs.get(0).getValue('Balance'));
            paymentMap.put('AppliedCreditBalanceAmount', OrderCheckAmountPaid - (decimal) zobjs.get(0).getValue('Balance'));
            paymentMap.put('Type', 'External'); }
        //START D-2787 04-29-2015 VPernica/MGatchalian
        else if (billAcc.Zuora__DefaultPaymentMethod__c == 'Other') {
            
            paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other'));
            paymentMap.put('Amount', zobjs.get(0).getValue('Balance'));
            paymentMap.put('AppliedInvoiceAmount', zobjs.get(0).getValue('Balance'));
            paymentMap.put('Type', 'External');
            
            //START 05/26/2015 UD-1310 Kevin Evasco - StopPress eNets transaction
            if(billAcc.Other_PaymentMethod__c == 'eNets'){
                List<BT_CO_STPPRS_StopPressSubscription__c> stopPressList = [SELECT Id, payment_number__c FROM BT_CO_STPPRS_StopPressSubscription__c WHERE Order__r.Account__r.Id = :billAcc.Zuora__Account__r.Id LIMIT 1];
                if(stopPressList.size() > 0)
                    paymentMap.put('Comment', 'eNets Payment Number: ' + stopPressList[0].payment_number__c);
            }
            //END 05/26/2015 UD-1310 Kevin Evasco - StopPress eNets transaction
        }
        //END D-2787 04-29-2015 VPernica/MGatchalian
        else {
            paymentMap.put('Amount', zobjs.get(0).getValue('Balance'));
            paymentMap.put('AppliedInvoiceAmount', zobjs.get(0).getValue('Balance'));
            paymentMap.put('PaymentMethodId', paymentMethod.Zuora__External_Id__c);//From Billing Account 
            paymentMap.put('Type', 'Electronic');
        }
        // EndD-2451 03/27/2015 VPernicia: Add a condition to handle cash payment
        
        paymentMap.put('Status', 'Processed');
        
        paymentMapList.add(paymentMap);
        
        return paymentMapList;
    } 
}