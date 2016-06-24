public class ChangeOfPaymentController{
    /*
     * parameters: "accountId" : Id of the parent Account 
     *
     *History UD-0870 K. Tan 4.24.2015 / overhaul to include Change of Payment for ARMS 
     */
     
    public Boolean isArms {get; set;}
    Set<Id> baCusIdSet = new Set<Id>();
    Set<Id> batchCustSet = new Set<Id>();
    Set<Id> batchAccSet = new Set<Id>();        
    List<BT_CO_ARMS_CreateAccountBatchFile__c> accToCreateBatchList = new List<BT_CO_ARMS_CreateAccountBatchFile__c>();
    List<BT_CO_ARMS_CreateCustAccountFile__c> cusToCreateBatchList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
    List<BT_CO_ARMS_CreateCustAccountFile__c> cusToInsertBatchList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
    public Account thisAccount {get; set;}
    public Order__c thisOrder {get; set;}
    public Zuora__CustomerAccount__c thisBillingAccount {get; set;}
    
    //START UD-0810 05-07-2015 Marvin G
    public List<Zuora__Subscription__c> theseSubscriptions = new List<Zuora__Subscription__c>();
    public List<Order__c> theseOrders = new List<Order__c>();
    public set<id> orderIds = new set<id>();
    //END UD-0810 05-07-2015 Marvin G
    
    
    public Zuora__Subscription__c dummySubscription {get; set;} //for Billing Account Lookup
    public zqu__Quote__c thisQuote {get; set;}
    public Case thisCase {get; set;}
    
    public String acquisitionType {get; set;}
    public String deliveryChargeType {get; set;}
    public String billingAccountOption {get; set;}
    public String glCode {get; set;}
    public String paymentMethodId{get; set;}
    public Date dtlDate {get; set;}
    public Boolean isSponsored {get; set;}
    public Decimal fullPaymentMonthlyDeliveryCharge {get; set;}
    public Decimal subscriberCharge {get; set;}
    public Decimal vendorCredit {get; set;}
    public Decimal amountPaid {get; set;}
    String recType;
    Id accountId;
    Id billingaccountId;
    //Start CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
    String PARAM_ACCOUNTID = GlobalVariableClass.PARAMETER_ACCTID_STRING;
    String PARAM_RECORDTYPE = GlobalVariableClass.PARAMETER_RECORDTYPE_STRING;
    String PARAM_BILLINGACCT = GlobalVariableClass.PARAMETER_BILLINGACCOUNTID_STRING;
    String CreditCard = GlobalVariableClass.CREDITCARD;
    String Cash = GlobalVariableClass.CASH;
    String Check = GlobalVariableClass.CHEQUE;
    //START:D-2738 4/13/15 Added by Karl Tan
    String Cheque = GlobalVariableClass.CHEQUEPT;
    
    //END:D-2738 4/13/15 Added by Karl Tan
    ZuoraCallOut zCall = new ZuoraCallOut(); 

    //End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
    
    //START UD-3294 26Nov2015 Added By C. Lin - Get Billing Account from field if page parameter has no billing account
    String parentId;
    //END UD-3294 26Nov2015 Added By C. Lin
    
    public ChangeOfPaymentController() {
        recType = ApexPages.currentPage().getParameters().get(PARAM_RECORDTYPE); //Start/End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
        dummySubscription = new Zuora__Subscription__c();
        thisQuote = new zqu__Quote__c();
        accountId = ApexPages.currentPage().getParameters().get(PARAM_ACCOUNTID); //Start/End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
        billingaccountId = (Id) ApexPages.currentPage().getParameters().get(PARAM_BILLINGACCT); //Start/End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
        thisCase = new Case();
        thisCase.AccountId = accountId;
        
        //START UD-3294 26Nov2015 Added By C. Lin - Get Billing Account from field if page parameter has no billing account
        parentId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFPARID);
        thisCase.ParentId = (parentId !=''  && parentId != GlobalVariableClass.NULLVALUE ? parentId : NULL);
        //END UD-3294 26Nov2015 Added By C. Lin
        
        //START: D-2609 3/24/2015  RBustarde - fix for null error on BillAccountId variable
        if(billingaccountId != null){
            //START D-3300 03-Aug-2015 Added by S.Puli-add Zuora__Zuora_Id__c
            thisBillingAccount = [SELECT Zuora__Account__r.Id, Zuora__Account__r.AccountNumber,
                                    Zuora__DefaultPaymentMethod__c, Name, Zuora__BillToAddress1__c, 
                                    Zuora__BillToAddress2__c, Zuora__BillToCity__c,Zuora__BillToName__c, 
                                    Zuora__BillToPostalCode__c, CreatedById, Other_PaymentMethod__c, 
                                    Create_ARMS_Customer_Account__c, ARMS_Business_Profile__c, ARMS_Account_Number__c, 
                                    Credit_Reference__c, Credit_Limit_Internal__c, Credit_Limit_External__c, Approved_Debt_Exposure_Amount__c, 
                                    ARMS_Debt_Management__c, GIRO_A_C__c, GIRO_Bank_Code__c, Business_Sector__c,Zuora__Zuora_Id__c 
                                    FROM Zuora__CustomerAccount__c WHERE Id = :billingaccountId];
            //END D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
            
            //START UD-0810 05-07-2015 Marvin G
            thisOrder = new Order__c();
            
            theseSubscriptions = [select id, Order_Number_1__c, Payment_Mode_1__c, Payment_Mode__c, Other_PaymentMethod_1__c, Other_PaymentMethod__c from Zuora__Subscription__c
                                    where Zuora__CustomerAccount__c = :billingaccountId];
            
            if (theseSubscriptions.size() > 0) {
                for(Zuora__Subscription__c eachSubs :theseSubscriptions ) {
                    orderIds.add(eachSubs.Order_Number_1__c);
                }
            }
                                   
            theseOrders = [Select id, Payment_Mode__c, Other_Payment_Mode__c from Order__c where id IN :orderIds];
            //END UD-0810 05-07-2015 Marvin G
            
            thisCase.AccountId = thisBillingAccount.Zuora__Account__r.Id;
            thisCase.Billing_Account_Name__c = billingaccountId;
            retrieveCreditBalance();
        }
        //END: D-2609 3/24/2015  RBustarde - fix for null error on BillAccountId variable
        //fetchBillingAccount();
        //thisCase.Billing_Account_Name__c = thisBillingAccount.Name;
    }
    
    public List<SelectOption> getAcquisitionTypes() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Zuora__Subscription__c.Acquisition_Type_1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }   
        return options;
    }
    
    public pagereference fetchBillingAccount() {
        try {
            //START:Code Review Implementation 2/18/15 Added by Manolo Vale?a - Checks if dummySubscription.Zuora__CustomerAccount__c is not equal to null.
            if(dummySubscription.Zuora__CustomerAccount__c != null){
                //START D-3300 03-Aug-2015 Added by S.Puli-add Zuora__Zuora_Id__c
                thisBillingAccount = [SELECT ARMS_Business_Profile__c, ARMS_Debt_Management__c, Id, Name, Zuora__PaymentMethod_Type__c, Other_PaymentMethod__c,Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Id = :dummySubscription.Zuora__CustomerAccount__c];
                //END D-3300 03-Aug-2015 Added by S.Puli-add Zuora__Zuora_Id__c
            }
            //END:Code Review Implementation 2/18/15 Added by Manolo Vale?a
        }
        catch(QueryException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid Billing Account!'));
            thisBillingAccount = new Zuora__CustomerAccount__c();
        }
    return null;
    }
    
    public String getSource() {
        return ConstantsSLB.getZuoraUrl('Default');
    }
    //START UD- 1851 8/31/2015 to route cancelled cases to account page
    public PageReference cancel(){
        PageReference pageRef = new PageReference('/' + thisCase.AccountID);
        pageRef.setRedirect(true);
        return pageRef;
    }
    //END UD- 1851 8/31/2015 to route cancelled cases to account page
    
    public pageReference saveRecord() {
        //START D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
        Zuora.zApi zApiInstance = new Zuora.zApi();
            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
            }
        //END D-3300 03-Aug-2015 Added by S.Puli
 //START UD-1389 6/16/2015 GdelRosario : Added validation rule for Saving Payment Method ID
            if(thisCase.Payment_Mode__c == CreditCard){
              if(thisCase.Payment_Method_ID__c == null || thisCase.Payment_Method_ID__c == ''){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('NoPaymentMethodID'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }     
            }                     
        //END UD-1389 6/16/2015 GdelRosario : Added validation rule for Saving Payment Method ID
    
        // START: UD-0562 4/08/2015 K. Tan / added query to populate current payment mode.
        if(thisBillingAccount == null){
            system.debug('>>>>>>>>>>>>>>>>>>' + thisBillingAccount);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Message: ' + ConstantsSLB.getErrorMessage('CreateCaseOnBillingAccount')));
            return null;
        }
        
        //START UD-0810 05-07-2015 Marvin G
        if(thisCase.Payment_Mode__c == 'Cheque' &&  (thisOrder.Check_Issuing_Bank__c == null || thisOrder.Check_No__c == null || thisOrder.Check_Dated__c == null ||
                thisOrder.Check_Amount__c == null || String.valueOf(thisOrder.Check_Issuing_Bank__c) == '' ||  String.valueOf(thisOrder.Check_No__c) == '' ||  String.valueOf(thisOrder.Check_Dated__c) == '' ||  String.valueOf(thisOrder.Check_Amount__c) == '')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please complete check details');
            ApexPages.addMessage(myMsg);
            return null;
        }   
        //END UD-0810 05-07-2015 Marvin G
        
        //START UD-1488 06/08/2015 KAREN HUNG added validation: Business Profile and Debt Management Treatment cannot be  "NONE" if payment method is invoice. 
        if((thisBillingAccount.ARMS_Business_Profile__c == 'NONE' || thisBillingAccount.ARMS_Debt_Management__c == 'NONE') && (thisCase.Payment_Mode__c == 'Invoice')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('ARMSBusProfDebtMgt')));
            return null;
        }
        //END UD-1488 06/08/2015 KAREN HUNG                        
    
        String returnId = '';
        if(thisCase.Payment_Mode__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please populate Payment Mode'));
            return null;
        }
        else{
    
            if(recType != null && recType != ''){
                thisCase.RecordTypeId = recType;
            }       
            //START D-3300 03-Aug-2015 Added by S.Puli-remove this part
            //Zuora.zApi zApiInstance = new Zuora.zApi();
            //END D-3300 03-Aug-2015 Added by S.Puli
            //Login to Zuora
            try {
                Map<String,String> resultMap = new Map<String,String>();
                //START:Code Review Implementation 2/18/15 Added by Manolo Vale?a - Checks if thisCase.Billing_Account_Name__c is not equal to null.
                if(thisCase.Billing_Account_Name__c != null){
                    Zuora__CustomerAccount__c zCust = [SELECT Id, Name, Zuora__External_Id__c, Other_PaymentMethod__c FROM Zuora__CustomerAccount__c WHERE id = : thisCase.Billing_Account_Name__c LIMIT 1];
                    
                    //ZuoraCallOut zCall = new ZuoraCallOut(); 
                    Map<String,Object> pMethod = new Map<String,Object>();
                    
                    pMethod.put('Id', zCust.Zuora__External_Id__c);
                    
                    // Start D-4463 17Mar16 JohnD - commented out due to new logic
                    /*
                    //START: Wenjun - 11/12/2014 - For Billing Batch Number Allocation 
                    String billingType = BillingBatchAllocationHandler.getBillingType(thisCase.Billing_Account_Name__c);
                    
                    String batchNumber = BillingBatchAllocationHandler.allocateBatchNumber(thisCase.Payment_Mode__c,billingType);
                    pMethod.put('Batch', batchNumber);
                    //END of Wenjun Change - 11/12/2014
                    
                    
                    //START: D-2340 3/14/2015  VPernicia - fix for SOQL too many rows 
                    String batchKey = BillingBatchAllocationHandler.generateBatchKey(thisCase.Payment_Mode__c,billingType);
                    
                    //Get Custom Setting
                    String strNumList = ConstantsSLB.getBillingBatch(batchKey);
                    
                    //Process the setting the generate Eligible Batch Number List
                    List<String> numberArray = strNumList.split(',');
    
                    //START: D-2609 3/23/2015  RBustarde - fix for null error on changing of payment type 
                    Billing_Batch__c CSNextBillingBatchNumber = Billing_Batch__c.getValues(batchKey);
                    Integer CurrentBatchNumber = (Integer) CSNextBillingBatchNumber.Next_Batch_Number__c;
                                 
                    Billing_Batch__c NextBatchNumber = [Select Id, Next_Batch_Number__c From Billing_Batch__c Where Name =: batchKey];
                
                    
                    if (numberArray.size()>1){                               
                        integer x = numberArray.size() - 1;
                        if (CurrentBatchNumber == Integer.valueof(numberArray[x])) {
                            NextBatchNumber.Next_Batch_Number__c = Integer.valueof(numberArray[0]);
                            System.debug('==if==[NextBNUM][CurrenBNUM]=>' + NextBatchNumber.Next_Batch_Number__c +'|'+ CurrentBatchNumber) ;
                        } else {                        
                            NextBatchNumber.Next_Batch_Number__c = CurrentBatchNumber + 1;
                            System.debug('==else==[NextBNUM][CurrenBNUM]=>' + NextBatchNumber.Next_Batch_Number__c +'|'+ CurrentBatchNumber) ;
                        }
                    }
                    //END: D-2609 3/23/2015  RBustarde - fix for null error on changing of payment type 
                    
                    //END: D-2340 3/14/2015  VPernicia - fix for SOQL too many rows 
                    */
                    // Start D-4463 17Mar16 JohnD - commented out due to new logic
                    
                    //START: D-1392 - KLorica 1/14/2015 - for Payment Mode Credit Card 1/22/2015 - Added system.debug for investigation
                    //Start/End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
                    if(thisCase.Payment_Mode__c == CreditCard){
                        pMethod.put('DefaultPaymentMethodId', thisCase.Payment_Method_ID__c);
                        //START UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                        //pMethod.put('ARMS_Account_Number__c', '');
                        //END UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                        pMethod.put('Other_PaymentMethod__c', 'N/A');
                        //Start D-4109 VPernicia 12/16/15
                        pMethod.put('PaymentTerm', GlobalVariableClass.PAYMENT_TERM_NORM);
                        //End D-4109 VPernicia 12/16/15
                        //D-4481 4/14/2016 Added by Kristine Balaoing - added payment gateway for credit card
                        pMethod.put('PaymentGateway', 'CyberSource');
                        //D-4481 4/14/2016 Added by Kristine Balaoing
                    }
                    //END: D-1392 - KLorica 1/14/2015 - Remove mapping of AutoPay as true; 1/22/2015 - Added system.debug for investigation
                    //START: D-1452 - KLorica 1/9/2015 - for Payment Mode Cash and Cheque; 1/22/2015 - Added system.debug for investigation
                    //Start/End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
                    else if (thisCase.Payment_Mode__c == Cash) {
                        pMethod.put('DefaultPaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Cash'));
                        pMethod.put('Other_PaymentMethod__c', 'N/A');
                        pMethod.put('AutoPay', 'false');
                        //START UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                        //pMethod.put('ARMS_Account_Number__c', '');
                        //END UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                        //Start D-4109 VPernicia 12/16/15
                        pMethod.put('PaymentTerm', GlobalVariableClass.PAYMENT_TERM_NORM);
                        //End D-4109 VPernicia 12/16/15
                    }  
                    //Start/End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
                    else if (thisCase.Payment_Mode__c == Cheque) {
                        pMethod.put('DefaultPaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Check'));
                        pMethod.put('Other_PaymentMethod__c', 'N/A');  
                        pMethod.put('AutoPay', 'false');
                        //START UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                        //pMethod.put('ARMS_Account_Number__c', '');
                        //END UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                    }
                    //END: D-1452 - KLorica 1/9/2015 - for Payment Mode Cash and Cheque; 1/22/2015 - Added system.debug for investigation
                    else {
                        pMethod.put('DefaultPaymentMethodId', ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other'));
                        pMethod.put('Other_PaymentMethod__c', thisCase.Payment_Mode__c);
                        pMethod.put('AutoPay', 'false');
                        //Start D-4109 VPernicia 12/16/15
                        if(thisCase.Payment_Mode__c != 'Invoice'){
                            pMethod.put('PaymentTerm', GlobalVariableClass.PAYMENT_TERM_NORM);
                        } else {
                            if(thisBillingAccount.ARMS_Debt_Management__c == GlobalVariableClass.SUBL) {
                                pMethod.put('PaymentTerm', GlobalVariableClass.PAYMENT_TERM_SUBL);
                            }
                            else if(thisBillingAccount.ARMS_Debt_Management__c == GlobalVariableClass.SUBH) {
                                pMethod.put('PaymentTerm', GlobalVariableClass.PAYMENT_TERM_SUBH);
                            }
                            else if(thisBillingAccount.ARMS_Debt_Management__c == GlobalVariableClass.GOVT) {
                                pMethod.put('PaymentTerm', GlobalVariableClass.PAYMENT_TERM_GOVT);
                            }
                            else {
                                pMethod.put('PaymentTerm', GlobalVariableClass.PAYMENT_TERM_NORM);
                            }
                        }
                        //End D-4109 VPernicia 12/16/15
                    }
                    //if (!Test.isRunningTest()) {
                        resultMap = zCall.updateZObject(pMethod,'Account', zCust.Zuora__External_Id__c);
                    
                        //START: D-1392 - KLorica 1/14/2015 - for Payment Mode Credit Card; 1/22/2015 - Added system.debug for investigation          
                        //Start/End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String         
                        if (thisCase.Payment_Mode__c == CreditCard && resultMap.get('Status') == 'Success') {
                            Map<String, Object> updateAutoPay = new Map<String, Object>();
                            updateAutoPay.put('AutoPay', 'true');
                            resultMap = zCall.updateZObject(updateAutoPay,'Account', zCust.Zuora__External_Id__c);
                        } 
                        System.debug('^^resultMap : ' + resultMap);
                        //END: D-1392 - KLorica 1/14/2015 - Update AutoPay as true; 1/22/2015 - Added system.debug for investigation
    
                        
                    //}
                    //else {
                    //    resultMap = new Map<String, String>{'Status' => 'Error'};
                    //}
                    
                    // START: Commented out by Wenjun 11/12/14 - Duplicated Call-out Statement
                    //resultMap = zCall.updateZObject(pMethod,'Account', zCust.Zuora__External_Id__c);
                    // END: Wenjun 11/12/14
    
                    if(resultMap.get('Status')=='Success') {
                    
                        //START D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
                        // prepare data for zuora update
                        Zuora.zObject zObject = new Zuora.zObject('Account');
                        zObject.setValue('Id', thisBillingAccount.Zuora__Zuora_Id__c);
                        //START UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                        //zObject.setValue('ARMS_Account_Number__c', '');
                        //zObject.setValue('ARMS_Business_Profile__c', 'N/A');
                        //zObject.setValue('ARMS_Debt_Management__c', 'N/A');
                        //zObject.setValue('ARMS_ID__c', '');
                        //END UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                        zObjectList.add(zObject);
                            
                        if (zObjectList <> null && zObjectList.size() > 0) {
                            //START D-**** 27-May-2016 JC Aduan - added this condition to avoid zapinstance callout
                                                                // upon running the test class that stop coverage below
                            if(!Test.isRunningTest()){
                                List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
                            }
                            //END
                            
                        }

                        //END D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
                        String pId = resultMap.get('Id');
                        if(thisCase.Id == null) {
                            insert thisCase;
                        }
                        else {
                            update thisCase;
                        } 
                        //START: D-2340 3/14/2015  VPernicia - fix for SOQL too many rows  
                        // update NextBatchNumber;  // Start/End D-4463 17Mar16 JohnD - commented out
                        
                            
                        //START UD-0810 05-07-2015 Marvin G
                        if (thisCase.Payment_Mode__c != 'CreditCard') {
                            thisBillingAccount.Zuora__Default_Payment_Method__c = null;
                            thisBillingAccount.Zuora__CreditCardNumber__c = null;
                        }
                        
                        if(thisCase.Payment_Mode__c == 'Invoice'){
                            thisBillingAccount.Payment_Mode__c = 'Other';
                            thisBillingAccount.Zuora__DefaultPaymentMethod__c = 'Other';
                            thisBillingAccount.Other_PaymentMethod__c = thisCase.Payment_Mode__c;
                            
                            //Start D-4109 VPernicia 12/16/15
                            if(thisBillingAccount.ARMS_Debt_Management__c == GlobalVariableClass.SUBL) {
                                thisBillingAccount.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBL;
                            }
                            else if(thisBillingAccount.ARMS_Debt_Management__c == GlobalVariableClass.SUBH) {
                                thisBillingAccount.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBH;
                            }
                            else if(thisBillingAccount.ARMS_Debt_Management__c == GlobalVariableClass.GOVT) {
                                thisBillingAccount.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_GOVT;
                            }
                            else {
                                thisBillingAccount.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_NORM;
                            }
                            //End D-4109 VPernicia 12/16/15
                            
                            updateOrderAndSubscriptions ('Other', thisCase.Payment_Mode__c);
                        
                            updateBillingAccountArms();
                            update thisBillingAccount;
                       
                        
                            if(thisBillingAccount.Create_ARMS_Customer_Account__c == false){
                                ARMS_TriggerHandler.isSkipUpdate = true;
                                //thisBillingAccount.Payment_Mode__c = 'Other';    
                                update thisBillingAccount;
                            }
                            else{
                                updateCreateCustomerService();
                            
                            }
                        }
                        else if(thisCase.Payment_Mode__c == 'Cash' || thisCase.Payment_Mode__c == 'CreditCard' || thisCase.Payment_Mode__c == 'Cheque') {
                            
                            //Start D-4109 VPernicia 12/16/15
                            thisBillingAccount.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_NORM;
                            //End D-4109 VPernicia 12/16/15
                            if(thisCase.Payment_Mode__c == 'Cheque'){
                                thisBillingAccount.Payment_Mode__c = 'Check';
                                thisBillingAccount.Zuora__DefaultPaymentMethod__c = 'Check';
                                thisBillingAccount.Other_PaymentMethod__c = '';


                                //START PD-0532 6/23/2016 Added By L. Valencia - Set to false to ensure that validation rule will not be triggered
                                thisBillingAccount.ARMS_Account_Required__c = false;
                                //END PD-0532 6/23/2016 Added By L. Valencia
                                
                                thisBillingAccount.ARMS_Account_Number__c = '';
                                thisBillingAccount.ARMS_Customer_Number__c = '';
                                thisBillingAccount.ARMS_ID__c = '';
                                thisBillingAccount.ARMS_Business_Profile__c = '';
                                thisBillingAccount.ARMS_Debt_Management__c = '';

                                updateOrderAndSubscriptions ('Check', '');
                                
                                update thisBillingAccount;
                            }
                            else{
                                thisBillingAccount.Payment_Mode__c = thisCase.Payment_Mode__c;
                                thisBillingAccount.Zuora__DefaultPaymentMethod__c = thisCase.Payment_Mode__c;
                                thisBillingAccount.Other_PaymentMethod__c = '';
                                
                                //START D-3059 5/29/2015
                                thisBillingAccount.ARMS_Account_Required__c = false;
                                //END D-3059 5/29/2015
                                
                                thisBillingAccount.ARMS_Account_Number__c = '';
                                thisBillingAccount.ARMS_Customer_Number__c = '';
                                thisBillingAccount.ARMS_ID__c = '';
                                thisBillingAccount.ARMS_Business_Profile__c = '';
                                thisBillingAccount.ARMS_Debt_Management__c = '';
                                
                                updateOrderAndSubscriptions (thisCase.Payment_Mode__c, '');
                                update thisBillingAccount;
                            }
                        
                        }
                        else{
                            
                            //Start D-4109 VPernicia 12/16/15
                            thisBillingAccount.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_NORM;
                            //End D-4109 VPernicia 12/16/15
                        
                            thisBillingAccount.Payment_Mode__c = 'Other';
                            thisBillingAccount.Zuora__DefaultPaymentMethod__c = 'Other';
                            thisBillingAccount.Other_PaymentMethod__c = thisCase.Payment_Mode__c;
                           
                            updateOrderAndSubscriptions ('Other', thisCase.Payment_Mode__c);
                            update thisBillingAccount;
                        
                        }
                            
                    }   
                        //catch (Exception e){
                        
                        //END UD-0810 05-07-2015 Marvin G
                        //END: D-2340 3/14/2015  VPernicia - fix for SOQL too many rows
                   // }                           
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Message: ' + resultMap.get('Message')));                    
                        return null;
                    }   
                }
                //END:Code Review Implementation 2/18/15 Added by Manolo Vale?a
            }
            //START UD-3849 2/2/2016 Added by J.Sarion - Set Catch
            catch (DmlException e) {
                ExceptionLogger.log(new list<exception> { e });
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error trying to save case. Error: ' +  e.getMessage()));
                return null;
            }
      
            catch (Zuora.zRemoteException ex) {
                if ('INVALID_FIELD' == ex.code) {
                    // An invalid field was specified             
                }
                else {
                }
                ExceptionLogger.log(new list<exception> { ex });
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error trying to save case. Error: ' +  ex.getMessage()));
                return null;
            }
            
            catch (Exception e) {
                ExceptionLogger.log(new list<exception> { e });
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error trying to save case. Error: ' +  e.getMessage()));
                return null;
            }
            //END UD-3849 2/2/2016 Added by J.Sarion - Set Catch
            
            if(thisCase.Id != NULL) {
                returnId = thisCase.Id; 
            }
    
          }  
            return new PageReference('/' + returnId);
    }
    
    //START UD-0810 05-07-2015 Marvin G
    public void updateOrderAndSubscriptions (String pMode, String otherPMode) {
        List<Zuora__Subscription__c> mySubs = new List<Zuora__Subscription__c>();
        List<Order__c> myOrders = new List<Order__c>();
        
        if (theseSubscriptions.size() > 0) {
            for(Zuora__Subscription__c eachSubs :theseSubscriptions ) {
                eachSubs.Payment_Mode_1__c = pMode;
                eachSubs.Payment_Mode__c = pMode;
                eachSubs.Other_PaymentMethod_1__c = otherPMode;
                eachSubs.Other_PaymentMethod__c = otherPMode;
                mySubs.add(eachSubs);
            }
        }

        if (theseOrders.size() > 0) {
            for(Order__c eachOrder :theseOrders) {
                eachOrder.Payment_Mode__c = pMode;
                eachOrder.Other_Payment_Mode__c = otherPMode;
                if (pMode == 'Check') {
                    eachOrder.Check_Issuing_Bank__c = thisOrder.Check_Issuing_Bank__c;
                    eachOrder.Check_No__c = thisOrder.Check_No__c;
                    eachOrder.Check_Dated__c = thisOrder.Check_Dated__c;
                    eachOrder.Check_Amount__c = thisOrder.Check_Amount__c;
                    eachOrder.Remarks__c = thisOrder.Remarks__c;
                }
                else {
                    eachOrder.Check_Issuing_Bank__c = '';
                    eachOrder.Check_No__c = '';
                    eachOrder.Check_Dated__c = null;
                    eachOrder.Check_Amount__c = 0;
                    eachOrder.Remarks__c = '';
                }
                
                myOrders.add(eachOrder);
            }
        }
        
        update myOrders;
        update mySubs;
    }
    //END UD-0810 05-07-2015 Marvin G
    
    
    // END: UD-0562 4/08/2015 K. Tan / added query to populate current payment mode.

    // START: D-2092 2/27/2015 K. Tan / Added Method to retrieve Billing Account Credit Balance on Case
    // START: UD-0562 4/08/2015 K. Tan / added query to populate current payment mode.
  
    public void retrieveCreditBalance(){
    
        Zuora__CustomerAccount__c zAcc = [SELECT Id, Name, Zuora__Credit_Balance__c, Credit_Term__c, Payment_Mode__c, Zuora__DefaultPaymentMethod__c, Other_PaymentMethod__c FROM Zuora__CustomerAccount__c WHERE Id=:thisCase.Billing_Account_Name__c];
    
        thisCase.Credit_Balance__c = zAcc.Zuora__Credit_Balance__c;
        //Start D-2723 18-July-2015 Added by S.Puli
        thisCase.Credit_Amount__c = zAcc.Zuora__Credit_Balance__c;
        //End D-2723 18-July-2015 Added by S.Puli
        thisCase.Current_Payment_Mode__c = zAcc.Zuora__DefaultPaymentMethod__c;
        
    // END: UD-0562 4/08/2015 K. Tan / added query to populate current payment mode.
        
     // END: D-2092 2/27/2015 K. Tan / Added Method to retrieve Billing Account Credit Balance on Case
      
    }
    
    //ARMS Details to Display MMallorca 04/22/2015
    public Boolean Create_ARMS_Customer_Account {get;set;}
    public String ARMS_Account_Number {get;set;} 
    public Boolean Create_ARMS_Account_Only {get;set;}
    public Boolean ARMS_Account_Required{get;set;}
    public String ARMS_Account_Type{get;set;}
    public String ARMS_Activity_Status_Sub_Type{get;set;}
    public String ARMS_Activity_Status_Type{get;set;}
    public Decimal ARMS_Bad_Debt_Amount{get;set;}
    public String ARMS_Business_Profile{get;set;}
    public Decimal ARMS_Credit_Balance{get;set;}
    public String ARMS_Customer_Number{get;set;}
    public String ARMS_Debt_Management{get;set;}
    public Id ARMS_ID{get;set;}
    public String ARMS_Return_Message{get;set;}
    public String ARMS_Return_Status{get;set;}
    public Decimal ARMS_Total_Outstanding_Amount{get;set;}
    public Boolean ARMS_Update_Ind{get;set;}
    public Decimal Credit_Term {get;set;}
    public String Credit_Reference {get;set;}
    public Decimal Credit_Limit_Internal {get;set;}
    public Decimal Credit_Limit_External {get;set;}
    
    //Start MMallorca 04/22/2015
    public void updateBillingAccountArms(){
    
        try{ 
            Zuora__CustomerAccount__c zAcc = [SELECT Id, Name, Credit_Term__c, Payment_Mode__c, Zuora__DefaultPaymentMethod__c, Zuora__External_Id__c, Zuora__Account__c, Other_PaymentMethod__c FROM Zuora__CustomerAccount__c WHERE Id=:thisBillingAccount.Id];
    
        // MMallorca 04/22/2015 Added query if there's an existing ARMS
            Zuora__CustomerAccount__c bc= [SELECT  Credit_Reference__c, Credit_Term__c, Credit_Limit_Internal__c, Credit_Limit_External__c, Create_ARMS_Account_Only__c, Create_ARMS_Customer_Account__c, ARMS_Account_Number__c, ARMS_Account_Required__c, ARMS_Account_Type__c,ARMS_Activity_Status_Sub_Type__c,ARMS_Activity_Status_Type__c, ARMS_Bad_Debt_Amount__c, ARMS_Business_Profile__c, ARMS_Credit_Balance__c,ARMS_Customer_Number__c, ARMS_Debt_Management__c, ARMS_ID__c,ARMS_Return_Message__c,ARMS_Return_Status__c, ARMS_Total_Outstanding_Amount__c,ARMS_Update_Ind__c, Other_PaymentMethod__c FROM Zuora__CustomerAccount__c WHERE ARMS_ID__c != null AND Zuora__Account__c =: zAcc.Zuora__Account__c Limit 1];
        
            //Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Id = zAcc.Id);
            
                
            if(bc != null){
                isArms = true;
                thisBillingAccount.Create_ARMS_Account_Only__c = bc.Create_ARMS_Account_Only__c;
                thisBillingAccount.Create_ARMS_Customer_Account__c= bc.Create_ARMS_Customer_Account__c;
                thisBillingAccount.ARMS_Account_Number__c= bc.ARMS_Account_Number__c;
                thisBillingAccount.ARMS_Account_Required__c= bc.ARMS_Account_Required__c;
                thisBillingAccount.ARMS_Account_Type__c= bc.ARMS_Account_Type__c;
                thisBillingAccount.ARMS_Activity_Status_Sub_Type__c= bc.ARMS_Activity_Status_Sub_Type__c;
                thisBillingAccount.ARMS_Activity_Status_Type__c= bc.ARMS_Activity_Status_Type__c;
                thisBillingAccount.ARMS_Bad_Debt_Amount__c= bc.ARMS_Bad_Debt_Amount__c;
                thisBillingAccount.ARMS_Business_Profile__c= bc.ARMS_Business_Profile__c;
                thisBillingAccount.ARMS_Credit_Balance__c= bc.ARMS_Credit_Balance__c;
                thisBillingAccount.ARMS_Customer_Number__c= bc.ARMS_Customer_Number__c;
                thisBillingAccount.ARMS_Debt_Management__c= bc.ARMS_Debt_Management__c;
                thisBillingAccount.ARMS_ID__c= bc.ARMS_ID__c;
                thisBillingAccount.ARMS_Return_Message__c= bc.ARMS_Return_Message__c;
                thisBillingAccount.ARMS_Return_Status__c= bc.ARMS_Return_Status__c;
                thisBillingAccount.ARMS_Total_Outstanding_Amount__c= bc.ARMS_Total_Outstanding_Amount__c;
                thisBillingAccount.ARMS_Update_Ind__c= bc.ARMS_Update_Ind__c;
                //START: D-3299 D-3298 K. Tan 7/30/2015
                thisBillingAccount.Zuora__DefaultPaymentMethod__c = 'Other';
                //END: D-3299 D-3298 K. Tan 7/30/2015
                thisBillingAccount.Other_PaymentMethod__c = 'Invoice';
                thisBillingAccount.Payment_Mode__c = 'Other';
                //Credit_Term = bc.Credit_Term__c;
                //display existing arms
                Create_ARMS_Customer_Account = bc.Create_ARMS_Customer_Account__c;
                ARMS_Account_Number= bc.ARMS_Account_Number__c;
                Create_ARMS_Account_Only = bc.Create_ARMS_Account_Only__c;
                Create_ARMS_Customer_Account= bc.Create_ARMS_Customer_Account__c;
                ARMS_Account_Number= bc.ARMS_Account_Number__c;
                ARMS_Account_Required= bc.ARMS_Account_Required__c;
                ARMS_Account_Type= bc.ARMS_Account_Type__c;
                ARMS_Activity_Status_Sub_Type= bc.ARMS_Activity_Status_Sub_Type__c;
                ARMS_Activity_Status_Type= bc.ARMS_Activity_Status_Type__c;
                ARMS_Bad_Debt_Amount= bc.ARMS_Bad_Debt_Amount__c;
                ARMS_Business_Profile= bc.ARMS_Business_Profile__c;
                ARMS_Credit_Balance= bc.ARMS_Credit_Balance__c;
                ARMS_Customer_Number= bc.ARMS_Customer_Number__c;
                ARMS_Debt_Management= bc.ARMS_Debt_Management__c;                
                ARMS_Return_Message= bc.ARMS_Return_Message__c;
                ARMS_Return_Status= bc.ARMS_Return_Status__c;
                ARMS_Total_Outstanding_Amount= bc.ARMS_Total_Outstanding_Amount__c;
                ARMS_Update_Ind= bc.ARMS_Update_Ind__c;
                Credit_Term = bc.Credit_Term__c; 
                Credit_Reference= bc.Credit_Reference__c; 
                Credit_Limit_Internal = bc.Credit_Limit_Internal__c;
                Credit_Limit_External = bc.Credit_Limit_External__c; 
                ARMS_ID= bc.ARMS_ID__c;               
                ARMS_TriggerHandler.isSkipUpdate = true;
                
                Map<String, Object> updateARMSID = new Map<String, Object>();
                //START UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                //updateARMSID.put('ARMS_Account_Number__c', ARMS_Account_Number);
                //END UD-2653 17-Sept-2015 - Remove zuora callout for arms fields
                zCall.updateZObject(updateARMSID,'Account', zAcc.Zuora__External_Id__c);
                update thisBillingAccount;
            }
            else{
                isArms = false;
            }
        }
        catch(exception ex){
            
        }
        
    }
    //END  MMallorca 04/22/2015
    
    
    //START D-0870 ADD MMallorca 4/21/2015 ARMS Component      
    public String aCust {get; set;}         
    public string billAccName {get; set;}       
    public boolean billAcc {get; set;}      
            
    public String accTextName {get; set;}       
    public String accNum {get; set;}        
    public String errorMsg {get; set;}      
    public boolean displayCusErr {get; set;}        
    public boolean displayAccList {get; set;}       
    public boolean addAccount {get; set;}       
    public boolean redisplay;       
    public boolean CBdisable {get; set;}        
                
    public class armsWrapper {      
                
        public string arNum {get; set;}         
        public string arName {get; set;}        
        public string arPOC {get; set;}         
        public string arAddress {get; set;}         
        public string arPostcode {get; set;}        
        public string arStatus {get; set;}      
        public string arBusProf {get; set;}         
        public string arDate {get; set;}        
        public boolean isTick {get; set;}       
        public string arAccNum {get; set;}      
        public string arType {get; set;}        
        public string arCredTerm{get; set;}         
        public string arCredTermRef {get; set;}         
        public string arDebtMgmt {get; set;}        
        public string arCompCode {get; set;}        
        public string arCreateDate {get; set;}      
        public string arBLInd {get; set;}       
        public string BLClrCd {get; set;}       
        public string BLRsn {get; set;}         
        public string IdTyp {get; set;}         
        public string IdN {get; set;}       
        public string PpCntryC {get; set;}      
        public string CrRskRtg {get; set;}      
        public string CrLmtInt {get; set;}      
        public string CrLmtExt {get; set;}      
        public string CityM {get; set;}         
        public string Cntry {get; set;}         
        public string PoBoxN {get; set;}        
        public string AttnI {get; set;}         
        public string StfI {get; set;}      
        public string GstOOSI {get; set;}       
        public string UpdId {get; set;}         
        public string UpdDte {get; set;}        
        public string UpdTme {get; set;}        
        public string arAddress1 {get; set;}        
        public string arAddress2 {get; set;}        
        public string arAddress3 {get; set;}        
        public string arAddress4 {get; set;}        
    }       
                
    public List<armsWrapper> armsCusWrapList {get; set;}        
    public List<armsWrapper> armsSelected {get; set;}       
                
                
    public void getBillAccName() {      
        //START D-2760 14-Apr-2015 Added by Raviteja  - Commented for as part of the duplicate ARMS ID changes
        /*
        List<Zuora__CustomerAccount__c> invoiceList = [Select Name, Id, Payment_Mode__c, Zuora__Account__c from Zuora__CustomerAccount__c Where Zuora__Account__c = :accountId AND Other_PaymentMethod__c = 'Invoice' limit 1];
        if (invoiceList.size()>0 && thisBillingAccount.Other_PaymentMethod__c== 'Invoice'){
            for(Zuora__CustomerAccount__c aRec : invoiceList){
                billAccName = aRec.Name;
                billAcc = false;
                ApexPages.Message billAccMessage = new ApexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.getErrorMessage('ARMS Existing invoice')+ billAccName);
                ApexPages.addMessage(billAccMessage);
                //Start UD-0433 3/18/2015 James - set variable values
                existinginvoicebilling = true;
                existinginvoicebillingname = billAccName;
            //End UD-0433 3/18/2015 James             
            }
        } else {
            billAccName = null;
            billAcc = true;
        }
        */
        billAccName = null;
        billAcc = true;
        //End D-2760 14-Apr-2015 Added by Raviteja     
    }       
                
    public void searchCusName(){      
            
        try{                
            accTextName =null;      
            accNum = null;      
        
            if(aCust<>null && aCust<>''){       
                                    
                //callout to webservice to search       
                wwwSphComArWsWsdlCam.SearchCustomerRequestType searchCusReq = new wwwSphComArWsWsdlCam.SearchCustomerRequestType();         
        
                searchCusReq.CusSrch = new wwwSphComArWsSchemaCamSearchcusto.CusSrch_element();         
                searchCusReq.CusSrch.SysId = ConstantsSLB.getOther('ARMS_SysId');       
                searchCusReq.CusSrch.CusM1 = aCust;         
        
        
                searchCusReq.user_x = new wwwSphComArWsSchemaCommonUser.UserType();         
                searchCusReq.user_x.userID = ConstantsSLB.getOther('ARMS_userID');      
                searchCusReq.user_x.password =  ConstantsSLB.getOther('ARMS_password');         
        
                wwwSphComArWsWsdlCam.CAMSOAP CusRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();       
        
               // System.assert(false, '***test: '+searchCusReq);
                //START D-**** 27-May-2016 JC Aduan - added this condition to avoid zapinstance callout
                                                                // upon running the test class that stop proceeding coverage below
                wwwSphComArWsWsdlCam.SearchCustomerResponseType cusResp;
                // if(!test.isRunningTest()){
                     cusResp = CusRespCAM.SearchCustomer(searchCusReq); 
                // }
                //END

                if(cusResp<>null){      
                    if(cusResp.CusSrchResp<>null){      
                        //cusResp.CusSrchResp.SysId         
                        if(cusResp.CusSrchResp.RtnSts == '0'){      
                                //cusResp.CusSrchResp.NRec      
                            //cusResp.CusSrchResp.L_Cus.Cus         
        
                            if(cusResp.CusSrchResp.L_Cus.Cus<>null){        
                                displayAccList = true;      
                                List<armsWrapper> arCusList = new List<armsWrapper>();      
                                //loop the customer results         
                                for(wwwSphComArWsSchemaCamSearchcustoR.CusType a : cusResp.CusSrchResp.L_Cus.Cus){      
                                        
                                armsWrapper awCus = new armsWrapper();      
                                    awCus.arNum = a.CusN;       
                                    awCus.arName = a.CusM1;         
                                    if(a.CusM2<>null && a.CusM2<>' '){      
                                        awCus.arName += a.CusM2;        
                                    }       
                                    awCus.arDate = a.CusCreDte;         
                                    awCus.arStatus = a.CusSts;      
         
                                    String adressText=''; //need to initialize variable before value assignment         
                                    /*20141126*/        
                                        if(a.BlkN<>null && a.BlkN<>'' && a.BlkN<>'null'){       
                                            adressText += a.BlkN +' ';      
                                        }       
                                        if(a.FlrN<>null && a.FlrN<>'' && a.FlrN<>'null'){       
                                            adressText += a.FlrN +' ';      
                                        }       
                                        if(a.UntN<>null && a.UntN<>'' && a.UntN<>'null'){       
                                            adressText += a.UntN +' ';      
                                        }       
                                        if(a.Str<>null && a.Str<>'' && a.Str<>'null'){      
                                            adressText += a.Str +' ';       
                                        }       
                                        if(a.BldgSec<>null && a.BldgSec<>'' && a.BldgSec<>'null'){      
                                            adressText += a.BldgSec +' ';       
                                        }       
                                        if(a.CusA1<>null && a.CusA1<>'' && a.CusA1<>'null'){        
                                            adressText += a.CusA1 +' ';         
                                            awCus.arAddress1 = a.CusA1;         
                                        }       
                                        if(a.CusA2<>null && a.CusA2<>'' && a.CusA2<>'null'){        
                                            adressText += a.CusA2 +' ';         
                                            awCus.arAddress2 = a.CusA2;         
                                        }       
                                        if(a.CusA3<>null && a.CusA3<>'' && a.CusA3<>'null'){        
                                            adressText += a.CusA3 +' ';         
                                            awCus.arAddress3 = a.CusA3;         
                                        }       
                                        if(a.CusA4<>null && a.CusA4<>'' && a.CusA4<>'null'){        
                                            adressText += a.CusA4 +' ';         
                                            awCus.arAddress4 = a.CusA4;         
                                        }       
        
                                    awCus.arAddress = adressText;       
        
                                    awCus.arPostcode = a.PstC;           
                                    awCus.arPOC = a.Attn;              
                                    awCus.arBusProf = a.BizP;             
                                    awCus.isTick = false;       
                                    arCusList.add(awCus);       
                                }       
                                if(arCusList<>null){        
                                    armsCusWrapList = arCusList;        
                                }       
                            }               
        
                        } else if (cusResp.CusSrchResp.RtnSts <> '0' || cusResp.CusSrchResp.RtnSts == null){        
                                    
                            displayCusErr = true;       
                            CBdisable = false;      
                            //errorMsg = ConstantsSLB.getErrorMessage('ARMS customer is not existing');         
                            errorMsg = cusResp.CusSrchResp.RtnMsg;      
                            thisBillingAccount.ARMS_Debt_Management__c = 'SUBH';        
                            thisBillingAccount.ARMS_Business_Profile__c = 'NORM';         
        
                        }       
                    } else if(cusResp.CusSrchResp==null){       
                        displayCusErr = true;       
                        CBdisable = false;      
                        errorMsg = ConstantsSLB.getErrorMessage('Invalid Response');        
                        thisBillingAccount.ARMS_Debt_Management__c = 'SUBH';        
                        thisBillingAccount.ARMS_Business_Profile__c = 'NORM';         
                    }       
                }       
            }       
        }catch(CallOutException ce){        
            system.debug(ce.getMessage());      
            displayCusErr = true;       
            CBdisable = false;      
            //errorMsg = ConstantsSLB.getErrorMessage('ARMS customer is not existing');         
            thisBillingAccount.ARMS_Debt_Management__c = 'SUBH';        
            thisBillingAccount.ARMS_Business_Profile__c = 'NORM';                 
            errorMsg = ConstantsSLB.getErrorMessage('ARMS Timed-out');      
        }       
                
    }       
                
    public void searchAccName(){        
        try{        
            if(aCust<>null && aCust<>''){       
                
                billAcc = true;
                
                wwwSphComArWsWsdlCam.SearchAccountRequestType searchAccReq = new wwwSphComArWsWsdlCam.SearchAccountRequestType();       
        
                searchAccReq.AccSrch = new wwwSphComArWsSchemaCamSearchaccou.AccSrch_element();         
                searchAccReq.AccSrch.SysId = ConstantsSLB.getOther('ARMS_SysId');       
                searchAccReq.AccSrch.CusN = accNum;         
                searchAccReq.AccSrch.AccTyp = ConstantsSLB.getOther('ARMS_AccTyp');         
                searchAccReq.AccSrch.CoyCd = ConstantsSLB.getOther('ARMS_CoyCd');       
        
                searchAccReq.user_x = new wwwSphComArWsSchemaCommonUser.UserType();         
                searchAccReq.user_x.userID = ConstantsSLB.getOther('ARMS_userID');      
                searchAccReq.user_x.password =  ConstantsSLB.getOther('ARMS_password');         
        
                wwwSphComArWsWsdlCam.CAMSOAP AccRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();   
                System.debug('%%%searchAccReq : '+ searchAccReq);
                System.debug('>>>>>AccRespCAM: ' + AccRespCAM);      
                //START D-**** 27-May-2016 JC Aduan - added this condition to avoid zapinstance callout
                                                                // upon running the test class that stop proceeding coverage below
                wwwSphComArWsWsdlCam.SearchAccountResponseType accResp;
                // if(!test.isRunningTest()){
                     accResp = AccRespCAM.SearchAccount(searchAccReq);
                // }else{

                // }
                //END    

                System.debug('>>>>>searchAccReq: ' + searchAccReq);    
                System.debug('>>>>>accResp: ' + accResp);    
                        
                if(accResp<>null){      
                    if(accResp.AccSrchResp<>null){      
                        //accResp.AccSrchResp.SysId;        
                        if(accResp.AccSrchResp.RtnSts == '0' && accResp.AccSrchResp.SysId == ConstantsSLB.getOther('ARMS_SysId')){                     
        
                            if(accResp.AccSrchResp.L_Acc.Acc<>null){        
                               thisBillingAccount.Create_ARMS_Account_Only__c = false;      
                                addAccount = true;      
                                List<armsWrapper> awList = new List<armsWrapper>();         
                                        
                                for(wwwSphComArWsSchemaCamSearchaccouR.AccType acR : accResp.AccSrchResp.L_Acc.Acc){        
                                        
                                    armsWrapper aW = new armsWrapper();         
                                        //acR.CusN;         
                                        aW.arAccNum = acR.AccN;         
                                        aW.arType = acR.AccTyp;         
                                        aW.arCreateDate = acR.AccCreDte;        
                                        aW.arCredTerm = acR.CrTrm;      
                                        aW.arCredTermRef = acR.CrTrmRef;               
                                        aW.arDebtMgmt = acR.DbtStrt;             
                                        aW.arCompCode = acR.CoyCd;         
                                                
                                        //populate order fields         
                                        thisBillingAccount.ARMS_Account_Number__c = acR.AccN;     
                                        thisBillingAccount.Credit_Reference__c = acR.CrTrmRef;      
                                        thisBillingAccount.Credit_Limit_Internal__c = decimal.valueof(acR.CrLmtInt);        
                                        thisBillingAccount.Credit_Limit_External__c = decimal.valueof(acR.CrLmtExt);        
                                        thisBillingAccount.Approved_Debt_Exposure_Amount__c = decimal.valueof(acR.DbtExp);        
                                        thisBillingAccount.ARMS_Debt_Management__c = acR.DbtStrt;       
                                        thisBillingAccount.GIRO_A_C__c = acR.CusGrAccN;         
                                        thisBillingAccount.GIRO_Bank_Code__c = acR.CusGrBnkN;         
                                        thisBillingAccount.Business_Sector__c = acR.BizSctr;   
        
                                                
                                    if(acR.AccTyp == ConstantsSLB.getOther('ARMS_AccTyp')){         
                                        awList.add(aW);         
                                    }       
                                }       
                                if(awList<>null && awList.size() == 1){         
                                    armsSelected = awList;      
                                    thisBillingAccount.Create_ARMS_Account_Only__c = false;      
                                } else if(awList<>null && awList.size() > 1){       
                                    displayCusErr = true;       
                                    errorMsg = ConstantsSLB.getErrorMessage('ARMS account too many record');        
                                    CBdisable = false;      
                                    thisBillingAccount.Create_ARMS_Account_Only__c = true;       
                                            
                                }       
                                        
                            }       
                        } else if(accResp.AccSrchResp.RtnSts == '1'){       
                                    
                            displayCusErr = true;       
                            errorMsg = ConstantsSLB.getErrorMessage('ARMS account is not existing');        
                            CBdisable = false;      
                            thisBillingAccount.Create_ARMS_Account_Only__c = true;       
                            thisBillingAccount.ARMS_Debt_Management__c = 'SUBH';        
                                
                        } else if(accResp.AccSrchResp.RtnSts == '8'){       
                                    
                            displayCusErr = true;       
                            errorMsg = ConstantsSLB.getErrorMessage('ARMS account too many record');        
                            CBdisable = true;           
                                
                        } else {        
                                    
                            displayCusErr = true;       
                            errorMsg = accResp.AccSrchResp.RtnMsg;      
                            CBdisable = false;      
                            thisBillingAccount.Create_ARMS_Account_Only__c = true;       
                            thisBillingAccount.ARMS_Debt_Management__c = 'SUBH';        
                        }       
                    } else  if(accResp.AccSrchResp==null){      
                        displayCusErr = true;       
                        errorMsg = ConstantsSLB.getErrorMessage('Invalid Response');        
                        CBdisable = false;      
                        thisBillingAccount.Create_ARMS_Account_Only__c = true;       
                        thisBillingAccount.ARMS_Debt_Management__c = 'SUBH';        
                    }       
                }       
            }       
        }catch(CallOutException ce){        
            system.debug(ce.getMessage());      
            displayCusErr = true;       
            errorMsg = ConstantsSLB.getErrorMessage('ARMS Timed-out');      
       }        
    }           
                
    public void addPopAcc() {           
        redisplay = false;      
        displayAccList = false;         
        List<armsWrapper> awrList = new List<armsWrapper>();        
        if(armsCusWrapList.size()>0){       
            for(armsWrapper awl : armsCusWrapList){         
                if(awl.isTick == true){         
                    awrList.add(awl);       
                    accTextName = awl.arName;       
                    accNum = awl.arNum;    
                    
                    ////////// field not exists        
                    //thisBillingAccount.Customer_Name__c = accTextName;  
                    thisBillingAccount.ARMS_Customer_Number__c = accNum;
                    thisBillingAccount.ARMS_ID__c = accNum;
                    thisBillingAccount.Payment_Mode__c = 'Other'; 
                    thisBillingAccount.Zuora__BillToAddress1__c= awl.arAddress1;         
                    thisBillingAccount.Zuora__BillToAddress2__c = awl.arAddress2; 
                    thisBillingAccount.ARMS_Business_Profile__c = awl.arBusProf;                             
                }       
            }       
        }       
        if(awrList.size()==1){      
            armsSelected = awrList;         
            CBdisable = true;       
            thisBillingAccount.Create_ARMS_Customer_Account__c = false;      
            thisBillingAccount.Create_ARMS_Account_Only__c = true;       
                    
        } else if(awrList.size()>1){        
            displayCusErr = true;       
            redisplay = true;       
            thisBillingAccount.Create_ARMS_Account_Only__c = false;      
            errorMsg = ConstantsSLB.getErrorMessage('ARMS select one Customer only');       
        }       
                
    }       
                
    public void closePopup() {               
        displayCusErr = false;      
        displayAccList = false;         
        if(redisplay == true){      
            displayAccList = true;      
        }       
    }               
                
    public void cancelSearch() {               
        displayAccList = false;         
        addAccount = false;         
        CBdisable = false;      
    }           
        //END D-0870 ADD MMallorca 4/21/2015 ARMS Component
        
    public void updateCreateCustomerService(){
   
        string referenceKey = thisBillingAccount.Zuora__Account__r.AccountNumber;
        string uniqueKey = thisBillingAccount.Zuora__Account__r.AccountNumber;
            
            
        if (thisBillingAccount.Zuora__Account__r.AccountNumber != null) {
            
            if (thisBillingAccount.Zuora__Account__r.AccountNumber.length() > 10) {
                
                referenceKey =  thisBillingAccount.Zuora__Account__r.AccountNumber.substring(0, 10);
            }

            if (thisBillingAccount.Zuora__Account__r.AccountNumber.length() > 26) {
                
                uniqueKey = thisBillingAccount.Zuora__Account__r.AccountNumber.substring(0, 26);
            }
        }
         
            
        BT_CO_ARMS_CreateCustAccountFile__c cusRec1 = new BT_CO_ARMS_CreateCustAccountFile__c(
            Customer_Name1__c = thisBillingAccount.Name,
            Customer_Status__c = ConstantsSLB.getOther('ARMS_CusSts'),
            Reference_Key__c = referenceKey,
            Unique_Key__c = uniqueKey,
            Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
            Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt'),
            Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt'),
            Create_Id__c = String.valueOf(thisBillingAccount.CreatedById).substring(0,15),
            
            Postal_Code__c = thisBillingAccount.Zuora__BillToPostalCode__c,
            City_Zip__c = thisBillingAccount.Zuora__BillToCity__c,
            //Country__c = thisBillingAccount.Zuora__BillToCountry__c,
            Sub_Contact_Name__c = thisBillingAccount.Zuora__BillToName__c,
            Debt_Mgt_Treatment__c = thisBillingAccount.ARMS_Debt_Management__c,
            Business_Profile__c = thisBillingAccount.ARMS_Business_Profile__c, 
            Record_Type__c = 'Master',
            Status__c = 'New',
        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
            Credit_Term_Reference__c = ConstantsSLB.getOther('ARMS_CrTrmRef'),
            Approved_Debt_Exposure_Amount__c = ConstantsSLB.getOther('ARMS_DbtExp')
        );
        if(thisBillingAccount.Zuora__BillToAddress1__c<>null){
            if(thisBillingAccount.Zuora__BillToAddress1__c.length() > 40){
                cusRec1.Address1__c = thisBillingAccount.Zuora__BillToAddress1__c.substring(0, 40);
            } else {
                cusRec1.Address1__c = thisBillingAccount.Zuora__BillToAddress1__c;
            }
        }
        if(thisBillingAccount.Zuora__BillToAddress2__c<>null){
            if(thisBillingAccount.Zuora__BillToAddress2__c.length() > 40){
                cusRec1.Address2__c = thisBillingAccount.Zuora__BillToAddress2__c.substring(0, 40);
            } else {
                cusRec1.Address2__c = thisBillingAccount.Zuora__BillToAddress2__c;
            }
        }
        if(cusRec1.Business_Profile__c == 'GOVT' && cusRec1.Debt_Mgt_Treatment__c == 'GOVT'){
            cusRec1.Credit_Term__c = '30';
        }
        if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'SUBH'){
            cusRec1.Credit_Term__c = '15';
        }
        if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'SUBL'){
            cusRec1.Credit_Term__c = '10';
        }
        if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'NORM'){
            cusRec1.Credit_Term__c = '0';
        }
            
            //END: D-995 12/05/14 Added by S.Puli
            
        BT_CO_ARMS_CreateCustAccountFile__c cusRec2 = new BT_CO_ARMS_CreateCustAccountFile__c(
            Customer_Name1__c = thisBillingAccount.Name,
            Customer_Status__c = ConstantsSLB.getOther('ARMS_CusSts'),
            Reference_Key__c = referenceKey,
            Unique_Key__c = uniqueKey,
            Business_Profile__c = thisBillingAccount.ARMS_Business_Profile__c, 
            Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
            Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt'),
            Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt'),
            Debt_Mgt_Treatment__c = thisBillingAccount.ARMS_Debt_Management__c,
            Create_Id__c = String.valueOf(thisBillingAccount.CreatedById).substring(0,15),
            Sub_Contact_Name__c = thisBillingAccount.Zuora__BillToName__c,
            Record_Type__c = 'Detail',
            Status__c = 'New'

        );
            
        cusToCreateBatchList.add(cusRec1);
        cusToInsertBatchList.add(cusRec1);
        cusToInsertBatchList.add(cusRec2);
        baCusIdSet.add(thisBillingAccount.Id);
            
         
        if(cusToCreateBatchList<>null && cusToCreateBatchList.size()>0){
        
            insert cusToInsertBatchList;
        
            for(BT_CO_ARMS_CreateCustAccountFile__c accBatch : cusToCreateBatchList){
                batchCustSet.add(accBatch.Id);
            }
        }
        //system.debug('>>masterToDetail_MAP add value>>'+masterToDetail_MAP);
       
        ARMS_CreateAndUpdate.createCustomerWebservice(batchCustSet, baCusIdSet);
           
   
    }
    
    //START UD-3294 26Nov2015 Added By C. Lin - Get Billing Account from field if page parameter has no billing account
    public void changeBillingAccount(){
        if(thisCase.Billing_Account_Name__c != null){
            billingaccountId = thisCase.Billing_Account_Name__c;
        }
        
        if(billingaccountId != null){
            //START D-3300 03-Aug-2015 Added by S.Puli-add Zuora__Zuora_Id__c
            thisBillingAccount = [SELECT Zuora__Account__r.Id, Zuora__Account__r.AccountNumber,
                                    Zuora__DefaultPaymentMethod__c, Name, Zuora__BillToAddress1__c, 
                                    Zuora__BillToAddress2__c, Zuora__BillToCity__c,Zuora__BillToName__c, 
                                    Zuora__BillToPostalCode__c, CreatedById, Other_PaymentMethod__c, 
                                    Create_ARMS_Customer_Account__c, ARMS_Business_Profile__c, ARMS_Account_Number__c, 
                                    Credit_Reference__c, Credit_Limit_Internal__c, Credit_Limit_External__c, Approved_Debt_Exposure_Amount__c, 
                                    ARMS_Debt_Management__c, GIRO_A_C__c, GIRO_Bank_Code__c, Business_Sector__c,Zuora__Zuora_Id__c, Credit_Term__c
                                    FROM Zuora__CustomerAccount__c WHERE Id = :billingaccountId];
            //END D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
            
            //START UD-0810 05-07-2015 Marvin G
            thisOrder = new Order__c();
            
            theseSubscriptions = [select id, Order_Number_1__c, Payment_Mode_1__c, Payment_Mode__c, Other_PaymentMethod_1__c, Other_PaymentMethod__c from Zuora__Subscription__c
                                    where Zuora__CustomerAccount__c = :billingaccountId];
            
            if (theseSubscriptions.size() > 0) {
                for(Zuora__Subscription__c eachSubs :theseSubscriptions ) {
                    orderIds.add(eachSubs.Order_Number_1__c);
                }
            }
                                   
            theseOrders = [Select id, Payment_Mode__c, Other_Payment_Mode__c from Order__c where id IN :orderIds];
            //END UD-0810 05-07-2015 Marvin G
            
            thisCase.AccountId = thisBillingAccount.Zuora__Account__r.Id;
            
            retrieveCreditBalance();
        }
    }
    //END UD-3294 26Nov2015 Added By C. Lin
    
    //START UD-3351 12/18/2015 Added by J.Sarion - Set Zuora URL for Zuora Hosted Page
    public string paymentGetway { get; set; }
    public string creditCardType { get; set; }
    
    public void retrieveSource() {    
        
        if(creditCardType == 'American Express') {
            paymentGetway = ConstantsSLB.getZuoraUrl('Amex');
        }
        else {
            paymentGetway = ConstantsSLB.getZuoraUrl('Default');
        }
   
    }
   //END UD-3351 12/18/2015 Added by J.Sarion - Set Zuora URL for Zuora Hosted Page
}