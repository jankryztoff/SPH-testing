/**
 * Trigger Name: BT_TH_VSS085DX_ManageSubscriptions
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW  
 * History: 2015/10/07 Renino Niefes UD-2898 changed the logic for managing subscription vendors for "Update" scenario 
 * History: 2016/01/05 Renino Niefes UD-3435 if the indicator is "U" update the  stop date as well
 * History: 2016/01/06 Renino Niefes UD-3435 reversing the fix done yesterday.  Scenario is invalid.  "U" indicator shouldn't update the subs stop date.
 */
 
 
public class BT_TH_VSS085DX_ManageSubscriptions
{   
    //START 2015/10/07 Renino Niefes UD-2898 changed the logic for managing subscription vendors for "Update" scenario 
    public void execute(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList, BT_TH_VSS085DX_ManageMaps mapManager) {
        Map<String, Account> hdsAccountsMap = null;
        Map<String, Contact> contactsMap = null;
        Map<String, Account> vendorMap = null;
        Map<ID, Subscription_Vendor__c> subVendorMap = null;
        Map<String, Map<String, ID>> accountSubscriptionVendorMap = null;
        Map<String, ID> subVenMap = null;
        Set<ID> forUpdateKeySet = new Set<ID>();
        
        List<Subscription_Vendor__c> forInsertList = new List<Subscription_Vendor__c>();
        List<Subscription_Vendor__c> forUpdateList = new List<Subscription_Vendor__c>();
        List<String> crsmSubscriptionIDList= new List<String>();
        
        //Get the current maps only
        hdsAccountsMap = mapManager.getAccountsMapByHDSRecipientId(null, false);
        contactsMap = mapManager.getContactsMap(null,false);
        vendorMap = mapManager.getVendorMap(null);
        Map<String, Publication__c> publicationMap = mapManager.getPublicationMap();        
        BT_CO_INT_Utilities.log('VSS085DX:3 hdsAccountsMap ' + hdsAccountsMap.size());
        BT_CO_INT_Utilities.log('VSS085DX:3 contactsMap ' + contactsMap.size());        
        
        //Update Subscriptions first based on feed file if HDS
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vCrsmVendorSubscriptionId = so.CrsmVendorSubscriptionId__c;
            if (StringUtility.validate(vCrsmVendorSubscriptionId)=='0') crsmSubscriptionIDList.add(vCrsmVendorSubscriptionId.trim());
        }
        Map<String, Subscription_Vendor__c> subVenMapX = null;
        subVenMapX = mapManager.getSubscriptionVendorsList(crsmSubscriptionIDList);
        List<Subscription_Vendor__c> subVendorListForUpdateX = new List<Subscription_Vendor__c>();
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vHdsContactId = so.HdsContactId__c;
            String vHdsSubscriptionId = so.HdsSubscriptionId__c;
            String vPublicationCode = so.PublicationCode__c;            
            String vCrsmVendorSubscriptionId = so.CrsmVendorSubscriptionId__c;
            
