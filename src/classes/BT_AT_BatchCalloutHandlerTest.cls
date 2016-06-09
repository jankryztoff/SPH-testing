/*
* Class Name: <BT_AT_BatchCalloutHandlerTest>
* @author: Emmanuel Flores
* Date: 10/22/2015
* Requirement/Project Name: <SPH>
* @description: Test class for BT_AT_BatchCalloutHandler
*/
@isTest (seeAllData=false)
private class BT_AT_BatchCalloutHandlerTest{

    static testmethod void unitTest1() { 
        try{
        BT_AT_BatchCalloutHandler batch = new BT_AT_BatchCalloutHandler('test');
        //ID batchprocessid = Database.executeBatch(batch,200);
        //System.assertNotEquals(null, batchprocessid);
        }catch(exception e){}
    }
        
}