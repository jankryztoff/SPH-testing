/**
* Class Name: SP_SendEmailNotifForFailedCCBatch
* @author: Jayson Sarion
* Date: 
* Requirement/Project Name: CRSM Project
* @description Batch Apex Class to retrieve Failed Credit Card Payments and send Notifications 
* to the Subscriber via Email.
*/
// START 05/12/2015 D-2669 J. Sarion - Added AllowCallouts
//START D-3660 LISEN 10/14/2015 - Enable on demand batch
global class SP_SendEmailNotifForFailedCCBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
//END D-3660 LISEN 10/14/2015 - Enable on demand batch
    // END 05/12/2015 D-2669 J. Sarion - Added AllowCallouts
    
    //START D-3660 LISEN 10/08/2015 - Enable on demand batch
    //START D-3952 Gdelrosario 19/11/15 : updated the ref date to yesterday
    //Date referenceDate = Date.Today();
    //Start D-3931 VPernicia: set to null
    Date referenceDate = null;
    //End D-3931 VPernicia: set to null
    //END D-3952 Gdelrosario 19/11/15 : updated the ref date to yesterday
    List<Id> ids = null;
    Boolean isApexJobSuccessful = true;
    
    global SP_SendEmailNotifForFailedCCBatch(){
    }
    
    global SP_SendEmailNotifForFailedCCBatch(Date batchRunDate){
        referenceDate = batchRunDate;
    }
    
    global SP_SendEmailNotifForFailedCCBatch(List<Id> ids){
        this.ids = ids;
    }
    //END D-3660 LISEN 10/08/2015 - Enable on demand batch
    
    /* @description Called at the beginning of the apex job to collect the objects    
    * to be passed to the execute method    
    * @param bc - predefined parameter     
    * @return list of objects from External Payment Object    
    */   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //START D-3660 LISEN 10/08/2015 - Enable on demand batch
        
        if(ids != null){
            //Start UD-3862 22-Feb-2016 Added By S.Puli
            return Database.getQueryLocator([SELECT Id, Payment_amount__c, Expiration_Date__c, Billing_Contact_email__c, Billing_Account__c,
                                             Billing_Account__r.Billing_Contact__r.FirstName, Billing_Account__r.Billing_Contact__r.LastName,
                                             Billing_Account__r.Zuora__Account__r.Id, Billing_Account__r.Billing_Contact__r.Address__r.Block_House_Number__c,
                                             //Start UD-3139 VPernicia 10/22/15 
                                             //Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Street_Name__c, 
                                             Account_Name__c,
                                             //End UD-3139 VPernicia 10/22/15 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.id,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Level_Number__c, Billing_Account__r.Billing_Contact__r.MailingCountry, 
                                             Billing_Account__r.Billing_Contact__r.recordtype.name, Billing_Account__r.Billing_Contact__r.Address__r.Unit_Number__c,
                                             //Start UD-3139 VPernicia 10/22/15 
                                             //Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Building_Name__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Country_Name__c,
                                             //End UD-3139 VPernicia 10/22/15  
                                             Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Name, Billing_Account__r.Zuora__Account__r.AccountNumber, 
                                             Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c, Transaction_amount__c,
                                             Billing_Account__r.Zuora__AccountNumber__c, Payment_Method__c, Payment_Date__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Airline_Number__c, Billing_Account__r.Billing_Contact__r.Address__r.City__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_1__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_1__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_2__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_2__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Address_3__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_4__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.Department__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.recordtype.name,
                                             Billing_Account__r.LastModifiedById, Billing_Account__r.Billing_Contact__c,
                                             //START MMallorca D-3722 05/11/2015 Added address fields for Internal Address Type    
                                             Billing_Account__r.Billing_Contact__r.Address__r.City__r.Country__r.Country_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.City__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.City__r.City_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__r.Name,
                                             Sold_To_Contact_Name__r.HomePhone__c, Sold_To_Contact_Name__r.Office_Number__c, Sold_To_Contact_Name__r.Mobile_Number__c
                                             
                                             //START MMallorca D-3722 05/11/2015 Added address fields for Internal Address Type  
                                             FROM External_Payment__c
                                             WHERE Transaction_Type__c = 'F' AND Payment_Method__c = 'Credit Card' AND Id IN :ids AND (Billing_Contact_email__c != null AND Billing_Contact_email__c != '')]);
        
        //Start D-3931 VPernicia: additional condition, Change Refdate to yestrday
        }else if (referenceDate != null){
            
            return Database.getQueryLocator([SELECT Id, Payment_amount__c, Expiration_Date__c, Billing_Contact_email__c, Billing_Account__c,
                                             Billing_Account__r.Billing_Contact__r.FirstName, Billing_Account__r.Billing_Contact__r.LastName,
                                             Billing_Account__r.Zuora__Account__r.Id, Billing_Account__r.Billing_Contact__r.Address__r.Block_House_Number__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Street_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Country_Name__c,
                                             Account_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.id,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Level_Number__c, Billing_Account__r.Billing_Contact__r.MailingCountry, 
                                             Billing_Account__r.Billing_Contact__r.recordtype.name, Billing_Account__r.Billing_Contact__r.Address__r.Unit_Number__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Building_Name__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Name, Billing_Account__r.Zuora__Account__r.AccountNumber, 
                                             Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c, Transaction_amount__c,
                                             Billing_Account__r.Zuora__AccountNumber__c, Payment_Method__c, Payment_Date__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Airline_Number__c, Billing_Account__r.Billing_Contact__r.Address__r.City__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_1__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_1__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_2__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_2__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Address_3__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_4__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.Department__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.recordtype.name,
                                             Billing_Account__r.LastModifiedById, Billing_Account__r.Billing_Contact__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.City__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.City__r.City_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__r.Name,
                                             Sold_To_Contact_Name__r.HomePhone__c, Sold_To_Contact_Name__r.Office_Number__c, Sold_To_Contact_Name__r.Mobile_Number__c
                                             
                                             FROM External_Payment__c
                                             WHERE Transaction_Type__c = 'F' AND Payment_Method__c = 'Credit Card' AND  CreatedDate = :referenceDate  AND (Billing_Contact_email__c != null AND Billing_Contact_email__c != '')]);
        
        }else{
            //START UD-2556 08/31/2015 added by Jason A./Alyana N.
            // START : D-2039 2/23/2015 Alyana Navarro
            //START D-3370 Added By S.Puli
            //START D-3435 - added Billing_Account__r.Billing_Contact__c 
                return Database.getQueryLocator([SELECT Id, Payment_amount__c, Expiration_Date__c, Billing_Contact_email__c, Billing_Account__c,
                                             Billing_Account__r.Billing_Contact__r.FirstName, Billing_Account__r.Billing_Contact__r.LastName,
                                             Billing_Account__r.Zuora__Account__r.Id, Billing_Account__r.Billing_Contact__r.Address__r.Block_House_Number__c,
                                             //Start UD-3139 VPernicia 10/22/15 
                                             //Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Street_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Country_Name__c,
                                             Account_Name__c,
                                             //End UD-3139 VPernicia 10/22/15 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.id,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Level_Number__c, Billing_Account__r.Billing_Contact__r.MailingCountry, 
                                             Billing_Account__r.Billing_Contact__r.recordtype.name, Billing_Account__r.Billing_Contact__r.Address__r.Unit_Number__c,
                                             //Start UD-3139 VPernicia 10/22/15 
                                             //Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Building_Name__c, 
                                             //End UD-3139 VPernicia 10/22/15  
                                             Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Name, Billing_Account__r.Zuora__Account__r.AccountNumber, 
                                             Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c, Transaction_amount__c,
                                             Billing_Account__r.Zuora__AccountNumber__c, Payment_Method__c, Payment_Date__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Airline_Number__c, Billing_Account__r.Billing_Contact__r.Address__r.City__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_1__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_1__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Flight_Number_2__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_2__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Address_3__c, Billing_Account__r.Billing_Contact__r.Address__r.Address_4__c, 
                                             Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.Department__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__c, Billing_Account__r.Billing_Contact__r.Address__r.recordtype.name,
                                             Billing_Account__r.LastModifiedById, Billing_Account__r.Billing_Contact__c,
                                             //START MMallorca D-3722 05/11/2015 Added address fields for Internal Address Type    
                                             Billing_Account__r.Billing_Contact__r.Address__r.City__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.City__r.City_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Division_Code__r.Name,
                                             Billing_Account__r.Billing_Contact__r.Address__r.Location_Code__r.Name,
                                             Sold_To_Contact_Name__r.HomePhone__c, Sold_To_Contact_Name__r.Office_Number__c, Sold_To_Contact_Name__r.Mobile_Number__c
                                             
                                             //START MMallorca D-3722 05/11/2015 Added address fields for Internal Address Type 
                                             FROM External_Payment__c
                                             WHERE Transaction_Type__c = 'F' AND Payment_Method__c = 'Credit Card' AND  CreatedDate = YESTERDAY  AND (Billing_Contact_email__c != null AND Billing_Contact_email__c != '')]);
            //End D-3931 VPernicia: additional condition, Change Refdate to yestrday changed to TODAY from YESTERDAY
            //END D-3435 - added Billing_Account__r.Billing_Contact__c
            //END UD-2556 08/31/2015 added by Jason A./Alyana N.
            //END D-3370 Added By S.Puli
            // END : D-2039 2/23/2015 Alyana Navarro
            //End UD-3862 22-Feb-2016 Added By S.Puli
           }
        //END D-3660 LISEN 10/08/2015 - Enable on demand batch for recovery
    }       
    
    /* @description Executes the business logic and send an Email Notification to the Subscriber   
* @param bc - predefined parameter  
* @param scope - a list of sObjects from the initial database query     
* @return void        
*/ 
    global void execute(Database.BatchableContext BC, List<External_Payment__c> scope) {
        //START D-3660 LISEN 10/08/2015 - Enable on demand batch for recovery
        Logger logger = new Logger(SP_SendEmailNotifForFailedCCBatch.class.getName(), 'SP014', BC.getJobID());
        Boolean emailIsError = false; // START-END D-4016 Gdelrosario 4/12/2015 : added varible for logger
        Savepoint sp = Database.setSavepoint();
        try{
            EmailTemplate emailTemplate = [SELECT HtmlValue, subject FROM EmailTemplate WHERE Name = 'Credit Card Failure'];
            Map<String, String> extMAP = new Map<String, String>();
            //START D-4016 Gdelrosario 4/12/2015 : added varible for logger
            String emailAddresses = '';
            String errorMessage = '';
            // END D-4016 Gdelrosario 4/12/2015 : added varible for logger
            // START : D-2039 2/23/2015 Alyana Navarro
            String barcode;
            String startDate = '';
            List<String> monthName = new List<String>{'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'};
                List<String> fullMonthName = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
                    Set<Id> billAccountPostalIdSet = new Set<Id>();
            List<Attachment> attList = new List<Attachment>();
            //Map<Id, String> postalCodeBarcodeMap = new Map<Id, String>();
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
            List<Messaging.SingleEmailMessage> emailsLIST = new List<Messaging.SingleEmailMessage>();
            List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>();
            List<Messaging.Email> allMails = new List<Messaging.Email>();
            List<Publication__c> pubList = new List<Publication__c>();
            Messaging.SingleEmailMessage mail;
            Set<Id> acctId = new Set<Id>();
            Set<String> pubCodeSet = new Set<String>();
            String pubConcatenate;
            // END : D-2039 2/23/2015 Alyana Navarro
            String oldValue, actualValue, fieldName, objName;
            Integer startIndex;
            Integer endIndex;
            
            //Start UD-3139 VPernicia 10/22/15 
            string HomeNumber = '';
            string OfficeNumber = '';
            string MobileNumber = '';
            //End UD-3139 VPernicia 10/22/15 
            
            //START: UD-2416 19-Aug-2015 Added By S.Puli
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
            //END: UD-2416 19-Aug-2015 Added By S.Puli
            for (External_Payment__c ext :scope) {
                // START : D-2039 3/23/2015 Alyana Navarro
                //Start UD-3139 VPernica 10/22/15
                acctId.add(ext.Billing_Account__c); //START/END D-3435 - gets the billing contact instead of the billing account
                //End UD-3139 VPernica 10/22/15
                if(ext.Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.id != null){
                    billAccountPostalIdSet.add(ext.Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.id);
                }
                // END : D-2039 3/23/2015 Alyana Navarro
            }
            // START : D-2039 2/23/2015 Alyana Navarro  
            if(billAccountPostalIdSet.size() > 0){
                attList = [SELECT Id, ParentId FROM Attachment WHERE ParentId IN: billAccountPostalIdSet ];
            }
            
            //Start UD-3139 VPernica 10/22/15
            list<id> listSubID = new list<id>();
            list<string> listInvoiceID = new list<string>();
            map<id,string> mapInvoice =  new map<id,string>();
            //START D-3931 11/19/2015 added by Jason A.
            list<Zuora__Subscription__c> newsubsList = new List<Zuora__Subscription__c>();
            set<id> newsubsSet = new set<id>();
            map<id, set<string>> oliIDtoPubCode = new map<id, set<string>>();
            //START UD-3187 Gdelrosario 26/11/15 : change to query to look for old subscription or new subscription
            //START D-4016 Gdelrosario 3/12/15 : remove the proposed solution to pick up old subscriptions
            /*List<Zuora__Subscription__c> checkOldSub = new List<Zuora__Subscription__c>();
            
             checkOldSub = [SELECT Id, Name, Zuora__Account__c 
                                FROM Zuora__Subscription__c 
                                    WHERE Zuora__CustomerAccount__c IN : acctId];
            system.debug('gddr >>checkOldSub '+ checkOldSub);
            system.debug('gddr >>checkOldSub '+ checkOldSub.size() );
            //START D-3931 Gdelrosario : remove if condition
            //if(checkOldSub.size() > 0){   
                 
                for(Zuora__Subscription__c oldSub : checkOldSub){
                         listSubID.add(oldSub.Id);
                         
                }
            */
            // }else{
            //END  D-4016 Gdelrosario 3/12/15 : remove the proposed solution to pick up old subscriptions      
            //START D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
            Map<id,id> realBillAcctToSUBlist = new Map<id,id>();
            Map<id,List<Zuora__Subscription__c>> realBillAcctToSUBlist2 = new Map<id,List<Zuora__Subscription__c>>();
            Map<string,id> invBillingAcct = new Map<string,id>();

                for (Zuora__ZInvoice__c invRecord: [SELECT id, Zuora__Zuora_Id__c, createddate, Zuora__BillingAccount__c from Zuora__ZInvoice__c where Zuora__BillingAccount__c in: acctId order by createddate asc ]){
                    mapInvoice.put(invRecord.Zuora__BillingAccount__c, invRecord.Zuora__Zuora_Id__c);
                       
                    invBillingAcct.put(invRecord.Zuora__Zuora_Id__c, invRecord.Zuora__BillingAccount__c);
                }

                for (Invoice_Line_Item__c invItem: [SELECT Subscription__c, Invoice_ID__c from Invoice_Line_Item__c where Invoice_ID__c in: mapInvoice.values()]) {
                    listSubID.add(invItem.Subscription__c);
                    realBillAcctToSUBlist.put(invItem.Subscription__c,invBillingAcct.get(invItem.Invoice_ID__c));
                }    

       
            //END D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
            // } 
             //END D-3931 Gdelrosario : remove if condition

            //END UD-3187 Gdelrosario 26/11/15 : change to query to look for old subscription or new subscription
            if (!acctId.isEmpty()) {
                //START D-3370 Added By S.Puli
                //START D-3435 - changed query - added Contact__c, removed status filter
                newsubsList = [SELECT Id, Name, Zuora__Account__c, Zuora__SubscriptionStartDate__c, Zuora__CustomerAccount__c, Main_Package_1__r.Name, Subscription_Type_1__c, (SELECT Id, PublicationCode__c, Name FROM Zuora__Subscription_Product_Charges__r), Contact__c 
                //Start UD-3139 VPernicia 10/22/15 
                ,Zuora__CustomerAccount__r.Billing_Contact__r.HomePhone__c,
                Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c,
                Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c,
                Order_Line_Item_Number_1__c
                //End UD-3139 VPernicia 10/22/15 
                FROM Zuora__Subscription__c WHERE id IN :listSubID AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION];
                //END D-3435 - changed query - added Contact__c, removed status filter
                //END D-3370 Added By S.Puli
            }
            //end UD-3139 VPernica 10/22/15
            if(newsubsList.size()>0){
                for(Zuora__Subscription__c newSub :newsubsList){
                    if(!newsubsSet.contains(newSub.Order_Line_Item_Number_1__c)){
                        newsubsSet.add(newSub.Order_Line_Item_Number_1__c);
                        subsList.add(newSub);
                    }
                }
            }
            
            for (Zuora__Subscription__c sub :newsubsList) {   //D-3931         
    //END D-3931 11/19/2015 added by Jason A.
                subIdToSubMap.put(sub.Id, sub);
                //START D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                if(realBillAcctToSUBlist2.containsKey(realBillAcctToSUBlist.get(sub.Id))){
                    realBillAcctToSUBlist2.get(realBillAcctToSUBlist.get(sub.Id)).add(sub);
                }else {
                    realBillAcctToSUBlist2.put(realBillAcctToSUBlist.get(sub.Id), new list<Zuora__Subscription__c>{sub});
                }
                //END D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                //START D-3435 - changed query - replaced Billing Account with Contact
                if (billAccIdToSubListMap.containsKey(sub.Zuora__Account__c)) {
                    //Start UD-3139 VPernicia 10/22/15: Change from contact__c to Billing_Contact
                    billAccIdToSubListMap.get(sub.Zuora__Account__c).add(sub);
                    //end UD-3139 VPernicia 10/22/15
                }
                else {
                    //billAccIdToSubListMap = new Map<Id, List<Zuora__Subscription__c>>();
                    //Start UD-3139 VPernicia 10/22/15: Change from contact__c to Billing_Contact
                    billAccIdToSubListMap.put(sub.Zuora__Account__c, new List<Zuora__Subscription__c>{sub});
                    //end UD-3139 VPernicia 10/22/15
                }
                //END D-3435 - changed query - replaced Billing Account with Contact
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
            subdIdToPubMap = new Map<Id, String>();
    //START D-3931 11/19/2015 added by Jason A.
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
                        }
                        else {
                            //subIdToPubNameSetMap = new Map<Id, Set<String>>();
                            subIdToPubNameSetMap.put(sub.Id, new Set<String>{pub.Name});
                        }
                        if(!oliIDtoPubCode.containskey(sub.Order_Line_Item_Number_1__c)){
                            if(subIdPubCodeSetMap.containsKey(sub.Id)){
                                subIdPubCodeSetMap.get(sub.Id).add(pub.Publication_Code__c);
                            } else {
                                subIdPubCodeSetMap.put(sub.Id, new Set<String>{pub.Publication_Code__c});
                            }
                        }else{
                            for(String pubCodeBundle : oliIDtoPubCode.get(sub.Order_Line_Item_Number_1__c)){
                                if(!subIdPubCodeSetMap.containsKey(sub.id)){    
                                    subIdPubCodeSetMap.put(sub.id, new Set<String>{pubCodeBundle});
                                }else{
                                    subIdPubCodeSetMap.get(sub.id).add(pubCodeBundle);
                                }
                            }
    //END D-3931 11/19/2015 added by Jason A.
                        }
                        if (subPubCodeSet.contains(pub.Publication_Code__c) == false) {
                            if (subPubCode == null || subPubCode == '') {
                                subPubCode = pub.Publication_Code__c;
                            }
                            else {
                                subPubCode = subPubCode + '/' + pub.Publication_Code__c;
                            }
                            subPubCodeSet.add(pub.Publication_Code__c);
                        }
                    }
                }
                subdIdToPubMap.put(sub.Id, subPubCode);
            }                       
            
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
            
            if (scope.size() > 0) {               
                for (External_Payment__c ext :scope) {
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
                    String expiryDate = '';
                    extMAP = new Map<String, String>();
                    if (ext.Billing_Contact_email__c != null) {
                        String template = emailTemplate.HtmlValue;
                        String subject = emailTemplate.subject;
                        Integer counter = 0;
                        //START D-3435 - replaced Billing account with Billing Contact
                        if (billAccIdToSubListMap.containsKey(ext.Account_Name__c)) {
                            //START D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                            for (Zuora__Subscription__c sub : realBillAcctToSUBlist2.get(ext.Billing_Account__c)) {
                            //END D-4447 Gdelrosario 26.2.2016 added for filtering of per account per billing account per sub
                                //END D-3435 - replaced Billing account with Billing Contact
                                if (subIdMainPackageMap.containsKey(sub.Id)) {
                                    String subName = subIdMainPackageMap.get(sub.Id);
                                    Date d = sub.Zuora__SubscriptionStartDate__c;
                                    DateTime dt = dateTime.newInstance(d.year(), d.month(), d.day(), 00, 00, 00);
                                    String dts = dt.format('MMM d');
                                    
                                    
                                    
                                    if (subConcatenated == null || subConcatenated == '') {
                                    // START D-4642  GDelrosario added nbsp
                                        subConcatenated = 'Subscription &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; :  ' + subName;
                                    // END D-4642 Gdelrosario added nbsp
                                    }
                                    else {
                                        // START D-4642  GDelrosario addednbsp
                                        subConcatenated = subConcatenated + '<br>' +  '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : ' + subName;
                                        // END D-4642 Gdelrosario addednbsp
                                    }                                                                               
                                    if (Description == null || Description == '') {
                                        //START D-3435 - removed amount
                                        //Start UD-3859 15-Feb-2016 Added by S.Puli
                                        Description = subName + ' Subscription' + '<br>' + 'Account No: ' + (ext.Billing_Account__r.Zuora__Account__r.AccountNumber != null ? ext.Billing_Account__r.Zuora__Account__r.AccountNumber : null) + '/' + (ext.Billing_Account__r.Zuora__AccountNumber__c != null ? ext.Billing_Account__r.Zuora__AccountNumber__c : null) + '<br>' + 'Description: ' + 'SPH ' + subIdStartDate.get(sub.id) + ' ' + /*(pub.Publication_Code__c != null ? pub.Publication_Code__c : '')*/ subIdPubCodeMap.get(sub.id) + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SUB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '<br>' + 'Declined Credit Card: ' + (ext.Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c != null ? ext.Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c : '');
                                        //End UD-3859 15-Feb-2016 Added by S.Puli
                                        //END D-3435 - removed amount
                                    }
                                    else {
                                        //START D-3435 - removed amount
                                        //Start D-4447 1.3.2016 Added by gdelrosario
                                        Description = Description + '<br>' + '<br>' + subName + ' Subscription' + '<br>' + 'Account No: ' + (ext.Billing_Account__r.Zuora__Account__r.AccountNumber != null ? ext.Billing_Account__r.Zuora__Account__r.AccountNumber : null) + '/' + (ext.Billing_Account__r.Zuora__AccountNumber__c != null ? ext.Billing_Account__r.Zuora__AccountNumber__c : null) + '<br>' + 'Description: ' + 'SPH ' + subIdStartDate.get(sub.id) + ' ' + /*(pub.Publication_Code__c != null ? pub.Publication_Code__c : '')*/ subIdPubCodeMap.get(sub.id) + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SUB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '<br>' + 'Declined Credit Card: ' + (ext.Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c != null ? ext.Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c : '');
                                        //END D-4447 1.3.2016 Added by gdelrosario
                                        //END D-3435 - removed amount
                                    }
                                }
                                
                                //Start UD-3862 22-Feb-2016 Added By S.Puli - HomeNumber OfficeNumber MobileNumber
                                HomeNumber = '';
                                OfficeNumber = '';
                                MobileNumber = '';
                                
                                
                                //Start UD-3139 VPernicia 10/22/15
                                if(ext.Sold_To_Contact_Name__r.HomePhone__c != null){
                                    HomeNumber = ext.Sold_To_Contact_Name__r.HomePhone__c;
                                }
                                if(ext.Sold_To_Contact_Name__r.Office_Number__c != null){
                                    OfficeNumber = ext.Sold_To_Contact_Name__r.Office_Number__c;
                                }
                                if(ext.Sold_To_Contact_Name__r.Mobile_Number__c != null){
                                    MobileNumber = ext.Sold_To_Contact_Name__r.Mobile_Number__c;
                                }
                                //End UD-3139 VPernicia 10/22/15
                                //End UD-3862 22-Feb-2016 Added By S.Puli
                            }
                        }
                        
                        mailAddress = '';
                        //START D-3277 Gdelrosario : added for method call of address
                         mailAddress= AddressHelper.formatAddress(ext.Billing_Account__r.Billing_Contact__r,false,false);

                        //END D-3277 Gdelrosario : added for method call of address
                        if (ext.Expiration_Date__c != null) {
                            //Start UD-3139 VPernicia 10/22/15
                            //expiryDate = string.valueOf(ext.Expiration_Date__c.day()) + '.' + string.valueOf(ext.Expiration_Date__c.month()) + '.' + string.valueOf(ext.Expiration_Date__c.year());
                            DateTime Eprdt = ext.Expiration_Date__c;                             
                            expiryDate = Eprdt.format('MM.yyyy');
                            //End UD-3139 VPernicia 10/22/15
                        }
                        extMAP.put(globalvariableclass.FIRST_NAME, ext.Billing_Account__r.Billing_Contact__r.FirstName.toUpperCase());
                        extMAP.put(globalvariableclass.LAST_NAME, ext.Billing_Account__r.Billing_Contact__r.LastName.toUpperCase());
                        extMAP.put(globalvariableclass.ZUORA_ACCOUNTNUMBER, ext.Billing_Account__r.Zuora__Account__r.AccountNumber + '/' + ext.Billing_Account__r.Zuora__AccountNumber__c);  //Start and END D-4447 1.3.2016 Added by gdelrosario
                        extMAP.put(globalvariableclass.MAILINGADDRESS, mailAddress);
                        extMAP.put(globalvariableclass.EXPIRATION_DATE, expiryDate);
                        extMAP.put(globalvariableclass.ZUORA_CREDITCARDMASKNUMBER, ext.Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c);
                        //Start UD-3139 VPernicia 10/22/15
                        extMAP.put(globalvariableclass.PAYMENT_AMOUNT, String.valueOf(ext.Payment_amount__c.setScale(2)));
                        //End UD-3139 VPernicia 10/22/15
                        extMAP.put(globalvariableclass.PAYMENT_DATE, ext.Payment_Date__c.day() + ' ' + fullMonthName[ext.Payment_Date__c.month()-1] + ' ' + ext.Payment_Date__c.year());//String.valueOf(ext.Payment_Date__c));
                        // END : D-2039 2/23/2015 Alyana Navarro
                        //START: UD-2416 19-Aug-2015 Added By S.Puli
                        extMAP.put('baseURL', finalLink);
                        //END: UD-2416 19-Aug-2015 Added By S.Puli
                        
                        //parse notification template body and replace merge fields with actual data
                        while(startIndex != 1) {
                            //template = template.replaceAll('<[^>]+>',' ');
                            startIndex = template.indexOf('{{') + 2;
                            if (startIndex != 1) {
                                endIndex = template.indexOf('}}') + 2;
                                oldValue = template.subString(startIndex - 2, endIndex);
                                String insideValue = template.subString(startIndex, endIndex - 2);
                                if (insideValue.contains('.')) {
                                    String[] values = insideValue.split('\\.');
                                    objName = values[0];
                                    fieldName = values[1];
                                }
                                else {
                                    fieldName = insideValue;
                                }
                                if (fieldName.contains('Today')) {
                                    //Start UD-3139 VPernicia 10/22/15
                                    if (fieldName.contains('7')) {
                                        template = template.replace(oldValue, (DateTime.Now() + 7).format('d MMMM YYYY'));
                                    }
                                    else {
                                        //template = template.replace(oldValue, DateTime.Now().format('d MMMM, YYYY'));
                                        if(Date.Today().day() == 1){
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>st</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        }else if(Date.Today().day() == 2){
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>nd</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        }else if(Date.Today().day() == 3){
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>rd</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        }else if(Date.Today().day() == 21){
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>st</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        }else if(Date.Today().day() == 22){
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>nd</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        }else if(Date.Today().day() == 23){
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>rd</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());   
                                        }else if(Date.Today().day() == 31){
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>st</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        } else {
                                            template = template.replace(oldValue, Date.Today().day() + '<sup>th</sup> ' + fullMonthName[Date.Today().month()-1] + ' ' + Date.Today().year());
                                        }
                                    }
                                    //End UD-3139 VPernicia 10/22/15                                    
                                }
                                else if (fieldName == 'Subscriptions') {
                                    // START : D-2039 2/23/2015 Alyana Navarro
                                    if (subConcatenated == null || subConcatenated == '') {
                                        subConcatenated = 'Subscription:';
                                        template = template.replace(oldValue, subConcatenated);
                                    }
                                    else {
                                        template = template.replace(oldValue, subConcatenated);
                                    }
                                }
                                else if (fieldName == 'Publication') {
                                    if (description == null || description == '') {
                                        //START D-4447 3.1.2016 Gdelrosario
                                        description = 'Account No: ' + (ext.Billing_Account__r.Zuora__Account__r.AccountNumber != null ? ext.Billing_Account__r.Zuora__Account__r.AccountNumber : null) + '/' + (ext.Billing_Account__r.Zuora__AccountNumber__c != null ? ext.Billing_Account__r.Zuora__AccountNumber__c : null) + '<br>' + 'Description:' + '<br>' + 'Declined Credit Card: ' + (ext.Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c != null ? ext.Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c : null);
                                        //END D-4447 3.1.2016 Gdelrosario
                                        template = template.replace(oldValue, description);
                                    }
                                    else {
                                        template = template.replace(oldValue, description);
                                    }
                                    // END : D-2039 2/23/2015 Alyana Navarro
                                }
                                //Start UD-3139 VPernicia 10/22/15
                                else if(fieldName == 'HomeNumber'){
                                    if (HomeNumber != null || HomeNumber != '') {
                                        template = template.replace(oldValue, HomeNumber);
                                    }
                                    else {
                                        template = template.remove(oldValue);
                                    }
                                } else if(fieldName == 'OfficeNumber'){
                                    if (OfficeNumber != null || OfficeNumber != '') {
                                        template = template.replace(oldValue, OfficeNumber);
                                    }
                                    else {
                                        template = template.remove(oldValue);
                                    }
                                } else if(fieldName == 'MobileNumber'){
                                    if (MobileNumber != null || MobileNumber != '') {
                                        template = template.replace(oldValue, MobileNumber);
                                    }
                                    else {
                                        template = template.remove(oldValue);
                                    }
                                }
                                //End UD-3139 VPernicia 10/22/15
                                else if (extMAP.containsKey(fieldName)) {
                                    if (extMAP.get(fieldName) != null) {
                                        actualValue = String.valueOf(extMAP.get(fieldName));
                                        template = template.replace(oldValue, actualValue);
                                    }
                                    else {
                                        template = template.remove(oldValue);
                                    }
                                }                                                                            
                                else if (!extMAP.containsKey(fieldName)){
                                    template = template.remove(oldValue);
                                }                                           
                            }
                            counter++;
                        }
                        //send email to Subscriber
                        addresses = new String[]{ext.Billing_Contact_email__c};
                            mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(addresses);
                        mail.setSubject(subject);
                        mail.setHtmlBody(template);
                        mail.setSaveAsActivity(true);               
                        //START D-3370 Added By S.Puli                      
                        mail.setTargetObjectId(ext.Billing_Account__r.Billing_Contact__c);
                        //END D-3370 Added By S.Puli
                        
                        emailsLIST.add(mail);
                    }
                }
                for (Integer j = 0; j < emailsLIST.size(); j++ ) {
                    allMails.add(emailsLIST.get(j));
                }
                //START D-4016 Gdelrosario 4/12/2015 : added logger for bounce email, if email address is invalid
                //Start D-4015 VPernicia 12/3/15: Add false
                try {
                    Messaging.SendEmailResult[] creditCardEmailResultList = Messaging.sendEmail(allMails, false);  
                    for(Integer counter = 0; counter < creditCardEmailResultList.size(); counter++){
                        if(!creditCardEmailResultList[counter].isSuccess()){
                            emailIsError = true;
                            emailAddresses = '';
                            errorMessage = '';
                        }

                        for(Messaging.SendEmailError emailError : creditCardEmailResultList[counter].getErrors()){
                            errorMessage += '* ' + emailError.getMessage() + '\n';
                        }

                        logger.log(true, 'Email not sent for ' + emailsLIST[counter].toAddresses + '. Errors encountered: \n' + errorMessage);     

                   }
                }catch(Exception e){
                    logger.logBatchFailure(e, scope);
                     emailIsError = true; 
                }
                
                //End D-4015 VPernicia 12/3/15: Add false
            }
        }catch(Exception e){
            Database.rollback(sp);
            logger.logBatchFailure(e, scope);
            emailIsError = true;
        }

        if(emailIsError){
            logger.save();
            isApexJobSuccessful = false;
        }
        //END D-4016 Gdelrosario 4/12/2015 : added logger for bounce email, if email address is invalid
        //END D-3660 LISEN 10/08/2015 - Enable on demand batch for recovery
    }
    
    global void finish(Database.BatchableContext BC) {
        // START 05/12/2015 D-2669 J. Sarion - Move code to BatchJobHelper
        //START D-3660 LISEN 10/08/2015 - Enable on demand batch for recovery
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false); //START-END KRITHIKA DHARMARAJAN 4/17/2015 D-2770
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
        //END D-3660 LISEN 10/08/2015 - Enable on demand batch for recovery
        // END 05/12/2015 D-2669 J. Sarion - Move code to BatchJobHelper
    }
}