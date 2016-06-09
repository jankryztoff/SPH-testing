trigger EmailMessageTrigger on EmailMessage (after delete, after insert, after update, before delete, before insert, before update)
{
    TriggerFactory.createHandler(EmailMessageTriggerHandler.class);
    //System.assertEquals(Trigger.new+'', ' ');
}