/**
* Class Name: SP_SendEmailNotifForSubsRenewalsBatch 
* @author: Jayson Sarion
* Date: 
* Requirement/Project Name: CRSM Project
* @description Batch Apex Class to retrieve all subscriptions expiring in two weeks. An email notification will be send 
* to the subscriber for Subscription Renewal Notice.
* History: 
*   UD-2535, UD-2803, UD-2610 and UD-2423 11/23/2015 Alyana Navarro - Reconstructed whole class.
*/
global class SP_SendEmailNotifForSubsRenewalsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {          
    //START D-4354 27.1.2016 Gdelrosario : added the custom setting for configurability
    Date firstNotifDateMag = System.Today().addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',true));
    Date secondNotifDateMag = System.Today().addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',false));
    Date firstNotifDateNews = System.Today().addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',true));
    Date secondNotifDateNews = System.Today().addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',false));
    //END D-4354 27.1.2016 Gdelrosario : added the custom setting for configurability
        
    List<exception> exceptionList = new List<exception>();
    Set<Id> failedRecs = new Set<Id>();
    Boolean isAdhoc = false;
    Boolean isApexJobSuccessful = true;
    String firstNewspaperRenewal = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
    String secondNewspaperRenewal = SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper;
    String firstMagazineRenewal = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
    String secondMagazineRenewal = SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine;
    
    global SP_SendEmailNotifForSubsRenewalsBatch(){
        
    }
  
    global SP_SendEmailNotifForSubsRenewalsBatch(Set<Id> renewalMasterLetterPrintRequest, Date batchRunDate){
        //START D-4354 27.1.2016 Gdelrosario : added for custom settings for configurability
        this.firstNotifDateMag = batchRunDate.addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',true));
        this.secondNotifDateMag = batchRunDate.addDays((ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',false)));
        this.firstNotifDateNews = batchRunDate.addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',true));
        this.secondNotifDateNews = batchRunDate.addDays((ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',false)));
        //END D-4354 27.1.2016 Gdelrosario : added for custom settings for configurability
        this.failedRecs = renewalMasterLetterPrintRequest;
        this.isAdhoc = true;        
    }
    
    /* @description Called at the beginning of the apex job to collect the objects    
    * to be passed to the execute method    
    * @param bc - predefined parameter     
    * @return list of records from Letter Print Request Object    
    */  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';

        query = 'SELECT id, name, Status_Email__c, Letter_Type__c, Language_Medium__c, Billing_Account__c, Type__c';
        query += ' FROM Letter_Print_Request__c';
        if(isAdhoc){
            query += ' WHERE Type__c = \'Master\'';
            query += ' AND (Letter_Type__c =: firstNewspaperRenewal OR Letter_Type__c =: secondNewspaperRenewal';
            query += ' OR Letter_Type__c =: firstMagazineRenewal OR Letter_Type__c =: secondMagazineRenewal)';
            query += ' AND id IN: failedRecs';
        } else {
            query += ' WHERE type__c = \'Master\' AND Status_Email__c = \'New\'';
            query += ' AND (Letter_Type__c =: firstNewspaperRenewal OR Letter_Type__c =: secondNewspaperRenewal';
            query += ' OR Letter_Type__c =: firstMagazineRenewal OR Letter_Type__c =: secondMagazineRenewal)';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Letter_Print_Request__c> parentLetterPrintRequestList) {
        
        Logger logger = new Logger(SP_SendEmailNotifForSubsRenewalsBatch.class.getName(), 'SP015', BC.getJobID());
        Savepoint sp = Database.setSavepoint(); 
        Boolean emailIsError = false; // START-END : D-4004 12/1/2015 Alyana Navarro
        try{
            EmailTemplate magazineTemplate = [SELECT HtmlValue, subject, Name FROM EmailTemplate WHERE Name = 'Magazines Renewal and Reminder'];
            EmailTemplate newspaperTemplate = [SELECT HtmlValue, subject, Name FROM EmailTemplate WHERE Name = 'Newspaper Renewal Reminder'];
            EmailTemplate magazineChineseTemplate = [SELECT HtmlValue, subject, Name 
                                                     FROM EmailTemplate 
                                                     WHERE Name = 'Chinese Magazine Renewal & Reminder'];
            EmailTemplate newspaperChineseTemplate = [SELECT HtmlValue, subject, Name 
                                                      FROM EmailTemplate 
                                                      WHERE Name = 'Chinese Newspaper Renewal & Reminder'];
            
            Letter_Print_Request__c updatedLPR;
            Messaging.SingleEmailMessage singleEmail;
            // START : D-4004 12/1/2015 Alyana Navarro
            String emailAddresses = '';
            String errorMessage = '';
            // END : D-4004 12/1/2015 Alyana Navarro
            Set<String> subIdSet = new Set<String>();
            Set<String> productCodeSet = new Set<String>();
            Set<Id> failedParentLPRIdSet = new Set<Id>();
            Set<Id> packageIdSet = new Set<Id>();
            Set<Id> billingAccountIdSet = new Set<Id>();
            Set<Id> parentLetterPrintRequestIdSet = new Set<Id>();
            Set<Id> invalidOrderLineItemIdSet = new Set<Id>();
            List<Contact> recipientContactList = new List<Contact>();
            List<Package__c> packageList = new List<Package__c>();
            List<Package__c> renewalPackageList  = new List<Package__c>();
            List<Zuora__Subscription__c> subscriptionList;
            List<Zuora__Subscription__c> updatedSubscriptionList = new List<Zuora__Subscription__c>();
            List<Letter_Print_Request__c> updatedLPRList = new List<Letter_Print_Request__c>();
            List<Messaging.SingleEmailMessage> renewalEmailList = new List<Messaging.SingleEmailMessage>();
            List<Letter_Print_Request__c> childLetterPrintRequestList = new List<Letter_Print_Request__c>();
            List<Letter_Print_Request__c> newChildLetterPrintRequestList = new List<Letter_Print_Request__c>();
            Map<id, Decimal> subscriptionDelPostCharge;
            Map<Id, List<Zuora__Subscription__c>> parentLPRSubscriptionList = new Map<Id, List<Zuora__Subscription__c>>(); // START-END : D-4004 12/1/2015 Alyana Navarro
            Map<id, Letter_Print_Request__c> childLPRMap = new Map<Id, Letter_Print_Request__c>();
            Map<Id, List<Zuora__Subscription__c>> parentLPRSubListMap = new Map<Id, List<Zuora__Subscription__c>>();        
            Map<Id, Package__c> packageMap = new Map<Id, Package__c>();
            Map<Id, Package__c> renewalPackageMap = new Map<Id, Package__c>();
            Map<Id, Contact> recipientContactMap = new Map<Id, Contact>();
            Map<String, zqu__ZProduct__c> productMap = new Map<String, zqu__ZProduct__c>();     
            Map<id, Zuora__Subscription__c> subscriptionMap = new Map<id, Zuora__Subscription__c>();
            Map<id, Zuora__CustomerAccount__c> billingAccountMap = new Map<id, Zuora__CustomerAccount__c>();        
            Map<id, List<Zuora__Subscription__c>> orderLineIdSubscriptionListMap = new Map<Id, List<Zuora__Subscription__c>>();     
            Map<Id, Letter_Print_Request__c> parentLetterPrintRequestMap = new Map<Id, Letter_Print_Request__c>();          
            Map<Id, Set<Id>> recipientOrderLineItemListMap = new Map<Id, Set<Id>>();
            // START : UD-3701 1/14/2016 Alyana Navarro
            Map<Id, Map<Id, SP_RenewalReminderHelper.DeliveryPostageFee>> parentLPRRecipientIdDelPostChargeMap = new Map<Id, Map<Id, SP_RenewalReminderHelper.DeliveryPostageFee>>();
            Map<Id, List<Zuora__Subscription__c>> parentLPRSubscriptionListMap = new Map<Id, List<Zuora__Subscription__c>>();
            Map<Id, Zuora__Subscription__c> updatedSubscriptionMap = new Map<Id, Zuora__Subscription__c>();
            // END : UD-3701 1/14/2016 Alyana Navarro
            SP_RenewalReminderMapper.RenewalSubscriptionGroup mapper = new SP_RenewalReminderMapper.RenewalSubscriptionGroup();
            SP_RenewalReminderHelper.RenewalRateGroup renewalRateGroupRec = new SP_RenewalReminderHelper.RenewalRateGroup();
            List<Document> sphLogoDoc = [Select Id, Name From Document Where Name = :ConstantsSLB.getOther('SPH Logo v2') Limit 1];
                            
            String sphLogo = '';
                    
            if(sphLogoDoc.size()>0){
                sphLogo = string.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
                sphLogo += '/servlet/servlet.ImageServer?id=' + sphLogoDoc[0].Id;
                sphLogo += '&oid=' + string.valueOf(Userinfo.getOrganizationId());
            }
            
            for(Letter_Print_Request__c parentLetterPrintRequest : parentLetterPrintRequestList){           
                parentLetterPrintRequestIdSet.add(parentLetterPrintRequest.id);
                parentLetterPrintRequestMap.put(parentLetterPrintRequest.id, parentLetterPrintRequest);
            }               
            
            childLetterPrintRequestList = [SELECT id, name, Language_Medium__c, Billing_Account__c, Letter_Type__c, Parent_Letter_Print_Request__c, 
                                           Record_Id__c
                                           FROM Letter_Print_Request__c 
                                           WHERE Parent_Letter_Print_Request__c IN: parentLetterPrintRequestIdSet AND Status_Email__c = 'Tagged'];
            
            for(Letter_Print_Request__c childLetterPrintRequest : childLetterPrintRequestList){
                if(childLetterPrintRequest.Record_Id__c != null){
                    subIdSet.add(childLetterPrintRequest.Record_Id__c);             
                }               
            }

            // START : D-3997 11/26/2015 Alyana Navarro
      // START : D-3338 12/7/2015 Alyana Navarro
            // START : UD-3510 1/8/2016 Alyana Navarro
            subscriptionMap = new Map<id, Zuora__Subscription__c>(
                [SELECT id, name, Order_Line_Item_Number_1__c, Recipient_Contact__r.Recipient_Number_Show__c, Zuora__SubscriptionEndDate__c,
                 is1stNotifEmailSent__c, is2ndNotifEmailSent__c, Main_Package_1__c, Main_Package_1__r.name, Main_Package_1__r.RenewalPkgCodeMag1YrBase__c, 
                 Main_Package_1__r.RenewalPkgCodeMag1YrDisc__c, Main_Package_1__r.RenewalPkgCodeMag2YrBase__c, Main_Package_1__r.RenewalPkgCodeMag2YrDisc__c, 
                 Main_Package_1__r.RenewalPkgCodeNewspaper__c, Main_Package_1__r.Package_Type__c, 
                 Main_Package_1__r.RenewalPkgCodeMag1YrBase__r.Package_Price__c, Main_Package_1__r.RenewalPkgCodeMag1YrDisc__r.Package_Price__c, 
                 Main_Package_1__r.RenewalPkgCodeMag2YrBase__r.Package_Price__c, Qty__c, Main_Package_1__r.RenewalPkgCodeMag2YrDisc__r.Package_Price__c, 
                 Main_Package_1__r.RenewalPkgCodeNewspaper__r.Package_Price__c, Recipient_Contact__c, Product_Code__c, Delivered_By__c, 
                 Order_Number_1__r.Delivery_Charge_Type__c, Order_Number_1__r.Delivery_Charge__c, Number_of_Copies__c, 
                 Main_Package_1__r.Effective_End_Date__c, Zuora__CustomerAccount__c, Recipient_Contact__r.name, Recipient_Contact__r.Company_Name__c, 
                 Main_Package_Product_Sub_Type_Mapping__c, Main_Package_1__r.Same_Pck_Renewal_Mag_1_Yr_Base__c, 
                 Main_Package_1__r.Same_Pck_Renewal_Mag_2_Yr_Base__c, Main_Package_1__r.Same_Pck_Renewal_Mag_1_Yr_Disc__c, 
                 Main_Package_1__r.Same_Pck_Renewal_Mag_2_Yr_Disc__c, Main_Package_1__r.Same_Pck_Renewal_Newspaper__c, 
                 Main_Package_1__r.Package_Price__c, Main_Package_1__r.RenewalPkgCodeNewspaper__r.name, Recipient_Contact__r.Address__r.RecordTypeId,
                 Recipient_Contact__r.Address__r.Address_Type__c, Recipient_Contact__r.Address__c, Delivery_Charge_Type__c, 
                 Recipient_Contact__r.Address__r.RecordType.Name
                 FROM Zuora__Subscription__c 
                 WHERE id IN: subIdSet 
                    AND (Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_EMAIL 
                            OR Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_BOTH)]
            );
            // END : UD-3510 1/8/2016 Alyana Navarro
      // END : D-3338 12/7/2015 Alyana Navarro
            // END : D-3997 11/26/2015 Alyana Navarro
            // START : UD-3701 1/14/2016 Alyana Navarro
            for(Letter_Print_Request__c childLPR : childLetterPrintRequestList){
                if(subscriptionMap.containsKey(childLPR.Record_Id__c)){
                    if(parentLPRSubscriptionListMap.containsKey(childLPR.Parent_Letter_Print_Request__c)){
                        parentLPRSubscriptionListMap.get(childLPR.Parent_Letter_Print_Request__c).add(subscriptionMap.get(childLPR.Record_Id__c));
                    } else {
                        parentLPRSubscriptionListMap.put(childLPR.Parent_Letter_Print_Request__c, new List<Zuora__Subscription__c>{subscriptionMap.get(childLPR.Record_Id__c)});
                    }
                }
            }
            
            parentLPRRecipientIdDelPostChargeMap = SP_RenewalReminderHelper.getrecipientDeliveryPostageFeeMap(parentLPRSubscriptionListMap);
            // END : UD-3701 1/14/2016 Alyana Navarro
            
            for(Zuora__Subscription__c subscription : subscriptionMap.values()){            
                productCodeSet.add(subscription.Product_Code__c);
                packageList.add(subscription.Main_Package_1__r);            
                recipientContactList.add(subscription.Recipient_Contact__r);
                billingAccountIdSet.add(subscription.Zuora__CustomerAccount__c);
            }

            recipientContactMap.putAll(recipientContactList);
            packageMap.putAll(packageList);     
            
            // START : UD-3338 12/3/2015 Alyana Navarro
            for(zqu__ZProduct__c product : [SELECT id, name, ProductCode__c, RenewalPkgCodeMag1YrBase__c, RenewalPkgCodeMag1YrDisc__c, 
                                             RenewalPkgCodeMag2YrBase__c, RenewalPkgCodeMag2YrDisc__c, RenewalPkgCodeNewspaper__c, 
                                             RenewalPkgCodeMag1YrBase__r.Package_Price__c, RenewalPkgCodeMag1YrDisc__r.Package_Price__c, 
                                             RenewalPkgCodeMag2YrBase__r.Package_Price__c, RenewalPkgCodeMag2YrDisc__r.Package_Price__c, 
                                             RenewalPkgCodeNewspaper__r.Package_Price__c, Suppress_Reminder_Letter__c, Suppress_Renewal_Letter__c,
                                             RenewalPkgCodeNewspaper__r.name
                                             FROM zqu__ZProduct__c
                                             WHERE ProductCode__c IN: productCodeSet AND zqu__Deleted__c = false]){
                productMap.put(product.ProductCode__c, product);
            }
            // END : UD-3338 12/3/2015 Alyana Navarro
            
            // START : UD-3510 1/11/2016 Alyana Navarro
            billingAccountMap = new Map<id, Zuora__CustomerAccount__c>(
                [SELECT id, name, Billing_Contact__r.Address__r.RecordTypeId, Billing_Contact__r.Address__r.Block_House_Number__c, 
                 Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c, Billing_Contact__r.Address__r.Building_Name__c, 
                 Billing_Contact__r.Address__r.Level_Number__c, Billing_Contact__r.Address__r.Unit_Number__c, 
                 Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c, Billing_Contact__r.MailingCountry, 
                 Billing_Contact__r.Address__r.Postal_Code__r.Name, Billing_Contact__r.Address__r.Country__r.Country_Name__c, 
                 Billing_Contact__r.Address__r.Section_Code__r.Name, Billing_Contact__r.Address__r.Department__r.Name, 
                 Billing_Contact__r.Address__r.Division_Code__r.Name, Billing_Contact__r.Address__r.Company_Code__r.Name, 
                 Billing_Contact__r.Address__r.Location_Code__r.Name, Billing_Contact__r.Address__r.City__r.City_Name__c, 
                 Billing_Contact__r.Address__r.Airline_Number__c, Billing_Contact__r.Address__r.City__c, Billing_Contact__r.Email_Secondary__c, 
                 Billing_Contact__r.Address__r.recordType.developerName, Billing_Contact__r.Address__r.Flight_Number_1__c, 
                 Billing_Contact__r.Address__r.Flight_Number_2__c, Billing_Contact__r.Address__r.Address_1__c, Billing_Contact__r.Email, 
                 Billing_Contact__r.Address__r.Address_2__c, Billing_Contact__r.Address__r.Address_3__c, Billing_Contact__r.Address__r.Address_4__c, 
                 Billing_Contact__r.Address__r.Location_Code__c, Billing_Contact__r.Address__r.Street_Name__c, Billing_Contact__r.Address__r.Company_Code__c, 
                 Billing_Contact__r.Address__r.Division_Code__c, Billing_Contact__r.Address__r.Department__c, Billing_Contact__r.Address__r.Section_Code__c, 
                 Billing_Contact__r.Name, Billing_Contact__r.Mobile_Number__c, Billing_Contact__r.Office_Number__c, Billing_Contact__r.HomePhone__c, 
                 Billing_Contact__c, Billing_Contact__r.Company_Name__c, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, Billing_Contact__r.Address__r.City__r.Country__r.Country_Name__c
                 FROM Zuora__CustomerAccount__c 
                 WHERE Id IN: billingAccountIdSet]
            );
            // END : UD-3510 1/11/2016 Alyana Navarro
            
            renewalRateGroupRec = SP_RenewalReminderHelper.getRenewalRates(subscriptionMap.values(), packageMap, productMap);       
            invalidOrderLineItemIdSet.addAll(renewalRateGroupRec.invalidOrderLineItemIdSet);
            
            for(Letter_Print_Request__c childLPR : childLetterPrintRequestList){
                if(subscriptionMap.containsKey(childLPR.Record_Id__c)){
                    if(invalidOrderLineItemIdSet.size() <= 0 || !invalidOrderLineItemIdSet.contains(subscriptionMap.get(childLPR.Record_Id__c).Order_Line_Item_Number_1__c)){
                        newChildLetterPrintRequestList.add(childLPR);
                    }
                }           
            }
            
            mapper = SP_RenewalReminderMapper.initializeRenewalSubscriptionGroup(newChildLetterPrintRequestList, subscriptionMap);              
            // Set<Zuora__Subscription__c> subscriptionSet = new Set<Zuora__Subscription__c>(); START-END : UD-3338 12/7/2015 Alyana Navarro - Remove
      // START : D-4004 12/1/2015 Alyana Navarro
            List<Letter_Print_Request__c> validParentLPRList = new List<Letter_Print_Request__c>();
      Map<id, Letter_Print_Request__c> updatedParentLPRMap = new Map<Id, Letter_Print_Request__c>();
            for(Letter_Print_Request__c parentLetterPrintRequest : parentLetterPrintRequestList){
                if(mapper.masterLPRId_orderLineItemIdList_map.containsKey(parentLetterPrintRequest.id)){
                    subscriptionList = new List<Zuora__Subscription__c>();
                    for(Id orderLineItemId : mapper.masterLPRId_orderLineItemIdList_map.get(parentLetterPrintRequest.id)){
                        subscriptionList.addAll(mapper.orderLineItemId_subscriptionList_map.get(orderLineItemId));
                    }
                    
                    recipientOrderLineItemListMap = SP_RenewalReminderMapper.groupOrderLineItemsByRecipient(subscriptionList);
                    
                    String publicationType = '';
                    String renewalType = '';
                    EmailTemplate emailTemplate;
                    updatedLPR = parentLetterPrintRequestMap.get(parentLetterPrintRequest.id);
                    singleEmail = new Messaging.SingleEmailMessage();
                    if(billingAccountMap.containsKey(parentLetterPrintRequest.Billing_Account__c)){
                        if(parentLetterPrintRequest.Language_Medium__c == 'C'){
                            if(parentLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine || parentLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine){                      
                                publicationType = 'Magazine';
                                emailTemplate = magazineChineseTemplate;
                            } else if(parentLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || parentLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper){                     
                                publicationType = 'Newspaper';
                                emailTemplate = newspaperChineseTemplate;
                            }
                        } else if(parentLetterPrintRequest.Language_Medium__c == 'E') {
                            if(parentLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine || parentLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine){                      
                                publicationType = 'Magazine';
                                emailTemplate = magazineTemplate;
                            } else if(parentLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || parentLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper){                     
                                publicationType = 'Newspaper';
                                emailTemplate = newspaperTemplate;
                            }
                        }
                        
                        try{
                            if(billingAccountMap.get(parentLetterPrintRequest.Billing_Account__c).Billing_Contact__r.Email != null || billingAccountMap.get(parentLetterPrintRequest.Billing_Account__c).Billing_Contact__r.Email_Secondary__c != null){
              // START : UD-3338 12/7/2015 Alyana Navarro

                                //START UD-3699 Gdelrosario : added the letter type to change the dependecy from dates to Letter type of Letter Print Request
                                singleEmail = getParsedEmail(emailTemplate, publicationType, subscriptionList[0].Zuora__SubscriptionEndDate__c, billingAccountMap.get(parentLetterPrintRequest.Billing_Account__c), recipientContactMap, recipientOrderLineItemListMap, mapper.orderLineItemId_subscriptionList_map, parentLPRRecipientIdDelPostChargeMap.get(parentLetterPrintRequest.id), sphLogo, renewalRateGroupRec.orderLineItemRenewalRateMap, productMap, packageMap, parentLetterPrintRequest.Letter_Type__c); // START-END : UD-3701 1/14/2016 Alyana Navarro
                                //END UD-3699 Gdelrosario : added the letter type to change the dependecy from dates to Letter type of Letter Print Request
                                validParentLPRList.add(parentLetterPrintRequest);
        // END : UD-3338 12/7/2015 Alyana Navarro
                                renewalEmailList.add(singleEmail);
                                
                                updatedLPR.Status_Email__c = 'Successful';
                                updatedLPR.Email_Address__c = '';
                                
                                for(String emailAddress : singleEmail.getToAddresses()){
                                    updatedLPR.Email_Address__c += emailAddress + '; ';
                                }
                            } else {
                                updatedLPR.Status_Email__c = 'Failed';
                                failedParentLPRIdSet.add(updatedLPR.id);                              
                                emailIsError = true;
                                logger.log(true, 'No email address for Letter Print Request ' + parentLetterPrintRequest.id);                             
                            }                                                      
                        } catch(Exception e){
                            updatedLPR.Status_Email__c = 'Failed';
                            failedParentLPRIdSet.add(updatedLPR.id);                            
                            emailIsError = true;
                            logger.log(e);                          
                        }                  
            updatedParentLPRMap.put(parentLetterPrintRequest.id, updatedLPR);                        
      /* START : UD-3338 12/7/2015 Alyana Navarro - Remove
                        if(!failedParentLPRIdSet.contains(parentLetterPrintRequest.id)){
                            for(Zuora__Subscription__c subscription : subscriptionList){
                                subscriptionSet.add(updateRenewalFieldsInSubscription(subscription, true));
                            }
                        }  END : UD-3338 12/7/2015 Alyana Navarro */
                        
                        parentLPRSubscriptionList.put(parentLetterPrintRequest.id, subscriptionList);
                    }
                } else {
                    parentLetterPrintRequest.Status_Email__c = 'Failed';
                    failedParentLPRIdSet.add(parentLetterPrintRequest.id);                    
                }
            }                        
                    
            try{
                Messaging.SendEmailResult[] renewalEmailResultList = Messaging.sendEmail(renewalEmailList, false);
                // START : UD-3338 12/7/2015 Alyana Navarro
                for(Integer counter = 0; counter < renewalEmailResultList.size(); counter++){
                    if(!renewalEmailResultList[counter].isSuccess()){
                        emailIsError = true;
                        emailAddresses = '';
                        errorMessage = '';
                        
                        for(Messaging.SendEmailError emailError : renewalEmailResultList[counter].getErrors()){
                            errorMessage += '* ' + emailError.getMessage() + '\n';
                        }
                        
                        logger.log(true, 'Email not sent for ' + validParentLPRList[counter].id + '. Errors encountered: \n' + errorMessage);
                        
                        if(parentLPRSubscriptionList.containsKey(validParentLPRList[counter].id)){
                            for(Zuora__Subscription__c subscription : parentLPRSubscriptionList.get(validParentLPRList[counter].id)){
                                // START : UD-3701 1/15/2016 Alyana Navarro
                                //updatedSubscriptionList.add(updateRenewalFieldsInSubscription(subscription, false)); // START-END : UD-3338 12/7/2015 Alyana Navarro
                                //START UD-3699 Gdelrosario : change for the dynamic part not based from dates but from Letter print request in letter type
                                updatedSubscriptionMap.put(subscription.id, updateRenewalFieldsInSubscription(subscription, false, parentLetterPrintRequestMap.get(validParentLPRList[counter].id).Letter_Type__c ));
                                //END UD-3699 Gdelrosario : change for the dynamic part not based from dates but from Letter print request in letter type
                                // END : UD-3701 1/15/2016 Alyana Navarro
                            }
                        }
                        
                        if(updatedParentLPRMap.containsKey(validParentLPRList[counter].id)){
                            updatedParentLPRMap.get(validParentLPRList[counter].id).Status_Email__c = 'Failed';
                        }
                    } else {
                        if(parentLPRSubscriptionList.containsKey(validParentLPRList[counter].id)){
                            for(Zuora__Subscription__c subscription : parentLPRSubscriptionList.get(validParentLPRList[counter].id)){
                                // START : UD-3701 1/15/2016 Alyana Navarro
                                //updatedSubscriptionList.add(updateRenewalFieldsInSubscription(subscription, false)); // START-END : UD-3338 12/7/2015 Alyana Navarro
                                //START UD-3699 Gdelrosario : change for the dynamic part not based from dates but from Letter print request in letter type
                                updatedSubscriptionMap.put(subscription.id, updateRenewalFieldsInSubscription(subscription, true, parentLetterPrintRequestMap.get(validParentLPRList[counter].id).Letter_Type__c ));
                                //END UD-3699 Gdelrosario : change for the dynamic part not based from dates but from Letter print request in letter type
                                // END : UD-3701 1/15/2016 Alyana Navarro
                            }
                        }
                    }
                }
    // END : UD-3338 12/7/2015 Alyana Navarro
                
                // updatedSubscriptionList.addAll(subscriptionSet); START-END : UD-3338 12/7/2015 Alyana Navarro - Remove
                updatedLPRList.addAll(updatedParentLPRMap.values());
                
                if(updatedLPRList.size() > 0){
                    update updatedLPRList;
                }
                
                // START : UD-3701 1/15/2016 Alyana Navarro
                if(updatedSubscriptionMap.size() > 0){
                    SubscriptionTriggerHandler.preventExecution = true; // START-END : D-4004 12/4/2015 Alyana Navarro
                    update updatedSubscriptionMap.values();
                }
                // END : UD-3701 1/15/2016 Alyana Navarro
            } catch(Exception e){
                logger.logBatchFailure(e, parentLetterPrintRequestList);
                emailIsError = true;
            }
        } catch(Exception e){
            Database.rollback(sp); // IF NO CALLOUT IN THE BATCH
            logger.logBatchFailure(e, parentLetterPrintRequestList);
            emailIsError = true;                       
        }
        
        if(emailIsError){
            logger.save();
            isApexJobSuccessful = false;
        }       
    } 
    
    public Zuora__Subscription__c updateRenewalFieldsInSubscription(Zuora__Subscription__c subscription, Boolean fieldValue, String letterType){
        // START : UD-3338 12/7/2015 Alyana Navarro
        //START UD-3699 Gdelrosario : change for the dynamic part not based from dates but from Letter print request in letter type
        if(letterType == firstMagazineRenewal || letterType == firstNewspaperRenewal){ 
            subscription.is1stNotifEmailSent__c = fieldValue;
        } else if(letterType == secondMagazineRenewal || letterType == secondNewspaperRenewal ){
            subscription.is2ndNotifEmailSent__c = fieldValue;
        }
        //END UD-3699 Gdelrosario : change for the dynamic part not based from dates but from Letter print request in letter type
  // END : UD-3338 12/7/2015 Alyana Navarro
        
        return subscription;
    }
    // END : D-4004 12/1/2015 Alyana Navarro
    
    // START : UD-3338 12/3/2015 Alyana Navarro
    public Messaging.SingleEmailMessage getParsedEmail(EmailTemplate emailTemplate, String publicationType, Date subEndDate, Zuora__CustomerAccount__c billingAccount, Map<id, Contact> recipientContactMap, Map<Id, Set<Id>> recipientOrderLineItemListMap, Map<Id,List<Zuora__Subscription__c>> orderLineIdSubListMap, Map<Id, SP_RenewalReminderHelper.DeliveryPostageFee> recipientIdDelPostChargeMap, String sphLogo, Map<Id, SP_RenewalReminderHelper.RenewalRate> orderLineItemRenewalRateMap, Map<String, zqu__ZProduct__c> productMap, Map<id, Package__c> packageMap, String letterType){
    // END : UD-3338 12/3/2015 Alyana Navarro
        Boolean isDeliveredByVendor = false;
        Boolean isDeliveredByMailingAgent = false;
        Integer startIndex = 0;
        Integer endIndex = 0;
        String subs = '';
        String oldValue = '';
        String objName = '';
        String fieldName = '';
        String actualValue = '';
        String notifRenewal = '';
        String template = emailTemplate.HtmlValue;
        String subject = emailTemplate.subject;     
        Decimal subTotal = 0.00;
        Decimal total = 0.00;
        Zuora__Subscription__c subscription;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> subEndDateList;
        List<String> addresses = new List<String>();
        Map<String, String> subMap = new Map<String, String>();                     
        
        String emailAddress = billingAccount.Billing_Contact__r.Email;
        String homeNumber = billingAccount.Billing_Contact__r.HomePhone__c;   
        String officeNumber = billingAccount.Billing_Contact__r.Office_Number__c;   
        String mobileNumber = billingAccount.Billing_Contact__r.Mobile_Number__c;
        
        // START : UD-3510 1/6/2016 Alyana Navarro
        //START UD-3699 Gdelrosario : change for the dynamic part not based from dates but from Letter print request in letter type
        //START D-4354 Gdelrosario : change custom settings
        Date expiryDate;
        if(letterType == firstMagazineRenewal || letterType == firstNewspaperRenewal){
            notifRenewal = 'Renewal';
            expiryDate = Date.today().addDays(ConstantsSLB.getRenewalNotificationExpiryDay('Renewal Notifications Values',true));
        } else if(letterType == secondMagazineRenewal || letterType == secondNewspaperRenewal ){
            notifRenewal = 'Reminder';
            expiryDate = Date.today().addDays(ConstantsSLB.getRenewalNotificationExpiryDay('Renewal Notifications Values',false));
        }
        //END D-4354 Gdelrosario : change custom settings
        //END UD-3699 Gdelrosario : change for the dynamic part not based from dates but from Letter print request in letter type
        String expiryDateStr = (expiryDate.day() < 10 ? '0' : '') + expiryDate.day() + '/' + (expiryDate.month() < 10 ? '0' : '') + expiryDate.month() + '/' + expiryDate.year();
        // END : UD-3510 1/6/2016 Alyana Navarro
        
        subMap.put('baseURL', sphLogo);
        //subMap.put(globalvariableclass.ACCOUNT_NAME, sub.Zuora__Account__r.Name);
        subMap.put(globalvariableclass.ACCOUNT_NUMBER, billingAccount.Zuora__Account__r.AccountNumber);
        subMap.put('expiryDate', expiryDateStr); // START-END : UD-3510 1/6/2016 Alyana Navarro
        subMap.put('BillingAccountNumber', billingAccount.Zuora__AccountNumber__c); // START-END : UD-2473 9/4/2015 Alyana Navarro
        //subMap.put('Total', '$' + total.setScale(2));     
        subMap.put('EmailAddress', emailAddress);
        subMap.put('Homenumber', homeNumber);
        subMap.put('OfficeNumber', officeNumber);
        subMap.put('MobileNumber', mobileNumber);
        subMap.put('ContactMailingAddress', AddressHelper.formatAddress(billingAccount.Billing_Contact__r,false,false));
        subMap.put('DateToday', DateTime.Now().format('d/MM/YYYY'));
        if(billingAccount.Billing_Contact__r.Company_Name__c != null && billingAccount.Billing_Contact__r.Company_Name__c != ''){
            subMap.put('AttentionTo', billingAccount.Billing_Contact__r.Company_Name__c + '<br/>');
        }
        //subMap.put('AttentionTo', billingAccount.Billing_Contact__r.Company_Name__c + '<br/>');
        subMap.put('ContactName', billingAccount.Billing_Contact__r.Name);
        subMap.put('notifRenewal', notifRenewal);

        
        while(startIndex != 1) {
            startIndex = template.indexOf('{{') + 2;
            if (startIndex != 1) {
                endIndex = template.indexOf('}}') + 2;
                oldValue = template.subString(startIndex - 2, endIndex);
                String insideValue = template.subString(startIndex, endIndex - 2);
                
                if (insideValue.contains('.')) {
                    String[] values = insideValue.split('\\.');
                    objName = values[0];
                    fieldName = values[1];
                } else {
                    fieldName = insideValue;
                }

                if (subMap.containsKey(fieldName)) {
                    if (subMap.get(fieldName) != null) {
                        actualValue = String.valueOf(subMap.get(fieldName));
                        template = template.replace(oldValue, actualValue);
                    } else {
                        template = template.remove(oldValue);
                    }
                } else if (fieldName == 'Insert Table') {
                    Date dateNewInstance = Date.newInstance(subEndDate.year(), subEndDate.month(), subEndDate.day());
                    String formattedSubEndDate = String.valueOf(dateNewInstance).subString(0,10);
                    subEndDateList = formattedSubEndDate.split('-');                                    
                    formattedSubEndDate = '';
                    formattedSubEndDate += subEndDateList[2] + '/';
                    formattedSubEndDate += subEndDateList[1] + '/';
                    formattedSubEndDate += subEndDateList[0].substring(2,4);
                    
                    if (publicationType == 'Magazine') {
                        for(Id recipientId : recipientOrderLineItemListMap.keySet()) {                          
                            subs += '<tr>';                         
                                subs += '<td width=100% align = left colspan = 9>';
                                    subs += recipientContactMap.get(recipientId).Recipient_Number_Show__c + '&nbsp;'; 
                                    subs += recipientContactMap.get(recipientId).Name;
                                    if(recipientContactMap.get(recipientId).Company_Name__c != null){
                                        subs += '<br>' + recipientContactMap.get(recipientId).Company_Name__c;
                                    }
                                subs += '</td>';
                            subs += '</tr>';
                            for(Id orderLineItemId : recipientOrderLineItemListMap.get(recipientId)){
                                subscription = orderLineIdSubListMap.get(orderLineItemId)[0];
                                subs += '<tr>';
                                    subs += '<td width=20% align=left>';
                                        // START : UD-3338 12/3/2015 Alyana Navarro
                                        subs += SP_RenewalReminderHelper.getSubscriptionTableLabel(publicationType, productMap, packageMap, orderLineIdSubListMap.get(orderLineItemId));                                        
                                        // END : UD-3338 12/3/2015 Alyana Navarro
                                    subs += '</td>';
                                    
                                    subs += '<td width=10% align=center>';
                                        subs += (subscription.Number_of_Copies__c != null ? Integer.valueOf(subscription.Number_of_Copies__c) : 0);
                                    subs += '</td>';
                                    
                                    subs += '<td width=10% align=center>';
                                        subs += String.valueOf(formattedSubEndDate).subString(0,8);
                                    subs += '</td>';
                                    
                                    // Start UD-3701 13-Jan-2015 Added by S.Puli/Alyana - multiply rate by number of copy
                                    subs += '<td width=10% align=center>'; 
                                            subs += orderLineItemRenewalRateMap.get(subscription.Order_Line_Item_Number_1__c).renewalBaseRate1  *subscription.Number_of_Copies__c;
                                    subs += '</td>';
                                        
                                    subs += '<td width=10% align=center>';                                                          
                                        subs += orderLineItemRenewalRateMap.get(subscription.Order_Line_Item_Number_1__c).renewalDiscRate1 * subscription.Number_of_Copies__c;
                                    subs += '</td>';
                                    
                                    subs += '<td width=10% align=center>(  )</td>';
                                    
                                    subs += '<td width=10% align=center>';                                      
                                        subs += orderLineItemRenewalRateMap.get(subscription.Order_Line_Item_Number_1__c).renewalBaseRate2 * subscription.Number_of_Copies__c;
                                    subs += '</td>';
                                        
                                    subs += '<td width=10% align=center>';
                                        subs += orderLineItemRenewalRateMap.get(subscription.Order_Line_Item_Number_1__c).renewalDiscRate2 * subscription.Number_of_Copies__c;
                                    subs += '</td>';
                                    // End UD-3701 13-Jan-2015 Added by S.Puli/Alyana - multiply rate by number of copy
                                    subs += '<td width=10% align=center>(  )</td>';
                                subs += '</tr>';
                            }
                            subs += '<tr>';
                                subs += '<tr>&nbsp;</td>';
                            subs += '</tr>';
                        }
                    } else if(publicationType == 'Newspaper') {
                        for(Id recipientId : recipientOrderLineItemListMap.keySet()) {
                            isDeliveredByVendor = false;
                            isDeliveredByMailingAgent = false;
                            subTotal = 0;
                            subs += '<tr>';
                                subs += '<td width=100% align = left colspan = 5>';
                                    subs += recipientContactMap.get(recipientId).Recipient_Number_Show__c + '&nbsp;';
                                    subs += recipientContactMap.get(recipientId).Name;
                                    if(recipientContactMap.get(recipientId).Company_Name__c != null){
                                        subs += '<br>' + recipientContactMap.get(recipientId).Company_Name__c;
                                    }
                                subs += '</td>';
                            subs += '</tr>';
                            for(Id orderLineItemId : recipientOrderLineItemListMap.get(recipientId)){                               
                                subscription = orderLineIdSubListMap.get(orderLineItemId)[0];
                                
                                if(subscription.Delivered_By__c == 'Vendor'){
                                    isDeliveredByVendor = true;
                                }
                                
                                if(subscription.Delivered_By__c == 'Mailing Agent'){
                                    isDeliveredByMailingAgent = true;
                                }
                                subs += '<tr>';
                                    subs += '<td width=40% align=left>';
                                        // START : UD-3338 12/3/2015 Alyana Navarro
                                        subs += SP_RenewalReminderHelper.getSubscriptionTableLabel(publicationType, productMap, packageMap, orderLineIdSubListMap.get(orderLineItemId));                                        
                                        // END : UD-3338 12/3/2015 Alyana Navarro
                                    subs += '</td>';
                                    
                                    subs += '<td width=15% align=center>';
                                        subs += (subscription.Number_of_Copies__c != null ? Integer.valueOf(subscription.Number_of_Copies__c) : 0);
                                    subs += '</td>';
                                    
                                    subs += '<td width=15% align=center>';
                                        subs += String.valueOf(formattedSubEndDate).subString(0,8);
                                    subs += '</td>';
                                    
                                    subs += '<td width=15% align=center>$';                     
                                    //Start UD-3701 13-Jan-2015 Added by S.Puli/Alyana - multiply rate by number of copy
                                        subs += orderLineItemRenewalRateMap.get(subscription.Order_Line_Item_Number_1__c).renewalNewspaperRate*subscription.Number_of_Copies__c;
                                        subTotal += orderLineItemRenewalRateMap.get(subscription.Order_Line_Item_Number_1__c).renewalNewspaperRate*subscription.Number_of_Copies__c;
                                    //End UD-3701 13-Jan-2015 Added by S.Puli/Alyana - multiply rate by number of copy
                                    subs += '</td>';
                                    
                                    subs += '<td width=15% align=center>(  )</td>';
                                subs += '</tr>'; 
                                
                                if(recipientIdDelPostChargeMap.containsKey(orderLineItemId)){
                                    if(recipientIdDelPostChargeMap.get(orderLineItemId).postageFee != null && isDeliveredByMailingAgent){
                                        subs += '<tr>';
                                            subs += '<td width=70% align=left colspan=3>POSTAGE FEE</td>';                              
                                            subs += '<td width=15% align=center>';
                                                subs += '$' + (recipientIdDelPostChargeMap.get(orderLineItemId).postageFee * 12).setScale(2);
                                            subs += '</td>';
                                            subs += '<td width=15% align=center></td>';
                                        subs += '</tr>';
                                        subTotal += recipientIdDelPostChargeMap.get(orderLineItemId).postageFee * 12;
                                    }   
                                }
                            }

                            if(recipientIdDelPostChargeMap.containsKey(recipientId)){
                                if(recipientIdDelPostChargeMap.get(recipientId).deliveryFee != null && isDeliveredByVendor){
                                    subs += '<tr>';
                                        subs += '<td width=70% align=left colspan=3>DELIVERY FEE</td>';
                                        subs += '<td width=15% align=center>';                                  
                                            subs += '$' + (recipientIdDelPostChargeMap.get(recipientId).deliveryFee * 12).setScale(2);                      
                                        subs += '</td>';
                                        subs += '<td width=15% align=center></td>';
                                    subs += '</tr>';
                                    subTotal += recipientIdDelPostChargeMap.get(recipientId).deliveryFee * 12;
                                } 
                            }
                            
                            subs += '<tr>';
                                subs += '<tr>&nbsp;</td>';
                            subs += '</tr>';
                            
                            subs += '<tr>';
                                subs += '<td width=40% align=center></td>';
                                subs += '<td width=60% colspan="4" align=left style="border-bottom: 1px dashed black;"></td>';
                            subs += '</tr>';

                            subs += '<tr>';
                                subs += '<td width=40% align=left></td>';
                                subs += '<td width=15% align=left>SUB TOTAL</td>';
                                subs += '<td width=15% align=left></td>';
                                subs += '<td width=15% align=center>';
                                    subs += subTotal.setScale(2);
                                subs += '*</td>'; // Start/End UD-3706 VPernicia 1/12/16
                                subs += '<td width=15% align=left></td>';
                            subs += '</tr>';

                            subs += '<tr>';
                                subs += '<td width=40% align=center></td>';
                                subs += '<td width=60% colspan="4" align=left style="border-top: 1px dashed black;"></td>';
                            subs += '</tr>';
                            
                            total += subTotal;
                        }
                        
                        subs += '<tr>';
                            subs += '<td width=40% align=center></td>';
                            subs += '<td width=60% colspan="4" align=left style="border-bottom: 1px dashed black;"></td>';
                        subs += '</tr>';

                        subs += '<tr>';
                            subs += '<td width=40% align=left></td>';
                            subs += '<td width=15% align=left>TOTAL</td>';
                            subs += '<td width=15% align=left></td>';
                            subs += '<td width=15% align=center>';
                                subs += total.setScale(2);
                            subs += '</td>';
                            subs += '<td width=15% align=left></td>';
                        subs += '</tr>';

                        subs += '<tr>';
                            subs += '<td width=40% align=center></td>';
                            subs += '<td width=60% colspan="4" align=left style="border-top: 1px dashed black;"></td>';
                        subs += '</tr>';
                    }

                    template = template.replace(oldValue, subs);
                } else if (!subMap.containsKey(fieldName)){
                    template = template.remove(oldValue);
                }
            }
        }

        if (billingAccount.Billing_Contact__r.Email != null) {
            addresses.add(billingAccount.Billing_Contact__r.Email);
        } else if (billingAccount.Billing_Contact__r.Email_Secondary__c != null) {
            addresses.add(billingAccount.Billing_Contact__r.Email_Secondary__c);
        }
                
        mail.setToAddresses(addresses);
        mail.setSubject(subject);
        mail.setHtmlBody(template);
        mail.setSaveAsActivity(true);
      // START : D-4004 12/3/2015 Alyana Navarro
        mail.setTargetObjectId(billingAccount.Billing_Contact__r.id);
        mail.setTreatTargetObjectAsRecipient(false);
      // END : D-4004 12/3/2015 Alyana Navarro
        return mail;
    }   
    
    global void finish(Database.BatchableContext BC) {   
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false);
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
    }
}