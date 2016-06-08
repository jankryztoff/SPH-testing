/*
* Class Name: <wwwSphComArWsSchemaCommonUserTest>
* @author: Reszel Garrie Pineda
* Date: 2/06/2015
* Requirement/Project Name: <SPH>
* @description: Test class for wwwSphComArWsSchemaCommonUser
*/
@isTest (seeAllData= True)
private class wwwSphComArWsSchemaCommonUserTest {
    
    /* @description: This method checks UserType class*/
    static testmethod void testUserType()
    {
        Test.startTest();
        new wwwSphComArWsSchemaCommonUser.UserType();
        Test.stopTest();
    }//end of testUserType()
}//end of wwwSphComArWsSchemaCommonUserTest