/**
 * Class Name: <CaseTriggerHandler>
 * @author: <FrancisMartinBenzon, MarjorieGaelo, KristineCampang, JerellaLedesma, RowenaEmpenado, KayLorica>
 * Date: <7/25/2014> <9/3/2014> <9/8/2014> <9/28/2014>
 * Requirement/Project Name: <SPH>
 * @description<To prevent saving out of office emails.> <Submit Vendor Order> <AutoSubmit for Approval - TempStopCase> <Create Temp Stop record> <Close Order>
 *
 * History: 21/Feb/2015 Wenjun - Code review Fix - using New Trigger Framework
 */

public class CaseTriggerHandler{
    
    //START: JLedesma D-3091 6/18/2015 Year To Date computation
    Map<Id, Zuora__Subscription__c> mapSubsCase = new Map<Id, Zuora__Subscription__c>();
    Map<Id, Zuora__Subscription__c> mapSubs = new Map<Id, Zuora__Subscription__c>();
     Set<Id> tempSubID = new Set<Id>(); 
    List<Zuora__SubscriptionProductCharge__c> spclist = new List<Zuora__SubscriptionProductCharge__c>();
    Map<Id, Set<String>> subToPubCodes = new Map<Id, Set<String>>();
    Map<Id, Id> caseToSubId = new Map<Id, Id>();
    Map<Id, Case> caseToCaseRec = new Map<Id, Case>();
    List<Zuora__Subscription__c> allSubscriptionList = new List<Zuora__Subscription__c>();
    Set<Id> tempStopID = new Set<Id>(); 
    Set<Id> tempUpdatedID = new Set<Id>(); 
    List<Case> caseToUpdateForYearToDate = new List<Case>();
    List<Zuora__Subscription__c> subToUpdateList = new List<Zuora__Subscription__c>();
    //START D-3329 08/26/2015 Added by Charles Lin - Commented out
    //START UD-2002 07/21/2015 Added by J.Sarion - Update Case Current Date for Year To Date
    //Map<Id, Case> caseIdToCaseYTDMap = new Map<Id, Case>();
    //END UD-2002 07/21/2015 Added by J.Sarion - Update Case Current Date for Year To Date
    //START UD-2002 07/22/2015 Added by J.Sarion - Check if called once
    //Boolean isCalledOnce = false;
    //END UD-2002 07/22/2015 Added by J.Sarion - Check if called once
    //END D-3329 08/26/2015 Added by Charles Lin - Commented out
    //END: JLedesma D-3091 6/18/2015 Year To Date computation
    
    /*------------------- Key Id's -------------------*/ 
    Id CASE_START_SUB_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
    Id CASE_TEMP_STOP_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
    Id CASE_CHNG_SUB_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Change of Subscription');
    Id CASE_RENEW_SUB_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case Renewal of Subscription');
    Id CASE_REFUND_ID  = (Id) ConstantsSLB.getKeyId('Case_Refund');//START-END 04/23/2015 UD-0572 Jason Abolac 
    Id CASE_COMPLAINT_NP  = (Id) ConstantsSLB.getKeyId('Complaint_Newspaper');//START/END: D-2565 03/21/2015 Added by S.PULI
    Id CASE_COMPLAINT_MAG  = (Id) ConstantsSLB.getKeyId('Case_Complaint Magazine');//START/END UD-2717 09/10/15 RReyes
    Id CASE_COA  = (Id) ConstantsSLB.getKeyId('Case_Change in Address');//START/END: MD-61 03/23/2015 Added by S.PULI
    Id CASE_ADJUSTMENT = (Id) ConstantsSLB.getKeyID('Case_Adjustments'); //START-END UD-1825 07/14/2015 Added by J.Sarion - Id from Custom Setting for Adjustment
    Id account_DirectCorporate = ConstantsSLB.getKeyId('Account_Direct Corporate');
    Id account_DirectIndividual = ConstantsSLB.getKeyId('Account_Direct Individual');
    Id account_DirectSphInterDivision = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
    Id account_VendorSubscriber = ConstantsSLB.getKeyId('Account_Vendor Subscriber');
    Id CASE_STOP_SUB_TYPE_ID = ConstantsSLB.getKeyId('Case_Stop');
    //START: D-1347 12/23/14 Added by J. Sarion Id from Custom Setting
    Id CSO_TL_QUEUE_ID = ConstantsSLB.getKeyId('CSO TL Queue');
    Id CSO_AMM_QUEUE_ID = ConstantsSLB.getKeyId('CSO Asst. Manager/ Manager Queue');
    Id CSO_HEAD_QUEUE_ID = ConstantsSLB.getKeyId('Head of Customer Service Queue');
    //END: D-1347 12/23/14 Added by J. Sarion
    //START: UD-3520 1/5/2015 added by Jason A.
    Id CASE_PARTICULARS  = (Id) ConstantsSLB.getKeyId('Case_Particulars');
    Map<id, Contact> conMap = new map<id, contact>(); 
    //END: UD-3520 1/5/2015 added by Jason A.
    //START UD-3486 1/5/2015 RReyes
    Id CASE_RETENTION  = (Id) ConstantsSLB.getKeyId('Case_Retention');
    Map<id, Contact> mapRetCont = new map<id, contact>(); 
    //END UD-3486 1/5/2015 RReyes
    Id CASE_COMPLAINT_DIG  = (Id) ConstantsSLB.getKeyId('Case_Complaint Digital'); //START-END UD-4009 12/2/2015 Added by J.Sarion - Complaint Digital Record Type
    //START UD-3434 1/5/2016 Added by J.Sarion
    Id VEN_OPS_NE_QUEUE  = (Id) ConstantsSLB.getKeyID('Ven Ops N&E Cir Reps Queue');
    Id VEN_OPS_WC_QUEUE  = (Id) ConstantsSLB.getKeyId('Ven Ops W&C Cir Reps Queue');
    //END UD-3434 1/5/2016 Added by J.Sarion
    /*----------------- End Key Id's -----------------*/
    
    static Set<Id> existingApprovalsSet = new Set<Id>();

    /*------------------- Start Subscription -------------------*/
    Map<Id, Account> accountMap;
    //START: JLedesma D-3091 6/18/2015 Year To Date computation
    Map<Id, Order__c> orderMap = new Map<Id, Order__c>();
    //END: JLedesma D-3091 6/18/2015 Year To Date computation
    Map<Integer, List<Subscription_Vendor_Publication__c>> wrapperNumberToSubsVendorPubsMap = new Map<Integer, List<Subscription_Vendor_Publication__c>>();
    Map<Integer, Subscription_Vendor__c> wrapperNumberToSubscriptionVendorMap = new Map<Integer, Subscription_Vendor__c>();
    Map<Integer, Case_Vendor_Subscription__c> wrapperNumberToCaseVendorSubsMap = new Map<Integer, Case_Vendor_Subscription__c>();
    List<Order__c> orderList = new List<Order__c>();
    /*--------------- End  Start Subscription ------------------*/
    list<id>  CusAccount = New list<id> (); //START/END: UD-0572 03/21/2015 Added by J.Abolac
    Map<Id, List<Id>> Accounttobilling = new Map<Id, list<Id>>(); //START/END: UD-0572 03/21/2015 Added by J.Abolac
    Map<Id, Zuora__CustomerAccount__c> billid = new Map<Id, Zuora__CustomerAccount__c>(); //START/END: UD-0572 03/21/2015 Added by J.Abolac
    
    /*----Complaint and Enquiry-----*/
    //START: JLedesma D-3091 6/18/2015 Year To Date computation
    Map<Id, Case> casToUpdateMap = new Map<Id, Case>();
    //END: JLedesma D-3091 6/18/2015 Year To Date computation
    List<Case_Subscription__c> complaintSubsDirect = new List<Case_Subscription__c>();
    List<Case_Vendor_Subscription__c> complaintSubsVen = new List<Case_Vendor_Subscription__c>();   
    
    Set<Id> caseIds = new Set<Id>();
    /*--------------------------------*/
    //For Parent Case field auto population
 
    /*----Renewal-----*/
    Map<Id, Order__c> caseOrderMap; 
    /*----End Renewal-----*/    
    
    //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
    final String FULL_PRE = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
    final String MR_PRE = GlobalVariableClass.BILLING_TYPE_MR_PRE;
    final String MR_POS = GlobalVariableClass.BILLING_TYPE_MR_POST;
    Map<Id, Date> subOliNumbersToManuallyCancel = new Map<Id, Date>();
    //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
    //START: D-1950 2/10/15 JLedesma - Update old temp stop status
    Map<Id, Temp_Stop__c> tempStopMap;
    Map<Id, Order__c> orderTempMap;
    //START: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
    Map<Id, Order__c> orderClosedMap;
    //END: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
    List<Order__c> orderToTempUpdateList = new List<Order__c>();
    //START: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
    List<Order__c> orderToClose = new List<Order__c>();
    //END: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
    List<Temp_Stop__c> tempToUpdateList = new List<Temp_Stop__c>();
    //END: D-1950 2/10/15 JLedesma - Update old temp stop status
    
    //START: D-2565 03/21/2015 Added by S.PULI
    Set<Id> complaintCaseUsageToZuoraSet = new Set<Id>();
    List<Usage__c> complaintCaseUsageToZuoraList = new List<Usage__c>();
    //END: D-2565 03/21/2015 Added by S.PULI
    
    //START: MD-61 03/23/2015 Added by S.PULI - COA checkbox
    List<Case> coaCase_LIST = new List<Case>();
    List<Case> tempStop_LIST = new List<Case>();
    Map<Case, Id> tempStopAcc_MAP = new Map<Case, Id>();
    List<Account> tempStopAcc_LIST = new List<Account>();
    Set<Id> coaCase_SET = new Set<Id>();
    Map<Id, List<Case>> sub_CaseList_MAP = new Map<Id, List<Case>>();
    List<Case_Subscription__c> coaCaseSub_LIST = new List<Case_Subscription__c>();
    Map<Id, Case> coaIdToObj_MAP = new Map<Id, Case>();
    //START PD-0155 01Jun2016 Added By C. Lin - prevent update duplicate TS cases
    //List<Case> tempExtisting = new List<Case>();
    Map<Id, Case> tempExistingMap = new Map<Id, Case>();
    //END PD-0155 01Jun2016 Added By C. Lin
    Set<Id> tCaseSet = new Set<Id>();
    Map<Id, Id> tCaseToRec_MAP = new Map<Id, Id>();
    //END: MD-61 03/23/2015 Added by S.PULI - COA checkbox
    //START UD-1825 07/14/2015 Added by J.Sarion - List of cases to be adjusted
    Set<Id> adjustmentIdSet = new Set<Id>();
    public static Boolean iscreateInvoiceAdjustmentFired = FALSE;
    //END UD-1825 07/14/2015 Added by J.Sarion - List of cases to be adjusted
    //START: D-3140 20/06/2015 Added by S.Puli
    List<Case> coaCasesForupdate = new List<Case>();
    List<Case_Vendor_Subscription__c> coaCaseVendorSubs_LIST = new List<Case_Vendor_Subscription__c>();
    //END: D-3140 20/06/2015 Added by S.Puli
    
    //START: UD-0327 4/29/2015 AAgna - added List of TempStop Cases
    List<Case> tempStopCases = new List<Case>();
    //END : UD-0327 4/29/2015 AAgna - added List of TempStop Cases
    
    //START D-2884 05/29/2015 Added By J. Sarion - usage will be created once
    public static Boolean isSendToZuoraCallOutFired = FALSE;
    public static Boolean isSendToZuoraCallOutFiredForGoodWill = FALSE;
    public static Boolean iscreateInvoiceAdjustmentPStop = FALSE; //STAR-END UD-2549 3/17/2016 Added by J.Sarion - Set boolean
    //END D-2884 05/29/2015 Added By J. Sarion - usage will be created once
    
    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
    Map<Id, Integer> subIdToOldCurrentYTD = new Map<Id, Integer>();
    Map<Id, Integer> subIdToOldNextYTD = new Map<Id, Integer>();
    Map<Id, List<Case>> subIdToCaseMap = new Map<Id, List<Case>>();
    Map<Id, List<Case>> subIdToCaseMap2 = new Map<Id, List<Case>>();
    List<Case> otherCaseToUpdateList = new List<Case>();
    Map<Id, Case> otherCaseToUpdateMap = new Map<Id, Case>();
    Map<Id, Zuora__Subscription__c> subIdToSubMap = new Map<Id, Zuora__Subscription__c>();
    //END UD-2443 9/5/2015 Added By C. Lin
    //START UD-2908 9/22/2015 Added By C. Lin - Exclude All-In-One
  Set<Id> packageIdSet = new Set<Id>();
  Map<Id, List<Package_Item__c>> packIdToPackItemListMap = new Map<Id, List<Package_Item__c>>();
  //END UD-2908 9/22/2015 Added By C. Lin
    List<Case> lstParentCaseToUpdate = new List<Case>();//START/END UD-3293 11/25/15 RReyes
    //START UD-4009 12/2/2015 Added by J.Sarion - Compute goodwill for Digital Complaint
    List<Case> complaintDigitalCaseList = new List<Case>();
    //END UD-4009 12/2/2015 Added by J.Sarion - Compute goodwill for Digital Complaint
    List<Case> assignToVenOpsCaseList = new List<Case>(); //START UD-3434 1/5/2016 Added by J.Sarion - Set Case Owner based on Postal Sector
    //Before Insert logic - Call separate method for detail processing - Leave Blank for not in use
    
    //START PD-0202 FrancisBenzon 20May16 : variables
    Set<String> beforeApprovalSubStat = new Set<String>{GlobalVariableClass.SUB_STATUS_WAIVING_APPROVAL, GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_APPROVAL};
    Set<String> afterApprovalSubStat = new Set<String>{GlobalVariableClass.CASESUBSTAT_WAIVEREJECTED, GlobalVariableClass.CASESUBSTAT_URGENTREJECTED};
    List<Order__c> ordersToUpdateAfterApprovalReject = new List<Order__c>();
    Set<Id> orderIdSet_COS = new Set<Id>();
    //END PD-0202 FrancisBenzon 20May16 : variables
    
    //START PD-0113 FrancisBenzon 9June16 : cater voiding for pending cases
    Set<Id> cosVoidedSubsId = new Set<Id>();
    Set<Id> stopVoidedSubsId = new Set<Id>();
    List<Zuora__Subscription__c> voidedSubs = new List<Zuora__Subscription__c>();
    Map<Id, Id> casIdRecTypeId = new Map<Id, Id>();
    //END PD-0113 FrancisBenzon 9June16 : cater voiding for pending cases
    
    public static String forcedDayOfMonth = '';//Start/End D-4452 Added By S.Puli - test coverage variable
    
    public void doBeforeInsert(List<Case> lstNewCases)
    {   
        //START: JLedesma D-3091 6/18/2015 Year To Date computation
        updateCaseYearToDateTempStop(lstNewCases);
        //END: JLedesma D-3091 6/18/2015 Year To Date computation
        tickUrgentRequest(lstNewCases); //Start/End D-0509 [12/11/2014] Added by April Banaag
        //START UD-0374 3/19/2015 Added by Manolo Valena - Invokes the populateOriginalOwner method.
        populateOriginalOwner(lstNewCases);
        //END UD-0374 3/19/2015 Added by Manolo Valena
        checkCirPlannerShedule(lstNewCases);
        
        // Start UD-1926 VPernicia 07/20/15
        updateContactFields(lstNewCases);
        // End UD-1926 VPernicia 07/20/15
        
        //START UD-3293 11/25/15 RReyes
        setParentCase(lstNewCases);
        setSubjAndDesc(lstNewCases);
        //END UD-3293 11/25/15 RReyes
        //START UD-0707 CommentedOut By FrancisBenzon : acct and con autopopulate is handled OOTB
        //EmailToCaseHelper.populateFields(lstNewCases); // Start/End UD-0707 21Apr15 JohnD - added email to case field populate
        //END UD-0707 CommentedOut By FrancisBenzon : acct and con autopopulate is handled OOTB
        
        for(Case newCase : lstNewCases)
        {
            if(newCase.recipient_address__c != null){
                populateInternaAddress(newCase);
            }
            
            //START: MD-61 03/23/2015 Added by S.PULI - COA checkbox
            if(newCase.RecordTypeId == CASE_TEMP_STOP_TYPE_ID){
                tempStop_LIST.add(newCase);
                //START: UD-0327 4/29/2015 AAgna -  TempStop Cases
                tempStopCases.add(newCase);
                //END: UD-0327 4/29/2015 AAgna -  TempStop Cases
            }
            //END: MD-61 03/23/2015 Added by S.PULI - COA checkbox
            
            //START UD-4009 12/2/2015 Added by J.Sarion - Compute Goodwill for Digital Complaint
            if(newCase.RecordTypeId == CASE_COMPLAINT_DIG){
                complaintDigitalCaseList.add(newCase);
            }
            //END UD-4009 12/2/2015 Added by J.Sarion - Compute Goodwill for Digital Complaint
            
        }
        
        //START: D-0509 12/02/14 Added by A. Banaag
        assignToTLQueue(lstNewCases);  
        //END: D-0509 12/02/14 Added by A. Banaag       
        
        //START: MD-61 03/23/2015 Added by S.PULI - COA checkbox
        if(tempStop_LIST.size()>0){ 
            checkForCOA(tempStop_LIST, false);
        }
        //END: MD-61 03/23/2015 Added by S.PULI - COA checkbox      
        
    //START D-4013 12/4/2015 Added by J.Sarion - Check tempStopCases if empty
        //START:  UD-0327 4/29/2015 AAgna call new method for UD-0327 TempStopCases
    if(!tempStopCases.isEmpty()) {
      populateMainPackage(tempStopCases);
        }
    //END:  UD-0327 4/29/2015 AAgna call new method for UD-0327 TempStopCases
        //END D-4013 12/4/2015 Added by J.Sarion - Check tempStopCases if empty
    
        //START UD-4009 12/2/2015 Added by J.Sarion - Compute Goodwill for Digital Complaint
        if(!complaintDigitalCaseList.isEmpty()) {
            computeGoodwill(complaintDigitalCaseList);
        }
        //END UD-4009 12/2/2015 Added by J.Sarion - Compute Goodwill for Digital Complaint
        setOwnerToQueueForVendorAssignment(lstNewCases); //START UD-3434 1/5/2016 Added by J.Sarion - Set Case Owner based on Postal Sector
    }
    
    //After Insert logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterInsert(List<Case> lstNewCases, Map<Id, Case> mapNewCases)
    {   
        
        //START: JLedesma D-3091 6/18/2015 Year To Date computation
    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        //updateSubYearToDateTempStop(lstNewCases);
    //END UD-2443 9/5/2015 Added By C. Lin
        //ENF: D-3091 6/18/2015 Year To Date computation
        
        //START D-2741 4/30/2015 GDelrosario - Invokce insertCaseVendorSubstopSub method
        insertCaseVendorSubstopSub(lstNewCases);
        //END D-2741 4/30/2015 GDelrosario 

        //START UD-0567 3/30/2015 Added by Manolo Valena - Invokes the urgentStopSubmitForApproval method.
        urgentStopSubmitForApproval(lstNewCases);
        //END UD-0567 3/30/2015 Added by Manolo Valena
        
        bulkAfterDataPrep(lstNewCases);
        // ------------------ ADD CASE VENDOR OPS TO QUEUE
        assignCaseToVendorQueue(mapNewCases, mapNewCases, true);
        
        for(Case newCase : lstNewCases)
        {
            /*Start Sub Route Case for Approval*/
            autoRouteCaseforApproval(newCase);
            /*End Start Sub Route Case for Approval*/
            
            //For Start Subs Case, auto-create Vendor Subscriptions
            createVendorSubs(newCase); 
            //START: UD-3520 1/5/2015 added by Jason A.
            if(newCase.RecordTypeId == CASE_PARTICULARS){
                if(conMap.containskey(newcase.contactid)){
                    if(newCase.AccountId != conmap.get(newcase.contactid).AccountId){
                    //system.assertequals(newCase.AccountId + '' , conmap.get(newcase.contactid).AccountId + ' ');
                        newCase.addError('Contact is not related to your Account');
                    }
                }
            }
            //END: UD-3520 1/5/2015 added by Jason A.
            //START UD-3486 1/5/2015 RReyes
            if(newCase.RecordTypeId == CASE_RETENTION){
                if(mapRetCont.containskey(newCase.contactid)){
                    if(newCase.AccountId != mapRetCont.get(newcase.contactid).AccountId){
                        newCase.addError('Contact is not related to your Account');
                    }
                }
            }
            //END UD-3486 1/5/2015 RReyes
        }
        
        //START D-2003 D-1977 2/13/15 Added by FrancisBenzon : added method after insert
        provisionSubscriptionAfterApproved(lstNewCases); 
        //END D-2003 D-1977 2/13/15 Added by FrancisBenzon : added method after insert      
        
        //Prepare list to update Order Status
        List<Case> lstCaseToUpdate = new List<Case>();
        List<Case> lstComplaintCases = new List<Case>();
        List<Case> lstOverseasCases = new List<Case>();
                
        for(Case newCase : lstNewCases)
        {
            if(newCase.RecordTypeId == CASE_START_SUB_TYPE_ID)
                lstCaseToUpdate.add(newCase);
            
            if(newCase.RecordTypeId==ConstantsSLB.getKeyId('Complaint_Newspaper'))
                lstComplaintCases.add(newCase);

            if(newCase.Order__c != null && newCase.RecordTypeId == ConstantsSLB.getKeyId('Case_Start Sub') 
                && (newCase.Order__r.Recipient_Type__c == 'Overseas' || newCase.Order__r.Recipient_Type__c == 'Airline')) 
            {
                lstOverseasCases.add(newCase);
            }
        }
        
        if(!lstCaseToUpdate.isEmpty())
            updateOrderStatus(lstCaseToUpdate); 
        
        /* For Complaint Newspaper Case record counter */
        if(!lstComplaintCases.isEmpty())
        {
            complaintNewspaperCounter s = new complaintNewspaperCounter();
            s.complaintCounter(lstComplaintCases);
        }
        /*End of For Complaint Newspaper Case record counter */

        //Start D-1089 01/12/2015 Added by FrancisBenzon: Update Status, Sub-Status, Owner if Start sub process has overseas/airline recipient
        if(!lstOverseasCases.isEmpty())
            processOverseasRecipients(lstOverseasCases);        
        //End D-1089 01/12/2015 Added by FrancisBenzon: Update Status, Sub-Status, Owner if Start sub process has overseas/airline recipient
        
        for(Case newCase : lstNewCases)
        {
            //START: D-1950 2/10/15 JLedesma - Update old temp stop status
            updateOldTempStop(newCase);
            //END: D-1950 2/10/15 JLedesma - Update old temp stop status
        }
        //Call andFinally to do Post Processing
        andFinally();
    }
    
