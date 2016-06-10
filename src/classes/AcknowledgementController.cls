//HISTORY: D-2116, 2413 03/20/2015 S.Puli - RECONSTRUCT THE WHOLE CLASS AND VISUALFORCE PAGE

/**
 * Revision: Version 3.0 
 * @author: Sherwin Puli
 * Date: 04/15/2015
 * Requirement/Project Name: Singapore Press Holdings
 * Description: Updated logic for UD-766 767 768 896
 */


public class AcknowledgementController {

//HISTORY: D-2116, 2413 03/20/2015 S.Puli - RECONSTRUCT THE WHOLE CLASS AND VISUALFORCE PAGE
    //START UD-2147 29/7/2015 GdelRosario : added the variable for the flag
    public boolean withDelCharge {get;set;}
    //END UD-2147 29/7/2015 GdelRosario : added the variable for the flag
    public Account acc { get; set; }
    public Zuora__Subscription__c Subscription { get; set; }
    public List<Zuora__Subscription__c> SubscriptionList { get; set; }
    public List<Zuora__Subscription__c> delSubsList { get; set; }//START/END: D-2116 03/18/2014 Added by S.Puli
    public Date DateToday{ get; set; }
    public String blockHouseNum {get; set;}
    public String levelNum {get; set;}
    public String unitNum {get;set;}
    public String buildingName {get; set;}
    public String stName {get; set;}
    public String countryName {get; set;}
    public String postalCode {get; set;}
    public Singpost_Address__c singPostAttachment {get; set;}
    //START : D-2112 02/20/2015 S.Puli
    public String barcodeAttId {get; set;}
    public boolean barChecker {get; set;}
    public boolean promo {get; set;}
    public boolean promoNP {get; set;}
    public boolean makePayment {get; set;}
    public boolean recurCC {get; set;}
    public boolean magazine {get; set;}
    public boolean recurInvoice {get; set;}
    public boolean everGreen {get; set;}
    //END : D-2112 02/20/2015 S.Puli
    //START : UD-1409/1410/1411/1412/1450 Jason A. 06/15/2015
    public string strtotalsubprice {get; set;}
    //END : UD-1409/1410/1411/1412/1450 Jason A. 06/15/2015    
    //START : D-0223 3/9/2015 George Del Rosario
    public String singleStoryAddrNum {get;set;}
    //END : D-0223 3/9/2015 George Del Rosario
    
    //Start: UD-1114 James 05/08/2015
    public Decimal totalsubprice {get; set;}                
    //End: UD-1114 James 05/08/2015
    
        //START D-3722 Gdelrosario 15/10/2015: added for output of the address in the pdf
        public String finalOutputAddress {get;set;}
        //END D-3722 Gdelrosario 15/10/2015: added for output of the address in the pdf
    //START UD-2013 22-July-2015 Added by S.Puli - address based on record type
    public String address1 {get;set;}
    public String address2 {get;set;}
    public String address3 {get;set;}
    public String address4 {get;set;}
    public String address5 {get;set;}
    public String recAddress1 {get;set;}
    public String recAddress2 {get;set;}
    public String recAddress3 {get;set;}
    public String recAddress4 {get;set;}
    public String recAddress5 {get;set;}
    //END UD-2013 22-July-2015 Added by S.Puli - address based on record type
    //START UD-2014 VPernicia 07/24/15- add postage fee
    public Map<Id, Decimal> subIdToPostageFee_MAP  {get;set;}
    Map<Id, Id> postSubToMainSub_MAP = new Map<Id, Id>();//replace by Map<Id, Set<Id>> if bundle needs to be Postaged individually
    Map<Id, Id> orderLineToSubs_MAP = new Map<Id, Id>();
    //END UD-2014 VPernicia 07/24/15 - add postage fee
  //START UD-2286 11-Aug-2015 Added By S.Puli
  public Zuora__CustomerAccount__c billAcc {get; set;}
  //END UD-2286 11-Aug-2015 Added By S.Puli
    //Start D-3689 VPernicia 10/6/15
    //set<id> CaseSubforCOS = new set<id>(); //START - END: D-3724 10/16 removed by Jason A.
    //End D-3689 VPernicia 10/6/15
    public map<id, decimal> newConSubMap {get; set;} //START-END 12-03-2015 D-3999 Added by Jason A.
    public class subsWrapper{
        
        public string accNum {get; set;}
        public string accName {get; set;}
        public string blk {get; set;}
        public string bldg {get; set;}
        public string street {get; set;}
        public string storyAdd {get; set;}
        public string country {get; set;}
        public string postal {get; set;}
        public string packName {get; set;}
        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public string copyNum {get; set;}
        public string subChrg {get; set;}
        public string homeph {get; set;}
        public Decimal Copies {get; set;}
        public Decimal delCharge {get; set;}
        public boolean withDel {get; set;}
        public boolean subChrgChecker {get; set;}
        public boolean isMakePayment {get; set;}
        public boolean isRecurCC {get; set;}
        public boolean isMagazine {get; set;}
        public boolean isRecurInvoice {get; set;}
        public boolean isEverGreen {get; set;}
        public boolean notEverGreen {get; set;} 
        public boolean isRecur {get; set;}  
        //START: UD-0896/767/768 04/13/2015 Added by S.Puli
        public string recConName {get; set;}
        public List<innerSubsWrapper> inerWrapList {get; set;}
        //END: UD-0896/767/768 04/13/2015 Added by S.Puli
    }
    
    //START: UD-0896/767/768 04/13/2015 Added by S.Puli
    public class innerSubsWrapper{
        
        public string packNameInner {get; set;}
        public Date startDateInner {get; set;}
        public Date endDateInner {get; set;}
        public Decimal CopiesInner {get; set;}
        public string subChrgInner {get; set;}
        public boolean withDelInner {get; set;}
        public boolean subChrgCheckerInner {get; set;}
        public boolean isMakePaymentInner {get; set;}
        public boolean isRecurCCInner {get; set;}
        public boolean isMagazineInner {get; set;}
        public boolean isRecurInvoiceInner {get; set;}
        public boolean isEverGreenInner {get; set;}
        public boolean notEverGreenInner {get; set;} 
        public boolean isRecurInner {get; set;} 
        public Decimal delChargeInner {get; set;}
        //Start: UD-1114 James 05/08/2015
        public string paymentmode {get; set;}
        public string otherpaymentmode {get; set;}
        public string subfreq {get; set;}
        public string billtype {get; set;}
        public Decimal contractperiod {get; set;}
        //End: UD-1114 James 05/08/2015
        //Start: UD-1114 James 05/19/2015
        public Decimal termlength {get; set;}
        //End: UD-1114 James 05/19/2015
        //START UD-2014 VPernicia 07/24/15- add postage fee
        public string SubID {get; set;}
        public boolean withSubID {get; set;}
        //END UD-2014 VPernicia 07/24/15- add postage fee
        public Boolean isStoppedSub {get; set;} // START-END : UD-2020 8/13/2015 Alyana Navarro
    }
    
