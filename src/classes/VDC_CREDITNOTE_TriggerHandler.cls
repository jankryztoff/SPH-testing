/*
 * Class Name: VDC_CREDITNOTE_TriggerHandler
 * Author: Kevin Evasco
 * Date: 03/19/2014
 * Project/Requirement: SPH Scheduled Processes - Vendor Debit/Credit
 *
 * History: 03/19/2015 Kevin Evasco Created Apex Class
 */
 
public class VDC_CREDITNOTE_TriggerHandler implements TriggerHandlerInterface{

    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    public static Integer latestCreditNoteNumber;
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !VDC_CREDITNOTE_TriggerHandler.isBeforeInsertTriggerCalled;
        VDC_CREDITNOTE_TriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !VDC_CREDITNOTE_TriggerHandler.isBeforeUpdateTriggerCalled;
        VDC_CREDITNOTE_TriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !VDC_CREDITNOTE_TriggerHandler.isBeforeDeleteTriggerCalled;
        VDC_CREDITNOTE_TriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !VDC_CREDITNOTE_TriggerHandler.isAfterInsertTriggerCalled;
        VDC_CREDITNOTE_TriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !VDC_CREDITNOTE_TriggerHandler.isAfterUpdateTriggerCalled;
        VDC_CREDITNOTE_TriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !VDC_CREDITNOTE_TriggerHandler.isAfterDeleteTriggerCalled;
        VDC_CREDITNOTE_TriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }

    public void bulkBefore() {
        List<VDC_CREDITNOTE__c> latestCreditNote = [SELECT Id, Credit_Note_Number__c FROM VDC_CREDITNOTE__c ORDER BY CreatedDate DESC LIMIT 1];
        if(latestCreditNote.size() == 0)
        {
            latestCreditNoteNumber = 19999999;
        }
        else 
        {
            latestCreditNoteNumber = Integer.valueOf(latestCreditNote[0].Credit_Note_Number__c);
        }
    }
        
    public void bulkAfter() {                                                                          
    }            
          
    public void beforeInsert(SObject so) {      
        VDC_CREDITNOTE__c stagingObject = (VDC_CREDITNOTE__c) so;
        latestCreditNoteNumber++;
        latestCreditNoteNumber++;
        if(latestCreditNoteNumber > 20099999) {
            latestCreditNoteNumber = 20000000;
        }
        stagingObject.Credit_Note_Number__c = latestCreditNoteNumber;       
    }
        
    public void beforeUpdate(SObject oldSo, SObject so) {        
    }
    
    public void beforeDelete(SObject so) {        
    }
    
    public void afterInsert(SObject so) {
    }    

    public void afterUpdate(SObject oldSo, SObject so) {
    }

    public void afterDelete(SObject so) {        
    }

    public void andFinally() {             
    }

}