/**
* Class Name: StopSubCaseOfferControllerTest
* @author: Jensar Joey Z. Sayson
* Date: 3/5/2016
* Requirement/Project Name: <SPH>
* @description Test Class for StopSubCaseOfferController
* 
*/

@isTest(seeAllData = true)
public class StopSubCaseOfferControllerTest{

    static List<Case> caseList = null;
    static Package__c packageRec = null;
    static Promotion__c promotion = null;
    static Promotion_Package__c promotionPackage = null;

    //initializing all methods
    static testMethod void test01(){
    
        mockData01();
        
        PageReference pageRef = Page.StopSubEditPage_Case;
            pageRef.getParameters().put('id', String.valueOf(caseList[0].Id));
            Test.setCurrentPage(pageRef);
            
        StopSubCaseOfferController sscoc = new StopSubCaseOfferController();
            sscoc.searchText = 'Test Promotion';
            sscoc.searchBillingType = 'Full Prepaid';
            sscoc.executeSearch();
            sscoc.caseView();
            sscoc.xsetPromotion();
            sscoc.setPackage();
            sscoc.setAddOn();
            sscoc.doCancel();
            sscoc.cancelEditCase();
            sscoc.redirectToOfferPromotion();
            sscoc.redirectToOfferPackage();
            sscoc.redirectToOfferAddOn();
        
        Test.startTest();   
        
            sscoc.packId = ''+ packageRec.id;
            sscoc.getSelectedPackage();
            
            sscoc.addId = ''+ packageRec.id;
            sscoc.getSelectedAddOn();
            
            sscoc.promoId = ''+ promotion.id;
            sscoc.getSelectedPromotion();
            
            sscoc.getPackageRecords();
            
            sscoc.getAddOnRecord();
            
            System.assertNotEquals(null, sscoc);
            
        Test.stopTest();
    }
    
    //run retrieveRelatedPackages
    static testMethod void test02(){
    
        mockData01();        
        StopSubCaseOfferController.retrieveRelatedPackages(''+ promotion.id,''+ packageRec.Billing_Type__c);

        Test.startTest();
            System.assertNotEquals(null, promotion);
        Test.stopTest();
          
    }
    
    //mock data
    static void mockData01(){
        
        
        
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Database.insert(caseList);
        
        packageRec = new Package__c(Name='Test Package', Package_Type__c='Base',
                                        Subscription_Type__c = 'Termed', Package_Code__c = 'PackageCode',
                                        Effective_Start_Date__c = date.today(), Effective_End_Date__c = date.today()+100, 
                                        Subscription_Period__c = '18', Billing_Type__c = 'Full Prepaid');
        Database.insert(packageRec);
        
        promotion = new Promotion__c(Name='Test Promotion', Promotion_Code__c='PC', 
                                        Contract__c='Yes', Effective_End_Date__c=date.today()+100, 
                                        Effective_Start_Date__c=date.today(), Contract_Period__c='12');    
        Database.insert(promotion);
        
        promotionPackage = new Promotion_Package__c();
            promotionPackage.Promotion__c = promotion.id;
            promotionPackage.Package_Name__c = packageRec.id;
        Database.insert(promotionPackage);
    }
}