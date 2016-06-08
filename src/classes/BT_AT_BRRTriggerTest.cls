@isTest
public class BT_AT_BRRTriggerTest { 


static testmethod void test_trigger(){


    BT_CO_Batch_Run_Request__c b = new BT_CO_Batch_Run_Request__c();
    
    b.Batch_Run_Date__c = System.Today();
    b.End_Time__c = System.Today();
    b.Interface_ID__c = '123456';
    b.Start_Time__c = System.Today();
   
    
    insert b;
    update b;
    
    }
   
    }