/* -------------------------------------------------------------------------------------------------------------------------------
   Name:            ARMSUpdateCustomerOnlineToSSTest.cls 
   Description:     This class is designed to be the Test Class for ARMSUpdateCustomerOnlineToSS.cls
   Date             Version         Author                             Summary of Changes 
  -----------      ---------    -----------------                  ---------------------------------------------------------------------------------------------------
  9 Feb 2015         1.0       Mayank Singh Rana                       Initial Release 
  
  Modified by: Ana Fe Dumangas
  Modified Date: 7/4/15
----------------------------------------------------------------------------------------------------------------------------*/

@isTest(SeeAllData=true)
private class ARMSUpdateCustomerOnlineToSSTest
{
    private static Account acc; 
    private static Zuora__CustomerAccount__c billAcc;
    
    /** This method creates the sample data to be used throughout the class **/
    private static void testData ()
    {
        /*TestDataFactory.createAccount(3, 'Mailing Agent');
        TestDataFactory.createBillingAccount(2);*/
        
        /* Test Account Data*/
            acc = new Account();
            acc.Name='Test Account';
            acc.Generate_Account_Number__c =  true;
            //acc.Account_Auto_Number__c = '';
        insert acc;
        system.debug('Account Auto Number-------------->'+acc.Account_Auto_Number__c);
        
        /*Test Singpost Address Data*/ //jurna added
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
            singAdd.Building_Name__c = 'Test Buildname';
            singAdd.Street_Name__c = 'Test st.';
            insert singAdd;
            
        /*Test City Data*/ //jurna added
        City__c city = TestDataFactory.createCity(1)[0];
            city.Flight_Number_1__c = 'testflight';
            insert city;        
        
        /*Test Country Data*/ //jurna added
        Country__c country = TestDataFactory.createCountry(1)[0];
            insert country;
        
        /*Test Address Data*/
        Address__c addr = new Address__c();
            addr.Name = 'New Address Record';
            addr.Legacy_Created_Date__c = '';
            addr.Legacy_Created_By__c   = '';
            addr.Legacy_Updated_Date__c = '';
            addr.Legacy_Updated_By__c   = '';
            addr.Address_1__c = 'Some address 12345';
            addr.Address_4__c = 'Address test';
            addr.Address_2__c = 'Address test2';
            addr.Address_3__c = 'Address test3';
            addr.Block_House_Number__c = '12';
            addr.Postal_Code__c = singAdd.Id;
            addr.City__c = city.Id;
            addr.Country__c = country.Id;
            addr.Level_Number__c = '12';
            addr.Unit_Number__c = 'test';
        insert addr;
        system.debug('Address inserted-------->'+addr.id);
        
        /*Test Contact Data*/
        Contact con = new contact();
            con.FirstName = 'Mayank';
            con.LastName  = 'Test';
            con.Accountid  = acc.id;
            con.Address__c = addr.id;
            con.HomePhone = '11213554';
        insert con;
        system.debug('Contact inserted-------->'+con.id);
        
        /*Test Billing Account Data*/
        billAcc = new Zuora__CustomerAccount__c();
            billAcc.Zuora__Account__c = acc.id;
            billAcc.Zuora__AccountNumber__c = '123456789';
            billAcc.Name = 'test Billing Account';
            billAcc.Billing_Contact__c = con.id;
            billAcc.ARMS_Customer_Number__c = '11CustmrNo';
            billAcc.Zuora__BillToId__c = 'Mayank Test';
        insert billAcc;
        
        List<Zuora__CustomerAccount__c> chckList = [select id, Zuora__Account__c, Name, ARMS_Customer_Number__c, Zuora__BillToId__c, Billing_Contact__r.Address__r.Address_1__c from Zuora__CustomerAccount__c where id =: billAcc.id];
        system.debug('Zuoar_CustomerAccount inserted-------->'+chckList);
        
        system.debug('Check for------------->'+chckList[0].Billing_Contact__r.Address__r.Address_1__c);
        
    }
    
