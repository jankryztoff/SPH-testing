/*
 * Trigger Name: UsageTrigger
 * Author: Kevin Evasco
 * Date: 03/27/2015
 * Project/Requirement: SPH - Bill Run
 *
 * History: 03/27/2015 Kevin Evasco Created Apex Trigger
 */

trigger UsageTrigger on Usage__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(UsageTriggerHandler.class);
}