/**
 * Trigger Name: BT_TH_VSS085DX_ManageAccounts
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW
 * History: 2015/10/07 Renino Niefes UD-2898 changed the logic for managing accounts for "Update" scenario  
 * History: 11/26/2015 D-3993 Renino Niefes - Related to D-3911. Remove Account.Phone from the code.  It shouldn't be populated.
 */
 
 
 public class BT_TH_VSS085DX_ManageAccounts
{   
	//START 2015/10/07 Renino Niefes UD-2898 changed the logic for managing accounts for "Update" scenario  
    public void execute(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList, BT_TH_VSS085DX_ManageMaps mapManager) {
        Set<String> hdsRecipientIDSet = new Set<String>();
        Set<String> crsmAccountNoSet = new Set<String>();
        Set<String> accountNameSet = new Set<String>();
        Set<String> postalCodeSet = new Set<String>();
        Set<String> levelSet = new Set<String>();
        Set<String> unitSet = new Set<String>();    
        
        Map<String, Account> hdsAccountsMap = null;
        Map<String, Account> crsmAccountsMap = null;
        Map<String, ID> addrAccountsMap = null;
        Map<ID, Account> accountsMap = null;        
        Set<ID> accountKeySet = new Set<ID>();
        Set<String> hdsIDKeySet = new Set<String>();
        
        List<Account> forInsertList = new List<Account>();
        List<Account> forUpdateList = new List<Account>();		
        
        //prepare the sets first
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vCrsmAccountId = so.CrsmAccountId__c;            
            String vSubscriberName = so.SubscriberName__c;
            String vSubscriberLevel = so.SubscriberLevel__c;
            String vSubscriberUnit = so.SubscriberUnit__c;
            String vSubscriberPostalCode = so.SubscriberPostalCode__c;			

            //Derive the Account Name if SubscriberName is null
            if (StringUtility.validate(vSubscriberName)=='1') {             
                vSubscriberName = 'HDS Recipient ID ' + so.HdsRecipientId__c.trim();
                so.SubscriberName__c = vSubscriberName;
            }
            
            if (StringUtility.validate(vHdsRecipientId)=='0') hdsRecipientIDSet.add(vHdsRecipientId.trim());
            if (StringUtility.validate(vCrsmAccountId)=='0') crsmAccountNoSet.add(vCrsmAccountId.trim());
            if (StringUtility.validate(vSubscriberName)=='0') accountNameSet.add(vSubscriberName.trim());
            if (StringUtility.validate(vSubscriberPostalCode)=='0') postalCodeSet.add(vSubscriberPostalCode.trim());
            if (StringUtility.validate(vSubscriberLevel)=='0') levelSet.add(vSubscriberLevel.trim());                       
            if (StringUtility.validate(vSubscriberUnit)=='0') unitSet.add(vSubscriberUnit.trim());			
			
			System.debug(loggingLevel.INFO,'vHdsRecipientId:' + vHdsRecipientId);
			System.debug(loggingLevel.INFO,'vCrsmAccountId:' + vCrsmAccountId);
			System.debug(loggingLevel.INFO,'vSubscriberName:' + vSubscriberName);
			System.debug(loggingLevel.INFO,'vSubscriberPostalCode:' + vSubscriberPostalCode);
			System.debug(loggingLevel.INFO,'vSubscriberLevel:' + vSubscriberLevel);
			System.debug(loggingLevel.INFO,'vSubscriberUnit:' + vSubscriberUnit);
        }
        
        //generate the accounts map
        hdsAccountsMap = mapManager.getAccountsMapByHDSRecipientId(hdsRecipientIDSet,false);
        crsmAccountsMap = mapManager.getAccountsMapByCRSMAccountNumber(crsmAccountNoSet,false);
        addrAccountsMap = mapManager.getAccountsMapByNameAndAddress(accountNameSet,postalCodeSet,postalCodeSet,unitSet,false);      
        accountsMap = mapManager.getAccountsMapByID(addrAccountsMap.values(),false);
        
        //Loop through the records list and check if they exist
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
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
            
            Account accountRecord = null;
            
            //Derive the Account Name if SubscriberName is null
            if (StringUtility.validate(vSubscriberName)=='1') {             
                vSubscriberName = 'HDS Recipient ID ' + so.HdsRecipientId__c.trim();
                so.SubscriberName__c = vSubscriberName;
            }   
            
            String strSearchKey = vSubscriberName + vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
        
			
            if (StringUtility.validate(vHdsRecipientId)=='0'&&hdsAccountsMap.containsKey(vHdsRecipientId.trim())) {         
                accountRecord = hdsAccountsMap.get(vHdsRecipientId.trim());
				System.debug(loggingLevel.INFO,'hdsAccountsMap:true');				
            } else if (StringUtility.validate(vCrsmAccountId)=='0'&&crsmAccountsMap.containsKey(vCrsmAccountId.trim())) {           
                accountRecord = crsmAccountsMap.get(vCrsmAccountId.trim());
				System.debug(loggingLevel.INFO,'crsmAccountsMap:true');				
            } else if (addrAccountsMap.containsKey(strSearchKey)) {
                ID accountId = addrAccountsMap.get(strSearchKey);
				System.debug(loggingLevel.INFO,'addrAccountsMap:' + strSearchKey);
                if (accountsMap.containsKey(accountId)) {
                    accountRecord = accountsMap.get(accountId);
					System.debug(loggingLevel.INFO,'addrAccountsMap:true');
                }               
            }
            
