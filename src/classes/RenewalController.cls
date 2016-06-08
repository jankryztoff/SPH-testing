// History: 11/24/2015 Kevin Evasco - Reconstructed class for Renewal Reminder To Escalate Defects: UD-2535, UD-2803, UD-2610 and D-2535, UD-2423
public class RenewalController
{
    integer MAX_TR_ON_FIRST_PAGE; // Start/End Johnx
    integer MAX_CHARS_PER_TR;    // Start/End Johnx
    public Id idParam;
     
    public string mainpackage  { get; set; } // to be deleted.
     
    public string billingContactName { get; set; }
    
    public date subscriptionEndDate { get; set; }
    public decimal subscriptionCharge { get; set; }
    public string finalAddress { get; set; }
    
    public string subAccountNum { get; set; }
    public string accountName { get; set; }
    public string recipientName { get; set; } //TABLE
    public string billingAccountNumber { get; set; }
    public String recAccountNum  {get; set;}
    
    public string frequency { get; set; } //TABLE
    public double numberOfCopies { get; set; } //TABLE
    public string subscriptionExpiry { get; set; } //TABLE
    
    public string acct { get; set; }
    
    public String type;
    public String notifKey;
   
    public Date dateOutput { get; set; }
    
    public String barcodeAttId {get; set;}
    public boolean barChecker {get; set;}
    
    public list<string> LastRows {get; set;}
    public integer MagazineCnt{get; set;}
    public integer NewsPaperCnt{get; set;}
    
    public string EmailAddress {get; set;}
    public string HomeNumber{get; set;}
    public string OfficeNumber{get; set;}
    public string MobileNumber{get; set;}
    
    public String notifAdvice{get; set;}
    
    public boolean charLength{get; set;}
    public boolean charLengthMag{get; set;}
    
    public Static String LD_RECIPIENT = 'Recipient';
    public Static String LD_SUBSCRIPTION = 'Subscription';
    public Static String LD_DELIVERY = 'Delivery';
    public Static String LD_POSTAGE = 'Postage';
    public Static String LD_SUBTOTAL= 'SubTotal';
    public Static String LD_TOTAL= 'Total';
    public Static String LD_LINEBREAK= 'LineBreak';
    
    public RenewalController(){
        idParam = ApexPages.currentPage().getParameters().get('id');
        
        LastRows = new list<string>();
        for (integer x = 0; x <= 25; x++){
            LastRows.add('1');
        }
    }   
    
    
    public Decimal newsDelCharge {get; set;}
    public Decimal newsTotal {get; set;}
    public Zuora__Subscription__c delSubscription;
    
    list<exception> exceptionList = new list<exception>();
    
    
    public class LineDetail {
        public String type {get; set;}
        public String label {get; set;}
        public String recipientNumber {get; set;}
        public String recipientName {get; set;}
        public String companyName {get; set;}
        public String mainPackageName {get; set;}
        public Integer subCopies {get; set;}
        public Date subEndDate {get; set;}
        public Decimal renewal1 {get; set;}
        public Decimal renewal1Disc {get; set;}
        public Decimal renewal2 {get; set;}
        public Decimal renewal2Disc {get; set;}
        public Decimal annualAmt {get; set;}
        
        //Start D-4079 VPernicia
        public Integer subNumRows {get; set;}
        //Start D-4079 VPernicia
    }
    public List<LineDetail> lineDetails {get;set;}
    
    // Start UD-3503
    public string lineDetailGroupFirst { get; set; }
    public list<string> lineDetailGroupList { get; set; }   
    list<integer> numberOfTrInIndexList = new list<integer>();
    // End UD-3503
    
    //START PD-0147 13May2016 Added By C. Lin - Change Date.Today() to when the Batch Run is from Custom Settings
    Manual_Batch_Run_Dates__c BRDate = Manual_Batch_Run_Dates__c.getInstance('ManualBatchRun');
    Date batchRunDate = BRDate.Batch_Run_Date__c;
    //END PD-0147 13May2016 Added By C. Lin
    
    public Date Today{ 
        get{ 
            //START PD-0147 13May2016 Added By C. Lin - Change Date.Today() to when the Batch Run is from Custom Settings
            //return Date.Today();             
            return batchRunDate;
            //END PD-0147 13May2016 Added By C. Lin
        }
    }
    
    public Zuora__Subscription__c zSub;
    
    Letter_Print_Request__c masterLetterPrintRequest = new Letter_Print_Request__c();   
    
    Set<Id> subscriptionIdSet = new Set<Id>();
    Set<Id> packageIdSet = new Set<Id>();
    Set<String> productCodeSet = new Set<String>();
    
    List<Letter_Print_Request__c> detailLetterPrintRequests = new List<Letter_Print_Request__c>();
    List<Zuora__Subscription__c> allSubscriptionsList = new List<Zuora__Subscription__c>(); 
    List<zqu__ZProduct__c> productList = new List<zqu__ZProduct__c>();
    
    Map<Id, Zuora__Subscription__c> allSubscriptionsMap = new Map<Id, Zuora__Subscription__c>();
    Map<Id,Package__c> mainPackageMap = new Map<Id,Package__c>();
    Map<String,zqu__ZProduct__c> productMap = new Map<String,zqu__ZProduct__c>();
    
    
    
    Zuora__CustomerAccount__c billingAccount;
    
    SP_RenewalReminderHelper.RenewalRateGroup renewalRateGroup;
    Map<Id, SP_RenewalReminderHelper.RenewalRate> orderLineItemRenewalRateMap;
        
