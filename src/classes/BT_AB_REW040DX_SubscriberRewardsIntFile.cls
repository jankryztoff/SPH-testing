/*
 * Class Name: BT_AB_REW040DX_SubscriberRewardsIntFile
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - REW040DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for REW040DX batch job. Used together with BT_AS_REW040DX_SubscriberRewardsIntFile Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco         -   Created Skeletal Apex Batchable
 *          2014/09/18 Renino Niefes        -   Filled in the codes
 *          2015/01/22 Renino Niefes        -   D-1762 Added mapping for Online User ID. get it from Asia 1 and use the contact ID as link
 *          2015/02/18 Rom Edison Reyes     -   Modified to address Code Review (100k Limit Findings)
 *          2015/03/04 Michael Francisco    -   D-2439 Modified SOQL query to address SOQL timeout governing limit
 *          2015/03/23 Michael Francisco    -   D-2585 Modified the code for the following items:
 *                                                  1) Replace use of SKU with ProductCode
 *                                                  2) Reference the correct Asia1 object (Asia1_Subscription__c)
 *                                                  3) Add rudimentary validation rules based loosely on the FDS
 *          2015/03/24 Nitin Khanna         -   D-2585 - Rewrote to address 50k limit issue encountered in UAT
 *          2015/03/26 Michael Francisco    -   D-2585 - Added validation for comma & special character processing
 *          2015/04/29 Michael Francisco    -   D-2841 - Modified to use the following: 
 *                                                  1) Asia1 Online UserID derived from Subscriber_Contact__r.ID
 *                                                  2) CRSM Account ID = Zuora__Subscription__r.Zuora__Account__r.Account_Auto_Number__c
 *                                                  3) Added ORDER BY Zuora__Subscription__r.Zuora__Account__r.AccountNumber sort condition
 *                                                  4) Used List / Sort approach to retain sorting 
 *                                                  5) Updated "zData" logic
 *                                                  6) Updated comments
 *          2015/05/07 Michael Francisco    -   Code Review: Updated to address review points raised during code review
 *          2015/11/10 Renino Niefes        -   D-3911: change the source of phone number from Account to Contact
 *          2015/11/11 Renino Niefes        -   D-3911: revised the mapping  based on available fields in UI
 */

