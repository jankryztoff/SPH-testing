/**
 * Trigger Name: BT_TH_VSS085DX_ManageOrders
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/05/25 Renino Niefes added setter method for Subscription Vendor Map
 * History: 2015/06/03 Renino Niefes hotfix: updated the Subscription Vendor Mapping
 * History: 2015/06/04 Renino Niefes hotfix: fixed the bug that returns null subscription vendor ID
 * History: 2015/09/22 UD-2898 Renino Niefes hotfix in UAT2: fixed the bug "SObject row was retrieved via SOQL without querying the requested field: Account.AccountNumber" on BT_TH_VSS085DX_ManageMaps.getAccountsMapByCRSMAccountNumber
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW
 * History: 2015/10/07 Renino Niefes UD-2898 added new methods for this defect 
 * History: 2015/10/15 Renino Niefes UD-2898 hotfixed in uat2 using recipient_number__c instead.
 */
 
 
public class BT_TH_VSS085DX_ManageMaps
{   
    //START 2015/10/07 Renino Niefes UD-2898 added new methods for this defect 
    Map<String, Singpost_Address__c> singpostMap = null;
    Map<String, Publication__c> publicationMap = null;
    Map<String, Account> vendorMap = null;
    Map<String, Address__c> addressMap = null;
    Map<String, Account> hdsAccountsMap = null;
    Map<String, Account> crsmAccountsMap = null;
    Map<String, ID> addrAccountsMap = null;
    Map<ID, Account> accountsMap = null;
    Map<String, Contact> contactsMap = null;
    Map<String, Contact> contactsMapByID = null;
    Map<ID, Subscription_Vendor__c> subVendorMap = null;
    Map<String, Map<String, ID>> accountSubscriptionVendorMap = null;   
    Map<String, Subscription_Vendor_Publication__c> subVenPubMap = null;
    Map<String, List<Subscription_Vendor_Publication__c>> subVenPubMapByID = null;
    
    List<Subscription_Vendor_Publication__c> subVenPubList = null;
    
    public Map<String, Singpost_Address__c> getSingpostMap(Set<String> postalCodesSet) {
        if (StringUtility.validate(singpostMap)=='1') {
            singpostMap = new Map<String, Singpost_Address__c>();
            List<Singpost_Address__c> postalCodeList = [SELECT ID, Name FROM Singpost_Address__c WHERE Name IN :postalCodesSet ];
            for (Singpost_Address__c saddr : postalCodeList) {
                singpostMap.put(saddr.Name,saddr);
            }
            BT_CO_INT_Utilities.log('VSS085DX: getSingpostMap');
        }
    
        return singpostMap;
    }
    
    public Map<String, Publication__c> getPublicationMap() {
        if (StringUtility.validate(publicationMap)=='1') {
            publicationMap = new Map<String, Publication__c>();
            List<Publication__c> pubList = [SELECT Id,Publication_Code__c FROM Publication__c WHERE Publication_Type__c = 'N' AND Platform_Type__c = 'Print'];
            for (Publication__c pub : pubList) {
                publicationMap.put(pub.publication_code__c,pub);
            }
            BT_CO_INT_Utilities.log('VSS085DX: getPublicationMap');
        }
        
        return publicationMap;
    }
    
    public Map<String, Account> getVendorMap(Set<String> vendorCodeSet) {
        if (StringUtility.validate(vendorMap)=='1') {
            vendorMap = new Map<String, Account>();
            List<Account> vendorsList = [SELECT ID, vendor_group__c, vendor_code__c FROM Account WHERE vendor_code__c IN :vendorCodeSet];
            for (Account acct : vendorsList) {
                vendorMap.put(acct.vendor_code__c,acct);
            }
            BT_CO_INT_Utilities.log('VSS085DX: getVendorMap');
        }   
    
        return vendorMap;
    }
    
