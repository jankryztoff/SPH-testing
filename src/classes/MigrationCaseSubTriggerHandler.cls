/**
 * Class Name: <MigrationCaseSubTriggerHandler>
 * @author: <Christopher Camilon>
 * Date: <04/19/2016>
 * Requirement/Project Name: <SPH>
 * @description<To populate the necesarry fields for Case temp Stop> 
 *
 */
public class MigrationCaseSubTriggerHandler implements TriggerHandlerInterface{

    public static Boolean preventExecution = FALSE;
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;

    Id CASE_TEMP_STOP_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
    Static Set<Id> caseIds = new Set<Id>();
    Static Map<Id, Case> caseMap = new Map<Id, Case>();
    Static List<Case> caseUpdList = new List<Case>();
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !MigrationCaseSubTriggerHandler.isBeforeInsertTriggerCalled;
        MigrationCaseSubTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !MigrationCaseSubTriggerHandler.isBeforeUpdateTriggerCalled;
        MigrationCaseSubTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !MigrationCaseSubTriggerHandler.isBeforeDeleteTriggerCalled;
        MigrationCaseSubTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !MigrationCaseSubTriggerHandler.isAfterInsertTriggerCalled;
        MigrationCaseSubTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !MigrationCaseSubTriggerHandler.isAfterUpdateTriggerCalled;
        MigrationCaseSubTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !MigrationCaseSubTriggerHandler.isAfterDeleteTriggerCalled;
        MigrationCaseSubTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;
    }
    
    public void bulkBefore() {
    
        
        if (Trigger.isUpdate) {
        
            for (Case_Subscription__c caseSub : (list<Case_Subscription__c>)trigger.new) {
                if(caseSub.CASE_Subscription_Legacy_Id__c != null){
                    caseIds.add(caseSub.Case__c);        
                }
            }    
            List<Case> caseList = new List<Case>();
            caseList = [Select Id, Temp_Stop_Date__c, Restart_Date__c, Current_Date_for_Year_To_Date__c, Next_Year_for_Year_To_Date__c From Case Where Id in : caseIds];
            for(Case c : caseList){
                
                caseMap.put(c.id, c);
            
            }
        } 
        
                                             
        
    }
    
    public void bulkAfter() {
        
    }
    public void afterUpdate(SObject oldSo, SObject so) {
    
       
    
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
    
       
    
    }
    public void afterDelete(SObject so) {
    
       
    
    }
    public void beforeDelete(SObject so) {
    
       
    
    }
    
    public void beforeInsert(SObject so) {
    
       
    
    }
    
    public void afterInsert(SObject so) {
    
        Case_Subscription__c caseSub = (Case_Subscription__c)so;
        if(caseSub.Case__r.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && caseSub.CASE_Subscription_Legacy_Id__c != null){
            Case updCase = caseMap.get(caseSub.Case__c);
            updCase.Temp_Stop_Sub__c = caseSub.Subscription__c;
            caseUpdList.add(updCase);                   
        } 
    
    }
    public void andFinally() {
    
        if(!caseUpdList.isEmpty()){
            update caseUpdList;
        }
    }
 
}