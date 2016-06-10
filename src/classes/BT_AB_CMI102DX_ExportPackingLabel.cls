/*
 * Class Name: BT_AB_CMI102DX_ExportPackingLabel
 * @author: Kevin H. Evasco
 * Date: 25 February 2016
 * Project/Requirement: SPH Integration - CMI102DX Interface - NCR015-5
 * @description This class populates BA_INT_DATA_POOL__c for CMI102DX batch job which is picked up by the on-premise to export Packing Label. 
 * D-4626 - Restrtutre the code by updating the logic of comma
 * D-4673 - Restrtutre the code by updating the logic of comma
 */


global class BT_AB_CMI102DX_ExportPackingLabel implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    
    global final String interfaceId = 'CMI102DX';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
        String startDate = batchRunDate + 'T00:00:00Z';
        String endDate = batchRunDate + 'T23:59:59Z';
        
        String query = '';      
        query += ' SELECT ';
        query += '  Publication_Code__c, ';
        query += '  Publication_Issue_Date__c, ';
        query += '  Vendor_Group__c, ';
        query += '  Mailing_Agent__c, ';
        query += '  Subscription_Name__c, ';
        query += '  Total_Direct_Subscriptions__c, ';
        query += '  Subscriber_Account_Number__c, ';
        query += '  Recipient_Number__c, ';
        query += '  Postal_Zone__c, ';
        query += '  Attention_To_Care_Of_Indicator__c, ';
        //START 24 March 2016 D-4583 Kevin Evasco - Added Attn To Name
        query += '  Attn_To_Name__c, ';
        //END 24 March 2016 D-4583 Kevin Evasco - Added Attn To Name
        query += '  First_Name__c, ';
        query += '  Last_Name__c, ';
        query += '  Address_Record_Type__c, ';
        query += '  Block_House_Number__c, ';
        query += '  Street_Name__c, ';
        query += '  Level_Number__c, ';
        query += '  Unit_Number__c, ';
        query += '  Building_Name__c, ';
        query += '  Country_Name__c, ';
        query += '  Postal_Code__c, ';
        query += '  Address_1__c, ';
        query += '  Address_2__c, ';
        query += '  Address_3__c, ';
        query += '  Address_4__c, ';
        query += '  Section_Code__c, ';
        query += '  Department__c, ';
        query += '  Division_Code__c, ';
        query += '  Company_Code__c, ';
        query += '  Location_Code__c, ';
        query += '  Airline_Number__c, ';
        query += '  Airline_Packing_Group__c, ';
        query += '  Packing_Group_Description__c, ';
        query += '  Airline_City_Code__c, ';
        query += '  Flight_Number__c, ';
        query += '  Flight_Number_2__c, ';
        query += '  Airline_Name__c, ';
        query += '  Sequence_Number__c, ';
        query += '  City_Code__c, ';
        query += '  Remarks__c, ';
        query += '  Freelist_Indicator__c ';
        query += ' FROM CMIS_POP_Packing_label_Batch__c ';
        //START D-4626 04-Apr-2016 Raviteja Kumar - Export records based on batch run date 
        //query += ' WHERE CreatedDate >= '+startDate+' AND CreatedDate <= '+ endDate;
        query += ' WHERE Batch_Run_Date__c = '+batchRunDate ; // commented for testing purpose
        query += ' AND Total_Direct_Subscriptions__c > 0 ' ; // 0 copies records should not be proceeses
        //query += ' where Subscription_Name__c = \'BA-S00062570\' '; // added for testing purpose
        //END D-4626 04-Apr-2016 Raviteja Kumar
        
        System.debug('query : '+query);
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CMIS_POP_Packing_label_Batch__c> scope)
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        String invalidCharacterSet = ConstantsSLB.getKeyId('SMS104DX Invalid characters');
        String[] invalidCharacterArray = invalidCharacterSet.split('/\\$/');  
        
        for(CMIS_POP_Packing_label_Batch__c plbRecord : scope)
        {              
            String exportData = '';                     
                
            exportData += StringUtility.wrapEscape(plbRecord.Publication_Code__c,',','""') + ',';
            //START 24 March 2016 D-4583 Kevin Evasco - Removed wrapEscape and String fomat
            exportData += plbRecord.Publication_Issue_Date__c + ',';
            //END 24 March 2016 D-4583 Kevin Evasco - Removed wrapEscape and String fomat
            exportData += StringUtility.wrapEscape(plbRecord.Vendor_Group__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Mailing_Agent__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Subscription_Name__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(String.valueOf(Integer.valueOf(plbRecord.Total_Direct_Subscriptions__c)),',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Subscriber_Account_Number__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Recipient_Number__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Postal_Zone__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Attention_To_Care_Of_Indicator__c,',','""') + ',';
            //START 24 March 2016 D-4583 Kevin Evasco - Added Attn To Name
            //exportData += StringUtility.wrapEscape(plbRecord.Attn_To_Name__c,',','""') + ',';
            exportData += (plbRecord.Attn_To_Name__c != null ? '"' + String.ValueOf(plbRecord.Attn_To_Name__c)+ '"' : '') + ','; 
            //END 24 March 2016 D-4583 Kevin Evasco - Added Attn To Name
            //exportData += StringUtility.wrapEscape(plbRecord.First_Name__c,',','""') + ',';
            exportData += (plbRecord.First_Name__c != null ? '"' + String.ValueOf(plbRecord.First_Name__c)+ '"' : '') + ','; 
            //exportData += StringUtility.wrapEscape(plbRecord.Last_Name__c,',','""') + ',';
            exportData += (plbRecord.Last_Name__c != null ? '"' + String.ValueOf(plbRecord.Last_Name__c)+ '"' : '') + ','; 
            exportData += StringUtility.wrapEscape(plbRecord.Address_Record_Type__c,',','""') + ',';
            //exportData += StringUtility.wrapEscape(plbRecord.Block_House_Number__c,',','""') + ',';
            exportData += (plbRecord.Block_House_Number__c != null ? '"' + String.ValueOf(plbRecord.Block_House_Number__c)+ '"' : '') + ','; 
            //exportData += StringUtility.wrapEscape(plbRecord.Street_Name__c,',','""') + ',';
            exportData += (plbRecord.Street_Name__c != null ? '"' + String.ValueOf(plbRecord.Street_Name__c)+ '"' : '') + ','; 
            //exportData += StringUtility.wrapEscape(plbRecord.Level_Number__c,',','""') + ',';
            exportData += (plbRecord.Level_Number__c != null ? '"' + String.ValueOf(plbRecord.Level_Number__c)+ '"' : '') + ','; 
            //exportData += StringUtility.wrapEscape(plbRecord.Unit_Number__c,',','""') + ',';
            exportData += (plbRecord.Unit_Number__c != null ? '"' + String.ValueOf(plbRecord.Unit_Number__c)+ '"' : '') + ','; 
            //exportData += StringUtility.wrapEscape(plbRecord.Building_Name__c,',','""') + ',';
            exportData += (plbRecord.Building_Name__c != null ? '"' + String.ValueOf(plbRecord.Building_Name__c)+ '"' : '') + ','; 
            // START PD-0134 - Raviteja - 10May2016 - capturing Country_Name__c name as string
            //exportData += StringUtility.wrapEscape(plbRecord.Country_Name__c,',','""') + ',';
            exportData += (plbRecord.Country_Name__c != null ? '"' + String.ValueOf(plbRecord.Country_Name__c)+ '"' : '') + ',';
            // END PD-0134 - Raviteja - 10May2016 - capturing Country_Name__c name as string
            exportData += StringUtility.wrapEscape(plbRecord.Postal_Code__c,',','""') + ',';
            //exportData += StringUtility.wrapEscape(plbRecord.Address_1__c,',','""') + ','; // Mainline            
            exportData += (plbRecord.Address_1__c != null ? '"' + String.ValueOf(plbRecord.Address_1__c)+ '"' : '') + ',';             
            //exportData += StringUtility.wrapEscape(plbRecord.Address_2__c,',','""') + ','; //Mainline            
            exportData += (plbRecord.Address_2__c != null ? '"' + String.ValueOf(plbRecord.Address_2__c)+ '"' : '') + ',';
            exportData += (plbRecord.Address_3__c != null ? '"' + String.ValueOf(plbRecord.Address_3__c)+ '"' : '') + ',';
            exportData += (plbRecord.Address_4__c != null ? '"' + String.ValueOf(plbRecord.Address_4__c)+ '"' : '') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Section_Code__c,',','""') + ',';
            //exportData += StringUtility.wrapEscape(plbRecord.Department__c,',','""') + ',';
            exportData += (plbRecord.Department__c != null ? '"' + String.ValueOf(plbRecord.Department__c)+ '"' : '') + ','; 
            exportData += StringUtility.wrapEscape(plbRecord.Division_Code__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Company_Code__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.Location_Code__c,',','""') + ',';
            exportData += (plbRecord.Airline_Number__c != null ? '"' + String.ValueOf(plbRecord.Airline_Number__c)+ '"' : '') + ',';
            //exportData += StringUtility.wrapEscape(plbRecord.Airline_Packing_Group__c,',','""') + ',';
            exportData += (plbRecord.Airline_Packing_Group__c != null ? '"' + String.ValueOf(plbRecord.Airline_Packing_Group__c)+ '"' : '') + ','; 
            //exportData += StringUtility.wrapEscape(plbRecord.Packing_Group_Description__c,',','""') + ',';
            exportData += (plbRecord.Packing_Group_Description__c != null ? '"' + String.ValueOf(plbRecord.Packing_Group_Description__c)+ '"' : '') + ','; 
            exportData += StringUtility.wrapEscape(plbRecord.Airline_City_Code__c,',','""') + ',';
            exportData += (plbRecord.Flight_Number__c != null ? '"' + String.ValueOf(plbRecord.Flight_Number__c)+ '"' : '') + ',';
            exportData += (plbRecord.Flight_Number_2__c != null ? '"' + String.ValueOf(plbRecord.Flight_Number_2__c)+ '"' : '') + ',';
            //exportData += StringUtility.wrapEscape(plbRecord.Airline_Name__c,',','""') + ',';
            exportData += (plbRecord.Airline_Name__c != null ? '"' + String.ValueOf(plbRecord.Airline_Name__c)+ '"' : '') + ','; 
            exportData += StringUtility.wrapEscape(plbRecord.Sequence_Number__c,',','""') + ',';
            exportData += StringUtility.wrapEscape(plbRecord.City_Code__c,',','""') + ',';
            //exportData += StringUtility.wrapEscape(plbRecord.Remarks__c,',','""') + ',';          
            exportData += (plbRecord.Remarks__c != null ? '"' + String.ValueOf(plbRecord.Remarks__c)+ '"' : '') + ','; 
            exportData += StringUtility.wrapEscape(plbRecord.Freelist_Indicator__c,',','""') + ',';                 
            
            
            
            exportData = exportData.replaceAll('\r\n', ' ');
            exportData = exportData.replaceAll('\n', ' ');
            exportData = exportData.replaceAll('\r', ' ');
            exportData = exportData.replaceAll(':', '');
            
            /*
            for(Integer index = 0; index < invalidCharacterArray.size(); index++) {               
                exportData = exportData.replaceAll(invalidCharacterArray[index],'');                
            }
            */           
            
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
  
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_CMI102DX_ExportPackingLabel insert operation failed.');
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID(interfaceId);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}