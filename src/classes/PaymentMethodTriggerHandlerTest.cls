/**
 * Class Name: <PaymentMethodTriggerHandlerTest>
 * @author: 
 * Date: <7/7/2015>
 * Requirement/Project Name: <SPH>
 */

@isTest
private class PaymentMethodTriggerHandlerTest{ 

    static testMethod void unitTest(){
    
        PaymentMethodTriggerHandler pmth = new PaymentMethodTriggerHandler();
        pmth.runBeforeInsertTrigger();
        pmth.runBeforeUpdateTrigger();
        pmth.runBeforeDeleteTrigger();
        pmth.runAfterInsertTrigger();
        pmth.runAfterUpdateTrigger();
        pmth.runAfterDeleteTrigger();

    }
}