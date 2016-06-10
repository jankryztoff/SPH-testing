/*
* Class Name: <ChangeOfAddressController_Test>
* @author: Manolo Luis Valena
* @edited: Thayne Recato Dy
* @edited:Kristine Balaoing 4/11/2016
* Date: 2/24/2015
* Requirement/Project Name: <SPH>
* @description: This is the test class for ChangeOfAddressController
*/
@isTest(seeAllData=True)
private class ChangeOfAddressControllerTest{
    
    public String selectedCountry {get; set;} 
    
    /*@Description: This test method executes all methods in the base class with a Address Type of Overseas*/
    static testMethod void testChangeOfAddressController(){
    
        //create Account record
        Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        database.insert(acc);
        
        //create SingPost Address
        Singpost_Address__c singPostAd = TestDataFactory.createSingpostAddress(1)[0];
        database.insert(singPostAd);
        
        Packing_Grp__c pack = new Packing_Grp__c();
        pack.Packing_Group_Description__c = 'PACKCODE123';
        pack.Sequence_Number__c = 123456;
        database.insert(pack);
                
        //create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        addressList[0].Postal_Code__c = singPostAd.Id;        
        addressList[0].Unit_Number__c = '22'; //Illegal assignment from Integer to String - must be a string
        addressList[0].Level_Number__c = '12'; //Illegal assignment from Integer to String
        addressList[0].Block_House_Number__c  = '1';
        addressList[0].Address_Type__c = 'H';
        //addressList[0].Building_Name__c  = 'Telco';
        addressList[0].Packing_Code__c= pack.id;
        
        database.insert(addressList);
         
        System.AssertEquals(pack.id, addressList[0].Packing_Code__c);         
                
        //create Contact for Case record
        Contact contactList = TestDataFactory.createContact(1)[0];
        contactList.AccountId = acc.Id;
        contactList.Address__c = addressList[0].Id;
        contactList.Recipient_Indicator__c = true;
        contactList.Billing_Indicator__c  = true;
        database.insert(contactList);
        
        System.assertEquals(contactList.AccountId, acc.Id);
        //create Case record
        Case c = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        c.AccountId = acc.Id;
        c.Change_of_Address_Type__c = 'Change of Billing Address';
        c.Selected_Subscriptions_Only__c = false;
        c.ContactId = contactList.Id;
        database.insert(c);
        
        PageReference pageRef = Page.ChangeOfAddress;
        pageRef.getParameters().put('caseid', c.Id);
        pageRef.getParameters().put('id', contactList.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(contactList);  
        ChangeOfAddressController createChangeOfAddressController = new ChangeOfAddressController(controller);
        
        Test.startTest();
        
        createChangeOfAddressController.addressId = addressList[0].id;
        
        List<Country__c> country = [SELECT id FROM Country__c WHERE Name = 'PH'];
        createChangeOfAddressController.selectedCountry = country.get(0).id;
        
        //create City record
        City__c newCityRecord = new City__c();
        newCityRecord.name = '1324';
        newCityRecord.City_Name__c = 'TestCity';
        newCityRecord.Country__c = createChangeOfAddressController.selectedCountry;
        newCityRecord.Flight_Number_1__c = '02-16-2015';
        newCityRecord.Flight_Number_2__c = '02-16-2016';
        database.insert(newCityRecord);
                
        List<City__c> city = [SELECT id from City__c WHERE City_Name__c= 'TestCity'];
        createChangeOfAddressController.stagedAddress.City__c = city.get(0).id;
        
        //createChangeOfAddressController.setAddressType('Local');
        try{
            createChangeOfAddressController.getAddressTypeOptions();
            createChangeOfAddressController.search();
            createChangeOfAddressController.fetchCityName();
            createChangeOfAddressController.fetchPackingGrpDetails();
            createChangeOfAddressController.selectAddressRecord();
            createChangeOfAddressController.clearAddressDetails();
            createChangeOfAddressController.clearContactAddress();
            createChangeOfAddressController.fetchCountryCode();
        }catch(Exception e){
            System.debug('Error' + e);
        }
        
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
        createChangeOfAddressController.stagedAddress.Address_Type__c = 'TestAddressType';
        createChangeOfAddressController.saveRecord();
        System.assert(ApexPages.getMessages().size()>0);
        
        //test fetchCityName
        
        addressList[0].City__C = null;
        database.update(addressList);
        createChangeOfAddressController.fetchCityName();
        
        //test fetchPackingGrpDetails
        addressList[0].Packing_Code__c = pack.id;
        database.update(addressList);
        createChangeOfAddressController.fetchPackingGrpDetails();
            
        Test.stopTest();
            
    }//END testMethod testChangeOfAddressController()

    /*@Description: This test method executes all methods in the base class but with a Address Type of Local*/    
    static testMethod void testChangeOfAddressController2(){
    
        //create Account record
        Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        database.insert(acc);
        
        //create SingPost Address
        Singpost_Address__c singPostAd = TestDataFactory.createSingpostAddress(1)[0];
        database.insert(singPostAd);
        
        //create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        addressList[0].Postal_Code__c = singPostAd.Id;
        database.insert(addressList);
        
        //create Contact for Case record
        Contact contactList = TestDataFactory.createContact(1)[0];
        contactList.Address__c = addressList[0].Id;
        contactList.AccountId = acc.Id;
        database.insert(contactList);
        
        //create Case record
        Case c = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        c.AccountId = acc.Id;
        c.Change_of_Address_Type__c = 'Change of Delivery Address – Local to Local';
        c.Selected_Subscriptions_Only__c = true;
        c.ContactId = contactList.Id;
        database.insert(c);
        
        Case myCase = [SELECT Change_of_Address_Type__c
                      FROM Case
                      WHERE Id =: c.id];
        
        System.assertEquals('Change of Delivery Address – Local to Local', myCase.Change_of_Address_Type__c);
        
        PageReference pageRef = Page.ChangeOfAddress;
        pageRef.getParameters().put('caseid', c.Id);
        pageRef.getParameters().put('id', contactList.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(contactList);  
        ChangeOfAddressController createChangeOfAddressController = new ChangeOfAddressController(controller );
        
        /*@description: test when Address Type is Local*/
        createChangeOfAddressController.stagedAddress.Unit_Number__c = '0';    
        createChangeOfAddressController.AddressType='Local';
        createChangeOfAddressController.checked=true;    
        
        try{
            createChangeOfAddressController.getAddressTypeOptions();
            createChangeOfAddressController.search();
            createChangeOfAddressController.fetchCityName();
            createChangeOfAddressController.fetchPackingGrpDetails();
            createChangeOfAddressController.selectAddressRecord();
            createChangeOfAddressController.clearAddressDetails();
            createChangeOfAddressController.clearContactAddress();
            createChangeOfAddressController.saveRecord();
            createChangeOfAddressController.fetchCountryCode();
        }catch(Exception e){
            System.debug('Error ' + e);
        }
        
    }//END testMethod testChangeOfAddressController2()

    /*@Description: This test method executes all methods in the base class but with a Change
                of Delivery Address from Local to Overseas */        
    static testMethod void testChangeOfAddressController3(){
    
        //create Account record
        Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        database.insert(acc);
        
        //create SingPost Address
        Singpost_Address__c singPostAd = TestDataFactory.createSingpostAddress(1)[0];
        database.insert(singPostAd);
        
        //create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        addressList[0].Postal_Code__c = singPostAd.Id;
        addressList[0].Block_House_Number__c  = '1';
        addressList[0].Address_Type__c = 'H';
        //addressList[0].Building_Name__c  = 'Telco';
        database.insert(addressList);
        
        //create Contact for Case record
        Contact contactList = TestDataFactory.createContact(1)[0];
        contactList.Address__c = addressList[0].Id;
        contactList.AccountId = acc.Id;
        database.insert(contactList);
        
        
        //create Case record
        Case c = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        c.AccountId = acc.Id;
        c.Change_of_Address_Type__c = 'Change of Delivery Address -- Local to Overseas';
        c.ContactId = contactList.Id;
        database.insert(c);
        
        Case myCase = [SELECT Change_of_Address_Type__c
                       FROM Case
                       WHERE Id =: c.id];
        
        System.assertEquals('Change of Delivery Address – Local to Overseas', myCase.Change_of_Address_Type__c);
        
        PageReference pageRef = Page.CaseAssignSelectedSubscription;
        pageRef.getParameters().put('caseid', c.Id);
        pageRef.getParameters().put('id', contactList.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(contactList);  
        ChangeOfAddressController createChangeOfAddressController = new ChangeOfAddressController(controller );
        try{
            createChangeOfAddressController.getAddressTypeOptions();
            createChangeOfAddressController.search();
            createChangeOfAddressController.fetchCityName();
            createChangeOfAddressController.fetchPackingGrpDetails();
            createChangeOfAddressController.selectAddressRecord();
            createChangeOfAddressController.clearAddressDetails();
            createChangeOfAddressController.clearContactAddress();
            createChangeOfAddressController.saveRecord();
            createChangeOfAddressController.fetchCountryCode();
        }catch(Exception e){
            System.debug('Errors ' + e);
        }
        
    }//END testMethod testChangeOfAddressController3()

  static testMethod void testChangeOfAddressControllerIfPackingCodeNotNull(){
        Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        database.insert(acc);
        
        //create SingPost Address
        Singpost_Address__c singPostAd = TestDataFactory.createSingpostAddress(1)[0];
        database.insert(singPostAd);
        
        Packing_Grp__c pack = new Packing_Grp__c();
        pack.Packing_Group_Description__c = 'PACKCODE123';
        pack.Sequence_Number__c = 123456;
        database.insert(pack);
        
        //create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(2);
        addressList[0].Postal_Code__c = null;        
        addressList[0].Unit_Number__c = '22'; 
        addressList[0].Level_Number__c = '12'; 
        addressList[0].Packing_Code__c= pack.Id;
        addressList[1].Postal_Code__c = singPostAd.Id;        
        addressList[1].Unit_Number__c = '22'; 
        addressList[1].Level_Number__c = '12'; 
        addressList[1].Packing_Code__c= pack.Id;
        
        database.insert(addressList);
 
        //create Contact for Case record
        Contact contactList = new Contact();
        contactList.LastName = 'Sample';
        contactList.AccountId = acc.Id;
        contactList.Address__c = addressList[0].Id;
        contactList.Phone= '111222333'; //joy added
        database.insert(contactList);
        
        System.assertEquals(contactList.AccountId, acc.Id);
        //create Case record
        Case c = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        c.AccountId = acc.Id;
        c.Change_of_Address_Type__c = 'Change of Billing Address';
        c.Selected_Subscriptions_Only__c = false;
        c.ContactId = null;
        database.insert(c);  
        
        PageReference pageRef = Page.ChangeOfAddress;
        pageRef.getParameters().put('caseid', c.Id);
        pageRef.getParameters().put('id', null);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(contactList);  
        ChangeOfAddressController createChangeOfAddressController = new ChangeOfAddressController(controller);  
        
        createChangeOfAddressController.stagedAddress = addressList[0];
        createChangeOfAddressController.addressId = string.valueOf(addressList[1].Id);
        createChangeOfAddressController.addressType = 'Local';
        
        Test.startTest();
            try{
                createChangeOfAddressController.search();
                createChangeOfAddressController.fetchPackingGrpDetails();
                createChangeOfAddressController.selectAddressRecord();
                
                createChangeOfAddressController.checked = true;
                contactList.Address__c = null;
                update contactList;
                createChangeOfAddressController.thisContact = contactList;
                createChangeOfAddressController.saveRecord();
                
                createChangeOfAddressController.searchstring = '';
                createChangeOfAddressController.postalId = '';
                createChangeOfAddressController.onOwnWindow = true;
                createChangeOfAddressController.billingIndicator = true;
                createChangeOfAddressController.recipientIndicator =true;
            }catch(Exception e){
                System.debug('Error ' + e);
            }
        Test.stopTest();    
        
        
      /*  ChangeOfAddressController coac = new ChangeOfAddressController();
        coac.searchstring = 'string';
        coac.postalId = 'id';
        coac.onOwnWindow = true;
        coac.billingIndicator = true;
        coac.recipientIndicator = true;*/
        
    }   

}//END ChangeOfAddressController_Test