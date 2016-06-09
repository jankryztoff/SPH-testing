/**
 * Class Name: Asia1SubscriptionDeactivationBatchable
 * @author: 
 * Date: 8/21/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Disable Asia1 Subscription and Service Flag
 * History: UD-1963 08/24/2015 Added by J.Sarion - Disable Asia1 Subscription and Service Flag depending on Active/Cancelled/Expired Subscriptions
 */
 
public class Asia1SubscriptionDeactivationBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
    //START:UD-2394 8/20/15 Added by Manolo Valena - Updated Class to remove raw string values and updated query to get only Asia1 Subscriptions that are Enabled and the Subscription Cancelled.
    
    //START:D-3612 9/29/15 Added by Manolo Valena - Added constructors.
    Date sDate;
    Boolean isDate;
    Id singleRec;
    
    public Asia1SubscriptionDeactivationBatchable() {
        sDate = date.today();
        isDate = true;
    }
    
    public Asia1SubscriptionDeactivationBatchable(Date specDate) {
        sDate = specDate;
        isDate = true;
    }
    
    public Asia1SubscriptionDeactivationBatchable(Id rec) {
        singleRec = rec;
        isDate = false;
    }
    //END:D-3612 9/29/15 Added by Manolo Valena
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> asia1IdSet = new set<id>();
        set<id> asia1SubIdSet = new set<id>();  // Start/End UD-3427 13Jan16 JohnD
        set<id> asia1SubServiceFlag = new set<id>();  // Start/End PD-0030 VPernicia/JohnD 5/7/16
        
        //START:D-3612 9/29/15 Added by Manolo Valena - Added if and else if statements.
        if(isDate == true) {
            // Start UD-3427 13Jan16 JohnD - added id
            for (Asia1_Subscription__c tmp : [SELECT Asia1__c, Id, Service_Access_Flag__c // Start/End PD-0030 VPernicia/JohnD 5/7/16
                                              FROM Asia1_Subscription__c 
                                              WHERE Status__c =: GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED
                                              AND Subscription__r.Zuora__Status__c =: GlobalVariableClass.ZUORA_STATUS_CANCEL
                                              //START:D-3612 9/29/15 Added by Manolo Valena - Updated to variable date.
                                              AND Subscription__r.Zuora__SubscriptionEndDate__c <=: sDate]) {   // Start/End UD-3427 28Dec15 Johnd - changed Subscription__r.Zuora__SubscriptionEndDate__c =: sDate to Subscription__r.Zuora__SubscriptionEndDate__c <=: sDate
                                              //END:D-3612 9/29/15 Added by Manolo Valena
                asia1IdSet.add(tmp.Asia1__c);
                asia1SubIdSet.add(tmp.Id);
                asia1SubServiceFlag.add(tmp.Service_Access_Flag__c); // Start/End PD-0030 VPernicia/JohnD 5/7/16
            }
            // End UD-3427 13Jan16 JohnD - added id
        }
        else if(isDate == false) {
            for (Asia1_Subscription__c tmp : [SELECT Asia1__c, Service_Access_Flag__c // Start/End PD-0030 VPernicia/JohnD 5/7/16
                                              FROM Asia1_Subscription__c 
                                              WHERE Status__c =: GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED
                                              AND Subscription__r.Zuora__Status__c =: GlobalVariableClass.ZUORA_STATUS_CANCEL
                                              AND Asia1__c =: singleRec]) {
                asia1IdSet.add(tmp.Asia1__c);
                asia1SubServiceFlag.add(tmp.Service_Access_Flag__c); // Start/End PD-0030 VPernicia/JohnD 5/7/16
            }
        }
        //END:D-3612 9/29/15 Added by Manolo Valena
        
        // Start UD-3427 13Jan16 JohnD - added filter on the inner query
        // Start PD-0030 VPernicia/JohnD 5/7/16: Update the inner query
        return Database.getQueryLocator([SELECT User_ID_LDAP_ID__c, (SELECT Id, Status__c, Service_Access_Flag__c, Service_Access_Flag__r.Name, Subscription__r.Zuora__Status__c FROM Asia1_Subscriptions__r where Service_Access_Flag__c in :asia1SubServiceFlag)
                                         FROM Asia1__c 
                                         WHERE Id IN: asia1IdSet]);
        // End PD-0030 VPernicia/JohnD 5/7/16: Update the inner query
        // End UD-3427 13Jan16 JohnD - added filter on the inner query
    }
    
    public void execute(Database.BatchableContext BC, List<Asia1__c> scope) {
        
        Logger logger = new Logger(Asia1SubscriptionDeactivationBatchable.class.getName(), 'SP035', BC.getJobID());    // Start/End UD-3427 12Jan16 JohnD
        List<Asia1_Subscription__c> asia1SubscriptionList = new List<Asia1_Subscription__c>();
        
        for (Asia1__c tmp : scope) {
            Set<String> allServiceFlagsSet = new Set<String>();
            Set<String> enabledServiceFlagsSet = new Set<String>();
            String username = tmp.User_ID_LDAP_ID__c;
            //List<Asia1_Subscription__c> tmpAsia1SubscriptionList = new List<Asia1_Subscription__c>();
            
            if (username != NULL) {
                String serviceFlags = GlobalVariableClass.EMPTYSTR;
                Integer i = 0;
                
                for(Asia1_Subscription__c tmp2 : tmp.Asia1_Subscriptions__r){
                    if(tmp2.Service_Access_Flag__r.Name != null){
                        allServiceFlagsSet.add(tmp2.Service_Access_Flag__r.Name);
                        //if(tmp2.Status__c == GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED){  // Start UD-3427 08Jan16 JohnD - commented out
                            if(tmp2.Subscription__r.Zuora__Status__c == GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE)
                                enabledServiceFlagsSet.add(tmp2.Service_Access_Flag__r.Name);
                            if(tmp2.Subscription__r.Zuora__Status__c == GlobalVariableClass.ZUORA_STATUS_CANCEL){
                                tmp2.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
                                asia1SubscriptionList.add(tmp2);
                            }
                        //}     // Start UD-3427 08Jan16 JohnD - commented out
                    }
                }
                system.debug('>>>>>allServiceFlagsSet ' + allServiceFlagsSet);
                system.debug('>>>>>enabledServiceFlagsSet ' + enabledServiceFlagsSet);
                allServiceFlagsSet.removeAll(enabledServiceFlagsSet);
                system.debug('>>>>>allServiceFlagsSet ' + allServiceFlagsSet);
                system.debug('>>>>>enabledServiceFlagsSet ' + enabledServiceFlagsSet);
                for (String serviceFlag : allServiceFlagsSet) {
                    if (i > 0) {
                        serviceFlags += GlobalVariableClass.DELIMITER;    
                    }
    
                    //if (tmp2.Service_Access_Flag__c != NULL) {
                    serviceFlags += serviceFlag;
                    //tmp2.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
                    //tmpAsia1SubscriptionList.add(tmp2);
                    i++;
                    //}
                }
                
                if(!allServiceFlagsSet.isEmpty()){
                    Map<String, Object> callOutResponse = AsiaOneServicesController.disableService(username.replace(GlobalVariableClass.SPACE, GlobalVariableClass.PLUS), serviceFlags.toLowerCase());
                }
                
                //if ((String)callOutResponse.get(GlobalVariableClass.DEACTIVATE) == GlobalVariableClass.ZUORA_SUCCESS) {
                    //asia1SubscriptionList.addAll(tmpAsia1SubscriptionList);
                //}
            }
        }
        
        if (asia1SubscriptionList.size() > 0) {
            
            try {
				//START UD-3832 1/29/2016 Added by Manolo Valena - set to Database.Update to allow successful records to be processed
                Database.update(asia1SubscriptionList, false);
				//END UD-3832 1/29/2016 Added by Manolo Valena - set to Database.Update to allow successful records to be processed
            } catch (exception e) {
                logger.logBatchFailure(e, scope);   // Start/End UD-3427 13Jan16 JohnD
                // system.debug(GlobalVariableClass.ASIA_ERROR + GlobalVariableClass.SPACE + e); Start/End UD-3427 13Jan16 JohnD - commented out
            }
        }
        
        logger.save();  // Start/End UD-3427 13Jan16 JohnD 
    }
    
    public void finish(Database.BatchableContext BC) {
        //Update Job Status
        BatchJobHelper.updateJobStatus(BC.getJobId());
    }
    //END:UD-2394 8/20/15 Added by Manolo Valena
}