/**
* Class Name: BatchAddressAssignmentEffectiveDate 
* @author: Christopher C. Camilon
* Date: 10/10/2014
* Requirement/Project Name: Singapore Press Holdings
* @description Batch class that updates the contact when the effective date
  of Address Assignment record is equal to Date today
* History: [JES 1/9/15] Update COA process for Address Assignment
* History: [Raviteja 19-Mar-2015] Update COA - Update the recipient contact in Delivery Subscription as well
* History: [C. Lin 30Nov2015] Revert the fix for UD-2868. Bring back the Auto Creation of New Contact depending on the created COA Case/Address Assignment
*/
global class BatchAddressAssignmentEffectiveDate implements  Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bc- predefined parameter 
    * @return list of objects from Address Assignment Object
    */ 
    
    //START: D-0974 1/14/2015 Added By J. Sarion - Implement new process for COA
    List<String> conZuoraIdList = new List<String>();
    List<Map<String, Object>> subMapList = new List<Map<String, Object>>();
    //START D-2547 19-Mar-2015 Added by Raviteja  - COA Change preparing deliverysubMapList to update the recipient contact in Delivery Subscription as well
    List<Map<String, Object>> deliverysubMapList = new List<Map<String, Object>>();
    Map<String,String> deliverySubzouraidmap = New Map<String,String>();
    //START UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
    global Map<ID, Set<String>> mapNewContactToSub = new Map<ID, Set<String>>();
    //END UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
    global Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
    //End D-2547 19-Mar-2015 Added by Raviteja
    //START D-2228 2/17/2015 Added By J.Sarion - Added criteria to WHERE clause
    Set<Id> postalCodeIdSet = new Set<Id>();
    //END D-2228 2/17/2015 Added By J.Sarion
    //START D-2258 3/5/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
    List<Map<String, Object>> billSubMapList = new List<Map<String, Object>>();
    //END D-2258 3/5/2015 Added By C. Lin
    //START UD-0539 4/23/2015 Added By C. Lin - Fix Batch Error for Too Many Callouts
    List<Map<String, Object>> lConList = new List<Map<String, Object>>();
    //END UD-0539 4/23/2015 Added By C. Lin
    //START D-2915 5/14/2015 Added By C. Lin - CCB COA
    //Map<Id, Address_Assignment__c> conIdToAddressAssignIdMap = new Map<Id, Address_Assignment__c>(); //START END D-4034 10Dec2015 Added By C. Lin
    //END D-2915 5/14/2015 Added By C. Lin
    //START D-2979 5/20/2015 Added By C. Lin - accounts from batch
    Set<Id> accountIdSet = new Set<Id>();
    //END D-2979 5/20/2015 Added By C. Lin
    
    //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
    Set<Id> zuoraCustomerIds = new Set<Id>();
    //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
    Logger logger; //START END D-1011 MD-28 Dags 18/06/15 - to be initialised at each execute method
    //START: D-0974 1/14/2015 Added By J. Sarion - Implement new process for COA
    
    //START D-3243 07/16/2015 Added by J.Sarion - Consolidate list for update
    List<Map<String, Object>> consolidatedSubMapList = new List<Map<String, Object>>();
    //END D-3243 07/16/2015 Added by J.Sarion - Consolidate list for update
    
    //START UD-2162 08/19/2015 Added by J.Sarion - Create Map for Delivery Charge Prices
    Map<String, Decimal> delChargeTypeToPriceMap = new Map<String, Decimal>();
    Map<String, Zuora__Subscription__c> zuoraIdToSubMap = new Map<String, Zuora__Subscription__c>();
    //END UD-2162 08/19/2015 Added by J.Sarion - Create Map for Delivery Charge Prices
  
    //START D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
    Set<String> selectiveIds = null;
    Boolean isApexJobSuccessful = true;
    //END D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
    
    //START D-4007 02Dec2015 Added By C. Lin - Uncheck the indicator for both checked contact for all publications
    Set<Id> billConIdsToUncheck = new Set<Id>();
    Set<Id> recConIdsToUncheck = new Set<Id>();
    List<Contact> contactsToUncheckList = new List<Contact>();
    Map<Id, Contact> conIdToConMap = new Map<Id, Contact>();
    //END D-4007 02Dec2015 Added By C. Lin
    
    //START UD-2162 08/26/2015 Added by J.Sarion - Get Date from Custom Setting
    Date referenceDate;
    global BatchAddressAssignmentEffectiveDate()
    {
        referenceDate = date.today();
    }
    
    global BatchAddressAssignmentEffectiveDate(Date inputDt)
    {
        referenceDate = inputDt;
    }
    //END UD-2162 08/26/2015 Added by J.Sarion - Get Date from Custom Setting
  
    //START D-3602 9/23/2015 Added By C. Lin - Constructor for specific Address Assignment record
    Id addressAssignId;
    
    global BatchAddressAssignmentEffectiveDate(Id addAssignId)
    {
        addressAssignId = addAssignId;
    }
    //END D-3602 9/23/2015 Added By C. Lin
    
    //START D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
    global BatchAddressAssignmentEffectiveDate(Set<String> selectiveIds)
    {
        this.selectiveIds = selectiveIds;
    }
    //END D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Date dt = date.today(); //START-END UD-2162 Added by J.Sarion - Commented out
        //START D-2001 2/5/2015 Added By C. Lin - Fixed COA for Vendor Subscriber Accounts. Fixed creation of new contact and updating of contact based on contact to update and subscriptions.
        //START D-2228 2/17/2015 Added By J.Sarion - Added criteria to WHERE clause
        //START D-2367 2/25/2015 Added By C. Lin - Added Active should be false in where clause
        //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments. Added End_Date__c = NULL
        //START D-2915 5/14/2015 Added By C. Lin - CCB COA
        //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
        //START UD-2162 08/26/2015 Added by J.Sarion - set referenceDate
        
        //START D-3602 9/23/2015 Added By C. Lin - Constructor for specific Address Assignment record
        //START D-4034 10Dec2015 Added By C. Lin - Execute address assignments together under each account
        /*String query = 'SELECT Id, Case__c, Case__r.Change_of_Address_Type__c, Address__c, Contact__c, Contact__r.Address__c, ';
        query += 'Effective_Date__c, Subscription__c, Subscription_Vendor__c, Active__c, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, ';
        query += 'Contact__r.Salutation, Contact__r.NRIC__c, Contact__r.Passport__c, Contact__r.Billing_Account_Name_2__c, Contact__r.Company_Name__c, ';
        query += 'Contact__r.City_Code__c, Contact__r.Remarks__c, Contact__r.Business_Address_Indicator__c, Contact__r.Recipient_Indicator__c, ';
        query += 'Contact__r.Billing_Indicator__c, Contact__r.HomePhone__c, Contact__r.Mobile_Number__c, Contact__r.Mobile_Number_2__c, Contact__r.Office_Number__c, ';
        query += 'Contact__r.Office_Extension__c, Contact__r.Fax__c, Contact__r.Email__c, Contact__r.Email_Secondary__c, LastModifiedDate, CreatedDate, Contact__r.Address__r.Postal_Code__c, Address__r.Postal_Code__c, Vendor__c ';
        query += 'FROM Address_Assignment__c WHERE ';
        
        //START D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
        if(referenceDate != null){
            query += 'Effective_Date__c = :referenceDate AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = \'Closed\'';
        }else if(addressAssignId != null){
            query += 'Id = :addressAssignId AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = \'Closed\'';
        }else if(selectiveIds != null){
            query += 'Id = :selectiveIds AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = \'Closed\'';
        }
        //END D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery*/
        
        List<Address_Assignment__c> addAssignList = new List<Address_Assignment__c>();
        Set<Id> addAssAccountsId = new Set<Id>();
        
        if(referenceDate != null){
            addAssignList = [SELECT Id, Contact__r.AccountId FROM Address_Assignment__c WHERE Effective_Date__c = :referenceDate AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = 'Closed'];
        }else if(addressAssignId != null){
            addAssignList = [SELECT Id, Contact__r.AccountId FROM Address_Assignment__c WHERE Id = :addressAssignId AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = 'Closed'];
        }else if(selectiveIds != null){
            addAssignList = [SELECT Id, Contact__r.AccountId FROM Address_Assignment__c WHERE Id = :selectiveIds AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = 'Closed'];
        }
        
        for(Address_Assignment__c addAss : addAssignList){
            addAssAccountsId.add(addAss.Contact__r.AccountId);
        }
        
        String query = 'SELECT Id, Name FROM Account WHERE Id IN :addAssAccountsId';
        //END D-4034 10Dec2015 Added By C. Lin
        
        return Database.getQueryLocator(query);
        //END D-3602 9/23/2015 Added By C. Lin
    
        //END UD-2162 08/26/2015 Added by J.Sarion - set referenceDate
        //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
        //END D-2915 5/14/2015 Added By C. Lin
        //END UD-0899 4/16/2015 Added By C. Lin
        //END D-2367 2/25/2015 Added By C. Lin
        //END D-2228 2/17/2015 Added By J.Sarion
        //END D-2001 2/5/2015 Added By C. Lin
    }
    //END: D-0974 1/14/2015 Added By J. Sarion
    
    /* @description Executes the business logic and creates/updates contact object
     * 
     * @param BC- predefined parameter 
     * @param scope - a list of sObjects from the initial database query
     * @return void
     */
    
    //START: D-0974 1/14/2015 Added By J. Sarion - Implement new process for COA
    global void execute(Database.BatchableContext BC, List<Account> scope) { //START END D-4034 Change Address_Assignment__c to Account
        //START D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
        Logger logger = new Logger(BatchAddressAssignmentEffectiveDate.class.getName(), 'SP050', BC.getJobID());
        try{
            List<Contact> contactList = new List<Contact>();
            List<Contact> conList = new List<Contact>();
            List<Contact> newContactList = new List<Contact>();
            List<Contact> updateContactList = new List<Contact>();
            List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
            List<Zuora__Subscription__c> newSubList = new List<Zuora__Subscription__c>();
            List<Zuora__Subscription__c> updateSubList = new List<Zuora__Subscription__c>();
            List<Address_Assignment__c> updateAddressAssignmentList = new List<Address_Assignment__c>();
            List<Map<String, Object>> createConMapList = new List<Map<String, Object>>();
            List<Map<String, Object>> updateConMapList = new List<Map<String, Object>>();
            Map<Contact, List<Zuora__Subscription__c>> newConToUpdateSubListMap = new Map<Contact, List<Zuora__Subscription__c>>();
            //Map<Id, Contact> conIdToConMap = new Map<Id, Contact>(); //START/END D-4007 02Dec2015 Added By C. Lin - Move out of execute method
            Map<Id, Zuora__Subscription__c> subIdToSubMap = new Map<Id, Zuora__Subscription__c>();
            Map<Id, Set<Id>> conIdToSubIdSetMap = new Map<Id, Set<Id>>();
            Map<Id, Map<Id, Map<String, Set<Id>>>> conIdAddressIdCaseRecTypeToSubIdSetMap = new Map<Id, Map<Id, Map<String, Set<Id>>>>();
            Map<Id, Contact> subdIdToNewContactMap = new Map<Id, Contact>();
            Map<String, Contact> subZuoraIdToNewContactMap = new Map<String, Contact>();
            //START D-2915 5/14/2015 Added By C. Lin - CCB COA - Move Map up
            //END D-2915 5/14/2015 Added By C. Lin
            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> subIdSet = new Set<Id>();
            Set<Id> newConDoneBillingSet = new Set<Id>();
            Set<Id> newConDoneDeliverySet = new Set<Id>();
            Set<Id> newConDoneBothSet = new Set<Id>();
            //START END D-2979 5/20/2015 Added By C. Lin - Move set up
            Set<String> deliveryAddressTypeSet = new Set<String>();
            deliveryAddressTypeSet.add(GlobalVariableClass.DELIVERYADDLOC);
            deliveryAddressTypeSet.add(GlobalVariableClass.DELIVERYADDLOCOVSEA);
            deliveryAddressTypeSet.add(GlobalVariableClass.DELIVERYADDOVSEALOC);
            deliveryAddressTypeSet.add(GlobalVariableClass.DELIVERYADDOVSEALOC);
            Boolean bothBillRec = false;
            //START D-2915 5/14/2015 Added By C. Lin - CCB COA
            Map<String, Id> subZuoraIdToNewVendorMap = new Map<String, Id>();
            Map<Id, Id> subVendorIdToNewVendorMap = new Map<Id, Id>();
            //END D-2915 5/14/2015 Added By C. Lin
          
            //START D-2258 3/4/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
            Map<Id, Set<Zuora__Subscription__c>> accountIdToSubscriptionMap = new Map<Id, Set<Zuora__Subscription__c>>();
            
            //START UD-3270 30Nov2015 Added By C. Lin
            Map<Id, Set<Zuora__Subscription__c>> billConIdToSubscriptionMap = new Map<Id, Set<Zuora__Subscription__c>>();
            Map<Id, Set<Zuora__Subscription__c>> recConIdToSubscriptionMap = new Map<Id, Set<Zuora__Subscription__c>>();
            Map<Id, Set<Subscription_Vendor__c>> recConIdToSubscriptionVendorMap = new Map<Id, Set<Subscription_Vendor__c>>();
            Boolean conIdSameWithSubRecipient = true;
            //END UD-3270 30Nov2015 Added By C. Lin
            
            Map<Id, Contact> subIdToNewContactMap = new Map<Id, Contact>();
            List<Zuora__Subscription__c> listSubscription = new List<Zuora__Subscription__c>();
            List<Order__c> newOrderList = new List<Order__c>();
            List<Order__c> newOrderListForRecipient = new List<Order__c>(); //START END D-4034 08Dec2015 Added By C. Lin - Updating Recipient Contact in Order record
            Map<Id, Address_Assignment__c> conIdToAddressAssignIdMap = new Map<Id, Address_Assignment__c>(); //START END D-4034 10Dec2015 Added By C. Lin - Move inside to execute method
            List<Zuora__CustomerAccount__c> newBillAccList = new List<Zuora__CustomerAccount__c>();
            Map<Id, Contact> billAccIdToNewContactMap = new Map<Id, Contact>();
            Map<Id, Set<Zuora__CustomerAccount__c>> conIdToBillAccSetMap = new Map<Id, Set<Zuora__CustomerAccount__c>>();
            Map<Id, Address__c> addIdToAddressMap = new Map<Id, Address__c>();

            Set<Id> billAccIdSet = new Set<Id>();
            Map<Id, Zuora__CustomerAccount__c> billAccIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
            Map<Id, Zuora__CustomerAccount__c> subIdToBillAccMap =  new Map<Id, Zuora__CustomerAccount__c>();
            //logger = new Logger(BatchAddressAssignmentEffectiveDate.class.getName(),'SP050'); //START END D-1011 MD-28 Dags 18/06/15
            //START UD-0539 4/10/2015 Added By C. Lin - Added filter for query of addresses to prevent Too Many Query Rows 5001 Error.
            Set<Id> addressIdSet = new Set<Id>();

            //START UD-2162 08/19/2015 Added by J.Sarion - Create Map for Delivery Charge Prices
            List<zqu__ProductRatePlanCharge__c> prpcList = new List<zqu__ProductRatePlanCharge__c>();
            Set<String> delUOMSet = new Set<String>();
            delUOMSet.add('LANDED');
            delUOMSet.add('APT');
            delUOMSet.add('HDB');

            prpcList = [SELECT Id, sum__c, zqu__UOM__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__UOM__c IN :delUOMSet AND zqu__Deleted__c = false AND Product_Code__c = 'DELCHG' AND zqu__Type__c = 'Usage'];

            for(zqu__ProductRatePlanCharge__c prpc :prpcList){
                if(prpc.zqu__UOM__c.toLowerCase() == 'landed'){
                    delChargeTypeToPriceMap.put('L', prpc.sum__c);
                }
                if(prpc.zqu__UOM__c.toLowerCase() == 'hdb'){
                    delChargeTypeToPriceMap.put('H', prpc.sum__c);
                }
                if(prpc.zqu__UOM__c.toLowerCase() == 'apt'){
                    delChargeTypeToPriceMap.put('C', prpc.sum__c);
                }
            }
            //END UD-2162 08/19/2015 Added by J.Sarion - Create Map for Delivery Charge Prices
            
            //START D-4034 10Dec2015 Added By C. Lin - Execute address assignments together under each account
            Set<Id> accToProcessIdSet = new Set<Id>();
            for (Account account :scope){
                if (account.Id != null) {
                    accToProcessIdSet.add(account.Id);
                }
            }
            
            List<Address_Assignment__c> scopeAddressAssignment = new List<Address_Assignment__c>();
            
            if(referenceDate != null){
                scopeAddressAssignment = [SELECT Id, Case__c, Case__r.Change_of_Address_Type__c, Address__c, Contact__c, Contact__r.Address__c, 
                    Effective_Date__c, Subscription__c, Subscription_Vendor__c, Active__c, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, 
                    Contact__r.Salutation, Contact__r.NRIC__c, Contact__r.Passport__c, Contact__r.Billing_Account_Name_2__c, Contact__r.Company_Name__c, 
                    Contact__r.City_Code__c, Contact__r.Remarks__c, Contact__r.Business_Address_Indicator__c, Contact__r.Recipient_Indicator__c, 
                    Contact__r.Billing_Indicator__c, Contact__r.HomePhone__c, Contact__r.Mobile_Number__c, Contact__r.Mobile_Number_2__c, Contact__r.Office_Number__c, 
                    Contact__r.Office_Extension__c, Contact__r.Fax__c, Contact__r.Email__c, Contact__r.Email_Secondary__c, LastModifiedDate, CreatedDate, 
                    Contact__r.Address__r.Postal_Code__c, Address__r.Postal_Code__c, Vendor__c FROM Address_Assignment__c WHERE Contact__r.AccountId IN :accToProcessIdSet AND Effective_Date__c = :referenceDate AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = 'Closed'];
            }else if(addressAssignId != null){
                scopeAddressAssignment = [SELECT Id, Case__c, Case__r.Change_of_Address_Type__c, Address__c, Contact__c, Contact__r.Address__c, 
                    Effective_Date__c, Subscription__c, Subscription_Vendor__c, Active__c, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, 
                    Contact__r.Salutation, Contact__r.NRIC__c, Contact__r.Passport__c, Contact__r.Billing_Account_Name_2__c, Contact__r.Company_Name__c, 
                    Contact__r.City_Code__c, Contact__r.Remarks__c, Contact__r.Business_Address_Indicator__c, Contact__r.Recipient_Indicator__c, 
                    Contact__r.Billing_Indicator__c, Contact__r.HomePhone__c, Contact__r.Mobile_Number__c, Contact__r.Mobile_Number_2__c, Contact__r.Office_Number__c, 
                    Contact__r.Office_Extension__c, Contact__r.Fax__c, Contact__r.Email__c, Contact__r.Email_Secondary__c, LastModifiedDate, CreatedDate, 
                    Contact__r.Address__r.Postal_Code__c, Address__r.Postal_Code__c, Vendor__c FROM Address_Assignment__c WHERE Contact__r.AccountId IN :accToProcessIdSet AND Id = :addressAssignId AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = 'Closed'];
            }else if(selectiveIds != null){
                scopeAddressAssignment = [SELECT Id, Case__c, Case__r.Change_of_Address_Type__c, Address__c, Contact__c, Contact__r.Address__c, 
                    Effective_Date__c, Subscription__c, Subscription_Vendor__c, Active__c, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, 
                    Contact__r.Salutation, Contact__r.NRIC__c, Contact__r.Passport__c, Contact__r.Billing_Account_Name_2__c, Contact__r.Company_Name__c, 
                    Contact__r.City_Code__c, Contact__r.Remarks__c, Contact__r.Business_Address_Indicator__c, Contact__r.Recipient_Indicator__c, 
                    Contact__r.Billing_Indicator__c, Contact__r.HomePhone__c, Contact__r.Mobile_Number__c, Contact__r.Mobile_Number_2__c, Contact__r.Office_Number__c, 
                    Contact__r.Office_Extension__c, Contact__r.Fax__c, Contact__r.Email__c, Contact__r.Email_Secondary__c, LastModifiedDate, CreatedDate, 
                    Contact__r.Address__r.Postal_Code__c, Address__r.Postal_Code__c, Vendor__c FROM Address_Assignment__c WHERE Contact__r.AccountId IN :accToProcessIdSet AND Id = :selectiveIds AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = 'Closed'];
            }
            //END D-4034 10Dec2015 Added By C. Lin
            
            for (Address_Assignment__c addAssign :scopeAddressAssignment){ //START END D-4034 Change scope to scopeAddressAssignment
                if (addAssign.Address__c != null) {
                    addressIdSet.add(addAssign.Address__c);
                }
            }
          
            List<Address__c> addressList = new List<Address__c>();
            
            if (addressIdSet.size() > 0){
                addressList = [SELECT Street_Name__c, Block_House_Number__c, Building_Name__c, Postal_Code__r.Building_Name__c, 
                Postal_Code__r.House_Block_Number__c, Postal_Code__r.Street_Name__c, Country_Name__c, City__r.City_Name__c, Postal_Code__r.Name
                FROM Address__c WHERE Id IN :addressIdSet];
            }
            //END UD-0539 4/10/2015 Added By C. Lin
            for(Address__c add : addressList){
                addIdToAddressMap.put(add.Id, add);
            }
            //END D-2258 3/4/2015 Added By C. Lin
            
            //START D-2001 2/5/2015 Added By C. Lin - Fixed COA for Vendor Subscriber Accounts. Fixed creation of new contact and updating of contact based on contact to update and subscriptions.
            Set<Id> subVendorIdSet = new Set<Id>();
            Map<Id, Set<Id>> conIdToSubVendorIdSetMap = new Map<Id, Set<Id>>();
            Map<Id, Map<Id, Map<String, Set<Id>>>> conIdAddressIdCaseRecTypeToSubVendorIdSetMap = new Map<Id, Map<Id, Map<String, Set<Id>>>>();
            Map<Id, Contact> subVendorIdToNewContactMap = new Map<Id, Contact>();
            List<Subscription_Vendor__c> subVendorList = new List<Subscription_Vendor__c>();
            Map<Id, Subscription_Vendor__c> subIdToSubVendorMap = new Map<Id, Subscription_Vendor__c>();
            List<Subscription_Vendor__c> newSubVendorList = new List<Subscription_Vendor__c>();
            //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
            Set<Id> subscriptionIdSet = new Set<Id>();
            Set<Id> subscriptionVendorIdSet = new Set<Id>();
            Date todayDate = date.today();
            //END UD-0899 4/16/2015 Added By C. Lin
            //START UD-0883 and UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
            Map<Id, Id> conIdToAccountIdMap = new Map <Id, Id>();
            //END UD-0883 and UD-0899 5/9/2015 Added By C. Lin
            
            //START D-2228 2/17/2015 Added By J.Sarion - Added criteria to WHERE clause
            for (Address_Assignment__c addAssign :scopeAddressAssignment){ //START END D-4034 Change scope to scopeAddressAssignment
                if (addAssign.Contact__c != null) {
                    if (addAssign.Contact__r.AccountId != null) {
                        accountIdSet.add(addAssign.Contact__r.AccountId);
                        //START UD-0883 and UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
                        conIdToAccountIdMap.put(addAssign.Contact__c, addAssign.Contact__r.AccountId);
                        //END UD-0883 and UD-0899 5/9/2015 Added By C. Lin
                    }
                }
                if (addAssign.Address__c != null && addAssign.Address__r.Postal_Code__c != null) {
                    postalCodeIdSet.add(addAssign.Address__r.Postal_Code__c);
                }
                //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
                if (addAssign.Subscription__c != null) {
                    subscriptionIdSet.add(addAssign.Subscription__c);
                }
                
                if (addAssign.Subscription_Vendor__c != null) {
                    subscriptionVendorIdSet.add(addAssign.Subscription_Vendor__c);
                }
                //END UD-0899 4/16/2015 Added By C. Lin
            }
            //END D-2228 2/17/2015 Added By J.Sarion
            
            //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
            List<Address_Assignment__c> addressAssignmentNoSubList = new List<Address_Assignment__c>();
            List<Address_Assignment__c> addressAssignmentWithSubList = new List<Address_Assignment__c>();
            List<Address_Assignment__c> addressAssignmentWithSubVendorList = new List<Address_Assignment__c>();
            Map<Id, List<Address_Assignment__c>> subIdToAddressAssignMap = new Map<Id, List<Address_Assignment__c>>();
            Map<Id, List<Address_Assignment__c>> subVendorIdToAddressAssignMap = new Map<Id, List<Address_Assignment__c>>();
            Set<Id> conIdSet = new Set<Id>();
            Set<Id> conNoSubIdSet = new Set<Id>();
            List<Zuora__Subscription__c> subscripList = new List<Zuora__Subscription__c>();
            List<Subscription_Vendor__c> subscripVendorList = new List<Subscription_Vendor__c>();
            List<Contact> listContacts = new List<Contact>();
            List<Address_Assignment__c> listAddressAssignment = new List<Address_Assignment__c>();
            
            if (accountIdSet.size() > 0){
                //START UD-0883 AND UD-0899 5/11/2015 Added By C. Lin - Added AND Zuora__SubscriptionEndDate__c >= TODAY
                subscripList = [SELECT Id, Contact__c, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Zuora__Account__c IN :accountIdSet AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND (Zuora__SubscriptionEndDate__c >= TODAY OR Zuora__TermSettingType__c = 'EVERGREEN')];
                //END UD-0883 AND UD-0899 5/11/2015 Added By C. Lin
                subscripVendorList = [SELECT Id, Recipient__c FROM Subscription_Vendor__c WHERE Account__c IN :accountIdSet AND Status__c = 'Active'];
            }
            
            if(subscripList.size() > 0){
                for(Zuora__Subscription__c zSub : subscripList){
                    conIdSet.add(zSub.Contact__c);
                    conIdSet.add(zSub.Recipient_Contact__c);
                }
            }
            
            if(subscripVendorList.size() > 0){
                for(Subscription_Vendor__c subVendor : subscripVendorList){
                    conIdSet.add(subVendor.Recipient__c);
                }
            }
            
            if(accountIdSet.size() > 0){
                listContacts = [SELECT Id, Name FROM Contact WHERE AccountId IN :accountIdSet];
            }
          
            for(Contact c : listContacts){
                if(!conIdSet.contains(c.Id)){
                    conNoSubIdSet.add(c.Id);
                }
            }
            
            if (conNoSubIdSet.size() > 0){
                addressAssignmentNoSubList = [SELECT Id, Case__c, Case__r.Change_of_Address_Type__c, Address__c, Contact__c, Contact__r.Address__c, Effective_Date__c, Subscription__c, 
                        Subscription_Vendor__c, Active__c, Contact__r.AccountId, Contact__r.Recipient_Indicator__c, Contact__r.Billing_Indicator__c, End_Date__c
                        FROM Address_Assignment__c WHERE Effective_Date__c <= :todayDate AND Active__c = true AND Contact__c IN :conNoSubIdSet];
            }
          
            if(subscriptionIdSet.size() > 0){
                addressAssignmentWithSubList = [SELECT Id, Case__c, Case__r.Change_of_Address_Type__c, Address__c, Contact__c, Contact__r.Address__c, Effective_Date__c, Subscription__c, 
                        Subscription_Vendor__c, Active__c, Contact__r.AccountId, Contact__r.Recipient_Indicator__c, Contact__r.Billing_Indicator__c, End_Date__c
                        FROM Address_Assignment__c WHERE Effective_Date__c <= :todayDate AND Active__c = true AND Subscription__c IN :subscriptionIdSet];
            }
            
            if(subscriptionVendorIdSet.size() > 0){
                addressAssignmentWithSubVendorList = [SELECT Id, Case__c, Case__r.Change_of_Address_Type__c, Address__c, Contact__c, Contact__r.Address__c, Effective_Date__c, Subscription__c, 
                        Subscription_Vendor__c, Active__c, Contact__r.AccountId, Contact__r.Recipient_Indicator__c, Contact__r.Billing_Indicator__c, End_Date__c
                        FROM Address_Assignment__c WHERE Effective_Date__c <= :todayDate AND Active__c = true AND Subscription_Vendor__c IN :subscriptionVendorIdSet];
            }
            //END UD-0899 4/16/2015 Added By C. Lin
            
            //Start Code Review 2/19/2015 James
            List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
            List<Subscription_Vendor__c> subscriptionVendorList = new List<Subscription_Vendor__c>();
            //START D-2547 19-Mar-2015 Added by Raviteja  - COA Change preparing deliverysubscriptionList  and publicationSubmap 
            List<Zuora__Subscription__c> deliverysubscriptionList = new List<Zuora__Subscription__c>();
            Map<String,String> publicationSubmap = New Map<String,String>();        
            //End D-2547 19-Mar-2015 Added by Raviteja
            
            //START UD-0883 and UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
            Map<Id, List<Zuora__Subscription__c>> accountIdToSubscriptionListMap = new Map<Id, List<Zuora__Subscription__c>>();
            Map<Id, List<Subscription_Vendor__c>> accountIdToSubscriptionVendorListMap = new Map<Id, List<Subscription_Vendor__c>>();
            //END UD-0883 and UD-0899 5/9/2015 Added By C. Lin

            if (accountIdSet.size() > 0){
                //START D-2367 2/25/2015 Added By C. Lin - Only consider subscriptions which are publication type
                //START D-2547 19-Mar-2015 Added by Raviteja  - COA - Addeed extra fields in the SOQL and written SOQL for deliverysubscriptionList     
                //START UD-0883 AND UD-0899 5/11/2015 Added By C. Lin - Added AND Zuora__SubscriptionEndDate__c >= TODAY
                subscriptionList = [SELECT Id,Zuora__Account__c,Contact__c,Zuora__Zuora_Id__c, Order_Line_Item_Number_1__c, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Zuora__Account__c IN :accountIdSet AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND (Zuora__SubscriptionEndDate__c >= TODAY OR Zuora__TermSettingType__c = 'EVERGREEN')]; //START/END UD-3270 30Nov2015 Added By C. Lin
                //END UD-0883 AND UD-0899 5/11/2015 Added By C. Lin
                //END D-2367 2/25/2015 Added By C. Lin
                //START UD-0883 AND UD-0899 5/11/2015 Added By C. Lin - Added AND Zuora__SubscriptionEndDate__c >= TODAY
                //STAART D-2961 05/19/2015 Added by J. Sarion - Get all Subscription regardless of Billing Type
                deliverysubscriptionList = [SELECT Id, Zuora__Account__c, Recipient_Contact__c, Recipient_Contact__r.Address__c, Zuora__Zuora_Id__c, Delivery_Charge_Type_1__c,
                            Zuora__CustomerAccount__c, Zuora__SubscriptionStartDate__c, Contract_End_Date_1__c,Zuora__SubscriptionEndDate__c, Order_Line_Item_Number_1__c  
                            FROM Zuora__Subscription__c WHERE Zuora__Account__c IN :accountIdSet 
                            AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Delivery' 
                            AND (Zuora__SubscriptionEndDate__c >= TODAY OR Zuora__TermSettingType__c = 'EVERGREEN')];
                //END D-2961 05/19/2015 Added by J. Sarion - Get all Subscription regardless of Billing Type
                //END UD-0883 AND UD-0899 5/11/2015 Added By C. Lin
                //End D-2547 19-Mar-2015 Added by Raviteja
                //START UD-0883 and UD-0899 5/9/2015 Added By C. Lin - Add Account__c
                subscriptionVendorList = [SELECT Id, Account__c, Recipient__c FROM Subscription_Vendor__c WHERE Account__c IN :accountIdSet AND Status__c = 'Active']; //START/END UD-3270 30Nov2015 Added By C. Lin
                //END UD-0883 and UD-0899 5/9/2015 Added By C. Lin
            }
            //End Code Review 2/19/2015 James
            //START UD-0883 and UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
            for(Zuora__Subscription__c zs : subscriptionList){
                if(accountIdToSubscriptionListMap.containsKey(zs.Zuora__Account__c)){
                    accountIdToSubscriptionListMap.get(zs.Zuora__Account__c).add(zs);
                }else{
                    accountIdToSubscriptionListMap.put(zs.Zuora__Account__c, new List<Zuora__Subscription__c> {zs});
                }
                
                //START UD-3270 30Nov2015 Added By C. Lin
                if(recConIdToSubscriptionMap.containsKey(zs.Recipient_Contact__c)){
                    recConIdToSubscriptionMap.get(zs.Recipient_Contact__c).add(zs);
                }else{
                    recConIdToSubscriptionMap.put(zs.Recipient_Contact__c, new Set<Zuora__Subscription__c> {zs});
                }
                //END UD-3270 30Nov2015 Added By C. Lin
            }
          
            for(Subscription_Vendor__c sVen : subscriptionVendorList){
                if(accountIdToSubscriptionVendorListMap.containsKey(sVen.Account__c)){
                    accountIdToSubscriptionVendorListMap.get(sVen.Account__c).add(sVen);
                }else{
                  accountIdToSubscriptionVendorListMap.put(sVen.Account__c, new List<Subscription_Vendor__c> {sVen});
                }
                    
                //START UD-3270 30Nov2015 Added By C. Lin
                if(recConIdToSubscriptionVendorMap.containsKey(sVen.Recipient__c)){
                    recConIdToSubscriptionVendorMap.get(sVen.Recipient__c).add(sVen);
                }else{
                    recConIdToSubscriptionVendorMap.put(sVen.Recipient__c, new Set<Subscription_Vendor__c> {sVen});
                }
                //END UD-3270 30Nov2015 Added By C. Lin
            }
            //END UD-0883 and UD-0899 5/9/2015 Added By C. Lin
            
            //START D-2547 19-Mar-2015 Added by Raviteja  - Preparing Publication Subscription map
            for(Zuora__Subscription__c pubsub : subscriptionList){
                publicationSubmap.put(pubsub.Order_Line_Item_Number_1__c,pubsub.Zuora__Zuora_Id__c);             
            }
            // Preparing Publication Subscription Zuora__Zuora_Id__c with Delivery Subscription Zuora__Zuora_Id__c map
            for(Zuora__Subscription__c deliverysub : deliverysubscriptionList){
                if(publicationSubmap.containsKey(deliverysub.Order_Line_Item_Number_1__c)){
                    deliverySubzouraidmap.put(publicationSubmap.get(deliverysub.Order_Line_Item_Number_1__c),deliverysub.Zuora__Zuora_Id__c);
                    mapDelZuoraIdToOldAddressId.put(deliverysub.Zuora__Zuora_Id__c, deliverysub.Recipient_Contact__r.Address__c);
                }        
            }        
            //End D-2547 19-Mar-2015 Added by Raviteja
            
            //END D-2001 2/5/2015 Added By C. Lin
            
            for (Address_Assignment__c aa :scopeAddressAssignment) { //START END D-4034 Change scope to scopeAddressAssignment
                //START D-2228 2/17/2015 Added By J.Sarion - Added criteria to WHERE clause
                if (aa.Contact__c != null) {
                    contactIdSet.add(aa.Contact__c);
                }
                //END D-2228 2/17/2015 Added By J.Sarion
                
                if (aa.Subscription__c != null) {
                    subIdSet.add(aa.Subscription__c);
                    if (conIdToSubIdSetMap.containsKey(aa.Contact__c)) {
                        conIdToSubIdSetMap.get(aa.Contact__c).add(aa.Subscription__c);
                    }
                    else {
                        conIdToSubIdSetMap.put(aa.Contact__c, new Set<Id> {aa.Subscription__c});
                    }
                    if (conIdAddressIdCaseRecTypeToSubIdSetMap.containsKey(aa.Contact__c)) {
                        if (conIdAddressIdCaseRecTypeToSubIdSetMap.get(aa.Contact__c).containsKey(aa.Address__c)) {
                            if (conIdAddressIdCaseRecTypeToSubIdSetMap.get(aa.Contact__c).get(aa.Address__c).containsKey(aa.Case__r.Change_of_Address_Type__c)) {
                                conIdAddressIdCaseRecTypeToSubIdSetMap.get(aa.Contact__c).get(aa.Address__c).get(aa.Case__r.Change_of_Address_Type__c).add(aa.Subscription__c);
                        
                                aa.Active__c = true;
                                updateAddressAssignmentList.add(aa);
                            }
                            else {
                                conIdAddressIdCaseRecTypeToSubIdSetMap.get(aa.Contact__c).get(aa.Address__c).put(aa.Case__r.Change_of_Address_Type__c, new Set<Id> {aa.Subscription__c});
                        
                                aa.Active__c = true;
                                updateAddressAssignmentList.add(aa);
                            }
                        }
                        else {
                            conIdAddressIdCaseRecTypeToSubIdSetMap.get(aa.Contact__c).put(aa.Address__c, new Map<String, Set<Id>>());
                            conIdAddressIdCaseRecTypeToSubIdSetMap.get(aa.Contact__c).get(aa.Address__c).put(aa.Case__r.Change_of_Address_Type__c, new Set<Id> {aa.Subscription__c});
                      
                            aa.Active__c = true;
                            updateAddressAssignmentList.add(aa);
                        }
                    }
                    else {
                        conIdAddressIdCaseRecTypeToSubIdSetMap.put(aa.Contact__c, new Map<Id, Map<String, Set<Id>>>());
                        conIdAddressIdCaseRecTypeToSubIdSetMap.get(aa.Contact__c).put(aa.Address__c, new Map<String, Set<Id>>());
                        conIdAddressIdCaseRecTypeToSubIdSetMap.get(aa.Contact__c).get(aa.Address__c).put(aa.Case__r.Change_of_Address_Type__c, new Set<Id> {aa.Subscription__c});
                        
                        aa.Active__c = true;
                        updateAddressAssignmentList.add(aa);
                    }
                }
                //START D-2001 2/5/2015 Added By C. Lin - Fixed COA for Vendor Subscriber Accounts. Fixed creation of new contact and updating of contact based on contact to update and subscriptions.
                else if(aa.Subscription_Vendor__c != null){
                    subVendorIdSet.add(aa.Subscription_Vendor__c);
                    if (conIdToSubVendorIdSetMap.containsKey(aa.Contact__c)) {
                        conIdToSubVendorIdSetMap.get(aa.Contact__c).add(aa.Subscription_Vendor__c);
                    }
                    else {
                        conIdToSubVendorIdSetMap.put(aa.Contact__c, new Set<Id> {aa.Subscription_Vendor__c});
                    }
                    
                    if (conIdAddressIdCaseRecTypeToSubVendorIdSetMap.containsKey(aa.Contact__c)) {
                        if (conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(aa.Contact__c).containsKey(aa.Address__c)) {
                            if (conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(aa.Contact__c).get(aa.Address__c).containsKey(aa.Case__r.Change_of_Address_Type__c)) {
                                conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(aa.Contact__c).get(aa.Address__c).get(aa.Case__r.Change_of_Address_Type__c).add(aa.Subscription_Vendor__c);
                            
                                aa.Active__c = true;
                                updateAddressAssignmentList.add(aa);
                            }
                            else {
                                conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(aa.Contact__c).get(aa.Address__c).put(aa.Case__r.Change_of_Address_Type__c, new Set<Id> {aa.Subscription_Vendor__c});
                            
                                aa.Active__c = true;
                                updateAddressAssignmentList.add(aa);
                            }
                        }
                        else {
                            conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(aa.Contact__c).put(aa.Address__c, new Map<String, Set<Id>>());
                            conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(aa.Contact__c).get(aa.Address__c).put(aa.Case__r.Change_of_Address_Type__c, new Set<Id> {aa.Subscription_Vendor__c});
                            
                            aa.Active__c = true;
                            updateAddressAssignmentList.add(aa);
                        }
                    }
                    else {
                        conIdAddressIdCaseRecTypeToSubVendorIdSetMap.put(aa.Contact__c, new Map<Id, Map<String, Set<Id>>>());
                        conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(aa.Contact__c).put(aa.Address__c, new Map<String, Set<Id>>());
                        conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(aa.Contact__c).get(aa.Address__c).put(aa.Case__r.Change_of_Address_Type__c, new Set<Id> {aa.Subscription_Vendor__c});
                        
                        aa.Active__c = true;
                        updateAddressAssignmentList.add(aa);
                    }
                }
                //END D-2001 2/5/2015 Added By C. Lin
                
                //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                if (conIdToAddressAssignIdMap.containsKey(aa.Contact__c)) {
                    if (aa.CreatedDate > conIdToAddressAssignIdMap.get(aa.Contact__c).CreatedDate) {
                        conIdToAddressAssignIdMap.put(aa.Contact__c, aa);
                    }
                }
                else {
                    conIdToAddressAssignIdMap.put(aa.Contact__c, aa);
                }
                //END D-2915 5/14/2015 Added By C. Lin
            }
            
            if (!subIdSet.isEmpty()) {
                //START UD-2162 08/20/2015 Added by J.Sarion - Added Billing Type
                //START UD-3574 1/13/2016 Added by J.Sarion- Add Delivery Charge Type field
                subList = [SELECT Id, Recipient_Contact__c, Billing_Type__c, Zuora__Zuora_Id__c, Zuora__CustomerAccount__r.Zuora__SoldToId__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Delivery_Charge_Type_1__c FROM Zuora__Subscription__c WHERE Id IN :subIdSet];
                //END UD-3574 1/13/2016 Added by J.Sarion- Add Delivery Charge Type field
                //END UD-2162 08/20/2015 Added by J.Sarion - Added Billing Type
            }
            
            for (Zuora__Subscription__c sub :subList) {
                //START UD-2162 08/20/2015 Added by J.Sarion - create map for String to Subscription
                zuoraIdToSubMap.put(sub.Zuora__Zuora_Id__c, sub);
                //END UD-2162 08/20/2015 Added by J.Sarion - create map for String to Subscription
                
                subIdToSubMap.put(sub.Id, sub);
            }
            
            //START D-2001 2/5/2015 Added By C. Lin - Fixed COA for Vendor Subscriber Accounts. Fixed creation of new contact and updating of contact based on contact to update and subscriptions.
            if (!subVendorIdSet.isEmpty()) {
                subVendorList = [SELECT Id, Recipient__c FROM Subscription_Vendor__c WHERE Id IN :subVendorIdSet];
            }
            
            for (Subscription_Vendor__c subV :subVendorList) {
                subIdToSubVendorMap.put(subV.Id, subV);
            }
            //END D-2001 2/5/2015 Added By C. Lin
            
            //START D-2228 2/17/2015 Added By J.Sarion - Added criteria to WHERE clause
            if (!contactIdSet.isEmpty()) {
                //START D-2547 27-Mar-2015 Added by Raviteja  - COA - Added Address__r.Address_Type__c field in the SOQL
                contactList = [SELECT Id, FirstName, LastName, Salutation, NRIC__c, Passport__c, Billing_Account_Name_2__c, Company_Name__c, City_Code__c, Remarks__c, Business_Address_Indicator__c, Billing_Indicator__c, Recipient_Indicator__c, HomePhone__c, Mobile_Number__c, Mobile_Number_2__c, Office_Number__c, Office_Extension__c, Fax__c, Email__c, Email_Secondary__c, Address__c, RecordTypeId, AccountId, Address__r.Postal_Code__r.Building_Name__c, Address__r.Postal_Code__r.House_Block_Number__c, Address__r.Postal_Code__r.Street_Name__c, Address__r.Building_Name__c, Address__r.Street_Name__c, Address__r.Block_House_Number__c, Address__r.City__r.Name, Address__r.Country_Name__c, Address__r.Postal_Code__r.Name,Address__r.Address_Type__c FROM Contact WHERE Id IN :contactIdSet];
                //End D-2547 27-Mar-2015 Added by Raviteja
            }
            //END D-2228 2/17/2015 Added By J.Sarion
            
            for (Contact con :contactList) {
                conIdToConMap.put(con.Id, con);
            }
            
            //START D-2258 3/4/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
            List<Zuora__CustomerAccount__c> billingAccountList = [SELECT Id, Billing_Contact__c, Zuora__BillToId__c, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN :accountIdSet AND Zuora__Status__c = 'Active'];
            
            for(Zuora__CustomerAccount__c billAcc : billingAccountList){
                if (conIdToBillAccSetMap.containsKey(billAcc.Billing_Contact__c)) {
                    conIdToBillAccSetMap.get(billAcc.Billing_Contact__c).add(billAcc);
                }else{
                    conIdToBillAccSetMap.put(billAcc.Billing_Contact__c, new Set<Zuora__CustomerAccount__c> {billAcc});
                }
            }
            //END D-2258 3/4/2015 Added By C. Lin
            
            //START D-2258 3/4/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
            if (!accountIdSet.isEmpty()) {
                //START UD-0883 AND UD-0899 5/11/2015 Added By C. Lin - Added AND Zuora__SubscriptionEndDate__c >= TODAY
                //START UD-2162 08/20/2015 Added by J.Sarion - Added Billing Type
                //START UD-3574 1/13/2016 Added by J.Sarion- Add Delivery Charge Type field
                listSubscription = [SELECT Id, Zuora__Zuora_Id__c, Billing_Type__c, Recipient_Contact__c, Contact__c, Zuora__Account__c, Zuora__CustomerAccount__c, Delivery_Charge_Type_1__c FROM Zuora__Subscription__c WHERE Zuora__Account__c IN :accountIdSet AND Zuora__Status__c = 'Active' AND (Zuora__SubscriptionEndDate__c >= TODAY OR Zuora__TermSettingType__c = 'EVERGREEN')];
                //END UD-3574 1/13/2016 Added by J.Sarion- Add Delivery Charge Type field
                //END UD-2162 08/20/2015 Added by J.Sarion - Added Billing Type
                //END UD-0883 AND UD-0899 5/11/2015 Added By C. Lin
            }
            
            for(Zuora__Subscription__c subs : listSubscription){
                billAccIdSet.add(subs.Zuora__CustomerAccount__c);
            }
            
            List<Zuora__CustomerAccount__c> billAccList = [SELECT Id, Billing_Contact__c, Zuora__BillToId__c, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Id IN :billAccIdSet];
            
            for(Zuora__CustomerAccount__c ba : billAccList){
                billAccIdToBillAccMap.put(ba.Id, ba);
            }
            
            for(Zuora__Subscription__c sub : listSubscription){
                //START UD-2162 08/20/2015 Added by J.Sarion - create map for String to Subscription
                zuoraIdToSubMap.put(sub.Zuora__Zuora_Id__c, sub);
                //END UD-2162 08/20/2015 Added by J.Sarion - create map for String to Subscription
              
                if(accountIdToSubscriptionMap.containsKey(sub.Zuora__Account__c)){
                    accountIdToSubscriptionMap.get(sub.Zuora__Account__c).add(sub);
                }else{
                    accountIdToSubscriptionMap.put(sub.Zuora__Account__c, new Set<Zuora__Subscription__c> {sub});
                }
                
                if(billConIdToSubscriptionMap.containsKey(sub.Contact__c)){
                    billConIdToSubscriptionMap.get(sub.Contact__c).add(sub);
                }else{
                    billConIdToSubscriptionMap.put(sub.Contact__c, new Set<Zuora__Subscription__c> {sub});
                }
                
                if(billAccIdToBillAccMap.containsKey(sub.Zuora__CustomerAccount__c)){
                    Zuora__CustomerAccount__c bAcc = billAccIdToBillAccMap.get(sub.Zuora__CustomerAccount__c);
                    subIdToBillAccMap.put(sub.Id, bAcc);
                }
            }
            //END D-2258 3/4/2015 Added By C. Lin
            
            for (Id conId :conIdToAddressAssignIdMap.keySet()) {
                Address_Assignment__c addressAssign = conIdToAddressAssignIdMap.get(conId);
                Contact con = conIdToConMap.get(conId);
                //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                if(addressAssign.Case__r.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD ||
                    addressAssign.Case__r.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                    //con.Address__c = addressAssign.Address__c; //START/END D-4007 02Dec2015 Added By C. Lin - Comment out
                    addressAssign.Active__c = true;
                    
                    updateAddressAssignmentList.add(addressAssign);
                }
                //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                
                //START D-2258 3/4/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
                if(addressAssign.Case__r.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD){
                    //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
                    if(addressAssignmentNoSubList.size() > 0){
                        listAddressAssignment = updatePreviousAddressAssignment(addressAssignmentNoSubList);
                    }
                    //END UD-0899 4/16/2015 Added By C. Lin
                    //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                    //START UD-3270 30Nov2015 Added By C. Lin
                    if(con.Billing_Indicator__c == true && con.Recipient_Indicator__c == false){
                        //Contact newContact = new Contact();
                    //END UD-2868 10/06/2015 Added By C. Lin
                        con.Address__c = addressAssign.Address__c; //START/END D-4007 02Dec2015 Added By C. Lin - Uncheck the indicator for both checked contact for all publications
                        Contact oldContact = conIdToConMap.get(conId);
                        //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                        //newContact = createContact(oldContact, addressAssign.Address__c, bothBillRec);
                        //END UD-2868 10/06/2015 Added By C. Lin
                        
                        //START UD-0883 and UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
                        //if(accountIdToSubscriptionListMap.containsKey(con.AccountId)){
                        //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                        /*if (accountIdToSubscriptionListMap.get(con.AccountId).size() > 1) {
                            //START UD-0539 4/23/2015 Added By C. Lin - Fix Batch Error for Attempt to dereference null object
                            if(accountIdToSubscriptionMap.containsKey(con.AccountId)){
                                for(Zuora__Subscription__c sub : accountIdToSubscriptionMap.get(con.AccountId)){
                                    if(subIdToBillAccMap.containsKey(sub.Id)){
                                        Zuora__CustomerAccount__c billingAccount = subIdToBillAccMap.get(sub.Id);
                                        updateContactZuora(newContact, billingAccount, addIdToAddressMap);
                                        billAccIdToNewContactMap.put(billingAccount.Id, newContact);
                                    }
                                }
                            }
                            updateContactCallOut(lConList);
                            //END UD-0539 4/23/2015 Added By C. Lin
                            if(accountIdToSubscriptionMap.containsKey(oldContact.AccountId)){
                                for(Zuora__Subscription__c subsc : accountIdToSubscriptionMap.get(oldContact.AccountId)){
                                subIdToNewContactMap.put(subsc.Id, newContact);
                                }
                            }
                            
                            newContactList.add(newContact);*/
                        //}else if(accountIdToSubscriptionListMap.get(con.AccountId).size() == 1){
                        //END UD-2868 10/06/2015 Added By C. Lin
                            /*if(accountIdToSubscriptionMap.containsKey(con.AccountId)){
                                for(Zuora__Subscription__c sub : accountIdToSubscriptionMap.get(con.AccountId)){
                                    if(subIdToBillAccMap.containsKey(sub.Id)){
                                        Zuora__CustomerAccount__c billingAccount = subIdToBillAccMap.get(sub.Id);
                                        updateContactZuora(con, billingAccount, addIdToAddressMap);
                                        billAccIdToNewContactMap.put(billingAccount.Id, con);
                                    }
                                }
                            }*/
                            if(billConIdToSubscriptionMap.containsKey(con.Id)){
                                for(Zuora__Subscription__c sub : billConIdToSubscriptionMap.get(con.Id)){
                                    if(subIdToBillAccMap.containsKey(sub.Id)){
                                        Zuora__CustomerAccount__c billingAccount = subIdToBillAccMap.get(sub.Id);
                                        updateContactZuora(con, billingAccount, addIdToAddressMap);
                                        billAccIdToNewContactMap.put(billingAccount.Id, con);
                                    }
                                }
                            }
                            updateContactCallOut(lConList);
                        
                            /*if(accountIdToSubscriptionMap.containsKey(oldContact.AccountId)){
                                for(Zuora__Subscription__c subsc : accountIdToSubscriptionMap.get(oldContact.AccountId)){
                                    subIdToNewContactMap.put(subsc.Id, con);
                                }
                            }*/
                            if(billConIdToSubscriptionMap.containsKey(oldContact.Id)){
                                for(Zuora__Subscription__c subsc : billConIdToSubscriptionMap.get(oldContact.Id)){
                                    subIdToNewContactMap.put(subsc.Id, con);
                                }
                            }
                            
                            conList.add(con);
                        //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                        //}
                        //END UD-2868 10/06/2015 Added By C. Lin
                    //}
                    //END UD-0883 and UD-0899 5/9/2015 Added By C. Lin
                    //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                    }else if(con.Billing_Indicator__c == true && con.Recipient_Indicator__c == true){
                        Contact newContact = new Contact();
                        Contact oldContact = conIdToConMap.get(conId);
                        oldContact.Recipient_Indicator__c = false;
                        newContact = createContact(oldContact, addressAssign.Address__c, bothBillRec, addressAssign.Case__r.Change_of_Address_Type__c); //START END D-4034 15Dec2015 Added By C. Lin - Add addressAssign.Case__r.Change_of_Address_Type__c
                        billConIdsToUncheck.add(oldContact.Id); //START/END D-4007 02Dec2015 Added By C. Lin - Uncheck the indicator for both checked contact for all publications
                        newContactList.add(newContact);
                        //START UD-0539 4/23/2015 Added By C. Lin - Fix Batch Error for Attempt to dereference null object
                        /*if(accountIdToSubscriptionMap.containsKey(con.AccountId)){
                            for(Zuora__Subscription__c sub : accountIdToSubscriptionMap.get(con.AccountId)){
                                if(subIdToBillAccMap.containsKey(sub.Id)){
                                    Zuora__CustomerAccount__c billingAccount = subIdToBillAccMap.get(sub.Id);
                                    updateContactZuora(newContact, billingAccount, addIdToAddressMap);
                                    billAccIdToNewContactMap.put(billingAccount.Id, newContact);
                                }
                            }
                        }*/
                        if(billConIdToSubscriptionMap.containsKey(con.Id)){
                            for(Zuora__Subscription__c sub : billConIdToSubscriptionMap.get(con.Id)){
                                if(subIdToBillAccMap.containsKey(sub.Id)){
                                    Zuora__CustomerAccount__c billingAccount = subIdToBillAccMap.get(sub.Id);
                                    updateContactZuora(newContact, billingAccount, addIdToAddressMap);
                                    billAccIdToNewContactMap.put(billingAccount.Id, newContact);
                                }
                            }
                        }
                        updateContactCallOut(lConList);
                        //END UD-0539 4/23/2015 Added By C. Lin
                        /*if(accountIdToSubscriptionMap.containsKey(oldContact.AccountId)){
                            for(Zuora__Subscription__c subsc : accountIdToSubscriptionMap.get(oldContact.AccountId)){
                                subIdToNewContactMap.put(subsc.Id, newContact);
                            }
                        }*/
                        if(billConIdToSubscriptionMap.containsKey(oldContact.Id)){
                            for(Zuora__Subscription__c subsc : billConIdToSubscriptionMap.get(oldContact.Id)){
                                subIdToNewContactMap.put(subsc.Id, newContact);
                            }
                        }
                    }
                    //END UD-3270 30Nov2015 Added By C. Lin
                    //END UD-2868 10/06/2015 Added By C. Lin
                }
                else if(addressAssign.Case__r.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                    //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
                    if(addressAssignmentNoSubList.size() > 0){
                        listAddressAssignment = updatePreviousAddressAssignment(addressAssignmentNoSubList);
                    }
                    //END UD-0899 4/16/2015 Added By C. Lin
                    if(con.Billing_Indicator__c == true && con.Recipient_Indicator__c == true){
                        //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                        //Contact newContact = new Contact();
                        //END UD-2868 10/06/2015 Added By C. Lin
                        con.Address__c = addressAssign.Address__c; //START END D-4034 08Dec2015 Added By C. Lin - Update address for BillDeliveryAdd
                        Contact oldContact = conIdToConMap.get(conId);
                        //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                        //bothBillRec = true;
                        //newContact = createContact(oldContact, addressAssign.Address__c, bothBillRec);
                        //END UD-2868 10/06/2015 Added By C. Lin
                        
                        //START UD-3270 30Nov2015 Added By C. Lin
                        //START UD-0883 and UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
                        //if(accountIdToSubscriptionListMap.containsKey(con.AccountId)){
                            //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                            /*if (accountIdToSubscriptionListMap.get(con.AccountId).size() > 1) {
                                //START UD-0539 4/23/2015 Added By C. Lin - Fix Batch Error for Attempt to dereference null object
                                if(accountIdToSubscriptionMap.containsKey(con.AccountId)){
                                    for(Zuora__Subscription__c sub : accountIdToSubscriptionMap.get(con.AccountId)){
                                        if(subIdToBillAccMap.containsKey(sub.Id)){
                                            Zuora__CustomerAccount__c billingAccount = subIdToBillAccMap.get(sub.Id);
                                            updateContactZuora(newContact, billingAccount, addIdToAddressMap);
                                            billAccIdToNewContactMap.put(billingAccount.Id, newContact);
                                        }
                                    }
                                }
                                updateContactCallOut(lConList);
                                //END UD-0539 4/23/2015 Added By C. Lin
                                if(accountIdToSubscriptionMap.containsKey(oldContact.AccountId)){
                                    for(Zuora__Subscription__c subsc : accountIdToSubscriptionMap.get(oldContact.AccountId)){
                                        subIdToNewContactMap.put(subsc.Id, newContact);
                                        subZuoraIdToNewContactMap.put(subsc.Zuora__Zuora_Id__c, newContact);
                                        //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                                        if(addressAssign.Vendor__c != null){
                                            subZuoraIdToNewVendorMap.put(subsc.Zuora__Zuora_Id__c, addressAssign.Vendor__c);
                                        }
                                        //END D-2915 5/14/2015 Added By C. Lin
                                    }
                                }
                                
                                newContactList.add(newContact);
                            }else if(accountIdToSubscriptionListMap.get(con.AccountId).size() == 1){*/
                            //END UD-2868 10/06/2015 Added By C. Lin
                            //START UD-3270 30Nov2015 Added By C. Lin
                            /*if(accountIdToSubscriptionMap.containsKey(con.AccountId)){
                                for(Zuora__Subscription__c sub : accountIdToSubscriptionMap.get(con.AccountId)){
                                    if(subIdToBillAccMap.containsKey(sub.Id)){
                                        Zuora__CustomerAccount__c billingAccount = subIdToBillAccMap.get(sub.Id);
                                        updateContactZuora(con, billingAccount, addIdToAddressMap);
                                        billAccIdToNewContactMap.put(billingAccount.Id, con);
                                    }
                                }
                            }*/
                            if(billConIdToSubscriptionMap.containsKey(con.Id)){
                                for(Zuora__Subscription__c sub : billConIdToSubscriptionMap.get(con.Id)){
                                    if(subIdToBillAccMap.containsKey(sub.Id)){
                                        Zuora__CustomerAccount__c billingAccount = subIdToBillAccMap.get(sub.Id);
                                        updateContactZuora(con, billingAccount, addIdToAddressMap);
                                        billAccIdToNewContactMap.put(billingAccount.Id, con);
                                    }
                                }
                            }
                            updateContactCallOut(lConList);
                            
                            /*if(accountIdToSubscriptionMap.containsKey(oldContact.AccountId)){
                                for(Zuora__Subscription__c subsc : accountIdToSubscriptionMap.get(oldContact.AccountId)){
                                    subIdToNewContactMap.put(subsc.Id, con);
                                    subZuoraIdToNewContactMap.put(subsc.Zuora__Zuora_Id__c, con);
                                    //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                                    if(addressAssign.Vendor__c != null){
                                        subZuoraIdToNewVendorMap.put(subsc.Zuora__Zuora_Id__c, addressAssign.Vendor__c);
                                    }
                                    //END D-2915 5/14/2015 Added By C. Lin
                                }
                            }*/
                            if(billConIdToSubscriptionMap.containsKey(oldContact.Id)){
                                for(Zuora__Subscription__c subsc : billConIdToSubscriptionMap.get(oldContact.Id)){
                                    subIdToNewContactMap.put(subsc.Id, con);
                                    /*subZuoraIdToNewContactMap.put(subsc.Zuora__Zuora_Id__c, con);
                                    //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                                    if(addressAssign.Vendor__c != null){
                                        subZuoraIdToNewVendorMap.put(subsc.Zuora__Zuora_Id__c, addressAssign.Vendor__c);
                                    }
                                    //END D-2915 5/14/2015 Added By C. Lin*/
                                }
                            }
                            if(recConIdToSubscriptionMap.containsKey(oldContact.Id)){
                                for(Zuora__Subscription__c subsc : recConIdToSubscriptionMap.get(oldContact.Id)){
                                    subZuoraIdToNewContactMap.put(subsc.Zuora__Zuora_Id__c, con);
                                    //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                                    if(addressAssign.Vendor__c != null){
                                        subZuoraIdToNewVendorMap.put(subsc.Zuora__Zuora_Id__c, addressAssign.Vendor__c);
                                    }
                                    //END D-2915 5/14/2015 Added By C. Lin
                                }
                            }
                            
                            conList.add(con);
                            //END UD-3270 30Nov2015 Added By C. Lin
                            //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                            //}
                            //END UD-2868 10/06/2015 Added By C. Lin
                        //}
                        //END UD-0883 and UD-0899 5/9/2015 Added By C. Lin
                        //END UD-3270 30Nov2015 Added By C. Lin
                    }
                }
                //END D-2258 3/4/2015 Added By C. Lin
            }
          
            for (Id conId :conIdAddressIdCaseRecTypeToSubIdSetMap.keySet()) {
                for (Id addressId :conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).keySet()) {
                    for (String recType :conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).keySet()) {
                        /*if (recType == GlobalVariableClass.BILLINGADD) {
                            if (conIdToConMap.containsKey(conId)) {
                                Contact con = conIdToConMap.get(conId);
                                con.Address__c = addressId;
                                
                                conList.add(con);
                            }
                        }*/
                        //START: D-1904 2/2/2015 Added By J. Sarion - Added callout to zuora to update recipient contact
                        if (recType == GlobalVariableClass.BILLDELIVERYADD || recType == GlobalVariableClass.DELIVERYADDLOC) {
                            //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
                            if(addressAssignmentWithSubList.size() > 0){
                                listAddressAssignment = updatePreviousAddressAssignment(addressAssignmentWithSubList);
                            }
                            //END UD-0899 4/16/2015 Added By C. Lin
                            
                            if (recType == GlobalVariableClass.BILLDELIVERYADD) {
                                bothBillRec = true;
                            }
                            //START D-2266 3/16/2015 Added By C. Lin - New contact created has recipient indicator checked
                            else if(recType == GlobalVariableClass.DELIVERYADDLOC){
                                bothBillRec = false;
                            }
                            //END D-2266 3/16/2015 Added By C. Lin
                            //START D-2001 2/5/2015 Added By C. Lin - Fixed COA for Vendor Subscriber Accounts. Fixed creation of new contact and updating of contact based on contact to update and subscriptions.
                            //START UD-0883 AND UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
                            //START UD-3270 30Nov2015 Added By C. Lin
                            //if(conIdToAccountIdMap.containsKey(conId)){
                                //Id accId = conIdToAccountIdMap.get(conId);
                            
                            for(Id subId :conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).get(recType)){
                                if(conId != subIdToSubMap.get(subId).Recipient_Contact__c){
                                    conIdSameWithSubRecipient = false;
                                }
                            }
                            
                            if(conIdSameWithSubRecipient == true){
                                //if(accountIdToSubscriptionListMap.containsKey(accId)){
                                if(recConIdToSubscriptionMap.containsKey(conId)){
                                    //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                                    //if (accountIdToSubscriptionListMap.get(accId).size() > 1) {
                                    //START D-4034 15Dec2015 Added By C. Lin - Add && recConIdToSubscriptionMap.get(conId).size() > conIdToSubIdSetMap.get(conId).size()
                                    if(recConIdToSubscriptionMap.get(conId).size() > conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).get(recType).size() && recConIdToSubscriptionMap.get(conId).size() > conIdToSubIdSetMap.get(conId).size()){
                                    //END D-4034 15Dec2015 Added By C. Lin
                                        Contact newContact = new Contact();
                                        Contact oldContact = conIdToConMap.get(conId);
                                        //START D-2266 3/16/2015 Added By C. Lin - New contact created has recipient indicator checked
                                        oldContact.Billing_Indicator__c = false;
                                        //END D-2266 3/16/2015 Added By C. Lin
                                        newContact = createContact(oldContact, addressId, bothBillRec, recType); //START END D-4034 15Dec2015 Added By C. Lin - Add recType
                                        
                                        for (Id subId :conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).get(recType)) {
                                            Zuora__Subscription__c sub = subIdToSubMap.get(subId);
                                            subZuoraIdToNewContactMap.put(sub.Zuora__Zuora_Id__c, newContact);
                                            //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                                            if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                                subZuoraIdToNewVendorMap.put(sub.Zuora__Zuora_Id__c, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                            }
                                            //END D-2915 5/14/2015 Added By C. Lin
                                        }
                                        
                                        newContactList.add(newContact);
                                    //}
                                    //else if (accountIdToSubscriptionListMap.get(accId).size() == 1){
                                    //END UD-2868 10/06/2015 Added By C. Lin
                                    }
                                    //START D-4034 15Dec2015 Added By C. Lin - Add || recConIdToSubscriptionMap.get(conId).size() == conIdToSubIdSetMap.get(conId).size()
                                    else if(recConIdToSubscriptionMap.get(conId).size() == conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).get(recType).size() || recConIdToSubscriptionMap.get(conId).size() == conIdToSubIdSetMap.get(conId).size()){
                                    //END D-4034 15Dec2015 Added By C. Lin
                                        Contact con = conIdToConMap.get(conId);
                                        //con.Address__c = addressId; //START/END D-4007 02Dec2015 Added By C. Lin - Comment Out
                                        
                                        if(con.Billing_Indicator__c == true && con.Recipient_Indicator__c == true){
                                            Contact newContact = new Contact();
                                            Contact oldContact = conIdToConMap.get(conId);
                                            //oldContact.Billing_Indicator__c = false; //START END D-4034 15Dec2015 Added By C. Lin - Comment Out
                                            newContact = createContact(oldContact, addressId, bothBillRec, recType); //START END D-4034 15Dec2015 Added By C. Lin - Add recType
                                            
                                            for (Id subId :conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).get(recType)) {
                                                Zuora__Subscription__c sub = subIdToSubMap.get(subId);
                                                subZuoraIdToNewContactMap.put(sub.Zuora__Zuora_Id__c, newContact);
                                                if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                                    subZuoraIdToNewVendorMap.put(sub.Zuora__Zuora_Id__c, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                                }
                                            }
                                            recConIdsToUncheck.add(oldContact.Id); //START/END D-4007 02Dec2015 Added By C. Lin - Uncheck the indicator for both checked contact for all publications
                                            newContactList.add(newContact);
                                        }else if(con.Billing_Indicator__c == false && con.Recipient_Indicator__c == true){
                                            con.Address__c = addressId; //START/END D-4007 02Dec2015 Added By C. Lin - Uncheck the indicator for both checked contact for all publications
                                            for (Id subId :conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).get(recType)) {
                                                Zuora__Subscription__c sub = subIdToSubMap.get(subId);
                                                subZuoraIdToNewContactMap.put(sub.Zuora__Zuora_Id__c, con);
                                                //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                                                if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                                    subZuoraIdToNewVendorMap.put(sub.Zuora__Zuora_Id__c, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                                }
                                                //END D-2915 5/14/2015 Added By C. Lin
                                            }
                                            
                                            //updateContactList.add(con);
                                            conList.add(con);
                                        }
                                    //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                                    //}
                                    //END UD-2868 10/06/2015 Added By C. Lin
                                    }
                                //}
                                }
                            //}
                            //END UD-0883 AND UD-0899 5/9/2015 Added By C. Lin
                            //END D-2001 2/5/2015 Added By C. Lin
                            }else{
                                Contact con = conIdToConMap.get(conId);
                                
                                if(con.Address__c == addressId){
                                    for (Id subId :conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).get(recType)) {
                                        Zuora__Subscription__c sub = subIdToSubMap.get(subId);
                                        subZuoraIdToNewContactMap.put(sub.Zuora__Zuora_Id__c, con);
                                        if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                            subZuoraIdToNewVendorMap.put(sub.Zuora__Zuora_Id__c, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                        }
                                    }
                                    
                                    //conList.add(con);
                                }else{
                                    Contact newContact = new Contact();
                                    Contact oldContact = conIdToConMap.get(conId);
                                    oldContact.Billing_Indicator__c = false;
                                    newContact = createContact(oldContact, addressId, bothBillRec, recType); //START END D-4034 15Dec2015 Added By C. Lin - Add recType
                        
                                    for (Id subId :conIdAddressIdCaseRecTypeToSubIdSetMap.get(conId).get(addressId).get(recType)) {
                                        Zuora__Subscription__c sub = subIdToSubMap.get(subId);
                                        subZuoraIdToNewContactMap.put(sub.Zuora__Zuora_Id__c, newContact);
                                        if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                            subZuoraIdToNewVendorMap.put(sub.Zuora__Zuora_Id__c, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                        }
                                    }
                                    
                                    newContactList.add(newContact);
                                }
                            }
                            //END UD-3270 30Nov2015 Added By C. Lin
                        }
                        //END: D-1904 2/2/2015 Added By J. Sarion
                    }
                }
            }
            //START D-2001 2/5/2015 Added By C. Lin - Fixed COA for Vendor Subscriber Accounts. Fixed creation of new contact and updating of contact based on contact to update and subscriptions.
            for (Id conId :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.keySet()) {
                for (Id addressId :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).keySet()) {
                    for (String recType :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).keySet()) {
                        
                        if (recType == GlobalVariableClass.BILLDELIVERYADD || recType == GlobalVariableClass.DELIVERYADDLOC) {
                            //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
                            if(addressAssignmentWithSubVendorList.size() > 0){
                                listAddressAssignment = updatePreviousAddressAssignment(addressAssignmentWithSubVendorList);
                            }
                            //END UD-0899 4/16/2015 Added By C. Lin
                            system.debug('>>>>> Change_of_Address_Type__c' + recType);
                            if (recType == GlobalVariableClass.BILLDELIVERYADD) {
                                bothBillRec = true;
                            }
                            //START D-2266 3/16/2015 Added By C. Lin - New contact created has recipient indicator checked
                            else if(recType == GlobalVariableClass.DELIVERYADDLOC){
                                bothBillRec = false;
                            }
                            //END D-2266 3/16/2015 Added By C. Lin
                            //START UD-0883 AND UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
                            //START UD-3270 30Nov2015 Added By C. Lin
                            //if(conIdToAccountIdMap.containsKey(conId)){
                                //Id accId = conIdToAccountIdMap.get(conId);
                            
                            //START D-4014 03Dec2015 Added By C. Lin - Change conIdAddressIdCaseRecTypeToSubIdSetMap to conIdAddressIdCaseRecTypeToSubVendorIdSetMap
                            for(Id subVendorId :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).get(recType)){
                                if(conId != subIdToSubVendorMap.get(subVendorId).Recipient__c){
                                    conIdSameWithSubRecipient = false;
                                }
                            }
                            //END D-4014 03Dec2015 Added By C. Lin
                            if(conIdSameWithSubRecipient == true){
                                //if(accountIdToSubscriptionVendorListMap.containsKey(accId)){
                                if(recConIdToSubscriptionVendorMap.containsKey(conId)){
                                    //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                                    //if (accountIdToSubscriptionVendorListMap.get(accId).size() > 1) {
                                    if(recConIdToSubscriptionVendorMap.get(conId).size() > conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).get(recType).size()){
                                        Contact newContact = new Contact();
                                        Contact oldContact = conIdToConMap.get(conId);
                                        //START D-2266 3/16/2015 Added By C. Lin - New contact created has recipient indicator checked
                                        oldContact.Billing_Indicator__c = false;
                                        //END D-2266 3/16/2015 Added By C. Lin
                                        newContact = createContact(oldContact, addressId, bothBillRec, recType); //START END D-4034 15Dec2015 Added By C. Lin - Add recType
                                        
                                        for (Id subVendorId :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).get(recType)) {
                                            Subscription_Vendor__c subVen = subIdToSubVendorMap.get(subVendorId);
                                            subVendorIdToNewContactMap.put(subVen.Id, newContact);
                                            //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                                            if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                                subVendorIdToNewVendorMap.put(subVen.Id, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                            }
                                            //END D-2915 5/14/2015 Added By C. Lin
                                        }
                                        
                                        newContactList.add(newContact);
                                    //}
                                    }
                                    //else if (accountIdToSubscriptionVendorListMap.get(accId).size() == 1){
                                    //END UD-2868 10/06/2015 Added By C. Lin
                                    else if(recConIdToSubscriptionVendorMap.get(conId).size() == conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).get(recType).size()){
                                        Contact con = conIdToConMap.get(conId);
                                        con.Address__c = addressId;
                                        
                                        if(con.Billing_Indicator__c == true && con.Recipient_Indicator__c == true){
                                            Contact newContact = new Contact();
                                            Contact oldContact = conIdToConMap.get(conId);
                                            //oldContact.Billing_Indicator__c = false; //START END D-4034 15Dec2015 Added By C. Lin - Comment Out
                                            newContact = createContact(oldContact, addressId, bothBillRec, recType); //START END D-4034 15Dec2015 Added By C. Lin - Add recType
                                            
                                            for (Id subVendorId :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).get(recType)) {
                                                Subscription_Vendor__c subVen = subIdToSubVendorMap.get(subVendorId);
                                                subVendorIdToNewContactMap.put(subVen.Id, newContact);
                                                if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                                    subVendorIdToNewVendorMap.put(subVen.Id, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                                }
                                            }
                                            
                                            newContactList.add(newContact);
                                        }else if(con.Billing_Indicator__c == false && con.Recipient_Indicator__c == true){
                                            //START D-4014 03Dec2015 Added By C. Lin - Change subId to subVendorId
                                            for (Id subVendorId :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).get(recType)) {
                                                Subscription_Vendor__c subVen = subIdToSubVendorMap.get(subVendorId);
                                            //END D-4014 03Dec2015 Added By C. Lin
                                                subVendorIdToNewContactMap.put(subVen.Id, con);
                                                //START D-2915 5/14/2015 Added By C. Lin - CCB COA
                                                if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                                    subVendorIdToNewVendorMap.put(subVen.Id, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                                }
                                                //END D-2915 5/14/2015 Added By C. Lin
                                            }
                                
                                            //updateContactList.add(con);
                                            conList.add(con);
                                        }
                                    //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                                    //}
                                    //END UD-2868 10/06/2015 Added By C. Lin
                                    }
                                //}
                                }
                            //}
                            //END UD-0883 AND UD-0899 5/9/2015 Added By C. Lin
                            }else{
                                Contact con = conIdToConMap.get(conId);
                                system.debug('con.Address__c' + con.Address__c);
                                system.debug('addressId' + addressId);
                                if(con.Address__c == addressId){
                                    //START D-4014 03Dec2015 Added By C. Lin - Change subId to subVendorId
                                    for (Id subVendorId :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).get(recType)) {
                                        Subscription_Vendor__c subVen = subIdToSubVendorMap.get(subVendorId);
                                    //END D-4014 03Dec2015 Added By C. Lin
                                        subVendorIdToNewContactMap.put(subVen.Id, con);
                                        if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                            subVendorIdToNewVendorMap.put(subVen.Id, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                        }
                                    }
                                    
                                    //conList.add(con);
                                }else{
                                    Contact newContact = new Contact();
                                    Contact oldContact = conIdToConMap.get(conId);
                                    oldContact.Billing_Indicator__c = false;
                                    newContact = createContact(oldContact, addressId, bothBillRec, recType); //START END D-4034 15Dec2015 Added By C. Lin - Add recType
                        
                                    for (Id subVendorId :conIdAddressIdCaseRecTypeToSubVendorIdSetMap.get(conId).get(addressId).get(recType)) {
                                        Subscription_Vendor__c subVen = subIdToSubVendorMap.get(subVendorId);
                                        subVendorIdToNewContactMap.put(subVen.Id, newContact);
                                        if(conIdToAddressAssignIdMap.get(conId).Vendor__c != null){
                                            subVendorIdToNewVendorMap.put(subVen.Id, conIdToAddressAssignIdMap.get(conId).Vendor__c);
                                        }
                                    }
                                    
                                    newContactList.add(newContact);
                                }
                            }
                            //END UD-3270 30Nov2015 Added By C. Lin
                        }
                    }
                }
            }
            //END D-2001 2/5/2015 Added By C. Lin
            if (!conList.isEmpty()) {
                upsert conList;
                //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
                coaCheckIfArmsContact(conList);
                //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
            }
            if (!updateAddressAssignmentList.isEmpty()) {
                upsert updateAddressAssignmentList;
            }
            if (!newContactList.isEmpty()) {
                //START UD-2868 10/06/2015 Added By C. Lin - Remove Auto Creation of New Contact
                insert newContactList; //START/END UD-3270 30Nov2015 Added By C. Lin
                //END UD-2868 10/06/2015 Added By C. Lin
                
                for (Contact con :newContactList) {
                }
            }
            //START D-2915 5/14/2015 Added By C. Lin - CCB COA
            //START D-2979 5/20/2015 Added By C. Lin - Remove subZuoraIdToNewVendorMap in if condition
            if (!subZuoraIdToNewContactMap.isEmpty()) {
                //START D-4034 08Dec2015 Added By C. Lin - Updating Recipient Contact in Order record
                newOrderListForRecipient = updateOrderRecipientContact(subZuoraIdToNewContactMap);
                if(!newOrderListForRecipient.isEmpty()){
                    upsert newOrderListForRecipient;
                }
                //END D-4034 08Dec2015 Added By C. Lin
                subMapList = updateSub(subZuoraIdToNewContactMap, subZuoraIdToNewVendorMap);
            }
            //END D-2979 5/20/2015 Added By C. Lin
            //END D-2915 5/14/2015 Added By C. Lin
            //START D-2001 2/5/2015 Added By C. Lin - Fixed COA for Vendor Subscriber Accounts. Fixed creation of new contact and updating of contact based on contact to update and subscriptions.
            //START D-2915 5/14/2015 Added By C. Lin - CCB COA
            //START D-2979 5/20/2015 Added By C. Lin - Remove subZuoraIdToNewVendorMap in if condition
            if (!subVendorIdToNewContactMap.isEmpty()) {
                newSubVendorList = updateSubVendor(subVendorIdToNewContactMap, subVendorIdToNewVendorMap);
                if(!newSubVendorList.isEmpty()){
                    upsert newSubVendorList;
                }
            }
            //END D-2979 5/20/2015 Added By C. Lin
            //END D-2915 5/14/2015 Added By C. Lin
            //END D-2001 2/5/2015 Added By C. Lin
            
            //START D-2258 3/5/2015 Added  By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
            if(!subIdToNewContactMap.isEmpty()){
                newOrderList = updateOrderBillingContact(subIdToNewContactMap);
                newBillAccList = updateBillAccBillingContact(conIdToAddressAssignIdMap, conIdToConMap, subIdToBillAccMap, billAccIdToNewContactMap, accountIdToSubscriptionMap);
                if(!newOrderList.isEmpty()){
                    upsert newOrderList;
                    
                    billSubMapList = updateSubBillingContact(newOrderList, subIdToNewContactMap);
                }
                if(!newBillAccList.isEmpty()){
                    //START UD-2509 8/28/2015 Added By C. Lin - update ARMS Customer address
                    ARMS_TriggerHandler.isSkipUpdate = true;
                    zuoraCustomerIds = updateCustomer(newBillAccList);
                    //END UD-2509 8/28/2015 Added By C. Lin
                    upsert newBillAccList;
                }
            }
            //END D-2258 3/5/2015 Added  By C. Lin
            
            //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
            if(!listAddressAssignment.isEmpty()){
                update listAddressAssignment;
            }
            //END UD-0899 4/16/2015 Added By C. Lin
            //logger.save(); //START END D-1011 MD-28 Dags 18/06/15 
        }catch(Exception e){
            logger.logBatchFailure(e, scope);
            
            isApexJobSuccessful = false;
        }finally{
            logger.save();
        }
        //END D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
    }
    
    public Contact createContact(Contact con, Id addressId, Boolean bothBillRec, String coaType) { //START END D-4034 15Dec2015 Added By C. Lin - Add coaType
        Contact newContact = new Contact();
        newContact.AccountId = con.AccountId;
        newContact.FirstName = con.FirstName;
        newContact.LastName = con.LastName;
        newContact.Salutation = (con.Salutation != null ? con.Salutation : null);
        newContact.NRIC__c = (con.NRIC__c != null ? con.NRIC__c : null);
        newContact.Passport__c = (con.Passport__c != null ? con.Passport__c : null);
        newContact.Billing_Account_Name_2__c = (con.Billing_Account_Name_2__c != null ? con.Billing_Account_Name_2__c : null);
        newContact.Company_Name__c = (con.Company_Name__c != null ? con.Company_Name__c : null);
        newContact.City_Code__c = (con.City_Code__c != null ? con.City_Code__c : null);
        newContact.Remarks__c = (con.Remarks__c != null ? con.Remarks__c : null);
        newContact.Business_Address_Indicator__c = con.Business_Address_Indicator__c;
        //START D-4034 15Dec2015 Added By C. Lin - Add coaType
        //newContact.Billing_Indicator__c = (bothBillRec == true ? true :con.Billing_Indicator__c);
        //newContact.Recipient_Indicator__c = con.Recipient_Indicator__c;
        if(coaType == GlobalVariableClass.DELIVERYADDLOC){
            newContact.Billing_Indicator__c = false;
            newContact.Recipient_Indicator__c = true;
        }else if(coaType == GlobalVariableClass.BILLINGADD){
            newContact.Billing_Indicator__c = true;
            newContact.Recipient_Indicator__c = false; //START-END UD-3590 07Jan2016 Added by J.Sarion/C. Lin - Change field from Billing Indicator to Recipient Indicator
        }else if(coaType == GlobalVariableClass.BILLDELIVERYADD){
            newContact.Billing_Indicator__c = true;
            newContact.Recipient_Indicator__c = true; //START-END UD-3590 07Jan2016 Added by J.Sarion/C. Lin - Change field from Billing Indicator to Recipient Indicator
        }
        //END D-4034 15Dec2015 Added By C. Lin
        newContact.HomePhone__c = (con.HomePhone__c != null ? con.HomePhone__c : null);
        newContact.Mobile_Number__c = (con.Mobile_Number__c != null ? con.Mobile_Number__c : null);
        newContact.Mobile_Number_2__c = (con.Mobile_Number_2__c != null ? con.Mobile_Number_2__c : null);
        newContact.Office_Number__c = (con.Office_Number__c != null ? con.Office_Number__c : null);
        newContact.Office_Extension__c = (con.Office_Extension__c != null ? con.Office_Extension__c : null);
        newContact.Fax__c = (con.Fax__c != null ? con.Fax__c : null);
        newContact.Email__c = (con.Email__c != null ? con.Email__c : null);
        newContact.Email_Secondary__c = (con.Email_Secondary__c != null ? con.Email_Secondary__c : null);
        newContact.Address__c = (addressId != null ? addressId : null);
        newContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        
        return newContact;
    }
    
    global void finish(database.batchableContext BC){
        //START UD-3204 Nov-6-2015 Added By C. Lin - New Logger for finish. Add try catch.
        Logger logger = new Logger(BatchAddressAssignmentEffectiveDate.class.getName(), 'SP050', BC.getJobID());
        Id jobID;
        
        try{
            //START D-3243 07/16/2015 Added by J.Sarion - Get Job ID
            jobID = BC.getJobId();
            //END D-3243 07/16/2015 Added by J.Sarion - Get Job ID
        }catch(Exception e){
            logger.log(false, string.valueOf(e));
        }
        //END UD-3204 Nov-6-2015 Added By C. Lin
        
        //START UD-2776 09/18/2015 Added by J.Sarion - added try catch and exception logger
        //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
        try{
            if(zuoraCustomerIds.size()>0){
                updateCustomerWebserviceNonFuture(zuoraCustomerIds);
            }
        }
        catch(Exception e){
            logger.log(false, string.valueOf(e));
            //logger.save(); //START END UD-3204 Nov-6-2015 Added By C. Lin - Comment Out
        }
        //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
        //END UD-2776 09/18/2015 Added by J.Sarion - added try catch and exception logger
        
        //START D-3243 07/16/2015 Added by J.Sarion - Consolidate list for update
        SP_AddressAssignmentCallOut addressAssignCallOut;
        
        if(!subMapList.isEmpty())
            consolidatedSubMapList.addAll(subMapList);
            
        if(!billSubMapList.isEmpty())
            consolidatedSubMapList.addAll(billSubMapList);
            
        if(!deliverysubMapList.isEmpty())
            consolidatedSubMapList.addAll(deliverysubMapList);
            
        if(!consolidatedSubMapList.isEmpty()){
            addressAssignCallOut = new SP_AddressAssignmentCallOut(consolidatedSubMapList, mapNewContactToSub, mapDelZuoraIdToOldAddressId, jobID);
            //START D-4687 18April2016 Added By C. Lin - Limit Callout to 10 records per batch
            Database.executeBatch(addressAssignCallOut, 10);
            //END D-4687 18April2016 Added By C. Lin
        }
        else if(!mapNewContactToSub.isEmpty()){
            BatchCOADeliveryCharge delChargeBatch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId, jobID);
            Database.executeBatch(delChargeBatch, 10);
        }
        else{
            //START UD-3204 Nov-6-2015 Added By C. Lin - Add try catch
            try{
                //START D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
                if(!isApexJobSuccessful){
                    BatchJobHelper.updateJobStatus(BC.getJobId(), false); //START-END KRITHIKA DHARMARAJAN 4/17/2015 D-2770
                }else{
                    BatchJobHelper.updateJobStatus(BC.getJobId(), true);
                }
                //END D-3752 15-Oct-2015 LISEN - Added logic for logging and recovery
            }catch(Exception e){
                logger.log(false, string.valueOf(e));
            }
            //END UD-3204 Nov-6-2015 Added By C. Lin
        }
        
        //START D-4007 02Dec2015 Added By C. Lin - Uncheck the indicator for both checked contact for all publications
        try{
            for(Id billId : billConIdsToUncheck){
                Contact c = conIdToConMap.get(billId);
                c.Billing_Indicator__c = false;
                c.Recipient_Indicator__c = true;
                contactsToUncheckList.add(c);
            }
            
            for(Id recId : recConIdsToUncheck){
                Contact c = conIdToConMap.get(recId);
                c.Billing_Indicator__c = true;
                c.Recipient_Indicator__c = false;
                contactsToUncheckList.add(c);
            }
            
            if(!contactsToUncheckList.isEmpty()){
                update contactsToUncheckList;
            }
        }
        catch(Exception e){
            logger.log(false, string.valueOf(e));
        }
        //END D-4007 02Dec2015 Added By C. Lin
        
        logger.save(); //START END UD-3204 Nov-6-2015 Added By C. Lin - Add Save at the end of method
        
        /*
        //START D-2258 3/5/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
        if(!subMapList.isEmpty()){
            SP_AddressAssignmentCallOut addressAssignCallOut = new SP_AddressAssignmentCallOut(subMapList);
            Database.executeBatch(addressAssignCallOut);
        }
        
        if(!billSubMapList.isEmpty()){
            SP_AddressAssignmentCallOut billAddressAssignCallOut = new SP_AddressAssignmentCallOut(billSubMapList);
            Database.executeBatch(billAddressAssignCallOut);
        }
        //END D-2258 3/5/2015 Added By C. Lin  
        //START D-2547 19-Mar-2015 Added by Raviteja  - COA Change preparing deliverysubMapList to update the recipient contact in Delivery Subscription as well
        System.debug('deliverysubMapList : '+deliverysubMapList);
        if(!deliverysubMapList.isEmpty()){
            SP_AddressAssignmentCallOut addressAssignCallOut = new SP_AddressAssignmentCallOut(deliverysubMapList);
            Database.executeBatch(addressAssignCallOut);
        }
        
        if(!mapNewContactToSub.isEmpty())
        {
            BatchCOADeliveryCharge delChargeBatch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId);
            Database.executeBatch(delChargeBatch, 10);
        }
        //End D-2547 19-Mar-2015 Added by Raviteja
        //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
        
       // String shortID = String.valueOf(BC.getJobId()).subString(0,15);
        //Start Code Review 2/19/2015 James
       // List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>();
       // if (BC.getJobId() <> null){ 
       // batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];
       // }
        //End Code Review 2/19/2015 James
       // if(batchJobSchedulerList.size() > 0)
       // {
       //     BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
       //     batchJobScheduler.Status__c = 'SUCCESS';
       //     batchJobScheduler.End_Time__c = DateTime.now();
       //     update batchJobScheduler;           
            
       //     BatchServiceFacade a1F = new BatchServiceFacade();
       //     BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
       //     serviceRequestVO.setJobStatus(0);
       //     serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
       //     serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
       //     a1F.delegateBatchCall(serviceRequestVO);
       // }
       BatchJobHelper.updateJobStatus(BC.getJobId()); //START-END KRITHIKA DHARMARAJAN HOTFIX
        //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
        */
        //END D-3243 07/16/2015 Added by J.Sarion - Consolidate list for update
    }
    //START D-2258 3/4/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
        
        
    
    public void updateContactZuora(Contact updateContact, Zuora__CustomerAccount__c billingAccount, Map<Id, Address__c> addIdToAddressMap) {
        Map<String, Object> conMap = new Map<String, Object>();
        
        String address = (addIdToAddressMap.get(updateContact.Address__c).Street_Name__c != null ? addIdToAddressMap.get(updateContact.Address__c).Street_Name__c : '') + ' ' + (addIdToAddressMap.get(updateContact.Address__c).Block_House_Number__c != null ? addIdToAddressMap.get(updateContact.Address__c).Block_House_Number__c : '') + ' ' + (addIdToAddressMap.get(updateContact.Address__c).Building_Name__c != null ? addIdToAddressMap.get(updateContact.Address__c).Building_Name__c : '');
        
        conMap.put('Id', billingAccount.Zuora__BillToId__c);
        conMap.put('FirstName', updateContact.FirstName);
        conMap.put('LastName', updateContact.LastName);
        conMap.put('Address1', address);
        conMap.put('City', (addIdToAddressMap.get(updateContact.Address__c).City__r.City_Name__c != null ? addIdToAddressMap.get(updateContact.Address__c).City__r.City_Name__c : null));
        conMap.put('Country', (addIdToAddressMap.get(updateContact.Address__c).Country_Name__c != null ? addIdToAddressMap.get(updateContact.Address__c).Country_Name__c : null));
        conMap.put('PostalCode', (addIdToAddressMap.get(updateContact.Address__c).Postal_Code__r.Name != null ? addIdToAddressMap.get(updateContact.Address__c).Postal_Code__r.Name : null));
        conMap.put('AccountId', billingAccount.Zuora__Zuora_Id__c);
        lConList.add(conMap);
    }
    
    //START UD-0539 4/23/2015 Added By C. Lin - Remove static
    public void updateContactCallOut(List<Map<String, Object>> lConList) {
    //END UD-0539 4/23/2015 Added By C. Lin
        ZuoraCallOut contactCallOut = new ZuoraCallOut();
        List<Map<String,String>> returnVarContact = contactCallOut.updateZObjects(lConList, 'Contact');
        String contactId;
        for(Map<String,String> resultMapContact :returnVarContact){
            if (resultMapContact.get('Status') == 'Success') {
                //TBD
                contactId = resultMapContact.get('Id');
            }
            else {
                //TBD
        //START D-1011 MD-28 Dags 18/06/15 - Using Logger
                system.debug('Message : ' + resultMapContact.get('Message')); 
                logger.log(false,resultMapContact.get('Message'));
                //END D-1011 MD-28 Dags 18/06/15
            }
        }
    }
    //END D-2258 3/4/2015 Added By C. Lin
    //START D-2915 5/14/2015 Added By C. Lin - CCB COA
    public List<Map<String, Object>> updateSub(Map<String, Contact> subZuoraIdToNewContactMap, Map<String, Id> subZuoraIdToNewVendorMap) {
    //END D-2915 5/14/2015 Added By C. Lin
        //START D-2228 2/17/2015 Added By J.Sarion - Added criteria to WHERE clause
        Map<String, Object> subMap;
        Map<String, Object> deliverysubMap;
        List<Map<String, Object>> subMapList = new List<Map<String, Object>>();
        List<Vendor_Allocation__c> vendorAllocList = new List<Vendor_Allocation__c>();
        List<Address__c> addressList = new List<Address__c>();
        
        //START D-2915 5/14/2015 Added By C. Lin - CCB COA - Remove
        /*Map<Id, Set<Id>> postalToVendorAllocMap = new Map<Id, Set<Id>>();
        if (!postalCodeIdSet.isEmpty()) {
            vendorAllocList = [SELECT SingPost_Address__c, Vendor_Account__c FROM Vendor_Allocation__c WHERE Status__c = 'Active' AND SingPost_Address__c IN :postalCodeIdSet];
        }
        
        for(Vendor_Allocation__c va : vendorAllocList){
            if(postalToVendorAllocMap.containsKey(va.SingPost_Address__c)){
                postalToVendorAllocMap.get(va.SingPost_Address__c).add(va.Vendor_Account__c);
            }else{
                postalToVendorAllocMap.put(va.SingPost_Address__c, new Set<Id> {va.Vendor_Account__c});
            }
        }*/
        //END D-2915 5/14/2015 Added By C. Lin
        Map<Id, Address__c> addIdToAddressMap = new Map<Id, Address__c>();
        
        //START D-2979 5/20/2015 Added By C. Lin - get magazine subscriptions
        Set<String> magazineSubSet = new Set<String>();
        List<Zuora__Subscription__c> subscripList = new List<Zuora__Subscription__c>();
        Set<Id> setPackId = new Set<Id>();
        List<Package_Item__c> packItemList = new List<Package_Item__c>();
        Set<Id> setPackageId = new Set<Id>();
        
        subscripList = [SELECT Id, Name, Zuora__Zuora_Id__c, Main_Package_1__c FROM Zuora__Subscription__c WHERE Zuora__Account__c IN :accountIdSet AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND ((Zuora__SubscriptionEndDate__c > TODAY AND Zuora__TermSettingType__c = 'TERMED') OR (Zuora__SubscriptionEndDate__c = NULL AND Zuora__TermSettingType__c = 'EVERGREEN'))];
        
        for(Zuora__Subscription__c sub : subscripList){
            if(sub.Main_Package_1__c != null){
                setPackId.add(sub.Main_Package_1__c);
            }
        }
        
        packItemList = [SELECT Id, Name, Package__c FROM Package_Item__c WHERE Package__c IN : setPackId AND Is_Magazine__c = true];
        
        for(Package_Item__c packItem : packItemList){
            if(packItem.Package__c != null){
                setPackageId.add(packItem.Package__c);
            }
        }
        
        for(Zuora__Subscription__c s : subscripList){
            if(setPackageId.contains(s.Main_Package_1__c)){
                magazineSubSet.add(s.Zuora__Zuora_Id__c);
            }
        }
        //END D-2979 5/20/2015 Added By C. Lin
        
        if (!postalCodeIdSet.isEmpty()) {
            //START D-2547 27-Mar-2015 Added by Raviteja  - COA - Added Address_Type__c field in SOQL
            addressList = [SELECT Postal_Code__c,Address_Type__c FROM Address__c WHERE Postal_Code__c IN :postalCodeIdSet];
            //End D-2547 27-Mar-2015 Added by Raviteja
        }
        
        for(Address__c address : addressList){
            addIdToAddressMap.put(address.Id, address);
        }
        //END D-2152 2/9/2015 Added By C. Lin
        //END D-2228 2/17/2015 Added By J.Sarion
        
        for (String subZuoraId :subZuoraIdToNewContactMap.keySet()) {
            //START UD-2162 08/20/2015 Added by J.Sarion - Get Subscription
            Zuora__Subscription__c sub1 = new Zuora__Subscription__c();
            if(zuoraIdToSubMap.containsKey(subZuoraId)){
                sub1 = zuoraIdToSubMap.get(subZuoraId);
            }
            //END UD-2162 08/20/2015 Added by J.Sarion - Get Subscription
            
            //START D-2979 5/20/2015 Added By C. Lin - Prevent error fix
            Contact con = new Contact();
            if(subZuoraIdToNewContactMap.containsKey(subZuoraId)){
                con = subZuoraIdToNewContactMap.get(subZuoraId);
            }
            //END D-2979 5/20/2015 Added By C. Lin
            
            //START D-2152 2/9/2015 Added By C. Lin - fix for appropriate vendor reflecting on the Subscription for Direct
            
            //END D-2228 2/17/2015 Added By J.Sarion
            //END D-2915 5/14/2015 Added By C. Lin
            
            //START D-2915 5/14/2015 Added By C. Lin - CCB COA
            //START D-2979 5/20/2015 Added By C. Lin - Prevent error fix and exclude magazine
            Id vendor;
            if(subZuoraIdToNewVendorMap.containsKey(subZuoraId)){
                if(!magazineSubSet.contains(subZuoraId)){
                    vendor = subZuoraIdToNewVendorMap.get(subZuoraId);
                }
            }
            //END D-2979 5/20/2015 Added By C. Lin
            //END D-2915 5/14/2015 Added By C. Lin
            
            //START D-2547 19-Mar-2015 Raviteja - Contact Address Type
            String newDeliveryType = null;
            Decimal vendorCreditAmt = null;
            if(con.Address__c != null && addIdToAddressMap.get(con.Address__c).Address_Type__c != null)
            {
                newDeliveryType = ConstantsSLB.getDefaultDeliveryChargeType(addIdToAddressMap.get(con.Address__c).Address_Type__c);
                //START UD-2162 08/19/2015 Added by J.Sarion - get Vendor Credit from SPC
                /*
                String recipientAddressType = addIdToAddressMap.get(con.Address__c).Address_Type__c;
                if(newDeliveryType != null)
                {
                    String addressTypeDeliveryChargeType =  recipientAddressType + newDeliveryType;
                    vendorCreditAmt = ConstantsSLB.getVendorCredit(addressTypeDeliveryChargeType);
                }
                */
                if(delChargeTypeToPriceMap.containsKey(newDeliveryType)){
                    vendorCreditAmt = delChargeTypeToPriceMap.get(newDeliveryType);
                }
                //END UD-2162 08/19/2015 Added by J.Sarion - get Vendor Credit from SPC
            }
            //END D-2547 19-Mar-2015 Added by Raviteja  
            //END D-2152 2/9/2015 Added By C. Lin
            
            subMap = new Map<String, Object>();
            subMap.put('Id', subZuoraId);
            subMap.put('Recipient_Contact__c', con.Id);
            //START: D-1904 2/2/2015 Added By J. Sarion - Added callout to zuora to update recipient contact
            subMap.put('Recipient_Contact_1__c', con.Id);
            //END: D-1904 2/2/2015 Added By J. Sarion
            //START D-2152 2/9/2015 Added By C. Lin - fix for appropriate vendor reflecting on the Subscription for Direct
            subMap.put('Vendor__c', vendor);
            //END D-2152 2/9/2015 Added By C. Lin
            //START UD-3007 12/7/2015 Added by J.Sarion - Update Delivery Charge Type and Vendor Credit also for Full Prepaid
            //START D-2547 19-Mar-2015 Raviteja - update Delivery Charge Type & Vendor Credit
            //START UD-2162 08/20/2015 - Update Delivery Charge Type and Vendor Credit for Recurring Subscriptions
            if(sub1.Billing_Type__c != null){
                //START UD-3574 1/13/2016 Added by J.Sarion - Set Delivery Charge Type and Vendor Credit for Recurring and Full Prepaid if Delivery Charge is H/C/L 
                if(sub1.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE || sub1.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_POST || (sub1.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE && (sub1.Delivery_Charge_Type_1__c == 'H' || sub1.Delivery_Charge_Type_1__c == 'C' || sub1.Delivery_Charge_Type_1__c == 'L'))){
                    if(newDeliveryType != null)
                        subMap.put('Delivery_Charge_Type__c', newDeliveryType);
                    if(vendorCreditAmt != null)
                        subMap.put('Vendor_Credit__c', vendorCreditAmt);
                }
                //END UD-3574 1/13/2016 Added by J.Sarion - Set Delivery Charge Type and Vendor Credit for Recurring and Full Prepaid if Delivery Charge is H/C/L 
            }
            //END UD-2162 08/20/2015 - Update Delivery Charge Type and Vendor Credit for Recurring Subscriptions
            //END D-2547 19-Mar-2015 Added by Raviteja
            //END UD-3007 12/7/2015 Added by J.Sarion - Update Delivery Charge Type and Vendor Credit also for Full Prepaid
            
            subMapList.add(subMap);
            //START D-2547 19-Mar-2015 Added by Raviteja - COA Change preparing deliverysubMap
            deliverysubMap = new Map<String, Object>();
            if(deliverySubzouraidmap.get(subZuoraId) != Null && con.Id != Null){
                deliverysubMap.put('Id', deliverySubzouraidmap.get(subZuoraId));
                deliverysubMap.put('Recipient_Contact__c', con.Id);   
                deliverysubMap.put('Recipient_Contact_1__c', con.Id); 
                if(vendor != null)
                    deliverysubMap.put('Vendor__c', vendor);
                //START UD-3007 12/7/2015 Added by J.Sarion - Update Delivery Charge Type and Vendor Credit also for Full Prepaid
                //START UD-2162 08/20/2015 - Update Delivery Charge Type and Vendor Credit for Recurring Subscriptions
                if(sub1.Billing_Type__c != null){
                    //START UD-3574 1/13/2016 Added by J.Sarion - Set Delivery Charge Type and Vendor Credit for Recurring and Full Prepaid if Delivery Charge is H/C/L 
                    if(sub1.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE || sub1.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_POST || (sub1.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE && (sub1.Delivery_Charge_Type_1__c == 'H' || sub1.Delivery_Charge_Type_1__c == 'C' || sub1.Delivery_Charge_Type_1__c == 'L'))){
                        if(newDeliveryType != null)
                            deliverysubMap.put('Delivery_Charge_Type__c', newDeliveryType);
                        if(vendorCreditAmt != null)
                            deliverysubMap.put('Vendor_Credit__c', vendorCreditAmt);
                    }
                    //END UD-3574 1/13/2016 Added by J.Sarion - Set Delivery Charge Type and Vendor Credit for Recurring and Full Prepaid if Delivery Charge is H/C/L 
                }
                //END UD-2162 08/20/2015 - Update Delivery Charge Type and Vendor Credit for Recurring Subscriptions
                //END UD-3007 12/7/2015 Added by J.Sarion - Update Delivery Charge Type and Vendor Credit also for Full Prepaid
                deliverysubMapList.add(deliverysubMap);
                //START UD-2162 08/17/2015 Added by J.Sarion - Add Zuora Id per Contact Id
                if(mapNewContactToSub.containsKey(con.Id)) {
                    mapNewContactToSub.get(con.Id).add(deliverySubzouraidmap.get(subZuoraId));
                }
                else {
                    mapNewContactToSub.put(con.Id, new Set<String> {deliverySubzouraidmap.get(subZuoraId)});
                }
                //END UD-2162 08/17/2015 Added by J.Sarion - Add Zuora Id per Contact Id
            }
            //End D-2547 19-Mar-2015 Added by Raviteja
        }
        return subMapList;
    }
    //END: D-0974 1/14/2015 Added By J. Sarion
    
    //START D-2001 2/5/2015 Added By C. Lin - Fixed COA for Vendor Subscriber Accounts. Fixed creation of new contact and updating of contact based on contact to update and subscriptions.
    //START D-2915 5/14/2015 Added By C. Lin - CCB COA
    public List<Subscription_Vendor__c> updateSubVendor(Map<Id, Contact> subVendorIdToNewContactMap, Map<Id, Id> subVendorIdToNewVendorMap) {
    //END D-2915 5/14/2015 Added By C. Lin
        //Map<String, Object> subMap;
        //START D-2228 2/17/2015 Added By J.Sarion - Added criteria to WHERE clause
        List<Subscription_Vendor__c> newSubVendorList = new List<Subscription_Vendor__c>();
        List<Vendor_Allocation__c> vendorAllocList = new List<Vendor_Allocation__c>();
        List<Address__c> addressList = new List<Address__c>();
        Set<Id> SVId = new Set<Id>();
        //END D-2228 2/17/2015 Added By J.Sarion
        
        //START D-2979 5/20/2015 Added By C. Lin - get magazine subscriptions
        Set<Id> magazineSubVendorSet = new Set<Id>();
        List<Subscription_Vendor__c> subscripVenList = new List<Subscription_Vendor__c>();
        Set<Id> subscripVenIdSet = new Set<Id>();
        List<Subscription_Vendor_Publication__c> subVenPubList = new List<Subscription_Vendor_Publication__c>();
        
        subscripVenList = [SELECT ID, Name FROM Subscription_Vendor__c WHERE Account__c IN :accountIdSet AND Status__c = 'Active'];
        
        for(Subscription_Vendor__c subVen : subscripVenList){
            subscripVenIdSet.add(subVen.Id);
        }
        
        subVenPubList = [SELECT Id, Name, Subscription_Vendor__c, Publication__c, Publication__r.Product_Category__c FROM Subscription_Vendor_Publication__c WHERE Subscription_Vendor__c IN :subscripVenIdSet];
        
        for(Subscription_Vendor_Publication__c svp : subVenPubList){
            if(svp.Publication__r.Product_Category__c == 'Magazine'){
                magazineSubVendorSet.add(svp.Subscription_Vendor__c);
            }
        }
        //END D-2979 5/20/2015 Added By C. Lin
        
        for (String subVendorId :subVendorIdToNewContactMap.keySet()) {
            SVId.add(subVendorId);
        }
        //START D-2152 2/9/2015 Added By C. Lin - fix for appropriate vendor reflecting on the Subscription for Vendor Subscriber
        //Start Code Review 2/19/2015 James
        List<Subscription_Vendor__c> SVList = new List<Subscription_Vendor__c>();
        if (SVId.size() > 0){
        SVList = [SELECT Id, Recipient__c, Vendor__c FROM Subscription_Vendor__c WHERE Id IN :SVId];
        }
        //End Code Review 2/19/2015 James
        //END D-2152 2/9/2015 Added By C. Lin
        
        for (Subscription_Vendor__c SV :SVList) {
            Contact con = subVendorIdToNewContactMap.get(SV.Id);
            
            //END D-2228 2/17/2015 Added By J.Sarion
            
            //START D-2915 5/14/2015 Added By C. Lin - CCB COA
            //START D-2979 5/20/2015 Added By C. Lin - Prevent error fix and exclude magazine
            Id vendor;
            if(subVendorIdToNewVendorMap.containsKey(SV.Id)){
                if(!magazineSubVendorSet.contains(SV.Id)){
                    vendor = subVendorIdToNewVendorMap.get(SV.Id);
                }
            }
            //END D-2979 5/20/2015 Added By C. Lin
            //END D-2915 5/14/2015 Added By C. Lin
            
            SV.Recipient__c = con.Id;
            //START D-2152 2/9/2015 Added By C. Lin - fix for appropriate vendor reflecting on the Subscription for Vendor Subscriber
            SV.Vendor__c = vendor;
            //END D-2152 2/9/2015 Added By C. Lin
            newSubVendorList.add(SV);
        }
        return newSubVendorList;
    }
    //END D-2001 2/5/2015 Added By C. Lin
    
    //START D-2258 3/5/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
    public List<Order__c> updateOrderBillingContact(Map<Id, Contact> subIdToNewContactMap) {
        List<Order__c> newOrderList = new List<Order__c>();
        Set<Id> SId = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c>();
        //START D-4034 14Dec2015 Added By C. Lin - Change to Id
        //Set<Order__c> orderSet = new Set<Order__c>();
        Set<Id> orderSet = new Set<Id>();
        //END D-4034 14Dec2015 Added By C. Lin
        for (String subId :subIdToNewContactMap.keySet()) {
            SId.add(subId);
        }
        //START UD-0883 AND UD-0899 5/11/2015 Added By C. Lin - Added AND Zuora__SubscriptionEndDate__c >= TODAY
        List<Zuora__Subscription__c> SList = [SELECT Id, Contact__c, Order_Number_1__c FROM Zuora__Subscription__c WHERE Id IN :SId AND (Zuora__SubscriptionEndDate__c >= TODAY OR Zuora__TermSettingType__c = 'EVERGREEN') Order By Name DESC]; //START END D-4034 14Dec2015 Added By C. Lin - Add Order By Name DESC
        //END UD-0883 AND UD-0899 5/11/2015 Added By C. Lin
        for(Zuora__Subscription__c subs : SList){
            orderIdSet.add(subs.Order_Number_1__c);
        }
        
        List<Order__c> orderList = [SELECT Id, Billing_Contact__c FROM Order__c WHERE Id IN :orderIdSet];
        
        for(Order__c order : orderList){
            orderIdToOrderMap.put(order.Id, order);
        }
        
        for(Zuora__Subscription__c subscription : SList){
            Order__c ord = orderIdToOrderMap.get(subscription.Order_Number_1__c);
            Contact con = subIdToNewContactMap.get(subscription.Id);
            //START D-4034 14Dec2015 Added By C. Lin - Update the order with the Recipient Contact of the last subscription
            /*if(ord != null){
                ord.Billing_Contact__c = con.Id;
                
                orderSet.add(ord);
            }*/
            
            if(!orderSet.contains(ord.Id)){
                ord.Billing_Contact__c = con.Id;
                
                newOrderList.add(ord);
                orderSet.add(ord.Id);
            }
            //END D-4034 14Dec2015 Added By C. Lin
        }
        //START D-4034 14Dec2015 Added By C. Lin - Comment Out
        /*for(Order__c order : orderSet){
            newOrderList.add(order);
        }*/
        //END D-4034 14Dec2015 Added By C. Lin
        return newOrderList;
    }
    
    //START D-4034 08Dec2015 Added By C. Lin - Updating Recipient Contact in Order record
    public List<Order__c> updateOrderRecipientContact(Map<String, Contact> subZuoraIdToNewContactMap) {
        List<Order__c> newOrderList = new List<Order__c>();
        Set<String> SId = new Set<String>();
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c>();
        //START D-4034 14Dec2015 Added By C. Lin - Change to Id
        //Set<Order__c> orderSet = new Set<Order__c>();
        Set<Id> orderSet = new Set<Id>();
        //END D-4034 14Dec2015 Added By C. Lin
        for (String subId :subZuoraIdToNewContactMap.keySet()) {
            SId.add(subId);
        }
        
        List<Zuora__Subscription__c> SList = [SELECT Id, Contact__c, Order_Number_1__c, Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :SId AND (Zuora__SubscriptionEndDate__c >= TODAY OR Zuora__TermSettingType__c = 'EVERGREEN') Order By Name DESC]; //START END D-4034 14Dec2015 Added By C. Lin - Add Order By Name DESC
        
        for(Zuora__Subscription__c subs : SList){
            orderIdSet.add(subs.Order_Number_1__c);
        }
        
        List<Order__c> orderList = [SELECT Id, Recipient_Contact__c FROM Order__c WHERE Id IN :orderIdSet];
        
        for(Order__c order : orderList){
            orderIdToOrderMap.put(order.Id, order);
        }
        
        for(Zuora__Subscription__c subscription : SList){
            Order__c ord = orderIdToOrderMap.get(subscription.Order_Number_1__c);
            Contact con = subZuoraIdToNewContactMap.get(subscription.Zuora__Zuora_Id__c);
            //START D-4034 14Dec2015 Added By C. Lin - Update the order with the Recipient Contact of the last subscription
            /*if(ord != null){
                ord.Recipient_Contact__c = con.Id;
                
                orderSet.add(ord);
            }*/
            
            if(!orderSet.contains(ord.Id)){
                ord.Recipient_Contact__c = con.Id;
                
                newOrderList.add(ord);
                orderSet.add(ord.Id);
            }
            //END D-4034 14Dec2015 Added By C. Lin
        }
        //START D-4034 14Dec2015 Added By C. Lin - Comment Out
        /*for(Order__c order : orderSet){
            newOrderList.add(order);
        }*/
        //END D-4034 14Dec2015 Added By C. Lin
        return newOrderList;
    }
    //END D-4034 08Dec2015 Added By C. Lin
    
    public List<Zuora__CustomerAccount__c> updateBillAccBillingContact(Map<Id, Address_Assignment__c> conIdToAddressAssignIdMap, Map<Id, Contact> conIdToConMap, Map<Id, Zuora__CustomerAccount__c> subIdToBillAccMap, Map<Id, Contact> billAccIdToNewContactMap, Map<Id, Set<Zuora__Subscription__c>> accountIdToSubscriptionMap) {
        List<Zuora__CustomerAccount__c> newBillAccList = new List<Zuora__CustomerAccount__c>();
        Set<Zuora__CustomerAccount__c> billAccSet = new Set<Zuora__CustomerAccount__c>();
        for(Id conId : conIdToAddressAssignIdMap.keyset()){
            Contact cont = conIdToConMap.get(conId);
            //START D-2961 05/19/2015 Added by J. Sarion - Check if Account is included in the map
            if (accountIdToSubscriptionMap.containsKey(cont.AccountId)) {
                for(Zuora__Subscription__c sub : accountIdToSubscriptionMap.get(cont.AccountId)){
                    if(subIdToBillAccMap.containsKey(sub.Id)){
                        Zuora__CustomerAccount__c billAccount = subIdToBillAccMap.get(sub.Id);
                        //START UD-0883 AND UD-0899 5/9/2015 Added By C. Lin - Fix for Attempt to dereference null
                        if(billAccIdToNewContactMap.containsKey(billAccount.Id)){
                            Contact con = billAccIdToNewContactMap.get(billAccount.Id);
                            
                            billAccount.Billing_Contact__c = con.Id;
                        }
                        //END UD-0883 AND UD-0899 5/9/2015 Added By C. Lin
                        billAccSet.add(billAccount);
                    }
                }
            }
            //END D-2961 05/19/2015 Added by J. Sarion - Check if Account is included in the map
        }
        
        for(Zuora__CustomerAccount__c billA : billAccSet){
            newBillAccList.add(billA);
        }
        
        return newBillAccList;
    }
    
    public List<Map<String, Object>> updateSubBillingContact(List<Order__c> newOrderList, Map<Id, Contact> subIdToNewContactMap) {
        Map<String, Object> billSubMap;
        List<Map<String, Object>> billSubMapList = new List<Map<String, Object>>();
        Set<Id> billSId = new Set<Id>();
        //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
        Map<Id, List<Zuora__Subscription__c>> orderIdToSubMap = new Map<Id, List<Zuora__Subscription__c>>();
        //END UD-0899 4/16/2015 Added By C. Lin
        
        for (String subId :subIdToNewContactMap.keySet()) {
            billSId.add(subId);
        }
        //START UD-0883 AND UD-0899 5/11/2015 Added By C. Lin - Added AND Zuora__SubscriptionEndDate__c >= TODAY
        List<Zuora__Subscription__c> billSList = [SELECT Id, Contact__c, Order_Number_1__c, Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE Id IN :billSId AND Zuora__Status__c = 'Active' AND (Zuora__SubscriptionEndDate__c >= TODAY OR Zuora__TermSettingType__c = 'EVERGREEN')];
        //END UD-0883 AND UD-0899 5/11/2015 Added By C. Lin
        for(Zuora__Subscription__c subs : billSList){
            //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
            if(orderIdToSubMap.containsKey(subs.Order_Number_1__c)){
                orderIdToSubMap.get(subs.Order_Number_1__c).add(subs);
            }else{
                orderIdToSubMap.put(subs.Order_Number_1__c, new List<Zuora__Subscription__c> {subs});
            }
            //END UD-0899 4/16/2015 Added By C. Lin
        }
        
        for (Order__c orderRec : newOrderList) {
            //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
            for(Zuora__Subscription__c subscrip : orderIdToSubMap.get(orderRec.Id)){
                if(subscrip != null){
                    billSubMap = new Map<String, Object>();
                    billSubMap.put('Id', subscrip.Zuora__Zuora_Id__c);
                    billSubMap.put('Billing_Contact__c', orderRec.Billing_Contact__c);
                    
                    billSubMapList.add(billSubMap);
                }
            }
            //END UD-0899 4/16/2015 Added By C. Lin
        }
        
        return billSubMapList;
    }
    //START D-2258 3/5/2015 Added By C. Lin
    
    //START UD-0899 4/16/2015 Added By C. Lin - Fix for deactivating active status in Address Assignments
    public List<Address_Assignment__c> updatePreviousAddressAssignment(List<Address_Assignment__c> addressAssignmentList){
        List<Address_Assignment__c> listAddressAssignment = new List<Address_Assignment__c>();
        for(Address_Assignment__c aa : addressAssignmentList){
            aa.Active__c = false;
            aa.End_Date__c = date.today();
            
            listAddressAssignment.add(aa);
        }
        
        return listAddressAssignment;
    }
    //END UD-0899 4/16/2015 Added By C. Lin
    
    //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
    public void coaCheckIfArmsContact(List<Contact> contact_LIST){
    
        Map<Id, Zuora__CustomerAccount__c> conIdToBillAcc_MAP = new Map<Id, Zuora__CustomerAccount__c>();
        Set<Id> conId_SET = new Set<Id>();
        List<Zuora__CustomerAccount__c> billAcc_LIST = new List<Zuora__CustomerAccount__c>();
        List<Zuora__CustomerAccount__c> billAccToUpdate_LIST = new List<Zuora__CustomerAccount__c>();
        for(Contact c : contact_LIST){
            conId_SET.add(c.Id);
        }
        
        if(conId_SET.size()>0){
            billAcc_LIST = [Select Id, Name, ARMS_Customer_Number__c, Billing_Contact__c, ARMS_Account_Number__c From Zuora__CustomerAccount__c Where Billing_Contact__c In :conId_SET AND ARMS_Customer_Number__c <> null AND ARMS_Account_Number__c <> null];
        
        }
        
        if(billAcc_LIST.size()>0){
            for(Zuora__CustomerAccount__c ba : billAcc_LIST){
                if(conIdToBillAcc_MAP.containskey(ba.Id)){
                    //do nothing
                } else{
                    conIdToBillAcc_MAP.put(ba.Id, ba);
                    billAccToUpdate_LIST.add(ba);
                }
            }       
        }
        
        
        if(billAccToUpdate_LIST.size()>0){
            //START UD-2509 8/28/2015 Added By C. Lin - Uncomment
            ARMS_TriggerHandler.isSkipUpdate = true;   //Start-End: UD-1528 07/07/2015 Added by S.Puli
            //END UD-2509 8/28/2015 Added By C. Lin
            zuoraCustomerIds = updateCustomer(billAccToUpdate_LIST);
        }
        
    }
    //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
    
    //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
    public Set<Id> updateCustomer(List<Zuora__CustomerAccount__c> edtCustomerList){
    //START: UD-1528 11/06/2015 Added by S.Puli
        
        Set<Id> CusToUpdSet = new Set<Id>();
        
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> bCusList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> bCusInsertList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        
        Set<Id> queryBillAccSet = new Set<Id>();
        if(edtCustomerList<>null && edtCustomerList.size()>0){
            for(Zuora__CustomerAccount__c zc : edtCustomerList){
                queryBillAccSet.add(zc.Id);
            }
        }
        
        //List<Zuora__CustomerAccount__c> zCusToUpdList = new List<Zuora__CustomerAccount__c>();
        //START: UD-0964/095 04/22/2015 Added by S.PULI
        //List<Zuora__CustomerAccount__c> customerToCreateList = [Select lastmodifiedby.name,Id,Name, Status__c, Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, ARMS_Business_Profile__c, ARMS_Debt_Management__c, CreatedById, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, Zuora__BillToPostalCode__c, Zuora__BillToCity__c, Zuora__BillToCountry__c, Zuora__BillToName__c, Other_PaymentMethod__c, ARMS_ID__c, ARMS_Customer_Number__c, Billing_Contact__r.Email,Billing_Contact__r.Office_Extension__c  From Zuora__CustomerAccount__c Where Id In :queryBillAccSet];

        //START: UD-1528 07/07/2015 Added by S.Puli
        List<Zuora__CustomerAccount__c> customerToCreateList = [Select lastmodifiedby.name, ARMS_ID__c,Other_PaymentMethod__c,ARMS_Customer_Number__c,Billing_Contact__r.Address__r.Country__r.code__c,
            Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c,Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
            Billing_Contact__r.Address__r.Department__r.Department_Name__c,Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c,
            Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, Billing_Contact__r.Address__r.City__r.City_Name__c,
            Billing_Contact__r.Address__r.Airline_Number__c,Billing_Contact__r.Address__r.Flight_Number_1__c,Billing_Contact__r.Address__r.Flight_Number_2__c,
            Billing_Contact__r.Office_Number__c,Zuora__Account__r.Designation__c,Billing_Contact__r.Address__r.recordType.developerName,
            Zuora__Account__r.Attention_To_Care_Of__c,Zuora__Account__r.Attention_Care_Off_ind__c,Billing_Contact__r.Address__r.Address_1__c,
            Billing_Contact__r.Address__r.Address_2__c,Billing_Contact__r.Address__r.Address_3__c,Billing_Contact__r.Address__r.Address_4__c,
            Billing_Contact__r.Address__r.Building_Name_2__c,Billing_Contact__r.Address__r.Street_Name__c,Billing_Contact__r.Address__r.Unit_Number__c,
            Billing_Contact__r.Address__r.Level_Number__c,Billing_Contact__r.Address__r.Block_House_Number__c,Billing_Contact__r.Address__r.Country__c,
            Billing_Contact__r.Address__r.Postal_Code__r.name,SOA_Grouping__c,Billing_Contact__r.NRIC__c,CreatedBy.name,Id,Name, Status__c, 
            Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, ARMS_Business_Profile__c,
            ARMS_Debt_Management__c, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, Zuora__BillToPostalCode__c, Zuora__BillToCity__c, 
            Zuora__BillToCountry__c, Zuora__BillToName__c,Billing_Contact__r.Email,Billing_Contact__r.Office_Extension__c,Billing_Contact__r.HomePhone__c,
            //START UD-1527 6/23/15 Added by Manolo Valena - Added passport field.
            Billing_Contact__r.Passport__c,
            //END UD-1527 6/23/15 Added by Manolo Valena
            Billing_Contact__r.Handphone_Number__c,Billing_Contact__r.Fax__c,Attention_To_Care_Of_Indicator1__c,Attention_To_Care1__c, Billing_Contact__r.Mobile_Number__c, Billing_Contact__r.Mobile_Number_2__c, Billing_Contact__r.Name, Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c, Zuora__Account__r.Attention_To_Care_Of_Indicator__c, Zuora__Account__r.GST_Out_of_Scope__c, Zuora__Account__r.Staff_ID__c From Zuora__CustomerAccount__c Where Id In :queryBillAccSet];
            //END: UD-1528 07/07/2015 Added by S.Puli
 
        //END: UD-0964/095 04/22/2015 Added by S.PULI
        
        //START: UD-0964/095 04/22/2015 Added by S.PULI
        Set<String> updCusName_SET = new Set<String>();
        Set<String> updUniqKey_SET = new Set<String>();
        Set<String> updCusNum_SET = new Set<String>();
        Map<Id, List<BT_CO_ARMS_UpdateCustomerBatchFile__c>> updCusMasterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_UpdateCustomerBatchFile__c>>();
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> updCusToDelete_LIST = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        
        
        if(customerToCreateList.size()>0){
            for(Zuora__CustomerAccount__c zc : customerToCreateList){
                updCusName_SET.add(zc.Name);
                updUniqKey_SET.add(zc.Zuora__Account__r.AccountNumber);
                updCusNum_SET.add(zc.ARMS_Customer_Number__c);
            }
        }
        
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> oldUpdateCusRecord_LIST = [Select Id, CreatedDate,Customer_Name1__c, CCRID__c,Business_Profile__c, UniqueKey__c from BT_CO_ARMS_UpdateCustomerBatchFile__c Where CreatedDate = Today AND Customer_Name1__c IN :updCusName_SET AND UniqueKey__c IN :updUniqKey_SET AND CCRID__c IN :updCusNum_SET];
        
        if(oldUpdateCusRecord_LIST.size()>0 && customerToCreateList.size()>0){
            for(Zuora__CustomerAccount__c zc : customerToCreateList){
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c oldRec : oldUpdateCusRecord_LIST){
                    if(zc.Zuora__Account__r.Name == oldrec.Customer_Name1__c && zc.Zuora__Account__r.AccountNumber == oldrec.UniqueKey__c && zc.ARMS_Customer_Number__c == oldrec.CCRID__c){
                        if(updCusMasterToDetail_MAP.containskey(zc.Id)){
                            updCusMasterToDetail_MAP.get(zc.Id).add(oldRec);
                        } else{
                            updCusMasterToDetail_MAP.put(zc.Id, new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>{oldRec});
                        }
                    }
                }
            }
        }
        
        //END: UD-0964/095 04/22/2015 Added by S.PULI
        
        if(edtCustomerList.size()>0 && edtCustomerList<>null){
            for(Zuora__CustomerAccount__c ba : customerToCreateList){
                if(ba.Other_PaymentMethod__c == 'Invoice'){
                    //START: UD-0964/095 04/22/2015 Added by S.PULI
                    if(updCusMasterToDetail_MAP.containskey(ba.Id)){
                        if(updCusMasterToDetail_MAP.get(ba.Id).size()>0){
                            for(BT_CO_ARMS_UpdateCustomerBatchFile__c bRec : updCusMasterToDetail_MAP.get(ba.Id)){
                                updCusToDelete_LIST.add(bRec);
                            }
                        }
                    }
                    //END: UD-0964/095 04/22/2015 Added by S.PULI
                    string referenceKey = ba.Zuora__Account__r.AccountNumber;
                    string uniqueKey = ba.Zuora__Account__r.AccountNumber;
                    
                    if (ba.Zuora__Account__r.AccountNumber != null) {
                        
                        if (ba.Zuora__Account__r.AccountNumber.length() > 10) {
                            
                            referenceKey =  ba.Zuora__Account__r.AccountNumber.substring(0, 10);
                        }

                        if (ba.Zuora__Account__r.AccountNumber.length() > 26) {
                            
                            uniqueKey =     ba.Zuora__Account__r.AccountNumber.substring(0, 26);
                        }
                    }
                    
                    BT_CO_ARMS_UpdateCustomerBatchFile__c updateCusRecord = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
                        updateCusRecord.CCRID__c = ba.ARMS_ID__c;
                        updateCusRecord.Customer_Name1__c = ba.Name;
                        updateCusRecord.UniqueKey__c = uniqueKey;
                        if(ba.lastmodifiedby.name.length() > 15){
                            updateCusRecord.Update_ID__c = ba.lastmodifiedby.name.substring(0, 15);
                        } else{
                            updateCusRecord.Update_ID__c = ba.lastmodifiedby.name;
                        }
                            String datedata = String.valueOf(date.today());
                            String datestring = datedata.replace('-','');
                        updateCusRecord.UpdateDate__c = datestring;
                            String timedata = String.valueOf(Datetime.now());
                            String timesubstring = timedata.substringAfter(' ');
                            String timestring = timesubstring.replace(':','');
                        updateCusRecord.UpdateTime__c = timestring;
                        //updateCusRecord.Postal_Code__c = ba.Zuora__BillToPostalCode__c;
                        //updateCusRecord.City_Zip__c = ba.Zuora__BillToCity__c;
                        updateCusRecord.Contact_Name__c = ba.Billing_Contact__r.Name;
            //START UD-2418 02-Sept-2015 Added By S.Puli 
                        updateCusRecord.Contact_Designation__c = ba.Zuora__Account__r.Designation__c;
                        updateCusRecord.Contact_Extension__c = ba.Billing_Contact__r.Office_Extension__c;
                        //END UD-2418 02-Sept-2015 Added By S.Puli
                        updateCusRecord.RecordType__c = 'Master';
                        updateCusRecord.Status__c = 'New';
                        //START: UD-0802 04/08/2015 Added by S.PULI
                        updateCusRecord.Business_Profile__c = ba.ARMS_Business_Profile__c;
                        updateCusRecord.ReferenceKey__c = referenceKey;
                        updateCusRecord.SPH_Staff_Indicator__c='N';
                        //END: UD-0802 04/08/2015 Added by S.PULI
                        
                        //START: UD-1528 07/07/2015 Added by S.Puli
                        if(ba.Zuora__Account__r.Staff_ID__c <> null){
                            updateCusRecord.SPH_Staff_Indicator__c = 'Y';
                        }
                        //END: UD-1528 07/07/2015 Added by S.Puli
                        if(ba.Billing_Contact__r.NRIC__c != null){
                            updateCusRecord.ID_Type__c = 'NRIC';
                            updateCusRecord.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                        }
            //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                        else {
                            if(ba.Billing_Contact__r.Passport__c != null) {
                                updateCusRecord.ID_Type__c = GlobalVariableClass.PASS;
                                updateCusRecord.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                            }
                        }
                        //END UD-1527 6/23/15 Added by Manolo Valena
                        
                        //START hotfix 05/28/2015
                        updateCusRecord.Customer_Status__c = 'A';
                        updateCusRecord.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                        updateCusRecord.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                        //END hotfix 05/28/2015
                        //START D-3046 06/03/2015
                        updateCusRecord.GST_OutOfScope_Indicator__c ='';
                        if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                            updateCusRecord.GST_OutOfScope_Indicator__c ='Y';
                        } else{
                            updateCusRecord.GST_OutOfScope_Indicator__c ='N';
                        }
                        //END D-3046 06/03/2015

                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == 'Local'){
                            updateCusRecord.Postal_Code__c = ba.Billing_Contact__r.Address__r.Postal_Code__r.name;
                            updateCusRecord.City_Zip__c = '';
                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                            updateCusRecord.Block_House_No__c = ba.Billing_Contact__r.Address__r.Block_House_Number__c;
                            updateCusRecord.Floor_No__c = ba.Billing_Contact__r.Address__r.Level_Number__c;
                            updateCusRecord.Unit_No__c = ba.Billing_Contact__r.Address__r.Unit_Number__c;
                            updateCusRecord.Street__c = ba.Billing_Contact__r.Address__r.Street_Name__c;
                            updateCusRecord.Building_Secondary__c = ba.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c;
                            updateCusRecord.PO_Box_No__c = ba.Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c;
                        }
                        
                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == 'Overseas'){
                            updateCusRecord.Address1__c = ba.Billing_Contact__r.Address__r.Address_1__c;
                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Address_2__c;
                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Address_3__c;
                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Address_4__c;
                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                        }
                        
                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == 'Internal'){
                            updateCusRecord.Address1__c = ba.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c;
                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Department__r.Department_Name__c;
                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c;
                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c;
                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                        }
                        
                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == 'Airline'){
                            updateCusRecord.Address1__c = (ba.Billing_Contact__r.Address__r.City__r.City_Name__c.length() > 40 ? ba.Billing_Contact__r.Address__r.City__r.City_Name__c.subString(0,40) : ba.Billing_Contact__r.Address__r.City__r.City_Name__c ) ;
                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Airline_Number__c;
                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Flight_Number_1__c;
                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Flight_Number_2__c;
                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                        }
                        
                        /*if(ba.Zuora__BillToAddress1__c<>null){
                            if(ba.Zuora__BillToAddress1__c.length() > 40){
                                updateCusRecord.Address1__c = ba.Zuora__BillToAddress1__c.substring(0, 40);
                            } else {
                                updateCusRecord.Address1__c = ba.Zuora__BillToAddress1__c;
                            }
                        }
                        if(ba.Zuora__BillToAddress2__c<>null){
                            if(ba.Zuora__BillToAddress2__c.length() > 40){
                                updateCusRecord.Address2__c = ba.Zuora__BillToAddress2__c.substring(0, 40);
                            } else {
                                updateCusRecord.Address2__c = ba.Zuora__BillToAddress2__c;
                            }
                        }*/
                        
                        BT_CO_ARMS_UpdateCustomerBatchFile__c updateCusRecord2 = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
                        updateCusRecord2.CCRID__c = ba.ARMS_ID__c;
                        updateCusRecord2.Customer_Name1__c = ba.Name;
                        updateCusRecord2.UniqueKey__c = uniqueKey;
                        if(ba.lastmodifiedby.name.length() > 15){
                            updateCusRecord2.Update_ID__c = ba.lastmodifiedby.name.substring(0, 15);
                        } else{
                            updateCusRecord2.Update_ID__c = ba.lastmodifiedby.name;
                        }
                            String datedata2 = String.valueOf(date.today());
                            String datestring2 = datedata2.replace('-','');
                        updateCusRecord2.UpdateDate__c = datestring2;
                            String timedata2 = String.valueOf(Datetime.now());
                            String timesubstring2 = timedata2.substringAfter(' ');
                            String timestring2 = timesubstring2.replace(':','');
                        updateCusRecord2.UpdateTime__c = timestring2;
                        //updateCusRecord2.Postal_Code__c = ba.Zuora__BillToPostalCode__c;
                        //updateCusRecord2.City_Zip__c = ba.Zuora__BillToCity__c;
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //updateCusRecord2.Contact_Name__c = ba.Billing_Contact__r.Name;
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        updateCusRecord2.RecordType__c = 'Detail';
                        updateCusRecord2.Status__c = 'New';
                        //START: UD-0802 04/08/2015 Added by S.PULI
                        updateCusRecord2.Business_Profile__c = ba.ARMS_Business_Profile__c;
                        //END: UD-0802 04/08/2015 Added by S.PULI
                        //START: UD-0964/095 04/22/2015 Added by S.PULI
                        updateCusRecord2.ContactNo_Email__c = ba.Billing_Contact__r.Office_Number__c;
                        updateCusRecord2.Contact_Type__c = 'O';
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //updateCusRecord2.Contact_Designation__c = ba.Zuora__Account__r.Designation__c;
                        //updateCusRecord2.Contact_Extension__c = ba.Billing_Contact__r.Office_Extension__c; //START/END UD-0118 5/20/15 MGaelo change OfficeExtension into phone
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        
                        //START: UD-1528 11/06/2015 Added by S.Puli
                        if(updateCusRecord2.ContactNo_Email__c == null){
                            updateCusRecord2.Contact_Type__c = null;
                        }
                        //END: UD-1528 11/06/2015 Added by S.Puli
                        //END: UD-0964/095 04/22/2015 Added by S.PULI
                        /*if(ba.Zuora__BillToAddress1__c<>null){
                            if(ba.Zuora__BillToAddress1__c.length() > 40){
                                updateCusRecord2.Address1__c = ba.Zuora__BillToAddress1__c.substring(0, 40);
                            } else {
                                updateCusRecord2.Address1__c = ba.Zuora__BillToAddress1__c;
                            }
                        }
                        if(ba.Zuora__BillToAddress2__c<>null){
                            if(ba.Zuora__BillToAddress2__c.length() > 40){
                                updateCusRecord2.Address2__c = ba.Zuora__BillToAddress2__c.substring(0, 40);
                            } else {
                                updateCusRecord2.Address2__c = ba.Zuora__BillToAddress2__c;
                            }
                        }*/
                        //START hotfix 05/28/2015
                        updateCusRecord2.Customer_Status__c = 'A';
                        if(ba.Billing_Contact__r.NRIC__c != null){
                            updateCusRecord2.ID_Type__c = 'NRIC';
                            updateCusRecord2.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                        }
            //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                        else {
                            if(ba.Billing_Contact__r.Passport__c != null) {
                                updateCusRecord2.ID_Type__c = GlobalVariableClass.PASS;
                                updateCusRecord2.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                            }
                        }
                        //END UD-1527 6/23/15 Added by Manolo Valena
                        updateCusRecord2.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                        updateCusRecord2.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                        //END hotfix 05/28/2015
                        //START D-3046 06/03/2015
                        updateCusRecord2.GST_OutOfScope_Indicator__c ='';
                        if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                            updateCusRecord2.GST_OutOfScope_Indicator__c ='Y';
                        } else{
                            updateCusRecord2.GST_OutOfScope_Indicator__c ='N';
                        }
                        //END D-3046 06/03/2015
                        
                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec3 = null;
                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec4 = null;
                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec5 = null;
                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec6 = null;

                        if(ba.Billing_Contact__r.HomePhone__c != null){
                            cusRec3 = updateCusRecord2.clone();
                            cusRec3.Contact_Type__c = 'H';
                            cusRec3.ContactNo_Email__c = ba.Billing_Contact__r.HomePhone__c;
                            //START hotfix 05/28/2015
                            cusRec3.Customer_Status__c = 'A';
                            if(ba.Billing_Contact__r.NRIC__c != null){
                                cusRec3.ID_Type__c = 'NRIC';
                                cusRec3.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                            }
              //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                            else {
                                if(ba.Billing_Contact__r.Passport__c != null) {
                                    cusRec3.ID_Type__c = GlobalVariableClass.PASS;
                                    cusRec3.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                                }
                            }
                            //END UD-1527 6/23/15 Added by Manolo Valena
                            cusRec3.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                            cusRec3.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                            //END hotfix 05/28/2015
                            //START D-3046 06/03/2015
                            cusRec3.GST_OutOfScope_Indicator__c ='';
                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                cusRec3.GST_OutOfScope_Indicator__c ='Y';
                            } else{
                                cusRec3.GST_OutOfScope_Indicator__c ='N';
                            }
                            //END D-3046 06/03/2015
                        }
                        
                        if(ba.Billing_Contact__r.Mobile_Number__c != null || ba.Billing_Contact__r.Mobile_Number_2__c != null){
                            cusRec4 = updateCusRecord2.clone();
                            cusRec4.Contact_Type__c='M';
                            if(ba.Billing_Contact__r.Mobile_Number__c <> null){
                                cusRec4.ContactNo_Email__c = ba.Billing_Contact__r.Mobile_Number__c;
                            } else if(ba.Billing_Contact__r.Mobile_Number_2__c <> null){
                                cusRec4.ContactNo_Email__c = ba.Billing_Contact__r.Mobile_Number_2__c;
                            }
                            //START hotfix 05/28/2015
                            cusRec4.Customer_Status__c = 'A';
                            if(ba.Billing_Contact__r.NRIC__c != null){
                                cusRec4.ID_Type__c = 'NRIC';
                                cusRec4.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                            }
              //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                            else {
                                if(ba.Billing_Contact__r.Passport__c != null) {
                                    cusRec4.ID_Type__c = GlobalVariableClass.PASS;
                                    cusRec4.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                                }
                            }
                            //END UD-1527 6/23/15 Added by Manolo Valena
                            cusRec4.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                            cusRec4.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                            //END hotfix 05/28/2015
                            //START D-3046 06/03/2015
                            cusRec4.GST_OutOfScope_Indicator__c ='';
                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                cusRec4.GST_OutOfScope_Indicator__c ='Y';
                            } else{
                                cusRec4.GST_OutOfScope_Indicator__c ='N';
                            }
                            //END D-3046 06/03/2015
                        }

                        if(ba.Billing_Contact__r.Fax__c != null){

                            cusRec5 = updateCusRecord2.clone();
                            cusRec5.Contact_Type__c = 'F';  
                            cusRec5.ContactNo_Email__c = ba.Billing_Contact__r.Fax__c;

                            //START hotfix 05/28/2015
                            cusRec5.Customer_Status__c = 'A';
                            if(ba.Billing_Contact__r.NRIC__c != null){
                                cusRec5.ID_Type__c = 'NRIC';
                                cusRec5.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                            }
              //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                            else {
                                if(ba.Billing_Contact__r.Passport__c != null) {
                                    cusRec5.ID_Type__c = GlobalVariableClass.PASS;
                                    cusRec5.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                                }
                            }
                            //END UD-1527 6/23/15 Added by Manolo Valena
                            cusRec5.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                            cusRec5.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                            //END hotfix 05/28/2015
                            //START D-3046 06/03/2015
                            cusRec5.GST_OutOfScope_Indicator__c ='';
                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                cusRec5.GST_OutOfScope_Indicator__c ='Y';
                            } else{
                                cusRec5.GST_OutOfScope_Indicator__c ='N';
                            }
                            //END D-3046 06/03/2015
                        }
                        
                        if(ba.Billing_Contact__r.Email != null){
                            cusRec6 = updateCusRecord2.clone();
                            cusRec6.Contact_Type__c='E';
                            cusRec6.ContactNo_Email__c = ba.Billing_Contact__r.Email;
                            //START hotfix 05/28/2015
                            cusRec6.Customer_Status__c = 'A';
                            if(ba.Billing_Contact__r.NRIC__c != null){
                                cusRec6.ID_Type__c = 'NRIC';
                                cusRec6.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                            }
              //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                            else {
                                if(ba.Billing_Contact__r.Passport__c != null) {
                                    cusRec6.ID_Type__c = GlobalVariableClass.PASS;
                                    cusRec6.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                                }
                            }
                            //END UD-1527 6/23/15 Added by Manolo Valena
                            cusRec6.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                            cusRec6.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                            //END hotfix 05/28/2015
                            //START D-3046 06/03/2015
                            cusRec6.GST_OutOfScope_Indicator__c ='';
                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                cusRec6.GST_OutOfScope_Indicator__c ='Y';
                            } else{
                                cusRec6.GST_OutOfScope_Indicator__c ='N';
                            }
                            //END D-3046 06/03/2015
                        }
                    //START D-3775 10/29/15 RReyes - cut ContactNo_Email__c to 40 characters
                    String tempCont = '';
                    if(updateCusRecord != null){
                        if(updateCusRecord.ContactNo_Email__c != null){
                            tempCont = updateCusRecord.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                updateCusRecord.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(updateCusRecord2 != null){
                        if(updateCusRecord2.ContactNo_Email__c != null){
                            tempCont = updateCusRecord2.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                updateCusRecord2.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec3 != null){
                        if(cusRec3.ContactNo_Email__c != null){
                            tempCont = cusRec3.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                cusRec3.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec4 != null){
                        if(cusRec4.ContactNo_Email__c != null){
                            tempCont = cusRec4.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                cusRec4.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec5 != null){
                        if(cusRec5.ContactNo_Email__c != null){
                            tempCont = cusRec5.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                cusRec5.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec6 != null){
                        if(cusRec6.ContactNo_Email__c != null){
                            tempCont = cusRec6.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                cusRec6.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    //END D-3775 10/29/15 RReyes - cut ContactNo_Email__c to 40 characters                  
                        
                    bCusList.add(updateCusRecord);
                    bCusInsertList.add(updateCusRecord);
                    //START UD-2418 02-Sept-2015 Added By S.Puli 
                    if(updateCusRecord2.Contact_Type__c <> null){
                        bCusInsertList.add(updateCusRecord2);
                    }
                    //END UD-2418 02-Sept-2015 Added By S.Puli 
                    if(cusRec3 != null) bCusInsertList.add(cusRec3);
                    if(cusRec4 != null) bCusInsertList.add(cusRec4);
                    if(cusRec5 != null) bCusInsertList.add(cusRec5);
                    if(cusRec6 != null) bCusInsertList.add(cusRec6);
                    //zCusTOUpdList.add(ba);
                }
            }
            //START: UD-0964/095 04/22/2015 Added by S.PULI
            if(updCusToDelete_LIST.size()>0){
        //START UD-2509 8/28/2015 Added By C. Lin - update ARMS Customer address
                //Database.delete(updCusToDelete_LIST, false);
                if(updCusToDelete_LIST.size()>0){
                    Map<Id, BT_CO_ARMS_UpdateCustomerBatchFile__c> newMapToDelete = new Map<Id, BT_CO_ARMS_UpdateCustomerBatchFile__c>();
                    newMapToDelete.putAll(updCusToDelete_LIST);
                    Database.delete(newMapToDelete.values(), false);
                }
                //END UD-2509 8/28/2015 Added By C. Lin
            }
            //END: UD-0964/095 04/22/2015 Added by S.PULI
            if(bCusInsertList<>null && bCusInsertList.size()>0 && bCusList<>null && bCusList.size()>0){
            
            insert bCusInsertList;
            
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c a : bCusList){
                    CusToUpdSet.add(a.Id);
                }
            }
        }
        //END: UD-1528 11/06/2015 Added by S.Puli
        return CusToUpdSet;
        
    }
    //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
    
    //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
    public static void updateCustomerWebserviceNonFuture(Set<Id> CusToUpdSet){
        Logger logger = new Logger(BatchAddressAssignmentEffectiveDate.class.getName(),'SP050'); //START END D-1011 MD-28 Dags 18/06/15
        //START: UD-1528 11/06/2015 Added by S.Puli
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> updCusBatchRec = [Select Id, Name, UniqueKey__c, CCRID__c, Address1__c, Address2__c, Customer_Name1__c, Update_ID__c, Contact_Name__c, City_Zip__c, Postal_Code__c, Business_Profile__c, RecordType__c, Address3__c, Address4__c, Block_House_No__c, Building_Secondary__c,CareOf_AttentionTo_Indicator__c,CareOf_ATtentionTo_Party__c,Country__c,Customer_Status__c,Floor_No__c,GST_OutOfScope_Indicator__c,ID_Number__c,ID_Type__c,PO_Box_No__c,SPH_Staff_Indicator__c,Street__c,Unit_No__c from BT_CO_ARMS_UpdateCustomerBatchFile__c Where  Id =: CusToUpdSet];
        
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> deleteCusList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
    
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> updCusToDelete_LIST = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        
        Set<String> updCusName_SET = new Set<String>();
        Set<String> updUniqKey_SET = new Set<String>();
        Set<String> updCusNum_SET = new Set<String>();
        
        if(updCusBatchRec.size()>0){
            for(BT_CO_ARMS_UpdateCustomerBatchFile__c zc : updCusBatchRec){
                updCusName_SET.add(zc.Customer_Name1__c);
                updUniqKey_SET.add(zc.UniqueKey__c);
                updCusNum_SET.add(zc.CCRID__c);
            }
        }

        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> oldUpdateCusRecord_LIST = [Select Id, CreatedDate,Customer_Name1__c, CCRID__c,Business_Profile__c, UniqueKey__c,Contact_Designation__c, Contact_Extension__c, Contact_Name__c, ContactNo_Email__c, Contact_Type__c, RecordType__c from BT_CO_ARMS_UpdateCustomerBatchFile__c Where CreatedDate = Today AND Customer_Name1__c IN :updCusName_SET AND UniqueKey__c IN :updUniqKey_SET AND CCRID__c IN :updCusNum_SET];
        
        Map<Id, List<BT_CO_ARMS_UpdateCustomerBatchFile__c>> updCusMasterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_UpdateCustomerBatchFile__c>>();
        
        if(oldUpdateCusRecord_LIST.size()>0 && updCusBatchRec.size()>0){
            for(BT_CO_ARMS_UpdateCustomerBatchFile__c zc : updCusBatchRec){
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c oldRec : oldUpdateCusRecord_LIST){
                    if(zc.Customer_Name1__c == oldrec.Customer_Name1__c && zc.UniqueKey__c == oldrec.UniqueKey__c && zc.CCRID__c == oldrec.CCRID__c){
                        if(updCusMasterToDetail_MAP.containskey(zc.Id)){
                            updCusMasterToDetail_MAP.get(zc.Id).add(oldRec);
                        } else{
                            updCusMasterToDetail_MAP.put(zc.Id, new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>{oldRec});
                        }
                    }
                }
            }
        }
        
        if(updCusBatchRec<>null && updCusBatchRec.size()>0){
        
            for(BT_CO_ARMS_UpdateCustomerBatchFile__c bc : updCusBatchRec){
                
                wwwSphComArWsWsdlCam.UpdateCustomerRequestType updCusRec = new wwwSphComArWsWsdlCam.UpdateCustomerRequestType();
                updCusRec.CusUpd = new wwwSphComArWsSchemaCamUpdatecusto.CusUpd_element();
                system.debug(updCusRec);
                
                updCusRec.CusUpd.SysId = ConstantsSLB.getOther('ARMS_SysId');
                //START: D-4025 12/11/15 Added by Manolo Valena
                if(bc.CCRID__c != null) { 
                    updCusRec.CusUpd.CusN = bc.CCRID__c;
                }
                else {
                    logger.log(false, GlobalVariableClass.ERR_BATCH_ADD, bc.Id);
                    continue;
                }
                //END: D-4025 12/11/15 Added by Manolo Valena
                updCusRec.CusUpd.CusM1 = bc.Customer_Name1__c;
                updCusRec.CusUpd.UniqId = bc.UniqueKey__c;
                updCusRec.CusUpd.Syno = bc.UniqueKey__c;
                updCusRec.CusUpd.CusA1 = bc.Address1__c;
                updCusRec.CusUpd.CusA2 = bc.Address2__c;
                updCusRec.CusUpd.UpdId = bc.Update_ID__c;
                    String datedata = String.valueOf(date.today());
                    String datestring = datedata.replace('-','');
                updCusRec.CusUpd.UpdDte = datestring;
                    String timedata = String.valueOf(Datetime.now());
                    String timesubstring = timedata.substringAfter(' ');
                    String timestring = timesubstring.replace(':','');
                updCusRec.CusUpd.UpdTme = timestring;
                updCusRec.CusUpd.CityM = bc.City_Zip__c;
                updCusRec.CusUpd.PstC = bc.Postal_Code__c;
                updCusRec.CusUpd.BizP = bc.Business_Profile__c;
                updCusRec.CusUpd.Unlnk = 'N';
                
                updCusRec.CusUpd.CusA3 = bc.Address3__c;
                updCusRec.CusUpd.CusA4 = bc.Address4__c;
                updCusRec.CusUpd.BlkN = bc.Block_House_No__c;
                updCusRec.CusUpd.BldgSec = bc.Building_Secondary__c;
                updCusRec.CusUpd.AttnI = bc.CareOf_AttentionTo_Indicator__c;
                updCusRec.CusUpd.Attn = bc.CareOf_ATtentionTo_Party__c;
                updCusRec.CusUpd.Cntry = bc.Country__c;
                updCusRec.CusUpd.CusSts = bc.Customer_Status__c;
                updCusRec.CusUpd.FlrN = bc.Floor_No__c;
                updCusRec.CusUpd.GstOOSI = bc.GST_OutOfScope_Indicator__c;
                updCusRec.CusUpd.IdN = bc.ID_Number__c;
                updCusRec.CusUpd.IdTyp = bc.ID_Type__c;
                updCusRec.CusUpd.PoBoxN = bc.PO_Box_No__c;
                updCusRec.CusUpd.StfI = bc.SPH_Staff_Indicator__c;
                updCusRec.CusUpd.Str = bc.Street__c;
                updCusRec.CusUpd.UntN = bc.Unit_No__c;
                //Unlink_Customer__c
                
                //START: UD-1528 11/06/2015 Added by S.Puli
                List<wwwSphComArWsSchemaCamUpdatecusto.ContType> contAccArray = new List<wwwSphComArWsSchemaCamUpdatecusto.ContType>();
            
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c zUpdFile : updCusMasterToDetail_MAP.get(bc.Id)){
                    
                    
                    if(zUpdFile.Contact_Type__c <> null ){  
                    
                        wwwSphComArWsSchemaCamUpdatecusto.ContType armsAccContact = new wwwSphComArWsSchemaCamUpdatecusto.ContType();
                        
                        armsAccContact.CtPeM1 = zUpdFile.Contact_Name__c;
                        armsAccContact.Dsgtn = zUpdFile.Contact_Designation__c;
                        armsAccContact.CtTyp = zUpdFile.Contact_Type__c;
                        armsAccContact.CtNoEm = zUpdFile.ContactNo_Email__c;
                        armsAccContact.CtExt = zUpdFile.Contact_Extension__c;
                        
                        contAccArray.add(armsAccContact);
                    }
                    
                }
                wwwSphComArWsSchemaCamUpdatecusto.L_ContType lAccContType = new wwwSphComArWsSchemaCamUpdatecusto.L_ContType();
                lAccContType.Cont = contAccArray;
                //END: UD-1528 11/06/2015 Added by S.Puli
            
                updCusRec.CusUpd.L_Cont = lAccContType;
            
                updCusRec.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
                updCusRec.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
                updCusRec.user_x.password = ConstantsSLB.getOther('ARMS_password');
                system.debug('Request File>>>'+updCusRec);
                wwwSphComArWsWsdlCam.CAMSOAP CusUpdCAM = new wwwSphComArWsWsdlCam.CAMSOAP();
                wwwSphComArWsWsdlCam.UpdateCustomerResponseType updCusRespRec = CusUpdCAM.UpdateCustomer(updCusRec);
                system.debug(updCusRespRec);
            
                if(updCusRespRec<>null){
                    if(updCusRespRec.messages<>null){
                        if(updCusRespRec.messages.overallStatus=='Successful'){
                              
                            deleteCusList.add(bc);
                            
                        }
                        //START D-1011 MD-28 Dags 18/06/15
                        else {
                            logger.log(false,''+bc); 
                        }
                        //END D-1011 MD-28 Dags 18/06/15            
                    } 
                }  
                //START UD-3204 Nov-6-2015 Added By C. Lin - Comment Out
                //Logger.save(); //START END D-1011 MD-28 Dags 18/06/15
                //END UD-3204 Nov-6-2015 Added By C. Lin
            }

            if(deleteCusList<>null && deleteCusList.size()>0){
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c dRec : deleteCusList){
                    updCusToDelete_LIST.addAll(updCusMasterToDetail_MAP.get(dRec.Id));
                }
        //START UD-2509 8/28/2015 Added By C. Lin - update ARMS Customer address
                //Database.delete(updCusToDelete_LIST, false);
                if(updCusToDelete_LIST.size()>0){
                    Map<Id, BT_CO_ARMS_UpdateCustomerBatchFile__c> newMapToDelete = new Map<Id, BT_CO_ARMS_UpdateCustomerBatchFile__c>();
                    newMapToDelete.putAll(updCusToDelete_LIST);
                    Database.delete(newMapToDelete.values(), false);
                }
                //END UD-2509 8/28/2015 Added By C. Lin
                system.debug('deleteCusList>>'+deleteCusList);
            }
        }
        //END: UD-1528 11/06/2015 Added by S.Puli
        logger.save(); //START END D-1011 MD-28 Dags 18/06/15
    }
    //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
}