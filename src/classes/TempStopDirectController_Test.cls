//*********************************************************************************************
//
// Author: Glen Anthony Abanes Cubinar
// Co-Author: Joy Suarez
// Date: 1/23/2015
// Description: Test Class for TempStopDirectController 
//
//*********************************************************************************************

@isTest (seeAllData= True)
private Class TempStopDirectController_Test {
    /**
    *  To test TempStopDirectController
    *  @name TestTempStopDirectController
    *  @param none
    *  @return none
    *  @throws na
    */ 
    Static testMethod void TestTempStopDirectController() {   

        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        insert cas;
 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        
        lOLI.add(oli);
        Insert lOLI;
       
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+10;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';             
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today();
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today()+2;
        TS.Restart_Date__c = date.today();
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
              
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        system.assertNotEquals(null, npub);   
                
        Test.startTest();
              
        PageReference pageRef = page.TempStopDirect;
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId', accList[0].Id);
        TempStopDirectController tempStopDirController = new TempStopDirectController(); 
        tempStopDirController.getAccount();
        tempStopDirController.getSubscriptions();
        set<id> ini = new set <id>();
        ini.add(zs.Id);
        //tempStopDirController.initialize(ini);
        List<SelectOption> RequestSources = tempStopDirController.getRequestSources();
        List<SelectOption> TempStopType= tempStopDirController.getListTempStopType();
              
        String GselectedTempStopType = tempStopDirController.getselectedTempStopType();
        tempStopDirController.selectedTempStopType = 'Update Temp Stop Request';
        tempStopDirController.setTempStopType('Update Temp Stop Request');
        tempStopDirController.getErrorOnLimit();
  
        TempStopDirectController.SubscriptionWrapper SubscriptionWrapperList = new TempStopDirectController.SubscriptionWrapper();
        TempStopDirectController.SelectedWrapper WrapperUpdateRequestList = new TempStopDirectController.SelectedWrapper();        
        tempStopDirController.submit();
        tempStopDirController.cancel();
        tempStopDirController.validateLimit();
        tempStopDirController.deliverySub(c.Address_Unique_Id__c);     
        //tempStopDirController.getQuantity(zs.Id);
        //tempStopDirController.refundEligible(zs.id, date.today(), date.today()+2, 10);
        //tempStopDirController.getFrequency('PUB123');
        tempStopDirController.validateLimit(10,10);
        tempStopDirController.validateLimit(12,10);
        tempStopDirController.removeSubscriptionRecord();
        
        //subscriptionwrapper
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.subscriptionResultList[0].earliestStartDate = null;    
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.newInstance(2012, 05, 5);
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.subscriptionResultList[0].earliestStartDate = null;    
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords(); 
      
        //updateresultlist
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.today()-2;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.newInstance(2015, 05, 5);
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.newInstance(2015, 10, 10);
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.newInstance(2015, 11, 2);
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subStartDate = date.today()+10;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.today()+1;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.today()+1;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.checkDuplicateSubscription();
        tempStopDirController.checkDuplicateSubscriptionUpdate();
        tempStopDirController.checkDuplicateSubscriptionCancel();
        tempStopDirController.removeSubscriptionRecordUpdate();
        tempStopDirController.removeSubscriptionRecordCancel(); 

        Test.stopTest();
    } 
    /**
    *  To test TempStopDirectController
    *  @name TestTempStopDirectController2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    Static testMethod void TestTempStopDirectController2() {   

        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();

        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
    
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;

        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        insert cas;
 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        
        lOLI.add(oli);
        Insert lOLI;
       
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+10;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = '2';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today();
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today();
        TS.Restart_Date__c = date.today()+2;
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'RPN123';
        SPC.Zuora__UOM__c = 'Copy Weekday';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        system.assertNotEquals(null, npub);   
  
        Test.startTest();
       
        PageReference pageRef = page.TempStopDirect;
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId', accList[0].Id);
        TempStopDirectController tempStopDirController = new TempStopDirectController(); 
        tempStopDirController.getAccount();
        tempStopDirController.getSubscriptions();
       
        List<SelectOption> RequestSources = tempStopDirController.getRequestSources();
        List<SelectOption> TempStopType= tempStopDirController.getListTempStopType();
        String GselectedTempStopType = tempStopDirController.getselectedTempStopType();
        tempStopDirController.selectedTempStopType = 'Update Temp Stop Request';
        tempStopDirController.setTempStopType('Update Temp Stop Request');
        tempStopDirController.getErrorOnLimit();
        TempStopDirectController.SelectedWrapper WrapperUpdateRequestList = new TempStopDirectController.SelectedWrapper();
        TempStopDirectController.SubscriptionWrapper SubscriptionWrapperList = new TempStopDirectController.SubscriptionWrapper();
        tempStopDirController.checkDuplicateSubscription();
        tempStopDirController.checkDuplicateSubscriptionUpdate();
        tempStopDirController.checkDuplicateSubscriptionCancel();
        tempStopDirController.removeSubscriptionRecordUpdate();
        tempStopDirController.removeSubscriptionRecordCancel(); 
        tempStopDirController.createRecordsOnSave();
        tempStopDirController.cancel();
        tempStopDirController.validateLimit();
        tempStopDirController.deliverySub(c.Address_Unique_Id__c);     
        //tempStopDirController.getQuantity(zs.Id);
        //tempStopDirController.getTotalRefundForYear(zs.Id);
        tempStopDirController.setCancelRecords();
        tempStopDirController.setSelectedRecords();
        //tempStopDirController.refundEligible(zs.id, date.today(), date.today()+2, 10);
        //tempStopDirController.getNonPub(zs.Id, date.today()+1);
        //tempStopDirController.getFrequency('RPN123');
        tempStopDirController.setUpdateRecords();
        Test.stopTest();
    } 
    /**
    *  To test TempStopDirectController
    *  @name TestTempStopDirectController3
    *  @param none
    *  @return none
    *  @throws na
    */ 
    Static testMethod void TestTempStopDirectController3() {   

        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
       
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
    
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;

        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        insert cas;

        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        
        lOLI.add(oli);
        Insert lOLI;
       
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+10;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = '2';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today();
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today()-2;
        TS.Restart_Date__c = date.today()+2;
        TS.Cancelled__c = true;
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'RPN123';
        SPC.Zuora__UOM__c = 'Copy Sat';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        system.assertNotEquals(null, npub); 
        
        Test.startTest(); 
        
        PageReference pageRef = page.TempStopDirect;
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId', accList[0].Id);
        TempStopDirectController tempStopDirController = new TempStopDirectController();       
        tempStopDirController.getAccount();
        tempStopDirController.getSubscriptions();
       
        List<SelectOption> RequestSources = tempStopDirController.getRequestSources();
        List<SelectOption> TempStopType= tempStopDirController.getListTempStopType();
        String GselectedTempStopType = tempStopDirController.getselectedTempStopType();
        
        tempStopDirController.selectedTempStopType = 'Update Temp Stop Request';
        tempStopDirController.setTempStopType('Update Temp Stop Request');
        tempStopDirController.getErrorOnLimit();
        TempStopDirectController.SelectedWrapper WrapperUpdateRequestList = new TempStopDirectController.SelectedWrapper();
        TempStopDirectController.SubscriptionWrapper SubscriptionWrapperList = new TempStopDirectController.SubscriptionWrapper();
        tempStopDirController.checkDuplicateSubscription();
        tempStopDirController.checkDuplicateSubscriptionUpdate();
        tempStopDirController.checkDuplicateSubscriptionCancel();
        tempStopDirController.removeSubscriptionRecordUpdate();
        tempStopDirController.removeSubscriptionRecordCancel(); 
        tempStopDirController.createRecordsOnSave();
        tempStopDirController.cancel();
        tempStopDirController.validateLimit();
        tempStopDirController.deliverySub(c.Address_Unique_Id__c);     
        //tempStopDirController.getQuantity(zs.Id);
        //tempStopDirController.getTotalRefundForYear(zs.Id);
        tempStopDirController.setCancelRecords();
        tempStopDirController.setSelectedRecords();
        /*tempStopDirController.refundEligible(zs.id, date.today(), date.today()-2, 10);
        tempStopDirController.checkSubFreq(1, 1);
        tempStopDirController.checkSubFreq(1, 2);
        tempStopDirController.checkSubFreq(1, 3);
        tempStopDirController.checkSubFreq(1, 4);
        tempStopDirController.checkSubFreq(1, 5);
        tempStopDirController.checkSubFreq(1, 6);
        tempStopDirController.checkSubFreq(1, 7);
        tempStopDirController.checkSubFreq(2, 1);
        tempStopDirController.checkSubFreq(2, 2);
        tempStopDirController.checkSubFreq(2, 3);
        tempStopDirController.checkSubFreq(2, 4);
        tempStopDirController.checkSubFreq(2, 5);
        tempStopDirController.checkSubFreq(2, 6);
        tempStopDirController.checkSubFreq(2, 7);
        tempStopDirController.checkSubFreq(3, 1);
        tempStopDirController.checkSubFreq(3, 2);
        tempStopDirController.checkSubFreq(3, 3);
        tempStopDirController.checkSubFreq(3, 4);
        tempStopDirController.checkSubFreq(3, 5);
        tempStopDirController.checkSubFreq(3, 6);
        tempStopDirController.checkSubFreq(3, 7);
        
        tempStopDirController.getFrequency('RPN123');*/
        Test.stopTest();
    } 
    /**
    *  To test TempStopDirectController
    *  @name TestTempStopDirectController4
    *  @param none
    *  @return none
    *  @throws na
    */
    Static testMethod void TestTempStopDirectController4() {   

        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
    
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;

        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        insert cas;

        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        
        lOLI.add(oli);
        Insert lOLI;
       
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+10;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = false;
        zs.Ph_e__c = true;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = '2';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today();
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today();
        TS.Restart_Date__c = date.today()+2;
        TS.Cancelled__c = true;
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'SKU123';
        SPC.Zuora__UOM__c = 'Copy Sat';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        system.assertNotEquals(null, npub); 
        
        Test.startTest();
        
        PageReference pageRef = page.TempStopDirect;
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId', accList[0].Id);
        TempStopDirectController tempStopDirController = new TempStopDirectController(); 
        tempStopDirController.getAccount();
        tempStopDirController.getSubscriptions();
       
        List<SelectOption> RequestSources = tempStopDirController.getRequestSources();
        List<SelectOption> TempStopType= tempStopDirController.getListTempStopType();
        String GselectedTempStopType = tempStopDirController.getselectedTempStopType();
        tempStopDirController.selectedTempStopType = 'Cancel Temp Stop Request';
        tempStopDirController.setTempStopType('Cancel Temp Stop Request');
        tempStopDirController.getErrorOnLimit();

        TempStopDirectController.SelectedWrapper WrapperUpdateRequestList = new TempStopDirectController.SelectedWrapper();
        TempStopDirectController.SubscriptionWrapper SubscriptionWrapperList = new TempStopDirectController.SubscriptionWrapper();
        tempStopDirController.checkDuplicateSubscriptionCancel();
        tempStopDirController.removeSubscriptionRecordUpdate();
        tempStopDirController.removeSubscriptionRecordCancel();
        tempStopDirController.setSelectedRecords();
        tempStopDirController.submit();
        tempStopDirController.cancel();
        tempStopDirController.validateLimit();
        tempStopDirController.deliverySub(c.Address_Unique_Id__c);     
        //tempStopDirController.getQuantity(zs.Id);
        //tempStopDirController.getTotalRefundForYear(zs.Id);
        tempStopDirController.setUpdateRecords();
        tempStopDirController.setCancelRecords();
        tempStopDirController.setSelectedRecords();
        //tempStopDirController.refundEligible(zs.id, date.today(), date.today()-2, 10);
        //tempStopDirController.getNonPub(zs.Id, date.today());
        tempStopDirController.publishedDayChecker(zs.Id, date.today()+2);
        //tempStopDirController.getFrequency('SKU123');
        Test.stopTest();
    } 
    /**
    *  To test TempStopDirectController
    *  @name TestTempStopDirectController5
    *  @param none
    *  @return none
    *  @throws na
    */
     Static testMethod void TestTempStopDirectController5() {   

        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
      
        accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;

        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    

        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;

        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        insert cas;
 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        
        lOLI.add(oli);
        Insert lOLI;
       
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+10;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today(); 
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today();
        TS.Restart_Date__c = date.today()+2;
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        system.assertNotEquals(null, npub);
        
        Test.startTest();
        
        PageReference pageRef = page.TempStopDirect;
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId', accList[0].Id);
        TempStopDirectController tempStopDirController = new TempStopDirectController(); 
        tempStopDirController.getAccount();
        tempStopDirController.getSubscriptions();
        
        List<SelectOption> RequestSources = tempStopDirController.getRequestSources();
        List<SelectOption> TempStopType= tempStopDirController.getListTempStopType();
        
        
        String GselectedTempStopType = tempStopDirController.getselectedTempStopType();
        tempStopDirController.selectedTempStopType = 'Update Temp Stop Request';
        tempStopDirController.setTempStopType('Update Temp Stop Request');
        tempStopDirController.getErrorOnLimit();

        TempStopDirectController.SelectedWrapper WrapperUpdateRequestList = new TempStopDirectController.SelectedWrapper();
        TempStopDirectController.SubscriptionWrapper SubscriptionWrapperList = new TempStopDirectController.SubscriptionWrapper();
        
        tempStopDirController.checkDuplicateSubscription();
        tempStopDirController.checkDuplicateSubscriptionUpdate();
        tempStopDirController.checkDuplicateSubscriptionCancel();
        tempStopDirController.removeSubscriptionRecordUpdate();
        tempStopDirController.removeSubscriptionRecordCancel(); 
        tempStopDirController.submit();
        tempStopDirController.cancel();      
        tempStopDirController.validateLimit();
        tempStopDirController.deliverySub(c.Address_Unique_Id__c);     
        //tempStopDirController.getQuantity(zs.Id);
        //tempStopDirController.getTotalRefundForYear(zs.Id);
        //tempStopDirController.refundEligible(zs.id, date.today(), date.today()+2, 10);
        //tempStopDirController.getFrequency('PUB123');
        tempStopDirController.validateLimit(10,10);
        tempStopDirController.validateLimit(12,10);
        tempStopDirController.removeSubscriptionRecord();
        //subscriptionwrapper
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.subscriptionResultList[0].earliestStartDate = null;    
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today()-2;
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.subscriptionResultList[0].earliestStartDate = null;    
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.today()-2;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.newInstance(2015, 05, 5);
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.newInstance(2015, 05, 5);
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.newInstance(2015, 11, 2);
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subStartDate = date.today()+10;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.today()+1;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
       
        Test.stopTest();
    } 
    /**
    *  To test TempStopDirectController
    *  @name TestTempStopDirectController6
    *  @param none
    *  @return none
    *  @throws na
    */
    Static testMethod void TestTempStopDirectController6() {   

        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
          
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
            
        accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;

        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        insert cas;

        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        
        lOLI.add(oli);
        Insert lOLI;
       
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+10;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today();
        pub.Product_Category__c = 'Print';
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today()+2;
        TS.Restart_Date__c = date.today();
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '0';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        system.assertNotEquals(null, npub);
        insert npub;
        
        Test.startTest();
        
        PageReference pageRef = page.TempStopDirect;
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId', accList[0].Id);
        TempStopDirectController tempStopDirController = new TempStopDirectController(); 
        tempStopDirController.getAccount();
        tempStopDirController.getSubscriptions();
        
        List<SelectOption> RequestSources = tempStopDirController.getRequestSources();
        List<SelectOption> TempStopType= tempStopDirController.getListTempStopType();
        
        
        String GselectedTempStopType = tempStopDirController.getselectedTempStopType();
        tempStopDirController.selectedTempStopType = 'Update Temp Stop Request';
        tempStopDirController.setTempStopType('Update Temp Stop Request');
        tempStopDirController.getErrorOnLimit();

        TempStopDirectController.SelectedWrapper WrapperUpdateRequestList = new TempStopDirectController.SelectedWrapper();
        TempStopDirectController.SubscriptionWrapper SubscriptionWrapperList = new TempStopDirectController.SubscriptionWrapper();
        
        tempStopDirController.checkDuplicateSubscription();
        tempStopDirController.checkDuplicateSubscriptionUpdate();
        tempStopDirController.checkDuplicateSubscriptionCancel();
        tempStopDirController.removeSubscriptionRecordUpdate();
        tempStopDirController.removeSubscriptionRecordCancel(); 
        tempStopDirController.submit();
        tempStopDirController.cancel();      
        tempStopDirController.validateLimit();
        tempStopDirController.deliverySub(c.Address_Unique_Id__c);     
        /*tempStopDirController.getQuantity(zs.Id);
        tempStopDirController.refundEligible(zs.id, date.today(), date.today()+2, 10);       
        tempStopDirController.getFrequency('PUB123');*/
        tempStopDirController.validateLimit(10,10);
        tempStopDirController.validateLimit(12,10);
        tempStopDirController.removeSubscriptionRecord();
        
        //subscriptionwrapper
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 1;
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.subscriptionResultList[0].earliestStartDate = null;    
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords();
        //
        tempStopDirController.subscriptionResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.subscriptionResultList[0].tp.Order__c = o.Id;
        tempStopDirController.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today()-2;
        tempStopDirController.subscriptionResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.subscriptionResultList[0].tp.Qty__c = 5;
        tempStopDirController.subscriptionResultList[0].earliestStartDate = null;    
        tempStopDirController.myId = tempStopDirController.subscriptionResultList[0].id;
        tempStopDirController.setSelectedRecords(); 
        
        //updateresultlist
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.today()-2;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.newInstance(2015, 05, 5);
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.newInstance(2015, 05, 5);
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.newInstance(2015, 11, 2);
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subStartDate = date.today()+10;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 
        //
        tempStopDirController.updateResultList[0].tp.Case__c = cas.Id;
        tempStopDirController.updateResultList[0].tp.Order__c = o.Id;
        tempStopDirController.updateResultList[0].tp.Temp_Stop_Date__c = date.today();
        tempStopDirController.updateResultList[0].tp.Restart_Date__c = date.today()+2;
        tempStopDirController.updateResultList[0].tp.Qty__c = 5;
        tempStopDirController.updateResultList[0].subEndDate = date.today()+1;
        tempStopDirController.myIdUpdate= tempStopDirController.updateResultList[0].id;
        tempStopDirController.setUpdateRecords(); 

        Test.stopTest();
    } 
}