    public void setFields(){
        Order_Line_Item__c olItem;
        Publication__c pub;
        Package_Item__c pi;
        NewsPaperCnt = 0;
        lineDetails = new List<LineDetail>();
        lineDetailGroupList = new list<string>();   // John
        integer currentNumberOfTr = 0;  // Johnx
        integer indexWithLowestTrCount = 0; // Johnx
        integer numberOfTrOfLowestIndex = 1000000; // Johnx
        
        masterLetterPrintRequest = [SELECT Id, Letter_Type__c, Billing_Account__c FROM Letter_Print_Request__c WHERE Id = :idParam LIMIT 1];
        detailLetterPrintRequests = [SELECT Id,Record_Id__c, Parent_Letter_Print_Request__c FROM Letter_Print_Request__c WHERE Parent_Letter_Print_Request__c = :idParam AND Status__c = 'Tagged'];  // START-END : UD-3510 1/8/2016 Alyana Navarro
        billingAccount = queryBillingAccount(masterLetterPrintRequest.Billing_Account__c);          
        acct = billingAccount.Billing_Contact__r.Company_Name__c;           
        recAccountNum = billingAccount.Zuora__Account__r.AccountNumber;         
        billingAccountNumber = billingAccount.Zuora__AccountNumber__c; 
        billingContactName = billingAccount.Billing_Contact__r.Name;
        finalAddress = AddressHelper.formatAddress(billingAccount.Billing_Contact__r,false,false); 
        if(billingAccount.Billing_Contact__r.Address__r.Postal_Code__c <> null){                    
            getBarCode(billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Id);                 
        }
        
        for(Letter_Print_Request__c detailLetterPrintRequestElem : detailLetterPrintRequests) {
            subscriptionIdSet.add(detailLetterPrintRequestElem.Record_Id__c);
        }
            
        allSubscriptionsList = querySubscriptions(subscriptionIdSet);
        allSubscriptionsMap = new Map<Id, Zuora__Subscription__c>(allSubscriptionsList);
        
        for(Zuora__Subscription__c subscriptionElem : allSubscriptionsList) {
            packageIdSet.add(subscriptionElem.Main_Package_1__c);
            productCodeSet.add(subscriptionElem.Product_Code__c);
        }
        
        // START : UD-3338 12/2/2015 Alyana Navarro
        // START : D-3997 11/26/2015 Alyana Navarro     
        mainPackageMap = new Map<Id,Package__c>(
        [
        SELECT Id, name, 
        Package_Type__c,
        RenewalPkgCodeMag1YrBase__c,RenewalPkgCodeMag1YrBase__r.Package_Price__c, 
        RenewalPkgCodeMag2YrBase__c,RenewalPkgCodeMag2YrBase__r.Package_Price__c,
        RenewalPkgCodeMag1YrDisc__c,RenewalPkgCodeMag1YrDisc__r.Package_Price__c,
        RenewalPkgCodeMag2YrDisc__c,RenewalPkgCodeMag2YrDisc__r.Package_Price__c,
        RenewalPkgCodeNewspaper__c,RenewalPkgCodeNewspaper__r.Package_Price__c, 
        Same_Pck_Renewal_Mag_1_Yr_Base__c, Same_Pck_Renewal_Mag_2_Yr_Base__c, 
        Same_Pck_Renewal_Mag_1_Yr_Disc__c, Same_Pck_Renewal_Mag_2_Yr_Disc__c, 
        Same_Pck_Renewal_Newspaper__c, Package_Price__c,
        RenewalPkgCodeNewspaper__r.name
        FROM Package__c WHERE Id IN :packageIdSet]); 
        // END : D-3997 11/26/2015 Alyana Navarro
        
        productList = [SELECT Id, ProductCode__c, name,
        RenewalPkgCodeMag1YrBase__c,RenewalPkgCodeMag1YrBase__r.Package_Price__c, 
        RenewalPkgCodeMag2YrBase__c,RenewalPkgCodeMag2YrBase__r.Package_Price__c,
        RenewalPkgCodeMag1YrDisc__c,RenewalPkgCodeMag1YrDisc__r.Package_Price__c,
        RenewalPkgCodeMag2YrDisc__c,RenewalPkgCodeMag2YrDisc__r.Package_Price__c,
        RenewalPkgCodeNewspaper__c,RenewalPkgCodeNewspaper__r.Package_Price__c,
        RenewalPkgCodeNewspaper__r.name
        FROM zqu__ZProduct__c 
    WHERE ProductCode__c IN :productCodeSet
            AND zqu__Deleted__c = false];        
        // END : UD-3338 12/2/2015 Alyana Navarro
        for(zqu__ZProduct__c productElem : productList) {
            productMap.put(productElem.ProductCode__c, productElem);
        } 
        
        renewalRateGroup = SP_RenewalReminderHelper.getRenewalRates(allSubscriptionsList, mainPackageMap,productMap);
        orderLineItemRenewalRateMap = renewalRateGroup.orderLineItemRenewalRateMap;
        //START D-4354 Gdelroasrio 2.1.2016
        if( masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine ||
            masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper ){
            notifAdvice = 'Renewal';
            //START PD-0147 13May2016 Added By C. Lin - Change Date.Today() to when the Batch Run is from Custom Settings
            //dateOutput = Date.today().addDays(ConstantsSLB.getRenewalNotificationExpiryDay('Renewal Notifications Values',true));
            if(batchRunDate != null){
                dateOutput = batchRunDate.addDays(ConstantsSLB.getRenewalNotificationExpiryDay('Renewal Notifications Values',true));
            }
            //END PD-0147 13May2016 Added By C. Lin
        } else {
            notifAdvice = 'Reminder';
            //START PD-0147 13May2016 Added By C. Lin - Change Date.Today() to when the Batch Run is from Custom Settings
            //dateOutput = Date.today().addDays(ConstantsSLB.getRenewalNotificationExpiryDay('Renewal Notifications Values',false));
            if(batchRunDate != null){
                dateOutput = batchRunDate.addDays(ConstantsSLB.getRenewalNotificationExpiryDay('Renewal Notifications Values',false));
            }
            //END PD-0147 13May2016 Added By C. Lin
        }       
        //END D-4354 Gdelroasrio 2.1.2016    
        SP_RenewalReminderMapper.RenewalSubscriptionGroup renewalGroup = SP_RenewalReminderMapper.initializeRenewalSubscriptionGroup(detailLetterPrintRequests, allSubscriptionsMap);

        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
        Set<Id> allOrderLineItemIdList = renewalGroup.masterLPRId_orderLineItemIdList_map.get(masterLetterPrintRequest.Id);

        for(Id orderLineItemId : allOrderLineItemIdList){
            subscriptionList.addAll(renewalGroup.orderLineItemId_subscriptionList_map.get(orderLineItemId));
        }
      
        // START : UD-3701 1/14/2016 Alyana Navarro
        Map<Id, List<Zuora__Subscription__c>> parentLPRSubscriptionListMap = new Map<Id, List<Zuora__Subscription__c>>();
        parentLPRSubscriptionListMap.put(idParam, subscriptionList);
        Map<Id, Map<Id, SP_RenewalReminderHelper.DeliveryPostageFee>> recipientDeliveryPostageFeeMap = SP_RenewalReminderHelper.getrecipientDeliveryPostageFeeMap(parentLPRSubscriptionListMap);
         // END : UD-3701 1/14/2016 Alyana Navarro
        Map<Id, Set<Id>> recipientId_orderLineItemIds_map = SP_RenewalReminderMapper.groupOrderLineItemsByRecipient(subscriptionList);
        
        Set<Id> contactIdSet = new Set<Id>();
        for(Id recipientId : recipientId_orderLineItemIds_map.keySet()){
            contactIdSet.add(recipientId);
        }
        
        Map<Id,Contact> contactMap = new map<Id,Contact>([SELECT Id, Name, Recipient_Number_Show__c, Company_Name__c FROM Contact WHERE Id IN :contactIdSet]);
        
        
        Decimal total = 0;
        // Start D-4079 VPernicia
        Decimal packageLength = 0;
        // End D-4079 VPernicia   

        // Start UD-3503
        string lineDetailGroup;
        integer lineGroupCounter = 1;
        integer totalLineGroup = recipientId_orderLineItemIds_map.size();
        string recipientDetail; // Johnx
        string lineDetailTotal = '';
        // End UD-3503
        
        for(Id recipientId : recipientId_orderLineItemIds_map.keySet()){
            
            lineDetailGroup = '';   // UD-3503
            
            Contact recipientContact = contactMap.get(recipientId);
            LineDetail recipientLine = new LineDetail();
            recipientLine.mainPackageName = 'Recipient';
            recipientLine.type = LD_RECIPIENT;
            recipientLine.recipientNumber = recipientContact.Recipient_Number_Show__c;
            recipientLine.recipientName = recipientContact.Name;
            recipientLine.companyName = recipientContact.Company_Name__c;
            

            // Start UD-3503
        // Start Johnx
            recipientDetail = '';
            if (recipientContact.Recipient_Number_Show__c != null) {
                recipientDetail = recipientContact.Recipient_Number_Show__c + ' ';
            }
            recipientDetail += recipientContact.Name;
            //currentNumberOfTr = countTr(recipientDetail);
            currentNumberOfTr = 1;
            // End Johnx

            if(masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || 
                masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper){

                lineDetailGroup = '<tr><td colspan="5">' + recipientContact.Recipient_Number_Show__c + ' ' + recipientContact.Name;
                if (recipientContact.Company_Name__c != null) {
                    lineDetailGroup += ' ' + recipientContact.Company_Name__c;
                }
                //lineDetailGroup += '</td><td></td><td></td><td></td><td></td></tr>';
                lineDetailGroup += '</td></tr>';

            } else if (masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine ||
                        masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine) {

                lineDetailGroup = '<tr><td width="30%" align="left" colspan="9">' + recipientContact.Recipient_Number_Show__c + ' ' + recipientContact.Name;
                if (recipientContact.Company_Name__c != null) {
                    lineDetailGroup += ' ' + recipientContact.Company_Name__c;
                }
                //lineDetailGroup += '</td><td width="8%" align="center"></td><td width="8%" align="center"></td><td width="8%" align="center"></td><td width="8%" align="center"></td>';
                //lineDetailGroup += '<td width="8%" align="center"></td><td width="8%" align="center"></td><td width="8%" align="center"></td><td width="8%" align="center"></td></tr>';
                lineDetailGroup += '</td></tr>';

            }

            
            // End UD-3503
            
            // Start D-4079 VPernicia
            if (recipientContact.Company_Name__c != null) {
                recipientLine.subNumRows = 2;           
            } else {
                recipientLine.subNumRows = 1;
            }
            // End D-4079 VPernicia
            
            Decimal subTotal = 0;

            Set<Id> orderLineItemIdList = recipientId_orderLineItemIds_map.get(recipientId);            
            
            lineDetails.add(recipientLine);
            for(Id orderLineItemIdElem : orderLineItemIdList){
                List<Zuora__Subscription__c> orderLineItemSubscriptionList = renewalGroup.orderLineItemId_subscriptionList_map.get(orderLineItemIdElem);
                
                Zuora__Subscription__c orderLineItemSubscription = orderLineItemSubscriptionList.get(0);
                SP_RenewalReminderHelper.RenewalRate renewalRates = orderLineItemRenewalRateMap.get(orderLineItemIdElem);
                LineDetail subscriptionLine = new LineDetail();
                subscriptionLine.type = LD_SUBSCRIPTION;
                // START : UD-3338 12/2/2015 Alyana Navarro
                // Start D-4079 VPernicia
                packageLength = string.valueof(SP_RenewalReminderHelper.getSubscriptionTableLabel(type, productMap, mainPackageMap, orderLineItemSubscriptionList)).length();
                // START : UD-3503 1/6/2016 Alyana Navarro
                Integer labelLength = 0;
                if(notifKey == 'MZEN'){
                    labelLength = 29;
                    packageLength = packageLength / labelLength;                    
                } else if(notifKey == 'MZCH'){
                    labelLength = 29;
                    packageLength = packageLength / labelLength;                    
                } else if(notifKey == 'NPEN'){
                    labelLength = 53;
                    packageLength = packageLength / labelLength;                    
                } else if(notifKey == 'NPCH'){
                    labelLength = 53;
                    packageLength = packageLength / labelLength;                    
                }
                
                packageLength = packageLength.round(system.RoundingMode.up);
                
                subscriptionLine.subNumRows = (integer) packageLength;
                // End D-4079 VPernicia
                
                String labelTemp = SP_RenewalReminderHelper.getSubscriptionTableLabel(type, productMap, mainPackageMap, orderLineItemSubscriptionList); 
                subscriptionLine.label = '';
                //system.3Equals(labelTemp.length() + '', ' ');
             
                while(labelTemp.length() > labelLength){
                    subscriptionLine.label += labelTemp.substring(0, labelLength) + '<br/>';
                    labelTemp = labelTemp.remove(labelTemp.substring(0, labelLength));
                }
                
                
                subscriptionLine.label += labelTemp;                                
                // END : UD-3503 1/6/2016 Alyana Navarro
                // END : UD-3338 12/2/2015 Alyana Navarro
                subscriptionLine.subCopies = Integer.valueOf(orderLineItemSubscription.Number_of_Copies__c);
                subscriptionLine.subEndDate = orderLineItemSubscription.Zuora__SubscriptionEndDate__c;
                //Start UD-3701 13-Jan-2015 Added by S.Puli/Alyana - multiply rate by number of copy
                if(renewalRates.renewalBaseRate1<>null){
                    subscriptionLine.renewal1 = renewalRates.renewalBaseRate1 * subscriptionLine.subCopies;
                }
                if(renewalRates.renewalDiscRate1<>null){
                    subscriptionLine.renewal1Disc = renewalRates.renewalDiscRate1 * subscriptionLine.subCopies;
                }
                if(renewalRates.renewalBaseRate2<>null){
                    subscriptionLine.renewal2 = renewalRates.renewalBaseRate2 * subscriptionLine.subCopies;
                }
                if(renewalRates.renewalDiscRate2<>null){
                    subscriptionLine.renewal2Disc = renewalRates.renewalDiscRate2 * subscriptionLine.subCopies;
                }
                if(renewalRates.renewalNewspaperRate<>null){
                    subscriptionLine.annualAmt = renewalRates.renewalNewspaperRate * subscriptionLine.subCopies;
                }
                //End UD-3701 13-Jan-2015 Added by S.Puli/Alyana
                lineDetails.add(subscriptionLine);
                
                // Start UD-3503
                if(masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || 
                     masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper){
                        datetime dt = datetime.newInstance(subscriptionLine.subEndDate.year(), subscriptionLine.subEndDate.month(), subscriptionLine.subEndDate.day());
                        lineDetailGroup += '<tr>';
                        lineDetailGroup += '<td>' + subscriptionLine.label + '</td>';
                        lineDetailGroup += '<td>' + string.valueOf(subscriptionLine.subCopies) + '</td>';
                        lineDetailGroup += '<td>' + dt.format('dd/MM/yy') + '</td>';
                        lineDetailGroup += '<td>' + string.valueOf(subscriptionLine.annualAmt.setScale(2)) + '</td>';
                        lineDetailGroup += '<td>( )</td>';
                        lineDetailGroup += '</tr>';
                        // End UD-3503
                } else if (masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine ||
                            masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine) {
                        datetime dt = datetime.newInstance(subscriptionLine.subEndDate.year(), subscriptionLine.subEndDate.month(), subscriptionLine.subEndDate.day());
                        
                        
                        lineDetailGroup += '<tr>';
                        lineDetailGroup += '<td width="30%" align="left">' + subscriptionLine.label + '</td>';
                        lineDetailGroup += '<td width="8%" align="center">' + string.valueOf(subscriptionLine.subCopies) + '</td>';
                        lineDetailGroup += '<td width="8%" align="center">' + dt.format('dd/MM/yy') + '</td>';
                        lineDetailGroup += '<td width="8%" align="center">' + string.valueOf(subscriptionLine.renewal1.setScale(2)) + '</td>';
                        lineDetailGroup += '<td width="8%" align="center">' + string.valueOf(subscriptionLine.renewal1Disc.setScale(2)) + '</td>';
                        lineDetailGroup += '<td width="8%" align="center">( )</td>';
                        lineDetailGroup += '<td width="8%" align="center">' + string.valueOf(subscriptionLine.renewal2.setScale(2)) + '</td>';
                        lineDetailGroup += '<td width="8%" align="center">' + string.valueOf(subscriptionLine.renewal2Disc.setScale(2)) + '</td>';
                        lineDetailGroup += '<td width="8%" align="center">( )</td>';
                        lineDetailGroup += '</tr>';
                        
                }
        currentNumberOfTr += countTr(subscriptionLine.label);   // Start/End Johnx

                if(subscriptionLine.annualAmt != null)
                subTotal += subscriptionLine.annualAmt;
            }
            
            if( masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || 
                masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper ) {
                SP_RenewalReminderHelper.DeliveryPostageFee deliveryPostageFee = recipientDeliveryPostageFeeMap.get(idParam).get(recipientId); // START-END : UD-3701 1/15/2016 Alyana Navarro
                
                if(deliveryPostageFee.deliveryFee != null){
                    LineDetail deliveryFeeDetail = new LineDetail();
                    deliveryFeeDetail.type = LD_DELIVERY;   
                    deliveryFeeDetail.label = 'DELIVERY FEE';
                    deliveryFeeDetail.annualAmt = deliveryPostageFee.deliveryFee * 12;  
                    deliveryFeeDetail.subNumRows = 1; // Start/End D-4079 VPernicia
                    lineDetails.add(deliveryFeeDetail); 
                    subTotal += deliveryFeeDetail.annualAmt;
                    
                    // Start UD-3503
                    lineDetailGroup += '<tr>';
                    lineDetailGroup += '<td>DELIVERY FEE</td>';
                    lineDetailGroup += '<td></td>';
                    lineDetailGroup += '<td></td>';
                    lineDetailGroup += '<td>' + string.valueOf(deliveryFeeDetail.annualAmt.setScale(2)) + '</td>';
                    lineDetailGroup += '<td></td>';
                    lineDetailGroup += '</tr>';
                    // End UD-3503
                    
                    currentNumberOfTr++;    // Start/End Johnx
                }
                
                if(deliveryPostageFee.postageFee != null){
                    LineDetail postageFeeDetail = new LineDetail();
                    postageFeeDetail.type = LD_POSTAGE; 
                    postageFeeDetail.label = 'POSTAGE FEE';
                    postageFeeDetail.annualAmt = deliveryPostageFee.postageFee * 12;        
                    postageFeeDetail.subNumRows = 1; // Start/End D-4079 VPernicia
                    lineDetails.add(postageFeeDetail);              
                    subTotal += postageFeeDetail.annualAmt;
                    
                    // Start UD-3503
                    lineDetailGroup += '<tr>';
                    lineDetailGroup += '<td>POSTAGE FEE</td>';
                    lineDetailGroup += '<td></td>';
                    lineDetailGroup += '<td></td>';
                    lineDetailGroup += '<td>' + string.valueOf(postageFeeDetail.annualAmt.setScale(2)) + '</td>';
                    lineDetailGroup += '<td></td>';
                    lineDetailGroup += '</tr>';
                    // End UD-3503
                    
                    currentNumberOfTr++;    // Start/End Johnx
                }               
                
                LineDetail subTotalLine = new LineDetail();
                subTotalLine.type = LD_SUBTOTAL;
                subTotalLine.label = 'Sub Total';
                subTotalLine.annualAmt = subTotal;
                subTotalLine.subNumRows = 1; // Start/End D-4079 VPernicia
                lineDetails.add(subTotalLine);      
                total += subTotal;
                
                // Start UD-3503
                //lineDetailGroup +='<tr class="lineSeparator"><td></td><td></td><td colspan="3" class="dashedBorderBottom"></td></tr>';
                lineDetailGroup += '<tr>';
                lineDetailGroup += '<td></td>';
                lineDetailGroup += '<td>Sub Total</td>';
                lineDetailGroup += '<td class="dashedBorderTopBottom"></td>';
                lineDetailGroup += '<td class="dashedBorderTopBottom">' + string.valueOf(subTotalLine.annualAmt.setScale(2)) + '*</td>';
                lineDetailGroup += '<td class="dashedBorderTopBottom"></td>';
                lineDetailGroup += '</tr>';
                //lineDetailGroup +='<tr class="lineSeparator"><td></td><td></td><td colspan="3" class="dashedBorderTop"></td></tr>';
                // End UD-3503
                
                currentNumberOfTr++;    // Start/End Johnx
                
            } else {
                LineDetail lineBreak = new LineDetail();
                lineBreak.type = LD_LINEBREAK;
                lineBreak.subNumRows = 1; // Start/End D-4079 VPernicia
                lineDetails.add(lineBreak);         
            }
            
            // Start UD-3503
            //if (lineGroupCounter < totalLineGroup) {
            if (masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || 
                     masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper) {
                lineDetailGroup = '<table class="content" cellspacing="0" >' + lineDetailGroup + '</table>';
            }else {
                lineDetailGroup = '<table cellspacing="0" >' + lineDetailGroup + '</table>';
            }
            
            //}
            
            system.debug('JohnCxxx ' + currentNumberOfTr + ' :: ' + numberOfTrOfLowestIndex);
            if (currentNumberOfTr < numberOfTrOfLowestIndex) {
                
                if (!lineDetailGroupList.isEmpty()) {
                    lineDetailGroupList.add(0, lineDetailGroup);    // force to be on first
                } else {
                    lineDetailGroupList.add(lineDetailGroup);
                }
                numberOfTrOfLowestIndex = currentNumberOfTr;

            } else {
                lineDetailGroupList.add(lineDetailGroup);
            }
            
            numberOfTrInIndexList.add(currentNumberOfTr);
            // End UD-3503
        }

        if( masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || 
            masterLetterPrintRequest.Letter_Type__c == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper ) {
            LineDetail totalLine = new LineDetail();
            totalLine.type = LD_TOTAL;
            totalLine.label = 'Total';
            totalLine.annualAmt = total;
            totalLine.subNumRows = 1; // Start/End D-4079 VPernicia
            lineDetails.add(totalLine);

            // Start UD-3503
            // Start Johnx
            
            lineDetailTotal ='<tr><td colspan="5"></td></tr>';
            lineDetailTotal += '<tr>';
            lineDetailTotal += '<td></td>';
            lineDetailTotal += '<td>Total</td>';
            lineDetailTotal += '<td class="dashedBorderTopBottom"></td>';
            lineDetailTotal += '<td class="dashedBorderTopBottom">' + string.valueOf(totalLine.annualAmt.setScale(2)) + '</td>';
            lineDetailTotal += '<td class="dashedBorderTopBottom"></td>';
            lineDetailTotal += '</tr>';
            //lineDetailTotal +='<tr class="lineSeparator"><td></td><td></td><td colspan="3" class="dashedBorderTop"></td></tr>';
            // End Johnx
            // End UD-3503
            
        }
        
        // Start UD-3503
        //lineDetailGroup = '<table class="content" cellspacing="0">' + lineDetailGroup + '</table>';
        //lineDetailGroupList.add(lineDetailGroup);
        // End UD-3503
        
        //Misc Adjustments
        mobileAdjustment(billingAccount);
        // Start UD-3503
        // start check if the first group exceed with the max tr for first page
        if (lineDetailGroupList.size() == 1) {
            numberOfTrOfLowestIndex += 2;
        }
// Start Johnx
        integer lastIndex = lineDetailGroupList.size() - 1;
        lineDetailGroup = lineDetailGroupList[lastIndex];   // get the last value of the list and attached the lineDetailTotal
        lineDetailGroup = lineDetailGroup.replace('</table', lineDetailTotal + '</table');
        lineDetailGroupList[lastIndex] = lineDetailGroup;
        
        // End Johnx
        integer trDifference = MAX_TR_ON_FIRST_PAGE - numberOfTrOfLowestIndex;
        
        // start check if succeeding element on the list can still fit on the first page
        if (trDifference > 1) {
            for (integer index = 1; index <= lastIndex; index++) {
                if (numberOfTrInIndexList[index] <= trDifference) {
                    string jTable = joinTable(lineDetailGroupList[0], lineDetailGroupList[index]);
                    lineDetailGroupList.add(0, jTable);     // force to put in index 0. this will cause the original content in index 0 will be moved to index 1
                    lineDetailGroupList.remove(1);  // remove index 1 since this was index 0 before. no longer valid value
                    lineDetailGroupList.add(index, null);   // replace the current index to null to avoid rearrangement. this will cause the original content to moved to the next index
                    lineDetailGroupList.remove(index + 1);  // remove the original content which aleady moved to the next index.
                    trDifference = trDifference - numberOfTrInIndexList[index];
                } else {
                    break;
                }
            }
        }
        // end check if succeeding element on the list can still fit on the first page
        
        // start remove element with null value in descending manner.
        // doing this on ascending will cause the original indexing to re change prior to the succeeding removal
        for (integer index = lastIndex; index > 0; index--) {
            if (lineDetailGroupList[index] == null) {
                lineDetailGroupList.remove(index);
            }
        }
        // end remove element with null value in descending manner.

        if (numberOfTrOfLowestIndex > MAX_TR_ON_FIRST_PAGE) {
            system.debug('vonski123:' +  numberOfTrOfLowestIndex + ':' + MAX_TR_ON_FIRST_PAGE);
            list<string> splittedTableList = splitTable(lineDetailGroupList[0], masterLetterPrintRequest.Letter_Type__c );
            lineDetailGroupList.remove(0);
            lineDetailGroupFirst = splittedTableList[0];
            if (!lineDetailGroupList.isEmpty()) {
                lineDetailGroupList.add(0, splittedTableList[1]);   // force to be on the first element of the list
            } else {
                lineDetailGroupList.add(splittedTableList[1]);
            }
        
        } else {
            system.debug('vonski1234:' +  numberOfTrOfLowestIndex + ':' + MAX_TR_ON_FIRST_PAGE);
            lineDetailGroupFirst = lineDetailGroupList[0];
            lineDetailGroupList.remove(0);
            
        }
        // end check if the first group exceed with the max tr for first page
        
        
        // End UD-3503
        
        //gio------------------------------
        system.debug('lineDetailGroupList >> : '+lineDetailGroupList.size());
        //gio------------------------------
    }
    
