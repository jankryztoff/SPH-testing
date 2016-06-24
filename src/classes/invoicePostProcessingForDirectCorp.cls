/**
* Class Name: <invoicePostProcessingForDirectCorp>
* @authors: <Jayson Sarion>
* Date: <12/11/2015>
* Requirement/Project Name: <SPH> UD-3002
* @description: 
*   Query Invoice Item details from Zuora to get the subscription list
*       If the subscriptions have open COS Case:
*           Convert the Invoice to Credit Balance (follow existing logic)
*           Send quotes for create new subscriptions (follow existing logic)
*       Else if Invoice Balance (Zuora__Balance2__c) > 0:
*           Apply Credit Balance if any (follow existing logic)
*           Perform Payments (follow existing logic)
* History : 8Jan16 UD-3491 FrancisBenzon : added logic for payment record creation, change class into queueable
*           21Jan16 UD-3676 RReyes : changed class from queueable to @future, reconstructured class
*/

public class invoicePostProcessingForDirectCorp{
    
    public Set<String> directCorpInvoiceIdSet {get;set;}
    //START UD-3491 8Jan16 FrancisBenzon : for payment creation
    public static Logger logger = new Logger(invoicePostProcessingForDirectCorp.class.getName());
    public invoicePostProcessingForDirectCorp(Set<String> directCorpInvoiceIdSet) {
        this.directCorpInvoiceIdSet = directCorpInvoiceIdSet;
        processDirectCorp(directCorpInvoiceIdSet);
    }
    //END UD-3491 8Jan16 FrancisBenzon : for payment creation
    public static Map<String, Decimal> mapInvBAToTotalCBAmt = new Map<String, Decimal>();
    public static Map<String, Decimal> mapInvBAToRemainingAmt = new Map<String, Decimal>();
    public static Map<String, Zuora__CustomerAccount__c> mapBAZuoraIdToBA = new Map<String, Zuora__CustomerAccount__c> ();
    public static Map<String, Id> mapBAZuoraIdToOrderID = new Map<String, Id>();
    public static Map<Id, Decimal> mapOrderIdToCheckAmount = new Map<Id, Decimal>();

    public static List<Zuora__CustomerAccount__c> lstBAs = new List<Zuora__CustomerAccount__c>();
    public static Map<Id, Decimal> mapOrderIdToCashAmount = new Map<Id, Decimal>();

    public static Map<String, Id> mapBAZuoraIdToAccountId = new Map<String, Id>();
    public static Map<String, Decimal> mapInvBAToTotalOtherCBAmt = new Map<String, Decimal>();
    static map<string, decimal> invoiceZuoraId_adjustedBalance = new map<string, decimal>();    // Start/End 22May16 JohnD
        
