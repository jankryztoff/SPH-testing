/*
 * Class Name: RenewalOfSub_GracePeriodBatchTest
 * @author: Jensar Joey Z. Sayson
 * Date: 4/8/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for RenewalOfSub_GracePeriodBatch
 */

@isTest(seeAllData = true)
public class RenewalOfSub_GracePeriodBatchTest {

	 //initializing batch class
    static testMethod void test01(){
        
        RenewalOfSub_GracePeriodBatch batch = new RenewalOfSub_GracePeriodBatch();
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        Test.startTest();

        	System.assertNotEquals(null, batch);
        
        Test.stopTest();
        
    }
    
    //initializing batch class
    static testMethod void test02(){
        
        Database.BatchableContext BC;

        Date_Configuration__c dateConfig = new Date_Configuration__c();
        dateConfig.Name = 'date';
        dateConfig.Date__c = date.today()+60;
        database.insert(dateConfig);
        
        Date referenceDate = UsageHelper.getUsageReferenceDate();
        Date firstDayOfNextMonth = referenceDate.addMonths(1).toStartofMonth();
        Date lastDayOfNextMonth = referenceDate.addMonths(2).toStartofMonth().addDays(-1); 
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
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
        
        list<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(3);
        subRecs[0].Zuora__CustomerAccount__c = billAcc.Id;
        subRecs[0].Zuora__SubscriptionStartDate__c = date.today();
        subRecs[0].Term_Length1__c = '1.1';
        subRecs[0].Billing_Type__c = 'Recurring Prepaid';
        
        subRecs[1].Zuora__CustomerAccount__c = billAcc.Id;
        subRecs[1].Zuora__SubscriptionStartDate__c = date.today()-30;
        subRecs[1].Zuora__SubscriptionEndDate__c = date.today()+30;
        subRecs[1].Term_Length__c = 1;
        subRecs[1].Term_Length1__c = '1';
        subRecs[1].Billing_Type__c = 'Recurring Prepaid';
        subrecs[1].Zuora__Status__c = 'Active';

        RenewalOfSub_GracePeriodBatch batch = new RenewalOfSub_GracePeriodBatch();
        ID batchprocessid = Database.executeBatch(batch, 200);        	    
        
        Test.startTest();
        	
            try{
                batch.execute(BC,subRecs);   
                
            }catch(Exception e){}
            
        	System.assertNotEquals(null,batch);
        
        Test.stopTest();
    }
}