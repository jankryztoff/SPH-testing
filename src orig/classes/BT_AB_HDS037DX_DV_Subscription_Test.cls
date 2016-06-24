@isTest
private class BT_AB_HDS037DX_DV_Subscription_Test
{

  static testMethod void myUnitTest()
  {
        Singpost_Address__c postal = new Singpost_Address__c();
        postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c address = new Address__c();
        address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = postal.Id;
        insert address;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        insert pack;
        
        Account acct = new Account();
        acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acct.NRIC__c = 'T1234567R';
        insert acct;
        
        test.starttest();
        BT_AB_HDS037DX_DailyVendorSubscription tryBT = new  BT_AB_HDS037DX_DailyVendorSubscription();
        test.stoptest();
    
  }

}