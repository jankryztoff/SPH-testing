/**
 * Class Name: SP_DeliveryChargeHandlerCOATest
 * @author: Accenture IDC - Nilesh
 * Date: 27-2-2015
 * Requirement/Project Name: SPH
 * @description - Test Class for SP_DeliveryChargeHandlerCOA
 */
@isTest
public class SP_DeliveryChargeHandlerCOATest {
        static testMethod void testSP_DeliveryChargeHandlerCOATest(){

                    try 
                    {
                        defaultCustomSetting();
                        Map<String, SObject> sObjectMap = createSubscriptionPackage();
                         
                        Zuora__Subscription__c testSubscriptionPublication = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
                         
                        Account testAccount = (Account) sObjectMap.get('Account');
                        Address__c testAddress = (Address__c) sObjectMap.get('Address__c');
                        
                        Address__c testCloneAddress = testAddress.clone(false, false, false, false);
                        testCloneAddress.Name = 'Test Address - Clone';
                        insert testCloneAddress;
                        
                        Test.startTest();
                        SP_DeliveryChargeHandlerCOA testInstance = new SP_DeliveryChargeHandlerCOA();
                        testInstance.checkDeliveryCharge(testSubscriptionPublication.Id, testAccount.Id,testCloneAddress.Id, testAddress, 100.0);
                        Test.stopTest();
                    }
                    catch(Exception exp)
                    {
                        System.debug('Exception -' + exp);
                    }

        }
    
        public static Map<String, SObject> createSubscriptionPackage(){
    
                    Map<String, SObject> objectMap = new Map<String, SObject>(); 
                    
                    Singpost_Address__c testSingPostAddress = TestDataFactory.createSingpostAddress(1)[0];
                    testSingPostAddress.Name = 'SPostal';
                    testSingPostAddress.House_Block_Number__c = 'TEST';
                    testSingPostAddress.Address_Type__c = 'A';
                    objectMap.put('Singpost_Address__c', testSingPostAddress);
                    
                    Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    testAccount.NRIC__c = 'T1234567R';
                    objectMap.put('Account', testAccount);
                    
                    Package__c testPackage = new Package__c();
                    testPackage = TestDataFactory.createPackage(1)[0];
                    testPackage.Name = 'Pack name';
                    testPackage.Billing_Type__c = 'Full Prepaid';
                    testPackage.Package_Type__c = 'Base';
                    testPackage.Subscription_Period__c = '18';
                    testPackage.Package_Code__c = 'afds132';
                    objectMap.put('Package__c', testPackage);
                    
                    zqu__ZProduct__c testProduct = TestDataFactory.createZProduct(1)[0];
                    testProduct.ProductType__c = 'Charge';
                    testProduct.ProductSubType__c = 'Delivery';
                    objectMap.put('zqu__ZProduct__c', testProduct);
                    
                    insert objectMap.values();
                    
                    zqu__ProductRatePlan__c testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                    testProductRatePlan.Name = 'Zero Charge Amount';
                    testProductRatePlan.zqu__ZProduct__c = testProduct.Id;
                    testProductRatePlan.RatePlanType__c= 'Bill Plan';
                    testProductRatePlan.zqu__EffectiveStartDate__c= date.today();
                    testProductRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                    testProductRatePlan.zqu__Deleted__c = false;
                    insert testProductRatePlan;
                    objectMap.put('zqu__ProductRatePlan__c', testProductRatePlan);
                    
                    zqu__ProductRatePlanCharge__c testProductRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1)[0];
                    testProductRatePlanCharge.Name = 'Product Rate Plan Charge';
                    testProductRatePlanCharge.zqu__ProductRatePlan__c = testProductRatePlan.id;
                    testProductRatePlanCharge.zqu__ZuoraId__c = '3689922200';
                    insert testProductRatePlanCharge;
                    objectMap.put('zqu__ProductRatePlanCharge__c', testProductRatePlanCharge);
                    
