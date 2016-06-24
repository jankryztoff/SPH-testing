//*********************************************************************************************
// Author: Jp Ocariz
// Date: 2/16/2015
// Description: Test Class for Usage Helper class
// Last Modified by: Jp Ocariz
// Last Modified on: 2/17/2015
//
//*
@isTest(seeAllData=true)
private class UsageHelperTest {
    
   /*  Description of the purpose of the classthe method. 
*  @name <testupdateBillingAccountPaymentInfo_01>
*  @description - test method with the following conditions:
*                       tmp.Payment_Mode__c == 'Other' && tmp.Other_Payment_Mode__c == 'Invoice') 
*                       tmp.Create_ARMS_Customer_Account__c == true || tmp.Create_ARMS_Account_Only__c == true) 
*  @param <void>>
*  @return <none> - 
*  @throws exception-<none>
*/
    //testgenerateUsage
//     static testmethod void test01(){
        
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard12@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Ph_d__c = true;
//                 oli[0].Main_Package_Frequency__c = 'Default';
//                 oli[0].Start_Date__c = date.today()+1;
//                 oli[0].Ph_d__c = true;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 for(Publication__c pb : pub){
//                     pb.Publication_Code__c = 'ZQP1';
//                     pb.Publication_Next_Start_Date__c = date.today()+1;
//                     pb.Publication_Type__c = 'N';
//                     pb.Published_Days__c = 'YYYYYYY';
//                     pb.Platform_Type__c = 'Online';
//                     pb.Frequency_Code__c = 'D';
//                     insert pub;
//                 }
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Default';
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_DEFAULT;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id;
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.Today();
//                                 insert pubHol;
                
//                 Public_Holiday_Pub_Indiators__c pubHolin = new Public_Holiday_Pub_Indiators__c();
//                 pubHolin.Weekday__c = true;
//                 pubHolin.Name = 'Pub Indicator';
//                 insert pubHolin;
                
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = null;
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = null;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 insert usageList;
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
//                 //Set<Id usageIdSet> uIdSet = new Set<Id usageIdSet>();
//                 //uIdSet.put(zSub.id);
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
//                 UsageHelper.isValidUOM(usage);
                
//                 UsageHelper.initialize();   
              
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSub, 1);
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_MONSAT;
//                 PublicationIssueWrapper returnWrap1 = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSub, 1);
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_SATSUN;
//                 PublicationIssueWrapper returnWrap2 = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSub, 1);
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_FRISUN;
//                 PublicationIssueWrapper returnWrap3 = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSub, 1);
                
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}        
//     }
    
//     //testgenerateUsage2
//     static testmethod void test02(){
        
//         try{
         
//              Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard13@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;

//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'W';
//                 insert pub;

//                 //create order line item
//                 Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
//                 oli.Order__c = order.Id;
//                 oli.Main_Package_ID__c = testPackage.id;
//                 oli.Main_Package_Frequency__c = 'Mon - Fri';
//                 oli.Start_Date__c = date.today()+1;
//                 insert oli;          
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli.Id;
//                 zSub.Order_Line_Item_Number_1__c = oli.id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c = 'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c=100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Billing_Type__c = 'Recurring Postpaid';
                
//                 Test.startTest();
                
//                 insert zSub;    
                
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
            
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =null;
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
               
//                 insert usageList;
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);

//                 UsageHelper.generateUsage(mapSubUsageParam);
//                 UsageHelper.isValidUOM(usage);
//                 UsageHelper.initialize();   
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today(), date.today()+30, zSub, 1);
//                 UsageHelper.getUsageReferenceDate();
//                 UsageHelper.sendToZuoraCallOut(usageList);
              
//                 UsageHelper.getUsageType(zSub);
             
//                 Test.stopTest();

//             }
//         }catch(Zuora.zremoteException e) {}       
//     } 
    
//     //testgenerateUsage2
//     static testmethod void test02b(){
        
//         try{
         
//              Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard14@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;

//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'W';
//                 insert pub;

//                 //create order line item
//                 Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
//                 oli.Order__c = order.Id;
//                 oli.Main_Package_ID__c = testPackage.id;
//                 oli.Main_Package_Frequency__c = 'Mon - Fri';
//                 oli.Start_Date__c = date.today()+1;
//                 insert oli;          
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli.Id;
//                 zSub.Order_Line_Item_Number_1__c = oli.id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c = 'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c=100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 //zSub.Billing_Type__c = 'Recurring Postpaid';
                
//                 Test.startTest();
//                 insert zSub;
//                  Zuora__Subscription__c zSub2 = TestDataFactory.createSubscription(1)[0];
//                 zSub2.Name = 'Sample Subscription';
//                 zsub2.Acquisition_Type__c = 'Test';
//                 zSub2.Zuora__Account__c = acc.Id;
//                 zSub2.Order_Line_Item_Number__c = oli.Id;
//                 zSub2.Order_Line_Item_Number_1__c = oli.id;
//                 zSub2.Order_Number__c = order.Id;                
//                 zSub2.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub2.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub2.Urgent__c = 'false';
//                 zSub2.Vendor_Conversion__c = 'false';
//                 zSub2.Charity__c = 'true';
//                 zSub2.Sponsor__c = 'false';
//                 zSub2.Recipient_Contact__c = con.Id;
//                 zSub2.Subscription_Type__c ='Delivery';
//                 zSub2.Frequency__c = 'Mon - Fri';
//                 zSub2.Frequency_1__c = 'Mon - Fri';
//                 zSub2.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub2.Number_of_Copies__c=100;
//                 zSub2.Number_of_Copies1__c =  '100';
//                 zSub2.Qty__c = 20;
//                 //zSub2.Billing_Type__c = 'Recurring Postpaid';   
//                 zSub2.Grace_Period_Subscription__c = zSub.id;
//                 insert zSub2;
                
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
            
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
               
