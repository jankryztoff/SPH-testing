/*
* Class Name: <ZuoraBillingAccountTest>
* @author: <Ana Fe Dumangas>
* Date: <7/14/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for ZuoraBillingAccount>
**/

@isTest(SeeAllData=True)
private class ZuoraBillingAccountTest{
    static testMethod void testCreateBillingAccountInZuora(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        database.insert(billAcc);
        
        List <Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;        
        }
        database.insert(subs);
        
        test.startTest();
            ZuoraBillingAccount bill = new ZuoraBillingAccount();
            bill.CreateBAInZuoraInvoice(billAcc, '123456');
            bill.createContactBilling(billAcc.Id, con.Id);
            bill.activateAccount(billAcc);
            bill.createAmendments(subs, billAcc.Id, billAcc.Id);
        test.stopTest();
    }
}