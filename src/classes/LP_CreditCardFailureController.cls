public class LP_CreditCardFailureController
{

    //Start UD-3139 VPernica 10/22/15
    public string HomeNumber { get;set; }
    public string OfficeNumber { get;set; }
    public string MobileNumber { get;set; }
    //End UD-3139 VPernica 10/22/15

    public string exPId;
     
    public string contactFirstName { get; set; }
    public string contactLastName { get; set; }
    public string contactName { get; set; }
    public string contactMailingAddress { get; set; }
    public decimal paymentAmount { get; set; } //START/END UD-2551 by dags changed from double to decimal
    public date expirationDate { get; set; }
    
//START D-3722 Gdelrosario : added for format the address
public string finalAddressOutput {get;set;}
//START D-3722 Gdelrosario : added for format the address
    public string mailingStreet { get; set; }
    public string mailingCity { get; set; }
    public string mailingCountry { get; set; }
    public string mailingPostalCode { get; set; }
    
    public string mailingBlk { get; set; }
    public string mailingLevel { get; set; }
    public string mailingUnit { get; set; }
    public string mailingBuilding { get; set; }
    
    public decimal paymentAmount2; //START/END UD-2551 by dags format 2 two decimal place
    
    // START : D-1189 1/22/2015 Alyana Navarro 
    public List<Zuora__Subscription__c> failedSubscriptions { get; set; }
    public List<String> pubCodes {get; set;}
    public List<String> ratePlanName {get;set;}
    public List<zqu__ProductRatePlanCharge__c> ratePlanCharges {get;set;}
    public list<Zuora__SubscriptionProductCharge__c > spcList {get;set;}
    public List<Publication__c> p {get;set;}
    public Date transactionDate {get; set;}
    // END : D-1189 1/22/2015
    //START: D-1189 / 01/20/2015 / P.Villarica
    public List<publicationWrapper> pubWrapper {get;set;}
    //END: D-1189 / 01/20/2015 / P.Villarica
    public map<string, string> publicationDescription {get;set;}
    // START : D-2042 2/19/2015 Alyana Navarro
    public Map<id, String> subIdPubCodeMap {get; set;}
    public String startDate {get; set;}
    public Map<Id, String> subIdStartDate {get; set;}
    public String address1 {get; set;}
    public String address2 {get; set;}
    public String address3 {get; set;}
    public String address4 {get; set;}
    public String address5 {get; set;}
    public String todayString {get; set;}
    public String barcodeId {get; set;}
    public Boolean barcodeFlag {get; set;}
    // END : D-2042 2/19/2015 Alyana Navarro
            
    //START: D-0902 / 12/02/2014 / R.Mayo
    //add the other fields
    public string creditcard { get; set; }
    public string accnumber { get; set; }
    //END: D-0902 / 12/02/2014 / R.Mayo          
    //Start UD-3859 15-Feb-2016 Added by S.Puli
    public string billAccNum { get; set; }
    //End UD-3859 15-Feb-2016 Added by S.Puli
    public LP_CreditCardFailureController()
    {               
        exPId = ApexPages.currentPage().getParameters().get('id');
        
    }

    public Date Today 
    { 
        get 
        { 
            return Date.today(); 
        }
    }
    
    public void initialize()                
    {
        
        // START : D-1189 1/22/2015 Alyana Navarro
        failedSubscriptions = new List<Zuora__Subscription__c>();
        pubCodes = new List<String>();
        ratePlanName = new List<String>();
        ratePlanCharges = new List<zqu__ProductRatePlanCharge__c>();
        spcList = new list<Zuora__SubscriptionProductCharge__c >();
        p = new List<Publication__c>();

        // END : D-1189 1/22/2015
        // START: D-1189 / 01/20/2015 / P.Villarica
        pubWrapper = new List<publicationWrapper>();
        // END: D-1189 / 01/20/2015 / P.Villarica            
        setContactDetails();
    }
                // START : D-2042 3/6/2015 Alyana Navarro
    
    public void setContactDetails(){
        Set<String> pubCodeSet = new Set<String>();
        Set<id> subIdSet = new Set<id>();
        Map<id, Set<String>> subIdPubCodeListMap = new Map<id, Set<String>>();
        startDate = '';
        address1 = '';
        address2 = '';
        address3 = '';
        address4 = '';
        address5 = '';
        List<String> monthName = new List<String>{'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'};
        List<String> fullMonthName = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
        subIdPubCodeMap = new Map<id, String>();
        subIdStartDate = new Map<id, String>();
        try {
            // START D-3477 Gdelrosario 2/9/15 : for dynamic sup for 1st , 2nd, 3rd
            if(Date.Today().day() == 1){
                todayString = Date.Today().day() + '<sup>st</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year();
            }else if(Date.Today().day() == 2){
                todayString = Date.Today().day() + '<sup>nd</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year();
            }else if(Date.Today().day() == 3){
                todayString = Date.Today().day() + '<sup>rd</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year();
            //Start UD-3139 VPernicia 10/22/15
            }else if(Date.Today().day() == 21){
                todayString = Date.Today().day() + '<sup>st</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year();
            }else if(Date.Today().day() == 22){
                todayString = Date.Today().day() + '<sup>nd</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year();
            }else if(Date.Today().day() == 23){
                todayString = Date.Today().day() + '<sup>rd</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year();
            }else if(Date.Today().day() == 31){
                todayString = Date.Today().day() + '<sup>st</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year();
            //End UD-3139 VPernicia 10/22/15
            }else {
                todayString = Date.Today().day() + '<sup>th</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year();
            }
            // END D-3477 Gdelrosario 2/9/15 : for dynamic sup for 1st , 2nd, 3rd
            //<!--START: D-1189 / 01/20/2015 / P.Villarica -->
            String descriptionConcat = '';
            //<!--END: D-1189 / 01/20/2015 / P.Villarica -->
            // START : D-1189 1/22/2015 Alyana Navarro
            External_Payment__c ep;
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(exPId<>null){
            //end : Code Review Implementation 02/18/2015 S.Puli
            //Start UD-3862 22-Feb-2016 Added By S.Puli
            ep = [SELECT Sold_To_Contact_Name__r.FirstName, 
                         Sold_To_Contact_Name__r.LastName,
                         Sold_To_Contact_Name__r.Name, 
                         Sold_To_Contact_Name__r.MailingStreet,
                         Sold_To_Contact_Name__r.MailingCity,
                         Sold_To_Contact_Name__r.MailingCountry,
                         Sold_To_Contact_Name__r.MailingPostalCode,
                         Sold_To_Contact_Name__r.Address__r.Block_House_Number__c,
                         Sold_To_Contact_Name__r.Address__r.Postal_Code__r.Street_Name__c,
                         Sold_To_Contact_Name__r.Address__r.Level_Number__c,
                         Sold_To_Contact_Name__r.Address__r.Unit_Number__c,
                         Sold_To_Contact_Name__r.Address__r.Postal_Code__r.Building_Name__c,
                         Sold_To_Contact_Name__r.Address__r.Postal_Code__r.Name,
                         Sold_To_Contact_Name__r.Address__r.Country_Name__c, Billing_Account__c,                         
                         Billing_Account__r.Zuora__CreditCard_Number__c, Transaction_Date__c,
                         Billing_Account__r.Zuora__AccountNumber__c,
                         Billing_Account__r.Billing_Contact__c, Transaction_Amount__c,                       
                         Payment_amount__c, Expiration_Date__c, Account_Name__r.AccountNumber,
                         Sold_To_Contact_Name__r.HomePhone__c,
                         Sold_To_Contact_Name__r.Office_Number__c,
                         Sold_To_Contact_Name__r.Mobile_Number__c
                  FROM External_Payment__c 
                  WHERE Id =: exPId];
            //End UD-3862 22-Feb-2016 Added By S.Puli
            }//Start/END : Code Review Implementation 02/18/2015 S.Puli
                                      
            //Start : Code Review Implementation 02/18/2015 S.Puli
            Contact billContact;
            if(ep<>null){
                if(ep.Billing_Account__c<>null){
                    if(ep.Billing_Account__r.Billing_Contact__c<>null){
            //START D-3722 Gdelrosario 23/10/2015: added to query
            billContact = [SELECT id, name, firstname, lastname, MailingAddress,
                //end : Code Review Implementation 02/18/2015 S.Puli
                                 Address__r.recordType.developerName,
                                 Address__r.Block_House_Number__c,
                                 Address__r.Street_Name__c,
                                 Address__r.Level_Number__c,
                                 Address__r.Unit_Number__c,
                                 Address__r.Building_Name__c,
                                 Address__r.Country__r.Country_Name__c,
                                 Address__r.Country__r.Code__c,
                                 Address__r.Country__r.Name,
                                 Address__r.Postal_Code__r.Name,
                                 Address__r.Section_Code__r.Section_Name__c,
                                 Address__r.Department__r.Department_Name__c,
                                 Address__r.Division_Code__r.Name,
                                 Address__r.Company_Code__r.Company_Name__c,
                                 Address__r.Location_Code__r.Location_Name__c,
                                 Address__r.Section_Code__r.Name,
                                 Address__r.Department__r.Name,
                                 Address__r.Company_Code__r.Name,
                                 Address__r.Location_Code__r.Name,
                                 Address__r.City__r.City_Name__c,
                                 Address__r.City__r.Name,
                                 Address__r.Packing_Code__c,
                                 Address__r.Location_Code__c,
                                 Address__r.Company_Code__c,
                                 Address__r.Division_Code__c,
                                 Address__r.Department__c,
                                 Address__r.Section_Code__c,
                                 Address__r.Address_1__c,
                                 Address__r.Address_2__c,
                                 Address__r.Address_3__c,
                                 Address__r.Address_4__c,
                                 MailingCountry, 
                                 //START MMallorca D-3722 04/11/2015 Added address fields for Airline Address Type
                                 Address__r.City__r.Country__r.Country_Name__c,
                                 Address__r.Airline_Number__c, 
                                 Address__r.Flight_Number_1__c,
                                 Address__r.Flight_Number_2__c
                                 //END MMallorca D-3722 04/11/2015 Added address fields for Airline Address Type 
                           FROM Contact
                           WHERE id =: ep.Billing_Account__r.Billing_Contact__c];
                           //END D-3722 Gdelrosario 23/10/2015: added to query
                //Start : Code Review Implementation 02/18/2015 S.Puli
                    }
                }
            }//END : Code Review Implementation 02/18/2015 S.Puli                   
            try{
                List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId =: billContact.Address__r.Postal_Code__r.id];
                barcodeId = attList[0].id;
                barcodeFlag = true;
            } catch(Exception e){
                barcodeId = null;
                barcodeFlag = false;
            }
            //List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId =: billContact.Address__r.Postal_Code__r.id];
            //barcodeId = attList[0].id;
            
            // END : D-1189 1/22/2015 Alyana Navarro                                                    
            
            if(ep != Null) {
                // START : D-1189 1/22/2015 Alyana Navarro
                contactFirstName = billContact.FirstName;
                contactLastName = billContact.LastName;
                transactionDate = ep.Transaction_Date__c;
                // END : D-1189 1/22/2015
                //<!--START: D-1189 / 01/20/2015 / P.Villarica -->
                if (billContact.firstname != NULL) {
                    contactName = (billContact.firstname + ' ' + billContact.lastname).toUpperCase();
                } else {
                    contactName = billContact.lastname.toUpperCase();
                }
                //<!--END: D-1189 / 01/20/2015 / P.Villarica -->
                //paymentAmount = ep.Transaction_amount__c;
                //START UD-2551 by dags format 2 two decimal place
                paymentAmount2 = ep.Transaction_amount__c;
                If (paymentAmount2 != null) {
                paymentAmount = paymentAmount2.setScale(2);
                }
                else {
                paymentAmount2 = 0;
                paymentAmount = paymentAmount2.setScale(2);
                }
                //END UD-2551 by dags format 2 two decimal place
                expirationDate = ep.Expiration_Date__c;                                                                                             
                
                //START D-3722 Gdelrosario : added for format the address
                //START D-3722 Gdelrosario 23/10/2015: change parameter  
                finalAddressOutput=AddressHelper.formatAddress(billContact,false,false);
                //END D-3722 Gdelrosario 23/10/2015: change parameter
                //END D-3722 Gdelrosario : added for format the address



                // END : D-2042 3/6/2015 Alyana Navarro
                
                
                //START: D-0902 / 12/02/2014 / R.Mayo
                //add the other fields
                creditcard = ep.Billing_Account__r.Zuora__CreditCard_Number__c;
                accnumber = ep.Account_Name__r.AccountNumber;
                //Start UD-3859 15-Feb-2016 Added by S.Puli
                billAccNum = ep.Billing_Account__r.Zuora__AccountNumber__c;
                //End UD-3859 15-Feb-2016 Added by S.Puli
                //END: D-0902 / 12/02/2014 / R.Mayo
                // START : D-2042 3/6/2015 Alyana Navarro
                
                //Start UD-3139 VPernica 10/22/15
                Zuora__ZInvoice__c invRecord = [SELECT id, Zuora__Zuora_Id__c, createddate, name from Zuora__ZInvoice__c where Zuora__BillingAccount__c =: ep.Billing_Account__c order by createddate desc limit 1];
                
                list<id> listSubID = new list<id>();
                for (Invoice_Line_Item__c invItem: [select Subscription__c from Invoice_Line_Item__c where Invoice_ID__c=: invRecord.Zuora__Zuora_Id__c]) {
                    listSubID.add(invItem.Subscription__c);
                }
                //End UD-3139 VPernica 10/22/15
                //START: D-3931 11/19/2015 added by Jason A.
                list<Zuora__Subscription__c> newFailedSubscriptions = new List<Zuora__Subscription__c>();
                set<id> newFailedSubscriptionsSet = new set<id>();
                map<id, set<string>> oliIDtoPubCode = new map<id, set<string>>();
                // START : D-1189 1/22/2015 April Banaag
                //Start : Code Review Implementation 02/18/2015 S.Puli
                if(billContact.id<>null){
                //End : Code Review Implementation 02/18/2015 S.Puli
                    newFailedSubscriptions = [SELECT id, Name, Zuora__SubscriptionStartDate__c, Recipient_Contact__r.Address__r.Flight_Number_1__c, 
                                           Recipient_Contact__r.Address__r.Flight_Number_2__c, Recipient_Contact__r.Address__r.City__r.Name, 
                                           Recipient_Contact__r.Address__r.City__c, Recipient_Contact__r.Address__r.Packing_Code__c, 
                                           Recipient_Contact__r.Address__r.Country__r.Name, Main_Package_1__r.name
                                           //Start UD-3139 VPernica 10/22/15
                                           ,Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c,
                                           Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c,
                                           Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c, Order_Line_Item_Number_1__c
                                           FROM Zuora__Subscription__c 
                                           WHERE id in: listSubID
                                           //End UD-3139 VPernica 10/22/15
                                           //START D-3249 7/16/2015 Added by Manolo Valena - Added filter to avoid error of delivery subscriptions not having SPCs with field Pub Code not having any value.
                                           AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION];
                                           //END D-3249 7/16/2015 Added by Manolo Valena
                }//Start/End : Code Review Implementation 02/18/2015 S.Puli                                                                 
                if(newFailedSubscriptions.size()>0){
                    for(Zuora__Subscription__c newSub :newFailedSubscriptions){
                        if(!newFailedSubscriptionsSet.contains(newSub.Order_Line_Item_Number_1__c)){
                            newFailedSubscriptionsSet.add(newSub.Order_Line_Item_Number_1__c);
                            failedSubscriptions.add(newSub);
                        }
                    }
                }
                for (Zuora__Subscription__c sub : newFailedSubscriptions){
                        
                    subIdSet.add(sub.id); // START-END : D-2042 2/19/2015 Alyana Navarro
                    startDate = '';
                    startDate += monthName[sub.Zuora__SubscriptionStartDate__c.month() - 1];
                    startDate += String.valueOf(sub.Zuora__SubscriptionStartDate__c.year()).substring(2, 4);
                    subIdStartDate.put(sub.id, startDate);
                    
                    //Start UD-3862 22-Feb-2016 Added By S.Puli
                    HomeNumber = '';
                    OfficeNumber = '';
                    MobileNumber = '';
                    
                    //Start UD-3139 VPernica 10/22/15
                    HomeNumber = ep.Sold_To_Contact_Name__r.HomePhone__c; 
                    OfficeNumber = ep.Sold_To_Contact_Name__r.Office_Number__c;   
                    MobileNumber = ep.Sold_To_Contact_Name__r.Mobile_Number__c; 
                    //End UD-3139 VPernica 10/22/15
                    //End UD-3862 22-Feb-2016 Added By S.Puli
                }
                // END : D-2042 3/6/2015 Alyana Navarro
                // START : D-2042 2/19/2015 Alyana Navarro
                if(subIdSet.size() > 0){
                    spcList = [SELECT id, name, PublicationCode__c , Zuora__Subscription__c, Zuora__Subscription__r.Order_Line_Item_Number_1__c
                               FROM Zuora__SubscriptionProductCharge__c 
                               WHERE Zuora__Subscription__c IN: subIdSet AND PublicationCode__c != null];
                }
                if(spcList.size() > 0){
                    for(Zuora__SubscriptionProductCharge__c newSPC : spcList){
                        if(!oliIDtoPubCode.containskey(newSPC.Zuora__Subscription__r.Order_Line_Item_Number_1__c)){
                            oliIDtoPubCode.put(newSPC.Zuora__Subscription__r.Order_Line_Item_Number_1__c, new set<string>{newSPC.PublicationCode__c});
                        } else{
                            oliIDtoPubCode.get(newSPC.Zuora__Subscription__r.Order_Line_Item_Number_1__c).add(newSPC.PublicationCode__c);
                        }
                        
                    }
                }
                for(Zuora__SubscriptionProductCharge__c subProdCharge : spcList){
                    if(!oliIDtoPubCode.containsKey(subProdCharge.Zuora__Subscription__r.Order_Line_Item_Number_1__c)){
                        if(subIdPubCodeListMap.containsKey(subProdCharge.Zuora__Subscription__c)){
                            if(subProdCharge.PublicationCode__c != null){
                                subIdPubCodeListMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge.PublicationCode__c);
                            }                            
                        } else {
                            if(subProdCharge.PublicationCode__c != null){
                                subIdPubCodeListMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{subProdCharge.PublicationCode__c});
                            }
                        }
                        pubCodeSet.add(subProdCharge.PublicationCode__c);
                    }else{
                        for(String pubCodeBundle : oliIDtoPubCode.get(subProdCharge.Zuora__Subscription__r.Order_Line_Item_Number_1__c)){
                            if(!subIdPubCodeListMap.containsKey(subProdCharge.Zuora__Subscription__c)){ 
                                subIdPubCodeListMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{pubCodeBundle});
                            }else{
                                subIdPubCodeListMap.get(subProdCharge.Zuora__Subscription__c).add(pubCodeBundle);
                            }
                        }
                    }
                }                                       
                //END: D-3931 11/19/2015 added by Jason A.
                
                for(Id subId : subIdPubCodeListMap.keySet()){
                    String concatPubCodes = '';
                    Integer listSize = subIdPubCodeListMap.get(subId).size();
                    Integer counter = 0;
                    for(String pubCode : subIdPubCodeListMap.get(subId)){
                        concatPubCodes += pubCode;
                        counter++;
                        if(counter < listSize){
                            concatPubCodes += ', ';
                        }                           
                    }
                    subIdPubCodeMap.put(subId, concatPubCodes);
                }
                
                
                
                // END : D-2042 2/19/2015 Alyana Navarro
                
            }                
        } catch (Exception e) {
                  System.debug('Error: ' + e.getMessage());
        }
    }
    
    //<!--START: D-1189 / 01/20/2015 / P.Villarica -->
    class publicationWrapper {        
        
        public string pubName {get; set;}
        public string description {get; set;}
        
        publicationWrapper (string subName, string description) {
            this.pubName = subName;
            this.description = description;
        }
    
    }
    //<!--END: D-1189 / 01/20/2015 / P.Villarica -->
}