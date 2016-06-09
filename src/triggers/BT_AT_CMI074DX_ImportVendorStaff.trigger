/**
 * Trigger Name: BT_AT_CMI074DX_ImportVendorStaff
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI074DX Interface
 * Description: This trigger contains the business logic for CMI074DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
            09/18/2014 Kevin Evasco Updated to implement business logic
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)			
 *          2015/02/17 Renino Niefes D-2253  Add missing validations
 */

trigger BT_AT_CMI074DX_ImportVendorStaff on BT_CO_CMISPOP_ImportVendorStaff__c (before insert, before update) 
{
    
    List<BT_CO_CMISPOP_ImportVendorStaff__c> recordsList = trigger.new;
        
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    

	//[START 02/16/2015 Renino Niefes D-2253]  Add missing validations    
    List<Contact> contactsForInsert = new List<Contact>();      
	List<Contact> contactsForUpdate = new List<Contact>();      
    List<Account> existingAccountsList = new List<Account>();
	List<Contact> existingContactsList = new List<Contact>();
    
    Set<String> inputVendorCodeSet = new Set<String>();
    Set<String> validVendorCodeSet = new Set<String>();
    
    Map<String,Account> vendorCode_account_Map = new Map<String,Account>();
    Map<String,Contact> vendorCode_contact_Map = new Map<String,Contact>();
	
    for(BT_CO_CMISPOP_ImportVendorStaff__c so : recordsList)
    {    
		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if(so.vendorCode__c!=null) inputVendorCodeSet.add(so.vendorCode__c);
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
    
	
    existingAccountsList = [SELECT Id, Vendor_Code__c FROM Account WHERE Vendor_Code__c IN :inputVendorCodeSet];
	existingContactsList = [SELECT ID,Account.Vendor_Code__c,AccountId,Name,LastName,Phone FROM Contact WHERE Account.Vendor_Code__c IN :inputVendorCodeSet];	
	
    for(Account accountRecord : existingAccountsList)
    {
		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if (accountRecord.Vendor_Code__c!=null) vendorCode_account_Map.put(accountRecord.Vendor_Code__c,accountRecord);        
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
	
    for(Contact contactRecord : existingContactsList)
    {
		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if (contactRecord.Account.Vendor_Code__c!=null&&contactRecord.Name!=null) vendorCode_contact_Map.put(contactRecord.Account.Vendor_Code__c + contactRecord.Name,contactRecord);        
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
	
    //[END 02/16/2015 Renino Niefes D-2253]  Add missing validations
	
    // Validation
    for(BT_CO_CMISPOP_ImportVendorStaff__c so : recordsList)
    {    
        Boolean isValid = true;
        String validationDetails = '';
        
        if(vendorCode_account_Map.get(so.vendorCode__c) == null)
        {
            validationDetails += 'Vendor Code does not exist in Salesforce Account records. ';
            isValid = false;
        }
		//[START 02/16/2015 Renino Niefes D-2253]  Add missing validations
        if(so.fullName__c == null||so.fullName__c=='')
        {
            validationDetails += 'Full Name is a mandatory field. ';
            isValid = false;
        }        
        if(so.telephoneNumber__c == null||so.telephoneNumber__c=='')
        {
            validationDetails += 'Telephone is a mandatory field. ';
            isValid = false;
        }        
		//[END 02/16/2015 Renino Niefes D-2253]  Add missing validations
		
        if(isValid)
        {  
			//[START 02/16/2015 Renino Niefes D-2253] Set the type of transaction
			so.Validation_Status__c = 'Passed';
			if (vendorCode_contact_Map.containsKey(so.vendorCode__c + so.fullName__c)) {
				Contact oldContact = vendorCode_contact_Map.get(so.vendorCode__c + so.fullName__c);
				oldContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
				oldContact.AccountId = vendorCode_account_Map.get(so.vendorCode__c).Id;
				oldContact.LastName = so.fullName__c;
				oldContact.HomePhone__c = so.telephoneNumber__c;
				//so.pagerNumber__c;
				oldContact.Active__c = true;
            
				so.Name = 'FOR UPDATE';
			
				contactsForUpdate.add(oldContact);         				
			} else {				
				Contact newContact = new Contact();
				newContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
				newContact.AccountId = vendorCode_account_Map.get(so.vendorCode__c).Id;
				newContact.LastName = so.fullName__c;
				newContact.HomePhone__c = so.telephoneNumber__c;
				//so.pagerNumber__c;
				newContact.Active__c = true;
            

				so.Name = 'FOR INSERT';
			
				contactsForInsert.add(newContact);         
            }
				//[END 02/16/2015 Renino Niefes D-2253]
        }
        else
        {        
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }
    }   
        
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
		//[START 02/16/2015 Renino Niefes D-2253] added records for update transaction
        insert contactsForInsert;
		update contactsForUpdate;
		//[END 02/16/2015 Renino Niefes D-2253]
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_CMI074DX_ImportVendorStaff Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }    
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI074DX';
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