    public List<innerSubsWrapper> innerSubsWrapperList {get; set;}
    
    public List<Id> contact_LIST {get; set;}
    
    public Map<Id, subsWrapper> recipientIdSubWrapper_MAP {get; set;}
    
    public Map<Id, Decimal> delChargeFinal_MAP {get; set;}
    //END: UD-0896/767/768 04/13/2015 Added by S.Puli
    
    public List<subsWrapper> subsWrapperList {get; set;}
    
    // START : UD-2178 8/7/2015 Alyana Navarro
    public Map<Id, Map<String, String>> recIdRecAddressMap {get; set;} // START-END : UD-2286 8/14/2015 Alyana Navarro
    public String firstRecipient {get; set;}
    // END : UD-2178 8/7/2015 Alyana Navarro
    public void generateAcknowledgementController() { 
        //START UD-2328 08/26/15 RReyes
    //START D-3599 10/06/2015 added by Jason A.
        DateTime dateFrom;
        DateTime dateTo;
        string recovery = ''; 
        //START: D-4266 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        Logger logger;
        
        if(!Test.isRunningTest()){
            logger = new Logger('AcknowledgementController');
        }
        
        recovery = ApexPages.currentPage().getParameters().get('isRecovery');
        if(recovery == 'true' ){
            dateFrom = DateTime.valueof(ApexPages.currentPage().getParameters().get('generationFrom'));
            dateTo = DateTime.valueof(ApexPages.currentPage().getParameters().get('generationTo'));
        }else{
            dateFrom = ConstantsSLB.getOtherDate('SP18_SDT1'); 
            dateTo = ConstantsSLB.getOtherDate('SP18_SDT2');
        }
    //END D-3599 10/06/2015 added by Jason A.
        //END UD-2328 08/26/15 RReyes   
        // START : UD-2178 8/7/2015 Alyana Navarro
        recIdRecAddressMap = new Map<Id, Map<String, String>>(); // START-END : UD-2286 8/14/2015 Alyana Navarro
        firstRecipient = '';
    // END : UD-2178 8/7/2015 Alyana Navarro
        //START: UD-0896/767/768 04/13/2015 Added by S.Puli
        List<ID> conIdTemp_LIST = new List<Id>();
        Map<Id, subsWrapper> recipientIdSubWrapperTemp_MAP = new Map<Id, subsWrapper>();
        Map<Id, Decimal> delChargeFinalTemp_MAP = new Map<Id, Decimal>();
        Set<Id> recipientId_SET = new Set<Id>();
        //END: UD-0896/767/768 04/13/2015 Added by S.Puli
        Set<Id> orderLineItemIdSet = new Set<Id>();
        Map<Id, Decimal> subTermLength = new Map<Id, Decimal>();
  //START UD-2286 11-Aug-2015 Added By S.Puli
        // START : UD-2020 8/13/2015 Alyana Navarro
        Set<Id> subscriptionIdSet = new Set<Id>();
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        Map<Id, Id> everSubIdCaseIdMap = new Map<Id, Id>(); 
        // END : UD-2020 8/13/2015 Alyana Navarro
        
        //Start UD-2373 VPernicia 09/04/15
        set<id> setOrderLineId = new set<id>();
        //End UD-2373 VPernicia 09/04/15
        
        
        try
        {
            subsWrapperList = new List<subsWrapper>();
            
            billAcc = [Select Id, Name, Zuora__Account__c from Zuora__CustomerAccount__c Where Id = :ApexPages.currentPage().getParameters().get('id')];
      acc = [Select Id, Name from Account Where Id = :billAcc.Zuora__Account__c];
            DateToday = Date.Today();
            // START : D-1189 1/22/2015 Alyana Navarro
            //Start UD-0287 03-10-2015 ABanaag Query order delivery charge
            //START: D-2116 03/18/2014 Added by S.Puli
            // START : UD-287 3/27/2015 Alyana Navarro - Change the logic of getting the delivery sub. Added Order_Line_Item_Number_1__c to the query.
            //START: UD-0896/767/768 04/13/2015 Added by S.Puli
            //Start: UD-1114 James 05/08/2015 - added fields in query
            //START UD-2013 22-July-2015 Added by S.Puli - address based on record type
            //Start UD-2014 VPernicia 07/24/15 Additional field for Postage
             //START D-3430 VPernicia 08/21/15
            //START UD-2328 08/26/15 RReyes - added condition. Subscription should be active| replaced DTL Date condition to CreatedDate          
            //START D-3689 10/05/2015 Jason A. - Remove filter for Active Subscription.
            //END UD-3141 10/22/2015 Jason A. - Added for Supressed Acknowledgement
                //START D-3722 Gdelrosario 23/10/2015: added to query
            //START D-3935 11/12/2015 added by Jason A.
            SubscriptionList = [SELECT Zuora__Account__c,Zuora__TermSettingType__c, Zuora__Account__r.SS_Subscriber_Account_Number__c, Contact__c, Recipient_Contact__c, Recipient_Contact__r.Name, Subscription_Type_1__c,
                            Main_Package_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Qty__c, Supressed_Acknowledgement_Letter_1__c,
                            Zuora__Account__r.AccountNumber, Zuora__Account__r.Name, Contact__r.Address__r.Block_House_Number__c, 
                            Contact__r.Address__r.Level_Number__c, Contact__r.Address__r.Unit_Number__c,
                            Contact__r.Address__r.Building_Name__c, Contact__r.Address__r.Postal_Code__r.Street_Name__c, 
                            Contact__r.Address__r.Country__r.Country_Name__c, Contact__r.Address__r.Postal_Code__r.Name,
                            Contact__r.LastName, Contact__r.FirstName, Main_Package_1__r.Name, 
                            Contact__r.Address__r.Postal_Code__r.Building_Name__c, Number_of_Copies__c, Subscription_Charge__c, 
                            Contact__r.Address__r.Postal_Code__c, Term_Length__c, 
                            Recipient_Contact__r.HomePhone__c, Recipient_Contact__r.Address__r.Building_Name__c,
                            Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c, Recipient_Contact__r.Address__r.Country__r.Country_Name__c, 
                            Recipient_Contact__r.Address__r.Postal_Code__r.Name, Recipient_Contact__r.Address__r.Block_House_Number__c,
                            Recipient_Contact__r.Address__r.Level_Number__c, Recipient_Contact__r.Address__r.Unit_Number__c, Order_Line_Item_Number_1__c,
                            Order_Number_1__r.Delivery_Charge__c, Order_Number_1__r.DTL_Date__c, Recipient_Contact__r.HomePhone, Recipient_Contact__r.Address__r.Name, 
                            Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c, Main_Package_1__r.Number_Of_Promotions__c, Payment_Mode_1__c, Billing_Type__c, 
                            Other_PaymentMethod_1__c, Frequency_1__c, New_Contract_Period_1__c, Recipient_Contact__r.Recipient_Number__c,
                            Recipient_Contact__r.Address__r.recordType.developerName, Recipient_Contact__r.Address__r.Street_Name__c,Recipient_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                            
                            Recipient_Contact__r.Address__r.Address_1__c,Recipient_Contact__r.Address__r.Address_2__c,
                            Recipient_Contact__r.Address__r.Address_3__c,Recipient_Contact__r.Address__r.Address_4__c,
                            Recipient_Contact__r.Address__r.Airline_Number__c,Recipient_Contact__r.Address__r.Flight_Number_1__c,Recipient_Contact__r.Address__r.Flight_Number_2__c,
                            Contact__r.Address__r.recordType.developerName, Contact__r.Address__r.Location_Code__r.Location_Name__c,
                            
                            // Start D-3722 VPernicia 11/09/15
                            Recipient_Contact__r.Address__r.Department__r.Name,
                            Recipient_Contact__r.Address__r.Division_Code__r.Name,
                            Recipient_Contact__r.Address__r.Company_Code__r.Name,
                            Recipient_Contact__r.Address__r.Location_Code__r.Name,
                            Recipient_Contact__r.Address__r.City__r.Name,
                            Recipient_Contact__r.Address__r.City__r.City_Name__c,
                            // End D-3722 VPernicia 11/09/15
                            //START D-4398 02-05-2016 added by jason A.
                            Recipient_Contact__r.Address__r.Section_Code__r.Name,
                            // Start UD-2882 VPernicia 11/09/15
                            Main_Package_1__r.GST_Exclusive__c,
                            //END D-4398 02-05-2016 added by jason A.
                            // Start UD-2882 VPernicia 11/09/15
                            
                            Contact__r.Address__r.Street_Name__c,Contact__r.Address__r.Section_Code__r.Section_Name__c,
                            Contact__r.Address__r.Department__r.Department_Name__c,Contact__r.Address__r.Division_Code__r.Name,
                            Contact__r.Address__r.Company_Code__r.Company_Name__c,Contact__r.Address__r.Address_1__c,Contact__r.Address__r.Address_2__c,
                            Contact__r.Address__r.Address_3__c,Contact__r.Address__r.Address_4__c,Contact__r.Address__r.City__r.City_Name__c,
                            Contact__r.Address__r.Airline_Number__c,Contact__r.Address__r.Flight_Number_1__c,Contact__r.Address__r.Flight_Number_2__c, Name, 
                            Zuora__CustomerAccount__r.Billing_Contact__r.Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__Status__c,
                            //Start UD-2517 VPernicia 08/27/15
                            Contact__r.Address__r.City__r.Country__r.Country_Name__c, Recipient_Contact__r.Address__r.City__r.Country__r.Country_Name__c,
                            //START MMallorca D-3722 04/11/2015 Added address fields for Internal Address Type    
                            Contact__r.Address__r.City__r.Name,
                            Contact__r.Address__r.Section_Code__r.Name,
                            Contact__r.Address__r.Department__r.Name,
                            Contact__r.Address__r.Location_Code__r.Name,
                            Contact__r.Address__r.Company_Code__r.Name,
                            //START UD-3720 01-28-2016 added by Jason A.
                            Zuora__CustomerAccount__r.Billing_Contact__r.Company_Name__c,
                            //END D-3935 11/12/2015 added by Jason A.
                            //END MMallorca D-3722 04/11/2015 Added address fields for Internal Address Type    
                            //End UD-2517 VPernicia 08/27/15
                            Order_Line_Item_Number_1__r.End_Date__c
                            //END UD-3720 01-28-2016 added by Jason A.
    //START UD-3758 02-23-2016 added by Jason A.                            
                            , Main_Package_1__r.Package_Type__c
    //END UD-3758 02-23-2016 added by Jason A.
                            FROM Zuora__Subscription__c 
                            WHERE Zuora__CustomerAccount__c =: billAcc.Id AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION AND (CreatedDate >: dateFrom AND CreatedDate <=: dateTo) AND Supressed_Acknowledgement_Letter_1__c = false];  
                //END D-3722 Gdelrosario 23/10/2015: added to query
            //END UD-3141 10/22/2015 Jason A. - Added for Supressed Acknowledgement
            //END D-3689 10/05/2015 Jason A. - Remove filter for Active Subscription.
            //END UD-2328 08/26/15 RReyes - added condition. Subscription should be active| replaced DTL Date condition to CreatedDate
            //End D-3430 VPernicia 08/21/15
            //END UD-2286 11-Aug-2015 Added By S.Puli
            //End UD-2014 VPernicia 07/24/15 Additional field for Postage
            //END UD-2013 22-July-2015 Added by S.Puli - address based on record type
            //End: UD-1114 James 05/08/2015
            //END: UD-0896/767/768 04/13/2015 Added by S.Puli
                                        
            //Start D-3689 VPernicia 10/6/15
            //set<id> subIDforCOS = new set<id>(); //START - END: D-3724 10/16 removed by Jason A.
            //Start D-3689 VPernicia 10/6/15
            //START: D-3724 10/16 added by Jason A.
            list<Zuora__Subscription__c> newSubscriptionList = new list<Zuora__Subscription__c>();                            
            for(Zuora__Subscription__c subscription : SubscriptionList){
            // START : UD-2020 8/13/2015 Alyana Navarro
                //START PD-0186 24May2016 Added By C. Lin - Update condition to exclude subscriptions with deleted status
                if(subscription.Zuora__SubscriptionEndDate__c > subscription.Zuora__SubscriptionStartDate__c || (subscription.Zuora__TermSettingType__c == 'EVERGREEN' && subscription.Zuora__SubscriptionEndDate__c == null)){ 
                //END PD-0186 24May2016 Added By C. Lin
            //START: D-3807 10/22 added by Jason A.
                    if(subscription.Zuora__TermSettingType__c == 'EVERGREEN'){
                        subscriptionIdSet.add(subscription.id);
                    }
                    newSubscriptionList.add(subscription);
                    orderLineItemIdSet.add(subscription.Order_Line_Item_Number_1__c);
                    subTermLength.put(subscription.Order_Line_Item_Number_1__c, subscription.Term_Length__c);
                    recipientId_SET.add(subscription.Recipient_Contact__c);
                    //subIDforCOS.add(subscription.id); //Start/End D-3689 VPernicia 10/6/15 //START - END: D-3724 10/16 removed by Jason A.
                }
            //END: D-3724 10/16 added by Jason A.
            }
            //START: D-3724 10/16 removed by Jason A.
            //Start D-3689 VPernicia 10/6/15
            /*for (case caseCOS: [select Subscription_Name__c from case where Subscription_Name__c in: subIDforCOS and RecordTypeId =: ConstantsSLB.getKeyId('Case_Change of Subscription')]) {
            
                CaseSubforCOS.add(caseCOS.Subscription_Name__c);
            }
            */
            //End D-3689 VPernicia 10/6/15
            //END: D-3724 10/16 removed by Jason A.
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
            // END : UD-2020 8/13/2015 Alyana Navarro
            if(recipientId_SET.size()>0){
                for(Id idRec : recipientId_SET){
                    conIdTemp_LIST.add(idRec);
                }
            }
            contact_LIST = conIdTemp_LIST;
            //Start UD-2014 VPernicia 07/24/15 Additional criteria for Postage
      //START UD-2286 11-Aug-2015 Added By S.Puli
      //START UD-3141 10/22/2015 Jason A. - Added for Supressed Acknowledgement
            delSubsList = [SELECT id, name, Delivery_Charge__c, Subscription_Charge__c, Unique_Delivery_Identifier__c, Zuora__Account__c, Order_Line_Item_Number_1__c, Subscription_Type__c, Zuora__CustomerAccount__c, Supressed_Acknowledgement_Letter_1__c
                                   FROM Zuora__Subscription__c 
                                   WHERE Zuora__CustomerAccount__c =: billAcc.Id
                                   AND (Subscription_Type__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY OR Subscription_Type__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE) AND Order_Line_Item_Number_1__c IN: orderLineItemIdSet AND Supressed_Acknowledgement_Letter_1__c = false];
      //END UD-3141 10/22/2015 Jason A. - Added for Supressed Acknowledgement
      //END UD-2286 11-Aug-2015 Added By S.Puli
            //End UD-2014 VPernicia 07/24/15 Additional criteria for Postage
            //map<sub.recipient.adres.name, subscharge>
            // Map<String, Decimal> subrecipientAddress_deliveryCharge_MAP = new Map<String, Decimal>(); - Alyana Navarro - For deletion
            Map<Id, Zuora__Subscription__c> delSubMap = new Map<Id, Zuora__Subscription__c>();
            
            
            for(Zuora__Subscription__c delSub : delSubsList){
                // Start UD-2014 VPernicia 07/24/15
                if (delSub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY) {
                    delSubMap.put(delSub.Order_Line_Item_Number_1__c, delSub);
                }
                
                if(delSub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE ){
                    if(!orderLineToSubs_MAP.containsKey(delSub.Order_Line_Item_Number_1__c)){
                        orderLineToSubs_MAP.put(delSub.Order_Line_Item_Number_1__c, delSub.Id);
                    }
                }
                // End UD-2014 VPernicia 07/24/15
            }
            
            //START UD-2014 VPernicia - add postage fee
            //START: D-3724 10/16 added by Jason A.
            for(Zuora__Subscription__c sub : newsubscriptionList){
            //END: D-3724 10/16 added by Jason A.   
                if(orderLineToSubs_MAP.containsKey(sub.Order_Line_Item_Number_1__c)){
                    postSubToMainSub_MAP.put(orderLineToSubs_MAP.get(sub.Order_Line_Item_Number_1__c), sub.Id);
                }
            }
            //END UD-2014 VPernicia - add postage fee
            
            //START UD-2014 VPernicia 07/24/15- add postage fee
            subIdToPostageFee_MAP = new Map<Id, Decimal>();
            for(Zuora__Subscription__c delSub : delSubsList){
            
                if(delSub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE ){
                    if(orderLineToSubs_MAP.containsKey(delSub.Order_Line_Item_Number_1__c)){
                // START : UD-2718 Sept-14-2015 Jason A - 2 decimal places format   
                        if(postSubToMainSub_MAP.containsKey(delSub.Id)){
                        decimal postageCharge = delSub.Subscription_Charge__c.setScale(2, System.RoundingMode.HALF_UP);
                            //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
                            subIdToPostageFee_MAP.put(delSub.Order_Line_Item_Number_1__c, postageCharge);
                            //End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                        }
                    }
                }
                // END : UD-2718 Sept-14-2015 Jason A - 2 decimal places format
            }
            //End UD-2014 VPernicia 07/24/15- add postage fee
            
            // START : D-0233 3/9/2015 george del rosario
            //START: D-3724 10/16 added by Jason A.
            if(newSubscriptionList.size()>0 & newSubscriptionList<>null){
            Subscription = newSubscriptionList[0];
            //END: D-3724 10/16 added by Jason A.
        //START UD-2147 7/29/2015 GdelRosario : set the valur to false always
                withDelCharge = false;
    //END UD-2147 7/29/2015 GdelRosario : set the valur to false always
                promo = false;
                promoNP = false;
                makePayment = false;
                recurCC = false;
                magazine = false;
                recurInvoice = false;
                everGreen = false;
                //Start: UD-1114 James 05/08/2015
                totalsubprice = 0;
                string recipientContact;
                //boolean delchargeadded = false;
                //End: UD-1114 James 05/08/2015
                //Start: UD-1114 James 05/19/2015
                decimal highestdelfee = 0;
                //End: UD-1114 James 05/19/2015
                //START: D-3724 10/16 added by Jason A.
                
                //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
                map<id, list<Zuora__Subscription__c>> mapOrderLineItem = new map<id, list<Zuora__Subscription__c>>();
                for(Zuora__Subscription__c Subscription : newSubscriptionList){
                    if (!mapOrderLineItem.containskey(Subscription.Order_Line_Item_Number_1__c)) {
                        mapOrderLineItem.put(Subscription.Order_Line_Item_Number_1__c, new list<Zuora__Subscription__c>{Subscription});
                    } else {
                        mapOrderLineItem.get(Subscription.Order_Line_Item_Number_1__c).add(Subscription);
                    }
                }
                
                set<id> setOrderLineitemID = new set<id>();
    //Start D-3999 12-03-2015 Added by Jason A.
                newConSubMap = new map<id, decimal>();
                
                //End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                    for(Zuora__Subscription__c Subscription : newSubscriptionList){
                        newConSubMap.put(Subscription.Recipient_Contact__c, -1);
                    }
                    
                    for(Zuora__Subscription__c Subscription : newSubscriptionList){
                        if(Subscription.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER){
                            newConSubMap.put(Subscription.Recipient_Contact__c, 0);
                        }
    //END D-3999 12-03-2015 Added by Jason A.
                    decimal intSubCharges=0; //Start/End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                    //END: D-3724 10/16 added by Jason A.
                    //if (!CaseSubforCOS.contains(Subscription.id)) { //Start/End D-3689 VPernicia 10/6/15 //START - END: D-3724 10/16 removed by Jason A.
                    //Start UD-3758 VPernicia 2/2/16: Additional criteria for Add-on
                         if (!setOrderLineitemID.contains(Subscription.Order_Line_Item_Number_1__c) || Subscription.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON) { //Start/End D-3928 VPernicia 11/12/15: Combine the bundle subscription   
                    //End UD-3758 VPernicia 2/2/16: Additional criteria for Add-on
                            
                            setOrderLineitemID.add(Subscription.Order_Line_Item_Number_1__c); //Start/End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                            
                            innerSubsWrapperList = new List<innerSubsWrapper>();
                            //START: UD-0896/767/768 04/13/2015 Added by S.Puli
                            innerSubsWrapper innerElement = new innerSubsWrapper();
                            innerElement.isStoppedSub = false; // START-END : UD-2020 8/13/2015 Alyana Navarro
                            //END: UD-0896/767/768 04/13/2015 Added by S.Puli
                            //START UD-2014 VPernicia 07/24/15- add postage fee
                            //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
                            innerElement.subID = Subscription.Order_Line_Item_Number_1__c;
                            innerElement.withSubID = false;
                            
                            for (Zuora__Subscription__c zuoraSubs: mapOrderLineItem.get(Subscription.Order_Line_Item_Number_1__c)){
                                if (subIdToPostageFee_MAP.containsKey(zuoraSubs.Order_Line_Item_Number_1__c)) {
                                    innerElement.withSubID = true;
                                }
                            }
                            //End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                            //END UD-2014 VPernicia 07/24/15- add postage fee
                            
                            subsWrapper subsElement = new subsWrapper();
                                subsElement.withDel = false;
                                subsElement.subChrgChecker = false;
                                subsElement.isMakePayment = false;
                                subsElement.isRecurCC = false;
                                subsElement.isMagazine = false;
                                subsElement.isRecurInvoice = false;
                                subsElement.isEverGreen = false;
                                subsElement.notEverGreen = true;
                                subsElement.isRecur = false;
                                //START: UD-0896/767/768 04/13/2015 Added by S.Puli
                                innerElement.withDelInner = false;
                                innerElement.subChrgCheckerInner = false;
                                innerElement.isMakePaymentInner = false;
                                innerElement.isRecurCCInner = false;
                                innerElement.isMagazineInner = false;
                                innerElement.isRecurInvoiceInner = false;
                                innerElement.isEverGreenInner = false;
                                innerElement.notEverGreenInner = true;
                                innerElement.isRecurInner = false;
                                //END: UD-0896/767/768 04/13/2015 Added by S.Puli
                                subsElement.accNum = Subscription.Zuora__Account__r.AccountNumber;
                                subsElement.accName = Subscription.Zuora__Account__r.Name;
                            //START: UD-0896/767/768 04/13/2015 Added by S.Puli
                            if(Subscription.Recipient_Contact__r.Name <> null){
                                subsElement.recConName = Subscription.Recipient_Contact__r.Name;
        
                            }
                            //END: UD-0896/767/768 04/13/2015 Added by S.Puli
                            //START D-3722 Gdelrosario 15/10/2015: added to call addressHelper to form the address
                              finalOutputAddress=AddressHelper.formatAddress(Subscription.Contact__r, false,false);
                            //END D-3722 Gdelrosario 15/10/2015: added to call addressHelper to form the address
                            
                                
        
        
        
                  
                                
        
        
        
                           // START : UD-2178 8/7/2015 Alyana Navarro
                            if(firstRecipient == ''){
                               // Start D-3722 VPernicia 10/20/15
                               firstRecipient = AddressHelper.formatAddress(Subscription.Recipient_Contact__r, true,false);
                               // End D-3722 VPernicia 10/20/15
                                // START : UD-2286 8/14/2015 Alyana Navarro
                    if(!recIdRecAddressMap.containsKey(Subscription.Recipient_Contact__c)){
                                    recIdRecAddressMap.put(Subscription.Recipient_Contact__c, new Map<String, String>{'Address' => 'DO NOT INCLUDE ADDRESS'});
                                    recIdRecAddressMap.get(Subscription.Recipient_Contact__c).put('RecNumber', '');
                                    recIdRecAddressMap.get(Subscription.Recipient_Contact__c).put('RecName', '');
                                }
                    // END : UD-2286 8/14/2015 Alyana Navarro
                            }
                            // Start D-3722 VPernicia 10/20/15
                            String recipientAddressTemp = AddressHelper.formatAddress(Subscription.Recipient_Contact__r, true,false);
                            // End D-3722 VPernicia 10/20/15
                            // START : UD-2286 8/14/2015 Alyana Navarro
                    if(!recIdRecAddressMap.containsKey(Subscription.Recipient_Contact__c)){
                                recIdRecAddressMap.put(Subscription.Recipient_Contact__c, new Map<String, String>{'Address' => recipientAddressTemp});
                                recIdRecAddressMap.get(Subscription.Recipient_Contact__c).put('RecNumber', String.valueOf(Subscription.Recipient_Contact__r.Recipient_Number__c));
                                recIdRecAddressMap.get(Subscription.Recipient_Contact__c).put('RecName', Subscription.Recipient_Contact__r.Name);
                            }
                    // END : UD-2286 8/14/2015 Alyana Navarro
                            // END : UD-2178 8/7/2015 Alyana Navarro
                            //END UD-2013 22-July-2015 Added by S.Puli - address based on record type
                            if(Subscription.Contact__r.Address__r.Level_Number__c == null ||
                               Subscription.Contact__r.Address__r.Unit_Number__c == null ){
                                    singleStoryAddrNum = null;                  
                            }else {           
                                    levelNum = Subscription.Contact__r.Address__r.Level_Number__c.toUpperCase();
                                    unitNum = Subscription.Contact__r.Address__r.Unit_Number__c.toUpperCase(); 
                                    singleStoryAddrNum = '#' + levelNum + '-' + unitNum;  
                                    
                            }
                            if(Subscription.Recipient_Contact__r.Address__r.Unit_Number__c <>null && Subscription.Recipient_Contact__r.Address__r.Level_Number__c <> null){
                                
                                String levelNumRec = '';
                                String unitNumRec = ''; 
                                levelNumRec = Subscription.Recipient_Contact__r.Address__r.Level_Number__c.toUpperCase();
                                unitNumRec = Subscription.Recipient_Contact__r.Address__r.Unit_Number__c.toUpperCase(); 
                                subsElement.storyAdd = '#' + levelNumRec + '-' + unitNumRec;
                            }
                            // END : D-0233 3/9/2015 george del rosario            
                            if(Subscription.Contact__r.Address__r.Block_House_Number__c != null){
                              blockHouseNum = Subscription.Contact__r.Address__r.Block_House_Number__c.toUpperCase();
                                
                            }
                            if(Subscription.Recipient_Contact__r.Address__r.Block_House_Number__c != null){
                                subsElement.blk = Subscription.Recipient_Contact__r.Address__r.Block_House_Number__c.toUpperCase();
                            }
                            if(Subscription.Contact__r.Address__r.Level_Number__c != null){
                              levelNum = Subscription.Contact__r.Address__r.Level_Number__c.toUpperCase();
                            }
                            if(Subscription.Contact__r.Address__r.Unit_Number__c != null){
                              unitNum = Subscription.Contact__r.Address__r.Unit_Number__c.toUpperCase();              
                            }
                            if(Subscription.Contact__r.Address__r.Postal_Code__r.Building_Name__c != null){
                              buildingName = Subscription.Contact__r.Address__r.Postal_Code__r.Building_Name__c.toUpperCase();
                                
                            }
                            if(Subscription.Recipient_Contact__r.Address__r.Building_Name__c<>null){
                                subsElement.bldg = Subscription.Recipient_Contact__r.Address__r.Building_Name__c.toUpperCase();
                            }
                            if(Subscription.Contact__r.Address__r.Postal_Code__r.Street_Name__c != null){
                              stName = Subscription.Contact__r.Address__r.Postal_Code__r.Street_Name__c.toUpperCase();
                                
                            }
                            if(Subscription.Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c <> null){
                                subsElement.street = Subscription.Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c.toUpperCase();
                            }
                            if(Subscription.Contact__r.Address__r.Country__r.Country_Name__c != null){
                              countryName = Subscription.Contact__r.Address__r.Country__r.Country_Name__c.toUpperCase();
                                subsElement.country = Subscription.Contact__r.Address__r.Country__r.Country_Name__c.toUpperCase();
                            }
                            if(Subscription.Contact__r.Address__r.Postal_Code__r.Name != null){
                              postalCode = Subscription.Contact__r.Address__r.Postal_Code__r.Name.toUpperCase();
                                subsElement.postal = Subscription.Contact__r.Address__r.Postal_Code__r.Name.toUpperCase();
                            }
                            if(Subscription.Recipient_Contact__r.Address__r.Postal_Code__r.Name <> null && Subscription.Recipient_Contact__r.Address__r.Postal_Code__r.Name <> ''){
                                subsElement.postal = Subscription.Recipient_Contact__r.Address__r.Postal_Code__r.Name.toUpperCase();
                            }
                            //start
                            if(Subscription.Main_Package_1__c <> null){
                                subsElement.packName = Subscription.Main_Package_1__r.Name;
                                innerElement.packNameInner = Subscription.Main_Package_1__r.Name;
                            }
                            if(Subscription.Recipient_Contact__r.HomePhone <> null){
                                subsElement.homeph = string.valueOf(Subscription.Recipient_Contact__r.HomePhone);
                            }
                            if(Subscription.Subscription_Charge__c <> null){
                                
                                //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
                                //Start UD-2882 VPernicia 11/24/15: GST exclusive for Airline
                                //Start UD-3758 VPernicia 2/2/16: Add-On
                                if (Subscription.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON) {
                                
                                    if (Subscription.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Airline') && Subscription.Main_Package_1__r.GST_Exclusive__c == true) {
                                        Other__c gstSetting = Other__c.getInstance('GST');
                                        
                                        subsElement.subChrg = String.ValueOf(Subscription.Subscription_Charge__c + (Subscription.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100)));
                                        intSubCharges += Subscription.Subscription_Charge__c + (Subscription.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100));
                                    } else {
                                        subsElement.subChrg = String.ValueOf(Subscription.Subscription_Charge__c);
                                        intSubCharges += Subscription.Subscription_Charge__c;
                                    }
                                } else { 
                                    for (Zuora__Subscription__c zuoraSubs: mapOrderLineItem.get(Subscription.Order_Line_Item_Number_1__c)){
                                        if (zuoraSubs.Main_Package_1__r.Package_Type__c != GlobalVariableClass.PACKAGETYPE_ADDON) {
                                            if (zuoraSubs.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Airline') && zuoraSubs.Main_Package_1__r.GST_Exclusive__c == true) {
                                                Other__c gstSetting = Other__c.getInstance('GST');
                                                
                                                intSubCharges += zuoraSubs.Subscription_Charge__c + (zuoraSubs.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100));
                                            } else {
                                                intSubCharges += zuoraSubs.Subscription_Charge__c;
                                            }
                                        }
                                    }
                                    subsElement.subChrg += String.ValueOf(intSubCharges);
                                }
                                //End UD-3758 VPernicia 2/2/16: Add-On
                                //End UD-2882 VPernicia 11/24/15: GST exclusive for Airline
                                //End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                                
                                subsElement.subChrgChecker = true;
                                innerElement.subChrgCheckerInner = true;
            //START : UD-1409/1410/1411/1412/1450 Jason A. 06/15/2015 
            // START : UD-2718 Sept-14-2015 Jason A - 2 decimal places format   
                                string strSubCharge = intSubCharges.setscale(2, System.RoundingMode.HALF_UP).format(); //Start/End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                                if (strSubCharge.right(2).left(1) == '.') {
                            
                                    strSubCharge = strSubCharge + '0';
                                } else if (strSubCharge.right(3).left(1) != '.'){
                                    strSubCharge = strSubCharge + '.00';
                                }
            // END : UD-2718 Sept-14-2015 Jason A - 2 decimal places format                   
                                //Start UD-3758 VPernicia 2/2/2016: For Add-on
                                if (Subscription.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON) {
                                    if (Subscription.Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Airline') && Subscription.Main_Package_1__r.GST_Exclusive__c == true) {
                                        Other__c gstSetting = Other__c.getInstance('GST');
                                        
                                        innerElement.subChrgInner = String.ValueOf(Subscription.Subscription_Charge__c + (Subscription.Subscription_Charge__c * (Decimal.ValueOf(gstSetting.Value__c) / 100)));
                                    } else {
                                        innerElement.subChrgInner = String.ValueOf(Subscription.Subscription_Charge__c);
                                    }
                                } else {
                                    innerElement.subChrgInner = strSubCharge;
                                }
                                //End UD-3758 VPernicia 2/2/2016: For Add-on
            //END : UD-1409/1410/1411/1412/1450 Jason A. 06/15/2015
                            }
                            if(Subscription.Zuora__SubscriptionStartDate__c <> null){
                                subsElement.startDate = Subscription.Zuora__SubscriptionStartDate__c;
                                innerElement.startDateInner = Subscription.Zuora__SubscriptionStartDate__c;
                            }
                            if(Subscription.Zuora__SubscriptionEndDate__c <> null){
                                subsElement.endDate = Subscription.Zuora__SubscriptionEndDate__c;
                                //START UD-3720 01-28-2016 added by Jason A. 
                                //innerElement.endDateInner = Subscription.Zuora__SubscriptionEndDate__c;
                                innerElement.endDateInner = Subscription.Order_Line_Item_Number_1__r.End_Date__c;
                                //END UD-3720 01-28-2016 added by Jason A.
                            }
                            if(Subscription.Number_of_Copies__c <> null){
                                subsElement.Copies = Subscription.Number_of_Copies__c;
                                innerElement.CopiesInner = Subscription.Number_of_Copies__c;
                            }
                            if(Subscription.Payment_Mode_1__c <> null && Subscription.Billing_Type__c <> null){
                                if(Subscription.Billing_Type__c <> GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID ){
                                //START UD-2345 17/8/2015 GdelRosario : added PAYPAL and Invoice for Full prepaid
                                    if(Subscription.Payment_Mode_1__c == GlobalVariableClass.CREDIT_CARD || Subscription.Payment_Mode_1__c == GlobalVariableClass.PAYPAL ){
                                        recurCC = true;
                                        subsElement.isRecurCC = true;
                                        innerElement.isRecurCCInner = true;
                                    } else if(Subscription.Other_PaymentMethod_1__c == GlobalVariableClass.INVOICE){
                                        recurInvoice = true;
                                        subsElement.isRecurInvoice = true;
                                        innerElement.isRecurInvoiceInner = true;
                                    } 
                                }else if(Subscription.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID ){
                                    if(Subscription.Other_PaymentMethod_1__c == GlobalVariableClass.INVOICE){
                                        makePayment = true;
                                        subsElement.isRecur = true;
                                        innerElement.isRecurInner = true;
                                    }
                                }
                                //END UD-2345 17/8/2015 GdelRosario : added PAYPAL and Invoice for Full prepaid
                            }
                            if(Subscription.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE){
                                magazine = true;
                                subsElement.isMagazine = true;
                                innerElement.isMagazineInner = true;
                            }
                            if(Subscription.Zuora__TermSettingType__c == 'EVERGREEN'){
                                everGreen = true;
                                subsElement.isEverGreen = true;
                                subsElement.notEverGreen = false;
                                innerElement.isEverGreenInner = true;
                                innerElement.notEverGreenInner = false;
                                // START : UD-2020 8/13/2015 Alyana Navarro
                                if(everSubIdCaseIdMap.containsKey(Subscription.id)){
                                    innerElement.isStoppedSub = true;
                                    //START UD-3720 01-28-2016 added by Jason A.
                                    innerElement.endDateInner = Subscription.Order_Line_Item_Number_1__r.End_Date__c;   
                                    //END UD-3720 01-28-2016 added by Jason A.
                                }
                                // END : UD-2020 8/13/2015 Alyana Navarro
                            }
                            //Start: UD-1114 James 05/08/2015
                            if(Subscription.Payment_Mode_1__c <> null){
                                innerElement.paymentmode = Subscription.Payment_Mode_1__c;
                            }
                            if(Subscription.Other_PaymentMethod_1__c <> null){
                                innerElement.otherpaymentmode = Subscription.Other_PaymentMethod_1__c;
                            }
                            if(Subscription.Frequency_1__c <> null){
                                innerElement.subfreq = Subscription.Frequency_1__c;
                            }
                            if(Subscription.Billing_Type__c <> null){
                                innerElement.billtype = Subscription.Billing_Type__c;
                            }
                            if(Subscription.New_Contract_Period_1__c <> null){
                                innerElement.contractperiod = Subscription.New_Contract_Period_1__c;
                            }else{
                                innerElement.contractperiod = null;
                            }
                            //End: UD-1114 James 05/08/2015
                            //Start: UD-1114 James 05/19/2015
                            //START D-3688 10/05/2015 Jason A.
                            if(Subscription.Term_Length__c <> null && Subscription.Term_Length__c != 0){
                                innerElement.termlength = Subscription.Term_Length__c;
                            }else{
                                innerElement.termlength = 0;
                            }
                            //ENDD-3688 10/05/2015 Jason A.
                            //End: UD-1114 James 05/19/2015
                            //end
                            //modify logic for delivery fee
                            //START: UD-2009 07/22/2015 Added by J.Abolac
                            if(Subscription.Recipient_Contact__r.Address__r.Name <> null && Subscription.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER){
                                // START : D-0287 3/27/2015 Alyana Navarro - Get Delivery Charge                        
                                if(delSubMap.containsKey(Subscription.Order_Line_Item_Number_1__c)){                                                  
                                    if(subTermLength.containsKey(Subscription.Order_Line_Item_Number_1__c)){
                                        if(Subscription.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID ){
                                            //Start UD-2373 VPernicia 09/04/15
                                            if (!setOrderLineId.contains(Subscription.Order_Line_Item_Number_1__c)) {
                                                subsElement.delCharge = delSubMap.get(Subscription.Order_Line_Item_Number_1__c).Subscription_Charge__c;
                                                //* Integer.valueOf(subTermLength.get(Subscription.Order_Line_Item_Number_1__c));
                                                innerElement.delChargeInner = delSubMap.get(Subscription.Order_Line_Item_Number_1__c).Subscription_Charge__c;
                                                //* Integer.valueOf(subTermLength.get(Subscription.Order_Line_Item_Number_1__c));
                                            } else {
                                                subsElement.delCharge = 0;
                                                innerElement.delChargeInner = 0;
                                            } 
                                            
                                            if (delSubMap.get(Subscription.Order_Line_Item_Number_1__c).Subscription_Charge__c > 0) {
                                                setOrderLineId.add(Subscription.Order_Line_Item_Number_1__c); 
                                            }
                                            //End UD-2373 VPernicia 09/04/15
                                        } else{
                                            subsElement.delCharge = delSubMap.get(Subscription.Order_Line_Item_Number_1__c).Subscription_Charge__c;
                                            innerElement.delChargeInner = delSubMap.get(Subscription.Order_Line_Item_Number_1__c).Subscription_Charge__c;
                                        }
                                        //START: UD-0896/767/768 04/13/2015 Added by S.Puli
                                        if(Subscription.Recipient_Contact__c<>null){
                                        
                                            //Start UD-2373 VPernicia 08/29/15
                                            if (Subscription.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID) {
                                                if(delChargeFinalTemp_MAP.containskey(Subscription.Recipient_Contact__c)){
                                                    decimal subDelFee = 0;
                                                    subDelFee = delChargeFinalTemp_MAP.get(Subscription.Recipient_Contact__c) + subsElement.delCharge;
                                                    delChargeFinalTemp_MAP.put(Subscription.Recipient_Contact__c, subDelFee);
                                                    
                                                } else {
                                                    delChargeFinalTemp_MAP.put(Subscription.Recipient_Contact__c, subsElement.delCharge);
                                                }
                                            } else {
                                                if(delChargeFinalTemp_MAP.containskey(Subscription.Recipient_Contact__c)){
                                                    //delChargeFinal = subsElement.delCharge;
                                                    if(delChargeFinalTemp_MAP.get(Subscription.Recipient_Contact__c) < subsElement.delCharge){
                                                        delChargeFinalTemp_MAP.put(Subscription.Recipient_Contact__c, subsElement.delCharge);
                                                    }
                                                } else {
                                                    delChargeFinalTemp_MAP.put(Subscription.Recipient_Contact__c, subsElement.delCharge);
                                                }
                                            }
                                            //End UD-2373 VPernicia 08/29/15
                                        }                               
                                        //END: UD-2009 07/22/2015 Added by J.Abolac
                                        //END: UD-0896/767/768 04/13/2015 Added by S.Puli
                                        subsElement.withDel = true;
                                        innerElement.withDelInner = true;
                                    }
                                } 
                            // START : UD-2178 8/10/2015 Alyana Navarro    
                                else {
                                    if(!delChargeFinalTemp_MAP.containsKey(Subscription.Recipient_Contact__c)){
                                        //delChargeFinalTemp_MAP.put(Subscription.Recipient_Contact__c, -1);    //START-END D-3999 12-03-2015 Added by Jason A.
                                    }
                                }
                                // END : D-0287 3/27/2015 Alyana Navarro - Get Delivery Charge                      
                            } 
                            
                            else {
                                if(!delChargeFinalTemp_MAP.containsKey(Subscription.Recipient_Contact__c)){
                                    //delChargeFinalTemp_MAP.put(Subscription.Recipient_Contact__c, -1);    //START-END D-3999 12-03-2015 Added by Jason A.
                                }
                            }
                            // END : UD-2178 8/10/2015 Alyana Navarro
                            if(Subscription.Main_Package_1__r.Number_Of_Promotions__c > 0){   
                                
                                if(Subscription.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER){
                                    promoNP = true;
                                } else{
                                    promo = true;
                                }
                            }
                            
                            //START: UD-0896/767/768 04/13/2015 Added by S.Puli
                            innerSubsWrapperList.add(innerElement);
                            
                            //END: UD-0896/767/768 04/13/2015 Added by S.Puli
                            
                            if(recipientIdSubWrapperTemp_MAP.containskey(Subscription.Recipient_Contact__c)){
                                if(innerSubsWrapperList.size()>0){
                                    
                                    
                                        recipientIdSubWrapperTemp_MAP.get(Subscription.Recipient_Contact__c).inerWrapList.add(innerElement);
                                    
                                }
                            } else {
                                subsElement.inerWrapList = innerSubsWrapperList;
                                recipientIdSubWrapperTemp_MAP.put(Subscription.Recipient_Contact__c, subsElement);
                                subsWrapperList.add(subsElement);
                            
                            }
                        //Start: UD-1114 James 05/19/2015
                            //Start: UD-1114 James 05/08/2015
                            //if(delChargeFinalTemp_MAP.get(Subscription.Recipient_Contact__c) != null({ // && recipientContact != Subscription.Recipient_Contact__c){
                                //Start D-3928 VPernicia 11/12/15: Combine the bundle subscription
                                totalsubprice = totalsubprice + intSubCharges; // + delChargeFinalTemp_MAP.get(Subscription.Recipient_Contact__c);
                                //End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                                
                                //recipientContact = Subscription.Recipient_Contact__c;
                                //delchargeadded = true;
                                //system.debug('>>>>>delChargeFinalTemp_MAP ');
                            //}else{
                                //totalsubprice = totalsubprice + Subscription.Subscription_Charge__c;
                            //}
                            //End: UD-1114 James 05/08/2015
                    //} //Start/End D-3689 VPernicia 10/6/15 //START - END: D-3724 10/16 removed by Jason A.
                    } //Start/End D-3928 VPernicia 11/12/15: Combine the bundle subscription
                }
                // START : UD-2178 8/10/2015 Alyana Navarro
                if(delChargeFinalTemp_MAP.size()>0){
                    for(Decimal x :delChargeFinalTemp_MAP.values()){                        
                        if(x != -1){
                            totalsubprice  = totalsubprice + x;
                            //START UD-2147 Gdelrosario : added the variable to flag if subscription has delivery
                            withDelCharge=true;
                        }
                        //END UD-2147 Gdelrosario : added the variable to flag if subscription has delivery
                    }
                }
                // END : UD-2178 8/10/2015 Alyana Navarro
                //START UD-2147 07/28/15 Gdelrosario - adds postage in total

                if(subIdToPostageFee_MAP != null && subIdToPostageFee_MAP.size() > 0 ){
                    for(Decimal postVal :subIdToPostageFee_MAP.values()){
                        totalsubprice  = totalsubprice + postVal;
                    }
                }
                //END UD-2147 07/28/15 Gdelrosario - adds postage in total
    //START : UD-1409/1410/1411/1412/1450 Jason A. 06/15/2015                
                strtotalsubprice = (totalsubprice.setscale(2)).format();
                
                if (strtotalsubprice.right(2).left(1) == '.') {
                    
                    strtotalsubprice = strtotalsubprice + '0';
                } else if (strtotalsubprice.right(3).left(1) != '.'){
                    strtotalsubprice = strtotalsubprice + '.00';
                }
                
    //END : UD-1409/1410/1411/1412/1450 Jason A. 06/15/2015                
                //End: UD-1114 James 05/19/2015
            }
           
            //START: UD-0896/767/768 04/13/2015 Added by S.Puli
            recipientIdSubWrapper_MAP = recipientIdSubWrapperTemp_MAP;          
            delChargeFinal_MAP = delChargeFinalTemp_MAP;                    
            //END: UD-0896/767/768 04/13/2015 Added by S.Puli
            //START : D-2112 02/20/2015 S.Puli
            barChecker = false;
            //START: D-3724 10/16 added by Jason A.
            String attChecker = '';
            if(newSubscriptionList.size()>0 && newSubscriptionList<>null){
                for(Zuora__Subscription__c z : newSubscriptionList){
            //END: D-3724 10/16 added by Jason A.
                    if(z.Contact__c <> null){
                        if(z.Contact__r.Address__c<>null){
                            if(z.Contact__r.Address__r.Postal_Code__c<>null){
                                attChecker = z.Contact__r.Address__r.Postal_Code__c;
                            }
                        }
                    }
                }
            }
            
            List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :attChecker];
            if(attList.size()>0){
                barcodeAttId = attList[0].Id;
                if(barcodeAttId<>null){
                    barChecker = true;
                }
            } else{
                barcodeAttId = null;
            }
            //END : D-2112 02/20/2015 S.Puli
            //START: D-3724 10/16 added by Jason A.
            try{
              singPostAttachment= [SELECT Id, (SELECT Id,Name FROM Attachments) FROM Singpost_Address__c WHERE Id = :newSubscriptionList[0].Contact__r.Address__r.Postal_Code__c];
            }
            //END: D-3724 10/16 added by Jason A.
            catch (Exception e){
            //START : D-2112 02/20/2015 S.Puli
              System.debug('There are no attachment');
            //END : D-2112 02/20/2015 S.Puli
            }   
        
        }
        catch(Exception e){
        //START D-4322 15/01/2016 Dags : Added is Running Test
        if(!Test.isRunningTest()){   
            logger.log(e);
            logger.save();
         }   
        //END D-4322 15/01/2016 Dags : Added is Running Test 
        }
        //END: D-4266 1-13-2016 Added by Kristine Balaoing
    }    
}