// Author: Percival Gacad
// Date: 9/03/2014
// Defect/CR no:
// Logic: 
//      High-Level: Update the Zuora Account Batch Number
//      Detailed:   Subscriber who wishes to bypass their invoice temporarily 
//
/* Class Name : UpdateBatchNumber
* History : include all changes
* Update on : 7/10/15
* Description : UD-1805 Bypass CreditCard. transfer invoice ownership for stop 
* and start charging
*/
 

public with sharing class UpdateBatchNumber {

    final String PMTHD_INV_ID = ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other');
    Zuora__CustomerAccount__c zclone;
    Contact contactBilling;
    List<Zuora__Subscription__c> subList;
    Case c;
    Account acc;
    ZuoraCallOut zCallout = new ZuoraCallOut();
    String BillingAcctId;
    String BillingContId;
    Boolean toGenInvoice;
    ZuoraBillingAccount zBa = new ZuoraBillingAccount();
    String Zourabillingacountid;
    
    public String getResponse() {
        return response;
    }
       
    String returnUrl;
    String billingAccountId;
    
    public String response { get; set; }
    
    
    public void queryBillingAccount() {
        returnUrl = ApexPages.currentPage().getParameters().get('retURL');  
        billingAccountId = ApexPages.currentPage().getParameters().get('cid');
        queryBillingAccount(billingAccountId);
        response = 'success';
    }
    
    public void queryBillingAccount(string cId){
        
        Map<String,Object> billingAccMap = new Map<String,Object>();
        Map<String,String> billingAccResultMap = new Map<String,String>();
        Zuora__CustomerAccount__c oldBillingAccount; //START-END D-3955 12/8/2015 Added by K. Tan
        try{
            //START UD-3833 2/22/2016 Added by J.Sarion - Added Billing Type
            c = [select Id, Billing_Account_Name__c, Stop_Charging_Credit_Card__c, Start_Charging_Credit_Card__c, Old_Batch_Number__c, Billing_Account_Name__r.Zuora__Account__c, Billing_Account_Name__r.Billing_Contact__c, Status, Generate_Arms_Invoice__c, Billing_Account_Name__r.Billing_Type__c from Case where Id = :cId AND Status = 'Closed'];    
            //END UD-3833 2/22/2016 Added by J.Sarion - Added Billing Type
        }
        catch(Exception e) {
            
            //e.setMessage('Case must be closed.');
            throw new CustomException('Case must be closed.');
        }
        

        
        string billAccountId = c.Billing_Account_Name__c;
        boolean stopCharge = c.Stop_Charging_Credit_Card__c;
        boolean startCharge = c.Start_Charging_Credit_Card__c;
        boolean generateInvoice = c.Generate_Arms_Invoice__c;
        
        //STARTR UD-3833 2/22/2016 Added by J.Sarion - Added Billing Type
        acc = [SELECT Id, Name, (SELECT Id, Payment_Mode__c, Zuora__External_Id__c, Other_PaymentMethod__c, Billing_Contact__c, ARMS_Debt_Management__c, ARMS_Business_Profile__c FROM R00N40000001kyLcEAI__r WHERE Other_PaymentMethod__c = 'Invoice' AND Payment_Mode__c = 'Other' AND Billing_Type__c =: c.Billing_Account_Name__r.Billing_Type__c  Order BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id =: c.Billing_Account_Name__r.Zuora__Account__c];
        //END UD-3833 2/22/2016 Added by J.Sarion - Added Billing Type
        
        if(acc.R00N40000001kyLcEAI__r.size()>0){
            
            toGenInvoice = false;                   
        }
        else{           
            toGenInvoice = true;
            
        }
        //START UD-1805 AddedBy FrancisBenzon : added Zuora__External_Id__c in query
        Zuora__CustomerAccount__c z = [select Zuora__Zuora_Id__c, Zuora__Batch__c, Old_Batch_Number__c, Billing_Contact__c, ARMS_Debt_Management__c, ARMS_Business_Profile__c, Zuora__External_Id__c from Zuora__CustomerAccount__c where id = :billAccountId];
        //END UD-1805 AddedBy FrancisBenzon : added Zuora__External_Id__c in query
        
        string ZuoraId = z.Zuora__Zuora_Id__c;
        string ZuoraBatchNumber = z.Zuora__Batch__c;
        string ZuoraOldBatchNumber = z.Old_Batch_Number__c; 

        subList = [select id,Zuora__Zuora_Id__c, Name FROM Zuora__Subscription__c WHERE Zuora__CustomerAccount__c = :z.id];
        zClone = [SELECT Id, Zuora__PaymentMethod_Type__c, Zuora__External_Id__c, Name, Payment_Mode__c,
                                                            Zuora__Currency__c, Zuora__BillCycleDay__c, Zuora__PaymentTerm__c, 
                                                            Zuora__SoldToId__c, Zuora__BillToId__c, Zuora__Account__c, Zuora__Batch__c,
                                                            Billing_Type__c, Other_PaymentMethod__c, Billing_Contact__c, ARMS_Debt_Management__c, ARMS_Business_Profile__c
                                                            FROM Zuora__CustomerAccount__c WHERE Id = :c.Billing_Account_Name__c];
                                                            
                    system.debug('zClone --->' + zClone);         

        if(c.Status  == 'Closed') {
            if (stopCharge == true && ZuoraBatchNumber != ConstantsSLB.getKeyId('Batch Number')){
                z.Old_Batch_Number__c = ZuoraBatchNumber;
                z.Zuora__Batch__c = ConstantsSLB.getKeyId('Batch Number');
                if(generateInvoice == true){                                                             
                    if(toGenInvoice == true){
                        Zourabillingacountid = zBa.CreateBAInZuoraInvoice(zClone, null);
                        if (Zourabillingacountid != null) {   
                            //START UD-1805 AddedBy FrancisBenzon : add input param of old BA
                            zBa.createAmendments(subList, Zourabillingacountid, zClone.Zuora__External_Id__c);
                            //END UD-1805 AddedBy FrancisBenzon : add input param of old BA
                        }
                    }
                    else{
                        if(acc.R00N40000001kyLcEAI__r.size()>0){
                            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>' + ' ' + acc.R00N40000001kyLcEAI__r.size()); 
                            //START UD-1805 AddedBy FrancisBenzon : add input param of old BA
                            zBa.createAmendments(subList, acc.R00N40000001kyLcEAI__r[0].Zuora__External_Id__c, zClone.Zuora__External_Id__c);
                            //END UD-1805 AddedBy FrancisBenzon : add input param of old BA                         
                        }
                        
                    }
                }
            }
            system.debug(':::StartCharging ' + startCharge);
            //START UD-1805 AddedBy FrancisBenzon 7/10/15 : transfer invoice owner of subs to old CC BA
            if (startCharge == true){
                z.Zuora__Batch__c = ZuoraOldBatchNumber;
                Id oldBAId = z.Id;
                String zuoraExternalId_oldBa = z.Zuora__External_Id__c;
                //START D-3955 12/8/2015 Added by K. Tan
                
                try{
                oldBillingAccount = [SELECT Zuora__Zuora_Id__c, Zuora__Account__c,  Zuora__Batch__c, Old_Batch_Number__c, Billing_Contact__c, ARMS_Debt_Management__c, ARMS_Business_Profile__c, Zuora__External_Id__c
                                        from Zuora__CustomerAccount__c WHERE Zuora__Account__c =: c.Billing_Account_Name__r.Zuora__Account__c AND Old_Batch_Number__c != null AND Payment_Mode__c = 'CreditCard' ORDER BY LastModifiedDate DESC LIMIT 1];
                }
                catch(exception e){
                    
                    throw new CustomException('This has been submitted.');  
                    
                }
                String invoiceStr = globalVariableClass.INVOICE;
                List<Zuora__Subscription__c> transferSubsInvoiceOwnerList = new List<Zuora__Subscription__c>();
                system.debug(':::PaymentMethod ' + invoiceStr);
                system.debug(':::OLDBAID ' + oldBAId);
                if(oldBAId != null)
                {
                    try
                    {                      
                        transferSubsInvoiceOwnerList = [Select Id, Name, Zuora__Zuora_Id__c From Zuora__Subscription__c 
                                                Where Zuora__CustomerAccount__c = :oldBAId 
                                                AND Zuora__InvoiceOwner__r.Other_PaymentMethod__c = :invoiceStr];
                        system.debug(':::SUBLIST ' + transferSubsInvoiceOwnerList);
                        if(!transferSubsInvoiceOwnerList.isEmpty())
                        {
                                zBa.createAmendments(transferSubsInvoiceOwnerList, oldBillingAccount.Zuora__Zuora_Id__c, oldBillingAccount.Zuora__Zuora_Id__c);
                                updateZuoraBatchNumber(oldBillingAccount.Zuora__Zuora_Id__c, oldBillingAccount.Old_Batch_Number__c);
                        }
                        
                    }
                    catch(exception e)
                    {
                        transferSubsInvoiceOwnerList = new List<Zuora__Subscription__c>();
                        system.debug('ERROR:  ' + e);
                    }
                }
                oldBillingAccount.Old_Batch_Number__c = null;
                update oldBillingAccount;
                //END D-3955 12/8/2015 Added by K. Tan                                                               
            }
            //END UD-1805 AddedBy FrancisBenzon 7/10/15 : transfer invoice owner of subs to old CC BA
            
            Map<String,boolean> map1 = updateZuoraBatchNumber(ZuoraId, z.Zuora__Batch__c);
            boolean isSuccess = map1.get('Success');
            system.debug('>>>>>>>111' + isSuccess);
            
            if(isSuccess == true){
                update z;
            }
        }   

    }
        
    public Map<String,boolean>  updateZuoraBatchNumber(String billingAccountId, string batchNumber){
    
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
        rec.setValue('Batch', batchNumber);
            
            try {
                List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};
                List<Zuora.zApi.SaveResult> results;
                    if(!Test.isRunningTest()){
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
            return map2;
        }

}