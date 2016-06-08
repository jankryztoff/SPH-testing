/**
 * Class Name: Quote_HandlerTest     
 * @author: Accenture IDC - Nilesh    
 * Date: 24 Feb 2015    
 * Requirement/Project Name: SPH Project    
 * @description Test Class for Quote_Handler    
 */
@isTest
public class Quote_HandlerTest {

    public static String deliveryChargeType = 'L';
    public static String origin = 'ESHOP Webservice';
    public static Date today = date.today();
        
    static testmethod void testCreate_Quotes()
    {
        defaultCustomSetting();
        
        //Create a new user with Standard User Profile
        User testUser = new User(
                Alias = 'testUser',
                Email='testStandarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId =  [SELECT id FROM Profile WHERE NAME = 'System Administrator'].Id,//(Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
        );
            
        System.runAs(testUser) {
        
            Order__c testOrder = generateData();
             System.debug('**WENDY: generateData() complete');
            Order_Line_Item__c testOrderLineItem = [SELECT Id, Name, End_Date__c, Main_Package_ID__r.Subscription_Type__c, Qty__c,Charity__c,Delivered_By__c,Vendor_Mailing_Agent__c,Main_Package_Frequency__c,Main_Package_ID__c, Main_Package_Product_Sub_Type__c, Order__c, Urgent__c, Suppress_Vendor_Start_notice__c, Supressed_Acknowledgement_Letter__c,Suppress_Renewal_and_Reminder_Letter__c, 
                                                        Main_Package_Billing_Type__c, PO_Number__c, Term_Length__c, Start_Date__c, Promotion_Contract_Period__c
                                                         FROM  Order_Line_Item__c WHERE Order__c =: testOrder.Id limit 1];
                                
                //Test.startTest();
                    System.debug('**WENDY: test00');
                    Quote_Handler testInstance = new Quote_Handler();
                    //karenmae 04.14.15 edited param
                    //WAK: edited param: testInstance.Create_Quotes(testOrder, 'string origin', origin);
                    System.debug('**WENDY: test0');
                    testInstance.Create_Quotes(testOrder, 'string origin', testOrderLineItem.Id);
                    System.debug('**WENDY: test1');
                    Quote_Handler.createQuoteExtension(testOrderLineItem,testOrder,'2','Test',origin);
                    System.debug('**WENDY: test2');
                    //karenmae 04.14.15 edited param
                    Quote_Handler.createQuoteDelivery(testOrder, testOrderLineItem,'Test','origin');
                    System.debug('**WENDY: test3');
                Test.stopTest();
        }        
    }
    
