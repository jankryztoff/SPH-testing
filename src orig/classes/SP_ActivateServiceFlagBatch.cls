/**
     * Class Name: SP_ActivateServiceFlagBatch
     * @author: Karl Tan
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Batch Apex Class to Create Asia 1 Accounts
     * 
     */
     //START: D-3827 10/29/2015 Added by Kristine Balaoing - added batch recovery implementation
    global class SP_ActivateServiceFlagBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
        global Batch_Configuration_Settings__c batchSettings; //configuration data for SP_ActivateServiceFlagBatch
        Boolean isApexJobSuccessful = true;
        Boolean isAdhoc = false;
        Set<Id> failedRecIds = new Set<Id>();
        
       /* @description Called at the beginning of the apex job to collect the objects
        * to be passed to the execute method
        * @param bc- predefined parameter 
        * @return list of objects from Asia1 Object
        */     
        global SP_ActivateServiceFlagBatch(){
       
        }
        
        global SP_ActivateServiceFlagBatch(Set<Id> asia1IDs){
            this.isAdhoc = true;
            this.failedRecIds = asia1IDs;
        }
        
        global Database.QueryLocator start(Database.BatchableContext bc) {
            
            batchSettings = Batch_Configuration_Settings__c.getInstance('SP_ActivateServiceFlagBatch');
            String query = '';
            if(isAdhoc){
                query = 'SELECT Id, Contact__c, Display_Name__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Phone,  Email__c, Enabled__c, Password__c, Secret_Answer__c, Secret_Question__c, Status__c, User_ID_LDAP_ID__c FROM Asia1__c WHERE Status__c = \'Pending Creation\' AND Id IN :failedRecIds';
            }else{
                query = 'SELECT Id, Contact__c, Display_Name__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Phone,  Email__c, Enabled__c, Password__c, Secret_Answer__c, Secret_Question__c, Status__c, User_ID_LDAP_ID__c FROM Asia1__c WHERE Status__c = \'Pending Creation\'';
            }
 
            return Database.getQueryLocator(query);
        }
        
        /* @description Executes the business logic and creates Usage object
         * 
         * @param bc- predefined parameter 
         * @param allScopes - a list of sObjects from the initial database query
         * @return void
         */    
        
        global void execute(Database.BatchableContext BC, List<Asia1__c> asia1List) {
        
            Logger logger = new Logger(SP_ActivateServiceFlagBatch.class.getName(), 'SP001', BC.getJobID());
            
            try{
                List<Asia1_Subscription__c> asia1SubList = new List<Asia1_Subscription__c> ();
                //// START: Code Review Implementation 2/13/2015 JAlejandro
                if (!asia1List.isEmpty())
                {
                    asia1SubList = [SELECT id, Asia1__c, Service_Access_Flag__r.Name,  ASIAONE_Subscription_Legacy_Id__c, Order_Line_Item__c, Service_Access_Flag__c, Status__c, Subscription__c FROM Asia1_Subscription__c WHERE Asia1__c IN: asia1List];
                
                    Map<Id, List<Asia1_Subscription__c>> asia1Toasia1SubMap = new Map<Id, List<Asia1_Subscription__c>>();
                    
                    
                    for(Asia1_Subscription__c asia1Sub : asia1SubList) {
                        if(asia1Toasia1SubMap.containsKey(asia1Sub.Asia1__c)) {
                            asia1Toasia1SubMap.get(asia1Sub.Asia1__c).add(asia1Sub);
                        }
                        else {
                            asia1Toasia1SubMap.put(asia1Sub.Asia1__c, new List<Asia1_Subscription__c>{asia1Sub});
                        }
                    }
                    
                    Map<Id, String> asia1SubToFlagCodeMap  = new Map<Id, String>();
                    
                    
                    List<Asia1_Subscription__c> listAsia1 = new List<Asia1_Subscription__c>();
                    List<List<Asia1_Subscription__c>> listasia1List = new List<List<Asia1_Subscription__c>>();
                    listasia1List = asia1Toasia1SubMap.values();
                    //system.assertEquals(null, listasia1List);
                    for(List<Asia1_Subscription__c> asia1SubscList : listasia1List) {
                        listAsia1.addAll(asia1SubscList);                
                    
                    }
                    
                            
                    for(Asia1_Subscription__c asiaSub: listAsia1) { 
                        //System.assert(false);
                        asia1SubToFlagCodeMap.put(asiaSub.id, asiaSub.Service_Access_Flag__r.Name );   
                    }
                    
                    //System.assertEquals(null, asia1SubToFlagCodeMap);
                    Set<String> svcSet = new Set<String>();
                    
                    for(Asia1__c asia1 : asia1List) 
                    {
                        if(asia1Toasia1SubMap.containsKey(asia1.id)) { 
                            
                            for(Asia1_Subscription__c asiaSub : asia1Toasia1SubMap.get(asia1.id)){
                                if(asia1SubToFlagCodeMap.containsKey(asiaSub.id)){
                                    
                                    
                                    svcSet.add(asia1SubToFlagCodeMap.get(asiaSub.id));
                                }
                            }
                        }
                        //system.assertEquals(null, svcSet);
                        String Status;        
                        String Errors;
                        Boolean IsSuccess;
                        Map<String, Object> responseMap = new Map<String, Object>();


                        if(asia1.User_ID_LDAP_ID__c !=null){
                            //system.assertEquals(null, getSVC(svcSet));   
                            responseMap = AsiaOneServicesController.enableService(asia1.User_ID_LDAP_ID__c, getSVC(svcSet));
                            system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + responseMap );
                        }   
                        
                        if(responseMap.containsKey('Activate')) {
                            //System.assert(false);
                            status = (String)responseMap.get('Activate');
                            if(status == 'Success'){
                               // Another if Statement for Enabled Asia1 Credentials
                                isSuccess = TRUE;
                            }
                            else {
                                Errors = (String)responseMap.get('Errors');
                                isSuccess = False;
                                    
                            }
                        }           
                
                    }
                }// END: Code Review Implementation 2/13/2015 JAlejandro
            }catch (Exception e){
                logger.logBatchFailure(e, asia1List);
                logger.save();
                        
                isApexJobSuccessful = false;
            }

        } 
        //END: D-3827 10/27/2015 Added by Kristine Balaoing
        
        public String getSVC(Set<String> setSVC) {
            String SVCResult ='';
            Integer counter = 0;
            for (String SVC : setSVC) {
                SVCResult = SVCResult + SVC;
                if(counter < setSVC.size() -1) {
                    SVCResult = SVCResult +'|';
                counter++;
                }
            }
        return SVCResult;
        
        }
        //START: D-3827 10/27/2015 Added by Kristine Balaoing - added for batch recovery
        global void finish(Database.BatchableContext BC) {
               
               if(!isApexJobSuccessful){
                    BatchJobHelper.updateJobStatus(BC.getJobId(), false);
                }else{
                    BatchJobHelper.updateJobStatus(BC.getJobId(), true);
                }

        }
        //END: D-3827 10/27/2015 Added by Kristine Balaoing
    }