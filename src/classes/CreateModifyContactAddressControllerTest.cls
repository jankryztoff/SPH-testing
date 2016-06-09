@isTest(seeAllData = TRUE)
public class CreateModifyContactAddressControllerTest {
    /**
     * Class Name: CreateModifyContactAddressControllerTest
     * @author: Jeffrey B. Teves
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Test Class for CAM_CreateModifyContactAddressController
     * 
     */
    
    static User cso;
    static Account acc;
    static List<Address__c> addressList;
    static SingPost_Address__c singPost;
    static Country__c country;
    static City__c city;
    
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
            System.assertEquals(10, controller.add.size());
            
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
            
            //set address details
            controller.AddressType = 'Internal';
            /*controller.stagedAddress.LocationCode__c = 'Test Location';
            controller.stagedAddress.Company_Code__c = 'Test Company Code';
            controller.stagedAddress.Division_Code__c = 'Test Division Code';
            controller.stagedAddress.Department__c = 'Test Department';
            controller.stagedAddress.Section_Code__c = 'Test Section Code';
            */
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
            /*for(Contact con : [SELECT Id, LastName, FirstName, RecordType.Name, Address__r.LocationCode__c, Address__r.Company_Code__c, Address__r.Division_Code__c, Address__r.Department__c, Address__r.Section_Code__c FROM Contact WHERE AccountId = :acc.Id]) {
                System.assertEquals('test last name', con.LastName);
                System.assertEquals('test first name', con.FirstName);
                System.assertEquals('Test Location', con.Address__r.LocationCode__c);
                System.assertEquals('Test Company Code', con.Address__r.Company_Code__c);
                System.assertEquals('Test Division Code', con.Address__r.Division_Code__c);
                System.assertEquals('Test Department', con.Address__r.Department__c);
                System.assertEquals('Test Section Code', con.Address__r.Section_Code__c);
                if(con.RecordType.Name == 'Billing Contact') {
                    isBillingContactCreated = TRUE;
                }
                if(con.RecordType.Name == 'Recipient Contact') {
                    isRecipientCOntactCreated = TRUE;
                }
            }*/
            //assert if billing and recipient contacts are created
            //System.assert(isBillingContactCreated);
            //System.assert(isRecipientContactCreated);
            
            Test.stopTest();
        } 
    }
    
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
            
            //assert error on billing/recipient indicator
            controller.billingIndicator = FALSE;
            controller.recipientIndicator = FALSE;
            controller.saveRecord();
            System.AssertEquals('Please tick Billing Indicator, Recipient Indicator or both.', ApexPages.getMessages().get(ApexPages.getMessages().size()-1).getSummary());
            
            //assert error on null adress type
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
    
    static void prepareTestusers() {
        cso = new User(
            Alias = 'standt',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
    }
    
    static void prepareTestdata() {
        
        acc = new Account(
            Name = 'Test Account',
            RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
            Email__c = 'Test@testing.com'
        );
        insert acc;
        
        singPost = new SingPost_Address__c(
            Name = '999999',
            Building_Name__c = 'Test Building Name',
            Address_Type__c = 'S',
            Street_Name__c = 'Test Street Name',
            Number_of_Units__c = 1,
            House_Block_Number__c = '1'
        );
        insert singPost;
        
        country = new Country__c(
            Name = 'xx',
            Country_Name__c = 'Country Name'
        );
        insert country;
        
        addressList = new List<Address__c>();
        for(Integer x = 10; x < 20; x++) {
            addressList.add(
                new Address__c(
                    Postal_Code__c = singPost.Id,
                    Unit_Number__c = String.valueOf(x),
                    Name = 'Test Add ' + x,
                    Level_Number__c = String.valueOf(x),
                    country__c = country.id
                )
            );            
        }
        insert addressList;
        
        
        city = new City__c(
            Name = 'yy',
            City_Name__c = 'City Name',
            Flight_Number_1__c = 'SQ279-DAILY'
        );
        insert city;
        
        
    }
}