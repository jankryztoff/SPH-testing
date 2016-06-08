/*
 * Class Name: BT_AT_CMI074DX_ImportVendorStaff_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
   @Author <Marjorie Gaelo>
   @ModifiedDate <2/2/2015>
   @Version <2.0>
 * Project/Requirement: SPH Integration - CMI074DX Interface
 * @description A test class for BT_AT_CMI074DX_ImportVendorStaff 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_CMI074DX_ImportVendorStaff_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {   
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
            acc.Name = 'CMI074DX';
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Code__c = 'f';
            insert acc;
        List<BT_CO_CMISPOP_ImportVendorStaff__c> interfaceRecordList = new List<BT_CO_CMISPOP_ImportVendorStaff__c>();
        
        BT_CO_CMISPOP_ImportVendorStaff__c interfaceRecord = new BT_CO_CMISPOP_ImportVendorStaff__c();
            interfaceRecord.Name = 'CMI074DX';
            interfaceRecord.fullName__c = 'CMI074DX';
            interfaceRecord.loginId__c = 'b';
            interfaceRecord.nricPassport__c = 'T1234567R';
            interfaceRecord.pagerNumber__c = 'd';
            interfaceRecord.telephoneNumber__c = 'e';
            interfaceRecord.vendorCode__c = 'f';
            interfaceRecord.vendorGroup__c = 'g';
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    static testMethod void testInterfaceApexTrigger2()
    {   
        
        List<BT_CO_CMISPOP_ImportVendorStaff__c> interfaceRecordList = new List<BT_CO_CMISPOP_ImportVendorStaff__c>();
        
        BT_CO_CMISPOP_ImportVendorStaff__c interfaceRecord = new BT_CO_CMISPOP_ImportVendorStaff__c();
            interfaceRecord.Name = 'CMI074DX';
            interfaceRecord.fullName__c = 'CMI074DX';
            interfaceRecord.loginId__c = 'b';
            interfaceRecord.nricPassport__c = 'T1234567R';
            interfaceRecord.pagerNumber__c = 'd';
            interfaceRecord.telephoneNumber__c = 'e';
            interfaceRecord.vendorCode__c = 'f';
            interfaceRecord.vendorGroup__c = 'g';
            
            
            
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
}