/*
 * @Test Class Name: AsiaOneServiceRequestVOTest
 * @author: John Patrick L. Ocariz
 * @Date: 02/04/2015    
 * @Description: Test class for AsiaOneServiceRequestVO
 */  

@isTest
private class AsiaOneServiceRequestVOTest {
    
    /*
    *  @name: testsetReqValueObject()
    *  @param: no parameters
    *  @return: void
    *  @throws exception: n/a 
    *  @description: tests the setReqValueObject() method   
    */
    static testmethod void testsetReqValueObject(){
        //test data
        Map<string, string> samplereqVO = new Map<string, string>();

        //start test
        test.startTest();
        
        AsiaOneServiceRequestVO sampleInstance = new AsiaOneServiceRequestVO();
        System.assertNotEquals(null, sampleInstance);
        
        sampleInstance.setReqValueObject(samplereqVO);
        
        test.stopTest();
    }
    
        /*
    *  @name: testsetReqValueObject()
    *  @param: no parameters
    *  @return: void
    *  @throws exception: n/a    
    *  @description: tests the setAsia1APIFunction() method
    */
    static testmethod void testsetAsia1APIFunction(){
        //test data
        String testAsia1APIFunc = null;
        
        //start test
        test.startTest();
       
        AsiaOneServiceRequestVO sampleInstance = new AsiaOneServiceRequestVO();
        System.assertNotEquals(null, sampleInstance);
        
        sampleInstance.setAsia1APIFunction(testAsia1APIFunc);
        
        test.stopTest();                   
    }
}