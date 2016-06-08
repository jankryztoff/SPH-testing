/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData =  false)
private class AttachEligibilityRuleExtensionTest {

    static list<Package__c> packages;
    static Promotion__c promotion;
    static Promotion_Package__c promotionPackage;
    static Eligibility_Rule__c eligibilityRule;

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
        
        // instantiate promotion eligibility rule
        Promotion_Eligibility_Rule__c promotionEligibilityRule = new Promotion_Eligibility_Rule__c();
        promotionEligibilityRule.Current_Platform__c = 'Print';
        promotionEligibilityRule.Eligibility_Rule__c = eligibilityRule.Id;
        promotionEligibilityRule.Promotion__c = promotion.Id;
        promotionEligibilityRule.Days__c = null;
        promotionEligibilityRule.Date__c = null;
        promotionEligibilityRule.Product_Family__c = 'ST';
        
        
        // instantiate attacheligibilityrule vf page
        PageReference pageRef = new PageReference('/apex/AttachEligibilityRule');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('promotionId', promotion.Id);
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
        extension.save();
        
        // cancel
        extension.cancel();        
    }



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
        cpackage2.Tagged_to_Promo_for_Add_On_Discount__c = true;        
        
        packages = new list<Package__c>();
        packages.add(cpackage1);
        packages.add(cpackage2);
        
        insert packages;
    }
    
    
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
    }
    
    
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
        
    }
}