    public Map<String, Address__c> getAddressMap(Set<String> postalCodeSet, Set<String> levelSet, Set<String> unitSet,  Boolean refreshMap) {
        if (StringUtility.validate(addressMap)=='1'||refreshMap) {
            addressMap = new Map<String, Address__c>();
            List<Address__c> addressList = [SELECT ID, Block_House_Number__c, Building_Name__c, Level_Number__c, Postal_Code__r.Name, Name, Street_Name__c, Unit_Number__c
                                FROM Address__c
                                WHERE Postal_Code__r.Name IN :postalCodeSet
                                    AND Unit_Number__c IN :unitSet
                                    AND Level_Number__c IN :levelSet ];
            for (Address__c addr : addressList) {
                String strAddrKey = addr.Postal_Code__r.Name + addr.Unit_Number__c + addr.Level_Number__c;
                addressMap.put(strAddrKey,addr);
            }
            BT_CO_INT_Utilities.log('VSS085DX: getAddressMap');
        }
        
        return addressMap;
    }
    
    public Map<String, Account> getAccountsMapByHDSRecipientId(Set<String> hdsRecipientIDSet, Boolean refreshMap) {
        //Search by HDS Recipient ID                                        
        if (StringUtility.validate(hdsAccountsMap)=='1'||refreshMap) {
            hdsAccountsMap = new Map<String, Account>();
            list<Account> accountsList = [SELECT ID, HDS_Recipient_Id__c, Name, Company_Name__c,
                                          Email__c, NRIC__c, Office_Extension__c, Office_Number__c, Phone
                                           FROM Account WHERE HDS_Recipient_Id__c IN :hdsRecipientIDSet ];
                                           
            for (Account acc : accountsList) {
                hdsAccountsMap.put(acc.HDS_Recipient_Id__c,acc);
            }
            BT_CO_INT_Utilities.log('VSS085DX: getAccountsMapByHDSRecipientId');            
        }
        return hdsAccountsMap;
    }
    
    public Map<String, Account> getAccountsMapByCRSMAccountNumber(Set<String> crsmAccountNumberSet, Boolean refreshMap) {       
        if (StringUtility.validate(crsmAccountsMap)=='1'||refreshMap) {
            crsmAccountsMap = new Map<String, Account>();
            List<Account> accountsList = [SELECT ID, HDS_Recipient_Id__c, Name, Company_Name__c,
                               Email__c, NRIC__c, Office_Extension__c, Office_Number__c, Phone, AccountNumber  //START/END 2015/09/22 UD-2898 Renino Niefes hotfix in UAT2
                               FROM Account WHERE AccountNumber IN :crsmAccountNumberSet    ];
            for (Account acc : accountsList) {
                crsmAccountsMap.put(acc.AccountNumber,acc);
            }
            BT_CO_INT_Utilities.log('VSS085DX: getAccountsMapByCRSMAccountNumber');         
        }
        return crsmAccountsMap;
    }
    
    public Map<String, ID> getAccountsMapByNameAndAddress(Set<String> accountNameSet, Set<String> postalCodeSet, Set<String> levelSet, Set<String> unitSet, Boolean refreshMap) {       
        if (StringUtility.validate(addrAccountsMap)=='1'||refreshMap) {
            addrAccountsMap = new Map<String, ID>();
            
            List<Contact> contactsList = [SELECT Account.ID, 
                                    Account.Name,
                                    Address__r.Postal_Code__r.Name,
                                    Address__r.Unit_Number__c,
                                    Address__r.Level_Number__c
                                FROM Contact 
                                WHERE Account.Name in :accountNameSet
                                    AND Address__r.Postal_Code__r.Name IN :postalCodeSet
                                    AND Address__r.Unit_Number__c IN :unitSet
                                    AND Address__r.Level_Number__c IN :levelSet
                                    AND Billing_Indicator__c = TRUE
                                    ];
            
            List<ID> crsmAccountIDSet = new List<ID>();
            for (Contact con : contactsList) {
                String searchString = con.Account.Name + con.Address__r.Postal_Code__r.Name +
                                      con.Address__r.Unit_Number__c + con.Address__r.Level_Number__c;
                addrAccountsMap.put(searchString, con.Account.ID);
            }
            BT_CO_INT_Utilities.log('VSS085DX: getAccountsMapByNameAndAddress');                        
        }
        return addrAccountsMap;     
    }
    
