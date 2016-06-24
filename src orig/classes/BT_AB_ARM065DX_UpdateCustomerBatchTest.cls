@isTest (Seealldata = TRUE)
public class BT_AB_ARM065DX_UpdateCustomerBatchTest{

    static testmethod void unitTest1(){
    
        Test.startTest(); 
        BT_AB_ARM065DX_UpdateCustomerBatch ucb = new BT_AB_ARM065DX_UpdateCustomerBatch();
        //ID batchprocessid = Database.executeBatch(ucb, 200);
        Test.stopTest();

    }    
}