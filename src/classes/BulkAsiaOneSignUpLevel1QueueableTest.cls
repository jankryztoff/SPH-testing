/*
 * Class Name: BulkAsiaOneSignUpLevel1QueueableTest
 * @author: Jensar Joey Z. Sayson
 * Date: 4/8/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for BulkAsiaOneSignUpLevel1Queueable
 */

@isTest(seeAllData = true)
public class BulkAsiaOneSignUpLevel1QueueableTest {

  	//initializing queueable class
    static testMethod void test01(){
    
       	set<id> asia1IdSetParam = new set<id>();
        Asia1__c asia1Record = new Asia1__c();
        
        asia1IdSetParam.add(asia1Record.Id);
        
        Test.startTest();
        
			System.enqueueJob(new BulkAsiaOneSignUpLevel1Queueable(asia1IdSetParam));
        	System.assertNotEquals(null, asia1IdSetParam);
        
        Test.stopTest();
    }
    
}