@isTest(SeeAllData = True)
public class SM_RenOfSubDetControllerTest {

    public static testMethod void testSubmit(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        vendorSubsAcct.AccountNumber = '12345';
        
        Contact con = TestDataFactory.createContact(1)[0];
        insert con;
                
        Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];
        zsub.Order_Number__c = null;
        zsub.Zuora__Account__c = acc.Id;
        zsub.Billing_Type__c = 'Full Prepaid';
        try
        {
            insert zsub; 
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }

        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.id;
        ord.Status__c = 'Pending';
        ord.Order_Type__c = 'Renewal';
        ord.Base_Subscription__c = zsub.id;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert new List<sObject>{ord, zProduct};
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Free';
        insert gift;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Bundled';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Subscription_Period__c = '18';
        insert pack;
       
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;       
                insert new List<sObject>{pg};    
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Is_Digital__c = true;
        oli.Order__c = ord.id;
        oli.Main_Package_ID__c = pack.id;
        oli.DTL_Date__c = date.today();
        try
        {
            insert oli;
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
               
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.Display_Name__c = 'Asia-1';
        asia.User_ID_LDAP_ID__c = 'test1@sample.com';
        asia.Password__c = 'password';
        insert asia;
        
        Asia1_Subscription__c as1 = TestDataFactory.createAsiaOneSubscription(1)[0];
        as1.Order_Line_Item__c = oli.id;
        as1.Asia1__c = asia.id;
        insert as1;


        PageReference pRef = Page.SM_RenewalOfSubscriptionDetail;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('Id', ord.Id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        SM_RenewalOfSubscriptionDetailController controller = new SM_RenewalOfSubscriptionDetailController();
        controller.dtlDate = Date.today();
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>> '+ApexPages.currentPage());
        controller.retrieveOrder();
        controller.Submit();
    }
    
    public static testMethod void testVoid(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
                
        Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];
        zsub.Order_Number__c = null;
        zsub.Zuora__Account__c = acc.Id;
        zsub.Billing_Type__c = 'Full Prepaid';
        try
        {
            insert zsub; 
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.id;
        ord.Status__c = 'Draft';
        ord.Order_Type__c = 'Renewal';
        ord.Base_Subscription__c = zsub.id;
        insert ord;
        
        Package__c pac = TestDataFactory.createPackage(1)[0];
        insert pac;
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Is_Digital__c = true;
        oli.Order__c = ord.id;
        oli.Main_Package_ID__c = pac.id;
        try
        {
            insert oli;
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.Display_Name__c = 'Asia-1';
        asia.User_ID_LDAP_ID__c = 'test1@sample.com';
        asia.Password__c = 'password';
        insert asia;
        
        Asia1_Subscription__c as1 = TestDataFactory.createAsiaOneSubscription(1)[0];
        as1.Order_Line_Item__c = oli.id;
        as1.Asia1__c = asia.id;
        insert as1;

        PageReference pRef = Page.SM_RenewalOfSubscriptionDetail;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('Id', ord.Id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        SM_RenewalOfSubscriptionDetailController controller = new SM_RenewalOfSubscriptionDetailController();
        controller.retrieveOrder();
        controller.void();
    }
    public static testMethod void testEdit(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];
        zsub.Order_Number__c = null;
        zsub.Zuora__Account__c = acc.Id;
        zsub.Billing_Type__c = 'Full Prepaid';
        try
        {
            insert zsub; 
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.id;
        ord.Status__c = 'Draft';
        ord.Order_Type__c = 'Renewal';
        ord.Base_Subscription__c = zsub.id;
        insert ord;
        
        Package__c pac = TestDataFactory.createPackage(1)[0];
        insert pac;
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Is_Digital__c = true;
        oli.Order__c = ord.id;
        oli.Main_Package_ID__c = pac.id;
        try
        {
            insert oli;
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.Display_Name__c = 'Asia-1';
        asia.User_ID_LDAP_ID__c = 'test1@sample.com';
        asia.Password__c = 'password';
        insert asia;
        
        Asia1_Subscription__c as1 = TestDataFactory.createAsiaOneSubscription(1)[0];
        as1.Order_Line_Item__c = oli.id;
        as1.Asia1__c = asia.id;
        insert as1;

        PageReference pRef = Page.SM_RenewalOfSubscriptionDetail;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('Id', ord.Id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        SM_RenewalOfSubscriptionDetailController controller = new SM_RenewalOfSubscriptionDetailController();
        controller.retrieveOrder();
        controller.edit();
    }
}