    public Map<ID, Account> getAccountsMapByID(List<ID> crsmAccountIDList, Boolean refreshMap) {        
        if (StringUtility.validate(accountsMap)=='1'||refreshMap) {
            accountsMap = new Map<ID, account>();
            List<Account> accountsList = [SELECT ID, HDS_Recipient_Id__c, Name, Company_Name__c,
                               Email__c, NRIC__c, Office_Extension__c, Office_Number__c, Phone
                               FROM Account WHERE ID IN :crsmAccountIDList  ];
            for (Account acc : accountsList) {
                accountsMap.put(acc.ID,acc);
            }
            BT_CO_INT_Utilities.log('VSS085DX: getAccountsMapByID');
        }
        return accountsMap;
    }
    
    public Map<String, Contact> getContactsMap(Set<String> hdsContactIDList, Boolean refreshMap) {
        if (StringUtility.validate(contactsMap)=='1'||refreshMap) {
            contactsMap = new Map<String, Contact>();
            List<Contact> contactsList = [SELECT ID, HDS_Contact_Id__c, HomePhone__c, Office_Number__c, 
                                Office_Extension__c,Fax__c,Mobile_Number__c, Email__c, NRIC__c, Company_Name__c,
                                Salutation,Recipient_Number__c, Recipient_Number_Show__c, Billing_Indicator__c, Recipient_Indicator__c,
                                Name, LastName,
                                Address__r.Postal_Code__r.Name,
                                Address__r.Unit_Number__c,
                                Address__r.Level_Number__c
                            FROM Contact WHERE HDS_Contact_Id__c IN :hdsContactIDList ];


            for (Contact con : contactsList) {                              
                contactsMap.put(con.HDS_Contact_Id__c,con);     
            }
            BT_CO_INT_Utilities.log('VSS085DX: getContactsMap');
        }
        return contactsMap;
    }
    //start 2015/10/15 Renino Niefes UD-2898 hotfixed in uat2 using recipient_number__c instead.
    public Map<String, Contact> getContactsMapByCRSMId(Set<String> crsmRecipientIdList, Boolean refreshMap) {
        Set<Decimal> crsmRecipientIdList2 = new Set<Decimal>();
        for (String recipientId : crsmRecipientIdList) {
            try {
                crsmRecipientIdList2.add(Decimal.valueOf(recipientId));
            } catch (Exception e) {
                System.debug(recipientId + ' is not a valid decimal value. ');
            }
        }
        if (StringUtility.validate(contactsMap)=='1'||refreshMap) {
            contactsMapByID = new Map<String, Contact>();
            List<Contact> contactsList = [SELECT ID, HDS_Contact_Id__c, HomePhone__c, Office_Number__c, 
                                Office_Extension__c,Fax__c,Mobile_Number__c, Email__c, NRIC__c, Company_Name__c,
                                Salutation,Recipient_Number__c, Recipient_Number_Show__c, Billing_Indicator__c, Recipient_Indicator__c,
                                Name, LastName,
                                Address__r.Postal_Code__r.Name,
                                Address__r.Unit_Number__c,
                                Address__r.Level_Number__c
                            FROM Contact WHERE Recipient_Number__c IN :crsmRecipientIdList2 ];


            for (Contact con : contactsList) {                              
                contactsMapByID.put(con.Recipient_Number_Show__c,con);     
            }
            BT_CO_INT_Utilities.log('VSS085DX: getContactsMap');
        }
        return contactsMapByID;
    }
    //2015/10/15 Renino Niefes UD-2898 hotfixed in uat2 using recipient_number__c instead.
    public Map<ID, Subscription_Vendor__c> getSubscriptionVendorMap(List<Account> accountList, Boolean refreshMap) {        
        if (StringUtility.validate(subVendorMap)=='1'||refreshMap) {
            List<ID> accountIDList = new List<ID>();
            for (Account acc : accountList) {
                accountIDList.add(acc.ID);
            }
        
            subVendorMap = new Map<ID, Subscription_Vendor__c>();
            List<Subscription_Vendor__c> subVenList = [SELECT ID, Account__r.ID, Vendor__c, Recipient__c, 
                                            Subscription_Start_Date__c, Subscription_Stop_Date__c,
                                            HDS_Subscription_Id__c 
                                            FROM Subscription_Vendor__c WHERE Account__r.ID IN :accountIDList 
                                            
                                ];


            for (Subscription_Vendor__c sv : subVenList) {                              
                subVendorMap.put(sv.ID,sv);     
            }
            BT_CO_INT_Utilities.log('VSS085DX: getSubscriptionVendorMap');
        }

        return subVendorMap;
    }   
    
