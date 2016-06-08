/**
     * Class Name: PreviousYearTotalTempStopBatch 
     * @author: Alyana Navarro
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Batch Apex Class to update fields in Subscription and Subscription Vendor.
     */
     
global class PreviousYearTotalTempStopBatch implements Database.Batchable<sObject> {     
    
    Date firstMonth = date.newInstance(system.today().year(), 1, 1);
    Date lastMonth = date.newInstance(system.today().year(), 12, 31);
    List<Temp_Stop__c> tempStopList = new List<Temp_Stop__c>();
    
    
    /* Description: Method for querying all of the temp stop done within the year.
     * Parameter: Database.BatchableContext BC
     * Return: Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string query = 'SELECT id, name, temp_stop_Date__c FROM Temp_Stop__c WHERE temp_stop_Date__c = this_year';
        return Database.getQueryLocator(query);
    }
    
    /* Description: Method for execution of the batch class.
     * Parameter: Database.BatchableContext BC, List<Temp_Stop__c> tempStopList
     * Return: 
     */
    global void execute(Database.BatchableContext BC, List<Temp_Stop__c> tempStopList) {
        Set<String> tempStopIdSet = new Set<String>();
        Set<String> directSubIdSet = new Set<String>();
        Set<String> vendorSubIdSet = new Set<String>();
        
        Integer counter = 0;        
        List<Subscription_Temp_Stop__c> directSubTempStopList = new List<Subscription_Temp_Stop__c>();
        List<Vendor_Temp_Stop__c> vendorSubTempStopList = new List<Vendor_Temp_Stop__c>();
        List<Zuora__Subscription__c> directSubList = new List<Zuora__Subscription__c>();
        List<Subscription_Vendor__c> vendorSubList = new List<Subscription_Vendor__c>();
        List<Zuora__Subscription__c> updatedDirectSubList = new List<Zuora__Subscription__c>();
        List<Subscription_Vendor__c> updatedVendorSubList = new List<Subscription_Vendor__c>();
        Map<String, Temp_Stop__c> tempStopMap = new Map<String, Temp_Stop__c>();
                
        for(Temp_Stop__c tempStop : tempStopList){
            tempStopIdSet.add(tempStop.id);         
        }
        
        for(Temp_Stop__c tempStop : tempStopList){
            tempStopMap.put(tempStop.id, tempStop);
        }
        
        directSubTempStopList = [SELECT id, name, subscription__c, temp_stop__c 
                                 FROM Subscription_Temp_Stop__c 
                                 WHERE temp_stop__c IN : tempStopIdSet];
        
        vendorSubTempStopList = [SELECT id, name, temp_stop__c, Subscription_Vendor__c 
                                FROM Vendor_Temp_Stop__c
                                WHERE temp_stop__c IN : tempStopIdSet];         
        
        for(Vendor_Temp_Stop__c vendorSubTempStop : vendorSubTempStopList){
            vendorSubIdSet.add(vendorSubTempStop.Subscription_Vendor__c);
        }
        
        for(Subscription_Temp_Stop__c directSubTempStop : directSubTempStopList){
            directSubIdSet.add(directSubTempStop.Subscription__c);
        }
        
        directSubList = [SELECT id, name, Previous_Year_Temp_Stop_Days__c, Year_to_Date_Temp_Stop_Days__c 
                         FROM Zuora__Subscription__c
                         WHERE id IN : directSubIdSet];
                         
        vendorSubList = [SELECT id, name, Temp_Stop_Count_Year_to_Date__c,  Previous_Year_Temp_Stop_Days__c
                         FROM Subscription_Vendor__c
                         WHERE id IN : vendorSubIdSet]; 
        
        List<SObject> directObjectList = resetCounter(directSubList, true);
        List<SObject> vendorObjectList = resetCounter(vendorSubList, false);
        for(SObject obj : directObjectList){
            updatedDirectSubList.add((Zuora__Subscription__c) obj);
        }
        
        for(SObject obj : vendorObjectList){
            updatedVendorSubList.add((Subscription_Vendor__c) obj);
        }               
        
        if(updatedDirectSubList.size() > 0) {
            List<Database.Saveresult> updateResults = Database.update(updatedDirectSubList, false); 
            for(Database.Saveresult sr : updateResults) {
                if(!sr.isSuccess()) {
                    System.debug('UpserResult: ' + sr);
                }
            }
        }
        if(updatedVendorSubList.size() > 0) {
            List<Database.Saveresult> updateResults = Database.update(updatedVendorSubList, false); 
            for(Database.Saveresult sr : updateResults) {
                if(!sr.isSuccess()) {
                    System.debug('UpserResult: ' + sr);
                }
            }
        }
    }
        
    /* Description: Method for finishing the batch.
     * Parameter: Database.BatchableContext BC
     * Return: 
     */
    global void finish(Database.BatchableContext BC) {
    
    }
    
    /* Description: Method for setting values to the fields to be updated. 
     * Parameter: List<SObject> objectList, Boolean isDirect
     * Return: List<SObject>
     */
    public List<SObject> resetCounter(List<SObject> objectList, Boolean isDirect){      
        
        for(SObject obj : objectList){
            if(isDirect){
                Zuora__Subscription__c directSubscription = (Zuora__Subscription__c) obj;
                
                directSubscription.Previous_Year_Temp_Stop_Days__c = directSubscription.Year_to_Date_Temp_Stop_Days__c;
                directSubscription.Year_to_Date_Temp_Stop_Days__c = 0;
            } else {
                Subscription_Vendor__c vendorSubscription = (Subscription_Vendor__c) obj;
                
                vendorSubscription.Previous_Year_Temp_Stop_Days__c = vendorSubscription.Temp_Stop_Count_Year_to_Date__c;
                vendorSubscription.Temp_Stop_Count_Year_to_Date__c = 0;
            }
        }
        
        return objectList;
    }
}