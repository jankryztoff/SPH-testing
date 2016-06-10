@isTest(seeAllData=True)
private class TempStop_CreditBalanceBatchTest{

    static testMethod void testTempStop_CalculateCreditBalanceBatch(){
    
    //insert test data
    
        Temp_Stop__c tempStopRecord = new Temp_Stop__c();
        tempStopRecord.Temp_Stop_Date__c = Date.today();
       
        insert tempStopRecord;
    
        Database.executebatch(new TempStop_CreditBalanceBatch());
    
    
    }//END testMethod testTempStop_CalculateCreditBalanceBatch()
    
    

}//END TempStop_CalculateCreditBalanceBatchTest