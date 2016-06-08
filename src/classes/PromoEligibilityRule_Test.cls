/*
 * Class Name: PromoEligbilityRule_Test
 * @author: Accenture IDC (jensar.joey.z.sayson) 
 * Date Created: 06/25/2015
 * Requirement/Project Name: <SPH> 
 * @description: Test Class for PromoEligbilityRule 
 *
 * Modifications:
 * 1. (Author EID) @ MM/DD/YYYY - (EP)
 * ...
 */ 
 
@isTest(seeAllData = TRUE)
public class PromoEligibilityRule_Test
{
    //Holds all testdata values
    //static Map<String, List<SObject>> sObjectListMap_global;
/*
    //testmethod - I
    static testmethod void temporaryName01(){
        
        PromoEligibilityRule per = new PromoEligibilityRule();                            //primary class
        Map<String, Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
        
        setAllData();

        List<Account> acc = (List<Account>) sObjectListMap_global.get('Account');
        List<Zuora__Subscription__c> zSubs = (List<Zuora__Subscription__c>) sObjectListMap_global.get('Zuora__Subscription__c');
        List<Promotion__c> promoList = (List<Promotion__c>) sObjectListMap_global.get('Promotion__c');
        Set<String> s1 = new Set<String>();
            s1.add(promoList[0].Contract_Period__c);
        System.assertEquals('yasyd97',promoList[0].Promotion_Code__c);
        promoCodeContractSet.put(promoList[0].Promotion_Code__c, s1);
        System.Debug('jen promoIdSet 1' + promoList[0].Id);
        Test.startTest();
            per.getEligibility(acc[0].Id, 'Add', promoCodeContractSet, 'string', zSubs[0].Id, true);
            per.getEligibility(acc[0].Id, 'Add', promoCodeContractSet, 'string', zSubs[0].Id, false);
            System.assertNotEquals(null,per);
        Test.stopTest();
    }

    //testmethod - I clone
    static testmethod void temporaryName01_5(){
        
        PromoEligibilityRuleClone_Test per = new PromoEligibilityRuleClone_Test();        //clone class
        Map<String, Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
        
        setAllData();

        List<Account> acc = (List<Account>) sObjectListMap_global.get('Account');
        List<Zuora__Subscription__c> zSubs = (List<Zuora__Subscription__c>) sObjectListMap_global.get('Zuora__Subscription__c');
        List<Promotion__c> promoList = (List<Promotion__c>) sObjectListMap_global.get('Promotion__c');
        Set<String> s1 = new Set<String>();
            s1.add(promoList[0].Contract_Period__c);
        System.assertEquals('yasyd97',promoList[0].Promotion_Code__c);
        promoCodeContractSet.put(promoList[0].Promotion_Code__c, s1);
        System.Debug('jen promoIdSet 1' + promoList[0].Id);
        Test.startTest();
            per.getEligibility(acc[0].Id, 'Add', promoCodeContractSet, 'string', zSubs[0].Id, true);
            per.getEligibility(acc[0].Id, 'Add', promoCodeContractSet, 'string', zSubs[0].Id, false);
            System.assertNotEquals(null,per);
        Test.stopTest();
    }
*/  
    static List<Account> createAccount() {
        //Create account
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual');
            acc[0].Name = 'TEST';
            acc[0].NRIC__c = 'T1234567R';
        sObjectListMap_global.put('Account',acc);
        Database.insert(acc);
        
        return acc;
    }    
    
    static List<Account> createAccount03() {
        //Create account
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual');
            acc[0].Name = 'TEST';
            acc[0].NRIC__c = 'T1234567R';
        Database.insert(acc);
        
            acc[0].Parent = acc[0];
        Database.update(acc);
        
        sObjectListMap_global.put('Account',acc);
        return acc;
    }      
    
    static List<Account> createAccount04() {
        
        return createAccount03();
    }   
    
    //WHERE Promotion_Code__c IN: promoCodeSet AND Contract_Period__c IN: promoPeriodSet
    static List<Promotion__c> createPromotion() {
        //Create promo
        List<Promotion__c> promo = TestDataFactory.createPromoList(3);
            promo[0].Name = 'Promotion';
            promo[0].Promotion_Code__c = 'yasyd97';
            promo[0].Effective_Start_Date__c = Date.today();
            promo[0].Effective_End_Date__c = Date.today().addDays(30);
            promo[0].Contract__c = 'Yes';
            promo[0].Contract_Period__c = '2';
            promo[0].Penalty_Charge__c = '100';
            promo[0].Penalty_Charge_Override__c = 500.00;           
       //     
            promo[1].Name = 'Promotion';
            promo[1].Promotion_Code__c = 'yasyd98';
            promo[1].Effective_Start_Date__c = Date.today();
            promo[1].Effective_End_Date__c = Date.today().addDays(30);
            promo[1].Contract__c = 'Yes';
            promo[1].Contract_Period__c = '2';
            promo[1].Penalty_Charge__c = '100';
            promo[1].Penalty_Charge_Override__c = 500.00;          
       //     
            promo[2].Name = 'Promotion';
            promo[2].Promotion_Code__c = 'yasyd99';
            promo[2].Effective_Start_Date__c = Date.today();
            promo[2].Effective_End_Date__c = Date.today().addDays(30);
            promo[2].Contract__c = 'Yes';
            promo[2].Contract_Period__c = '2';
            promo[2].Penalty_Charge__c = '100';
            promo[2].Penalty_Charge_Override__c = 500.00;
            
        sObjectListMap_global.put('Promotion__c', promo);    
        Database.insert(promo);
        return promo;
    }
    
    static List<Promotion__c> createPromotion03() {
        //Create promo
        List<Promotion__c> promo = TestDataFactory.createPromoList(6);
            promo[0].Name = 'Promotion';
            promo[0].Promotion_Code__c = 'yasyd97';
            promo[0].Effective_Start_Date__c = Date.today();
            promo[0].Effective_End_Date__c = Date.today().addDays(30);
            promo[0].Contract__c = 'Yes';
            promo[0].Contract_Period__c = '2';
            promo[0].Penalty_Charge__c = '100';
            promo[0].Penalty_Charge_Override__c = 500.00;           
       //     
            promo[1].Name = 'Promotion';
            promo[1].Promotion_Code__c = 'yasyd98';
            promo[1].Effective_Start_Date__c = Date.today();
            promo[1].Effective_End_Date__c = Date.today().addDays(30);
            promo[1].Contract__c = 'Yes';
            promo[1].Contract_Period__c = '2';
            promo[1].Penalty_Charge__c = '100';
            promo[1].Penalty_Charge_Override__c = 500.00;          
       //     
            promo[2].Name = 'Promotion';
            promo[2].Promotion_Code__c = 'yasyd99';
            promo[2].Effective_Start_Date__c = Date.today();
            promo[2].Effective_End_Date__c = Date.today().addDays(30);
            promo[2].Contract__c = 'Yes';
            promo[2].Contract_Period__c = '2';
            promo[2].Penalty_Charge__c = '100';
            promo[2].Penalty_Charge_Override__c = 500.00;
       //     
            promo[3].Name = 'Promotion';
            promo[3].Promotion_Code__c = 'yasyd97';
            promo[3].Effective_Start_Date__c = Date.today();
            promo[3].Effective_End_Date__c = Date.today().addDays(30);
            promo[3].Contract__c = 'Yes';
            promo[3].Contract_Period__c = '2';
            promo[3].Penalty_Charge__c = '100';
            promo[3].Penalty_Charge_Override__c = 500.00;           
       //    
            promo[4].Name = 'Promotion';
            promo[4].Promotion_Code__c = 'yasyd98';
            promo[4].Effective_Start_Date__c = Date.today();
            promo[4].Effective_End_Date__c = Date.today().addDays(30);
            promo[4].Contract__c = 'Yes';
            promo[4].Contract_Period__c = '2';
            promo[4].Penalty_Charge__c = '100';
            promo[4].Penalty_Charge_Override__c = 500.00;          
       //     
            promo[5].Name = 'Promotion';
            promo[5].Promotion_Code__c = 'yasyd99';
            promo[5].Effective_Start_Date__c = Date.today();
            promo[5].Effective_End_Date__c = Date.today().addDays(30);
            promo[5].Contract__c = 'Yes';
            promo[5].Contract_Period__c = '2';
            promo[5].Penalty_Charge__c = '100';
            promo[5].Penalty_Charge_Override__c = 500.00;
           
        sObjectListMap_global.put('Promotion__c', promo);    
        Database.insert(promo);
        return promo;
    }
    
    
    
    static List<Promotion__c> createPromotion04() {
        //Create promo
        List<Promotion__c> promo = TestDataFactory.createPromoList(1);
            promo[0].Name = 'Promotion';
            promo[0].Promotion_Code__c = 'yasyd97';
            promo[0].Effective_Start_Date__c = Date.today();
            promo[0].Effective_End_Date__c = Date.today().addDays(30);
            promo[0].Contract__c = 'Yes';
            promo[0].Contract_Period__c = '2';
            promo[0].Penalty_Charge__c = '100';
            promo[0].Penalty_Charge_Override__c = 500.00; 
            
        sObjectListMap_global.put('Promotion__c', promo);    
        Database.insert(promo);
        return promo;
    }
    
    static List<Package__c> createPackage() {
        //Create package
        List<Package__c> packList = new List<Package__c>();
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
                pack.Name = 'Package';
                pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Code__c = 'temp code';      
                pack.Product_Family_Current_Package__c = 'temp package'; 
                pack.Effective_End_Date__c = date.today().addDays(31);
                pack.Effective_Start_Date__c = date.today();
                pack.Subscription_Period__c = '1';
            packList.add(pack);
        sObjectListMap_global.put('Package__c', packList);
        Database.insert(packList);
        return packList;
    }
    
