@isTest(SeeAllData = true)
private class AsiaOneServiceTest{
    static testmethod void unitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
        Map<String, String> reqMap = new Map<String, String>();
        reqMap.put('Id','213213');
        String reqStr = '';
        AsiaOneServiceRequestVO bsr = new AsiaOneServiceRequestVO();
        bsr.setAsia1APIFunction('Test');
        bsr.setReqValueObject(reqMap);
        AsiaOneFacade bsf = new AsiaOneFacade();
        bsf.delegateAsiaOneCall(bsr);
        Test.stopTest();
    }

}