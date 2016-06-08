@isTest
private class OrderTriggerHandlerTest {

	@testSetup
	static void setupData() {
		
		insert CustomSettingsDataFactory.createKey_Id();
		insert CustomSettingsDataFactory.createOther();
	}

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
 		string randomStr = ResponseUtility.generateExternalId();
 		string alias = randomStr.substring(0,6);
 		string userName = randomStr.substring(0,10);
		string email = username + '@test.com';
 		
        Id profileID = (Id) ConstantsSLB.getKeyId('Profile_System Administrator');
        User u = new User(
            Alias = alias,
            Email = email, 
            EmailEncodingKey =  'UTF-8',
            LastName = alias,
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = email
        );
        
       System.runAs(u) {
            
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            Address__c address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
            
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
            
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            insert con;

           Zuora__CustomerAccount__c billingAccount =  TestDataFactory.createBillingAccount(1)[0];
           billingAccount.Zuora__Account__c = acct.Id;
           billingAccount.Zuora__DefaultPaymentMethod__c = 'CreditCard';
           billingAccount.Zuora__PaymentMethodType__c = 'CreditCard';
           billingAccount.Billing_Type__c = 'Full Prepaid';
           insert billingAccount;
           
           Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
           pm.Zuora__BillingAccount__c = billingAccount.Id;
           pm.Zuora__Type__c = 'CreditCard';
           pm.Zuora__PaymentMethodStatus__c = 'Active';
           pm.Zuora__External_Id__c =  ResponseUtility.generateExternalId();
           insert pm;
            
           //create order
           Order__c order = TestDataFactory.createOrder(1)[0];
           order.Account__c = acct.Id;
           order.Recipient_Contact__c = con.Id;
           order.Payment_Mode__c = 'Credit Card';
           order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
           order.Billing_Account__c = billingAccount.Id;
           order.Billing_Type__c = 'Full Prepaid';
           insert order;
           
           order.Subject__c = 'test';
           update order;
       }        
    }
}