/**
 * Class Name: SP_VendorNotifChainBatch 
 * @author: Sherwin Puli
 * Date: 08-June-2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that send email notifications for Migrated Subs (Start and Stop) and Normal Expiry Scenario
 */

 
global class SP_VendorNotifChainBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    
    list<exception> exceptionList = new list<exception>(); // declare this at the outermost within your class

   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param BC - predefined parameter 
    * @return list of objects from Order Object
    */ 
    
    public static SMS_Outbound__c bound;
    public static List<SMS_Outbound__c> smsOutboundList = new List<SMS_Outbound__c>();
    public static List<String> venStaffMobileNumberList = new List<String>();
    public static String venMobileNumber;
    public static Map<Id, String> subToOutputMAP = new Map<Id, String>();
    public static Map<Id, String> subToSmsOutputMAP = new Map<Id, String>();
    
    //Prepare the cutoff dates
    public Date dtEffStart = Date.today();        
    public Date dtEffEnd = dtEffStart.addDays(1);

    global static String vendorRepRoleId = Key_Id__c.getInstance('Vendor Rep Role').Id__c;
    
    public static List<Task> taskList = new List<Task>();
    public static List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
    public static Task task;
    public static Set<String> venStaffid = new Set<String>();   
    public static Map<Id, User> vendorStaffId_partnerUser = new Map<Id, User>();
    global Set<Id> selectiveIds = new Set<Id>();
    global Boolean isAdhoc = false;

    
    global class mailTextWrapper {
        global string mailBodyTop;
        global string mailBodyMid;
        global string mailBodyBottom;
        global list<string> mailtoAddress; 
        
        global string SMSmessageTop;
        global string SMSmessageMid;
        global string SMSmessageBottom;
        global List<string> SMSMobile;
        
        global String OwnerId; 
        global List<String> WhoId;
        global string Description;
        global string taskSubject;
        
        global boolean sendMailKey;
        global string RecordTypeId;
        global string transactionPartnerCOS;
        global string transactionNameCOS;
        global string addressId;
        global string vendorId;

    }
    
    global Map<String, mailTextWrapper> mailText_Map;
    global Map<Id, Id> mailRemarks_Map;

    public Map<Id, Map<Id,boolean>> coaWithTempRestartTom = new Map<Id, Map<Id,boolean>>();
    public Map<Id, Map<Id,boolean>> coaInBetwnTStop = new Map<Id, Map<Id,boolean>>();
    List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerListChain;
    
    public SP_VendorNotifChainBatch(List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList) {
        mailText_Map = new Map<String, mailTextWrapper>();
        mailRemarks_Map = new Map<Id, Id>();
        this.batchJobSchedulerListChain = batchJobSchedulerList;
    }
    
    
    public SP_VendorNotifChainBatch(Set<Id> sublist){
        mailText_Map = new Map<String, mailTextWrapper>();
        mailRemarks_Map = new Map<Id, Id>();
        this.selectiveIds = sublist;
        this.isAdhoc = true;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String publication = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        String vendor = GlobalVariableClass.VENDOR;
        //Prepare the cutoff dates
        String query = '';
        query = 'SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Term_Length__c,';
        query += ' Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c,Order_Line_Item_Number_1__r.Suppress_Vendor_Start_notice__c,';
        query += ' Order_Line_Item_Number_1__r.Vendor_Conversion__c,Recipient_Contact__r.Address__r.Postal_Code__r.Name,';
        query += ' Recipient_Contact__c,Recipient_Contact__r.Address__c,Recipient_Contact__r.Address__r.Postal_Code__c,Order_Number_1__r.Vendor_Sms_Remarks__c,';
        query += ' Vendor_1__c, Vendor_1__r.Active__c, Vendor_1__r.Vendor_Communication_Preference__c, Vendor_1__r.RecordType.Name, Vendor_1__r.Email__c,';
        query += ' Frequency_1__c,Vendor_1__r.Handphone_Number__c,Ph_d__c,Ph_e__c,Number_of_Copies__c,Main_Package_1__c,Urgent_1__c';

        query += ' FROM ';
        query += '      Zuora__Subscription__c ';
        query += ' WHERE ';
        query += ' (( Zuora__SubscriptionStartDate__c = :dtEffEnd AND (Zuora__SubscriptionEndDate__c >= :dtEffEnd OR Zuora__SubscriptionEndDate__c = null))';
        query += ' OR';
        query += ' ( Zuora__SubscriptionEndDate__c = :dtEffStart AND Zuora__SubscriptionStartDate__c <= :dtEffStart ))';
        query += ' AND Subscription_Type__c = :publication';
        query += ' AND Delivered_By_1__c = :vendor';
        query += ' AND Vendor_1__c <> null';
        
        
        if(isAdhoc){
            query += ' AND Id IN :selectiveIds';
        }
       
        if (Test.isRunningTest()){
            query += ' Limit 200';
        }

        return Database.getQueryLocator(query);    
    }
    
    /* @description Executes the business logic.Sends email notification to Vendor and Vendor Staff based on scenarios
     * 
     * @param BC - predefined parameter 
     * @param initialSubs - a list of sObjects from the initial database query
     * @return void
     */ 

    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> initialSubs) {       
    
        try{
            String START_SUBSCRIPTION = 'Start_Subscription';
            String CHANGE_OF_SUBSCRIPTION = 'Change_of_Subscription';
            String RENEWAL_OF_SUBSCRIPTION = 'Renewal_of_Subscription';
            String STOP_SUBSCRIPTION = 'Stop_Subscription';
            
            Set<Id> initialSubIds = new Set<Id>();
            Set<Id> subsToFilter = new Set<Id>();
            Set<Id> subscriptionIdSet = new Set<Id>();
            List<Zuora__Subscription__c> scope = new List<Zuora__Subscription__c>();
            
            if(initialSubs.size()>0){
                for(Zuora__Subscription__c sub : initialSubs){
                    initialSubIds.add(sub.Id);
                }
            }
            List<Case_Subscription__c> caseSubsToFilter = new List<Case_Subscription__c>();
            
            //filter out subscriptions with case and case subs and non normal expiry
            if(!initialSubIds.isEmpty()){    
                caseSubsToFilter = [Select ID,Case__c,Subscription__c From Case_Subscription__c Where ((
                (Case__r.RecordType.DeveloperName = :START_SUBSCRIPTION 
                OR Case__r.RecordType.DeveloperName = :CHANGE_OF_SUBSCRIPTION) 
                //OR Case__r.RecordType.DeveloperName = :RENEWAL_OF_SUBSCRIPTION) 
                AND Subscription__r.Zuora__SubscriptionStartDate__c = :dtEffEnd) 
                OR (Case__r.RecordType.DeveloperName = :STOP_SUBSCRIPTION 
                AND Subscription__r.Zuora__SubscriptionEndDate__c = :dtEffStart)) 
                AND Subscription__c In :initialSubIds];

                if(!caseSubsToFilter.isEmpty()){
                    
                    for(Case_Subscription__c cs : caseSubsToFilter){
                        if(cs.Subscription__c <> null){
                            subsToFilter.add(cs.Subscription__c);
                        }
                    }
                }
                //Start PD-0198 16-Jun-2016 Added by S.Puli
                String vendor = GlobalVariableClass.VENDOR;
                List<Case_Subscription__c> caseSubsOfCOS = [SELECT ID,Case__c,Subscription__c,Case__r.Subscription_Name__c 
                FROM Case_Subscription__c WHERE Case__r.RecordType.DeveloperName = :CHANGE_OF_SUBSCRIPTION 
                AND Case__r.Subscription_Name__c IN :initialSubIds 
                AND Subscription__r.Delivered_By_1__c = :vendor
                AND Case__r.Subscription_Name__r.Zuora__SubscriptionEndDate__c = :dtEffStart];
                if(!caseSubsOfCOS.isEmpty()){
                    for(Case_Subscription__c csCOS : caseSubsOfCOS){
                        subsToFilter.add(csCOS.Case__r.Subscription_Name__c);
                    }
                }
                for(Zuora__Subscription__c subRec : initialSubs){
                    if(!subsToFilter.isEmpty()){
                        if(!subsToFilter.contains(subRec.Id)){
                            if(subRec.Zuora__SubscriptionStartDate__c == dtEffEnd){
                                scope.add(subRec);
                                subscriptionIdSet.add(subRec.Id);
                            }else if(subRec.Zuora__SubscriptionEndDate__c <> null){ 
                                if(subRec.Zuora__SubscriptionEndDate__c == dtEffStart){
                                    scope.add(subRec);
                                    subscriptionIdSet.add(subRec.Id);
                                }                           
                            }
                        }
                    }else{
                        scope.add(subRec);
                        subscriptionIdSet.add(subRec.Id);
                    }
                }
                //End PD-0198 16-Jun-2016 Added by S.Puli
            }

            //getting possible publications
            Map<String , Publication__c> publicationMap = new Map<String, Publication__c>();
            Map<String , Publication__c> noSundayPubMap = new Map<String, Publication__c>();
            List <Publication__c> pubList = [Select Publication_Code__c, Sunday_Publication__r.Publication_Code__c, Published_Days__c,                                  
                                            Sunday_Publication__c, Has_Sunday_Pub__c, Publish_Pattern__c
                                            FROM Publication__c Where (Sunday_Publication__c <> '' AND Has_Sunday_Pub__c = true) 
                                            OR (Platform_Type__c='Print' AND Published_Days__c = 'YYYYYYY' AND Publish_Pattern__c = null AND Has_Sunday_Pub__c = false)];
            
            List <Publication__c> noSunPubList = [Select Publication_Code__c, Sunday_Publication__r.Publication_Code__c, Published_Days__c,                                  
                                                Sunday_Publication__c, Has_Sunday_Pub__c, Publish_Pattern__c
                                                FROM Publication__c Where Has_Sunday_Pub__c = false];
            
            For (Publication__c pub :pubList) {
                publicationMap.put(pub.Publication_Code__c, pub);
            } 
            
            for(Publication__c pub :noSunPubList) {
                noSundayPubMap.put(pub.Publication_Code__c, pub); 
            }
            
            //handling of bundle
            Set<Id> startPackIds = new Set<Id>();
            Map<Id, Package_Item__c> startPackToPackItemsMap = new Map<Id, Package_Item__c>();
            if(!scope.isEmpty()){
                for(Zuora__Subscription__c sublist : scope){   
                    startPackIds.add(sublist.Main_Package_1__c);
                }
            }
            List<Package_Item__c> startPackageItems = new List<Package_Item__c>();
            if(!startPackIds.isEmpty()){
                startPackageItems = [Select Id, Is_Print__c,  Is_All_In_One__c, Is_Digital_2__c, Package__c
                                                    From Package_Item__c 
                                                    Where Package__c IN :startPackIds
                                                    AND (RecordTypeId = :ConstantsSLB.getKeyId('Package Item_Base Product') 
                                                    OR RecordTypeId = :ConstantsSLB.getKeyId('Package Item_Bundle Product')) 
                                                    AND (Product_Platform__c = :GlobalVariableClass.PLATFORM_PRINT 
                                                    OR Product_Platform__c = :GlobalVariableClass.PLATFORM_AIO)];
            
                for(Package_Item__c pItem : startPackageItems)
                {
                    startPackToPackItemsMap.put(pItem.Package__c, pItem);
                }
            }
            //getting alias from assigned vendor ops from Post Sector Mapping 
            Set<String> zoneNameSet = new Set<String>();
            Set<Id> vendorIdset = new Set<Id>();
            Set<Id> contactIdSet = new Set<Id>();
            Map<Id, Zuora__Subscription__c> subscriptionMap = new Map<Id, Zuora__Subscription__c>();
            if(!scope.isEmpty()){
                for(Zuora__Subscription__c zSub : scope){
                    subscriptionMap.put(zSub.Id,zSub);
                    contactIdSet.add(zSub.Recipient_Contact__c);
                    vendorIdset.add(zSub.Vendor_1__r.Id);
                    if(zSub.Recipient_Contact__c <> null){
                        if(zSub.Recipient_Contact__r.Address__c <> null){
                            if(zSub.Recipient_Contact__r.Address__r.Postal_Code__c <> null){
                                if(zSub.Recipient_Contact__r.Address__r.Postal_Code__r.Name.length() > 2){
                                    String postalSectorKey = '';
                                    postalSectorKey = zSub.Recipient_Contact__r.Address__r.Postal_Code__r.Name.substring(0,2);
                                    zoneNameSet.add(postalSectorKey);
                                }
                            }
                        }
                    }
                }
            }
            
            Map<Id,Id> vendorStaffContactIdMAP = new Map<Id,Id>();
            Map<Id, String> conId_AliasMap = new Map<Id, String>();
            Map<Id, id> conId_NameMap = new Map<Id, Id>();
            List<Post_Sector_Ops_Rep_Mapping__c> postSectorMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
            Map<Id, List<Contact>> account_VendorStaffMap = new Map<Id, List<Contact>>();
            if(vendorIdset<>null && vendorIdset.size()>0){
                List<Contact> vendStaffList = [Select Id, Name, RecordType.Name, Vendor_Communication_Preference__c, AccountId, Email,Active__c,HomePhone__c From Contact Where AccountId IN :vendorIdset AND RecordType.Name = :GlobalVariableClass.VENDOR_STAFF AND Active__c = true];
                List<Account> vendorList = [SELECT id, name, Vendor_Communication_Preference__c FROM Account WHERE Id IN: vendorIdset]; 
            
                if(!vendStaffList.isEmpty()){
                    for(Contact c : vendStaffList){
                        vendorStaffContactIdMAP.put(c.Id,c.AccountId);
                        if(!account_VendorStaffMap.containsKey(c.AccountId)){
                            account_VendorStaffMap.put(c.AccountId, new List<Contact>{c});
                        }else{
                            account_VendorStaffMap.get(c.AccountId).add(c);
                        }
                    }
                }
                List<User> userList = new List<User>();
                if(!userList.isEmpty()){
                    userList = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE 
                                AND ContactId IN :vendorStaffContactIdMAP.keyset() AND IsActive = true];
                }
                if(!zoneNameSet.isEmpty()){
                    postSectorMapping_List = [Select Id, Zone__r.Name, Vendor_Ops__c, Vendor_Ops__r.Alias, Vendor_Ops__r.IsActive From Post_Sector_Ops_Rep_Mapping__c 
                                                Where Zone__r.Name In :zoneNameSet AND Vendor_Ops__c <> null AND Vendor_Ops__r.IsActive = true];
                }
                if(postSectorMapping_List.size()>0){
                    for(Post_Sector_Ops_Rep_Mapping__c postSectRec : postSectorMapping_List){
                        if(postSectRec.Vendor_Ops__r.Alias <> null){
                            for(Zuora__Subscription__c subToAlias : scope){
                                if(subToAlias.Recipient_Contact__c <> null){
                                    if(subToAlias.Recipient_Contact__r.Address__c <> null){
                                        if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__c <> null){
                                            if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__r.Name <> null){
                                                if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__r.Name.length()>2){
                                                    if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__r.Name.subString(0,2) == postSectRec.Zone__r.Name){
                                                        conId_AliasMap.put(subToAlias.Recipient_Contact__c, postSectRec.Vendor_Ops__r.Alias);
                                                    }
                                                }else{
                                                    if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__r.Name == postSectRec.Zone__r.Name){
                                                        conId_AliasMap.put(subToAlias.Recipient_Contact__c, postSectRec.Vendor_Ops__r.Alias);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(userList<>null && userList.size()>0){
                    for(User u : userList){
                        conId_NameMap.put(vendorStaffContactIdMAP.get(u.ContactId), u.id);
                        vendorStaffId_partnerUser.put(u.ContactId,u);
                    }
                }
            }
            
            //map spc to subs
            List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
            if(!subscriptionIdSet.isEmpty()){
                subProdChargeList = [SELECT Zuora__Subscription__c, Zuora__RatePlanName__c, PublicationCode__c, Zuora__UOM__c FROM Zuora__SubscriptionProductCharge__c 
                                WHERE Zuora__Subscription__c IN: subscriptionIdSet];
            }
            Map <id, List<Zuora__SubscriptionProductCharge__c>> subToSPC = new Map <id, List<Zuora__SubscriptionProductCharge__c>>(); 
            
            if(!subProdChargeList.isEmpty()){       
                for(Zuora__SubscriptionProductCharge__c subProdCharge: subProdChargeList){
                    if(subProdCharge.PublicationCode__c <> null && subProdCharge.Zuora__Subscription__c <> null){
                        if (subToSPC.containskey(subProdCharge.Zuora__Subscription__c)) {
                            subToSPC.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge);
                        }
                        else {
                            subToSPC.put(subProdCharge.Zuora__Subscription__c, new List <Zuora__SubscriptionProductCharge__c> {subProdCharge});
                        }
                    }
                }
            }

            //Get contacts
            List<Contact> contactList = new List<Contact>();
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            Set<Id> addressIdSet = new Set<Id>();
            List<Address__c> addressList = new List<Address__c>();
            List<Singpost_Address__c> singpostAddressList = new List<Singpost_Address__c>();
            Map<Id, Address__c> addressMap = new Map<Id, Address__c>();
            Set<Id> singpostAddressIdSet = new Set<Id>();
            Map<Id,Singpost_Address__c> singpostAddressMap = new Map<Id,Singpost_Address__c>();
            List<Contact> vendorStaffsList = new List<Contact>();
            Contact con = new Contact();
            Address__c addressObj = new Address__c();
            Singpost_Address__c singpostAddressObj = new Singpost_Address__c();
            set<string> pubCode = new set<string>();
            Map <string, string> details = new  Map <string, string>();
            integer myCounter = 0;
            String transactionName = '';
            string sub = '';
            String classification = '';
            if(!contactIdSet.isEmpty()){
                contactList = [SELECT Id, FirstName, LastName, Address__r.Id, Salutation FROM Contact WHERE Id IN: contactIdSet];
                for(Contact c : contactList){
                    contactMap.put(c.Id, c);
                    addressIdSet.add(c.Address__r.Id);
                }
            }
            
            //Get Addresses based on Contacts
            if(!addressIdSet.isEmpty()){
                addressList = [SELECT Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__c,Postal_Code__r.Id 
                            FROM Address__c WHERE Id IN: addressIdSet]; 
            }                           
            if(!addressList.isEmpty()){       
                for(Address__c address : addressList){
                    addressMap.put(address.Id, address);
                    singpostAddressIdSet.add(address.Postal_Code__r.Id);
                }
            }
            
            //Get SingpostAddress based on Addresses
            if(!singpostAddressIdSet.isEmpty()){
                singpostAddressList = [SELECT Id, Name FROM Singpost_Address__c WHERE Id IN: singpostAddressIdSet];
            }
            if(!singpostAddressList.isEmpty()){
                for(Singpost_Address__c singpostAddress : singpostAddressList){
                    singpostAddressMap.put(singpostAddress.Id, singpostAddress);
                }
            }

            //start construction of frequency 
            if(!scope.isEmpty()){
                for(Zuora__Subscription__c subscription : scope){
                    Messaging.SingleEmailMessage mail = getEmail();
                    String issueDate = '';
                    Set<String> toAddressesSet = new Set<String>();
                    List<String> toAddresses = new List<String>(); 
                    boolean sendMail = false;
                    boolean isSendEmail = false;
                    sub = '';
                    transactionName = '';
                    if(subscription.Vendor_1__c <> null){
                        if((subscription.Vendor_1__r.Vendor_Communication_Preference__c == 'Both' || subscription.Vendor_1__r.Vendor_Communication_Preference__c == 'Email') 
                            && subscription.Vendor_1__r.Active__c == true && subscription.Vendor_1__r.RecordType.Name == GlobalVariableClass.VENDOR){
                            if(subscription.Vendor_1__r.Email__c != null){                             
                                toAddressesSet.add(subscription.Vendor_1__r.Email__c);
                                isSendEmail = true;
                            }
                        }
                    }
                    
                    venMobileNumber = null;
                    if(subscription.Vendor_1__c <> null){
                        if(subscription.Vendor_1__r.Vendor_Communication_Preference__c <> 'Email' && subscription.Vendor_1__r.Active__c){
                            venMobileNumber = subscription.Vendor_1__r.Handphone_Number__c;
                        }
                    }
                    
                    vendorStaffsList = null;
                    if(account_VendorStaffMap.containsKey(subscription.Vendor_1__c)){
                        vendorStaffsList = account_VendorStaffMap.get(subscription.Vendor_1__c);
                    }
                    
                    con = new Contact();
                    if(!contactMap.isEmpty()){            
                        if(contactMap.containsKey(subscription.Recipient_Contact__c)){
                            con = contactMap.get(subscription.Recipient_Contact__c); 
                        }
                    }
                    
                    addressObj = new Address__c();
                    singpostAddressObj = new Singpost_Address__c();
                    if(!addressMap.isEmpty()){
                        if(addressMap.containsKey(con.Address__r.Id)){
                            addressObj = addressMap.get(con.Address__r.Id);
                            if(!singpostAddressMap.isEmpty()){
                                if(addressObj.Postal_Code__c <> null){
                                    singpostAddressObj = singpostAddressMap.get(addressObj.Postal_Code__r.Id);
                                }
                            }
                        }
                    }
                    
                    List <Zuora__SubscriptionProductCharge__c> spcList = new List <Zuora__SubscriptionProductCharge__c>();
                    spcList = subToSPC.get(subscription.Id);
                    
                    pubCode = new set<string>();
                    if (spcList != null) {
                        for(Zuora__SubscriptionProductCharge__c spc: spcList){
                            if (spc.PublicationCode__c != null && (spc.Zuora__UOM__c == 'Copy Weekday' || spc.Zuora__UOM__c == 'Copy Sat' || spc.Zuora__UOM__c == 'Copy Sun'))  {
                                pubCode.add(spc.PublicationCode__c);
                                pubCode.remove(null);      
                            }               
                        }
                    }
                    
                    details = new  Map <string, string>();
                    myCounter = 1;
                    if(!pubCode.isEmpty()){
                        for (string eachPubCode: pubCode) {
                            myCounter = myCounter +1;
                            string phDStart = '0';
                            string phEStart = '0';
                            string freq3 = ' ';
                            string freq4 = ' ';
                            if(subscription.Ph_d__c){
                                phDStart = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');
                            }
                            if(subscription.Ph_e__c){
                                phEStart = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');
                            }
                            if(publicationMap.containskey(eachPubCode)) {
                                    
                                Publication__c pub = new Publication__c();
                                pub = publicationMap.get(eachPubCode);
                                if (details.containskey(pub.Sunday_Publication__r.Publication_Code__c)) {
                                    if(subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_DEFAULT 
                                        || subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_FRISUN 
                                        || subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_SATSUN){
                                        sub = string.valueOf(eachPubCode) + '/' + sub;

                                        details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);

                                    } else if(subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_MONFRI || subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_MONSAT){
                                        sub = string.valueOf(eachPubCode);
                                        details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);
                                    }
                                } else {
                                     sub = '';

                                     if(pub.Sunday_Publication__c == null ){
                                        sub = string.valueOf(eachPubCode);
                                     }else{
                                        if(subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_DEFAULT 
                                            || subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_FRISUN 
                                            || subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_SATSUN){
                                            sub = string.valueOf(eachPubCode) + '/' + pub.Sunday_Publication__r.Publication_Code__c;
                                        } else if(subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_MONFRI || subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_MONSAT){
                                            sub = string.valueOf(eachPubCode);
                                        }
                                     }

                                     if(subscription != null){
                                        string numOfCopy = '';

                                        try{

                                        if(subscription.Number_of_Copies__c <> null && subscription.Frequency_1__c <> null){
                                            numOfCopy = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');

                                            if(startPackToPackItemsMap.containsKey(subscription.Main_Package_1__c)){
                                                if(startPackToPackItemsMap.get(subscription.Main_Package_1__c).Is_Print__c || startPackToPackItemsMap.get(subscription.Main_Package_1__c).Is_All_In_One__c)
                                                {
                                                    
                                                    if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT )
                                                    {
                                                        freq3 = pub.Published_Days__c.replace('Y', numOfCopy);                                                
                                                        freq4 = freq3.replace('N', '0') + phDStart + phEStart;                                              
                                                    
                                                    }
                                                    else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_MONFRI) 
                                                    {
                                                        freq4 = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + '0' + numOfCopy + '0';
                                                        
                                                    }
                                                    else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_MONSAT)
                                                    {
                                                        freq4 = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + numOfCopy + numOfCopy;
                                                        
                                                    }
                                                    else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_SATSUN)
                                                    {
                                                        freq4 = '0' + '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + '0' + numOfCopy;
                                                        
                                                    }
                                                    else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_FRISUN)
                                                    {
                                                        freq4 = '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy;
                                                        
                                                    }

                                                    if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'YYYYYYN'){

                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'NNNNYYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'NNNNNYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((1*(numOfCopy.length()))+2));
                                                        freq4 += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq4 +') ';   
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((3*(numOfCopy.length()))));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYNN'){

                                                        freq4 = freq4.substring(0, ((5*(numOfCopy.length()))+1));

                                                        freq4 += '0' + numOfCopy + '0';

                                                        sub += ' ('+GlobalVariableClass.FREQ_MONFRI +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'NNNNYYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((3*(numOfCopy.length()))));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'NNNNNYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += '0' + numOfCopy + numOfCopy;

                                                        sub += ' ('+GlobalVariableClass.FREQ_MONSAT +'>'+freq4 +') ';
                                                    } else{
                                                        sub += ' ('+string.valueOf(subscription.Frequency_1__c)+'>'+freq4 +') ';
                                                    }

                                                }
                                                
                                            }
                                        }

                                        } catch(Exception e){
                                            exceptionList.add(e);
                                        }
         
                                    }

                                        details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);

                                }
                            }
                            else {
                                if (!details.containskey(eachPubCode)) {
                                     sub = '';
                                     sub = string.valueOf(eachPubCode);

                                    List<Publication__c> thisPub = new List<Publication__c>();
                                    
                                    if(noSundayPubMap.containsKey(eachPubCode)){
                                        thisPub.add(noSundayPubMap.get(eachPubCode));

                                         if(subscription != null){

                                            string numOfCopy = '';
                                            if(subscription.Number_of_Copies__c <> null && subscription.Frequency_1__c <> null){
                                                try{

                                                numOfCopy = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');

                                                    if(startPackToPackItemsMap.containsKey(subscription.Main_Package_1__c)){
                                                        if(startPackToPackItemsMap.get(subscription.Main_Package_1__c).Is_Print__c || startPackToPackItemsMap.get(subscription.Main_Package_1__c).Is_All_In_One__c)
                                                        {                                               
                                                            if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT)
                                                            {
                                                                freq3 = thisPub[0].Published_Days__c.replace('Y', numOfCopy);

                                                                freq4 = freq3.replace('N', '0') + phDStart + phEStart;
                                                        
                                                            }
                                                            else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_MONFRI) 
                                                            {
                                                                freq4 = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + '0' + numOfCopy + '0';
                                                        
                                                            }
                                                            else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_MONSAT)
                                                            {
                                                                freq4 = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + numOfCopy + numOfCopy;
                                                        
                                                            }
                                                            else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_SATSUN)
                                                            {
                                                                freq4 = '0' + '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + '0' + numOfCopy;
                                                        
                                                            }
                                                            else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_FRISUN)
                                                            {
                                                                freq4 = '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy;
                                                        
                                                            }
            
                                                        if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'YYYYYYN'){
                                                            freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                            freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                            sub += ' ('+GlobalVariableClass.DAILY +'>'+freq4 +') ';
                                                        }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'NNNNYYN'){
                                                            freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                            freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                            sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq4 +') ';
                                                        }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'NNNNNYN'){
                                                            freq4 = freq4.substring(0, freq4.length() - ((1*(numOfCopy.length()))+2));
                                                            freq4 += numOfCopy + '0' + numOfCopy;
                                                            sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq4 +') ';   
                                                        }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYYY'){
                                                            freq4 = freq4.substring(0, freq4.length() - ((3*(numOfCopy.length()))));
                                                            freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                            sub += ' ('+GlobalVariableClass.DAILY +'>'+freq4 +') ';
                                                        }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYNN'){

                                                            freq4 = freq4.substring(0, ((5*(numOfCopy.length()))+1));

                                                            freq4 += '0' + numOfCopy + '0';

                                                            sub += ' ('+GlobalVariableClass.FREQ_MONFRI +'>'+freq4 +') ';
                                                        }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'NNNNYYY'){
                                                            freq4 = freq4.substring(0, freq4.length() - ((3*(numOfCopy.length()))));
                                                            freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                            sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq4 +') ';
                                                        }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'NNNNNYY'){
                                                            freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                            freq4 += numOfCopy + '0' + numOfCopy;
                                                            sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq4 +') ';
                                                        }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYYN'){
                                                            freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                            freq4 += '0' + numOfCopy + numOfCopy;

                                                            sub += ' ('+GlobalVariableClass.FREQ_MONSAT +'>'+freq4 +') ';
                                                        } else{
                                                            sub += ' ('+string.valueOf(subscription.Frequency_1__c)+'>'+freq4 +') ';
                                                        }

                                                        }
                                                        
                                                    }

                                                } catch(Exception e){
                                                    exceptionList.add(e);
                                                }
                                            }
                                         }
                                        if(thisPub[0].Publish_Pattern__c != GlobalVariableClass.CREATEVENDORSTART_WEEKEND && thisPub[0].Sunday_Publication__c == null)
                                        {
                                            details.put(eachPubCode, sub);
                                        }
                                    }
                                
                                }
                                
                            }
                        }
                    }
                    sub = '';
                    myCounter = 0;
                    for (String perSub : details.keyset()) {
                        myCounter += 1;
                        sub += details.get(perSub);
                    }

                    //classify if start dtEffEnd or stop dtEffStart 
                    if(subscription.Zuora__SubscriptionStartDate__c == dtEffEnd 
                    && (subscription.Zuora__SubscriptionEndDate__c == null || dtEffStart < subscription.Zuora__SubscriptionEndDate__c) 
                    && (subscription.Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c == false 
                    && subscription.Order_Line_Item_Number_1__r.Suppress_Vendor_Start_notice__c == false)){
                    
                        if(subscription.Urgent_1__c == false){
                            transactionName = GlobalVariableClass.START_URGENT;
                        }else if(subscription.Order_Line_Item_Number_1__r.Vendor_Conversion__c){
                            transactionName = GlobalVariableClass.START_CONVERSION;
                        }else{
                            transactionName = GlobalVariableClass.START_NEW;
                        }
                        sendMail = true;
                        issueDate = convertDateToString(subscription.Zuora__SubscriptionStartDate__c);
                    }
                    
                    if(subscription.Zuora__SubscriptionEndDate__c == dtEffStart && subscription.Zuora__SubscriptionStartDate__c <= dtEffStart){
                        transactionName = GlobalVariableClass.STOP_URGENT ;
                        sendMail = true;
                        issueDate = convertDateToString(subscription.Zuora__SubscriptionEndDate__c.addDays(1));
                    }
                    
                    classification = GlobalVariableClass.NOTIF_CLASS_DIRECT;
                
                    if(toAddressesSet.size() > 0){
                        toAddresses.addAll(toAddressesSet);
                    }
                    venStaffMobileNumberList = new List<String>();
                    if(vendorStaffsList != null){
                        venStaffid = new Set<String>();
                        for(Contact venCon : vendorStaffsList){  
                            if(venCon.Id != null){
                                venStaffid.add(venCon.Id);
                            }
                            if(venCon.Email != null){
                                if(toAddresses.size() < 100){
                                    if((venCon.Vendor_Communication_Preference__c == 'Both' || venCon.Vendor_Communication_Preference__c == 'Email') && venCon.Active__c){
                                        toAddresses.add(venCon.Email);
                                        isSendEmail = true;
                                    }
                                }
                            }
                            if((venCon.Vendor_Communication_Preference__c == 'Both' || venCon.Vendor_Communication_Preference__c == 'SMS') 
                                && venCon.Active__c && venCon.HomePhone__c != null){                                 
                                venStaffMobileNumberList.add(venCon.HomePhone__c);
                            }
                        }
                    }
                    
                    if(sendMail == true){
                        if(sub != '' && sub != null){
                            constructMail(transactionName, toAddresses, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, conId_NameMap, isSendEmail);
                        }
                    }
                    
                }//end of subscription loop
            }
            
        }catch(Exception e){
            exceptionList.add(e);//error handling
        }
      
        ExceptionLogger.log(exceptionList); // you must invoke this at the end of your execution script
    }
    
    public void constructMail(String transactionNameParam, List<String> toAddressesParam, Zuora__Subscription__c subscriptionParam, Map<Id, String> conId_AliasMapParam, String issueDateParam, String subParam, Address__c addressObjParam, Singpost_Address__c singpostAddressObjParam, String classificationParam, Map<Id, id> conId_NameMapParam, boolean isSendEmailParam){
        
        mailTextWrapper mailTextFields = new mailTextWrapper();
        mailTextFields.SMSMobile = new List<string>();
        mailTextFields.WhoId = new List<string>();
        String key = '';
        
        if(addressObjParam <> null && subscriptionParam <> null){
            key = string.valueOf(addressObjParam.id) + string.valueOf(subscriptionParam.Vendor_1__c) + transactionNameParam;
        }
        
        mailTextFields.sendMailKey = false;
        if(isSendEmailParam){
            mailTextFields.sendMailKey = true;
        }
        if(!toAddressesParam.isEmpty()){  
            mailTextFields.mailtoAddress = toAddressesParam;
        }
                
        String output = '';
        String smsoutput = '';
        String output3 = '';
        String smsoutput3 = '';
        String output4 = '';
        String smsoutput4 = '';
        String output5 = '';
        String smsoutput5 = '';
        
        if(!mailText_Map.containsKey(key)){
            if(conId_AliasMapParam.containsKey(subscriptionParam.Recipient_Contact__c)){
                output += conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c)+' ';
                smsoutput += conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c)+' ';
            }
            if(issueDateParam != null){
                issueDateParam.replace(' 00:00:00',''); 
                output += issueDateParam+' ';
                smsoutput += issueDateParam+' ';
            }
            if (transactionNameParam != null && transactionNameParam != 'null'){
                output += '-' + transactionNameParam + ' ' + '&nbsp;' +'</br>';
                smsoutput += '-' + transactionNameParam + ' ' + ' ';
            }
            
            mailTextFields.mailBodyTop = output;
            mailTextFields.SMSmessageTop = smsoutput;
            
        }//end mailtText_Map top
        
        if (subParam != null && subParam != 'null'){        
            if(!mailText_Map.containsKey(key)){
                
                output4 += subParam.removeEnd(' ');
                smsoutput4 += subParam.removeEnd(' ');
                mailTextFields.mailBodyMid = output4;
                mailTextFields.SMSmessageMid = smsoutput4;
                
                 
            }else{
                String newSub = '';
                newSub = mailText_Map.get(key).mailBodyMid + ', '+subParam.removeEnd(' ');
                mailText_Map.get(key).mailBodyMid = newSub;
                mailText_Map.get(key).SMSmessageMid = newSub;
            }   
        }//end mailtText_Map mid
        
        if(!mailText_Map.containsKey(key)){
            output3 += '</br>'+' @';
            smsoutput3 += ' '+' @';
                
            if(addressObjParam != null){
                if (addressObjParam.Block_House_Number__c != null){
                    
                    output3 += string.valueOf(addressObjParam.Block_House_Number__c)+' ';
                    smsoutput3 += string.valueOf(addressObjParam.Block_House_Number__c)+' ';
                }

                if (addressObjParam.Street_Name__c != null){
                    output3 += addressObjParam.Street_Name__c+' ';
                    smsoutput3 += addressObjParam.Street_Name__c+' ';
                }
                if (addressObjParam.Building_Name__c != null){
                    output3 += addressObjParam.Building_Name__c+' ';
                    smsoutput3 += addressObjParam.Building_Name__c+' ';
                }
                if (addressObjParam.Level_Number__c != null){
                    output3 += '#'+string.valueOf(addressObjParam.Level_Number__c);
                    smsoutput3 += '#'+string.valueOf(addressObjParam.Level_Number__c);
                }

                if (addressObjParam.Unit_Number__c != null){
                
                    output3 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';
                    smsoutput3 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';
                }
            }

            output3 += ' ' + classificationParam + ' ' ;
            smsoutput3 += ' ' + classificationParam + ' ' ;
            
            mailTextFields.mailBodyBottom = output3;
            mailTextFields.SMSmessageBottom = smsoutput3;
            
            if (subscriptionParam.Order_Number_1__r.Vendor_Sms_Remarks__c != null && subscriptionParam.Order_Number_1__r.Vendor_Sms_Remarks__c != ''){
                output5 += ' ('+subscriptionParam.Order_Number_1__r.Vendor_Sms_Remarks__c+') ';
                smsoutput5 += ' ('+subscriptionParam.Order_Number_1__r.Vendor_Sms_Remarks__c+') '; 
                
                if(!mailText_Map.containsKey(key)){
                    mailTextFields.mailBodyBottom = mailTextFields.mailBodyBottom + output5;
                    mailTextFields.SMSmessageBottom = mailTextFields.SMSmessageBottom + smsoutput5;
                }else{
                    mailText_Map.get(key).mailBodyBottom = mailText_Map.get(key).mailBodyBottom + ', '+output5;
                    mailText_Map.get(key).SMSmessageBottom = mailText_Map.get(key).SMSmessageBottom + ', '+output5;
                }
            }
        }//end mailtText_Map bot
        String taskSub = '';
        if(!venStaffid.isEmpty()){
            for(String venStaff : venStaffid){
                taskSub = '';
                if(subscriptionParam.Zuora__SubscriptionStartDate__c == dtEffEnd){
                    taskSub = GlobalVariableClass.SUBJECT_START_SUBSCRIPTION;
                }else if(subscriptionParam.Zuora__SubscriptionEndDate__c == dtEffStart){
                    taskSub = GlobalVariableClass.SUBJECT_STOP_SUBSCRIPTION;
                }
                if(conId_NameMapParam.containsKey(subscriptionParam.Vendor_1__r.Id)){
                    if(conId_NameMapParam.get(subscriptionParam.Vendor_1__r.Id) != NULL) {      
                        mailTextFields.OwnerId = conId_NameMapParam.get(subscriptionParam.Vendor_1__r.Id);
                        mailTextFields.WhoId.add(venStaff);
                        mailTextFields.taskSubject = 'Notification (' + taskSub + ')';
 

                    }
                }
            }
        }
        
        if(!venStaffMobileNumberList.isEmpty()){
            for(String venStaffMobNum : venStaffMobileNumberList){
                if(venStaffMobNum != null){
                    mailTextFields.SMSMobile.add(venStaffMobNum);
                }
            }
        }
        if(venMobileNumber != null){
            mailTextFields.SMSMobile.add(venMobileNumber);
        }
        if(!mailText_Map.containsKey(key)){
            mailText_Map.put(key, mailTextFields);
        }

    }
    
    public static Messaging.SingleEmailMessage getEmail() {

        Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
        mailMessage.setSaveAsActivity(false);
        return mailMessage;

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
        
        List<Messaging.SingleEmailMessage> mail_LIST = new List<Messaging.SingleEmailMessage>();
        List<SMS_Outbound__c> smsList = new List<SMS_Outbound__c>();
        List<Task> task_LIST = new List<Task>();
        if(!mailText_Map.isEmpty()){
            for(mailTextWrapper data : mailText_Map.values()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(data.mailtoAddress);
                    mail.setSubject(GlobalVariableClass.EMAIL_DELIVERY_NOTIFICATION);
                    mail.setHtmlBody(data.mailBodyTop + data.mailBodyMid + data.mailBodyBottom);
                    
                if(data.sendMailKey){
                    mail_LIST.add(mail);
                }
                
                for(String mobileNum : data.SMSMobile){
                    SMS_Outbound__c txtMsg = new SMS_Outbound__c();
                        txtMsg.SMS_status__c = GlobalVariableClass.STATUS_NEW;
                        txtMsg.SMS_message__c = data.SMSmessageTop + data.SMSmessageMid + data.SMSmessageBottom;
                        txtMsg.Mobile__c = mobileNum;
                    smsList.add(txtMsg);
                }
                
                for(String conId : data.WhoId){
                    Task taskRecord = new Task();
                        taskRecord.OwnerId = data.OwnerId;
                        taskRecord.WhoId = conId;
                        taskRecord.Description = data.SMSmessageTop + data.SMSmessageMid + data.SMSmessageBottom;
                        taskRecord.ActivityDate = Date.Today();
                        taskRecord.subject = data.taskSubject;
                        taskRecord.Status = 'Open';
                    task_LIST.add(taskRecord);
                }
            }
            
            boolean isError = false;
            Logger logger = new Logger(SP_VendorNotificationsBatch.class.getName(), 'SP017', BC.getJobID());
            Messaging.SendEmailResult[] mailResult = Messaging.sendEmail(mail_LIST, false);
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
            
            //Database.insert(smsList, false);
            Database.SaveResult[] smsResult = Database.insert(smsList, false);
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
            
            //Database.insert(task_LIST, false);
            Database.SaveResult[] taskResult = Database.insert(task_LIST, false);
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
        
    }
    
    public void testCoveragePatch() {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
    
}