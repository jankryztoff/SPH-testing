/**
 * Class Name: ChangeOfParticulars
 * @author: April Banaag
 * Date: 11/03/2014 
 * Requirement/Project Name: Singapore Press Holdings
 * @description Change of Particulars for Billing and Recipient contacts
 *
 * History: Add the Account fields for defect D-0937
 * @author: Rica Kirsten Joy Mayo
 * Date: 12/01/2014
 *
 */

public class ChangeOfParticulars{

    private Boolean editingAsPartOfChangeOfParticulars {get; set;}
    public Contact aContact { get; set;}
	
	//START: D-0633 12/5/2014 Added by C. Lin - Updating Address Details for Internal and Airline Address Type
	public Boolean IsInternalAirline { get; set;}
    public String AddressType{ get; set;}
    //END: D-0633 12/5/2014 Added by C. Lin
    
	Contact c;

    //START: D-0937 12/01/14 Added by R.Mayo
    //additional fields
	
    public ChangeOfParticulars(ApexPages.StandardController controller){
		//START: D-0633 12/5/2014 Added by C. Lin - Added Address fields to update for Internal and Airline
        //START:Code Review Implementation 2/18/15 Added by Manolo Vale?a - Checks if the Id is not equal to null.
        //START: UD-1528 16-July-2015 Added by S.Puli - change from Fax to Fax__c
        if(ApexPages.currentPage().getParameters().get('ContactId') != null){
            c = [Select Recipient_Indicator__c, Billing_Indicator__c, MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode, AccountId, Id, Salutation, FirstName, Address__c, Address__r.RecordTypeId, Address__r.RecordType.Name,
                Address__r.Location_Code__c, Address__r.Company_Code__c, Address__r.Division_Code__c, Address__r.Section_Code__c,
                Address__r.Additional_Info__c, Address__r.City__c, Address__r.Packing_Code__c,
                LastName, HomePhone__c, Mobile_Number__c, Mobile_Number_2__c, Email__c, Email_Secondary__c, NRIC__c, Office_Number__c, 
                RecordTypeId, Fax, Passport__c, Account.Language__c, Account.Gender__c, Account.Race__c, Account.Designation__c, Recipient_Number__c,
                Account.Education__c, Account.Income_Range__c, Account.Date_of_Birth__c, Office_Extension__c, Fax__c
                From Contact where Id = : ApexPages.currentPage().getParameters().get('ContactId')];
        //END: UD-1528 16-July-2015 Added by S.Puli - change from Fax to Fax__c        
			//END: D-0633 12/5/2014 Added by C. Lin
			
			aContact = c;
			
			editingAsPartOfChangeOfParticulars = true;
			
			//START: D-0633 12/5/2014 Added by C. Lin - Updating Address Details for Internal and Airline Address Type
			 if(c != null){
				if(c.Address__r.RecordType.Name == 'Internal' || c.Address__r.RecordType.Name == 'Airline'){
					IsInternalAirline = true;
				}else{
					IsInternalAirline = false;
				}
				
				AddressType = c.Address__r.RecordType.Name;
			}
			//END: D-0633 12/5/2014 Added by C. Lin
		}
		//END:Code Review Implementation 2/18/15 Added by Manolo Vale?a
    }
	
    public pageReference saveContact(){
		//START:Code Review Implementation 2/18/15 Added by Manolo Vale?a - Checks if aContact is not equal to null.
		if(aContact != null){
			aContact.Recipient_Number__c = c.Recipient_Number__c;
			aContact.salutation= c.salutation;
			aContact.FirstName = c.FirstName;
			aContact.LastName = c.LastName;     
			aContact.Address__c = c.Address__c;   
			aContact.HomePhone__c= c.HomePhone__c;
			aContact.Mobile_Number__c= c.Mobile_Number__c;
			aContact.Mobile_Number_2__c= c.Mobile_Number_2__c;
			aContact.Email__c= c.Email__c;
			aContact.Email_Secondary__c= c.Email_Secondary__c;
			aContact.NRIC__c= c.NRIC__c;
			aContact.Office_Number__c= c.Office_Number__c;
			aContact.Office_Extension__c= c.Office_Extension__c;
			aContact.RecordTypeId= c.RecordTypeId;
            //START: UD-1528 16-July-2015 Added by S.Puli - change from Fax to Fax__c
            aContact.Fax__c= c.Fax__c;
            //START: UD-1528 16-July-2015 Added by S.Puli - change from Fax to Fax__c
			aContact.Passport__c= c.Passport__c;
			aContact.AccountId = c.AccountId ;
			aContact.MailingCountry = c.MailingCountry;
			aContact.MailingStreet = c.MailingStreet;
			aContact.MailingCity = c.MailingCity;
			aContact.MailingState = c.MailingState;
			aContact.MailingPostalCode = c.MailingPostalCode;
			aContact.Account.Language__c = c.Account.Language__c;
			aContact.Account.Gender__c = c.Account.Gender__c;
			aContact.Account.Race__c = c.Account.Race__c;
			aContact.Account.Designation__c = c.Account.Designation__c;
			aContact.Account.Education__c = c.Account.Education__c;
			aContact.Account.Income_Range__c = c.Account.Income_Range__c;
			aContact.Account.Date_of_Birth__c = c.Account.Date_of_Birth__c;
			
			//START: D-0633 12/5/2014 Added by C. Lin - Updating Address Details for Internal and Airline Address Type
			if(AddressType == 'Internal'){
				aContact.Address__r.Location_Code__c = aContact.Address__r.Location_Code__c;
				aContact.Address__r.Company_Code__c = aContact.Address__r.Company_Code__c;
				aContact.Address__r.Division_Code__c = aContact.Address__r.Division_Code__c;
				aContact.Address__r.Section_Code__c = aContact.Address__r.Section_Code__c;
			}
			
			if(AddressType == 'Airline'){
				aContact.Address__r.Additional_Info__c = aContact.Address__r.Additional_Info__c;
				aContact.Address__r.City__c = aContact.Address__r.City__c;
				aContact.Address__r.Packing_Code__c = aContact.Address__r.Packing_Code__c;
			}
			//END: D-0633 12/5/2014 Added by C. Lin
			
			//END: D-0937 12/01/14 Added by R.Mayo
						
			//START D-2749 4/16/2015 Added By C. Lin - Catch validation errors or other errors for upserting records
			try{
				upsert aContact;
            
				//START: D-0633 12/5/2014 Added by C. Lin - Updating Address Details for Internal and Airline Address Type
				upsert aContact.Account;
				upsert aContact.Address__r;
				//END: D-0633 12/5/2014 Added by C. Lin
			} catch (exception e) {
				ApexPages.addMessages(e);
				return null;
			}
			//END D-2749 4/16/2015 Added By C. Lin
			
			PageReference pageRef = new PageReference('/'+aContact.Id);
			return pageRef;
		}
		return null;
		//END:Code Review Implementation 2/18/15 Added by Manolo Vale?a
    }
    
    
}