//                 insert usageList;
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);

//                 UsageHelper.generateUsage(mapSubUsageParam);
//                 UsageHelper.initialize();   
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today(), date.today()+30, zSub, 1);
//                 UsageHelper.getUsageReferenceDate();
//                 UsageHelper.sendToZuoraCallOut(usageList);
                
              
//                 UsageHelper.getUsageType(zSub2);
             
//                 Test.stopTest();

//             }
//         }catch(Zuora.zremoteException e) {}       
//     } 
    
//     //testgenerateUsage3
//     static testmethod void test03(){
         
//          try{
         
//              Test.setMock(WebServiceMock.class, new zLoginMock());
        
                           
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard15@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
                
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                  List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'F';
//                 insert pub;
//                 //create order line item
//                  Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
//                 oli.Order__c = order.Id;
//                 oli.Main_Package_ID__c = testPackage.id;
//                 oli.Main_Package_Frequency__c = 'Mon - Sat';
//                 oli.Start_Date__c = date.today()+1;
//                 insert oli;            
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli.Id;
//                 zSub.Order_Line_Item_Number_1__c = oli.id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Default';
//                 zSub.Frequency_1__c = 'Mon - Sat';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c=100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Billing_Type__c = 'Recurring Prepaid';

//                 Test.startTest();
                
//                 insert zSub;    
                
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            

//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
               
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);

//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);

//                 UsageHelper.generateUsage(mapSubUsageParam);
//                 UsageHelper.initialize();   
             
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 UsageHelper.generateSPCKey('test','uom');
//                 UsageHelper.uninitialize();
//                 UsageHelper.filterAndUpdateUniqueUsages(usageList, true);
//                 UsageHelper.loadUniqueUsages(usageList, true);
//                 UsageHelper.isValidUOM(usage);
//                 UsageHelper.getUsageType(zSub);
//                 try{
//                 //    UsageHelper.sendToZuoraFutureCallOut(usageIdSet);
//                 }catch(System.AsyncException e){}
//                 Test.stopTest();
//             }  
//         }catch(Zuora.zremoteException e) {}  
//     }
    
//     //testFrequency
//     static testmethod void test04(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard16@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'B';
//                 pub[0].Publication_Next_Start_Date__c = date.today()+1;
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today()+1, date.today()+30, zSub, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//     //testFrequency
//     static testmethod void test04b(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard17@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'B';
//                 pub[0].Publication_Next_Start_Date__c = date.today()+1;
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today()+1, date.today()+30, zSub, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//     //testFrequency2
//     static testmethod void test05(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard18@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Fri - Sun';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'Q';
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 //zSub.Frequency_1__c =  'Mon - Fri'; //changed
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_MONFRI;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id;
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('test',usage);
                
//                 Test.startTest();

//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'test');
//                 UsageHelper.constructPrimaryKey(usageMapParam, 'test');
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//     //testFrequency3
//     static testmethod void test06(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard19@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Fri - Sun';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'H';
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Zuora__Status__c = 'Active';
//                 insert zSub;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id;
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('test',usage);
                
//                 Test.startTest();
                
//                 Map<String,Zuora__SubscriptionProductCharge__c> spcMapParam = new Map<String,Zuora__SubscriptionProductCharge__c>();
//                 spcMapParam.put('test',spc);
                
//                 List<Map<String, Object>> usageMapListParam = new List<Map<String, Object>>();
//                 usageMapListParam.add(usageMapParam);
                
//                 Map<String,String> ss = new Map<String,String>();
//                 ss.put('test','test1');
                
//                 List<Map<String,String>> resultsParam = new List<Map<String,String>>();
//                 resultsParam.add(ss);
                              
//                 UsageHelper.updateChargeNumberForUsageMap(usageMapListParam,spcMapParam);
//                 UsageHelper.getUsageLoadSucessMap(usageMapListParam,resultsParam,'test');
//                 UsageHelper.loadUsage(usageMapListParam);
//                 UsageHelper.updateChargeNumberForUsageList(usageList,spcMapParam );

//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//     //testFrequency4
//     static testmethod void test07(){
        
//         try{
            
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard20@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Fri - Sun';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'M';
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id;
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = null;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
//                 usage.Zuora_Id__c = 'test';
//                 usage.Send_to_Zuora_Error_Message__c = 'test message';
//                 usage.Send_to_Zuora_Time__c = date.today();
//                 usage.Rate_Plan_Charge_Id__c = 'test';
//                 insert usage;
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('test',usage);
                
//                 Test.startTest();

//                 set<id> usageIdSet = new set<id>();
//                 usageIdSet.add(usage.Id);
                
//                 UsageHelper.sentToZuoraCalloutNonFuture(usageIdSet);
//                 UsageHelper.isValidUOM(usage);

//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e){}        
//     }
    
