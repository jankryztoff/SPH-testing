/**
* Class Name: <ChangeOfCreditCardController>
* @Revision Author: <Bustarde, Richard>
* Requirement/Project Name: <SPH>
* @description<Create Case inside Billing Account record and select Change of Credit Card >
* History: 
*        RBustarde: 3/25/2015 D-2563 Created a wrapper - tick boxes for each Subscription record to enable the user to select subscriptions and later transfer to a new billing account
*/
/**
* @Revision Author: <Jason Abolac>
* @description: <Change of logic : additional logic is being implemented>
* History: this is for defect UD-5454
*/

/**
* @Revision Author: <Kathleen Estoya>
* @description: <Change of logic: Callouts should come first prior DML>
* History: this is for defect UD-2945
*/
//START: UD-0871 05/04/2015 KEstoya - With sharing keyword
public with sharing class ChangeOfCreditCardController{ 
//END: UD-0871 05/04/2015 KEstoya

    //START: MD-25 []D-2563, D-2569, D-2583] 03/24/2015 RBustarde - Subscription Details on Change of Credit Card      
    public Zuora__CustomerAccount__c thisBillingAccount {get; set;}
    public Zuora__CustomerAccount__c cloneBillingAccount {get; set;}
    public Contact contactBilling{get; set;}
    public Zuora__Subscription__c dummySubscription {get; set;}
    public List<Zuora__Subscription__c> subscriptions {get; set;}   

    public List<Zuora__Subscription__c> SelectedSubscriptions {get; set;}   
    //START UD-1814 08-07-2015 Marvin Gatchalian
    public List<Zuora__Subscription__c> UnSelectedSubscriptions = new  List<Zuora__Subscription__c>(); 
    //END UD-1814 08-07-2015 Marvin Gatchalian

    public Case thisCase {get; set;}
    public List<WrapSubscription> WrapSubList {get; set;}
        
    public Case caseRec {get; set;}
    public String paymentMethodId {get; set;}
    public Boolean showCCDetails {get; set;}
    
    Id accountId;
    Id recordType;
    Id AmendmentId;
    String BillingAcctId;
    String BillingAcctNum;
    String BillingContId;

    ZuoraCallOut zCallout = new ZuoraCallOut();
    
    Id caseId;
    Id conId;
    //Start CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
    String CreditCard = GlobalVariableClass.CREDITCARD;
    String ActiveSubscription = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
    
    String Subscription_Type = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    String PARAM_ACCOUNTID = GlobalVariableClass.PARAMETER_ACCTID_STRING;
    String PARAM_RECORDTYPE = GlobalVariableClass.PARAMETER_RECORDTYPE_STRING;
    String PARAM_ID = GlobalVariableClass.PARAMETER_ID_STRING;
    String PARAM_CONTACTID = GlobalVariableClass.PARAMETER_CONTACTID_STRING;
    //End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String

    public void ProcessSelected(){
        SelectedSubscriptions = new List<Zuora__Subscription__c>();
        //START D-3099 16-06-2015 Marvin Gatchalian
        set <id> oliIDs = new set<id>();
        //END  D-3099 16-06-2015 Marvin Gatchalian
        
        for(WrapSubscription wrapobj:WrapSubList){
            //START UD-1814 08-07-2015 Marvin Gatchalian
            if (wrapobj.selected){
                SelectedSubscriptions.add(wrapobj.SubRec);
                //START D-3099 16-06-2015 Marvin Gatchalian
                oliIDs.add(wrapobj.SubRec.Order_Line_Item_Number_1__c);
                //END D-3099 16-06-2015 Marvin Gatchalian
            }
            else if (!wrapobj.selected){
                UnSelectedSubscriptions.add(wrapobj.SubRec);
            }
            //END UD-1814 08-07-2015 Marvin Gatchalian
        }
        
        //START D-3099 16-06-2015 Marvin Gatchalian
        for (Zuora__Subscription__c eachDeliverySub : [SELECT Id, Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c, Name, Zuora__CustomerAccount__c, 
                                                      Zuora__CustomerAccount__r.Payment_Mode__c, Subscription_Type_1__c, Zuora__Zuora_Id__c, Order_Line_Item_Number_1__c
                                                        FROM Zuora__Subscription__c 
                                                        WHERE Zuora__CustomerAccount__r.Payment_Mode__c = :GlobalVariableClass.CREDITCARD 
                                                            AND Subscription_Type_1__c= :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY
                                                            AND Order_Line_Item_Number_1__c in :oliIDs]) {
        
            SelectedSubscriptions.add(eachDeliverySub);
                                                            
        }
        //END  D-3099 16-06-2015 Marvin Gatchalian                                                  
    }
    
    public class WrapSubscription {
        public Zuora__Subscription__c SubRec {get; set;}
        public Boolean selected {get; set;}
                
        public WrapSubscription(Zuora__Subscription__c sub) {
            SubRec = sub;
            selected = false;
        }
    }
    
    public ChangeOfCreditCardController() {
        //Start CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
        accountId = ApexPages.currentPage().getParameters().get(PARAM_ACCOUNTID);
        system.debug('--AcctID-->' + AccountId);
        recordType = ApexPages.currentPage().getParameters().get(PARAM_RECORDTYPE); 
        caseId = ApexPages.currentPage().getParameters().get(PARAM_ID);
        conId = ApexPages.currentPage().getParameters().get(PARAM_CONTACTID); 
        //End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
        dummySubscription = new Zuora__Subscription__c();
        
        
        if(caseId != NULL) {//for edit
            
            //START: D-1752 03/16/2015 RBustarde - Billing Account callout to Zuora
            if (caseId != null) { //patrick.c.villarica, Code review, 2/18/15
                caseRec = [SELECT OwnerId, CaseNumber, Origin, Account__c, AccountId, ContactId, Contact_Number__c, Billing_Account_Name__c, Billing_Account_Name__r.Billing_Contact__c, Category__c, Sub_Category__c, Selected_Subscriptions_Only__c, Status, Creation_Mode__c, Priority, Subject, Description From Case where Id =: caseId LIMIT 1];              
                
                system.debug('---->CaseREC: ' + caseRec);

            } else { //patrick.c.villarica, Code review, 2/18/15
                caseRec = new Case();
            }
            thisCase = caseRec; //Start-End 04/10/2015 UD-0545 Jason Abolac
            if(thisCase.Id != null) { //patrick.c.villarica, Code review, 2/18/15
                thisCase.Billing_Account_Name__c = [Select Billing_Account_Name__c From Case where Id =: thisCase.Id LIMIT 1].Billing_Account_Name__c;
            } 
            system.debug('----> CaseRec Billing Contact : ' + caseRec.Billing_Account_Name__r.Billing_Contact__c);            
            //END: D-1752 03/16/2015 RBustarde - Billing Account callout to Zuora
            
        } else {//new case
            
            thisCase = new Case(); 
            thisCase.AccountID = accountId;
            thisCase.RecordtypeId = recordType;
            thisCase.ContactId = conId;
        }
        fetchBillingAccount();
    } 
    
    public pagereference fetchBillingAccount() {
        if(thisCase.Billing_Account_Name__c != null) {          
            try
             {
                //Start CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
                //START: D-1374 / 12-23-2014 added by S.Puli - corrected SOQL Zuora__CustomerAccount__r.Payment_Mode__c = 'CreditCard'              
                //START: D-1752 03/16/2015 RBustarde - Billing Account callout to Zuora
                 
                WrapSubList =new List<WrapSubscription>();
                
                if(thisCase.Billing_Account_Name__c != null && CreditCard != null) { //patrick.c.villarica, Code review, 2/18/15
                    //START - END D-3099 16-06-2015 Marvin Gatchalian : Added Order_Line_Item_Number_1__c on the Q
                    subscriptions = [SELECT Id, Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c, Name, Zuora__CustomerAccount__c, 
                                        Zuora__CustomerAccount__r.Payment_Mode__c, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c 
                                            WHERE Zuora__CustomerAccount__c = :thisCase.Billing_Account_Name__c 
                                                AND Zuora__CustomerAccount__r.Payment_Mode__c = :CreditCard AND Subscription_Type_1__c= :Subscription_Type];            
                                                
                    //START - END D-3099 16-06-2015 Marvin Gatchalian : Added Order_Line_Item_Number_1__c on the Q
                    for(Zuora__Subscription__c s:[SELECT Id, Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c, Name, Zuora__CustomerAccount__c, 
                                                    Zuora__CustomerAccount__r.Payment_Mode__c, Subscription_Type_1__c, Zuora__Zuora_Id__c, Order_Line_Item_Number_1__c
                                                        FROM Zuora__Subscription__c 
                                                            WHERE Zuora__CustomerAccount__c = :thisCase.Billing_Account_Name__c 
                                                                AND Zuora__CustomerAccount__r.Payment_Mode__c = :CreditCard AND Subscription_Type_1__c= :Subscription_Type
                                                                AND Zuora__Status__c =:ActiveSubscription]){                                                                
                        WrapSubList.add(new WrapSubscription(s));
                                                        
                    }       
                    
                                                    
                } 
                else { //patrick.c.villarica, Code review, 2/18/15
                    subscriptions = new List<Zuora__Subscription__c>();
                }
                //END: D-1374 / 12-23-2014 added by S.Puli
                //End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
                
            }
            catch(QueryException e) {
                subscriptions = new List<Zuora__Subscription__c>();
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('InvalidBillingAccount')));
                thisBillingAccount = new Zuora__CustomerAccount__c();
            }
            try {
                //START: D-1374 / 12-23-2014 added by S.Puli - added Payment_Mode__c
                List<Zuora__CustomerAccount__c> billingAccount = new List<Zuora__CustomerAccount__c>(); //patrick.c.villarica, Code review, 2/18/15
                if (thisCase.Billing_Account_Name__c != null) { //patrick.c.villarica, Code review, 2/18/15
                    billingAccount = [SELECT Id, Zuora__PaymentMethod_Type__c, Zuora__External_Id__c, Name, Payment_Mode__c FROM Zuora__CustomerAccount__c WHERE Id = :thisCase.Billing_Account_Name__c];
                }
                //END: D-1752 03/16/2015 RBustarde - Billing Account callout to Zuora
                //END: D-1374 / 12-23-2014 added by S.Puli
                if(billingAccount.size()> 0) {
                    //START: D-1752 03/06/2015 JTeves - Billing Account callout to Zuora
                    thisBillingAccount = billingAccount[0];
                    //END: D-1752 03/06/2015 JTeves - Billing Account callout to Zuora
                    //Start CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
                    //START: D-1374 / 12-23-2014 added by S.Puli - change Credit Card to CreditCard
                    if(billingAccount[0].Payment_Mode__c == CreditCard) {
                    //END: D-1374 / 12-23-2014 added by S.Puli
                    //End CodeCleanUp AddedBy FrancisBenzon 2/3/15 : Hardcoded String
                        showCCDetails = true;
                    } else {
                        showCCDetails = false;
                    }
                }              
            }
            catch(QueryException e) {
                subscriptions = new List<Zuora__Subscription__c>();
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('InvalidBillingAccount')));
                thisBillingAccount = new Zuora__CustomerAccount__c();
            }
        }
        return null;
    }
    
    public String getSource() {
        return ConstantsSLB.getZuoraUrl('Default');
    }
    
    
    
    public pageReference saveRecord(){
        boolean error = false; //Start - End: UD-0545 Jason Abolac
        
        
        
        //START UD-1389 6/16/2015 GdelRosario : Added validation rule for Saving Payment Method ID
                if(thisCase.Payment_Method_ID__c == null || thisCase.Payment_Method_ID__c == ''){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('NoPaymentMethodID'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }             
        //END UD-1389 6/16/2015 GdelRosario : Added validation rule for Saving Payment Method ID


        try {                       
            Map<String,String> paymentMethodResultMap = new Map<String,String>();
            Map<String,String> billingAccResultMap = new Map<String,String>();
            //Map<String,String> AmendmentResultMap = new Map<String,String>();
            Map<String,Object> billingAccMap = new Map<String,Object>();
            Map<String,String> paymentMethodMap = new Map<String,String>(); 
            ProcessSelected(); // fill up the SelectedSubscriptions list
        
        if (thisCase.Payment_Method_ID__c != '' && thisCase.Payment_Method_ID__c != null){      //Start - End: UD-0545 Jason Abolac   
        //if (paymentMethodId != '' && paymentMethodId != null){    
                
                //START UD-1814 08-07-2015 Marvin Gatchalian - added contidion for not creating new billing account if single or all subscriptions are selected.
                if (SelectedSubscriptions.isEmpty() || (!SelectedSubscriptions.isEmpty() && UnSelectedSubscriptions.isEmpty())){       //Start - End: UD-0545 Jason Abolac
                //END UD-1814 08-07-2015 Marvin Gatchalian - added contidion for not creating new billing account if single or all subscriptions are selected.
                    //START: D-2945 5/26/2015 KEstoya 
                    //START: UD-0871 04/30/2015 KEstoya - Case editing only for record Owners
                   
                    //START: D-1752 03/06/2015 JTeves - Billing Account callout to Zuora

                    paymentMethodMap.put('AccountId', thisBillingAccount.Zuora__External_Id__c);
                    paymentMethodMap.put('Id', thisCase.Payment_Method_ID__c);
                    
                    billingAccMap.put('Id', thisBillingAccount.Zuora__External_Id__c);
                    billingAccMap.put('DefaultPaymentMethodId', thisCase.Payment_Method_ID__c);
                    
                    billingAccResultMap = zCallout.updateZObject(billingAccMap, 'Account', thisBillingAccount.Zuora__External_Id__c);
                    //END: UD-0871 04/30/2015 KEstoya - Case editing only for record Owners
                    //END: D-1752 03/06/2015 JTeves - Billing Account callout to Zuora
                    
                    thisCase.ContactId = caseRec.ContactId;
                    thisCase.Contact_Number__c = caseRec.Contact_Number__c;         
                    thisCase.AccountId  = caseRec.AccountId;
                    //START D-0756 01/12/2015 by JLedesma Update the billing account field.
                    thisCase.Billing_Account_Name__c = thisCase.Billing_Account_Name__c;
                    //END D-0756 01/12/2015 by JLedesma 
                    thisCase.Category__c =  caseRec.Category__c;
                    thisCase.Sub_Category__c = caseRec.Sub_Category__c;
                    thisCase.Selected_Subscriptions_Only__c = caseRec.Selected_Subscriptions_Only__c;   
                    thisCase.Status = caseRec.Status;
                    thisCase.Creation_Mode__c = caseRec.Creation_Mode__c;
                    thisCase.Priority = caseRec.Priority;
                    thisCase.Subject = caseRec.Subject;
                    thisCase.Description = caseRec.Description;
                    
                    upsert thisCase;
                    system.debug('thisCase.Payment_Method_ID__c' + thisCase.Payment_Method_ID__c);
                    system.debug('succesful insert ' + thisCase);
                    //END: D-2945 5/26/2015 KEstoya                   
                    
                                                   
                }
                else {          
                     // 03-26-15 RBustarde - Create New Billing Account--

                    //START: D-2945 5/26/2015 KEstoya 
                    cloneBillingAccount = [SELECT Id, Zuora__PaymentMethod_Type__c, Zuora__External_Id__c, Name, Payment_Mode__c,
                                                            Zuora__Currency__c, Zuora__BillCycleDay__c, Zuora__PaymentTerm__c, 
                                                            Zuora__SoldToId__c, Zuora__BillToId__c, Zuora__Account__c, Zuora__Batch__c,
                                                            Billing_Type__c
                                                            FROM Zuora__CustomerAccount__c WHERE Id = :thisCase.Billing_Account_Name__c];
                                                            
                    system.debug(' cloneBillingAccount --->' + cloneBillingAccount);
                                                                                
                    billingAccMap.put('BillCycleDay',cloneBillingAccount.Zuora__BillCycleDay__c);
                    billingAccMap.put('Currency',cloneBillingAccount.Zuora__Currency__c );
                    billingAccMap.put('Name',cloneBillingAccount.Name );
                    billingAccMap.put('PaymentTerm',cloneBillingAccount.Zuora__PaymentTerm__c );                                
                    billingAccMap.put('Status','Draft');
                    billingAccMap.put('Batch',cloneBillingAccount.Zuora__Batch__c);
                    billingAccMap.put('CrmId',cloneBillingAccount.Zuora__Account__c );
                    billingAccMap.put('DefaultPaymentMethodId', thisCase.Payment_Method_ID__c);
                    billingAccMap.put('Billing_Type__c', cloneBillingAccount.Billing_Type__c);
                                        

                    billingAccResultMap = zCallout.createZObject (billingAccMap, 'Account');
                    try {
                        
                            if (billingAccResultMap.get('Status') == 'Success') {
                                system.debug('===>>>>success create billing Acct'); 
                                 BillingAcctId = (String) billingAccResultMap.get('Id');
                                 system.debug('====BillingId====>>>' + BillingAcctId);
                            }
                            else {
                                system.debug('>>>>>>>>>>>>>>>>>rMap1' + ' ' + billingAccResultMap.get('Status'));
                                system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + billingAccResultMap.get('Code'));
                                system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + billingAccResultMap.get('Message'));

                                system.debug('=====>>>>fail Create Billing acct');
                            }
                            createContactBilling();//create contact to zuora
                            activateAccount();
                            createAmendments(); 
                    
                    //START UD-0871 KEstoya - moved these code to cover in the DMLException
                    thisCase.ContactId = caseRec.ContactId;
                    thisCase.Contact_Number__c = caseRec.Contact_Number__c;         
                    thisCase.AccountId  = caseRec.AccountId;                
                    thisCase.Billing_Account_Name__c = thisCase.Billing_Account_Name__c;                
                    thisCase.Category__c =  caseRec.Category__c;
                    thisCase.Sub_Category__c = caseRec.Sub_Category__c;
                    thisCase.Selected_Subscriptions_Only__c = caseRec.Selected_Subscriptions_Only__c;   
                    thisCase.Status = caseRec.Status;
                    thisCase.Creation_Mode__c = caseRec.Creation_Mode__c;
                    thisCase.Priority = caseRec.Priority;
                    thisCase.Subject = caseRec.Subject;
                    thisCase.Description = caseRec.Description;
                    upsert thisCase;
                    //END UD-0871 KEstoya - moved these code to cover in the DMLException

                    }
                    catch(Exception e) {
                        system.debug('===Exception Error==>>>>' + e);
                        
                        
                    }//END: D-2945 5/26/2015 KEstoya 
                
                }
            //Start: UD-0545 Jason Abolac                        
            }
            else{
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('Error Encountered')));           
            error = true;
            }
            //End: UD-0545 Jason Abolac
        }
        catch(DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('ErrorTryingToSaveCaseError') +  e.getMessage()));
            return null; //Start-End 04/30/2015 UD-0871 KEstoya - reactivated this line from JAbolac UD-0545
            
        }
        String returnId;
        
        if(thisCase.Id != NULL) {
            returnId = thisCase.Id;
            system.debug('returnId' + returnId);  
        }
        //Start-End 04/10/2015 UD-0545 Jason Abolac
        else{
            return null;
        }
        if(!error){
            return new PageReference('/' + returnId);
        }
        else{
            return null;
        }
        //End: UD-0545 Jason Abolac
    }
    
    public void activateAccount(){
        
        String StatusBillingAcct;
        
        Map<String,String> NewBillingAccResultMap = new Map<String,String>();
        Map<String,Object> newbillingAccMap = new Map<String,Object>();
        
        newbillingAccMap.put('Id', BillingAcctId);
        system.debug('====BillingAcctId==>>' +BillingAcctId);
        newbillingAccMap.put('Status', 'Active');
        newbillingAccMap.put('BillToId',BillingContId);
        newbillingAccMap.put('SoldToId',BillingContId);
        newbillingAccMap.put('CrmId',cloneBillingAccount.Zuora__Account__c);
        newbillingAccMap.put('Batch',cloneBillingAccount.Zuora__Batch__c);
        
        
        NewBillingAccResultMap = zCallout.updateZObject(newbillingAccMap, 'Account', BillingAcctId);
        
        if (NewBillingAccResultMap.get('Status') == 'Success') {
            system.debug('===>>>>success updating status Acct');    
            StatusBillingAcct= NewBillingAccResultMap.get('Status');
            system.debug('====status====>>>' + StatusBillingAcct);
        }
        else {
            system.debug('>>>>>>>>>>>>>>>>>rMap1' + ' ' + NewBillingAccResultMap.get('Status'));
            system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + NewBillingAccResultMap.get('Code'));
            system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + NewBillingAccResultMap.get('Message'));
            system.debug('=====>>>>fail status update acct');
        }
        
    }
        
    
    public void createAmendments()  {
    
            // Create Amendment
            List<Map<String,Object>> AmendmentList = new List<Map<String,Object>>();                            
            Map<String,Object> AmendmentMap;
            String startDate;
            startDate = zuora.zUtil.getZuoraDate(date.today());
            

            system.debug('=====Before Loop SelectedSubscription====>>');
            for(Zuora__Subscription__c sub: SelectedSubscriptions)
            {                       
                system.debug('=====Inside Loop SelectedSubscription====>>');
                AmendmentMap = new Map<String, Object>();
                AmendmentMap.put('Code', null);
                AmendmentMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, startDate);
                AmendmentMap.put(globalvariableclass.DESCRIPTION, 'Subscription Owner Transfer');
                AmendmentMap.put(globalvariableclass.EFFECTIVE_DATE, startDate);
                AmendmentMap.put(globalvariableclass.NAME, 'Subscription Owner Transfer');
                AmendmentMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
                AmendmentMap.put(globalvariableclass.SUBSCRIPTION_ID, sub.Zuora__Zuora_Id__c);
                AmendmentMap.put(globalvariableclass.TYPE, 'OwnerTransfer');
                AmendmentMap.put('DestinationAccountId', BillingAcctId);
                //START: D-3149 K. Tan 6/25/2015 - to transfer Subscription-Invoice records to new Billing Account
                AmendmentMap.put('DestinationInvoiceOwnerId', BillingAcctId);
                //END: D-3149 K. Tan 6/25/2015 - to transfer Subscription-Invoice records to new Billing Account
                AmendmentList.add(AmendmentMap);
                system.debug('=====Amendment====>>' + AmendmentList);
                
            }
            
            List<Map<String,String>> AmendmentResultMap = zCallout.amendZObjects(AmendmentList);
                                                        
            
            try {                           
            
                for(Map<String, String> rMap: AmendmentResultMap) {
                    if (rMap.get('Status') == 'Success') {
                        system.debug('===>>>>success amend');
                    
                    }
                    else {
                        system.debug('>>>>>>>>>>>>>>>>>rMap1' + ' ' + rMap.get('Status'));
                        system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + rMap.get('Code'));
                        system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + rMap.get('Message'));
                        system.debug('===>>>>fail amend');                                      
                    }
                }
            

            }
            catch(Exception e){
                system.debug('===Amendment Error==>>>>' +e);
            }   

    }
    
    public void createContactBilling(){
        
        Map<String,String> billingContactResultMap = new Map<String,String>();
        Map<String,Object> billingContactMap = new Map<String,Object>();
        system.debug('====]Billing Account Name:' + caseRec.Billing_Account_Name__r.Billing_Contact__c);
        //START-END UD-1361 6/2/2015 Kestoya - added fields for address
        contactBilling = [SELECT Id, Name, AccountId, MailingCountry, FirstName, LastName, Email, Mailing_Address__c, City_Code__c, Address__r.Postal_Code__r.Name, Address__r.City__r.City_Name__c
                            FROM Contact WHERE Id =:caseRec.Billing_Account_Name__r.Billing_Contact__c];
        
        system.debug('====]>>>> contactBilling SOQL :' + contactBilling);
        String stop = 'yes';
        
                billingContactMap.put('AccountId',BillingAcctId);
                billingContactMap.put('Country',contactBilling.MailingCountry );
                billingContactMap.put('FirstName',contactBilling.FirstName );
                billingContactMap.put('LastName',contactBilling.LastName);                              
                billingContactMap.put('WorkEmail',contactBilling.Email);
                //START UD-1361 6/2/2015 Kestoya
                billingContactMap.put('City', contactBilling.Address__r.City__r.City_Name__c);
                //billingContactMap.put('Address1', contactBilling.Mailing_Address__c);
                billingContactMap.put('PostalCode', contactBilling.Address__r.Postal_Code__r.Name);
                //END UD-1361 6/2/2015 Kestoya
        
                
        billingContactResultMap = zCallout.createZObject (billingContactMap, 'Contact');
        
                try {
                    
                        if (billingContactResultMap.get('Status') == 'Success') {
                            system.debug('===>>>>success create billing Contact');  
                             BillingContId = (String) billingContactResultMap.get('Id');
                             //BillingAcctNum = (String)billingAccMap.get('AccountNumber');
                            //SubscriptionId = Id.valueOf(billingAccResultMap.get('Id'));
                             system.debug('====BillingConIdclone====>>>' + BillingContId);
                             
                                                }
                        else {
                            system.debug('>>>>>>>>>>>>>>>>>rMap1' + ' ' + billingContactResultMap.get('Status'));
                            system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + billingContactResultMap.get('Code'));
                            system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + billingContactResultMap.get('Message'));

                            system.debug('=====>>>>fail Create Billing acct');
                        }
                }
                catch(Exception e){
                system.debug('===CreateContactBilling Error==>>>>' +e);
            }   
    }
    
    
    
    //END: MD-25 []D-2563, D-2569, D-2583] 03/24/2015 RBustarde - Subscription Details on Change of Credit Card 
     public PageReference cancel(){
        PageReference pageRef;
        if(thisCase.Id<>null){
            pageRef = new PageReference('/'+thisCase.Id);
        } else{
            pageRef = new PageReference('/500/e');
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //START UD-3351 12/18/2015 Added by J.Sarion - Set Zuora URL for Zuora Hosted Page
    public string paymentGetway { get; set; }
    public string creditCardType { get; set; }
    
    public void retrieveSource() {    
        
        if(creditCardType == 'American Express') {
            paymentGetway = ConstantsSLB.getZuoraUrl('Amex');
        }
        else {
            paymentGetway = ConstantsSLB.getZuoraUrl('Default');
        }
   
    }
   //END UD-3351 12/18/2015 Added by J.Sarion - Set Zuora URL for Zuora Hosted Page

    
}