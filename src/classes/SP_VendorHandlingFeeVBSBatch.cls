/**
* Class Name: SP_VendorHandlingFeeVBSBatch 
* @author: Joban Bir Singh 
* Date: 
* Requirement/Project Name: CRSM Project
* @description Batch Apex Class to create record in Vendor Monthly Data and calculate the 
* Vendor Handling Fee, summation of Commissions, Insertions, and Pagination for VBS
* @History - UD-1917 Wenjun 24/07/15 : Change the constructor to accept custom date range
*/
     
global class SP_VendorHandlingFeeVBSBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global final Id JOB_ID;
    global final Date monthStart;
    global final Date monthEnd;
  
    global SP_VendorHandlingFeeVBSBatch(Id jobID, Date fromDate, Date toDate){
      this.JOB_ID = jobID;
      this.monthStart = fromDate;
      this.monthEnd = toDate;
    }
      
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name,Vendor_Code__c FROM Account WHERE RecordType.DeveloperName = \'Vendor\' ';
        query       += 'AND Vendor_code__c != Null';
        return Database.getQueryLocator(query);
    }
    
   global void execute(Database.BatchableContext BC, List<Account> lstVendors){
        Set<String> vendorCodeSet = New Set<String>();      
        List<BT_CO_VBS_CreditDebit__c> lstVBSToUpsert = New List<BT_CO_VBS_CreditDebit__c>();
        Map<String,BT_CO_VBS_CreditDebit__c> mapVBSOldRecords = New Map<String,BT_CO_VBS_CreditDebit__c>();
        Set<String> setReasonCodes = new Set<String>();
        
        //Reason Code Set
        setReasonCodes.add(GlobalVariableClass.REASON_CD_COM);
        setReasonCodes.add(GlobalVariableClass.REASON_CD_PAGE);
        setReasonCodes.add(GlobalVariableClass.REASON_CD_INST);
        
        for(Account vendor : lstVendors)    
            vendorCodeSet.add(vendor.Vendor_code__c);
        
        for(BT_CO_VBS_CreditDebit__c oldVBS :[Select ID, Vendor_Number__c, Vendor_Group__c, Posting_Date__c, 
                                Publication_Code__c, Amt_Before_GST__c, Reason_Code__c  
                                From BT_CO_VBS_CreditDebit__c 
                                Where Credit_Debit__c = :GlobalVariableClass.CREDIT_IND AND Posting_Date__c >= :monthStart
                                AND Posting_Date__c <= :monthEnd AND Vendor_Number__c IN :vendorCodeSet AND Reason_Code__c IN :setReasonCodes])
        {
            String vbsKey = oldVBS.Vendor_Number__c + '' + oldVBS.Vendor_Group__c + '' 
                + oldVBS.Publication_Code__c + '' + oldVBS.Posting_Date__c + '' + oldVBS.Reason_Code__c;
            mapVBSOldRecords.put(vbsKey, oldVBS);
        }
        
        for (AggregateResult vssSum : [Select Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c, 
                                SUM(Commission__c), SUM(Pagination__c), SUM(Insertion__c) 
                                From BT_CO_VSS_CreditDebit__c Where Credit_Debit__c = : GlobalVariableClass.CREDIT_IND AND Job_Id__c = 'SP016'
                                AND Vendor_Number__c in :vendorCodeSet  AND Posting_Date__c >= :monthStart AND Posting_Date__c <= :monthEnd 
                                Group By Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c])  
        {
            String vssKey = vssSum.get('Vendor_Number__c') + '' + vssSum.get('Vendor_Group__c') + '' 
                            + vssSum.get('Publication_Code__c') + '' + vssSum.get('Posting_Date__c');
                            
            BT_CO_VBS_CreditDebit__c vbsCom;
            BT_CO_VBS_CreditDebit__c vbsPage;
            BT_CO_VBS_CreditDebit__c vbsInst;
            
            //Commission
            String vssComKey = vssKey + '' + GlobalVariableClass.REASON_CD_COM;
            if(mapVBSOldRecords.containsKey(vssComKey)) //Update existing Record
            {
                vbsCom = mapVBSOldRecords.get(vssComKey);
                vbsCom.Amt_Before_GST__c = (Decimal)vssSum.get('expr0');
            }
            else //Create New Record
            {
                vbsCom = new BT_CO_VBS_CreditDebit__c();
                vbsCom.Amt_Before_GST__c = (Decimal)vssSum.get('expr0');
                vbsCom.GST_Amount__c = 0.00;
                vbsCom.Vendor_Group__c = (String)vssSum.get('Vendor_Group__c');
                vbsCom.Vendor_Number__c = (String)vssSum.get('Vendor_Number__c');  
                vbsCom.Publication_Code__c = (String)vssSum.get('Publication_Code__c');
                vbsCom.Posting_Date__c = monthEnd;
                vbsCom.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
                vbsCom.Reason_Code__c = GlobalVariableClass.REASON_CD_COM; 
            }
            
            //Pagination
            String vssPageKey = vssKey + '' + GlobalVariableClass.REASON_CD_PAGE;
            if(mapVBSOldRecords.containsKey(vssPageKey)) //Update existing Record
            {
                vbsPage = mapVBSOldRecords.get(vssPageKey);
                vbsPage.Amt_Before_GST__c = (Decimal)vssSum.get('expr1'); //START END D-2261 Wenjun 20/03/15
            }
            else //Create New Record
            {
                vbsPage = new BT_CO_VBS_CreditDebit__c();
                vbsPage.Amt_Before_GST__c = (Decimal)vssSum.get('expr1'); //START END D-2261 Wenjun 20/03/15
                vbsPage.GST_Amount__c = 0.00;
                vbsPage.Vendor_Group__c = (String)vssSum.get('Vendor_Group__c');
                vbsPage.Vendor_Number__c = (String)vssSum.get('Vendor_Number__c');  
                vbsPage.Publication_Code__c = (String)vssSum.get('Publication_Code__c');
                vbsPage.Posting_Date__c = monthEnd;
                vbsPage.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
                vbsPage.Reason_Code__c = GlobalVariableClass.REASON_CD_PAGE; 
            }
            
            //Insertion
            String vssInstKey = vssKey + '' + GlobalVariableClass.REASON_CD_INST;
            if(mapVBSOldRecords.containsKey(vssInstKey)) //Update existing Record
            {
                vbsInst = mapVBSOldRecords.get(vssInstKey);
                vbsInst.Amt_Before_GST__c = (Decimal)vssSum.get('expr2'); //START END D-2261 Wenjun 20/03/15
            }
            else //Create New Record
            {
                vbsInst = new BT_CO_VBS_CreditDebit__c();
                vbsInst.Amt_Before_GST__c = (Decimal)vssSum.get('expr2'); //START END D-2261 Wenjun 20/03/15
                vbsInst.GST_Amount__c = 0.00;
                vbsInst.Vendor_Group__c = (String)vssSum.get('Vendor_Group__c');
                vbsInst.Vendor_Number__c = (String)vssSum.get('Vendor_Number__c');  
                vbsInst.Publication_Code__c = (String)vssSum.get('Publication_Code__c');
                vbsInst.Posting_Date__c = monthEnd;
                vbsInst.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
                vbsInst.Reason_Code__c = GlobalVariableClass.REASON_CD_INST; 
            }
            
            if(vbsCom!= null){
                vbsCom.Job_Id__c = 'SP016'; //START/END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
                lstVBSToUpsert.add(vbsCom);
            }
            if(vbsPage!= null){
                vbsPage.Job_Id__c = 'SP016'; //START/END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
                lstVBSToUpsert.add(vbsPage);
            }
            if(vbsInst!= null){
                vbsInst.Job_Id__c = 'SP016'; //START/END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
                lstVBSToUpsert.add(vbsInst);
            }
        }
        
        //Perform UPSERT
        if(!lstVBSToUpsert.isEmpty())
            UPSERT lstVBSToUpsert; 
    }
    
    global void finish(Database.BatchableContext BC) {   
        //START 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
        SP_PopulateVDCCreditNotes batchInstance = new SP_PopulateVDCCreditNotes('SP016',JOB_ID, monthStart, monthEnd);
        Database.executeBatch(batchInstance);
        //END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
    }
}