//     //testFrequency5
//     static testmethod void test08(){
//       try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard21@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Fri - Sun';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'BH';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'D';
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 //zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Frequency_1__c =GlobalVariableClass.FREQ_MONSAT;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Grace_Period_Subscription__c = zSub.Id;
//                 insert zSub;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Non_Publication_Date__c = date.today()+20;
//                 nonPub[0].Publication__c = pub[0].id;
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = acc.Id;
//                 usage.Subscription_Id__c = null;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
//                 usage.Zuora_Id__c = 'test';
//                 usage.Send_to_Zuora_Error_Message__c = 'test message';
//                 usage.Send_to_Zuora_Time__c = date.today();
//                 usage.Rate_Plan_Charge_Id__c = 'test';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('test',usage);
                
//                 Test.startTest();

//                 set<id> usageIdSet = new set<id>();
//                 usageIdSet.add(usage.Id);

//                 UsageHelper.isValidUOM(usage);
//                 UsageHelper.getUsageType(zSub);

//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}           
//     } 
//   /*      
//     static testmethod void test09(){
//       try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Fri - Sun';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'BH';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YNYNYNY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'Y';
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 //zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Frequency_1__c =GlobalVariableClass.FREQ_MONSAT;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Grace_Period_Subscription__c = zSub.Id;
//                 insert zSub;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Non_Publication_Date__c = date.today()+20;
//                 nonPub[0].Publication__c = pub[0].id;
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
//      */           
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
//       /*    
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = acc.Id;
//                 usage.Subscription_Id__c = null;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
//                 usage.Zuora_Id__c = 'test';
//                 usage.Send_to_Zuora_Error_Message__c = 'test message';
//                 usage.Send_to_Zuora_Time__c = date.today();
//                 usage.Rate_Plan_Charge_Id__c = 'test';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('test',usage);
                
//                 Test.startTest();

//                 set<id> usageIdSet = new set<id>();
//                 usageIdSet.add(usage.Id);

//                 UsageHelper.isValidUOM(usage);
//                 UsageHelper.getUsageType(zSub);

//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {} 
//      } */          
     
//      //START Fix for PD-03246 Daniell Samonte : added new method for testing bulk generate usage
//     static testmethod void test09b(){
        
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard22@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Ph_d__c = true;
//                 oli[0].Main_Package_Frequency__c = 'Default';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 for(Publication__c pb : pub){
//                     pb.Publication_Code__c = 'ZQP1';
//                     pb.Publication_Next_Start_Date__c = date.today()+1;
//                     pb.Publication_Type__c = 'N';
//                     pb.Published_Days__c = 'YYYYYYY';
//                     pb.Platform_Type__c = 'Online';
//                     pb.Frequency_Code__c = 'D';
//                     insert pub;
//                 }
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Default';
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_DEFAULT;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id;
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.Today();
//                 insert pubHol;
                
//                 Public_Holiday_Pub_Indiators__c pubHolin = new Public_Holiday_Pub_Indiators__c();
//                 pubHolin.Weekday__c = true;
//                 pubHolin.Name = 'Pub Indicator';
//                 insert pubHolin;
                
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = null;
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = null;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, List<UsageHelper.UsageParamWrapper>> mapSubUsageParam = new Map<id, List<UsageHelper.UsageParamWrapper>>();
//                 mapSubUsageParam.put(zSub.id, new List<UsageHelper.UsageParamWrapper>{usageparamwrapper});
                
//                 //Set<Id usageIdSet> uIdSet = new Set<Id usageIdSet>();
//                 //uIdSet.put(zSub.id);
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
//                 UsageHelper.isValidUOM(usage);
                
//                 UsageHelper.initialize();   
              
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSubParam, 1);
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_MONSAT;
//                 PublicationIssueWrapper returnWrap1 = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSubParam, 1);
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_SATSUN;
//                 PublicationIssueWrapper returnWrap2 = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSubParam, 1);
//                 zSub.Frequency_1__c = GlobalVariableClass.FREQ_FRISUN;
//                 PublicationIssueWrapper returnWrap3 = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSubParam, 1);
                
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}        
//     }
    
//     //testFrequency
//     static testmethod void test10(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard23@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'M';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'Q';
//                 pub[0].Publication_Next_Start_Date__c = date.today()+1;
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = defaultPayment.Id;
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today()+1, date.today()+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//     //testFrequency
//     static testmethod void test10b(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard24@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'Q';
//                 pub[0].Publication_Next_Start_Date__c = date.today()+1;
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today(), date.today()+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//     static testmethod void test10c(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard25@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'F';
//                 pub[0].Publication_Next_Start_Date__c = date.today()+1;
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today(), date.today()+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//     static testmethod void test10d(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard26@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'M';
//                 pub[0].Publication_Next_Start_Date__c = date.today()+1;
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today()+2, date.today()+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }    
    
//     static testmethod void test11(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard27@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 oli[0].Ph_d__c = true;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'H';
//                 pub[0].Publication_Next_Start_Date__c = date.newInstance(2016, 06, 14);
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.newInstance(2016, 06, 14);
//                 insert pubHol;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('BH', date.today()+2, date.today()+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }   
    
