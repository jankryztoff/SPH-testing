public class AsiaOneBulkCreationTriggerHandler {

    static map<string, Asia1__c> existingLdapId_asia1 = new map<string, Asia1__c>();    // Start/End UD-3329 30Nov15 JohnD
    // Start UD-3305 25Nov15 JohnD
    public void doBeforeInsert(list<BT_CO_ASIAONE_BulkIdCreation__c> recordList) {
        verify(recordList);
    }
    // End UD-3305 25Nov15 JohnD
    public void doAfterInsert(list<BT_CO_ASIAONE_BulkIdCreation__c> recordsList) {

        // Start UD-3329 30Nov15 JohnD
        final string REQUEST_FIELD_NAME_SUBSCRIPTION_ID = 'subscriptionId';
        final string REQUEST_FIELD_NAME_SERVICE_FLAGS = 'serviceFlags';
        final string REQUEST_FIELD_NAME_LDAP_ID = 'ldapId';
        final string REQUEST_FIELD_NAME_ASIA1_SUBSCRIPTION_IDENTIFIERS = 'asia1SubscriptionIdentifiers';
        
        map<string, map<string, string>> subscriptionIdAsia1Id_requestObject = new map<string, map<string, string>>();
        map<string, string> requestObject;
        map<string, Asia1_Subscription__c> asia1SubscriptionIdentifier_Asia1Subscription = new map<string, Asia1_Subscription__c>();
        list<Asia1__c> newAsia1List = new list<Asia1__c>(); 
        // End UD-3329 30Nov15 JohnD
        
        // Start UD-3401 23Dec15 JohnD
        final integer MAX_ASIA1_LEVEL_1 = 2500;
        integer batchCounter = 1;
        integer counter = 1;
        integer totalAsia1;
        set<id> asia1IdSetLevel1 = new set<id>();
        map<string, Asia1__c> ldapId_newAsia1 = new map<string, Asia1__c>();    // Start/End UD-3401 11Jan16 JohnD
        // End UD-3401 23Dec15 JohnD

        map<string, list<Asia1__c>> subscriptionName_asia1List = new map<string, list<Asia1__c>>(); // Start/End D-4157 21Dec15 JohnD
        List<Asia1__c> asia1RecList = new List<Asia1__c>();
        List<Asia1_Subscription__c> asia1SubscriptionList = new List<Asia1_Subscription__c>();
        Set<id> packSet = new Set<id>();
        set<id> asia1IdSet = new set<id>();
        map<string, set<id>> username_asia1SubscriptionIdSet = new map<string, set<id>>();
        map<string, id> username_subscriptionId = new map<string, id>();
        map<string, string> username_serviceFlags = new map<string, string>();
        
        Map<String, zuora__subscription__c> subMap = new Map<String, zuora__subscription__c>();
        Map<zuora__subscription__c, List<Asia1__c>> subAsia1Map = new Map<zuora__subscription__c, List<Asia1__c>>();
        Map<id, Set<Package_Access_Flag__c>> packPafMap = new Map<id, Set<Package_Access_Flag__c>>();
        
        Set<String> subNameSet = new Set<String>();
        
        for(BT_CO_ASIAONE_BulkIdCreation__c tempRec : recordsList){
            subNameSet.add(tempRec.subscription__c);
        }
        
        for (zuora__subscription__c tempRec : [select id, name, Main_Package_1__c, Order_Number_1__r.Name, 
                Order_Line_Item_Number_1__c, Recipient_Contact__r.firstName, Recipient_Contact__r.LastName, 
                Recipient_Contact__r.Mobile_Number__c, Recipient_Contact__r.HomePhone__c, Recipient_Contact__r.Email__c 
                from zuora__subscription__c where name in :subNameSet]) {   // Start/End UD-3325 27Nov15 JohnD - added Order_Number_1__c
            
            subMap.put(tempRec.name, tempRec);
            packSet.add(tempRec.Main_Package_1__c);
        }
        
        List<Package_Access_Flag__c> pafTmp = [select Package__c, Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, No_of_Concurrent_Users__c from Package_Access_Flag__c where Package__r.id in :packSet];
        
        for(id tmpPack : packSet){
            Set<Package_Access_Flag__c> pafList = new Set<Package_Access_Flag__c>();
            for(Package_Access_Flag__c tmp : pafTmp){
                if(tmpPack == tmp.Package__c){
                    pafList.add(tmp);
                }
            }
            packPafMap.put(tmpPack, pafList);
        }
        
        for(BT_CO_ASIAONE_BulkIdCreation__c tempRec : recordsList){
    // Start UD-3401 11Jan16 JohnD - improved logic            
            Asia1__c asia1Rec;
            // Start UD-3329 30Nov15 JohnD - added logic for existing ldapid

            if (!existingLdapId_asia1.keySet().contains(tempRec.User_ID_LDAP_ID__c)) {  
                
                if (ldapId_newAsia1.get(tempRec.User_ID_LDAP_ID__c) == null) {
                    
                    asia1Rec = new Asia1__c();
                    asia1Rec.Email__c = tempRec.Email__c;
                    asia1Rec.Display_Name__c = tempRec.Display_Name__c;
                    asia1Rec.User_ID_LDAP_ID__c = tempRec.User_ID_LDAP_ID__c;
                    asia1Rec.Password__c = tempRec.Password__c;
                    asia1Rec.Secret_Answer__c = tempRec.Secret_Answer__c;
                    asia1Rec.Secret_Question__c = tempRec.Secret_Question__c;
                    asia1Rec.Contact__c = subMap.get(tempRec.subscription__c).Recipient_Contact__r.id;
                    asia1Rec.status__c = 'Created';
                    // Start UD-3325 27Nov15 JohnD
                    if (subMap.get(tempRec.subscription__c) != null) {
                        asia1Rec.Order_Number__c = subMap.get(tempRec.subscription__c).Order_Number_1__r.Name;
                    }
                    // End UD-3325 27Nov15 JohnD
                    // newAsia1List.add(asia1Rec);  //  - commented out
                    
                    ldapId_newAsia1.put(tempRec.User_ID_LDAP_ID__c, asia1Rec);
                
                } else {
                    asia1Rec = ldapId_newAsia1.get(tempRec.User_ID_LDAP_ID__c);
                }
                
            } else {
                asia1Rec = existingLdapId_asia1.get(tempRec.User_ID_LDAP_ID__c);
            }
            // End UD-3329 30Nov15 JohnD - added logic for existing ldapid
    // End UD-3401 11Jan16 JohnD - improved logic            
            // Start D-4157 21Dec15 JohnD - added logic to segregate 
            asia1RecList = new list<Asia1__c>();
            if (subscriptionName_asia1List.get(tempRec.subscription__c) != null) {
                asia1RecList = subscriptionName_asia1List.get(tempRec.subscription__c);
            }
            asia1RecList.add(asia1Rec);
            subscriptionName_asia1List.put(tempRec.subscription__c, asia1RecList);
            // End D-4157 21Dec15 JohnD - added logic to segregate

            subAsia1Map.put(subMap.get(tempRec.subscription__c), asia1RecList);              
        }
        
        //insert newAsia1List;    // Start/End UD-3329 30Nov15 JohnD - replaced asia1RecList by newAsia1List // Start/End UD-3401 11Jan16 JohnD - commented out
        insert ldapId_newAsia1.values();    // Start/End UD-3401 11Jan16 JohnD
        
        for(zuora__subscription__c subId : subAsia1Map.keySet()){
            
            List<Asia1__c> asia1RecListTmp = subAsia1Map.get(subId);
            
            for(Asia1__c asia1Tmp : asia1RecListTmp){
                
                Set<Package_Access_Flag__c> pafList = packPafMap.get(subId.Main_Package_1__c);
                list<Asia1_Subscription__c> a1Sublist = new list<Asia1_Subscription__c>();
                string serviceFlags = '';
                // Start UD-3329 30Nov15 JohnD
                string asia1SubscriptionIdentifier = '';
                string asia1SubscriptionIdentifiersConcat = '';
                string subscriptionIdAsia1Id = subId.Id + '' + asia1Tmp.id;
                // End UD-3329 30Nov15 JohnD
                
                for(Package_Access_Flag__c pafTmp2 : pafList) {
                    
                    Asia1_Subscription__c asia1Subscription = new Asia1_Subscription__c();
                    asia1Subscription.Concurrent__c = pafTmp2.No_of_Concurrent_Users__c;
                    asia1Subscription.Order_Line_Item__c = subId.Order_Line_Item_Number_1__c;
                    asia1Subscription.Service_Access_Flag__c = pafTmp2.Package_Service_Access_Flag__c;
                    asia1Subscription.Asia1__c = asia1Tmp.id;
                    asia1Subscription.Subscription__c = subId.id;
                    asia1SubscriptionList.add(asia1Subscription);
                    // asia1IdSet.add(asia1Tmp.id); // Start/End UD-3329 30Nov15 JohnD - moved below
                    
                    // Start UD-3329 30Nov15 JohnD - for existing ldapId
                    asia1SubscriptionIdentifier = asia1Subscription.Subscription__c + '' + asia1Subscription.Asia1__c + '' + asia1Subscription.Service_Access_Flag__c + '' + asia1Subscription.Order_Line_Item__c + '' + asia1Subscription.Concurrent__c;
                    asia1SubscriptionIdentifier_Asia1Subscription.put(asia1SubscriptionIdentifier, asia1Subscription);
                    // End UD-3329 30Nov15 JohnD - for existing ldapId
                    
                    // username_subscriptionId.put(asia1Tmp.User_ID_LDAP_ID__c, subId.Id);  // Start/End UD-3329 30Nov15 JohnD - commented out not in use
                    
                    if (serviceFlags != '') {
                        serviceFlags += '|';
                    }
                    
                    serviceFlags += pafTmp2.Package_Service_Access_Flag__r.Name;
                    
                    // Start UD-3329 30Nov15 JohnD
                    if (asia1SubscriptionIdentifiersConcat != '') {
                        asia1SubscriptionIdentifiersConcat += '|';
                    }
                    asia1SubscriptionIdentifiersConcat += asia1SubscriptionIdentifier;
                    // End UD-3329 30Nov15 JohnD
                    // username_serviceFlags.put(asia1Tmp.User_ID_LDAP_ID__c, serviceFlags);    // Start/End UD-3329 30Nov15 JohnD - commented out not in use
                }
                // Start UD-3329 30Nov15 JohnD - added condition not to include the existing asia1 for apiSignUp call
                if (!existingLdapId_asia1.keySet().contains(asia1Tmp.User_ID_LDAP_ID__c)) {
                    asia1IdSet.add(asia1Tmp.id);
                } else {
                    
                    requestObject = new map<string, string>();
                    requestObject.put(REQUEST_FIELD_NAME_LDAP_ID, asia1Tmp.User_ID_LDAP_ID__c);
                    requestObject.put(REQUEST_FIELD_NAME_SUBSCRIPTION_ID, subId.Id);
                    requestObject.put(REQUEST_FIELD_NAME_SERVICE_FLAGS, serviceFlags);
                    requestObject.put(REQUEST_FIELD_NAME_ASIA1_SUBSCRIPTION_IDENTIFIERS, asia1SubscriptionIdentifiersConcat);
                    
                    subscriptionIdAsia1Id_requestObject.put(subscriptionIdAsia1Id, requestObject);
                }
                // End UD-3329 30Nov15 JohnD - added condition not to include the existing asia1 for apiSignUp call
            }
        }
        
        if (!asia1SubscriptionIdentifier_Asia1Subscription.isEmpty()) { // Start/End D-4157 21Dec15 JohnD
            
            try {
                
                
                insert asia1SubscriptionIdentifier_Asia1Subscription.values();  // Start/End D-4157 21Dec15 JohnD
                 
                asia1IdSet.remove(null);
                totalAsia1 = asia1IdSet.size(); // Start/End UD-3401 23Dec15 JohnD
                
                for (id asia1Id : asia1IdSet) {
                    
                    // Start UD-3401 23Dec15 JohnD
                    asia1IdSetLevel1.add(asia1Id);
                    if (batchCounter == MAX_ASIA1_LEVEL_1 || counter == totalAsia1) {
						System.enqueueJob(new BulkAsiaOneSignUpLevel1Queueable(asia1IdSetLevel1));
                        asia1IdSetLevel1 = new set<id>();
                        batchCounter = 0;
                    }
                    
                    batchCounter++;
                    counter++;
                    
                    // apiSignUp(asia1Id);  // commented out
                    // End UD-3401 23Dec15 JohnD
                    
                }
            
                // Start UD-3329 30Nov15 JohnD - added callout to only enable the serviceFlags
                // Start UD-3401 23Dec15 JohnD
                batchCounter = 1;
                counter = 1;
                totalAsia1 = subscriptionIdAsia1Id_requestObject.size();
                list<ServiceFlagActivationParamWrapper> paramList = new list<ServiceFlagActivationParamWrapper>();
                for (map<string, string> ro : subscriptionIdAsia1Id_requestObject.values()) {
                    
                    set<id> asia1SubscriptionIdSet = new set<id>();
                    for (string identifier : ro.get(REQUEST_FIELD_NAME_ASIA1_SUBSCRIPTION_IDENTIFIERS).split('\\|')) {
                        asia1SubscriptionIdSet.add(asia1SubscriptionIdentifier_Asia1Subscription.get(identifier).Id);
                    }
                    //enableServicesFuture(string username, string serviceFlag, set<id> asia1SubscriptionIdSet, id subscriptionId)
                    
                    ServiceFlagActivationParamWrapper serviceFlagParam = new ServiceFlagActivationParamWrapper();
                    serviceFlagParam.username = ro.get(REQUEST_FIELD_NAME_LDAP_ID);
                    serviceFlagParam.serviceFlag = ro.get(REQUEST_FIELD_NAME_SERVICE_FLAGS);
                    serviceFlagParam.asia1SubscriptionIdSet = asia1SubscriptionIdSet;
                    serviceFlagParam.subscriptionId = ro.get(REQUEST_FIELD_NAME_SUBSCRIPTION_ID);
                    paramList.add(serviceFlagParam);
                    
                    if (batchCounter == MAX_ASIA1_LEVEL_1 || counter == totalAsia1) {
						System.enqueueJob(new BulkServiceFlagActivationLevel1Queueable(paramList));
                        paramList = new list<ServiceFlagActivationParamWrapper>();
                        batchCounter = 0;
                    }
                    
                    batchCounter++; 
                    counter++;
                    
                    //AsiaOneServicesController.enableServicesFuture(ro.get(REQUEST_FIELD_NAME_LDAP_ID), ro.get(REQUEST_FIELD_NAME_SERVICE_FLAGS), asia1SubscriptionIdSet, ro.get(REQUEST_FIELD_NAME_SUBSCRIPTION_ID));
                }
                // End UD-3401 23Dec15 JohnD
                // End UD-3329 30Nov15 JohnD - added callout to only enable the serviceFlags
            } catch (exception e) {
                ExceptionLogger.log(new list<exception>{ e });
            }
        }       
    }
    
    // Start PD-0236 Bea Rillorta: Add testVisible to manually call in the test class
    @future (callout=true)
    @TestVisible private static void apiSignUp(id asia1IdParam) {
    // End PD-0236 Bea Rillorta: Add testVisible to manually call in the test class
        string serviceFlags = '';
        Map<String, String> sReqVO = new Map<String, String>();
        string status;
        string error;
        
        list<Asia1_Subscription__c> asia1SubscriptionList = [select Id, Asia1__r.User_ID_LDAP_ID__c, Asia1__r.Password__c, Asia1__r.Display_Name__c,  
                Asia1__r.Email__c, Service_Access_Flag__r.Name, Subscription__r.Recipient_Contact__r.Firstname, Subscription__r.Recipient_Contact__r.LastName, 
                Subscription__r.Recipient_Contact__r.Mobile_Number__c, Subscription__r.Recipient_Contact__r.HomePhone__c, 
                Subscription__r.Recipient_Contact__r.Office_Number__c from Asia1_Subscription__c 
                where Asia1__c = :asia1IdParam];

        for (Asia1_Subscription__c asia1Subscription : asia1SubscriptionList) {
                    
            if (serviceFlags != '') {
                serviceFlags += '|';
            }
            
            serviceFlags += asia1Subscription.Service_Access_Flag__r.Name;
        }
       
        if (!asia1SubscriptionList.isEmpty()) {

            sReqVO.put(GlobalVariableClass.USERNAME, refineData(asia1SubscriptionList[0].Asia1__r.User_ID_LDAP_ID__c));
            sReqVO.put(GlobalVariableClass.PASSWORD, refineData(asia1SubscriptionList[0].Asia1__r.Password__c));
            sReqVO.put(GlobalVariableClass.IP, BulkAsiaOneConfigParams__c.getInstance('AsiaOne').ip__c);
            sReqVO.put(GlobalVariableClass.PASS_CHALLENGE, BulkAsiaOneConfigParams__c.getInstance('AsiaOne').passwordChallenge__c.replace(' ','+'));
            sReqVO.put(GlobalVariableClass.PASS_RESPONSE, BulkAsiaOneConfigParams__c.getInstance('AsiaOne').passwordResponse__c.replace(' ','+'));
            sReqVO.put(GlobalVariableClass.DISPLAY_NAME, refineData(asia1SubscriptionList[0].Asia1__r.Display_Name__c));
            sReqVO.put(GlobalVariableClass.FNAME, refineData(asia1SubscriptionList[0].Subscription__r.Recipient_Contact__r.FirstName));
            sReqVO.put(GlobalVariableClass.LNAME, refineData(asia1SubscriptionList[0].Subscription__r.Recipient_Contact__r.LastName));
            sReqVO.put(GlobalVariableClass.EMAIL, asia1SubscriptionList[0].Asia1__r.Email__c);
            sReqVO.put(GlobalVariableClass.SVC, serviceFlags);
            sReqVO.put(GlobalVariableClass.ENABLE, 'no');   // Start/End UD-3330 01Nov15 JohnD
            if(asia1SubscriptionList[0].Subscription__r.Recipient_Contact__r.Mobile_Number__c != null){
                sReqVO.put(GlobalVariableClass.PHONE, refineData(asia1SubscriptionList[0].Subscription__r.Recipient_Contact__r.Mobile_Number__c));
            }else if(asia1SubscriptionList[0].Subscription__r.Recipient_Contact__r.HomePhone__c != null){
                sReqVO.put(GlobalVariableClass.PHONE, refineData(asia1SubscriptionList[0].Subscription__r.Recipient_Contact__r.HomePhone__c));
            }else if(asia1SubscriptionList[0].Subscription__r.Recipient_Contact__r.Office_Number__c != null){
                sReqVO.put(GlobalVariableClass.PHONE, refineData(asia1SubscriptionList[0].Subscription__r.Recipient_Contact__r.Office_Number__c));
            }else{
                sReqVO.put(GlobalVariableClass.PHONE,'1234567890');
            }
            
            
            AsiaOneServiceResponsetVO resp = asiaOneServiceCall(sReqVO, 'apiSignUp');
            String responseString = (String)resp.getReqValueObject().get('Sign-Up');
            
            if(responseString == 'Success'){
                status = 'Enabled';
            }else{
                status = 'Service Activation Error';
                error = (string)resp.getReqValueObject().get('Errors');
            }
            
            for (Asia1_Subscription__c asia1Subscription : asia1SubscriptionList) {
                asia1Subscription.Status__c = status;
                asia1Subscription.Reason_for_Failure__c = error;
            }
            
            update asia1SubscriptionList;
        }
    }
    
    
    private static AsiaOneServiceResponsetVO asiaOneServiceCall(Map<String, String> sReqVO, String asiaOneAPI){
        AsiaOneFacade a1F = new AsiaOneFacade();
        AsiaOneServiceRequestVO serviceRequestVO = new AsiaOneServiceRequestVO();
        serviceRequestVO.setReqValueObject(sReqVO);
        serviceRequestVO.setasia1APIFunction(asiaOneAPI);
        return a1F.delegateAsiaOneCall(serviceRequestVO);
    }
    
    
    private static string refineData(string stringParam) {
        
        string refineStr;
        
        if (stringParam != null) {
            refineStr = stringParam.replace(' ', '+');
        }
        
        return refineStr;
    }
    
    // Start UD-3305 25Nov15 JohnD
    /*
     * @description : this method is to verify the new records to be created.
     */
    private void verify(list<BT_CO_ASIAONE_BulkIdCreation__c> recordList) {
        
        map<string, integer> subscriptionName_numberOfCopies = new map<string, integer>();
        map<string, integer> subscriptionName_numberOfEntries = new map<string, integer>();
        map<string, boolean> ldapId_isDuplicate = new map<string, boolean>();
        // Start UD-3363 05Dec15 JohnD
        map<string, boolean> displayName_isDuplicate = new map<string, boolean>();
        map<string, set<string>> ldapId_subscriptionNameSet = new map<string, set<string>>();
        set<string> subscriptionNameSet;
        // End UD-3363 05Dec15 JohnD
        
        // Start UD-3401 06Jan16 JohnD
        map<string, string> ldapId_displayName = new map<string, string>();
        map<string, string> displayName_ldapId = new map<string, string>();
        map<string, boolean> ldapId_multipleDisplayName = new map<string, boolean>();
        map<string, boolean> displayName_multipleLdapId = new map<string, boolean>();
        // End UD-3401 06Jan16 JohnD
        
        // Start UD-3329 30Nov15 JohnD
        map<string, id> newLdapId_accountId = new map<string, id>();
        map<string, set<string>> subscriptionName_ldapIdSet = new map<string, set<string>>();
        set<string> existingSubscriptionNameSet = new set<string>();
        set<string> ldapIdSet;
        // End UD-3329 30Nov15 JohnD
        integer entry;
        // Start UD-3401 29Dec15 JohnD
        set<string> subscriptionNameLdapIdSet = new set<string>();  
        string subscriptionNameLdapId;
        // End UD-3401 29Dec15 JohnD
        // start retrieve current entries
        for (BT_CO_ASIAONE_BulkIdCreation__c tempRec : recordList) {
            
            // Start UD-3363 05Dec15 JohnD
            if (tempRec.User_ID_LDAP_ID__c == null) {
                tempRec.User_ID_LDAP_ID__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
                continue;
            }
            // End UD-3363 05Dec15 JohnD
            
            // Start UD-3401 06Jan16 JohnD
            if (tempRec.Display_Name__c == null) {
                tempRec.Display_Name__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
                continue;
            }
            // End UD-3401 06Jan16 JohnD
            
            entry = 0;
            
            if (subscriptionName_numberOfEntries.get(tempRec.subscription__c) != null) {
                entry = subscriptionName_numberOfEntries.get(tempRec.subscription__c);
            }
            
            entry++;
            subscriptionName_numberOfEntries.put(tempRec.subscription__c, entry);
            
            // Start UD-3329 30Nov15 JohnD
            ldapIdSet = new set<string>();
            
            if (subscriptionName_ldapIdSet.get(tempRec.subscription__c) != null) {
                ldapIdSet = subscriptionName_ldapIdSet.get(tempRec.subscription__c);
            }
            
            ldapIdSet.add(tempRec.User_ID_LDAP_ID__c);
            subscriptionName_ldapIdSet.put(tempRec.subscription__c, ldapIdSet); 
            // End UD-3329 30Nov15 JohnD
            
            // Start UD-3401 06Jan16 JohnD
            // start verify ldapid with different display names
            if (ldapId_displayName.get(tempRec.User_ID_LDAP_ID__c) != null) {
                if (ldapId_displayName.get(tempRec.User_ID_LDAP_ID__c) != tempRec.Display_Name__c) {
                    ldapId_multipleDisplayName.put(tempRec.User_ID_LDAP_ID__c, true);
                }
            } else {
                ldapId_displayName.put(tempRec.User_ID_LDAP_ID__c, tempRec.Display_Name__c);
                ldapId_multipleDisplayName.put(tempRec.User_ID_LDAP_ID__c, false);
            }
            // end verify ldapid with different display names
            // start verify display name with different ldapids
            if (displayName_ldapId.get(tempRec.Display_Name__c) != null) {
                if (displayName_ldapId.get(tempRec.Display_Name__c) != tempRec.User_ID_LDAP_ID__c) {
                    displayName_multipleLdapId.put(tempRec.Display_Name__c, true);
                }
            } else {
                displayName_ldapId.put(tempRec.Display_Name__c, tempRec.User_ID_LDAP_ID__c);
                displayName_multipleLdapId.put(tempRec.Display_Name__c, false);
            }
            // end verify display name with different ldapids
            // End UD-3401 06Jan16 JohnD
            
            // Start UD-3401 06Jan16 JohnD - commented out
            /*
            // start prevent duplicate entry
            if (ldapId_isDuplicate.get(tempRec.User_ID_LDAP_ID__c) == null) {
                ldapId_isDuplicate.put(tempRec.User_ID_LDAP_ID__c, false);
            } else {
                ldapId_isDuplicate.put(tempRec.User_ID_LDAP_ID__c, true);
            }
            
            // Start UD-3363 05Dec15 JohnD
            if (displayName_isDuplicate.get(tempRec.Display_Name__c) == null) {
                displayName_isDuplicate.put(tempRec.Display_Name__c, false);
            } else {
                displayName_isDuplicate.put(tempRec.Display_Name__c, true);
            }
            // End UD-3363 05Dec15 JohnD
            // end prevent duplicate entry
            */
            // End UD-3401 06Jan16 JohnD - commented out
        }
        // end  retrieve current entries
        
        // Start UD-3329 30Nov15 JohnD - retrieve ldap and account for new records
        // Start UD-3401 23Dec15 JohnD - added logic 
        for (Zuora__Subscription__c sub : [select Name, Zuora__Account__c from Zuora__Subscription__c 
                where Name in :subscriptionName_ldapIdSet.keySet() and Zuora__Status__c = 'Active' 
                and Subscription_Type_1__c = 'Publication' and Order_Line_Item_Number_1__r.Is_Digital__c = true]) { 
            
            for (string ldapId : subscriptionName_ldapIdSet.get(sub.Name)) {
                
                // Start UD-3401 11Jan16 JohnD - logic to check new ldap in different accounts
                if (newLdapId_accountId.get(ldapId) != null) {
                    if (newLdapId_accountId.get(ldapId) != sub.Zuora__Account__c) {
                        ldapId_isDuplicate.put(ldapId, true);
                    }
                } else {
                    newLdapId_accountId.put(ldapId, sub.Zuora__Account__c);
                    ldapId_isDuplicate.put(ldapId, false);
                }
                // End UD-3401 11Jan16 JohnD - logic to check new ldap in different accounts
                
            }
            
            existingSubscriptionNameSet.add(sub.Name);
        }
        // End UD-3401 23Dec15 JohnD - added logic
        // End UD-3329 30Nov15 JohnD - retrieve ldap and account for new records
        // start count existing record
        // Start UD-3401 29Dec15 JohnD - revised query by removing aggregate
        for (Asia1_Subscription__c ar : [select Asia1__r.User_ID_LDAP_ID__c, Subscription__r.Name from Asia1_Subscription__c 
                where subscription__r.Name in :subscriptionName_numberOfEntries.keySet() 
                and Status__c != 'Error Creation']) {
            
            subscriptionNameLdapId = ar.Subscription__r.Name + '' + ar.Asia1__r.User_ID_LDAP_ID__c;
            if (!subscriptionNameLdapIdSet.contains(subscriptionNameLdapId)) {

                entry = subscriptionName_numberOfEntries.get(ar.Subscription__r.Name) + 1;
                subscriptionName_numberOfEntries.put(ar.Subscription__r.Name, entry);
                subscriptionNameLdapIdSet.add(subscriptionNameLdapId);
            }
            // start prevent duplicate
            // ldapId_isDuplicate.put((string)ar.get('ldapId'), true); // Start UD-3323 28Nov15 JohnD - commented out
            // end prevent duplicate
        }
        // End UD-3401 29Dec15 JohnD - revised query by removing aggregate
        // end count existing record
        
        // Start UD-3323 28Nov15 JohnD
        // Start UD-3329 30Nov15 JohnD - added logic for existing ldap within the same account
        // start retrieive existing ldap
        // Start UD-3363 05Dec15 JohnD - added logic to check the display name and existing subscription under ldap
        for (Asia1__c a1 : [select Id, User_ID_LDAP_ID__c, Contact__r.AccountId, Display_Name__c, 
                (select Subscription__r.Name from Asia1_Subscriptions__r) from Asia1__c 
                where (User_ID_LDAP_ID__c in :ldapId_isDuplicate.keySet() or Display_Name__c in :displayName_isDuplicate.keySet()) 
                and Status__c != 'Error Creation']) {
            
            if (ldapId_isDuplicate.keySet().contains(a1.User_ID_LDAP_ID__c) 
                    && ldapId_isDuplicate.get(a1.User_ID_LDAP_ID__c) == false) {    // Start/End UD-3401 11Jan16 JohnD - added expression not to include the duplicate id
                
                if (a1.Contact__r.AccountId == newLdapId_accountId.get(a1.User_ID_LDAP_ID__c)) {
                    existingLdapId_asia1.put(a1.User_ID_LDAP_ID__c, a1);
                    ldapId_isDuplicate.put(a1.User_ID_LDAP_ID__c, false);    // Start/End D-4157 21Dec15 JohnD
                } else {
                    ldapId_isDuplicate.put(a1.User_ID_LDAP_ID__c, true);
                }
                
                subscriptionNameSet = new set<string>();
                for (Asia1_Subscription__c a1Sub : a1.Asia1_Subscriptions__r) {
                    subscriptionNameSet.add(a1Sub.Subscription__r.Name);
                }
                ldapId_subscriptionNameSet.put(a1.User_ID_LDAP_ID__c, subscriptionNameSet);
            }
            
            if (displayName_isDuplicate.keySet().contains(a1.Display_Name__c) 
                    && (ldapId_isDuplicate.get(a1.User_ID_LDAP_ID__c) == null
                    || (ldapId_isDuplicate.get(a1.User_ID_LDAP_ID__c) != null 
                    && !ldapId_isDuplicate.get(a1.User_ID_LDAP_ID__c)))) {
                        
                displayName_isDuplicate.put(a1.Display_Name__c, true);
            }
        }
        // End UD-3363 05Dec15 JohnD - added logic to check the display name
        // end retrieve existing ldap
        // End UD-3329 30Nov15 JohnD - added logic for existing ldap within the same account
        // End UD-3323 28Nov15 JohnD

        // start retrieve subscription's number of copies
        for (Zuora__Subscription__c sub : [select Name, Number_of_Copies__c from Zuora__Subscription__c 
                where Name in :subscriptionName_numberOfEntries.keySet()]) {
                    
            subscriptionName_numberOfCopies.put(sub.Name, integer.valueOf(sub.Number_of_Copies__c));        
        }
        // end retrieve subscription's number of copies
        
        // start add error if necessary
        for (BT_CO_ASIAONE_BulkIdCreation__c tempRec : recordList) {
            
            // Start UD-3329 02Dec15 JohnD - added validation
            // start check if subscription exist in the system
            if (!existingSubscriptionNameSet.contains(tempRec.subscription__c)) {
                tempRec.subscription__c.addError(ConstantsSLB.getErrorMessage('InvalidLdapSubscription'));
            }
            // end check if subscription exist in the system
            // End UD-3329 02Dec15 JohnD - added validation
            
            // start check duplicates
            // Start UD-3401 06Jan16 JohnD
            if (ldapId_multipleDisplayName.get(tempRec.User_ID_LDAP_ID__c) == true) {
                tempRec.User_ID_LDAP_ID__c.addError(ConstantsSLB.getErrorMessage('LdapIdMultipleDisplayNames'));
            }
            
            if (displayName_multipleLdapId.get(tempRec.Display_Name__c) == true) {
                tempRec.Display_Name__c.addError(ConstantsSLB.getErrorMessage('DisplayNameMultipleLdapIds'));
            }
            // End UD-3401 06Jan16 JohnD
            
            
            if (ldapId_isDuplicate.get(tempRec.User_ID_LDAP_ID__c) == true) {
                tempRec.User_ID_LDAP_ID__c.addError(ConstantsSLB.getErrorMessage('DuplicateLdapId'));
            }
            
            // Start UD-3363 05Dec15 JohnD - added checking for duplicate display name
            if (!existingLdapId_asia1.keySet().contains(tempRec.User_ID_LDAP_ID__c) && displayName_isDuplicate.get(tempRec.Display_Name__c) == true) {
                tempRec.Display_Name__c.addError(ConstantsSLB.getErrorMessage('DuplicateAsia1DisplayName'));
            }
            
            // start check if subscription already existing under the ldapid
            subscriptionNameSet = ldapId_subscriptionNameSet.get(tempRec.User_ID_LDAP_ID__c);
            if (subscriptionNameSet != null && !subscriptionNameSet.isEmpty() && subscriptionNameSet.contains(tempRec.subscription__c)) {
                tempRec.Subscription__c.addError(ConstantsSLB.getErrorMessage('DuplicateAsia1Subscription'));
            }
            // end check if subscription already existing under the ldapid
            // End UD-3363 05Dec15 JohnD - added checking for duplicate display name
            // end check duplicates

            // start check subscription's number of copies against total number of asia1 to associated to the subscription
            if (subscriptionName_numberOfEntries.get(tempRec.subscription__c) > subscriptionName_numberOfCopies.get(tempRec.subscription__c)) {
                tempRec.Subscription__c.addError(ConstantsSLB.getErrorMessage('Asia1vsQuantity'));
            }
            // end check subscription's number of copies against total number of asia1 to associated to the subscription
            
            
        }
        // end add error if necessary
    }
    // End UD-3305 25Nov15 JohnD
}