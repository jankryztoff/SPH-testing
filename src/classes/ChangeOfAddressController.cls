/**
 * Class Name: ChangeOfAddressController 
 * @author: Carla Haldos
 * Date: 09/03/2014 
 * Requirement/Project Name: Singapore Press Holdings
 * @description Changes of Address for Billing Address address type
 *
 */
public class ChangeOfAddressController {



    Public String AddressType {get;set;}
    public String searchstring {get;set;}
    public String addressId {get;set;}
    public String postalId {get;set;}
    public String selectedCountry {get; set;}
    public String countryCode {get; set;}
    public String cityName {get; set;}
    public Date effectivedate {get;set;}
    Public String flightNumber1 {get;set;}
    Public String flightNumber2 {get;set;}
    public String packingGroupDesc {get; set;}
    public Decimal sequenceNumber{get; set;}     
    public Contact thisContact {get; set;}
    public Address__c stagedAddress {get; set;}
    public Boolean checked {get;set;}
    public Boolean onOwnWindow {get; set;}
    public Boolean billingIndicator {get; set;}
    public Boolean recipientIndicator {get; set;}
    public List<Address__c> add {get;set;}
    public List<Contact> con = new List<Contact>();  //START-END D-4076 12-10-2015 added by Jason A. for code review
    public List<SelectOption>  countries {get; set;}
    private Map<String, String> countryCodeCountryNameMap; //Map of Country__c Id to Country Code
    private Map<Id, Address__c> addressMap;
    private Contact contact2;
    private String searchquery;

    
    Case c;
    
    public changeOfAddressController(ApexPages.StandardController controller) {
    
        c = [Select ContactId, Effective_Date__c From Case where Id = : ApexPages.currentPage().getParameters().get('caseId')];  
        //System.assertEquals(String.valueOf(c),'aaaa');
        effectivedate = c.Effective_Date__c;
        thisContact = (Contact) controller.getRecord();
        checked = false;
       stagedAddress = new Address__c();
       countryCodeCountryNameMap = new Map<String, String>();
       countries = new List<SelectOption>();
       countries.add(new SelectOption('', '--select one--'));
       for(Country__c country : [SELECT Id, Country_Name__c,  Name FROM Country__c]) {
           countryCodeCountryNameMap.put(country.Id, country.Name);
           countries.add(new SelectOption(country.Id, Country.Country_Name__c));
       }
        
    }
    
    public List<SelectOption> getAddressTypeOptions() {
        List<SelectOption> AddressOptions = new List<SelectOption>();
        AddressOptions.add(new SelectOption('','--Select--'));
        AddressOptions.add(new SelectOption('Local','Local'));
        AddressOptions.add(new SelectOption('Internal','Internal'));
        AddressOptions.add(new SelectOption('Overseas','Overseas'));
        AddressOptions.add(new SelectOption('Airline','Airline'));    
        return AddressOptions ;
    }


    public void search() {
        thisContact.Address__c = null;
        searchquery();                

        system.debug('soql has this value: ' + searchquery);
        addressMap = new Map<Id, Address__c>((List<Address__c>) Database.query(searchquery));
        add = addressMap.values();
    }  
    
    //populate cuntry code based on selected country -- airline
    public void fetchCountryCode() {
        checked = false;
        if(countryCodeCountryNameMap.containsKey(selectedCountry)) {
            countryCode = countryCodeCountryNameMap.get(selectedCountry);
            
        }
        //populate country lookup field on address record based on user's selecton
        if(selectedCountry != null && selectedCountry != '') {
            stagedAddress.Country__c = selectedCountry;
        }
    }
    
    public void fetchCityName() {
        checked = false;
        if(stagedAddress.City__C != null) {
            City__c city = [SELECT Id, City_Name__c,Flight_Number_1__c,Flight_Number_2__c FROM City__C WHERE Id = :stagedAddress.City__c];
            cityName = city.City_Name__c;
            flightNumber1 = city.Flight_Number_1__c;
            flightNumber2 = city.Flight_Number_2__c;
        }
        else {
            cityName = '';  
            flightNumber1 = ''; 
            flightNumber2 = '';      
        }
    }
    
