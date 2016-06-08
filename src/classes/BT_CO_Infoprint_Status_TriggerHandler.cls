/*
 * Class Name: BT_CO_Infoprint_Status_TriggerHandler
 * Author: Krithika Dharmarajan
 * Date: 05/08/2015
 * Project/Requirement: SPH - Infoprint
 *
 * 
 */
 
public class BT_CO_Infoprint_Status_TriggerHandler implements TriggerHandlerInterface{

    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    List<Letter_Print_Request__c> letterPrintRecordList = new List<Letter_Print_Request__c>();
    List<Letter_Print_Request__c> letterPrintRecordtoUpdate = new List<Letter_Print_Request__c>();
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !BT_CO_Infoprint_Status_TriggerHandler.isBeforeInsertTriggerCalled;
        BT_CO_Infoprint_Status_TriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !BT_CO_Infoprint_Status_TriggerHandler.isBeforeUpdateTriggerCalled;
        BT_CO_Infoprint_Status_TriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !BT_CO_Infoprint_Status_TriggerHandler.isBeforeDeleteTriggerCalled;
        BT_CO_Infoprint_Status_TriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !BT_CO_Infoprint_Status_TriggerHandler.isAfterInsertTriggerCalled;
        BT_CO_Infoprint_Status_TriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !BT_CO_Infoprint_Status_TriggerHandler.isAfterUpdateTriggerCalled;
        BT_CO_Infoprint_Status_TriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !BT_CO_Infoprint_Status_TriggerHandler.isAfterDeleteTriggerCalled;
        BT_CO_Infoprint_Status_TriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }

    public void bulkBefore() {      
    }
        
    public void bulkAfter() { 
    //START UD-3872 07-Mar-2016 Added by Raviteja  - Updating the logic for after update
    //if(trigger.isInsert){
    if(trigger.isInsert || trigger.isUpdate){
    //End UD-3872 07-Mar-2016 Added by Ravitej
    Set<String> fileNameSet = new Set<String>();
    Set<String> attachmentIdSet = new Set<String>();
    List<BT_CO_Infoprint_Status__c> infoprintRecordList = trigger.new;
        for(BT_CO_Infoprint_Status__c infoprintrecord :  infoprintRecordList)
        {
         fileNameSet.add(infoprintrecord.Filename__c);
         attachmentIdSet.add(infoprintrecord.Attachment_ID__c);
        }
    letterPrintRecordList = [select Attachment_ID__c,Filename__c,Downloaded__c from Letter_Print_Request__c where status__c ='Successful' and Filename__c IN :fileNameSet and Attachment_ID__c IN :attachmentIdSet];
     }
    }            
          
    public void beforeInsert(SObject so) {      
   
    }
        
    public void beforeUpdate(SObject oldSo, SObject so) {    
   
    }
    
    public void beforeDelete(SObject so) {        
    }
    
    public void afterInsert(SObject so) {
    if(trigger.isInsert){
        BT_CO_Infoprint_Status__c recordInfoprintstatus = (BT_CO_Infoprint_Status__c) so;
        for(Letter_Print_Request__c recordletterPrint : letterPrintRecordList)
        {
            if( (recordInfoprintstatus.Attachment_ID__c == recordletterPrint.Attachment_ID__c) && (recordInfoprintstatus.Filename__c == recordletterPrint.Filename__c) )
            {
             recordletterPrint.Downloaded__c = true;
             letterPrintRecordtoUpdate.add(recordletterPrint);
            }
         }
       }
    }    

    public void afterUpdate(SObject oldSo, SObject so) {
		//START 24 March 2016 D-4583 Kevin Evasco - Updating the Downloaded__c equals True in after update
        //START UD-3872 07-Mar-2016 Added by Raviteja  - Updating the Downloaded__c equals True in after update
        if(trigger.isUpdate){
        BT_CO_Infoprint_Status__c recordInfoprintstatus = (BT_CO_Infoprint_Status__c) so;
        for(Letter_Print_Request__c recordletterPrint : letterPrintRecordList)
        {
            if( (recordInfoprintstatus.Attachment_ID__c == recordletterPrint.Attachment_ID__c) && (recordInfoprintstatus.Filename__c == recordletterPrint.Filename__c) )
            {
             recordletterPrint.Downloaded__c = true;
             letterPrintRecordtoUpdate.add(recordletterPrint);
            }
         }
       }
       //End UD-3872 07-Mar-2016 Added by Raviteja      
	   //END 24 March 2016 D-4583 Kevin Evasco - Updating the Downloaded__c equals True in after update
    }

    public void afterDelete(SObject so) {        
    }

    public void andFinally() {  
    update letterPrintRecordtoUpdate;   
    }

}