     private static void testData2()
    {
        /*TestDataFactory.createAccount(3, 'Mailing Agent');
        TestDataFactory.createBillingAccount(2);*/
        
        /* Test Account Data*/
            acc = new Account();
            acc.Name='Test Account';
            acc.Generate_Account_Number__c =  true;
            //acc.Account_Auto_Number__c = '';
        insert acc;
        system.debug('Account Auto Number-------------->'+acc.Account_Auto_Number__c);
        
        /*Test Singpost Address Data*/ //jurna added
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
            singAdd.Building_Name__c = 'Test Buildname';
            singAdd.Street_Name__c = 'Test st.';
            insert singAdd;
            
        /*Test City Data*/ //jurna added
        City__c city = TestDataFactory.createCity(1)[0];
            city.Flight_Number_1__c = 'testflight';
            insert city;        
        
        /*Test Country Data*/ //jurna added
        Country__c country = TestDataFactory.createCountry(1)[0];
            insert country;
        
        /*Test Address Data*/
        Address__c addr = new Address__c();
            addr.Name = 'New Address Record';
            addr.Legacy_Created_Date__c = '';
            addr.Legacy_Created_By__c   = '';
            addr.Legacy_Updated_Date__c = '';
            addr.Legacy_Updated_By__c   = '';
            addr.Address_1__c = 'Some address 12345';
            addr.Address_4__c = 'Address test';
            addr.Address_2__c = 'Address test2';
            addr.Address_3__c = 'Address test3';
            addr.Block_House_Number__c = '12';
            addr.Postal_Code__c = singAdd.Id;
            addr.City__c = city.Id;
            addr.Country__c = country.Id;
            addr.Level_Number__c = '12';
            addr.Unit_Number__c = 'test';
        insert addr;
        system.debug('Address inserted-------->'+addr.id);
        
        /*Test Contact Data*/
        Contact con = new contact();
            con.FirstName = 'Mayank';
            con.LastName  = 'Test';
            con.Accountid  = acc.id;
            con.Address__c = addr.id;
            con.HomePhone = '11213554';
        insert con;
        system.debug('Contact inserted-------->'+con.id);
        
        /*Test Billing Account Data*/
        billAcc = new Zuora__CustomerAccount__c();
            billAcc.Zuora__Account__c = acc.id;
            billAcc.Zuora__AccountNumber__c = '123456789';
            billAcc.Name = 'test Billing Account';
            //billAcc.Billing_Contact__c = con.id;
            billAcc.ARMS_Customer_Number__c = '11CustmrNo';
            billAcc.Zuora__BillToId__c = 'Mayank Test';
        insert billAcc;
        
        //List<Zuora__CustomerAccount__c> chckList = [select id, Zuora__Account__c, Name, ARMS_Customer_Number__c, Zuora__BillToId__c, Billing_Contact__r.Address__r.Address_1__c from Zuora__CustomerAccount__c where id =: billAcc.id];
        //system.debug('Zuoar_CustomerAccount inserted-------->'+chckList);
        
        //system.debug('Check for------------->'+chckList[0].Billing_Contact__r.Address__r.Address_1__c);
        
    }
    
    /** Initial testmethod covers  **/
    private static testmethod void testMethod1()
    {
        testData();
        
        ARMSUpdateCustomerOnlineToSS instance = new ARMSUpdateCustomerOnlineToSS();
        
        ARMSUpdateCustomerOnlineToSS.ErrorResponseWrapper eRw = new ARMSUpdateCustomerOnlineToSS.ErrorResponseWrapper('Failed','200','Test Message');
        
        ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineRequest req = new ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineRequest(); 
        
        List<Account> accList = [select Name,Id,Generate_Account_Number__c,Account_Auto_Number__c from Account where id =: acc.Id];
        req.referenceKey = accList[0].Account_Auto_Number__c;
        req.customerName1 = billAcc.Zuora__BillToId__c;
        req.customerNumber = billAcc.ARMS_Customer_Number__c;
        req.idType = 'pass';
        req.systemID = 'test';
        req.Country = 'SG'; //jurna added
        req.block = '1';
        req.country = 'Malaysia';
        req.floorNo = '1';
        req.postalCode = '123';
        req.street = '12';
        req.unitNo = '2';
        
        ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineResponse res = new ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineResponse(req,eRw);
        
        //ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters vmPara = new ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters(req);
        //Boolean testvar = ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters(req);
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        //ARMSUpdateCustomerOnlineToSS.updateDetails updte =    new ARMSUpdateCustomerOnlineToSS.updateDetails(req);  
   
        system.debug('req--->'+req);
       
        String testString = ARMSUpdateCustomerOnlineToSS.fetchBillingAccountDetails(req);
        String testString1 = ARMSUpdateCustomerOnlineToSS.updateBillingContactaddressDetails(req);
        
        req.UniqueKey = accList[0].Account_Auto_Number__c;
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        
        req.systemID = 'SS';
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        
        req.systemID = '';
        req.customerNumber = '';
        req.ReferenceKey = '';
        req.UniqueKey = '';
        req.CustomerName1 = '';
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
       
    }
    