global class BT_AB_REW040DX_SubscriberRewardsIntFile implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // START 2015/04/29 Michael Francisco - D-2841 Modified to use "Zuora__Subscription__r.Subscriber_Contact__r.ID"
    
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements

    global final String interfaceId = 'REW040DX';
    
    /* @description 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;         
        
        List<zqu__ZProduct__c> productCodeList = [SELECT ProductCode__c FROM zqu__ZProduct__c WHERE ProductSubType__c = 'Newspaper' AND zqu__Deleted__c=FALSE];
        String recordTypeID = ConstantsSLB.getKeyId('Account_Direct Individual');
        Set<String> productCodeSet = new Set<String>();
        for(zqu__ZProduct__c pcode : productCodeList){
            String pcode_value = pcode.ProductCode__c;
            if (pcode_value != null && pcode_value.length() > 0) {
                productCodeSet.add(pcode_value);               
            }
        }
    
        String query = ' SELECT ';
               query += '    Zuora__Account__r.AccountNumber, ';    
               query += '    Zuora__Account__r.Account_Auto_Number__c, ';   
               query += '    Subscriber_Contact__r.ID, ';
               query += '    Zuora__Account__r.Date_Of_Birth__c, ';
               query += '    Zuora__Account__r.Name, ';
               query += '    Zuora__Account__r.NRIC__c, ';
               query += '    Zuora__Account__r.Phone, ';
               query += '    Zuora__Account__r.Email__c, ';     
               query += '    Zuora__SubscriptionEndDate__c, ';  
               query += '    ID, '; 
               query += '    Product_Code__c, ';    
			   //START 2015-11-11 Renz D-3911
			   query += '    Subscriber_Contact__r.HomePhone__c, ';
			   query += '    Subscriber_Contact__r.Mobile_Number__c, ';
			   query += '    Subscriber_Contact__r.Mobile_Number_2__c, ';
			   query += '    Subscriber_Contact__r.Fax__c, ';
			   query += '    Subscriber_Contact__r.Office_Number__c, ';
			   //END 2015-11-11 Renz D-3911
               query += '    Subscriber_Contact__r.Address__r.Postal_Code__r.Name ';    
               query += ' FROM ';
               query += '    Zuora__Subscription__c ';
               query += ' WHERE ';
               query += '    Zuora__Account__r.recordType.developerName=\'Direct_Individual\' ';
               query += '    AND Zuora__Status__c=\'Active\' ';
               query += '    AND Subscription_Type__c=\'Publication\' ';
               query += '    AND Product_Code__c in :productCodeSet ';
               query += ' ORDER BY ';
               query += '    Zuora__Account__r.AccountNumber';
               
        return Database.getQueryLocator(query);
    }
    
    // END 2015/04/29 Michael Francisco - D-2841 
        
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {       
        // START 2015/04/29 Michael Francisco - D-2841 
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        Map<ID, Zuora__Subscription__c> mContactSubscription = new Map<ID, Zuora__Subscription__c>();
        List<String> zProductCodeList = new List<String>();
        
        // Create Contact set ...
        Set<ID> zContactSet = new Set<ID>();
        for(sObject record : scope) {
            Zuora__Subscription__c zSubscriptionRecord = (Zuora__Subscription__c) record;
            
            ID zContact = zSubscriptionRecord.Subscriber_Contact__r.ID;
            String zProductCode = zSubscriptionRecord.Product_Code__c;
            
            if(zContact != null){
                mContactSubscription.put(zContact, zSubscriptionRecord);
            }
            
        }
        zContactSet = mContactSubscription.keySet();
        
        // Initialize Asia1 Subscription List ...
        List<Asia1__c> zAsia1List = new List<Asia1__c>();
        if(zContactSet.size() > 0){
            zAsia1List = [SELECT Contact__r.ID, User_ID_LDAP_ID__c FROM Asia1__c WHERE Contact__r.ID IN :zContactSet];
        } 
        
        // Initialize Contact Asia1 Map ...
        Map<ID, Asia1__c> zContactAsia1Map = new Map<ID, Asia1__c>();
        for(Asia1__c rec : zAsia1List)
        {
            ID zContact = rec.Contact__r.ID;
            if (zContact != null && zContactAsia1Map.get(zContact)==null) {
                zContactAsia1Map.put(zContact, rec);
            }
        }       
        
        // Process records ...
        Set<String> exportDataSet = new Set<String>();
        List<String> exportDataList = new List<String>();
        for(sObject record : scope) 
        {
            Zuora__Subscription__c subRecord = (Zuora__Subscription__c) record;
            
            String zVALIDATION_CODE = '0';            
            String zCustomerName = subRecord.Zuora__Account__r.Name;
            String zNRICPassport = subRecord.Zuora__Account__r.NRIC__c;
            String zBirthDate = String.valueOf(subRecord.Zuora__Account__r.Date_Of_Birth__c);
			//START D-3911 2015-11-11 Renz Use the Contact's Phone instead of Account's. Use all available phone number fields until you find valid value
			String zTelephoneNumber = subRecord.Subscriber_Contact__r.HomePhone__c;
			if (zTelephoneNumber ==null) zTelephoneNumber = subRecord.Subscriber_Contact__r.Mobile_Number__c;
			if (zTelephoneNumber ==null) zTelephoneNumber = subRecord.Subscriber_Contact__r.Mobile_Number_2__c;
			if (zTelephoneNumber ==null) zTelephoneNumber = subRecord.Subscriber_Contact__r.Office_Number__c;
			if (zTelephoneNumber ==null) zTelephoneNumber = subRecord.Subscriber_Contact__r.Fax__c;
			//END D-3911 2015-11-11 Renz
			
            String zEmailID = subRecord.Zuora__Account__r.Email__c;
            String zExpiryDate = String.valueOf(subRecord.Zuora__SubscriptionEndDate__c);
            String zSubscriberID = subRecord.Zuora__Account__r.AccountNumber;
            String zPostalCode = subRecord.Subscriber_Contact__r.Address__r.Postal_Code__r.Name;    
            String zCRSMAccountNumber = subRecord.Zuora__Account__r.Account_Auto_Number__c;    
        
        // START 2015/05/07 Michael Francisco - Code Review
            String zOnlineUserID = '';
            ID zContact = subRecord.Subscriber_Contact__r.ID;  
            if (zContactAsia1Map.get(zContact)!=null) {
                Asia1__c asia1Rec = zContactAsia1Map.get(zContact);
                zOnlineUserID = asia1Rec.User_ID_LDAP_ID__c;            
            }   
        
            // Validate 'Customer Name' data ...
            if (zCustomerName != null && zCustomerName.length() > 0) {
                zVALIDATION_CODE += '0';
            } else {
                zVALIDATION_CODE += '1';
            }

            // Validate 'Subscriber ID' data ...
            if (zSubscriberID != null && zSubscriberID.length() > 0) {
                zVALIDATION_CODE += '0';
            } else {
                zVALIDATION_CODE += '1';
            }

            // Validate 'Postal Code' data ...
            if (zPostalCode != null && zPostalCode.length() > 0) {
                zVALIDATION_CODE += '0';
            } else {
                zVALIDATION_CODE += '1';
            }           
        // END 2015/05/07 Michael Francisco - Code Review
                     
            String zData = ''; 
            zData += StringUtility.quoteReplaceStr(zCustomerName) + ',';        // Customer Name
            zData += StringUtility.quoteReplaceStr(zNRICPassport) + ',';        // NRIC or Passport
            zData += StringUtility.quoteReplaceStr(zBirthDate) + ',';           // Birthdate
            zData += StringUtility.quoteReplaceStr(zTelephoneNumber) + ',';     // Telephone Number
            zData += StringUtility.quoteReplaceStr(zEmailID) + ',';             // Email ID
            zData += StringUtility.quoteReplaceStr(zExpiryDate) + ',';          // Expiry Date
            zData += StringUtility.quoteReplaceStr(zSubscriberID) + ',';        // Subscriber ID
            zData += StringUtility.quoteReplaceStr(zPostalCode) + ',';          // Postal Code
            zData += StringUtility.quoteReplaceStr(zOnlineUserID) + ',';        // Asia1 Online User ID
            zData += 'N,';                                                      // Privacy Indicator
            zData += StringUtility.quoteReplaceStr(zCRSMAccountNumber);         // CRSM Account ID
            
            if (Decimal.valueOf(zVALIDATION_CODE)==0) {
                if (!exportDataSet.contains(zData)) {
                    exportDataList.add(zData);
                }
                exportDataSet.add(zData);              
            } else {
                System.debug('EXPORT-FAILED ID-['+subRecord.ID+'] CODE-['+zVALIDATION_CODE+']: '+zData);
            }
        }

        for (String exportData : exportDataList) {
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
             System.debug('BT_AB_' + interfaceId + '_DirectSubscriberRewards insert operation failed.');
        }
        // END 2015/04/29 Michael Francisco - D-2841 
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
        a1F.delegateBatchCall(serviceRequestVO);

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}