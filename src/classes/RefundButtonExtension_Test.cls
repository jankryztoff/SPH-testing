@isTest(SeeAllData=true)
private class RefundButtonExtension_Test{

    public static void testRefundButtonExtension(){
        
        Test.setMock(WebServiceMock.class, new zApiTest());
               
        PageReference pgRef = Page.RefundButton;
        Test.setCurrentPage(pgRef);  
        
        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        insert acct;
        
        Case c = TestDataFactory.createCase(1,'Refund')[0];
        System.debug('Record Type ID:' + c.RecordTypeId);
        //c.RecordTypeId = rt.Id; 
        c.AccountId = acct.Id;
        c.Payment_Mode__c = 'Cheque';
        insert c;
        
        Zuora__CustomerAccount__c billaccount = TestDataFactory.createBillingAccount(1)[0];
        billaccount.Zuora__Account__c = acct.id;
        insert billaccount;
        
        Zuora__PaymentMethod__c zpmethod = TestDataFactory.createPaymentMethod(1)[0];
        zpmethod.Zuora__BillingAccount__c = billaccount.id;
        zpmethod.Zuora__Type__c = 'Check';
        insert zpmethod;
        
        Zuora__CustomerAccount__c zbaccount = TestDataFactory.createBillingAccount(1)[0];
        zbaccount.Zuora__Account__c = acct.id;
        zbaccount.Zuora__Default_Payment_Method__c = zpmethod.id;
        zbaccount.Refund_Amount__c = 1000;
        zbaccount.Zuora__External_Id__c = 'Test Account 123';
        insert zbaccount;
        
                    

        
        /* 
        RecordType rt = 'SELECT id, Name FROM RecordType WHERE SobjectType= 'Case' AND Name= 'Complaint - Digital' LIMIT 1';
        insert rt;
        */
        
        /* 
        List<RecordType> rt = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name=: recType LIMIT 1];
        */
        
        /*
        RecordType rt = new RecordType(Name = 'Complaint - Digital');
        insert rt;
        */
        
        
    
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(c); 
        RefundButtonExtension rbe = new RefundButtonExtension(stdCtrlr);
        rbe.activateRefund();
        
    }//END testMethod testRefundButtonExtension()

}//END RefundButtonExtension_Test