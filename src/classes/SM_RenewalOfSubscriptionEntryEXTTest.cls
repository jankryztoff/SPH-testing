/**
 * Class Name: SM_RenewalOfSubscriptionEntryTest2
 * @author: Leuwend Job Hapa
 * Date: 01/26/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Third Test Class for SM_RenewalOfSubscriptionEntryController
 *
 */
@isTest ( seeAllData = true )
public class SM_RenewalOfSubscriptionEntryEXTTest {

    // Test Data
    static Account acc;
    static Singpost_Address__c postal;
    static Address__c address;
    static List<Contact> con;
    static List<Package__c> pkg;
    static List<Order__c> orderRec;
    static Case testCase;
    static List<Zuora__CustomerAccount__c> zcaList;
    static List<Zuora__Subscription__c> zSubs;
    static Zuora__Refund__c refund;
    static List<Zuora__PaymentMethod__c> zpmList;
    static List<Zuora__Subscription__c> testSubscription;
    static PageReference pageRef;
    static String accId;
    static String conId;
    static String recConId;
    static Package__c packageObject;
    static List<Promotion__c> promotion;
    static Gift__c gift;
    static Promotion_Gift__c pg;
    static List<zqu__ZProduct__c> zProduct;
    static List<Package_Item__c> pItems;
    static List<Product_Family__c> productFamily;
    static List<zqu__ProductRatePlan__c> prdRatePlans;
    static List<Order_Line_Item__c> oli;
    static Order_Line_Item__c tempOLI;
    static Asia1__c tmpAsia1;
        
