//*********************************************************************************************
//
// Author: Glen Anthony Abanes Cubinar
// Date: 1/20/2015
// Description: Test Class for BT_AB_ESH1003DX_ESHOPPackage
//
//*********************************************************************************************

@isTest
Private Class Test_BT_AB_ESH1003DX_ESHOPPackage {

    Public Static testMethod void Test_BT_AB_ESH1003DX_ESHOPPackage() {
    
        List<BA_INT_DATA_POOL__c> lDataPool = new List<BA_INT_DATA_POOL__c>();
        
        //GAAC Insert INT_DATA_POOL
        BA_INT_DATA_POOL__c dataPool = new BA_INT_DATA_POOL__c();
        dataPool.Name = 'ESH1003DX';
        dataPool.job_id__c = 'ESH1003DX';
        dataPool.group_id__c = 'Master';
        dataPool.run_for_date__c = System.Today();
        dataPool.export_data__c = 'H,2014-11-14 12:43:01';
        dataPool.insert_time__c = System.Now();
        
        lDataPool.add(dataPool);
        Insert lDataPool ;
    try{
        Test.StartTest();
        
            //GAAC Call the Batch
            BT_AB_ESH1003DX_ESHOPPackage esh1003dx = new BT_AB_ESH1003DX_ESHOPPackage('ESH1003DX');
            //ID batchprocessid = database.executeBatch(esh1003dx ,200);
            Database.executeBatch(esh1003dx );
        
        Test.StopTest();
    }catch(exception e){}
    }
}