/*
* Class Name: <DeleteProductFamiliesClass_Test>
* @author: Reszel Garrie Pineda
* Date: 2/05/2015
* Modified by: Ana Fe Dumangas
* Modified Date: 6/23/15
* Requirement/Project Name: <SPH>
* @description: Test class for DeleteProductFamiliesClass
*/
@isTest
private class DeleteProductFamiliesClassTest {
    
    /* @description: This method checks DeleteProductFamiliesClass method */
    static testmethod void testDeleteProductFamiliesClass()
    { 
        //test data creation
        //Creation of Promotion

        String perId;            
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Name = 'prom';
        prom.Promotion_Code__c = 'promc';
        prom.Effective_Start_Date__c = date.today();
        prom.Effective_End_Date__c = date.today().addDays(30);
        prom.Contract__c = 'Yes';
        prom.Contract_Period__c = '15';
        database.insert(prom);
        
        //Creation of Eligibility rule
        Eligibility_Rule__c er = TestDataFactory.createEligibilityRule(1)[0];        
        er.Name= 'foo';
        er.Customer_Status__c = 'New customer';
        er.Action__c = 'Add';
        er.Effective_Start_Date__c = date.today();
        er.Effective_End_Date__c = date.today().addDays(30);
        database.insert(er);
        
        //Creation of List of Promotion_Eligibility_Rule__c
        List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(1);
        perList[0].Eligibility_Rule__c = er.Id;
        perList[0].Package_List__c = '123';
        perList[0].Promotion__c = prom.Id;        
        database.insert(perList);
        system.assert(perList.size()>0);
        
        //Creation of List of Promo_Eligibility_Rule_Product_Family__c (modified by ana dumangas)
        Promo_Eligibility_Rule_Product_Family__c perdf = new Promo_Eligibility_Rule_Product_Family__c();
        perdf.Promotion_Eligibility_Rule__c = perList[0].Id;
        perdf.Name = 'Sample';  
        Product_Family__c ProdFamSample = new Product_Family__c(Product_Family__c='Product Family Sample');
        database.insert(ProdFamSample);
        perdf.Product_Family__c= ProdFamSample.Id;       
        database.insert(perdf);
        
        System.assert(perdf!=null);
              
        //end of test data creation
        
        //start of test
        Test.startTest();
        DeleteProductFamiliesClass dpfc = new DeleteProductFamiliesClass();
        dpfc.DeleteProductFamilies(perList);
        System.assertEquals(er.Name, 'foo');   
        
        Promo_Eligibility_Rule_Product_Family__c perdf1 = new Promo_Eligibility_Rule_Product_Family__c();
        perdf1.Promotion_Eligibility_Rule__c = perList[0].Id;
        perdf1.Name = 'Sample';          
        perdf1.Product_Family__c= ProdFamSample.Id;   
        database.insert(perdf1);    
                        
        List<Promo_Eligibility_Rule_Product_Family__c> perpfStoDelete = [SELECT Name, Promotion_Eligibility_Rule__c FROM Promo_Eligibility_Rule_Product_Family__c WHERE Promotion_Eligibility_Rule__c =:perList[0].Id];          
        System.assert(!perpfStoDelete.isEmpty());   
        dpfc.DeleteProductFamilies(perList);
        List<Promo_Eligibility_Rule_Product_Family__c> perpfStoDeleteAfterCall = [SELECT Name, Promotion_Eligibility_Rule__c FROM Promo_Eligibility_Rule_Product_Family__c WHERE Promotion_Eligibility_Rule__c =:perList[0].Id]; 
        System.assert(perpfStoDeleteAfterCall.isEmpty());   
        
        Test.stopTest();
        //end of test      
        
    }//end of testDeleteProductFamiliesClass()
}//end of DeleteProductFamiliesClassTest