    public Map<String, Map<String, ID>> getSubscriptionVendorIDMapByAccount(List<Account> accountList, Boolean refreshMap) {
        if (StringUtility.validate(accountSubscriptionVendorMap)=='1'||refreshMap) {
            List<ID> accountIDList = new List<ID>();
            for (Account acc : accountList) {
                accountIDList.add(acc.ID);
            }
            
            accountSubscriptionVendorMap = new Map<String, Map<String, ID>>();
            List<Subscription_Vendor_Publication__c> subVenPubList = [
                        SELECT Subscription_Vendor__r.ID,
                            Subscription_Vendor__r.Account__r.HDS_Recipient_Id__c,
                            Subscription_Vendor__r.Account__c, 
                            Subscription_Vendor__r.Account__r.Id, 
                            Subscription_Vendor__r.Vendor__c,
                            Subscription_Vendor__r.Recipient__c, 
                            Subscription_Vendor__r.Subscription_Start_Date__c,
                            Subscription_Vendor__r.Subscription_Stop_Date__c,
                            Subscription_Vendor__r.HDS_Subscription_Id__c,
                            Publication__r.Publication_Code__c
                        FROM Subscription_Vendor_Publication__c WHERE Subscription_Vendor__r.Account__r.ID IN :accountIDList
                        ];
                        
            for (Subscription_Vendor_Publication__c svpRec : subVenPubList) {                               
                Map<String, ID> subVenMap = null;
                if (svpRec.Subscription_Vendor__r.Account__r.HDS_Recipient_Id__c!=null) {
                    if (!accountSubscriptionVendorMap.containsKey(svpRec.Subscription_Vendor__r.Account__r.HDS_Recipient_Id__c)) {
                        subVenMap = new  Map<String, ID>();
                        accountSubscriptionVendorMap.put(svpRec.Subscription_Vendor__r.Account__r.HDS_Recipient_Id__c,subVenMap);
                    } else {
                        subVenMap = accountSubscriptionVendorMap.get(svpRec.Subscription_Vendor__r.Account__r.HDS_Recipient_Id__c);
                    }
                    
                    String pubCode = svpRec.Publication__r.Publication_Code__c.trim();
                    if (pubCode.equalsIgnoreCase('ST')||pubCode.equalsIgnoreCase('SUT')) {
                        System.debug('VSS085DX: W1 STSUT');
                        subVenMap.put('STSUT',svpRec.Subscription_Vendor__r.ID);
                    } else if (pubCode.equalsIgnoreCase('TM')||pubCode.equalsIgnoreCase('TMS')) {
                        System.debug('VSS085DX: W1 TMTMS');
                        subVenMap.put('TMTMS',svpRec.Subscription_Vendor__r.ID);
                    } else if (pubCode.equalsIgnoreCase('NP')||pubCode.equalsIgnoreCase('TNPS')) {                  
                        System.debug('VSS085DX: W1 NPTNPS');
                        subVenMap.put('NPTNPS',svpRec.Subscription_Vendor__r.ID);
                    } else if (pubCode.equalsIgnoreCase('BH')||pubCode.equalsIgnoreCase('BM')) {                        
                        System.debug('VSS085DX: W1 BHBM');
                        subVenMap.put('BHBM',svpRec.Subscription_Vendor__r.ID);
                    }
                    
                    //For everything else, add to map, including grouped publications e.g. ST/SUT TM/TMS NP/TNPS BH/BM
                    System.debug('VSS085DX: W2 ' + pubCode + ' ' + svpRec.Subscription_Vendor__r.ID);
                    subVenMap.put(pubCode,svpRec.Subscription_Vendor__r.ID);                    
                }           
            }
            BT_CO_INT_Utilities.log('VSS085DX: getSubscriptionVendorIDMap');
        }
        
        return accountSubscriptionVendorMap;
    }
    
