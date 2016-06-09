/**
 * Class Name: <SP_PopConsolidationBatchMainTest>
 * @author: <Marjorie Gaelo>
 * Date: <2/26/2015>
 * Requirement/Project Name: <SPH>
 * @description: Test Class for SP_PopConsolidationBatchMain
 */
 
 @isTest //(Seealldata = TRUE)
private class SP_PopConsolidationBatchMainTest{
    static testMethod void TestPopConBatchMain(){
    
    Id jobId; 
    
    Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = '2';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pub.Published_Days__c = 'YYYYYYY';
        pub.Frequency_Code__c = 'W';
        pub.Public_Holiday_Weekend_Pub_Indicator__c = TRUE;
        pub.Public_Holiday_Weekday_Pub_Indicator__c = FALSE;
        pub.Publication_Next_Start_Date__c = date.today();
        insert pub;
        
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductCode__c = 'BI';
        insert zProduct;
        
    Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = pub.id;
        //prodPub.Product_Code__c = zProduct.id;
        Test.StartTest();
        insert prodPub;
        Test.StopTest();    
    /*Test.StartTest();
    SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(jobID); 
    ID batchprocessid = Database.executeBatch(batch, 200);
    Test.StopTest();*/
        
    }
}