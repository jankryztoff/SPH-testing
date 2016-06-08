/**
   @Author Val Lu
   @name UpdatePromotionGiftClassTest
   @CreateDate 02/26/2015
   @Description To test UpdatePromotionGiftClass class
   @Version <1.0>
  */
@isTest (seeAllData= True)
private class UpdatePromotionGiftClassTest {
    /**
    *  To test UpdatePromotionGift class
    *  @name testUpdatePromotionGift
    *  @param none
    *  @return none
    *  @throws na
    */
    /*
    static testmethod void testUpdatePromotionGift(){
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) { 
            
            //create Publication
            Publication__c newPublication = TestDataFactory.createPublication(1)[0];
            newPublication.Earliest_Start_Date__c = Date.Today();
            newPublication.Publication_Code__c = 'PUB1';
            newPublication.Published_Days__c = '2';
            newPublication.Publication_Type__c = 'N';
            insert newPublication;
            
            system.assertNotEquals(null, newPublication.id);
            
            //create Product
            Zuora__Product__c newProduct = TestDataFactory.createProduct(1)[0];
            insert newProduct;
            
            system.assertNotEquals(null, newProduct.id);
            
            //create Product Publication - junction object between Product and Publication
            Product_Publication__c newProductPub = TestDataFactory.createProductPublication(1)[0];
            insert newProductPub;
            
            system.assertNotEquals(null, newProductPub.id);
            
            //create Account
            Account newAccount = TestDataFactory.createAccount(1,'Direct Corporate')[0];
            newAccount.Name='TestAccount';
            newAccount.Phone='00000';
            insert newAccount;
            
            system.assertNotEquals(null, newAccount.id);
            
            //create Order
            Order__c newOrder = TestDataFactory.createOrder(1)[0];
            newOrder.Subscription_Start_Date__c = newPublication.Earliest_Start_Date__c;//no earliest start date on Order object
            newOrder.Order_Type__c = 'Start';
            newOrder.Status__c = 'Draft';
            newOrder.Account__c = newAccount.Id;
            insert newOrder;
            
            system.assertNotEquals(null, newOrder.id);
            
            //create Case
            Case caseRecord = new Case(Subject= GlobalVariableClass.SUBJECT_START_SUBSCRIPTION,
                                       Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST,
                                       Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION,
                                       Status= GlobalVariableClass.STATUS_PENDING,
                                       Origin='Email',
                                       RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION),
                                       Order__c = newOrder.id);
            insert caseRecord; 
            
            system.assertNotEquals(null, caseRecord.id);
            
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
            newPackage.Package_Code__c='PackageCode';
            insert newPackage;
            
            system.assertNotEquals(null, newPackage.id);
            
            //create Order Line Item
            Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
            newOLI.Order__c = newOrder.Id;
            newOLI.Main_Package_ID__c = newPackage.Id;
            newOLI.Is_Digital__c = true;
            insert newOLI;
            
            system.assertNotEquals(null, newOLI.id);
            
            List<Order_Line_Item__c> orderLineItem = new List<Order_Line_Item__c>();
            orderLineItem.add(newOLI);
            
            //create Promotion gift
            Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
            newPG.Gift_Inventory__c = 1000;
            newPG.Gift_Issued__c = 100;
            newPG.Gift_Redeemed__c = 100;
            insert newPG;
            
            system.assertNotEquals(null, newPG.id);
            
            List<Promotion_Gift__c> promotionGifts2 = new List<Promotion_Gift__c>();
            promotionGifts2.add(newPG);
            
            //create Order Line Item Gift
            Order_Line_Item_Gift__c newOLIg = TestDataFactory.createItemGift(1)[0];
            newOLIG.Order_Line_Item__c = newOLI.Id;
            newOLIG.Promotion_Gift__c = newPG.Id;
            newOLIG.Order_Quantity__c = 1;
            newOLIG.Redemption_Quantity__c = 1;
            newOLIG.Redemption_Date__c = date.today();
            insert newOLIG;
            
            system.assertNotEquals(null, newOLIG.id);
            
            List<Order_Line_Item_Gift__c> newOrderLineItemGifts  = new List<Order_Line_Item_Gift__c>();
            newOrderLineItemGifts.add(newOLIg);
            
            Test.startTest();
            
            UpdatePromotionGiftClass upgClass = new UpdatePromotionGiftClass();
            
            system.assertNotEquals(null, upgClass);
            
            upgClass.UpdatePromotionGift(newOrderLineItemGifts );
            
            Test.stopTest(); 
        }
        
    }
    */
    /**
    *  To test DecreaseQuantity
    *  @name testDecreaseQuantity
    *  @param none
    *  @return none
    *  @throws na
    */    
    /*
    static testmethod void testDecreaseQuantity()
    {
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) {
            //create Publication
            Publication__c newPublication = TestDataFactory.createPublication(1)[0];
            newPublication.Earliest_Start_Date__c = Date.Today();
            newPublication.Publication_Code__c = 'PUB1';
            newPublication.Published_Days__c = '2';
            newPublication.Publication_Type__c = 'N';
            insert newPublication;
            
            system.assertNotEquals(null, newPublication.id);
            
            //create Product
            Zuora__Product__c newProduct = TestDataFactory.createProduct(1)[0];
            insert newProduct;
            
            //create Product Publication - junction object between Product and Publication
            Product_Publication__c newProductPub = TestDataFactory.createProductPublication(1)[0];
            insert newProductPub;
            
            //create Account
            Account newAccount = TestDataFactory.createAccount(1,'Direct Corporate')[0];
            newAccount.Name='TestAccount';
            newAccount.Phone='00000';
            insert newAccount;
            
            system.assertNotEquals(null, newAccount.id);
            
            //create Order
            Order__c newOrder = TestDataFactory.createOrder(1)[0];
            newOrder.Subscription_Start_Date__c = newPublication.Earliest_Start_Date__c;//no earliest start date on Order object
            newOrder.Order_Type__c = 'Start';
            newOrder.Status__c = 'Draft';
            newOrder.Account__c = newAccount.Id;
            insert newOrder;
            
            system.assertNotEquals(null, newOrder.id);
            
            //create Case
            Case caseRecord = new Case(Subject= GlobalVariableClass.SUBJECT_START_SUBSCRIPTION,
                                       Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST,
                                       Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION,
                                       Status= GlobalVariableClass.STATUS_PENDING,
                                       Origin='Email',
                                       RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION),
                                       Order__c = newOrder.id);
            insert caseRecord; 
            
            system.assertNotEquals(null, caseRecord.id);
            
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
            newPackage.Package_Code__c='PackageCode';
            insert newPackage;
            
            system.assertNotEquals(null, newPackage.id);
            
            //create Order Line Item
            Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
            newOLI.Order__c = newOrder.Id;
            newOLI.Main_Package_ID__c = newPackage.Id;
            newOLI.Is_Digital__c = true;
            insert newOLI;
            
            List<Order_Line_Item__c> orderLineItem = new List<Order_Line_Item__c>();
            orderLineItem.add(newOLI);
            
            //create Promotion gift
            Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
            newPG.Gift_Inventory__c = 1000;
            newPG.Gift_Issued__c = 100;
            newPG.Gift_Redeemed__c = 100;
            insert newPG;
            
            system.assertNotEquals(null, newPG.id);
            
            List<Promotion_Gift__c> promotionGifts2 = new List<Promotion_Gift__c>();
            promotionGifts2.add(newPG);
            
            //create Order Line Item Gift
            Order_Line_Item_Gift__c newOLIg = TestDataFactory.createItemGift(1)[0];
            newOLIG.Order_Line_Item__c = newOLI.Id;
            newOLIG.Promotion_Gift__c = newPG.Id;
            newOLIG.Order_Quantity__c = 1;
            newOLIG.Redemption_Quantity__c = 1;
            newOLIG.Redemption_Date__c = date.today();
            insert newOLIG;
            
            system.assertNotEquals(null, newOLIG.id);
            
            List<Order_Line_Item_Gift__c> deletedOrderLineItemGifts = new List<Order_Line_Item_Gift__c>();
            deletedOrderLineItemGifts.add(newOLIg);
            
            
            Test.startTest();
            
            UpdatePromotionGiftClass upgClass = new UpdatePromotionGiftClass();
            
            system.assertNotEquals(null, upgClass);
            
            upgClass.DecreaseQuantity(deletedOrderLineItemGifts);
            
            Test.stopTest(); 
        }
        
    }
    */
    
