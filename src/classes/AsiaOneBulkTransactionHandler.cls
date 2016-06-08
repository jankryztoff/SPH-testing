/**
* Class Name: <AsiaOneBulkTransactionHandler> 
* @authors: <Nitin Khanna>
* Date: <10/12/2014>
* Requirement/Project Name: <SPH>
* @description <vlass to facilitate creation of bulk asia one id s for subscription scenarios and bulk disabling in case of expiry of a subscription>
*/
 
public class AsiaOneBulkTransactionHandler{
    public static String API_DISABLE_SERVICE = 'apiDisableService';
    public static String API_ENABLE_SERVICE = 'apiEnableService';
    public static String API_CHECK_USER_AVAILABILITY = 'apiCheckUserAvailability';
    public static String API_CHECK_DISPLAYNAME_AVAILABILITY = 'apiCheckDisplayNameAvailability';
    public static String API_SIGN_UP = 'apiSignUp';
    public static String DEACTIVATEx = 'Deactivate';
    public static String ACTIVATEx = 'Activate';
    public static String SIGNUP = 'Sign-Up';
    public static String USER_AVAILABILITY = 'User-Availability';
    public static String DISPLAY_NAME_AVAILABILITY = 'DisplayName-Availability';
    public static String ERRORSx = 'Errors';
    public static String SUCCESS = 'Success';
    public static String FAILURE = 'Failed';
    public static String SERVICE_ALREADY_DISABLED = 'You have not activated this service.';
    public static STring SERVICE_ALREADY_ENABLED = 'You have already activated the service.';
    public static String DISABLED = 'Disabled';

    public static AsiaOneServiceResponsetVO asiaOneServiceCall(Map<String, String> sReqVO, String asiaOneAPI){
        AsiaOneFacade a1F = new AsiaOneFacade();
        AsiaOneServiceRequestVO serviceRequestVO = new AsiaOneServiceRequestVO();
        serviceRequestVO.setReqValueObject(sReqVO);
        serviceRequestVO.setasia1APIFunction(asiaOneAPI);
        System.debug('################ SERVICE CALLED : ' + asiaOneAPI + '#########################');
        return a1F.delegateAsiaOneCall(serviceRequestVO);
    }
    
    @future(callout=true)
    public static void disableServices( String username, String svc, Id subscription){
        boolean isServiceDisable = false;
        Map<String, String> sReqVO = new Map<String, String>();
        sReqVO.put('username',username);
        sReqVO.put('ip',BulkAsiaOneConfigParams__c.getInstance('AsiaOne').ip__c);
        sReqVO.put('svc', svc);
        AsiaOneServiceResponsetVO resp = asiaOneServiceCall(sReqVO, API_DISABLE_SERVICE);
        String responseString = (String)resp.getReqValueObject().get(DEACTIVATEx);
        
        if( responseString != SUCCESS ){
            String errors = (String)resp.getReqValueObject().get(ERRORSx);
           
                if ( errors == SERVICE_ALREADY_DISABLED ){
                    isServiceDisable = true;
                }
          
        }else{
            isServiceDisable = true;
        }

        System.debug('################ SERVICE call response : ' + isServiceDisable + '#########################');
        
        List<Asia1_Subscription__c> aScList = [ select Asia1__r.User_ID_LDAP_ID__c, Service_Access_Flag__r.name, status__c from Asia1_Subscription__c where Subscription__r.id = :subscription and Asia1__r.User_ID_LDAP_ID__c = :username and Service_Access_Flag__r.name = :svc ];
        for(Asia1_Subscription__c tmp : aScList){
            if(isServiceDisable){
                tmp.status__c = DISABLED;
                update aScList;
            }
        }
        
    }
    
    public static boolean isUserNameAvailable(String username){
        boolean isUsernameAvailable = false;
        Map<String, String> sReqVO = new Map<String, String>();
        sReqVO.put('username',username);
        sReqVO.put('ip',BulkAsiaOneConfigParams__c.getValues('ip').ip__c);
        AsiaOneServiceResponsetVO resp = asiaOneServiceCall(sReqVO, API_CHECK_USER_AVAILABILITY);
        String responseString = (String)resp.getReqValueObject().get(USER_AVAILABILITY);
        
        if( responseString != SUCCESS ){
            isUsernameAvailable = true;
        }
        
        System.debug('################ SERVICE call response : ' + isUsernameAvailable + '#########################');
        return isUsernameAvailable;
    }
    
    public static boolean isDisplayNameAvailable(String username){
        boolean isDisplayNameAvailable = false;
        Map<String, String> sReqVO = new Map<String, String>();
        sReqVO.put('username',username);
        sReqVO.put('ip',BulkAsiaOneConfigParams__c.getValues('ip').ip__c);
        AsiaOneServiceResponsetVO resp = asiaOneServiceCall(sReqVO, API_CHECK_DISPLAYNAME_AVAILABILITY);
        String responseString = (String)resp.getReqValueObject().get(DISPLAY_NAME_AVAILABILITY);
        
        if( responseString != SUCCESS ){
            isDisplayNameAvailable = true;
        }
        
        System.debug('################ SERVICE call response : ' + isDisplayNameAvailable + '#########################');
        return isDisplayNameAvailable;
    }
    
