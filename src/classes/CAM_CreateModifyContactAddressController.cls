/**
* Class Name: CAM_CreateModifyContactAddressController
* @author: Francis L. A. Sevilla
* Date: 
* Requirement/Project Name: CRSM Project
* @description Controller for CreateModifyContactAddressScreen VF Page
*
* ------Revision------
* Version 1.1: Pilot Release -- updated logic based on DEMO feedback -- By: Jeffrey B. Teves
* History: 05/Jan/2015 Wenjun D-1180   
*          20/Jan/2015 Joban D-1827        
*/
public class CAM_CreateModifyContactAddressController { 

    public String recipientContactId {get;set;}
    Public String AddressType {get;set;}
    public String searchstring {get;set;}
    //public String addressname {get;set;}
    //public String postalcode {get;set;}  
    //public String blockhousenumber {get;set;} 
    //public String street {get;set;} 
    //public String building {get;set;} 
    //public String level {get;set;} 
    //public String unit {get;set;} 
    //public String addtype {get;set;}
    public String addressId {get;set;}
    public String postalId {get;set;}
    //public String postal {get;set;}
    public String selectedCountry {get; set;}
    public String countryCode {get; set;}
    public String cityName {get; set;}
    Public String flightNumber1 {get;set;}
    Public String flightNumber2 {get;set;}
    //START D-0046 3/14/2015 Added By C. Lin - Fix layout of airline address based on the FD given.
    Public String airlineNumber {get; set;}
    //END D-0046 3/14/2015 Added By C. Lin
    public String packingGroupDesc {get; set;}
    public Decimal sequenceNumber{get; set;}        
    public Contact thisContact {get; set;}
    public Address__c stagedAddress {get; set;}
    public Boolean checked {get;set;}
    public Boolean onOwnWindow {get; set;}
    //public Boolean addFound {get;set;}
    //public Boolean intparam {get;set;}
    //needs to be added back.
    public Boolean billingIndicator {get; set;}
    public Boolean recipientIndicator {get; set;}

    public List<Address__c> add {get;set;}
    public List<Contact> con = new List<Contact>(); //START-END D-4076 12-10-2015 added by Jason A. for code review  
    public List<SelectOption>  countries {get; set;}
    public boolean isInIframe { get; set; }
    String acctId;
    private Map<String, String> countryCodeCountryNameMap; //Map of Country__c Id to Country Code
    private Map<Id, Address__c> addressMap;
    private Contact contact2;
    private String searchquery;
    public String rectype {get; set;}
//START: CCB002 Added by April Banaag - to apply changes to contact record type
    //Id recipientId = (ConstantsSLB.getKeyId('Contact_Recipient Contact'));
    //Id billingId = (ConstantsSLB.getKeyId('Contact_Billing Contact'));
//END: CCB002 Added by April Banaag - to apply changes to contact record type
    
