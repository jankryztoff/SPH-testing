/**
* Class Name: ARMS_TriggerHandler
* @author: Accenture PDC - Sherwin Puli
* Date: 24.Oct.2014
* Requirement/Project Name: SF SPH
* @description: Class that manages Billing Account inserted.
*/

public class ARMS_TriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    //START: D-995 12/05/14 Add by S.Puli - updated components to successfully execute webservice call
    public static boolean isSkipUpdate;
    //END: D-995 12/05/14 Add by S.Puli
    public map<id, boolean> isOtherPaymentMode = new map<id, boolean>();
    public list<Zuora__CustomerAccount__c> armsBillingAccountList = new list<Zuora__CustomerAccount__c>();
    set<id> armsAccountIdSet = new set<id>();
    set<id> otherAccountIdSet = new set<id>();
    
    //START: UD-0802 04/08/2015 Added by S.PULI
    //START: UD-1810 08/07/2015 Added by S.Puli
    List<Zuora__CustomerAccount__c> billAccToSearch_LIST = new List<Zuora__CustomerAccount__c>();
    //REMOVE Set<Id> billAccId_SET = new Set<Id>();
    //END: UD-1810 08/07/2015 Added by S.Pul
    //START UD-1361 Kestoya 6/9/2015
    Map<string, Case> mapPaymentIDandCase = new Map<string, Case>();
    //END UD-1361 Kestoya 6/9/2015
    List<BT_CO_ARMS_CreateCustAccountFile__c> cusToCreateBatchList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
    List<BT_CO_ARMS_CreateCustAccountFile__c> cusToInsertBatchList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
    Set<Id> baCusIdSet = new Set<Id>();
    Set<Id> batchCustSet = new Set<Id>();
    //END: D-995 12/05/14 Removed by S.Puli
    set<id> billingAccountIdSet = new set<id>();    // Start/End D-4463 18Mar16 JohnD
    
    //START: UD-0963 04/24/2015 Added by S.PULI
    List<BT_CO_ARMS_CreateCustAccountFile__c> createFileToDelete = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
    //END: UD-0963 04/24/2015 Added by S.PULI
    //START D-3539 10/27/15 RReyes
    Boolean isValidationExempted = false;
    //END D-3539 10/27/15 RReyes
    
    //START UD-3833 02/23/2016 Added by J.Sarion
    Map<Id, Zuora__CustomerAccount__c> accountIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
    //END UD-3833 02/23/2016 Added by J.Sarion
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !ARMS_TriggerHandler.isBeforeInsertTriggerCalled;
        ARMS_TriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !ARMS_TriggerHandler.isBeforeUpdateTriggerCalled;
        ARMS_TriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !ARMS_TriggerHandler.isBeforeDeleteTriggerCalled;
        ARMS_TriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !ARMS_TriggerHandler.isAfterInsertTriggerCalled;
        ARMS_TriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !ARMS_TriggerHandler.isAfterUpdateTriggerCalled;
        ARMS_TriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !ARMS_TriggerHandler.isAfterDeleteTriggerCalled;
        ARMS_TriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    //START: D-995 12/05/14 Added by S.Puli
    
    public void bulkBefore() {
    
        system.debug('>>>>>>>>triggerbilling<<<<<< ' +trigger.new);
    //START: UD-0802 04/08/2015 Added by S.PULI
    //START: UD-1810 08/07/2015 Added by S.Puli
    
        if(trigger.isUpdate && isSkipUpdate <> true){
            for(SObject ba : trigger.new){
                Zuora__CustomerAccount__c baRec = (Zuora__CustomerAccount__c)ba;
                SObject oldSO = Trigger.oldMap.get(baRec.Id);
                Zuora__CustomerAccount__c oldBA = (Zuora__CustomerAccount__c)oldSO;
                //START: UD-0964/0965 04/22/2015 Added by S.PULI
                if(baRec.Payment_Mode__c == GlobalVariableClass.OTHER && baRec.Other_PaymentMethod__c == GlobalVariableClass.INVOICE && baRec.ARMS_Business_Profile__c <> null && baRec.ARMS_Debt_Management__c <> null && baRec.ARMS_Customer_Number__c == null && baRec.ARMS_Account_Number__c == null){
                    
                    if(oldBA.ARMS_Account_Required__c == false && baRec.ARMS_Account_Required__c == true){
                        //billAccId_SET.add(baRec.Id);
                        billAccToSearch_LIST.add(baRec);
                        
                    }
                }
                //END: UD-0964/0965 04/22/2015 Added by S.PULI
            }//START/END: D-2623 04/14/2015 Added by S.PULI
                

            //REMOVE}
        }
    //END: UD-1810 08/07/2015 Added by S.Puli
    //END: UD-0802 04/08/2015 Added by S.PULI
        
        //START UD-2375 08/28/2015 Added by J.Sarion - Commented out
        /*
        //START UD-1735 7/3/15 Added by Manolo Valena - Invoke method to update Payment Term of the Customer Account in CRM and Zuora.
        if(trigger.isUpdate) {
            Set<Id> customerAccountIdSet = new Set<Id>();
            Map<Id, String> idToDebtManagementMap = new Map<Id, String>();
            for(Zuora__CustomerAccount__c z : (List<Zuora__CustomerAccount__c>)trigger.new) {
                customerAccountIdSet.add(z.Id);
            }
            for(Id z : trigger.oldMap.keySet()){
                if(trigger.oldMap.containsKey(z)) {
                    SObject sObjz = trigger.oldMap.get(z);
                    Zuora__CustomerAccount__c oldSObjz = (Zuora__CustomerAccount__c)sObjz;
                    idToDebtManagementMap.put(z, oldSObjz.ARMS_Debt_Management__c);
                }
            }
            
            //START UD-1735 7/3/15 Added by Manolo Valena - Additional check that invokes the new future method to update Payment Term only when the logic invoking the method is not future as well.
            //START: UD-1528 07/07/2015 Added by S.PULI
            if(!System.IsFuture() && !System.isBatch()) {
                updatePaymentTerm(customerAccountIdSet, idToDebtManagementMap);
            }
            //END: UD-1528 07/07/2015 Added by S.PULI
            //END UD-1735 7/3/15 Added by Manolo Valena
        }
        //END UD-1735 7/3/15 Added by Manolo Valena
        */
        //END UD-2375 08/28/2015 Added by J.Sarion - Commented out
        
        //START UD-1361 Kestoya 06/09/2015
        if(trigger.isInsert || trigger.isupdate){
            Set<Id> setAcctIDs = new Set<Id>();          
            Set<String> setPaymentMethodIDs = new Set<String>();
            Set<String> setExternalIDs = new Set<String>();
            Set<ID> setExistingAcctIDs = new Set<ID>();
    
            for(SObject baRec : trigger.new) {
                Zuora__CustomerAccount__c newBA = (Zuora__CustomerAccount__c)baRec;
                setAcctIDs.add(newBA.Zuora__Account__c);    
                if(newBA.Zuora__Default_Payment_Method__c != null)              
                    setPaymentMethodIDs.add(newBA.Zuora__Default_Payment_Method__c);            
            }
            
            //Retrieve existing Account IDs
            //START UD-3833 2/23/2016 Added by J.Sarion - Check existing Invoice BAs
            for (Zuora__CustomerAccount__c BAs : [SELECT Id, Name, Zuora__Account__c, Billing_Contact__c, Billing_Type__c, Other_PaymentMethod__c, Payment_Mode__c, 
                                                    ARMS_Account_Number__c, ARMS_ID__c, ARMS_Business_Profile__c, ARMS_Debt_Management__c, ARMS_Customer_Number__c
                                                  FROM Zuora__CustomerAccount__c 
                                                  WHERE Zuora__Account__c in : setAcctIDs]){
                setExistingAcctIDs.add(BAs.Zuora__Account__c);
                
                if(!accountIdToBillAccMap.containsKey(BAs.Zuora__Account__c) && BAs.Payment_Mode__c == 'Other' && BAs.Other_PaymentMethod__c == 'Invoice' && BAs.ARMS_Account_Number__c != null && BAs.ARMS_ID__c != null && BAs.ARMS_Business_Profile__c != null && BAs.ARMS_Debt_Management__c != null && BAs.ARMS_Customer_Number__c != null) {
                    accountIdToBillAccMap.put(BAs.Zuora__Account__c, BAs);
                }
                //END UD-3833 2/23/2016 Added by J.Sarion - Check existing Invoice BAs
            }
            
            if(!setExistingAcctIDs.isEmpty())
            {
                for (Zuora__PaymentMethod__c payMthd :[SELECT ID, Zuora__External_Id__c FROM Zuora__PaymentMethod__c where ID in :setPaymentMethodIDs] ) 
                {
                    if(payMthd.Zuora__External_Id__c != NULL)
                        setExternalIDs.add(payMthd.Zuora__External_Id__c);
                }
                
               
                if (!setExternalIDs.isEmpty())  
                { 
                    for (Case cocCase :[SELECT id, Account__c, Payment_Method_ID__c, Billing_Account_Name__c, Billing_Account_Name__r.name, Billing_Account_Name__r.Billing_Contact__c, 
                                Billing_Account_Name__r.Zuora__BillToCity__c, Billing_Account_Name__r.Zuora__BillToAddress1__c, Billing_Account_Name__r.Payment_Mode__c,
                                Billing_Account_Name__r.Zuora__Default_Payment_Method__c, Category__c, Sub_Category__c
                                FROM Case where AccountID in :setExistingAcctIDs AND Category__c = 'Subscription Request' 
                                AND Sub_Category__c = 'Change of Credit Card' AND Payment_Method_ID__c in :setExternalIDs]) 
                    {
                        mapPaymentIDandCase.put(cocCase.Payment_Method_ID__c, cocCase);
                    }
                }
            }
        }
        //END UD-1361 Kestoya 06/09/2015      
        
        //START D-3539 10/27/15 RReyes - get the user info
        if(trigger.isUpdate){
            Id userId = UserInfo.getUserId();
            User currentUser = [SELECT Id, Name, Validation_Exempted__c FROM User where Id=:userId LIMIT 1];
            if(currentUser != null){
                isValidationExempted = currentUser.Validation_Exempted__c;
            }
        }
        //END D-3539 10/27/15 RReyes - get the user info
    } 
        
    public void bulkAfter() {
        //start here
        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
        system.debug('isSkipUpdate-->>> '+ isSkipUpdate);
        if(trigger.isUpdate && isSkipUpdate <> true) {
            List<Zuora__CustomerAccount__c> edtBillAccList = new List<Zuora__CustomerAccount__c>();
            //START: D-1013 12/06/14 Added by S.Puli - add edtCustomerList to Update Customer online to ARMS
            List<Zuora__CustomerAccount__c> edtCustomerList = new List<Zuora__CustomerAccount__c>();
            //END: D-1013 12/06/14 Added by S.Puli
            //if(updBillAccList<>null && updBillAccList.size()>0){
                for(SObject ba : trigger.new){
                    Zuora__CustomerAccount__c baRec = (Zuora__CustomerAccount__c)ba; 
                    SObject oldSO = Trigger.oldMap.get(baRec.Id);
                    Zuora__CustomerAccount__c oldBA = (Zuora__CustomerAccount__c)oldSO;
                    //START: UD-0802 04/08/2015 Added by S.PULI
                    //if(baRec.ARMS_ID__c != oldBA.ARMS_ID__c || baRec.ARMS_Account_Number__c != oldBA.ARMS_Account_Number__c || baRec.ARMS_Account_Type__c != oldBA.ARMS_Account_Type__c || baRec.Credit_Term__c != oldBA.Credit_Term__c || baRec.Credit_Reference__c != oldBA.Credit_Reference__c || baRec.Credit_Limit_Internal__c != oldBA.Credit_Limit_Internal__c || baRec.Credit_Limit_External__c != oldBA.Credit_Limit_External__c || baRec.Approved_Debt_Exposure_Amount__c != oldBA.Approved_Debt_Exposure_Amount__c || baRec.ARMS_Debt_Management__c != oldBA.ARMS_Debt_Management__c || baRec.Business_Sector__c != oldBA.Business_Sector__c || baRec.SOA_Grouping__c != oldBA.SOA_Grouping__c){
                    
                    //START: UD-0964/0965 04/22/2015 Added by S.PULI
                    if(baRec.Payment_Mode__c == GlobalVariableClass.OTHER && baRec.Other_PaymentMethod__c == GlobalVariableClass.INVOICE && baRec.ARMS_Customer_Number__c <> null && baRec.ARMS_Customer_Number__c <> '' && baRec.ARMS_Account_Number__c <> null && baRec.ARMS_Account_Number__c <> ''){
                        
                        if(baRec.ARMS_Account_Type__c != oldBA.ARMS_Account_Type__c || baRec.Credit_Term__c != oldBA.Credit_Term__c || baRec.Credit_Reference__c != oldBA.Credit_Reference__c || baRec.Credit_Limit_Internal__c != oldBA.Credit_Limit_Internal__c || baRec.Credit_Limit_External__c != oldBA.Credit_Limit_External__c || baRec.Approved_Debt_Exposure_Amount__c != oldBA.Approved_Debt_Exposure_Amount__c || baRec.ARMS_Debt_Management__c != oldBA.ARMS_Debt_Management__c || baRec.Business_Sector__c != oldBA.Business_Sector__c || baRec.SOA_Grouping__c != oldBA.SOA_Grouping__c){
                        //END: UD-0802 04/08/2015 Added by S.PULI
                          //  system.debug('Updating ARMS Details');
                            edtBillAccList.add(baRec);
                        }
                        //START: UD-0802 04/08/2015 Added by S.PULI
                        //START: UD-1528 07/07/2015 Added by S.PULI
                        if(baRec.Zuora__BillToAddress1__c != oldBA.Zuora__BillToAddress1__c || baRec.Zuora__BillToAddress2__c != oldBA.Zuora__BillToAddress2__c || baRec.Zuora__Account__r.Name != oldBA.Zuora__Account__r.Name || baRec.ARMS_Business_Profile__c != oldBA.ARMS_Business_Profile__c ||baRec.Zuora__BillToCity__c != oldBA.Zuora__BillToCity__c || baRec.Zuora__BillToPostalCode__c != oldBA.Zuora__BillToPostalCode__c || baRec.Zuora__BillToName__c != oldBA.Zuora__BillToName__c || baRec.Name != oldBA.Name){
                        //END: UD-1528 07/07/2015 Added by S.PULI
                        //END: UD-0802 04/08/2015 Added by S.PULI
                          //  system.debug('Updating ARMS Customer Details');
                            edtCustomerList.add(baRec);
                        }
                    }
                    //END: UD-0964/0965 04/22/2015 Added by S.PULI
                }
            //}
            ARMS_CreateAndUpdate updCusAcc = new ARMS_CreateAndUpdate();
            updCusAcc.updateAccount(edtBillAccList);
            //START: D-1013 12/06/14 Added by S.Puli - add lines to Update Customer online to ARMS
            updCusAcc.updateCustomer(edtCustomerList);
            //END: D-1013 12/06/14 Added by S.Puli
        }
        //END: D-995 12/05/14 Added by S.Puli
        
        //START UD-1805 AddedBy PULI : bypass CC ARMS
        Set<Id> creditFailBA_SET = new Set<Id>();
        if(trigger.isInsert){
            for(SObject ba : trigger.new){
                Zuora__CustomerAccount__c baRec = (Zuora__CustomerAccount__c)ba;
                if(baRec.ARMS_Business_Profile__c <> null && baRec.ARMS_Debt_Management__c <> null && baRec.Other_PaymentMethod__c == GlobalVariableClass.INVOICE){
                    creditFailBA_SET.add(baRec.Id);
                }
            }
            if(creditFailBA_SET.size()>0){
                createCustomerBatchRecord(creditFailBA_SET);
            }
            
        }
        //END UD-1805 AddedBy PULI : bypass CC ARMS
        
        //START UD-2375 08/28/2015 Added by J.Sarion - Update ARMS account
        if(trigger.isUpdate) {
            //START UD-3815 1/25/2016 Added by J.Sarion - Added Acount Id Set
            Set<Id> accountIdForARMSSet = new Set<Id>();
            //END UD-3815 1/25/2016 Added by J.Sarion - Added Acount Id Set
            Set<Id> customerAccountIdSet = new Set<Id>();
            Map<String, String> idToDebtManagementMap = new Map<String, String>();
            //START UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
            Map<String, String> idToBusinessProfMap = new Map<String, String>();
            //END UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
            for(Zuora__CustomerAccount__c z : (List<Zuora__CustomerAccount__c>)trigger.new) {
                customerAccountIdSet.add(z.Id);
            }
            for(Id z : trigger.oldMap.keySet()){
                if(trigger.oldMap.containsKey(z)) {
                    SObject sObjz = trigger.oldMap.get(z);
                    Zuora__CustomerAccount__c oldSObjz = (Zuora__CustomerAccount__c)sObjz;
                    
                    SObject sObjzNew = trigger.newMap.get(z);
                    Zuora__CustomerAccount__c newSObjz = (Zuora__CustomerAccount__c)sObjzNew;
                    if(oldSObjz.ARMS_ID__c != null && oldSObjz.ARMS_Debt_Management__c != newSObjz.ARMS_Debt_Management__c){
                        customerAccountIdSet.add(z);
                        idToDebtManagementMap.put(oldSObjz.ARMS_ID__c, newSObjz.ARMS_Debt_Management__c);
                        //START UD-3815 1/25/2016 Added by J.Sarion - Added Acount Id Set
                        accountIdForARMSSet.add(oldSObjz.Zuora__Account__c);
                        //END UD-3815 1/25/2016 Added by J.Sarion - Added Acount Id Set
                    }
                    
                    //START UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
                    if(oldSObjz.ARMS_ID__c != null && oldSObjz.ARMS_Business_Profile__c != newSObjz.ARMS_Business_Profile__c){
                        customerAccountIdSet.add(z);
                        idToBusinessProfMap.put(oldSObjz.ARMS_ID__c, newSObjz.ARMS_Business_Profile__c);
                        //START UD-3815 1/25/2016 Added by J.Sarion - Added Acount Id Set
                        accountIdForARMSSet.add(oldSObjz.Zuora__Account__c);
                        //END UD-3815 1/25/2016 Added by J.Sarion - Added Acount Id Set
                    }
                    //END UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
                }
            }
            if(!System.IsFuture() && !System.isBatch()) {
                //START UD-3815 1/25/2016 Added by J.Sarion - Added Acount Id Set
                updatePaymentTerm(idToBusinessProfMap, idToDebtManagementMap, accountIdForARMSSet); //START-END UD-2375 09/01/2015 Added by J.Sarion - update parameter
                //END UD-3815 1/25/2016 Added by J.Sarion - Added Acount Id Set
            }
        }
        //END UD-2375 08/28/2015 Added by J.Sarion - Update ARMS account
    }
    
    public void beforeInsert(SObject so) {
        System.debug('gio >> : beforeInsert ');
    //Start: D-2906 James 05/12/2015 - store value of Billing Contact to new field
        if(trigger.isInsert){
            Zuora__CustomerAccount__c newBa = (Zuora__CustomerAccount__c)so;
            //START UD-3833 02/23/2016 Added bu J.Sarion - Populate ARMS detail
            //START: UD-1544 K. Tan 10/14/2015
            if(newBa.Other_PaymentMethod__c != null){          
                if(newBa.Other_PaymentMethod__c == 'Invoice'){
                    if(accountIdToBillAccMap.containsKey(newBA.Zuora__Account__c)) {
                        newBa.Payment_Mode__c = 'Other';
                        newBa.ARMS_Business_Profile__c = accountIdToBillAccMap.get(newBA.Zuora__Account__c).ARMS_Business_Profile__c;
                        newBa.ARMS_Debt_Management__c = accountIdToBillAccMap.get(newBA.Zuora__Account__c).ARMS_Debt_Management__c;
                        newBa.ARMS_Account_Number__c = accountIdToBillAccMap.get(newBA.Zuora__Account__c).ARMS_Account_Number__c;
                        newBa.ARMS_ID__c = accountIdToBillAccMap.get(newBA.Zuora__Account__c).ARMS_ID__c;
                        newBa.ARMS_Customer_Number__c = accountIdToBillAccMap.get(newBA.Zuora__Account__c).ARMS_Customer_Number__c;
                    }
                    else {
                        newBa.Payment_Mode__c = 'Other';
                        newBa.ARMS_Business_Profile__c = 'NORM';
                        newBa.ARMS_Debt_Management__c = 'SUBH';
                    }
                }
            }  
            //START: UD-1544 K. Tan 10/14/2015              
            //END UD-3833 02/23/2016 Added bu J.Sarion - Populate ARMS detail
            if(newBa.Billing_Contact__c <> null){
                newBa.ExistingBillingContact__c = newBa.Billing_Contact__c;
            }
            
            else {
                 
            }
            
            //START UD-1361 Kestoya 06/09/2015
                copyPreviousBA (newBa);            
            //END UD-1361 Kestoya 06/09/2015
            // Start D-3852 John D. K. Tan 11/3/2015
            System.debug('gio >> : ' + newBa.Billing_Contact__c +'  ::  '+ newBa.Link_Prev_Billing_Contact__c);
            if (newBa.Billing_Contact__c == null) {
                newBa.Billing_Contact__c = newBa.Link_Prev_Billing_Contact__c;
            }
            newBa.Link_Prev_Billing_Contact__c = null;
            
            // End D-3852 John D. K. Tan 11/3/2015
        }
    //End: D-2906 James 05/12/2015
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
    //Start: D-2906 James 05/12/2015 - update Billing Contact if null
        if(trigger.isUpdate){
            Zuora__CustomerAccount__c newBa = (Zuora__CustomerAccount__c)so;
            Zuora__CustomerAccount__c oldBA = (Zuora__CustomerAccount__c)oldSo;
            System.debug('gio >> : ' + newBa.Billing_Contact__c +'  ::  '+ newBa.Link_Prev_Billing_Contact__c);
            System.debug('gio >> : ' + oldBA.Billing_Contact__c +'  ::  '+ oldBA.Link_Prev_Billing_Contact__c);
            if(newBa.Billing_Contact__c <> null){
                newBa.ExistingBillingContact__c = newBa.Billing_Contact__c;
            }
            
            if(newBa.Billing_Contact__c == null && oldBA.Billing_Contact__c <> null && oldBA.ExistingBillingContact__c <> null){
                newBa.Billing_Contact__c = oldBA.ExistingBillingContact__c;
            }
            
            //START UD-1361 Kestoya 06/09/2015
            copyPreviousBA (newBa);
            //END UD-1361 Kestoya 06/09/2015
            
            // Start D-3852 John D. K. Tan 11/3/2015
            //START D-3923 11/20/15 RReyes - added more conditions to prevent billing contact deletion
            if (newBa.Billing_Contact__c == null && newBa.Link_Prev_Billing_Contact__c != null){
                newBa.Billing_Contact__c = newBa.Link_Prev_Billing_Contact__c;
                newBa.Link_Prev_Billing_Contact__c = null;
            }else if(newBa.Billing_Contact__c == null && oldBa.Billing_Contact__c != null){
                newBa.Billing_Contact__c = oldBa.Billing_Contact__c;
            }
            //END D-3923 11/20/15 RReyes - added more conditions to prevent billing contact deletion
            // End D-3852 John D. K. Tan 11/3/2015
            
            //START D-3279 RReyes 07/27/15
            if(newBa.Zuora__Default_Payment_Method__c == null && oldBa.Zuora__Default_Payment_Method__c != null){
                //START D-3298/ D-3299 K.Tan 07/30/15               
                if(newBa.Zuora__DefaultPaymentMethod__c == 'CreditCard' || newBa.Payment_Mode__c == 'CreditCard' ) //START & END UD-2730 15/8/15 Gdelrosario : added "or" for uncatch scenario 
                //END D-3279 / D-3299 K.Tan 07/30/15
                newBa.Zuora__Default_Payment_Method__c = oldBa.Zuora__Default_Payment_Method__c;
            }
            //END D-3279 07/27/15 RReyes
            //START D-3539 10/27/15 RReyes - prevents deletion of ARMS_Business_Profile__c and ARMS_Debt_Management__c
            if(isValidationExempted){
                if(newBa.Payment_Mode__c == GlobalVariableClass.OTHER && newBa.Other_PaymentMethod__c == GlobalVariableClass.INVOICE){
                    if(newBA.ARMS_Business_Profile__c == null || newBA.ARMS_Business_Profile__c == ''){
                        newBA.ARMS_Business_Profile__c = oldBA.ARMS_Business_Profile__c;
                    }
                    if(newBA.ARMS_Debt_Management__c == null || newBA.ARMS_Debt_Management__c == ''){
                        newBA.ARMS_Debt_Management__c = oldBA.ARMS_Debt_Management__c;
                    }
                }
            }
            //END D-3539 10/27/15 RReyes - prevents deletion of ARMS_Business_Profile__c and ARMS_Debt_Management__c 
            
            //START 13 April 2016 D-4634 Kevin Evasco - Set Other Payment Method to null if Other Payment Method is Invoice but Payment Mode is not Other
            if(newBa.Other_PaymentMethod__c == GlobalVariableClass.INVOICE && newBa.Payment_Mode__c != GlobalVariableClass.OTHER) {
                newBA.Other_PaymentMethod__c = null;
                newBA.Other_Payment_Method__c = null;
            }
            //END 13 April 2016 D-4634 Kevin Evasco - Set Other Payment Method to null if Other Payment Method is Invoice but Payment Mode is not Other
       }
    //End: D-2906 James 05/12/2015
    }
   //START UD-1361 Kestoya 06/09/2015
    public void copyPreviousBA (Zuora__CustomerAccount__c newBa) {

        case prevBA = new case();
        
       
        if (mapPaymentIDandCase.containsKey(newBa.Payment_External_ID__c)) {
            prevBA = mapPaymentIDandCase.get(newBa.Payment_External_ID__c);
            if (prevBA != null) {
                newBA.Billing_Contact__c = prevBA.Billing_Account_Name__r.Billing_Contact__c;
                newBA.Zuora__BillToCity__c = prevBA.Billing_Account_Name__r.Zuora__BillToCity__c;
                newBA.Zuora__BillToAddress1__c = prevBA.Billing_Account_Name__r.Zuora__BillToAddress1__c;
                newBA.Payment_Mode__c = prevBA.Billing_Account_Name__r.Payment_Mode__c;
            }
        }     
    }
    //END UD-1361 Kestoya 06/09/2015
    
    public void beforeDelete(SObject so) {
      
    }
    
    public void afterInsert(SObject so) {
        
        // Start D-4463 18Mar16 JohnD - capture newly created ids. this will be used to update the batch number
        Zuora__CustomerAccount__c ca = (Zuora__CustomerAccount__c)so;
        if (ca.Billing_Type__c != null) {
            billingAccountIdSet.add(ca.Id);
        }
        // End D-4463 18Mar16 JohnD - capture newly created ids. this will be used to update the batch number
        
        /*
        Zuora__CustomerAccount__c billingAccount = (Zuora__CustomerAccount__c)so;
        
        if (billingAccount.)    
            if (billingAccount.Other_Payment_Mode__c == 'Invoice') {
                
                armsBillingAccountList.add(billingAccount);
            }
        */
    }


    public void afterUpdate(SObject oldSo, SObject so) {
        
        Zuora__CustomerAccount__c ca = (Zuora__CustomerAccount__c)so;
        
        if (ca.Zuora__DefaultPaymentMethod__c == 'Other') {
            
            if (ca.Other_PaymentMethod__c == 'Invoice' && ca.ARMS_ID__c == null 
                    && ca.ARMS_Account_Number__c == null) {
                        
                armsAccountIdSet.add(ca.Id);
                
            } else {
                
                otherAccountIdSet.add(ca.Id);
            }
        }
    }


    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        
        //START: UD-1810 15-July-2015 Added by S.Puli
        if(billAccToSearch_LIST.size() == 1){
            //START UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
            //Set<Id> billAccToSearch_SET = new Set<Id>();
            relinkCustomerBatchRecord(billAccToSearch_LIST[0]);
            //START: UD-1810 15-July-2015 Added by S.Puli
            //searchCustomerBatchRecord(billAccToSearch_SET);
            //createCustomerBatchRecord(billAccToSearch_SET);
            //END: UD-1810 15-July-2015 Added by S.Puli
            //END UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
        }
        //END: UD-1810 15-July-2015 Added by S.Puli
        if (armsAccountIdSet.size() > 0) {
            // create
        }
        
        //START: UD-0963 04/24/2015 Added by S.PULI
        if(createFileToDelete.size()>0){
            Database.delete(createFileToDelete, false);
        }
        //END: UD-0963 04/24/2015 Added by S.PULI
        
        //START: UD-0802 04/08/2015 Added by S.PULI
        //START: UD-1810 08/07/2015 Added by S.Puli
        //START UD-1805 AddedBy PULI : bypass CC ARMS
        
        if(cusToCreateBatchList<>null && cusToCreateBatchList.size()>0){
            
            insert cusToInsertBatchList;
        
            for(BT_CO_ARMS_CreateCustAccountFile__c accBatch : cusToCreateBatchList){
                batchCustSet.add(accBatch.Id);
            }
        }
        
        if(batchCustSet.size()>0 && baCusIdSet.size()>0){
            ARMS_CreateAndUpdate.createCustomerWebservice(batchCustSet, baCusIdSet);
        }
        //cusToCreateBatchList
        
        //END AddedBy PULI : bypass CC ARMS
        
        
    //END: UD-0802 04/08/2015 Added by S.PULI
        // Start D-4463 18Mar16 JohnD
        if (!billingAccountIdSet.isEmpty()) {
            System.enqueueJob(new BillingBatchAllocationQueueable(billingAccountIdSet));
        }
        // End D-4463 18Mar16 JohnD
    }
    
    //START: UD-0802 04/08/2015 Added by S.PULI
    //START: UD-1527 11/06/2015 Added by S.Puli
    //START: UD-1528 07/07/2015 Added by S.Puli
    //START: UD-1810 08/07/2015 Added by S.Puli - REMOVE
    //START UD-1805 AddedBy PULI : byPassCC ARMS
    public void createCustomerBatchRecord(Set<Id> customerSET){
        
        //START: UD-1810 08/07/2015 Added by S.Puli
        List<Zuora__CustomerAccount__c> customerToCreateList = [Select GST_Out_of_Scope__c,Billing_Contact__r.Address__r.Building_Name__c, Billing_Contact__r.Mobile_Number__c,Billing_Contact__r.Mobile_Number_2__c,Billing_Contact__r.Address__r.Country__r.code__c,
            Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c,Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
            Billing_Contact__r.Address__r.Department__r.Department_Name__c,Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c,
            Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, Billing_Contact__r.Address__r.City__r.City_Name__c,
            Billing_Contact__r.Address__r.Airline_Number__c,Billing_Contact__r.Address__r.Flight_Number_1__c,Billing_Contact__r.Address__r.Flight_Number_2__c,
            Billing_Contact__r.Office_Number__c,Zuora__Account__r.Designation__c,Billing_Contact__r.Address__r.recordType.developerName,
            Zuora__Account__r.Attention_To_Care_Of__c,Zuora__Account__r.Attention_Care_Off_ind__c,Billing_Contact__r.Address__r.Address_1__c,
            Billing_Contact__r.Address__r.Address_2__c,Billing_Contact__r.Address__r.Address_3__c,Billing_Contact__r.Address__r.Address_4__c,
            Billing_Contact__r.Address__r.Building_Name_2__c,Billing_Contact__r.Address__r.Street_Name__c,Billing_Contact__r.Address__r.Unit_Number__c,
            Billing_Contact__r.Address__r.Level_Number__c,Billing_Contact__r.Address__r.Block_House_Number__c,Billing_Contact__r.Address__r.Country__c,
            Billing_Contact__r.Address__r.Postal_Code__r.name,SOA_Grouping__c,Billing_Contact__r.NRIC__c,CreatedBy.name,Id,Name, Status__c, 
            Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, ARMS_Business_Profile__c,
            ARMS_Debt_Management__c, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, Zuora__BillToPostalCode__c, Zuora__BillToCity__c, 
            Zuora__BillToCountry__c, Zuora__BillToName__c,Billing_Contact__r.Email,Billing_Contact__r.Office_Extension__c,Billing_Contact__r.HomePhone__c,
            //START UD-1527 6/23/15 Added by Manolo Valena - Added passport field.
            Billing_Contact__r.Passport__c,
            //END UD-1527 6/23/15 Added by Manolo Valena
            Billing_Contact__r.Handphone_Number__c,Billing_Contact__r.Fax__c, Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c, Zuora__Account__r.Attention_To_Care_Of_Indicator__c, Zuora__Account__r.Staff_ID__c, LastModifiedBy.Name From Zuora__CustomerAccount__c Where Id In :customerSET];
        //END: UD-1810 08/07/2015 Added by S.Puli
        //END: UD-1528 07/07/2015 Added by S.Puli
        //START: UD-0963 04/24/2015 Added by S.PULI
        Set<String> cusName_SET = new Set<String>();
        
        //START: UD-1557 11/06/2015 Added by S.Puli
        Set<Id> cusIds_SET = new Set<Id>();
        if(customerToCreateList.size()>0){
            for(Zuora__CustomerAccount__c ba : customerToCreateList){
                cusName_SET.add(ba.Name);
                cusIds_SET.add(ba.Id);
            }
        }
        
        
        List<Zuora__Subscription__c> newCusSubsList = new List<Zuora__Subscription__c>();
        Map<Id, String> billCusAccToOrderAlias_MAP = new Map<Id, String>();

        if(cusIds_SET.size()>0){
            newCusSubsList = [Select Id, Name, Zuora__CustomerAccount__c, Order_Number_1__r.Billing_Account_Creation_Mode__c, Order_Number_1__r.CreatedBy.Alias from Zuora__Subscription__c Where Zuora__CustomerAccount__c IN :cusIds_SET AND Order_Number_1__r.Billing_Account_Creation_Mode__c = :GlobalVariableClass.CREATE_NEW_BILLACC Limit 1];
            if(newCusSubsList.size()>0){
                for(Zuora__Subscription__c zSub : newCusSubsList){
                    if(!billCusAccToOrderAlias_MAP.containsKey(zSub.Zuora__CustomerAccount__c)){
                        billCusAccToOrderAlias_MAP.put(zSub.Zuora__CustomerAccount__c, zSub.Order_Number_1__r.CreatedBy.Alias);
                    }
                }
            }
        }
        
        
        //END: UD-1557 11/06/2015 Added by S.Puli
        
        List<BT_CO_ARMS_CreateCustAccountFile__c> createCusFile_LIST = [Select Id, Customer_Name1__c, Reference_Key__c, CreatedDate From BT_CO_ARMS_CreateCustAccountFile__c Where CreatedDate = Today AND Customer_Name1__c In :cusName_SET];
        
        Map<Id, List<BT_CO_ARMS_CreateCustAccountFile__c>> createMasterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_CreateCustAccountFile__c>>();
        if(customerToCreateList.size()>0 && createCusFile_LIST.size()>0){
            for(Zuora__CustomerAccount__c billRec : customerToCreateList){
                for(BT_CO_ARMS_CreateCustAccountFile__c bFile : createCusFile_LIST){
                    if(billRec.Name == bFile.Customer_Name1__c){
                        if(createMasterToDetail_MAP.containskey(billRec.Id)){
                            createMasterToDetail_MAP.get(billRec.Id).add(bFile);
                        }else{
                            createMasterToDetail_MAP.put(billRec.Id, new List<BT_CO_ARMS_CreateCustAccountFile__c>{bFile});
                        }
                    }
                }
            }
        }

        

        if(customerToCreateList.size()>0){
    //END: UD-0963 04/24/2015 Added by S.PULI
            for(Zuora__CustomerAccount__c customerRec : customerToCreateList){
                //START: UD-1557 11/06/2015 Added by S.Puli
                //START: UD-1810 08/07/2015 Added by S.Puli
                //if(billCusAccToOrderAlias_MAP.containsKey(customerRec.Id)){
                //END: UD-1810 08/07/2015 Added by S.Puli
                //END: UD-1557 11/06/2015 Added by S.Puli
                
                    //START: UD-0963 04/24/2015 Added by S.PULI
                    if(createMasterToDetail_MAP.containskey(customerRec.Id)){
                        if(createMasterToDetail_MAP.get(customerRec.Id).size()>0){
                            for(BT_CO_ARMS_CreateCustAccountFile__c batchFileRecord : createMasterToDetail_MAP.get(customerRec.Id)){
                                createFileToDelete.add(batchFileRecord);
                            }                   
                        }
                    }
                    //END: UD-0963 04/24/2015 Added by S.PULI
                    
                    string referenceKey = customerRec.Zuora__Account__r.AccountNumber;
                    string uniqueKey = customerRec.Zuora__Account__r.AccountNumber;
                    
                    if (customerRec.Zuora__Account__r.AccountNumber != null) {
                        
                        if (customerRec.Zuora__Account__r.AccountNumber.length() > 10) {
                            
                            referenceKey =  customerRec.Zuora__Account__r.AccountNumber.substring(0, 10);
                        }

                        if (customerRec.Zuora__Account__r.AccountNumber.length() > 26) {
                            
                            uniqueKey =     customerRec.Zuora__Account__r.AccountNumber.substring(0, 26);
                        }
                    }
                    //END: D-995 12/05/14 Added by S.Puli
                    
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec1 = new BT_CO_ARMS_CreateCustAccountFile__c(
                        Customer_Name1__c = customerRec.Name,
                        Customer_Status__c = ConstantsSLB.getOther('ARMS_CusSts'),
                        Company_Code__c = ConstantsSLB.getOther('ARMS_CoyCd'),
                        Reference_Key__c = referenceKey,
                        Unique_Key__c = uniqueKey,
                        Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
                        Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt'),
                        Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt'),
                        //START: UD-1557 11/06/2015 Added by S.Puli
                        //START: UD-1810 08/07/2015 Added by S.Puli
                        //Create_Id__c = customerRec.LastModifiedBy.Name.substring(0,15),
                        //END: UD-1810 08/07/2015 Added by S.Puli
                        //END: UD-1557 11/06/2015 Added by S.Puli
                        Sub_Contact_Name__c = customerRec.Zuora__BillToName__c,
                        //START UD-2418 02-Sept-2015 Added By S.Puli
                        Sub_Contact_Designation__c = customerRec.Zuora__Account__r.Designation__c,
                        Sub_Contact_Ext__c = customerRec.Billing_Contact__r.Office_Extension__c,
                        //END UD-2418 02-Sept-2015 Added By S.Puli
                        //Sub_Contact_Type__c,
                        Debt_Mgt_Treatment__c = customerRec.ARMS_Debt_Management__c,
                        Business_Profile__c = customerRec.ARMS_Business_Profile__c, 
                        Record_Type__c = 'Master',
                        Status__c = 'New',
                        SPH_Staff_Indicator__c='N',
                    //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Credit_Term_Reference__c = ConstantsSLB.getOther('ARMS_CrTrmRef'),
                        Approved_Debt_Exposure_Amount__c = ConstantsSLB.getOther('ARMS_DbtExp'),
                        SOA_Group__c = customerRec.SOA_Grouping__c,
                        GST_OutOfScope_Indicator__c = (customerRec.GST_Out_of_Scope__c ? 'Y' : 'N')
                        //SOA_Supression_Indicator__c
                    );
                    
                    //START: UD-1810 08/07/2015 Added by S.Puli
                    if(billCusAccToOrderAlias_MAP.containsKey(customerRec.Id)){
                        cusRec1.Create_Id__c = billCusAccToOrderAlias_MAP.get(customerRec.Id);
                    }else{
                        if(customerRec.LastModifiedBy.Name.length()>15){
                            cusRec1.Create_Id__c = customerRec.LastModifiedBy.Name.substring(0,15);
                        }
                        else{
                            cusRec1.Create_Id__c = customerRec.LastModifiedBy.Name;
                        }
                    }
                    //END: UD-1810 08/07/2015 Added by S.Puli
                    
                    if(customerRec.Billing_Contact__r.Address__r.recordType.developerName == 'Local'){
                        cusRec1.Postal_Code__c = customerRec.Billing_Contact__r.Address__r.Postal_Code__r.name;
                        cusRec1.City_Zip__c = '';
                        cusRec1.Country__c = customerRec.Billing_Contact__r.Address__r.Country__r.code__c;
                        cusRec1.Block_House_Number__c = customerRec.Billing_Contact__r.Address__r.Block_House_Number__c;
                        cusRec1.Floor_Number__c = customerRec.Billing_Contact__r.Address__r.Level_Number__c;
                        cusRec1.Unit_No__c = customerRec.Billing_Contact__r.Address__r.Unit_Number__c;
                        cusRec1.Street__c = customerRec.Billing_Contact__r.Address__r.Street_Name__c;
                        cusRec1.Building_Secondary__c = customerRec.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c;
                        cusRec1.PO_Box_No__c = customerRec.Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c;
                    }
                    
                    if(customerRec.Billing_Contact__r.Address__r.recordType.developerName == 'Overseas'){
                        cusRec1.Address1__c = customerRec.Billing_Contact__r.Address__r.Address_1__c;
                        cusRec1.Address2__c = customerRec.Billing_Contact__r.Address__r.Address_2__c;
                        cusRec1.Address3__c = customerRec.Billing_Contact__r.Address__r.Address_3__c;
                        cusRec1.Address4__c = customerRec.Billing_Contact__r.Address__r.Address_4__c;
                        cusRec1.Country__c = customerRec.Billing_Contact__r.Address__r.Country__r.code__c;
                    }
                    
                    if(customerRec.Billing_Contact__r.Address__r.recordType.developerName == 'Internal'){
                        cusRec1.Address1__c = customerRec.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c;
                        cusRec1.Address2__c = customerRec.Billing_Contact__r.Address__r.Department__r.Department_Name__c;
                        cusRec1.Address3__c = customerRec.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c;
                        cusRec1.Address4__c = customerRec.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c;
                        cusRec1.Country__c = customerRec.Billing_Contact__r.Address__r.Country__r.code__c;
                    }
                    
                    if(customerRec.Billing_Contact__r.Address__r.recordType.developerName == 'Airline'){
                        cusRec1.Address1__c = (customerRec.Billing_Contact__r.Address__r.City__r.City_Name__c.length() > 40 ? customerRec.Billing_Contact__r.Address__r.City__r.City_Name__c.subString(0,40) : customerRec.Billing_Contact__r.Address__r.City__r.City_Name__c ) ;
                        cusRec1.Address2__c = customerRec.Billing_Contact__r.Address__r.Airline_Number__c;
                        cusRec1.Address3__c = customerRec.Billing_Contact__r.Address__r.Flight_Number_1__c;
                        cusRec1.Address4__c = customerRec.Billing_Contact__r.Address__r.Flight_Number_2__c;
                        cusRec1.Country__c = customerRec.Billing_Contact__r.Address__r.Country__r.code__c;
                    }
                    
                    cusRec1.Co_Attention_To_Indicator__c = customerRec.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                    cusRec1.co_Attention_To_Party__c = customerRec.Zuora__Account__r.Attention_To_Care_Of__c;
                    
                    /*if(customerRec.Zuora__BillToAddress1__c<>null){
                        if(customerRec.Zuora__BillToAddress1__c.length() > 40){
                            cusRec1.Address1__c = customerRec.Zuora__BillToAddress1__c.substring(0, 40);
                        } else {
                            cusRec1.Address1__c = customerRec.Zuora__BillToAddress1__c;
                        }
                    }
                    if(customerRec.Zuora__BillToAddress2__c<>null){
                        if(customerRec.Zuora__BillToAddress2__c.length() > 40){
                            cusRec1.Address2__c = customerRec.Zuora__BillToAddress2__c.substring(0, 40);
                        } else {
                            cusRec1.Address2__c = customerRec.Zuora__BillToAddress2__c;
                        }
                    }*/
                    
                    if(cusRec1.Business_Profile__c == 'GOVT' && cusRec1.Debt_Mgt_Treatment__c == 'GOVT'){
                        cusRec1.Credit_Term__c = '30';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'SUBH'){
                        cusRec1.Credit_Term__c = '15';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'SUBL'){
                        cusRec1.Credit_Term__c = '10';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'NORM'){
                        cusRec1.Credit_Term__c = '0';
                    }
                    if(customerRec.Billing_Contact__r.NRIC__c != null){
                        cusRec1.ID_Type__c = 'NRIC';
                        cusRec1.ID_No__c = customerRec.Billing_Contact__r.NRIC__c;
                    }
                    //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                    else {
                        if(customerRec.Billing_Contact__r.Passport__c != null) {
                            cusRec1.ID_Type__c = GlobalVariableClass.PASS;
                            cusRec1.ID_No__c = customerRec.Billing_Contact__r.Passport__c;
                        }
                    }
                    //END UD-1527 6/23/15 Added by Manolo Valena
                    //END: D-995 12/05/14 Added by S.Puli
                    
                    //START: UD-1528 07/07/2015 Added by S.Puli
                    if(customerRec.Zuora__Account__r.Staff_ID__c <> null){
                        cusRec1.SPH_Staff_Indicator__c = 'Y';
                    }
                    //END: UD-1528 07/07/2015 Added by S.Puli
                    
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec2 = new BT_CO_ARMS_CreateCustAccountFile__c(
                        Customer_Name1__c = customerRec.Name,
                        Customer_Status__c = ConstantsSLB.getOther('ARMS_CusSts'),
                        Reference_Key__c = referenceKey,
                        Unique_Key__c = uniqueKey,
                        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Business_Profile__c = customerRec.ARMS_Business_Profile__c, 
                        //END: D-995 12/05/14 Added by S.Puli
                        Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
                        Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt'),
                        Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt'),
                        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Debt_Mgt_Treatment__c = customerRec.ARMS_Debt_Management__c,
                        //END: D-995 12/05/14 Added by S.Puli
                        //START: UD-1557 11/06/2015 Added by S.Puli
                        Create_Id__c = billCusAccToOrderAlias_MAP.get(customerRec.Id),
                        //END: UD-1557 11/06/2015 Added by S.Puli
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //Sub_Contact_Name__c = customerRec.Zuora__BillToName__c,
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //Sub_Contact_Designation__c,
                        Sub_Contact_Type__c='O',
                        //Sub_ContactNo_Email__c,
                        //Sub_Contact_Ext__c,
                        Record_Type__c = 'Detail',
                        //START: UD-0964/095 04/22/2015 Added by S.PULI
                        Status__c = 'New',
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //Sub_Contact_Designation__c = customerRec.Zuora__Account__r.Designation__c,
                        Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.Office_Number__c
                        //Sub_Contact_Ext__c = customerRec.Billing_Contact__r.Office_Extension__c //START/END UD-0118 5/20/15 MGaelo Change OfficeExtension into phone
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //END: UD-0964/095 04/22/2015 Added by S.PULI

                    );
                    
                    if(customerRec.Billing_Contact__r.Office_Number__c <>  null){
                        cusRec2.Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.Office_Number__c;
                    }else {
                        cusRec2.Sub_Contact_Type__c = null;
                        cusRec2.Sub_ContactNo_Email__c = '0';
                    }
                    
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec3 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec4 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec5 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec6 = null;

                    if(customerRec.Billing_Contact__r.HomePhone__c != null){
                        cusRec3 = cusRec2.clone();
                        cusRec3.Sub_Contact_Type__c = 'H';
                        cusRec3.Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.HomePhone__c;
                        cusRec3.Sub_Contact_Ext__c = '';
                    }
                    
                    if(customerRec.Billing_Contact__r.Mobile_Number__c != null || customerRec.Billing_Contact__r.Mobile_Number_2__c != null){
                        cusRec4 = cusRec2.clone();
                        cusRec4.Sub_Contact_Type__c='M';
                        cusRec4.Sub_ContactNo_Email__c = (customerRec.Billing_Contact__r.Mobile_Number__c != null ? customerRec.Billing_Contact__r.Mobile_Number__c : customerRec.Billing_Contact__r.Mobile_Number_2__c);
                        cusRec4.Sub_Contact_Ext__c = '';
                    }
                    
                    if(customerRec.Billing_Contact__r.Fax__c != null){
                        cusRec5 = cusRec2.clone();
                        cusRec5.Sub_Contact_Type__c = 'F';
                        cusRec5.Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.Fax__c;
                        cusRec5.Sub_Contact_Ext__c = '';
                    }
                    
                    if(customerRec.Billing_Contact__r.Email != null){
                        cusRec6 = cusRec2.clone();
                        cusRec6.Sub_Contact_Type__c='E';
                        cusRec6.Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.Email;
                        cusRec6.Sub_Contact_Ext__c = '';
                    }
                    
                    cusToCreateBatchList.add(cusRec1);
                    cusToInsertBatchList.add(cusRec1);
                    //START UD-2418 02-Sept-2015 Added By S.Puli
                    if(cusRec2.Sub_Contact_Type__c <> null){
                        cusToInsertBatchList.add(cusRec2);
                    }
                    //END UD-2418 02-Sept-2015 Added By S.Puli
                    if(cusRec3 != null) cusToInsertBatchList.add(cusRec3);
                    if(cusRec4 != null) cusToInsertBatchList.add(cusRec4);
                    if(cusRec5 != null) cusToInsertBatchList.add(cusRec5);
                    if(cusRec6 != null) cusToInsertBatchList.add(cusRec6);
                    baCusIdSet.add(customerRec.Id);
                    

                //START: UD-1557 11/06/2015 Added by S.Puli 
                //START: UD-1810 08/07/2015 Added by S.Puli
                //}
                //END: UD-1810 08/07/2015 Added by S.Puli
                //END: UD-1557 11/06/2015 Added by S.Puli
            }
        }
        //END: UD-1527 11/06/2015 Added by S.Puli
    }
    
    //END UD-1805 AddedBy PULI : byPassCC ARMS
    //END: UD-1810 08/07/2015 Added by S.Puli
    //END: UD-0802 04/08/2015 Added by S.PULI
    
    //START: UD-1810 08/07/2015 Added by S.Puli
    //START: UD-1810 15-July-2015 Added by S.Puli - REMOVE
    /*
    @future(callout = true)
    public static void searchCustomerBatchRecord(Set<Id> billAccToSearch_SET){
        Zuora__CustomerAccount__c billAccToSearch;
        if(billAccToSearch_SET.size() == 1){
            billAccToSearch = [Select Id,Name,ARMS_Customer_Number__c,ARMS_Account_Number__c,ARMS_ID__c,Zuora__Zuora_Id__c,ARMS_Business_Profile__c,ARMS_Debt_Management__c From Zuora__CustomerAccount__c Where Id In :billAccToSearch_SET Limit 1];
        }
        List<Zuora__Subscription__c> newCusSubsList = new List<Zuora__Subscription__c>();
        Map<Id, String> billCusAccToCusName = new Map<Id, String>();
        String customerNumber = '';
        String accountNumber = '';
        
            
        if(billAccToSearch <> null){

            wwwSphComArWsWsdlCam.SearchCustomerRequestType searchCusReq = new wwwSphComArWsWsdlCam.SearchCustomerRequestType();

            searchCusReq.CusSrch = new wwwSphComArWsSchemaCamSearchcusto.CusSrch_element();
            searchCusReq.CusSrch.SysId = ConstantsSLB.getOther('ARMS_SysId');
            searchCusReq.CusSrch.CusM1 = billAccToSearch.Name;
            


            searchCusReq.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
            searchCusReq.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
            searchCusReq.user_x.password =  ConstantsSLB.getOther('ARMS_password');

            wwwSphComArWsWsdlCam.CAMSOAP CusRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();

            wwwSphComArWsWsdlCam.SearchCustomerResponseType cusResp = CusRespCAM.SearchCustomer(searchCusReq);

            if(cusResp<>null){
                if(cusResp.CusSrchResp<>null){
                    if(cusResp.CusSrchResp.RtnSts == '0'){
                        if(cusResp.CusSrchResp.L_Cus.Cus<>null){

                            for(wwwSphComArWsSchemaCamSearchcustoR.CusType a : cusResp.CusSrchResp.L_Cus.Cus){
                                customerNumber = a.CusN;
                            }
                        }
                    }
                }
            }
        }
        
        if(customerNumber <> null && customerNumber <> '' && customerNumber <> ' '){
            wwwSphComArWsWsdlCam.SearchAccountRequestType searchAccReq = new wwwSphComArWsWsdlCam.SearchAccountRequestType();

            searchAccReq.AccSrch = new wwwSphComArWsSchemaCamSearchaccou.AccSrch_element();
            searchAccReq.AccSrch.SysId = ConstantsSLB.getOther('ARMS_SysId');
            searchAccReq.AccSrch.CusN = customerNumber;
            searchAccReq.AccSrch.AccTyp = ConstantsSLB.getOther('ARMS_AccTyp');
            searchAccReq.AccSrch.CoyCd = ConstantsSLB.getOther('ARMS_CoyCd');

            searchAccReq.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
            searchAccReq.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
            searchAccReq.user_x.password =  ConstantsSLB.getOther('ARMS_password');

            wwwSphComArWsWsdlCam.CAMSOAP AccRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();

            wwwSphComArWsWsdlCam.SearchAccountResponseType accResp = AccRespCAM.SearchAccount(searchAccReq);
                        
                        
                        
            if(accResp<>null){
                if(accResp.AccSrchResp<>null){
                    if(accResp.AccSrchResp.RtnSts == '0' && accResp.AccSrchResp.SysId == ConstantsSLB.getOther('ARMS_SysId')){

                        if(accResp.AccSrchResp.L_Acc.Acc<>null){
                            
                            for(wwwSphComArWsSchemaCamSearchaccouR.AccType acR : accResp.AccSrchResp.L_Acc.Acc){
                                accountNumber = acR.AccN;
                            }
                        }
                    }
                }
            }
        }
        
            
        if(customerNumber <> null && customerNumber <> '' && accountNumber <> null && accountNumber <> ''){
        
            List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
            Zuora.zApi zApiInstance = new Zuora.zApi();
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage
            
            Zuora.zObject zObject = new Zuora.zObject('Account');
            zObject.setValue('Id', billAccToSearch.Zuora__Zuora_Id__c);
            zObject.setValue('ARMS_Account_Number__c', accountNumber);
            zObject.setValue('ARMS_Business_Profile__c', billAccToSearch.ARMS_Business_Profile__c);
            zObject.setValue('ARMS_Debt_Management__c', billAccToSearch.ARMS_Debt_Management__c);
            
            zObjectList.add(zObject);
            
            if (zObjectList <> null && zObjectList.size() > 0) {
                List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
            }
        }
        
        billAccToSearch.ARMS_Customer_Number__c = customerNumber;
        billAccToSearch.ARMS_ID__c = customerNumber;
        billAccToSearch.ARMS_Account_Number__c = accountNumber;
        
        Database.update(billAccToSearch, false);
    }
    */
    //END: UD-1810 15-July-2015 Added by S.Puli
    //END: UD-1810 08/07/2015 Added by S.Puli
    
    //START UD-2375 08/28/2015 Added by J.Sarion - Udpate ARMS account
    //START UD-1735 7/3/15 Added by Manolo Valena - Method to update Payment Term of the Customer Account in CRM and Zuora.
    @Future(callout=true)
    public static void updatePaymentTerm(Map<String, String> idToBusinessProfMap, Map<String, String> idToDebtManagementMap, Set<Id> accountIdForARMSSet) { //START-END UD-2375 09/01/2015 Added by J.Sarion - update parameter //START-END UD-3815 1/25/2016 Added by J.Sarion - Added Account Id Set

        ZuoraCallOut zCallOut = new ZuoraCallout();
        Map<String, Object> custRec;
        List<Map<String, Object>> custRecList = new List<Map<String, Object>>();
        List<Exception> exceptionList = new List<Exception>();
        //START UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
        Set<Id> billAccIdSet = new Set<Id>();
        
        //START UD-2653 10-Sept-2015 Added By S.Puli
        Map<Id,Zuora__CustomerAccount__c> billAccToUpdate = new Map<Id,Zuora__CustomerAccount__c>();
        //END UD-2653 10-Sept-2015 Added By S.Puli
        
        //Start D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
        boolean isRecordLock = true;
        //END D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
        
        //START UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
        //START UD-3815 1/25/2016 Added by J.Sarion - Added Account Id Set in query
        for(Zuora__CustomerAccount__c customerAccountRecord : [SELECT Id, ARMS_ID__c, ARMS_Business_Profile__c, ARMS_Debt_Management__c, Zuora__External_Id__c, Other_PaymentMethod__c, Payment_Mode__c,                                                              Zuora__PaymentTerm__c 
                                                               FROM Zuora__CustomerAccount__c 
                                                               WHERE (ARMS_ID__c IN : idToDebtManagementMap.keySet() OR ARMS_ID__c IN : idToBusinessProfMap.keySet()) AND Zuora__Account__c IN :accountIdForARMSSet]) {
            system.debug('CHA customerAccountRecord ' + customerAccountRecord);
            if(customerAccountRecord.Other_PaymentMethod__c == GlobalVariableClass.INVOICE && 
               customerAccountRecord.Payment_Mode__c == GlobalVariableClass.OTHER) {
                
                billAccIdSet.add(customerAccountRecord.Id);
                custRec = new Map<String, Object>();
                if(idToDebtManagementMap.containsKey(customerAccountRecord.ARMS_ID__c)){
                    customerAccountRecord.ARMS_Debt_Management__c = idToDebtManagementMap.get(customerAccountRecord.ARMS_ID__c);
                }
                if(idToBusinessProfMap.containsKey(customerAccountRecord.ARMS_ID__c)){
                    customerAccountRecord.ARMS_Business_Profile__c = idToBusinessProfMap.get(customerAccountRecord.ARMS_ID__c);
                }
               
                //START UD-2653 10-Sept-2015 Added By S.Puli
                billAccToUpdate.put(customerAccountRecord.Id, customerAccountRecord);
                //END UD-2653 10-Sept-2015 Added By S.Puli
                //START UD-2653 10-Sept-2015 Added By S.Puli - Remove callout for ARMS fields in zuora
                if(customerAccountRecord.ARMS_Debt_Management__c == GlobalVariableClass.NORM) {
                    customerAccountRecord.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_NORM;
                    custRec.put(GlobalVariableClass.PARAMETER_ID, customerAccountRecord.Zuora__External_Id__c);
                    custRec.put(GlobalVariableClass.PAYMENT_TERM, customerAccountRecord.Zuora__PaymentTerm__c);
                    //custRec.put(GlobalVariableClass.ARMSBUSINESSPROF, customerAccountRecord.ARMS_Business_Profile__c);
                    //custRec.put(GlobalVariableClass.ARMSDEBTMGT, customerAccountRecord.ARMS_Debt_Management__c);
                }
                else if(customerAccountRecord.ARMS_Debt_Management__c == GlobalVariableClass.SUBH) {
                    customerAccountRecord.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBH;
                    custRec.put(GlobalVariableClass.PARAMETER_ID, customerAccountRecord.Zuora__External_Id__c);
                    custRec.put(GlobalVariableClass.PAYMENT_TERM, customerAccountRecord.Zuora__PaymentTerm__c);
                    //custRec.put(GlobalVariableClass.ARMSBUSINESSPROF, customerAccountRecord.ARMS_Business_Profile__c);
                    //custRec.put(GlobalVariableClass.ARMSDEBTMGT, customerAccountRecord.ARMS_Debt_Management__c);
                }
                else if(customerAccountRecord.ARMS_Debt_Management__c == GlobalVariableClass.SUBL) {
                    customerAccountRecord.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBL;
                    custRec.put(GlobalVariableClass.PARAMETER_ID, customerAccountRecord.Zuora__External_Id__c);
                    custRec.put(GlobalVariableClass.PAYMENT_TERM, customerAccountRecord.Zuora__PaymentTerm__c);
                    //custRec.put(GlobalVariableClass.ARMSBUSINESSPROF, customerAccountRecord.ARMS_Business_Profile__c);
                    //custRec.put(GlobalVariableClass.ARMSDEBTMGT, customerAccountRecord.ARMS_Debt_Management__c);
                }
                else if(customerAccountRecord.ARMS_Debt_Management__c == GlobalVariableClass.GOVT) {
                    customerAccountRecord.Zuora__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_GOVT;
                    custRec.put(GlobalVariableClass.PARAMETER_ID, customerAccountRecord.Zuora__External_Id__c);
                    custRec.put(GlobalVariableClass.PAYMENT_TERM, customerAccountRecord.Zuora__PaymentTerm__c);
                    //custRec.put(GlobalVariableClass.ARMSBUSINESSPROF, customerAccountRecord.ARMS_Business_Profile__c);
                    //custRec.put(GlobalVariableClass.ARMSDEBTMGT, customerAccountRecord.ARMS_Debt_Management__c);
                }
                //END UD-2653 10-Sept-2015 Added By S.Puli
                system.debug('>>>>>custRec ' + custRec);
                custRecList.add(custRec);
            }
        }
        //END UD-3815 1/25/2016 Added by J.Sarion - Added Account Id Set in query
        //END UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
        if(custRecList.size() > 0) {
            List<Map <String, String>> results = zCallOut.updateZObjects(custRecList, GlobalVariableClass.ACCOUNTSTR);
            for(Map<String, String> result : results) {
                if(result.get(GlobalVariableClass.STATUS) == GlobalVariableClass.ZUORA_FAILED) {
                    exceptionList.add(new CustomException(GlobalVariableClass.ACCUPFAILED + ' : ' + result.get(GlobalVariableClass.MESSAGESTR)));
                }
            }
            //Start D-4011 03-Dec-2015 Added by S.Puli - transfer to bottom
            //REMOVE if(!exceptionList.isEmpty()) {
            //REMOVE     ExceptionLogger.log(exceptionList);
            //REMOVE }
            //END D-4011 03-Dec-2015 Added by S.Puli 
        }

        //START PD-0107 17 May 2016 Kevin Evasco - Zuora on demand sync is no longer needed because of real time sync.
        /*
        //START UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
        if(!billAccIdSet.isEmpty()){
            //Perform Zuora Sync
            Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
            syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
            syncManager.syncObjectIdSet  = billAccIdSet;
            List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        }
        //END UD-2375 09/01/2015 Added by J.Sarion - Update ARMS account
        */
        //END PD-0107 17 May 2016 Kevin Evasco - Zuora on demand sync is no longer needed because of real time sync.
        
        //START UD-2653 10-Sept-2015 Added By S.Puli
        ARMS_TriggerHandler.isSkipUpdate = true;
        //Start D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
        while(isRecordLock){
            try{
                update billAccToUpdate.values();
                isRecordLock = false;
            } catch (dmlexception e) {
                isRecordLock = e.getMessage().contains('UNABLE_TO_LOCK_ROW');
                exceptionList.add(e);
            }
        }
        if(!exceptionList.isEmpty()) {
            ExceptionLogger.log(exceptionList);
        }
        //End D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
        //END UD-2653 10-Sept-2015 Added By S.Puli
    }
    //END UD-1735 7/3/15 Added by Manolo Valena
    //END UD-2375 08/28/2015 Added by J.Sarion - Udpate ARMS account
    //START UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
    public void relinkCustomerBatchRecord(Zuora__CustomerAccount__c customerSET){
        
        system.debug('customerSET>>'+customerSET);
        //START: UD-1810 08/07/2015 Added by S.Puli
        List<Zuora__CustomerAccount__c> customerToCreateList = new List<Zuora__CustomerAccount__c>();
        customerToCreateList.add(customerSET);
        //replace Billing_Contact__r
        Contact billCon;
        if(customerSET.Billing_Contact__c <> null){
            billCon = [SELECT Id, Address__r.Building_Name__c,Mobile_Number__c,Mobile_Number_2__c,Address__r.Country__r.code__c,Address__r.Postal_Code__r.Service_Number__c,
                                Address__r.Section_Code__r.Section_Name__c,Address__r.Department__r.Department_Name__c,Address__r.Division_Code__r.Department_Name__c,
                                Address__r.Company_Code__r.Company_Name__c,Address__r.City__r.City_Name__c,Address__r.Airline_Number__c,Address__r.Flight_Number_1__c,
                                Address__r.Flight_Number_2__c,Office_Number__c,Address__r.recordType.developerName,Address__r.Address_1__c,Address__r.Address_2__c,
                                Address__r.Address_3__c,Address__r.Address_4__c,Address__r.Building_Name_2__c,Address__r.Street_Name__c,Address__r.Unit_Number__c,
                                Address__r.Level_Number__c,Address__r.Block_House_Number__c,Address__r.Country__c,Address__r.Postal_Code__r.name,NRIC__c,Email,
                                Office_Extension__c,HomePhone__c,Passport__c,Handphone_Number__c,Fax__c,Address__r.Postal_Code__r.Building_Name__c
                                FROM Contact WHERE Id = :customerSET.Billing_Contact__c];
        }
        //replace Zuora__Account__r
        Account accRecord;
        if(customerSET.Zuora__Account__c <> null){
            accRecord = [SELECT Id, Name, Designation__c, Attention_To_Care_Of__c, Attention_Care_Off_ind__c, AccountNumber, Attention_To_Care_Of_Indicator__c, Staff_ID__c
                                FROM Account WHERE Id = :customerSET.Zuora__Account__c];
        }
        system.debug('accRecord: '+accRecord+'>>>billCon: '+billCon);
        /*
        List<Zuora__CustomerAccount__c> customerToCreateList = [Select GST_Out_of_Scope__c,Billing_Contact__r.Address__r.Building_Name__c, Billing_Contact__r.Mobile_Number__c,Billing_Contact__r.Mobile_Number_2__c,Billing_Contact__r.Address__r.Country__r.code__c,
            Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c,Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
            Billing_Contact__r.Address__r.Department__r.Department_Name__c,Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c,
            Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, Billing_Contact__r.Address__r.City__r.City_Name__c,
            Billing_Contact__r.Address__r.Airline_Number__c,Billing_Contact__r.Address__r.Flight_Number_1__c,Billing_Contact__r.Address__r.Flight_Number_2__c,
            Billing_Contact__r.Office_Number__c,Zuora__Account__r.Designation__c,Billing_Contact__r.Address__r.recordType.developerName,
            Zuora__Account__r.Attention_To_Care_Of__c,Zuora__Account__r.Attention_Care_Off_ind__c,Billing_Contact__r.Address__r.Address_1__c,
            Billing_Contact__r.Address__r.Address_2__c,Billing_Contact__r.Address__r.Address_3__c,Billing_Contact__r.Address__r.Address_4__c,
            Billing_Contact__r.Address__r.Building_Name_2__c,Billing_Contact__r.Address__r.Street_Name__c,Billing_Contact__r.Address__r.Unit_Number__c,
            Billing_Contact__r.Address__r.Level_Number__c,Billing_Contact__r.Address__r.Block_House_Number__c,Billing_Contact__r.Address__r.Country__c,
            Billing_Contact__r.Address__r.Postal_Code__r.name,SOA_Grouping__c,Billing_Contact__r.NRIC__c,CreatedBy.name,Id,Name, Status__c, 
            Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, ARMS_Business_Profile__c,
            ARMS_Debt_Management__c, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, Zuora__BillToPostalCode__c, Zuora__BillToCity__c, 
            Zuora__BillToCountry__c, Zuora__BillToName__c,Billing_Contact__r.Email,Billing_Contact__r.Office_Extension__c,Billing_Contact__r.HomePhone__c,
            //START UD-1527 6/23/15 Added by Manolo Valena - Added passport field.
            Billing_Contact__r.Passport__c,
            //END UD-1527 6/23/15 Added by Manolo Valena
            Billing_Contact__r.Handphone_Number__c,Billing_Contact__r.Fax__c, Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c, Zuora__Account__r.Attention_To_Care_Of_Indicator__c, Zuora__Account__r.Staff_ID__c, LastModifiedBy.Name From Zuora__CustomerAccount__c Where Id In :customerSET];
        */
        //END: UD-1810 08/07/2015 Added by S.Puli
        system.debug('customerToCreateList><>>'+customerToCreateList);
        //END: UD-1528 07/07/2015 Added by S.Puli
        //START: UD-0963 04/24/2015 Added by S.PULI
        Set<String> cusName_SET = new Set<String>();
        
        //START: UD-1557 11/06/2015 Added by S.Puli
        Set<Id> cusIds_SET = new Set<Id>();
        if(customerToCreateList.size()>0){
            for(Zuora__CustomerAccount__c ba : customerToCreateList){
                cusName_SET.add(ba.Name);
                cusIds_SET.add(ba.Id);
            }
        }
        
        
        List<Zuora__Subscription__c> newCusSubsList = new List<Zuora__Subscription__c>();
        Map<Id, String> billCusAccToOrderAlias_MAP = new Map<Id, String>();
        //START UD-2653 10-Sept-2015 Added By S.Puli
        String userId = UserInfo.getUserId();
        User userRecord = [SELECT Id, Alias FROM User WHERE Id = :userId];
        //END UD-2653 10-Sept-2015 Added By S.Puli

        if(cusIds_SET.size()>0){
            newCusSubsList = [Select Id, Name, Zuora__CustomerAccount__c, Order_Number_1__r.Billing_Account_Creation_Mode__c, Order_Number_1__r.CreatedBy.Alias from Zuora__Subscription__c Where Zuora__CustomerAccount__c IN :cusIds_SET AND Order_Number_1__r.Billing_Account_Creation_Mode__c = :GlobalVariableClass.CREATE_NEW_BILLACC Limit 1];
            if(newCusSubsList.size()>0){
                for(Zuora__Subscription__c zSub : newCusSubsList){
                    if(!billCusAccToOrderAlias_MAP.containsKey(zSub.Zuora__CustomerAccount__c)){
                        billCusAccToOrderAlias_MAP.put(zSub.Zuora__CustomerAccount__c, zSub.Order_Number_1__r.CreatedBy.Alias);
                    }
                }
            }
        }
        
        
        //END: UD-1557 11/06/2015 Added by S.Puli
        
        List<BT_CO_ARMS_CreateCustAccountFile__c> createCusFile_LIST = [Select Id, Customer_Name1__c, Reference_Key__c, CreatedDate From BT_CO_ARMS_CreateCustAccountFile__c Where CreatedDate = Today AND Customer_Name1__c In :cusName_SET];
        
        Map<Id, List<BT_CO_ARMS_CreateCustAccountFile__c>> createMasterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_CreateCustAccountFile__c>>();
        if(customerToCreateList.size()>0 && createCusFile_LIST.size()>0){
            for(Zuora__CustomerAccount__c billRec : customerToCreateList){
                for(BT_CO_ARMS_CreateCustAccountFile__c bFile : createCusFile_LIST){
                    if(billRec.Name == bFile.Customer_Name1__c){
                        if(createMasterToDetail_MAP.containskey(billRec.Id)){
                            createMasterToDetail_MAP.get(billRec.Id).add(bFile);
                        }else{
                            createMasterToDetail_MAP.put(billRec.Id, new List<BT_CO_ARMS_CreateCustAccountFile__c>{bFile});
                        }
                    }
                }
            }
        }

        system.debug('billCusAccToOrderAlias_MAP>>'+billCusAccToOrderAlias_MAP);

        if(customerToCreateList.size()>0){
    //END: UD-0963 04/24/2015 Added by S.PULI
            for(Zuora__CustomerAccount__c customerRec : customerToCreateList){
                //START: UD-1557 11/06/2015 Added by S.Puli
                //START: UD-1810 08/07/2015 Added by S.Puli
                //if(billCusAccToOrderAlias_MAP.containsKey(customerRec.Id)){
                //END: UD-1810 08/07/2015 Added by S.Puli
                //END: UD-1557 11/06/2015 Added by S.Puli
                
                    //START: UD-0963 04/24/2015 Added by S.PULI
                    if(createMasterToDetail_MAP.containskey(customerRec.Id)){
                        if(createMasterToDetail_MAP.get(customerRec.Id).size()>0){
                            for(BT_CO_ARMS_CreateCustAccountFile__c batchFileRecord : createMasterToDetail_MAP.get(customerRec.Id)){
                                createFileToDelete.add(batchFileRecord);
                            }                   
                        }
                    }
                    //END: UD-0963 04/24/2015 Added by S.PULI
                    
                    string referenceKey = accRecord.AccountNumber;
                    string uniqueKey = accRecord.AccountNumber;
                    
                    if (accRecord.AccountNumber != null) {
                        
                        if (accRecord.AccountNumber.length() > 10) {
                            
                            referenceKey =  accRecord.AccountNumber.substring(0, 10);
                        }

                        if (accRecord.AccountNumber.length() > 26) {
                            
                            uniqueKey = accRecord.AccountNumber.substring(0, 26);
                        }
                    }
                    //END: D-995 12/05/14 Added by S.Puli
                    
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec1 = new BT_CO_ARMS_CreateCustAccountFile__c(
                        Customer_Name1__c = customerRec.Name,
                        Customer_Status__c = ConstantsSLB.getOther('ARMS_CusSts'),
                        Company_Code__c = ConstantsSLB.getOther('ARMS_CoyCd'),
                        Reference_Key__c = referenceKey,
                        Unique_Key__c = uniqueKey,
                        Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
                        Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt'),
                        Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt'),
                        //START: UD-1557 11/06/2015 Added by S.Puli
                        //START: UD-1810 08/07/2015 Added by S.Puli
                        //Create_Id__c = customerRec.LastModifiedBy.Name.substring(0,15),
                        //END: UD-1810 08/07/2015 Added by S.Puli
                        //END: UD-1557 11/06/2015 Added by S.Puli
                        Sub_Contact_Name__c = customerRec.Zuora__BillToName__c,
                        //START UD-2418 02-Sept-2015 Added By S.Puli
                        Sub_Contact_Designation__c = accRecord.Designation__c,
                        Sub_Contact_Ext__c = (Test.isRunningTest()) ? '123' : billCon.Office_Extension__c,
                        //END UD-2418 02-Sept-2015 Added By S.Puli
                        //Sub_Contact_Type__c,
                        Debt_Mgt_Treatment__c = customerRec.ARMS_Debt_Management__c,
                        Business_Profile__c = customerRec.ARMS_Business_Profile__c, 
                        Record_Type__c = 'Master',
                        Status__c = 'New',
                        SPH_Staff_Indicator__c='N',
                    //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Credit_Term_Reference__c = ConstantsSLB.getOther('ARMS_CrTrmRef'),
                        Approved_Debt_Exposure_Amount__c = ConstantsSLB.getOther('ARMS_DbtExp'),
                        SOA_Group__c = customerRec.SOA_Grouping__c,
                        GST_OutOfScope_Indicator__c = (customerRec.GST_Out_of_Scope__c ? 'Y' : 'N')
                        //SOA_Supression_Indicator__c
                    );
                    
                    //START: UD-1810 08/07/2015 Added by S.Puli
                    if(billCusAccToOrderAlias_MAP.containsKey(customerRec.Id)){
                        cusRec1.Create_Id__c = billCusAccToOrderAlias_MAP.get(customerRec.Id);
                    }else{
                        //START UD-2653 10-Sept-2015 Added By S.Puli
                        /*
                        if(customerRec.LastModifiedBy.Name.length()>15){
                            cusRec1.Create_Id__c = customerRec.LastModifiedBy.Name.substring(0,15);
                        }
                        else{
                            cusRec1.Create_Id__c = customerRec.LastModifiedBy.Name;
                        }
                        */
                        cusRec1.Create_Id__c = userRecord.Alias;
                        //END UD-2653 10-Sept-2015 Added By S.Puli
                    }
                    //END: UD-1810 08/07/2015 Added by S.Puli
                    
                    if(billCon.Address__r.recordType.developerName == 'Local'){
                        cusRec1.Postal_Code__c = billCon.Address__r.Postal_Code__r.name;
                        cusRec1.City_Zip__c = '';
                        cusRec1.Country__c = billCon.Address__r.Country__r.code__c;
                        cusRec1.Block_House_Number__c = billCon.Address__r.Block_House_Number__c;
                        cusRec1.Floor_Number__c = billCon.Address__r.Level_Number__c;
                        cusRec1.Unit_No__c = billCon.Address__r.Unit_Number__c;
                        cusRec1.Street__c = billCon.Address__r.Street_Name__c;
                        cusRec1.Building_Secondary__c = billCon.Address__r.Postal_Code__r.Building_Name__c;
                        cusRec1.PO_Box_No__c = billCon.Address__r.Postal_Code__r.Service_Number__c;
                    }
                    
                    if(billCon.Address__r.recordType.developerName == 'Overseas'){
                        cusRec1.Address1__c = billCon.Address__r.Address_1__c;
                        cusRec1.Address2__c = billCon.Address__r.Address_2__c;
                        cusRec1.Address3__c = billCon.Address__r.Address_3__c;
                        cusRec1.Address4__c = billCon.Address__r.Address_4__c;
                        cusRec1.Country__c = billCon.Address__r.Country__r.code__c;
                    }
                    
                    if(billCon.Address__r.recordType.developerName == 'Internal'){
                        cusRec1.Address1__c = billCon.Address__r.Section_Code__r.Section_Name__c;
                        cusRec1.Address2__c = billCon.Address__r.Department__r.Department_Name__c;
                        cusRec1.Address3__c = billCon.Address__r.Division_Code__r.Department_Name__c;
                        cusRec1.Address4__c = billCon.Address__r.Company_Code__r.Company_Name__c;
                        cusRec1.Country__c = billCon.Address__r.Country__r.code__c;
                    }
                    
                    if(billCon.Address__r.recordType.developerName == 'Airline'){
                        cusRec1.Address1__c = (billCon.Address__r.City__r.City_Name__c.length() > 40 ? billCon.Address__r.City__r.City_Name__c.subString(0,40) : billCon.Address__r.City__r.City_Name__c ) ;
                        cusRec1.Address2__c = billCon.Address__r.Airline_Number__c;
                        cusRec1.Address3__c = billCon.Address__r.Flight_Number_1__c;
                        cusRec1.Address4__c = billCon.Address__r.Flight_Number_2__c;
                        cusRec1.Country__c = billCon.Address__r.Country__r.code__c;
                    }
                    
                    cusRec1.Co_Attention_To_Indicator__c = accRecord.Attention_To_Care_Of_Indicator__c;
                    cusRec1.co_Attention_To_Party__c = accRecord.Attention_To_Care_Of__c;
                    
                    /*if(customerRec.Zuora__BillToAddress1__c<>null){
                        if(customerRec.Zuora__BillToAddress1__c.length() > 40){
                            cusRec1.Address1__c = customerRec.Zuora__BillToAddress1__c.substring(0, 40);
                        } else {
                            cusRec1.Address1__c = customerRec.Zuora__BillToAddress1__c;
                        }
                    }
                    if(customerRec.Zuora__BillToAddress2__c<>null){
                        if(customerRec.Zuora__BillToAddress2__c.length() > 40){
                            cusRec1.Address2__c = customerRec.Zuora__BillToAddress2__c.substring(0, 40);
                        } else {
                            cusRec1.Address2__c = customerRec.Zuora__BillToAddress2__c;
                        }
                    }*/
                    
                    if(cusRec1.Business_Profile__c == 'GOVT' && cusRec1.Debt_Mgt_Treatment__c == 'GOVT'){
                        cusRec1.Credit_Term__c = '30';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'SUBH'){
                        cusRec1.Credit_Term__c = '15';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'SUBL'){
                        cusRec1.Credit_Term__c = '10';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'NORM'){
                        cusRec1.Credit_Term__c = '0';
                    }
                    if(billCon.NRIC__c != null){
                        cusRec1.ID_Type__c = 'NRIC';
                        cusRec1.ID_No__c = billCon.NRIC__c;
                    }
                    //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                    else {
                        if(billCon.Passport__c != null) {
                            cusRec1.ID_Type__c = GlobalVariableClass.PASS;
                            cusRec1.ID_No__c = billCon.Passport__c;
                        }
                    }
                    //END UD-1527 6/23/15 Added by Manolo Valena
                    //END: D-995 12/05/14 Added by S.Puli
                    
                    //START: UD-1528 07/07/2015 Added by S.Puli
                    if(accRecord.Staff_ID__c <> null){
                        cusRec1.SPH_Staff_Indicator__c = 'Y';
                    }
                    //END: UD-1528 07/07/2015 Added by S.Puli
                    
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec2 = new BT_CO_ARMS_CreateCustAccountFile__c(
                        Customer_Name1__c = customerRec.Name,
                        Customer_Status__c = ConstantsSLB.getOther('ARMS_CusSts'),
                        Reference_Key__c = referenceKey,
                        Unique_Key__c = uniqueKey,
                        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Business_Profile__c = customerRec.ARMS_Business_Profile__c, 
                        //END: D-995 12/05/14 Added by S.Puli
                        Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
                        Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt'),
                        Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt'),
                        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Debt_Mgt_Treatment__c = customerRec.ARMS_Debt_Management__c,
                        //END: D-995 12/05/14 Added by S.Puli
                        //START: UD-1557 11/06/2015 Added by S.Puli
                        Create_Id__c = billCusAccToOrderAlias_MAP.get(customerRec.Id),
                        //END: UD-1557 11/06/2015 Added by S.Puli
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //Sub_Contact_Name__c = customerRec.Zuora__BillToName__c,
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //Sub_Contact_Designation__c,
                        Sub_Contact_Type__c='O',
                        //Sub_ContactNo_Email__c,
                        //Sub_Contact_Ext__c,
                        Record_Type__c = 'Detail',
                        //START: UD-0964/095 04/22/2015 Added by S.PULI
                        Status__c = 'New',
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //Sub_Contact_Designation__c = accRecord.Designation__c,
                        Sub_ContactNo_Email__c = billCon.Office_Number__c
                        //Sub_Contact_Ext__c = billCon.Office_Extension__c //START/END UD-0118 5/20/15 MGaelo Change OfficeExtension into phone
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //END: UD-0964/095 04/22/2015 Added by S.PULI

                    );
                    
                    if(billCon.Office_Number__c <>  null){
                        cusRec2.Sub_ContactNo_Email__c = billCon.Office_Number__c;
                    }else {
                        cusRec2.Sub_Contact_Type__c = null;
                        cusRec2.Sub_ContactNo_Email__c = '0';
                    }
                    
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec3 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec4 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec5 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec6 = null;

                    if(billCon.HomePhone__c != null){
                        cusRec3 = cusRec2.clone();
                        cusRec3.Sub_Contact_Type__c = 'H';
                        cusRec3.Sub_ContactNo_Email__c = billCon.HomePhone__c;
                        cusRec3.Sub_Contact_Ext__c = '';
                    }
                    
                    if(billCon.Mobile_Number__c != null || billCon.Mobile_Number_2__c != null){
                        cusRec4 = cusRec2.clone();
                        cusRec4.Sub_Contact_Type__c='M';
                        cusRec4.Sub_ContactNo_Email__c = (billCon.Mobile_Number__c != null ? billCon.Mobile_Number__c : billCon.Mobile_Number_2__c);
                        cusRec4.Sub_Contact_Ext__c = '';
                    }
                    
                    if(billCon.Fax__c != null){
                        cusRec5 = cusRec2.clone();
                        cusRec5.Sub_Contact_Type__c = 'F';
                        cusRec5.Sub_ContactNo_Email__c = billCon.Fax__c;
                        cusRec5.Sub_Contact_Ext__c = '';
                    }
                    
                    if(billCon.Email != null){
                        cusRec6 = cusRec2.clone();
                        cusRec6.Sub_Contact_Type__c='E';
                        cusRec6.Sub_ContactNo_Email__c = billCon.Email;
                        cusRec6.Sub_Contact_Ext__c = '';
                    }
                    
                    //START D-3775 10/29/15 RReyes
                    String tempContCreate = '';
                    if(cusRec1 != null){
                        if(cusRec1.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec1.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec1.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec2 != null){
                        if(cusRec2.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec2.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec2.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec3 != null){
                        if(cusRec3.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec3.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec3.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec4 != null){
                        if(cusRec4.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec4.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec4.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec5 != null){
                        if(cusRec5.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec5.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec5.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec6 != null){
                        if(cusRec6.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec6.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec6.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    //END D-3775 10/29/15 RReyes
                    cusToCreateBatchList.add(cusRec1);
                    cusToInsertBatchList.add(cusRec1);
                    //START UD-2418 02-Sept-2015 Added By S.Puli
                    if(cusRec2.Sub_Contact_Type__c <> null){
                        cusToInsertBatchList.add(cusRec2);
                    }
                    //END UD-2418 02-Sept-2015 Added By S.Puli
                    if(cusRec3 != null) cusToInsertBatchList.add(cusRec3);
                    if(cusRec4 != null) cusToInsertBatchList.add(cusRec4);
                    if(cusRec5 != null) cusToInsertBatchList.add(cusRec5);
                    if(cusRec6 != null) cusToInsertBatchList.add(cusRec6);
                    baCusIdSet.add(customerRec.Id);
                    
                    system.debug('cusToCreateBatchList<<<'+cusToCreateBatchList);

                //START: UD-1557 11/06/2015 Added by S.Puli 
                //START: UD-1810 08/07/2015 Added by S.Puli
                //}
                //END: UD-1810 08/07/2015 Added by S.Puli
                //END: UD-1557 11/06/2015 Added by S.Puli
            }
        }
        //END: UD-1527 11/06/2015 Added by S.Puli
    }
    //END UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
}