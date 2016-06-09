/**
   @Author Joy Suarez    
   @name AttachEligibilityRuleExtension_Test
   @CreateDate 02/04/2015
   @Description test class for AttachEligibilityRuleExtension
   @Version <1.0>
   @reference <Referenced program names>
  */


@isTest(seeAllData =  false)
private class AttachEligibilityRuleExtension_Test {

    static list<Package__c> packages;
    static Promotion__c promotion;
    static Promotion_Package__c promotionPackage;
    static Eligibility_Rule__c eligibilityRule;

    /**
    *  To test AttachEligibilityRuleExtension
    *  @name myUnitTest1
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        
        // create package
        generatePackages();

        // create promotion
        generatePromotion();
        
        // create promotion package
        generatePromotionPackage(packages[0].Id, promotion.Id);        
        
        // create elibility rule
        generateEligibilityRule();
        
                
        Product_Family__c newPrFamily = new Product_Family__c();
        newPrFamily.Product_Family__c = 'NP';        
        insert newPrFamily;   
        
    
        // instantiate promotion eligibility rule
        Promotion_Eligibility_Rule__c promotionEligibilityRule = new Promotion_Eligibility_Rule__c();
        promotionEligibilityRule.Current_Platform__c = 'Print';
        promotionEligibilityRule.Eligibility_Rule__c = eligibilityRule.Id;
        promotionEligibilityRule.Promotion__c = promotion.Id;
        promotionEligibilityRule.Days__c = null;
        promotionEligibilityRule.Date__c = null;
        promotionEligibilityRule.Prod_Family__c = newPrFamily.Id;
        promotionEligibilityRule.Package_List__c = 'STPFP1';
        database.insert(promotionEligibilityRule);
        
        // instantiate attacheligibilityrule vf page
        PageReference pageRef = new PageReference('/apex/AttachEligibilityRule');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('promotionId', promotion.Id);
        ApexPages.currentPage().getParameters().put('promotionName', promotion.Name);
        
        ApexPages.StandardController promotionEligibilityRuleStd = new ApexPages.StandardController(promotionEligibilityRule);        
        
        // instantiate attachelibilityruleextension apex class
        AttachEligibilityRuleExtension extension = new AttachEligibilityRuleExtension(promotionEligibilityRuleStd);
         extension.prodfamId = ''+newPrFamily.id;    
        // create promotion elibility rule
        extension.getItems();
        system.assertEquals(extension.getItems().size(), 1);
        
        // save without date and days
        extension.save();
        system.assertEquals(extension.save(), null);
        
        // save with both date and days
        promotionEligibilityRule.Days__c = '2';    
        promotionEligibilityRule.Date__c = date.today();
        extension.promotionEligibilityRule = promotionEligibilityRule;
        extension.save();

        // save without packageListSelected
        promotionEligibilityRule.Days__c = null;
        promotionEligibilityRule.Date__c = date.today();
        extension.promotionEligibilityRule = promotionEligibilityRule;
        extension.save();
                
        // save with packageListSelected
        extension.packageListSelected = ';' + promotion.Promotion_Code__c;
        //extension.save();
        
        // cancel
        extension.cancel();  
             
    }
    /**
    *  To test AttachEligibilityRuleExtension
    *  @name myUnitTest2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        
        // create package
        generatePackages();

        // create promotion
        generatePromotion();
        
        // create promotion package
        generatePromotionPackage(packages[0].Id, promotion.Id);        
        
        // create elibility rule
        generateEligibilityRule();
        
        // create product family
        
        // instantiate promotion eligibility rule
        Promotion_Eligibility_Rule__c promotionEligibilityRule = new Promotion_Eligibility_Rule__c();
        promotionEligibilityRule.Current_Platform__c = 'Print';
        promotionEligibilityRule.Eligibility_Rule__c = eligibilityRule.Id;
        promotionEligibilityRule.Promotion__c = promotion.Id;
        promotionEligibilityRule.Days__c = null;
        promotionEligibilityRule.Date__c = null;
        promotionEligibilityRule.Package_List__c = 'STPFP1';
        
            
        // instantiate attacheligibilityrule vf page
        PageReference pageRef = new PageReference('/apex/AttachEligibilityRule');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('', promotion.Id);
        ApexPages.currentPage().getParameters().put('promotionName', promotion.Name);
        
        ApexPages.StandardController promotionEligibilityRuleStd = new ApexPages.StandardController(promotionEligibilityRule);        
        
        // instantiate attachelibilityruleextension apex class
        AttachEligibilityRuleExtension extension = new AttachEligibilityRuleExtension(promotionEligibilityRuleStd);
             
        // create promotion elibility rule
        extension.getItems();
        system.assertEquals(extension.getItems().size(), 1);
        
        // save without date and days
        extension.save();
         
        system.assertEquals(extension.save(), null);
        
        // save with both date and days
        promotionEligibilityRule.Days__c = '2';    
        promotionEligibilityRule.Date__c = date.today();
        extension.promotionEligibilityRule = promotionEligibilityRule;
        extension.save();

        // save without packageListSelected
        promotionEligibilityRule.Days__c = null;
        promotionEligibilityRule.Date__c = date.today();
        extension.promotionEligibilityRule = promotionEligibilityRule;
        extension.save();
                
        // save with packageListSelected
        extension.packageListSelected = ';' + promotion.Promotion_Code__c;
        extension.addProductFamily();
        extension.removeProductFamily();
        extension.save();
        
        // cancel
        extension.cancel();        
    }

    /**
    *  To test AttachEligibilityRuleExtension
    *  @name generatePackages
    *  @param none
    *  @return none
    *  @throws na
    */ 

