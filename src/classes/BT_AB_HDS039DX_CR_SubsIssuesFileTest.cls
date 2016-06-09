/** * Class Name: BT_AB_VSS090DX_ExportVendorSubsTest      
* @author: Accenture AprilVeloso        
* Requirement/Project Name: SPH Project     
* @description Test Class for BT_AB_HDS039DX_CR_SubscriptionIssuesFile     
*/

@isTest (SeeAllData = true)
public class BT_AB_HDS039DX_CR_SubsIssuesFileTest{

    private static List<Zuora__Subscription__c> zsubList;
    
    static testmethod void testSubscriptionNotNull() {  // <-- This is the Original Test Method Signature                                  

        String interfaceId = 'ARM067DX';
             String batchRunDate= BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
             
             BT_CO_Batch_Run_Request__c brr = new BT_CO_Batch_Run_Request__c();
             brr.Batch_Run_Date__c = date.Today();
             brr.Interface_ID__c = 'ARM067DX';
             brr.End_Time__c = null;
             insert brr;
             /*           
             BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
             bis.Name = 'Endpoint Delegator';
             bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
             insert bis; 
            
             List<Key_Id__c> newKeyid = TestDataFactory.createKeyIds();
             newKeyid[0].name = 'NEXT_RECIPIENT_NUMBER'; 
             newKeyid[0].Id__c = '1234';
             insert newKeyid;*/
                             
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
             addressList[0].Block_House_Number__c = '10';
             insert addressList;
             
             contact cont = new contact();
             cont.lastname = 'rert';
             cont.Accountid = acc.id;
             cont.Contact_Legacy_Id__c = '00998877';
             cont.Recipient_Indicator__c = TRUE;
             cont.HomePhone__c = '123456';
             //cont.Recipient_Number__c = '5629140';
             insert cont;
    
                    
             List<Publication__c> pub = TestDataFactory.createPublication(1);
             pub[0].name = 'test123';
             pub[0].Publication_Code__c = 'PUB1';
             pub[0].Published_Days__c = 'YYYYYYN';
             pub[0].Publication_Type__c = 'q';
             pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
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
             zsub.Term_Length__c = 5;
             zsub.Zuora__Status__c = 'Cancelled';
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
             vssCred[0].Credit_Debit__c = 'C';
             vssCred[0].Note_Number__c = 123;
             vssCred[0].Pagination__c = 5;
             //vssCred[0].Posting_Date__c = date.Today() + 60;
             vssCred[0].Posting_Date__c = date.Today();
             vssCred[0].From__c = date.Today();
             vssCred[0].To__c = date.Today()+60;
             vssCred[0].Vendor_Group__c = 'A';
             vssCred[0].Address__c = addressList[0].id;
             insert vssCred;
             
       
                                                  
        BT_AB_HDS039DX_CR_SubscriptionIssuesFile batch = new BT_AB_HDS039DX_CR_SubscriptionIssuesFile();        
        //ID batchprocessid = Database.executeBatch(batch,200);        
        //System.assertNotEquals(null, batchprocessid); 
        

     }
     
