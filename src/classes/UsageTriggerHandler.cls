/*
 * Class Name: UsageTriggerHandler
 * Author: Kevin Evasco
 * Date: 03/27/2015
 * Project/Requirement: SPH - Bill Run
 *
 * History: 03/27/2015 Kevin Evasco Created Apex Class
            05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier. Utilized UsageHelper.constructPrimaryKey
 */
 
public class UsageTriggerHandler implements TriggerHandlerInterface{

    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    public static Integer latestCreditNoteNumber;
    
    //START D-2647 06/16/2015 Added By J.Sarion - Check if Case is Complaint Newspaper
    Set<Id> caseIdSet = new Set<Id>();
    List<Case> caseList = new List<Case>();
    Map<Id, Case> caseIdToCaseMap = new Map<Id, Case>();
    //END D-2647 06/16/2015 Added By J.Sarion - Check if Case is Complaint Newspaper
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !UsageTriggerHandler.isBeforeInsertTriggerCalled;
        UsageTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !UsageTriggerHandler.isBeforeUpdateTriggerCalled;
        UsageTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !UsageTriggerHandler.isBeforeDeleteTriggerCalled;
        UsageTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !UsageTriggerHandler.isAfterInsertTriggerCalled;
        UsageTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !UsageTriggerHandler.isAfterUpdateTriggerCalled;
        UsageTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !UsageTriggerHandler.isAfterDeleteTriggerCalled;
        UsageTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }

    public void bulkBefore() {      
        //START D-2647 06/16/2015 Added By J.Sarion - Check if Case is Complaint Newspaper
        if (trigger.isUpdate) {
            for (sObject u :trigger.old) {
                Usage__c usage = (Usage__c) u;
                if (trigger.isUpdate) {
                    if (usage.Case__c != null) {
                        caseIdSet.add(usage.Case__c);
                    }
                }
            }
        }
        
        //START PD-0154 4/27/2016 Added by J.Sarion - Add case in uniqueIdentifier
        if(trigger.isInsert) {
            for(sObject u :trigger.new) {
                Usage__c usage = (Usage__c) u;
                if(usage.Case__c != null && (usage.StopType__c == 'TStop Final' || usage.StopType__c == 'TStop Convert' || usage.StopType__c == 'TStop Temp')) {
                    caseIdSet.add(usage.Case__c);
                }
            }
        }
        //END PD-0154 4/27/2016 Added by J.Sarion - Add case in uniqueIdentifier
        
        if (!caseIdSet.isEmpty()) {
            caseIdToCaseMap = new Map<Id, Case>([SELECT ID, RecordType.Id, CaseNumber FROM Case WHERE Id IN:caseIdSet]); //START-END PD-0154 4/27/2016 Added by J.Sarion
        }
        //END D-2647 06/16/2015 Added By J.Sarion - Check if Case is Complaint Newspaper
    }
        
    public void bulkAfter() {                                                                          
    }            
          
    public void beforeInsert(SObject so) {      
        Usage__c stagingObject = (Usage__c) so;
        stagingObject.Unique_Identifier__c = UsageHelper.constructPrimaryKey(stagingObject);
        
        //START PD-0154 4/27/2016 Added by J.Sarion - add case to uniqueIdentifier
        if(stagingObject.Case__c != null) {
            if(caseIdToCaseMap.containsKey(stagingObject.Case__c)) {
                stagingObject.Unique_Identifier__c += '_' + caseIdToCaseMap.get(stagingObject.Case__c).CaseNumber;
            }
        }
        //END PD-0154 4/27/2016 Added by J.Sarion - add case to uniqueIdentifier
    }
        
    public void beforeUpdate(SObject oldSo, SObject so) {    
        Usage__c stagingObject = (Usage__c) so;
        //START D-2647 06/16/2015 Added By J.Sarion - If Case RecordType is Complaint Newspaper, do not update Primary Key
        if (stagingObject.Case__c != null) {
            if (caseIdToCaseMap.containsKey(stagingObject.Case__c)) {
                if (caseIdToCaseMap.get(stagingObject.Case__c).RecordType.Id != ConstantsSLB.getKeyId(GlobalVariableClass.COMPNEWS))
                    stagingObject.Unique_Identifier__c = UsageHelper.constructPrimaryKey(stagingObject);
            }
        }
        else {
            stagingObject.Unique_Identifier__c = UsageHelper.constructPrimaryKey(stagingObject);
        }
        //END D-2647 06/16/2015 Added By J.Sarion - If Case RecordType is Complaint Newspaper, do not update Primary Key
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