    /**
    * @name: prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/20/2015
    */ 
    static void prepareTestData(String caseSub, String productType, String subPeriod, String packageType){
            defaultCustomSetting();
            pageRef = Page.SM_RenewalOfSubscriptionEntry;
            
            testSubscription = [ SELECT Id, Main_Package_1__c, Zuora__Account__c, Main_Package__c,
                                Zuora__CustomerAccount__r.Billing_Type__c, Zuora__CustomerAccount__c, Billing_Type__c,
                                Zuora__CustomerAccount__r.Zuora__Account__c, Contact__c, Contact__r.AccountId,
                                Recipient_Contact__c, Vendor_1__c, Zuora__SubscriptionEndDate__c
                                FROM Zuora__Subscription__c
                                WHERE Zuora__Account__c != NULL
                                AND Zuora__Status__c = 'Active'
                                AND Subscription_Type_1__c != 'Delivery'
                                AND Main_Package_1__c != ''
                                AND Billing_Type__c = 'Recurring Prepaid'
                                AND Main_Package_1__r.Package_Type__c = :packageType
                                LIMIT 1];
            
            if(testSubscription.size() == 0) {
                acc = new Account();
                acc.Name = 'Test Account';
                acc.RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber');
                insert acc;
                accId = acc.Id;
            
                postal = new Singpost_Address__c();
                postal = TestDataFactory.createSingpostAddress(1)[0];
                insert postal;
            
                address = new Address__c();
                address = TestDataFactory.createAddress(1)[0];
                address.Postal_Code__c = postal.Id;
                insert address;
            
                con = TestDataFactory.createContact(2);
                con[0].Phone = '1234567';
                con[0].LastName ='Dumangas';
                con[0].FirstName = 'Ana';
                con[0].AccountId = acc.Id;
                con[1].Phone = '1234567';
                con[1].AccountId = acc.Id;
                con[1].Recipient_Indicator__c = true;
                con[1].LastName ='Dumangas';
                con[1].FirstName = 'Ana';
                insert con;
                
                conId = con[0].Id;
                recConId = con[1].Id;
                   
                pkg = TestDataFactory.createPackage(1);
                pkg[0].Subscription_Period__c = '15'; 
                pkg[0].Package_Type__c = packageType;
                pkg[0].Billing_Type__c = 'Recurring Prepaid';
                insert pkg;    
            
                zcaList = TestDataFactory.createBillingAccount(1);
                zcaList[0].Name = 'Zuora Customer Account';
                zcaList[0].Zuora__Account__c = acc.Id;
                zcaList[0].Zuora__Credit_Balance__c = 1;
                zcaList[0].Refund_Amount__c = 100;
                zcaList[0].Zuora__AutoPay__c =false;
                zcaList[0].Zuora__Balance__c = 1;
                zcaList[0].Payment_Mode__c = 'Cash';
                zcaList[0].Other_PaymentMethod__c= 'Cash';
                zcaList[0].Zuora__PaymentMethodType__c = 'Cash'; 
                zcalist[0].Zuora__External_Id__c = '22544AA';  
                zcalist[0].Zuora__Zuora_Id__c = '0124';  
                zcalist[0].Billing_Type__c = 'Recurring Prepaid';
                insert zcaList;
            
                //START : D-1929 3/2/2015 added to create Default Payment Method
                zpmList = TestDataFactory.createPaymentMethod(1);
                zpmList[0].Name = 'Zuora Customer Account';
                zpmList[0].Zuora__Type__c = 'Cash';
                zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
                insert zpmList;  
                //End: D-1929 3/2/2015 added to create Default Payment Method
            
                zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
                update zcaList;
            
                //create billing account      
                testSubscription =  TestDataFactory.createSubscription(1);
                testSubscription[0].Subscriber_Contact__c = con[0].id;
                testSubscription[0].Main_Package__c = pkg[0].id;
                testSubscription[0].Zuora__Account__c = acc.id;
                testSubscription[0].Order_Number__c = null;
                testSubscription[0].Zuora__CustomerAccount__c = zcaList[0].Id;
                testSubscription[0].Billing_Type__c = 'Recurring Prepaid';
                testSubscription[0].Legacy_Create_Date__c = 'a';
                testSubscription[0].Legacy_Create_By__c = 'a';
                testSubscription[0].Legacy_Update_By__c = 'a';
                testSubscription[0].Legacy_Subscription_ID__c = 'a';
                testSubscription[0].Legacy_Update_Date__c = 'a';
                testSubscription[0].Number_of_Copies__c = 100;
                testSubscription[0].Number_of_Copies1__c = '100';
                testSubscription[0].Zuora__Status__c = 'Active';
                testSubscription[0].Subscription_Type_1__c = 'Publication';
                testSubscription[0].Subscription_Type__c = 'Publication';
                testSubscription[0].Contact__c = con[0].id;
                testSubscription[0].Delivery_Charge_Type__c = 'H';
                testSubscription[0].Recipient_Contact__c = recConId;
                testSubscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(20);
                testSubscription[0].Zuora__Version__c = 1;
                insert testSubscription;
            }
                                
            System.assertEquals(1, testSubscription.size());
            
            testCase = new Case();
            testCase.AccountId = testSubscription[0].Zuora__Account__c;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Status = 'New';
            testCase.Payment_Mode__c = 'Cash';
            testCase.Amount_To_Refund__c = 100;
            testCase.Action_Type__c = 'Amend';    
            testCase.RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.CASERETENTION);
            if(caseSub != null){
                testCase.Subscription_Name__c = testSubscription[0].Id;
            }
           
            insert testCase;
            
            packageObject = [SELECT Id, Package_Type__c FROM Package__c WHERE
                                    Id = :testSubscription[0].Main_Package_1__c OR
                                    Id =: testSubscription[0].Main_Package__c];
            
            packageObject.Subscription_Period__c = subPeriod;
            update packageObject;
            
            Zuora__CustomerAccount__c billingAccount = [SELECT Id, Zuora__Account__c, Billing_Type__c
                                                        FROM Zuora__CustomerAccount__c
                                                        WHERE Id = :testSubscription[0].Zuora__CustomerAccount__c];
            accId = billingAccount.Zuora__Account__c;
            conId = testSubscription[0].Contact__c;
            recConId = testSubscription[0].Recipient_Contact__c;
            
            if(zcaList == null  || zcaList.isEmpty()){
                zcaList = new List<Zuora__CustomerAccount__c>();
                zcaList.add(billingAccount);
            }
            zProduct = [SELECT Id FROM zqu__ZProduct__c WHERE ProductSubType__c = :productType];
        
            If(zProduct.size() == 0) {
                //Create zProduct
                zProduct = TestDataFactory.createZProduct(1);
                zProduct[0].ProductSubType__c = productType;
                zProduct[0].ProductPlatform__c = 'Print';
                zProduct[0].name='BORJ';
                zProduct[0].zqu__SKU__c = 'TESTES121';
                zProduct[0].ProductCode__c = 'QWERTY';
                zProduct[0].ProductFamily__c = 'asdasd';
                insert zProduct;
            }
        
