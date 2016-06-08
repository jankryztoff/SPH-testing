/**
 * Trigger Name: BT_AT_VSS085DX_ImportVendorSubscription
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)
 * History: 2015/05/04 D-2856 Renino Niefes Exit Code 5 Issue due to 100k governor limits
 * History: 2015-05-06 D-2856 Renz Niefes - Correction on fields to be used for Contacts
 * History: 2015/05/08 Renino Niefes - Total rewrite
 * History: 2015/05/20 Renino Niefes - Code Review (Line 371 is causing a 100k error since HDS ID is not indexed.  planning to add another criteria to work around this.)
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW  
 */

public class BT_TH_VSS085DX_ImportVendorSubscription
{        
    integer invalidRecordCount = 0;
    String errorMessage = '';   
    String stackTrace = '';
    String dmlStatus = 'Success';   
    
    List<Account> accountsList = new List<Account>();
    List<Contact> contactsList = new List<Contact>();
    List<Address__c> addressList = new List<Address__c>();
    List<Singpost_Address__c> postalCodeList = new List<Singpost_Address__c>();
    List<Subscription_Vendor__c> subvenList = new List<Subscription_Vendor__c>();
    List<Account> vendorsList = new List<Account>();
    List<Subscription_Vendor_Publication__c> svpList = new List<Subscription_Vendor_Publication__c>();
    
    Set<String> hdsRecipientIDSet = new Set<String>();
    Set<String> hdsContactIdSet = new Set<String>();
    Set<String> crsmAccountNoSet = new Set<String>();
    Set<String> crsmAccountNameSet = new Set<String>();
    Set<String> crsmAccountPostalSet = new Set<String>();
    Set<String> crsmAccountUnitSet = new Set<String>();
    Set<String> crsmAccountLevelSet = new Set<String>();
    Set<ID> crsmAccountIDSet = new Set<ID>();
    Set<String> hdsSubscriptionIDSet = new Set<String>();
    Set<String> vssSubscriptionIDSet = new Set<String>();
    Set<String> vendorNumbersSet = new Set<String>();
    Set<String> publicationCodeSet = new Set<String>();
    Set<String> crsmContactNoSet = new Set<String>();
    
    Map<String,Account> hdsRecipientMap = new Map<String,Account>();
    Map<String,Account> crsmAccountNoMap = new Map<String,Account>();
    Map<String,Account> accountNameMap = new Map<String,Account>();
    Map<String,ID> accountNameByIDMap = new Map<String,ID>();
    
    Map<String,Address__c> addressMap = new Map<String,Address__c>();
    Map<String,Singpost_Address__c> postalCodeMap = new Map<String,Singpost_Address__c>();
    
    Map<String,Contact> hdsContactMap = new Map<String,Contact>();
    Map<Decimal,Contact> crsmContactNoMap = new Map<Decimal,Contact>();
    Map<String,Contact> contactNameMap = new Map<String,Contact>();
    
    Map<String, Subscription_Vendor__c> subVenMap = new Map<String, Subscription_Vendor__c>();
    Map<String, Account> vendorsMap = new Map<String, Account>();
    Map<String, Publication__c> publicationMap = new Map<String, Publication__c>();
    Map<String, Subscription_Vendor_Publication__c> svpMap = new Map<String, Subscription_Vendor_Publication__c>();
    
    List<BT_CO_VSS_ImportVendorSubscription__c> validRecordsList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
    
    public void execute(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList)
    {
        //Initialize Sets
        initializeSets(recordsList);

        //Prepare the Maps (This comes first because postal code map is being used by validator)
        prepareAddressMaps();
        prepareVendorMaps();
        preparePublicationMaps();
        prepareAccountMaps();
        prepareContactMaps();
        prepareSubscriptionVendorMaps();
        prepareSubscriptionVendorPublicationMaps();
        
        //Validate Mandatory fields e.g. HDS Recipient ID, Subscriber Postal, HDS Contact ID, 
        //Recipient Postal, Vendor Group, Vendor Code, Publication Code
        validateFileRecords(recordsList);
            
        
        //Loop through each record and process
        processAccountRecords(validRecordsList);        
        
        //Loop through each record and process
        processAddressRecords(validRecordsList);
        
        //Loop through each record and process      
        processBillingContactRecords(validRecordsList);
        processRecipientContactRecords(validRecordsList);
        processSubscriptionVendorRecords(validRecordsList);
        
        
        
        
        //LogManager
         BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
        leg2sfLog.Interface_ID__c = 'VSS085DX';
        leg2sfLog.Batch_Run_Date__c = recordsList[0].Batch_Run_Date__c;
        leg2sfLog.Total_Record_Count__c = recordsList.size();
        leg2sfLog.Valid_Record_Count__c = recordsList.size() - invalidRecordCount;
        leg2sfLog.Invalid_Record_Count__c = invalidRecordCount;
        leg2sfLog.DML_Status__c = '';
        leg2sfLog.Error_Message__c = '';
        leg2sfLog.Stack_Trace__c = '';
        leg2sfLog.Batch_Job_Id__c = recordsList[0].Batch_Job_Id__c;
   
        insert leg2sfLog;
    }
    
