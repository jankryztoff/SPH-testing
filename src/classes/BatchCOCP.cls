/**
 * Class Name:  BatchCOCP
 * @author: Zhu, Wenjun
 * Date: 18 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: This job will fetch all the eligibles publication subsriptions and mark them for mass cover price update
 * History: 19/04/2016 [D-4382] Wenjun : Restructure the class
 */
 
global class BatchCOCP implements Database.Batchable<sObject>, Database.Stateful {    

    global final String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global final String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    global final String SUB_TYPE_PUB = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    global final String STATUS_ACTIVE = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
    
    global List<String> listProductCodes = new List<String>();
    global List<String> listSubNames = new List<String>();
    global Integer totalRecordCount;
    global Integer succesRecordCount;
    global Boolean isMthlyRun = false;
    global Boolean isForContract = false;
    global Date jobRunDate;
    global MASS_CONFIG__c prodCodeConfig = MASS_CONFIG__c.getValues('MCOP_PRD_CODES');
    

    //Contructor for Full Run
    global BatchCOCP(Boolean forContract, Boolean runMonthly, Date executionDay){
        if(prodCodeConfig == null)
            throw new CustomException('No Product Codes configured in Custom Setting');
        String strProductCodes = prodCodeConfig.Value__c + ',' + prodCodeConfig.Value2__c;
        listProductCodes = strProductCodes.split(',');
        isMthlyRun = runMonthly;
        isForContract = forContract;
        jobRunDate = executionDay;
    }
    
    //Contructor for Targeted Run
    global BatchCOCP(Boolean forContract, String strSubNames, Boolean runMonthly, Date executionDay){
        if(prodCodeConfig == null)
            throw new CustomException('No Product Codes configured in Custom Setting');
        String strProductCodes = prodCodeConfig.Value__c + ',' + prodCodeConfig.Value2__c;
        listProductCodes = strProductCodes.split(',');
        isMthlyRun = runMonthly;
        listSubNames = strSubNames.split(',');
        isForContract = forContract;
        jobRunDate = executionDay;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        //Initialising counts
        totalRecordCount = 0;
        succesRecordCount = 0;
        Date monthEndDate;
        
        //Determine Date Range depends on Running Mode
        if(isMthlyRun) //Month End Run
            monthEndDate = UsageHelper.getUsageReferenceDate(); 
        
        //Fetch all the eligible subscription records
        String query = ' Select ID, Name, Product_Code__c,Zuora__SubscriptionEndDate__c, Contract_End_Date_1__c FROM Zuora__Subscription__c ';
        query +=' Where Subscription_Type_1__c = :SUB_TYPE_PUB AND Product_Code__c in :listProductCodes AND Zuora__Status__c = :STATUS_ACTIVE '; 
        if(!listSubNames.isEmpty())
            query +=' AND Name in :listSubNames ';
        if(isForContract)
        {
            if(isMthlyRun)
                query +=' AND Contract_End_Date_1__c != NULL AND Contract_End_Date_1__c >= :jobRunDate AND Contract_End_Date_1__c <= :monthEndDate ';   
            else    
                query +=' AND Contract_End_Date_1__c != NULL AND Contract_End_Date_1__c = :jobRunDate ';                    
        }
        //START Wenjun D-4806 19 May 16 - Ignore on contract
        else
             query +=' AND Contract_End_Date_1__c = NULL '; 
        //END Wenjun D-4806 19 May 16 
        query +=' AND (Billing_Type__c = :MR_PRE OR Billing_Type__c = :MR_POST)';
        query +=' AND (Zuora__SubscriptionEndDate__c = NULL OR Zuora__SubscriptionEndDate__c > THIS_MONTH)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) {
        Set<ID> setSubIDs = new Set<ID> ();
        Map<ID, Zuora__Subscription__c> mapIDToSub = new Map<ID, Zuora__Subscription__c>();
        List<Zuora__Subscription__c> lstSubsToUpd = new List<Zuora__Subscription__c>();
        Set<String> setProductCodes = new Set<String>();
        Map<String, Decimal> mapChargeToPrice = new Map<String, Decimal>();
        
        for(Zuora__Subscription__c subRec : scope)
        {
            //Filter out those Contract End Date = Sub End Date
            if(subRec.Zuora__SubscriptionEndDate__c == NULL || subRec.Contract_End_Date_1__c == NULL 
            || subRec.Contract_End_Date_1__c != subRec.Zuora__SubscriptionEndDate__c)
            {
                mapIDToSub.put(subRec.ID, subRec);
                setProductCodes.add(subRec.Product_Code__c);
            }
        }
        
        //Fetch New Rate Plan Charges
        for(zqu__ProductRatePlanCharge__c prpc : [SELECT Id, Name, zqu__ProductRatePlan__r.Name, sum__c FROM zqu__ProductRatePlanCharge__c 
                 WHERE zqu__Deleted__c = false AND zqu__ProductRatePlan__r.zqu__Deleted__c = false AND PublicationCode__c != null AND sum__c > 0 
                 AND zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Deleted__c = false AND zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCode__c in : setProductCodes])
        {
            mapChargeToPrice.put(prpc.zqu__ProductRatePlan__r.Name + prpc.Name, prpc.sum__c);
        }
            
        //Fetch SPCs and compare prices to determine list of subs to be updated
        for(Zuora__SubscriptionProductCharge__c spc : [SELECT Name, Zuora__RatePlanName__c, Zuora__Price__c, Zuora__Subscription__c FROM Zuora__SubscriptionProductCharge__c 
                                WHERE Zuora__Subscription__c in :mapIDToSub.keySet() AND Zuora__Model__c = : GlobalVariableClass.SPC_MODEL_UNIT 
                                AND PublicationCode__c != null AND Zuora__Price__c > 0] )
        {
            if(spc.Zuora__Price__c != mapChargeToPrice.get(spc.Zuora__RatePlanName__c + spc.Name))
                setSubIDs.add(spc.Zuora__Subscription__c);
        }
        
        for(ID subID : setSubIDs)
        {
            Zuora__Subscription__c subRec = mapIDToSub.get(subID);
            subRec.For_Mass_Update__c = true;
            lstSubsToUpd .add(subRec);
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
               
    global void finish(Database.BatchableContext BC) 
    {
        Logger logger = new Logger(BatchCOCP.class.getName());
        logger.log(false, 'Total eligible records for Mass Update: ' + totalRecordCount +'. Total clean records for Mass Update: ' + succesRecordCount);
        logger.save();
        
        //Start the main processing job
        //START Wenjun D-4806 20 April 16 - Add Job Run Date parameter
        BatchCOCPMain batch = new BatchCOCPMain(jobRunDate);
        //END Wenjun D-4806 20 April 16
        Database.executeBatch(batch, 10);     
    }
}