/**
@Author Val Lu
@name CAM_CreateModifyContactAddressCont
@CreateDate 02/17/2015
@Description To test CAM_CreateModifyContactAddressCont
@Version 1.0

*/


@isTest(seeAllData = true)
public class CAM_CreateModifyContactAddressContTest {


    static User cso;
    static Account acc;
    static List<Address__c> addressList;
    static SingPost_Address__c singPost;
    static Country__c country;
    static City__c city;
    static Contact con;
    static Contact con1; 
    /**
    *  This method will test the instantiation of the controller and other mnethods
    *  @name CAM_CreateModifyContactAddressControllerTest
    *  @param none
    *  @return none
    *  @throws exception-none
    */    
    static testMethod void CAM_CreateModifyContactAddressControllerTest()
    {
    
        prepareTestUsers();
        System.runAs(cso) { 
            Test.startTest();
            
            
            prepareTestData();
            
       
            // RecordType = Billing
            PageReference pRef1 = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef1);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType', 'Billing');
            ApexPages.StandardController stdCtrlr1 = new ApexPages.StandardController(new Contact());
            //system.assertequals(null, stdCtrlr1);
            CAM_CreateModifyContactAddressController controller1 = new CAM_CreateModifyContactAddressController(stdCtrlr1);
            
            // RecordType = Id
            PageReference pRef2 = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef2);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType', con.id);
            ApexPages.StandardController stdCtrlr2 = new ApexPages.StandardController(new Contact());
            CAM_CreateModifyContactAddressController controller2 = new CAM_CreateModifyContactAddressController(stdCtrlr2);
            
