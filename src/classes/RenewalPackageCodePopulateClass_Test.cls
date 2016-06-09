/**
 * Class Name: <RenewalPackageCodePopulateClass_Test>
 * @author: <Joy Suarez>
 * Date: <10/09/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for RenewalPackageCodePopulateClass>
 */

@isTest(seeAllData = TRUE)

private class RenewalPackageCodePopulateClass_Test {
    /**
    *  To test RenewalPackageCodePopulateClass
    *  @name testRenewalPackageCodePopulateClass
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testmethod void testRenewalPackageCodePopulateClass() {
    
        //create project
        Project__c pro = TestDataFactory.createProject(1)[0];
        pro.Project_Description__c = 'This is a new confidential project.';
        //create vendor subscriber acct
        Account acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        //insert acct;
        //create singpost addresscreateAccount
        Id recordTypeAcctDirect = ConstantsSLB.getKeyId('Account_Direct Individual');
        acct.RecordTypeId = recordTypeAcctDirect;
        Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        //create subscription vendor
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        //create vendor Account
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert new List<sObject>{pro, acct, singpostAdd, subsVen, pack, venAccount};

        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Newspaper';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
        prpct.zqu__PriceFormat__c = 'Per Unit';
        prpct.zqu__Currency__c ='SGD';
        insert prpct;
        
        List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1, 'Base Product');
        pItem[0].Package__c = pack.Id;
        pItem[0].Product_Rate_Plan__c = prdRatePlan.Id;
        pItem[0].Duration_in_months__c = '2';
        pItem[0].Effective_Start_Month__c = '12';
        insert pItem;
        
        //create address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;
        
        //create billing acct
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        billingAcc.Billing_Type__c = 'Full Prepaid';
        insert billingAcc;
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acct.Id;
        con.Address__c = add.Id;
        con.Recipient_Indicator__c = TRUE;
        insert con;
        
        //create order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con.Id;
        order.Billing_Account__c = billingAcc.Id;
        order.Informed_Customer__c = True;  
        order.Billing_Type__c = 'Full Prepaid';  
        try
        {
            insert order;      
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        //create case
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //create order line item
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Order__c = order.Id;
        oli.Vendor_Subscription_ID__c = subsVen.Id;
        oli.Main_Package_ID__c = pack.Id;
        insert oli;
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 100;
        insert gift;
        
        Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
        pg.Gift__c = gift.Id;
        
        insert pg;
        
        Order_Line_Item_Gift__c olig = TestDataFactory.createItemGift(1)[0];
        olig.Order_Line_Item__c = oli.Id;
        olig.Promotion_Gift__c = pg.Id;
        insert olig;
        system.assertNotEquals(null, olig);    
        
        //create Zuora Subscriptions
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = acct.Id;
        zSub.Order_Line_Item_Number__c = oli.Id;
        zSub.Order_Number__c = order.Id;
        zSub.Order_Number_1__c = order.Id;
        zSub.Subscriber_Contact__c = con.Id;
        zSub.Recipient_Contact__c = con.Id;
        zSub.Renewal_Request_Date__c = Date.Today();
        zSub.Zuora__SubscriptionStartDate__c = Date.Today();
        Integer configurableNumberOfDays = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubscriptionEndDate'));
        Date sixWeeksBefore = Date.Today().addDays(configurableNumberOfDays);
        zSub.Zuora__SubscriptionEndDate__c = sixWeeksBefore.adddays(1);
        zSub.Suppress_Vendor_Start_Notice__c = 'false';
        zSub.Supressed_Acknowledgement_Letter__c = 'false';
        zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSub.RenewalRequestDateNull__c = TRUE;
        zSub.Urgent__c = 'false';
        zSub.Vendor_Conversion__c = 'false';
        zSub.Charity__c = 'false';
        zSub.Zuora__AutoRenew__c = false;
        Test.startTest();
        try
        {
             insert zSub;
        
            RenewalPackageCodePopulateClass rpcpc = new RenewalPackageCodePopulateClass();
            rpcpc.RenewalPackageCodePopulate(pItem);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
       
        Test.stopTest();
    
    
    }    
    /**
    *  To test RenewalPackageCodePopulateClass
    *  @name testRenewalPackageCodePopulateClass2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testmethod void testRenewalPackageCodePopulateClass2() {
    
        //create project
        Project__c pro = TestDataFactory.createProject(1)[0];
        pro.Project_Description__c = 'This is a new confidential project.';
        //create vendor subscriber acct
        Account acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        //insert acct;
        //create singpost addresscreateAccount
        Id recordTypeAcctDirect = ConstantsSLB.getKeyId('Account_Direct Individual');
        acct.RecordTypeId = recordTypeAcctDirect;
        Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        //create subscription vendor
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        //create vendor Account
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert new List<sObject>{pro, acct, singpostAdd, subsVen, pack, venAccount};

        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Magazine';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
        prpct.zqu__PriceFormat__c = 'Per Unit';
        prpct.zqu__Currency__c ='SGD';
        insert prpct;
        
        List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1, 'Base Product');
        pItem[0].Package__c = pack.Id;
        pItem[0].Product_Rate_Plan__c = prdRatePlan.Id;
        pItem[0].Duration_in_months__c = '2';
        pItem[0].Effective_Start_Month__c = '12';
        insert pItem;
        
        //create address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;
        
        //create billing acct
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        billingAcc.Billing_Type__c = 'Full Prepaid';
        insert billingAcc;
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acct.Id;
        con.Address__c = add.Id;
        con.Recipient_Indicator__c = TRUE;
        insert con;
        
        //create order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con.Id;
        order.Billing_Account__c = billingAcc.Id;
        order.Informed_Customer__c = True;
        order.Billing_Type__c = 'Full Prepaid';  
        try
        {
            insert order;      
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        
        //create case
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //create order line item
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Order__c = order.Id;
        oli.Vendor_Subscription_ID__c = subsVen.Id;
        oli.Main_Package_ID__c = pack.Id;
        insert oli;
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 100;
        insert gift;
        
        Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
        pg.Gift__c = gift.Id;
        
        insert pg;
        
        Order_Line_Item_Gift__c olig = TestDataFactory.createItemGift(1)[0];
        olig.Order_Line_Item__c = oli.Id;
        olig.Promotion_Gift__c = pg.Id;
        insert olig;
        system.assertNotEquals(null, olig);       
        
        //create Zuora Subscriptions
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = acct.Id;
        zSub.Order_Line_Item_Number__c = oli.Id;
        zSub.Order_Number__c = order.Id;
        zSub.Order_Number_1__c = order.Id;
        zSub.Subscriber_Contact__c = con.Id;
        zSub.Recipient_Contact__c = con.Id;
        zSub.Renewal_Request_Date__c = Date.Today();
        zSub.Zuora__SubscriptionStartDate__c = Date.Today();
        Integer configurableNumberOfDays = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubscriptionEndDate'));
        Date sixWeeksBefore = Date.Today().addDays(configurableNumberOfDays);
        zSub.Zuora__SubscriptionEndDate__c = sixWeeksBefore.adddays(1);
        zSub.Suppress_Vendor_Start_Notice__c = 'false';
        zSub.Supressed_Acknowledgement_Letter__c = 'false';
        zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSub.RenewalRequestDateNull__c = TRUE;
        zSub.Urgent__c = 'false';
        zSub.Vendor_Conversion__c = 'false';
        zSub.Charity__c = 'false';
        zSub.Zuora__AutoRenew__c = false;
        Test.startTest();
        try
        {
            insert zSub;
        
            RenewalPackageCodePopulateClass rpcpc = new RenewalPackageCodePopulateClass();
            rpcpc.RenewalPackageCodePopulate(pItem);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        Test.stopTest();
    
    
    }    
}