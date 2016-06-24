/**
* Class Name: AcknowledgmentLetterEmail
* @author: Jean Cariño
* Date: 04/17/2015
* Requirement/Project Name: Singapore Press Holdings
* @description Batch Process to handle email notification of Acknowledgment Letter
* History : UD-2286 8/13/2015 Alyana Navarro - Reconstructed whole class
*/
//START: D-4363 2-15-2016 Added by Kristine Balaoing - added database.AllowsCallouts to class definition
global class AcknowledgmentLetterEmail implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    //END: D-4363 2-15-2016 Added by Kristine Balaoing
    public String footnotes;
    public Map<Id, Zuora__CustomerAccount__c> billingAccountMap = new Map<Id, Zuora__CustomerAccount__c>();
    public Map<Id, Map<Id, List<Zuora__Subscription__c>>> billAcctIdRecConIdPubSubListMap = new Map<Id, Map<Id, List<Zuora__Subscription__c>>>();    
    public Map<Id, Map<Id, Decimal>> recConIdDelSubChargeMap = new Map<Id, Map<Id, Decimal>>();
    public Map<Id, String> subIdSubChargeMap = new Map<Id, String>();
    public Map<Id, String> subIdStartEndDateMap = new Map<Id, String>();
    public Map<Id, Map<String, String>> billAccIdFootNotesMap = new Map<Id, Map<String, String>>();
    public Map<Id, List<Zuora__Subscription__c>> accIdSubListMap = new Map<Id, List<Zuora__Subscription__c>>();
    public Map<Id, Set<String>> billingAcctIdEmailAddressSet = new Map<Id, Set<String>>();    
    public Map<Id, Decimal> billacctIdTotalSubChargeMap = new Map<Id, Decimal>();
    public Map<Id, String> subIdPriceSign = new Map<Id, String>(); // START-END : UD-0683 6/15/2015 Alyana Navarro
  //START: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015 
    public decimal subIdSubChargedec;
    public string strtotalsubprice;
  //END: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015    
  
    //START UD-2013 22-July-2015 Added by S.Puli - address based on record type
    Map<Id, String> accIdToTopAddress_MAP = new Map<Id, String>();
    Map<Id, String> accIdToMidAddress_MAP = new Map<Id, String>();
    //END UD-2013 22-July-2015 Added by S.Puli - address based on record type
    
    //START UD-2015 Added by S.Puli - add postage fee
    Map<Id, Decimal> subIdToPostageFee_MAP = new Map<Id, Decimal>();
    Map<Id, Id> postSubToMainSub_MAP = new Map<Id, Id>();//replace by Map<Id, Set<Id>> if bundle needs to be Postaged individually
    Map<Id, Id> orderLineToSubs_MAP = new Map<Id, Id>();
    //END UD-2015 Added by S.Puli - add postage fee
  
    // START : UD-2179 8/7/2015 Alyana Navarro
    public Map<Id, String> recIdRecAddress = new Map<Id, String>();
    // END : UD-2179 8/7/2015 Alyana Navarro
    
    public Map<Id, Contact> recipientContactMap = new Map<Id, Contact>();
    public Map<Id, Contact> billAccountRecContacttMap = new Map<Id, Contact>();
    //START: D-3598 09/28/2015 added by Jason A.
    //START UD-2328 08/27/15 RReyes
    public DateTime dateFromCS = ConstantsSLB.getOtherDate('SP18_SDT1');
    public DateTime dateToCS = ConstantsSLB.getOtherDate('SP18_SDT2');
    //END UD-2328 08/27/15 RReyes
    public Set<Id> lprIdSet = new Set<Id>();
    public DateTime referenceDateFrom;
    public DateTime referenceDateTo;
    public Boolean isRecovery;
    
    //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
    public map<id, list<Zuora__Subscription__c>> mapOrderLineItem = new map<id, list<Zuora__Subscription__c>>();
    //End D-3928 VPernicia 11/12/15: Combine the bundle subscription
    
    //START UD-2017 11/13/2015 added by Jason A.
    public Map<Id, Id> billIdToBillConId = new Map<Id, Id>();
    public String bccAddresses = ConstantsSLB.getother('BCC Email Set up');
    //END UD-2017 11/13/2015 added by Jason A.
    
    //START: D-4363 2-12-2016 Added by Kristine Balaoing -added callout to CTRL M
    Boolean isApexJobSuccessful = true;
    //END: D-4363 2-12-2016 Added by Kristine Balaoing
    
    global AcknowledgmentLetterEmail()
    {
        referenceDateFrom = dateFromCS;
        referenceDateTo = dateToCS;
        isRecovery = false;
    }
    
    global AcknowledgmentLetterEmail(Set<Id> lprID){
        isRecovery = true;
        lprIdSet = lprID;
        List<Letter_Print_Request__c> letterPrintRecoveryList  = [SELECT id, name, Generation_From__c, Generation_To__c FROM Letter_Print_Request__c WHERE ID in: lprIdSet];
        referenceDateFrom = letterPrintRecoveryList[0].Generation_From__c;
        referenceDateTo = letterPrintRecoveryList[0].Generation_To__c;      
    }
    
    global AcknowledgmentLetterEmail(DateTime dateFrom, DateTime dateTo)
    {
        isRecovery = false;
        referenceDateFrom = dateFrom;
        referenceDateTo = dateTo;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        // START : UD-0683 6/15/2015 Alyana Navarro
    //START UD-2328 08/27/15 - RReyes replaced DTL Date criteria with Custom Settings
    // START : UD-2575 9/18/2015 Jason A. - additional field Status Email and Email Address
        /*return Database.getQueryLocator([SELECT id, name, Record_ID__c, DTL_Date__c, Acknowledgment_Type__c, Status_Email__c, Email_Address__c
                                            FROM Letter_Print_Request__c 
                                            WHERE Letter_Type__c = 'Acknowledgment_Letter' 
                                            AND (Sub_Created_Date__c >: dateFrom AND Sub_Created_Date__c <=: dateTo)
                                            AND (Acknowledgment_Type__c = 'Email' OR Acknowledgment_Type__c = 'Both')
                                            ]);*/
                                            
        String query = ' SELECT id, name, Record_ID__c, DTL_Date__c, Acknowledgment_Type__c, Status_Email__c, Email_Address__c, Generation_From__c, Generation_To__c ' ;
        query += ' FROM Letter_Print_Request__c ' ;                                   
        query += ' WHERE Letter_Type__c = \'Acknowledgment_Letter\' AND (Acknowledgment_Type__c = \'Email\' OR Acknowledgment_Type__c = \'Both\')';
        
        if(isRecovery){
            query += 'AND Id IN :lprIdSet AND (Sub_Created_Date__c >=: referenceDateFrom AND Sub_Created_Date__c <=: referenceDateTo) '; 
        }else{
            query += 'AND (Sub_Created_Date__c >: referenceDateFrom AND Sub_Created_Date__c <=: referenceDateTo) ';
        }        
        return Database.getQueryLocator(query);
    //END: D-3598 09/28/2015 added by Jason A.
    // END : UD-2575 9/18/2015 Jason A. - adding Try Catch 
    //END UD-2328 08/27/15 - RReyes replaced DTL Date criteria with Custom Settings
        // END : UD-0683 6/15/2015 Alyana Navarro
    }   
            
    global void execute(Database.BatchableContext BC, List<Letter_Print_Request__c> letterPrintRequestList){
        
        system.debug('Excuted');
        system.debug('letterPrintRequestList -- ' + letterPrintRequestList.size());
        //START: D-4266 1-13-2016 Added by Kristine Balaoing - added logger
        List<Exception> exceptionList = new List<Exception>();
        //START: D-4363 2-12-2016 Added by Kristine Balaoing - added callout to CTRL M
        Boolean isError = false;
        
        try{
            getAcknowledgmentDetails(letterPrintRequestList);
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        //END: D-4266 1-13-2016 Added by Kristine Balaoing
        
            Integer startIndex;
            Integer endIndex;       
            String oldValue;
            String actualValue;
            String fieldName;        
            Messaging.SingleEmailMessage mail;
            List<Messaging.SingleEmailMessage> emailLIST = new List<Messaging.SingleEmailMessage>();
            Map<String, String> fieldValueMap = new Map<String, String>();
            EmailTemplate emailTemplate = [SELECT HtmlValue,subject 
                                           FROM EmailTemplate 
                                           WHERE Name = 'Acknowledgement Letters'];
        
        
            List<Messaging.Email> allMails = new List<Messaging.Email>();
            String subject = emailTemplate.subject;
            String innerTable = '';
            
        
            
            
            List<Document> sphLogoDoc = [Select Id, Name From Document Where Name = :ConstantsSLB.getOther('SPH Logo v2') Limit 1];
            
            string linkForLogo1 = '';
            string linkForLogo2 = '';
            string linkForLogo3 = '';
            string linkForLogo4 = '';
            string finalLink = '';
        
        
    // START : D-4197 1/4/2016 Alyana Navarro
            
    Logger logger = new Logger(AcknowledgmentLetterEmail.class.getName(), 'SP054', BC.getJobID());
    List<Letter_Print_Request__c> successLPRList = new List<Letter_Print_Request__c>();
    Map<Id, Letter_Print_Request__c> updatedLPRMap = new Map<Id, Letter_Print_Request__c>();        
    // END : D-4197 1/4/2016 Alyana Navarro
        if(sphLogoDoc.size()>0){
            linkForLogo1 = string.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
            linkForLogo2 = '/servlet/servlet.ImageServer?id=';
            linkForLogo3 = sphLogoDoc[0].Id + '&oid=';
            linkForLogo4 = string.valueOf(Userinfo.getOrganizationId());
            finalLink = linkForLogo1 + linkForLogo2 + linkForLogo3 + linkForLogo4;
        }
        // START : UD-2575 9/18/2015 Jason A. - adding Try Catch and updating Status field in the Letter Print Request
        list<Letter_Print_Request__c> LPR = new list<Letter_Print_Request__c>();
        //START: D-3598 09/28/2015 added by Jason A.
            Other__c otherDateFrom = Other__c.getInstance('SP18_SDT1');
        Other__c otherDateTo = Other__c.getInstance('SP18_SDT2');
        //END: D-3598 09/28/2015 added by Jason A.
        for(Letter_Print_Request__c letterPrintRequest : letterPrintRequestList){
         
        try{
            if(letterPrintRequest.Acknowledgment_Type__c == 'Email' || letterPrintRequest.Acknowledgment_Type__c == 'Both' )//Start-End UD-0683 Jean Cariño 04/29/2015
            {
                if(billAcctIdRecConIdPubSubListMap.containsKey(letterPrintRequest.Record_ID__c)){                
                    String template = emailTemplate.HtmlValue;
                    innerTable = '';
                    startIndex = 0;
                    endIndex = 0;
                    oldValue = '';
                    actualValue = '';
                    fieldName = '';
                    fieldValueMap = new Map<String, String>();
      //START: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015                
                    Datetime yourDate = Date.Today();
        //START: UD-1738 Jason A. / Von P. 09/07/2015
                    String dateOutput = yourDate.format('dd/MM/yyyy');
        //END: UD-1738 Jason A. / Von P. 09/07/2015
                    fieldValueMap.put('Today', String.valueOf(dateOutput));
      //END: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015                
                    if(billingAccountMap.containsKey(letterPrintRequest.Record_ID__c)){
                        // Start D-3430 VPernicia 08/21/15
                        fieldValueMap.put('AccountNumber', String.valueOf(billingAccountMap.get(letterPrintRequest.Record_ID__c).Zuora__AccountNumber__c));
                        fieldValueMap.put('AccountName', String.valueOf(billingAccountMap.get(letterPrintRequest.Record_ID__c).Billing_Contact__r.Name));
                        //START D-3935 11/12/2015 added by Jason A.     
                        fieldValueMap.put('AttnTo', String.valueOf(billingAccountMap.get(letterPrintRequest.Record_ID__c).Billing_Contact__r.Company_Name__c));     
                        //END D-3935 11/12/2015 added by Jason A.
                        // End D-3430 VPernicia 08/21/15
                        //START UD-2013 22-July-2015 Added by S.Puli - address based on record type
                        //fieldValueMap.put('MailingAddress', String.valueOf(billingAccountMap.get(letterPrintRequest.Record_ID__c)[0].Recipient_Contact__r.Mailing_Address__c));
                        fieldValueMap.put('MailingAddress', accIdToTopAddress_MAP.get(letterPrintRequest.Record_ID__c));
                        //fieldValueMap.put('MailingAddress1', String.valueOf(billingAccountMap.get(letterPrintRequest.Record_ID__c)[0].Recipient_Contact__r.MailingAddress2__c));//Start-End UD-1114 Jean Cariño 05/8/2015
                        fieldValueMap.put('MailingAddress1', accIdToMidAddress_MAP.get(letterPrintRequest.Record_ID__c));            
                        fieldValueMap.put('RecipientNumber', String.valueOf(billAccountRecContacttMap.get(letterPrintRequest.Record_ID__c).Recipient_Number__c));
                        fieldValueMap.put('RecipientAccountName', String.valueOf(billAccountRecContacttMap.get(letterPrintRequest.Record_ID__c).Firstname) + ' ' + String.valueOf(billAccountRecContacttMap.get(letterPrintRequest.Record_ID__c).Lastname));
                        //END UD-2013 22-July-2015 Added by S.Puli - address based on record type
                        
                        //START: UD-2416 19-Aug-2015 Added By S.Puli
                        //String baseURL = string.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm()) + '/resource/SPHlogov2';
                        //fieldValueMap.put('baseURL', 'http://c.cs6.content.force.com/servlet/servlet.ImageServer?id=015N00000007u0U&oid=00DN0000000OdC2');  
                        //fieldValueMap.put('baseURL', string.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm()));  
                        fieldValueMap.put('baseURL', finalLink);
                        //END: UD-2416 19-Aug-2015 Added By S.Puli
                    }
                    Integer counter = 0; //START-END : UD-2179 8/7/2015 Alyana Navarro
                    while(startIndex != 1) {
                        startIndex = template.indexOf('{{') + 2;
                        if (startIndex != 1) {
                            endIndex = template.indexOf('}}') + 2;
                            oldValue = template.subString(startIndex - 2, endIndex);
                            String insideValue = template.subString(startIndex, endIndex - 2);
                            fieldName = insideValue;
                        }
                        //START: UD-1114 05/8/2015 Jean Cariño Added logic for Payment Method
                        if(fieldName == 'insert table'){
                            for(Id recConId : billAcctIdRecConIdPubSubListMap.get(letterPrintRequest.Record_ID__c).keySet()){
                                // START : UD-2179 8/7/2015 Alyana Navarro
                                counter++;
                                if(counter > 1){                                                                
                                    innerTable += '<tr style = "font-size:9pt">';//START/END UD-2571 RReyes - changed font-size to 9pt, same as in template
                                    innerTable +=   '<td colspan = 6 style="border: 1px solid #000000;">';
                                    innerTable +=       '<b>Subscription & Recipient Details<br/></b>';
                                    innerTable +=       String.valueOf(recipientContactMap.get(recConId).Recipient_Number__c) + '&nbsp;&nbsp;';
                                    innerTable +=       String.valueOf(recipientContactMap.get(recConId).Firstname) + '&nbsp;' + String.valueOf(recipientContactMap.get(recConId).Lastname) + ',&nbsp;&nbsp;';
                                    if(recIdRecAddress.containsKey(recConId)){
                                        innerTable += recIdRecAddress.get(recConId);
                                    }
                                    innerTable += '</td>';
                                    innerTable += '</tr>';
                                }
                                // END : UD-2179 8/7/2015 Alyana Navarro
                                for(Zuora__Subscription__c sub : billAcctIdRecConIdPubSubListMap.get(letterPrintRequest.Record_ID__c).get(recConId)){
                                    String pricePlan = '';
                                    String paymentMethod = ''; 
                                    String contractPeriod = 'NA';
                                    // START : D-1114 Jean Cariño 05/19/2015
                                    if(sub.Billing_Type__c == 'Full Prepaid'){
                                        pricePlan = String.valueOf(Integer.valueOf(sub.Term_Length__c)) + ' Month(s) Full Prepaid';
                                    //START D-3688 10/05/2015 Jason A. 
                                    } else if(sub.Billing_Type__c == 'Recurring Prepaid'){                                  
                                        if(sub.Term_Length__c < 12 || sub.Term_Length__c == 0 || sub.Term_Length__c == null){
                                            pricePlan = 'Monthly';
                                        } else {
                                            pricePlan = 'Yearly';
                                        }
                                    //END D-3688 10/05/2015 Jason A. 
                                    } else if(sub.Billing_Type__c == 'Recurring Postpaid'){
                                        pricePlan = 'Monthly';
                                    }
                                    
                                        if(sub.New_Contract_Period_1__c != null){
                                        contractPeriod = String.valueOf(sub.New_Contract_Period_1__c);
                                    }
                                    // END : UD-1114 Jean Cariño 05/19/2015
                                    // START : UD-1114 Jean Cariño 5/21/2015
                                    if(sub.Payment_Mode_1__c == 'Other'){
                                        paymentMethod = sub.Other_PaymentMethod_1__c;
                                    }  else {
                                        paymentMethod = sub.Payment_Mode_1__c;
                                    }
                                    // END: UD-1114 Jean Cariño 5/21/2015
      //START: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015                
                 
                         
                                    subIdSubChargedec = decimal.valueof(subIdSubChargeMap.get(sub.Id));
                                    
                                    innerTable += '<tr>';
                                    innerTable +=   '<td align = left style="border: 1px solid #000000;">';
                                    innerTable +=       '&nbsp;' +  sub.Main_Package_1__r.Name;
                                    innerTable +=   '</td>';
                                    innerTable +=   '<td align = center style="border: 1px solid #000000;">';
                                    innerTable +=       '&nbsp;' + subIdStartEndDateMap.get(sub.id);
                                    innerTable +=   '</td>';
                                    innerTable +=   '<td align = center style="border: 1px solid #000000;">';
                                    innerTable +=       Integer.valueOf(sub.Number_of_Copies__c);
                                    innerTable +=   '</td>';
                                    innerTable +=   '<td align = center style="border: 1px solid #000000;">';
                                    innerTable +=       '&nbsp;' + pricePlan;                                                         
                                    innerTable +=   '</td>';
                                    innerTable +=   '<td align = center style="border: 1px solid #000000;">';
                                    innerTable +=       '&nbsp;' + paymentMethod;
                                    innerTable +=   '</td>';
                                    innerTable +=   '<td align = right style="border: 1px solid #000000;">';
                                    // START : UD-2718 Sept-14-2015 Jason A - 2 decimal places format
                                    string strSubCharge = subIdSubChargedec.setScale(2, System.RoundingMode.HALF_UP).format();
                                    
                                    if (strSubCharge.right(2).left(1) == '.') {                    
                                        strSubCharge = strSubCharge + '0';
                                    } else if (strSubCharge.right(3).left(1) != '.'){
                                        strSubCharge = strSubCharge + '.00';
                                    }
                                    
                                    // END : UD-2718 Sept-14-2015 Jason A - 2 decimal places format
                                    innerTable +=    strSubCharge + subIdPriceSign.get(sub.Id) ; // START-0683 : UD-0683 6/15/2015 Alyana Navarro
                                    innerTable +=   '</td>';
                                    innerTable += '</tr>';
                                    
                                    //START UD-2015 Added by S.Puli - add postage fee
                                    //Start D-3928 VPernicia 11/16/15: Fix for bundle sub
                                    for (Zuora__Subscription__c zuoraSubs: mapOrderLineItem.get(sub.Order_Line_Item_Number_1__c)){
                                        if(subIdToPostageFee_MAP.containsKey(zuoraSubs.Id)){
                                            innerTable += '<tr >';
                                            innerTable +=   '<td colSpan = 5 align = left style="border: 1px solid #000000;">';
                                            innerTable +=       'Postage Fee';
                                            innerTable +=   '</td>';
                                            innerTable +=   '<td align = right style="border: 1px solid #000000;">';
                                            innerTable +=   subIdToPostageFee_MAP.get(zuoraSubs.Id);
                                            innerTable +=   '</td>';
                                            innerTable += '</tr>';
                                        }
                                    }
                                    //End D-3928 VPernicia 11/16/15: Fix for bundle sub
                                    //END UD-2015 Added by S.Puli - add postage fee
                                    
                                }                           
                                /*if(recConIdDelSubChargeMap.containsKey(recConId)){
                                    //innerTable += '<tr> <td> &nbsp; </td> </tr>';
                                    innerTable += '<tr>';
                                    innerTable +=   '<td width=90% colSpan = 5 align = left>';
                                    innerTable +=       'DELIVERY FEE'; //START-END: UD-1114 05/19/2015 Jean Cariño
                                    innerTable +=   '</td>';
                                    innerTable +=   '<td width=10% align = center>';
                                    innerTable +=       recConIdDelSubChargeMap.get(recConId);
                                    innerTable +=   '</td>';
                                    innerTable += '</tr>';
                                }*/
                                // START : UD-1738 7/4/2015 Alyana Navarro - Remove 
                                /*Decimal total = 0.00;

                                if(billacctIdTotalSubChargeMap.containsKey(letterPrintRequest.Record_ID__c)){
                                    total = billacctIdTotalSubChargeMap.get(letterPrintRequest.Record_ID__c);
                                }*/
                                // END : UD-1738 7/4/2015 Alyana Navarro - Remove   
                                
                                innerTable += '<tr>';
                                innerTable +=   '<td colSpan = 5 align = left style="border: 1px solid #000000;">';
                                innerTable +=       'Newspaper Delivery Fee';
                                innerTable +=   '</td>';
                                innerTable +=   '<td align = right style="border: 1px solid #000000;">';
                                if(recConIdDelSubChargeMap.containsKey(letterPrintRequest.Record_ID__c)){
                                    if(recConIdDelSubChargeMap.get(letterPrintRequest.Record_ID__c).get(recConId) != null){
                                        innerTable +=   recConIdDelSubChargeMap.get(letterPrintRequest.Record_ID__c).get(recConId);
                                    } else{
                                        innerTable +=   'N/A';
                                    }
                                } else{
                                    innerTable +=   'N/A';
                                }
                                innerTable +=   '</td>';
                                innerTable += '</tr>';
                                // START : UD-1738 7/4/2015 Alyana Navarro - Remove             
                                /*innerTable += '<tr>';
                                innerTable +=   '<td width=90% colSpan = 5 align = left>';
                                innerTable +=       'TOTAL';
                                innerTable +=   '</td>';
                                innerTable +=   '<td width=10% align = right>';
                                strtotalsubprice = total.format();
                            
                                 if (strtotalsubprice.right(2).left(1) == '.') {
                    
                                        strtotalsubprice = strtotalsubprice + '0';
                                    } else if (strtotalsubprice.right(3).left(1) != '.') {
                                        strtotalsubprice = strtotalsubprice + '.00';
                                    }
                                innerTable +=   strtotalsubprice  + '**';
                                innerTable +=   '</td>';
                                innerTable += '</tr>';
                                innerTable += '<tr>';
                                innerTable += '<td width=90% colSpan = 6 align = left>';
                                innerTable += '**GST Included (Singapore Only)'; //START-END: UD-2372 10/19/2015 Added by Jason A
                                innerTable += '</td>'; 
                                innerTable += '</tr>';*/
                                // END : UD-1738 7/4/2015 Alyana Navarro - Remove                       
      //END: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015    
                            }
                            // START : UD-1738 7/4/2015 Alyana Navarro
                            Decimal total = 0.00;
                            if(billacctIdTotalSubChargeMap.containsKey(letterPrintRequest.Record_ID__c)){
                                total = billacctIdTotalSubChargeMap.get(letterPrintRequest.Record_ID__c);
                            }
                            
                            innerTable += '<tr>';
                            innerTable +=   '<td colSpan = 5 align = left style="border: 1px solid #000000;">';
                            innerTable +=       'TOTAL';
                            innerTable +=   '</td>';
                            innerTable +=   '<td align = right style="border: 1px solid #000000;">';//START/END UD-2571 RReyes - added border style
                            // START : UD-2718 Sept-14-2015 Jason A - 2 decimal places format
                            strtotalsubprice = total.setScale(2, System.RoundingMode.HALF_UP).format();
                            
                            if (strtotalsubprice.right(2).left(1) == '.') {
                                strtotalsubprice = strtotalsubprice + '0';
                                } else if (strtotalsubprice.right(3).left(1) != '.') {
                                    strtotalsubprice = strtotalsubprice + '.00';
                                }
                            
                            // END : UD-2718 Sept-14-2015 Jason A - 2 decimal places format
                            innerTable +=   strtotalsubprice  + '**';
                            innerTable +=   '</td>';
                            innerTable += '</tr>';
                            innerTable += '<tr>';
                            innerTable += '<td colSpan = 6 align = left style="border: 1px solid #000000;">';//START/END UD-2571 RReyes - added border style
                            innerTable += '**GST Included (Singapore Only)'; //START-END: UD-3730 14.1.2016 Gdelrosario added "singapore only" static text
                            innerTable += '</td>'; 
                            innerTable += '</tr>';
                            // END : UD-1738 7/4/2015 Alyana Navarro
                            template = template.replace(oldValue, innerTable);
                        } else if(fieldName == 'footnotes'){
                            if(billAccIdFootNotesMap.containsKey(letterPrintRequest.Record_ID__c)){
                                footnotes = '';                     
                                for(String key : billAccIdFootNotesMap.get(letterPrintRequest.Record_ID__c).keySet()){
                                    footnotes += billAccIdFootNotesMap.get(letterPrintRequest.Record_ID__c).get(key);                               
                                }
                                footnotes += '<br/>';
                                template = template.replace(oldValue, footnotes);
                            } else {
                                template = template.remove(oldValue);
                            }
                        } else if(fieldValueMap.containsKey(fieldName)){
                            if(fieldValueMap.get(fieldName) != null){                       
                                template = template.replace(oldValue, fieldValueMap.get(fieldName));
                            } else {
                                template = template.remove(oldValue);
                            }
                        } else {
                            template = template.remove(oldValue);
                        }
                    }
                    //END: UD-1114 05/8/2015 Jean Cariño
                    List<String> emailAddList = new List<String>();
                    if(billingAcctIdEmailAddressSet.containsKey(letterPrintRequest.Record_ID__c)){
                        emailAddList.addAll(billingAcctIdEmailAddressSet.get(letterPrintRequest.Record_ID__c));             
                        mail = new Messaging.SingleEmailMessage();
                    //START: UD-3308 11/24/2015 added by Jason A.
                        //mail.setToAddresses(emailAddList);
                    //END: UD-3308 11/24/2015 added by Jason A.
                        mail.setSubject(subject);
                        mail.setHtmlBody(template);
                        //START UD-2017 11/13/2015 added by Jason A.
                        // START : UD-3461 1/5/2016 Alyana Navarro
                        if(bccAddresses != null){
                            List<String> bccList = new List<String>();
                            bccList.add(bccAddresses);
                            mail.setBccSender(true);                          
                            mail.setBccAddresses(bccList);
                        }
                        // END : UD-3461 1/5/2016 Alyana Navarro
                        mail.setTargetObjectId(billIdToBillConId.get(letterPrintRequest.Record_ID__c));
                        
                        //END UD-2017 11/13/2015 added by Jason A.
                        mail.setSaveAsActivity(true);
                        emailLIST.add(mail);
                        letterPrintRequest.Status_Email__c = 'Successful';
                        letterPrintRequest.Email_Address__c = '';
                        for(string emailAdd: billingAcctIdEmailAddressSet.get(letterPrintRequest.Record_ID__c)){
                            letterPrintRequest.Email_Address__c += emailAdd + ';';
                        }
                        
                        successLPRList.add(letterPrintRequest); // START-END : D-4197 1/4/2016 Alyana Navarro
                    } else {
                        letterPrintRequest.Status_Email__c = 'Failed';
                    // START : D-4197 1/4/2016 Alyana Navarro
                    logger.log(true, 'No email address for Letter Print Request ' + letterPrintRequest.id); 
                    isError = true;
                    // END : D-4197 1/4/2016 Alyana Navarro
                    }
                                 
                }
            }
        } catch(exception e){
   
            letterPrintRequest.Status_Email__c = 'Failed';
            // START : D-4197 1/4/2016 Alyana Navarro
            logger.log(true, 'Record ID: ' + letterPrintRequest.id + '\n Stack trace: ' + e.getStackTraceString() + '\n Message: ' + e.getMessage()); 
            isError = true;
            // END : D-4197 1/4/2016 Alyana Navarro
        }
        //START: D-3598 09/28/2015 added by Jason A.
        letterPrintRequest.Generation_From__c = otherDateFrom.DateTime__c;
        letterPrintRequest.Generation_to__c = otherDateTo.DateTime__c;
        // START : D-4197 1/4/2016 Alyana Navarro
        updatedLPRMap.put(letterPrintRequest.id, letterPrintRequest);
        //LPR.add(letterPrintRequest);
        // END : D-4197 1/4/2016 Alyana Navarro
        //END: D-3598 09/28/2015 added by Jason A.
        } 
        
        for (Integer j = 0; j < emailLIST.size(); j++ ) {
            allMails.add(emailLIST.get(j));
        }                
        system.debug(allMails.size() + ' ' + billAcctIdRecConIdPubSubListMap + ' ');
            //START D-3992 11/26/2015 added by Jason A.
        // START : D-4197 1/4/2016 Alyana Navarro  
        String emailFailure = '';           
        try{
        Messaging.SendEmailResult[] mailResult = Messaging.sendEmail(allMails, false); // START-END : UD-3461 1/5/2016 Alyana Navarro
            for(Integer counter = 0; counter < mailResult.size(); counter++){
                emailFailure = '';
                if (!mailResult[counter].isSuccess() ) {
                    for(Messaging.SendEmailError emailError : mailResult[counter].getErrors()){
                        emailFailure += '* ' + emailError.getMessage() + '\n';
                    }
                    
                    logger.log(true, 'Email not sent for ' + successLPRList[counter].id + '. Errors encountered: \n' + emailFailure);
                    isError = true;
                    if(updatedLPRMap.containsKey(successLPRList[counter].id)){
                        updatedLPRMap.get(successLPRList[counter].id).Status_Email__c = 'Failed';
                    }
                }
            }

            LPR.addAll(updatedLPRMap.values());
        } catch(DmlException dmlEx) {                
            logger.log(true, 'Stack trace: ' + dmlEx.getStackTraceString() + '\n Message: ' + dmlEx.getMessage());
            isError = true;
        } catch(System.EmailException emlEx) {                
            logger.log(true, 'Stack trace: ' + emlEx.getStackTraceString() + '\n Message: ' + emlEx.getMessage());
            isError = true;
        } catch(Exception e){
            logger.log(true, 'Stack trace: ' + e.getStackTraceString() + '\n Message: ' + e.getMessage());
            isError = true;
        }
        // END : D-4197 1/4/2016 Alyana Navarro
            //END D-3992 11/26/2015 added by Jason A. 
        if(LPR.size()>0){
            update LPR;
        }
        // END : UD-2575 9/18/2015 Jason A. - adding Try Catch and updating Status field in the Letter Print Request 
    // START : D-4197 1/4/2016 Alyana Navarro
    if(isError){
        logger.save();
        isApexJobSuccessful = false;
    }
    // END : D-4197 1/4/2016 Alyana Navarro
    //END: D-4363 2-12-2016 Added by Kristine Balaoing
    }
    
    public void getAcknowledgmentDetails(List<Letter_Print_Request__c> letterPrintRequestList){ 
    
        footnotes = '';                            
        String subCharge = '';
        String sign = ''; // START-END : UD-0683 6/15/2015 Alyana Navarro
        String startEndDate = '';       
        //Set<Id> accountIdSet = new Set<Id>();
        Set<Id> billingAccountIdSet = new Set<Id>();
        //Set<Id> orderIdSet = new Set<Id>();
        Set<Id> recipientContactSet = new Set<Id>();
        Set<Id> subscriptionIdSet = new Set<Id>(); // START-END : UD-2021 8/13/2015 Alyana Navarro
        List<Order__c> orderList = new List<Order__c>();
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>(); 
        List<Contact> recipientContactList = new List<Contact>();
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>(); // START-END : UD-2021 8/13/2015 Alyana Navarro
        Map<Id, Set<Id>> recConIdBillAccountIdMap = new Map<Id, Set<Id>>();
        Map<Id, Map<Id, Map<String, List<Zuora__Subscription__c>>>> recConIdBillTypeDelSubListMap = new Map<Id, Map<Id, Map<String, List<Zuora__Subscription__c>>>>();
        Map<Id, Decimal> billAcctIdTotalPostChargeMap = new Map<Id, Decimal>(); // START-END : UD-2148 7/29/2015 Alyana Navarro
        Map<Id, Id> everSubIdCaseIdMap = new Map<Id, Id>(); // START-END : UD-2021 8/13/2015 Alyana Navarro
        
        for(Letter_Print_Request__c letterPrintRequest : letterPrintRequestList){
            billingAccountIdSet.add(letterPrintRequest.Record_ID__c);
        }
        //START UD-2013 22-July-2015 Added by S.Puli - address based on record type
        /*orderList = [SELECT id, name, Account__c, Account__r.Name, Account__r.AccountNumber,
                     Recipient_Contact__r.Mailing_Address__c, Recipient_Contact__r.MailingAddress2__c, Recipient_Contact__r.Recipient_Number__c
                     FROM Order__c 
                     WHERE Billing_Account__c IN: billingAccountIdSet AND DTL_Date__c = TODAY AND Order_Type__c = 'START'];
        //END UD-2013 22-July-2015 Added by S.Puli - address based on record type
        
        for(Order__c order : orderList){
            orderIdSet.add(order.Id);            
            if(billingAccountMap.containsKey(order.Billing_Account__c)){
                billingAccountMap.get(order.Billing_Account__c).add(order);
            } else {
                billingAccountMap.put(order.Billing_Account__c, new List<Order__c>{order});
            }
        }*/
        
        // Start D-3430 VPernicia 08/21/15
        //START D-3935 11/12/2015 added by Jason A. 
        List<Zuora__CustomerAccount__c> billingAccountList = [SELECT id, name, Zuora__Account__r.AccountNumber, Zuora__Account__c, 
                                                              Zuora__Account__r.Name, Zuora__AccountNumber__c, Billing_Contact__r.Name, Billing_Contact__r.Company_Name__c
                                                              FROM Zuora__CustomerAccount__c 
                                                              WHERE id IN: billingAccountIdSet];
        //END D-3935 11/12/2015 added by Jason A.   
        // End D-3430 VPernicia 08/21/15
        for(Zuora__CustomerAccount__c billingAccount : billingAccountList){
            billingAccountMap.put(billingAccount.id, billingAccount);
        }
        //START: D-3598 09/28/2015 added by Jason A.
        // START : UD-1114 5/9/2015 Jean Cariño
        //START-END UD-1114 05/8/2015 Jean Cariño Added some fields in the query
        //START UD-2013 22-July-2015 Added by S.Puli - address based on record type
    //START UD-2328 08/27/15 - RReyes replaced DTL Date criteria with Custom Settings  
        // START : UD-2929 9/24/2015 Alyana Navarro
        //START D-3689 10/05/2015 Jason A. - Remove filter for Active Subscription.
        //START UD-3141 10/22/2015 Jason A. - Added for Supressed Acknowledgement
        
        subscriptionList = [SELECT id, name, Zuora__Account__c,Zuora__TermSettingType__c, Supressed_Acknowledgement_Letter_1__c,
                            Zuora__Account__r.SS_Subscriber_Account_Number__c, Contact__c, Recipient_Contact__c, Recipient_Contact__r.Name, 
                            Main_Package_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Qty__c, Other_PaymentMethod_1__c,
                            Zuora__Account__r.AccountNumber, Zuora__Account__r.Name, Contact__r.Address__r.Block_House_Number__c, 
                            Contact__r.Address__r.Level_Number__c, Contact__r.Address__r.Unit_Number__c, Payment_Method_1__c,
                            Contact__r.Address__r.Building_Name__c, Contact__r.Address__r.Postal_Code__r.Street_Name__c, 
                            Contact__r.Address__r.Country__r.Country_Name__c, Contact__r.Address__r.Postal_Code__r.Name,
                            Contact__r.LastName, Contact__r.FirstName, Main_Package_1__r.Name, Number_of_Copies__c, Subscription_Charge__c, 
                            Main_Package_1__r.Number_Of_Promotions__c, Payment_Mode_1__c, Term_Length__c, New_Contract_Period_1__c,
                            Recipient_Contact__r.Address__r.Postal_Code__c, Subscription_Type_1__c, Recipient_Contact__r.Mailing_Address__c,
                            Recipient_Contact__r.HomePhone__c, Order_Line_Item_Number_1__c, Billing_Type__c, Frequency_1__c, 
                            Order_Number_1__r.Delivery_Charge__c, Order_Number_1__r.DTL_Date__c, Recipient_Contact__r.HomePhone, 
                            Recipient_Contact__r.Address__r.Name, Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c, 
                            Recipient_Contact__r.Recipient_Number__c, Zuora__CustomerAccount__r.Billing_Contact__r.Email__c, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Email_Secondary__c,
                            Recipient_Contact__r.Address__r.recordType.developerName, Recipient_Contact__r.Address__r.Street_Name__c,
                            Recipient_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                            Recipient_Contact__r.Address__r.Department__r.Department_Name__c, Recipient_Contact__r.Address__r.Division_Code__r.Name,
                            Recipient_Contact__r.Address__r.Company_Code__r.Company_Name__c,Recipient_Contact__r.Address__r.Address_1__c,Recipient_Contact__r.Address__r.Address_2__c, Recipient_Contact__r.Address__r.Address_3__c, 
                            Recipient_Contact__r.Address__r.Address_4__c,Recipient_Contact__r.Address__r.City__r.City_Name__c,
                            Recipient_Contact__r.Address__r.Airline_Number__c,Recipient_Contact__r.Address__r.Flight_Number_1__c,
                            Recipient_Contact__r.Address__r.Flight_Number_2__c, Zuora__CustomerAccount__r.Billing_Contact__r.Email,
                            Recipient_Contact__r.Address__r.Country__r.Country_Name__c,Recipient_Contact__r.Address__r.Block_House_Number__c,
                            Recipient_Contact__r.Address__r.Level_Number__c,Recipient_Contact__r.Address__r.Unit_Number__c,Recipient_Contact__r.Address__r.Building_Name__c, Zuora__CustomerAccount__c, Recipient_Contact__r.Lastname, Recipient_Contact__r.Firstname,
                            Recipient_Contact__r.Address__r.Postal_Code__r.Name,Recipient_Contact__r.Address__r.Location_Code__r.Location_Name__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Postal_Code__r.Name, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Street_Name__c, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Division_Code__r.Name,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Address_1__c, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Address_2__c, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Address_3__c, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Address_4__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.City__r.City_Name__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Airline_Number__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Flight_Number_1__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Flight_Number_2__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Country__r.Country_Name__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Block_House_Number__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Level_Number__c, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Unit_Number__c, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Building_Name__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.recordType.developerName,
                            
                            // Start UD-2882 VPernicia 11/09/15
                            Main_Package_1__r.GST_Exclusive__c,
                            Contact__r.Address__r.RecordTypeId,
                            // Start UD-2882 VPernicia 11/09/15
    //START UD-3758 02-23-2016 added by Jason A.               
                             //START MMallorca D-3722 05/11/2015 Added address fields for Internal Address Type    
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.City__r.Name,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Section_Code__r.Name,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Department__r.Name,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Company_Code__r.Name,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Location_Code__r.Name, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.City__r.Country__r.Country_Name__c,
                            Recipient_Contact__r.Address__r.City__r.Name,
                            Recipient_Contact__r.Address__r.Section_Code__r.Name,
                            Recipient_Contact__r.Address__r.Department__r.Name,
                            Recipient_Contact__r.Address__r.Company_Code__r.Name,
                            Recipient_Contact__r.Address__r.Location_Code__r.Name,
                            //UD-3720
                            Recipient_Contact__r.Address__r.City__r.Country__r.Country_Name__c,
                            //END MMallorca D-3722 05/11/2015 Added address fields for Internal Address Type  
                            Order_Line_Item_Number_1__r.End_Date__c
                            //UD-3720
                            , Main_Package_1__r.Package_Type__c
                            FROM Zuora__Subscription__c
                            WHERE (CreatedDate >: ReferenceDateFrom AND CreatedDate <=:ReferencedateTo) 
                                //START PD-0186 25May2016 Added By C. Lin - Include Active and Future Active Subscription only
                                AND Zuora__CustomerAccount__c IN: billingAccountIdSet AND Supressed_Acknowledgement_Letter_1__c = false AND (Status_Formula__c = 'Active' OR Status_Formula__c = 'Future Active')];
                                //END PD-0186 25May2016 Added By C. Lin
    //END UD-3758 02-23-2016 added by Jason A.
        //END UD-3141 10/22/2015 Jason A. - Added for Supressed Acknowledgement                     
        //END D-3689 10/05/2015 Jason A. - Remove filter for Active Subscription.                       
        // END : UD-2929 9/24/2015 Alyana Navarro
    //END UD-2328 08/27/15 - RReyes replaced DTL Date criteria with Custom Settings            
        //END UD-2013 22-July-2015 Added by S.Puli - address based on record type
        //END: D-3598 09/28/2015 added by Jason A.
        
        //Start D-3689 VPernicia 10/6/15
        //set<id> subIDforCOS = new set<id>(); //START - END: D-3724 10/16 removed by Jason A.
        //set<id> CaseSubforCOS = new set<id>(); //START - END: D-3724 10/16 removed by Jason A.
        //Start D-3689 VPernicia 10/6/15
            //START: D-3724 10/16 added by Jason A.
        list<Zuora__Subscription__c> newSubscriptionList = new list<Zuora__Subscription__c>();
        //START UD-2015 Added by S.Puli - add postage fee
        for(Zuora__Subscription__c sub : subscriptionList){
            // START : UD-2021 8/13/2015 Alyana Navarro
            if(sub.Zuora__SubscriptionEndDate__c > sub.Zuora__SubscriptionStartDate__c || sub.Zuora__TermSettingType__c == 'EVERGREEN'){ //START: D-3807 10/22 added by Jason A.
                if(sub.Zuora__TermSettingType__c == 'EVERGREEN'){
                    subscriptionIdSet.add(sub.id);
                }
                // END : UD-2021 8/13/2015 Alyana Navarro
                if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE ){
                    if(!orderLineToSubs_MAP.containsKey(sub.Order_Line_Item_Number_1__c)){
                        orderLineToSubs_MAP.put(sub.Order_Line_Item_Number_1__c, sub.Id);
                    }
                }
                if(!recipientContactMap.containsKey(sub.Recipient_Contact__c)){
                    recipientContactMap.put(sub.Recipient_Contact__c, sub.Recipient_Contact__r);
                }
                
                if(!billAccountRecContacttMap.containsKey(sub.Zuora__CustomerAccount__c)){
                    billAccountRecContacttMap.put(sub.Zuora__CustomerAccount__c, sub.Recipient_Contact__r);
                }
                //subIDforCOS.add(sub .id); //Start/End D-3689 VPernicia 10/6/15  //START - END: D-3724 10/16 removed by Jason A.
                newSubscriptionList.add(sub);
            }           
        }
            //END: D-3724 10/16 added by Jason A.
        //START: D-3724 10/16 removed by Jason A.
        //Start D-3689 VPernicia 10/6/15
        /*for (case caseCOS: [select Subscription_Name__c from case where Subscription_Name__c in: subIDforCOS and RecordTypeId =: ConstantsSLB.getKeyId('Case_Change of Subscription')]) {
        
            CaseSubforCOS.add(caseCOS.Subscription_Name__c);
        }*/
        //End D-3689 VPernicia 10/6/15
        //END: D-3724 10/16 removed by Jason A.
        // START : UD-2021 8/13/2015 Alyana Navarro
        caseSubList = [SELECT id, name, Subscription__c, Case__c
                       FROM Case_Subscription__c 
                       WHERE Case__r.RecordTypeId =: ConstantsSLB.getKeyId('Case_Stop') 
                            AND Subscription__c IN: subscriptionIdSet
                            AND (Case__r.Sub_Status__c = 'Ready for Submission' OR Case__r.Status = 'Closed')];
                            
        //START : D-3876 11/05/15 added by Jason A.
        List<Case> changeOfSubCase = [SELECT id, Status, Subscription_Name__c FROM Case WHERE RecordTypeId =: ConstantsSLB.getKeyId('Case_Change of Subscription') 
                        AND Status = 'Closed' AND Subscription_Name__c IN: subscriptionIdSet];
                        
        for(Case caseRec : changeOfSubCase){
            everSubIdCaseIdMap.put(caseRec.Subscription_Name__c, caseRec.id);
        }
        //END : D-3876 11/05/15 added by Jason A.
        
        
        for(Case_Subscription__c caseSub : caseSubList){
            everSubIdCaseIdMap.put(caseSub.Subscription__c, caseSub.Case__c);
        }
        // END : UD-2021 8/13/2015 Alyana Navarro
        
        //START: D-3724 10/16 added by Jason A.
        for(Zuora__Subscription__c sub : newsubscriptionList){ 
        //END: D-3724 10/16 added by Jason A.
        // START : UD-2575 9/18/2015 Jason A. - adding Try Catch 
            try{
                if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ){
                    if(orderLineToSubs_MAP.containsKey(sub.Order_Line_Item_Number_1__c)){
                        postSubToMainSub_MAP.put(orderLineToSubs_MAP.get(sub.Order_Line_Item_Number_1__c), sub.Id);
                    }
                }
            }catch(exception e){
            }
        // END : UD-2575 9/18/2015 Jason A. - adding Try Catch 
        }
        //END UD-2015 Added by S.Puli - add postage fee
        
        //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
        //map<id, list<Zuora__Subscription__c>> mapOrderLineItem = new map<id, list<Zuora__Subscription__c>>();
        for(Zuora__Subscription__c Subscription : newSubscriptionList){
            if (Subscription.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION) {
                if (!mapOrderLineItem.containskey(Subscription.Order_Line_Item_Number_1__c)) {
                    mapOrderLineItem.put(Subscription.Order_Line_Item_Number_1__c, new list<Zuora__Subscription__c>{Subscription});
                } else {
                    mapOrderLineItem.get(Subscription.Order_Line_Item_Number_1__c).add(Subscription);
                }
            }
        }
        
        set<id> setOrderLineitemID = new set<id>();
        //End D-3928 VPernicia 11/12/15: Combine the bundle subscription
        
        //START: D-3724 10/16 added by Jason A.
        for(Zuora__Subscription__c sub : newsubscriptionList){
        //END: D-3724 10/16 added by Jason A.   
        //START UD-2017 11/13/2015 added by Jason A.
        billIdToBillConId.put(sub.Zuora__CustomerAccount__c, sub.Zuora__CustomerAccount__r.Billing_Contact__c);
        //END UD-2017 11/13/2015 added by Jason A.
        decimal intSubCharges=0;  //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
        
        // START : UD-2575 9/18/2015 Jason A. - adding Try Catch 
        try{
        
            //if (!CaseSubforCOS.contains(sub.id)) { //Start/End D-3689 VPernicia 10/6/15 //START - END: D-3724 10/16 removed by Jason A.
        
                if(recConIdBillAccountIdMap.containsKey(sub.Recipient_Contact__c)){
                    recConIdBillAccountIdMap.get(sub.Recipient_Contact__c).add(sub.Zuora__CustomerAccount__c);
                } else {
                    recConIdBillAccountIdMap.put(sub.Recipient_Contact__c, new Set<Id>{sub.Zuora__CustomerAccount__c});
                }
             // END : UD-1114 5/9/2015 Jean Cariño
                // Not in use
                /*if(accIdSubListMap.containsKey(sub.Zuora__Account__c)){             
                    accIdSubListMap.get(sub.Zuora__Account__c).add(sub);                
                } else {
                    accIdSubListMap.put(sub.Zuora__Account__c, new List<Zuora__Subscription__c>{sub});
                }*/                 
                // START : UD-2929 9/24/2015 Alyana Navarro
                if(billingAcctIdEmailAddressSet.containsKey(sub.Zuora__CustomerAccount__c)){
                    if(sub.Zuora__CustomerAccount__r.Billing_Contact__r.Email != null){
                        billingAcctIdEmailAddressSet.get(sub.Zuora__CustomerAccount__c).add(sub.Zuora__CustomerAccount__r.Billing_Contact__r.Email);
                    } else if(sub.Zuora__CustomerAccount__r.Billing_Contact__r.Email_Secondary__c != null){
                        billingAcctIdEmailAddressSet.get(sub.Zuora__CustomerAccount__c).add(sub.Zuora__CustomerAccount__r.Billing_Contact__r.Email_Secondary__c);
                    }
                } else {
                    if(sub.Zuora__CustomerAccount__r.Billing_Contact__r.Email != null){
                        billingAcctIdEmailAddressSet.put(sub.Zuora__CustomerAccount__c, new Set<String>{sub.Zuora__CustomerAccount__r.Billing_Contact__r.Email});
                    } else if(sub.Zuora__CustomerAccount__r.Billing_Contact__r.Email_Secondary__c != null){
                        billingAcctIdEmailAddressSet.put(sub.Zuora__CustomerAccount__c, new Set<String>{sub.Zuora__CustomerAccount__r.Billing_Contact__r.Email_Secondary__c});
                    }
                }
                // END : UD-2929 9/24/2015 Alyana Navarro
                
                if(sub.Subscription_Type_1__c == 'Publication'){
                    
                    //Start UD-3758 VPernicia 2/2/16: Additional criteria for Add-on
                    if (!setOrderLineitemID.contains(sub.Order_Line_Item_Number_1__c) || sub.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON) { //Start/End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                    //End UD-3758 VPernicia 2/2/16: Additional criteria for Add-on
                        setOrderLineitemID.add(sub.Order_Line_Item_Number_1__c); //Start/End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                        // START : UD-1114 5/9/2015 Jean Cariño
                        if(sub.Subscription_Charge__c == null) {
                            sub.Subscription_Charge__c = 0;
                        }
                        
                        //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
                        //Start UD-2882 VPernicia 11/24/15: GST exclusive for Airline
                        //Start UD-3758 VPernicia 2/2/16: Additional criteria for Add-on
                        if (sub.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON) {
                        
                            if (sub.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Airline') && sub.Main_Package_1__r.GST_Exclusive__c == true) {
                                Other__c gstSetting = Other__c.getInstance('GST');
                                
                                if(billacctIdTotalSubChargeMap.containsKey(sub.Zuora__CustomerAccount__c)){
                                    Decimal total = billacctIdTotalSubChargeMap.get(sub.Zuora__CustomerAccount__c);
                                    total += sub.Subscription_Charge__c + (sub.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100));
                                    billacctIdTotalSubChargeMap.put(sub.Zuora__CustomerAccount__c, total);
                                } else {
                                    billacctIdTotalSubChargeMap.put(sub.Zuora__CustomerAccount__c, sub.Subscription_Charge__c + (sub.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100)));
                                }
                                
                                intSubCharges += sub.Subscription_Charge__c + (sub.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100));
                            } else {
                                if(billacctIdTotalSubChargeMap.containsKey(sub.Zuora__CustomerAccount__c)){
                                    Decimal total = billacctIdTotalSubChargeMap.get(sub.Zuora__CustomerAccount__c);
                                    total += sub.Subscription_Charge__c;
                                    billacctIdTotalSubChargeMap.put(sub.Zuora__CustomerAccount__c, total);
                                } else {
                                    billacctIdTotalSubChargeMap.put(sub.Zuora__CustomerAccount__c, sub.Subscription_Charge__c);
                                }
                                
                                intSubCharges += sub.Subscription_Charge__c;
                            }
                        
                        } else {
                            for (Zuora__Subscription__c zuoraSubs: mapOrderLineItem.get(sub.Order_Line_Item_Number_1__c)){
                                
                                if (zuoraSubs.Main_Package_1__r.Package_Type__c != GlobalVariableClass.PACKAGETYPE_ADDON) {
                                    if (zuoraSubs.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Airline') && zuoraSubs.Main_Package_1__r.GST_Exclusive__c == true) {
                                        Other__c gstSetting = Other__c.getInstance('GST');
                                        
                                        if(billacctIdTotalSubChargeMap.containsKey(zuoraSubs.Zuora__CustomerAccount__c)){
                                            Decimal total = billacctIdTotalSubChargeMap.get(zuoraSubs.Zuora__CustomerAccount__c);
                                            total += zuoraSubs.Subscription_Charge__c + (zuoraSubs.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100));
                                            billacctIdTotalSubChargeMap.put(zuoraSubs.Zuora__CustomerAccount__c, total);
                                        } else {
                                            billacctIdTotalSubChargeMap.put(zuoraSubs.Zuora__CustomerAccount__c, zuoraSubs.Subscription_Charge__c + (zuoraSubs.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100)));
                                        }
                                        
                                        intSubCharges += zuoraSubs.Subscription_Charge__c + (zuoraSubs.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100));
                                    } else {
                                        if(billacctIdTotalSubChargeMap.containsKey(zuoraSubs.Zuora__CustomerAccount__c)){
                                            Decimal total = billacctIdTotalSubChargeMap.get(zuoraSubs.Zuora__CustomerAccount__c);
                                            total += zuoraSubs.Subscription_Charge__c;
                                            billacctIdTotalSubChargeMap.put(zuoraSubs.Zuora__CustomerAccount__c, total);
                                        } else {
                                            billacctIdTotalSubChargeMap.put(zuoraSubs.Zuora__CustomerAccount__c, zuoraSubs.Subscription_Charge__c);
                                        }
                                        
                                        intSubCharges += zuoraSubs.Subscription_Charge__c;
                                    }
                                }
                            }
                        }
                        //End UD-3758 VPernicia 2/2/16: Additional criteria for Add-on
                        //End UD-2882 VPernicia 11/24/15: GST exclusive for Airline
                        //End D-3928 VPernicia 11/12/15: Combine the bundle subscription
        
                        // END : UD-1114 5/9/2015 Jean Cariño
                        //START: UD-1114 5/8/2015 Jean Cariño Modified Footnotes                                                
                        if(sub.Subscription_Charge__c != null){
                            subCharge = String.valueOf(intSubCharges); //Start/End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                        } else {
                            subCharge = '0.00';
                        }
                        sign = ''; // START-END : UD-0683 6/15/2015 Alyana Navarro
                        startEndDate = '';
                        /*if(billAcctIdRecConIdPubSubListMap.containsKey(sub.Zuora__Account__c)){
                            if(billAcctIdRecConIdPubSubListMap.get(sub.Zuora__Account__c).containsKey(sub.Recipient_Contact__c)){
                                billAcctIdRecConIdPubSubListMap.get(sub.Zuora__Account__c).get(sub.Recipient_Contact__c).add(sub);
                            } else {
                                billAcctIdRecConIdPubSubListMap.get(sub.Zuora__Account__c).put(sub.Recipient_Contact__c, new List<Zuora__Subscription__c>{sub});
                            }
                        } else {
                            billAcctIdRecConIdPubSubListMap.put(sub.Zuora__Account__c, new Map<Id, List<Zuora__Subscription__c>>());
                            billAcctIdRecConIdPubSubListMap.get(sub.Zuora__Account__c).put(sub.Recipient_Contact__c, new List<Zuora__Subscription__c>{sub});
                        }*/
                        
                        if(billAcctIdRecConIdPubSubListMap.containsKey(sub.Zuora__CustomerAccount__c)){
                            if(billAcctIdRecConIdPubSubListMap.get(sub.Zuora__CustomerAccount__c).containsKey(sub.Recipient_Contact__c)){
                                billAcctIdRecConIdPubSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).add(sub);
                            } else {
                                billAcctIdRecConIdPubSubListMap.get(sub.Zuora__CustomerAccount__c).put(sub.Recipient_Contact__c, new List<Zuora__Subscription__c>{sub});
                            }
                        } else {
                            billAcctIdRecConIdPubSubListMap.put(sub.Zuora__CustomerAccount__c, new Map<Id, List<Zuora__Subscription__c>>());
                            billAcctIdRecConIdPubSubListMap.get(sub.Zuora__CustomerAccount__c).put(sub.Recipient_Contact__c, new List<Zuora__Subscription__c>{sub});
                        }
                        
                        //START: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015                
                        /*if(sub.Main_Package_1__r.Number_Of_Promotions__c > 0){
                            if(sub.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER){
                                if(billAccIdFootNotesMap.containsKey(sub.Zuora__Account__c)){
                        //START: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015    
                                    //if(!billAccIdFootNotesMap.get(sub.Zuora__Account__c).containsKey('news')){
                                    //   billAccIdFootNotesMap.get(sub.Zuora__Account__c).put('news', '<br/>If you have subscribed to a newspaper promotion package, no cancellation of subscription is allowed within the contracted period. Otherwise, an administrative fee of SGD$100, $200 and $500 will be imposed for a 12, 24 and 36 months contract respectively.');
                                    //}
                        //END: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015
                                } else {
                                    //billAccIdFootNotesMap.put(sub.Zuora__Account__c, new Map<String, String>());
                                    //billAccIdFootNotesMap.get(sub.Zuora__Account__c).put('news', '<br/>If you have subscribed to a newspaper promotion package, no cancellation of subscription is allowed within the contracted period. Otherwise, an administrative fee of SGD$100, $200 and $500 will be imposed for a 12, 24 and 36 months contract respectively.');
                                }
                            } else {
                                if(billAccIdFootNotesMap.containsKey(sub.Zuora__Account__c)){
                                    if(!billAccIdFootNotesMap.get(sub.Zuora__Account__c).containsKey('promo')){
                                        billAccIdFootNotesMap.get(sub.Zuora__Account__c).put('promo', '<br/>If you have signed up a promotion package, please note that an administrative fee will be imposed if you terminate your subscription before the contract expiry date. The fee imposed will be based on the amount stated in the Terms and Condition of the promotion, and the fee may differ for each promotion.');
                                    }
                                } else {
                                    billAccIdFootNotesMap.put(sub.Zuora__Account__c, new Map<String, String>());
                                    billAccIdFootNotesMap.get(sub.Zuora__Account__c).put('promo', '<br/>If you have signed up a promotion package, please note that an administrative fee will be imposed if you terminate your subscription before the contract expiry date. The fee imposed will be based on the amount stated in the Terms and Condition of the promotion, and the fee may differ for each promotion.');
                                }
                            }
                        }
                        */
                        
                        if(sub.Billing_Type__c != 'Full Prepaid'){
                            //Start UD-2345 GdelRosario: updated the logic
                            if(sub.Payment_Mode_1__c == GlobalVariableClass.CREDIT_CARD){
                                sign += ' ^'; // START-END : UD-0683 6/15/2015 Alyana Navarro
                                if(billAccIdFootNotesMap.containsKey(sub.Zuora__CustomerAccount__c)){
                                    if(!billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).containsKey('^')){
                                        billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('^', '^Subscription is charged to your credit card on a monthly recurring basis.<br/>');
                                    }
                                } else {
                                    billAccIdFootNotesMap.put(sub.Zuora__CustomerAccount__c, new Map<String, String>());
                                    billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('^', '^Subscription is charged to your credit card on a monthly recurring basis.<br/>');
                                }
                            } else if(sub.Other_PaymentMethod_1__c == GlobalVariableClass.INVOICE){
                                sign += ' ##'; // START-END : UD-0683 6/15/2015 Alyana Navarro
                                if(billAccIdFootNotesMap.containsKey(sub.Zuora__CustomerAccount__c)){
                                    if(!billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).containsKey('##')){
                                        billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('##', '##Subscription will be invoiced on a monthly basis. Please make payment before the due dates indicated in the invoices.<br/>');
                                    }
                                } else {
                                    billAccIdFootNotesMap.put(sub.Zuora__CustomerAccount__c, new Map<String, String>());
                                    billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('##', '##Subscription will be invoiced on a monthly basis. Please make payment before the due dates indicated in the invoices.<br/>');
                                }
                            }
                        }else if (sub.Billing_Type__c == 'Full Prepaid'){
                            if(sub.Other_PaymentMethod_1__c == GlobalVariableClass.INVOICE){
                                sign += ' #'; // START-END : UD-0683 6/15/2015 Alyana Navarro
                                if(billAccIdFootNotesMap.containsKey(sub.Zuora__CustomerAccount__c)){
                                    if(!billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).containsKey('#')){
                                        billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('#', '#Please make payment for your subscription before the due date indicated in the invoice, which will be mailed to you separately.<br/>');
                                    }
                                } else {
                                    billAccIdFootNotesMap.put(sub.Zuora__CustomerAccount__c, new Map<String, String>());
                                    billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('#', '#Please make payment for your subscription before the due date indicated in the invoice, which will be mailed to you separately.<br/>');
                                }
                            }
                        }
                        //END UD-2345 GdelRosario: updated the logic
                        if(sub.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE){
                            sign += ' ^^'; // START-END : UD-0683 6/15/2015 Alyana Navarro
                            if(billAccIdFootNotesMap.containsKey(sub.Zuora__CustomerAccount__c)){
                                if(!billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).containsKey('^^')){
                                    billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('^^', '^^Please note that Subscribers will receive the magazine(s) 3 to 5 working days after release at newsstands.<br/>');
                                }
                            } else {
                                billAccIdFootNotesMap.put(sub.Zuora__CustomerAccount__c, new Map<String, String>());
                                billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('^^', '^^Please note that Subscribers will receive the magazine(s) 3 to 5 working days after release at newsstands.<br/>');
                            }
                        }
          //END: UD-1409/1410/1411/1412/1450 Jason A. / Von P. / James A. 06/15/2015                
                        if(sub.Zuora__TermSettingType__c == 'EVERGREEN'){
                            //UD-3720
                            // START : UD-2021 8/13/2015 Alyana Navarro
                            /*
                            if(everSubIdCaseIdMap.containsKey(sub.id)){
                                startEndDate = String.valueOf(sub.Zuora__SubscriptionStartDate__c.day()) + '/' 
                              + String.valueOf(sub.Zuora__SubscriptionStartDate__c.month()) + '/' 
                              + String.valueOf(sub.Zuora__SubscriptionStartDate__c.year()) +  ' - ' 
                              + String.valueOf(sub.Zuora__SubscriptionEndDate__c.day()) + '/' 
                              + String.valueOf(sub.Zuora__SubscriptionEndDate__c.month()) + '/' 
                              + String.valueOf(sub.Zuora__SubscriptionEndDate__c.year());
                            } else {
                                startEndDate = String.valueOf(sub.Zuora__SubscriptionStartDate__c.day()) + '/' 
                              + String.valueOf(sub.Zuora__SubscriptionStartDate__c.month()) + '/' 
                              + String.valueOf(sub.Zuora__SubscriptionStartDate__c.year()) +  ' - ' 
                              + 'Evergreen'; //START-END: UD-1114 05/19/2015 Jean Cariño
                            }
                            */
                            startEndDate = String.valueOf(sub.Zuora__SubscriptionStartDate__c.day()) + '/' 
                              + String.valueOf(sub.Zuora__SubscriptionStartDate__c.month()) + '/' 
                              + String.valueOf(sub.Zuora__SubscriptionStartDate__c.year()) +  ' - ' 
                              + 'Evergreen'; 
                            //UD-3720
                            // END : UD-2021 8/13/2015 Alyana Navarro
                            // START : UD-2286 8/14/2015 Removed by Jason A
                            /*if(billAccIdFootNotesMap.containsKey(sub.Zuora__CustomerAccount__c)){
                                if(!billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).containsKey('*')){
                                    billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('*', '*For your convenience, subscription(s) will be automatically renewed until terminated by Subscribers in writing with 30 days’ notice.<br/>');
                                }
                            } else {
                                billAccIdFootNotesMap.put(sub.Zuora__CustomerAccount__c, new Map<String, String>());
                                billAccIdFootNotesMap.get(sub.Zuora__CustomerAccount__c).put('*', '*For your convenience, subscription(s) will be automatically renewed until terminated by Subscribers in writing with 30 days’ notice.<br/>');
                            } */
                            // END : UD-2286 8/14/2015 Removed by Jason A
                        } else {
                        //UD-3720
                            startEndDate = String.valueOf(sub.Zuora__SubscriptionStartDate__c.day()) + '/' 
                          + String.valueOf(sub.Zuora__SubscriptionStartDate__c.month()) + '/' 
                          + String.valueOf(sub.Zuora__SubscriptionStartDate__c.year()) +  ' - ' 
                          + String.valueOf(sub.Order_Line_Item_Number_1__r.End_Date__c.day()) + '/' 
                          + String.valueOf(sub.Order_Line_Item_Number_1__r.End_Date__c.month()) + '/' 
                          + String.valueOf(sub.Order_Line_Item_Number_1__r.End_Date__c.year());
                        //UD-3720
                        }
                        subIdStartEndDateMap.put(sub.id, startEndDate);                                                          
                        subIdSubChargeMap.put(sub.id, subCharge);
                        subIdPriceSign.put(sub.Id, sign); // START-END : UD-0683 6/15/2015 Alyana Navarro
                    } //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
                } else if(sub.Subscription_Type_1__c == 'Delivery'){
                    if(recConIdBillTypeDelSubListMap.containsKey(sub.Zuora__CustomerAccount__c)){                               
                        if(recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).containsKey(sub.Recipient_Contact__c)){
                            if(sub.Billing_Type__c == 'Full Prepaid'){
                                if(recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).containsKey('Full Prepaid')){
                                    recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).get('Full Prepaid').add(sub);
                               } else {
                                    recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).put('Full Prepaid', new List<Zuora__Subscription__c>{sub});
                                }
                           } else {
                                if(recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).containsKey('Recurring')){
                                    recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).get('Recurring').add(sub);
                                } else {
                                    recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).put('Recurring', new List<Zuora__Subscription__c>{sub});
                                }
                            }
                        } else {                        
                            recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).put(sub.Recipient_Contact__c, new Map<String, List<Zuora__Subscription__c>>());
                            if(sub.Billing_Type__c == 'Full Prepaid'){
                                recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).put('Full Prepaid', new List<Zuora__Subscription__c>{sub});
                            } else {
                                recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).put('Recurring', new List<Zuora__Subscription__c>{sub});
                            }
                        }
                    } else {
                        recConIdBillTypeDelSubListMap.put(sub.Zuora__CustomerAccount__c, new Map<Id, Map<String, List<Zuora__Subscription__c>>>());
                        recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).put(sub.Recipient_Contact__c, new Map<String, List<Zuora__Subscription__c>>());
                        if(sub.Billing_Type__c == 'Full Prepaid'){
                            recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).put('Full Prepaid', new List<Zuora__Subscription__c>{sub});
                        } else {
                            recConIdBillTypeDelSubListMap.get(sub.Zuora__CustomerAccount__c).get(sub.Recipient_Contact__c).put('Recurring', new List<Zuora__Subscription__c>{sub});
                        }
                    }
                }
                //START UD-2015 Added by S.Puli - add postage fee
                else if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE){
                    if(postSubToMainSub_MAP.containsKey(sub.Id)){
                        //Start UD-2778 VPernicia 9/30/15
              subIdToPostageFee_MAP.put(postSubToMainSub_MAP.get(sub.Id), sub.Subscription_Charge__c.setScale(2, System.RoundingMode.HALF_UP));
              //End UD-2778 VPernicia 9/30/15
                        // START : UD-2148 7/29/2015 Alyana Navarro
                        if(billAcctIdTotalPostChargeMap.containsKey(sub.Zuora__CustomerAccount__c)){                     
                            Decimal totalPostAmountTemp = billAcctIdTotalPostChargeMap.get(sub.Zuora__CustomerAccount__c) + sub.Subscription_Charge__c;
                        // START : UD-2718 Sept-14-2015 Jason A - 2 decimal places format   
                            Decimal totalPostAmount = totalPostAmountTemp.setScale(2, System.RoundingMode.HALF_UP);
                        // END : UD-2718 Sept-14-2015 Jason A - 2 decimal places format 
                            billAcctIdTotalPostChargeMap.put(sub.Zuora__CustomerAccount__c, totalPostAmount);
                        } else {
                            billAcctIdTotalPostChargeMap.put(sub.Zuora__CustomerAccount__c, sub.Subscription_Charge__c);                     
                        }
                        // END : UD-2148 7/29/2015 Alyana Navarro
                    }
                }
                //END UD-2015 Added by S.Puli - add postage fee
                
                //START UD-2013 22-July-2015 Added by S.Puli - address based on record type                        
                Contact recipientContact = sub.Recipient_Contact__r;
                Contact billingContact = sub.Zuora__CustomerAccount__r.Billing_Contact__r;                      
                Map<String, Contact> conRecTypeContactMap = new Map<String, Contact>{
                    'Billing' => billingContact,
                    'Recipient' => recipientContact
                };
                
                
                Map<String, String> conRecTypeFinalAddress = formatAddress(conRecTypeContactMap);           
                if(!accIdToTopAddress_MAP.containsKey(sub.Zuora__CustomerAccount__c) && conRecTypeFinalAddress.get('Billing') != null){
                    accIdToTopAddress_MAP.put(sub.Zuora__CustomerAccount__c, conRecTypeFinalAddress.get('Billing'));
                }
                
                //Put in Map of Account ID to mid Address
                if(!accIdToMidAddress_MAP.containsKey(sub.Zuora__CustomerAccount__c) && conRecTypeFinalAddress.get('Recipient') != null){
                    accIdToMidAddress_MAP.put(sub.Zuora__CustomerAccount__c, conRecTypeFinalAddress.get('Recipient'));
                }
                // START : UD-2179 8/7/2015 Alyana Navarro          
                if(conRecTypeFinalAddress.get('Recipient') != null){
                    recIdRecAddress.put(sub.Recipient_Contact__c, conRecTypeFinalAddress.get('Recipient'));
                }
                // END : UD-2179 8/7/2015 Alyana Navarro
                //END UD-2013 22-July-2015 Added by S.Puli - address based on record type
            //} //Start/End D-3689 VPernicia 10/6/15 //START - END: D-3724 10/16 removed by Jason A.
            }
            catch(exception e){
            
            }
            // END : UD-2575 9/18/2015 Jason A. - adding Try Catch 
        } 
        //END: UD-1114 5/8/2015 Jean Cariño Modified Footnotes
        for(Id billingId : recConIdBillTypeDelSubListMap.keySet()){
            for(Id recConId : recConIdBillTypeDelSubListMap.get(billingId).keySet()){
                // START : UD-1738 7/4/2015 Alyana Navarro
                Decimal totalDelSub = 0.00;
                // START : UD-2009 7/22/2015 Alyana Navarro
                if(recConIdBillTypeDelSubListMap.get(billingId).get(recConId).containsKey('Full Prepaid')){
                    if(recConIdBillTypeDelSubListMap.get(billingId).get(recConId).get('Full Prepaid').size() > 0){            
                        for(Zuora__Subscription__c delSub : recConIdBillTypeDelSubListMap.get(billingId).get(recConId).get('Full Prepaid')){
                            if(delSub.Subscription_Charge__c != null){                          
                                //Start UD-2373 VPernicia 08/28/15
                                //if(totalDelSub < delSub.Subscription_Charge__c){                                
                                    //totalDelSub += delSub.Subscription_Charge__c;
                                //}
                                totalDelSub = totalDelSub + delSub.Subscription_Charge__c;
                                //Start UD-2373 VPernicia 08/28/15                          
                            } else {
                                totalDelSub = 0.00;
                            }     
                        }
                    }
                } else if(recConIdBillTypeDelSubListMap.get(billingId).get(recConId).containsKey('Recurring')){
                    if(recConIdBillTypeDelSubListMap.get(billingId).get(recConId).get('Recurring').size() > 0){
                        for(Zuora__Subscription__c delSub : recConIdBillTypeDelSubListMap.get(billingId).get(recConId).get('Recurring')){
                            //START: UD-0683 Jean Cariño 04/24/2015                   
                            Decimal tempDelSub = (delSub.Subscription_Charge__c == null ? 0 : delSub.Subscription_Charge__c);
                            // * Integer.valueOf(delSub.Term_Length__c == null ? 0 : delSub.Term_Length__c);
                            //END: UD-0683 Jean Cariño 04/24/2015                   
                            if(totalDelSub < tempDelSub){
                                totalDelSub = tempDelSub;
                            }                       
                        }            
                    }
                }
                // END : UD-2009 7/22/2015 Alyana Navarro
                // END : UD-1738 7/4/2015 Alyana Navarro

                // START : UD-1114 5/9/2015 Jean Cariño
                //if(recConIdBillAccountIdMap.containsKey(recConId)){                
                    //for(Id billingId : recConIdBillAccountIdMap.get(recConId)){
                Decimal total;
                if(billacctIdTotalSubChargeMap.containsKey(billingId)){
                    total = billacctIdTotalSubChargeMap.get(billingId);
                    total += totalDelSub;
                    billacctIdTotalSubChargeMap.put(billingId, total);
                } else {
                    billacctIdTotalSubChargeMap.put(billingId, total);
                }
                if(recConIdDelSubChargeMap.containsKey(billingId)){
                    recConIdDelSubChargeMap.get(billingId).put(recConId, totalDelSub);
                } else {
                    recConIdDelSubChargeMap.put(billingId, new Map<Id, Decimal>{
                        recConId => totalDelSub
                    });
                }
                    //}
                //}                                         
                // END : UD-1114 5/9/2015 Jean Cariño                                                  
            }
        }
        
        // START : UD-2148 7/29/2015 Alyana Navarro
        Decimal totalPostChargeTemp;
        Decimal finalTotal;
        for(Id billAccountId : billAcctIdTotalPostChargeMap.keySet()){
            if(billacctIdTotalSubChargeMap.containsKey(billAccountId)){
                totalPostChargeTemp = billAcctIdTotalPostChargeMap.get(billAccountId);
                finalTotal = billacctIdTotalSubChargeMap.get(billAccountId);
                finalTotal += totalPostChargeTemp;
                billacctIdTotalSubChargeMap.put(billAccountId, finalTotal);
            }
        }
        // END : UD-2148 7/29/2015 Alyana Navarro
    }
    
    //Start D-3722 VPernicia 10/20/15
    public Map<String, String> formatAddress(Map<String, Contact> conRecTypeContactMap){                
        String topAddress = '';
        String midAddress = '';
        Map<String, String> conRecTypeFinalAddressMap = new Map<String, String>();
        
        for(String conRecordType : conRecTypeContactMap.keySet()){



                        
            topAddress = AddressHelper.formatAddress(conRecTypeContactMap.get(conRecordType), false,false);
            midAddress = AddressHelper.formatAddress(conRecTypeContactMap.get(conRecordType), true,false);
            
            if(conRecordType == 'Billing'){
                conRecTypeFinalAddressMap.put(conRecordType, topAddress);
            } else if(conRecordType == 'Recipient'){
                conRecTypeFinalAddressMap.put(conRecordType, midAddress);
            }
        }
        
        return conRecTypeFinalAddressMap;
    }
    //End D-3722 VPernicia 10/20/15
    
    global void finish(Database.BatchableContext BC)
    {
        //START: D-4266 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        //START: D-4363 2-12-2016 Added by Kristine Balaoing - added callout to CTRL M
        Logger loggerFinish; 
            
        if(!Test.isRunningTest()){
            loggerFinish = new Logger('AcknowledgmentLetterEmail', 'SP054');
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
        //END: D-4363 2-12-2016 Added by Kristine Balaoing
        //END: D-4266 1-13-2016 Added by Kristine Balaoing
    }
}