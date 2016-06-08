/*
* Class Name: <AsiaOneFacadTest>
* @author: Reszel Garrie Pineda
* Date: 2/05/2015
* Requirement/Project Name: <SPH>
* @description: Test class for AsiaOneFacade
*/
@isTest (seeAllData = true)           
private class  AsiaOneFacadeTest{
    
    /* @description: This method checks AsiaOneServiceResponsetVO method if success */
    static testmethod void testSuccess()
    {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());       
        AsiaOneServiceRequestVO aosr = new AsiaOneServiceRequestVO();        
        AsiaOneFacade aof = new AsiaOneFacade();
        AsiaOneServiceResponsetVO actualResponse = aof.delegateAsiaOneCall(aosr);            
    
    // Get TestData
        BatchServiceFacadeMockTest testData = new BatchServiceFacadeMockTest();
        HTTPResponse res = testData.respond(new HttpRequest());
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

        System.assertEquals(respMap.get('respValueObject'), actualResponse.reqValueObject);

        Test.stopTest();
        
    }//end of testSuccess()
    
    /* @description: This method checks AsiaOneServiceResponsetVO method if fail */
    static testmethod void testFail()
    {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockFailTest());       
        AsiaOneServiceRequestVO aosr = new AsiaOneServiceRequestVO();           
        AsiaOneFacade aof = new AsiaOneFacade();
        AsiaOneServiceResponsetVO actualResponse = aof.delegateAsiaOneCall(aosr);
                    
        Test.stopTest();
    }//end of testFail()
    
    /* @description: This method checks AsiaOneServiceResponsetVO method if error */
    static testmethod void testError()
    {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockErrorTest());        
        AsiaOneServiceRequestVO aosr = new AsiaOneServiceRequestVO();   
        AsiaOneFacade aof = new AsiaOneFacade();
        AsiaOneServiceResponsetVO actualResponse = aof.delegateAsiaOneCall(aosr);
        
        Test.stopTest();
    }//end of testError()
}//end of AsiaOneFacadeTest