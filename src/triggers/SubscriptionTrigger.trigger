trigger SubscriptionTrigger on Zuora__Subscription__c(after delete, after insert, after update, before delete, before insert, before update)
{
    
  //START: UD-1830 7/13/2015 Avoid looping of Trigger
  if(SubscriptionTriggerHandler.preventExecution == FALSE){
      
      TriggerFactory.createHandler(SubscriptionTriggerHandler.class);
      
  }
  //END: UD-1830 7/13/2015 Avoid looping of Trigger
}