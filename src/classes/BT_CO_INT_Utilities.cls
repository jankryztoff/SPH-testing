/*
* Class Name: BT_CO_INT_Utilities
* @author: Nitin B. Khanna
* Date: 2015/05/1468
* Project/Requirement: SPH Integration Interface
* @description This class populates BA_INT_DATA_POOL__c for VSS090DX batch job. Used together with BT_AS_VSS090DX_ExportVendorSubscription Schedulable
* 
* History: 
*       2015/05/14  Nitin Khanna            - Created APEX Class
*       2015/05/18  Michael Francisco   - Modified to include 'FAILED' record logging
*       2015/05/18  Renino Niefes           - Added new reusable methods
*       2015/05/19  Renino Niefes           - Overloaded the exportDataItem adding RecordID parameter
*       2015/12/03  Renino Niefes           - UD-1633 Remove Pagination_Rate__c field due to redundancy
*
*
*/

public Class BT_CO_INT_Utilities{
    public static final String DELIM = '|';

    //sends out publication code,frequency
    //ID in the return value refers to Package ID
    public static Map<ID,Set<Publication__c>> packageToPublication(List<ID> listPackages){
        Map<ID, Set<Publication__c>> mapPackToPub = new Map<ID, Set<Publication__c>>();
        Map<zqu__ProductRatePlanCharge__c, Publication__c> mapPRPCtoPub = new Map<zqu__ProductRatePlanCharge__c, Publication__c>();
        Set<String> setStrPubs = new Set<String>();
        List<ID> listPRP = new List<ID>();

        List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];
        //List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN ('a1XO0000000vVkzMAE') AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];

        for(Package_Item__c pi : listPackageItem)
            if(pi.Product_Rate_Plan__c != null) 
                listPRP.add(pi.Product_Rate_Plan__r.ID);
        
        log('SZ -----------> ' + listPRP.size());

        List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

        for(zqu__ProductRatePlanCharge__c temp : listPRPC)
            if(temp.PublicationCode__c != null) 
                setStrPubs.add(temp.PublicationCode__c);

        log('SZ1 ---------> '+setStrPubs.size());
        log('SZ2 ---------> '+setStrPubs);

        //START 2015/12/03  Renino Niefes           - UD-1633 Remove Pagination_Rate__c field due to redundancy
        List<Publication__c> listPublications = [SELECT Active_Date__c,Available_For_Vendor_Subscriptions__c,Commission_Rate_Fri__c,
            Commission_Rate_Mon__c,Commission_Rate_PHE__c,Commission_Rate_PHW__c,Commission_Rate_Sat__c,Commission_Rate_Special_Fri__c,
            Commission_Rate_Special_Mon__c,Commission_Rate_Special_PHE__c,Commission_Rate_Special_PHW__c,Commission_Rate_Special_Sat__c,
            Commission_Rate_Special_Sun__c,Commission_Rate_Special_Thu__c,Commission_Rate_Special_Tue__c,Commission_Rate_Special_Wed__c,
            Commission_Rate_Sun__c,Commission_Rate_Thu__c,Commission_Rate_Tue__c,Commission_Rate_Wed__c,Cover_Price_Fri__c,
            Cover_Price_Mon__c,Cover_Price_PHE__c,Cover_Price_PHW__c,Cover_Price_Sat__c,Cover_Price_Sun__c,Cover_Price_Thu__c,
            Cover_Price_Tue__c,Cover_Price_Wed__c,CreatedById,CreatedDate,Delivery_Rate_Fee__c,Direct_Sub_Delivery_Method__c,
            Direct_Sub_Mailing_Agent__c,Earliest_Start_Date__c,Expiry_Date__c,Free_Publication__c,Frequency_Code__c,ID,Insertion__c,
            Insert_Rate__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Migration_Code__c,
            Name,Online_Publication__c,OwnerId,Pagination__c,Platform_Type__c,Product_Category__c,Product_Family_Lookup__c,
            Product_Family__c,Publication_Code__c,Publication_Next_Start_Date__c,Publication_Type__c,Public_Holiday_Weekday_Pub_Indicator__c,
            Public_Holiday_Weekend_Pub_Indicator__c,Published_Days__c,Publisher_Code__c,Publish_Pattern__c,Sph_Publication_Indicator__c,
            Sunday_Publication__c,SystemModstamp,Vendor_Sub_Delivery_Method__c,Vendor_Sub_Mailing_Agent__c FROM Publication__c 
            WHERE Publication_Code__c IN :setStrPubs AND  Platform_Type__c='Print' AND Publication_Type__c = 'N'];
        //END 2015/12/03  Renino Niefes           - UD-1633 Remove Pagination_Rate__c field due to redundancy
        log('SZ2 ---------> '+listPublications.size());
        log('SZb ---------> '+listPublications);

        for(zqu__ProductRatePlanCharge__c prpc : listPRPC)
            for(Publication__c pub : listPublications)
                if(prpc.PublicationCode__c == pub.Publication_Code__c) 
                    mapPRPCtoPub.put(prpc,pub);

        log('SZ4 ---------> '+ mapPRPCtoPub.size());
        log('SZ5 ---------> '+ mapPRPCtoPub);
        // Start - Nitin - hot Fix - 20-Aug-2015 putting pset inside for loop
        //START HotFix 27-July-2015 Added by Nitin - Moved pSet out of for loop
        //Set<Publication__c> pSet = new Set<Publication__c>();
        for(Package_Item__c pi : listPackageItem) {
            //START UD-2598 - HotFix 03-Sep-2015 Added by Raviteja - Adding multiple subscriptions for 1 packgeid
            /*
            Set<Publication__c> pSet = new Set<Publication__c>();
        //End HotFix 27-July-2015 Added by Nitin - Moved pSet out of for loop   
        // End- Nitin - hot Fix - 20-Aug-2015 putting pset inside for loop
            for(zqu__ProductRatePlanCharge__c temp : listPRPC) {
                if(pi.Product_Rate_Plan__c == temp.zqu__ProductRatePlan__c)
                    pSet.add(mapPRPCtoPub.get(temp));
            }
            mapPackToPub.put(pi.Package__c, pSet);
            log('SZ6 ---------> '+ pSet.size());
            log('SZ7 ---------> '+ pi.package__r.package_code__c + ' ----> ' + pSet);
        }
        log('SZ8 ---------> '+ mapPackToPub.size());
        log('SZ9 ---------> '+ mapPackToPub);
        */
            for(zqu__ProductRatePlanCharge__c temp : listPRPC) {
                System.debug(' temp : '+temp );
                System.debug(' pi.Product_Rate_Plan__c: '+pi.Product_Rate_Plan__c );
                if(pi.Product_Rate_Plan__c == temp.zqu__ProductRatePlan__c){
                    System.debug(' temp.zqu__ProductRatePlan__c : '+temp.zqu__ProductRatePlan__c );
                    if(!mapPackToPub.containsKey(pi.Package__c))
                        mapPackToPub.put(pi.Package__c, new Set<Publication__C> {mapPRPCtoPub.get(temp)});
                    else
                        mapPackToPub.get(pi.Package__c).add(mapPRPCtoPub.get(temp));  
                    }
                   System.debug(' mapPackToPub : '+mapPackToPub );
                }
            }
            //End UD-2598 - HotFix 03-Sep-2015 Added by Raviteja
        return mapPackToPub;
    }
    
    //START UD-2691 23-Sep-2015 Added by Raviteja  - Adding prodPubMapping method 
        public static Map<String, Set<String>> prodPubMapping(){
        List<Product_Publication__c> listPP = [SELECT ZProduct__r.productcode__c, publication_code__r.name FROM Product_Publication__c];
        Map<String, Set<String>> mProdPub = new Map<String, Set<String>>();
        for(Product_Publication__c pp : listPP){
            if(mProdPub.containsKey(pp.ZProduct__r.productcode__c)){
                Set<String> tmp = mProdPub.get(pp.ZProduct__r.productcode__c);
                tmp.add(pp.publication_code__r.name);
            }else{
                Set<String> tmp = new Set<String>(); 
                tmp.add(pp.publication_code__r.name);
                mProdPub.put(pp.ZProduct__r.productcode__c, tmp);
            }
        }
        return mProdPub;
    }
    
    public static Set<Publication__c> prodPubMapping(Set<Publication__c> setPubs, String prodCode, Map<String, Set<String>> mapProdPub){
        Set<Publication__c> publicationListDataTmp = new Set<Publication__c>();
        Set<String> pubs = mapProdPub.get(prodCode);
                System.debug('******************************* '+prodCode);
        System.debug('******************************* '+pubs);
        for(Publication__c p : setPubs){
            //if(pubs != null &&  pubs.contains(p.name))
            System.debug(' p: '+ p);
            if(pubs != null)
                  if(p != Null && p.name != Null)
                      if(pubs.contains(p.name))
                        publicationListDataTmp.add(p);
                
        }
        return publicationListDataTmp;
    }
    //End UD-2691 23-Sep-2015 Added by Raviteja
    // Return a MAP of Zuora__Subscription__c objects using ID as the KEY ...
    public static Map<ID, Zuora__Subscription__c> orderToSubscription(List<ID> lOrderIDs) {
        
        List<Order__c> lOrderList = new List<Order__c>();
        if (lOrderIDs != null && lOrderIDs.size() > 0) {
            lOrderList = [
                SELECT 
                   ID,
                   Subscription__r.ID
                FROM
                    Order__c
                WHERE
                    ID IN :lOrderIDs
            ];          
        }
        List<ID> zSubscriptionIDs = new List<ID>();
        if (lOrderList.size() > 0) {
            for (Order__c oRecord : lOrderList) {
                ID zRecordID = oRecord.Subscription__r.ID;
                if (zRecordID != null) {
                    zSubscriptionIDs.add(zRecordID);
                }
            }
        }
        Map<ID, Zuora__Subscription__c> mSubscriptionMap = getSubscriptionMap(zSubscriptionIDs);
        return mSubscriptionMap;
    }
    
    public static Map<ID, Zuora__Subscription__c> getSubscriptionMap(List<ID> zSubscriptionIDs) {
        Map<ID, Zuora__Subscription__c> mSubscriptionMap = new Map<ID, Zuora__Subscription__c>();
        if (zSubscriptionIDs != null && zSubscriptionIDs.size() > 0) {      
            List<Zuora__Subscription__c> zSubscriptionsList = new List<Zuora__Subscription__c>();
            zSubscriptionsList = [
                SELECT
                    ID,
                    Name,
                    Qty__c,
                    Pub_Tag__c,             
                    Frequency__c,
                    Product_Code__c,
                    Zuora__SubscriptionStartDate__c,
                    Zuora__SubscriptionEndDate__c,
                    Effective_Start_Date__c,        
                    Effective_End_Date__c,              
                    Vendor_1__r.Id,
                    Vendor_1__r.Vendor_Group__c,
                    Vendor_1__r.Vendor_Code__c,
                    Main_Package_1__c,
                    LastModifiedDate,
                    Zuora__Status__c,
                    Vendor_Conversion_1__c, // START / End UD-2771 16-Sep-2015 Added by Raviteja - Adding Vendor Conversion field in Subscription records
                    Recipient_Contact__r.Address__r.Block_House_Number__c,
                    Recipient_Contact__r.Address__r.Level_Number__c,
                    Recipient_Contact__r.Address__r.Unit_Number__c,
                    Recipient_Contact__r.Address__r.Postal_Code__r.Name,
                    Recipient_Contact__r.Address__r.Street_Name__c,
                    Recipient_Contact__r.Address__r.Building_Name__c,
                    Recipient_Contact__r.Contact_Legacy_Id__c,
                    Recipient_Contact__r.ID,
                    Recipient_Contact__r.Name,
                    Recipient_Contact__r.Recipient_Number__c,
                    Recipient_Contact__r.Salutation
                FROM
                    Zuora__Subscription__c
                WHERE
                    ID IN :zSubscriptionIDs
            ];
            if (zSubscriptionsList.size() > 0) {
                for (Zuora__Subscription__c zRecord : zSubscriptionsList) {
                    if (zRecord != null) {
                        ID zRecordID = zRecord.ID;
                        if (zRecordID != null) {
                            mSubscriptionMap.put(zRecordID, zRecord);                                           
                        }
                    }
                }
            }   
        }
        return mSubscriptionMap;
    }
    
    public static Map<ID, Address_Assignment__c> getAddressAssignmentMap(List<ID> caseIdCOAList) {
        Map<ID, Address_Assignment__c> caseAddressAssignmentMap = new Map<ID, Address_Assignment__c>();
        List<Address_Assignment__c> addressAssignmentList = new List<Address_Assignment__c>();
        if (caseIdCOAList != null && caseIdCOAList.size() > 0) {
            addressAssignmentList = [
                SELECT 
                    ID,
                    Active__c,
                    Address__r.Block_House_Number__c,
                    Address__r.Level_Number__c,
                    Address__r.Unit_Number__c,
                    Address__r.Street_Name__c,
                    Address__r.Building_Name__c,
                    Address__r.Postal_Code__r.Name,                 
                    Case__r.Id,
                    Effective_Date__c,
                    Name,
                    Subscription__r.Id,
                    Subscription_Vendor__r.Id,
                    Vendor__r.Vendor_Code__c,
                    Vendor__r.Vendor_Group__c
                FROM 
                    Address_Assignment__c
                WHERE   
                    Case__c IN :caseIdCOAList
                ORDER BY
                    Address__r.Postal_Code__r.Name, 
                    Address__r.Level_Number__c, 
                    Address__r.Unit_Number__c,
                    Effective_Date__c
            ];  
            if (addressAssignmentList.size() > 0) {
                for (Address_Assignment__c aRecord : addressAssignmentList) {
                    if (aRecord != null) {
                        ID caseId = aRecord.Case__r.Id;
                        //ID addressAssignmentId = aRecord.Id;
                        if (caseId != null) {
                            // Create Case-AddressAssignment Map
                            caseAddressAssignmentMap.put(caseId,aRecord);
                        }
                    }
                }               
            }
        }       
        return caseAddressAssignmentMap;
    }
    
    public static boolean checkValidation(String zVALIDATION_CODE) {
        boolean bResult = false;
        if (String.isNotBlank(zVALIDATION_CODE)) {
            bResult = (Decimal.valueOf(zVALIDATION_CODE) == 0);
        }
        return bResult;
    }
    
    public static boolean exportDataItemDuplicateCheck(String zInput, Set<String> zDataSet) {   
        boolean bResult = false;
        if (zDataSet != null) {
            bResult = (!zDataSet.contains(zInput));             
        }
        return bResult;
    }   
        
    public static List<BA_INT_DATA_POOL__c> exportDataItem(String interface_id, String group_id, String zInput, DateTime dtLastModifiedDate, List<BA_INT_DATA_POOL__c> ldpValid) {
        BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
        datapoolRecord.Name = interface_id;
        datapoolRecord.job_id__c = '1';
        datapoolRecord.group_id__c = group_id;
        datapoolRecord.run_for_date__c = Date.today();      
        datapoolRecord.insert_time__c = dtLastModifiedDate; 
        datapoolRecord.export_data__c = zInput;            
        
        ldpValid.add(datapoolRecord);       
        
        return ldpValid;
    }
    
    public static List<BA_INT_DATA_POOL__c> exportDataItem(String interface_id, String group_id, String zRecordID, String zInput, DateTime dtLastModifiedDate, List<BA_INT_DATA_POOL__c> ldpValid) {
        BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
        datapoolRecord.Name = interface_id;
        datapoolRecord.job_id__c = '1';
        datapoolRecord.group_id__c = group_id;
        datapoolRecord.Record_ID__c = zRecordID;
        datapoolRecord.run_for_date__c = Date.today();      
        datapoolRecord.insert_time__c = dtLastModifiedDate; 
        datapoolRecord.export_data__c = zInput;            
        
        ldpValid.add(datapoolRecord);       
        
        return ldpValid;
    }   

    public static List<BA_INT_DATA_FAILED_POOL__c> exportFailedDataItem (String interface_id, String group_id, String zRecordID, String zErrorMsg, String zErrorCode, String zData, DateTime dtLastModifiedDate, List<BA_INT_DATA_FAILED_POOL__c> ldpFailed) {
        BA_INT_DATA_FAILED_POOL__c datapoolFailedRecord = new BA_INT_DATA_FAILED_POOL__c();
        datapoolFailedRecord.Name = interface_id;
        datapoolFailedRecord.Record_ID__c = zRecordID;
        datapoolFailedRecord.insert_time__c = dtLastModifiedDate; 
        datapoolFailedRecord.export_data__c = zData;  
        datapoolFailedRecord.Error_Message__c = zErrorMsg;
        datapoolFailedRecord.Error_Code__c = zErrorCode;
        datapoolFailedRecord.job_id__c = '1';
        datapoolFailedRecord.group_id__c = group_id;
        datapoolFailedRecord.run_for_date__c = Date.today();      
        
        ldpFailed.add(datapoolFailedRecord);   

        return ldpFailed;
    } 
    
    public static String convert(String zVALIDATION_CODE) {
        double dResult = 0;
        try {
            Integer SIZE = zVALIDATION_CODE.length();
            Integer iPower = zVALIDATION_CODE.length()-1;
            String zErrorCode = zVALIDATION_CODE.reverse();
            Integer i = 0;
            while(iPower>=0){
                double exp = (Math.pow(2,iPower));
                Integer iBase = 0;          
                try {
                    iBase = Integer.valueOf(zErrorCode.subString(i,i<SIZE? i+1 : i));
                } catch (Exception ignore) {
                    iBase = 0;
                }
                dResult += (exp * iBase);   
                
                iPower--;
                i++;
            }           
        } catch (Exception e) {
            dResult = -1.0;
        }
        return String.valueOf(Integer.valueOf(dResult));        
    }   
    
    public static void log(String zMsg, ID zRecordID, String vCode, String zData) {
        System.debug(zMsg +' RECORD-ID:' + zRecordID + ' V-CODE:' + vCode + ' Z-DATA:' + zData);
    }

    public static void log(String zMsg, ID zRecordID) {
        System.debug(zMsg +' RECORD-ID:' + zRecordID);
    }   

    public static void log(String zMsg) {
        System.debug(zMsg);
    }
    
    public static void sendCallOutMessage(String interfaceId) {
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');

        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID(interfaceId);
        serviceRequestVO.setJobDate(myDate);
        a1F.delegateBatchCall(serviceRequestVO);
    }
    
    public static Map<Decimal,String> getErrorMessageMap(String interfaceId) {
        Map<Decimal,String> errorMessageMap = new Map<Decimal,String>();
        
        List<BT_CS_Interface_Field_Validation__c> fieldValidationList  = [
                SELECT 
                    Error_Message__c,
                    Field_ID__c 
                FROM 
                    BT_CS_Interface_Field_Validation__c 
                WHERE 
                    Name = :interfaceId 
                ORDER BY 
                    Field_ID__c ASC NULLS FIRST
            ];
        
        for (BT_CS_Interface_Field_Validation__c record  : fieldValidationList) {
            if (StringUtility.validate(record.Field_ID__c).equalsIgnoreCase('0')&&StringUtility.validate(record.Error_Message__c).equalsIgnoreCase('0')) {
                errorMessageMap.put(record.Field_ID__c, record.Error_Message__c);
            }
        }
        
        return errorMessageMap;
    }
    
    public static Date getEffectiveIssueDate(DateTime dtComplaintFrom, DateTime dtComplaintTo, String zPattern) {
        Date dtEffectiveIssueDate = null;
        try {
            dtEffectiveIssueDate = DateUtility.getFirstPublicationDate(dtComplaintFrom, dtComplaintTo, zPattern);
        } catch (Exception e) {
            dtEffectiveIssueDate = null;
        }
        return dtEffectiveIssueDate;
    }
    
    public static String getComplaintDescription(Date dtComplaintTo, Date dtComplaintFrom) {
        String zResult = '';
        try {
            String zTmpFrom = StringUtility.formatDateValue(dtComplaintFrom, 'dd.mm.yyyy');
            String zTmpTo = StringUtility.formatDateValue(dtComplaintTo, 'dd.mm.yyyy');     
            zResult = 'Period from ' + zTmpFrom + ' to ' + zTmpTo;
        } catch (Exception e) {
            zResult = '';
        }
        return zResult;
    }   
    
    public static String parseValidationCode(String zVALIDATION_CODE, Map<Decimal, String> mFieldErrMsg) {
        String zErrorMsg = '';
        if (String.isNotBlank(zVALIDATION_CODE)) { 
            Integer iValidationSize = zVALIDATION_CODE.length();
            List<Integer> l = new List<Integer>();
            try {
                for (Integer i = 0; i<iValidationSize; i++) {
                    l.add(Integer.valueOf(zVALIDATION_CODE.substring(i,i<iValidationSize ? i+1 : i)));
                }               
            } catch (Exception ignore) {}           
            for (Integer i = 0; i < l.size(); i++) {
                String zTempMsg = ''; 
                try {
                    zTempMsg = '('+i+'):'+mFieldErrMsg.get(i);                  
                    if (zTempMsg == null) {
                        zTempMsg = '';
                    }
                } catch (Exception e) {
                    zTempMsg = '';
                }
                zErrorMsg += (l.get(i) > 0) ? zTempMsg : '';
            }
        }
        return zErrorMsg;
    }   
    
    public static String extractLegacyID(String zInputStr, String zDelim) {
        String zResult = null;
        if (zInputStr != null) {
            String zDelimiter = DELIM;
            if (zDelim != null) {
                zDelimiter = zDelim;
            }
            if (zInputStr.contains(zDelimiter)) {
                // Sample value for VSS/HDS Legacy IDs ---> VSS|1316444
                List<String> l = zInputStr.split('['+zDelimiter+']');
                if (l.size() > 1) {
                    zResult = l.get(1);             
                }               
            } else {
                zResult = zInputStr;
            }
        }
        return zResult;
    }   
}