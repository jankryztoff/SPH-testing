/*
* Class Name: <DeleteProductFamiliesClass_Test>
* @author: Reszel Garrie Pineda
* Date: 2/05/2015
* Requirement/Project Name: <SPH>
* @description: Test class for DeleteProductFamiliesClass
*/
@isTest
private class DeleteProductFamiliesClass_Test {
    
    /* @description: This method checks DeleteProductFamiliesClass method */
    static testmethod void testDeleteProductFamiliesClass()
    {
        //test data creation
        //Creation of Promotion
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
        //end of test data creation
        
        //start of test
        Test.startTest();
        DeleteProductFamiliesClass dpfc = new DeleteProductFamiliesClass();
        dpfc.DeleteProductFamilies(perList);
        System.assertEquals(er.Name, 'foo');
        Test.stopTest();
        //end of test      
        
    }//end of testDeleteProductFamiliesClass()
}//end of DeleteProductFamiliesClassTest