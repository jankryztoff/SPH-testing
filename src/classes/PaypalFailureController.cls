/**
* Class Name: PaypalFailureController 
* @author: Alyana Navarro / Jason Abolac / George del rosario
* Date: Sept 11 2015
* Requirement/Project Name: SPH Project
* @description Batch Apex Class to retrieve failed PayPal Payments and send Notifications (PDF)
**/

public class PaypalFailureController {

    //START D-3952 Gdelrosario : change the varibles
    public string exPaymentID;
    //END D-3952 Gdelrosario : change the varibles
    public String address1 {get;set;}
    public String address2 {get;set;}
    public String address3 {get;set;}
    public String address4 {get;set;}
    public String address5 {get;set;}
    public String contactName {get;set;}
    public string billingAccountNum {get;set;}
    public string accountNum {get;set;}
    public decimal paymentAmount {get;set;}
    public string paypalEmail {get;set;}
    public string datetoday {get;set;}
    public string paymentDate {get;set;}
    public string responseDate {get; set;}  
    public List<Zuora__Subscription__c > subscriptionList {get;set;}
    public List<wrapperSubscription> wrapList {get;set;}
    public Map<Id, Set<String>> subToPubcode {get; set;}
    public List<Zuora__SubscriptionProductCharge__c> allSPClist;
    public String barcodeAttId {get; set;}
    public String subAlPackage {get; set;}
    //START UD-2632 : added the variable to dissable static text in the lower env
    public string homeNumber {get;set;}
    public string officeNumber {get;set;}
    public string mobileNumber {get;set;}
    private id invoiceId;
    public List<Invoice_Line_Item__c> invLineItemList;
    public Set<Id> subIdSet;
    //START D-3722 15/10/2015 Gdelrosario: added for variable change in page
    public String finalAddressOutput {get; set;}
    //END D-3722 15/10/2015 Gdelrosario: added for variable change in page
    //END UD-2632 : added the variable to dissable static text in the lower env
    public class wrapperSubscription {
        public String description {get;set;}
        public String mainPackage {get;set;}
    }
    
    public PaypalFailureController(){  
        //START D-3952 Gdelrosario : change the variable to external payment
        exPaymentID = ApexPages.currentPage().getParameters().get('id'); 
        //END D-3952 Gdelrosario : change the variable to external payment  

        //try{
        main();  
        //} catch(Exception e){
        //    system.debug('ERROR: ' + e);
        //}
        
           
    }
    
