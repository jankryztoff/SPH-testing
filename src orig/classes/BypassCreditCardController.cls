public class BypassCreditCardController{

    public Account thisAccount {get; set;}
    public Zuora__CustomerAccount__c thisBillingAccount {get; set;}
    public Case thisCase {get; set;} 
    public String paymentMethodId {get; set;}
    public string batchNumber {get; set;}
    

    public BypassCreditCardController() {
        thisCase = new Case();
        thisCase.RecordtypeID = [Select Id, Name From Recordtype where Sobjecttype = 'Case' AND name = 'Bypass Credit Card' limit 1].Id;

    }
    
    public void updateZuoraAccount(string zId){
    
    Zuora__CustomerAccount__c c = [select Zuora__Zuora_Id__c, ARMS_Account_Number__c, AGD_Unit__c  from Zuora__CustomerAccount__c where Zuora__Zuora_Id__c = :zId];
    string ZuoraId = c.Zuora__Zuora_Id__c;
    system.debug('>>>>>>>' +c);

  }

    public String getSource() {        
        Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance( 'Default' );
        String iframeSrc;
        String id = hpm.Id__c;
        String tenantId = hpm.Tenant_Id__c;
        String APISecurityKey = hpm.Api_Security_Key__c;
        String ZuoraURL = hpm.Zuora_Url__c ;

        Datetime cdt = datetime.now();        
        String timestamp= String.valueOf(cdt.getTime());
        Integer len = 32;
        
        String token = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0,len);
        
        String inputString = 'id='+id+'&tenantId='+tenantId+'&timestamp='+timestamp+'&token='+token+APISecurityKey;
        String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(inputString)));
        String signature =  EncodingUtil.base64Encode(Blob.valueOf(md5Coded));
        
        iframeSrc  = ZuoraURL + '/PublicHostedPage.do?method=requestPage&id='+id+'&tenantId='+tenantId+'&timestamp='+timestamp+'&token='+token+'&signature='+signature;

        return iframeSrc;
    }

    public pageReference saveRecord(){
    
        String returnId;
        Boolean resultsuccess = true;
        Zuora.zApi zApiInstance = new Zuora.zApi();
        
        try{
           
            zApiInstance.zlogin();            
        }
        catch (Zuora.zRemoteException ex) {
            if ('INVALID_LOGIN' == ex.code) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error trying to save case. Error:'));         
            }
        }
        try {
            Zuora.zObject acc = new Zuora.zObject('Account');
            acc.setValue('Id','2c92c0f8479f6c3c0147a9addf487888'); //an existing account
            if(thisCase.Stop_Charging_Credit_Card__c == True){
            acc.setValue('Batch','Batch20');
            }
            else if (thisCase.Start_Charging_Credit_Card__c == True) {
            acc.setValue('Batch','Batch2');
            } 
            List<Zuora.zObject> objs = new List<Zuora.zObject> {acc};
            List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(objs);
             
            for (Zuora.zApi.SaveResult result : results) {
            if (result.Success){
            //get the updated id
            String updatedId = result.Id;
            } else {
            Zuora.zObject[] errors = result.errors;
            for (Zuora.zObject error : errors) {
            String errorCode = (String)error.getValue('Code');
            String message = (String)error.getValue('Message');
            }
            }
            }
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_FIELD' == ex.code) {
            // An invalid field was specified
            } else {
            }
            } catch (Zuora.zAPIException ex) {
            ex.getMessage();
            } catch (Zuora.zForceException ex) {
            }
            
        try {
            if(thisCase.Stop_Charging_Credit_Card__c == True){
            thisCase.Charge_Status__c = 'Do Not Charge';
            insert thisCase;
            }
            
            
            if(thisCase.Stop_Charging_Credit_Card__c == True){
                thisCase.Charge_Status__c = 'Do Not Charge';
                thisBillingAccount = new Zuora__CustomerAccount__c();
                thisBillingAccount.ID = thisCase.Billing_Account_Name__c;
                update thisBillingAccount;
            }
        }
        catch(DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error trying to save case. Error: ' +  e.getMessage()));
            return null;
        }    
            
        if(thisCase.Id != NULL) {
            returnId = thisCase.Id; 
        }
        return new PageReference('/' + returnId);
    } 
    
    public PageReference saveandnew(){
    
        String returnId;
        Boolean resultsuccess = true;
        Zuora.zApi zApiInstance = new Zuora.zApi();
        
        try{
           
            zApiInstance.zlogin();            
        }
        catch (Zuora.zRemoteException ex) {
            if ('INVALID_LOGIN' == ex.code) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error trying to save case. Error:'));         
            }
        }
        try {
            Zuora.zObject acc = new Zuora.zObject('Account');
            acc.setValue('Id','2c92c0f8479f6c3c0147a9addf487888'); //an existing account
            if(thisCase.Stop_Charging_Credit_Card__c == True){
            acc.setValue('Batch','Batch20');
            }
            else if (thisCase.Start_Charging_Credit_Card__c == True) {
            acc.setValue('Batch','Batch2');
            } 
            List<Zuora.zObject> objs = new List<Zuora.zObject> {acc};
            List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(objs);
             
            for (Zuora.zApi.SaveResult result : results) {
            if (result.Success){
            //get the updated id
            String updatedId = result.Id;
            } else {
            Zuora.zObject[] errors = result.errors;
            for (Zuora.zObject error : errors) {
            String errorCode = (String)error.getValue('Code');
            String message = (String)error.getValue('Message');
            }
            }
            }
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_FIELD' == ex.code) {
            // An invalid field was specified
            } else {
            }
            } catch (Zuora.zAPIException ex) {
            ex.getMessage();
            } catch (Zuora.zForceException ex) {
            }
            
        try {
            insert thisCase;
            if(thisCase.Stop_Charging_Credit_Card__c == True){
                thisBillingAccount = new Zuora__CustomerAccount__c();
                thisBillingAccount.ID = thisCase.Billing_Account_Name__c;
                thisCase.Charge_Status__c = 'Do Not Charge';
                update thisBillingAccount;
            }
        }
        catch(DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error trying to save case. Error: ' +  e.getMessage()));
            return null;
        }    
            
        if(thisCase.Id != NULL) {
            returnId = thisCase.Id; 
        }
        PageReference pageRef = new pageReference('/apex/BypassCreditCard?caseId=' + returnId);
        pageRef.setRedirect(true);
        return pageRef;
    
    }  
    
    public PageReference cancel(){
        PageReference pageRef = new PageReference('/500/o');
        pageRef.setRedirect(true);
        return pageRef;
    }

}