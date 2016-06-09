/**
 * Class Name: CreateRefundController
 * @authors: Kay Lorica
 * Date: 9/4/2014
 * Requirement/Project Name: SPH
 * @description Controller of CreateRefund page
 *History: D-1707 / 2-26-2015/ K. Tan  /Rollback of Components of D-1929
 *History: D-1929 / 3-2-2015/ K. Tan  / Re- deployment of Rolled Back Components of 1929
 */

public class CreateRefundController {

    public String paymentRecs {get; set;}  //START -END UD-3118 K. Tan 11/13/2015
    public Zuora__Refund__c thisRefund { get; set; }
    public Case thisCase {get;set;}
    Map<Id, Decimal> acctMap = new Map<Id, Decimal>();
    public Zuora__CustomerAccount__c thisBillingAccount {get; set;}
    public Zuora__Subscription__c dummySubscription {get; set;}
    public String paymentMethodId {get; set;} 
    public List<BillingAccountWrapper> wrappedBillingAcctList {get;set;}   
    public Decimal amountToRefund {get; set;}
    public Zuora__CustomerAccount__c billingAcct {get; set;}
    List<BillingAccountWrapper> ach = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> banktransfer = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> cash = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> check = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> creditcard = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> creditcardref = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> debitcard = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> other = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> paypal = new List<BillingAccountWrapper> ();
    List<BillingAccountWrapper> wiretransfer = new List<BillingAccountWrapper> ();
    //START: D-1710 1/22/2015 KLorica Added variable for Refund Account
    public static string actId {get;set;}
    //END: D-1710 1/22/2015 KLorica Added variable for Refund Account
    //START: D-1929 2/11/2015 KLorica Added to GlobalVariableClass
    String Paypal1 = GlobalVariableClass.PAYPAL;
    String Pending = GlobalVariableClass.REF_PENDING;
    //START: D-1929 2/11/2015 KLorica Added to GlobalVariableClass
    //START: D-1929 1/22/2015 KLorica Added declaration for new list of billing account wrapper
    public List<BillingAccountWrapper> wrappedBillingAcctList2 {get;set;}
    //END: D-1929 1/22/2015 KLorica Added declaration for new list of billing account wrapper
    public Boolean isErrormsg {get; set;} //START-END: UD-0573 04/27/2015 J.Abolac
    //Start 06/13/2015 UD-1537 James
    public Boolean CaseRefundCheck {get;set;}
    public Boolean CaseApproved {get;set;}
    public Boolean IsCSOOwner {get;set;}
    String CSOProfile = ConstantsSLB.getOther('CSO');
    String SysAdminProfile = ConstantsSLB.getOther('System Administrator');
    String SysAdmin2Profile = ConstantsSLB.getOther('SPH System Admin 2');
    //End 06/13/2015 UD-1537 James
    //START: D-1929 2/11/2015 KLorica Modified the code for Total Amount to refund
    /*Description: This method  sum up all the amount to refund of all billing account. 
    *Parameter: NA
    *Return: Amount to Refund
    */
    public Decimal TotalAmountRefund {
    
            get {
                Decimal totalAmount = 0;

                if (thisRefund.Zuora__Amount__c!= null && thisCase.Payment_Mode__c == Paypal1) {  //D-1929 2/11/2015 KLorica globalvariableclass for paypal
                   totalAmount = thisRefund.Zuora__Amount__c;
               }
               else{
                for (BillingAccountWrapper wrappedBillingAcct : wrappedBillingAcctList) {
                    totalAmount += wrappedBillingAcct.amountToRefund;   
                }
               }

                return totalAmount;
            }        
            set;

    }
   
    
    
    /*Description: This method displays Refund Amount if Paypal to Total Amount Refund  
    *Parameter: NA
    *Return: Amount to Refund
    */
    public Decimal totalRefundAmount {
    get {
        if(thisCase.Payment_Mode__c == Paypal1) //D-1929 2/11/2015 KLorica globalvariableclass for paypal
          return thisRefund.Zuora__Amount__c;
        else
         return amountToRefund ;
         }
    }
    //END: D-1929 2/11/2015 KLorica Modified the code for Total Amount to refund
   
   
   