    public void setSubscriptionVendorIDMapByAccount(Map<String, Map<String, ID>> svMap) {
        this.accountSubscriptionVendorMap = svMap;
    }
    
    public void printOutAccountSubscriptionVendorMap(Map<String, Map<String, ID>> accountSubscriptionVendorMap) {
        Set<String> hdsRepSet = accountSubscriptionVendorMap.keySet();
        BT_CO_INT_Utilities.log('VSS085DX: y1 ' + accountSubscriptionVendorMap.size());
        for (String str1 : hdsRepSet) {
            Map<String, ID> subVenMapX = accountSubscriptionVendorMap.get(str1);
            BT_CO_INT_Utilities.log('VSS085DX: y2 ' + subVenMapX.size());
            Set<String> hdsSubVenSet = subVenMapX.keySet();         
            for (String str2 : hdsSubVenSet) {
                ID myID = subVenMapX.get(str2);
                BT_CO_INT_Utilities.log('VSS085DX: y3 ' + str1 + ' - ' + str2 + ' - ' + myID);
            }
        }
    }

    public ID getIDFromSubscriptionVendorMap(String vPublicationCode, Map<String, ID> subVenMap) {
        ID subVenID = null;     
        if (vPublicationCode.equalsIgnoreCase('ST')||vPublicationCode.equalsIgnoreCase('SUT')) {
            System.debug('VSS085DX: Q1 STSUT');
            if (subVenMap.containsKey('STSUT')) subVenID = subVenMap.get('STSUT');
        } else if (vPublicationCode.equalsIgnoreCase('TM')||vPublicationCode.equalsIgnoreCase('TMS')) {
            System.debug('VSS085DX: Q1 TMTMS');     
            if (subVenMap.containsKey('TMTMS')) subVenID = subVenMap.get('TMTMS');
        } else if (vPublicationCode.equalsIgnoreCase('NP')||vPublicationCode.equalsIgnoreCase('TNPS')) {                    
            System.debug('VSS085DX: Q1 NPTNPS');
            if (subVenMap.containsKey('NPTNPS')) subVenID = subVenMap.get('NPTNPS');
        } else if (vPublicationCode.equalsIgnoreCase('BH')||vPublicationCode.equalsIgnoreCase('BM')) {                      
            System.debug('VSS085DX: Q1 BHBM');
            if (subVenMap.containsKey('BHBM')) subVenID = subVenMap.get('BHBM');
        } else {
            System.debug('VSS085DX: Q1 ' + vPublicationCode);
            if (subVenMap.containsKey(vPublicationCode)) subVenID = subVenMap.get(vPublicationCode.trim());
        }
        
        
        //This will override the group IDs if the individual IDs of the subscription is not the same e.g. Migrated Data
        ID subVenID2 = null;
        if (subVenMap.containsKey(vPublicationCode)) subVenID2 = subVenMap.get(vPublicationCode.trim());
        System.debug('VSS085DX: Q2 ' + subVenID2);
        
        if (subVenID2!=null&&subVenID2!=subVenID) {
            System.debug('VSS085DX: Q3 ' + subVenID2);
            return subVenID2;
        } else {
            System.debug('VSS085DX: Q4 ' + subVenID);
            return subVenID;
        }
    }
    
