/*
 * Class Name: BT_AT_CMI100DX_NumberOfVendor_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - CMI100DX Interface
 * @description A test class for BT_AT_CMI100DX_NumberOfVendorInserts 
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger Test Class
 *          2015/03/10 Michael Francisco modified to use correct data
 */

@isTest
private class BT_AT_CMI100DX_NumberOfVendor_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
    
     Publication__c pub = TestDataFactory.createPublication(1)[0];
                    pub.Publication_Code__c = 'BH';
                    pub.Published_Days__c = 'NNNNNNY';
                    database.insert(pub);
                    
        List<Vendor_Inserts__c> vendorListInsert = new List<Vendor_Inserts__c>();
        Vendor_Inserts__c v = new Vendor_Inserts__c();
        v.Publication_Code__c = 'BH';
        v.Publication_Issue_Date__c = date.newInstance(2007,10,17);
        v.Publication__c = pub.id;
        v.Vendor_Number__c = '0006B';
        v.Number_of_Inserts__c = 47;
        v.Vendor_Group__c = 'A';
        vendorListInsert.add(v);
        insert vendorListInsert;          
                    
        List<BT_CO_CMIS_POP_NumberOfVendorInserts__c> interfaceRecordList = new List<BT_CO_CMIS_POP_NumberOfVendorInserts__c>();
        
        BT_CO_CMIS_POP_NumberOfVendorInserts__c interfaceRecord = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        interfaceRecord.Name = 'CMI100DX';
        interfaceRecord.numberOfInserts__c = '47';
        interfaceRecord.publicationCode__c = 'BH';
        interfaceRecord.publicationIssueDate__c = '17.10.2007';
        interfaceRecord.vendorGroup__c = 'V';
        interfaceRecord.vendorNumber__c = '0006B';
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    static testMethod void testInterfaceApexTrigger1()
    {
    try{
     Publication__c pub = TestDataFactory.createPublication(1)[0];
                    pub.Publication_Code__c = 'BH';
                    pub.Published_Days__c = 'NNNNNNY';
                    database.insert(pub);
                    
        List<Vendor_Inserts__c> vendorListInsert = new List<Vendor_Inserts__c>();
        Vendor_Inserts__c v = new Vendor_Inserts__c();
        v.Publication_Code__c = 'BH';
        v.Publication_Issue_Date__c = date.newInstance(2007,10,17);
        v.Publication__c = pub.id;
        v.Vendor_Number__c = '0006B';
        v.Number_of_Inserts__c = 1;
        v.Vendor_Group__c = 'A';
        vendorListInsert.add(v);
        insert vendorListInsert;            
                            
        List<BT_CO_CMIS_POP_NumberOfVendorInserts__c> interfaceRecordList = new List<BT_CO_CMIS_POP_NumberOfVendorInserts__c>();
        
        BT_CO_CMIS_POP_NumberOfVendorInserts__c interfaceRecord = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        interfaceRecord.Name = 'CMI100DX';
        interfaceRecord.numberOfInserts__c = '47';
        interfaceRecord.publicationCode__c = 'BH1';
        interfaceRecord.Validation_Status__c = 'Passed';
        interfaceRecord.publicationIssueDate__c = '';
        interfaceRecord.vendorGroup__c = 'A';
        interfaceRecord.vendorNumber__c = '0006B';

        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
        }catch (Exception e){
        System.debug(e);
        }
    }
    

    static testMethod void testInterfaceApexTrigger3()
    {
    
     Publication__c pub = TestDataFactory.createPublication(1)[0];
                    pub.Publication_Code__c = 'BH';
                    pub.Published_Days__c = 'NNNNNNY';
                    database.insert(pub);
                    
          
        List<Vendor_Inserts__c> vendorListInsert = new List<Vendor_Inserts__c>();
        Vendor_Inserts__c v = new Vendor_Inserts__c();
        v.Publication_Code__c = 'BH';
        v.Publication_Issue_Date__c = date.newInstance(2007,10,17);
        v.Publication__c = pub.id;
        v.Vendor_Number__c = '0006B';
        v.Number_of_Inserts__c = 1;
        v.Vendor_Group__c = 'A';
        vendorListInsert.add(v);
 
        insert vendorListInsert;   
                    
        List<BT_CO_CMIS_POP_NumberOfVendorInserts__c> interfaceRecordList = new List<BT_CO_CMIS_POP_NumberOfVendorInserts__c>();
        
        BT_CO_CMIS_POP_NumberOfVendorInserts__c interfaceRecord = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        interfaceRecord.Name = '';
        interfaceRecord.numberOfInserts__c = '';
        interfaceRecord.publicationCode__c = '';
        interfaceRecord.Validation_Status__c = '';
        interfaceRecord.publicationIssueDate__c = '';
        interfaceRecord.vendorGroup__c = '';
        interfaceRecord.vendorNumber__c = '';
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    static testMethod void newTest001()
    {
    try{
     Publication__c pub = TestDataFactory.createPublication(1)[0];
                    pub.Publication_Code__c = 'BH';
                    pub.Published_Days__c = 'NNNNNNY';
                    database.insert(pub);
                    
        List<Vendor_Inserts__c> vendorListInsert = new List<Vendor_Inserts__c>();
        Vendor_Inserts__c v = new Vendor_Inserts__c();
        v.Publication_Code__c = 'BH';
        v.Publication_Issue_Date__c = date.newInstance(2007,10,17);
        v.Publication__c = pub.id;
        v.Vendor_Number__c = '';
        v.Number_of_Inserts__c = 47;
        v.Vendor_Group__c = '';
        vendorListInsert.add(v);
        insert vendorListInsert;          
                    
        List<BT_CO_CMIS_POP_NumberOfVendorInserts__c> interfaceRecordList = new List<BT_CO_CMIS_POP_NumberOfVendorInserts__c>();
        
        BT_CO_CMIS_POP_NumberOfVendorInserts__c interfaceRecord = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        interfaceRecord.Name = 'CMI100DX';
        interfaceRecord.numberOfInserts__c = '47';
        //interfaceRecord.publicationCode__c = 'BH';
        interfaceRecord.publicationIssueDate__c = '\\.';
        interfaceRecord.vendorGroup__c = '';
        interfaceRecord.vendorNumber__c = '';
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
        }catch(Exception e){}
    }
    
}