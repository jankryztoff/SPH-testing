/**
 * Trigger Name: BT_AT_DIR097DX_ImportSingpostDetail
 * Author: Kevin Evasco
 * Date: 01 March 2016
 * Project/Requirement: SPH Integration - DIR096DX Interface
 * Description: This trigger contains the business logic for DIR096DX interface.
 */

trigger BT_AT_DIR097DX_ImportSingpostDetail on Address_Details__c (before insert, before update) 
{    
    List<Address_Details__c> recordsList = trigger.new;
    List<Singpost_Address__c> singpostAddressList;
    
    Map<String, Singpost_Address__c> singpostAddressMap = new Map<String, Singpost_Address__c>();
    
    Set<String> singpostKeySet = new Set<String>();
    
    for(Address_Details__c addressDetail : recordsList)
    {
        String singpostKey = addressDetail.postal_code_text__c + '|' + addressDetail.buildingNo__c;
        singpostKeySet.add(singpostKey);
    }
    
    singpostAddressList = [SELECT Id, SingPost_Key__c FROM Singpost_Address__c WHERE SingPost_Key__c IN :singpostKeySet];
    
    for(Singpost_Address__c singpostAddress : singpostAddressList) {
        singpostAddressMap.put(singpostAddress.SingPost_Key__c, singpostAddress);
    }
    
    for(Address_Details__c addressDetail : recordsList)
    {
        String singpostKey = addressDetail.postal_code_text__c + '|' + addressDetail.buildingNo__c;
        Singpost_Address__c singpostAddress = singpostAddressMap.get(singpostKey);
        if(singpostAddress != null)
            addressDetail.postal_code__c = singpostAddress.Id;
    }
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'DIR097DX';
    leg2sfLog.Batch_Run_Date__c = Date.today();
    leg2sfLog.Total_Record_Count__c = recordsList.size();
    leg2sfLog.Valid_Record_Count__c = recordsList.size();
    leg2sfLog.Invalid_Record_Count__c = 0;
   
    insert leg2sfLog;
    
}