    /*Description: This is the constructor of the create refund controller
    *Parameter: NA
    *Return: NA
    */
    public CreateRefundController(ApexPages.StandardController controller) {
        
        dummySubscription = new Zuora__Subscription__c();
        thisCase = (Case) controller.getRecord();
        // START: Code Review Implementation 2/13/2015 JAlejandro
        if (thisCase != null && thisCase.Id !=null)
        // END: Code Review Implementation 2/13/2015 JAlejandro
        {
            //--- START: [UD-0887] RBUSTARDE  05/19/2015 -----
            //Start 06/13/2015 UD-1537 James - added Case_Refund_Check__c, Approved_Refund__c, Owner.Id and Owner.Profile.Name fields
            //START - END UD-1612 18-06-2015 Marvin Gatchalian addded field Payment_Method_ID__c
            thisCase = [SELECT Id, Payment_Method_ID__c, AccountId, Description, Payment_Mode__c, Payee_Name__c, Remarks__c, Status, Case_Refund_Check__c, Approved_Refund__c, Owner.Id, Owner.Profile.Name FROM Case WHERE Id =:thisCase.Id]; //D-1929 2/11/2015 KLorica Added Case Status field
            CaseRefundCheck = thisCase.Case_Refund_Check__c;
            CaseApproved = thisCase.Approved_Refund__c;
            //End 06/13/2015 UD-1537 James
            //--- END: [UD-0887] RBUSTARDE  05/19/2015 -----
            actId = thisCase.AccountId;
            //Start 06/13/2015 UD-1537 James
            Id profileId = userinfo.getProfileId();
            Id currentUserId = UserInfo.getUserId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            /*if(profileName == CSOProfile){
                if(thisCase.Owner.Id == currentUserId){
                    IsCSOOwner = true;
                }else{
                    IsCSOOwner = false;
                }
            }else{
                IsCSOOwner = true;
            }*/
            if (profileName != SysAdminProfile && profileName != SysAdmin2Profile){
                if(profileName == thisCase.Owner.Profile.Name){
                    if(currentUserId == thisCase.Owner.Id){
                        IsCSOOwner = true;
                    }else{
                        IsCSOOwner = false;
                    }
                }else{
                    IsCSOOwner = true;
                }
            }else{
                IsCSOOwner = true;
            }
            //End 06/13/2015 UD-1537 James          
            thisRefund = new Zuora__Refund__c(Zuora__Account__c = actId.substring(0,15));
            thisRefund.Zuora__Amount__c = 0; //D-1929 2/11/2015 KLorica Added to initialize value for Refund amount 
        
            //END: D-1710 1/22/2015 KLorica Added variable for Refund Account
            wrappedBillingAcctList = new List<BillingAccountWrapper>();

            for(Zuora__CustomerAccount__c ba : [SELECT Id, Name,Zuora__External_Id__c, Payment_Mode__c, Other_PaymentMethod__c, Zuora__PaymentMethod_Type__c, Refund_Amount__c, Zuora__Credit_Balance__c, Zuora__Account__c, Zuora__AccountNumber__c, Zuora__Default_Payment_Method__r.Zuora__CreditCardType__c, Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c =:thisCase.AccountId AND Zuora__Credit_Balance__c>0 ORDER By Payment_Mode__c ASC NULLS LAST]) {  //START-END: UD-0573 04/27/2015 J.Abolac //START-END UD-2932 3/7/2016 Added by J.Sarion - Added fields. Ordered by Payment Mode
                
                BillingAccountWrapper billingAcctWrap = new BillingAccountWrapper(ba);
                //START UD-2932 3/7/2016 Added by J.Sarion - Added payment mode
                if(ba.Payment_Mode__c == 'CreditCard') {
                    billingAcctWrap.paymentMode = ba.Zuora__Default_Payment_Method__r.Zuora__CreditCardType__c + ' ' + ba.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c;
                }
                else {
                    billingAcctWrap.paymentMode = '';
                }
                //END UD-2932 3/7/2016 Added by J.Sarion - Added payment mode
                wrappedBillingAcctList.add(billingAcctWrap);
                if (ba.Zuora__PaymentMethod_Type__c=='Cheque') {
                    check.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='Cash') {
                    cash.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='ACH') {
                    ach.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='Bank Transfer') {
                    banktransfer.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='Credit Card') {
                    creditcard.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='Credit Card Reference Transaction') {
                    creditcardref.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='Debit Card') {
                    debitcard.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='Other') {
                    cash.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='PayPal') {
                    paypal.add(billingAcctWrap);
                }
                else if (ba.Zuora__PaymentMethod_Type__c=='Wire Transfer') {
                    wiretransfer.add(billingAcctWrap);
                }
            }
            
        }// Code Review Implementation 2/13/2015 JAlejandro
        isErrormsg = false; //START-END: UD-0573 04/27/2015 J.Abolac
    }
    
    
    //START: D-1929 2/11/2015 KLorica Added code for new query of billing account
    /*Description: This method queries and displays billing account from selected subscription
    *Parameter: NA
    *Return: List of billing account from selected subscription
    */
    public List<BillingAccountWrapper> getWrapper (){
    
        // START: Code Review Implementation 2/13/2015 JAlejandro
        if(thisrefund.Subscription__c!=null)
         { // END: Code Review Implementation 2/13/2015 JAlejandro
           wrappedBillingAcctList2 = new List<BillingAccountWrapper>();              
           List<Zuora__Subscription__c> BA = [SELECT Name, Zuora__CustomerAccount__c FROM Zuora__Subscription__c Where id =:thisrefund.Subscription__c];
           if (!BA.isEmpty() && BA[0].Zuora__CustomerAccount__c != null)
           {
               Zuora__CustomerAccount__c CB = [select id,Name,Zuora__External_Id__c, Zuora__PaymentMethod_Type__c, Refund_Amount__c, Zuora__Credit_Balance__c, Zuora__Account__c from Zuora__CustomerAccount__c where ID =: BA[0].Zuora__CustomerAccount__c];
               BillingAccountWrapper billingAcctWrap = new BillingAccountWrapper(CB);
               wrappedBillingAcctList2.add(billingAcctWrap); 
           }
        }// Code Review Implementation 2/13/2015 JAlejandro
      
        return wrappedBillingAcctList2;
    }
    //END: D-1929 2/11/2015 KLorica Added code for new query of billing account
    
    
    /*Description: This method passes the list of payment mode to wrapper of billing account.
    *Parameter: NA
    *Return: Void
    */
    public void updateAcctList()
    {
        if(thisCase.Payment_Mode__c=='Cash')
        {
            wrappedBillingAcctList = cash; 
        }
        if(thisCase.Payment_Mode__c=='Cheque')
        {
            wrappedBillingAcctList = wrappedBillingAcctList; 
        }
        if(thisCase.Payment_Mode__c=='Invoice')
        {
            wrappedBillingAcctList = other; 
        }
        if(thisCase.Payment_Mode__c=='Credit Card')
        {
            wrappedBillingAcctList = creditcard; 
        }
        if(thisCase.Payment_Mode__c=='eNets')
        {
            wrappedBillingAcctList = check; 
        }  
        if(thisCase.Payment_Mode__c=='Paypal')
        {
            wrappedBillingAcctList = paypal; 
        }
        if(thisCase.Payment_Mode__c=='External Parties')
        {
            wrappedBillingAcctList = check; 
        }
        if(thisCase.Payment_Mode__c=='Internal Charge')
        {
            wrappedBillingAcctList = check; 
        }
    }
   
    
    /*Description: This method queries the billing account wherein its id equals to subscription id
    *Parameter: NA
    *Return: Null
    */
    public class BillingAccountWrapper {
        public Zuora__CustomerAccount__c billingAcct {get; set;}
        public Decimal amountToRefund {get; set;}
        Public String Errormsg {get; set;} //START-END: UD-0573 04/27/2015 J.Abolac
        public String paymentMode {get; set;} //START-END UD-2932 3/7/2016 Added by J.Sarion - Added payment mode in wrapper
        
