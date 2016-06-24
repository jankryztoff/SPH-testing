@isTest
private class AddressValidatorTest {

    private static testMethod void validate() {
        
        final string POSTAL_NAME =  '00011';
        final string BUILDING_NO = 'ABCDEF0';
        final string LEVEL = '001';
        final string UNIT = '01';
        List<Address__c> addList = new List<Address__c>();
        
        list<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(1);
        singpostAddressList[0].Name = POSTAL_NAME;
        
        insert singpostAddressList;
        
        Address_Details__c addressDetail = new Address_Details__c();
        addressDetail.postal_code__c = singpostAddressList[0].Id;
        addressDetail.buildingNo__c = BUILDING_NO;
        addressDetail.level__c = LEVEL;
        addressDetail.unit__c = UNIT;
        addressDetail.key__c = 'thequickbrownfoxjumpsovert';       
        insert addressDetail;
        
        Country__c country = new Country__c();
        country.Name = 'SG';
        country.Code__c = 'SIN';
        country.Country_Name__c = 'Singapore';
        insert country;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'H';
        addressRec.Postal_Code__c = singpostAddressList[0].Id;
        addressRec.Block_House_Number__c ='44';
        addressRec.Level_Number__c = LEVEL;
        addressRec.Unit_Number__c = UNIT;
        addressRec.Country__c = country.Id;
        
        insert addressRec;
        addList.add(addressRec);

        
        Test.startTest();
        
        string validIdentifier = POSTAL_NAME + BUILDING_NO + LEVEL + UNIT;
        string invalidIdenfier = validIdentifier + 'X';
        
        map<string, boolean> identifier_isValid = AddressValidator.validate(new set<string>{validIdentifier, invalidIdenfier});
        boolean isValid = AddressValidator.validate(addressRec);
        map<string, boolean> isValidList =  AddressValidator.validate(addList);
        
        //System.assertEquals(true, identifier_isValid.get(validIdentifier));
        //System.assertEquals(false, identifier_isValid.get(invalidIdenfier));
        
        Test.stopTest();
    }
}