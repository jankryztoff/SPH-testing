/*
 * Class Name: BT_AB_DIR094DX_CallOutOnly
 * @author: Renino Niefes
 * Date: 11/19/2014
 * Project/Requirement: SPH Integration - DIR094DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for DIR094DX batch job. Used together with BT_AS_DIR094DX_VendorPerformanceInfo Schedulable
 * 
 * History: 11/19/2014 Renino Niefes Created Batchable for call outs only
 */


global class BT_AB_DIR094DX_CallOutOnly implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    global final String interfaceId = 'DIR094DX';

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Select query and save to data pool
        String query = ' SELECT Vendor_Group__c,  ';
        query += '      Vendor_Code__c,  ';
        query += '      Complaint_Count_NonDelivery__c, ';
        query += '      Complain_Count_Delivery__c ';
        query += ' FROM BT_CO_DIR_VendorPerformanceMaster__c ';
        query += ' WHERE Complaint_Count_NonDelivery__c >0 OR Complain_Count_Delivery__c > 0 ';
        query += ' ORDER BY Vendor_Code__c ';
        
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {   
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        for(sObject obj : scope) {  
            BT_CO_DIR_VendorPerformanceMaster__c record = (BT_CO_DIR_VendorPerformanceMaster__c) obj;
        
            String exportData = '';     
            exportData += record.Vendor_Group__c + ',';
            exportData += record.Vendor_Code__c + ',';
            exportData += record.Complain_Count_Delivery__c + ',';
            exportData += record.Complaint_Count_NonDelivery__c + '';
            
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            
            datapoolList.add(datapoolRecord);                   
        }

             Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_' + interfaceId + '_DailyVendorSubscription insert operation failed.');
        }   
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Send callout
        BT_CO_INT_Utilities.sendCallOutMessage(interfaceId);

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}