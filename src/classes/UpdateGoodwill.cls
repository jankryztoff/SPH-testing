public with sharing class UpdateGoodwill {
    
    
    public String getResponse() {
        return response;
    }
   
// Author: Marvin Gatchalian
// Date: 10/20/2014
// Defect/CR no:
// Logic: 
//      High-Level: Update the Zuora Account Good Will field
//      Detailed:   update good will field after approval of case
//
// Update:
// Update by:
// Update date:
// Defect/CR no:
// Update reason:
//      High-Level: 
//      Detailed:   
    
    String returnUrl;
    String billingAccountId;
    
    public String response { get; set; }
    public static Boolean isTrue = true; //START PD-0174 23-MAY-2016 KTUMANENG Added "else if condition for SUCCESS and ERROR response" to cover ERROR condition in test class
    
    

    @future (callout=true)
    public static void updateZuoraGoodWillCall(string goodwillValue, string billingAccountId){
    
    //Log in to Zuora
    Zuora.zApi zApiInstance = new Zuora.zApi();
    map<string,boolean> map2 = new map<string,boolean>();
        try {
            if(!Test.isRunningTest()){
                zApiInstance.zlogin();
            }
        }
        catch(Zuora.zAPIException ex){
            //m = ex.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage())); 
        }
        catch (Zuora.zForceException ex) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage())); 
        }

        //Update Zuora Customer Account Object
        Zuora.zObject rec = new Zuora.zObject('Account');
        rec.setValue('Id', billingAccountId);
        rec.setValue('Goodwill_Amount__c', goodwillValue);
            
            try {
                List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};
                List<Zuora.zApi.SaveResult> results;
                    if(!Test.isRunningTest()){
                        results = zApiInstance.zupdate(objs);
                        //system.debug('>>>>>>>222' + objs);
                    }
                    
                    /* START PD-0174 23-MAY-2016 KTUMANENG Added "else if condition for SUCCESS and ERROR response" to cover ERROR condition in test class*/
                    else if(isTrue){
                        results                         = new List<Zuora.zApi.SaveResult>() ;
                        Zuora.zApi.SaveResult result    = new Zuora.zApi.SaveResult();

                        result.Success = TRUE;
                        result.Id = '123vd';
                        results.add(result);
                    }else{
                        results                         = new List<Zuora.zApi.SaveResult>();
                        Zuora.zApi.SaveResult res       = new Zuora.zApi.SaveResult();
                        Zuora.zObject error             = new Zuora.zObject('Error');
                        Zuora.zObject[] errors          = new List<Zuora.zObject>();

                        error.setValue ('Code', 'test error');
                        error.setValue ('Message', 'test message');
                        errors.add(error);
                                
                        
                        res.Success     = false; 
                        res.id          = null;
                        res.Errors      = errors;
                        results.add(res);
                    }
                    //END PD-0174 23-MAY-2016 KTUMANENG Added "else if condition for SUCCESS and ERROR response" to cover ERROR condition in test class
                    
                for (Zuora.zApi.SaveResult result : results) {  
                    if (result.Success){  
                        string createdId = result.Id;
                        boolean isSuccess = result.Success;
                        //string updateError = result.Errors;
                        map2.put('Success',result.Success);
                        
                    } 
                    
                    else {  
                        Zuora.zObject[] errors = result.errors; 
                        for (Zuora.zObject error : errors) {  
                            String errorCode = (String)error.getValue('Code');  
                            String message = (String)error.getValue('Message');  
                            String FullErrorr = errorCode + message ;
                        }  
                    }  
        
                }  
            } 
           
            catch (Zuora.zRemoteException ex) {  
                if ('INVALID_FIELD' == ex.code) {  
                } 
                
            } 
            
            catch (Zuora.zAPIException ex) {  
                ex.getMessage();  
            }
            
            catch (Zuora.zForceException ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));  
            }

        }
    }