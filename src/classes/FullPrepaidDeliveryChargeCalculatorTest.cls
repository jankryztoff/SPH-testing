@isTest(seeAllData = true)
public class FullPrepaidDeliveryChargeCalculatorTest {

    static Id orderId;
    static decimal subscriberCharge;
    
    static Account vendorAcct;
    static Singpost_Address__c singPostAddr;
    static Address__c address;
    static Contact contact;
    
    static zqu__ZProduct__c zProduct;
    static zqu__ProductRatePlan__c prodRatePlan;
    static zqu__ProductRatePlanCharge__c prodRatePlanCharge;
    
    static Package__c aPackage;
    static Package_Item__c packageItem;
    static Order__c order;
    static Order_Line_Item__c orderLineItem;
    static Vendor_Allocation__c vendorAlloc; 
    static Zuora__Subscription__c zouraSubscription;
    static Case aCase;
    static Zuora__CustomerAccount__c billingaccount;
    static List<Id> oliId;
    
    
    static void prepareTestData(decimal subscriberChargeParam){
        setUpFirstDataFactory();
        Test.startTest();
        setUpSecondDataFactory();
        subscriberCharge = subscriberChargeParam;
    }
    
     /**
        @name setUpFirstDataFactory
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setUpFirstDataFactory() {
    
        vendorAcct = TestDataFactory.createAccount(1, 'Vendor')[0]; 
        insert vendorAcct;
        
        singPostAddr = TestDataFactory.createSingpostAddress(1)[0];
        singPostAddr.Name = 'SPostal';
        singPostAddr.House_Block_Number__c = 'TEST';
        //singPostAddr.orderRecord_Type__c = 'A';
        insert singPostAddr;        
        
        address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c = 'P';
        address.Postal_Code__c = singPostAddr.Id;
        address.Block_House_Number__c ='TEST';
        address.Level_Number__c ='xx';
        address.Unit_Number__c = 'yy';
        insert address;        
        
        billingaccount = TestDataFactory.createBillingAccount(1)[0];
        billingaccount.Zuora__Account__c = vendorAcct.Id;
        insert billingaccount;
        
        contact = TestDataFactory.createContact(1)[0];
        contact.Address__c = address.Id;
        contact.AccountId = vendorAcct.Id;
        contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contact.Recipient_Indicator__c = true;
        insert contact;        
        
        zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        prodRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prodRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prodRatePlan;
        
        prodRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prodRatePlanCharge.zqu__ProductRatePlan__c = prodRatePlan.Id;
        insert prodRatePlanCharge;        
                       
        aPackage = TestDataFactory.createPackage(1)[0]; 
        aPackage.Name = 'Pack name';
        aPackage.Billing_Type__c = 'Full Prepaid';
        aPackage.Package_Type__c = 'Base';
        aPackage.Subscription_Period__c = '18';
        aPackage.Package_Code__c = 'afds132';
        insert aPackage;        
        
        packageItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem.Package__c = aPackage.Id;
        packageItem.Product_Rate_Plan__c = prodRatePlan.Id;
        insert packageItem;
             
    }
    
    
    /**
        @name setUpSecondDataFactory
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setUpSecondDataFactory() { 
        
        aCase = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        insert aCase;        
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorAcct.Id;
        order.Informed_Customer__c = true;
        order.Recipient_Contact__c = contact.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = true;
        //order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        //order.Billing_Account__c = billAcc.id;
        //order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 0;
        insert order;
        
        orderId = order.id;
        
        System.debug('ASM order.Id = ' + order.Id);
               
        List<String> billingTypeList = new List<String>{'Full Prepaid', 'Recurring Prepaid'};
        oliId = new List<Id>();
        Integer count = 0;
        
        for (String bt : billingTypeList ) {
            
            orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.Id;
            orderLineItem.Case__c = aCase.Id;        
            orderLineItem.Main_Package_ID__c = aPackage.Id;
            orderLineItem.Main_Package_Type__c = 'Base';
            orderLineItem.Main_Package_Billing_Type__c = bt; //NOTE
            orderLineItem.Main_Package_Period__c = 0;
            orderLineItem.Start_Date__c = Date.today().addDays(1); //LIMOT
            orderLineItem.End_Date__c = Date.Today().addDays(2);
            orderLineItem.Term_Length__c = 0;        
            orderLineItem.Earliest_Start_Date__c = Date.today();
            orderLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderLineItem.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderLineItem.Terminating_Reason__c = 'Others';
            orderLineItem.Amount_To_Refund__c = 0;
            orderLineItem.Admin_Charge__c = 0;
            orderLineItem.Fee_Waiver__c = false; //LIMOT
            orderLineItem.Fee_Override__c = true; 
            orderLineItem.Override_Reason__c = 'TEST';
            orderLineItem.Suppress_Notification_Stop__c = true;        
            orderLineItem.Vendor_Mailing_Agent__c = vendorAcct.Id;
            orderLineItem.Postage_Charge__c = 0;
            orderLineItem.Main_Package_Product_Sub_Type__c = 'Newspaper';
            insert orderLineItem;
            
            count++;
            oliId.add(orderLineItem.Id);
            
            System.debug('ASM orderLineItem.Id= ' + orderLineItem.Id + ' count=' + count); 
        }
           
        zouraSubscription = TestDataFactory.createSubscription(1)[0];
        
        zouraSubscription.Zuora__Zuora_Id__c = 'zouraId';
        zouraSubscription.Zuora__CustomerAccount__c = billingaccount.Id;
        zouraSubscription.Zuora__Status__c = 'Active';
        zouraSubscription.Zuora__Account__c = vendorAcct.Id;
        zouraSubscription.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);        
        
        zouraSubscription.Subscriber_Contact__c = contact.Id;
        zouraSubscription.Recipient_Contact__c = contact.Id;       
        
        zouraSubscription.Main_Package_1__c = aPackage.Id;
        zouraSubscription.Order_Number__c = order.Id;
        zouraSubscription.Order_Number_1__c = order.Id;
        zouraSubscription.Order_Line_Item_Number__c = orderLineItem.Id;
        zouraSubscription.Order_Line_Item_Number_1__c = orderLineItem.Id;
        
        zouraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zouraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zouraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zouraSubscription.Urgent__c = 'false';
        
        zouraSubscription.Vendor_Conversion__c = 'false';
        zouraSubscription.Vendor__c = vendorAcct.Id;
        zouraSubscription.Vendor_1__c = vendorAcct.Id;         
        zouraSubscription.Charity__c = 'false';
        
        zouraSubscription.Billing_Type__c = 'Full Prepaid'; //NOTE       
        
        zouraSubscription.Subscription_Type__c = 'Publication';
        zouraSubscription.Subscription_Type_1__c = 'Publication';
        zouraSubscription.Number_of_Copies1__c =  '100';
        zouraSubscription.Number_of_Copies__c = 100;
        zouraSubscription.Qty__c = 20;     
        insert zouraSubscription;        
        
        vendorAlloc = TestDataFactory.createVendorAlloc(1)[0];   
        vendorAlloc.Vendor_Account__c = vendorAcct.Id;
        vendorAlloc.SingPost_Address__c = singPostAddr.Id;
        vendorAlloc.Effective_Start_Date__c = Date.today();
        vendorAlloc.Allocated__c = true;
        insert vendorAlloc; 
    }
    
    

    static testmethod void testZouraListSubIsNullShouldReturnNull() {
        
        List<Zuora__Subscription__c> zouraSubList = FullPrepaidDeliveryChargeCalculator.calculate(null);
        
        System.assertEquals(null, zouraSubList);
    }
    
    static testmethod void testZouraListSubNotNullShouldReturnNotNullAndSizeZero() {
        
        List<Zuora__Subscription__c> zouraSubList = FullPrepaidDeliveryChargeCalculator.calculate(new List<Zuora__Subscription__c>());
        
        System.assertNotEquals(null, zouraSubList);
        System.assertEquals(0, zouraSubList.size());
    }
    
    static testmethod void testOrderMapWithNullId() {
        prepareTestData(0);
        
        Map<string, decimal> orderMap = FullPrepaidDeliveryChargeCalculator.calculate(null, null);
        
        System.assertEquals(0, orderMap.get(GlobalVariableClass.BILLING_TYPE_FULL));
        System.assertEquals(0, orderMap.get(GlobalVariableClass.BILLING_TYPE_RECURRING));
        Test.stopTest(); 
    }
    
    static testmethod void testOrderMapWithValidId() {
        prepareTestData(10);
        
        Map<string, decimal> orderMap = FullPrepaidDeliveryChargeCalculator.calculate(orderId, subscriberCharge);
        
        System.assertEquals(0.0, orderMap.get(GlobalVariableClass.BILLING_TYPE_FULL));
        System.assertEquals(10, orderMap.get(GlobalVariableClass.BILLING_TYPE_RECURRING));
        Test.stopTest(); 
    }

}