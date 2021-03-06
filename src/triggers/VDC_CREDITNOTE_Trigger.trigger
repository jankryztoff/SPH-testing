/*
 * Trigger Name: VDC_CREDITNOTE_Trigger
 * Author: Kevin Evasco
 * Date: 03/19/2014
 * Project/Requirement: SPH Scheduled Processes - Vendor Debit/Credit
 *
 * History: 03/19/2015 Kevin Evasco Created Apex Trigger
 */

trigger VDC_CREDITNOTE_Trigger  on VDC_CREDITNOTE__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(VDC_CREDITNOTE_TriggerHandler.class);
}