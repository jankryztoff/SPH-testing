@isTest(SeeAllData = true)
private class SM_ChangeOfSubDetailController_Test {
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       //Generate a map of tokens for all the Record Types for the desired object
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

       //Retrieve the record type id by name
       return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }
    
    static testMethod void testSM_ChangeOfSubscriptionDetail(){
        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                                  Email__c = 'sample@email.com',
                                  Mobile__c = '1234567',
                                  AccountNumber = 'subscriberId');
        insert acc;

        Contact con = new Contact(AccountId = acc.Id,
                                  FirstName = 'Test',
                                  LastName = 'Account',
                                  Phone = '0917911312',
                                  Recipient_Indicator__c = true,
                                  Billing_Indicator__c = true);
        insert con;
        
        Case caserec = new Case(AccountId = acc.Id,
                                Status='Waiting',
                                ContactId=con.Id);
        insert caserec;

        Package__c packageRecord = new Package__c(Name = 'Test Package', 
                                                  Package_Type__c = 'Grace Period',
                                                  Subscription_Type__c = 'Termed', 
                                                  Package_Code__c = 'PackageCode',
                                                  Effective_Start_Date__c = date.today(), 
                                                  Effective_End_Date__c = date.today()+100, 
                                                  Subscription_Period__c = '1');
        insert packageRecord;

        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Name = 'Test Billing Account',
                                                                          Zuora__Account__c = acc.id,
                                                                          Billing_Contact__c = con.id,
                                                                          Zuora__Status__c = 'Active',
                                                                          Payment_Mode__c = 'Cash',
                                                                          Zuora__Credit_Balance__c = 2,
                                                                          Billing_Type__c = 'Full Prepaid');
        insert billAcc;

        Order__c orderRecord = new Order__c(Credit_Balance__c = 20000.00, 
                                            Delivery_Charge__c = 100.00,
                                            Monthly_Delivery_Charge_for_Full_Payment__c = 100.00,
                                            Account__c = acc.Id,
                                            Order_Type__c = 'Change of Subscription Package',
                                            Status__c = 'Draft',
                                            Billing_Type__c = 'Full Prepaid',
                                            Billing_Account_Creation_Mode__c = 'Use existing Billing Account',
                                            Billing_Contact__c = con.Id,
                                            Billing_Account__c = billAcc.Id,
                                            isOrderLegacy__c = true);
        insert orderRecord;

        Order_Line_Item__c orderline = new Order_Line_Item__c(Order__c = orderRecord.Id,
                                                              Main_Package_ID__c = packageRecord.Id,
                                                              Term_Length__c = 0,
                                                              Main_Package_Period__c = 0,
                                                              Earliest_Start_Date__c = date.today()+10,
                                                              Earliest_Stop_Date__c = date.today()+15,
                                                              Stop_Request_Date__c = date.today()+1,
                                                              Start_Date__c = date.today()+2,
                                                              Terminating_Reason__c = 'Others',
                                                              Amount_To_Refund__c = 0,
                                                              Admin_Charge__c = 0,
                                                              Fee_Override__c = TRUE,
                                                              Override_Reason__c = 'TEST',
                                                              Suppress_Notification_Stop__c = TRUE,
                                                              Delivered_By__c = 'Vendor',
                                                              Main_Package_Type__c = 'Base',
                                                              Main_Package_Billing_Type__c = 'Full Prepaid',
                                                              End_Date__c = date.newInstance(2016, 12, 2),
                                                              Is_Digital__c = true,
                                                              Fee_Waiver__c = true,
                                                              Case__c = caserec.Id);
        insert orderline;

        Zuora__Subscription__c subscriptionRecord = new Zuora__Subscription__c(Name = 'Test Subscription', 
                                                        Zuora__Zuora_Id__c = 'ZID',
                                                        Next_Earliest_Start_Date__c = date.today()+30,
                                                        Unique_Address_Id__c = 'UAID00000', 
                                                        Zuora__Version__c = 1, 
                                                        Delivery_Charge__c = 200.00, 
                                                        Vendor_Credit_1__c = 20000.00,
                                                        Term_Length__c = 10, 
                                                        Number_of_Copies__c = 3, 
                                                        Zuora__SubscriptionEndDate__c = date.today()+100,
                                                        Zuora__SubscriptionStartDate__c = date.today(),  
                                                        Legacy_Create_By__c = 'User', 
                                                        Legacy_Create_Date__c = '10/24/2014',
                                                        Legacy_Subscription_ID__c = 'LSUB00000', 
                                                        Legacy_Update_By__c = 'User',
                                                        Legacy_Update_Date__c = '10/24/2014', 
                                                        Number_of_Copies1__c = '1',
                                                        Zuora__CustomerAccount__c = billAcc.Id,
                                                        Main_Package_1__c = packageRecord.Id,
                                                        Zuora__Account__c = acc.Id,
                                                        Subscription_Type_1__c = 'Publication',
                                                        Recipient_Contact__c = con.Id,
                                                        Cost_Center__c = 'Class',
                                                        Order_Number_1__c = orderRecord.Id,
                                                        Delivery_Charge_Type_1__c = 'H');
        insert subscriptionRecord;
        
        Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='Test Asia One1', 
                                              Email__c='testasiaone@email.com');
        insert asiaOneRecord;

        Asia1_Subscription__c asiaOneSubscriptionRecord = new Asia1_Subscription__c(Status__c = 'Enabled',
                                                                                    Asia1__c =  asiaOneRecord.Id,
                                                                                    Subscription__c = subscriptionRecord.Id,
                                                                                    Concurrent__c = 124);
        insert asiaOneSubscriptionRecord;
        
        PageReference pg = Page.SM_ChangeOfSubscriptionDetail;
        pg.getParameters().put('Id',orderRecord.Id);
        pg.getParameters().put('accountId',acc.Id);
        Test.setCurrentPage(pg);
        
        Test.startTest();
            SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
            controller.retrieveOrder();
            controller.getUserIdDisableSvcInAsia1(subscriptionRecord.Id);
            controller.creditBalance(orderRecord.Id);
            //controller.updateOrderLineItemGifts(orderLineList);
            controller.submit();
            controller.void();
            controller.edit();
            controller.doCancel();
        Test.stopTest();
    }
    
    static testMethod void testSM_ChangeOfSubscriptionDetail1(){
        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                                  Email__c = 'sample@email.com',
                                  Mobile__c = '1234567',
                                  AccountNumber = 'subscriberId');
        insert acc;

        Contact con = new Contact(AccountId = acc.Id,
                                  FirstName = 'Test',
                                  LastName = 'Account',
                                  Phone = '0917911312',
                                  Recipient_Indicator__c = true,
                                  Billing_Indicator__c = true);
        insert con;
        
        Case caserec = new Case(AccountId = acc.Id,
                                Status='Waiting',
                                ContactId=con.Id);
        insert caserec;

        Package__c packageRecord = new Package__c(Name = 'Test Package', 
                                                  Package_Type__c = 'Grace Period',
                                                  Subscription_Type__c = 'Termed', 
                                                  Package_Code__c = 'PackageCode',
                                                  Effective_Start_Date__c = date.today(), 
                                                  Effective_End_Date__c = date.today()+100, 
                                                  Subscription_Period__c = '1');
        insert packageRecord;

        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Name = 'Test Billing Account',
                                                                          Zuora__Account__c = acc.id,
                                                                          Billing_Contact__c = con.id,
                                                                          Zuora__Status__c = 'Active',
                                                                          Payment_Mode__c = 'Cash');
        insert billAcc;

        Order__c orderRecord = new Order__c(Credit_Balance__c = 20000.00, 
                                            Delivery_Charge__c = 100.00,
                                            Monthly_Delivery_Charge_for_Full_Payment__c = 100.00,
                                            Account__c = acc.Id,
                                            Order_Type__c = 'Change of Subscription Package',
                                            Status__c = 'Draft',
                                            Billing_Type__c = 'Full Prepaid',
                                            Billing_Account_Creation_Mode__c = 'Create New Billing Account',
                                            Billing_Contact__c = con.Id);
        insert orderRecord;

        Order_Line_Item__c orderline = new Order_Line_Item__c(Order__c = orderRecord.Id,
                                                              Main_Package_ID__c = packageRecord.Id,
                                                              Term_Length__c = 0,
                                                              Main_Package_Period__c = 0,
                                                              Earliest_Start_Date__c = date.today()+10,
                                                              Earliest_Stop_Date__c = date.today()+15,
                                                              Stop_Request_Date__c = date.today()+1,
                                                              Start_Date__c = date.today()+2,
                                                              Terminating_Reason__c = 'Others',
                                                              Amount_To_Refund__c = 0,
                                                              Admin_Charge__c = 0,
                                                              Fee_Override__c = TRUE,
                                                              Override_Reason__c = 'TEST',
                                                              Suppress_Notification_Stop__c = TRUE,
                                                              Delivered_By__c = 'Vendor',
                                                              Main_Package_Type__c = 'Base',
                                                              Main_Package_Billing_Type__c = 'Full Prepaid',
                                                              End_Date__c = date.newInstance(2016, 12, 2),
                                                              Is_Digital__c = true,
                                                              Fee_Waiver__c = true,
                                                              Case__c = caserec.Id);
        insert orderline;

        Zuora__Subscription__c subscriptionRecord = new Zuora__Subscription__c(Name = 'Test Subscription', 
                                                        Zuora__Zuora_Id__c = 'ZID',
                                                        Next_Earliest_Start_Date__c = date.today()+30,
                                                        Unique_Address_Id__c = 'UAID00000', 
                                                        Zuora__Version__c = 1, 
                                                        Delivery_Charge__c = 200.00, 
                                                        Vendor_Credit_1__c = 20000.00,
                                                        Term_Length__c = 10, 
                                                        Number_of_Copies__c = 3, 
                                                        Zuora__SubscriptionEndDate__c = date.today()+100,
                                                        Zuora__SubscriptionStartDate__c = date.today(),  
                                                        Legacy_Create_By__c = 'User', 
                                                        Legacy_Create_Date__c = '10/24/2014',
                                                        Legacy_Subscription_ID__c = 'LSUB00000', 
                                                        Legacy_Update_By__c = 'User',
                                                        Legacy_Update_Date__c = '10/24/2014', 
                                                        Number_of_Copies1__c = '1',
                                                        Zuora__CustomerAccount__c = billAcc.Id,
                                                        Main_Package_1__c = packageRecord.Id,
                                                        Zuora__Account__c = acc.Id,
                                                        Subscription_Type_1__c = 'Publication',
                                                        Recipient_Contact__c = con.Id,
                                                        Cost_Center__c = 'Class',
                                                        Order_Number_1__c = orderRecord.Id,
                                                        Delivery_Charge_Type_1__c = 'H');
        insert subscriptionRecord;
        
        PageReference pg = Page.SM_ChangeOfSubscriptionDetail;
        pg.getParameters().put('Id',orderRecord.Id);
        pg.getParameters().put('accountId',acc.Id);
        Test.setCurrentPage(pg);
        
        Test.startTest();
            SM_ChangeOfSubscriptionDetailController.SubscriptionWrapper wrapperClass = new SM_ChangeOfSubscriptionDetailController.SubscriptionWrapper();
            wrapperClass.publicationName = 'Test';
            wrapperClass.publicationPrintPattern = 'Test';
            wrapperClass.subscriptionStartDate = date.today();
            wrapperClass.subscriptionEndDate = date.today();
            wrapperClass.quantity = 2;
            wrapperClass.mainPackage = packageRecord.Id;
            wrapperClass.SubscriptionId = subscriptionRecord.Id;
            wrapperClass.packageName = 'Test';
        Test.stopTest();
    }
    
    static testMethod void testSM_ChangeOfSubscriptionDetail2(){
        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                                  Email__c = 'sample@email.com',
                                  Mobile__c = '1234567',
                                  AccountNumber = 'subscriberId');
        insert acc;

        Contact con = new Contact(AccountId = acc.Id,
                                  FirstName = 'Test',
                                  LastName = 'Account',
                                  Phone = '0917911312',
                                  Recipient_Indicator__c = true,
                                  Billing_Indicator__c = true);
        insert con;
        
        Case caserec = new Case(AccountId = acc.Id,
                                Status='Waiting',
                                ContactId=con.Id);
        insert caserec;

        Package__c packageRecord = new Package__c(Name = 'Test Package', 
                                                  Package_Type__c = 'Grace Period',
                                                  Subscription_Type__c = 'Termed', 
                                                  Package_Code__c = 'PackageCode',
                                                  Effective_Start_Date__c = date.today(), 
                                                  Effective_End_Date__c = date.today()+100, 
                                                  Subscription_Period__c = '1');
        insert packageRecord;

        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Name = 'Test Billing Account',
                                                                          Zuora__Account__c = acc.id,
                                                                          Billing_Contact__c = con.id,
                                                                          Zuora__Status__c = 'Active',
                                                                          Payment_Mode__c = 'CreditCard',
                                                                          Zuora__Credit_Balance__c = 2,
                                                                          Billing_Type__c = 'Full Prepaid');
        insert billAcc;

        Order__c orderRecord = new Order__c(Credit_Balance__c = 20000.00, 
                                            Delivery_Charge__c = 100.00,
                                            Monthly_Delivery_Charge_for_Full_Payment__c = 100.00,
                                            Account__c = acc.Id,
                                            Order_Type__c = 'Change of Subscription Package',
                                            Status__c = 'Draft',
                                            Billing_Type__c = 'Full Prepaid',
                                            Billing_Account_Creation_Mode__c = 'Use existing Billing Account',
                                            Billing_Contact__c = con.Id,
                                            //Billing_Account__c = billAcc.Id,
                                            isOrderLegacy__c = true);
        insert orderRecord;

        Order_Line_Item__c orderline = new Order_Line_Item__c(Order__c = orderRecord.Id,
                                                              Main_Package_ID__c = packageRecord.Id,
                                                              Term_Length__c = 0,
                                                              Main_Package_Period__c = 0,
                                                              Earliest_Start_Date__c = date.today()+10,
                                                              Earliest_Stop_Date__c = date.today()+15,
                                                              Stop_Request_Date__c = date.today()+1,
                                                              Start_Date__c = date.today()+2,
                                                              Terminating_Reason__c = 'Others',
                                                              Amount_To_Refund__c = 0,
                                                              Admin_Charge__c = 0,
                                                              Fee_Override__c = TRUE,
                                                              Override_Reason__c = 'TEST',
                                                              Suppress_Notification_Stop__c = TRUE,
                                                              Delivered_By__c = 'Vendor',
                                                              Main_Package_Type__c = 'Base',
                                                              Main_Package_Billing_Type__c = 'Full Prepaid',
                                                              End_Date__c = date.newInstance(2016, 12, 2),
                                                              Is_Digital__c = true,
                                                              Fee_Waiver__c = true,
                                                              Case__c = caserec.Id);
        insert orderline;

        Zuora__Subscription__c subscriptionRecord = new Zuora__Subscription__c(Name = 'Test Subscription', 
                                                        Zuora__Zuora_Id__c = 'ZID',
                                                        Next_Earliest_Start_Date__c = date.today()+30,
                                                        Unique_Address_Id__c = 'UAID00000', 
                                                        Zuora__Version__c = 1, 
                                                        Delivery_Charge__c = 200.00, 
                                                        Vendor_Credit_1__c = 20000.00,
                                                        Term_Length__c = 10, 
                                                        Number_of_Copies__c = 3, 
                                                        Zuora__SubscriptionEndDate__c = date.today()+100,
                                                        Zuora__SubscriptionStartDate__c = date.today(),  
                                                        Legacy_Create_By__c = 'User', 
                                                        Legacy_Create_Date__c = '10/24/2014',
                                                        Legacy_Subscription_ID__c = 'LSUB00000', 
                                                        Legacy_Update_By__c = 'User',
                                                        Legacy_Update_Date__c = '10/24/2014', 
                                                        Number_of_Copies1__c = '1',
                                                        Zuora__CustomerAccount__c = billAcc.Id,
                                                        Main_Package_1__c = packageRecord.Id,
                                                        Zuora__Account__c = acc.Id,
                                                        Subscription_Type_1__c = 'Publication',
                                                        Recipient_Contact__c = con.Id,
                                                        Cost_Center__c = 'Class',
                                                        Order_Number_1__c = orderRecord.Id,
                                                        Delivery_Charge_Type_1__c = 'H');
        insert subscriptionRecord;
        
        PageReference pg = Page.SM_ChangeOfSubscriptionDetail;
        pg.getParameters().put('Id',orderRecord.Id);
        pg.getParameters().put('accountId',acc.Id);
        Test.setCurrentPage(pg);
        
        Test.startTest();
            SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
            controller.retrieveOrder();
            controller.creditBalance(orderRecord.Id);
            controller.submit();
            controller.void();
            controller.edit();
            controller.doCancel();
        Test.stopTest();
    }
    
    static testMethod void testSM_ChangeOfSubscriptionDetail3(){
        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                                  Email__c = 'sample@email.com',
                                  Mobile__c = '1234567',
                                  AccountNumber = 'subscriberId');
        insert acc;

        Contact con = new Contact(AccountId = acc.Id,
                                  FirstName = 'Test',
                                  LastName = 'Account',
                                  Phone = '0917911312',
                                  Recipient_Indicator__c = true,
                                  Billing_Indicator__c = true);
        insert con;
        
        Case caserec = new Case(AccountId = acc.Id,
                                Status='Waiting',
                                ContactId=con.Id);
        insert caserec;

        Package__c packageRecord = new Package__c(Name = 'Test Package', 
                                                  Package_Type__c = 'Grace Period',
                                                  Subscription_Type__c = 'Termed', 
                                                  Package_Code__c = 'PackageCode',
                                                  Effective_Start_Date__c = date.today(), 
                                                  Effective_End_Date__c = date.today()+100, 
                                                  Subscription_Period__c = '1');
        insert packageRecord;

        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Name = 'Test Billing Account',
                                                                          Zuora__Account__c = acc.id,
                                                                          Billing_Contact__c = con.id,
                                                                          Zuora__Status__c = 'Active',
                                                                          Payment_Mode__c = 'Cash',
                                                                          Zuora__Credit_Balance__c = 2,
                                                                          Billing_Type__c = 'Full Prepaid');
        insert billAcc;
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Name = 'Test Subscription', 
                                                        Zuora__Zuora_Id__c = 'ZID',
                                                        Next_Earliest_Start_Date__c = date.today()+30,
                                                        Unique_Address_Id__c = 'UAID00000', 
                                                        Zuora__Version__c = 1, 
                                                        Delivery_Charge__c = 200.00, 
                                                        Vendor_Credit_1__c = 20000.00,
                                                        Term_Length__c = 10, 
                                                        Number_of_Copies__c = 3, 
                                                        Zuora__SubscriptionEndDate__c = date.today()+100,
                                                        Zuora__SubscriptionStartDate__c = date.today(),  
                                                        Legacy_Create_By__c = 'User', 
                                                        Legacy_Create_Date__c = '10/24/2014',
                                                        Legacy_Subscription_ID__c = 'LSUB00000', 
                                                        Legacy_Update_By__c = 'User',
                                                        Legacy_Update_Date__c = '10/24/2014', 
                                                        Number_of_Copies1__c = '1',
                                                        Zuora__CustomerAccount__c = billAcc.Id,
                                                        Main_Package_1__c = packageRecord.Id,
                                                        Zuora__Account__c = acc.Id,
                                                        Subscription_Type_1__c = 'Publication',
                                                        Subscription_Type__c = 'Publication',
                                                        Recipient_Contact__c = con.Id,
                                                        Cost_Center__c = 'Class',
                                                        //Order_Number_1__c = orderRecord.Id,
                                                        Delivery_Charge_Type_1__c = 'H',
                                                        Billing_Type__c = 'Full Prepaid',
                                                        Zuora__Status__c = 'Active',
                                                        Vendor_1__c = acc.Id);
        insert sub;
        sub = [SELECT Id, Subscription_Type_1__c, Zuora__Account__c, Zuora__Status__c FROM Zuora__Subscription__c WHERE Id = :sub.Id];
        System.debug('*****'+sub);

        Order__c orderRecord = new Order__c(Credit_Balance__c = 20000.00, 
                                            Delivery_Charge__c = 100.00,
                                            Monthly_Delivery_Charge_for_Full_Payment__c = 100.00,
                                            Account__c = acc.Id,
                                            Order_Type__c = 'Change of Subscription',
                                            Order_Type1__c = 'Change of Subscription',
                                            Status__c = 'Draft',
                                            Billing_Type__c = 'Full Prepaid',
                                            Billing_Account_Creation_Mode__c = 'Use existing Billing Account',
                                            Billing_Contact__c = con.Id,
                                            //Billing_Account__c = billAcc.Id,
                                            isOrderLegacy__c = true,
                                            Subscription__c = sub.Id,
                                            isChangeOfSubEntry__c = true);
        System.assert(sub.Subscription_Type_1__c=='Publication');
        System.assert(sub.Zuora__Account__c==orderRecord.Account__c);
        System.assert(sub.Zuora__Status__c!='Cancelled');
        System.assert(orderRecord.Order_Type__c.contains('Change of Subscription'));
        System.assert(orderRecord.Order_Type1__c.contains('Change of Subscription'));
        System.assert(orderRecord.isChangeOfSubEntry__c==true);
        insert orderRecord;

        Order_Line_Item__c orderline = new Order_Line_Item__c(Order__c = orderRecord.Id,
                                                              Main_Package_ID__c = packageRecord.Id,
                                                              Term_Length__c = 0,
                                                              Main_Package_Period__c = 0,
                                                              Earliest_Start_Date__c = date.today()+10,
                                                              Earliest_Stop_Date__c = date.today()+15,
                                                              Stop_Request_Date__c = date.today()+1,
                                                              Start_Date__c = date.today()+5,
                                                              Terminating_Reason__c = 'Others',
                                                              Amount_To_Refund__c = 0,
                                                              Admin_Charge__c = 0,
                                                              Fee_Override__c = TRUE,
                                                              Override_Reason__c = 'TEST',
                                                              Suppress_Notification_Stop__c = TRUE,
                                                              Delivered_By__c = 'Vendor',
                                                              Main_Package_Type__c = 'Base',
                                                              Main_Package_Billing_Type__c = 'Full Prepaid',
                                                              End_Date__c = date.newInstance(2016, 12, 2),
                                                              Is_Digital__c = true,
                                                              Fee_Waiver__c = true,
                                                              Case__c = caserec.Id);
        insert orderline;

        Zuora__Subscription__c subscriptionRecord = new Zuora__Subscription__c(Name = 'Test Subscription', 
                                                        Zuora__Zuora_Id__c = 'ZID',
                                                        Next_Earliest_Start_Date__c = date.today()+30,
                                                        Unique_Address_Id__c = 'UAID00000', 
                                                        Zuora__Version__c = 1, 
                                                        Delivery_Charge__c = 200.00, 
                                                        Vendor_Credit_1__c = 20000.00,
                                                        Term_Length__c = 10, 
                                                        Number_of_Copies__c = 3, 
                                                        Zuora__SubscriptionEndDate__c = date.today()+100,
                                                        Zuora__SubscriptionStartDate__c = date.today(),  
                                                        Legacy_Create_By__c = 'User', 
                                                        Legacy_Create_Date__c = '10/24/2014',
                                                        Legacy_Subscription_ID__c = 'LSUB00000', 
                                                        Legacy_Update_By__c = 'User',
                                                        Legacy_Update_Date__c = '10/24/2014', 
                                                        Number_of_Copies1__c = '1',
                                                        Zuora__CustomerAccount__c = billAcc.Id,
                                                        Main_Package_1__c = packageRecord.Id,
                                                        Zuora__Account__c = acc.Id,
                                                        Subscription_Type_1__c = 'Publication',
                                                        Recipient_Contact__c = con.Id,
                                                        Cost_Center__c = 'Class',
                                                        Order_Number_1__c = orderRecord.Id,
                                                        Delivery_Charge_Type_1__c = 'H',
                                                        Billing_Type__c = 'Full Prepaid');
        insert subscriptionRecord;
        
        Promotion_Gift__c promotionPackageGiftRecord = new Promotion_Gift__c(Gift_Inventory__c=1000,
                                                                             Gift_Issued__c=100, 
                                                                             Gift_Redeemed__c=100);
        insert promotionPackageGiftRecord;
        
        Order_Line_Item_Gift__c orderLineItemGiftRecord = new Order_Line_Item_Gift__c(Order_Line_Item__c = orderline.Id,
                                                                                      Order_Quantity__c = 3,
                                                                                      Hidden_Status__c = 'Hidden',
                                                                                      Promotion_Gift__c = promotionPackageGiftRecord.Id);
        insert orderLineItemGiftRecord;
        
        PageReference pg = Page.SM_ChangeOfSubscriptionDetail;
        pg.getParameters().put('Id',orderRecord.Id);
        pg.getParameters().put('accountId',acc.Id);
        Test.setCurrentPage(pg);
        
        Test.startTest();
            SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
        	controller.thisOrder = orderRecord;
            controller.retrieveOrder();
            controller.creditBalance(orderRecord.Id);
            controller.submit();
            controller.void();
            controller.edit();
            controller.doCancel();
            controller.selectedPackageId = packageRecord.Id;
        Test.stopTest();
    }
}