/**
* Class Name: UpdateParticulars
* @author: Accenture PDC - Sherwin Puli
* Date: 11.Nov.2014
* Requirement/Project Name: SF SPH
* @description: 
*/

public with sharing class UpdateParticulars {
    
    public String getResponse() {
        return response;
    }
    
     public String response { get; set; }
		
     @future (callout=true)
	//START UD-0773 7/4/2015 Added By C. Lin - Changes to update Zuora Bill To for billing contact updates
    //public static void updateZuoraFields(Id conId, String firstName, String lastName, string workEmail, string personEmail, string workPhone, string mobilePhone, string homePhone, string Fax, string country, string address1, string address2, string city, string county, string postalCode, string descrip){
	public static void updateZuoraFields(Map<Id, Id> oldContactIdToNewContactId){
		//Map<Id, String> conMap = new Map<Id, String>();
		Set<Id> oldConIdSet = new Set<Id>();
		Set<Id> newConIdSet = new Set<Id>();
		Set<String> customerNoSet = new Set<String>();
		Map<Id, Set<Zuora__CustomerAccount__c>> conIdToBillAccSetMap = new Map<Id, Set<Zuora__CustomerAccount__c>>();
		Map<Id, Contact> newIdToContactMap = new Map<Id, Contact>();
		Map<Id, Contact> oldContactIdToNewContact = new Map<Id, Contact>();
		List<Contact> lstNewContacts = new List<Contact>();
		
		for(Id contId : oldContactIdToNewContactId.keySet()){
			if(contId != null){
				oldConIdSet.add(contId);
			}
			
			if(oldContactIdToNewContactId.containsKey(contId)){
				newConIdSet.add(oldContactIdToNewContactId.get(contId));
			}
		}
		
		lstNewContacts = [SELECT Id, Name, FirstName, LastName, Email__c, Email_Secondary__c, Office_Number__c, Mobile_Number__c, HomePhone__c, Fax__c, Address__r.Country__r.Country_Name__c, Address__r.Address_1__c, Address__r.Address_2__c, City_Code__r.City_Name__c, zqu__County__c, Address__r.Postal_Code__r.Name, Description, Fax FROM Contact WHERE Id IN : newConIdSet];
		
		for(Contact con : lstNewContacts){
			if(con.Id != null){
				newIdToContactMap.put(con.Id, con);
			}
		}
		
		for(Id oldConId : oldContactIdToNewContactId.keySet()){
			if(oldContactIdToNewContactId.containsKey(oldConId)){
				if(newIdToContactMap.containsKey(oldContactIdToNewContactId.get(oldConId))){
					oldContactIdToNewContact.put(oldConId, newIdToContactMap.get(oldContactIdToNewContactId.get(oldConId)));
				}
			}
		}
		
		List<Order__c> orList = [Select Id, Name, Account__c, Customer_No__c, Create_ARMS_Customer_Account__c, Business_Profile__c, Debt_Management_Treatment__c, Create_ARMS_Account_Only__c, Other_Payment_Mode__c, Billing_Contact__c  From Order__c Where Billing_Contact__c IN :oldConIdSet AND Other_Payment_Mode__c = 'Invoice' AND Status__c = 'Close'];
		
		if(orList != null && orList.size() > 0){
			for(Order__c ord : orList){
				//START 2/18/15 MGAELO Code Review: Check if ord.Billing_Contact__c and ord.Customer_No__c is null
				if (ord.Customer_No__c != null){
					//conMap.put(ord.Billing_Contact__c, ord.Customer_No__c);
					customerNoSet.add(ord.Customer_No__c);
				}
				//END 2/18/15 Added by MGaelo
			}
		}
		
		//Zuora__CustomerAccount__c billAccRecARMS = [Select Id, Name, Zuora__External_Id__c, Zuora__BillToId__c, Zuora__BillToName__c, ARMS_ID__c, Other_PaymentMethod__c From Zuora__CustomerAccount__c Where ARMS_ID__c IN :customerNoSet AND Other_PaymentMethod__c='Invoice' LIMIT 1]; //Ask Sherwin for LIMIT 1
		
		List<Zuora__CustomerAccount__c> billAccRecList = [Select Id, Name, Zuora__External_Id__c, Zuora__BillToId__c, Zuora__BillToName__c, ARMS_ID__c, Other_PaymentMethod__c, Billing_Contact__c From Zuora__CustomerAccount__c Where Billing_Contact__c IN :oldConIdSet OR (ARMS_ID__c IN :customerNoSet AND Other_PaymentMethod__c='Invoice')];
		
		
		for(Zuora__CustomerAccount__c bAcc : billAccRecList){
			if(conIdToBillAccSetMap.containsKey(bAcc.Billing_Contact__c)){
				conIdToBillAccSetMap.get(bAcc.Billing_Contact__c).add(bAcc);
			}else{
				conIdToBillAccSetMap.put(bAcc.Billing_Contact__c, new Set<Zuora__CustomerAccount__c>{bAcc});
			}
		}
		
		// d-0914
		// alyana navarro
		try{
			//Log in to Zuora
			Zuora.zApi zApiInstance = new Zuora.zApi();
			map<string,boolean> map2 = new map<string,boolean>();
			Zuora.zObject rec = new Zuora.zObject('Contact');
			List<Zuora.zObject> objs = new List<Zuora.zObject>();
			
			try {
				if(!System.Test.isRunningTest()){
					zApiInstance.zlogin();
				}
			}
			catch(Zuora.zAPIException ex){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage())); 
			}
			catch(Zuora.zForceException ex){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage())); 
			}
			
			for(Id cId : oldContactIdToNewContact.keySet()){
				if(oldContactIdToNewContact.containsKey(cId)){
					system.debug(cId + ' ' + oldContactIdToNewContact.get(cId));
				}
				
				if(conIdToBillAccSetMap.containsKey(cId)){
					for(Zuora__CustomerAccount__c ba : conIdToBillAccSetMap.get(cId)){
						rec = new Zuora.zObject('Contact');
						String billingAccountId = ba.Zuora__External_Id__c;
						String contactId = ba.Zuora__BillToId__c;
						system.debug('contact'+contactId+'billingAccountId'+billingAccountId);
						
						//Update Zuora Billing Contact Object
						if(billingAccountId<>null && billingAccountId<>'null'){
							rec.setValue('AccountId', billingAccountId);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('Id', contactId);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('FirstName', oldContactIdToNewContact.get(cId).FirstName);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('LastName', oldContactIdToNewContact.get(cId).LastName);
						}
						if(contactId<>null && contactId <>'null'){  
							rec.setValue('WorkEmail', oldContactIdToNewContact.get(cId).Email__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('PersonalEmail', oldContactIdToNewContact.get(cId).Email_Secondary__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('WorkPhone', oldContactIdToNewContact.get(cId).Office_Number__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('MobilePhone', oldContactIdToNewContact.get(cId).Mobile_Number__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('HomePhone', oldContactIdToNewContact.get(cId).HomePhone__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('Fax', oldContactIdToNewContact.get(cId).Fax);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('Country', oldContactIdToNewContact.get(cId).Address__r.Country__r.Country_Name__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('Address1', oldContactIdToNewContact.get(cId).Address__r.Address_1__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('Address2', oldContactIdToNewContact.get(cId).Address__r.Address_2__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('City', oldContactIdToNewContact.get(cId).City_Code__r.City_Name__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('County', oldContactIdToNewContact.get(cId).zqu__County__c);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('PostalCode', oldContactIdToNewContact.get(cId).Address__r.Postal_Code__r.Name);
						}
						if(contactId<>null && contactId <>'null'){
							rec.setValue('Description', oldContactIdToNewContact.get(cId).Description);
						}
						
						system.debug('full rec ' + rec);
				
						objs.add(rec);
					}
				}
				
			}
			
			try {
				List<Zuora.zApi.SaveResult> results;
				if(!System.Test.isRunningTest()){
					results = zApiInstance.zupdate(objs);
					system.debug('>>results>>'+results);
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
	//END UD-0773 7/4/2015 Added By C. Lin
    }