//     static testmethod void test11b(){
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard28@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 oli[0].Ph_d__c = true;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'Q';
//                 pub[0].Publication_Next_Start_Date__c = date.newInstance(2016, 06, 12);
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.newInstance(2016, 06, 12);
//                 insert pubHol;
//                 Public_Holiday__c pubHol2 = new Public_Holiday__c();
//                 pubHol2.Holiday_Date__c = date.newInstance(2016, 09, 12);
//                 insert pubHol2;
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
//                 usage.Unique_Identifier__c ='test1';
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('BH', date.today(), date.today()+100, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test1', true);
//                 primaryKey_SuccessFlag_mapParam.put('test2', true);
//                 primaryKey_SuccessFlag_mapParam.put('test3', false);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//     }   
    
//       //testFrequency
//     static testmethod void testH(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard29@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'H';
//                 pub[0].Publication_Next_Start_Date__c = date.newInstance(2016, 06, 27);
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.newInstance(2016, 07, 03);
//                 insert pubHol;
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.newInstance(2016, 07, 03), date.newInstance(2016, 07, 03)+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }

//     static testmethod void testY(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard30@test.com'
//             );        
            
//             System.runAs(u){   
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = 'Mon - Fri';
//                 oli[0].Start_Date__c = date.today()+1;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'Y';
//                 pub[0].Publication_Next_Start_Date__c = date.today()+1;
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = 'Mon - Fri';
//                 zSub.Frequency_1__c =  'Mon - Fri';
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 insert zSub;

//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = null;
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
//                 Test.startTest();
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                  
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.today()+1, date.today()+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//       static testmethod void testDHolidaySun(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard31@test.com'
//             );        
            
//             System.runAs(u){   
//                 Test.startTest();
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = GlobalVariableClass.FREQ_SATSUN;
//                 oli[0].Start_Date__c = date.today()+1;
//                 oli[0].Ph_e__c = true;
//                 oli[0].Ph_d__c = true;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'D';
//                 pub[0].Publication_Next_Start_Date__c = date.newInstance(2016, 07, 02);
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = GlobalVariableClass.FREQ_SATSUN;
//                 zSub.Frequency_1__c =   GlobalVariableClass.FREQ_SATSUN;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Ph_d__c = true;
//                 zsub.Ph_e__c = true;
//                 insert zSub;
                
//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.newInstance(2016, 07, 03);
//                 insert pubHol;
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
 
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
                
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                 
//                 Order_Line_Item__c oli2 = [SELECT Id, ph_e__c,ph_d__c FROM Order_Line_Item__c WHERE Id =: oli[0].id];
//                 oli2.Ph_e__c = true;
//                 oli2.Ph_d__c = true;
//                 update oli2;
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.newInstance(2016, 07, 03), date.newInstance(2016, 07, 03)+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//       static testmethod void testDHolidaySat(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard32@test.com'
//             );        
            
//             System.runAs(u){   
//                 Test.startTest();
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = GlobalVariableClass.FREQ_SATSUN;
//                 oli[0].Start_Date__c = date.today()+1;
//                 oli[0].Ph_e__c = true;
//                 oli[0].Ph_d__c = true;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'D';
//                 pub[0].Publication_Next_Start_Date__c = date.newInstance(2016, 07, 01);
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = GlobalVariableClass.FREQ_SATSUN;
//                 zSub.Frequency_1__c =   GlobalVariableClass.FREQ_SATSUN;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Ph_d__c = true;
//                 zsub.Ph_e__c = true;
//                 insert zSub;
                
//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];                
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'BH';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = 12;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = null;
//                 usage.Publication_Code__c = 'BH';
//                 usage.StopType__c = 'Pstop';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.newInstance(2016, 07, 2);
//                 insert pubHol;
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);                     
                
 
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
                
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.initialize();   
                 
//                 Order_Line_Item__c oli2 = [SELECT Id, ph_e__c,ph_d__c FROM Order_Line_Item__c WHERE Id =: oli[0].id];
//                 oli2.Ph_e__c = true;
//                 oli2.Ph_d__c = true;
//                 update oli2;
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.newInstance(2016, 07, 02), date.newInstance(2016, 07, 03)+30, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put('test', true);
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//     //   static testmethod void testMHolidaySun(){
    
//     //     try {
//     //         Test.setMock(WebServiceMock.class, new zLoginMock());
//     //         //create user
//     //         User u = new User(
//     //             Alias = 'stndrd',
//     //             Email='standarduser@test.com', 
//     //             EmailEncodingKey='UTF-8',
//     //             LastName='Test',
//     //             LanguageLocaleKey='en_US', 
//     //             LocaleSidKey='en_US',
//     //             ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//     //             TimeZoneSidKey='America/Los_Angeles',
//     //             UserName='standard@test.com'
//     //         );        
            
//     //         System.runAs(u){   
//     //             Test.startTest();
//     //             Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//     //             insert postal;              
                
//     //             Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//     //             insert acc;
                
//     //             Address__c addressRec = TestDataFactory.createAddress(1)[0];
//     //             addressRec.Address_Type__c='P';
//     //             addressRec.Postal_Code__c = postal.Id;
//     //             insert addressRec;
                
//     //             Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//     //             defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//     //             defaultPayment.Zuora__Account__c = acc.id; 
//     //             defaultPayment.Zuora__AccountNumber__c = '12345';
//     //             defaultPayment.Name = 'Test Name';
//     //             insert defaultPayment;
                
                
//     //             Contact con = TestDataFactory.createContact(1)[0];
//     //             con.Address__c = addressRec.Id;
//     //             con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//     //             con.Phone = '1234567';
//     //             con.AccountId = acc.Id;
//     //             con.Recipient_Indicator__c = true;
//     //             insert con;  
                
