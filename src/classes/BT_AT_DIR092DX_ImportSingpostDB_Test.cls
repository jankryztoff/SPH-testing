/*
 * Class Name: BT_AT_DIR092DX_ImportSingpostDB_Test
 * @author: Accenture IDC
 * Date: 16/02/2015
   @Author Shruti Kishore
   @Version <2.0>
 * Project/Requirement: SPH Integration - CMI074DX Interface
 * @description A test class for BT_AT_DIR092DX_ImportSingpostDatabase
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */
 
@isTest(seeallData=true)
private class BT_AT_DIR092DX_ImportSingpostDB_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testWithFalse()
    {   
    Test.startTest();
        Singpost_Address__c address = TestDataFactory.createSingpostAddress(1)[0];
            
            address.Address_Type_Overridden__c = false;
            address.SingPost_Key__c= '01919131';
            address.Building__c=false;
            address.Street_Name_Overriden__c= false ;
            address.Street_Name__c = 'dhwdw';
            insert address;
        
        List<BT_CO_DIR_ImportSingpostDatabase__c> interfaceRecordList = new List<BT_CO_DIR_ImportSingpostDatabase__c>();
        BT_CO_DIR_ImportSingpostDatabase__c interfaceRecord = new BT_CO_DIR_ImportSingpostDatabase__c();
        interfaceRecord.postalCode__c='';
        interfaceRecord.AddressType__c = '';
        interfaceRecord.buildingNo__c = '';
        interfaceRecord.StreetKey__c = '';
        interfaceRecord.streetName__c = '';
        interfaceRecord.Validation_Status__c = 'Failed';
        interfaceRecord.Validation_Details__c =' Values cannot be null';
        interfaceRecordList.add(interfaceRecord);
        insert interfaceRecordList;
       
        Test.stopTest();
    }
 
    static testMethod void testInterfaceApexTriggerInsert()
    {   
       
        Test.startTest();
   
            BT_CO_DIR_ImportSingpostDatabase__c sop = new BT_CO_DIR_ImportSingpostDatabase__c();
            sop.buildingNo__c = '123';
            sop.streetName__c = 'manhatton';
            sop.buildingName__c = 'White House';
            sop.postalCode__c = '345';
            sop.buildingCode__c = '123';
            sop.floor__c ='4';
            sop.unit__c= '5';
            sop.SingpostKey__c= '1200|1';
            sop.buildingDescription__c= 'fgh';
            sop.AddressType__c= 'r';
            sop.NumberOfUnits__c = 4;
            sop.StreetKey__c = '6';
            sop.ServiceNumber__c = '9';
            sop.WalkupIndicator__c = 'H';
            sop.postalCodeImageBase64__c = 'dsds';
            insert sop;

        
        Test.stopTest();
    }

    
       static testMethod void testInterfaceApexTriggerUpdate()
    {   
        String singPostKey = '018936|7';
        Test.startTest();
       
        
            BT_CO_DIR_ImportSingpostDatabase__c sop = new BT_CO_DIR_ImportSingpostDatabase__c();
            sop.buildingNo__c = '123';
            sop.streetName__c = 'manhatton';
            sop.buildingName__c = 'White House';
            sop.postalCode__c = '345';
            sop.buildingCode__c = '123';
            sop.floor__c ='4';
            sop.unit__c= '5';
            sop.SingpostKey__c= singPostKey;
            sop.buildingDescription__c= 'fgh';
            sop.AddressType__c= 'r';
            sop.NumberOfUnits__c = 4;
            sop.StreetKey__c = '6';
            sop.ServiceNumber__c = '9';
            sop.WalkupIndicator__c = 'H';
            sop.postalCodeImageBase64__c = 'dsds';
            insert sop;

        
        Test.stopTest();
    }
  
 }