/**
   @Author Val Lu
   @name BT_AB_CMI087DX_ExportVendorToPostalTest
   @CreateDate 02/26/2015
   @Description To test BT_AB_CMI087DX_ExportVendorToPostal class
   @Version <1.0>
  */
@isTest (Seealldata = false)
private class BT_AB_CMI087DX_ExportVendorToPostalTest{  
    /**
    *  To test BT_AB_CMI087DX_ExportVendorToPostal class
    *  @name testBT_AB_CMI087DX_ExportVendorToPostal1
    *  @param none
    *  @return none
    *  @throws na
    */    
    static testmethod void testBT_AB_CMI087DX_ExportVendorToPostal1(){
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;

        List<Account> VendorAccountList =  TestDataFactory.createAccount(1, 'Vendor');
        VendorAccountList[0].Vendor_Name__c = 'Vendor1';
        VendorAccountList[0].Vendor_Group__c = '1';
        VendorAccountList[0].Vendor_Code__c = '1'; 
        insert VendorAccountList;
        
        List<SingPost_Address__c> SingPOstList = TestDataFactory.createSingpostAddress(1);
        SingPOstList[0].Name = 'SGSample';  
        SingPOstList[0].SingPost_Key__c = 'SG1';

        List<Vendor_Allocation__c> VendorAllocationList =  TestDataFactory.createVendorAlloc(1);
        VendorAllocationList[0].SingPost_Address__c =SingPOstList[0].id;
        VendorAllocationList[0].Vendor_Account__c = VendorAccountList[0].id;
        VendorAllocationList[0].Legacy_Created_By__c =  'testuser';
        VendorAllocationList[0].Legacy_Created_Date__c = String.valueOf(date.today());
        VendorAllocationList[0].Legacy_Updated_By__c =  'testuser';
        VendorAllocationList[0].Legacy_Updated_Date__c = String.valueOf(date.today());
        VendorAllocationList[0].Effective_Start_Date__c = date.today();
        VendorAllocationList[0].Allocated__c = true;
        insert VendorAllocationList;
 
        
        Test.StartTest();
        BT_AB_CMI087DX_ExportVendorToPostal batch = new BT_AB_CMI087DX_ExportVendorToPostal();
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        system.assertNotEquals(null, batchprocessid);
        
        Test.StopTest();
        
    }

    /**
    *  To test BT_AB_CMI087DX_ExportVendorToPostal class
    *  @name testBT_AB_CMI087DX_ExportVendorToPostal2
    *  @param none
    *  @return none
    *  @throws na
    */     
    static testmethod void testBT_AB_CMI087DX_ExportVendorToPostal2(){
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;

        List<Account> VendorAccountList =  TestDataFactory.createAccount(1, 'Vendor');
        VendorAccountList[0].Vendor_Name__c = 'Vendor2';
        VendorAccountList[0].Vendor_Group__c = '1';
        VendorAccountList[0].Vendor_Code__c = '1'; 
        insert VendorAccountList;
        
        List<SingPost_Address__c> SingPOstList = TestDataFactory.createSingpostAddress(1);
        SingPOstList[0].Name = null;  
        SingPOstList[0].SingPost_Key__c = 'SG2';
        insert SingPOstList;
        
        List<Vendor_Allocation__c> VendorAllocationList =  TestDataFactory.createVendorAlloc(1);
        VendorAllocationList[0].SingPost_Address__c =SingPOstList[0].id;
        VendorAllocationList[0].Vendor_Account__c = VendorAccountList[0].id;
        VendorAllocationList[0].Legacy_Created_By__c =  'testuser';
        VendorAllocationList[0].Legacy_Created_Date__c = String.valueOf(date.today());
        VendorAllocationList[0].Legacy_Updated_By__c =  'testuser';
        VendorAllocationList[0].Legacy_Updated_Date__c =String.valueOf(date.today());
        VendorAllocationList[0].Effective_Start_Date__c = date.today();
        VendorAllocationList[0].Allocated__c = true;
   
        insert VendorAllocationList;
        
        
        Test.StartTest();
        BT_AB_CMI087DX_ExportVendorToPostal batch = new BT_AB_CMI087DX_ExportVendorToPostal();
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        system.assertNotEquals(null, batchprocessid);
        
        Test.StopTest();
        
    }

    static testmethod void testBT_AB_CMI087DX_ExportVendorToPostal3(){
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;

        List<Account> VendorAccountList =  TestDataFactory.createAccount(1, 'Vendor');
        VendorAccountList[0].Vendor_Name__c = 'Vendor2';
        VendorAccountList[0].Vendor_Group__c = null;
        VendorAccountList[0].Vendor_Code__c = null; 
        insert VendorAccountList;
        
        List<SingPost_Address__c> SingPOstList = TestDataFactory.createSingpostAddress(1);
        SingPOstList[0].Name = null;  
        SingPOstList[0].SingPost_Key__c = 'SG2';
        insert SingPOstList;
        
        List<Vendor_Allocation__c> VendorAllocationList =  TestDataFactory.createVendorAlloc(1);
        VendorAllocationList[0].SingPost_Address__c =SingPOstList[0].id;
        VendorAllocationList[0].Vendor_Account__c = VendorAccountList[0].id;
        VendorAllocationList[0].Legacy_Created_By__c =  'testuser';
        VendorAllocationList[0].Legacy_Created_Date__c = String.valueOf(date.today());
        VendorAllocationList[0].Legacy_Updated_By__c =  'testuser';
        VendorAllocationList[0].Legacy_Updated_Date__c =String.valueOf(date.today());
        VendorAllocationList[0].Effective_Start_Date__c = date.today();
        VendorAllocationList[0].Allocated__c = true;
   
        insert VendorAllocationList;
        
        
        Test.StartTest();
        BT_AB_CMI087DX_ExportVendorToPostal batch = new BT_AB_CMI087DX_ExportVendorToPostal();
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        system.assertNotEquals(null, batchprocessid);
        
        Test.StopTest();
    }
    
}