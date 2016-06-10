/*
 * Class Name: SP_RenewalReminderRequestBatch
 * @author: Kevin H. Evasco
 * Date: 11/09/2014
 * Project/Requirement: Letter Printing - Renewal Reminder Letter
 * @description This class generates Renewal Reminder Letter Print Requests
 * 
 * History: 11/09/2014 Kevin Evasco Created Apex Batch
 * History: 12/03/2014 D-1030 Kevin Evasco Added query filter Supressed_Renewal_and_Reminder_Letter_1__c = FALSE
 * History: 12/05/2014 D-0797, D-0849 Kevin Evasco Added new constructor to enable storage of Session ID.
 * History: 26-Feb-2015 D-1932 Raviteja, resolved the "Cannot Insert Update Activate Entity" error. Implemented the logic of Renewal notification for Magazine and NewsPaper
 * History: 10/12/2015 Added by Kristine Balaoing - added additional param to handle batch Recovery 
 * History: 11/24/2015 Kevin Evasco - Reconstructed class for Renewal Reminder To Escalate Defects: UD-2535, UD-2803, UD-2610 and D-2535, UD-2423 
 */

global class SP_RenewalReminderRequestBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    String letterType, publicationType;
    Date expirationDate;
    Integer batchCount;  
    
    String sessionId;    
    
    List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>();    
    
    //START END PD-0146 Gdelrosario : added variable 
    Date adhocBatchRunDate = null;
    //END END PD-0146 Gdelrosario : added variable 
    Date EndDate;
    
    String BatchCode = ''; 
    List<Zuora__Subscription__c> lstSubToBeUpdated = new List<Zuora__Subscription__c>();
    
    String a;
    Date refDate = null;
    List<Id> batchIds = new List<Id>();
    String batchMode;
    String batchCodeFinal;
    Boolean isAdhoc = false;
    
    Boolean isApexJobSuccessful = true;     
    
    String evergreen = GlobalVariableClass.EVERGREEN;
    String hardcopy = GlobalVariableClass.REFERENCE_HARD_COPY;
    String both = GlobalVariableClass.REFERENCE_BOTH;
    String email = GlobalVariableClass.REFERENCE_EMAIL;
    String active = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
    String futureActive = 'Future Active'; //START END PD-0204 17May2016 Added By C. Lin - Use Status Formula in getting Subscriptions
    String publication = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;      
    
    //Normal Run via Control M/ this can also be adhoc if you input a different date in batchRunDate
    global SP_RenewalReminderRequestBatch(String letterType, Integer daysBeforeExpiration, Date batchRunDate, Integer batchCount, String sessionId, String batchCodeParam)
    {
        this.letterType = letterType;   
        
        if(daysBeforeExpiration == Null){       
            this.expirationDate = batchRunDate.addDays(0);
        }else{
            this.expirationDate = batchRunDate.addDays(daysBeforeExpiration);
        }
        
        if(letterType == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine || letterType == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine)
        {
            this.publicationType = 'M';
        }
        else if(letterType == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || letterType == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper)
        {
            this.publicationType = 'N';
        }

        this.batchCount = batchCount;
        this.sessionId = sessionId;
        
        if(batchRunDate!=null){
            refDate = batchRunDate; 
        }else{
            refDate = System.today();
        }
        
        if(batchRunDate != System.today()){
            isAdhoc = true;
            
        }

        //START END PD-0146 Gdelrosario : added variable 
        adhocBatchRunDate = batchRunDate;
        //END PD-0146 Gdelrosario : added variable 
        batchMode = 'N';
        batchCodeFinal = batchCodeParam;
    }
    
    //Recovery via Subscription ID bypasses the criteria
    global SP_RenewalReminderRequestBatch(String letterType, Integer daysBeforeExpiration, Set<Id> subsIds, Date batchRunDate, Integer batchCount, String sessionId, String batchCodeParam)
    {

        this.letterType = letterType;   

        if(daysBeforeExpiration == Null){       
            this.expirationDate = batchRunDate.addDays(0);
        }else{
            this.expirationDate = batchRunDate.addDays(daysBeforeExpiration);
        }
        
        if(letterType == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine || letterType == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine)
        {
            this.publicationType = 'M';
        }
        else if(letterType == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || letterType == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper)
        {
            this.publicationType = 'N';
        }

        this.batchCount = batchCount;
        this.sessionId = sessionId;
        batchIds.addAll(subsIds);
        
        isAdhoc = true;
        batchMode = 'Y';
        batchCodeFinal = batchCodeParam;
    }

    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //START PD-0210 18May2016 Added By C. Lin - Exclude old Subscription With Renewal Case
        List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>();
        List<Case> caseList = new List<Case>();
        Set<Id> subIdSet = new Set<Id>();
        Set<Id> subIdWithRenewalCaseSet = new Set<Id>();
        //END PD-0210 18May2016 Added By C. Lin
        
        if(isAdhoc){
            BatchCode = batchCodeFinal;
        }else {      
            String shortjobID = String.valueOf(BC.getJobId()).subString(0,15);
            List<BATCH_JOB_SCHEDULER__c> batchJobScheduler = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortjobID OR SFDC_Job_id__c = :BC.getJobId()];
            BatchCode = batchJobScheduler[0].Batch_Code__c;
        }
        String subProdType = ''; 
        
        String flagStr = '';
        String query = '';
        
            if(batchMode == 'N'){ //START END PD-0146 Gdelrosario : change the condition to batchMode instead of adhoc
                //START D-4354 27.1.2016 Gdelrosario : added the custom setting for configurability
                if(BatchCode == 'SP022'){
                     EndDate   = refDate.addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',true));
                     subProdType = 'Magazine';   
                     //START PD-0147 13May2016 Added By C. Lin - Prevent Duplicate
                     //flagStr = 'AND (is1stPDFGenerated__c = FALSE ';
                     //flagStr += 'OR is1stNotifEmailSent__c = FALSE)';
                     flagStr = 'AND ((is1stPDFGenerated__c = FALSE AND Zuora__Account__r.Renewal_Letter__c IN (:hardcopy, :both)) ';
                     flagStr += 'OR (is1stNotifEmailSent__c = FALSE AND Zuora__Account__r.Renewal_Letter__c IN (:email, :both)))';
                     //END PD-0147 13May2016 Added By C. Lin
                }else if(BatchCode == 'SP023'){
                     EndDate   = refDate.addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',false));
                     subProdType = 'Magazine';
                     //START PD-0147 13May2016 Added By C. Lin - Prevent Duplicate
                     //flagStr = 'AND (is2ndPDFGenerated__c = FALSE ';
                     //flagStr += 'OR is2ndNotifEmailSent__c = FALSE)';
                     flagStr = 'AND ((is2ndPDFGenerated__c = FALSE AND Zuora__Account__r.Renewal_Letter__c IN (:hardcopy, :both)) ';
                     flagStr += 'OR (is2ndNotifEmailSent__c = FALSE AND Zuora__Account__r.Renewal_Letter__c IN (:email, :both)))';
                     //END PD-0147 13May2016 Added By C. Lin
                }else if(BatchCode == 'SP024'){
                     EndDate   = refDate.addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',true));
                     subProdType = 'Newspaper';   
                     //START PD-0147 13May2016 Added By C. Lin - Prevent Duplicate
                     //flagStr = 'AND (is1stPDFGenerated__c = FALSE ';
                     //flagStr += 'OR is1stNotifEmailSent__c = FALSE)';
                     flagStr = 'AND ((is1stPDFGenerated__c = FALSE AND Zuora__Account__r.Renewal_Letter__c IN (:hardcopy, :both)) ';
                     flagStr += 'OR (is1stNotifEmailSent__c = FALSE AND Zuora__Account__r.Renewal_Letter__c IN (:email, :both)))';
                     //END PD-0147 13May2016 Added By C. Lin
                }else if(BatchCode == 'SP025'){
                     EndDate   = refDate.addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',false));
                     subProdType = 'Newspaper';
                     //START PD-0147 13May2016 Added By C. Lin - Prevent Duplicate
                     //flagStr = 'AND (is2ndPDFGenerated__c = FALSE ';
                     //flagStr += 'OR is2ndNotifEmailSent__c = FALSE)';
                     flagStr = 'AND ((is2ndPDFGenerated__c = FALSE AND Zuora__Account__r.Renewal_Letter__c IN (:hardcopy, :both)) ';
                     flagStr += 'OR (is2ndNotifEmailSent__c = FALSE AND Zuora__Account__r.Renewal_Letter__c IN (:email, :both)))';
                     //END PD-0147 13May2016 Added By C. Lin
                }
                //END D-4354 27.1.2016 Gdelrosario : added the custom setting for configurability
            }
        
        query += 'SELECT Id, Order_Line_Item_Number_1__c,';
        query += 'is1stPDFGenerated__c, '; 
        query += 'is2ndPDFGenerated__c, '; 
        query += 'is1stNotifEmailSent__c, '; 
        query += 'is2ndNotifEmailSent__c, '; 
        query += 'Zuora__CustomerAccount__c, '; 
        query += 'Product_Code__c, ';       
        query += 'Zuora__SubscriptionEndDate__c, ';     
        query += 'Zuora__Account__r.Renewal_Letter__c, ';     
        query += 'Main_Package_1__c, ';     
        query += 'Main_Package_1__r.Effective_End_Date__c, '; 
        query += 'Main_Package_1__r.Package_Type__c, ';
        query += 'Main_Package_Product_Sub_Type_Mapping__c ';      
        query += 'FROM Zuora__Subscription__c ';
        if(batchMode == 'N'){ 
            query += 'WHERE Zuora__SubscriptionEndDate__c = :EndDate ';
            query += 'AND Zuora__TermSettingType__c !=: evergreen ';
            //START PD-0210 18May2016 Added By C. Lin - Remove futureActive
            query += 'AND Status_Formula__c =: active '; //START END PD-0204 17May2016 Added By C. Lin - Use Status Formula in getting Subscriptions
            //END PD-0210 18May2016 Added By C. Lin
            //START PD-0120 23May2016 Added By C. Lin - Revert back to consider Supressed_Renewal_and_Reminder_Letter_1__c
            query += 'AND Zuora__AutoRenew__c = FALSE AND Supressed_Renewal_and_Reminder_Letter_1__c = FALSE '; //START-END : D-4135 12/18/2015
            //END PD-0120 23May2016 Added By C. Lin
            query += 'AND (Zuora__Account__r.Renewal_Letter__c =: hardcopy ';
            query += 'OR Zuora__Account__r.Renewal_Letter__c =: email ';
            query += 'OR Zuora__Account__r.Renewal_Letter__c =: both) ';
            query += 'AND Main_Package_Product_Sub_Type_Mapping__c =: subProdType ';
            query += flagStr;
            query += 'AND Subscription_Type_1__c = :publication';
            
            //START PD-0210 18May2016 Added By C. Lin - Exclude old Subscription With Renewal Case
            subsList = Database.query(query);
            
            if(!subsList.isEmpty()){
                for(Zuora__Subscription__c subRec : subsList){
                    subIdSet.add(subRec.Id);
                }
            }
            
            if(!subIdSet.isEmpty()){
                caseList = [SELECT Id, Subscription_Name__c FROM Case WHERE RecordType.Name = 'Renewal of Subscription' AND Subscription_Name__c IN :subIdSet AND Status = 'Closed'];
            }
            
            if(!caseList.isEmpty()){
                for(Case caseRec : caseList){
                    if(caseRec.Subscription_Name__c != null){
                        subIdWithRenewalCaseSet.add(caseRec.Subscription_Name__c);
                    }
                }
            }
            
            if(!subIdWithRenewalCaseSet.isEmpty()){
                query += ' AND Id NOT IN :subIdWithRenewalCaseSet';
            }
            //END PD-0210 18May2016 Added By C. Lin
        }else{
            query += 'WHERE Id IN :batchIds';
        }       
        
        System.debug('Query String: ' + query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope)
    {   

        System.debug('execute start =========================================================================>');
        System.debug('scope :' + scope);
        Logger logger;
        if(!Test.isRunningTest()) {  
            logger = new Logger (SP_RenewalReminderRequestBatch.class.getName(), BatchCode, BC.getJobID());
        } 
        
        try{
            letterPrintRequests = new List<Letter_Print_Request__c>(); 
            
            Set<Id> subscriptionIdSet = new Set<Id>(); 
            Set<String> productCodeSet = new Set<String>();
            Set<Id> packageIdSet = new Set<Id>();
            Set<Id> billingAccountIdSet = new Set<Id>(); 
            
            List<zqu__ZProduct__c> productList = new List<zqu__ZProduct__c>();
            
            Map<Id,String> subscriptionLanguageMediumMap = new Map<Id,String>();
            Map<Id,Package__c> mainPackageMap = new Map<Id,Package__c>();
            Map<String,zqu__ZProduct__c> productMap = new Map<String,zqu__ZProduct__c>();
            Map<Id,List<Letter_Print_Request__c>> orderLineItem_existingLPRs = new Map<Id,List<Letter_Print_Request__c>>();
            Map<Id,List<Zuora__Subscription__c>> orderLineItem_subscription_map = new Map<Id,List<Zuora__Subscription__c>>();
            Map<Id,String> subscriptionId_languageMediumMap = new Map<Id,String>();
            
            SP_RenewalReminderHelper.RenewalRateGroup renewalRateGroup;
            
            for(Zuora__Subscription__c batchObject : scope)
            {
                
                subscriptionIdSet.add(batchObject.Id); 

                productCodeSet.add(batchObject.Product_Code__c);
                packageIdSet.add(batchObject.Main_Package_1__c);
                billingAccountIdSet.add(batchObject.Zuora__CustomerAccount__c);
            }
            
            // START : D-3997 11/26/2015 Alyana Navarro
            mainPackageMap = new Map<Id,Package__c>(
            [SELECT Id, Package_Type__c,
            RenewalPkgCodeMag1YrBase__c,RenewalPkgCodeMag1YrBase__r.Package_Price__c, 
            RenewalPkgCodeMag2YrBase__c,RenewalPkgCodeMag2YrBase__r.Package_Price__c,
            RenewalPkgCodeMag1YrDisc__c,RenewalPkgCodeMag1YrDisc__r.Package_Price__c,
            RenewalPkgCodeMag2YrDisc__c,RenewalPkgCodeMag2YrDisc__r.Package_Price__c,
            RenewalPkgCodeNewspaper__c,RenewalPkgCodeNewspaper__r.Package_Price__c, 
            Same_Pck_Renewal_Mag_1_Yr_Base__c, Same_Pck_Renewal_Mag_2_Yr_Base__c, 
            Same_Pck_Renewal_Mag_1_Yr_Disc__c, Same_Pck_Renewal_Mag_2_Yr_Disc__c, 
            Same_Pck_Renewal_Newspaper__c, Package_Price__c
            FROM Package__c WHERE Id IN :packageIdSet]);        
            // END : D-3997 11/26/2015 Alyana Navarro
            
            productList = [SELECT Id, ProductCode__c,
            RenewalPkgCodeMag1YrBase__c,RenewalPkgCodeMag1YrBase__r.Package_Price__c, 
            RenewalPkgCodeMag2YrBase__c,RenewalPkgCodeMag2YrBase__r.Package_Price__c,
            RenewalPkgCodeMag1YrDisc__c,RenewalPkgCodeMag1YrDisc__r.Package_Price__c,
            RenewalPkgCodeMag2YrDisc__c,RenewalPkgCodeMag2YrDisc__r.Package_Price__c,
            RenewalPkgCodeNewspaper__c,RenewalPkgCodeNewspaper__r.Package_Price__c,
            Suppress_Renewal_Letter__c, Suppress_Reminder_Letter__c
            FROM zqu__ZProduct__c 
            WHERE ProductCode__c IN :productCodeSet 
            AND zqu__Deleted__c = false];
            
            for(zqu__ZProduct__c productElem : productList) {
                productMap.put(productElem.ProductCode__c, productElem);
            }           
            
            Set<Id> allInvalidOrderLineItems = new Set<Id>();
            Set<Id> orderLineItemsWithInvalidPackage = new Set<Id>();
            Set<Id> orderLineItemsWithInvalidProduct = new Set<Id>();
            Set<Id> orderLineItemsWithMissingRates = new Set<Id>();
            
            orderLineItemsWithInvalidPackage.addAll(SP_RenewalReminderHelper.getOrderLineItemWithInvalidPackage(scope));
            //START PD-0147 13May2016 Added By C. Lin - Add batchMode parameter
            //START PD-0146 Gdelrosario : added paramater becuase added parameter in the 
            orderLineItemsWithInvalidProduct.addAll(SP_RenewalReminderHelper.getSuspendedOrderLineItemSet(scope, productMap, adhocBatchRunDate, isAdhoc, batchMode));      
            //END PD-0146 Gdelrosario : added paramater becuase added parameter in the 
            //END PD-0147 13May2016 Added By C. Lin
            renewalRateGroup = SP_RenewalReminderHelper.getRenewalRates(scope, mainPackageMap,productMap);
            orderLineItemsWithMissingRates = renewalRateGroup.invalidOrderLineItemIdSet;            
            
            allInvalidOrderLineItems.addAll(orderLineItemsWithInvalidPackage);
            allInvalidOrderLineItems.addAll(orderLineItemsWithInvalidProduct);
            allInvalidOrderLineItems.addAll(orderLineItemsWithMissingRates);
            
            subscriptionLanguageMediumMap = SP_RenewalReminderHelper.getSubscriptionLanguageMediumMap(subscriptionIdSet); 
            
            for(Zuora__Subscription__c batchObject : scope){
                if(orderLineItem_subscription_map.get(batchObject.Order_Line_Item_Number_1__c) ==  null)
                    orderLineItem_subscription_map.put(batchObject.Order_Line_Item_Number_1__c, new List<Zuora__Subscription__c>());
                orderLineItem_subscription_map.get(batchObject.Order_Line_Item_Number_1__c).add(batchObject);
                
                String languageMedium;
                if(subscriptionLanguageMediumMap.containsKey(batchObject.Id))
                        languageMedium = subscriptionLanguageMediumMap.get(batchObject.Id);
                else
                        languageMedium = SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH;
                subscriptionId_languageMediumMap.put(batchObject.Id, languageMedium);
            }
            
            Set<Id> existingLPRSubscriptionIdSet = new Set<Id>();
            Map<Id,Letter_Print_Request__c> subscriptionId_LPR_map = new Map<Id,Letter_Print_Request__c>();
            
            List<Letter_Print_Request__c> existingLPRList = [SELECT Id, Record_ID__c, Language_Medium__c FROM Letter_Print_Request__c WHERE Billing_Account__c IN :billingAccountIdSet AND Letter_Type__c = :letterType AND Type__c = :SP_RenewalReminderConsolidator.LPR_TYPE_DETAIL AND (Status__c = :SP_GenerateLetterPrintBatch.newValue OR Status_Email__c = :SP_GenerateLetterPrintBatch.newValue)];
            
            for(Letter_Print_Request__c existingLPRElem :  existingLPRList) {
                existingLPRSubscriptionIdSet.add(existingLPRElem.Record_ID__c);
                subscriptionId_LPR_map.put(existingLPRElem.Record_ID__c, existingLPRElem);
            }         
            
            List<Zuora__Subscription__c> existingLPRSubscriptionList = [SELECT Id,Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE Id IN :existingLPRSubscriptionIdSet AND Main_Package_1__r.Package_Type__c = :GlobalVariableClass.PACKAGETYPE_BUNDLE];
            
            for(Zuora__Subscription__c LPRSubscriptionElem : existingLPRSubscriptionList){
            
                Letter_Print_Request__c existingLPR = subscriptionId_LPR_map.get(LPRSubscriptionElem.Id);
                if(orderLineItem_existingLPRs.get(LPRSubscriptionElem.Order_Line_Item_Number_1__c) == null)
                    orderLineItem_existingLPRs.put(LPRSubscriptionElem.Order_Line_Item_Number_1__c, new List<Letter_Print_Request__c>());
                orderLineItem_existingLPRs.get(LPRSubscriptionElem.Order_Line_Item_Number_1__c).add(existingLPR);
            }
            

            for(Zuora__Subscription__c batchObject : scope)
            {               
                Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                letterPrintRequest.Letter_Type__c = letterType;
                letterPrintRequest.Record_ID__c = batchObject.Id;               
                letterPrintRequest.Type__c = SP_RenewalReminderConsolidator.LPR_TYPE_DETAIL;            
                letterPrintRequest.Billing_Account__c = batchObject.Zuora__CustomerAccount__c;                  

                
                String languageMedium = subscriptionId_languageMediumMap.get(batchObject.Id);
                if(batchObject.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE) {
                    List<Letter_Print_Request__c> relatedLPRs = orderLineItem_existingLPRs.get(batchObject.Order_Line_Item_Number_1__c);
                    List<Zuora__Subscription__c> bundledSubscriptions = orderLineItem_subscription_map.get(batchObject.Order_Line_Item_Number_1__c);
                    if(relatedLPRs != null)
                        languageMedium = SP_RenewalReminderHelper.getFinalLanguageMedium(relatedLPRs, languageMedium);
                    if(bundledSubscriptions != null && subscriptionId_languageMediumMap != null)
                        languageMedium = SP_RenewalReminderHelper.getFinalLanguageMedium(bundledSubscriptions, subscriptionId_languageMediumMap);
                }
                
                letterPrintRequest.Language_Medium__c = languageMedium;                 
                    
                String lprStatus = SP_GenerateLetterPrintBatch.newValue;
                if(allInvalidOrderLineItems.contains(batchObject.Order_Line_Item_Number_1__c)) {                    
                    lprStatus = 'Validation Code: ';
                    
                    if(orderLineItemsWithInvalidPackage.contains(batchObject.Order_Line_Item_Number_1__c))
                        lprStatus += ' 1';
                    else                    
                        lprStatus += ' 0';
                        
                    if(orderLineItemsWithInvalidProduct.contains(batchObject.Order_Line_Item_Number_1__c))
                        lprStatus += ' 1';
                    else                    
                        lprStatus += ' 0';
                        
                    if(orderLineItemsWithMissingRates.contains(batchObject.Order_Line_Item_Number_1__c))
                        lprStatus += ' 1';
                    else                    
                        lprStatus += ' 0';                      
                }   

                letterPrintRequest.Status__c = lprStatus;
                letterPrintRequest.Status_Email__c = lprStatus;
                    
                if(batchObject.Zuora__Account__r.Renewal_Letter__c == hardcopy)                 
                    letterPrintRequest.Status_Email__c = 'Suppressed';
                else if(batchObject.Zuora__Account__r.Renewal_Letter__c == email)
                    letterPrintRequest.Status__c = 'Suppressed';    
                
                //START PD-0147 12May2016 Added By C. Lin - Bypass is1stPDFGenerated__c, is2ndPDFGenerated__c for AdHoc SubId
                if(batchMode == 'N'){
                    if(BatchCode == 'SP022' || BatchCode == 'SP024'){
                        if(batchObject.is1stPDFGenerated__c)
                            letterPrintRequest.Status__c = 'Suppressed - PDF Generated';
                        if(batchObject.is1stNotifEmailSent__c)                                  
                            letterPrintRequest.Status_Email__c = 'Suppressed - Email Sent';
                    }else if(BatchCode == 'SP023' || BatchCode == 'SP025'){
                        if(batchObject.is2ndPDFGenerated__c)
                            letterPrintRequest.Status__c = 'Suppressed - PDF Generated';
                        if(batchObject.is2ndNotifEmailSent__c)                                  
                            letterPrintRequest.Status_Email__c = 'Suppressed - Email Sent';
                    }      
                }
                //END PD-0147 12May2016 Added By C. Lin

                letterPrintRequests.add(letterPrintRequest);   
            }
            if(letterPrintRequests.size() > 0)
            {
                try{
                    insert letterPrintRequests;
                }catch(Exception e){
                    System.debug('Error: ' + e.getMessage());
                    throw e;
                }
            }
        }catch(Exception e){
            if(!Test.isRunningTest()) {
                logger.logBatchFailure(e, scope);
                logger.save();
            }           
            isApexJobSuccessful = false;   
        }       
    }    
    
    global void finish(Database.BatchableContext BC){
    
        //START: D-4262 1-12-2016 Added by Kristine Balaoing
        
        List<Exception> exceptionList = new List<Exception>();
        
        try{    
            SP_RenewalReminderConsolidator batchInstance = new SP_RenewalReminderConsolidator(BC.getJobId(), batchCode, letterType, sessionId, isApexJobSuccessful);
            Database.executeBatch(batchInstance);
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
    }    
}