     /** Initial testmethod covers  **/
    private static testmethod void testMethod2()
    {
        testData();
        
        ARMSUpdateCustomerOnlineToSS instance = new ARMSUpdateCustomerOnlineToSS();
        
        ARMSUpdateCustomerOnlineToSS.ErrorResponseWrapper eRw = new ARMSUpdateCustomerOnlineToSS.ErrorResponseWrapper('Failed','200','Test Message');
        
        ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineRequest req = new ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineRequest(); 
        
        List<Account> accList = [select Name,Id,Generate_Account_Number__c,Account_Auto_Number__c from Account where id =: acc.Id];
        req.referenceKey = accList[0].Account_Auto_Number__c;
        req.customerName1 = billAcc.Zuora__BillToId__c;
        req.customerNumber = billAcc.ARMS_Customer_Number__c;
        req.idType = 'NRIC';
        req.systemID = 'test';
        req.Country = 'SG'; //jurna added
        //req.block = '1';
        //req.country = 'Malaysia';
        //req.floorNo = '1';
        //req.postalCode = '123';
        //req.street = '12';
        //req.unitNo = '2';
        
        ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineResponse res = new ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineResponse(req,eRw);
        
        //ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters vmPara = new ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters(req);
        //Boolean testvar = ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters(req);
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        //ARMSUpdateCustomerOnlineToSS.updateDetails updte =    new ARMSUpdateCustomerOnlineToSS.updateDetails(req);  
   
        system.debug('req--->'+req);
       
        String testString = ARMSUpdateCustomerOnlineToSS.fetchBillingAccountDetails(req);
        String testString1 = ARMSUpdateCustomerOnlineToSS.updateBillingContactaddressDetails(req);
        
        req.UniqueKey = accList[0].Account_Auto_Number__c;
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        
        req.systemID = 'SS';
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        
        req.systemID = '';
        req.customerNumber = '';
        req.ReferenceKey = '';
        req.UniqueKey = '';
        req.CustomerName1 = '';
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
       
    }
    //jurna
     /** Initial testmethod covers  **/
    private static testmethod void testMethod3()
    {
        testData2();
        
        ARMSUpdateCustomerOnlineToSS instance = new ARMSUpdateCustomerOnlineToSS();
        
        ARMSUpdateCustomerOnlineToSS.ErrorResponseWrapper eRw = new ARMSUpdateCustomerOnlineToSS.ErrorResponseWrapper('Failed','200','Test Message');
        
        ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineRequest req = new ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineRequest(); 
        
        List<Account> accList = [select Name,Id,Generate_Account_Number__c,Account_Auto_Number__c from Account where id =: acc.Id];
        req.referenceKey = accList[0].Account_Auto_Number__c;
        req.customerName1 = billAcc.Zuora__BillToId__c;
        req.customerNumber = billAcc.ARMS_Customer_Number__c;
        req.idType = 'NRIC';
        req.systemID = 'test';
        //req.Country = 'SG'; //jurna added
        //req.block = '1';
        //req.country = 'Malaysia';
        //req.floorNo = '1';
        //req.postalCode = '123';
        //req.street = '12';
        //req.unitNo = '2';
        
        ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineResponse res = new ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineResponse(req,eRw);
        
        //ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters vmPara = new ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters(req);
        //Boolean testvar = ARMSUpdateCustomerOnlineToSS.validateMandatoryParameters(req);
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        //ARMSUpdateCustomerOnlineToSS.updateDetails updte =    new ARMSUpdateCustomerOnlineToSS.updateDetails(req);  
   
        system.debug('req--->'+req);
       
        String testString = ARMSUpdateCustomerOnlineToSS.fetchBillingAccountDetails(req);
        String testString1 = ARMSUpdateCustomerOnlineToSS.updateBillingContactaddressDetails(req);
        
        req.UniqueKey = accList[0].Account_Auto_Number__c;
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        
        req.systemID = 'SS';
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
        
        req.systemID = '';
        req.customerNumber = '';
        req.ReferenceKey = '';
        req.UniqueKey = '';
        req.CustomerName1 = '';
        res= ARMSUpdateCustomerOnlineToSS.updateDetails(req);
       
    }
}