    private static Order__c generateData()
    {
        Account testAccount = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert testAccount;
                                
        Singpost_Address__c testSingpostAddress = TestDataFactory.createSingpostAddress(1)[0];
            testSingpostAddress.Name = '99';
            testSingpostAddress.House_Block_Number__c = 'TEST';
            testSingpostAddress.Address_Type__c = deliveryChargeType;
        insert testSingpostAddress;
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
        Address__c testAddress = TestDataFactory.createAddress(1)[0];
            testAddress.Postal_Code__c = testSingpostAddress.Id;
            testAddress.RecordTypeId = getRecordType('Local','Address__c').Id;
            testAddress.Address_Type__c = deliveryChargeType;
        insert testAddress;
        
        Contact testContact = TestDataFactory.createContact(1)[0];
            testContact.AccountId = testAccount.Id;
            testContact.Address__c = testAddress.Id;
            //testContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            testContact.Recipient_Indicator__c = true;
            testContact.Billing_Indicator__c = true;
        insert testContact;
        
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
            testProduct.ProductPlatform__c = 'Print';
            testProduct.ProductType__c = 'Gift';
            testProduct.ProductSubType__c = 'Premium';
            testProduct.ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
        insert testProduct;
        
        zqu__ProductRatePlan__c testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.Name = 'LANDED DELIVERY CHARGE';
            testProductRatePlan.zqu__ZProduct__c = testProduct.Id;
            testProductRatePlan.RatePlanType__c = 'Bill Plan';
            testProductRatePlan.zqu__EffectiveStartDate__c = today;
            testProductRatePlan.zqu__EffectiveEndDate__c = today.addDays(30);
            testProductRatePlan.zqu__Deleted__c = false;
            testProductRatePlan.RatePlanCode__c = 'CHGPOS';
        insert testProductRatePlan;
        
        Package__c testPackageBase = TestDataFactory.createPackage(1)[0];
            testPackageBase.Name = 'Test Package Base';
            testPackageBase.Package_Type__c = 'Base';
            testPackageBase.Subscription_Type__c = 'Termed';
            testPackageBase.Subscription_Period__c = '4';
            testPackageBase.Package_Code__c = 'Base';
        insert testPackageBase;
        
        Package__c testPackageBundled = testPackageBase.clone(false, false, false, false);
            testPackageBundled.Name = 'Test Package Bundled';
            testPackageBundled.Package_Type__c = 'Bundled';
            testPackageBundled.Subscription_Type__c = 'Termed';
            testPackageBundled.Subscription_Period__c = '4';
            testPackageBundled.Package_Code__c = 'Bundled';
        insert testPackageBundled;
        
        Package__c testPackageAddOn = testPackageBase.clone(false, false, false, false);
            testPackageAddOn.Name = 'Test Package Add On';
            testPackageAddOn.Package_Type__c = 'Add On';
            testPackageAddOn.Subscription_Type__c = 'Termed';
            testPackageAddOn.Subscription_Period__c = '4';
            testPackageAddOn.Package_Code__c = 'Add On';
            testPackageAddOn.Eligible_Product_Family_for_Add_On_Pack__c = 'Bundled';
            testPackageAddOn.Billing_Type__c = 'Prepaid';
        insert testPackageAddOn;    
        
        Package_Item__c testPackageItemBundleProduct = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
            testPackageItemBundleProduct.Package__c = testPackageBundled.Id;
            testPackageItemBundleProduct.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItemBundleProduct.Duration_in_months__c = '3';
            testPackageItemBundleProduct.Effective_Start_Month__c = '3';
        insert testPackageItemBundleProduct;
                
        Package_Item__c testPackageItem = TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];
            testPackageItem.Package__c = testPackageBundled.Id;
            testPackageItem.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItem.Base_Package_Item__c = testPackageItemBundleProduct.Id;
            testPackageItem.Duration_in_months__c = '3';
            testPackageItem.Effective_Start_Month__c = '3';
        insert testPackageItem;     
                
        Product_Family__c testProductFamily = new Product_Family__c();
            testProductFamily.Product_Family__c = 'Test Product Family';
            testProductFamily.Product_Family_name__c = 'Test Product Family';
        insert testProductFamily;

        //WAK: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = testProductRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c testPackageItemBase = TestDataFactory.createPackageItem(1,'Base Product')[0];
            testPackageItemBase.Name = 'Test Pack Item Base Product';
            testPackageItemBase.Package__c = testPackageBase.Id;
            testPackageItemBase.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItemBase.Product_Family__c = testProductFamily.id;
        insert testPackageItemBase;

        /*Package_Item__c testPackageItemBaseAddOn = testPackageItemBase.clone(false, false, false, false);
            testPackageItemBaseAddOn.Name = 'Test Pack Item Base Product Add On';
            testPackageItemBaseAddOn.Package__c = testPackageAddOn.Id;
            testPackageItemBaseAddOn.Product_Rate_Plan__c = testProductRatePlan.Id;       
            testPackageItemBaseAddOn.Product_Family__c = testProductFamily.id;
        insert testPackageItemBaseAddOn;*/
        
        Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
            testCustomerAccount.Zuora__Account__c = testAccount.Id;
            testCustomerAccount.Billing_Type__c = 'Full Prepaid';
            //billAcc[0].Zuora__Account__c = acc.Id;
            //billAcc[0].Billing_Type__c = 'Full Prepaid';
            testCustomerAccount.Billing_Contact__c = testContact.id;
            testCustomerAccount.Zuora__Credit_Balance__c = 50000.00;
            testCustomerAccount.Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
        insert testCustomerAccount;
        
