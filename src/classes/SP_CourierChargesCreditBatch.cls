/**
 * Class Name: SP_CourierChargesCreditBatch 
 * @author: Jb Domingo
 * Date: 9/11/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that creates Vendor Monthly Data - Credit 
 *
 * History: 01/08/2015 Wenjun : Order Postage Charge Field Change
 */
global class SP_CourierChargesCreditBatch implements Database.Batchable<sObject>
{
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bcTemp - predefined parameter 
    * @return list of objects from Order Object
    */ 
    global database.QueryLocator start(database.BatchableContext bcTemp){
        //START 01/08/15 Wenjun - Postage Charges : Change to Total_Monthly_Postage_Charge__c instead of Postage_Charge__c
        return database.getQueryLocator([SELECT Total_Monthly_Postage_Charge__c, Subscription__r.Vendor_1__c,
                                                Subscription__r.Vendor_1__r.Vendor_Group__c,
                                                Subscription__r.Vendor_1__r.AccountNumber
                                                FROM Order__c      
                                                WHERE Effective_Date__c = THIS_MONTH]);
        //END 01/08/15 Wenjun - Postage Charges
    }
    
    /* @description Executes the business logic and creates Vendor Monthly Data object
     * 
     * @param bcTemp - predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(database.batchableContext bcTemp, list<Order__c> allScopes){   
        List<Vendor_Monthly_Data__c> vendorMonthlyDataList = new List<Vendor_Monthly_Data__c>();
        for(Order__c orderObj:allScopes){            
            Vendor_Monthly_Data__c vendorMonthlyDataCredit = new Vendor_Monthly_Data__c();
            //START 01/08/15 Wenjun - Postage Charges : Change to Total_Monthly_Postage_Charge__c instead of Postage_Charge__c
            vendorMonthlyDataCredit.Amount_Before_GST__c = orderObj.Total_Monthly_Postage_Charge__c;
            vendorMonthlyDataCredit.Credit_Debit__c = 'Credit';  
            vendorMonthlyDataCredit.GST_Amount__c = orderObj.Total_Monthly_Postage_Charge__c * GlobalVariableClass.GST_AMOUNT;
            //END 01/08/15 Wenjun - Postage Charges
            vendorMonthlyDataCredit.Vendor__c= orderObj.Subscription__r.Vendor_1__c;
            vendorMonthlyDataCredit.Vendor_Group__c = orderObj.Subscription__r.Vendor_1__r.Vendor_Group__c;
            vendorMonthlyDataCredit.Vendor_Number__c = orderObj.Subscription__r.Vendor_1__r.AccountNumber;
            vendorMonthlyDataList.add(vendorMonthlyDataCredit);
        }
        
        try{
            insert vendorMonthlyDataList;
        }
        catch(Exception e){
            //error handling
        }             
    }

    global void finish(database.batchableContext BC){
        String shortID = String.valueOf(BC.getJobId()).subString(0,15);
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];

        if(batchJobSchedulerList.size() > 0)
        {
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = 'SUCCESS';
            batchJobScheduler.End_Time__c = DateTime.now();
            update batchJobScheduler;           
            
            //System.debug('*********************** inside final'+ this.query);
            BatchServiceFacade a1F = new BatchServiceFacade();
            BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
            serviceRequestVO.setJobStatus(0);
            serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
            serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
            System.debug('################ before');
            a1F.delegateBatchCall(serviceRequestVO);
            System.debug('################ after');             
        }   
        
    }         
}