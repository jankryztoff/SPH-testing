/*
 * Class Name: SP_RenewalReminderRequestBatch
 * @author: Kevin H. Evasco
 * Date: 11/19/2015
 * Project/Requirement: Letter Printing - Renewal Reminder Letter
 * @description This class consolidate Detail Letter Print Requests by creating Master Letter Print Requests
 * 
 * History: 11/19/2015 Kevin Evasco Created Apex Batch
 */

global class SP_RenewalReminderConsolidator implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    public static String LPR_TYPE_DETAIL = 'Detail';
    public static String LPR_TYPE_MASTER = 'Master';
    public static String LPR_STATUS_TAGGED = 'Tagged';
    
    Id jobId;
    
    String batchCode;
    String letterType;
    String sessionId;
    
    Boolean isApexJobSuccessful = true;
    
    global SP_RenewalReminderConsolidator(Id jobIdParam, String batchCodeParam, String letterTypeParam, String sessionIdParam, Boolean isApexJobSuccessfulParam){
        this.jobId = jobIdParam;
        this.batchCode = batchCodeParam;
        this.letterType = letterTypeParam;
        this.sessionId = sessionIdParam;
        this.isApexJobSuccessful = isApexJobSuccessfulParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {    
        return Database.getQueryLocator([SELECT Id, Status__c, Status_Email__c, Record_ID__c, Letter_Type__c, Language_Medium__c, Billing_Account__c, Parent_Letter_Print_Request__c FROM Letter_Print_Request__c WHERE (Status__c = :SP_GenerateLetterPrintBatch.newValue OR Status_Email__c = :SP_GenerateLetterPrintBatch.newValue) AND Letter_Type__c = :letterType AND Type__c = :LPR_TYPE_DETAIL]);
    }
    
    global void execute(Database.BatchableContext BC, List<Letter_Print_Request__c> scope) {             


        Logger logger;
        if(!Test.isRunningTest()) {  
            logger = new Logger (SP_RenewalReminderConsolidator.class.getName(), batchCode, BC.getJobID()); //START/END 20 November 2015 UD-2535 Kevin Evasco - Corrected class name
        }   
        
        try {
            // START : D-4335 1/21/2016 Alyana Navarro
            Schema.SObjectType objectType;
            Letter_Print_Request__c clonedLPR = new Letter_Print_Request__c();
            List<Id> toCloneLPRIdList = new List<Id>();
            Map<Id, SObject> clonedLPRMap = new Map<Id, SObject>();
            // END : D-4335 1/21/2016 Alyana Navarro
            Map<String, Letter_Print_Request__c> existingMasterLPRMap = new Map<String, Letter_Print_Request__c>();
            Map<String, Letter_Print_Request__c> newMasterLPRMap = new Map<String, Letter_Print_Request__c>();
            Set<Id> billingAccountIdSet = new Set<Id>();
            Set<String> languageMediumSet = new Set<String>();
            
            for(Letter_Print_Request__c letterPrintRequestElem : scope) {
                billingAccountIdSet.add(letterPrintRequestElem.Billing_Account__c);
                languageMediumSet.add(letterPrintRequestElem.Language_Medium__c);
            }
            
            existingMasterLPRMap = getExistingMasterLPRMap(billingAccountIdSet,languageMediumSet,letterType);

            for(Letter_Print_Request__c letterPrintRequestElem : scope) {
                
                String masterLPRKey = constructMasterLPRKey(letterPrintRequestElem.Billing_Account__c, letterPrintRequestElem.Language_Medium__c, letterType);
                if(existingMasterLPRMap.containsKey(masterLPRKey)){
                    letterPrintRequestElem.Parent_Letter_Print_Request__c = existingMasterLPRMap.get(masterLPRKey).Id;
                    if(letterPrintRequestElem.Status__c == SP_GenerateLetterPrintBatch.newValue)
                        letterPrintRequestElem.Status__c = LPR_STATUS_TAGGED;
                    if(letterPrintRequestElem.Status_Email__c == SP_GenerateLetterPrintBatch.newValue)
                        letterPrintRequestElem.Status_Email__c = LPR_STATUS_TAGGED;
                } else {
                    // START : D-4335 1/21/2016 Alyana Navarro - Remove commented out code.
                    /*Letter_Print_Request__c masterLPR = (Letter_Print_Request__c)SObjectAllFieldCloner.cloneObject(letterPrintRequestElem,letterPrintRequestElem.getsObjectType());
                    masterLPR.Type__c = LPR_TYPE_MASTER;
                    masterLPR.Record_ID__c = null;                                      
                    newMasterLPRMap.put(masterLPRKey, masterLPR);*/
                    objectType = letterPrintRequestElem.getsObjectType();
                    toCloneLPRIdList.add(letterPrintRequestElem.id);
                    // END : D-4335 1/21/2016 Alyana Navarro
                }           
            }
            // START : D-4335 1/21/2016 Alyana Navarro
            //START UD-3710 Gdelrosario
            clonedLPRMap = SObjectAllFieldCloner.cloneObjects(toCloneLPRIdList, objectType);
            map<id, string> lang = new map<id, string>();

            for(Id oldObjectId : clonedLPRMap.keySet()){
                clonedLPR = (Letter_Print_Request__c) clonedLPRMap.get(oldObjectId);
            

                if (lang.containsKey(clonedLPR.Billing_Account__c)) {
                    System.debug('Pasok sa una IF ----------------------' +clonedLPR.Billing_Account__c+ ' - ' +lang.get(clonedLPR.Billing_Account__c)+ ' - ' + clonedLPR.Language_Medium__c);
                    if (lang.get(clonedLPR.Billing_Account__c) != clonedLPR.Language_Medium__c) {
                        lang.put(clonedLPR.Billing_Account__c, 'E');
                    }
                   
                } else {
                   
                    lang.put(clonedLPR.Billing_Account__c, clonedLPR.Language_Medium__c);
                
                }
            }
            // END : D-4335 1/21/2016 Alyana Navarro
           
            for(Id oldObjectId : clonedLPRMap.keySet()){
                clonedLPR = (Letter_Print_Request__c) clonedLPRMap.get(oldObjectId);
                clonedLPR.Type__c = LPR_TYPE_MASTER;
                clonedLPR.Record_ID__c = null;
                clonedLPR.Language_Medium__c = lang.get(clonedLPR.Billing_Account__c);

                newMasterLPRMap.put(constructMasterLPRKey(clonedLPR.Billing_Account__c, lang.get(clonedLPR.Billing_Account__c), letterType), clonedLPR);
            }

            System.debug('gio >> : ' + newMasterLPRMap);
            Database.insert(newMasterLPRMap.values());
            //END UD-3710 Gdelrosario
            for(Letter_Print_Request__c letterPrintRequestElem : newMasterLPRMap.values()) {
                letterPrintRequestElem.Record_ID__c = letterPrintRequestElem.Id;
            }
            
            Database.update(newMasterLPRMap.values());
            
            for(Letter_Print_Request__c letterPrintRequestElem : scope) {       
                if(letterPrintRequestElem.Parent_Letter_Print_Request__c == null) { 

                    //START UD-3710 GDelrosario
                    String masterLPRKey = constructMasterLPRKey(letterPrintRequestElem.Billing_Account__c, lang.get(letterPrintRequestElem.Billing_Account__c), letterType);
                    //END UD-3710 GDelrosario
                    String lprStatus;
                    if(newMasterLPRMap.containsKey(masterLPRKey)){
                        letterPrintRequestElem.Parent_Letter_Print_Request__c = newMasterLPRMap.get(masterLPRKey).Id;
                        lprStatus = LPR_STATUS_TAGGED;
                    } else {
                        lprStatus = SP_GenerateLetterPrintBatch.failedValue;
                        isApexJobSuccessful = false;    //START/End D-4482 14-Mar-2016 Added by Raviteja - Sending failed signal to Ctrl+M if any letter print request failed. 
                    }                   
                    if(letterPrintRequestElem.Status__c == SP_GenerateLetterPrintBatch.newValue)
                        letterPrintRequestElem.Status__c = lprStatus;
                    if(letterPrintRequestElem.Status_Email__c == SP_GenerateLetterPrintBatch.newValue)
                        letterPrintRequestElem.Status_Email__c = lprStatus;
                }
            }
            
            update scope;
        } catch(Exception e) {
            if(!Test.isRunningTest()) {
                logger.logBatchFailure(e, scope);
                logger.save();
            }      
            isApexJobSuccessful = false;
        }
    }   

    global void finish(Database.BatchableContext BC) {
        String nextBatchCode;
        //START: D-4262 1-12-2016 Added by Kristine Balaoing - added logging mechanism
        List<Exception> exceptionList = new List<Exception>();
        try{
            if(letterType == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine)
            {
                nextBatchCode = 'SP030';
            }
            else if(letterType == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine)
            {
                nextBatchCode = 'SP031';
            }
            else if(letterType == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper)
            {
                nextBatchCode = 'SP032';
            }
            else if(letterType == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper)
            {
                nextBatchCode = 'SP033';
            }

            //Start D-4742 Raviteja 26Apr2016 - Should not send the signal to control M
            if(!isApexJobSuccessful){
                //BatchJobHelper.updateJobStatus(jobId, false); 
                 BatchJobHelper.updateBatchJobScheduler(jobId, false); 
            }else{
                //BatchJobHelper.updateJobStatus(jobId, true);
                BatchJobHelper.updateBatchJobScheduler(jobId, true);
            }
            
            SP_BatchJobSchedulerService.setParentBatchJobSchedulerId(jobId);  
            //End D-4742 Raviteja 26Apr2016 - Capturing batch job schdduler record id
            SP_BatchJobSchedulerService.processRequest(nextBatchCode,'Start', null, sessionId);   
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
    
    }
    
    public static String constructMasterLPRKey(String billingAccountIdParam, String languageParam, String letterTypeParam) {
        return billingAccountIdParam + '_' + languageParam + '_' + letterTypeParam;
    }
    
    public static Map<String,Letter_Print_Request__c> getExistingMasterLPRMap(Set<Id> billingAccountIdSetParam, Set<String> languageMediumSetParam, String letterTypeParam) {
        Map<String,Letter_Print_Request__c> existerMasterLPRMap = new Map<String,Letter_Print_Request__c>();
        List<Letter_Print_Request__c> masterLPRList = [SELECT Id, Billing_Account__c, Language_Medium__c, Letter_Type__c FROM Letter_Print_Request__c WHERE Billing_Account__c IN :billingAccountIdSetParam AND Language_Medium__c IN :languageMediumSetParam AND Letter_Type__c = :letterTypeParam AND Type__c = :LPR_TYPE_MASTER AND Status__c = :SP_GenerateLetterPrintBatch.newValue];
        
        for(Letter_Print_Request__c masterLPRElem : masterLPRList) {
            String masterLPRKey = constructMasterLPRKey(masterLPRElem.Billing_Account__c, masterLPRElem.Language_Medium__c, masterLPRElem.Letter_Type__c);
            existerMasterLPRMap.put(masterLPRKey, masterLPRElem);
        }
        
        return existerMasterLPRMap;
    }
}