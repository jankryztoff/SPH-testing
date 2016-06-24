/*
* Class Name: <wwwSphComArWsSchemaCommonMessagesTest>
* @author: Reszel Garrie Pineda
* Date: 2/06/2015
* Requirement/Project Name: <SPH>
* @description: Test class for wwwSphComArWsSchemaCommonMessages
*/
@isTest (seeAllData= True)
private class wwwSphComArWsSchemaCommonMessagesTest {
    
    /* @description: This method checks MessagesType class*/
    static testmethod void testMessagesType()
    {
        
        Test.startTest();        
        new wwwSphComArWsSchemaCommonMessages.MessagesType();        
        Test.stopTest();
        
    }//end of testMessages
    
    /* @description: This method checks MessagesType class*/    
    static testmethod void testMessageType()
    {
        
        Test.startTest();        
        new wwwSphComArWsSchemaCommonMessages.MessageType();        
        Test.stopTest();
        
    }//end of testMessage
}//end of wwwSphComArWsSchemaCommonMessagesTest