    public CAM_CreateModifyContactAddressController(ApexPages.StandardController controller) {        
        thisContact = (Contact) controller.getRecord();
        acctId = ApexPages.currentPage().getParameters().get('accountId');
        rectype = ApexPages.currentPage().getParameters().get('RecordType');
        
        //START CCB-002 12/05/14 KEVasco Set Billing Indicator default value to true if we are creating a billing contact
        if(recType == 'Billing')
        {
            billingIndicator = true;
            recipientIndicator = false;
        }
        else {
            billingIndicator = false;
            recipientIndicator = true;
        }
        //END CCB-002 12/04/14 KEVasco
        /*
        //ANUP DEFECT 1 AND 4
        if(rectype == recipientId) {
            recipientIndicator = true;
        }       
        else if(rectype == billingId) {
            billingIndicator = true;
        }*/
        if(acctId != null && acctId != '' && acctId != 'null') {
            try {
                //START UD-0118 5/20/2015 Added By C. Lin
                Account acc = [Select Id, NRIC__c, Passport__c, Company_Name__c, Phone, Mobile__c, Office_Number__c, Office_Extension__c, Fax, Email__c, Email_Secondary__c, Attention_To_Care_Of_Salutation__c FROM Account WHERE Id = :acctId];
                //END UD-0118 5/20/2015 Added By C. Lin
                thisContact.AccountId = acc.Id;
                //START UD-0118 5/20/2015 Added By C. Lin
                thisContact.NRIC__c = acc.NRIC__c;
                thisContact.Passport__c = acc.Passport__c;
                thisContact.Company_Name__c = acc.Company_Name__c;
                thisContact.HomePhone__c = acc.Phone;
                thisContact.Mobile_Number__c = acc.Mobile__c;
                thisContact.Office_Number__c = acc.Office_Number__c;
                thisContact.Salutation = acc.Attention_To_Care_Of_Salutation__c; //START/END UD-0118 MGaelo Added AttentionToCareOfSalutation
                if(acc.Office_Extension__c != null){
                    thisContact.Office_Extension__c = acc.Office_Extension__c;  //START/END UD-0118 MGaelo change OfficeExtension into phone
                }else{
                    thisContact.Office_Extension__c = null;
                }
                thisContact.Fax__c = acc.Fax;
                thisContact.Email__c = acc.Email__c;
                thisContact.Email_Secondary__c = acc.Email_Secondary__c;
                //END UD-0118 5/20/2015 Added By C. Lin
                //START: D-1180 01/05/14 Wenjun : For non-Iframe mode, 'RecordType' is ID not as 'Recipient' or 'Billing' and the following code should outside this block - regarless of 'acctId' value
                /*
                //START: D-1180 12/18/14 Added by A Banaag - get selected recordtype from parameters string recTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        //START: D-1329 12/22/14 Added by S.Puli       
                if(rectype != null && rectype != '' && rectype != 'null') {
                    if(rectype == 'Recipient' || rectype == 'Billing') {
                        thisContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    }
                }
        //END: D-1329 12/22/14 Added by S.Puli
        //END: D-1180 12/18/14 Added by A Banaag - get selected recordtype from parameters 
                */
                //END: D-1180 01/05/14 Wenjun
            }
            catch(QueryException e) {
                String errorMessage = 'Error trying to fetch Account details. Error: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
        }
        
        //START: D-1180 01/05/14 Wenjun : Bring the code outside Account IF Loop      
        //Mode 1: VF Page inside iFrame
        if(rectype == 'Recipient' || rectype == 'Billing') 
            thisContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //Mode 2: Not inside Iframe - from "New Contact" button
        //To validate if it is a Valid ID
        else if(rectype InstanceOf ID)
            thisContact.RecordTypeId = rectype;
        //END: D-1180 01/05/14 Wenjun
        //Start D-2270 02/18/2015 Added by ABanaag - set Customer Contact as default record type if null as in renewal of sub page iFrame
        else if (rectype==null){
            thisContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        }
        //End D-2270 02/18/2015 Added by ABanaag - set Customer Contact as default record type if null in renewal of sub page iFrame
        
       stagedAddress = new Address__c();
       countryCodeCountryNameMap = new Map<String, String>();
       countries = new List<SelectOption>();
       countries.add(new SelectOption('', '--select one--'));
       for(Country__c country : [SELECT Id, Country_Name__c,  Name FROM Country__c ORDER BY Country_Name__c]) {
           countryCodeCountryNameMap.put(country.Id, country.Name); //START/END D-2924 MGaelo 5/21/15 Arrange countries in order
           countries.add(new SelectOption(country.Id, Country.Country_Name__c));
       }
       checked = FALSE;
       if(ApexPages.currentPage().getUrl().contains('CreateModifyContactAddress')) {
           onOwnWindow = TRUE;
       }
       else {
           onOwnWindow = FALSE;
       }
       //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(URL.getCurrentRequestUrl())));

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
        searchquery = 'Select name, Postal_Code__c, Postal_Code__r.Name, Block_House_Number__c, Street_Name__c, Building_Name__c,Level_Number__c, Unit_Number__c, Address_Type__c From Address__c where RecordtypeId in (Select Id from Recordtype where SObjectType = \'Address__c\' and Name = \'Local\') and '
                                + (stagedAddress.Postal_Code__c != null ? 'Postal_Code__c = \'' + stagedAddress.Postal_Code__c + '\' and ' : '')
                                /*+ (stagedAddress.Name != null && stagedAddress.Name != '' ? ' Name like \'' + stagedAddress.Name + '%\' and ' : '')
                                + (stagedAddress.Block_House_Number__c != null && stagedAddress.Block_House_Number__c != '' ? ' Block_House_Number__c like \'' + stagedAddress.Block_House_Number__c + '%\' and ' : '')*/
                                + (stagedAddress.Level_Number__c != null && stagedAddress.Level_Number__c != '' ? 'Level_Number__c like \''+stagedAddress.Level_Number__c+'%\' and ' : '')
                                /*+ (stagedAddress.Street_Name__c != null && stagedAddress.Street_Name__c != '' ? 'Street_Name__c like \'' + stagedAddress.Street_Name__c + '%\' and ' : '')
                                + (stagedAddress.Building_Name__c != null && stagedAddress.Building_Name__c != '' ? 'Building_Name__c like \''+stagedAddress.Building_Name__c + '%\' and ' : '')*/
                                + (stagedAddress.Unit_Number__c != null && stagedAddress.Unit_Number__c != '' ? 'Unit_Number__c like \''+stagedAddress.Unit_Number__c+'%\' and ' : '')
                                /*+ (stagedAddress.Address_Type__c != null && stagedAddress.Address_Type__c != '' ? 'Address_Type__c like \''+stagedAddress.Address_Type__c+'%\' and ' : '')*/;
                                
        searchquery =  searchquery.endsWith('and ')? searchquery.substring(0, (searchquery.length() - 4)): searchquery ;                  

        system.debug('soql has this value: ' + searchquery);
        addressMap = new Map<Id, Address__c>((List<Address__c>) Database.query(searchquery));
        add = addressMap.values();
    }  
    
    //populate cuntry code based on selected country -- airline
    public void fetchCountryCode() {
        if(countryCodeCountryNameMap.containsKey(selectedCountry)) {
            countryCode = countryCodeCountryNameMap.get(selectedCountry);
        }
        //populate country lookup field on address record based on user's selecton
        if(selectedCountry != null && selectedCountry != '') {
            stagedAddress.Country__c = selectedCountry;
        }
    }
      
    public void fetchCityName() {
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
    
        if(stagedAddress.Packing_Code__c != null) {
            //START D-0046 3/14/2015 Added By C. Lin - Fix layout of airline address based on the FD given.
            Packing_Grp__c det = [SELECT Id, Packing_Group_Description__c, Sequence_Number__c, Airline__c
                              FROM Packing_Grp__c WHERE Id = :stagedAddress.Packing_Code__c];
            airlineNumber = det.Airline__c;
            //END D-0046 3/14/2015 Added By C. Lin
            packingGroupDesc = det.Packing_Group_Description__c;
            sequenceNumber = (Decimal)det.Sequence_Number__c;
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'PackingGroup Details : '+ ' stagedAddress.Packing_Code__c ' + det));

        }
        else{
            packingGroupDesc = '';            
            sequenceNumber = null;            
        }
    }
    
    //set value of contact address based on the selected record
    public void selectAddressRecord(){
        checked = false;
        thisContact.Address__c = addressId;
        if(addressMap.containsKey(addressId)) {
            stagedAddress = addressMap.get(addressId).clone();
            //Start UD-0205 03/23/2015 James - pass value of formula fields to text fields
            stagedAddress.Street_Name_2__c = stagedAddress.Street_Name__c;
            stagedAddress.Building_Name_2__c = stagedAddress.Building_Name__c;
            //End UD-0205 03/23/2015 James
        }
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
    //Start UD-0205 03/23/2015 James - clear values on postal code change
    public void clearAddressDetails2() {
        addressId = '';
        thisContact.Address__c = null;
        stagedAddress.Unit_Number__c = null;
        stagedAddress.Level_Number__c = null;
        stagedAddress.Address_Type__c = null;
        stagedAddress.Block_House_Number__c = null;
        stagedAddress.Name = null;
        stagedAddress.Street_Name_2__c = null;
        stagedAddress.Building_Name_2__c = null;
    }
    //End UD-0205 03/23/2015 James
    public pageReference saveRecord(){
        Boolean addressInserted = FALSE;
        List<Contact> contactInsertList = new List<Contact>();
        //require user to tick at least one indicator.
        //added back
        if(recipientIndicator == FALSE && billingIndicator == FALSE) {
            ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR, 'Please tick Billing Indicator, Recipient Indicator or both.'));
            return null;
        }
               
        //START: D-1180 01/05/14 Wenjun : Redundant code - Record Type already set in Constructor Method
        /*
    //START: D-1180 12/18/14 Added by A Banaag - get selected recordtype from parameters 
    //START: D-1329 12/22/14 Added by S.Puli        
    if(rectype != null && rectype != '' && rectype != 'null') {
      
      if(rectype == 'Recipient' || rectype == 'Billing') {
        thisContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
      }
    }
    //END: D-1329 12/22/14 Added by S.Puli
    //END: D-1180 12/18/14 Added by A Banaag - get selected recordtype from parameters 
        */
        //END: D-1180 01/05/14 Wenjun 

        //if(rectype!= null && rectype!= '' && rectype!= 'null' && (rectype == recipientId || rectype == billingId )) {
        //if (isInIframe == FALSE ) { 
           /* if (rectype == string.valueof(recipientId)) {
                contact2 = thisContact.clone();
                contact2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
                contact2.Recipient_Indicator__c = true;
                contactInsertList.add(contact2);
                
            }
            else if (rectype == string.valueof(billingId)){
                thisContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Billing Contact');
                thisContact.Billing_Indicator__c = true;
                contactInsertList.add(thisContact);
            }*/
         /*} 
         else 
         {           
            if (billingId != null && (billingId == ConstantsSLB.getKeyId('Contact_Billing Contact'))){
                thisContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Billing Contact');
                thisContact.Billing_Indicator__c = true;
                contactInsertList.add(thisContact);
            }
            else if(recipientId != null && (recipientId == ConstantsSLB.getKeyId('Contact_Recipient Contact'))) {
                contact2.Id = thisContact.Id;
                contact2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
                contact2.Recipient_Indicator__c = true;
                contactInsertList.add(contact2);
            }
        } */
        
        //Require user to select an address type
        if(addressType == null || addressType == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an address type!'));
            return null;
        }
        // START : CCB.002 12/1/2014 Added By A. Navarro - Creation of contact.
        Boolean result = validateContact();
        if(!result){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact with Billing Indicator already exist.'));
            return null;
        } else {
            if (checked || AddressType != 'Local') {
                
                //Require Postal Code for Local addresses
                if(stagedAddress.Postal_Code__c == null && addressType == 'Local') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Postal Code.'));
                    return null;
                }
                //validate Unit Number and Level Number fields
                if(stagedAddress.Unit_Number__c != null && stagedAddress.Unit_Number__c.length() < 2) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unit must be at least two characters.'));
                    return null;
                }
                if(stagedAddress.Level_Number__c != null && stagedAddress.Level_Number__c.length() < 2) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Level must be at least two characters.'));
                    return null;
                }
                if(checked) {
                    //Start UD-0713 James 04/01/2015 - Allow user to create an Address with Postal Code input only
                    /*searchquery = 'Select name, Postal_Code__c, Postal_Code__r.Name, Block_House_Number__c, Street_Name__c, Building_Name__c,Level_Number__c, Unit_Number__c, Address_Type__c From Address__c where RecordtypeId in (Select Id from Recordtype where SObjectType = \'Address__c\' and Name = \'Local\') and '
                                    + (stagedAddress.Postal_Code__c != null ? 'Postal_Code__c = \'' + stagedAddress.Postal_Code__c + '\' and ' : '')
                                    + (stagedAddress.Name != null && stagedAddress.Name != '' ? ' Name like \'' + stagedAddress.Name + '%\' and ' : '')
                                    + (stagedAddress.Block_House_Number__c != null && stagedAddress.Block_House_Number__c != '' ? ' Block_House_Number__c like \'' + stagedAddress.Block_House_Number__c + '%\' and ' : '')
                                    + (stagedAddress.Level_Number__c != null && stagedAddress.Level_Number__c != '' ? 'Level_Number__c like \''+stagedAddress.Level_Number__c+'%\' and ' : '')
                                    + (stagedAddress.Street_Name__c != null && stagedAddress.Street_Name__c != '' ? 'Street_Name__c like \'' + stagedAddress.Street_Name__c + '%\' and ' : '')
                                    + (stagedAddress.Building_Name__c != null && stagedAddress.Building_Name__c != '' ? 'Building_Name__c like \''+stagedAddress.Building_Name__c + '%\' and ' : '')
                                    + (stagedAddress.Unit_Number__c != null && stagedAddress.Unit_Number__c != '' ? 'Unit_Number__c like \''+stagedAddress.Unit_Number__c+'%\' and ' : '')
                                    + (stagedAddress.Address_Type__c != null && stagedAddress.Address_Type__c != '' ? 'Address_Type__c like \''+stagedAddress.Address_Type__c+'%\' and ' : '');
                    
                    searchquery =  searchquery.endsWith('and ')? searchquery.substring(0, (searchquery.length() - 4)): searchquery ;  
                    */
                    string PCode = stagedAddress.Postal_Code__c;
                    string UnitNumber = stagedAddress.Unit_Number__c;
                    string LevelNumber = stagedAddress.Level_Number__c;
                    List<Address__c> matchingAddress = [Select name, Postal_Code__c, Postal_Code__r.Name, Block_House_Number__c, Street_Name__c, Building_Name__c,Level_Number__c, Unit_Number__c, Address_Type__c From Address__c where Level_Number__c = :LevelNumber and Unit_Number__c = :UnitNumber and Postal_Code__c = :PCode];
                    try {
                        //List<Address__c> matchingAddress = Database.query(searchQuery);
                        //End UD-0713 James 04/01/2015
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
          //START D-1827 20/01/15 Joban : if the type of the address is local or Internal populate the country to Singapore
                    // START : D-2591 3/24/2015 Alyana Navarro - Added Airline in condition.
                    
                    if(AddressType == 'Local' || AddressType =='Internal' || AddressType == 'Airline'){
                    // END : D-2591 3/24/2015 Alyana Navarro   
                       
                       //START D-3144 20-06-2015 Marvin Gatchalian Added filter "SG" and throws an error if no record found
                       list<Country__c> countryList = new List<Country__c>([Select Id from Country__c where Country_Name__c = 'Singapore' 
                                                                               and Name = 'SG' limit 1]);
                    
                       
                       if(!countryList.isEmpty()){
                           stagedAddress.Country__c = countryList[0].Id;
                           //START UD-1719 KAREN HUNG 6/22/2015
                           /*insert stagedAddress;
                           addressInserted = TRUE;                                             
                           thisContact.Address__c = stagedAddress.id;*/
                           //END UD-1719 KAREN HUNG 6/22/2015

                       }
                       else {
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record not found for local country name. Make sure Singapore was added in Country list.'));
                           return null;
                       }
                    }
                    //START UD-1719 KAREN HUNG 6/22/2015
                           insert stagedAddress;
                           addressInserted = TRUE;                                             
                           thisContact.Address__c = stagedAddress.id;
                    //karen
                    //END UD-1719 KAREN HUNG 6/22/2015 
                     
                    //END D-3144 20-06-2015 Marvin Gatchalian Added filter "SG" and throws an error if no record found
                }
                catch(DmlException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                    return null;
                }
                
            }
            
            if(thisContact.Address__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an existing Address record or create a New one.'));
                return null;            
            }
            //added back ANUP DEFECT 1 AND 4
            //if (billingIndicator == true) {
                // should be change to Customer Contact Record Type
                //thisContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Billing Contact');
                thisContact.Billing_Indicator__c = billingIndicator;
                thisContact.Recipient_Indicator__c = recipientIndicator;
                //contactInsertList.add(thisContact);
            //}
            // END : CCB.002 12/1/2014
            
            /*if (recipientIndicator == true) {
    //            contact2 = thisContact.clone();
                if(contact2 == null){
                    contact2 = thisContact.clone();
                }
                contact2.Billing_Indicator__c = FALSE;
                contact2.Recipient_Indicator__c = TRUE; 
                contact2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
                contactInsertList.add(contact2);                
            }*/
            try {
                //if(String.valueOf(contactInsertList)!= NULL){
                    // START : CCB.002 12/1/2014 Added By A. Navarro - Creation of contact.
                    // insert contactInsertList;
                    //if(billingIndicator == true && recipientIndicator == false){
                    insert thisContact;
                    
                    //}                
                    
                    // END : CCB.002 12/1/2014 Added By A. Navarro
                //}
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
        }
        String returnId;
        //added back
        if(thisContact.Id != NULL) {
            returnId = thisContact.Id;
        }
        else if(contact2.Id != NULL) {
            returnId = contact2.Id;
        }
        
        // [JohnD 12/05] CCB-002
        if (isInIframe == true) {
            string xUrlParam = ApexPages.currentPage().getParameters().get('RecordType');
            if (xUrlParam != null) {
                xUrlParam = '?rType=' + xUrlParam;
            } else {
                xUrlParam = '';
            }
            return new PageReference('/apex/ContactCreationConfirmation' + xUrlParam);
        } else {
            return new PageReference('/' + returnId);
        }
        // end CCB-002
        
        try {
            if(thisContact.Id != NULL) {
                returnId = thisContact.Id;
                recipientContactId = thisContact.Id;
            }
            if (contact2.Id != NULL) {
                returnId = contact2.Id;
                recipientContactId = contact2.Id;
            }
        } catch (Exception e) {
            if (contact2 != null){
            Contact contact2 = new Contact();
            
            }
        }
        
        if (isInIframe == false) {
                // [JohnD 12/04] CCB-002
            return new PageReference('/apex/ContactCreationConfirmation');
            // end CCB-002
        }
        
        else{
             return new PageReference('/apex/CreateModifyContactAddress?accountId=' + acctId);
        }
    }
    
    // START : CCB 002 12/3/2014 Added By Alyana P. Navarro
    public Boolean validateContact(){
        Boolean flag = true;
        try{
            List<Contact> contactRec = [SELECT id, name, firstname, lastname, email__c, Recipient_Indicator__c, Billing_Indicator__c 
                                        FROM Contact 
                                        WHERE AccountId =: acctId AND Billing_Indicator__c = true];        
                                                        
            if(billingIndicator && !recipientIndicator){
                for(Contact con : contactRec){
                    if(thisContact.firstname == con.firstname && thisContact.lastname == con.lastname && thisContact.email__c == con.email__c && con.billing_Indicator__c == true && con.recipient_Indicator__c == true){               
                        con.billing_Indicator__c = false;
                        flag = true;
                    }                        
                }
                
                update contactRec;
            } else if(billingIndicator && recipientIndicator){            
                for(Contact con : contactRec){
                    if(thisContact.firstname == con.firstname && thisContact.lastname == con.lastname && thisContact.email__c == con.email__c && con.billing_Indicator__c == true && con.recipient_Indicator__c == false){
                        flag = false;
                        break;
                    }
                }
            }
        } catch(Exception e){
            system.debug('No contact selected. No further action required.');
        }
                
        return flag;
    }
    // END : CCB 002 12/5/2014
}