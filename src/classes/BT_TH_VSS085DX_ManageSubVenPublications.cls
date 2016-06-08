/**
 * Trigger Name: BT_TH_VSS085DX_ManageSubVenPublications
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/06/03 Renino Niefes hotfix: fixed the subscription copies substring values
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW 
 * History: 2015/10/07 Renino Niefes UD-2898 changed the logic for managing subscription vendor publications for "Update" scenario
 */
 
 
public class BT_TH_VSS085DX_ManageSubVenPublications
{   
    //START 2015/10/07 Renino Niefes UD-2898 changed the logic for managing subscription vendor publications for "Update" scenario
    public void execute(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList, BT_TH_VSS085DX_ManageMaps mapManager) {
        Map<String, Account> hdsAccountsMap = null;
        Map<String, Map<String, ID>> accountSubscriptionVendorMap = null;
        List<ID> subVenIDList = null;
        List<String> crsmSubscriptionIDList= new List<String>();
        List<String> hdsSubscriptionIDList = new List<String>();
        Map<String, Subscription_Vendor_Publication__c> subVenPubMap = null;
        Map<String, List<Subscription_Vendor_Publication__c>> subVenPubMapByID = null;
        Map<String, Subscription_Vendor__c> subVenMapX = null;
        
        List<Subscription_Vendor_Publication__c> forInsertList = new List<Subscription_Vendor_Publication__c>();
        List<Subscription_Vendor_Publication__c> forUpdateList = new List<Subscription_Vendor_Publication__c>();
        
        Map<String, Publication__c> publicationMap = mapManager.getPublicationMap();
        hdsAccountsMap = mapManager.getAccountsMapByHDSRecipientId(null, false);
        accountSubscriptionVendorMap = mapManager.getSubscriptionVendorIDMapByAccount(hdsAccountsMap.values(),false);
        subVenIDList = mapManager.getSubVenIDListfromAccountSubscriptionVendorMap(accountSubscriptionVendorMap);
        mapManager.printOutAccountSubscriptionVendorMap(accountSubscriptionVendorMap);
        
        //Get the list of HDS Subscription IDs
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vHdsSubscriptionId = so.HdsSubscriptionId__c;
            String vCrsmSubscriptionId = so.crsmVendorSubscriptionId__c;
            
            hdsSubscriptionIDList.add(vHdsSubscriptionId);
            if (StringUtility.validate(vCrsmSubscriptionId)=='0') crsmSubscriptionIDList.add(vCrsmSubscriptionId.trim());
        }
        
        subVenPubMap = mapManager.getSubVenPublicationMap(hdsSubscriptionIDList, subVenIDList, true);
        subVenPubMapByID = mapManager.getSubVenPublicationMapByCRSMSubID(crsmSubscriptionIDList, true);       
        subVenMapX = mapManager.getSubscriptionVendorsList(crsmSubscriptionIDList);
       
        //Process the list
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {       
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vHdsSubscriptionId = so.HdsSubscriptionId__c;
            String vPublicationCode = so.PublicationCode__c;
            String vSubscriptionCopies = so.SubscriptionCopies__c;
            String vSubscriptionUpdateIndicator = so.SubscriptionUpdateIndicator__c;
            String vCrsmSubscriptionId = so.crsmVendorSubscriptionId__c;

            System.debug(loggingLevel.INFO,'VSS085DX DEF: vHdsRecipientId' + vHdsRecipientId);
            System.debug(loggingLevel.INFO,'VSS085DX DEF: vHdsSubscriptionId' + vHdsSubscriptionId);
            System.debug(loggingLevel.INFO,'VSS085DX DEF: vPublicationCode' + vPublicationCode);
            System.debug(loggingLevel.INFO,'VSS085DX DEF: vSubscriptionCopies' + vSubscriptionCopies);
            System.debug(loggingLevel.INFO,'VSS085DX DEF: vSubscriptionUpdateIndicator' + vSubscriptionUpdateIndicator);
            System.debug(loggingLevel.INFO,'VSS085DX DEF: vCrsmSubscriptionId' + vCrsmSubscriptionId);
            
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
                vPHe = Decimal.valueOf(vSubscriptionCopies.subString(24,27));
            } catch (Exception e) {
                BT_CO_INT_Utilities.log('VSS085DX: Error parsing Subscription Copies ' + e.getMessage());
            }
            