        Order__c testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id;
            testOrder.Payment_Mode__c = 'Cash';
            testOrder.Recipient_Contact__c = testContact.Id;
            testOrder.Billing_Account__c = testCustomerAccount.Id;
            testOrder.Billing_Contact__c = testContact.Id;
            testOrder.Billing_Type__c = testCustomerAccount.Billing_Type__c;
            testOrder.Informed_Customer__c = True;
            testOrder.Subscriber_Charge__c = 10.0;
            testOrder.Delivery_Charge__c = 1;
            testOrder.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        insert testOrder;
        
        Subscription_Vendor__c testSubscriptionVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert testSubscriptionVendor;
        
        Promotion_Package__c testPromotionPackage =  TestDataFactory.createPromotionPackage(1)[0];
            testPromotionPackage.Package_Name__c = testPackageBundled.id;
        insert testPromotionPackage;
        
        Promotion__c testPromotion = TestDataFactory.createPromotion(1)[0];
            testPromotion.Contract_Period__c = '1';
        insert testPromotion;
        
        List<Order_Line_Item__c> testOrderLineItemList = TestDataFactory.createOrderLineItem(2);
                
        String[] deliverBy = new String[]{'Mailing Agent', 'Vendor'};
                
        for(Integer count = 0 ; count < testOrderLineItemList.size(); count++)
            {               
                Order_Line_Item__c testOrderLineItem = testOrderLineItemList[count];
                    
                testOrderLineItem.Order__c = testOrder.Id;
                testOrderLineItem.Vendor_Subscription_ID__c = testSubscriptionVendor.Id;
                testOrderLineItem.Main_Package_ID__c = testPackageBundled.id;
                testOrderLineItem.Vendor_Mailing_Agent__c = testAccount.Id;
                testOrderLineItem.Addon_Package__c = testPackageAddOn.id;
                testOrderLineItem.Vendor_Conversion__c = True;
                testOrderLineItem.Contract_End_Date__c = today;
                testOrderLineItem.Promotion_ID__c = testPromotion.id;
                testOrderLineItem.Main_Package_Product_Platform__c = 'All-In-One';
                testOrderLineItem.Main_Package_Product_Sub_Type__c = 'Newspaper';
                testOrderLineItem.Main_Package_Product_Family__c = 'Bundled';
                testOrderLineItem.Main_Package_Billing_Type__c = 'Prepaid';
                testOrderLineItem.Delivered_By__c = deliverBy[count];
                testOrderLineItem.Postage_Charge__c = 1;
                //WAK: Edited Start_Date__c
                testOrderLineItem.Start_Date__c = today + 1;
                testOrderLineItem.Qty__c = 10;
                testOrderLineItem.Term_Length__c = 1;
            }
                
        insert testOrderLineItemList;
                        
        testOrder.Subscriber_Charge__c = 10.0;
        update testOrder;
       
        Gift__c testGift = TestDataFactory.createGift(1)[0];
            testGift.Gift_Type__c = 'Premium';
            testGift.One_Time_Charge__c = 100.0;
        insert testGift;
        
        Promotion_Gift__c testPromotionGift = TestDataFactory.createPromotionGift(1)[0];
            testPromotionGift.Gift__c = testGift.Id;
        insert testPromotionGift;
        
        Order_Line_Item_Gift__c testOrderLineItemGift = TestDataFactory.createItemGift(1)[0];
            testOrderLineItemGift.Order_Line_Item__c = testOrderLineItemList[0].Id;
            testOrderLineItemGift.Promotion_Gift__c = testPromotionGift.Id;
            testOrderLineItemGift.Order_Quantity__c = 5;
        insert testOrderLineItemGift;
        
        zqu__Quote__c testQuote = TestDataFactory.createQuote(1)[0];
            testQuote.Subscription_Type__c = 'Delivery';
        insert testQuote;
        
