@isTest(seeAllData=True)
private class ChangeOfAddressController_Test{
    
    public String selectedCountry {get; set;} 
    
    static testMethod void testChangeOfAddressController(){
    
        //create Account record
        Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        insert acc;
        
        //create SingPost Address
        Singpost_Address__c singPostAd = TestDataFactory.createSingpostAddress(1)[0];
        insert singPostAd;
        
        //create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        addressList[0].Postal_Code__c = singPostAd.Id;
        
        //addressList[0].City__r.City__c = 1017; //Illegal assignment from Integer to Id
        //addressList[0].Country__r.Country_Name__c = 'PHILIPPINES' ; //must be an ID
        //addressList[0].Packing_Grp__r.Packing_Code__c = 'MFA'; //Invalid id: MFA
        addressList[0].Unit_Number__c = '22'; //Illegal assignment from Integer to String - must be a string
        addressList[0].Level_Number__c = '12'; //Illegal assignment from Integer to String
        
        insert addressList; 
        
        //create Contact for Case record
        Contact contactList = TestDataFactory.createContact(1)[0];
        contactList.AccountId = acc.Id;
        contactList.Address__c = addressList[0].Id;
        insert contactList;
        
        System.assertEquals(contactList.AccountId, acc.Id);
        //create Case record
        Case c = TestDataFactory.createCase(1, 'Change of Address')[0];
        c.AccountId = acc.Id;
        c.Change_of_Address_Type__c = 'Change of Billing Address';
        c.Selected_Subscriptions_Only__c = false;
        c.ContactId = contactList.Id;
        insert c;
        
        PageReference pageRef = Page.ChangeOfAddress;
        pageRef.getParameters().put('caseid', c.Id);
        pageRef.getParameters().put('id', contactList.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(contactList);  
        ChangeOfAddressController createChangeOfAddressController = new ChangeOfAddressController(controller);
        
        Test.startTest();
        
        List<Country__c> country = [SELECT id FROM Country__c WHERE Name = 'PH'];
        createChangeOfAddressController.selectedCountry = country.get(0).id;
        
        //create City record
        City__c newCityRecord = new City__c();
        newCityRecord.name = '1324';
        newCityRecord.City_Name__c = 'TestCity';
        newCityRecord.Country__c = createChangeOfAddressController.selectedCountry;
        newCityRecord.Flight_Number_1__c = '02-16-2015';
        newCityRecord.Flight_Number_2__c = '02-16-2016';
        insert newCityRecord;
                
        List<City__c> city = [SELECT id from City__c WHERE City_Name__c= 'TestCity'];
        createChangeOfAddressController.stagedAddress.City__c = city.get(0).id;
        
        //createChangeOfAddressController.setAddressType('Local');
        createChangeOfAddressController.getAddressTypeOptions();
        createChangeOfAddressController.search();
        createChangeOfAddressController.fetchCityName();
        createChangeOfAddressController.fetchPackingGrpDetails();
        createChangeOfAddressController.selectAddressRecord();
        createChangeOfAddressController.clearAddressDetails();
        createChangeOfAddressController.clearContactAddress();
        createChangeOfAddressController.fetchCountryCode();
        
        //test unit number validation error
        createChangeOfAddressController.stagedAddress.Unit_Number__c = '0';    
        createChangeOfAddressController.AddressType='Overseas';
        createChangeOfAddressController.checked=true;
        System.assertNotEquals(null,createChangeOfAddressController.stagedAddress.Unit_Number__c);
        System.assertNotEquals(2,createChangeOfAddressController.stagedAddress.Unit_Number__c.length());
        createChangeOfAddressController.saveRecord();
        System.assert(ApexPages.getMessages().size()>0);
          
        //test level number validation error
        createChangeOfAddressController.stagedAddress.Unit_Number__c = null;    
        System.assertEquals(null,createChangeOfAddressController.stagedAddress.Unit_Number__c);
        createChangeOfAddressController.stagedAddress.Level_Number__c= '0';    
        System.assertNotEquals(null,createChangeOfAddressController.stagedAddress.Level_Number__c);
        System.assertNotEquals(2,createChangeOfAddressController.stagedAddress.Level_Number__c.length());
        createChangeOfAddressController.saveRecord();
        System.assert(ApexPages.getMessages().size()>0);
        
        
        //test searchQuery try statement        
        createChangeOfAddressController.stagedAddress.Level_Number__c= null;    
        System.assertEquals(null,createChangeOfAddressController.stagedAddress.Level_Number__c);
        System.assertEquals(true,createChangeOfAddressController.checked);
        createChangeOfAddressController.saveRecord();
        System.assert(ApexPages.getMessages().size()>0);
        
        //test searchQuery catch statement
        //createChangeOfAddressController.stagedAddress.Building_Name__c = 'MyTestBuildingName123';
        createChangeOfAddressController.stagedAddress.Address_Type__c = 'TestAddressType';
        createChangeOfAddressController.saveRecord();
        System.assert(ApexPages.getMessages().size()>0);
            
        Test.stopTest();
            
    }//END testMethod testChangeOfAddressController()
    
    static testMethod void testChangeOfAddressController2(){
    
    //create Account record
    Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
    insert acc;
    
    //create SingPost Address
    Singpost_Address__c singPostAd = TestDataFactory.createSingpostAddress(1)[0];
    insert singPostAd;
    
    //create an Address record
    List<Address__c> addressList = TestDataFactory.createAddress(1);
    addressList[0].Postal_Code__c = singPostAd.Id;
    insert addressList;
        
    //create Contact for Case record
    Contact contactList = TestDataFactory.createContact(1)[0];
    contactList.Address__c = addressList[0].Id;
    contactList.AccountId = acc.Id;
    insert contactList;
    
    //create Case record
    Case c = TestDataFactory.createCase(1, 'Change of Address')[0];
    c.AccountId = acc.Id;
    c.Change_of_Address_Type__c = 'Change of Delivery Address – Local to Local';
    c.Selected_Subscriptions_Only__c = true;
    c.ContactId = contactList.Id;
    insert c;
    
    PageReference pageRef = Page.ChangeOfAddress;
    pageRef.getParameters().put('caseid', c.Id);
    pageRef.getParameters().put('id', contactList.Id);
    Test.setCurrentPage(pageRef);
    
    ApexPages.StandardController controller = new ApexPages.StandardController(contactList);  
    ChangeOfAddressController createChangeOfAddressController = new ChangeOfAddressController(controller );
    createChangeOfAddressController.getAddressTypeOptions();
    createChangeOfAddressController.search();
    createChangeOfAddressController.fetchCityName();
    createChangeOfAddressController.fetchPackingGrpDetails();
    createChangeOfAddressController.selectAddressRecord();
    createChangeOfAddressController.clearAddressDetails();
    createChangeOfAddressController.clearContactAddress();
    createChangeOfAddressController.saveRecord();
    createChangeOfAddressController.fetchCountryCode();
    
    }//END testMethod testChangeOfAddressController2()
    
    static testMethod void testChangeOfAddressController3(){
    
    //create Account record
    Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
    insert acc;
    
    //create SingPost Address
    Singpost_Address__c singPostAd = TestDataFactory.createSingpostAddress(1)[0];
    insert singPostAd;
    
    //create an Address record
    List<Address__c> addressList = TestDataFactory.createAddress(1);
    addressList[0].Postal_Code__c = singPostAd.Id;
    insert addressList;
     
    //create Contact for Case record
    Contact contactList = TestDataFactory.createContact(1)[0];
    contactList.Address__c = addressList[0].Id;
    contactList.AccountId = acc.Id;
    insert contactList;
    
    
    //create Case record
    Case c = TestDataFactory.createCase(1, 'Change of Address')[0];
    c.AccountId = acc.Id;
    c.Change_of_Address_Type__c = 'Change of Delivery address – Local to Overseas';
    c.ContactId = contactList.Id;
    insert c;
    
    PageReference pageRef = Page.CaseAssignSelectedSubscription;
    pageRef.getParameters().put('caseid', c.Id);
    pageRef.getParameters().put('id', contactList.Id);
    Test.setCurrentPage(pageRef);
    
    ApexPages.StandardController controller = new ApexPages.StandardController(contactList);  
    ChangeOfAddressController createChangeOfAddressController = new ChangeOfAddressController(controller );
    createChangeOfAddressController.getAddressTypeOptions();
    createChangeOfAddressController.search();
    createChangeOfAddressController.fetchCityName();
    createChangeOfAddressController.fetchPackingGrpDetails();
    createChangeOfAddressController.selectAddressRecord();
    createChangeOfAddressController.clearAddressDetails();
    createChangeOfAddressController.clearContactAddress();
    createChangeOfAddressController.saveRecord();
    createChangeOfAddressController.fetchCountryCode();
        
    }//END testMethod testChangeOfAddressController3()
}//END ChangeOfAddressController_Test