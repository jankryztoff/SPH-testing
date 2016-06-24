/**
 * Class Name:  SP_VBSManualCreditBatch
 * @author: Zhu, Wenjun
 * Date: 16 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: Generate VBS Records for Manual Vendor Credit / Debit
 * UD-3618 07-Jan-2016 Added by Raviteja - Restructure the class
 */
 
global class  SP_VBSManualCreditBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {    

    global final Id JOB_ID;
    global Date startDate;
    global Date endDate;
    global Boolean isManualrun = False;
    Boolean isApexJobSuccessful = true; 
  
    global SP_VBSManualCreditBatch(Id jobID){
      JOB_ID = jobID;
      startDate = Date.today()-1;
      endDate = Date.today();     
    }
    
    global SP_VBSManualCreditBatch(Id jobID, Date startDateX, Date endDateX){
      JOB_ID = jobID;
      startDate = startDateX;
      endDate = endDateX;      
      isManualrun = True;      
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Vendor_Code__c FROM Account WHERE RecordType.DeveloperName = \'Vendor\' ';
        query       += 'AND Vendor_code__c != Null AND Active__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> lstVendors){
       
        Logger logger = new Logger(SP_VBSManualCreditBatch.class.getName(), 'SP002', BC.getJobID()); 
        Savepoint sp = Database.setSavepoint();
        
        try {
            Set<String> vendorCodeSet = New Set<String>();      
            List<BT_CO_VBS_CreditDebit__c> lstVBSToInsert = New List<BT_CO_VBS_CreditDebit__c>();
            
            for(Account vendor : lstVendors)    
                vendorCodeSet.add(vendor.Vendor_code__c);
            
            //Process Credit Records            
            Decimal vGstRate = 0;
            List<Other__c> gstSettingList = [SELECT Id, Value__c FROM Other__c WHERE Name = 'GST'];
            if(gstSettingList != null && gstSettingList.size() > 0) {
            Other__c gstSetting = gstSettingList.get(0);
                try{
                    Decimal z = Decimal.valueOf(gstSetting.Value__c) / 100;                     
                    z = z.setScale(2);
                    vGstRate = z.setScale(4);                       
                } catch(Exception e) {}
            }
     
             for (AggregateResult vssSum : [Select Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c, Manual_VDC_reason_code__c, SUM(Manual_Amt__c)
                                        From BT_CO_VSS_CreditDebit__c Where Credit_Debit__c = : GlobalVariableClass.CREDIT_IND 
                                        AND Vendor_Number__c in :vendorCodeSet AND Manual_Amt__c != 0.00 AND Note_Number__c = Null AND Posting_Date__c >= :startDate  AND Posting_Date__c <= :endDate
                                        Group By Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c, Manual_VDC_reason_code__c])  

            {
                BT_CO_VBS_CreditDebit__c vbsObj = new BT_CO_VBS_CreditDebit__c();            
                vbsObj.Vendor_Group__c = (String)vssSum.get('Vendor_Group__c');
                vbsObj.Vendor_Number__c = (String)vssSum.get('Vendor_Number__c'); 
                vbsObj.Publication_Code__c = (String)vssSum.get('Publication_Code__c');         
                vbsObj.Posting_Date__c = (Date)vssSum.get('Posting_Date__c');   
                vbsObj.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;               
                vbsObj.Reason_Code__c = (String)vssSum.get('Manual_VDC_reason_code__c');
                vbsObj.Amt_Before_GST__c = ((vbsObj.Reason_Code__c == '01' || vbsObj.Reason_Code__c == '03') ? (((Decimal)vssSum.get('expr0'))/(1.0+vGstRate)).setScale(2) : (Decimal)vssSum.get('expr0'));
                vbsObj.GST_Amount__c = ((vbsObj.Reason_Code__c == '01' || vbsObj.Reason_Code__c == '03') ? (Decimal)vssSum.get('expr0') - vbsObj.Amt_Before_GST__c : 0.0);
                vbsObj.Job_Id__c = 'SP002'; //START/END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
                lstVBSToInsert.add(vbsObj);
            }
            
          
            //Process Debit Records           
            for (AggregateResult vssSum : [Select Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c ,Manual_VDC_reason_code__c, SUM(Manual_Amt__c)
                                        From BT_CO_VSS_CreditDebit__c Where Credit_Debit__c = : GlobalVariableClass.DEBIT_IND                                        
                                        AND Vendor_Number__c in :vendorCodeSet AND Manual_Amt__c != 0.00 AND Note_Number__c = Null AND Posting_Date__c >= :startDate  AND Posting_Date__c <= :endDate 
                                        Group By Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c, Manual_VDC_reason_code__c])  

            {           
                BT_CO_VBS_CreditDebit__c vbsObj = new BT_CO_VBS_CreditDebit__c();
                           
                vbsObj.Reason_Code__c = (String)vssSum.get('Manual_VDC_reason_code__c');
                vbsObj.Amt_Before_GST__c = ((vbsObj.Reason_Code__c == '01' || vbsObj.Reason_Code__c == '03') ? (((Decimal)vssSum.get('expr0'))/(1.0+vGstRate)).setScale(2) : (Decimal)vssSum.get('expr0'));
                vbsObj.GST_Amount__c = ((vbsObj.Reason_Code__c == '01' || vbsObj.Reason_Code__c == '03') ? (Decimal)vssSum.get('expr0') - vbsObj.Amt_Before_GST__c : 0.0);              
                vbsObj.Vendor_Group__c = (String)vssSum.get('Vendor_Group__c');
                vbsObj.Vendor_Number__c = (String)vssSum.get('Vendor_Number__c'); 
                vbsObj.Publication_Code__c = (String)vssSum.get('Publication_Code__c');         
                vbsObj.Posting_Date__c = (Date)vssSum.get('Posting_Date__c');   
                vbsObj.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;                           
                vbsObj.Job_Id__c = 'SP002';
                lstVBSToInsert.add(vbsObj);
            }
          
            //Perform UPSERT
            if(!lstVBSToInsert.isEmpty())
                INSERT lstVBSToInsert; 
        } catch(Exception e){
            Database.rollback(sp);
            logger.logBatchFailure(e, lstVendors);
            logger.save();
            
            isApexJobSuccessful = false;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {        
        
        SP_PopulateVDCCreditNotes batchInstance;
        
        if(isManualrun){
            batchInstance = new SP_PopulateVDCCreditNotes('SP002',JOB_ID, startDate, endDate);
            Database.executeBatch(batchInstance);
        }else {
            batchInstance = new SP_PopulateVDCCreditNotes('SP002',JOB_ID);
            Database.executeBatch(batchInstance);
        }
     
    }
}