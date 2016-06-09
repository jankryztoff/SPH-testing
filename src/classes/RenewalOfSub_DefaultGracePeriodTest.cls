/**
 * Class Name: <RenewalOfSub_DefaultGracePeriodTest>
 * @author: <JhustinPinoy>
 * Date: <10/09/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for RenewalOfSub_DefaultGracePeriod>
 */

@isTest(seeAllData = TRUE)

public class RenewalOfSub_DefaultGracePeriodTest {
/*
    static testmethod void test() {
    
        //create project
        Project__c pro = TestDataFactory.createProject(1)[0];
        pro.Project_Description__c = 'This is a new confidential project.';
        //create vendor subscriber acct
        Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        //create singpost addresscreateAccount
        Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        //create subscription vendor
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        //create vendor Account
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount};

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
        insert pItem;
        
        //create address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;
        
        //create billing acct
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
        insert billingAcc;
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = vendorSubsAcct.Id;
        con.Address__c = add.Id;
        insert con;
        
        //create order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorSubsAcct.Id;
        order.Recipient_Contact__c = con.Id;
        order.Billing_Account__c = billingAcc.Id;
        order.Informed_Customer__c = True;
        insert order;
        
        //create case
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //create order line item
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Order__c = order.Id;
        oli.Vendor_Subscription_ID__c = subsVen.Id;
        oli.Main_Package_ID__c = pack.Id;
        oli.Vendor_Mailing_Agent__c = vendorSubsAcct.Id;
        insert oli;
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
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
        zSub.Zuora__Account__c = vendorSubsAcct.Id;
        zSub.Order_Line_Item_Number__c = oli.Id;
        zSub.Order_Number__c = order.Id;
        zSub.Zuora__SubscriptionEndDate__c = Date.Today().addDays(42);
        zSub.Billing_Type__c = 'Full Prepaid';
        zSub.Zuora__TermSettingType__c = 'TERMED';
        zSub.Suppress_Grace_Allocation__c = false;
        zSub.Suppress_Vendor_Start_Notice__c = 'false';
        zSub.Supressed_Acknowledgement_Letter__c = 'false';
        zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSub.Urgent__c = 'false';
        zSub.Vendor_Conversion__c = 'false';
        zSub.Charity__c = 'false';
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
        insert venAlloc;
        
        
        
       Test.startTest();
       RenewalOfSub_DefaultGracePeriod batch = new RenewalOfSub_DefaultGracePeriod();
       ID batchprocessid = Database.executeBatch(batch, 200);
       Test.stopTest();
    }
*/
}