/**
 * Class Name: SP_TempStopResetCounterTest
 * @author: April Veloso
 * Date: 4/7/2016
 * Requirement/Project Name: Singapore Press Holdings
 * @ test class for SP_TempStopResetCounter
 * Edited by: April Veloso <04/07/2016>
 */


@isTest(Seealldata=true)
public class SP_TempStopResetCounterTest {
    static testMethod void test_SP_TempStopResetCounter(){
             test.startTest();
                 SP_TempStopResetCounter batch = new SP_TempStopResetCounter();
                 //ID batchprocessid = Database.executeBatch(batch, 200);
            test.stopTest(); 
    }
    static testMethod void test_SP_TempStopResetCounter2(){
             Date dateToday =  date.today();
             test.startTest();
                 SP_TempStopResetCounter batch = new SP_TempStopResetCounter(dateToday);
                 //ID batchprocessid = Database.executeBatch(batch, 200);
            test.stopTest(); 
    }
    static testMethod void test_SP_TempStopResetCounter3(){
             Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
             database.insert(acc);
             
             Set<Id> setId = new Set<Id>();
             setId.add(acc.id);
             
             test.startTest();
                 SP_TempStopResetCounter batch = new SP_TempStopResetCounter(setId);
                 ID batchprocessid = Database.executeBatch(batch, 200);
            test.stopTest(); 
    }
     static testMethod void test_SP_TempStopResetCounter4(){
             Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
             database.insert(acc);
             
             Set<String> StringiD = new Set<String>();
             StringiD.add(''+acc.id);
             
             test.startTest();
                 SP_TempStopResetCounter batch = new SP_TempStopResetCounter(StringiD );
                 ID batchprocessid = Database.executeBatch(batch, 200);
            test.stopTest(); 
    }
}