/**
 * Trigger Name: BT_TH_VSS085DX_ManageRecipientContacts
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/06/02 Renino Niefes added default value 9999999999 for phone number fields if blank
 * History: 2015/06/04 Renino Niefes hotfix: check if email is present
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW 
 * History: 2015/10/07 Renino Niefes UD-2898 changed the logic for managing recipient contacts for "Update" scenario  
 */
 
 
public class BT_TH_VSS085DX_ManageRecipientContacts
{   
	//START 2015/10/07 Renino Niefes UD-2898 changed the logic for managing recipient contacts for "Update" scenario  
    public void execute(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList, BT_TH_VSS085DX_ManageMaps mapManager) {
        Map<String, Account> hdsAccountsMap = null;
        Map<String, Account> crsmAccountsMap = null;
        Map<String, ID> addrAccountsMap = null;
        Map<ID, Account> accountsMap = null;
        Map<String, Address__c> addressMap = null;
        Map<String, Contact> contactsMap = null;
		Map<String, Contact> contactsMapByID = null;
        Set<String> hdsContactIDSet = new Set<String>();
        
        List<Contact> forInsertList = new List<Contact>();
        List<Contact> forUpdateList = new List<Contact>();
        
        Set<String> forInsertKeySet = new Set<String>();
        Set<ID> forUpdateKeySet = new Set<ID>();
		Set<String> crsmRecipientIDSet = new Set<String>();        
        //Get the current maps only
        addressMap = mapManager.getAddressMap(null, null, null, false);
        hdsAccountsMap = mapManager.getAccountsMapByHDSRecipientId(null, false);
        crsmAccountsMap = mapManager.getAccountsMapByCRSMAccountNumber(null,false);
        addrAccountsMap = mapManager.getAccountsMapByNameAndAddress(null,null,null,null,false);     
        accountsMap = mapManager.getAccountsMapByID(addrAccountsMap.values(),false);
        
        System.debug('VSS085DX:1 addressMap ' + addressMap.size());
        System.debug('VSS085DX:1 hdsAccountsMap ' + hdsAccountsMap.size());
        System.debug('VSS085DX:1 crsmAccountsMap ' + crsmAccountsMap.size());
        System.debug('VSS085DX:1 addrAccountsMap ' + addrAccountsMap.size());
        System.debug('VSS085DX:1 accountsMap ' + accountsMap.size());
        
        //Prepare the sets first
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vHdsContactId = so.HdsContactId__c;
			String vCrsmRecipientId = so.crsmContactId__c;
            if (StringUtility.validate(vHdsContactId)=='0') hdsContactIDSet.add(vHdsContactId.trim());			
			if (StringUtility.validate(vCrsmRecipientId)=='0') crsmRecipientIDSet.add(vCrsmRecipientId.trim());
			System.debug(loggingLevel.INFO,'VSS085DX ABC: HDS Contact ID = ' + vHdsContactId);
			System.debug(loggingLevel.INFO,'VSS085DX ABC: CRSM Contact ID = ' + vCrsmRecipientId);
        }
		
        //generate the contacts map
        contactsMap = mapManager.getContactsMap(hdsContactIDSet,true);
		contactsMapByID = mapManager.getContactsMapByCRSMId(crsmRecipientIDSet,true);		
        
		System.debug(loggingLevel.INFO,'VSS085DX ABC: contactsMap = ' + contactsMap.size());
		System.debug(loggingLevel.INFO,'VSS085DX ABC: contactsMapByID = ' + contactsMapByID.size());
		