        zqu__QuoteCharge__c testQuoteCharge = TestDataFactory.createQuoteCharge(1)[0];
            testQuoteCharge.zqu__Quote__c = testQuote.Id;
            testQuoteCharge.zqu__Quantity__c = 8;
            testQuoteCharge.zqu__EffectivePrice__c =50;
        insert testQuoteCharge;
        
        Zuora__Subscription__c testSubscription = TestDataFactory.createSubscription(1)[0];
            testSubscription.Acquisition_Type__c = 'Test';
            testSubscription.Zuora__Account__c = testAccount.Id;
            testSubscription.Order_Line_Item_Number__c = testOrderLineItemList[0].Id;
            testSubscription.Order_Number__c = testOrder.Id;        
            testSubscription.Suppress_Vendor_Start_Notice__c = 'false';
            testSubscription.Supressed_Acknowledgement_Letter__c = 'false';
            testSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            testSubscription.Urgent__c = 'false';
            testSubscription.Vendor_Conversion__c = 'false';
            testSubscription.Charity__c = 'true';
            testSubscription.Sponsor__c = 'false';
            testSubscription.Recipient_Contact__c = testContact.Id;
            testSubscription.Subscription_Type__c ='Delivery';
            testSubscription.Subscription_Charge__c = 100.00;
            testSubscription.Zuora__Status__c = 'Active';
            testSubscription.Zuora__CustomerAccount__c = testCustomerAccount.id;
            testSubscription.Number_of_Copies1__c = '1';
            testSubscription.Number_of_Copies__c = 1;
            Test.startTest();
        insert testSubscription;
        
        return testOrder;
    }
    
    private static RecordType getRecordType(String recordTypeValue,String objectType)
    {
        RecordType testRecordType = null;
        
        if(recordTypeValue != null)
        {
            testRecordType = [SELECT id FROM RecordType WHERE SobjectType = :objectType AND Name=: recordTypeValue LIMIT 1][0];
        }
        
        return testRecordType;
    }

    static void defaultCustomSetting()
    {
        Key_Id__c keyId;
        Other__c otherC;        
        
        String[] keyIdNameArray = new String[]{'AddAirline','AddInternal','AddLocal','AddOverseas','Package Item_Extension Product','SubTermTypeEvergreen','SubTypeGift','Package Item_Bundle Discount','SubTermTypeTermed','QuoteInvoiceProcessingSubscription','CurrencySGD','Profile_System Administrator','Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER1','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'Airline','Internal','Local','Overseas','012N00000008jCnIAI','Evergreen','Gift','012N00000008jCiIAI','Termed','Subscription','SGD','00e90000001VZOq','012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Name','Name','Name','Name','RecordType','Name','Name','RecordType','Name','Name','Name','Profile','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
            insert keyId;
        }
        
        String[] orderCNameArray = new String[]{'LANDED DELIVERY CHARGE','Zero Charge Amount','Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print'};
        String[] orderCValueArray = new String[]{'LANDED DELIVERY CHARGE','Zero Charge Amount','Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print'};
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
            insert otherC;
        }
        
        Cir_Planner_Schedule__c testCirPlannerSchedule = new Cir_Planner_Schedule__c();
            testCirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            testCirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            testCirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Sun_Start_Time__c = System.Now();
            testCirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Name = 'CIR Plan Schedule';
        insert testCirPlannerSchedule;
        
        BatchInterface_Settings__c testBatchInterfaceSetting = new BatchInterface_Settings__c();
            testBatchInterfaceSetting.Name = 'Endpoint Delegator';
            testBatchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert testBatchInterfaceSetting;
        
        Delivery_Charge_Type__c testDeliveryChargeType = new Delivery_Charge_Type__c();
            testDeliveryChargeType.Name = deliveryChargeType;
            testDeliveryChargeType.Default_Delivery_Charge_Type__c = 'L';
        insert testDeliveryChargeType;    

        Other__c testOther = new Other__c();
            testOther.Name = 'LOG_DEBUG_ON';
            testOther.Value__c = 'TRUE';
        insert testOther;  
    }
}