       static testmethod void teststartdate(){
        
             Database.BatchableContext BC;                  
           
             String interfaceId = 'ARM067DX';
             String batchRunDate= BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
             
             /*APRIL Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
             insert dtl;
            
             BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
             bis.Name = 'Endpoint Delegator';
             bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
             insert bis; 
             
             List<Key_Id__c> newKeyid = TestDataFactory.createKeyIds();
             newKeyid[0].name = 'NEXT_RECIPIENT_NUMBER'; 
             newKeyid[0].Id__c = '1234';
             insert newKeyid; APRIL*/
                             
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
             addressList[0].Block_House_Number__c = '10';
             insert addressList;
             
             contact cont = new contact();
             cont.lastname = 'rert';
             cont.Accountid = acc.id;
             cont.Contact_Legacy_Id__c = '00998877';
             cont.Recipient_Indicator__c = TRUE;
             cont.HomePhone__c = '123456';
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
             zsub.Zuora__SubscriptionEndDate__c = date.Today() +60;
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
             vssCred[0].Credit_Debit__c = 'C';
             vssCred[0].Note_Number__c = 123;
             vssCred[0].Pagination__c = 5;
             vssCred[0].Posting_Date__c = date.Today();
             vssCred[0].From__c = null;
             vssCred[0].To__c = null;
             vssCred[0].Vendor_Group__c = 'A';
             vssCred[0].Address__c = addressList[0].id;
             
               
                
         Test.StartTest();
                                                        
        BT_AB_HDS039DX_CR_SubscriptionIssuesFile batch = new BT_AB_HDS039DX_CR_SubscriptionIssuesFile();        
        //ID batchprocessid = Database.executeBatch(batch,200);        
        //System.assertNotEquals(null, batchprocessid); 
         Test.StopTest();
    }
    static testmethod void testSubscriptionNull(){
        
             Database.BatchableContext BC;                  
           
             String interfaceId = 'ARM067DX';
             String batchRunDate= BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
             
             /*APRIL Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
             insert dtl;
            
             BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
             bis.Name = 'Endpoint Delegator';
             bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
             insert bis; 
             
             List<Key_Id__c> newKeyid = TestDataFactory.createKeyIds();
             newKeyid[0].name = 'NEXT_RECIPIENT_NUMBER'; 
             newKeyid[0].Id__c = '1234';
             insert newKeyid; APRIL*/
                             
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
             cont.HomePhone__c = '123456';
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
             zsub.Zuora__SubscriptionEndDate__c = date.Today() +60;
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
             vssCred[0].Subscription__c = zSub.id; //Entity is Deleted
             vssCred[0].Recipient_Contact__c = cont.id;
             vssCred[0].Vendor_Number__c = '123';
             vssCred[0].Publication_Code__c = 'PUB1';
             vssCred[0].Copies__c = 300;
             vssCred[0].Delivery__c = 50.00;
             vssCred[0].Commission__c = 100.00;
             vssCred[0].Manual_Amt__c = 75.00;
             vssCred[0].Insertion__c = 75.00;
             vssCred[0].Total_Amount__c = 1000.00;
             vssCred[0].Credit_Debit__c = 'C';
             vssCred[0].Note_Number__c = 123;
             vssCred[0].Pagination__c = 5;
             vssCred[0].Posting_Date__c = date.Today();
             vssCred[0].From__c = null;
             vssCred[0].To__c = null;
             vssCred[0].Vendor_Group__c = 'A';
            
             insert vssCred;
   
                
         Test.StartTest();
                                                        
        BT_AB_HDS039DX_CR_SubscriptionIssuesFile batch = new BT_AB_HDS039DX_CR_SubscriptionIssuesFile();        
        //ID batchprocessid = Database.executeBatch(batch,200);        
        //System.assertNotEquals(null, batchprocessid); 
         Test.StopTest();
    } 
    static testmethod void testSubscriptionNull2(){
        
             Database.BatchableContext BC;                  
           
             String interfaceId = 'ARM067DX';
             String batchRunDate= BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
             
             /*APRIL Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
             insert dtl;
            
             BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
             bis.Name = 'Endpoint Delegator';
             bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
             insert bis; 
             
             List<Key_Id__c> newKeyid = TestDataFactory.createKeyIds();
             newKeyid[0].name = 'NEXT_RECIPIENT_NUMBER'; 
             newKeyid[0].Id__c = '1234';
             insert newKeyid; APRIL*/
                             
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
             cont.HomePhone__c = '123456';
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
             zsub.Zuora__SubscriptionEndDate__c = date.Today() +60;
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
            // vssCred[0].Subscription__c = zSub.id; //Entity is Deleted
             vssCred[0].Recipient_Contact__c = cont.id;
             vssCred[0].Vendor_Number__c = '123';
             vssCred[0].Publication_Code__c = 'PUB1';
             vssCred[0].Copies__c = 300;
             vssCred[0].Delivery__c = 50.00;
             vssCred[0].Commission__c = 100.00;
             vssCred[0].Manual_Amt__c = 75.00;
             vssCred[0].Insertion__c = 75.00;
             vssCred[0].Total_Amount__c = 1000.00;
             vssCred[0].Credit_Debit__c = 'C';
             vssCred[0].Note_Number__c = 123;
             vssCred[0].Pagination__c = 5;
             vssCred[0].Posting_Date__c = date.Today();
             vssCred[0].From__c = null;
             vssCred[0].To__c = null;
             vssCred[0].Vendor_Group__c = 'A';
            
             insert vssCred;
   
                
         Test.StartTest();
                                                        
        BT_AB_HDS039DX_CR_SubscriptionIssuesFile batch = new BT_AB_HDS039DX_CR_SubscriptionIssuesFile();        
        //ID batchprocessid = Database.executeBatch(batch,200);        
        //System.assertNotEquals(null, batchprocessid); 
         Test.StopTest();
    } 
  /*   static testmethod void testSubscriptionIsNull() {  // <-- This is the Original Test Method Signature                                  

             
        prepareTestData();
        
        BT_CO_VSS_CreditDebit__c cdValue = new BT_CO_VSS_CreditDebit__c();
        cdValue.Credit_Debit__c = 'C';
        cdValue.Vendor_Number__c = '1';
        cdValue.Vendor_Group__c = '1';
        cdValue.Posting_Date__c = date.today();
        insert cdValue;        
        
        
        
        List<zqu__ZProduct__c> zProd= TestDataFactory.createZProduct(1);
        zProd[0].ProductCode__c = 'CD001';
        insert zProd;                

        Publication__c testPublication = TestDataFactory.createPublication(1)[0];
        testPublication.Publication_Code__c = 'BH';        
        insert testPublication ;
        
        List<Product_Publication__c> prodPub = TestDataFactory.createProductPublication(1);
        prodPub[0].zProduct__c =  zProd[0].id;
        prodPub[0].Publication_Code__c = testPublication.id;     
        insert prodPub;
     
  APRIL   */    
        /* Set<String> productCodeSet = new Set<String>();
        productCodeSet.add('CD001');
        
        List<Product_Publication__c> samPle = [SELECT Id,                
        ZProduct__r.ProductCode__c,                
        Publication_Code__r.Publication_Code__c,                
        Publication_Code__r.Published_Days__c,                
        Publication_Code__r.Public_Holiday_Weekday_Pub_Indicator__c,                
        Publication_Code__r.Public_Holiday_Weekend_Pub_Indicator__c            
        FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c IN :productCodeSet AND Publication_Code__r.ID != null];
        
        System.assertEquals(-1, samPle.size());*/                         
                                                  
