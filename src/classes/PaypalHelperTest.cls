/**
* Class Name: PaypalHelperTest
* @author: Kirk Yngwie Enriquez
* Date: 7/8/2015
* @Description: This class is used for the code coverage of the PaypalHelper class.
*
*/

@isTest(seeAllData=true)
private class PaypalHelperTest{
    
    static testmethod void test_createBillingContact(){
    
        String retVal;
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
        
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id)ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='changeofpaymentcontroller@test.com'
            );
            
            System.runAS(testUser){
                Test.startTest();
                
                PaypalHelper.BillingContactWrapper contactWrap = new PaypalHelper.BillingContactWrapper();
                contactWrap.accountId = 'SampleID';
                contactWrap.firstName = 'First Name';
                contactWrap.lastName = 'Last Name';
                contactWrap.country = 'Country';
                
                retVal = PaypalHelper.createBillingContact(contactWrap);
                
                System.assertNotEquals(null, retVal);
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e){}  
    }
    
    static testmethod void test_createAccountContact(){
        
        String retVal;
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
        
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id)ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='changeofpaymentcontroller@test.com'
            );
            
            System.runAs(testUser){
                Test.startTest();
                
                PaypalHelper.BillingAccountWrapper accountWrap = new PaypalHelper.BillingAccountWrapper();
                accountWrap.name = 'Name';
                accountWrap.batch = 'Batch';
                accountWrap.billCycleday = 1;
                accountWrap.billingType = 'Billing Type';
                accountWrap.billToId = 'Bill To ID';
                accountWrap.soldToId = 'Sold To ID';
                
                retVal = PaypalHelper.createBillingAccount(accountWrap);
                
                System.assertNotEquals(null, retVal);
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e){}
    }
    
    static testmethod void test_createPaymentMethodId(){
        
        String retVal;
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
        
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id)ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='changeofpaymentcontroller@test.com'
            );
            
            System.runAs(testUser){
                Test.startTest();
                
                retVal = PaypalHelper.createPaymentMethodId('Sample BaID', 'Sample Paypal Email', 'Sample Accnt ID');
                
                System.assertNotEquals(null, retVal);
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e){}
    }
    
    static testmethod void test_updateBillingAccount(){
        
        String retVal;
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
        
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id)ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='changeofpaymentcontroller@test.com'
            );
            
            System.runAs(testUser){
                Test.startTest();
                
                //PaypalHelper.updateBillingAccount('Sample BaID', 'Sample Paypal Email');
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e){}
    }
    
    static testmethod void test_linkZAccountToSF(){
        
        String retVal;
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
        
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id)ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='changeofpaymentcontroller@test.com'
            );
            
            System.runAs(testUser){
                Test.startTest();
                
                PaypalHelper.linkZAccountToSF('Sample BaID', 'Sample Paypal Email');
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e){}
    }
    
    static testmethod void test_createPaypal(){
        
        String retVal;
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
        
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id)ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='changeofpaymentcontroller@test.com'
            );
            
            System.runAs(testUser){
                Test.startTest();
                
                PaypalHelper.BillingInformationWrapper infoWrap = new PaypalHelper.BillingInformationWrapper();
                infoWrap.paypalBAID = 'BaID';
                infoWrap.paypalEmail = 'paypal@sample.com';
                infoWrap.firstName = 'Juan';
                infoWrap.lastName = 'dela Cruz';
                infoWrap.country = 'Philippines';
                infoWrap.billingType = 'Prepaid';
                
                PaypalHelper.createPaypal(infoWrap);
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e){}
    }
}