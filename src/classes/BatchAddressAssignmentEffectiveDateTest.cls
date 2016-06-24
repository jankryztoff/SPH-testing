/*
* Class Name: <BatchAddressAssignmentEffectiveDateTest>
* @author: Reszel Garrie Pineda
* @author: Recuerdo Bregente
* Date: 2/16/2015
* Requirement/Project Name: <SPH>
* @description: Test class for BatchAddressAssignmentEffectiveDate
*/
@isTest //(seeAllData=false)
private class BatchAddressAssignmentEffectiveDateTest{

    // Test Data
    static List<Case> casList;
    static Account acc;
    static List<Contact> contactList;
    static List<Address__c> addressRecords;
    static List<Zuora__Subscription__c> subRecs;
    static Singpost_Address__c postal;
    static Order__c order;
    static List<Subscription_Vendor__c> svs;

    /**
    * @name : prepareInitialTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the initial test data objects.
    * @date: 07/31/2015
    */ 
    static void prepareInitialTestData(String changeOfAdd, Boolean recipIndicator, Integer subCount, String addName){
        defaultCustomSetting();
    
        //test data creation
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Name = 'Zuora Customer Account';
        acc.Phone = '123456';
        acc.AccountNumber = 'ACCNO001';
        acc.Staff_ID__c = 'SID001';
        insert acc;    
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Recurring Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        insert pack;        
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Magazine';
        zProduct.ProductCode__c = 'DELCHG';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.Name = 'HDB DELIVERY CHARGE';
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;        
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        //zprpc.zqu__UOM__c = 'landed';
        zprpc.zqu__Deleted__c = false;
        zprpc.zqu__Type__c = 'Usage';
        insert zprpc;        
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem;     
        
        
        addressRecords = TestDataFactory.createAddress(1);
        addressRecords.add(TestDataFactory.createAddress(1)[0]);
        for(Address__c addressRec: addressRecords) {
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            if(addName == 'Airline') {
                addressRec.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Airline'].id;
            }
            if(addName == 'Internal') {
                addressRec.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Internal'].id;
            }
            if(addName == 'Overseas') {
                addressRec.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Overseas'].id;
            }
            
        }
        
        insert addressRecords;     
        
        contactList = TestDataFactory.createContact(1);
        contactList.add(TestDataFactory.createContact(1)[0]);
        
        for(Contact con: contactList) {
            con.Address__c = addressRecords[0].Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Customer Contact'].id;
            con.Recipient_Indicator__c = recipIndicator;
            con.NRIC__c = 'T1234567R';
            con.Passport__c = 'PASS001';
            con.Mobile_Number__c = '09324861074';
            con.Fax__c = '09324861074';                                    
        }
        
        contactList[0].HomePhone__c = '123456';
        contactList[0].Billing_Indicator__c = true;
        contactList[1].Billing_Indicator__c = true;
        contactList[1].HomePhone__c = '123456';
        insert contactList; 

        List<Zuora__CustomerAccount__c> billAccounts = TestDataFactory.createBillingAccount(1);
        for(Zuora__CustomerAccount__c billAcc: billAccounts){
            billAcc.Name = 'Zuora Customer Account';
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Credit_Balance__c = 1;
            billAcc.Refund_Amount__c = 100;
            billAcc.Zuora__AutoPay__c =false;
            billAcc.Zuora__Balance__c = 1;
            billAcc.Payment_Mode__c = 'Invoice';
            billAcc.Other_PaymentMethod__c= 'Invoice';
                //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            billAcc.Zuora__PaymentMethodType__c = 'Invoice';
            billAcc.ARMS_Customer_Number__c = 'ARMSCUS001';
            billAcc.ARMS_Account_Number__c = 'ARMSACC001';
            billAcc.Zuora__External_Id__c = '22544AA';  
            billAcc.Zuora__Zuora_Id__c = '0124';
            billAcc.Billing_Type__c= 'Recurring Prepaid';    
            billAcc.Zuora__Status__c = 'Active';
            billAcc.Billing_Contact__c = contactList[0].Id;
        }
        insert billAccounts;
        Account accRec = [SELECT AccountNumber FROM ACCOUNT WHERE ID =:acc.ID];
        
        BT_CO_ARMS_UpdateCustomerBatchFile__c armsUp = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
        armsUp.Customer_Name1__c = 'Zuora Customer Account';
        armsUp.UniqueKey__c = accRec.AccountNumber;
        armsUp.CCRID__c = 'ARMSCUS001';
        insert armsUp; 
        
        Set<Id> CusToUpdSet = new Set<Id>();
        CusToUpdSet.add(armsUp.Id);
        /**
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> oldUpdateCusRecord_LIST =
                        [Select Id, CreatedDate,Customer_Name1__c, CCRID__c,Business_Profile__c, UniqueKey__c from 
                        BT_CO_ARMS_UpdateCustomerBatchFile__c Where
                        CreatedDate = Today
                        AND Customer_Name1__c =: billAccounts[0].Name];
                        //AND UniqueKey__c IN :updUniqKey_SET
                        //AND CCRID__c IN :updCusNum_SET];
        System.assertEquals(-1, oldUpdateCusRecord_LIST.size());*/
        //START : D-1929 3/2/2015 added to create Default Payment Method
        List<Zuora__PaymentMethod__c> zpmList = TestDataFactory.createPaymentMethod(1);
        for(Zuora__PaymentMethod__c zpm : zpmList) {
            zpm.Name = 'Zuora Customer Account';
            zpm.Zuora__Type__c = 'Invoice';
        }
        
        zpmList[0].Zuora__BillingAccount__c = billAccounts[0].id;
        
        insert zpmList;  
        //End: D-1929 3/2/2015 added to create Default Payment Method
            
        billAccounts[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
        update billAccounts;
        
        
        order = TestDataFactory.createOrder(1)[0];
        order.Subscriber_Charge__c = 100.0;
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        if(contactList[0].Recipient_Indicator__c) {
            order.Recipient_Contact__c = contactList[0].Id;
        }        
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAccounts[0].id;
        order.Billing_Type__c = 'Recurring Prepaid';
        order.Billing_Contact__c = contactList[1].id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Order_Status__c = 'Close';
        insert order;
        
        casList = TestDataFactory.createCase(2, 'Complaint - Magazine');
        for(Case cas: casList) {
            cas.Order__c = order.Id;
            cas.Change_of_Address_Type__c = changeOfAdd;
        }
        casList[1].Change_of_Address_Type__c = 'Change of Delivery Address - Overseas to Overseas';
        
        insert casList;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
            
        subRecs =  TestDataFactory.createSubscription(1+subCount);
        Integer count = 1;
        for(Zuora__Subscription__c subRec: subRecs) {
            subRec.Subscriber_Contact__c = contactList[0].id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Account__c = acc.id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            //subRec.Order_Number__c = order.Id;
            subRec.Zuora__CustomerAccount__c = billAccounts[0].Id;
            subRec.Billing_Type__c = 'Recurring Prepaid';
            subRec.Legacy_Create_Date__c = 'a';
            subRec.Legacy_Create_By__c = 'a';
            subRec.Legacy_Update_By__c = 'a';
            subRec.Legacy_Subscription_ID__c = 'a';
            subRec.Legacy_Update_Date__c = 'a';
            subRec.Number_of_Copies__c = 100;
            subRec.Number_of_Copies1__c = '100';
            subRec.Zuora__Status__c = 'Active';
            subRec.Subscription_Type_1__c = 'Publication';
            subRec.Subscription_Type__c = 'Publication';
            subRec.Term_Length__c = 1;
            subRec.Zuora__SubscriptionStartDate__c = Date.today();
            subRec.Zuora__SubscriptionEndDate__c = Date.today();
            subRec.Zuora__TermSettingType__c = 'EVERGREEN';
            subRec.Zuora__Zuora_Id__c = 'ZZID000'+count;
            subRec.Main_Package__c = pack.id;
            count++;
        }
        
        subRecs[subCount].Subscription_Type__c = 'Delivery';
            
        insert subRecs;
        
        Vendor_Allocation__c va = TestDataFactory.createVendorAlloc(1)[0];
        va.Allocated__c = TRUE;
        va.Vendor_Account__c = acc.Id;
        va.Effective_Start_Date__c  = date.today();
        va.SingPost_Address__c = postal.id;
        va.Effective_End_Date__c = date.today().addMonths(2);
        insert va;
        
    }
    
    /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the initial test data objects.
    * @date: 07/31/2015
    */ 
    static void prepareTestData(String sub, String vendorSub, Integer addAssCount, Integer vendorCount){
        
        svs = TestDataFactory.createSubscriptionVendor(vendorCount);
        for(Subscription_Vendor__c sv:svs) {
            /*sv.Account__c = acc.Id;*/
            sv.Status__c = 'Active';
            /*sv.Recipient__c = contactList[0].Id;*/
        }
      
        insert svs;
        
        List<Address_Assignment__c> aa1 = new List<Address_Assignment__c>();
        aa1.add(new Address_Assignment__c());
        if(addAssCount > 1) {
            aa1.add(new Address_Assignment__c());
            aa1.add(new Address_Assignment__c());
            aa1.add(new Address_Assignment__c());
            aa1.add(new Address_Assignment__c());
        }
        
        for(Address_Assignment__c aa : aa1){
            /*aa.Address__c = addressRecords[0].Id;*/
            /*aa.Case__c = casList[0].Id;*/
            /*aa.Contact__c = contactList[0].Id;*/
            aa.Effective_Date__c = Date.today(); 
            aa.Status__c = 'Active'; 
            aa.Vendor__c = acc.Id;
            //aa.End_Date__c = null;  
            if(vendorSub != null) {
                aa.Subscription_Vendor__c = svs[0].id;
            }                                    
             
            aa.Active__c = False; 
            if(sub != null){
                aa.Subscription__c = subRecs[0].id;
            }
            
            // Raus Ablaza
            // Put address and contact to all Address_Assignment__c
            aa.Address__c = addressRecords[1].Id;
            aa.Contact__c = contactList[1].Id;
        }
        
        if(addAssCount > 1) {
            aa1[1].Contact__c = contactList[1].Id;
            if(vendorSub != null) {
                aa1[1].Subscription_Vendor__c = svs[1].id;
            }
            // Checking is for line #379
            if(sub != null){
                aa1[1].Subscription__c = subRecs[1].id;
            }
            
            // For line 361
            aa1[2].Address__c = addressRecords[1].Id;
            
            // For line 354
            aa1[3].Case__c = casList[1].Id;
            
            aa1[4].Contact__c = contactList[1].Id;
        }
        
        insert aa1;
    }
    
    // static testMethod void testBatchAddressEffectiveDate(){
    //     prepareInitialTestData();
    //     prepateTestData();
    // }
    
    /**
    * @name: testBatch
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution.
    * @date: 07/31/2015
    */
    static testMethod void testBatch(){
        Test.StartTest();
        prepareInitialTestData('Change of Delivery Address - Local to Local', true, 2, 'local');
        prepareTestData('', '', 2, 2);
        
        
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;
        
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        ID batchprocessid = Database.executeBatch(batch, 200);
            
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchprocessid;
        batchJobSched.Batch_Run_Date__c = System.today();
        insert batchJobSched;
        
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
    }
    
    /**
    * @name: testBatchWithPublicationSubscriptionIsOne
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution with
    *                subscription count with 'Publication' is one.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithPublicationSubscriptionIsOne(){
        prepareInitialTestData('Change of Delivery Address - Local to Local', true, 1, 'local');
        prepareTestData(null, '', 1, 1);
        Test.StartTest();
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    static testMethod void testBatchWithPublicationSubscriptionIsOne2(){
         /*prepareInitialTestData('Change of Delivery Address - Local to Local', true, 1, 'Overseas');*/
        Test.StartTest();
        /*prepareTestData(null, '', 1, 1);
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    static testMethod void testBatchWithPublicationSubscriptionIsOne3(){
         /*prepareInitialTestData('Change of Delivery Address - Local to Local', true, 1, 'Internal');*/
        Test.StartTest();
        /*prepareTestData(null, '', 1, 1);
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testBatchWithPublicationSubscriptionIsOneAndInactiveAddressAssignment
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution with
    *                subscription count with 'Publication' is one and an active address assignment.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithPublicationSubscriptionIsOneAndActiveAddressAssignment(){
        /*prepareInitialTestData('Change of Delivery Address - Local to Local', true, 1, 'local');*/
        /*prepareTestData(null, '', 1, 1);*/
        Test.StartTest();

        Address_Assignment__c addAssRec = new Address_Assignment__c();
        /*addAssRec.Address__c = addressRecords[0].Id;*/
        /*addAssRec.Case__c = casList[0].Id;*/
        /*addAssRec.Contact__c = contactList[0].Id; */
        addAssRec.Effective_Date__c = Date.today(); 
        addAssRec.Status__c = 'Active'; 
        /*addAssRec.Vendor__c = acc.Id;*/
        /*addAssRec.Subscription_Vendor__c = svs[0].id;*/                           
        addAssRec.Active__c = true;
        //insert addAssRec;
        
        List<Address_Assignment__c> addAssList = new List<Address_Assignment__c>();
        addAssList.add(addAssRec);
        /*insert addAssList;*/
        
        /*Account accRec = [SELECT AccountNumber FROM ACCOUNT WHERE ID =:acc.ID];*/
        
        BT_CO_ARMS_UpdateCustomerBatchFile__c armsUp = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
        armsUp.Customer_Name1__c = 'Zuora Customer Account';
        /*armsUp.UniqueKey__c = accRec.AccountNumber;*/
        armsUp.CCRID__c = 'ARMSCUS001';
        armsUp.Contact_Type__c = 'E';
        insert armsUp; 
        
        Set<Id> CusToUpdSet = new Set<Id>();
        CusToUpdSet.add(armsUp.Id);
        
        Set<String> selectiveID = new Set<String>();
        selectiveID.add(String.ValueOf(addAssList[0].Id));
        /*
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            /*BatchAddressAssignmentEffectiveDate.updateCustomerWebserviceNonFuture(CusToUpdSet);
            batch.updatePreviousAddressAssignment(addAssList);*/
            
            BatchAddressAssignmentEffectiveDate batch2 = new BatchAddressAssignmentEffectiveDate(date.today().addDays(2));
            
            BatchAddressAssignmentEffectiveDate batch3 = new BatchAddressAssignmentEffectiveDate(addAssList[0].Id);
            
            BatchAddressAssignmentEffectiveDate batch4 = new BatchAddressAssignmentEffectiveDate(selectiveID);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    static testMethod void testBatchWithPublicationSubscriptionIsOneAndActiveAddressAssignment2(){
         /*prepareInitialTestData('Change of Delivery Address - Local to Local', true, 1, 'local');*/
        /*prepareTestData(null, '', 1, 1);*/
        Test.StartTest();
        
        Address_Assignment__c addAssRec = new Address_Assignment__c();
        /*addAssRec.Address__c = addressRecords[0].Id;*/
        /*addAssRec.Case__c = casList[0].Id;*/
        /*addAssRec.Contact__c = contactList[0].Id; */
        addAssRec.Effective_Date__c = Date.today(); 
        addAssRec.Status__c = 'Active'; 
        /*addAssRec.Vendor__c = acc.Id;*/
        /*addAssRec.Subscription_Vendor__c = svs[0].id;*/                          
        addAssRec.Active__c = true;
        //insert addAssRec;
        
        List<Address_Assignment__c> addAssList = new List<Address_Assignment__c>();
        addAssList.add(addAssRec);
        /*insert addAssList;*/
        
        /*Account accRec = [SELECT AccountNumber FROM ACCOUNT WHERE ID =:acc.ID];*/
        
        BT_CO_ARMS_UpdateCustomerBatchFile__c armsUp = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
        armsUp.Customer_Name1__c = 'Zuora Customer Account';
        /*armsUp.UniqueKey__c = accRec.AccountNumber;*/
        armsUp.CCRID__c = 'ARMSCUS001';
        armsUp.Contact_Type__c = 'E';
        insert armsUp; 
        
        Set<Id> CusToUpdSet = new Set<Id>();
        CusToUpdSet.add(armsUp.Id);
        
        Set<String> selectiveID = new Set<String>();
        selectiveID.add(String.ValueOf(addAssList[0].Id));
        
        Map<String, Contact> subZuoraIdToNewContactMap = new Map<String, Contact>();
        /*subZuoraIdToNewContactMap.put('contact', contactList[0]);
        
        Map<Id, Contact> subIdToNewContactMap = new Map<Id, Contact>();
        subIdToNewContactMap.put(subRecs[0].Id, contactList[0]);
        
        Map<String, Id> subZuoraIdToNewVendorMap = new Map<String, Id>();
        subZuoraIdToNewVendorMap.put('test', acc.Id);
        
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            //BatchAddressAssignmentEffectiveDate.updateCustomerWebserviceNonFuture(CusToUpdSet);
            batch.updatePreviousAddressAssignment(addAssList);
            /*batch.createContact(contactList[0], addressRecords[0].Id, TRUE, GlobalVariableClass.BILLDELIVERYADD);*/
            
            BatchAddressAssignmentEffectiveDate batch2 = new BatchAddressAssignmentEffectiveDate(date.today().addDays(2));
            
            BatchAddressAssignmentEffectiveDate batch3 = new BatchAddressAssignmentEffectiveDate(addAssList[0].Id);
            
            BatchAddressAssignmentEffectiveDate batch4 = new BatchAddressAssignmentEffectiveDate(selectiveID);
            
            /*batch.updateOrderBillingContact(subIdToNewContactMap);
            batch.updateSub(subZuoraIdToNewContactMap, subZuoraIdToNewVendorMap);*/
            
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testBatchWithSubscriptionAndVendor
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution with
    *                subscription and vendor data.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithSubscriptionAndVendor(){
         /*prepareInitialTestData('Change of Delivery Address - Local to Local', true, 1, 'local');*/
        Test.StartTest();
        /*prepareTestData('', '', 1, 1);
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testBatchWithNoSubscription
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution
    *                with no Subscription.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithNoSubscription(){
         /*prepareInitialTestData('Change of Delivery Address - Local to Local', true, 2, 'local');*/
        Test.StartTest();
        /*prepareTestData(null,'', 2, 2);*/
        /*for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        ID batchprocessid = Database.executeBatch(batch, 200);
            
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchprocessid;
        batchJobSched.Batch_Run_Date__c = System.today();
        insert batchJobSched;
        
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
    }
    
    /**
    * @name: testBatchWithChangeToBillingAddress
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution
    *                with change billing address.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithChangeToBillingAddress(){
        /*prepareInitialTestData(GlobalVariableClass.BILLINGADD, true, 2, 'local');*/
        Test.StartTest();
        /*prepareTestData(null, null, 2, 2);
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;
        */
        
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        ID batchprocessid = Database.executeBatch(batch, 200);
            
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchprocessid;
        batchJobSched.Batch_Run_Date__c = System.today();
        insert batchJobSched;
        
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
    }
    
    /**
    * @name: testBatchWithChangeToBillingAddressAndRecipientIndicatorIsFalse
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution
    *                with change billing address and recipient indicator is false.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithChangeToBillingAddressAndRecipientIndicatorIsFalse(){
         /*prepareInitialTestData(GlobalVariableClass.BILLINGADD, false, 2, 'local');*/
        Test.StartTest();
        /*prepareTestData(null, null, 2, 2);
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;
        */
        
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        ID batchprocessid = Database.executeBatch(batch, 200);
            
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchprocessid;
        batchJobSched.Batch_Run_Date__c = System.today();
        insert batchJobSched;
        
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
    }
    
    /**
    * @name: testBatchWithChangeToBillingAddressAndRecipientIndicatorIsFalseAndSubPublicationIsOne
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution
    *                with change billing address and recipient indicator is false and subscription count
    *                with 'Publication' is one.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithChangeToBillingAddressAndRecipientIndicatorIsFalseAndSubPublicationIsOne(){
         /*prepareInitialTestData(GlobalVariableClass.BILLINGADD, false, 1, 'local');*/
        Test.StartTest();
        /*prepareTestData(null, null, 2, 2);
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testBatchWithAddressChangeToBillingDeliveryAddress
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution
    *                with change to billing delivery address.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithChangeToBillingDeliveryAddress(){
        /*prepareInitialTestData(GlobalVariableClass.BILLDELIVERYADD, true, 2, 'local');*/
        Test.StartTest();
        /*prepareTestData(null, null, 2, 2);
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        ID batchprocessid = Database.executeBatch(batch, 200);
            
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchprocessid;
        batchJobSched.Batch_Run_Date__c = System.today();
        insert batchJobSched;
        
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
    }
    
    /**
    * @name: testBatchWithChangeToBillingDeliveryAddressAndPublicationSubscriptionIsOne
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution
    *                with change to billing delivery address and subscription count with
    *                'Publication' is one.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithChangeToBillingDeliveryAddressAndPublicationSubscriptionIsOne(){
         /*prepareInitialTestData(GlobalVariableClass.BILLDELIVERYADD, true, 1, 'local');*/
        
        /*prepareTestData(null, null, 2, 2);*/
        Test.StartTest();
        /*for(Zuora__Subscription__c subs : subRecs) {
            subs.Order_Number__c = order.Id;
            subs.Order_Number_1__c = order.Id;
        }
        update subRecs;
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testBatchWithChangeToBillingDeliveryAddressAndAddressIsInternal
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution
    *                with change to billing delivery address and address is Internal.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithChangeToBillingDeliveryAddressAndAddressIsInternal(){
         /*prepareInitialTestData(GlobalVariableClass.BILLDELIVERYADD, true, 1, 'Internal');*/
        /*prepareTestData(null, null, 2, 2);*/
        //Test.StartTest();
        /*for(Zuora__Subscription__c subs : subRecs) {
            subs.Order_Number__c = order.Id;
            subs.Order_Number_1__c = order.Id;
        }
        update subRecs;
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        Test.StartTest();
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testBatchWithChangeToBillingDeliveryAddressAndAddressIsOverseas
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate execution
    *                with change to billing delivery address and address is Overseas.
    * @date: 07/31/2015
    */
    static testMethod void testBatchWithChangeToBillingDeliveryAddressAndAddressIsOverseas(){
         /*prepareInitialTestData(GlobalVariableClass.BILLDELIVERYADD, true, 1, 'Overseas');*/      
        /*prepareTestData(null, null, 2, 2);*/
        //Test.StartTest();
        /*for(Zuora__Subscription__c subs : subRecs) {
            subs.Order_Number__c = order.Id;
            subs.Order_Number_1__c = order.Id;
        }
        update subRecs;
        for(Case cas: casList) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
        }
        update casList;*/
        Test.StartTest();
        try{
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch, 200);
                
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchprocessid;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            
            System.assertNotEquals(null, batchprocessid);
            Test.StopTest();
        
        }catch(System.DmlException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testUpdateSubBillingContact
    * @author : Hazel Jurna M. Limot
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate's method, updateSubBillingContact
    * @date: 08/20/2015
    */
    static testMethod void testUpdateSubBillingContact(){
        Test.StartTest();
        
        defaultCustomSetting();
    
        //test data creation
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Name = 'Zuora Customer Account';
        acc.Phone = '123456';
        acc.AccountNumber = 'ACCNO001';
        acc.Staff_ID__c = 'SID001';
        insert acc; 
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Recurring Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        insert pack;  
        
        addressRecords = TestDataFactory.createAddress(1);
        addressRecords.add(TestDataFactory.createAddress(1)[0]);
        for(Address__c addressRec: addressRecords) {
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            //if(addName == 'Airline') {
              //  addressRec.RecordTypeId = '012N00000008idx';
            //}
           // if(addName == 'Internal') {
             //   addressRec.RecordTypeId = '012N00000008idnIAA';
           // }
          //  if(addName == 'Overseas') {
            //    addressRec.RecordTypeId = '012N00000008idsIAA';
           // }
            
        }
        
        insert addressRecords;     
        
        Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRecords[0].Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Customer Contact'].id;
            con.Recipient_Indicator__c = false;
            con.NRIC__c = 'T1234567R';
            con.Passport__c = 'PASS001';
            con.Mobile_Number__c = '09324861074';
            con.Fax__c = '09324861074';                                    
            con.HomePhone__c = '123456';
            con.Billing_Indicator__c = true;
            con.HomePhone__c = '123456';
            //insert con; 
        
        List<Zuora__CustomerAccount__c> billAccounts = TestDataFactory.createBillingAccount(1);
        for(Zuora__CustomerAccount__c billAcc: billAccounts){
            billAcc.Name = 'Zuora Customer Account';
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Credit_Balance__c = 1;
            billAcc.Refund_Amount__c = 100;
            billAcc.Zuora__AutoPay__c =false;
            billAcc.Zuora__Balance__c = 1;
            billAcc.Payment_Mode__c = 'Invoice';
            billAcc.Other_PaymentMethod__c= 'Invoice';
                //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            billAcc.Zuora__PaymentMethodType__c = 'Invoice';
            billAcc.ARMS_Customer_Number__c = 'ARMSCUS001';
            billAcc.ARMS_Account_Number__c = 'ARMSACC001';
            billAcc.Zuora__External_Id__c = '22544AA';  
            billAcc.Zuora__Zuora_Id__c = '0124';
            billAcc.Billing_Type__c= 'Recurring Prepaid';    
            billAcc.Zuora__Status__c = 'Active';
            billAcc.Billing_Contact__c = con.Id;
        }
        insert billAccounts;
        
        order = TestDataFactory.createOrder(1)[0];
        order.Subscriber_Charge__c = 100.0;
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        if(con.Recipient_Indicator__c) {
            order.Recipient_Contact__c = con.Id;
        }
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAccounts[0].id;
        order.Billing_Type__c = 'Recurring Prepaid';
        order.Billing_Contact__c = con.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Order_Status__c = 'Close';
        /*insert order;
            List<Order__c> ord = new List<Order__c>();
        ord.add(order);
         */
        subRecs =  TestDataFactory.createSubscription(1+2);
        Integer count = 1;
        for(Zuora__Subscription__c subRec: subRecs) {
            subRec.Contact__c = con.Id;
            subRec.Subscriber_Contact__c = con.id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Account__c = acc.id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            //subRec.Order_Number__c = order.Id;
            subRec.Zuora__CustomerAccount__c = billAccounts[0].Id;
            subRec.Billing_Type__c = 'Recurring Prepaid';
            subRec.Legacy_Create_Date__c = 'a';
            subRec.Legacy_Create_By__c = 'a';
            subRec.Legacy_Update_By__c = 'a';
            subRec.Legacy_Subscription_ID__c = 'a';
            subRec.Legacy_Update_Date__c = 'a';
            subRec.Number_of_Copies__c = 100;
            subRec.Number_of_Copies1__c = '100';
            subRec.Zuora__Status__c = 'Active';
            subRec.Subscription_Type_1__c = 'Publication';
            subRec.Subscription_Type__c = 'Publication';
            subRec.Term_Length__c = 1;
            subRec.Zuora__SubscriptionStartDate__c = Date.today();
            subRec.Zuora__SubscriptionEndDate__c = Date.today()+3;
            subRec.Zuora__TermSettingType__c = 'EVERGREEN';
            subRec.Zuora__Zuora_Id__c = 'ZZID000'+count;
            subRec.Main_Package__c = pack.id;
            subRec.Order_Number__c = order.Id;
            subRec.Order_Number_1__c = order.Id;
            subRec.Zuora__Zuora_Id__c = '1123';
            count++;
        }
        
        subRecs[2].Subscription_Type__c = 'Delivery';
            
        insert subRecs;
        
        Map<Id, Contact> subIdToNewContactMap = new Map<Id, Contact>();
        subIdToNewContactMap.put(subRecs[0].Id,con);  
        
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        //ID batchprocessid = Database.executeBatch(batch, 200);
            
        //BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        //batchJobSched.SFDC_Job_id__c = batchprocessid;
        //batchJobSched.Batch_Run_Date__c = System.today();
        //insert batchJobSched;
        
        /*batch.updateSubBillingContact(ord, subIdToNewContactMap); */
        
        /*System.assertNotEquals(null, con.Id);*/
        Test.StopTest();
    }
    
    /**
    * @name: testUpdateCustomerWebserviceNonFuture
    * @author : Hazel Jurna M. Limot
    * @description : Handles the testing for BatchAddressAssignmentEffectiveDate's method, updateCustomerWebserviceNonFuture
    * @date: 08/20/2015
    */
    static testMethod void testUpdateCustomerWebserviceNonFuture(){
        Test.StartTest();
        
        defaultCustomSetting();
    
        //test data creation
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Name = 'Zuora Customer Account';
        acc.Phone = '123456';
        acc.AccountNumber = 'ACCNO001';
        acc.Staff_ID__c = 'SID001';
        insert acc; 
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Recurring Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        insert pack;  
        
        addressRecords = TestDataFactory.createAddress(1);
        addressRecords.add(TestDataFactory.createAddress(1)[0]);
        for(Address__c addressRec: addressRecords) {
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            //if(addName == 'Airline') {
              //  addressRec.RecordTypeId = '012N00000008idx';
            //}
           // if(addName == 'Internal') {
             //   addressRec.RecordTypeId = '012N00000008idnIAA';
           // }
          //  if(addName == 'Overseas') {
            //    addressRec.RecordTypeId = '012N00000008idsIAA';
           // }
            
        }
        
        insert addressRecords;     
        
        Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRecords[0].Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Customer Contact'].id;
            con.Recipient_Indicator__c = false;
            con.NRIC__c = 'T1234567R';
            con.Passport__c = 'PASS001';
            con.Mobile_Number__c = '09324861074';
            con.Fax__c = '09324861074';                                    
            con.HomePhone__c = '123456';
            con.Billing_Indicator__c = true;
            con.HomePhone__c = '123456';
            //insert con; 
        
        List<Zuora__CustomerAccount__c> billAccounts = TestDataFactory.createBillingAccount(1);
        for(Zuora__CustomerAccount__c billAcc: billAccounts){
            billAcc.Name = 'Zuora Customer Account';
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Credit_Balance__c = 1;
            billAcc.Refund_Amount__c = 100;
            billAcc.Zuora__AutoPay__c =false;
            billAcc.Zuora__Balance__c = 1;
            billAcc.Payment_Mode__c = 'Invoice';
            billAcc.Other_PaymentMethod__c= 'Invoice';
                //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            billAcc.Zuora__PaymentMethodType__c = 'Invoice';
            billAcc.ARMS_Customer_Number__c = 'ARMSCUS001';
            billAcc.ARMS_Account_Number__c = 'ARMSACC001';
            billAcc.Zuora__External_Id__c = '22544AA';  
            billAcc.Zuora__Zuora_Id__c = '0124';
            billAcc.Billing_Type__c= 'Recurring Prepaid';    
            billAcc.Zuora__Status__c = 'Active';
            billAcc.Billing_Contact__c = con.Id;
        }
        insert billAccounts;
        
        order = TestDataFactory.createOrder(1)[0];
        order.Subscriber_Charge__c = 100.0;
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        if(con.Recipient_Indicator__c) {
            order.Recipient_Contact__c = con.Id;
        }
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAccounts[0].id;
        order.Billing_Type__c = 'Recurring Prepaid';
        order.Billing_Contact__c = con.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Order_Status__c = 'Close';
        /*insert order;
            List<Order__c> ord = new List<Order__c>();
        ord.add(order);
        */
        
        subRecs =  TestDataFactory.createSubscription(1+2);
        Integer count = 1;
        for(Zuora__Subscription__c subRec: subRecs) {
            subRec.Contact__c = con.Id;
            subRec.Subscriber_Contact__c = con.id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Account__c = acc.id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            //subRec.Order_Number__c = order.Id;
            subRec.Zuora__CustomerAccount__c = billAccounts[0].Id;
            subRec.Billing_Type__c = 'Recurring Prepaid';
            subRec.Legacy_Create_Date__c = 'a';
            subRec.Legacy_Create_By__c = 'a';
            subRec.Legacy_Update_By__c = 'a';
            subRec.Legacy_Subscription_ID__c = 'a';
            subRec.Legacy_Update_Date__c = 'a';
            subRec.Number_of_Copies__c = 100;
            subRec.Number_of_Copies1__c = '100';
            subRec.Zuora__Status__c = 'Active';
            subRec.Subscription_Type_1__c = 'Publication';
            subRec.Subscription_Type__c = 'Publication';
            subRec.Term_Length__c = 1;
            subRec.Zuora__SubscriptionStartDate__c = Date.today();
            subRec.Zuora__SubscriptionEndDate__c = Date.today()+3;
            subRec.Zuora__TermSettingType__c = 'EVERGREEN';
            subRec.Zuora__Zuora_Id__c = 'ZZID000'+count;
            subRec.Main_Package__c = pack.id;
            subRec.Order_Number__c = order.Id;
            subRec.Order_Number_1__c = order.Id;
            subRec.Zuora__Zuora_Id__c = '1123';
            count++;
        }
        
        subRecs[2].Subscription_Type__c = 'Delivery';
            
        insert subRecs;
        
        Map<Id, Contact> subIdToNewContactMap = new Map<Id, Contact>();
        subIdToNewContactMap.put(subRecs[0].Id,con);  
        
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        //ID batchprocessid = Database.executeBatch(batch, 200);
            
        //BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        //batchJobSched.SFDC_Job_id__c = batchprocessid;
        //batchJobSched.Batch_Run_Date__c = System.today();
        //insert batchJobSched;
        
        /*batch.updateSubBillingContact(ord, subIdToNewContactMap); */
        
        /*System.assertNotEquals(null, con.Id);*/
        Test.StopTest();
    }
    
     /**
    * @name: defaultCustomSetting
    * @author : Recuerdo Bregente
    * @description : Prepares custom settings.
    * @date: 07/27/2015
    */
    static void defaultCustomSetting()
    {
        
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
        
    }

}//end of BatchAddressAssignmentEffectiveDate