            prdRatePlans = [Select Id FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__c =: zProduct[0].Id LIMIT 1];
        
            if(prdRatePlans.size() == 0) {
                //Create Product Rate Plan
                prdRatePlans = TestDataFactory.createProductRatePlan(1);
                prdRatePlans[0].zqu__ZProduct__c = zProduct[0].Id;
                prdRatePlans[0].BillingType__c = 'Recurring Prepaid';//CLin 25April2016
                insert prdRatePlans;
            }
            
            List<zqu__ProductRatePlan__c> discountRatePlan = [SELECT Id FROM zqu__ProductRatePlan__c WHERE RatePlanType__c = 'Discount' AND zqu__ZProduct__c =: zProduct[0].Id LIMIT 1];
            
            if(discountRatePlan.size() == 0) {
                discountRatePlan = TestDataFactory.createProductRatePlan(1);
                discountRatePlan[0].zqu__ZProduct__c = zProduct[0].Id;
                discountRatePlan[0].RatePlanType__c = 'Discount';
                insert discountRatePlan;
            }
            prdRatePlans.addAll(discountRatePlan);
            
            prdRatePlans[0].BillingPeriod__c = packageObject.Subscription_Period__c;
            prdRatePlans[1].BillingPeriod__c = packageObject.Subscription_Period__c;
            
            update prdRatePlans;
        
        List<Package_Item__c> toDeleteItem = [SELECT Id FROM Package_Item__c WHERE Package__c = :packageObject.id];
        
        if(toDeleteItem.size() > 0) {
            delete toDeleteItem;
        }
        
        productFamily = new List<Product_Family__c>();
        productFamily.add(new Product_Family__c());
        productFamily[0].Product_Family__c = 'UNID0001';
        productFamily[0].Product_Family_Name__c = 'Name 001';
        
        productFamily.add(new Product_Family__c());
        productFamily[1].Product_Family__c = 'UNID0002';
        productFamily[1].Product_Family_Name__c = 'Name 002';
        
        insert productFamily;
        
        String packageItemType = packageType + ' Product';
        if(packageType == 'Add on') {
            packageItemType = 'Base Product';
        }
        
        pItems = [SELECT Id FROM Package_Item__c WHERE Package__c = : packageObject.Id AND RecordType.Name = 'Base Product' LIMIT 1];
        
        if(pItems.size() == 0) {
            //Create Package Item
            pItems = TestDataFactory.createPackageItem(1, packageItemType);
            pItems[0].Package__c = packageObject.Id;
            pItems[0].Duration_in_months__c = '1';
            pItems[0].Effective_Start_Month__c = '1';
            pItems[0].Product_Rate_Plan__c = prdRatePlans[0].Id;
            //insert pItems; //CLin 25April2016
        }
        pItems[0].Product_Family__c = productFamily[0].Id;
        
        if(packageType == 'Add on') {
            List<Package_Item__c> discountPackItems = [SELECT Id FROM Package_Item__c WHERE Package__c = : packageObject.Id AND RecordType.Name = 'Discount' LIMIT 1];
        
            if(discountPackItems.size() == 0) {
                discountPackItems = TestDataFactory.createPackageItem(1, 'Discount');
                discountPackItems[0].Package__c = packageObject.Id;
                discountPackItems[0].Duration_in_months__c = '1';
                discountPackItems[0].Effective_Start_Month__c = '1';
                discountPackItems[0].Product_Rate_Plan__c = prdRatePlans[1].Id;
                insert discountPackItems;
            }
            discountPackItems[0].Product_Family__c = productFamily[1].Id;
            pItems.addAll(discountPackItems);
        }
        
        //update pItems; //CLin 25April2016
        
