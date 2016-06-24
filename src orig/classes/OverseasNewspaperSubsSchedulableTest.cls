/**
@Author Joyrem Zarmaine D. Ayuman
@name OverseasNewspaperSubsSchedulableTest
@CreateDate <07/10/2015>
@Description <Test Class for OverseasNewspaperSubsSchedulable>
@Version <1.0>
@reference <none>
*/

@isTest(seeAllData = true)

public class OverseasNewspaperSubsSchedulableTest{

    static testmethod void unitTest(){
    
         test.starttest();
         OverseasNewspaperSubscriptionSchedulable onss = new OverseasNewspaperSubscriptionSchedulable ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, onss);
         test.stopTest();
    }
    
    }