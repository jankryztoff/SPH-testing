/**
* Class Name: <CreditNoteControllerTest>
* @author: Val Lu
* Date: <02/18/2015>
* Requirement/Project Name: <SPH>
* @author: <Marjorie Gaelo>
* Modified Date <02/24/2015>
* @description<Test Class for CreditNoteTriggerHandler>
*Additional for code coverage : Joyrem Zarmaine D. Ayuman
*/

@isTest
private class CreditNoteTriggerHandlerTest {
    Static testMethod void TestTempStopDirectController() { 
        List<Letter_Print_Request__c> LPR = new List<Letter_Print_Request__c>();
        //Insert Letter Print Request
        Letter_Print_Request__c letterPrintreq = new Letter_Print_Request__c();
        letterPrintreq.Name = 'letterPrintreq123';

        LPR.add(letterPrintreq);
        INSERT LPR;
        /*
        Credit_Note__c cN = new Credit_Note__c();
        cN.Remark1__c = 'samplecredit';
        INSERT cN;
        UPDATE cN;
        DELETE cN;

        CreditNoteTriggerHandler cnth = new CreditNoteTriggerHandler();
        cnth.runBeforeInsertTrigger();
        cnth.runBeforeUpdateTrigger();
        cnth.runBeforeDeleteTrigger();
        cnth.runAfterInsertTrigger();
        cnth.runAfterUpdateTrigger();
        cnth.runAfterDeleteTrigger();
		*/
   }     
}