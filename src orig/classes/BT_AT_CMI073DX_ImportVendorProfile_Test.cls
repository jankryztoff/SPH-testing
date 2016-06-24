/*
 * Class Name: BT_AT_CMI073DX_ImportVendorProfile_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - CMI073DX Interface
 * @description A test class for BT_AT_CMI073DX_ImportVendorProfile 
 *
 * History:
 * 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 * 02/07/2015 Michelle Tumbaga updated test class to add record insert for Account, Singpost_Address__c and Contact
 */

@isTest
private class BT_AT_CMI073DX_ImportVendorProfile_Test {   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 

    static testMethod void testInterfaceApexTrigger() {
        //instantiate record creation -- Start
        List<BT_CO_CMISPOP_ImportVendorProfile__c> interfaceRecordList = new List<BT_CO_CMISPOP_ImportVendorProfile__c>();
        List <Singpost_Address__c> postAdd = TestDataFactory.createSingpostAddress(1);
        List <Account> testAccount = TestDataFactory.createAccount(1, 'Vendor');        
        //List <Contact> testContact = TestDataFactory.createContactRecType(1, 'Vendor Contact');        
        //instantiate record creation -- End
    
        insert postAdd;
        
        Test.StartTest();

        //set ImportVendorProfile fields without Vendor Name -- Start
        BT_CO_CMISPOP_ImportVendorProfile__c interfaceRecord = new BT_CO_CMISPOP_ImportVendorProfile__c();
        interfaceRecord.Name = 'CMI073DX';
        interfaceRecord.vendorCode__c = 'Code1';
        interfaceRecord.vendorGroup__c = 'G';
        //set ImportVendorProfile fields without Vendor Name -- End
        
        interfaceRecordList.add(interfaceRecord);

        //set ImportVendorProfile fields without Postal Code -- Start
        interfaceRecord.Name = 'CMI073DX';
        interfaceRecord.vendorCode__c = 'Code1';
        interfaceRecord.vendorGroup__c = 'G';
        interfaceRecord.vendorName__c = 'Test Vendor Name';
        //set ImportVendorProfile fields without Postal Code -- End
        
        interfaceRecordList.add(interfaceRecord);
        
        //set ImportVendorProfile fields -- Start
        interfaceRecord.Name = 'CMI073DX';
        interfaceRecord.vendorCode__c = 'Code1';
        interfaceRecord.vendorGroup__c = 'G';
        interfaceRecord.vendorName__c = 'Test Vendor Name';
        interfaceRecord.vendorStatus__c = '1';
        interfaceRecord.vendorType__c = 'TY';
        interfaceRecord.zoneCode__c = '2';
        interfaceRecord.postalCode__c = postAdd[0].Name;
        interfaceRecord.blockHouseNumber__c = 'block1';
        interfaceRecord.buildingName__c = 'Building Name';
        interfaceRecord.email__c = 'testemail@sph.com.sg';
        interfaceRecord.faxNumber__c = '654-3210';
        interfaceRecord.gstRegistrationNumber__c = 'Registration12345';
        interfaceRecord.handphoneNumber__c = '654-3210';
        interfaceRecord.level__c = 'LV1';
        interfaceRecord.nricPassport__c = 'NRIC123';
        interfaceRecord.pagerNumber__c = '6543-210-98';
        interfaceRecord.registeredName__c = 'Test REG Name';
        interfaceRecord.streetName__c = '888';
        interfaceRecord.telephoneOffice__c = '654-3210';
        interfaceRecord.telephoneResidence__c = '654-3210';
        interfaceRecord.unitNumber__c = '1234';
        //set ImportVendorProfile fields -- End
        
        interfaceRecordList.add(interfaceRecord);

        insert testAccount;

        //Set Contact fields -- Start
        /*for(Contact cont: testContact) {
            cont.Recipient_Indicator__c = TRUE;
            cont.AccountId = testAccount[0].Id;
        } //Set Contact fields -- End
        
        insert testContact;*/
        
        //match the Account fields with ImportVendorProfile fields on Account update
        //update Account -- Start
        testAccount[0].Vendor_Type__c  = interfaceRecordList[2].vendorType__c;
        testAccount[0].Vendor_Group__c  = interfaceRecordList[2].vendorGroup__c;
        testAccount[0].Zone_Code__c  = interfaceRecordList[2].zoneCode__c;
        //testAccount[0].NRIC__c  = interfaceRecordList[2].nricPassport__c;
        //testAccount[0].Registered_Name__c  = interfaceRecordList[2].registeredName__c;
        testAccount[0].Unit_Number__c  = interfaceRecordList[2].unitNumber__c;
        testAccount[0].Level_Number__c  = interfaceRecordList[2].level__c;
        testAccount[0].House_Block_Number__c  = interfaceRecordList[2].blockHouseNumber__c;
        testAccount[0].Street_Name__c  = interfaceRecordList[2].streetName__c;
        testAccount[0].Building_Name__c  = interfaceRecordList[2].buildingName__c;
        testAccount[0].PostalCode__c  = interfaceRecordList[2].postalCode__c;
        testAccount[0].Telephone_Residence__c  = interfaceRecordList[2].telephoneResidence__c;
        testAccount[0].Telephone_Office__c  = interfaceRecordList[2].telephoneOffice__c;
        //testAccount[0].Email__c  = interfaceRecordList[2].email__c;
        testAccount[0].GST_Registration_Number__c  = interfaceRecordList[2].gstRegistrationNumber__c;
        //update Account -- End
        
        update testAccount;

        //match the Account fields with ImportVendorProfile fields on Account create
        //insert Account -- Start
        list<Account> testAccount2 = TestDataFactory.createAccount(1, 'Vendor');
            testAccount2[0].Vendor_Type__c  = interfaceRecordList[2].vendorType__c;
            testAccount2[0].Vendor_Group__c  = interfaceRecordList[2].vendorGroup__c;
            testAccount2[0].Zone_Code__c  = interfaceRecordList[2].zoneCode__c;
            //testAccount2.NRIC__c  = interfaceRecordList[2].nricPassport__c;
            //testAccount2.Registered_Name__c  = interfaceRecordList[2].registeredName__c;
            testAccount2[0].Unit_Number__c  = interfaceRecordList[2].unitNumber__c;
            testAccount2[0].Level_Number__c  = interfaceRecordList[2].level__c;
            testAccount2[0].House_Block_Number__c  = interfaceRecordList[2].blockHouseNumber__c;
            testAccount2[0].Street_Name__c  = interfaceRecordList[2].streetName__c;
            testAccount2[0].Building_Name__c  = interfaceRecordList[2].buildingName__c;
            testAccount2[0].PostalCode__c  = interfaceRecordList[2].postalCode__c;
            testAccount2[0].Telephone_Residence__c  = interfaceRecordList[2].telephoneResidence__c;
            testAccount2[0].Telephone_Office__c  = interfaceRecordList[2].telephoneOffice__c;
            //testAccount2.Email__c  = interfaceRecordList[2].email__c;
            testAccount2[0].GST_Registration_Number__c  = interfaceRecordList[2].gstRegistrationNumber__c;
        //insert Account -- End
        
        insert testAccount2;
        Test.StopTest();
    }
}