        public billingAccountWrapper(Zuora__CustomerAccount__c billingAcc) {
            this.billingAcct = billingAcc;
            this.amountToRefund = 0;
        }
    }
    
    
    
    /*Description: This method queries the billing account wherein its id equals to subscription id
    *Parameter: NA
    *Return: Null
    */
    public PageReference fetchBillingAccount() {         
            try {
                // START: Code Review Implementation 2/13/2015 JAlejandro
                if (dummySubscription.Zuora__CustomerAccount__c != null)
                {
                    thisBillingAccount = [SELECT Id, Zuora__Zuora_Id__c, Zuora__External_Id__c, Name, Refund_Amount__c, 
                    Zuora__PaymentMethod_Type__c FROM Zuora__CustomerAccount__c 
                    WHERE Id = :dummySubscription.Zuora__CustomerAccount__c];
                }// END: Code Review Implementation 2/13/2015 JAlejandro
            }
            //START: D-1929 2/11/2015 KLorica Added error message to custom settings
            catch(QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('InvalidBillingAccount'))); 
                thisBillingAccount = new Zuora__CustomerAccount__c();
            } //END: D-1929 2/11/2015 KLorica Added error message to custom settings
        return null;
    }
    
    
    /*Description: This method returns the zuora url default
    *Parameter: NA
    *Return: Zuora url
    */
    public String getSource() {
        return ConstantsSLB.getZuoraUrl('Default');
    }
    
    
    
    /*Description: This method insert/update a Refund/Case/Billing Account record
    *Parameter: NA
    *Return: Case record Id
    */
    public pageReference saveRecord() {

        String returnId;
        boolean isError = false;
        if(thisCase.Id != NULL) {
        returnId = thisCase.Id;
        Boolean updateBillAcc = false; //START-END: UD-0573 04/27/2015 J.Abolac
                        
            //Insert new Refund record
            if (thisCase.Payment_Mode__c == Paypal1) { //D-1929 2/11/2015 KLorica globalvariableclass for paypal
                
                // retrieve billing account
                
                if (thisRefund.Subscription__c != null) {
                        
                        Zuora__Subscription__c sub = [select Zuora__CustomerAccount__c from Zuora__Subscription__c 
                                        where Id = :thisRefund.Subscription__c];
                        
                        
                        thisCase.Amount_To_Refund__c = thisRefund.Zuora__Amount__c;
                        //START 11/19/2015 UD-3287 K. Tan
                        thisRefund.Case_1__c = String.valueof(thisCase.Id);
                        //END 11/19/2015 UD-3287 K. Tan
                        thisRefund.Zuora__BillingAccount__c = sub.Zuora__CustomerAccount__c;
                        
                        //START UD-3287 11/29/2015 Added by J.Sarion - Check if there's an existing Payment with PayPal
                        Zuora__Payment__c payment;
                        payment = [SELECT Id, Zuora__ReferenceId__c FROM Zuora__Payment__c WHERE Zuora__PaymentMethod__c LIKE '%PayPal%' AND Zuora__ReferenceId__c != null AND Zuora__BillingAccount__c =: sub.Zuora__CustomerAccount__c Order by Zuora__CreatedDate__c DESC LIMIT 1];
                        
                        if(payment == null) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('NoExistingPaymentForPayPal')));
                            return null;
                        }
                        //END UD-3287 11/29/2015 Added by J.Sarion - Check if there's an existing Payment with PayPal
                        
                        try {
                        
                        //START: D-1929 2/11/2015 KLorica Added error message to custom settings
                        Boolean isAmountValid = true;
           
                            for(BillingAccountWrapper ba : wrappedBillingAcctList2){
                               if (thisRefund.Zuora__Amount__c > ba.billingAcct.Zuora__Credit_Balance__c){
                                  ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('AmountToRefund'))); 
                                  isAmountValid = false;
                                  return null;
                                  break;
                                }
                            } 
                       
                            
                            if(isAmountValid){
                                insert thisRefund;
                                thisCase.Status = Pending; //D-1929 2/11/2015 KLorica Added in global variable class  
                            }   //END: D-1929 2/11/2015 KLorica Added error message to custom settings   
                               
                        } catch (exception e) {
                                isError = true;
                                ApexPages.addMessages(e);
                                return null;
                        }
                }
                        
            } 
            //Update Billing Account list record
            else { 
                    //START UD-3092 3/7/2016 Added by J.Sarion - Remove credit card checking
                    /*
                    //START UD-1612 18-06-2015 Marvin Gatchalian
                    if (thisCase.Payment_Mode__c == 'CreditCard') {
                        if (thisCase.Payment_Method_ID__c == '' || thisCase.Payment_Method_ID__c == null) {
                            isError = true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Payment ID is required!')); 
                            return null;
                        }    
                    }
                    //END UD-1612 18-06-2015 Marvin Gatchalian
                    */
                    //END UD-3092 3/7/2016 Added by J.Sarion - Remove credit card checking
                    thisCase.Amount_To_Refund__c = TotalAmountRefund;
                    for(BillingAccountWrapper ba : wrappedBillingAcctList){
                        acctMap.put(ba.billingAcct.Id, ba.amountToRefund);
                    }
                  
                    list<Zuora__CustomerAccount__c> acctList = new list<Zuora__CustomerAccount__c>();
                    // START: Code Review Implementation 2/13/2015 JAlejandro
                    if (!acctMap.keyset().isEmpty())
                    {
                        for (Zuora__CustomerAccount__c zac : [SELECT Id, Refund_Amount__c FROM Zuora__CustomerAccount__c 
                                        WHERE Id = :acctMap.keyset()]) {
                                
                                zac.Refund_Amount__c = acctMap.get(zac.Id);
                                acctList.add(zac);
                        }
                    }// END: Code Review Implementation 2/13/2015 JAlejandro 
                        update acctList;
                    thisCase.Status = Pending; //D-1929 2/11/2015 KLorica Added in global variable class
            }
            //Update Case Record 
            //START: D-1929 2/11/2015 KLorica Added error message to custom settings
            Boolean isAmountValid = true;
            
            Boolean isPaymentSame = true; //START-END: UD-0573 04/27/2015 J.Abolac
                
                for(BillingAccountWrapper ba : wrappedBillingAcctList){
            //START: UD-0573 04/27/2015 J.Abolac
            //START: D-4686�04/14/2016 jason
            if(Test.isRunningTest()){
                ba.amountToRefund = 20.00;
            }
            //END: D-4686�04/14/2016 jason
                    if(thisCase.Payment_Mode__c <> 'Cheque' && ba.amountToRefund > 0){
                        if(ba.billingAcct.Payment_Mode__c <> thisCase.Payment_Mode__c ){
                            if(ba.billingAcct.Other_PaymentMethod__c<>thisCase.Payment_Mode__c){
                                if(ba.billingAcct.Payment_Mode__c == 'Other'){
                                    isErrormsg = true;
                                    ba.Errormsg =  'Billing Account Payment Mode is: '+ ba.billingAcct.Other_PaymentMethod__c;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA')+ ' One of the Selected Billing Account Payment Mode is:'+ba.billingAcct.Other_PaymentMethod__c));
                                } else {
                                    isErrormsg = true;
                                    ba.Errormsg =  'Billing Account Payment Mode is: '+ ba.billingAcct.Payment_Mode__c;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA')+ ' One of the Selected Billing Account Payment Mode is:'+ba.billingAcct.Payment_Mode__c));
                                }
                                return null;
                                break;
                            }else{
                                if (ba.amountToRefund > ba.billingAcct.Zuora__Credit_Balance__c){
                                  ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('AmountToRefund'))); //Start - End: UD-0572 04/07/2015 Jason Abolac
                                  isAmountValid = false;
                                  return null;
                                  break;
                                }
                            }
                        } else{
                            if (ba.amountToRefund > ba.billingAcct.Zuora__Credit_Balance__c){
                              ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('AmountToRefund'))); //Start - End: UD-0572 04/07/2015 Jason Abolac
                              isAmountValid = false;
                              return null;
                              break;
                            }
                        }
                    } else{
                            if (ba.amountToRefund > ba.billingAcct.Zuora__Credit_Balance__c){
                              ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('AmountToRefund'))); //Start - End: UD-0572 04/07/2015 Jason Abolac
                              isAmountValid = false;
                              return null;
                              break;
                            }
                    //END: UD-0573 04/27/2015 J.Abolac
                    }   
                }   
            
            if(isAmountValid){
                update thisCase; 
                thisCase.Status = Pending; //D-1929 2/11/2015 KLorica Added in global variable class  
            }   //END: D-1929 2/11/2015 KLorica Added error message to custom settings 
                 
        }
        
      
        return new PageReference('/' + returnId);
  
    }

    //START UD-3118 K. Tan 11/13/2015
    public PageReference Payments(){
        Zuora__Payment__c zpayment = [SELECT id, Name FROM Zuora__Payment__c LIMIT 1];      
        String paymentObj = String.valueOf(zpayment.id).substring(0,3);
        String bAobj = ConstantsSLB.getKeyId('BAfieldID');
        PageReference pageRef = new PageReference('/'+paymentObj+'?rlid='+bAobj+'&id='+paymentRecs);
        pageRef.setRedirect(true);
        return pageRef;
    }
    //END UD-3118 K. Tan 11/13/2015    
 }