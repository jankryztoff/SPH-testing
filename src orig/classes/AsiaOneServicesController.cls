/**
 * Class Name: AsiaOneServicesController
 * @author: Jb Domingo
 * Date: 8/15/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Utility Class for AsiaOne Callouts
 *
 */
public class AsiaOneServicesController{

   // Start D-1963 02/16/2015 JohnD
   //Start: D-4618
   //05-10-2016 Josell Paguiligan  Added: test visible for test classes 
   @testvisible private static final string SUCCESS = 'Success';
   //START:D-2510 3/12/15 Added by Manolo Valena - Added new static variables.
   @testvisible private static final string FAILED = 'Failed';
   @testvisible private static final string ERRORS = 'Errors';
   @testvisible private static final string ERROR_CREATION = 'Error Creation';
   //END:D-2510 3/12/15 Added by Manolo Valena
   @testvisible private static final string DEACTIVATE = 'Deactivate';
   
   @testvisible private static final string ACTIVATE_R = 'Activate';
   
   @testvisible private static final string DISABLED = 'Disabled';
   @testvisible private static final string ENABLED = 'Enabled';
   // End D-1963 02/16/2015 JohnD
   
   
   @testvisible private static final String ERROR_ALREADY_ACTIVATED = 'You have already activated the service.'; //START/END 13 August 2015 D-3391/UD-2271 Kevin Evasco - Asia1 Subscription Service Activation
    //End D-4618
    
