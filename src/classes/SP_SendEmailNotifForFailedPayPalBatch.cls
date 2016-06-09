/**
* Class Name: SP_SendEmailNotifForFailedPayPalBatch
* @author: Alyana Navarro
* Date: 4/9/2015
* Requirement/Project Name: SPH Project
* @description Batch Apex Class to retrieve Failed PayPal Payments and send Notifications 
* to the Subscriber via Email.
* @UD-3185/D-3841 Gdelrosario: made changes to sync with letter
**/
   //START: D3730 10/15/2015 Added by Kristine Balaoing - added for exception logging 
//START D-3811 23-Oct-2015 LISEN - fix callout issue
global class SP_SendEmailNotifForFailedPayPalBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
//END D-3811 23-Oct-2015 LISEN - fix callout issue

   /* @description Called at the beginning of the apex job to collect the objects    
    * to be passed to the execute method    
    * @param bc - predefined parameter     
    * @return list of objects from Payment Object    
    */
    //END: D3730 10/15/2015 Added by Kristine Balaoing - added for exception logging 
    //START: D-3730 10/14/2015 Added by Kristine Balaoing - added for batch recovery
    Boolean isApexJobSuccessful = true;
    Set<Id> failedRecs = new Set<Id>();
    Boolean isAdhoc = false;
    //END: D-3730 10/14/2015 Added by Kristine Balaoing
    //START: D3730  10/14/2015 Added by Kristine Balaoing - added for batch recovery
    global SP_SendEmailNotifForFailedPayPalBatch(){
    }
    
    //START D-3952 Gdelrosario : change the variables to external payment
    global SP_SendEmailNotifForFailedPayPalBatch(Set<Id> exPaymentIds){
        this.failedRecs = exPaymentIds;
        this.isAdhoc = true;
    }
    //END D-3952 Gdelrosario : change the variables to external payment

    global Database.QueryLocator start(Database.BatchableContext BC){
        // START : D-3442 8/31/2015 Alyana Navarro
        // START : UD-2615 9/8/2015 Alyana Navarro
        String query = '';
        if(isAdhoc){
            //START D-3952 Gdelrosario  19/11/15 : change the variables to external payment
            query += 'SELECT id, name, Transaction_Amount__c, Transaction_Date__c, Billing_Account__c, Account_Name__c,';
            query += 'Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c, ';
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__c, ';
            query += 'Account_Name__r.AccountNumber, Billing_Account__r.Billing_Contact__r.Address__r.recordtype.name, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Block_House_Number__c, ';
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Level_Number__c, ';
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Unit_Number__c, ';  
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.MailingCountry, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Name, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Airline_Number__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.City__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_1__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_2__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Address_1__c, '; 
            //START D-3722 Gdelrosario 23/10/2015: added to query
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.recordType.developerName,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Street_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Building_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Country_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Code__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__r.Name,';                                         
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.City__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Packing_Code__c,';
         query += 'Billing_Account__r.Billing_Contact__r.HomePhone__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Office_Number__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Mobile_Number__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.City__r.City_Name__c,';
         //END D-3722 Gdelrosario 23/10/2015: added to query
         //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
         query += 'Billing_Account__r.Billing_Contact__r.Email,';
         //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Address_2__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Address_3__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Address_4__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Department__c, Billing_Account__r.Zuora__AccountNumber__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__c, Billing_Account__r.Billing_Contact__r.FirstName, '; 
            query += 'Billing_Account__r.Billing_Contact__r.LastName '; 
            query += 'FROM External_Payment__c '; 
            query += 'WHERE ID IN :failedRecs';
            //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
            
        }else{
            //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
            query += 'SELECT id, name, Transaction_Amount__c, Transaction_Date__c, Billing_Account__c,Account_Name__c,Payment_Type__c, '; //Start UD-3185 Gdelrosario 11/11/15 : added Zuora Account
            query += 'Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c, ';
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__c, ';
            query += 'Account_Name__r.AccountNumber, Billing_Account__r.Billing_Contact__r.Address__r.recordtype.name, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Block_House_Number__c, ';
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Level_Number__c, ';
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Unit_Number__c, ';  
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.MailingCountry, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Name, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Airline_Number__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.City__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_1__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_2__c, '; 
            //START D-3722 Gdelrosario 23/10/2015: added to query
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.recordType.developerName,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Street_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Building_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Country_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Code__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__r.Name,';                                         
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.City__r.Name,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.Packing_Code__c,';
         query += 'Billing_Account__r.Billing_Contact__r.HomePhone__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Office_Number__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Mobile_Number__c,';
         query += 'Billing_Account__r.Billing_Contact__r.Address__r.City__r.City_Name__c,';
         //END D-3722 Gdelrosario 23/10/2015: added to query
         //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
         query += 'Billing_Account__r.Billing_Contact__r.Email,';
         //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Address_1__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Address_2__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Address_3__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Address_4__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Department__c, Billing_Account__r.Zuora__AccountNumber__c, '; 
            query += 'Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__c, Billing_Account__r.Billing_Contact__r.FirstName, '; 
            query += 'Billing_Account__r.Billing_Contact__r.LastName ';    
            query += 'FROM External_Payment__c ';  
            query += 'WHERE Payment_Type__c = \'PayPal\' '; 
            query += 'AND CreatedDate = TODAY AND Billing_Account__r.Zuora__PaymentMethod_Type__c = \'PayPal\' '; // changed YESTERDAY to Today
            //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
        }
        return Database.getQueryLocator(query);
        // END : UD-2615 9/8/2015 Alyana Navarro
        // END : D-3442 8/31/2015 Alyana Navarro
    }
    //END: D-3730 10/14/2015 Added by Kristine Balaoing
    
   /* @description Executes the business logic and send an Email Notification to the Subscriber   
    * @param bc - predefined parameter  
    * @param scope - a list of sObjects from the initial database query     
    * @return void        
    */
    //START: D-3730 10/14/2015 Added by Kristine Balaoing - added for exception logger  
        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
    global void execute(Database.BatchableContext BC, List<External_Payment__c> scope) {
        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
        
        Logger logger = new Logger(SP_SendEmailNotifForFailedPayPalBatch.class.getName(), 'SP051', BC.getJobID());
        
        Boolean emailIsError = false; // START END D-4016 Gdelrosario 4/12/2015 : added varible for logger
        try{
            EmailTemplate emailTemplate = [SELECT HtmlValue, subject FROM EmailTemplate WHERE Name = 'PayPal Template'];                 
            String barcode;
            String startDate = '';
            String pubConcatenate;
            String oldValue;
            //START D-4016 Gdelrosario 4/12/2015 : added varible for logger
            String emailAddresses = '';
            String errorMessage = '';
            // END D-4016 Gdelrosario 4/12/2015 : added varible for logger
            String actualValue;
            String fieldName;
            String objName;
            Integer startIndex;
            Integer endIndex;
            Messaging.SingleEmailMessage mail;
            Set<Id> acctId = new Set<Id>();
            Set<Id> billAccountPostalIdSet = new Set<Id>();         
            Set<String> pubCodeSet = new Set<String>();
            List<String> monthName = new List<String> {
                'JAN', 
                'FEB', 
                'MAR', 
                'APR', 
                'MAY', 
                'JUN', 
                'JUL', 
                'AUG', 
                'SEP', 
                'OCT', 
                'NOV', 
                'DEC'
            };
            List<String> fullMonthName = new List<String> {
                'January', 
                'February', 
                'March', 
                'April', 
                'May', 
                'June', 
                'July', 
                'August', 
                'September', 
                'October', 
                'November', 
                'December'
            };
            
            // START : D-3468 9/1/2015 Alyana Navarro
            Map<Integer, String> dayNumberText = new Map<Integer, String>{
                1 => 'st',
                2 => 'nd',
                3 => 'rd',
                21 => 'st',
                22 => 'nd',
                23 => 'rd',
                31 => 'st'
            };
            // END : D-3468 9/1/2015 Alyana Navarro
            List<Messaging.SingleEmailMessage> emailsLIST = new List<Messaging.SingleEmailMessage>();
            List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>();
            List<Messaging.Email> allMails = new List<Messaging.Email>();
            List<Publication__c> pubList = new List<Publication__c>();
            Map<String, String> paymentMAP = new Map<String, String>();  
            Map<Id, Set<String>> subIdToPubNameSetMap = new Map<Id, Set<String>>();
            Map<String, Publication__c> pubIdToPubMap = new Map<String, Publication__c>();
            Map<String, Publication__c> pubNameToPubMap = new Map<String, Publication__c>();
            Map<Id, String> subdIdToPubMap = new Map<Id, String>();
            Map<Id, Zuora__Subscription__c> subIdToSubMap = new Map<Id, Zuora__Subscription__c>();
            Map<Id, List<Zuora__Subscription__c>> billAccIdToSubListMap = new Map<Id, List<Zuora__Subscription__c>>();
            Map<Id, String> subIdPubCodeMap = new Map<Id, String>();
            Map<Id, Set<String>> subIdPubCodeSetMap = new Map<Id, Set<String>>();
            Map<Id, String> subIdMainPackageMap = new Map<Id, String>();
            Map<Id, String> subIdStartDate = new Map<Id, String>();
            //START UD-2632 Gdelrosario : added for change in query
            Map<id,string> mapInvoice =  new map<id,string>();
            List<string> listInvoiceID = new list<string>();
            List<id> listSubID = new list<id>();
            //START D-3930 11/23/2015 added by Jason A.
            //START UD-3187 Gdelrosario 26/11/15 : instantiated the code for new subscriptions
            //List<Zuora__Subscription__c> checkOldSub = new List<Zuora__Subscription__c>(); //START D-4016 Gdelrosario : removed the proposed solution
            //END UD-3187 Gdelrosario 26/11/15 : instantiated the code for new subscriptions
            map<id, set<string>> oliIDtoPubCode = new map<id, set<string>>();
            //END D-3930 11/23/2015 added by Jason A.
            //Start D-3841 Gdelrosario 10/29/15 
            string HomeNumber = '';
            string OfficeNumber = '';
            string MobileNumber = '';
            //End D-3841 Gdelrosario 10/29/15 

            
            //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
            //START UD-3187 Gdelrosario 26/11/15 : instantiated the code for new subscriptions
            //START D-4016 Gdelrosario : removed the proposed solution

                for (External_Payment__c expayment :scope) {
                   
                    acctId.add(expayment.Billing_Account__c);
                   
                    if(expayment.Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__c != null){
                        billAccountPostalIdSet.add(expayment.Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__c);
                    }                
                }
            
                //START D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                    Map<id,id> realBillAcctToSUBlist = new Map<id,id>();
                    Map<id,List<Zuora__Subscription__c>> realBillAcctToSUBlist2 = new Map<id,List<Zuora__Subscription__c>>(); //map to get the subscription records not ID
                    Map<string,id> invBillingAcct = new Map<string,id>();
                    for (Zuora__ZInvoice__c invRecord: [SELECT id, Zuora__Zuora_Id__c, createddate, Zuora__BillingAccount__c from Zuora__ZInvoice__c where Zuora__BillingAccount__c in: acctId order by createddate asc ]){
                        mapInvoice.put(invRecord.Zuora__BillingAccount__c, invRecord.Zuora__Zuora_Id__c);
                        invBillingAcct.put(invRecord.Zuora__Zuora_Id__c, invRecord.Zuora__BillingAccount__c);
                         
                    }
                    //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                    for (Invoice_Line_Item__c invItem: [select Subscription__c, Invoice_ID__c from Invoice_Line_Item__c where Invoice_ID__c in: mapInvoice.values()]) {
                        listSubID.add(invItem.Subscription__c);
                        realBillAcctToSUBlist.put(invItem.Subscription__c,invBillingAcct.get(invItem.Invoice_ID__c));   
                    } 

                //END D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub  
               // }                    
              //END D-3931 Gdelrosario : remove if condition
                //END D-4016 Gdelrosario : removed the proposed solution
            
            //END UD-3187 Gdelrosario 26/11/15 : instantiated the code for new subscriptions
            // START : D-3468 9/1/2015 Alyana Navarro
             //Start D-3841 Gdelrosario 10/29/15 
            //START D-3930 11/23/2015 added by Jason A.
            if (!acctId.isEmpty()) {
                subsList = [SELECT Id, Name, Zuora__Account__c, Zuora__SubscriptionStartDate__c, Zuora__CustomerAccount__c,
                                    Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c,
                                    Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c,
                                    Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c,
                                    Main_Package_1__r.Name, Order_Line_Item_Number_1__c,
                            (SELECT Id, PublicationCode__c, Name FROM Zuora__Subscription_Product_Charges__r) 
                            FROM Zuora__Subscription__c 
                            WHERE id IN :listSubID AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION];
            }
            //END D-3930 11/23/2015 added by Jason A.
             //END D-3841 Gdelrosario 10/29/15 
        //END UD-2632 Gdelrosario : added for change in query
            // END : D-3468 9/1/2015 Alyana Navarro
            for (Zuora__Subscription__c sub :subsList) {              
                subIdToSubMap.put(sub.Id, sub);
                //START D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                if(realBillAcctToSUBlist2.containsKey(realBillAcctToSUBlist.get(sub.Id))){
                    realBillAcctToSUBlist2.get(realBillAcctToSUBlist.get(sub.Id)).add(sub);
                }else {
                    realBillAcctToSUBlist2.put(realBillAcctToSUBlist.get(sub.Id), new list<Zuora__Subscription__c>{sub});
                }
                //END D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                if (billAccIdToSubListMap.containsKey(sub.Zuora__Account__c)) {
                    billAccIdToSubListMap.get(sub.Zuora__Account__c).add(sub);
                }
                else {
                    //billAccIdToSubListMap = new Map<Id, List<Zuora__Subscription__c>>();
                    billAccIdToSubListMap.put(sub.Zuora__Account__c, new List<Zuora__Subscription__c>{sub});
                }
				
                for (Zuora__SubscriptionProductCharge__c spc :sub.Zuora__Subscription_Product_Charges__r) {
                    if (spc.PublicationCode__c != null) {
                        pubCodeSet.add(spc.PublicationCode__c);
                    }
                }
            }
			
            if (!pubCodeSet.isEmpty()) {
                pubList = [SELECT Id, Name, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN :pubCodeSet];
            }
            
            for (Publication__c pub :pubList) {
                pubIdToPubMap.put(pub.Publication_Code__c, pub);
                pubNameToPubMap.put(pub.Name, pub);
            }
            //START D-3930 11/23/2015 added by Jason A.
            set<id> subToOLI = new set<id>();
            subdIdToPubMap = new Map<Id, String>();
            
            List<Zuora__SubscriptionProductCharge__c> spclist = new List<Zuora__SubscriptionProductCharge__c>();
            if(listSubID.size()>0){
                spclist = [SELECT id, name, PublicationCode__c , Zuora__Subscription__c, Zuora__Subscription__r.Order_Line_Item_Number_1__c
                                       FROM Zuora__SubscriptionProductCharge__c 
                                       WHERE Zuora__Subscription__c IN: listSubID AND PublicationCode__c != null];
            }
            
            if(spclist.size() > 0){
                for(Zuora__SubscriptionProductCharge__c newSPC : spclist){
                    if(!oliIDtoPubCode.containskey(newSPC.Zuora__Subscription__r.Order_Line_Item_Number_1__c)){
                        oliIDtoPubCode.put(newSPC.Zuora__Subscription__r.Order_Line_Item_Number_1__c, new set<string>{newSPC.PublicationCode__c});
                    } else{
                        oliIDtoPubCode.get(newSPC.Zuora__Subscription__r.Order_Line_Item_Number_1__c).add(newSPC.PublicationCode__c);
                    }
                    
                }
            }
            
            for (Zuora__Subscription__c sub :subsList) {
                if(!subToOLI.contains(sub.Order_Line_Item_Number_1__c)){
                    subToOLI.add(sub.Order_Line_Item_Number_1__c);
                    Set<String> subPubCodeSet = new Set<String>();
                    String subPubCode = '';                
                    if(sub.Main_Package_1__r.Name != null){
                        subIdMainPackageMap.put(sub.id, sub.Main_Package_1__r.Name);
                    }               
                    startDate = '';
                    startDate += monthName[sub.Zuora__SubscriptionStartDate__c.month() - 1];
                    startDate += String.valueOf(sub.Zuora__SubscriptionStartDate__c.year()).substring(2, 4);
                    subIdStartDate.put(sub.id, startDate);
                    for (Zuora__SubscriptionProductCharge__c spc :sub.Zuora__Subscription_Product_Charges__r) {
                        Publication__c pub;
                        if (pubIdToPubMap.containsKey(spc.PublicationCode__c)) {
                            pub = pubIdToPubMap.get(spc.PublicationCode__c);
                            
                            if (subIdToPubNameSetMap.containsKey(sub.Id)) {
                                subIdToPubNameSetMap.get(sub.Id).add(pub.Name);
                            } else {
                                subIdToPubNameSetMap.put(sub.Id, new Set<String>{pub.Name});
                            }
                            
                            if(oliIDtoPubCode.containsKey(sub.Order_Line_Item_Number_1__c)){
                                for(String pubBundleString : oliIDtoPubCode.get(sub.Order_Line_Item_Number_1__c)){
                                    if(subIdPubCodeSetMap.containsKey(sub.Id)){
                                        subIdPubCodeSetMap.get(sub.Id).add(pubBundleString);
                                    } else {
                                        subIdPubCodeSetMap.put(sub.Id, new Set<String>{pubBundleString});
                                    }
                                }
                            } else {
                                for(String pubCodeBundle : oliIDtoPubCode.get(sub.Order_Line_Item_Number_1__c)){
                                    if(!subIdPubCodeSetMap.containsKey(sub.id)){    
                                        subIdPubCodeSetMap.put(sub.id, new Set<String>{pubCodeBundle});
                                    }else{
                                        subIdPubCodeSetMap.get(sub.id).add(pubCodeBundle);
                                    }
                                }
                            }
                            
                            if (subPubCodeSet.contains(pub.Publication_Code__c) == false) {
                                if (subPubCode == null || subPubCode == '') {
                                    subPubCode = pub.Publication_Code__c;
                                } else {
                                    subPubCode = subPubCode + '/' + pub.Publication_Code__c;
                                }
                                subPubCodeSet.add(pub.Publication_Code__c);
                            }
                        }
                    }
                
                    subdIdToPubMap.put(sub.Id, subPubCode);
                }
            }
            //END D-3930 11/23/2015 added by Jason A.            
            for(Id subId : subIdPubCodeSetMap.keySet()){
                String concatPubCodes = '';
                Integer listSize = subIdPubCodeSetMap.get(subId).size();
                Integer counter = 0;
                for(String pubCode : subIdPubCodeSetMap.get(subId)){
                    concatPubCodes += pubCode;
                    counter++;
                    if(counter < listSize){
                        concatPubCodes += ', ';
                    }
                }
                subIdPubCodeMap.put(subId, concatPubCodes);
            }
            //START  MMallorca UD-3214 06/11/2015 Get the SPH Logo for Email Template
            List<Document> sphLogoDoc = [Select Id, Name From Document Where Name = :ConstantsSLB.getOther('SPH Logo v2') Limit 1];
            
            string linkForLogo1 = '';
            string linkForLogo2 = '';
            string linkForLogo3 = '';
            string linkForLogo4 = '';
            string finalLink = '';
            if(sphLogoDoc.size()>0){
                linkForLogo1 = string.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
                linkForLogo2 = '/servlet/servlet.ImageServer?id=';
                linkForLogo3 = sphLogoDoc[0].Id + '&oid=';
                linkForLogo4 = string.valueOf(Userinfo.getOrganizationId());
                finalLink = linkForLogo1 + linkForLogo2 + linkForLogo3 + linkForLogo4;
            }
            //END MMallorca UD-3214 06/11/2015 Get the SPH Logo for Email Template
            if (scope.size() > 0) {
                //STARt D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                for (External_Payment__c expayment :scope) {
                    system.debug('gio payment zuora:'+ expayment.Account_Name__c); 
                //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                    startIndex = 0;
                    endIndex = 0;
                    oldValue = '';
                    actualValue = '';
                    fieldName = '';
                    objName = '';
                    String subConcatenated = '';
                    String description = '';
                    String[] addresses;
                    String mailAddress = '';
                    //String expiryDate = '';
                    paymentMAP = new Map<String, String>();
                    //STARt D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                    //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                    if (expayment.Billing_Account__r.Billing_Contact__r.Email != null) {
                    //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                    //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                        String template = emailTemplate.HtmlValue;
                        String subject = emailTemplate.subject;
                        Integer counter = 0;
                        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                        if (billAccIdToSubListMap.containsKey(expayment.Account_Name__c)) {
                            //START D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                            for (Zuora__Subscription__c sub : realBillAcctToSUBlist2.get(expayment.Billing_Account__c)) {
                            //END D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                                //START UD-3187 Gdelrosario 26/11/15 : instantiated the code for new subscriptions
                                HomeNumber = '';
                                OfficeNumber = '';
                                MobileNumber = '';
                                //END UD-3187 Gdelrosario 26/11/15 : instantiated the code for new subscriptions
                        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment                                   
                                if (subIdMainPackageMap.containsKey(sub.Id)) {
                                    String subName = subIdMainPackageMap.get(sub.Id);                                    
                                    Date d = sub.Zuora__SubscriptionStartDate__c;
                                    DateTime dt = dateTime.newInstance(d.year(), d.month(), d.day(), 00, 00, 00);
                                    String dts = dt.format('MMM d');
                                    
                    // START : UD-2632;UD-2624 9/9/2015 Alyana Navarro
                                    if (subConcatenated == null || subConcatenated == '') {
                                        subConcatenated = 'Subscription&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;&nbsp;: ' + subName;
                                    } else {
                                        subConcatenated = subConcatenated + '<br>' +  '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : ' + subName;
                                    }
                                    // START : UD-2615 9/8/2015 Alyana Navarro
                                    if (Description == null || Description == '') {
                                        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                                        //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                                        //START UD-3340 Gdelrosario 1/12/15 : added set scale to 2 for two decimal places
                                        Description = 'Subscription&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp; : ' +subName   + '<br>' 
                                        + 'Account No&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;: ' + (expayment.Account_Name__r.AccountNumber != null ? expayment.Account_Name__r.AccountNumber : null) + '/' 
                                        + (expayment.Billing_Account__r.Zuora__AccountNumber__c != null ? expayment.Billing_Account__r.Zuora__AccountNumber__c : null) + '<br>' 
                                        + 'Description&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;: ' + 'SPH ' + subIdStartDate.get(sub.id) + ' ' + subIdPubCodeMap.get(sub.id) + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SUB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&emsp;&emsp;' 
                                        + '($' +  (expayment.Transaction_Amount__c).setScale(2) + ')'+ '<br>' 
                                        + 'PayPal Email Address&emsp;: ' + (expayment.Billing_Account__r.Billing_Contact__r.Email != null ? expayment.Billing_Account__r.Billing_Contact__r.Email : '');
                                    } else {
                                        Description = Description + '<br>' + '<br>' + 'Subscription&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp; : ' + subName + '<br>' 
                                        + 'Account No&emsp;&emsp;&emsp;&emsp;&emsp;: ' + (expayment.Account_Name__r.AccountNumber != null ? expayment.Account_Name__r.AccountNumber : null) + '/' 
                                        + (expayment.Billing_Account__r.Zuora__AccountNumber__c != null ? expayment.Billing_Account__r.Zuora__AccountNumber__c : null) + '<br>' 
                                        + 'Description&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;: ' + 'SPH ' + subIdStartDate.get(sub.id) + ' ' + subIdPubCodeMap.get(sub.id) + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SUB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&emsp;&emsp;' 
                                        + '($' +  (expayment.Transaction_Amount__c).setScale(2) + ')' +'<br>' 
                                        + 'PayPal Email Address&emsp;: ' + (expayment.Billing_Account__r.Billing_Contact__r.Email != null ? expayment.Billing_Account__r.Billing_Contact__r.Email : '');
                                        //END UD-3340 Gdelrosario 1/12/15 : added set scale to 2 for two decimal places
                                        //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                                        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                                    }
                                    // END : UD-2615 9/8/2015 Alyana Navarro
                    // END : UD-2632;UD-2624 9/9/2015 Alyana Navarro
                                }
                                 //Start D-3841 Gdelrosario 10/29/15 
                                if(sub.Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c != null){
                                   HomeNumber = sub.Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c; 
                                }
                                if(sub.Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c != null){
                                    OfficeNumber = sub.Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c;
                                }
                                if(sub.Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c != null){
                                    MobileNumber = sub.Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c;
                                }
                                    
                                    
                                    system.debug('gio tel numbers :'+HomeNumber+','+OfficeNumber+','+MobileNumber); 
                                 //END D-3841 Gdelrosario 10/29/15 
                            }
                        }                        
                        mailAddress = '';                        
                        //START D-3722 Gdelrosario 23/10/2015: changre parameter of address
                        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                        mailAddress= AddressHelper.formatAddress(expayment.Billing_Account__r.Billing_Contact__r,false,false); 
                        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment               
            //END D-3722 Gdelrosario 23/10/2015: changre parameter of address
                        /*if (payment.Expiration_Date__c != null) {
                            expiryDate = string.valueOf(payment.Expiration_Date__c.day()) + '.' + string.valueOf(payment.Expiration_Date__c.month()) + '.' 
                            + string.valueOf(payment.Expiration_Date__c.year());
                        }*/
                        // START : D-3442 8/31/2015 Alyana Navarro
                        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                        if(expayment.Billing_Account__r.Billing_Contact__r.FirstName != null){
                            paymentMAP.put(globalvariableclass.FIRST_NAME, expayment.Billing_Account__r.Billing_Contact__r.FirstName.toUpperCase());
                        }
                        if(expayment.Billing_Account__r.Billing_Contact__r.LastName != null){
                            paymentMAP.put(globalvariableclass.LAST_NAME, expayment.Billing_Account__r.Billing_Contact__r.LastName.toUpperCase());
                        }
                        // END : D-3442 8/31/2015 Alyana Navarro
                        paymentMAP.put(globalvariableclass.ZUORA_ACCOUNTNUMBER, expayment.Account_Name__r.AccountNumber + '/' + expayment.Billing_Account__r.Zuora__AccountNumber__c); // START-END : UD-2615 9/8/2015 Alyana Navarro
                        paymentMAP.put(globalvariableclass.MAILINGADDRESS, mailAddress); 
                        //Start D-3841 Gdelrosario 29/10/15                     
                        paymentMAP.put(globalvariableclass.PAYMENT_AMOUNT, String.valueOf(expayment.Transaction_Amount__c.setScale(2)));
                        //Start D-3841 Gdelrosario 29/10/15
                        paymentMAP.put(globalvariableclass.PAYMENT_DATE, expayment.Transaction_Date__c.day() + ' ' + fullMonthName[expayment.Transaction_Date__c.month()-1] + ' ' + expayment.Transaction_Date__c.year());                        
                        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                        //START  MMallorca UD-3214 06/11/2015 Set Logo link
                        paymentMAP.put('baseURL', finalLink);
                        //END  MMallorca UD-3214 06/11/2015 Set Logo link
                        
                        //parse notification template body and replace merge fields with actual data
                        while(startIndex != 1) {                           
                            startIndex = template.indexOf('{{') + 2;
                            if (startIndex != 1) {
                                endIndex = template.indexOf('}}') + 2;
                                oldValue = template.subString(startIndex - 2, endIndex);
                                String insideValue = template.subString(startIndex, endIndex - 2);
                                fieldName = insideValue;                            
                                /*if (insideValue.contains('.')) {
                                    String[] values = insideValue.split('\\.');
                                    objName = values[0];
                                    fieldName = values[1];
                                } else {
                                    fieldName = insideValue;
                                }*/
                                
                                if (fieldName.contains('Today')) {
                                    if (fieldName.contains('7')) {
                                        template = template.replace(oldValue, (DateTime.Now() + 7).format('d MMMM YYYY')); // START-END : UD-2624 9/8/2015 Alyana Navarro
                                    } else {
                                        // START : D-3468 9/1/2015 Alyana Navarro
                                        //template = template.replace(oldValue, DateTime.Now().format('d MMMM, YYYY'));
                                        if(dayNumberText.containsKey(Date.Today().day())){                                          
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>' + dayNumberText.get((Integer)Date.Today().day()) +'</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        } else {
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>th</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        }
                                        // END : D-3468 9/1/2015 Alyana Navarro
                                    }                                                    
                                } else if (fieldName == 'Subscriptions') {                                                       
                                    if (subConcatenated == null || subConcatenated == '') {
                                        subConcatenated = 'Subscription:';
                                        template = template.replace(oldValue, subConcatenated);
                                        system.debug('>>>>> IN SUB');
                                    } else {
                                        //subConcatenated = 'Subscription:';
                                        template = template.replace(oldValue, subConcatenated);
                                    }
                                } else if (fieldName == 'Publication') {
                                    system.debug('>>>>>description ' + description);
                                    // START : UD-2615 9/8/2015 Alyana Navarro
                    // START : UD-2632;UD-2624 9/9/2015 Alyana Navarro
                                    if (description == null || description == '') {
                                        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                                        //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                                        description = 'Account No&emsp;&emsp;&emsp;&emsp;&emsp;: '  + (expayment.Account_Name__r.AccountNumber != null ? expayment.Account_Name__r.AccountNumber : null) + '/' 
                                        + (expayment.Billing_Account__r.Zuora__AccountNumber__c != null ? expayment.Billing_Account__r.Zuora__AccountNumber__c : null) + '<br>' 
                                        + 'Description&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;:' + '<br>' 
                                        + 'PayPal Email Address&emsp;: ' + (expayment.Billing_Account__r.Billing_Contact__r.Email != null ? expayment.Billing_Account__r.Billing_Contact__r.Email : '');
                                        //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                                        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                                        template = template.replace(oldValue, description);                                        
                                    } else {
                                        //description = 'Account No:' + '<br>' + 'Description:' + '<br>' + 'Declined Credit Card:' + '<br> <br>';
                                        template = template.replace(oldValue, description);
                                    }
                                    // END : UD-2615 9/8/2015 Alyana Navarro                                
                    // END : UD-2632;UD-2624 9/9/2015 Alyana Navarro
                     //START UD-2632 Gdelrosario : added for change in query
                                //Start D-3841 Gdelrosario 10/29/15 
                                } else if(fieldName == 'HomeNumber'){
                                    if (HomeNumber != null || HomeNumber != '') {
                                        template = template.replace(oldValue, HomeNumber);
                                    }else {
                                        template = template.remove(oldValue);
                                    } 
                                } else if(fieldName == 'OfficeNumber'){
                                     if (OfficeNumber != null || OfficeNumber != '') {
                                        template = template.replace(oldValue, OfficeNumber);
                                     }else {
                                        template = template.remove(oldValue);
                                    }
                                } else if(fieldName == 'MobileNumber'){
                                    if (MobileNumber != null || MobileNumber != '') {
                                        template = template.replace(oldValue, MobileNumber);
                                    }else {
                                        template = template.remove(oldValue);
                                    } 
                                //END D-3841 Gdelrosario 10/29/15 
                 //END UD-2632 Gdelrosario : added for change in query
                                } else if(fieldName == 'PayPalEmail'){
                                    //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                                    //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                                    template = template.replace(oldValue, expayment.Billing_Account__r.Billing_Contact__r.Email);
                                    //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                                    //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                                } else if (paymentMAP.containsKey(fieldName)) {
                                    if (paymentMAP.get(fieldName) != null) {
                                        actualValue = String.valueOf(paymentMAP.get(fieldName));
                                        template = template.replace(oldValue, actualValue);
                                    } else {
                                        template = template.remove(oldValue);
                                    }
                                } else if (!paymentMAP.containsKey(fieldName)){
                                    template = template.remove(oldValue);
                                }                                           
                            }
                            counter++;
                        }
                        //send email to Subscriber
                        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                        //START D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                        addresses = new String[]{expayment.Billing_Account__r.Billing_Contact__r.Email};
                        //END D-3943 Gdelrosario 26/11/15 : change the email from default payment method to subscribers(billing contact) email
                        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
                        mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(addresses);
                        mail.setSubject(subject);
                        mail.setHtmlBody(template);
                        mail.setSaveAsActivity(true);   
                        mail.setTargetObjectId(expayment.Billing_Account__r.Billing_Contact__r.Id);
                        

                        emailsLIST.add(mail);                       
                    }
                }
                for (Integer j = 0; j < emailsLIST.size(); j++ ) {
                    allMails.add(emailsLIST.get(j));
                } 
                //START D-4016 Gdelrosario 4/12/2015 : added logger for bounce email, if email address is invalid              
                //Start D-4015 VPernicia 12/3/15: Add false
                try{
                   Messaging.SendEmailResult[] paypalEmailResultList = Messaging.sendEmail(allMails, false);
                   
                   for(Integer counter = 0; counter < paypalEmailResultList.size(); counter++){
                        if(!paypalEmailResultList[counter].isSuccess()){
                            emailIsError = true;
                            emailAddresses = '';
                            errorMessage = '';
                        }

                        for(Messaging.SendEmailError emailError : paypalEmailResultList[counter].getErrors()){
                            errorMessage += '* ' + emailError.getMessage() + '\n';
                        }

                        logger.log(true, 'Email not sent for ' + emailsLIST[counter].toAddresses + '. Errors encountered: \n' + errorMessage);     

                   }
                }catch(Exception e) {
                    logger.logBatchFailure(e, scope);
                     emailIsError = true;  
                }
                
                //End D-4015 VPernicia 12/3/15: Add false
            }
        }catch(Exception e){
            logger.logBatchFailure(e, scope);
            emailIsError = true;  
        }
        if(emailIsError){
            logger.save();
            isApexJobSuccessful = false;
        }
        
    }
    //END: D-3730 10/14/2015 Added by Kristine Balaoing
     //end D-4016 Gdelrosario 4/12/2015 : added logger for bounce email, if email address is invalid  
    //START: D-3730 10/14/2015 Added by Kristine Balaoing - added for exception logger
    global void finish(Database.BatchableContext BC) {
        
        //START: D- 4265 1-13-2016 Added by Kristine Balaoing - added logger
            Logger loggerFinish; 
            
            if(!Test.isRunningTest()){
            loggerFinish = new Logger('SP_PaypalFailureRequestBatch', 'SP045');
            }
            
            try{
                if(!isApexJobSuccessful){
                    BatchJobHelper.updateJobStatus(BC.getJobId(), false);
                }else{
                    BatchJobHelper.updateJobStatus(BC.getJobId(), true);
                }
            }catch(Exception e){
                loggerFinish.log(e);
                loggerFinish.save();
            }
        //END: D- 4265 1-13-2016 Added by Kristine Balaoing
    }
    //END: D-3730 10/14/2015 Added by Kristine Balaoing
}