    public void main() {
    try {
         //START UD-2632 Gdelrosario : added for query
        Set<Id> subscriptionIdSet = new Set<Id>();
        //END UD-2632 Gdelrosario : added for query
        Map <Integer, String> monthName = new Map<Integer, String> {
            1 =>    'JAN', 
            2 =>    'FEB', 
            3 =>    'MAR', 
            4 =>    'APR', 
            5 =>    'MAY', 
            6 =>    'JUN', 
            7 =>    'JUL', 
            8 =>    'AUG', 
            9 =>    'SEP', 
            10 =>   'OCT', 
            11 =>   'NOV', 
            12 =>   'DEC'
        };
        Map<Integer, String> fullMonthName = new Map<Integer, String> {
            1 =>    'January', 
            2 =>    'February', 
            3 =>    'March', 
            4 =>    'April', 
            5 =>    'May', 
            6 =>    'June', 
            7 =>    'July', 
            8 =>    'August', 
            9 =>    'September', 
            10 =>   'October', 
            11 =>   'November', 
            12 =>   'December'
        };              
                    
        Map<Integer, String> dayNumberText = new Map<Integer, String>{
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            21 => 'st',
            22 => 'nd',
            23 => 'rd',
            31 => 'st'
        };
        //START UD-2632 Gdelrosario : change logic for the query invoice -> invoice line item -> subscription
        subscriptionList = new List <Zuora__Subscription__c >();                
        invLineItemList = new List<Invoice_Line_Item__c>();
        //START D-3952 Gdelrosario : removed the querlly in for payment, will change to external payment
        //START D-3930 11/23/2015 added by Jason A.
        set<id> newsubscriptionSet = new set<id>();
        list<Zuora__Subscription__c> newSubscriptionList = new List <Zuora__Subscription__c >();
        map<id, set<string>> oliIDtoPubCode = new map<id, set<string>>();
        //END D-3930 11/23/2015 added by Jason A.
        /*
        Zuora__Payment__c payment = [SELECT id, Name , Zuora__BillingAccount__c, Zuora__BillingAccount__r.Zuora__AccountNumber__c, Zuora__BillingAccount__r.Zuora__Account__r.AccountNumber,
                                    Zuora__Amount__c, Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c, Zuora__EffectiveDate__c
                                    FROM Zuora__Payment__c WHERE id =: paymentID LIMIT 1];
        */
        //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email                            
        External_Payment__c ep = [SELECT id, Name, Sold_To_Contact_Name__r.FirstName, Sold_To_Contact_Name__r.LastName, Billing_Account__c, Billing_Account__r.Zuora__Account__r.AccountNumber,
                                    Billing_Account__r.Zuora__CreditCard_Number__c, Transaction_Date__c, Billing_Account__r.Zuora__AccountNumber__c, Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c,
                                        Billing_Account__r.Billing_Contact__c,Billing_Account__r.Billing_Contact__r.Email, Transaction_Amount__c, Payment_amount__c, Expiration_Date__c, Account_Name__r.AccountNumber
                                            FROM External_Payment__c WHERE Id =: exPaymentID];
        //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email                                    

        //END D-3952 Gdelrosario : removed the querlly in for payment, will change to external payment
        Zuora__ZInvoice__c invList  = [SELECT id, Name, Zuora__Zuora_Id__c, Zuora__BillingAccount__c
                                           FROM Zuora__ZInvoice__c
                                                WHERE  Zuora__BillingAccount__c =: ep.Billing_Account__c 
                                                ORDER BY CreatedDate DESC NULLS FIRST 
                                                LIMIT 1]; 
        
        invLineItemList = [SELECT id, Name, Subscription_Number__c, Subscription_ID__c,Invoice_ID__c,Subscription__c
                                FROM Invoice_Line_Item__c 
                                    WHERE Invoice_ID__c =: invList.Zuora__Zuora_Id__c];  
        subIdSet = new Set<Id>();
        for(Invoice_Line_Item__c inv:invLineItemList){
                subIdSet.add(inv.Subscription__c);
        }
        
        //END UD-2632 Gdelrosario : added forchange logic for the query invoice -> invoice line item -> subscription
         //START D-3722 Gdelrosario 23/10/2015: added to query                           
        subscriptionList = [SELECT Zuora__SubscriptionStartDate__c,Zuora__Account__c, Contact__c, 
                            Zuora__Account__r.AccountNumber, Zuora__Account__r.Name, Contact__r.Address__r.Block_House_Number__c, 
                            Contact__r.Address__r.Level_Number__c, Contact__r.Address__r.Unit_Number__c,
                            Contact__r.Address__r.Building_Name__c, Contact__r.Address__r.Postal_Code__r.Street_Name__c, 
                            Contact__r.Address__r.Country__r.Country_Name__c, Contact__r.Address__r.Postal_Code__r.Name,
                            Contact__r.LastName, Contact__r.FirstName, Main_Package_1__r.Name,
                            Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                            Contact__r.Address__r.Postal_Code__c,
                            Contact__r.Address__r.recordType.developerName, Contact__r.Address__r.Location_Code__r.Location_Name__c,
                            Contact__r.Address__r.Street_Name__c,Contact__r.Address__r.Section_Code__r.Section_Name__c,
                            Contact__r.Address__r.Department__r.Department_Name__c,Contact__r.Address__r.Division_Code__r.Name,
                            Contact__r.Address__r.Company_Code__r.Company_Name__c,Contact__r.Address__r.Address_1__c,Contact__r.Address__r.Address_2__c,
                            Contact__r.Address__r.Address_3__c,Contact__r.Address__r.Address_4__c,Contact__r.Address__r.City__r.City_Name__c,
                            Contact__r.Address__r.Airline_Number__c,Contact__r.Address__r.Flight_Number_1__c,Contact__r.Address__r.Flight_Number_2__c, Name, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                            Contact__r.Address__r.City__r.Country__r.Country_Name__c,Contact__r.Address__r.Packing_Code__c,Contact__r.Address__r.City__r.Name,
                            Contact__r.Address__r.City__c,Contact__r.Address__r.Location_Code__r.Name, Contact__r.Address__r.Company_Code__r.Name,
                            Contact__r.Address__r.Department__r.Name, Contact__r.Address__r.Section_Code__r.Name,Contact__r.Address__r.Country__r.Name,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Email,
                            //START UD-3185 Gdelrosario 30/10/2015: added to query
                            Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c,Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c,
        //START D-3930 11/23/2015 added by Jason A.
                            Order_Line_Item_Number_1__c
                            //END UD-3185 Gdelrosario 30/10/2015: added to query
                            FROM Zuora__Subscription__c  
                            WHERE Id IN: subIdSet
                                AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ];
         //END D-3722 Gdelrosario 23/10/2015: added to query
        for(Zuora__Subscription__c sub : subscriptionList){
            subscriptionIdSet.add(sub.id);
        }
        
        allSPClist = [SELECT id, name, PublicationCode__c, Zuora__Subscription__c, Zuora__Subscription__r.Order_Line_Item_Number_1__c 
                      FROM Zuora__SubscriptionProductCharge__c
                      WHERE Zuora__Subscription__c IN: subscriptionIdSet];
        //END D-3930 11/23/2015 added by Jason A.
        //END UD-2632 Gdelrosario : change logic for the query invoice -> invoice line item -> subscription
        contactName = subscriptionList[0].Contact__r.FirstName + ' ' +  subscriptionList[0].Contact__r.LastName;
        contactName = contactName.toUpperCase();
        //START UD-2632 Gdelrosario : change logic for the query invoice -> invoice line item -> subscription
        homeNumber = subscriptionList[0].Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c;
        officeNumber = subscriptionList[0].Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c;
        mobileNumber = subscriptionList[0].Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c;
        //STARt D-3722 Gdelrosario 23/10/2015: change the parameters of the code
        finalAddressOutput = AddressHelper.formatAddress(subscriptionList[0].contact__r,false,false);
        //END D-3722 Gdelrosario 23/10/2015: change the parameters of the code
        //START D-3952 Gdelrosario : change the variables from payment to external payment
        /*  billingAccountNum = payment.Zuora__BillingAccount__r.Zuora__AccountNumber__c;
            accountNum = payment.Zuora__BillingAccount__r.Zuora__Account__r.AccountNumber;
            paymentAmount = payment.Zuora__Amount__c;
            paypalEmail = payment.Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c;  */
        system.debug('BA : ' + ep.Billing_Account__c);
        billingAccountNum = ep.Billing_Account__r.Zuora__AccountNumber__c;
        accountNum = ep.Billing_Account__r.Zuora__Account__r.AccountNumber;     
        //START UD-3340 Gdelrosario 1/12/15 : added set scale to 2 for two decimal places
        if( ep.Transaction_Amount__c <> null){
            paymentAmount = (ep.Transaction_Amount__c).setScale(2);    
        }   
        //END UD-3340 Gdelrosario 1/12/15 : added set scale to 2 for two decimal places  
        //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
        if(ep.Billing_Account__r.Billing_Contact__r.Email != null){
            paypalEmail = ep.Billing_Account__r.Billing_Contact__r.Email;
        }
        //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
        
        
        //END D-3952 Gdelrosario : change the variables from payment to external payment

        if(dayNumberText.containskey(date.today().day())){
            datetoday = string.valueof(date.today().day() + '<sup>' + dayNumberText.get(date.today().day()) + '</sup> ' + fullMonthName.get(date.today().month()) +' ' + date.today().year()); // START-END : UD-3185 11/2/2015 Gio Del Rosario
        }
        else{
            datetoday = string.valueof(date.today().day() + '<sup>th</sup> ' + fullMonthName.get(date.today().month()) + ' '+ date.today().year());
        }
        //START D-3952 Gdelrosario : will change the payment date
        //paymentDate = payment.Zuora__EffectiveDate__c.day() + ' ' + fullMonthName.get(payment.Zuora__EffectiveDate__c.month()) + ' ' + payment.Zuora__EffectiveDate__c.year();  
        paymentDate = ep.Transaction_Date__c.day() + ' ' + fullMonthName.get(ep.Transaction_Date__c.month()) + ' ' + ep.Transaction_Date__c.year();  
        //END D-3952 Gdelrosario : will change the payment date
        responseDate = string.valueof(date.today().adddays(7).day() + ' ' + fullMonthName.get(date.today().month()) + ' '+ date.today().year());
        //START D-3930 11/23/2015 added by Jason A. 
        subToPubcode = new Map<Id, Set<String>>();
        for(Zuora__SubscriptionProductCharge__c spc: allSPClist){
            //START UD-3185 Gdelrosario : check if pubcode is null
            if(spc.PublicationCode__c != null){
                if(subToPubcode.containsKey(spc.Zuora__Subscription__r.Order_Line_Item_Number_1__c)){
                subToPubcode.get(spc.Zuora__Subscription__r.Order_Line_Item_Number_1__c).add(spc.PublicationCode__c);
                }else {
                    subToPubcode.put(spc.Zuora__Subscription__r.Order_Line_Item_Number_1__c, new Set<String>{spc.PublicationCode__c});
                }
            }  
            //END UD-3185 Gdelrosario : check if pubcode is null
        }   
        wrapList = new list<wrapperSubscription>();
        subAlPackage = '';
         Integer counter = 0;
        //D-3930
        if(subscriptionList.size()>0){
            for(Zuora__Subscription__c newSub :subscriptionList){
                if(!newsubscriptionSet.contains(newSub.Order_Line_Item_Number_1__c)){
                    newsubscriptionSet.add(newSub.Order_Line_Item_Number_1__c);
                    //subscriptionList.add(newSub);
                }
            }
        }
        set<id> ppId = new set<id>();
        for(Zuora__Subscription__c perSub :subscriptionList){
            if(!ppId.contains(perSub.Order_Line_Item_Number_1__c)){
                ppId.add(perSub.Order_Line_Item_Number_1__c);
                subAlPackage += ': ' + perSub.Main_Package_1__r.Name + '<br/>';
                wrapperSubscription wrap = new wrapperSubscription();           
                wrap.description = string.valueof(monthName.get(perSub.Zuora__SubscriptionStartDate__c.month()) + String.valueOf(perSub.Zuora__SubscriptionStartDate__c.year()).substring(2,4)) + ' ';                      
                if(subToPubcode.containsKey(persub.Order_Line_Item_Number_1__c)){
                    for(String pubcode : subToPubcode.get(persub.Order_Line_Item_Number_1__c)){                                    
                            wrap.description += pubcode; 
                            counter++;
                                if(counter < subToPubcode.get(persub.Order_Line_Item_Number_1__c).size()){
                                    wrap.description += ', ';
                                }    
                    }
                }
                wrap.mainPackage = perSub.Main_Package_1__r.Name;

                wrapList.add(wrap);  
            }   
        }
        //END D-3930 11/23/2015 added by Jason A. 
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :subscriptionList[0].Contact__r.Address__r.Postal_Code__c];
        if(attList.size()>0){
            barcodeAttId = attList[0].Id;           
        } else{
            barcodeAttId = null;
        } 
    } catch (Exception e){

    }
                     
    }
    
    /* START D-3722 Gdelrosario : not used code anymore
    public void formatAddress(Contact contactRecord ){

        address1 = '';
        address2 = '';
        address3 = '';
        address4 = '';
        address5 = '';
        
        
        if(contactRecord.Address__r.recordType.developerName == 'Local'){
                    
            String bhN = '';
            String stN = '';
            String lvN = '';
            String unitN = '';
            bhN = contactRecord.Address__r.Block_House_Number__c;
            stN = contactRecord.Address__r.Street_Name__c;
            if(bhN <> null && bhN <> 'null' && bhN <> ''){
                address1 += bhN+' ';
            }
            if(stN <> null && stN <> 'null' && stN <> ''){
                address1 += stN;
            }
            if((bhN <> null && bhN <> 'null' && bhN <> '')||( stN <> null && stN <> 'null' && stN <> '' )){
                address1 += '&nbsp'+'<br/>';
            }
            lvN = contactRecord.Address__r.Level_Number__c;
            unitN = contactRecord.Address__r.Unit_Number__c;
            if(lvN <> null && lvN <> 'null' && lvN <> ''){
                address2 += '#'+lvN;
            }
            if(unitN <> null && unitN <> 'null' && unitN <> ''){
                address2 += '-'+unitN;
            }
            if (address2.length() > 0) { 
                address2 += '&nbsp'+'<br/>'; 
            } 
            if((lvN <> null && lvN <> 'null' && lvN <> '')||( unitN <> null && unitN <> 'null' && unitN <> '' )){
                address2 += ' ';
            }
            if(contactRecord.Address__r.Building_Name__c <> null){
                address3 += contactRecord.Address__r.Building_Name__c;
            }
            if(contactRecord.Address__r.Building_Name__c <> null){
                address3 += '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Country__r.Country_Name__c <> null){
                address4 += contactRecord.Address__r.Country__r.Country_Name__c;
            }
            if(contactRecord.Address__r.Postal_Code__r.Name <> null){
                address4 += ' '+contactRecord.Address__r.Postal_Code__r.Name;
            }
        }

        if(contactRecord.Address__r.recordType.developerName == 'Overseas'){
            if(contactRecord.Address__r.Address_1__c <> null){
                address1 = contactRecord.Address__r.Address_1__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Address_2__c <> null){
                address2 = contactRecord.Address__r.Address_2__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Address_3__c <> null){
                address3 = contactRecord.Address__r.Address_3__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Address_4__c <> null){
                address4 = contactRecord.Address__r.Address_4__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Country__r.Country_Name__c <> null){
                address5 = contactRecord.Address__r.Country__r.Country_Name__c;
            }
        }

        if(contactRecord.Address__r.recordType.developerName == 'Internal'){
            if(contactRecord.Address__r.Section_Code__r.Section_Name__c <> null){
                address1 = contactRecord.Address__r.Section_Code__r.Section_Name__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Department__r.Department_Name__c <> null){
                address2 = contactRecord.Address__r.Department__r.Department_Name__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Division_Code__r.Name <> null){
                address3 = contactRecord.Address__r.Division_Code__r.Name + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Company_Code__r.Company_Name__c <> null){
                address4 = contactRecord.Address__r.Company_Code__r.Company_Name__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Location_Code__r.Location_Name__c <> null){
                address5 = contactRecord.Address__r.Location_Code__r.Location_Name__c;
            }
        }

        if(contactRecord.Address__r.recordType.developerName == 'Airline'){
            if(contactRecord.Address__r.City__r.City_Name__c <> null){
                address1 += (contactRecord.Address__r.City__r.City_Name__c.length() > 40 ? contactRecord.Address__r.City__r.City_Name__c.subString(0,40) : contactRecord.Address__r.City__r.City_Name__c ) ;
                address1 += '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Airline_Number__c <> null){
                address2 = contactRecord.Address__r.Airline_Number__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.Flight_Number_1__c <> null){    
                address3 = contactRecord.Address__r.Flight_Number_1__c + '&nbsp'+'<br/>';
            }   
            if(contactRecord.Address__r.Flight_Number_2__c <> null){
                address4 = contactRecord.Address__r.Flight_Number_2__c + '&nbsp'+'<br/>';
            }
            if(contactRecord.Address__r.City__r.Country__r.Country_Name__c <> null){
                address5 = contactRecord.Address__r.City__r.Country__r.Country_Name__c;
            }
        }
    }*/
}