/**
 * Class Name: <ContactTriggerHandler>
 * @author: <FrancisMartinBenzon>
 * Date: <7/15/2014>
 * Requirement/Project Name: <SPH>
 * @description : Trigger Handler Class for Contact Trigger
 * History : 16/02/2015 Wenjun - Rewrite the class to use new Trigger Framework which fix Code Review issues;
                                 Also use Custom Setting for Recipient Next Number to be Thread Safe
 */
 
public class ContactTriggerHandler {

    //Before Insert logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doBeforeInsert(List<Contact> lstNewContacts)
    {
        processAddress(lstNewContacts);
        
        //Set running number - only Recipient Contact
        List<Contact> lstRecipients = new List<Contact>();
        for(Contact newContact : lstNewContacts)
        {
            if(newContact.Recipient_Indicator__c == true)
                lstRecipients.add(newContact);
        }
        
        if(!lstRecipients.isEmpty())
            setRecipientNumber(lstRecipients);    
    }
    
    //After Insert logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doAfterInsert(List<Contact> lstNewContacts, Map<Id, Contact> mapNewContacts)
    {}
    
    //Before Update logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doBeforeUpdate(List<Contact> lstNewContacts, Map<Id, Contact> mapNewContacts,
                               List<Contact> lstOldContacts, Map<Id, Contact> mapOldContacts)
    {
        List<Contact> lstUpdatedContacts = new List<Contact>();
        for(Contact newContact : lstNewContacts)
        {
            //Verify if Address is changed
            if(newContact.Address__c != null && mapOldContacts.get(newContact.Id) != null
             && newContact.Address__c != mapOldContacts.get(newContact.Id).Address__c)
                lstUpdatedContacts.add(newContact);
        }
        
        if(!lstUpdatedContacts.isEmpty())
            processAddress(lstUpdatedContacts);
            
        // START D-3594 10/28/2015 K. Tan 
        List<Contact> lstRecipients = new List<Contact>();
        for(Contact newContact : lstNewContacts)
        {   
            if(newContact.Recipient_Indicator__c == true)
                lstRecipients.add(newContact);
        }
        
        if(!lstRecipients.isEmpty())
            setRecipientNumber(lstRecipients);
        //END D-3594 10/28/2015 K. Tan            
            
    }

    //After Update logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doAfterUpdate(List<Contact> lstNewContacts, Map<Id, Contact> mapNewContacts,
                               List<Contact> lstOldContacts, Map<Id, Contact> mapOldContacts)
    {
        //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli 
        if (!System.isBatch()){
            checkIfArmsContact(lstNewContacts);
        }
        //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli 
        updateZuoraPaticular(lstNewContacts, mapOldContacts);
    }
    
    //Before Delete logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doBeforeDelete(List<Contact> lstOldContacts, Map<Id, Contact> mapOldContacts)
    {}
    
    //After Delete logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doAfterDelete(List<Contact> lstOldContacts, Map<Id, Contact> mapOldContacts)
    {}
    
    /**
     * Description: Validate Address Fields and populate data based Address Type
    **/
    private void processAddress(List<Contact> lstNewContacts)
    {
        Set<Id> addressIds = new Set<Id>();
        Set<Id> parentAccountIds = new Set<Id>();
        
        for (Contact conObj : lstNewContacts){
            parentAccountIds.add(conObj.AccountId);
            addressIds.add(conObj.Address__c);
        } 
        
        //Fetch Address Details
        Map<Id, Address__c> addressMap = new Map<Id, Address__c>([SELECT Id, Name, Address_Unique_Id__c, Postal_Code__r.Name, Block_House_Number__c, 
                                                Street_Name__c, Building_Name__c, Level_Number__c, Unit_Number__c,  Country__c, Country__r.Country_Name__c, 
                                                City__c, City__r.City_Name__c, Address_1__c, Address_2__c, Address_3__c, Address_4__c, RecordType.DeveloperName 
                                                FROM Address__c WHERE Id IN : addressIds]); 
        //Fetch Related Account Details                                   
        Map<Id, Account> parentAccountMap = new Map<Id, Account>([SELECT Id, Airline_Indicator__c FROM Account WHERE Id IN : parentAccountIds]);
        
        for (Contact con : lstNewContacts){
            if(con.Address__c != null && addressMap.containsKey(con.Address__c)) 
            {
                Address__c thisAddress = addressMap.get(con.Address__c);
                con.Address_Unique_Id__c = thisAddress.Address_Unique_ID__c;
                
                if(thisAddress.RecordType.DeveloperName == 'Airline' && parentAccountMap.containsKey(con.AccountId)
                    && parentAccountMap.get(con.AccountId).Airline_Indicator__c == FALSE){
                        con.addError('Invalid Address Record Type for Airline Account');
                } 
                
                if(thisAddress.RecordType.DeveloperName == 'Local') {
                    con.MailingStreet = (thisAddress.Block_House_Number__c != null ? thisAddress.Block_House_Number__c : '') +
                                        (thisAddress.Street_Name__c != null ? ' ' + thisAddress.Street_Name__c + '\n' : '') + 
                                        (thisAddress.Building_Name__c != null ? ' ' + thisAddress.Building_Name__c : '') +
                                        (thisAddress.Level_Number__c != null ? thisAddress.Level_Number__c : '') +
                                        (thisAddress.Level_Number__c != null && thisAddress.Unit_Number__c != null ? ' - ' : '') +
                                        (thisAddress.Unit_Number__c != null ? thisAddress.Unit_Number__c : '');
                                        
                    con.MailingCity = 'Singapore';
                    con.MailingCountry = 'Singapore';
                    con.MailingPostalCode = thisAddress.Postal_Code__r.Name;
                }
                else if(thisAddress.RecordType.DeveloperName == 'Overseas') {
                    if(thisAddress.Country__c != NULL) 
                        con.MailingCountry = thisAddress.Country__r.Country_Name__c;
                    
                    con.MailingStreet = (thisAddress.Address_1__c != null ? thisAddress.Address_1__c : '') +
                                        (thisAddress.Address_2__c != null ? ' ' + thisAddress.Address_2__c : '') +
                                        (thisAddress.Address_3__c != null ? ' ' + thisAddress.Address_3__c : '') +
                                        (thisAddress.Address_4__c != null ? ' ' + thisAddress.Address_4__c : '');                
                }
                else if(thisAddress.RecordType.DeveloperName == 'Airline') {                                        
                    con.MailingCountry = 'Singapore'; // START-END : D-2591 3/25/2015 Alyana Navarro    
                    if(thisAddress.City__c != null)
                        con.MailingCity = thisAddress.City__r.City_Name__c;
                    
                    con.Address_Unique_Id__c = thisAddress.Name;
                }
                // START : D-2591 3/27/2015 Alyana Navarro - Added logic for Internal Address
                else if(thisAddress.RecordType.DeveloperName == 'Internal'){
                    con.MailingCountry = 'Singapore';
                }
                // END : D-2591 3/27/2015 Alyana Navarro
            }
        } // END of For Loop
    }
    
    //16/02/2015 Wenjun - using Custom Setting instead of "Counter" as it is not thread safe 
    private void setRecipientNumber(List<Contact> lstRecipients) {
        Integer nextNumber = null;
        Key_Id__c setting;
        Key_Id__c setting2;
        
        try{
            //Query the next number from Custom Setting and Lock for update to prevent concurrent updates           
            setting = [SELECT Name, Id__c FROM Key_Id__c WHERE Name = 'NEXT_RECIPIENT_NUMBER' LIMIT 1 FOR UPDATE];           
            //System.assertEquals(setting2,setting);
            if(setting != null)
            {
                nextNumber = Integer.valueOf(setting.Id__c);
            
                if(nextNumber != null)
                {
                    for (Contact contact : lstRecipients){
                        //START D-3901 Nov-6-2015 Added By C. Lin - Update Recipient Number only if null
                        if(contact.Recipient_Number__c == null){
                            contact.Recipient_Number__c = nextNumber;
                            contact.Recipient_Number_Show__c = String.valueOf(nextNumber); // START-END D-3594 10/28/2015 K. Tan
                            nextNumber ++; 
                        }
                        //END D-3901 Nov-6-2015 Added By C. Lin
                    }
            
                    //Update Custom Setting with the next number
                    setting.Id__c = String.valueOf(nextNumber);
                }
            }
        }
        catch(Exception e)
        {
            throw e;
        }
        finally
        {
            if(setting != null)
                UPDATE setting; //Release Lock
        }
    }
    
    private void updateZuoraPaticular(List<Contact> lstNewContacts, Map<Id, Contact> mapOldContacts)
    {
        String firstName;String lastName;
        String workEmail;String personEmail;
        String workPhone; String mobilePhone;String homePhone; String Fax;
        String country;String address1;String address2;String city;String county;String postalCode;
        String descrip;     
        Boolean needUpdateZuora = false;     
        
        //START UD-0773 7/4/2015 Added By C. Lin - Create map for oldContactId to newContact for UpdateParticulars.updateZuoraFields
        Map<Id, Id> oldContactIdToNewContactId = new Map<Id, Id>();
        Set<Id> conIdSet = new Set<Id>();
        
        for(Contact con : lstNewContacts){
            if(con.Id != null){
                conIdSet.add(con.Id);
            }
        }
        
        lstNewContacts = [SELECT Id, Name, FirstName, LastName, Email__c, Email_Secondary__c, Office_Number__c, Mobile_Number__c, HomePhone__c, Fax__c, Address__r.Country__r.Country_Name__c, Fax,
        Address__r.Address_1__c, Address__r.Address_2__c, City_Code__r.City_Name__c, zqu__County__c, Address__r.Postal_Code__r.Name, Description FROM Contact WHERE Id IN :conIdSet];
        
        for(Contact newContact : lstNewContacts)
        {
            Contact oldContact = mapOldContacts.get(newContact.Id);
            
            if(newContact.FirstName != oldContact.FirstName || newContact.LastName != oldContact.LastName || newContact.Email__c != oldContact.Email__c || 
            newContact.Email_Secondary__c != oldContact.Email_Secondary__c || newContact.Office_Number__c != oldContact.Office_Number__c || newContact.Mobile_Number__c != oldContact.Mobile_Number__c || 
            newContact.HomePhone__c != oldContact.HomePhone__c || newContact.Fax != oldContact.Fax || newContact.Address__r.Country__r.Country_Name__c != oldContact.Address__r.Country__r.Country_Name__c || 
            newContact.Address__r.Address_1__c != oldContact.Address__r.Address_1__c || newContact.Address__r.Address_2__c != oldContact.Address__r.Address_2__c || 
            newContact.City_Code__r.City_Name__c != oldContact.City_Code__r.City_Name__c || newContact.zqu__County__c != oldContact.zqu__County__c || 
            newContact.Address__r.Postal_Code__r.Name != oldContact.Address__r.Postal_Code__r.Name || newContact.Description != oldContact.Description)
            {
                if(!oldContactIdToNewContactId.containsKey(oldContact.Id)){
                    oldContactIdToNewContactId.put(oldContact.Id, newContact.Id);
                }
                needUpdateZuora = true;
            }
            
            /*if(newContact.FirstName != oldContact.FirstName){
                firstName = newContact.FirstName;
                needUpdateZuora = true;
            }
            if(newContact.LastName != oldContact.LastName){
                lastName = newContact.LastName;
                needUpdateZuora = true;
            }
            if(newContact.Email__c != oldContact.Email__c){
                workEmail = newContact.Email__c;
                needUpdateZuora = true;
            }
            if(newContact.Email_Secondary__c != oldContact.Email_Secondary__c){
                personEmail = newContact.Email_Secondary__c;
                needUpdateZuora = true;
            }
            if(newContact.Office_Number__c != oldContact.Office_Number__c){
                workPhone = newContact.Office_Number__c;
                needUpdateZuora = true;
            }
            if(newContact.Mobile_Number__c != oldContact.Mobile_Number__c){
                mobilePhone = newContact.Mobile_Number__c;
                needUpdateZuora = true;
            }
            if(newContact.HomePhone__c != oldContact.HomePhone__c){
                homePhone = newContact.HomePhone__c;
                needUpdateZuora = true;
            }
            if(newContact.Fax__c != oldContact.Fax__c){
                Fax = newContact.Fax__c;
                needUpdateZuora = true;
            }*/
            
            /***************************** Potential Issue *******************************************/
            //Note: Wenjun 17/02/15 the following codes have issues: Trigger.New and Trigger.Old 
            //  does NOT contains values for relationship fields. Need query 1st
            /*if(newContact.Address__r.Country__r.Country_Name__c != oldContact.Address__r.Country__r.Country_Name__c){
                country = newContact.Address__r.Country__r.Country_Name__c;
                needUpdateZuora = true;
            }
            if(newContact.Address__r.Address_1__c != oldContact.Address__r.Address_1__c){
                address1 = newContact.Address__r.Address_1__c;
                needUpdateZuora = true;
            }
            if(newContact.Address__r.Address_2__c != oldContact.Address__r.Address_2__c){
                address2 = newContact.Address__r.Address_2__c;
                needUpdateZuora = true;
            }   
            if(newContact.City_Code__r.City_Name__c != oldContact.City_Code__r.City_Name__c){
                city = newContact.City_Code__r.City_Name__c;
                needUpdateZuora = true;
            }
            if(newContact.zqu__County__c != oldContact.zqu__County__c){
                county = newContact.zqu__County__c;
                needUpdateZuora = true;
            }
            if(newContact.Address__r.Postal_Code__r.Name != oldContact.Address__r.Postal_Code__r.Name){
                postalCode = newContact.Address__r.Postal_Code__r.Name;
                needUpdateZuora = true;
            }
            if(newContact.Description != oldContact.Description){
                descrip = newContact.Description;
                needUpdateZuora = true;
            }*/
        } // End of For Loop
        
        //START D-1814 1/19/2015 Added By C. Lin - For Future cannot be called by Batch Error
        if(needUpdateZuora && !System.isBatch()){
            //UpdateParticulars.updateZuoraFields(oldContact.Id, firstName, lastName, workEmail, personEmail, workPhone, mobilePhone, homePhone, Fax, country, address1, address2, city, county, postalCode, descrip);
            UpdateParticulars.updateZuoraFields(oldContactIdToNewContactId);
        }
        //END D-1814 1/19/2015 Added By C. Lin
        
        //END UD-0773 7/4/2015 Added By C. Lin
    }
    //START: D-3046 ARMS Update Customer 12/05/2015 Added by S.Puli
    public void checkIfArmsContact(List<Contact> contact_LIST){
    
        Map<Id, Zuora__CustomerAccount__c> conIdToBillAcc_MAP = new Map<Id, Zuora__CustomerAccount__c>();
        Set<Id> conId_SET = new Set<Id>();
        List<Zuora__CustomerAccount__c> billAcc_LIST = new List<Zuora__CustomerAccount__c>();
        List<Zuora__CustomerAccount__c> billAccToUpdate_LIST = new List<Zuora__CustomerAccount__c>();
        for(Contact c : contact_LIST){
            conId_SET.add(c.Id);
        }
        
        if(conId_SET.size()>0){
            billAcc_LIST = [Select Id, Name, ARMS_Customer_Number__c, Billing_Contact__c, ARMS_Account_Number__c From Zuora__CustomerAccount__c Where Billing_Contact__c In :conId_SET AND ARMS_Customer_Number__c <> null AND ARMS_Account_Number__c <> null];
        
        }
        
        if(billAcc_LIST.size()>0){
            for(Zuora__CustomerAccount__c ba : billAcc_LIST){
                if(conIdToBillAcc_MAP.containskey(ba.Id)){
                    //do nothing
                } else{
                    conIdToBillAcc_MAP.put(ba.Id, ba);
                    billAccToUpdate_LIST.add(ba);
                }
            }       
        }
        
        if(billAccToUpdate_LIST.size()>0){
            ARMS_CreateAndUpdate updateContactInARMS = new ARMS_CreateAndUpdate();
            updateContactInARMS.updateCustomer(billAccToUpdate_LIST);
        }
        
        ARMS_TriggerHandler.isSkipUpdate = true;
        
    }
    //END: D-3046 ARMS Update Customer 12/05/2015 Added by S.Puli
}