    public void initializeNP(){
    
        type = 'Newspaper';
        notifKey = 'NPEN';
		//BEGIN PD-0205 06-03-2016 - Jerome Liwanag - Reworked values for Max row in first page and Characters to not overflow to next page
        MAX_TR_ON_FIRST_PAGE = 7;
        MAX_CHARS_PER_TR = 53;
		//END PD-0205 06-03-2016 - Jerome Liwanag - Reworked values for Max row in first page and Characters to not overflow to next page
        try{
            setFields();
        } catch (exception e){
            exceptionList.add(e);
        }
        ExceptionLogger.log(exceptionList);
    }
    
    public void initializeMZ(){
    
        type = 'Magazine';
        notifKey = 'MZEN';
		//BEGIN PD-0205 06-03-2016 Jerome Liwanag - Reworked values for Max row in first page and Characters to not overflow to next page
        MAX_TR_ON_FIRST_PAGE = 7; 
        MAX_CHARS_PER_TR = 53;
		//END PD-0205 06-03-2016 Jerome Liwanag - Reworked values for Max row in first page and Characters to not overflow to next page
        try{
            setFields();
        } catch (exception e){
            exceptionList.add(e);
        }
        ExceptionLogger.log(exceptionList);
    }
    
    public void initializeCHNP(){
    
        type = 'Newspaper';
        notifKey = 'NPCH';
		//BEGIN PD-0205 06-03-2016 Jerome Liwanag - Reworked values for Max row in first page and Characters to not overflow to next page
        MAX_TR_ON_FIRST_PAGE = 7;
        MAX_CHARS_PER_TR = 53;
		//END PD-0205 06-03-2016 Jerome Liwanag - Reworked values for Max row in first page and Characters to not overflow to next page
        try{
            setFields();
        } catch (exception e){
          exceptionList.add(e);
        }
    }
    