   /*APRIL     BT_AB_HDS039DX_CR_SubscriptionIssuesFile batch = new BT_AB_HDS039DX_CR_SubscriptionIssuesFile();        
        ID batchprocessid = Database.executeBatch(batch,200);        
        System.assertNotEquals(null, batchprocessid); 

     } 
      private static void prepareTestData(){
      //insert test data
        List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
        insert accList;
               
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        insert packageList;
        
                               
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(2);
        billAccountList[0].Zuora__Account__c = accList[0].id;
        billAccountList[1].Zuora__Account__c = accList[1].id;     
        
        insert billAccountList;       
        
               
        List<Order__c> orderList = TestDataFactory.createOrder(2);
        orderList[0].Account__c = accList[0].id;
        orderList[0].Subscriber_Charge__c = 100; 
        orderList[1].Account__c = accList[1].id;
        orderList[1].Subscriber_Charge__c = 100;     
        insert orderList;
              
                         
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
        orderLineItemList[0].Order__c = orderList[0].id; 
        orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
        orderLineItemList[1].Order__c = orderList[1].id; 
        orderLineItemList[1].Main_Package_ID__c = packageList[1].id;        
        insert orderLineItemList;
        
                  
        zsubList = TestDataFactory.createSubscription(2);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';  
        zsubList[0].Order_Number__c = orderList[0].id;        
        zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
        zsubList[0].Delivery_Charge__c = 200;
        zsubList[1].Zuora__Account__c = accList[1].id;     
        zsubList[1].Zuora__CustomerAccount__c = billAccountList[1].id;
        zsubList[1].Qty1__c ='10';  
        zsubList[1].Order_Number__c = orderList[1].id; 
        zsubList[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
        zsubList[1].Delivery_Charge__c = 200;
        zsubList[1].Number_of_Copies1__c =  '100';
        zsubList[1].Number_of_Copies__c = 100;
        zsubList[1].Qty__c = 20;
        zsubList[0].Product_Code__c = 'CD001';
        zsubList[0].Subscription_Type_1__c = 'Publication';
        zsubList[0].Subscription_Type__c = 'Publication';
        zsubList[0].Number_of_Copies1__c =  '100';
        zsubList[0].Number_of_Copies__c = 100;
        zsubList[0].Qty__c = 20;
        insert zsubList;
        
        List<Zuora__Subscription__c> queryList = [SELECT id FROM Zuora__Subscription__c WHERE Product_Code__c = 'CD001'];

        //System.assertNotEquals(queryList[0].id, zsubList[0].id);
                
          
      }APRIL*/
 }