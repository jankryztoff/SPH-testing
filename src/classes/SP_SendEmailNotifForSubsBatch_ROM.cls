/**
* Class Name: SP_SendEmailNotifForSubsRenewalsBatch
* @author: Jayson Sarion
* Date: 
* Requirement/Project Name: CRSM Project
* @description Batch Apex Class to retrieve all subscriptions expiring in two weeks. An email notification will be send 
* to the subscriber for Subscription Renewal Notice.
*/
//START D-2674 06/03/2015 Added by C. Lin - Add AllowsCallouts
global class SP_SendEmailNotifForSubsBatch_ROM implements Database.Batchable<sObject>, Database.AllowsCallouts {
//END D-2674 06/03/2015 Added by C. Lin
   /* @description Called at the beginning of the apex job to collect the objects    
    * to be passed to the execute method    
    * @param bc - predefined parameter     
    * @return list of objects from Account Object    
    */     
    
    List<exception> exceptionList = new List<exception>(); // START-END : D-2204 3/3/2015 Alyana Navarro
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> directRecTypeIds = new Set<Id> {
            ConstantsSLB.getKeyId('Account_Direct Corporate'),
            ConstantsSLB.getKeyId('Account_Direct Individual'),
            ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')
        };
        //START D-2674 06/03/2015 Added by C. Lin - to be removed
        /*
        String query = 'SELECT Id, Name FROM Account WHERE RecordType.Id IN :directRecTypeIds';
        */
        //END D-2674 06/03/2015 Added by C. Lin
        //START D-2674 06/03/2015 Added by C. Lin - update query to get subscriptions
        //START UD-1168 6/17/2015 Added By C. Lin - Added Main_Package_1__r.Name
        //START : D-3125 6/19/2015 Alyana Navarro
        //START UD-1168 07/16/15 RReyes - added in Main_Package_Product_Sub_Type_Mapping__c, is1stPDFGenerated__c, is2ndPDFGenerated__c,is1stNotifEmailSent__c, is2ndNotifEmailSent__c in query. Also changed the condition.
        return Database.getQueryLocator([SELECT Id, Zuora__Account__r.AccountNumber, Subscriber_Contact__r.FirstName, 
                                         Subscriber_Contact__r.LastName, Recipient_Contact__r.Name, Recipient_Contact__r.Account.AccountNumber, 
                                         Zuora__Account__r.Name, Subscriber_Contact__r.Contact_Address_Detail__c, Number_of_Copies__c, 
                                         Subscription_Charge__c, Zuora__Account__c, Recipient_Contact__r.Address__r.Address_Unique_ID__c, 
                                         Subscriber_Contact__r.Email__c, Frequency_1__c, Subscriber_Contact__r.Email_Secondary__c, Product_Code__c, 
                                         Zuora__SubscriptionEndDate__c, Main_Package_1__c, Order_Line_Item_Number_1__c, Main_Package_1__r.Name, 
                                         Contact__r.Address__r.RecordTypeId, Contact__r.Address__r.Block_House_Number__c, 
                                         Contact__r.Address__r.Postal_Code__r.Street_Name__c, Contact__r.Address__r.Level_Number__c, 
                                         Contact__r.Address__r.Unit_Number__c, Contact__r.Address__r.Postal_Code__r.Building_Name__c, 
                                         Contact__r.MailingCountry, Contact__r.Address__r.Postal_Code__r.Name, 
                                         Contact__r.Address__r.Airline_Number__c, Contact__r.Address__r.City__c, 
                                         Contact__r.Address__r.Flight_Number_1__c, Contact__r.Address__r.Flight_Number_2__c, 
                                         Contact__r.Address__r.Address_1__c, Contact__r.Address__r.Address_2__c, Contact__r.Address__r.Address_3__c,
                                         Contact__r.Address__r.Address_4__c, Contact__r.Address__r.Location_Code__c, 
                                         Contact__r.Address__r.Company_Code__c, Contact__r.Address__r.Division_Code__c, 
                                         Contact__r.Address__r.Department__c, Contact__r.Address__r.Section_Code__c, Contact__r.Name,
                                         Main_Package_Product_Sub_Type_Mapping__c, is1stPDFGenerated__c, is2ndPDFGenerated__c,
                                         is1stNotifEmailSent__c, is2ndNotifEmailSent__c
                                         FROM Zuora__Subscription__c 
                                         WHERE ((is1stPDFGenerated__c = TRUE AND is1stNotifEmailSent__c = FALSE) 
                                            OR (is2ndPDFGenerated__c = TRUE AND is2ndNotifEmailSent__c = FALSE))
                                            AND Zuora__Status__c = :globalvariableclass.ZUORA_STATUS_ACTIVE 
                                            AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION
                                            AND Zuora__Account__r.RecordType.Id IN :directRecTypeIds
                                            AND Id = 'a0CN00000066Qu7'
                                            AND (Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_EMAIL OR Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_BOTH)]);
                                         /*START CommentedOut by RReyes to use new condition above
                                         WHERE Days_to_Expire__c = :globalvariableclass.DAYS_TO_EXPIRE_14 
                                            AND Zuora__Status__c = :globalvariableclass.ZUORA_STATUS_ACTIVE 
                                            AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION
                                            AND Zuora__Account__r.RecordType.Id IN :directRecTypeIds
                                            AND (Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_EMAIL OR Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_BOTH)]);
                                        END CommentedOut by RReyes to use new condition above*/
        //END UD-1168 07/16/15 RReyes - added in Main_Package_Product_Sub_Type_Mapping__c, is1stPDFGenerated__c, is2ndPDFGenerated__c,is1stNotifEmailSent__c, is2ndNotifEmailSent__c in query. Also changed the condition.
        //END : D-3125 6/19/2015 Alyana Navarro
        //END UD-1168 6/17/2015 Added By C. Lin
        //END D-2674 06/03/2015 Added by C. Lin
    }
     
   /* @description Executes the business logic and send an Email Notification to the Subscriber   
    * @param bc - predefined parameter  
    * @param scope - a list of sObjects from the initial database query     
    * @return void        
    */         
    //START D-2674 06/03/2015 Added by C. Lin - Change Account to Zuora__Subscription__c
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> subList) {
    //END D-2674 06/03/2015 Added by C. Lin
        system.debug('subListSize>>'+subList.size());
        system.debug('subList>>'+subList);
        EmailTemplate magazineTemplate = [SELECT HtmlValue, subject, Name FROM EmailTemplate WHERE Name = 'Magazines Renewal and Reminder'];
        EmailTemplate newspaperTemplate = [SELECT HtmlValue, subject, Name FROM EmailTemplate WHERE Name = 'Newspaper Renewal Reminder'];
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> subIdTospcMap = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        Map<String, EmailTemplate> prodCodeToEmailTemplateMap = new Map<String, EmailTemplate>();
        Map<Id, List<Publication__c>> subIdToPubMap = new Map<Id, List<Publication__c>>();
        Map<String, String> subMap = new Map<String, String>();
        List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
        List<Messaging.SingleEmailMessage> emailsLIST = new  List<Messaging.SingleEmailMessage>();
        //START D-2674 06/03/2015 Added by C. Lin - to be removed
        //List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        //END D-2674 06/03/2015 Added by C. Lin
        List<zqu__ZProduct__c> zProductList = new List<zqu__ZProduct__c>();
        List<Messaging.Email> allMails = new List<Messaging.Email>();
        Messaging.SingleEmailMessage mail;
        Set<String> prodCodeSet = new Set<String>();
        //START D-2674 06/03/2015 Added by C. Lin - to be removed
        //Set<Id> acctIdSET = new Set<Id>();
        //END D-2674 06/03/2015 Added by C. Lin
        Set<Id> subIdSET = new Set<Id>();   
        String oldValue, actualValue, objName; // START-END : D-2204 3/3/2015 Alyana Navarro - Remove variable fieldName
        EmailTemplate emailTemplate;
        Integer startIndex = 0;
        Integer endIndex = 0;
        String[] addresses;
        //START UD-1168 6/17/2015 Added By C. Lin - Add for new format of Address
        String address1, address2, address3, address4, address5;
        //END UD-1168 6/17/2015 Added By C. Lin
        
        // START : D-2204 3/3/2015 Alyana Navarro
        Decimal delSubCharge = 0.00;
        Decimal total = 0.00;
        //Set<Id> delSubIdSet = new Set<Id>();
        //START D-2674 06/03/2015 Added by C. Lin - OLI for delivery subs
        //Set<String> recipientAddressSet = new Set<String>();
        Set<Id> oliIdSet = new Set<Id>();
        //END D-2674 06/03/2015 Added by C. Lin
        Set<Id> packageIdSet = new Set<Id>();
        Set<Id> magSubIdSet = new Set<Id>();
        Set<String> magPubCode = new Set<String>();
        List<Package_Item__c> packItemList = new List<Package_Item__c>();
        List<Zuora__Subscription__c> delSubList = new List<Zuora__Subscription__c>();
        Map<String, Zuora__Subscription__c> delSubMap = new Map<String, Zuora__Subscription__c>();
        Map<Id, List<Package_Item__c>> packIdPackItemListMap = new Map<Id, List<Package_Item__c>>();
        Map<String, Zuora__Subscription__c> pubCodeSubMap = new Map<String, Zuora__Subscription__c>();
        Map<Id, String> subIdMagPubCode = new Map<Id, String>();
        Map<Id, Map<String, Zuora__Subscription__c>> accIdRecAddDelSubMap = new Map<Id, Map<String, Zuora__Subscription__c>>();
        Map<String, Zuora__Subscription__c> recAddSubMap = new Map<String, Zuora__Subscription__c>();
        List<Zuora__Subscription__c> lstSubsToUpdate = new List<Zuora__Subscription__c>(); //START/END UD-1168 07/16/15 RReyes - list of subscriptions to be updated
        
        try {
        // END : D-2204 3/3/2015 Alyana Navarro
        //START D-2674 06/03/2015 Added by C. Lin - to be removed
        /*for (Account a :scope) {
            acctIdSET.add(a.Id);
        }
        
        if (!acctIdSET.isEmpty()) {
                // START : D-2204 3/3/2015 Alyana Navarro
                    subList = [SELECT Id, Zuora__Account__r.AccountNumber, Subscriber_Contact__r.FirstName, Subscriber_Contact__r.LastName, 
                               Recipient_Contact__r.Name, Recipient_Contact__r.Account.AccountNumber, Zuora__Account__r.Name, 
                               Subscriber_Contact__r.Contact_Address_Detail__c, Number_of_Copies__c, Subscription_Charge__c, Zuora__Account__c,
                               Recipient_Contact__r.Address__r.Address_Unique_ID__c, Subscriber_Contact__r.Email__c, Frequency_1__c, 
                               Subscriber_Contact__r.Email_Secondary__c, Product_Code__c, Zuora__SubscriptionEndDate__c, Main_Package_1__c
                               FROM Zuora__Subscription__c
                               WHERE Zuora__Account__c IN :acctIdSET 
                                     AND Days_to_Expire__c = :globalvariableclass.DAYS_TO_EXPIRE_14 
                                     AND Zuora__Status__c = :globalvariableclass.ZUORA_STATUS_ACTIVE];
            // END : D-2204 3/3/2015 Alyana Navarro      
        }*/
        //END D-2674 06/03/2015 Added by C. Lin
            
            for (Zuora__Subscription__c sub :subList) {
                subIdSET.add(sub.Id);
                    // START : D-2204 3/3/2015 Alyana Navarro
                    packageIdSet.add(sub.Main_Package_1__c);
                    //START D-2674 06/03/2015 Added by C. Lin - OLI for delivery subs
                    //recipientAddressSet.add(sub.Recipient_Contact__r.Address__r.Address_Unique_ID__c);
                    oliIdSet.add(sub.Order_Line_Item_Number_1__c);
                    //END D-2674 06/03/2015 Added by C. Lin
                    pubCodeSubMap.put(sub.Product_Code__c, sub);
                    // END : D-2204 3/3/2015 Alyana Navarro
            }
            
                // START : D-2204 3/3/2015 Alyana Navarro
                //START D-2674 06/03/2015 Added by C. Lin - OLI for delivery subs instead of Unique_Delivery_Identifier__c
            //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges. Added Term_Length__c
            delSubList = [SELECT id, name, Unique_Delivery_Identifier__c, Subscription_Charge__c, Zuora__Account__c, Order_Line_Item_Number_1__c, Term_Length__c 
                          FROM Zuora__Subscription__c 
                          WHERE Order_Line_Item_Number_1__c IN: oliIdSet AND Subscription_Type_1__c = 'Delivery'];
            //END UD-1168 6/15/2015 Added By C. Lin
                //END D-2674 06/03/2015 Added by C. Lin
                
                for(Zuora__Subscription__c delSub : delSubList){
                    //START D-2674 06/03/2015 Added by C. Lin - Change Unique_Delivery_Identifier__c to OLI
                    if(accIdRecAddDelSubMap.containsKey(delSub.Zuora__Account__c)){
                        accIdRecAddDelSubMap.get(delSub.Zuora__Account__c).put(delSub.Order_Line_Item_Number_1__c, delSub);
                    } else {
                        Map<String, Zuora__Subscription__c> recSubTempMap = new Map<String, Zuora__Subscription__c>();
                        recSubTempMap.put(delSub.Order_Line_Item_Number_1__c, delSub);
                        accIdRecAddDelSubMap.put(delSub.Zuora__Account__c, recSubTempMap);
                    }
                    //END D-2674 06/03/2015 Added by C. Lin
                }
                
                for(Zuora__Subscription__c delSub : delSubList){
                    //delSubMap.put(delSub.id, delSub);
                }
                
                system.debug('delSubMap : ' + delSubMap);
                
                packItemList = [SELECT id, name, RenewalPkgCodeMag1YrBase__c, RenewalPkgCodeMag1YrDisc__c, RenewalPkgCodeMag2YrBase__c, 
                                RenewalPkgCodeMag2YrDisc__c, Package__c
                                FROM Package_Item__c
                                WHERE Package__c IN: packageIdSet];
                
                for(Package_Item__c packItem : packItemList){
                    if(packIdPackItemListMap.containsKey(packItem.Package__c)){
                        packIdPackItemListMap.get(packItem.Package__c).add(packItem);
                    } else {
                        packIdPackItemListMap.put(packItem.Package__c, new List<Package_Item__c>{packItem});
                    }
                }
                // END : D-2204 3/3/2015 Alyana Navarro
            if (!subIdSET.isEmpty()) {
                spcList = [SELECT Id, PublicationCode__c, Zuora__Account__c, Zuora__Subscription__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN :subIdSET];
            }
            
            for (Zuora__SubscriptionProductCharge__c spc :spcList) {
                if (subIdTospcMap.containsKey(spc.Zuora__Subscription__c)) {
                    subIdTospcMap.get(spc.Zuora__Subscription__c).add(spc);
                }
                else {
                    subIdTospcMap.put(spc.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>{spc});
                }
            }
            
            for (Zuora__Subscription__c sub :subList) {
                prodCodeSet.add(sub.Product_Code__c);
            }       
            
            if (!prodCodeSet.isEmpty()) {
                zProductList = [SELECT Id, ProductSubType__c, ProductCode__c FROM zqu__ZProduct__c WHERE ProductCode__c IN :prodCodeSet];
            }
            
            for (zqu__ZProduct__c zProd :zProductList) {
                    // START : D-2204 3/3/2015 Alyana Navarro
                    if(pubCodeSubMap.containsKey(zProd.ProductCode__c)){
                        if(zProd.ProductSubType__c == 'Magazine'){
                            magSubIdSet.add(pubCodeSubMap.get(zProd.ProductCode__c).id);
                        }
                    }
                    // END : D-2204 3/3/2015 Alyana Navarro
                if (zProd.ProductSubType__c == 'Newspaper') {
                    if (!prodCodeToEmailTemplateMap.containsKey(zProd.ProductCode__c)) {
                        prodCodeToEmailTemplateMap.put(zProd.ProductCode__c, newspaperTemplate);
                    }
                }
                else if (zProd.ProductSubType__c == 'Magazine'){
                    if (!prodCodeToEmailTemplateMap.containsKey(zProd.ProductCode__c)) {
                        prodCodeToEmailTemplateMap.put(zProd.ProductCode__c, magazineTemplate);
                    }
                }
            }
            
                // START : D-2204 3/3/2015 Alyana Navarro
                for(Id magSubId : magSubIdSet){
                    if(subIdTospcMap.containsKey(magSubId)){
                        for(Zuora__SubscriptionProductCharge__c subProdCharge : subIdTospcMap.get(magSubId)){
                            if(subProdCharge.PublicationCode__c != null){
                                magPubCode.add(subProdCharge.PublicationCode__c);                       
                                subIdMagPubCode.put(subProdCharge.Zuora__Subscription__c, subProdCharge.PublicationCode__c);
                            }
                        }
                    }
                }
                // END : D-2204 3/3/2015 Alyana Navarro
        //START D-2674 06/03/2015 Added by C. Lin - removed if condition
                SubscriptionUtil subUtil = new SubscriptionUtil();
                subIdToPubMap = subUtil.subIdToPubListMap(subIdSet);
                
                for (Zuora__Subscription__c sub :subList) {
                    //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges.
                    total = 0.00;
                    //END UD-1168 6/15/2015 Added By C. Lin
                    
                    if (sub.Subscriber_Contact__r.Email__c != null || sub.Subscriber_Contact__r.Email_Secondary__c != null) {
                            // START : D-2204 3/3/2015 Alyana Navarro
                emailTemplate = new EmailTemplate();
                        //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges.
                        if(prodCodeToEmailTemplateMap.containsKey(sub.Product_Code__c)){
                            emailTemplate = prodCodeToEmailTemplateMap.get(sub.Product_Code__c);
                        }
                        //END UD-1168 6/15/2015 Added By C. Lin
                            String template = emailTemplate.htmlvalue;
                            String subject = emailTemplate.subject;
                            Integer counter = 0;
                            String subs = '';
                            String fieldName = '';
                            startIndex = 0;
                            endIndex = 0;
                            //Map values for Magazine
                        //START UD-1168 6/17/2015 Added By C. Lin - Fix format and Charges.
                        //subMap.put(globalvariableclass.FIRST_NAME, sub.Subscriber_Contact__r.FirstName);
                        //subMap.put(globalvariableclass.LAST_NAME, sub.Subscriber_Contact__r.LastName);
                        //subMap.put(globalvariableclass.MAILINGADDRESS, sub.Subscriber_Contact__r.Contact_Address_Detail__c);
                        //END UD-1168 6/17/2015 Added By C. Lin
                            subMap.put(globalvariableclass.ACCOUNT_NAME, sub.Zuora__Account__r.Name);
                            subMap.put(globalvariableclass.ACCOUNT_NUMBER, sub.Zuora__Account__r.AccountNumber); 
                            subMap.put(globalvariableclass.EXPIRY_DATE, String.valueOf(sub.Zuora__SubscriptionEndDate__c));                                                                     
                            
                        //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges. Remove For Loop
                        //for (Publication__c pub :subIdToPubMap.get(sub.Id)) {
                            //START D-2674 06/03/2015 Added by C. Lin - Add if condition
                            if (sub.Subscription_Charge__c != null){
                                total += sub.Subscription_Charge__c;
                            }
                            //END D-2674 06/03/2015 Added by C. Lin
                        //}
                        //END UD-1168 6/15/2015 Added By C. Lin
                                
                            if(accIdRecAddDelSubMap.containsKey(sub.Zuora__Account__c)){
                                //START D-2674 06/03/2015 Added by C. Lin - Change Address_Unique_ID__c to OLI
                                if(accIdRecAddDelSubMap.get(sub.Zuora__Account__c).containsKey(sub.Order_Line_Item_Number_1__c)){
                                //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges
                                if (accIdRecAddDelSubMap.get(sub.Zuora__Account__c).get(sub.Order_Line_Item_Number_1__c).Subscription_Charge__c != null && accIdRecAddDelSubMap.get(sub.Zuora__Account__c).get(sub.Order_Line_Item_Number_1__c).Term_Length__c != null){
                                    total += accIdRecAddDelSubMap.get(sub.Zuora__Account__c).get(sub.Order_Line_Item_Number_1__c).Subscription_Charge__c * accIdRecAddDelSubMap.get(sub.Zuora__Account__c).get(sub.Order_Line_Item_Number_1__c).Term_Length__c;
                                }
                                //END UD-1168 6/15/2015 Added By C. Lin
                                }
                                //START D-2674 06/03/2015 Added by C. Lin
                            }
                        //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges.
                        subMap.put('Total', '$' + total.setScale(2));
                        subMap.put('Sub Total', '$' + total.setScale(2) + '*');
                        //END UD-1168 6/15/2015 Added By C. Lin
                            // END : D-2204 3/3/2015 Alyana Navarro
                            
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
                                //START UD-1168 6/17/2015 Added By C. Lin - Fix format and Charges.
                                if(fieldName.contains('MailingAddress')){
                                    if(sub.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Local')){
                                        address1 = sub.Contact__r.Address__r.Block_House_Number__c + ' ' + sub.Contact__r.Address__r.Postal_Code__r.Street_Name__c;
                                        address2 = '#' + sub.Contact__r.Address__r.Level_Number__c + ' - ' + sub.Contact__r.Address__r.Unit_Number__c;
                                        address3 = sub.Contact__r.Address__r.Postal_Code__r.Building_Name__c;
                                        address4 = sub.Contact__r.MailingCountry.toUpperCase() + ' ' + sub.Contact__r.Address__r.Postal_Code__r.Name;
                                    } else if(sub.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Airline')){
                                        address1 = sub.Contact__r.Address__r.Airline_Number__c + ' ' + sub.Contact__r.Address__r.City__c;
                                        address2 = sub.Contact__r.Address__r.Flight_Number_1__c;
                                        address3 = sub.Contact__r.Address__r.Flight_Number_2__c;
                                    } else if(sub.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Overseas')){
                                        address1 = sub.Contact__r.Address__r.Address_1__c;
                                        address2 = sub.Contact__r.Address__r.Address_2__c;
                                        address3 = sub.Contact__r.Address__r.Address_3__c;
                                        address4 = sub.Contact__r.Address__r.Address_4__c;                     
                                    } else if(sub.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Internal')){
                                        address1 = sub.Contact__r.Address__r.Location_Code__c;
                                        address2 = sub.Contact__r.Address__r.Company_Code__c;
                                        address3 = sub.Contact__r.Address__r.Division_Code__c;
                                        address4 = sub.Contact__r.Address__r.Department__c;
                                        address5 = sub.Contact__r.Address__r.Section_Code__c;
                                    }
                                    
                                    if(address1 != null && address1 != ''){
                                        actualValue = address1 + '<br/>';
                                    }
                                    if(address2 != null && address2 != ''){
                                        actualValue += address2 + '<br/>';
                                    }
                                    if(address3 != null && address3 != ''){
                                        actualValue += address3 + '<br/>';
                                    }
                                    if(address4 != null && address4 != ''){
                                        actualValue += address4 + '<br/>';
                                    }
                                    if(address5 != null && address5 != ''){
                                        actualValue += address5 + '<br/>';
                                    }
                                    
                                    template = template.replace(oldValue, actualValue);
                                }else if(fieldName.contains('Name')){
                                    if(objName.contains('Contact')){
                                        template = template.replace(oldValue, sub.Contact__r.Name);
                                    }else if(objName.contains('Account')){
                                        template = template.replace(oldValue, sub.Zuora__Account__r.Name);
                                    }
                                }
                                else if (fieldName.contains('Today')) {
                                //END UD-1168 6/17/2015 Added By C. Lin
                                    if (fieldName.contains('14')) {
                                        template = template.replace(oldValue, (DateTime.Now() + 14).format('d/MM/YYYY')); // START-END : D-2204 3/11/2015 Alyana Navarro
                                    }
                                    else {
                                        template = template.replace(oldValue, DateTime.Now().format('d/MM/YYYY')); // START-END : D-2204 3/11/2015 Alyana Navarro
                                }                                                    
                            }
                            else if (subMap.containsKey(fieldName)) {
                                if (subMap.get(fieldName) != null) {
                                    actualValue = String.valueOf(subMap.get(fieldName));
                                    template = template.replace(oldValue, actualValue);
                                }
                                else {
                                    template = template.remove(oldValue);
                                }
                            }     
                            
                            else if (fieldName == 'Insert Table') {
                        //START : D-2204 3/3/2015 Alyana Navarro
                                        Date dateNewInstance = Date.newInstance(sub.Zuora__SubscriptionEndDate__c.year(), sub.Zuora__SubscriptionEndDate__c.month(), sub.Zuora__SubscriptionEndDate__c.day());
                                        String subEndDate = String.valueOf(dateNewInstance).subString(0,10);
                                        List<String> subEndDateList = subEndDate.split('-');                                    
                                        subEndDate = '';
                                        subEndDate += subEndDateList[2] + '/';
                                        subEndDate += subEndDateList[1] + '/';
                                        subEndDate += subEndDateList[0].substring(2,4);                                        
                                if (prodCodeToEmailTemplateMap.get(sub.Product_Code__c).Name.contains('Magazine')) {
                                    
                                            if(packIdPackItemListMap.containsKey(sub.Main_Package_1__c)){
                                                for (Package_Item__c packItem : packIdPackItemListMap.get(sub.Main_Package_1__c)) {
                                                    subs += '<tr>'+
                                                        //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges
                                                        '<td width=20% align=left>'+sub.Zuora__Account__r.AccountNumber+'&nbsp;'+sub.Recipient_Contact__r.Name+'<br>'+(sub.Main_Package_1__r.Name != null ? sub.Main_Package_1__r.Name : '')+'</td>'+
                                                        '<td width=10% align=center>'+(sub.Number_of_Copies__c != null ? Integer.valueOf(sub.Number_of_Copies__c) : 0)+'</td>'+
                                                        '<td width=10% align=center>'+String.valueOf(subEndDate).subString(0,8)+'</td>'+ 
                                                        '<td width=10% align=center>'+ (packItem.RenewalPkgCodeMag1YrBase__c != null ? packItem.RenewalPkgCodeMag1YrBase__c : '') +'</td>'+
                                                        '<td width=10% align=center>'+ (packItem.RenewalPkgCodeMag1YrDisc__c != null ? packItem.RenewalPkgCodeMag1YrDisc__c : '') +'</td>'+
                                                        '<td width=10% align=center>(  )</td>'+
                                                        '<td width=10% align=center>'+ (packItem.RenewalPkgCodeMag2YrBase__c != null ? packItem.RenewalPkgCodeMag2YrBase__c : '') +'</td>'+
                                                        '<td width=10% align=center>'+ (packItem.RenewalPkgCodeMag2YrDisc__c != null ? packItem.RenewalPkgCodeMag2YrDisc__c : '') +'</td>'+
                                                        //END UD-1168 6/15/2015 Added By C. Lin
                                                            '<td width=10% align=center>(  )</td>'+
                                                            '</tr>';                                                    
                                                }
                                    }
                                            // END : D-2204 3/3/2015 Alyana Navarro
                                    }
                                    if (prodCodeToEmailTemplateMap.get(sub.Product_Code__c).Name.contains('Newspaper')) {
                                            // START : D-2204 3/3/2015 Alyana Navarro
                                        //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges. Remove for loop
                                        //for (Publication__c pub :subIdToPubMap.get(sub.Id)) {
                                            //Decimal total += Subscription Amount; TBD
                                            subs += '<tr>'+
                                                    //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges
                                                    '<td width=30% align=left>'+sub.Recipient_Contact__r.Account.AccountNumber+'&nbsp;'+sub.Zuora__Account__r.Name+'<br>'+sub.Recipient_Contact__r.Name+'</td>'+
                                                    '</tr>'+
                                                    '<tr>'+
                                                    '<td width=30% align=left>'+(sub.Main_Package_1__r.Name != null ? sub.Main_Package_1__r.Name : '')+'</td>'+
                                                    '<td width=20% align=left>'+(sub.Number_of_Copies__c != null ? Integer.valueOf(sub.Number_of_Copies__c) : 0)+'</td>'+
                                                    //END UD-1168 6/15/2015 Added By C. Lin
                                                    '<td width=20% align=left>'+String.valueOf(subEndDate).subString(0,8)+'</td>'+ 
                                                    //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges
                                                    '<td width=15% align=left>$'+(sub.Subscription_Charge__c != null ? sub.Subscription_Charge__c.setScale(2) : 0.00)+'</td>'+
                                                    //END UD-1168 6/15/2015 Added By C. Lin
                                                    '<td width=15% align=left>(  )</td>'+
                                                    '</tr>';                                            
                                        //}
                                        //END UD-1168 6/15/2015 Added By C. Lin
                                            
                                            if(accIdRecAddDelSubMap.containsKey(sub.Zuora__Account__c)){
                                                //START D-2674 06/03/2015 Added by C. Lin - Change Address_Unique_ID__c to OLI
                                                if(accIdRecAddDelSubMap.get(sub.Zuora__Account__c).containsKey(sub.Order_Line_Item_Number_1__c)){
                                                //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges
                                                if(accIdRecAddDelSubMap.get(sub.Zuora__Account__c).get(sub.Order_Line_Item_Number_1__c).Subscription_Charge__c != null && accIdRecAddDelSubMap.get(sub.Zuora__Account__c).get(sub.Order_Line_Item_Number_1__c).Term_Length__c != null){
                                                    delSubCharge = accIdRecAddDelSubMap.get(sub.Zuora__Account__c).get(sub.Order_Line_Item_Number_1__c).Subscription_Charge__c * accIdRecAddDelSubMap.get(sub.Zuora__Account__c).get(sub.Order_Line_Item_Number_1__c).Term_Length__c;
                                                }
                                                //END UD-1168 6/15/2015 Added By C. Lin
                                                }
                                                //END D-2674 06/03/2015 Added by C. Lin
                                            }
                                            
                                            subs += '<tr>'+
                                                    '<td width=30% align=left>DELIVERY FEE</td>'+
                                                    '<td width=20% align=left></td>'+
                                                    '<td width=20% align=left></td> '+
                                                //START UD-1168 6/15/2015 Added By C. Lin - Fix format and Charges
                                                '<td width=15% align=left>$' + delSubCharge.setScale(2) + '</td>'+
                                                //END UD-1168 6/15/2015 Added By C. Lin
                                                    '<td width=15% align=left></td>'+
                                                    '</tr>';
                                            // END : D-2204 3/3/2015 Alyana Navarro
                                }
                                
                                template = template.replace(oldValue, subs);
                            }                       
                            else if (!subMap.containsKey(fieldName)){
                                template = template.remove(oldValue);
                            }     
                        }
                        counter++;
                    }

                    //send email to Subscriber
                    addresses = new List<String>();
                    if (sub.Subscriber_Contact__r.Email__c != null) {
                        addresses.add(sub.Subscriber_Contact__r.Email__c);
                    }
                    if (sub.Subscriber_Contact__r.Email_Secondary__c != null) {
                        addresses.add(sub.Subscriber_Contact__r.Email_Secondary__c);
                    }
                    system.debug('addresses>>'+addresses);
                    mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(addresses);
                    mail.setSubject(subject);
                    mail.setHtmlBody(template);
                    mail.setSaveAsActivity(true);               
                    system.debug('mail>>'+mail);
                    //START UD-1168 07/16/15 RReyes - added condition filter which subscriptions receive email notification
                    Date dateToday = Date.today();
                    Integer dayOfMonth = dateToday.day();
                    Renewal_Notifications__c Renewal = Renewal_Notifications__c.getValues('Renewal Notifications Values');
                    if((sub.Main_Package_Product_Sub_Type_Mapping__c == 'Magazine' && sub.is1stPDFGenerated__c == TRUE && sub.is1stNotifEmailSent__c == FALSE && dayOfMonth == Renewal.FirstMagazineNotifDayOfMonth__c)
                    ||(sub.Main_Package_Product_Sub_Type_Mapping__c == 'Newspaper' && sub.is1stPDFGenerated__c == TRUE && sub.is1stNotifEmailSent__c == FALSE && dayOfMonth == Renewal.FirstNewspaperNotifDayOfMonth__c)){
                        sub.is1stPDFGenerated__c = TRUE;
                        sub.is1stNotifEmailSent__c = TRUE;
                        emailsLIST.add(mail);
                        lstSubsToUpdate.add(sub);
                    }
                    if((sub.Main_Package_Product_Sub_Type_Mapping__c == 'Magazine' && sub.is2ndPDFGenerated__c == TRUE && sub.is2ndNotifEmailSent__c == FALSE && dayOfMonth == Renewal.SecondMagazineNotifDayOfMonth__c)
                    ||(sub.Main_Package_Product_Sub_Type_Mapping__c == 'Newspaper' && sub.is2ndPDFGenerated__c == TRUE && sub.is2ndNotifEmailSent__c == FALSE && dayOfMonth == Renewal.SecondNewspaperNotifDayOfMonth__c)){
                        sub.is2ndPDFGenerated__c = TRUE;
                        sub.is2ndNotifEmailSent__c = TRUE;
                        emailsLIST.add(mail);
                        lstSubsToUpdate.add(sub);
                    }
                    system.debug('emailsLIST>>'+emailsLIST);
                    //END UD-1168 07/16/15 RReyes - added condition filter which subscriptions receive email notification
                }
            }
            system.debug('emailsLIST>>'+emailsLIST);
            for (Integer j = 0; j < emailsLIST.size(); j++ ) {
                allMails.add(emailsLIST.get(j));
            }  
            system.debug('allMails>>'+allMails);
            system.debug('>>>>allMails.size>>'+allMails.size());
            system.debug('>>>lstSubsToUpdate>>' + lstSubsToUpdate);
            if (!allMails.isEmpty()){
                //START UD-1168 07/16/15 RReyes - added try catch. Added update statement to update certain fields in subscription
                try{
                    //Messaging.sendEmail(allMails);
                    Messaging.sendEmail(allMails,false);
                    if(lstSubsToUpdate.size() > 0){
                        update lstSubsToUpdate;
                    }
                }catch(Exception e){
                    System.debug('Error: ' + e.getMessage());
                }
                //END UD-1168 07/16/15 RReyes - added try catch. Added update statement to update certain fields in subscription
            }
        //END D-2674 06/03/2015 Added by C. Lin
    // START : D-2204 3/3/2015 Alyana Navarro
        } catch (exception e) {
          exceptionList.add(e);
        }
        ExceptionLogger.log(exceptionList); 
    // END : D-2204 3/3/2015 Alyana Navarro
    }
        
    global void finish(Database.BatchableContext BC) {
        //START D-2674 06/03/2015 Added By C. Lin - Move code to BatchJobHelper
        BatchJobHelper.updateJobStatus(BC.getJobId());
        //END D-2674 06/03/2015 Added By C. Lin
    }
}