/*
 * Class Name: BT_AT_CMI080DX_ImportNonPublication_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - CMI080DX Interface
 * @description A test class for BT_AT_CMI080DX_ImportNonPublicationDate 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 * History: 02/06/2015 George Santos Modified to increase coverage of the trigger
 */

@isTest
private class BT_AT_CMI080DX_ImportNonPublication_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        List<BT_CO_CMIS_POP_ImportNonPublicationDate__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportNonPublicationDate__c>();
        
        BT_CO_CMIS_POP_ImportNonPublicationDate__c interfaceRecord = new BT_CO_CMIS_POP_ImportNonPublicationDate__c();
        interfaceRecord.Name = 'CMI080DX';
        interfaceRecord.nonPublicationDate__c = '12.11.2014';
        interfaceRecord.publicationCode__c = 'b';


        interfaceRecordList.add(interfaceRecord);
        
        //START - add1 - George Santos - 2/6/2015 - added for publication record and non publication day record
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = 'b';
        pub.Published_Days__c = '1';
        pub.Publication_Type__c = 'b';
        pub.Published_Days__c = 'YYYYYYN';
        insert pub;
        
        Non_Publication_Day__c nonPubDay = new Non_Publication_Day__c();
        nonPubDay.Publication__c = pub.id;
        nonPubDay.Publication_Code__c = 'b';
        nonPubDay.Non_Publication_Date__c = Date.Today();
        insert nonPubDay;
        //END - add1 - George Santos
        
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    //START - add2 - George Santos - 2/6/2015 - added for null conditions
    static testMethod void testInterfaceApexTrigger2()
    {
        List<BT_CO_CMIS_POP_ImportNonPublicationDate__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportNonPublicationDate__c>();
        
        BT_CO_CMIS_POP_ImportNonPublicationDate__c interfaceRecord = new BT_CO_CMIS_POP_ImportNonPublicationDate__c();
        interfaceRecord.Name = 'CMI080DX';
        interfaceRecord.nonPublicationDate__c = null;
        interfaceRecord.publicationCode__c = 'b';


        interfaceRecordList.add(interfaceRecord);

        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = 'c';
        pub.Published_Days__c = '1';
        pub.Publication_Type__c = 'b';
        pub.Published_Days__c = 'YYYYYYN';
        insert pub;
        
        Non_Publication_Day__c nonPubDay = new Non_Publication_Day__c();
        nonPubDay.Publication__c = pub.id;
        nonPubDay.Publication_Code__c = 'c';
        nonPubDay.Non_Publication_Date__c = Date.Today();
        insert nonPubDay;
        
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    //END - add2 - George Santos
    
    //START - add3 - George Santos - added for invalid date
    static testMethod void testInterfaceApexTrigger3()
    {
        List<BT_CO_CMIS_POP_ImportNonPublicationDate__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportNonPublicationDate__c>();
        
        BT_CO_CMIS_POP_ImportNonPublicationDate__c interfaceRecord = new BT_CO_CMIS_POP_ImportNonPublicationDate__c();
        interfaceRecord.Name = 'CMI080DX';
        interfaceRecord.nonPublicationDate__c = 'b';
        interfaceRecord.publicationCode__c = 'b';


        interfaceRecordList.add(interfaceRecord);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = 'b';
        pub.Published_Days__c = '1';
        pub.Publication_Type__c = 'b';
        pub.Published_Days__c = 'YYYYYYN';
        insert pub;
        
        Non_Publication_Day__c nonPubDay = new Non_Publication_Day__c();
        nonPubDay.Publication__c = pub.id;
        nonPubDay.Publication_Code__c = 'b';
        nonPubDay.Non_Publication_Date__c = Date.Today();
        insert nonPubDay;
        
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    //END - add3 - George Santos
}