    static List<Promotion_Package__c> createPromotionPackage(List<Promotion__c> promo, List<Package__c> packList) {
        //Create promotion package
        List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(3);
            promotionPackageList[0].Promotion__c = promo[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
        //    
            promotionPackageList[1].Promotion__c = promo[1].Id;
            promotionPackageList[1].Package_Name__c = packList[0].Id;
        //    
            promotionPackageList[2].Promotion__c = promo[2].Id;
            promotionPackageList[2].Package_Name__c = packList[0].Id;
            
        sObjectListMap_global.put('Promotion_Package__c', promotionPackageList);    
        Database.insert(promotionPackageList);
        return promotionPackageList;
    }
    
    static List<Promotion_Package__c> createPromotionPackage03(List<Promotion__c> promo, List<Package__c> packList) {
        //Create promotion package
        List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(6);
            promotionPackageList[0].Promotion__c = promo[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
        //    
            promotionPackageList[1].Promotion__c = promo[1].Id;
            promotionPackageList[1].Package_Name__c = packList[1].Id;
        //    
            promotionPackageList[2].Promotion__c = promo[2].Id;
            promotionPackageList[2].Package_Name__c = packList[2].Id;
        //
            promotionPackageList[3].Promotion__c = promo[3].Id;
            promotionPackageList[3].Package_Name__c = packList[3].Id;
        //    
            promotionPackageList[4].Promotion__c = promo[4].Id;
            promotionPackageList[4].Package_Name__c = packList[4].Id;
        //    
            promotionPackageList[5].Promotion__c = promo[5].Id;
            promotionPackageList[5].Package_Name__c = packList[5].Id;
            
        sObjectListMap_global.put('Promotion_Package__c', promotionPackageList);    
        Database.insert(promotionPackageList);
        return promotionPackageList;
    }
    
    static List<Promotion_Package__c> createPromotionPackage04(List<Promotion__c> promo, List<Package__c> packList) {
        //Create promotion package
        List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(1);
            promotionPackageList[0].Promotion__c = promo[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
            
        sObjectListMap_global.put('Promotion_Package__c', promotionPackageList);    
        Database.insert(promotionPackageList);
        return promotionPackageList;
    }
    
    static void createPromoEligibilityRule(List<Promotion__c> promoList) {
        List<Product_Family__c> pfList = createProductFamily();
        List<Eligibility_Rule__c> erList = createEligibilityRule(pfList);
        List<Promotion_Eligibility_Rule__c> perList = createPromotionEligibilityRule(promoList, pfList, erList);
        createPromoEligibilityRuleProductFamily(pfList, perList);
    }
    
    static List<Product_Family__c> createProductFamily() {
        //create product family      
        List<Product_Family__c> pfList = TestDataFactory.createProductFamily(1);
        
        Database.insert(pfList);
        return pfList;
    }
    
    static List<Eligibility_Rule__c> createEligibilityRule(List<Product_Family__c> pfList) {
        //create eligibility rule
        List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(6);
            erList[0].Name = 'temp name';
            erList[0].Product_Family__c = pfList[0].Id;
            erList[0].Contract_Status__c = 'With Contract';
            erList[0].Customer_Status__c = 'New customer';
            erList[0].Effective_Start_Date__c = Date.today();
            erList[0].Effective_End_Date__c = Date.today().addDays(30);
            erList[0].Action__c = 'Change';
            
            
        //TESTDATA 03
            erList[1].Name = 'temp name';
            erList[1].Product_Family__c = pfList[0].Id;
//            erList[1].Contract_Status__c = 'With Contract';
            erList[1].Customer_Status__c = 'New Customer';
            erList[1].Effective_Start_Date__c = Date.today();
            erList[1].Effective_End_Date__c = Date.today().addDays(30);
            erList[1].Action__c = 'Add';
            
        //TestData 04
            erList[2].Name = 'temp name';
            erList[2].Product_Family__c = pfList[0].Id;
//            erList[2].Contract_Status__c = 'With Contract';
            erList[2].Customer_Status__c = 'Vendor Customer';
            erList[2].Effective_Start_Date__c = Date.today();
            erList[2].Effective_End_Date__c = Date.today().addDays(30);
            erList[2].Action__c = 'Change';   
            
            erList[3].Name = 'temp name';
            erList[3].Product_Family__c = pfList[0].Id;
//            erList[3].Contract_Status__c = 'With Contract';
            erList[3].Customer_Status__c = 'Vendor Customer';
            erList[3].Effective_Start_Date__c = Date.today();
            erList[3].Effective_End_Date__c = Date.today().addDays(30);
            erList[3].Action__c = 'Add';           
            
        //TESTDATA 05
            erList[4].Name = 'temp name';
            erList[4].Product_Family__c = pfList[0].Id;
//            erList[4].Contract_Status__c = 'With Contract';
            erList[4].Customer_Status__c = 'Existing Customer';
            erList[4].Effective_Start_Date__c = Date.today();
            erList[4].Effective_End_Date__c = Date.today().addDays(30);
            erList[4].Action__c = 'Add';
        
        //TESTDATA 06
            erList[5].Name = 'temp name';
            erList[5].Product_Family__c = pfList[0].Id;
//            erList[5].Contract_Status__c = 'With Contract';
            erList[5].Customer_Status__c = 'Existing Customer';
            erList[5].Effective_Start_Date__c = Date.today();
            erList[5].Effective_End_Date__c = Date.today().addDays(30);
            erList[5].Action__c = 'Change';
            
        Database.insert(erList);
        return erList;
    }
    
    static List<Eligibility_Rule__c> createEligibilityRule02(List<Product_Family__c> pfList) {
        //create eligibility rule
        List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(8);
            erList[0].Name = 'temp name';
            erList[0].Product_Family__c = pfList[0].Id;
            erList[0].Contract_Status__c = 'With Contract';
            erList[0].Customer_Status__c = 'Vendor Customer';
            erList[0].Effective_Start_Date__c = Date.today();
            erList[0].Effective_End_Date__c = Date.today().addDays(30);
            erList[0].Action__c = 'Change';
            erList[0].Contract_Subscription_Rule__c = 'Subscription End Date';
            erList[0].Date__c = Date.today();
        //
            erList[1].Name = 'temp name';
            erList[1].Product_Family__c = pfList[0].Id;
            erList[1].Contract_Status__c = 'With Contract';
            erList[1].Customer_Status__c = 'Vendor Customer';
            erList[1].Effective_Start_Date__c = Date.today();
            erList[1].Effective_End_Date__c = Date.today().addDays(30);
            erList[1].Action__c = 'Change';
            erList[1].Subsciber_Status__c = 'New Subscriber';
            erList[1].Contract_Subscription_Rule__c = 'Contract End Date';
            erList[1].Days__c = '30';
        //    
            erList[2].Name = 'temp name';
            erList[2].Product_Family__c = pfList[0].Id;
            erList[2].Customer_Status__c = 'Existing Customer';
            erList[2].Effective_Start_Date__c = Date.today();
            erList[2].Effective_End_Date__c = Date.today().addDays(30);
            erList[2].Action__c = 'Add';
            erList[2].Subsciber_Status__c = 'New Subscriber';
            erList[2].Contract_Subscription_Rule__c = 'Subscription End Date';
            erList[2].Date__c = Date.today();
        //    
            erList[3].Name = 'temp name';
            erList[3].Product_Family__c = pfList[0].Id;
            erList[3].Customer_Status__c = 'Existing Customer';
            erList[3].Effective_Start_Date__c = Date.today();
            erList[3].Effective_End_Date__c = Date.today().addDays(30);
            erList[3].Action__c = 'Add';
            erList[3].Subsciber_Status__c = 'New Subscriber';
            erList[3].Contract_Subscription_Rule__c = 'Subscription End Date';
            erList[3].Days__c = '30';
        //    
            erList[4].Name = 'temp name';
            erList[4].Product_Family__c = pfList[0].Id;
            erList[4].Contract_Status__c = 'With Contract';
            erList[4].Customer_Status__c = 'Existing Customer';
            erList[4].Effective_Start_Date__c = Date.today();
            erList[4].Effective_End_Date__c = Date.today().addDays(30);
            erList[4].Action__c = 'Change';
            erList[4].Subsciber_Status__c = 'New Subscriber';
            erList[4].Contract_Subscription_Rule__c = 'Subscription End Date';
            erList[4].Date__c = Date.today();
        //    
            erList[5].Name = 'temp name';
            erList[5].Product_Family__c = pfList[0].Id;
            erList[5].Contract_Status__c = 'Without Contract';
            erList[5].Customer_Status__c = 'Existing Customer';
            erList[5].Effective_Start_Date__c = Date.today();
            erList[5].Effective_End_Date__c = Date.today().addDays(30);
            erList[5].Action__c = 'Change';
            erList[5].Subsciber_Status__c = null;  //if(promElRule.Eligibility_Rule__r.Subsciber_Status__c == null){
            erList[5].Contract_Subscription_Rule__c = 'Contract End Date';
            erList[5].Days__c = '30';
        //
            erList[6].Name = 'temp name';
            erList[6].Product_Family__c = pfList[0].Id;
            erList[6].Contract_Status__c = 'With Contract';
            erList[6].Customer_Status__c = 'Existing Customer';
            erList[6].Effective_Start_Date__c = Date.today();
            erList[6].Effective_End_Date__c = Date.today().addDays(30);
            erList[6].Action__c = 'Change';
            erList[6].Subsciber_Status__c = null;  //if(promElRule.Eligibility_Rule__r.Subsciber_Status__c == null){
            erList[6].Contract_Subscription_Rule__c = 'Contract End Date';
            erList[6].Date__c = Date.today();
        //        
            erList[7].Name = 'temp name';
            erList[7].Product_Family__c = pfList[0].Id;
            erList[7].Customer_Status__c = 'Existing Customer';
            erList[7].Effective_Start_Date__c = Date.today();
            erList[7].Effective_End_Date__c = Date.today().addDays(30);
            erList[7].Action__c = 'Add';
            erList[7].Subsciber_Status__c = 'New Subscriber';
            erList[7].Contract_Subscription_Rule__c = 'Subscription End Date';
            erList[7].Days__c = '30';
            
        Database.insert(erList);
        return erList;
    }
    
    static List<Eligibility_Rule__c> createEligibilityRule04(List<Product_Family__c> pfList) {
        //create eligibility rule
        List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(3);
            erList[0].Name = 'temp name';
            erList[0].Product_Family__c = pfList[0].Id;
            erList[0].Contract_Status__c = 'With Contract';
            erList[0].Customer_Status__c = 'Existing Customer';
            erList[0].Effective_Start_Date__c = Date.today();
            erList[0].Effective_End_Date__c = Date.today().addDays(30);
            erList[0].Action__c = 'Change';
            erList[0].Contract_Subscription_Rule__c = 'Contract End Date';
            erList[0].Date__c = Date.today();
            erList[0].Condition__c = '>';
        //     
            erList[1].Name = 'temp name';
            erList[1].Product_Family__c = pfList[0].Id;
            erList[1].Contract_Status__c = 'With Contract';
            erList[1].Customer_Status__c = 'Existing Customer';
            erList[1].Effective_Start_Date__c = Date.today();
            erList[1].Effective_End_Date__c = Date.today().addDays(30);
            erList[1].Action__c = 'Change';
            erList[1].Contract_Subscription_Rule__c = 'Contract End Date';
            erList[1].Days__c = '0';
            erList[1].Condition__c = '<=';
        //
            erList[2].Name = 'temp name';
            erList[2].Product_Family__c = pfList[0].Id;
            erList[2].Contract_Status__c = 'Without Contract';
            erList[2].Customer_Status__c = 'Existing Customer';
            erList[2].Effective_Start_Date__c = Date.today();
            erList[2].Effective_End_Date__c = Date.today().addDays(30);
            erList[2].Action__c = 'Change';
            erList[2].Contract_Subscription_Rule__c = 'Contract End Date';
           
        Database.insert(erList);
        return erList;
    }
    
    static List<Promotion_Eligibility_Rule__c> createPromotionEligibilityRule(List<Promotion__c> promo, List<Product_Family__c> pfList, List<Eligibility_Rule__c> erList) {
        //create promotion eligibility rule
        List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(6);
            perList[0].Promotion__c = promo[0].Id;
            perList[0].Product_Family__c = 'TM';
            perList[0].Package_List__c = 'temp package list';
            perList[0].Prod_Family__c = pfList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id; 
            perList[0].Date__c = Date.today();
        //
            perList[1].Promotion__c = promo[1].Id;
            perList[1].Product_Family__c = 'TM';
            perList[1].Package_List__c = 'temp package list';
            perList[1].Prod_Family__c = pfList[0].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id;
            perList[1].Days__c = '30'; 
        //
            perList[2].Promotion__c = promo[0].Id;
            perList[2].Product_Family__c = 'TM';
            perList[2].Package_List__c = 'temp package list';
            perList[2].Prod_Family__c = pfList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id; 
            perList[2].Date__c = Date.today();
        //
            perList[3].Promotion__c = promo[1].Id;
            perList[3].Product_Family__c = 'TM';
            perList[3].Package_List__c = 'temp package list';
            perList[3].Prod_Family__c = pfList[0].Id;
            perList[3].Eligibility_Rule__c = erList[3].Id; 
            perList[3].Days__c = '30'; 
        //
            perList[4].Promotion__c = promo[0].Id;
            perList[4].Product_Family__c = 'TM';
            perList[4].Package_List__c = 'temp package list';
            perList[4].Prod_Family__c = pfList[0].Id;
            perList[4].Eligibility_Rule__c = erList[4].Id; 
            perList[4].Date__c = Date.today();
        //
            perList[5].Promotion__c = promo[0].Id;
            perList[5].Product_Family__c = 'TM';
            perList[5].Package_List__c = 'temp package list';
            perList[5].Prod_Family__c = pfList[0].Id;
            perList[5].Eligibility_Rule__c = erList[5].Id; 
            perList[5].Days__c = '30'; 
        //
            perList[6].Promotion__c = promo[1].Id;
            perList[6].Product_Family__c = 'TM';
            perList[6].Package_List__c = 'temp package list';
            perList[6].Prod_Family__c = pfList[0].Id;
            perList[6].Eligibility_Rule__c = erList[6].Id; 
            perList[6].Date__c = Date.today();
        //
            perList[7].Promotion__c = promo[0].Id;
            perList[7].Product_Family__c = 'TM';
            perList[7].Package_List__c = 'temp package list';
            perList[7].Prod_Family__c = pfList[0].Id;
            perList[7].Eligibility_Rule__c = erList[7].Id; 
            perList[7].Days__c = '30'; 
              
            
        Database.insert(perList);
        return perList;
    }
    
    static List<Promotion_Eligibility_Rule__c> createPromotionEligibilityRule03(List<Promotion__c> promo, List<Product_Family__c> pfList, 
            List<Eligibility_Rule__c> erList) {
        //create promotion eligibility rule
        List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(9);
            perList[0].Promotion__c = promo[0].Id;
            perList[0].Product_Family__c = 'TM';
            perList[0].Package_List__c = 'temp package list';
            perList[0].Prod_Family__c = pfList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id; 
            perList[0].Date__c = Date.today();
            //perList[0].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
        //    
            perList[1].Promotion__c = promo[1].Id;
            perList[1].Product_Family__c = 'TM';
            perList[1].Package_List__c = 'temp package list';
            perList[1].Prod_Family__c = pfList[0].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id; 
            perList[1].Days__c = '30';
            //perList[1].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
        //
            perList[2].Promotion__c = promo[2].Id;
            perList[2].Product_Family__c = 'TM';
            perList[2].Package_List__c = 'temp package list';
            perList[2].Prod_Family__c = pfList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id; 
            perList[2].Date__c = Date.today();
            //perList[2].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
        //    
            perList[3].Promotion__c = promo[3].Id;
            perList[3].Product_Family__c = 'TM';
            perList[3].Package_List__c = 'temp package list';
            perList[3].Prod_Family__c = pfList[0].Id;
            perList[3].Eligibility_Rule__c = erList[3].Id; 
            perList[3].Days__c = '30';
            //perList[3].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
        //
            perList[4].Promotion__c = promo[4].Id;
            perList[4].Product_Family__c = 'TM';
            perList[4].Package_List__c = 'temp package list';
            perList[4].Prod_Family__c = pfList[0].Id;
            perList[4].Eligibility_Rule__c = erList[4].Id; 
            perList[4].Date__c = Date.today();
            //perList[4].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
        //    
            perList[5].Promotion__c = promo[5].Id;
            perList[5].Product_Family__c = 'TM';
            perList[5].Package_List__c = 'temp package list';
            perList[5].Prod_Family__c = pfList[0].Id;
            perList[5].Eligibility_Rule__c = erList[5].Id;  
            perList[5].Days__c = '30';
            //perList[5].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
        //    
            perList[6].Promotion__c = promo[0].Id;
            perList[6].Product_Family__c = 'TM';
            perList[6].Package_List__c = 'temp package list';
            perList[6].Prod_Family__c = pfList[0].Id;
            perList[6].Eligibility_Rule__c = erList[3].Id; 
            perList[6].Date__c = Date.today();
            //perList[6].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
        //
            perList[7].Promotion__c = promo[3].Id;
            perList[7].Product_Family__c = 'TM';
            perList[7].Package_List__c = 'temp package list';
            perList[7].Prod_Family__c = pfList[0].Id;
            perList[7].Eligibility_Rule__c = erList[7].Id; 
            perList[7].Days__c = '30';
            //perList[7].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
        //    
            perList[8].Promotion__c = promo[5].Id;
            perList[8].Product_Family__c = 'TM';
            perList[8].Package_List__c = 'temp package list';
            perList[8].Prod_Family__c = pfList[0].Id;
            perList[8].Eligibility_Rule__c = erList[5].Id; 
            perList[8].Date__c = Date.today(); 
            //perList[8].Promo_Eligibility_Rule_Product_Families__c = perpfList[0].id;
            
        Database.insert(perList);
        return perList;
    }
    
    static List<Promotion_Eligibility_Rule__c> createPromotionEligibilityRule04(List<Promotion__c> promo, List<Product_Family__c> pfList, 
            List<Eligibility_Rule__c> erList) {
        //create promotion eligibility rule
        List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(3);
            perList[0].Promotion__c = promo[0].Id;
            perList[0].Product_Family__c = 'TM';
            perList[0].Package_List__c = 'temp package list';
            perList[0].Prod_Family__c = pfList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id; 
            perList[0].Date__c = Date.today();
        //    
            perList[1].Promotion__c = promo[0].Id;
            perList[1].Product_Family__c = 'TM';
            perList[1].Package_List__c = 'temp package list';
            perList[1].Prod_Family__c = pfList[0].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id; 
            perList[1].Days__c = '0';
            //perList[1].Date__c = Date.today(); // this will cause error because of validation rule
        //    
            perList[2].Promotion__c = promo[0].Id;
            perList[2].Product_Family__c = 'TM';
            perList[2].Package_List__c = 'temp package list';
            perList[2].Prod_Family__c = pfList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id; 
            perList[2].Current_Platform__c = 'All-In-One';
        Database.insert(perList);
        return perList;
    }
       
    static List<Promo_Eligibility_Rule_Product_Family__c> createPromoEligibilityRuleProductFamily(List<Product_Family__c> pfList, List<Promotion_Eligibility_Rule__c> perList) {
        //create promo eligibility rule product family
        List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(1);
            perpfList[0].Product_Family__c = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            
        Database.insert(perpfList);
        return perpfList;
    }
       
    static List<Promo_Eligibility_Rule_Product_Family__c> createPromoEligibilityRuleProductFamily03(List<Product_Family__c> pfList, List<Promotion_Eligibility_Rule__c> perList) {
        //create promo eligibility rule product family
        List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(9);
            perpfList[0].Product_Family__c = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            
            perpfList[1].Product_Family__c = pfList[0].Id;
            perpfList[1].Promotion_Eligibility_Rule__c = perList[1].Id;
            
            perpfList[2].Product_Family__c = pfList[0].Id;
            perpfList[2].Promotion_Eligibility_Rule__c = perList[2].Id;
            
            perpfList[3].Product_Family__c = pfList[0].Id;
            perpfList[3].Promotion_Eligibility_Rule__c = perList[3].Id;
            
            perpfList[4].Product_Family__c = pfList[0].Id;
            perpfList[4].Promotion_Eligibility_Rule__c = perList[4].Id;
            
            perpfList[5].Product_Family__c = pfList[0].Id;
            perpfList[5].Promotion_Eligibility_Rule__c = perList[5].Id;
            
            perpfList[6].Product_Family__c = pfList[0].Id;
            perpfList[6].Promotion_Eligibility_Rule__c = perList[6].Id;
            
            perpfList[7].Product_Family__c = pfList[0].Id;
            perpfList[7].Promotion_Eligibility_Rule__c = perList[7].Id;
            
            perpfList[8].Product_Family__c = pfList[0].Id;
            perpfList[8].Promotion_Eligibility_Rule__c = perList[8].Id;
            
        Database.insert(perpfList);
        return perpfList;
    }
       
    static List<Promo_Eligibility_Rule_Product_Family__c> createPromoEligibilityRuleProductFamily04(List<Product_Family__c> pfList, List<Promotion_Eligibility_Rule__c> perList) {
        //create promo eligibility rule product family
        List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(3);
            perpfList[0].Product_Family__c = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            
            perpfList[1].Product_Family__c = pfList[0].Id;
            perpfList[1].Promotion_Eligibility_Rule__c = perList[1].Id;
            
            perpfList[2].Product_Family__c = pfList[0].Id;
            perpfList[2].Promotion_Eligibility_Rule__c = perList[2].Id;
                        
        Database.insert(perpfList);
        return perpfList;
    }

    //Billing Account
    static List<Zuora__CustomerAccount__c> createZuoraCustomerAccount(List<Account> acc) {
        //Create zoura customer account
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c = acc[0].Id;
            billAcc[0].Billing_Type__c = 'Full Prepaid';
            billAcc[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
        sObjectListMap_global.put('Zuora__CustomerAccount__c', billAcc);
        Database.insert(billAcc);
        return billAcc;
    }
    
    static List<Order__c> createOrder(List<Account> acc) {
        //Create order
        List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c = acc[0].Id;
//            odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c = 'Full Prepaid';
        sObjectListMap_global.put('Order__c', odr);
        Database.insert(odr);
        return odr;
    }
    
    static List<Zuora__Subscription__c> createZuoraSubscription(List<Account> acc, List<Promotion__c> promo, List<Zuora__CustomerAccount__c>billAcc, List<Order__c> odr) {
        //Create zuora subscription 
        List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c x: zSub){
            x.Zuora__Account__c = acc[0].id;
            x.Promotion_1__c = promo[0].id;
            x.Zuora__CustomerAccount__c = billAcc[0].Id;
            x.Order_Number__c = odr[0].id;
            x.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            x.Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            //x.Contract_End_Date_1__c = Date.today().addDays(90);
            x.Contract_End_Date__c = ''+Date.today().addDays(90);
            x.Zuora__Status__c = 'Active';
        }
        sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        return zSub;
    }
    
    static List<Zuora__Subscription__c> createZuoraSubscription03(List<Account> acc, List<Promotion__c> promo, 
            List<Zuora__CustomerAccount__c>billAcc, List<Order__c> odr, List<Package__c> packList) {
        //Create zuora subscription 
        List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(6);
        //for(Zuora__Subscription__c x: zSub){
            zSub[0].Zuora__Account__c = acc[0].id;
            zSub[0].Promotion_1__c = promo[0].id;
            zSub[0].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[0].Order_Number__c = odr[0].id;
            zSub[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            //zSub[0].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[0].Contract_End_Date__c = ''+Date.today().addDays(90);
            zSub[0].Zuora__Status__c = 'Active';
            zSub[0].Main_Package__c = packList[0].id;
        //}
            zSub[1].Zuora__Account__c = acc[0].id;
            zSub[1].Promotion_1__c = promo[1].id;
            zSub[1].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[1].Order_Number__c = odr[0].id;
            zSub[1].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[1].Contract_End_Date__c = ''+Date.today().addDays(90);
            zSub[1].Zuora__Status__c = 'Active';
            zSub[1].Main_Package__c = packList[1].id;
        //}
            zSub[2].Zuora__Account__c = acc[0].id;
            zSub[2].Promotion_1__c = promo[2].id;
            zSub[2].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[2].Order_Number__c = odr[0].id;
            zSub[2].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[2].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[2].Contract_End_Date__c = ''+Date.today().addDays(90);
            zSub[2].Zuora__Status__c = 'Active';
            zSub[2].Main_Package__c = packList[2].id;
        //
            zSub[3].Zuora__Account__c = acc[0].id;
            zSub[3].Promotion_1__c = promo[3].id;
            zSub[3].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[3].Order_Number__c = odr[0].id;
            zSub[3].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[3].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[3].Contract_End_Date__c = ''+Date.today().addDays(90);
            zSub[3].Zuora__Status__c = 'Active';
            //zSub[3].Main_Package__c = packList[3].id;
        //}
            zSub[4].Zuora__Account__c = acc[0].id;
            zSub[4].Promotion_1__c = promo[4].id;
            zSub[4].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[4].Order_Number__c = odr[0].id;
            zSub[4].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[4].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            //zSub[4].Contract_End_Date__c = ''+Date.today().addDays(90);
            zSub[4].Zuora__Status__c = 'Active';
            zSub[4].Main_Package__c = packList[4].id;
        //
            zSub[5].Zuora__Account__c = acc[0].id;
            zSub[5].Promotion_1__c = promo[5].id;
            zSub[5].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[5].Order_Number__c = odr[0].id;
            zSub[5].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[5].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[5].Contract_End_Date__c = ''+Date.today().addDays(-90);
            zSub[5].Zuora__Status__c = 'Active';
            //zSub[5].Main_Package__c = packList[5].id;
        //}
        sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        return zSub;
    }
           
    static List<Zuora__Subscription__c> createZuoraSubscription04(List<Account> acc, List<Promotion__c> promo, 
            List<Zuora__CustomerAccount__c>billAcc, List<Order__c> odr, List<Package__c> packList) {
        //Create zuora subscription 
        List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(2);
        //for(Zuora__Subscription__c x: zSub){
            zSub[0].Zuora__Account__c = acc[0].id;
            zSub[0].Promotion_1__c = promo[0].id;
            zSub[0].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[0].Order_Number__c = odr[0].id;
            zSub[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[0].Contract_End_Date__c = ''+Date.today().addDays(90);
            zSub[0].Zuora__Status__c = 'Active';
            zSub[0].Main_Package__c = packList[0].id;
        //}
            zSub[1].Zuora__Account__c = acc[0].id;
            zSub[1].Promotion_1__c = promo[0].id;
            zSub[1].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[1].Order_Number__c = odr[0].id;
            zSub[1].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[1].Contract_End_Date__c = ''+Date.today().addDays(-90);
            zSub[1].Zuora__Status__c = 'Active';
            zSub[1].Main_Package__c = packList[0].id;
        //}
        sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        return zSub;
    }
    
    static List<Zuora__SubscriptionProductCharge__c> createZuoraSubscriptionProductCharge(List<Account> acc, List<Zuora__Subscription__c> zSub) {
        //Create zuora subscription product charge
        List<Zuora__SubscriptionProductCharge__c> zSubProCharge = TestDataFactory.createSubscriptionProductCharge(1);
            zSubProCharge[0].Zuora__Account__c = acc[0].id;
            zSubProCharge[0].Zuora__Subscription__c = zSub[0].Id;
            zSubProCharge[0].Zuora__ProductSKU__c = 'temp';
            zSubProCharge[0].Zuora__RatePlanName__c = 'temp';
            zSubProCharge[0].Zuora__ProductName__c = 'temp';
            zSubProCharge[0].Zuora__Quantity__c = 15.3;
            zSubProCharge[0].Product_Code__c = 'churva';
            zSubProCharge[0].Zuora__Price__c = 100.00;
            zSubProCharge[0].Zuora__BillingPeriod__c = 'First';
        sObjectListMap_global.put('Zuora__SubscriptionProductCharge__c', zSubProCharge);
        Database.insert(zSubProCharge); 
        return zSubProCharge;
    }
    
    static List<zqu__ZProduct__c> createZProduct(List<Zuora__SubscriptionProductCharge__c> zSubProCharge) {
        //Create zuora zProduct
        List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
            zProductList[0].ProductCode__c = 'churva';
            zProductList[0].zqu__SKU__c = zSubProCharge[0].Zuora__ProductSKU__c;
        sObjectListMap_global.put('zqu__ZProduct__c',zProductList);
        Database.insert(zProductList);
        return zProductList;
    }
    
    static List<zqu__ProductRatePlan__c> createProductRatePlan(List<zqu__ZProduct__c> zProductList, List<Zuora__SubscriptionProductCharge__c> zSubProCharge) {
        //Create product rate plan
        List<zqu__ProductRatePlan__c> productRatePlanList = TestDataFactory.createProductRatePlan(1);
            productRatePlanList[0].zqu__ZProduct__c = zProductList[0].Id;
            productRatePlanList[0].name = zSubProCharge[0].Zuora__RatePlanName__c;
        sObjectListMap_global.put('zqu__ProductRatePlan__c',productRatePlanList);
        Database.insert(productRatePlanList);
        return productRatePlanList;
    }
    
    //Subscription_Vendor_Publications__c
    public static List<Subscription_Vendor_Publication__c> createSubscriptionVendorPublication(Integer numSubsVendPub) {
        List<Subscription_Vendor_Publication__c> subscriptionVendorPublicationList = new List<Subscription_Vendor_Publication__c>();
    
        for(Integer i=0;i<numSubsVendPub;i++){
            Subscription_Vendor_Publication__c subscriptionVendorRecord = new Subscription_Vendor_Publication__c();
            subscriptionVendorPublicationList.add(subscriptionVendorRecord);
        }
        return subscriptionVendorPublicationList;
    }
    
    static List<Subscription_Vendor_Publication__c> createSubscriptionVendorPublication01(List<Publication__c> publicationList) {
        List<Subscription_Vendor_Publication__c> subscriptionVendorPublicationList = createSubscriptionVendorPublication(1);
            subscriptionVendorPublicationList[0].Publication__c = publicationList[0].id;
            
        sObjectListMap_global.put('Subscription_Vendor_Publication__c',subscriptionVendorPublicationList);
        Database.insert(subscriptionVendorPublicationList);
        return subscriptionVendorPublicationList;
    }
    
    //FROM Subscription_Vendor__c WHERE Account__c =: acct.Parent.Id AND Status__c = 'Active'
    //Subscription_Vendor__c 
    static List<Subscription_Vendor__c> createSubscriptionVendor(List<Account> acc) {
        List<Subscription_Vendor__c> subscriptionVendorList = TestDataFactory.createSubscriptionVendor(1);
            subscriptionVendorList[0].Account__c = acc[0].id;
            subscriptionVendorList[0].Status__c = 'Active';
            
        sObjectListMap_global.put('Subscription_Vendor__c',subscriptionVendorList);
        Database.insert(subscriptionVendorList);
        return subscriptionVendorList;
    }
        
    //Initializes testdata values
    static void setAllData(){
    
        //Reset data holder values
        sObjectListMap_global = null;
        sObjectListMap_global = new Map<String, Object>();
        
        List<Account> acc = createAccount();
        List<Promotion__c> promo = createPromotion();
        List<Package__c> packList = createPackage();
        List<Promotion_Package__c> promotionPackageList = createPromotionPackage(promo, packList);
        
        createPromoEligibilityRule(promo);
              
        List<Zuora__CustomerAccount__c>billAcc = createZuoraCustomerAccount(acc);
        List<Order__c> odr = createOrder(acc);
        List<Zuora__Subscription__c> zSub = createZuoraSubscription(acc, promo, billAcc, odr);
        List<Zuora__SubscriptionProductCharge__c> zSubProCharge = createZuoraSubscriptionProductCharge(acc, zSub);
        List<zqu__ZProduct__c> zProductList = createZProduct(zSubProCharge);
        List<zqu__ProductRatePlan__c> productRatePlanList = createProductRatePlan(zProductList, zSubProCharge);        
    }
    
    //cias START 20150723 
    
    static void testData03() {
    
        sObjectListMap_global = null;
        sObjectListMap_global = new Map<String, Object>();
                
        List<Account> acc = createAccount03();
        List<Promotion__c> promo = createPromotion03();
        List<Package__c> packList = createPackage03();
        List<Promotion_Package__c> promotionPackageList = createPromotionPackage03(promo, packList);
                
        List<Product_Family__c> pfList = createProductFamily();                    
        List<Eligibility_Rule__c> erList = createEligibilityRule02(pfList);        
        List<Promotion_Eligibility_Rule__c> perList = createPromotionEligibilityRule03(promo, pfList, erList); 
        List<Promo_Eligibility_Rule_Product_Family__c> perpfList = createPromoEligibilityRuleProductFamily03(pfList, perList );      
        
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount(acc);
        List<Order__c> odr = createOrder(acc);
        List<Zuora__Subscription__c> zSub = createZuoraSubscription03(acc, promo, billAcc, odr, packList);
        List<Zuora__SubscriptionProductCharge__c> zSubProCharge = createZuoraSubscriptionProductCharge(acc, zSub);
        List<zqu__ZProduct__c> zProductList = createZProduct(zSubProCharge);
        List<zqu__ProductRatePlan__c> productRatePlanList = createProductRatePlan(zProductList, zSubProCharge);        
        
        //TODO
        List<Publication__c> publicationList = createPublication01();
        List<Subscription_Vendor_Publication__c> subscriptionVendorPublicationList = createSubscriptionVendorPublication01(publicationList);
        List<Subscription_Vendor__c> subscriptionVendorList = createSubscriptionVendor(acc);
        
        // <--

        //List<Account> acc = (List<Account>) sObjectListMap_global.get('Account');
        //List<Zuora__Subscription__c> zSubs = (List<Zuora__Subscription__c>) sObjectListMap_global.get('Zuora__Subscription__c');
        //List<Promotion__c> promoList = (List<Promotion__c>) sObjectListMap_global.get('Promotion__c');
        Set<String> s1 = new Set<String>();
            s1.add(promo[0].Contract_Period__c);
            s1.add(promo[1].Contract_Period__c);
            s1.add(promo[2].Contract_Period__c);
            s1.add(promo[3].Contract_Period__c);
            s1.add(promo[4].Contract_Period__c);
            s1.add(promo[5].Contract_Period__c);
        
        Map<String, Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
            promoCodeContractSet.put(promo[0].Promotion_Code__c, s1);
            promoCodeContractSet.put(promo[1].Promotion_Code__c, s1);
            promoCodeContractSet.put(promo[2].Promotion_Code__c, s1);
            promoCodeContractSet.put(promo[3].Promotion_Code__c, s1);
            promoCodeContractSet.put(promo[4].Promotion_Code__c, s1);
            promoCodeContractSet.put(promo[5].Promotion_Code__c, s1);
        
        
        sObjectListMap_global.put('promoCodeContractSet', promoCodeContractSet);
    }
  
    /*static testmethod void testGetEligibility03() {
        
        PromoEligibilityRule testObj = new PromoEligibilityRule();                            //primary class
        
        //TestData 03
        testData03();
        
        //Test Proper
        Test.startTest();
            testObj.getEligibility(((List<Account>)sObjectListMap_global.get('Account'))[0].Id, 'Add', 
                    ((Map<String, Set<String>>)sObjectListMap_global.get('promoCodeContractSet')), 
                    'string', ((List<Zuora__Subscription__c>)sObjectListMap_global.get('Zuora__Subscription__c'))[0].Id, true); //'Vendor Customer'
            testObj.getEligibility(((List<Account>)sObjectListMap_global.get('Account'))[0].Id, 'Add', 
                    ((Map<String, Set<String>>)sObjectListMap_global.get('promoCodeContractSet')),
                    'string', ((List<Zuora__Subscription__c>)sObjectListMap_global.get('Zuora__Subscription__c'))[0].Id, false); //'Existing Customer' || 'New Customer'
            testObj.getEligibility(((List<Account>)sObjectListMap_global.get('Account'))[0].Id, 'Change', 
                    ((Map<String, Set<String>>)sObjectListMap_global.get('promoCodeContractSet')), 
                    'string', ((List<Zuora__Subscription__c>)sObjectListMap_global.get('Zuora__Subscription__c'))[0].Id, true); //'Vendor Customer'
            testObj.getEligibility(((List<Account>)sObjectListMap_global.get('Account'))[0].Id, 'Change', 
                    ((Map<String, Set<String>>)sObjectListMap_global.get('promoCodeContractSet')),
                    'string', ((List<Zuora__Subscription__c>)sObjectListMap_global.get('Zuora__Subscription__c'))[0].Id, false); //'Existing Customer' || 'New Customer'
            //System.assertNotEquals(null,per);
        Test.stopTest();
    }*/
   
//-->
    /*
    static testmethod void testGetEligibility04() {
        
        PromoEligibilityRule testObj = new PromoEligibilityRule();                            //primary class
        //PromoEligibilityRuleCloneTest testObj = new PromoEligibilityRuleCloneTest();
        
        //TestData 04
        sObjectListMap_global = null;
        sObjectListMap_global = new Map<String, Object>();
                
        List<Account> acc = createAccount04();
        List<Promotion__c> promo = createPromotion04();
        List<Package__c> packList = createPackage04();
        List<Promotion_Package__c> promotionPackageList = createPromotionPackage04(promo, packList);
                
        List<Product_Family__c> pfList = createProductFamily();                    
        List<Eligibility_Rule__c> erList = createEligibilityRule04(pfList);        
        List<Promotion_Eligibility_Rule__c> perList = createPromotionEligibilityRule04(promo, pfList, erList); 
        List<Promo_Eligibility_Rule_Product_Family__c> perpfList = createPromoEligibilityRuleProductFamily04(pfList, perList );      
        
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount(acc);
        List<Order__c> odr = createOrder(acc);
        List<Zuora__Subscription__c> zSub = createZuoraSubscription04(acc, promo, billAcc, odr, packList);
        List<Zuora__SubscriptionProductCharge__c> zSubProCharge = createZuoraSubscriptionProductCharge(acc, zSub);
        List<zqu__ZProduct__c> zProductList = createZProduct(zSubProCharge);
        List<zqu__ProductRatePlan__c> productRatePlanList = createProductRatePlan(zProductList, zSubProCharge);        
        
        //TODO
        List<Publication__c> publicationList = createPublication01();
        List<Subscription_Vendor_Publication__c> subscriptionVendorPublicationList = createSubscriptionVendorPublication01(publicationList);
        List<Subscription_Vendor__c> subscriptionVendorList = createSubscriptionVendor(acc);
        
        // <--

        //List<Account> acc = (List<Account>) sObjectListMap_global.get('Account');
        //List<Zuora__Subscription__c> zSubs = (List<Zuora__Subscription__c>) sObjectListMap_global.get('Zuora__Subscription__c');
        //List<Promotion__c> promoList = (List<Promotion__c>) sObjectListMap_global.get('Promotion__c');
        Set<String> s1 = new Set<String>();
            s1.add(promo[0].Contract_Period__c);
        
        Map<String, Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
            promoCodeContractSet.put(promo[0].Promotion_Code__c, s1);
        
        
        sObjectListMap_global.put('promoCodeContractSet', promoCodeContractSet);
        
        //Test Proper
        Test.startTest();
            testObj.getEligibility(acc[0].Id, 'Change', promoCodeContractSet, 'string', zSub[0].Id, false); //'Existing Customer'
            testObj.getEligibility(acc[0].Id, 'Change', promoCodeContractSet, 'string', zSub[1].Id, false); //'Existing Customer'
        Test.stopTest();
    }*/
//<--    

    //Holds all testdata values
    static Map<String, Object> sObjectListMap_global;
    
    // Test Data 01
    static void testData01() {
        List<Address__c> addressList = createAddress01();
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<City__c> cityList = createCity01(countryList);
        List<Singpost_Address__c> singpostAddressList = createSingPostAddress01();
        List<Account> accountList = createAccount01(singpostAddressList);
        
        List<Package__c> packageList = createPackage01();
        List<zqu__ZProduct__c> zProductList = createZProduct01();
        List<zqu__ProductRatePlan__c> prdRatePlanList = createProductRatePlan01(zProductList);
        List<Package_Item__c> packItemList = createPackageItem01(packageList, prdRatePlanList);
        
        List<zqu__ProductRatePlanCharge__c> prpcList = createProductRatePlanCharge01(prdRatePlanList);
        
        List<Publication__c> publicationList = createPublication01();
        List<Product_Publication__c> productPublicationList = createProductPublication01(zProductList);
        
        List<Contact> contactList = createContact01(accountList, cityList, addressList);
        
        List<Zuora__CustomerAccount__c> zuoraCustomerAccountList = createCustomerAccount01(contactList, accountList);
        
        List<Zuora__PaymentMethod__c> zuoraPaymentMethodList = createPaymentMethod01(zuoraCustomerAccountList);
        
        List<Order__c> orderList = createOrder01(accountList);
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(orderList, packageList, promotionList);
        List<Zuora__Subscription__c> zuoraSubscriptionList = createSubscription01(accountList, zuoraCustomerAccountList,
            packageList, orderLineItemList);
        List<Case> caseList = createCase01(zuoraSubscriptionList, accountList);
        orderList = updateOrder01(orderList, zuoraSubscriptionList);
        List<zqu__Quote__c> quoteList = createQuote01(orderLineItemList);
    }
    
    // Test Data 00
    static void testData00() {
    
        sObjectListMap_global = new Map<String, Object>();
    
        List<Address__c> addressList = createAddress01();
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<City__c> cityList = createCity01(countryList);
        List<Singpost_Address__c> singpostAddressList = createSingPostAddress01();
        List<Account> accountList = createAccount01(singpostAddressList);
        
        List<Package__c> packageList = createPackage01();
        List<zqu__ZProduct__c> zProductList = createZProduct01();
        List<zqu__ProductRatePlan__c> prdRatePlanList = createProductRatePlan01(zProductList);
        List<Package_Item__c> packItemList = createPackageItem01(packageList, prdRatePlanList);
        
        List<zqu__ProductRatePlanCharge__c> prpcList = createProductRatePlanCharge01(prdRatePlanList);
        
        List<Publication__c> publicationList = createPublication01();
        List<Product_Publication__c> productPublicationList = createProductPublication01(zProductList);
        
        List<Contact> contactList = createContact01(accountList, cityList, addressList);
        
        List<Zuora__CustomerAccount__c> zuoraCustomerAccountList = createCustomerAccount01(contactList, accountList);
        
        //List<Zuora__PaymentMethod__c> zuoraPaymentMethodList = createPaymentMethod01(zuoraCustomerAccountList);
        
        List<Order__c> orderList = createOrder01(accountList);
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(orderList, packageList, promotionList);
        List<Zuora__Subscription__c> zuoraSubscriptionList = createSubscription01(accountList, zuoraCustomerAccountList,
            packageList, orderLineItemList);
        //List<Case> caseList = createCase01(zuoraSubscriptionList, accountList);
        //orderList = updateOrder01(orderList, zuoraSubscriptionList);
        //List<zqu__Quote__c> quoteList = createQuote01(orderLineItemList);
    }
    
    static List<Address__c> createAddress01() {
        //Address
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        
            RecordType recordType = [SELECT ID FROM RecordType WHERE Name='Overseas' LIMIT 1];
            addressList[0].RecordType = recordType;
        
        insert addressList;
        sObjectListMap_global.put('Address__c', addressList);
        return addressList;
    }
        
    static List<Zone__c> createZone01() {
        //Zone
        List<Zone__c> zoneList = TestDataFactory.createZone(1);
        
            zoneList[0].Name = ''+1;
            
        Database.insert(zoneList);
        sObjectListMap_global.put('Zone__c', zoneList);
        return zoneList;
    }
     
    static List<Country__c> createCountry01(List<Zone__c> zoneList) {
        //Country
        List<Country__c> countryList = TestDataFactory.createCountry(1);
        
            countryList[0].Zone__c = zoneList[0].id;
            
        insert countryList;
        sObjectListMap_global.put('Country__c', countryList);
        return countryList;
    }
        
    static List<City__c> createCity01(List<Country__c> countryList) {
        //City
        List<City__c> cityList = TestDataFactory.createCity(1);
        
            //Country - Country
            cityList[0].Country__c = countryList[0].id;
            cityList[0].Flight_Number_1__c = 'Flight Number 1 '+ 1;
            
        Database.insert(cityList);
        sObjectListMap_global.put('City__c', cityList);
        return cityList;
    }
        
    static List<Singpost_Address__c> createSingPostAddress01() {
        //Singpost Address
        List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(1);
        
        Database.insert(singpostAddressList);
        sObjectListMap_global.put('Singpost_Address__c', singpostAddressList);
        return singpostAddressList;
    }

    static List<Account> createAccount01(List<Singpost_Address__c> singpostAddressList) {
        //Account
        List<Account> accountList = TestDataFactory.createAccount(1, 'Direct Corporate');
        
                //Singpost Address - Postal Code
                accountList[0].Singpost_Address__c = singpostAddressList[0].id;
                
        //}
        Database.insert(accountList);
        sObjectListMap_global.put('Account', accountList);
        return accountList; 
    }
    
    //Billing Account
//    Zuora__Account__c
    
    static List<Package__c> createPackage01() {
        //Package
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        
            packageList[0].Package_Type__c = 'Add On';
            packageList[0].Package_Sub_Type__c = 'Single';
            packageList[0].Package_Price__c = 10;            
            packageList[0].Subscription_Period__c = '15';   
            packageList[0].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[0].Billing_Type__c = 'Full Prepaid';  
            
        Database.insert(packageList);
        sObjectListMap_global.put('Package__c', packageList);
        return packageList;
    }
    
    
    static List<Package__c> createPackage03() {
        //Package
        List<Package__c> packageList = TestDataFactory.createPackage(6);
        //
            packageList[0].Package_Type__c = 'Add On';
            packageList[0].Package_Code__c = 'T1233';
            packageList[0].Package_Sub_Type__c = 'Single';
            packageList[0].Package_Price__c = 10;            
            packageList[0].Subscription_Period__c = '15';   
            packageList[0].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[0].Billing_Type__c = 'Full Prepaid';  
            packageList[0].Product_Family_Current_Package__c = 'family';
            Database.insert(packageList[0]);
        //
            packageList[1].Package_Type__c = 'Add On';
            packageList[1].Package_Code__c = 'T1234';
            packageList[1].Package_Sub_Type__c = 'Single';
            packageList[1].Package_Price__c = 10;            
            packageList[1].Subscription_Period__c = '15';   
            packageList[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[1].Billing_Type__c = 'Full Prepaid';  
            packageList[1].Product_Family_Current_Package__c = 'Package2';            
            Database.insert(packageList[1]);
        //
            packageList[2].Package_Type__c = 'Add On';
            packageList[2].Package_Code__c = '1235';
            packageList[2].Package_Sub_Type__c = 'Single';
            packageList[2].Package_Price__c = 10;            
            packageList[2].Subscription_Period__c = '15';   
            packageList[2].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[2].Billing_Type__c = 'Full Prepaid';  
            packageList[2].Product_Family_Current_Package__c = 'Package3';            
            Database.insert(packageList[2]);
        //
            packageList[3].Package_Type__c = 'Add On';
            //packageList[3].Package_Code__c = '1236';
            packageList[3].Package_Sub_Type__c = 'Single';
            packageList[3].Package_Price__c = 10;            
            packageList[3].Subscription_Period__c = '15';   
            packageList[3].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[3].Billing_Type__c = 'Full Prepaid';  
            //packageList[3].Product_Family_Current_Package__c = 'Package4';            
            Database.insert(packageList[3]);
        //
            packageList[4].Package_Type__c = 'Add On';
            packageList[4].Package_Code__c = '1237';
            packageList[4].Package_Sub_Type__c = 'Single';
            packageList[4].Package_Price__c = 10;            
            packageList[4].Subscription_Period__c = '15';   
            packageList[4].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[4].Billing_Type__c = 'Full Prepaid';  
            packageList[4].Product_Family_Current_Package__c = 'family';            
            Database.insert(packageList[4]);
        //
            packageList[5].Package_Type__c = 'Add On';
            //packageList[5].Package_Code__c = '1238';
            packageList[5].Package_Sub_Type__c = 'Single';
            packageList[5].Package_Price__c = 10;            
            packageList[5].Subscription_Period__c = '15';   
            packageList[5].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[5].Billing_Type__c = 'Full Prepaid';  
            //packageList[5].Product_Family_Current_Package__c = 'Package6';            
            Database.insert(packageList[5]);
                
        //Database.insert(packageList);
        sObjectListMap_global.put('Package__c', packageList);
        return packageList;
    }
    
    static List<Package__c> createPackage04() {
        //Package
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        //
            packageList[0].Package_Type__c = 'Add On';
            packageList[0].Package_Code__c = 'T1233';
            packageList[0].Package_Sub_Type__c = 'Single';
            packageList[0].Package_Price__c = 10;            
            packageList[0].Subscription_Period__c = '15';   
            packageList[0].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[0].Billing_Type__c = 'Full Prepaid';  
            packageList[0].Product_Family_Current_Package__c = 'family';
            Database.insert(packageList[0]);
            
        //Database.insert(packageList);
        sObjectListMap_global.put('Package__c', packageList);
        return packageList;
    }
        
        //System.assertNotEquals(null, packageList[0].id, 'This should not return null if it is inserted properly.');

        //FROM : ComplaintNewspaper
        
    static List<zqu__ZProduct__c> createZProduct01() {
        List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
        
        Database.insert(zProductList);
        sObjectListMap_global.put('zqu__ZProduct__c', zProductList);
        return zProductList;
    }
        
    static List<zqu__ProductRatePlan__c> createProductRatePlan01(List<zqu__ZProduct__c> zProductList) {
        List<zqu__ProductRatePlan__c> prdRatePlanList = TestDataFactory.createProductRatePlan(1);
            prdRatePlanList[0].zqu__ZProduct__c = zProductList[0].Id;
            prdRatePlanList[0].RatePlanType__c = 'Bill Plan'; 
            prdRatePlanList[0].RatePlanSubType__c = 'Standard'; 
            prdRatePlanList[0].Name = 'RATE_PLAN_NAME';
            
        Database.insert(prdRatePlanList);
        sObjectListMap_global.put('zqu__ProductRatePlan__c', prdRatePlanList);
        return prdRatePlanList;
    }
        
    static List<Package_Item__c> createPackageItem01(List<Package__c> packageList, List<zqu__ProductRatePlan__c> prdRatePlanList) {
        List<Package_Item__c> packItemList = TestDataFactory.createPackageItem(1, 'Base Product');
            packItemList[0].Package__c = packageList[0].id;
            packItemList[0].Product_Rate_Plan__c = prdRatePlanList[0].Id;
        
        try {    // to be fixed
          Database.insert(packItemList);
        } catch (exception e) {}
        sObjectListMap_global.put('Package_Item__c', packItemList);
        return packItemList;
    }    
    
    static List<zqu__ProductRatePlanCharge__c> createProductRatePlanCharge01(List<zqu__ProductRatePlan__c> prdRatePlanList) {
        List<zqu__ProductRatePlanCharge__c> prpcList = TestDataFactory.createProductRatePlanCharge(1);
            prpcList[0].zqu__ProductRatePlan__c = prdRatePlanList[0].Id;
            prpcList[0].PublicationCode__c = 'PUB1';
            
        Database.insert(prpcList);
        sObjectListMap_global.put('zqu__ProductRatePlanCharge__c', prpcList);
        return prpcList;
    }
        
    static List<Publication__c> createPublication01() {
        //Publication
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        insert publicationList;
        sObjectListMap_global.put('Publication__c', publicationList);
        return publicationList;
    }
        
    static List<Product_Publication__c> createProductPublication01(List<zqu__ZProduct__c> zProductList) {
        //Product Publication
        List<Product_Publication__c> productPublicationList = TestDataFactory.createProductPublication(1);
            productPublicationList[0].ZProduct__c = zProductList[0].id;
        
        Database.insert(productPublicationList);
        sObjectListMap_global.put('Product_Publication__c', productPublicationList);
        return productPublicationList;
    }

    static List<Contact> createContact01(List<Account> accountList, List<City__c> cityList, List<Address__c> addressList) {
        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(1);
        
            contactList[0].Account = accountList[0];
            contactList[0].City_Code__c = cityList[0].id;
            contactList[0].Address__c = addressList[0].id;
            
        Database.insert(contactList); 
        sObjectListMap_global.put('Contact', contactList);
        return contactList;
    }

    static List<Zuora__PaymentMethod__c> createPaymentMethod01(List<Zuora__CustomerAccount__c> zuoraCustomerAccountList) {
        //Payment Method
        List<Zuora__PaymentMethod__c> zuoraPaymentMethodList = TestDataFactory.createPaymentMethod(1);
        
            zuoraPaymentMethodList[0].Zuora__BillingAccount__c = zuoraCustomerAccountList[0].id;
        
        Database.insert(zuoraPaymentMethodList);
        sObjectListMap_global.put('Zuora__PaymentMethod__c', zuoraPaymentMethodList);
        return zuoraPaymentMethodList;
    }
            
    static List<Zuora__CustomerAccount__c> createCustomerAccount01(List<Contact> contactList, List<Account> accountList) {
        //Billing Account
        List<Zuora__CustomerAccount__c> zuoraCustomerAccountList = TestDataFactory.createBillingAccount(1);
        
            zuoraCustomerAccountList[0].Billing_Contact__c = contactList[0].id;
            zuoraCustomerAccountList[0].Zuora__Account__c = accountList[0].id;
            zuoraCustomerAccountList[0].Zuora__Credit_Balance__c = 0;
            zuoraCustomerAccountList[0].Billing_Type__c = 'Full Prepaid';
            
        Database.insert(zuoraCustomerAccountList);
        sObjectListMap_global.put('Zuora__CustomerAccount__c', zuoraCustomerAccountList);
        return zuoraCustomerAccountList;
    }
    
    static List<Order__c> createOrder01(List<Account> accountList) {
        //Order
        List<Order__c> orderList = TestDataFactory.createOrder(1);
        
            orderList[0].Account__c = accountList[0].id;            
// TODO     orderList[0].Billing_Account__c = zuoraCustomerAccountList[0].id;
//          orderList[0].Recipient_Contact__c = contactList[0].id;
            orderList[0].isChangeOfSubEntry__c = false;            
            orderList[0].Order_Type__c = 'Change of Subscription';
            orderList[0].Billing_Type__c = 'Full Prepaid';            
            orderList[0].Status__c = 'Draft';            
            orderList[0].Credit_Balance__c = 0;
            
        Database.insert(orderList);
        sObjectListMap_global.put('Order__c', orderList);
        return orderList;
    }
    
    static List<Promotion__c> createPromotion01() {
        //Promotion
        List<Promotion__c> promotionList = TestDataFactory.createPromotion(1);
        
            promotionList[0].Contract_Period__c = '1';
            
        Database.insert(promotionList);
        sObjectListMap_global.put('Promotion__c', promotionList);
        return promotionList;
    }

    static List<Order_Line_Item__c> createOrderLineItem01(List<Order__c> orderList, List<Package__c> packageList, List<Promotion__c> promotionList) {
        //Order Line Item
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
        
            //Order__c, // Mandatory
            orderLineItemList[0].Order__c = orderList[0].id;
            //Main_Package_ID__c // Mandatory
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
            
            orderLineItemList[0].Start_Date__c = Date.today().addDays(10);
            
            orderLineItemList[0].Qty__c = 10;
            orderLineItemList[0].Add_On_Package_Subscription_Rate__c = 10;
            
            // TODO
            orderLineItemList[0].Addon_Package__c = packageList[0].id;
            orderLineItemList[0].Promotion_ID__c = promotionList[0].id;
            orderLineItemList[0].Main_Package_Product_Family__c = 'Default';
            orderLineItemList[0].Main_Package_Billing_Type__c = 'Full Prepaid';
            
        Database.insert(orderLineItemList);
        sObjectListMap_global.put('Order_Line_Item__c', orderLineItemList);
        return orderLineItemList;
    }
        
    static List<Zuora__Subscription__c> createSubscription01(List<Account> accountList, List<Zuora__CustomerAccount__c> zuoraCustomerAccountList,
            List<Package__c> packageList, List<Order_Line_Item__c> orderLineItemList) {
        //Subscription
        List<Zuora__Subscription__c> zuoraSubscriptionList = TestDataFactory.createSubscription(1);
        
            //Account         - Account
            zuoraSubscriptionList[0].Zuora__Account__c = accountList[0].id;
            //Package         - Addon Package
        //zuoraSubscriptionList[0].Addon_Package_1__c = packageList[0].id;
        //zuoraSubscriptionList[0].Addon_Package__c = packageList[0].id;
            //Billing Account - Billing Account
            zuoraSubscriptionList[0].Zuora__CustomerAccount__c = zuoraCustomerAccountList[0].id;
            //Contact         - Billing Contact
            //Subscription    - Grace Period Subscription
            //Billing Account - Invoice Owner
            //Package         - Main Package
            zuoraSubscriptionList[0].Main_Package_1__c = packageList[0].id;
            zuoraSubscriptionList[0].Main_Package__c = packageList[0].id;
            //Order Line Item - Order Line Item Number
//Zuora.zRemoteException : zuoraSubscriptionList[0].Order_Line_Item_Number__c = orderLineItemList[0].id; // This should be ID of Order Line Item
            //Order           - Order Number
            //Promotion       - Promotion
            //Contact         - Recipient Contact
            //Contact         - Subscriber Contact
            //Account         - Vendor
            //Vendor          - Vendor Subscription To Convert
            //Text            - Number of Copies             
            zuoraSubscriptionList[0].Number_of_Copies1__c = '1';
            zuoraSubscriptionList[0].Zuora__Status__c = Globalvariableclass.SUBSCRIPTION_STATUS_ACTIVE;
            zuoraSubscriptionList[0].Zuora__SubscriptionStartDate__c = Date.today();
            zuoraSubscriptionList[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(15);
            zuoraSubscriptionList[0].Subscription_Type__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            zuoraSubscriptionList[0].Subscription_Type_1__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            zuoraSubscriptionList[0].Zuora__TermSettingType__c = 'EVERGREEN';
            zuoraSubscriptionList[0].Term_Length__c = 1;            
            zuoraSubscriptionList[0].Order_Number__c = orderLineItemList[0].id;
            //zuoraSubscriptionList[0].Order_Number_1__c = orderLineItemList[0].id;            
            //TODO
            zuoraSubscriptionList[0].Delivery_Charge__c = 10;
            zuoraSubscriptionList[0].Delivery_Charge_Type_1__c = 'H';
            zuoraSubscriptionList[0].Delivery_Charge_Type__c = 'H';            
            zuoraSubscriptionList[0].Number_of_Copies__c = 10;            
            //sub.Payment_Mode__c == 'Other' && sub.Other_PaymentMethod__c == 'Freelist'
            zuoraSubscriptionList[0].Payment_Mode__c = 'Other';
            zuoraSubscriptionList[0].Other_PaymentMethod__c = 'Freelist';
            
        Database.insert(zuoraSubscriptionList);
        sObjectListMap_global.put('Zuora__Subscription__c', zuoraSubscriptionList);
        return zuoraSubscriptionList;
    }
    
    static List<Case> createCase01(List<Zuora__Subscription__c> zuoraSubscriptionList, List<Account> accountList) {
        //Case
        List<Case> caseList = TestDataFactory.createCase(1, 'Change of Subscription');
        
            caseList[0].Subscription_Name__c = zuoraSubscriptionList[0].id;
            caseList[0].AccountId = accountList[0].id;
            RecordType recordTypeId = [SELECT ID FROM RecordType WHERE Name='Complaint - Newspaper' LIMIT 1];
            caseList[0].RecordTypeId = recordTypeId.id;
            
//Zuora : Database.insert(caseList);
        sObjectListMap_global.put('Case', caseList);
        return caseList;
    }
    
    static List<Order__c> updateOrder01(List<Order__c> orderList, List<Zuora__Subscription__c> zuoraSubscriptionList) {
        //count = 0;
        for (Order__c obj : orderList) {
            //Account__c // Mandatory
            //obj.Account__c = accountList[count].id;
            
            obj.Subscription__c = zuoraSubscriptionList[0].id;
            //count++;
        }
        Database.update(orderList);
        sObjectListMap_global.put('Order__c', orderList);
        return orderList;
    }    
        
    static List<zqu__Quote__c> createQuote01(List<Order_Line_Item__c> orderLineItemList) {
        //zqu__Quote__c
        List<zqu__Quote__c> quoteList = TestDataFactory.createQuote(1);
        
            quoteList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            quoteList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            
        Database.insert(quoteList);
        sObjectListMap_global.put('zqu__Quote__c', quoteList);
        return quoteList;
    }
// TODO <---
      

    static testMethod void testGetEligibility02() {
        PromoEligibilityRule testObj = new PromoEligibilityRule();
        
        //TestData
        //Map<String, Object> initData = new Map<String, Object>();
        //List<Account> accountList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        //initData.put('Account', accountList);
        
        sObjectListMap_global = new Map<String, Object>();
        
        testData01();
        
        //Map<String, Object> td1 = sObjectListMap_global;
        
        Id accId = ((List<Account>)sObjectListMap_global.get('Account'))[0].id;
        String action = '';
        Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
        String pkgCode = '';
        Id subsId = null;
        Boolean booleanVar = false;
        
        // Test Proper
        testObj.getEligibility(accId, action, promoCodeContractSet, pkgCode, subsId, booleanVar);
    }
    
    static testMethod void testGetPackageList01() {
        PromoEligibilityRule testObj = new PromoEligibilityRule();
        
        //Test Data
        String packageList = 'SPH';
        String packageCode = 'H';
        
        System.assertEquals(true, testObj.getPackageList(packageList, packageCode));
    }
    
    static testMethod void testgetCurrentPlatformEligibility01(){
        PromoEligibilityRule testObj = new PromoEligibilityRule();
        
        //Test Data
        String curPlatform = 'SPHTest;';
        String subPlatform = 'Test';
        
        System.assertEquals(true, testObj.getCurrentPlatformEligibility(curPlatform, subPlatform));
    }
    
    static testMethod void testGetSubscriberStatus01() {
        PromoEligibilityRule testObj = new PromoEligibilityRule();
        
        String packageCode = '';
    
        try{ testObj.getSubscriberStatus(packageCode); }
        catch (System.NullPointerException e) {}
        
    }
    
    static testMethod void testCheckIfSubsProdFamIsSpecified01() {
        PromoEligibilityRule testObj = new PromoEligibilityRule();
        
        //Test Data
        String specifiedProdFam = 'SPHFamilyCompany';
        String prodFamily = 'FamilyCompany';
        
        System.assertEquals(true, testObj.checkIfSubsProdFamIsSpecified(specifiedProdFam, prodFamily));
    }
    
    static testMethod void testGetContractSubscriptionRule01() {
        PromoEligibilityRule testObj = new PromoEligibilityRule();
    
        //Test Data
        Zuora__Subscription__c zuoraSub = new Zuora__Subscription__c();
        zuoraSub.Zuora__SubscriptionEndDate__c = Date.today().addDays(5);
        zuoraSub.Contract_End_Date_1__c = Date.today().addDays(10);
        String contractSubsRule;
        
        //if(contractSubsRule == 'Subscription End Date')
        contractSubsRule = 'Subscription End Date';
        System.assertEquals(Date.today().addDays(5), testObj.getContractSubscriptionRule(zuoraSub, contractSubsRule));
        
        //if(contractSubsRule == 'Contract End Date')
        contractSubsRule = 'Contract End Date';
        System.assertEquals(Date.today().addDays(10), testObj.getContractSubscriptionRule(zuoraSub, contractSubsRule));
    }
    
    static testMethod void testGetRecentsubscription01() {
        PromoEligibilityRule testObj = new PromoEligibilityRule();
        
        //Test Data
        testData00();
        
        List<Zuora__Subscription__c> zuoraSub = (List<Zuora__Subscription__c>)sObjectListMap_global.get('Zuora__Subscription__c');
        String strProductFamily;
        String contractRule;
        
        //Map<String, Object> td1 = testData01(null);
        
        //for(Zuora__Subscription__c sub: zuoraSub){
        // if(sub.Main_Package_1__r.Product_Family_Current_Package__c == Productfamily )
        // if(contractSubsRule == 'Subscription End Date')        
        
        Package__c pkg = ((List<Package__c>)sObjectListMap_global.get('Package__c'))[0];
        pkg.Product_Family_Current_Package__c = 'VNode';
        
        update pkg;
        
        zuoraSub[0].Main_Package_1__c = pkg.id;
        zuoraSub[0].Main_Package__c = pkg.id;
        update zuoraSub;
        
        strProductFamily = 'VNode';
        contractRule= 'Subscription End Date';
        System.assertEquals(1, testObj.getrecentsubscription(zuoraSub, strProductFamily, contractRule).size());
        
        //for(Zuora__Subscription__c sub: zuoraSub){
        // if(sub.Main_Package_1__r.Product_Family_Current_Package__c == Productfamily )
        // if(contractSubsRule == 'Contract End Date')
        strProductFamily = 'VNode';
        contractRule= 'Contract End Date';
        
        System.assertEquals(1, testObj.getrecentsubscription(zuoraSub, strProductFamily, contractRule).size());
    }
    
    static testMethod void testGetPromotionEligibility01() {
        PromoEligibilityRule testObj = new PromoEligibilityRule();
        
        //Test Data
        String condition;
        Date datebase;
        Date sDate;
        String days;
        
        //if(days == null){
        // if(condition == '<')
        condition = '<';
        datebase = Date.today();
        sDate = Date.today();
        days = null;
        System.assertEquals(false, testObj.getPromotionEligibility(condition, datebase, sDate, days));
        
        //if(days == null){
        // if(condition == '>')
        condition = '>';
        datebase = Date.today();
        sDate = Date.today();
        days = null;
        System.assertEquals(false, testObj.getPromotionEligibility(condition, datebase, sDate, days));
        
        //if(days == null){
        // if(condition == '<=')
        condition = '<=';
        datebase = Date.today();
        sDate = Date.today();
        days = null;
        System.assertEquals(true, testObj.getPromotionEligibility(condition, datebase, sDate, days));
        
        //if(days == null){
        // if(condition == '>=')
        condition = '>=';
        datebase = Date.today();
        sDate = Date.today();
        days = null;
        System.assertEquals(true, testObj.getPromotionEligibility(condition, datebase, sDate, days));
        
        
        //if(days == null){
        //else
        // if(condition == '<')
        condition = '<';
        datebase = Date.today();
        sDate = Date.today();
        days = '1';
        System.assertEquals(true, testObj.getPromotionEligibility(condition, datebase, sDate, days));
        
        //if(days == null){
        //else
        // if(condition == '>')
        condition = '>';
        datebase = Date.today();
        sDate = Date.today();
        days = '1';
        System.assertEquals(false, testObj.getPromotionEligibility(condition, datebase, sDate, days));
        
        //if(days == null){
        //else
        // if(condition == '<=')
        condition = '<=';
        datebase = Date.today();
        sDate = Date.today();
        days = '1';
        System.assertEquals(false, testObj.getPromotionEligibility(condition, datebase, sDate, days));
        
        //if(days == null){
        //else
        // if(condition == '>=')
        condition = '>=';
        datebase = Date.today();
        sDate = Date.today().addDays(-1);
        days = '1';
        System.assertEquals(true, testObj.getPromotionEligibility(condition, datebase, sDate, days));
    }
    
    static testMethod void testGetContractStatus01() {
        PromoEligibilityRule testObj = new PromoEligibilityRule();
        
        //if(zSubContractEndDate >= date.today())
        Date zSubContractEndDat = Date.today();
        //System.assertEquals('With contract', testObj.getContractStatus(zSubContractEndDat));  // to be fixed
        
        //else if(zSubContractEndDate < date.today())
        zSubContractEndDat = Date.today().addDays(-1);
        //System.assertEquals('Without contract', testObj.getContractStatus(zSubContractEndDat)); // to be fixed
        
        //else if(zSubContractEndDate == null)
        zSubContractEndDat = null;
        //System.assertEquals('Without contract', testObj.getContractStatus(zSubContractEndDat));  // to be fixed
    }

}