    public void validateFileRecords(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList) {
        Boolean isValid = true;
        String validationDetails = '';
        
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vSubscriberPostalCode = so.SubscriberPostalCode__c;
            String vHdsContactId = so.HdsContactId__c;
            String vRecipientPostalCode = so.RecipientPostalCode__c;
            String vHdsSubscriptionId = so.HdsSubscriptionId__c;
            String vVendorGroup = so.VendorGroup__c;
            String vVendorNumber = so.VendorNumber__c;          
            String vPublicationCode = so.PublicationCode__c;
            String vStartDate = so.StartDate__c;
            String vStopDate = so.StopDate__c;
            String vSubscriptionCopies = so.SubscriptionCopies__c;
            
            validationDetails = '';
            isValid = true;
            
            if(vHdsRecipientId==null||vHdsRecipientId.trim()== '') {
                    validationDetails += 'HdsRecipientId__c is mandatory field...';
                    isValid = false;
            }
            
            if(vSubscriberPostalCode==null||vSubscriberPostalCode.trim()== '') {
                    validationDetails += 'SubscriberPostalCode__c is mandatory field...';
                    isValid = false;
            } else {
                if (postalCodeMap.containsKey(vSubscriberPostalCode)==false) {
                    validationDetails += 'SubscriberPostalCode__c is invalid...';
                    isValid = false;                
                }
            }           
            
            if(vHdsContactId==null||vHdsContactId.trim()== '') {
                    validationDetails += 'HdsContactId__c is mandatory field...';
                    isValid = false;
            }
            
            if(vRecipientPostalCode==null||vRecipientPostalCode.trim()== '') {
                    validationDetails += 'RecipientPostalCode__c is mandatory field...';
                    isValid = false;                    
            } else {
                if (postalCodeMap.containsKey(vRecipientPostalCode)==false) {
                    validationDetails += 'RecipientPostalCode__c is invalid...';
                    isValid = false;                
                }
            
            }

            if(vHdsSubscriptionId==null||vHdsSubscriptionId.trim()== '') {
                    validationDetails += 'HDS Subscription ID is mandatory field...';
                    isValid = false;
            }
            
            if(vVendorGroup==null||vVendorGroup.trim()== '') {
                    validationDetails += 'Vendor Group is mandatory field...';
                    isValid = false;
            }

            if(vVendorNumber==null||vVendorNumber.trim()== '') {
                    validationDetails += 'Vendor Number is mandatory field...';
                    isValid = false;
            } else {
                if (vendorsMap.containsKey(vVendorNumber)==false) {
                    validationDetails += 'Vendor Number does not exist in crsm...';
                    isValid = false;    
                }
            }
            
            if(vStartDate!=null&&vStartDate.trim()!= '') {              
                if(DateUtility.isDateDD_MM_YYYY(vStartDate,'\\.') == false) {
                    validationDetails += 'Start Date is not in correct format...';
                    isValid = false;
                }
            }

            if(vStopDate!=null&&vStopDate.trim()!= '') {                
                if(DateUtility.isDateDD_MM_YYYY(vStopDate,'\\.') == false) {
                    validationDetails += 'Stop Date is not in correct format...';
                    isValid = false;                    
                }
            }
            
            if (vPublicationCode==null||vPublicationCode.trim()=='') {
                validationDetails += 'Publication Code is mandatory field...';
                isValid = false;
            } else {
                if (publicationMap.containsKey(vPublicationCode)==false) {
                    validationDetails += 'Publication Code is invalid...';
                    isValid = false;                
                }               
            }

            if (vSubscriptionCopies==null||vSubscriptionCopies.trim()==''){         
                validationDetails += 'Subscription Copies is empty...';
                isValid = false;            
            } else {
                if (vSubscriptionCopies.trim().length()!=27) {
                    validationDetails += 'Subscription Copies is not in the correct format...';
                    isValid = false;                
                }
                
                if (vSubscriptionCopies.trim().isNumeric()==false) {
                    validationDetails += 'Subscription Copies is not in the correct format...';
                    isValid = false;                
                }
            }
            
            if (isValid) {
                validRecordsList.add(so);
            } else {
                so.Validation_Status__c = 'Failed';
                so.Validation_Details__c = validationDetails;
                invalidRecordCount++;
                System.debug('VSS085DX: Validation Error: ' + validationDetails);
            }
            
        }
    }
    
    public void initializeSets(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList) {
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {       
            if (so.HdsRecipientId__c!=null&&so.HdsRecipientId__c.trim()!='') hdsRecipientIDSet.add(so.HdsRecipientId__c.trim());
            if (so.HdsContactId__c!=null&&so.HdsContactId__c.trim()!='') hdsContactIdSet.add(so.HdsContactId__c.trim());
            if (so.CrsmAccountId__c!=null&&so.CrsmAccountId__c.trim()!='') crsmAccountNoSet.add(so.CrsmAccountId__c.trim());
            if (so.CrsmContactId__c!=null&&so.CrsmContactId__c.trim()!='') crsmContactNoSet.add(so.CrsmContactId__c.trim());
            if (so.SubscriberName__c!=null&&so.SubscriberName__c.trim()!='') {
                crsmAccountNameSet.add(so.SubscriberName__c.trim());
            } else{
                if (so.HdsRecipientId__c!=null&&so.HdsRecipientId__c.trim()!='') {
                    crsmAccountNameSet.add('HDS Recipient ID ' + so.HdsRecipientId__c.trim());
                } else {
                    crsmAccountNameSet.add('HDS Recipient');
                }
            }
            if (so.SubscriberPostalCode__c!=null&&so.SubscriberPostalCode__c.trim()!='') crsmAccountPostalSet.add(so.SubscriberPostalCode__c.trim());           
            if (so.SubscriberUnit__c!=null&&so.SubscriberUnit__c.trim()!='') crsmAccountUnitSet.add(so.SubscriberUnit__c.trim());
            if (so.SubscriberLevel__c!=null&&so.SubscriberLevel__c.trim()!='') crsmAccountLevelSet.add(so.SubscriberLevel__c.trim());
            if (so.RecipientPostalCode__c!=null&&so.RecipientPostalCode__c.trim()!='') crsmAccountPostalSet.add(so.RecipientPostalCode__c.trim());
            if (so.RecipientUnit__c!=null&&so.RecipientUnit__c.trim()!='') crsmAccountUnitSet.add(so.RecipientUnit__c.trim());
            if (so.RecipientLevel__c!=null&&so.RecipientLevel__c.trim()!='') crsmAccountLevelSet.add(so.RecipientLevel__c.trim());
            
            if (so.HdsSubscriptionId__c!=null&&so.HdsSubscriptionId__c.trim()!='') {
                vssSubscriptionIDSet.add('VSS|'+so.HdsSubscriptionId__c.trim());
                hdsSubscriptionIDSet.add(so.HdsSubscriptionId__c.trim());
            }
            if (so.VendorNumber__c!=null&&so.VendorNumber__c.trim()!='') vendorNumbersSet.add(so.VendorNumber__c.trim());
            if (so.PublicationCode__c!=null&&so.PublicationCode__c.trim()!='') publicationCodeSet.add(so.PublicationCode__c.trim());
        }   
    }
    
    public void prepareAccountMaps() {
        //Search Account by HDS Recipient ID
        accountsList = [SELECT ID, HDS_Recipient_Id__c, Name, Company_Name__c,
                               Email__c, NRIC__c, Office_Extension__c, Office_Number__c, Phone
                               FROM Account WHERE HDS_Recipient_Id__c IN :hdsRecipientIDSet ];
        for (Account acc : accountsList) {
            hdsRecipientMap.put(acc.HDS_Recipient_Id__c,acc);
        }
        
        
        //Search Account by Account Number
        accountsList = [SELECT ID, HDS_Recipient_Id__c, Name, Company_Name__c,
                               Email__c, NRIC__c, Office_Extension__c, Office_Number__c, Phone
                               FROM Account WHERE AccountNumber IN :crsmAccountNoSet    ];
        for (Account acc : accountsList) {
            hdsRecipientMap.put(acc.AccountNumber,acc);
        }
        
        //Search Account by Account Name and Address
        contactsList = [SELECT Account.ID, 
                                    Account.Name,
                                    Address__r.Postal_Code__r.Name,
                                    Address__r.Unit_Number__c,
                                    Address__r.Level_Number__c
                                FROM Contact 
                                WHERE Account.Name in :crsmAccountNameSet
                                    AND Address__r.Postal_Code__r.Name IN :crsmAccountPostalSet
                                    AND Address__r.Unit_Number__c IN :crsmAccountUnitSet
                                    AND Address__r.Level_Number__c IN :crsmAccountLevelSet
                                    AND Billing_Indicator__c = TRUE
                                    ];
        for (Contact con : contactsList) {
            crsmAccountIDSet.add(con.Account.ID);
            String searchString = con.Account.Name + con.Address__r.Postal_Code__r.Name +
                                  con.Address__r.Unit_Number__c + con.Address__r.Level_Number__c;
            accountNameByIDMap.put(searchString, con.Account.ID);
        }
        accountsList = [SELECT ID, HDS_Recipient_Id__c, Name, Company_Name__c,
                               Email__c, NRIC__c, Office_Extension__c, Office_Number__c, Phone
                               FROM Account WHERE ID IN :crsmAccountIDSet   ];
        for (Account acc : accountsList) {
            accountNameMap.put(acc.ID,acc);
        }       
    }
    
    public void prepareContactMaps() {
        contactsList = [SELECT ID, HDS_Contact_Id__c, HomePhone__c, Office_Number__c, 
                            Office_Extension__c,Fax__c,Mobile_Number__c, Email__c, NRIC__c, Company_Name__c,
                            Salutation,Recipient_Number__c, Billing_Indicator__c, Recipient_Indicator__c,
                            Name, LastName,
                            Address__r.Postal_Code__r.Name,
                            Address__r.Unit_Number__c,
                            Address__r.Level_Number__c
                        FROM Contact WHERE AccountId IN :crsmAccountIDSet ];
            
        for (Contact con : contactsList) {
            if (con.HDS_Contact_Id__c!=null&&con.HDS_Contact_Id__c.trim()!='') hdsContactMap.put(con.HDS_Contact_Id__c,con);
            if (con.Recipient_Number__c!=null&&con.Recipient_Number__c>0) crsmContactNoMap.put(con.Recipient_Number__c,con);            
            String strSearchKey = con.Name + con.Address__r.Postal_Code__r.Name + con.Address__r.Unit_Number__c + con.Address__r.Level_Number__c;
            contactNameMap.put(strSearchKey,con);       
        }

    }
    
    public void prepareAddressMaps() {
        //Search Address
        addressList = [SELECT ID, Block_House_Number__c, Building_Name__c, Level_Number__c, Postal_Code__r.Name, Name, Street_Name__c, Unit_Number__c
                                FROM Address__c
                                WHERE Postal_Code__r.Name IN :crsmAccountPostalSet
                                    AND Unit_Number__c IN :crsmAccountUnitSet
                                    AND Level_Number__c IN :crsmAccountLevelSet ];
        for (Address__c addr : addressList) {
            String strAddrKey = addr.Postal_Code__r.Name + addr.Unit_Number__c + addr.Level_Number__c;
            addressMap.put(strAddrKey,addr);
        }
        
        //Create a map of Postal Codes
        postalCodeList = [SELECT ID, Name FROM Singpost_Address__c WHERE Name IN :crsmAccountPostalSet ];
        for (Singpost_Address__c saddr : postalCodeList) {
            postalCodeMap.put(saddr.Name,saddr);
        }
    }
    
    public void prepareVendorMaps() {
        //Search Vendors
        vendorsList = [SELECT ID, vendor_group__c, vendor_code__c FROM Account WHERE vendor_code__c IN :vendorNumbersSet];
        for (Account acct : vendorsList) {
            vendorsMap.put(acct.vendor_code__c,acct);
        }       
    }
    
    public void preparePublicationMaps() {
        //Search Vendors
        List<Publication__c> pubList = [SELECT Id,Publication_Code__c FROM Publication__c];
        for (Publication__c pub : pubList) {
            publicationMap.put(pub.publication_code__c,pub);
        }       
    }   
    
    public void prepareSubscriptionVendorMaps() {
        //Search subscription vendor (Using HDS Contact IDs)
        subvenList = [SELECT ID, Account__c, Vendor__c, Recipient__c, 
                            Subscription_Start_Date__c, Subscription_Stop_Date__c,
                            HDS_Subscription_Id__c 
                      FROM Subscription_Vendor__c WHERE HDS_Subscription_Id__c IN :hdsContactIdSet ];
        
        for (Subscription_Vendor__c subven : subvenList) {
            subVenMap.put(subven.HDS_Subscription_Id__c,subven);
        }
        
    }
    
    public void prepareSubscriptionVendorPublicationMaps() {
        svpList = [SELECT ID, HDS_Subscription_Id__c, Publication__c FROM Subscription_Vendor_Publication__c 
                WHERE Publication__r.Publication_Code__c IN :publicationCodeSet 
                AND Vendor_Subscription_Pub_Legacy_Id__c IN :vssSubscriptionIDSet 
                AND HDS_Subscription_Id__c IN :hdsSubscriptionIDSet ];
        
        for (Subscription_Vendor_Publication__c svpRec : svpList) {
            svpMap.put(svpRec.HDS_Subscription_Id__c,svpRec);
        }       
    }
    
    
    
    
    
    
    public void processAddressRecords(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList) {
        List<Address__c> addressForInsertList = new List<Address__c>();
    
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vSubscriberHouseBlockNumber = so.SubscriberHouseBlockNumber__c;      
            String vSubscriberLevel = so.SubscriberLevel__c;
            String vSubscriberUnit = so.SubscriberUnit__c;
            String vSubscriberPostalCode = so.SubscriberPostalCode__c;
            
            String vRecipientHouseBlockNumber = so.RecipientHouseBlockNumber__c;            
            String vRecipientLevel = so.RecipientLevel__c;
            String vRecipientUnit = so.RecipientUnit__c;
            String vRecipientPostalCode = so.RecipientPostalCode__c;

        
            String strAddrKey1 = vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
            String strAddrKey2 = vRecipientPostalCode + vRecipientUnit + vRecipientLevel;
            
            
            
            if (!addressMap.containsKey(strAddrKey1)) {
                if (postalCodeMap.containsKey(vSubscriberPostalCode)) {
                    Singpost_Address__c saddr = postalCodeMap.get(vSubscriberPostalCode);
                    Address__c billingAddress = new Address__c();
                    
                    billingAddress.Postal_Code__c = saddr.Id;
                    billingAddress.Block_House_Number__c = vSubscriberHouseBlockNumber;
                    billingAddress.Level_Number__c = vSubscriberLevel;
                    billingAddress.Unit_Number__c = vSubscriberUnit;
                    
                    addressForInsertList.add(billingAddress);
                    addressMap.put(strAddrKey1,billingAddress);
                }
            }
            
            if (!addressMap.containsKey(strAddrKey2)) {
                if (postalCodeMap.containsKey(vRecipientPostalCode)) {
                    Singpost_Address__c saddr = postalCodeMap.get(vRecipientPostalCode);
                    Address__c recipientAddress = new Address__c();
                    
                    recipientAddress.Postal_Code__c = saddr.Id;
                    recipientAddress.Block_House_Number__c = vRecipientHouseBlockNumber;
                    recipientAddress.Level_Number__c = vRecipientLevel;
                    recipientAddress.Unit_Number__c = vRecipientUnit;
                    
                    addressForInsertList.add(recipientAddress);
                    addressMap.put(strAddrKey2,recipientAddress);
                }
            }           
            
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert addressForInsertList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('VSS085DX: Address Processing Failed.');
            dmlStatus = 'Failed';
            errorMessage  = e.getMessage();
            stackTrace = e.getStackTraceString();
        }    
        
        //Repopulate the Account Maps using forInserts only for succeeding sections
        for (Address__c addr : addressForInsertList) {
            String strAddrKey = addr.Postal_Code__r.Name + addr.Unit_Number__c + addr.Level_Number__c;
            addressMap.put(strAddrKey,addr);
        }
        
    }
    
    public void processAccountRecords(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList) {    
        List<Account> accountsForInsert = new List<Account>();
        List<Account> accountsForUpdate = new List<Account>();
        Set<Account> accountsForUpdateCheck = new Set<Account>();

        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            //Objects to be created
            Account accountRecord = null;
        
            //Assign the values from so object
            //Account & Contact (Billing) Section
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vSubscriberName = so.SubscriberName__c;
            String vSubscriberStreetCode = so.SubscriberStreetCode__c;
            String vSubscriberBuildingCode = so.SubscriberBuildingCode__c;
            String vSubscriberHouseBlockNumber = so.SubscriberHouseBlockNumber__c;
            String vSubscriberLevel = so.SubscriberLevel__c;
            String vSubscriberUnit = so.SubscriberUnit__c;
            String vSubscriberPostalCode = so.SubscriberPostalCode__c;
            String vSubscriberResidentTelephoneNumber = so.SubscriberResidentTelephoneNumber__c;
            String vSubscriberOfficeTelephoneNumber = so.SubscriberOfficeTelephoneNumber__c;
            String vSubscriberOfficeTelephoneExtension = so.SubscriberOfficeTelephoneExtension__c;
            String vSubscriberFaxNumber = so.SubscriberFaxNumber__c;
            String vSubscriberHandphoneNumber = so.SubscriberHandphoneNumber__c;
            String vSubscriberEmail = so.SubscriberEmail__c;
            String vSubscriberNric = so.SubscriberNric__c;
            String vSubscriberCompanyName = so.SubscriberCompanyName__c;
            String vSubscriberSalutation = so.SubscriberSalutation__c;
            String vSubscriberUpdateIndicator = so.SubscriberUpdateIndicator__c;
            String vCrsmAccountId = so.CrsmAccountId__c;
            String vHdsComplimentaryTypeName = so.HdsComplimentaryTypeName__c;
            
            //Derive the Account Name if SubscriberName is null
            if (so.SubscriberName__c!=null&&so.SubscriberName__c.trim()!='') {
                vSubscriberName=so.SubscriberName__c;
            } else{
                vSubscriberName = 'HDS Recipient ID ' + so.HdsRecipientId__c.trim();
            }
            
            String strSearchKey = null;
            
            strSearchKey = vSubscriberName + vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
            
            //Determine if Account is already existing using Map
            if (vHdsRecipientId!=null&&vHdsRecipientId.trim()!=''&&hdsRecipientMap.containsKey(vHdsRecipientId.trim())) {
                accountRecord = hdsRecipientMap.get(vHdsRecipientId.trim());
            } else if (vCrsmAccountId!=null&&vCrsmAccountId.trim()!=''&&crsmAccountNoMap.containsKey(vCrsmAccountId.trim())) {
                accountRecord = crsmAccountNoMap.get(vHdsRecipientId.trim());
            } else if (accountNameByIDMap.containsKey(strSearchKey)) {
                if (accountNameMap.containsKey(accountNameByIDMap.get(strSearchKey))) {
                    accountRecord = accountNameMap.get(accountNameByIDMap.get(strSearchKey));
                }
            }
            
            if (accountRecord==null) {
                //Record does not exist.  Create a new one.
                System.debug('VSS085DX: adding new account into Insert List...');
                accountRecord = new Account();
                accountRecord.HDS_Recipient_Id__c = vHdsRecipientId;
                if (vSubscriberName==null||vSubscriberName=='') vSubscriberName = 'HDS Recipient ID ' + vHdsRecipientId;
                accountRecord.Name = vSubscriberName;
                accountRecord.Company_Name__c = vSubscriberCompanyName;
                accountRecord.Email__c = vSubscriberEmail;
                accountRecord.NRIC__c = vSubscriberNric;
                accountRecord.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                accountRecord.Office_Number__c = vSubscriberOfficeTelephoneNumber;
                accountRecord.Phone = vSubscriberResidentTelephoneNumber;
                accountRecord.Mobile__c = vSubscriberHandphoneNumber;
                accountRecord.Handphone_Number__c = vSubscriberHandphoneNumber;
                accountRecord.Active__c = true;
                accountRecord.RecordTypeId  = ConstantsSLB.getKeyId('Vendor Subscriber');   
                accountRecord.Sub_Group__c = vHdsComplimentaryTypeName;
                accountsForInsert.add(accountRecord);               
                System.debug('VSS085DX: new account added into Insert List...');

                
                //Add this to HDSList
                //Repopulate the Account Maps using forInserts only for succeeding sections
                if (accountRecord.HDS_Recipient_Id__c!=null&&accountRecord.HDS_Recipient_Id__c.trim()!='') {
                    hdsRecipientMap.put(accountRecord.HDS_Recipient_Id__c.trim(),accountRecord);
                }           
            } else {
                if (accountRecord.Id!=null) {
                    System.debug('VSS085DX: Account Record for Update...' + accountRecord.Id);
                    if (vSubscriberUpdateIndicator.equalsIgnoreCase('N')) {
                        System.debug('VSS085DX: Account No Change');
                    } else if (vSubscriberUpdateIndicator.equalsIgnoreCase('U')) {
                        if (vSubscriberName==null||vSubscriberName=='') vSubscriberName = 'HDS Recipient ID ' + vHdsRecipientId;
                        accountRecord.Name = vSubscriberName;
                        accountRecord.Company_Name__c = vSubscriberCompanyName;
                        accountRecord.Email__c = vSubscriberEmail;
                        accountRecord.NRIC__c = vSubscriberNric;
                        accountRecord.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                        accountRecord.Office_Number__c = vSubscriberOfficeTelephoneNumber;
                        accountRecord.Phone = vSubscriberResidentTelephoneNumber;
                        accountRecord.Mobile__c = vSubscriberHandphoneNumber;
                        accountRecord.Handphone_Number__c = vSubscriberHandphoneNumber;
                
                        if (accountsForUpdateCheck.contains(accountRecord)==false) {
                            accountsForUpdate.add(accountRecord);
                            System.debug('VSS085DX: Account record added to update list...' + accountRecord.Id);
                        } else {
                            System.debug('VSS085DX: Account record will not be added to update list...' + accountRecord.Id);
                        }
                        accountsForUpdateCheck.add(accountRecord);
                        
                    }
                } else {
                    System.debug('VSS085DX: Account searched is still for insert.  Skip this record...');
                }
                
            }
        }
        
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert accountsForInsert;
            update accountsForUpdate;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('VSS085DX: Account Processing Failed.' + e.getMessage());
            dmlStatus = 'Failed';
            errorMessage  = e.getMessage();
            stackTrace = e.getStackTraceString();
        }    
        
        //Repopulate the Account Maps using forInserts only for succeeding sections
        for (Account acc : accountsForInsert) {
            if (acc.HDS_Recipient_Id__c!=null&&acc.HDS_Recipient_Id__c.trim()!='') {
                hdsRecipientMap.put(acc.HDS_Recipient_Id__c.trim(),acc);
                crsmAccountIDSet.add(acc.Id);
            }
        }
    }
    
    public void processBillingContactRecords(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList) {
        List<Contact> contactForInsert = new List<Contact>();
        List<Contact> contactForUpdate = new List<Contact>();
        Set<Contact> contactForUpdateCheck = new Set<Contact>();
        RecordType recType = null;
        
        List<RecordType> recTypeList = [SELECT ID FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Customer_Contact'];
        
        if (recTypeList.size()>0) {
            recType = recTypeList.get(0);  
        }
        
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            //Reference Objects
            Account accountRecord = null;
            
            //Objects to be created
            Contact billingContact = null;
            Contact recipientContact = null;
            Address__c billingAddress = null;
            Address__c recipientAddress = null;
            
            //Assign the values from so object
            //Account & Contact (Billing) Section
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vSubscriberName = so.SubscriberName__c;
            String vSubscriberStreetCode = so.SubscriberStreetCode__c;
            String vSubscriberBuildingCode = so.SubscriberBuildingCode__c;
            String vSubscriberHouseBlockNumber = so.SubscriberHouseBlockNumber__c;
            String vSubscriberLevel = so.SubscriberLevel__c;
            String vSubscriberUnit = so.SubscriberUnit__c;
            String vSubscriberPostalCode = so.SubscriberPostalCode__c;
            String vSubscriberResidentTelephoneNumber = so.SubscriberResidentTelephoneNumber__c;
            String vSubscriberOfficeTelephoneNumber = so.SubscriberOfficeTelephoneNumber__c;
            String vSubscriberOfficeTelephoneExtension = so.SubscriberOfficeTelephoneExtension__c;
            String vSubscriberFaxNumber = so.SubscriberFaxNumber__c;
            String vSubscriberHandphoneNumber = so.SubscriberHandphoneNumber__c;
            String vSubscriberEmail = so.SubscriberEmail__c;
            String vSubscriberNric = so.SubscriberNric__c;
            String vSubscriberCompanyName = so.SubscriberCompanyName__c;
            String vSubscriberSalutation = so.SubscriberSalutation__c;
            String vSubscriberUpdateIndicator = so.SubscriberUpdateIndicator__c;
            String vCrsmAccountId = so.CrsmAccountId__c;        
                                    
            //Contact and Vendor (Recipient)
            String vHdsContactId = so.HdsContactId__c;
            String vRecipientUpdateIndicator = so.RecipientUpdateIndicator__c;          
            String vCrsmContactId = so.CrsmContactId__c;
            
            //get the corresponding account ID from HDS Account Map
            accountRecord = hdsRecipientMap.get(vHdsRecipientId.trim());
            
            //Default contact name
            if (vSubscriberName==null||vSubscriberName=='') vSubscriberName = 'HDS Contact ID ' + vHdsContactId;
            
            //Default phone number if none is provided
            //home phone, mobile, other phone or office number
            if (vSubscriberResidentTelephoneNumber==null) {
                vSubscriberResidentTelephoneNumber = '999999999';
            }

            
            //get the billing contact
            String strSearchKey = vSubscriberName + vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
            if (hdsContactMap.containsKey(vHdsContactId.trim())) {
                billingContact = hdsContactMap.get(vHdsContactId.trim());
            } else if (contactNameMap.containsKey(strSearchKey)) {
                billingContact = contactNameMap.get(strSearchKey);
            }
            
            if (billingContact==null) {
                strSearchKey = vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
                billingAddress = addressMap.get(strSearchKey);
                
                billingContact = new Contact();
                
                billingContact.HomePhone__c = vSubscriberResidentTelephoneNumber ;
                billingContact.Office_Number__c = vSubscriberOfficeTelephoneNumber ;
                if (vSubscriberOfficeTelephoneExtension!=null&&vSubscriberOfficeTelephoneExtension!='') 
                    billingContact.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                billingContact.Fax__c = vSubscriberFaxNumber ;
                billingContact.Mobile_Number__c = vSubscriberHandphoneNumber ;
                billingContact.Email__c = vSubscriberEmail ;
                billingContact.NRIC__c = vSubscriberNric ;
                billingContact.Company_Name__c = vSubscriberCompanyName ;
                billingContact.Salutation = vSubscriberSalutation ;
                billingContact.LastName = vSubscriberName;
                billingContact.Billing_Indicator__c = TRUE;
                if (billingAddress!=null) billingContact.Address__c = billingAddress.Id;
                billingContact.HDS_Contact_Id__c = vHdsContactId;
                billingContact.AccountId  = accountRecord.Id;
                billingContact.Active__c = true;
                billingContact.RecordTypeId  = recType.Id;
                
                contactForInsert.add(billingContact);
                hdsContactMap.put(billingContact.HDS_Contact_Id__c,billingContact);     
                System.debug('VSS085DX: Billing Contact added to insert list...');
            } else {
                if (billingContact.Id!=null) {
                    billingContact.HomePhone__c = vSubscriberHandphoneNumber ;
                    billingContact.Office_Number__c = vSubscriberOfficeTelephoneNumber ;
                    if (vSubscriberOfficeTelephoneExtension!=null&&vSubscriberOfficeTelephoneExtension!='') 
                        billingContact.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                    billingContact.Fax__c = vSubscriberFaxNumber ;
                    billingContact.Mobile_Number__c = vSubscriberHandphoneNumber ;
                    billingContact.Email__c = vSubscriberEmail ;
                    billingContact.NRIC__c = vSubscriberNric ;
                    billingContact.Company_Name__c = vSubscriberCompanyName ;
                    billingContact.Salutation = vSubscriberSalutation ;
                    billingContact.LastName = vSubscriberName;
                    billingContact.Billing_Indicator__c = TRUE;
                    if (billingAddress!=null) billingContact.Address__c = billingAddress.Id;
                    billingContact.HDS_Contact_Id__c = vHdsContactId;
                    billingContact.AccountId  = accountRecord.Id;
                
                    if (contactForUpdateCheck.contains(billingContact)==false) {
                        contactForUpdate.add(billingContact);
                        System.debug('VSS085DX: Billing Contact added to update list...' + billingContact.Id);
                    } else {
                        System.debug('VSS085DX: Billing Contact will not be added to update list...' + billingContact.Id);
                    }
                    contactForUpdateCheck.add(billingContact);
                    
                } else {
                    System.debug('VSS085DX: can not update a billing contact that is still for insert...');
                }
            
            }   
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert contactForInsert;
            update contactForUpdate;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            //Database.rollback(savepointBeforeDML);
            System.debug('VSS085DX: Contact Processing Failed.' + e.getMessage());
            dmlStatus = 'Failed';
            errorMessage  = e.getMessage();
            stackTrace = e.getStackTraceString();
        }    
        
        //Repopulate the Account Maps using forInserts only for succeeding sections
        for (Contact con : contactForInsert) {
            hdsContactMap.put(con.HDS_Contact_Id__c,con);           
        }       
    }
    
    public void processRecipientContactRecords(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList) {
        List<Contact> contactForInsert = new List<Contact>();
        List<Contact> contactForUpdate = new List<Contact>();
        Set<Contact> contactForUpdateCheck = new Set<Contact>();
        RecordType recType = null;
        
        List<RecordType> recTypeList = [SELECT ID FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Recipient_Contact'];
        
        if (recTypeList.size()>0) {
            recType = recTypeList.get(0);  
        }
        
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            //Reference Objects
            Account accountRecord = null;
            
            //Objects to be created
            Contact recipientContact = null;
            Address__c recipientAddress = null;
            
            //Assign the values from so object
            //Account & Contact (Billing) Section
            String vHdsRecipientId = so.HdsRecipientId__c;          
            
            //Contact and Vendor (Recipient)
            String vHdsContactId = so.HdsContactId__c;
            String vRecipientName = so.RecipientName__c;
            String vRecipientStreetCode = so.RecipientStreetCode__c;
            String vRecipientBuildingCode = so.RecipientBuildingCode__c;
            String vRecipientHouseBlockNumber = so.RecipientHouseBlockNumber__c;
            String vRecipientLevel = so.RecipientLevel__c;
            String vRecipientUnit = so.RecipientUnit__c;
            String vRecipientPostalCode = so.RecipientPostalCode__c;
            String vRecipientResidenceTelephoneNumber = so.RecipientResidenceTelephoneNumber__c;
            String vRecipientOfficeTelephoneNumber = so.RecipientResidenceTelephoneNumber__c;
            String vRecipientOfficeTelephoneExtension = so.RecipientOfficeTelephoneExtension__c;
            String vRecipientFaxNumber = so.RecipientFaxNumber__c;
            String vRecipientHandphoneNumber = so.RecipientHandphoneNumber__c;
            String vRecipientEmail = so.RecipientEmail__c;
            String vRecipientNric = so.RecipientNric__c;
            String vRecipientCompanyName = so.RecipientCompanyName__c;
            String vVendorGroup = so.VendorGroup__c;
            String vVendorNumber = so.VendorNumber__c;
            String vRecipientSalutation = so.RecipientSalutation__c;
            String vRecipientUpdateIndicator = so.RecipientUpdateIndicator__c;          
            String vCrsmContactId = so.CrsmContactId__c;
            
            //get the corresponding account ID from HDS Account Map
            accountRecord = hdsRecipientMap.get(vHdsRecipientId.trim());
            
            //Default contact name
            if (vRecipientName==null||vRecipientName=='') vRecipientName = 'HDS Contact ID ' + vHdsContactId;
            
            //Default phone number if none is provided
            if (vRecipientResidenceTelephoneNumber==null) {
                vRecipientResidenceTelephoneNumber = '999999999';
            }
                    
            
            //get the recipient contact
            String strSearchKey = vRecipientName + vRecipientPostalCode + vRecipientUnit + vRecipientLevel;         
            if (hdsContactMap.containsKey(vHdsContactId.trim())) {
                recipientContact = hdsContactMap.get(vHdsContactId.trim());
            } else if (contactNameMap.containsKey(strSearchKey)) {
                recipientContact = contactNameMap.get(strSearchKey);
            }
            
            
            if (recipientContact==null) {
                System.debug('VSS085DX: Recipient Contact create new record');
                strSearchKey = vRecipientPostalCode + vRecipientUnit + vRecipientLevel;
                recipientAddress = addressMap.get(strSearchKey);
        
                recipientContact = new Contact();                
                recipientContact.HomePhone__c = vRecipientResidenceTelephoneNumber  ;
                recipientContact.Office_Number__c = vRecipientOfficeTelephoneNumber  ;
                if (vRecipientOfficeTelephoneExtension!=null&&vRecipientOfficeTelephoneExtension!='')
                    recipientContact.Office_Extension__c = vRecipientOfficeTelephoneExtension;
                recipientContact.Fax__c = vRecipientFaxNumber  ;
                recipientContact.Mobile_Number__c = vRecipientHandphoneNumber  ;
                recipientContact.Email__c = vRecipientEmail  ;
                recipientContact.NRIC__c = vRecipientNric  ;
                recipientContact.Company_Name__c = vRecipientCompanyName  ;
                recipientContact.Salutation = vRecipientSalutation  ;
                if (vRecipientName==null||vRecipientName=='') vRecipientName = 'HDS Contact ID ' + vHdsContactId;
                recipientContact.LastName = vRecipientName;
                recipientContact.Recipient_Indicator__c = TRUE;
                if (recipientAddress!=null) recipientContact.Address__c = recipientAddress.Id;
                recipientContact.HDS_Contact_Id__c = vHdsContactId;
                recipientContact.AccountId  = accountRecord.Id;
                recipientContact.Active__c = true;  
                recipientContact.recordTypeId = recType.Id;

                contactForInsert.add(recipientContact);
                hdsContactMap.put(recipientContact.HDS_Contact_Id__c,recipientContact);
                System.debug('VSS085DX: Recipient Contact new record added to insert list.');
                
            } else {            
                if (recipientContact.Id!=null) {
                    recipientContact.HomePhone__c = vRecipientResidenceTelephoneNumber  ;
                    recipientContact.Office_Number__c = vRecipientOfficeTelephoneNumber  ;
                    if (vRecipientOfficeTelephoneExtension!=null&&vRecipientOfficeTelephoneExtension!='')
                        recipientContact.Office_Extension__c = vRecipientOfficeTelephoneExtension;
                    recipientContact.Fax__c = vRecipientFaxNumber  ;
                    recipientContact.Mobile_Number__c = vRecipientHandphoneNumber  ;
                    recipientContact.Email__c = vRecipientEmail  ;
                    recipientContact.NRIC__c = vRecipientNric  ;
                    recipientContact.Company_Name__c = vRecipientCompanyName  ;
                    recipientContact.Salutation = vRecipientSalutation  ;
                    if (vRecipientName==null||vRecipientName=='') vRecipientName = 'HDS Contact ID ' + vHdsContactId;
                    recipientContact.LastName = vRecipientName;
                    recipientContact.Recipient_Indicator__c = TRUE;
                    if (recipientAddress!=null) recipientContact.Address__c = recipientAddress.Id;
                    recipientContact.HDS_Contact_Id__c = vHdsContactId;
                    recipientContact.AccountId  = accountRecord.Id;
                    
                    if(contactForUpdateCheck.contains(recipientContact)==false) {
                        contactForUpdate.add(recipientContact);
                        System.debug('VSS085DX: Recipient Contact added to update list...' + recipientContact.Id);
                    } else {
                        System.debug('VSS085DX: Recipient Contact will not be added to update list...' + recipientContact.Id);
                    }
                    contactForUpdateCheck.add(recipientContact);
                
                } else{
                    System.debug('VSS085DX: can not update a recipient contact that is still for insert...');
                }
            }           
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert contactForInsert;
            update contactForUpdate;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            //database.rollback(savepointBeforeDML);
            System.debug('VSS085DX: Contact Processing Failed.' + e.getMessage());
            dmlStatus = 'Failed';
            errorMessage  = e.getMessage();
            stackTrace = e.getStackTraceString();
        }    
        
        //Repopulate the Account Maps using forInserts only for succeeding sections
        for (Contact con : contactForInsert) {
            hdsContactMap.put(con.HDS_Contact_Id__c,con);
        }
        
        
    }   

    public void processSubscriptionVendorRecords(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList) {
        List<Subscription_Vendor__c> subvenForInsert = new List<Subscription_Vendor__c>();
        List<Subscription_Vendor__c> subvenForUpdate = new List<Subscription_Vendor__c>();
        Set<Subscription_Vendor__c> subvenForUpdateCheck = new Set<Subscription_Vendor__c>();
        List<Subscription_Vendor_Publication__c> subvenPubForInsert = new List<Subscription_Vendor_Publication__c>();
        List<Subscription_Vendor_Publication__c> subvenPubForUpdate = new List<Subscription_Vendor_Publication__c>();
        List<Order__c> ordersList = new List<Order__c>();
        List<Order_Line_Item_Vendor__c> orderLinesList = new List<Order_Line_Item_Vendor__c>();
        Map<String,Order__c> ordersMap = new Map<String,Order__c>();
        
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {   
            //Reference Objects
            Account accountRecord = null;
            Account vendorRecord = null;
            Contact recipientContact = null;
            Subscription_Vendor__c subVendor = null;
            Publication__c publication = null;
            Subscription_Vendor_Publication__c svpRec = null;
        
            //Others
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vHdsContactId = so.HdsContactId__c;
            String vVendorGroup = so.VendorGroup__c;
            String vVendorNumber = so.VendorNumber__c;

            //Subscription and Subscription Vendor Publication section
            String vHdsSubscriptionId = so.HdsSubscriptionId__c;
            String vPublicationCode = so.PublicationCode__c;
            String vSubscriptionCopies = so.SubscriptionCopies__c;
            String vStartDate = so.StartDate__c;
            String vStopDate = so.StopDate__c;
            String vSubscriptionPeriod = so.SubscriptionPeriod__c;
            String vSubscriptionUpdateIndicator = so.SubscriptionUpdateIndicator__c;
            String vHdsClassificationId = so.HdsClassificationId__c;
            String vHdsComplimentaryTypeName = so.HdsComplimentaryTypeName__c;
            String vCrsmAccountId = so.CrsmAccountId__c;
            String vCrsmContactId = so.CrsmAccountId__c;
            String vCrsmVendorSubscriptionId = so.CrsmVendorSubscriptionId__c;
            
            if (hdsRecipientMap.containsKey(vHdsRecipientId)) {
                accountRecord = hdsRecipientMap.get(vHdsRecipientId);
                System.debug('VSS085DX: Subscription Vendor - account record detected.');
            } else {
                System.debug('VSS085DX: Subscription Vendor - account record not detected.');
            }
            
            if (vendorsMap.containsKey(vVendorNumber)) {
                vendorRecord = vendorsMap.get(vVendorNumber);
                System.debug('VSS085DX: Subscription Vendor - vendor detected.');
            } else {
                System.debug('VSS085DX: Subscription Vendor - vendor not detected.');
            }
            
            if (hdsContactMap.containsKey(vHdsContactId)) {
                recipientContact = hdsContactMap.get(vHdsContactId);
                System.debug('VSS085DX: Subscription Vendor - recipient contact detected.');
            } else {
                System.debug('VSS085DX: Subscription Vendor - recipient contact not detected.');
            }
            
            if (publicationMap.containsKey(vPublicationCode)) {
                publication = publicationMap.get(vPublicationCode);
                System.debug('VSS085DX: Subscription Vendor - publication detected.');
            } else {
                System.debug('VSS085DX: Subscription Vendor - publication not detected.');
            }

            if (accountRecord!=null&&vendorRecord!=null&&recipientContact!=null&&publication!=null) {
            
                //---------------------------------------------------------------------------------------------
                //SUBSCRIPTION VENDOR
                //---------------------------------------------------------------------------------------------
                if (subVenMap.containsKey(vHdsContactId.trim())) {   //Use Contact ID to retrieve the account
                    subVendor = subVenMap.get(vHdsContactId.trim());
                    System.debug('VSS085DX: Subscription Vendor - existing subscription vendor detected.' + subVendor.HDS_Subscription_Id__c);
                } else {
                    System.debug('VSS085DX: Subscription Vendor - no existing sub vendor detected.');
                }
                
                
                
                if (subVendor==null) {              
                    //Create new Subscription_Vendor__c
                    subVendor = new Subscription_Vendor__c();
                    subVendor.Account__c = accountRecord.Id;
                    subVendor.Vendor__c = vendorRecord.Id;
                    subVendor.Recipient__c = recipientContact.Id;
                    subVendor.HDS_Subscription_Id__c = vHdsContactId.trim();  //Use Contact ID instead of HDS Subscription ID to group the records                  
                    if (vStartDate!=null&&vStartDate.trim()!='') subVendor.Subscription_Start_Date__c = DateUtility.convertDate(vStartDate,'\\.','DMY');
                    if (vStopDate!=null&&vStopDate.trim()!='') subVendor.Subscription_Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');                                        
                    if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('D')) {
                        subVendor.Status__c = 'Inactive';
                    } else {
                        subVendor.Status__c = 'Active';
                    }
                    subvenForInsert.add(subVendor);
                    subVenMap.put(subVendor.HDS_Subscription_Id__c,subVendor);
                    System.debug('VSS085DX: Subscription Vendor - new Subscription Vendor added to insert list.');                                      
                    
                    
                    //Create Order__c
                    Order__c newOrder = new Order__c();                 
                    newOrder.Account__c = accountRecord.Id;
                    if (vStartDate!=null&&vStartDate.trim()!='') newOrder.DTL_Date__c = DateUtility.convertDate(vStartDate,'\\.','DMY');
                    newOrder.Recipient_Contact__c = recipientContact.Id;
                    newOrder.Status__c = 'New';
                    newOrder.Delivery_Charge__c = 0.0;
                    newOrder.Reason__c = vHdsContactId;
                    newOrder.Credit_Balance__c = 0.0;
                    
                    ordersList.add(newOrder);
                    System.debug('VSS085DX: Order - new record added to insert list...');
                    
                } else {
                    //Update existing Subscription_Vendor__c                    
                    System.debug('VSS085DX: Subscription Vendor for Update...');
                    if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('P')) {
                        //  Update Subscription Stop Date
                        if (vStopDate!=null&&vStopDate.trim()!='') subVendor.Subscription_Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');                        
                        subvenForUpdate.add(subVendor);
                        System.debug('VSS085DX: Subscription Vendor - P Indicator.');
                    } else if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('D')) {
                        //  Stop Subscription
                        if (vStopDate!=null&&vStopDate.trim()!='') subVendor.Subscription_Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');
                        subVendor.Status__c = 'Inactive';
                        subvenForUpdate.add(subVendor);
                        System.debug('VSS085DX: Subscription Vendor - D Indicator.');
                    } else if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('V')) {
                        // Change of Vendor
                        subVendor.Vendor__c = vendorRecord.Id;
                        subvenForUpdate.add(subVendor);
                        System.debug('VSS085DX: Subscription Vendor - V Indicator.');
                    } else if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('R')) {
                        // Reactivate Subscription
                        subVendor.Subscription_Stop_Date__c = null;
                        subVendor.Status__c = 'Active';
                        subvenForUpdate.add(subVendor);
                        System.debug('VSS085DX: Subscription Vendor - R Indicator.');
                    }
                    
                }
            
            
                //---------------------------------------------------------------------------------------------
                //SUBSCRIPTION VENDOR PUBLICATION
                //---------------------------------------------------------------------------------------------
                if (svpMap.containsKey(vHdsSubscriptionId.trim())) {   //Use Contact ID to retrieve the account
                    svpRec = svpMap.get(vHdsSubscriptionId.trim());
                    System.debug('VSS085DX: Subscription Vendor Publication - existing svp detected.' + svpRec.HDS_Subscription_Id__c);
                } else {
                    System.debug('VSS085DX: Subscription Vendor Publication - no existing svp detected.');
                }
            
                if (svpRec==null) {
                    svpRec = new Subscription_Vendor_Publication__c();
                    
                    svpRec.Account__c = accountRecord.Id;
                    svpRec.Publication__c = publication.Id;
                    svpRec.HDS_Subscription_Id__c = vHdsSubscriptionId;
                    svpRec.Reason__c = vHdsContactId;

                    Decimal vMon = null;
                    Decimal vTue = null;
                    Decimal vWed = null;
                    Decimal vThu = null;
                    Decimal vFri = null;
                    Decimal vSat = null;
                    Decimal vSun = null;
                    Decimal vPHd = null;
                    Decimal vPHe = null;
                        
                    try {
                        vMon = Decimal.valueOf(vSubscriptionCopies.subString(0,3));
                        vTue = Decimal.valueOf(vSubscriptionCopies.subString(3,6));
                        vWed = Decimal.valueOf(vSubscriptionCopies.subString(6,9));
                        vThu = Decimal.valueOf(vSubscriptionCopies.subString(9,12));
                        vFri = Decimal.valueOf(vSubscriptionCopies.subString(12,15));
                        vSat = Decimal.valueOf(vSubscriptionCopies.subString(15,18));
                        vSun = Decimal.valueOf(vSubscriptionCopies.subString(18,21));
                        vPHd = Decimal.valueOf(vSubscriptionCopies.subString(21,24));
                        vPHe = Decimal.valueOf(vSubscriptionCopies.subString(24,26));
                        
                        svpRec.Mon__c = vMon;
                        svpRec.Tue__c = vTue;
                        svpRec.Wed__c = vWed;
                        svpRec.Thu__c = vThu;
                        svpRec.Fri__c = vFri;
                        svpRec.Sat__c = vSat;
                        svpRec.Sun__c = vSun;
                        svpRec.PHd__c = vPHd;
                        svpRec.PHe__c = vPHe;
                    } catch (Exception e) {
                        System.debug('VSS085DX: Order - Exception' + e.getMessage());
                    }
                    //svpRec.Order__c
                        
                                        
                    subvenPubForInsert.add(svpRec);
                    System.debug('VSS085DX: Subscription Vendor Publication - new record added to insert list...');
                    
                    
                    //Create Order Line Items
                    Order_Line_Item_Vendor__c orderLine = new Order_Line_Item_Vendor__c();
                    //orderLine.Order__c
                    if (vStartDate!=null&&vStartDate.trim()!='') orderLine.DTL_Date__c = DateUtility.convertDate(vStartDate,'\\.','DMY');
                    if (vStartDate!=null&&vStartDate.trim()!='') orderLine.Start_Date__c = DateUtility.convertDate(vStartDate,'\\.','DMY');
                    if (vStopDate!=null&&vStopDate.trim()!='') orderLine.Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');                     
                    orderLine.Vendor__c = vendorRecord.Id;
                    orderLine.Reason__c = vHdsContactId;
                    orderLine.Publication__c = publication.Id;
                    
                    try {
                        orderLine.Mon__c = vMon;
                        orderLine.Tue__c = vTue;
                        orderLine.Wed__c = vWed;
                        orderLine.Thu__c = vThu;
                        orderLine.Fri__c = vFri;
                        orderLine.Sat__c = vSat;
                        orderLine.Sun__c = vSun;
                        orderLine.PHd__c = vPHd;
                        orderLine.PHe__c = vPHe;
                    } catch (Exception e) {
                        System.debug('VSS085DX: Order Line Item - Exception' + e.getMessage());
                    }
                    
                    orderLinesList.add(orderLine);
                    System.debug('VSS085DX: Order Line Item - new record added to insert list...');
                } else {
                    System.debug('VSS085DX: Subscription Vendor Publication - Update section.');
                    if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('U')) {
                        //Update the Subscription Copies
                        try {
                            String vMon = vSubscriptionCopies.subString(0,3);
                            String vTue = vSubscriptionCopies.subString(3,6);
                            String vWed = vSubscriptionCopies.subString(6,9);
                            String vThu = vSubscriptionCopies.subString(9,12);
                            String vFri = vSubscriptionCopies.subString(12,15);
                            String vSat = vSubscriptionCopies.subString(15,18);
                            String vSun = vSubscriptionCopies.subString(18,21);
                            String vPHd = vSubscriptionCopies.subString(21,24);
                            String vPHe = vSubscriptionCopies.subString(24,26);
                            
                            svpRec.Mon__c = Decimal.valueOf(vMon);
                            svpRec.Tue__c = Decimal.valueOf(vTue);
                            svpRec.Wed__c = Decimal.valueOf(vWed);
                            svpRec.Thu__c = Decimal.valueOf(vThu);
                            svpRec.Fri__c = Decimal.valueOf(vFri);
                            svpRec.Sat__c = Decimal.valueOf(vSat);
                            svpRec.Sun__c = Decimal.valueOf(vSun);
                            svpRec.PHd__c = Decimal.valueOf(vPHd);
                            svpRec.PHe__c = Decimal.valueOf(vPHe);
                        } catch (Exception e) {
                        
                        }
                        
                        subvenPubForUpdate.add(svpRec);
                        System.debug('VSS085DX: Subscription Vendor Publication - U Indicator.');
                    }
                
                
                    
                }
            
            } else {
                System.debug('VSS085DX: Subscription Vendor can not be created.  One of the required record is missing. e.g account, contact, vendor');
            }
            
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert subvenForInsert;
            update subvenForUpdate;                 
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            //Database.rollback(savepointBeforeDML);
            System.debug('VSS085DX: Subscription Vendor Processing Failed.' + e.getMessage());
            dmlStatus = 'Failed';
            errorMessage  = e.getMessage();
            stackTrace = e.getStackTraceString();
        }    
        
        //Insert orders List
        try {insert ordersList; } catch (Exception e) {System.debug('VSS085DX: Order Processing Failed.' + e.getMessage());  }
        
        //Repopulate the Account Maps using forInserts only for succeeding sections
        for (Subscription_Vendor__c subVendor : subvenForInsert) {      
            subVenMap.put(subVendor.HDS_Subscription_Id__c,subVendor);
        }

        for (Order__c orderRec : ordersList) {      
            ordersMap.put(orderRec.Reason__c,orderRec);
            System.debug('VSS085DX: Creating orders Map using HDS Contact ID');
            orderRec.Reason__c = '';            
        }
        try {update ordersList; } catch (Exception e) {System.debug('VSS085DX: Order Processing Failed.' + e.getMessage());  }
        
        
        try 
        {
            for (Order_Line_Item_Vendor__c orderLineRec :orderLinesList) {
                if (ordersMap.containsKey(orderLineRec.Reason__c)) {
                    Order__c order1 = ordersMap.get(orderLineRec.Reason__c);
                    orderLineRec.Order__c = order1.Id;
                    orderLineRec.Reason__c = '';
                }
            }           
            
            for (Subscription_Vendor_Publication__c svp : subvenPubForInsert) {
                
                if (subVenMap.containsKey(svp.Reason__c)) {         
                    Subscription_Vendor__c  subVenRec = subVenMap.get(svp.Reason__c);               
                    svp.Subscription_Vendor__c = subVenRec.Id;                  
                }
                
                if (ordersMap.containsKey(svp.Reason__c)) {
                    Order__c order1 = ordersMap.get(svp.Reason__c);
                    svp.Order__c = order1.Id;
                }
                
                svp.Reason__c = '';
            }
                
            insert subvenPubForInsert;
            update subvenPubForUpdate;
        
        } catch(Exception e) {
            //Database.rollback(savepointBeforeDML);
            System.debug('VSS085DX: Subscription Vendor Processing Failed.' + e.getMessage());
            dmlStatus = 'Failed';
            errorMessage  = e.getMessage();
            stackTrace = e.getStackTraceString();       
        }
        
        try {insert orderLinesList; } catch (Exception e) {System.debug('VSS085DX: Order Line Item Processing Failed.' + e.getMessage()); }
    }
    
    

    
    
}