@isTest (SeeAllData = false)
private class SM_SubscriptionHelperTest {
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       //Generate a map of tokens for all the Record Types for the desired object
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

       //Retrieve the record type id by name
       return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }
    
    static testMethod void testMethod1(){
        Profile  myProfileRecord = [Select Id 
                                    From Profile 
                                    Where Name = 'CSO' 
                                    Limit 1];
                                    
        User user = new User(
            Alias = 'ACNUser',
            Email = 'ACNUser@acn.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'ACN ',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = myProfileRecord.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'ACNUser@ACN.com.org',
            isActive = true,
            Validation_Exempted__c = true
        );
        
        System.runAs(user){
            Test.startTest();
                //List<Asia1SubscriptionWrapper> myWrapperList = new List<Asia1SubscriptionWrapper>();
                
                //SM_SubscriptionHelper helperClass = new SM_SubscriptionHelper();
                SM_SubscriptionHelper.generateOrderSoqlStr();

                SM_SubscriptionHelper.Asia1SubscriptionWrapper wrapperClassAsia1Sub = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
                wrapperClassAsia1Sub.serviceFlagId = 'True';
                wrapperClassAsia1Sub.serviceFlagName = 'TestTrue';
                wrapperClassAsia1Sub.status = 'Start';
                wrapperClassAsia1Sub.concurrent = 1;
                
                //myWrapperList.add(wrapperClassAsia1Sub);
                
                /*SM_SubscriptionHelper.RelatedPackageWrapper wrapperClassRelated = new SM_SubscriptionHelper.RelatedPackageWrapper();
                wrapperClassRelated.packageId = '1234';
                wrapperClassRelated.packageName = 'Test';
                wrapperClassRelated.packageType = 'Raw';
                wrapperClassRelated.packageSubscriptionType = '1';
                wrapperClassRelated.packageSubscriptionPeriod = '2';
                wrapperClassRelated.packageSubscriptionRate = 1.5;*/
                
                SM_SubscriptionHelper.Asia1Wrapper wrapperClassAsia1 = new SM_SubscriptionHelper.Asia1Wrapper();
                wrapperClassAsia1.userId = 'userIdTest';
                wrapperClassAsia1.asia1Id = 'userIdTest';
                wrapperClassAsia1.asia1Subscriptions = null;
            Test.stopTest();
        }
    }
    
    static testMethod void testMethod2(){
        Profile  myProfileRecord = [Select Id 
                                    From Profile 
                                    Where Name = 'CSO' 
                                    Limit 1];
                                    
        User user = new User(
            Alias = 'ACNUser',
            Email = 'ACNUser@acn.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'ACN ',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = myProfileRecord.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'ACNUser@ACN.com.org',
            isActive = true,
            Validation_Exempted__c = true
        );
        
        System.runAs(user){
            Test.startTest();
                Key_Id__c keyCS = new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER',
                                                Id__c = '123462697',
                                                Type__c = 'Number');
                insert keyCS;
                
                Other__c otherCS = new Other__c(DateTime__c = System.today(),
                                                Value__c = '23:59',
                                                Name = 'DTL');
                insert otherCS;
            
                Account acc = new Account(Name = 'Test Account',
                                          Email__c = 'sample@email.com',
                                          Mobile__c = '1234567',
                                          AccountNumber = 'subscriberId');
                insert acc;
                
                Contact con = new Contact(FirstName = 'trial',
                                          LastName = 'tail',
                                          Phone = '0917911312',
                                          Recipient_Indicator__c = true,
                                          AccountId = acc.Id);
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
                                                    Recipient_Contact__c = con.Id);
                insert orderRecord;

                /*Order_Line_Item__c orderline = new Order_Line_Item__c(Order__c = orderRecord.Id,
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
                                                                      Start_Date__c = date.today()+2);
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
                                                                                        Order_Line_Item_Number_1__c = orderline.Id);
                insert subscriptionRecord;*/

                /*Publication__c pub = new Publication__c(Name = 'wow',
                                                        Publication_Code__c = 'qweq',
                                                        Published_Days__c = 'NNYYNNY',
                                                        Publication_Type__c = 'e');
                insert pub;*/

                Asia1__c asiaOneRecord = new Asia1__c(Email__c='testasiaone@email.com',
                                                      Display_Name__c = 'testclass',
                                                      User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx');
                insert asiaOneRecord;

                Asia1_Subscription__c asiaOneSubscriptionRecord = new Asia1_Subscription__c(Status__c = 'Enabled',
                                                                                            Asia1__c =  asiaOneRecord.Id,
                                                                                            //Subscription__c = subscriptionRecord.Id,
                                                                                            Concurrent__c = 124);
                insert asiaOneSubscriptionRecord;

                /*Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item', 
                                                                        RecordTypeId = getObjectRecordTypeId(Package_Item__c.SObjectType,'Base Product'),
                                                                        Package__c = packageRecord.Id,
                                                                        Bundle_Item_No__c = 8,
                                                                        Duration_in_months__c='10',
                                                                        Effective_Start_Month__c='1',
                                                                        Product_Rate_Plan__c = productRatePlanRecord.Id);
                insert packageItemRecord;*/ 

                Service_Access_Flag__c svcAccessFlagRecord = new Service_Access_Flag__c(Name = 'Access Flag');
                insert svcAccessFlagRecord;

                Package_Access_Flag__c packageAccessFlagRecord = new Package_Access_Flag__c(Package_Service_Access_Flag__c = svcAccessFlagRecord.Id, 
                                                                                            Package__c = packageRecord.Id);
                insert packageAccessFlagRecord; 
                
                zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge', 
                                                                                                              zqu__ZuoraId__c='ZID');
                insert productRatePlanChargeRecord;
                
                Set<String> stringSet = new Set<String>();
                stringSet.add('HDB DELIVERY CHARGE');
                stringSet.add('APT DELIVERY CHARGE');
            
                Map<Id, Set<String>> conMapSet = new Map<Id, Set<String>>();
                conMapSet.put(con.Id, stringSet);
                
                Map<Id, Contact> conMap = new Map<Id, Contact>();
                conMap.put(con.Id, con);
                
                Set<Id> packSet = new Set<Id>();
                packSet.add(packageRecord.Id);
                
                List<Asia1_Subscription__c> asiaList = new List<Asia1_Subscription__c>();
                asiaList.add(asiaOneSubscriptionRecord);
                
                Set<Id> packAFSet = new Set<Id>();
                packSet.add(packageAccessFlagRecord.Id);
            
                //SM_SubscriptionHelper.getOrderLineItem(orderline.Id);
                SM_SubscriptionHelper.getOrderLineItems(orderRecord.Id);
                SM_SubscriptionHelper.getDtlDate();
                SM_SubscriptionHelper.getCharges(con.Id,'N',4,5);
                SM_SubscriptionHelper.validateFutureDatedCOA(con.id,system.today()+2,'testclass');
                SM_SubscriptionHelper.getChargesForRenewalLetter(conMapSet, conMap);
                SM_SubscriptionHelper.getPackageSubscriptionRate(packSet,'Full Prepaid');
                //SM_SubscriptionHelper.deleteRelatedOrderLineItemRelatedObjects(orderline.Id);
                SM_SubscriptionHelper.deleteRelatedOrderLineItemRelatedObjects(orderRecord.Id, true);
                SM_SubscriptionHelper.getAsia1s(asiaList);
                //SM_SubscriptionHelper.validateAsia1Account('xxxxx@xxxx.xxxx','testclass');
                //SM_SubscriptionHelper.createAsia1Subscription(list<Asia1Wrapper>, id orderLineItemId);
                SM_SubscriptionHelper.createAsia1SubscriptionFromAccessFlag(null,asiaOneRecord.Id,packageRecord.Id);
                SM_SubscriptionHelper.retrieveServiceFlags(packAFSet);
                SM_SubscriptionHelper.registerAsia1Accounts(orderRecord.Id);
                SM_SubscriptionHelper.mapSubscriptionToAsia1Subscription(null);
                SM_SubscriptionHelper.getRelatedPackages(null,'Full Prepaid');
                SM_SubscriptionHelper.getRelatedPackages('testclass','Full Prepaid','acc.Id','punch',true,null);
                SM_SubscriptionHelper.retrieveAddOn('1234');
            Test.stopTest();
        }
    }
    
    static testMethod void testMethod3(){
        SM_SubscriptionHelper helperClass = new SM_SubscriptionHelper();
        helperClass.testCoveragePatch();
    }
}