    public void addToSubscriptionVendorMap(String vPublicationCode, Map<String, ID> subVenMap, ID subVenID) {
        BT_CO_INT_Utilities.log('VSS085DX: q1 ' + vPublicationCode + ' ' + subVenID);
        if (vPublicationCode.equalsIgnoreCase('ST')||vPublicationCode.equalsIgnoreCase('SUT')) {
            subVenMap.put('STSUT',subVenID);
        } else if (vPublicationCode.equalsIgnoreCase('TM')||vPublicationCode.equalsIgnoreCase('TMS')) {
            subVenMap.put('TMTMS',subVenID);
        } else if (vPublicationCode.equalsIgnoreCase('NP')||vPublicationCode.equalsIgnoreCase('TNPS')) {                    
            subVenMap.put('NPTNPS',subVenID);
        } else if (vPublicationCode.equalsIgnoreCase('BH')||vPublicationCode.equalsIgnoreCase('BM')) {                      
            subVenMap.put('BHBM',subVenID);
        }
        
        subVenMap.put(vPublicationCode,subVenID);               
        BT_CO_INT_Utilities.log('VSS085DX: x9 ' + subVenMap.size());        
    }   
    
    public boolean checkIfPubCodeExistInSubscriptionVendorMap(String vPublicationCode, Map<String, ID> subVenMap) {
        boolean ifExist = false;
        if (vPublicationCode.equalsIgnoreCase('ST')||vPublicationCode.equalsIgnoreCase('SUT')) {
            if (subVenMap.containsKey('STSUT')) ifExist = true;
        } else if (vPublicationCode.equalsIgnoreCase('TM')||vPublicationCode.equalsIgnoreCase('TMS')) {
            if (subVenMap.containsKey('TMTMS')) ifExist = true;
        } else if (vPublicationCode.equalsIgnoreCase('NP')||vPublicationCode.equalsIgnoreCase('TNPS')) {                    
            if (subVenMap.containsKey('NPTNPS')) ifExist = true;
        } else if (vPublicationCode.equalsIgnoreCase('BH')||vPublicationCode.equalsIgnoreCase('BM')) {                      
            if (subVenMap.containsKey('BHBM')) ifExist = true;
        }
        
        if (subVenMap.containsKey(vPublicationCode)) ifExist = true;
        return ifExist;
    }   
    
    public List<ID> getSubVenIDListfromAccountSubscriptionVendorMap(Map<String, Map<String, ID>> accountSubscriptionVendorMap) {
        List<ID> subVenIDList = new List<ID>();
        Set<String> hdsRepSet = accountSubscriptionVendorMap.keySet();
        for (String str1 : hdsRepSet) {
            Map<String, ID> subVenMapX = accountSubscriptionVendorMap.get(str1);
            Set<String> hdsSubVenSet = subVenMapX.keySet();         
            for (String str2 : hdsSubVenSet) {
                ID myID = subVenMapX.get(str2);
                if (StringUtility.validate(myID)=='0') subVenIDList.add(myID);
            }
        }
        return subVenIDList;
    }
    
    public Map<String, Subscription_Vendor_Publication__c> getSubVenPublicationMap(List<String> hdsSubscriptionIDList, List<ID> subvenIDList, Boolean refreshMap) {
        if (StringUtility.validate(subVenPubMap)=='1'||refreshMap) {
            subVenPubMap = new Map<String, Subscription_Vendor_Publication__c>();
            List<Subscription_Vendor_Publication__c> subVenPubList = [
                    SELECT ID, 
                        HDS_Subscription_Id__c, 
                        Subscription_Vendor__r.ID, 
                        Subscription_vendor__r.Account__r.ID,
                        Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c                      
                    FROM Subscription_Vendor_Publication__c 
                    WHERE Subscription_Vendor__c IN :subvenIDList
                        AND HDS_Subscription_Id__c IN :hdsSubscriptionIDList
                    order by HDS_Subscription_Id__c ];
                    
                    
            for (Subscription_Vendor_Publication__c rec : subVenPubList) {
                subVenPubMap.put(rec.HDS_Subscription_Id__c, rec);
            }
        }
        return subVenPubMap;
    }
    
