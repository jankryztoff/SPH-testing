@isTest (Seealldata = TRUE)
private class BT_AB_VSS089DX_ExportZoneToPostalTest {
     // prepares the data needed for execution
    static testmethod void unitTest1(){
       
        BA_INT_DATA_POOL__c ezp = new BA_INT_DATA_POOL__c();
        ezp.job_id__c = '1';
        ezp.group_id__c = 'Detail';
        ezp.run_for_date__c = Date.today();      
        ezp.insert_time__c = DateTime.now(); 
        ezp.export_data__c = '0000';   
        
        insert ezp;
        
    Test.StartTest();
    BT_AB_VSS089DX_ExportZoneToPostal batch = new BT_AB_VSS089DX_ExportZoneToPostal();
    ID batchprocessid = Database.executeBatch(batch,200);
    Test.StopTest();
        
        
        
        
        
    }//end of unitTest1
    
}