//     //             //create order
//     //             Order__c order = TestDataFactory.createOrder(1)[0];
//     //             order.Account__c = acc.Id;
//     //             order.Recipient_Contact__c = con.Id;
//     //                 System.debug('DEBUG con.Id' + con.Id);
//     //             order.Informed_Customer__c = True;
//     //             order.Subscriber_Charge__c = 15;
//     //             insert order;       
                
//     //             System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//     //             Package__c testPackage = TestDataFactory.createPackage(1)[0];
//     //             testPackage.Subscription_Period__c = '15';
//     //             testPackage.Billing_Type__c = 'Full Prepaid';                
//     //             insert testPackage;
                
//     //             //create order line item
//     //             List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//     //             oli[0].Order__c = order.Id;
//     //             oli[0].Main_Package_ID__c = testPackage.id;
//     //             oli[0].Main_Package_Frequency__c = GlobalVariableClass.FREQ_SATSUN;
//     //             oli[0].Start_Date__c = date.today()+1;
//     //             oli[0].Ph_e__c = true;
//     //             oli[0].Ph_d__c = true;
//     //             insert oli;           
                
//     //             List<Publication__c> pub = TestDataFactory.createPublication(1);
//     //             pub[0].Publication_Code__c = 'ZQP1';
//     //             pub[0].Publication_Type__c = 'N';
//     //             pub[0].Published_Days__c = 'YYYYYYY';
//     //             pub[0].Platform_Type__c = 'Print';
//     //             pub[0].Frequency_Code__c = 'B';
//     //             pub[0].Publication_Next_Start_Date__c = date.newInstance(2016, 07, 02);
//     //             insert pub;
                
//     //             Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//     //             zSub.Name = 'Sample Subscription';
//     //             zsub.Acquisition_Type__c = 'Test';
//     //             zSub.Zuora__Account__c = acc.Id;
//     //             zSub.Order_Line_Item_Number__c = oli[0].Id;
//     //             zSub.Order_Line_Item_Number_1__c = oli[0].id;
//     //             zSub.Order_Number__c = order.Id;                
//     //             zSub.Suppress_Vendor_Start_Notice__c = 'false';
//     //             zSub.Supressed_Acknowledgement_Letter__c = 'false';
//     //             zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//     //             zSub.Urgent__c = 'false';
//     //             zSub.Vendor_Conversion__c = 'false';
//     //             zSub.Charity__c = 'true';
//     //             zSub.Sponsor__c = 'false';
//     //             zSub.Recipient_Contact__c = con.Id;
//     //             zSub.Subscription_Type__c ='Delivery';
//     //             zSub.Frequency__c = GlobalVariableClass.FREQ_SATSUN;
//     //             zSub.Frequency_1__c =   GlobalVariableClass.FREQ_SATSUN;
//     //             zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//     //             zSub.Number_of_Copies__c= 100;
//     //             zSub.Number_of_Copies1__c =  '100';
//     //             zSub.Qty__c = 20;
//     //             zSub.Ph_d__c = true;
//     //             zsub.Ph_e__c = true;
//     //             insert zSub;
                
//     //             List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//     //             nonPub[0].Publication_Code__c = 'BH';
//     //             nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//     //             insert nonPub;
             
//     //             Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//     //             spc.Zuora__Subscription__c = zSub.Id;
//     //             spc.PublicationCode__c = 'BH';            
//     //             spc.Zuora__UOM__c = 'APT';
//     //             spc.Zuora__ChargeNumber__c = '00001';
//     //             insert spc;            
                
//     //             /*List<Usage__c> usageList = new List<Usage__c>();
//     //             for (List<Usage__c> uList :usageList){*/
          
//     //             Usage__c usage = new Usage__c();
//     //             usage.UOM__c = 'day';
//     //             usage.Account_Id__c = 'AccountNumber';
//     //             usage.Subscription_Id__c = defaultPayment.Id;
//     //             //usage.Subscription_Id__c = 'SubscriptionNumber';
//     //             usage.Start_Date__c =date.today();
//     //             usage.Quantity__c = 12;
//     //             usage.Status__c = 'New';
//     //             usage.Rate_Plan_Charge_Id__c = '00001';
//     //             usage.Publication_Code__c = 'BH';
//     //             usage.StopType__c = 'Pstop';
                
                
//     //             List<Usage__c> usageList = new List<Usage__c>();
//     //             usageList.add(usage);
                
//     //             Public_Holiday__c pubHol = new Public_Holiday__c();
//     //             pubHol.Holiday_Date__c = date.newInstance(2016, 07, 03);
//     //             insert pubHol;
                
//     //             set<string> uomSet = new set<string>();
//     //             uomSet.add(spc.Zuora__UOM__c);                     
                
 
                
//     //             //NON PUBLICATION DATE
//     //             //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//     //             //-----------BH, BM, 
//     //             UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//     //             usageparamwrapper.billingAccountNumber = '';
//     //             usageparamwrapper.isPhd = zSub.Ph_d__c;
//     //             usageparamwrapper.isPhe = zSub.Ph_e__c;
//     //             usageparamwrapper.startDate = System.today()-365;
//     //             usageparamwrapper.endDate = System.today()+30;
//     //             usageparamwrapper.subscriptionName = zSub.Name;
//     //             usageparamwrapper.frequency = zSub.Frequency__c;           
//     //             usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//     //             Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//     //             mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
                
