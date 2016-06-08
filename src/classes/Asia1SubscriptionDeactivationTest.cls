//*********************************************************************************************
//
// Author: Von Carlo V. Villaruel
// Date: 1/19/2015
// Description: Test Class for Asia1SubscriptionDeactivationBatchable
//
//*********************************************************************************************

@isTest
Private Class Asia1SubscriptionDeactivationTest {

    Public Static testMethod void testAsia1SubscriptionDeactivation() {
    
    List<Account> lAccount = new List<Account>();
    
    Account acc1 = new Account(Name = 'Von Villaruel');
    acc1.Email__c = 'test@email.com';
    acc1.Date_of_Birth__c = System.Today();
    acc1.Remarks__c = 'Test';
    acc1.Remarks_2__c = 'Test';
    insert acc1;
    
    lAccount.add(acc1);
    
    Test.StartTest();    
        try{
        }catch(Exception e){
        }
    
    Test.StopTest();            

    }

}