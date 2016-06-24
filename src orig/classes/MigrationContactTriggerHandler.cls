/**
 * Class Name: MigrationContactTriggerHandler
 * @author: <ChristopherCamilon>
 * Date: <03/10/2015>
 * Requirement/Project Name: <SPH>
 * @description : Trigger Handler Class for Contact Trigger (for Migration)
 * 
 */
 
public class MigrationContactTriggerHandler {

    //Before Insert logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doBeforeInsert(List<Contact> lstNewContacts)
    {
        processAddress(lstNewContacts);
        
        //Set running number - only Recipient Contact
        //START D-2975 05192015 Christopher Camilon - To load contact records faster
        /*
        List<Contact> lstRecipients = new List<Contact>();
        for(Contact newContact : lstNewContacts)
        {
            if(newContact.Recipient_Indicator__c == true)
                lstRecipients.add(newContact);
        }
        
        if(!lstRecipients.isEmpty())
            setRecipientNumber(lstRecipients);
        */
        //END D-2975 05192015 Christopher Camilon - To load contact records faster
    }
    

    
    //Before Update logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doBeforeUpdate(List<Contact> lstNewContacts, Map<Id, Contact> mapNewContacts,
                               List<Contact> lstOldContacts, Map<Id, Contact> mapOldContacts)
    {
        List<Contact> lstUpdatedContacts = new List<Contact>();
        for(Contact newContact : lstNewContacts)
        {
            
            //Verify if Address is changed
           /* if(newContact.Address__c != null && mapOldContacts.get(newContact.Id) != null && newContact.Address__c != mapOldContacts.get(newContact.Id).Address__c){
             */
            //START D-2833 03232015 Christopher Camilon - To update for Migration purposes
            if(newContact.Address__c != null){
                lstUpdatedContacts.add(newContact);
            }
            //START D-2603 03232015 Christopher Camilon - To make the country field null for Contact with no address
            else if (newContact.Address__c == null){
            
                newContact.MailingCountry = null; 
                newContact.Address_Unique_Id__c  = null;
                newContact.MailingStreet = null;                            
                newContact.MailingCity = null;
                newContact.MailingCountry = null;
                newContact.MailingPostalCode = null;
            }
            //END D-2603 03232015 Christopher Camilon - To make the country field null for Contact with no address
        }
        
        if(!lstUpdatedContacts.isEmpty())
            processAddress(lstUpdatedContacts);
    }
   
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
                /*
                if(thisAddress.RecordType.DeveloperName == 'Airline' && parentAccountMap.containsKey(con.AccountId)
                    && parentAccountMap.get(con.AccountId).Airline_Indicator__c == FALSE){
                        con.addError('Invalid Address Record Type for Airline Account');
                } 
                */
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
                //START D-2603 03232015 Christopher Camilon - To make the country field null for  Airline and Internal Address Record type

                else if(thisAddress.RecordType.DeveloperName == 'Airline') {                  
                    con.MailingCountry = 'Singapore'; // START-END : D-2591 3/25/2013 Alyana Navarro
                    con.Address_Unique_Id__c = thisAddress.Name;
                    con.MailingStreet = null;
                    con.MailingPostalCode = null;
                    if(thisAddress.City__c != null) 
                        con.MailingCity = thisAddress.City__r.City_Name__c;
                        
                        
                }
                else if(thisAddress.RecordType.DeveloperName == 'Internal'){
                   
                    con.MailingCountry = 'Singapore'; // START-END : D-2591 3/27/2015 Alyana Navarro - Default Mailing Country ro Singapore                     
                    con.Address_Unique_Id__c  = null;
                    con.MailingStreet = null;                            
                    con.MailingCity = null;                  
                    con.MailingPostalCode = null;
                }
                //END D-2603 03232015 Christopher Camilon - To make the country field null for  Airline and Internal Address Record type
            }
       
        } // END of For Loop
    }
    
    //START D-2975 05192015 Christopher Camilon - To load contact records faster
    /*
    //16/02/2015 Wenjun - using Custom Setting instead of "Counter" as it is not thread safe 
    private void setRecipientNumber(List<Contact> lstRecipients) {
        Integer nextNumber = null;
        Key_Id__c setting;
        
        try{
            //Query the next number from Custom Setting and Lock for update to prevent concurrent updates
            //setting = [SELECT Name, Id__c FROM Key_Id__c WHERE Name = 'NEXT_RECIPIENT_NUMBER' LIMIT 1 FOR UPDATE];
            setting = [SELECT Name, Id__c FROM Key_Id__c WHERE Name = 'NEXT_RECIPIENT_NUMBER' LIMIT 1];
            if(setting != null)
            {
                nextNumber = Integer.valueOf(setting.Id__c);
            
                if(nextNumber != null)
                {
                    for (Contact contact : lstRecipients){
                        contact.Recipient_Number__c = nextNumber;
                        nextNumber ++; 
                    }
            
                    //Update Custom Setting with the next number
                    setting.Id__c = String.valueOf(nextNumber);
                }
            }
            if(setting != null)
                UPDATE setting; //Release Lock
        }
        catch(Exception e)
        {
            throw e;
        }
        finally
        {
          /*  if(setting != null)
                UPDATE setting; //Release Lock
            */    
                //END D-2833 03232015 Christopher Camilon - To update for Migration purposes
   /*     }
    }
    */
    //END D-2975 05192015 Christopher Camilon - To load contact records faster
    
}