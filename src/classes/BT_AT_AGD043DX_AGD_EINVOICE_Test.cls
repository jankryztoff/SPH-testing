/*
 * Class Name: BT_AT_AGD043DX_AGD_EINVOICE_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - AGD043DX Interface
 * @description A test class for BT_AT_AGD043DX_AGD_EINVOICE 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_AGD043DX_AGD_EINVOICE_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        List<BT_CO_AGD_EINVOICE__c> interfaceRecordList = new List<BT_CO_AGD_EINVOICE__c>();
        
        BT_CO_AGD_EINVOICE__c interfaceRecord = new BT_CO_AGD_EINVOICE__c();
        interfaceRecord.Name = 'AGD043DX';
        interfaceRecord.business_unit__c = '1';
        interfaceRecord.invoice_date__c = '2';
        interfaceRecord.invoice_number__c = '3';
        interfaceRecord.remarks__c = '4';

        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
}