/**
 * Trigger Name: BT_AT_STP050DX_StopPressSubscription
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - STP050DX Interface
 * Description: This trigger contains the business logic for STP050DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
 */

trigger BT_AT_STP050DX_StopPressSubscription on BT_CO_STPPRS_StopPressSubscription__c (before insert, before update) 
{
    
    List<BT_CO_STPPRS_StopPressSubscription__c> recordsList = trigger.new;
    
    BT_TH_STP050DX_StopPressSubscription triggerHandler = new BT_TH_STP050DX_StopPressSubscription();
    triggerHandler.execute(recordsList);    
}