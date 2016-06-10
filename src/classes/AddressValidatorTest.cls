@isTest
private class AddressValidatorTest {

    private static testMethod void validate() {
        
        final string POSTAL_NAME =  '00011';
        final string BUILDING_NO = 'ABCDEF0';
        final string LEVEL = '001';
        final string UNIT = '01';
        
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
        
        Test.startTest();
        
        string validIdentifier = POSTAL_NAME + BUILDING_NO + LEVEL + UNIT;
        string invalidIdenfier = validIdentifier + 'X';
        
        map<string, boolean> identifier_isValid = AddressValidator.validate(new set<string>{validIdentifier, invalidIdenfier});
            
        System.assertEquals(true, identifier_isValid.get(validIdentifier));
        System.assertEquals(false, identifier_isValid.get(invalidIdenfier));
        
        Test.stopTest();
    }
}