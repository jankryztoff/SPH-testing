/*
 * Class Name: BT_AB_INET052DX_STNewsletter
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - INET052DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for INET052DX batch job. Used together with BT_AS_INET052DX_STNewsletter Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco: Created Skeletal Apex Batchable
 *          2015/01/20 Michael Francisco: D-1722 - Modified to Use Contact object instead of Account object as well as add conditions to global query 
 *          2015/01/22 Michael Francisco: D-1895 - Modified variables to use correct Email value
 *          2015/03/06 Michael Francisco: D-2446 - Modified to replace ',' character if any exist in "NAME" as well as invalidate any email addresses that contain it   
 *          2015/08/28 Kevin Evasco: UD-2511 - Changed filter from Recipient Contact to Billing Contact. Only get subscription records with at least 1 billing email (based from the Billing Contact lookup). Get Name and Email from Billing Contact. Ensure unique combination of Name and Email for the datapool records.
 *
 */


global class BT_AB_INET052DX_STNewsletter implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful //START/END 28 August 2015 UD-2511 Kevin Evasco - Added Database.Stateful implementation
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    
    //START D-1722 20/01/2015 Michael Francisco - Modified to global SOQL to use Contact Object
    //global final String query = 'SELECT Zuora__Account__r.Name, Zuora__Account__r.Email__c FROM Zuora__Subscription__c WHERE Product_Code__c like \'ST%\''; //START/END 28 August 2015 UD-2511 Kevin Evasco - Filter product codes starting with ST    
    //Start Code Review 2/19/2015 James
    global final String query = 'SELECT Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Email__c, Contact__r.Email_Secondary__c FROM Zuora__Subscription__c WHERE Main_Package_1__r.Product_Family_Current_Package_Map__c = \'ST\' AND Contact__c != null AND Status_Formula__c = \'Active\' AND (Contact__r.Email != null OR Contact__r.Email__c != null OR Contact__r.Email_Secondary__c != null)' ; //START/END 28 August 2015 UD-2511 Kevin Evasco - Changed filter from Recipient Contact to Billing Contact. Only get subscription records with at least 1 billing email (based from the Billing Contact lookup)
    //End Code Review 2/19/2015 James
    //END D-1722 20/01/2015 Michael Francisco
    
    global final String interfaceId = 'INET052DX';
    Set<String> existingSIOPContactSet = new Set<String>(); //START/END 28 August 2015 UD-2511 Kevin Evasco - Converted list to set to have a unique combination of name and email.
      
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Start Code Review 2/19/2015 James
        List<BA_INT_DATA_POOL__c> resultList = new List<BA_INT_DATA_POOL__c>();
        if(interfaceId <> null){
        resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        }
        delete resultList;
        //End Code Review 2/19/2015 James
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        Set<String> validSIOPContactSet = new Set<String>(); //START/END 28 August 2015 UD-2511 Kevin Evasco - Converted list to set to have a unique combination of name and email.
    
        //START D-1722 20/01/2015 Michael Francisco - Added validation logic for mandatory EMAIL and NAME fields ... 
        for(sObject record : scope)
        {   

            //START D-2446 2015/03/06 Michael Francisco - Replaced isValid to better track failure points ...
            String zValidityCode = 'CODE';
            //END D-2446 2015/03/06 Michael Francisco
            
            Zuora__Subscription__c cn = (Zuora__Subscription__c) record;
            //START 28 August 2015 UD-2511 Kevin Evasco - Get name and email from the Billing Contact not Recipient Contact.
            String name = cn.Contact__r.Name;
            //START D-1895 22/01/2015 Michael Francisco - Changed Email Variable naming convention to address D-1895
            String email_first = cn.Contact__r.Email;
            String email_second = cn.Contact__r.Email__c;
            String email_third = cn.Contact__r.Email_Secondary__c;
            //END 28 August 2015 UD-2511 Kevin Evasco - Get name and email from the Billing Contact not Recipient Contact.
            String email_final = '';
            
            //Check Email (Salesforce out of the box field) ...
            if (email_first != null && email_first.length() >= 1) {
                zValidityCode += '0';
                email_final = email_first;
            } else {
                //Check custom Email__c ... 
                if (email_second != null && email_second.length() >= 1) {
                    zValidityCode += '0';
                    email_final = email_second;
                } else {
                    //Check custom Email_Secondary__c ...
                    if (email_third != null && email_third.length() >= 1) {
                        zValidityCode += '0';
                        email_final = email_third;
                    } else {
                        // If no valid email found set boolean to false ...
                        zValidityCode += '1';
                    }
                }
            }
            //END D-1895 22/01/2015 Michael Francisco

            // Only check NAME if a valid email was found ...
            if (name != null && name.length() >= 1) {               
                zValidityCode += '0';
            } else {
                zValidityCode += '1';
            }           
            
            //START D-2446 2015/03/06 Michael Francisco - added validation code and string replace code ...
            if (email_final.indexOf(',') >= 0) {
                zValidityCode += '1';
            } else { 
                zValidityCode += '0';
            }
            
            // Store Set of valid Contacts with both NAME and EMAIL data ...
            if (zValidityCode.indexOf('1') < 0) {
                String valid_data = (name+'|'+email_final).trim();              
                //START 28 August 2015 UD-2511 Kevin Evasco - Get name and email from the Billing Contact not Recipient Contact.
                if(existingSIOPContactSet.contains(valid_data) == false) {
                    validSIOPContactSet.add(valid_data);
                    existingSIOPContactSet.add(valid_data);
                }               
                //END 28 August 2015 UD-2511 Kevin Evasco - Get name and email from the Billing Contact not Recipient Contact.
            } else {
                System.debug('EXPORT-FAILED REASON-CODE:['+zValidityCode+'], DATA:['+name+'|'+email_final+']');
            }
            //END D-2446 2015/03/06 Michael Francisco
        }
        
        // Export Valid Data 
        for(String data : validSIOPContactSet)
        {
            String exportData = '';                 
                
            List<String> result = data.split('[|]');
            
            if (result.size() > 1) {
                String name = result.get(0); //Name
                String email = result.get(1); //Email 
                
                //START D-2446 2015/03/06 Michael Francisco - called new StringUtility method quoteReplaceStr() ...         
                if (name.length() > 0 && email.length() > 0) {
                    exportData +=  StringUtility.quoteReplaceStr(name) + ','; 
                    exportData +=  StringUtility.quoteReplaceStr(email);                                                                                            
                }
                //END D-2446 2015/03/06 Michael Francisco
            }
            
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;          
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            
            datapoolList.add(datapoolRecord);   
        }       
        //END D-1722 20/01/2015 Michael Francisco - 
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_INET052DX_STNewsletter insert operation failed.');
        }
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
       //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID(interfaceId);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);

    }
}