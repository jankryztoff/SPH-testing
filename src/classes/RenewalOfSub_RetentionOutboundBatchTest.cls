/**
 * Class Name: <RenewalOfSub_RetentionOutboundBatchTest>
 * @author: <JhustinPinoy>
 * Date: <10/09/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for RenewalOfSub_RetentionOutboundBatch>
 */

@isTest
public class RenewalOfSub_RetentionOutboundBatchTest {

    @testSetup 
    static void setupData() {
        
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createBatchInterface();
        insert CustomSettingsDataFactory.createBillingBatch();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createDateConfig();
        insert CustomSettingsDataFactory.createUom();
        insert CustomSettingsDataFactory.createUnit_of_Measure();
        insert CustomSettingsDataFactory.createSpecial_Product_Families();
        insert CustomSettingsDataFactory.createRenewal_Notifications();
        insert CustomSettingsDataFactory.createPublic_Holiday_Pub_Indiators();
        insert CustomSettingsDataFactory.createProduct_Frequency();
        insert CustomSettingsDataFactory.createProduct_Code();
        insert CustomSettingsDataFactory.createPostage_Charge();
        
    }


    static testMethod void method01() {

        //create project
        Project__c pro = TestDataFactory.createProject(1)[0];
        pro.Project_Description__c = 'This is a new confidential project.';
        //create vendor subscriber acct
        Account acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acct.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual');
        //create singpost addresscreateAccount
        Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        //create subscription vendor
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_PRE;
        
        //create vendor Account
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert new List<sObject>{pro, acct, singpostAdd, subsVen, pack, venAccount};

        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
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
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '2';
        pItem.Effective_Start_Month__c = '12';
        insert pItem;
        
        //create address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;
        
        //create billing acct
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        billingAcc.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_PRE;
        insert billingAcc;
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acct.Id;
        con.Address__c = add.Id;
        con.Recipient_Indicator__c = true;
        insert con;
        
        //create order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con.Id;
        order.Billing_Account__c = billingAcc.Id;
        order.Informed_Customer__c = True;
        order.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_PRE;
        insert order;
        
        //create case
        Case cas = TestDataFactory.createCase(1, 'Renewal of Subscription')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //create order line item
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Order__c = order.Id;
        oli.Vendor_Subscription_ID__c = subsVen.Id;
        oli.Main_Package_ID__c = pack.Id;
        //oli.Vendor_Mailing_Agent__c = acct.Id;
        oli.Start_Date__c = date.today()+1;
        insert oli;
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 10;
        insert gift;
        
        Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
        pg.Gift__c = gift.Id;
        insert pg;
        
        Order_Line_Item_Gift__c olig = TestDataFactory.createItemGift(1)[0];
        olig.Order_Line_Item__c = oli.Id;
        olig.Promotion_Gift__c = pg.Id;
        insert olig;
        
        //create Zuora Subscriptions
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = acct.Id;
        
        zSub.Order_Line_Item_Number__c = oli.Id;
        zSub.Order_Number__c = order.Id;
        zSub.Order_Number_1__c = order.Id;
        zSub.Subscriber_Contact__c = con.Id;
        zSub.Recipient_Contact__c = con.Id;
        zSub.Renewal_Request_Date__c = Date.Today();
        zSub.Zuora__SubscriptionStartDate__c = oli.Start_Date__c;
        zSub.Zuora__SubscriptionEndDate__c = Date.Today().addDays(42);
        zsub.Subscription_End_Date__c = 'Date.Today().addDays(42)';
        zSub.Suppress_Vendor_Start_Notice__c = 'false';
        zSub.Supressed_Acknowledgement_Letter__c = 'false';
        zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSub.Urgent__c = 'false';
        zSub.Vendor_Conversion__c = 'false';
        zSub.Charity__c = 'false';
        zSub.Zuora__AutoRenew__c = false;
        zsub.Zuora__CustomerAccount__c = billingAcc.Id;
        zsub.RenewalRequestDateNull__c = true;
        zsub.Subscription_Type_1__c = 'Publication';
        zsub.Subscription_Type__c = 'Publication';
        zsub.Grace_Period_Subscription__c = null;
        
        SubscriptionTriggerHandler.preventExecution = true;
        insert zSub;
        
        //create parcel
        Parcel__c par = TestDataFactory.createParcel(1)[0];
        par.Project_Name__c = pro.Id;
        par.Allocation_Type__c = 'SDA';
        par.Description__c = 'Description';
        insert par;
        
        //create vendor allocation
        Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
        venAlloc.SingPost_Address__c = singpostAdd.Id;
        venAlloc.Vendor_Account__c = venAccount.Id;
        venAlloc.Parcel_Name__c = par.Id;
        venAlloc.Allocated__c = true;
        venAlloc.Operated__c = FALSE;
        insert venAlloc;
        
        Set<Id> subRec = new set<Id>();
        subRec.add(zsub.Id);
            
        Test.startTest();
           
        RenewalOfSub_RetentionOutboundBatch batch = new RenewalOfSub_RetentionOutboundBatch(subRec);
        
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        
        RenewalOfSub_RetentionOutboundBatch batch1 = new RenewalOfSub_RetentionOutboundBatch();
        
        ID batchprocessid1 = Database.executeBatch(batch1, 200);
        System.assertNotEquals(null, batchprocessid1);
        
        Test.stopTest();
    }
}