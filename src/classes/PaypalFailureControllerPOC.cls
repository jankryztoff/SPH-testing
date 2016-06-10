/**
* Class Name: PaypalFailureController 
* @author: Alyana Navarro / Jason Abolac / George del rosario
* Date: Sept 11 2015
* Requirement/Project Name: SPH Project
* @description Batch Apex Class to retrieve failed PayPal Payments and send Notifications (PDF)
**/

public class PaypalFailureControllerPOC {

    public string paymentID;
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
    //END UD-2632 : added the variable to dissable static text in the lower env
    public class wrapperSubscription {
        public String description {get;set;}
        public String mainPackage {get;set;}
    }
    
    public PaypalFailureControllerPOC(){   
        paymentID = ApexPages.currentPage().getParameters().get('id');                  
        //try{
        main();  
        //} catch(Exception e){
        //    system.debug('ERROR: ' + e);
        //}
        
           
    }
    
    public void main() {
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
        
        Zuora__Payment__c payment = [SELECT id, Name , Zuora__BillingAccount__c, Zuora__BillingAccount__r.Zuora__AccountNumber__c, Zuora__BillingAccount__r.Zuora__Account__r.AccountNumber,
                                    Zuora__Amount__c, Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c, Zuora__EffectiveDate__c
                                    FROM Zuora__Payment__c WHERE id =: paymentID LIMIT 1];
        
        Zuora__ZInvoice__c invList  = [SELECT id, Name, Zuora__Zuora_Id__c, Zuora__BillingAccount__c
                                           FROM Zuora__ZInvoice__c
                                                WHERE  Zuora__BillingAccount__c =: payment.Zuora__BillingAccount__c 
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
                            Contact__r.Address__r.City__r.Country__r.Country_Name__c
                            ,Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c
                            ,Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c
                            ,Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c
                            FROM Zuora__Subscription__c  
                            WHERE Id IN: subIdSet
                                AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ];
        for(Zuora__Subscription__c sub : subscriptionList){
            subscriptionIdSet.add(sub.id);
        }
        
        allSPClist = [SELECT id, name, PublicationCode__c, Zuora__Subscription__c 
                      FROM Zuora__SubscriptionProductCharge__c
                      WHERE Zuora__Subscription__c IN: subscriptionIdSet];
        //END UD-2632 Gdelrosario : change logic for the query invoice -> invoice line item -> subscription
        contactName = subscriptionList[0].Contact__r.FirstName + ' ' +  subscriptionList[0].Contact__r.LastName;
        contactName = contactName.toUpperCase();
    //START UD-2632 Gdelrosario : change logic for the query invoice -> invoice line item -> subscription
        homeNumber = subscriptionList[0].Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c;
        officeNumber = subscriptionList[0].Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c;
        mobileNumber = subscriptionList[0].Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c;
        formatAddress(subscriptionList[0].contact__r);
        billingAccountNum = payment.Zuora__BillingAccount__r.Zuora__AccountNumber__c;
        accountNum = payment.Zuora__BillingAccount__r.Zuora__Account__r.AccountNumber;
        paymentAmount = payment.Zuora__Amount__c;
        paypalEmail = payment.Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c;
        
        if(dayNumberText.containskey(date.today().day())){
            datetoday = string.valueof(date.today().day() + '<sup>' + dayNumberText + '</sup> ' + fullMonthName.get(date.today().month()) +' ' + date.today().year());
        }
        else{
            datetoday = string.valueof(date.today().day() + '<sup>th</sup> ' + fullMonthName.get(date.today().month()) + ' '+ date.today().year());
        }
        paymentDate = payment.Zuora__EffectiveDate__c.day() + ' ' + fullMonthName.get(payment.Zuora__EffectiveDate__c.month()) + ' ' + payment.Zuora__EffectiveDate__c.year();  
        responseDate = string.valueof(date.today().adddays(7).day() + ' ' + fullMonthName.get(date.today().month()) + ' '+ date.today().year());
        
        subToPubcode = new Map<Id, Set<String>>();
        for(Zuora__SubscriptionProductCharge__c spc: allSPClist){
            if(subToPubcode.containsKey(spc.Zuora__Subscription__c)){
                subToPubcode.get(spc.Zuora__Subscription__c).add(spc.PublicationCode__c);
            }else {
                subToPubcode.put(spc.Zuora__Subscription__c, new Set<String>{spc.PublicationCode__c});
            }
        }   
        
        wrapList = new list<wrapperSubscription>();
        subAlPackage = '';
        for(Zuora__Subscription__c perSub :subscriptionList){
            subAlPackage += ': ' + perSub.Main_Package_1__r.Name + '<br/>';
            wrapperSubscription wrap = new wrapperSubscription();           
            wrap.description = string.valueof(monthName.get(perSub.Zuora__SubscriptionStartDate__c.month()) + String.valueOf(perSub.Zuora__SubscriptionStartDate__c.year()).substring(2,4));            
            if(subToPubcode.containsKey(persub.id)){
                for(String pubcode : subToPubcode.get(persub.id)){
                    wrap.description += pubcode;
                }
            }
            wrap.mainPackage = perSub.Main_Package_1__r.Name;

            wrapList.add(wrap);         
        }
        
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :subscriptionList[0].Contact__r.Address__r.Postal_Code__c];
        if(attList.size()>0){
            barcodeAttId = attList[0].Id;           
        } else{
            barcodeAttId = null;
        }               
    }
    
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
    }
}