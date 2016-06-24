/**
 * Class Name: EmailNotificationCreation 
 * @author: Alyana Navarro
 * Date: 2/3/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Class that send email notifications to Vendor and Vendor Staff
 * @author: Jason Abolac
 * Date: 3/12/2015
 * Requirement/Project Name: Singapore Press Holdings / MD -54
 * @description: SMS Notification to Vendor and Vendor Staff
 * 
 * HISTORY: MD-62 D-2682 6/27/2015 Alyana Navarro - Add logic that caters sending email and sms to Vendor Subscriber.
*/

public class EmailNotificationCreation{
    //Start: MD-54 03/12/2015 Jason Abolac
    public static List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
    //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
    //public static Case caseRecord = new Case();
    public static List<Case> caseRecord = new List<Case>();
    public static Map<Id, Zuora__Subscription__c> subscriptionMap = new Map<Id, Zuora__Subscription__c>();
    //END: MD-62 D-2620 03/31/2015 Sherwin Puli 
    public static Map<String, Set<String>> subIdPubCodeSetMap = new Map<String, Set<String>>();
    public static Map<String, Address__c> subIdAddressMap = new Map<String, Address__c>();
    public static Map<String, Singpost_Address__c> subIdSingpostIdMap = new Map<String, Singpost_Address__c>();
    public static Map<String, List<Contact>> vendorIdVendorStaffListMap = new Map<String, List<Contact>>();
    public static Map<String, Publication__c> publicationMap = new Map<String, Publication__c>();
    public static Map<String, String> pubCodeParentPubMap = new Map<String, String>();    
    public static String smsMessage{get;set;}
    public static List<String> mobileNumberList = new List<String>();
    public static String mobileNumber = '';
    //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
    public static List<Case> caserec_LIST = new List<Case>();
    public static Map<Id, List<Id>> caseToSub_MAP = new Map<Id, List<Id>>();
    //END: MD-62 D-2620 03/31/2015 Sherwin Puli
    // START : MD-62 D-2682 6/27/2015 Alyana Navarro
    public static Map<Id, List<Id>> caseVenToSubVen_MAP = new Map<Id, List<Id>>();
    public static List<Subscription_Vendor__c> subscriptionVenList = new List<Subscription_Vendor__c>();
    public static Map<Id, Subscription_Vendor__c> subscriptionVenMap = new Map<Id, Subscription_Vendor__c>();
    public static Map<Id, Set<String>> subIdPubIdSetMap = new Map<Id, Set<String>>();
    public static Map<Id, List<Subscription_Vendor_Publication__c>> subIdSubVenListMap = new Map<Id, List<Subscription_Vendor_Publication__c>>();
    // END : MD-62 D-2682 6/27/2015 Alyana Navarro
    //End: MD-54 03/12/2015 Jason Abolac
    // START : UD-0985 7/8/2015 Alyana Navarro
    public static Map<Id, List<Package_Item__c>> packIdPackLineItemMap = new Map<Id, List<Package_Item__c>>();  
    // END : UD-0985 7/8/2015 Alyana Navarro
    // START : UD-2270 8/10/2015 Alyana Navarro
    //Start: D-4466 15-march-2016 added by Jason A. 
    public static Map<id , Case_Subscription__c> casesubmap = new Map<id , Case_Subscription__c>();
    public static Map<id , Case_Vendor_Subscription__c> caseVenSubmap = new Map<id , Case_Vendor_Subscription__c>();
    //End: D-4466 15-march-2016 added by Jason A. 
    public static Map<Id, Id> vendorPartnerUserMap = new Map<Id, Id>();
    public static List<Task> taskList = new List<Task>();
    public static Map<Id, String> conId_AliasMap = new Map<Id, String>();
    // END : UD-2270 8/10/2015 Alyana Navarro
   //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
    public static void getDetails(Set<Id> caseRec){  //Start-End: MD-54 03/12/2015 Jason Abolac
    //END: MD-62 D-2620 03/31/2015 Sherwin Puli
        Boolean isExisting = false;
        String vendorStaffRecTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.CONTACT_VENDOR_STAFF);
        Set<String> subIdSet = new Set<String>();

        Set<String> addressIdSet = new Set<String>();
        Set<String> singpostIdSet = new Set<String>();
        Set<String> vendorAccountIdSet = new Set<String>();
        Set<String> pubCodeSet = new Set<String>();
        Set<String> sunPubSet = new Set<String>();
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        //MD-62vendor
        List<Case_Vendor_Subscription__c> caseSubVendorList = new List<Case_Vendor_Subscription__c>();
        Set<Id> subVenIdSet = new Set<Id>();
        Set<String> subVendorAccIdSet = new Set<String>();
        //MD-62vendor
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        List<Address__c> addressList = new List <Address__c>();
        List<Singpost_Address__c> singpostAddressList = new List<Singpost_Address__c>();
        List<Contact> vendorStaffList = new List<Contact>();
        List<Publication__c> publicationList = new List<Publication__c>();
        List<Publication__c> sundayPubList = new List<Publication__c>();
        Map<String, String> singpostIdSubIdMap = new Map<String, String>();     
        // START : D-1796 2/24/2015 Alyana Navarro
        Map<id, id> subIdAddIdMap = new Map<id, id>();
        Map<id, Address__c> addressMap = new Map<id, Address__c>();
        Map<id, Singpost_Address__c> singpostMap = new Map<id, Singpost_Address__c>();
        // END : D-1796 2/24/2015 Alyana Navarro
        // START : UD-0985 7/8/2015 Alyana Navarro
        Set<Id> packageIdSet = new Set<Id>(); 
        List<Package_Item__c> packageLineItemList = new List<Package_Item__c>();        
        // END : UD-0985 7/8/2015 Alyana Navarro
        // START : UD-2270 8/10/2015 Alyana Navarro
        List<User> partnerUserList = new List<User>();
        Set<Id> vendorSftaffIdSet = new Set<Id>();
        // END : UD-2270 8/10/2015 Alyana Navarro   
        //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
        //caseRecord = [SELECT id, CaseNumber, Account.recordType.Name FROM Case WHERE id =: caseRec];  //Start-End: MD-54 03/12/2015 Jason Abolac
    //Start D-3123 06/22 Jason A.
        caseRecord = [SELECT id, CaseNumber, Account.recordType.Name, CreatedDate, Sub_Category__c, RecordType.name FROM Case WHERE id IN: caseRec]; // START-END : UD-2270 8/10/2015 Alyana Navarro
    //End D-3123 06/22 Jason A.        
    //Start: D-4466 15-march-2016 added by Jason A. 
        //caseSubList = [SELECT Id, Case__c, Subscription__c FROM Case_Subscription__c WHERE Case__c =: caseRec];  //Start-End: MD-54 03/12/2015 Jason Abolac
        caseSubList = [SELECT Id, Case__c, Subscription__c, Complaint_Copies__c FROM Case_Subscription__c WHERE Case__c IN: caseRec];
    //End: D-4466 15-march-2016 added by Jason A. 
        //END: MD-62 D-2620 03/31/2015 Sherwin Puli
        //MD-62vendor
        caseSubVendorList = getCaseSubVen(caseRec);
        //MD-62vendor
        for(Case_Subscription__c caseSub : caseSubList){
            casesubmap.put(caseSub.Subscription__c, caseSub);   //Start-End: D-4466 15-march-2016 added by Jason A. 
            subIdSet.add(caseSub.Subscription__c);
        //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
            if(caseToSub_MAP.containskey(caseSub.Case__c)){
                caseToSub_MAP.get(caseSub.Case__c).add(caseSub.Subscription__c);
            } else {
                caseToSub_MAP.put(caseSub.Case__c, new List<Id>{caseSub.Subscription__c});
            }
        //END: MD-62 D-2620 03/31/2015 Sherwin Puli
        }
        //MD-62vendor
        for(Case_Vendor_Subscription__c caseVenSub : caseSubVendorList){
            caseVenSubmap.put(caseVenSub.Subscription_Vendor__c, caseVenSub);   //Start-End: D-4466 15-march-2016 added by Jason A. 
            subVenIdSet.add(caseVenSub.Subscription_Vendor__c);
            if(caseVenToSubVen_MAP.containskey(caseVenSub.Case__c)){               
                caseVenToSubVen_MAP.get(caseVenSub.Case__c).add(caseVenSub.Subscription_Vendor__c);
            } else {               
                caseVenToSubVen_MAP.put(caseVenSub.Case__c, new List<Id>{caseVenSub.Subscription_Vendor__c});
            }
        }
        //MD-62vendor
    //Start D-3124 06/18 Added by Jason A.        
    // START : UD-0985 7/8/2015 Alyana Navarro
        // START : UD-2270 8/10/2015 Alyana Navarro
        subscriptionList = [SELECT Id, Name, Subscriber_Contact__c, Recipient_Contact__c, Recipient_Contact__r.FirstName, 
                            Recipient_Contact__r.LastName, Vendor_1__r.Id, Frequency_1__c, Number_of_Copies__c, Vendor_1__r.Email__c, 
                            Vendor_1__r.Handphone_Number__c, Vendor_1__r.Vendor_Communication_Preference__c, //Start-End: MD-54 03/12/2015 Jason Abolac
                            Effective_End_Date__c, Effective_Start_Date__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                            Vendor_Subscription_To_Convert_1__c, Classification__c, Order_Number_1__r.Vendor_Sms_Remarks__c,
                            Recipient_Contact__r.Address__c, Main_Package__c, Ph_d__c, Ph_e__c, Vendor_1__r.Active__c
                            FROM Zuora__Subscription__c 
                            WHERE id IN: subIdSet];
        // END : UD-2270 8/10/2015 Alyana Navarro               
    // END : UD-0985 7/8/2015 Alyana Navarro
    //End D-3124 06/18 Added by Jason A.      
        //MD-62vendor       
        subscriptionVenList = getSubscriptionVendor(subVenIdSet);
        List<Subscription_Vendor_Publication__c> subVenPubList = getSubVenPublication(subVenIdSet);                     
        
