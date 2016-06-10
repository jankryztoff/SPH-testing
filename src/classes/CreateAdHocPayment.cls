public class CreateAdHocPayment{

    private final Zuora__CustomerAccount__c acct;
    public String paymentMethodId {get; set;} 
    public Decimal Amount {get;set;}
    public String paymentMethod {get;set;}
    public String ChequeNo {get;set;} 
    public Date ChequeDate {get;set;}
    public String Bank {get;set;}      
    Public Date PaymentDate {get;set;}
    Public String month {get;set;}
    Public String day {get;set;}
    Public String Type {get;set;}
    Public String myDate {get; set;}
    Public String chqDate {get; set;} //START-END  UD-3284 11/24/2015 K. Tan
    String cashId;
    String checkId;
    Zuora__CustomerAccount__c currentRecord;
    String billAcctId = ApexPages.currentPage().getParameters().get('Id'); 

    public CreateAdHocPayment(ApexPages.StandardController Controller) {      
        this.acct = (Zuora__CustomerAccount__c)Controller.getRecord();
        currentRecord = [SELECT Zuora__External_Id__c, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Id = :this.acct.Id];        
        //submit();
        //CreateAdHocPayment(); --- <D-0798 KL 11/28: Not to display the Invalid Amount Error Message> 
    }        


    public List<SelectOption> getPaymentMode() {
        List<SelectOption> PaymentModeOptions = new List<SelectOption>();
        PaymentModeOptions.add(new SelectOption('Cash', 'Cash'));
        PaymentModeOptions.add(new SelectOption('Cheque','Cheque'));
        return PaymentModeOptions;
        }
      
        
    public pageReference CreateAdHocPayment(){    
        Zuora.zApi zApiInstance = new Zuora.zApi();
        cashId = ConstantsSLB.getKeyId('PaymentMethodId_Cash');
        checkId = ConstantsSLB.getKeyId('PaymentMethodId_Check');
        DateTime dT = PaymentDate;
        DateTime cT = ChequeDate; //START-END  UD-3284 11/24/2015 K. Tan
        month = '';
        day = '';             
        //Start UD-3831 18-Mar-2016 Added By S.Puli
        cT = acct.Cheque_Date__c;
        dT = acct.Customer_Create_Date__c;
        //End UD-3831
        if (Amount == null || Amount == 0){                  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,ConstantsSLB.geterrorMessage('Invalid_Amount')));
            return null;
        }
        //START  UD-3284 11/24/2015 K. Tan      
        if (cT != null && paymentMethod == 'Cheque') {                
            if (String.ValueOf(cT.month()).length() == 1){
                month = '0'+cT.month();
            }
            else {
                month = String.valueOf(cT.month());
            }
            if (String.ValueOf(cT.day()).length() == 1){
                day = '0'+ cT.day();
            }
            else {
                day = String.valueOf(cT.day());
            }
            chqDate = cT.year() + '-' + month + '-' + day;   
        }     
        //END  UD-3284 11/24/2015 K. Tan        
        
        
               
        if (dT != null && dT <= date.today()) {//Start/End UD-3831 Added by S.Puli                
            if (String.ValueOf(dT.month()).length() == 1){
                month = '0'+dT.month();
            }
            else {
                month = String.valueOf(dT.month());
            }
            if (String.ValueOf(dT.day()).length() == 1){
                day = '0'+ dT.day();
            }
            else {
                day = String.valueOf(dT.day());
            }
            myDate = dT.year() + '-' + month + '-' + day;                          
        }                
        else{           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.geterrorMessage('InvalidPaymentDate')));
            return null;
        }  
        //Payment Method Id assignment based on Payment Mode (External)
        if (paymentMethod == 'Cash'){
            paymentMethodId = cashId;          
        }
        else if (paymentMethod == 'Cheque'){
            paymentMethodId = checkId;
        } 
      
        //Validate Cheque No.
        //START: D-1874 / 2/10/2015 /K.Tan / Deleted scenario for Validation         
        /*if(paymentMethod == 'Cash' && ChequeNo != '') {
            //system.assert(false);                   
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.geterrorMessage('ChequeCaseValidation'));           
            ApexPages.addMessage(errormsg);
            return null;            
        }*/
        //END: D-1874 / 2/10/2015 /K.Tan / Deleted scenario for Validation       
                     
        if(paymentMethod == 'Cheque' && ChequeNo == '' ) {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.geterrorMessage('ChequeCaseValidation'));           
            ApexPages.addMessage(errormsg);
            return null; 
        }
        
        //Create Payment in Zuora
        try{
        //START D-3268 Modified By C.I.Salas - Test Coverage
        if (!Test.isRunningTest()) {
            zApiInstance.zlogin();
        }
        //END D-3268 Modified By C.I.Salas - Test Coverage
        Zuora.zObject p = new Zuora.zObject('Payment');    
        p.setValue('AccountId', currentRecord.Zuora__Zuora_Id__c);
        p.setValue('Amount', Amount);
        p.setValue('AppliedCreditBalanceAmount', Amount);
        p.setValue('Type', 'External');
        p.setValue('Status', 'Processed');  
        p.setValue('EffectiveDate', myDate+'T00:00:00');
        p.setValue('PaymentMethodId', paymentMethodId);
        //START UD-2263 11/17/2015 K. Tan
        p.setValue('AdHocCreatedBy__c', UserInfo.getName());
        //END UD-2263 11/17/2015 K. Tan
        //START  UD-3284 11/24/2015 K. Tan
        if(paymentMethod == 'Cheque'){
            p.setValue('Bank__c', Bank);
            p.setValue('Cheque_Date__c', chqDate);
            p.setValue('Cheque_No__c', ChequeNo);
        }
        //END UD-3284 11/24/2015 K. Tan                  
        
        List<Zuora.zObject> objs = new List<Zuora.zObject> {p}; 
        List<Zuora.zApi.SaveResult> results = zApiInstance.zcreate(objs);               
        for (Zuora.zApi.SaveResult result : results) {
                if (result.success) {
                    //get the newly created id
                    String createdId = result.Id;                                   
                }               
                else {
                    //failure
                    Zuora.zObject[] errors = result.errors;
                    for (Zuora.zObject error : errors) {
                        String errorCode = (String)error.getValue('Code');
                        String message = (String)error.getValue('Message'); 
                        String test = errorCode + ' ' + message;
                        system.debug('error' + test);                       
                    }
                }
            }
        }  
        catch (Zuora.zRemoteException ex){        
            if ('INVALID_FIELD' == ex.code){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.code + ex.message));
            }    
        } 
        PageReference pageRef = new PageReference('/' + billAcctId);
        pageRef.setRedirect(true);
        return pageRef;
    }   
}