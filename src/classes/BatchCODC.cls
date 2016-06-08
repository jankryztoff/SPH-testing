/**
 * Class Name:  BatchCODC
 * @author: Zhu, Wenjun
 * Date: 21 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: This job will fetch all the eligibles delivery subsriptions and mark them for mass delivery charge update
 *
 * History: 19/04/2016 [D-4382] Wenjun : Restructure the class
 */
 
global class BatchCODC implements Database.Batchable<sObject>, Database.Stateful {    

    global final Decimal HDB_PRICE = Decimal.valueOf(MASS_CONFIG__c.getValues('HDB_PRICE').Value__c);
    global final Decimal APT_PRICE = Decimal.valueOf(MASS_CONFIG__c.getValues('APT_PRICE').Value__c);
    global final Decimal LANDED_PRICE = Decimal.valueOf(MASS_CONFIG__c.getValues('LANDED_PRICE').Value__c);
    global final String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global final String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    global final String SUB_TYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    global final String STATUS_ACTIVE = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
    global Integer totalRecordCount;
    global Integer succesRecordCount;
    global Boolean isMthlyRun = false;
    global Boolean isForContract = false;
    global Date jobRunDate;
    global Date monthEndDate;
    
    global List<String> listSubNames = new List<String>();
  
    //Contructor for Full Run
    global BatchCODC(Boolean forContract, Boolean runMonthly, Date executionDate){
        isMthlyRun = runMonthly;
        isForContract = forContract;
        jobRunDate = executionDate;
    }
    
    //Contructor for Targeted Run
    global BatchCODC(Boolean forContract, String strSubNames, Boolean runMonthly, Date executionDate){
        isMthlyRun = runMonthly;
        listSubNames = strSubNames.split(',');
        isForContract = forContract;
        jobRunDate = executionDate;
    }
    
    global String getQueryString(){
        List<String> lstConditions = new List<String>();
        
        //Determine Date Range depends on Running Mode
        if(isMthlyRun) //Month End Run
            monthEndDate = UsageHelper.getUsageReferenceDate(); 
        
        if(HDB_PRICE > 0)
            lstConditions.add('(Delivery_Charge_Type_1__c = \'H\' AND Subscription_Charge__c != :HDB_PRICE)');
        if(APT_PRICE > 0)
            lstConditions.add('(Delivery_Charge_Type_1__c = \'C\' AND Subscription_Charge__c != :APT_PRICE)');
        if(LANDED_PRICE > 0)
            lstConditions.add('(Delivery_Charge_Type_1__c = \'L\' AND Subscription_Charge__c != :LANDED_PRICE)');
        
        if(!lstConditions.isEmpty())
        {
            String query = 'SELECT Id, Name, Contract_End_Date_1__c, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c ';
            query += 'WHERE Subscription_Type_1__c = : SUB_TYPE_DEL AND Zuora__Status__c = :STATUS_ACTIVE ';
            query += 'AND (Billing_Type__c = :MR_PRE OR Billing_Type__c = :MR_POST) ';
            query +=' AND (Zuora__SubscriptionEndDate__c = NULL OR Zuora__SubscriptionEndDate__c > THIS_MONTH)';
            if(!listSubNames.isEmpty()) //Targted Sub Names
                query +=' AND Name in :listSubNames ';
            if(isForContract) //Only cater for Sub on Contract
            {
                if(isMthlyRun)
                    query +=' AND Contract_End_Date_1__c != NULL AND Contract_End_Date_1__c >= :jobRunDate AND Contract_End_Date_1__c <= :monthEndDate ';   
                else    
                    query +=' AND Contract_End_Date_1__c != NULL AND Contract_End_Date_1__c = :jobRunDate ';                    
            }
            query += 'AND (';
            if(lstConditions.size() == 1)
                query += lstConditions[0];
            else if(lstConditions.size() == 2)
                query += lstConditions[0] + ' OR ' + lstConditions[1];
            else if(lstConditions.size() == 3)
                query += lstConditions[0] + ' OR ' + lstConditions[1] +' OR ' + lstConditions[2];
            query += ')'; 
            return query;
        }
        else
            return null;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        totalRecordCount = 0;
        succesRecordCount = 0;
        return Database.getQueryLocator(getQueryString());
    }

    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstSubsInScope)
    {
        List<Zuora__Subscription__c> lstSubsToUpd = new List<Zuora__Subscription__c>();
        
        for(Zuora__Subscription__c subRec : lstSubsInScope)
        {
            //Filter out those Contract End Date = Sub End Date
            if(subRec.Zuora__SubscriptionEndDate__c == NULL || subRec.Contract_End_Date_1__c == NULL 
            || subRec.Contract_End_Date_1__c != subRec.Zuora__SubscriptionEndDate__c)
            {
                subRec.For_Mass_Update__c = true;
                lstSubsToUpd .add(subRec);
            }
        }
        
        //UPDATE Existing Subscriptions
        if(!lstSubsToUpd.isEmpty())
        {
            SubscriptionTriggerHandler.preventExecution = true;
            Database.SaveResult[] srList = Database.update(lstSubsToUpd, false);
            
            Integer tmp = 0;
            for(Database.SaveResult sr : srList)
            {
                if(sr.isSuccess()) tmp += 1;
            }
            
            totalRecordCount += lstSubsToUpd.size();
            succesRecordCount += tmp;
        }
    }
    
    global void finish(Database.BatchableContext BC) {  
        Logger logger = new Logger(BatchCODC.class.getName());
        logger.log(false, 'Total eligible records for Mass Update: ' + totalRecordCount +'. Total clean records for Mass Update: ' + succesRecordCount);
        logger.save();
        
        //Start the main processing job
        BatchCODCMain batch = new BatchCODCMain(HDB_PRICE, APT_PRICE, LANDED_PRICE);
        Database.executeBatch(batch, 8);  
    }
}