                    Package_Item__c testPackageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                    testPackageItem.Package__c = testPackage.id;
                    testPackageItem.Product_Rate_Plan__c = testProductRatePlan.id;
                    testPackageItem.Name = 'Test Pack Item';
                    insert testPackageItem; 
                    objectMap.put('Package_Item__c', testPackageItem);   
                    
                    Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
                    testCustomerAccount.Zuora__Account__c = testAccount.Id;
                    testCustomerAccount.Zuora__External_Id__c = 'test';
                    testCustomerAccount.ARMS_Account_Type__c = 'Savings';
                    testCustomerAccount.ARMS_Business_Profile__c = 'ARMS Business Profile';
                    testCustomerAccount.ARMS_Debt_Management__c = 'picklist data type??';
                    testCustomerAccount.ARMS_ID__c = '00002';
                    testCustomerAccount.Zuora__AccountNumber__c = '12345667';
                    testCustomerAccount.Zuora__BillToAddress1__c = 'Address1';
                    testCustomerAccount.Zuora__BillToAddress2__c = 'Address2';
                    testCustomerAccount.Zuora__BillToPostalCode__c = '1900';
                    testCustomerAccount.Zuora__BillToCity__c = 'New York';
                    testCustomerAccount.Zuora__BillToName__c = 'John Smith';
                    insert testCustomerAccount;
                    objectMap.put('Zuora__CustomerAccount__c', testCustomerAccount);   
                    
                    Address__c testAddress = TestDataFactory.createAddress(1)[0];
                    testAddress.Address_Type__c = 'A';
                    testAddress.Postal_Code__c = testSingPostAddress.Id;
                    testAddress.Block_House_Number__c ='TEST';
                    testAddress.Level_Number__c ='xx';
                    testAddress.Unit_Number__c = 'yy';
                    insert testAddress;
                    objectMap.put('Address__c', testAddress);   
                    
                    Contact testRecipientContact = TestDataFactory.createContact(1)[0];
                    testRecipientContact.Address__c = testAddress.Id;
                    testRecipientContact.AccountId = testAccount.Id;
                    testRecipientContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    testRecipientContact.Recipient_Indicator__c = true;
                    insert testRecipientContact;
                    objectMap.put('Recipient Contact', testRecipientContact);   
                    
                    Contact testBillingContact = TestDataFactory.createContact(1)[0];
                    testBillingContact.Address__c = testAddress.Id;
                    testBillingContact.AccountId = testAccount.Id;
                    testBillingContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    testBillingContact.Billing_Indicator__c = true;
                    insert testBillingContact;
                    objectMap.put('Billing Contact', testBillingContact);   
                    
                    Order__c testOrder = TestDataFactory.createOrder(1)[0];
                    testOrder.Account__c = testAccount.Id;
                    testOrder.Informed_Customer__c = TRUE;
                    testOrder.Recipient_Contact__c = testRecipientContact.Id;
                    testOrder.Order_Type__c = 'Renewal';
                    testOrder.Status__c = 'Draft';
                    testOrder.Eligible_for_Retention__c = TRUE;
                    testOrder.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                    testOrder.Payment_Mode__c = 'Credit Card';
                    testOrder.Billing_Account__c = testCustomerAccount.id;
                    testOrder.Billing_Contact__c = testBillingContact.id;
                    testOrder.Case_Record_Type__c = 'Complaint - Magazine';
                    testOrder.Category__c = 'Subscription Request';
                    testOrder.Sub_Category__c ='Stop Subscription';
                    testOrder.Credit_Balance__c = 0;
                    testOrder.Delivery_Charge__c = 0;
                    testOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                    testOrder.Order_Type__c = 'Change of Subscription Package';
                    testOrder.PO_Number__c = 'PO00000';
                    insert testOrder;
                    objectMap.put('Order__c', testOrder);   
                        
                    Case testCase = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                    testCase.Order__c = testOrder.Id;
                    insert testCase;
                    objectMap.put('Case', testCase);   
                    
                    Order_Line_Item__c testOrderLineItem = TestDataFactory.createOrderLineItem(1)[0];
                    testOrderLineItem.Order__c = testOrder.Id;
                    testOrderLineItem.End_Date__c = Date.Today().addDays(1);
                    testOrderLineItem.Main_Package_ID__c = testPackage.Id;
                    testOrderLineItem.Term_Length__c = 0;
                    testOrderLineItem.Main_Package_Period__c = 0;
                    testOrderLineItem.Earliest_Start_Date__c = date.today();
                    testOrderLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
                    testOrderLineItem.Stop_Request_Date__c =  date.Today().addDays(4);
                    testOrderLineItem.Terminating_Reason__c = 'Others';
                    testOrderLineItem.Amount_To_Refund__c = 0;
                    testOrderLineItem.Admin_Charge__c = 0;
                    testOrderLineItem.Fee_Waiver__c = TRUE;
                    testOrderLineItem.Fee_Override__c = TRUE;
                    testOrderLineItem.Override_Reason__c = 'TEST';
                    testOrderLineItem.Suppress_Notification_Stop__c = TRUE;
                    testOrderLineItem.Main_Package_Type__c = 'Base';
                    insert testOrderLineItem;
                    objectMap.put('Order_Line_Item__c', testOrderLineItem);  
                    
                    
                    List<Zuora__Subscription__c> testSubscriptionList = TestDataFactory.createSubscription(2);
                    
