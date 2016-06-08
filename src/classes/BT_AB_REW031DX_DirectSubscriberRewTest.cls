/**
Class Name: BT_AB_REW031DX_DirectSubscriberRewTest
@author: Accentrue IDC (Sudha Kumari)
Date: 02/11/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_REW031DX_DirectSubscriberRewards
**/
@isTest //(Seealldata = true)
private class BT_AB_REW031DX_DirectSubscriberRewTest {

    static testmethod void unitTest1(){
        BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis; 
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Account_Direct Individual';
        key.Id__c = '012N00000008l27IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        insert subRecs;
        
        Zuora__SubscriptionProductCharge__c zspc = new Zuora__SubscriptionProductCharge__c();
        zspc.name = 'dfdsf';
        zspc.Zuora__ProductSKU__c = 'SKU01';
        zspc.Zuora__Zuora_Id__c = 'dfgdfg';
        zspc.Zuora__Subscription__c = subRecs.Id;
        zspc.Zuora__Account__c = acc.Id;
        insert zspc;
        
        zqu__ZProduct__c zzp = new zqu__ZProduct__c();
        zzp.name = 'dfdfdf';
        zzp.zqu__ZuoraId__c = 'ret45r';
        zzp.zqu__SKU__c = 'SKU01';
        zzp.ProductCode__c = 'dfd';
        zzp.ProductSubType__c = 'Newspaper';
        insert zzp;
        
        BA_INT_DATA_POOL__c bidp = new BA_INT_DATA_POOL__c();
        bidp.name = 'dfdf';
        bidp.job_id__c = 'sdfsdf';
        bidp.group_id__c = 'sdfse';
        bidp.run_for_date__c = system.today();
        bidp.insert_time__c = system.now();
        insert bidp;
        
        test.starttest();   
        BT_AB_REW031DX_DirectSubscriberRewards dsr = new BT_AB_REW031DX_DirectSubscriberRewards();
        database.executebatch(dsr, 200);
        test.stoptest();
    }//end of unitTest1
    
   // static testmethod void unitTest2(){
       /* BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis; */
            
     /*      User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [Select Id From Profile Where Name = 'CSO Admin' LIMIT 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
            );
        
        
            System.runAs(testUser) {

                Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
                insert dtl;
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = 'Test Name';
    
                Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Date_of_Birth__c = date.today();
                acc.REcordTypeId = [SELECT Id from RecordType WHERE Name = 'Vendor Subscriber'].id;
                acc.AccountNumber = '12354';
                
    
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                insert new List<sObject>{postal, acc, pack};
              
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                billAcc.Billing_Type__c = 'Full Prepaid';
                insert billAcc;
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c = '123';
                addressRec.Level_Number__c = '123';
                insert addressRec;
                
                System.assertEquals(addressRec.Postal_Code__c, postal.Id);
     
                Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBER';
                key.Id__c = '123457397';
                key.Type__c = 'Number';
                insert key;
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                // START : CCB 002 12/2/2014 Editedt By Alyana P. Navarro;
                RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
                con.RecordTypeId = rt.id;
                con.Recipient_Indicator__c = true;
                con.NRIC__c = 'T1234567R';
                con.Phone = '123456';
                con.Email__c = 'email@test.com';
                // END : CCB 002 12/2/2014
                insert con;
                
                System.assertEquals(con.AccountId, acc.Id);
    
                
                Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = con.Id;
                
                insert orderRec;
                
                Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
                cirPlanSched.Name = 'CIR Plan Schedule';
                cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
                cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
                cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
                cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                insert cirPlanSched;
                            
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                  
                List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
                Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
                subs.Zuora__Account__c = acc.Id;
                subs.Zuora__Zuora_Id__c = '1123';
                subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subs.Subscriber_Contact__c = con.Id;
                subs.Recipient_Contact__c = con.Id;
                subs.Main_Package_1__c = pack.id;
                subs.Zuora__Status__c = 'Active';
                //subs.Order_Number__c = orderRec.Id;
                subs.Suppress_Vendor_Start_Notice__c = 'false';
                subs.Supressed_Acknowledgement_Letter__c = 'false';
                subs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subs.Urgent__c = 'false';
                subs.Vendor_Conversion__c = 'false';
                subs.Charity__c = 'false';
                //subs.Billing_Type__c = 'Recurring Prepaid';
                subs.Billing_Type__c = 'Full Prepaid';
                subs.Zuora__SubscriptionStartDate__c = date.today();
                subs.Subscription_Charge__c = 10.00;
                subs.Subscription_Type__c = 'Publication';
                subs.Subscription_Type_1__c = 'Publication';
                subs.Zuora__Status__c = 'Active';
                subs.Zuora__TermSettingType__c = 'EVERGREEN';
                subs.Grace_Period_Subscription__c = null;
                subs.Zuora__CustomerAccount__c =billAcc.Id;
                
                
                subsList.add(subs);
                insert subsList;
                
                List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
                zSubProdCharge[0].Name = 'SPC_NAME';
                zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
                zSubProdCharge[0].Zuora__Subscription__c = subsList[0].id;
                zSubProdCharge[0].Zuora__RatePlanName__c = 'RATE_PLAN_NAME';
                zSubProdCharge[0].Zuora__ProductName__c = 'TEST NAME';
                zSubProdCharge[0].Product_Code__c = 'PUBX';
                zSubProdCharge[0].Zuora__Price__c = 20;
                zSubProdCharge[0].Zuora__BillingPeriod__c = 'Quarterly';
                zSubProdCharge[0].Zuora__Quantity__c = 18732;
                zSubProdCharge[0].Zuora__UOM__c ='ZuoraUOM';
                zSubProdCharge[0].Zuora__Type__c = 'Usage';
                insert zSubProdCharge; 
                
                 Set<String> skuSet = new Set<String>();
                 skuSet.add('test string');
                  
               }
    }*/
}