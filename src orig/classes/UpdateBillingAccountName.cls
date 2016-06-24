public with sharing class UpdateBillingAccountName {

    public String getResponse() {
        return response;
    }
   
    // Author: Krithika D
    // Date: 11/11/2014
    // Defect/CR no:
    // Logic: 
    // Update:
    // Update by:
    // Update date:
    // Defect/CR no:
    // Update reason:
    // High-Level: 
    // Detailed:   
    
    String returnUrl;
    String billingAccountId;
    
    public String response { get; set; }
    public static Boolean isTrue = true; //Start END PD-0174 - Loven Reyes 5/23/16
    
    @future (callout=true)
    public static void updateZuoraBillingAccount(string Name, string BillingaccntID){
    
        //Log in to Zuora
        Zuora.zApi zApiInstance = new Zuora.zApi();
        map<string,boolean> map2 = new map<string,boolean>();
        try {
            if(!system.Test.isRunningTest()){
                zApiInstance.zlogin();
            }
        }catch(Zuora.zAPIException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage())); 
        }catch (Zuora.zForceException ex) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage())); 
        }

        //Update Zuora Customer Account Object
        Zuora.zObject rec = new Zuora.zObject('Account');
        rec.setValue('Id', BillingaccntID);
        rec.setValue('Name', Name);
            
        try {
            List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};
            List<Zuora.zApi.SaveResult> results;

            //Start PD-0174 - Loven Reyes 5/23/16
            //created isTrue to cover from Test class
            if(!system.Test.isRunningTest()){
                results = zApiInstance.zupdate(objs);
            }else if(isTrue){
                results = new List<Zuora.zApi.SaveResult>() ;
                Zuora.zApi.SaveResult result = new Zuora.zApi.SaveResult();

                result.Success = TRUE;
                result.Id = '123vd';
                results.add(result);
            }else{
                results = new List<Zuora.zApi.SaveResult>();
                Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                Zuora.zObject error = new Zuora.zObject('Error');
                Zuora.zObject[] errors = new List<Zuora.zObject>();

                error.setValue ('Code', 'test error');
                error.setValue ('Message', 'test message');
                errors.add(error);
                        
                res.Success = false; 
                res.id = null;
                res.Errors = errors;
                results.add(res);
            }
            //END PD-0174 - Loven Reyes 5/23/16
                
            for (Zuora.zApi.SaveResult result : results) {  
                if (result.Success){  
                    string createdId = result.Id;
                    boolean isSuccess = result.Success;
                    map2.put('Success',result.Success);
                } 
                else {  
                    Zuora.zObject[] errors = result.errors; 
                    for (Zuora.zObject error : errors) {  
                        String errorCode = (String)error.getValue('Code');  
                        String message = (String)error.getValue('Message');  
                        String FullErrorr = errorCode+message;
                    }  
                }  
            }  
        }catch (Zuora.zRemoteException ex) {  
            if ('INVALID_FIELD' == ex.code) {  
            } 
            else {  
            }  
        }catch (Zuora.zAPIException ex) {  
            ex.getMessage(); 
        }catch (Zuora.zForceException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));  
        }
    }
}