/** 
 * Class Name: <EmailMessageTriggerHandler>
 * @author: <FrancisMartinBenzon>
 * Date: <7/24/2014>
 * Requirement/Project Name: <SPH>
 * @description<To prevent deletion of Email records.>
 */


public class EmailMessageTriggerHandler implements TriggerHandlerInterface{

    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
    List<String> OutOfOfficeKeywords = new List<String>();
    List<Out_Of_Office__c> allOut = Out_Of_Office__c.getall().values(); // Custom Setting Object that contains all out of office keywords.
    Static Set<Id> emsParentId = new Set<Id>();
    Static Map<Id, Case> parentCases = new Map<Id, Case>();
    
    //START UD-3605 19Feb2016 FrancisBenzon : variables
    List<String> emailIdsStringLst = new List<String>();
    Set<String> emailIdsStringSet = new Set<String>();
    //END UD-3605 19Feb2016 FrancisBenzon : variables
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !EmailMessageTriggerHandler.isBeforeInsertTriggerCalled;
        EmailMessageTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !EmailMessageTriggerHandler.isBeforeUpdateTriggerCalled;
        EmailMessageTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !EmailMessageTriggerHandler.isBeforeDeleteTriggerCalled;
        EmailMessageTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !EmailMessageTriggerHandler.isAfterInsertTriggerCalled;
        EmailMessageTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !EmailMessageTriggerHandler.isAfterUpdateTriggerCalled;
        EmailMessageTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !EmailMessageTriggerHandler.isAfterDeleteTriggerCalled;
        EmailMessageTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public void bulkBefore() {
        //parentCases =new map<Id, Case>([ SELECT Id , Email_to_Case_Address__c FROM Case WHERE Id IN :emsParentId]);
    }
        
    public void bulkAfter() {       
        parentCases =new map<Id, Case>();
        // START: Code Review Implementation 2/13/2015 JAlejandro
        if (!emsParentId.isEmpty())
        {
            parentCases.putAll([ SELECT Id , Email_to_Case_Address__c  FROM Case WHERE Id IN :emsParentId]);
        }
        // END: Code Review Implementation 2/13/2015 JAlejandro
    }
  
    public void beforeInsert(SObject so) {
        EmailMessage ems = (EmailMessage) so;        
        //record is not created for out of office replies.   
        for(Out_Of_Office__c off : allOut) {          
            if(ems.Subject.toUpperCase().contains(off.Out_of_Office_Keyword__c.toUpperCase())){
                ems.addError(ConstantsSLB.getErrorMessage('Error for Out of Office Replies'));
            }                                
        }           
        
        //does not allow sending if "From" field is not the same as the current sender.
        List<Case> parentCase = new List<Case>();
        // START: Code Review Implementation 2/13/2015 JAlejandro
        if (ems.ParentId != null)
        {
            //Start UD-0192 03-25-15 ABanaag
            parentCase = [Select Id, Email_to_Case_Address__c, Email_Message_Counter__c FROM Case WHERE id = : ems.ParentId];
            integer emailCounter;
            try{
                emailCounter = integer.valueOf(parentCase[0].Email_Message_Counter__c);
            }
            catch(Exception e){
                emailCounter = 0;
            }
            //START UD-3605 19Feb2016 FrancisBenzon : consider multiple toAddress for email to case scenario
            if(parentCase[0] != null && parentCase[0].Email_to_Case_Address__c != null && parentCase[0].Email_to_Case_Address__c.contains(';'))
            {               
                emailIdsStringLst = parentCase[0].Email_to_Case_Address__c.split('; ',5);
                if(emailIdsStringLst.size() > 0)
                {
                    for(String eId : emailIdsStringLst)
                    {
                        emailIdsStringSet.add(eid);
                    }
                    
                    if(!emailIdsStringSet.contains(ems.FromAddress) && !ems.Incoming && emailCounter > 0)
                    {                                               
                        ems.addError(GlobalVariableClass.ERROR_MESSAGE_INVALID_SENDER);
                    }
                }
                
            }
            else {
                if(ems.FromAddress !=  parentCase[0].Email_to_Case_Address__c && !ems.Incoming && emailCounter > 0){
                
                    ems.addError(GlobalVariableClass.ERROR_MESSAGE_INVALID_SENDER);
                }
            }
            //End UD-0192 03-25-15 ABanaag
            //END UD-3605 19Feb2016 FrancisBenzon : consider multiple toAddress for email to case scenario
            emsParentId.add(ems.ParentId);
        }
        // END: Code Review Implementation 2/13/2015 JAlejandro
    }
        
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
        //prevents email deletion. 
        so.addError(ConstantsSLB.getErrorMessage('Prevent Email Deletion'));
        
    }
    
    public void afterInsert(SObject so) {
        
        
        //auto populates custom field in case record with ToAddress of the email.      
        EmailMessage ems = (EmailMessage) so;  
        //system.assertEquals('>>>>Is Incoming', string.valueOf(ems.Incoming));
        Case ca = parentCases.get(ems.ParentId);               
        //system.assertEquals('------>', string.valueOf(casesToUpdateMap));          
        if(!casesToUpdateMap.containsKey(ems.ParentId)){
            //Case ca = parentCases.get(ems.ParentId);
            system.debug('----------->' + ca.Email_to_Case_Address__c);
            if(ca.Email_to_Case_Address__c == null && ems.Incoming) {
                ca.Email_to_Case_Address__c = ems.ToAddress;
                casesToUpdateMap.put(ca.Id, ca);                     
            }
            system.debug('>>>>TO:' + ems.ToAddress);
                                      
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