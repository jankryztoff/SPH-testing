/**
 * Class Name: <DataPurgeBatchTest>
 * @author: <Flores, Emmanuel>
 * Date: <7/2/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for DataPurgeBatch>
 */
@isTest
private class DataPurgeBatchTest {
    
    /*static testmethod void unitTest() {
        
        List<Address_Assignment__c> aa1 = new List<Address_Assignment__c>();
        for(Address_Assignment__c addressAss : aa1){
                addressAss.Effective_Date__c = date.today();
                addressAss.Status__c = 'Active';
                addressAss.End_Date__c =  date.today().addDays(2);
                addressAss.Active__c = False;
        }
        insert aa1;
        
        String query = 'SELECT Account_Name__c, Account_Number__c, Customer_Name__c FROM Order__c WHERE isWaive__c =TRUE';
        DataPurgeBatch batch = new DataPurgeBatch(query);
        //ID batchprocessid = Database.executeBatch(batch,10);
        //System.assertNotEquals(null, batchprocessid);
        Database.BatchableContext bc;
        batch.start(bc);
        try{
        batch.execute(bc, aa1);
        batch.finish(bc);
        }catch(exception e){
            
        }
    }
    */
    
    static testmethod void unitTest2() {

        List<Publication__c> pubList = TestDataFactory.createPublication(1);
        insert pubList;
        String query = 'SELECT Name, Publication_Code__c, Published_Days__c, Publication_Type__c, Earliest_Start_Date__c FROM Publication__c LIMIT 1';
        
        Test.startTest();
        DataPurgeBatch batch = new DataPurgeBatch(query);
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
        //Database.BatchableContext bc;
        //batch.start(bc);
    }
 }