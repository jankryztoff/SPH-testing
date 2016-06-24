/**
Class Name: BT_AB_HDS039DX_DR_SubscriptionTest
@author: accenture IDC (Sudha Kumari)
Date: 02/11/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_HDS039DX_DR_SubscriptionIssuesFile
**/
@isTest(seeAllData = false)
private class BT_AB_HDS039DX_DR_SubscriptionTest{

    static testmethod void subsIssueFile(){
        
             Database.BatchableContext BC;                  
           
             String interfaceId = 'ARM067DX';
             String batchRunDate= BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
             
             BT_CO_Batch_Run_Request__c brr = new BT_CO_Batch_Run_Request__c();
             brr.Batch_Run_Date__c = date.Today();
             brr.Interface_ID__c = 'ARM067DX';
             brr.End_Time__c = null;
             insert brr;
             
             Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
             insert dtl;
            
             BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
             bis.Name = 'Endpoint Delegator';
             bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
             insert bis; 
             
             List<Key_Id__c> newKeyid = TestDataFactory.createKeyIds();
             newKeyid[0].name = 'NEXT_RECIPIENT_NUMBER'; 
             newKeyid[0].Id__c = '1234';
             insert newKeyid;
                             
             Recordtype recType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Vendor'];
             account acc = new account();
             acc.Name = 'Hello';
             acc.Recordtypeid = rectype.id;
             acc.Account_Legacy_Id__c = '00112233';
             acc.Generate_Account_Number__c = TRUE;
             insert acc;
             
             Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
             postal.Name = 'PostalName';
             postal.Building_Name__c = 'Ebloc2';
             postal.Street_Name__c = 'Aviles';
             insert postal;
             
             Recordtype recType2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Local'];
             List<Address__c> addressList = TestDataFactory.createAddress(1);
             addressList[0].Recordtypeid = recType2.id;
             addressList[0].Postal_Code__c = postal.id;
             addressList[0].Level_Number__c = '21';
             addressList[0].Unit_Number__c = '15';
             addressList[0].Address_Unique_ID__c = 'ID112233';
             insert addressList;
             
             contact cont = new contact();
             cont.lastname = 'rert';
             cont.Accountid = acc.id;
             cont.Contact_Legacy_Id__c = '00998877';
             cont.Recipient_Indicator__c = TRUE;
             cont.Office_Number__c = '0244412322';
             //cont.Recipient_Number__c = '5629140';
             insert cont;
    
                    
             List<Publication__c> pub = TestDataFactory.createPublication(1);
             pub[0].name = 'test123';
             pub[0].Publication_Code__c = 'PUB1';
             pub[0].Published_Days__c = 'YYYYYYN';
             pub[0].Publication_Type__c = 'q';
             insert pub;
             
             Package__c pkg = new Package__c();
             pkg.Billing_Type__c = 'Add On';
             pkg.Package_Code__c = '5343';
             pkg.name = 'rwere';
             pkg.Effective_Start_Date__c = system.today();
             pkg.Effective_End_Date__c = system.today();
             insert pkg;
             
             List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
             billAcc[0].Zuora__Account__c = acc.id;
             billAcc[0].Zuora__DefaultPaymentMethod__c = 'Other';
             insert billAcc;
             
             List<Promotion__c> promo = TestDataFactory.createPromotion(1);
             promo[0].Effective_Start_Date__c = date.Today();
             promo[0].Effective_End_Date__c = date.Today() +60;
             promo[0].Contract_Period__c = '1';
             insert promo;
        
             
             Order__c order = TestDataFactory.createOrder(1)[0];
             order.Account__c = acc.Id;
             order.Informed_Customer__c = TRUE;
             order.Recipient_Contact__c = cont.Id;
             order.Subscriber_Charge__c = 100.00;
             order.DOW_Pattern__c = 'DowPattern';
             insert order;
      
             Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];//new Zuora__Subscription__c();
             zsub.Zuora__Account__c = acc.id;
             zsub.Zuora__CustomerAccount__c = billAcc[0].id;
             zsub.name = 'abs';
             zsub.Unique_Address_Id__c='wewe';
             zsub.Number_of_Copies__c = 23323223;
             zsub.Next_Earliest_Start_Date__c = system.today();
             zsub.Year_to_Date_Temp_Stop_Days__c = 3;
             zsub.Previous_Year_Temp_Stop_Days__c = 2;
             zsub.Legacy_Create_Date__c = 'xc';
             zsub.Legacy_Create_By__c = 'wq';
             zsub.Legacy_Update_Date__c = 'we';
             zsub.Legacy_Update_By__c = 'wer';
             zsub.Legacy_Subscription_ID__c = '234';
             zsub.Cheque_details__c = 'ew';
             zsub.DTL__c = 'rt';
             zsub.Paypal_Payment_Profile_Id__c = 're';
             zsub.Pub_Tag__c = 'reere';
             zsub.Sponsored_Indicator__c = 'er';
             zsub.Subscribe_As__c = 'rew';
             zsub.Zuora__SubscriptionEndDate__c = date.Today() +60;
             zsub.Zuora__SubscriptionStartDate__c = date.newInstance(2015, 08, 03);
             zsub.Subscription_Grace_Period_End_Date__c = 'rty';
             zsub.Gift_ID__c = 'ere';
             zsub.Redeem_Date__c = 'ukvvgk';
             zsub.Gift_ID_2__c = 'fdfs';
             zsub.Redeem_Date_2__c = 'fsf';
             zsub.Subscriber_Contact__c = cont.id;
             zsub.Subscription_Charge__c = 43;
             zsub.Term_Length__c = 43;
             zsub.Main_Package_1__c = pkg.id;
             zsub.Zuora__Zuora_Id__c = 'dsfdd';
             zsub.Subscription_Type_1__c = 'Publication';
             zsub.Subscription_Type__c = 'Publication';
             zsub.Recipient_Contact__c = cont.id;
             zsub.Product_Code__c = 'PROD12';
             zsub.Promotion_1__c = promo[0].id;
             zsub.Sponsor_1__c = TRUE;
             zsub.Order_Number_1__c = order.id;
             zsub.Zuora__TermStartDate__c = date.Today();
             zsub.Zuora__TermEndDate__c = date.Today() +60;
             zsub.Frequency_1__c = 'Mon - Fri';
             zsub.Frequency__c = 'Mon - Fri';
             insert zsub;
 
            
             List<BT_CO_VSS_CreditDebit__c> vssCred = TestdataFactory.createBT_CO_VSS_CreditDebit(1);
             vssCred[0].Subscription__c = zsub.id; //Entity is Deleted
             vssCred[0].Recipient_Contact__c = cont.id;
             vssCred[0].Vendor_Number__c = '123';
             vssCred[0].Publication_Code__c = 'PUB1';
             vssCred[0].Copies__c = 300;
             vssCred[0].Delivery__c = 50.00;
             vssCred[0].Commission__c = 100.00;
             vssCred[0].Manual_Amt__c = 75.00;
             vssCred[0].Insertion__c = 75.00;
             vssCred[0].Total_Amount__c = 1000.00;
             vssCred[0].Credit_Debit__c = 'D';
             vssCred[0].Note_Number__c = 123;
             vssCred[0].Pagination__c = 5;
             //vssCred[0].Posting_Date__c = date.Today() + 60;
             vssCred[0].Posting_Date__c = date.Today();
             vssCred[0].From__c = date.Today();
             vssCred[0].To__c = date.Today()+60;
             vssCred[0].Vendor_Group__c = 'A';
             insert vssCred;
             
                             
            List<sObject> scope = [SELECT Subscription__c, Vendor_Number__c, Publication_Code__c,
            Copies__c,
            Delivery__c,
            Commission__c,
            Manual_Amt__c,
            Insertion__c,
            Total_Amount__c,
            Credit_Debit__c,
            Note_Number__c,
            Pagination__c,
            Posting_Date__c,
            Recipient_Contact__c,
            From__c,
            To__c,
            Vendor_Group__c FROM BT_CO_VSS_CreditDebit__c];
                
