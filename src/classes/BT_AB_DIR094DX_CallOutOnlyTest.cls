/**
 * Class Name: <BT_AB_DIR094DX_CallOutOnlyTest>
 * @author: <Thayne Recato>
 * Date: 2/05/2015
 * Requirement/Project Name: <SPH>
 * @description<Test Class for BT_AB_DIR094DX_CallOutOnly>
*/
@isTest (Seealldata = TRUE)
private class BT_AB_DIR094DX_CallOutOnlyTest {
    
    /*@description: This test method execute the base class that populates 
     * BA_INT_DATA_POOL__c for DIR094DX batch job. Used together 
     * with BT_AS_DIR094DX_VendorPerformanceInfo Schedulable */
    static testmethod void testCallOutOnly() {
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());   
        
        Test.startTest();
        BT_AB_DIR094DX_CallOutOnly call = new BT_AB_DIR094DX_CallOutOnly();
        ID batchprocessid = Database.executeBatch(call, 200);
        System.assertNotEquals(NULL, batchprocessid);
        Test.stopTest();
    }
}