            Account accountRecord = hdsAccountsMap.get(vHdsRecipientId);
            Set<String> duplicateCheck = new Set<String>();
            if (subVenMapX.containsKey(vCrsmVendorSubscriptionId)) {
                Subscription_Vendor__c svRecX = subVenMapX.get(vCrsmVendorSubscriptionId);
                String keyString = vHdsSubscriptionId + ':' + vPublicationCode + ':' + vHdsRecipientId + ':' + accountRecord.Id; 
                if (!duplicateCheck.contains(vCrsmVendorSubscriptionId)) {
                    if (svRecX.HDS_Subscription_Id__c==null) {
                        svRecX.HDS_Subscription_Id__c = vHdsContactId;
                        svRecX.Reason__c = keyString;
                        subVendorListForUpdateX.add(svRecX);
                    }
                    duplicateCheck.add(vCrsmVendorSubscriptionId);
                }
            }
        }
        Savepoint savepointBeforeDML0 = Database.setSavepoint();
        try {
            update subVendorListForUpdateX;
        } catch(Exception e) {    
            Database.rollback(savepointBeforeDML0);
            BT_CO_INT_Utilities.log('VSS085DX: Manage Subscriptions Processing Failed.' + e.getMessage());
        }

        
        
        //Generate the Maps for Subscription
        subVendorMap = mapManager.getSubscriptionVendorMap(hdsAccountsMap.values(),false);
        accountSubscriptionVendorMap = mapManager.getSubscriptionVendorIDMapByAccount(hdsAccountsMap.values(),false);
        
        BT_CO_INT_Utilities.log('VSS085DX:3 subVendorMap ' + subVendorMap.size());
        BT_CO_INT_Utilities.log('VSS085DX:3 accountSubscriptionVendorMap ' + accountSubscriptionVendorMap.size());      

        //Iterate and process the records (Subscription Vendor Only)
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vHdsContactId = so.HdsContactId__c;
            String vHdsSubscriptionId = so.HdsSubscriptionId__c;
            String vVendorNumber = so.VendorNumber__c;
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

            Account accountRecord = hdsAccountsMap.get(vHdsRecipientId);
            Contact contactRecord = contactsMap.get(vHdsContactId);
            Account vendorRecord = vendorMap.get(vVendorNumber);
            
            BT_CO_INT_Utilities.log('VSS085DX: x1');
            if (!accountSubscriptionVendorMap.containsKey(vHdsRecipientId)) {
                Map<String, ID> subVenMapNew = new Map<String, ID>();
                accountSubscriptionVendorMap.put(vHdsRecipientId, subVenMapNew);
                BT_CO_INT_Utilities.log('VSS085DX: x2');
            }
            subVenMap = accountSubscriptionVendorMap.get(vHdsRecipientId);
            
            BT_CO_INT_Utilities.log('VSS085DX: x4 ' + accountSubscriptionVendorMap.size());
            ID subVenID = null;
            subVenID = mapManager.getIDFromSubscriptionVendorMap(vPublicationCode, subVenMap);
            
            BT_CO_INT_Utilities.log('VSS085DX: x5 ' + subVenID);
            
            if (subVenID==null) {
                if (StringUtility.validate(vCrsmVendorSubscriptionId)=='1'||vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('A')) {
                    BT_CO_INT_Utilities.log('VSS085DX: x6 ');
                    String keyString = vHdsSubscriptionId + ':' + vPublicationCode + ':' + vHdsRecipientId + ':' + accountRecord.Id;                                
                    Subscription_Vendor__c subVendor = new Subscription_Vendor__c();                
                    subVendor.Account__c = accountRecord.Id;
                    subVendor.Vendor__c = vendorRecord.Id;
                    subVendor.Recipient__c = contactRecord.Id;
                    subVendor.HDS_Subscription_Id__c = vHdsContactId;
                    subVendor.Reason__c = keyString;
                    if (vStartDate!=null&&vStartDate.trim()!='') subVendor.Subscription_Start_Date__c = DateUtility.convertDate(vStartDate,'\\.','DMY');
                    if (vStopDate!=null&&vStopDate.trim()!='') subVendor.Subscription_Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');                                        
                    subVendor.Status__c = 'Active';
                    if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('D')) {
                        subVendor.Status__c = 'Inactive';
                    }
                    
                    if (!mapManager.checkIfPubCodeExistInSubscriptionVendorMap(vPublicationCode, subVenMap)) {
                        BT_CO_INT_Utilities.log('VSS085DX: x7 ');
                        forInsertList.add(subVendor);               
                        mapManager.addToSubscriptionVendorMap(vPublicationCode, subVenMap, null);
                        BT_CO_INT_Utilities.log('VSS085DX: x10 ' + subVenMap.size());
                    }
                }                
            } else {
                BT_CO_INT_Utilities.log('VSS085DX: x8 ');
                Subscription_Vendor__c subVendor = subVendorMap.get(subVenID);
                
                if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('P')) {   //START/END 2016-01-06 UD-3435 Renz Niefes Reversing the fix done yesterday...   Remove this statement "||vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('U')"
                    //  Update Subscription Stop Date
                    if (vStopDate!=null&&vStopDate.trim()!='') subVendor.Subscription_Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');                        
                    if (!forUpdateKeySet.contains(subVenID)) {forUpdateList.add(subVendor);}
                    forUpdateKeySet.add(subVenID);
                    BT_CO_INT_Utilities.log('VSS085DX: Subscription Vendor - P Indicator.');
                } else if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('D')) {
                    //  Stop Subscription
                    if (vStopDate!=null&&vStopDate.trim()!='') subVendor.Subscription_Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');
                    subVendor.Status__c = 'Inactive';
                    if (!forUpdateKeySet.contains(subVenID)) {forUpdateList.add(subVendor);}
                    forUpdateKeySet.add(subVenID);
                    BT_CO_INT_Utilities.log('VSS085DX: Subscription Vendor - D Indicator.');
                } else if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('V')) {
                    // Change of Vendor
                    subVendor.Vendor__c = vendorRecord.Id;
                    if (!forUpdateKeySet.contains(subVenID)) {forUpdateList.add(subVendor);}
                    forUpdateKeySet.add(subVenID);
                    BT_CO_INT_Utilities.log('VSS085DX: Subscription Vendor - V Indicator. ' + vendorRecord.Id);
                } else if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('R')) {
                    // Reactivate Subscription
                    if (vStopDate!=null&&vStopDate.trim()!='') {
                        subVendor.Subscription_Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');
                    } else {
                        subVendor.Subscription_Stop_Date__c = null;
                    }
                    subVendor.Status__c = 'Active';
                    if (!forUpdateKeySet.contains(subVenID)) {forUpdateList.add(subVendor);}
                    forUpdateKeySet.add(subVenID);
                    BT_CO_INT_Utilities.log('VSS085DX: Subscription Vendor - R Indicator.');
                }
            }
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert forInsertList;
            update forUpdateList;
        } catch(Exception e) {    
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('VSS085DX: Manage Subscriptions Processing Failed.' + e.getMessage());
        }
        
        //Repopulate the Subscription Vendor Maps
        accountSubscriptionVendorMap = mapManager.getSubscriptionVendorIDMapByAccount(hdsAccountsMap.values(),true);
        for (Subscription_Vendor__c subVendor : forInsertList) {
            List<String> vTemp = subVendor.Reason__c.split(':');            
            subVenMap = null;
            if (accountSubscriptionVendorMap.containsKey(vTemp[2])) {
                subVenMap = accountSubscriptionVendorMap.get(vTemp[2]);
            } else {
                subVenMap = new Map<String, ID>();
                accountSubscriptionVendorMap.put(vTemp[2], subVenMap);
            }
            
            subVenMap = accountSubscriptionVendorMap.get(vTemp[2]);
            mapManager.addToSubscriptionVendorMap(vTemp[1], subVenMap, subVendor.ID);
            accountSubscriptionVendorMap.put(vTemp[2],subVenMap);
        }
        
        mapManager.setSubscriptionVendorIDMapByAccount(accountSubscriptionVendorMap);
        //mapManager.printOutAccountSubscriptionVendorMap(accountSubscriptionVendorMap);        
    }
    //END 2015/10/07 Renino Niefes UD-2898 changed the logic for managing subscription vendors for "Update" scenario     
}