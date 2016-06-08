/**
 * Class Name: RefundButtonExtension
 * @authors: Kay Lorica
 * Date: 9/4/2014
 * Requirement/Project Name: SPH
 * @description 
 * HISTORY
 * UD-1419 7/20/2015 Alyana Navarro
 * 
 **/
public class RefundButtonExtension {

public Case thisCase {get;set;}
ZuoraCallOut RefundCallOut = new ZuoraCallOut();
Zuora.zApi zApiInstance = new Zuora.zApi();

    /*
    *Query all created process refund in current case record
    *Log in to Zuora for Call out
    */ 
//Start 06/13/2015 UD-1537 James
String CSOProfile = ConstantsSLB.getOther('CSO');
String SysAdminProfile = ConstantsSLB.getOther('System Administrator');
String SysAdmin2Profile = ConstantsSLB.getOther('SPH System Admin 2');
//End 06/13/2015 UD-1537 James

final static string CREDIT_CARD = 'CreditCard';	// Start/End D-4592 07Apr16 JohnD

public RefundButtonExtension(ApexPages.StandardController controller) {

    //START D-3268 Modified By C.I.Salas - Test Coverage
    if (!Test.isRunningTest()) {
        zApiInstance.zlogin();
    }
    //END D-3268 Modified By C.I.Salas - Test Coverage
    
    //START UD-0981 5/7/2015 KEstoya - Added Case_Refund_Check__c
    //START [UD_0887] RBustarde 19/05/2015                                  
    //Start 06/13/2015 UD-1537 James - added Owner.Id and Owner.Profile.Name field 
    //START/END UD-1612 18-06-2015 Marvin Gatchalian added Payment_Method_ID__c field
    thisCase = [SELECT Id, Case_Refund_Check__c, Payment_Method_ID__c, AccountId, Approved_Refund__c, Amount_to_Refund__c, Payee_Name__c, Payment_Mode__c, Status, Owner.Id, Owner.Profile.Name FROM Case WHERE Id = :controller.getRecord().Id];     //Start-END UD-0728 K. Tan 4/17/205 - to not create refund once case is closed
    //End 06/13/2015 UD-1537 James
    //END [UD_0887] RBustarde 19/05/2015                                    
    //END UD-0981 5/7/2015 KEstoya - Added Case_Refund_Check__c

}
    