            if (StringUtility.validate(accountRecord)=='1') {
				System.debug(loggingLevel.INFO,'accountRecord:null');
                if (hdsIDKeySet.contains(vHdsRecipientId)==false) {
					System.debug(loggingLevel.INFO,'accountRecord:create new record');
                    accountRecord = new Account();
                    accountRecord.HDS_Recipient_Id__c = vHdsRecipientId;
                    accountRecord.Name = vSubscriberName;
                    accountRecord.Company_Name__c = vSubscriberCompanyName;
                    accountRecord.Email__c = vSubscriberEmail;
                    accountRecord.NRIC__c = vSubscriberNric;
                    accountRecord.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                    accountRecord.Office_Number__c = vSubscriberOfficeTelephoneNumber;
					//Start UD-3993 2015-11-26 Renz Do not populate Account.Phone field
                    //accountRecord.Phone = vSubscriberResidentTelephoneNumber;
					//End UD-3993 2015-11-26 Renz
                    accountRecord.Mobile__c = vSubscriberHandphoneNumber;
                    accountRecord.Handphone_Number__c = vSubscriberHandphoneNumber;
                    accountRecord.Active__c = true;
                    accountRecord.RecordTypeId  = ConstantsSLB.getKeyId('Vendor Subscriber');   
                    accountRecord.Sub_Group__c = vHdsComplimentaryTypeName;
                    forInsertList.add(accountRecord);                   
                }
                hdsIDKeySet.add(vHdsRecipientId);
                
            } else {
                Boolean forUpdateFlag = false;
                System.debug(loggingLevel.INFO,'accountRecord:update record');
                if (accountKeySet.contains(accountRecord.ID)==false) {
					System.debug(loggingLevel.INFO,'accountKeySet:false');
                    if (StringUtility.validate(accountRecord.HDS_Recipient_Id__c)=='1') {                       
                        accountRecord.HDS_Recipient_Id__c = vHdsRecipientId;
                        forUpdateFlag = true;
						System.debug(loggingLevel.INFO,'forUpdateFlag:true');
						System.debug(loggingLevel.INFO,'accountRecord:'+accountRecord.AccountNumber);
                    }
                    
					System.debug(loggingLevel.INFO,'vSubscriberUpdateIndicator:'+vSubscriberUpdateIndicator);
                    if (vSubscriberUpdateIndicator.equalsIgnoreCase('U')) {
                        forUpdateFlag = true;                        
                        accountRecord.Name = vSubscriberName;
                        accountRecord.Company_Name__c = vSubscriberCompanyName;
                        accountRecord.Email__c = vSubscriberEmail;
                        accountRecord.NRIC__c = vSubscriberNric;
                        accountRecord.Office_Extension__c = vSubscriberOfficeTelephoneExtension;
                        accountRecord.Office_Number__c = vSubscriberOfficeTelephoneNumber;
						//Start UD-3993 2015-11-26 Renz Do not populate Account.Phone field
                        //accountRecord.Phone = vSubscriberResidentTelephoneNumber;
						//End UD-3993 2015-11-26 Renz
                        accountRecord.Mobile__c = vSubscriberHandphoneNumber;
                        accountRecord.Handphone_Number__c = vSubscriberHandphoneNumber;
                        accountRecord.HDS_Recipient_Id__c = vHdsRecipientId;
                    }
                    
					System.debug(loggingLevel.INFO,'forUpdateFlag:'+forUpdateFlag);
                    if (forUpdateFlag) {
                        accountKeySet.add(accountRecord.ID);
                        forUpdateList.add(accountRecord);
                    }
                }
                
            }
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert forInsertList;
            update forUpdateList;
        } catch(Exception e) {    
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('VSS085DX: Account Processing Failed.' + e.getMessage());
        }

        //RE-Generate the account maps
        hdsAccountsMap = mapManager.getAccountsMapByHDSRecipientId(hdsRecipientIDSet,true);
        crsmAccountsMap = mapManager.getAccountsMapByCRSMAccountNumber(crsmAccountNoSet,true);
        addrAccountsMap = mapManager.getAccountsMapByNameAndAddress(accountNameSet,postalCodeSet,postalCodeSet,unitSet,true);       
        accountsMap = mapManager.getAccountsMapByID(addrAccountsMap.values(),true);
        

    }
	//END 2015/10/07 Renino Niefes UD-2898 changed the logic for managing accounts for "Update" scenario         
}