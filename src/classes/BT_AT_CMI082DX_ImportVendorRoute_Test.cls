/*
 * Class Name: BT_AT_CMI082DX_ImportVendorRoute_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - CMI082DX Interface
 * @description A test class for BT_AT_CMI082DX_ImportVendorRouteInfo 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_CMI082DX_ImportVendorRoute_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        List<BT_CO_CMIS_POP_ImportVendorRouteInfo__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportVendorRouteInfo__c>();
        
        BT_CO_CMIS_POP_ImportVendorRouteInfo__c interfaceRecord = new BT_CO_CMIS_POP_ImportVendorRouteInfo__c();
        interfaceRecord.Name = 'CMI082DX';
        interfaceRecord.description__c = 'a';
        interfaceRecord.dropPoint__c = 'b';
        interfaceRecord.publicationCode__c = 'c';
        interfaceRecord.route__c = 'd';
        interfaceRecord.routeSystem__c = 'e';
        interfaceRecord.variedFixed__c = 'f';
        interfaceRecord.vendorId__c = 'g';

        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
}