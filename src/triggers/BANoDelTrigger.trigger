trigger BANoDelTrigger on Zuora__CustomerAccount__c (after delete)     
{
    if(Trigger.isAfter && Trigger.isDelete)
    {
        List<Exception> exceptionList = new List<Exception>();
        String message = '';
        for(Zuora__CustomerAccount__c account: Trigger.Old)
        {
            message += account.Zuora__External_Id__c +'|';
        }
        exceptionList.add(new CustomException(message));
        ExceptionLogger.log(exceptionList);   
    }
}