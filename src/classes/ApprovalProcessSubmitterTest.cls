@isTest

public class ApprovalProcessSubmitterTest{

    static testMethod void ApprovalProcessSubTest() {
    
    
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
            
   
    ApprovalProcessSubmitter.submit(acc.id);
    
    }
    
  }