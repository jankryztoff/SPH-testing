/**
 * Class Name: SP_PopConsolidationBatchFinal
 * @author: Zhu, Wenjun
 * Date: 23 Feb 2015
 * Requirement/Project Name: CRSM Project
 * @description: This is the last process of POP which is to generate the Aggregated POP Data by Vendor  
 */
 
global class SP_PopConsolidationBatchFinal implements Database.Batchable<sObject>, Database.AllowsCallouts{    

    global final Id JOB_ID;
    
    global SP_PopConsolidationBatchFinal(Id jobID){
      JOB_ID = jobID;
    }
    
    global Iterable<sObject> start(Database.BatchableContext BC) { 
        List<Account> lstAccounts = [SELECT ID, Vendor_Code__c, Mailing_Agent_Code__c FROM Account 
                                       WHERE RecordType.DeveloperName IN ('Vendor','Mailing_Agent')]; 
                                      
        Account dummyAccount = new Account(Mailing_Agent_Code__c = 'MLAGN'); //Dummy Mailing Agent Code for Null Value
        lstAccounts.add(dummyAccount);
        
        return lstAccounts;
    }
    
    /*************************** Process Total Count *************************************/
    global void execute(Database.BatchableContext BC, List<Account> lstAccounts) {   
        List<Vendor_POP_Batch__c> lstTotalPOP = new List<Vendor_POP_Batch__c>();
        
        Set<String> setVendorNumbers = new Set<String>();
     //START UD-3043 07-Oct-2015 Added by Raviteja - Applying Try catch block in order to handle the Exception , failed records and Abort the job if exception occured 
    try{ 
        for(Account account : lstAccounts)
        {
            if(account.Vendor_code__c != null)
                setVendorNumbers.add(account.Vendor_code__c);
            if(account.Mailing_Agent_Code__c != null)
                setVendorNumbers.add(account.Mailing_Agent_Code__c);
        }
        
        for (AggregateResult ar :[SELECT Publication_Code__c, Vendor_Number__c, Vendor_Group__c, Publication_Issue_Date__c, 
                                  SUM(Total_Direct_Subscriptions__c), SUM(Total_Local_Freelist_Copies__c), SUM(Total_Local_Subscription_Copies__c),  
                                  SUM(Total_Overseas_Freelist_Copies__c), SUM(Total_Overseas_Subscription_Copies__c), SUM(Total_Sponsored_Copies__c)  
                                  FROM Vendor_POP_Batch__c 
                                  WHERE CreatedDate = TODAY AND Vendor_Number__c in :setVendorNumbers AND Subscription_Name__c != NULL 
                                  GROUP BY Publication_Code__c, Vendor_Number__c, Vendor_Group__c, Publication_Issue_Date__c])
        {   
            Vendor_POP_Batch__c popRec = new Vendor_POP_Batch__c();
            popRec.Vendor_Number__c = (String) ar.get('Vendor_Number__c');
            popRec.Publication_Code__c = (String) ar.get('Publication_Code__c');
            popRec.Vendor_Group__c = (String) ar.get('Vendor_Group__c')  ;
            popRec.Publication_Issue_Date__c = (Date) ar.get('Publication_Issue_Date__c');
            popRec.Subscription_Name__c = null;
            popRec.External_Id__c = popRec.Vendor_Number__c + popRec.Publication_Code__c;
            
            popRec.Total_Direct_Subscriptions__c = (Decimal) ar.get('expr0');
            popRec.Total_Local_Freelist_Copies__c = (Decimal) ar.get('expr1');
            popRec.Total_Local_Subscription_Copies__c = (Decimal) ar.get('expr2');
            popRec.Total_Overseas_Freelist_Copies__c = (Decimal) ar.get('expr3');
            popRec.Total_Overseas_Subscription_Copies__c = (Decimal) ar.get('expr4');
            popRec.Total_Sponsored_Copies__c = (Decimal) ar.get('expr5');
            
            lstTotalPOP.add(popRec);
        }
        
        if(!lstTotalPOP.isEmpty())        
            INSERT lstTotalPOP;
            
       } 
      catch (Exception e) {                
            BatchJobHelper.handleException(lstAccounts,e,SP_PopConsolidationBatchFinal.class.getName(),'SP012',JOB_ID,BC.getJobId(), True);
        }  
      //End UD-3043 07-Oct-2015 Added by Raviteja                
    }        
               
    global void finish(Database.BatchableContext BC) {   
        /*************************** Update Job Execution Status *************************************/
        //START UD-3043 07-Oct-2015 Added by Raviteja - Using BatchJobHelper.updateJobStatus to update the Status.        
        BatchJobHelper.updateJobStatus(JOB_ID);
        //End UD-3043 07-Oct-2015 Added by Raviteja 
    }
}