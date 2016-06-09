@isTest
private class BT_AT_CMI079DX_ImportNextIssueDateInTest{
    static testMethod void testBT_AT_CMI079DX_ImportNextIssueDateInfo(){
        //start test data
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
            
        BT_CO_CMIS_POP_ImportNextIssueDateInfo__c inidi = new BT_CO_CMIS_POP_ImportNextIssueDateInfo__c();
        inidi.publicationCode__c = '02';
        //end test data
    
        test.startTest();
            database.insert(inidi);
        test.stopTest();
    }
    
    static testMethod void testBT_AT_CMI079DX_ImportNextIssueDateInfo2(){
        //start test data
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
            
        BT_CO_CMIS_POP_ImportNextIssueDateInfo__c inidi = new BT_CO_CMIS_POP_ImportNextIssueDateInfo__c();
        inidi.publicationCode__c = '01';
        inidi.publicationNextStartDate__c = '26.10.2015';
        //end test data
    
        test.startTest();
            database.insert(inidi);
        test.stopTest();
    } 
}