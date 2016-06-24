/**
 * Trigger Name: BT_AT_CMI073DX_ImportVendorProfile
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI073DX Interface
 * Description: This trigger contains the business logic for CMI073DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
            09/18/2014 Kevin Evasco Updated to implement business logic
 * History: 02/11/2015 Renino Niefes Changed the operator from || to && for Fax Number field.  Added try catch block to trap the error
 * History: 02/13-16/2015 Renino Niefes Added format validation for Email and NRIC fields
 */

trigger BT_AT_CMI073DX_ImportVendorProfile on BT_CO_CMISPOP_ImportVendorProfile__c (before insert, before update) 
{
    
    List<BT_CO_CMISPOP_ImportVendorProfile__c> recordsList = trigger.new;   
    
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';
    //[START D-2021 Renz 2015-02-16] Add new variables for nric and email patterns
    String emailRegex = '^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$';
    String nricRegex = '^[S,F,T,G]\\d{7}[A-Z]$';
    //[END D-2021 Renz 2015-02-16] Add new variables for nric and email patterns
    List<Account> accountsForInsert = new List<Account>();
    List<Account> accountsForUpdate = new List<Account>();
    List<Contact> contactsForInsert = new List<Contact>();
    List<Singpost_Address__c> singpostAddressList;
    
    Set<String> inputVendorCodeSet = new Set<String>();
    Set<String> newVendorCodeSet = new Set<String>();
    Set<String> postalCodeSet = new Set<String>();
    

    
    Map<String,BT_CO_CMISPOP_ImportVendorProfile__c> vendorCode_SO_Map = new Map<String,BT_CO_CMISPOP_ImportVendorProfile__c>();
    Map<String,Singpost_Address__c> postalCode_singpostAddress_Map = new Map<String,Singpost_Address__c>();
    
    for(BT_CO_CMISPOP_ImportVendorProfile__c so : recordsList)
    {
        postalCodeSet.add(so.postalCode__c);
    }
    
    singpostAddressList = [SELECT Id, Name FROM Singpost_Address__c WHERE Name IN :postalCodeSet];
    for(Singpost_Address__c singpostAddress : singpostAddressList)
    {
        postalCode_singpostAddress_Map.put(singpostAddress.Name, singpostAddress);
    }
    
    // Validation
    for(BT_CO_CMISPOP_ImportVendorProfile__c so : recordsList)
    {
        Boolean isValid = true;
        String validationDetails = '';
        
        if(so.vendorName__c == null || so.vendorName__c == '')
        {        
            validationDetails += 'Vendor Name is Blank. ';
            isValid = false;
        }        
        if(postalCode_singpostAddress_Map.get(so.postalCode__c) == null)
        {
            validationDetails += 'Postal Code does not exist in Salesforce Singpost Address records. ';
            isValid = false;
        }
        //[START 2015-02-13 Renz D-2021] Added NRIC and EMail Address Validation
        if(so.nricPassport__c != null && so.nricPassport__c != '')
        {        
            if(!Pattern.matches(nricRegex, so.nricPassport__c)) {
                validationDetails += 'Invalid NRIC Format. ';
                isValid = false;
            }
        }               
        if(so.email__c != null && so.email__c != '')
        {        
            if(!Pattern.matches(emailRegex, so.email__c)) {
                validationDetails += 'Invalid Email Address. ';
                isValid = false;
            }
        }               
        //[END 2015-02-13 Renz D-2021] Added NRIC and EMail Address Validation
        
        if(isValid)
        {             
            postalCodeSet.add(so.postalCode__c);
            inputVendorCodeSet.add(so.vendorCode__c);
            vendorCode_SO_Map.put(so.vendorCode__c, so);
            so.Validation_Status__c = 'Passed';
        }
        else
        {        
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }
    }
    
    
    
    newVendorCodeSet.addAll(inputVendorCodeSet);
    //Nitin Khanna : 12-october-2015 : Hotfix : UD-3060 : adding name to the query, the fix requires the account name to be updated with the vendor name : START
    //accountsForUpdate = [SELECT Id, Vendor_Code__c, Vendor_Group__c, Zone_Code__c, Vendor_Name__c, Vendor_Type__c, NRIC__c, Registered_Name__c, Unit_Number__c, Level_Number__c, House_Block_Number__c, Street_Name__c, Building_Name__c, Singpost_Address__c, Telephone_Number_1__c, Telephone_Office__c, Handphone_Number__c, Telefax_Number__c, Email__c, GST_Registration_Number__c, Active__c FROM Account WHERE Vendor_Code__c IN :inputVendorCodeSet];    \
    accountsForUpdate = [SELECT Id, name, Vendor_Code__c, Vendor_Group__c, Zone_Code__c, Vendor_Name__c, Vendor_Type__c, NRIC__c, Registered_Name__c, Unit_Number__c, Level_Number__c, House_Block_Number__c, Street_Name__c, Building_Name__c, Singpost_Address__c, Telephone_Number_1__c, Telephone_Office__c, Handphone_Number__c, Telefax_Number__c, Email__c, GST_Registration_Number__c, Active__c FROM Account WHERE Vendor_Code__c IN :inputVendorCodeSet];    
    //Nitin Khanna : 12-october-2015 : Hotfix : UD-3060 : adding name to the query, the fix requires the account name to be updated with the vendor name : END
    
    for(Account acc : accountsForUpdate)
    {
        newVendorCodeSet.remove(acc.Vendor_Code__c);
        
        BT_CO_CMISPOP_ImportVendorProfile__c so = vendorCode_SO_Map.get(acc.Vendor_Code__c);
        //[START 2015-02-11 Renz D-2021] Added operation type in Name field and add missing fields
        so.Name = 'FOR UPDATE';
        

        acc.Vendor_Code__c = so.vendorCode__c;
        acc.Vendor_Group__c = so.vendorGroup__c;
        acc.Zone_Code__c = so.zoneCode__c;
        acc.Vendor_Name__c = so.vendorName__c;
        
        //Nitin Khanna : 12-october-2015 : Hotfix : UD-3060 : adding name to the query, the fix requires the account name to be updated with the vendor name : START
        acc.name = so.vendorName__c;
        //Nitin Khanna : 12-october-2015 : Hotfix : UD-3060 : adding name to the query, the fix requires the account name to be updated with the vendor name : END
        
        acc.Vendor_Type__c = so.vendorType__c;
        acc.NRIC__c = so.nricPassport__c;
        acc.Registered_Name__c = so.registeredName__c;
        acc.Unit_Number__c = so.unitNumber__c;
        acc.Level_Number__c = so.level__c;
        acc.House_Block_Number__c = so.blockHouseNumber__c;
        acc.Street_Name__c = so.streetName__c;
        acc.Building_Name__c = so.buildingName__c;
        acc.Singpost_Address__c = postalCode_singpostAddress_Map.get(so.postalCode__c).Id;
        acc.PostalCode__c = so.postalCode__c;
        acc.Telephone_Residence__c = so.telephoneResidence__c;
        acc.Telephone_Office__c = so.telephoneOffice__c;
        //acc.Pager_Number__c = so.pagerNumber__c;
        acc.Handphone_Number__c = so.handphoneNumber__c;
        //[START 2015-02-11 Renz D-2021] Changed the operator from || to &&.  Added try catch block.  Added missing fields 
        if (so.faxNumber__c!=null && so.faxNumber__c!='') {
            try {
                acc.Telefax_Number__c = Decimal.valueOf(so.faxNumber__c);
            } catch (Exception e) {
            
            }
        }  
        //[END 2015-02-11 Renz D-2021]

        if (so.vendorStatus__c.equalsIgnoreCase('Y')) {
            acc.Status__c = 'Active';
            acc.Active__c = true;
        } else {
            acc.Status__c = 'Inactive';
            acc.Active__c = false;
        }
        //[END 2015-02-11 Renz D-2021]
        
        acc.Email__c = so.email__c;
        acc.GST_Registration_Number__c = so.gstRegistrationNumber__c;
    }
    
    for(String newVendorCode : newVendorCodeSet)
    {
        BT_CO_CMISPOP_ImportVendorProfile__c so = vendorCode_SO_Map.get(newVendorCode);
        //[START 2015-02-11 Renz D-2021] Added operation type in Name field and add missing fields
        so.Name = 'FOR INSERT';
                
        Account newAccount = new Account();
        newAccount.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        newAccount.Name = so.vendorName__c;
        newAccount.Vendor_Code__c = so.vendorCode__c;
        newAccount.Vendor_Group__c = so.vendorGroup__c;
        newAccount.Zone_Code__c = so.zoneCode__c;
        newAccount.Vendor_Name__c = so.vendorName__c;
        newAccount.Vendor_Type__c = so.vendorType__c;
        newAccount.NRIC__c = so.nricPassport__c;
        newAccount.Registered_Name__c = so.registeredName__c;
        newAccount.Unit_Number__c = so.unitNumber__c;
        newAccount.Level_Number__c = so.level__c;
        newAccount.House_Block_Number__c = so.blockHouseNumber__c;
        newAccount.Street_Name__c = so.streetName__c;
        newAccount.Building_Name__c = so.buildingName__c;
        newAccount.Singpost_Address__c = postalCode_singpostAddress_Map.get(so.postalCode__c).Id;
        newAccount.PostalCode__c = so.postalCode__c;
        newAccount.Telephone_Residence__c = so.telephoneResidence__c;
        newAccount.Telephone_Office__c = so.telephoneOffice__c;
        //newAccount.Pager_Number__c = so.pagerNumber__c;
        newAccount.Handphone_Number__c = so.handphoneNumber__c;
        //[END 2015-02-11 Renz D-2021]
        
        //[START 2015-02-11 Renz D-2021] Changed the operator from || to &&
        if (so.faxNumber__c!=null && so.faxNumber__c!='') {
            try {
                newAccount.Telefax_Number__c = Decimal.valueOf(so.faxNumber__c);
            } catch (Exception e) {

            }
        }
        
        if (so.vendorStatus__c.equalsIgnoreCase('Y')) {
            newAccount.Status__c = 'Active';
            newAccount.Active__c = true;
        } else {
            newAccount.Status__c = 'Inactive';
            newAccount.Active__c = false;
        }       
        //[END 2015-02-11 Renz D-2021] 
        
        newAccount.Email__c = so.email__c;
        newAccount.GST_Registration_Number__c = so.gstRegistrationNumber__c;
        
        accountsForInsert.add(newAccount);        
    }       
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        insert accountsForInsert;
        update accountsForUpdate;
        
        for(Account acc : accountsForInsert)
        {
            Contact newContact = new Contact();
            newContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Contact');
            newContact.AccountId = acc.Id;
            newContact.LastName = acc.Vendor_Name__c;
            newContact.Active__c = true;
            
            contactsForInsert.add(newContact);            
        }
        
        insert contactsForInsert;
    }
    
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_CMI073DX_ImportVendorProfile Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }   
      
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI073DX';
    leg2sfLog.Batch_Run_Date__c = recordsList[0].Batch_Run_Date__c;
    leg2sfLog.Total_Record_Count__c = recordsList.size();
    leg2sfLog.Valid_Record_Count__c = recordsList.size() - invalidRecordCount;
    leg2sfLog.Invalid_Record_Count__c = invalidRecordCount;
    leg2sfLog.DML_Status__c = dmlStatus;
    leg2sfLog.Error_Message__c = errorMessage;
    leg2sfLog.Stack_Trace__c = stackTrace;
    leg2sfLog.Batch_Job_Id__c = recordsList[0].Batch_Job_Id__c;
    
    insert leg2sfLog;
}