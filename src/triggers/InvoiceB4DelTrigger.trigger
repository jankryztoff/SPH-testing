trigger InvoiceB4DelTrigger on Zuora__ZInvoice__c (After delete) 
{
    if(Trigger.isAfter && Trigger.isDelete)
    {
        List<Exception> exceptionList = new List<Exception>();
        String message = '';
    	for(Zuora__ZInvoice__c invoice : Trigger.Old)
        {
            message += invoice.Name +'|';
        }
        exceptionList.add(new CustomException(message));
        ExceptionLogger.log(exceptionList);   
    }
}