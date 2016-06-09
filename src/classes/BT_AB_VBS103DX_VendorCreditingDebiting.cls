/*
 * Class Name: BT_AB_VBS103DX_VendorCreditingDebiting
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - VBS103DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for VBS103DX batch job. Used together with BT_AS_VBS103DX_VendorCreditingDebiting Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 *          2014/09/29 Renino Niefes added code implementations
 *          2015/01/27 Renino Niefes D-1830 fix the missing fields
 *          2015/02/25 Michael Francisco D-1830 added validation rules and Handling Fee value
 *          2015/03/19 Michael Francisco D-2562 modified to address changes to Scheduled Process 
 *                                              that required creation of new Salesforce 
 *                                              Custom Object BT_CO_VBS_CreditDebit__c. Removed
 *                                              comments and code sections that no longer apply.
 *          2015/04/24 Renino Niefes UD-1014 Put back the publication Code as it was a mistake on FDS.  It is still needed for this interface
 *          2015/05/06 Renino Niefes UD-1014 Put back the publication Code as it was a mistake on FDS.  It is still needed for this interface
 *  UD-3618 07-Jan-2016 Added by Raviteja - Restructure the class
 */


global class BT_AB_VBS103DX_VendorCreditingDebiting implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.stateful
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    //global final String query = 'SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = \'VBS103DX Sample Source\'';    
    global final String interfaceId = 'VBS103DX';      
   
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList; 
    
        //Prepare the cut off dates.  11AM of previous day to 11AM current day.  Use Batch Run Date as current date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_ToMonthEnd(batchRunDate);
        DateTime cutOffStart = DateUtility.convertDateFromYYYY_MM_DD_ToMonthStart(batchRunDate);
        
        //Nitin Khanna : 29-6-2015 : HOTFIX : UD-1650 : setting up only manual VDC to be sent out on the day of generation
        DateTime dtBatchRunDate = DateUtility.convertDateFromYYYY_MM_DDtHH_MM_SSz(batchRunDate+'T23:59:59Z');
        Boolean isEOM = true;
        
        DateTime dtpreviousDate = dtBatchRunDate.addDays(-2);       
        String strpreviousDate = dtpreviousDate.format('yyyy-MM-dd');
       
        System.debug('SZ0 ----> Batch Run Date converted----> ' + dtBatchRunDate);
        System.debug('SZ1 ----> Batch Run Date ----> ' + batchRunDate);
        System.debug('SZ2 ----> cutOffEnd ----> ' + cutOffEnd);
        System.debug('SZ3 ----> cutOffStart ----> ' + cutOffStart);
        System.debug('SZ4 ----> dtpreviousDate ----> ' + dtpreviousDate);
        System.debug('SZ5 ----> strpreviousDate ----> ' + strpreviousDate);
        
        if(dtBatchRunDate != cutOffEnd){
            isEOM = FALSE;
        }
        //Nitin Khanna : 29-6-2015 : HOTFIX : UD-1650 : setting up only manual VDC to be sent out on the day of generation
        
        // START - 2015/03/19 - D-2562 - Michael Francisco - Created new query 
        String query = '';
        query += ' SELECT Credit_Debit__c, ';
        query += '  Vendor_Group__c, ';
        query += '  Vendor_Number__c, ';
        query += '  Note_Number__c, ';
        query += '  Reason_Code__c, ';
        query += '  Amt_Before_GST__c, ';
        query += '  GST_Amount__c, ';
        query += '  Name, ';
        query += '  Publication_Code__c, ';
        query += '  Posting_Date__c, ';
        query += '  Id, ';
        query += '  IsDeleted, ';
        query += '  Job_Id__c ';
        query += ' FROM BT_CO_VBS_CreditDebit__c ';
        query += ' WHERE '; 
        query += ' IsDeleted = FALSE '; 
        
        //Nitin Khanna : 29-6-2015 : HOTFIX : UD-1650 : setting up only manual VDC to be sent out on the day of generation
        if(isEOM){
            System.debug('SZ4 ----> EOM == true ? ----> ' + isEOM);
            query += ' AND (( Posting_Date__c >= ' + cutOffStart.format('yyyy-MM-dd');
            query += ' AND Posting_Date__c <= ' + cutOffEnd.format('yyyy-MM-dd');  
            query += ' AND Reason_Code__c not in (\'01\',\'02\',\'03\',\'04\') ) ';
            query += ' OR ( Reason_Code__c in (\'01\',\'02\',\'03\',\'04\') ';
            query += ' AND isJobProcessed__c = FALSE ' ;
            query += ' AND Posting_Date__c >= ' + strpreviousDate ;
            query += ' AND Posting_Date__c <= ' + dtBatchRunDate.format('yyyy-MM-dd') +')) ';
        }else{
            System.debug('SZ5 ----> EOM == true ? ----> ' + isEOM);           
           
            query += ' AND ( Posting_Date__c >= ' + strpreviousDate ;
            query += ' AND Posting_Date__c <= ' + batchRunDate + ') '; 
            query += ' AND isJobProcessed__c = FALSE ' ;
            query += ' AND Reason_Code__c in (\'01\',\'02\',\'03\',\'04\') ';
        }
         
        query += ' AND Amt_Before_GST__c > 0 ';  
        
        System.debug('SZ6 ----> query ----> ' + query);
        
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
       
        Logger logger = new Logger(BT_AB_VBS103DX_VendorCreditingDebiting.class.getName(),'VBS103');  
        BT_CO_VBS_CreditDebit__c vbserr = New BT_CO_VBS_CreditDebit__c();     
        List<BT_CO_VBS_CreditDebit__c> lstupdatevbs = New List<BT_CO_VBS_CreditDebit__c>();  
       
        
        try{
        
        for(sObject record : scope)
        {  
            vbserr = (BT_CO_VBS_CreditDebit__c)record;
                      
            BT_CO_VBS_CreditDebit__c vbs_record = (BT_CO_VBS_CreditDebit__c)record;
            
            String zVALIDATION_CODE = '0';            
            String zCreditDebitIndicator = vbs_record.Credit_Debit__c;            
         
            String zCreditDebitNoteNumber = null;
            if (vbs_record.Note_Number__c!=null) {
                zCreditDebitNoteNumber = vbs_record.Note_Number__c.toPlainString();
            }
          
            String zName = vbs_record.Name;
            String zVendorGroup = vbs_record.Vendor_Group__c;
            String zVendorNumber = vbs_record.Vendor_Number__c;
            String zPubCode = vbs_record.Publication_Code__c;
            String zReasonCode = vbs_record.Reason_Code__c;
            Date zPostingDate = vbs_record.Posting_Date__c;
            
            // Validate Credit / Debit Indicator ...
            if (zCreditDebitIndicator != null && zCreditDebitIndicator.length() <= 2 && zCreditDebitIndicator.length() > 0) {
                zVALIDATION_CODE = '0';
            } else {
                zVALIDATION_CODE = '1';             
            }
            
            // Validate Credit / Debit Note Number in BT_CO_VBS_CreditDebit__c ...      
            if (zCreditDebitNoteNumber != null) {
                // If zNoteNumber longer than 12 digits replace all non-numeric characters ...
                if (zCreditDebitNoteNumber.length() > 12) {
                    zCreditDebitNoteNumber = zCreditDebitNoteNumber.replaceAll('[^0-9]','');
                }
            }
                      
            // Validate derived zCreditDebitNoteNumber value ...
            if (zCreditDebitNoteNumber.length() > 0 && zCreditDebitNoteNumber.length() <= 12) {
                zVALIDATION_CODE += '0';
            } else {
                zVALIDATION_CODE += '1';                 
            }
           
                        
            // Validate 'Vendor Group' in BT_CO_VBS_CreditDebit__c ...      
            if (zVendorGroup != null && zVendorGroup.length() > 0) {
                zVALIDATION_CODE += '0';
            } else {
                zVALIDATION_CODE += '1';    
            }
            
            // Validate 'Vendor Number' in BT_CO_VBS_CreditDebit__c ...
            if (zVendorNumber != null && zVendorNumber.length() > 0) {
                zVALIDATION_CODE += '0';
            } else {
                zVALIDATION_CODE += '1';    
            }           
            
            // Validate 'Reason Code' in BT_CO_VBS_CreditDebit__c ...
            if (zReasonCode != null && zReasonCode.length() > 0 && zReasonCode.length() <= 2) {
                zVALIDATION_CODE += '0';    
            } else {
                zVALIDATION_CODE += '1';                
            }
            
            // Validate Amount Before GST in BT_CO_VBS_CreditDebit__c ...
            Decimal zAmountBeforeGST = 0.0;
            try {
                zAmountBeforeGST = vbs_record.Amt_Before_GST__c;
                if (zAmountBeforeGST != null && zAmountBeforeGST >= 0.0) {
                    zVALIDATION_CODE += '0';                   
                    zAmountBeforeGST = zAmountBeforeGST.setScale(2);                    
                } else {
                    zVALIDATION_CODE += '1';                    
                }   
            } catch (Exception e) {
                zVALIDATION_CODE += '1';                                    
            }       
            
            // Validate GST Amount in BT_CO_VBS_CreditDebit__c ...
            Decimal dGSTAmount = 0.0;
            try {
                dGSTAmount = vbs_record.GST_Amount__c; 
                if (dGSTAmount != null && dGSTAmount >= 0.0) {
                    zVALIDATION_CODE += '0';                   
                    dGSTAmount = dGSTAmount.setScale(2);                   
                } else {
                    zVALIDATION_CODE += '1';                    
                }               
            } catch (Exception e) {
                zVALIDATION_CODE += '1';                                    
            }
            
            String exportData = '';  
            exportData += zCreditDebitIndicator + ',';  //Credit/Debit Indicator
            exportData += zCreditDebitNoteNumber + ','; //Credit/Debit Note Number
            exportData += zVendorGroup + ',';           //Vendor Group
            exportData += zVendorNumber + ',';          //Vendor Name          
            exportData += zPubCode + ',';               //Publication Code ====> Removed from FDS          
            exportData += zReasonCode + ',';            //Reason Code
            exportData += zAmountBeforeGST + ',';       //Amount before GST
            exportData += dGSTAmount + ',';             //GST Amount
            exportData += zPostingDate + ',';           //Posting Date
            
            Decimal validation_code = Decimal.valueOf(zVALIDATION_CODE);
            
            if (validation_code == 0) {
                // Prepare Data Pool information here
                BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
                datapoolRecord.Name = interfaceId;
                datapoolRecord.job_id__c = '1';
                datapoolRecord.group_id__c = 'Detail';
                datapoolRecord.run_for_date__c = Date.today();      
                datapoolRecord.insert_time__c = DateTime.now(); 
                datapoolRecord.export_data__c = exportData;             
                
                datapoolList.add(datapoolRecord);
            } else {
                // Added a line to help in debugging ...
                System.debug('EXPORT-FAILED (BT_CO_VBS_CreditDebit__c): ID:['+vbs_record.Id+'] - CODE:['+zVALIDATION_CODE+'] - DATA:'+exportData);
            }        
       
            //Updating  isJobProcessed__c to TRUE as part of yesterday missing records solution      
            System.debug('vbserr.Job_Id__c : '+vbserr.Job_Id__c);
            if(vbserr.Job_Id__c == 'SP002'){
                vbserr.isJobProcessed__c = TRUE;
                lstupdatevbs.add(vbserr);
            }
        }
        }catch (Exception e) {
                 String errmsg = String.ValueOf(vbserr.Id) + e.getTypeName() + e.getMessage() + e.getCause() + e.getLineNumber() + e.getStackTraceString();                  
                 logger.log(false,String.valueOf(errmsg));    
                 logger.save();                             
            }
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            System.debug('lstupdatevbs size : '+lstupdatevbs.size());
            System.debug('datapoolList size : '+datapoolList.size());
            
            insert datapoolList;
            
            // Updating VBS records which are proceed in VBS File for Manaul Vendor Credit Records - SP002
            System.debug('lstupdatevbs size : '+lstupdatevbs.size());
            if(!lstupdatevbs.isEmpty())
                update lstupdatevbs;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_VBS103DX_VendorCreditingDebiting insert operation failed.');
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