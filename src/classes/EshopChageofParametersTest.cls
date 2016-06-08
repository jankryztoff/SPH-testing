/**
@Author <Mariane Aquino>
@name <EshopChageofParametersTest>
@CreateDate <02/07/2015>
@Description <Test Class for EshopChageofParameters>
@Version <1.0>
@reference <>
*/
@isTest(SeeAllData = True)
private class EshopChageofParametersTest{//changed from global to private to cope up with novacop standards
    
    /**
    @Author <CV Manawatao>
    @name <ChangeofParametersRequest>
    @CreateDate <02/09/2015>
    @Description <recreated ChangeofParametersRequest of Base Class>
    @Version <1.0>
    @reference <>
    */
    public class ChangeofParametersRequest{
        String nric;
        String passport;
        String homePhone;
        String mobilePhone;
        String officePhone;
        String email;
        String secondarymail;
        String name;
        String salutation;
        String contactID;
        String billingIndicator;
        String recipientIndicator;
    }
    
    /**
    *  Test method 1
    * @name <testEshopChageofParameters>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void testEshopChageofParameters(){
         List<Account> tempAccntlist = TestDataFactory.createAccount(3, 'Direct Individual');
         //tempAccntlist[0].NRIC__c = 'T1234567R'; 
         //tempAccntlist[1].NRIC__c = ''; 
         //tempAccntlist[2].NRIC__c = Null;           
         insert tempAccntList;
     
         List<Contact> tempContactlist = testDataFactory.createContact(3);     
         insert tempContactList;
     
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EshopChangeofParametersService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        ChangeofParametersRequest eshReq = new ChangeofParametersRequest();
        eshReq.billingIndicator = 'Y';
        eshReq.recipientIndicator = 'N';
        EshopChageofParameters.ChangeofParametersRequest esh = new EshopChageofParameters.ChangeofParametersRequest();
        String jsonStr = JSON.serialize(eshReq);
        esh = (EshopChageofParameters.ChangeofParametersRequest)JSON.deserialize(jsonStr, EshopChageofParameters.ChangeofParametersRequest.class);
        EshopChageofParameters.ChangeofParametersResponse response = EshopChageofParameters.UpdateCustomerDetails(esh);    
        Test.stopTest();
        System.assertNotEquals(null, response);
    }
    
    /**
    *  Test method 2
    * @name <testEshopChageofParameters>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void testEshopChageofParameters2(){
         List<Account> tempAccntlist = TestDataFactory.createAccount(3, 'Direct Individual');
         insert tempAccntList;
     
         List<Contact> tempContactlist = testDataFactory.createContact(3);     
         insert tempContactList;
     
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EshopChangeofParametersService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        ChangeofParametersRequest eshReq = new ChangeofParametersRequest();
        eshReq.nric = '';
        eshReq.passport = '';
        eshReq.homephone = '';
        eshReq.mobilePhone = '';
        eshReq.officePhone = '';
        eshReq.email = '';
        eshReq.secondarymail = '';
        eshReq.Name = '';
        eshReq.Salutation = '';
        eshReq.contactId = '';
        eshReq.billingIndicator = '';
        eshReq.recipientIndicator = '';
        EshopChageofParameters.ChangeofParametersRequest esh = new EshopChageofParameters.ChangeofParametersRequest();
        String jsonStr = JSON.serialize(eshReq);
        esh = (EshopChageofParameters.ChangeofParametersRequest)JSON.deserialize(jsonStr, EshopChageofParameters.ChangeofParametersRequest.class);
        EshopChageofParameters.ChangeofParametersResponse response = EshopChageofParameters.UpdateCustomerDetails(esh); 
        Test.stopTest();
        System.assertNotEquals(null, response);      
    }
    
    /**
    *  Test method 3
    * @name <testEshopChageofParameters>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void testEshopChageofParameters3(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'S1234567D';
        acc.Passport__c = 'P11111';
        acc.Telephone_Residence__c = '122-1222';
        acc.Handphone_Number__c = '222111111';
        acc.Office_Number__c = '11244444';
        acc.Email__c = 'sample@sample.com';
        acc.Email_Secondary__c = 'sample2@sample.com';
        acc.Name = 'Account Name';
        insert acc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.FirstName = 'John';
        con.LastName = 'Doe';
        con.NRIC__c = acc.NRIC__c;
        con.Passport__c = 'P11111';
        con.HomePhone__c = '122-1222';
        con.Mobile_Number__c = '222111111';
        con.Office_Number__c = '11244444';
        con.Email__c = 'sample@sample.com';
        con.Email_Secondary__c = 'sample2@sample.com';
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Salutation = 'Mr';
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.FirstName = 'John';
        con1.LastName = 'Doe';
        con1.NRIC__c = acc.NRIC__c;
        con1.Passport__c = 'P11111';
        con1.HomePhone__c = '122-1222';
        con1.Mobile_Number__c = '222111111';
        con1.Office_Number__c = '11244444';
        con1.Email__c = 'sample@sample.com';
        con1.Email_Secondary__c = 'sample2@sample.com';
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        con1.Salutation = 'Mr';
        insert con1;

        Test.startTest();
        EshopChageofParameters.accName = [Select Account_Auto_Number__c From Account Where id=:acc.id].Account_Auto_Number__c;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EshopChangeofParametersService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        ChangeofParametersRequest eshReq = new ChangeofParametersRequest();
        eshReq.nric = acc.NRIC__c;
        eshReq.passport = acc.Passport__c;
        eshReq.homephone = acc.Handphone_Number__c;
        eshReq.mobilePhone = acc.Handphone_Number__c;
        eshReq.officePhone = acc.Office_number__c;
        eshReq.email = acc.Email__c;
        eshReq.secondarymail = acc.Email_Secondary__c;
        eshReq.Name = acc.Name;
        eshReq.Salutation = con.Salutation;    
        eshReq.contactId = con.Id;
        eshReq.billingIndicator = 'N';
        eshReq.recipientIndicator = 'Y';
        
        EshopChageofParameters.ChangeofParametersRequest esh = new EshopChageofParameters.ChangeofParametersRequest();
        String jsonStr = JSON.serialize(eshReq);
        esh = (EshopChageofParameters.ChangeofParametersRequest)JSON.deserialize(jsonStr, EshopChageofParameters.ChangeofParametersRequest.class);
        EshopChageofParameters.ChangeofParametersResponse response = EshopChageofParameters.UpdateCustomerDetails(esh); 
        Test.stopTest();
        System.assertNotEquals(null, response);    
    }
    
    /**
    *  Test method 4
    * @name <testEshopChageofParameters>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void testEshopChageofParameters4(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'S1234567D';
        acc.Passport__c = 'P11111';
        acc.Telephone_Residence__c = '122-1222';
        acc.Handphone_Number__c = '222111111';
        acc.Office_Number__c = '11244444';
        acc.Email__c = 'sample@sample.com';
        acc.Email_Secondary__c = 'sample2@sample.com';
        acc.Name = 'Account Name';
        insert acc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.FirstName = 'John';
        con.LastName = 'Doe';
        con.NRIC__c = acc.NRIC__c;
        con.Passport__c = 'P11111';
        con.HomePhone__c = '122-1222';
        con.Mobile_Number__c = '222111111';
        con.Office_Number__c = '11244444';
        con.Email__c = 'sample@sample.com';
        con.Email_Secondary__c = 'sample2@sample.com';
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Salutation = 'Mr';
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.FirstName = 'John';
        con1.LastName = 'Doe';
        con1.NRIC__c = acc.NRIC__c;
        con1.Passport__c = 'P11111';
        con1.HomePhone__c = '122-1222';
        con1.Mobile_Number__c = '222111111';
        con1.Office_Number__c = '11244444';
        con1.Email__c = 'sample@sample.com';
        con1.Email_Secondary__c = 'sample2@sample.com';
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        con1.Salutation = 'Mr';
        insert con1;

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EshopChangeofParametersService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        ChangeofParametersRequest eshReq = new ChangeofParametersRequest();
        eshReq.nric = acc.NRIC__c;
        eshReq.passport = acc.Passport__c;
        eshReq.homephone = acc.Handphone_Number__c;
        eshReq.mobilePhone = acc.Handphone_Number__c;
        eshReq.officePhone = acc.Office_number__c;
        eshReq.email = acc.Email__c;
        eshReq.secondarymail = acc.Email_Secondary__c;
        eshReq.Name = acc.Name;
        eshReq.Salutation = con.Salutation;    
        eshReq.contactId = con.Id;
        eshReq.billingIndicator = 'Y';
        eshReq.recipientIndicator = 'N';
        EshopChageofParameters.accName = [Select Account_Auto_Number__c From Account Where id=:acc.id].Account_Auto_Number__c;
        EshopChageofParameters.ChangeofParametersRequest esh = new EshopChageofParameters.ChangeofParametersRequest();
        String jsonStr = JSON.serialize(eshReq);
        esh = (EshopChageofParameters.ChangeofParametersRequest)JSON.deserialize(jsonStr, EshopChageofParameters.ChangeofParametersRequest.class);
        EshopChageofParameters.ChangeofParametersResponse response = EshopChageofParameters.UpdateCustomerDetails(esh); 
        Test.stopTest();
        System.assertNotEquals(null, response);
    }
    
    /**
    *  Test method 5
    * @name <testEshopChageofParameters>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void testEshopChageofParameters5(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'S1234567D';
        acc.Passport__c = 'P11111';
        acc.Telephone_Residence__c = '122-1222';
        acc.Handphone_Number__c = '222111111';
        acc.Office_Number__c = '11244444';
        acc.Email__c = 'sample@sample.com';
        acc.Email_Secondary__c = 'sample2@sample.com';
        acc.Name = 'Account Name';
        insert acc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.FirstName = 'John';
        con.LastName = 'Doe';
        con.NRIC__c = acc.NRIC__c;
        con.Passport__c = 'P11111';
        con.HomePhone__c = '122-1222';
        con.Mobile_Number__c = '222111111';
        con.Office_Number__c = '11244444';
        con.Email__c = 'sample@sample.com';
        con.Email_Secondary__c = 'sample2@sample.com';
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Salutation = 'Mr';
        con.Billing_Indicator__c = true;
        insert con;
        
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EshopChangeofParametersService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        ChangeofParametersRequest eshReq = new ChangeofParametersRequest();
        eshReq.nric = acc.NRIC__c;
        eshReq.passport = acc.Passport__c;
        eshReq.homephone = acc.Handphone_Number__c;
        eshReq.mobilePhone = acc.Handphone_Number__c;
        eshReq.officePhone = acc.Office_number__c;
        eshReq.email = acc.Email__c;
        eshReq.secondarymail = acc.Email_Secondary__c;
        eshReq.Name = acc.Name;
        eshReq.Salutation = con.Salutation;    
        eshReq.contactId = con.Id;
        eshReq.billingIndicator = 'Y';
        eshReq.recipientIndicator = 'N';
        EshopChageofParameters.accName = [Select Account_Auto_Number__c From Account Where id=:acc.id].Account_Auto_Number__c;
        EshopChageofParameters.ChangeofParametersRequest esh = new EshopChageofParameters.ChangeofParametersRequest();
        String jsonStr = JSON.serialize(eshReq);
        esh = (EshopChageofParameters.ChangeofParametersRequest)JSON.deserialize(jsonStr, EshopChageofParameters.ChangeofParametersRequest.class);
        EshopChageofParameters.ChangeofParametersResponse response = EshopChageofParameters.UpdateCustomerDetails(esh); 
        Test.stopTest();
        System.assertNotEquals(null, response);      
    }
 
    /**
    * Test method 6
    * @name <testEshopChageofParameters>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void testEshopChageofParameters6(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'S1234567D';
        acc.Passport__c = 'P11111';
        acc.Telephone_Residence__c = '122-1222';
        acc.Handphone_Number__c = '222111111';
        acc.Office_Number__c = '11244444';
        acc.Email__c = 'sample@sample.com';
        acc.Email_Secondary__c = 'sample2@sample.com';
        acc.Name = 'Account Name';
        insert acc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.FirstName = 'John';
                con.LastName = 'Doe';
                con.NRIC__c = acc.NRIC__c;
                con.Passport__c = 'P11111';
                con.HomePhone__c = '122-1222';
                con.Mobile_Number__c = '222111111';
                con.Office_Number__c = '11244444';
                con.Email__c = 'sample@sample.com';
                con.Email_Secondary__c = 'sample2@sample.com';
                con.AccountId = acc.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                con.Salutation = 'Mr';
                con.Billing_Indicator__c = true;
        insert con;
        
        Zuora__CustomerAccount__c zCust = TestDataFactory.createBillingAccount(1)[0];
        zCust.Zuora__Account__c = acc.id;
        zCust.Zuora__BillToId__c = con.id;
        zCust.Zuora__SoldToId__c = con.id;
        zCust.Billing_Contact__c = con.id;
        insert zCust;
        
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EshopChangeofParametersService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        ChangeofParametersRequest eshReq = new ChangeofParametersRequest();
        eshReq.nric = acc.NRIC__c;
        eshReq.passport = acc.Passport__c;
        eshReq.homephone = acc.Handphone_Number__c;
        eshReq.mobilePhone = acc.Handphone_Number__c;
        eshReq.officePhone = acc.Office_number__c;
        eshReq.email = acc.Email__c;
        eshReq.secondarymail = acc.Email_Secondary__c;
        eshReq.Name = acc.Name;
        eshReq.Salutation = con.Salutation;    
        eshReq.contactId = con.Id;
        eshReq.billingIndicator = 'Y';
        eshReq.recipientIndicator = 'N';
        EshopChageofParameters.accName = 'Account';//[Select Account_Auto_Number__c From Account Where id=:acc.id].Account_Auto_Number__c;
        EshopChageofParameters.ChangeofParametersRequest esh = new EshopChageofParameters.ChangeofParametersRequest();
        String jsonStr = JSON.serialize(eshReq);
        esh = (EshopChageofParameters.ChangeofParametersRequest)JSON.deserialize(jsonStr, EshopChageofParameters.ChangeofParametersRequest.class);
        EshopChageofParameters.ChangeofParametersResponse response = EshopChageofParameters.UpdateCustomerDetails(esh); 
        Test.stopTest();
        System.assertNotEquals(null, response);
    }

}