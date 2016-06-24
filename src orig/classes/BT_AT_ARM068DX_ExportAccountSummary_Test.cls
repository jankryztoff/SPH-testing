/*
 * Class Name: BT_AT_ARM068DX_ExportAccountSummary_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - ARM068DX Interface
 * @description A test class for BT_AT_ARM068DX_ExportAccountSummary 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_ARM068DX_ExportAccountSummary_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        List<BT_CO_ARMS_ExportAccountSummary__c> interfaceRecordList = new List<BT_CO_ARMS_ExportAccountSummary__c>();
        
        BT_CO_ARMS_ExportAccountSummary__c interfaceRecord = new BT_CO_ARMS_ExportAccountSummary__c();
        interfaceRecord.Name = 'ARM068DX';
        interfaceRecord.exportData__c = '1';
        interfaceRecord.groupId__c = '2';
        interfaceRecord.sortOrder__c = '3';
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
}