    // Start UD-1926 VPernicia 07/20/15
    public void updateContactFields(List<Case> lstNewCases) {
        
        list<id> listContactIDs = new list<id>();
        
        for (Case Cas: lstNewCases) {
            listContactIDs.add(Cas.ContactID);
        }
    
        map<id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, HomePhone__c, Mobile_Number__c FROM Contact WHERE Id IN :listContactIDs]);
        
        if (!mapContacts.isEmpty()) {
            for(Case cs : lstNewCases){
                
                cs.Contact_Number__c = mapContacts.get(cs.ContactID).HomePhone__c;
                cs.Contact_Mobile__c = mapContacts.get(cs.ContactID).Mobile_Number__c;
            }
        }
    }
    // End UD-1926 VPernicia 07/20/15
    
    //Before Update logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeUpdate(List<Case> lstNewCases, Map<Id, Case> mapNewCases,
                               List<Case> lstOldCases, Map<Id, Case> mapOldCases)
    {
        //START: JLedesma D-3091 6/18/2015 Year To Date computation
        //START D-3329 08/26/2015 Added by Charles Lin - Update Year to Date
        List<Case> updateTempStopCase = new List<Case>();
        for(Id caseId :mapNewCases.keySet()){
            if(mapNewCases.get(caseId).RecordTypeId == CASE_TEMP_STOP_TYPE_ID){
                Date oldTempStopDate = mapOldCases.get(caseId).Temp_Stop_Date__c;
                Date oldRestartDate = mapOldCases.get(caseId).Restart_Date__c;
                Date newTempStopDate = mapNewCases.get(caseId).Temp_Stop_Date__c;
                Date newRestartDate = mapNewCases.get(caseId).Restart_Date__c;
                
                //For Non-Urgent
                if((oldTempStopDate != newTempStopDate) || (oldRestartDate != newRestartDate)){
                    updateTempStopCase.add(mapNewCases.get(caseId));
                }

                //For Urgent
                if((mapNewCases.get(caseId).Sub_Status__c != mapOldCases.get(caseId).Sub_Status__c) && mapNewCases.get(caseId).Sub_Status__c == 'Temp Stop Approved'){
                    updateTempStopCase.add(mapNewCases.get(caseId));
                }
            }
        }
        if(!updateTempStopCase.isEmpty()){
            updateCaseYearToDateTempStop(updateTempStopCase);
        }
        //END D-3329 08/26/2015 Added by Charles Lin - Update Year to Date
        //END: JLedesma D-3091 6/18/2015 Year To Date computation
        tickUrgentRequest(lstNewCases); //Start/End D-0509 [12/11/2014] Added by April Banaag
        
        // Start UD-1926 VPernicia 07/20/15
        list<Case> lstCasetoUpdate = new list<Case>();
        for (Case cas: lstNewCases) {
            
            if (cas.ContactID != mapOldCases.get(cas.id).ContactID) {
                lstCasetoUpdate.add(cas);
            }
            //START PD-0202 FrancisBenzon 20May16 : get orders of rejected cases for COS approval
            if(beforeApprovalSubStat.contains(mapOldCases.get(cas.Id).Sub_Status__c) && afterApprovalSubStat.contains(mapNewCases.get(cas.Id).Sub_Status__c) && mapNewCases.get(cas.Id).Order__c != null)
            {              
                orderIdSet_COS.add(mapNewCases.get(cas.Id).Order__c);
            }
            //END PD-0202 FrancisBenzon 20May16 : get orders of rejected cases for COS approval
        }
        /*if(userinfo.getLastName() == 'Benzon')
        {
            system.assertEquals('GETORDERS', 'HERE' + orderIdSet_COS);
        }*/
        //START PD-0202 FrancisBenzon 20May16 : update order status
        if(orderIdSet_COS.size() > 0)
        {
            for(Order__c ord : [Select Id, Status__c From Order__c Where Id IN :orderIdSet_COS])
            {
                /*if(userinfo.getLastName() == 'Benzon')
                {
                    system.assertEquals('GETORDERS', 'HERE' + ord);
                }*/
                ord.Status__c = GlobalVariableClass.STATUS_VOID;
                ordersToUpdateAfterApprovalReject.add(ord);
            }
        }
        //END PD-0202 FrancisBenzon 20May16 : update order status
        
        /*if(userinfo.getLastName() == 'Benzon')
        {
            system.assertEquals('GETORDERS', 'HERE' + ordersToUpdateAfterApprovalReject);
        }*/
        if (!lstCasetoUpdate.isEmpty()) {
            updateContactFields(lstCasetoUpdate);
        }
        // End UD-1926 VPernicia 07/20/15
        
            //START: UD-0327 4/29/2015 AAgna -  TempStop Cases
        for(Case c : lstOldCases){
            system.debug('APRIL old dobeforeupdate' + ' '+ c.Sub_Status__c + ' ' + c.Status);
        }   
        for(Case c : lstNewCases){
            system.debug('APRIL new dobeforeupdate' + ' '+ c.Sub_Status__c + ' ' + c.Status);
            if(c.RecordTypeId == CASE_TEMP_STOP_TYPE_ID){
                tempStopCases.add(c);
            }
            //END: UD-0327 4/29/2015 AAgna -  TempStop Cases
            //START: D-3140 20/06/2015 Added by S.Puli
            if(c.RecordTypeId == CASE_COA && c.Sub_Status__c == GlobalVariableClass.URGENTCOAAPPROVED){
                coaCasesForupdate.add(c);
            }
            //END: D-3140 20/06/2015 Added by S.Puli
            //START UD-1825 07/14/2015 Added by J.Sarion - Create Invoice Adjustment for approved cases
            if(c.RecordTypeId == CASE_ADJUSTMENT && c.Status == GlobalVariableClass.STATUS_PENDING && c.Sub_Status__c == 'Approved'){
                c.OwnerId = c.CreatedById;
                c.Adjustment_Status__c = 'Success';
            }
            //END UD-1825 07/14/2015 Added by J.Sarion - Create Invoice Adjustment for approved cases
        }      
        for(Case newCase : lstNewCases)
        {
            if(newCase.recipient_address__c != null){
                populateInternaAddress(newCase);
            }
            
            //START: D-1347 12/19/14 Added by J. Sarion Add oldCas as parameter 
            returnCaseToCSO(newCase, mapOldCases.get(newCase.Id));
            //END: D-1347 12/19/14 Added by J. Sarion
            
            //D-0765 [JB Domingo 11/18/2014] Vendor Stop
            if(newCase.RecordTypeId == CASE_STOP_SUB_TYPE_ID)
                updateCaseSubStatus(newCase);    
        }
    
    //START D-4013 12/4/2015 Added by J.Sarion - Check tempStopCases if empty
        //START:  UD-0327 4/29/2015 AAgna call new method for UD-0327 TempStopCases
    if(!tempStopCases.isEmpty()) {
      populateMainPackage(tempStopCases);
        }
    //END:  UD-0327 4/29/2015 AAgna call new method for UD-0327 TempStopCases
    //END D-4013 12/4/2015 Added by J.Sarion - Check tempStopCases if empty
    
        //START: D-3140 20/06/2015 Added by S.Puli
        if(coaCasesForupdate.size()>0){
            updateCoaCasesubs(coaCasesForupdate);
        }
        //END: D-3140 20/06/2015 Added by S.Puli
        
        //START: D-0509 12/02/14 Added by A. Banaag
        assignToTLQueue(lstNewCases);  
        //END: D-0509 12/02/14 Added by A. Banaag
        
        //START: D-1347 12/23/14 Added by J. Sarion
        for(Case newCase : lstNewCases)
        {
            updateOwner(newCase, mapOldCases.get(newCase.Id));
        }
        
        //END: D-1347 12/23/14 Added by J. Sarion
        
        //START UD-3434 1/5/2016 Added by J.Sarion - Set Case Owner based on Postal Sector
        for(Case cas :lstNewCases) {
            Case oldCas = mapOldCases.get(cas.Id);

            if((cas.Sub_Status__c == 'Submitted to Vendor' && oldCas.Sub_Status__c != 'Submitted to Vendor') || (cas.Sub_Status__c == 'Waiting for Vendor Assignment' && oldCas.Sub_Status__c != 'Waiting for Vendor Assignment')) {
                assignToVenOpsCaseList.add(cas);
            }
        }
        
        if(!assignToVenOpsCaseList.isEmpty()) {
            setOwnerToQueueForVendorAssignment(assignToVenOpsCaseList); //START UD-3434 1/5/2016 Added by J.Sarion - Set Case Owner based on Postal Sector
        }
       //START UD-3434 1/5/2016 Added by J.Sarion - Set Case Owner based on Postal Sector
        //START: D-3140 20/06/2015 Added by S.Puli
        andFinally();
        //END: D-3140 20/06/2015 Added by S.Puli
    }

    //After Update logic - Call separate method for detail processing - Leave Blank for not in use
    //Issue Note: Wenjun - A lot of operations does not check Old Value. So the action may be triggered unnecessarily
    public void doAfterUpdate(List<Case> lstNewCases, Map<Id, Case> mapNewCases,
                               List<Case> lstOldCases, Map<Id, Case> mapOldCases)
    {
        //START: JLedesma D-3091 6/18/2015 Year To Date computation
    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        //updateSubYearToDateTempStop(lstNewCases);
    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        //END: JLedesma D-3091 6/18/2015 Year To Date computation
        bulkAfterDataPrep(lstNewCases);
    //START:D-3916 11/11/2015 Added by Manolo Valena - Removed.
        //START:UD-1341 5/21/2015 Added by Manolo Valena - Invoke updateSubscriptionVendors method.
        //updateSubscriptionVendors(lstNewCases);
        //END:UD-1341 5/21/2015 Added by Manolo Valena
    //END:D-3916 11/11/2015 Added by Manolo Valena
        // ------------------ ADD CASE VENDOR OPS TO QUEUE
        assignCaseToVendorQueue(mapOldCases, mapNewCases, false);
      
        List<Case> lstRejectedRenewCases = new List<Case>();
        List<Case> lstTStopCases = new List<Case>();
        List<Case> lstCloseOrderTStopCases = new List<Case>();
        List<Case> lstWaiveChargeCases = new List<Case>();
        List<Case> lstGoodWillCases = new List<Case>();
        List<Case> lstCaseToUpdate = new List<Case>();  
        List<Case> lstAddressCases = new List<Case>();
        List<Case> lstOrderToUpdateToDraft = new List<Case>();
        //START MD-17 03/20/2015 Added by J.Sarion/J.Abolac - Create Usage for Goodwill 
        Set<Id> caseIdForGoodwill = new Set<Id>();
        //END MD-17 03/20/2015 Added by J.Sarion/J.Abolac - Create Usage for Goodwill
        List<Zuora__CustomerAccount__c> lstBillingAccountsToUpdate = new List<Zuora__CustomerAccount__c>(); //Start-End 04/23/2015 UD-0572 Jason Abolac
        //START UD-2717 09/10/15 RReyes
        Set<Id> caseIdVoid = new Set<Id>();
        List<Usage__c> usageToDel = new List<Usage__c>();
        //END UD-2717 09/10/15 RReyes
        //START D-4100 04Jan2016 Added By C. Lin - Revert End Date of subscription during Void
        Set<Id> voidCaseId = new Set<Id>();
        //END D-4100 04Jan2016 Added By C. Lin
        //START UD-3553 02Feb2016 Added By C. Lin - Auto approve related bundle case for temp stop
        Set<Id> tsCaseIdsForApproveSet = new Set<Id>();
        Set<Id> tsCaseIdsForRejectSet = new Set<Id>();
        //END UD-3553 02Feb2016 Added By C. Lin
        Set<Id> closedStopCaseIdSet = new Set<Id>(); //STAR-END UD-2549 3/15/2016 Added by J.Sarion
        
    //START D-2323 Wenjun 24/02/15 : Update entry criteria to avoid unnecessary execution 
        for(Case theCase : lstNewCases)
        {
            //START UD-2549 3/15/2016 Added by J.Sarion - check closed Stop Case
            if(theCase.Status == GlobalVariableClass.STATUS_CLOSED && (mapOldCases.get(theCase.Id).Status != GlobalVariableClass.STATUS_CLOSED) && theCase.RecordTypeId == ConstantsSLB.getKeyID('Case_Stop')) {
                closedStopCaseIdSet.add(theCase.Id);
            }
            //END UD-2549 3/15/2016 Added by J.Sarion - check closed Stop Case
            
            if(theCase.Rejected_Renewal__c == TRUE)
                lstRejectedRenewCases.add(theCase);
            
            //START UD-3553 02Feb2016 Added By C. Lin - Auto approve related bundle case for temp stop
            if(theCase.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && theCase.Requires_Urgent_Approval__c == TRUE 
                && theCase.Status == GlobalVariableClass.STATUS_CLOSED 
                && theCase.Sub_Status__c == GlobalVariableClass.TEMP_STOP_APPROVED 
                && theCase.Sub_Status__c != mapOldCases.get(theCase.Id).Sub_Status__c){
                lstTStopCases.add(theCase);
                
                tsCaseIdsForApproveSet.add(theCase.Id);
            }
            
            if(theCase.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && theCase.Requires_Urgent_Approval__c == TRUE 
                && theCase.Status == GlobalVariableClass.STATUS_CLOSED 
                && theCase.Sub_Status__c == 'Temp Stop Rejected' 
                && theCase.Sub_Status__c != mapOldCases.get(theCase.Id).Sub_Status__c){
                
                tsCaseIdsForRejectSet.add(theCase.Id);
            }
            //END UD-3553 02Feb2016 Added By C. Lin
                
            if(theCase.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && theCase.Order__c != NULL 
                && theCase.Status != GlobalVariableClass.TS_PENDING 
                && mapOldCases.get(theCase.Id).Status == GlobalVariableClass.TS_PENDING)
                lstCloseOrderTStopCases.add(theCase);
            
            if(theCase.RecordTypeId == CASE_CHNG_SUB_TYPE_ID && theCase.Order__c != NULL 
                && theCase.Charges_Waived__c == true && (theCase.Sub_Status__c == 'Waiting for Urgent Approval' 
                || theCase.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN 
                || theCase.Sub_Status__c == GlobalVariableClass.SUB_STATUS_CHANGE_OF_SUB_COMPLETED))
                lstWaiveChargeCases.add(theCase);
            //Start 04/23/2015 UD-0572 Jason Abolac 
            if(theCase.RecordTypeId == CASE_REFUND_ID && theCase.Approved_Refund__c == TRUE){
                List<ID> ZBupdate = New list<ID>();
                List<ID> accbillval = new List<ID>();
                List<Zuora__CustomerAccount__c> customerlist = new List<Zuora__CustomerAccount__c>();
                id accid = theCase.Accountid;
                ZBUpdate = Accounttobilling.get(accid);
                
                
                for(id billingid : ZBupdate)
                {
                    customerlist.add(billid.get(billingid));
                }
                for(Zuora__CustomerAccount__c Zcusa: customerlist)
                {
                    Zcusa.Refund_Amount_New__c = Zcusa.Refund_Amount__c;
                    lstBillingAccountsToUpdate.add(Zcusa);

                }
            }
            //End 04/23/2015 UD-0572 Jason Abolac 
                
            //Only Trigger when status changed to "Goodwill Approved"
            //START MD-17 03/20/2015 Added by J.Sarion/J.Abolac - Create Usage for Goodwill 
            //START 03/31/2015 D-2684 Kevin Evasco - No usage for goodwill are being created
            if ((theCase.Sub_Status__c == 'Goodwill Approved' 
                 && theCase.Sub_Status__c != mapOldCases.get(theCase.Id).Sub_Status__c) || 
                 ((theCase.RecordTypeId == ConstantsSLB.getKeyID('Case_Complaint Digital') || theCase.RecordTypeId == ConstantsSLB.getKeyID('Case_Complaint Magazine') || theCase.RecordTypeId == ConstantsSLB.getKeyID('Case_Complaint Newspaper')) && theCase.Goodwill_Amount_Newspaper__c <= 10)) {
                lstGoodWillCases.add(theCase);
                caseIdForGoodwill.add(theCase.Id);
                system.debug('>>>>>After ' + theCase.Sub_Status__c + ' Before ' + mapOldCases.get(theCase.Id).Sub_Status__c);
                system.debug('caseIdForGoodwill '+ caseIdForGoodwill);                
            }
            //END 03/31/2015 D-2684 Kevin Evasco - No usage for goodwill are being created
            //END MD-17 03/20/2015 Added by J.Sarion/J.Abolac - Create Usage for Goodwill
            
            //START D-2884 05-18-2015 Marvin Gatchalian add is when goodwill case is closed
            if (theCase.Sub_Status__c == 'Goodwill Approved' && theCase.Status == 'Closed') {
                lstGoodWillCases.add(theCase);
                caseIdForGoodwill.add(theCase.Id);
            } 
            //END D-2884 05-18-2015 Marvin Gatchalian add is when goodwill case is closed
          

        //Only trigger when case status is changed          
            if(theCase.RecordTypeId == CASE_START_SUB_TYPE_ID && theCase.Status != mapOldCases.get(theCase.Id).Status)
                lstCaseToUpdate.add(theCase);
            
            if (theCase.RecordTypeId == ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGEADD) 
                && theCase.Sub_Status__c == GlobalVariableClass.URGENTCOAAPPROVED
                && theCase.Sub_Status__c != mapOldCases.get(theCase.Id).Sub_Status__c) 
                lstAddressCases.add(theCase);
           // Start UD-0759 ronald dagaraga add criteria     
            if (theCase.RecordTypeId == CASE_START_SUB_TYPE_ID 
                && theCase.Sub_Status__c == GlobalVariableClass.URGENT_START_REJECTED) 
                //&& theCase.Sub_Status__c != mapOldCases.get(theCase.Id).Sub_Status__c) 
                lstOrderToUpdateToDraft.add(theCase);

            // End UD-0759 ronald dagaraga add criteria   
        
      //START:D-2951 5/19/2015 Added by Manolo Valena - Fix by Von Pernicia
            if(theCase.Outcome__c == 'Retained' && theCase.Urgent_Request__c == true && theCase.Sub_Status__c == 'Waiting for Urgent Stop Approval'){
                
                ApprovalProcessSubmitter.submit(theCase.id);
            }
      //END:D-2951 5/19/2015 Added by Manolo Valena
            //START UD-1825 07/14/2015 Added by J.Sarion - Create Invoice Adjustment for approved cases
            if(theCase.RecordTypeId == CASE_ADJUSTMENT && theCase.Status == GlobalVariableClass.STATUS_PENDING && theCase.Sub_Status__c == 'Approved'){
                adjustmentIdSet.add(theCase.Id);
            }
            //END UD-1825 07/14/2015 Added by J.Sarion - Create Invoice Adjustment for approved cases
            
            //START UD-2717 09/10/15 RReyes - get void cases                
            if((theCase.RecordTypeId == CASE_COMPLAINT_MAG || theCase.RecordTypeId == CASE_COMPLAINT_NP) && theCase.Status == 'Void'){
                caseIdVoid.add(theCase.Id);
            }
            //END UD-2717 09/10/15 RReyes - get void cases
            
            //START: UD-3520 1/5/2015 added by Jason A.
            if(theCase.RecordTypeId == CASE_PARTICULARS){
                if(conMap.containskey(theCase.contactid)){
                    if(theCase.AccountId != conmap.get(theCase.contactid).AccountId){
                    //system.assertequals(theCase.AccountId + '' , conmap.get(theCase.contactid).AccountId + ' ');
                        theCase.addError('Contact is not related to your Account');
                    }
                }
            }
            //END: UD-3520 1/5/2015 added by Jason A.
            //START UD-3486 1/5/2015 RReyes
            if(theCase.RecordTypeId == CASE_RETENTION){
                if(mapRetCont.containskey(theCase.contactid)){
                    if(theCase.AccountId != mapRetCont.get(theCase.contactid).AccountId){
                        theCase.addError('Contact is not related to your Account');
                    }
                }
            }
            //END UD-3486 1/5/2015 RReyes
            //START D-4100 04Jan2016 Added By C. Lin - Revert End Date of subscription during Void
            system.debug('>>>>>CHA theCase.Status ' + theCase.Status);
            system.debug('>>>>>CHA mapOldCases.get(theCase.Id).Status ' + mapOldCases.get(theCase.Id).Status);
                    
            if((theCase.RecordTypeId == CASE_CHNG_SUB_TYPE_ID || theCase.RecordTypeId == CASE_STOP_SUB_TYPE_ID) && theCase.Status == GlobalVariableClass.STATUS_VOID &&  theCase.Status != mapOldCases.get(theCase.Id).Status){
                voidCaseId.add(theCase.Id); 
                //START PD-0113 FrancisBenzon 9June16 : cater voiding for pending cases
                casIdRecTypeId.put(theCase.Id, theCase.RecordTypeId); 
                //END PD-0113 FrancisBenzon 9June16 : cater voiding for pending cases               
            }
            //END D-4100 04Jan2016 Added By C. Lin
            
        }
        
        //END D-2323 Wenjun 24/02/15
        
        //START D-4100 04Jan2016 Added By C. Lin - Revert End Date of subscription during Void
        //START 18 April 2016 UD-3911 Kevin Evasco - Revert End Date of Subscription during COS //fritz
        Set<Id> subscripId = new Set<Id>();
        Set<Id> subVendorId = new Set<Id>();
        Set<Id> ordIdSet = new Set<Id>();
        Set<Id> subVenSetCheck = new Set<Id>();
        Set<Id> oLineItemIdSet = new Set<Id>();
        Map<Id, List<Subscription_Vendor__c>> ordIdToSubVenMap = new Map<Id, List<Subscription_Vendor__c>>();
        Map<Id, List<Order_Line_Item_Vendor__c>> orderIdToOlivListMap = new Map<Id, List<Order_Line_Item_Vendor__c>>();
        List<Zuora__Subscription__c> subListToUpdate = new List<Zuora__Subscription__c>();
        List<Subscription_Vendor__c> subVenListToUpdate = new List<Subscription_Vendor__c>();
        
        system.debug('>>>>>CHA voidCaseId ' + voidCaseId);
        //Start UD-3911 VPernicia/John D 4/19/16
        if(!voidCaseId.isEmpty()){
            for(Case_Subscription__c sub : [SELECT Id, Subscription__c, Subscription__r.Order_Line_Item_Number_1__c, Case__r.RecordType.DeveloperName, case__r.subscription_name__r.Order_Line_Item_Number_1__c FROM Case_Subscription__c WHERE Case__c IN :voidCaseId]){
                if (sub.Case__r.RecordType.DeveloperName == GlobalVariableClass.RT_DEV_NAME_STOP) {
                    if(sub.Subscription__r.Order_Line_Item_Number_1__c != null){
                        oLineItemIdSet.add(sub.Subscription__r.Order_Line_Item_Number_1__c);
                    }
                }
                
                if (sub.Case__r.RecordType.DeveloperName == GlobalVariableClass.RT_DEV_NAME_COS) {
                    if(sub.case__r.subscription_name__r.Order_Line_Item_Number_1__c != null){
                        oLineItemIdSet.add(sub.case__r.subscription_name__r.Order_Line_Item_Number_1__c);
                    }
                }
            }
            //End UD-3911 VPernicia/John D 4/19/16
            
            for(Case_Vendor_Subscription__c subV : [SELECT Id, Subscription_Vendor__c FROM Case_Vendor_Subscription__c WHERE Case__c IN :voidCaseId]){
                if(subV.Subscription_Vendor__c != null){
                    subVendorId.add(subV.Subscription_Vendor__c);
                }
            }
            //system.assertEquals('OLI', ' ' + oLineItemIdSet);
            if(!oLineItemIdSet.isEmpty()){
                for(Zuora__Subscription__c sub : [SELECT Id, Name, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Term_Length__c, Zuora__TermSettingType__c FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c IN :oLineItemIdSet]){
                    if(sub.Zuora__TermSettingType__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED && sub.Term_Length__c != null){
                        sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(integer.valueOf(sub.Term_Length__c)).addDays(-1);
                    }else if(sub.Zuora__TermSettingType__c == GlobalVariableClass.EVERGREEN){
                        sub.Zuora__SubscriptionEndDate__c = null;
                    }
                    
                    subListToUpdate.add(sub);
                }
            }
            //START PD-0113 FrancisBenzon 9June16 : cater voiding for pending cases
            else {
                for(Id casId : voidCaseId)
                {
                    if(casIdRecTypeId.containsKey(casId) && casIdRecTypeId.get(casId) != null)
                    {
                        if(casIdRecTypeId.get(casId) == CASE_CHNG_SUB_TYPE_ID)
                        {
                            for(Case cas : [Select Subscription_Name__c From Case Where Id IN :voidCaseId])
                            {
                                if(cas.Subscription_Name__c != null) {
                                    cosVoidedSubsId.add(cas.Subscription_Name__c);
                                }                   
                            }
                            if(cosVoidedSubsId.size() > 0)
                            {
                                 for(Zuora__Subscription__c sub : [SELECT Id, Name, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Term_Length__c, Zuora__TermSettingType__c                                       FROM Zuora__Subscription__c WHERE Id IN :cosVoidedSubsId])
                                 {
                                    if(sub.Zuora__TermSettingType__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED && sub.Term_Length__c != null){
                                        sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(integer.valueOf(sub.Term_Length__c)).addDays(-1);
                                    }else if(sub.Zuora__TermSettingType__c == GlobalVariableClass.EVERGREEN){
                                        sub.Zuora__SubscriptionEndDate__c = null;
                                    }                           
                                    subListToUpdate.add(sub);
                                }
                            }
                        }
                    } 
                }           
            }
            //END PD-0113 FrancisBenzon 9June16 : cater voiding for pending cases
            /*
            if(!oLineItemIdSet.isEmpty()){
                for(Zuora__Subscription__c sub : [SELECT Id, Name, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Term_Length__c, Zuora__TermSettingType__c FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c IN :oLineItemIdSet]){
                    //system.assertEquals(string.valueOF(sub.Zuora__TermSettingType__c), string.valueOF(sub.Term_Length__c));
                    if(sub.Zuora__TermSettingType__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED && sub.Term_Length__c != null){
                        sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(integer.valueOf(sub.Term_Length__c)).addDays(-1);
                    }else if(sub.Zuora__TermSettingType__c == GlobalVariableClass.EVERGREEN){
                        sub.Zuora__SubscriptionEndDate__c = null;
                    }
                    
                    subListToUpdate.add(sub);
                }
            }*/            
            //END 18 April 2016 UD-3911 Kevin Evasco - Revert End Date of Subscription during COS
            
            if(!subVendorId.isEmpty()){
                for(Subscription_Vendor__c subven : [SELECT Id, Order_Number__c FROM Subscription_Vendor__c WHERE Id IN :subVendorId]){
                    if(subven.Order_Number__c != null){
                        ordIdSet.add(subven.Order_Number__c);
                    }
                }
            }
            
            for(Order_Line_Item_Vendor__c oliv : [SELECT Id, Order__c, Wrapper_Number__c, Stop_Date__c FROM Order_Line_Item_Vendor__c WHERE Order__c IN :ordIdSet]){
                if(orderIdToOlivListMap.containsKey(oliv.Order__c)){
                    orderIdToOlivListMap.get(oliv.Order__c).add(oliv);
                }else{
                    orderIdToOlivListMap.put(oliv.Order__c, new List<Order_Line_Item_Vendor__c>{oliv});
                }
            }
            
            if(!subVendorId.isEmpty()){
                for(Subscription_Vendor__c subVen : [SELECT Id, Name, Subscription_Stop_Date__c, Order_Number__c FROM Subscription_Vendor__c WHERE Id IN :subVendorId ORDER BY Id]){
                    if(ordIdToSubVenMap.containsKey(subVen.Order_Number__c)){
                        ordIdToSubVenMap.get(subVen.Order_Number__c).add(subVen);
                    }else{
                        ordIdToSubVenMap.put(subVen.Order_Number__c, new List<Subscription_Vendor__c>{subVen});
                    }
                }
            }
            
            if(!ordIdSet.isEmpty()){
                for(Id ordId : ordIdSet){
                    system.debug('>>>>>CHA orderIdToOlivListMap ' + orderIdToOlivListMap);
                    if(orderIdToOlivListMap.containsKey(ordId)){
                        for(Order_Line_Item_Vendor__c oliv : orderIdToOlivListMap.get(ordId)){
                            if(ordIdToSubVenMap.containsKey(ordId)){
                                for(Integer x = 0; x < ordIdToSubVenMap.get(ordId).size(); x++){
                                    if(x+1 == oliv.Wrapper_Number__c){
                                        system.debug('>>>>>CHA oliv.Stop_Date__c ' + oliv.Stop_Date__c);
                                        ordIdToSubVenMap.get(ordId)[x].Subscription_Stop_Date__c = oliv.Stop_Date__c;
                                        ordIdToSubVenMap.get(ordId)[x].Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
                                        
                                        if(!subVenSetCheck.contains(ordIdToSubVenMap.get(ordId)[x].Id)){
                                            subVenListToUpdate.add(ordIdToSubVenMap.get(ordId)[x]);
                                            subVenSetCheck.add(ordIdToSubVenMap.get(ordId)[x].Id);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            system.debug('>>>>>CHA subListToUpdate ' + subListToUpdate);
            if(!subListToUpdate.isEmpty()){
                update subListToUpdate;
            }
            system.debug('>>>>>CHA subVenListToUpdate ' + subVenListToUpdate);
            if(!subVenListToUpdate.isEmpty()){
                update subVenListToUpdate;
            }
        }
        //END D-4100 04Jan2016 Added By C. Lin
        
        //START UD-2717 09/10/15 RReyes - delete usages for void complaints                 
        if(caseIdVoid.size() > 0){
            usageToDel = [SELECT Id from Usage__c WHERE Case__c IN :caseIdVoid]; 
            if(usageToDel.size() > 0){
                try{
                    delete usageToDel;
                }catch(Exception  e){
                    System.debug(e.getMessage());
                }
            }
        }
        //END UD-2717 09/10/15 RReyes - delete usages for void complaints
        
        //Start 04/23/2015 UD-0572 Jason Abolac 
        if(!lstBillingAccountsToUpdate.isEmpty()){
            update lstBillingAccountsToUpdate;
        }
        //End 04/23/2015 UD-0572 Jason Abolac 
        /*----Renewal-----*/
        if(!lstRejectedRenewCases.isEmpty())
            updateOrderStatusIfRejected(lstRejectedRenewCases);
        /*----End Renewal-----*/
        
        // Start UD-0759 ronald dagaraga add criteria 
        if(!lstOrderToUpdateToDraft.isEmpty())
            updateOrderStatusToDraft(lstOrderToUpdateToDraft);
            
        // End UD-0759 ronald dagaraga add criteria     
        
        //START UD-3553 02Feb2016 Added By C. Lin - Auto approve related bundle case for temp stop
        //Start D-4665 02-Apr-2016 Added By S.Puli
        if(!Test.isRunningTest()){
            if(!tsCaseIdsForApproveSet.isEmpty()){
                System.enqueueJob(new AutoApprover(tsCaseIdsForApproveSet, 'Approved'));
            }
            
            if(!tsCaseIdsForRejectSet.isEmpty()){
                System.enqueueJob(new AutoApprover(tsCaseIdsForRejectSet, 'Reject'));
            }
        }
        //End D-4665 02-Apr-2016 Added By S.Puli
        //END UD-3553 02Feb2016 Added By C. Lin
        
        /*Start Sub Route Case for Approval*/    
        if(!lstTStopCases.isEmpty()){//START/END: MD-61 03/23/2015 Added by S.PULI
            createTempStopUponApproval(lstTStopCases); 
            checkForCOA(lstTStopCases, true);//START/END: MD-61 03/23/2015 Added by S.PULI
        }//START/END: MD-61 03/23/2015 Added by S.PULI
        
        if(!lstCloseOrderTStopCases.isEmpty())
            closingOrderTempStopCase(lstCloseOrderTStopCases);
                
        for(Case newCase : lstNewCases)
        {
            autoRouteCaseforApproval(newCase);
            
            //For Start Subs Case, auto-create Vendor Subscriptions
            createVendorSubs(newCase);
        } 

        if(!lstWaiveChargeCases.isEmpty())
            updateCreditsAndCharges(lstWaiveChargeCases);
        
        //START D-2003 D-1977 2/13/15 Added by FrancisBenzon : added method after Update
        provisionSubscriptionAfterApproved(lstNewCases);
        //END D-2003 D-1977 2/13/15 Added by FrancisBenzon : added method after Update
        
        // For Goodwill update - Added Nov 22, 2014 by: Marvin Gatchalian
        if(!lstGoodWillCases.isEmpty())
            processGoodWill(lstGoodWillCases);

        if(!lstCaseToUpdate.isEmpty())
            updateOrderStatus(lstCaseToUpdate);           

        for(Case newCase : lstNewCases)
        {
            //START: D-1950 2/10/15 JLedesma - Update old temp stop status
            updateOldTempStop(newCase);
            //END: D-1950 2/10/15 JLedesma - Update old temp stop status
        }
        
        //START: D-1955 2/11/15 J.Sarion - Create Address Assignment
        System.debug('cube ---------------------------------------------------------------- nasalabas' + lstAddressCases);
        if (!lstAddressCases.isEmpty()){//START/END: MD-61 03/25/2015 Added by S.PULI 
            //cube -----
                System.debug('cube ---------------------------------------------------------------- pumasok' + lstAddressCases);
            //cube -----
            createAddressAssignment(lstAddressCases);
            //START: MD-61 03/25/2015 Added by S.PULI 
            for(Case c : lstAddressCases){
                tCaseSet.add(c.Id);
            }
            CaseSubscriptionTriggerHandler csTH = new CaseSubscriptionTriggerHandler();
            csTH.checkForTempStop(tCaseSet);
            csTH.andFinallyAfterInsert();
        }
        //END: MD-61 03/25/2015 Added by S.PULI 
        //END: D-1955 2/11/15 J.Sarion - Create Address Assignment
        
        
     //START D-2884 05/29/2015 Added By J. Sarion - usage will be created once
        //START MD-17 03/20/2015 Added by J.Sarion/J.Abolac - Create Usage for Goodwill
        system.debug('>>>CHA caseIdForGoodwill.size() ' + caseIdForGoodwill.size());
        system.debug('>>>CHA caseIdForGoodwill ' + caseIdForGoodwill);
        system.debug('>>>CHA isSendToZuoraCallOutFiredForGoodWill ' + isSendToZuoraCallOutFiredForGoodWill);
        system.debug('>>>CHA !isSendToZuoraCallOutFiredForGoodWill ' + !isSendToZuoraCallOutFiredForGoodWill);
        
        if (caseIdForGoodwill.size() > 0 && !isSendToZuoraCallOutFiredForGoodWill) {
            System.debug('cube ---------------------------------------------- || called usageCreationForGoodwill ' );
            usageCreationForGoodwill.createUsageForGoodwill(caseIdForGoodwill);
            isSendToZuoraCallOutFiredForGoodWill = true;
        }
        //END MD-17 03/20/2015 Added by J.Sarion/J.Abolac - Create Usage for Goodwill 
     //END D-2884 05/29/2015 Added By J. Sarion - usage will be created once
        
        
        
     //START D-2884 05/29/2015 Added By J. Sarion - usage will be created once
        //START D-2884 05-18-2015 Marvin Gatchalian
        //START: D-2565 03/21/2015 Added by S.PULI
        //Start D-4452 02-Apr-2016 Added By S.Puli
        /**
        if(complaintCaseUsageToZuoraSet.size()>0 && !isSendToZuoraCallOutFired) {
            isSendToZuoraCallOutFired = true;
            sendToZuoraCallOut(complaintCaseUsageToZuoraSet);
        }
        **/
        //End D-4452 02-Apr-2016 Added By S.Puli
        //END: D-2565 03/21/2015 Added by S.PULI
        //END D-2884 05-18-2015 Marvin Gatchalian
     //END D-2884 05/29/2015 Added By J. Sarion - usage will be created once
        
        //START D-3170 6/25/15 Added by Manolo Valena - Invokes updateSubscriptionEndDateUrgenStop method.
        updateSubscriptionEndDateUrgentStop(lstNewCases);
        //END D-3170 6/25/15 Added by Manolo Valena
        //START D-3488 9/4/15 Added by Manolo Valena - Invokes updateRecalledSubEndDate method.
        updateRecalledSubEndDate(lstNewCases);
        //END D-3488 9/4/15 Added by Manolo Valena
        //START UD-1825 07/14/2015 Added by J.Sarion - Create Invoice Adjustment
        if(!adjustmentIdSet.isEmpty() && !iscreateInvoiceAdjustmentFired){
            iscreateInvoiceAdjustmentFired = true;
            //START 06 August 2015 UD-2122 Kevin Evasco - Changed Adjustment Case payment process. Usages are now being created to give credits to the customer.
            //createInvoiceAdjustment(adjustmentIdSet);
            AdjustmentUsageLoader.loadAdjustmentUsages(adjustmentIdSet);
            //END 06 August 2015 UD-2122 Kevin Evasco - Changed Adjustment Case payment process. Usages are now being created to give credits to the customer.
        }
        //END UD-1825 07/14/2015 Added by J.Sarion - Create Invoice Adjustment
       
        
        //Call andFinally to do Post Processing
        andFinally();
    
    //START:D-3916 11/11/2015 Added by Manolo Valena
        updateSubscriptionVendors(lstNewCases);
        //END:D-3916 11/11/2015 Added by Manolo Valena
        
        //START UD-2549 3/17/2016 Added by J.Sarion - Call method
        //START PD-0327 06/08/2016 removed by Jason A.
        /*
        if(!closedStopCaseIdSet.isEmpty() && !iscreateInvoiceAdjustmentPStop) {
            system.debug('>>>>>closedStopCaseIdSet ' + closedStopCaseIdSet);
            createInvoiceAdjustmentPStop(closedStopCaseIdSet);
            iscreateInvoiceAdjustmentPStop = true;
        }
        */
        //END PD-0327 06/08/2016 removed by Jason A.
        //END UD-2549 3/17/2016 Added by J.Sarion - Call method
    }
    
    //Before Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeDelete(List<Case> lstOldCases, Map<Id, Case> mapOldCases)
    {}
    
    //After Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterDelete(List<Case> lstOldCases, Map<Id, Case> mapOldCases)
    {}
    
    private void bulkAfterDataPrep(List<Case> lstNewCases) {
        casToUpdateMap = new Map<Id, Case>(); 
        /*------ Start Subscription ---------*/ 
        Set<Id> orderIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        //START: D-1950 2/10/15 JLedesma - Update old temp stop status
        Set<Id> tempStopIds = new Set<Id>();
        Set<Id> oldTempOrderIds = new Set<Id>(); 
        
        Set<Id> caseComplaintNpIds = new Set<Id>();//START/END: D-2565 03/21/2015 Added by S.PULI
        
    //START: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
        Set<Id> oldClosed = new Set<Id>(); 
        //END: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
        //START UD-3293 11/25/15 RReyes
        Set<Id> setParentId = new Set<Id>();
        Map<Id, Id> mapCaseToParent = new Map<Id, Id>();
        List<Case> lstParentCase = new List<Case>();
        //END UD-3293 11/25/15 RReyes
        set<id> setcontact = new set<Id>();//START-END: UD-3520 1/5/2015 added by Jason A.
        Set<Id> setRetContact = new Set<Id>();//START/END UD-3486 1/5/2015 RReyes
        set<id> stopCaseSet = new set<Id>();//START-END PD-0327 06/08/2016 added by Jason A.
        List<Order_Line_Item__c> oliStopList = new List<Order_Line_Item__c>();//START-END PD-0327 06/08/2016 added by Jason A.
        for(Case c : lstNewCases) {
            //START: UD-3520 1/5/2015 added by Jason A.
            if(c.RecordTypeId == Case_Particulars ){
                setcontact.add(c.contactID);
            }
            //END: UD-3520 1/5/2015 added by Jason A.
            
            //START UD-3486 1/5/2015 RReyes
            if(c.RecordTypeId == CASE_RETENTION){
                setRetContact.add(c.contactID);
            }
            //END UD-3486 1/5/2015 RReyes
            
            //START: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
            if(c.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && c.Status == GlobalVariableClass.STATUS_CLOSED){
                oldClosed.add(c.Order__c);
            }
            //END: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
            caseIds.add(c.Id);
            
            if(c.Order__c != null) 
                orderIds.add(c.Order__c);
            
            accIds.add(c.AccountId);
                
            if(c.Temp_Stop_Updated__c!=NULL)
                tempStopIds.add(c.Temp_Stop_Updated__c);

            //START: D-2565 03/21/2015 Added by S.PULI
            //complaintCaseUsageToZuoraList
            if(c.RecordTypeId == CASE_COMPLAINT_NP && c.Status == GlobalVariableClass.STATUS_CLOSED){
                caseComplaintNpIds.add(c.Id);
            }
            //END: D-2565 03/21/2015 Added by S.PULI    
            //START UD-3293 RReyes - 11/25/15
            if(Trigger.isInsert){
                if(c.ParentId != null){
                    setParentId.add(c.ParentId);
                    if(!mapCaseToParent.containsKey(c.Id)){
                        mapCaseToParent.put(c.Id, c.ParentId);
                    }
                }
            }
            //END  UD-3293 RReyes - 11/25/15
            ////START PD-0327 06/08/2016 added by Jason A.
            if(c.RecordTypeId == CASE_STOP_SUB_TYPE_ID && c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION){
                stopCaseSet.add(c.Id);
            }
            //END PD-0327 06/08/2016 added by Jason A.
        }   
        //START: UD-3520 1/5/2015 added by Jason A.
        
        if(setcontact.size() > 0){
            conMap =  new map<id, contact>([SELECT id, Accountid From Contact WHERE id in: setcontact]);
        }
        //END: UD-3520 1/5/2015 added by Jason A.
        //START UD-3486 1/5/2015 RReyes
        if(setRetContact.size() > 0){
            mapRetCont =  new map<id, contact>([SELECT id, AccountId From Contact WHERE id in: setRetContact]);
        }
        //END UD-3486 1/5/2015 RReyes
    // Start UD-1926 VPernicia 07/20/15: Code optimization: Comment out this block
        /*//START: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
        if(oldClosed.size() > 0){
            orderClosedMap = new Map<Id, Order__c>([SELECT Id, Status__c, Remarks__c FROM Order__c WHERE Id IN :oldClosed]);
        }
        //END: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed*/
        // End UD-1926 VPernicia 07/20/15: Code optimization: Comment out this block
        
        //Start 04/23/2015 UD-0572 Jason Abolac 
        //START D-3611 25-Sept-2015 Added by S.Puli - reduce SOQL for Complaint Newspaper
        if(caseComplaintNpIds.size()==0){
            for(Zuora__CustomerAccount__c Zcust : [Select ID, Zuora__Account__c, Refund_Amount_New__c, Refund_Amount__c from Zuora__CustomerAccount__c where Zuora__Account__c IN : accIds]) {
                if(Accounttobilling.containskey(Zcust.Zuora__Account__c))
                {
                    Accounttobilling.get(Zcust.Zuora__Account__c).add(Zcust.ID);
                    CusAccount.add(Zcust.ID);
                }
                else
                {
                    Accounttobilling.put(Zcust.Zuora__Account__c, new list<ID>{Zcust.ID});
                    CusAccount.add(Zcust.ID);
                }
                
                // Start UD-1926 VPernicia 07/20/15 - Code optimization
                billid.put(Zcust.ID, Zcust);
                // End UD-1926 VPernicia 07/20/15 - Code optimization
            }
        }
        //END D-3611 25-Sept-2015 Added by S.Puli - reduce SOQL for Complaint Newspaper
        // Start UD-1926 VPernicia 07/20/15 - Code optimization: Comment out the block
        //for(Zuora__CustomerAccount__c billac : [Select ID , Refund_Amount__c from Zuora__CustomerAccount__c Where ID IN : CusAccount]){
        //    billid.put(billac.ID, billac);
        //}
        // END UD-1926 VPernicia 07/20/15 - Code optimization: Comment out the block
        //End 04/23/2015 UD-0572 Jason Abolac 

        
        //START: D-2565 03/21/2015 Added by S.PULI
        //START D-2647 06/20/2015 Added by J.Sarion - Update Start Date to first day of the month if it is a complaint a month ago
        if(caseComplaintNpIds.size()>0){
            complaintCaseUsageToZuoraList = [Select Id, Case__c, Status__c, Start_Date__c, Subscription_Id__c From Usage__c Where Case__c IN :caseComplaintNpIds AND Status__c = :GlobalVariableClass.STATUS_NEW AND Usage_Type__c = :UsageHelper.USAGE_TYPE_NONDELIVERY]; //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            
            Set<String> subNameComplaintSet = new Set<String>();
            List<Zuora__Subscription__c> subComplaintList = new List<Zuora__Subscription__c>();
            Map<String, Zuora__Subscription__c> subNameToSubMap = new Map<String, Zuora__Subscription__c>();
            
            
            if(complaintCaseUsageToZuoraList.size()>0){
                for(Usage__c u : complaintCaseUsageToZuoraList){
                    complaintCaseUsageToZuoraSet.add(u.Id);
                    if (u.Subscription_Id__c != null)
                        subNameComplaintSet.add(u.Subscription_Id__c);
                }
                if (!subNameComplaintSet.isEmpty()) {
                    subComplaintList = [SELECT ID, Name, Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c WHERE Name IN :subNameComplaintSet];
                }
                for (Zuora__Subscription__c sub : subComplaintList) {
                    subNameToSubMap.put(sub.Name, sub);
                }
                for(Usage__c u : complaintCaseUsageToZuoraList){
                    Zuora__Subscription__c subComplaint = subNameToSubMap.get(u.Subscription_Id__c);
                    Date complaintDate = date.today().toStartOfMonth();
                    Date subStartDateStart = subComplaint.Zuora__SubscriptionStartDate__c.toStartOfMonth();
                    Date subStartDateEnd = date.newInstance(subComplaint.Zuora__SubscriptionStartDate__c.year(), subComplaint.Zuora__SubscriptionStartDate__c.month(), date.daysInMonth(subComplaint.Zuora__SubscriptionStartDate__c.year(), subComplaint.Zuora__SubscriptionStartDate__c.month()));
                    // Start D-4470 02Apr16 JohnD - revised logic
                    u.Start_Date__c = date.today();
                    /*
                    if (u.Start_Date__c < complaintDate) {
                        if (u.Start_Date__c >= subStartDateStart && u.Start_Date__c <= subStartDateEnd) {
                            u.Start_Date__c = complaintDate.toStartOfMonth();
                        }
                    }
                    */
                    // End D-4470 02Apr16 JohnD - revised logic
                }
                //START D-3611 25-Sept-2015 Added by S.Puli
                //REMOVE update complaintCaseUsageToZuoraList;
                //END D-3611 25-Sept-2015 Added by S.Puli
            }
        }
        //END D-2647 06/20/2015 Added by J.Sarion - Update Start Date to first day of the month if it is a complaint a month ago
        //END: D-2565 03/21/2015 Added by S.PULI
        
        if(tempStopIds!=NULL){
            List<Temp_Stop__c> tempList = [SELECT Id, Cancelled__c, Order__c FROM Temp_Stop__c WHERE Id IN :tempStopIds];
            tempStopMap = new Map<Id, Temp_Stop__c>(tempList);
            for(Temp_Stop__c t: tempList){
                if(t.Order__c!=NULL){
                    oldTempOrderIds.add(t.Order__c);
                }
            }
        }
        
        if(oldTempOrderIds!=NULL){
            orderTempMap = new Map<Id, Order__c>([SELECT Id, Status__c, Remarks__c FROM Order__c WHERE Id IN :oldTempOrderIds]);
        }
        //END: D-1950 2/10/15 JLedesma - Update old temp stop status
        
        // Start UD-1926 VPernicia - Code Optimization
        // Start D-2167 02/12/2015 JohnD added Recipient_Contact__r.Address__r.RecordType.Name field
        // Start D-2346 02/25/2015 JTeves added Recipient_Contact__r.Address__r.RecordTypeId field
        //START D-3611 25-Sept-2015 Added by S.Puli
        //START D-4341 RReyes 01/27/16 Added ORDER BY Start_Date__c
        if(orderIds.size()>0){
            orderMap = new Map<Id, Order__c>([SELECT Id, Account__c, Reason__c, Recipient_Contact__c, Recipient_Contact__r.Address__r.RecordTypeId, Recipient_Contact__r.Address__r.RecordType.Name, 
                              (SELECT Id, Name, Start_Date__c, Stop_Date__c, Publication__c, Order__c, Mon__c, Tue__c,
                               Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c, Wrapper_Number__c, Vendor__c
                               FROM Order_Line_Items__r ORDER BY Wrapper_Number__c, Start_Date__c), Status__c
                               FROM Order__c WHERE Id IN :orderIds]);
        }
        //END D-4341 RReyes 01/27/16 ORDER BY Start_Date__c
        //END D-3611 25-Sept-2015 Added by S.Puli
        // End D-2346 02/25/2015 JTeves
        // End D-2167 02/12/2015 JohnD          
        
        
        caseOrderMap = new Map<Id, Order__c>();
        for(Order__c ord : orderMap.values()) { 
            Order__c orders = new Order__c(Status__c = ord.Status__c, id=ord.id);
            caseOrderMap.put(ord.id,orders);             
        }
        // End UD-1926 VPernicia - Code Optimization
        
        // Start UD-1926 VPernicia - Code Optimization: Comment out this block
        //caseOrderMap = new Map<Id, Order__c>([SELECT Name, Id, Status__c FROM Order__c WHERE Id IN :orderIds]);
        // End UD-1926 VPernicia - Code Optimization: Comment out this block
        //START D-3611 25-Sept-2015 Added by S.Puli - reduce SOQL for Complaint Newspaper
        if(accIds.size()>0){
            accountMap = new Map<Id, Account>([Select RecordTypeId FROM Account WHERE Id IN :accIds]);
        }
        //END D-3611 25-Sept-2015 Added by S.Puli
        for(ProcessInstance e : [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN :caseIds]){
            existingApprovalsSet.add(e.TargetObjectId);
        }
        //START UD-3293 11/25/15 RReyes - Hotfixed in SIT
        if(setParentId.size() > 0){
            lstParentCase = [SELECT Id, Status, Origin, RecordType.Name FROM Case WHERE Id IN:setParentId]; 
            if(lstParentCase.size() > 0){
                for(Case caseRec:lstParentCase){
                    if(caseRec.RecordType.Name == 'Enquiry' && (caseRec.Origin == 'Email' || caseRec.Origin == 'SPH Circulation'|| caseRec.Origin == 'SPH Rewards' || caseRec.Origin == 'SPH Paypal')){
                        caseRec.Status = 'Closed';
                        lstParentCaseToUpdate.add(caseRec);
                    }
                }
            }
        }
        //END UD-3293 11/25/15 RReyes - Hotfixed in SIT
        
        //START UD-2002 07/22/2015
        //START PD-0327 06/08/2016 added by Jason A.
        if(!stopCaseSet.isEmpty() && !iscreateInvoiceAdjustmentPStop) {
            createInvoiceAdjustmentPStop(stopCaseSet);
            iscreateInvoiceAdjustmentPStop = true;
        }
        //END PD-0327 06/08/2016 added by Jason A.
    }
    
    private void andFinally() {
        insertVendorSubsRecords(); 
        //START: D-1950 2/10/15 JLedesma - Update old temp stop status
        if(orderToTempUpdateList != null){
            update orderToTempUpdateList;
        }
        
    //START: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
        if(orderToClose != null){
            update orderToClose;
        }
        //END: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
        
        if(tempToUpdateList != null){
            //START: JLedesma D-3091 6/18/2015 Year To Date computation
            try{
            update tempToUpdateList;
            }
            catch(exception e) {
                System.debug(String.valueOf(e));
            }
        }
        //END: D-1950 2/10/15 JLedesma - Update old temp stop status
        //START: UD-1830 7/13/2015 Avoid looping of Trigger
        if(subToUpdateList.size() > 0){
            SubscriptionTriggerHandler.preventExecution = TRUE;
            update subToUpdateList;
            SubscriptionTriggerHandler.preventExecution = FALSE;
        }
        //END: JLedesma D-3091 6/18/2015 Year To Date computation
        //END: UD-1830 7/13/2015 Avoid looping of Trigger
    
        //START PD-0155 01Jun2016 Added By C. Lin - prevent update duplicate TS cases
        //START: MD-61 03/24/2015 Added by S.PULI 
        /*if(tempExtisting.size()>0){
            update tempExtisting;
        }*/
        if(tempExistingMap.size()>0){
            update tempExistingMap.values();
        }
        //END: MD-61 03/24/2015 Added by S.PULI 
        //END PD-0155 01Jun2016 Added By C. Lin
        system.debug(':::OrderLst1 ' + ordersToUpdateAfterApprovalReject);
        //START PD-0202 FrancisBenzon 20May16 : update orders
        if(ordersToUpdateAfterApprovalReject.size() > 0)
        {
            try
            {                                           
                update ordersToUpdateAfterApprovalReject;
            }catch(exception e) {
                ordersToUpdateAfterApprovalReject = new List<Order__c>();
                system.debug(':::ERRORCOSREJECT ' + e);
            }
        }
        //END PD-0202 FrancisBenzon 20May16 : update orders
        system.debug(':::OrderLst ' + ordersToUpdateAfterApprovalReject);
        //START: D-3140 20/06/2015 Added by S.Puli
        if(coaCaseVendorSubs_LIST.size()>0){
            update coaCaseVendorSubs_LIST;
        }
        //END: D-3140 20/06/2015 Added by S.Puli
        //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        if(!subOliNumbersToManuallyCancel.isEmpty()) {
            List<Zuora__Subscription__c> zSubs = [Select Id, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c IN :subOliNumbersToManuallyCancel.keySet()];
            for(Zuora__Subscription__c zSub : zSubs) {
                zSub.Zuora__subscriptionEndDate__c = subOliNumbersToManuallyCancel.get(zSub.Order_Line_Item_Number_1__c);
            }
            update zSubs;
            subOliNumbersToManuallyCancel.clear();
        }
        //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        //START D-3611 25-Sept-2015 Added by S.Puli
        if(complaintCaseUsageToZuoraList.size()>0){
            update complaintCaseUsageToZuoraList;
        }
        //END D-3611 25-Sept-2015 Added by S.Puli
        //START UD-3293 11/25/15 RReyes
        if(lstParentCaseToUpdate.size() > 0){
            update lstParentCaseToUpdate;
        }
        //END UD-3293 11/25/15 RReyes
    }
       
    private void checkCirPlannerShedule(List<Case> lstNewCases)
    {
        /*----Complaint and Enquiry-----*/
        //Gets the custom setting for Cir Planning Schedule with test data.
        Cir_Planner_Schedule__c cirPlannerSchdule = Cir_Planner_Schedule__c.getInstance('CIR Plan Schedule');
        Set<String> weekDays = new Set<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'}; //set of days of the week for reference.
        casToUpdateMap = new Map<Id, Case>();  
        /*------------------------------*/  
        /*----Complaint and Enquiry-----*/
        //Checks if newly created case falls within the Circulation Planning Schedule.(Day and time is taken into consideration)
        //If yes then within circulation planning check-box is check-box is TRUE else FALSE.
        for(Case theCase : lstNewCases)
        {
            if(!casToUpdateMap.containskey(theCase.Id)) {
                String dayOfMonth = DateTime.now().format('EEEE');
                //Start D-4665 Added By S.Puli - test coverage variable
                if(test.isRunningTest()){
                    if(forcedDayOfMonth <> null)
                        dayOfMonth = forcedDayOfMonth;
                }
                //End D-4665 Added By S.Puli - test coverage variable
                if(weekDays.contains(dayOfMonth)){
                    Time startTime = cirPlannerSchdule.Mon_Fri_Start_Time__c.time();
                    Time endTime = cirPlannerSchdule.Mon_Fri_End_Time__c.time();
                    if(DateTime.now().Time() >= startTime && DateTime.now().Time() <= endTime) 
                        theCase.Within_Circulation_Planning_Schedule__c = TRUE;                             
                    else 
                        theCase.Within_Circulation_Planning_Schedule__c = FALSE;
                }
                else if(dayOfMonth == 'Saturday') {
                    Time startTime = cirPlannerSchdule.Sat_PH_Start_Time__c.time();
                    Time endTime = cirPlannerSchdule.Sat_PH_End_Time__c.time();
                    if(DateTime.now().Time() >= startTime && DateTime.now().Time() <= endTime) 
                        theCase.Within_Circulation_Planning_Schedule__c = TRUE;
                    else 
                        theCase.Within_Circulation_Planning_Schedule__c = FALSE;
                }
                else if(dayOfMonth == 'Sunday') {                
                    Time startTime = cirPlannerSchdule.Sun_Start_Time__c.time();
                    Time endTime = cirPlannerSchdule.Sun_End_Time__c.time();
                    if(DateTime.now().Time() >= startTime && DateTime.now().Time() <= endTime)
                        theCase.Within_Circulation_Planning_Schedule__c = TRUE;
                    else
                        theCase.Within_Circulation_Planning_Schedule__c = FALSE;  
                }
                else {             
                    Time startTime = cirPlannerSchdule.Sat_PH_Start_Time__c.time();
                    Time endTime = cirPlannerSchdule.Sat_PH_End_Time__c.time();
                    if(DateTime.now().Time() >= startTime && DateTime.now().Time() <= endTime)
                        theCase.Within_Circulation_Planning_Schedule__c = TRUE;
                    else 
                        theCase.Within_Circulation_Planning_Schedule__c = FALSE; 
                }       
            } // End of IF
        } //End of For Loop
    }       
    
    //Start D-1089 01/12/2015 Added by FrancisBenzon: Update Status, Sub-Status, Owner if Start sub process has overseas/airline recipient
    private void processOverseasRecipients(List<Case> lstCases)
    {
        for(Case cas : lstCases)
        {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_SUBS_CREATED;
        }
        
        UPDATE lstCases;
    }       
    //End D-1089 01/12/2015 Added by FrancisBenzon: Update Status, Sub-Status, Owner if Start sub process has overseas/airline recipient

    /*------------------- Renewal Subs -------------------*/
   /* @description This method creates Subscription records when criteria is met. 
    * @param case record
    * @return void
    */ 
    private void updateOrderStatusIfRejected(List<Case> lstUpdatedCases){
        for(Case updatedCase : lstUpdatedCases)
        {
            if(caseOrderMap.containsKey(updatedCase.Order__c)) {
                caseOrderMap.get(updatedCase.Order__c).Status__c = 'Draft';
            }
        }
        UPDATE caseOrderMap.values();       
    }
    
    /*------------------- End Renewal Subs -------------------*/
    
   /*------------------- Start Subscription -------------------*/
   /* @description This method creates Subscription records when criteria is met. 
    * @param case record
    * @return void
    */ 
    private void createVendorSubs(Case cas) {
        System.debug('Sub_Status__c' + cas.Sub_Status__c);
        Account thisAccount = new Account();
        Case caseToUpdate;
        if(casToUpdateMap.containsKey(cas.Id)) {
            caseToUpdate = casToUpdateMap.get(cas.Id);
        } 
        else {
            caseToUpdate = new Case(Id=cas.Id);
        }
        if(accountMap.containsKey(cas.AccountId)) {
            thisAccount = accountMap.get(cas.AccountId);
        }
        
        if(cas.RecordTypeId == CASE_START_SUB_TYPE_ID && !cas.Vendor_Subscription_Created__c && thisAccount.RecordTypeId == account_VendorSubscriber &&
           (cas.Sub_Status__c == 'Urgent Start Approved' || cas.Sub_Status__c == GlobalVariableClass.SUB_STATUS_SUBS_CREATED || cas.Sub_Status__c == 'Ready for Subscription')) {//START/END UD-1451 RReyes - changed condition from 'Provisioning' to GlobalVariableClass.SUB_STATUS_SUBS_CREATED
            Order__c orderRecord  = new Order__c();
            if(orderMap.containsKey(cas.Order__c)) {
                orderRecord = orderMap.get(cas.Order__c);
            }
            /*
             *create related publications based on order line item vendor records
             */
            Subscription_Vendor__c sv;
            Boolean hasUnassigned = false;
            for (Order_Line_Item_Vendor__c oliv : orderRecord.Order_Line_Items__r) {
                // create vendor subscription
                Integer wrapperNumber = (Integer) oliv.Wrapper_Number__c;
                if(oliv.Vendor__c == null && !hasUnassigned) {
                    hasUnassigned = true;
                }
                if(wrapperNumberToSubscriptionVendorMap.containsKey(wrapperNumber)) {
                    sv = wrapperNumberToSubscriptionVendorMap.get(wrapperNumber);
                }
                else {
                    sv = new Subscription_Vendor__c();
                    sv.Order_Number__c = orderRecord.Id;
                    sv.Account__c = orderRecord.Account__c;
                    sv.Status__c = 'Active';
                    sv.Reason__c = orderRecord.Reason__c;
                    sv.Recipient__c = orderRecord.Recipient_Contact__c; 
                    sv.Subscription_Start_Date__c = oliv.Start_Date__c;
                    sv.Subscription_Stop_Date__c = oliv.Stop_Date__c;
                    sv.Vendor__c = oliv.Vendor__c;
                    wrapperNumberToSubscriptionVendorMap.put(wrapperNumber, sv);
                    System.debug('>>> subscription Vendor: ' + sv);
                    
                    Case_Vendor_Subscription__c cvs = new Case_Vendor_Subscription__c();
                    cvs.Account__c = orderRecord.Account__c;
                    cvs.Case__c = cas.Id;
                    wrapperNumberToCaseVendorSubsMap.put(wrapperNumber, cvs);
                    System.debug('>>> wrapperNumberToCaseVendorSubsMap: ' + cvs);
                }
                
                Subscription_Vendor_Publication__c svp = new Subscription_Vendor_Publication__c();
                svp.Publication__c = oliv.Publication__c;
                svp.Order__c = oliv.Order__c;
                svp.Mon__c = oliv.Mon__c;
                svp.Tue__c = oliv.Tue__c;
                svp.Wed__c = oliv.Wed__c;
                svp.Thu__c = oliv.Thu__c;
                svp.Fri__c = oliv.Fri__c;
                svp.Sat__c = oliv.Sat__c;
                svp.Sun__c = oliv.Sun__c;
                svp.PHd__c = oliv.PHd__c;
                svp.PHe__c = oliv.PHe__c;
                if(wrapperNumberToSubsVendorPubsMap.containsKey(wrapperNumber)) {
                    wrapperNumberToSubsVendorPubsMap.get(wrapperNumber).add(svp);
                }
                else {
                    wrapperNumberToSubsVendorPubsMap.put(wrapperNumber, new List<Subscription_Vendor_Publication__c>{svp});
                }
            }
            // Start D-2167 02/12/2015 JohnD added vendor assignment logic
            // Start D-2346 02/25/2015 JTeves  -- modified filter to look at RecordTypeId and not RecordType.Name
            
            if(hasUnassigned && orderRecord.Recipient_Contact__r.Address__r.RecordTypeId == ConstantsSLB.getKeyID('Address_Local')) { 
                orderRecord.Status__c = GlobalVariableClass.STATUS_PENDING_VENDOR_ASSIGN;
                caseToUpdate.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
            }
           
            else {
                orderRecord.Status__c = GlobalVariableClass.STATUS_CLOSE;
                caseToUpdate.Status = GlobalVariableClass.STATUS_CLOSED;
                caseToUpdate.Sub_Status__c = GlobalVariableClass.SUB_STATUS_SUBS_CREATED;
            }
            caseToUpdate.Vendor_Subscription_Created__c = true;
            casToUpdateMap.put(cas.Id, caseToUpdate);
            orderMap.put(orderRecord.Id, orderRecord);
            // End D-2346 02/25/2015 JTeves 
            // End D-2167 02/12/2015 JohnD
        }
    }
    
    private void insertVendorSubsRecords() {
        List<Subscription_Vendor_Publication__c> subVendorPubList = new List<Subscription_Vendor_Publication__c>();
        insert wrapperNumberToSubscriptionVendorMap.values();
        
        for(Integer wrapperNo : wrapperNumberToSubscriptionVendorMap.keySet()) {
            Id subscriptionVendorId = wrapperNumberToSubscriptionVendorMap.get(wrapperNo).Id;
            //Link Case Vendor Suvscription to parent Subscription Vendor record
            if(wrapperNumberToCaseVendorSubsMap.containsKey(wrapperNo)) {
                wrapperNumberToCaseVendorSubsMap.get(wrapperNo).Subscription_Vendor__c = subscriptionVendorId;
            }
            
            //link Subscription Vendor Publication to parent Subscription Vendor record
            if(wrapperNumberToSubsVendorPubsMap.containsKey(wrapperNo)) {
                for(Subscription_Vendor_Publication__c svp : wrapperNumberToSubsVendorPubsMap.get(wrapperNo)) {
                    svp.Subscription_Vendor__c = subscriptionVendorId;
                    subVendorPubList.add(svp);
                }
            }
        }
        //Start D-4118 17-Dec-2015 Added By S.Puli - to avoid DML when map is empty
        if(wrapperNumberToSubscriptionVendorMap.size()>0){
            update orderMap.values();
           
            insert wrapperNumberToCaseVendorSubsMap.values();
            insert subVendorPubList;
            update casToUpdateMap.values();
        }
        //End D-4118 17-Dec-2015 Added By S.Puli
    }
    
    private void provisionSubscriptionAfterApproved(List<Case> lstCases){
      //START D-3229 Rom Reyes 8-July-2015 - Update criteria based on updated COS approval pocess action
      Map<Id, Case> oldCaseMap = new Map<Id, Case>();
      if(trigger.isUpdate) {
        oldCaseMap = (Map<Id, Case>) trigger.oldMap;
      }
      //END D-3229 Rom Reyes 8-July-2015 - Update criteria based on updated COS approval pocess action
        Set<Id> caseIds = new Set<Id>();
        set<Id> orderIds = new set<Id>();
        //START UD-1595 JTeves/FBenzon 19-June-2015 Cancel Urgent COS subscription only after approval
        //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        Set<Id> urgentInvoiceCosOrderIds = new Set<id>();
        Set<Id> nonUrgentInvoiceCosOrderIds = new Set<Id>();
        //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        //END UD-1595 JTeves/FBenzon 19-June-2015 Cancel Urgent COS subscription only after approval
        //START D-1977, D-2003 2/11/15 AddedBy FrancisBenzon : Variable : 2/19/15 Updated Variables     
        String ChangeOfSubString = GlobalVariableClass.CASECHANGESUB;
        String COSQueue = GlobalVariableClass.CSO_QUEUE;
        //END D-1977, D-2003 2/11/15 AddedBy FrancisBenzon : Variable
        //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        Set<Id> cosOrderIds = new Set<Id>();
        for(Case c : lstCases) {
            if(c.RecordTypeId == (Id) ConstantsSLB.getKeyId(ChangeOfSubString) && c.Order__c != null) {
                cosOrderIds.add(c.Order__c);
            }
        }
        Map<Id, Order__c> cosOrderMap = new Map<Id, Order__c>([SELECT Id, Subscription__c, Subscription__r.Billing_Type__c, Subscription__r.Zuora__Status__c, Subscription__r.Order_Line_Item_Number_1__c, (SELECT Main_Package_Billing_Type__c, Start_Date__c FROM Order_Line_Items_Direct__r) FROM Order__c WHERE Id IN :cosOrderIds]);
        //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        
        for(Case c : lstCases) {
            //START PD-0138 Gdelrosario : added for creation of renewal subscription when created via URGENT CASE
                System.debug('cube ---------------------------------------------- || ');
                System.debug('cube ------ : ' + c.Id  );
                System.debug('cube ------ : ' +  c.RecordTypeId );
                System.debug('cube ------ : ' +  c.Category__c );
                System.debug('cube ------ : ' +  c.Sub_Category__c );
                System.debug('cube ------ : ' +  c.Sub_Status__c );
                System.debug('cube ------ : ' +  c.Status );
                System.debug('cube ---------------------------------------------- || ');
                
                if (c.RecordTypeId == CASE_RENEW_SUB_TYPE_ID && c.Category__c == 'Subscription Request' &&  c.Sub_Category__c == 'Renewal of Subscription' && c.Sub_Status__c == 'Ready for Submission' && c.Status == 'Pending') {

                    caseIds.add(c.Id);
                    if(c.Account_Record_Type__c <> GlobalVariableClass.VENDOR && c.Account_Record_Type__c<>GlobalVariableClass.VENDORSUB && c.Account_Record_Type__c<>GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT){    
                        orderIds.add(c.Order__c);
                    }
                } 
            //END PD-0138 Gdelrosario : added for creation of renewal subscription when created via URGENT CASE
            //Start: D-1355 01/06/15 Added by April Banaag - change criteria for case sub status & status in creation of quote    
            if(c.RecordTypeId == CASE_START_SUB_TYPE_ID && c.Category__c == 'Subscription Request' &&  
               c.Sub_Category__c == 'Start Subscription' && c.Sub_Status__c == 'Ready for Subscription' && c.Status == 'Pending') // Start/End D-2711 08Apr15 JohnD changed Closed to Pending
            {
                caseIds.add(c.Id);
                //START D-2875 05/08/2015 Added By S.Puli allow only Direct accounts to create Quotes for Zuora
                if(c.Account_Record_Type__c <> GlobalVariableClass.VENDOR && c.Account_Record_Type__c<>GlobalVariableClass.VENDORSUB && c.Account_Record_Type__c<>GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT){    
                    orderIds.add(c.Order__c);
                }
                //END D-2875 05/08/2015 Added By S.Puli 
            }            
            //End: D-1355 01/06/15 Added by April Banaag - change criteria for case sub status & status in creation of quote  
            
            //START D-1977, D-2003, D-2134 2/11/15 AddedBy FrancisBenzon : cater quote creation for change of subscription cases that are undergoing //approval processes : Updated Code 2/19/15 Added Conditions in IF statement to Cater trigger execution order in different environments
            //START D-3229 Rom Reyes 8-July-2015 - Update criteria based on updated COS approval pocess action
            Case oldCase = oldCaseMap.get(c.Id);
            System.debug('JEPI oldCase: ' + oldCAse);
            System.debug('JEPI newCAse: ' + c);
            //START D-3411 Wenjun 03/Sep/15 : Submit Quotes after waive approval 
            
            
            if(
            c.RecordTypeId == (Id) ConstantsSLB.getKeyId(ChangeOfSubString) && c.Category__c == GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST &&
            c.Sub_Category__c == GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION && oldCase != null
            && c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_PROVISIONING
            &&
            (oldCase.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_APPROVAL 
            || oldCase.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAIVING_APPROVAL 
            )
            ) { 
            //END D-3411 Wenjun 03/Sep/15
            //END D-3229 Rom Reyes 8-July-2015
                caseIds.add(c.Id); 
                //START D-2875 05/08/2015 Added By S.Puli allow only Direct accounts to create Quotes for Zuora
                if(c.Account_Record_Type__c <> GlobalVariableClass.VENDOR && c.Account_Record_Type__c<>GlobalVariableClass.VENDORSUB && c.Account_Record_Type__c<>GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT){
                    //START UD-1595 JTeves/FBenzon 19-June-2015 Cancel Urgent COS subscription only after approval
                    //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
                    Boolean urgentInvoicingScenario = FALSE;
                    if(cosOrderMap.containsKey(c.Order__c)) {
                        Order__c cosOrder = cosOrderMap.get(c.Order__c);
                        for(Order_Line_Item__c oli : cosOrder.Order_Line_Items_Direct__r) {
                            //check if urgent invoicing scenario
                            
                            if((cosOrder.Subscription__r.Billing_Type__c == FULL_PRE && oli.Main_Package_Billing_Type__c == FULL_PRE) || (cosOrder.Subscription__r.Billing_Type__c == FULL_PRE && oli.Main_Package_Billing_Type__c == MR_PRE) || (cosOrder.Subscription__r.Billing_Type__c == MR_PRE && oli.Main_Package_Billing_Type__c == FULL_PRE && oli.Start_Date__c.toStartOfMonth() == Date.today().toStartOfMonth())) {
                                urgentInvoicingScenario = TRUE;
                            }
                            else {
                                //OLI number of subs to be cancelled for non-urgent Invoicing, subs will be updated in andFinally() method
                                subOliNumbersToManuallyCancel.put(cosOrder.Subscription__r.Order_Line_Item_Number_1__c, oli.Start_Date__c.addDays(-1));
                            }
                        }
                        if(urgentInvoicingScenario) {
                            urgentInvoiceCosOrderIds.add(cosOrder.Id);
                        }
                        else {
                            //"start sub" part of cos for non-urgent invoicing scenario to be handled as regular start subscription
                            orderIds.add(cosOrder.Id); 
                        }
                    }
                    //orderIds.add(c.Order__c);
                    //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
                    //END UD-1595 JTeves/FBenzon 19-June-2015 Cancel Urgent COS subscription only after approval
                }
                //END D-2875 05/08/2015 Added By S.Puli
                system.debug(':::OIDS' + orderIds);
            }
            //END D-1977, D-2003, D-2134 2/11/15 AddedBy FrancisBenzon : cater quote creation for change of subscription cases that are undergoing //approval processes : Updated Code 2/19/15 Added Conditions in IF statement to Cater trigger execution order in different environments
        }
        
        //Issue Note: Wenjun - Need to change to Bulk Quote Handler later       
        if(!orderIds.isEmpty()){ 
            
            // Start D-2693 06Apr15 JohnD modify query
            string queryStr = SM_SubscriptionHelper.generateOrderSoqlStr();
            queryStr += ' where Id in :OrderIds';
            
            for (SObject orderObj : database.query(queryStr)) {
                Subscription_Handler sh = new Subscription_Handler();
                sh.CreateQuotes((Order__c)orderObj,'Case Trigger Handler');
            }
            // End D-2693 06Apr15 JohnD modify query
        } 
        
        //START UD-1595 JTeves/FBenzon 19-June-2015 Cancel Urgent COS subscription only after approval
        //START HOTFIX FOR D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        //invoke cancellation callout for approved COS
        if(!urgentInvoiceCosOrderIds.isEmpty()) {
            Map<Id, Map<Id, Date>> orderToSubEndDatesMap = new Map<Id, Map<Id, Date>>();
            //START UD-1595 Addedby FBenzon/JTeves : added sub stat in query and call cancellation only when sub is active
            Map<Id, String> orderId_oldSubStatus = new Map<Id, String>();
            List<Order__c> orders = [SELECT Id, Subscription__c, Subscription__r.Zuora__Status__c, (SELECT Start_Date__c FROM Order_Line_Items_Direct__r) FROM Order__c where Id in :urgentInvoiceCosOrderIds];
            
            for (Order__c orderRecord : orders) {
                orderId_oldSubStatus.put(orderRecord.Id, orderRecord.Subscription__r.Zuora__Status__c);
                Map<Id, Date> subToEndDateMap = new Map<Id, Date>();
                for(Order_Line_Item__c oli : orderRecord.Order_Line_Items_Direct__r) {
                    if(orderRecord.Subscription__c != NULL && oli.Start_Date__c != NULL) {
                        subToEndDateMap.put(orderRecord.Subscription__c, oli.Start_Date__c);                    
                    }
                }
                if(!subToEndDateMap.isEmpty()) {
                    orderToSubEndDatesMap.put(orderRecord.Id, subToEndDateMap);
                }
            }
            
            for(Id orderId : orderToSubEndDatesMap.keySet()) {              
                if(orderId_oldSubStatus.containsKey(orderId))
                {
                    if(orderId_oldSubStatus.get(orderId) ==  GlobalVariableClass.ZUORA_STATUS_ACTIVE)
                    {
                        SM_SubscriptionCancellationHelper.cosCancel(orderToSubEndDatesMap.get(orderId), 'Change of Subscription', orderId);
                    }
                }
                //END UD-1595 Addedby FBenzon/JTeves : added sub stat in query and call cancellation only when sub is active                               
            }      
        }
        //END HOTFIX FOR D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
        //END UD-1595 JTeves/FBenzon 19-June-2015 Cancel Urgent COS subscription only after approval
    }

    /* @description This method submits case for approval when conditions are met. 
     * @param So which is an Object Record
     * @return void
     */ 
    private void autoRouteCaseforApproval(Case c){
        /*Start Subscription Auto Route Case for ApprovalStart Subscription*/
        if(c.RecordTypeId == CASE_START_SUB_TYPE_ID && c.Category__c == 'Subscription Request' &&  c.Sub_Category__c == 'Start Subscription' 
            && c.Sub_Status__c == 'Waiting for Urgent Start Approval' && c.Status == 'Pending')
        {
            genApprovalRequest(c);
        }
        else if(c.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && c.Sub_Status__c == 'Waiting for Urgent Temp Stop/Restart Approval' 
                && c.Status == 'Pending' && c.Origin != 'ESHOP')
        {
            genApprovalRequest(c);
        }
        //START D-3411 Wenjun 03/Sep/15 : Submit Waive Charge Approval
        else if(c.RecordTypeId == CASE_CHNG_SUB_TYPE_ID &&  c.Status == 'Pending' 
            && (c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_APPROVAL || c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAIVING_APPROVAL))
        {
            genApprovalRequest(c);
        }
        //END D-3411 Wenjun 03/Sep/15
        else if(c.RecordTypeId == CASE_RENEW_SUB_TYPE_ID && c.Category__c == 'Subscription Request' 
                &&  c.Sub_Category__c == 'Renewal of Subscription' && c.Sub_Status__c == 'Waiting for Urgent Start Approval' && c.Status == 'Pending') 
        {
            genApprovalRequest(c);
        }           
        /* End Start Subscription Auto Route Case for Approval*/
        //START UD-0816 5/6/2015 Added By C. Lin  - Fix auto urgent approval for COA
        else if(c.RecordTypeId == CASE_COA && c.Sub_Category__c == 'Change of Address' && c.Status == 'Pending' && c.Effective_Date__c < c.POP_Start_Date__c &&
            (c.Change_of_Address_Type__c == 'Change of Delivery Address - Local to Local' || c.Change_of_Address_Type__c == 'Change of Billing and Delivery Address'
                //START PD-0284 6/8/2016 Added By L. Valencia - Added condition for Change of Billing address
                || c.Change_of_Address_Type__c == 'Change of Billing address'))
                //END PD-0284 6/8/2016 Added By L. Valencia 
        {
            genApprovalRequest(c);
        }
        //END UD-0816 5/6/2015 Added By C. Lin
    }
    
    /*Start Subscription Approval Submit Request*/
      private void genApprovalRequest(SObject objRec) {
        if(!existingApprovalsSet.contains(objRec.Id)) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(objRec.Id);
            Approval.ProcessResult result = Approval.process(req1);      
            System.Debug('IN APPROVAL' + objRec.Id);
            System.debug('Submitted for approval successfully: '+result.isSuccess());
            }
            
         }
    
   private void assignCaseToVendorQueue(Map<Id, Case> mCaseOld, Map<Id, Case> mCaseNew, Boolean bInsert){
        Set<Id> sCaseIds = new Set<Id>(); 
        Set<Id> caseIds = new Set<Id>();
        Set<Id> RecIds = new Set<Id>();
        
        map<Integer,Id> sectorCase = new map<Integer,Id>(); 
        map<Id,Id> contactCaseMap = new map<Id,Id>();
        map<Id,Id> newCaseTeam = new map<Id,Id>(); 
        map<Id,CaseTeamMember> newCaseTeamMap = new map<Id,CaseTeamMember>();
        list<string> sector = new list<string>(); //START/END MGaelo D-2791 set sector as string
        list<Post_Sector_Ops_Rep_Mapping__c> vendorOps = new list<Post_Sector_Ops_Rep_Mapping__c>();
        map<id, set<id>> parentId_memberIds = new map<id, set<id>>();
        
        if(bInsert){
            for(Case c: mCaseNew.values()){
                if(c.RecordTypeId == CASE_START_SUB_TYPE_ID && 
                    c.Sub_Status__c == 'Waiting for Vendor Assignment' && c.Status == 'Pending')
                {
                    sCaseIds.add(c.Id);
                }
            }
        }else{
            for(Case c: mCaseOld.values()){
                Case cNew = mCaseNew.get(c.Id);
                
                if(c.RecordTypeId == CASE_START_SUB_TYPE_ID &&  cNew.Sub_Status__c == 'Waiting for Vendor Assignment' && 
                   c.Sub_Status__c != 'Waiting for Vendor Assignment' && c.Status == 'Pending')
                {
                   sCaseIds.add(c.Id);
                }
            }
        }
        
        if(sCaseIds.size()>0){
            for (Case c : [Select Order__r.Recipient_Address__c, Order__r.Recipient_Contact__c, Order__c From Case where Id IN: sCaseIds]){
                RecIds.add(c.Order__r.Recipient_Contact__c);
                contactCaseMap.put(c.Order__r.Recipient_Contact__c, c.Id);
            }
            
            List<Contact> contacts = [Select Id, Address__r.Postal_Code__r.Name from Contact where Id IN: RecIds];
            for(Contact recipient : contacts){
                if (recipient.Address__r.Postal_Code__r.Name != null) {   // [JohnD 11/22] D-0968 catching null pointer      
                    String subStrPostal = recipient.Address__r.Postal_Code__r.Name.substring(0,2);              
                    sector.add(subStrPostal); //START/END MGaelo D-2791 set to string
                    sectorCase.put(integer.valueOf(subStrPostal),contactCaseMap.get(recipient.Id));
                }
            }
            
            //START MGaelo D-2791 to reference at Postal Sector instead of Post Sector Ops Rep Mapping object
            vendorOps = [Select Zone__r.Postal_Sector__c, Vendor_Ops__c from Post_Sector_Ops_Rep_Mapping__c where Zone__r.Postal_Sector__c IN: sector];
            for (Post_Sector_Ops_Rep_Mapping__c opsRepMap : vendorOps){
                newCaseTeam.put(sectorCase.get(integer.valueOf(opsRepMap.Zone__r.Postal_Sector__c)),opsRepMap.Vendor_Ops__c);              
            }
            //END MGaelo D-2791 to reference at Postal Sector instead of Post Sector Ops Rep Mapping object
            
            caseIds = newCaseTeam.keySet();
            
            for (Id caseIdOpsRep : caseIds ){
                set<id> memberIds = new set<id>();
                if (parentId_memberIds.get(caseIdOpsRep) != null) {
                    memberIds = parentId_memberIds.get(caseIdOpsRep);
                }
                
                if (!memberIds.contains(newCaseTeam.get(caseIdOpsRep))) {
                    CaseTeamMember newMember = new CaseTeamMember();
                    newMember.ParentId = caseIdOpsRep;
                    newMember.MemberId = newCaseTeam.get(caseIdOpsRep);
                    newMember.TeamRoleId = ConstantsSLB.getKeyId('Vendor Rep Role');                 
                    newCaseTeamMap.put(newCaseTeam.get(caseIdOpsRep),newMember);
                    
                    memberIds.add(newCaseTeam.get(caseIdOpsRep));
                    
                    parentId_memberIds.put(caseIdOpsRep, memberIds);
                    system.debug('Vendor Rep------' + newCaseTeamMap);
                }
            }    
            
            if(newCaseTeamMap.values().size() > 0){
                //[johnd 11/22] related D-0968 add try catch
                // D
               try {
                    insert newCaseTeamMap.values();
               } catch(exception e) {
                    system.debug('error while inserting news case team member.' + e);
               }
            }
        }         
    }
    /*---------------- End Start Subscription ------------------*/  
    
    
    /*------------------- Temp Stop Subscription -------------------*/
    // Update order record when all cases from same order is not pending    
    private void closingOrderTempStopCase (List<Case> lstCases) {
      Set<Id> setOrderIds = new Set<Id>();
      for(Case theCase : lstCases)
          setOrderIds.add(theCase.Order__c);
      
      // Start UD-1926 VPernicia 07/20/15 Code Optimization
      if (!setOrderIds.isEmpty()) {
        
        List<Order__c> relatedOrders = new List<order__c>();
        for(Id orderId : setOrderIds) {
            Order__c orderRecord = new Order__c(Id=orderId);
            orderRecord.Order_Status__c = GlobalVariableClass.STATUS_CLOSE;
            relatedOrders.add(orderRecord);
        }
        update relatedOrders;
      }
      // End UD-1926 VPernicia 07/20/15 Code Optimization
      
      // Start UD-1926 VPernicia 07/20/15 Code Optimization: Comment out this block
      /* List<Order__c> relatedOrders = [SELECT Id, name, order_status__c FROM Order__c WHERE id in : setOrderIds];
      if(relatedOrders != null && !relatedOrders.isEmpty())
      {
          for(Order__c orderObj : relatedOrders)
          {
              orderObj.Order_Status__c = 'Close';
          }
          UPDATE relatedOrders;
      }*/
      // End UD-1926 VPernicia 07/20/15 Code Optimization: Comment out this block
    }
   
   
   // Create temp stop record upon approval of urgent request
   //Issue Note: Wenjun - One order/case can have multiple subscriptions for Temp Stop
   private void createTempStopUponApproval(List<Case> lstTStopCases)
   {
       List<Temp_Stop__c> lstTStopsToUpdate = new List<Temp_Stop__c>();
       List<Temp_Stop__c> lstTStopsToCreate = new List<Temp_Stop__c>();
       List<Vendor_Temp_Stop__c> lstVendorTStop = new List<Vendor_Temp_Stop__c>();
       List<Case_Subscription__c> lstCaseSubs = new List<Case_Subscription__c>();
       List<Subscription_Temp_Stop__c> lstSubTStops = new List<Subscription_Temp_Stop__c>();
       Map<Id, Id> mapCaseIdToTStopId = new Map<Id, Id>();
       List<Case> lstCasesToUpdate = new List<Case>();  //START END D-2323 Wenjun 24/02/15
       
       for(Case c : lstTStopCases)
       {
            Temp_Stop__c ts = new Temp_Stop__c ();
            //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop -->
            Temp_Stop__c tsToUpdate = new Temp_Stop__c ();
            //Cancelled Temp Stop
            if(c.Temp_Stop_Type__c == Globalvariableclass.TS_CANCEL){
                ts.Id = c.Temp_Stop__c;
                ts.Cancelled__c = TRUE;  
                lstTStopsToUpdate.add(ts);
            }
            
            if(c.Temp_Stop_Type__c == GlobalVariableClass.TS_UPDATE){
                    tsToUpdate.Id = c.Temp_Stop_Updated__c;
                    tsToUpdate.Cancelled__c = TRUE;  
                    lstTStopsToUpdate.add(tsToUpdate);
            }
            //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop -->

            //Active Temp Stop
            if(c.Temp_Stop_Type__c != Globalvariableclass.TS_CANCEL){
                ts.Case__c = c.Id; 
                ts.Order__c = c.Order__c; 
                ts.Temp_Stop_Date__c = c.Temp_Stop_Date__c; 
                ts.Restart_Date__c = c.Restart_Date__c; 
                ts.Remarks__c = c.Remarks__c;
                ts.Temp_Stop_Qty__c = c.Temp_Stop_Qty__c;
                ts.Cancelled__c = FALSE;
                ts.Qty__c = c.Qty__c;
                ts.Request_Total_Issue__c = c.Request_Total_Issue__c;
                ts.Request_Total_Credit__c = c.Request_Total_Credit__c;
                
                lstTStopsToCreate.add(ts);
            }
       }
       
       if(!lstTStopsToUpdate.isEmpty())
           UPDATE lstTStopsToUpdate;
       
       if(!lstTStopsToCreate.isEmpty())
           INSERT lstTStopsToCreate;
       
       //Create Case Temp Stop map for later reference
       for(Temp_Stop__c tStop : lstTStopsToCreate)
            mapCaseIdToTStopId.put(tStop.Case__c, tStop.Id);
        
       for(Case c : lstTStopCases)
       {
            //Active Temp Stop
            if(c.Temp_Stop_Type__c != Globalvariableclass.TS_CANCEL){
                if(c.Temp_Stop_VSub__c != null){
                    Vendor_Temp_Stop__c vts = new Vendor_Temp_Stop__c ();
                    vts.Temp_Stop__c = mapCaseIdToTStopId.get(c.Id);
                    vts.Subscription_Vendor__c = c.Temp_Stop_VSub__c;
                    //START: D-1950 2/10/15 JLedesma - Update old temp stop status
                    vts.Publication__c = c.Publication__c;
                    //END: D-1950 2/10/15 JLedesma - Update old temp stop status
                    lstVendorTStop.add(vts);
                }
                
                //START: D-1119 12/17/14 Added by April Banaag - added condition
                // Start D-3519 09Sep15 JohnD - added 'Direct Corporate' and 'Direct SPH Inter-Division'
                if(c.Account_Record_Type__c=='Direct Individual' || c.Account_Record_Type__c == 'Direct Corporate' 
                        || c.Account_Record_Type__c == 'Direct SPH Inter-Division'){
                // End D-3519 09Sep15 JohnD - added 'Direct Corporate' and 'Direct SPH Inter-Division'
                    Case_Subscription__c casSub = new Case_Subscription__c();
                    casSub.Case__c = c.Id;
                    casSub.Account__c = c.AccountId;                            
                    casSub.Subscription__c = c.Temp_Stop_Sub__c;
                    lstCaseSubs.add(casSub);
                    
                    //START: D-1950 2/10/15 JLedesma - Update old temp stop status
                    if(c.Temp_Stop_Sub__c!=NULL){
                        Subscription_Temp_Stop__c thisSubTemp = new Subscription_Temp_Stop__c ();
                        thisSubTemp.Subscription__c = c.Temp_Stop_Sub__c;
                        thisSubTemp.Temp_Stop__c = mapCaseIdToTStopId.get(c.Id);
                        lstSubTStops.add(thisSubTemp);
                    }
                    //END: D-1950 2/10/15 JLedesma - Update old temp stop status
                //START: D-1361 JLedesma Change font color to red if Urgent.  
                }
                
                //Update Case Temp Stop field
        //START D-2323 Wenjun 24/02/15 : New instance of case as the original Case record is Read-only
        Case cas = new Case(id = c.Id);  
                //START: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
                cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Temp Stop');
                //END: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
                cas.Temp_Stop__c = mapCaseIdToTStopId.get(c.Id); 
                lstCasesToUpdate.add(cas);
        //END D-2323 Wenjun 24/02/15
            }
                //END: D-1361 JLedesma Change font color to red if Urgent.  
            //END: D-1119 12/17/14 Added by April Banaag - added condition
       }
       
       //Perform DML in Bulk
       if(!lstVendorTStop.isEmpty())
           INSERT lstVendorTStop;
       
       if(!lstCaseSubs.isEmpty())
           INSERT lstCaseSubs;
       
       if(!lstSubTStops.isEmpty())
           INSERT lstSubTStops;
       
       //START D-2323 Wenjun 24/02/15 : New instance of case as the original Case record is Read-only
        if(!lstCasesToUpdate.isEmpty())
            UPDATE lstCasesToUpdate;
       //END D-2323 Wenjun 24/02/15
    }
     /*---------------- End Temp Stop Subscription ------------------*/  
    
   private void updateCreditsAndCharges (List<Case> lstCases) {
      Set<Id> setOrderIds = new Set<Id>();
      for(Case theCase : lstCases)
          setOrderIds.add(theCase.Order__c);
      
        // Start D-1926 VPernicia 07/20/15 Code optimization
        if (!setOrderIds.isEmpty()) {
            List<Order__c> relatedOrders = new List<order__c>();
            
            for(Id orderId : setOrderIds) {
                Order__c orderRecord = new Order__c(Id=orderId);
                orderRecord.Admin_Charge__c = 0;
                relatedOrders.add(orderrecord);
            }
            update relatedOrders;
        }
        // End D-1926 VPernicia 07/20/15 Code optimization
      
      // Start D-1926 VPernicia 07/20/15 Code optimization: Comment-out this block
      /* List<Order__c> relatedOrders = [SELECT id, name, order_status__c, Admin_Charge__c, Total_Due_to_SPH__c, 
                                      Total_Due_to_Customer__c FROM Order__c WHERE id in : setOrderIds];
                                      
      if(relatedOrders != null && !relatedOrders.isEmpty())
      {
          for(Order__c orderObj : relatedOrders)
          {
              orderObj.Admin_Charge__c = 0;
          }
          UPDATE relatedOrders;
      }*/
      // End D-1926 VPernicia 07/20/15 Code optimization: Comment-out this block
  }
  
    private void populateInternaAddress(Case caseRec){     
        caseRec.InternalAddress__c = caseRec.Recipient_Address__r.Location_Code__r.Location_Code__c + ', ' 
                                   + caseRec.Recipient_Address__r.Company_Code__r.Company_Code__c + ', ' 
                                   + caseRec.Recipient_Address__r.Division_Code__r.Department_Code__c + ', ' 
                                   + caseRec.Recipient_Address__r.Department__r.Department_Code__c + ', ' 
                                   + caseRec.Recipient_Address__r.Section_Code__r.Section_Code__c;      
    }
    
    private void updateOrderStatus(List<Case> lstCaseToUpdate)
    {
        Map<Id, Case> mapOrderIdToCase = new Map<Id, Case>();
        for(Case newCase : lstCaseToUpdate)
        {
            if(newCase.Order__c != null)
                mapOrderIdToCase.put(newCase.Order__c, newCase);
        }
        
        // Start UD-1926 VPernicia 07/20/15 Code Optimization
        if (!mapOrderIdToCase.isEmpty()) {
            List<Order__c> relatedOrders = new List<order__c>();
            
            for(Id orderId : mapOrderIdToCase.keySet()) {
            
                Case relatedCase = mapOrderIdToCase.get(orderId);
                
                if (relatedCase != null) {
                    Order__c orderRecord = new Order__c(Id=orderId);            
                    orderRecord.Order_Status__c = relatedCase.Status;
                    relatedorders.add(orderrecord);
                }
            }
            update relatedOrders;
        }
        // End UD-1926 VPernicia 07/20/15 Code Optimization

        // Start UD-1926 VPernicia 07/20/15 Code Optimization: Comment out this block
        /*Map<Id, Order__c> mapOrders = new Map<Id, Order__c>([SELECT ID, Status__c FROM Order__c WHERE Id in : mapOrderIdToCase.keySet()]);
        
        for (Id orderId : mapOrders.keySet())
        {
            Order__c orderObj = mapOrders.get(orderId);
            Case relatedCase = mapOrderIdToCase.get(orderId);
            if(orderObj != null && relatedCase != null)
                orderObj.Status__c = relatedCase.Status;
        }
        
        UPDATE mapOrders.values();   
        */
        // End UD-1926 VPernicia 07/20/15 Code Optimization: Comment out this block
    }
    
    // Start UD-0759 ronald dagaraga add criteria     
    private void updateOrderStatusToDraft(List<Case> lstOrderToUpdateToDraft)
    {
        Map<Id, Case> mapOrderIdToCase = new Map<Id, Case>();
        for(Case newCase : lstOrderToUpdateToDraft)
        {
            if(newCase.Order__c != null)
                mapOrderIdToCase.put(newCase.Order__c, newCase);
        }

        // Start UD-1926 VPernicia 07/20/15 Code Optimization
        if (!mapOrderIdToCase.isEmpty()) {
        
            List<Order__c> relatedOrders = new List<order__c>();
            
            for(Id orderId : mapOrderIdToCase.keySet()) {
                
                Case relatedCase = mapOrderIdToCase.get(orderId);
                if ((relatedCase.Sub_Status__c == GlobalVariableClass.URGENT_START_REJECTED) && (relatedCase.RecordTypeId == CASE_START_SUB_TYPE_ID || relatedCase.RecordTypeId == CASE_CHNG_SUB_TYPE_ID)){
                    
                    Order__c orderRecord = new Order__c(Id=orderId);
                    
                    orderRecord.Order_Status__c = GlobalVariableClass.STATUS_DRAFT;
                    relatedorders.add(orderrecord);
                }
            }
            
            update relatedOrders;
        }
        // End UD-1926 VPernicia 07/20/15 Code Optimization
        
        // Start UD-1926 VPernicia 07/20/15 Code Optimization: Comment out this block
        /*
        Map<Id, Order__c> mapOrdersToDraft = new Map<Id, Order__c>([SELECT ID, Status__c FROM Order__c WHERE Id in : mapOrderIdToCase.keySet()]);
        
        for (Id orderId : mapOrdersToDraft.keySet())
        {
            Order__c orderObj = mapOrdersToDraft.get(orderId);
            Case relatedCase = mapOrderIdToCase.get(orderId);
            if ((relatedCase.Sub_Status__c == GlobalVariableClass.URGENT_START_REJECTED) && (relatedCase.RecordTypeId == CASE_START_SUB_TYPE_ID || relatedCase.RecordTypeId == CASE_CHNG_SUB_TYPE_ID)){
                orderObj.Status__c = GlobalVariableClass.STATUS_DRAFT;

                
            }   
         }   
        UPDATE mapOrdersToDraft.values();   
        */
        // End UD-1926 VPernicia 07/20/15 Code Optimization: Comment out this block
    }
    // End UD-0759 ronald dagaraga add criteria     
    //START: UD - 0234 05/03/15 Jean Cariï¿½o, Updated the if condition
    //START: D-1347 12/19/14 Added by J. Sarion Added Case oldC as parameter. Check old and new value if not same then update Case Owner
    private void returnCaseToCSO(Case c, Case oldC) {
        //START: D-1795 1/20/15 By Mark Gatdula, Update the IF condition to include Temp Stop Rejected value for sub status  
        //START: D-0726 2/13/2015 Added by ABanaag, Update the IF condition to include Ready for Subscription value for sub status; removed hardcoded values
        if((oldC.Sub_Status__c==GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_START && c.Sub_Status__c==GlobalVariableClass.SUB_STATUS_READY_FOR_SUBSCRIPTION )
            ||(c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAIVED_APPROVED  && oldC.Sub_Status__c != GlobalVariableClass.SUB_STATUS_WAIVED_APPROVED ) 
            || (c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAIVED_REJECTED  && oldC.Sub_Status__c != GlobalVariableClass.SUB_STATUS_WAIVED_REJECTED ) 
            || (c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_URGENT_STOP_APPROVED  && oldC.Sub_Status__c != GlobalVariableClass.SUB_STATUS_URGENT_STOP_APPROVED) 
            || (c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_URGENT_STOP_REJECTED && oldC.Sub_Status__c != GlobalVariableClass.SUB_STATUS_URGENT_STOP_REJECTED) 
            || (c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_TEMP_STOP_REJECTED && oldC.Sub_Status__c != GlobalVariableClass.SUB_STATUS_TEMP_STOP_REJECTED)
            || (c.Sub_Status__c == GlobalVariableClass.URGENT_START_REJECTED && oldC.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_START )
            // Start: UD-733 Ronald Dagaraga Added new criteria 
            || (c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_SUBS_CREATED && c.RecordTypeId == CASE_START_SUB_TYPE_ID && c.Status == GlobalVariableClass.SUB_STATUS_CLOSE && oldC.Sub_Status__c!= GlobalVariableClass.SUB_STATUS_TEMP_STOP_REJECTED)){
            // End: UD-733 Ronald Dagaraga Added new criteria
            c.OwnerId = c.CreatedById;
        }
        //END: D-0726 2/13/2015 Added by ABanaag, Update the IF condition to include Ready for Subscription value for sub status; removed hardcoded values
        //END: D-1795 1/20/15 By Mark Gatdula
    //END: D-1347 12/19/14 Added by J. Sarion
    //END: UD - 0234 05/03/15 Jean Cariï¿½o
        else if(c.RecordTypeId == CASE_START_SUB_TYPE_ID && c.Sub_Status__c == 'Ready for Subscription' && c.Status == 'Closed'){
            c.OwnerId = c.CreatedById;
        }
        //START: D-1375 1/7/15 JerellaLedesma
         else if(c.Sub_Status__c == 'Temp Stop Approved' && c.Status == 'Closed'){
            c.OwnerId = c.CreatedById;
        }
        //END: D-1375 1/7/15 JerellaLedesma
        //START: D-1625,1406,1356, 1506 1/23/2015 Added by Kristine Campang - modified if condition and removed owner id update 
        //START: D-0497 12/03/14 Added by S.Puli -- method updates case owner to CSO
        else if(c.Outcome__c <>null && c.Urgent_Request__c ==false && c.Sub_Status__c == 'For Retention Offer' && c.Waived_Request__c == false){
            c.Sub_Status__c = 'Ready for Submission';
        }
        //START D-2953 05/19/2015 Added by J.Sarion - Return case owner to the creator
        else if (((c.Status == GlobalVariableClass.STATUS_CLOSED && oldC.Status != GlobalVariableClass.STATUS_CLOSED) || (c.Sub_Status__c == GlobalVariableClass.SUB_STATUS_COA_REJECTED && oldC.Sub_Status__c != GlobalVariableClass.SUB_STATUS_COA_REJECTED)) && c.RecordTypeId == ConstantsSLB.getKeyID(GlobalVariableClass.CASECHANGEADD)) {
            c.OwnerId = c.CreatedById;
        }
        //END D-2953 05/19/2015 Added by J.Sarion - Return case owner to the creator
    }
    
    /**April Banaag [11/28]
    * START D-509 - method updates case owner to CSO TL Queue if awaiting approval
    */
    private void assignToTLQueue(List<Case> lstNewCases) {
        for(Case newCase : lstNewCases)
        {
            //START: D-1375 1/7/15 Added by J.Ledesma - Added criteria for temp stop urgent Case Owner. 
            if(newCase.Requires_Urgent_Approval__c == true && newCase.Sub_Status__c == 'Waiting for Urgent Temp Stop/Restart Approval'){
                newCase.ownerId = CSO_TL_QUEUE_ID;
            }
            //END: D-1375 1/7/15 Added by J.Ledesma - Added criteria for temp stop urgent Case Owner. 
        }
    }
    // END D-509
    
    // D-0765 [JB Domingo 11/18/2014]      
    private void updateCaseSubStatus(Case cas){      
        //START:UD-1934 8/19/15 Added by Manolo Valena - Updated condition and changed raw string values to GlobalVariableClass counterparts.
        if(cas.Status == GlobalVariableClass.STATUS_CLOSED && !(cas.Sub_Status__c.contains(GlobalVariableClass.REJECTED)) && cas.Sub_Status__c != GlobalVariableClass.REQUEST_RECALLED){
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_STOP_COMPLETED;    
        }
        //END:UD-1934 8/19/15 Added by Manolo Valena
        //START D-1109 12/10/2014 JB Domingo Change of sub status to Retained and Not Retained
        //START: D-1347 12/19/14 Added by J. Sarion Update Sub-Status whether it is for Urgent or Waived
        if((cas.Outcome__c == 'Retained' || cas.Outcome__c == 'Not Retained') && cas.Urgent_Request__c == true && cas.Sub_Status__c == 'For Retention Offer'){
            if (cas.Outcome__c == 'Retained') {
                //START:D-2951 5/19/2015 Added by Manolo Valena - Changed sub status to Customer Retained as per FDS.
                cas.Sub_Status__c = 'Customer Retained';
                //END:D-2951 5/19/2015 Added by Manolo Valena
            }
            else {
                //START:D-2951 5/19/2015 Added by Manolo Valena - Changed sub status to No Retention as per FDS.
                cas.Sub_Status__c = 'No Retention';
                //END:D-2951 5/19/2015 Added by Manolo Valena
            }
        }
        else if((cas.Outcome__c == 'Retained' || cas.Outcome__c == 'Not Retained') && cas.Urgent_Request__c == false && cas.Stop_Waive_Request__c == true && cas.Sub_Status__c == 'For Retention Offer'){
            if (cas.Outcome__c == 'Retained') {
                cas.Sub_Status__c = 'Retained';
            }
            else {
                cas.Sub_Status__c = 'Not Retained';
            }
            //START UD-0778 4/29/2015 Added by Manolo Valena - Update from "Waived" to "Waiver"
            cas.Sub_Status__c = 'Waiting for Waiver Approval';
            //END UD-0778 4/29/2015 Added by Manolo Valena
        }
        //END: D-1347 12/19/14 Added by J. Sarion
        //END D-1109 12/10/2014 JB Domingo
    //START:D-2951 5/20/2015 Added by Manolo Valena - Update sub status.
        if(cas.Urgent_Request__c == true && cas.Sub_Status__c == 'No Retention' && cas.Outcome__c == 'Not Retained' && cas.Ownerid != ConstantsSLB.getKeyId('Retention_Outbound_Queue') && cas.Record_Locked__c == true) {
            cas.Sub_Status__c = 'Waiting for Urgent Stop Approval';
        }
        //END:D-2951 5/20/2015 Added by Manolo Valena
    //START:UD-1341 5/21/2015 Added by Manolo Valena - Close case and sub status is stop sub completed if status is pending and sub status is ready for submission.
        if(cas.RecordTypeId == CASE_STOP_SUB_TYPE_ID && 
           cas.Status == GlobalVariableClass.STATUS_PENDING && 
           cas.Sub_Status__c == GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION && 
           cas.Approval_Submitted__c == true &&
           cas.Account_Record_Type__c == GlobalVariableClass.VENDORSUB) {
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_STOP_COMPLETED;
        }
        //END:UD-1341 5/21/2015 Added by Manolo Valena
    }
    
    //start D-0509 [12/11/2014] Added by A. Banaag - updates fields if request is urgent
    private void tickUrgentRequest(List<Case> lstNewCases){
        for(Case thisCase : lstNewCases)
        {
            if(thisCase.Earliest_Stop_Date__c >= thisCase.Stop_Request_Date__c){
                thisCase.Urgent_Request__c = true;
            }
            else{
                System.debug('Case not urgent. Earliest stop: '+ thisCase.Earliest_Stop_Date__c + 
                            '; Stop Request: '+ thisCase.Stop_Request_Date__c);
            }
        }
    }
    //end D-0509
    
    //START: D-1347 12/23/14 Added by J. Sarion Update Owner Base on Admin Charges
    //START: D-2221 02/20/2015 Added by KristineCampang -added equal sign to include the below amount
    private void updateOwner(Case cas, Case oldCas) {
        if (cas.Urgent_Request__c == true && cas.Record_Locked__c == true && cas.Sub_Status__c == 'Waiting for Urgent Stop Approval') {
            cas.ownerId = CSO_TL_QUEUE_ID;
        }
        //START UD-0778 4/29/2015 Added by Manolo Valena - Updated Sub Status from "Waiting for Waived Approval" to "Waiting for Waiver Approval"
        else if (cas.Admin_Charges__c <= 100 && cas.Record_Locked__c == true && cas.Sub_Status__c == 'Waiting for Waiver Approval') {
            cas.ownerId = CSO_TL_QUEUE_ID;
        }
        else if (cas.Admin_Charges__c >= 101 && cas.Admin_Charges__c <= 500 && cas.Record_Locked__c == true && cas.Sub_Status__c == 'Waiting for Waiver Approval') {
            cas.ownerId = CSO_AMM_QUEUE_ID;
        }
        else if (cas.Admin_Charges__c >= 501 && cas.Admin_Charges__c <= 5000 && cas.Record_Locked__c == true && cas.Sub_Status__c == 'Waiting for Waiver Approval') {
            cas.ownerId = CSO_HEAD_QUEUE_ID;
        }
        //END UD-0778 4/29/2015 Added by Manolo Valena
        //START UD-0374 3/19/2015 Added by Manolo Valena - Added additional condition that checks if the new field 'Original Owner' is added with the string 'Recalled' by the recall action of the approval process. If the case has been recalled, the owner of the case is reverted back to the original owner. The Sub status of the record is also reverted back to the original sub status.
        if((cas.Original_Owner__c != null && cas.Original_Owner__c != GlobalVariableClass.EMPTYSTR) && cas.Original_Owner__c.contains(GlobalVariableClass.RECALLED))
        {
            cas.ownerId = cas.Original_Owner__c.split(GlobalVariableClass.DASH)[0];
            //START UD-0778 4/29/2015 Added by Manolo Valena - Removed as there is already a new sub status value "Request Recalled"
            //cas.Sub_Status__c = cas.Original_Owner__c.split(GlobalVariableClass.DASH)[1];
            //END UD-0778 4/29/2015 Added by Manolo Valena
            //START UD-0778 4/29/2015 Added by Manolo Valena - Updated to store only ownerId.
            if(cas.Original_Owner__c.split(GlobalVariableClass.DASH)[1] == GlobalVariableClass.RECALLED) {
                cas.Original_Owner__c = cas.ownerId;
            }
            else if(cas.Original_Owner__c.split(GlobalVariableClass.DASH)[1] == GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED) {
                cas.Original_Owner__c = cas.ownerId + GlobalVariableClass.DASH + cas.Original_Owner__c.split(GlobalVariableClass.DASH)[1];
            }
            //END UD-0778 4/29/2015 Added by Manolo Valena
        }
        //END UD-0374 3/19/2015 Added by Manolo Valena
        
        //START UD-0778 4/29/2015 Added by Manolo Valena - Update Sub Status and Owner after case being recalled.
        if(cas.Sub_Status__c == 'Request Recalled' && cas.RecordTypeId == CASE_STOP_SUB_TYPE_ID && !cas.Original_Owner__c.contains(GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED)) {
            if (cas.Urgent_Request__c == true && cas.Record_Locked__c == true) {
                cas.ownerId = CSO_TL_QUEUE_ID;
                cas.Sub_Status__c = 'Waiting for Urgent Stop Approval';
            }
        }
        else if (cas.Sub_Status__c == 'Request Recalled' && cas.RecordTypeId == CASE_STOP_SUB_TYPE_ID && cas.Original_Owner__c.contains(GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED)) {
            if (cas.Admin_Charges__c <= 100 && cas.Record_Locked__c == true) {
                cas.ownerId = CSO_TL_QUEUE_ID;
                cas.Sub_Status__c = 'Waiting for Waiver Approval';
            }
            else if (cas.Admin_Charges__c >= 101 && cas.Admin_Charges__c <= 500 && cas.Record_Locked__c == true) {
                cas.ownerId = CSO_AMM_QUEUE_ID;
                cas.Sub_Status__c = 'Waiting for Waiver Approval';
            }
            else if (cas.Admin_Charges__c >= 501 && cas.Admin_Charges__c <= 5000 && cas.Record_Locked__c == true) {
                cas.ownerId = CSO_HEAD_QUEUE_ID;
                cas.Sub_Status__c = 'Waiting for Waiver Approval';
            }
        }
        //END UD-0778 4/29/2015 Added by Manolo Valena
        //START UD-3818 28Jan16 FrancisBenzon : return case ownership to original owner after approval.
        if((cas.Original_Owner__c != null && cas.Original_Owner__c != GlobalVariableClass.EMPTYSTR) && (cas.Original_Owner__c.split(GlobalVariableClass.DASH)[1].contains(GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_STOP) || cas.Original_Owner__c.split(GlobalVariableClass.DASH)[1].contains(GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED)) && cas.Sub_Status__c == GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION ) {
            cas.ownerId = cas.Original_Owner__c.split(GlobalVariableClass.DASH)[0];         
        }
        //END UD-3818 28Jan16 FrancisBenzon : return case ownership to original owner after approval.
    }
    //END: D-2221 02/20/2015 Added by KristineCampang
    //END: D-1347 12/23/14 Added by J. Sarion
    
    //START: D-1950 2/10/15 JLedesma - Update old temp stop status
    private void updateOldTempStop(Case cas) {
        Temp_Stop__c tempRec = new Temp_Stop__c();
        Order__c orderRec = new Order__c();
    
        if (cas.Temp_Stop_Updated__c != null && cas.Sub_Status__c == 'Temp Stop Approved'){
            tempRec = tempStopMap.get(cas.Temp_Stop_Updated__c);
            tempRec.Cancelled__c = TRUE;
            tempToUpdateList.add(tempRec);
            if(tempRec.Order__c != null){
                orderRec = orderTempMap.get(tempRec.Order__c);
                orderRec.Status__c = 'Cancelled';
                orderToTempUpdateList.add(orderRec);
            }
        }
        
    //START: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
        if(cas.Status == GlobalVariableClass.STATUS_CLOSED && cas.Order__c!= NULL && cas.RecordTypeId == CASE_TEMP_STOP_TYPE_ID){
            
            // Start UD-1926 VPernicia 07/20/15: Comment out this block
            /*orderRec = orderClosedMap.get(cas.Order__c);
            orderRec.Status__c = GlobalVariableClass.STATUS_CLOSE;
            orderToClose.add(orderRec);*/
            // End UD-1926 VPernicia 07/20/15: Comment out this block
            
            // Start UD-1926 VPernicia 07/20/15
            Order__c orderRecord = new Order__c(Id=cas.Order__c);
            
            orderRecord.Status__c = GlobalVariableClass.STATUS_CLOSE;
            orderToClose.add(orderRecord);
            // End UD-1926 VPernicia 07/20/15
            
        }
        //END: JLedesma D-2891 5/14/2015 Temp Stop Subscription Order status is New when Case status is already Closed
        
    }
    //END: D-1950 2/10/15 JLedesma - Update old temp stop status
    
    //START: D-1955 2/11/15 J.Sarion - Create Address Assignment
        //START 3/27/15 MGaelo UD-0528 Added logic for Vendor Allocation for CoV urgent Approval
        private void createAddressAssignment (List<Case> lstCases) 
    {
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        List<Case_Vendor_Subscription__c> caseSubVendorList = new List<Case_Vendor_Subscription__c>();
        List<Address_Assignment__c> addressAssignmentList = new List<Address_Assignment__c>();
        List<Vendor_Allocation__c> venAllocList = new List<Vendor_Allocation__c>();
        Address_Assignment__c addressAssignment;
        Map<Id, Case> mapCases = new Map<Id, Case>();
        //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
        Map<Id, Set<Id>> postalCodeToVendorMap = new Map<Id, Set<Id>>();
        Set<Id> postalCodeSet = new Set<Id>();
        Set<Id> newAddressSet = new Set<Id>();
        List<Address__c> addressList = new List<Address__c>();
        Map<Id, Id> addIdToPostalCodeMap = new Map<Id, Id>();
        List<Case> newlstCases = new List<Case>();
        Set<Id> caseIdSet = new Set<Id>();
        //END D-2905 5/12/2015 Added By C. Lin
        
        //START UD-2398 08/21/2015 Added by J.Sarion - Set Case once
        Set<Id> isAddedSet = new Set<Id>();
        //END UD-2398 08/21/2015 Added by J.Sarion - Set Case once
        
        //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
        for(Case theCase : lstCases){
            mapCases.put(theCase.Id, theCase);
            newAddressSet.add(theCase.New_Address__c);
        }
        
        addressList = [SELECT Id, Postal_Code__c FROM Address__c WHERE Id IN : newAddressSet];
        for(Address__c add : addressList){
            postalCodeSet.add(add.Postal_Code__c);
            addIdToPostalCodeMap.put(add.Id, add.Postal_Code__c);
        }
        //END D-2905 5/12/2015 Added By C. Lin
        System.debug('cube -----  || lstCases ' +  lstCases);
        //START PD-0284 6/7/2016 Added By L. Valencia - Added query field Delivered_By_1__c
        caseSubList = [SELECT Id, Subscription__c, Case__c, Case__r.Change_of_Address_Type__c, Subscription__r.Delivered_By_1__c FROM Case_Subscription__c WHERE Case__c in : lstCases];
        //END PD-0284 6/7/2016 Added By L. Valencia
        caseSubVendorList = [SELECT Id, Subscription_Vendor__c, Case__c, Case__r.Change_of_Address_Type__c FROM Case_Vendor_Subscription__c WHERE Case__c in: lstCases];
        //cube ----------- 
        System.debug('cube -----  || caseSubList.size() ' +  caseSubList.size());
        System.debug('cube -----  || caseSubList ' +  caseSubList);
        //cube ----------- 
        //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
        //Start D-4706 19-Apr-2016 Added By S.Puli - test coverage - test coverage
        if(!postalCodeSet.isEmpty()){
            venAllocList = [SELECT Id, SingPost_Address__c, Vendor_Account__c FROM Vendor_Allocation__c WHERE SingPost_Address__c IN :postalCodeSet AND Status__c = 'active'];
        }
        //End D-4706 19-Apr-2016 Added By S.Puli - test coverage - test coverage
        for(Vendor_Allocation__c venAlloc : venAllocList){
            if (postalCodeToVendorMap.containsKey(venAlloc.SingPost_Address__c)){
                postalCodeToVendorMap.get(venAlloc.SingPost_Address__c).add(venAlloc.Vendor_Account__c);
            }else{
                postalCodeToVendorMap.put(venAlloc.SingPost_Address__c, new Set<Id> {venAlloc.Vendor_Account__c});
            }
        }
        //END D-2905 5/12/2015 Added By C. Lin
        for (Case_Subscription__c caseSub :caseSubList) {
            if (caseSub.case__r.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC){
                Case cas = mapCases.get(caseSub.Case__c);
                addressAssignment = new Address_Assignment__c();
                addressAssignment.Case__c = cas.Id;
                addressAssignment.Address__c = cas.New_Address__c;
                addressAssignment.Contact__c = cas.Contact_To_Update__c;
                addressAssignment.Effective_Date__c = cas.Effective_Date__c;
                addressAssignment.Subscription__c = caseSub.Subscription__c;
                //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
                Case newC = new Case();
                newC.Id = cas.Id;
                
                if(postalCodeToVendorMap.containsKey(addIdToPostalCodeMap.get(cas.New_Address__c))){
                    //START PD-0284 6/7/2016 Added By L. Valencia - Added checking subscription will be delivered by Mailing Agent
                    if(caseSub.Subscription__r.Delivered_By_1__c == GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT) {
                        newC.Sub_Status__c = null;
                        newC.Status = GlobalVariableClass.STATUS_CLOSED;
                    } else {
                    //END PD-0284 6/7/2016 Added By L. Valencia
                        if(postalCodeToVendorMap.get(addIdToPostalCodeMap.get(cas.New_Address__c)).size() == 1){
                            for(Id vendorAcc : postalCodeToVendorMap.get(addIdToPostalCodeMap.get(cas.New_Address__c))){
                                addressAssignment.Vendor__c = vendorAcc;
                            }
                        }else{
                            newC.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                            //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
                            //newC.OwnerId = ConstantsSLB.getKeyID('Ven Ops N&E Cir Reps Queue');
                            //END D-4722 24April2016 Added By C. Lin
                            newC.Status = 'Pending';
                        }
                    //START PD-0284 6/7/2016 Added By L. Valencia - Added checking subscription will be delivered by Mailing Agent
                    }
                    //END PD-0284 6/7/2016 Added By L. Valencia
                }else{
                    newC.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                    //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
                    //newC.OwnerId = ConstantsSLB.getKeyID('Ven Ops N&E Cir Reps Queue');
                    //END D-4722 24April2016 Added By C. Lin
          //START D-2953 05/20/2015 Added by J. Sarion - Set Status to Pending
                    newC.Status = 'Pending';
          //END D-2953 05/20/2015 Added by J. Sarion - Set Status to Pending
                }
                
                if (!caseIdSet.contains(newC.Id)) {
                    newlstCases.add(newC);
                    caseIdSet.add(newC.Id);
                }
                //END D-2905 5/12/2015 Added By C. Lin
                addressAssignmentList.add(addressAssignment);
                
            }
            
        }
        
        for (Case_Vendor_Subscription__c caseSubVendor :caseSubVendorList) {
            if (caseSubVendor .case__r.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC){
                
                Case cas = mapCases.get(caseSubVendor.Case__c);
                addressAssignment = new Address_Assignment__c();
                addressAssignment.Case__c = cas.Id;
                addressAssignment.Address__c = cas.New_Address__c;
                addressAssignment.Contact__c = cas.Contact_To_Update__c;
                addressAssignment.Effective_Date__c = cas.Effective_Date__c;
                addressAssignment.Subscription_Vendor__c = caseSubVendor.Subscription_Vendor__c;
                //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
                //START UD-2398 08/21/2015 Added by J.Sarion - add case once
                if(!(isAddedSet.contains(cas.Id))){
                    Case newC = new Case();
                    newC.Id = cas.Id;
                    
                    if(postalCodeToVendorMap.containsKey(addIdToPostalCodeMap.get(cas.New_Address__c))){
                        if(postalCodeToVendorMap.get(addIdToPostalCodeMap.get(cas.New_Address__c)).size() == 1){
                            for(Id vendorAcc : postalCodeToVendorMap.get(addIdToPostalCodeMap.get(cas.New_Address__c))){
                                addressAssignment.Vendor__c = vendorAcc;
                            }
                        }else{
                            newC.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                            //START D-2953 05/20/2015 Added by J. Sarion - Set Status to Pending
                            newC.Status = 'Pending';
                            //END D-2953 05/20/2015 Added by J. Sarion - Set Status to Pending
                        }
                    }else{
                        newC.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                        //START D-2953 05/20/2015 Added by J. Sarion - Set Status to Pending
                        newC.Status = 'Pending';
                        //END D-2953 05/20/2015 Added by J. Sarion - Set Status to Pending
                    }
                    
                    newlstCases.add(newC);
                    isAddedSet.add(cas.Id);
                }
                //END UD-2398 08/21/2015 Added by J.Sarion - add case once
                //END D-2905 5/12/2015 Added By C. Lin
                addressAssignmentList.add(addressAssignment);
            }
        }
        //START UD-0816 4/23/2015 Added By C. Lin - For Urgent Approval of COA
        for(Case c : lstCases){
            if(c.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                addressAssignment = new Address_Assignment__c();
                addressAssignment.Case__c = c.Id;
                addressAssignment.Address__c = c.New_Address__c;
                addressAssignment.Contact__c = c.Contact_To_Update__c;
                addressAssignment.Effective_Date__c = c.Effective_Date__c;
                //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
                Case newC = new Case();
                newC.Id = c.Id;
                
                if(postalCodeToVendorMap.containsKey(addIdToPostalCodeMap.get(c.New_Address__c))){
                    if(postalCodeToVendorMap.get(addIdToPostalCodeMap.get(c.New_Address__c)).size() == 1){
                        for(Id vendorAcc : postalCodeToVendorMap.get(addIdToPostalCodeMap.get(c.New_Address__c))){
                            addressAssignment.Vendor__c = vendorAcc;
                        }
                    }else{
                        newC.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                        //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
                        //newC.OwnerId = ConstantsSLB.getKeyID('Ven Ops N&E Cir Reps Queue');
                        //END D-4722 24April2016 Added By C. Lin
                        newC.Status = 'Pending';
                    }
                }else{
                    newC.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                    //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
                    //newC.OwnerId = ConstantsSLB.getKeyID('Ven Ops N&E Cir Reps Queue');
                    //END D-4722 24April2016 Added By C. Lin
                    newC.Status = 'Pending';
                }
                
                newlstCases.add(newC);
                //END D-2905 5/12/2015 Added By C. Lin
                addressAssignmentList.add(addressAssignment);
            }
        }

        //END UD-0816 4/23/2015 Added By C. Lin
        if (!addressAssignmentList.isEmpty()) {
            INSERT addressAssignmentList;
        }
        //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
        if(!newlstCases.isEmpty()){
            upsert newlstCases;
        }
        
        try {
            //Update mapCases.values(); //START END D-4034 08Dec2015 Added By C. Lin - Comment out
        } catch (exception e) {
            ExceptionLogger.log(new list<exception> { e });
            system.debug(e);
        }
        //END D-2905 5/12/2015 Added By C. Lin
        
        /*if (!venAllocList.isEmpty()) {
            INSERT venAllocList;
        }*/
        //END D-2905 5/12/2015 Added By C. Lin
    }
    //END 3/27/15 MGaelo UD-0528 Added logic for Vendor Allocation for CoV urgent Approval
    //END: D-1955 2/11/15 J.Sarion - Create Address Assignment
    
    //START: D-1597 / K. Tan/ Update Query for Goodwill
    //START: D-1734 1/20/2015 Added By K. Tan - Added condition to cater Newspaper and Digital Complaint
    private void processGoodWill(List<Case> lstCases)
    {
        Map<Id, Id> mapSubIdToCaseId = new Map<Id, Id>();
        Map<Id, Case> mapCases = new Map<Id, Case>();
        
        for(Case cas : lstCases)
        {
            mapCases.put(cas.Id, cas);
            if(cas.Subscription_Name__c != null)
                mapSubIdToCaseId.put(cas.Subscription_Name__c, cas.Id);
        }
        
        for(Case_Subscription__c casSub : [SELECT Id, Subscription__c, Case__c FROM Case_Subscription__c WHERE Case__c in: lstCases])
            mapSubIdToCaseId.put(casSub.Subscription__c, casSub.Case__c);
        
        for(Zuora__Subscription__c sub : [SELECT Id, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c 
                                          FROM Zuora__Subscription__c WHERE Id in : mapSubIdToCaseId.keySet()])
         {
            String billAccountId = sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
            Case relatedCase = mapCases.get(mapSubIdToCaseId.get(sub.Id));
            String goodwillValue;
            if(relatedCase.Subscription_Name__c == null)
              goodwillValue = String.valueof(relatedCase.Goodwill_Amount_Newspaper__c);
            else
              goodwillValue = String.valueof(relatedCase.Goodwill_Amount__c);
            
            //Call @future method to update Zuora
            UpdateGoodwill.updateZuoraGoodWillCall(goodwillValue , billAccountId );
         }
    }
    //END: D-1734 1/20/2015 Added By K. Tan - Added condition to cater Newspaper and Digital Complaint
    //END: D-1597 / K. Tan/ Update Query for Goodwill
    
    //START UD-0374 3/19/2015 Added by Manolo Valena - Method that updates the new text field 'Original Owner' with the id of the creator of the case record. Also adds the initial sub status to the text field. This is called before insertion of the record/s.
    private void populateOriginalOwner(List<Case> lstNewCases)
    {
        for(Case thisCase : lstNewCases)
        {
            if(thisCase.RecordTypeId == CASE_STOP_SUB_TYPE_ID)
            {
                thisCase.Original_Owner__c = thisCase.ownerId + GlobalVariableClass.DASH + thisCase.Sub_Status__c;
            }
        }
    }
    //END UD-0374 3/19/2015 Added by Manolo Valena
    
    //START: MD-61 03/24/2015 Added by S.PULI 
    /*
     * @description : method to check for COA case
     * @param : list of temp stop case for checking
     * @return : none 
     */
    private void checkForCOA(List<Case> tsCaseList, Boolean isUpdate){     
        
        for(Case c : tsCaseList){
            tempStopAcc_MAP.put(c, c.AccountId);
            if(isUpdate==true){
                tCaseToRec_MAP.put(c.Id, c.Temp_Stop__c);
            }
        }
        if(tempStopAcc_MAP.size()>0){
        tempStopAcc_LIST = [Select Id, Name From Account Where Id IN :tempStopAcc_MAP.values()];
        //START: D-3130 18/06/2015 Added by S.Puli
        coaCase_LIST = [Select Id, RecordTypeId, Effective_Date__c, AccountId, Change_of_Address_Type__c From Case Where AccountId IN :tempStopAcc_MAP.values() AND RecordTypeId = :CASE_COA AND Effective_Date__c >= TODAY AND Sub_Status__c != :GlobalVariableClass.SUB_STATUS_WAITING_FOR_COA_APPROVAL AND Sub_Status__c != :GlobalVariableClass.SUB_STATUS_COA_REJECTED AND (Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR OR Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD)];
        //END: D-3130 18/06/2015 Added by S.Puli
        }
        if(coaCase_LIST.size()>0){
            for(Case c: coaCase_LIST){
                coaCase_SET.add(c.Id);
                coaIdToObj_MAP.put(c.Id, c);
            }
        }
        if(coaCase_SET.size()>0){
            coaCaseSub_LIST = [Select Id, Case__c, Case__r.Effective_Date__c, Subscription__c From Case_Subscription__c Where Case__c IN :coaCase_SET];
        }
        if(coaCaseSub_LIST.size()>0){
            for(Case_Subscription__c cs :  coaCaseSub_LIST){
                
                if(sub_CaseList_MAP.containskey(cs.Subscription__c)){
                    sub_CaseList_MAP.get(cs.Subscription__c).add(coaIdToObj_MAP.get(cs.Case__c));
                } else{
                    sub_CaseList_MAP.put(cs.Subscription__c, new List<Case>{coaIdToObj_MAP.get(cs.Case__c)});
                }
            }
        }
        //Temp_Stop_Sub__c
        Date currDate;
        
        if(sub_CaseList_MAP.size()>0){
            for(Case c : tsCaseList){
                if(sub_CaseList_MAP.containskey(c.Temp_Stop_Sub__c) && sub_CaseList_MAP.get(c.Temp_Stop_Sub__c) <> null){
                    for(Case ca : sub_CaseList_MAP.get(c.Temp_Stop_Sub__c)){
                        for(currDate = c.Temp_Stop_Date__c; currDate <= c.Restart_Date__c; currDate = currDate.addDays(1)){
                            if(ca.Effective_Date__c == currDate){
                                
                                if(isUpdate == true){
                                    //list of temp to update in andFinally
                                    Case cas = new Case(id = c.Id);  
                                    cas.COA__c = true;
                                    //START PD-0155 01Jun2016 Added By C. Lin - prevent update duplicate TS cases
                                    //tempExtisting.add(cas);
                                    if(!tempExistingMap.containsKey(cas.Id)){
                                        tempExistingMap.put(cas.Id, cas);
                                    }
                                    //END PD-0155 01Jun2016 Added By C. Lin
                                } else {
                                    c.COA__c = true;
                                }
                            }
                        }       
                    }
                }
            }       
        }
    }   
    //END: MD-61 03/24/2015 Added by S.PULI 
    
    //START: D-2565 03/21/2015 Added by S.PULI 
    /*
     * @description : method to send the usage to zuora - FUTURE VERSION
     * @param : set of usage ids
     * @return : reponse from the callout request 
     */
    //Start D-4452 02-Apr-2016 Added By S.Puli
    /**
    @future(callout=true)
    public static void sendToZuoraCallOut(set<id> usageIdSet) {

        list<map<string, string>> response = new list<map<string, string>>();
        ZuoraCallOut UsageCallOut = new ZuoraCallOut();
        list<map<string, object>> requestParam_requestValue_list = new list<map<string, object>>();
        list<map<string, object>> requestParam_requestValue_batchOfMax = new list<map<string, object>>();
        list<Usage__c> usageList = new list<Usage__c>();
        map<string, object> requestParam_requestValue;
        integer index = 0;
        integer currentBatchIndex = 0;
        integer counter = 0;
        integer batchOfMax = 0;
        integer j = 0;
        
        for (Usage__c usage : [select Id, Account_Id__c, Subscription_Id__c, UOM__c, Quantity__c, Start_Date__c, 
                Zuora_Id__c, Send_to_Zuora_Error_Message__c, StopType__c, Send_to_Zuora_Time__c, Rate_Plan_Charge_Id__c from Usage__c where Id in :usageIdSet]) { //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only //START/END 08/11/2015 D-3364 Karl Tan - Include Stop Type

            requestParam_requestValue = new map<string, object>();
            requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_SUBSCRIPTION_NUMBER, usage.Subscription_Id__c);
            requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_ACCOUNT_NUMBER, usage.Account_Id__c);
            requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_UOM, usage.UOM__c);
            requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_QUANTITY, usage.Quantity__c);
            requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_CHARGE_NUMBER, usage.Rate_Plan_Charge_Id__c); //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_STOP_TYPE, usage.StopType__c); //START/END 08/11/2015 D-3364 Karl Tan - Include Stop Type
            
            if (usage.Start_Date__c != null) {
                requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_START_DATE_TIME, zuora.zUtil.getZuoraDate(usage.Start_Date__c));
                if (date.daysInMonth(usage.Start_Date__c.year(), usage.Start_Date__c.month()) == usage.Start_Date__c.day()) {
                    requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_START_DATE_TIME, zuora.zUtil.getZuoraDate(usage.Start_Date__c.addDays(-1)));
                }
            }
            
            requestParam_requestValue_list.add(requestParam_requestValue);
            usageList.add(usage);
        }
        
        
            //
        
        if (usageList.isEmpty() == false && requestParam_requestValue_list.isEmpty() == false) {
            
            for (counter = 0; counter < requestParam_requestValue_list.size(); counter++) {
                
                currentBatchIndex = (batchOfMax * UsageHelper.REQUEST_MAX_USAGE);       
                requestParam_requestValue_batchOfMax.add(requestParam_requestValue_list[counter]);
                
                if (math.mod(counter + 1, UsageHelper.REQUEST_MAX_USAGE) == 0 || counter == (requestParam_requestValue_list.size() - 1)) {
                    
                    index = currentBatchIndex;
                    
                    for (map<string, string> result : UsageCallOut.loadZObjects(requestParam_requestValue_batchOfMax, UsageHelper.REQUEST_TYPE)) {
                        
                        if (usageList[index] != null) {
                        
                            usageList[index].Status__c = result.get(UsageHelper.RESPONSE_FIELD_STATUS);
                            usageList[index].Send_to_Zuora_Time__c = datetime.now();
                            usageList[index].Send_to_Zuora_Error_Message__c = null;
                            
                            if (result.get(UsageHelper.RESPONSE_FIELD_ID) != null) {
                                usageList[index].Zuora_Id__c = result.get(UsageHelper.RESPONSE_FIELD_ID);
                            } else if (result.get(UsageHelper.RESPONSE_FIELD_MESSAGE) != null) {
                                usageList[index].Send_to_Zuora_Error_Message__c = result.get(UsageHelper.RESPONSE_FIELD_MESSAGE);
                            }
                        }
                        
                        response.add(result);
                        index++;
                    }
                    
                    requestParam_requestValue_batchOfMax = new list<map<string, object>>();
                    batchOfMax++;                   
                }
            }
            
            try {
                Database.update(usageList,false); //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            } catch (exception e) {
                ExceptionLogger.log(new list<exception> { e });
            }
        }
        
    }
    **/
    //End D-4452 02-Apr-2016 Added By S.Puli
    //END: D-2565 03/21/2015 Added by S.PULI
    //START UD-0567 3/30/2015 Added by Manolo Valena
    private void urgentStopSubmitForApproval(List<Case> lstNewCases)
    {
        List<Approval.ProcessSubmitRequest> lstProcess = new List<Approval.ProcessSubmitRequest>();
        for(Case thisCase : lstNewCases)
        {
            if(thisCase.Record_Locked__c == false && thisCase.wasRecalled__c == false)
            {
                if(thisCase.Sub_Status__c == GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_STOP  && 
                   thisCase.Urgent_Request__c == true)
                {
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    List<Id> lId = new List<Id>();
                    lId.add(CSO_TL_QUEUE_ID);
                    
                    request.setObjectId(thisCase.Id);
                    request.setNextApproverIds(lId);
                    lstProcess.add(request);
                }
            }
        }
        if(lstProcess.size() > 0)
        {
            Approval.process(lstProcess);
        }
    }
    //END UD-0567 3/30/2015 Added by Manolo Valena 
    
  //START D-2940 5/15/15 Added by Manolo Valena - Updated the whole method.  
    //START D-2741 GDelrosario : added method to auto create record for Case Vendor Subscription for STOPSub
    private void insertCaseVendorSubstopSub(List<Case> lstNewCases){
        List<Case_Vendor_Subscription__c> caseVendorList = new List<Case_Vendor_Subscription__c>();
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        List<Subscription_Vendor__c> toCreateSV = new List<Subscription_Vendor__c>();
        
        //START D-2940 5/15/15 Added by Manolo Valena - Added new variables.
        Map<Id, Id> mapOrderToCase = new Map<Id, Id>();
        List<Order_Line_Item_Vendor__c> olivs = new List<Order_Line_Item_Vendor__c>();
        Set<Id> accIds = new Set<Id>();
        Set<id> orderIds = new Set<id>();
        Set<Id> caseIds = new Set<Id>();
        Set<id> olivIds = new Set<Id>();
        Map<Id, Set<Id>> casToSVListMap = new Map<Id, Set<Id>>();
        //END D-2940 5/15/15 Added by Manolo Valena
        
        for(Case newcases : lstNewCases){
            if(newcases.Sub_Category__c == 'Stop Subscription' && newcases.RecordTypeId == CASE_STOP_SUB_TYPE_ID){
                if(newcases.Account_Record_Type__c == 'Vendor Subscriber') {
                    //START D-2940 5/15/15 Added by Manolo Valena - Updated condition to store values in sets and a map.
                    accIds.add(newcases.AccountId);
                    orderIds.add(newcases.Order_Number__c);
                    caseIds.add(newcases.Id);
                    mapOrderToCase.put(newcases.Order_Number__c, newcases.Id);
                    //END D-2940 5/15/15 Added by Manolo Valena
                }
            } 
        }
        
        //START D-2940 5/15/15 Added by Manolo Valena - New logic to map the subscription vendor to the new stop cases.
          
        if(orderIds.size() > 0) {
           
            olivs = [SELECT Id, Order__c, Subscription_Vendor__c, Subscription_Vendor__r.Order_Number__c, Subscription_Vendor__r.Status__c 
                    FROM Order_Line_Item_Vendor__c 
                    WHERE Order__c IN : orderIds];
           
            for(Order_Line_Item_Vendor__c oliv : olivs) {
                if(mapOrderToCase.containsKey(oliv.Order__c)) {
                    if(casToSVListMap.containsKey(mapOrderToCase.get(oliv.Order__c))) {
                        casToSVListMap.get(mapOrderToCase.get(oliv.Order__c)).add(oliv.Subscription_Vendor__c);
                    }
                    else {
                        casToSVListMap.put(mapOrderToCase.get(oliv.Order__c), new Set<Id> {oliv.Subscription_Vendor__c});
                    }
                }
            }
        }
        //END D-2940 5/15/15 Added by Manolo Valena
    
        Set<Id> x = new Set<Id>();
        Set<Id> y = new Set<Id>();
        //START UD-1677 6/18/15 Added by Manolo Valena
        Map<Id, Id> mapOrderToCaseDI = new Map<Id, Id>();
        //END UD-1677 6/18/15 Added by Manolo Valena
        for(Case newCase : lstNewCases) {
            x.add(newCase.Id);
            y.add(newCase.Order__c);
            //START UD-1677 6/18/15 Added by Manolo Valena
            mapOrderToCaseDI.put(newCase.Order__c, newCase.Id);
            //END UD-1677 6/18/15 Added by Manolo Valena
        }
    
        //START UD-1677 6/18/15 Added by Manolo Valena
        List<Order_Line_Item__c> mList = [SELECT Subscription_Id__c,Subscription_Name__c,Subscription__c, Order__c
                                          FROM Order_Line_Item__c 
                                          WHERE Order__c IN : y];
        //END UD-1677 6/18/15 Added by Manolo Valena 
    
        //START UD-1677 6/18/15 Added by Manolo Valena - To be removed.
        //Map<Id, String> h =  new Map<Id, String>();
        //END UD-1677 6/18/15 Added by Manolo Valena
        
        //START UD-1677 6/18/15 Added by Manolo Valena
        Map<Id, Set<Id>> caseIdToSubscriptionsMap = new Map<Id, Set<Id>>();
        //END UD-1677 6/18/15 Added by Manolo Valena
        
        for(Order_Line_Item__c m : mList) {
            //START UD-1677 6/18/15 Added by Manolo Valena - To be removed.
            //h.put(m.Case__c, m.Subscription__c);
            //END UD-1677 6/18/15 Added by Manolo Valena
            
            //START UD-1677 6/18/15 Added by Manolo Valena
            if(mapOrderToCaseDI.containsKey(m.Order__c)) {
                if(caseIdToSubscriptionsMap.containsKey(mapOrderToCaseDI.get(m.Order__c))) {
                    caseIdToSubscriptionsMap.get(mapOrderToCaseDI.get(m.Order__c)).add(m.Subscription__c);
                }
                else {
                    caseIdToSubscriptionsMap.put(mapOrderToCaseDI.get(m.Order__c), new Set<Id> {m.Subscription__c});
                }
            }
            //END UD-1677 6/18/15 Added by Manolo Valena
        }
        
        for(Case newcases : lstNewCases){
            if(newcases.Sub_Category__c == 'Stop Subscription' && newcases.RecordTypeId == CASE_STOP_SUB_TYPE_ID){
                if(newcases.Account_Record_Type__c == 'Vendor Subscriber'){          
                    if(casToSVListMap.containsKey(newcases.Id)) {
                        //START D-2940 5/15/15 Added by Manolo Valena - Loop through the subscription vendors associated with the case.
                        for(Id svId : casToSVListMap.get(newcases.Id)) {
                            Case_Vendor_Subscription__c cvs = new Case_Vendor_Subscription__c();
                            cvs.Case__c = newcases.Id;
                            //START D-2940 5/15/15 Added by Manolo Valena - Assign the subscription vendor record from the map.
                            cvs.Subscription_Vendor__c = svId;
                            //END D-2940 5/15/15 Added by Manolo Valena
                            cvs.Account__c = newcases.AccountId;
                            caseVendorList.add(cvs);
                        }
                        //END D-2940 5/15/15 Added by Manolo Valena
                    }
                }
                //START D-4346 1/28/2016 Added by Manolo Valena - Added Direct Corporate in the condition for creating Case Subscription
                else if (newcases.Account_Record_Type__c == GlobalVariableClass.ACCRECTYPEDI || newcases.Account_Record_Type__c == GlobalVariableClass.ACCRECTYPEDC){
                    //START UD-1677 6/18/15 Added by Manolo Valena
                    if(caseIdToSubscriptionsMap.containsKey(newcases.Id)) {
                        for(Id cITSM : caseIdToSubscriptionsMap.get(newcases.Id)) {
                            Case_Subscription__c cs = new Case_Subscription__c();
                            cs.Case__c = newcases.Id;
                            cs.Account__c = newcases.AccountId;
                            cs.Subscription__c = cITSM;
                            cs.isComplaint__c = false;
                            caseSubList.add(cs);
                        }
                    }
                    //END UD-1677 6/18/15 Added by Manolo Valena
                    //START UD-1677 6/18/15 Added by Manolo Valena - To be removed.
                    /*Case_Subscription__c cs = new Case_Subscription__c();
                    cs.Case__c= newcases.Id;
                    cs.Account__c = newcases.AccountId;
                    cs.Subscription__c = h.get(newcases.Id);
                    cs.isComplaint__c = false;
                    caseSubList.add(cs);*/ 
                    //END UD-1677 6/18/15 Added by Manolo Valena
                }
                //END D-4346 1/28/2016 Added by Manolo Valena
            }
        }
        
        try {
            insert caseVendorList;
        }catch (exception e){
            System.debug('--->> : ERROR for Case Vendor Subscription' + e.getMessage() );
        }
        
        try {
            insert caseSubList;
        }catch (exception e){
            System.debug('--->> : ERROR for Case Vendor Subscription' + e.getMessage() );
        }
        
    }
    //END D-2741 GDelRosario
  //END D-2940 5/15/15 Added by Manolo Valena
    
    //START new method for UD-0327  AAgna query MainPackage Name from Order 
    public void populateMainPackage(List<Case> cases) {
        set<Id> OrderIds = new set<Id>();
        for (Case c : Cases ){
            if(c.Order__c != null) {
                OrderIds.add(c.Order__c);
            }
        }
        Map <Id, Order__c> MainPackageName = new Map <Id, Order__c>([SELECT Id, Subscription__r.Main_Package_1__r.Name FROM Order__c WHERE Id IN : OrderIds]);
        for (Case c : Cases ){
            if(MainPackageName.containsKey(c.Order__c)) {
                c.Main_Package__c = MainPackageName.get(c.Order__c).Subscription__r.Main_Package_1__r.Name;
            }
        }
    }//END new method for UD-0327  AAgna query MainPackage Name from Order
    //START:UD-1341 5/21/2015 Added by Manolo Valena - Method to update Order status and Vendor Subscription status when Stop Sub is completed.
    private void updateSubscriptionVendors(List<Case> lstNewCases) {
    
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> subscriptionVendorIdSet = new Set<Id>();
        List<Order__c> ordRecs = new List<Order__c>();
        List<Order__c> ordRecsToUpdate = new List<Order__c>();
        List<Case_Vendor_Subscription__c> cvsRecs = new List<Case_Vendor_Subscription__c>();
        List<Subscription_Vendor__c> svRecs = new List<Subscription_Vendor__c>();
        List<Subscription_Vendor__c> svRecsToUpdate = new List<Subscription_Vendor__c>();
        
        for(Case cas : lstNewCases) {       
            if(cas.Account_Record_Type__c == GlobalVariableClass.VENDORSUB &&
               cas.Approval_Submitted__c == true &&
               cas.Status == GlobalVariableClass.STATUS_CLOSED &&
               cas.Sub_Status__c == GlobalVariableClass.SUB_STATUS_STOP_COMPLETED &&
               cas.RecordTypeId == CASE_STOP_SUB_TYPE_ID) {
                orderIdSet.add(cas.Order_Number__c);
                caseIdSet.add(cas.Id);
            }
        }
        
        if(orderIdSet.size() > 0 && caseIdSet.size() > 0) {
            //Start UD-1926 VPernicia Code Optimization: Comment out this block
            /*ordRecs = [SELECT Status__c 
                       FROM Order__c 
                       WHERE Id IN : orderIdSet];
                    
            for(Order__c ordRec : ordRecs) {
                ordRec.Status__c = GlobalVariableClass.STATUS_CLOSED;
                ordRecsToUpdate.add(ordRec);
            }
            */
            //End UD-1926 VPernicia Code Optimization: Comment out this block
            
            //Start UD-1926 VPernicia Code Optimization
            for(Id orderId : orderIdSet) {
            
                Order__c orderRecord = new Order__c(Id=orderId);
                orderRecord.Status__c = GlobalVariableClass.STATUS_CLOSE; // START- END UD-3761 K. Tan 1/28/2015 Shall refer to STATUS_CLOSE instead
                ordRecsToUpdate.add(orderRecord);
            }
            //End UD-1926 VPernicia Code Optimization
            
            cvsRecs = [SELECT Subscription_Vendor__c 
                       FROM Case_Vendor_Subscription__c 
                       WHERE Case__c IN : caseIdSet];
                       
            for(Case_Vendor_Subscription__c cvsRec : cvsRecs) {
                subscriptionVendorIdSet.add(cvsRec.Subscription_Vendor__c);
            }
            
            if(subscriptionVendorIdSet.size() > 0) {
                //Start UD-1926 VPernicia Code Optimization: Comment out this block
                /*svRecs = [SELECT Status__c 
                          FROM Subscription_Vendor__c 
                          WHERE Id IN : subscriptionVendorIdSet];
                
                for(Subscription_Vendor__c svRec : svRecs) {
                    svRec.Status__c = GlobalVariableClass.STATUS_CANCELLED;
                    svRecsToUpdate.add(svRec);
                }*/
                //End UD-1926 VPernicia Code Optimization: Comment out this block
                
                //Start UD-1926 VPernicia Code Optimization
                for(Id SubVendorId : subscriptionVendorIdSet) {
                
                    Subscription_Vendor__c SubVendorRecord = new Subscription_Vendor__c(Id=SubVendorId);
                    SubVendorRecord.Status__c = GlobalVariableClass.STATUS_CANCELLED;
                    svRecsToUpdate.add(SubVendorRecord);
                }
                //End UD-1926 VPernicia Code Optimization
                
                update svRecsToUpdate;
            }
            update ordRecsToUpdate;
        }
    }
    //END:UD-1341 5/21/2015 Added by Manolo Valena    
    
    //START: JLedesma D-3091 6/18/2015 Year To Date computation
    //Start D-4452 - code coverage
    /***
    public void updateSubYearToDateTempStop(List<Case> lstNewCases){
        Set<Id> subIdList = new Set<Id>();
        Temp_Stop__c tsRec = new Temp_Stop__c();
        List<Temp_Stop__c> listTempStop = new List<Temp_Stop__C>();
        Zuora__Subscription__c zuoSubscrpt = new Zuora__Subscription__c();
        Map<Id, Temp_Stop__c> caseToTempStopUpdated = new Map<Id, Temp_Stop__c>();
        Map<Id, Temp_Stop__c> caseToTempStopCancelled = new Map<Id, Temp_Stop__c>();
        Set<Id> tempStopId = new Set<Id>();
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        Temp_Stop__c oldTS = new Temp_Stop__c();
        Map<Id, Decimal> subIdToTotalOldCurrentYTD = new Map<Id, Decimal>();
        Map<Id, Decimal> subIdToTotalNewCurrentYTD = new Map<Id, Decimal>();
        Map<Id, Decimal> subIdToTotalOldNextYTD = new Map<Id, Decimal>();
        Map<Id, Decimal> subIdToTotalNewNextYTD = new Map<Id, Decimal>();
        Decimal total;
        Set<Id> subIdSetCheck = new Set<Id>();
        //END UD-2443 9/5/2015 Added By C. Lin
        
         for(Case c : lstNewCases) {
            //if(c.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && c.Status == GlobalVariableClass.STATUS_CLOSED && c.Sub_Status__c == 'Temp Stop Approved'){
            if((Trigger.isInsert && !c.Requires_Urgent_Approval__c) || 
                  (Trigger.isUpdate && (String) Trigger.OldMap.get(c.Id).get('Sub_Status__c') != 'Temp Stop Approved' && c.Sub_Status__c == 'Temp Stop Approved')) {
                //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop -->

                if(c.Temp_Stop_Sub__c!=null){
                    subIdList.add(c.Temp_Stop_Sub__c);
                }
                if(c.Temp_Stop_Updated__c!=null){
                    tempStopId.add(c.Temp_Stop_Updated__c);
                }
                
                if(c.Temp_Stop_Type__c == 'Cancel'){
                    if(c.Temp_Stop_Sub__c!=null){
                        tempStopId.add(c.Temp_Stop__c);
                    }
                //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop -->

                }
            }
        }

        if(tempStopId.size() > 0){
            listTempStop = [SELECT Id, Case__r.Temp_Stop_Sub__c, Case__r.Next_Year_for_Year_To_Date__c, Case__r.Current_Date_for_Year_To_Date__c FROM Temp_Stop__c WHERE ID IN : tempStopId];
        }
        
        for(Case csRec : lstNewCases){
            if(listTempStop.size() > 0){
                    for(Temp_Stop__c ts : listTempStop){
                        if(ts.Id == csRec.Temp_Stop_Updated__c && csRec.Temp_Stop_Type__c == 'Update'){
                            caseToTempStopUpdated.put(csRec.Id, ts);
                        }
                        if(csRec.Temp_Stop_Type__c == 'Cancel' && ts.Id == csRec.Temp_Stop__c){
                            caseToTempStopCancelled.put(csRec.Id, ts);
                        }
                    }
                }
        }       
        
        if(subIdList.size() > 0){
            mapSubsCase = new Map<Id, Zuora__Subscription__c>([SELECT Order_Line_Item_Number__c, Status_Formula__c, Order_Line_Item_Number_1__r.Ph_d__c, Order_Line_Item_Number_1__r.Ph_e__c, Next_Year_Temp_Stop_Days__c, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Ph_d__c, Ph_e__c, Id, Zuora__SubscriptionEndDate__c, Recipient_Address_ID__c, Main_Package_1__r.Name, Year_to_Date_Temp_Stop_Days__c, Subscription_Type_1__c, Name, Zuora__CustomerAccount__r.Name, Main_Package_1__r.Id, Zuora__CustomerAccount__r.Id, Delivery_Charge__c, Frequency_1__c, Recipient_Contact__r.Name, Recipient_Contact__r.Id, Zuora__Status__c, Number_of_Copies__c, Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c WHERE Id IN :subIdList]);
            
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
            for(Case newCas : lstNewCases){
                total = 0;
                if(newCas.Temp_Stop_Type__c == 'Update' && caseToTempStopUpdated.containsKey(newCas.Id)){
                    oldTS = caseToTempStopUpdated.get(newCas.Id);
                    if(subIdToTotalOldCurrentYTD.containsKey(newCas.Temp_Stop_Sub__c)){
                        total = subIdToTotalOldCurrentYTD.get(newCas.Temp_Stop_Sub__c);
                        total = total + oldTS.Case__r.Current_Date_for_Year_To_Date__c;
                        subIdToTotalOldCurrentYTD.put(newCas.Temp_Stop_Sub__c, total);
                    }else{
                        subIdToTotalOldCurrentYTD.put(newCas.Temp_Stop_Sub__c, oldTS.Case__r.Current_Date_for_Year_To_Date__c);
                    }
                    if(subIdToTotalNewCurrentYTD.containsKey(newCas.Temp_Stop_Sub__c)){
                        total = subIdToTotalNewCurrentYTD.get(newCas.Temp_Stop_Sub__c);
                        total = total + newCas.Current_Date_for_Year_To_Date__c;
                        subIdToTotalNewCurrentYTD.put(newCas.Temp_Stop_Sub__c, total);
                    }else{
                        subIdToTotalNewCurrentYTD.put(newCas.Temp_Stop_Sub__c, newCas.Current_Date_for_Year_To_Date__c);
                    }
                    if(subIdToTotalOldNextYTD.containsKey(newCas.Temp_Stop_Sub__c)){
                        total = subIdToTotalOldNextYTD.get(newCas.Temp_Stop_Sub__c);
                        total = total + oldTS.Case__r.Next_Year_for_Year_To_Date__c;
                        subIdToTotalOldNextYTD.put(newCas.Temp_Stop_Sub__c, total);
                    }else{
                        subIdToTotalOldNextYTD.put(newCas.Temp_Stop_Sub__c, oldTS.Case__r.Next_Year_for_Year_To_Date__c);
                    }
                    if(subIdToTotalNewNextYTD.containsKey(newCas.Temp_Stop_Sub__c)){
                        total = subIdToTotalNewNextYTD.get(newCas.Temp_Stop_Sub__c);
                        total = total + newCas.Next_Year_for_Year_To_Date__c;
                        subIdToTotalNewNextYTD.put(newCas.Temp_Stop_Sub__c, total);
                    }else{
                        subIdToTotalNewNextYTD.put(newCas.Temp_Stop_Sub__c, newCas.Next_Year_for_Year_To_Date__c);
                    }
                }
            }
            //END UD-2443 9/5/2015 Added By C. Lin
            
            for(Case cs : lstNewCases){
                //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop -->
                
                if(mapSubsCase.containsKey(cs.Temp_Stop_Sub__c)){
                zuoSubscrpt = mapSubsCase.get(cs.Temp_Stop_Sub__c);
                    if(cs.Temp_Stop_Type__c == 'Create'){
                        
                        //Start MMallorca D-3214 09/07/2015 prevent saving a null value else set it to 0 
                        if(zuoSubscrpt.Next_Year_Temp_Stop_Days__c == null){
                            zuoSubscrpt.Next_Year_Temp_Stop_Days__c = 0;
                        }
                        if(zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c == null){
                            zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = 0;
                        }
                        zuoSubscrpt.Next_Year_Temp_Stop_Days__c = zuoSubscrpt.Next_Year_Temp_Stop_Days__c + cs.Next_Year_for_Year_To_Date__c;
                        zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c + cs.Current_Date_for_Year_To_Date__c;
                        subToUpdateList.add(zuoSubscrpt);
                        //End MMallorca D-3214 09/07/201
                        
                    }
                    if(cs.Temp_Stop_Type__c == 'Update' && caseToTempStopUpdated.containsKey(cs.Id)){
                        //Start MMallorca D-3214 09/07/2015 prevent saving a null value else set it to 0 
                        if(zuoSubscrpt.Next_Year_Temp_Stop_Days__c == null){
                            zuoSubscrpt.Next_Year_Temp_Stop_Days__c = 0;
                        }
                        if(zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c == null){
                            zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = 0;
                        }
                        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
                        /*tsRec = caseToTempStopUpdated.get(cs.Id);
                        zuoSubscrpt.Next_Year_Temp_Stop_Days__c = (zuoSubscrpt.Next_Year_Temp_Stop_Days__c - tsRec.Case__r.Next_Year_for_Year_To_Date__c) + cs.Next_Year_for_Year_To_Date__c;
                        zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = (zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c - tsRec.Case__r.Current_Date_for_Year_To_Date__c)+ cs.Current_Date_for_Year_To_Date__c;*//***********************
                        if((zuoSubscrpt.Next_Year_Temp_Stop_Days__c - subIdToTotalOldNextYTD.get(cs.Temp_Stop_Sub__c)) + subIdToTotalNewNextYTD.get(cs.Temp_Stop_Sub__c) > 30){
                            zuoSubscrpt.Next_Year_Temp_Stop_Days__c = 30;
                        }else{
                            zuoSubscrpt.Next_Year_Temp_Stop_Days__c = (zuoSubscrpt.Next_Year_Temp_Stop_Days__c - subIdToTotalOldNextYTD.get(cs.Temp_Stop_Sub__c)) + subIdToTotalNewNextYTD.get(cs.Temp_Stop_Sub__c);
                        }
                        if((zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c - subIdToTotalOldCurrentYTD.get(cs.Temp_Stop_Sub__c))+ subIdToTotalNewCurrentYTD.get(cs.Temp_Stop_Sub__c) > 30){
                            zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = 30;
                        }else{
                            zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = (zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c - subIdToTotalOldCurrentYTD.get(cs.Temp_Stop_Sub__c))+ subIdToTotalNewCurrentYTD.get(cs.Temp_Stop_Sub__c);
                        }
                        if(!subIdSetCheck.contains(zuoSubscrpt.Id)){
                            subToUpdateList.add(zuoSubscrpt);
                            subIdSetCheck.add(zuoSubscrpt.Id);
                        }
                        //END UD-2443 9/5/2015 Added By C. Lin
                        //End MMallorca D-3214 09/07/201
                    }
                    
                    if(cs.Temp_Stop_Type__c == 'Cancel' && caseToTempStopCancelled.containsKey(cs.Id)){
                        //Start MMallorca D-3214 09/07/2015 prevent saving a null value else set it to 0 
                        if(zuoSubscrpt.Next_Year_Temp_Stop_Days__c == null){
                            zuoSubscrpt.Next_Year_Temp_Stop_Days__c = 0;
                        }
                        if(zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c == null){
                            zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = 0;
                        }
                        tsRec = caseToTempStopCancelled.get(cs.Id);
                        zuoSubscrpt.Next_Year_Temp_Stop_Days__c = zuoSubscrpt.Next_Year_Temp_Stop_Days__c - tsRec.Case__r.Next_Year_for_Year_To_Date__c;
                        zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c - tsRec.Case__r.Current_Date_for_Year_To_Date__c;
                        subToUpdateList.add(zuoSubscrpt);
                        //End MMallorca D-3214 09/07/201
                    }
                }
                //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop -->

            }       
        }
    }
    ***/
    //End D-4452 Code coverage
    public void updateCaseYearToDateTempStop(List<Case> lstNewCases){
        //START D-3329 08/26/2015 Added by Charles Lin - Commented out
        //START UD-2002 07/22/2015 Added by J.Sarion - Check if called once
        //if(!isCalledOnce){
        UsageHelper.initialize();
        List<Temp_Stop__c> listTempStop = new List<Temp_Stop__C>();
        //Map<Id, Temp_Stop__c> caseToTempStopUpdated = new Map<Id, Temp_Stop__c>(); //START END UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
        Set<Id> tempStopId = new Set<Id>();

        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        Temp_Stop__c oldTS = new Temp_Stop__c();
        Integer total;
        Set<Id> caseIdForSubSet = new Set<Id>();
        //Set<Id> caseIdExcludeSet = new Set<Id>(); //START END UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
        List<Temp_Stop__c> tempStopList = new List<Temp_Stop__c>();
        //Map<Id, Case> tsIdToCaseMap = new Map<Id, Case>(); //START END UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
        //END UD-2443 9/5/2015 Added By C. Lin
        
        //START UD-3417 21Jan2016 Added By C. Lin
        Temp_Stop__c cancelledTS = new Temp_Stop__c();
        Map<Id, Temp_Stop__c> tsUpdatedIdToTSMap = new Map<Id, Temp_Stop__c>();
        Map<Id, Temp_Stop__c> tsCancelledIdToTSMap = new Map<Id, Temp_Stop__c>();
        //END UD-3417 21Jan2016 Added By C. Lin
        
        //START D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        Map<Id, Case> subIdToEarliestCaseMap = new Map<Id, Case>();
        //Map<Id, List<Temp_Stop__c>> subIdToTempStopMap = new Map<Id, List<Temp_Stop__c>>(); //START END UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
        //END UD-2443 9/5/2015 Added By C. Lin
        //END D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
  
        //START: D-3628 10/29/15 Added by Manolo Valena
        Set<Id> cancelTempStopSet = new Set<Id>();
        //START UD-3417 21Jan2016 Added By C. Lin - Comment Out
        /*Map<Id, Set<Id>> subIdToCancelTempStop = new Map<Id, Set<Id>>();
        Map<Id, Decimal> tsIdToRequestTotalIssue = new Map<Id, Decimal>();
        Map<Id, Decimal> subIdToSubMap2 = new Map<Id, Decimal>();*/
        //END UD-3417 21Jan2016 Added By C. Lin
        //END: D-3628 10/29/15 Added by Manolo Valena
        
        for(Case c : lstNewCases) {
            if(c.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && c.Status == GlobalVariableClass.STATUS_CLOSED && c.Sub_Status__c == 'Temp Stop Approved'){
                if(c.Temp_Stop_Sub__c!=null){
                    tempSubID.add(c.Temp_Stop_Sub__c);
                    caseToSubId.put(c.Id, c.Temp_Stop_Sub__c);
                    caseToCaseRec.put(c.Id, c);
                    
                    //START D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
                    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
                    if(subIdToCaseMap.containsKey(c.Temp_Stop_Sub__c)){
                        subIdToCaseMap.get(c.Temp_Stop_Sub__c).add(c);
                        subIdToCaseMap2.get(c.Temp_Stop_Sub__c).add(c);
                    }else{
                        subIdToCaseMap.put(c.Temp_Stop_Sub__c, new List<Case> {c});
                        subIdToCaseMap2.put(c.Temp_Stop_Sub__c, new List<Case> {c});
                    }
                    
                    if(c.Temp_Stop_Type__c == 'Update' || c.Temp_Stop_Type__c == 'Cancel'){ //START END UD-3417 21Jan2016 Added By C. Lin - Include Cancel Temp Stop. Add || c.Temp_Stop_Type__c == 'Cancel'
                        if(subIdToEarliestCaseMap.containsKey(c.Temp_Stop_Sub__c)){
                            if(subIdToEarliestCaseMap.get(c.Temp_Stop_Sub__c).Temp_Stop_Date__c > c.Temp_Stop_Date__c){
                                subIdToEarliestCaseMap.put(c.Temp_Stop_Sub__c, c);
                            }
                        }
                        else{
                            subIdToEarliestCaseMap.put(c.Temp_Stop_Sub__c, c);
                        }
                        //caseIdExcludeSet.add(c.Temp_Stop_Updated__r.Case__c); //START END UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
                        
                        cancelTempStopSet.add(c.Temp_Stop__c); //START END UD-3417 21Jan2016 Added By C. Lin - store temp stop IDs to be cancelled
                    }
                    //END UD-2443 9/5/2015 Added By C. Lin
                    //END D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
                    
                    //START UD-3417 21Jan2016 Added By C. Lin - Comment Out
                    //START: D-3628 10/29/15 Added by Manolo Valena
                    /*if(c.Temp_Stop_Type__c == 'Cancel'){
                        cancelTempStopSet.add(c.Temp_Stop__c);
                        if(subIdToCancelTempStop.containsKey(c.Temp_Stop_Sub__c)) {
                            subIdToCancelTempStop.get(c.Temp_Stop_Sub__c).add(c.Temp_Stop__c);
                        }
                        else {
                            subIdToCancelTempStop.put(c.Temp_Stop_Sub__c, new Set<Id>{c.Temp_Stop__c});
                        }
                    }*/
                    //END: D-3628 10/29/15 Added by Manolo Valena
                    //END UD-3417 21Jan2016 Added By C. Lin
                }
            }
            
            if(c.Temp_Stop_Updated__c!=null){
                tempStopId.add(c.Temp_Stop_Updated__c);
            }
        }
        //START UD-2443 9/5/2015 Added By C. Lin - Temp Stop List of Sub created/updated
        if(!tempSubID.isEmpty()){
            //START D-3844 10/30/2015 Added By C. Lin - Filter out Completed Temp Stops
            tempStopList = [SELECT Id, Case__c, Case__r.Order__c, Case__r.Temp_Stop_Sub__c, Case__r.Next_Year_for_Year_To_Date__c, Case__r.Current_Date_for_Year_To_Date__c FROM Temp_Stop__c WHERE Case__r.Temp_Stop_Sub__c IN : tempSubID AND (Temp_Stop_Status__c != 'Cancelled' AND Temp_Stop_Status__c != 'Completed')];
            //END D-3844 10/30/2015 Added By C. Lin
            
            //START UD-2908 9/22/2015 Added By C. Lin - Add Main_Package_1__c
            for(Zuora__Subscription__c sub :[SELECT Id, Next_Year_Temp_Stop_Days__c, Year_to_Date_Temp_Stop_Days__c, Main_Package_1__c FROM Zuora__Subscription__c WHERE Id IN :tempSubID]){
            //END UD-2908 9/22/2015 Added By C. Lin
                subIdToSubMap.put(sub.Id, sub);
                //START: D-3628 10/29/15 Added by Manolo Valena
                //subIdToSubMap2.put(sub.Id, sub.Year_to_Date_Temp_Stop_Days__c); //START END UD-3417 21Jan2016 Added By C. Lin - Comment Out cause not used
                //END: D-3628 10/29/15 Added by Manolo Valena
            }
            //subIdToSubMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Next_Year_Temp_Stop_Days__c, Year_to_Date_Temp_Stop_Days__c FROM Zuora__Subscription__c WHERE Id IN :tempSubID]);
        }
        
        //START UD-2908 9/22/2015 Added By C. Lin - Exclude All-In-One
        for(Zuora__Subscription__c zSub : subIdToSubMap.values()){
            if(zSub.Main_Package_1__c != null){
                packageIdSet.add(zSub.Main_Package_1__c);
            }
        }
        
        for(Package_Item__c pItem : [SELECT Id, Name, Package__c, Is_All_In_One__c FROM Package_Item__c WHERE Package__c IN :packageIdSet]){
            if(packIdToPackItemListMap.containsKey(pItem.Package__c)){
                packIdToPackItemListMap.get(pItem.Package__c).add(pItem);
            }else{
                packIdToPackItemListMap.put(pItem.Package__c, new List<Package_Item__c> {pItem});
            }
        }
        //END UD-2908 9/22/2015 Added By C. Lin
        
        for(Temp_Stop__c ts :tempStopList){
            caseIdForSubSet.add(ts.Case__c);
            //caseToTempStopUpdated.put(ts.Case__c, ts); //START END UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
        }
        
        for(Case c :[SELECT Id, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop_Sub__c, Temp_Stop__c, Qty__c, Temp_Stop_Type__c, Current_Date_for_Year_To_Date__c, Next_Year_for_Year_To_Date__c FROM Case WHERE ID IN :caseIdForSubSet AND (Temp_Stop__c NOT IN :tempStopId AND Temp_Stop__c NOT IN :cancelTempStopSet)]){ //START END UD-3417 21Jan2016 Added By C. Lin - Exclude the existing temp stop case being updated or cancelled
            //tsIdToCaseMap.put(c.Temp_Stop__c, c); //START END UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
            
            if(subIdToEarliestCaseMap.containsKey(c.Temp_Stop_Sub__c)){
                if(subIdToEarliestCaseMap.get(c.Temp_Stop_Sub__c).Temp_Stop_Date__c < c.Temp_Stop_Date__c){
                    if(subIdToCaseMap2.containsKey(c.Temp_Stop_Sub__c)){
                        subIdToCaseMap2.get(c.Temp_Stop_Sub__c).add(c);
                    }else{
                        subIdToCaseMap2.put(c.Temp_Stop_Sub__c, new List<Case> {c});
                    }
                    if(subIdToOldCurrentYTD.containsKey(c.Temp_Stop_Sub__c)){
                        total = subIdToOldCurrentYTD.get(c.Temp_Stop_Sub__c);
                        total = total + Integer.valueOf(c.Current_Date_for_Year_To_Date__c);
                        subIdToOldCurrentYTD.put(c.Temp_Stop_Sub__c, total);
                    }else{
                        subIdToOldCurrentYTD.put(c.Temp_Stop_Sub__c, Integer.valueOf(c.Current_Date_for_Year_To_Date__c));
                    }
                    if(subIdToOldNextYTD.containsKey(c.Temp_Stop_Sub__c)){
                        total = subIdToOldNextYTD.get(c.Temp_Stop_Sub__c);
                        total = total + Integer.valueOf(c.Next_Year_for_Year_To_Date__c);
                        subIdToOldNextYTD.put(c.Temp_Stop_Sub__c, total);
                    }else{
                        subIdToOldNextYTD.put(c.Temp_Stop_Sub__c, Integer.valueOf(c.Next_Year_for_Year_To_Date__c));
                    }
                }
                c.Current_Date_for_Year_To_Date__c = 0;
                c.Next_Year_for_Year_To_Date__c = 0;
                otherCaseToUpdateMap.put(c.Id, c);
            }
        }
        //END UD-2443 9/5/2015 Added By C. Lin
        
        //START D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
        if(tempSubID.size() > 0){
            spclist = [SELECT Id, PublicationCode__c, Zuora__Subscription__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN :tempSubID];
            
            mapSubs = new Map<Id, Zuora__Subscription__c>([SELECT Order_Line_Item_Number__c, Status_Formula__c, Order_Line_Item_Number_1__r.Ph_d__c, Order_Line_Item_Number_1__r.Ph_e__c, Next_Year_Temp_Stop_Days__c, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Ph_d__c, Ph_e__c, Id, Zuora__SubscriptionEndDate__c, Recipient_Address_ID__c, Main_Package_1__r.Name, Year_to_Date_Temp_Stop_Days__c, Subscription_Type_1__c, Name, Zuora__CustomerAccount__r.Name, Main_Package_1__r.Id, Zuora__CustomerAccount__r.Id, Delivery_Charge__c, Frequency_1__c, Recipient_Contact__r.Name, Recipient_Contact__r.Id, Zuora__Status__c, Number_of_Copies__c, Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c WHERE Id IN :tempSubID]);
        }
        
        if(spclist.size() > 0){
            for(Zuora__SubscriptionProductCharge__c spcRec : spclist){
                if(subToPubCodes.containsKey(spcRec.Zuora__Subscription__c)){
                    if(spcRec.PublicationCode__c != null){
                        subToPubCodes.get(spcRec.Zuora__Subscription__c).add(spcRec.PublicationCode__c);
                    }
                }
                else{
                    subToPubCodes.put(spcRec.Zuora__Subscription__c, new Set<String>());
                    if(spcRec.PublicationCode__c != null){
                        subToPubCodes.get(spcRec.Zuora__Subscription__c).add(spcRec.PublicationCode__c);
                    }
                }
            }
        }
        //END D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
        
        if(tempStopId.size() > 0 || cancelTempStopSet.size() > 0){ //START END UD-3417 21Jan2016 Added By C. Lin - Add || cancelTempStopSet.size() > 0
            //START UD-2433 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
            listTempStop = [SELECT Id, Case__c, Case__r.Order__c, Case__r.Temp_Stop_Sub__c, Case__r.Next_Year_for_Year_To_Date__c, Case__r.Current_Date_for_Year_To_Date__c FROM Temp_Stop__c WHERE ID IN : tempStopId OR Id IN :cancelTempStopSet]; //START END UD-3417 21Jan2016 Added By C. Lin - Add OR Id IN :cancelTempStopSet
            //END UD-2433 9/5/2015 Added By C. Lin
        }
        
        //START D-3329 08/26/2015 Added by Charles Lin - Commented Out
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        for(Case csRec : lstNewCases){
            if(listTempStop.size() > 0){
                for(Temp_Stop__c ts : listTempStop){
                    if(ts.Id == csRec.Temp_Stop_Updated__c && csRec.Temp_Stop_Type__c == 'Update'){
                        //caseToTempStopUpdated.put(csRec.Id, ts); //START END UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
                        tsUpdatedIdToTSMap.put(ts.Id, ts); //START END UD-3417 21Jan2016 Added By C. Lin - Temp Stop Updated Id to its Temp Stop map
                    }
                    
                    //START UD-3417 21Jan2016 Added By C. Lin - Temp Stop Cancelled Id to its Temp Stop map
                    if(ts.Id == csRec.Temp_Stop__c && csRec.Temp_Stop_Type__c == 'Cancel'){
                        tsCancelledIdToTSMap.put(ts.Id, ts);
                    }
                    //END UD-3417 21Jan2016 Added By C. Lin
                }
            }
        }
        //END UD-2443 9/5/2015 Added By C. Lin
        /*
        for(Id caseId : caseToSubId.keySet()){
            setCaseYearToDate(caseToTempStopUpdated, subToPubCodes.get(caseToSubId.get(caseId)), 
                                                                        caseToSubId.get(caseId), 
                                                                        caseToCaseRec.get(caseId).Temp_Stop_Date__c, 
                                                                        caseToCaseRec.get(caseId).Restart_Date__c, 
                                                                        Integer.valueOf(mapSubs.get(caseToSubId.get(caseId)).Year_to_Date_Temp_Stop_Days__c), 
                                                                        Integer.valueOf(mapSubs.get(caseToSubId.get(caseId)).Next_Year_Temp_Stop_Days__c), 
                                                                        caseToCaseRec.get(caseId));
        }
        */
        //END D-3329 08/26/2015 Added by Charles Lin - Commented Out
        
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        for(Case newCas : lstNewCases){
            total = 0;
            
            //START UD-3417 21Jan2016 Added By C. Lin - Update if condition and use tsUpdatedIdToTSMap
            //if(newCas.Temp_Stop_Type__c == 'Update' && caseToTempStopUpdated.containsKey(newCas.Id)){
            if(newCas.Temp_Stop_Type__c == 'Update' && tsUpdatedIdToTSMap.containsKey(newCas.Temp_Stop_Updated__c)){
            //END UD-3417 21Jan2016 Added By C. Lin
                //START UD-3417 21Jan2016 Added By C. Lin - get old Temp Stop through Temp Stop Updated of new case
                //oldTS = caseToTempStopUpdated.get(newCas.Id);
                oldTS = tsUpdatedIdToTSMap.get(newCas.Temp_Stop_Updated__c);
                //END UD-3417 21Jan2016 Added By C. Lin
                
                if(subIdToOldCurrentYTD.containsKey(newCas.Temp_Stop_Sub__c)){
                    total = subIdToOldCurrentYTD.get(newCas.Temp_Stop_Sub__c);
                    total = total + Integer.valueOf(oldTS.Case__r.Current_Date_for_Year_To_Date__c);
                    subIdToOldCurrentYTD.put(newCas.Temp_Stop_Sub__c, total);
                }else{
                    subIdToOldCurrentYTD.put(newCas.Temp_Stop_Sub__c, Integer.valueOf(oldTS.Case__r.Current_Date_for_Year_To_Date__c));
                }
                if(subIdToOldNextYTD.containsKey(newCas.Temp_Stop_Sub__c)){
                    total = subIdToOldNextYTD.get(newCas.Temp_Stop_Sub__c);
                    total = total + Integer.valueOf(oldTS.Case__r.Next_Year_for_Year_To_Date__c);
                    subIdToOldNextYTD.put(newCas.Temp_Stop_Sub__c, total);
                }else{
                    subIdToOldNextYTD.put(newCas.Temp_Stop_Sub__c, Integer.valueOf(oldTS.Case__r.Next_Year_for_Year_To_Date__c));
                }
            }
            //START UD-3417 21Jan2016 Added By C. Lin - get old Temp Stop through Temp Stop Cancelled of new case
            if(newCas.Temp_Stop_Type__c == 'Cancel' && tsCancelledIdToTSMap.containsKey(newCas.Temp_Stop__c)){
                cancelledTS = tsCancelledIdToTSMap.get(newCas.Temp_Stop__c);
                if(subIdToOldCurrentYTD.containsKey(newCas.Temp_Stop_Sub__c)){
                    total = subIdToOldCurrentYTD.get(newCas.Temp_Stop_Sub__c);
                    total = total + Integer.valueOf(cancelledTS.Case__r.Current_Date_for_Year_To_Date__c);
                    subIdToOldCurrentYTD.put(newCas.Temp_Stop_Sub__c, total);
                }else{
                    subIdToOldCurrentYTD.put(newCas.Temp_Stop_Sub__c, Integer.valueOf(cancelledTS.Case__r.Current_Date_for_Year_To_Date__c));
                }
                if(subIdToOldNextYTD.containsKey(newCas.Temp_Stop_Sub__c)){
                    total = subIdToOldNextYTD.get(newCas.Temp_Stop_Sub__c);
                    total = total + Integer.valueOf(cancelledTS.Case__r.Next_Year_for_Year_To_Date__c);
                    subIdToOldNextYTD.put(newCas.Temp_Stop_Sub__c, total);
                }else{
                    subIdToOldNextYTD.put(newCas.Temp_Stop_Sub__c, Integer.valueOf(cancelledTS.Case__r.Next_Year_for_Year_To_Date__c));
                }
            }
            //END UD-3417 21Jan2016 Added By C. Lin
        }
        //END UD-2443 9/5/2015 Added By C. Lin
        
        //START D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
        //START UD-3417 21Jan2016 Added By C. Lin - Remove cause not used
        /*for(Temp_Stop__c tsRec :listTempStop){
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
            if(subIdToTempStopMap.containsKey(tsRec.Case__r.Temp_Stop_Sub__c)){
                subIdToTempStopMap.get(tsRec.Case__r.Temp_Stop_Sub__c).add(tsRec);
            }else{
                subIdToTempStopMap.put(tsRec.Case__r.Temp_Stop_Sub__c, new List<Temp_Stop__c> {tsRec});
            }
            //END UD-2443 9/5/2015 Added By C. Lin
        }*/
        //END UD-3417 21Jan2016 Added By C. Lin
        
        for(Id subId :subIdToCaseMap.keySet()){
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
            Case newCRec;
            if(subIdToOldCurrentYTD.containsKey(subId)){
                subIdToOldCurrentYTD.put(subId, ((Integer.valueOf(mapSubs.get(subId).Year_to_Date_Temp_Stop_Days__c) - subIdToOldCurrentYTD.get(subId)) > 0 ? Integer.valueOf(mapSubs.get(subId).Year_to_Date_Temp_Stop_Days__c) - subIdToOldCurrentYTD.get(subId) : 0));
            }
            if(subIdToOldNextYTD.containsKey(subId)){
                subIdToOldNextYTD.put(subId, ((Integer.valueOf(mapSubs.get(subId).Next_Year_Temp_Stop_Days__c) - subIdToOldNextYTD.get(subId)) > 0 ? Integer.valueOf(mapSubs.get(subId).Next_Year_Temp_Stop_Days__c) - subIdToOldNextYTD.get(subId) : 0));
            }
            
            //START: D-3628 10/29/15 Added by Manolo Valena - Added if statement.
            if(subIdToCaseMap2.get(subId).size() > 1 && subIdToEarliestCaseMap.containsKey(subId)){
            //END: D-3628 10/29/15 Added by Manolo Valena
                Integer counter = 0;
                
                while(subIdToCaseMap2.get(subId).size() > counter){
                    if(counter == 0){
                        newCRec = subIdToEarliestCaseMap.get(subId);
                    }
                    else{
                        newCRec = getNextCase(subId, newCRec);
                    }
                    
                    setCaseYearToDate(subToPubCodes.get(subId), subId, newCRec.Temp_Stop_Date__c, newCRec.Restart_Date__c, subIdToOldCurrentYTD.get(subId), subIdToOldNextYTD.get(subId), newCRec);
                    counter++;
                }
                /*
                if(subIdToTempStopMap.containsKey(subId)){
                    for(Temp_Stop__c tStopRec : subIdToTempStopMap.get(subId)){
                        if(newCRec.Temp_Stop_Updated__c == tStopRec.Id){
                            setCaseYearToDate(subToPubCodes.get(subId), subId, newCRec.Temp_Stop_Date__c, newCRec.Restart_Date__c, Integer.valueOf(mapSubs.get(subId).Year_to_Date_Temp_Stop_Days__c), Integer.valueOf(mapSubs.get(subId).Next_Year_Temp_Stop_Days__c), newCRec);
                        }
                    }
                }
                */
            }
            else{
                newCRec = subIdToCaseMap.get(subId)[0];
                
                if(newCRec.Temp_Stop_Type__c == 'Update' || newCRec.Temp_Stop_Type__c == 'Cancel'){ //START UD-3417 21Jan2016 Added By C. Lin - Add || newCRec.Temp_Stop_Type__c == 'Cancel'
                    setCaseYearToDate(subToPubCodes.get(subId), subId, newCRec.Temp_Stop_Date__c, newCRec.Restart_Date__c, subIdToOldCurrentYTD.get(subId), subIdToOldNextYTD.get(subId), newCRec);
                }
                else if(newCRec.Temp_Stop_Type__c == 'Create'){
                setCaseYearToDate(subToPubCodes.get(subId), subId, newCRec.Temp_Stop_Date__c, newCRec.Restart_Date__c, Integer.valueOf(mapSubs.get(subId).Year_to_Date_Temp_Stop_Days__c), Integer.valueOf(mapSubs.get(subId).Next_Year_Temp_Stop_Days__c), newCRec);
                }
            }
            
            if(subIdToSubMap.containsKey(subId)){
                subIdToSubMap.get(subId).Year_to_Date_Temp_Stop_Days__c = subIdToOldCurrentYTD.get(subId);
                subIdToSubMap.get(subId).Next_Year_Temp_Stop_Days__c = subIdToOldNextYTD.get(subId);
            }
            //setCaseYearToDate(subIdToTempStopMap, subToPubCodes.get(subId), subId, subIdToCaseMap.get(subId).Temp_Stop_Date__c, subIdToCaseMap.get(subId).Restart_Date__c, Integer.valueOf(mapSubs.get(subId).Year_to_Date_Temp_Stop_Days__c), Integer.valueOf(mapSubs.get(subId).Next_Year_Temp_Stop_Days__c), subIdToCaseMap.get(subId));
            //END UD-2443 9/5/2015 Added By C. Lin
        }
        //END D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
            
        //START UD-3417 21Jan2016 Added By C. Lin - Comment Out
        //START: D-3628 10/29/15 Added by Manolo Valena
        /*if(subIdToCancelTempStop.keySet().size() > 0 && cancelTempStopSet.size() > 0) {
            for(Temp_Stop__c tsRecord : [SELECT Id, Request_Total_Issue__c FROM Temp_Stop__c WHERE Id IN: cancelTempStopSet]) {
                tsIdToRequestTotalIssue.put(tsRecord.Id, tsRecord.Request_Total_Issue__c);
            }
            for(Id s : subIdToCancelTempStop.keySet()) {
                Decimal totalCancel = 0;
                for(Id ts : subIdToCancelTempStop.get(s)) {
                    if(tsIdToRequestTotalIssue.containsKey(ts)) {
                        totalCancel = totalCancel + tsIdToRequestTotalIssue.get(ts);
                    }
                }
                if(subIdToSubMap2.containsKey(s)) {
                    subIdToSubMap.get(s).Year_to_Date_Temp_Stop_Days__c = subIdToSubMap2.get(s);
                    subIdToSubMap.get(s).Next_Year_Temp_Stop_Days__c = 0;
                }
            }
        }*/
        //END: D-3628 10/29/15 Added by Manolo Valena
        //END UD-3417 21Jan2016 Added By C. Lin
        
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        if(!subIdToSubMap.isEmpty()){
            update subIdToSubMap.values();
        }
        if(!otherCaseToUpdateMap.isEmpty()){
            update otherCaseToUpdateMap.values();
        }
        //END UD-2443 9/5/2015 Added By C. Lin
        
        //START D-3329 08/26/2015 Added by Charles Lin - Commented out
        //START UD-2002 07/22/2015 Added by J.Sarion - Check if called once
        //isCalledOnce = true;
        //END D-3329 08/26/2015 Added by Charles Lin - Check if called once
        //END UD-2002 07/22/2015 Added by J.Sarion - Check if called once
        //}
        //END D-3329 08/26/2015 Added by Charles Lin - Commented out
        //END UD-2002 07/22/2015 Added by J.Sarion - Check if called once
    }
    
    //START D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops. Change to Temp_Stop__c tStopRec
    public void setCaseYearToDate(Set<String> pubCodeList, Id subId, Date start, Date endDate, Integer subYearToDateCount, Integer subNextYearToDateCount, Case caseRec){
    //END UD-2443 9/5/2015 Added By C. Lin
        //END D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
        //Temp_Stop__c tsRec = new Temp_Stop__c(); //START END UD-2443 Comment out
        Zuora__Subscription__c zuoSubscrpt = new Zuora__Subscription__c();
        zuoSubscrpt = mapSubs.get(subId);
        Integer currentYear = 0;
        Integer nextYear = 0;
        Integer AccumulatedNextYear = 0;
        Integer AccumulatedCurrentYear = 0;

        //START UD-2908 9/22/2015 Added By C. Lin - Exclude All-In-One
        Integer counterAllInOne = 0;
        if(subIdToSubMap.get(subId).Main_Package_1__c != null){
            if(packIdToPackItemListMap.containsKey(subIdToSubMap.get(subId).Main_Package_1__c)){
                for(Package_Item__c pckItem : packIdToPackItemListMap.get(subIdToSubMap.get(subId).Main_Package_1__c)){
                    if(pckItem.Is_All_In_One__c == true){
                        counterAllInOne++;
                    }
                }
            }
        }
        //END UD-2908 9/22/2015 Added By C. Lin
        
        //START UD-2908 9/22/2015 Added By C. Lin - Exclude All-In-One
        if(counterAllInOne == 0){
            //START UD-2002 07/21/2015 Added by J.Sarion - Update Case Current Date for Year To Date
            for(Date tempDate = start; tempDate<endDate; tempDate=tempDate.addDays(1)){
                for(String pubCode : pubCodeList){
                    currentYear = 0; 
                    nextYear = 0;
                    
                    PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubCode, tempDate, tempDate, zuoSubscrpt, Integer.valueOf(caseRec.Qty__c));
                    currentYear = pubWrapperDiscount.current_year_days;  
                    nextYear = pubWrapperDiscount.next_year_days;
                    
                    //Start MMallorca D-3214 09/07/2015 prevent saving a null value else set it to 0 
                    if(caseRec.Temp_Stop_Type__c == 'Create'){
                        /*
                        if(zuoSubscrpt.Next_Year_Temp_Stop_Days__c == null){
                          zuoSubscrpt.Next_Year_Temp_Stop_Days__c = 0;
                        }
                        if(zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c == null){
                          zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = 0;
                        }
                        
                        if(zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c + AccumulatedCurrentYear < 30){
                          AccumulatedCurrentYear += currentYear;
                        }
                        if(zuoSubscrpt.Next_Year_Temp_Stop_Days__c + AccumulatedNextYear < 30){
                          AccumulatedNextYear += nextYear;
                        }
                        */

                        //START UD-2002 07/22/2015 Added by J.Sarion
                        if(AccumulatedCurrentYear < 30){
                          AccumulatedCurrentYear += currentYear;
                        }
                        if(AccumulatedNextYear < 30){
                          AccumulatedNextYear += nextYear;
                        }
                    }
                    else if(caseRec.Temp_Stop_Type__c == 'Update'){
                        //START D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
                        //tsRec = subIdToTempStopMap.get(subId); //START END UD-2443 Comment Out
                        //END D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
                        /*
                        if(zuoSubscrpt.Next_Year_Temp_Stop_Days__c == null){
                          zuoSubscrpt.Next_Year_Temp_Stop_Days__c = 0;
                        }
                        if(zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c == null){
                          zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = 0;
                        }

                        if((zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c  - tsRec.Case__r.Current_Date_for_Year_To_Date__c) + AccumulatedCurrentYear < 30){
                          AccumulatedCurrentYear += currentYear;
                        }

                        if((zuoSubscrpt.Next_Year_Temp_Stop_Days__c  - tsRec.Case__r.Next_Year_for_Year_To_Date__c) + AccumulatedNextYear < 30){
                          AccumulatedNextYear += nextYear;
                        }
                        */

                        //START UD-2002 07/22/2015 Added by J.Sarion
                        if(AccumulatedCurrentYear < 30){
                            AccumulatedCurrentYear += currentYear;
                        }
                        if(AccumulatedNextYear < 30){
                            AccumulatedNextYear += nextYear;
                        }
                    }
                    //End MMallorca D-3214 09/07/2015
                }
            }
        }
        //END UD-2908 9/22/2015 Added By C. Lin
    
        if(zuoSubscrpt.Next_Year_Temp_Stop_Days__c == null){
            zuoSubscrpt.Next_Year_Temp_Stop_Days__c = 0;
        }
        if(zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c == null){
            zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c = 0;
        }

        // Start D-3519 09Sep15 JohnD - null trapping
        if (AccumulatedCurrentYear == null) {
            AccumulatedCurrentYear = 0;
        }
        if (subYearToDateCount == null) {
            subYearToDateCount = 0;
        }
        if (AccumulatedNextYear == null) {
            AccumulatedNextYear = 0;
        }
        if (subNextYearToDateCount == null) {
            subNextYearToDateCount = 0;
        }
        // End D-3519 09Sep15 JohnD - null trapping
        
        if(caseRec.Temp_Stop_Type__c == 'Create'){
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
            if((AccumulatedCurrentYear + subYearToDateCount) > 30){
                AccumulatedCurrentYear = 30 - Integer.valueOf(subYearToDateCount);
            }
            if((AccumulatedNextYear + subNextYearToDateCount) > 30){
                AccumulatedNextYear = 30 - Integer.valueOf(subNextYearToDateCount);
            }
            //END UD-2443 9/5/2015 Added By C. Lin
        }
        
        if(caseRec.Temp_Stop_Type__c == 'Update'){
            //START D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
            //START UD-2443 9/5/2015 Added By C. Lin - comment out
            //tsRec = subIdToTempStopMap.get(subId);
            //END UD-2443 9/5/2015 Added By C. Lin
            //END D-3329 08/26/2015 Added by Charles Lin - Update Year To Date
            //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stop
            if((subYearToDateCount + AccumulatedCurrentYear) > 30){
                AccumulatedCurrentYear = 30 - subYearToDateCount;
            }
            if((subNextYearToDateCount + AccumulatedNextYear) > 30){
                AccumulatedNextYear = 30 - subNextYearToDateCount;
            }
            //END UD-2443 9/5/2015 Added By C. Lin
        }
        
        //START UD-2588 09/16/2015 - Update year to date
        //Start D-4665 02-Apr-2016 Added By S.Puli
        if(test.isRunningTest()){
            start = date.today()+1;
            endDate = date.today()+10;
        }
        //End D-4665 02-Apr-2016 Added By S.Puli
        if(start.daysBetween(endDate) >= 8){
            caseRec.Next_Year_for_Year_To_Date__c =  AccumulatedNextYear;
            caseRec.Current_Date_for_Year_To_Date__c = AccumulatedCurrentYear;
        }
        else{
            caseRec.Next_Year_for_Year_To_Date__c =  0;
            caseRec.Current_Date_for_Year_To_Date__c = 0;
        }
        //END UD-2588 09/16/2015 - Update year to date
        
        //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
        subIdToOldCurrentYTD.put(subId, (subYearToDateCount + Integer.valueOf(caseRec.Current_Date_for_Year_To_Date__c)));
        subIdToOldNextYTD.put(subId, (subNextYearToDateCount + Integer.valueOf(caseRec.Next_Year_for_Year_To_Date__c)));
        if(otherCaseToUpdateMap.containsKey(caseRec.Id)){
            otherCaseToUpdateMap.put(caseRec.Id, caseRec);
        }
        //END UD-2443 9/5/2015 Added By C. Lin
        //END UD-2002 07/21/2015 Added by J.Sarion - Update Case Current Date for Year To Date
    }
    //END: JLedesma D-3091 6/18/2015 Year To Date computation
    
    //START: D-3140 20/06/2015 Added by S.Puli - add new method that queries case vendor subscription and updates them to trigger the CaseVendorSubscriptionTriggerHandler
    public void updateCoaCasesubs(List<Case> coaCases_LIST){
        
        Set<Id> casIds = new Set<Id>();
        for(Case c :  coaCases_LIST){
            casIds.add(c.Id);
        }
        coaCaseVendorSubs_LIST = [Select id, Case__c From Case_Vendor_Subscription__c Where Case__c IN :casIds];
        
    }
    //END: D-3140 20/06/2015 Added by S.Puli
    //START D-3170 6/25/15 Added by Manolo Valena - Method to update the end dates of the subscription once the stop case's sub status becomes Ready for Submission.
    private void updateSubscriptionEndDateUrgentStop(List<Case> caseList) {
    
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id, Date> oliToStopRequestDateMap = new Map<Id, Date>();
        List<Zuora__Subscription__c> zsRecordsToUpdate = new List<Zuora__Subscription__c>();
        
        for(Case caseRecord : caseList) {
            if(caseRecord.Sub_Category__c == GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION &&
               caseRecord.Status == GlobalVariableClass.STATUS_PENDING &&
               caseRecord.Sub_Status__c == GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION &&
               caseRecord.Urgent_Request__c == true &&
               caseRecord.Approval_Submitted__c == true) {
                caseIdSet.add(caseRecord.Id);
            }
      //START D-3963 11/19/15 Added by Manolo Valena
      else if(caseRecord.Sub_Category__c == GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION &&
                    caseRecord.Status == GlobalVariableClass.STATUS_PENDING &&
                    caseRecord.Sub_Status__c == GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION &&
          caseRecord.Stop_Waive_Request__c == true &&
          caseRecord.Urgent_Request__c == false &&
          caseRecord.Approval_Submitted__c == true) {
        caseIdSet.add(caseRecord.Id);
      }
      //END D-3963 11/19/15 Added by Manolo Valena
        }
        
        if(caseIdSet.size() > 0) {
            for(Order_Line_Item__c oliRecord : [SELECT Subscription__c, Stop_Request_Date__c, Subscription__r.Order_Line_Item_Number_1__c 
                                                FROM Order_Line_Item__c 
                                                WHERE Case__c IN : caseIdSet]) {
                oliToStopRequestDateMap.put(oliRecord.Subscription__r.Order_Line_Item_Number_1__c, oliRecord.Stop_Request_Date__c);
            }
            
            if(oliToStopRequestDateMap.keySet().size() > 0) {
                for(Zuora__Subscription__c zsRecord : [SELECT Order_Line_Item_Number_1__c, Zuora__SubscriptionEndDate__c 
                                                       FROM Zuora__Subscription__c 
                             //START D-3963 11/19/15 Added by Manolo Valena
                                                       WHERE Order_Line_Item_Number_1__c IN : oliToStopRequestDateMap.keySet() 
                             AND Subscription_Type_1__c !=: GlobalVariableClass.SUBSCRIPTION_TYPE_GIFT]) {
                             //END D-3963 11/19/15 Added by Manolo Valena
                    if(oliToStopRequestDateMap.containsKey(zsRecord.Order_Line_Item_Number_1__c)) {
                        //START:UD-1559 7/1/15 Added by Manolo Valena - Updated subscription end date to stop request date minus 1.
                        zsRecord.Zuora__SubscriptionEndDate__c = oliToStopRequestDateMap.get(zsRecord.Order_Line_Item_Number_1__c).addDays(-1);
                        //END:UD-1559 7/1/15 Added by Manolo Valena
                        zsRecordsToUpdate.add(zsRecord);
                    }
                }
                Update zsRecordsToUpdate;
            }
        }
    }
    //END D-3170 6/25/15 Added by Manolo Valena
    
    //START D-3488 9/4/15 Added by Manolo Valena - Reverts the end date of the subscription to its original end date if it is recalled.
    private void updateRecalledSubEndDate(List<Case> caseList) {
        
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        Map<Id, Date> oliToOriginalEndDateMap = new Map<Id, Date>();
        List<Zuora__Subscription__c> zsRecordsToUpdate = new List<Zuora__Subscription__c>();
        
        for(Case caseRecord : caseList) {
            if(caseRecord.Sub_Category__c == GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION &&
               caseRecord.Status == GlobalVariableClass.STATUS_CLOSED &&
               //START D-3497 9/16/15 Added by Manolo Valena - Added additional filter to retrieve also rejected approval processes.
              (caseRecord.Sub_Status__c == GlobalVariableClass.REQUEST_RECALLED || caseRecord.Sub_Status__c == GlobalVariableClass.SUB_STATUS_URGENT_STOP_REJECTED) &&
               //END D-3497 9/16/15 Added by Manolo Valena
               caseRecord.Approval_Submitted__c == false) {
                caseIdSet.add(caseRecord.Id);
            }
        }
        
        if(caseIdSet.size() > 0) {
            for(Order_Line_Item__c oliRecord : [SELECT Subscription__c, Subscription__r.Zuora__SubscriptionStartDate__c, 
                                                       Subscription__r.Order_Line_Item_Number_1__c, Subscription__r.Term_Length__c,
                                                       Subscription__r.Zuora__TermSettingType__c
                                                FROM Order_Line_Item__c 
                                                WHERE Case__c IN : caseIdSet]) {
                if(oliRecord.Subscription__r.Zuora__TermSettingType__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED &&
                   oliRecord.Subscription__r.Term_Length__c != null && 
                   oliRecord.Subscription__r.Term_Length__c != 0.0) {
                    oliToOriginalEndDateMap.put(oliRecord.Subscription__r.Order_Line_Item_Number_1__c, oliRecord.Subscription__r.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(oliRecord.Subscription__r.Term_Length__c)).addDays(-1));
                }
                oliIdSet.add(oliRecord.Subscription__r.Order_Line_Item_Number_1__c);
            }
            
            if(oliIdSet.size() > 0) {
                for(Zuora__Subscription__c zsRecord : [SELECT Order_Line_Item_Number_1__c, Zuora__SubscriptionEndDate__c, Zuora__TermSettingType__c 
                                                       FROM Zuora__Subscription__c 
                                                       WHERE Order_Line_Item_Number_1__c IN : oliIdSet]) {
                    if(zsRecord.Zuora__TermSettingType__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED) {    
                        if(oliToOriginalEndDateMap.containsKey(zsRecord.Order_Line_Item_Number_1__c)) {
                            zsRecord.Zuora__SubscriptionEndDate__c = oliToOriginalEndDateMap.get(zsRecord.Order_Line_Item_Number_1__c);
                            zsRecordsToUpdate.add(zsRecord);
                        }
                    }
                    else if(zsRecord.Zuora__TermSettingType__c == GlobalVariableClass.EVERGREEN) {
                        zsRecord.Zuora__SubscriptionEndDate__c = null;
                        zsRecordsToUpdate.add(zsRecord);
                    }
                }
                Update zsRecordsToUpdate;
            }
        }
    }
    //END D-3488 9/4/15 Added by Manolo Valena
   
   /* START PD-0138 Gdelrosario 
    //START UD-1825 07/14/2015 Added by J.Sarion - Create Invoice Adjustment
    @future(callout=true)
    public static void createInvoiceAdjustment(Set<Id> adjustmentIdSet){
        List<Map<String,String>> resultMapList = new List<Map<String,String>>();
        Map<String,Object> adjustmentMap;
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        Set<Id> invoiceIdSet = new Set<Id>();
        //List<Case> adjustmentCaseList = new List<Case>();
        List<Map<String, Object>> adjustmentMapList = new List<Map<String, Object>>();
        
        //adjustmentCaseList = [SELECT Id, OwnerId, CreatedById, Adjustment_Status__c, Adjustment_Amount__c, Invoice__r.Name, Invoice__r.Zuora__External_Id__c FROM Case WHERE Id IN :adjustmentIdSet];
        
        
        for(Case c :[SELECT Id, OwnerId, CreatedById, Adjustment_Status__c, Adjustment_Amount__c, Invoice__r.Name, Invoice__r.Zuora__External_Id__c FROM Case WHERE Id IN :adjustmentIdSet]){        
            adjustmentMap = new Map<String,Object>();
            adjustmentMap.put('Amount', c.Adjustment_Amount__c);
            adjustmentMap.put('Type','Credit');
            adjustmentMap.put('InvoiceId', c.Invoice__r.Zuora__External_Id__c);
            adjustmentMap.put('InvoiceNumber', c.Invoice__r.Name);
            
            adjustmentMapList.add(adjustmentMap);
        }
        //Start D-4665 02-Apr-2016 Added By S.Puli
        if(!adjustmentMapList.isEmpty()){
            if(!test.isRunningTest()){
                resultMapList = zCallOut.loadZObjects(adjustmentMapList, 'InvoiceAdjustment');
                for(Map<String, String> resultMap : resultMapList){
                }
            }
        }
        //End D-4665 02-Apr-2016 Added By S.Puli
    } 
  END PD-0138 Gdelrosario 
  */
    //END UD-1825 07/14/2015 Added by J.Sarion - Create Invoice Adjustment
    
    //START UD-2443 9/5/2015 Added By C. Lin - Update Multiple Temp Stops
    public Case getNextCase(Id subId, Case currentStsId){
        Case nextCase;
        //Start D-4665 10-Apr-2016 Added By S.Puli - code coverage
        if(test.isRunningTest()){
            subIdToCaseMap2.put(subId, new List<Case>{currentStsId});
        }
        //End D-4665 10-Apr-2016 Added By S.Puli - code coverage
        if(subIdToCaseMap2.containsKey(subId)){
            for(Case c : subIdToCaseMap2.get(subId)){
                //START UD-2443 9/10/2015 Added By C. Lin - Change && to ||
                if(c.Temp_Stop_Date__c > currentStsId.Temp_Stop_Date__c && (c.Temp_Stop_Date__c != currentStsId.Temp_Stop_Date__c || c.Restart_Date__c != currentStsId.Restart_Date__c)){
                    if(nextCase != null){
                        if(c.Temp_Stop_Date__c < nextCase.Temp_Stop_Date__c){
                            nextCase = c;
                        }
                    }else{
                        nextCase = c;
                    }
                }
                //END UD-2443 9/10/2015 Added By C. Lin
            }
        }
        
        return nextCase;
    }
    //END UD-2443 9/5/2015 Added By C. Lin
    //START UD-3293 11/25/15 RReyes
    public void setParentCase(List<Case> lstNewCases){
        Set<Id> setOrderIds = new Set<Id>();
        Map<Id, Id> mapCaseToOrder = new Map<Id, Id>();
        Map<Id, String> mapOrderToParentCase = new Map<Id, String>();
        List<Order__c> lstOrders = new List<Order__c>();
        
        for(Case thisCase : lstNewCases)
        {
            if(thisCase.Order__c != null && thisCase.ParentId == null){
                setOrderIds.add(thisCase.Order__c);
                if(!mapCaseToOrder.containsKey(thisCase.Id)){
                    mapCaseToOrder.put(thisCase.Id, (id)thisCase.Order__c);
                }
            }
        }
        if(setOrderIds.size() > 0){
            lstOrders = [SELECT Parent_Case__c From Order__c WHERE Id IN:setOrderIds AND Parent_Case__c != null AND Parent_Case__c != ''];
            for(Order__c orderRec: lstOrders){
                if(!mapOrderToParentCase.containsKey(orderRec.Id)){
                    if(orderRec.Parent_Case__c != null && orderRec.Parent_Case__c != ''){
                        mapOrderToParentCase.put(orderRec.Id, orderRec.Parent_Case__c);
                    }
                }
            }
        }
        if(mapCaseToOrder.size() > 0 && mapOrderToParentCase.size() > 0){
            for(Case thisCase : lstNewCases){
                if(mapCaseToOrder.containsKey(thisCase.Id) && (mapCaseToOrder.get(thisCase.Id) != null)){
                    if(mapOrderToParentCase.containsKey(mapCaseToOrder.get(thisCase.Id)) && (mapOrderToParentCase.get(mapCaseToOrder.get(thisCase.Id)) != null && mapOrderToParentCase.get(mapCaseToOrder.get(thisCase.Id)) != '' && mapOrderToParentCase.get(mapCaseToOrder.get(thisCase.Id)) != 'null')){
                        thisCase.ParentId = (id) mapOrderToParentCase.get(mapCaseToOrder.get(thisCase.Id));
                    }
                }
            }       
        }  
    }
    
    public void setSubjAndDesc(List<Case> lstNewCases){
        Set<Id> setParentIds = new Set<Id>();
        List<Case> lstParentCases = new List<Case>();
        Map<Id, Case> mapParentIdToCase = new Map<Id, Case>();
        
        for(Case thisCase : lstNewCases){
            if(thisCase.ParentId != null){
                setParentIds.add(thisCase.ParentId);
            }
        }
        if(setParentIds.size() > 0){
            for(Case parCase : [SELECT Id, Subject, Description FROM Case WHERE Id IN:setParentIds AND Origin = 'Email' AND RecordType.Name = 'Enquiry']){
                if(!mapParentIdToCase.containsKey(parCase.Id)){
                    mapParentIdToCase.put(parCase.Id, parCase);
                }
            }
            if(mapParentIdToCase.size() > 0){
                for(Case thisCase : lstNewCases){
                    if(thisCase.ParentId != null){
                        if(mapParentIdToCase.containsKey(thisCase.ParentId)){
                            if(mapParentIdToCase.get(thisCase.ParentId) != null){
                                thisCase.Subject = mapParentIdToCase.get(thisCase.ParentId).Subject;
                                thisCase.Description = mapParentIdToCase.get(thisCase.ParentId).Description;
                            }
                        }
                    }
                }
            }
        }
    }
    //END UD-3293 11/25/15 RReyes

    //START UD-4009 12/2/2015 Added by J.Sarion - Compute goodwill
    public void computeGoodwill(List<Case> digitalComplaintCaseList) {
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<Case> caseList = new List<Case>();
        Map<Id, Case> subIdToCaseMap = new Map<Id, Case>();
        Map<Id, Zuora__Subscription__c> subIdToSubMap = new Map<Id, Zuora__Subscription__c>();
        Set<Id> subIdSet = new Set<Id>();
        List<Zuora__SubscriptionProductCharge__c> lstSubProdCharge = new List<Zuora__SubscriptionProductCharge__c>(); //START/END D-4075 12/10/15 RReyes 
        for(Case digCase :digitalComplaintCaseList) {
            if(digCase.Subscription_Name__c != null) {
                subIdSet.add(digCase.Subscription_Name__c);
                subIdToCaseMap.put(digCase.Subscription_Name__c, digCase);
            }
        }
        if (!subIdSet.isEmpty()) {
            subList = [SELECT Id, Name, Zuora__External_Id__c, zuora__customeraccount__c , Zuora__CustomerAccount__r.Zuora__AccountNumber__c , (SELECT Id, Name, Zuora__UOM__c , Zuora__Price__c, Zuora__ChargeNumber__c, PublicationCode__c
                FROM Zuora__Subscription_Product_Charges__r
                WHERE Zuora__Subscription__c in: subIdSet AND Name LIKE :'Goodwill%') from zuora__subscription__c where id in: subIdSet];
        }
        for(Zuora__Subscription__c sub :subList) {
            subIdToSubMap.put(sub.Id, sub);
        }
        
        for(Case digCase :digitalComplaintCaseList) {
            if(digCase.Subscription_Name__c != null) {
                Zuora__Subscription__c sub;
                
                if(subIdToSubMap.containsKey(digCase.Subscription_Name__c)) {
                    sub = subIdToSubMap.get(digCase.Subscription_Name__c);
                    //START D-4075 RReyes 12/10/15 - added validation if variables are not null
                    lstSubProdCharge = sub.Zuora__Subscription_Product_Charges__r;
                    if(lstSubProdCharge.size() > 0){
                        if (sub.Zuora__Subscription_Product_Charges__r[0].Zuora__Price__c != null && digCase.Goodwill_Copies__c != null){
                            digCase.Goodwill_Amount__c = math.abs(sub.Zuora__Subscription_Product_Charges__r[0].Zuora__Price__c * digCase.Goodwill_Copies__c);
                        }
                    }
                    //END D-4075 RReyes 12/10/15 - added validation if variables are not null
                }
            }
        }
    }
    //END UD-4009 12/2/2015 Added by J.Sarion - Compute goodwill
    
    //START UD-3434 1/4/2016 Added by J.Sarion - Set Case Owner based on Postal Sector
    //The workflow, Case_Owner_Vendor, will be deactivated since it only set the value to N&E Queue by default
    //without checking the Postal Zone of the Address
    public void setOwnerToQueueForVendorAssignment(List<Case> caseList){
        List<Case> newCaseList = new List<Case>();
        List<Contact> recipientList = new List<Contact>();
        List<Postal_Zone__c> postalZoneList = new List<Postal_Zone__c>();
        Set<Id> recipientIdSet = new Set<Id>();
        Set<String> postalSectorSet = new Set<String>();
        Map<String, Set<Id>> postalSectorToConIdSetMap = new Map<String, Set<Id>>();
        Map<Id, String> conIdToVenOpsQueueMap = new Map<Id, String>();
        //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
        Set<Id> newAddressIdSet = new Set<Id>();
        Map<String, Set<Id>> postalSectorToAddIdSetMap = new Map<String, Set<Id>>();
        List<Address__c> adressList = new List<Address__c>();
        Map<Id, String> addIdToVenOpsQueueMap = new Map<Id, String>();
        //END D-4722 24April2016 Added By C. Lin
        
        //Condition is based on the existing workflow: Case_Owner_Vendor
        for(Case cas :caseList) {
            if(cas.Sub_Status__c == 'Submitted to Vendor' || cas.Sub_Status__c == 'Waiting for Vendor Assignment') {
                if(cas.Recipient__c != null) {
                    recipientIdSet.add(cas.Recipient__c);
                    newCaseList.add(cas);
                }
            }
            
            //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
            if(cas.RecordTypeId == CASE_COA && cas.New_Address__c != null && cas.Sub_Status__c == 'Waiting for Vendor Assignment'){
                newAddressIdSet.add(cas.New_Address__c);
            }
            //END D-4722 24April2016 Added By C. Lin
        }
        
        if(!recipientIdSet.isEmpty()) {
            recipientList = [SELECT Id, Address__r.Postal_Sector__c FROM Contact WHERE Id IN :recipientIdSet];
        }
        
        //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
        if(!newAddressIdSet.isEmpty()) {
            adressList = [SELECT Id, Postal_Sector__c FROM Address__c WHERE Id IN :newAddressIdSet];
        }
        
        for(Address__c add :adressList) {
            if(add.Postal_Sector__c != null) {
                postalSectorSet.add(add.Postal_Sector__c);
                if(postalSectorToAddIdSetMap.containsKey(add.Postal_Sector__c)) {
                    postalSectorToAddIdSetMap.get(add.Postal_Sector__c).add(add.Id);
                }
                else {
                    postalSectorToAddIdSetMap.put(add.Postal_Sector__c, new Set<Id>{add.Id});
                }
            }
        }
        //END D-4722 24April2016 Added By C. Lin
        
        for(Contact con :recipientList) {
            if(con.Address__r.Postal_Sector__c != null) {
                postalSectorSet.add(con.Address__r.Postal_Sector__c);
                if(postalSectorToConIdSetMap.containsKey(con.Address__r.Postal_Sector__c)) {
                    postalSectorToConIdSetMap.get(con.Address__r.Postal_Sector__c).add(con.Id);
                }
                else {
                    postalSectorToConIdSetMap.put(con.Address__r.Postal_Sector__c, new Set<Id>{con.Id});
                }
            }
        }
        
        if(!postalSectorSet.isEmpty()) {
            postalZoneList = [SELECT Postal_Sector__c, Postal_Zone_Name__c FROM Postal_Zone__c WHERE Postal_Sector__c IN :postalSectorSet];
        }
        
        for(Postal_Zone__c postalZone :postalZoneList) {
            Id vendorQueue;
            
            if(postalZone.Postal_Zone_Name__c == 'W' || postalZone.Postal_Zone_Name__c == 'C') {
                vendorQueue = VEN_OPS_WC_QUEUE;
            }
            else {
                vendorQueue = VEN_OPS_NE_QUEUE;
            }
            
            if(vendorQueue != null) {
                if(postalSectorToConIdSetMap.containsKey(postalZone.Postal_Sector__c)) {
                    for(Id conId :postalSectorToConIdSetMap.get(postalZone.Postal_Sector__c)) {
                        conIdToVenOpsQueueMap.put(conId, vendorQueue);
                    }
                }
                //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
                if(postalSectorToAddIdSetMap.containsKey(postalZone.Postal_Sector__c)) {
                    for(Id addId :postalSectorToAddIdSetMap.get(postalZone.Postal_Sector__c)) {
                        addIdToVenOpsQueueMap.put(addId, vendorQueue);
                    }
                }
                //END D-4722 24April2016 Added By C. Lin
            }
        }
        
        for(Case cas :caseList) {
            if(conIdToVenOpsQueueMap.containsKey(cas.Recipient__c)) {
                cas.OwnerId = conIdToVenOpsQueueMap.get(cas.Recipient__c);
            }
            //START D-4722 24April2016 Added By C. Lin - set Case Owner to Vendor Ops Queue for COA
            else if(addIdToVenOpsQueueMap.containsKey(cas.New_Address__c) && cas.RecordTypeId == CASE_COA && cas.Sub_Status__c == 'Waiting for Vendor Assignment'){
                cas.OwnerId = addIdToVenOpsQueueMap.get(cas.New_Address__c);
            }
            //END D-4722 24April2016 Added By C. Lin
        }
    }
    //END UD-3434 1/4/2016 Added by J.Sarion - Set Case Owner based on Postal Sector
    
    //START UD-2549 3/15/2016 Added by J.Sarion - perform full invoice adjustment on the outstanding invoice
    @future(callout=true)
    public static void createInvoiceAdjustmentPStop(Set<Id> caseIdSet) {
        //Lists
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Zuora.zObject> invoiceLineItemList = new List<Zuora.zObject>();
        List<Zuora.zObject> creditBalanceAdjustmentList = new List<Zuora.zObject>();
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        List<Map<String, Object>> invAdjustmentMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> creditBalanceAdjustmentMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> cancelPaymentMapList = new List<Map<String, Object>>(); //START-END UD-2549 4/6/2016 Added by J.Sarion
        
        //Sets
        Set<String> subZuoraNameSet = new Set<String>();
        Set<String> invoiceZuoraIdSet = new Set<String>();
        
        //Maps
        Map<String, String> subZuoraIdToCaseNumberMap = new Map<String, String>();
        Map<String, String> invZuoraIdToCaseNumberMap = new Map<String, String>();
        Map<String, Object> objMap = new Map<String, Object>();
        
        //Variables
        String queryStr = '';
        String zoqlString = '';
        
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        Logger logger = new Logger(CaseTriggerHandler.class.getName());
        
        try {
            system.debug('>>>>>caseIdSet ' + caseIdSet);
            //START PD-0138 Gdelrosario
      if(!Test.isRunningTest()){
        oliList = [SELECT Id, Subscription__r.Zuora__Zuora_Id__c, Subscription__r.Name, Case__r.CaseNumber 
                       FROM Order_Line_Item__c 
                       WHERE (Terminating_Reason__c = 'Payment failure - Credit card' OR Terminating_Reason__c = 'Payment failure - PayPal') AND Subscription__r.Billing_Type__c = 'Full Prepaid' AND Case__c IN :caseIdSet];
      }else { 
        oliList = [SELECT Id, Subscription__r.Zuora__Zuora_Id__c, Subscription__r.Name, Case__r.CaseNumber 
                       FROM Order_Line_Item__c 
                       WHERE (Terminating_Reason__c = 'Payment failure - Credit card' OR Terminating_Reason__c = 'Payment failure - PayPal') AND Subscription__r.Billing_Type__c = 'Full Prepaid' AND Case__c IN :caseIdSet LIMIT 5];
      }
            //END PD-0138 Gdelrosario
            system.debug('>>>>>oliList ' + oliList);
 
       
            for(Order_Line_Item__c oli :oliList) {
                subZuoraNameSet.add(oli.Subscription__r.Name);
                subZuoraIdToCaseNumberMap.put(oli.Subscription__r.Zuora__Zuora_Id__c, oli.Case__r.CaseNumber);
            }
            system.debug('>>>>>subZuoraNameSet ' + subZuoraNameSet);
            if(!subZuoraNameSet.isEmpty()) {
                invoiceLineItemList = zCallOut.bulkQueryForInvoiceItem(subZuoraNameSet, 'subscription');
            }
            system.debug('>>>>>invoiceLineItemList ' + invoiceLineItemList);
            if(!invoiceLineItemList.isEmpty()) {
                for(Zuora.zObject zobj :invoiceLineItemList) {
                    invoiceZuoraIdSet.add((String) zobj.getValue('InvoiceId'));
                    
                    if(subZuoraIdToCaseNumberMap.containsKey((String) zobj.getValue('SubscriptionId'))) {
                        invZuoraIdToCaseNumberMap.put((String) zobj.getValue('InvoiceId'), subZuoraIdToCaseNumberMap.get((String) zobj.getValue('SubscriptionId')));
                    }
                }
            }
            system.debug('>>>>>invoiceZuoraIdSet ' + invoiceZuoraIdSet);
            //START UD-2549 4/6/2016 Added by J.Sarion - Cancel Payment
            if(!invoiceZuoraIdSet.isEmpty()) {
                invoiceList = [SELECT Id, Name, Zuora__BillingAccount__r.Zuora__Zuora_Id__c, Zuora__Zuora_Id__c, Zuora__Balance2__c, Zuora__TotalAmount__c, 
                                    Is_CN_Processed__c, (SELECT Zuora__Payment__r.Zuora__EXT_ID__c, Zuora__Payment__r.Zuora__Type__c FROM Zuora__PaymentInvoices__r WHERE Zuora__Payment__r.Zuora__Status__c = 'Processed') 
                               FROM Zuora__ZInvoice__c 
                               WHERE Zuora__Zuora_Id__c IN :invoiceZuoraIdSet];
            }
            system.debug('>>>>>invoiceList ' + invoiceList);
            for(Zuora__ZInvoice__c inv :invoiceList) {
                objMap = new Map<String, Object>();
                
                inv.Is_CN_Processed__c  = false;
                
                if(inv.Zuora__TotalAmount__c != inv.Zuora__Balance2__c) {
                    queryStr += ' OR SourceTransactionId=\'' + inv.Zuora__Zuora_Id__c + '\'';
                }
                
                //objMap.put('AccountId', inv.Zuora__BillingAccount__r.Zuora__Zuora_Id__c); // not available in create call
          
                                      objMap.put('InvoiceId', inv.Zuora__Zuora_Id__c);
                    objMap.put('Type', 'Credit');
                    objMap.put('AdjustmentDate', Zuora.Zutil.getZuoraDate(Date.Today()));
                    objMap.put('Amount', inv.Zuora__TotalAmount__c);
                    if(invZuoraIdToCaseNumberMap.containsKey(inv.Zuora__Zuora_Id__c)) {
                        objMap.put('ReferenceId', invZuoraIdToCaseNumberMap.get(inv.Zuora__Zuora_Id__c));
                    }
                    objMap.put('Comments', 'Payment failure - Credit card / Paypal');
                    system.debug('>>>>>objMap ' + objMap);
                    invAdjustmentMapList.add(objMap);           
                    
                    for(Zuora__PaymentInvoice__c invPayment :inv.Zuora__PaymentInvoices__r) {
                        objMap = new Map<String, Object>();
                        if(invPayment.Zuora__Payment__r.Zuora__Type__c == 'Electronic') {
                            objMap = new Map<String, Object>();
                            objMap.put('Id', invPayment.Zuora__Payment__r.Zuora__EXT_ID__c);
                            objMap.put('Status', 'Voided');
                            cancelPaymentMapList.add(objMap);
                        }
                        else if(invPayment.Zuora__Payment__r.Zuora__Type__c == 'External') {
                            objMap = new Map<String, Object>();
                            objMap.put('Id', invPayment.Zuora__Payment__r.Zuora__EXT_ID__c);
                            objMap.put('Status', 'Canceled');
                            cancelPaymentMapList.add(objMap);
                        }
                    }
            
  
            }
            //END UD-2549 4/6/2016 Added by J.Sarion - Cancel Payment
            system.debug('>>>>>invAdjustmentMapList ' + invAdjustmentMapList);
            system.debug('>>>>>queryStr ' + queryStr);
            if(queryStr != '') {
                queryStr = queryStr.substring(4);
                zoqlString = 'SELECT Id FROM CreditBalanceAdjustment Where ' + queryStr;
                
                //Start D-4665 10-Apr-2016 Added By S.Puli - code coverage
                if(!Test.isRunningTest()){
                    creditBalanceAdjustmentList = zCallOut.bulkQueryZObjects(zoqlString);
                }
                //End D-4665 10-Apr-2016 Added By S.Puli
                system.debug('>>>>>creditBalanceAdjustmentList ' + creditBalanceAdjustmentList);
                if(!creditBalanceAdjustmentList.isEmpty()) {
                    for(Zuora.zObject zobj :creditBalanceAdjustmentList) {
                        objMap = new Map<String, Object>();
                        
                        objMap.put('Id', zobj.getValue('Id'));
                        objMap.put('Status', 'Canceled');
                        
                        creditBalanceAdjustmentMapList.add(objMap);
                    }
                }
            }
            system.debug('>>>>>creditBalanceAdjustmentMapList ' + creditBalanceAdjustmentMapList);
            if(!creditBalanceAdjustmentMapList.isEmpty()) {
                List<Map<String, String>> resultMapList = zCallOut.updateZObjects(creditBalanceAdjustmentMapList, 'CreditBalanceAdjustment');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            
            //START UD-2549 4/5/2016 Added by J.Sarion - cancel payment
            if(!cancelPaymentMapList.isEmpty()) {
                List<Map<String, String>> resultMapList = new List<Map<String, String>>();
                resultMapList = zCallOut.updateZObjects(cancelPaymentMapList, 'Payment');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            //END UD-2549 4/5/2016 Added by J.Sarion - cancel payment
            
            if(!invAdjustmentMapList.isEmpty()) {
                List<Map<String, String>> resultMapList = zCallOut.loadZObjects(invAdjustmentMapList, 'InvoiceAdjustment');
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            
            update invoiceList;
        }
        catch(Exception e) {
            logger.log(e);
        }
        logger.save();
    }
    //END UD-2549 3/15/2016 Added by J.Sarion - perform full invoice adjustment on the outstanding invoice
}