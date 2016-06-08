/**
* Test Class Name: AsiaOneServiceEesponsetVOTest
* @author: Thayne Jarrett Recato Dy
* Date: 02/04/2015 
* Description: Test class of AsiaOneServiceResponsetVO
*/ 
@isTest (Seealldata = TRUE)
private class AsiaOneServiceResponsetVOTest
{
    
    /*@description: This test method executes the class AsiaOneServiceResponsetVO */
    static testmethod void testAsiaOneServiceResponsetVO(){
        test.startTest();
        Map<string, string> reqValueObject = new Map<string, string>();
        string asia1APIFunction = null;        
        AsiaOneServiceResponsetVO call = new AsiaOneServiceResponsetVO(reqValueObject, asia1APIFunction);
        
        Map<string, object> getReqObj = call.getReqValueObject();
        System.assertNotEquals(NULL, getReqObj);
        test.stopTest();
    }    
}