    //collect all details can be retrieve in Address object
    public void fetchPackingGrpDetails() {
        checked = false;
        if(stagedAddress.Packing_Code__c != null) {
            Packing_Grp__c det = [SELECT Id, Packing_Group_Description__c, Sequence_Number__c
                              FROM Packing_Grp__c WHERE Id = :stagedAddress.Packing_Code__c];
            packingGroupDesc = det.Packing_Group_Description__c;
            sequenceNumber = (Decimal)det.Sequence_Number__c;
            
            

        }
        else{
           
            packingGroupDesc = '';            
            sequenceNumber = null;            
        }
    }

    
    //set value of contact address based on the selected record
    public pageReference selectAddressRecord(){
        checked = false;
        
        List <Contact> myContacts = new List <Contact>();
        myContacts = [Select id from Contact where id = :thisContact.id and Address__c = :addressId];
        
        if (myContacts.size() <= 0) {
            thisContact.Address__c = addressId;
            if(addressMap.containsKey(addressId)) {
                stagedAddress = addressMap.get(addressId).clone();
            } 
            
        }
        else if (myContacts.size() > 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'unable to select current Contact address'));
        }
        return null;
              
    }
    
    //clear address details on address type selection
    public void clearAddressDetails() {
        stagedAddress = new Address__c();
        addressId = '';
        thisContact.Address__c = null;
    }
    
    public void clearContactAddress() {
        thisContact.Address__c = null;
    }
    
    
    public pageReference saveRecord(){
        Boolean addressInserted = FALSE;
        
        //Require user to select an address type
        if(addressType == null || addressType == '') {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('PleaseSelectAddressType')));
            return null;
        }
        
        if (checked || AddressType != 'Local') {
          
            //Require Postal Code for Local addresses
            if(stagedAddress.Postal_Code__c == null && addressType == 'Local') {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('PleaseSelectPostalCode')));
                return null;
            }
            //validate Unit Number and Level Number fields
            if(stagedAddress.Unit_Number__c != null && stagedAddress.Unit_Number__c.length() < 2) {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('UnitAtLeastTwoChars')));
                return null;
            }
            if(stagedAddress.Level_Number__c != null && stagedAddress.Level_Number__c.length() < 2) {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('LevelATLeastTwoChars')));
                return null;
            }
            if(checked) {
                searchquery();  
                try {
                    List<Address__c> matchingAddress = Database.query(searchQuery);
                    if(matchingAddress != null && matchingAddress.size() > 0) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Existing Address record found: Record Id = ' + matchingAddress[0].Id));
                        return null;
                    }
                }
                catch(QueryException e) {
                    String errorMessage = 'Error trying to validate Address details. Error: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                    return null;
                }  
            }
            try {  
                stagedAddress.RecordTypeId = (ConstantsSLB.getKeyId('Address_' + addressType));
                insert stagedAddress;
                addressInserted = TRUE;
                thisContact.Address__c = stagedAddress.id;
            }
            catch(DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                return null;
            }
            
        }
        system.debug('<<<<<<<<<<<>>>>>>>>>>>>>>>>>>> ' + addressId);
        //Added by Charles for Change of Address Case. Update Contact with selected existing Address based on the Postal Code.
        if(!checked && AddressType == 'Local'){
            if (addressId != null) {
                thisContact = [SELECT Id, Address__c FROM Contact WHERE Id = :thisContact.Id];
                if(addressId != '')
                {
                    thisContact.Address__c = addressId;
                }
                update thisContact;
                system.debug('<<<<<<<<<<<>>>>>>>>>>>>>>>>>>> ' + thisContact.Address__c);
            }
        }
        
        if(thisContact.Address__c == NULL) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.geterrorMessage('PleaseSelectAddressOrNewOne')));
            return null;            
        }
        Address_Assignment__c addressAssignObj = new Address_Assignment__c();
        addressAssignObj.Contact__c = thisContact.Id;
        addressAssignObj.Address__c = thisContact.Address__C;
        if (effectivedate == null || String.valueof(effectivedate) == ''){
            addressAssignObj.Effective_Date__c = null;
        }
        else{
            addressAssignObj.Effective_Date__c = c.Effective_Date__c;
        }
        
        addressAssignObj.Status__c = 'Inactive';
        try {
            //update thisContact;
            insert addressAssignObj;
        }
        catch(DmlException e) {
            //delete pre-inserted address record
            if(addressInserted) {
                Address__c newInstance = stagedAddress.clone();
                newInstance.Name = '';
                delete stagedAddress;
                stagedAddress = newInstance;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            return null;
        }        
        return new PageReference('/' + c.Id);
    }
    
    private void searchquery(){
    searchquery = 'Select name, Postal_Code__c, Postal_Code__r.Name, Block_House_Number__c, Street_Name__c, Building_Name__c,Level_Number__c, Unit_Number__c, Address_Type__c From Address__c where RecordtypeId in (Select Id from Recordtype where SObjectType = \'Address__c\' and Name = \'Local\') and '
                                + (stagedAddress.Postal_Code__c != null ? 'Postal_Code__c = \'' + stagedAddress.Postal_Code__c + '\' and ' : '')
                                + (stagedAddress.Name != null && stagedAddress.Name != '' ? ' Name like \'' + stagedAddress.Name + '%\' and ' : '')
                                + (stagedAddress.Block_House_Number__c != null && stagedAddress.Block_House_Number__c != '' ? ' Block_House_Number__c like \'' + stagedAddress.Block_House_Number__c + '%\' and ' : '')
                                + (stagedAddress.Level_Number__c != null && stagedAddress.Level_Number__c != '' ? 'Level_Number__c like \''+stagedAddress.Level_Number__c+'%\' and ' : '')
                                + (stagedAddress.Street_Name__c != null && stagedAddress.Street_Name__c != '' ? 'Street_Name__c like \'' + stagedAddress.Street_Name__c + '%\' and ' : '')
                                + (stagedAddress.Building_Name__c != null && stagedAddress.Building_Name__c != '' ? 'Building_Name__c like \''+stagedAddress.Building_Name__c + '%\' and ' : '')
                                + (stagedAddress.Unit_Number__c != null && stagedAddress.Unit_Number__c != '' ? 'Unit_Number__c like \''+stagedAddress.Unit_Number__c+'%\' and ' : '')
                                + (stagedAddress.Address_Type__c != null && stagedAddress.Address_Type__c != '' ? 'Address_Type__c like \''+stagedAddress.Address_Type__c+'%\' and ' : '');
                                
                searchquery =  searchquery.endsWith('and ')? searchquery.substring(0, (searchquery.length() - 4)): searchquery ;
               
    
    }
}