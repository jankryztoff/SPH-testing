@isTest
private class StopSubOrderEntryDirectTest {
    static testmethod void testHandler(){
        
        TestDataFactory.createAccount(1,'Vendor Subscriber');
            
            
        Test.StartTest();
        /********************************************************************************************************/
        Test.StopTest(); //Indicates End of Coverage of Test Method
    }
}