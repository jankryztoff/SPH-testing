/*
 * Class Name: BT_AB_HDS039DX_SubscriptionIssuesFile
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - HDS039DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for HDS039DX batch job. Used together with BT_AS_HDS039DX_SubscriptionIssuesFile Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 * History: 11/09/2014 Renino Niefes code implementation
 * History: 16/12/2014 Wenjun D-1167
 */


global class BT_AB_HDS039DX_SubscriptionIssuesFile implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    //global final String query = 'SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = \'HDS039DX Sample Source\'';    
    global final String interfaceId = 'HDS039DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;  
        
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_ToMonthEnd(batchRunDate);
        DateTime cutOffStart = DateUtility.convertDateFromYYYY_MM_DD_ToMonthStart(batchRunDate);
        
        String query = '';
        query += 'SELECT Subscription__r.Account_Record_Type__c,';
        query += ' Vendor_Number__c,';
        query += ' Publication_Code__c,';
        query += ' Subscription__r.Contact__r.Address__r.Block_House_Number__c,';
        query += ' Subscription__r.Contact__r.Address__r.Level_Number__c,';
        query += ' Subscription__r.Contact__r.Address__r.Unit_Number__c,';
        query += ' Subscription__r.Contact__r.Address__r.Postal_Code__r.Name,';
        query += ' Subscription__r.Contact__r.Address__r.Street_Name__c,';
        query += ' Subscription__r.Contact__r.Address__r.Building_Name__c,';
        query += ' Subscription__r.Contact__r.Address__r.Address_Unique_ID__c,';
        query += ' Subscription__r.Zuora__SubscriptionStartDate__c,';
        query += ' Subscription__r.Zuora__SubscriptionEndDate__c,';
        query += ' Copies__c,';
        query += ' Amount_Type__c,';
        query += ' Total__c,';
        query += ' Subscription__r.Product_Code__c,';
        query += ' Subscription__r.Effective_Start_Date__c,';
        query += ' Subscription__r.Effective_End_Date__c,';
        query += ' Subscription__r.Sponsored_Indicator__c,';
        query += ' Credit_Debit__c,';
        query += ' Credit_Period__c,';
        query += ' Subscription__r.Zuora__Account__r.ID,';
        query += ' Subscription__r.Contact__r.ID,';
        query += ' Subscription__r.ID, ';  
        //START D-1167 16/12/14 Added by Wenjun : Account Number, Contact Number and Subscription Number
        query += ' Subscription__r.Zuora__Account__r.Account_Auto_Number__c,';
        query += ' Subscription__r.Contact__r.Recipient_Number__c,';
        query += ' Subscription__r.Name, '; 
        //END D-1167
        query += ' Subscription__r.Order_Number_1__r.DOW_Pattern__c ';
        query += ' FROM Vendor_Monthly_Data__c';
        query += ' WHERE Credit_Period__c >= ' + cutOffStart.format('yyyy-MM-dd');
        query += ' AND Credit_Period__c <= ' + cutOffEnd.format('yyyy-MM-dd');
        
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        
        for(sObject record : scope)
        {                       
            Vendor_Monthly_Data__c so = (Vendor_Monthly_Data__c)record;
        
            String exportData = '';     
            //Cus Grp  - clarify how to we know what ID to use for the grouping?
            if (so.Subscription__r.Account_Record_Type__c=='Direct Individual') {
                exportData += 'null,';//Cus Grp 
            } else {
                exportData += 'null,';//Cus Grp 
            }           
            
            exportData += so.Vendor_Number__c + ',';//Vendor Number 
            exportData += 'null,';//Subscriber Account 
            exportData += 'null,';//Recipient Account 
            exportData += so.Publication_Code__c + ',';//Publication Code 
            exportData += 'null,';//Publication Tag 
            exportData += so.Subscription__r.Contact__r.Address__r.Block_House_Number__c + ',';//Block Number 
            exportData += so.Subscription__r.Contact__r.Address__r.Level_Number__c + ',';//Level Number 
            exportData += so.Subscription__r.Contact__r.Address__r.Unit_Number__c + ',';//Unit Number 
            exportData += so.Subscription__r.Contact__r.Address__r.Postal_Code__r.Name + ',';//Postal Code 
            exportData += so.Subscription__r.Contact__r.Address__r.Street_Name__c + ',';//Street Name 
            exportData += so.Subscription__r.Contact__r.Address__r.Building_Name__c + ',';//Building Name 
            exportData += so.Subscription__r.Contact__r.Address__r.Address_Unique_ID__c + ',';//Address Line 
            exportData += so.Subscription__r.Zuora__SubscriptionStartDate__c + ',';//From Date 
            exportData += so.Subscription__r.Zuora__SubscriptionEndDate__c + ',';//To Date 
            exportData += so.Copies__c + ',';//Copies 
            
            //Amount type = Commission, Pagination, Delivery Rate, Insertion, Deilvery Fee, Miscellaneous
            //Question:  How about Commission and Pagination?
            //Handling Charge = Miscellaneous           
            if (so.Amount_Type__c=='Miscellaneous') {
                exportData += so.Total__c + ',';//Handling Charge 
            } else {
                exportData += 'null,';
            }
            
            //Insertion Fee = Insertion
            if (so.Amount_Type__c=='Insertion') {
                exportData += so.Total__c + ',';//Insertion Fee 
            } else {
                exportData += 'null,';
            }
            
            //Delivery Fee = Delivery Rate
            if (so.Amount_Type__c=='Delivery Rate'||so.Amount_Type__c=='Delivery Fee') {
                exportData += so.Total__c + ',';//Delivery Fee 
            } else {
                exportData += 'null,';
            }
            
            exportData += so.Total__c + ',';//Total Amount 
            exportData += 'null,';//C/N number 
            exportData += so.Subscription__r.Product_Code__c + ',';//Product Code 
            exportData += so.Subscription__r.Effective_Start_Date__c + ',';//Start Date 
            exportData += so.Subscription__r.Effective_End_Date__c + ',';//Stop Date 
            exportData += so.Subscription__r.Order_Number_1__r.DOW_Pattern__c + ',';//Day of week pattern 
            exportData += 'null,';//Free Gift 
            exportData += so.Subscription__r.Sponsored_Indicator__c + ',';//Sponsored Indicator 
            
            //CR/DR indicator 
            if (so.Credit_Debit__c=='Credit') {
                exportData += 'C,';//CR/DR indicator 
            } else {
                exportData += 'D,';//CR/DR indicator 
            }
            
            exportData += so.Credit_Period__c + ',';//Transaction Date 
            
            //START D-1167 16/12/14 Added by Wenjun : Account Number, Contact Number, Subscription Number and Account Sub Group
            /* D-1167: according to FDS, it should not be the 18-character Row ID but a system generated sequence number
            exportData += so.Subscription__r.Zuora__Account__r.ID + ',';//CRSM Account ID
            exportData += so.Subscription__r.Contact__r.ID + ',';//CRSM Contact ID
            exportData += so.Subscription__r.ID + ',';//CRSM Direct Subscription ID
			*/ 
            exportData += so.Subscription__r.Zuora__Account__r.Account_Auto_Number__c + ',';//CRSM Account Number
            exportData += so.Subscription__r.Contact__r.Recipient_Number__c + ','; //CRSM Contact Number
            exportData += so.Subscription__r.Name + ',';//CRSM Direct Subscription Number - Generated from Zuora
            //END D-1167
            
            exportData += 'null,';//Day of week pattern (PHe)
                
        
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
            System.debug('BT_AB_HDS039DX_SubscriptionIssuesFile insert operation failed.');
        }
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
       //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
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