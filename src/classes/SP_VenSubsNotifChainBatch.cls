/**
 * Class Name: SP_VenSubsNotifChainBatch 
 * @author: Sherwin Puli
 * Date: 08-June-2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that send email notifications for Migrated Subscription (Vendor) (Start and Stop) and Normal Expiry Scenario
 */
global class SP_VenSubsNotifChainBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {

    list<exception> exceptionList = new list<exception>(); // declare this at the outermost within your class
    
    Static Integer Mon;
    Static Integer Tue;
    Static Integer Wed;
    Static Integer Thu;
    Static Integer Fri;
    Static Integer Sat;
    Static Integer Sun;
    Static Integer PHd;
    Static Integer PHe;
    Static String frequencyDay;
    Static String frequencyDigit;
    
    //Prepare the cutoff dates
    public Date dtEffStart = Date.today();        
    public Date dtEffEnd = dtEffStart.addDays(1);
    
    global final String sessionId;
    global static String vendorRepRoleId = Key_Id__c.getInstance('Vendor Rep Role').Id__c;
    
    public static Task task;
    public static Set<String> venStaffid = new Set<String>();   
    public static Map<Id, User> vendorStaffId_partnerUser = new Map<Id, User>();
    public static SMS_Outbound__c bound;

    public static String venMobileNumber;
    public static set<String> venStaffMobileNumberList = new set<String>();

     Map<Id, Address__c> addressMapForStart = new Map<Id, Address__c>();

    global Map<string, MailSMSWrapper> mapConcatenated = new Map<string, MailSMSWrapper>();
    global Map<Id, Id> mailRemarks_Map = new Map<Id, Id>();
    global Set<Id> failedRecIds = new Set<Id>();
    global Boolean isAdhoc = false;
    
    List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerListChain;

    public SP_VenSubsNotifChainBatch(List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList){
        this.batchJobSchedulerListChain = batchJobSchedulerList;
    }
    public SP_VenSubsNotifChainBatch(Set<Id> subVenIds)
    {
        if(subVenIds <> null){
            this.failedRecIds = subVenIds;
            this.isAdhoc = true;
        }
    }
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String vendor = GlobalVariableClass.VENDOR;
  
        String query = '';
        query += ' SELECT Id,Subscription_Stop_Date__c,Subscription_Start_Date__c, Vendor__c,Recipient__c';
        query += ' FROM Subscription_Vendor__c';
        query += ' WHERE Vendor__r.RecordType.Name = :vendor';
        query += ' AND';
        query += ' (Subscription_Start_Date__c = :dtEffEnd';
        query += ' OR Subscription_Stop_Date__c = :dtEffEnd)';
        
        if(isAdhoc){
            query += ' AND Id IN:failedRecIds';
        }     
        if (Test.isRunningTest()) {
            query += ' Limit 200';
        }
      
        return Database.getQueryLocator(query);    
    }

    global void execute(Database.BatchableContext BC, List<Subscription_Vendor__c> initialSubsVen) {
        
        String CASE_STATUS_CLOSED = 'Closed';
        String START_SUBSCRIPTION = 'Start_Subscription';
        String CHANGE_OF_SUBSCRIPTION = 'Change_of_Subscription';
        String RENEWAL_OF_SUBSCRIPTION = 'Renewal_of_Subscription';
        String STOP_SUBSCRIPTION = 'Stop_Subscription';  
        String Z_SUBSCRIPTION_TYPE_PUB = 'PUBLICATION';
        
        try{
            List<Subscription_Vendor__c> scope = new List<Subscription_Vendor__c>();
            Set<Id> initSubVenIds = new Set<Id>();
            Set<ID> validSubVens = new Set<Id>();
            if(!initialSubsVen.isEmpty()){
                for(Subscription_Vendor__c svInit : initialSubsVen){
                    initSubVenIds.add(svInit.Id);
                }
            }
            
            List<Case_Vendor_Subscription__c> caseVenSubToFilter = new List<Case_Vendor_Subscription__c>();
            Set<ID> subVenToFilter = new Set<ID>();
            if(!initSubVenIds.isEmpty()){
                caseVenSubToFilter = [SELECT Case__c,Subscription_Vendor__c FROM Case_Vendor_Subscription__c WHERE 
                Subscription_Vendor__c IN :initialSubsVen AND ((
                Case__r.RecordType.DeveloperName = :START_SUBSCRIPTION
                AND Subscription_Vendor__r.Subscription_Start_Date__c = :dtEffEnd)
                OR (Case__r.RecordType.DeveloperName = :STOP_SUBSCRIPTION 
                AND Subscription_Vendor__r.Subscription_Stop_Date__c = :dtEffEnd)
                )];
                
                if(!caseVenSubToFilter.isEmpty()){
                    for(Case_Vendor_Subscription__c cvsInit : caseVenSubToFilter){
                        if(cvsInit.Subscription_Vendor__c <> null){
                            subVenToFilter.add(cvsInit.Subscription_Vendor__c);
                        }
                    }
                }
            }
            
            if(!initialSubsVen.isEmpty()){
                for(Subscription_Vendor__c svInit : initialSubsVen){
                    if(!subVenToFilter.isEmpty()){
                        if(!subVenToFilter.contains(svInit.Id)){
                            scope.add(svInit);
                            validSubVens.add(svInit.Id);
                        }
                    }else{
                        scope.add(svInit);
                        validSubVens.add(svInit.Id);
                    }
                }
            }
            
            Boolean isSendEmail = false;
                    
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> subscriptionVendorIdSet = new Set<Id>();
            Set<Id> subscriptionVendorTempStopIdSet = new Set<Id>();
            Set<Id> addressIdSet = new Set<Id>();
            Set<Id> singpostAddressIdSet = new Set<Id>();
            set<string> pubCode = new set<string>();
            Set<Id> vendorAccountIdSet = new Set<Id>(); 
            
            List<Subscription_Vendor__c> subscriptionVendorList = new List<Subscription_Vendor__c>();
            List<String> toAddresses = new List<String>();

            List<Contact> vendorStaffList = new List<Contact>();
            List<Account> vendorAccountList = new List<Account>();
            List<Address__c> addressList = new List<Address__c>();
            List<Singpost_Address__c> singpostAddressList = new List<Singpost_Address__c>();
            List <Subscription_Vendor_Publication__c> svPub = new List <Subscription_Vendor_Publication__c>();
            List<Contact> vendorStaffsList = new List<Contact>();
            
            Map <String , Publication__c> publicationMap = new Map<String, Publication__c>(); 
            Map <Id, List<Case_Vendor_Subscription__c>> mapCaseToCaseVendorSubscription = new Map<Id, List<Case_Vendor_Subscription__c>>();
            Map <Id, Case> mapSubscriptionVendorToCase  = new Map<Id, Case>();
            Map <Id, List<Case>> mapSubscriptionVendorToCaseList  = new Map<Id, List<Case>>(); 
            Map <Id, Id> vendorStaffContactIdMAP = new Map <Id, Id>();
            Map <Id, Contact> contactVendorStaff = new Map <Id, Contact>();
            Map <Id, List<Contact>> accountVendorToVendorStaff = new  Map <Id, List<Contact>>();
            Map <Id, String> conId_AliasMap = new Map<Id, String>();
            Map <Id, List<Contact>> account_VendorStaffMap = new Map<Id, List<Contact>>();
            Map <Id, Contact> contactMap = new Map<Id, Contact>();
            Map <Id, Address__c> addressMap = new Map<Id, Address__c>();
            Map <Id, Singpost_Address__c> singpostAddressMap = new Map<Id,Singpost_Address__c>();
            Map <string, string> details = new  Map <string, string>();
            Map <string, Subscription_Vendor_Publication__c> pubCodeToDailyMap = new Map <string, Subscription_Vendor_Publication__c>(); 
            Map<Id,Subscription_Vendor__c> subscriptionvenMap = new Map<Id,Subscription_Vendor__c>();
            Map<Id, List<String>> caseToAddressVendorMap = new Map<Id, List<String>>();
            String issueDate;
            String transactionName; 
            String partialTemplate;
            String classification;

            String vendorStaffRecTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
            
            Boolean sendMail;
            Integer myCounter;                                                       
            Contact currentContact = new Contact(); 
            Address__c addressObj = new Address__c(); 
            Singpost_Address__c singpostAddressObj = new Singpost_Address__c();
            Subscription_Vendor__c subven = new Subscription_Vendor__c();
            
            Map<Id, Set<Id>> startCasesToSubs_Map = new Map<Id, Set<Id>>();
            List <Publication__c> pubList = [Select Publication_Code__c, Sunday_Publication__r.Publication_Code__c 
                                              FROM Publication__c];
           

            For (Publication__c pub :pubList) {
                if (pub.Sunday_Publication__c <> null ) {
                    publicationMap.put (pub.Publication_Code__c, pub); 
                }
            }
            
            Set<Id> vendorIdCoaSet = new Set<Id>();
            Set<Id> vendorIdCovSet = new Set<Id>();
            Map<Id, String> aliasCOAMap = new Map<Id, String>();
            List<Contact> vendorStaffCoaList = new List<Contact>();
            List<Contact> vendorStaffCOVendorList = new List<Contact>();
            List<Address_Assignment__c> addressAssignmentList = new List<Address_Assignment__c>();
            Map<Id, List<Contact>> vendorIdVendorStaffCoaListMap = new Map<Id, List<Contact>>();
            Map<Id, List<Contact>> vendorIdVendorStaffCOAVendorListMap = new Map<Id, List<Contact>>();
            Map<Id, List<Address_Assignment__c>> caseIdAddressAssignListMap = new Map<Id, List<Address_Assignment__c>>();

            Map<Id, Id> caseIdToVendor_MAP = new Map<Id, Id>();
            Map <id, id> mapVendorToStaff_MAP = new Map <id, id>();
            Map<Id, String> userIdToAlias_MAP = new Map<Id, String>();

            Map<Id, String> caseIdToZoneName = new Map<Id, String>();
            map<id, id> venStafToVendor = new map<id, id>();
            map<id,id> vendorIdToUserId = new map<id,id>();
            if(!scope.isEmpty()){
                for(Subscription_Vendor__c svRec : scope){
                    vendorAccountIdSet.add(svRec.Vendor__c);
                    contactIdSet.add(svRec.Recipient__c);
                    
                    if(svRec.Subscription_Start_Date__c == dtEffEnd){
                        subscriptionVendorIdSet.add(svRec.Id);
                    }
                    
                    if(svRec.Subscription_Stop_Date__c == dtEffEnd){
                        subscriptionVendorIdSet.add(svRec.Id);
                    }
                }
            }
            
            if(vendorAccountIdSet.size()>0){
                vendorStaffsList = [SELECT id, name, Email, HomePhone__c, Vendor_Communication_Preference__c, Active__c, AccountId FROM Contact 
                WHERE AccountId IN: vendorAccountIdSet And Active__c = true AND RecordType.Name = :GlobalVariableClass.VENDOR_STAFF];
                if(!vendorStaffsList.isEmpty()){
                    venStaffMobileNumberList = new Set<String>(); 
                    for(Contact venCon:vendorStaffsList){                           
                        venStafToVendor.put(venCon.id, venCon.accountId);
                        if(venCon.Email != null){    
                            if(toAddresses.size() < 100){
                                toAddresses.add(venCon.Email);                                                                  
                            }
                        }                   
                    }
                }
            

             
                if(!vendorStaffsList.isEmpty()){
                    for(Contact c : vendorStaffsList){
                        contactVendorStaff.put (c.Id, c);
                        
                        List<Contact> vendorStaffTempList = account_VendorStaffMap.get(c.AccountId);
                        if(vendorStaffTempList == null){
                            vendorStaffTempList = new List<Contact>();
                        }
                        vendorStaffTempList.add(c);
                        account_VendorStaffMap.put(c.AccountId,vendorStaffTempList);
                    }
                }
                
                List<User> userList = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User 
                Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE 
                AND ContactId IN :contactVendorStaff.keyset() and isActive=true Order by Createddate asc];
            
                if(userList <> null && userList.size() > 0){
                    for(User u : userList){
                        vendorIdToUserId.put(venStafToVendor.get(u.ContactId), u.Id);
                        vendorStaffId_partnerUser.put(u.ContactId,u);
                    }
                }

            }
            //Get contacts
            contactMap = new Map<Id, Contact>();
            if(!contactIdSet.isEmpty()){
                contactMap =  new Map<Id, Contact>([SELECT Id, FirstName, LastName, Address__r.Id, Salutation FROM Contact WHERE Id IN: contactIdSet]);
                for(Contact c : contactMap.values()){
                    addressIdSet.add(c.Address__r.Id);
                }
            }
            
            //Get Addresses based on Contacts
            addressList = new List<Address__c>();
            singpostAddressMap = new Map<ID, Singpost_Address__c>();
            if(!addressIdSet.isEmpty()){
                addressList = [SELECT Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id 
                FROM Address__c WHERE Id IN: addressIdSet];          
                for(Address__c address : addressList){
                    addressMap.put(address.Id, address);
                    if(address.Postal_Code__c <> null){
                        singpostAddressIdSet.add(address.Postal_Code__r.Id);
                    }
                }
                if(!singpostAddressIdSet.isEmpty()){
                    singpostAddressMap = new Map<ID, Singpost_Address__c>([SELECT Id, Name FROM Singpost_Address__c WHERE Id IN: singpostAddressIdSet]);
                }
            }
            
            Map<Id, List<Subscription_Vendor_Publication__c>> subTosubVenPub = new Map<Id, List<Subscription_Vendor_Publication__c>>();
            List<Subscription_Vendor_Publication__c> subVenPub_LIST = new List<Subscription_Vendor_Publication__c>();
            Map<Id, String> subIdToZoneName = new Map<Id, String>();
            Map<String, String> zoneNameToAlias = new Map<String, String>();
            List<Post_Sector_Ops_Rep_Mapping__c> postSectorMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
            
            if (!subscriptionVendorIdSet.isEmpty()) {
                subscriptionVendorList = [select id, Name, Subscription_Start_Date__c, Vendor__r.RecordType.Name, 
                Vendor__r.Vendor_Communication_Preference__c, Subscription_Stop_Date__c, Vendor__c, Vendor__r.email__c, 
                Vendor__r.Active__c, Order_Number__r.Vendor_Sms_Remarks__c, Recipient__c, Recipient__r.Address__c,
                Recipient__r.Address__r.Postal_Code__r.Name, Vendor__r.Handphone_Number__c,(select id, Publication__r.Publication_Code__c, 
                Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c, Subscription_Vendor__c from Subscription_Vendor_Publications__r) 
                from Subscription_Vendor__c where id in :subscriptionVendorIdSet AND Vendor__r.RecordType.Name = :GlobalVariableClass.VENDOR];
            
                if(subscriptionVendorList.size() > 0){
                    for(Subscription_Vendor__c subsVenToZone : subscriptionVendorList){
                        if(subsVenToZone.Recipient__c <> null){
                            if(subsVenToZone.Recipient__r.Address__c <> null){
                                if(subsVenToZone.Recipient__r.Address__r.Postal_Code__c <> null){
                                    if(subsVenToZone.Recipient__r.Address__r.Postal_Code__r.Name.length() > 2){
                                        subIdToZoneName.put(subsVenToZone.Id, subsVenToZone.Recipient__r.Address__r.Postal_Code__r.Name.subString(0,2));
                                    }
                                }
                            }
                        }
                    }
                }
                postSectorMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
                conId_AliasMap = new Map<Id, String>();
                if(subIdToZoneName.size()>0){
                    postSectorMapping_List = [Select Id, Zone__r.Name, Vendor_Ops__c, Vendor_Ops__r.Alias, Vendor_Ops__r.IsActive 
                    From Post_Sector_Ops_Rep_Mapping__c Where Zone__r.Name In :subIdToZoneName.values() AND Vendor_Ops__c <> null 
                    AND Vendor_Ops__r.IsActive = true];
                    if(postSectorMapping_List.size()>0){
                        for(Post_Sector_Ops_Rep_Mapping__c postRec : postSectorMapping_List){
                            for(Id subId : subIdToZoneName.keySet()){
                                if(subIdToZoneName.get(subId) == postRec.Zone__r.Name){
                                    if(postRec.Vendor_Ops__c <> null){
                                        conId_AliasMap.put(subId, postRec.Vendor_Ops__r.Alias);
                                    }
                                }
                            }
                        }
                    }
                }
                
                //Start Sub
                subVenPub_LIST = [SELECT Subscription_Vendor__c, Subscription_Vendor__r.Subscription_Start_Date__c, Publication__c 
                FROM Subscription_Vendor_Publication__c WHERE Subscription_Vendor__c IN :subscriptionVendorIdSet 
                AND Subscription_Vendor__r.Subscription_Start_Date__c = Tomorrow];
                
                if(subVenPub_LIST.size()>0){
                    for(Subscription_Vendor_Publication__c subVenPubs : subVenPub_LIST){
                        if(!subTosubVenPub.containsKey(subVenPubs.Subscription_Vendor__c)){
                            subTosubVenPub.put(subVenPubs.Subscription_Vendor__c, new List<Subscription_Vendor_Publication__c>{subVenPubs});
                        }
                        else{
                            subTosubVenPub.get(subVenPubs.Subscription_Vendor__c).add(subVenPubs);
                        }
                    }
                }
            
            }
            if(!subscriptionVendorList.isEmpty()){
                for (Subscription_Vendor__c subsVendor : subscriptionVendorList) {
                    svPub = subsVendor.Subscription_Vendor_Publications__r;
                    if (svPub != null) {
                        pubCode = new set<string>();
                        Mon=0;Tue=0;Wed=0;Thu=0;Fri=0;Sat=0;Sun=0;PHd=0;PHe=0;
                        frequencyDay  = '';
                        frequencyDigit = '';
                        for(Subscription_Vendor_Publication__c svp: svPub){
                            if (svp.Publication__c != null) {
                                    pubCode.add(svp.Publication__r.Publication_Code__c);
                                rollUpDays(svp);
                            }  
                        }
                        ArrangeFrequency();
                        details.clear();
                        for (string eachPubCode: pubCode) {
                            Publication__c pub = new Publication__c();
                            pub = publicationMap.get(eachPubCode);
                            
                            if (publicationMap.containskey(eachPubCode)) {
                                if (details.containskey(pub.Sunday_Publication__r.Publication_Code__c)) {
                                    partialTemplate = string.valueOf(eachPubCode) + '/' + partialTemplate;
                                    details.put(pub.Sunday_Publication__r.Publication_Code__c, partialTemplate);
                                }
                                else {
                                    partialTemplate = '';
                                    if(Sun > 0){
                                        partialTemplate = string.valueOf(eachPubCode) + '/' + pub.Sunday_Publication__r.Publication_Code__c;
                                    } else {
                                        partialTemplate = string.valueOf(eachPubCode);
                                    }
                                    if(subsVendor != null){
                                        partialTemplate += ' (' + frequencyDay + ' > ' + frequencyDigit + ')'; 
                                    }
                                    details.put(pub.Sunday_Publication__r.Publication_Code__c, partialTemplate);
                                }
                            }
                            else { // if pub code has no look up publication
                                if (!details.containskey(eachPubCode)) {
                                    partialTemplate = '';
                                    partialTemplate = string.valueOf(eachPubCode);
                                    if(subsVendor != null){
                                        partialTemplate += ' (' + frequencyDay +  ' > ' + frequencyDigit + ')';
                                    }
                                    details.put(eachPubCode, partialTemplate );
                                }
                            }
          
                        }
                    }
                    
                    // Arranging pubcode format
                    partialTemplate  = '';
                    myCounter = 0;
                    for (String perSub : details.keyset()) {
                        myCounter += 1;
                     
                        if (details.size() == myCounter && details.size() > 1) {
                            partialTemplate += 'and ' + details.get(perSub);
                        }
                        else {
                            partialTemplate += details.get(perSub);
                        }
                    }
                    
                    venStaffid = new Set<String>();
                    toAddresses = new List<String>();
                    
                    if (subsVendor.Vendor__r.Email__c <> null) {
                        if((subsVendor.Vendor__r.Vendor_Communication_Preference__c == 'Both' 
                        || subsVendor.Vendor__r.Vendor_Communication_Preference__c == 'Email') && subsVendor.Vendor__r.Active__c){
                            toAddresses.add(subsVendor.Vendor__r.Email__c); 
                            isSendEmail = true;
                        }
                    }
                    venStaffMobileNumberList = new Set<String>();
                    
                    if (account_VendorStaffMap.containsKey(subsVendor.Vendor__c)) {                         
                        List<Contact> myContactList = new List<Contact>();
                        myContactList = account_VendorStaffMap.get(subsVendor.Vendor__c);
                        for (Contact myContact :myContactList ) {
                            if(myContact.Active__c){
                                venStaffid.add(myContact.Id);
                            
                                if (myContact.email != null ) {
                                    if((myContact.Vendor_Communication_Preference__c == 'Both' || myContact.Vendor_Communication_Preference__c == 'Email') && myContact.Active__c){
                                        toAddresses.add(myContact.email);
                                        isSendEmail = true;
                                    } 
                                }
                                if(contactVendorStaff.containsKey(myContact.id)){
                                    if(contactVendorStaff.get(myContact.id).Vendor_Communication_Preference__c == 'SMS' || contactVendorStaff.get(myContact.id).Vendor_Communication_Preference__c == 'Both'){
                                        if(myContact.HomePhone__c != null){
                                            venStaffMobileNumberList.add(myContact.HomePhone__c);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    venMobileNumber = '';
                    if(subsVendor.Vendor__r.Handphone_Number__c != null){
                        venMobileNumber = subsVendor.Vendor__r.Handphone_Number__c;
                    }
                    currentContact = new Contact();
                    if(contactMap != null && subsVendor != null){            
                        currentContact = contactMap.get(subsVendor.Recipient__c);
                    }
                    addressObj = new Address__c();
                    if(addressMap != null && currentContact != null){
                        addressObj = addressMap.get(currentContact.Address__r.Id);
                    }
                    singpostAddressObj = new Singpost_Address__c();
                    if(singpostAddressMap != null && addressObj != null){
                        singpostAddressObj = singpostAddressMap.get(addressObj.Postal_Code__r.Id);
                    }
                    
                    transactionName = '';
                    if(subsVendor.Subscription_Stop_Date__c == dtEffEnd){
                        transactionName = GlobalVariableClass.STOP_URGENT;
                        sendMail = true;  
                        issueDate = convertDateToString(dtEffEnd);
                    }
                    
                    if(subsVendor.Subscription_Start_Date__c == dtEffEnd){
                        transactionName = GlobalVariableClass.START_NEW;
                        sendMail = true;  
                        issueDate = convertDateToString(dtEffEnd);
                    }
                    
                    classification = GlobalVariableClass.NOTIF_CLASS_VENDOR;
                    
                    if(sendMail == true){
                        Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage(); 
                        if(partialTemplate != '' && partialTemplate != null){
                            constructMail(isSendEmail, transactionName, toAddresses, subsVendor, conId_AliasMap,issueDate, partialTemplate, 
                            addressObj,singpostAddressObj, classification);
                        }
                    }
                    
                }
            }   
            
        }catch(Exception e){
            exceptionList.add(e);//error handling
        }
        
        ExceptionLogger.log(exceptionList);
    }
    
    public void constructMail(Boolean isSendEmail, String transactionNameParam, List<String> toAddressesParam, Subscription_Vendor__c subscriptionParam,
    Map<Id, String> conId_AliasMapParam, String issueDateParam, String subParam, Address__c addressObjParam,Singpost_Address__c singpostAddressObjParam, String classificationParam){
        
        string mapKey = '';
        mapKey = string.valueOf(addressObjParam.id) + string.valueOf(subscriptionParam.vendor__c) + transactionNameParam;
        
        MailSMSWrapper MWrapper = new MailSMSWrapper();
        
        MWrapper.mailisSendEmail = isSendEmail;
        MWrapper.mailtoAddress = new list<string>();
        
        MWrapper.mailtoAddress = toAddressesParam;
        
        String output = '';
        String plainTextOutput = '';
        String smsoutput = '';
        
        if(!mapConcatenated.containsKey(mapKey)){
            
            output += conId_AliasMapParam.get(subscriptionParam.Id)+' ';
            smsoutput += conId_AliasMapParam.get(subscriptionParam.Id)+' ';
            plainTextOutput += conId_AliasMapParam.get(subscriptionParam.Id)+' ';
        
        
            if(issueDateParam != null) {
                issueDateParam.replace(' 00:00:00',''); 
                output += issueDateParam+' ';
                smsoutput += issueDateParam+' ';
                plainTextOutput += issueDateParam+' ';
            }
            
            if (transactionNameParam != null && transactionNameParam != 'null') {
                output += '- ' + transactionNameParam +'&nbsp;'+'</br>';
                smsoutput += '- ' + transactionNameParam + ' ';
                plainTextOutput += '- ' + transactionNameParam + ' ';
            }
        
        }
        
        if (subParam != null && subParam != 'null') {
            output += subParam ;
            smsoutput += subParam;
            plainTextOutput += subParam;
        }
        
        if (mapConcatenated.containsKey(mapKey)) {
            // For Email
            String mapKeyValue = mapConcatenated.get(mapKey).mailBody;
            mapKeyValue = mapKeyValue + ', ' + output;
            MWrapper.mailBody = mapKeyValue;

            // For SMS
            String mapKeyValue2 = mapConcatenated.get(mapKey).SMSmessage;
            smsoutput = mapKeyValue2 + ', ' + smsoutput;
            
            // For Task
            String mapKeyValue3 = mapConcatenated.get(mapKey).Description;
            plainTextOutput = mapKeyValue3 + ', ' + plainTextOutput;
        } else {
            // For Email
            MWrapper.mailBody = output;
        }
        
        String output2 = '</br> @';
        String plainTextOutput2 = ' @';
        String smsoutput2 = ' @';
                        
        if (addressObjParam.Block_House_Number__c != null) {
            output2 += string.valueOf(addressObjParam.Block_House_Number__c)+' ';
            smsoutput2 += string.valueOf(addressObjParam.Block_House_Number__c)+' ';
            plainTextOutput2 += string.valueOf(addressObjParam.Block_House_Number__c)+' ';
        }

        if (addressObjParam.Street_Name__c != null) {
            output2 += addressObjParam.Street_Name__c+' ';
            smsoutput2 += addressObjParam.Street_Name__c+' ';
            plainTextOutput2 += addressObjParam.Street_Name__c+' ';
        }


        if (addressObjParam.Building_Name__c != null) {
            output2 += addressObjParam.Building_Name__c+' ';
            smsoutput2 += addressObjParam.Building_Name__c+' ';
            plainTextOutput2 += addressObjParam.Building_Name__c+' ';
        }

        if (addressObjParam.Level_Number__c != null) {
             output2 += '#'+string.valueOf(addressObjParam.Level_Number__c);
             smsoutput2 += '#'+string.valueOf(addressObjParam.Level_Number__c);
             plainTextOutput2 += '#'+string.valueOf(addressObjParam.Level_Number__c);
        }

        if (addressObjParam.Unit_Number__c != null) {
            output2 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';
            smsoutput2 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';
            plainTextOutput2 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';
        }
                     
        output2 += ' ' + classificationParam + ' ' ;      
        smsoutput2 += ' ' + classificationParam + ' ' ;
        plainTextOutput2 += ' ' + classificationParam + ' ' ;
        
        MWrapper.mailBodyAddress = output2;
        MWrapper.SMSmessage2 = smsoutput2;
        MWrapper.Description2 = plainTextOutput2;
             
        MWrapper.SMSMobile = new list<string>();
        
        if(!venStaffMobileNumberList.isEmpty()){
            for(String venStaffMobNum : venStaffMobileNumberList){
                if(venStaffMobNum != null){
                    MWrapper.SMSmessage = smsoutput;
                    MWrapper.SMSMobile.add(venStaffMobNum);
                }           
            }
        }
        
        if((subscriptionParam.Vendor__r.Vendor_Communication_Preference__c == 'Both' || subscriptionParam.Vendor__r.Vendor_Communication_Preference__c == 'SMS') && subscriptionParam.Vendor__r.Active__c){   
            if(venMobileNumber != null){
                MWrapper.SMSmessage = smsoutput;
                MWrapper.SMSMobile.add(venMobileNumber);
            }
        }
        
        MWrapper.WhoId = new list<id>();
        
        if(!venStaffid.isEmpty()){
            for(String venStaff : venStaffid){
                if(vendorStaffId_partnerUser.containsKey(venStaff)){
                    MWrapper.OwnerId = vendorStaffId_partnerUser.get(venStaff).Id;
                    MWrapper.WhoId.add(venStaff);
                    MWrapper.Description = plainTextOutput;
                    String taskSub = '';
                    if(subscriptionParam.Subscription_Start_Date__c == dtEffEnd){
                        taskSub = GlobalVariableClass.SUBJECT_START_SUBSCRIPTION;
                    }else if(subscriptionParam.Subscription_Stop_Date__c == dtEffEnd){
                        taskSub = GlobalVariableClass.SUBJECT_STOP_SUBSCRIPTION;
                    }
                    MWrapper.subject = 'Notification (' + taskSub + ')';
                }
                
            }
        }
        mapConcatenated.put(mapKey, MWrapper);
    } 
     
    public static void ArrangeFrequency () {
     
         boolean daily;
         daily=true;
         if (Mon <> 0) {
             frequencyDay = 'Mon/';
             daily= true;
         }
         else {daily= false;}
         if (Tue <> 0) {
             frequencyDay += 'Tue/';
         }
         else {daily= false;}
         if (Wed <> 0) {
             frequencyDay += 'Wed/';
         }
         else {daily= false;}
         if (Thu <> 0) {
             frequencyDay += 'Thu/';
         }
         else {daily= false;}
         if (Fri <> 0) {
             frequencyDay += 'Fri/';
         }
         else {daily= false;}
         if (Sat <> 0) {
             frequencyDay += 'Sat/';
         }
         else {daily= false;}
         if (Sun <> 0) {
             frequencyDay += 'Sun/';
         }
         else {daily= false;}
         if (daily) {
             frequencyDay = 'Daily';
         }
         else{
             frequencyDay = frequencyDay.left(frequencyDay.length() -1);
         }
         
         frequencyDigit = string.valueOf(Mon) + string.valueOf(Tue) + string.valueOf(Wed) + string.valueOf(Thu) + string.valueOf(Fri) + 
                  string.valueOf(Sat) + string.valueOf(Sun) + string.valueOf(PHd) + string.valueOf(PHe);      
     }
      
      public static void rollUpDays (Subscription_Vendor_Publication__c subVenPub) {
        
        if (subVenPub.Mon__c <> null && subVenPub.Mon__c <> 0) {
            Mon += integer.valueOf(subVenPub.Mon__c);
        }
        if (subVenPub.Tue__c <> null && subVenPub.Tue__c <> 0) {
            Tue += integer.valueOf(subVenPub.Tue__c);
        }
        if (subVenPub.Wed__c <> null && subVenPub.Wed__c <> 0) {
            Wed += integer.valueOf(subVenPub.Wed__c);
        }
        if (subVenPub.Thu__c <> null && subVenPub.Thu__c <> 0) {
            Thu += integer.valueOf(subVenPub.Thu__c);
        }
        if (subVenPub.Fri__c <> null && subVenPub.Fri__c <> 0) {
            Fri+= integer.valueOf(subVenPub.Fri__c);
        }
        if (subVenPub.Sat__c <> null && subVenPub.Sat__c <> 0) {
            Sat += integer.valueOf(subVenPub.Sat__c);
        }
        if (subVenPub.Sun__c <> null && subVenPub.Sun__c <> 0) {
            Sun+= integer.valueOf(subVenPub.Sun__c);
        }
        if (subVenPub.PHd__c <> null && subVenPub.PHd__c <> 0) {
            PHd += integer.valueOf(subVenPub.PHd__c);
        }
        if (subVenPub.PHe__c <> null && subVenPub.PHe__c <> 0) {
            PHe += integer.valueOf(subVenPub.Phe__c);
        }

    }
     
    public static String convertDateToString(Date dateValue)
    {
        Integer day = dateValue.day();
        Integer month = dateValue.month();
        Integer year= dateValue.year();
        
        String dayString;
        String monthString;
        String yearString = String.valueOf(year);
        
        if(day<10)
        {
            dayString = '0' + String.valueOf(day);
        }
        else
        {
            dayString = String.valueOf(day);
        }
        
        if(month<10)
        {
            monthString = '0' + String.valueOf(month);
        }
        else
        {
            monthString = String.valueOf(month);
        }
        
        String dateString =  dayString + '/' + monthString + '/' + yearString;
        
        return dateString;
    } 
        
    global void finish(Database.BatchableContext BC) {
        
        if(!Test.isRunningTest()){
            if(batchJobSchedulerListChain.size() > 0)
            {
                BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerListChain.get(0);
                batchJobScheduler.Status__c = 'SUCCESS';
                batchJobScheduler.End_Time__c = DateTime.now();
            
                BatchServiceFacade a1F = new BatchServiceFacade();
                BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
                serviceRequestVO.setJobStatus(0);
                serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
                serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
                a1F.delegateBatchCall(serviceRequestVO);

                update batchJobScheduler;           
         
            }  
        }
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<SMS_Outbound__c> smsOutboundList = new List<SMS_Outbound__c>();
        List<Task> taskList = new List<Task>();
        for (string keySets: mapConcatenated.keyset()) {
            
            string strMailBody = '';
            string strSMSBody = '';
            string strTaskBody = '';
            
            if (mapConcatenated.get(keySets).mailisSendEmail) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setSubject(GlobalVariableClass.EMAIL_DELIVERY_NOTIFICATION);
                mail.setToAddresses(mapConcatenated.get(keySets).mailtoAddress);
                
                if(mapConcatenated.get(keySets).mailBody <> null){
                    strMailBody = mapConcatenated.get(keySets).mailBody;
                }
                if(mapConcatenated.get(keySets).mailBodyAddress <> null){
                    strMailBody += mapConcatenated.get(keySets).mailBodyAddress;
                }
                if(mapConcatenated.get(keySets).mailBodyRemarks <> null){
                    strMailBody += mapConcatenated.get(keySets).mailBodyRemarks;
                }
                                
                mail.setHtmlBody(strMailBody);
            
                mailList.add(mail);
            }
            
            for (integer x=0; x<mapConcatenated.get(keySets).SMSMobile.size(); x++) {
                bound = new SMS_Outbound__c();
                bound.SMS_status__c = 'New';
                
                if(mapConcatenated.get(keySets).SMSmessage <> null){
                    bound.SMS_message__c = mapConcatenated.get(keySets).SMSmessage;
                }
                if(mapConcatenated.get(keySets).SMSmessage2 <> null){
                    bound.SMS_message__c += mapConcatenated.get(keySets).SMSmessage2;
                }
                if(mapConcatenated.get(keySets).SMSRemarks <> null){
                    bound.SMS_message__c += mapConcatenated.get(keySets).SMSRemarks;
                }
                
                bound.Mobile__c = mapConcatenated.get(keySets).SMSMobile[x];
                smsOutboundList.add(bound);
            }
            
            for (integer x=0; x<mapConcatenated.get(keySets).WhoId.size(); x++) {
                task = new task();
                task.OwnerId = mapConcatenated.get(keySets).OwnerId;
                //task.WhatId = mapConcatenated.get(keySets).WhatId;
                task.WhoId = mapConcatenated.get(keySets).WhoId[x];
                
                if(mapConcatenated.get(keySets).Description <> null){
                    task.Description = mapConcatenated.get(keySets).Description;
                }
                if(mapConcatenated.get(keySets).Description2 <> null){
                    task.Description += mapConcatenated.get(keySets).Description2;
                }
                if(mapConcatenated.get(keySets).DescriptionRemarks <> null){
                    task.Description += mapConcatenated.get(keySets).DescriptionRemarks;
                }
                
                task.ActivityDate = Date.today();
                task.subject = mapConcatenated.get(keySets).subject;
                task.Status = 'Open';
                taskList.add(task);
            }
        }
        //Start UD-3457 26-Jan-2016 Added By S.Puli 
        //Messaging.sendEmail(mailList, false);
        boolean isError = false;
        Logger logger = new Logger(SP_VendorSubscriptionNotificationsBatch.class.getName(), 'SP044', BC.getJobID());
        Messaging.SendEmailResult[] mailResult = Messaging.sendEmail(mailList, false);
        for(Integer counter = 0; counter < mailResult.size(); counter++){
            String emailFailure = '';
            if (!mailResult[counter].isSuccess() ) {
                for(Messaging.SendEmailError emailError : mailResult[counter].getErrors()){
                    emailFailure += '* ' + emailError.getMessage() + '\n';
                }
                
                logger.log(true, emailFailure);
                isError = true;
            }
        }
        
        //insert smsOutboundList;
        Database.SaveResult[] smsResult = Database.insert(smsOutboundList, false);
        for(Database.SaveResult sms : smsResult){
            String smsFailure = '';
            if (!sms.isSuccess()) {
                for(Database.Error smsError : sms.getErrors()){
                    smsFailure += smsError.getStatusCode()+'* ' + smsError.getMessage() + '\n';
                }
                
                logger.log(true, smsFailure);
                isError = true;
            }
        }
        
        //insert taskList;
        Database.SaveResult[] taskResult = Database.insert(taskList, false);
        for(Database.SaveResult tas : taskResult){
            String taskFailure = '';
            if (!tas.isSuccess()) {
                for(Database.Error taskError : tas.getErrors()){
                    taskFailure += taskError.getStatusCode()+'* ' + taskError.getMessage() + '\n';
                }
                
                logger.log(true, taskFailure);
                isError = true;
            }
        }
        
        if(isError){
            logger.save();          
        }
        
    }

    global class MailSMSWrapper {
        global string mailBody;
        global string mailBodyAddress;
        global string mailBodyRemarks;
        global list<string> mailtoAddress;
        global boolean mailisSendEmail;
        
        global string SMSmessage;
        global string SMSmessage2;
        global string SMSRemarks;
        global list<string> SMSMobile;
        
        global id OwnerId;
        global id WhatId;
        global list<id> WhoId;
        global string Description;
        global string Description2;
        global string DescriptionRemarks;
        global string subject;      
    }

}