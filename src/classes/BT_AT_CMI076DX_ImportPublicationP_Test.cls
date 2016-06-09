/*
 * Class Name: BT_AT_CMI076DX_ImportPublicationP_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - CMI076DX Interface
 * @description A test class for BT_AT_CMI076DX_ImportPublicationPrice 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest (seealldata=true)
private class BT_AT_CMI076DX_ImportPublicationP_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '1003';
        pub.Published_Days__c = 'NNNNNNN';
        pub.Publication_Type__c = 'n';        
        insert pub; 
        system.assertNotEquals(null, pub);
         
        Publication_Price__c pr = TestDataFactory.createPublicationPrice(1)[0]; 
        pr.Publication__c = pub.Id;
        pr.Publication_Code__c = '1003';
        insert pr;    
           
                
        List<BT_CO_CMIS_POP_ImportPublicationPrice__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicationPrice__c>();
        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord.Name = 'CMI076DX';
        interfaceRecord.coverPrice__c = '100';
        interfaceRecord.effectiveDate__c = '11.04.2014';
        interfaceRecord.publicationCode__c = '1003';
        interfaceRecord.salesType__c = 'd';
        interfaceRecord.dayOfWeek__c = '9';           
        interfaceRecordList.add(interfaceRecord);
        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord2 = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord2.Name = 'CMI076DX';
        interfaceRecord2.coverPrice__c = '100';
        interfaceRecord2.effectiveDate__c = '11.04.2014';
        interfaceRecord2.publicationCode__c = '1003';
        interfaceRecord2.salesType__c = 'd';
        interfaceRecord2.dayOfWeek__c = '9';           
        interfaceRecordList.add(interfaceRecord2);
        
       /* BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord3 = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord2.Name = 'CMI076DX';
        interfaceRecord2.coverPrice__c = '100';
        interfaceRecord2.effectiveDate__c = '11.04.2014';
        interfaceRecord2.publicationCode__c = '1003';
        interfaceRecord2.salesType__c = 'd';
        interfaceRecord2.dayOfWeek__c = '9';           
        interfaceRecordList.add(interfaceRecord3);*/
            
        Test.startTest();
        insert interfaceRecordList;
        //system.assertEquals(null, interfaceRecordList);      
        Test.stopTest();
        
        
    }
     /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger2()
    {
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '1003';
        pub.Published_Days__c = 'NNNNNNN';
        pub.Publication_Type__c = 'n';        
        insert pub; 
        system.assertNotEquals(null, pub);
         
        Publication_Price__c pr = TestDataFactory.createPublicationPrice(1)[0]; 
        pr.Publication__c = pub.Id;        
        pr.Publication_Code__c = pub.Publication_Code__c ;
        pr.Effective_Date__c = date.Newinstance(2014, 04, 11);
        pr.Day_of_Week__c = '1';
        pr.Sales_Type__c = 'n';
        pr.Cover_Price__c = 100;
        insert pr;        
            
        List<BT_CO_CMIS_POP_ImportPublicationPrice__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicationPrice__c>();
        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord.Name = 'CMI076DX';
        interfaceRecord.coverPrice__c = '100';
        interfaceRecord.effectiveDate__c = '11.04.2014';
        interfaceRecord.publicationCode__c = pr.Publication_Code__c;
        interfaceRecord.salesType__c = pr.Sales_Type__c;
        interfaceRecord.dayOfWeek__c = pr.Day_of_Week__c;   
        
        interfaceRecordList.add(interfaceRecord);
        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord2= new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord2.Name = 'CMI076DX';
        interfaceRecord2.coverPrice__c = '100';
        interfaceRecord2.effectiveDate__c = '11.04.2014';
        interfaceRecord2.publicationCode__c = pr.Publication_Code__c;
        interfaceRecord2.salesType__c = pr.Sales_Type__c;
        interfaceRecord2.dayOfWeek__c = pr.Day_of_Week__c;    
        
        interfaceRecordList.add(interfaceRecord2);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
     /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger3()
    {
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '1004';
        pub.Published_Days__c = 'NNNNNNN';
        pub.Publication_Type__c = 'n';        
        insert pub; 
        system.assertNotEquals(null, pub);
         
        Publication_Price__c pr = TestDataFactory.createPublicationPrice(1)[0]; 
        pr.Publication__c = pub.Id;        
        pr.Publication_Code__c = '1004';
        insert pr;        
            
        List<BT_CO_CMIS_POP_ImportPublicationPrice__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicationPrice__c>();
        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord.Name = 'CMI076DX';
        interfaceRecord.coverPrice__c = '100';
        interfaceRecord.effectiveDate__c = '11.03.2014';
        interfaceRecord.publicationCode__c = '1005';
        interfaceRecord.salesType__c = 'n';
        interfaceRecord.dayOfWeek__c = '1';   
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
     /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger4()
    {
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '1004';
        pub.Published_Days__c = 'NNNNNNN';
        pub.Publication_Type__c = 'n';        
        insert pub; 
        system.assertNotEquals(null, pub);
         
        Publication_Price__c pr = TestDataFactory.createPublicationPrice(1)[0]; 
        pr.Publication__c = pub.Id;        
        pr.Publication_Code__c = '1004';
        insert pr;        
            
        List<BT_CO_CMIS_POP_ImportPublicationPrice__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicationPrice__c>();
        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord.Name = 'CMI076DX';
        interfaceRecord.coverPrice__c = '';
        interfaceRecord.effectiveDate__c = '01.01.0000';
        interfaceRecord.publicationCode__c = '';
        interfaceRecord.salesType__c = 'n';
        interfaceRecord.dayOfWeek__c = '1';   
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
     /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
        static testMethod void testInterfaceApexTrigger5()
    {
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '1004';
        pub.Published_Days__c = 'NNNNNNN';
        pub.Publication_Type__c = 'n';        
        insert pub; 
        system.assertNotEquals(null, pub);
         
        Publication_Price__c pr = TestDataFactory.createPublicationPrice(1)[0]; 
        pr.Publication__c = pub.Id;        
        pr.Publication_Code__c = '1004';
        insert pr;        
            

        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord.Name = 'CMI076DX';
        interfaceRecord.effectiveDate__c = '01.01.0000';
        interfaceRecord.salesType__c = 'n';
        interfaceRecord.dayOfWeek__c = '1';   

        Test.startTest();
        insert interfaceRecord;
        Test.stopTest();
    }    
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger6()
    {
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '1003';
        pub.Published_Days__c = 'NNNNNNN';
        pub.Publication_Type__c = 'n';        
        insert pub; 
        system.assertNotEquals(null, pub);
         
        Publication_Price__c pr = TestDataFactory.createPublicationPrice(1)[0]; 
        pr.Publication__c = pub.Id;        
        pr.Publication_Code__c = pub.Publication_Code__c ;
        pr.Effective_Date__c = date.Newinstance(2014, 11, 04);
        pr.Day_of_Week__c = '1';
        pr.Sales_Type__c = 'n';
        pr.Cover_Price__c = 100;
        insert pr;        
            
        List<BT_CO_CMIS_POP_ImportPublicationPrice__c> interfaceRecordList = new List<BT_CO_CMIS_POP_ImportPublicationPrice__c>();
        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord.Name = 'CMI076DX';
        interfaceRecord.coverPrice__c = '100';
        interfaceRecord.effectiveDate__c = '11.04.2014';
        interfaceRecord.publicationCode__c = pr.Publication_Code__c;
        interfaceRecord.salesType__c = pr.Sales_Type__c;
        interfaceRecord.dayOfWeek__c = pr.Day_of_Week__c;   
        
        interfaceRecordList.add(interfaceRecord);
        
        BT_CO_CMIS_POP_ImportPublicationPrice__c interfaceRecord2= new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        interfaceRecord2.Name = 'CMI076DX';
        interfaceRecord2.coverPrice__c = '100';
        interfaceRecord2.effectiveDate__c = '11.04.2014';
        interfaceRecord2.publicationCode__c = pr.Publication_Code__c;
        interfaceRecord2.salesType__c = pr.Sales_Type__c;
        interfaceRecord2.dayOfWeek__c = pr.Day_of_Week__c;    
        
        interfaceRecordList.add(interfaceRecord2);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }

}