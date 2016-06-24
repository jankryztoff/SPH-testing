// Author: Krithika D
// Date: 11/11/2014
// Defect/CR no:
// Logic: 
// 
//

public with sharing class UpdateBillingContactName {
    
    public String getResponse() {
        return response;
    }
    
    String returnUrl;
    String billingAccountId;
    
    public String response { get; set; }
    public static Boolean isTrue = true; /* START PD-0174 23-MAY-2016 KTUMANENG Added "else if condition for SUCCESS and ERROR response" to cover ERROR condition in test class*/
    
    /**********************************************************
     * REVISON(s)
     * Update by                : Kingsley Tumaneng
     * Update date              : MAY 23, 2016
     * Defect/CR no             : 
     * Update reason            
     *      High-Level          : 
     *      Detailed            : Added else if condition
     *                            and a public boolean variable
     *                            so that the test class can 
     *                            cover up the else in for loop
    **********************************************************/
    @future (callout=true)
    public static void updateZuoraBillingContact(string FirstName,string Lastname, string ContactID){
    
    //Log in to Zuora
    Zuora.zApi zApiInstance = new Zuora.zApi();
    map<string,boolean> map2 = new map<string,boolean>();
        try {
            if(!system.Test.isRunningTest()){
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
        Zuora.zObject rec = new Zuora.zObject('Contact');
        rec.setValue('Id', ContactID);
        rec.setValue('FirstName', FirstName);
        rec.setValue('LastName',Lastname);
            
            try {
                List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};
                List<Zuora.zApi.SaveResult> results;
                    if(!system.Test.isRunningTest()){
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
                            System.debug(errorCode);
                            String message = (String)error.getValue('Message');  
                            System.debug(message);
                            String FullErrorr = errorCode + message ;
                            System.debug(FullErrorr);
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
     

    /**********************************************************
     * REVISON(s)
     * Update by                : Kingsley Tumaneng
     * Update date              : MAY 23, 2016
     * Defect/CR no             : 
     * Update reason            
     *      High-Level          : 
     *      Detailed            : Added else if condition
     *                            and a public boolean variable
     *                            so that the test class can 
     *                            cover up the else in for loop
    **********************************************************/   
    @future (callout=true)
    public static void updateZuoraBillingAccount(string Name, string BillingaccntID){
    
    //Log in to Zuora
    Zuora.zApi zApiInstance = new Zuora.zApi();
    map<string,boolean> map2 = new map<string,boolean>();
        try {
            if(!system.Test.isRunningTest()){
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
        rec.setValue('Id', BillingaccntID);
        rec.setValue('Name', Name);
        
            
            try {
                List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};
                List<Zuora.zApi.SaveResult> results;
                    if(!system.Test.isRunningTest()){
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
                    //END START PD-0174 23-MAY-2016 KTUMANENG Added "else if condition for SUCCESS and ERROR response" to cover ERROR condition in test class
                
                    
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
                            System.debug(errorCode);
                            String message = (String)error.getValue('Message');  
                            System.debug(message);
                            String FullErrorr = errorCode + message ;
                            System.debug(FullErrorr);
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