    @future(callout=true)
     public static void processDirectCorp(Set<String> directCorpInvoiceIdSet){
        //START Declaration and Instantiation of Variables
        List<Zuora.zObject> invoiceList = new List<Zuora.zObject>();

        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<Map<String, Object>> negativeInvoiceMapList = new List<Map<String, Object>>(); //START/END D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
        
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
        Set<String> subZuoraIdSet = new Set<String>();
        Set<Id> billingActIDs = new Set<Id>();
        Set<String> orderTypes = new Set<String>();
        orderTypes.add('Change of Subscription Quantity');
        orderTypes.add('Change of Subscription Package');
        List<Order__c> orderList = new List<Order__c>();
        String orderStatNew = 'New';
        String orderStatDraft = 'Draft';
        String orderStatClose = 'Close';
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        Set<Id> orderIds = new Set<Id>();
        //START UD-3890 13/04/2016 Wenjun
        Map<String, String> mapSubToInvoice = new Map<String, String>();
        Set<String> setStopInvoiceIds = new Set<String>();
        Set<String> setFPPInvoiceIds = new Set<String>();
        List<Zuora.zObject> lstStopInvocies = new List<Zuora.zObject>();
        List<Zuora.zObject> lstNewFPPInvocies = new List<Zuora.zObject>();
        //END UD-3890 13/04/2016 Wenjun
        
        //START 15/04/2016 D-4686 - added isRunningTest to skip zCallout (MBG)
        //if (!Test.isRunningTest()) {  - Test is running is no longer need as there is already mock response
            zObjectList = zCallOut.bulkQueryForInvoiceItem(directCorpInvoiceIdSet, 'invoice'); //START-END UD-2549 3/15/2016 Added by J.Sarion - added params
      System.debug(' cube ---------> : ' + zObjectList.size());
      System.debug(' cube ---------> : ' + zObjectList);
        //}
        //else {
        //    zObjectList = null;
        //} - Test is running is no longer need as there is already mock response
        //END 15/04/2016 D-4686 - added isRunningTest to skip zCallout (MBG)
        
        if(zObjectList != null && !zObjectList.isEmpty()) {
            for(Zuora.zObject zObj :zObjectList) {
                subZuoraIdSet.add((String) zObj.getValue('SubscriptionId'));
                mapSubToInvoice.put((String) zObj.getValue('SubscriptionId'),(String) zObj.getValue('InvoiceId')); //START END UD-3890 Wenjun 13/04/2016
            }
        }
        //START UD-3890 Wenjun : query more fieds
    System.debug(' cube ---------> : ' + subZuoraIdSet.size());
    System.debug(' cube ---------> : ' + subZuoraIdSet);
    System.debug(' cube ---------> : ' + orderTypes);
    System.debug(' cube ---------> : ' + orderStatNew);
    System.debug(' cube ---------> : ' + orderStatDraft);
    System.debug(' cube ---------> : ' + orderStatClose);
        if(!subZuoraIdSet.isEmpty()) {
            //START PD-0202 FrancisBenzon 20May16 : exclude void orders in processing
            /*orderList = [SELECT Id, Name, Account__c, Billing_Type__c, Subscription__r.Zuora__Zuora_Id__c FROM Order__c 
                            WHERE Subscription__r.Zuora__Zuora_Id__c IN :subZuoraIdSet AND Order_Type__c IN :orderTypes AND Status__c != :orderStatNew 
                            AND Status__c != :orderStatDraft AND Status__c != :orderStatClose];*/
            orderList = [SELECT Id, Name, Account__c, Billing_Type__c, Subscription__r.Zuora__Zuora_Id__c FROM Order__c 
                            WHERE Subscription__r.Zuora__Zuora_Id__c IN :subZuoraIdSet AND Order_Type__c IN :orderTypes AND Status__c != :orderStatNew 
                            AND Status__c != :orderStatDraft AND Status__c != :orderStatClose AND Status__c != :GlobalVariableClass.STATUS_VOID ];
            //END PD-0202 FrancisBenzon 20May16 : exclude void orders in processing
            subList = [SELECT Name, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__Credit_Balance__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, 
                        Zuora__CustomerAccount__r.Zuora__External_Id__c, Order_Number_1__c, Billing_Type__c, Zuora__Zuora_Id__c, 
                        Order_Number_1__r.Check_Amount__c,Order_Number_1__r.Amount_Paid__c, Order_Number_1__r.Payment_Mode__c, Zuora__Account__c
                        FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :subZuoraIdSet];
        }
        //END 13/04/2016 UD-3890 Wenjun
        
        if(directCorpInvoiceIdSet.size() > 0){
            //START 15/04/2016 D-4686 - added isRunningTest to skip zCallout (MBG)
            //if (!Test.isRunningTest()) {
                invoiceList = zCallOut.bulkQueryInvoices(directCorpInvoiceIdSet);
            //}
            //END 15/04/2016 D-4686 - added isRunningTest to skip zCallout (MBG)
        }
        //END Declaration and Instantiation of Variables

        //START UD-3890 13/04/2016 Wenjun : Fix the flow issue
        /******* Seperate Stop Invoices from COS Orders and New Full Prepaid Invoices *********/
        //Get COS Stop Invoices ID
    System.debug(' cube ---------> : ' + orderList.size());
    System.debug(' cube ---------> : ' + orderList);
        for(Order__c cosOrder : orderList)
        {
            if(mapSubToInvoice.containsKey(cosOrder.Subscription__r.Zuora__Zuora_Id__c))
                setStopInvoiceIds.add(mapSubToInvoice.get(cosOrder.Subscription__r.Zuora__Zuora_Id__c));
        }
        
        //Get Full Prepaid Invoices ID
    System.debug(' cube ---------> : ' + subList.size());
    System.debug(' cube ---------> : ' + subList);
        for(Zuora__Subscription__c sub: subList)
        {
            if(GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID == sub.Billing_Type__c && mapSubToInvoice.containsKey(sub.Zuora__Zuora_Id__c))
                setFPPInvoiceIds.add(mapSubToInvoice.get(sub.Zuora__Zuora_Id__c));
        }
        //Filter the Invoice List
    System.debug(' cube ---------> : ' + invoiceList.size());
    System.debug(' cube ---------> : ' + invoiceList);
        for(Zuora.zObject zuoraInv : invoiceList)
        {
            if(setStopInvoiceIds.contains((String)zuoraInv.getValue('Id')))
                lstStopInvocies.add(zuoraInv);
            else if(setFPPInvoiceIds.contains((String)zuoraInv.getValue('Id'))) //For non-stop, only look at Full Prepaid
                lstNewFPPInvocies.add(zuoraInv);
        }
        //END UD-3890 13/04/2016 Wenjun
        
        //START UD-3890 13/04/2016 Wenjun : New condition
        if(!lstNewFPPInvocies.isEmpty()) {
        //END UD-3890 13/04/2016 Wenjun  
            for(Zuora__Subscription__c sub :subList)
            {
                //START UD-3890 13/04/2016 Wenjun : Shall only handle Full Prepaid here
                if(GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID == sub.Billing_Type__c)
                {
                    mapBAZuoraIdToAccountId.put(sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, sub.Zuora__Account__c);
                    billingActIDs.add(sub.Zuora__CustomerAccount__c);
                    mapBAZuoraIdToOrderID.put(sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, sub.Order_Number_1__c);
                    if (sub.Order_Number_1__r.Check_Amount__c != null && sub.Order_Number_1__r.Payment_Mode__c == GlobalVariableClass.CHEQUE) 
                        mapOrderIdToCheckAmount.put(sub.Order_Number_1__c, sub.Order_Number_1__r.Check_Amount__c); 
                    if (sub.Order_Number_1__r.Amount_Paid__c != null && sub.Order_Number_1__r.Payment_Mode__c == GlobalVariableClass.CASH) 
                        mapOrderIdToCashAmount.put(sub.Order_Number_1__c, sub.Order_Number_1__r.Amount_Paid__c);
                }
                //END UD-3890 13/04/2016 Wenjun
            }
            
            lstBAs = [SELECT Zuora__AccountNumber__c, Zuora__External_Id__c, Zuora__Credit_Balance__c, Zuora__Account__c, Other_PaymentMethod__c,
                      Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c, 
                      Zuora__Balance__c, Payment_Mode__c, Billing_Type__c  FROM Zuora__CustomerAccount__c WHERE Id IN: billingActIDs];
        
            for(Zuora__CustomerAccount__c billingAccount : lstBAs)
            {
                mapBAZuoraIdToBA.put(billingAccount.Zuora__External_Id__c, billingAccount); 
            }
            //Start UD-3890 09-Apr-2016 Added by S.Puli
            //START UD-3890 13/04/2016 Wenjun : changed to lstNewFPPInvocies
            //InvoicePaymentQueueableClass.updateZInvoice(invoiceList);//Start/End UD-3890 04-Apr-2016 Added By S.Puli - transfer here
            transferCreditBalances(lstNewFPPInvocies, zCallOut);
            updateInvPrevBalanceForCorp(lstNewFPPInvocies, zCallOut);
            applyCreditBalance(lstNewFPPInvocies, zCallOut);
            processPayment(lstNewFPPInvocies, zCallOut);

            //End UD-3890 09-Apr-2016 Added by S.Puli
        }//END of ELSE
       //END UD-3890 13/04/2016 Wenjun             
        if(orderList.size() > 0){

            List<Account> acctsToUpdate = new List<Account>();
            
            //START STEP 1: Convert Negative Invoice Amount to Credit Balance 
            if(lstStopInvocies.size() > 0){  //START END UD-3890 13/04/2016 Wenjun : change to the filtered list
                //REMOVE InvoicePaymentQueueableClass.updateZInvoice(invoiceList);//Start/End UD-3890 04-Apr-2016 Added By S.Puli
                convertNegativeInvoiceToCB(lstStopInvocies, zCallOut); //START END UD-3890 13/04/2016 Wenjun : change to the filtered list
                
                //START D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
                for(Zuora.zObject zInv : lstStopInvocies) { //START END UD-3890 13/04/2016 Wenjun : change to the filtered list
                    if(Decimal.valueOf(String.valueOf(zInv.getValue('Amount'))) < 0){
                        Map<String, Object> invoiceMap = new Map<String, Object>();         
                        invoiceMap.put('Id', zInv.getValue('Id'));
                        invoiceMap.put('Immediate_CB__c', 'Y');
                        negativeInvoiceMapList.add(invoiceMap);
                    }
                }       
                
                try{
                    updateInvoiceImmediateCB(negativeInvoiceMapList);
                }catch(Exception e){
                    logger.log(e);
                }
                //END D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
                
            }//END STEP 1: Convert Negative Invoice Amount to Credit Balance 
            Set<Id> filterAccountToUpdate = new Set<Id>();  //PD-0111 Gdelrosario : added for filtering 
            //START STEP 2: Send new Quotes to Zuora (After COS) 
            for(Order__c thisOrder : orderList){
                Account accToUpd = new Account(Id = thisOrder.Account__c);
                accToUpd.Billing_Type__c = SM_SubscriptionHelper.getBillingTypeForBA(thisOrder.Billing_Type__c);
        //PD-0111 Gdelrosario : added for filtering of acctsToUpdate
                if(!filterAccountToUpdate.contains(accToUpd.Id)){
                    acctsToUpdate.add(accToUpd);   
                    filterAccountToUpdate.add(accToUpd.Id);
                }   
        //PD-0111 Gdelrosario : added for filtering acctsToUpdate                
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
            
            //START D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
            /*
            //START 11 March 2016 UD-3247 Kevin Evasco - Immediate CB to true for Negative Invoices
            try{
                updateInvoiceImmediateCB(directCorpInvoiceIdSet);
            }catch(Exception e){
                logger.log(e);
            }
            //END 11 March 2016 UD-3247 Kevin Evasco - Immediate CB to true for Negative Invoices
            */          
            //END D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
            for(Order__c thisOrder : orderList){
                orderIds.add(thisOrder.id);
            }
            if(!orderIds.isEmpty()){
                try{
                    Id jobID = System.enqueueJob(new SM_ChangeOfSubStartStopProcess(orderIds));
                }catch(Exception e){
                     logger.log(e);
                }
            }
            //END STEP 2: Send new Quotes to Zuora (After COS) 
    //Start UD-3890 13-Apr-2016 Transfer Codes to above
        }
    //End UD-3890 13-Apr-2016 Transfer Codes to above
        logger.save();
    }
    
    //Method that Converts Negative Invoice to Credit Balance
    public static void convertNegativeInvoiceToCB(List<Zuora.zObject> zobjs, ZuoraCallOut zCallOut) {
        List<Map<String, Object>> listCBMap = new List<Map<String, Object>>();
        for(Zuora.zObject zObj: zobjs){
            //START PD-0202 FrancisBenzon 20May16 : catch invalid conversion error
            try{
                Decimal amount = (Decimal) zObj.getValue('Amount');
                if(amount < 0){
                    amount = amount * (-1);
                    Map<String,Object> creditAdjustment = new Map<String, Object>();
                    creditAdjustment.put('SourceTransactionNumber', zObj.getValue('InvoiceNumber'));
                    creditAdjustment.put('Amount', amount);
                    creditAdjustment.put('Type', 'Increase');
                    creditAdjustment.put('ReferenceId', zObj.getValue('Id'));
                    listCBMap.add(creditAdjustment);
                }
            }catch(exception e)
            {
                system.debug(e);
            }
            //END PD-0202 FrancisBenzon 20May16 : catch invalid conversion error           
        }
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

    //Method that Transfers Credit Balance from other Billing Accounts to the Existing Billing Account
    public static void transferCreditBalances(list<Zuora.zObject> zobjs, ZuoraCallOut zCallOut) {     
        Set<String> setBAIdsForInv = new Set<String>(); //These are the BAs where the generated Invoices belongs to
        Set<Id> setSFAccountIDs = new Set<Id>(); 
        lstBAs = new List<Zuora__CustomerAccount__c>();
        Map<Id, List<Zuora__CustomerAccount__c>> mapAccIdToAllBAs = new Map<Id, List<Zuora__CustomerAccount__c>>();
        List<Map<String, Object>> listRefundMap = new List<Map<String, Object>>();
        List<Map<String, Object>> listPaymentMap = new List<Map<String, Object>>();
                
        for(Zuora.zObject zObj: zobjs)
        {
            String targetBAId = (String)zObj.getValue('AccountId');
            if (targetBAId != null) {
                setBAIdsForInv.add(targetBAId);
                setSFAccountIDs.add(mapBAZuoraIdToAccountId.get(targetBAId));
            }
        }
        
        if(!setSFAccountIDs.isEmpty()){
            lstBAs = [SELECT Zuora__AccountNumber__c, Zuora__External_Id__c, Zuora__Credit_Balance__c, Zuora__Account__c, Other_PaymentMethod__c,
                      Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c, 
                      Zuora__Balance__c, Payment_Mode__c, Billing_Type__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN: setSFAccountIDs];
        }
        
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
        
        //Transfer Credit Balance Step 1A: Perform Refund Transactions to withdraw Credit Balance from Other Billing Accounts
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
                        refundMap.put('Type', 'External' );  
                        refundMap.put('MethodType', 'Other' );                   
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
        
        //Transfer Credit Balance Step 1B: Perform Payment Transaction to deposit the Refunded Credit Balance to Target BA
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

    //Method that applies the Credit Balance to Invoice Amount (if > 0)
    public static void applyCreditBalance(List<Zuora.zObject> zobjs, ZuoraCallOut zCallOut) {
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
            
            if(creditAmtToApply > 0)
            {
                Map<String, Object> creditBalanceMap = new Map<String, Object>();
                creditBalanceMap.put('Amount', creditAmtToApply); 
                creditBalanceMap.put('Type', 'Decrease');
                creditBalanceMap.put('SourceTransactionId', zObj.getValue('Id'));
                listCBMap.add(creditBalanceMap);
                
                // Start PD-0266 21May16 JohnD - added logic for credit balance deduction
                newCreditBalance = totalCreditBalance - creditAmtToApply;
                mapInvBAToTotalCBAmt.put(targetBAId, newCreditBalance);
                system.debug('------------newCreditBalance: '+newCreditBalance);
                // End PD-0266 21May16 JohnD - added logic for credit balance deduction
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

    //Method that creates payment
    public static void processPayment (List<Zuora.zObject> zobjs, ZuoraCallOut zCallOut) {
        Set<Id> setENetsAcctID = new Set<Id>();
        List<BT_CO_STPPRS_StopPressSubscription__c> lstStopPress;
        Map<Id, String> mapAcctIdToPayNum = new Map<Id, String>();
        List<Map<String, Object>> lstPaymentMap = new List<Map<String, Object>>();

        Set<Id> baIds = new Set<Id>();
        List<Zuora__CustomerAccount__c> lstBillAcc = new List<Zuora__CustomerAccount__c>();
        Map<String, String> mapBAToPayMet = new Map<String, String>();
        Set<String> setBAExId = new Set<String>();
        List<Zuora.zObject> zobjsPayMet = new List<Zuora.zObject>();
        final string BA_CREATION_MODE_EXISTING = 'Use existing Billing Account';    // Start/End PD-0266 23May16 JohnD
        
        for(Zuora.zObject zObj: zobjs)
        {
            String targetBAId = (String)zObj.getValue('AccountId');
            Zuora__CustomerAccount__c billingAcct = mapBAZuoraIdToBA.get(targetBAId);
            
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
        
        for(Zuora__CustomerAccount__c billAcc: mapBAZuoraIdToBA.values()){
            baIds.add(billAcc.Id);
        }
        System.debug('>>>rr 7 baIds: ' + baIds);
        if(baIds.size() > 0){
            // Start PD-0266 23May16 JohnD - update query
            lstBillAcc = [SELECT Id, Zuora__External_Id__c, Zuora__DefaultPaymentMethod__c,(SELECT id, Order_Number_1__r.Payment_Method_ID__c, Order_Number_1__r.Billing_Account_Creation_Mode__c 
                    From Zuora__Subscriptions__r order by createddate desc LIMIT 1)
                          FROM Zuora__CustomerAccount__c WHERE Id IN:baIds];
            // End PD-0266 23May16 JohnD - update query
        }
        System.debug('>>>rr 8 lstBillAcc: ' + lstBillAcc);
        for(Zuora__CustomerAccount__c ba : lstBillAcc){
            if(ba.Zuora__DefaultPaymentMethod__c != GlobalVariableClass.CASH
            && ba.Zuora__DefaultPaymentMethod__c != GlobalVariableClass.CHEQUE && ba.Zuora__DefaultPaymentMethod__c != GlobalVariableClass.OTHER){
                if(!setBAExId.contains(ba.Zuora__External_Id__c)){
                    // Start PD-0266 23May16 JohnD - added logic
                    for(Zuora__Subscription__c subsMap : ba.Zuora__Subscriptions__r) {
                        if (subsMap.Order_Number_1__r.Billing_Account_Creation_Mode__c == BA_CREATION_MODE_EXISTING) {
                            setBAExId.add(ba.Zuora__External_Id__c);
                        } else {
                            mapBAToPayMet.put(ba.Zuora__External_Id__c, subsMap.Order_Number_1__r.Payment_Method_ID__c);
                        }
                    }
                    // End PPD-0266 23May16 JohnD - added logic
                }
            }
        } 

        // Start PD-0266 23May16 JohnD - commented out
        /*
        if(setBAExId.size() > 0){
            zobjsPayMet = zCallOut.bulkQueryPayMet(setBAExId);
        }

        if(zobjsPayMet.size() > 0){
            for(Zuora.zObject zo: zobjsPayMet){
                String baId = (String)zo.getValue('Id');
                if(!mapBAToPayMet.containsKey(baId)){
                    mapBAToPayMet.put(baId,(String)zo.getValue('DefaultPaymentMethodId'));
                }
            }
        }
        */
        // End PD-0266 23May16 JohnD - commented out

        // Start PD-0266 23May16 JohnD - apply logic same with direct individual
        if (!setBAExId.isEmpty()) {

            for (Zuora__CustomerAccount__c billingAccount : [select Zuora__External_Id__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c 
                    from Zuora__CustomerAccount__c where Zuora__External_Id__c in :setBAExId]) {
                
                mapBAToPayMet.put(billingAccount.Zuora__External_Id__c, billingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);     
            }           
        }
        // End PD-0266 23May16 JohnD - apply logic same with direct individual
        
        for(Zuora.zObject zObj: zobjs)
        {
            String targetBAId = (String)zObj.getValue('AccountId');
            //Decimal remainingAmt = mapInvBAToRemainingAmt.get(targetBAId);    // Start/End PD-0266 22May16 JohnD - commented out
            Decimal remainingAmt = invoiceZuoraId_adjustedBalance.get((String)zObj.getValue('Id')); // Start/End PD-0266 22May16 JohnD
            Zuora__CustomerAccount__c billingAcct = mapBAZuoraIdToBA.get(targetBAId);
            Id orderId = mapBAZuoraIdToOrderID.get(targetBAId);
            System.debug('>>>rr 11a remainingAmt >>>'+ remainingAmt);
            if(targetBAId != null && remainingAmt != null && billingAcct != null && orderId != null && remainingAmt >= 0) //start/end rom 10/13 //START-END D-3601 10/29/2015 Added by J.Sarion - create payment for non-negative reamaining amount
            {
                //Only create payment for FPP Billing Accounts
                System.debug('>>> RReyes 01/22: billingAcct::: ' + billingAcct);
                if(billingAcct.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE){
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
                    else if (billingAcct.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.OTHER && remainingAmt > 0) { // Start/End PD-0266 22May16 JohnD - added " && remainingAmt > 0"
                        paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other'));
                        paymentMap.put('Amount', remainingAmt);                 
                        paymentMap.put('Type', 'External');

                        if(billingAcct.Other_PaymentMethod__c == 'eNets'){
                            if(billingAcct.Zuora__Account__c != null && mapAcctIdToPayNum.containsKey(billingAcct.Zuora__Account__c))
                                paymentMap.put('Comment', 'eNets Payment Number: ' + mapAcctIdToPayNum.get(billingAcct.Zuora__Account__c));
                        }
                    }
                    else if(remainingAmt > 0) { // Start/End PD-0266 22May16 JohnD - added "if(remainingAmt > 0)"
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
        }

    }
    
    //START D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
    //START 11 March 2016 UD-3247 Kevin Evasco - Immediate CB to true for Negative Invoices
    public static void updateInvoiceImmediateCB(List<Map<String, Object>> negativeInvoiceMapList){
        
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        Logger loggerParam = new Logger(invoicePostProcessingForDirectCorp.class.getName());
        try {   
            List<Map<String,String>> resultMap = zCallout.updateZObjects(negativeInvoiceMapList, 'Invoice');
             for(Map<String,String> result :resultMap){
                if(result.get('Status') == 'Success') {                      
                    system.debug('Successful Negative Invoice Immediate CB Update'); 
                }
                else {
                    loggerParam.log(false,result.get('Message'));                                                     
                } 
             }
        } catch (exception ze) {
              loggerParam.log(ze);
        }
        loggerParam.save();//Start/End UD-3890 09-Apr-2016 Added by S.Puli
    }
    //END 11 March 2016 UD-3247 Kevin Evasco - Immediate CB to true for Negative Invoices 
    //END D-4588 04 April 2016 Kevin Evasco - Zuora Invoice - Immediate CB to true
    //Start UD-3890 09-Apr-2016 Added by S.Puli 
    public static void updateInvPrevBalanceForCorp(List<Zuora.zObject> zobjs, ZuoraCallOut zCallOut){
        
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