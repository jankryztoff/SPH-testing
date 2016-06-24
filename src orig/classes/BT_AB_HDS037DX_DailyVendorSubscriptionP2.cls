/*
 * Class Name: BT_AB_HDS037DX_DailyVendorSubscriptionP2
 * @author: Renino Q. Niefes
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - HDS037DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for HDS037DX batch job. Used together with BT_AS_HDS037DX_DailyVendorSubscription Schedulable
 * 
 *          2015/04/29 Renino Niefes                - Additional fix for UD-1056 Additional logic fur U indicator
 *          2015/05/04 Renino Niefes                - D-2854 Recipient Number to Plain String  / Enclose values with Quotes
 * 
 */

global class BT_AB_HDS037DX_DailyVendorSubscriptionP2 implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    global final String interfaceId = 'HDS037DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId); 
        Date dtEffStart = Date.valueOf(brd);
        Date dtEffEnd = dtEffStart.addDays(1);
        
        String  query = ' SELECT ';
                query += '  ID, ';
                query += '  Zuora__Account__r.Account_Legacy_Id__c, ';
                query += '  Zuora__Account__r.Account_Auto_Number__c, ';
                query += '  Zuora__Account__r.Id, ';
                query += '  Zuora__Account__r.Name, ';
                query += '  Zuora__Account__r.Company_Name__c, ';
                query += '  Zuora__Account__r.Sub_Group__c, ';
                query += '  Recipient_Contact__r.Address__r.Block_House_Number__c, ';
                query += '  Recipient_Contact__r.Address__r.Level_Number__c, ';
                query += '  Recipient_Contact__r.Address__r.Unit_Number__c, ';
                query += '  Recipient_Contact__r.Address__r.Postal_Code__r.Name, ';
                query += '  Recipient_Contact__r.Address__r.Street_Name__c, ';
                query += '  Recipient_Contact__r.Address__r.Building_Name__c, ';
                query += '  Recipient_Contact__r.Contact_Legacy_Id__c, ';
                query += '  Recipient_Contact__r.Id, ';
                query += '  Recipient_Contact__r.Name, ';
                query += '  Recipient_Contact__r.Recipient_Number__c, ';
                query += '  Recipient_Contact__r.Salutation, ';
                query += '  Name, ';
                query += '  Qty__c, ';
                query += '  Pub_Tag__c, ';
                query += '  Frequency__c, ';
                query += '  Product_Code__c, ';
                query += '  Zuora__SubscriptionStartDate__c, ';
                query += '  Zuora__SubscriptionEndDate__c, ';
                query += '  Effective_Start_Date__c, ';
                query += '  Effective_End_Date__c, ';
                query += '  Vendor_1__r.Id, ';
                query += '  Vendor_1__r.Vendor_Group__c, ';
                query += '  Vendor_1__r.Vendor_Code__c, ';
                query += '  LastModifiedDate, ';
                query += '  Zuora__Status__c ';
                query += ' FROM Zuora__Subscription__c ';
                query += ' WHERE Zuora__SubscriptionEndDate__c = :dtEffEnd ';

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
        
        System.debug('BT_AB_HDS037DX_DailyVendorSubscriptionP2:RENZ');
        
        Set<String> productCodeSet = new Set<String>();
        for(sObject record : scope)
        {
            Zuora__Subscription__c subRecord = (Zuora__Subscription__c) record;
            String zProductCode = subRecord.Product_Code__c;
            if (zProductCode!=null) {
                productCodeSet.add(zProductCode);
            }
        }
        
        List<Product_Publication__c> zProductPublicationList = new List<Product_Publication__c>();
        if (productCodeSet.size() > 0) {
            zProductPublicationList = [
                SELECT Id,
                    ZProduct__r.ProductCode__c,
                    Publication_Code__r.Publication_Code__c,
                    Publication_Code__r.Published_Days__c,
                    Publication_Code__r.Public_Holiday_Weekday_Pub_Indicator__c,
                    Publication_Code__r.Public_Holiday_Weekend_Pub_Indicator__c,
                    Publication_Code__r.Platform_Type__c
                FROM 
                    Product_Publication__c 
                WHERE 
                    ZProduct__r.ProductCode__c IN :productCodeSet
                    AND Publication_Code__r.Platform_Type__c = 'Print'
                    AND Publication_Code__r.ID != null                  
                ORDER BY Publication_Code__r.Publication_Code__c
            ];          
        }       
        Map<String, List<Publication__c>> productPublicationMap = new Map<String, List<Publication__c>>();
        Pattern pPublishedDays = Pattern.compile('((?=.*[YN]).{3,9})');
        Pattern pPublicationCode = Pattern.compile('((?=.*\\d)|(?=.*[a-zA-Z]).{2,6})');
        boolean failed = false;
        for (Product_Publication__c rec : zProductPublicationList) {
            String zProductCode = rec.ZProduct__r.ProductCode__c;
            String zPublishedDays = rec.Publication_Code__r.Published_Days__c;
            String zPublicationCode = rec.Publication_Code__r.Publication_Code__c;
            if (zPublishedDays != null && zPublicationCode != null) {
                Matcher mPublishedDays = pPublishedDays.matcher(zPublishedDays);
                Matcher mPublicationCode = pPublicationCode.matcher(zPublicationCode);
                if (mPublishedDays.matches() && mPublicationCode.matches()) {
                    if (productPublicationMap.containsKey(zProductCode)) {
                        List<Publication__c> existingPublicationCodeList = productPublicationMap.get(zProductCode);
                        existingPublicationCodeList.add(rec.Publication_Code__r);
                    } else{
                        List<Publication__c> newPublicationCodeList = new List<Publication__c>();
                        newPublicationCodeList.add(rec.Publication_Code__r);
                        productPublicationMap.put(zProductCode,newPublicationCodeList);
                    }                   
                } else {
                    failed = true;
                }
            } else {
                failed = true;
            }   
            if (failed) {
                System.debug('FAILED PP-REC-ID:'+rec.Id+' PUB-CODE:'+zPublicationCode+' PUB-DAYS:'+zPublishedDays);
                failed = false;
            } 
        }
        
        Set<String> exportDataSet = new Set<String>();      
        List<String> exportDataList = new List<String>();
        for(sObject record : scope)
        {
            Zuora__Subscription__c subRecord = (Zuora__Subscription__c) record;
            ID zRecordId = subRecord.Id;
            String zSingpostAddressId = '0000';
            
            String zAccountLegacyId = subRecord.Zuora__Account__r.Account_Legacy_Id__c;
            String zAccountNumber = subRecord.Zuora__Account__r.Account_Auto_Number__c;
            String zAccountID = subRecord.Zuora__Account__r.Id;
            String zAccountName = subRecord.Zuora__Account__r.Name;
            String zAccountCompany = subRecord.Zuora__Account__r.Company_Name__c;
            String zAccountSubGroup = subRecord.Zuora__Account__r.Sub_Group__c;
            String zAccountBlockHouseNo = subRecord.Recipient_Contact__r.Address__r.Block_House_Number__c;
            String zAccountLevelNo= subRecord.Recipient_Contact__r.Address__r.Level_Number__c;
            String zAccountUnitNo = subRecord.Recipient_Contact__r.Address__r.Unit_Number__c;
            String zAccountPostalCode = subRecord.Recipient_Contact__r.Address__r.Postal_Code__r.Name;
            String zAccountStreetName = subRecord.Recipient_Contact__r.Address__r.Street_Name__c;
            String zAccountBuildingName = subRecord.Recipient_Contact__r.Address__r.Building_Name__c;
            String zContactLegacyId = subRecord.Recipient_Contact__r.Contact_Legacy_Id__c;
            String zContactId = subRecord.Recipient_Contact__r.Id;
            String zContactName = subRecord.Recipient_Contact__r.Name;
			//START D-2854 2015-05-04 Renz use ToPlainString to prevent scientific notation
			String zContactNumber = null;
			if (subRecord.Recipient_Contact__r.Recipient_Number__c!=null) {
				zContactNumber = String.valueOf(subRecord.Recipient_Contact__r.Recipient_Number__c.toPlainString());  
			}
			//END D-2854 2015-05-04 Renz use ToPlainString to prevent scientific notation
            String zContactSalutation = subRecord.Recipient_Contact__r.Salutation;
            String zSubsName = subRecord.Name;
            Decimal zSubsQty = subRecord.Qty__c;
            String zSubsPubTag = subRecord.Pub_Tag__c;
            String zSubsFrequency = subRecord.Frequency__c;
            String zSubsProductCode = subRecord.Product_Code__c;
            Date zSubsStartDate = subRecord.Zuora__SubscriptionStartDate__c;
            Date zSubsEndDate = subRecord.Zuora__SubscriptionEndDate__c;
            Date zSubsEffectiveStartDate = subRecord.Effective_Start_Date__c;
            Date zSubsEffectiveEndDate = subRecord.Effective_End_Date__c;
            String zVendorId = subRecord.Vendor_1__r.Id;
            String zVendorGroup = subRecord.Vendor_1__r.Vendor_Group__c;
            String zVendorCode = subRecord.Vendor_1__r.Vendor_Code__c;
            DateTime zLastModifiedDate = subRecord.LastModifiedDate;
            String zStatus = subRecord.Zuora__Status__c;

            
            if (productPublicationMap.containsKey(zSubsProductCode)) {
                List<Publication__c> publicationListData = new List<Publication__c>();
                if (productPublicationMap.get(zSubsProductCode) != null) {
                    publicationListData = productPublicationMap.get(zSubsProductCode);
                }
                String zVALIDATION_CODE = '0';
                String zPublicationPattern = null;
                Decimal zTotalQuantity = 0;
                Decimal zSubscriptionQty = subRecord.Qty__c;
                String zPublishedDays = '';
                String zPublicationCode = '';
                String zPHeIndicator = 'N';
                String zPHdIndicator = 'N';
                boolean zPublicHolidayWeekdayInd = false;
                boolean zPublicHolidayWeekendInd = false;
                for (Publication__c rec : publicationListData) {
                    if (rec != null) {
                        zPublishedDays = StringUtility.getPublishedDays(zSubsFrequency, rec.Published_Days__c); 
                        zPublicationCode = rec.Publication_Code__c;
                        zPublicHolidayWeekdayInd = rec.Public_Holiday_Weekday_Pub_Indicator__c;
                        zPublicHolidayWeekendInd = rec.Public_Holiday_Weekend_Pub_Indicator__c;
                        if (zPublicHolidayWeekdayInd) {
                            zPHdIndicator = 'Y';
                        } else {
                            zPHdIndicator = 'N';
                        }
                        if (zPublicHolidayWeekendInd) {
                            zPHeIndicator = 'Y';
                        } else {
                            zPHeIndicator = 'N';
                        }
                        if (zPublishedDays != null && zPublishedDays.length() > 0) {
                            zPublicationPattern = zPublishedDays + zPHdIndicator;                                       
                        }
                        zTotalQuantity = Decimal.valueOf(zPublishedDays.replaceAll('[N]','').length()) * zSubscriptionQty;

                
                
                        String zVendorNumber = null;                        
                        if (zVendorGroup == null || zVendorGroup.length() == 0) {
                            zVendorGroup = 'V';
                        } 
                        if (zVendorCode !=null && zVendorCode.length() > 0) {
                            zVendorNumber = zVendorGroup + zVendorCode;
                            zVALIDATION_CODE += '0';
                        } else {
                            zVALIDATION_CODE += '1';
                        }
                        
                        // Validate House Block Number ...
                        if (zAccountBlockHouseNo!=null) {
                            zVALIDATION_CODE += '0';
                        } else {
                            zVALIDATION_CODE += '1';
                        }

                        // Validate Postal Code ...
                        if (zAccountPostalCode!=null) {
                            zVALIDATION_CODE += '0';
                        } else {
                            zVALIDATION_CODE += '1';
                        }
                        
                        // Validate zPublicationPattern ...
                        if (zPublicationPattern != null && zPublicationPattern.length() > 0) {
                            zVALIDATION_CODE += '0';
                        } else {
                            zVALIDATION_CODE += '1';
                        }
                        
                        // Validate Recipient Name ...
                        if (zContactName !=null) {
                            zVALIDATION_CODE += '0';
                        } else {
                            zVALIDATION_CODE += '1';
                        }
                        
                        // Validate CRSM Account Number ...
                        if (zAccountNumber!=null) {
                            zVALIDATION_CODE += '0';
                        } else {
                            zVALIDATION_CODE += '1';
                        }

                        // Validate CRSM Contact Number ...
                        if (zContactNumber!=null) {
                            zVALIDATION_CODE += '0';
                        } else {
                            zVALIDATION_CODE += '1';
                        }
                        
                        // Validate CRSM Direct Subscription ID ...
                        if (zSubsName!=null) {
                            zVALIDATION_CODE += '0';
                        } else {
                            zVALIDATION_CODE += '1';
                        }
                                            
						//START D-2854 2015-05-04 Renz Enclose the values with Quotes
						String zData = '';
						
						zData += StringUtility.quoteReplaceStr(zAccountLegacyId) +','; 				// Subscriber Account 
						zData += StringUtility.quoteReplaceStr(zContactLegacyId) +','; 				// Recipient Account 
						zData += StringUtility.quoteReplaceStr(zPublicationCode) +','; 				// Publication Code 
						zData += StringUtility.quoteReplaceStr(zSubsPubTag) +','; 						// Publication Tag 							
						zData += zSubsQty +','; 						// Subscription Copies
						zData += zSubsStartDate +','; 					// Subscription Start Date 
						zData += zSubsEndDate + ',';					// Subscription End Date 
						
						zData += StringUtility.quoteReplaceStr(zVendorNumber) +','; 					// Vendor Number 
						zData += StringUtility.quoteReplaceStr(zSingpostAddressId) +','; 				// Address ID 
						zData += StringUtility.quoteReplaceStr(zAccountBlockHouseNo) +','; 			// House-Block Number
						zData += StringUtility.quoteReplaceStr(zAccountLevelNo) +','; 					// Level Number
						zData += StringUtility.quoteReplaceStr(zAccountUnitNo) +','; 					// Unit Number 
						zData += StringUtility.quoteReplaceStr(zAccountPostalCode) +','; 				// Postal Code 
						zData += StringUtility.quoteReplaceStr(zAccountStreetName) +','; 				// Street Name 
						zData += StringUtility.quoteReplaceStr(zAccountBuildingName) +','; 			// Building Name 
						zData += 'U,'; 									// Indicator 
						zData += zPublicationPattern +','; 				// Day of Week Pattern 
						zData += StringUtility.quoteReplaceStr(zContactName) +','; 					// Recipient Name
						zData += StringUtility.quoteReplaceStr(zAccountCompany) +','; 					// Company Name 
						zData += StringUtility.quoteReplaceStr(zContactSalutation) +','; 				// Salutation 
						zData += StringUtility.quoteReplaceStr(zAccountNumber) +','; 					// CRSM Account ID
						zData += StringUtility.quoteReplaceStr(zContactNumber) +','; 					// CRSM Contact ID
						zData += StringUtility.quoteReplaceStr(zSubsName) +','; 						// CRSM Direct Subscription ID
						zData += StringUtility.quoteReplaceStr(zAccountSubGroup) +','; 				// CRSM Account Sub Group
						zData += StringUtility.quoteReplaceStr(zPHeIndicator) +','; 					// Day of week pattern (PHe)
						zData += 'null,'; 								// Previous House/Block Number
						zData += 'null,'; 								// Previous Level Number 
						zData += 'null,';			 					// Previous Unit Number 
						zData += 'null,'; 								// Previous Postal Code
						
						zData += 'null,'; 								// Vendor Conversion / blank for now
						zData += 'null,';			 					// Effective Date
						//END D-2854 2015-05-04 Renz Enclose the values with Quotes
                        if (Decimal.valueOf(zVALIDATION_CODE)==0) {
                            if (!exportDataSet.contains(zData)) {
                                exportDataList.add(zData);  
                            }
                            exportDataSet.add(zData);
                        } else {
                            System.debug('[P2]EXPORT-FAILED ID-['+zRecordId+'] CODE-['+zVALIDATION_CODE+']: '+zData);
                        }
                        zVALIDATION_CODE = '0';
                    } 
                }
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
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_' + interfaceId + '_DailyVendorSubscription insert operation failed.');
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
                
        //System.debug('*********************** inside final'+ this.query);
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
    //END 2015/03/30 UD-0624 Michael Francisco
}