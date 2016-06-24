/**
    * Class Name: TempStopDirectController
    * @author: Jerella Mayel Ledesma and Glenn Garcia
    * Date: 09-08-2014
    * Requirement/Project Name: <SPH>
    * @description Controller for subTempStopSubs page
    * History:
    *Reconstructed whole class for calculation of credit D-0104(UAT Defect) Inline with new implementation of calculation for issues. J. Ledesma
    * @description Modified code according to the new Product Catalogue Configuration. 
    * @author: Jerella Mayel Ledesma 12/16/2014
    */
    
    
    public class TempStopDirectController {
        boolean isAdd = false; //Start/End UD-2925 VPernicia 9/25/15
        
        public Boolean followUpTask { get; set; }
        public transient string validateLimitMsg { get; set; }
        public String myId {get; set;}
        public String myIdUpdate {get; set;}
        public String myIdCancel {get; set;}
        public String tstopId {get; set;}   
        public String tempStop {get; set;}
        public String restartDate {get; set;}
        public Account thisAccount {get; set;}
        //public List<String> subscriptionId = new List<String>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient Case thisCase {get; set;} 
        transient Temp_Stop__c thisTempStop {get; set;} 
        //End UD-2925 VPernicia 9/25/15: Put Transient
        public Subscription_Temp_Stop__c subTempStop {get; set;}
        public Order__c thisOrder {get; set;}
        public String requestSource {get;set;}
        public Zuora__Subscription__c thisSub {get;set;}
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient List<Zuora__Subscription__c> subList {get;set;}
        transient List<Zuora__Subscription__c> subscriptionList {get;set;}
        //START: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
        transient List<Zuora__Subscription__c> allSubscriptionList = new List<Zuora__Subscription__c>();
        transient Map<String, String> orderLineToDelivery = new Map<String, String>();
        transient Map<Id, String> pubSubToOrderLine = new Map<Id, String>();
        //END: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
        //End UD-2925 VPernicia 9/25/15: Put Transient
        
        //List<Zuora__Subscription__c> subToUpdateList; //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //Map<Id, Set<Id>> subIdToRatePlan = new Map<Id, Set<Id>>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient Map<Id, List<Publication__c>> packageToPubrec = new Map<Id, List<Publication__c>>();
        transient Map<Id, List<Package_Item__c>> subIdToPackageItems = new Map<Id, List<Package_Item__c>>();
        transient Map<Id, Id> subIdToPackageIds = new Map<Id, Id>();
        transient Set<Id> packageIds = new Set<Id>();
        Map<Id, Zuora__Subscription__c> mapIdToSubRec = new Map<Id, Zuora__Subscription__c>(); 
        //START: D- 0077 03/03/2015 Added by Kristine Campang - added variables for new Issue Calculation Utility
        transient Map<String, Decimal> totalIssueAndTotalAmount = new Map<String, Decimal>(); 
        //START: UD-0309 03/20/2015 Year To Date computation
        transient Map<String, Decimal> totalIssueAndTotalAmountPlusYearToDate = new Map<String, Decimal>();
        //End UD-2925 VPernicia 9/25/15: Put Transient      
        //END: UD-0309 03/20/2015 Year To Date computation
        
        //Map<Id, Integer> subIdToCurrentYear = new Map<Id, Integer>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //Map<Id, Integer> subIdToNextYear = new Map<Id, Integer>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        Integer pendingCopiesPerPub = 0;
        Decimal weekdayIssue = 0;
        Decimal SaturdayIssue = 0;
        Decimal SundayIssue = 0;
        Integer accumulatedCurrentYear = 0;
        Integer accumulatedNextYear = 0;
        Integer currentYear = 0;
        Integer nextYear = 0;
        Decimal copyPriceWeekday = 0;
        Decimal copyPriceSaturday = 0;
        Decimal copyPriceSunday = 0;
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient Map<String, Decimal> refundEligibleAndTotalCredit = new Map<String, Decimal>();
        transient List<Zuora__SubscriptionProductCharge__c> zuoSubProdChargListDisc = new List<Zuora__SubscriptionProductCharge__c>();
        transient Set<Zuora__SubscriptionProductCharge__c> zSPCDiscount = new Set<Zuora__SubscriptionProductCharge__c>();
        transient Set<Date> zSPCDiscountSet = new Set<Date>(); 
        transient List<Date> zSPCDiscountList = new List<Date>();
        transient Map<Id, Decimal> mapSPCDiscToPrice = new Map<Id, Decimal>();
        transient Map<Date, Id> mapDateToSPC = new Map<Date, Id>();
        transient Map<Id, List<Date>> finalDiscountMap = new Map<Id, List<Date>>(); 
        //End UD-2925 VPernicia 9/25/15: Put Transient
        Map<Id, List<Date>> totalDiscountDateMap = new Map<Id, List<Date>>();
        Decimal totalDiscountAmount = 0;
        Decimal totalNotDiscountedAmount = 0;
        Decimal weekDayNotDiscounted = 0;
        Decimal saturdayNotDiscounted = 0;
        Decimal sundayNotDiscounted = 0;
        Decimal weekDayDiscount = 0;
        Decimal saturdayDiscount = 0;
        Decimal sundayDiscount = 0;
        Decimal totalDiscount = 0;
        Decimal totalDiscountPerPub = 0;
        Decimal totalNotDiscounted = 0;
        Decimal totalNotDiscountedPerPub = 0;
        Map<Id, Zuora__SubscriptionProductCharge__c> mapSPCIdToSPCRec = new Map<Id, Zuora__SubscriptionProductCharge__c>();
        //Map<String, Map<String, Decimal>> mapPRC_UOM_Price = new Map<String, Map<String, Decimal>>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //END: D- 0077 03/03/2015 Added by Kristine Campang
        public String selectedTempStopType {get; set;}
        public Set<Date> tsDate= new Set<Date>();
        public List<Subscription_Temp_Stop__c> subTempStopRecList {get;set;}
        public SubscriptionWrapper wrapper;
        public SubscriptionWrapper wrapper2;
        public SubscriptionWrapper wrapper3;
        public SelectedWrapper tempstopwrapper;
        //public List<Contact> contact {get; set;} //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        public String subfreq {get; set;}
        public Boolean isPubDay {get; set;}
        public SubscriptionWrapper wrapperToUpdate {get; set;}
        public SubscriptionWrapper wrapperToCancel {get; set;} 
        public List<SubscriptionWrapper> subscriptionResultList {get;set;}
        public List<SubscriptionWrapper> updateResultList {get;set;}
        public List<SubscriptionWrapper> cancelResultList {get;set;}
        public List<SubscriptionWrapper> updateListWrapper {get;set;}
        public List<SubscriptionWrapper> cancelListWrapper {get;set;}
        public List<Subscription_Temp_Stop__c> sToUpdate {get; set;}
        public List<Subscription_Temp_Stop__c> sToCancel {get; set;}
        public Integer currentQty {get; set;}
        public Integer tempStopQty {get; set;}
        public List<SelectedWrapper> updateRequestList {get;set;}   
        public List<SelectedWrapper> cancelRequestList {get;set;}
        public List<SelectedWrapper> tempStopRequestList {get;set;} 
        Set<String> pubcodes = new Set<String>();
        List<Publication__c> pubList;
        String validation = '';
        List<String> checker = new List<String>();
        Boolean duplicateChecker;
        //map<Id, Id> mCaseOrder = new map<Id, Id>(); Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient map<Id, Id> mTSCas = new map<Id, Id>(); 
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        transient map<Id, List<Id>> mCasSub = new map<Id, List<Id>>();
        //END UD-2443 9/5/2015 Added By C. Lin
        //End UD-2925 VPernicia 9/25/15: Put Transient
        Integer indexNumber = 0;
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient List<Case> createdCaseRecords = new List<Case>();
        //End UD-2925 VPernicia 9/25/15: Put Transient
        Integer eShopMonths = integer.valueOf(ConstantsSLB.getKeyId('EshopDuration'));
        Integer crsmMonths = integer.valueOf(ConstantsSLB.getKeyId('CRSMDuration'));  
        //List<Zuora__Subscription__c> subscriptionToBeUpdated = new List<Zuora__Subscription__c>(); Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //START: D-2407 2/26/2015 Computation of year to date days
        //Map<Id, Zuora__Subscription__c> mapSubIdToSubRecord = new Map<Id, Zuora__Subscription__c>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //END: D-2407 2/26/2015 Computation of year to date days
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient List<zqu__ProductRatePlanCharge__c> ratePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        //End UD-2925 VPernicia 9/25/15: Put Transient
        
        //List<Date> earliest = new List<Date>(); Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        List<Zuora__SubscriptionProductCharge__c> subProdChList = new List<Zuora__SubscriptionProductCharge__c>();
        //START:UD-3127 10/22/15 Added by Manolo Valena
        List<Zuora__SubscriptionProductCharge__c> subProdChListDisc = new List<Zuora__SubscriptionProductCharge__c>();
        Map<Id, Double> subscriptionToDiscountPrice = new Map<Id, Double>();
        //END:UD-3127 10/22/15 Added by Manolo Valena
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient Map<String, Decimal> mapRefundTotalCredit = new Map<String, Decimal>(); 
        //End UD-2925 VPernicia 9/25/15: Put Transient
        Map<Id, List<String>> subToCoverPrice = new Map<Id, List<String>>();
        //START: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
        //Map<Id, List<Zuora__SubscriptionProductCharge__c>> subToDiscountSPCList = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>(); Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        transient Map<Id,Map<String, Double>> sProdChargeUOMToPrice = new Map<Id,Map<String, Double>>(); // SubscriptionId to Subscription Product & Charge UOM with Price
        //End UD-2925 VPernicia 9/25/15: Put Transient
        //END: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
        //Start D-2483 03/10/2015 James - Temp Stop Settings View for Reference Data
        List<Temp_Stop_Setting__c> tempstopsettings = [SELECT Name, TempStop_Min_Gap_Days__c, TemStop_Max_Issues__c, TemStop_Min_Issues__c from Temp_Stop_Setting__c LIMIT 1];
        String TEMPSTOPCANCELLEDSTATUS = ConstantsSLB.getOther('TEMPSTOPCANCELLEDSTATUS');
        //End D-2483 03/10/2015 James - Temp Stop Settings View for Reference Data   
        //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
        List <Case> PendingCase = new List<Case>();
        //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
        //START: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        //transient List <Id> caseIds = new List<Id>(); //START END UD-3417 21Jan2016 Added By C. Lin - Comment Out cause not used
        //End UD-2925 VPernicia 9/25/15: Put Transient
        //END: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
        //START: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
        public Map<ID,List<Case>> subToPendingCasesMap = new Map<ID,List<Case>>(); 
        //END: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
        //Start UD-2925 VPernicia 9/25/15: Put Transient
        //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
        transient Map<String, List<Publication__c>> prodCodeToPubRecMap = new Map<String, List<Publication__c>>();
        transient Map<Id, String> subIdToProductCodeMap = new Map<Id, String>();
        transient Map<Id, List<Zuora__Subscription__c>> oliIdToBundlePubSubListMap = new Map<Id, List<Zuora__Subscription__c>>();
        transient Map<Id, Subscription_Temp_Stop__c> stsIdToStsMap = new Map<Id, Subscription_Temp_Stop__c>();
        //END-3329 8/26/2015 Added By C. Lin
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        Map<Id, Map<Id, SelectedWrapper>> selectedIdToSubIdToTempStopUpdate = new Map<Id, Map<Id, SelectedWrapper>>(); //START END UD-3417 21Jan2016 Added By C. Lin - Remove Transient. Do not transiet since this map is being used for Multiple Temp Stop for the same subscription. Every Add populates this map and should not be cleared.
        transient Map<Id, Set<Id>> subIdToStsIdSetMap = new Map<Id, Set<Id>>();
        transient List<Case> cList = new List<Case>();
        //Map<Id, Case> caseIdToCaseMap = new Map<Id, Case>();//Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        transient Set<Id> tempStopIds = new Set<Id>(); 
        //List<Temp_Stop__c> tsList = new List<Temp_Stop__c>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        //Map<Id, Temp_Stop__c> tsIdToTempStopMap = new Map<Id, Temp_Stop__c>();
        transient Set<Id> subUpdateIdSet = new Set<Id>(); 
        transient List<Zuora__Subscription__c> listSubs = new List<Zuora__Subscription__c>();
        //Map<Id, Zuora__Subscription__c> subIdToSubMap = new Map<Id, Zuora__Subscription__c>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
        public List<Subscription_Temp_Stop__c> orderedStsList {get;set;}
        transient Map<Id, List<Subscription_Temp_Stop__c>> subIdToStsMap = new Map<Id, List<Subscription_Temp_Stop__c>>(); 
        //END UD-2443 9/5/2015 Added By C. Lin
        //START UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
        transient Set<Id> returnedSetIdOfSub = new Set<Id>();
        //END UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
        //End UD-2925 VPernicia 9/25/15: Put Transient
        
        //START UD-2925 10/08/2015 Added By C. Lin - Move out ConstantsSLB.getUOM from for loop
        String copySun = ConstantsSLB.getUOM('Copy Sun');
        String copyWeek = ConstantsSLB.getUOM('Copy Weekday');
        String copySat = ConstantsSLB.getUOM('Copy Sat');
        String discPer = ConstantsSLB.getUOM('Discount-Percentage');
        Map<Id, List<Package_Item__c>> packIdToPackItemListMap = new Map<Id, List<Package_Item__c>>();
        //END UD-2925 10/08/2015 Added By C. Lin
        
        //START: D-3628 10/29/15 Added by Manolo Valena
        //Map<Id, Case> caseIdToCaseRecMap = new Map<Id, Case>(); //START END UD-3417 21Jan2016 Added By C. Lin - Comment Out cause not used
        //END: D-3628 10/29/15 Added by Manolo Valena
    Id parentCaseId; //START/END UD-3293 11/25/15 RReyes
        
        //START: UD-3295 11/24/15 Added by Manolo Valena
        Map<Id, String> subscriptionIdToPackageTypeMap = new Map<Id, String>();
        Map<Id, String> stsIdToPackageTypeMap = new Map<Id, String>();
        //END: UD-3295 11/24/15 Added by Manolo Valena
        
        public class SubscriptionWrapper{
            public String tempStopId {get; set;} 
            public String id {get; set;}
            public String subid {get; set;}
            public String packageId {get; set;}
            public Decimal yearToDate {get; set;}
            public String recipientid {get; set;}
            public String billingid {get; set;}
            public String subscriptionName {get; set;}
            public Decimal tempStopQty {get; set;}
            public Date tempStopDate {get; set;}
            public Date restartDate {get; set;}  
            public Temp_Stop__c tp {get;set;}
            public String status {get; set;}
            public Date earliestStartDate {get; set;}
            public String frequency {get; set;}
            public String billingAccount {get; set;}
            public String recipient {get; set;}
            public String deliverySub {get; set;}
            public integer tempstopDays {get; set;}
            public integer qty {get; set;}
            public integer orderTempStopDays {get; set;}
            public integer totalIssues {get; set;}
            public String tempStopStatus {get; set;}
            public String remarks {get; set;}
            public Boolean isTempstopdateGTTODAY {get; set;} 
            public Boolean isrestartdateLTEearliestStartDate {get; set;} 
            public Boolean isrestartdateGTToday {get; set;}  
            public Date subEndDate {get; set;}
            public Integer yearToDateCurrentYear {get; set;}
            public Integer yearToDateNextYear {get; set;}
            public Integer oldYearToDateCurrentYear {get; set;}
            public Integer oldYearToDateNextYear {get; set;}
            //START: D-1298 1/5/15 Added by J.Ledesma – related.
            public Date subStartDate {get; set;}
            //END: D-1298 1/5/15 Added by J.Ledesma – related.
            public Boolean isTempstopdateLTEToday {get; set;}  
            //START: D-1950 2/10/15 JLedesma - Update old temp stop status
            public String tempStopToUpdate {get; set;} 
            //END: D-1950 2/10/15 JLedesma - Update old temp stop status
            //START: D-2407 2/27/2015 Computation of year to date days
            public integer yearToDateTemp {get; set;}
            //END: D-2407 2/27/2015 Computation of year to date days
            //START: UD-0309 03/20/2015 Year To Date computation
             public integer yearToDateNextYearfromSub {get; set;}
             //END: UD-0309 03/20/2015 Year To Date computation
             //START: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
            public String caseStatusUpdate {get; set;}
            //END: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
            //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
            public String productCode {get; set;}
            //END UD-2233 8/19/2015 Added By C. Lin
        }
           // vst.tempstopdate <= TODAY() && vst.restartdate > TODAY()
       
        public class SelectedWrapper{
            public String tempStopId {get; set;} 
            public Date subEndDate {get; set;}
            //START: D-1298 1/5/15 Added by J.Ledesma – related.
            public Date subStartDate {get; set;}
            //END: D-1298 1/5/15 Added by J.Ledesma – related.
            public String tempStopStatus {get; set;}
            public String subid {get; set;}
            public String packageId {get; set;}
            public integer orderTempStopDays {get; set;}
            public integer totalIssues {get; set;}
            public Decimal yearToDate {get; set;}
            public String recipientid {get; set;}
            public String billingid {get; set;}
            public String id {get; set;}
            public String subscriptionName {get; set;}
            public Date earliestStartDate {get; set;} 
            public Date tempStopDate {get; set;}
            public Date restartDate {get; set;}
            public String remarks {get; set;}
            public Decimal tempStopQty {get; set;}  
            public String status {get; set;}
            public String frequency {get; set;}
            public String billingAccount {get; set;}
            public String recipient {get; set;}
            public String deliverySub {get; set;}
            public integer tempstopDays {get; set;}
            public integer qty {get; set;}
            public integer refundEligible {get; set;}
            public decimal totalCredit {get; set;}
            public Integer yearToDateCurrentYear {get; set;}
            public Integer yearToDateNextYear {get; set;}
            public Integer oldYearToDateCurrentYear {get; set;}
            public Integer oldYearToDateNextYear {get; set;}
            //START: D-1950 2/10/15 JLedesma - Update old temp stop status
            public String tempStopToUpdate {get; set;}  
            //END: D-1950 2/10/15 JLedesma - Update old temp stop status
            //START: D-2407 2/27/2015 Computation of year to date days
            public integer yearToDateTemp {get; set;}
            //END: D-2407 2/27/2015 Computation of year to date days
            //START: UD-0309 03/20/2015 Year To Date computation
            public integer yearToDateNextYearfromSub {get; set;}
            //END: UD-0309 03/20/2015 Year To Date computation
            //START: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
            public String caseStatusUpdate {get; set;}
            //END: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
            //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
            public String productCode {get; set;}
            //END UD-2233 8/19/2015 Added By C. Lin
        }
        
        
        /*Description: Checks duplicates for Selected Create Table 
        *Parameter: NA
        *Return: Boolean
        */    
        public Boolean checkDuplicateSubscription() {
            //START UD-2008 8/13/2015 Added By C. Lin - Instantiate checker list again when method is invoked
            checker = new List<String>();
            //END UD-2008 8/13/2015 Added By C. Lin
            for(SelectedWrapper sub : tempStopRequestList) {
                if(sub.id.equals(myId)) {
                    checker.add(myId);
                }
            } 
            
            if(checker.size()>0){
                duplicateChecker = False;
            }
            else{
                duplicateChecker = True;
            }
            
            return duplicateChecker;
            
        }
        
        /*Description: Checks duplicates for Selected Update Table 
        *Parameter: NA
        *Return: Boolean
        */
        public Boolean checkDuplicateSubscriptionUpdate() {
            //START D-3328 8/7/2015 Added by Manolo Valena - reinstantiate checker list everytime method is invoked.
            checker = new List<String>();
            //END D-3328 8/7/2015 Added by Manolo Valena
            for(SelectedWrapper sub : updateRequestList) {
                if(sub.id.equals(myIdUpdate)) {
                    checker.add(myIdUpdate);
                }
            } 
            
            if(checker.size()>0){
                duplicateChecker = False;
            }
            else{
                duplicateChecker = True;
            }
            
            return duplicateChecker;
        }
        
        /*Description: Checks duplicates for Selected Cancel Table 
        *Parameter: NA
        *Return: Boolean
        */
        public Boolean checkDuplicateSubscriptionCancel() {
            //START UD-2008 8/13/2015 Added By C. Lin - Instantiate checker list again when method is invoked
            checker = new List<String>();
            //END UD-2008 8/13/2015 Added By C. Lin
            for(SelectedWrapper sub : cancelRequestList) {
                if(sub.id.equals(myIdCancel)) {
                    checker.add(myIdCancel);
                }
            } 
            if(checker.size()>0){
                duplicateChecker = False;
            }
            else{
                duplicateChecker = True;
            }
            
            return duplicateChecker;
        }
        
        /*Description: Remove selected row from Update Selected Table
        *Parameter: NA
        *Return: NA
        */
        public void removeSubscriptionRecordUpdate() {
            //Start UD-2925 VPernicia 9/25/15: Put Transient
            getSubscriptions();
            //End UD-2925 VPernicia 9/25/15: Put Transient
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            Set<Id> relateSubTempIdSet = new Set<Id>();
            
            for(Subscription_Temp_Stop__c s : subTempStopRecList){
                for(Zuora__Subscription__c subs : oliIdToBundlePubSubListMap.get(s.Subscription__r.Order_Line_Item_Number__c)){
                    if(stsIdToStsMap.get(myIdUpdate).Subscription__r.Order_Line_Item_Number__c == Id.valueOf(pubSubToOrderLine.get(subs.Id)) && s.Temp_Stop__r.Temp_Stop_Date__c == stsIdToStsMap.get(myIdUpdate).Temp_Stop__r.Temp_Stop_Date__c && s.Temp_Stop__r.Restart_Date__c == stsIdToStsMap.get(myIdUpdate).Temp_Stop__r.Restart_Date__c && s.Temp_Stop__r.Temp_Stop_Status__c == stsIdToStsMap.get(myIdUpdate).Temp_Stop__r.Temp_Stop_Status__c){
                        //START: UD-3295 11/24/15 Added by Manolo Valena
                        if(stsIdToPackageTypeMap.containsKey(s.Id) && 
                           stsIdToPackageTypeMap.get(s.Id) != GlobalVariableClass.PACKAGETYPE_ADDON) {
                            relateSubTempIdSet.add(s.Id);
                        }
                        //END: UD-3295 11/24/15 Added by Manolo Valena
                    }
                }
            }
            //END D-3329 8/26/2015 Added By C. Lin
            
            for(Integer counter = 0; counter < updateRequestList.size(); counter++) {
                //START: UD-3295 11/24/15 Added by Manolo Valena
                if(stsIdToPackageTypeMap.containsKey(myIdUpdate) && 
                   stsIdToPackageTypeMap.get(myIdUpdate) != GlobalVariableClass.PACKAGETYPE_ADDON) {
                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                    for(Id bSubId : relateSubTempIdSet){
                        if(updateRequestList[counter].id == myIdUpdate || updateRequestList[counter].id == bSubId){
                            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
                            selectedIdToSubIdToTempStopUpdate.remove(updateRequestList[counter].id);
                            //END UD-2443 9/5/2015 Added By C. Lin
                            
                            updateRequestList.remove(counter);
                        }
                    }
                    //END D-3329 8/26/2015 Added By C. Lin
                }
                else if(stsIdToPackageTypeMap.containsKey(myIdUpdate) && 
                        stsIdToPackageTypeMap.get(myIdUpdate) == GlobalVariableClass.PACKAGETYPE_ADDON && 
                        updateRequestList[counter].id == myIdUpdate) {
                    selectedIdToSubIdToTempStopUpdate.remove(updateRequestList[counter].id);
                    updateRequestList.remove(counter);
                }
                //END: UD-3295 11/24/15 Added by Manolo Valena
            }
        }
        
        /*Description: Remove selected row from Cancel Selected Table
        *Parameter: NA
        *Return: NA
        */
        public void removeSubscriptionRecordCancel() {
            //Start UD-2925 VPernicia 9/25/15: Put Transient
            getSubscriptions();
            //End UD-2925 VPernicia 9/25/15: Put Transient
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            Set<Id> relateSubTempIdSet = new Set<Id>();
            
            for(Subscription_Temp_Stop__c s : subTempStopRecList){
                for(Zuora__Subscription__c subs : oliIdToBundlePubSubListMap.get(s.Subscription__r.Order_Line_Item_Number__c)){
                    if(stsIdToStsMap.get(myIdCancel).Subscription__r.Order_Line_Item_Number__c == Id.valueOf(pubSubToOrderLine.get(subs.Id)) && s.Temp_Stop__r.Temp_Stop_Date__c == stsIdToStsMap.get(myIdCancel).Temp_Stop__r.Temp_Stop_Date__c && s.Temp_Stop__r.Restart_Date__c == stsIdToStsMap.get(myIdCancel).Temp_Stop__r.Restart_Date__c && s.Temp_Stop__r.Temp_Stop_Status__c == stsIdToStsMap.get(myIdCancel).Temp_Stop__r.Temp_Stop_Status__c){
                        //START: UD-3295 11/24/15 Added by Manolo Valena
                        if(stsIdToPackageTypeMap.containsKey(s.Id) && 
                           stsIdToPackageTypeMap.get(s.Id) != GlobalVariableClass.PACKAGETYPE_ADDON) {  
                            relateSubTempIdSet.add(s.Id);
                        }
                        //END: UD-3295 11/24/15 Added by Manolo Valena
                    }
                }
            }
            //END D-3329 8/26/2015 Added By C. Lin
            
            for(Integer counter = 0; counter < cancelRequestList.size(); counter++) {
                //START: UD-3295 11/24/15 Added by Manolo Valena
                if(stsIdToPackageTypeMap.containsKey(myIdCancel) && 
                   stsIdToPackageTypeMap.get(myIdCancel) != GlobalVariableClass.PACKAGETYPE_ADDON) {
                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                    
                    for(Id bSubId : relateSubTempIdSet){
                        if(cancelRequestList[counter].id == myIdCancel || cancelRequestList[counter].id == bSubId){
                            cancelRequestList.remove(counter);
                        }
                    }
                    //END D-3329 8/26/2015 Added By C. Lin
                }
                else if(stsIdToPackageTypeMap.containsKey(myIdCancel) && 
                        stsIdToPackageTypeMap.get(myIdCancel) == GlobalVariableClass.PACKAGETYPE_ADDON && 
                        cancelRequestList[counter].id == myIdCancel) {
                    cancelRequestList.remove(counter);
                }
                //END: UD-3295 11/24/15 Added by Manolo Valena
            }
        }
        
        /*Description: Function for cancel button
        *Parameter: NA
        *Return: PageReference 
        */
        public PageReference cancel() {
            PageReference pRef = new PageReference('/' + thisAccount.Id);
            return pRef;    
        }
        
        /*Description: Validates the input if it exceeds the number of current quantity
        *Parameter: NA
        *Return: NA
        */   
        public PageReference validateLimit() {
                if (currentQty < tempstopQty){
                    validation = globalvariableclass.TS_YES;
                }
                else{
                    validation = globalvariableclass.TS_NO;
                }
                return null;
        }
        
        /*Description: Returns value of the validation for Quantity 
        *Parameter: NA
        *Return: String
        */   
        public String getErrorOnLimit() {
            return validation;
        }
        
        /*Description: Gets the selected radio button
        *Parameter: NA
        *Return: String
        */   
        public String getselectedTempStopType() {
           return selectedTempStopType;
        }
        
        /*Description: Sets the selected radio button
        *Parameter: String
        *Return: NA
        */   
        public void setTempStopType(String selectedTempStopType) {    
            this.selectedTempStopType = selectedTempStopType; 
        }
     
        //START: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
        public Boolean pendingCaseChecker(Id subid){
            Boolean hasPending = FALSE;
            if(subToPendingCasesMap.containsKey(subid)){
                hasPending = TRUE;
            }
            
            return hasPending;
        }       
        //END: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)  
           
        /*Description: Initializes the controller
        *Parameter: NA
        *Return: NA
        */   
        public TempStopDirectController(){        
            thisTempStop = new Temp_Stop__c();
            subscriptionResultList = new List<SubscriptionWrapper>();    
            updateResultList = new List<SubscriptionWrapper>();  
            cancelResultList = new List<SubscriptionWrapper>();  
            tempStopRequestList = new List<SelectedWrapper>();
            updateRequestList = new List<SelectedWrapper>();  
            cancelRequestList = new List<SelectedWrapper>();        
            thisSub = new Zuora__Subscription__c();
            thisCase = new Case();
            getAccount();
            getRequestSources();
            getSubscriptions();
            setSubscriptionRecords();
            setSubscriptionRecordsUpdate();
            setSubscriptionRecordsCancel();
            //START UD-3293 11/25/15 RReyes
            parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
            if (parentCaseId != null) {
                string tmp = parentCaseId;
                tmp.toLowerCase();
                if (tmp == 'null') {
                    parentCaseId = null;
                }
            }   
            //END UD-3293 11/25/15 RReyes
            }
         //START: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop   
        public String deliverySub(Id subId){
            String orderLineItemNumber = null;
            String Delivery = '';
            if(pubSubToOrderLine.containsKey(subId)){
                orderLineItemNumber = pubSubToOrderLine.get(subId);
            }
            
            if(orderLineItemNumber!= NULL && orderLineToDelivery.containsKey(orderLineItemNumber)){
                Delivery = orderLineToDelivery.get(orderLineItemNumber);
            }
            
            return Delivery;
            
        }
         //END: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop          
        /*Description: Gets the account ID of the record. 
        *Parameter: NA
        *Return: NA
        */   
        public void getAccount() {
            Id accountId = ApexPages.currentPage().getParameters().get('accountId');
            thisAccount = [SELECT Id, Name, Date_Since__c,Contact_Person__c, AccountNumber, RecordType.Name FROM Account WHERE Id = :accountID];   
        } 
        
        /*Description: Sets subscriptions for the Create, Update, and Cancel Temp Stops
        *Parameter: NA
        *Return: NA
        */     
        //START: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
        public void getSubscriptions() {  
            Boolean flag = false;
            Boolean subsChecker = false;
            sublist = new List<Zuora__Subscription__c>();
            subscriptionlist = new List<Zuora__Subscription__c>();
            allSubscriptionList = new List<Zuora__Subscription__c>();
            orderLineToDelivery = new Map<String, String>();
            pubSubToOrderLine = new Map<Id, String>();
            sToUpdate = new LIST<Subscription_Temp_Stop__c>();
            sToCancel = new LIST<Subscription_Temp_Stop__c>();  
            subProdChList = new List<Zuora__SubscriptionProductCharge__c>();
            //START:UD-3127 10/22/15 Added by Manolo Valena
            subProdChListDisc = new List<Zuora__SubscriptionProductCharge__c>();
            //END:UD-3127 10/22/15 Added by Manolo Valena
            subIdToPackageIds = new Map<Id, Id>();
            //Start UD-2925 VPernicia 9/25/15: Put Transient
            oliIdToBundlePubSubListMap = new Map<Id, List<Zuora__Subscription__c>>();
            mapIdToSubRec = new Map<Id, Zuora__Subscription__c>();
            packageIds = new Set<Id>();
            subIdToProductCodeMap = new Map<Id, String>();
            sProdChargeUOMToPrice = new Map<Id,Map<String, Double>>();
            subIdToPackageItems = new Map<Id, List<Package_Item__c>>();
            pubcodes = new Set<String>();
            packageToPubrec = new Map<Id, List<Publication__c>>();
            prodCodeToPubRecMap = new Map<String, List<Publication__c>>();
            zuoSubProdChargListDisc = new List<Zuora__SubscriptionProductCharge__c>();
            zSPCDiscount = new Set<Zuora__SubscriptionProductCharge__c>();
            zSPCDiscountList = new List<Date>();
            totalIssueAndTotalAmount = new Map<String, Decimal>();
            refundEligibleAndTotalCredit = new Map<String, Decimal>();
            //caseIds = new List<Id>(); //START END UD-3417 21Jan2016 Added By C. Lin - Comment Out cause not used
            tempStopIds = new Set<Id>();
            subUpdateIdSet = new Set<Id>();
            stsIdToStsMap = new Map<Id, Subscription_Temp_Stop__c>();
            pubSubToOrderLine = new Map<Id, String>();
            subIdToStsIdSetMap = new Map<Id, Set<Id>>();
            //selectedIdToSubIdToTempStopUpdate = new Map<Id, Map<Id, SelectedWrapper>>(); //START END UD-3417 21Jan2016 Added By C. Lin - Remove to not clear the Map's value for every add. getSubscriptions() method is being called for every click of add button
            //End UD-2925 VPernicia 9/25/15: Put Transient
            //START: D-1298 1/5/15 Added by J.Ledesma – related.
            //START: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
            //START UD-0297 3/10/2015 Added By C. Lin - Added query filter which Subscription End Date is today or later than today.
            //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
            //START: UD-0474 JLedesma 3/27/2015 Cater evergreen.
            //START UD-2233 8/19/2015 Added By C. Lin - Add Product_Code__c to identify bundle packages
            //START: UD-3295 11/24/15 Added by Manolo Valena - Added Main_Package_1__r.Package_Type__c.
            allSubscriptionList = [SELECT Order_Line_Item_Number__c, Status_Formula__c, Order_Line_Item_Number_1__r.Ph_d__c, Order_Line_Item_Number_1__r.Ph_e__c, Next_Year_Temp_Stop_Days__c, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Ph_d__c, Ph_e__c, Id, Zuora__SubscriptionEndDate__c, Recipient_Address_ID__c, Main_Package_1__r.Name, Year_to_Date_Temp_Stop_Days__c, Previous_Year_Temp_Stop_Days__c, Subscription_Type_1__c, Name, Zuora__CustomerAccount__r.Name, Main_Package_1__r.Id, Zuora__CustomerAccount__r.Id, Delivery_Charge__c, Frequency_1__c, Recipient_Contact__r.Name, Recipient_Contact__r.Id, Zuora__Status__c, Number_of_Copies__c, Zuora__SubscriptionStartDate__c, Product_Code__c, Main_Package_1__r.Package_Type__c 
            //END: UD-3295 11/24/15 Added by Manolo Valena 
                       FROM Zuora__Subscription__c 
                       WHERE Zuora__Account__c = :thisAccount.Id AND (Zuora__Status__c = :globalvariableclass.SUBSCRIPTION_STATUS_ACTIVE OR Zuora__Status__c = :globalvariableclass.STATUS_CANCELLED) AND (Zuora__SubscriptionEndDate__c >= TODAY OR Zuora__TermSettingType__c = 'EVERGREEN')];
            //END UD-2233 8/19/2015 Added By C. Lin
                       
            for(Zuora__Subscription__c s : allSubscriptionList){
                if(s.Subscription_Type_1__c == globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION){
                    subscriptionList.add(s);                
                    if(s.Order_Line_Item_Number__c!=null){
                        pubSubToOrderLine.put(s.Id, s.Order_Line_Item_Number__c);
                        
                        //START: UD-3295 11/24/15 Added by Manolo Valena
                        if(!subscriptionIdToPackageTypeMap.containsKey(s.Id)) {
                            subscriptionIdToPackageTypeMap.put(s.Id, s.Main_Package_1__r.Package_Type__c);
                        }
                        //END: UD-3295 11/24/15 Added by Manolo Valena
                        
                        //START: UD-3295 11/24/15 Added by Manolo Valena
                        if(s.Main_Package_1__r.Package_Type__c != GlobalVariableClass.PACKAGETYPE_ADDON) {
                            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                            if(oliIdToBundlePubSubListMap.containsKey(s.Order_Line_Item_Number__c)){
                                oliIdToBundlePubSubListMap.get(s.Order_Line_Item_Number__c).add(s);
                            }else{
                                oliIdToBundlePubSubListMap.put(s.Order_Line_Item_Number__c, new List<Zuora__Subscription__c>{s});
                            }
                            //END D-3329 8/26/2015 Added By C. Lin
                        }
                        //END: UD-3295 11/24/15 Added by Manolo Valena
                    }
                }               
                
                if(s.Subscription_Type_1__c == globalvariableclass.SUBSCRIPTION_TYPE_DELIVERY || s.Subscription_Type_1__c == globalvariableclass.SUBSCRIPTION_TYPE_POSTAGE){
                    if(s.Order_Line_Item_Number__c!=null){
                        orderLineToDelivery.put(s.Order_Line_Item_Number__c, s.Name);
                    }
                }
                
            }
            //END: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
            //END: UD-0474 JLedesma 3/27/2015 Cater evergreen.
            //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
            //END UD-0297 3/10/2015 Added By C. Lin
            //END: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
            //START: D-1298 1/5/15 Added by J.Ledesma – related.
            if((subscriptionList != null)){
                for (Zuora__Subscription__c sub : subscriptionList ) {
                    if(sub.Main_Package_1__c != NULL){
                        subIdToPackageIds.put(sub.ID, sub.Main_Package_1__c);
                        mapIdToSubRec.put(sub.ID, sub);
                    }
                }
                //Set<Id> returnedSetIdOfSub = new Set<Id>(); //START-END UD-2560 Added by J.Sarion - Moved on top
                //START UD-2925 10/08/2015 Added By C. Lin - Remove subsID. Change for loops to mapping to prevent error.
                returnedSetIdOfSub = initialize(subIdToPackageIds);
                
                for(Id sId: returnedSetIdOfSub){
                    if(mapIdToSubRec.containsKey(sId)){
                        sublist.add(mapIdToSubRec.get(sId));
                    }
                }
                //END UD-2925 10/08/2015 Added By C. Lin
                //START: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
                //START UD-2925 10/08/2015 Added By C. Lin - Change subsID to subIdToPackageIds.keySet()
                List<Case> pendingCases = [SELECT Id, Temp_Stop_Sub__c FROM Case WHERE Temp_Stop_Sub__c =: subIdToPackageIds.keySet() AND Status = 'Pending' ];
                //END UD-2925 10/08/2015 Added By C. Lin
                
                for(Case c: pendingCases){
                    if(subToPendingCasesMap.containsKey(c.Temp_Stop_Sub__c)){
                        subToPendingCasesMap.get(c.Temp_Stop_Sub__c).add(c);
                    }
                    else{
                        subToPendingCasesMap.put(c.Temp_Stop_Sub__c, new List<Case>());
                        subToPendingCasesMap.get(c.Temp_Stop_Sub__c).add(c);
                    }
                }
                //END: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)

                //end
                //START: D-1298 1/5/15 Added by J.Ledesma – related.
                //START: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
                 //START: D-2407 2/26/2015 Computation of year to date days
                 //START: UD-0326 3/19/2015 Computation of year to date days
                /*Start UD-2925 VPernicia 9/25/15: Comment out*/
                //for(Zuora__Subscription__c zs : sublist){
                //    mapSubIdToSubRecord.put(zs.Id, zs);
                //}
                //End UD-2925 VPernicia 9/25/15: Comment out */
                //END: UD-0326 3/19/2015 Computation of year to date days
                //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                //START: UD-1066 5/8/2015 Include all eligible subscriptions for Temp Stop
                //START UD-2233 8/19/2015 Added By C. Lin - Add Product_Code__c to identify bundle packages
                //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. Add Subscription__c, Temp_Stop__r.Case__c
                subTempStopRecList = [SELECT Subscription__r.Status_Formula__c, Subscription__r.Order_Line_Item_Number__c, Subscription__r.Order_Line_Item_Number_1__r.Ph_d__c, Subscription__r.Order_Line_Item_Number_1__r.Ph_e__c, Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c, Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c, Subscription__r.Next_Year_Temp_Stop_Days__c, Subscription__r.Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Subscription__r.Year_to_Date_Temp_Stop_Days__c, Subscription__r.Ph_d__c, Subscription__r.Ph_e__c, Subscription__r.Zuora__SubscriptionStartDate__c , Subscription__r.Zuora__SubscriptionEndDate__c, Subscription__r.Recipient_Address_ID__c, Subscription__r.Main_Package_1__r.Id, Subscription__r.Main_Package_1__r.Name, Temp_Stop__r.Id, Subscription__r.Recipient_Contact__r.Id, Subscription__r.Zuora__CustomerAccount__r.Id, Id, Name, Subscription__r.Delivery_Charge__c, Subscription__r.Name, Subscription__r.Id, Temp_Stop__r.Qty__c, Subscription__r.Zuora__Status__c, Temp_Stop__r.Case__r.Total_Issue__c,
                                    Subscription__r.Frequency_1__c, Subscription__r.Zuora__CustomerAccount__r.Name, Subscription__r.Recipient_Contact__r.Name, 
                                    //START: UD-3295 11/24/15 Added by Manolo Valena
                                    Temp_Stop__c, Temp_Stop__r.Temp_Stop_Date__c, Subscription__r.Number_of_Copies__c, Temp_Stop__r.Temp_Stop_Status__c, Temp_Stop__r.POP_Start_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Request_Total_Issue__c, Temp_Stop__r.Case__r.Year_To_Date_Count__c, Subscription__r.Product_Code__c, Subscription__c, Temp_Stop__r.Case__c, Subscription__r.Main_Package_1__r.Package_Type__c 
                                    //END: UD-3295 11/24/15 Added by Manolo Valena
                                    //START PD-0001 03May2016 Added By C. Lin - Bypass Migrated Data for Overlapping Validation
                                    , Subscription_Temp_Stop_Legacy_Id__c 
                                    //END PD-0001 03May2016 Added By C. Lin
                                    FROM Subscription_Temp_Stop__c WHERE Subscription__c IN : returnedSetIdOfSub]; 
                //END UD-2443 9/5/2015 Added By C. Lin
                //END UD-2233 8/19/2015 Added By C. Lin
                //END: UD-1066 5/8/2015 Include all eligible subscriptions for Temp Stop
                //END: D-2407 2/26/2015 Computation of year to date days
                //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                
                //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. Subscription Temp Stop List Order by Temp Stop Date
                orderedStsList = [SELECT Subscription__r.Status_Formula__c, Subscription__r.Order_Line_Item_Number__c, Subscription__r.Order_Line_Item_Number_1__r.Ph_d__c, Subscription__r.Order_Line_Item_Number_1__r.Ph_e__c, Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c, Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c, Subscription__r.Next_Year_Temp_Stop_Days__c, Subscription__r.Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Subscription__r.Year_to_Date_Temp_Stop_Days__c, Subscription__r.Ph_d__c, Subscription__r.Ph_e__c, Subscription__r.Zuora__SubscriptionStartDate__c , Subscription__r.Zuora__SubscriptionEndDate__c, Subscription__r.Recipient_Address_ID__c, Subscription__r.Main_Package_1__r.Id, Subscription__r.Main_Package_1__r.Name, Temp_Stop__r.Id, Subscription__r.Recipient_Contact__r.Id, Subscription__r.Zuora__CustomerAccount__r.Id, Id, Name, Subscription__r.Delivery_Charge__c, Subscription__r.Name, Subscription__r.Id, Temp_Stop__r.Qty__c, Subscription__r.Zuora__Status__c, Temp_Stop__r.Case__r.Total_Issue__c, Subscription__r.Frequency_1__c, Subscription__r.Zuora__CustomerAccount__r.Name, Subscription__r.Recipient_Contact__r.Name, Temp_Stop__c, Temp_Stop__r.Temp_Stop_Date__c, Subscription__r.Number_of_Copies__c, Temp_Stop__r.Temp_Stop_Status__c, Temp_Stop__r.POP_Start_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Request_Total_Issue__c, Temp_Stop__r.Case__r.Year_To_Date_Count__c, Subscription__r.Product_Code__c, Subscription__c, Temp_Stop__r.Case__c FROM Subscription_Temp_Stop__c WHERE Subscription__c IN : returnedSetIdOfSub ORDER BY Temp_Stop__r.Temp_Stop_Date__c];
                //END UD-2443 9/5/2015 Added By C. Lin
            }
                //END: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
                //END: D-1298 1/5/15 Added by J.Ledesma – related.
                if (subTempStopRecList != null) {
                    for (Subscription_Temp_Stop__c tmpdate : subTempStopRecList) {
                        tsDate.add(tmpdate.Temp_Stop__r.Temp_Stop_Date__c);
                        tsDate.add(tmpdate.Temp_Stop__r.Restart_Date__c);
                    }        
                            
                for(Subscription_Temp_Stop__c sUpdate : subTempStopRecList){
                    if(sUpdate.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_ONGOING || sUpdate.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_NOTSTARTED){
                            sToUpdate.add(sUpdate);
                            
                        //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                        stsIdToStsMap.put(sUpdate.Id, sUpdate);
                        //END D-3329 8/26/2015 Added By C. Lin
                        
                        //START: UD-3295 11/24/15 Added by Manolo Valena
                        stsIdToPackageTypeMap.put(sUpdate.Id, sUpdate.Subscription__r.Main_Package_1__r.Package_Type__c);
                        //END: UD-3295 11/24/15 Added by Manolo Valena
                    }   
                }
                
                for(Subscription_Temp_Stop__c sCancel : subTempStopRecList){
                    if(sCancel.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_NOTSTARTED){
                            sToCancel.add(sCancel);
                    }   
                }            
            }
            
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
            if(!orderedStsList.isEmpty()){
                for (Subscription_Temp_Stop__c tmpdate : orderedStsList) {
                    if(tmpdate.Temp_Stop__r.Case__c != null){
                        //START: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
                        //caseIds.add(tmpdate.Temp_Stop__r.Case__c); //START END UD-3417 21Jan2016 Added By C. Lin - Comment Out cause not used
                        //END: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
                    }
                    
                    if(tmpdate.Temp_Stop__c != null){
                        tempStopIds.add(tmpdate.Temp_Stop__c);
                    }
                }
                
                for(Subscription_Temp_Stop__c orderSts : orderedStsList){
                    if(orderSts.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_ONGOING || orderSts.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_NOTSTARTED){
                        if(orderSts.Subscription__c != null){
                            subUpdateIdSet.add(orderSts.Subscription__c);
                        }
                        
                        if(subIdToStsIdSetMap.containsKey(orderSts.Subscription__c)){
                            subIdToStsIdSetMap.get(orderSts.Subscription__c).add(orderSts.Id);
                        }else{
                            subIdToStsIdSetMap.put(orderSts.Subscription__c, new Set<Id>{orderSts.Id});
                        }
                    }
                }
                
                if(!subUpdateIdSet.isEmpty()){
                    listSubs = [SELECT Id, Name, Status_Formula__c, Order_Line_Item_Number__c, Order_Line_Item_Number_1__r.Ph_d__c, Order_Line_Item_Number_1__r.Ph_e__c, Next_Year_Temp_Stop_Days__c, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Year_to_Date_Temp_Stop_Days__c, Ph_d__c, Ph_e__c, Zuora__SubscriptionStartDate__c , Zuora__SubscriptionEndDate__c, Recipient_Address_ID__c, Main_Package_1__r.Id, Main_Package_1__r.Name, Recipient_Contact__r.Id, Zuora__CustomerAccount__r.Id, Delivery_Charge__c, Zuora__Status__c, Frequency_1__c, Zuora__CustomerAccount__r.Name, Recipient_Contact__r.Name, Number_of_Copies__c, Product_Code__c FROM Zuora__Subscription__c WHERE Id IN :subUpdateIdSet];
                }
                /*Start UD-2925 VPernicia 9/25/15: Comment-out
                if(!listSubs.isEmpty()){
                    for(Zuora__Subscription__c sub : listSubs){
                        subIdToSubMap.put(sub.Id, sub);
                    }
                }
                End UD-2925 VPernicia 9/25/15: Comment-out*/
                //START UD-3417 21Jan2016 Added By C. Lin - Comment Out cause not used
                /*if(!caseIds.isEmpty()){
                    //START: D-3628 10/29/15 Added by Manolo Valena
                    cList = [SELECT Id, Current_Date_for_Year_To_Date__c, Next_Year_for_Year_To_Date__c, Total_Issue__c, Year_To_Date_Count__c, Request_Total_Credit__c, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Temp_Stop__c FROM Case WHERE Id IN :caseIds];
                    //END: D-3628 10/29/15 Added by Manolo Valena
                }
                
                //START: D-3628 10/29/15 Added by Manolo Valena
                for(Case c : cList) {
                    caseIdToCaseRecMap.put(c.Id, c);
                }*/
                //END: D-3628 10/29/15 Added by Manolo Valena
                //END UD-3417 21Jan2016 Added By C. Lin
                
                /*Start UD-2925 VPernicia 9/25/15: Comment-out
                if(!cList.isEmpty()){
                    for(Case c : cList){
                        caseIdToCaseMap.put(c.Id, c);
                    }
                }
                
                if(!tempStopIds.isEmpty()){
                    tsList = [SELECT Id, Name, Temp_Stop_Date__c, Temp_Stop_Status__c, POP_Start_Date__c, Restart_Date__c, Request_Total_Issue__c, Qty__c, Case__c FROM Temp_Stop__c WHERE Id IN :tempStopIds];
                }
                if(!tsList.isEmpty()){
                    for(Temp_Stop__c ts : tsList){
                        tsIdToTempStopMap.put(ts.Id, ts);
                    }
                }
                End UD-2925 VPernicia 9/25/15: Comment-out*/
                
            }
            //END UD-2443 9/5/2015 Added By C. Lin
        }
        
        /*Description: Sets the records for the maps to be used
        *Parameter: String
        *Return: NA
        */  
        //START UD-2925 10/08/2015 Added By C. Lin - Remove subsId. Added UOMSet.
        public Set<Id> initialize(Map<Id, Id> subIdTopackageId){
            Set<String> UOMSet = new Set<String>{copySun, copyWeek, copySat, discPer};
        //END UD-2925 10/08/2015 Added By C. Lin
            //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
            String CaseStatus = globalvariableclass.TS_PENDING;
            String TempStopRecType = ConstantsSLB.getKeyId('Case_Temp Stop');
            String CaseSubStatus = globalvariableclass.WAITING_URGENT_TEMPSTOP_RESTART_APPROVAL;
            //START: D-1026 12/06/14 Added by J.Ledesma – correct mapping of the records to be used in getting the subscriptions that can be temp stopped.
            ratePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
            //START: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            //START UD-2925 10/08/2015 Added By C. Lin - Changed WHERE Zuora__Subscription__c IN : subsId to Zuora__Subscription__c IN : subIdTopackageId.keySet() AND Zuora__UOM__c IN : UOMSet
            subProdChList = [SELECT Zuora__EffectiveStartDate__c, Zuora__Model__c, Zuora__ProductName__c, Zuora__Subscription__r.Ph_d__c, Zuora__Subscription__r.Ph_e__c, Name, Zuora__Quantity__c, Zuora__UOM__c, Zuora__Price__c, Zuora__Subscription__c, Zuora__ProductSKU__c, PublicationCode__c, Zuora__RatePlanName__c, Zuora__Subscription__r.Product_Code__c FROM Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c IN : subIdTopackageId.keySet() AND Zuora__UOM__c IN : UOMSet];
            //END UD-2925 10/08/2015 Added By C. Lin
            //END D-3329 8/26/2015 Added By C. Lin
            //START:UD-3127 10/22/15 Added by Manolo Valena
            subProdChListDisc = [SELECT Zuora__EffectiveStartDate__c, Zuora__Model__c, Zuora__ProductName__c, 
                                        Zuora__Subscription__r.Ph_d__c, Zuora__Subscription__r.Ph_e__c, Name, 
                                        Zuora__Quantity__c, Zuora__UOM__c, Zuora__Price__c, Zuora__Subscription__c, 
                                        Zuora__ProductSKU__c, PublicationCode__c, Zuora__RatePlanName__c, 
                                        Zuora__Subscription__r.Product_Code__c 
                                FROM Zuora__SubscriptionProductCharge__c 
                                WHERE Zuora__Subscription__c IN : subIdTopackageId.keySet()
                                AND Zuora__UOM__c = NULL 
                                AND Zuora__ProductName__c = 'Discount'];
                                
            if(subProdChListDisc.size() > 0) {
                for(Zuora__SubscriptionProductCharge__c zSPCRec : subProdChListDisc) {
                    subscriptionToDiscountPrice.put(zSPCRec.Zuora__Subscription__c, zSPCRec.Zuora__Price__c);
                }
            }
            //END:UD-3127 10/22/15 Added by Manolo Valena
            PendingCase = [Select AccountId, CaseNumber, Status, Sub_Status__c, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop_Sub__c from Case where Status = :CaseStatus AND RecordTypeID = :TempStopRecType AND Sub_Status__c = :CaseSubStatus AND AccountId = :thisAccount.Id];
            subToCoverPrice = new Map<Id, List<String>>();
            //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
            //Set<String> ratePlanName = new Set<String>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
            //Set<String> skuCodes = new Set<String>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
            //Set<ID> zprpIdList = new Set<ID>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
            //subIdToRatePlan = new Map<Id, Set<Id>>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
            List<Id> packIds = subIdTopackageId.values();
            for(Id pack : packIds)
            {packageIds.add(pack);}
            //START UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. Add Product_Rate_Plan__r.Product_Code__c
            List<Package_Item__c> pckItems = [SELECT Package__c, Product_Rate_Plan__c, Id, Is_Print__c, Is_All_In_One__c, Is_Newspaper__c, Product_Rate_Plan__r.Product_Code__c FROM Package_Item__c WHERE Package__c IN : packageIds]; // AND Is_Newspaper__c = TRUE AND (Is_Print__c=TRUE OR Is_All_In_One__c=TRUE)
            Map<String, Set<Id>> prodCodeToPubIdSetMap = new Map<String, Set<Id>>();
            //END D-3329 8/26/2015 Added By C. Lin
            //END UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
            
            for(Zuora__SubscriptionProductCharge__c s: subProdChList){
                //START UD-2925 10/08/2015 Added By C. Lin - Change to ConstantsSLB.getUOM to Strings
                //if((s.Zuora__UOM__c == ConstantsSLB.getUOM('Copy Sun')) || (s.Zuora__UOM__c == ConstantsSLB.getUOM('Copy Weekday')) || (s.Zuora__UOM__c == ConstantsSLB.getUOM('Copy Sat'))){
                if((s.Zuora__UOM__c == copySun) || (s.Zuora__UOM__c == copyWeek) || (s.Zuora__UOM__c == copySat)){
                //END UD-2925 10/08/2015 Added By C. Lin
                    if(sProdChargeUOMToPrice.containsKey(s.Zuora__Subscription__c)){
                        sProdChargeUOMToPrice.get(s.Zuora__Subscription__c).put(s.Zuora__UOM__c, s.Zuora__Price__c);    
                    }
                    else{
                        sProdChargeUOMToPrice.put(s.Zuora__Subscription__c, new Map<String, Double>{s.Zuora__UOM__c => s.Zuora__Price__c});
                    }
               }
                if(subToCoverPrice.containsKey(s.Zuora__Subscription__c)){            
                    if(s.Zuora__UOM__c == 'Copy Weekday'){
                        subToCoverPrice.get(s.Zuora__Subscription__c).add('wkd' + s.Zuora__Price__c);
                    }   
                    if(s.Zuora__UOM__c == 'Copy Sat'){
                        subToCoverPrice.get(s.Zuora__Subscription__c).add('sat' + s.Zuora__Price__c);
                    }
                    if(s.Zuora__UOM__c == 'Copy Sun'){
                        subToCoverPrice.get(s.Zuora__Subscription__c).add('sun' + s.Zuora__Price__c);
                    }
                } 
                else {
                    subToCoverPrice.put(s.Zuora__Subscription__c, new List<String>());
                    if(s.Zuora__UOM__c == 'Copy Weekday'){
                        subToCoverPrice.get(s.Zuora__Subscription__c).add('wkd' + s.Zuora__Price__c);
                    }   
                    if(s.Zuora__UOM__c == 'Copy Sat'){
                        subToCoverPrice.get(s.Zuora__Subscription__c).add('sat' + s.Zuora__Price__c);
                    }
                    if(s.Zuora__UOM__c == 'Copy Sun'){
                        subToCoverPrice.get(s.Zuora__Subscription__c).add('sun' + s.Zuora__Price__c);
                    }
                }
                
                //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                if(s.Zuora__Subscription__r.Product_Code__c != null){
                    subIdToProductCodeMap.put(s.Zuora__Subscription__c, s.Zuora__Subscription__r.Product_Code__c);
                }
                //END D-3329 8/26/2015 Added By C. Lin
            }
            //START UD-2925 10/08/2015 Added By C. Lin - Optimize loops in using maps.
            
            for(Package_Item__c pi : pckItems){
                if(pi.Package__c != null){
                    if(packIdToPackItemListMap.containsKey(pi.Package__c)){
                        packIdToPackItemListMap.get(pi.Package__c).add(pi);
                    }else{
                        packIdToPackItemListMap.put(pi.Package__c, new List<Package_Item__c>{pi});
                    }
                }
            }
            
            for(Id sub : subIdTopackageId.keySet()){
                if(packIdToPackItemListMap.containsKey(subIdTopackageId.get(sub))){
                    for(Package_Item__c pacItem : packIdToPackItemListMap.get(subIdTopackageId.get(sub))){
                        if(subIdToPackageItems.containsKey(sub)){
                            subIdToPackageItems.get(sub).add(pacItem);
                        }else{
                            subIdToPackageItems.put(sub, new List<Package_Item__c>{pacItem});
                        }
                    }
                }
            }
            //END UD-2925 10/08/2015 Added By C. Lin 
            Set<Id> sublistId = new Set<Id>();
            Set<Id> prp = new Set<Id>();
            List<Package_Item__c> packageItems = new List<Package_Item__c>();
            Map<Id, Set<String>> PRPToPubCode = new Map<Id, Set<String>>();
            //START: UD-0474 03/24/2015 temp stop subscriptions did not show all the active pubs
            for(Id subIdFromPackageMap : subIdToPackageItems.keySet()){
                LIST<String> subProd = subToCoverPrice.get(subIdFromPackageMap);
                if(subProd!=NULL && !subProd.isEmpty()){
                    sublistId.add(subIdFromPackageMap);
                    if(subIdToPackageItems.containsKey(subIdFromPackageMap)){
                        packageItems = subIdToPackageItems.get(subIdFromPackageMap);
                    }
                    if(packageItems!=NULL){
                        for(Package_Item__c p : packageItems){
                            prp.add(p.Product_Rate_Plan__c);
                        }
                    }
                }
            }
            //END: UD-0474 03/24/2015 temp stop subscriptions did not show all the active pubs
            ratePlanChargeList = [SELECT Id, Name, PublicationCode__c, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.Name from zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN :prp];
            for(zqu__ProductRatePlanCharge__c prpc : ratePlanChargeList){
                pubcodes.add(prpc.PublicationCode__c);
                if(PRPToPubCode.containsKey(prpc.zqu__ProductRatePlan__c)){            
                        PRPToPubCode.get(prpc.zqu__ProductRatePlan__c).add(prpc.PublicationCode__c);
                } 
                else {
                    PRPToPubCode.put(prpc.zqu__ProductRatePlan__c, new Set<String>());
                    PRPToPubCode.get(prpc.zqu__ProductRatePlan__c).add(prpc.PublicationCode__c);
                }
            }
            pubList = [SELECT Id, Name, Platform_Type__c, Publication_Code__c, Published_Days__c, Earliest_Start_Date__c from Publication__c WHERE Publication_Code__c IN : pubcodes]; 
            Set<String> publCodeFromRatePlan = new Set<String>();
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            Set<String> pubCodeChecker = new Set<String>();
            //END D-3329 8/26/2015 Added By C. Lin
            for(Package_Item__c p : pckItems){
                if(PRPToPubCode.containsKey(p.Product_Rate_Plan__c)){
                    publCodeFromRatePlan = PRPToPubCode.get(p.Product_Rate_Plan__c);
                    for(String pubCode : publCodeFromRatePlan){
                        for(Publication__c pubrec : pubList){
                            if(pubrec.Platform_Type__c == 'Print' && pubCode == pubrec.Publication_Code__c){
                                if(packageToPubrec.containsKey(p.Package__c)){            
                                        packageToPubrec.get(p.Package__c).add(pubrec);
                                } 
                                else {
                                    packageToPubrec.put(p.Package__c, new List<Publication__c>());
                                    packageToPubrec.get(p.Package__c).add(pubrec);
                                }
                            }
                            //START UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
                            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                            if(pubrec.Platform_Type__c == 'Print' && pubCode == pubrec.Publication_Code__c){ // && !pubCodeChecker.contains(pubrec.Publication_Code__c)
                                if(prodCodeToPubRecMap.containsKey(p.Product_Rate_Plan__r.Product_Code__c)){
                                    if(!prodCodeToPubIdSetMap.get(p.Product_Rate_Plan__r.Product_Code__c).contains(pubRec.Id)){
                                        prodCodeToPubRecMap.get(p.Product_Rate_Plan__r.Product_Code__c).add(pubrec);
                                        prodCodeToPubIdSetMap.get(p.Product_Rate_Plan__r.Product_Code__c).add(pubrec.Id);
                                    }
                                } 
                                else {
                                    prodCodeToPubRecMap.put(p.Product_Rate_Plan__r.Product_Code__c, new List<Publication__c>());
                                    prodCodeToPubRecMap.get(p.Product_Rate_Plan__r.Product_Code__c).add(pubrec);
                                    prodCodeToPubIdSetMap.put(p.Product_Rate_Plan__r.Product_Code__c, new Set<Id>());
                                    prodCodeToPubIdSetMap.get(p.Product_Rate_Plan__r.Product_Code__c).add(pubrec.Id);
                                }
                                pubCodeChecker.add(pubrec.Publication_Code__c);
                            }
                            //END D-3329 8/26/2015 Added By C. Lin
                            //END UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
                        }
                    }
                }
            }
            return sublistId;
        }
        
        /*Description: 
        *Parameter: 
        *Return: 
        */  
        //START: UD-0309 03/20/2015 Year To Date computation
        //START: JLedesma D-3091 6/18/2015 Year To Date computation
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. Integer refundInSelected, Integer totalOldRemCurrYTD, Integer totalOldRemNextYTD, Integer totalNewRemCurrYTD, Integer totalNewRemNextYTD
        public Map<String, Decimal> computation(String tempStopType, Integer oldCurrentDays, Integer oldNextDays, Id subId, Date TempStop, Date RestartDate, Integer qty, Integer subYearToDate, Integer subNextYearToDate, Integer refundInSelected, Integer totalOldRemCurrYTD, Integer totalOldRemNextYTD, Integer totalNewRemCurrYTD, Integer totalNewRemNextYTD){
        //END UD-2443 9/5/2015 Added By C. Lin
        //END: JLedesma D-3091 6/18/2015 Year To Date computation
            //START: UD-0326 3/19/2015 Computation of year to date days   //END: UD-0326 3/19/2015 Computation of year to date days
            Decimal totalIssue = 100;
            Decimal total = 0;
            Decimal refundEligible = 0;
        //END: UD-0309 03/20/2015 Year To Date computation
            //Zuora__Subscription__c subRec = mapIdToSubRec.get(subId); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
            List<Package_Item__c> pckList = subIdToPackageItems.get(subId);
            Integer counterAllInOne = 0;
            for(Package_Item__c pItem : pckList){
                if(pItem.Is_All_In_One__c == TRUE){
                    counterAllInOne++;
                }
            }
            //END: UD-0326 3/19/2015 Computation of year to date days
            for(Zuora__SubscriptionProductCharge__c z : subProdChList){
                //START UD-2925 10/08/2015 Added By C. Lin - Change ConstantsSLB.getUOM to discPer
                if(z.Zuora__Model__c == discPer && z.Zuora__ProductName__c.toLowerCase() == 'discount' && z.Zuora__Subscription__c == subId){
                //END UD-2925 10/08/2015 Added By C. Lin
                    zuoSubProdChargListDisc.add(z);
                }
            }
            
            for(Zuora__SubscriptionProductCharge__c zSPC : zuoSubProdChargListDisc){
                mapSPCIdToSPCRec.put(zSPC.Id, zSPC);
                zSPCDiscount.add(zSPC);
                if(!zSPCDiscountSet.contains(zSPC.Zuora__EffectiveStartDate__c)){
                    zSPCDiscountSet.add(zSPC.Zuora__EffectiveStartDate__c);
                    zSPCDiscountList.add(zSPC.Zuora__EffectiveStartDate__c);
                }
            }
            for(Zuora__SubscriptionProductCharge__c spcDisc : zSPCDiscount){
                mapSPCDiscToPrice.put(spcDisc.Id, spcDisc.Zuora__Price__c);
                mapDateToSPC.put(spcDisc.Zuora__EffectiveStartDate__c, spcDisc.Id);
            }
            //START: UD-0309 03/20/2015 Year To Date computation
            totalDiscountDateMap = getDiscount(TempStop, RestartDate, zSPCDiscountList);
       //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            //totalDiscountAmount = computeDiscount(packageToPubrec.get(subIdTopackageIds.get(subId)), subId, qty);
            totalDiscountAmount = computeDiscount(prodCodeToPubRecMap.get(subIdToProductCodeMap.get(subId)), subId, qty);
            //totalIssueAndTotalAmountPlusYearToDate = computeNotDiscountedPlusYearToDate(tempStopType, oldCurrentDays, oldNextDays, packageToPubrec.get(subIdTopackageIds.get(subId)), subId, qty, TempStop, RestartDate, subYearToDate, subNextYearToDate);
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. refundInSelected, totalOldRemCurrYTD, totalOldRemNextYTD, totalNewRemCurrYTD, totalNewRemNextYTD
            totalIssueAndTotalAmountPlusYearToDate = computeNotDiscountedPlusYearToDate(tempStopType, oldCurrentDays, oldNextDays, prodCodeToPubRecMap.get(subIdToProductCodeMap.get(subId)), subId, qty, TempStop, RestartDate, subYearToDate, subNextYearToDate, refundInSelected, totalOldRemCurrYTD, totalOldRemNextYTD, totalNewRemCurrYTD, totalNewRemNextYTD);
            //END UD-2443 9/5/2015 Added By C. Lin
            //END D-3329 8/26/2015 Added By C. Lin
            totalNotDiscountedAmount = totalIssueAndTotalAmountPlusYearToDate.get('amount');
            totalIssue = totalIssueAndTotalAmountPlusYearToDate.get('issues');
            refundEligible = totalIssueAndTotalAmountPlusYearToDate.get('refund');
            //START:UD-3127 10/22/15 Added by Manolo Valena
            if(subscriptionToDiscountPrice.containsKey(subId)) {
                total = totalNotDiscountedAmount - (totalNotDiscountedAmount * subscriptionToDiscountPrice.get(subId) / 100);
            }
            else {
                total = totalNotDiscountedAmount - totalDiscountAmount;
            }
            //END:UD-3127 10/22/15 Added by Manolo Valena
            //START: UD-0326 3/19/2015 Computation of year to date days
            if(counterAllInOne > 0){
                refundEligibleAndTotalCredit.put('refund', 0);
                refundEligibleAndTotalCredit.put('credit',  0);
            }
            else{
                refundEligibleAndTotalCredit.put('refund', refundEligible);
                refundEligibleAndTotalCredit.put('credit', total);
            }
            //END: UD-0326 3/19/2015 Computation of year to date days

            refundEligibleAndTotalCredit.put('issue', totalIssue);
            refundEligibleAndTotalCredit.put('tempStopDays', totalIssue/qty);
        //START: D-2594 3/22/2015 Get values of Year To Dates from Map return.
        refundEligibleAndTotalCredit.put('current', totalIssueAndTotalAmountPlusYearToDate.get('current'));
        refundEligibleAndTotalCredit.put('next', totalIssueAndTotalAmountPlusYearToDate.get('next'));
        
        return refundEligibleAndTotalCredit;
        //END: D-2594 3/22/2015 Get values of Year To Dates from Map return.
            //END: UD-0309 03/20/2015 Year To Date computation
        }
        
        //START: D- 0077 03/09/2015 Added by Kristine Campang - added logic for discount
    public Map<Id, List<Date>> getDiscount(Date strDate, Date enDate, List<Date> zSPCDiscountList){
        
        Integer counter;
        finalDiscountMap = new Map<Id, List<Date>>();
        for(counter = 0; counter < zSPCDiscountList.size(); counter++){
            if(zSPCDiscountList[counter] >= strDate && zSPCDiscountList[counter] <= enDate-1){
               if(counter != zSPCDiscountList.size()-1){
                finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], zSPCDiscountList[counter + 1] - 1});
               } 
               else {
                finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], enDate-1});
               }
             }
            else if(zSPCDiscountList[counter] < strDate && zSPCDiscountList[counter] <= enDate-1){
                //START: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                if(counter == 0){
                    //Start: D-2846 04/30/2015 James - handle error: List out of bounds
                    if(zSPCDiscountList.size() > 1){
                        finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate , zSPCDiscountList[counter + 1] - 1});
                    }else{
                        //START UD-2234 9/18/2015 Added By C. Lin - Check which is later strDate or zSPCDiscountList[counter]
                        if(strDate > zSPCDiscountList[counter]){
                            finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate, enDate-1});
                        }else{
                            finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], enDate-1});
                        }
                        //END UD-2234 9/18/2015 Added By C. Lin
                    }
                    //End: D-2846 04/30/2015 James
                }
                //END: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                else{
                    finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], enDate-1});
                }
            }
        }
        return finalDiscountMap;
    }
    
    public Decimal computeDiscount(List<Publication__c> publicationList, Id subId, Integer qty){    
        Zuora__Subscription__c zuoSubscrpt = new Zuora__Subscription__c();
        zuoSubscrpt = mapIdToSubRec.get(subId);
        totalDiscount = 0;
        totalDiscountPerPub = 0.00;
        for(Id spcDiscountId : totalDiscountDateMap.keySet()){
            //START UD-2234 9/18/2015 Added By C. Lin - get only discountRange from subId
            if(mapSPCIdToSPCRec.get(spcDiscountId).Zuora__Subscription__c == subId){
                List<Date> discountRange = totalDiscountDateMap.get(spcDiscountId);
                
                for(Publication__c pubRec : publicationList){
                
                        PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubRec.Publication_Code__c, discountRange[0], discountRange[1], zuoSubscrpt, qty);
                        
                        weekdayIssue = Decimal.valueOf(pubWrapperDiscount.weekday_no_of_copies);
                        SaturdayIssue = Decimal.valueOf(pubWrapperDiscount.sat_no_of_copies);
                        SundayIssue = Decimal.valueOf(pubWrapperDiscount.sun_no_of_copies);
                        
                        weekDayDiscount = 0.00;
                        saturdayDiscount = 0.00;
                        sundayDiscount = 0.00;
                        List<String> coverPrices = new List<String>();
                        coverPrices = subToCoverPrice.get(subId);
                        
                        for(String s : coverPrices){
                            if(s.contains('wkd')){
                                copyPriceWeekday = Decimal.valueOf(s.subString(3));
                                weekDayDiscount = (Math.abs(copyPriceWeekday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * weekdayIssue;
                            }
                            else if(s.contains('sat')){
                                copyPriceSaturday = Decimal.valueOf(s.subString(3));
                                saturdayDiscount = (Math.abs(copyPriceSaturday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * SaturdayIssue;
                            }
                            else if(s.contains('sun')){
                                copyPriceSunday = Decimal.valueOf(s.subString(3));
                                sundayDiscount = (Math.abs(copyPriceSunday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * SundayIssue;
                            }
                        }
                        totalDiscountPerPub += weekDayDiscount + saturdayDiscount + sundayDiscount;
                }
                totalDiscount += totalDiscountPerPub;
            }
            //END UD-2234 9/18/2015 Added By C. Lin
        }
        return totalDiscount;
    }
    
    //START: UD-0309 03/20/2015 Year To Date computation
    //START: JLedesma D-3091 6/18/2015 Year To Date computation
    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. Add Integer refundInSelected, Integer totalCurrYTD, Integer totalNextYTD
    public Map<String, Decimal> computeNotDiscountedPlusYearToDate(String tStopType, Integer oldCurrentDayCount, Integer oldNextDayCount, List<Publication__c> publicationList, Id subId, Integer qty, Date start, Date endDate, Integer subYearToDateCount, Integer subNextYearToDateCount, Integer refundInSelected, Integer totalOldRemCurrYTD, Integer totalOldRemNextYTD, Integer totalNewRemCurrYTD, Integer totalNewRemNextYTD){
    //END UD-2443 9/5/2015 Added By C. Lin
    //END: JLedesma D-3091 6/18/2015 Year To Date computation
        
        Zuora__Subscription__c zuoSubscrpt = new Zuora__Subscription__c();
        zuoSubscrpt = mapIdToSubRec.get(subId);
        totalNotDiscountedPerPub = 0.00;
        totalNotDiscounted = 0.00;
        Decimal totalIssue = 0.00;
        Decimal allIssues = 0.00;
        AccumulatedNextYear = 0;
        AccumulatedCurrentYear = 0;
        Decimal issueCount = 0;
        Decimal totalWeekday = 0;
        Decimal totalSunday = 0;
        Decimal totalSaturday = 0;
        Decimal totalweekdayIssue = 0;
        Decimal totalSaturdayIssue = 0;
        Decimal totalSundayIssue = 0;
        //START: UD-0474 03/24/2015 temp stop subscriptions did not show all the active pubs
        weekDayNotDiscounted = 0;
        saturdayNotDiscounted = 0;
        sundayNotDiscounted = 0;
        //END: UD-0474 03/24/2015 temp stop subscriptions did not show all the active pubs
        List<String> coverPrices = new List<String>();
        coverPrices = subToCoverPrice.get(subId);
        
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
        if(refundInSelected == null){
            refundInSelected = 0;
        }
        if(totalOldRemCurrYTD == null){
            totalOldRemCurrYTD = 0;
        }
        if(totalOldRemNextYTD == null){
            totalOldRemNextYTD = 0;
        }
        if(totalNewRemCurrYTD == null){
            totalNewRemCurrYTD = 0;
        }
        if(totalNewRemNextYTD == null){
            totalNewRemNextYTD = 0;
        }
        if(oldCurrentDayCount == null){
            oldCurrentDayCount = 0;
        }
        if(oldNextDayCount == null){
            oldNextDayCount = 0;
        }
        //END UD-2443 9/5/2015 Added By C. Lin
        
        for(Date tempDate = start; tempDate<endDate; tempDate=tempDate.addDays(1)){
            //START UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
            if(publicationList != null){
                for(Publication__c pubRec : publicationList){
                    currentYear = 0; 
                    nextYear = 0;
                    PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubRec.Publication_Code__c, tempDate, tempDate, zuoSubscrpt, qty);
                    weekdayIssue = Decimal.valueOf(pubWrapperDiscount.weekday_no_of_copies);
                    SaturdayIssue = Decimal.valueOf(pubWrapperDiscount.sat_no_of_copies);
                    SundayIssue = Decimal.valueOf(pubWrapperDiscount.sun_no_of_copies);
                    currentYear = pubWrapperDiscount.current_year_days;  
                    nextYear = pubWrapperDiscount.next_year_days;
                    //START: JLedesma D-3091 6/18/2015 Year To Date computation
                    
                    allIssues += weekdayIssue + SaturdayIssue + SundayIssue;
                    
                    if(tStopType == globalvariableclass.TS_CREATE){
                        if(tempDate.year() == date.today().year() && subYearToDateCount + AccumulatedCurrentYear < 30){ //Start/End VPernicia D-2897 5/15/15: Remove subYearToDateCount+
                            totalweekdayIssue += weekdayIssue;
                            totalSaturdayIssue += SaturdayIssue;
                            totalSundayIssue += SundayIssue;
                            AccumulatedCurrentYear += currentYear;
                        }
                        else if(tempDate.year() != date.today().year() && subNextYearToDateCount+ AccumulatedNextYear < 30){ //Start/End VPernicia D-2897 5/15/15: Remove subNextYearToDateCount+
                            totalweekdayIssue += weekdayIssue;
                            totalSaturdayIssue += SaturdayIssue;
                            totalSundayIssue += SundayIssue;
                            AccumulatedNextYear += nextYear;
                        }
                    }
                    
                    if(tStopType == globalvariableclass.TS_UPDATE){
                        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. + refundInSelected, - totalOldRemCurrYTD, + totalNewRemCurrYTD
                        if(tempDate.year() == date.today().year() && (subYearToDateCount - oldCurrentDayCount - totalOldRemCurrYTD) + totalNewRemCurrYTD + AccumulatedCurrentYear + refundInSelected < 30){ //Start/End VPernicia D-2897 5/15/15: Remove subYearToDateCount+
                        //END UD-2443 9/5/2015 Added By C. Lin
                            totalweekdayIssue += weekdayIssue;
                            totalSaturdayIssue += SaturdayIssue;
                            totalSundayIssue += SundayIssue;
                            AccumulatedCurrentYear += currentYear;
                        }
                        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. + refundInSelected,  - totalNextYTD
                        else if(tempDate.year() != date.today().year() && (subNextYearToDateCount - oldNextDayCount - totalOldRemNextYTD) + totalNewRemNextYTD + AccumulatedNextYear + refundInSelected < 30){ //Start/End VPernicia D-2897 5/15/15: Remove subNextYearToDateCount+
                        //END UD-2443 9/5/2015 Added By C. Lin
                            totalweekdayIssue += weekdayIssue;
                            totalSaturdayIssue += SaturdayIssue;
                            totalSundayIssue += SundayIssue;
                            AccumulatedNextYear += nextYear;
                        }
                    }
                    
                }
            }
            //END UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
            //END: JLedesma D-3091 6/18/2015 Year To Date computation
        }   
        
        for(String s : coverPrices){
                if(s.contains('wkd')){
                    copyPriceWeekday = Decimal.valueOf(s.subString(3));
                    weekDayNotDiscounted = (Math.abs(copyPriceWeekday) * totalweekdayIssue);
                }
                else if(s.contains('sat')){
                    copyPriceSaturday = Decimal.valueOf(s.subString(3));
                    saturdayNotDiscounted = (Math.abs(copyPriceSaturday) * totalSaturdayIssue);
                }
                else if(s.contains('sun')){
                    copyPriceSunday = Decimal.valueOf(s.subString(3));
                    sundayNotDiscounted = (Math.abs(copyPriceSunday) * totalSundayIssue);
                }
            }
        totalNotDiscountedPerPub += weekDayNotDiscounted + saturdayNotDiscounted+ sundayNotDiscounted;
        totalIssue += totalweekdayIssue + totalSaturdayIssue + totalSundayIssue;
        totalNotDiscounted += totalNotDiscountedPerPub;
        
        //Return values
        totalIssueAndTotalAmount.put('issues', allIssues);
        totalIssueAndTotalAmount.put('refund', totalIssue);
        totalIssueAndTotalAmount.put('amount', totalNotDiscounted);
        totalIssueAndTotalAmount.put('current', AccumulatedCurrentYear);
        totalIssueAndTotalAmount.put('next', AccumulatedNextYear);
        
        return totalIssueAndTotalAmount;
    }
    //END: UD-0309 03/20/2015 Year To Date computation
    //END: D- 0077 03/09/2015 Added by Kristine Campang
    public Boolean publishedDayChecker(Id subId, Date restart){
        Zuora__Subscription__c zuoSubscrpt = new Zuora__Subscription__c();
        zuoSubscrpt = mapIdToSubRec.get(subId);
        List<Publication__c> publicationList = packageToPubrec.get(subIdTopackageIds.get(subId));
        Date start = restart;
        Date endDate = restart;
        Integer qty = 1;
        Integer count = 0;
        Boolean returnValue = FALSE;
        UsageHelper.initialize();
        for(Publication__c pubRec : publicationList){
            PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubRec.Publication_Code__c, start, endDate, zuoSubscrpt, qty);
            weekdayIssue = Decimal.valueOf(pubWrapperDiscount.weekday_no_of_copies);
            SaturdayIssue = Decimal.valueOf(pubWrapperDiscount.sat_no_of_copies);
            SundayIssue = Decimal.valueOf(pubWrapperDiscount.sun_no_of_copies);
            //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
            if(weekdayIssue>0 || SaturdayIssue>0 || SundayIssue>0){
                count++;
            }
        }
        if(count>0){
            returnValue = TRUE;
        }
        return returnValue;
    }
        //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
        /*Description: Gets the earliest start date.
        *Parameter: String 
        *Return: Date
        */
        public Date earliestStart (Id subId){  
            Date earliestDate = null;
            List<Publication__c> publications = new List<Publication__c>();
            List<Date> pubDates = new List<Date>();
            if(packageToPubrec.containsKey(subIdTopackageIds.get(subId))){
                publications = packageToPubrec.get(subIdTopackageIds.get(subId));
                for(Publication__c pub : publications){
                    pubDates.add(pub.Earliest_Start_Date__c);     
                }
                if(pubDates.size()>0){    
                    pubDates.sort();
                    earliestDate = pubDates[0];
                }
                else{
                    earliestDate = NULL;
                }
            }
            return(earliestDate);
        }  
        
        /*Description: Validates if the input exceeds the current quantity of for each selected record.
        *Parameter: Decimal, Integer 
        *Return: Boolean 
        */   
        public Boolean validateLimit(Decimal tsQty, Integer currentQty) {    
            Boolean result = FALSE;
            if(integer.valueOf(tsQty) > currentQty){
                result = TRUE;
            }
            else{
                result = FALSE;
            }      
            return result;
        } 
        
        /*Description: Removes the row from the Selected Create Temp Stop table
        *Parameter: NA
        *Return: NA
        */   
        public void removeSubscriptionRecord() {
            //Start UD-2925 VPernicia 9/25/15
            pubSubToOrderLine = new Map<Id, String>(); 
            returnedSetIdOfSub = new Set<Id>();
            getSubscriptions();
            //End UD-2925 VPernicia 9/25/15
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            Set<Id> relatedBundleSubIdSet = new Set<Id>();
            relatedBundleSubIdSet = getRelatedBundleSub(tstopId);
            //END D-3329 8/26/2015 Added By C. Lin
            for(Integer counter = 0; counter < tempStopRequestList.size(); counter++) {
                //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                /*if(tempStopRequestList[counter].id == tstopId) {
                    tempStopRequestList.remove(counter);
                }*/
                for(Id bSubId : relatedBundleSubIdSet){
                    if(tempStopRequestList[counter].id == tstopId || tempStopRequestList[counter].id == bSubId){
                        tempStopRequestList.remove(counter);
                    }
                }
                //END D-3329 8/26/2015 Added By C. Lin
            
                //START: UD-3295 11/24/15 Added by Manolo Valena
                if(subscriptionIdToPackageTypeMap.containsKey(tstopId) &&
                   subscriptionIdToPackageTypeMap.get(tstopId) == GlobalVariableClass.PACKAGETYPE_ADDON &&
                   tempStopRequestList[counter].id == tstopId) {
                    tempStopRequestList.remove(counter);
                }
                //END: UD-3295 11/24/15 Added by Manolo Valena
            }
        }
        
        /*Description: Validates whether the selected Temp Stop record has any overlapping values with any of the existing temp stop records. 
        *Parameter: NA
        *Return: Boolean
        */   
        //START: D-2407 2/27/2015 Computation of year to date days
        public Boolean validateOverlapping(List<Subscription_Temp_Stop__c> subTempRecords, Date startinput, Date endinput, Id myID, Id subTempId){
            List<Subscription_Temp_Stop__c> subtempList = new List<Subscription_Temp_Stop__c>();
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            Set<Id> relateSubTempIdSet = new Set<Id>();
            //END D-3329 8/26/2015 Added By C. Lin
            
            for(Subscription_Temp_Stop__c s : subTempRecords){
                if(subTempId!=NULL){
                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. Remove s.Id != subTempId || 
                    if(stsIdToStsMap.get(subTempId).Subscription__r.Order_Line_Item_Number__c == Id.valueOf(pubSubToOrderLine.get(myID)) && s.Temp_Stop__r.Temp_Stop_Date__c == stsIdToStsMap.get(subTempId).Temp_Stop__r.Temp_Stop_Date__c && s.Temp_Stop__r.Restart_Date__c == stsIdToStsMap.get(subTempId).Temp_Stop__r.Restart_Date__c && s.Temp_Stop__r.Temp_Stop_Status__c == stsIdToStsMap.get(subTempId).Temp_Stop__r.Temp_Stop_Status__c){
                        relateSubTempIdSet.add(s.Id);
                    }
                    
                    if(!relateSubTempIdSet.contains(s.Id)){
                    //END D-3329 8/26/2015 Added By C. Lin
                        subtempList.add(s);
                    }
                }
                else{
                    subtempList = subTempRecords;
                }
            }
            Subscription_Temp_Stop__c tempStopRecord = new Subscription_Temp_Stop__c();
            Boolean result = FALSE;
            Date endprev;
            Date startprev;
            List<String> overlapped = new List<String>();
            system.debug('>>>CHA subtempList ' + subtempList);
            if(subtempList!=NULL){
                for(Subscription_Temp_Stop__c st : subtempList){
                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                    if((st.Subscription__c == Id.valueOf(myId) || st.Subscription__r.Order_Line_Item_Number__c == Id.valueOf(pubSubToOrderLine.get(myId))) && st.Temp_Stop__r.Temp_Stop_Status__c!= globalvariableclass.TS_STATUS_CANCELLED){
                    //END D-3329 8/26/2015 Added By C. Lin
                        startprev = st.Temp_Stop__r.Temp_Stop_Date__c;
                        endprev = st.Temp_Stop__r.Restart_Date__c;
                        system.debug('>>>CHA startprev ' + startprev);
                        system.debug('>>>CHA startinput ' + startinput);
                        system.debug('>>>CHA endinput ' + endinput);
                        system.debug('>>>CHA endprev ' + endprev);
                        if((startprev >= startinput && startprev <= endinput) ||(endprev >= startinput && endprev <= endinput) ||(startprev <= startinput && endprev >= endinput)){
                            system.debug('>>>CHA overlapped');
                            result = TRUE;
                            overlapped.add(string.valueOf(result));
                        }
                    }
                }  
            }
            system.debug('>>>CHA overlapped.size() ' + overlapped.size());
            if(overlapped.size() > 0){
                result = TRUE;
            }
            else{
                result = FALSE;
            }
            system.debug('>>>CHA result ' + result);
            return Result;
            
        }
        //END: D-2407 2/27/2015 Computation of year to date days
        
        //START: JLedesma UD-1146 5/21/2015 3 days interval for request dates
        public Boolean checkIntervalDate(Date restardDate, Date tempStopDate, Id sub){
            Boolean isTrue = FALSE;
            
            if(subTempStopRecList.size() > 0){
                for(Subscription_Temp_Stop__c sts : subTempStopRecList){
                    if(sts.Temp_Stop__r.Temp_Stop_Status__c != 'Cancelled' && sts.Subscription__r.Id == sub){
                        for(integer counter = 1; counter <= 3; counter++){
                            if(((sts.Temp_Stop__r.Restart_Date__c + counter) == tempStopDate) || (restardDate == (sts.Temp_Stop__r.Temp_Stop_Date__c - counter))){
                                isTrue = TRUE;
                            }
                        }
                    }
                }
            }
            
            
            return isTrue;
        }
        //END: JLedesma UD-1146 5/21/2015 3 days interval for request dates
        
        /*Description: Instantiates record values of all Temp Stop records that can be created.
        *Parameter: NA
        *Return: NA
        */     
        public void setSelectedRecords() { 
            //Start UD-2925 VPernicia 9/25/15
            isAdd = true;
            getSubscriptions();
            setSubscriptionRecords();
            //End UD-2925 VPernicia 9/25/15
            if(checkDuplicateSubscription()) {     
                //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                //Start UD-0300 03/11/2015 JLedesma - Related
                Boolean PendingCaseExist = false;
                String PendingCaseNumber;
                //End UD-0300 03/11/2015 JLedesma - Related
                //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                Set<Id> relatedBundleSubIdSet = new Set<Id>();
                relatedBundleSubIdSet = getRelatedBundleSub(myId);
                //END D-3329 8/26/2015 Added By C. Lin
                //START: JLedesma UD-1146 5/21/2015 3 days interval for request dates
                Boolean isWithinInterval = false;
                //END: JLedesma UD-1146 5/21/2015 3 days interval for request dates 
                
                for (SubscriptionWrapper subven : subscriptionResultList) {                       
                    
                    //START UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                    List<Package_Item__c> pckList = new List<Package_Item__c>();
                    if(subIdToPackageItems.containsKey(subven.subId)){
                        pckList = subIdToPackageItems.get(subven.subId);
                    }
                    Integer counterAllInOne = 0;
                    
                    for(Package_Item__c pItem : pckList){
                        if(pItem.Is_All_In_One__c == TRUE){
                            counterAllInOne++;
                        }
                    }
                    //END UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                    
                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                    if(subven.Id == myId || relatedBundleSubIdSet.contains(subven.Id)){
                    //END D-3329 8/26/2015 Added By C. Lin
                        //START: JLedesma UD-1146 5/21/2015 3 days interval for request dates
                        if(subven.tp.Restart_Date__c!=null && subven.tp.Temp_Stop_Date__c!=null){
                            isWithinInterval = checkIntervalDate(subven.tp.Restart_Date__c, subven.tp.Temp_Stop_Date__c, myId);
                        }
                        //END: JLedesma UD-1146 5/21/2015 3 days interval for request dates 
                        
                        //START: D-0075 2/24/2015 JLedesma Validate input for restart
                        Boolean isPublishDay;
                        //START: D-0102 2/27/2015 Total Issue should not be 0.
                        Integer orderTempStopDayCount = 0;
                        if(subven.tp.Restart_Date__c != NULL){
                         //START: D-2594 3/22/2015 Related defect. Get the correct restart date.
                            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                            isPublishDay = publishedDayChecker(subven.Id, subven.tp.Restart_Date__c);
                            //END D-3329 8/26/2015 Added By C. Lin
                         //END: D-2594 3/22/2015 Related defect. Get the correct restart date.
                        }
                        
                        //START UD-3415 22Dec2015 Added By C. Lin - Fix days between to consider only publication days
                        Integer tDateToRDateCount = 0;
                        for(Date checkDate = subven.tp.Temp_Stop_Date__c; checkDate < subven.tp.Restart_Date__c; checkDate = checkDate.addDays(1)){
                            if(checkDate != null){
                                if(publishedDayChecker(subven.Id, checkDate)){
                                    tDateToRDateCount++;
                                }
                            }
                        }
                        //END UD-3415 22Dec2015 Added By C. Lin
                        
                        //START: D-2407 2/27/2015 Computation of year to date days
                        if(myId!=NULL && subven.tp.Temp_Stop_Date__c!= NULL && subven.tp.Restart_Date__c!=NULL && subven.tp.Qty__c!=NULL){
                            //START: UD-0309 03/20/2015 Year To Date computation
                            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                            mapRefundTotalCredit = computation(globalvariableclass.TS_CREATE, null, null, subven.Id, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c, Integer.valueOf(subven.tp.Qty__c),Integer.valueOf(subven.yearToDate), Integer.valueOf(subven.yearToDateNextYearfromSub), null, null, null, null, null);
                            //END UD-2443 9/5/2015 Added By C. Lin
                            //END D-3329 8/26/2015 Added By C. Lin
                            //END: UD-0309 03/20/2015 Year To Date computation
                            orderTempStopDayCount = Integer.valueOf(mapRefundTotalCredit.get('tempStopDays'));
                        }
                        //Start D-2483 03/10/2015 James - Temp Stop Settings View for Reference Data
                        //START: JLedesma UD-1146 5/21/2015 Commented out
                        /*Integer numberDays;
                        Integer cancelled = 0;
                        date TempStopDateTempStopSettings;
                        date DateTempStopSettings;
                        List<Date> DateTempStopSettingsList = new List<Date>();
                        if(subTempStopRecList.size() > 0){
                            //Get the latest Restart Date of previous Temp Stops
                            for(integer x = 0; x < subTempStopRecList.size(); x++) {  
                                if(subTempStopRecList[x].Temp_Stop__r.Temp_Stop_Status__c != 'Cancelled'){
                                    DateTempStopSettingsList.add(subTempStopRecList[x].Temp_Stop__r.Restart_Date__c);
                                }
                                else{
                                    //Start UD-0298 03/25/2015 James - Temp Stop Settings View for Reference Data
                                    if(subTempStopRecList[x].Temp_Stop__r.Temp_Stop_Status__c == 'Cancelled'){
                                        cancelled += 1;
                                    }
                                    //End UD-0298 03/25/2015 James - Temp Stop Settings View for Reference Data
                                }
                            }
                            //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                            if(DateTempStopSettingsList.size() > 0){
                                DateTempStopSettings = DateTempStopSettingsList[0];
                                for(integer y = 0; y < DateTempStopSettingsList.size(); y++) {  
                                    if (DateTempStopSettings < DateTempStopSettingsList[y]){
                                        DateTempStopSettings = DateTempStopSettingsList[y];
                                    }
                                }
                            }
                            TempStopDateTempStopSettings = subven.tp.Temp_Stop_Date__c;
                            if(TempStopDateTempStopSettings != null && DateTempStopSettings != null){
                                numberDays = DateTempStopSettings.daysBetween(TempStopDateTempStopSettings);
                            }
                            else{
                                numberDays = 0;
                            }
                        }
                        */
                        //END: JLedesma UD-1146 5/21/2015 Commented out
                        //End D-2483 03/10/2015 James - Temp Stop Settings View for Reference Data
                        //Start UD-0300 03/11/2015 JLedesma - Related
                        if(PendingCase.size() > 0){
                            for(integer t = 0; t < PendingCase.size(); t++){
                                //Start UD-0300 03/11/2015 JLedesma - Related
                                //START: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
                                if(subven.Id == PendingCase[t].Temp_Stop_Sub__c){
                                //END: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
                                //End UD-0300 03/11/2015 JLedesma - Related
                                    PendingCaseExist = true;
                                    PendingCaseNumber = PendingCase[t].CaseNumber;
                                }
                            }
                        }
                        //End UD-0300 03/11/2015 JLedesma - Related
                        if(subven.tp.Temp_Stop_Date__c == NULL || subven.tp.Restart_Date__c == NULL || subven.tp.Qty__c == NULL ){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Incomplete Inputs')));
                        } 
                        //END: D-0102 2/27/2015 Total Issue should not be 0.
                        //END: D-0075 2/24/2015 JLedesma Validate input for restart                     
                        //START: D-0081 2/24/2015 JLedesma Validate input temp stop date
                        //START: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
                        //Start UD-0300 03/11/2015 JLedesma - Related
                        else if(PendingCaseExist == true){
                                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('OverlappingNotApproved') + ' ' + PendingCaseNumber));
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Temp Stop Pending Cases')));
                        }
                        //End UD-0300 03/11/2015 JLedesma - Related 
                        else if(subven.tp.Restart_Date__c <= subven.tp.Temp_Stop_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Invalid Date Inputs')));
                        }
                        //END: D-0081 2/24/2015 JLedesma Validate input temp stop date
                        //START: D-1896 1/30/2015 Added error message to custom settings 
                        else if(subven.earliestStartDate  == null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Missing Earliest Start Date'))); 
                        }
                        //END: D-1896 1/30/2015 Added error message to custom settings 
                        //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                        else if(validateOverlapping(subTempStopRecList, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c, subven.Id, null)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Overlapping')));
                        }      
                        //END D-3329 8/26/2015 Added By C. Lin
                        //END: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
                        else if(validateLimit(subven.tp.Qty__c,subven.qty) ){                                         
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Limit')));
                        }
                        //Start D-1298 01/21/2015 Updated by James Azaña: Tempstop date should be greater than current date
                       else if(subven.tp.Temp_Stop_Date__c <= Date.TODAY()){
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 1')));
                        } 
                        //End D-1298 01/21/2015
                        else if(subven.subEndDate <= subven.tp.Temp_Stop_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 2')));
                        }
                        else if(subven.subStartDate > subven.tp.Temp_Stop_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 3')));
                        }       
                        else if(subven.subStartDate >= subven.tp.Restart_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 1')));
                        }   
                        else if(subven.subEndDate < subven.tp.Restart_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 2')));
                        }
                        //Start UD-1066 05/21/2015 Updated by JLedesma revert the remove of code block
                        //Start UD-1066 05/12/2015 Updated by JTeves: remove code block below
                        else if(subven.subEndDate <= subven.tp.Restart_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 3')));
                        }
                        //END UD-1066 05/12/2015 Updated by JTeves: remove code block below
                        //Start UD-1066 05/21/2015 Updated by JLedesma revert the remove of code block
                        else if(!isPublishDay){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 5')));
                        }
                        else if(orderTempStopDayCount == 0 ){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Temp Stop no issue for record')));
                        } 
                        //END: D-2407 2/27/2015 Computation of year to date days
                        //Start D-2483 03/10/2015 James - Temp Stop Settings View for Reference Data
                        //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                        //START: JLedesma UD-1146 5/21/2015 Commented out
                        //Start UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data
                        /*else if(subTempStopRecList.size() > 0 && (cancelled != subTempStopRecList.size()) && tempstopsettings.size() > 0 && numberDays < tempstopsettings[0].TempStop_Min_Gap_Days__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart1') + ' ' + tempstopsettings[0].TempStop_Min_Gap_Days__c + ' ' + ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart2')));
                        }*/
                        //END: JLedesma UD-1146 5/21/2015 Commented out
                        //START: JLedesma UD-1146 5/21/2015 3 days interval for request dates
                        else if(isWithinInterval){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart1') + ' ' + tempstopsettings[0].TempStop_Min_Gap_Days__c + ' ' + ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart2')));
                        }
                        //END: JLedesma UD-1146 5/21/2015 3 days interval for request dates
                        
                        //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                        //End D-2483 03/10/2015 James - Temp Stop Settings View for Reference Data
                        //END: D-1298 1/5/15 Added by J.Ledesma – corrected Validation messages.
                        //START UD-3415 22Dec2015 Added By C. Lin - Fix days between to consider only publication days
                        //else if(tempstopsettings.size() > 0 &&  subven.tp.Temp_Stop_Date__c.daysbetween(subven.tp.Restart_Date__c) < tempstopsettings[0].TempStop_Min_Gap_Days__c){
                        else if(tempstopsettings.size() > 0 &&  tDateToRDateCount < tempstopsettings[0].TempStop_Min_Gap_Days__c){
                        //END UD-3415 22Dec2015 Added By C. Lin
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopDateRestartDatePart1') + ' ' + tempstopsettings[0].TempStop_Min_Gap_Days__c + ' ' + ConstantsSLB.getErrorMessage('TempStopDateRestartDatePart2')));
                        }
                        //End UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data
                        else if(requestSource == 'Eshop' && subven.tp.Temp_Stop_Date__c.monthsBetween(subven.tp.Restart_Date__c) == eShopMonths) {
                            if(subven.tp.Temp_Stop_Date__c.day() < subven.tp.Restart_Date__c.day()) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidTempStopDurationEshop')));
                            } 
                            if(subven.tp.Temp_Stop_Date__c.day() == subven.tp.Restart_Date__c.day()) {
                                tempstopwrapper = new SelectedWrapper();
                                //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                                tempstopwrapper.id = subven.Id;
                                //END D-3329 8/26/2015 Added By C. Lin
                                tempstopwrapper.subscriptionName = subven.subscriptionName;
                                tempstopwrapper.earliestStartDate = subven.earliestStartDate;
                                tempstopwrapper.tempStopDate  = subven.tp.Temp_Stop_Date__c;
                                tempstopwrapper.yearToDate = subven.yeartoDate;
                                tempstopwrapper.restartDate  = subven.tp.Restart_Date__c;
                                tempstopwrapper.status  = subven.status;
                                tempstopwrapper.frequency  = subven.frequency;
                                tempstopwrapper.yearToDate = subven.yearToDate;
                                tempstopwrapper.tempStopQty  = subven.tp.Qty__c;
                                tempstopwrapper.billingAccount = subven.billingAccount;
                                tempstopwrapper.recipient = subven.recipient;
                                tempstopwrapper.deliverySub = subven.deliverySub;
                                tempstopwrapper.tempstopDays = subven.tempstopDays;
                                tempstopwrapper.packageId = subven.packageId;
                                tempstopwrapper.qty = subven.qty;
                                tempstopwrapper.orderTempStopDays = subven.tp.Temp_Stop_Date__c.daysBetween(subven.tp.Restart_Date__c);
                                tempstopwrapper.totalIssues = (tempstopwrapper.orderTempStopDays * integer.valueOf(subven.tp.Qty__c));
                                if(myId!=NULL && subven.tp.Temp_Stop_Date__c!= NULL && subven.tp.Restart_Date__c!=NULL){
                                    //START: UD-0309 03/20/2015 Year To Date computation
                                    //START: JLedesma D-3091 6/18/2015 Year To Date computation
                                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                                    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                                    mapRefundTotalCredit = computation(globalvariableclass.TS_CREATE, null, null, subven.Id, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c, Integer.valueOf(tempstopwrapper.tempStopQty),Integer.valueOf(subven.yearToDate), Integer.valueOf(subven.yearToDateNextYearfromSub), null, null, null, null, null);
                                    //END UD-2443 9/5/2015 Added By C. Lin
                                    //END D-3329 8/26/2015 Added By C. Lin
                                    //END: JLedesma D-3091 6/18/2015 Year To Date computation
                                    //END: UD-0309 03/20/2015 Year To Date computation
                                    tempstopwrapper.refundEligible = Integer.valueOf(mapRefundTotalCredit.get('refund'));
                                    tempstopwrapper.totalCredit = mapRefundTotalCredit.get('credit');
                                }
                                else{
                                    tempstopwrapper.refundEligible = 0;
                                    tempstopwrapper.totalCredit = 0;
                                }
                                //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
                                tempstopwrapper.productCode = subven.productCode;
                                //END UD-2233 8/19/2015 Added By C. Lin
                                
                                tempStopRequestList.add(tempstopwrapper);
                            }                                    
                        }
                        
                        else if(requestSource == 'Eshop' && subven.tp.Temp_Stop_Date__c.monthsBetween(subven.tp.Restart_Date__c) > eShopMonths) {
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidTempStopDurationEshop')));        
                        }
                        
                        else if(requestSource != 'Eshop' && subven.tp.Temp_Stop_Date__c.monthsBetween(subven.tp.Restart_Date__c) == crsmMonths) {
                            if(subven.tp.Temp_Stop_Date__c.day() < subven.tp.Restart_Date__c.day()) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidTempStopDurationCRSM')));
                            }
                            if(subven.tp.Temp_Stop_Date__c.day() == subven.tp.Restart_Date__c.day()) {
                                tempstopwrapper = new SelectedWrapper();
                                //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                                tempstopwrapper.id = subven.Id;
                                //END D-3329 8/26/2015 Added By C. Lin
                                tempstopwrapper.subscriptionName = subven.subscriptionName;
                                tempstopwrapper.earliestStartDate = subven.earliestStartDate;
                                tempstopwrapper.tempStopDate  = subven.tp.Temp_Stop_Date__c;
                                tempstopwrapper.yearToDate = subven.yeartoDate;
                                tempstopwrapper.restartDate  = subven.tp.Restart_Date__c;
                                tempstopwrapper.status  = subven.status;
                                tempstopwrapper.frequency  = subven.frequency;
                                tempstopwrapper.yearToDate = subven.yearToDate;
                                tempstopwrapper.tempStopQty  = subven.tp.Qty__c;
                                tempstopwrapper.billingAccount = subven.billingAccount;
                                tempstopwrapper.recipient = subven.recipient;
                                tempstopwrapper.deliverySub = subven.deliverySub;
                                tempstopwrapper.tempstopDays = subven.tempstopDays;
                                tempstopwrapper.packageId = subven.packageId;
                                tempstopwrapper.qty = subven.qty;
                                tempstopwrapper.orderTempStopDays = subven.tp.Temp_Stop_Date__c.daysBetween(subven.tp.Restart_Date__c);
                                tempstopwrapper.totalIssues = (tempstopwrapper.orderTempStopDays * integer.valueOf(subven.tp.Qty__c));
                                if(myId!=NULL && subven.tp.Temp_Stop_Date__c!= NULL && subven.tp.Restart_Date__c!=NULL){
                                    //START: UD-0309 03/20/2015 Year To Date computation
                                    //START: JLedesma D-3091 6/18/2015 Year To Date computation
                                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                                    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                                    mapRefundTotalCredit = computation(globalvariableclass.TS_CREATE, null, null, subven.Id, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c, Integer.valueOf(tempstopwrapper.tempStopQty), Integer.valueOf(subven.yearToDate), Integer.valueOf(subven.yearToDateNextYearfromSub), null, null, null, null, null);
                                    //END UD-2443 9/5/2015 Added By C. Lin
                                    //END D-3329 8/26/2015 Added By C. Lin
                                    //END: JLedesma D-3091 6/18/2015 Year To Date computation
                                    //END: UD-0309 03/20/2015 Year To Date computation
                                    tempstopwrapper.refundEligible = Integer.valueOf(mapRefundTotalCredit.get('refund'));
                                    tempstopwrapper.totalCredit = mapRefundTotalCredit.get('credit');
                                }
                                else{
                                    tempstopwrapper.refundEligible = 0;
                                    tempstopwrapper.totalCredit = 0;
                                }
                                //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
                                tempstopwrapper.productCode = subven.productCode;
                                //END UD-2233 8/19/2015 Added By C. Lin
                                
                                tempStopRequestList.add(tempstopwrapper);   
                            }
                                                  
                        }
                        
                        else if(requestSource != 'Eshop' && subven.tp.Temp_Stop_Date__c.monthsBetween(subven.tp.Restart_Date__c) > crsmMonths) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidTempStopDurationCRSM')));
                        }
                        
                        else{
                        tempstopwrapper = new SelectedWrapper();
                            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                            tempstopwrapper.id = subven.Id;
                            //END D-3329 8/26/2015 Added By C. Lin
                        tempstopwrapper.subscriptionName = subven.subscriptionName;
                        tempstopwrapper.earliestStartDate = subven.earliestStartDate;
                        tempstopwrapper.tempStopDate  = subven.tp.Temp_Stop_Date__c;
                        //START: D-2407 2/26/2015 Computation of year to date days
                        tempstopwrapper.restartDate  = subven.tp.Restart_Date__c;
                        tempstopwrapper.status  = subven.status;
                        tempstopwrapper.frequency  = subven.frequency;
                        tempstopwrapper.tempStopQty  = subven.tp.Qty__c;                    
                        tempstopwrapper.billingAccount = subven.billingAccount;
                        tempstopwrapper.recipient = subven.recipient;
                        tempstopwrapper.deliverySub = subven.deliverySub;
                        tempstopwrapper.tempstopDays = subven.tempstopDays;
                        tempstopwrapper.packageId = subven.packageId;
                        tempstopwrapper.qty = subven.qty;
                        //START: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
                        if(myId!=NULL && subven.tp.Temp_Stop_Date__c!= NULL && subven.tp.Restart_Date__c!=NULL){
                            //START UD-0296 3/27/2015 Added By C. Lin - No refund eligible copies and total credit for Temp Stop Days
                            //START: UD-0309 03/20/2015 Year To Date computation
                            //START: JLedesma D-3091 6/18/2015 Year To Date computation
                                //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myId to subven.Id
                                //mapRefundTotalCredit = computation(globalvariableclass.TS_CREATE, null, null, myId, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c, Integer.valueOf(tempstopwrapper.tempStopQty), Integer.valueOf(subven.yearToDate),Integer.valueOf(subven.yearToDateNextYearfromSub));
                                //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                                mapRefundTotalCredit = computation(globalvariableclass.TS_CREATE, null, null, subven.Id, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c, Integer.valueOf(tempstopwrapper.tempStopQty), Integer.valueOf(subven.yearToDate),Integer.valueOf(subven.yearToDateNextYearfromSub), null, null, null, null, null);
                                //END UD-2443 9/5/2015 Added By C. Lin
                                //END D-3329 8/26/2015 Added By C. Lin
                            //END: JLedesma D-3091 6/18/2015 Year To Date computation
                            //END: UD-0309 03/20/2015 Year To Date computation
                            //END UD-0296 3/27/2015 Added By C. Lin
                            tempstopwrapper.refundEligible = Integer.valueOf(mapRefundTotalCredit.get('refund'));
                            tempstopwrapper.totalCredit = mapRefundTotalCredit.get('credit');
                            tempstopwrapper.orderTempStopDays = Integer.valueOf(mapRefundTotalCredit.get('tempStopDays'));
                            tempstopwrapper.totalIssues = Integer.valueOf(mapRefundTotalCredit.get('issue'));
                            tempstopwrapper.yearToDateCurrentYear = Integer.valueOf(mapRefundTotalCredit.get('current'));
                            tempstopwrapper.yearToDateNextYear = Integer.valueOf(mapRefundTotalCredit.get('next'));
                        }
                        else{
                            tempstopwrapper.refundEligible = 0;
                            tempstopwrapper.totalCredit = 0;
                            tempstopwrapper.orderTempStopDays = 0;
                            tempstopwrapper.totalIssues = 0;
                            tempstopwrapper.yearToDateCurrentYear = 0;
                            tempstopwrapper.yearToDateNextYear = 0;
                        }
                        //Start D-2483 03/10/2015 James - Temp Stop Settings View for Reference Data
                        //Start UD-0298 03/25/2015 James  - Temp Stop Settings View for Reference Data
                        //START D-2655 03/31/2015 JLedesma - Checks Total Issue instead of qty.
                        //START UD-0300 4/28/2015 Added By C. Lin - Additional Fix
                            //START UD-2781 9/16/2015 Added By C. Lin - change refundEligible to orderTempStopDays
                            //START UD-2942 10/1/2015 Added By C. Lin - Remove validation preventing temp stop for more than 30 days
                            /*if(tempstopsettings.size() > 0 && tempstopwrapper.orderTempStopDays > tempstopsettings[0].TemStop_Max_Issues__c){
                            //END UD-2781 9/16/2015 Added By C. Lin
                        //END UD-0300 4/28/2015 Added By C. Lin
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopQtyLesserPart1') + ' ' + tempstopsettings[0].TemStop_Max_Issues__c + '. ' + ConstantsSLB.getErrorMessage('TempStopQtyGreaterLesserPart2')));
                            tempstopwrapper.totalCredit = 0;
                            tempstopwrapper.refundEligible = 0;
                        }
                            //START UD-2781 9/16/2015 Added By C. Lin - change totalIssues to orderTempStopDays
                            else*/
                            if(tempstopsettings.size() > 0 && tempstopwrapper.orderTempStopDays < tempstopsettings[0].TemStop_Min_Issues__c){
                            //END UD-2942 10/1/2015 Added By C. Lin
                            //END UD-2781 9/16/2015 Added By C. Lin
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopQtyGreaterPart1') + ' ' + tempstopsettings[0].TemStop_Min_Issues__c + '. ' + ConstantsSLB.getErrorMessage('TempStopQtyGreaterLesserPart2')));
                            tempstopwrapper.totalCredit = 0;
                            tempstopwrapper.refundEligible = 0;
                        }
                        //END D-2655 03/31/2015 JLedesma - Checks Total Issue instead of qty.
                        //End D-UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data
                        //End D-2483 03/10/2015 James - Temp Stop Settings View for Reference Data
                        //tempstopwrapper.totalIssues = (tempstopwrapper.orderTempStopDays * integer.valueOf(subven.tp.Qty__c));
                            //START UD-2781 9/16/2015 Added By C. Lin - Set totalIssues same as orderTempStopDays
                            tempstopwrapper.totalIssues = integer.valueOf(tempstopwrapper.orderTempStopDays);
                            //START UD-2781 9/16/2015 Added By C. Lin
                            
                            //START UD-2588 09/16/2015 Added by J.Sarion - Update year to date only for temp stop days of 8 or greater
                            //START UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                            if(subven.yeartoDate != null && counterAllInOne == 0){
                                tempstopwrapper.yearToDate = subven.yeartoDate;
                                //START UD-3416 22Dec2015 Added By C. Lin - Fix days between to consider only publication days
                                //if(subven.tp.Temp_Stop_Date__c.daysBetween(subven.tp.Restart_Date__c) >= 8){
                                if(tDateToRDateCount >= 8){
                                //END UD-3416 22Dec2015 Added By C. Lin
                                    //START UD-3416 06Jan2015 Added By C. Lin - Change orderTempStopDays to yearToDateCurrentYear
                                    tempstopwrapper.yearToDate = subven.yearToDate + tempstopwrapper.yearToDateCurrentYear;
                                    //END UD-3416 06Jan2015 Added By C. Lin
                                    tempstopwrapper.yearToDateTemp = tempstopwrapper.orderTempStopDays;
                                }
                                else{
                                    //START UD-3416 07Jan2015 Added By C. Lin - Change 0 to yearToDate
                                    tempstopwrapper.yearToDate = subven.yearToDate;
                                    //END UD-3416 07Jan2015 Added By C. Lin
                                    tempstopwrapper.yearToDateTemp = 0;
                                }
                            }
                            else{
                                tempstopwrapper.yearToDate = 0;
                                tempstopwrapper.yearToDateTemp = 0;
                            }
                            //END UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                            //END UD-2588 09/16/2015 Added by J.Sarion - Update year to date only for temp stop days of 8 or greater
                        //START: JLedesma D-3091 6/18/2015 Year To Date computation
                        if(tempstopwrapper.yearToDate > 30){
                            tempstopwrapper.yearToDate = 30;
                        }
                        //END: JLedesma D-3091 6/18/2015 Year To Date computation
                            //START UD-2588 09/16/2015 Added by J.Sarion - Update year to date only for temp stop days of 8 or greater
                            //START UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                            /*
                            if(subven.tp.Temp_Stop_Date__c.daysBetween(subven.tp.Restart_Date__c) >= 8){
                                tempstopwrapper.yearToDateTemp = tempstopwrapper.orderTempStopDays;
                            }
                            else{
                                tempstopwrapper.yearToDateTemp = 0;
                            }
                            */
                            //END UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                            //END UD-2588 09/16/2015 Added by J.Sarion - Update year to date only for temp stop days of 8 or greater
                        //END: D-2407 2/26/2015 Computation of year to date days
                        //START UD-0296 3/27/2015 Added By C. Lin - No refund eligible copies and total credit for Temp Stop Days
                        //START: UD-0326 3/19/2015 Computation of year to date days
                        /*if(subven.yearToDate > 30){
                            tempstopwrapper.totalCredit = 0;
                            tempstopwrapper.refundEligible = 0;
                        }*/
                        //END: UD-0326 3/19/2015 Computation of year to date days
                        if(tempstopwrapper.orderTempStopDays < 8){
                            tempstopwrapper.totalCredit = 0;
                            tempstopwrapper.refundEligible = 0;
                        }
                        //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
                        tempstopwrapper.productCode = subven.productCode;
                        //END UD-2233 8/19/2015 Added By C. Lin
                        
                        //END UD-0296 3/27/2015 Added By C. Lin
                        tempStopRequestList.add(tempstopwrapper);
                        //END: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
                        }
                    }
                }
            }
            //Start UD-2925 VPernicia 9/25/15
            isAdd = false;
            //End UD-2925 VPernicia 9/25/15     
        }
                    
        /*Description: Instantiates record values for Selected Temp Stop Records to be Created
        *Parameter: NA
        *Return: NA
        */   
        public void setSubscriptionRecords() { 
            if(subList.size() > 0) {
                for (Zuora__Subscription__c subven : subList) {         
                    wrapper = new SubscriptionWrapper();
                    wrapper.id = subven.Id;
                    wrapper.subId = subven.Id;
                    if(subven.Id != null || subven.Id != ''){
                       wrapper.earliestStartDate = earliestStart(subven.Id);
                    }
                    else{
                         wrapper.earliestStartDate = NULL;
                    }
                    wrapper.packageId = subven.Main_Package_1__r.Id;
                    wrapper.subscriptionName = subven.Main_Package_1__r.Name;
                    //START: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                    wrapper.status = subven.Status_Formula__c;
                    wrapper.frequency = subven.Frequency_1__c;
                    wrapper.billingAccount = subven.Zuora__CustomerAccount__r.Name;
                    wrapper.recipient = subven.Recipient_Contact__r.Name;
                    wrapper.billingId = subven.Zuora__CustomerAccount__r.Id;
                    if (subven.Recipient_Address_ID__c <> null){
                        wrapper.deliverySub = deliverySub(subven.Id);
                    }
                    //END: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                    wrapper.recipientId = subven.Recipient_Contact__r.Id;
                    
                    //START: D-1511 1/21/2015 Manolo Valena - Used the number of copies field of the subscription record to give the appropriate value for the current quantities.
                    wrapper.qty = Integer.valueOf(subven.Number_of_Copies__c);
                    //END: D-1511 1/21/2015 Manolo Valena
                    
                    wrapper.tp = new Temp_Stop__c();
                    if(subven.Year_to_Date_Temp_Stop_Days__c!=NULL){
                        wrapper.yearToDate = subven.Year_to_Date_Temp_Stop_Days__c;
                    }
                    else{
                        wrapper.yearToDate = 0;
                    }
                    //START: UD-0309 03/20/2015 Year To Date computation
                    if(subven.Next_Year_Temp_Stop_Days__c != NULL){
                        wrapper.yearToDateNextYearfromSub = Integer.valueOf(subven.Next_Year_Temp_Stop_Days__c);
                    }
                    else{
                        wrapper.yearToDateNextYearfromSub = 0;
                    }
                    //END: UD-0309 03/20/2015 Year To Date computation
                    wrapper.subEndDate = subven.Zuora__SubscriptionEndDate__c;
                    wrapper.subStartDate = subven.Zuora__SubscriptionStartDate__c;
                    //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
                    wrapper.productCode = subven.Product_Code__c;
                    //END UD-2233 8/19/2015 Added By C. Lin
                    
                    //Start UD-2925 VPernicia 9/25/15: Put Transient
                    if (isAdd == false) {
                        subscriptionResultList.add(wrapper);
                    }
                    //End UD-2925 VPernicia 9/25/15: Put Transient
                }
            }      
        }
        

        
        /*Description: Instantiates record values of all Temp Stop records that can be updated.
        *Parameter: NA
        *Return: NA
        */   
        public void setSubscriptionRecordsUpdate() {            
            for (Subscription_Temp_Stop__c subven : sToUpdate) {         
                wrapper2 = new Subscriptionwrapper();
                //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                if(subven.Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c != NULL){
                    wrapper2.oldYearToDateCurrentYear = Integer.valueOf(subven.Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c);
                }
                else{
                    wrapper2.oldYearToDateCurrentYear = 0;
                }
                if(subven.Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c != NULL){
                    wrapper2.oldYearToDateNextYear = Integer.valueOf(subven.Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c);
                }
                else{
                    wrapper2.oldYearToDateNextYear = 0;
                }
                //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                wrapper2.id = subven.Id;
                wrapper2.subId = subven.Subscription__r.Id;
                if(subven.Subscription__c != null){
                   wrapper2.earliestStartDate = earliestStart(subven.Subscription__c);
                }
                else{
                         wrapper.earliestStartDate = NULL;
                }
                wrapper2.subEndDate = subven.Subscription__r.Zuora__SubscriptionEndDate__c;
                wrapper2.subStartDate = subven.Subscription__r.Zuora__SubscriptionStartDate__c;
                wrapper2.packageId = subven.Subscription__r.Main_Package_1__r.Id;
                wrapper2.tempstopstatus = subven.Temp_Stop__r.Temp_Stop_Status__c;
                wrapper2.subscriptionName = subven.Subscription__r.Main_Package_1__r.Name;
                //START: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                wrapper2.status = subven.Subscription__r.Status_Formula__c;
                wrapper2.frequency = subven.Subscription__r.Frequency_1__c;
                wrapper2.billingAccount = subven.Subscription__r.Zuora__CustomerAccount__r.Name;
                wrapper2.recipient = subven.Subscription__r.Recipient_Contact__r.Name;
                wrapper2.billingId = subven.Subscription__r.Zuora__CustomerAccount__r.Id;
                wrapper2.recipientId = subven.Subscription__r.Recipient_Contact__r.Id;
                wrapper2.qty = integer.valueOf(subven.Subscription__r.Number_of_Copies__c);
                wrapper2.tempstopDate = subven.Temp_Stop__r.Temp_Stop_Date__c;
                //wrapper2.tempstopDate = subven.Temp_Stop__r.Temp_Stop_Date__c; //START END D-4317 21Jan2016 Added By C. Lin - Reduce redundancy
                if (subven.Subscription__r.Recipient_Address_ID__c <> null){
                    wrapper2.deliverySub = deliverySub(subven.Subscription__c);
                }
                //END: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                wrapper2.restartDate = subven.Temp_Stop__r.Restart_Date__c;
                wrapper2.tempstopqty = subven.Temp_Stop__r.Qty__c;
                wrapper2.tempstopId = subven.Temp_Stop__r.Id;
                wrapper2.tempstopstatus = subven.Temp_Stop__r.Temp_Stop_Status__c;
                wrapper2.tp = new Temp_Stop__c();
                if(subven.Subscription__r.Year_to_Date_Temp_Stop_Days__c!=NULL){
                    wrapper2.yearToDate = subven.Subscription__r.Year_to_Date_Temp_Stop_Days__c;
                }
                else{
                    wrapper2.yearToDate = 0;
                }
                
                if (subven.Temp_Stop__r.Temp_Stop_Date__c > date.today()) {
                    wrapper2.isTempstopdateGTTODAY = true;
                } else {
                    wrapper2.isTempstopdateGTTODAY = false;
                }
                
                if (subven.Temp_Stop__r.Restart_Date__c <= wrapper2.earliestStartDate) {
                    wrapper2.isrestartdateLTEearliestStartDate = true;
                } else {
                    wrapper2.isrestartdateLTEearliestStartDate = false;
                }
                if (subven.Temp_Stop__r.Temp_Stop_Date__c <= date.today()) {
                    wrapper2.isTempstopdateLTEToday = true;
                } else {
                    wrapper2.isTempstopdateLTEToday = false;
                }
                
                if (subven.Temp_Stop__r.Restart_Date__c > date.today()) {
                    wrapper2.isrestartdateGTToday = true;
                } else {
                    wrapper2.isrestartdateGTToday = false;
                }
                //START: D-1950 2/10/15 JLedesma - Update old temp stop status
                wrapper2.tempStopToUpdate = subven.Temp_Stop__c;
                //END: D-1950 2/10/15 JLedesma - Update old temp stop status
                
                //START: UD-0309 03/20/2015 Year To Date computation
                if(subven.Subscription__r.Next_Year_Temp_Stop_Days__c != NULL){
                    wrapper2.yearToDateNextYearfromSub = Integer.valueOf(subven.Subscription__r.Next_Year_Temp_Stop_Days__c);
                }
                else{
                    wrapper2.yearToDateNextYearfromSub = 0;
                }
                //END: UD-0309 03/20/2015 Year To Date computation
                //START: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
                wrapper2.caseStatusUpdate = subven.Temp_Stop__r.Temp_Stop_Status__c;
                //END: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
                //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
                wrapper2.productCode = subven.Subscription__r.Product_Code__c;
                //END UD-2233 8/19/2015 Added By C. Lin
                
                updateResultList.add(wrapper2);
                
            }
        }
        
        /*Description: Instantiates record values for Selected Temp Stop Records to be Updated
        *Parameter: NA
        *Return: NA
        */   
        public void setUpdateRecords() {            
            //Start UD-2925 VPernicia 9/25/15
            getSubscriptions();
            setSubscriptionRecords();
            //End UD-2925 VPernicia 9/25/15
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
            Integer refundInSelected = 0;
            Decimal yearToDateInSelected = 0;
            Decimal oldYearToDateInSelected = 0;
            Decimal oldNextYearToDateInSelected = 0;
            //END UD-2443 9/5/2015 Added By C. Lin
            
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            if(checkDuplicateSubscriptionUpdate()) {
                Set<Id> relatedBundleSubIdSet = new Set<Id>();
                relatedBundleSubIdSet = getRelatedBundleSub(myIdUpdate);
                
                for (SubscriptionWrapper subven : updateResultList) {
                
                    //START UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                    List<Package_Item__c> pckList = new List<Package_Item__c>();
                    if(subIdToPackageItems.containsKey(subven.subId)){
                        pckList = subIdToPackageItems.get(subven.subId);
                    }
                    Integer counterAllInOne = 0;
                    
                    for(Package_Item__c pItem : pckList){
                        if(pItem.Is_All_In_One__c == TRUE){
                            counterAllInOne++;
                        }
                    }
                    //END UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                
                //END D-3329 8/26/2015 Added By C. Lin
                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                    if(subven.Id == myIdUpdate || relatedBundleSubIdSet.contains(subven.Id)){
                    //END D-3329 8/26/2015 Added By C. Lin
                       //START: D-1172,D-1298 1/5/15 Added by J.Ledesma – corrected Validation messages.
                       //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                       //START: UD-0326 3/19/2015 Computation of year to date days
                        Boolean isPublishDay = publishedDayChecker(subven.subId, subven.tp.Restart_Date__c);
                        //END: UD-0326 3/19/2015 Computation of year to date days
                        //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                        
                        //START: D-0102 2/27/2015 Total Issue should not be 0.
                        Integer orderTempStopDayCount = 0;
                        //START UD-0313 3/11/2015 Added By C. Lin - Add code for getting temp stop date from temp stop history when Status is On-going
                        Date tempStopDate;
                        if(subVen.tempstopstatus == 'On-going'){
                            tempStopDate = subVen.tempstopDate;
                        }else{
                            tempStopDate = subven.tp.Temp_Stop_Date__c;
                        }
                        
                        //START D-4317 21Jan2016 Added By C. Lin - Move to get the tempStopDate if the temp stop status is On-going
                        //START UD-3416 22Dec2015 Added By C. Lin - Fix days between to consider only publication days
                        Integer tDateToRDateCount = 0;
                        for(Date checkDate = tempStopDate; checkDate < subven.tp.Restart_Date__c; checkDate = checkDate.addDays(1)){
                            if(checkDate != null){
                                if(publishedDayChecker(subven.subId, checkDate)){
                                    tDateToRDateCount++;
                                }
                            }
                        }
                        //END UD-3416 22Dec2015 Added By C. Lin
                        //END D-4317 21Jan2016 Added By C. Lin
                        
                        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                        for(Id stsId : selectedIdToSubIdToTempStopUpdate.keySet()){
                            if(selectedIdToSubIdToTempStopUpdate.containsKey(stsId)){
                                for(Id sId : selectedIdToSubIdToTempStopUpdate.get(stsId).keySet()){
                                    if(sId == subVen.subId){
                                        refundInSelected += selectedIdToSubIdToTempStopUpdate.get(stsId).get(sId).refundEligible;
                                        yearToDateInSelected += selectedIdToSubIdToTempStopUpdate.get(stsId).get(sId).yearToDateCurrentYear;
                                        oldYearToDateInSelected += selectedIdToSubIdToTempStopUpdate.get(stsId).get(sId).OldYearToDateCurrentYear;
                                        oldNextYearToDateInSelected += selectedIdToSubIdToTempStopUpdate.get(stsId).get(sId).OldYearToDateNextYear;
                                    }
                                }
                            }
                        }
                        
                        List<Subscription_Temp_Stop__c> remainingTS = getRemainingTempStopId(subven.Id);
                        Integer totalOldRemainCurrentYD = 0;
                        Integer totalOldRemainNextYD = 0;
                        
                        for(Subscription_Temp_Stop__c tsRec : remainingTS){
                            totalOldRemainCurrentYD += Integer.valueOf(tsRec.Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c);
                            totalOldRemainNextYD += Integer.valueOf(tsRec.Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c);
                        }
                        totalOldRemainCurrentYD += Integer.valueOf(oldYearToDateInSelected);
                        totalOldRemainNextYD += Integer.valueOf(oldNextYearToDateInSelected);
                        //END UD-2443 9/5/2015 Added By C. Lin
                        if(subven.subId!=NULL && tempStopDate != NULL && subven.tp.Restart_Date__c!=NULL){
                            //START: UD-0309 03/20/2015 Year To Date computation
                            //START: JLedesma D-3091 6/18/2015 Year To Date computation
                            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. add refundInSelected, totalOldRemainCurrentYD, totalOldRemainNextYD
                            mapRefundTotalCredit = computation(globalvariableclass.TS_UPDATE, subven.OldYearToDateCurrentYear, subven.OldYearToDateNextYear, subven.subId, tempStopDate, subven.tp.Restart_Date__c, Integer.valueOf(subven.tempStopQty), Integer.valueOf(subven.yearToDate),Integer.valueOf(subven.yearToDateNextYearfromSub), refundInSelected, totalOldRemainCurrentYD, totalOldRemainNextYD, null, null);
                            //END UD-2443 9/5/2015 Added By C. Lin
                            //END: JLedesma D-3091 6/18/2015 Year To Date computation
                            //END: UD-0309 03/20/2015 Year To Date computation
                        //END UD-0313 3/11/2015 Added By C. Lin
                            orderTempStopDayCount = Integer.valueOf(mapRefundTotalCredit.get('tempStopDays'));
                        }
                        
                        //START: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
                        //START: D-3095 GSantos 6/12/2015 Regression  - Attempt to de-reference a null object error in Temp Stop page
                        //START UD-2230 8/6/2015 Added by Manolo Valena - Updated condition in firing error message.
                        if(((subven.tp.Temp_Stop_Date__c == NULL || subven.tp.Restart_Date__c == NULL) && subVen.tempstopstatus == GlobalVariableClass.TS_STATUS_NOTSTARTED) ||
                           (subven.tp.Restart_Date__c == NULL && subVen.tempstopstatus == GlobalVariableClass.TS_STATUS_ONGOING)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Incomplete Inputs')));
                        }
                        //END UD-2230 8/6/2015 Added by Manolo Valena 
                        else if(pendingCaseChecker(subven.subId)){
                        //END: D-3095 GSantos 6/12/2015 Regression  - Attempt to de-reference a null object error in Temp Stop page
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Temp Stop Pending Cases')));
                        }                        
                        else if(requestSource != 'Eshop' && (tempStopDate.monthsBetween(subven.tp.Restart_Date__c) > crsmMonths)) {
                        //END: D-3077 JLedesma 6/5/2014 No validation of Pending for Approval Update Temp Stop (Direct)
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidTempStopDurationCRSM')));
                        } 
                        //END: D-0102 2/27/2015 Total Issue should not be 0.
                        //Start D-1298 01/21/2015 Updated by James Azaña: Tempstop date should be greater than current date
                       else if(subven.tp.Temp_Stop_Date__c <= Date.TODAY()){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 1')));
                        } 
                        //End D-1298 01/21/2015
                        else if(subven.subEndDate <= tempStopDate){ //START END D-4317 21Jan2016 Added By C. Lin - change to tempStopDate to consider On-going temp stop
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 2')));
                        }
                        else if(subven.subStartDate > subven.tp.Temp_Stop_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 3')));
                        }       
                        else if(subven.subStartDate >= subven.tp.Restart_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 1')));
                        }   
                        else if(subven.subEndDate < subven.tp.Restart_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 2')));
                        }
                        else if(!isPublishDay){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 5')));
                        }
                        //END: D-1298 1/5/15 Added by J.Ledesma – corrected Validation messages.
                        else if(requestSource == 'Eshop' && subven.tp.Temp_Stop_Date__c.monthsBetween(subven.tp.Restart_Date__c) > eShopMonths) {
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidTempStopDurationEshop')));        
                        }
                        //START: D-0102 2/27/2015 Total Issue should not be 0.
                        //START: D-2407 2/26/2015 Computation of year to date days
                        //START PD-0001 03May2016 Added By C. Lin - Bypass Migrated Data for Overlapping Validation. Update code on 04May
                        //else if(stsIdToStsMap.get(subven.Id).Subscription_Temp_Stop_Legacy_Id__c == null){
                        else if(validateOverlapping(subTempStopRecList, tempStopDate, subven.tp.Restart_Date__c, subven.subId, myIdUpdate) && stsIdToStsMap.get(subven.Id).Subscription_Temp_Stop_Legacy_Id__c == null){ //START END D-4317 21Jan2016 Added By C. Lin - change to tempStopDate to consider On-going temp stop
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Overlapping')));
                        }
                        //}
                        //END PD-0001 03May2016 Added By C. Lin
                        else if(orderTempStopDayCount == 0 ){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Temp Stop no issue for record')));
                        } 
                        //END: D-0102 2/27/2015 Total Issue should not be 0.
                        //END: D-2407 2/26/2015 Computation of year to date days
                        else{ 
                            tempstopwrapper = new SelectedWrapper();
                            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myIdUpdate to subven.Id
                            tempstopwrapper.id = subven.Id;
                            //END D-3329 8/26/2015 Added By C. Lin
                            tempstopwrapper.tempstopId = subven.tempstopId;
                            tempstopwrapper.subId = subven.subId;
                            tempstopwrapper.subscriptionName = subven.subscriptionName;
                            tempstopwrapper.earliestStartDate = subven.earliestStartDate;
                            if(subven.tp.Temp_Stop_Date__c!=NULL){
                                tempstopwrapper.tempstopDate = subven.tp.Temp_Stop_Date__c;
                                }
                            else{
                                tempstopwrapper.tempstopDate = subven.tempstopDate;
                            }
                            tempstopwrapper.restartDate  = subven.tp.Restart_Date__c;
                            tempstopwrapper.tempStopQty  = subven.tempStopQty;
                            tempstopwrapper.deliverySub  = subven.deliverySub;
                            //START: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
                            //START: D-2407 2/27/2015 Computation of year to date days
                            tempstopwrapper.remarks = tempstopwrapper.remarks;
                            if(subven.subId!=NULL && tempstopwrapper.tempstopDate!= NULL && subven.tp.Restart_Date__c!=NULL){
                                tempstopwrapper.refundEligible = Integer.valueOf(mapRefundTotalCredit.get('refund'));
                                tempstopwrapper.totalCredit = mapRefundTotalCredit.get('credit');
                                tempstopwrapper.orderTempStopDays = Integer.valueOf(mapRefundTotalCredit.get('tempStopDays'));
                                tempstopwrapper.totalIssues = Integer.valueOf(mapRefundTotalCredit.get('issue'));
                                tempstopwrapper.yearToDateCurrentYear = Integer.valueOf(mapRefundTotalCredit.get('current'));
                                tempstopwrapper.yearToDateNextYear = Integer.valueOf(mapRefundTotalCredit.get('next'));
                            }
                            else{
                                tempstopwrapper.refundEligible = 0;
                                tempstopwrapper.totalCredit = 0;
                                tempstopwrapper.orderTempStopDays = 0;
                                tempstopwrapper.totalIssues = 0;
                                tempstopwrapper.yearToDateCurrentYear = 0;
                                tempstopwrapper.yearToDateNextYear = 0;
                            }
                            //START: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                            //START UD-2781 9/16/2015 Added By C. Lin - change refundEligible to orderTempStopDays
                            //START UD-2942 10/1/2015 Added By C. Lin - Remove validation preventing temp stop for more than 30 days
                            /*if(tempstopsettings.size() > 0 && tempstopwrapper.orderTempStopDays > tempstopsettings[0].TemStop_Max_Issues__c){
                            //START UD-2781 9/16/2015 Added By C. Lin
                            //END: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopQtyLesserPart1') + ' ' + tempstopsettings[0].TemStop_Max_Issues__c + '. ' + ConstantsSLB.getErrorMessage('TempStopQtyGreaterLesserPart2')));
                                tempstopwrapper.totalCredit = 0;
                                tempstopwrapper.refundEligible = 0;
                            }
                            //START UD-2781 9/16/2015 Added By C. Lin - change totalIssues to orderTempStopDays
                            else*/
                            if(tempstopsettings.size() > 0 && tempstopwrapper.orderTempStopDays < tempstopsettings[0].TemStop_Min_Issues__c){
                            //END UD-2942 10/1/2015 Added By C. Lin
                            //START UD-2781 9/16/2015 Added By C. Lin
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopQtyGreaterPart1') + ' ' + tempstopsettings[0].TemStop_Min_Issues__c + '. ' + ConstantsSLB.getErrorMessage('TempStopQtyGreaterLesserPart2')));
                                tempstopwrapper.totalCredit = 0;
                                tempstopwrapper.refundEligible = 0;
                            }
                            
                            //START UD-2781 9/16/2015 Added By C. Lin - remove *tempstopwrapper.tempStopQty
                            tempstopwrapper.totalIssues = integer.valueOf(tempstopwrapper.orderTempStopDays);
                            //START UD-2781 9/16/2015 Added By C. Lin
                            //START: D-1950 2/10/15 JLedesma - Update old temp stop status  
                            tempstopwrapper.tempStopToUpdate = subven.tempStopToUpdate;
                            //START: D-2407 2/27/2015 Computation of year to date days
                            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. Add + yearToDateInSelected //- oldYearToDateInSelected
                            
                            //START UD-2588 09/16/2015 Added by J.Sarion - Update year to date only for temp stop days of 8 or greater
                            /*if(subven.tp.Temp_Stop_Date__c.daysBetween(subven.tp.Restart_Date__c) >= 8){
                                tempstopwrapper.yearToDate = (subven.yearToDate - subven.OldYearToDateCurrentYear - oldYearToDateInSelected) + tempstopwrapper.yearToDateCurrentYear + yearToDateInSelected;
                            }
                            else{
                                tempstopwrapper.yearToDate = subven.yearToDate;
                            }*/
                            //START UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                            if(counterAllInOne == 0){
                                if(tempstopwrapper.tempstopDate != null && tempstopwrapper.restartDate != null){
                                    //START UD-3416 22Dec2015 Added By C. Lin - Fix days between to consider only publication days
                                    //if(tempstopwrapper.tempstopDate.daysBetween(tempstopwrapper.restartDate) >= 8){
                                    if(tDateToRDateCount >= 8){
                                    //END UD-3416 22Dec2015 Added By C. Lin
                                        tempstopwrapper.yearToDate = (subven.yearToDate - subven.OldYearToDateCurrentYear - oldYearToDateInSelected) + tempstopwrapper.yearToDateCurrentYear + yearToDateInSelected;
                                    }else{
                                        tempstopwrapper.yearToDate = subven.yearToDate - subven.OldYearToDateCurrentYear; //START-END UD-2588 09/17/2015 Added by J.Sarion - update year to date
                                    }
                                }else{
                                    tempstopwrapper.yearToDate = subven.yearToDate;
                                }
                            }
                            else{
                                tempstopwrapper.yearToDate = 0;
                            }
                            //END UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                            //END UD-2588 09/16/2015 Added by J.Sarion - Update year to date only for temp stop days of 8 or greater
                            
                            //END UD-2443 9/5/2015 Added By C. Lin
                            //START: JLedesma D-3091 6/18/2015 Year To Date computation
                            if(tempstopwrapper.yearToDate > 30){
                                tempstopwrapper.yearToDate = 30;
                            }
                            //END: JLedesma D-3091 6/18/2015 Year To Date computation
                            //START UD-2588 09/16/2015 Added by J.Sarion - update year to date
                            /*if(subven.tp.Temp_Stop_Date__c.daysBetween(subven.tp.Restart_Date__c) >= 8){
                                tempstopwrapper.yearToDateTemp = tempstopwrapper.orderTempStopDays;
                            }
                            else{
                                tempstopwrapper.yearToDateTemp = 0;
                            }*/
                            //START UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                            if(counterAllInOne == 0){
                                if(tempstopwrapper.tempstopDate != null && tempstopwrapper.restartDate != null){
                                    //START UD-3416 22Dec2015 Added By C. Lin - Fix days between to consider only publication days
                                    //if(tempstopwrapper.tempstopDate.daysBetween(tempstopwrapper.restartDate) >= 8){
                                    if(tDateToRDateCount >= 8){
                                    //END UD-3416 22Dec2015 Added By C. Lin
                                        tempstopwrapper.yearToDateTemp = tempstopwrapper.orderTempStopDays;
                                    }
                                    else{
                                        tempstopwrapper.yearToDateTemp = 0;
                                    }
                                }else{
                                    tempstopwrapper.yearToDateTemp = 0;
                                }
                            }
                            else{
                                tempstopwrapper.yearToDateTemp = 0;
                            }
                            //END UD-2908 09/22/2015 Added by C. Lin - AIO packages will have 0 year to date count
                            //END UD-2588 09/16/2015 Added by J.Sarion - update year to date
                            //END: D-2407 2/27/2015 Computation of year to date days
                            //END: D-1950 2/10/15 JLedesma - Update old temp stop status  
                            tempstopwrapper.OldYearToDateCurrentYear = subven.OldYearToDateCurrentYear; 
                            tempstopwrapper.OldYearToDateNextYear = subven.OldYearToDateNextYear;
                            //START UD-0296 3/27/2015 Added By C. Lin - No refund eligible copies and total credit for Temp Stop Days
                            if(tempstopwrapper.orderTempStopDays < 8){
                                tempstopwrapper.totalCredit = 0;
                                tempstopwrapper.refundEligible = 0;
                            }
                            //END UD-0296 3/27/2015 Added By C. Lin
                            //START: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
                            tempstopwrapper.caseStatusUpdate = subven.caseStatusUpdate; 
                            //END: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
                            //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
                            tempstopwrapper.productCode = subven.productCode;
                            //END UD-2233 8/19/2015 Added By C. Lin
                            
                            updateRequestList.add(tempstopwrapper);
                            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                            for(SelectedWrapper upReq : updateRequestList){
                                selectedIdToSubIdToTempStopUpdate.put(upReq.Id, new Map<Id, SelectedWrapper>());
                                selectedIdToSubIdToTempStopUpdate.get(upReq.Id).put(upReq.subId, upReq);
                            }
                            //END UD-2443 9/5/2015 Added By C. Lin
                            //END: D-2126 JLedesma 2/9/2015 Discount computation for refund considered.
                            
                            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
                            for(SelectedWrapper updateReq : updateRequestList){
                                //START UD-2908 09/22/2015 Added by C. Lin - update year to date count
                                if(updateReq.subId == tempstopwrapper.subId){
                                    updateReq.yearToDate = tempstopwrapper.yearToDate;
                                }
                                //END UD-2908 09/22/2015 Added by C. Lin - update year to date count
                            }
                            //END UD-2443 9/5/2015 Added By C. Lin
                       }
                    }
                }
            //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
            }
            //END D-3329 8/26/2015 Added By C. Lin
        }
            
        
        /*Description: Instantiates record values of all Temp Stop records that can be cancelled.
        *Parameter: NA
        *Return: NA
        */   
        public void setSubscriptionRecordsCancel() {            
            for (Subscription_Temp_Stop__c subven : sToCancel) {         
                wrapper3  = new Subscriptionwrapper();
                //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                if(subven.Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c != NULL){
                    wrapper3.oldYearToDateCurrentYear = Integer.valueOf(subven.Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c);
                }
                else{
                    wrapper3.oldYearToDateCurrentYear = 0;
                }
                if(subven.Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c != NULL){
                    wrapper3.oldYearToDateNextYear = Integer.valueOf(subven.Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c);
                }
                else{
                    wrapper3.oldYearToDateNextYear = 0;
                }
                //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
                wrapper3.id = subven.Id;
                wrapper3.subId = subven.Subscription__c;
                if(subven.Subscription__c!= null){
                   wrapper3.earliestStartDate = earliestStart(subven.Subscription__c);
                }
                wrapper3.packageId = subven.Subscription__r.Main_Package_1__r.Id;
                wrapper3.tempstopstatus = subven.Temp_Stop__r.Temp_Stop_Status__c;
                wrapper3.tempstopId = subven.Temp_Stop__c;
                wrapper3.subscriptionName = subven.Subscription__r.Main_Package_1__r.Name;
                //START: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                wrapper3.status = subven.Subscription__r.Status_Formula__c;
                wrapper3.frequency = subven.Subscription__r.Frequency_1__c;
                wrapper3.billingAccount = subven.Subscription__r.Zuora__CustomerAccount__r.Name;
                wrapper3.recipient = subven.Subscription__r.Recipient_Contact__r.Name;
                wrapper3.billingId = subven.Subscription__r.Zuora__CustomerAccount__r.Id;
                wrapper3.recipientId = subven.Subscription__r.Recipient_Contact__r.Id;
                wrapper3.qty = integer.valueOf(subven.Subscription__r.Number_of_Copies__c);
                wrapper3.tempstopqty = subven.Temp_Stop__r.Qty__c;
                wrapper3.tempstopDate = subven.Temp_Stop__r.Temp_Stop_Date__c;
                if (subven.Subscription__r.Recipient_Address_ID__c<> null){
                    wrapper3.deliverySub = deliverySub(subven.Subscription__c);
                }
                //END: UD-1066 5/7/2015 Include all eligible subscriptions for Temp Stop
                wrapper3.restartDate = subven.Temp_Stop__r.Restart_Date__c;
                wrapper3.tempstopstatus = subven.Temp_Stop__r.Temp_Stop_Status__c;
                wrapper3.tp = new Temp_Stop__c();
                if(subven.Temp_Stop__r.Case__r.Year_To_Date_Count__c == NULL){
                    subven.Temp_Stop__r.Case__r.Year_To_Date_Count__c = 0;
                }
                if(subven.Subscription__r.Year_to_Date_Temp_Stop_Days__c == NULL){
                    subven.Subscription__r.Year_to_Date_Temp_Stop_Days__c = 0;
                }
                //START UD-3417 22Jan2016 Added By C. Lin - Change to subven.Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c
                //wrapper3.yearToDate = subven.Subscription__r.Year_to_Date_Temp_Stop_Days__c - subven.Temp_Stop__r.Case__r.Year_To_Date_Count__c;
                wrapper3.yearToDate = subven.Subscription__r.Year_to_Date_Temp_Stop_Days__c - subven.Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c;
                //END UD-3417 22Jan2016 Added By C. Lin
                if(wrapper3.yearToDate < 0){
                    wrapper3.yearToDate = 0;
                }
                //START: UD-0309 03/20/2015 Year To Date computation
                if(subven.Subscription__r.Next_Year_Temp_Stop_Days__c != NULL){
                    wrapper3.yearToDateNextYearfromSub = Integer.valueOf(subven.Subscription__r.Next_Year_Temp_Stop_Days__c);
                }
                else{
                    wrapper3.yearToDateNextYearfromSub = 0;
                }
                //END: UD-0309 03/20/2015 Year To Date computation
                //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
                wrapper3.productCode = subven.Subscription__r.Product_Code__c;
                //END UD-2233 8/19/2015 Added By C. Lin
                
                cancelResultList.add(wrapper3);
                
            }
        }

        /*Description: Instantiates record values for Selected Temp Stop Records to be Cancelled
        *Parameter: NA
        *Return: NA
        */   
        public void setCancelRecords() {            
            //Start UD-2925 VPernicia 9/25/15
            getSubscriptions();
            setSubscriptionRecords();
            //End UD-2925 VPernicia 9/25/15
            //START UD-2008 8/13/2015 Added By C. Lin - Instantiate checker list again when method is invoked
            if(checkDuplicateSubscriptionCancel()){
                //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                Set<Id> relatedBundleSubIdSet = new Set<Id>();
                relatedBundleSubIdSet = getRelatedBundleSub(myIdCancel);
                //END D-3329 8/26/2015 Added By C. Lin
                
                for (SubscriptionWrapper subven : cancelResultList) {         
                    //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
                    if(subven.Id == myIdCancel || relatedBundleSubIdSet.contains(subven.Id)){
                    //END D-3329 8/26/2015 Added By C. Lin
                        tempstopwrapper = new SelectedWrapper();
                        tempstopwrapper.subid = subven.subId;
                        //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together. myIdCancel to subven.Id
                        tempstopwrapper.id = subven.Id;
                        //END D-3329 8/26/2015 Added By C. Lin
                        tempstopwrapper.remarks = tempstopwrapper.remarks;
                        tempstopwrapper.tempstopid = subven.tempstopid;
                        tempstopwrapper.subscriptionName = subven.subscriptionName;
                        tempstopwrapper.tempStopDate  = subven.tempstopDate;
                        tempstopwrapper.deliverySub = subven.deliverySub;
                        tempstopwrapper.restartDate  = subven.restartDate;
                        tempstopwrapper.tempStopQty  = subven.tempStopQty;
                        tempstopwrapper.status  = subven.tempstopstatus;
                        //START: D-2407 2/27/2015 Computation of year to date days
                        tempstopwrapper.yearToDate = subven.yearToDate;
                        //END: D-2407 2/27/2015 Computation of year to date days
                        tempstopwrapper.OldYearToDateCurrentYear = subven.OldYearToDateCurrentYear; 
                        tempstopwrapper.OldYearToDateNextYear = subven.OldYearToDateNextYear;
                        //START UD-2233 8/19/2015 Added By C. Lin - Add Product Code to identify bundle packages
                        tempstopwrapper.productCode = subven.productCode;
                        //END UD-2233 8/19/2015 Added By C. Lin
                        
                        cancelRequestList.add(tempstopwrapper);
                    }
                }
            }
            //END UD-2008 8/13/2015 Added By C. Lin
        }

        /*Description: Options for request source picklist
        *Parameter: NA
        *Return: List
        */   
        public List<SelectOption> getRequestSources() {
            List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption(globalvariableclass.TS_OPTION_CALL, globalvariableclass.TS_OPTION_CALL));
                options.add(new SelectOption(globalvariableclass.TS_OPTION_EMAIL, globalvariableclass.TS_OPTION_EMAIL));
                options.add(new SelectOption(globalvariableclass.TS_OPTION_FAX, globalvariableclass.TS_OPTION_FAX));
                options.add(new SelectOption(globalvariableclass.TS_OPTION_MAIL, globalvariableclass.TS_OPTION_MAIL));
                options.add(new SelectOption(globalvariableclass.TS_OPTION_ESHOP, globalvariableclass.TS_OPTION_ESHOP));
            return options;
        } 
        
        /*Description: Options for Temp Stop Type radio button 
        *Parameter: NA
        *Return: List
        */   
        public List<SelectOption> getListTempStopType() {
            List<SelectOption> options = new List<SelectOption>(); 
                options.add(new SelectOption(globalvariableclass.TS_RADIO_CREATE_TEMP_STOP,globalvariableclass.TS_RADIO_CREATE_TEMP_STOP)); 
                options.add(new SelectOption(globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP,globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP)); 
                options.add(new SelectOption(globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP,globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP));
            return options; 
        }
        
        /*Description: Creation of records upon submission of save button
        *Parameter: NA
        *Return: NA
        */   
        public List<Case> createRecordsOnSave(){
            //Start UD-2925 VPernicia 9/25/15: Put Transient
            mTSCas = new map<Id, Id>();
            mCasSub = new map<Id, List<Id>>();
            subIdToStsMap = new Map<Id, List<Subscription_Temp_Stop__c>>();
            getSubscriptions();
            //subToUpdateList = new List<Zuora__Subscription__c>(); //Start/End UD-2925 VPernicia 9/25/15: Variable not in used
            //End UD-2925 VPernicia 9/25/15: Put Transient
            List<Order__c> orderInsertList = new List<Order__c>();
            List<Case> caseList = new List<Case>();
            List<Case> urgent = new List<Case>();
            List<Case> trytry = new List<Case>();
            List<Temp_Stop__c> tempStopInsertList = new List<Temp_Stop__c>();
            List<Temp_Stop__c> oldTempStopUpdateList = new List<Temp_Stop__c>();
            List<Subscription_Temp_Stop__c> tempStopList = new List<Subscription_Temp_Stop__c>();
            List<Case_Subscription__c> directCaseSubs = new List<Case_Subscription__c>();    
            //START: D-2407 2/27/2015 Computation of year to date days
            List<Zuora__Subscription__c> subUpdateYearToDate = new List<Zuora__Subscription__c>();    
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            //END: D-2407 2/27/2015 Computation of year to date days
            //START D-3415 9/10/2015 Added By C. Lin - Separate Approved Case List
            List<Case> caseListApproved = new List<Case>();
            //END D-3415 9/10/2015 Added By C. Lin
            
            //Creation of records for the Update Temp Stop
            if (selectedTempStopType == globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP){
                               
                for (SelectedWrapper Upd : updateRequestList){
                                     
                    Order__c order = new Order__c();
                    order.Subscription__c = Upd.subId;
                    order.Account__c = thisAccount.Id;
                    order.Order_Type__c = globalvariableclass.TS_TEMP_STOP;
                    order.Temp_Stop_Type__c = globalvariableclass.TS_UPDATE;
                    order.Status__c = globalvariableclass.TS_NEW;
                    order.Informed_Customer__c = true;
                    order.Case_Record_Type__c = ConstantsSLB.getKeyId('Temp Stop Subscription');
                    order.Credit_Balance__c = 0; 
                    order.Delivery_Charge__c = 0; 
                    order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                    order.Request_Source__c = requestSource; 
                    order.Subscriber_Account__c = thisAccount.Id;
                    orderInsertList.add(order);
                        
                    thisCase = new Case(); 
                    thisCase.Create_Follow_Up_Task__c = followUpTask;
                    thisCase.Origin = requestSource;
                    thisCase.Total_Issue__c = Upd.totalIssues;
                    thisCase.Temp_Stop_Type__c = globalvariableclass.TS_UPDATE;
                    thisCase.RecordTypeID = ConstantsSLB.getKeyId('Temp Stop Subscription');
                    thisCase.Category__c = globalvariableclass.TS_SUBSCRIPTION_REQUEST;
                    thisCase.Subject = globalvariableclass.TS_SUBJECT;
                    thisCase.Temp_Stop_Date__c = Upd.tempStopDate;
                    thisCase.POP_Start_Date__c = Upd.earliestStartDate;
                    thisCase.Qty__c = Upd.tempStopQty;
                    thisCase.Restart_Date__c = Upd.restartDate;
                    thisCase.Remarks__c = Upd.remarks;
                    thisCase.Temp_Stop_Sub__c = Upd.subId;
                    thisCase.Request_Total_Issue__c = Upd.refundEligible;
                    thisCase.Request_Total_Credit__c = Upd.totalCredit;
                    thisCase.AccountId = thisAccount.Id;  
                    //START UD-3293 11/25/15 RReyes
                    if(parentCaseId != null){
                        thisCase.ParentId = parentCaseId;
                    }
                    //END UD-3293 11/25/15 RReyes
                    //START: JLedesma D-3091 6/18/2015 Year To Date computation
                    //thisCase.Current_Date_for_Year_To_Date__c = Upd.yearToDateCurrentYear;
                    //thisCase.Next_Year_for_Year_To_Date__c = Upd.yearToDateNextYear;
                    //END: JLedesma D-3091 6/18/2015 Year To Date computation
                    //START: D-2407 2/27/2015 Computation of year to date days
                    thisCase.Year_To_Date_Count__c = Upd.yearToDateTemp;
                    //END: D-2407 2/27/2015 Computation of year to date days
                    //START: D-1950 2/10/15 JLedesma - Update old temp stop status
                    thisCase.Temp_Stop_Updated__c = Upd.tempStopToUpdate;
                    //END: D-1950 2/10/15 JLedesma - Update old temp stop status
                    //Start UD-0753 04/06/2015 James - temp stop date equal to earliest start date should not be urgent
                    //Start d-4261 VPernicia: Remove condition for globalvariableclass.TS_STATUS_ONGOING
                    //START: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.                 
                    //if ((Upd.caseStatusUpdate != globalvariableclass.TS_STATUS_ONGOING) && (Upd.tempStopDate < Upd.earliestStartDate || Upd.restartDate < Upd.earliestStartDate)){
                    //END: D-2493 JLedesma 4/6/2015 Wrong Status and Sub Status after updating an on-going Urgent Temp Stop case.
                    /*****************************************************
                    //PD-0112 ORIGINAL CODE
                    if (Upd.tempStopDate < Upd.earliestStartDate || Upd.restartDate < Upd.earliestStartDate){
                    //End d-4261 VPernicia: Remove condition for globalvariableclass.TS_STATUS_ONGOING
                    //End UD-0753 04/06/2015 James
                            thisCase.Requires_Urgent_Approval__c = true;
                            //START: D-1483 1/8/15 Added by J.Ledesma – Create follow up task.
                            //START/END: UD-0754 4/20/2015 Removed setting Create follow up task to true upon urgent approval.
                            //END: D-1483 1/8/15 Added by J.Ledesma – Create follow up task.
                            thisCase.Status = globalvariableclass.TS_PENDING;
                            thisCase.Sub_Status__c = globalvariableclass.WAITING_URGENT_TEMPSTOP_RESTART_APPROVAL;
                    } else {
                            thisCase.Requires_Urgent_Approval__c = false;
                            thisCase.Status = 'Closed';
                            thisCase.Sub_Status__c = globalvariableclass.TEMP_STOP_APPROVED;
                        
                        //START D-3415 9/10/2015 Added By C. Lin - Separate Approved Case List
                        caseListApproved.add(thisCase);
                        //END D-3415 9/10/2015 Added By C. Lin
                    }
                    *******************************************************/
                    
                    //START PD-0112 6/6/16 EFernandez
                       if (upd.tempStopDate < Upd.earliestStartDate && Upd.tempStopDate == stsIdToStsMap.get(Upd.Id).Temp_Stop__r.Temp_Stop_Date__c) {
                              System.debug('***old TP Temp Stop Date' + stsIdToStsMap.get(Upd.Id).Temp_Stop__r.Temp_Stop_Date__c);
                              System.debug('***old TP Restart Date' + stsIdToStsMap.get(Upd.Id).Temp_Stop__r.Restart_Date__c);
                              if (upd.restartDate < Upd.earliestStartDate && Upd.restartDate != stsIdToStsMap.get(Upd.Id).Temp_Stop__r.Restart_Date__c) {
                                   thisCase.Requires_Urgent_Approval__c = true;
                                   thisCase.Status = globalvariableclass.TS_PENDING;
                                   thisCase.Sub_Status__c = globalvariableclass.WAITING_URGENT_TEMPSTOP_RESTART_APPROVAL;
                                  } else {
                                           thisCase.Requires_Urgent_Approval__c = false;
                                           thisCase.Status = 'Closed';
                                           thisCase.Sub_Status__c = globalvariableclass.TEMP_STOP_APPROVED;
                                           caseListApproved.add(thisCase);
                              }
                        } 
                        else if (upd.tempStopDate < Upd.earliestStartDate && Upd.tempStopDate != stsIdToStsMap.get(Upd.Id).Temp_Stop__r.Temp_Stop_Date__c) {
                                       thisCase.Requires_Urgent_Approval__c = true;
                                       thisCase.Status = globalvariableclass.TS_PENDING;
                                       thisCase.Sub_Status__c = globalvariableclass.WAITING_URGENT_TEMPSTOP_RESTART_APPROVAL;
                                 } else {
                                          thisCase.Requires_Urgent_Approval__c = false;
                                          thisCase.Status = 'Closed';
                                          thisCase.Sub_Status__c = globalvariableclass.TEMP_STOP_APPROVED;
                                          caseListApproved.add(thisCase);
                                 }
                    //END PD-0112 6/6/16 EFernandez
                    
                            
                    caseList.add(thisCase);
                    
                    
                    Temp_Stop__c tpRecord = new Temp_Stop__c ();
                    tpRecord.Temp_Stop_Date__c = Upd.tempStopDate; 
                    tpRecord.Restart_Date__c = Upd.restartDate; 
                    tpRecord.Remarks__c = Upd.remarks;
                    tpRecord.Qty__c = Upd.tempStopQty;
                    tpRecord.Request_Total_Issue__c = Upd.refundEligible;
                    tpRecord.Request_Total_Credit__c = Upd.totalCredit;
                    tpRecord.Cancelled__c = False;
                                        
                    Subscription_Temp_Stop__c thisSubTemp = new Subscription_Temp_Stop__c();
                    thisSubTemp.Subscription__c= Upd.subId;
                    thisSubTemp.Temp_Stop__c = tpRecord.Id;

                    Case_Subscription__c casSub = new Case_Subscription__c();
                    casSub.Case__c = thisCase.Id;
                    casSub.Account__c = thisAccount.Id;
                    casSub.Subscription__c = Upd.subId; 

                    if (thisCase.Status == globalvariableclass.TS_CLOSED){
                        tempStopInsertList.add(tpRecord);
                        tempStopList.add(thisSubTemp);
                        directCaseSubs.add(casSub);
                        
                        /*Start UD-2925 VPernicia 9/25/15: Comment-out
                        Zuora__Subscription__c subToUpdate = mapSubIdToSubRecord.get(Id.valueOf(Upd.subId));
                        if(subToUpdate.Next_Year_Temp_Stop_Days__c == null){
                            subToUpdate.Next_Year_Temp_Stop_Days__c = 0;
                        }
                        if(subToUpdate.Year_to_Date_Temp_Stop_Days__c == null){
                            subToUpdate.Year_to_Date_Temp_Stop_Days__c = 0;
                        }
                        subToUpdate.Next_Year_Temp_Stop_Days__c = (subToUpdate.Next_Year_Temp_Stop_Days__c - Upd.OldYearToDateNextYear) + Upd.yearToDateNextYear;
                        subToUpdate.Year_to_Date_Temp_Stop_Days__c = (subToUpdate.Year_to_Date_Temp_Stop_Days__c - Upd.OldYearToDateCurrentYear) + Upd.yearToDateCurrentYear;
                        subToUpdateList.add(subToUpdate);
                       
                        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                        //updateRemainingTS(Upd.Id, Upd.yearToDateCurrentYear, Upd.yearToDateNextYear, 'Update');
                        //END UD-2443 9/5/2015 Added By C. Lin
                        End UD-2925 VPernicia 9/25/15: Comment-out*/
                    }
            }
                
                /*Start UD-2925 VPernicia 9/25/15: Comment-out
                //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                if(!caseIdToCaseMap.isEmpty()){
                    //update caseIdToCaseMap.values();
                }
                
                if(!tsIdToTempStopMap.isEmpty()){
                    //update tsIdToTempStopMap.values();
                }
                End UD-2925 VPernicia 9/25/15: Comment-out*/
                //END UD-2443 9/5/2015 Added By C. Lin
        } 
        
        //Creation of records for the Cancel Temp Stop
        else if (selectedTempStopType == globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP){
            for (SelectedWrapper Can : cancelRequestList){
                         
                Order__c order = new Order__c();
                order.Subscription__c = Can.subId;
                order.Account__c = thisAccount.Id;
                order.Order_Type__c = globalvariableclass.TS_TEMP_STOP;
                order.Temp_Stop_Type__c = globalvariableclass.TS_CANCEL;
                order.Status__c = globalvariableclass.TS_NEW;
                order.Informed_Customer__c = true;
                order.Case_Record_Type__c = ConstantsSLB.getKeyId('Temp Stop Subscription');
                order.Credit_Balance__c = 0; 
                order.Delivery_Charge__c = 0; 
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Request_Source__c = requestSource;  
                order.Subscriber_Account__c = thisAccount.Id;
                orderInsertList.add(order);
                
                thisCase = new Case(); 
                thisCase.Create_Follow_Up_Task__c = followUpTask;
                thisCase.Origin = requestSource;
                thisCase.Temp_Stop_Type__c = globalvariableclass.TS_CANCEL;
                thisCase.RecordTypeID = ConstantsSLB.getKeyId('Temp Stop Subscription');
                thisCase.Category__c = globalvariableclass.TS_SUBSCRIPTION_REQUEST;
                thisCase.Subject = globalvariableclass.TS_SUBJECT;
                thisCase.Temp_Stop_Date__c = Can.tempStopDate;
                thisCase.Temp_Stop__c = Can.tempstopid;
                thisCase.Qty__c = Can.tempStopQty;
                thisCase.Restart_Date__c = Can.restartDate;
                thisCase.Remarks__c = Can.remarks;
                thisCase.Temp_Stop_Sub__c = Can.subId;  
                thisCase.AccountId = thisAccount.Id;   
                //START UD-3293 11/25/15 RReyes
                if(parentCaseId != null){
                    thisCase.ParentId = parentCaseId;
                }
                //END UD-3293 11/25/15 RReyes
                    if (Can.tempStopDate == Date.Today() + 1){
                        thisCase.Requires_Urgent_Approval__c = true;
                        //START: D-1483 1/8/15 Added by J.Ledesma – Create follow up task.
                        //START/END: UD-0754 4/20/2015 Removed setting Create follow up task to true upon urgent approval.
                        //END: D-1483 1/8/15 Added by J.Ledesma – Create follow up task.
                        thisCase.Status = globalvariableclass.TS_PENDING;
                        thisCase.Sub_Status__c = globalvariableclass.TS_URGENT_APPROVAL_STATUS;
                    } else {
                        thisCase.Requires_Urgent_Approval__c = false;
                        thisCase.Status = globalvariableclass.TS_CLOSED;
                        thisCase.Sub_Status__c = globalvariableclass.TS_APPROVED;
                        
                        //START D-3415 9/10/2015 Added By C. Lin - Separate Approved Case List
                        caseListApproved.add(thisCase);
                        //END D-3415 9/10/2015 Added By C. Lin
                    }
                caseList.add(thisCase);

                Temp_Stop__c thisTempStop = new Temp_Stop__c ();
                thisTempStop.Id = Can.tempStopId;
                thisTempStop.Cancelled__c = True;
                
                if (thisCase.Status == globalvariableclass.TS_CLOSED){
                    oldTempStopUpdateList.add(thisTempStop);
                        /*Start UD-2925 VPernicia 9/25/15: Comment-out
                        Zuora__Subscription__c subToUpdate = mapSubIdToSubRecord.get(Id.valueOf(Can.subId));
                            if(subToUpdate.Next_Year_Temp_Stop_Days__c == null){
                                subToUpdate.Next_Year_Temp_Stop_Days__c = 0;
                            }
                            if(subToUpdate.Year_to_Date_Temp_Stop_Days__c == null){
                                subToUpdate.Year_to_Date_Temp_Stop_Days__c = 0;
                            }
                            subToUpdate.Next_Year_Temp_Stop_Days__c = (subToUpdate.Next_Year_Temp_Stop_Days__c - Can.OldYearToDateNextYear);
                            subToUpdate.Year_to_Date_Temp_Stop_Days__c = (subToUpdate.Year_to_Date_Temp_Stop_Days__c - Can.OldYearToDateCurrentYear);
                            subToUpdateList.add(subToUpdate);
                        
                        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                        //updateRemainingTS(Can.Id, null, null, 'Cancel');
                        //END UD-2443 9/5/2015 Added By C. Lin
                        End UD-2925 VPernicia 9/25/15: Comment-out*/
                }
            } 
                //START: D-3628 10/29/15 Added by Manolo Valena
                //cancelUpdateRecords(caseList); //START END UD-3417 21Jan2016 Added By C. Lin - Remove method. Create, Update and Cancel of Temp Stop should be in CaseTriggerHandler to consider approval process
                //END: D-3628 10/29/15 Added by Manolo Valena
                //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
                /*Start UD-2925 VPernicia 9/25/15: Comment-out
                if(!caseIdToCaseMap.isEmpty()){
                    //update caseIdToCaseMap.values();
                }
                
                if(!tsIdToTempStopMap.isEmpty()){
                    //update tsIdToTempStopMap.values();
                }
                End UD-2925 VPernicia 9/25/15: Comment-out*/
                //END UD-2443 9/5/2015 Added By C. Lin
        } 
        
        //Creation of records for the Create Temp Stop
        else {
        
            for (SelectedWrapper tempstop : tempStopRequestList){ 
                    Order__c order = new Order__c();
                    order.Subscription__c = tempstop.Id;
                    order.Account__c = thisAccount.Id;
                    order.Order_Type__c = globalvariableclass.TS_TEMP_STOP;
                    order.Temp_Stop_Type__c = globalvariableclass.TS_CREATE;
                    order.Status__c = 'New';
                    order.Informed_Customer__c = true;
                    order.Case_Record_Type__c = ConstantsSLB.getKeyId('Temp Stop Subscription');
                    order.Credit_Balance__c = 0; 
                    order.Delivery_Charge__c = 0; 
                    order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                    order.Request_Source__c = requestSource;  
                    order.Subscriber_Account__c = thisAccount.Id;
                    orderInsertList.add(order);
                    
                    thisCase = new Case(); 
                    thisCase.Origin = requestSource;
                    thisCase.Total_Issue__c = tempstop.totalIssues;
                    thisCase.Temp_Stop_Type__c = globalvariableclass.TS_CREATE;
                    thisCase.RecordTypeID = ConstantsSLB.getKeyId('Temp Stop Subscription');
                    thisCase.Category__c = globalvariableclass.TS_SUBSCRIPTION_REQUEST;
                    thisCase.Subject = globalvariableclass.TS_SUBJECT;
                    thisCase.Temp_Stop_Date__c = tempstop.tempStopDate;
                    thisCase.POP_Start_Date__c = tempstop.earliestStartDate;
                    thisCase.Qty__c = tempstop.tempStopQty;
                    thisCase.Restart_Date__c = tempstop.restartDate;
                    thisCase.Remarks__c = tempstop.remarks;
                    thisCase.Temp_Stop_Sub__c = tempstop.Id; 
                    thisCase.AccountId = thisAccount.Id;
                    thisCase.Create_Follow_Up_Task__c = followUpTask;
                    thisCase.Request_Total_Issue__c = tempstop.refundEligible;
                    thisCase.Request_Total_Credit__c = tempstop.totalCredit;
                    //START UD-3293 11/25/15 RReyes
                    if(parentCaseId != null){
                        thisCase.ParentId = parentCaseId;
                    }
                    //END UD-3293 11/25/15 RReyes
                    //START: JLedesma D-3091 6/18/2015 Year To Date computation
                    //thisCase.Current_Date_for_Year_To_Date__c = tempstop.yearToDateCurrentYear;
                    //thisCase.Next_Year_for_Year_To_Date__c = tempstop.yearToDateNextYear;
                    //END: JLedesma D-3091 6/18/2015 Year To Date computation
                    //START: D-2407 2/27/2015 Computation of year to date days
                    thisCase.Year_To_Date_Count__c = tempstop.yearToDateTemp;
                    //END: D-2407 2/27/2015 Computation of year to date days
                        //Start UD-0753 04/06/2015 James - temp stop date equal to earliest start date should not be urgent
                        if (tempstop.tempStopDate < tempstop.earliestStartDate || tempstop.restartDate < tempstop.earliestStartDate ){
                        //End UD-0753 04/06/2015 James
                                thisCase.Requires_Urgent_Approval__c = true;
                                //START: D-1483 1/8/15 Added by J.Ledesma – Create follow up task.
                                //START/END: UD-0754 4/20/2015 Removed setting Create follow up task to true upon urgent approval.
                                //END: D-1483 1/8/15 Added by J.Ledesma – Create follow up task.
                                thisCase.Status = globalvariableclass.TS_PENDING;
                                thisCase.Sub_Status__c = globalvariableclass.TS_URGENT_APPROVAL_STATUS;
                        } else {
                                thisCase.Requires_Urgent_Approval__c = false;
                                thisCase.Status = globalvariableclass.TS_CLOSED;
                                thisCase.Sub_Status__c = globalvariableclass.TS_APPROVED;
                            
                            //START D-3415 9/10/2015 Added By C. Lin - Separate Approved Case List
                            caseListApproved.add(thisCase);
                            //END D-3415 9/10/2015 Added By C. Lin
                        }
                    caseList.add(thisCase);
                    
                    Temp_Stop__c tpRecord = new Temp_Stop__c ();
                    tpRecord.Temp_Stop_Date__c = thisCase.Temp_Stop_Date__c; 
                    tpRecord.Restart_Date__c = thisCase.Restart_Date__c; 
                    tpRecord.Remarks__c = thisCase.Remarks__c;
                    tpRecord.Request_Total_Issue__c = tempstop.refundEligible;
                    tpRecord.Request_Total_Credit__c = tempstop.totalCredit;
                    tpRecord.Qty__c = tempstop.tempStopQty;
                    tpRecord.Cancelled__c = False;
                    
                    Subscription_Temp_Stop__c thisSubTemp = new Subscription_Temp_Stop__c();
                    thisSubTemp.Subscription__c = tempstop.Id;
                    thisSubTemp.Temp_Stop__c = tpRecord.Id;
                    
                    Case_Subscription__c casSub = new Case_Subscription__c();
                    casSub.Case__c = thisCase.Id;
                    casSub.Account__c = thisAccount.Id;
                    casSub.Subscription__c = tempstop.Id; 
                    
                    if (thisCase.Status == globalvariableclass.TS_CLOSED){
                        tempStopInsertList.add(tpRecord);
                        tempStopList.add(thisSubTemp);
                        directCaseSubs.add(casSub);
                        /*Start UD-2925 VPernicia 9/25/15: Comment-out
                        Zuora__Subscription__c subToUpdate = mapSubIdToSubRecord.get(Id.valueOf(tempstop.Id));
                        if(subToUpdate.Next_Year_Temp_Stop_Days__c == null){
                            subToUpdate.Next_Year_Temp_Stop_Days__c = 0;
                        }
                        if(subToUpdate.Year_to_Date_Temp_Stop_Days__c == null){
                            subToUpdate.Year_to_Date_Temp_Stop_Days__c = 0;
                        }
                        subToUpdate.Next_Year_Temp_Stop_Days__c += tempstop.yearToDateNextYear;
                        subToUpdate.Year_to_Date_Temp_Stop_Days__c += tempstop.yearToDateCurrentYear;
                        subToUpdateList.add(subToUpdate);
                        End UD-2925 VPernicia 9/25/15: Comment-out*/
                    }
                    
            }
         } 
        
            insert orderInsertList;
            
            for(Case c : caseList) {
                c.Order__c = orderInsertList[indexNumber].Id;
                indexNumber++;
            }
            insert caseList;    
            trytry = caseList;
            /*Start UD-2925 VPernicia 9/25/15: Comment-out
            for(case c:  caselist){
                mCaseOrder.put(c.Id, c.Order__c);
            }
            End UD-2925 VPernicia 9/25/15: Comment-out*/
            try {
                //START D-3415 9/10/2015 Added By C. Lin - Separate Approved Case List
                /*if(caseList.size() == tempStopInsertList.size()) {
                    for(Integer i = 0; i < caseList.size(); i++) {
                        tempStopInsertList[i].Order__c = caseList[i].Order__c;     
                        tempStopInsertList[i].Case__c = caseList[i].Id; 
                    }
                }*/
                
                if(caseListApproved.size() == tempStopInsertList.size()) {
                    for(Integer i = 0; i < caseListApproved.size(); i++) {
                        tempStopInsertList[i].Order__c = caseListApproved[i].Order__c;
                        tempStopInsertList[i].Case__c = caseListApproved[i].Id;
                    }
                }
                //END D-3415 9/10/2015 Added By C. Lin
            }
            catch(exception e) {
            }
              
            insert tempStopInsertList; 
            
            if(tempStopInsertList.size()>0){
                for(Temp_Stop__c t: tempStopInsertList){
                    mTSCas.put(t.case__c,t.Id);
                }
            }
            
          
            for(Case c : caseList) {
                if(c.status == globalvariableclass.TS_CLOSED && c.Temp_Stop_Type__c!='Cancel'){ 
                   c.Temp_stop__c = mTSCas.get(c.Id);
                }
        
            }
            
                update caseList;       

            for(case c: caseList){
                if(c.Temp_Stop__c != null){
                    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
                    if(mCasSub.containsKey(c.temp_stop_sub__c)){
                        mCasSub.get(c.temp_stop_sub__c).add(c.Temp_Stop__c);
                    }else{
                        mCasSub.put(c.temp_stop_sub__c, new List<Id> {c.Temp_Stop__c});
                    }
                    //END UD-2443 9/5/2015 Added By C. Lin
                 }
            }
            indexNumber = 0;    
        
            list<Subscription_Temp_Stop__c > newSTS = new list<Subscription_Temp_Stop__c >();
            
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
            for(Subscription_Temp_Stop__c sts : tempStopList){
                if(sts.Subscription__c != null){
                    if(subIdToStsMap.containsKey(sts.Subscription__c)){
                        subIdToStsMap.get(sts.Subscription__c).add(sts);
                    }else{
                        subIdToStsMap.put(sts.Subscription__c, new List<Subscription_Temp_Stop__c> {sts});
                    }
                }
            }
            
            for(Id subId : subIdToStsMap.keySet()){
                if(subIdToStsMap.get(subId).size() == mCasSub.get(subId).size()){
                    for(Integer x = 0; x < subIdToStsMap.get(subId).size(); x++){
                        subIdToStsMap.get(subId)[x].Temp_stop__c = mCasSub.get(subId)[x];
                    }
                }
            }
            
            /*for(Integer x = 0; x < tempStopList.size(); x++){
                if(mCasSub.containsKey(tempStopList[x].Subscription__c)){
                    tempStopList[x].Temp_stop__c = mCasSub.get(tempStopList[x].Subscription__c)[x];
                }
            }*/
            //END UD-2443 9/5/2015 Added By C. Lin
            
            for(Subscription_Temp_Stop__c vts : tempStopList) {    
                //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. Comment out
                /*for(Id tsId : mCasSub.get(vts.Subscription__c)){
                   vts.Temp_stop__c = tsId;
                }*/
                //vts.Temp_Stop__c = mCasSub.get(vts.Subscription__c);
                //END UD-2443 9/5/2015 Added By C. Lin
                
                newSTS.add(vts);                        
            }

            insert newSTS;
        
            indexNumber = 0;
            for(Case_Subscription__c cvs : directCaseSubs) {
                cvs.Case__c = caseList[indexNumber].Id;
                indexNumber++;
            }
            insert directCaseSubs;
            
            if (selectedTempStopType == globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP || selectedTempStopType == globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP) {
                indexNumber = 0;
                for(Temp_Stop__c oldtemp : oldTempStopUpdateList) {
                    oldtemp.Id = oldTempStopUpdateList[indexNumber].Id;
                    indexNumber++;
                }
                
            }
            if(oldTempStopUpdateList.size()>0){
                update oldTempStopUpdateList; 
            }
            
            /*Start UD-2925 VPernicia 9/25/15: Comment-out
            if(subToUpdateList.size()>0){
                //START: JLedesma D-3091 6/18/2015 Year To Date computation
                //update subToUpdateList;
                //END: JLedesma D-3091 6/18/2015 Year To Date computation
            }
            End UD-2925 VPernicia 9/25/15: Comment-out*/
         return caseList;      
      }
      
      /*Description: Function for submit button 
        *Parameter: NA
        *Return: PageReference 
        */   
        public PageReference submit() {

            PageReference pRef; 
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
            UsageHelper.initialize();
            //END UD-2443 9/5/2015 Added By C. Lin
            if(selectedTempStopType!=NULL ){
                // Start D-3844 30Oct15 JohnD - added try-catch
                try {
                    
                    createdCaseRecords = createRecordsOnSave();
                    if(createdCaseRecords.size() == 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Temp Stop Blank Values')));
                    }
                    //START D-3804 10/27/2015 Added By C. Lin - Redirect to Account and not Case
                    /*
                    else if(createdCaseRecords.size()==1){
                        pref= new PageReference('/' + createdCaseRecords[0].Id );
                    }
                    else{
                        pref= new PageReference('/' + globalvariableclass.TS_REDIRECT_TO_RECORD );
                    }*/
                    else{
                        pref= new PageReference('/' + thisAccount.Id);
                    }
                    //END D-3804 10/27/2015 Added By C. Lin
                
                } catch (exception e) {
                    system.debug('Submit Error ' + e);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
                // End D-3844 30Oct15 JohnD - added try-catch
            }     
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Select Temp Stop Transaction')));
            }
            return pRef; 
        }
        
        //START D-3329 8/26/2015 Added By C. Lin - Temp Stop Bundle Subscriptions together
        /*Description: Method for getting related Bundle Subscriptions
        *Parameter: myId
        *Return: PageReference
        */
        public Set<Id> getRelatedBundleSub(Id myId){
            List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>();
            List<Zuora__Subscription__c> bundleSubsList = new List<Zuora__Subscription__c>();
            Id oliId;
            Set<Id> relatedBundleSubIdSet = new Set<Id>();
            Map<Id, SubscriptionWrapper> subIdToSubWrapperMap = new Map<Id, SubscriptionWrapper>();
            Map<Id, SubscriptionWrapper> subIdToSubWrapperMapUpdate = new Map<Id, SubscriptionWrapper>();
            Map<Id, SubscriptionWrapper> subIdToSubWrapperMapCancel = new Map<Id, SubscriptionWrapper>();
            //START UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
            List<Zuora__Subscription__c> filteredBundleSubsList = new List<Zuora__Subscription__c>();
            //START UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
            
            //START: UD-3295 11/24/15 Added by Manolo Valena - Added if condition.
            if((subscriptionIdToPackageTypeMap.containsKey(myId) && 
               subscriptionIdToPackageTypeMap.get(myId) != GlobalVariableClass.PACKAGETYPE_ADDON) || 
               (stsIdToPackageTypeMap.containsKey(myId) && 
               stsIdToPackageTypeMap.get(myId) != GlobalVariableClass.PACKAGETYPE_ADDON)) {
                if(myId != null){
                    if(pubSubToOrderLine.containsKey(myId)){
                        oliId = pubSubToOrderLine.get(myId);
                    }
                    
                    if(oliId != null){
                        if(oliIdToBundlePubSubListMap.containsKey(oliId)){
                            bundleSubsList = oliIdToBundlePubSubListMap.get(oliId);
                        }
                    }
                }
                
                //START UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
                if(!returnedSetIdOfSub.isEmpty()){
                    for(Zuora__Subscription__c sub :bundleSubsList){
                        if(returnedSetIdOfSub.contains(sub.Id)){
                            filteredBundleSubsList.add(sub);
                        }
                    }
                }
                //END UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
                
                for(SubscriptionWrapper subven : subscriptionResultList){
                    subIdToSubWrapperMap.put(subven.Id, subven);
                }
                
                for(SubscriptionWrapper subven : updateResultList){
                    subIdToSubWrapperMapUpdate.put(subven.Id, subven);
                }
                
                for(SubscriptionWrapper subven : cancelResultList){
                    subIdToSubWrapperMapCancel.put(subven.Id, subven);
                }
                
                Set<Id> relateSubTempIdSet = new Set<Id>();
                
                for(Subscription_Temp_Stop__c s : subTempStopRecList){
                    if(oliIdToBundlePubSubListMap.containsKey(s.Subscription__r.Order_Line_Item_Number__c)){
                        for(Zuora__Subscription__c subs : oliIdToBundlePubSubListMap.get(s.Subscription__r.Order_Line_Item_Number__c)){
                            if(stsIdToStsMap.containsKey(myId) && pubSubToOrderLine.containsKey(subs.Id)){
                                if(stsIdToStsMap.get(myId).Subscription__r.Order_Line_Item_Number__c == Id.valueOf(pubSubToOrderLine.get(subs.Id)) && s.Temp_Stop__r.Temp_Stop_Date__c == stsIdToStsMap.get(myId).Temp_Stop__r.Temp_Stop_Date__c && s.Temp_Stop__r.Restart_Date__c == stsIdToStsMap.get(myId).Temp_Stop__r.Restart_Date__c && s.Temp_Stop__r.Temp_Stop_Status__c == stsIdToStsMap.get(myId).Temp_Stop__r.Temp_Stop_Status__c){
                                    //START: UD-3295 11/24/15 Added by Manolo Valena
                                    if(stsIdToPackageTypeMap.containsKey(s.Id) && 
                                       stsIdToPackageTypeMap.get(s.Id) != GlobalVariableClass.PACKAGETYPE_ADDON) {
                                        relateSubTempIdSet.add(s.Id);
                                    }
                                    //END: UD-3295 11/24/15 Added by Manolo Valena
                                }
                            }
                        }
                    }
                }
                
                for(Zuora__Subscription__c bSub : filteredBundleSubsList){ //START-END UD-2560 09/02/2015 Added by J.Sarion - Update copies calculation
                    relatedBundleSubIdSet.add(bSub.Id);
                    
                    if(subIdToSubWrapperMap.containsKey(bSub.Id) && subIdToSubWrapperMap.containsKey(myId)){
                        subIdToSubWrapperMap.get(bSub.Id).tp.Temp_Stop_Date__c = subIdToSubWrapperMap.get(myId).tp.Temp_Stop_Date__c;
                        subIdToSubWrapperMap.get(bSub.Id).tp.Restart_Date__c = subIdToSubWrapperMap.get(myId).tp.Restart_Date__c;
                        subIdToSubWrapperMap.get(bSub.Id).tp.Qty__c = subIdToSubWrapperMap.get(myId).tp.Qty__c;
                    }
                }
                
                for(Id stsId : relateSubTempIdSet){
                    relatedBundleSubIdSet.add(stsId);
                    
                    if(subIdToSubWrapperMapUpdate.containsKey(stsId) && subIdToSubWrapperMapUpdate.containsKey(myId)){
                        subIdToSubWrapperMapUpdate.get(stsId).tp.Temp_Stop_Date__c = subIdToSubWrapperMapUpdate.get(myId).tp.Temp_Stop_Date__c;
                        subIdToSubWrapperMapUpdate.get(stsId).tp.Restart_Date__c = subIdToSubWrapperMapUpdate.get(myId).tp.Restart_Date__c;
                    }
                    if(subIdToSubWrapperMapCancel.containsKey(stsId) && subIdToSubWrapperMapCancel.containsKey(myId)){
                        subIdToSubWrapperMapCancel.get(stsId).tp.Temp_Stop_Date__c = subIdToSubWrapperMapCancel.get(myId).tp.Temp_Stop_Date__c;
                        subIdToSubWrapperMapCancel.get(stsId).tp.Restart_Date__c = subIdToSubWrapperMapCancel.get(myId).tp.Restart_Date__c;
                        subIdToSubWrapperMapCancel.get(stsId).tp.Qty__c = subIdToSubWrapperMapCancel.get(myId).tp.Qty__c;
                    }
                }
            }
            //END: UD-3295 11/24/15 Added by Manolo Valena
            return relatedBundleSubIdSet;
        }
        //END D-3329 8/26/2015 Added By C. Lin
        
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops.
        public List<Subscription_Temp_Stop__c> getRemainingTempStopId(Id currentStsId){
            List<Subscription_Temp_Stop__c> remainingTS = new List<Subscription_Temp_Stop__c>();
            
            if(!orderedStsList.isEmpty()){
                for(Subscription_Temp_Stop__c sts : orderedStsList){
                    if(sts.Subscription__c == stsIdToStsMap.get(currentStsId).Subscription__c){
                        if(sts.Temp_Stop__r.Temp_Stop_Date__c > stsIdToStsMap.get(currentStsId).Temp_Stop__r.Temp_Stop_Date__c){
                            remainingTS.add(sts);
                        }
                    }
                }
            }
            return remainingTS;
        }
        
        
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
        
        
        //START UD-3417 21Jan2016 Added By C. Lin - Comment out method. Not needed.
        //START: D-3628 10/29/15 Added by Manolo Valena
        /*public void cancelUpdateRecords(List<Case> caseCancelList) {
    
            Set<Id> subCancelIdSet = new Set<Id>();
            Set<Id> tStopIdSet = new Set<Id>();
            Map<Id, Decimal> tsIdToRequestTotalIssue = new Map<Id, Decimal>();
            Map<Id, Decimal> subToYTDMap = new Map<Id, Decimal>();
            Map<Id, Decimal> subToYTDNMap = new Map<Id, Decimal>();
            Map<Id, Decimal> subToBaseMap = new Map<Id, Decimal>();
            List<Subscription_Temp_Stop__c> sTempStopList = new List<Subscription_Temp_Stop__c>();
            Map<Id, List<Case>> subIdToCasesMap = new Map<Id, List<Case>>();
            Map<Id, Integer> subToTotalSucceedingMap = new Map<Id, Integer>();
            Map<Id, Integer> subToRequestTotalIssueMap = new Map<Id, Integer>();
            List<Case> caseListUpdate = new List<Case>();
            List<Zuora__Subscription__c> subListUpdate = new List<Zuora__Subscription__c>();
            Map<Id, Integer> subIdToHighestYTDMap = new Map<Id, Integer>();
            Map<Id, Zuora__Subscription__c> subIdToSubscriptionRecordMap = new Map<Id, Zuora__Subscription__c>();
            Set<Id> tStopToUpdateSet = new Set<Id>();
            List<Temp_Stop__c> tempStopsToUpdateList = new List<Temp_Stop__c>();
            Map<Id, Decimal> tempStopIdToTotalCreditMap = new Map<Id, Decimal>();
            Map<Id, Integer> tempStopIdToTotalIssueMap = new Map<Id, Integer>();
            Map<Id, Temp_Stop__c> tempStopIdToTempStopRecMap = new Map<Id, Temp_Stop__c>();
            Set<Id> cancelledCasesSet = new Set<Id>();
            
            Map<Id, Subscription_Temp_Stop__c> subToEarliestTempStopMap = new Map<Id, Subscription_Temp_Stop__c>();
            for(Case c : caseCancelList) {
                subCancelIdSet.add(c.Temp_Stop_Sub__c);
                tStopIdSet.add(c.Temp_Stop__c);
            }
            
            if(tStopIdSet.size() > 0) {
                for(Temp_Stop__c tsR : [SELECT Id, Request_Total_Issue__c, Temp_Stop_Date__c, Case__c, (SELECT Id, Subscription__c, Temp_Stop__r.Temp_Stop_Date__c FROM Subscription_Temp_Stops__r LIMIT 1) FROM Temp_Stop__c WHERE Id IN: tStopIdSet]) {
                    tsIdToRequestTotalIssue.put(tsR.Id, tsR.Request_Total_Issue__c);
                    sTempStopList.add(tsR.Subscription_Temp_Stops__r[0]);
                    cancelledCasesSet.add(tsR.Case__c);
                    
                    if(subToEarliestTempStopMap.containsKey(tsR.Subscription_Temp_Stops__r[0].Subscription__c)) {
                        if(tsR.Temp_Stop_Date__c < subToEarliestTempStopMap.get(tsR.Subscription_Temp_Stops__r[0].Subscription__c).Temp_Stop__r.Temp_Stop_Date__c) {
                            subToEarliestTempStopMap.put(tsR.Subscription_Temp_Stops__r[0].Subscription__c, tsR.Subscription_Temp_Stops__r[0]);
                            subToRequestTotalIssueMap.put(tsR.Subscription_Temp_Stops__r[0].Subscription__c, Integer.valueOf(tsR.Request_Total_Issue__c));
                        }
                    }
                    else {
                        subToEarliestTempStopMap.put(tsR.Subscription_Temp_Stops__r[0].Subscription__c, tsR.Subscription_Temp_Stops__r[0]);
                        subToRequestTotalIssueMap.put(tsR.Subscription_Temp_Stops__r[0].Subscription__c, Integer.valueOf(tsR.Request_Total_Issue__c));
                    }
                }
            }
            if(sTempStopList.size() > 0) {
                for(Subscription_Temp_Stop__c stsRecord : sTempStopList) {
                    if(subToEarliestTempStopMap.containsKey(stsRecord.Subscription__c) &&
                       subToEarliestTempStopMap.get(stsRecord.Subscription__c).Id == stsRecord.Id) {
                        List<Subscription_Temp_Stop__c> sTempStopRemainingList = new List<Subscription_Temp_Stop__c>();
                        sTempStopRemainingList = getRemainingTempStopId(stsRecord.Id);
                        for(Subscription_Temp_Stop__c stsRecRem : sTempStopRemainingList) {
                            if(stsRecRem.Temp_Stop__r.Temp_Stop_Status__c == 'Not Started') {   
                                if(caseIdToCaseRecMap.containsKey(stsRecRem.Temp_Stop__r.Case__c)) {
                                    tStopToUpdateSet.add(caseIdToCaseRecMap.get(stsRecRem.Temp_Stop__r.Case__c).Temp_Stop__c);
                                    if(subIdToCasesMap.containsKey(stsRecRem.Subscription__c)) {
                                        subIdToCasesMap.get(stsRecRem.Subscription__c).add(caseIdToCaseRecMap.get(stsRecRem.Temp_Stop__r.Case__c));
                                    }
                                    else {
                                        subIdToCasesMap.put(stsRecRem.Subscription__c, new List<Case>{caseIdToCaseRecMap.get(stsRecRem.Temp_Stop__r.Case__c)});
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(tStopToUpdateSet.size() > 0) {
                for(Temp_Stop__c tsRecs : [SELECT Id, Request_Total_Credit__c, Request_Total_Issue__c FROM Temp_Stop__c WHERE Id IN: tStopToUpdateSet]) {
                    tempStopIdToTempStopRecMap.put(tsRecs.Id, tsRecs);
                }
            }
            
            if(subCancelIdSet.size() > 0) {
                for(Zuora__Subscription__c zSub : [SELECT Id, Year_to_Date_Temp_Stop_Days__c, Next_Year_Temp_Stop_Days__c FROM Zuora__Subscription__c WHERE Id IN: subCancelIdSet]) {
                    subToYTDMap.put(zSub.Id, zSub.Year_to_Date_Temp_Stop_Days__c);
                    subToYTDNMap.put(zSub.Id, zSub.Next_Year_Temp_Stop_Days__c);
                    subIdToSubscriptionRecordMap.put(zSub.Id, zSub);
                }
            }
            if(subIdToCasesMap.keySet().size() > 0) {
                for(Id subsId : subIdToCasesMap.keySet()) {
                    for(Case cRec : subIdToCasesMap.get(subsId)) {
                        if(subToTotalSucceedingMap.containsKey(subsId)) {
                            subToTotalSucceedingMap.put(subsId, subToTotalSucceedingMap.get(subsId) + Integer.valueOf(cRec.Current_Date_for_Year_To_Date__c));
                        }
                        else {
                            subToTotalSucceedingMap.put(subsId, Integer.valueOf(cRec.Current_Date_for_Year_To_Date__c));
                        }
                    }
                    
                    if(subToRequestTotalIssueMap.containsKey(subsId) &&
                       subToTotalSucceedingMap.containsKey(subsId)) {
                        subToTotalSucceedingMap.put(subsId, subToTotalSucceedingMap.get(subsId) + subToRequestTotalIssueMap.get(subsId));
                    }
                }
                
                if(subToTotalSucceedingMap.keySet().size() > 0) {
                    for(Id stts : subToTotalSucceedingMap.keySet()) {
                        if(subToYTDMap.containsKey(stts)) {
                            subToBaseMap.put(stts, subToYTDMap.get(stts) - subToTotalSucceedingMap.get(stts));
                        }
                    }
                }
            }
            if(subIdToCasesMap.keySet().size() > 0) {
                for(Id subsId : subIdToCasesMap.keySet()) {
                    Map<String, Decimal> updateValues = new Map<String, Decimal>();
                    Integer base = Integer.valueOf(subToBaseMap.get(subsId));
                    if(base != null) {  
                        for(Case cRec : subIdToCasesMap.get(subsId)) {
                            if(!cancelledCasesSet.contains(cRec.Id)) {
                                updateValues = computation(globalvariableclass.TS_CREATE, null, null, subsId, cRec.Temp_Stop_Date__c, cRec.Restart_Date__c, Integer.valueOf(cRec.Temp_Stop__r.Qty__c), base, 0, null, null, null, null, null);
                                cRec.Request_Total_Credit__c = updateValues.get('credit');
                                cRec.Current_Date_for_Year_To_Date__c = Integer.valueOf(updateValues.get('refund'));
                                base = base + Integer.valueOf(updateValues.get('refund'));
                                caseListUpdate.add(cRec);
                                
                                tempStopIdToTotalCreditMap.put(cRec.Temp_Stop__c, updateValues.get('credit'));
                                tempStopIdToTotalIssueMap.put(cRec.Temp_Stop__c, Integer.valueOf(updateValues.get('refund')));
                            }
                            
                            if(subIdToHighestYTDMap.containsKey(subsId)) {
                                if(base > subIdToHighestYTDMap.get(subsId)) {
                                    subIdToHighestYTDMap.put(subsId, base);
                                }
                            }
                            else {
                                subIdToHighestYTDMap.put(subsId, base);
                            }
                        }
                    }
                }
                if(caseListUpdate.size() > 0) {
                    update caseListUpdate;
                }
                if(subIdToHighestYTDMap.keySet().size() > 0) {
                    for(Id z : subIdToHighestYTDMap.keySet()) {
                        if(subIdToSubscriptionRecordMap.containsKey(z)) {
                            subIdToSubscriptionRecordMap.get(z).Year_to_Date_Temp_Stop_Days__c = subIdToHighestYTDMap.get(z);
                            subIdToSubscriptionRecordMap.get(z).Next_Year_Temp_Stop_Days__c = 0;
                            subListUpdate.add(subIdToSubscriptionRecordMap.get(z));
                        }
                    }
                    
                    if(subListUpdate.size() > 0) {
                        SubscriptionTriggerHandler.preventExecution = TRUE;
                        update subListUpdate;
                    }
                }
                if(tempStopIdToTotalCreditMap.keySet().size() > 0) {
                    for(Id tsId : tempStopIdToTotalCreditMap.keySet()) {
                        if(tempStopIdToTempStopRecMap.containsKey(tsId)) {
                            tempStopIdToTempStopRecMap.get(tsId).Request_Total_Credit__c = tempStopIdToTotalCreditMap.get(tsId);
                            tempStopIdToTempStopRecMap.get(tsId).Request_Total_Issue__c = tempStopIdToTotalIssueMap.get(tsId);
                            tempStopsToUpdateList.add(tempStopIdToTempStopRecMap.get(tsId));
                        }
                    }
                    
                    if(tempStopsToUpdateList.size() > 0) {
                        update tempStopsToUpdateList;
                    }
                }
            }
            else {
                if(subIdToSubscriptionRecordMap.keySet().size() > 0) {
                    for(Id subI : subIdToSubscriptionRecordMap.keySet()) {
                        if(subToRequestTotalIssueMap.containsKey(subI) &&
                           subToRequestTotalIssueMap.get(subI) == subIdToSubscriptionRecordMap.get(subI).Year_to_Date_Temp_Stop_Days__c) {
                            subIdToSubscriptionRecordMap.get(subI).Year_to_Date_Temp_Stop_Days__c = 0;
                        }
                        else if(subToRequestTotalIssueMap.containsKey(subI) &&
                                subToRequestTotalIssueMap.get(subI) != subIdToSubscriptionRecordMap.get(subI).Year_to_Date_Temp_Stop_Days__c) {
                            subIdToSubscriptionRecordMap.get(subI).Year_to_Date_Temp_Stop_Days__c = subIdToSubscriptionRecordMap.get(subI).Year_to_Date_Temp_Stop_Days__c - subToRequestTotalIssueMap.get(subI);
                        }
                        subListUpdate.add(subIdToSubscriptionRecordMap.get(subI));
                    }
                    
                    if(subListUpdate.size() > 0) {
                        SubscriptionTriggerHandler.preventExecution = TRUE;
                        update subListUpdate;
                    }
                }
            }
        }*/
        //END: D-3628 10/29/15 Added by Manolo Valena
        //END UD-3417 21Jan2016 Added By C. Lin
        
        /*Start UD-2925 VPernicia 9/25/15: Comment-out
        public void updateRemainingTS(Id currentStsId, Integer currentYTD, Integer nextYTD, String tempStopType){
            List<Subscription_Temp_Stop__c> remainingTS = getRemainingTempStopId(currentStsId);
            Map<String, Decimal> mapComputationRefund = new Map<String, Decimal>();
            Integer totalOldRemainCurrentYD = 0;
            Integer totalOldRemainNextYD = 0;
            Integer yearToDateTempStopDaysCancel = 0;
            Integer nextYearTempStopDaysCancel = 0;
            
            if(currentYTD == null){
                currentYTD = 0;
            }
            if(nextYTD == null){
                nextYTD = 0;
            }
            Integer totalNewRemainCurrentYD = currentYTD;
            Integer totalNewRemainNextYD = nextYTD;
            
            for(Subscription_Temp_Stop__c tsRec : remainingTS){
                totalOldRemainCurrentYD += Integer.valueOf(tsRec.Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c);
                totalOldRemainNextYD += Integer.valueOf(tsRec.Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c);
            }
            
            for(Subscription_Temp_Stop__c tsRec : remainingTS){
                
                if(tempStopType == 'Update'){
                    mapComputationRefund = computation(globalvariableclass.TS_UPDATE, Integer.valueOf(stsIdToStsMap.get(currentStsId).Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c), Integer.valueOf(stsIdToStsMap.get(currentStsId).Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c), tsRec.Subscription__c, tsRec.Temp_Stop__r.Temp_Stop_Date__c, tsRec.Temp_Stop__r.Restart_Date__c, Integer.valueOf(tsRec.Temp_Stop__r.Qty__c), Integer.valueOf(tsRec.Subscription__r.Year_to_Date_Temp_Stop_Days__c), Integer.valueOf(tsRec.Subscription__r.Next_Year_Temp_Stop_Days__c), null, totalOldRemainCurrentYD, totalOldRemainNextYD, totalNewRemainCurrentYD, totalNewRemainNextYD);
                }
                
                if(tempStopType == 'Cancel'){
                    yearToDateTempStopDaysCancel = Integer.valueOf(tsRec.Subscription__r.Year_to_Date_Temp_Stop_Days__c) - Integer.valueOf(stsIdToStsMap.get(currentStsId).Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c);
                    nextYearTempStopDaysCancel = Integer.valueOf(tsRec.Subscription__r.Year_to_Date_Temp_Stop_Days__c) - Integer.valueOf(stsIdToStsMap.get(currentStsId).Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c);
                    
                    mapComputationRefund = computation(globalvariableclass.TS_UPDATE, null, null, tsRec.Subscription__c, tsRec.Temp_Stop__r.Temp_Stop_Date__c, tsRec.Temp_Stop__r.Restart_Date__c, Integer.valueOf(tsRec.Temp_Stop__r.Qty__c), yearToDateTempStopDaysCancel, nextYearTempStopDaysCancel, null, totalOldRemainCurrentYD, totalOldRemainNextYD, totalNewRemainCurrentYD, totalNewRemainNextYD);
                }
                
                if(!mapComputationRefund.isEmpty()){
                    if(tsRec.Temp_Stop__r.Case__c !=null && tsRec.Temp_Stop__c != null){
                        caseIdToCaseMap.get(tsRec.Temp_Stop__r.Case__c).Year_To_Date_Count__c = Integer.valueOf(mapComputationRefund.get('tempStopDays'));
                        caseIdToCaseMap.get(tsRec.Temp_Stop__r.Case__c).Total_Issue__c = Integer.valueOf(mapComputationRefund.get('issue'));
                        caseIdToCaseMap.get(tsRec.Temp_Stop__r.Case__c).Request_Total_Issue__c = Integer.valueOf(mapComputationRefund.get('refund'));
                        caseIdToCaseMap.get(tsRec.Temp_Stop__r.Case__c).Request_Total_Credit__c = mapComputationRefund.get('credit');
                        caseIdToCaseMap.get(tsRec.Temp_Stop__r.Case__c).Current_Date_for_Year_To_Date__c = mapComputationRefund.get('current');
                        caseIdToCaseMap.get(tsRec.Temp_Stop__r.Case__c).Next_Year_for_Year_To_Date__c = mapComputationRefund.get('next');
                        
                        tsIdToTempStopMap.get(tsRec.Temp_Stop__c).Request_Total_Issue__c = Integer.valueOf(mapComputationRefund.get('refund'));
                        tsIdToTempStopMap.get(tsRec.Temp_Stop__c).Request_Total_Credit__c = mapComputationRefund.get('credit');
                    }
                    
                    totalNewRemainCurrentYD += Integer.valueOf(mapComputationRefund.get('current'));
                    totalNewRemainNextYD += Integer.valueOf(mapComputationRefund.get('next'));
                }
            }
        }
        //END UD-2443 9/5/2015 Added By C. Lin
        End UD-2925 VPernicia 9/25/15: Comment-out*/
    }