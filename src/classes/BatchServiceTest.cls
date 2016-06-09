@isTest
private class BatchServiceTest{
    static testmethod void unitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
        Map<String, String> reqMap = new Map<String, String>();
        String reqStr = '';
        BatchServiceRequestVO bsr = new BatchServiceRequestVO();
        BatchServiceFacade bsf = new BatchServiceFacade();
        try {
            bsf.delegateBatchCall(bsr);
        }
        catch(Exception e) {
            
        }
        Test.stopTest();
    }
    static testmethod void failUnitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockFailTest());
        Map<String, String> reqMap = new Map<String, String>();
        String reqStr = '';
        BatchServiceRequestVO bsr = new BatchServiceRequestVO();
        BatchServiceFacade bsf = new BatchServiceFacade();
        try {
            bsf.delegateBatchCall(bsr);
        }
        catch(Exception e) {
            
        }
        Test.stopTest();
    }

}