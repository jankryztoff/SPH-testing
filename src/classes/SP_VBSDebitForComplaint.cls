/**
 * Class Name: SP_VBSDebitForComplaint
 * @author: Raviteja Kumar
 * Date: 11-Mar-2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that creates Vendor Credit / Debit data for VBS
 * 
 * History: UD-1014 Wenjun 05/05/15: Update Reason Code Mapping - '24' for Courier Charge and 'D3' for Paper Fee
 */
global class SP_VBSDebitForComplaint implements Database.Batchable<sObject>, Database.AllowsCallouts
{

    global final Id job_ID;
    
    //START HotFix 20-July-2015 Added by Raviteja - applying New Logic for ManualRun      
     global Date startDate;
     global Date endDate;
     global Boolean ismanualrun = False;
    //End HotFix 20-July-2015 Added by Raviteja
   //Start HotFix 05-Aug-2015 Added by Raviteja - Updating logic for posting date  
    global Date postingDate;
   //End HotFix 05-Aug-2015 Added by Raviteja - Updating logic for posting date  
      
    global SP_VBSDebitForComplaint(Id jobID){
      job_ID = jobID;
      //START HotFix 20-July-2015 Added by Raviteja - applying New Logic for ManualRun 
      startDate = Date.today();
      //Start D-3576 HotFix 16-Sep-2015 Added by Raviteja - Updating enddate logic to MonthEnd
      //endDate = Date.today();      
      //End HotFix 20-July-2015 Added by Raviteja
      //Start HotFix 05-Aug-2015 Added by Raviteja - Updating logic for posting date  
       // Calculating Last day of the month
        Date monthStart = startDate.toStartOfMonth();
        Integer numberOfDays = Date.daysInMonth(monthStart.year(),monthStart.month());
        Date monthEnd = Date.newInstance(monthStart.year(), monthStart.month(), numberOfDays);
        postingDate = monthEnd;
        endDate = monthEnd;
       //End D-3576 HotFix 16-Sep-2015 Added by Raviteja 
       //End HotFix 05-Aug-2015 Added by Raviteja - Updating logic for posting date 
    }
    
    //START HotFix 20-July-2015 Added by Raviteja - applying New Logic for ManualRun 
    global SP_VBSDebitForComplaint(Id jobID, Date manualstartDate, Date manualendDate){
      job_ID = jobID;
      startDate = manualstartDate;
      endDate = manualendDate;
      ismanualrun = True;
      //Start HotFix 05-Aug-2015 Added by Raviteja - Updating logic for posting date  
        postingDate = endDate;
       //End HotFix 05-Aug-2015 Added by Raviteja - Updating logic for posting date 
    }
   //End HotFix 20-July-2015 Added by Raviteja
   
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bcTemp - predefined parameter 
    * @return list of objects from Case Object
    */ 
    global database.QueryLocator start(database.BatchableContext bcTemp){
        return database.getQueryLocator([SELECT Id,Name,Vendor_Code__c FROM Account WHERE recordtype.DeveloperName= 'Vendor' AND Vendor_code__c != Null]);
    }
    
    global void execute(database.batchableContext bcTemp, list<Account> lstVendors){  
     
        Set<String> vendorCodeSet = New Set<String>();      
        List<BT_CO_VBS_CreditDebit__c> lstVBSToUpsert = New List<BT_CO_VBS_CreditDebit__c>();
        Map<String,BT_CO_VBS_CreditDebit__c> mapVBSOldRecords = New Map<String,BT_CO_VBS_CreditDebit__c>();
        
        //START UD-1631 Wenjun 26/06/15 : Get GST from Custom Setting
        String gstSetting = ConstantsSLB.getOther('GST');
        if(gstSetting == null) throw new CustomException('No GST Congiduration');
        Decimal GST_PERCENT = Decimal.valueOf(gstSetting) / 100;
        //END UD-1631 Wenjun 26/06/15
        //Start HotFix 05-Aug-2015 Added by Raviteja - Updating logic for posting date 
        /*// Calculating Last day of the month
        Date monthStart = Date.today().toStartOfMonth();
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date monthEnd = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);
        */
        Date monthEnd = postingDate;
       //End HotFix 05-Aug-2015 Added by Raviteja - Updating logic for posting date 
        for(Account vendor : lstVendors)    
            vendorCodeSet.add(vendor.Vendor_code__c);
        
        for(BT_CO_VBS_CreditDebit__c oldVBS :[Select Id,Vendor_Number__c,Vendor_Group__c,Publication_Code__c,Posting_Date__c,
                                              Amt_Before_GST__c,GST_Amount__c,Credit_Debit__c,Reason_Code__c 
                                              From BT_CO_VBS_CreditDebit__c 
                                              //START HotFix 20-July-2015 Added by Raviteja - applying New Logic for ManualRun for Posting_Date__c 
                                              //Where Credit_Debit__c = : GlobalVariableClass.DEBIT_IND AND Posting_Date__c = THIS_MONTH
                                              Where Credit_Debit__c = : GlobalVariableClass.DEBIT_IND AND Posting_Date__c >= :startDate AND Posting_Date__c <= :endDate
                                              //End HotFix 20-July-2015 Added by Raviteja
                                              AND Vendor_Number__c in :vendorCodeset AND Reason_Code__c in ('24', 'D3') ])
        {
            String vbsKey = oldVBS.Vendor_Number__c + '' + oldVBS.Vendor_Group__c + ''
                            + oldVBS.Publication_Code__c + '' + oldVBS.Posting_Date__c + '' + oldVBS.Reason_Code__c;
            mapVBSOldRecords.put(vbsKey, oldVBS);
        }
        
        System.debug('===========> mapVBSOldRecords keySet : ' + mapVBSOldRecords.keySet() );
        
        /********************** Courier Charge **************************/
        for (AggregateResult vssSum : [Select Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c,SUM(Total_Amount__c) amountsum
                                       From BT_CO_VSS_CreditDebit__c 
                                       //START HotFix 20-July-2015 Added by Raviteja - applying New Logic for ManualRun for Posting_Date__c
                                       //Where Credit_Debit__c =: GlobalVariableClass.DEBIT_IND AND Posting_Date__c = THIS_MONTH 
                                       Where Credit_Debit__c =: GlobalVariableClass.DEBIT_IND AND Posting_Date__c >= :startDate AND Posting_Date__c <= :endDate 
                                       //End HotFix 20-July-2015 Added by Raviteja
                                       AND Vendor_Number__c in :vendorCodeset AND Manual_Amt__c = 0 And Subscription__c = NULL 
                                       Group By Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c])  
        {    
            String vssKey = vssSum.get('Vendor_Number__c') + '' + vssSum.get('Vendor_Group__c') 
                            + '' + vssSum.get('Publication_Code__c') + '' + vssSum.get('Posting_Date__c') + '24';
            BT_CO_VBS_CreditDebit__c vbsObj;   
            Decimal amtAfterGST = (Decimal)vssSum.get('amountSum');
                
            if(mapVBSOldRecords.containsKey(vssKey)) //Update existing Record
            {
                vbsObj= mapVBSOldRecords.get(vssKey);
                //START UD-1631 Wenjun 26/06/15 : Get GST from Custom Setting
                vbsObj.Amt_Before_GST__c = amtAfterGST.divide(1 + GST_PERCENT, 2, System.RoundingMode.HALF_UP); 
                //END UD-1631 Wenjun 26/06/15
                vbsObj.GST_Amount__c = amtAfterGST - vbsObj.Amt_Before_GST__c;         
            }
            else //Create New Record
            {              
                vbsObj = New BT_CO_VBS_CreditDebit__c();            
                //START UD-1631 Wenjun 26/06/15 : Get GST from Custom Setting
                vbsObj.Amt_Before_GST__c = amtAfterGST.divide(1 + GST_PERCENT, 2, System.RoundingMode.HALF_UP); 
                //END UD-1631 Wenjun 26/06/15   
                vbsObj.GST_Amount__c = amtAfterGST - vbsObj.Amt_Before_GST__c;                  
                vbsObj.Vendor_Group__c = (String)vssSum.get('Vendor_Group__c');
                vbsObj.Vendor_Number__c = (String)vssSum.get('Vendor_Number__c');                    
                vbsObj.Posting_Date__c = monthEnd;
                vbsObj.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
                vbsObj.Reason_Code__c = '24'; //Need to update GlobalVariableClass
                //START D-2349 23-Mar-2015 Added by Raviteja  - Populating Publication_Code__c
                vbsObj.Publication_Code__c = (String)vssSum.get('Publication_Code__c');
                //End D-2349 23-Mar-2015 Added by Raviteja
            }
            
            System.debug('==========>lstVBSToUpsert size : ' + lstVBSToUpsert.size());
            
            if(vbsObj!= null){
                vbsObj.Job_Id__c = 'SP003'; //START/END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
                lstVBSToUpsert.add(vbsObj);
            }
        }
        
        /********************** Paper Fee **************************/
        for (AggregateResult vssSum : [Select Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c,SUM(Total_Amount__c) amountsum
                                       From BT_CO_VSS_CreditDebit__c 
                                       //START HotFix 31-July-2015 Added by Raviteja - applying New Logic for ManualRun for Posting_Date__c 
                                       //Where Credit_Debit__c =: GlobalVariableClass.DEBIT_IND AND Posting_Date__c = THIS_MONTH                                        
                                        Where Credit_Debit__c = : GlobalVariableClass.DEBIT_IND AND Posting_Date__c >= :startDate AND Posting_Date__c <= :endDate
                                       //End HotFix 20-July-2015 Added by Raviteja
                                       AND Vendor_Number__c in :vendorCodeset AND Manual_Amt__c = 0 And Subscription__c != NULL 
                                       Group By Vendor_Number__c, Vendor_Group__c, Publication_Code__c, Posting_Date__c])  
        {    
            String vssKey = vssSum.get('Vendor_Number__c') + '' + vssSum.get('Vendor_Group__c') 
                            + '' + vssSum.get('Publication_Code__c') + '' + vssSum.get('Posting_Date__c') + 'D3';
            BT_CO_VBS_CreditDebit__c vbsObj;           
            if(mapVBSOldRecords.containsKey(vssKey)) //Update existing Record
            {
                vbsObj= mapVBSOldRecords.get(vssKey);
                vbsObj.Amt_Before_GST__c = (Decimal)vssSum.get('amountSum');
                vbsObj.GST_Amount__c = 0; //No GST for Paper Fee            
            }
            else //Create New Record
            {              
                vbsObj = New BT_CO_VBS_CreditDebit__c();                
                vbsObj.GST_Amount__c = 0; //No GST for Paper Fee
                vbsObj.Amt_Before_GST__c = (Decimal)vssSum.get('amountSum');
                vbsObj.Vendor_Group__c = (String)vssSum.get('Vendor_Group__c');
                vbsObj.Vendor_Number__c = (String)vssSum.get('Vendor_Number__c');                    
                vbsObj.Posting_Date__c = monthEnd;
                vbsObj.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
                vbsObj.Reason_Code__c = 'D3'; //Need to update GlobalVariableClass
                //START D-2349 23-Mar-2015 Added by Raviteja  - Populating Publication_Code__c
                vbsObj.Publication_Code__c = (String)vssSum.get('Publication_Code__c');
                //End D-2349 23-Mar-2015 Added by Raviteja
            }
            
            System.debug('==========>lstVBSToUpsert size : ' + lstVBSToUpsert.size());
            
            if(vbsObj!= null){
                vbsObj.Job_Id__c = 'SP003'; //START/END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
                lstVBSToUpsert.add(vbsObj);
            }
        }
        
        //Perform UPSERT
        if(!lstVBSToUpsert.isEmpty())
            UPSERT lstVBSToUpsert;    
 
    }
    
    global void finish(Database.BatchableContext BC) {  
        //START HotFix 20-July-2015 Added by Raviteja - applying New Logic for ManualRun - Commented existing batch run
        /*
        //START 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
        SP_PopulateVDCCreditNotes batchInstance = new SP_PopulateVDCCreditNotes('SP003',job_ID);
        Database.executeBatch(batchInstance);
        //END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
        */
        
        SP_PopulateVDCCreditNotes batchInstance;
        if(ismanualrun){
             batchInstance = new SP_PopulateVDCCreditNotes('SP003',job_ID, startDate,endDate);
             Database.executeBatch(batchInstance);
        }else {
            batchInstance = new SP_PopulateVDCCreditNotes('SP003',job_ID);
            Database.executeBatch(batchInstance);
        }        
       //End HotFix 20-July-2015 Added by Raviteja
      }
        
}