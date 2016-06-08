/*
 * Class Name: BT_AT_CMI075DX_ImportPublication_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - CMI075DX Interface
 * @description A test class for BT_AT_CMI075DX_ImportPublicationInfo 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
             02/18/2015 Kalidass Gujar created test method importPublicationInfoTest
 */

@isTest
private class BT_AT_CMI075DX_ImportPublication_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        List<BT_CO_CMIS_POP_ImportPublicationInfo__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicationInfo__c>();
        
        BT_CO_CMIS_POP_ImportPublicationInfo__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicationInfo__c();
        interfaceRecord.Name = 'CMI075DX';
        interfaceRecord.effectiveDate__c = 'a';
        interfaceRecord.expiryDate__c = 'b';
        interfaceRecord.frequencyCode__c = 'c';
        interfaceRecord.publicationCode__c = 'd';
        interfaceRecord.publicationName__c = 'e';
        interfaceRecord.publicationType__c = 'f';
        interfaceRecord.publicHolidayWeekdayIndicator__c = 'g';
        interfaceRecord.publicHolidayWeekendIndicator__c = 'h';
        interfaceRecord.publishedDays__c = 'i';
        interfaceRecord.sphPublicationIndicator__c = 'j';
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    static testMethod void importPublicationInfoTest(){
    
    Integer i;
    
    
    Publication__c p = new Publication__c();
    p.Name = 'Test';
    p.Publication_Code__c = 'D462';
    p.Published_Days__c = 'NNYNNYN';
    p.Publication_Type__c = 'M';
    
    insert p;
    
    
    BT_CO_CMIS_POP_ImportPublicationInfo__c insertRecord = new BT_CO_CMIS_POP_ImportPublicationInfo__c();
        insertRecord.Name = 'CMI075DX';
        insertRecord.effectiveDate__c = '02.07.2015';
        insertRecord.expiryDate__c = '02.12.2015';
        insertRecord.frequencyCode__c = 'D';
        insertRecord.publicationCode__c = 'D462';
        insertRecord.publicationName__c = 'Test';
        insertRecord.publicationType__c = 'M';
        insertRecord.publicHolidayWeekdayIndicator__c = 'Y';
        insertRecord.publicHolidayWeekendIndicator__c = 'N';
        insertRecord.publishedDays__c = '56';
        insertRecord.sphPublicationIndicator__c = 'Y';
        insertRecord.onlinePublicationIndicator__c= 'Y';
        insertRecord.freePublicationIndicator__c = 'N';
        
    
    
    insert insertRecord ;
    
    BT_CO_CMIS_POP_ImportPublicationInfo__c record= new BT_CO_CMIS_POP_ImportPublicationInfo__c();
        record.Name = 'CMI075DX';
        record.effectiveDate__c = '02.07.2015';
        record.expiryDate__c = '02.12.2015';
        record.frequencyCode__c = 'D';
        record.publicationCode__c = 'D807';
        record.publicationName__c = 'Test1';
        record.publicationType__c = 'M';
        record.publicHolidayWeekdayIndicator__c = 'N';
        record.publicHolidayWeekendIndicator__c = 'Y';
        record.publishedDays__c = '56';
        record.sphPublicationIndicator__c = 'N';
        record.onlinePublicationIndicator__c= 'N';
        record.freePublicationIndicator__c = 'Y';
        
        insert record;
    }
}