    public void activateRefund(){
        List<Map<String, String>> resultsMap = new List<Map<String, String>>();
        List<Zuora__CustomerAccount__c> cAccounts = new List<Zuora__CustomerAccount__c>();
        List<Zuora__CustomerAccount__c> invoiceBillAccList = new List<Zuora__CustomerAccount__c>(); //Start Add SRPULI 11132014 END
        Zuora__Refund__c thisRefund = new Zuora__Refund__c();
        Zuora__Payment__c zpayment = new Zuora__Payment__c();
        Set<Id> billAccIdSet = new Set<Id>();
        Contact contactRec;
        //Start RBustarde D-0589
        Map<String,Object> BAmap = new Map<String, Object>();//Start Add RBustarde 04152015 END
        String BAPaymentMode;
        String BAacctNum;
        String ErrMsg;
        //End RBustarde D-0589 
        //Start CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded Value
        Integer maxLimit = integer.valueOf(GlobalVariableClass.REFUND_MAXLIMIT);
        Integer minLimit = integer.valueOf(GlobalVariableClass.REFUND_MINLIMIT);
        //End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded Value        
        
        //Start: UD-0572 04/07/2015 Jason Abolac
        
        //Start UD-0728 K. Tan 4/17/205 - to not create refund once case is closed
        if (thisCase.Status != 'Closed') {
        //END UD-0728 K. Tan 4/17/205 - to not create refund once case is closed
        //START UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
            //Start 06/13/2015 UD-1537 James - check user profile
            Id profileId = userinfo.getProfileId();
            Id currentUserId = UserInfo.getUserId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
      Boolean withEditAccess;
      
      if (profileName != SysAdminProfile && profileName != SysAdmin2Profile){
        if(profileName == thisCase.Owner.Profile.Name){
          if(currentUserId == thisCase.Owner.Id){
            withEditAccess = true;
          }else{
            withEditAccess = false;
          }
        }else{
          withEditAccess = true;
        }
      }else{
        withEditAccess = true;
      }    
            
      If(withEditAccess == false){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('Insufficient Privileges')));
            }else{
                if (thisCase.Case_Refund_Check__c != true) {
                //END UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click

                    if(thisCase.AccountId != null && thisCase.Approved_Refund__c == TRUE){
                    //End: UD-0572 04/07/2015 Jason Abolac
                        if(thisCase.Payment_Mode__c=='Cheque'){
                    
                        //JA remove Zuora__PaymentMethod_Type__c!=NULL in the query
                        //START: D-1707 K. Tan Payment Maintenance creation of Payment Record
                        //START / END UD-1612 18-06-2015 Marvin Gatchalian added Zuora__CustomerAccount__c.Zuora__Default_Payment_Method__r field
                        //START UD-3092 16Mar16 FrancisBenzon : added Credit_Balance_Incl_Goodwill__c in query for reference
                        cAccounts = [SELECT Id, Zuora__CustomerAccount__c.Zuora__Default_Payment_Method__r.Zuora__External_Id__c, Zuora__Zuora_Id__c, Zuora__AccountNumber__c, Refund_Amount__c, Zuora__External_Id__c, Name, Zuora__PaymentMethod_Type__c, Zuora__Account__c, Payment_Mode__c, Credit_Balance_Incl_Goodwill__c
                                        FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c = :thisCase.AccountId AND Refund_Amount__c != 0];       
                        
                        } 
                        else{
                          
                        //START / END UD-1612 18-06-2015 Marvin Gatchalian added Zuora__CustomerAccount__c.Zuora__Default_Payment_Method__r field
                        // Start D-4592 07Apr16 JohnD - added Zuora__CreditCardType__c field
                        cAccounts = [SELECT Id, Zuora__CustomerAccount__c.Zuora__Default_Payment_Method__r.Zuora__External_Id__c, Zuora__Zuora_Id__c, Zuora__AccountNumber__c, Refund_Amount__c, Zuora__External_Id__c, Name, Zuora__PaymentMethod_Type__c, Payment_Mode__c, Zuora__Account__c, Credit_Balance_Incl_Goodwill__c, Zuora__CreditCardType__c, Zuora__DefaultPaymentMethod__c 
                                        FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c = :thisCase.AccountId AND Refund_Amount__c != 0];
                        
                        // End D-4592 07Apr16 JohnD - added Zuora__CreditCardType__c field
                        //END: D-1707 K. Tan Payment Maintenance creation of Payment Record
                                        
                        invoiceBillAccList = [SELECT Id, Zuora__Zuora_Id__c, Refund_Amount__c, Zuora__External_Id__c, Name, Zuora__PaymentMethod_Type__c, Payment_Mode__c, Zuora__Account__c, Other_PaymentMethod__c, ARMS_Account_Number__c, Credit_Balance_Incl_Goodwill__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c = :thisCase.AccountId AND Other_PaymentMethod__c = 'Invoice']; 
                        //END UD-3092 16Mar16 FrancisBenzon : added Credit_Balance_Incl_Goodwill__c in query for reference
                            if(invoiceBillAccList<>null && invoiceBillAccList.size()>0){
                                for(Zuora__CustomerAccount__c bRec : invoiceBillAccList){
                                    billAccIdSet.add(bRec.Id);
                                }
                            }
                        }
                        
                        if(thisCase.Payment_Mode__c =='Cheque'){
                            thisCase.Payment_Mode__c = 'Check';
                        }
                        //START: KLorica 1/16/2015 Remove system.debug & for loop FOR D-1707 & remove commented trycatch lines.
                        //START: RBustarde 04/15/2015 D-0589 Payment Mode not equal to check should display an error                        
                        for(Zuora__CustomerAccount__c baRec : cAccounts){

                            BAPaymentMode = baRec.Payment_Mode__c;
                            BAacctNum = baRec.Zuora__AccountNumber__c;      
                                    
                        }
                        system.debug('BA Account Number ---------->'+ BAacctNum);
                        system.debug('>>>>>>>> ----> cAccount Payment Mode = ' + BAPaymentMode);
                        system.debug('>>>>>>>> ----> This Case Payment Mode = ' + thisCase.Payment_Mode__c);
                        
                        ErrMsg = 'Error creating refund. Billing Account Payment mode  : '+ BAPaymentMode;            
                        //START-END UD-0573 Jason Abolac 04/27/2015 comment out
                        //if((BAPaymentMode != thisCase.Payment_Mode__c) && thisCase.Payment_Mode__c!='Check')
                        //{
                        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ErrMsg));
                        // }
                        //else
                        //{
                        //START-END UD-0573 Jason Abolac 04/27/2015 comment out             
                        //END: RBustarde 04/15/2015 D-0589 Payment Mode not equal to check should display an error
                    
                            if (thisCase.Payment_Mode__c == 'Paypal') {
                                //START [UD_0887] RBustarde 19/05/2015                                  
                                system.debug('------------>>PAYPAL<<--------------');
                                // START : D-2982 6/8/2015 Alyana Navarro
                                // START : UD-3287 11/19/2015 K. Tan
                                thisRefund = [SELECT Id, Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, Zuora__Amount__c, Payee__c,
                                              Zuora__RefundDate__c, Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c
                                              FROM Zuora__Refund__c 
                                              WHERE Case__c = :thisCase.Id];
                                try{              
                                zpayment = [SELECT id, Zuora__External_Id__c FROM Zuora__Payment__c WHERE Zuora__BillingAccount__c =: thisRefund.Zuora__BillingAccount__c  AND Zuora__Type__c != 'External' AND Zuora__Status__c != 'Error' ORDER BY CreatedDate DESC LIMIT 1 ];
                                }
                                catch (exception ze) {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ('No Electronic Payment tied for this Billing Account')));
                                
                                
                                }
                                // END : D-2982 6/8/2015 Alyana Navarro
                                //END [UD_0887] RBustarde 18/05/2015                                    
                                system.debug('subscription' + thisRefund);          
                                    Map<String,Object> refundMap = new Map<String, Object>();
                                    refundMap.put('AccountId', thisRefund.Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c);
                                    //refundMap.put('PaymentMethodId', thisRefund.Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
                                    refundMap.put('PaymentId', zpayment.Zuora__External_Id__c);                                    
                                    refundMap.put('Amount', thisRefund.Zuora__Amount__c);                                   
                                    refundMap.put('SourceType', 'Payment');                    
                                    refundMap.put('Type', 'Electronic');
                                    //refundMap.put('Type', 'External');  
                                    //refundMap.put('MethodType', 'PayPal');
                                    //START UD-2252 AddedBy FrancisBenzon 10/23/15 : populate case field in refund record 
                                    refundMap.put('Case_1__c', thisCase.id);
                                    //END UD-2252 AddedBy FrancisBenzon 10/23/15 : populate case field in refund record
                                    //UD-1031
                                    
                                    Zuora__Payment__c payment;
                                    payment = [SELECT Id, Zuora__ReferenceId__c, Zuora__EXT_ID__c FROM Zuora__Payment__c WHERE Zuora__PaymentMethod__c LIKE '%PayPal%' AND Zuora__ReferenceId__c != null AND Zuora__BillingAccount__c =: thisRefund.Subscription__r.Zuora__CustomerAccount__c Order by Zuora__CreatedDate__c DESC LIMIT 1];
                                    
