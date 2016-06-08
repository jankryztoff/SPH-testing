/**
 * Class Name: SP_VBSDeliveryFeeBatch
 * @Author: Wenjun Zhu
 * @Date: 16/March/2015
 * @description: Batch Class that creates Monthly Delivery Fee Vendor Credit / Debit data for VBS
 * History: [E2E Hotfix] Wenjun 01-08-15 - Support custom data range
 */
global class SP_VBSDeliveryFeeBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global final Id JOB_ID;
    global final Date monthStart;
    global final Date monthEnd;
	//START HotFix 17-Aug-2015 Added by Raviteja - applying New Logic for ManualRun           
     global Boolean ismanualrun = False;
    //End HotFix 17-Aug-2015 Added by Raviteja
  
    global SP_VBSDeliveryFeeBatch(Id jobID){
      JOB_ID = jobID;
      this.monthStart = Date.today().toStartOfMonth();
      this.monthEnd = monthStart.addMonths(1).addDays(-1);
    }
    
    global SP_VBSDeliveryFeeBatch(Id jobID, Date dtMthEnd){
      JOB_ID = jobID;
      this.monthEnd = dtMthEnd;
      this.monthStart = dtMthEnd.toStartOfMonth();
	  ismanualrun = True; //START/End HotFix 17-Aug-2015 Added by Raviteja - applying New Logic for ManualRun		
    }
     
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Vendor_Code__c FROM Account WHERE RecordType.DeveloperName = \'Vendor\' ';
        query       += 'AND Vendor_code__c != Null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> lstVendors){
        Set<String> vendorCodeSet = New Set<String>();      
        List<BT_CO_VBS_CreditDebit__c> lstVBSToUpsert = New List<BT_CO_VBS_CreditDebit__c>();
        Map<String,BT_CO_VBS_CreditDebit__c> mapVBSOldRecords = New Map<String,BT_CO_VBS_CreditDebit__c>();
        
        for(Account vendor : lstVendors)    
            vendorCodeSet.add(vendor.Vendor_code__c);
        
        for(BT_CO_VBS_CreditDebit__c oldVBS :[Select ID, Vendor_Number__c,Vendor_Group__c,Posting_Date__c,Amt_Before_GST__c,GST_Amount__c 
                                          From BT_CO_VBS_CreditDebit__c 
                                          Where Credit_Debit__c = :GlobalVariableClass.CREDIT_IND 
                                          AND Posting_Date__c >= :monthStart  AND Posting_Date__c <= :monthEnd
                                          AND Vendor_Number__c in :vendorCodeSet AND Reason_Code__c = :GlobalVariableClass.REASON_CD_DEL])
        {
            String vbsKey = oldVBS.Vendor_Number__c + '' + oldVBS.Vendor_Group__c + '' + oldVBS.Posting_Date__c;
            mapVBSOldRecords.put(vbsKey, oldVBS);
        }
        
        for (AggregateResult vssSum : [Select Vendor_Number__c, Vendor_Group__c, Posting_Date__c, SUM(Delivery__c) amountSum
                                    From BT_CO_VSS_CreditDebit__c Where Credit_Debit__c = : GlobalVariableClass.CREDIT_IND 
                                    AND Vendor_Number__c in :vendorCodeSet AND Delivery__c != 0.00 
                                    AND Posting_Date__c >= :monthStart  AND Posting_Date__c <= :monthEnd
                                    Group By Vendor_Number__c, Vendor_Group__c, Posting_Date__c])  
        {
            String vssKey = vssSum.get('Vendor_Number__c') + ''+ vssSum.get('Vendor_Group__c') + ''+ vssSum.get('Posting_Date__c');
            BT_CO_VBS_CreditDebit__c vbsObj;
            
            if(mapVBSOldRecords.containsKey(vssKey)) //Update existing Record
            {
                vbsObj = mapVBSOldRecords.get(vssKey);
                vbsObj.Amt_Before_GST__c = (Decimal)vssSum.get('amountSum');
            }
            else //Create New Record
            {
                vbsObj = new BT_CO_VBS_CreditDebit__c();
                vbsObj.Amt_Before_GST__c = (Decimal)vssSum.get('amountSum');
                vbsObj.GST_Amount__c = 0.00;
                vbsObj.Vendor_Group__c = (String)vssSum.get('Vendor_Group__c');
                vbsObj.Vendor_Number__c = (String)vssSum.get('Vendor_Number__c');                    
                vbsObj.Posting_Date__c = this.monthEnd;
                vbsObj.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
                vbsObj.Reason_Code__c = GlobalVariableClass.REASON_CD_DEL; 
            }
            
            if(vbsObj!= null){
                vbsObj.Job_Id__c = 'SP011'; //START/END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
                lstVBSToUpsert.add(vbsObj);
            }
        }
        
        //Perform UPSERT
        if(!lstVBSToUpsert.isEmpty())
            UPSERT lstVBSToUpsert; 
    }
    
    global void finish(Database.BatchableContext BC) {   
		//START HotFix 17-Aug-2015 Added by Raviteja - applying New Logic for ManualRun
        /*//START 03/19/2015 MD-50 Kevin Evasco Credit Note Generation        
        SP_PopulateVDCCreditNotes batchInstance = new SP_PopulateVDCCreditNotes('SP011',JOB_ID);
        Database.executeBatch(batchInstance);
        //END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
		*/
        SP_PopulateVDCCreditNotes batchInstance;
        if(ismanualrun){
                batchInstance = new SP_PopulateVDCCreditNotes('SP011',JOB_ID, monthStart,monthEnd);
                Database.executeBatch(batchInstance); 
            }
            else{
                batchInstance = new SP_PopulateVDCCreditNotes('SP011',JOB_ID);
                Database.executeBatch(batchInstance);
            }
        //End HotFix 17-Aug-2015 Added by Raviteja - applying New Logic for ManualRun
      }
}