            PageReference pRef3 = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef3);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType', con.id);
            ApexPages.StandardController stdCtrlr3 = new ApexPages.StandardController(new Contact());
            CAM_CreateModifyContactAddressController controller3 = new CAM_CreateModifyContactAddressController(stdCtrlr3);
            
            // fetchPackingGrpDetails
          //  controller3.stagedAddress = addressRec; //joy
            controller3.fetchPackingGrpDetails();
            
            
            // validate contact
            controller3.thisContact = con1;
            controller3.billingIndicator = true;
            controller3.recipientIndicator = false;
            controller3.validateContact();
            
            PageReference pRef4 = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef4);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType', con1.id);
            ApexPages.StandardController stdCtrlr4 = new ApexPages.StandardController(new Contact());
            CAM_CreateModifyContactAddressController controller4 = new CAM_CreateModifyContactAddressController(stdCtrlr4);
            
            // validate contact
            controller4.thisContact = con;
            controller4.billingIndicator = true;
            controller4.recipientIndicator = true;
            controller4.validateContact();
            
            
            // Acount = null
            PageReference pRef5 = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef5);
            ApexPages.currentPage().getParameters().put('accountId', null);
            ApexPages.currentPage().getParameters().put('RecordType', con.id);
            ApexPages.StandardController stdCtrlr5 = new ApexPages.StandardController(new Contact());
            CAM_CreateModifyContactAddressController controller5 = new CAM_CreateModifyContactAddressController(stdCtrlr5);
            
            Test.stopTest();
        }
    }
    
    /**
    *  This method will test the local address
    *  @name testLocalAddress
    *  @param none
    *  @return none
    *  @throws exception-none
    */       
    static testMethod void testLocalAddress() {
        prepareTestUsers();
        System.runAs(cso) {
            prepareTestData();
            
            Test.startTest();
            
            //initialize page and controllers
            PageReference pRef = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Contact());
            CAM_CreateModifyContactAddressController controller = new CAM_CreateModifyContactAddressController(stdCtrlr);
            
            //assert number of available options for address types : 5
            System.assertEquals(controller.getAddressTypeOptions().size(), 5);
            
            //test search functionality
            controller.stagedAddress.Postal_Code__c = singPost.Id;
            controller.search();
            //System.assertEquals(10, controller.add.size());
            
            //test city/country code fubnctionality
            controller.stagedAddress.City__c = city.Id;
            controller.fetchCityName();
            System.assertEquals(city.City_Name__c, controller.cityName);
            controller.StagedAddress.City__c = null;
            controller.fetchCityName();
            System.assertEquals('', controller.cityName);
            
            controller.selectedCountry = country.Id;
            controller.fetchCountryCode();
            system.assertEquals(country.Name, controller.countryCode);
            
            //get address record
            controller.addressId = addressList[0].Id;
            controller.selectAddressRecord();
            System.assertEquals(addressList[0].Id, controller.thisContact.Address__c);
            
            //clear address record
            controller.clearAddressDetails();
            System.assertEquals(NULL, controller.thisContact.Address__c);
            
            controller.clearContactAddress();
            System.assertEquals(NULL, controller.thisContact.Address__c);
            
            Test.stopTest();
        } 
    }

    /**
    *  This method will test the internal contact 
    *  @name testInternalContact
    *  @param none
    *  @return none
    *  @throws exception-none
    */     
    static testMethod void testInternalContact() {
        prepareTestUsers();
        
        System.runAs(cso) {
            prepareTestData();
            
            Test.startTest();
            
            //initialize page and controllers
            PageReference pRef = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Contact());
            CAM_CreateModifyContactAddressController controller = new CAM_CreateModifyContactAddressController(stdCtrlr);
            
            //assert number of available options for address types : 5
            System.assertEquals(controller.getAddressTypeOptions().size(), 5);
            
            //set contact details
            controller.thisContact.AccountId = acc.Id;
            controller.thisContact.LastName = 'test last name';
            controller.thisContact.FirstName = 'test first name';
            controller.thisContact.HomePhone__c = '1234567';
            
            //set indicator flags -- tick both so we will create 2 contact records
            controller.billingIndicator = TRUE;
            controller.recipientIndicator = TRUE;
            
            //invoke save action
            controller.saveRecord();
            
            //assert field values for inserted records
            Boolean isBillingContactCreated = FALSE;
            Boolean isRecipientCOntactCreated = FALSE;
            //[SELECT Id, LastName, FirstName, RecordType.Name, Address__r.LocationCode__c, Address__r.Company_Code__c, Address__r.Division_Code__c, Address__r.Department__c, Address__r.Section_Code__c FROM Contact WHERE AccountId = :acc.Id]) {
            for(Contact cntct : [SELECT Id, LastName, FirstName, Billing_Indicator__C, Recipient_Indicator__C/*, Address__r.LocationCode__c,*/ /*Address__r.Company_Code__c,*/ /*Address__r.Division_Code__c,*/ /*Address__r.Department__c,*/ /*Address__r.Section_Code__c*/ FROM Contact WHERE AccountId = :acc.Id]) {                            
                System.assertEquals('test last name', cntct.LastName);
                System.assertEquals('test first name', cntct.FirstName);
                
                if(cntct.Billing_Indicator__C) {
                    isBillingContactCreated = TRUE;
                }
                if(cntct.Recipient_Indicator__C) {
                    isRecipientCOntactCreated = TRUE;
                }
            }
            //assert if billing and recipient contacts are created
            System.assert(isBillingContactCreated);
            System.assert(isRecipientContactCreated);
            
            Test.stopTest();
        } 
    }

    /**
    *  This method will test the error handling 
    *  @name testErrorHandling
    *  @param none
    *  @return none
    *  @throws exception-none
    */     
    static testMethod void testErrorHandling() {
        prepareTestUsers();
        
        System.runAs(cso) {
            prepareTestData();
            
            
            
            Test.startTest();
            
            //initialize page and controllers
            PageReference pRef = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Contact());
            CAM_CreateModifyContactAddressController controller = new CAM_CreateModifyContactAddressController(stdCtrlr);
            
            //assert number of available options for address types : 5
            System.assertEquals(controller.getAddressTypeOptions().size(), 5);
            
            controller.clearAddressDetails2();
            controller.fetchPackingGrpDetails(); //
            //assert error on billing/recipient indicator
            controller.billingIndicator = FALSE;
            controller.recipientIndicator = FALSE;
            controller.saveRecord();
            System.AssertEquals('Please tick Billing Indicator, Recipient Indicator or both.', ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary());
            
            //assert error on null adress type
            controller.recipientContactId = 'test';
            controller.searchstring = 'test2';
            controller.postalId = 'test3';
            controller.airlineNumber = 'test4';
            controller.isInIframe = true;
            controller.billingIndicator = TRUE;
            controller.recipientIndicator = TRUE;
            controller.AddressType = '';
            controller.saveRecord();
            System.AssertEquals('Please select an address type!', ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary());
            
            //assert error on null postal code for Local address type
            controller.checked = TRUE;
            controller.AddressType = 'Local';
            controller.saveRecord();
            System.AssertEquals('Please select a Postal Code.', ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary());
            
            //assert error on invalid unit number
            controller.stagedAddress.Postal_Code__c = singPost.Id;
            controller.stagedAddress.Unit_Number__c = '1';
            controller.saveRecord();
            System.AssertEquals('Unit must be at least two characters.', ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary());
            
            //assert error on invalid level number
            controller.stagedAddress.Postal_Code__c = singPost.Id;
            controller.stagedAddress.Unit_Number__c = '11';
            controller.stagedAddress.Level_Number__c = '1';
            controller.saveRecord();
            System.AssertEquals('Level must be at least two characters.', ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary());
            
            //assert error on null address Id
            controller.checked = FALSE;
            controller.stagedAddress.Level_Number__c = '11';
            controller.saveRecord();
            System.AssertEquals('Please select an existing Address record or create a New one.', ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary());
            
            //assert error on attempt to insert existing address
            controller.checked = TRUE;
            controller.stagedAddress.Postal_Code__c = singPost.Id;
            controller.saveRecord();
            System.assert(ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary().contains('Existing Address record found:'));            
            
            //assert queryexception on save record
            
            
            //assert DML exception on saverecord method
            controller.thisContact.LastName = 'test';
            controller.stagedAddress.Unit_Number__c = '51';
            controller.saveRecord();
            System.assertEquals('At least 1 phone number should be entered (either home phone, mobile, other phone or office number).', ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary());
            
            PageReference pRef_2 = Page.CreateModifyContactAddress;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('accountId', '1234567890');
            ApexPages.StandardController stdCtrlr_2 = new ApexPages.StandardController(new Contact());
            CAM_CreateModifyContactAddressController controller_2 = new CAM_CreateModifyContactAddressController(stdCtrlr_2);
            System.assert(ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary().contains('Error trying to fetch Account details'));
            
            
            
            
            Test.stopTest();
        } 
    }

    /**
    *  This method will create the test user data 
    *  @name prepareTestusers
    *  @param none
    *  @return none
    *  @throws exception- none
    */     
    static void prepareTestusers() {
    
    
        cso = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
    }

    /**
    *  This method will create the test data 
    *  @name prepareTestdata
    *  @param none
    *  @return none
    *  @throws exception-none
    */     
    static void prepareTestdata() {
    
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        singPost = TestDataFactory.createSingpostAddress(1)[0];
        singPost.Name = 'SPostal';
        singPost.House_Block_Number__c = 'TEST';
        singPost.Address_Type__c = 'A';
        insert singPost;
        objectMap.put('Singpost_Address__c', singPost);
        
        country = TestDataFactory.createCountry(1)[0];
        country.Name = 'test';
        country.Country_Name__c = 'Country test';
        insert country;
        objectMap.put('Country__c', country);
        
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Office_Extension__c = 'test'; //
        insert acc;
        objectMap.put('Account', acc);
        
        Packing_Grp__c pg = new Packing_Grp__c();
        pg.Packing_Code__c = 'MFA';
        insert pg;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Packing_Code__c = pg.id; //
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = singPost.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        Id addRecId = [Select Id From RecordType Where SObjectType='Address__c' And Name = 'Overseas' LIMIT 1].Id;
        addressRec.RecordTypeId = addRecId;
        insert addressRec;
        objectMap.put('Address__c', addressRec); 
        
        Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = recordType;
        con.LastName='test last name';
        con.FirstName='test first name';
        con.Email__c = 'test@test.com';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        objectMap.put('Recipient Contact', con);   
        
        con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = recordType;
        con1.LastName='test last name';
        con1.FirstName='test first name';
        con1.Email__c = 'test@test.com';
        con1.Billing_Indicator__c = true;
        con.Recipient_Indicator__c = false;
        insert con1;
        objectMap.put('Billing Contact', con1); 
        
        addressList = new List<Address__c>();
        for(Integer x = 10; x < 20; x++) {
            addressList.add(
                new Address__c(
                    Postal_Code__c = singPost.Id,
                    Unit_Number__c = String.valueOf(x),
                    Name = 'Test Add ' + x,
                    Level_Number__c = String.valueOf(x),
                    Country__c = country.id
                )
            );            
        }
        insert addressList;
        //system.assertequals(addressList, null);
       
        country = new Country__c(
            Name = 'xx',
            Country_Name__c = 'Country Name'
            
        );
        insert country;
        
        city = new City__c(
            Name = 'yy',
            City_Name__c = 'City Name',
            Flight_Number_1__c = '02-15-2014' 
        );
        insert city;
        
        
    }  
    
}