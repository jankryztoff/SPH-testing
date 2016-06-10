/*
 * Trigger Name: BT_CO_Infoprint_Status_Trigger
 * Author: Krithika Dharmarajan
 * Date: 05/08/2015
 * Project/Requirement: SPH - Infoprint Update Status
 *
 * 
 */

trigger BT_CO_Infoprint_Status_Trigger on BT_CO_Infoprint_Status__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(BT_CO_Infoprint_Status_TriggerHandler.class);
}