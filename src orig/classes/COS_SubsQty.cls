/**
* Class Name: COS_SubsQty
* @author: Accenture PDC - Sherwin Puli
* Date: 17.Dec.2014
* Requirement/Project Name: SF SPH
* @description: 
*/

public with sharing class COS_SubsQty {
    
    
    public String getResponse() {
        return response;
    }
    
    public String response { get; set; }
    
    public static void updateZuoraSubFields(String zSubId, String Qty){
        
        try{    
   
            Zuora.zApi zApiInstance = new Zuora.zApi();
            map<string,boolean> map2 = new map<string,boolean>();
                try {
                    if(!System.Test.isRunningTest()){
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
                
                //Update Zuora Billing Contact Object
                Zuora.zObject rec = new Zuora.zObject('Subscription');
                    if(zSubId<>null && zSubId<>'null'){
                        rec.setValue('Id', zSubId);
                    }
                    if(Qty<>null && Qty <>'null'){
                        rec.setValue('Qty1__c', Qty);
                    }
                    
            try {
                    List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};
                    List<Zuora.zApi.SaveResult> results;
                        if(!System.Test.isRunningTest()){
                            results = zApiInstance.zupdate(objs);
                            //system.debug('>>>>>>>222' + objs);
                        }
                        
                                  
                        else{
                            results = new List<Zuora.zApi.SaveResult>() ;
                            Zuora.zApi.SaveResult result = new Zuora.zApi.SaveResult();
                            result.Success = TRUE;
                            result.Id = '123vd';
                            results.add(result);
                                                 
                        }
                    
                        
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
                    
                    else {  
                    }  
                } 
                
                catch (Zuora.zAPIException ex) {  
                    ex.getMessage();  
                }
                
                catch (Zuora.zForceException ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));  
                }
        } catch(Exception e){
            system.debug('error' + e);
        }
    }
}