/**
 * Trigger Name: BT_TH_VSS085DX_ManageAddresses
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW
 */
 
 
public class BT_TH_VSS085DX_ManageAddresses
{   
    public void execute(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList, BT_TH_VSS085DX_ManageMaps mapManager) {
        Set<String> postalCodeSet = new Set<String>();
        Set<String> levelSet = new Set<String>();
        Set<String> unitSet = new Set<String>();
        Set<String> addressKeySet = new Set<String>();
        
        Map<String, Address__c> addressMap = null;
        Map<String, Singpost_Address__c> singpostMap = null;
        
        List<Address__c> forInsertList = new List<Address__c>();
        
        //Prepare the Sets of strings to generate the address map
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vSubscriberPostalCode = so.SubscriberPostalCode__c;
            String vRecipientPostalCode = so.RecipientPostalCode__c;
            String vSubscriberLevel = so.SubscriberLevel__c;
            String vRecipientLevel = so.RecipientLevel__c;
            String vSubscriberUnit = so.SubscriberUnit__c;
            String vRecipientUnit = so.RecipientUnit__c;

            
            if (StringUtility.validate(vSubscriberPostalCode)=='0') postalCodeSet.add(vSubscriberPostalCode.trim());            
            if (StringUtility.validate(vRecipientPostalCode)=='0') postalCodeSet.add(vRecipientPostalCode.trim());

            if (StringUtility.validate(vSubscriberLevel)=='0') levelSet.add(vSubscriberLevel.trim());           
            if (StringUtility.validate(vRecipientLevel)=='0') levelSet.add(vRecipientLevel.trim());
            
            if (StringUtility.validate(vSubscriberUnit)=='0') unitSet.add(vSubscriberUnit.trim());
            if (StringUtility.validate(vRecipientUnit)=='0') unitSet.add(vRecipientUnit.trim());
            
        }
        
        //Generate the address map
        addressMap = mapManager.getAddressMap(postalCodeSet, levelSet, unitSet, false);
        singpostMap = mapManager.getSingpostMap(postalCodeSet);

        //Iterate again through records to process them
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            String vSubscriberHouseBlockNumber = so.SubscriberHouseBlockNumber__c;
            String vRecipientHouseBlockNumber = so.RecipientHouseBlockNumber__c;
            String vSubscriberPostalCode = so.SubscriberPostalCode__c;
            String vRecipientPostalCode = so.RecipientPostalCode__c;
            String vSubscriberLevel = so.SubscriberLevel__c;
            String vRecipientLevel = so.RecipientLevel__c;
            String vSubscriberUnit = so.SubscriberUnit__c;
            String vRecipientUnit = so.RecipientUnit__c;
            
            String strAddrKey1 = vSubscriberPostalCode + vSubscriberUnit + vSubscriberLevel;
            String strAddrKey2 = vRecipientPostalCode + vRecipientUnit + vRecipientLevel;
            
            if (addressKeySet.contains(strAddrKey1)==false
                &&addressMap.containsKey(strAddrKey1)==false
                &&singpostMap.containsKey(vSubscriberPostalCode)) { 
                
                addressKeySet.add(strAddrKey1);
                Singpost_Address__c singpost = singpostMap.get(vSubscriberPostalCode);
                Address__c billingAddress = new Address__c();
                
                billingAddress.Postal_Code__c = singpost.Id;
                billingAddress.Block_House_Number__c = vSubscriberHouseBlockNumber;
                billingAddress.Level_Number__c = vSubscriberLevel;
                billingAddress.Unit_Number__c = vSubscriberUnit;
                
                forInsertList.add(billingAddress);
            }
            
            if (addressKeySet.contains(strAddrKey2)==false
                &&addressMap.containsKey(strAddrKey2)==false
                &&singpostMap.containsKey(vRecipientPostalCode)) {
                
                addressKeySet.add(strAddrKey2);
                Singpost_Address__c singpost = singpostMap.get(vRecipientPostalCode);
                Address__c recipientAddress = new Address__c();
                
                recipientAddress.Postal_Code__c = singpost.Id;
                recipientAddress.Block_House_Number__c = vRecipientHouseBlockNumber;
                recipientAddress.Level_Number__c = vRecipientLevel;
                recipientAddress.Unit_Number__c = vRecipientUnit;
                
                forInsertList.add(recipientAddress);
            }
        }

        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert forInsertList;
        } catch(Exception e) {    
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('VSS085DX: Address Processing Failed.' + e.getMessage());           
        }

        //RE-Generate the address map
        addressMap = mapManager.getAddressMap(postalCodeSet, levelSet, unitSet, true);      
                
        
    }
        
}