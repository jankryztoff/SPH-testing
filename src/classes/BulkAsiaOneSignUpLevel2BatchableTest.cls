/*
 * Class Name: BulkAsiaOneSignUpLevel2BatchableTest
 * @author: Reyes, Rom Edison C.
 * Date: 04/08/2016
 * Project/Requirement: SPH
 * Description: Test Class for BulkAsiaOneSignUpLevel2Batchable
 */ 
@isTest(SeeAllData = true)
public with sharing class BulkAsiaOneSignUpLevel2BatchableTest {

        static testmethod void testSingleBatchJobScheduler(){
            
            Asia1__c asia1 = new Asia1__c ();
            asia1.User_ID_LDAP_ID__c = 'ldap@test.com';
            insert asia1;
            
            Set<id> asia1IdSet = new Set<id>();
            asia1IdSet.add(asia1.id);
            
            BulkAsiaOneSignUpLevel2Batchable bulkA1 = new BulkAsiaOneSignUpLevel2Batchable(asia1IdSet);

            ID batchprocessid = Database.executeBatch(bulkA1 ,200);
            System.assertNotEquals(null, batchprocessid);
        }
}