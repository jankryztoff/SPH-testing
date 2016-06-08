// max of 50 asia1 ids

public class BulkServiceFlagActivationLevel2Queueable implements Queueable, Database.allowsCallouts {

    
    list<ServiceFlagActivationParamWrapper> paramList = new list<ServiceFlagActivationParamWrapper>();
    list<Asia1_Subscription__c> asia1SubscriptionList = new list<Asia1_Subscription__c>();
    list<exception> exceptionList = new list<exception>();
    
    public BulkServiceFlagActivationLevel2Queueable(list<ServiceFlagActivationParamWrapper> serviceFlagParamWrapperListParam) {
            
        this.paramList = serviceFlagParamWrapperListParam;
    }


    public void execute(QueueableContext context) {
        
        for (ServiceFlagActivationParamWrapper param : paramList) {
            enableServicesFuture(param.username, param.serviceFlag, param.asia1SubscriptionIdSet, param.subscriptionId);
        }
        
        if (!asia1SubscriptionList.isEmpty()) {
            try {
                update asia1SubscriptionList;
            } catch (exception e) {
                ExceptionLogger.log(new list<exception>{ e });
            }
        }
    }
    
 
    
    private void enableServicesFuture(string usernameParam, string serviceFlagParam, set<id> asia1subscriptionIdParamSetParam, id subscriptionIdParam) {


        final string SUCCESS = 'Success';
        final string FAILED = 'Failed';
        final string ERRORS = 'Errors';
        final string ERROR_CREATION = 'Error Creation';
        final string ENABLED = 'Enabled';
        final string ACTIVATE_R = 'Activate';
        final String ERROR_ALREADY_ACTIVATED = 'You have already activated the service.'; 
        string ldapId;
        string ldapIdprev;
        
        map<string, object> request = AsiaOneServicesController.enableService(usernameParam, serviceFlagParam);
        ldapId = null;
        ldapIdprev = null;

        for (Asia1_Subscription__c asia1Subscription1 : [select Asia1__r.User_ID_LDAP_ID__c from Asia1_Subscription__c 
                    where Id IN :asia1subscriptionIdParamSetParam ]) {
                    
          if (ldapId== null){
             ldapId = asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c;
             ldapIdprev =  asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c;
             map<string, object> request1 = AsiaOneServicesController.enableService(ldapId, serviceFlagParam);
          }             
          else if (ldapIdprev <> asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c){
             ldapId = asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c;
             ldapIdprev =  asia1Subscription1.Asia1__r.User_ID_LDAP_ID__c;
             map<string, object> request1 = AsiaOneServicesController.enableService(ldapId, serviceFlagParam);
          }   
        }

        if (request.get(ACTIVATE_R) == SUCCESS) {
            
            for (Asia1_Subscription__c asia1Subscription : [select Id, Status__c, Subscription__c from Asia1_Subscription__c 
                    where Id IN :asia1subscriptionIdParamSetParam and (Status__c = :GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED 
                    or Status__c = null)]) {
            
                asia1Subscription.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
                asia1Subscription.Subscription__c = subscriptionIdParam;
                asia1SubscriptionList.add(asia1Subscription);
            }
            
            
        } else if(request.get(ACTIVATE_R) == FAILED) {

            string aSubError = string.valueOf(request.get(ERRORS));
            
            if (aSubError != null) {
                aSubError = aSubError.replace('[', '').replace(']', '');
            }
            
            for (Asia1_Subscription__c asia1Subscription : [select Id, Status__c, Subscription__c from Asia1_Subscription__c 
                    where Id IN :asia1subscriptionIdParamSetParam and (Status__c = :GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED 
                    or Status__c = null)]) {
                
                if(aSubError == ERROR_ALREADY_ACTIVATED || (aSubError != null && aSubError.contains(ERROR_ALREADY_ACTIVATED))) {                       
                    asia1Subscription.Status__c = ENABLED;
                    asia1Subscription.Reason_for_Failure__c = null;
                } else {
                    asia1Subscription.Status__c = ERROR_CREATION;
                    asia1Subscription.Reason_for_Failure__c = aSubError;
                }
                
                asia1Subscription.Subscription__c = subscriptionIdParam;
                asia1SubscriptionList.add(asia1Subscription);
            }

        }
    }   
}