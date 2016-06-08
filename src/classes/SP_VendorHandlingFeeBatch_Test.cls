/**
   @Author Joy Suarez
   @name SP_VendorHandlingFeeBatch_Test
   @CreateDate 02/04/2015
   @Description Test class for SP_VendorHandlingFeeBatch
   @Version <1.0>
   @reference 
*/

@isTest(seeAllData=False)

private class SP_VendorHandlingFeeBatch_Test{
    /**
    *  To test SP_VendorHandlingFeeBatch
    *  @name testSP_VendorHandlingFeeBatch
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testSP_VendorHandlingFeeBatch(){
    
    Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
    acct.Vendor_Group__c = 'V';
    acct.AccountNumber = '30017';
    insert acct;
    
    Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNNY',
        Publication_Type__c = '2'   
    );
    insert pub;
    system.assertNotEquals(null, pub);    
   
    Vendor_POP_Batch__c vPOPBatch = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acct.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20
    );
    insert vPOPBatch;
    
    Publication_Daily_Issue_Data__c pubDailyIssueData = new Publication_Daily_Issue_Data__c(
        Name = 'Sample Pub Daily Issue Data',
        Publication_Code__c = vPOPBatch.Publication_Code__c, 
        Publication_Issue_Date__c = vPOPBatch.Publication_Issue_Date__c, 
        Consolidation_Date__c = Date.today(),
        Order_Closed_Indicator__c = 'Y',
        Publication__c = pub.Id,
        Pagination__c = 6   
    );
    insert pubDailyIssueData;
    
    Vendor_Inserts__c vendorInserts = new Vendor_Inserts__c(
        Name = 'Sample Vendor Insert',
        Publication_Code__c = vPOPBatch.Publication_Code__c, 
        Publication_Issue_Date__c = vPOPBatch.Publication_Issue_Date__c,
        Vendor_Group__c = 'V',
        Number_of_Inserts__c = 6,
        Insert_Value__c = 10,
        Vendor_Number__c = acct.AccountNumber,
        Publication__c = pub.Id
    );
    insert vendorInserts;
    
    List<Vendor_Monthly_Data__c> vmdList = new List<Vendor_Monthly_Data__c>();  
    Vendor_Monthly_Data__c vMonthlyData = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch.Vendor_Number__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee'        
    );
    
    Vendor_Monthly_Data__c vMonthlyData2 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch.Vendor_Number__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee'        
    );
    
     Vendor_Monthly_Data__c vMonthlyData3 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch.Vendor_Number__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee'        
    );
    
    vmdList.add(vMonthlyData);
    vmdList.add(vMonthlyData2);
    vmdList.add(vMonthlyData3);
    insert vmdList;
    
     Test.StartTest();
         SP_VendorHandlingFeeBatch batch = new SP_VendorHandlingFeeBatch();
         ID batchprocessid = Database.executeBatch(batch, 200);
     Test.StopTest();
        
    
    }//END testMethod testSP_VendorHandlingFeeBatch
    /**
    *  To test SP_VendorHandlingFeeBatch
    *  @name testSP_VendorHandlingFeeBatch2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testSP_VendorHandlingFeeBatch2(){

    Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acct.Vendor_Group__c = 'V';
        acct.AccountNumber = '30017';
    insert acct;

    Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNNY',
        Publication_Type__c = '2'   
    );
    insert pub;
    system.assertNotEquals(null, pub);  
    
    List<Vendor_POP_Batch__c> vpbList = new List<Vendor_POP_Batch__c>();
    Vendor_POP_Batch__c vPOPBatch = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acct.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20
    );
    Vendor_POP_Batch__c vPOPBatch2 = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = '34234234',
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20
    );
    vpbList.add(vPOPBatch);
    vpbList.add(vPOPBatch2);
    insert vpbList ;
    
    Publication_Daily_Issue_Data__c pubDailyIssueData = new Publication_Daily_Issue_Data__c(
        Name = 'Sample Pub Daily Issue Data',
        Publication_Code__c = vPOPBatch.Publication_Code__c, 
        Publication_Issue_Date__c = vPOPBatch.Publication_Issue_Date__c, 
        Consolidation_Date__c = Date.today(),
        Order_Closed_Indicator__c = 'Y',
        Publication__c = pub.Id,
        Pagination__c = 6   
    );
    insert pubDailyIssueData;
    
    Vendor_Inserts__c vendorInserts = new Vendor_Inserts__c(
        Name = 'Sample Vendor Insert',
        Publication_Code__c = vPOPBatch.Publication_Code__c, 
        Publication_Issue_Date__c = vPOPBatch.Publication_Issue_Date__c, 
        Vendor_Group__c = 'V',
        Number_of_Inserts__c = 6,
        Insert_Value__c = 10,
        Vendor_Number__c = acct.AccountNumber,
        Publication__c = pub.Id
    );
    insert vendorInserts;
     Test.StartTest();
  
         SP_VendorHandlingFeeBatch batch = new SP_VendorHandlingFeeBatch();
         ID batchprocessid = Database.executeBatch(batch, 200);
     Test.StopTest();
    
    }//END testMethod testSP_VendorHandlingFeeBatch2
    
    /**
    *  To test SP_VendorHandlingFeeBatch
    *  @name testSP_VendorHandlingFeeBatch3
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testSP_VendorHandlingFeeBatch3(){
    
    //insert test data
    Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acct.Vendor_Group__c = 'V';
        acct.AccountNumber = '30017';
    insert acct;

    Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNNY',
        Publication_Type__c = '2'   
    );
    insert pub;
    system.assertNotEquals(null, pub);  
    
    List<Vendor_POP_Batch__c> vpbList = new List<Vendor_POP_Batch__c>();
    Vendor_POP_Batch__c vPOPBatch = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acct.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20
    );
    Vendor_POP_Batch__c vPOPBatch2 = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = '34234234',
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20
    );
    vpbList.add(vPOPBatch);
    vpbList.add(vPOPBatch2);
    insert vpbList ;
    
    Publication_Daily_Issue_Data__c pubDailyIssueData = new Publication_Daily_Issue_Data__c(
        Name = 'Sample Pub Daily Issue Data',
        Publication_Code__c = vPOPBatch.Publication_Code__c,
        Publication_Issue_Date__c = vPOPBatch.Publication_Issue_Date__c, 
        Consolidation_Date__c = Date.today(),
        Order_Closed_Indicator__c = 'Y',
        Publication__c = pub.Id,
        Pagination__c = 6   
    );
    insert pubDailyIssueData;
    
    Vendor_Inserts__c vendorInserts = new Vendor_Inserts__c(
        Name = 'Sample Vendor Insert',
        Publication_Code__c = vPOPBatch.Publication_Code__c,
        Publication_Issue_Date__c = vPOPBatch.Publication_Issue_Date__c, 
        Vendor_Group__c = 'V',
        Number_of_Inserts__c = 6,
        Insert_Value__c = 10,
        Vendor_Number__c = acct.AccountNumber,
        Publication__c = pub.Id
    );
    insert vendorInserts;
    
    
     Test.StartTest();
         SP_VendorHandlingFeeBatch batch = new SP_VendorHandlingFeeBatch();
         ID batchprocessid = Database.executeBatch(batch, 200);
     Test.StopTest();
    
    }//END testMethod testSP_VendorHandlingFeeBatch3
    /**
    *  To test SP_VendorHandlingFeeBatch
    *  @name testSP_VendorHandlingFeeBatch4
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testSP_VendorHandlingFeeBatch4(){

        User u = TestDataFactory.prepareTestusers('CSO');
        
        System.runAs(u) {
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.AccountNumber = '30017';
        insert acc;

        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        insert pack;
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '123457397';
        key.Type__c = 'Number';
        insert key; 
        */
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: 'Customer Contact' LIMIT 1];
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.RecordTypeId = rt.Id;
        con.Recipient_Indicator__c = true; 
        insert con;

        
        
        zqu__ProductRatePlanCharge__c newRatePlan = TestDataFactory.createProductRatePlanCharge(1)[0];
        newRatePlan.Name = 'Admin Charge';
        newRatePlan.zqu__Deleted__c = false;
        newRatePlan.zqu__ZuoraId__c = 'Zuora1';
        insert newRatePlan;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
            
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        
         List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Name = 'ZS001';
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
            }
            try{
            Test.startTest();
            insert subRecs;
            }catch(exception e){}
    Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNNY',
        Publication_Type__c = '2'   
    );
    insert pub;
    system.assertNotEquals(null, pub);  
    
    List<Vendor_POP_Batch__c> vPOPList = new List<Vendor_POP_Batch__c>();
    Vendor_POP_Batch__c vPOPBatch1 = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acc.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20,
        Subscription_Name__c = subRecs[0].Name
    );
    Vendor_POP_Batch__c vPOPBatch2 = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acc.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20,
        Subscription_Name__c = subRecs[0].Name
    );
    Vendor_POP_Batch__c vPOPBatch3 = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acc.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20,
        Subscription_Name__c = subRecs[0].Name
    );
    
    
    vPOPList.add(vPOPBatch1);
    vPOPList.add(vPOPBatch2);
    vPOPList.add(vPOPBatch3);
    insert vPOPList;
    
    Publication_Daily_Issue_Data__c pubDailyIssueData = new Publication_Daily_Issue_Data__c(
        Name = 'Sample Pub Daily Issue Data',
        Publication_Code__c = vPOPBatch1.Publication_Code__c,
        Publication_Issue_Date__c = vPOPBatch1.Publication_Issue_Date__c, 
        Consolidation_Date__c = Date.today(),
        Order_Closed_Indicator__c = 'Y',
        Publication__c = pub.Id,
        Pagination__c = 6
    );
    insert pubDailyIssueData;
    
    Vendor_Inserts__c vendorInserts = new Vendor_Inserts__c(
        Name = 'Sample Vendor Insert',
        Publication_Code__c = vPOPBatch1.Publication_Code__c, 
        Publication_Issue_Date__c = vPOPBatch1.Publication_Issue_Date__c, 
        Vendor_Group__c = 'V',
        Number_of_Inserts__c = 6,
        Insert_Value__c = 10,
        Vendor_Number__c = acc.AccountNumber,
        Publication__c = pub.Id
    );
    insert vendorInserts;
      
    List<Vendor_Monthly_Data__c> vmdList = new List<Vendor_Monthly_Data__c>();
    Vendor_Monthly_Data__c vMonthlyData = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch1.Vendor_Number__c, 
        Publication_Code__c = vPOPBatch1.Publication_Code__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );
    Vendor_Monthly_Data__c vMonthlyData2 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch1.Vendor_Number__c, 
        Publication_Code__c = 'AST',
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );
    Vendor_Monthly_Data__c vMonthlyData3 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 44,
        Vendor_Number__c = vPOPBatch1.Vendor_Number__c,  
        Publication_Code__c = vPOPBatch1.Publication_Code__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );

    vmdList.add(vMonthlyData);
    vmdList.add(vMonthlyData2);
    vmdList.add(vMonthlyData3);   
    insert vmdList;
    Test.stopTest();

        
    Database.executebatch(new SP_VendorHandlingFeeBatch());
    
    }//END testMethod testSP_VendorHandlingFeeBatch4
    }
    /**
    *  To test SP_VendorHandlingFeeBatch
    *  @name testSP_VendorHandlingFeeBatch5
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testSP_VendorHandlingFeeBatch5(){

        User u = TestDataFactory.prepareTestusers('CSO');
        
        System.runAs(u) {
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.AccountNumber = '30017';
        insert acc;

        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        insert pack;
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '123457397';
        key.Type__c = 'Number';
        insert key; 
        */
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: 'Customer Contact' LIMIT 1];
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.RecordTypeId = rt.Id;
        con.Recipient_Indicator__c = true; 
        insert con;

        
        
        zqu__ProductRatePlanCharge__c newRatePlan = TestDataFactory.createProductRatePlanCharge(1)[0];
        newRatePlan.Name = 'Admin Charge';
        newRatePlan.zqu__Deleted__c = false;
        newRatePlan.zqu__ZuoraId__c = 'Zuora1';
        insert newRatePlan;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
            
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        
         List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Name = 'ZS001';
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
            }
            try{
            Test.startTest();
            insert subRecs;
            }catch(exception e){}

    Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNNY',
        Publication_Type__c = '2'   
    );
    insert pub;
    system.assertNotEquals(null, pub);  
    
    List<Vendor_POP_Batch__c> vPOPList = new List<Vendor_POP_Batch__c>();
    Vendor_POP_Batch__c vPOPBatch1 = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acc.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20,
        Subscription_Name__c = 'TestSub'
    );
    Vendor_POP_Batch__c vPOPBatch2 = new Vendor_POP_Batch__c(
        Publication_Code__c = 'AS',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acc.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20,
        Subscription_Name__c = 'TestSub'
    );
    Vendor_POP_Batch__c vPOPBatch3 = new Vendor_POP_Batch__c(
        Publication_Code__c = 'AS',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acc.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20
    );
    
    
    vPOPList.add(vPOPBatch1);
    vPOPList.add(vPOPBatch2);
    vPOPList.add(vPOPBatch3);
    insert vPOPList;
    
    Publication_Daily_Issue_Data__c pubDailyIssueData = new Publication_Daily_Issue_Data__c(
        Name = 'Sample Pub Daily Issue Data',
        Publication_Code__c = vPOPBatch1.Publication_Code__c,
        Publication_Issue_Date__c = vPOPBatch1.Publication_Issue_Date__c, 
        Consolidation_Date__c = Date.today(),
        Order_Closed_Indicator__c = 'Y',
        Publication__c = pub.Id,
        Pagination__c = 6
    );
    insert pubDailyIssueData;
    
    Vendor_Inserts__c vendorInserts = new Vendor_Inserts__c(
        Name = 'Sample Vendor Insert',
        Publication_Code__c = vPOPBatch1.Publication_Code__c, 
        Publication_Issue_Date__c = vPOPBatch1.Publication_Issue_Date__c, 
        Vendor_Group__c = 'V',
        Number_of_Inserts__c = 6,
        Insert_Value__c = 10,
        Vendor_Number__c = acc.AccountNumber,
        Publication__c = pub.Id
    );
    insert vendorInserts;
      
    List<Vendor_Monthly_Data__c> vmdList = new List<Vendor_Monthly_Data__c>();
    Vendor_Monthly_Data__c vMonthlyData = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch1.Vendor_Number__c, 
        Publication_Code__c = vPOPBatch1.Publication_Code__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );
    Vendor_Monthly_Data__c vMonthlyData2 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch1.Vendor_Number__c, 
        Publication_Code__c = 'AST',
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );
    Vendor_Monthly_Data__c vMonthlyData3 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 44,
        Vendor_Number__c = vPOPBatch1.Vendor_Number__c,  
        Publication_Code__c = vPOPBatch1.Publication_Code__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );
    Vendor_Monthly_Data__c vMonthlyData4 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch2.Vendor_Number__c, 
        Publication_Code__c = vPOPBatch2.Publication_Code__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );
    Vendor_Monthly_Data__c vMonthlyData5 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch2.Vendor_Number__c, 
        Publication_Code__c = 'AST',
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );
    Vendor_Monthly_Data__c vMonthlyData6 = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 44,
        Vendor_Number__c = vPOPBatch2.Vendor_Number__c,  
        Publication_Code__c = vPOPBatch1.Publication_Code__c,
        Credit_Debit__c = 'Credit',
        Amount_Type__c = 'Handling Fee',
        Subscription__c = subRecs[0].Id
    );

    vmdList.add(vMonthlyData);
    vmdList.add(vMonthlyData2);
    vmdList.add(vMonthlyData3);   
    vmdList.add(vMonthlyData4);
    vmdList.add(vMonthlyData5);
    vmdList.add(vMonthlyData6); 
    insert vmdList;
    Test.stopTest();

        
    Database.executebatch(new SP_VendorHandlingFeeBatch());
    
    }//END testMethod testSP_VendorHandlingFeeBatch5
    }

}//END SP_VendorHandlingFeeBatchTest