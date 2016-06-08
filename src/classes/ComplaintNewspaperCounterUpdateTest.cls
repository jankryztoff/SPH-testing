/**
 * Class Name: ComplaintNewspaperCounterUpdateTest
 * @author: April Veloso
 * Date: 04/07/2016
 * Requirement/Project Name: SPH
 * @description Test Class for ComplaintNewspaperCounterUpdate
 */
@isTest(seeAllData=True)
private class ComplaintNewspaperCounterUpdateTest{
    static testmethod void test_ComplaintNewspaperCounterUpdateTest(){

        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Migration',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
            );
    
            System.runAs(u){
                        
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                database.insert(acc);
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = '1234';
                postal.Street_Name__c = 'Street';
                postal.Building_Name__c = 'building';
                database.insert(postal);
                
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Country_Name__c = 'country';
                database.insert(country);
                
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Block_House_Number__c = '10';
                add.Postal_Code__c = postal.Id;
                add.Level_Number__c = '12';
                add.Unit_Number__c = '12';
                add.Country__c = country.Id;
                database.insert(add);
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = add.Id;
                con.AccountId = acc.Id;
                con.Recipient_Indicator__c = true;
                database.insert(con);
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                database.insert(billAcc);
                
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__CustomerAccount__c = billAcc.Id;
                subRecs.Zuora__SubscriptionStartDate__c = date.today();
                subRecs.Term_Length1__c = '1.1';
                subrecs.Recipient_Contact__c = con.id;
                database.insert(subRecs);
               
                List<Case> cs = TestDataFactory.createCase(2,'Complaint - Newspaper');                  
                database.insert(cs);                
                
                Case_Subscription__c caseSub = TestdataFactory.createCaseSubscription(1)[0];
                caseSub.Case__c = cs[0].id;
                caseSub.Subscription__c = subRecs.id;
                database.insert(caseSub);
                
                Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
                subVen.Recipient__c = con.id;
                database.insert(subVen);
                
                Case_Vendor_Subscription__c caseVenSub = TestdataFactory.createCaseVendorSub(1)[0];
                caseVenSub.Subscription_Vendor__c = subVen.id;
                caseVenSub.Case__c = cs[0].id;
                database.insert(caseVenSub);
                
                ComplaintNewspaperCounterUpdate run = new ComplaintNewspaperCounterUpdate();
                run.doUpdate();
           }
    }



}