/*
 * Class Name: RenewalOfSub_GracePeriodBatchTest
 * @author: Jensar Joey Z. Sayson
 * Date: 4/8/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for RenewalOfSub_GracePeriodBatch
 */

@isTest(seeAllData = true)
public class BulkServiceFlagActivationLevel1QTest {

    //initializing queueable class
    static testMethod void test01(){
    
    	List<ServiceFlagActivationParamWrapper> paramList = new list<ServiceFlagActivationParamWrapper>();
        ServiceFlagActivationParamWrapper sfapw = new ServiceFlagActivationParamWrapper();
        
        paramList.add(sfapw);
        
        Test.startTest();
        
			System.enqueueJob(new BulkServiceFlagActivationLevel1Queueable(paramList));
        	System.assertNotEquals(null, paramList);
        
        Test.stopTest();        
        
    }
}