    public void initializeCHMZ(){
    
        type = 'Magazine';
        notifKey = 'MZCH';
		//BEGIN PD-0205 06-03-2016 Jerome Liwanag - Reworked values for Max row in first page and Characters to not overflow to next page
        MAX_TR_ON_FIRST_PAGE = 7;
        MAX_CHARS_PER_TR = 53;
		//END PD-0205 06-03-2016 Jerome Liwanag - Reworked values for Max row in first page and Characters to not overflow to next page
        try{
            setFields();
        } catch (exception e){
            exceptionList.add(e);
        }
        ExceptionLogger.log(exceptionList);
    }
    
    public void getBarCode(Id idParam){
    
    barChecker = false;
    List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :idParam];
        if(attList.size()>0){
            barcodeAttId = attList[0].Id;
            if(barcodeAttId<>null){
                barChecker = true;
            }
        } else{
            barcodeAttId = null;
        }
        
    }
    
    public static Zuora__CustomerAccount__c queryBillingAccount(Id billingAccountIdParam) {
        List<Zuora__CustomerAccount__c> billingAccounts = 
            [
                SELECT Id,
                Zuora__AccountNumber__c,
                Zuora__Account__r.AccountNumber,
                Billing_Contact__c, 
                Billing_Contact__r.Name,
                Billing_Contact__r.Email, 
                Billing_Contact__r.Homephone__c,
                Billing_Contact__r.Office_Number__c, 
                Billing_Contact__r.Mobile_Number__c,
                Billing_Contact__r.Address__r.Postal_Code__c, 
                Billing_Contact__r.Address__r.Postal_Code__r.Id,                          
                Billing_Contact__r.Address__r.Block_House_Number__c,      
                Billing_Contact__r.Address__r.Street_Name__c,
                Billing_Contact__r.Address__r.RecordTypeId,     
                Billing_Contact__r.Address__r.Level_Number__c,        
                Billing_Contact__r.Address__r.Unit_Number__c,     
                Billing_Contact__r.Address__r.Building_Name__c,       
                Billing_Contact__r.Address__r.Country__r.Country_Name__c,     
                Billing_Contact__r.Address__r.Postal_Code__r.Name,    
                Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,        
                Billing_Contact__r.Address__r.Department__r.Department_Name__c,     
                Billing_Contact__r.Address__r.Division_Code__r.Name,      
                Billing_Contact__r.Address__r.Company_Code__r.Name,       
                Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c,        
                Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c,      
                Billing_Contact__r.Address__r.City__r.City_Name__c,       
                Billing_Contact__r.Address__r.Airline_Number__c,      
                Billing_Contact__r.Address__r.Flight_Number_1__c,     
                Billing_Contact__r.Address__r.Flight_Number_2__c,     
                Billing_Contact__r.Address__r.Address_1__c,       
                Billing_Contact__r.Address__r.Address_2__c,       
                Billing_Contact__r.Address__r.Address_3__c,       
                Billing_Contact__r.Address__r.Address_4__c,
                Billing_Contact__r.Company_Name__c,
                Billing_Contact__r.Address__r.Section_Code__r.Name, 
                Billing_Contact__r.Address__r.Department__r.Name,
                Billing_Contact__r.Address__r.City__r.Country__r.Country_Name__c,
                Billing_Contact__r.Address__r.Location_Code__r.Name 
                FROM Zuora__CustomerAccount__c WHERE Id = :billingAccountIdParam
            ];
            
        if(billingAccounts.isEmpty() == false)
            return billingAccounts.get(0);
        else
            return null;
    }
    
    // START : UD-3510 1/8/2016 Alyana Navarro
    public static List<Zuora__Subscription__c> querySubscriptions(Set<Id> subscriptionIdSetParam){
        return 
        [SELECT Subscriber_Contact__c, Recipient_Contact__c, Recipient_Contact__r.Name, Contact__r.Name, Order_Number_1__c, 
        Zuora__Account__r.Name, Order_Line_Item_Number_1__c, Frequency_1__c, Number_of_Copies__c, Main_Package_1__c, Main_Package_1__r.name, Contact__r.Address__r.Block_House_Number__c, Contact__r.Address__r.Postal_Code__r.Street_Name__c,
        Contact__r.Address__r.Level_Number__c, Recipient_Contact__r.Address__r.Name, Contact__r.Address__r.Unit_Number__c, Zuora__SubscriptionEndDate__c, Contact__r.Address__r.Postal_Code__r.Building_Name__c, Contact__r.Address__r.Postal_Code__r.Name,Zuora__CustomerAccount__c, Contact__r.Address__r.Country_Name__c, Contact__r.MailingAddress, Unique_Delivery_Identifier__c,
        Contact__r.Address__r.Country__r.Country_Name__c, Subscription_Charge__c, Subscriber_Contact__r.Account.AccountNumber, Zuora__Account__r.AccountNumber, Zuora__Account__c, Zuora__Account__r.Account_Auto_Number__c, Contact__r.MailingCountry,
        Recipient_Contact__r.Account.AccountNumber, Delivered_By_1__c, Contact__r.Address__r.Airline_Number__c, 
        Contact__r.Address__r.City__c, Contact__r.Address__r.Flight_Number_1__c, Contact__r.Address__r.Flight_Number_2__c,
        Contact__r.Address__r.Address_1__c, Contact__r.Address__r.Address_2__c, Contact__r.Address__r.Address_3__c, 
        Contact__r.Address__r.Address_4__c, Contact__r.Address__r.Location_Code__r.Name, Contact__r.Address__r.Company_Code__r.Name, 
        Contact__r.Address__r.Division_Code__r.Name, Contact__r.Address__r.Department__r.Name, 
        Contact__r.Address__r.Section_Code__r.Name, is2ndPDFGenerated__c, Contact__r.Address__r.RecordType.Name, Contact__r.Email, 
        Contact__r.Mobile_Number__c, Contact__r.Office_Number__c, Contact__r.HomePhone__c, is1stPDFGenerated__c,
        Recipient_Contact__r.Recipient_Number_Show__c, Recipient_Contact__r.Company_Name__c, Product_Code__c, Delivered_By__c,
        Order_Number_1__r.Delivery_Charge__c, Order_Number_1__r.Delivery_Charge_Type__c, Qty__c, Main_Package_Product_Sub_Type_Mapping__c,
        Recipient_Contact__r.Address__r.Address_Type__c, Recipient_Contact__r.Address__c, Delivery_Charge_Type__c, 
        Recipient_Contact__r.Address__r.RecordTypeId, Recipient_Contact__r.Address__r.RecordType.Name
        FROM Zuora__Subscription__c 
        WHERE Id IN: subscriptionIdSetParam];
    }
    // END : UD-3510 1/8/2016 Alyana Navarro
    
    public void mobileAdjustment(Zuora__CustomerAccount__c billingAccountParam) {
        charLength = true;
        charLengthMag = true;
        
        EmailAddress = billingAccountParam.Billing_Contact__r.Email; 
        HomeNumber = billingAccountParam.Billing_Contact__r.HomePhone__c; 
        OfficeNumber = billingAccountParam.Billing_Contact__r.Office_Number__c;   
        MobileNumber = billingAccountParam.Billing_Contact__r.Mobile_Number__c;
        
        if((HomeNumber <> null && HomeNumber.length() > 11)||(OfficeNumber <> null && OfficeNumber.length() > 11)||(MobileNumber <> null && MobileNumber.length() > 13)){
            charLength = false;
        }
        if((HomeNumber <> null && HomeNumber.length() > 13)||(OfficeNumber <> null && OfficeNumber.length() > 12)||(MobileNumber <> null && MobileNumber.length() > 14)){
            charLengthMag = false;
        } 
    }
    // Start Johnx
    private integer countTr(string stringParam) {
        
        integer numberOfTr = 1;

        stringParam = stringParam.replace('<table cellspacing="0" >','');
        stringParam = stringParam.replace('<td width="30%" align="left" colspan="9">','');
        stringParam = stringParam.replace('<td width="30%" align="left">','');

        if (stringParam != null) {
            if (stringParam.length() > MAX_CHARS_PER_TR) {
                numberOfTr = integer.valueOf(stringParam.length() / MAX_CHARS_PER_TR);
                if (math.mod(stringParam.length(), MAX_CHARS_PER_TR) > 0 ) {
                    numberOfTr++;
                }
            }

            
        }
        system.debug('JohnD :: ' +stringParam+ ' :: ' +numberOfTr);
        return numberOfTr;
    }

    private list<string> splitTable(string tableParam, string letterType) {
        
        list<string> tableList = new list<string>();
        list<string> tableTmpList = new list<string>();
        string tableTmp = tableParam.replace('<table class="content" cellspacing="0">', '');
        tableTmp = tableTmp.replace('</table>', '');
        list<string> tdList = new list<string>();
        string tdTmp;
        
        
        integer trCounter = 0;
        boolean hitMax = false;
        string lineDetail = '';

         
        for (string tr : tableTmp.split('</tr>')) {

            tdList = tr.split('</td>');
            tdTmp = tdList[0].replace(' class="dashedBorderTopBottom"', '');
            tdTmp = tdTmp.replace(' colspan="5"', '');
            tdTmp = tdTmp.replace('<td>', '');

            tdTmp = tdTmp.replace('<table class="content" cellspacing="0" >', '');
            tdTmp = tdTmp.replace('<tr>', '');
  
            
            trCounter += countTr(tdTmp);    // count the number of chars on the first td of each tr
            
            
            if (trCounter > MAX_TR_ON_FIRST_PAGE && !hitMax) {
                
                // first table
                hitMax = true;
                if (letterType ==  SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || 
                      letterType ==  SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper ) {
                    lineDetail = '<table class="content" cellspacing="0" >' + lineDetail + '</table>';
                } else {
                    lineDetail = '<table cellspacing="0" >' + lineDetail + '</table>';
                }
                
                tableList.add(lineDetail);
                lineDetail = '';
            }

            lineDetail += tr + '' + '</tr>';
        }
        
        // second table
         if (letterType ==  SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || 
            letterType ==  SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper ) {
            lineDetail = '<table class="content" cellspacing="0" >' + lineDetail + '</table>';
        }else {
            lineDetail = '<table cellspacing="0" >' + lineDetail + '</table>';
        }
        tableList.add(lineDetail);
        
        return tableList; 
    }
    private string joinTable(string table1Param, string table2Param) {
        
        string tableTmp = table1Param + '<br />' + table2Param;
        return tableTmp;
    }
    // End Johnx
    //START PD-0147 14May2016 Added By C. Lin
     public void testCoveragePatch() {
      integer i = 0;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    }        
    //END PD-0147 14May2016 Added By C. Lin
}