         Test.StartTest();
             BT_AB_HDS039DX_DR_SubscriptionIssuesFile sif = new BT_AB_HDS039DX_DR_SubscriptionIssuesFile();
             database.executeBatch(sif,201);  
           //  sif.execute(BC,scope); 
         Test.StopTest();
    }
    
    static testmethod void teststartdate(){
        
             Database.BatchableContext BC;                  
           
             String interfaceId = 'ARM067DX';
             String batchRunDate= BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
             
             Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
             insert dtl;
            
             BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
             bis.Name = 'Endpoint Delegator';
             bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
             insert bis; 
             
             List<Key_Id__c> newKeyid = TestDataFactory.createKeyIds();
             newKeyid[0].name = 'NEXT_RECIPIENT_NUMBER'; 
             newKeyid[0].Id__c = '1234';
             insert newKeyid;
                             
             Recordtype recType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Vendor'];
             account acc = new account();
             acc.Name = 'Hello';
             acc.Recordtypeid = rectype.id;
             acc.Account_Legacy_Id__c = '00112233';
             acc.Generate_Account_Number__c = TRUE;
             insert acc;
             
             Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
             postal.Name = 'PostalName';
             postal.Building_Name__c = 'Ebloc2';
             postal.Street_Name__c = 'Aviles';
             insert postal;
             
             Recordtype recType2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Local'];
             List<Address__c> addressList = TestDataFactory.createAddress(1);
             addressList[0].Recordtypeid = recType2.id;
             addressList[0].Postal_Code__c = postal.id;
             addressList[0].Level_Number__c = '21';
             addressList[0].Unit_Number__c = '15';
             addressList[0].Address_Unique_ID__c = 'ID112233';
             insert addressList;
             
             contact cont = new contact();
             cont.lastname = 'rert';
             cont.Accountid = acc.id;
             cont.Contact_Legacy_Id__c = '00998877';
             cont.Recipient_Indicator__c = TRUE;
             cont.Office_Number__c = '0244412312';
             //cont.Recipient_Number__c = '5629140';
             insert cont;
    
                    
             Publication__c pub = new Publication__c();
             pub.name = 'test123';
             pub.Publication_Code__c = 'er3';
             pub.Published_Days__c = 'YYYYYYN';
             pub.Publication_Type__c = 'q';
             insert pub;
             
             Package__c pkg = new Package__c();
             pkg.Billing_Type__c = 'Add On';
             pkg.Package_Code__c = '5343';
             pkg.name = 'rwere';
             pkg.Effective_Start_Date__c = system.today();
             pkg.Effective_End_Date__c = system.today();
             insert pkg;
             
             List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
             billAcc[0].Zuora__Account__c = acc.id;
             billAcc[0].Zuora__DefaultPaymentMethod__c = 'Other';
             insert billAcc;
             
             List<Promotion__c> promo = TestDataFactory.createPromotion(1);
             promo[0].Effective_Start_Date__c = date.Today();
             promo[0].Effective_End_Date__c = date.Today() +60;
             promo[0].Contract_Period__c = '1';
             insert promo;
        
             
             Order__c order = TestDataFactory.createOrder(1)[0];
             order.Account__c = acc.Id;
             order.Informed_Customer__c = TRUE;
             order.Recipient_Contact__c = cont.Id;
             order.Subscriber_Charge__c = 100.00;
             order.DOW_Pattern__c = 'DowPattern';
             insert order;
            
             Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];//new Zuora__Subscription__c();
             zsub.Zuora__Account__c = acc.id;
             zsub.Zuora__CustomerAccount__c = billAcc[0].id;
             zsub.name = 'abs';
             zsub.Unique_Address_Id__c='wewe';
             zsub.Number_of_Copies__c = 23323223;
             zsub.Next_Earliest_Start_Date__c = system.today();
             zsub.Year_to_Date_Temp_Stop_Days__c = 3;
             zsub.Previous_Year_Temp_Stop_Days__c = 2;
             zsub.Legacy_Create_Date__c = 'xc';
             zsub.Legacy_Create_By__c = 'wq';
             zsub.Legacy_Update_Date__c = 'we';
             zsub.Legacy_Update_By__c = 'wer';
             zsub.Legacy_Subscription_ID__c = '234';
             zsub.Cheque_details__c = 'ew';
             zsub.DTL__c = 'rt';
             zsub.Paypal_Payment_Profile_Id__c = 're';
             zsub.Pub_Tag__c = 'reere';
             zsub.Sponsored_Indicator__c = 'er';
             zsub.Subscribe_As__c = 'rew';
             zsub.Zuora__SubscriptionEndDate__c = date.Today()+60;
             zsub.Zuora__SubscriptionStartDate__c = date.Today();
             zsub.Subscription_Grace_Period_End_Date__c = 'rty';
             zsub.Gift_ID__c = 'ere';
             zsub.Redeem_Date__c = 'ukvvgk';
             zsub.Gift_ID_2__c = 'fdfs';
             zsub.Redeem_Date_2__c = 'fsf';
             zsub.Subscriber_Contact__c = cont.id;
             zsub.Subscription_Charge__c = 43;
             zsub.Term_Length__c = 43;
             zsub.Main_Package_1__c = pkg.id;
             zsub.Zuora__Zuora_Id__c = 'dsfdd';
             zsub.Subscription_Type_1__c = 'Publication';
             zsub.Subscription_Type__c = 'Publication';
             zsub.Recipient_Contact__c = cont.id;
             zsub.Product_Code__c = 'PROD12';
             zsub.Promotion_1__c = promo[0].id;
             zsub.Sponsor_1__c = TRUE;
             zsub.Order_Number_1__c = order.id;
             zsub.Zuora__TermStartDate__c = date.Today();
             zsub.Zuora__TermEndDate__c = date.Today() +60;
             zsub.Frequency_1__c = 'Mon - Fri';
             zsub.Frequency__c = 'Mon - Fri';
             insert zsub;
             
            
             List<BT_CO_VSS_CreditDebit__c> vssCred = TestdataFactory.createBT_CO_VSS_CreditDebit(1);
             vssCred[0].Subscription__c = zsub.id; //Entity is Deleted
             vssCred[0].Recipient_Contact__c = cont.id;
             vssCred[0].Vendor_Number__c = '123';
             vssCred[0].Publication_Code__c = 'PUB1';
             vssCred[0].Copies__c = 300;
             vssCred[0].Delivery__c = 50.00;
             vssCred[0].Commission__c = 100.00;
             vssCred[0].Manual_Amt__c = 75.00;
             vssCred[0].Insertion__c = 75.00;
             vssCred[0].Total_Amount__c = 1000.00;
             vssCred[0].Credit_Debit__c = 'D';
             vssCred[0].Note_Number__c = 123;
             vssCred[0].Pagination__c = 5;
             vssCred[0].Posting_Date__c = date.Today();
             vssCred[0].From__c = null;
             vssCred[0].To__c = null;
             vssCred[0].Vendor_Group__c = 'A';
             insert vssCred;
   
                
         Test.StartTest();
             BT_AB_HDS039DX_DR_SubscriptionIssuesFile sif = new BT_AB_HDS039DX_DR_SubscriptionIssuesFile();
             database.executeBatch(sif,201);
         Test.StopTest();
    }
    static testmethod void testSubIdNull(){
        
             Database.BatchableContext BC;                  
           
             String interfaceId = 'ARM067DX';
             String batchRunDate= BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
             
             BT_CO_Batch_Run_Request__c brr = new BT_CO_Batch_Run_Request__c();
             brr.Batch_Run_Date__c = date.Today();
             brr.Interface_ID__c = 'ARM067DX';
             brr.End_Time__c = null;
             insert brr;
             
             Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
             insert dtl;
            
             BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
             bis.Name = 'Endpoint Delegator';
             bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
             insert bis; 
             
             List<Key_Id__c> newKeyid = TestDataFactory.createKeyIds();
             newKeyid[0].name = 'NEXT_RECIPIENT_NUMBER'; 
             newKeyid[0].Id__c = '1234';
             insert newKeyid;
                             
             Recordtype recType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Vendor'];
             account acc = new account();
             acc.Name = 'Hello';
             acc.Recordtypeid = rectype.id;
             acc.Account_Legacy_Id__c = '00112233';
             acc.Generate_Account_Number__c = TRUE;
             insert acc;
             
             Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
             postal.Name = 'PostalName';
             postal.Building_Name__c = 'Ebloc2';
             postal.Street_Name__c = 'Aviles';
             insert postal;
             
             Recordtype recType2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Local'];
             List<Address__c> addressList = TestDataFactory.createAddress(1);
             addressList[0].Recordtypeid = recType2.id;
             addressList[0].Postal_Code__c = postal.id;
             addressList[0].Level_Number__c = '21';
             addressList[0].Unit_Number__c = '15';
             addressList[0].Address_Unique_ID__c = 'ID112233';
             insert addressList;
             
             contact cont = new contact();
             cont.lastname = 'rert';
             cont.Accountid = acc.id;
             cont.Contact_Legacy_Id__c = '00998877';
             cont.Office_Number__c = '0244332322';
             cont.Recipient_Indicator__c = TRUE;
             //cont.Recipient_Number__c = '5629140';
             insert cont;
    
                    
             List<Publication__c> pub = TestDataFactory.createPublication(1);
             pub[0].name = 'test123';
             pub[0].Publication_Code__c = 'PUB1';
             pub[0].Published_Days__c = 'YYYYYYN';
             pub[0].Publication_Type__c = 'q';
             insert pub;
             
             Package__c pkg = new Package__c();
             pkg.Billing_Type__c = 'Add On';
             pkg.Package_Code__c = '5343';
             pkg.name = 'rwere';
             pkg.Effective_Start_Date__c = system.today();
             pkg.Effective_End_Date__c = system.today();
             insert pkg;
             
             List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
             billAcc[0].Zuora__Account__c = acc.id;
             billAcc[0].Zuora__DefaultPaymentMethod__c = 'Other';
             insert billAcc;
             
             List<Promotion__c> promo = TestDataFactory.createPromotion(1);
             promo[0].Effective_Start_Date__c = date.Today();
             promo[0].Effective_End_Date__c = date.Today() +60;
             promo[0].Contract_Period__c = '1';
             insert promo;
        
             
             Order__c order = TestDataFactory.createOrder(1)[0];
             order.Account__c = acc.Id;
             order.Informed_Customer__c = TRUE;
             order.Recipient_Contact__c = cont.Id;
             order.Subscriber_Charge__c = 100.00;
             order.DOW_Pattern__c = 'DowPattern';
             insert order;
      
             Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];//new Zuora__Subscription__c();
             zsub.Zuora__Account__c = acc.id;
             zsub.Zuora__CustomerAccount__c = billAcc[0].id;
             zsub.name = 'abs';
             zsub.Unique_Address_Id__c='wewe';
             zsub.Number_of_Copies__c = 23323223;
             zsub.Next_Earliest_Start_Date__c = system.today();
             zsub.Year_to_Date_Temp_Stop_Days__c = 3;
             zsub.Previous_Year_Temp_Stop_Days__c = 2;
             zsub.Legacy_Create_Date__c = 'xc';
             zsub.Legacy_Create_By__c = 'wq';
             zsub.Legacy_Update_Date__c = 'we';
             zsub.Legacy_Update_By__c = 'wer';
             zsub.Legacy_Subscription_ID__c = '234';
             zsub.Cheque_details__c = 'ew';
             zsub.DTL__c = 'rt';
             zsub.Paypal_Payment_Profile_Id__c = 're';
             zsub.Pub_Tag__c = 'reere';
             zsub.Sponsored_Indicator__c = 'er';
             zsub.Subscribe_As__c = 'rew';
             zsub.Zuora__SubscriptionEndDate__c = date.Today() +60;
             zsub.Zuora__SubscriptionStartDate__c = date.newInstance(2015, 08, 03);
             zsub.Subscription_Grace_Period_End_Date__c = 'rty';
             zsub.Gift_ID__c = 'ere';
             zsub.Redeem_Date__c = 'ukvvgk';
             zsub.Gift_ID_2__c = 'fdfs';
             zsub.Redeem_Date_2__c = 'fsf';
             zsub.Subscriber_Contact__c = cont.id;
             zsub.Subscription_Charge__c = 43;
             zsub.Term_Length__c = 43;
             zsub.Main_Package_1__c = pkg.id;
             zsub.Zuora__Zuora_Id__c = 'dsfdd';
             zsub.Subscription_Type_1__c = 'Publication';
             zsub.Subscription_Type__c = 'Publication';
             zsub.Recipient_Contact__c = cont.id;
             zsub.Product_Code__c = 'PROD12';
             zsub.Promotion_1__c = promo[0].id;
             zsub.Sponsor_1__c = TRUE;
             zsub.Order_Number_1__c = order.id;
             zsub.Zuora__TermStartDate__c = date.Today();
             zsub.Zuora__TermEndDate__c = date.Today() +60;
             zsub.Frequency_1__c = 'Mon - Fri';
             zsub.Frequency__c = 'Mon - Fri';
             insert zsub;
 
            
             List<BT_CO_VSS_CreditDebit__c> vssCred = TestdataFactory.createBT_CO_VSS_CreditDebit(1);
             vssCred[0].Subscription__c = null; //Entity is Deleted
             vssCred[0].Recipient_Contact__c = cont.id;
             vssCred[0].Vendor_Number__c = '123';
             vssCred[0].Publication_Code__c = 'PUB1';
             vssCred[0].Copies__c = 300;
             vssCred[0].Delivery__c = 50.00;
             vssCred[0].Commission__c = 100.00;
             vssCred[0].Manual_Amt__c = 75.00;
             vssCred[0].Insertion__c = 75.00;
             vssCred[0].Total_Amount__c = 1000.00;
             vssCred[0].Credit_Debit__c = 'D';
             vssCred[0].Note_Number__c = 123;
             vssCred[0].Pagination__c = 5;
             vssCred[0].Posting_Date__c = date.Today();
             vssCred[0].From__c = date.Today();
             vssCred[0].To__c = date.Today()+60;
             vssCred[0].Vendor_Group__c = 'A';
             insert vssCred;
             
               
         Test.StartTest();
             BT_AB_HDS039DX_DR_SubscriptionIssuesFile sif = new BT_AB_HDS039DX_DR_SubscriptionIssuesFile();
             database.executeBatch(sif,201);  
         Test.StopTest();
         }
}