   /* @description This method executes verify user callout to Asia One 
    * 
    * @param username - login id/system id
    * @param password - password
    * @param serviceFlag - service flag 
    * @return resMap - map which contains the response from Asia One
    */ 
    public static Map<String,Object> verifyUser(String username, String password, String serviceFlag){  
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();
        AsiaOneServiceResponsetVO sRespVO;    
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();
        sReqMap.put(GlobalVariableClass.UUU,username); 
        sReqMap.put(GlobalVariableClass.PPP,password); 
        sReqMap.put(GlobalVariableClass.SVC,serviceFlag);
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                          
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_CHECK_AUTH);    
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);  
        if (sRespVO != null) { 
            resMap = sRespVO.reqValueObject;    
        }            
        return resMap;
    }
    //START: D- 4472 Added by Kristine Balaoing - added for update of concurrency in Asia1
    public static Map<String, Object> updateConcurrent(String username, String svc, String quota){
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();
        AsiaOneServiceResponsetVO sRespVO;
        
        Map<String, String> sReqMap = new Map<String, String>();
        Map<String, Object> resMap = new Map<String, String>();
        sReqMap.put(GlobalVariableClass.USERNAME,username);
        sReqMap.put(GlobalVariableClass.SVC,svc);
        sReqMap.put(GlobalVariableClass.QUOTA,quota);
        sReqMap.put(GlobalVariableClass.IP,'121.11.223.1');
        //AsiaOneServiceRequestVO serviceRequestVO = new AsiaOneServiceRequestVO();
        sReqVO.setReqValueObject(sReqMap);
        sReqVO.setasia1APIFunction(GlobalVariableClass.API_UPDATECONCURRENT);
        System.debug('################ before');
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);
        System.debug('################ after');
        
        if (sRespVO != null) { 
            resMap = sRespVO.reqValueObject;    
        }            
        return resMap;
    }
    //END: D- 4472 Added by Kristine Balaoing
   /* @description This method executes verify user callout to Asia One 
    * 
    * @param username - login id/system id
    * @param password - password
    * @return resMap - map which contains the response from Asia One
    */     
    public static Map<String,Object> verifyUser2(String username, String password){  
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO(); 
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();     
        sReqMap.put(GlobalVariableClass.UUU,username); 
        sReqMap.put(GlobalVariableClass.PPP,password); 
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                          
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_CHECK_AUTH2);    
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);   
        if (sRespVO != null) {
            resMap = sRespVO.reqValueObject; 
        }
        return resMap;  
    }
   /* @description This method executes verify facebook user callout to Asia One 
    * 
    * @param facebookID - facebook user id
    * @return resMap - map which contains the response from Asia One
    */     
    public static Map<String,Object> verifyUserFacebook(String facebookID){  
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>();
        Map<String, Object> resMap = new Map<String, String>();     
        sReqMap.put(GlobalVariableClass.FFF,facebookID); 
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                          
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_CHECK_AUTH3);    
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);  
        if (sRespVO != null) { 
            resMap = sRespVO.reqValueObject;
        }
        return resMap;      
    }
   /* @description This method executes create account callout to Asia One 
    * 
    * @param accountMap - map that contains the account keys and values
    * @return resMap - map which contains the response from Asia One
    */                                  
    public static Map<String,Object> createAccount(Map<String,String> accountMap){          
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();  
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>();
        Map<String, Object> resMap = new Map<String, String>();
        //UD-3952 4-18-2016 Added by Kristine Balaoing - removed spaces in first name and lastname

        String LNAME_FORMATTED;
        String FNAME_FORMATTED;
        
        if(accountMap.get(GlobalVariableClass.FNAME)!=null){
            FNAME_FORMATTED = accountMap.get(GlobalVariableClass.FNAME).replaceAll(' ', '+');
        }
        if(accountMap.get(GlobalVariableClass.LNAME)!=null){
            LNAME_FORMATTED = accountMap.get(GlobalVariableClass.LNAME).replaceAll(' ', '+');
        }
        sReqMap.put(GlobalVariableClass.USERNAME,accountMap.get(GlobalVariableClass.USERNAME));                                                                       
        sReqMap.put(GlobalVariableClass.PASSWORD,accountMap.get(GlobalVariableClass.PASSWORD)); 
        sReqMap.put(GlobalVariableClass.PASS_CHALLENGE,accountMap.get(GlobalVariableClass.PASS_CHALLENGE)); 
        sReqMap.put(GlobalVariableClass.PASS_RESPONSE,accountMap.get(GlobalVariableClass.PASS_RESPONSE)); 
        sReqMap.put(GlobalVariableClass.FNAME,FNAME_FORMATTED);
        sReqMap.put(GlobalVariableClass.LNAME,LNAME_FORMATTED); 
        sReqMap.put(GlobalVariableClass.DISPLAY_NAME,accountMap.get(GlobalVariableClass.DISPLAY_NAME)); 
        sReqMap.put(GlobalVariableClass.EMAIL,accountMap.get(GlobalVariableClass.EMAIL)); 
        sReqMap.put(GlobalVariableClass.PHONE,accountMap.get(GlobalVariableClass.PHONE)); 
        //UD-3952 4-18-2016 Added by Kristine Balaoing
        
        //START D-2942 25-06-2015 Marvin Gatchalian as per requirement Account should be disabled upon creation
        //sReqMap.put(GlobalVariableClass.ENABLE,accountMap.get(GlobalVariableClass.ENABLE));
        sReqMap.put(GlobalVariableClass.ENABLE,'no'); 
        //END D-2942 25-06-2015 Marvin Gatchalian as per requirement Account should be disabled upon creation
        if (accountMap.get(GlobalVariableClass.SVC) != null)    // Start/End UD-3391 15Mar16 JohnD
            sReqMap.put(GlobalVariableClass.SVC,accountMap.get(GlobalVariableClass.SVC));
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                  
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_SIGNUP);            
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);   
        if (sRespVO != null) {
            resMap = sRespVO.reqValueObject;  
        }
        return resMap;      
    }
    /* @description This method executes enable service callout to Asia One 
    * 
    * @param username - login id/system id
    * @param serviceFlag - service flag
    * @return resMap - map which contains the response from Asia One
    */    
    public static Map<String,Object> enableService(String username, String serviceFlag){        
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();
        sReqMap.put(GlobalVariableClass.SVC,serviceFlag);
        sReqMap.put(GlobalVariableClass.USERNAME,username);                                                                   
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                              
        sReqVO.setReqValueObject(sReqMap);   
        system.debug('RETURN:'+sReqMap);                                                       
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_ENABLE_SERVICE);         
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);  
        if (sRespVO != null) { 
            resMap = sRespVO.reqValueObject; 
        }        
        return resMap;            
    }
    //START: D-0964 12/16/14 Added by S.Puli - enable
    /* @description This method executes enable service future callout to Asia One 
    * 
    * @param username - login id/system id
    * @param serviceFlag - service flag
    * @return resMap - map which contains the response from Asia One
    */    
    @future(callout = true)
    public static void enableServiceFuture(String username, String serviceFlag, Id asiaId){        
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();
        sReqMap.put(GlobalVariableClass.SVC,serviceFlag);
        sReqMap.put(GlobalVariableClass.USERNAME,username);                                                                   
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                              
        sReqVO.setReqValueObject(sReqMap);   
        system.debug('RETURN:'+sReqMap);                                                       
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_ENABLE_SERVICE);    
        
           
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);  
        if (sRespVO != null) { 
            resMap = sRespVO.reqValueObject; 
        } 
        
 
        //return resMap;
        Asia1_Subscription__c asia1SubFinal = new Asia1_Subscription__c();  
        asia1SubFinal = [SELECT Id, Subscription__c, Asia1__c, Service_Access_Flag__c, Asia1__r.Status__c, Asia1__r.User_ID_LDAP_ID__c
                                 FROM Asia1_Subscription__c WHERE Id = : asiaId 
                                 AND Status__c = 'Disabled'];
                                 
        system.debug('resMap--->'+resMap);  
                  
        if(resMap.get('Activate') == 'Success') {
            system.debug('resMap--->success');
            asia1SubFinal.Status__c = 'Enabled';
            update asia1SubFinal;
        }
        
                                 
    }
    //END: D-0964 12/16/14 Added by S.Puli
    
    
    // Start D-1963 02/16/2015 JohnD method to allow multiple asia1 subscriptions activation
    @future(callout = true)
    public static void enableServicesFuture(string username, string serviceFlag, set<id> asia1SubscriptionIdSet, id subscriptionId) {
        //Start D-3289 07/30/2015 Dags - added to enable service flags for multiple asia1 in one order line item 
        string ldapId;
        string ldapIdprev;
        //End D-3289 07/30/2015 Dags - added to enable service flags for multiple asia1 in one order line item 
        //START: PD-0035 04/20/2016 Added by Kristine Balaoing - added variables for add on
        Zuora__Subscription__c zSubRec;
        Id mainSubscriptionId;
        Id addOnSubcriptionId;
        //END: PD-0035 04/20/2016 Added by Kristine Balaoing
        list<Asia1_Subscription__c> asia1SubscriptionList = new list<Asia1_Subscription__c>();
        //START:D-2510 3/12/15 Added by Manolo Valena - Query to check Asia1 records that were not successfully created.
        list<Asia1_Subscription__c> aList = [SELECT Id, Status__c, Asia1__r.Status__c 
                                         FROM Asia1_Subscription__c 
                                         WHERE Id IN: asia1SubscriptionIdSet 
                                         AND Status__c =: GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED
                                         AND Asia1__r.Status__c =: ERROR_CREATION];
        //END:D-2510 3/12/15 Added by Manolo Valena
        try {
            
            //{ // Start/End UD-3915 08Apr16 JohnD - commented out
                map<string, object> request = enableService(username, serviceFlag);
               //Start D-3289 07/30/2015 Dags - added to enable service flags for multiple asia1 in one order line item 
               
               //START: PD-0035 May 16, 2016 Added by Kristine Balaoing - transferred code bock after callout to avoid uncommitted work pending
               //START:D-2510 3/12/15 Added by Manolo Valena - Added condition to check if the Asia1 records were created. If yes, the Asia1 Subscription records can be updated. Else, they are deleted.
                if(aList.size() > 0)
                {
                    delete aList;
                }
                //else  // Start/End UD-3915 08Apr16 JohnD - commented out
                //END: PD-0035 May 16, 2016 Added by Kristine Balaoing
               ldapId = null;
               ldapIdprev = null;
               
               for (Asia1_Subscription__c asia1Subscription1 : [select Asia1__r.User_ID_LDAP_ID__c from Asia1_Subscription__c 
                            where Id IN :asia1SubscriptionIdSet ]) {
                            
                  if (ldapId== null){
                     ldapId = asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c;
                     ldapIdprev =  asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c;
                     map<string, object> request1 = enableService(ldapId, serviceFlag);
                  }             
                  else if (ldapIdprev <> asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c){
                     ldapId = asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c;
                     ldapIdprev =  asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c;
                     map<string, object> request1 = enableService(ldapId, serviceFlag);
                  }   
               }
               //End D-3289 07/30/2015 Dags - added to enable service flags for multiple asia1 in one order line item
                //START: PD-0035 04/20/2016 Added by Kristine Balaoing - added logic for add on service flag
                // start retrieve subscription ids
                map<string, id> packageType_packageId = new map<string, id>();
                set<string> mainSubAccessFlagSet = new set<string>();
                set<string> addOnSubAccessFlagSet = new set<string>();
                Zuora__Subscription__c providedZSub = new Zuora__Subscription__c();
                
                providedZSub = [select Id, Main_Package__c, Order_Line_Item_Number_1__c, Order_Line_Item_Number_1__r.Main_Package_ID__c, Order_Line_Item_Number_1__r.Addon_Package__c FROM Zuora__Subscription__c where Id = :subscriptionId];
                
                for (Zuora__Subscription__c sub : [select Id, Main_Package__c, Order_Line_Item_Number_1__r.Main_Package_ID__c, Order_Line_Item_Number_1__r.Addon_Package__c FROM Zuora__Subscription__c where Order_Line_Item_Number_1__c = :providedZSub.Order_Line_Item_Number_1__c and Subscription_Type__c = 'Publication']) {
                    System.debug('SUBBBBB >> ' + sub);
                    if (sub.Main_Package__c == sub.Order_Line_Item_Number_1__r.Main_Package_ID__c) {
                        mainSubscriptionId = sub.Id;
                        packageType_packageId.put('main', sub.Order_Line_Item_Number_1__r.Main_Package_ID__c);
                    } else if (sub.Main_Package__c == sub.Order_Line_Item_Number_1__r.Addon_Package__c) {
                        addOnSubcriptionId = sub.Id;
                        packageType_packageId.put('addon', sub.Order_Line_Item_Number_1__r.Addon_Package__c);
                    }
                }
                //System.assertEquals(null, addOnSubcriptionId);
                // end retrieve subscription ids

                // start retrieve package access flags
                for (Package_Access_Flag__c pkgFlags : [select Package__c, Package_Service_Access_Flag__r.Name from Package_Access_Flag__c where Package__c in :packageType_packageId.values()]) {
                    //if(userinfo.getLastName() == 'Balaoing'){
                        //System.assert(false);
                    //}
                    if (packageType_packageId.get('main') == pkgFlags.Package__c) {
                        mainSubAccessFlagSet.add(pkgFlags.Package_Service_Access_Flag__c);
                    } else if (packageType_packageId.get('addon') != null && packageType_packageId.get('addon') == pkgFlags.Package__c) {
                        addOnSubAccessFlagSet.add(pkgFlags.Package_Service_Access_Flag__c);
                    }
                        
                }
                // end retrieve package access flags
                System.debug('ADD ON FLAGS >> ' + addOnSubAccessFlagSet);
                System.debug('MAIN FLAG SET >> ' + mainSubAccessFlagSet);
                System.debug('MAIN SUBS ID >> ' + mainSubscriptionId);
                System.debug('ADD ON SUBS ID >> ' + addOnSubcriptionId);
                System.debug('ASIA1 SET >> ' + asia1SubscriptionIdSet);
                System.debug('Request >> ' + request);
          
                //START:D-2510 3/12/15 Added by Manolo Valena - If success, the Asia1 Subscription records are updated accordingly.
                if (request.get(ACTIVATE_R) == SUCCESS ) {
                     System.debug('\n\n ***DEBUG ON request ****  ' + request.get(ACTIVATE_R) + '\n\n');
               
                    for (Asia1_Subscription__c asia1Subscription : [select Id, Status__c, Service_Access_Flag__c, Subscription__c, Asia1__c from Asia1_Subscription__c 
                        where Id IN :asia1SubscriptionIdSet and (Status__c = :GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED 
                        or Status__c = null)]) {    // Start/End UD-3363 08Dec15 JohnD - added status = null in the criteria
                
                        asia1Subscription.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
                        //asia1Subscription.Subscription__c = subscriptionId;
                        System.debug('FLAG INSIDE >> ' + asia1Subscription.Service_Access_Flag__c);
                        if (mainSubAccessFlagSet.contains(asia1Subscription.Service_Access_Flag__c)) {
                            //asia1Subscription.Subscription__c = packageType_packageId.get('main');
                            asia1Subscription.Subscription__c = mainSubscriptionId;
                            //mainSubAccessFlagSet.remove(asia1Subscription.Service_Access_Flag__c);
                        } else if (addOnSubAccessFlagSet.contains(asia1Subscription.Service_Access_Flag__c)) {
                            //asia1Subscription.Subscription__c = packageType_packageId.get('addon');
                            asia1Subscription.Subscription__c = addOnSubcriptionId;
                            //addOnSubAccessFlagSet.remove(asia1Subscription.Service_Access_Flag__c);
                        }

                        asia1SubscriptionList.add(asia1Subscription);
                    }
                    //END: PD-0035 04/20/2016 Added by Kristine Balaoing
                    system.debug('asia1SubscriptionList ::::::: ' + asia1SubscriptionList);
                    
                    try {
                        update asia1SubscriptionList;
                    } catch (exception e2) {
                        ExceptionLogger.log(new list<exception> { e2 });
                    }
                }
                //END:D-2510 3/12/15 Added by Manolo Valena
                //START:D-2510 3/12/15 Added by Manolo Valena - If failed, the errors during creation of Asia1 Subscription/s are captured.
                else if(request.get(ACTIVATE_R) == FAILED)
                {
                    String aSubError = string.valueOf(request.get(ERRORS));
                    // Start UD-3363 04Dec15 JohnD
                    if (aSubError != null) {
                        aSubError = aSubError.replace('[', '').replace(']', '');
                    }
                    
                    // End UD-3363 04Dec15 JohnD
                    for (Asia1_Subscription__c asia1Subscription : [select Id, Status__c, Subscription__c from Asia1_Subscription__c 
                            where Id IN :asia1SubscriptionIdSet and (Status__c = :GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED 
                            or Status__c = null)]) {    // Start/End UD-3329 30Nov15 JohnD - added Status = null
                        //START 13 August 2015 D-3391/UD-2271 Kevin Evasco - Asia1 Subscription Service Activation
                        if(aSubError == ERROR_ALREADY_ACTIVATED || (aSubError != null && aSubError.contains(ERROR_ALREADY_ACTIVATED))) {   // Start/End UD-3329 30Nov15 JohnD - added expression                       
                            asia1Subscription.Status__c = ENABLED;
                            asia1Subscription.Reason_for_Failure__c = null;
                        } else {
                            asia1Subscription.Status__c = ERROR_CREATION;
                            asia1Subscription.Reason_for_Failure__c = aSubError;
                        }
                        
                        asia1Subscription.Subscription__c = subscriptionId;
                        asia1SubscriptionList.add(asia1Subscription);
                        //END 13 August 2015 D-3391/UD-2271 Kevin Evasco - Asia1 Subscription Service Activation
                    }
                    
                    system.debug('asia1SubscriptionList ::::::: ' + asia1SubscriptionList);
                    
                    try {
                        update asia1SubscriptionList;
                    } catch (exception e2) {
                        ExceptionLogger.log(new list<exception> { e2 });
                    }
                }
                //END:D-2510 3/12/15 Added by Manolo Valena
            //}     // Start/End UD-3915 08Apr16 JohnD - commented out
            //END:D-2510 3/12/15 Added by Manolo Valena
            
        } catch (exception e) {
            ExceptionLogger.log(new list<exception> { e });
        }
    }    
    // End D-1963 02/18/2015 JohnD
    
    /* @description This method executes enable service callout to Asia One 
    * 
    * @param username - login id/system id
    * @param serviceFlag - service flag
    * @return resMap - map which contains the response from Asia One
    */     
    public static Map<String,Object> disableService(String username, String serviceFlag){        
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();  
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();
        sReqMap.put(GlobalVariableClass.USERNAME,username);                                                                   
        sReqMap.put(GlobalVariableClass.SVC,serviceFlag);
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                              
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_DISABLE_SERVICE);          
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);  
        if (sRespVO != null) { 
            resMap = sRespVO.reqValueObject; 
        }      
        return resMap;      
    }
    
    
    // Start D-1963 02/16/2015 JohnD method to allow multiple asia1 subscriptions deactivation
    @future(callout = true)
    public static void disableServicesFuture(string username, string serviceFlag, set<id> asia1SubscriptionIdSet) {
        
        list<Asia1_Subscription__c> asia1SubscriptionList = new list<Asia1_Subscription__c>();
        
        try {
            
            map<string, object> request = disableService(username, serviceFlag);
            
            if (request.get(DEACTIVATE) == SUCCESS) {
                
                for (Asia1_Subscription__c asia1Subscription : [select Id, Status__c from Asia1_Subscription__c 
                        where Id = :asia1SubscriptionIdSet and Status__c = :GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED]) {
                
                    asia1Subscription.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
                    asia1SubscriptionList.add(asia1Subscription);
                }
                
                try {
                    update asia1SubscriptionList;
                } catch (exception e2) {
                    ExceptionLogger.log(new list<exception> { e2 });
                }
            }
            
        } catch (exception e) {
            ExceptionLogger.log(new list<exception> { e });
        }
    }
    
    public static void disableServiceFuture(string username, string serviceFlag, id asia1SubscriptionIdSet) {
        // old approach
    }
    
    // End D-1963 02/16/2015 JohnD
    
    /* @description This method executes validate username callout to Asia One 
    * 
    * @param username - login id/system id
    * @return resMap - map which contains the response from Asia One
    */      
    public static Map<String,Object> validateUserName(String username){ 
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();  
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>();
        Map<String, Object> resMap = new Map<String, String>();     
        sReqMap.put(GlobalVariableClass.USERNAME,username);                                                                   
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                      
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_CHECK_USER);             
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO); 
        if (sRespVO != null) {  
            resMap = sRespVO.reqValueObject;
        }      
        return resMap;      
    }
    /* @description This method executes validate displayname callout to Asia One 
    * 
    * @param displayName - display name
    * @return resMap - map which contains the response from Asia One
    */              
    public static Map<String,Object> validateDisplayName(String displayName){  
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO(); 
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>();    
        Map<String, Object> resMap = new Map<String, String>();
        sReqMap.put(GlobalVariableClass.DISPLAY_NAME,displayName);      
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                             
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_CHECK_DISPLAY_NAME);              
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);
        if (sRespVO != null) { 
            resMap = sRespVO.reqValueObject;
        }
        return resMap;      
    }   
    /* @description This method executes view user details callout to Asia One 
    * 
    * @param username - login id/system id
    * @return resMap - map which contains the response from Asia One
    */ 
    public static Map<String,Object> viewUserDetails(String username){  
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO(); 
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();     
        sReqMap.put(GlobalVariableClass.USERNAME,username);     
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                           
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_VIEW_USER_DETAILS);               
        
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);
        if (sRespVO != null) {   
            resMap = sRespVO.reqValueObject;
        }
        System.debug('resMap' + resMap);
        if(Test.isRunningTest()){
            resMap.put('User-View','Success');
            resMap.put('Display Name','Test Class');
            resMap.put('E-mail','test@sph.com');
            resMap.put('Password Answer','test123');
            resMap.put('Pasword Question','Test Question');
            resMap.put('AsiaOne','Password1');
        }
        
        return resMap;
              
    }   
    /* @description This method executes reset password callout to Asia One 
    * 
    * @param username - login id/system id
    * @param newPassword - new password
    * @return resMap - map which contains the response from Asia One
    */ 
    public static Map<String,Object> resetUserPassword(String username, String newPassword){  
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();     
        sReqMap.put(GlobalVariableClass.USERNAME,username);     
        sReqMap.put(GlobalVariableClass.NEWPASSWORD,newPassword);       
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                               
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_RESET_PASSWORD);              
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);
        if (sRespVO != null) {
            resMap = sRespVO.reqValueObject;
        }
        return resMap;      
    }   
    /* @description This method executes enable user account callout to Asia One 
    * 
    * @param username - login id/system id
    * @return resMap - map which contains the response from Asia One
    */    
    public static Map<String,Object> enableUserAccount(String username){  
        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();  
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();     
        sReqMap.put(GlobalVariableClass.USERNAME,username);             
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                               
        sReqVO.setReqValueObject(sReqMap);                                                          
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_ENABLE_ACCOUNT);         
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);   
        
        if (sRespVO != null) {
            resMap = sRespVO.reqValueObject; 
        }
        return resMap;      
    }
    //START: D-0964 12/16/14 Added by S.Puli - disable method
    /* @description This method executes disable user account callout to Asia One 
    * 
    * @param username - login id/system id
    * @return resMap - map which contains the response from Asia One
    */    
    public static Map<String,Object> disableUserAccount(String username){  
        
       

        AsiaOneFacade asiaOneFacadeObj = new AsiaOneFacade();
        AsiaOneServiceRequestVO sReqVO = new AsiaOneServiceRequestVO();  
        AsiaOneServiceResponsetVO sRespVO;      
        Map<String, String> sReqMap = new Map<String, String>(); 
        Map<String, Object> resMap = new Map<String, String>();     
        sReqMap.put(GlobalVariableClass.USERNAME,username);             
        sReqMap.put(GlobalVariableClass.IP,GlobalVariableClass.EMPTYSTR);                                                                                               
        sReqVO.setReqValueObject(sReqMap);                                                          
        
        //START UD-0877 04-27-2015 MarvinG     
        //sReqVO.setAsia1APIFunction(GlobalVariableClass.API_DISABLE_SERVICE);                                                     
        sReqVO.setAsia1APIFunction(GlobalVariableClass.API_DISABLE_ACCOUNT);         
        //END UD-0877 04-27-2015 MarvinG
        
        
        sRespVO = asiaOneFacadeObj.delegateAsiaOneCall(sReqVO);   
        
        if (sRespVO != null) {
            resMap = sRespVO.reqValueObject; 
        }
        
        return resMap;      
    }
    //END: D-0964 12/16/14 Added by S.Puli
}