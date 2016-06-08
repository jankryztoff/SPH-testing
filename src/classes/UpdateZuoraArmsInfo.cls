public with sharing class UpdateZuoraArmsInfo {
    
        public String getResponse() {
        return response;
    }

// Author: Percival Gacad
// Date: 8/21/2014
// Defect/CR no:
// Logic: 
//      High-Level: Update the Zuora Account with ARMS no and AGD No
//      Detailed:   After the Billing Account record has been created, update the Zuora's Customer Account record with ARMS no and AGD Unit
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
    
    public String paymentMethodId {get; set;}
    
    public String response { get; set; }
    
    public String c { get; set; }

    public String paymentMethod { get; set; }
    
    
   //public UpdateZuoraArmsInfo(ApexPages.StandardSetController controller) {
        //returnUrl = ApexPages.currentPage().getParameters().get('retURL');  
        //billingAccountId = ApexPages.currentPage().getParameters().get('zid');
    //}
    
    
    public void updateZuoraAccount() {
        returnUrl = ApexPages.currentPage().getParameters().get('retURL');  
        billingAccountId = ApexPages.currentPage().getParameters().get('zid');
    
        updateZuoraAccount(billingAccountId);
        //return new PageReference(returnUrl);
        response = 'success';
    }

    public void updateZuoraAccount(string zId)
	{
        // START: Code Review Implementation 2/13/2015 JAlejandro
        if (zId !=null)
		{ // END: Code Review Implementation 2/13/2015 JAlejandro
			Zuora__CustomerAccount__c c = [select Zuora__Zuora_Id__c, Payment_Mode__c, ARMS_Account_Number__c, Zuora__PaymentMethod_Type__c, AGD_Unit__c from Zuora__CustomerAccount__c where id = :zId];
			string ZuoraId = c.Zuora__Zuora_Id__c;
			string ArmsNo = c.ARMS_Account_Number__c;
			string PayMode = c.Payment_Mode__c;   
			//valgacad 08292014: removed due to confirmed approach on when the AGD Unit will be sync to Zuora refer to: QL-210 of the toolkit
			string AGDNo = c.AGD_Unit__c;
			system.debug('>>>>>>>' +c);
			updateCustomerAccount(ZuoraId, ArmsNo, AGDNo, PayMode);
		}// Code Review Implementation 2/13/2015 JAlejandro
    }
    
    public static void updateCustomerAccount(String billingAccountId, string armsNo, string AGDNo, string PayMode){
    //Log in to Zuora
    String paymentMethodId;
    Zuora.zApi zApiInstance = new Zuora.zApi();
        
        try {
            if(!Test.isRunningTest()){zApiInstance.zlogin();}
            
            //else {zApiInstance.zlogin();}
        }
        catch(Zuora.zAPIException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));
            //m = ex.getMessage(); 
        }
        catch (Zuora.zForceException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage())); 
        }
        
        /*if (PayMode == 'Cash'){
            paymentMethodId = '2c92c0f843dca14e0143e429e7d96f18';          
        }
        else if (PayMode== 'Cheque'){
            paymentMethodId = '2c92c0f843dca14e0143e429e79c6f08';
        }  
        else if (PayMode== 'Credit Card'){
            paymentMethodId = '2c92c0f843dca14e0143e429e7ab6f0c';
        }*/ 
        //system.debug('>>>>>>>>>>>' + paymentMethodId +  PayMode);
        //system.assertEquals(paymentMethodId +'','');
        //Update Zuora Customer Account Object
        Zuora.zObject rec = new Zuora.zObject('Account');
        rec.setValue('Id', billingAccountId);
        //START UD-2649 21-Sept-2015 Removed by S.Puli - remove update of ARMS info to Zuora
	//rec.setValue('ARMS_Account_Number__c', armsNo );
	//ENd UD-2649 21-Sept-2015
        //valgacad 08292014: removed due to confirmed approach on when the AGD Unit will be sync to Zuora refer to: QL-210 of the toolkit
        rec.setValue('AGD_Unit__c', agdNo );
        //rec.setValue('DefaultPaymentMethodId', paymentMethodId);
            
            try {
                List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};
                List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(objs);
                //List<Zuora.zApi.SaveResult> results;
                    if(!Test.isRunningTest()){
                        system.debug('>>>>>>>222' + Test.isRunningTest());
                        results = zApiInstance.zupdate(objs);
                    }
                                    
                    else{
                        results = new List<Zuora.zApi.SaveResult>() ;
                        Zuora.zApi.SaveResult result = new Zuora.zApi.SaveResult();
                        result.Success = TRUE;
                        //Start CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded ID
                        result.Id = GlobalVariableClass.UPDATE_ARMS_INFO_RESULTID;
                        //End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded ID
                        results.add(result);
                                             
                    }
                system.debug('>>>>>>>1111' + results);
                    
                for (Zuora.zApi.SaveResult result : results) {  
                    if (result.Success){  
                        string createdId = result.Id; 
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
                /*if ('INVALID_FIELD' == ex.code) {  
                } 
                
                else {  
                }*/
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));      
            } 
            
            catch (Zuora.zAPIException ex) {  
                ex.getMessage();  
            }
            
            catch (Zuora.zForceException ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));
            }
    }  
}