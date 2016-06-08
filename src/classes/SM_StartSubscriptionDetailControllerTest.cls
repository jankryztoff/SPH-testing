@isTest(SeeAllData=true)
public class SM_StartSubscriptionDetailControllerTest{

    
    static testMethod void testSM_StartSubsDetailController(){
        //insert Test Data 
        
        //get cso Profile ID
        List<Profile> csoprof = new List<Profile>();
        csoprof = [Select ID From Profile Where Name = 'cso' LIMIT 1];
        
        User testUser = new User(
        Alias = 'stndrd',
        Email='standarduser@test.com', 
        EmailEncodingKey='UTF-8',
        LastName='Test',
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US',
        ProfileId = csoprof[0].id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='standard@test.com'
        );
        
        
        System.runAs(testUser) { 
                
        //create Publication
        Publication__c newPublication = TestDataFactory.createPublication(1)[0];
        newPublication.Earliest_Start_Date__c = Date.Today().addDays(1);
        newPublication.Publication_Code__c = 'PUB1';
        newPublication.Published_Days__c = 'NNNNNNN';
        newPublication.Publication_Type__c = 'Y';
        insert newPublication;
        
        //create Product
        Zuora__Product__c newProduct = TestDataFactory.createProduct(1)[0];
        //newProduct.Product_Code__c = 'ABC1'; //Cannot see data type for this
        insert newProduct;
        
        //create Product Publication - junction object between Product and Publication
        Product_Publication__c newProductPub = TestDataFactory.createProductPublication(1)[0];
        //newProductPub.Publication_Code__c = newPublication.Publication_Code__c; //Publication_Code__c - lookup to Publication__c
        //newProductPub.Product_Code__c = newProduct.Product_Code__c; //Product_Code__c - lookup to Zuora__Product__c
        insert newProductPub;
        
        //create Account
        Account newAccount = TestDataFactory.createAccount(1,'Vendor')[0];
        newAccount.Name='TestAccount';
        newAccount.Phone='00000';
        insert newAccount;
        
        /*
        //create Subscription
        Zuora__Subscription__c newZsub = TestDataFactory.createSubscription(1)[0];
        newZsub.Name='Test Subscription';
        insert newZsub;
        */
        
        //create Order
        Order__c newOrder = TestDataFactory.createOrder(1)[0];
        newOrder.Subscription_Start_Date__c = newPublication.Earliest_Start_Date__c;//no earliest start date on Order object
        newOrder.Order_Type__c = 'Start';
        newOrder.Status__c = 'Draft';
        newOrder.Account__c = newAccount.Id;
        newOrder.Delivery_Charge_Type__c = 'Z';
        insert newOrder;
        
        //create Case
        Case caseRecord = new Case(Subject= GlobalVariableClass.SUBJECT_START_SUBSCRIPTION,
        Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST,
        Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION,
        Status= GlobalVariableClass.STATUS_PENDING,
        Origin='Email',
        RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION),
        Order__c = newOrder.id);
        insert caseRecord; 
        
        List<Order__c> orderList = new List<Order__c>();
        orderList.add(newOrder);
        
        //create Package
        Package__c newPackage = TestDataFactory.createPackage(1)[0];
        newPackage.Name = 'Test Package';
        newPackage.Package_Type__c='Base';
        newPackage.Subscription_Type__c='Termed';
        newPackage.Effective_Start_Date__c=date.today();
        newPackage.Effective_End_Date__c=date.today()+100;
        newPackage.Subscription_Period__c='18';
        newPackage.Package_Code__c='PackageCode2';
        insert newPackage;
       
         
        //create Order Line Item
        Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
        newOLI.Order__c = newOrder.Id;
        newOLI.Main_Package_ID__c = newPackage.Id;
        newOLI.Vendor_Mailing_Agent__c = newAccount.Id;
        newOLI.Is_Digital__c = true;
        newOLI.Start_Date__c = Date.Today()+1;
        newOLI.Delivered_By__c = GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT;
        
        insert newOLI;
        
        //system.assertEquals(' ', newOLI.Id+'');

        List<Order_Line_Item__c> orderLineItem = new List<Order_Line_Item__c>();
        orderLineItem.add(newOLI);
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        List<Promotion_Gift__c> promotionGifts2 = new List<Promotion_Gift__c>();
        promotionGifts2.add(newPG);
        
        //create Order Line Item Gift
        Order_Line_Item_Gift__c newOLIg = TestDataFactory.createItemGift(1)[0];
        newOLIG.Order_Line_Item__c = newOLI.Id;
        newOLIG.Promotion_Gift__c = newPG.Id;
        insert newOLIG;
        
        List<Order_Line_Item_Gift__c> promotionGifts = new List<Order_Line_Item_Gift__c>();
        promotionGifts.add(newOLIg);
        
        //create ZProduct
        zqu__ZProduct__c newZP = TestDataFactory.createZProduct(1)[0];
        newZP.Name='Test Quote Wizard';
        newZP.zqu__SKU__c='SKU';
        newZP.ProductCode__c='Product Code';
        newZP.ProductType__c='Product Type';
        insert newZP;    
        
        //create Product Rate Plan
        zqu__ProductRatePlan__c newPRPlan = TestDataFactory.createProductRatePlan(1)[0];
        newPRPlan.zqu__ZProduct__c = newZP.Id;
        //newPRPlan.Zuora__Product__c = newProduct.Id;
        //newPRPlan.Order_Line_Item__c = newOLI.Id;
        insert newPRPlan;
        
        //create Product Rate Plan Charge
        zqu__ProductRatePlanCharge__c newPRPCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        newPRPCharge.zqu__ProductRatePlan__c = newPRPlan.Id;
        insert newPRPCharge;
        
        //create Product Rate Plan Charge Tier
        zqu__ProductRatePlanChargeTier__c newPRPCTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        newPRPCTier.zqu__ProductRatePlanCharge__c = newPRPCharge.Id;
        insert newPRPCTier;
                
        zqu__Quote__c newQuote = new zqu__Quote__c();
        newQuote.Delivery_Charge_Type__c = 'N';
        newQuote.Subscriber_Charge__c = 100;
        newQuote.Vendor_Credit__c = 10;
        newQuote.zqu__ZuoraAccountID__c = 'newAccount.Id';
        newQuote.Order_Line_Item_Number_1__c = newOLI.Id;
        newQuote.Order_Line_Item_Number__c = 'newOLI.Id';
        insert newQuote;
        
        test.startTest(); 

        PageReference pageRef = Page.SM_StartSubscriptionDetail;
        Test.setCurrentPage(pageRef);
        //ApexPages.customController controller = new ApexPages.customController(newOrder);  
        ApexPages.currentPage().getParameters().put('accountId', newAccount.Id);
        ApexPages.currentPage().getParameters().put('Id', newOrder.Id); 
        //ApexPages.currentPage().getParameters().put('def_parent_Id', <kung ano man yung id na toh>);
        SM_StartSubscriptionDetailController smStartSub = new SM_StartSubscriptionDetailController();
        smStartSub.selectedOrderLineItem = newOLI.Id;  
        smStartSub.retrieveOrder();
        smStartSub.retrieveOrderLineItem();
        //smStartSub.orderLineItemList();
        //smStartSub.retrieveOrderLineItems();
        smStartSub.submit();
        smStartSub.edit();
        smStartSub.isNewspaper = false;
        smStartSub.isMagazine = false;
        smStartSub.VendorMailingAgent = 'agent';
        //smStartSub.void();
        
        system.assertEquals(1, promotionGifts.size() );
        //system.assertEquals(false, isError);
        //system.assertEquals(true, newOLI.Is_Digital__c); 

        test.stopTest(); 
              
    }}//END testMethod testSM_StartSubsDetailController()
    
        static testMethod void testSM_VoidOrder(){
        //insert Test Data 
        
        //get cso Profile ID
        List<Profile> csoprof = new List<Profile>();
        csoprof = [Select ID From Profile Where Name = 'cso' LIMIT 1];
        
        User testUser = new User(
        Alias = 'stndrd',
        Email='standarduser@test.com', 
        EmailEncodingKey='UTF-8',
        LastName='Test',
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US',
        ProfileId = csoprof[0].id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='standard@test.com'
        );
        
        
        System.runAs(testUser) { 
                
        //create Publication
        Publication__c newPublication = TestDataFactory.createPublication(1)[0];
        newPublication.Earliest_Start_Date__c = Date.Today().addDays(1);
        newPublication.Publication_Code__c = 'PUB1';
        newPublication.Published_Days__c = 'NNNNNNN';
        newPublication.Publication_Type__c = 'Y';
        insert newPublication;
        
        //create Product
        Zuora__Product__c newProduct = TestDataFactory.createProduct(1)[0];
        //newProduct.Product_Code__c = 'ABC1'; //Cannot see data type for this
        insert newProduct;
        
        //create Product Publication - junction object between Product and Publication
        Product_Publication__c newProductPub = TestDataFactory.createProductPublication(1)[0];
        //newProductPub.Publication_Code__c = newPublication.Publication_Code__c; //Publication_Code__c - lookup to Publication__c
        //newProductPub.Product_Code__c = newProduct.Product_Code__c; //Product_Code__c - lookup to Zuora__Product__c
        insert newProductPub;
        
        //create Account
        Account newAccount = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        newAccount.Name='TestAccount';
        newAccount.Phone='00000';
        insert newAccount;
        
        
        Zuora__CustomerAccount__c newBillAcc = TestDataFactory.createBillingAccount(1)[0];
        newBillAcc.Zuora__Account__c = newAccount.Id;
        newBillAcc.Billing_Type__c = 'Full Prepaid'; 
        newBillAcc.Zuora__Credit_Balance__c = 1;
        insert newBillAcc;
        
        
       
        
        /*
        //create Subscription
        Zuora__Subscription__c newZsub = TestDataFactory.createSubscription(1)[0];
        newZsub.Name='Test Subscription';
        insert newZsub;
        */
        
        //create Order
        Order__c newOrder = TestDataFactory.createOrder(1)[0];
        newOrder.Subscription_Start_Date__c = newPublication.Earliest_Start_Date__c;//no earliest start date on Order object
        newOrder.Order_Type__c = 'Start';
        //newOrder.Billing_Account__c = newBillAcc.Id;
        newOrder.Status__c = 'Draft';
        
        newOrder.Account__c = newAccount.Id;
        newOrder.Billing_Type__c = 'Full Prepaid';
        insert newOrder;
        
        //create Case
        Case caseRecord = new Case(Subject= GlobalVariableClass.SUBJECT_START_SUBSCRIPTION,
        Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST,
        Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION,
        Status= GlobalVariableClass.STATUS_PENDING,
        Origin='Email',
        RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION),
        Order__c = newOrder.id);
        insert caseRecord; 
        
        List<Order__c> orderList = new List<Order__c>();
        
        orderList.add(newOrder);
        
        //create Package
        Package__c newPackage = TestDataFactory.createPackage(1)[0];
        newPackage.Name = 'Test Package';
        newPackage.Package_Type__c='Base';
        newPackage.Subscription_Type__c='Termed';
        newPackage.Effective_Start_Date__c=date.today();
        newPackage.Effective_End_Date__c=date.today()+100;
        newPackage.Subscription_Period__c='18';
        newPackage.Package_Code__c='PackageCode3';
        insert newPackage;
         
        //create Order Line Item
        Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
        newOLI.Order__c = newOrder.Id;
        newOLI.Main_Package_ID__c = newPackage.Id;
        newOLI.Is_Digital__c = true;
        newOLI.Start_Date__c = Date.Today()+1;
        insert newOLI;
        
        //system.assertEquals(' ', newOLI.Id+'');

        List<Order_Line_Item__c> orderLineItem = new List<Order_Line_Item__c>();
        
        orderLineItem.add(newOLI);
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        List<Promotion_Gift__c> promotionGifts2 = new List<Promotion_Gift__c>();
        promotionGifts2.add(newPG);
        
        //create Order Line Item Gift
        Order_Line_Item_Gift__c newOLIg = TestDataFactory.createItemGift(1)[0];
        newOLIG.Order_Line_Item__c = newOLI.Id;
        newOLIG.Promotion_Gift__c = newPG.Id;
        insert newOLIG;
        
        List<Order_Line_Item_Gift__c> promotionGifts = new List<Order_Line_Item_Gift__c>();
        promotionGifts.add(newOLIg);
        
        //create ZProduct
        zqu__ZProduct__c newZP = TestDataFactory.createZProduct(1)[0];
        newZP.Name='Test Quote Wizard';
        newZP.zqu__SKU__c='SKU';
        newZP.ProductCode__c='Product Code';
        newZP.ProductType__c='Product Type';
        newZp.ProductSubType__c = 'Newspaper';
        insert newZP;    
        
        //create Product Rate Plan
        zqu__ProductRatePlan__c newPRPlan = TestDataFactory.createProductRatePlan(1)[0];
        newPRPlan.zqu__ZProduct__c = newZP.Id;
        //newPRPlan.Zuora__Product__c = newProduct.Id;
        //newPRPlan.Order_Line_Item__c = newOLI.Id;
        insert newPRPlan;
        
        //create Product Rate Plan Charge
        zqu__ProductRatePlanCharge__c newPRPCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        newPRPCharge.zqu__ProductRatePlan__c = newPRPlan.Id;
        insert newPRPCharge;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = newPackage.id;
        pItem.Product_Rate_Plan__c = newPRPlan.id;
        //pItem.Is_Newspaper__c = true;
        pItem.Name = 'Test Pack Item';
        insert pItem;
        
        //create Product Rate Plan Charge Tier
        zqu__ProductRatePlanChargeTier__c newPRPCTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        newPRPCTier.zqu__ProductRatePlanCharge__c = newPRPCharge.Id;
        insert newPRPCTier;
        
        test.startTest(); 

        PageReference pageRef = Page.SM_StartSubscriptionDetail;
        Test.setCurrentPage(pageRef);
        //ApexPages.customController controller = new ApexPages.customController(newOrder);  
        ApexPages.currentPage().getParameters().put('accountId', newAccount.Id);
        ApexPages.currentPage().getParameters().put('Id', newOrder.Id); 
        //ApexPages.currentPage().getParameters().put('def_parent_Id', <kung ano man yung id na toh>);
        SM_StartSubscriptionDetailController smStartSub = new SM_StartSubscriptionDetailController();
        smStartSub.selectedOrderLineItem = newOLI.Id;  
        smStartSub.retrieveOrder();
        smStartSub.retrieveOrderLineItem();
        smStartSub.getIsButtonRendered();
        smStartSub.creditBalance(newOrder.Id);
        //smStartSub.orderLineItemList();
        //smStartSub.retrieveOrderLineItems();

        smStartSub.voidButton();
        
        system.assertEquals(1, promotionGifts.size() );
        //system.assertEquals(false, isError);
        //system.assertEquals(true, newOLI.Is_Digital__c); 

        test.stopTest(); 
              
    }}//END testSM_VoidOrder()
    
    
    
    static testMethod void testAsia1Wrapper(){
    
        //SM_StartSubscriptionDetailController.Asia1Wrapper asia1Wrapper = new SM_StartSubscriptionDetailController.Asia1Wrapper();
        //JDS 9/29
    
    }//END testMethod testAsia1Wrapper()
    
    static testMethod void testAsia1SubscriptionWrapper(){
    
        //SM_StartSubscriptionDetailController.Asia1SubscriptionWrapper asia1SubWrapper = new SM_StartSubscriptionDetailController.Asia1SubscriptionWrapper();
        //JDS 9/29
    
    }//END testMethod testAsia1SubscriptionWrapper
}//END SM_StartSubsDetailControllerTest