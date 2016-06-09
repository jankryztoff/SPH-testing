/**
 * Class Name: <CaseCommentTriggerHandler>
 * @author: <Karl Tan>
 * Date: <12/18/2014>
 * Requirement/Project Name: <SPH>
 * @description<Update Follow-up indicator in case object.>
 */


public class CaseCommentTriggerHandler implements TriggerHandlerInterface{

    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
       
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !CaseCommentTriggerHandler.isBeforeInsertTriggerCalled;
        CaseCommentTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !CaseCommentTriggerHandler.isBeforeUpdateTriggerCalled;
        CaseCommentTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !CaseCommentTriggerHandler.isBeforeDeleteTriggerCalled;
        CaseCommentTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !CaseCommentTriggerHandler.isAfterInsertTriggerCalled;
        CaseCommentTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !CaseCommentTriggerHandler.isAfterUpdateTriggerCalled;
        CaseCommentTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !CaseCommentTriggerHandler.isAfterDeleteTriggerCalled;
        CaseCommentTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public void bulkBefore() {
        
    }
        
    public void bulkAfter() {
        
    }
  
    public void beforeInsert(SObject so) {
           
    }
        
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
        
    }
    
    public void afterInsert(SObject so) {
        //Update Case Follow_up__c to 'True'
        CaseComment ccms = (CaseComment) so;                 
            if(!casesToUpdateMap.containsKey(ccms.ParentId)){
                Case ca = new Case(Id = ccms.ParentId);
                ca.Follow_up__c = True;               
                casesToUpdateMap.put(ca.Id, ca);                          
            }      
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
    
        update casesToUpdateMap.values();
       
    }
}