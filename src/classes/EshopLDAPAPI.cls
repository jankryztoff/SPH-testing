/**
 * Class Name: ESHOPLDAPAPI
 * @author: Kristine Balaoing
 * Date: 3/17/2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description class to handle ldap tagging for subscriptions
 *
 * History: 04/05/16 D-4612 Kristine Balaoing : Reformat service flags to lower case before callout and
 *change concurrent implementation considering subscription copies
**/
 @RestResource(urlMapping='/EShopLDAPAPI/*')
global with sharing class EshopLDAPAPI{
    
    private static Response resp = new Response();
    public static Map<Id, Zuora__Subscription__c> mapSubToSubRec = new Map<Id, Zuora__Subscription__c>();
    public static Map<Id, Set<String>> mapPckToSVC = new Map<Id, Set<String>>();
    public static Map<Id, List<Asia1_Subscription__c>> mapSubIdToAsia1SubRec = new Map<Id, List<Asia1_Subscription__c>>();
    public static Map<String, Service_Access_Flag__c> mapFlagToSAFRec = new Map<String, Service_Access_Flag__c>();
    public static Map<String, Object> responseResult = new Map<String, Object>();
    public static List<Asia1__c> asia1RecipientContact = new List<Asia1__c>();
    public static Map<Id, Decimal> mapSubToCon = new Map<Id, Decimal>();
    //START: D-4472 3-24-2016 Added by Kristine Balaoing - added map of Sub to map of svc to concurrent
    public static Map<Id, Map<String, Decimal>> mapSubToMapSVCToCon = new Map<Id, Map<String, Decimal>>();
    public static Map<String, Decimal> mapServFlagToCon = new Map<String, Decimal>();
    //END: D-4472 3-24-2016 Added by Kristine Balaoing
    public static Map<String, Decimal> mapSVCToCon = new Map<String, Decimal>();
    public static Map<String, Decimal> mapServiceToConFromAsiaSubs = new Map<String, Decimal>();
    public static Decimal finalCon;
    public static Decimal subCon;
    //START: D-4472 3-24-2016 Added by Kristine Balaoing - added new variable'
    public static Decimal svcCon;
    public static Decimal serviceCon;
    //END: D-4472 3-24-2016 Added by Kristine Balaoing
    //Error Codes 
    public static String EXES0011_Code = 'EXES0011';
    public static String EXES0018_Code = 'EXES0018';
    public static String EXES0019_Code = 'EXES0019';
    public static String EXES0020_Code = 'EXES0020';
    public static String EXES0021_Code = 'EXES0021';
    public static String EXES0022_Code = 'EXES0022';
    public static String EXES0023_Code = 'EXES0023';
    //START: D-4472 3-23-2016 Added by Kristine Balaoing - added variables for existing ldap validations
    public static String EXES0024_Code = 'EXES0024';
    //END: D-4472 3-23-2016 Added by Kristine Balaoing
    //Error Messages
    public static String EXES0011_Value = 'Subscriber subscription combo invalid;';
    public static String EXES0018_Value = '[You have already activated the service.]';
    public static String EXES0019_Value = 'Mandatory Parameter Missing: SubscriberId.';
    public static String EXES0020_Value = 'Mandatory Parameter Missing: AsiaOneLdapId.';
    public static String EXES0021_Value = '[Processing error at Asia one,response code received302]';
    //START: D-4472 3-23-2016 Added by Kristine Balaoing - added variables for existing ldap validations
    public static String EXES0024_Value = 'The provided Ldap Id is already tied to a subscriber in the system.';
    //END: D-4472 3-23-2016 Added by Kristine Balaoing
    
    public static String FAILURE = 'Failure';
    public static String SUCCESS = 'Success';
    public static String FAILED = 'Failed';
    public static String SUBSCRIBER_ID = 'subscriberId';
    public static String ASIAONE_LDAP_ID = 'asiaOneLdapId';
    public static String ACTIVE = 'Active'; 
    public static String PRINT = 'Print';
    public static String printSVC = 'COM';
    public static String ACTIVATE_VALUE = 'Activate';
    public static String DISABLED_VALUE = 'Disabled';
    public static String ENABLED_VALUE = 'Enabled';
    public static String CREATED_VALUE = 'Created';
    public static String DISPLAY_NAME = 'Display Name';
    public static String ERROR = 'Error';
    public static String ERRORS = 'Errors';
    public static String UPDATE_CONCURRENT_CONFIG = 'Update-Concurrent-Config';
    public static String PUBLICATION = 'Publication';
    
    // Start UD-3391 14Mar16 JohnD - set variables to global
    global class Request{
        global String subscriberId;
        global String asiaOneLdapId;
        global List<String> subscriptionIds;
        
    } 

    global class Response{
        global String subscriberId;
        global String asiaOneLdapId;
        global List<String> subscriptionIds;
        global String svc_status;
        global String error_code;
        global String error_message;
    }
    // End UD-3391 14Mar16 JohnD - set variables to global
    
    @httpPOST
    global static Response processRequest(Request reqObj){
        
        Set<Id> subIds = new Set<Id>();
        List<Zuora__Subscription__c> subsToBeProcessed = new List<Zuora__Subscription__c>();
        List<Asia1_Subscription__c> asia1SubsList = new List<Asia1_Subscription__c>();
        List<Asia1_Subscription__c> enabledAsia1List = new List<Asia1_Subscription__c>();
        Map<Id, Set<String>> mapSubsToPubCodes = new Map<Id, Set<String>>();
        Map<String, Boolean> mandatoryFieldChkResult = new Map<String, Boolean>();
        List<Zuora__Subscription__c> zuoraSubList = new List<Zuora__Subscription__c>();
        List<Zuora__SubscriptionProductCharge__c> zSPCs = new List<Zuora__SubscriptionProductCharge__c>();
        List<Publication__c> pubListPrint = new List<Publication__c>();
        List<Publication__c> pubListDigital = new List<Publication__c>();
        List<Package__c> packageList = new List<Package__c>();
        List<Package_Access_Flag__c> pafList = new List<Package_Access_Flag__c>();
        List<Service_Access_Flag__c> safList = new List<Service_Access_Flag__c>();
        //START: D-4472 3-23-2016 Added by Kristine Balaoing - added variables for existing ldap validations
        List<Contact> contactList = new List<Contact>();
        //END: D-4472 3-23-2016 Added by Kristine Balaoing
        List<Contact> recipient = new List<Contact>();
        Set<String> printPubCodes = new Set<String>();
        Set<String> digitalPubCodes = new Set<String>();
        Set<Id> zSubIdsToBeProcessed = new Set<Id>();
        Set<Id> packageSet = new Set<Id>();
        Set<Id> recipientContactSet = new Set<Id>();
        Set<Asia1_Subscription__c> asia1SubsToBeUpdated = new Set<Asia1_Subscription__c>();
        Set<Id> asia1SubsToBeCreated = new Set<Id>();
        Set<String> svcForEnablement = new Set<String>();
        //START: D-4472 3-23-2016 Added by Kristine Balaoing - added variabled for existing ldap validations
        Set<Id> recCOnSet = new Set<Id>();
        //END: D-4472 3-23-2016 Added by Kristine Balaoing - added variabled for existing ldap validations
        Set<Id> hasPrintSubSet = new Set<Id>();
        Set<String> setSAF = new Set<String>();
        Set<Id> recipientIdSet = new Set<Id>();
        Set<Id> oldAsia1 = new Set<Id>();
        //START: D-4472 3-23-2016 Added by Kristine Balaoing - added variabled for existing ldap validations
        Set<String> subNameSet = new Set<String>();
        List<Asia1__c> asiaOneRec = new List<Asia1__c>();
        //END: D-4472 3-23-2016 Added by Kristine Balaoing
        //START: D-4472 3-24-2016 Added by Kristine Balaoing -added variables for subs with no ldap tagging
        Set<Id> subWithAsia1Sub = new Set<Id>();
        //END: D-4472 3-24-2016 Added by Kristine Balaoing
        Asia1__c asiaOneForProcessing;
        Boolean isValid = true;
        Boolean areSubsUnderSubscriberId = true;
        finalCon = 0;
        subCon = 0;
        svcCon = 0;
        serviceCon = 0;
        
        
        
        mandatoryFieldChkResult = checkMandatoryFields(reqObj);
        //System.assertEquals(null, mandatoryFieldChkResult);
        //System.assertEquals(1, 0);
        //areSubsUnderSubscriberId = checkSubscriptionsAccount(reqObj);
        
        if(mandatoryFieldChkResult.containsKey(SUBSCRIBER_ID) && (!mandatoryFieldChkResult.get(SUBSCRIBER_ID))){
            //System.assert(false);
            resp.error_code = EXES0019_Code;
            resp.error_message = EXES0019_Value;
            resp.svc_status = FAILURE; 
                
                //return resp;
        }else if(mandatoryFieldChkResult.containsKey(ASIAONE_LDAP_ID) && (!mandatoryFieldChkResult.get(ASIAONE_LDAP_ID))){
            resp.error_code = EXES0020_Code;
            resp.error_message = EXES0020_Value;
            resp.svc_status = FAILURE;  
        }else{
            //START: D-4472 Retest Failed 3-23-2016 Added by Kristine Balaoing - added validation for existing ldap id in the system
            if(reqObj.asiaOneLdapId != null){
                asiaOneRec = [SELECT Id, User_ID_LDAP_ID__c, Contact__c FROM Asia1__c WHERE User_ID_LDAP_ID__c = :reqObj.asiaOneLdapId];
            }
            
            contactList = [SELECT Id, Name, AccountId, Recipient_Indicator__c FROM Contact 
                            WHERE Account.AccountNumber =:reqObj.subscriberId AND Recipient_Indicator__c = true];
            
            for(Contact con : contactList){
                recCOnSet.add(con.Id);
            }
            //END: D-4472 Retest Failed 3-23-2016 Added by Kristine Balaoing
            if(reqObj != null){
                if(reqObj.subscriberId != null){
                    // Start UD-3391 02Mar16 JohnD - changed zuora__status__c to status_formula__c to allow future stop
                    zuoraSubList =[SELECT Id, name, Zuora__Account__r.Account_Auto_Number__c, Main_Package_1__c, Recipient_Contact__c, Order_Line_Item_Number_1__c 
                                   FROM Zuora__Subscription__c
                                   // START D-4636 - 06Apr2016 - Raviteja Kumar - Adding Future Active in SOQL
                                   //WHERE Zuora__Account__r.AccountNumber = :reqObj.subscriberId AND  Status_Formula__c = :ACTIVE AND Subscription_Type_1__c = :PUBLICATION];
                                   WHERE Zuora__Account__r.AccountNumber = :reqObj.subscriberId AND  ( Status_Formula__c = :ACTIVE OR Status_Formula__c = 'Future Active' )AND Subscription_Type_1__c = :PUBLICATION];
                                   // END D-4636 - 06Apr2016 - Raviteja Kumar
                   // End UD-3391 02Mar16 JohnD - changed zuora__status__c to status_formula__c to allow future stop                
                }
            }
            
            if(zuoraSubList.size()>0){
                for(Zuora__Subscription__c sub: zuoraSubList){
                    subIds.add(sub.Id);
            //START: D-4472 3-23-2016 Added by Kristine Balaoing - added logic for existing ldap validations
            subNameSet.add(sub.Name);
            //END: D-4472 3-23-2016 Added by Kristine Balaoing
                }
            }
            
            //publicationSets
            pubListPrint = [SELECT Id, Publication_Code__c, Platform_Type__c 
                                FROM Publication__c
                                WHERE Platform_Type__c = :PRINT];
                                
            pubListDigital = [SELECT Id, Publication_Code__c, Platform_Type__c 
                                FROM Publication__c
                                WHERE Platform_Type__c != :PRINT]; 
            
            for(Publication__c pubPrint : pubListPrint){
                printPubCodes.add(pubPrint.Publication_Code__c);
            }
            
            for(Publication__c digiPrint : pubListDigital){
                digitalPubCodes.add(digiPrint.Publication_Code__c);
            }
            //System.assertEquals(null, subIds);
            if(reqObj.subscriptionIds.size()>0){
                //START: D-4472 3-23-2016 Added by Kristine Balaoing - added logic for account checking
                areSubsUnderSubscriberId = checkSubscriptionsAccount(subNameSet, reqObj);
                //END: D-4472 3-23-2016 Added by Kristine Balaoing
        }
            
            
            if(!areSubsUnderSubscriberId){
                resp.error_code = EXES0011_Code;
                resp.error_message = EXES0011_Value;
                resp.svc_status = FAILURE;
            //START: D-4472 Retest Failed 3-23-2016 Added by Kristine Balaoing - added validation for existing ldap ids in the system
            }else if(asiaOneRec.size()>0 && (!recCOnSet.contains(asiaOneRec[0].Contact__c))){
                    resp.error_code = EXES0024_Code;
                    resp.error_message = EXES0024_Value;
                    resp.svc_status = FAILURE;
            }else{

                //check if SubsList is null or not
                if(reqObj.subscriptionIds.size()>0){
                    subsToBeProcessed = [SELECT Id, Main_Package_1__c, Order_Line_Item_Number_1__c, Recipient_Contact__c  FROM Zuora__Subscription__c  WHERE Name IN:reqObj.subscriptionIds];
                
                    for(Zuora__Subscription__c zSubParam : subsToBeProcessed){
                        zSubIdsToBeProcessed.add(zSubParam.Id);
                    }
                }else{
                    subsToBeProcessed = zuoraSubList;
                    zSubIdsToBeProcessed = subIds;
                    
                }
                
                zSPCs = [SELECT Id, Zuora__Subscription__c, PublicationCode__c 
                            FROM Zuora__SubscriptionProductCharge__c
                            WHERE Zuora__Subscription__c IN :zSubIdsToBeProcessed];
                
                for(Zuora__SubscriptionProductCharge__c zSPC : zSPCs){
                    if(mapSubsToPubCodes.containsKey(zSPC.Zuora__Subscription__c)){
                        mapSubsToPubCodes.get(zSPC.Zuora__Subscription__c).add(zSPC.PublicationCode__c);
                    }else{
                        mapSubsToPubCodes.put(zSPC.Zuora__Subscription__c, new Set<String>{zSPC.PublicationCode__c});
                    }
                    
                }
                //for print
                for(Id subsId : mapSubsToPubCodes.keySet()){
                    for(String pubCode : mapSubsToPubCodes.get(subsId)){
                        if(printPubCodes.contains(pubCode)){
                           hasPrintSubSet.add(subsId);
                        }
                    }
                }
                for(Zuora__Subscription__c subs : subsToBeProcessed){
                    packageSet.add(subs.Main_Package_1__c);
                    mapSubToSubRec.put(subs.Id, subs);
                    recipientContactSet.add(subs.Recipient_Contact__c);
                }
                
                recipient = [SELECT Id, Email__c FROM Contact WHERE ID IN :recipientContactSet LIMIT 1];
                
                packageList = [SELECT Id, Name FROM Package__c WHERE Id IN:packageSet];  // -- di ko ata to kelangan?
                
                pafList = [SELECT Id, Package__c, Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, No_of_Concurrent_Users__c
                            FROM Package_Access_Flag__c
                            WHERE Package__c IN : packageSet];
                
                for(Package_Access_Flag__c paf : pafList){
                    if(mapPckToSVC.containsKey(paf.Package__c)){
                        mapPckToSVC.get(paf.Package__c).add(paf.Package_Service_Access_Flag__r.Name);
                    }else{
                        mapPckToSVC.put(paf.Package__c, new Set<String>{paf.Package_Service_Access_Flag__r.Name});
                    }
                    mapSVCToCon.put(paf.Package_Service_Access_Flag__r.Name, paf.No_of_Concurrent_Users__c);
                }
                
                for(Id hasPrintSubId : hasPrintSubSet){
                    /*if(mapPckToSVC.containsKey(mapSubToSubRec.get(hasPrintSubId).Main_Package_1__c)){
                        mapPckToSVC.get(mapSubToSubRec.get(hasPrintSubId).Main_Package_1__c).add(printSVC);
                    }else{
                        mapPckToSVC.put(mapSubToSubRec.get(hasPrintSubId).Main_Package_1__c, new Set<String>{printSVC});
                    }*/
                    if(!mapPckToSVC.containsKey(mapSubToSubRec.get(hasPrintSubId).Main_Package_1__c)){
                        mapPckToSVC.put(mapSubToSubRec.get(hasPrintSubId).Main_Package_1__c, new Set<String>{printSVC});
                    }
                }
                
                for(Set<String> strSet : mapPckToSVC.values()){
                    for(String str : strSet){
                        setSAF.add(str);
                    }
                }
                
                safList = [SELECT Id, Name FROM Service_Access_Flag__c WHERE Name IN :setSAF];
                
                for(Service_Access_Flag__c saf : safList){
                    mapFlagToSAFRec.put(saf.Name, saf);
                }
                
                //START: D-4772 3-24-2016 Added by Kristine Balaoing - added additional logic for asia1Subs to be updated and created       
                //check for Asia1Subs
                asia1SubsList = [SELECT Id, Asia1__c, Service_Access_Flag__c, Subscription__c, Concurrent__c, Asia1__r.User_ID_LDAP_ID__c,          Service_Access_Flag__r.Name
                                    FROM Asia1_Subscription__c
                                    WHERE Subscription__c IN :zSubIdsToBeProcessed];
                                    
                enabledAsia1List = [SELECT Id, Asia1__c, Service_Access_Flag__c, Subscription__c, Concurrent__c, Asia1__r.User_ID_LDAP_ID__c, Service_Access_Flag__r.Name, Status__c, Subscription__r.Number_of_Copies__c
                                    FROM Asia1_Subscription__c
                                    WHERE Subscription__c IN :zSubIdsToBeProcessed AND Status__c = :ENABLED_VALUE];
                                    
                //for update of Asia1             
                for(Asia1_Subscription__c asia1Sub : asia1SubsList){
                    if(asia1Sub.Asia1__r.User_ID_LDAP_ID__c != reqObj.asiaOneLdapId){
                        if(mapSubIdToAsia1SubRec.containsKey(asia1Sub.Subscription__c)){
                            mapSubIdToAsia1SubRec.get(asia1Sub.Subscription__c).add(asia1Sub);
                        }else{
                            mapSubIdToAsia1SubRec.put(asia1Sub.Subscription__c, new List<Asia1_Subscription__c>{asia1Sub});
                        }
                        
                        asia1SubsToBeCreated.add(asia1Sub.Subscription__c);
                        
                    }
                    subWithAsia1Sub.add(asia1Sub.Subscription__c);
                    //oldAsia1.add(asia1Sub.Asia1__c);
                }
                //check for Asia1 Old Recipient Contact__c
                //asia1RecipientContact = [SELECT Id, User_ID_LDAP_ID__c, Contact__c, Email__c FROM Asia1__c WHERE Id IN :oldAsia1 LIMIT 1];
                
                for(Zuora__Subscription__c subs : subsToBeProcessed){
                    if(mapSubIdToAsia1SubRec.containsKey(subs.Id)){
                        asia1SubsToBeUpdated.addAll(mapSubIdToAsia1SubRec.get(subs.Id));    //test this after the block
                    }
                    //for subs without tagging
                    if(!subWithAsia1Sub.contains(subs.Id)){
                        asia1SubsToBeCreated.add(subs.Id);
                    }
                }
                //END: D-4772 3-24-2016 Added by Kristine Balaoing
                for(Asia1_Subscription__c aSub : enabledAsia1List){
                    //System.debug(null, aSub);
                    if(aSub.Concurrent__c != null){
                        System.debug('ALPHONSE concur  ' + aSub.Concurrent__c);
                        //insert here2
                        if(mapServiceToConFromAsiaSubs.containsKey(aSub.Service_Access_Flag__r.Name)){
                            serviceCon = mapServiceToConFromAsiaSubs.get(aSub.Service_Access_Flag__r.Name);
                            mapServiceToConFromAsiaSubs.put(aSub.Subscription__c, serviceCon + (aSub.Concurrent__c*aSub.Subscription__r.Number_of_Copies__c));
                        }else{
                            mapServiceToConFromAsiaSubs.put(aSub.Service_Access_Flag__r.Name, (aSub.Concurrent__c*aSub.Subscription__r.Number_of_Copies__c));
                        }
                        finalCon = finalCon + aSub.Concurrent__c;
                        System.debug('entered');
                        /*
                        if(mapSubToCon.containsKey(aSub.Subscription__c)){
                            subCon = mapSubToCon.get(aSub.Subscription__c);
                            mapSubToCon.put(aSub.Subscription__c, subCon + aSub.Concurrent__c);
                        }else{
                            mapSubToCon.put(aSub.Subscription__c, aSub.Concurrent__c);
                        }*/
                        
                        //new map
                        if(mapSubToMapSVCToCon.containsKey(aSub.Subscription__c)){
                            System.debug('entered 1');
                            mapServFlagToCon = mapSubToMapSVCToCon.get(aSub.Subscription__c);
                            if(mapServFlagToCon.containsKey(aSub.Service_Access_Flag__r.Name)){
                                    svcCon = mapServFlagToCon.get(aSub.Service_Access_Flag__r.Name);
                                    mapServFlagToCon.put(aSub.Service_Access_Flag__r.Name, svcCon + aSub.Concurrent__c);
                            }else{
                                //mapServFlagToCon = new Map<String, Integer>();
                                mapServFlagToCon.put(aSub.Service_Access_Flag__r.Name, aSub.Concurrent__c);
                            }
                            mapSubToMapSVCToCon.put(aSub.Subscription__c, mapServFlagToCon);
                            System.debug('map 1 ' + mapSubToMapSVCToCon);
                        }else{
                            System.debug('entered 2');
                            mapServFlagToCon = new Map<String, Decimal>();
                            //mapSubToMapSVCToCon = new Map<Id, Map<String, Decimal>>(); 

                            mapServFlagToCon.put(aSub.Service_Access_Flag__r.Name, aSub.Concurrent__c);
                            mapSubToMapSVCToCon.put(aSub.Subscription__c, mapServFlagToCon);
                            System.debug('map 2 ' + mapSubToMapSVCToCon);
                        }
                        System.debug('TINE TINE finalconwithin  ' + finalCon);
                    }
                }
                System.debug('CONCURRENT MAP ' + mapSubToMapSVCToCon);
                //System.assertEquals(1, 2);
                System.debug('TINE FINAL CON  ' + finalCon);
                for(Id subId : asia1SubsToBeCreated){
                    svcForEnablement.addAll(mapPckToSVC.get(mapSubToSubRec.get(subId).Main_Package_1__c));  //perform debug here to check if naaccumulate
                }

                //svcForEnablement.addAll(existingSVCSet);
                //svcForEnablement.addAll(newSVCSet);
                //concat service flags                
                String concatenatedSVCs = concatServiceFlags(svcForEnablement);
                system.debug('concatenatedSVCs : '+concatenatedSVCs);
                // START D-4636 - 06Apr2016 - Raviteja Kumar - Chcecking Serivce Flags before sending signals to Server
                if(concatenatedSVCs != Null && concatenatedSVCs != '' && concatenatedSVCs.trim() != Null){
                    responseResult = enableServiceFlag(reqObj.asiaOneLdapId, concatenatedSVCs);                
                }
                // END D-4636 - 06Apr2016 - Raviteja Kumar
                System.debug('>>>>>>>>>>>>>>   ' + responseResult);
                //System.assertEquals(null, responseResult);
                //Boolean forced = true;
                // START D-4636 - 06Apr2016 - Raviteja Kumar - Sent Success status if we get EXES0018 error.
                //if((String)responseResult.get(ACTIVATE_VALUE)== SUCCESS){
                if((String)responseResult.get(ACTIVATE_VALUE)== SUCCESS || (String)responseResult.get(ERRORS)== EXES0018_Value){
                // END D-4636 - 06Apr2016 - Raviteja Kumar
                
                    if(reqObj.asiaOneLdapId != null){
                        if(asiaOneRec.size()>0){
                            asiaOneForProcessing = asiaOneRec[0];
                        }else{
                            //retrieve values
                            Map<String, Object> retrieveResult = AsiaOneServicesController.viewUserDetails(reqObj.asiaOneLdapId);
                            //insert here1
                            svcForEnablement.remove(Null);
                            for(String svflag : svcForEnablement){
                                String asia1Subsvfalg;                                                      
                                Map<String, Object> updateConcurrent = AsiaOneServicesController.updateConcurrent(reqObj.asiaOneLdapId, svflag.toLowerCase(), (String.valueOf(mapServiceToConFromAsiaSubs.get(svflag))));                              
                                    if(updateConcurrent.get(UPDATE_CONCURRENT_CONFIG)==FAILED){
                                        resp.svc_status = FAILURE;
                                        resp.error_code = EXES0022_Code;
                                        resp.error_message = (String)updateConcurrent.get(ERRORS);
                                    }                            
                            }
                            Asia1__c asia1RecTobeCreated = new Asia1__c();
                            asia1RecTobeCreated.User_ID_LDAP_ID__c = reqObj.asiaOneLdapId;
                            asia1RecTobeCreated.Contact__c = recipient[0].Id;
                            asia1RecTobeCreated.Display_Name__c = String.valueOf(retrieveResult.get(DISPLAY_NAME));
                            asia1RecTobeCreated.Email__c = recipient[0].Email__c;
                            asia1RecTobeCreated.Enabled__c = true;
                            asia1RecTobeCreated.Is_Link_Expired_Used__c = true;
                            asia1RecTobeCreated.Base_Date_Expiration__c = Date.today();
                            asia1RecTobeCreated.Status__c = CREATED_VALUE;
                            
                            insert asia1RecTobeCreated;
                            
                            asiaOneForProcessing = asia1RecTobeCreated;
                        }
                    }
                
                    if(asia1SubsToBeUpdated.size()>0){
                        processAsia1Sub(asiaOneForProcessing.Id, null, asia1SubsToBeUpdated);
                    }
                    if(asia1SubsToBeCreated.size()>0){
                        processAsia1Sub(asiaOneForProcessing.Id, asia1SubsToBeCreated, null);
                    }
                
                    resp.svc_status = SUCCESS;
                    resp.subscriberId = reqObj.subscriberId;
                    resp.asiaOneLdapId = reqObj.asiaOneLdapId;
                    resp.subscriptionIds = reqObj.subscriptionIds;
                    
                    // START D-4636 - 06Apr2016 - Raviteja Kumar - Adding EXES0018 error as success response with error
                    if((String)responseResult.get(ERRORS)== EXES0018_Value){
                        resp.error_code = EXES0018_Code;
                        resp.error_message = EXES0018_Value;
                    }
                   // END D-4636 - 06Apr2016 - Raviteja Kumar
                }else{
                    //System.assertEquals(null, responseResult);
                    resp.svc_status = FAILURE;
                    resp.subscriberId = reqObj.subscriberId;
                    resp.asiaOneLdapId = reqObj.asiaOneLdapId;
                    resp.subscriptionIds = reqObj.subscriptionIds;
                    if((String)responseResult.get(ERRORS)== EXES0021_Value){
                        resp.error_code = EXES0021_Code;
                        resp.error_message = EXES0021_Value;
                    // START D-4636 - 06Apr2016 - Raviteja Kumar - follow sucess process if we get EXES0018 error.
                    /*
                    }else if((String)responseResult.get(ERRORS)== EXES0018_Value){
                        System.debug('Else if you have already activated the service');                        
                        resp.error_code = EXES0018_Code;
                        resp.error_message = EXES0018_Value;
                    */ 
                    // END D-4636 - 06Apr2016 - Raviteja Kumar   
                    }else{
                        System.debug('ELSE ENTERED');
                        resp.error_code = EXES0023_Code;
                        resp.error_message = (String)responseResult.get(ERRORS);
                    }
                }
                
            }
        }
        return resp;
    }
    //END: D-4472 Retest Failed 3-23-2016 Added by Kristine Balaoing
    public static Map<String, Boolean> checkMandatoryFields(Request reqObj)
    {
        Map<String, Boolean>  resultMandCheck = new Map<String, Boolean>();
        Boolean isValid = true;
        resultMandCheck.put(SUBSCRIBER_ID, isValid);
        resultMandCheck.put(ASIAONE_LDAP_ID, isValid);
        
        //START UD-1205 09-May-2015 Added by Raviteja - added String.isBlank() in both conditions
        if(reqObj.subscriberId == null || reqObj.subscriberId == '' || String.isBlank(reqObj.subscriberId)){
            isValid = false;
            resultMandCheck.put(SUBSCRIBER_ID, isValid);
        }
        if(reqObj.asiaOneLdapId == null || reqObj.asiaOneLdapId == '' || String.isBlank(reqObj.asiaOneLdapId)){
            isValid = false;
            resultMandCheck.put(ASIAONE_LDAP_ID, isValid);
        }
        //End UD-1205 09-May-2015 Added by Raviteja
        return resultMandCheck;
    }
    //START: D-4472 3-23-2016 Added by Kristine Balaoing - added logic for subs name instead of sub Id
    public static Boolean checkSubscriptionsAccount(Set<String> idsUnderAccountSet, Request reqObj){
        
        Boolean isUnderAccount = true;
        
        for(String zSubName: reqObj.subscriptionIds){
            if(!idsUnderAccountSet.contains(zSubName)){
                isUnderAccount = false;
            }
        }
      
        return isUnderAccount;
        
    }
    //END: D-4472 3-23-2016 Added by Kristine Balaoing
    
    public static void processAsia1Sub(Id asia1Id, Set<Id> subsIdToBeCreated, Set<Asia1_Subscription__c> asia1SubsToBeUpdated){
        
        List<Asia1_Subscription__c> asia1SubList = new List<Asia1_Subscription__c>();
        List<Asia1_Subscription__c> asia1SubToBeUpdated2 = new List<Asia1_Subscription__c>();
        //asia1SubsToBeUpdated = new Set<Asia1_Subscription__c>();
        //subsIdToBeCreated = new Set<Asia_Subscription>();
        if(subsIdToBeCreated != null){
            if(subsIdToBeCreated.size()>0){
                for(Id subId : subsIdToBeCreated){
                    Zuora__Subscription__c zSub = new Zuora__Subscription__c();
                    
                    if(mapSubToSubRec.containsKey(subId)){
                        zSub = mapSubToSubRec.get(subId);
                    }
                    
                    if(mapPckToSVC.containsKey(zSub.Main_Package_1__c)){
                        for(String serviceFlag : (mapPckToSVC.get(zSub.Main_Package_1__c))){
                            Asia1_Subscription__c asia1SubToBeCreated = new Asia1_Subscription__c();
                            asia1SubToBeCreated.Asia1__c = asia1Id;                            
                             // START D-4636 - 06Apr2016 - Raviteja Kumar - Checking serviceFlag before assinging
                            //asia1SubToBeCreated.Service_Access_Flag__c = mapFlagToSAFRec.get(serviceFlag).Id;
                            if(serviceFlag != Null && mapFlagToSAFRec.get(serviceFlag) != Null){
                                asia1SubToBeCreated.Service_Access_Flag__c = mapFlagToSAFRec.get(serviceFlag).Id;
                            }
                            else{
                                asia1SubToBeCreated.Service_Access_Flag__c = Null;
                            }
                            // END D-4636 - 06Apr2016 - Raviteja Kumar 
                            asia1SubToBeCreated.Subscription__c = subId;
                            asia1SubToBeCreated.Status__c = ENABLED_VALUE;
                            asia1SubToBeCreated.Order_Line_Item__c = mapSubToSubRec.get(subId).Order_Line_Item_Number_1__c;
                            if(mapSubIdToAsia1SubRec.containsKey(zSub.Id)){
                                //asia1SubToBeCreated.Concurrent__c = mapSubToCon.get(subId);
                                //START: D-4472 3-24-2016 Added by Kristine Balaoing- changed logic for getting concurrency
                                System.debug('MAP SUB CON ' + mapSubToMapSVCToCon);
                                if(mapSubToMapSVCToCon.containsKey(subId)){
                                    if(mapSubToMapSVCToCon.get(subId).containsKey(serviceFlag)){
                                        asia1SubToBeCreated.Concurrent__c = mapSubToMapSVCToCon.get(subId).get(serviceFlag);
                                    }
                                }
                                //END: D-4472 3-24-2016 Added by Kristine Balaoing
                            }else{
                                if(mapSVCToCon.containsKey(serviceFlag)){
                                    asia1SubToBeCreated.Concurrent__c = mapSVCToCon.get(serviceFlag);
                                }
                            }
                            
                            
                            asia1SubList.add(asia1SubToBeCreated);
                        }
                    }
                    
                }
                insert asia1SubList;
            }
        }
        //UpdateAsia1
        if(asia1SubsToBeUpdated != null){
            if(asia1SubsToBeUpdated.size()>0){
                for(Asia1_Subscription__c asia1Sub1: asia1SubsToBeUpdated){
                    asia1Sub1.Status__c = DISABLED_VALUE;
                    
                    asia1SubList.add(asia1Sub1);
                }
                //System.assertEquals(null, asia1SubList);
                update asia1SubList;
            }
        }
        
    }
    
    public static Map<String, Object> enableServiceFlag(String username, String serviceFlag){
        
        System.debug('serviceFlag : '+serviceFlag);
        Map<String, Object> enableServiceResult = new Map<String, Object>();
        enableServiceResult = AsiaOneServicesController.enableService(username, serviceFlag.toLowerCase());
        
        //System.assertEquals(null, enableServiceResult);
        return enableServiceResult;
    }
    
    public static String concatServiceFlags(Set<String> svcSet){
        //ensure that serList does not have any null values
        List<String> serList = new List<String>();
        serList.addAll(svcSet);
        String finalStr='';
        for(integer counter=0; counter<serList.size(); counter++){
            String serStr = serList[counter];
            If(counter>0)
                finalStr += '|';
                finalStr += serStr;
        }

        return finalStr;
    }
    
    public static Integer addConcurrent(Set<Integer> concurVal){
        
        Integer sumConcal = 0;
        
        for(Integer con : concurVal){
            sumConcal = sumConcal + con;
        }
        
        return sumConcal;
    }
    
    
}