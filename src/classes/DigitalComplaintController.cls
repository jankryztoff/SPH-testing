public with sharing class DigitalComplaintController {
    
    public  Asia1__c asia1Rec;
    public static String Errors;
    public Map<String, String> responseMap = new Map<String, String>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
    public boolean resetPassword(Case ca, string UserName, String asia1Id, string NewPassword, String SVC, String displayName){
        boolean isSuccess = TRUE;
        String Status = 'Success'; //remove this afterwards
        String PasswordReset;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        responseMap = AsiaOneServicesController.resetUserPassword(UserName, NewPassword); //--comment this out for testing purposes to avoid callout 
        PasswordReset = (String)responseMap.get('Password-Reset');
        
        
        //assuming that response map has a key-value pair of "RequestStatus" => <request status>
        if(responseMap.containsKey('Password-Reset')) {
            if(PasswordReset=='Success')
            {
                isSuccess = TRUE;
                Status = 'Success';
                insert createDigitalComplaintItems(ca, userName, /*asia1Id,*/ NewPassword, SVC, displayName ,Status);
            }
            else
            {
                isSuccess = FALSE;
                Status = 'FAILED';
                insert createDigitalComplaintItems(ca, userName, /*asia1Id,*/ NewPassword, SVC, displayName ,Status);
                Errors = (String)responseMap.get('Errors');
            }
        }
        
        return isSuccess;
    }
    
    public String getErrors()
    {
        return Errors;
    }
    
    public Map<String, Boolean> validateNewUsername(String UserName, string displayName) {
       
        boolean isSuccessUserName = TRUE;
        boolean isSuccessDisplayName = TRUE;
        Map<String, Boolean> mapValidationResults = new Map<String, Boolean>();
        String Status;
        Map<String, Object> responseMapUser = new Map<String, Object>();
        Map<String, Object> responseMapDisp = new Map<String, Object>();
     
      
        responseMapUser = AsiaOneServicesController.validateUserName(UserName); //--comment this out for testing purposes to avoid callout 
        
        if(responseMapUser.containsKey('User-Availability')) {
            Status = (String)responseMapUser.get('User-Availability');
            if(Status=='Success')
            {
                isSuccessUserName = TRUE;
               
            }
            else
            {
                isSuccessUserName = FALSE;
            }
        }
       
        responseMapDisp = AsiaOneServicesController.validateDisplayName(displayName); //--comment this out for testing purposes to avoid callout
        //assuming that response map has a key-value pair of "RequestStatus" => <request status>
        if(responseMapDisp.containsKey('DisplayName-Availability')) {
            Status = (String)responseMapDisp.get('DisplayName-Availability');
            if(Status=='Success')
            {
                isSuccessDisplayName = TRUE;
            }
            else
            {
                isSuccessDisplayName = FALSE;
            }
        }
        mapValidationResults.put('userNameValidationResult', isSuccessUserName);
        mapValidationResults.put('dispNameValidationResult', isSuccessDisplayName);
        
        return mapValidationResults;
    }
    
	//START: UD-3819 1/26/16 Added by Manolo Valena
    public boolean enableAccount(Case ca, Map<String, String> accountMap) {
        boolean isSuccess = TRUE;
        String Status;
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap = AsiaOneServicesController.enableUserAccount(accountMap.get(GlobalVariableClass.USERNAME));
        if(responseMap.containsKey(GlobalVariableClass.RESPONSE_ENABLE_ACCOUNT)) {
            Status = (String)responseMap.get(GlobalVariableClass.RESPONSE_ENABLE_ACCOUNT);
            if(Status == GlobalVariableClass.ZUORA_SUCCESS) {
                isSuccess = TRUE;
            }
            else {
                isSuccess = FALSE;
                Errors = (String)responseMap.get(GlobalVariableClass.RESPONSE_ERRORS);
            }
        }
        return isSuccess;
    }
    //END: UD-3819 1/26/16 Added by Manolo Valena
	
    public boolean enableServiceFlag(Case ca, String Username, String SVC){
        boolean isSuccess = TRUE;
        String Status;
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap = AsiaOneServicesController.enableService(UserName, svc);
        //assuming that response map has a key-value pair of "RequestStatus" => <request status>
        if(responseMap.containsKey('Activate')) {
            status = (String)responseMap.get('Activate');
            if(status == 'Success')
            {
                isSuccess = TRUE;
                insert createDigitalComplaintItems(ca, userName, '', svc, '', Status);
            }
            else
            {
                isSuccess = FALSE;
                insert createDigitalComplaintItems(ca, userName, '', svc, '', Status);
                Errors = (String)responseMap.get('Errors');
            }
        }
        
        return isSuccess;
    }

        
    public boolean disableServiceFlag(Case ca, string UserName, /*String Asia1Id,*/ String password, String displayName, string svc){
        
        
        boolean isSuccess = TRUE;
        String Status;
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap = AsiaOneServicesController.disableService(UserName, svc);
        //assuming that response map has a key-value pair of "RequestStatus" => <request status>
        if(responseMap.containsKey('Deactivate')) {
            status = (String)responseMap.get('Deactivate');
            
            if(status == 'Success')
            {
                isSuccess = TRUE;
                insert createDigitalComplaintItems(ca, userName, /*asia1Id,*/ '', svc, '', Status);
             
            }
            else
            {
                isSuccess = FALSE;
                insert createDigitalComplaintItems(ca, userName, /*asia1Id,*/ '', svc, '', Status);
                Errors = (String)responseMap.get('Errors');
            }
        }
        
        return isSuccess;
    }
    
    public boolean createAccount(Case ca, Map<String, String> accountMap){
        
        boolean isSuccess = FALSE;
        String Status;
        String Asia1Id = accountMap.get('Id');
        String UserName = accountMap.get(GlobalVariableClass.USERNAME);
        String displayName = accountMap.get(GlobalVariableClass.DISPLAY_NAME);
        String Password = accountMap.get(GlobalVariableClass.PASSWORD);
        String Email= accountMap.get(GlobalVariableClass.EMAIL);
        String svc= accountMap.get(GlobalVariableClass.SVC);
        Map<String, Object> responseMap = new Map<String, Object>();
        
        responseMap = AsiaOneServicesController.createAccount(accountMap);
        //assuming that response map has a key-value pair of "RequestStatus" => <request status>
        if(responseMap.containsKey('Sign-Up')) {
            Status = (String)responseMap.get('Sign-Up');
            if(Status=='Success')
            {
                isSuccess = TRUE;
                //START D-2942 25-06-2015 Marvin Gatchalian this is no longer needed as asia1 is already created 
                //createAsia1(UserName, displayName , 'Sucessfully Created', Password, Email);
                //START D-2942 25-06-2015 Marvin Gatchalian this is no longer needed as asia1 is already created 
                
                //insert createDigitalComplaintItems(ca, userName,Password, svc, displayName, Status); D-2096 2/4/2015 Updated by James - Commenting line to avoid duplicate digital complaint item record creation
            }
        }
        if(responseMap.containsKey('Error')){
                isSuccess = FALSE;
                Errors = (String)responseMap.get('Error');
                //insert createDigitalComplaintItems(ca, userName,Password, svc, displayName, Status); D-2096 2/4/2015 Updated by James - Commenting line to avoid duplicate digital complaint item record creation
        }
        return isSuccess;  
    }
    // for easy access to Asia1 param: (String UserName, String displayName , String isSuccess, String Password, String Email)
    

    public Digital_Complaint_Items__c createDigitalComplaintItems(Case ca, string userName, string password, string svc, string displayName, String Status) {
        
 
            Digital_Complaint_Items__c dciRec = new Digital_Complaint_Items__c();
        
            dciRec.Case_No__c = ca.id;
            dciRec.Email__c = ca.SuppliedEmail;
            
            //values from parameters
            dciRec.SPH_Online_User_Id__c = UserName;
            dciRec.New_Password__c = password;
            dciRec.Status__c = Status;
            
            //for record type of digital complaint upon insert
            if (ca.Sub_Category__c == 'Change/Reset Password') {
                      dciRec.RecordTypeId = (Id)ConstantsSLB.getKeyId('Reset_Password');  
                  } else {
                      if (ca.Sub_Category__c == 'User Id Not Created/Activated') {
                              dciRec.RecordTypeId = (Id)ConstantsSLB.getKeyId('Create_User');  
                      } else {
                              if (ca.Sub_Category__c == 'Deactivate User Id') {
                                      dciRec.RecordTypeId = (Id)ConstantsSLB.getKeyId('Deactivate_User');  
                              } else {
                                      dciRec.RecordTypeId = (Id)ConstantsSLB.getKeyId('Force_Logout');                      
                              }                      
                      }                      
                  }
            
       
        return dciRec;

    }
    //creating Asia1 in SF    
    private void createAsia1(String UserName, String displayName , String status, String Password, String Email){
        
        Asia1__c asia1Rec = new Asia1__c();
        
        
        //values from CreateAsia1
        asia1Rec.User_ID_LDAP_ID__c = UserName;
        asia1Rec.Display_Name__c = displayName;
        asia1Rec.Password__c = Password;
        asia1Rec.Email__c = Email;
        
        insert asia1Rec;
    }
}