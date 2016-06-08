@isTest(seeAllData = false)

public class SP_CreateDelChargeUsageBatchTest {

    static void defaultCustomSetting(){
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;

        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};

        List<Key_Id__c> keyList = new List<Key_Id__c>();
        /*
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        */
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

        Date_Configuration__c dateConfig = new Date_Configuration__c();
        dateConfig.Name = 'Usage Reference Date';
        dateConfig.Date__c = date.today().addDays(21);
        insert dateConfig;
    }

    static testmethod void test() {

        defaultCustomSetting();

        Account acct = new Account();
        acct = TestDataFactory.createAccount(5, 'Direct Individual')[0];
        insert acct;

        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Unique_ID__c = '123152test';
        insert add; 

        Key_Id__c key = new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', Id__c = '123462697', Type__c = 'Number');
        insert key;

        Contact con = TestDataFactory.createContact(1)[0];
        con.Recipient_Indicator__c = true;
        con.Address__c = add.Id;
        con.AccountId = acct.Id; //PD-0354
        insert con;

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        //billAcc.Zuora__AccountNumber__c = 'z123sgd';
        billAcc.Zuora__Account__c = acct.Id;
        insert billAcc;

        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__Account__c = acct.Id;
        subscription.Recipient_Contact__c = con.Id;
        subscription.Recipient_Contact_1__c = con.Id;
        subscription.Subscription_Type_1__c =  'Delivery';
        subscription.Subscription_Type__c = 'Delivery';
        subscription.Zuora__CustomerAccount__c = billAcc.Id;
        subscription.Billing_Type__c = 'Full Prepaid';
        subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
        subscription.New_Contract_Period_1__c = 1;
        subscription.Contract_End_Date_1__c = date.Today();
        subscription.Zuora__Status__c = 'Active';
        subscription.Zuora__SubscriptionEndDate__c = null;
        insert subscription; 

        Test.startTest();
            SP_CreateDelChargeUsageBatch batch = new SP_CreateDelChargeUsageBatch();
            ID batchprocessid = Database.executeBatch(batch);

            Set<String> s = new Set<String>(); // Define a new set
            s.add(subscription.Id);
            SP_CreateDelChargeUsageBatch batch2 = new SP_CreateDelChargeUsageBatch(s, 2);
            SP_CreateDelChargeUsageBatch batch3 = new SP_CreateDelChargeUsageBatch(s, 1);
            SP_CreateDelChargeUsageBatch batch4 = new SP_CreateDelChargeUsageBatch(null, 2);
        Test.stopTest();
    }

    static testmethod void test1() {
        defaultCustomSetting();

        Account acct = new Account();
        acct = TestDataFactory.createAccount(5, 'Direct Individual')[0];
        insert acct;

        Key_Id__c key = new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', Id__c = '123462697', Type__c = 'Number');
        insert key;

        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Unique_ID__c = '123152test';
        insert add; 

        Contact con = TestDataFactory.createContact(1)[0];
        con.Recipient_Indicator__c = true;
        con.Address__c = add.Id;
        con.AccountId = acct.Id; //PD-0354
        insert con;

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        //billAcc.Zuora__AccountNumber__c = 'z123sgd';
        billAcc.Zuora__Account__c = acct.Id;
        insert billAcc;

        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__Zuora_Id__c  = '123456789';
        subscription.Zuora__Account__c = acct.Id;
        subscription.Recipient_Contact__c = con.Id;
        subscription.Recipient_Contact_1__c = con.Id;
        subscription.Subscription_Type_1__c =  'DELIVERY';
        subscription.Subscription_Type__c = 'DELIVERY';
        subscription.Zuora__CustomerAccount__c = billAcc.Id;
        subscription.Billing_Type__c = 'RECURRING PREPAID';
        subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
        subscription.New_Contract_Period_1__c = 1;
        subscription.Contract_End_Date_1__c = date.Today();
        subscription.Zuora__Status__c = 'Active';
        subscription.Zuora__SubscriptionEndDate__c = null;
        insert subscription; 

        Invoice_Line_Item__c invoice = new Invoice_Line_Item__c();
        invoice.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
        invoice.Charge_Amount__c = 100;
        insert invoice;

        Zuora__SubscriptionProductCharge__c subsProd = testDataFactory.createSubscriptionProductCharge(1)[0];
        subsProd.Zuora__UOM__c = 'LANDED'; 
        subsProd.Zuora__Subscription__c = subscription.Id;
        insert subsProd;

        Test.startTest();
            SP_CreateDelChargeUsageBatch batch = new SP_CreateDelChargeUsageBatch();
            ID batchprocessid = Database.executeBatch(batch);

            Set<String> s = new Set<String>(); // Define a new set
            s.add(subscription.Id);
            SP_CreateDelChargeUsageBatch batch2 = new SP_CreateDelChargeUsageBatch(s, 2);
            SP_CreateDelChargeUsageBatch batch3 = new SP_CreateDelChargeUsageBatch(s, 1);
            SP_CreateDelChargeUsageBatch batch4 = new SP_CreateDelChargeUsageBatch(null, 2);
        Test.stopTest();
    }

    static testmethod void test2() {
        defaultCustomSetting();

        Account acct = new Account();
        acct = TestDataFactory.createAccount(5, 'Direct Individual')[0];
        insert acct;

        Key_Id__c key = new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', Id__c = '123462697', Type__c = 'Number');
        insert key;

        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Unique_ID__c = '123152test';
        insert add; 

        Contact con = TestDataFactory.createContact(1)[0];
        con.Recipient_Indicator__c = true;
        con.Address__c = add.Id;
        con.AccountId = acct.Id; //PD-0354
        insert con;

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        //billAcc.Zuora__AccountNumber__c = 'z123sgd';
        billAcc.Zuora__Account__c = acct.Id;
        insert billAcc;

        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__Account__c = acct.Id;
        subscription.Recipient_Contact__c = con.Id;
        subscription.Recipient_Contact_1__c = con.Id;
        subscription.Subscription_Type_1__c =  'DELIVERY';
        subscription.Subscription_Type__c = 'DELIVERY';
        subscription.Zuora__CustomerAccount__c = billAcc.Id;
        subscription.Billing_Type__c = 'RECURRING POSTPAID';
        subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
        subscription.New_Contract_Period_1__c = 1;
        subscription.Contract_End_Date_1__c = date.today().addDays(21).toStartOfMonth();
        subscription.Zuora__Status__c = 'Active';
        subscription.Zuora__SubscriptionEndDate__c = date.today().addDays(30).toStartOfMonth();
        insert subscription; 

        Zuora__SubscriptionProductCharge__c subsProd = testDataFactory.createSubscriptionProductCharge(1)[0];
        subsProd.Zuora__UOM__c = 'LANDED'; 
        subsProd.Zuora__Subscription__c = subscription.Id;
        insert subsProd;

        Test.startTest();
            SP_CreateDelChargeUsageBatch batch = new SP_CreateDelChargeUsageBatch();
            ID batchprocessid = Database.executeBatch(batch);

            Set<String> s = new Set<String>(); // Define a new set
            s.add(subscription.Id);
            SP_CreateDelChargeUsageBatch batch2 = new SP_CreateDelChargeUsageBatch(s, 2);
            SP_CreateDelChargeUsageBatch batch3 = new SP_CreateDelChargeUsageBatch(s, 1);
            SP_CreateDelChargeUsageBatch batch4 = new SP_CreateDelChargeUsageBatch(null, 2);
        Test.stopTest();
    }

    static testmethod void test3() {
        defaultCustomSetting();
        Account acct = new Account();
        acct = TestDataFactory.createAccount(5, 'Direct Individual')[0];
        insert acct;

        Key_Id__c key = new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', Id__c = '123462697', Type__c = 'Number');
        insert key;

        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Unique_ID__c = '123152test';
        insert add; 

        Contact con = TestDataFactory.createContact(1)[0];
        con.Recipient_Indicator__c = true;
        con.Address__c = add.Id;
        con.AccountId = acct.Id; //PD-0354
        insert con;

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        //billAcc.Zuora__AccountNumber__c = 'z123sgd';
        billAcc.Zuora__Account__c = acct.Id;
        insert billAcc;

        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__Account__c = acct.Id;
        subscription.Recipient_Contact__c = con.Id;
        subscription.Recipient_Contact_1__c = con.Id;
        subscription.Subscription_Type_1__c =  'DELIVERY';
        subscription.Subscription_Type__c = 'DELIVERY';
        subscription.Zuora__CustomerAccount__c = billAcc.Id;
        subscription.Billing_Type__c = 'RECURRING PREPAID';
        subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
        subscription.New_Contract_Period_1__c = 1;
        subscription.Contract_End_Date_1__c = date.today().addDays(21).toStartOfMonth();
        subscription.Zuora__Status__c = 'Active';
        subscription.Zuora__SubscriptionEndDate__c = date.today().addDays(21).toStartOfMonth();
        insert subscription; 

        Test.startTest();
            SP_CreateDelChargeUsageBatch batch = new SP_CreateDelChargeUsageBatch();
            ID batchprocessid = Database.executeBatch(batch);

            Set<String> s = new Set<String>(); // Define a new set
            s.add(subscription.Id);
            SP_CreateDelChargeUsageBatch batch2 = new SP_CreateDelChargeUsageBatch(s, 2);
            SP_CreateDelChargeUsageBatch batch3 = new SP_CreateDelChargeUsageBatch(s, 1);
            SP_CreateDelChargeUsageBatch batch4 = new SP_CreateDelChargeUsageBatch(null, 2);
        Test.stopTest();
    }
    /*
    static testmethod void testReferenceIdIsNull() {
        
        defaultCustomSetting();
        Account acct = new Account();
        
        //create vendor subscriber acct
        acct = TestDataFactory.createAccount(5, 'Direct Individual')[0];
        insert acct;
        
       Address__c add = TestDataFactory.createAddress(1)[0];
       add.Address_Unique_ID__c = '123152test';
       insert add; 
        
       Contact con = TestDataFactory.createContact(1)[0];
       con.Recipient_Indicator__c = true;
       con.Address__c = add.Id;
       insert con;
       
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       //billAcc.Zuora__AccountNumber__c = 'z123sgd';
       billAcc.Zuora__Account__c = acct.Id;
       insert billAcc;
        
       Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
       subscription.Zuora__Account__c = acct.Id;
       subscription.Recipient_Contact__c = con.Id;
       subscription.Subscription_Type_1__c =  'Delivery';
       subscription.Zuora__CustomerAccount__c = billAcc.Id;
       subscription.Billing_Type__c = 'Full Prepaid';
       subscription.Zuora__SubscriptionStartDate__c = date.Today()+14;
       subscription.New_Contract_Period_1__c = 1;
       subscription.Contract_End_Date_1__c = date.Today();
       subscription.Zuora__Status__c = 'Active';
       subscription.Zuora__SubscriptionEndDate__c = date.Today()+15;
       insert subscription; 
       
       Test.startTest();
       
       SP_CreateDelChargeUsageBatch batch = new SP_CreateDelChargeUsageBatch();
       ID batchprocessid = Database.executeBatch(batch);
       
       Set<String> s = new Set<String>(); // Define a new set
       s.add(batchprocessid); 
       SP_CreateDelChargeUsageBatch batch2 = new SP_CreateDelChargeUsageBatch(null, 2);
       SP_CreateDelChargeUsageBatch batch3 = new SP_CreateDelChargeUsageBatch(s, 1);
       
       Test.stopTest();
    } */
}