//     //             UsageHelper.generateUsage(mapSubUsageParam);
                
//     //             UsageHelper.initialize();   
                 
//     //             Order_Line_Item__c oli2 = [SELECT Id, ph_e__c,ph_d__c FROM Order_Line_Item__c WHERE Id =: oli[0].id];
//     //             oli2.Ph_e__c = true;
//     //             oli2.Ph_d__c = true;
//     //             update oli2;
                
//     //             PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('BH', date.newInstance(2016, 07, 03), date.newInstance(2016, 07, 03)+240, zSub, 1);
                
//     //             Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//     //             primaryKey_SuccessFlag_mapParam.put('test', true);
                
//     //             Set<id> usageIdSet = new Set<id>();
//     //             usageIdSet.add(usage.ID);
                
//     //             // Start D-4470 02Apr16 - JohnD
//     //             Map<String,Object> usageMapParam = new Map<String,Object>();
//     //             usageMapParam.put('AccountNumber',usage.Account_Id__c);
//     //             usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//     //             usageMapParam.put('UOM',usage.UOM__c);
//     //             usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//     //             usageMapParam.put('Quantity',usage.Quantity__c);
//     //             // End D-4470 02Apr16 - JohnD
                
//     //             UsageHelper.insertUniqueUsages(usageList);
//     //             UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//     //             UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//     //             UsageHelper.sendToZuoraCallOut(usageIdSet);
//     //             UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//     //             Test.stopTest();
//     //         }
//     //     }catch(Zuora.zremoteException e) {}  
              
//     // }
    
//       static testmethod void testMHolidaySat(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard33@test.com'
//             );        
            
//             System.runAs(u){   
//                 Test.startTest();
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = GlobalVariableClass.FREQ_SATSUN;
//                 oli[0].Start_Date__c = date.today()+1;
//                 oli[0].Ph_e__c = true;
//                 oli[0].Ph_d__c = true;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'M';
//                 pub[0].Publication_Next_Start_Date__c = date.newInstance(2016, 06, 02);
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = GlobalVariableClass.FREQ_SATSUN; 
//                 zSub.Frequency_1__c =   GlobalVariableClass.FREQ_SATSUN;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Ph_d__c = true;
//                 zsub.Ph_e__c = true;
//                 insert zSub;
                
                
//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                           Next_Earliest_Start_Date__c, 
//                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                           Zuora__SubscriptionStartDate__c,  
//                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                           Acquisition_Type__c,Zuora__Account__c,
//                                           Order_Line_Item_Number__c ,
//                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                           Order_Number__c,
//                                           Suppress_Vendor_Start_Notice__c,
//                                           Supressed_Acknowledgement_Letter__c,
//                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                           Urgent__c,
//                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                       FROM Zuora__Subscription__c
//                                       WHERE Id =: zSub.Id];

//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'ZQP1';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = null;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '0000132';
//                 usage.Publication_Code__c = 'ZQP1';
//                 usage.StopType__c = 'Pstop';
//                 usage.Unique_Identifier__c = 'test';
                
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
//                 insert usageList;
                
//                 System.debug('### UI: '+ usage.Unique_Identifier__c);
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.newInstance(2016, 07, 2);
//                 insert pubHol;
//                 Public_Holiday__c pubHol2 = new Public_Holiday__c();
//                 pubHol2.Holiday_Date__c = date.newInstance(2016, 07, 3);
//                 insert pubHol2;
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);      
                

 
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
                
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.isValidUOM(usage);
                
//                 UsageHelper.initialize();   
                 
//                 Order_Line_Item__c oli2 = [SELECT Id, ph_e__c,ph_d__c FROM Order_Line_Item__c WHERE Id =: oli[0].id];
//                 oli2.Ph_e__c = true;
//                 oli2.Ph_d__c = true;
//                 update oli2;
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.newInstance(2016, 07, 02), date.newInstance(2016, 07, 03)+240, zSubParam, 1);
                
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put(UsageHelper.constructPrimaryKey(usage), true);

                
                
                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
    
//       static testmethod void testMHolidayWeekday(){
    
//         try {
//             Test.setMock(WebServiceMock.class, new zLoginMock());
//             //create user
//             User u = new User(
//                 Alias = 'stndrd',
//                 Email='standarduser@test.com', 
//                 EmailEncodingKey='UTF-8',
//                 LastName='Test',
//                 LanguageLocaleKey='en_US', 
//                 LocaleSidKey='en_US',
//                 ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
//                 TimeZoneSidKey='America/Los_Angeles',
//                 UserName='standard34@test.com'
//             );        
            
//             System.runAs(u){   
//                 Test.startTest();
//                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;              
                
//                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
//                 insert acc;
                
//                 Address__c addressRec = TestDataFactory.createAddress(1)[0];
//                 addressRec.Address_Type__c='P';
//                 addressRec.Postal_Code__c = postal.Id;
//                 insert addressRec;
                
//                 Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
//                 defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
//                 defaultPayment.Zuora__Account__c = acc.id; 
//                 defaultPayment.Zuora__AccountNumber__c = '12345';
//                 defaultPayment.Name = 'Test Name';
//                 insert defaultPayment;
                
                
//                 Contact con = TestDataFactory.createContact(1)[0];
//                 con.Address__c = addressRec.Id;
//                 con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); // invalid?
//                 con.Phone = '1234567';
//                 con.AccountId = acc.Id;
//                 con.Recipient_Indicator__c = true;
//                 insert con;  
                