        if('Bundle' == packageType){
            Package_Item__c currentPackageItems = TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];
            currentPackageItems.Package__c = packageObject.id;
            currentPackageItems.Duration_in_months__c = '2';
            currentPackageItems.Product_Rate_Plan__c = prdRatePlans[1].id;
            insert currentPackageItems;
        }
        
        promotion = TestDataFactory.createPromotion(1);
        promotion[0].Contract_Period__c = '2';
        promotion[0].Effective_Start_Date__c = date.Today();
        promotion[0].Effective_End_Date__c = date.Today()+7;
        promotion[0].Promotion_Code__c = '10054';
        insert promotion;
        
        orderRec = [SELECT Id, Recipient_Contact__c, Recipient_Contact__r.Phone, Recipient_Contact__r.HomePhone__c, Recipient_Contact__r.Mobile_Number__c,
                    Billing_Account__c, Account__c, Informed_Customer__c, Subscriber_Charge__c, Recipient_Contact__r.Address__r.Address_Type__c
                    FROM Order__c WHERE Account__c =:accId AND Recipient_Contact__c = :recConId];
              
        if(orderRec.size() == 0) {
            orderRec = TestDataFactory.createOrder(1);
            orderRec[0].Account__c = accId;
            orderRec[0].Informed_Customer__c = TRUE;
            orderRec[0].Recipient_Contact__c = recConId;
            orderRec[0].Subscriber_Charge__c = 15;
            orderRec[0].Billing_Account__c = testSubscription[0].Zuora__CustomerAccount__c;
            orderRec[0].Billing_Type__c = testSubscription[0].Zuora__CustomerAccount__r.Billing_Type__c;
            insert orderRec;
        }
        oli = [SELECT Id FROM Order_Line_Item__c WHERE Main_Package_ID__c =:packageObject.id AND Order__c = :orderRec[0].id];
        
        if(oli.size() == 0) {
            oli = TestDataFactory.createOrderLineItem(1);
            oli[0].Earliest_Start_Date__c = testSubscription[0].Zuora__SubscriptionEndDate__c;
            oli[0].Start_Date__c =  testSubscription[0].Zuora__SubscriptionEndDate__c;
            oli[0].End_Date__c = testSubscription[0].Zuora__SubscriptionEndDate__c;
            oli[0].Fee_Waiver__c = TRUE;
            oli[0].Order__c = orderRec[0].id;
            oli[0].Main_Package_ID__c = packageObject.id;
            oli[0].Main_Package_Period__c = 1;
            oli[0].Qty__c = 1;
            oli[0].Term_Length__c = 1;
            oli[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
            oli[0].Main_Package_Type__c = 'Base';
            oli[0].Main_Package_Frequency__c = 'Default';
            oli[0].Delivered_By__c = 'None';
            //oli[0].Addon_Package__c = packageObject.id;
            oli[0].Promotion_ID__c = promotion[0].id;
            oli[0].Term_is_discussed__c = TRUE;
            oli[0].Is_Digital__c = TRUE;
            oli[0].Delivered_By__c = 'Mailing Agent';
            oli[0].New_Contract_Period__c = 1;
            insert oli;
        }
        
        tempOLI = new Order_Line_Item__c();
        tempOLI = oli[0];
        
        gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.Gift_Code__c  = '1233333';
        gift.One_Time_Charge__c = 100;
        insert gift;
        
        pg =  new Promotion_Gift__c(
        Gift_Inventory__c = 1000,
        Gift_Issued__c = 200,
        Gift_Redeemed__c = 0,
        Gift__c = gift.id,
        Redemption_Start_Date__c = date.Today()+4,
        Redemption_End_Date__c = date.Today()+7,
        Promotion__c = promotion[0].id);
        insert pg;
        
        List<zqu__Quote__c> zqQ = TestDataFactory.createQuote(1);
        zqQ[0].Vendor_Credit__c = 0;
        zqQ[0].zqu__Account__c = accId;
        zqQ[0].Payment_Mode__c = 'Test';
        zqQ[0].Delivery_Charge_Type__c = 'S';
        zqQ[0].Subscriber_Charge__c = 0;
        zqQ[0].Other_PaymentMethod__c = 'Recurring Prepaid';
        zqQ[0].zqu__BillToContact__c = conId;
        zqQ[0].Main_Package__c = packageObject.id;
        zqQ[0].Order__c = orderRec[0].Id;
        zqQ[0].Order_Line_Item_Number__c = oli[0].Id;
        zqQ[0].Order_Line_Item_Number_1__c = oli[0].Id;
        zqQ[0].Subscription_Type__c = 'Delivery';
        zqQ[0].Delivery_Charge_Type__c = 'S';
        insert zqQ;
            
        Order_Line_Item_Gift__c olig = new Order_Line_Item_Gift__c(
        Order_Line_Item__c = oli[0].id,
        Promotion_Gift__c = pg.id);
        insert olig;
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = packageObject.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        //insert PAF; //CLin 25April2016
        
        //create Asia1__c
        tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = conId;
        insert tmpAsia1;
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = testSubscription[0].Id;
        asiaSubList[0].Status__c = 'Enabled';
        asiaSubList[0].Order_Line_Item__c = oli[0].Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        insert asiaSublist;
        
    }
    
    /**
    * @name: testSaveNoPaymentMethod
    * @author : Recuerdo Bregente
    * @description : Tests Save method with no Payment Method
    * @date: 07/20/2015
    */
    static testMethod void testSaveNoPaymentMethod(){
        prepareTestData('', 'Newspaper', '12', 'Base');
        
        try{
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            
            controller.billingAccountOption = 'createNew';
            //controller.thisOrder.Payment_Mode__c = 'Credit Card'; //CLin 25April2016
            controller.thisOrder.Payment_Method_ID__c = null;
            PageReference saveRef = controller.save();
            
            System.assertEquals(null, saveRef);
            //CLin 25April2016
            Test.stopTest();
        } catch(Zuora.zRemoteException e) {
                System.assertNotEquals(null, e);
        }

    }
    
    /**
    * @name: testSaveWithPaymentMethodOtherAndInvoice
    * @author : Recuerdo Bregente
    * @description : Tests Save method with Payment Method is Other and invoice
    * @date: 07/20/2015
    */
    static testMethod void testSaveWithPaymentMethodOtherAndInvoice(){
        prepareTestData('', 'Newspaper', '12', 'Base');
        
        try{
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            
            controller.billingAccountOption = 'createNew';
            controller.thisOrder.Payment_Mode__c = 'Other';
            controller.thisOrder.Other_Payment_Mode__c = 'Invoice';
            controller.thisOrder.Create_ARMS_Customer_Account__c = false;
            controller.searchCustTick = false;
            controller.selectedSubscriptionId = ' ';
            PageReference saveRef = controller.save();
            
            System.assertEquals(null, saveRef);
            //CLin 25April2016
            
            Test.stopTest();
        } catch(Zuora.zRemoteException e) {
                System.assertNotEquals(null, e);
        }

    }
    
    /**
    * @name: testSaveWithArmsAccountError
    * @author : Recuerdo Bregente
    * @description : Tests Save method with Arms Account Error
    * @date: 07/20/2015
    */
    static testMethod void testSaveWithArmsAccountError(){
        prepareTestData('', 'Newspaper', '12', 'Base');
        
        try{
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            
            controller.billingAccountOption = 'createNew';
            controller.thisOrder.Payment_Mode__c = 'Other';
            controller.thisOrder.Other_Payment_Mode__c = 'Invoice';
            controller.thisOrder.Create_ARMS_Customer_Account__c = false;
            controller.searchCustTick = true;
            controller.searchAcctTick = false;
            controller.accNum = 'ACCNO0001';
            controller.accTextName = 'Account Text Name';
            PageReference saveRef = controller.save();
            
            System.assertEquals(null, saveRef);
            //CLin 25April2016  
            
            Test.stopTest();
        } catch(Zuora.zRemoteException e) {
                System.assertNotEquals(null, e);
        }

    }
    
    /**
    * @name: testSaveWithErrorOnOrderLineItem
    * @author : Recuerdo Bregente
    * @description : Tests Save method with error on OrderLineItem
    * @date: 07/20/2015
    */
    static testMethod void testSaveWithErrorOnOrderLineItem(){
        prepareTestData('', 'Newspaper', '12', 'Base');
        
        try{
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            controller.orderLineItem.Term_Length__c = 0;
            controller.orderLineItem.Main_Package_Sub_Type__c = 'Termed';
            controller.orderLineItem.New_Contract_Period__c = 0;
            controller.orderLineItem.Term_is_discussed__c = false;
            controller.orderLineItem.Qty__c = 0;
            controller.orderLineItem.Delivered_By__c = 'Vendor';
            controller.orderLineItem.Start_Date__c = null;
            controller.recipientAddressRecordTypeName = ConstantsSLB.getOther('Contact_Recordtype_Overseas');
            PageReference saveRef = controller.save();
            
            
            System.assertEquals(null, saveRef);
            
            controller.recipientAddressRecordTypeName = ConstantsSLB.getOther('Contact_Recordtype_Airline');
            saveRef = controller.save();
            System.assertEquals(null, saveRef);
            
            controller.recipientAddressRecordTypeName = ConstantsSLB.getOther('Contact_Recordtype_Internal');
            saveRef = controller.save();
            System.assertEquals(null, saveRef);
            
            //CLin 25April2016
           
            
            Test.stopTest();
        } catch(Zuora.zRemoteException e) {
                System.assertNotEquals(null, e);
        } catch(System.QueryException e) {
                System.assertNotEquals(null, e);
        }

    }
    
    /**
    * @name: testSaveWithARMSExistingInvoiceError
    * @author : Recuerdo Bregente
    * @description : Tests Save method with ARMS Existing Invoice error
    * @date: 07/20/2015
    */
    static testMethod void testSaveWithARMSExistingInvoiceError(){
        prepareTestData('', 'Newspaper', '12', 'Base');
        
        try{
            //CLin 25April2016
            Test.startTest();
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            controller.getBillAccName();
            controller.thisOrder.Payment_Mode__c = ConstantsSLB.getOther('Other');
            controller.thisOrder.Other_Payment_Mode__c = ConstantsSLB.getOther('Invoice');
            PageReference saveRef = controller.save();
            
            System.assertEquals(null, saveRef);
            //CLin 25April2016
            
            Test.stopTest();
        } catch(Zuora.zRemoteException e) {
                System.assertNotEquals(null, e);
        }

    }
    
    /**
    * @name: testSaveWithBillingAccountIsNull
    * @author : Recuerdo Bregente
    * @description : Tests Save method with Billing Account is null
    * @date: 07/20/2015
    */
    static testMethod void testSaveWithBillingAccountIsNull(){
        prepareTestData('', 'Newspaper', '12', 'Base');
        
        try{
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            controller.thisOrder.Billing_Account__c = null;
            PageReference saveRef = controller.save();
            
            System.assertEquals(null, saveRef);
            //CLin 25April2016
            
            Test.stopTest();
        } catch(Zuora.zRemoteException e) {
                System.assertNotEquals(null, e);
        }

    }
    
    /**
    * @name: testSave
    * @author : Recuerdo Bregente
    * @description : Tests Save method
    * @date: 07/21/2015
    */
    static testMethod void testSave(){
        prepareTestData('', 'Newspaper', '12', 'Base');
        try{
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
            
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            controller.orderLineItem.Qty__c = 2; //CLin 25April2016
            
            List<Order_Line_Item__c> checkOLI = [SELECT Id FROM Order_Line_Item__c WHERE Id = :controller.orderLineItem.Id]; //CLin 25April2016

            if(checkOLI.size() == 0) {
                insert controller.orderLineItem;
            }
            else {
                update controller.orderLineItem;
            } //CLin 25April2016
          
            
            PageReference saveRef = controller.save(); //CLin 25April2016
            
            System.assertEquals(null, saveRef); //CLin 25April2016
            Test.stopTest();
            
            controller.thisOrder.Delivery_Charge_Type__c = 'Z';
            controller.selectedDeliveryChargeType = 'H';
            controller.calculateCharges2();
            controller.selectedDeliveryChargeType = '9';
            controller.orderLineItem.Delivered_By__c = 'No Method';
            controller.calculateCharges2();//CLin 25April2016
        } catch(Zuora.zRemoteException e) {
                System.assertNotEquals(null, e);
        }

    }
    
    /**
    * @name: testSaveNoError
    * @author : Recuerdo Bregente
    * @description : Tests Save method with no error
    * @date: 07/21/2015
    */
    static testMethod void testSaveNoError(){
        prepareTestData('', 'Newspaper', '12', 'Base');
        List<Case> casListperSub = [SELECT AccountId,CaseNumber,Status,Subject 
                                            FROM Case 
                                                WHERE Status != 'New' AND Id != :testCase.Id AND Subscription_Name__c =: testSubscription[0].Id];
        if(!casListperSub.isEmpty()) {
           delete casListperSub;
        }
        
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            controller.thisOrder = orderRec[0];
            controller.thisOrder.Billing_Account__c = testSubscription[0].Zuora__CustomerAccount__c;

            testCase.Status = 'New';
            update testCase;
            //PageReference saveRef = controller.save(); //CLin 25April2016
            
            Test.stopTest();
            
            controller.asia1SelectedExistingId = String.valueOf(tmpAsia1.id);
            controller.addAsia1NewAccount();
            
            controller.asia1SingleAccount.Password__c = 'DeeMiko04';
            controller.thisOrder.Recipient_Contact__r.Phone = '+639324861074';
            controller.addAsia1NewAccount();
            
            controller.thisOrder.Recipient_Contact__r.Phone = null;
            controller.thisOrder.Recipient_Contact__r.HomePhone__c = null;
            controller.thisOrder.Recipient_Contact__r.Mobile_Number__c = '+639324861074';
            controller.addAsia1NewAccount();
            //selectedPackageId
            controller.selectedPackageId = packageObject.id;
            controller.addAsia1ExistingAccount();
            
            
            controller.asia1SingleAccount = tmpAsia1;
            controller.validateNewAsia1Account();
            
            
            controller.getAsia1ExistingAccounts();
            
            controller.asia1IdToBeRemoved = controller.asia1Subscriptions.get(0).asia1Id;
            controller.removeAsia1Subscription();
            
            controller.getDeliveryChargeTypes();
            controller.getBillingAccountOptions();
            controller.fetchBillingAccount();
            controller.getSource();        
            
            controller.clearPaymentMethod();
            controller.clearOtherPaymentMethod();
            //CLin 25April2016
            //System.assertEquals(null, saveRef); //CLin 25April2016

    }
    
    
    
    /**
    * @name: testSaveWithDebtManagementIsSUBL
    * @author : Recuerdo Bregente
    * @description : Tests Save method with order debt management value is 'SUBL'
    * @date: 07/21/2015
    */
    static testMethod void testSaveWithDebtManagementIsSUBL(){
            prepareTestData('', 'Newspaper', '12', 'Base');
            List<Case> casListperSub = [SELECT AccountId,CaseNumber,Status,Subject 
                                                FROM Case 
                                                    WHERE Status != 'New' AND Id != :testCase.Id AND Subscription_Name__c =: testSubscription[0].Id];
            if(!casListperSub.isEmpty()) {
               delete casListperSub;
            }
            //CLin 25April2016
            Test.startTest();
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            controller.thisOrder = orderRec[0];
            controller.thisOrder.Billing_Account__c = testSubscription[0].Zuora__CustomerAccount__c;
            controller.thisOrder.Debt_Management_Treatment__c = 'SUBL';
            testCase.Status = 'New';
            update testCase;
            PageReference saveRef = controller.save();
            
            Test.stopTest();
            
            controller.selectedDeliveryChargeType = 'N';
            controller.thisOrder.Delivery_Charge_Type__c = 'Z';
            controller.orderLineItem.Main_Package_Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
            controller.orderLineItem.Term_Length__c = 1;
            controller.thisOrder.Subscriber_Charge__c = 15;
            controller.orderLineItem.Charity__c = true;
            insert controller.orderLineItem;
            controller.calculateCharges2();
            controller.selectedDeliveryChargeType = 'S';
            controller.orderLineItem.Delivered_By__c = GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT;
            controller.calculateCharges2();
            
            System.assertEquals(null, saveRef);
            //CLin 25April2016
    }
    
    /**
    * @name: testSaveWithDebtManagementIsSUBH
    * @author : Recuerdo Bregente
    * @description : Tests Save method with order debt management treatment is SUBH
    * @date: 07/21/2015
    */
    static testMethod void testSaveWithDebtManagementIsSUBH(){
        prepareTestData('', 'Newspaper', '12', 'Base');
            List<Case> casListperSub = [SELECT AccountId,CaseNumber,Status,Subject 
                                                FROM Case 
                                                    WHERE Status != 'New' AND Id != :testCase.Id AND Subscription_Name__c =: testSubscription[0].Id];
            if(!casListperSub.isEmpty()) {
               delete casListperSub;
            }
        
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            controller.thisOrder = orderRec[0];
            controller.thisOrder.Billing_Account__c = testSubscription[0].Zuora__CustomerAccount__c;
            controller.thisOrder.Debt_Management_Treatment__c = 'SUBH';
            testCase.Status = 'New';
            update testCase;
            PageReference saveRef = controller.save();
            //CLin 25April2016
            Test.stopTest();

    }
    
    /**
    * @name: testSaveWithDebtManagementIsGOVT
    * @author : Recuerdo Bregente
    * @description : Tests Save method with order debt management treatment is GOVT
    * @date: 07/21/2015
    */
    static testMethod void testSaveWithDebtManagementIsGOVT(){
            prepareTestData('', 'Newspaper', '12', 'Base');
            List<Case> casListperSub = [SELECT AccountId,CaseNumber,Status,Subject 
                                                FROM Case 
                                                    WHERE Status != 'New' AND Id != :testCase.Id AND Subscription_Name__c =: testSubscription[0].Id];
            if(!casListperSub.isEmpty()) {
               delete casListperSub;
            }
        
            Test.startTest();
            //CLin 25April2016
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'caseId', testCase.Id );
        
            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.checkAndCreateOrder();
            controller.retrieveActiveSubscriptions();
            
            controller.thisOrder = orderRec[0];
            controller.thisOrder.Billing_Account__c = testSubscription[0].Zuora__CustomerAccount__c;
            controller.thisOrder.Debt_Management_Treatment__c = 'GOVT';
            testCase.Status = 'New';
            update testCase;
            PageReference saveRef = controller.save();
            //CLin 25April2016
            
            Test.stopTest();

    }
    
     /**
    * @name: defaultCustomSetting
    * @author : Recuerdo Bregente
    * @description : Prepares custom settings.
    * @date: 07/27/2015
    */
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        List<Key_Id__c> keyList = [SELECT Name FROM Key_Id__c];
        Set<String> keyNames = new Set<String>();
        for(Key_Id__c keyRec : keyList) {
            keyNames.add(keyRec.Name);
        }
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            if(!keyNames.contains(keyIdNameArray[i])) {
                keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
                insert keyId;
            }
        }
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = [SELECT Name FROM Other__c];
        Set<String> otherNames = new Set<String>();
        for(Other__c otherRec : otherList) {
            otherNames.add(otherRec.Name);
        }
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            if(!otherNames.contains(orderCNameArray[i])) {
                otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
                insert otherC;
            }
        }
        
        List<Cir_Planner_Schedule__c> cpcList = [SELECT Name FROM Cir_Planner_Schedule__c WHERE Name = 'CIR Plan Schedule'];
        if(cpcList.isEmpty()) {
            Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        }
        
        List<BatchInterface_Settings__c> bitList = [SELECT Name FROM BatchInterface_Settings__c WHERE Name = 'Endpoint Delegator'];
        if(bitList.isEmpty()) {
            BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
            batchInterfaceSetting.Name = 'Endpoint Delegator';
            batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
            insert batchInterfaceSetting;
        }
        
        String[] errorCNameArray = new String[]{'ARMS account too many record','ARMS account is not existing','ARMS Timed-out','ARMS select one Customer only','Invalid Response'};
        String[] errorCValueArray = new String[]{'Too many account type.','ARMS account is not existing.','Timed-out. Please click Search button again.','Please select one Customer only.','Invalid response from server. Please try again later.'};
        
        List<Error_Messages__c> errorList = [SELECT Name FROM Error_Messages__c];
        Set<String> errorNames = new Set<String>();
        for(Error_Messages__c errorRec : errorList) {
            errorNames.add(errorRec.Name);
        }
        
        Error_Messages__c errorRec;
        for(Integer i = 0 ; i < errorCNameArray.size(); i++ )
        {
             if(!errorNames.contains(errorCNameArray[i])) {
                errorRec = new Error_Messages__c();
                errorRec.Name = errorCNameArray[i];
                errorRec.Message__c = errorCValueArray[i];
                insert errorRec;
            }
        }
    }
}