        for(Subscription_Vendor__c subVen : subscriptionVenList){
            subscriptionVenMap.put(subVen.id, subVen);
            addressIdSet.add(subVen.Recipient__r.Address__c);
            vendorAccountIdSet.add(subVen.Vendor__r.Id);
            subIdAddIdMap.put(subVen.id, subVen.Recipient__r.Address__c);
        }
        
        for(Subscription_Vendor_Publication__c subVenPub : subVenPubList){
            if(subVenPub.Publication__r.Publication_Code__c != null){
                pubCodeSet.add(subVenPub.Publication__r.Publication_Code__c);
            }
            
            if(subIdPubIdSetMap.containsKey(subVenPub.Subscription_Vendor__c)){
                subIdSubVenListMap.get(subVenPub.Subscription_Vendor__c).add(subVenPub);
                subIdPubIdSetMap.get(subVenPub.Subscription_Vendor__c).add(subVenPub.Publication__r.Publication_Code__c);
            } else {
                subIdSubVenListMap.put(subVenPub.Subscription_Vendor__c, new List<Subscription_Vendor_Publication__c>{subVenPub});
                subIdPubIdSetMap.put(subVenPub.Subscription_Vendor__c, new Set<String>{subVenPub.Publication__r.Publication_Code__c});
            }
        }       
        //MD-62vendor
        for(Zuora__Subscription__c sub : subscriptionList){
            packageIdSet.add(sub.Main_Package__c);         // START-END : UD-0985 7/8/2015 Alyana Navarro              
            subscriptionMap.put(sub.id, sub);
            addressIdSet.add(sub.Recipient_Contact__r.Address__c);
            vendorAccountIdSet.add(sub.Vendor_1__r.Id);
            subIdAddIdMap.put(sub.id, sub.Recipient_Contact__r.Address__c); // START-END : D-1796 2/24/2015 Alyana Navarro
        }
        
        // START : UD-0985 7/8/2015 Alyana Navarro              
        subProdChargeList = [SELECT id, name, Zuora__Subscription__c, PublicationCode__c, Zuora__UOM__c
                             FROM Zuora__SubscriptionProductCharge__c 
                             WHERE Zuora__Subscription__c IN: subIdSet];
                             
        packageLineItemList = [SELECT id, name, Is_All_In_One__c, Package__c FROM Package_Item__c WHERE Package__c IN: packageIdSet];
        
