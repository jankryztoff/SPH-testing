@isTest(seeAllData=true)

private class Refund_TriggerHandlerTest{
    static testMethod void testRefund_TriggerHandlerSingle(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Other_PaymentMethod__c = 'Invoice';
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Refund')[0];
        cas.Actual_Approver_Name__c = 'Approver Name';
        cas.Payment_Mode__c = 'Invoice';
        database.insert(cas);
    
        Zuora__Refund__c refund = TestDataFactory.createRefund(1)[0];
        refund.Zuora__BillingAccount__c = billAcc.Id;
        refund.Case__c = cas.Id;
        refund.Case_1__c = cas.Id;
        refund.Zuora__RefundDate__c = date.today()+5;
        refund.Zuora__Amount__c = 100;
        refund.Zuora__Account__c = acc.Id;
        
        test.startTest();
            database.insert(refund);
            system.assertEquals(refund.Case__c, cas.Id);
            
            refund.Name = 'New Name';
            database.update(refund);
            
            database.delete(refund);
        test.stopTest();
    }
    
    static testMethod void testRefund_TriggerHandlerBulk(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Other_PaymentMethod__c = 'Invoice';
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Refund')[0];
        cas.Actual_Approver_Name__c = 'Approver Name';
        cas.Payment_Mode__c = 'Invoice';
        database.insert(cas);
    
        List<Zuora__Refund__c> refund = TestDataFactory.createRefund(200);
        for(Zuora__Refund__c zr : refund){
            zr.Zuora__BillingAccount__c = billAcc.Id;
            zr.Case__c = cas.Id;
            zr.Case_1__c = cas.Id;
            zr.Zuora__RefundDate__c = date.today()+5;
            zr.Zuora__Amount__c = 100;
            zr.Zuora__Account__c = acc.Id;
        }
        
        test.startTest();
            database.insert(refund);
            
            refund[0].Name = 'New Name 1';
            refund[1].Name = 'New Name 2';
            database.update(refund);
            
            database.delete(refund);
        test.stopTest();
    }
}