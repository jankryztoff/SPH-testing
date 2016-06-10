/**
@Author <Miguel Oabel>
@name <COS_SaveSubmitTest>
@CreateDate <10/24/2014>
@Description <Test Class for COS_SaveSubmit>
@Version <1.0>
@reference <none>
*/
@isTest(SeeAllData=true)
private class COS_SaveSubmitTest {
    
  
    /**
    * Test method where effective date is greater than earliest 
    * @name <testEffectiveDateGreaterThanEarliest>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static TestMethod void testEffectiveDateGreaterThanEarliest(){
    
        try {
                Test.setMock(WebServiceMock.class, new zLoginMock());
               
                //Create a new user with Standard User Profile
                User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                );
                
                System.assertNotEquals('', String.valueOf(u)); //change assertEquals to assertNotEquals - zantua [2/7]
                
                System.runAs(u)  { 
                
                    Account newAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                    newAccount.NRIC__c = 'T1234567R';
                    newAccount.Name='TestAccount';
                    newAccount.Phone='00000';      
                    
                    insert newAccount;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    insert postal;
                    
                    //create Address
                    Address__c addressRec = TestDataFactory.createAddress(1)[0];
                    addressRec.Address_Type__c='P';
                    addressRec.Postal_Code__c = postal.Id;
                    insert addressRec;
                    
                    //create Package
                    Package__c newPackage = TestDataFactory.createPackage(1)[0];
                    newPackage.Name = 'Test Package';
                    newPackage.Package_Type__c='Add On';
                    newPackage.Subscription_Type__c='Termed';
                    newPackage.Effective_Start_Date__c=date.today();
                    newPackage.Effective_End_Date__c=date.today()+100;
                    newPackage.Subscription_Period__c='18';
                    newPackage.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    newPackage.Billing_Type__c = 'Full Prepaid';
                    //newPackage.Package_Code__c='PackageCode';
                    insert newPackage;
                    
                    List<Contact> con = TestDataFactory.createContact(1);
                    con[0].Address__c = addressRec.Id;
                    //START: CCB002 Added by April Banaag - to apply changes to contact record type
                    con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    con[0].Recipient_Indicator__c = true;
                    //END: CCB002 Added by April Banaag - to apply changes to contact record type
                    con[0].Phone = '1234567';
                    con[0].AccountId = newAccount.Id;
                    insert con;             
                                       
                    //create Order
                    Order__c newOrder = new Order__c();
                    newOrder.Order_Type__c = 'Start';
                    newOrder.Status__c = 'Draft';
                    newOrder.Account__c = newAccount.Id;
                    newOrder.Informed_Customer__c = true;
                    newOrder.Recipient_Contact__c = con[0].Id;
                    newOrder.Effective_Date__c = date.today() + 2;
                    newOrder.Credit_Balance__c = 20000.00;
                    newOrder.Delivery_Charge__c = 100.00;
                    newOrder.COS_Urgent_Request__c = false;
                    insert newOrder;
                    
                    //create Order Line Item
                    Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
                    newOLI.Order__c = newOrder.Id;
                    newOLI.Main_Package_ID__c = newPackage.Id;
                    newOLI.Effective_Date__c = System.Today()-1;
                    newOli.Earliest_Start_Date__c = date.today()-3;
                    newOLI.Is_Digital__c = true;
                    newoli.Addon_Package__c = newPackage.id;
                    newoli.Main_Package_Product_Family__c = 'Default';
                    newoli.Main_Package_Billing_Type__c = 'Full Prepaid';
                    newoli.Start_Date__c = date.today().addDays(1);
                    insert newOLI;     
    
                    //---------------added 4/10/16-------------------------
                    //create Order2
                    Order__c newOrder2 = new Order__c();
                    newOrder2.Order_Type__c = 'Start';
                    newOrder2.Status__c = 'Draft';
                    newOrder2.Account__c = newAccount.Id;
                    newOrder2.Informed_Customer__c = true;
                    newOrder2.Recipient_Contact__c = con[0].Id;
                    newOrder2.Effective_Date__c = date.today() + 2;
                    newOrder2.Credit_Balance__c = 20000.00;
                    newOrder2.Delivery_Charge__c = 100.00;
                    newOrder2.COS_Urgent_Request__c = false;
                    insert newOrder2;
                    
                    //create new Order Line Item
                    Order_Line_Item__c newOLI2 = TestDataFactory.createOrderLineItem(1)[0];
                    newOLI2.Order__c = newOrder.Id;
                    newOLI2.Main_Package_ID__c = newPackage.Id;
                    newOLI2.Effective_Date__c = System.Today()-1;
                    newOLI2.Earliest_Start_Date__c = date.today()-3;
                    newOLI2.Is_Digital__c = true;
                    newOLI2.Addon_Package__c = newPackage.id;
                    newOLI2.Main_Package_Product_Family__c = 'Default';
                    newOLI2.Main_Package_Billing_Type__c = 'Full Prepaid';
                    newOLI2.Start_Date__c = date.today().addDays(1);
                    newOLI2.Vendor_Mailing_Agent__c = null;
                    insert newOLI2; 
                    //----------------------------------------------------------
                    
                    Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(1)[0];
                    zca.Zuora__DefaultPaymentMethod__c = 'Other' ;
                    zca.Zuora__Account__c = newAccount.id;
                   
                    insert zca;
                    
                    //create Zuora Subscription
                    List <Zuora__Subscription__c> SubsList = new List <Zuora__Subscription__c>();
                    //Zuora__Subscription__c Subs = TestDataFactory.createSubscription(3)[0];
                    Zuora__Subscription__c Subs = new Zuora__Subscription__c();
                    //Subs.id = '11QWERTY';
                    Subs.Zuora__Account__c = newAccount.id;
                    Subs.Name= 'CS0000000110';
                    Subs.Number_of_Copies__c= 10;
                    Subs.Zuora__CustomerAccount__c = zca.id;
                    Subs.Next_Earliest_Start_Date__c= date.today();
                    Subs.Unique_Address_Id__c= 'asdasdasd';
                    Subs.Year_to_Date_Temp_Stop_Days__c= 2;
                    Subs.Previous_Year_Temp_Stop_Days__c= 2;
                    Subs.Legacy_Create_Date__c='2014-08-07';
                    Subs.Legacy_Create_By__c='test';
                    Subs.Legacy_Update_Date__c='test';
                    Subs.Legacy_Update_By__c='test';
                    Subs.Legacy_Subscription_ID__c='test';
                    Subs.Cheque_details__c='test';
                    Subs.DTL__c='test';
                    Subs.Paypal_Payment_Profile_Id__c='test';
                    Subs.Pub_Tag__c='test';
                    Subs.Zuora__SubscriptionEndDate__c= date.today().addDays(5);
                    Subs.Subscription_Grace_Period_End_Date__c= 'test';
                    Subs.Gift_ID__c= 'test';
                    Subs.Redeem_Date__c= 'test';
                    Subs.Gift_ID_2__c= 'test';
                    Subs.Redeem_Date_2__c= 'test';
                    Subs.Subscriber_Contact__c= con[0].Id;
                    Subs.Recipient_Contact__c= con[0].Id;
                    Subs.Subscription_Charge__c= 223.0;
                    Subs.Term_Length__c= 2;
                    Subs.Order_Line_Item_Number__c= newOLI.id;
                    Subs.Main_Package_1__c= newPackage.id;
                    Subs.Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                    database.insert(Subs);
                    SubsList.add(Subs);
                    
                    Zuora__Subscription__c Subs2 = new Zuora__Subscription__c();
                    //Subs.id = '11QWERTY';
                    Subs2.Zuora__Account__c = newAccount.id;
                    Subs2.Name= 'CS0000000110';
                    Subs2.Number_of_Copies__c= 10;
                    Subs2.Zuora__CustomerAccount__c = zca.id;
                    Subs2.Next_Earliest_Start_Date__c= date.today();
                    Subs2.Unique_Address_Id__c= 'asdasdasd';
                    Subs2.Year_to_Date_Temp_Stop_Days__c= 2;
                    Subs2.Previous_Year_Temp_Stop_Days__c= 2;
                    Subs2.Legacy_Create_Date__c='2014-08-07';
                    Subs2.Legacy_Create_By__c='test';
                    Subs2.Legacy_Update_Date__c='test';
                    Subs2.Legacy_Update_By__c='test';
                    Subs2.Legacy_Subscription_ID__c='test';
                    Subs2.Cheque_details__c='test';
                    Subs2.DTL__c='test';
                    Subs2.Paypal_Payment_Profile_Id__c='test';
                    Subs2.Pub_Tag__c='test';
                    Subs2.Zuora__SubscriptionEndDate__c= date.today().addDays(5);
                    Subs2.Subscription_Grace_Period_End_Date__c= 'test';
                    Subs2.Gift_ID__c= 'test';
                    Subs2.Redeem_Date__c= 'test';
                    Subs2.Gift_ID_2__c= 'test';
                    Subs2.Redeem_Date_2__c= 'test';
                    Subs2.Subscriber_Contact__c= con[0].Id;
                    Subs2.Recipient_Contact__c= con[0].Id;
                    Subs2.Subscription_Charge__c= 223.0;
                    Subs2.Term_Length__c= 2;
                    Subs2.Order_Line_Item_Number__c= newOLI2.id;
                    Subs2.Main_Package_1__c= newPackage.id;
                    Subs2.Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                    database.insert(Subs2);
                    SubsList.add(Subs2);
                   
                    // insert SubsList;
                    List<Vendor_Allocation__c> vAllocs =TestDataFactory.createVendorAlloc(1);
                    for(Vendor_Allocation__c vAlloc: vAllocs)
                    {
                        
                        vAlloc.SingPost_Address__c = postal.id;
                        vAlloc.Vendor_Account__c = newAccount.id;
                        vAlloc.Allocated__c = true;
                    }
                    insert vAllocs;
                     
                    Date effectiveDate = date.today().addDays(2);
                    Decimal qty = 1;
                  
                    zqu__ProductRatePlanCharge__c zProductRatePlanCharge =TestDataFactory.createProductRatePlanCharge(1)[0];
                    zProductRatePlanCharge.zqu__ZuoraId__c = 'Zy87Rq';
                    zProductRatePlanCharge.Name = 'Name';
                    database.insert(zProductRatePlanCharge );  
                          
                    test.Starttest();
                    system.assertEquals(1, vAllocs.size());
                    COS_SaveSubmit newtest = new COS_SaveSubmit();   
                    newtest.saveAsDraft(newOrder,newOLI,Subs);
                    //COS_SaveSubmit.amendCallOut(SubsList[0].Id, effectiveDate, qty); 
                    newtest.Submit(newOrder, null);
                    //newtest.Submit(newOrder, SubsList[0]);
                    test.Stoptest();
                    
                }
       }catch(Zuora.zRemoteException e) {}  
  }
    
    //---------------added 4/10/16------------------------- 
    static TestMethod void testEffectiveDateGreaterThanEarliestVAGT1(){
    
        try {
                Test.setMock(WebServiceMock.class, new zLoginMock());
               
                //Create a new user with Standard User Profile
                User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                );
                
                System.assertNotEquals('', String.valueOf(u)); //change assertEquals to assertNotEquals - zantua [2/7]
                
                System.runAs(u)  { 
                
                    Account newAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                    newAccount.NRIC__c = 'T1234567R';
                    newAccount.Name='TestAccount';
                    newAccount.Phone='00000';      
                    
                    insert newAccount;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    insert postal;
                    
                    //create Address
                    Address__c addressRec = TestDataFactory.createAddress(1)[0];
                    addressRec.Address_Type__c='P';
                    addressRec.Postal_Code__c = postal.Id;
                    insert addressRec;
                    
                    //create Package
                    Package__c newPackage = TestDataFactory.createPackage(1)[0];
                    newPackage.Name = 'Test Package';
                    newPackage.Package_Type__c='Add On';
                    newPackage.Subscription_Type__c='Termed';
                    newPackage.Effective_Start_Date__c=date.today();
                    newPackage.Effective_End_Date__c=date.today()+100;
                    newPackage.Subscription_Period__c='18';
                    newPackage.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    newPackage.Billing_Type__c = 'Full Prepaid';
                    insert newPackage;
                    
                    List<Contact> con = TestDataFactory.createContact(1);
                    con[0].Address__c = addressRec.Id;
                    con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    con[0].Recipient_Indicator__c = true;
                    con[0].Phone = '1234567';
                    con[0].AccountId = newAccount.Id;
                    insert con;             
                                                          
                    //create Order
                    Order__c newOrder = new Order__c();
                    newOrder.Order_Type__c = 'Start';
                    newOrder.Status__c = 'Draft';
                    newOrder.Account__c = newAccount.Id;
                    newOrder.Informed_Customer__c = true;
                    newOrder.Recipient_Contact__c = con[0].Id;
                    newOrder.Effective_Date__c = date.today() + 2;
                    newOrder.Credit_Balance__c = 20000.00;
                    newOrder.Delivery_Charge__c = 100.00;
                    newOrder.COS_Urgent_Request__c = false;
                    insert newOrder;
                    
                    //create new Order Line Item
                    Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
                    newOLI.Order__c = newOrder.Id;
                    newOLI.Main_Package_ID__c = newPackage.Id;
                    newOLI.Effective_Date__c = System.Today()-1;
                    newOLI.Earliest_Start_Date__c = date.today()-3;
                    newOLI.Is_Digital__c = true;
                    newOLI.Addon_Package__c = newPackage.id;
                    newOLI.Main_Package_Product_Family__c = 'Default';
                    newOLI.Main_Package_Billing_Type__c = 'Full Prepaid';
                    newOLI.Start_Date__c = date.today().addDays(1);
                    newOLI.Vendor_Mailing_Agent__c = null;
                    insert newOLI;                    
                    
                    Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(1)[0];
                    zca.Zuora__DefaultPaymentMethod__c = 'Other' ;
                    zca.Zuora__Account__c = newAccount.id;
                   
                    insert zca;
                    
                    //create Zuora Subscription
                    List <Zuora__Subscription__c> SubsList = new List <Zuora__Subscription__c>();                   
                    Zuora__Subscription__c Subs = new Zuora__Subscription__c();
                    Subs.Zuora__Account__c = newAccount.id;
                    Subs.Name= 'CS0000000110';
                    Subs.Number_of_Copies__c= 10;
                    Subs.Zuora__CustomerAccount__c = zca.id;
                    Subs.Next_Earliest_Start_Date__c= date.today();
                    Subs.Unique_Address_Id__c= 'asdasdasd';
                    Subs.Year_to_Date_Temp_Stop_Days__c= 2;
                    Subs.Previous_Year_Temp_Stop_Days__c= 2;
                    Subs.Legacy_Create_Date__c='2014-08-07';
                    Subs.Legacy_Create_By__c='test';
                    Subs.Legacy_Update_Date__c='test';
                    Subs.Legacy_Update_By__c='test';
                    Subs.Legacy_Subscription_ID__c='test';
                    Subs.Cheque_details__c='test';
                    Subs.DTL__c='test';
                    Subs.Paypal_Payment_Profile_Id__c='test';
                    Subs.Pub_Tag__c='test';
                    Subs.Zuora__SubscriptionEndDate__c= date.today().addDays(5);
                    Subs.Subscription_Grace_Period_End_Date__c= 'test';
                    Subs.Gift_ID__c= 'test';
                    Subs.Redeem_Date__c= 'test';
                    Subs.Gift_ID_2__c= 'test';
                    Subs.Redeem_Date_2__c= 'test';
                    Subs.Subscriber_Contact__c= con[0].Id;
                    Subs.Recipient_Contact__c= con[0].Id;
                    Subs.Subscription_Charge__c= 223.0;
                    Subs.Term_Length__c= 2;
                    Subs.Order_Line_Item_Number__c= newOLI.id;
                    Subs.Main_Package_1__c= newPackage.id;
                    Subs.Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                    database.insert(Subs);
                    SubsList.add(Subs);
                   
                    // insert SubsList;
                    List<Vendor_Allocation__c> vAllocs =TestDataFactory.createVendorAlloc(2);
                    for(Vendor_Allocation__c vAlloc: vAllocs)
                    {
                        
                        vAlloc.SingPost_Address__c = postal.id;
                        vAlloc.Vendor_Account__c = newAccount.id;
                        vAlloc.Allocated__c = true;
                    }
                    insert vAllocs;
                     
                    Date effectiveDate = date.today().addDays(2);
                    Decimal qty = 1;
                  
                    zqu__ProductRatePlanCharge__c zProductRatePlanCharge =TestDataFactory.createProductRatePlanCharge(1)[0];
                    zProductRatePlanCharge.zqu__ZuoraId__c = 'Zy87Rq';
                    zProductRatePlanCharge.Name = 'Name';
                    database.insert(zProductRatePlanCharge );  
                          
                    test.Starttest();
                    system.assertEquals(2, vAllocs.size());
                    COS_SaveSubmit newtest = new COS_SaveSubmit();   
                    newtest.saveAsDraft(newOrder,newOLI,Subs);
                    newtest.Submit(newOrder, Subs);
                    test.Stoptest();                   
                }
       }catch(Zuora.zRemoteException e) {}  
    }
    
    static TestMethod void testEffectiveDateGreaterThanEarliestVALT1(){
    
        try {
                Test.setMock(WebServiceMock.class, new zLoginMock());
               
                //Create a new user with Standard User Profile
                User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                );
                
                System.assertNotEquals('', String.valueOf(u)); //change assertEquals to assertNotEquals - zantua [2/7]
                
                System.runAs(u)  { 
                
                    Account newAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                    newAccount.NRIC__c = 'T1234567R';
                    newAccount.Name='TestAccount';
                    newAccount.Phone='00000';      
                    
                    insert newAccount;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    insert postal;
                    
                    //create Address
                    Address__c addressRec = TestDataFactory.createAddress(1)[0];
                    addressRec.Address_Type__c='P';
                    addressRec.Postal_Code__c = postal.Id;
                    insert addressRec;
                    
                    //create Package
                    Package__c newPackage = TestDataFactory.createPackage(1)[0];
                    newPackage.Name = 'Test Package';
                    newPackage.Package_Type__c='Add On';
                    newPackage.Subscription_Type__c='Termed';
                    newPackage.Effective_Start_Date__c=date.today();
                    newPackage.Effective_End_Date__c=date.today()+100;
                    newPackage.Subscription_Period__c='18';
                    newPackage.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    newPackage.Billing_Type__c = 'Full Prepaid';
                    insert newPackage;
                    
                    List<Contact> con = TestDataFactory.createContact(1);
                    con[0].Address__c = addressRec.Id;
                    con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    con[0].Recipient_Indicator__c = true;
                    con[0].Phone = '1234567';
                    con[0].AccountId = newAccount.Id;
                    insert con;             
                                                          
                    //create Order
                    Order__c newOrder = new Order__c();
                    newOrder.Order_Type__c = 'Start';
                    newOrder.Status__c = 'Draft';
                    newOrder.Account__c = newAccount.Id;
                    newOrder.Informed_Customer__c = true;
                    newOrder.Recipient_Contact__c = con[0].Id;
                    newOrder.Effective_Date__c = date.today() + 2;
                    newOrder.Credit_Balance__c = 20000.00;
                    newOrder.Delivery_Charge__c = 100.00;
                    newOrder.COS_Urgent_Request__c = false;
                    insert newOrder;
                    
                    //create new Order Line Item
                    Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
                    newOLI.Order__c = newOrder.Id;
                    newOLI.Main_Package_ID__c = newPackage.Id;
                    newOLI.Effective_Date__c = System.Today()-1;
                    newOLI.Earliest_Start_Date__c = date.today()-3;
                    newOLI.Is_Digital__c = true;
                    newOLI.Addon_Package__c = newPackage.id;
                    newOLI.Main_Package_Product_Family__c = 'Default';
                    newOLI.Main_Package_Billing_Type__c = 'Full Prepaid';
                    newOLI.Start_Date__c = date.today().addDays(1);
                    newOLI.Vendor_Mailing_Agent__c = null;
                    insert newOLI;                    
                    
                    Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(1)[0];
                    zca.Zuora__DefaultPaymentMethod__c = 'Other' ;
                    zca.Zuora__Account__c = newAccount.id;
                   
                    insert zca;
                    
                    //create Zuora Subscription
                    List <Zuora__Subscription__c> SubsList = new List <Zuora__Subscription__c>();                   
                    Zuora__Subscription__c Subs = new Zuora__Subscription__c();
                    Subs.Zuora__Account__c = newAccount.id;
                    Subs.Name= 'CS0000000110';
                    Subs.Number_of_Copies__c= 10;
                    Subs.Zuora__CustomerAccount__c = zca.id;
                    Subs.Next_Earliest_Start_Date__c= date.today();
                    Subs.Unique_Address_Id__c= 'asdasdasd';
                    Subs.Year_to_Date_Temp_Stop_Days__c= 2;
                    Subs.Previous_Year_Temp_Stop_Days__c= 2;
                    Subs.Legacy_Create_Date__c='2014-08-07';
                    Subs.Legacy_Create_By__c='test';
                    Subs.Legacy_Update_Date__c='test';
                    Subs.Legacy_Update_By__c='test';
                    Subs.Legacy_Subscription_ID__c='test';
                    Subs.Cheque_details__c='test';
                    Subs.DTL__c='test';
                    Subs.Paypal_Payment_Profile_Id__c='test';
                    Subs.Pub_Tag__c='test';
                    Subs.Zuora__SubscriptionEndDate__c= date.today().addDays(5);
                    Subs.Subscription_Grace_Period_End_Date__c= 'test';
                    Subs.Gift_ID__c= 'test';
                    Subs.Redeem_Date__c= 'test';
                    Subs.Gift_ID_2__c= 'test';
                    Subs.Redeem_Date_2__c= 'test';
                    Subs.Subscriber_Contact__c= con[0].Id;
                    Subs.Recipient_Contact__c= con[0].Id;
                    Subs.Subscription_Charge__c= 223.0;
                    Subs.Term_Length__c= 2;
                    Subs.Order_Line_Item_Number__c= newOLI.id;
                    Subs.Main_Package_1__c= newPackage.id;
                    Subs.Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                    database.insert(Subs);
                    SubsList.add(Subs);
                   
                    Date effectiveDate = date.today().addDays(2);
                    Decimal qty = 1;
                  
                    zqu__ProductRatePlanCharge__c zProductRatePlanCharge =TestDataFactory.createProductRatePlanCharge(1)[0];
                    zProductRatePlanCharge.zqu__ZuoraId__c = 'Zy87Rq';
                    zProductRatePlanCharge.Name = 'Name';
                    database.insert(zProductRatePlanCharge );  
                          
                    test.Starttest();
                    COS_SaveSubmit newtest = new COS_SaveSubmit();   
                    newtest.saveAsDraft(newOrder,newOLI,Subs);
                    newtest.Submit(newOrder, Subs);
                    test.Stoptest();                   
                }
       }catch(Zuora.zRemoteException e) {}  
    }
    //----------------------------------------------------------
    
    /**
    * Testmethod with effectivedate greater than today
    * @name <testEffectiveDateGreatedThanToday>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testEffectiveDateGreatedThanToday()
    {        
                    //Create SingPost Address
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    insert postal;
                    
                    //Create Address
                    Address__c addr = TestDataFactory.createAddress(1)[0];
                    addr.Address_Type__c='P';
                    addr.Postal_Code__c = postal.Id;
                    insert addr;
                    
                    //Create Account
                    Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
                    acc.NRIC__c = 'T1234567R';
                    acc.Name='TestAccount';
                    acc.Phone='00000';               
                    insert acc;
                    
                    //Create Contact
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.Address__c = addr.Id;
                    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    con.Recipient_Indicator__c = true;
                    con.Phone = '1234567';
                    con.AccountId = acc.Id;
                    insert con;            
                    
                    //Create Package
                    Package__c pack = TestDataFactory.createPackage(1)[0];
                    pack.Name = 'Test Package';
                    pack.Package_Type__c= 'Add on';
                    pack.Subscription_Type__c='Termed';
                    pack.Effective_Start_Date__c = date.today();
                    pack.Effective_End_Date__c=date.today()+100;
                    pack.Subscription_Period__c='18';
                    pack.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    pack.Billing_Type__c = 'Full Prepaid';
                    //pack.Package_Code__c='PackageCode';
                    insert pack;
                    
                     Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(1)[0];
                     zca.Zuora__DefaultPaymentMethod__c = 'Other' ;
                     zca.Payment_Mode__c = 'Other';
                     zca.Zuora__Account__c = acc.id;
                       
                     insert zca;
                    
                    //Create Zuora Subscription
                    Zuora__Subscription__c Subs = TestDataFactory.createSubscription(1)[0];
                    Subs.Zuora__Account__c = acc.id;
                    Subs.Zuora__CustomerAccount__c = zca.id;
                    Subs.Name= 'CS0000000110';
                    Subs.Number_of_Copies__c= 10;
                    Subs.Next_Earliest_Start_Date__c= date.today();
                    Subs.Unique_Address_Id__c= 'asdasdasd';
                    Subs.Year_to_Date_Temp_Stop_Days__c= 2;
                    Subs.Previous_Year_Temp_Stop_Days__c= 2;
                    Subs.Legacy_Create_Date__c='2014-08-07';
                    Subs.Legacy_Create_By__c='test';
                    Subs.Legacy_Update_Date__c='test';
                    Subs.Legacy_Update_By__c='test';
                    Subs.Legacy_Subscription_ID__c='test';
                    Subs.Cheque_details__c='test';
                    Subs.DTL__c='test';
                    Subs.Paypal_Payment_Profile_Id__c='test';
                    Subs.Pub_Tag__c='test';
                    Subs.Subscribe_As__c='test';
                    //Subs.Zuora__SubscriptionEndDate__c= date.today().addDays(5); //changed to null
                    Subs.Zuora__SubscriptionEndDate__c= null;
                    Subs.Subscription_Grace_Period_End_Date__c= 'test';
                    Subs.Gift_ID__c= 'test';
                    Subs.Redeem_Date__c= 'test';
                    Subs.Gift_ID_2__c= 'test';
                    Subs.Redeem_Date_2__c= 'test';
                    Subs.Subscriber_Contact__c= con.Id;
                    Subs.Recipient_Contact__c= con.Id;
                    Subs.Subscription_Charge__c= 223.0;
                    Subs.Term_Length__c= 2;
                    //Subs.Order_Line_Item_Number__c= newOLI.id;
                    Subs.Main_Package_1__c= pack.id;
                    Subs.Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                    //Subs.Zuora__ContractEffectiveDate__c = date.today() -2;
                    insert Subs;
                    
                    Zuora__SubscriptionProductCharge__c zSubProdCharge = TestDataFactory.createSubProductCharge(1)[0];
                    zSubProdCharge.Name = 'Test Charge';
                    zSubProdCharge.Zuora__Zuora_Id__c = '2c92c0f84b34ed37014b3ac4fef36c9f';
                    zSubProdCharge.Zuora__RatePlanName__c = 'Rate Plan';
                    zSubProdCharge.Zuora__ProductSKU__c = 'SKU00000326';
                    zSubProdCharge.Zuora__RatePlanId__c =  '2c92c0f84b34ed37014b3ac4fef36c9e';
                    zSubProdCharge.Zuora__Subscription__c = Subs.id;
                    insert zSubProdCharge;
                    
                    //Create Order
                    Order__c order = TestDataFactory.createOrder(1)[0];
                    order.Order_Type__c = 'Start';
                    order.Status__c = 'Draft';
                    order.Account__c = acc.Id;
                    order.Informed_Customer__c = true;
                    order.Recipient_Contact__c = con.Id;
                    order.Effective_Date__c = date.today().addDays(2);
                    order.COS_Urgent_Request__c = true;
                    insert order;
                    
                    //create Order Line Item
                    Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
                    oli.Order__c = order.Id;
                    oli.Main_Package_ID__c = pack.Id;
                    oli.Effective_Date__c = System.Today()+1;
                    oli.Is_Digital__c = true;
                    oli.Addon_Package__c = pack.id;
                    oli.Main_Package_Product_Family__c = 'Default';
                    oli.Main_Package_Billing_Type__c = 'Full Prepaid';
                    oli.Start_Date__c = date.today().addDays(1);
                    insert oli;                
                   
                     zqu__ProductRatePlanCharge__c zProductRatePlanCharge =TestDataFactory.createProductRatePlanCharge(1)[0];
                     zProductRatePlanCharge.zqu__ZuoraId__c = 'Zy87Rq';
                     database.insert(zProductRatePlanCharge );  
                        
                    Test.startTest();   
                    COS_SaveSubmit controller = new COS_SaveSubmit();      
                    controller.saveAsDraft(order, oli, Subs);    
                    Test.stopTest();
                  
    }
    
    
    static testmethod void testforOrderLineItem(){ 
                User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                );
                
                
                System.runAs(u)  {                
                    Account newAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                    newAccount.NRIC__c = 'T1234567R';
                    newAccount.Name='TestAccount';
                    newAccount.Phone='00000';      
                    
                    insert newAccount;
                           
                  // TestData Initialization
                    Integer count = 0;
                
                    
                 //Order_Line_Item__c
                 //Create SingPost Address
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    insert postal;
                    
                    //Create Address
                    Address__c addr = TestDataFactory.createAddress(1)[0];
                    addr.Address_Type__c='P';
                    addr.Postal_Code__c = postal.Id;
                    insert addr;
                    
                    //Create Contact
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.Address__c = addr.Id;
                    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    con.Recipient_Indicator__c = true;
                    con.Phone = '1234567';
                    con.AccountId = newAccount.Id;
                    insert con;            
                    
                    //Create Package
                    Package__c pack = TestDataFactory.createPackage(1)[0];
                    pack.Name = 'Test Package';
                    pack.Package_Type__c='Add On';
                    pack.Subscription_Type__c='Termed';
                    pack.Effective_Start_Date__c=date.today();
                    pack.Effective_End_Date__c=date.today()+100;
                    pack.Subscription_Period__c='18';
                    pack.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    pack.Billing_Type__c = 'Full Prepaid';
                    //pack.Package_Code__c='PackageCode';
                    insert pack;
                    
                    Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(1)[0];
                    zca.Zuora__DefaultPaymentMethod__c = 'Other' ;
                    zca.Payment_Mode__c = 'Other';
                    zca.Zuora__Account__c = newAccount.id;
                    insert zca;
                    
                    //Create Zuora Subscription
                    Zuora__Subscription__c Subs = TestDataFactory.createSubscription(1)[0];
                    Subs.Zuora__Account__c = newAccount.id;
                    Subs.Zuora__CustomerAccount__c = zca.id;
                    Subs.Name= 'CS0000000110';
                    Subs.Number_of_Copies__c= 10;
                    Subs.Next_Earliest_Start_Date__c= date.today();
                    Subs.Unique_Address_Id__c= 'asdasdasd';
                    Subs.Year_to_Date_Temp_Stop_Days__c= 2;
                    Subs.Previous_Year_Temp_Stop_Days__c= 2;
                    Subs.Legacy_Create_Date__c='2014-08-07';
                    Subs.Legacy_Create_By__c='test';
                    Subs.Legacy_Update_Date__c='test';
                    Subs.Legacy_Update_By__c='test';
                    Subs.Legacy_Subscription_ID__c='test';
                    Subs.Cheque_details__c='test';
                    Subs.DTL__c='test';
                    Subs.Paypal_Payment_Profile_Id__c='test';
                    Subs.Pub_Tag__c='test';
                    Subs.Subscribe_As__c='test';
                    //Subs.Zuora__SubscriptionEndDate__c= date.today().addDays(5); //changed to null
                    Subs.Zuora__SubscriptionEndDate__c= null;
                    Subs.Subscription_Grace_Period_End_Date__c= 'test';
                    Subs.Gift_ID__c= 'test';
                    Subs.Redeem_Date__c= 'test';
                    Subs.Gift_ID_2__c= 'test';
                    Subs.Redeem_Date_2__c= 'test';
                    Subs.Subscriber_Contact__c= con.Id;
                    Subs.Recipient_Contact__c= con.Id;
                    Subs.Subscription_Charge__c= 223.0;
                    Subs.Term_Length__c= 2;
                    //Subs.Order_Line_Item_Number__c= newOLI.id;
                    Subs.Main_Package_1__c= pack.id;
                    Subs.Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                    Subs.Zuora__ContractEffectiveDate__c = date.today() -2;
                    insert Subs;
                    
                    zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
                    zProd.Name = 'THE STRAITS TIMES PRINT TEST';
                    zProd.zqu__SKU__c = 'SKU00000326';
                    zProd.ProductCode__c = 'TEST';
                    zProd.ProductType__c = 'Product';
                    zProd.ProductPlatform__c = 'Print';
                    zProd.ProductFamily__c = 'ST';
                    zProd.ProductSubType__c = 'Newspaper';
                    insert zProd;
                    
                    zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
                    //prp.Name = 'PRODUCT RATE PLAN TEST';
                    prp.Name = 'Name';
                    prp.RatePlanCode__c = 'STEST13TS';
                    prp.RatePlanType__c = 'Bill Plan';
                    prp.zqu__ZProduct__c = zProd.Id;
                    insert prp;
                
                    Zuora__SubscriptionProductCharge__c zSubProdCharge = TestDataFactory.createSubProductCharge(1)[0];
                    zSubProdCharge.Name = 'Test Charge';
                    zSubProdCharge.Zuora__Zuora_Id__c = '2c92c0f84b34ed37014b3ac4fef36c9f';
                    zSubProdCharge.Zuora__RatePlanName__c = 'Name';
                    zSubProdCharge.Zuora__ProductSKU__c = 'SKU00000326';
                    zSubProdCharge.Zuora__RatePlanId__c =  '2c92c0f84b34ed37014b3ac4fef36c9e';
                    zSubProdCharge.Zuora__Subscription__c = Subs.id;
                    zSubProdCharge.Name = 'Name';
                    insert zSubProdCharge;
                    
                    List<Vendor_Allocation__c> vAllocs = TestDataFactory.createVendorAlloc(2);
                    for(Vendor_Allocation__c vAlloc: vAllocs)
                    {
                        vAlloc.SingPost_Address__c = postal.id;
                        vAlloc.Effective_Start_Date__c = date.today() - 5;
                        vAlloc.Legacy_Created_Date__c = 'Feb 12';
                        vAlloc.Legacy_Created_By__c = 'TestCreator';
                        vAlloc.Legacy_Updated_By__c = 'TestUpdater';
                        vAlloc.Legacy_Updated_Date__c = 'Feb 13';
                        vAlloc.Vendor_Account__c = newAccount.id;
                        vAlloc.Allocated__c = true ;
                    }
                    insert vAllocs;
                    
                    //Create Order
                    Order__c order = TestDataFactory.createOrder(1)[0];
                    order.Order_Type__c = 'Start';
                    order.Status__c = 'Draft';
                    order.Account__c = newAccount.Id;
                    order.Informed_Customer__c = true;
                    order.Recipient_Contact__c = con.Id;
                    order.Effective_Date__c = date.today() + 2;
                    order.COS_Urgent_Request__c = true;
                    insert order;
                    
                    //create Order Line Item
                    List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
                    count = 0;
                    for (Order_Line_Item__c obj : orderLineItemList) {
                        obj.Order__c = order.id;
                        obj.Main_Package_ID__c = pack.id;
                        obj.Vendor_Mailing_Agent__c = null;
                        obj.Addon_Package__c = pack.id;
                        obj.Main_Package_Product_Family__c = 'Default';
                        obj.Main_Package_Billing_Type__c = 'Full Prepaid';
                        obj.Start_Date__c = date.today().addDays(1);
                        count++;
                    }
                    insert orderLineItemList;
                    
                   zqu__ProductRatePlanCharge__c zProductRatePlanCharge =TestDataFactory.createProductRatePlanCharge(1)[0];
                   zProductRatePlanCharge.zqu__ZuoraId__c = 'Zy87Rq';
                   zProductRatePlanCharge.Name = 'Name';
                   zProductRatePlanCharge.zqu__ProductRatePlan__c = prp.Id;
                   database.insert(zProductRatePlanCharge );
                
                   Date effectiveDate = date.today().addDays(2);
                   Decimal qty = 1;
                   try{
                       test.setMock(WebServiceMock.class, new zApiTest());
                       Test.startTest(); 
                           //system.assertNotEquals(null, Subs.size());
                           COS_SaveSubmit newtest = new COS_SaveSubmit();       
                           //newtest.saveAsDraft(Order,newOLI,Subs);  
                           //newtest.amendCallOut(Subs.id, effectiveDate, qty);
                           newtest.Submit(order , Subs);
                           COS_SaveSubmit.amendCallOut(subs.Id, effectiveDate, qty);          
                       Test.stopTest();
                   }
                   catch(Exception e){ }
                }
          } 
   
}