/**
     * @Class Name:  wwwSphComArWsSchemaCamCreateaccouRTest
     * @Base Class:  wwwSphComArWsSchemaCamCreateaccouR
     * @author: John Patrick L. Ocariz
     * @Date: 02/19/2015    
     */    
@isTest
private class wwwSphComArWsSchemaCamCreateaccouRTest {
    
    //@Description: test the instance of wwwSphComArWsSchemaCamCreateaccouR
    //@Parameters: none
    //@return type: none
    static testmethod void testAccCreResp_element(){
        
        test.startTest();
            wwwSphComArWsSchemaCamCreateaccouR.AccCreResp_element testobj = new wwwSphComArWsSchemaCamCreateaccouR.AccCreResp_element();
            System.assertNotEquals(null, testobj);
        
        test.stopTest();
    }
}