        //Get RecordType
        List<RecordType> recTypeList = [SELECT ID FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Customer_Contact'];        
        RecordType recType = null;
        if (recTypeList.size()>0) {
            recType = recTypeList.get(0);  
        }
        
        //Process the contacts      
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vHdsContactId = so.HdsContactId__c;
            String vRecipientName = so.RecipientName__c;
            if (StringUtility.validate(vRecipientName)=='1') {
                vRecipientName = 'HDS Contact ID ' + vHdsContactId;
                so.RecipientName__c = vRecipientName;
            }
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
			
            if (StringUtility.validate(vRecipientResidenceTelephoneNumber).equalsIgnoreCase('1')) {vRecipientResidenceTelephoneNumber = '9999999999';}
            if (StringUtility.validate(vRecipientOfficeTelephoneNumber).equalsIgnoreCase('1')) {vRecipientOfficeTelephoneNumber = '9999999999';}
            if (StringUtility.validate(vRecipientFaxNumber).equalsIgnoreCase('1')) {vRecipientFaxNumber = '9999999999';}
            if (StringUtility.validate(vRecipientHandphoneNumber).equalsIgnoreCase('1')) {vRecipientHandphoneNumber = '9999999999';}

            
            
			System.debug(loggingLevel.INFO,'VSS085DX ABC: Processing');
			Boolean hasMatchFlag = false;
			if (contactsMap.containsKey(vHdsContactId)) {
				System.debug(loggingLevel.INFO,'VSS085DX ABC: contactsMap.containsKey(vHdsContactId)');
                Contact recipientContact = contactsMap.get(vHdsContactId);          
                if (forUpdateKeySet.contains(recipientContact.ID)==false) {
                    Boolean forUpdateFlag = false;
                    if (recipientContact.Recipient_Indicator__c == false) {
                        recipientContact.Recipient_Indicator__c = true;
                        forUpdateFlag = true;
                    }               
                    if (vRecipientUpdateIndicator.trim().equalsIgnoreCase('U')) {
                        String strSearchKey = vRecipientPostalCode + vRecipientUnit + vRecipientLevel;
                        Address__c recipientAddress = addressMap.get(strSearchKey);
                        
                        recipientContact.HomePhone__c = vRecipientResidenceTelephoneNumber  ;
                        recipientContact.Office_Number__c = vRecipientOfficeTelephoneNumber  ;
                        recipientContact.Fax__c = vRecipientFaxNumber  ;
                        recipientContact.Mobile_Number__c = vRecipientHandphoneNumber  ;
                        recipientContact.Email__c = vRecipientEmail  ;
                        recipientContact.NRIC__c = vRecipientNric  ;
                        recipientContact.Company_Name__c = vRecipientCompanyName  ;
                        recipientContact.Salutation = vRecipientSalutation  ;
                        recipientContact.LastName = vRecipientName;
                        recipientContact.Recipient_Indicator__c = true;
                        recipientContact.HDS_Contact_Id__c = vHdsContactId;
                        
                        if (recipientAddress!=null) recipientContact.Address__c = recipientAddress.Id;
                        if (vRecipientOfficeTelephoneExtension!=null&&vRecipientOfficeTelephoneExtension!='')
                            recipientContact.Office_Extension__c = vRecipientOfficeTelephoneExtension;
                        
                        
                        forUpdateFlag = true;
                    }
                    
                    if (forUpdateFlag) {
                        forUpdateList.add(recipientContact);
                    }					
                }
				hasMatchFlag = true;				
                forUpdateKeySet.add(recipientContact.ID);               
            
            }
			
			if (hasMatchFlag==false&&contactsMapByID.containsKey(vCrsmContactId)) {
				System.debug(loggingLevel.INFO,'VSS085DX ABC: contactsMapByID.containsKey(vCrsmContactId)');
				 Contact recipientContact = contactsMapByID.get(vCrsmContactId);          
                if (forUpdateKeySet.contains(recipientContact.ID)==false) {
                    Boolean forUpdateFlag = false;
                    if (recipientContact.Recipient_Indicator__c == false) {
                        recipientContact.Recipient_Indicator__c = true;
                        forUpdateFlag = true;
                    }               
                    if (vRecipientUpdateIndicator.trim().equalsIgnoreCase('U')) {
                        String strSearchKey = vRecipientPostalCode + vRecipientUnit + vRecipientLevel;
                        Address__c recipientAddress = addressMap.get(strSearchKey);
                        
                        recipientContact.HomePhone__c = vRecipientResidenceTelephoneNumber  ;
                        recipientContact.Office_Number__c = vRecipientOfficeTelephoneNumber  ;
                        recipientContact.Fax__c = vRecipientFaxNumber  ;
                        recipientContact.Mobile_Number__c = vRecipientHandphoneNumber  ;
                        recipientContact.Email__c = vRecipientEmail  ;
                        recipientContact.NRIC__c = vRecipientNric  ;
                        recipientContact.Company_Name__c = vRecipientCompanyName  ;
                        recipientContact.Salutation = vRecipientSalutation  ;
                        recipientContact.LastName = vRecipientName;
                        recipientContact.Recipient_Indicator__c = true;
                        recipientContact.HDS_Contact_Id__c = vHdsContactId;
                        
                        if (recipientAddress!=null) recipientContact.Address__c = recipientAddress.Id;
                        if (vRecipientOfficeTelephoneExtension!=null&&vRecipientOfficeTelephoneExtension!='')
                            recipientContact.Office_Extension__c = vRecipientOfficeTelephoneExtension;
                        
                        
                        forUpdateFlag = true;
                    } else {
						recipientContact.HDS_Contact_Id__c = vHdsContactId;  //Update the HDS  Contact ID
						forUpdateFlag = true;
					}
                    
                    if (forUpdateFlag) {
                        forUpdateList.add(recipientContact);						
                    }
                }
				hasMatchFlag = true;
                forUpdateKeySet.add(recipientContact.ID);
			}
			
			if (hasMatchFlag==false) {
                if (forInsertKeySet.contains(vHdsContactId)==false) {
                    String strSearchKey = vRecipientPostalCode + vRecipientUnit + vRecipientLevel;
                    Account accountRecord = hdsAccountsMap.get(vHdsRecipientId);
                    Address__c recipientAddress = addressMap.get(strSearchKey);
                                
                    Contact recipientContact = new Contact();                
                    recipientContact.HomePhone__c = vRecipientResidenceTelephoneNumber  ;
                    recipientContact.Office_Number__c = vRecipientOfficeTelephoneNumber  ;
                    recipientContact.Fax__c = vRecipientFaxNumber  ;
                    recipientContact.Mobile_Number__c = vRecipientHandphoneNumber  ;
                    if (StringUtility.validate(vRecipientEmail).equalsIgnoreCase('0')) recipientContact.Email__c = vRecipientEmail  ;
                    if (StringUtility.validate(vRecipientNric).equalsIgnoreCase('0')) recipientContact.NRIC__c = vRecipientNric  ;
                    recipientContact.Company_Name__c = vRecipientCompanyName  ;
                    recipientContact.Salutation = vRecipientSalutation  ;
                    recipientContact.LastName = vRecipientName;
                    recipientContact.Recipient_Indicator__c = TRUE;
                    recipientContact.HDS_Contact_Id__c = vHdsContactId;
                    recipientContact.AccountId  = accountRecord.Id;
                    recipientContact.Active__c = true;  
                    recipientContact.recordTypeId = recType.Id;
                    if (vRecipientOfficeTelephoneExtension!=null&&vRecipientOfficeTelephoneExtension!='')
                        recipientContact.Office_Extension__c = vRecipientOfficeTelephoneExtension;
                    if (recipientAddress!=null) recipientContact.Address__c = recipientAddress.Id;

                    forInsertList.add(recipientContact);
                }
                forInsertKeySet.add(vHdsContactId);
            }	
            
        }
        
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert forInsertList;
            update forUpdateList;
        } catch(Exception e) {    
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('VSS085DX: Recipient Contact Processing Failed.' + e.getMessage());
        }

        //Regenerate the Contacts Map
        contactsMap = mapManager.getContactsMap(hdsContactIDSet,true);
        System.debug('VSS085DX:1 contactsMap ' + contactsMap.size());
        BT_CO_INT_Utilities.log('VSS085DX: hdsContactIDSet ' + hdsContactIDSet.size());
    }
	//END 2015/10/07 Renino Niefes UD-2898 changed the logic for managing recipient contacts for "Update" scenario         
}