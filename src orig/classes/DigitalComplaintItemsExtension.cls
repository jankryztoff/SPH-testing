/**
     * Class Name: DigitalComplaintItemsExtension 
     * @author Weng Empenado
     * Date: 2014.08.05
     * Requirement: Complaint & Enquiry - Digital Complaint Items
     * @description This class is used as an apex controller of DigitalComplaintItems VF page.
     *
     */


    /*
    * ------Revision------
    * Version 1.0: Pilot Release
    * By: <Developer Name>
    * Description:
    */

    public class DigitalComplaintItemsExtension {
        
        public Digital_Complaint_Items__c digital {get;set;}
        public String accountName {get; set;}
        public String casenoName {get; set;}
        public String subsName {get; set;}
        public String subcatName {get; set;}
        public String status {get; set;}
        public Boolean suppress {get; set;}
        public Boolean deactivate {get; set;}
        public Boolean force {get; set;}
        public String sphOnlineUserId {get; set;}
        public Asia1__c asia1 {get; set;}
        public List<Asia1__c> asia1List {get; set;}
        public List<Asia1_Subscription__c> asia1sub{get; set;}
        public list<Asia1Wrapper> asia1Subscriptions { get; set; }
        public transient boolean isAsia1Individual{get; set;}
        public transient boolean isAsia1Existing { get; set; }
        public transient string asia1CreationMode { get; set; }
        public List<SelectOption> enabledAsia1Options {get; set;}
        public String enabledAsia1 {get; set;}
        public Asia1__c selectedAsia1 {get; set;}
        private Case c;
    //START UD-2058 28/7/2015 : added for placement of quantity
        public Decimal quantity;
        public Decimal totalQuantityFromAll;
        public Decimal asia1Count; 
        public Boolean isErrorQty = false;
    //END UD-2058 28/7/2015 : added for placement of quantity
        
        public boolean deacUserId;
        public boolean forLogOut;
        public boolean createUser;
        public boolean resetPass;
        public boolean enableService;
        public String digiUserNameText;
        public String digiAsiaOne;
        public String digiUsername;
        public String digiNewPass;
        public Set<String> SVCSet;
        //START D-2402 27-Feb-2015 Added by Raviteja  - Assigend value as '' // End
        public String SVCResult = '';
        public String displayName;
        public String asiaUsername;
        public String asiaDisplayName;
        public String asia1NewPass;
        public String asia1Email;
        public String asia1Id;
        public String DeacUserAsia1;
        public String digiFirstName;
        public String digiLastName;
        public String digiEmail;
        public Map<String, String> accountMap;
        public Map<String, Boolean> mapValidateResults;
        public Set<Id> packId;
        public Set<Id> zuoSubIdSet;
        public Set<Id> asia1SubIdSet;
        
        //START D-2942 25-06-2015 Marvin Gatchalian
        public set<Id> asiaIdSet = new set<id>();
        //END D-2942 25-06-2015 Marvin Gatchalian
        
        public List<Package_Access_Flag__c> pafList;
        public List<Asia1_Subscription__c> asia1SubList;
        public Asia1__c asia1Deac;
        //public Map<String, Asia1__c> mapUsername_Asia1; D-0917 [JB Domingo 11/25/2014]  
        public Map<Id, Asia1_Subscription__c> mapAsia1_AsiaSub;
        public Asia1_Subscription__c asia1SubAssociatedWithSelectedAsia1;
        public Asia1_Subscription__c asia1SubRec;
        //START: UD-0900 5/5/2015 Added by JTeves - error message if Sub Category is invalid
        public String returnText {get; set;}
        public String returnUrl {get; set;}
        public Boolean isValidSubCategory {get; set;}
        public String errorMessage {get; set;}
        //END: UD-0900 5/5/2015 Added by JTeves
        //START: UD-1065 5/7/2015 Added by JTeves - validation for lookup filter
        private final String LOOKUP_FILTER_ERROR = 'Asia1 user record must be under the same Account.';
        //END: UD-1065 5/7/2015 Added by JTeves - validation for lookup filter
       
        //START UD-1065 AddedbyFrancisBenzon 8/12/15 : variables for DComplaints Asia1
        public list<SelectOption> asia1WithAccessFlags { get; set; }
        public String thisSelectedAsia1 {get; set;}
        public Id accountId;
        public Id subMainPackId;
        public Id subRecipientId;
        //END UD-1065 AddedbyFrancisBenzon 8/12/15 : variables for DComplaints Asia1
        //START UD-3324 27Nov15 francisBenzon : variables deactivate user
        public String deacAsia1UserId {get;set;}
        public list<SelectOption> asia1sForSub {get;set;}
        List<Asia1_Subscription__c> deacAsia1SubsList = new List<Asia1_Subscription__c>();
        //END UD-3324 27Nov15 francisBenzon : variables deactivate user
        
        private boolean isAsia1Validated = false; //START-END UD-3896 4/1/2016 Added by J.Sarion
        final string ACTIVE = 'Active'; // Start/End UD-3391 02Apr16 JohnD
        final string ERR_NO_SUB = 'No Subscription selected.';
        final string ERR_INV_SUB = 'Only active subscription is allowed.';
        //START: UD-3952 04-18-2016 Added by Kristine Balaoing - added variables
        final string ERRORS = 'Errors';
        final string ERR_RESP = 'is already disabled';
        final string SUCCESS = 'Success';
        //END: UD-3952 04-18-2016 Added by Kristine Balaoing
        
        public DigitalComplaintItemsExtension(ApexPages.standardController controller) {
            //START: UD-0900 5/5/2015 Added by JTeves - error message if Sub Category is invalid
            returnText = Error_Messages__c.getInstance('Return To Previous Page').Message__c;
            returnUrl = '/home/home.jsp';
            isValidSubCategory = true;
            //END: UD-0900 5/5/2015 Added by JTeves
            
            this.asia1 = new Asia1__c();
            this.digital =(Digital_Complaint_Items__c)controller.getRecord(); 
            accountMap = new Map<String, String>();
            packId = new Set<Id>();
            pafList = new List<Package_Access_Flag__c>();
            asia1Subscriptions = new List<Asia1Wrapper>();
            asia1List = new List<Asia1__c> ();
            SVCSet = new Set<String>();
            //mapUsername_Asia1 = new Map<String, Asia1__c>();
            mapAsia1_AsiaSub = new Map<Id, Asia1_Subscription__c>();
            initializeAsia1Components();
            asia1SubAssociatedWithSelectedAsia1 = new Asia1_Subscription__c();
            
            //START UD-3324 27Nov15 francisBenzon : vars
            asia1sForSub = new list<SelectOption>();
            asia1sForSub.add(new SelectOption('--None--', '--None--'));
            Set<String> ldapSetChecker = new Set<String>();
            //END UD-3324 27Nov15 francisBenzon : vars
            
            // Start UD-3452 19Jan16 JohnD - added Office Number field
            // Start UD-3391 15Mar16 JohnD - added AccountNumber, Qty__c fields
            // Start UD-3391 02Mar16 JohnD - added Subscription_Name__r.Name, Subscription_Name__r.Status_formula__c fields
            c = [SELECT Id, Account.Id, Account.Name, Account.AccountNumber, CaseNumber,Subscription_Name__c,Sub_Category__c, SuppliedEmail,
                 ContactId, Contact.FirstName, Contact.LastName, Contact.Phone, Subscription_Name__r.Recipient_Contact__r.HomePhone__c,
                 Subscription_Name__r.Recipient_Contact__r.Phone, Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c,
                 Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c, Subscription_Name__r.Recipient_Contact__r.Office_Number__c, 
                 Subscription_Name__r.Qty__c, Subscription_Name__r.Name, Subscription_Name__r.Status_formula__c, Subscription_Name__r.Recipient_Contact__r.FirstName, Subscription_Name__r.Recipient_Contact__r.LastName
                FROM Case 
                WHERE Id = :ApexPages.currentPage().getParameters().get('caseId')]; //gets case Record from Page
            // End UD-3391 02Mar16 JohnD - added Subscription_Name__r.Name, Subscription_Name__r.Status_formula__c fields
            // End UD-3391 15Mar16 JohnD - added AccountNumber, Qty__c fields
            // End UD-3452 19Jan16 JohnD - added Office Number field
            //START: UD-0900 5/5/2015 Added by JTeves - error message if Sub Category is invalid
            if(c != null && c.Id != null) {
                //START UD-1065 8/12/15 AddedBy FrancisBenzon : account Id to be used as input param
                accountId = c.Account.Id;
                //END UD-1065 8/12/15 AddedBy FrancisBenzon : account Id to be used as input param
                returnUrl = '/' + c.Id;
                //START UD-2484 Added by Dags to remove VF page for Force Logout
                if(c.Sub_Category__c == 'Service Flag Not Updated' || c.Sub_Category__c == 'App Crash / Slow Loading / Sys Issues'||c.Sub_Category__c == 'Force Logout' ) {
                    isValidSubCategory = false;
                    errorMessage = Error_Messages__c.getInstance('DigitalComplaint_NoFunctionality').Message__c;
                }
            }
            //END: UD-0900 5/5/2015 Added by JTeves
            //END UD-2484 Added by Dags to remove VF page for Force Logout
            
            //gets Zuora Subscription List associated with the Case
            //Start 8/13/15 UD-1065 AddedBy Francisbenzon : added recipient in query
            LIST <zuora__Subscription__c> zuoSubList = [SELECT Id, Name, Main_Package_1__c, Recipient_Contact__c, 
                                                        Recipient_Contact__r.LastName,Recipient_Contact__r.FirstName,
                                                        Recipient_Contact__r.Phone
                                                        FROM zuora__Subscription__c 
                                                        WHERE Id =: c.Subscription_Name__c]; //Gets Zuora based on the Subscription field
            //End 8/13/15 UD-1065 AddedBy Francisbenzon : added recipient in query
            
            //START UD-3324 27Nov15 francisBenzon : add values for select list
            deacAsia1SubsList = [Select Id, Name, Asia1__c, Asia1__r.User_ID_LDAP_ID__c 
                                From Asia1_Subscription__c 
                                Where Subscription__c = :c.Subscription_Name__c];
            if(deacAsia1SubsList.size() >0)
            {   
                for(Asia1_Subscription__c aSubs : deacAsia1SubsList)
                {
                    if(!ldapSetChecker.contains(aSubs.Asia1__r.User_ID_LDAP_ID__c))
                    {
                        asia1sForSub.add(new SelectOption(aSubs.Asia1__c, aSubs.Asia1__r.User_ID_LDAP_ID__c));
                        ldapSetChecker.add(aSubs.Asia1__r.User_ID_LDAP_ID__c);
                    }                 
                }
            }
            //END UD-3324 27Nov15 francisBenzon : add values for select list
            
            Set<Id> zuoSubIdSet = new Set<Id>();
            // for fields updated by system (auto-populated) across all sections
            //for creation of accountMap
            for (Zuora__Subscription__c zuoSubRec : zuoSubList)
                {
                    //Start 8/13/15 UD-1065 AddedBy Francisbenzon : input params to new method
                    subMainPackId = zuoSubRec.Main_Package_1__c;
                    subRecipientId = zuoSubRec.Recipient_Contact__c;
                    //End 8/13/15 UD-1065 AddedBy Francisbenzon : input params to new method
                    //james to insert here
                    digital.Account_Lookup_Field__c = c.Account.Id;
                    digital.Case_No__c = c.Id;
                    casenoName = c.CaseNumber;
                    accountName = c.Account.Name;
                    subsName = zuoSubRec.Name;
                    subcatName = c.Sub_Category__c;
                    accountMap.put(GlobalVariableClass.PASS_CHALLENGE, 'Challenging Password!');
                    accountMap.put(GlobalVariableClass.PASS_RESPONSE, 'Responding Password');
                    accountMap.put(GlobalVariableClass.FNAME, zuoSubRec.Recipient_Contact__r.LastName);
                    accountMap.put(GlobalVariableClass.LNAME, zuoSubRec.Recipient_Contact__r.FirstName);
                    accountMap.put(GlobalVariableClass.PHONE, zuoSubRec.Recipient_Contact__r.Phone);
                    accountMap.put(GlobalVariableClass.ENABLE, 'TRUE'); //question
                    packId.add(zuoSubRec.Main_Package_1__c);
                    zuoSubIdSet.add(zuoSubRec.Id);
                    
                }
            // Start : Code Review / K. Tan 
            LIST <Asia1_Subscription__c> asia1SubList = new LIST <Asia1_Subscription__c>(); 
            if(!zuoSubIdSet.isEmpty()) {
            //generate List of Asia Subscription under the Subacsription associated with the Case
                 asia1SubList = [SELECT Asia1__c, Asia1__r.Id, Subscription__c, Status__c 
                                                             FROM Asia1_Subscription__c 
                                                             WHERE Subscription__c IN :zuoSubIdSet];
            }
            // END : Code Review / K. Tan   
                                         
            Set<Id> asia1IdSet = new Set<Id>();
            for(Asia1_Subscription__c asia1SubRec : asia1SubList)
                {
                    // Start : Code Review / K. Tan 
                    if(asia1SubRec.Asia1__c != null) {
                        asia1IdSet.add(asia1SubRec.Asia1__c);
                        mapAsia1_AsiaSub.put(asia1SubRec.Asia1__r.Id, asia1SubRec);
                    }
                    // END : Code Review / K. Tan   

                }
            // Start : Code Review / K. Tan                 
            List<Asia1__c> asia1List = new List<Asia1__c>();
            
            if (!asia1IdSet.isEmpty()) { // KARL
                asia1List = [SELECT Id, User_ID_LDAP_ID__c,  Email__c, Contact__r.FirstName, Contact__r.LastName,                                   Contact__r.Phone, Password__c, Display_Name__c, Secret_Answer__c, Secret_Question__c
                                            FROM Asia1__c 
                                            WHERE Id IN :asia1IdSet];
            }
            // END : Code Review / K. Tan   
            
            enabledAsia1Options = new List<SelectOption>();
            for(Asia1__c asia1 : asia1List)
            {
                enabledAsia1Options.add(new SelectOption('--None--','--None--'));
                enabledAsia1Options.add(new SelectOption(asia1.User_ID_LDAP_ID__c, asia1.User_ID_LDAP_ID__c));
                //mapUsername_Asia1.put(asia1.Id, asia1);
            }
            
            // Start : Code Review / K. Tan                             
            if(!packId.isEmpty()) {
                pafList = [SELECT Id, Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, 
                                                        No_of_Concurrent_Users__c 
                                                        FROM Package_Access_Flag__c 
                                                        WHERE Package__c IN :packId];
            }
            // END : Code Review / K. Tan               
            for(Package_Access_Flag__c psaf : pafList)
                {
                    // Start : Code Review / K. Tan                             
                    if(psaf.Package_Service_Access_Flag__r.Name != null) {
                        SVCSet.add(psaf.Package_Service_Access_Flag__r.Name);
                    }
                    // END : Code Review / K. Tan   

                    Integer counter = 0;
                    for (String SVC : SVCSet)
                        {
                            SVCResult = SVCResult + SVC;
                            if(counter<SVCSet.size() -1)
                            {
                                SVCResult = SVCResult +'|';
                                counter++;
                            }
                        }
                    accountMap.put(GlobalVariableClass.SVC, SVCResult); //change SVCSet to Result
                }
                
            //for Suppress Email to Customer
            if (subcatName == 'Deactivate User Id' || subcatName == 'Force Logout') {
                          suppress = False;  
                      } else {
                          suppress = True;                      
                      }
            //START UD-1065 8/12/15 AddedBy FrancisBenzon : specific query for Change/Reset Password
            if(subcatName == 'Change/Reset Password')
            {
                getRelatedAsia1sWithAccessFlag(subMainPackId, subRecipientId);
            }
            //END UD-1065 8/12/15 AddedBy FrancisBenzon : specific query for Change/Reset Password
             
        }
        
         // start asia1 components
        public transient string selectedAsia1Creation { get; set; }
        public transient string asia1SelectedExistingId { get; set; }
        public transient string asia1IdToBeRemoved { get; set; }
        public transient string selectedPackageId { get; set; }
        public transient boolean isCreateNew { get; set; }
        public string ldapValidityImg { get; set; }
        public string displayNameValidityImg { get; set; }
        //START: UD-3819 1/26/16 Added by Manolo Valena
        public Boolean isExistingS { get; set; }
        //END: UD-3819 1/26/16 Added by Manolo Valena
        

        
        private void initializeAsia1Components() {
            isCreateNew = true;
            asia1Subscriptions = new list<Asia1Wrapper>();
            ldapValidityImg = '/s.gif';
            displayNameValidityImg = '/s.gif';
        }
       
        
        public class Asia1Wrapper  {
            public string userId { get; set; }
            public string asia1Id { get; set; }
            public String displayName { get; set; }
            public String Email { get; set; }
            public String Password { get; set;}
            public list<Asia1SubscriptionWrapper> asia1Subscriptions { get; set; } 
        }
        
        
        public class Asia1SubscriptionWrapper {
            public string serviceFlagId { get; set; }
            public string serviceFlagName { get; set; }
            public string status { get; set; }
            public integer concurrent { get; set; }
        }
        
        
        public void addAsia1ExistingAccount() {

            // Start UD-3391 15Mar16 JohnD - new logic due to CR
            Asia1__c tmpAsia1 = [select Id, User_ID_LDAP_ID__c, Display_Name__c, Email__c, Password__c from Asia1__c where Id = :asia1SelectedExistingId];
            createAsia1SubscriptionFromAccessFlag(tmpAsia1.User_ID_LDAP_ID__c, tmpAsia1.Id, tmpAsia1.Display_Name__c, tmpAsia1.Email__c, tmpAsia1.Password__c);
            // End UD-3391 15Mar16 JohnD - new logic due to CR
            
            // Start UD-3391 15Mar16 JohnD - commented out due to CR
            /*
            //START UD-2058 28/7/2015 Gdel rosario : added this to get the Quantity from the subscription
            system.debug('gddr - subscription Name from Case: ' + c.Subscription_Name__c );
                LIST <zuora__Subscription__c> zuoSubList = [SELECT Id, Name, Main_Package_1__c,
                                                          Recipient_Contact__r.LastName,Recipient_Contact__r.FirstName,Qty__c,
                                                          Recipient_Contact__r.Phone
                                                          FROM zuora__Subscription__c 
                                                          WHERE Id =: c.Subscription_Name__c LIMIT 1];

                // Start UD-2532 31Aug15 JohnD - commented out
                /*
                LIST <Asia1_Subscription__c> asia1InsideSub = [SELECT Asia1__c,Id,Name,Status__c,Subscription__c 
                                                                FROM Asia1_Subscription__c 
                                                                WHERE Subscription__c =: c.Subscription_Name__c 
                                                                AND Status__c =: GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED];
                * /
                // End UD-2532 31Aug15 JohnD - commented out
                
                integer totalAsia1EnabledAccounts = getTotalAsia1EnabledAccounts(c.Subscription_Name__c); // Start/End UD-2532 31Aug15 JohnD

              if(zuoSubList.size() > 0){
                if(zuoSubList[0].Qty__c != null){
                  quantity = zuoSubList[0].Qty__c;  
                }else {
                  quantity = 0;
                }
                // Start UD-2532 31Aug15 JohnD - replaced asia1InsideSub to totalAsia1EnabledAccounts
                //if(totalAsia1EnabledAccounts > 0) { // commented out
                  totalQuantityFromAll = totalAsia1EnabledAccounts + asia1Subscriptions.size() + 1;
                //} // commented out
                // End UD-2532 31Aug15 JohnD - replaced asia1InsideSub to totalAsia1EnabledAccounts
              } 
              system.debug(' gddr - quantity  : ' +quantity );
              system.debug(' gddr - totalQuantityFromAll: ' + totalQuantityFromAll);
              if(quantity>=totalQuantityFromAll){
                isErrorQty=false;
                //END UD-2058 28/7/2015 Gdel rosario : added this to get the Quantity from the subscription  
                
            Asia1__c tmpAsia1 = [select Id, User_ID_LDAP_ID__c, Display_Name__c, Email__c, Password__c from Asia1__c where Id = :asia1SelectedExistingId];
            createAsia1SubscriptionFromAccessFlag(tmpAsia1.User_ID_LDAP_ID__c, tmpAsia1.Id, tmpAsia1.Display_Name__c, tmpAsia1.Email__c, tmpAsia1.Password__c);
           //START UD-2058 28/7/2015 Gdel rosario : added this to get the Quantity from the subscription   
          system.debug(' gddr - Existing - asia1Subscriptions after : ' + asia1Subscriptions.size() );
            }else {
              system.debug(' gddr - Existing - PUMASOK SA ELSE' );
              isErrorQty=true;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('asia1quantity')));
            }
            //END UD-2058 28/7/2015 Gdel rosario : added this to get the Quantity from the subscription  
            */
            // End UD-3391 15Mar16 JohnD - commented out due to CR
        }
        /*
         * This method will create a new asia 1 account
        */
        public void addAsia1NewAccount() {
            //START UD-3896 4/1/2016 Added by J.Sarion - check asia1
            isAsia1Validated = false;
            Validate();
            if (isAsia1Validated && asia1.User_ID_LDAP_ID__c != null && asia1.Display_Name__c != null) {
                if(mapValidateResults.get('userNameValidationResult') == true && mapValidateResults.get('dispNameValidationResult') && asia1.Password__c != null && asia1.Password__c != '') {          
                    // Start UD-3391 15Mar16 JohnD - new logic due to CR
                    createAsia1SubscriptionFromAccessFlag(asia1.User_ID_LDAP_ID__c, asia1.Id, asia1.Display_Name__c, asia1.Email__c, asia1.Password__c);
                    ldapValidityImg = '/s.gif';
                    displayNameValidityImg = '/s.gif';
                    // End UD-3391 15Mar16 JohnD - new logic due to CR
                }
                else if(asia1.Password__c == null || asia1.Password__c != '') {
                    ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'Password is required'));
                }
            }
            if(asia1.Password__c == null || asia1.Password__c == '') {
                    ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'Password is required'));
            }
            //END UD-3896 4/1/2016 Added by J.Sarion - check asia1
            // Start UD-3391 15Mar16 JohnD - commented out due to CR
            /*
            System.debug('I WAS CALLED---ADD');
            //START D-2942 25-06-2015 Marvin Gatchalian
          
          try {
          //START UD-2058 28/7/2015 Gdel rosario : added this to get the Quantity from the subscription
              system.debug('gddr - subscription Name from Case: ' + c.Subscription_Name__c );
              LIST <zuora__Subscription__c> zuoSubList = [SELECT Id, Name, Main_Package_1__c,
                                                          Recipient_Contact__r.LastName,Recipient_Contact__r.FirstName,Qty__c,
                                                          Recipient_Contact__r.Phone
                                                          FROM zuora__Subscription__c 
                                                          WHERE Id =: c.Subscription_Name__c LIMIT 1];

                // Start UD-2532 31Aug15 JohnD - commented out
                /*
                LIST <Asia1_Subscription__c> asia1InsideSub = [SELECT Asia1__c,Id,Name,Status__c,Subscription__c 
                                                                FROM Asia1_Subscription__c 
                                                                WHERE Subscription__c =: c.Subscription_Name__c 
                                                                AND Status__c =: GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED];
                * /
                // End UD-2532 31Aug15 JohnD - commented out
                
                integer totalAsia1EnabledAccounts = getTotalAsia1EnabledAccounts(c.Subscription_Name__c); // Start/End UD-2532 31Aug15 JohnD
              if(zuoSubList.size() > 0){
                if(zuoSubList[0].Qty__c != null){
                  quantity = zuoSubList[0].Qty__c;  
                }else {
                  quantity = 0;
                }

                // Start UD-2532 31Aug15 JohnD - replaced asia1InsideSub to totalAsia1EnabledAccounts
                //if(totalAsia1EnabledAccounts > 0) { // commented out
                  totalQuantityFromAll = totalAsia1EnabledAccounts + asia1Subscriptions.size() + 1;
                //} // commented out
                // End UD-2532 31Aug15 JohnD - replaced asia1InsideSub to totalAsia1EnabledAccounts
              } 
              system.debug(' gddr - quantity  : ' +quantity );
              system.debug(' gddr - totalQuantityFromAll: ' + totalQuantityFromAll);

              if(quantity>=totalQuantityFromAll){
                isErrorQty = false;
          //END UD-2058 28/7/2015 Gdel rosario : added this to get the Quantity from the subscription  
                  
                  asia1.Status__c = 'Pending Creation';
            asia1.Contact__c  = c.Contact.id;
            insert asia1;
            
            asiaIdSet.add (asia1.id);
            //END D-2942 25-06-2015 Marvin Gatchalian
            
            createAsia1SubscriptionFromAccessFlag(asia1.User_ID_LDAP_ID__c, asia1.Id, asia1.Display_Name__c, asia1.Email__c, asia1.Password__c);
            
            // reset asia1 single account
            asia1 = new Asia1__c();
            // end reset asia1 single account

              ldapValidityImg = '/s.gif';
              displayNameValidityImg = '/s.gif';
          //START UD-2058 28/7/2015 Gdel rosario : added this to get the Quantity from the subscription
                  system.debug(' gddr - asia1Subscriptions after : ' + asia1Subscriptions.size() );
              }else {
                isErrorQty=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('asia1quantity')));
              }  
             //END UD-2058 28/7/2015 Gdel rosario : added this to get the Quantity from the subscription  
          } catch (exception e) { 
              
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
          }
          */
          // End UD-3391 15Mar16 Johnd - commented out due to CR
        }
        
        
        
        
        /*
         * Description: This method will retrieve the corresponding access flag associated package
         * @param: 
         *    ldapid
         *    asia1id
         *    packageid
        */
        private void createAsia1SubscriptionFromAccessFlag(string ldapId, id asia1Id, string displayName, string email, string password) {

            Asia1Wrapper newAsia1Subscription = new Asia1Wrapper();
            newAsia1Subscription.userId = ldapId;
            newAsia1Subscription.asia1Id = asia1Id;
            newAsia1Subscription.displayName = displayName;
            newAsia1Subscription.Email = email;
            newAsia1Subscription.Password = password;
            
          list<Asia1SubscriptionWrapper> tmpAsia1Subscriptions = new list<Asia1SubscriptionWrapper>();
            
            for (Package_Access_Flag__c paf : pafList) {
                
                Asia1SubscriptionWrapper tmpAsia1Sub = new Asia1SubscriptionWrapper();
                
                tmpAsia1Sub.status = 'Disabled';
                tmpAsia1Sub.serviceFlagId = paf.Package_Service_Access_Flag__c;
                tmpAsia1Sub.serviceFlagName = paf.Package_Service_Access_Flag__r.Name;
                
                // Start UD-3391 15Mar16 JohnD - added Qty__c
                if (paf.No_of_Concurrent_Users__c != null && c.Subscription_Name__c != null && c.Subscription_Name__r.Qty__c != null) {
                    tmpAsia1Sub.concurrent = integer.valueOf(paf.No_of_Concurrent_Users__c) * integer.valueOf(c.Subscription_Name__r.Qty__c);
                }
                // End UD-3391 15Mar16 JohnD - added Qty__c
                
                tmpAsia1Subscriptions.add(tmpAsia1Sub);
            }
            
            newAsia1Subscription.asia1Subscriptions = tmpAsia1Subscriptions;
            
            asia1Subscriptions.add(newAsia1Subscription);
        }
        

        public void validateNewAsia1Account() {
            
            // check require fields
            if (asia1.User_ID_LDAP_ID__c != null && asia1.Display_Name__c != null) {
                
                // call to asia1 actual
                map<string, Object> isValidUserName = AsiaOneServicesController.validateUserName(asia1.User_ID_LDAP_ID__c);
                if ( isValidUserName.get('User-Availability') == 'Success') {
                    ldapValidityImg = '/resource/check';
                } else {
                    ldapValidityImg = '/resource/wrong';
                }
                
                map<string, Object> isValidDisplayName = AsiaOneServicesController.validateUserName(asia1.Display_Name__c);
                if (isValidDisplayName.get('DisplayName-Availability') == 'Success') {
                    displayNameValidityImg = '/resource/check';
                } else {
                    displayNameValidityImg = '/resource/wrong';
                } 
                // end call to asia1 actual
                
                
            } else {
                
                ldapValidityImg = '/s.gif';
                displayNameValidityImg = '/s.gif';
                
                if (asia1.User_ID_LDAP_ID__c == null) {
                    asia1.User_ID_LDAP_ID__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
                }
                
                if (asia1.Display_Name__c == null) {
                    asia1.Display_Name__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
                }
                
            }

            // end check require fields
        }
        
        
        public void removeAsia1Subscription() {
            
            integer i = 0;
            //D-4675 4-15-2016 Added by Kristine Balaoing - modified logic for remove button
            /*
            for (i = 0; i < asia1Subscriptions.size(); i++) {   
                if (asia1Subscriptions.get(i).asia1Id == asia1IdToBeRemoved) {
                    asia1Subscriptions.remove(i);
                }
            }
            try {
                  delete [select id from Asia1__c where Id = :asia1IdToBeRemoved and Status__c = 'Pending Creation'];
                } catch (exception e) {
                    System.assertEquals(null, e);
                }
                */
            asia1Subscriptions = new List<Asia1Wrapper>();
            //D-4675 4-15-2016 Added by Kristine Balaoing
        }
        
        
        public list<Package_Access_Flag__c> retrieveServiceFlags(id pkgId) {
            
            return [select Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, 
                    No_of_Concurrent_Users__c from Package_Access_Flag__c where Package__c = :pkgId];
            
        }
        
        
        public list<SelectOption> getAsia1ExistingAccounts() {
            
            set<id> tmpAsia1Ids = new set<id>();
            for (Asia1Wrapper tmpw : asia1Subscriptions) {
            
                tmpAsia1Ids.add(tmpw.asia1Id);
            }
            
            list<SelectOption> options = new list<SelectOption>();
            
            
            for (Asia1__c asia1 : [select Id, User_ID_LDAP_ID__c from Asia1__c where Contact__c = :c.ContactId  and Id not in :tmpAsia1Ids]) {
                options.add(new SelectOption(asia1.Id, asia1.User_ID_LDAP_ID__c));
            }
            
            return options;
        }
        
        
        
        
        private void createAsia1Subscription(list<Asia1Wrapper> asia1SubscriptionList) {
          
          list<Asia1_Subscription__c> newAsia1Subscriptions = new list<Asia1_Subscription__c>();
          map<string, list<Asia1_Subscription__c>> userId_asia1Subscriptions = new map<string, list<Asia1_Subscription__c>>();
        system.debug('asia1SubscriptionList'+asia1SubscriptionList);
        for (Asia1Wrapper asia1Tmp : asia1SubscriptionList) {
          
        //START D-2402 27-Feb-2015 Added by Raviteja  - commented the Asia1_Subscription__c intializaation in order to create mulitple Asia1_Subscription__c for Asia1 as per the number of Package Access Flags in Package record from Subscription record
            Asia1_Subscription__c as1;
          
          for (Asia1SubscriptionWrapper asia1SubscriptionTmp : asia1Tmp.asia1Subscriptions) {
            as1 = new Asia1_Subscription__c();
            
            as1.Asia1__c = asia1Tmp.asia1Id;
            as1.Concurrent__c = asia1SubscriptionTmp.concurrent;
            as1.Service_Access_Flag__c = asia1SubscriptionTmp.serviceFlagId;
            as1.Status__c = 'Enabled';      
            as1.Subscription__c = c.Subscription_Name__c;
            newAsia1Subscriptions.add(as1);
            }
          
          //End D-2402 27-Feb-2015 Added by Raviteja
          
        }
        
        try {
            system.debug('newAsia1Subscriptions'+newAsia1Subscriptions);
          insert newAsia1Subscriptions;
        } catch (exception e) {
          ApexPages.addMessages(e);
        }
        }
        
        // end asia1 components
        public String getEnabledAsia1(){
            return enabledAsia1;
        }
        
        
        //not sure if there is no risk of using Asia1 variable again
        public void populateDisableServiceFields(){
            //digiUserNameText = digital.SPH_Online_User_Id__c;
            digiAsiaOne = digital.Asia1__c;
            //added to catch value selected in EnabledAsia1Options
        
            //for SelectList
            //if(mapUsername_Asia1.containsKey(digiAsiaOne)){
                //digital.First_Name__c = mapUsername_Asia1.get(digiAsiaOne).Contact__r.FirstName;
                //digital.Last_Name__c =  mapUsername_Asia1.get(digiAsiaOne).Contact__r.LastName;
                //digital.Email__c = mapUsername_Asia1.get(digiAsiaOne).Email__c;
                
                digital.First_Name__c = digital.Asia1__r.Contact__r.FirstName;
                digital.Last_Name__c = digital.Asia1__r.Contact__r.LastName;
                digital.Email__c = digital.Asia1__r.Email__c;
            //}
            //else{
                //digital.addError('Username does not exist. Check your spelling.');
            //}
            
        }
        
        public PageReference SaveMe() {
                DigitalComplaintController digiComController = new DigitalComplaintController();
                //START D-2402 27-Feb-2015 Added by Raviteja  - Assigend value as '' // End
                String serviceFlag='';
                Asia1__c asia1obj;
                //START D-2402 27-Feb-2015 Added by Raviteja  - Prepared the List to store multiple values
                List<Asia1_Subscription__c> asia1Sub;
                //fields from Digital Complaint Items
                //digiUserNameText = mapUsername_Asia1.get()digital.SPH_Online_User_Id__c;
            //START UD-1065 AddedBy FrancisBenzon : assign value to asia1, only asia1 with accessflag is valid 
            //System.assertEquals(null, subcatName);
            if(subcatName =='Change/Reset Password' && thisSelectedAsia1 != null)
            {
                asia1Id = thisSelectedAsia1;
                try {
                    Asia1__c thisAsia1 = [Select id From Asia1__c Where Id = :asia1Id];
                    digital.Asia1__c = thisAsia1.Id;                            
                }
                catch(exception e)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select User Id.')); 
                    return null;
                }
                
            }
            
            //END UD-1065 AddedBy FrancisBenzon : assign value to asia1, only asia1 with accessflag is valid
                if(subcatName != 'User Id Not Created/Activated'){
                    
                    if(digital != null){
                    //START: UD-3515 1-06-2015 added by Jason A.    
                        try{
                            asia1obj = [SELECT Id, User_ID_LDAP_ID__c FROM Asia1__c WHERE Id =: digital.Asia1__c LIMIT 1]; //D-0917 11/25/2014
                        }
                        catch(exception e){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Username'));
                            return null;
                        }
                    //END: UD-3515 1-06-2015 added by Jason A.
                    }
                        System.debug('>>>>ASIA1OBJ:' + asia1obj);
                        //KCampang D-0917 11/27/2014
                        if(asia1obj != null){
                            try{
                                //START D-2402 27-Feb-2015 Added by Raviteja  - //nitin K : D-2402 : 27-2-15
                                //START UD-2530 9/1/15 AddedBy FrancisBenzon : display asia1 related to asia1 id and subscription.
                                if(subsName != null)
                                {
                                    asia1Sub = [SELECT Id, Status__c, Service_Access_Flag__r.Name, Asia1__c FROM Asia1_Subscription__c 
                                                WHERE Asia1__c=: asia1obj.Id AND Subscription__r.name = :subsName];
                                }                               
                                //END UD-2530 9/1/15 AddedBy FrancisBenzon : display asia1 related to asia1 id and subscription.
                                //End D-2402 27-Feb-2015 Added by Raviteja - END D-2402                        
                            }
                            catch(Exception e){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('No Asia1 Subscription')));
                            }
                        }
                        System.debug('>>>>ASIA1SUB:' + asia1Sub);
                        System.debug('>>>>>>DIGIUSERNAME:' + digiUsername);

                        //START D-2402 27-Feb-2015 Added by Raviteja  - nitin K : D-2402 : 27-2-15
                        if(asia1Sub.size() > 0){
                            for(Asia1_Subscription__c x : asia1Sub){
                            
                                integer counter = 0;

                                serviceFlag = serviceFlag + x.Service_Access_Flag__r.Name;
                                if(counter < asia1Sub.size() -1)
                                {
                                    serviceFlag = serviceFlag +'|';
                                    counter++;
                                }
                            
                            }
                         //End D-2402 27-Feb-2015 Added by Raviteja - End
                        }
                }
                //Start Added by FrancisBenzon to catch attemp to dereference null error 
                //Encountered during D-1264 fix
                if(asia1obj != null) {
                    digiUsername = asia1obj.User_ID_LDAP_ID__c;  
                } 
                //End Added by FrancisBenzon to catch attemp to dereference null error              
                digiFirstName = digital.First_Name__c;
                digiLastName = digital.Last_Name__c;
                digiEmail = digital.Email__c;
                displayName = 'display';
                digiNewPass = digital.New_Password__c;
                
                //fields from Asia1
                asia1Id = digital.Asia1__c;
                asiaUsername = asia1.User_ID_LDAP_ID__c;
                asiaDisplayName = asia1.Display_Name__c;
                asia1NewPass = asia1.Password__c;
                asia1Email = asia1.Email__c;
                                
                //putting inputted values to the accountMap iterating thorugh Asia1 Subscription  Wrapper List 
                //System Debugs
                if (subcatName =='Change/Reset Password')
                    {/* D-0917 [JB Domingo 11/25/2014] 
                        if(!mapUsername_Asia1.containsKey(digiUsername))
                        {
                            digital.addError('Username does not exist. Check your spelling.');
                            return null;
                        }
                        else 
                            {
                            */    
                            //START: UD-1065 06/01/2015 Karen Hung add validation if user Id is under the account
                            if(digital.Asia1__c != null) {
                                Asia1__c asia1Rec = [SELECT Id, User_ID_LDAP_ID__c, Contact__r.AccountId FROM Asia1__c WHERE Id = :digital.Asia1__c];
                                if(asia1Rec.Contact__r.AccountId != digital.Account_Lookup_Field__c) {
                                    digital.Asia1__c.addError(LOOKUP_FILTER_ERROR);
                                    return null;
                                }
                            }
                            //END: UD-1065 06/01/2015 Karen Hung                            
                                resetPass = digiComController.resetPassword(c, digiUsername , asia1Id, digiNewPass, serviceFlag, digital.Asia1__r.Display_Name__c);
                               
                                    if(resetPass==FALSE)
                                        {
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, digiComController.getErrors())); 
                                            return null;
                                        //String errorContainer = digiComController.getErrors();
                                        }
                            //}D-0917 [JB Domingo 11/25/2014] 
                    }
                else if (subcatName == 'Deactivate User Id')
                {
                    //START UD-0877 04-27-2015 MarvinG
                    //START: UD-1065 5/7/2015 Added by JTeves - validation for lookup filter
                    if(digital.Asia1__c != null) {
                        Asia1__c asia1Rec = [SELECT Id, User_ID_LDAP_ID__c, Contact__r.AccountId FROM Asia1__c WHERE Id = :digital.Asia1__c];
                        if(asia1Rec.Contact__r.AccountId != digital.Account_Lookup_Field__c) {
                            digital.Asia1__c.addError(LOOKUP_FILTER_ERROR);
                            return null;
                        }
                    }
                    //END: UD-1065 5/7/2015 Added by JTeves - validation for lookup filter
                    string errorResponse;
                    //START: UD-3952 4-18-2016 Added by Kristine Balaoing - commented out hardcorded error response
                    //errorResponse = 'Failed, the username is already disabled.'; //START-END: D-2893 05/20/2015 Jean Cari?o
                    if (deactivateID (asia1Obj.User_ID_LDAP_ID__c, asia1Sub)){
                        asia1Obj.Status__c = 'Disabled';
                        //START UD-2488 08/22/2015 Added by J.Sarion - unchecked Enable checkbox
                        asia1Obj.Enabled__c = false;
                        //END UD-2488 08/22/2015 Added by J.Sarion - unchecked Enable checkbox
                        update asia1Obj;
                    }
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorResponse )); 
                        return null;
                    }
                    //END: UD-3952 4-18-2016 Added by Kristine Balaoing
                    //END UD-0877 04-27-2015 MarvinG
                    
                }
                else if (subcatName =='User Id Not Created/Activated')
                {
                    //System.assertEquals(1,2);
                    // Start UD-3391 15Mar16 JohnD - revised logic due to CR
                    // Start UD-3391 02Apr16 JohnD - add/change value
                    if (c.Subscription_Name__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_NO_SUB)); 
                        return null;
                    }
                    
                    if (c.Subscription_Name__r.Status_Formula__c != ACTIVE) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_INV_SUB)); 
                        return null;
                    }
                    //End UD-3391 02Apr16 JohnD - add/change value
                    
                    list<Digital_Complaint_Items__c> digitalComplaintItems = new list<Digital_Complaint_Items__c>();
                    string errorMessage;
                    string ldapId;
                    string password;
                    
                    if (isExistingS == null) {
                        isExistingS = false;
                    }
                    
                    for (Asia1Wrapper asia1SingleWrap : asia1Subscriptions) {   // loop only once since it will only contain 1 record
                        
                        digitalComplaintItems.add(digiComController.createDigitalComplaintItems(c, asia1SingleWrap.userId ,asia1SingleWrap.Password, serviceFlag, asia1SingleWrap.displayName, 'Success'));
                        
                        ldapId = asia1SingleWrap.userId;
                        //START: UD-3952 4-18-2016 Added by Kristine Balaoing - added logic for first name and lastname
                        if (!isExistingS) { 
                            
                            String asia1phone = '1234567890'; 
                            String asia1FirstName;
                            String asia1LastName;
                            Map<String, String> accountMap = new Map<String, String>();                                           
                            accountMap.put(GlobalVariableClass.USERNAME, asia1SingleWrap.userId);
                            accountMap.put(GlobalVariableClass.DISPLAY_NAME, asia1SingleWrap.displayName);
                            accountMap.put(GlobalVariableClass.PASSWORD, asia1SingleWrap.Password);
                            accountMap.put(GlobalVariableClass.EMAIL, asia1SingleWrap.Email);
                            
                            if (c.Subscription_Name__r.Recipient_Contact__c != null) {
                                
                                if (c.Subscription_Name__r.Recipient_Contact__r.HomePhone__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.HomePhone__c);                          
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Phone != null) {                  
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Phone);
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c);
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c);
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Office_Number__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Office_Number__c);
                                }
                                
                                //D-4457 2-14-2016 Added by Kristine Balaoing - added first name and last name in the creation of asia1 account
                                if(c.Subscription_Name__r.Recipient_Contact__r.FirstName != null){
                                    asia1FirstName = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.FirstName);
                                }
                                if(c.Subscription_Name__r.Recipient_Contact__r.LastName != null){
                                    asia1LastName = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.LastName);
                                }
                                
                            }
                            //asia1FirstName.replaceAll(' ',''); 
                            //asia1LastName.replaceAll(' ',''); 
                            asia1phone.replaceAll(' ',''); 
                            accountMap.put(GlobalVariableClass.FNAME, asia1FirstName);
                            accountMap.put(GlobalVariableClass.LNAME, asia1LastName);
                            accountMap.put(GlobalVariableClass.PHONE,asia1phone);
                            //END: UD-3952 4-18-2016 Added by Kristine Balaoing 
                            map<string, object> response = AsiaOneServicesController.createAccount(accountMap);
                            //System.assertEquals(null, response);
                            
                            if (response.containsKey('Error') && response.get('Error') != null) {
                                
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, (string)response.get('Error'))); 
                                return null;
                            }

                            //START: UD-3943 04/12/2016 Added by Kristine Balaoing - added one more key Errors in case Error is not used
                            //START: UD-3952 04/18/2016 Added by Kristine Balaoing - modified comments
                             if (response.containsKey(ERRORS) && response.get(ERRORS) != null) {
                                
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, (string)response.get(ERRORS))); 
                                return null;
                            }
                            //END: UD-3952 04/18/2016 Added by Kristine Balaoing
                            //END: UD-3943 04/12/2016 Added by Kristine Balaoing
                            password = asia1SingleWrap.Password; 
                        }
                    }
                    
                    EshopLDAPAPI.Request req = new EshopLDAPAPI.Request();
                    req.subscriberId = c.Account.AccountNumber;
                    req.asiaOneLdapId = ldapId;
                    req.subscriptionIds =  new list<string>{c.Subscription_Name__r.Name};   // Start/End UD-3391 02Apr16 - change Id to Name
                    
                    EshopLDAPAPI.response res = EshopLDAPAPI.processRequest(req);
                    
                    if (res.error_message != null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, res.error_message)); 
                        return null;
                    }
                    
                    try {
                    
                        Asia1__c asia1ToBeUpdated = [select Id, Password__c from Asia1__c where User_ID_LDAP_ID__c = :ldapId 
                                order by createddate desc limit 1];
                        
                        asia1ToBeUpdated.Password__c = password;
                        
                        update asia1ToBeUpdated;
                        
                    } catch (exception e) {
                        
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
                        return null;
                    }
                    
                    // End UD-3391 15Mar16 JohnD - revised logic due to CR                    
                   
                    insert digitalComplaintItems;   // Start/End UD-3643 13Apr16 JohnD 
                    // Start UD-3391 15Mar16 JohnD - commented out due to CR
                    /* 
                    //START UD-2058 Gdelrosario 10/08/15 : added trigger error message in Sub quantity versus Asia1 quantity
                    // Start UD-2532 01Sep15 JohnD - commented out
                    /*
                    if(isErrorQty == true){
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('asia1quantity')));
                      return null;
                    }
                    * /
                    // End UD-2532 01Sep15 JohnD - commented out
            
                    list<Digital_Complaint_Items__c> digitalComplaintItems = new list<Digital_Complaint_Items__c>();
                    List<Asia1__c> asia1objList = new List<Asia1__c>();
                    //END UD-2058 Gdelrosario 10/08/15 : added trigger error message in Sub quantity versus Asia1 quantity
                    
                    for(Asia1Wrapper asia1SingleWrap : asia1Subscriptions){
                        digitalComplaintItems.add(digiComController.createDigitalComplaintItems(c, asia1SingleWrap.userId ,asia1SingleWrap.Password, serviceFlag, asia1SingleWrap.displayName, 'Success'));
                        String asia1phone;                      
                        // D-0916 [JB Domingo 11/26/2014]
                        Map<String, String> accountMap = new Map<String, String>();                                           
                        accountMap.put(GlobalVariableClass.USERNAME,asia1SingleWrap.userId);
                        accountMap.put(GlobalVariableClass.DISPLAY_NAME,asia1SingleWrap.displayName);
                        accountMap.put(GlobalVariableClass.PASSWORD,asia1SingleWrap.Password);
                        accountMap.put(GlobalVariableClass.EMAIL,asia1SingleWrap.Email);
                        //START D-1412 Modified by FrancisBenzon : considered other recipient contact phone numbers for create/deactivate Asia1 user                     
                        //START D-2402 27-Feb-2015 Added by Raviteja  - Calculating the list of serviceFlagName from asia1SingleWrap.asia1Subscriptions
                        String SVCResult =''; 
                        Integer counter = 0;
                        for (Asia1SubscriptionWrapper SVC : asia1SingleWrap.asia1Subscriptions)
                        {
                            SVCResult = SVCResult + SVC.serviceFlagName;
                            if(counter<SVCSet.size() -1)
                            {
                                SVCResult = SVCResult +'|';
                                counter++;
                           }
                        }
                        try {
                             accountMap.put(GlobalVariableClass.SVC,SVCResult); 
                            //End D-2402 27-Feb-2015 Added by Raviteja                     
                        }
                        catch(exception e) {
                            system.debug(e.getMessage());
                        } 
                        if(c.Subscription_Name__c != null) {
                            if(c.Subscription_Name__r.Recipient_Contact__c != null) {
                                if(c.Subscription_Name__r.Recipient_Contact__r.HomePhone__c != null){
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.HomePhone__c);                          
                                }
                                else if(c.Subscription_Name__r.Recipient_Contact__r.Phone != null){                  
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Phone);
                                }
                                else if(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c != null){
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c);
                                }
                                else if(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c != null){
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c);
                                // Start UD-3452 19Jan16 JohnD - added phone numbers
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Office_Number__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Office_Number__c);
                                } else {
                                    asia1phone = '1234567890';
                                }
                                // End UD-3452 19Jan16 JohnD - added phone numbers
                            }
                        }                       
                        //END D-1412 Modified by FrancisBenzon : considered other recipient contact phone numbers for create/deactivate Asia1 user
                        // Start UD-2532 01Sep15 JohnD - added null trapping
                        if (asia1phone != null) {
                            asia1phone.replaceAll(' ',''); 
                            accountMap.put(GlobalVariableClass.PHONE,asia1phone);
                        }          
                        // End UD-2532 01Sep15 JohnD - added null trapping
                        
                        //START D-2942 25-06-2015 Marvin Gatchalian 
                        //START: UD-3819 1/26/16 Added by Manolo Valena
                        if(isExistingS == null) {
                            isExistingS = false;
                        }
                        if (registerAsia1Accounts(c.Id, accountMap, isExistingS)) {
                        //END: UD-3819 1/26/16 Added by Manolo Valena
                            
                            
                            asia1objList = [SELECT Id, User_ID_LDAP_ID__c, Status__c FROM Asia1__c WHERE Id in :asiaIdSet];
                            for (Asia1__c eachAsia1 :asia1objList) {
                                eachAsia1.Status__c = 'Created';
                                eachAsia1.Enabled__c = true;
                            }
                            
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Registering Account, please click validate button and try again')); 
                            return null;
                        }
                        //START D-2942 25-06-2015 Marvin Gatchalian 
                        
                    } 
                    update asia1objList ;       //Start/END UD-2058 GDDel Rosaio        
                    insert digitalComplaintItems;
                    system.debug(asia1Subscriptions);
                    //START: UD-3819 1/26/16 Added by Manolo Valena
                    if(isExistingS == null) {
                        isExistingS = false;
                    }
                    if(!isExistingS) {    
                        createAsia1Subscription(asia1Subscriptions);    
                    }
                    else {
                        Set<Id> asiaOneIds = new Set<Id>();
                        List<Asia1__c> asiaOneList = new List<Asia1__c>();
                        List<Asia1_Subscription__c> asiaOneSubList = new List<Asia1_Subscription__c>();
                        for(Asia1Wrapper awRec : asia1Subscriptions) {
                            asiaOneIds.add(awRec.asia1Id);
                        }
                        if(asiaOneIds.size() > 0) {
                            for(Asia1__c aRec : [SELECT Id, Status__c, Enabled__c, 
                                                       (SELECT Id, Status__c FROM Asia1_Subscriptions__r 
                                                        WHERE Subscription__c =: c.Subscription_Name__c 
                                                        AND Status__c =: GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED
                                                        AND (Subscription__r.Zuora__SubscriptionEndDate__c >: date.today() OR 
                                                             Subscription__r.Zuora__SubscriptionEndDate__c = NULL)) 
                                                FROM Asia1__c 
                                                WHERE Id IN : asiaOneIds]) {
                                aRec.Status__c = GlobalVariableClass.ASIAONE_CREATED;
                                aRec.Enabled__c = true;
                                asiaOneList.add(aRec);
                                
                                if(aRec.Asia1_Subscriptions__r.size() > 0) {
                                    for(Asia1_Subscription__c asRec : aRec.Asia1_Subscriptions__r) {
                                        asRec.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
                                        asiaOneSubList.add(asRec);
                                    }
                                }
                            }
                            if(asiaOneList.size() > 0) {
                                update asiaOneList;
                            }
                            if(asiaOneSubList.size() > 0) {
                                update asiaOneSubList;
                            }
                        }
                    }
                    //END: UD-3819 1/26/16 Added by Manolo Valena
                    */ 
                    // End UD-3391 15Mar16 JohnD - commented out due to CR                  
                }
                PageReference pageRef = new pageReference('/' + c.Id);
                 pageRef.setRedirect(true);
                 return pageRef;
        }
        public void Validate(){
                DigitalComplaintController digiComController = new DigitalComplaintController();
                Boolean validUserName;
                Boolean validDispName;
                //Asia1 fields to be validated
                asiaUsername = asia1.User_ID_LDAP_ID__c;
                asiaDisplayName = asia1.Display_Name__c;

                if (asia1.User_ID_LDAP_ID__c != null && asia1.Display_Name__c != null) {
                    mapValidateResults = new Map<String, Boolean>(); 
                    mapValidateResults = digiComController.validateNewUsername(asiaUsername, asiaDisplayName);
                    validUserName=mapValidateResults.get('userNameValidationResult');
                    validDispName = mapValidateResults.get('dispNameValidationResult');
                        //validates Username 
                        if(validUserName==TRUE)
                        {
                                ldapValidityImg = '/resource/check';
                                isAsia1Validated = true; //START-END UD-3896 4/1/2016 Added by J.Sarion - set valid true
                        } else {
                            ldapValidityImg = '/resource/wrong';
                        }
                        //validates Display Name
                        if (validDispName == TRUE) {
                            displayNameValidityImg = '/resource/check';
                            isAsia1Validated = true; //START-END UD-3896 4/1/2016 Added by J.Sarion - set valid true
                        } else {
                            displayNameValidityImg = '/resource/wrong';
                        } 
                } else {
                
                    ldapValidityImg = '/s.gif';
                    displayNameValidityImg = '/s.gif';
                    
                    if (asia1.User_ID_LDAP_ID__c == null) {
                        asia1.User_ID_LDAP_ID__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
                    }
                    
                    if (asia1.Display_Name__c == null) {
                        asia1.Display_Name__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
                    }
                
                }
        }

        public PageReference saveandnew(){
                DigitalComplaintController digiComController = new DigitalComplaintController();
                String serviceFlag;
                Asia1__c asia1obj;
                //START D-2402 27-Feb-2015 Added by Raviteja  - Prepared the List to store multiple values
                List<Asia1_Subscription__c> asia1Sub;                
            //START UD-1065 AddedBy FrancisBenzon : assign value to asia1, only asia1 with accessflag is valid                                                          
            if(subcatName =='Change/Reset Password' && thisSelectedAsia1 != null)
            {
                asia1Id = thisSelectedAsia1;
                try {
                    Asia1__c thisAsia1 = [Select id From Asia1__c Where Id = :asia1Id];
                    digital.Asia1__c = thisAsia1.Id;                            
                }
                catch(exception e)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select User Id.')); 
                    return null;
                }
                
            }           
            //END UD-1065 AddedBy FrancisBenzon : assign value to asia1, only asia1 with accessflag is valid        
                //fields from Digital Complaint Items
                //digiUserNameText = digital.SPH_Online_User_Id__c;
                if(subcatName != 'User Id Not Created/Activated'){
                    if(digital != null){
                        
                            asia1obj = [SELECT Id, User_ID_LDAP_ID__c FROM Asia1__c WHERE Id =: digital.Asia1__c LIMIT 1]; //D-0917 11/25/2014
                        }
                        
                        System.debug('>>>>ASIA1OBJ:' + asia1obj);
                        //KCampang D-0917 11/27/2014
                        if(asia1obj != null){
                            try{
                                //START D-2402 27-Feb-2015 Added by Raviteja  - nitin K : D-2402 : 27-2-15                                
                                //START UD-2530 9/1/15 AddedBy FrancisBenzon : display asia1 related to asia1 id and subscription.
                                if(subsName != null)
                                {
                                    asia1Sub = [SELECT Id, Status__c, Service_Access_Flag__r.Name, Asia1__c FROM Asia1_Subscription__c 
                                                    WHERE Asia1__c =: asia1obj.Id AND Subscription__r.name = :subsName];
                                }
                                //END UD-2530 9/1/15 AddedBy FrancisBenzon : display asia1 related to asia1 id and subscription. 
                                 //End D-2402 27-Feb-2015 Added by Raviteja - end D-2402
                                
                            }
                            catch(Exception e){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('No Asia1 Subscription')));
                            }
                        }
                        System.debug('>>>>ASIA1SUB:' + asia1Sub);
                        System.debug('>>>>>>DIGIUSERNAME:' + digiUsername);
                        //START D-2402 27-Feb-2015 Added by Raviteja  - nitin K : D-2402 : 27-2-15                                
                        if(asia1Sub.size() > 0){
                            for(Asia1_Subscription__c x : asia1Sub){
                                
                                integer counter = 0;
                                serviceFlag = serviceFlag + x.Service_Access_Flag__r.Name;
                                if(counter < asia1Sub.size() -1)
                                {
                                    serviceFlag = serviceFlag +'|';
                                    counter++;
                                }
                                
                            }
                        }
                        //End D-2402 27-Feb-2015 Added by Raviteja - end D-2402
                }
                
                System.debug('SUB CAT >>> ' + subcatName);
                //Start D-2009 02/02/2015 Added by James - catch attempt to dereference null error
                if(asia1obj != null) {
                    digiUsername = asia1obj.User_ID_LDAP_ID__c;
                }
                //End D-2009 02/02/2015
                digiFirstName = digital.First_Name__c;
                digiLastName = digital.Last_Name__c;
                digiEmail = digital.Email__c;
                displayName = 'display';
                digiNewPass = digital.New_Password__c;
                
                //fields from Asia1
                asia1Id = digital.Asia1__c;
                asiaUsername = asia1.User_ID_LDAP_ID__c;
                asiaDisplayName = asia1.Display_Name__c;
                asia1NewPass = asia1.Password__c;
                asia1Email = asia1.Email__c;
                               
                //putting inputted values to the accountMap iterating thorugh Asia1 Subscription  Wrapper List 
                if (subcatName =='Change/Reset Password')
                    {
                    /* D-0917 [JB Domingo 11/25/2014] 
                        if(!mapUsername_Asia1.containsKey(digiUsername))
                        {
                            digital.addError('Username does not exist. Check your spelling.');
                            return null;
                        }
                        else 
                            {
                            */   
                                resetPass = digiComController.resetPassword(c, digiUsername, asia1Id, digiNewPass, serviceFlag, digital.Asia1__r.Display_Name__c);
                                
                                    if(resetPass==FALSE)
                                        {
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, digiComController.getErrors())); 
                                            return null;
                                           
                                        }
                            //}D-0917 [JB Domingo 11/25/2014] 
                    }
                else if (subcatName == 'Deactivate User Id')
                {

                    //START UD-0877 04-27-2015 MarvinG
                    string errorResponse;
                    //START: UD-3952 04-18-2016 Added by Kristine Balaoing - commented out hardcoding of error response
                    //errorResponse = 'Failed, the username is already disabled.'; //START-END: D-2893 05/20/2015 Jean Cari?o 
                    if (deactivateID (asia1Obj.User_ID_LDAP_ID__c, asia1Sub)){
                        asia1Obj.Status__c = 'Disabled';
                        update asia1Obj;
                    }
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorResponse )); 
                        return null;
                    }
                    //END: UD-3952 04-18-2016 Added by Kristine Balaoing
                    //END UD-0877 04-27-2015 MarvinG
                        
                }
                else if (subcatName =='User Id Not Created/Activated')
                {
                    System.debug('>>>>>>called 345');
                    // Start UD-3391 15Mar16 JohnD - revised logic due to CR
                    // Start UD-3391 02Apr16 JohnD - add/change value
                    if (c.Subscription_Name__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_NO_SUB)); 
                        return null;
                    }
                    
                    if (c.Subscription_Name__r.Status_Formula__c != ACTIVE) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_INV_SUB)); 
                        return null;
                    }
                    // End UD-3391 02Apr16 JohnD - add/change value
                    
                    list<Digital_Complaint_Items__c> digitalComplaintItems = new list<Digital_Complaint_Items__c>();
                    string errorMessage;
                    string ldapId;
                    
                    if (isExistingS == null) {
                        isExistingS = false;
                    }
                    
                    for (Asia1Wrapper asia1SingleWrap : asia1Subscriptions) {
                        System.debug('>>>>>>called ');
                        
                        digitalComplaintItems.add(digiComController.createDigitalComplaintItems(c, asia1SingleWrap.userId ,asia1SingleWrap.Password, serviceFlag, asia1SingleWrap.displayName, 'Success'));
                        //UD-3952 4-18-2016 Added by Kristine Balaoing - added variables
                        String asia1FirstName;
                        String asia1LastName;
                        //UD-3952 4-18-2016 Added by Kristine Balaoing
                        
                        ldapId = asia1SingleWrap.userId;
                        
                        if (!isExistingS) {
                            System.debug('>>>>>>called 2');
                            
                            String asia1phone = '1234567890'; 
                            Map<String, String> accountMap = new Map<String, String>();                                           
                            accountMap.put(GlobalVariableClass.USERNAME, asia1SingleWrap.userId);
                            accountMap.put(GlobalVariableClass.DISPLAY_NAME, asia1SingleWrap.displayName);
                            accountMap.put(GlobalVariableClass.PASSWORD, asia1SingleWrap.Password);
                            accountMap.put(GlobalVariableClass.EMAIL, asia1SingleWrap.Email);                           
                            
                            if (c.Subscription_Name__r.Recipient_Contact__c != null) {
                                
                                if (c.Subscription_Name__r.Recipient_Contact__r.HomePhone__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.HomePhone__c);                          
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Phone != null) {                  
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Phone);
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c);
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c);
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Office_Number__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Office_Number__c);
                                }
                                
                                //START: UD-3952 4-18-2016 Added by Kristine Balaoing - added first name and last name in the creation of asia1 account
                                if(c.Subscription_Name__r.Recipient_Contact__r.FirstName != null){
                                    asia1FirstName = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.FirstName);
                                }
                                if(c.Subscription_Name__r.Recipient_Contact__r.LastName != null){
                                    asia1LastName = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.LastName);
                                }
                                //END: UD-3952 4-18-2016 Added by Kristine Balaoing
                                
                            }
                            //asia1FirstName.replaceAll(' ',''); 
                            //asia1LastName.replaceAll(' ',''); 
                            asia1phone.replaceAll(' ',''); 
                            accountMap.put(GlobalVariableClass.FNAME, asia1FirstName);
                            accountMap.put(GlobalVariableClass.LNAME, asia1LastName); 
                            accountMap.put(GlobalVariableClass.PHONE,asia1phone);
                            //END: UD-3952 4-18-2016 Added by Kristine Balaoing
                            
                            map<string, object> response = AsiaOneServicesController.createAccount(accountMap);
                            System.debug('REESPONSE >>>> '+response);
                            //START: UD-3943 04/12/2016 Added by Kristine Balaoing - added one more key Errors in case Error is not used
                            if (response.containsKey('Error') && response.get('Error') != null) {
                                
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, (string)response.get('Error'))); 
                                return null;
                            }
                            //START: UD-3952 04/18/2016 Added by Kristine Balaoing - modified comments for variable
                            if (response.containsKey(ERRORS) && response.get(ERRORS) != null) {
                                
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, (string)response.get(ERRORS))); 
                                return null;
                            }
                            //END: UD-3952 04/18/2016 Added by Kristine Balaoing
                            //END: UD-3943 04/12/2016 Added by Kristine Balaoing

                        }
                    }
                    
                    EshopLDAPAPI.Request req = new EshopLDAPAPI.Request();
                    req.subscriberId = c.Account.AccountNumber;
                    req.asiaOneLdapId = ldapId;
                    req.subscriptionIds =  new list<string>{c.Subscription_Name__r.Name};   // Start/End 02Apr16 JohnD
                    
                    EshopLDAPAPI.response res = EshopLDAPAPI.processRequest(req);
                    
                    if (res.error_message != null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, res.error_message)); 
                        return null;
                    }
                    
                    // End UD-3391 15Mar16 JohnD - revised logic due to CR                    
                    insert digitalComplaintItems;   // Start/End UD-3493 13Apr16 JohnD
                    // Start UD-3391 15Mar16 JohnD - commented out due to CR
                    /* 
                    list<Digital_Complaint_Items__c> digitalComplaintItems = new list<Digital_Complaint_Items__c>();
                                        
                    for(Asia1Wrapper asia1SingleWrap : asia1Subscriptions){
                        //START UD-0877 04-27-2015 MarvinG
                        Digital_Complaint_Items__c eachDigitalComplaintItem = new Digital_Complaint_Items__c();
                        eachDigitalComplaintItem = digiComController.createDigitalComplaintItems(c, asia1SingleWrap.userId ,asia1SingleWrap.Password, serviceFlag, asia1SingleWrap.displayName, 'Success');
                        eachDigitalComplaintItem.First_Name__c = '';
                        eachDigitalComplaintItem.Last_Name__c = '';
                        eachDigitalComplaintItem.Suppress_Email__c = suppress;
                        eachDigitalComplaintItem.Deactivate_user__c = false;
                        
                        digitalComplaintItems.add(eachDigitalComplaintItem );
                        //END UD-0877 04-27-2015 MarvinG
                        
                        String asia1phone;
                        // D-0916 [JB Domingo 11/26/2014]
                        Map<String, String> accountMap = new Map<String, String>();                                           
                        accountMap.put(GlobalVariableClass.USERNAME,asia1SingleWrap.userId);
                        accountMap.put(GlobalVariableClass.DISPLAY_NAME,asia1SingleWrap.displayName);
                        accountMap.put(GlobalVariableClass.PASSWORD,asia1SingleWrap.Password);
                        accountMap.put(GlobalVariableClass.EMAIL,asia1SingleWrap.Email);
                        //START D-1412 Modified by FrancisBenzon : catch error if sub package has no service flags
                        try {
                            accountMap.put(GlobalVariableClass.SVC,asia1SingleWrap.asia1Subscriptions[0].serviceFlagName);
                        }
                        catch(exception e) {
                            system.debug(e.getMessage());
                        }                                        
                        if(c.Subscription_Name__c != null) {
                            if(c.Subscription_Name__r.Recipient_Contact__c != null) {
                                if(c.Subscription_Name__r.Recipient_Contact__r.HomePhone__c != null){
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.HomePhone__c);                          
                                }
                                else if(c.Subscription_Name__r.Recipient_Contact__r.Phone != null){                  
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Phone);
                                }
                                else if(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c != null){
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c);
                                }
                                else if(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c != null){
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c);
                                // Start UD-3452 19Jan16 JohnD - added phone numbers
                                } else if (c.Subscription_Name__r.Recipient_Contact__r.Office_Number__c != null) {
                                    asia1phone = string.valueOf(c.Subscription_Name__r.Recipient_Contact__r.Office_Number__c);
                                } else {
                                    asia1phone = '1234567890';
                                }
                                // End UD-3452 19Jan16 JohnD - added phone numbers
                            }
                        }  
                        //END D-1412 Modified by FrancisBenzon : catch error if sub package has no service flags                        
                        // Start UD-2532 01Sep15 JohnD - added null trapping
                        if (asia1phone != null) {
                            asia1phone.replaceAll(' ',''); 
                            accountMap.put(GlobalVariableClass.PHONE,asia1phone);
                        }          
                        // End UD-2532 01Sep15 JohnD - added null trapping
                        //START: UD-3819 1/26/16 Added by Manolo Valena
                        if(isExistingS == null) {
                            isExistingS = false;
                        }
                        registerAsia1Accounts(c.Id, accountMap, isExistingS);
                        //END: UD-3819 1/26/16 Added by Manolo Valena
                    }
                    insert digitalComplaintItems;
                    //START: UD-3819 1/26/16 Added by Manolo Valena
                    if(isExistingS == null) {
                        isExistingS = false;
                    }
                    if(!isExistingS) {    
                        createAsia1Subscription(asia1Subscriptions);    
                    }
                    else {
                        Set<Id> asiaOneIds = new Set<Id>();
                        List<Asia1__c> asiaOneList = new List<Asia1__c>();
                        List<Asia1_Subscription__c> asiaOneSubList = new List<Asia1_Subscription__c>();
                        for(Asia1Wrapper awRec : asia1Subscriptions) {
                            asiaOneIds.add(awRec.asia1Id);
                        }
                        if(asiaOneIds.size() > 0) {
                            for(Asia1__c aRec : [SELECT Id, Status__c, Enabled__c, 
                                                       (SELECT Id, Status__c FROM Asia1_Subscriptions__r 
                                                        WHERE Subscription__c =: c.Subscription_Name__c 
                                                        AND Status__c =: GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED
                                                        AND (Subscription__r.Zuora__SubscriptionEndDate__c >: date.today() OR 
                                                             Subscription__r.Zuora__SubscriptionEndDate__c = NULL)) 
                                                FROM Asia1__c 
                                                WHERE Id IN : asiaOneIds]) {
                                aRec.Status__c = GlobalVariableClass.ASIAONE_CREATED;
                                aRec.Enabled__c = true;
                                asiaOneList.add(aRec);
                                
                                if(aRec.Asia1_Subscriptions__r.size() > 0) {
                                    for(Asia1_Subscription__c asRec : aRec.Asia1_Subscriptions__r) {
                                        asRec.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
                                        asiaOneSubList.add(asRec);
                                    }
                                }
                            }
                            if(asiaOneList.size() > 0) {
                                update asiaOneList;
                            }
                            if(asiaOneSubList.size() > 0) {
                                update asiaOneSubList;
                            }
                        }
                    }
                    //END: UD-3819 1/26/16 Added by Manolo Valena
                    */
                    // End UD-3391 15Mar16 JohnD - commented out due to CR
                }
                PageReference pageRef = new pageReference('/apex/DigitalComplaintItemsPage?caseId=' + c.Id);
                 pageRef.setRedirect(true);
                 return pageRef;
        }
        
        public PageReference cancel() {
                PageReference pageRef = new pageReference('/' + c.Id);
                 pageRef.setRedirect(true);
                 return pageRef;
        }
        
        
        //START D-2942 25-06-2015 Marvin Gatchalian removed @future, and return boolean
        //@future(callout = true)
        //START: UD-3819 1/26/16 Added by Manolo Valena
        public static boolean registerAsia1Accounts(Id caseId,Map<String,String> accountMap, Boolean selectedExisting) {
            Case cObj = [SELECT Id, Account.Id, Account.Name,CaseNumber,Subscription_Name__c,Sub_Category__c, SuppliedEmail,
                 ContactId, Contact.FirstName, Contact.LastName, Contact.Phone, Subscription_Name__r.Recipient_Contact__r.HomePhone__c,
                 Subscription_Name__r.Recipient_Contact__r.Phone, Subscription_Name__r.Recipient_Contact__r.Mobile_Number__c,
                 Subscription_Name__r.Recipient_Contact__r.Mobile_Number_2__c FROM Case WHERE Id =: caseID];
            DigitalComplaintController digiComController = new DigitalComplaintController();    
            //START: UD-3819 1/26/16 Added by Manolo Valena
            if(selectedExisting) {
                return digiComController.enableAccount(cObj, accountMap);
            }
            else {
                return digiComController.createAccount(cObj, accountMap);
            }
            //END: UD-3819 1/26/16 Added by Manolo Valena
        }
        //END: UD-3819 1/26/16 Added by Manolo Valena
        //END D-2942 25-06-2015 Marvin Gatchalian removed @future, and return boolean

                
                        
        //START: D-1262 1/14/2015 Added by Kristine Campang - added method for retrieval of user details
        public void retrieveUserDetails(){
            //START UD-3324 27Nov15 FrancisBenzon : display digital fields
            if(deacAsia1UserId != null && deacAsia1UserId != '--None--')
            {
                digital.Asia1__c = id.valueOf(deacAsia1UserId);
            }
            if(deacAsia1UserId == '--None--')
            {
                digital.Asia1__c = null;
            }           
            //END UD-3324 27Nov15 FrancisBenzon : display digital fields
        
            //START: UD-1064 5/6/2015 Added by JTeves - address SOQL Error on clearing the Lookup field
            //START: UD-1065 5/7/2015 Added by JTeves - validation for lookup filter
            if(digital.Asia1__c != null) {
                Asia1__c asia1Rec = [SELECT Id, User_ID_LDAP_ID__c, Contact__r.AccountId FROM Asia1__c WHERE Id = :digital.Asia1__c];
                if(asia1Rec.Contact__r.AccountId != digital.Account_Lookup_Field__c) {
                    digital.Asia1__c.addError(LOOKUP_FILTER_ERROR);
                    digital.First_Name__c = '';
                    digital.Last_Name__c = '';
                    digital.Email__c = '';
                }
                else {
                    Map<String, Object> userDetailsMap =  AsiaOneServicesController.viewUserDetails(asia1Rec.User_ID_LDAP_ID__c);
                    
                    digital.First_Name__c = String.valueof(userDetailsMap.get('First Name'));
                    digital.Last_Name__c = String.valueof(userDetailsMap.get('Last Name'));
                    digital.Email__c = String.valueof(userDetailsMap.get('E-Mail'));
                }
            }
            else {
                digital.First_Name__c = '';
                digital.Last_Name__c = '';
                digital.Email__c = '';
            }
            //END: UD-1065 5/7/2015 Added by JTeves - validation for lookup filter
            //END: UD-1064 5/6/2015 Added by JTeves - address SOQL Error on clearing the Lookup field
            
        }
        //END: D-1262 1/14/2015 Added by Kristine Campang
        
        //START UD-0877 04-27-2015 MarvinG
        public boolean deactivateID (string ldapid, List<Asia1_Subscription__c> asia1Sub) {
            //for SelectList
            string responseStatus;
            string errorResponse;
            boolean deacUserId;
          
            list<Digital_Complaint_Items__c> digitalComplaintItems = new list<Digital_Complaint_Items__c>();
            system.debug('mapAsia1_AsiaSub'+mapAsia1_AsiaSub);
            system.debug('mapAsia1_AsiaSub.get'+mapAsia1_AsiaSub.get(digital.Asia1__r.Id));
                    
            asia1SubAssociatedWithSelectedAsia1 = mapAsia1_AsiaSub.get(digital.Asia1__r.Id);

            //call Digital Complaint Controller
                    
            //START UD-0877 04-27-2015 MarvinG
            //deacUserId = digiComController.disableServiceFlag(c, digiUsername, digiNewPass, displayName, accountMap.get(GlobalVariableClass.SVC));
            Digital_Complaint_Items__c eachDigitalComplaintItem = new Digital_Complaint_Items__c();        
            Map<String, Object> responseMap = new Map<String, Object>();             
            responseMap =  AsiaOneServicesController.disableUserAccount(ldapid);
            
            responseStatus = (String)responseMap.get('Disable-Account');
            //System.assertEquals(null, (String)responseMap.get('Errors'));
            //System.assertEquals(1, 2);
            //UD-3952 04-18-2016 Added by Kristine Balaoing - changed result when ldap already disabled
            if(responseStatus == 'Success') {
                deacUserId = true;
                eachDigitalComplaintItem.Status__c = 'Success';
            }else if(responseMap.containsKey(ERRORS) && ((String)responseMap.get(ERRORS)).contains(ERR_RESP)){
                
                deacUserId = true;
                eachDigitalComplaintItem.Status__c = 'Success';
            }else {
                deacUserId = false;
                eachDigitalComplaintItem.Status__c = 'Failed';
                errorResponse = (String)responseMap.get(ERRORS); //START-END: D-2893 05/20/2015 Jean Cari?o
            }
            //UD-3952 04-18-2016 Added by Kristine Balaoing
            eachDigitalComplaintItem.RecordTypeId = (Id)ConstantsSLB.getKeyId('Deactivate_User');
            eachDigitalComplaintItem.Case_No__c = c.id;
            eachDigitalComplaintItem.SPH_Online_User_Id__c = ldapid;
            eachDigitalComplaintItem.First_Name__c = digital.First_Name__c;
            eachDigitalComplaintItem.Last_Name__c = digital.Last_Name__c;
            eachDigitalComplaintItem.Email__c = digital.Email__c;
            eachDigitalComplaintItem.Suppress_Email__c = digital.Suppress_Email__c;
            eachDigitalComplaintItem.Deactivate_user__c = digital.Deactivate_user__c;
            //START UD-1065 7-May-2015 Added by JTeves - populate account and Asia1 fields
            eachDigitalComplaintItem.Account_Lookup_Field__c = digital.Account_Lookup_Field__c;
            eachDigitalComplaintItem.Asia1__c = digital.Asia1__c;
            //START UD-1065 7-May-2015 Added by JTeves - populate account and Asia1 fields
            digitalComplaintItems.add(eachDigitalComplaintItem );
            

            ///// Duplicate Logic 
            //if(asia1SubAssociatedWithSelectedAsia1 != null){ //D-0917 [JB Domingo 11/25/2014] 
                
            //    asia1SubAssociatedWithSelectedAsia1.Status__c = 'disabled';
            //    update asia1SubAssociatedWithSelectedAsia1;
                
            //}
            ///// Duplicate Logic 

            if(deacUserId == true) {
                
                if(asia1Sub.size() > 0){  //D-0917 [JB Domingo 11/25/2014] 
                    
                      //START D-2402 27-Feb-2015 Added by Raviteja - Nitin K : D-2402 : 27-2-15
                    for(Asia1_Subscription__c x : asia1Sub){
                        x.Status__c = 'Disabled';
                    }
                    //asia1Sub.Status__c = 'Disabled';
                     //End D-2402 27-Feb-2015 Added by Raviteja - End
                    update asia1Sub;
                }
                 
                ///// Duplicate Logic
                //asia1SubAssociatedWithSelectedAsia1 = mapAsia1_AsiaSub.get(mapUsername_Asia1.get(digiUsername).Id); //D-0917 [JB Domingo 11/25/2014] 
                //asia1SubAssociatedWithSelectedAsia1 = mapAsia1_AsiaSub.get(digital.Asia1__r.Id);                              
                //if(asia1SubAssociatedWithSelectedAsia1 != null){
                //    asia1SubAssociatedWithSelectedAsia1.Status__c = 'disabled';
                //    update asia1SubAssociatedWithSelectedAsia1;
                //}
                ///// Duplicate Logicaccount
                insert digitalComplaintItems; 
            }
             
           return deacUserId;
            
        }
        //END UD-0877 04-27-2015 MarvinG
        
        /*
        *Description : this method queries all Asia1s that has packages with packages access flags and 
        *puts all values into a listOption for user to choose from.
        *Return : null
        *Date: 8/12/15
        */
        //START UD-1065 AddedBy FrancisBenzon
        public void getRelatedAsia1sWithAccessFlag(Id mainPackageId, Id recipientId)
        {   
            //START UD-2368 K. Tan 8/20/2015 - To include filter for subscriptions
            Map<Id, String> mapAsia1toLdap = new Map<Id, String>();
            //END UD-2368 K. Tan 8/20/2015 - To include filter for subscriptions
            List<Package_Access_Flag__c> packageAccessFlags = new List<Package_Access_Flag__c>();
            Set<Id> packageAccessFlagIds = new Set<Id>();
            List<Asia1_Subscription__c> asia1Subs = new List<Asia1_Subscription__c>();
            asia1WithAccessFlags = new list<SelectOption>();
            asia1WithAccessFlags.add(new SelectOption('--None--', '--None--'));
            
            packageAccessFlags = [Select Id, Package__c, Package_Service_Access_Flag__c From Package_Access_Flag__c Where Package__c = :mainPackageId];
            for(Package_Access_Flag__c paf : packageAccessFlags)
            {
                packageAccessFlagIds.add(paf.Package_Service_Access_Flag__c);
            }
            //START UD-2368 K. Tan 8/19/2015 - To include filter for subscriptions
            // Start UD-2580 02Sep15 JohnD - removed "AND Asia1__r.Contact__c = :recipientId" and added Asia1__r.User_ID_LDAP_ID__c
            asia1Subs = [Select Id, Asia1__c, Asia1__r.Name, Asia1__r.Contact__c, Status__c, Asia1__r.User_ID_LDAP_ID__c From Asia1_Subscription__c
                            Where Service_Access_Flag__c IN :packageAccessFlagIds
                            AND Subscription__r.Name =: subsname]; 
            // End UD-2580 02Sep15 JohnD - removed "AND Asia1__r.Contact__c = :recipientId" and added Asia1__r.User_ID_LDAP_ID__c
            //END UD-2368 K. Tan 8/19/2015 - To include filter for subscriptions
            
            set<id> asia1IdSet = new set<id>(); // Start/End UD-2580 02Sep15 JohnD
 

            for(Asia1_Subscription__c aSubs : asia1Subs)
            {   
                // Start UD-2580 02Sep15 JohnD - replaced aSubs.Asia1__r.Name with aSubs.Asia1__r.User_ID_LDAP_ID__c
                if (!asia1IdSet.contains(aSubs.Asia1__c)) {    
                    asia1WithAccessFlags.add(new SelectOption(aSubs.Asia1__c, aSubs.Asia1__r.User_ID_LDAP_ID__c));
                // Start UD-2641 08Sep15 K.Tan - add set Asia1 to set            
                    asia1IdSet.add(aSubs.Asia1__c);
                // END UD-2641 08Sep15 K.Tan - add set Asia1 to set        
                }   
                // End UD-2580 02Sep15 JohnD - replaced aSubs.Asia1__r.Name with aSubs.Asia1__r.User_ID_LDAP_ID__c
            }
            
        }
        //END UD-1065 AddedBy FrancisBenzon
        
        // Start UD-2532 31Aug15 JohnD - added new method to retrieve total number of enabled asia1
        private integer getTotalAsia1EnabledAccounts(id subscriptionId) {
            
            integer totalAsia1 = 0;
            
            for (AggregateResult ar : [select count_distinct(Asia1__c)totalAsia1 from Asia1_Subscription__c where subscription__c = :subscriptionId 
                    and status__c = :GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED]) {
                    
                totalAsia1 = (integer)ar.get('totalAsia1');
            }
            
            return totalAsia1;
        } 
        // End UD-2532 31Aug15 JohnD - added new method to retrieve total number of enabled asia1
    }