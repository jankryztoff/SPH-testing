trigger AttachmentTrigger on Attachment (before delete){
    
    //START 13 April 2016 D-4419 Kevin Evasco - Validation Exempt
    User userRecord = [SELECT Id, Validation_Exempted__c FROM User WHERE Id = :UserInfo.getUserId()];
    
    if(userRecord.Validation_Exempted__c == false) {
        String ErrorMsg = ConstantsSLB.getErrorMessage('AttachmentDeleteError');
        for(Attachment att : trigger.old) {
            att.addError(ErrorMsg);
        } 
    }
    //END 13 April 2016 D-4419 Kevin Evasco - Validation Exempt
    
}