    static testmethod void testUpdatePromotionGift()
    {
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) {
            UpdatePromotionGiftClass testObj = new UpdatePromotionGiftClass();
            
          //Promotion_Gift__c
            List<Promotion_Gift__c> pgs = TestDataFactory.createPromotionGift(200);
            insert pgs;
            
          //Order_Line_Item_Gift__c
            List<Order_Line_Item_Gift__c> oligs = TestDataFactory.createItemGift(200);
            Integer count = 0;
            List<String> pg_ids = new List<String>();
            
            for (Order_Line_Item_Gift__c olig : oligs) {
                pg_ids.add(pgs[count].id);
                olig.Promotion_Gift__c = pgs[count++].id;
                olig.Order_Quantity__c = 10;
                olig.Redemption_Quantity__c = 20;
            }
            
            Test.startTest();
            
            testObj.UpdatePromotionGift(oligs);
            List<Promotion_Gift__c> actuals = [SELECT Name, Gift_Issued__c, Gift_Redeemed__c FROM Promotion_Gift__c WHERE Id=:pg_ids];
            
            Test.stopTest();
            
            for (Promotion_Gift__c pg : actuals) {
                System.assertEquals(110,pg.Gift_Issued__c);
                System.assertEquals(120,pg.Gift_Redeemed__c);
            }
        }
    }
    
    static testmethod void testDecreaseQuantity()
    {
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) {
            UpdatePromotionGiftClass testObj = new UpdatePromotionGiftClass();
            
          //Promotion_Gift__c
            List<Promotion_Gift__c> pgs = TestDataFactory.createPromotionGift(200);
            insert pgs;
            
          //Order_Line_Item_Gift__c
            List<Order_Line_Item_Gift__c> oligs = TestDataFactory.createItemGift(200);
            Integer count = 0;
            List<String> pg_ids = new List<String>();
            
            for (Order_Line_Item_Gift__c olig : oligs) {
                pg_ids.add(pgs[count].id);
                olig.Promotion_Gift__c = pgs[count++].id;
                olig.Order_Quantity__c = 10;
                olig.Redemption_Quantity__c = 20;
            }
            
            Test.startTest();
            
            testObj.DecreaseQuantity(oligs);
            List<Promotion_Gift__c> actuals = [SELECT Name, Gift_Issued__c, Gift_Redeemed__c FROM Promotion_Gift__c WHERE Id=:pg_ids];
            
            Test.stopTest();
            
            for (Promotion_Gift__c pg : actuals) {
                System.assertEquals(90,pg.Gift_Issued__c);
                System.assertEquals(80,pg.Gift_Redeemed__c);
            }
        }
    }
}