                                    if(payment == null) {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('NoExistingPaymentForPayPal')));
                                    }
                                    else {
                                        //refundMap.put('Type', 'External');
                                        refundMap.put('PaymentId', payment.Zuora__EXT_ID__c);
                                    }
                                    //END UD-3287 11/29/2015 Added by J.Sarion - Check if there's an existing Payment with PayPal
                                    
                                    datetime d = system.now();
                                    datetime dt = datetime.newinstance(d.year(), d.month(), d.day(), d.hour(), d.minute(), d.second());
                                    string dFormat = (string.valueOf(dt)).replaceAll( '\\s+', 'T'); 
                                    //refundMap.put('RefundDate', dFormat);
                                    // END : UD-3287 11/19/2015 K. Tan
                                    system.debug('RefundMap--------------'+refundMap);
                                //START: D-1710 KLorica 1/22/2015 Added trycatch
                                try {   
                                    Map<String,String> resultMap = RefundCallOut.createZObject(refundMap, 'Refund');
                                     if(resultMap.get('Status') == 'Success') {
                                         
                                        //START UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                                         thisCase.Case_Refund_Check__c = true;
                                        //END UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click                                
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('SuccessfullyCreatedRefund'))); 
                                    }
                                    else {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA')));
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + resultMap.get('Message')));
                                        
                                    }
                                    //END: D-1710 KLorica 1/22/2015 Added trycatch
                                    thisRefund.Zuora__External_Id__c = resultMap.get('Id');                 
                                    update thisRefund;
                                    //START UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                                    update thisCase;
                                    //END UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                                    system.debug('RefundMap--------------'+refundMap);
                                } catch (exception ze) {
                                    ApexPages.addMessages(ze);
                                }
                                
                            }
                            
                            if(thisCase.Payment_Mode__c == 'Invoice') {

                            //START ADD SRPULI PAYMENT MODE = INVOICE, Generation of Credit Note   
                                //START UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text
                                
                                List<Case> latestCreditNum = [Select Id, Credit_Note_Number__c From Case Where Credit_Note_Number__c != null Order By Credit_Note_Number__c DESC limit 1];
                                //Start CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded Value                
                                if(latestCreditNum<>null && latestCreditNum.size()>0){
                                    for(Case c : latestCreditNum){
                                        if(c.Credit_Note_Number__c<>null && c.Credit_Note_Number__c <> maxLimit) {
                                            thisCase.Credit_Note_Number__c = c.Credit_Note_Number__c+1;
                                        } else if(c.Credit_Note_Number__c<>null && c.Credit_Note_Number__c == maxLimit){
                                            thisCase.Credit_Note_Number__c = minLimit;
                                        }
                                    }
                                } else if(latestCreditNum == null || latestCreditNum.size() == 0){
                                    thisCase.Credit_Note_Number__c = minLimit;
                                }
                                
                                //END UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text
                                //End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded Value                
                                List<Map<String, Object>> listMap = new List<Map<String, Object>>();
                                
                                Account accRec = [Select Id, Name, Account_Auto_Number__c from Account Where Id = :thisCase.AccountId];
                                System.debug('invoiceBillAccList: ' + invoiceBillAccList);                              
                                if(invoiceBillAccList<>null && invoiceBillAccList.size()>0){
                                    for(Zuora__CustomerAccount__c ba : invoiceBillAccList){
                                        System.debug('Refund_Amount__c: ' + ba.Refund_Amount__c);
                                        //START UD-3092 16Mar16 FrancisBenzon :added condition
                                        if(ba.Refund_Amount__c != null && ba.Refund_Amount__c != 0 && ba.Credit_Balance_Incl_Goodwill__c != 0){ 
                                        //END UD-3092 16Mar16 FrancisBenzon :added condition
                                        //START-END UD-0573 Jason Abolac 04/27/2015
                                            Map<String,Object> refundMap = new Map<String, Object>();
                                            refundMap.put('AccountId', ba.Zuora__External_Id__c);                    
                                            refundMap.put('Amount', ba.Refund_Amount__c);                                   
                                            refundMap.put('SourceType', 'CreditBalance');                    
                                            refundMap.put('Type', 'External');  
                                            refundMap.put('Case_1__c', thisCase.id);
                                            if(thisCase.Payment_Mode__c=='Invoice'){
                                                refundMap.put('MethodType', 'Other');
                                                refundMap.put('OtherPaymentMethod__c',thisCase.Payment_Mode__c);
                                            } else{
                                                refundMap.put('MethodType', thisCase.Payment_Mode__c );     
                                            }
                                            
                                            listMap.add(refundMap);
                                            system.debug('ba.Refund_Amount__c' + ba.Refund_Amount__c);
                                            system.debug('refundMap' + refundMap);
                                        } //START-END UD-0573 Jason Abolac 04/27/2015
                                    }                                   
                                }   
                                for(Map<String, Object> b: listMap){
                                }
                                system.debug('listMap' + listMap);
                                //START UD-3092 16Mar16 FrancisBenzon : for test class
                                Map<String,String> resultMap = new Map<String,String>();
                                if (!Test.isRunningTest()) {
                                    resultMap = RefundCallOut.createMultipleZObjectForRefund(listMap, 'Refund'); 
                                    system.debug('resultMap1' + resultMap);                                 
                                }
                                else {                              
                                    resultMap.put('Status', 'Success');
                                    system.debug('resultMap2' + resultMap);
                                }
                                //END UD-3092 16Mar16 FrancisBenzon : for test class
                                
                                    if(resultMap.get('Status') == 'Success') { 
                                                                        
                                    
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('SuccessfullyCreatedRefund'))); 
                                        
                                        //START UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                                        thisCase.Case_Refund_Check__c = true;
                                        system.debug('case check after success' + thisCase.Case_Refund_Check__c);
                                        //END UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                                        
                                        if(invoiceBillAccList<>null && invoiceBillAccList.size()>0){
                                        
                                            Map<String, String> invoiceToInvoiceLineMap = new Map<String, String>();
                                            
                                            if(thisCase.ContactId<>null){
                                                contactRec = [Select Id, Name, Recipient_Number__c From Contact Where ID = :thisCase.ContactId limit 1];
                                            }           
                                            
                                            //START: D-2484 VPernicia 3/12/2015: Change the criteria to use Zuora__TotalAmount__c instead of Zuora__Balance__c   
                                            List<Zuora__ZInvoice__c> invoiceList = [Select Id, Name, Zuora__BillingAccount__c, Zuora__Zuora_Id__c, Zuora__Balance2__c, Refund_Indicator__c, Zuora__TaxAmount__c, Zuora__AmountWithoutTax__c, Zuora__DueDate__c From Zuora__ZInvoice__c Where Zuora__BillingAccount__c IN :billAccIdSet AND Zuora__TotalAmount__c<0 AND Refund_Indicator__c =false];
                                            //END: D-2484 VPernicia 3/12/2015: Change the criteria to use Zuora__TotalAmount__c instead of Zuora__Balance__c 
                                            Set<String> invIdSet = new Set<String>();
                                            Map<Id, List<Zuora__ZInvoice__c>> billAccountInvoiceListMap = new Map<Id, List<Zuora__ZInvoice__c>>(); // START-END : D-2982 5/27/2015 Alyana Navarro
                                            if(invoiceList<>null && invoiceList.size()>0){
                                                for(Zuora__ZInvoice__c zInv : invoiceList){
                                                    invIdSet.add(zInv.Zuora__Zuora_Id__c);
                                                    
                                                    // START : D-2982 5/27/2015 Alyana Navarro
                                                    if(billAccountInvoiceListMap.containsKey(zInv.Zuora__BillingAccount__c)){
                                                        billAccountInvoiceListMap.get(zInv.Zuora__BillingAccount__c).add(zInv);
                                                    } else {
                                                        billAccountInvoiceListMap.put(zInv.Zuora__BillingAccount__c, new List<Zuora__ZInvoice__c>{zInv});
                                                    }
                                                    // END : D-2982 5/27/2015 Alyana Navarro
                                                }
                                            }
                                            
                                            // START : D-2982 6/1/2015 Alyana Navarro
                        // START : D-3136 6/22/2015 Alyana Navarro
                                            List<Invoice_Line_Item__c> invLineList = [Select Id, Name, Rate_Plan_Charge_ID__c , Product_ID__c, Invoice_ID__c, Service_End_Date__c,Service_Start_Date__c, Tax_Amount__c, Accounting_Code__c, Charge_Amount__c, Applied_To_Invoice_Item_ID__c, ID__c, Subscription_ID__c, Subscription__r.Subscription_Type_1__c From Invoice_Line_Item__c Where Invoice_ID__c IN :invIdSet];
                                            // END : D-3136 6/22/2015 Alyana Navarro                                     
                                            Set<String> ProductSet = new Set<String>();
                                            Set<String> subProdZuoraIDSet = new Set<String>();
                                            Set<String> subZuoraIdSet = new Set<String>();
                                            List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
                                            List<Zuora__SubscriptionProductCharge__c> subProdChargeDiscountList = new List<Zuora__SubscriptionProductCharge__c>();
                                            Map<String, Id> invLineToProdMap = new Map<String, Id>();
                                            Map<String, Zuora__SubscriptionProductCharge__c> zuoraIdSubProdChargeMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
                                            Map<String, Zuora__SubscriptionProductCharge__c> zuoraIdSubProdChargeDiscountMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
                                            Map<String, List<Invoice_Line_Item__c>> invoiceIdInvoiceLineListMap = new Map<String, List<Invoice_Line_Item__c>>();
                                            Map<Id, Decimal> invoiceLineIdDiscountMap = new Map<Id, Decimal>();
                                            
                                            if(invLineList<>null && invLineList.size()>0){
                                                for(Invoice_Line_Item__c invL : invLineList){
                                                    ProductSet.add(invL.Product_ID__c);
                                                    invLineToProdMap.put(invL.Product_ID__c, invL.Id);
                                                    subProdZuoraIDSet.add(invL.Rate_Plan_Charge_ID__c);
                                                    subZuoraIdSet.add(invL.Subscription_ID__c);
                        // START : D-3136 6/22/2015 Alyana Navarro
                            if(invL.Subscription__r.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION){
                                if(invoiceIdInvoiceLineListMap.containsKey(invL.Invoice_ID__c)){
                                    invoiceIdInvoiceLineListMap.get(invL.Invoice_ID__c).add(invL);
                                } else {
                                    invoiceIdInvoiceLineListMap.put(invL.Invoice_ID__c, new List<Invoice_Line_Item__c>{invL});
                                }
                            }
                                                }
                                            }                                           
                            Map<String, Zuora__SubscriptionProductCharge__c> allSubProdChargeMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
                                            subProdChargeList = [SELECT id, name, Zuora__External_Id__c, Zuora__Price__c, Zuora__Subscription__r.Zuora__Zuora_ID__c, Zuora__Subscription__r.Subscription_Type_1__c, PublicationCode__c
                                                                 FROM Zuora__SubscriptionProductCharge__c 
                                                                 WHERE Zuora__External_Id__c IN: subProdZuoraIDSet];
                                                                    //AND Zuora__Price__c < 0  - for deletion
                                                                    //AND Zuora__Subscription__r.Subscription_Type_1__c = 'Publication']; - for deletion
                                            
                                            subProdChargeDiscountList = [SELECT id, name, Zuora__Price__c, Zuora__Subscription__r.Zuora__Zuora_ID__c
                                                                         FROM Zuora__SubscriptionProductCharge__c
                                                                         WHERE Zuora__ProductName__c LIKE '%Discount%' AND Zuora__Subscription__r.Zuora__Zuora_ID__c IN: subZuoraIdSet AND Zuora__Subscription__r.Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION];
                                
                                            for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){
                        if(subProdCharge.Zuora__Price__c < 0 && subProdCharge.Zuora__Subscription__r.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION){
                            zuoraIdSubProdChargeMap.put(subProdCharge.Zuora__External_Id__c, subProdCharge);
                        }
                        allSubProdChargeMap.put(subProdCharge.Zuora__External_Id__c, subProdCharge);
                                            }                                                                                       
                        // END : D-3136 6/22/2015 Alyana Navarro
                                            for(Zuora__SubscriptionProductCharge__c subProdChargeDiscount : subProdChargeDiscountList){
                                                zuoraIdSubProdChargeDiscountMap.put(subProdChargeDiscount.Zuora__Subscription__r.Zuora__Zuora_ID__c, subProdChargeDiscount);
                                            }
                                            
                                            for(Invoice_Line_Item__c invoiceLine : invLineList){
                                                if(zuoraIdSubProdChargeMap.containsKey(invoiceLine.Rate_Plan_Charge_ID__c)){
                                                    Zuora__SubscriptionProductCharge__c subProdCharge = zuoraIdSubProdChargeMap.get(invoiceLine.Rate_Plan_Charge_ID__c);
                                                    if(zuoraIdSubProdChargeDiscountMap.containsKey(subProdCharge.Zuora__Subscription__r.Zuora__Zuora_ID__c)){
                                                        Zuora__SubscriptionProductCharge__c subProdChargeDiscountRec = zuoraIdSubProdChargeDiscountMap.get(subProdCharge.Zuora__Subscription__r.Zuora__Zuora_ID__c);
                                                        Decimal totalAmount = (-1 * subProdCharge.Zuora__Price__c) / (100 - subProdChargeDiscountRec.Zuora__Price__c.setScale(2))*100;
                                                        Decimal discount = totalAmount - (-1 * subProdCharge.Zuora__Price__c);
                                                        invoiceLineIdDiscountMap.put(invoiceLine.id, discount.setScale(2));
                                                    }
                                                }
                                            }
                                            // END : D-2982 6/1/2015 Alyana Navarro
                                            
                                            system.debug('ProductSet'+ProductSet);
                                            List<zqu__ZProduct__c> zProdList = [Select Id, Name, zqu__ZuoraId__c, ProductSubType__c From zqu__ZProduct__c Where zqu__ZuoraId__c IN :ProductSet];
                                            Set<Id> zProdSet = new Set<Id>();
                                            Map<Id, String> salesTypeMap = new Map<Id, String>();
                                            
                                            if(zProdList<>null && zProdList.size()>0){
                                                for(zqu__ZProduct__c zProd : zProdList){
                                                    salesTypeMap.put(invLineToProdMap.get(zProd.zqu__ZuoraId__c),zProd.ProductSubType__c);
                                                    zProdSet.add(zProd.Id);
                                                }
                                            }
                                            system.debug('zProdSet'+zProdSet);
                                            List<Product_Publication__c> prodPubList = [Select Id, Name, Publication_Code__r.Publication_Code__c, ZProduct__r.zqu__ZuoraId__c, Product_Code__c From Product_Publication__c Where ZProduct__c IN :zProdSet];
                                            Set<Id> zProdPub = new Set<Id>();
                                            Map<Id, String> pubMap = new Map<Id, String>();
                                            
                                            if(prodPubList<>null && prodPubList.size()>0){
                                                for(Product_Publication__c prodPub : prodPubList){
                                                    zProdPub.add(prodPub.Id);
                                                    pubMap.put(invLineToProdMap.get(prodPub.ZProduct__r.zqu__ZuoraId__c),prodPub.Publication_Code__r.Publication_Code__c);
                                                }
                                            }
                                            // START : UD-1419 7/20/2015 Alyana Navarro
                                            /*
                                            List<Credit_Note__c> credList = new List<Credit_Note__c>();
                                            List<Zuora__ZInvoice__c> invRefIndList = new List<Zuora__ZInvoice__c>();
                                            String gstRate = Other__c.getInstance('GST').Value__c;                                          
                                            for(Zuora__CustomerAccount__c baRec : invoiceBillAccList){
                                                if(billAccountInvoiceListMap.containsKey(baRec.id)){
                                                    for(Zuora__ZInvoice__c zInvRec : billAccountInvoiceListMap.get(baRec.id)){
                                                        if(invoiceIdInvoiceLineListMap.containsKey(zInvRec.Zuora__Zuora_ID__c)){
                                                            for(Invoice_Line_Item__c invLineRec : invoiceIdInvoiceLineListMap.get(zInvRec.Zuora__Zuora_ID__c)){
                                                                Credit_Note__c credRec = new Credit_Note__c();
                                                                // START : D-2982 5/21/2015 Alyana Navarro
                                                                //START UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text
                                                                
                                                                if(thisCase.Credit_Note_Number__c<>null){
                                                                    credRec.Credit_Note_Number__c = '0000'+string.valueOf(thisCase.Credit_Note_Number__c);
                                                                }
                                                                credRec.Related_Case__c = thisCase.Id;
                                                                //END UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text
                                                                if(baRec.ARMS_Account_Number__c<>null){
                                                                    credRec.Account_Number__c = baRec.ARMS_Account_Number__c;
                                                                }
                                                                if(zInvRec.Name<>null){
                                                                credRec.Invoice__c = zInvRec.Name;
                                                                }
                                                                if(zInvRec.Id<>null){
                                                                credRec.Invoice_ID__c = zInvRec.Id;
                                                                }
                                                                if(salesTypeMap.get(invLineRec.Id)<>null){
                                                                        String salestype = salesTypeMap.get(invLineRec.Id);
                                                                        String salestypeKey;
                                                                        if(salestype<>null){
                                                                            if(salestype == 'Newspaper'){
                                                                                salestypeKey = 'S';
                                                                            } else if(salestype == 'Magazine'){
                                                                                salestypeKey = 'N';
                                                                            }
                                                                        }
                                                                    credRec.Sales_Type__c = salestypeKey;
                                                                }
                                // START : D-3136 6/22/2015 Alyana Navarro
                                if(allSubProdChargeMap.containsKey(invLineRec.Rate_Plan_Charge_ID__c)){
                                    credRec.Publication__c = allSubProdChargeMap.get(invLineRec.Rate_Plan_Charge_ID__c).PublicationCode__c;
                                }
                                                                
                                // END : D-3136 6/22/2015 Alyana Navarro
                                                                if(accRec.Account_Auto_Number__c<>null){
                                                                    credRec.Synonym__c = accRec.Account_Auto_Number__c;
                                                                }
                                                                if(invLineRec.Service_Start_Date__c<>null){
                                                                    String stdatedata = String.valueOf(invLineRec.Service_Start_Date__c);
                                                                    String stsubdate = stdatedata.substringBefore(' ');
                                                                    String startdatestring = stsubdate.replace('-','');
                                                                    
                                                                credRec.Start_Date__c = startdatestring;
                                                                }    
                                                                if(invLineRec.Service_Start_Date__c<>null){
                                                                    String edatedata = String.valueOf(invLineRec.Service_End_Date__c);
                                                                    String esubdate = edatedata.substringBefore(' ');
                                                                    String enddatestring = esubdate.replace('-','');

                                                                    credRec.Stop_Date__c = enddatestring;
                                                                }
                                                                credRec.Insertion_Amount__c = '0';
                                                                credRec.Pagination_Amount__c = '0';
                                                                credRec.NRA_Amount__c = '0';
                                                                credRec.Freight_Charge__c = '0';
                                                                /*if(zInvRec.Zuora__TaxAmount__c<>null && zInvRec.Zuora__AmountWithoutTax__c<>null){
                                                                        Decimal gstrate = zInvRec.Zuora__TaxAmount__c;
                                                                        Decimal gstratePercent = gstrate.divide(zInvRec.Zuora__AmountWithoutTax__c, 2, System.RoundingMode.UP);
                                                                    credRec.GST_Rate__c = String.ValueOf(gstratePercent*100);   
                                                                }*/
                                                                /*
                                                                credRec.GST_Rate__c = gstRate;
                                // START : HOTFIX 6/24/2015 Alyana Navarro
                                if(invLineRec.Charge_Amount__c != null){
                                  credRec.Gross_Amount__c = String.valueOf(invLineRec.Charge_Amount__c); 
                                } else {
                                  credRec.Gross_Amount__c = '0';
                                }
                                // END : HOTFIX 6/24/2015 Alyana Navarro
                                
                                                                credRec.Gross_Sales__c = '0';                                                           
                                
                                // START : HOTFIX 6/24/2015 Alyana Navarro
                                                                if(invLineRec.Tax_Amount__c != null){
                                                                    credRec.GST_Amount__c = String.valueOf(invLineRec.Tax_Amount__c);
                                                                } else {
                                  credRec.GST_Amount__c = '0';
                                }                                
                                                                                                                            
                                                                if(invLineRec.Charge_Amount__c != null){
                                                                    credRec.Net_Amount_After_GST__c = String.valueOf(Decimal.valueOf(credRec.Gross_Amount__c) + Decimal.valueOf(credRec.GST_Amount__c)); 
                                                                }
                                // END : HOTFIX 6/24/2015 Alyana Navarro
                                                                
                                                                if(invoiceLineIdDiscountMap.containsKey(invLineRec.id)){
                                                                    credRec.Discount__c = String.valueOf(invoiceLineIdDiscountMap.get(invLineRec.id));
                                                                } else {
                                                                    credRec.Discount__c = '0';
                                                                }
                                                                
                                                                credRec.Adjustment_to_Commission_Amount__c = '0';
                                                                credRec.Commission__c = '0';                                                            
                                                                credRec.Issue_Date__c = Date.Today();
                                                                // START : D-2982 5/21/2015 Alyana Navarro - Remove
                                                                /*if(invLineRec.Charge_Amount__c<>null){
                                                                    credRec.Discount__c = String.valueOf(invLineRec.Charge_Amount__c);
                                                                }*/
                                                                // END : D-2982 5/21/2015 Alyana Navarro - Remove
                                                                /*
                                                                // START : UD-1421 7/1/2015 Alyana Navarro - Remove commented out line of Codes
                                                                if(zInvRec.ARMS_Invoice_ID__c != null){
                                                                    credRec.Reference_Doc_No_for_CN__c = zInvRec.ARMS_Invoice_ID__c;
                                                                }
                                                                /*if(zInvRec.Zuora__DueDate__c<>null){
                                                                        String duedatedata = String.valueOf(zInvRec.Zuora__DueDate__c);
                                                                        String duedatestring = duedatedata.replace('-','');
                                                                    credRec.Due_Date__c = duedatestring;
                                                                }*/
                                                                /*
                                                                // END : UD-1421 7/1/2015 Alyana Navarro - Remove commented out line of Codes
                                                                if(thisCase.ContactId<>null){
                                                                    credRec.Remark1__c = String.ValueOf(contactRec.Recipient_Number__c);
                                                                }
                                                                credRec.GL_account__c = invLineRec.Accounting_Code__c;
                                // START : D-3136 6/22/2015 Alyana Navarro
                                if(credRec.Publication__c != null){
                                    credList.add(credRec);
                                }
                                // END : D-3136 6/22/2015 Alyana Navarro
                                                                // END : D-2982 5/21/2015 Alyana Navarro
                                                            }
                                                        }
                                                        zInvRec.Refund_Indicator__c = true;
                                                        invRefIndList.add(zInvRec);
                                                    }
                                                }
                                            }
                                            */
                                            

                                            //update invRefIndList;
                                            update thisCase;
                                            //insert credList;
                                            // END : UD-1419 7/20/2015 Alyana Navarro
                                            
                                        }
                                    }
                                    else {
                                        
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA')));
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Code: ' + resultMap.get('Code')));
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + resultMap.get('Message')));
                                    }
                                    
                                    invoiceItemAdjustment();
                            //END ADD SRPULI PAYMENT MODE = INVOICE, Generation of Credit Note 
                            //START D-     
                            //START UD-1612 18-06-2015 Marvin Gatchalian     
                            } else if (thisCase.Payment_Mode__c == 'CreditCard') {

                                List<Map<String, Object>> listMap = new List<Map<String, Object>>();
                                for(Zuora__CustomerAccount__c ba : cAccounts){
                                    //START UD-3092 16Mar16 FrancisBenzon :added condition
                                    if(ba.Refund_Amount__c != null && ba.Refund_Amount__c != 0 && ba.Credit_Balance_Incl_Goodwill__c != 0 
                                    		&& ba.Zuora__DefaultPaymentMethod__c == CREDIT_CARD){	// Start/End D-4592 07Apr16 JohnD - added Zuora__DefaultPaymentMethod__c
                                    //END UD-3092 16Mar16 FrancisBenzon :added condition
                                        Map<String,Object> refundMap = new Map<String, Object>();
										refundMap.put('AccountId', ba.Zuora__External_Id__c);
										refundMap.put('PaymentMethodId', ba.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);                     
										refundMap.put('Amount', ba.Refund_Amount__c);                                   
										refundMap.put('SourceType', 'CreditBalance');                    
										refundMap.put('Type', 'Electronic' );     
										//refundMap.put('MethodType', thisCase.Payment_Mode__c );                                     
										refundMap.put('Payee__c', thisCase.Payee_Name__c);      
                                        //START UD-2252 AddedBy FrancisBenzon 10/23/15 : populate case field in refund record 
                                        refundMap.put('Case_1__c', thisCase.id);
                                        //END UD-2252 AddedBy FrancisBenzon 10/23/15 : populate case field in refund record  
                                        listMap.add(refundMap);
                                        system.debug('>>>>>>>>>>> ThisCase Payee: ' + thisCase.Payee_Name__c);
                                        system.debug('RefundMap--------------'+refundMap);
                                    }   
                                }

                                List<Map<String,String>> resultMap = RefundCallOut.loadZObjects(listMap, 'Refund');

								system.debug('JohnD ::: ' + resultMap);

                                for(Map<String, String> rMap: resultMap) {
                                    if (rMap.get('Status') == 'Success') {                          
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('SuccessfullyCreatedRefund'))); 
                                        thisCase.Case_Refund_Check__c = true;
                                        system.debug('case check after success' + thisCase.Case_Refund_Check__c);
                                    }
                                    else {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA')));
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + rMap.get('Message')));                                   
                                    }
                                    system.debug('>>>>>>>>>>>>>>>>>rMap1' + ' ' + rMap.get('Status'));
                                    system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + rMap.get('Code'));                                
                                    system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + rMap.get('Message'));

                                }
                                                        
                                system.debug('case before update' + thisCase.Case_Refund_Check__c);
                                update thisCase;
                                system.debug('case after update' + thisCase.Case_Refund_Check__c);
                            
                            
                            //END UD-1612 18-06-2015 Marvin Gatchalian
                            } else if (thisCase.Payment_Mode__c != 'Paypal') {
                                //START [UD_0887] RBustarde 19/05/2015                                  
                                 system.debug('------------Not PAYPAL--------------');                                                                      
                                List<Map<String, Object>> listMap = new List<Map<String, Object>>();
                                system.debug(':::cAccounts ' + cAccounts);
                                for(Zuora__CustomerAccount__c ba : cAccounts){
                                    //START UD-3092 16Mar16 FrancisBenzon :added condition
                                    if(ba.Refund_Amount__c != null && ba.Refund_Amount__c != 0 && ba.Credit_Balance_Incl_Goodwill__c != 0){ 
                                    //END UD-3092 16Mar16 FrancisBenzon :added condition
                                    //START-END UD-0573 Jason Abolac 04/27/2015
                                        Map<String,Object> refundMap = new Map<String, Object>();
                                        refundMap.put('AccountId', ba.Zuora__External_Id__c);                    
                                        refundMap.put('Amount', ba.Refund_Amount__c);                                   
                                        refundMap.put('SourceType', 'CreditBalance');                    
                                        refundMap.put('Type', 'External' );     
                                        refundMap.put('MethodType', thisCase.Payment_Mode__c );                                     
                                        refundMap.put('Payee__c', thisCase.Payee_Name__c);      
                                        //START UD-2252 AddedBy FrancisBenzon 10/23/15 : populate case field in refund record 
                                        refundMap.put('Case_1__c', thisCase.id);
                                        //END UD-2252 AddedBy FrancisBenzon 10/23/15 : populate case field in refund record
                                        listMap.add(refundMap);
                                        system.debug('>>>>>>>>>>> ThisCase Payee: ' + thisCase.Payee_Name__c);
                                //END [UD_0887] RBustarde 19/05/2015                                    
                                        system.debug('RefundMap--------------'+refundMap);
                                    }   //START-END UD-0573 Jason Abolac 04/27/2015
                                }
                                for(Map<String, Object> b: listMap){
                                }
                                //START: D-1707 K. Tan Payment Maintenance creation of Payment Record
                                List<Map<String,String>> resultMap = RefundCallOut.loadZObjects(listMap, 'Refund');
                                system.debug(':::ResultMap ' + resultMap);
                                //Map<String,String> resultMap = RefundCallOut.createMultipleZObject(listMap, 'Refund');
                                for(Map<String, String> rMap: resultMap) {
                                    if (rMap.get('Status') == 'Success') {                          
                                                                        
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('SuccessfullyCreatedRefund'))); 
                                        
                                        //START UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                                        thisCase.Case_Refund_Check__c = true;
                                        system.debug('case check after success' + thisCase.Case_Refund_Check__c);
                                        //END UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click                                   
                                    }
                                    else {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA'))); 
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + rMap.get('Message')));                                   
                                    }
                                    system.debug('>>>>>>>>>>>>>>>>>rMap1' + ' ' + rMap.get('Status'));
                                    system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + rMap.get('Code'));                                
                                    system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + rMap.get('Message'));

                                }
                                                            
                                //START UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                                                        
                                system.debug('case before update' + thisCase.Case_Refund_Check__c);
                                update thisCase;
                                system.debug('case after update' + thisCase.Case_Refund_Check__c);
                                //END UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                                
                                /*  if(resultMap.get('Status') == 'Success') {
                                        
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('SuccessfullyCreatedRefund'))); 
                                    }
                                    else {
                                        //START: KLorica 1/16/2015 FOR D-1707 Comment out apexpages.addmessage for 'Code'
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA')));
                                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Code: ' + resultMap.get('Code')));
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + resultMap.get('Message')));
                                   }*/ //END: KLorica 1/16/2015 FOR D-1707 Comment out apexpages.addmessage for 'Code'
                                //END: D-1707 K. Tan Payment Maintenance creation of Payment Record                   
                            } 
                        //}
                    } //END: KLorica 1/16/2015 FOR D-1707
                    //Start: UD-0572 04/07/2015 Jason Abolac
                    else{
                        
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('RefundApproval')));
                    }
                }//START UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('CaseRefundCheck')));
                }//END UD-0981 KEstoya 5/7/2015 do not allow refund after refund button click
            }
            //End 06/13/2015 UD-1537 James
        //Start UD-0728 K. Tan 4/17/205 - to not create refund once case is closed
        }
        else{           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('CaseClosedRefund')));
            
        }
        
        
        //END UD-0728 K. Tan 4/17/205 -  to not create refund once case is closed
        
        //End: UD-0572 04/07/2015 Jason Abolac
    }
    /*Query all invoices with negative amount and Refunded indicator = "No" or unchecked
    *Create Invoice Item adjustments (Zuora callout) to 0 out the negative invoices
    *Update all invoices with negative amount to set Refunded indicator = "Yes" or checked
    */
    public void invoiceItemAdjustment() {
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
        List<Map<String, Object>> invoiceItemMapList = new List<Map<String, Object>>();
        Set<String> invoiceZuoraIdSet = new Set<String>();
        Map<String, Object> invoiceItemMap;
        
        invoiceList = [SELECT ID, Zuora__Balance2__c, Zuora__Zuora_Id__c, Refund_Indicator__c FROM Zuora__ZInvoice__c WHERE Zuora__Account__c = :thisCase.AccountId AND Zuora__Balance2__c < 0 AND Refund_Indicator__c = FALSE];
        
        for (Zuora__ZInvoice__c invoice :invoiceList) {
            invoiceZuoraIdSet.add(invoice.Zuora__Zuora_Id__c);
        }
        
        iliList = [SELECT Id, Name, Charge_Amount__c, Invoice_ID__c, ID__c FROM Invoice_Line_Item__c WHERE Invoice_ID__c IN :invoiceZuoraIdSet];
        
        for (Invoice_Line_Item__c ili :iliList) {
            invoiceItemMap = new Map<String, Object>();
            invoiceItemMap.put('AdjustmentDate', Zuora.zUtil.getZuoraDate(Date.Today()));
            invoiceItemMap.put('Amount', ili.Charge_Amount__c);
            invoiceItemMap.put('InvoiceId', ili.Invoice_ID__c);
            invoiceItemMap.put('SourceType', 'InvoiceDetail');
            invoiceItemMap.put('SourceId', ili.ID__c);
            invoiceItemMap.put('Type', 'Charge');
            invoiceItemMapList.add(invoiceItemMap);
        }
        
        if (!invoiceItemMapList.isEmpty()) {
            List<Map<String,String>> returnVar = RefundCallOut.loadZObjects(invoiceItemMapList, 'InvoiceItemAdjustment');
            for (Map<String, String> resultMap :returnVar) {
                if (resultMap.get('Status') == 'Success') {
                    system.debug(resultMap.get('Id'));
                }
                else {
                    system.debug(resultMap.get('Code'));
                    system.debug(resultMap.get('Message'));
                }
            }
        }
        
        for (Zuora__ZInvoice__c invoice :invoiceList) {
            invoice.Refund_Indicator__c = TRUE;
        }
        
        try {
            update invoiceList;
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.geterrorMessage('Error Encountered')));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e.getMessage()));
        }
    }
}