    public Map<String, List<Subscription_Vendor_Publication__c>> getSubVenPublicationMapByCRSMSubID(List<String> subvenIDList, Boolean refreshMap) {
        if (StringUtility.validate(subVenPubMapByID)=='1'||refreshMap) {
            subVenPubMapByID = new Map<String, List<Subscription_Vendor_Publication__c>>();
            List<Subscription_Vendor_Publication__c> subVenPubList = [
                    SELECT ID, 
                        HDS_Subscription_Id__c, 
                        Subscription_Vendor__r.ID, 
                        Subscription_vendor__r.Account__r.ID,
                        Subscription_vendor__r.Name,
                        Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c,
                        Publication__r.Publication_Code__c
                    FROM Subscription_Vendor_Publication__c 
                    WHERE Subscription_Vendor__r.Name IN :subvenIDList                       
                    order by Subscription_Vendor__r.Name ];
                    
                    
            for (Subscription_Vendor_Publication__c rec : subVenPubList) {
                System.debug(loggingLevel.INFO,'VSS085DX DEF:  getSubVenPublicationMapByCRSMSubID Sub Vendor ID : ' + rec.Subscription_Vendor__r.Name);
                System.debug(loggingLevel.INFO,'VSS085DX DEF:  getSubVenPublicationMapByCRSMSubID Publication Code : ' + rec.Publication__r.Publication_Code__c);
                
                List<Subscription_Vendor_Publication__c> list1 = null;
                if (subVenPubMapByID.containsKey(rec.Subscription_Vendor__r.Name)) {
                    System.debug(loggingLevel.INFO,'VSS085DX DEF:  getSubVenPublicationMapByCRSMSubID  line 430 ');
                    list1 = subVenPubMapByID.get(rec.Subscription_Vendor__r.Name);
                    if (list1==null) {
                        System.debug(loggingLevel.INFO,'VSS085DX DEF:  getSubVenPublicationMapByCRSMSubID  line 434 ' + rec.Publication__r.Publication_Code__c);
                        list1 = new List<Subscription_Vendor_Publication__c>();
                    }
                } else{
                    System.debug(loggingLevel.INFO,'VSS085DX DEF:  getSubVenPublicationMapByCRSMSubID  line 438 ' + rec.Publication__r.Publication_Code__c);
                    list1 = new List<Subscription_Vendor_Publication__c>();                 
                } 
                list1.add(rec);
                subVenPubMapByID.put(rec.Subscription_Vendor__r.Name, list1);
            }
            
            for (String subId : subvenIDList) {
                if (!subVenPubMapByID.containsKey(subId)) {
                    List<Subscription_Vendor_Publication__c> list1 = new List<Subscription_Vendor_Publication__c>();
                    subVenPubMapByID.put(subId, list1);
                }
            }
        }
        return subVenPubMapByID;
    }   

    public List<Subscription_Vendor_Publication__c>  getSubVenPubListForInsert() {
        return this.subVenPubList;
    }
    
    public void setSubVenPubListForInsert(List<Subscription_Vendor_Publication__c> subVenPubList) {
        this.subVenPubList = subVenPubList;
    }
    
    
   public Map<String, Subscription_Vendor__c> getSubscriptionVendorsList(List<String> crsmSubscriptionIDList) {    
        Map<String, Subscription_Vendor__c> subVenPubMapX = new Map<String, Subscription_Vendor__c>();
        if (StringUtility.validate(crsmSubscriptionIDList)=='0') {
            List<Subscription_Vendor__c> subVenList = [SELECT ID, Account__r.ID, Vendor__c, Recipient__c, 
                                        Subscription_Start_Date__c, Subscription_Stop_Date__c,
                                        HDS_Subscription_Id__c,Name,Reason__c
                                        FROM Subscription_Vendor__c WHERE Name IN :crsmSubscriptionIDList                                       
                            ];

            
            for (Subscription_Vendor__c svRec : subVenList) {
                subVenPubMapX.put(svRec.Name, svRec);
            }
        }
        return subVenPubMapX;   
    }   
    //END 2015/10/07 Renino Niefes UD-2898 added new methods for this defect 
}