    public static boolean enableServices( String username, String svc){
        boolean isServiceEnabled = false;
        Map<String, String> sReqVO = new Map<String, String>();
        sReqVO.put('username',username);
        sReqVO.put('ip',BulkAsiaOneConfigParams__c.getValues('ip').ip__c);
        sReqVO.put('svc', svc);
        AsiaOneServiceResponsetVO resp = asiaOneServiceCall(sReqVO, API_ENABLE_SERVICE);
        String responseString = (String)resp.getReqValueObject().get(ACTIVATEx);
        
        if( responseString != SUCCESS ){
            List<String> errors = (List<String>)resp.getReqValueObject().get(ERRORSx);
            for ( String tempMsg : errors ){
                if ( tempMsg == SERVICE_ALREADY_ENABLED ){
                    isServiceEnabled = true;
                }
            }
        }else{
            isServiceEnabled = true;
        }
        
        System.debug('################ SERVICE call response : ' + isServiceEnabled + '#########################');
        return isServiceEnabled;
    }
    
    @future (callout=true)
    public static void apiSignUp(String svc, String username, String displayName, Id subId, Decimal concurrentUser, id orderLI, id servAccFlg, id asia1Tmp ){
        boolean isSuccess = false;
        
        Zuora__Subscription__c sub = [ select Recipient_Contact__r.FirstName, Recipient_Contact__r.LastName, Recipient_Contact__r.Mobile_Number__c, Recipient_Contact__r.HomePhone__c, Recipient_Contact__r.Email__c, Recipient_Contact__r.Office_Number__c from Zuora__Subscription__c where id = :subId ];
        Map<String, String> sReqVO = new Map<String, String>();
        sReqVO.put(GlobalVariableClass.USERNAME,username);
        sReqVO.put(GlobalVariableClass.PASSWORD,BulkAsiaOneConfigParams__c.getInstance('AsiaOne').Password__c );
        sReqVO.put(GlobalVariableClass.IP,BulkAsiaOneConfigParams__c.getInstance('AsiaOne').ip__c);
        sReqVO.put(GlobalVariableClass.PASS_CHALLENGE,BulkAsiaOneConfigParams__c.getInstance('AsiaOne').passwordChallenge__c.replace(' ','+'));
        sReqVO.put(GlobalVariableClass.PASS_RESPONSE,BulkAsiaOneConfigParams__c.getInstance('AsiaOne').passwordResponse__c.replace(' ','+'));
        sReqVO.put(GlobalVariableClass.DISPLAY_NAME,displayName);
        sReqVO.put(GlobalVariableClass.FNAME,sub.Recipient_Contact__r.FirstName);
        sReqVO.put(GlobalVariableClass.LNAME,sub.Recipient_Contact__r.LastName);
        sReqVO.put(GlobalVariableClass.EMAIL,sub.Recipient_Contact__r.Email__c);
        sReqVO.put(GlobalVariableClass.ENABLE,BulkAsiaOneConfigParams__c.getInstance('AsiaOne').Enable__c);
        sReqVO.put(GlobalVariableClass.SVC, svc);
        
        if(sub.Recipient_Contact__r.Mobile_Number__c != null){
            sReqVO.put(GlobalVariableClass.PHONE,sub.Recipient_Contact__r.Mobile_Number__c);
        }else if(sub.Recipient_Contact__r.HomePhone__c != null){
            sReqVO.put(GlobalVariableClass.PHONE,sub.Recipient_Contact__r.HomePhone__c);
        }else if(sub.Recipient_Contact__r.Office_Number__c != null){
            sReqVO.put(GlobalVariableClass.PHONE,sub.Recipient_Contact__r.Office_Number__c);
        }else{
            sReqVO.put(GlobalVariableClass.PHONE,'1234567890');
        }


        AsiaOneServiceResponsetVO resp = asiaOneServiceCall(sReqVO, API_SIGN_UP);
        String responseString = (String)resp.getReqValueObject().get(SIGNUP);
        
        Asia1_Subscription__c asia1Subscription = new Asia1_Subscription__c();           
        asia1Subscription.Concurrent__c = concurrentUser;
        asia1Subscription.Order_Line_Item__c = orderLI;
        asia1Subscription.Service_Access_Flag__c = servAccFlg;
        asia1Subscription.Asia1__c = asia1Tmp;
        asia1Subscription.Subscription__c = subId;
        
        if( responseString == SUCCESS ){
//          isSuccess = true;
            asia1Subscription.Status__c = 'Enabled';
        }else{
            asia1Subscription.Status__c = 'Service Activation Error';
            asia1Subscription.Reason_for_Failure__c = (string)resp.getReqValueObject().get(ERRORSx);
        }
        
        insert asia1Subscription;
        System.debug('################ SERVICE call response : ' + isSuccess + '#########################');
    }
    
    
    public static void resolveIdsToBeDisabled( Set<id> subscriptionSet ){
        List<Asia1_Subscription__c> aScList = [ select Asia1__r.User_ID_LDAP_ID__c, Service_Access_Flag__r.name, status__c, subscription__r.id from Asia1_Subscription__c where Subscription__r.id in :subscriptionSet ];
        for( Asia1_Subscription__c aScTemp : aScList ){
            AsiaOneBulkTransactionHandler.disableServices(aScTemp.Asia1__r.User_ID_LDAP_ID__c, aScTemp.Service_Access_Flag__r.name, aScTemp.subscription__r.id);    
        }
    }
}