            Boolean hasMatchFlag = false;
            if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('U')) {
                System.debug(loggingLevel.INFO,'VSS085DX DEF: Update Indicator');
                if (subVenPubMap.containsKey(vHdsSubscriptionId)) {
                    System.debug(loggingLevel.INFO,'VSS085DX DEF: subVenPubMap.containsKey(vHdsSubscriptionId) = TRUE');
                    Subscription_Vendor_Publication__c svpRec = null;
                    Publication__c publication = publicationMap.get(vPublicationCode);
                    svpRec = subVenPubMap.get(vHdsSubscriptionId);
                    svpRec.Publication__c = publication.Id;
                    svpRec.Mon__c = vMon;
                    svpRec.Tue__c = vTue;
                    svpRec.Wed__c = vWed;
                    svpRec.Thu__c = vThu;
                    svpRec.Fri__c = vFri;
                    svpRec.Sat__c = vSat;
                    svpRec.Sun__c = vSun;
                    svpRec.PHd__c = vPHd;
                    svpRec.PHe__c = vPHe;

                    forUpdateList.add(svpRec);
                    hasMatchFlag = true;
                }
                    
                if (hasMatchFlag==false && subVenPubMapByID.containsKey(vCrsmSubscriptionId)) {
                    System.debug(loggingLevel.INFO,'VSS085DX DEF: subVenPubMapByID.containsKey(vCrsmSubscriptionId) = TRUE');
                    List<Subscription_Vendor_Publication__c> list1 = subVenPubMapByID.get(vCrsmSubscriptionId);
                    for (Subscription_Vendor_Publication__c svpRec : list1) {
                        System.debug(loggingLevel.INFO,'VSS085DX DEF: svpRec ' + svpRec.Publication__r.Publication_Code__c);
                        if (svpRec.Publication__r.Publication_Code__c.equalsIgnoreCase(vPublicationCode)) {
                            System.debug(loggingLevel.INFO,'VSS085DX DEF: svpRec.HDS_Subscription_Id__c ' + vHdsSubscriptionId);
                            svpRec.HDS_Subscription_Id__c = vHdsSubscriptionId;
                            svpRec.Mon__c = vMon;
                            svpRec.Tue__c = vTue;
                            svpRec.Wed__c = vWed;
                            svpRec.Thu__c = vThu;
                            svpRec.Fri__c = vFri;
                            svpRec.Sat__c = vSat;
                            svpRec.Sun__c = vSun;
                            svpRec.PHd__c = vPHd;
                            svpRec.PHe__c = vPHe;

                            forUpdateList.add(svpRec);
                            hasMatchFlag = true;
                        }
                    }                   
                }
                
                //Nitin Khanna : UD-3435  - PD-0081 : 23-12-2015 : adding an extra block to insert SVP recors in case its an update request but no records are found :Start
                //Create new record if no match found on both maps.
                if (hasMatchFlag==false) {
                    System.debug(loggingLevel.INFO,'VSS085DX DEF: Add Indicator');
                    Subscription_Vendor_Publication__c svpRec = new Subscription_Vendor_Publication__c();               
                    Account accountRecord = hdsAccountsMap.get(vHdsRecipientId);
                    Publication__c publication = publicationMap.get(vPublicationCode);
                    svpRec.Account__c = accountRecord.Id;
                    svpRec.Publication__c = publication.Id;
                    svpRec.HDS_Subscription_Id__c = vHdsSubscriptionId;

                    Map<String, ID> subVenMap = accountSubscriptionVendorMap.get(vHdsRecipientId);

                    if (StringUtility.validate(vCrsmSubscriptionId)=='0'&&subVenMapX.containsKey(vCrsmSubscriptionId)) {                
                        Subscription_Vendor__c svRec = subVenMapX.get(vCrsmSubscriptionId);
                        svpRec.Subscription_Vendor__c = svRec.ID;
                    } else {
                        svpRec.Subscription_Vendor__c = mapManager.getIDFromSubscriptionVendorMap(vPublicationCode, subVenMap);
                    }
                    
                    svpRec.Mon__c = vMon;
                    svpRec.Tue__c = vTue;
                    svpRec.Wed__c = vWed;
                    svpRec.Thu__c = vThu;
                    svpRec.Fri__c = vFri;
                    svpRec.Sat__c = vSat;
                    svpRec.Sun__c = vSun;
                    svpRec.PHd__c = vPHd;
                    svpRec.PHe__c = vPHe;

                    forInsertList.add(svpRec);                          
                }
                //Nitin Khanna : UD-3435 - PD-0081 : 23-12-2015 : adding an extra block to insert SVP recors in case its an update request but no records are found :End
            }
            
            //Create new record if no match found on both maps.
            if (vSubscriptionUpdateIndicator.trim().equalsIgnoreCase('A')) {
                System.debug(loggingLevel.INFO,'VSS085DX DEF: Add Indicator');
                Subscription_Vendor_Publication__c svpRec = new Subscription_Vendor_Publication__c();               
                Account accountRecord = hdsAccountsMap.get(vHdsRecipientId);
                Publication__c publication = publicationMap.get(vPublicationCode);
                svpRec.Account__c = accountRecord.Id;
                svpRec.Publication__c = publication.Id;
                svpRec.HDS_Subscription_Id__c = vHdsSubscriptionId;

                Map<String, ID> subVenMap = accountSubscriptionVendorMap.get(vHdsRecipientId);

                if (StringUtility.validate(vCrsmSubscriptionId)=='0'&&subVenMapX.containsKey(vCrsmSubscriptionId)) {                
                    Subscription_Vendor__c svRec = subVenMapX.get(vCrsmSubscriptionId);
                    svpRec.Subscription_Vendor__c = svRec.ID;
                } else {
                    svpRec.Subscription_Vendor__c = mapManager.getIDFromSubscriptionVendorMap(vPublicationCode, subVenMap);
                }
                
                svpRec.Mon__c = vMon;
                svpRec.Tue__c = vTue;
                svpRec.Wed__c = vWed;
                svpRec.Thu__c = vThu;
                svpRec.Fri__c = vFri;
                svpRec.Sat__c = vSat;
                svpRec.Sun__c = vSun;
                svpRec.PHd__c = vPHd;
                svpRec.PHe__c = vPHe;

                forInsertList.add(svpRec);                          
            }
            
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert forInsertList;
            update forUpdateList;
        } catch(Exception e) {    
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('VSS085DX: Manage Subscriptions Vendor Publications Processing Failed.' + e.getMessage());
        }
        
        mapManager.setSubVenPubListForInsert(forInsertList);
    }
    //END 2015/10/07 Renino Niefes UD-2898 changed the logic for managing subscription vendor publications for "Update" scenario       
}