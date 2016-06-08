/**
* Class Name: TempStopResetCounter 
* @author: C. Lin
* Date: 12Jan2016
* Requirement/Project Name: Singapore Press Holdings
* @description Batch class that updates Year To Date Temp Stop Days, Previous Year Temp Stop Days, Next Year Temp Stop Days in Subscription for Temp Stop. Defect UD-3632.
*/

global class SP_TempStopResetCounter implements  Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    Date referenceDate;
    Set<Id> subIdSet = new Set<Id>();
    Set<String> baIdSet = new Set<String>();
    Boolean isApexJobSuccessful = true;
	
    global SP_TempStopResetCounter()
    {
        referenceDate = Date.today();
    }
    
    global SP_TempStopResetCounter(Date inputDate)
    {
        referenceDate = inputDate;
    }
    
    global SP_TempStopResetCounter(Set<Id> objIdSet)
    {
        subIdSet = objIdSet;
    }
    
    global SP_TempStopResetCounter(Set<String> objIdSet)
    {
        baIdSet = objIdSet;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        
        if(referenceDate != null){
            query = 'SELECT Id, Name, Subscription__c, Temp_Stop__c, Temp_Stop__r.Case__c FROM Subscription_Temp_Stop__c WHERE Subscription__r.Zuora__Status__c = \'Active\' AND ((Subscription__r.Zuora__TermSettingType__c = \'TERMED\' AND Subscription__r.Zuora__SubscriptionEndDate__c >= :referenceDate) OR Subscription__r.Zuora__TermSettingType__c = \'EVERGREEN\')';
        }else if(!subIdSet.isEmpty()){
            query = 'SELECT Id, Name, Subscription__c, Temp_Stop__c, Temp_Stop__r.Case__c FROM Subscription_Temp_Stop__c WHERE Subscription__r.Zuora__Status__c = \'Active\' AND (Subscription__r.Zuora__TermSettingType__c = \'TERMED\' OR Subscription__r.Zuora__TermSettingType__c = \'EVERGREEN\') AND Subscription__c IN :subIdSet';
        }else if(!baIdSet.isEmpty()){
            query = 'SELECT Id, Name, Subscription__c, Temp_Stop__c, Temp_Stop__r.Case__c FROM Subscription_Temp_Stop__c WHERE Subscription__r.Zuora__Status__c = \'Active\' AND (Subscription__r.Zuora__TermSettingType__c = \'TERMED\' OR Subscription__r.Zuora__TermSettingType__c = \'EVERGREEN\') AND Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c IN :baIdSet';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Subscription_Temp_Stop__c> scope) {
        Set<Id> subscriptionIdSet = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<Case> caseList = new List<Case>();
        List<Case> cList = new List<Case>();
        
        Logger logger = new Logger(SP_TempStopResetCounter.class.getName(), 'SP059', BC.getJobID());
        
        try{
            for(Subscription_Temp_Stop__c sts : scope){
                if(sts.Subscription__c != null){
                    subscriptionIdSet.add(sts.Subscription__c);
                }
                
                if(sts.Temp_Stop__r.Case__c != null){
                    caseIdSet.add(sts.Temp_Stop__r.Case__c);
                }
            }
            
            if(!subscriptionIdSet.isEmpty()){
                subscriptionList = [SELECT Id, Name, Year_to_Date_Temp_Stop_Days__c, Previous_Year_Temp_Stop_Days__c, Next_Year_Temp_Stop_Days__c FROM Zuora__Subscription__c WHERE Id IN :subscriptionIdSet];
            }
            
            if(!caseIdSet.isEmpty()){
                caseList = [SELECT Id, Current_Date_for_Year_To_Date__c, Next_Year_for_Year_To_Date__c FROM Case WHERE Id IN :caseIdSet];
            }
            
            if(!subscriptionList.isEmpty()){
                for(Zuora__Subscription__c sub : subscriptionList){
                    if(sub.Year_to_Date_Temp_Stop_Days__c != null){
                        sub.Previous_Year_Temp_Stop_Days__c = sub.Year_to_Date_Temp_Stop_Days__c;
                    }else{
                        sub.Previous_Year_Temp_Stop_Days__c = 0;
                    }
                    
                    if(sub.Next_Year_Temp_Stop_Days__c != null){
                        sub.Year_to_Date_Temp_Stop_Days__c = sub.Next_Year_Temp_Stop_Days__c;
                    }else{
                        sub.Year_to_Date_Temp_Stop_Days__c = 0;
                    }
                    
                    sub.Next_Year_Temp_Stop_Days__c = 0;
                    
                    subList.add(sub);
                }
            }
            
            if(!caseList.isEmpty()){
                for(Case c : caseList){
                    if(c.Next_Year_for_Year_To_Date__c != null){
                        c.Current_Date_for_Year_To_Date__c = c.Next_Year_for_Year_To_Date__c;
                    }else{
                        c.Current_Date_for_Year_To_Date__c = 0;
                    }
                    
                    c.Next_Year_for_Year_To_Date__c = 0;
                    
                    cList.add(c);
                }
            }
            
            if(!subList.isEmpty()){
                update subList;
            }
            
            if(!cList.isEmpty()){
                update cList;
            }
        }catch(Exception e){
            logger.log(false, string.valueOf(e));
			
			isApexJobSuccessful = false;
        }
        
        logger.save();
    }
    
    global void finish(Database.BatchableContext BC){
        Logger logger = new Logger(SP_TempStopResetCounter.class.getName(), 'SP059', BC.getJobID());
        
        try{
            if(!isApexJobSuccessful){
                BatchJobHelper.updateJobStatus(BC.getJobId(), false);
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
            }
        }catch(Exception e){
            logger.log(false, string.valueOf(e));
        }
		
		logger.save();
    }
}