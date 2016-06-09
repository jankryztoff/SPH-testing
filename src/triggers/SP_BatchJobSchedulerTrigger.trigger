/*
     * Trigger Name: SP_BatchJobSchedulerTrigger
     * Author: Kevin Evasco
     * Date: 11/15/2014
     * Project/Requirement: SPH Scheduled Processes - Batch Process Control
     * Description: This trigger executes the batch jobs given the Batch Code of the created Batch Run Request.
     * History: 11/15/2014 Kevin Evasco Created Apex Trigger
     * History: 11/23/2014 Kevin Evasco Updated to include gift letters
     * History: 11/27/2014 D-0894 Kevin Evasco Updated to include Session ID
     * History: 12/02/2014 D-0906, D-0907, D-0908, D-0909, D-0849, D-0900, D-0901, D-0902, D-0903, D-0904, D-0910 Kevin Evasco Updated to include Session ID
     * History: 12/05/2014 D-0797, D-0849 Kevin Evasco Updated to include Session ID from the Record Session ID field. Updated Parameter for these Batch Codes: SP019, SP020, SP021, SP022, SP023, SP024, SP025, SP026, SP027, SP028, SP029, P030, SP031, SP032, SP033
     * History: 10/12/2015 Added by Kristine Balaoing - added parameters for batch recovery 
     * History: 19/10/2015 D-3767 Added by Krithika D-0797 HouseKeeping Jobs
     */

    trigger SP_BatchJobSchedulerTrigger on BATCH_JOB_SCHEDULER__c (before insert) {

        List<BATCH_JOB_SCHEDULER__c> batchRunRequestList = trigger.new;
        
        Set<String> inputBatchSet = new Set<String>();
        Set<String> activeBatchSet = new Set<String>();
        Set<String> newlyStartBatchSet = new Set<String>();    
        
        Map<String, Batch_Control_Settings__c> batchControlSettingsMap; //START/END 04/17/2015 D-2771 Kevin Evasco - Configurable Batch Size
        
        //START PD-0147 13May2016 Added By C. Lin - Change Date.Today() in the parameter to Date from Custom Settings
        Manual_Batch_Run_Dates__c BRDate = Manual_Batch_Run_Dates__c.getInstance('ManualBatchRun');
        Date dateOfBatchRun;
        if(BRDate != null){
            dateOfBatchRun = BRDate.Batch_Run_Date__c;
        }
        //END PD-0147 13May2016 Added By C. Lin
        
        for(BATCH_JOB_SCHEDULER__c batchRunRequest: batchRunRequestList)        
        {
            inputBatchSet.add(batchRunRequest.Batch_Code__c);
        }
        List<BATCH_JOB_SCHEDULER__c> brrList;
        //START Code Review Jean Cariño 2/18/2015 : check inputBatchSet if null
        if (inputBatchSet.size() > 0){
        brrList = [SELECT Batch_Code__c FROM BATCH_JOB_SCHEDULER__c WHERE Batch_Code__c IN :inputBatchSet AND (Status__c = 'STARTED')];
        }
        //END Code Review Jean Cariño 2/18/2015 : check inputBatchSet if null
        /*
            Loop through all Batch Run Request object and put to Map those records that are still active.
        */
        for (BATCH_JOB_SCHEDULER__c brrRecord: brrList)
        {
            activeBatchSet.add(brrRecord.Batch_Code__c);
        }
        
      batchControlSettingsMap = BatchJobHelper.getBatchControlSettingsMap(inputBatchSet); //START/END 04/17/2015 D-2771 Kevin Evasco - Configurable Batch Size
        
        for(BATCH_JOB_SCHEDULER__c batchRunRequest: batchRunRequestList)
        {
            String batchCode = batchRunRequest.Batch_Code__c;
            // START PD-0104 - Raviteja - 09May2016 - implementaion for Manual Batch run date  
            Date batchRundate = batchRunRequest.Batch_Run_Date__c;
            System.debug(' batchRundate: '+batchRundate);         
            
            Manual_Batch_Run_Dates__c mBRD = Manual_Batch_Run_Dates__c.getValues('ManualBatchRun');                
            if(mBRD != Null && mBRD.isManualrun__c == True){
                    batchRundate = mBRD.Batch_Run_Date__c;   
                    batchRunRequest.Batch_Run_Date__c = batchRundate;           
                }       
            // END PD-0104 - Raviteja - 09May2016 - implementaion for Manual Batch run date 
        Integer batchSize = BatchJobHelper.getBatchSize(batchControlSettingsMap,batchCode); //START/END 04/17/2015 D-2771 Kevin Evasco - Configurable Batch Size
        //START 04/14/2015 D-2740 Kevin Evasco - Get the number of parallel jobs from custom settings
            Integer numberOfParallelJobs = 5;
        Integer letterPrintRequestCount;
        if(batchRunRequest.Letter_Print_Request_Count__c != null){
          letterPrintRequestCount = Integer.valueOf(batchRunRequest.Letter_Print_Request_Count__c);
        }
        if(batchRunRequest.Number_of_Parallel_Jobs__c != null) {
          numberOfParallelJobs = Integer.valueOf(batchRunRequest.Number_of_Parallel_Jobs__c);
        }    
        //END 04/14/2015 D-2740 Kevin Evasco - Get the number of parallel jobs from custom settings
            Integer numberOfDaysBeforeExpiration = Integer.valueOf(batchRunRequest.LP_Days_Before_Expiration__c);
            
            if (activeBatchSet.contains(batchCode) && batchRunRequest.Allow_Parallel_Jobs__c == false)
            {
                batchRunRequest.addError('Cannot execute this batch run because it is currently active. ');
            }
            else if (newlyStartBatchSet.contains(batchCode) && batchRunRequest.Allow_Parallel_Jobs__c == false)
            {
                batchRunRequest.addError('Cannot execute this batch run because it is currently active. This batch has been executed by the same request.');
            }
            else 
            {
                newlyStartBatchSet.add(batchCode);
                
                if(batchCode == 'SP001')
                {
            //START: D-3938 11/23/2015 Added by Kristine Balaoing - added limit to batch execution      
                    SP_ActivateServiceFlagBatch batchJob = new SP_ActivateServiceFlagBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob, 90);
                }
            //END: D-3938 11/23/2015 Added by Kristine Balaoing
          //START D-2452 Wenjun 18/03/15 :VDC Changes
                else if(batchCode == 'SP002')
                {
                    SP_VSSManualCreditBatch batchJob = new SP_VSSManualCreditBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }              
                else if(batchCode == 'SP003')
                {
                    SP_VSSDebitForComplaint batchJob = new SP_VSSDebitForComplaint();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
          //END D-2452 Wenjun 18/03/15
                else if(batchCode == 'SP004')
                {
                    SP_CreateDelChargeUsageBatch batchJob = new SP_CreateDelChargeUsageBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
                else if(batchCode == 'SP005')
                {
                    SP_DeliveryChargesBatch batchJob = new SP_DeliveryChargesBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
                else if(batchCode == 'SP006')
                {   
                //Start D-4645 Dags to retrofit the hotfix in Gold QA 07Apr2016
                    //SP_GracePeriodSubscriptionBatch batchJob = new SP_GracePeriodSubscriptionBatch();
                    //batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                    System.debug('SP006 job not scheduled');
                // End D-4645 Dags hotfix - 07Apr2016     
                }      
                // START 30 November 2015 D-4002 Kevin Evasco - Commented out for D-3919. SP_IncreaseDecreaseQuantityBatch no longer valid.
                //else if(batchCode == 'SP007')
                //{
                //    SP_IncreaseDecreaseQuantityBatch batchJob = new SP_IncreaseDecreaseQuantityBatch();
                //    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                //}  
                // END 30 November 2015 D-4002 Kevin Evasco - Commented out for D-3919. SP_IncreaseDecreaseQuantityBatch no longer valid.
                else if(batchCode == 'SP008')
                {
                    SP_loadMonthlyUsageDataBatch batchJob = new SP_loadMonthlyUsageDataBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
                else if(batchCode == 'SP009')
                {
                    SP_MidMonthStartProrationBatch batchJob = new SP_MidMonthStartProrationBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
                else if(batchCode == 'SP010')
                {
                    SP_MidMonthTempStopBatch batchJob = new SP_MidMonthTempStopBatch();
            //Start D-1875 01/27/2015 JohnD add limit of 100 to avoid cpu run time
            batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob, 100);
            // End D-1875 01/27/2015 JohnD
                }        
                else if(batchCode == 'SP011')
                {
                    SP_MonthlyDeliveryFeeBatch batchJob = new SP_MonthlyDeliveryFeeBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
                else if(batchCode == 'SP012')
                {
                    SP_PopConsolidationBatch batchJob = new SP_PopConsolidationBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob, 2000); //START END D-2984 Wenjun 12/05/15 UAT Hotfix - Increase Batch Size
                }        
                else if(batchCode == 'SP013')
                {
                    SP_RenewalOfSubscriptionBatchProcess batchJob = new SP_RenewalOfSubscriptionBatchProcess();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
                else if(batchCode == 'SP014')
                {
                    SP_SendEmailNotifForFailedCCBatch batchJob = new SP_SendEmailNotifForFailedCCBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
                else if(batchCode == 'SP015')
                {
                    SP_SendEmailNotifForSubsRenewalsBatch batchJob = new SP_SendEmailNotifForSubsRenewalsBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        

                else if(batchCode == 'SP016')
                {
                    SP_VendorHandlingFeeBatch batchJob = new SP_VendorHandlingFeeBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                }        
                else if(batchCode == 'SP017')
                {
                    // START 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
                    SP_VendorNotificationsBatch batchJob = new SP_VendorNotificationsBatch(); // START-END : UD-0982 5/13/2015 Alyana Navarro - Change in constructor
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob, 100);
                    // END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
                }        
                else if(batchCode == 'SP018')
                {                
                    String letterType = SP_GenerateLetterPrintBatch.acknowledgmentLetter;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, UserInfo.getSessionId());           
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END PD-0139 05172016 Gdelrosario - change the batch size to configurable
                }
                //START: D-3663 10/13/2015 Added by Kristine Balaoing - added for Batch Recovery
                else if(batchCode == 'SP019')
                {
                    String letterType = SP_GenerateLetterPrintBatch.creditCardFailureNotification;
                    SP_CreditCardFailureRequestBatch batchableInstance = new SP_CreditCardFailureRequestBatch(letterType, numberOfParallelJobs, UserInfo.getSessionId(), null, null);   
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,1000);
                }
                //END: D-3663 Added by Kristine Balaoing
                else if(batchCode == 'SP020')
                {
                    // START - D-2828 5/7/2015 Alyana Navarro
                    String letterType = SP_GenerateLetterPrintBatch.invoiceLetter;
                    SP_InvoiceRequestBatch batchableInstance = new SP_InvoiceRequestBatch(letterType, numberOfParallelJobs, UserInfo.getSessionId(), true);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,1000);
                    // END - D-2828 5/7/2015 Alyana Navarro
                }        
                else if(batchCode == 'SP021')
                {               
                    String letterType = SP_GenerateLetterPrintBatch.packingLabelLetter ;
                    SP_PackingLabelAttachmentBatch batchableInstance = new SP_PackingLabelAttachmentBatch(letterType, numberOfParallelJobs, UserInfo.getSessionId());   
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,1000);
                }
                //START PD-0147 13May2016 Added By C. Lin - Change Date.Today() in the parameter to dateOfBatchRun(Date from Custom Settings)
                //START: D-3663 10/12/2015 Added by Kristine Balaoing - added parameters for batch recovery
                else if(batchCode == 'SP022')
                {
                    String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
                    SP_RenewalReminderRequestBatch batchableInstance = new SP_RenewalReminderRequestBatch(letterType,numberOfDaysBeforeExpiration, dateOfBatchRun, numberOfParallelJobs, UserInfo.getSessionId(),'SP022');   
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 05102016 PD-0117 Gdelrosario - Configurable Batch Size
                }        
                else if(batchCode == 'SP023')
                {
                    String letterType = SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine;
                    SP_RenewalReminderRequestBatch batchableInstance = new SP_RenewalReminderRequestBatch(letterType,numberOfDaysBeforeExpiration, dateOfBatchRun, numberOfParallelJobs, UserInfo.getSessionId(), 'SP023');   
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 05102016/2015 PD-0117 Gdelrosario - Configurable Batch Size
                }        
                else if(batchCode == 'SP024')
                {
                    String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
                    SP_RenewalReminderRequestBatch batchableInstance = new SP_RenewalReminderRequestBatch(letterType,numberOfDaysBeforeExpiration, dateOfBatchRun, numberOfParallelJobs, UserInfo.getSessionId(), 'SP024');   
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 05102016 PD-0117 Gdelrosario - Configurable Batch Size
                }        
                else if(batchCode == 'SP025')
                {
                    String letterType = SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper;
                    SP_RenewalReminderRequestBatch batchableInstance = new SP_RenewalReminderRequestBatch(letterType,numberOfDaysBeforeExpiration, dateOfBatchRun, numberOfParallelJobs, UserInfo.getSessionId(), 'SP025');   
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 05102016 PD-0117 Gdelrosario - Configurable Batch Size
                }
                //END: D-3663 10/12/2015 Added by Kristine Balaoing         
                //END PD-0147 13May2016 Added By C. Lin
                else if(batchCode == 'SP026')
                {
                                 
                    String letterType = SP_GenerateLetterPrintBatch.creditNotes;
            //START UD-2847 22-Sept-2015 Added By S.Puli
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c, letterPrintRequestCount);
            //END UD-2847 22-Sept-2015 Added By S.Puli
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                }       
                else if(batchCode == 'SP027')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.creditCardFailureNotification;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                }     
                else if(batchCode == 'SP028')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.invoiceLetter;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c, letterPrintRequestCount); //START/END 04/14/2015 D-2740 Kevin Evasco - Pass Letter Print Request Count
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 04/17/2015 D-2771 Kevin Evasco - Configurable Batch Size
                } 
                else if(batchCode == 'SP029')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.packingLabelLetter;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                } 
                else if(batchCode == 'SP030')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 05102016 PD-0117 Gdelrosario - Configurable Batch Size
                } 
                else if(batchCode == 'SP031')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 05102016 PD-0117 Gdelrosario - Configurable Batch Size
                } 
                else if(batchCode == 'SP032')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 05102016 PD-0117 Gdelrosario - Configurable Batch Size
                } 
                else if(batchCode == 'SP033')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize); //START/END 05102016 PD-0117 Gdelrosario - Configurable Batch Size
                } 
                else if(batchCode == 'SP034')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.giftLetter;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, UserInfo.getSessionId());
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                } 
                //START:D-2218 2/13/15 Added by Manolo Valeña - Removed as present gift is no longer needed.
                /*else if(batchCode == 'SP035')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.presentGift;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, UserInfo.getSessionId());
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                }*/ 
                //END:D-2218 2/13/15 Added by Manolo Valeña
                //START:D-3432 8/26/15 Added by Manolo Valena - Asia1Subscription Deactivation batch job.
                else if(batchCode == 'SP035')
                {
                    Asia1SubscriptionDeactivationBatchable batchableInstance = new Asia1SubscriptionDeactivationBatchable();
                    //START:D-3612 9/29/15 Added by Manolo Valena - Added size of 50 per batch.
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance, 50);
                    //END:D-3612 9/29/15 Added by Manolo Valena
                }
                //END:D-3432 8/26/15 Added by Manolo Valena
                else if(batchCode == 'SP036')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.subscriptionLetter;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, UserInfo.getSessionId());
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                } 
                else if(batchCode == 'SP037')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.giftRenewalLetter;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, UserInfo.getSessionId());
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                } 
                else if(batchCode == 'SP038')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.giftRedemptionLetter;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, UserInfo.getSessionId());
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                } 
                /* Batch job added by Krithika.D as part of Postage Charges */
                else if(batchCode == 'SP039')
                {                             
                    BatchPostageMonthlyUsage batchJob = new BatchPostageMonthlyUsage();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);  
                }
          //START:D-2218 2/13/15 Added by Manolo Valeña - Added new conditions for the new letter templates that will be added soon.
                //START : 20/03/2015 Added by Jean Cariño for MD42
                else if(batchCode == 'SP040')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.giftPremiumChina;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, UserInfo.getSessionId());
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                } 
                else if(batchCode == 'SP041')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.giftPremiumEnglish;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, UserInfo.getSessionId());
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                } 
                //END
                //END:D-2218 2/13/15 Added by Manolo Valeña
                //START:D-2187 2/17/15 Added by Karl Tan - Added new conditions for the Renewal Batch.
                else if(batchCode == 'SP042')
                {                             
                    RenewalOfSub_RetentionOutboundBatch batchJob = new RenewalOfSub_RetentionOutboundBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);               
                }
                //START D-3235 14-July-2015 Added by Raviteja - Comment Out SP043 as it is Merge SP043 with SP057. Run Batch 
                /*
                else if(batchCode == 'SP043')
                {                             
                    SP_CancelSubForNormalExpiration batchJob = new SP_CancelSubForNormalExpiration();
                //START:  D-2658 4/1/15 Added by Karl Tan - Added Cancel Subscription for Normal Expiration.               
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob, 50); 
                //END:    D-2658 4/1/15 Added by Karl Tan - Added Cancel Subscription for Normal Expiration.
                                  
                }  
                */   
                //End D-3235 14-July-2015 Added by Raviteja             
                //END:D-2187 2/17/15 Added by Karl Tan  
                //START : UD-2361 31-Aug-2015 Added by S.Puli  - added letter print request creation for credit note
                
                else if(batchCode == 'SP043')
                {                             
                    SP_CreditNoteRequestBatch batchJob = new SP_CreditNoteRequestBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob, 100);  
                } 
                
                //END : UD-2361 31-Aug-2015 Added by S.Puli 
                //START D-2212 03/05/2015 Marvin Gatchalian - email notification for Vendor subscriber
                else if(batchCode == 'SP044')
                {
                    // START 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
                    SP_VendorSubscriptionNotificationsBatch batchJob = new SP_VendorSubscriptionNotificationsBatch(); //START/END 11 November 2015 D-3897 Kevin Evasco  - No need to pass Session Id
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob, 100);
                    // END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention

                }  
                //END D-2212  03/05/2015 Marvin Gatchalian - email notification for Vendor subscriber
                //START D-3235 14-July-2015 Added by Raviteja - Comment Out SP045 as it is duplicated with SP055 
                /*
                //START MD-52 03/20/2015 George Del Rosario - Batch for CreaditBalance to zuora
                else if(batchCode == 'SP045')
                {
                    SP_BatchCreateCreditBalance batchJob = new SP_BatchCreateCreditBalance();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);

                }
                //END D-2212  MD-52 03/20/2015 George Del Rosario - Batch for CreaditBalance to zuora
                */
                //End D-3235 14-July-2015 Added by Raviteja
                // START : UD-2634 9/10/2015 Alyana Navarro
                else if(batchCode == 'SP045'){
                    String letterType = SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION;
                    SP_PaypalFailureRequestBatch batchableInstance = new SP_PaypalFailureRequestBatch(letterType, numberOfParallelJobs, UserInfo.getSessionId());   
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,1000);
                }
                // END : UD-2634 9/10/2015 Alyana Navarro
                //START MD-17 03/20/2015 J.Sarion/J.Abolac - Batch Job for Negative Invoice 
                //START: D-4102 12-15-2015 Added by Kristine Balaoing - added to address cannot create more than 50 Zobjects at a time
                else if(batchCode == 'SP046')
                {
                    SP_CreditBalanceAdjustmentLessThanZero batchJob = new SP_CreditBalanceAdjustmentLessThanZero();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob, 50);

                }
                //END: D-4102 12-15-2015 Added by Kristine Balaoing
                //END MD-17 03/20/2015 J.Sarion/J.Abolac - Batch Job for Negative Invoice 
                //START UD-0467 03/27/2015 James - Batch Job for Expired Subscription 
                else if(batchCode == 'SP047')
                {
                    //START UD-0467 03/31/2015 James - Commenting out updates
                    //SP_SubscriptionExpirationBatch batchJob = new SP_SubscriptionExpirationBatch();
                    //batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchJob);
                    //Removing this batch since there is already an existing batch job that changes the subscription status (SP_CancelSubForNormalExpiration (D-2658))
                    //END UD-0467 03/31/2015 James - Commenting out updates

                    // START : UD-2634 9/10/2015 Alyana Navarro
                    String letterType = SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType, numberOfParallelJobs, batchRunRequest.Session_ID__c);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,100);
                    // END : UD-2634 9/10/2015 Alyana Navarro
                }
                //END UD-0467 03/27/2015 James - Batch Job for Expired Subscription
                //START D-3326 8/3/2015 Added By C. Lin
                else if(batchCode == 'SP048'){
                    SP_VendorAllocationBatch batchjob =  new SP_VendorAllocationBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executebatch(batchjob);
                }
                //END D-3326 8/3/2015 Added By C. Lin
               //START D-2685 4/6/2015 KRITHIKA D
               else if(batchCode == 'SP049')
               {
                     String query = 'Select ID from ba_int_data_pool__c';
                     DataPurgeBatch batch = new DataPurgeBatch(query);
                     batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000); //START/END 11 November 2015 D-3897 Kevin Evasco  - Krithika's hotfix for integration house keeping
               }
               else if(batchCode == 'SP050' )
               {
                    BatchAddressAssignmentEffectiveDate batchjob =  new BatchAddressAssignmentEffectiveDate();//KRITHIKA DHARMARAJAN 5/19/2015
                    batchRunRequest.SFDC_Job_id__c = Database.executebatch(batchjob);
               }
               //END D-2685 4/6/2015 KRITHIKA D 
               // START : CR-PayPal(D-2864) 4/14/2015 Alyana Navarro
               else if(batchCode == 'SP051' )
               {                
                     SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
                     batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch);
               }
               // END : CR-PayPal 4/14/2015 Alyana Navarro
               // START : UD-907 4/16/2015 Alyana Navarro
               else if(batchCode == 'SP052' )
               {                
                     SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
                     batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch);
               }
               // END : UD-907 4/16/2015 Alyana Navarro
         //START D-2777 Wenjun 16/04/15 : Set Delivery Subscription Active Flag
               else if(batchCode == 'SP053' )
               {                
                     SP_DailySetSubActiveFlag batch = new SP_DailySetSubActiveFlag(Date.today());
                     batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch);
               }
               //END D-2777 Wenjun 16/04/15
               // START : UD-683 4/17/2015 Jean Cariño
               else if(batchCode == 'SP054'){
                    AcknowledgmentLetterEmail batchAckEmail = new AcknowledgmentLetterEmail();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchAckEmail);
               }
               // END : UD-683 4/17/2015 Jean Cariño           
               //START 17-July-2015 D-3255 Added By S.Puli - Job SP055
               else if(batchCode == 'SP055'){
                    SP_BatchCreateCreditBalance batchInstance = new SP_BatchCreateCreditBalance();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchInstance, 50); //START END D-4505 21Mar2016 Added By C. Lin - Limit to process only 50 records per batch
               }
               //END 17-July-2015 D-3255 Added By S.Puli - Job SP055
               //START D-3235 14-July-2015 Added by Raviteja           
               else if(batchCode == 'SP056'){
                    STP050DXSendQuotesToZuoraBatch batchInstance = new STP050DXSendQuotesToZuoraBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchInstance,1);
               }  
               else if(batchCode == 'SP057'){
                    SP_CancelSubscriptionInZuora batchInstance = new SP_CancelSubscriptionInZuora();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchInstance,1);
               }
               else if(batchCode == 'SP058'){
                    SP_LoadPublicationRates batchInstance = new SP_LoadPublicationRates();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchInstance);
               }
               //End D-3235 14-July-2015 Added by Raviteja
                //START UD-3632 15Jan2016 Added By C. Lin - New batch job for Temp Stop Reset YTD
                else if(batchCode == 'SP059'){
                    SP_TempStopResetCounter batchInstance = new SP_TempStopResetCounter();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchInstance);
                }
                //END UD-3632 15Jan2016 Added By C. Lin
                //START 25 February 2016 NCR015-5 Kevin Evasco - Packing Label CR
                else if(batchCode == 'SP060'){
                    // START PD-0104 - Raviteja - 09May2016 - Solution for unable to pick the day's data, if run past mid night                   
                   //SP_PackingLabelBatch batchInstance = new SP_PackingLabelBatch();
                   SP_PackingLabelBatch batchInstance = new SP_PackingLabelBatch(batchRundate);               
                   // END PD-0104 - Raviteja - 09May2016 - Solution for unable to pick the day's data, if run past mid night  
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchInstance);
                }
                //Start UD-3253 29-Feb-2016 Added By S.Puli
                else if(batchCode == 'SP061'){
                    SP_CreateCreditNoteBatch batchInstance = new SP_CreateCreditNoteBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchInstance);
                }
                //End UD-3253 29-Feb-2016 Added By S.Puli
                //END 25 February 2016 NCR015-5 Kevin Evasco - Packing Label CR
                //Start UD-3207 26-Mar-2016 Added by S.Puli
                 else if(batchCode == 'SP062'){
                String letterType = SP_GenerateLetterPrintBatch.dailyInvLetter;
                SP_DailyInvoiceRequestBatch batchableInstance = new SP_DailyInvoiceRequestBatch(letterType, numberOfParallelJobs, UserInfo.getSessionId(), true);
                batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,1000);
                }
                else if(batchCode == 'SP063')
                {                             
                    String letterType = SP_GenerateLetterPrintBatch.dailyInvLetter;
                    SP_GenerateLetterPrintBatch batchableInstance = new SP_GenerateLetterPrintBatch(letterType,numberOfParallelJobs, batchRunRequest.Session_ID__c, letterPrintRequestCount);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance,batchSize);
                }
                else if(batchCode == 'SP064')
                {                             
                    SP_CreateDailyInvoiceBatch batchableInstance = new SP_CreateDailyInvoiceBatch();
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batchableInstance);
                }
                //End UD-3207 26-Mar-2016 Added by S.Puli
                //Start D-3767 19-Oct-2015 Added by Krithika D-0797 HouseKeeping Jobs
                else if(batchCode == 'HK000'){
                    String query = 'Select ID from ba_int_data_pool__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }  
               else if(batchCode == 'HK001'){
                    String query = 'Select Id FROM Vendor_POP_Batch__c WHERE Publication_Issue_Date__c < last_n_days:4 AND Subscription_Name__c != null';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK002'){
                   String query = 'Select Id FROM BT_CO_CMIS_POP_ImportPublicationInfo__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
                else if(batchCode == 'HK003'){
                    String query = 'Select Id FROM BT_CO_CMIS_POP_NumberOfVendorInserts__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }  
               else if(batchCode == 'HK004'){
                    String query = 'Select Id FROM BT_CO_MIRO_SubscriptionIssueFile__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK005'){
                    String query = 'Select Id FROM BT_CO_VBS_CreditDebit__c where createdDate < last_n_months:1';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK006'){
                    String query = 'Select Id FROM BT_CO_VSS_CreditDebit__c where createdDate < last_n_months:1';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK007'){
                    String query = 'Select Id FROM BT_CO_CMIS_POP_ImportPublicationIssue__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK008'){
                    String query = 'Select Id FROM BT_CO_CMIS_POP_ImportPublicationPrice__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK009'){
                    String query = 'Select Id FROM BT_CO_CMIS_POP_ImportNonPublicationDate__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK010'){
                    String query = 'Select Id FROM BT_CO_CMIS_POP_NumberOfVendorInserts__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK011'){
                    String query = 'Select Id FROM BT_CO_CMISPOP_ImportVendorProfile__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK012'){
                    String query = 'Select Id FROM BT_CO_CMIS_POP_ImportNextIssueDateInfo__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK013'){
                    String query = 'Select Id FROM BT_CO_CMIS_POP_ImportPublicationInfo__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK014'){
                    String query = 'Select Id FROM BT_CO_CMIS_POP_ImportPublicHolidayInfo__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK015'){
                    String query = 'Select Id FROM BT_CO_CMISPOP_ImportVendorStaff__c';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               else if(batchCode == 'HK016'){                
                    String query = 'SELECT Id FROM Letter_Print_Request__c WHERE CreatedDate != LAST_N_DAYS:7';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               //START 11 November 2015 D-3897 Kevin Evasco  - HK017 for Batch Job Scheduler / Batch Run Request clean up
               else if(batchCode == 'HK017'){  
                    // Start D-4645 Dags Raviteja - hotfix - 07Apr2016 - SFDC_Job_id__c should be Unique text we cannot hardcode it,               
                    //batchRunRequest.SFDC_Job_id__c = 'N/A';
                    batchRunRequest.SFDC_Job_id__c = String.ValueOf(DateTime.now());
                    // End  D-4645 Dags Raviteja - hotfix - 07Apr2016 -
                    batchRunRequest.End_Time__c = DateTime.now();
                    Boolean isCleanupSuccess = BatchJobHelper.runJobCleaners(batchRunRequest);
                    if(isCleanupSuccess)            
                        batchRunRequest.Status__c = 'SUCCESS';
                    else
                        batchRunRequest.Status__c = 'FAILED';
               }
               //END 11 November 2015 D-3897 Kevin Evasco  - HK017 for Batch Job Scheduler / Batch Run Request clean up
               //START 30 November 2015 D-4002 Kevin Evasco - New HK Job for Packing Labels
               else if(batchCode == 'HK018'){                
                    String query = 'SELECT Id FROM Packing_Label_Batch__c WHERE LastModifiedDate != LAST_N_DAYS:3 LIMIT 2000000';
                    DataPurgeBatch batch = new DataPurgeBatch(query);
                    batchRunRequest.SFDC_Job_id__c = Database.executeBatch(batch, 2000);
               }
               //END 30 November 2015 D-4002 Kevin Evasco - New HK Job for Packing Labels
               //End D-3767 19-Oct-2015 Added by Krithika D-0797 HouseKeeping Jobs
                /************************************************************************************************************
                //START D-3326 8/3/2015 Added By C. Lin - Used SP048 for COV
                //START:D-3432 8/26/15 Added by Manolo Valena - Used SP035 for deactivation of Asia1 Subscriptions for stopped Subscriptions.
               //START : UD-2361 31-Aug-2015 Added by S.Puli - Used SP043 for creation of letter print request for credit notes
               // START-END : UD-2634 9/10/2015 Alyana Navarro - Used SP045 for creation of letter print request for PayPal and SP047 for generateletterprintbatch of PayPal
               Note: Please use empty batch number before creating new number: SP045 / SP047
               //END : UD-2361 31-Aug-2015 Added by S.Puli
               //END:D-3432 8/26/15 Added by Manolo Valena
                //END D-3326 8/3/2015 Added By C. Lin
                *************************************************************************************************************/  
               }

        }
    }