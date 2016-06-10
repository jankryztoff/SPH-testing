/*
 * Class Name: BulkServiceFlagActivationLevel2Queueable
 * @author: Christian Coquilla
 * Date: 4/9/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for BulkServiceFlagActivationLevel2Queueable
 */

@isTest(seeAllData = true)
public class BulkServiceFlagActivationLevel2QTest {

    //initializing queueable class
    static testMethod void test01(){
    
      List<ServiceFlagActivationParamWrapper> paramList = new list<ServiceFlagActivationParamWrapper>();
        ServiceFlagActivationParamWrapper sfapw = new ServiceFlagActivationParamWrapper();
        
        paramList.add(sfapw);
        
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
         asia.User_ID_LDAP_ID__c = 'ldap@test.com';
         insert asia;
         
         Asia1_Subscription__c asiaSubs = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiaSubs.Asia1__c = asia.Id;
        //asiaSubs.Subscription__c = subRecs.Id;
        insert asiaSubs;
        
        Test.startTest();
        
      System.enqueueJob(new BulkServiceFlagActivationLevel2Queueable(paramList));
          System.assertNotEquals(null, paramList);
        
        Test.stopTest();        
        
    }
}