                    for(Integer count=0; count < testSubscriptionList.size(); count++)
                    {
                    Zuora__Subscription__c testSubscription = testSubscriptionList[count];
                    testSubscription.Zuora__Account__c = testAccount.Id;
                    testSubscription.Zuora__Zuora_Id__c = '1123';
                    testSubscription.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                    testSubscription.Subscriber_Contact__c = testRecipientContact.Id;
                    testSubscription.Recipient_Contact__c = testRecipientContact.Id;
                    testSubscription.Main_Package_1__c = testPackage.id;
                    testSubscription.Zuora__Status__c = 'Active';
                    testSubscription.Order_Number__c = testOrder.Id;
                    testSubscription.Suppress_Vendor_Start_Notice__c = 'false';
                    testSubscription.Supressed_Acknowledgement_Letter__c = 'false';
                    testSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                    testSubscription.Urgent__c = 'false';
                    testSubscription.Vendor_Conversion__c = 'false';
                    testSubscription.Charity__c = 'false';
                    testSubscription.Billing_Type__c = 'Full Prepaid';
                    testSubscription.Order_Line_Item_Number__c = testOrderLineItem.id;
                    if(count == 0)
                    {
                    testSubscription.Subscription_Type_1__c = 'Publication';
                    testSubscription.Subscription_Type__c = 'Publication';
                    }
                    else
                    {
                    testSubscription.Subscription_Type_1__c = 'Delivery';
                    testSubscription.Subscription_Type__c = 'Delivery';
                    //          testSubscription.Zuora__CustomerAccount__c = testCustomerAccount.Id;
                    }
                    testSubscription.Zuora__Status__c = 'Active';
                    testSubscription.Order_Number_1__c = testOrder.id;
                    testSubscription.Zuora__Status__c = 'Active';
                    testSubscription.Generate_Invoice1__c = 'false';
                    }
                    
                    insert testSubscriptionList;
                    objectMap.put('Zuora__Subscription__c', testSubscriptionList[0]);       
                    
                    /* WHERE Zuora__Account__c =:selectedSubs.Zuora__Account__r.Id 
                    AND  Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY 
                    AND  Recipient_Contact__r.Address__r.Id =:newAddId
                    AND Zuora__Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE];    */
                    
                    return objectMap;
    }
    
    static void defaultCustomSetting()
    {
                    Key_Id__c keyId;
                    Other__c otherC;        
                    
                    String[] keyIdNameArray = new String[]{'Profile_Standard User','Default Quote Charge','DELCHG_APT','DELCHG_HDB','DELCHG_LAND','DELCHG_ZERO','AddAirline','AddInternal','AddLocal','AddOverseas','Package Item_Extension Product','SubTermTypeEvergreen','SubTypeGift','Package Item_Bundle Discount','SubTermTypeTermed','QuoteInvoiceProcessingSubscription','CurrencySGD','Profile_System Administrator','Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
                    String[] keyIdIdcArray = new String[]{'00e90000001VZOw','012N00000008jgsIAA','Delivery Charge Condo/Office','Delivery Charge HDB','Delivery Charge Landed','Zero Charge Amount','Airline','Internal','Local','Overseas','012N00000008jCnIAI','Evergreen','Gift','012N00000008jCiIAI','Termed','Subscription','SGD','00e90000001VZOq','012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
                    String[] keyIdTypeArray = new String[]{'Profile','Record','Delivery Charge Type','Delivery Charge Type','Delivery Charge Type','Delivery Charge Type','Name','Name','Name','Name','RecordType','Name','Name','RecordType','Name','Name','Name','Profile','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
                    
                    List<Key_Id__c> keyIDList = new List<Key_Id__c>();
                    for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
                    {
                        keyId = new Key_Id__c();
                        keyId.Name = keyIdNameArray[i];
                        keyId.Id__c = keyIdIdcArray[i];
                        keyId.Type__c = keyIdTypeArray[i];
                        keyIDList.add(keyId);
                    }
                    insert keyIDList;
                    
                    String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print'};
                    String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print'};
                    
                    List<Other__c> OtherList = new List<Other__c>();
                    for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
                    {
                        otherC = new Other__c();
                        otherC.Name = orderCNameArray[i];
                        otherC.Value__c = orderCValueArray[i];
                        OtherList.add(otherC);
                    }
                    insert OtherList;
                    
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
                    testDeliveryChargeType.Name = 'H';
                    testDeliveryChargeType.Default_Delivery_Charge_Type__c = 'H';
                    insert testDeliveryChargeType;      
          }
}