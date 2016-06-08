@isTest (Seealldata = TRUE)
private class BT_AB_SAP072DX_AdjustmentIntToSAPTest {

    static testmethod void unitTest1(){
        // this prepares the data needed for execution
        BA_INT_DATA_POOL__c bac = new BA_INT_DATA_POOL__c();
        bac.Name = 'SAP072DX Sample Source';
        bac.job_id__c = '1';
        bac.group_id__c = 'Master';
        bac.run_for_date__c = Date.today();      
        bac.insert_time__c = DateTime.now(); 
        insert bac;
   
    Test.StartTest();
    BT_AB_SAP072DX_AdjustmentInterfaceToSAP batch = new BT_AB_SAP072DX_AdjustmentInterfaceToSAP();
    ID batchprocessid = Database.executeBatch(batch,200);
    Test.StopTest();
            }//end of unitTest1
    
}