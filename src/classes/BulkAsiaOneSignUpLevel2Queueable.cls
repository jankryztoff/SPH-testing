// max of 50 asia1 ids

public class BulkAsiaOneSignUpLevel2Queueable implements Queueable, Database.allowsCallouts {

    set<id> asia1IdSet = new set<id>();
    list<Asia1_Subscription__c> asia1SubscriptionList4Update = new list<Asia1_Subscription__c>();
    list<exception> exceptionList = new list<exception>();
    
    public BulkAsiaOneSignUpLevel2Queueable(set<id> asia1IdSetParam) {
        this.asia1IdSet = asia1IdSetParam;
    }
    

    public void execute(QueueableContext context) {
        
        asia1IdSet.remove(null);
        
        for (id asia1Id : asia1IdSet) {
            apiSignUp(asia1Id);
        }
        
        if (!asia1SubscriptionList4Update.isEmpty()) {
            try {
                update asia1SubscriptionList4Update;
            } catch (exception e) {
                ExceptionLogger.log(new list<exception>{ e });
            }
        }
    }
    
 
    private void apiSignUp(id asia1IdParam) {
        
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
            sReqVO.put(GlobalVariableClass.ENABLE, 'no');
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
            
            if (responseString == 'Success') {
                status = 'Enabled';
            } else {
                status = 'Service Activation Error';
                error = (string)resp.getReqValueObject().get('Errors');
            }
            
            for (Asia1_Subscription__c asia1Subscription : asia1SubscriptionList) {
                
                asia1Subscription.Status__c = status;
                asia1Subscription.Reason_for_Failure__c = error;
                asia1SubscriptionList4Update.add(asia1Subscription);
                
            }
                        
        }
    }
    
    
    private AsiaOneServiceResponsetVO asiaOneServiceCall(Map<String, String> sReqVO, String asiaOneAPI){
        
        AsiaOneFacade a1F = new AsiaOneFacade();
        AsiaOneServiceRequestVO serviceRequestVO = new AsiaOneServiceRequestVO();
        serviceRequestVO.setReqValueObject(sReqVO);
        serviceRequestVO.setasia1APIFunction(asiaOneAPI);
        return a1F.delegateAsiaOneCall(serviceRequestVO);
    }
    
    
    private string refineData(string stringParam) {
        
        string refineStr;
        
        if (stringParam != null) {
            refineStr = stringParam.replace(' ', '+');
        }
        
        return refineStr;
    }      
}