    private static void generatePackages() {
        /*
            require fields:
            1. Effective Start Date
            2. Effective End Date
            3. Package Code
        */
        Package__c cpackage1 = new Package__c();
        cpackage1.Name = 'Package Test 0001';
        cpackage1.Effective_Start_Date__c = date.today();
        cpackage1.Effective_End_Date__c = date.today().addDays(30);
        cpackage1.Package_Code__c = 'PC0001';
        
        Package__c cpackage2 = new Package__c();
        cpackage2.Name = 'Package Test 0002';
        cpackage2.Effective_Start_Date__c = date.today();
        cpackage2.Effective_End_Date__c = date.today().addDays(30);
        cpackage2.Package_Code__c = 'PC0002';
        
        packages = new list<Package__c>();
        packages.add(cpackage1);
        packages.add(cpackage2);
        
        insert packages;
        system.assertNotEquals(null, packages);  
    }
    
    /**
    *  To test AttachEligibilityRuleExtension
    *  @name generatePromotion
    *  @param none
    *  @return none
    *  @throws na
    */ 
    
    private static void generatePromotion() {
        /* 
            require fields:
            1. Effective Start Date
            2. Effective End Date
            3. Promotion Code
        */
        
        promotion = new Promotion__c();
        promotion.Name = 'Promotion Test 0001';
        promotion.Effective_Start_Date__c = date.today();
        promotion.Effective_End_Date__c = date.today().addDays(30);
        promotion.Promotion_Code__c = 'PRO0001';
        
        insert promotion;
        system.assertNotEquals(null, promotion);  
    }
    
    /**
    *  To test AttachEligibilityRuleExtension
    *  @name generatePromotionPackage
    *  @param none
    *  @return none
    *  @throws na
    */ 
    private static void generatePromotionPackage(id packageId, id promotionId) {
        /* 
            require fields:
            1. Package Name
            2. Promotion
        */
        
        promotionPackage = new Promotion_Package__c();
        promotionPackage.Package_Name__c = packageId;
        promotionPackage.Promotion__c = promotionId;
        
        insert promotionPackage;
        
        string packageName = [select Package_Name__r.Name from Promotion_Package__c where Id = :promotionPackage.Id].Package_Name__r.Name;
        system.assertEquals(packageName, 'Package Test 0001');
    }
    
    /**
    *  To test AttachEligibilityRuleExtension
    *  @name generateEligibilityRule
    *  @param none
    *  @return none
    *  @throws na
    */ 
    private static void generateEligibilityRule() {
        /* 
            require fields:
            1. Effective Start Date
            2. Effective End Date
        */
        
        eligibilityRule = new Eligibility_Rule__c();
        eligibilityRule.Name = 'Eligibility Rule Test 0001';
        eligibilityRule.Effective_Start_Date__c = date.today();
        eligibilityRule.Effective_End_Date__c = date.today().addDays(30);
        eligibilityRule.Current_Platform__c = 'Print';
        eligibilityRule.Condition__c = '=';
        eligibilityRule.Customer_Status__c = 'New customer';
                
        
        insert eligibilityRule;
        system.assertNotEquals(null, eligibilityRule); 
    }
}