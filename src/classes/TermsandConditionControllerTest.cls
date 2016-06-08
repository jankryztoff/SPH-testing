/*
 * Class Name: TermsandConditionControllerTest
 * @author: Rom Edison Reyes
 * Date: 4/14/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for TermsandConditionController

 */

@isTest(seeAllData = true)
public class TermsandConditionControllerTest {
    static testMethod void testTermsAndConditionPage(){
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Name = 'Promotion Name';
        promo.Terms_Conditions_Summary__c = 'Terms and Conditions Summary';
        promo.Terms_Conditions_Detail__c = 'Terms and Conditions Details';
        promo.Contract_Period__c = '12';
        insert promo;
        
        Id promoId = promo.id;
        PageReference pageRef = Page.TermsandCondition;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',promoId);
        
        test.starttest();
        TermsandConditionController terms = new TermsandConditionController();
        test.stoptest();
    }
}