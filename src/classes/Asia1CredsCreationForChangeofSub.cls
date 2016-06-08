/**
 * Class Name: Asia1CredsCreationForChangeofSub
 * @author: Kristine Campang
 * Date: 10/1/2014/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class that removes Delivery Charge Subscription
 *
 */
 
  /*
   * ------Revision------
   * Version 1.0: Pilot Release
   * By: <Karl Tan>
   * Description: Added method for Disablement of Asia 1 Subscription
  */

 
 public with sharing class Asia1CredsCreationForChangeofSub{
    
    public String Errors; 
    /*
     *@Description: calls Asia1 Webservice to create Asia1 Credentials
     *@Parameters: Boolean isDigital and Map<String, String> accountMap containing credentials
     *@Return: Boolean Status of the Response of Callout
    */
    public boolean createAccount(Boolean isDigital, Map<String, String> accountMap){
        
        boolean isSuccess = FALSE;
        String Status;
        String Asia1Id = accountMap.get('Id');
        String UserName = accountMap.get(GlobalVariableClass.USERNAME);
        String displayName = accountMap.get(GlobalVariableClass.DISPLAY_NAME);
        String Password = accountMap.get(GlobalVariableClass.PASSWORD);
        String Email= accountMap.get(GlobalVariableClass.EMAIL);
        String svc= accountMap.get(GlobalVariableClass.SVC);
        Map<String, Object> responseMap = new Map<String, Object>();
        
        if(isDigital && accountMap!=null){
            responseMap = AsiaOneServicesController.createAccount(accountMap);
        }
     
        if(responseMap.containsKey('Sign-Up')) {
            Status = (String)responseMap.get('Sign-Up');
            if(Status=='Success')
            {
                isSuccess = TRUE;
                System.debug('ASIA1 CREDENTIALS IS SUCCESSFULLY CREATED');
            }
        }
        if(responseMap.containsKey('Error')){
                isSuccess = FALSE;
                Errors = (String)responseMap.get('Error');
            }
        
        return isSuccess;  
    }
    
    /*
     *@Description: calls Asia1 Webservice to enable the service flags associated with the created Username 
     *@Parameters: String Username and String serviceflag
     *@Return: Boolean Status of the Response of Callout
    */
    public boolean enableServiceFlag(Boolean isDigital, String Username, String SVC){
        boolean isSuccess = TRUE;
        String Status;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        
        if(Username!=null &&SVC!=null && isDigital){
            responseMap = AsiaOneServicesController.enableService(UserName, svc);
        
        }
        
        if(responseMap.containsKey('Activate')) {
            status = (String)responseMap.get('Activate');
            if(status == 'Success')
            {
                isSuccess = TRUE;
            }
            else
            {
                isSuccess = FALSE;
                Errors = (String)responseMap.get('Errors');
            }
        }
        
        return isSuccess;
    }
    
    
     /*
     *@Description: calls Asia1 Webservice to disable the service flags associated with the created Username 
     *@Parameters: String Username and String serviceflag
     *@Return: Boolean Status of the Response of Callout
    */
    public boolean disableServiceFlag(Boolean isDigital, String Username, String SVC){
        boolean isSuccess = TRUE;
        String Status;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        
        if(Username!=null &&SVC!=null && isDigital){
            responseMap = AsiaOneServicesController.disableService(UserName, svc);
        
        }
        
        if(responseMap.containsKey('Deactivate')) {
            status = (String)responseMap.get('Deactivate');
            if(status == 'Success')
            {
                isSuccess = TRUE;
            }
            else
            {
                isSuccess = FALSE;
                Errors = (String)responseMap.get('Errors');
            }
        }
        
        return isSuccess;
    }

    //START UD-2193 07/31/2015 Added by J.Sarion - create Asia1 Account
    /*
     *@Description: calls Asia1 Webservice to create Asia1 Credentials
     *@Parameters: Id orderId
     *@Return: List of Asia1s
    */
    public List<Asia1__c> registerAsia1Accounts(id orderId) {
        list<Asia1__c> asia1List = new list<Asia1__c>();
        set<id> asia1IdSet = new set<id>();

        for (Asia1_Subscription__c tmp : [select Asia1__c from Asia1_Subscription__c 
                where Order_Line_Item__r.Order__c = :orderId and Asia1__r.Status__c = 'Pending Creation']) {
            
            asia1IdSet.add(tmp.Asia1__c);
        }

        if(asia1IdSet.size()>0){
            for (Asia1__c tmp : [select User_ID_LDAP_ID__c, Display_Name__c, First_Name__c, Last_Name__c, 
                        Status__c, Log__c, Phone__c, Password__c, Email__c, ASIAONE_Legacy_Id__c, 
                        (select Service_Access_Flag__r.Name from Asia1_Subscriptions__r) 
                        from Asia1__c where Id in :asia1IdSet]) {
                    
                string serviceFlags = '';
                integer i = 0;
                
                for (Asia1_Subscription__c tmp2 : tmp.Asia1_Subscriptions__r) {
                    
                    if (i > 0) {
                        serviceFlags += '|';    
                    }

                    if (tmp2.Service_Access_Flag__c != null) {
                        serviceFlags += tmp2.Service_Access_Flag__r.Name;
                        i++;
                    }
                }

                map<string, string> asia1newCreate = new map<string, string>();
                asia1newCreate.put(GlobalVariableClass.SVC, 'com');
                asia1newCreate.put(GlobalVariableClass.USERNAME, tmp.User_ID_LDAP_ID__c);
                asia1newCreate.put(GlobalVariableClass.PASSWORD, tmp.Password__c);
                asia1newCreate.put(GlobalVariableClass.PHONE, tmp.Phone__c);
                asia1newCreate.put(GlobalVariableClass.EMAIL, tmp.Email__c);
                asia1newCreate.put(GlobalVariableClass.ENABLE, 'no');
                asia1newCreate.put(GlobalVariableClass.IP, '');
                
                if (tmp.First_Name__c != null) {
                    asia1newCreate.put(GlobalVariableClass.FNAME, tmp.First_Name__c.replace(' ', '+'));
                }
                
                if (tmp.Last_Name__c != null) {
                    asia1newCreate.put(GlobalVariableClass.LNAME, tmp.Last_Name__c.replace(' ', '+'));
                }
                
                if (tmp.Display_Name__c != null) {
                    asia1newCreate.put(GlobalVariableClass.DISPLAY_NAME, tmp.Display_Name__c.replace(' ', '+'));
                }
                
                map<string, Object> asia1Return = AsiaOneServicesController.createAccount(asia1newCreate);
                
                if (asia1Return.get('Sign-Up') == 'Success') {
                    tmp.Status__c = 'Created';
                    tmp.ASIAONE_Legacy_Id__c = (string)asia1Return.get('System Id');
                    tmp.Enabled__c = true;
                } else {
                    tmp.Status__c = 'Error Creation';
                    
                    if (asia1Return.get('Error') != null) {
                        tmp.Log__c = string.valueOf(asia1Return.get('Error'));
                        
                    } else if (asia1Return.get('Errors') != null) {
                        tmp.Log__c = string.valueOf(asia1Return.get('Errors'));
                    }
                }
                asia1List.add(tmp);         
            }
        }
        return asia1List;
    }
    //END UD-2193 07/31/2015 Added by J.Sarion - create Asia1 Account
}