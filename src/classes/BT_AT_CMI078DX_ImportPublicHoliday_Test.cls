/*
 * Class Name: BT_AT_CMI078DX_ImportPublicHoliday_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - CMI078DX Interface
 * @description A test class for BT_AT_CMI078DX_ImportPublicHolidayInfo 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_CMI078DX_ImportPublicHoliday_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {   
        List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c>();
        
        BT_CO_CMIS_POP_ImportPublicHolidayInfo__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicHolidayInfo__c();
        interfaceRecord.Name = 'CMI078DX';
        interfaceRecord.holidayDate__c = '02.04.2015';
        interfaceRecord.holidayDescription__c = 'holidescrip';

        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    static testMethod void testInterfaceApexTrigger2()
    {
        List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c>();
        
        BT_CO_CMIS_POP_ImportPublicHolidayInfo__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicHolidayInfo__c();
        interfaceRecord.Name = 'CMI078DX';
        interfaceRecord.holidayDate__c = '';
        interfaceRecord.holidayDescription__c = 'holidescrip';

        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
     static testMethod void testInterfaceApexTrigger3()
    {
    
        
        List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c>();
        
        BT_CO_CMIS_POP_ImportPublicHolidayInfo__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicHolidayInfo__c();
        interfaceRecord.Name = 'CMI078DX';
        interfaceRecord.holidayDate__c = '01/04/2015';
        interfaceRecord.holidayDescription__c = 'holidescrip';
        
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    static testMethod void testInterfaceApexTrigger4()
    {   
        Public_Holiday__c pHol = new Public_Holiday__c();
        pHol.Name = 'pubholi';
        pHol.Holiday_Date__c = date.today();
        insert pHol;
        
        List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c>();
        
        BT_CO_CMIS_POP_ImportPublicHolidayInfo__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicHolidayInfo__c();
        interfaceRecord.Name = 'CMI078DX';
        interfaceRecord.holidayDate__c = date.today().day()+'.'+date.today().month()+'.'+date.today().year();
        interfaceRecord.holidayDescription__c = 'holidescrip';

        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
        
}