        for(Package_Item__c packageLineItem : packageLineItemList){
            if(packIdPackLineItemMap.containsKey(packageLineItem.Package__c)){
                packIdPackLineItemMap.get(packageLineItem.Package__c).add(packageLineItem);
            } else {
                packIdPackLineItemMap.put(packageLineItem.Package__c, new List<Package_Item__c>{packageLineItem});
            }
        }
        // END : UD-0985 7/8/2015 Alyana Navarro                
        for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){
            if(subIdPubCodeSetMap.containsKey(subProdCharge.Zuora__Subscription__c)){
                subIdPubCodeSetMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge.PublicationCode__c);
            } else {
                subIdPubCodeSetMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{subProdCharge.PublicationCode__c});
            }
        // START : D-1796 2/27/2015 Alyana Navarro
            // START : UD-0985 7/6/2015 Alyana Navarro
            if(subProdCharge.PublicationCode__c != null && (subProdCharge.Zuora__UOM__c == GlobalVariableClass.UOM_COPYWEEKDAY 
                || subProdCharge.Zuora__UOM__c == GlobalVariableClass.UOM_COPYSAT 
                || subProdCharge.Zuora__UOM__c == GlobalVariableClass.UOM_COPYSUN)){
                pubCodeSet.add(subProdCharge.PublicationCode__c);
            }
            // END : UD-0985 7/6/2015 Alyana Navarro
        }               
        // END : D-1796 2/27/2015 Alyana Navarro 
        addressList = [SELECT Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id 
                       FROM Address__c 
                       WHERE Id IN: addressIdSet];
        
        for(Address__c add : addressList){
            singpostIdSet.add(add.Postal_Code__r.id);
            addressMap.put(add.id, add); // START-END : D-1796 2/24/2015 Alyana Navarro
        }
        // START : D-1796 2/27/2015 Alyana Navarro 
        for(Zuora__Subscription__c sub : subscriptionList){
            subIdAddressMap.put(sub.id, addressMap.get(subIdAddIdMap.get(sub.id)));
            singpostIdSubIdMap.put(sub.id, addressMap.get(subIdAddIdMap.get(sub.id)).Postal_Code__r.id);
        }
        // START : MD-62 6/24/2015 Alyana Navarro
        for(Subscription_Vendor__c subVen : subscriptionVenList){
            subIdAddressMap.put(subVen.id, addressMap.get(subIdAddIdMap.get(subVen.id)));
            singpostIdSubIdMap.put(subVen.id, addressMap.get(subIdAddIdMap.get(subVen.id)).Postal_Code__r.id);
        }
        // END : MD-62 6/24/2015 Alyana Navarro
        
        singpostAddressList = [SELECT Id, Name FROM Singpost_Address__c WHERE Id IN: singpostIdSet];
        
        for(Singpost_Address__c singpost : singpostAddressList){
            singpostMap.put(singpost.id, singpost);
        }
        
        for(Zuora__Subscription__c sub : subscriptionList){
            subIdSingpostIdMap.put(sub.id, singpostMap.get(singpostIdSubIdMap.get(sub.id)));
        }
        
        for(Subscription_Vendor__c subVen : subscriptionVenList){
            subIdSingpostIdMap.put(subVen.id, singpostMap.get(singpostIdSubIdMap.get(subVen.id)));
        }
        // END : D-1796 2/27/2015 Alyana Navarro 
        //Start: MD-54 03/12/2015 Jason Abolac
    //Start D-3124 06/18 Added by Jason A.   
    // START : UD-2270 8/10/2015 Alyana Navarro
        vendorStaffList = [SELECT Id, Account.Id, Email, homephone__c, Vendor_Communication_Preference__c, Active__c, Account.Active__c
                           FROM Contact 
                           WHERE Account.Id IN: vendorAccountIdSet 
                                AND Account.Active__c = true
                                AND Active__c = true
                                AND RecordType.id =: vendorStaffRecTypeId
                          ];
                          
        
    //End D-3124 06/18 Added by Jason A.   
        //End: MD-54 03/12/2015 Jason Abolac
        Map<Id, Contact> vendorStaffMap = new Map<Id, Contact>();
        for(Contact venCon : vendorStaffList){
            vendorSftaffIdSet.add(venCon.id);
            vendorStaffMap.put(venCon.id, venCon);
            if(vendorIdVendorStaffListMap.containsKey(venCon.Account.Id)){
                vendorIdVendorStaffListMap.get(venCon.Account.Id).add(venCon);
            } else {
                vendorIdVendorStaffListMap.put(venCon.Account.Id, new List<Contact>{venCon});
            }
        }
        
        partnerUserList = [SELECT Id, Name, Profile.UserLicense.Name, Alias, ContactId 
                           FROM User 
                           WHERE Profile.UserLicense.Name =: GlobalVariableClass.USER_LICENSE 
                                AND ContactId IN: vendorSftaffIdSet 
                                AND isActive = true 
                           ORDER BY Createddate asc];
        
        for(User partnerUser : partnerUserList){
            vendorPartnerUserMap.put(partnerUser.ContactId, partnerUser.id);
            conId_AliasMap.put(vendorStaffMap.get(partnerUser.ContactId).Account.id, partnerUser.Alias);
        }
        // END : UD-2270 8/10/2015 Alyana Navarro
        publicationList = [SELECT id, name, Sunday_Publication__r.Publication_Code__c, Publication_Code__c, Sunday_Publication__c, Published_Days__c         // START-END : UD-0985 7/6/2015 Alyana Navarro
                           FROM Publication__c 
                           WHERE Publication_Code__c IN: pubCodeSet];
        Set<String> groupPub = new Set<String>();
        // START : UD-0985 7/6/2015 Alyana Navarro
        for(Publication__c pub : publicationList){
            isExisting = false; // START-END : D-1796 2/24/2015 Alyana Navarro
            if(!pubCodeParentPubMap.containsKey(pub.Publication_Code__c)){
                for(String key : pubCodeParentPubMap.keySet()){
                    if(pubCodeParentPubMap.get(key) != null){
                        if(pubCodeParentPubMap.get(key) == pub.Publication_Code__c){
                            isExisting = true;
                        } else if(pubCodeParentPubMap.get(key) == pub.Sunday_Publication__r.Publication_Code__c){
                            isExisting = true;
                        }
                    } else {
                        if(key == pub.Sunday_Publication__r.Publication_Code__c){
                            pubCodeParentPubMap.put(key, pub.Publication_Code__c);
                            groupPub.add(pub + '-' + pub.Publication_Code__c);
                            isExisting = true;
                        }
                    }
                }
                
                if(!isExisting){
                    if(pub.Sunday_Publication__c != null){
                        pubCodeParentPubMap.put(pub.Publication_Code__c, pub.Sunday_Publication__r.Publication_Code__c);
                        groupPub.add(pub.Publication_Code__c + '-' + pub.Sunday_Publication__r.Publication_Code__c);
                    } else {
                        pubCodeParentPubMap.put(pub.Publication_Code__c, null);
                    }
                }
            }
            
            publicationMap.put(pub.Publication_Code__c, pub);
        }       
        // END : UD-0985 7/6/2015 Alyana Navarro
        /*
        sundayPubList = [SELECT id, name, Publication_Code__c, Sunday_Publication__r.Publication_Code__c 
                         FROM Publication__c 
                         WHERE Publication_Code__c IN: sunPubSet];
        
        for(Publication__c pub : sundayPubList){
            if(pub.Publication_Code__c != null || pub.Publication_Code__c != 'null'){
                publicationMap.put(pub.Publication_Code__c, pub);
            }
        }*/
    }
    // START : MD-62 6/24/2015 Alyana Navarro
    
    // START : UD-1987 7/24/2015 Alyana Navarro
    // START : UD-0985 7/8/2015 Alyana Navarro
    //Start: D-4466 15-march-2016 added by Jason A. 
    public static String groupPubPerSub(Id subId, Set<String> pubCodeSet, String frequency, String complaintCopies, Boolean isDirect){ //Start-End: MD-54 03/12/2015 Jason Abolac
        String sub = ''; 
        string numberOfCopies = '';
        for(String pubCode : pubCodeSet){
            if(pubCodeParentPubMap.containsKey(pubCode)){
                if(pubCodeParentPubMap.get(pubCode) != null){
                    if(isDirect){                       
                        if(subscriptionMap.containsKey(subId)){
                            numberOfCopies = getNumberOfCopies(subscriptionMap.get(subId), new Set<String>{pubcode,  pubCodeParentPubMap.get(pubCode)}, complaintCopies);                            
                            if(frequency == GlobalVariableClass.FREQUENCY_DEFAULT || frequency == GlobalVariableClass.SUB_FREQUENCY_FRISUN || frequency == GlobalVariableClass.SUB_FREQUENCY_SATSUN){
                                if(frequency == GlobalVariableClass.FREQUENCY_DEFAULT){
                                    frequency = getFrequency(numberOfCopies, complaintCopies);
                                }
                                sub += pubCode + '/' + pubCodeParentPubMap.get(pubCode);
                                sub += ' (' + frequency + '>' + numberOfCopies + ') ';
                            } else if(frequency == GlobalVariableClass.SUB_FREQUENCY_MONFRI || frequency == GlobalVariableClass.FREQUENCY_MONSAT){                              
                                sub += pubCode;
                                sub += ' (' + frequency + '>' + numberOfCopies + ') ';                              
                            }
                        }
                    } else {
                        if(subscriptionVenMap.containsKey(subId)){
                            Subscription_Vendor__c subVenSub = subscriptionVenMap.get(subId);
                            if(subIdPubIdSetMap.containsKey(subId)){
                                if(isSundayPub){
                                    sub += pubCode + '/' + pubCodeParentPubMap.get(pubCode);
                                    sub += ' (' + frequency + '>' + complaintCopies + ') ';
                                } else {
                                    sub += pubCode;
                                    sub += ' (' + frequency + '>' + complaintCopies + ') ';
                                }
                            }
                        }
                    }
                } else {
                    if(isDirect){
                        numberOfCopies = getNumberOfCopies(subscriptionMap.get(subId), new Set<String>{pubcode}, complaintCopies);
                        if(subscriptionMap.containsKey(subId)){
                            if(frequency == GlobalVariableClass.FREQUENCY_DEFAULT){                         
                                frequency = getFrequency(numberOfCopies, complaintCopies);
                            }
                        }
                        complaintCopies = numberOfCopies;
                    }                   
                    sub += pubCode;
                    sub += ' (' + frequency + '>' + complaintCopies + ') ';
                }
            }
        }
    //End: D-4466 15-march-2016 added by Jason A.         
        return sub;
    }
    // END : UD-0985 7/8/2015 Alyana Navarro
    public static String getFrequency(String binaryFreq, string numOfCopies){   //Start-End: D-4466 15-march-2016 added by Jason A. 
        String frequency = '';
        String defaultFrequency = binaryFreq.replace(String.valueOf(numOfCopies), 'Y');
        defaultFrequency = defaultFrequency.replace('0', 'N');
        defaultFrequency = defaultFrequency.substring(0, defaultFrequency.length() - 2);        
        
        // START : D-3492 9/5/2015 Alyana Navarro
        if(defaultFrequency == GlobalVariableClass.FREQ_FRISUN_DAYS){
            frequency = GlobalVariableClass.SUB_FREQUENCY_FRISUN;
        } else if(defaultFrequency == GlobalVariableClass.FREQ_SATSUN_DAYS){
            frequency = GlobalVariableClass.SUB_FREQUENCY_SATSUN;
        } else if(defaultFrequency == GlobalVariableClass.FREQ_MONFRI_DAYS){
            frequency = GlobalVariableClass.SUB_FREQUENCY_MONFRI;
        } else if(defaultFrequency == GlobalVariableClass.FREQ_MONSAT_DAYS){
            frequency = GlobalVariableClass.FREQUENCY_MONSAT;
        } else if(defaultFrequency == 'YYYYYYY'){
            frequency = 'Daily';
        }
        // END : D-3492 9/5/2015 Alyana Navarro
        
        return frequency;
    }
    
    // START : UD-0985 7/8/2015 Alyana Navarro
    public static Integer mon, tue, wed, thu, fri, sat, sun, pHd, pHe;
    public static Boolean isSundayPub;
    public static String getNumberOfCopies(Zuora__Subscription__c subscription, Set<String> pubCodeSet, string numberOfCopies){     //Start-End: D-4466 15-march-2016 added by Jason A. 
        Boolean isAllInOne = false;
        String frequencyValue = '';
        String finalFrequencyValue = '';
        String pheLocal = '0';
        String phdLocal = '0';
        Publication__c publication = new Publication__c();
        
        if(subscription.Ph_d__c){
            phdLocal = String.valueOf(numberOfCopies);  //Start-End: D-4466 15-march-2016 added by Jason A. 
        }
        
        if(subscription.Ph_e__c){
            pheLocal = String.valueOf(numberOfCopies);  //Start-End: D-4466 15-march-2016 added by Jason A. 
        }
        //START 07/13/2015 UD-1849 removed by Jason A./Alyana N.
        /*if(packIdPackLineItemMap.containsKey(subscription.Main_Package__c)){
            for(Package_Item__c packLineItem : packIdPackLineItemMap.get(subscription.Main_Package__c)){
                if(packLineItem.Is_All_In_One__c){
                    isAllInOne = true;
                }
            }
        }*/
        
        //if(isAllInOne){
        //    finalFrequencyValue = String.valueOf(subscription.Number_of_Copies__c);
        //} else {
    //Start: D-4466 15-march-2016 added by Jason A. 
            if(subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_FRISUN){
                finalFrequencyValue = GlobalVariableClass.FREQ_FRISUN_BIN.replace('1', String.valueOf(numberOfCopies)) + phdLocal + pheLocal;
            } else if(subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_SATSUN){
                finalFrequencyValue = GlobalVariableClass.FREQ_SATSUN_BIN.replace('1', String.valueOf(numberOfCopies)) + phdLocal + pheLocal;
            } else if(subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_MONFRI){
                finalFrequencyValue = GlobalVariableClass.FREQ_MONFRI_BIN.replace('1', String.valueOf(numberOfCopies)) + phdLocal + pheLocal;
            } else if(subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_MONSAT){
                finalFrequencyValue = GlobalVariableClass.FREQ_MONSAT_BIN.replace('1', String.valueOf(numberOfCopies)) + phdLocal + pheLocal;
            } else if(subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_DEFAULT){                
                for(String pubCode : pubCodeSet){
                    if(publicationMap.containsKey(pubCode)){
                        publication = publicationMap.get(pubCode);
                        if(frequencyValue == ''){
                            frequencyValue = publication.Published_Days__c.replace('Y', String.valueOf(numberOfCopies));
                            frequencyValue = frequencyValue.replace('N', '0');
                        } else {
                            String tempFreq = publication.Published_Days__c.replace('Y', String.valueOf(numberOfCopies));
                            tempFreq = tempFreq.replace('N', '0');                              
                            
                            for(Integer counter = 0; counter <  frequencyValue.length(); counter++){
                                if(frequencyValue.substring(counter, counter+1) == String.valueOf(numberOfCopies) || tempFreq.substring(counter, counter+1) == String.valueOf(numberOfCopies)){
                                    if(counter == 0){
                                        finalFrequencyValue = String.valueOf(numberOfCopies);
                                    } else {
                                        finalFrequencyValue += String.valueOf(numberOfCopies);
                                    }
                                } else {
                                    if(counter == 0){
                                        finalFrequencyValue = '0';
                                    } else {
                                        finalFrequencyValue += '0';
                                    }
                                }
                            }
                        }
                    }
    //End: D-4466 15-march-2016 added by Jason A. 
                    // START : D-3492 9/5/2015 Alyana Navarro
                    if(pubCodeSet.size() == 1){
                        finalFrequencyValue = frequencyValue;
                    }
                    // END : D-3492 9/5/2015 Alyana Navarro
                }
                finalFrequencyValue += phdLocal + pheLocal;
            }
        //}
        //END 07/13/2015 UD-1849 removed by Jason A./Alyana N.
        return finalFrequencyValue;
    }   
    // END : UD-0985 7/8/2015 Alyana Navarro
    // END : UD-1987 7/24/2015 Alyana Navarro
    public static String getSubVenFrequency(){
        String frequencyDay = '';               
        Boolean daily = true;
        isSundayPub = false; // START-END : UD-0985 7/8/2015 Alyana Navarro
        if(mon != 0){
            frequencyDay = 'Mon/';
        } else {
            daily= false;
        }

        if(tue != 0){
            frequencyDay += 'Tue/';
        } else {
            daily= false;
        }

        if(wed != 0){
            frequencyDay += 'Wed/';
        } else {
            daily = false;
        }

        if(thu != 0){
            frequencyDay += 'Thu/';
        } else {
            daily = false;
        }

        if(fri != 0){
            frequencyDay += 'Fri/';
        } else {
            daily = false;
        }

        if(sat != 0){
            frequencyDay += 'Sat/';
        } else {
            daily = false;
        }

        if(sun != 0){
            frequencyDay += 'Sun/';
            isSundayPub = true; // START-END : UD-0985 7/8/2015 Alyana Navarro
        } else {
            daily = false;
        }

        if(daily) {
            frequencyDay = 'Daily';
        } else{
            frequencyDay = frequencyDay.left(frequencyDay.length() -1);
        }
        
        return frequencyDay;
    }   
    //Start: D-4466 15-march-2016 added by Jason A. 
    public static String getSubVenCopies(List<Subscription_Vendor_Publication__c> subVenPubList, integer numberVenOfCopies){
        String copies = '';
        mon = 0;
        tue = 0;
        wed = 0;
        thu = 0;
        fri = 0;
        sat = 0;
        sun = 0;
        pHe = 0;
        pHd = 0;
        Map<String, String> copiesPerDayMap = new Map<String, String>();
        
        for(Subscription_Vendor_Publication__c subVenPub : subVenPubList){
            if(subVenPub.Publication__c != null){
                if (subVenPub.Mon__c != null && subVenPub.Mon__c != 0) {
                    mon += numberVenOfCopies;
                }
                if (subVenPub.Tue__c != null && subVenPub.Tue__c != 0) {
                    tue += numberVenOfCopies;
                }
                if (subVenPub.Wed__c != null && subVenPub.Wed__c != 0) {
                    wed += numberVenOfCopies;
                }
                if (subVenPub.Thu__c != null && subVenPub.Thu__c != 0) {
                    thu += numberVenOfCopies;
                }
                if (subVenPub.Fri__c != null && subVenPub.Fri__c != 0) {
                    fri+= numberVenOfCopies;
                }
                if (subVenPub.Sat__c != null && subVenPub.Sat__c != 0) {
                    sat += numberVenOfCopies;
                }
                if (subVenPub.Sun__c != null && subVenPub.Sun__c != 0) {
                    sun+= numberVenOfCopies;
                }
                if (subVenPub.PHd__c != null && subVenPub.PHd__c != 0) {
                    pHd += numberVenOfCopies;
                }
                if (subVenPub.PHe__c != null && subVenPub.PHe__c != 0) {
                    pHe += numberVenOfCopies;
                }
            }
        }

        copies = String.valueOf(mon) + String.valueOf(tue) + String.valueOf(wed) + String.valueOf(thu) + String.valueOf(fri) 
                    + String.valueOf(sat) + String.valueOf(sun) + String.valueOf(pHd) + String.valueOf(pHe);
        system.debug('>>>>>gold2' + copies);
        return copies;
    //End: D-4466 15-march-2016 added by Jason A.         
    }
        
    public static List<Publication__c> getPublications(Set<Id> pubIdSet){
        List<Publication__c> publicationList = new List<Publication__c>();
        
        publicationList = [SELECT id, name, Publication_Code__c, Sunday_Publication__c FROM Publication__c WHERE Id IN: pubIdSet];
        
        return publicationList;
    }
    
    public static List<Case_Vendor_Subscription__c> getCaseSubVen(Set<Id> caseIdSet){
        List<Case_Vendor_Subscription__c> caseSubVenList = new List<Case_Vendor_Subscription__c>();
        caseSubVenList = [SELECT Id, Case__c, Subscription_Vendor__c, Complaint_Copies__c From Case_Vendor_Subscription__c Where Case__c IN: caseIdSet];    //Start-End: D-4466 15-march-2016 added by Jason A. 
        
        return caseSubVenList;
    }
    // START : UD-2270 8/10/2015 Alyana Navarro
    public static List<Subscription_Vendor__c> getSubscriptionVendor(Set<Id> subVenIdSet){
        List<Subscription_Vendor__c> subscriptionVendorList = new List<Subscription_Vendor__c>();
        subscriptionVendorList = [SELECT Id, Name, Vendor__c, Vendor__r.Id, Vendor__r.Handphone_Number__c, 
                                  Vendor__r.Vendor_Communication_Preference__c, Recipient__c, Recipient__r.FirstName, Recipient__r.LastName,
                                  Recipient__r.Address__c, Vendor__r.Email__c, Order_Number__r.Vendor_Sms_Remarks__c, Vendor__r.Active__c
                                  FROM Subscription_Vendor__c 
                                  WHERE id IN: subVenIdSet];
     // END : UD-2270 8/10/2015 Alyana Navarro   
        return subscriptionVendorList;      
    }
    
    public static List<Subscription_Vendor_Publication__c> getSubVenPublication(Set<Id> subVenIdSet){
        List<Subscription_Vendor_Publication__c> subVenPublicationList = new List<Subscription_Vendor_Publication__c>();
        
        subVenPublicationList = [SELECT id, name, Publication__c, Publication__r.Publication_Code__c, Subscription_Vendor__c, 
                                 Publication__r.Sunday_Publication__c, Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c                            
                                 FROM Subscription_Vendor_Publication__c 
                                 WHERE Subscription_Vendor__c IN: subVenIdSet];
        
        return subVenPublicationList;
    }
    // END : MD-62 6/24/2015 Alyana Navarro
    
    //Start: MD-54 03/12/2015 Jason Abolac
    @Future(callout=true)  
    //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
    public static void createEmail(Set<Id> caseid_SET){
        String smsoutput;
        caserec_LIST = [Select Sub_Category__c from Case where ID IN :caseid_SET];
        getDetails(caseid_SET);
    //END: MD-62 D-2620 03/31/2015 Sherwin Puli
    //End: MD-54 03/12/2015 Jason Abolac
        String sub = '';
        String issueDate = ''; // START-END : D-1796 2/24/2015 Alyana Navarro
        String transactionName = GlobalVariableClass.COMPLAINT_TRANSACTION_NAME;
        String classification = ''; // START-END : D-1796 2/27/2015 Alyana Navarro 
        Set<String> toAddressesSet = new Set<String>();
        // START : UD-2270 8/10/2015 Alyana Navarro - Remove commented out lines of code
        //List<String> toAddresses = new List<String>(); 
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mailRec = new Messaging.SingleEmailMessage();
        // START : D-1796 2/27/2015 Alyana Navarro 
        //START D-1983 02/06/2015 MBG
        Set<Id> vendorIdset = new Set<Id>();
        /*if(subscriptionList != null && subscriptionList.size()>0){
            for(Zuora__Subscription__c zSub:subscriptionList){
                vendorIdset.add(zSub.Vendor_1__r.Id);
            }
        }
        Map<Id,Id> vendorStaffContactIdMAP = new Map<Id,Id>();
        Map<Id, String> conId_AliasMap = new Map<Id, String>();
        if(vendorIdset!=null && vendorIdset.size()>0){
            //Start D-3124 06/18 Added by Jason A.   
            List<Contact> vendStaffList = [Select Id, Name, RecordType.Name, Vendor_Communication_Preference__c, AccountId From Contact Where AccountId IN :vendorIdset AND RecordType.Name = :GlobalVariableClass.VENDOR_STAFF];
            //End D-3124 06/18 Added by Jason A.
            if(vendStaffList!=null &&vendStaffList.size()>0){
                for(Contact c : vendStaffList){
                    vendorStaffContactIdMAP.put(c.Id,c.AccountId);
                }
            }
            List<User> userList = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE AND ContactId IN :vendorStaffContactIdMAP.keyset()];
            
            if(userList!=null && userList.size()>0){
                for(User u : userList){
                    conId_AliasMap.put(vendorStaffContactIdMAP.get(u.ContactId), u.Alias);
                } 
            }
        }*/

        //END D-1983 02/06/2015 MBG
        // END : D-1796 2/27/2015 Alyana Navarro 
        // START : D-1796 2/27/2015 Alyana Navarro
    //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
        for(Case c : caseRecord){       
            List<Id> subIdList = new List<Id>();            
            /*if(c.Account.RecordType.Name == 'Direct Corporate' || c.Account.RecordType.Name == 'Direct Individual' 
               || c.Account.RecordType.Name == 'Direct SPH Inter-Division'){
                classification = 'Direct Sub';
            } else if(c.Account.RecordType.Name == 'Vendor' || c.Account.RecordType.Name == 'Vendor Subscriber'){
                classification = 'Vendor Sub';
            }*/
            // END : D-1796 2/27/2015 Alyana Navarro
            // START : D-1796 2/27/2015 Alyana Navarro 
            
            system.debug('caseToSub_MAP>>'+caseToSub_MAP);
            system.debug('subscriptionMap>>'+subscriptionMap);
            
            if(caseToSub_MAP.containsKey(c.Id)){
                subIdList.addAll(caseToSub_MAP.get(c.id));
            }
            
            if(caseVenToSubVen_MAP.containsKey(c.id)){
                subIdList.addAll(caseVenToSubVen_MAP.get(c.id));
            }
            
            for(Id subId : subIdList){
                //for(Zuora__Subscription__c subscription : subscriptionMap.get(subId)){
                mailRec = new Messaging.SingleEmailMessage();
                mailRec = composeEmail(c, subId, conId_AliasMap);                                           
                
                if(toAddresses != null && toAddresses.size() > 0 && mailRec != null){ // START-END : UD-0985 7/8/2015 Alyana Navarro
                    mailList.add(mailRec);
                }
                //}
            }
            
            /*for(Id subId : caseToSub_MAP.get(c.Id)){
                
                Zuora__Subscription__c subscription = new Zuora__Subscription__c();
                subscription = subscriptionMap.get(subId);
    //END: MD-62 D-2620 03/31/2015 Sherwin Puli
                Address__c addressRec = subIdAddressMap.get(subscription.id);
                
                mail = new Messaging.SingleEmailMessage();          
            //Start: MD-62 D-2620 03/31/2015 Sherwin Puli        
                    //mail.setSubject('Case:' + c.CaseNumber + ' Subscription:' + subscription.Name);
                    //END: MD-62 D-2620 03/31/2015 Sherwin Puli
                if(vendorIdVendorStaffListMap.containsKey(subscription.Vendor_1__r.id)){
                    for(Contact venCon : vendorIdVendorStaffListMap.get(subscription.Vendor_1__r.id)){
        //Start D-3124 06/18 Added by Jason A.   
                        if(subscription.Vendor_1__r.Vendor_Communication_Preference__c != GlobalVariableClass.SMS_Preference){
                            toAddresses.add(venCon.Email);
                        }
                        //Start: MD-54 03/12/2015 Jason Abolac
                        if(venCon.Homephone__c != null){
                            if(venCon.Vendor_Communication_Preference__c != GlobalVariableClass.Email_Preference){
                                mobileNumberList.add(venCon.Homephone__c);
                            }
                        }
                    }                               
                }
                    
                    
                    if(subscription.Vendor_1__r.Vendor_Communication_Preference__c != GlobalVariableClass.SMS_Preference){
                        toAddresses.add(subscription.Vendor_1__r.Email__c);
                    }
                    if(subscription.Vendor_1__r.Handphone_Number__c != null){
                        if(subscription.Vendor_1__r.Vendor_Communication_Preference__c != GlobalVariableClass.Email_Preference){
                            mobileNumberList.add(subscription.Vendor_1__r.Handphone_Number__c);
                            system.debug('mobileNumberList : ' + mobileNumberList);
                        }
        //End D-3124 06/18 Added by Jason A.   
                    }
                        //End: MD-54 03/12/2015 Jason Abolac
                system.debug('toAddresses : ' + toAddresses);
                
                mail.setToAddresses(toAddresses);
                
                String output = ''; 
                smsoutput = '';  //Start-End: MD-54 03/12/2015 Jason Abolac
                Integer listSize = subIdPubCodeSetMap.get(subscription.id).size();
                Integer counter = 0;            
                // START : UD-0985 7/8/2015 Alyana Navarro          
                sub = groupPubPerSub(subscription.id, subIdPubCodeSetMap.get(subscription.id), String.valueOf(subscription.Frequency_1__c), String.valueOf(subscription.Number_of_Copies__c), true);                        
                // END : UD-0985 7/8/2015 Alyana Navarro
                //START D-1983 02/06/2015 MBG
                if(subscription.Vendor_1__c != null && conId_AliasMap.get(subscription.Vendor_1__r.Id)!=null)
                {
                    output += conId_AliasMap.get(subscription.Vendor_1__r.Id)+' ';
                    smsoutput += conId_AliasMap.get(subscription.Vendor_1__r.Id)+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                //END D-1983 02/06/2015 MBG
                if(issueDate != null){
        //Start D-3123 06/22 Jason A.
                        issueDate = convertDateToString((c.CreatedDate).date());
        //End D-3123 06/22 Jason A.
                    issueDate.replace(' 00:00:00','');
                    output += issueDate+' ';
                    smsoutput += issueDate+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                if (transactionName != null && transactionName != 'null'){
                    output += transactionName;
                    smsoutput += transactionName;  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
            //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
                if(c.Sub_Category__c != null && c.Sub_Category__c != 'null'){
                    output += ' - ' + c.Sub_Category__c;
                    smsoutput += ' - ' + c.Sub_Category__c;  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
            //END: MD-62 D-2620 03/31/2015 Sherwin Puli
                if (sub != null && sub != 'null'){
                    output +=  '</br>' + sub +'</br>'+' @';
                    smsoutput +=  ' ' + sub +' '+' @';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                if (addressRec.Block_House_Number__c != null){
                    output += string.valueOf(addressRec.Block_House_Number__c)+' ';
                    smsoutput += string.valueOf(addressRec.Block_House_Number__c)+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                if (addressRec.Street_Name__c != null){
                    output += addressRec.Street_Name__c+' ';
                    smsoutput += addressRec.Street_Name__c+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                if (addressRec.Building_Name__c != null){
                    output += addressRec.Building_Name__c+' ';
                    smsoutput += addressRec.Building_Name__c+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                
                if (addressRec.Level_Number__c != null){
                output += '#' + string.valueOf(addressRec.Level_Number__c) + '-'; // START-END : UD-0985 7/8/2015 Alyana Navarro
                    smsoutput += '#' +string.valueOf(addressRec.Level_Number__c)+'-';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                
                if (addressRec.Unit_Number__c != null){
                    output += string.valueOf(addressRec.Unit_Number__c)+' ';
                    smsoutput += string.valueOf(addressRec.Unit_Number__c)+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                // START : UD-0985 7/8/2015 Alyana Navarro - Remove
                /*if(subIdSingpostIdMap.containsKey(subscription.id)){
                    if(subIdSingpostIdMap.get(subscription.id).Name != null && subIdSingpostIdMap.get(subscription.id).Name != ''){
                        output += subIdSingpostIdMap.get(subscription.id).Name;
                        smsoutput += subIdSingpostIdMap.get(subscription.id).Name;  //Start-End: MD-54 03/12/2015 Jason Abolac
                    }
                }
                // END : UD-0985 7/8/2015 Alyana Navarro - Remove
                if(classification != null && classification != ''){
                    output += ' '+ classification +' ';   
                    smsoutput += ' '+ classification +' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                }
                
                if (subscription.Order_Number_1__r.Vendor_Sms_Remarks__c != null && subscription.Order_Number_1__r.Vendor_Sms_Remarks__c != ''){
                    output += ' Remarks: ' + subscription.Order_Number_1__r.Vendor_Sms_Remarks__c;
                    smsoutput += '(' + subscription.Order_Number_1__r.Vendor_Sms_Remarks__c + ')';  //Start-End: MD-54 03/12/2015 Jason Abolac
                
                }
                            
                smsMessage = EncodingUtil.urlEncode(smsoutput, 'UTF-8');   //Start-End: MD-54 03/12/2015 Jason Abolac
                smsMessage = smsmessage.replaceall('%40', '\u0040'); //Start-End: MD-54 03/12/2015 Jason Abolac
                mail.setHtmlBody(output);
                system.debug('output'+output);
                
                if(toAddresses != null && toAddresses.size() > 0 && sub != ''){ // START-END : UD-0985 7/8/2015 Alyana Navarro
                    mailList.add(mail);
                }//Start/END: MD-62 D-2620 03/31/2015 Sherwin Puli
            }*/
        }
    // END : D-1796 2/27/2015 Alyana Navarro 
        
       /* try{
        //Start: MD-54 03/12/2015 Jason Abolac
            for(String mobNum : mobileNumberList){
                mobileNumber = mobNum;
                CalloutSMSResponse();
            }
        }
        catch(Exception s){
            system.debug('Error callout : ' + s);
        }*/             
        try {           
            insert taskList;        
        } catch(Exception e){
            system.debug('Error encountered : ' + e);
        }
        
        // END : UD-2270 8/10/2015 Alyana Navarro
        try{            
            Messaging.sendEmail(mailList);
            system.debug('maillist2'+maillist);
        }
        catch(Exception e){
            system.debug('Error : ' + e);
        }
    }
    // START : UD-2270 8/10/2015 Alyana Navarro
    public static List<Task> createTask(Case caseRec, List<Contact> vendorStaffList, String output){
        Task task;
        List<Task> localTaskList = new List<Task>();                
        
        for(Contact venStaff : vendorStaffList){
            if(venStaff.Active__c){
                if(vendorPartnerUserMap.containsKey(venStaff.Id)){              
                    if(vendorPartnerUserMap.get(venStaff.Id) != null) {                 
                        task = new Task();
                        task.OwnerId = vendorPartnerUserMap.get(venStaff.Id);                   
                        task.WhatId = caseRec.Id;
                        task.WhoId = venStaff.id;
                        task.Description = output;                  
                        task.ActivityDate = Date.today();
                        task.subject = 'Notification (' + caseRec.RecordType.Name + ')';
                        task.Status = 'Open';
                        localTaskList.add(task);
                        //system.assertEquals(localTaskList + '', ' ');
                    }
                }
            }
        }
        
        return localTaskList;
    }
    // END : UD-2270 8/10/2015 Alyana Navarro
    public static String convertDateToString(Date dateValue)
        //End: MD-54 03/12/2015 Jason Abolac
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
    //Start: MD-54 03/12/2015 Jason Abolac
    public static Void CalloutSMSResponse() {
  
        Http h = new Http();
        
        String Username = ConstantsSLB.getSMSIntegrationGateway('SMS Commzgate').SMS_Gateway_ID__c;
        system.debug('Username'+Username);
        String Password = ConstantsSLB.getSMSIntegrationGateway('SMS Commzgate').SMS_Password__c;
        system.debug('Password'+Password);
        //Start D-3124 06/18 Added by Jason A.
        String MobileNo= ConstantsSLB.getSMSIntegrationGateway('SMS Commzgate').SMS_Country_Code__c + mobileNumber;
        //End D-3124 06/18 Added by Jason A.
        //string mobilesize = mobileNumber;
        //String MobileNo= ConstantsSLB.getSMSIntegrationGateway('SMS Commzgate').SMS_Country_Code__c + mobilesize.substring(mobilesize.length()-10,mobilesize.length());   
        system.debug('MobileNo'+MobileNo);
        String Type= ConstantsSLB.getSMSIntegrationGateway('SMS Commzgate').SMS_Type__c;
        system.debug('Type'+Type);
        system.debug('MessageSMS2nd'+smsMessage);
        String Postdata = 'ID=' +Username + '&Password=' +Password + '&Mobile=' +MobileNo +'&Type=' +Type + '&Message=' + smsMessage;
        //EncodingUtil.urlEncode(Postdata, 'UTF-8');
        system.debug('Postdata'+Postdata);
        

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ConstantsSLB.getSMSIntegrationGateway('SMS Commzgate').SMS_Gateway_URL__c + postdata);
        req.setMethod('POST');
        req.setBody('');
        system.debug('postdata'+postdata);
        HttpResponse res = h.send(req);
    }
  //End: MD-54 03/12/2015 Jason Abolac
  //Start: MD-62 D-2620 03/31/2015 Sherwin Puli
    public static void createEmailNotFuture(Set<Id> caseid_SET){
        //Case caserec = [Select Sub_Category__c from Case where ID = : caseid];
        caserec_LIST = [Select Sub_Category__c from Case where ID IN :caseid_SET];
        //getDetails(caseid);
        getDetails(caseid_SET);
        //End: MD-54 03/12/2015 Jason Abolac                             
        Set<String> toAddressesSet = new Set<String>();        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mailRec = new Messaging.SingleEmailMessage();     
        // START : D-1796 2/27/2015 Alyana Navarro 
        //START D-1983 02/06/2015 MBG
        Set<Id> vendorIdset = new Set<Id>();
    // START : UD-2270 8/10/2015 Alyana Navarro
        /*if(subscriptionList != null && subscriptionList.size()>0){
            for(Zuora__Subscription__c zSub:subscriptionList){
                vendorIdset.add(zSub.Vendor_1__r.Id);
            }
        }
        Map<Id,Id> vendorStaffContactIdMAP = new Map<Id,Id>();
        Map<Id, String> conId_AliasMap = new Map<Id, String>();
        if(vendorIdset!=null && vendorIdset.size()>0){
    //Start D-3124 06/18 Added by Jason A.   
            List<Contact> vendStaffList = [Select Id, Name, RecordType.Name, AccountId, Vendor_Communication_Preference__c From Contact Where AccountId IN :vendorIdset AND RecordType.Name = :GlobalVariableClass.VENDOR_STAFF];
    //End D-3124 06/18 Added by Jason A.           
            if(vendStaffList!=null &&vendStaffList.size()>0){
                for(Contact c : vendStaffList){
                    vendorStaffContactIdMAP.put(c.Id,c.AccountId);
                }
            }
            List<User> userList = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE AND ContactId IN :vendorStaffContactIdMAP.keyset()];
            
            if(userList!=null && userList.size()>0){
                for(User u : userList){
                    conId_AliasMap.put(vendorStaffContactIdMAP.get(u.ContactId), u.Alias);
                }
            }
        }*/
    // END : UD-2270 8/10/2015 Alyana Navarro
        //END D-1983 02/06/2015 MBG
        // END : D-1796 2/27/2015 Alyana Navarro 
        // START : D-1796 2/27/2015 Alyana Navarro
        
        for(Case c : caseRecord){
            List<Id> subIdList = new List<Id>();
            // END : D-1796 2/27/2015 Alyana Navarro
            // START : D-1796 2/27/2015 Alyana Navarro 
            //for(Zuora__Subscription__c subscription : subscriptionList){
            //subscriptionMap
            system.debug('caseToSub_MAP>>'+caseToSub_MAP);
            system.debug('subscriptionMap>>'+subscriptionMap);
            //if(caseToSub_MAP.containskey(c.Id)){
            if(caseToSub_MAP.containsKey(c.Id)){
                subIdList.addAll(caseToSub_MAP.get(c.id));
            }
            
            if(caseVenToSubVen_MAP.containsKey(c.id)){
                subIdList.addAll(caseVenToSubVen_MAP.get(c.id));
            }
            
            for(Id subId : subIdList){
                //for(Zuora__Subscription__c subscription : subscriptionMap.get(subId)){
                mailRec = new Messaging.SingleEmailMessage();
                mailRec = composeEmail(c, subId, conId_AliasMap);
                if(toAddresses != null && toAddresses.size() > 0 && mailRec != null){ // START-END : UD-0985 7/8/2015 Alyana Navarro
                    mailList.add(mailRec);
                }
                //}
            }
        }
        //}
    // END : D-1796 2/27/2015 Alyana Navarro 
        // START : UD-2270 8/10/2015 Alyana Navarro 
        try {           
            insert taskList;        
        } catch(Exception e){
            system.debug('Error encountered : ' + e);
        } 
        // END : UD-2270 8/10/2015 Alyana Navarro   
        try{            
            Messaging.sendEmail(mailList, false);
            system.debug('maillist2'+maillist);
            
        }
        catch(Exception e){
            system.debug('Error : ' + e);
        }
    }
    //END: MD-62 D-2620 03/31/2015 Sherwin Puli
    public static List<String> toAddresses = new List<String>();
    // START : UD-2270 8/10/2015 Alyana Navarro
    public static Messaging.SingleEmailMessage composeEmail(Case caseRec, Id subId, Map<Id, String> conId_AliasParamMap){
    // END : UD-2270 8/10/2015 Alyana Navarro
        sObject subscription;
        String sub = '';
        String issueDate = '';
        String classification = '';
        String transactionName = GlobalVariableClass.COMPLAINT_TRANSACTION_NAME;
        Account vendorRec;
        Order__c orderRec;
        mobileNumberList = new List<String>();
        if(subscriptionMap.containsKey(subId)){
            subscription = subscriptionMap.get(subId);
        } else if(subscriptionVenMap.containsKey(subId)){
            subscription = subscriptionVenMap.get(subId);
        }
        
        if(subscription instanceof Zuora__Subscription__c){
            vendorRec = ((Zuora__Subscription__c) subscription).Vendor_1__r;
            orderRec = ((Zuora__Subscription__c) subscription).Order_Number_1__r;
        } else if(subscription instanceof Subscription_Vendor__c){
            vendorRec = ((Subscription_Vendor__c) subscription).Vendor__r;
            orderRec = ((Subscription_Vendor__c) subscription).Order_Number__r;
        }
        
        if(caseRec.Account.RecordType.Name == 'Direct Corporate' || caseRec.Account.RecordType.Name == 'Direct Individual' 
           || caseRec.Account.RecordType.Name == 'Direct SPH Inter-Division'){
            classification = 'Direct Sub';
        } else if(caseRec.Account.RecordType.Name == 'Vendor' || caseRec.Account.RecordType.Name == 'Vendor Subscriber'){
            classification = 'Vendor Sub';
        }
        
        Address__c addressRec = subIdAddressMap.get(subscription.id);
 //Start D-3124 06/18 Added by Jason A.       
        toAddresses = new List<String>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();          
        mail.setSubject('Case:' + caseRec.CaseNumber + ' Subscription:' + subscription.get('Name'));
    // START : UD-2270 8/10/2015 Alyana Navarro
        if(vendorIdVendorStaffListMap.containsKey(vendorRec.id)){
            for(Contact venCon : vendorIdVendorStaffListMap.get(vendorRec.id)){
                if(venCon.Vendor_Communication_Preference__c != GlobalVariableClass.SMS_Preference && venCon.Active__c){
                    toAddresses.add(venCon.Email);
                }
                //Start: MD-54 03/12/2015 Jason Abolac
                if(venCon.Homephone__c != null){
                    if(venCon.Vendor_Communication_Preference__c != GlobalVariableClass.Email_Preference && venCon.Active__c){
                        mobileNumberList.add(venCon.Homephone__c);
                    }
                }
            }                               
        }
                
        if(vendorRec.Vendor_Communication_Preference__c != GlobalVariableClass.SMS_Preference && vendorRec.Active__c){
            toAddresses.add(vendorRec.Email__c);
        }

        if(vendorRec.Handphone_Number__c != null){
            if(vendorRec.Vendor_Communication_Preference__c != GlobalVariableClass.Email_Preference && vendorRec.Active__c){
                mobileNumberList.add(vendorRec.Handphone_Number__c);
                system.debug('mobileNumberList : ' + mobileNumberList);
            }
        }
    // END : UD-2270 8/10/2015 Alyana Navarro
//End D-3124 06/18 Added by Jason A.   
                //End: MD-54 03/12/2015 Jason Abolac
        system.debug('toAddresses : ' + toAddresses);
        
        mail.setToAddresses(toAddresses);
        
        String output = ''; 
        String smsoutput = '';  //Start-End: MD-54 03/12/2015 Jason Abolac
        if(subscription instanceof Zuora__Subscription__c){
            if(subIdPubCodeSetMap.containskey(subscription.id)){                
        // START : UD-0985 7/8/2015 Alyana Navarro             
                sub = groupPubPerSub(subscription.id, subIdPubCodeSetMap.get(subscription.Id), String.valueOf(subscription.get('Frequency_1__c')), String.valueOf(caseSubMap.get(subscription.id).Complaint_Copies__c), true); //Start-END: D-4466 15-march-2016 added by Jason A. 
            }           
        } else if(subscription instanceof Subscription_Vendor__c){      
            String copies = getSubVenCopies(subIdSubVenListMap.get(subscription.id), integer.valueof(caseVenSubmap.get(subscription.id).Complaint_Copies__c));  //Start-End: D-4466 15-march-2016 added by Jason A. 
            String frequency = getSubVenFrequency();
            sub = groupPubPerSub(subscription.id, subIdPubIdSetMap.get(subscription.id), frequency, copies, false);
            // END : UD-0985 7/8/2015 Alyana Navarro
            system.debug('>>>>>gold' + copies);
        }
        /*FOR DELETION
        if(subscription.Recipient_Contact__r.FirstName != null && subscription.Recipient_Contact__r.FirstName != 'null'){
            output += subscription.Recipient_Contact__r.FirstName+' ';
        }       
        if(subscription.Recipient_Contact__r.LastName != null && subscription.Recipient_Contact__r.LastName != 'null'){
            output += subscription.Recipient_Contact__r.LastName+' ';
        }*/
        //START D-1983 02/06/2015 MBG
    // START : UD-2270 8/10/2015 Alyana Navarro
        if(vendorRec != null && conId_AliasParamMap.get(vendorRec.Id)!=null)
        {
            output += conId_AliasParamMap.get(vendorRec.Id)+' ';
            smsoutput += conId_AliasParamMap.get(vendorRec.Id)+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
    // END : UD-2270 8/10/2015 Alyana Navarro
        //END D-1983 02/06/2015 MBG
        if(issueDate != null){
//Start D-3123 06/22 Jason A.
                issueDate = convertDateToString((caseRec.CreatedDate).date());
//End D-3123 06/22 Jason A.
            issueDate.replace(' 00:00:00','');
            output += issueDate+' ';
            smsoutput += issueDate+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        if (transactionName != null && transactionName != 'null'){
            output += transactionName;
            smsoutput += transactionName;  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        if(caseRec.Sub_Category__c != null && caseRec.Sub_Category__c != 'null'){
            output += ' - ' + caseRec.Sub_Category__c;
            smsoutput += ' - ' + caseRec.Sub_Category__c;  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        if (sub != null && sub != 'null'){
            output +=  '</br>' + sub +'</br>'+' @';
            smsoutput +=  ' ' + sub +' '+' @';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        if (addressRec.Block_House_Number__c != null){
            output += string.valueOf(addressRec.Block_House_Number__c)+' ';
            smsoutput += string.valueOf(addressRec.Block_House_Number__c)+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        if (addressRec.Street_Name__c != null){
            output += addressRec.Street_Name__c+' ';
            smsoutput += addressRec.Street_Name__c+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        if (addressRec.Building_Name__c != null){
            output += addressRec.Building_Name__c+' ';
            smsoutput += addressRec.Building_Name__c+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        
        if (addressRec.Level_Number__c != null){
            output += '#' + string.valueOf(addressRec.Level_Number__c)+ '-';         // START-END : UD-0985 7/8/2015 Alyana Navarro
            smsoutput += '#' +string.valueOf(addressRec.Level_Number__c)+'-';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        
        if (addressRec.Unit_Number__c != null){
            output += string.valueOf(addressRec.Unit_Number__c)+' ';
            smsoutput += string.valueOf(addressRec.Unit_Number__c)+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        // START : UD-0985 7/8/2015 Alyana Navarro - Remove
        /*if(subIdSingpostIdMap.containsKey(subscription.id)){
            if(subIdSingpostIdMap.get(subscription.id).Name != null && subIdSingpostIdMap.get(subscription.id).Name != ''){
                output += subIdSingpostIdMap.get(subscription.id).Name;
                smsoutput += subIdSingpostIdMap.get(subscription.id).Name;  //Start-End: MD-54 03/12/2015 Jason Abolac
            }
        }*/
        // END : UD-0985 7/8/2015 Alyana Navarro - Remove
        if(classification != null && classification != ''){
            output += ' '+ classification +' ';   
            smsoutput += ' '+ classification +' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
        }
        try{
            if (orderRec.Vendor_Sms_Remarks__c != null && orderRec.Vendor_Sms_Remarks__c != ''){
                output += ' Remarks: ' + orderRec.Vendor_Sms_Remarks__c;
                smsoutput += '(' + orderRec.Vendor_Sms_Remarks__c + ')';  //Start-End: MD-54 03/12/2015 Jason Abolac        
            }
        } catch(Exception e){
            system.debug('Error ' + e);
            system.debug('Vendor_Sms_Remarks__c is null');
        }
        // START : UD-2270 8/10/2015 Alyana Navarro
        if(vendorRec.Active__c){
            taskList.addAll(createTask(caseRec, vendorIdVendorStaffListMap.get(vendorRec.id), smsoutput));
        }
        // END : UD-2270 8/10/2015 Alyana Navarro
        //smsMessage = EncodingUtil.convertToHex(smsoutput);
        smsMessage = EncodingUtil.urlEncode(smsoutput, 'UTF-8');   //Start-End: MD-54 03/12/2015 Jason Abolac
        smsMessage = smsmessage.replaceall('%40', '\u0040'); //Start-End: MD-54 03/12/2015 Jason Abolac
        try{
        //Start: MD-54 03/12/2015 Jason Abolac
            for(String mobNum : mobileNumberList){
                mobileNumber = mobNum;
                system.debug('mobileNumberList  :' + mobileNumberList);
                CalloutSMSResponse();
            }
        }
        catch(Exception s){
            system.debug('Error callout : ' + s);
        }
        mail.setHtmlBody(output);
        system.debug('output'+output);
        system.debug('smsoutput'+smsoutput);
        // START : UD-0985 7/8/2015 Alyana Navarro
        if(sub == ''){
            mail = null;
        }
    // END : UD-0985 7/8/2015 Alyana Navarro    
        return mail;
    }
    
}