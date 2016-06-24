/**
     * Class Name: <ContactTriggerHandler_Test>
     * @author: <FrancisMartinBenzon, MarkJhustinPinoy>
     * Date: <7/15/2014>
     * Requirement/Project Name: <SPH>
     * @description<Test Class for ContactTriggerHandler, handles bulk insert and update, handles validations>
     */
    @isTest (seeAllData=true)
    private class ContactTriggerHandler_Test {  
    
    //This method runs a user to create a contact record. In the process of contact creation related Objects records are also created.
    //Account, Address, SingPost Address are also created.
    
    
    static List<Singpost_Address__c> singPostAddrList;
    static Singpost_Address__c singPostAddr;
    
    static List<City__c> cityList;
    static City__c city;
    
    static List<Country__c> countryList;
    static Country__c country;
    
    static List<Address__c> addressList;
    static Address__c addr;
    
    static List<Account> accountList;
    static Account account;
    
    static List<Contact> contactList;
    static Contact contact;
    
    
    private static User returnUser() {
        
        User u = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
        return u;    
    }
    
    /**
        @name setUpData
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setupData() {
        
        singPostAddrList = TestDataFactory.createSingpostAddress(1);
        singPostAddr = singPostAddrList.get(0);
        //singPostAddr.Name = 'singPostAddr';
        insert singPostAddr;
                
        cityList = TestDataFactory.createCity(1);
        city = cityList.get(0);
        city.City_Name__c = 'cityName_test';
        city.Flight_Number_1__c = 'cityFlightNumber1_test';
        city.Flight_Number_2__c = 'cityFlightNumber2_test';
        insert city;
        
        countryList = TestDataFactory.createCountry(1);
        country = countryList.get(0);
        country.Country_Name__c = 'Philippines';
        insert country;
                
        addressList = TestDataFactory.createAddress(1);
        addr = addressList.get(0);
        addr.Country__c = country.Id;
        addr.Postal_Code__c = singPostAddr.Id;
        
        addr.Address_Unique_Id__c = 'addrUniqueId_test';
        addr.RecordTypeId = ConstantsSLB.getKeyId('Address_Local'); //NOTE 
        
        addr.Address_1__c = 'address1_test';
        addr.Address_2__c = 'address2_test';
        insert addr;   
        
        accountList = TestDataFactory.createAccount(1, 'Direct Corporate');
        account = accountList.get(0);
        account.Airline_Indicator__c = true;
        insert account;
                
        contactList = TestDataFactory.createContactRecType(1, 'Customer Contact');
        contact = contactList.get(0);
        contact.AccountId = account.Id;
        contact.Address__c = addr.Id;
        contact.City_Code__c = city.Id;         
        contact.Billing_Indicator__c = true;
        contact.Recipient_Indicator__c = true;         
        
        contact.Email__c = 'email@email.com';
        contact.Email_Secondary__c = 'email2@email.com';
        contact.Office_Number__c = '111-111-111';
        contact.Mobile_Number__c = '111-111-111';
        contact.HomePhone__c = '111-111-111';
        contact.Fax__c = '111-111-111';
        contact.zqu__County__c = 'zouraCountry_test';
        contact.Description = 'contactDesc_test';  
        insert contact;
    }
    
    /**
    @name localAddrTest
    @param none
    @return void
    @description tests when contact with local address is inserted, updated, deleted
    */
    static testMethod void localAddrTest() {
          
        setupData();         
        Test.startTest();
          
        //update fields
        singPostAddr.Name = 'singPostAddr2';
        update singPostAddr;
        
        city.City_Name__c = 'cityName_test2';
        update city;
        
        country.Country_Name__c = 'Singapore';
        update country;        
        
        addr.Address_1__c = 'address1_test2';
        addr.Address_2__c = 'address2_test2';
        update addr;        
        
        contact.FirstName = 'contactFirstName2';
        contact.LastName = 'contactLastName2';
        contact.Email__c = 'email2@email.com';
        contact.Email_Secondary__c = 'email22@email.com';
        contact.Office_Number__c = '222-222-222';
        contact.Mobile_Number__c = '222-222-222';
        contact.HomePhone__c = '222-222-222';
        contact.Fax__c = '222-222-222';
        contact.zqu__County__c = 'zouraCountry_test2';
        contact.Description = 'contactDesc_test2';        
        update contact;
        
        contact = [Select FirstName From Contact Where Id= :contact.Id];
        System.assertEquals(contact.FirstName, 'contactFirstName2');
        
        delete contact;          
        Test.stopTest();
     }  
     
     /**
        @name overseasAddrTest
        @param none
        @return void
        @description tests when contact with overseas address is inserted, updated, deleted
    */
     static testMethod void overseasAddrTest() {
          
        setupData();       
        Test.startTest();
          
        //update fields
        singPostAddr.Name = 'singPostAddr2';
        update singPostAddr;
        
        city.City_Name__c = 'cityName_test2';
        update city;
        
        country.Country_Name__c = 'Singapore';
        update country;

        
        addressList = TestDataFactory.createAddress(1);
        addr = addressList.get(0);
        addr.Country__c = country.Id;
        addr.Postal_Code__c = singPostAddr.Id;
        
        addr.Address_Unique_Id__c = 'addrUniqueId_test';
        addr.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas'); //NOTE 
        
        addr.Address_1__c = 'address1_test2';
        addr.Address_2__c = 'address2_test2';
        insert addr;
        
        
        contact.Address__c = addr.Id; //link contact to a new address
        contact.FirstName = 'contactFirstName2';
        contact.LastName = 'contactLastName2';
        contact.Email__c = 'email2@email.com';
        contact.Email_Secondary__c = 'email22@email.com';
        contact.Office_Number__c = '222-222-222';
        contact.Mobile_Number__c = '222-222-222';
        contact.HomePhone__c = '222-222-222';
        contact.Fax__c = '222-222-222';
        contact.zqu__County__c = 'zouraCountry_test2';
        contact.Description = 'contactDesc_test2';        
        update contact;
        
        contact = [Select FirstName From Contact Where Id= :contact.Id];
        System.assertEquals(contact.FirstName, 'contactFirstName2');
        
        delete contact;           
        Test.stopTest();  
     } 
     
     /**
        @name internalAddrTest
        @param none
        @return void
        @description tests when contact with internal address is inserted, updated, deleted
    */
     static testMethod void internalAddrTest() {
          
        setupData();       
        Test.startTest();
          
        //update fields
        singPostAddr.Name = 'singPostAddr2';
        update singPostAddr;
        
        city.City_Name__c = 'cityName_test2';
        update city;
        
        country.Country_Name__c = 'Singapore';
        update country;

        
        addressList = TestDataFactory.createAddress(1);
        addr = addressList.get(0);
        addr.Country__c = country.Id;
        addr.Postal_Code__c = singPostAddr.Id;
        
        addr.Address_Unique_Id__c = 'addrUniqueId_test';
        addr.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal'); //NOTE 
        
        addr.Address_1__c = 'address1_test2';
        addr.Address_2__c = 'address2_test2';
        insert addr;
        
        
        contact.Address__c = addr.Id; //link contact to a new address
        contact.FirstName = 'contactFirstName2';
        contact.LastName = 'contactLastName2';
        contact.Email__c = 'email2@email.com';
        contact.Email_Secondary__c = 'email22@email.com';
        contact.Office_Number__c = '222-222-222';
        contact.Mobile_Number__c = '222-222-222';
        contact.HomePhone__c = '222-222-222';
        contact.Fax__c = '222-222-222';
        contact.zqu__County__c = 'zouraCountry_test2';
        contact.Description = 'contactDesc_test2';        
        update contact;
        
        contact = [Select FirstName From Contact Where Id= :contact.Id];
        System.assertEquals(contact.FirstName, 'contactFirstName2');
        
        delete contact;           
        Test.stopTest();  
     }
     
     /**
        @name airlineAddrTest
        @param none
        @return void
        @description tests when contact with airline address is inserted, updated, deleted
    */
     static testMethod void airlineAddrTest() {
          
        setupData();
        Test.startTest();
          
        //update fields
        account.Airline_Indicator__c = true;
        update account;
        
        singPostAddr.Name = 'singPostAddr2';
        update singPostAddr;
        
        city.City_Name__c = 'cityName_test2';
        update city;
        
        country.Country_Name__c = 'Singapore';
        update country;
        
        
        addressList = TestDataFactory.createAddress(1);
        addr = addressList.get(0);
        addr.Country__c = country.Id;
        addr.Postal_Code__c = singPostAddr.Id;
        
        addr.Address_Unique_Id__c = 'addrUniqueId_test';
        addr.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline'); //NOTE 
        
        addr.Address_1__c = 'address1_test2';
        addr.Address_2__c = 'address2_test2';
        insert addr;
        
        
        contact.Address__c = addr.Id; //link contact to a new address        
        contact.FirstName = 'contactFirstName2';
        contact.LastName = 'contactLastName2';
        contact.Email__c = 'email2@email.com';
        contact.Email_Secondary__c = 'email22@email.com';
        contact.Office_Number__c = '222-222-222';
        contact.Mobile_Number__c = '222-222-222';
        contact.HomePhone__c = '222-222-222';
        contact.Fax__c = '222-222-222';
        contact.zqu__County__c = 'zouraCountry_test2';
        contact.Description = 'contactDesc_test2';        
        update contact;
        
        contact = [Select FirstName From Contact Where Id= :contact.Id];
        System.assertEquals(contact.FirstName, 'contactFirstName2');
        
        delete contact;           
        Test.stopTest();  
     }
     
     /**
        @name airlineAddrTestCityNotNull
        @param none
        @return void
        @description tests when contact with airline address is inserted, updated, deleted
    */
     static testMethod void airlineAddrTestCityNotNull() {
          
        setupData();        
        Test.startTest();
          
        //update fields
        account.Airline_Indicator__c = true;
        update account;
        
        singPostAddr.Name = 'singPostAddr2';
        update singPostAddr;
        
        city.City_Name__c = 'cityName_test2';
        update city;
        
        country.Country_Name__c = 'Singapore';
        update country;
        
        
        addressList = TestDataFactory.createAddress(1);
        addr = addressList.get(0);
        addr.Country__c = country.Id;
        addr.Postal_Code__c = singPostAddr.Id;
        addr.City__c = city.id;
        
        addr.Address_Unique_Id__c = 'addrUniqueId_test';
        addr.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline'); //NOTE 
        
        addr.Address_1__c = 'address1_test2';
        addr.Address_2__c = 'address2_test2';
        insert addr;
        
        
        contact.Address__c = addr.Id; //link contact to a new address        
        contact.FirstName = 'contactFirstName2';
        contact.LastName = 'contactLastName2';
        contact.Email__c = 'email2@email.com';
        contact.Email_Secondary__c = 'email22@email.com';
        contact.Office_Number__c = '222-222-222';
        contact.Mobile_Number__c = '222-222-222';
        contact.HomePhone__c = '222-222-222';
        contact.Fax__c = '222-222-222';
        contact.zqu__County__c = 'zouraCountry_test2';
        contact.Description = 'contactDesc_test2';        
        update contact;
        
        contact = [Select FirstName From Contact Where Id= :contact.Id];
        System.assertEquals(contact.FirstName, 'contactFirstName2');
        
        delete contact;           
        Test.stopTest();  
     }
     
/** ian
     static testMethod void testUpdateZuoraPaticular01() {
        
        Integer count = 0;
        
        //setupData();       
        
    // Account    
        List<Account> myAccountList = TestDataFactory.createAccount(1, 'Direct Corporate');
        for (Account accnt : myAccountList) {
            accnt.Airline_Indicator__c = true;
        }
        insert myAccountList;
// NEW
    // Address - City
        List<City__c> myCityList = TestDataFactory.createCity(1);
        for (City__c ct : myCityList) {
            ct.City_Name__c = 'cityName_test';
            ct.Flight_Number_1__c = 'cityFlightNumber1_test';
            ct.Flight_Number_2__c = 'cityFlightNumber2_test';
        }
        insert myCityList ;
        
    // Address - Country
        List<Country__c> myCountryList = TestDataFactory.createCountry(1);
        for (Country__c cntry : myCountryList) {
            cntry.Country_Name__c = 'Philippines';
        }
        insert myCountryList ;
    
    // Address
        List<Address__c> myAddressList = TestDataFactory.createAddress(1);
        count = 0;
        for (Address__c addrs : myAddressList) {
            addrs.Country__c = myCountryList[count].Id;
            //addrs.Postal_Code__c = singPostAddr.Id;
            
            addrs.Address_Unique_Id__c = 'addrUniqueId_test';
            addrs.RecordTypeId = ConstantsSLB.getKeyId('Address_Local'); //NOTE 
            
            addrs.Address_1__c = 'address1_test';
            addrs.Address_2__c = 'address2_test';
            count++;
        }
        insert myAddressList;   
    // Address - Country
    
        List<Contact> lstNewContacts = TestDataFactory.createContact(1);
        count = 0;
        for (Contact myContact : lstNewContacts ) {
            //contact = contactList.get(0);
            myContact.AccountId = myAccountList[count].Id;
            myContact.Address__c = myAddressList[count].Id;
            myContact.City_Code__c = myCityList[count].Id;
            count++;
        }
        insert lstNewContacts;
        
        List<String> oldContactsId = new List<String>();
        for(Contact myContact : lstNewContacts) {
            oldContactsId.add(myContact.Id);
        }

// OLD        
        Map<Id, Contact> mapOldContacts = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Email__c, Email_Secondary__c, Office_Number__c, Mobile_Number__c, HomePhone__c, Address__c, Fax__c, City_Code__c, zqu__County__c, Description FROM Contact WHERE Id=:oldContactsId]);//new Map<Id, Contact>(); // QUERY all Contacts
        
        ContactTriggerHandler testObj = new ContactTriggerHandler();
          
        Test.startTest();
        
        testObj.doAfterUpdate(lstNewContacts, new Map<Id, Contact>(),
                               new List<Contact>(), mapOldContacts);
        Test.stopTest();
    }
****/
}