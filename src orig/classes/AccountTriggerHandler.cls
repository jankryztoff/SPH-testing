public class AccountTriggerHandler implements TriggerHandlerInterface {
     /**
     * Class Name: AccountTriggerHandler
     * @author: Jeffrey Teves
     * Date: 8/4/2014
     * Requirement/Project Name: <SPH>
     * @description 
     * @Change #1: Wenjun at 10/12/14
     *  This is to auto-create Recipient Contact based on existing Recipient Contact during Vendor Subscriber Account Conversion. 
     */

    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    //START - [Wenjun 10/12/14] : Vendor Conversion
    /*------------------- Record Type Ids -------------------*/ 
    public static String ACC_RT_VS = (String) ConstantsSLB.getKeyId('Account_Vendor Subscriber');
    public static String ACC_RT_DI = (String) ConstantsSLB.getKeyId('Account_Direct Individual');
    public static String CON_RT_CUS = (String) ConstantsSLB.getKeyId('Contact_Customer Contact');
    Map<Id, Account> accountsToUpdateMap = new Map<Id, Account>();
    List<Account> lstNewDIAccounts = new List<Account>();
    List<ID> lstVSAccountIDs = new List<ID>();
    //END - [Wenjun 10/12/14]
    
    //START: UD-1528 07/07/2015 Added by S.PULI - Set of Ids to update in ARMS update customer callout
    List<Zuora__CustomerAccount__c> billAcc_LIST = new List<Zuora__CustomerAccount__c>();
    //END: UD-1528 07/07/2015 Added by S.PULI

    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !AccountTriggerHandler.isBeforeInsertTriggerCalled;
        AccountTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !AccountTriggerHandler.isBeforeUpdateTriggerCalled;
        AccountTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !AccountTriggerHandler.isBeforeDeleteTriggerCalled;
        AccountTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !AccountTriggerHandler.isAfterInsertTriggerCalled;
        AccountTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !AccountTriggerHandler.isAfterUpdateTriggerCalled;
        AccountTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !AccountTriggerHandler.isAfterDeleteTriggerCalled;
        AccountTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public void bulkBefore() {
        
    }
        
    public void bulkAfter() {
    
        //START: UD-1528 07/07/2015 Added by S.PULI
        Set<Id> accToCheckArms = new Set<Id>();
        if(trigger.isUpdate){
            for(SObject so : trigger.new){
                Account accObj = (Account) so;
                SObject oldSo = Trigger.oldMap.get(accObj.Id);
                Account accOldObj = (Account) oldSo;

            
                if(accOldObj.Staff_ID__c <> accObj.Staff_ID__c || accOldObj.GST_Out_of_Scope__c <> accObj.GST_Out_of_Scope__c || accOldObj.Attention_To_Care_Of__c <> accObj.Attention_To_Care_Of__c){
                    accToCheckArms.add(accObj.Id);
                }
            }
        }
        
        if(accToCheckArms.size()>0){
            billAcc_LIST = [Select Id,Zuora__Account__c,Other_PaymentMethod__c,ARMS_Business_Profile__c,ARMS_Debt_Management__c,ARMS_Customer_Number__c,ARMS_Account_Number__c From Zuora__CustomerAccount__c Where Zuora__Account__c IN :accToCheckArms AND Other_PaymentMethod__c = :GlobalVariableClass.INVOICE AND ARMS_Business_Profile__c <> null AND ARMS_Debt_Management__c <> null AND ARMS_Customer_Number__c <> null AND ARMS_Account_Number__c <> null];
        }
        
        //END: UD-1528 07/07/2015 Added by S.PULI
    }
   
    public void beforeInsert(SObject so) {
        
    }
       
    public void beforeUpdate(SObject oldSo, SObject so) {
        //Start VPernicia/MGatchalian 5/13/15 D-2917: Remove recursion
        Account acc = (Account) so;
        if(acc.Generate_Account_Number__c) {
                acc.AccountNumber = acc.Account_Auto_Number__c;
        }
        //End VPernicia/MGatchalian 5/13/15 D-2917: Remove recursion
    }
    
    public void beforeDelete(SObject so) {
               
    }
    
    public void afterInsert(SObject so) {
        updateAccountNumber(so);
        
        //START - Wenjun Change 10/12/2014: Vendor Conversion
        Account accObj = (Account) so;
        //Validate if it is the conversion case : Record Type is Direct Individual and Parent Account is NOT NULL
        //Note: Here we are not sure whether the Parent Account is a Vendor Subscriber
        if(accObj.RecordTypeID == ACC_RT_DI && accObj.ParentId != NULL)
        {
            lstNewDIAccounts.add(accObj);
            lstVSAccountIDs.add(accObj.ParentId);
        }
        //END - Wenjun Change 10/12/2014: Vendor Conversion
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        //updateAccountNumber(so);//Start/End VPernicia/MGatchalian 5/13/15 D-2917: Remove recursion - comment-out this line

        //START - Wenjun Change 10/12/2014: Vendor Conversion
        Account accObj = (Account) so;
        Account accOldObj = (Account) oldSo;
        
        //Validate if it is the conversion case : Record Type is Direct Individual and Parent Account is NOT NULL
        //Note: Here we are not sure whether the Parent Account is a Vendor Subscriber

        if(accObj.RecordTypeID == ACC_RT_DI && accOldObj.ParentId == NULL && accObj.ParentId != NULL)
        {
            lstNewDIAccounts.add(accObj);
            lstVSAccountIDs.add(accObj.ParentId);
        }
        //END - Wenjun Change 10/12/2014: Vendor Conversion
    }

    public void afterDelete(SObject so) {
        
    }

        //Start VPernicia/MGatchalian 5/13/15 D-2917: Add if Condition to filter if coutn is O
    public void andFinally() {
        if(accountsToUpdateMap.values().size() > 0){
        update accountsToUpdateMap.values();
        }
        //End VPernicia/MGatchalian 5/13/15 D-2917: Add if Condition to filter if coutn is O
        
        //START - Wenjun Change 10/12/2014: Vendor Conversion
        if(!lstVSAccountIDs.isEmpty())
            createRecipientContacts();
        //END - Wenjun Change 10/12/2014
        //START: UD-1528 07/07/2015 Added by S.PULI
        if(billAcc_LIST.size()>0){
            ARMS_CreateAndUpdate armsCall = new ARMS_CreateAndUpdate();
            armsCall.updateCustomer(billAcc_LIST);
        }
        //END: UD-1528 07/07/2015 Added by S.PULI
    }
        
    public void updateAccountNumber(SObject so){ 
        Account acc = (Account) so;
        if(acc.Generate_Account_Number__c) {
            if(!accountsToUpdateMap.containsKey(acc.Id)) {
                Account accToUpdate = new Account(Id = acc.Id);
                accToUpdate.AccountNumber = acc.Account_Auto_Number__c;
                accountsToUpdateMap.put(accToUpdate.Id, accToUpdate);
            }
        }
    }
    
    //@Author: Wenjun Change 10/12/2014: Vendor Conversion
    //@Description: Vendor Conversion to auto-create Recipient Contact
    public void createRecipientContacts()
    {
        List<Contact> lstNewContacts = new List<Contact>();
        
        if (CON_RT_CUS !=NULL && ACC_RT_VS !=NULL && lstVSAccountIDs !=NULL) { //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check
        
        //Retrieve all the Vendor Subscriber Recipient Contacts
        List<Contact> lstContacts = [SELECT Id,AccountId,LastName,FirstName,Salutation,NRIC__c,Passport__c,Billing_Account_Name_2__c,
                                     City_Code__c,Company_Name__c,Phone,MobilePhone,Address__c,Active__c,Email_Secondary__c, 
                                     Email__c,Fax__c,Fax,HomePhone__c,Mobile_Number__c,Mobile_Number_2__c,Office_Number__c, 
                                     Office_Extension__c,Remarks__c FROM Contact
                                     WHERE RecordTypeId= :CON_RT_CUS AND Account.RecordTypeId = : ACC_RT_VS AND AccountId in : lstVSAccountIDs];
        
            if(lstContacts != NULL && !lstContacts.isEmpty())
            {
                //Create Vendor Subscriber Account ID to Vendor recipient Contact Map
                //Assumption: there will be only ONE recipient Contact for each Vendor Subscriber
                Map<ID,Contact> mapIDContact = new Map<ID,Contact>();
                for(Contact contactObj : lstContacts)
                    mapIDContact.put(contactObj.AccountId,contactObj);
                
                //Loop through all the new Direct Individual Accounts and Create New Recipient Contact
                for(Account acocuntObj : lstNewDIAccounts)
                {
                    if(mapIDContact.get(acocuntObj.ParentId) != NULL)
                    {
                        Contact oldContact = mapIDContact.get(acocuntObj.ParentId);
                        Contact newContact = oldContact.clone(false,true,false,false);
                        
                        //Explicitly update the following fields
                        newContact.AccountId = acocuntObj.ID;
                        newContact.RecordTypeId= CON_RT_CUS;
                        newContact.Recipient_Indicator__c=true;

                        lstNewContacts.add(newContact);
                    }//End of If
                }
            } //End of If
        }//END: Code Review Implementation 2/17/2015 KLorica - Added NULL check
        //Finally Insert New Contacts to DB
        INSERT lstNewContacts;
    }
}