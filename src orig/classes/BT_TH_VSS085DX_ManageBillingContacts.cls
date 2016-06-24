/**
 * Trigger Name: BT_TH_VSS085DX_ManageBillingContacts
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/06/02 Renino Niefes added default value 9999999999 for phone number fields if blank
 * History: 2015/06/04 Renino Niefes hotfix: check if email is present
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW 
 * History: 2015/10/07 Renino Niefes UD-2898 changed the logic for managing billing contacts for "Update" scenario 
 */
 
 
public class BT_TH_VSS085DX_ManageBillingContacts
{   
	//START 2015/10/07 Renino Niefes UD-2898 changed the logic for managing billing contacts for "Update" scenario 
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
        
        System.debug('VSS085DX:2 addressMap ' + addressMap.size());
        System.debug('VSS085DX:2 hdsAccountsMap ' + hdsAccountsMap.size());
        System.debug('VSS085DX:2 crsmAccountsMap ' + crsmAccountsMap.size());
        System.debug('VSS085DX:2 addrAccountsMap ' + addrAccountsMap.size());
        System.debug('VSS085DX:2 accountsMap ' + accountsMap.size());       
        
        //Prepare the sets first
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vHdsContactId = so.HdsContactId__c;
			String vCrsmRecipientId = so.crsmContactId__c;
            if (StringUtility.validate(vHdsContactId)=='0') hdsContactIDSet.add(vHdsContactId.trim());
			if (StringUtility.validate(vCrsmRecipientId)=='0') crsmRecipientIDSet.add(vCrsmRecipientId.trim());
        }
        
        //generate the contacts map
        contactsMap = mapManager.getContactsMap(hdsContactIDSet,false);     
		contactsMapByID = mapManager.getContactsMapByCRSMId(crsmRecipientIDSet,true);

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
            String vSubscriberName = so.SubscriberName__c;
            if (StringUtility.validate(vSubscriberName)=='1') {
                vSubscriberName = 'HDS Contact ID ' + vHdsContactId;
                so.SubscriberName__c = vSubscriberName;
            }
            String vSubscriberStreetCode = so.SubscriberStreetCode__c;
            String vSubscriberBuildingCode = so.SubscriberBuildingCode__c;
            String vSubscriberHouseBlockNumber = so.SubscriberHouseBlockNumber__c;
            String vSubscriberLevel = so.SubscriberLevel__c;
            String vSubscriberUnit = so.SubscriberUnit__c;
            String vSubscriberPostalCode = so.SubscriberPostalCode__c;
            String vSubscriberResidenceTelephoneNumber = so.SubscriberResidentTelephoneNumber__c;
            String vSubscriberOfficeTelephoneNumber = so.SubscriberOfficeTelephoneNumber__c;
            String vSubscriberOfficeTelephoneExtension = so.SubscriberOfficeTelephoneExtension__c;
            String vSubscriberFaxNumber = so.SubscriberFaxNumber__c;
            String vSubscriberHandphoneNumber = so.SubscriberHandphoneNumber__c;
            String vSubscriberEmail = so.SubscriberEmail__c;
            String vSubscriberNric = so.SubscriberNric__c;
            String vSubscriberCompanyName = so.SubscriberCompanyName__c;
            String vVendorGroup = so.VendorGroup__c;
            String vVendorNumber = so.VendorNumber__c;
            String vSubscriberSalutation = so.SubscriberSalutation__c;
            String vSubscriberUpdateIndicator = so.SubscriberUpdateIndicator__c;            
            String vCrsmContactId = so.CrsmContactId__c;
            
            if (StringUtility.validate(vSubscriberResidenceTelephoneNumber).equalsIgnoreCase('1')) {vSubscriberResidenceTelephoneNumber = '9999999999';}
            if (StringUtility.validate(vSubscriberOfficeTelephoneNumber).equalsIgnoreCase('1')) {vSubscriberOfficeTelephoneNumber = '9999999999';}
            if (StringUtility.validate(vSubscriberFaxNumber).equalsIgnoreCase('1')) {vSubscriberFaxNumber = '9999999999';}
            if (StringUtility.validate(vSubscriberHandphoneNumber).equalsIgnoreCase('1')) {vSubscriberHandphoneNumber = '9999999999';}
            
			Boolean hasMatchFlag = false;


			if (contactsMap.containsKey(vHdsContactId)) {                
                Contact subscriberContact = contactsMap.get(vHdsContactId);         
                if (forUpdateKeySet.contains(subscriberContact.ID)==false) {
                    Boolean forUpdateFlag = false;
                    if (subscriberContact.Billing_Indicator__c == false) {
                        subscriberContact.Billing_Indicator__c = true;
                        forUpdateFlag = true;
                    }
                    if (vSubscriberUpdateIndicator.trim().equalsIgnoreCase('U')) {
                        String strSearchKey = vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
                        Address__c subscriberAddress = addressMap.get(strSearchKey);
                        
                        subscriberContact.HomePhone__c = vSubscriberResidenceTelephoneNumber  ;
                        subscriberContact.Office_Number__c = vSubscriberOfficeTelephoneNumber  ;
                        subscriberContact.Fax__c = vSubscriberFaxNumber  ;
                        subscriberContact.Mobile_Number__c = vSubscriberHandphoneNumber  ;
                        subscriberContact.Email__c = vSubscriberEmail  ;
                        subscriberContact.NRIC__c = vSubscriberNric  ;
                        subscriberContact.Company_Name__c = vSubscriberCompanyName  ;
                        subscriberContact.Salutation = vSubscriberSalutation  ;
                        subscriberContact.LastName = vSubscriberName;
                        subscriberContact.Billing_Indicator__c = true;
                        subscriberContact.HDS_Contact_Id__c = vHdsContactId;
                        
                        if (subscriberAddress!=null) subscriberContact.Address__c = subscriberAddress.Id;
                        if (vSubscriberOfficeTelephoneExtension!=null&&vSubscriberOfficeTelephoneExtension!='')
                            subscriberContact.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                        
                        
                        forUpdateFlag = true;
                    }
                    
                    if (forUpdateFlag) {
                        forUpdateList.add(subscriberContact);						
                    }					
                }
				hasMatchFlag = true;
                forUpdateKeySet.add(subscriberContact.ID);              
            
            }
            
			if (hasMatchFlag==false&&contactsMapByID.containsKey(vCrsmContactId)) {
				 Contact subscriberContact = contactsMapByID.get(vCrsmContactId);   
				if (forUpdateKeySet.contains(subscriberContact.ID)==false) {
                    Boolean forUpdateFlag = false;
                    if (subscriberContact.Billing_Indicator__c == false) {
                        subscriberContact.Billing_Indicator__c = true;
                        forUpdateFlag = true;
                    }
                    if (vSubscriberUpdateIndicator.trim().equalsIgnoreCase('U')) {
                        String strSearchKey = vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
                        Address__c subscriberAddress = addressMap.get(strSearchKey);
                        
                        subscriberContact.HomePhone__c = vSubscriberResidenceTelephoneNumber  ;
                        subscriberContact.Office_Number__c = vSubscriberOfficeTelephoneNumber  ;
                        subscriberContact.Fax__c = vSubscriberFaxNumber  ;
                        subscriberContact.Mobile_Number__c = vSubscriberHandphoneNumber  ;
                        subscriberContact.Email__c = vSubscriberEmail  ;
                        subscriberContact.NRIC__c = vSubscriberNric  ;
                        subscriberContact.Company_Name__c = vSubscriberCompanyName  ;
                        subscriberContact.Salutation = vSubscriberSalutation  ;
                        subscriberContact.LastName = vSubscriberName;
                        subscriberContact.Billing_Indicator__c = true;
                        subscriberContact.HDS_Contact_Id__c = vHdsContactId;
                        
                        if (subscriberAddress!=null) subscriberContact.Address__c = subscriberAddress.Id;
                        if (vSubscriberOfficeTelephoneExtension!=null&&vSubscriberOfficeTelephoneExtension!='')
                            subscriberContact.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                        
                        
                        forUpdateFlag = true;
                    } else {
						subscriberContact.HDS_Contact_Id__c = vHdsContactId;
					}
                    
                    if (forUpdateFlag) {
                        forUpdateList.add(subscriberContact);						
                    }
                }
				hasMatchFlag = true;
                forUpdateKeySet.add(subscriberContact.ID);  	 
			}
			
            if (hasMatchFlag==false) {
                if (forInsertKeySet.contains(vHdsContactId)==false) {
                    String strSearchKey = vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
                    Account accountRecord = hdsAccountsMap.get(vHdsRecipientId);
                    Address__c subscriberAddress = addressMap.get(strSearchKey);
                                
                    Contact subscriberContact = new Contact();                
                    subscriberContact.HomePhone__c = vSubscriberResidenceTelephoneNumber  ;
                    subscriberContact.Office_Number__c = vSubscriberOfficeTelephoneNumber  ;
                    subscriberContact.Fax__c = vSubscriberFaxNumber  ;
                    subscriberContact.Mobile_Number__c = vSubscriberHandphoneNumber  ;
                    if (StringUtility.validate(vSubscriberEmail).equalsIgnoreCase('0')) subscriberContact.Email__c = vSubscriberEmail  ;
                    if (StringUtility.validate(vSubscriberNric).equalsIgnoreCase('0')) subscriberContact.NRIC__c = vSubscriberNric  ;
                    subscriberContact.Company_Name__c = vSubscriberCompanyName  ;
                    subscriberContact.Salutation = vSubscriberSalutation  ;
                    subscriberContact.LastName = vSubscriberName;
                    subscriberContact.Billing_Indicator__c = TRUE;
                    subscriberContact.HDS_Contact_Id__c = vHdsContactId;
                    subscriberContact.AccountId  = accountRecord.Id;
                    subscriberContact.Active__c = true; 
                    subscriberContact.recordTypeId = recType.Id;
                    if (vSubscriberOfficeTelephoneExtension!=null&&vSubscriberOfficeTelephoneExtension!='')
                        subscriberContact.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                    if (subscriberAddress!=null) subscriberContact.Address__c = subscriberAddress.Id;

                    forInsertList.add(subscriberContact);
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
            BT_CO_INT_Utilities.log('VSS085DX: Subscriber Contact Processing Failed.' + e.getMessage());
        }

        //Regenerate the Contacts Map
        contactsMap = mapManager.getContactsMap(hdsContactIDSet,true);
        System.debug('VSS085DX:2 contactsMap ' + contactsMap.size());
        BT_CO_INT_Utilities.log('VSS085DX: hdsContactIDSet ' + hdsContactIDSet.size());     
    }
	//END 2015/10/07 Renino Niefes UD-2898 changed the logic for managing billing contacts for "Update" scenario 
}