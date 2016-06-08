/*
* Class Name: Asia1Activation
* @author: Karl Tan
* Date: 06-11-2014
* Requirement/Project Name: SPH
* @description:
*/

//START UD-0285 03-26-2015 Marvin Gatchalian - Major modification
    
    /* Revision Date 03-25-2015
    * Class Name: Asia1Activation
    * @by: Marvin Gatchalian
    * Date: 03-25-2015
    * Requirement/Project Name: SPH
    * @description: Add expiration and logic for one time use only
    */



public class Asia1Activation {

    


    public Asia1__c thisAsia1 {get; set;}
    public Boolean isSuccess {get; set;}
    public Boolean isActivated {get; set;}
    public Boolean onLoad {get; set;}
    public Boolean isEnabled {get; set;}
    public Boolean isExpired {get; set;}
    public Boolean isMessageShown {get; set;}
    public String messageResult {get; set;}
    Boolean proceedWithUpdate;
    
    public Asia1Activation (ApexPages.StandardController controller) {
        this.thisAsia1 = (Asia1__c)controller.getRecord();
        
        checkIfExptired();
        isActivated = FALSE;
        isSuccess = FALSE;
        isEnabled = FALSE; 
        isMessageShown = FALSE;
        onLoad = True;
        
    
    }


    /*
     *@Description: calls Asia1 Webservice to verify Asia1 Credentials
     *@Parameters: Map<String, Object> 
     *@Return: Boolean Status of the Response of Callout
    */
    public void checkIfExptired() {
        
        if (thisAsia1.Base_Date_Expiration__c < date.today()) {

                thisAsia1.Is_Link_Expired_Used__c = true;
                proceedWithUpdate = true;
        }
        
        
        if (thisAsia1.Is_Link_Expired_Used__c) {
            messageResult = 'link session is expired or already been used.';
            isMessageShown = true;
            onLoad = false;
        }
        
    }
     
    public void verifyAccount(){
        
        
        //PageReference pref = ApexPages.currentPage();
        
        onLoad = False;   
        String Status;
        
        String Errors;
        proceedWithUpdate = false;
        Map<String, Object> responseMap = new Map<String, Object>();
        

        if(thisAsia1.User_ID_LDAP_ID__c !=null){
            checkIfExptired();
            if (!thisAsia1.Is_Link_Expired_Used__c) {
                responseMap = AsiaOneServicesController.enableUserAccount(thisAsia1.User_ID_LDAP_ID__c);
            }
        }    
        
            
        if(responseMap.containsKey('Enable-Account')) {
            status = (String)responseMap.get('Enable-Account');
            isMessageShown = TRUE;
            if(status == 'Success'){
                    thisAsia1.ID_Already_Active__c = true;
                    thisAsia1.Is_Link_Expired_Used__c = true;
                    thisAsia1.Enabled__c = true;    // Start/End UD-2864 29Sep15 JohnD
                    messageResult = status;
                    proceedWithUpdate = true;
                    
            }
            else {
                messageResult = (String)responseMap.get('Errors');
                if(messageResult.contains('is already enabled.')) {
                    thisAsia1.ID_Already_Active__c = true;
                    thisAsia1.Is_Link_Expired_Used__c = true;
                    thisAsia1.Enabled__c = true;    // Start/End UD-2864 29Sep15 JohnD
                    proceedWithUpdate = true;
                }
   
            }
        }
        
        try{
            if (proceedWithUpdate) {
                update thisAsia1;
            }
        } 
        catch(Exception e) {
        }
        
        //return pref;
    }    
    
}


//END UD-0285 03-26-2015 Marvin Gatchalian - Major modification