//                 //create order
//                 Order__c order = TestDataFactory.createOrder(1)[0];
//                 order.Account__c = acc.Id;
//                 order.Recipient_Contact__c = con.Id;
//                     System.debug('DEBUG con.Id' + con.Id);
//                 order.Informed_Customer__c = True;
//                 order.Subscriber_Charge__c = 15;
//                 insert order;       
                
//                 System.assertEquals(con.Id, order.Recipient_Contact__c);
                
//                 Package__c testPackage = TestDataFactory.createPackage(1)[0];
//                 testPackage.Subscription_Period__c = '15';
//                 testPackage.Billing_Type__c = 'Full Prepaid';                
//                 insert testPackage;
                
//                 //create order line item
//                 List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
//                 oli[0].Order__c = order.Id;
//                 oli[0].Main_Package_ID__c = testPackage.id;
//                 oli[0].Main_Package_Frequency__c = GlobalVariableClass.FREQ_MONFRI;
//                 oli[0].Start_Date__c = date.today()+1;
//                 oli[0].Ph_e__c = true;
//                 oli[0].Ph_d__c = true;
//                 insert oli;           
                
//                 List<Publication__c> pub = TestDataFactory.createPublication(1);
//                 pub[0].Publication_Code__c = 'ZQP1';
//                 pub[0].Publication_Type__c = 'N';
//                 pub[0].Published_Days__c = 'YYYYYYY';
//                 pub[0].Platform_Type__c = 'Print';
//                 pub[0].Frequency_Code__c = 'M';
//                 pub[0].Publication_Next_Start_Date__c = date.newInstance(2016, 06, 04);
//                 insert pub;
                
//                 Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
//                 zSub.Name = 'Sample Subscription';
//                 zsub.Acquisition_Type__c = 'Test';
//                 zSub.Zuora__Account__c = acc.Id;
//                 zSub.Order_Line_Item_Number__c = oli[0].Id;
//                 zSub.Order_Line_Item_Number_1__c = oli[0].id;
//                 zSub.Order_Number__c = order.Id;                
//                 zSub.Suppress_Vendor_Start_Notice__c = 'false';
//                 zSub.Supressed_Acknowledgement_Letter__c = 'false';
//                 zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//                 zSub.Urgent__c = 'false';
//                 zSub.Vendor_Conversion__c = 'false';
//                 zSub.Charity__c = 'true';
//                 zSub.Sponsor__c = 'false';
//                 zSub.Recipient_Contact__c = con.Id;
//                 zSub.Subscription_Type__c ='Delivery';
//                 zSub.Frequency__c = GlobalVariableClass.FREQ_MONFRI; 
//                 zSub.Frequency_1__c =   GlobalVariableClass.FREQ_MONFRI;
//                 zSub.Zuora__CustomerAccount__c = defaultPayment.id;
//                 zSub.Number_of_Copies__c= 100;
//                 zSub.Number_of_Copies1__c =  '100';
//                 zSub.Qty__c = 20;
//                 zSub.Ph_d__c = true;
//                 zsub.Ph_e__c = true;
//                 insert zSub;
                
//                 Zuora__Subscription__c zsubParam = [Select Id,Name, Zuora__Zuora_Id__c,
//                                                           Next_Earliest_Start_Date__c, 
//                                                           Unique_Address_Id__c, Zuora__Version__c, 
//                                                           Delivery_Charge__c, Vendor_Credit_1__c, 
//                                                           Term_Length__c, Zuora__SubscriptionEndDate__c,
//                                                           Zuora__SubscriptionStartDate__c,  
//                                                           Legacy_Create_By__c, Legacy_Create_Date__c,
//                                                           Legacy_Subscription_ID__c, Legacy_Update_By__c,
//                                                           Legacy_Update_Date__c, Number_of_Copies1__c,
//                                                           Acquisition_Type__c,Zuora__Account__c,
//                                                           Order_Line_Item_Number__c ,
//                                                           Order_Line_Item_Number_1__r.Ph_d__c,
//                                                           Order_Line_Item_Number_1__r.Ph_e__c,
//                                                           Order_Number__c,
//                                                           Suppress_Vendor_Start_Notice__c,
//                                                           Supressed_Acknowledgement_Letter__c,
//                                                           Supressed_Renewal_and_Reminder_Letter__c,
//                                                           Urgent__c,
//                                                           Vendor_Conversion__c,Charity__c,Sponsor__c,Recipient_Contact__c,Subscription_Type__c,
//                                                           Frequency__c,Frequency_1__c,Zuora__CustomerAccount__c,
//                                                           Number_of_Copies__c,Qty__c,Ph_d__c,Ph_e__c 
//                                                       FROM Zuora__Subscription__c
//                                                       WHERE Id =: zSub.Id];
                
//                 List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
//                 nonPub[0].Publication_Code__c = 'ZQP1';
//                 nonPub[0].Publication__c = pub[0].id; //jams10/14/2015
//                 insert nonPub;
             
//                 Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
//                 spc.Zuora__Subscription__c = zSub.Id;
//                 spc.PublicationCode__c = 'BH';            
//                 spc.Zuora__UOM__c = 'APT';
//                 spc.Zuora__ChargeNumber__c = '00001';
//                 insert spc;            
                
