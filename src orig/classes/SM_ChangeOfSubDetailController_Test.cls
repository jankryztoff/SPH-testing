@isTest(SeeAllData = true)
private class SM_ChangeOfSubDetailController_Test {
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       //Generate a map of tokens for all the Record Types for the desired object
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

       //Retrieve the record type id by name
       return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }
    
    static testMethod void testSMChangeOfSubscriptionDetailController(){
        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                                  Email__c = 'sample@email.com',
                                  Mobile__c = '1234567',
                                  AccountNumber = 'subscriberId');
        insert acc;

        Contact con = new Contact(FirstName = 'trial',
                                  LastName = 'tail',
                                  Phone = '0917911312',
                                  Recipient_Indicator__c = true);
        insert con;

        Package__c packageRecord = new Package__c(Name = 'Test Package', 
                                                  Package_Type__c = 'Grace Period',
                                                  Subscription_Type__c = 'Termed', 
                                                  Package_Code__c = 'PackageCode',
                                                  Effective_Start_Date__c = date.today(), 
                                                  Effective_End_Date__c = date.today()+100, 
                                                  Subscription_Period__c = '1');
        insert packageRecord;

        zqu__ZProduct__c zProductRecord = new zqu__ZProduct__c(Name='Test Quote Wizard', 
                                                               zqu__SKU__c='SKU',
                                                               ProductCode__c='Product Code', 
                                                               zqu__ZuoraId__c='ZID',
                                                               ProductType__c='Product Type',
                                                               ProductPlatform__c = 'All-In-One'
                                                               ); 
        insert zProductRecord;

        zqu__ProductRatePlan__c productRatePlanRecord = new zqu__ProductRatePlan__c(Name = 'Test Product Rate Plan', 
                                                                                    RatePlanCode__c = 'TestRatePlan',
                                                                                    zqu__ZuoraId__c = 'ZID', 
                                                                                    RatePlanType__c = 'Proration',
                                                                                    zqu__ZProduct__c = zProductRecord.Id);
        insert productRatePlanRecord;

        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Name = 'Test Billing Account',
                                                                          Zuora__Account__c = acc.id,
                                                                          Billing_Contact__c = con.id,
                                                                          Zuora__Status__c = 'Active');
        insert billAcc;

        Order__c orderRecord = new Order__c(Credit_Balance__c = 20000.00, 
                                            Delivery_Charge__c = 100.00,
                                            Monthly_Delivery_Charge_for_Full_Payment__c = 100.00,
                                            Account__c = acc.Id,
                                            Order_Type__c = 'Change of Subscription Package',
                                            Status__c = 'Draft');
        insert orderRecord;

        Order_Line_Item__c orderline = new Order_Line_Item__c(Order__c = orderRecord.Id,
                                                              Main_Package_ID__c = packageRecord.Id,
                                                              Term_Length__c = 0,
                                                              Main_Package_Period__c = 0,
                                                              Earliest_Start_Date__c = date.today(),
                                                              Earliest_Stop_Date__c =date.newInstance(2016, 12, 2),
                                                              Stop_Request_Date__c = date.newInstance(2016, 12, 2),
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
                                                              Is_Digital__c = true);
        insert orderline;
        
        Promotion_Gift__c promotionGift = new Promotion_Gift__c(Gift_Inventory__c = 1000,
                                                                Gift_Issued__c = 100, 
                                                                Gift_Redeemed__c = 100);
        insert promotionGift;
        
        Order_Line_Item_Gift__c orderlinegift = new Order_Line_Item_Gift__c(Order_Line_Item__c = orderline.Id,
                                                                            Hidden_Status__c = 'Go',
                                                                            Has_Letter_Attached__c = true,
                                                                            Order_Quantity__c = 2,
                                                                            Promotion_Gift__c = promotionGift.Id);
        insert orderlinegift;

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
                                                        Order_Line_Item_Number_1__c = orderline.Id);
        insert subscriptionRecord;

        Publication__c pub = new Publication__c(Name = 'wow',
                                                Publication_Code__c = 'qweq',
                                                Published_Days__c = 'NNYYNNY',
                                                Publication_Type__c = 'e');
        insert pub;

        Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='Test Asia One1', 
                                              Email__c='testasiaone@email.com');
        insert asiaOneRecord;

        Asia1_Subscription__c asiaOneSubscriptionRecord = new Asia1_Subscription__c(Status__c = 'Enabled',
                                                                                    Asia1__c =  asiaOneRecord.Id,
                                                                                    Subscription__c = subscriptionRecord.Id,
                                                                                    Concurrent__c = 124);
        insert asiaOneSubscriptionRecord;

        Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item', 
                                                                RecordTypeId = getObjectRecordTypeId(Package_Item__c.SObjectType,'Base Product'),
                                                                Package__c = packageRecord.Id,
                                                                Bundle_Item_No__c = 8,
                                                                Duration_in_months__c='10',
                                                                Effective_Start_Month__c='1',
                                                                Product_Rate_Plan__c = productRatePlanRecord.Id);
        insert packageItemRecord;
        
        PageReference pg = Page.SM_ChangeOfSubscriptionDetail;
        pg.getParameters().put('Id',orderRecord.Id);
        pg.getParameters().put('accountId',acc.Id);
        Test.setCurrentPage(pg);
        
        Test.startTest();
            SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
            controller.retrieveOrder();
            
        Test.stopTest();
        
        /*SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
        SM_SubscriptionHelper subHelper = new SM_SubscriptionHelper();
        
        //set current page parameters        
        PageReference pr = new Pagereference('/apex/SM_ChangeOfSubscriptionDetail?id=' + o.Id + '&accountId=' + o.Account__c);
        //PageReference pageRef = new Pagereference('/apex/SM_ChangeOfSubscriptionDetail');
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('id',o.id);
        ApexPages.currentPage().getParameters().put('accountId',a.id);
       
        //System.AssertEquals(0,ApexPages.currentPage().Messages().size());
        controller.retrieveOrder();
        
        //System.assertNotEquals(null, controller.thisOrder);
        
        SM_ChangeOfSubscriptionDetailController.SubscriptionWrapper page = new SM_ChangeOfSubscriptionDetailController.SubscriptionWrapper();
        
        string queryStr = SM_SubscriptionHelper.generateOrderSoqlStr();
        queryStr += ' where (Order_Type__c = \'Change of Subscription Package\' and Account__c = \'' + a.id  + '\' and Status__c =\'Draft\')';
        queryStr += ' or Id = \'' + o.id  + '\' limit 1';
        
        
        list<SObject> orderList = new list<SObject>();
        Order__c thisOrder = new Order__c();
        orderList = database.query(queryStr);
        controller.thisOrder = (Order__c)orderList[0];
               
        controller.edit();*/
    }
}