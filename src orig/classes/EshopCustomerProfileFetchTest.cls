/**
* Class Name: <EshopCustomerProfileFetchTest>
* @author: <Mark Gatdula>
* Date: <02/07/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for EshopCustomerProfileFetch>
*/

@isTest
public class EshopCustomerProfileFetchTest {
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        //insert CustomSettingsDataFactory.createOther(); 
    }  
        
    static testmethod void EshopCustomerProfileFetchUnitTest()
    {
        
        Integer count = 0;
        /*this portion added by Mayank Singh Rana*/
        /*Sample Account record*/
        //Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Account acc = new Account();
            acc.Name = 'Test Account';
            acc.NRIC__c = 'T1234567R';
            acc.Active__c = true;
            acc.Generate_Account_Number__c = true;
        insert acc;
        
        //START EGC 4/9/2016
        //Get a Country. Assuming Country__c records are funtional data.
        //Country__c country = [SELECT Id FROM Country__c LIMIT 1];
        //END EGC 4/9/2016
        
        List<Zone__c> zoneList = TestDataFactory.createZone(1);
        count = 0;
        for (Zone__c obj : zoneList) {
            obj.Name = ''+count;
            count++;
        }
        insert zoneList;
        
        List<Country__c> countryList = TestDataFactory.createCountry(1);
        count = 0;
        for (Country__c obj : countryList) {
            obj.Zone__c = zoneList[count].id;
            count++;
        }
        insert countryList;
        
        
        /*Sample address records*/
        Address__c addr = new Address__c();
            addr.Name = 'Test Address';
            addr.Legacy_Created_By__c  = '';
            addr.Legacy_Created_Date__c= '';
            addr.Legacy_Updated_By__c  = '';
            addr.Legacy_Updated_Date__c= '';
            addr.Country__c = countryList[0].Id; //EGC 4/9/2016 added
        insert addr;
        
        /*Sample contact record*/
        Contact con = new Contact();
            con.FirstName = 'Test';
            con.Lastname  = 'Contact1';
            con.AccountId = acc.id; 
            con.Address__c = addr.id;
            con.HomePhone__c = '0213132';
            con.recipient_indicator__c = true;
            con.billing_indicator__c  = true;          
        insert con;
        
        /*creating sample records Billing Account*/
        Zuora__CustomerAccount__c zoraCustAcnt = new Zuora__CustomerAccount__c();
            zoraCustAcnt.Name = 'Test Billing Account';
            zoraCustAcnt.Zuora__Account__c = acc.id;
            zoraCustAcnt.Billing_Contact__c = con.id;
            zoraCustAcnt.Zuora__Status__c = 'Active';
        insert zoraCustAcnt;
        
        Test.startTest();  
            EshopCustomerProfileFetch eProfFetch = new EshopCustomerProfileFetch();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/CustomerProfileFetchService';  
            req.httpMethod = 'POST';
            
            RestContext.request = req;
            RestContext.response= res;
            
            EshopCustomerProfileFetch.EshopCustomerProfileFetchRequest eshopReq = new EshopCustomerProfileFetch.EshopCustomerProfileFetchRequest();
            String accountNum = [Select Account_Auto_Number__c From Account Where Account_Auto_Number__c != NULL and Id =: acc.Id limit 1].Account_Auto_Number__c;
            eshopReq.getSubscriberId();
            eshopReq.setSubscriberId(accountNum);
            EshopCustomerProfileFetch.EshopCustomerProfileFetchResponse response = EshopCustomerProfileFetch.FetchCustomerDetails(eshopReq);
            response = EshopCustomerProfileFetch.FetchCustomerDetails(eshopReq);  
        Test.stopTest();
    }
    
    static testmethod void EshopCustomerProfileFetchUnitTest2()
    {
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        
        Test.startTest(); 
            EshopCustomerProfileFetch eProfFetch = new EshopCustomerProfileFetch();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/CustomerProfileFetchService';  
            req.httpMethod = 'POST';
            
            RestContext.request = req;
            RestContext.response= res;
            
            EshopCustomerProfileFetch.EshopCustomerProfileFetchRequest eshopReq = new EshopCustomerProfileFetch.EshopCustomerProfileFetchRequest();
            String accountNum = acc.Account_Auto_Number__c;
            eshopReq.setSubscriberId(accountNum);
            EshopCustomerProfileFetch.EshopCustomerProfileFetchResponse response = EshopCustomerProfileFetch.FetchCustomerDetails(eshopReq);
            response = EshopCustomerProfileFetch.FetchCustomerDetails(eshopReq);  
        Test.stopTest();
    }
    
    
}