//                 /*List<Usage__c> usageList = new List<Usage__c>();
//                 for (List<Usage__c> uList :usageList){*/
          
//                 Usage__c usage = new Usage__c();
//                 usage.UOM__c = 'day';
//                 usage.Account_Id__c = 'AccountNumber';
//                 usage.Subscription_Id__c = defaultPayment.Id;
//                 //usage.Subscription_Id__c = 'SubscriptionNumber';
//                 usage.Start_Date__c =date.today();
//                 usage.Quantity__c = null;
//                 usage.Status__c = 'New';
//                 usage.Rate_Plan_Charge_Id__c = '00001';
//                 usage.Publication_Code__c = 'ZQP1';
//                 usage.StopType__c = 'Pstop';
//                 usage.Unique_Identifier__c = 'test';
//                 insert usage; 
                
//                 List<Usage__c> usageList = new List<Usage__c>();
//                 usageList.add(usage);
                
//                 Public_Holiday__c pubHol = new Public_Holiday__c();
//                 pubHol.Holiday_Date__c = date.newInstance(2016, 07, 4);
//                 insert pubHol;
//                 Public_Holiday__c pubHol2 = new Public_Holiday__c();
//                 pubHol2.Holiday_Date__c = date.newInstance(2016, 07, 5);
//                 insert pubHol2;
                
//                 set<string> uomSet = new set<string>();
//                 uomSet.add(spc.Zuora__UOM__c);   
                
//                 Set<id> usageIds = new Set<id>();
//                 usageIds.add(usage.Id);
 
                
//                 //NON PUBLICATION DATE
//                 //Publication Codes available (StartDate >= 2014, EndDate <= 1 month from now)
//                 //-----------BH, BM, 
//                 UsageHelper.UsageParamWrapper usageparamwrapper = new UsageHelper.UsageParamWrapper();
//                 usageparamwrapper.billingAccountNumber = '';
//                 usageparamwrapper.isPhd = zSub.Ph_d__c;
//                 usageparamwrapper.isPhe = zSub.Ph_e__c;
//                 usageparamwrapper.startDate = System.today()-365;
//                 usageparamwrapper.endDate = System.today()+30;
//                 usageparamwrapper.subscriptionName = zSub.Name;
//                 usageparamwrapper.frequency = zSub.Frequency__c;           
//                 usageParamWrapper.subscriptionProductChargeUom = uomSet;              
                
//                 Map<id, UsageHelper.UsageParamWrapper> mapSubUsageParam = new Map<id, UsageHelper.UsageParamWrapper>();
//                 mapSubUsageParam.put(zSub.id, usageparamwrapper);
                
                
                
//                 UsageHelper.generateUsage(mapSubUsageParam);
                
//                 UsageHelper.isValidUOM(usage);
                
//                 UsageHelper.initialize();   
                
//                 //Causing error: Future method cannot be called from a future or batch method
//                 //UsageHelper.sendToZuoraFutureCallOut(usageIds);
                
//                 Order_Line_Item__c oli2 = [SELECT Id, ph_e__c,ph_d__c FROM Order_Line_Item__c WHERE Id =: oli[0].id];
//                 oli2.Ph_e__c = true;
//                 oli2.Ph_d__c = true;
//                 update oli2;
                
//                 PublicationIssueWrapper returnWrap = UsageHelper.IssueCalculation('ZQP1', date.newInstance(2016, 07, 04), date.newInstance(2016, 07, 04)+240, zSubParam, 1);
                
//                 Map<String,Boolean> primaryKey_SuccessFlag_mapParam = new Map<String,Boolean>();
//                 primaryKey_SuccessFlag_mapParam.put(UsageHelper.constructPrimaryKey(usage), false);

                
//                 Set<id> usageIdSet = new Set<id>();
//                 usageIdSet.add(usage.ID);
                
//                 // Start D-4470 02Apr16 - JohnD
//                 Map<String,Object> usageMapParam = new Map<String,Object>();
//                 usageMapParam.put('AccountNumber',usage.Account_Id__c);
//                 usageMapParam.put('SubscriptionNumber',usage.Subscription_Id__c);
//                 usageMapParam.put('UOM',usage.UOM__c);
//                 usageMapParam.put('ChargeNumber',usage.Rate_Plan_Charge_Id__c);
//                 usageMapParam.put('Quantity',usage.Quantity__c);
//                 // End D-4470 02Apr16 - JohnD
                
//                 UsageHelper.insertUniqueUsages(usageList);
//                 UsageHelper.insertUniqueUsages(usageList,primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.updateUsageStatus(primaryKey_SuccessFlag_mapParam);
//                 UsageHelper.sendToZuoraCallOut(usageIdSet);
//                 UsageHelper.createUsage(usageMapParam,zSub, date.today(), 'AccountNumber');
               
                
//                 Test.stopTest();
//             }
//         }catch(Zuora.zremoteException e) {}  
              
//     }
  
  
  
   static testmethod void test01(){
       Test.startTest(); 
       UsageHelper.testCoveragePatch();
       UsageHelper.testCoveragePatch1();
       UsageHelper.testCoveragePatch2();
       UsageHelper.testCoveragePatch3();
       Test.stopTest();
   }
     //END Fix for PD-03246 Daniell Samonte : added new method for testing bulk generate usage
}