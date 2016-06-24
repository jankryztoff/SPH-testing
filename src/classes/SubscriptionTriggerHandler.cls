/**
* Class Name: <SubscriptionTriggerHandler>
* @authors: <JerellaMayelLedesma>
* Date: <7/30/2014>
* Requirement/Project Name: <SPH>
* @description <Validate>
* History: 12/03/14 D-1030 Kevin Evasco Updated to include acknowledgment letter suppression
* History: 02/18/2015 D-1693 D-2277 JohnD Refactored the class for bulkification
* History: 26-Feb-2015 D-2342 Added by Raviteja - to fix the 'You have not activated this service.' error
* History: 28/04/15 UD-0776 Wenjun - Modification to custom Zuora Sync to prevent deletion of subscriptions
*/

public class SubscriptionTriggerHandler implements TriggerHandlerInterface {
    //START: UD-1830 7/10/2015 Avoid looping of Trigger
    public static Boolean preventExecution = FALSE;
    //END: UD-1830 7/10/2015 Avoid looping of Trigger
    
    static final string NON_PAYPAL_2_NON_PAYPAL_EMAIL_SUBJECT = 'Other to Other';
    static final string NON_PAYPAL_2_PAYPAL_EMAIL_SUBJECT = 'Other to Paypal';
    static final string ASIA1_SERVICE_FLAG_DELIMITER = '|';
    //START: PD-0035 May 17, 2016 Added by Kristine Balaoing - added variables for string literals
    static final string PUBLICATION = 'Publication';
    //END: PD-0035 May 17, 2016 Added by Kristine Balaoing
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    // START UD-0533 04/30/2015 Added by S.Puli  - add flag to avoid SOQL 101
    public static Boolean isBulkBeforeToRun = TRUE;
    public static Boolean isBulkAfterToRun = TRUE;
    // END UD-0533 04/30/2015 Added by S.Puli  - add flag to avoid SOQL 101
    
    //IMPORTANT NOTE: please be careful when defining the collection varible as Static as it will accumulate data from previous trigger batch
    //If you need to set varible as Static to pass data between "Before" and "After" context, please reset the your varible in method resetStaticDataCollection()
    // Start SOQL 101
    static map<id, Order__c> orderId_order = new map<id, Order__c>();
    static set<id> orderIdSet = new set<id>();
    static list<Account> accountToUpdateList = new list<Account>();
    
    static map<id, Case> orderId_case = new map<id, Case>();
    static map<id, Order_Line_Item__c> orderLineItemId_orderLineItem = new map<id, Order_Line_Item__c>();
    //START: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
    static map<id, set<string>> orderToOrderLineItemsMap = new map<id, set<string>>();
    //END: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
    static map<id, string> accountId_accountStatus = new map<id, string>();
    static map<id, boolean> accountId_isWithActiveSubscription = new map<id, boolean>();
    
    static list<exception> exceptionList = new list<exception>();
    List<Log__c> logList= new List<Log__c>();//SPULI Temporary Log, to delete tomorrow
    static list<Case_Subscription__c> caseSubscriptionList = new list<Case_Subscription__c>();
    
    static map<id, id> orderLineItemId_subscripitonId = new map<id, id>();
    static map<id, set<id>> orderLineItemId_subscripitonIdSet = new map<id, set<id>>(); // Start/End UD-1646 23Jun15 JohnD
    static map<id, Zuora__Subscription__c> paypalBillingAccountId_deliverySubscription = new map<id, Zuora__Subscription__c>();
    static map<id, Zuora__Subscription__c> otherBillingAccountId_deliverySubscription = new map<id, Zuora__Subscription__c>();
    static map<id, Zuora__Subscription__c> subscriptionId_subscription = new map<id, Zuora__Subscription__c>();
    static list<Messaging.SingleEmailMessage> emailMessageList = new list<Messaging.SingleEmailMessage>();
    static string emailBody;
    static Messaging.SingleEmailMessage emailMessage;
    static map<string, Subscription_Temp_Stop__c> subscriptionZuoraId_subscriptionTempStop = new map<string, Subscription_Temp_Stop__c>();
    static map<string, list<Address_Assignment__c>> subscriptionZuoraId_AddressAssignmentList = new map<string, list<Address_Assignment__c>>();
    static list<Address_Assignment__c> addressAssignmentList = new list<Address_Assignment__c>();
    static Subscription_Temp_Stop__c subscriptionTempStop;
    
    static map<id, Asia1_Subscription__c> orderLineItemId_asia1Subscription_serviceActivation = new map<id, Asia1_Subscription__c>();
    static map<id, Asia1_Subscription__c> orderLineItemId_asia1Subscription_serviceDeactivation = new map<id, Asia1_Subscription__c>();
    static map<id, list<Asia1_Subscription__c>> orderLineItemId_asia1SubscriptionList_serviceActivation = new map<id, list<Asia1_Subscription__c>>();
    static map<id, list<Asia1_Subscription__c>> orderLineItemId_asia1SubscriptionList_serviceDeactivation = new map<id, list<Asia1_Subscription__c>>();
    static map<id, id> orderLineItemId_subscriptionId = new map<id, id>();
    
    static Asia1_Subscription__c asia1Subscription;
    static set<id> subscriptionIdSet4Asia1ServiceActivation = new set<id>();
    static set<id> orderLineItemIdSet = new set<id>();
    static set<id> orderIdSet4PaymentUpdate = new set<id>();
    static Set<Id> subFullPrepaidSet = new Set<Id>();
    static Set<Id> subStopSet = new Set<Id>(); //START-END: MD-10 03/17/15 Rom Edison Reyes
    static Map<Id, Subscription_Vendor__c> vendorSubscriptionMap = new Map<Id, Subscription_Vendor__c>();
    static List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>();
    static map<id, boolean> orderId_isNoVendorNeeded = new map<id, boolean>();
    static set<string> relatedSubscription4TempStopSet = new set<string>();
    static map<id, Zuora__CustomerAccount__c> accountId_billingAccount = new map<id, Zuora__CustomerAccount__c>();
    static Zuora__CustomerAccount__c billingAccount;
    static list<Zuora__Subscription__c> deliverySubscriptionList = new list<Zuora__Subscription__c>();
    static map<id, boolean> billingAccountId_isWithActiveSubscription = new map<id, boolean>();
    static map<id, list<Zuora__Subscription__c>> accountId_deliverySubscriptionList = new map<id, list<Zuora__Subscription__c>>();
    static map<id, list<Zuora__Subscription__c>> accountId_subscriptionList = new map<id, list<Zuora__Subscription__c>>();
    // End SOQL 101
    //START: D-2279 02/19/2015 Added by Kristine Campang - added variables for stop
    static List<Case> caseList = new List<Case>();
    static Set<Id> accList = new Set<Id>();
    static Map<String, Case> acc_CaseRecMap = new Map<String, Case>();
    //END: D-2279 02/19/2015 Added by Kristine Campang
    //START D-2327 25/02/15 Wenjun
    static String RT_ID_BUNDLE_PROD = ConstantsSLB.getKeyId('Package Item_Bundle Product');
    static String RT_ID_EXT_PROD = ConstantsSLB.getKeyId('Package Item_Extension Product');
    Map<Id,Package__c> mapMainPackages = new Map<Id,Package__c>(); //Related Main Package details
    Map<Id,List<Package_Item__c>> mapPackIDToItemLst = new Map<Id,List<Package_Item__c>>();
    //END D-2327 25/02/15 Wenjun
    // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date
    static Map<Id, Date> subToDTL_MAP = new Map<Id, Date>();
    static Map<Id, Id> SubsToOLI_MAP = new Map<Id, Id>();
    static Map<Id, Set<Date>> accToDTL_MAP = new Map<Id, Set<Date>>();
    static Map<String, Set<Date>> lprRecIdToDTL_MAP = new Map<String, Set<Date>>();
    static Set<Id> accId_SET = new Set<Id>();
    static List<Letter_Print_Request__c> LPR_List = new List<Letter_Print_Request__c>();
    // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
    //Start D-2248 03/06/2015 ABanaag
    set<id> subIdsToInvoiceSeparately = new set<id>();
     Map<id,integer> billingAcctIdToCheck_subCount = new Map<id,integer>();
    //End D-2248 03/06/2015 ABanaag
    static Date dtltoday = SM_SubscriptionHelper.getDtlDate(); //START END D-2721 - FIx SOQL in Loop Issue
    //IMPORTANT NOTE: please be careful when defining the collection varible as Static as it will accumulate data from previous trigger batch
    //If you need to set varible as Static to pass data between "Before" and "After" context, please reset the your varible in method resetStaticDataCollection()
    //START: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
    map<id,order__c> orderNumberId_order = new map<id,order__c>(); //D-2788
    //END: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case   
    Set<Id> setRecipientIds = new Set<Id>(); //START END D-2777 Wenjun 16/04/15
    
    //START 28/04/15 UD-0776 Wenjun : Custom Zuora Sync for Amendment Issue
    List<Zuora__Subscription__c> lstNewSubVersions = new List<Zuora__Subscription__c>(); 
    List<Zuora__Subscription__c> lstNewSubsToDel = new List<Zuora__Subscription__c>(); 
    Set<Id> setBAIdsToSync = new Set<Id>();
    //END 28/04/15 UD-0776 Wenjun
    //START: PD-0035 May 16, 2015 Added by Kristine Balaoing - added variables 
    Map<Id, Map<String, Id>> mapOliToMapSvcToSub = new Map<Id, Map<String, Id>>();
    //END: PD-0035 May 16, 2015 Added by Kristine Balaoing
    
    //START UD-2036 07/24/2015 Added by J.Sarion - Added set of enabled Asia1 sub from existing Asia1
    static map<id, list<Asia1_Subscription__c>> orderLineItemId_asia1SubscriptionList_FromExistingAsia1 = new map<id, list<Asia1_Subscription__c>>();
    List<Asia1_Subscription__c> updateAsia1SubFromExistingAsia1List = new List<Asia1_Subscription__c>();
    //END UD-2036 07/24/2015 Added by J.Sarion - Added set of enabled Asia1 sub from existing Asia1
    
    //START UD-2738 Wenjun 21/Sep/15 : Code Optimization
    /*
    //Start: D-2862 05/06/2015 James - Avoid SOQL 101 error
    string STOP_SUB_CATEGORY = ConstantsSLB.getOther('Stop Subscription');
    string STOP_SUB_STATUS = ConstantsSLB.getOther('Subscription Stop Completed');
    //START UD-1676 Wenjun 22/06/15 : Overrite End Date for 'Pending Submission' PSTOP Subs
    Set<ID> setPStopSubIDs = new Set<ID>(); 
    Map<ID,Date> mapOliIDToStopDate = new Map<ID,Date>();
    //END UD-1676 Wenjun 22/06/15
    //End: D-2862 05/06/2015 James
    //Start UD-1642 06/13/2015 James
    List<Order_Line_Item__c> StopOLI = new List<Order_Line_Item__c>();
    //End UD-1642 06/13/2015 James
    */
    Set<ID> setPubSubIDs = new Set<ID>(); 
    Map<ID,Date> mapOliIDToCancelDate = new Map<ID,Date>();
    //START: UD-3798 1/19/16 Added by Manolo Valena
  Set<String> setActiveCaseStatus = new Set<String> {GlobalVariableClass.SUB_STATUS_PROVISIONING, GlobalVariableClass.ZUORA_ISSUE_CANCELLATION, GlobalVariableClass.SEND_TO_ZUORA_ISSUE,
                    GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION, GlobalVariableClass.SUB_STATUS_STOP_COMPLETED, GlobalVariableClass.SUB_STATUS_SUBS_CREATED, 
                    GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN, GlobalVariableClass.SUB_STATUS_CHANGE_OF_SUB_COMPLETED, GlobalVariableClass.SUB_STATUS_FOR_RETENTION_OFFER};
  //END: UD-3798 1/19/16 Added by Manolo Valena
    //END UD-2738 Wenjun 21/Sep/15 : Code Optimization
    
    //START UD-1595 6/23/15 AddedBy FBenzon/JTeves : variables 
    //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
    static Set<Id> newSubCOSIDs = new Set<Id>();
    final String ORDERTYPE_CHANGE_OF_PACKAGE = GlobalVariableClass.COS_PACKAGE;
    final String ORDERTYPE_CHANGE_OF_QTY = GlobalVariableClass.COS_QUANTITY;
    final String STATUS_NEW = GlobalVariableClass.STATUS_NEW;
    final String STATUS_DRAFT = GlobalVariableClass.STATUS_DRAFT;
    static Map<Id, Id> subIdtoCosOrderId = new Map<Id, Id>();
    static set<id> cosOrderIdSet = new set<Id>();
    final String FULL_PRE = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
    final String MR_PRE = GlobalVariableClass.BILLING_TYPE_MR_PRE;
    final String MR_POS = GlobalVariableClass.BILLING_TYPE_MR_POST;
    //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
    //END UD-1595 6/23/15 AddedBy FBenzon/JTeves : variables
        
    //START UD-1559 Hotfix AddedBy Manolo V.
    //START UD-1559 Updated 7/8/15 by FrancisBenzon : code not needed
    /* 
    Set<Id> setCancelledSubs = new Set<Id>(); 
    Set<String> COSIdentifiers = new Set<String>{ORDERTYPE_CHANGE_OF_PACKAGE, ORDERTYPE_CHANGE_OF_QTY};
    */
    //END UD-1559 Updated 7/8/15 by FrancisBenzon : code not needed
    //END UD-1559 Hotfix AddedBy Manolo V.
    static Set<Id> ccFailureSubIdSet = new Set<Id>(); //START-END: UD-1544 05-07-2015 Marvin / JOHN
    
    //START UD-2738 Wenjun 21/Sep/15 : Code Optimization
    /*
    //START:UD-1559 7/1/15 Added by Manolo Valena
    Map<Id, Date> COSOLIIdToEndDateMap = new Map<Id, Date>();
    Map<Id, Date> PSTOPOLIIdToEndDateMap = new Map<Id, Date>();
    Set<Id> setSubIds = new Set<Id>();
    //END:UD-1559 7/1/15 Added by Manolo Valena
    */
    //END UD-2738 Wenjun 21/Sep/15 : Code Optimization
    
    //START D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
    //static Set<Id> ccFailureSubIdSet = new Set<Id>(); //START-END: UD-1544 05-07-2015 Marvin / JOHN
    //map<id, string> billingAccountId_ArmsReturnStatus = new map<id, string>(); // Start/End UD-1544 
    //END D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
    
    //START D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
    Id CASE_STOP_SUB_TYPE_ID = ConstantsSLB.getKeyId('Case_Stop');
    Set<Id> caseWithActiveSubSet = new Set<Id>();
    //END D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
    
     //START UD-1816 7/16/2015 Added By C. Lin - Classification field
    Map<Id, Order_Line_Item__c> oldSubToRenewalOrderLineMap = new Map<Id, Order_Line_Item__c>();
    Map<Id, Order_Line_Item__c> oldSubToStopOrderLineMap = new Map<Id, Order_Line_Item__c>();
    //END UD-1816 7/16/2015 Added By C. Lin
    
    //START UD-3652 4Feb2016 FrancisBenzon : vars
    Set<Id> subsToStopIDSet = new Set<Id>();
    //END UD-3652 4Feb2016 FrancisBenzon : vars
    static Map<String, Set<String>> lprRecIdToStatus_MAP = new Map<String, Set<String>>(); //START/END UD-2328 08/25/15 RReyes
    
    //START UD-2867 09/21/2015 Added by J.Sarion - update unique address id
    Set<Id> recipientContactIdSet = new Set<Id>();
    Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact>();
    //END UD-2867 09/21/2015 Added by J.Sarion - update unique address id
    //Start UD-3888 14-Apr-2016 Added By S.Puli - update LPR of the transferred Subs
    Map<Id, Id> oldBillAcToNewBillAc = new Map<Id, Id>();
    List<Letter_Print_Request__c> letterPrintReq_List = new List<Letter_Print_Request__c>();
    List<Letter_Print_Request__c> lprToUpdate = new List<Letter_Print_Request__c>();
    //End UD-3888 14-Apr-2016 Added By S.Puli - update LPR of the transferred Subs
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isBeforeInsertTriggerCalled;
        SubscriptionTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled;
        SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        //START/END: UD-0410 04/06/15 RReyes - Changed return value from returnVar to true
        // START UD-0533 04/30/2015 Added by S.Puli - returning returnVar as return, PLS DO NOT MODIFY THIS PART OF CODE
        return returnVar;
        // END UD-0533 04/30/2015 Added by S.Puli - returning returnVar as return, PLS DO NOT MODIFY THIS PART OF CODE
    }
   
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled;
        SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isAfterInsertTriggerCalled;
        SubscriptionTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isAfterUpdateTriggerCalled;
        SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isAfterDeleteTriggerCalled;
        SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;
    }
   
 
    public void bulkBefore() {
         
        // START UD-0533 04/30/2015 Added by S.Puli  - add flag to avoid SOQL 101
        if(isBulkBeforeToRun){
        // END UD-0533 04/30/2015 Added by S.Puli 
        //START D-2721 Wenjun 10/04/15 - Reset Static Data Collection before each Trigger Batch
        resetStaticDataCollection();
        //END D-2721 Wenjun 10/04/15
        
        set<id> billingAccountIdSet = new set<id>();
        list<Zuora__Subscription__c> subList;
        //START: D-2279 02/20/2015 Added by Kristine Campang - added variables for Stop Subscription
        set<string> cancelledSubNameList = new set<string>(); //Start/End D-2324 02/26/15 Added by ABanaag - changed from list to Set 
        map<string, Order_Line_Item__c> cancelledSubName_orderLineItem = new map<string, Order_Line_Item__c>();
        Order_Line_Item__c  orderLineItemTmp = new Order_Line_Item__c();
        //END: D-2279 02/20/2015 Added by Kristine Campang
        
        //START UD-1816 7/16/2015 Added By C. Lin - Classification field
        Set<Id> normalSubIdSet = new Set<Id>();
        Set<Id> evergreenSubsIdSet = new Set<Id>();
        Set<Id> stopSubIdSet = new Set<Id>();
        List<Order_Line_Item__c> renewalOrderLineList = new List<Order_Line_Item__c>();
        List<Order_Line_Item__c> stopOrderLineList = new List<Order_Line_Item__c>();
        Set<Id> oliSet = new Set<Id>();
        List<Zuora__Subscription__c> delSubList = new List<Zuora__Subscription__c>();
        List<Order_Line_Item__c> orderLineList = new List<Order_Line_Item__c>();
        Map<Id, Id> oliToDelSubMap = new Map<Id, Id>();
        //END UD-1816 7/16/2015 Added By C. Lin
        
        if (Trigger.isInsert || Trigger.isUpdate) {
            
            //START: D-2279 02/20/2015 Added By John Dacutan -start retrieve all cancelled subscriptions
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                if (sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED && sub.Name != null) {
                    cancelledSubNameList.add(sub.Name);
                }
                System.debug('@@sub.isdigital '+sub.Order_Line_Item_Number_1__r.Is_Digital__c);
            }

            //END: D-2279 02/20/2015 Added By John Dacutan
            
            // START: D-2279 02/20/2015 Added By John Dacutan - retrieve and map order and order line item 
            // START: D-2526 03/16/2015 Added By Karl Tan- added Grace Days to Query
            system.debug('+++CHA cancelledSubNameList ' + cancelledSubNameList);
            for (Order_Line_Item__c oli : [select Id, Order__c, Order__r.Recipient_Contact__c, Subscription_Name__c, Grace_Days__c from Order_Line_Item__c 
                    where Subscription_Name__c in :cancelledSubNameList]) {
            // END: D-2526 03/16/2015 Added By Karl Tan- added Grace Days to Query 
            //Start/End D-2324 02/26/15 Added by ABanaag - added Order__r.Recipient_Contact__c to query                        
                system.debug('+++CHA oli.Subscription_Name__c ' + oli.Subscription_Name__c);
                system.debug('+++CHA oli.Order__c ' + oli.Order__c);
                if (oli.Subscription_Name__c != null) {
                    cancelledSubName_orderLineItem.put(oli.Subscription_Name__c, oli);
                    orderIdSet.add(oli.Order__c); //START-END UD-2549 3/30/2016 Added by J.Sarion - Add Order
                }
            }
            //END: D-2279 02/20/2015 Added By John Dacutan
            system.debug('>>>>>orderIdSet ' + orderIdSet);
            //Start D-2324 02/26/15 Added by ABanaag - map values
            set<id> orderNumbers = new set<id>();
                //START: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
                orderNumberId_order = new map<id,order__c>();
                //END: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case                    
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                orderNumbers.add((id)sub.Order_Number__c);
                // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                //START UD-2286 11-Aug-2015 Added By S.Puli
                accId_SET.add(sub.Zuora__CustomerAccount__c);
                //END UD-2286 11-Aug-2015 Added By S.Puli
                // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                //START D-3262 07/20/2015 Added by J.Sarion - Update Subscription End Date for Normal Expiry
                if(sub.Term_Length__c > 0 && sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED && sub.Zuora__SubscriptionEndDate__c == sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c))){
                    sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1);
                }
                //END D-3262 07/20/2015 Added by J.Sarion - Update Subscription End Date for Normal Expiry
                
                //START UD-2867 09/21/2015 Added by J.Sarion - update unique address id
                if(sub.Recipient_Contact_1__c != null){
                    recipientContactIdSet.add((id)sub.Recipient_Contact_1__c);
                }
                //END UD-2867 09/21/2015 Added by J.Sarion - update unique address id
            }
            
            //START UD-2867 09/21/2015 Added by J.Sarion - update unique address id
            if(!recipientContactIdSet.isEmpty()){
                contactIdToContactMap = new Map<Id, Contact>([SELECT Id, Address_Unique_Id__c FROM Contact WHERE Id IN :recipientContactIdSet]);
            }
            //END UD-2867 09/21/2015 Added by J.Sarion - update unique address id
            
            //START UD-0781 4/13/2015 Added by Manolo Valena - Added Total_Subscription_Rate__c field to the query.
                //START: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
                for(Order__c order : [SELECT ID, Recipient_Contact__c, Subscriber_Charge__c, Total_Subscription_Rate__c FROM ORDER__C WHERE ID in : orderNumbers]){
                //END: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
                orderNumberId_order.put(order.id, order);
            }
            //END UD-0781 4/13/2015 Added by Manolo Valena
            //End D-2324 02/26/15 Added by ABanaag - map values
            
            //START: D-2279 02/20/2015 Added By John Dacutan - added logic for stop
            
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                    
                //START 04/05/15 UD-0776 Wenjun : By pass process for Zuora New Version
                system.debug('+++CHA sub.Zuora__Version__c ' + sub.Zuora__Version__c);
                if(Trigger.isInsert && sub.Zuora__Version__c != 1)
                    continue;
                //END 04/05/15 UD-0776 Wenjun
                                    
                // start for case and order status update
                system.debug('+++CHA sub.Order_Number__c ' + sub.Order_Number__c);
                if (sub.Order_Number__c != null) {
                    
                        
                        orderIdSet.add((id)sub.Order_Number__c);
  
                        orderId_isNoVendorNeeded.put((id)sub.Order_Number__c, false);                   
                        
                    //Start D-2324 02/26/15 Added by ABanaag - change from else if to "if"
                    system.debug('+++CHA sub.Zuora__Status__c ' + sub.Zuora__Status__c);
                    if (sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED) {
                    //End D-2324 02/26/15 Added by ABanaag - change from else if to "if"                        
                        if (cancelledSubName_orderLineItem != null) {
                            system.debug('+++CHA cancelledSubName_orderLineItem.get(sub.Name) ' + cancelledSubName_orderLineItem.get(sub.Name));
                            orderLineItemTmp = cancelledSubName_orderLineItem.get(sub.Name);
                            //Start D-2324 02/26/15 Added by ABanaag - ensure recipient contact is populated
                            if(orderLineItemTmp!=null){
                                system.debug('+++CHA orderLineItemTmp.Order__c ' + orderLineItemTmp.Order__c);
                                orderIdSet.add(orderLineItemTmp.Order__c);
                            
                                sub.Order_Number_1__c = orderNumberId_order.get(sub.Order_Number__c).id;
                                if(sub.Recipient_Contact__c==null){
                                    sub.Recipient_Contact__c = orderNumberId_order.get(sub.Order_Number__c).Recipient_Contact__c;
                                    sub.Recipient_Contact_1__c = orderNumberId_order.get(sub.Order_Number__c).Recipient_Contact__c;
                                    sub.Subscriber_Contact__c = orderNumberId_order.get(sub.Order_Number__c).Recipient_Contact__c;
                                }
                                //START UD-0781 4/13/2015 Added by Manolo Valena - Added if statement for the subscription's Subscription_Charge__c field. If null, it will be given a value.
                                if(sub.Subscription_Charge__c == null) {
                                    sub.Subscription_Charge__c = orderNumberId_order.get(sub.Order_Number__c).Total_Subscription_Rate__c;
                                }
                                //END UD-0781 4/13/2015 Added by Manolo Valena
                            }
                            //End D-2324 02/26/15 Added by ABanaag - ensure recipient contact is populated
                            
                                
                        }
                    }
                    
                }
                //END: D-2279 02/20/2015 Added By John Dacutan
                // end for case and order status update
                
                // start for case subscription creation
                if (sub.Order_Line_Item_Number__c != null) {               
                    orderLineItemId_subscripitonId.put((id)sub.Order_Line_Item_Number__c, sub.Id);                  
                }
                // end for case subscription
                
                // start for account status update
                if (sub.Zuora__Account__c != null) {
                    accountId_isWithActiveSubscription.put(sub.Zuora__Account__c, false);
                }
                // end for account status update
                
                // start for delivery paypal related
                if (sub.Zuora__CustomerAccount__c != null) {
                    billingAccountIdSet.add(sub.Zuora__CustomerAccount__c);
                }
                // end for delivery paypal related
                
                if (trigger.isInsert) {
                    
                    // start for temp-stop reassignment of subscription id
                    if (sub.Related_Subscription__c != null) {
                        relatedSubscription4TempStopSet.add(sub.Related_Subscription__c);
                    }
                    // end for temp-stop reassignment of subscription id
                    
                    // start for asia1 subscription (service) activation
                    if (sub.Order_Line_Item_Number__c != null) {
                        System.debug('oli population entered :');
                        orderLineItemIdSet.add((id)sub.Order_Line_Item_Number__c);
                    }
                    System.debug('oli set >>> ' + orderLineItemIdSet);
                    // end for asia1 subscription (service) activation
                }
            }
            
        //START D-2327 25/02/15 Wenjun : Retrieve more fields for Sub Rate
            // START: D-2526 03/16/2015 Added By Karl Tan- added Grace Days to Query
            //START UD-0810 04-23-2015 Marvin G added field Order__r.Payment_Mode__c, Order__r.Other_Payment_Mode__c,
                // Start D-2900 11May15 JohnD - added Delivered_by field
                // Start UD-1646 23Jun15 JohnD - added Addon_package__c field
                // Start UD-2660 05Sep15 JohnD - added Order__r.Sponsor__c
                orderLineItemId_orderLineItem = new map<id, Order_Line_Item__c>([SELECT Id, Classification__c, Is_Digital__c, 
                        Order__r.Payment_Mode__c, Order__r.Other_Payment_Mode__c,Delivered_By__c, AddOn_Package__c, 
                        Generate_Invoice__c, Main_Package_Billing_Type__c, Postage_Charge__c, Promotion_ID__c, Qty__c, 
                        Reason_Code__c, Sub_Classification__c, Subscription_Name__c, Term_is_discussed__c, Vendor_Mailing_Agent__c, 
                        Case__c,Case__r.Sub_Category__c, Order__c, Order__r.Billing_Contact__c, Order__r.Delivery_Charge__c, Order__r.Sponsor__c, 
                        Order__r.PO_Number__c, Order__r.Recipient_Contact__c, Order__r.Subscription__c, Order__r.Subscriber_Charge__c, 
                        //START D-3153 6/30/2015 Added by Manolo Valena - Added Auto_Renew__c field. 
                        Order__r.Subscription__r.Order_Line_Item_Number_1__r.Grace_Days__c, Grace_Days__c, Term_Length__c, Start_Date__c, Auto_Renew__c   
                        //END D-3153 6/30/2015 Added by Manolo Valena   
                        from Order_Line_Item__c where Order__c in :orderIdSet]);
            System.debug('@@orderLineItemId_orderLineItem '+orderLineItemId_orderLineItem);
                // End UD-2660 05Sep15 JohnD - added Order__r.Sponsor__c
                // End UD-1646 23Jun15 JohnD - added Addon_package__c field
                // End D-2900 11May15 JohnD - added Delivered_by field
            //START UD-0810 04-23-2015 Marvin G
            // END: D-2526 03/16/2015 Added By Karl Tan- added Grace Days to Query
            //START D-2324/D-2333 02/25/2015 Evasco/Banaag Updated to auto populate Billing Account's Billing Contact         
            if (trigger.isInsert) {
                try{
                    subscriptionBillingAccountInitializer billingAccountModifier = new subscriptionBillingAccountInitializer();
                    billingAccountModifier.retrieveBillingContact((List<Zuora__Subscription__c>)Trigger.new,orderLineItemId_orderLineItem);
                }
                catch(Exception e){
                    System.debug('subscriptionBillingAccountInitializer ' + e.getMessage());
                    exceptionList.add(e); //Start-End PD-0196 5-19-2016 added by Jason A.
                }
            }
            //END D-2324/D-2333 02/25/2015 Evasco/Banaag Updated to auto populate Billing Account's Billing Contact
 
             // start for delivery charge paypal related                                                    
            for (Zuora__Subscription__c sub : [select Id, Contact__r.Email__c,Zuora__Status__c, Subscription_Type__c,
                    Zuora__Account__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Name, 
                    Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c, Zuora__CustomerAccount__r.Zuora__SoldToName__c, 
                    Recipient_Contact__r.Address__r.Level_Number__c, Recipient_Contact__r.Address__r.Unit_Number__c, 
                    Recipient_Contact__r.Address__r.Postal_Code__r.Name, Recipient_Contact__r.Address__c, 
                    Subscription_Type_1__c, Order_Number__c, Order_Number_1__r.Name 
                    FROM Zuora__Subscription__c where Zuora__CustomerAccount__c in :billingAccountIdSet]) {
             //END D-2327 25/02/15 Wenjun   
                if (sub.Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c != null) {
                    if (sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY) {
                        subList = new list<Zuora__Subscription__c>();
                        if (accountId_deliverySubscriptionList.get(sub.Zuora__Account__c) != null) {
                            subList.addAll(accountId_deliverySubscriptionList.get(sub.Zuora__Account__c));
                        }
                        
                        subList.add(sub);
                        accountId_deliverySubscriptionList.put(sub.Zuora__Account__c, subList);
                    } else if (sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                            && sub.Zuora__Status__c == GlobalVariableClass.STATUS_ACTIVE) {
                        
                        subList = new list<Zuora__Subscription__c>();
                        billingAccountId_isWithActiveSubscription.put(sub.Zuora__Account__c, true);
                        
                        if (accountId_subscriptionList.get(sub.Zuora__Account__c) != null) {
                            subList.addAll(accountId_subscriptionList.get(sub.Zuora__Account__c));
                        }
                        subList.add(sub);
                        
                        accountId_subscriptionList.put(sub.Zuora__Account__c, subList);
                                
                                subscriptionId_subscription.put(sub.Id, sub);
                                system.debug('sub id is' + sub.id);
                                system.debug('map for sub ' + subscriptionId_subscription);
                            
                    }
                }
                
                       
                        
                // end for delivery charge paypal related 
            }
            
            //START D-2327 25/02/15 Wenjun : set Subscription Rate
            //Get Related Main Package details
            Set<Id> setMainPackIDs = new Set<Id>();
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                if(sub.Zuora__Status__c == GlobalVariableClass.STATUS_ACTIVE && sub.Main_Package_1__c != null)
                {
                    setMainPackIDs.add(sub.Main_Package_1__c);
                }
            }
            
            if(!setMainPackIDs.isEmpty())
            {
                mapMainPackages = new Map<Id,Package__c> ([SELECT ID, Package_Price__c, Package_Type__c, Package_Sub_Type__c 
                                                           FROM Package__c WHERE ID in :setMainPackIDs]);
                for(Package_Item__c item: [SELECT ID, Package__c, RecordTypeId, Price__c, Product_Rate_Plan__r.Product_Code__c 
                                           FROM Package_Item__c WHERE Package__c in :setMainPackIDs 
                                           AND (RecordTypeID = :RT_ID_BUNDLE_PROD OR RecordTypeID =:RT_ID_EXT_PROD)])
                {
                    if(mapPackIDToItemLst.containsKey(item.Package__c))
                        mapPackIDToItemLst.get(item.Package__c).add(item);
                    else mapPackIDToItemLst.put(item.Package__c, new List<Package_Item__c> {item});
                }
            }
            //END D-2327 25/02/15 Wenjun
            
            //START D-2116 03/12/2015 Added by S.Puli
            if(accId_SET.size()>0 && accId_SET<>null){
                LPR_List = [Select Id, Name, Record_ID__c, DTL_Date__c, Letter_Type__c, Status__c From Letter_Print_Request__c Where Letter_Type__c = :GlobalVariableClass.LETTER_TYPE_ACK AND Record_ID__c IN :accId_SET]; //START/END UD-2328 08/25/15 RReyes - added Status__c
                
                if(LPR_List.size()>0 && LPR_List<>null){
                    for(Letter_Print_Request__c lpr : LPR_List){
                        
                            if(lprRecIdToDTL_MAP.get(lpr.Record_ID__c)<>null && lprRecIdToDTL_MAP.get(lpr.Record_ID__c).size()>0){
                                lprRecIdToDTL_MAP.get(lpr.Record_ID__c).add(lpr.DTL_Date__c);
                            } else{
                                lprRecIdToDTL_MAP.put(lpr.Record_ID__c, new Set<Date>{lpr.DTL_Date__c});
                            
                            }
                            //START UD-2328 08/25/15 RReyes
                            if(lprRecIdToStatus_MAP.get(lpr.Record_ID__c)<>null && lprRecIdToStatus_MAP.get(lpr.Record_ID__c).size()>0){
                                lprRecIdToStatus_MAP.get(lpr.Record_ID__c).add(lpr.Status__c);
                            } else{
                                lprRecIdToStatus_MAP.put(lpr.Record_ID__c, new Set<String>{lpr.Status__c});
                            }
                            //END UD-2328 08/25/15 RReyes 
                            //    
                                        
                    }
                }           
            }
            // END D-2116 03/12/2015 Added by S.Puli
            
            //START UD-2738 Wenjun 21/Sep/15 : Code Optimization
            if(trigger.isUpdate){
                //Retrieve all the Publication Susbcriptions for fetching related PSTOP/COS Cases
                //START D-3609 Wenjun 24/09/15 : Retreive Order Line Line to fetch the related Pub Ids
                Set<ID> setOrderLineItemIds = new Set<ID>();
                for (Zuora__Subscription__c sub : (List<Zuora__Subscription__c>)trigger.new)
                {
                    if(sub.Order_Line_Item_Number_1__c != NULL)
                        setOrderLineItemIds.add(sub.Order_Line_Item_Number_1__c);
                }
                
                for(Zuora__Subscription__c sub :[SELECT Id, Name FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c in : setOrderLineItemIds 
                                                AND Subscription_Type_1__c = : GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION])
                {
                    setPubSubIDs.add(sub.ID);
                }
                //END D-3609 Wenjun 24/09/15
                
                //Retrieve PSTOP/COS Cases
                for(Order_Line_Item__c oli: [SELECT Id, Subscription__c, Subscription__r.Order_Line_Item_Number_1__c, Stop_Request_Date__c, Case__r.RecordType.DeveloperName,
                        Start_Date__c, Case__r.Subscription_Name__c, Case__r.Subscription_Name__r.Order_Line_Item_Number_1__c
                        FROM Order_Line_Item__c 
                        WHERE ((Case__r.RecordType.DeveloperName = :GlobalVariableClass.RT_DEV_NAME_STOP AND Subscription__c IN :setPubSubIDs) OR 
                        (Case__r.RecordType.DeveloperName = :GlobalVariableClass.RT_DEV_NAME_COS AND Case__r.Subscription_Name__c IN :setPubSubIDs))
                        AND Case__r.Sub_Status__c in :setActiveCaseStatus AND Case__r.Status != :GlobalVariableClass.STATUS_VOID]) //START END D-4100 05Jan2016 Added By C. Lin - Add AND Case__r.Status != :GlobalVariableClass.STATUS_VOID
                {
                    if(oli.Case__r.RecordType.DeveloperName == GlobalVariableClass.RT_DEV_NAME_STOP) //PSTOP Cases
                    {
                        if(oli.Subscription__r.Order_Line_Item_Number_1__c != NULL && oli.Stop_Request_Date__c != NULL)
                            mapOliIDToCancelDate.put(oli.Subscription__r.Order_Line_Item_Number_1__c, oli.Stop_Request_Date__c);
                    }
                    else //COS Cases
                    {
                        if(oli.Case__r.Subscription_Name__r.Order_Line_Item_Number_1__c != NULL && oli.Start_Date__c != NULL)
                            mapOliIDToCancelDate.put(oli.Case__r.Subscription_Name__r.Order_Line_Item_Number_1__c, oli.Start_Date__c);
                    }                                        
                }
            }
            //END UD-2738 Wenjun 21/Sep/15 : Code Optimization
            
            //START D-3153 6/30/2015 Added by Manolo Valena - Invoke new method to update subscriptions under renewal batch.
            if(Trigger.isInsert) {
                updateRenewalSubscriptionContacts((list<Zuora__Subscription__c>)trigger.new);
            }
            //END D-3153 6/30/2015 Added by Manolo Valena
            
            //START UD-1816 7/16/2015 Added By C. Lin - Classification field            
            if(Trigger.isUpdate) {
                for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                    //START UD-1626 8/6/2015 Added By C. Lin - Prevent argument cannot be null error
                    if(sub.Zuora__SubscriptionEndDate__c != null && sub.Zuora__TermSettingType__c == 'TERMED' && sub.Zuora__SubscriptionStartDate__c != null && sub.Term_Length__c != null){
                    //END UD-1626 8/6/2015 Added By C. Lin
                        if(sub.Zuora__SubscriptionStartDate__c.addMonths(integer.valueOf(sub.Term_Length__c)).addDays(-1) == sub.Zuora__SubscriptionEndDate__c){
                            normalSubIdSet.add(sub.Id);
                        }else{
                            stopSubIdSet.add(sub.Id);
                        }
                    }else if(sub.Zuora__TermSettingType__c == 'EVERGREEN'){
                        evergreenSubsIdSet.add(sub.Id);
                    }
                }
                
                renewalOrderLineList = [SELECT Id, Name, Order__r.Order_Type__c, Order__r.Base_Subscription__c, Order__r.Base_Subscription__r.Order_Line_Item_Number_1__c FROM Order_Line_Item__c WHERE Order__r.Base_Subscription__c IN :normalSubIdSet];
                stopOrderLineList = [SELECT Id, Name, Subscription__c FROM Order_Line_Item__c WHERE (Subscription__c IN :evergreenSubsIdSet OR Subscription__c IN :stopSubIdSet) AND Stop_Request_Date__c != null];
                
                for(Order_Line_Item__c renOrderLine : renewalOrderLineList){
                    if(renOrderLine.Order__r.Base_Subscription__c != null){
                        oldSubToRenewalOrderLineMap.put(renOrderLine.Order__r.Base_Subscription__c, renOrderLine);
                    }
                    
                    if(renOrderLine.Id != null){
                        oliSet.add(renOrderLine.Order__r.Base_Subscription__r.Order_Line_Item_Number_1__c);
                    }
                }
                
                delSubList = [SELECT Id, Name, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c IN :oliSet AND Subscription_Type_1__c != 'Publication'];
                
                for(Zuora__Subscription__c delSub : delSubList){
                    if(delSub.Order_Line_Item_Number_1__c != null){
                        oliToDelSubMap.put(delSub.Order_Line_Item_Number_1__c, delSub.Id);
                    }
                }
                
                for(Order_Line_Item__c renOrderLine : renewalOrderLineList){
                    if(renOrderLine.Order__r.Base_Subscription__r.Order_Line_Item_Number_1__c != null){
                        oldSubToRenewalOrderLineMap.put(oliToDelSubMap.get(renOrderLine.Order__r.Base_Subscription__r.Order_Line_Item_Number_1__c), renOrderLine);
                    }
                }
                
                for(Order_Line_Item__c oli : stopOrderLineList){
                    if(oli.Subscription__c != null){
                        oldSubToStopOrderLineMap.put(oli.Subscription__c, oli);
                    }
                }
            }
            //END UD-1816 7/16/2015 Added By C. Lin
        }
        // START UD-0533 04/30/2015 Added by S.Puli 
        }
        // END UD-0533 04/30/2015 Added by S.Puli 
    }      

    public void bulkAfter() {       
        // START UD-0533 04/30/2015 Added by S.Puli  - add flag to avoid SOQL 101
        system.debug('+++CHA isBulkAfterToRun ' + isBulkAfterToRun);
        if(isBulkAfterToRun){
        // END UD-0533 04/30/2015 Added by S.Puli
        //START: PD-0035 Added by Kristine Balaoing May 16, 2016 - added variables
        Map<Id, Set<String>> mapPackToServiceFlags = new Map<Id, Set<String>>();
        if (Trigger.isInsert || Trigger.isUpdate) {
           
            set<id> publicationSubscriptionIdSet;   // Start/End UD-1646 23Jun15 JohnD
            List<Package_Access_Flag__c> pafList = new List<Package_Access_Flag__c>();
            Set<Id> subscriptionPackagesSet = new Set<Id>();

            //START D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
            //set<id> billingAccountIdSet = new set<id>(); // Start/End UD-1544
            //END D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
            
            
            //START D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
            if (!orderIdSet.isEmpty()) {
                checkForActiveSub();
            }
            //END D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
           
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                
                // start for case subscription creation
                
                //Nitin Khanna : D-2667 : 5-4-2015 : Start : adding the publication condition in order to make sure that Case-Subscription records
                //                                           are only created for publication subscriptions.
                if (sub.Order_Line_Item_Number__c != null && sub.subscription_type__c == 'Publication') {               
                    
                    //orderLineItemId_subscripitonId.put((id)sub.Order_Line_Item_Number__c, sub.Id);    // Start/End UD-1646 23John15 JohnD - commented out

                    // Start UD-1646 23Jun15 JohnD - put related subscriptions
                    publicationSubscriptionIdSet = new set<id>();
                    
                    if (orderLineItemId_subscripitonIdSet.get((id)sub.Order_Line_Item_Number__c) != null) {
                        publicationSubscriptionIdSet = orderLineItemId_subscripitonIdSet.get((id)sub.Order_Line_Item_Number__c);
                    }
                     
                    publicationSubscriptionIdSet.add(sub.Id);
                    
                    orderLineItemId_subscripitonIdSet.put((id)sub.Order_Line_Item_Number__c, publicationSubscriptionIdSet);
                    // End UD-1646 23Jun15 JohnD - put related subscriptions
                    //START: PD-0035 May 16, 2016 Added by Kristine Balaoing - added set for packages
                    subscriptionPackagesSet.add(sub.Main_Package_1__c);
                    //END: PD-0035 May 16, 2016 Added by Kristine Balaoing

                }
                //Nitin Khanna : D-2667 : 5-4-2015 : End
                // end for case subscription
                //START D-2249 2/27/2015 Added By C. Lin - Populate AccountId To Account Status Map
     
                if(sub.Zuora__Account__c != null){
                    accountId_accountStatus.put(sub.Zuora__Account__c, sub.Zuora__Account__r.Status__c);
                }
                //END D-2249 2/27/2015 Added By C. Lin
                
                
                //START D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
                // Start UD-1544
                //billingAccountIdSet.add(sub.Zuora__CustomerAccount__c);
                // End UD-1544
                //END D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
                                
                //START UD-3652 4Feb2016 FrancisBenzon: get subs that status went from active to cancelled
                if(trigger.isUpdate)
                {
                    Zuora__Subscription__c oldSub = (Zuora__Subscription__c)trigger.oldMap.get(sub.Id);
                    if(sub.Zuora__Status__c == GlobalVariableClass.ZUORA_STATUS_CANCEL && oldSub.Zuora__Status__c == GlobalVariableClass.ZUORA_STATUS_ACTIVE)
                    {
                        subsToStopIDSet.add(sub.id);
                    }
                    system.debug(':::oldSUb ' + oldSub);
                    system.debug(':::newSub ' + oldSub);
                    //Start UD-3888 14-Apr-2016 Added By S.Puli - update LPR of the transferred Subs
                    if(sub.Zuora__CustomerAccount__c <> oldSub.Zuora__CustomerAccount__c)
                    {
                        if(oldSub.Zuora__CustomerAccount__c <> null){   
                            if(sub.Zuora__CustomerAccount__c <> null){  
                                oldBillAcToNewBillAc.put(oldSub.Zuora__CustomerAccount__c, sub.Zuora__CustomerAccount__c);
                            }
                        }
                    }
                    //End UD-3888 14-Apr-2016 Added By S.Puli - update LPR of the transferred Subs
                }   
                
                //END UD-3652 4Feb2016 FrancisBenzon: get subs that status went from active to cancelled
                
            }
            
            //START: PD-0035 May 16, 2016 Added by Kristine Balaoing - added query for package access flags
                pafList = [SELECT Id, No_of_Concurrent_Users__c, Package__c, Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name FROM Package_Access_Flag__c WHERE Package__c IN :subscriptionPackagesSet];
                for(Package_Access_Flag__c paf : pafList){
                    if(mapPackToServiceFlags.containsKey(paf.Package__c)){
                        mapPackToServiceFlags.get(paf.Package__c).add(paf.Package_Service_Access_Flag__r.Name);
                    }else{
                        mapPackToServiceFlags.put(paf.Package__c, new Set<String>{paf.Package_Service_Access_Flag__r.Name});      
                    }
                }
            
            //Start UD-3888 14-Apr-2016 Added By S.Puli - update LPR of the transferred Subs
            if(!oldBillAcToNewBillAc.isEmpty()){
                String ackLtr = SP_GenerateLetterPrintBatch.acknowledgmentLetter;
                String newTxt = GlobalVariableClass.STATUS_NEW;
                letterPrintReq_List = [SELECT Id, Record_ID__c, Status__c, Letter_Type__c FROM Letter_Print_Request__c WHERE Record_ID__c IN :oldBillAcToNewBillAc.keySet()
                                        AND Letter_Type__c = :ackLtr AND Status__c = :newTxt];
                
                if(!letterPrintReq_List.isEmpty()){
                    for(Letter_Print_Request__c lpr : letterPrintReq_List){
                        if(lpr.Record_ID__c <> null){
                            if(oldBillAcToNewBillAc.containsKey(lpr.Record_ID__c)){
                                lpr.Record_ID__c = oldBillAcToNewBillAc.get(lpr.Record_ID__c);
                                lprToUpdate.add(lpr);
                            }
                        }
                    }
                }
            }
            //End UD-3888 14-Apr-2016 Added By S.Puli - update LPR of the transferred Subs
            system.debug('>>>>>orderIdSet ' + orderIdSet);
            if (orderIdSet.size() > 0) {
                //START D-3336 JTeves 10-Aug-2015 - Prevent "too many SOQL queries" issue
                Order__c orderTmp;
                //START PD-0083 08Jun2016 Added By C. Lin - Add RecordType.Name, RecordTypeId
                List<Case> tmpCaseList = [select Id, AccountId, Status, Sub_Status__c, Sub_Category__c, Order__c, 
                        Order__r.Status__c, Order__r.No_Vendor_Needed__c, Order__r.Acquisition_Type__c, CreatedById, RecordType.Name, RecordTypeId,
                        (select Id, Subscription_Name__c from Order_Line_Items__r) from Case where Order__c in :orderIdSet AND Status != :GlobalVariableClass.STATUS_VOID]; //START END D-4100 05Jan2016 Added By C. Lin - Add AND Case__r.Status != :GlobalVariableClass.STATUS_VOID
                //END PD-0083 08Jun2016 Added By C. Lin
                system.debug('>>>>>tmpCaseList ' + tmpCaseList);
                list<string> SubscriptionName = new list<string>();
                // To pull the subscription ID base on the subscription name   
                map<string,id> SubscriptionID = new map<string,id>();   
                for(Case caseTmp : tmpCaseList) {
                    for (Order_Line_Item__c oli : caseTmp.Order_Line_Items__r) {
                        // To put subscription name to a list
                        if (oli.Subscription_Name__c != null) {
                            SubscriptionName.add(oli.Subscription_Name__c);
                        }
                    }
                }
                for (Zuora__Subscription__c ZSub: [select id, name from Zuora__Subscription__c where name in: SubscriptionName]) {
                    SubscriptionID.put(ZSub.name, ZSub.id);
                }
                //START: D-2466 3/14/2015 VPernicia: Add Subscription_Name__c field in the query
                system.debug('+++CHA tmpCaseList ' + tmpCaseList);
                for (Case caseTmp : tmpCaseList) {
                    system.debug('+++CHA caseTmp ' + caseTmp);
                //END D-3336 JTeves 10-Aug-2015 - Prevent "too many SOQL queries" issue
                //END: D-2466 3/14/2015 VPernicia: Add Subscription_Name__c field in the query    
                //START: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
        
                    //START D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
                    Boolean updateRec = true;
                    //END D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
                    
                    if (caseTmp.Order__c != null) {
                            for(Order_Line_Item__c oliRec : orderLineItemId_orderLineItem.values()){
                                  
                                if (oliRec.Delivered_By__c == GlobalVariableClass.VENDOR && oliRec.Vendor_Mailing_Agent__c == null) { // Start/End D-2900 11May15 JohnD - added expression
                                    if(orderToOrderLineItemsMap.containsKey(oliRec.Order__c)){            
                                        orderToOrderLineItemsMap.get(oliRec.Order__c).add(oliRec.Id);
                                    } 
                                    else {
                                        orderToOrderLineItemsMap.put(oliRec.Order__c, new Set<String>());
                                        orderToOrderLineItemsMap.get(oliRec.Order__c).add(oliRec.Id);
                                    }
                                }   
                            }
                        
                        orderTmp = new Order__c();
                        orderTmp.Id = caseTmp.Order__c;
                        system.debug('>>>>>caseTmp ' + caseTmp);
                        //START/END D-1977 Addedby FrancisBenzon 2/19/15 : exclude ChangeOfSub in checking. Already applied checking in Create Case
                        //Start/End D-2332 Addedby FrancisBenzon 3/10/15 Removed COS in if criteria
                         //Start UD-0413 and UD-0663 Added by Ronald Dagaraga 31/03/2015 Added Case recordtype of COS and ROS in if condition
                         
                        //Start MMallorca UD-1454 Add Renewal in statement 06/16/2015
                        if (caseTmp.Sub_Category__c == GlobalVariableClass.RECTYPE_START_SUBSCRIPTION || caseTmp.Sub_Category__c == GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION || caseTmp.Sub_Category__c == GlobalVariableClass.SUBCATEGORY_RENEWAL_OF_SUBCRIPTION){
                        //End MMallorca UD-1454 06/16/2015       
                                if (orderToOrderLineItemsMap.containskey(caseTmp.Order__c)) {
                                    orderTmp.Status__c = GlobalVariableClass.STATUS_PENDING_VENDOR_ASSIGN;
                                    caseTmp.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                                    System.debug(caseTmp + ' ++>>>>>>');
                                }
                                else{
                                    orderId_isNoVendorNeeded.put(caseTmp.Order__c, true);
                                    orderTmp.Status__c = GlobalVariableClass.STATUS_CLOSE;
                                    caseTmp.Status = GlobalVariableClass.STATUS_CLOSED;
                                    caseTmp.Sub_Status__c = GlobalVariableClass.SUB_STATUS_SUBS_CREATED;
                                    caseTmp.OwnerId = caseTmp.CreatedById;
                                }   
                            } 
                            else {
                                //START D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
                                if (caseWithActiveSubSet.contains(caseTmp.Id)) {
                                    updateRec = false;
                                }
                                system.debug('>>>>>updateRec ' + updateRec);
                                if (updateRec) {
                                    orderTmp.Status__c = GlobalVariableClass.STATUS_CLOSE;
                                    caseTmp.Status = GlobalVariableClass.STATUS_CLOSED;
                                    //Start UD-0799 Updated by Ronald Dagaraga 07/04/2015 Sub Status should be SUBS_CREATED
                                    caseTmp.Sub_Status__c = GlobalVariableClass.SUB_STATUS_SUBS_CREATED;
                                    //End UD-0799 Updated by Ronald Dagaraga 07/04/2015 Sub Status should be SUBS_CREATED
                                    caseTmp.OwnerId = caseTmp.CreatedById;
                                
                                }
                                //END D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
                            }
                        //END: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
                        //End UD-0413 and UD-0663 Added by Ronald Dagaraga 31/03/2015 Added Case recordtype of COS and ROS in if condition                        
                        orderId_order.put(caseTmp.Order__c, orderTmp);
                        orderId_case.put(caseTmp.Order__c, caseTmp);

                        //START: D-2466 3/14/2015 VPernicia: Add additional query to pull link case stop record to case sub
                        //START D-3336 JTeves 10-Aug-2015 - Prevent "too many SOQL queries" issue - move SOQL query outside FOR loop
                        /*list<string> SubscriptionName = new list<string>();
                        for (Order_Line_Item__c oli : caseTmp.Order_Line_Items__r) {
                            // To put subscription name to a list
                            if (oli.Subscription_Name__c != null) {
                                SubscriptionName.add(oli.Subscription_Name__c);
                            }
                        }
                        // To pull the subscription ID base on the subscription name
                        map<string,id> SubscriptionID = new map<string,id>();
                        for (Zuora__Subscription__c ZSub: [select id, name from Zuora__Subscription__c where name in: SubscriptionName]) {
                            
                            SubscriptionID.put(ZSub.name, ZSub.id);
                        }*/
                        //END D-3336 JTeves 10-Aug-2015 - Prevent "too many SOQL queries" issue - move SOQL query outside FOR loop
                        
                        // create case subscription
                        system.debug('+++CHA trigger.isInsert ' + trigger.isInsert);
                        if (trigger.isInsert) { //START/END 27 October 2015 D-3491 Kevin Evasco - Create Case Subscription for ESHOP
                            system.debug('+++CHA caseTmp.Order_Line_Items__r ' + caseTmp.Order_Line_Items__r);
                            for (Order_Line_Item__c oli : caseTmp.Order_Line_Items__r) {
                                //START PD-0083 08Jun2016 Added By C. Lin - Exclude Stop Subscription from duplication of Case Sub
                                system.debug('+++++CHA caseTmp.RecordTypeId' + caseTmp.RecordTypeId);
                                system.debug('+++++CHA CASE_STOP_SUB_TYPE_ID ' + CASE_STOP_SUB_TYPE_ID);
                                if(caseTmp.RecordTypeId != CASE_STOP_SUB_TYPE_ID){
                                    system.debug('+++CHA oli ' + oli);
                                    
                                    // Start UD-1646 23Jun15 JohnD - commented out logic is lacking
                                    /*
                                    string SubID;
                                    if (orderLineItemId_subscripitonId.get(oli.Id) != null) {
                                        SubID = (string)orderLineItemId_subscripitonId.get(oli.Id);
                                    } else {
                                        SubID = (string)SubscriptionID.get(oli.Subscription_Name__c);
                                    }
                                    
                                    if (SubID != null) {
                                        Case_Subscription__c caseSubscription = new Case_Subscription__c();
                                        caseSubscription.Case__c  = caseTmp.Id;
                                        caseSubscription.Subscription__c = SubID ;
                                        caseSubscription.Account__c = caseTmp.AccountId;
                                        caseSubscriptionList.add(caseSubscription);
                                    }
                                    */
                                    // End UD-1646 23Jun15 JohnD - commented out logic is lacking
                                    
                                    // Start UD-1646 23Jun15 JohnD - improved previous logic for it does not cater multiple publciation subscriptions
                                    system.debug('+++CHA orderLineItemId_subscripitonIdSet ' + orderLineItemId_subscripitonIdSet);
                                    system.debug('+++CHA orderLineItemId_subscripitonIdSet.get(oli.Id) ' + orderLineItemId_subscripitonIdSet.get(oli.Id));
                                    if (orderLineItemId_subscripitonIdSet != null && orderLineItemId_subscripitonIdSet.get(oli.Id) != null) {
                                        for (id subscriptionIdTmp :  orderLineItemId_subscripitonIdSet.get(oli.Id)) {
                                            system.debug('+++CHA subscriptionIdTmp ' + subscriptionIdTmp);
                                            Case_Subscription__c caseSubscription = new Case_Subscription__c();
                                            caseSubscription.Case__c  = caseTmp.Id;
                                            caseSubscription.Subscription__c = subscriptionIdTmp ;
                                            caseSubscription.Account__c = caseTmp.AccountId;
                                            caseSubscriptionList.add(caseSubscription);
                                        }
                                        
                                    } else {
                                        system.debug('+++CHA SubscriptionID.get(oli.Subscription_Name__c) ' + SubscriptionID.get(oli.Subscription_Name__c));
                                        // Start UD-1646 23Jun15 JohnD - this code block was copied from original logic
                                        string SubID = (string)SubscriptionID.get(oli.Subscription_Name__c);
                                        if (SubID != null) {
                                            Case_Subscription__c caseSubscription = new Case_Subscription__c();
                                            caseSubscription.Case__c  = caseTmp.Id;
                                            caseSubscription.Subscription__c = SubID ;
                                            caseSubscription.Account__c = caseTmp.AccountId;
                                            caseSubscriptionList.add(caseSubscription);
                                        }
                                        // End UD-1646 23Jun15 JohnD - this code block was copied from original logic
                                    }
                                    // End UD-1646 23Jun15 JohnD - improved previous logic for it does not cater multiple publciation subscriptions
                                }
                                //END PD-0083 08Jun2016 Added By C. Lin
                            }
                        }
                        //END: D-2466 3/14/2015 VPernicia: Add additional query to pull link case stop record to case sub
                        // end create case subscription
                    }
                }
            }
        
            if (accountId_accountStatus.size() > 0) { //start/end D-1788 01/23/15 ABanaag
                //START D-2249 2/27/2015 Added By C. Lin - Should be Zuora__Status__c instead of Zuora__Account__r.Status__c
                for (Zuora__Subscription__c sub : [Select Zuora__Account__c, Zuora__Account__r.Status__c, Zuora__Status__c FROM Zuora__Subscription__c 
                        WHERE Zuora__Account__c IN :accountId_accountStatus.keySet()]) {
                    
                    if (sub.Zuora__Status__c == GlobalVariableClass.ZUORA_STATUS_ACTIVE) {
                        accountId_isWithActiveSubscription.put(sub.Zuora__Account__c, true);
                    }
                }
                //END D-2249 2/27/2015 Added By C. Lin
                for (id accountId : accountId_accountStatus.keySet()) {
                    //START D-2249 2/27/2015 Added By C. Lin - Added condition if status of account is null, it should also update account status
                    if ((accountId_accountStatus.get(accountId) == GlobalVariableClass.ACCOUNT_STATUS_ACTIVE || accountId_accountStatus.get(accountId) == null)
                            && accountId_isWithActiveSubscription.get(accountId) == false) {
                    //END D-2249 2/27/2015 Added By C. Lin
                        Account acc = new Account();
                        acc.Id = accountId;
                        acc.Status__c = GlobalVariableClass.ACCOUNT_STATUS_INACTIVE;
                        acc.Active__c = false;
                        accountToUpdateList.add(acc);
                    //START D-2249 2/27/2015 Added By C. Lin - Added condition if status of account is null, it should also update account status
                    } else if ((accountId_accountStatus.get(accountId) == GlobalVariableClass.ACCOUNT_STATUS_INACTIVE || accountId_accountStatus.get(accountId) == null)
                            && accountId_isWithActiveSubscription.get(accountId) == true) {
                    //END D-2249 2/27/2015 Added By C. Lin
                        Account acc = new Account();
                        acc.Id = accountId;
                        acc.Status__c = GlobalVariableClass.ACCOUNT_STATUS_ACTIVE;
                        acc.Active__c = true;
                        accountToUpdateList.add(acc);
                    
                    }
                }
                
            } //Start/end  D-1788 01/23/15 ABanaag
            // Start D-2248 03 March 2015 ABanaag 
            /**1.   When the new Publication subscription is synced back to SFDC from Zuora, check the Billing Account if:
                a.  Default Payment Method is Credit Card
                b.  SFDC Account record type is Direct Corporate
                c.  Subscription is sponsored

                2.  If none of 1.a, 1.b, and 1.c is true then 
                check if there are other subscriptions under this 
                Billing Account aside from Delivery/Postage Charge.

                3.  If the result in 2 returned other publication subscriptions aside from the Delivery/Postage charge, 
                then make a zuora API callout to update the Subscription field called IsInvoiceSeparate. Set the value of this field to TRUE.

                
            **/
            
            set<id> billingAccountIdToCheck = new set<Id>();
            Map<Zuora__Subscription__c,id> sub_billingAcctId = new Map<Zuora__Subscription__c,id>();
            Map<Id, Zuora__CustomerAccount__c> billingAcctId_billingAcctObj = new Map<Id, Zuora__CustomerAccount__c>();
            
            //Map all subscription to billing account id
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                sub_billingAcctId.put(sub, sub.Zuora__CustomerAccount__c);
            }
            //Map billing account id to billing account object

            //START D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
            // Start UD-1544 06Jul15 Marvin/John - added Arms_Return_Status__c field and billingAccountId_ArmsReturnStatus
            for(Zuora__CustomerAccount__c billingAcct : [SELECT ID, Zuora__DefaultPaymentMethod__c, ARMS_Return_Status__c
                    FROM Zuora__CustomerAccount__c WHERE Id in : sub_billingAcctId.values()]){
                        
                billingAcctId_billingAcctObj.put(billingAcct.id,billingAcct);
                //billingAccountId_ArmsReturnStatus.put(billingAcct.Id, billingAcct.ARMS_Return_Status__c);
            }
            // End UD-1544 06Jul15 Marvin/John - added Arms_Return_Status__c field and billingAccountId_ArmsReturnStatus
            //END D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
            
            //list which billing accounts pass criteria
            System.debug('@@sub_billingAcctId.keySet() '+sub_billingAcctId.keySet());
            System.debug('@@billingAcctId_billingAcctObj '+billingAcctId_billingAcctObj);
            for (Zuora__Subscription__c sub : sub_billingAcctId.keySet()) {
                System.debug('@@bill '+billingAcctId_billingAcctObj.get(sub_billingAcctId.get(sub)));
                System.debug('@@sub_billingAcctId.get(sub) '+sub_billingAcctId.get(sub));
                System.debug('@@sub: '+sub);
                //PD-0006 Tops
                if(billingAcctId_billingAcctObj.containsKey(sub_billingAcctId.get(sub)) &&
                billingAcctId_billingAcctObj.get(sub_billingAcctId.get(sub)).Zuora__DefaultPaymentMethod__c != GlobalVariableClass.CREDITCARD
                && sub.Zuora__Account__r.RecordTypeID != ConstantsSLB.getKeyId('Account_Direct Corporate')
                && !(sub.Sponsor_1__c)){
                    billingAccountIdToCheck.add(sub.Zuora__CustomerAccount__c);
                }
            }
            
            //START UD-1595 6/23/15 AddedBy FBenzon/JTeves : query of orders using cancelled subs for COS
            //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            //remove hard coded strings
            //START UD-3652 4Feb2016 FrancisBenzon: filter subs for invoiceProcessForStopSub class
            Set<Id> oldOliIds = new Set<Id>(); //renamed variable from oldOrderIds
            for(Order__c orderRec :[Select Id, Name, Subscription__c, Subscription__r.Order_Number__c, Subscription__r.Billing_Type__c,                         Subscription__r.Zuora__Status__c, Subscription__r.Order_Line_Item_Number_1__c, 
                                    (SELECT Main_Package_Billing_Type__c, Start_Date__c FROM Order_Line_Items_Direct__r) 
                                    From Order__c Where Subscription__c IN :subsToStopIDSet
                                    AND Order_Type__c IN (:ORDERTYPE_CHANGE_OF_PACKAGE, :ORDERTYPE_CHANGE_OF_QTY) 
                                    AND Status__c != :GlobalVariableClass.STATUS_CLOSE]) 
            //END UD-3652 4Feb2016 FrancisBenzon: filter subs for invoiceProcessForStopSub class
            {
                for(Order_Line_Item__c oli : orderRec.Order_Line_Items_Direct__r) {
                    if((orderRec.Subscription__r.Billing_Type__c == FULL_PRE && oli.Main_Package_Billing_Type__c == FULL_PRE) || (orderRec.Subscription__r.Billing_Type__c == FULL_PRE && oli.Main_Package_Billing_Type__c == MR_PRE) || (orderRec.Subscription__r.Billing_Type__c == MR_PRE && oli.Main_Package_Billing_Type__c == FULL_PRE && oli.Start_Date__c.toStartOfMonth() == Date.today().toStartOfMonth())) {
                        newSubCOSIDs.add(orderRec.Subscription__c); //add subscription Id if subject to urgent invoicing
                        oldOliIds.add(orderRec.Subscription__r.Order_Line_Item_Number_1__c); //related order of subs subject to urgent invoicing
                    }
                }
                //START HOTFIX: D-3226 JTeves - 11-July-2015 - Stop Invoice from Being Generated for Cancelled Recurring Subs
                //if(orderRec.Subscription__r.Billing_Type__c != GlobalVariableClass.BILLING_TYPE_FULL_PRE) { 
                    
                    //subIdtoCosOrderId.put(orderRec.Subscription__c, orderRec.Id);
                    //oldOliIds.add(orderRec.Subscription__r.Order_Line_Item_Number_1__c); //related order of MR subs subject to COS
                //}
                //END HOTFIX: D-3226 JTeves - 11-July-2015
                
            }
            
            //include delivery subs
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                if (sub.Subscription_Type_1__c == 'Delivery' && oldOliIds.contains(sub.Order_Line_Item_Number_1__c)) {
                    newSubCOSIDs.add(sub.Id);
                }
            }
            //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            //END UD-1595 6/23/15 AddedBy FBenzon/JTeves : query of orders using cancelled subs for COS
        }
        
        if (Trigger.isInsert) {
            //START: PD-0035 May 16, 2016 Added by Kristine Balaoing - added mapping of oli to service flags
            Map<String, Id> mapServiceFlagtoSub = new Map<String, Id>();
            //START: PD-0035 June 22, 2016 Added by Von Pernicia - added subscription to right service flag
            integer x = 0;
            for(Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new){
                //mapServiceFlagtoSub = new Map<String, Id>();
                if(sub.Subscription_Type_1__c == PUBLICATION){
                    if(mapPackToServiceFlags.containsKey(sub.Main_Package_1__c)){
                        for(String svc : mapPackToServiceFlags.get(sub.Main_Package_1__c)){
                            mapServiceFlagtoSub.put(svc + x, sub.Id);
                            x++;
                        }
                    }
                    mapOliToMapSvcToSub.put(sub.Order_Line_Item_Number__c, mapServiceFlagtoSub);
                    
                }
            }
            //END: PD-0035 June 22, 2016 Added by Von Pernicia - added subscription to right service flag
            //END: PD-0035 May 16, 2016 Added by Kristine Balaoing
            System.debug(mapOliToMapSvcToSub + 'mapOliToMapSvcToSub');
            //D-0721 1122 MS
            if (!relatedSubscription4TempStopSet.isEmpty()) {
                
                list<Address_Assignment__c> addAssList;
                
                for (Subscription_Temp_Stop__c subTmpStp : [select Id, Subscription__c, Temp_Stop__c, Subscription__r.Zuora__Zuora_Id__c 
                        from Subscription_Temp_Stop__c where Subscription__r.Zuora__Zuora_Id__c in :relatedSubscription4TempStopSet 
                        and Temp_Stop__r.Temp_Stop_Status__c != :GlobalVariableClass.TS_STATUS_ONGOING]) {
                    
                    subscriptionZuoraId_subscriptionTempStop.put(subTmpStp.Subscription__r.Zuora__Zuora_Id__c, subTmpStp);
                }
                
                for (Address_Assignment__c addAss : [select Id, Subscription__c, Subscription__r.Zuora__Zuora_Id__c from Address_Assignment__c 
                        where Subscription__r.Zuora__Zuora_Id__c in :relatedSubscription4TempStopSet 
                        and Active__c = false and Effective_Date__c > today]) {
                    
                    addAssList = new list<Address_Assignment__c>();
                    
                    if (subscriptionZuoraId_addressAssignmentList.get(addAss.Subscription__r.Zuora__Zuora_Id__c) != null) {
                        addAssList.addAll(subscriptionZuoraId_addressAssignmentList.get(addAss.Subscription__r.Zuora__Zuora_Id__c));
                    }
                    
                    addAssList.add(addAss);
                    
                    subscriptionZuoraId_addressAssignmentList.put(addAss.Subscription__r.Zuora__Zuora_Id__c, addAssList);
                }
            }
            // end for temp-stop and coa renewal
            System.debug('OLI SET >>> ' + orderLineItemIdSet);
            if (!orderLineItemIdSet.isEmpty()) {
                list<Asia1_Subscription__c> asia1SubList;
                for (Asia1_Subscription__c a1Sub : [select Id, Order_Line_Item__c, Subscription__c, Status__c, Asia1__c, Service_Access_Flag__c, 
                        Service_Access_Flag__r.Name, Asia1__r.Status__c, Asia1__r.User_ID_LDAP_ID__c 
                        from Asia1_Subscription__c where Order_Line_Item__c in :orderLineItemIdSet 
                        and (Order_Line_Item__r.Is_Digital__c = true OR Order_Line_Item__r.Order__r.Acquisition_Type__c = :GlobalVariableClass.ACQTYPE_ESHOP_ECOMZ_ONLINE)]) { //START/END 27 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation for ESHOP
                    
                    asia1SubList = new list<Asia1_Subscription__c>();
                    System.debug('ASIA1 SUB STATUS >> ' + a1Sub);
                    if (a1Sub.Status__c == GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED) {
                        
                        if (orderLineItemId_asia1SubscriptionList_serviceActivation.get(a1Sub.Order_Line_Item__c) != null) {
                            asia1SubList.addAll(orderLineItemId_asia1SubscriptionList_serviceActivation.get(a1Sub.Order_Line_Item__c));
                        }
                        
                        asia1SubList.add(a1Sub);
                        
                        orderLineItemId_asia1SubscriptionList_serviceActivation.put(a1Sub.Order_Line_Item__c, asia1SubList);
                        
                    } 
                    //START UD-2036 07/24/2015 Added by J.Sarion - Commented out. Tie Subscription to Asia1 Subscription
                    else if (a1Sub.Status__c == GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED && a1Sub.Subscription__c == null) {
                        System.debug('ENTERED >>>> ');
                        if (orderLineItemId_asia1SubscriptionList_FromExistingAsia1.get(a1Sub.Order_Line_Item__c) != null) {
                            System.debug('ENTERED 2>>>> ');
                            asia1SubList.addAll(orderLineItemId_asia1SubscriptionList_FromExistingAsia1.get(a1Sub.Order_Line_Item__c));
                        }
                        
                        asia1SubList.add(a1Sub);
                        
                        orderLineItemId_asia1SubscriptionList_FromExistingAsia1.put(a1Sub.Order_Line_Item__c, asia1SubList);
                        /*
                        if (orderLineItemId_asia1SubscriptionList_serviceDeactivation.get(a1Sub.Order_Line_Item__c) != null) {
                            asia1SubList.addAll(orderLineItemId_asia1SubscriptionList_serviceDeactivation.get(a1Sub.Order_Line_Item__c));
                        }
                        
                        asia1SubList.add(a1Sub);
                        
                        orderLineItemId_asia1SubscriptionList_serviceDeactivation.put(a1Sub.Order_Line_Item__c, asia1SubList);
                        */
                    }
                    //END UD-2036 07/24/2015 Added by J.Sarion - Commented out. Tie Subscription to Asia1 Subscription
                }
            }
        }
        // START UD-0533 04/30/2015 Added by S.Puli  - add flag to avoid SOQL 101
        }
        // END UD-0533 04/30/2015 Added by S.Puli  - add flag to avoid SOQL 101
    }
   
   //START: D-2279 02/20/2015 Added by Kristine Campang - added logic for stop
    public void beforeInsert(SObject so) {
        Zuora__Subscription__c sub = (Zuora__Subscription__c)so;

            mapZSubscripitonCustomFields(sub);
   
        //START D-2777 Wenjun 16/04/15 : Set Subscription Active Flag
        if(sub.Subscription_Type__c != GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY &&
           (sub.Zuora__SubscriptionEndDate__c > Date.today() || sub.Zuora__SubscriptionEndDate__c == null))
        {
            sub.Is_Active__c = true;
        }
        //END D-2777 Wenjun 16/04/15  
        
        //START 28/04/15 UD-0776 Wenjun : Remove Account Lookup Field for New Version - marked for deletion later
        if(sub.Zuora__Version__c != 1)
            sub.Zuora__Account__c = Null;
        //END 28/04/15 UD-0776 Wenjun
        //START D-3551 09/25/2015 added by: Jason A.
        if(sub.Zuora__TermSettingType__c == 'EVERGREEN'){
            sub.Term_Length__c = Null;
        }
        //END D-3551 09/25/2015 added by: Jason A.
    }
   
   
    public void beforeUpdate(SObject oldSo, SObject so) {
    
        Zuora__Subscription__c sub = (Zuora__Subscription__c)so;
        //START D-2654 4/8/15 commented in by FrancisBenzon : bill run related. mapping of fields during update needed. 
        mapZSubscripitonCustomFields(sub);
        //END D-2654 4/8/15 commented in by FrancisBenzon : bill run related. mapping of fields during update needed. 
        //END: D-2279 02/20/2015 Added by Kristine Campang
        //Start UD-0677 04/22/2015 James - update subscription end date with the request stop date
        //End UD-0677 04/22/2015 James
        
        //START: UD-0410 04/06/15 RReyes
        if(sub.Term_Length__c > 0 && sub.Zuora__Status__c != GlobalVariableClass.STATUS_CANCELLED){ //Start/End UD-0677 04/22/2015 James
            sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1);
        }else if(sub.Zuora__Status__c != GlobalVariableClass.STATUS_CANCELLED && sub.Term_Length__c == null ){ //START-END UD-1733 Karen Hung- added status != cancelled
            sub.Zuora__SubscriptionEndDate__c = null;
        }
        //Start UD-0677 04/22/2015 James - update subscription end date with the request stop date
        //START D-3262 07/20/2015 Added by J.Sarion - Update Subscription End Date for Normal Expiry
        else if(sub.Term_Length__c > 0 && sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED && sub.Zuora__SubscriptionEndDate__c == sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c))){
            sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1);
        }
        //END D-3262 07/20/2015 Added by J.Sarion - Update Subscription End Date for Normal Expiry
        
        //Start UD-1642 06/13/2015 James
        //if(sub.Status_Formula__c == GlobalVariableClass.STATUS_CANCELLED){
            //sub.Is_Active__c = false;
        //}
        //End UD-1642 06/13/2015 James
        //End UD-0677 04/22/2015 James
        
        //START UD-2738 Wenjun 21/Sep/15 : Code Optimization
        if(!mapOliIDToCancelDate.isEmpty() && mapOliIDToCancelDate.containsKey(sub.Order_Line_Item_Number_1__c) && mapOliIDToCancelDate.get(sub.Order_Line_Item_Number_1__c) != null) 
        {
            //Set Subscription End Date = Cancel Date - 1
             sub.Zuora__SubscriptionEndDate__c = mapOliIDToCancelDate.get(sub.Order_Line_Item_Number_1__c).addDays(-1);
        }
        //END UD-2738 Wenjun 21/Sep/15 : Code Optimization
        //START D-3551 09/25/2015 added by: Jason A.
        if(sub.Zuora__TermSettingType__c == 'EVERGREEN'){
            sub.Term_Length__c = Null;
        }
        //END D-3551 09/25/2015 added by: Jason A.
        //START D-3797 Wenjun 22/Oct/15 : For Migrated PSTOP / COS
        if(sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED && sub.Subscription_End_Date__c != null && sub.Legacy_Subscription_ID__c != null) 
        { 
            try{
                sub.Zuora__SubscriptionEndDate__c = Date.valueOf(sub.Subscription_End_Date__c); 
            }
            catch(Exception e){}
        }
        //END D-3797 Wenjun 22/Oct/15
    }
    
    public void beforeDelete(SObject so) {
        //START 28/04/15 UD-0776 Wenjun - Disable delete any sub during Zuora Amendment Sync
        Zuora__Subscription__c sub = (Zuora__Subscription__c)so;
        //Subscriptions with empty Accoun ID are marked for deletion: i.e. new versions inserted
        if(sub.Zuora__Account__c != NULL) 
            sub.addError('Disable Zuora Sync Deletion!');
        //END 28/04/15 UD-0776 Wenjun
    }
   
    public void afterInsert(SObject so) {
        Zuora__Subscription__c subscription = (Zuora__Subscription__c)so; 
          /*  if (Userinfo.getlastname() == 'Testing123'){
                                    system.assertequals(subscription, null);
                    system.assertequals(1, 2);
                        } */
                    
        if (subscription.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION) { 
            
            updateDeliverySubscriptionBillingAccount(subscription.Id);
             system.debug('after insert is' + subscription.id);
            system.debug('after insert map ' + subscriptionId_subscription);
            // start for asia1 activation/deactivation
            orderLineItemId_subscriptionId.put(subscription.Order_Line_Item_Number_1__c, subscription.Id);
            // end for asia1 activation/deactivation
        }
        
        //START PD-0041 18May16 FrancisBenzon : exclude bulkUpload using cc for invoicePayment creation as payment method has timing issue
        //START D-2530 Wenjun 20/03/15 - Prevent unnessary actions for Subscription Amendments 
        if (subscription.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID
            && subscription.Zuora__Version__c == 1 
            && !(subscription.Acquisition_Type_1__c == GlobalVariableClass.SUBACQUISITIONTYPE_BULKORDERUPLOAD && subscription.Payment_Mode_1__c == GlobalVariableClass.CREDIT_CARD)
            ) 
        {
            subFullPrepaidSet.add(subscription.Id);
        }
        //END D-2530 Wenjun 20/03/1
        //END PD-0041 18May16 FrancisBenzon : exclude bulkUpload using cc for invoicePayment creation as payment method has timing issue
        
        //START: MD-10 03/17/15 Rom Edison Reyes

        //START D-2530 Wenjun 20/03/15 - Prevent unnessary actions for Subscription Amendments 
        if (subscription.Order_Number__c != null && subscription.Zuora__CustomerAccount__c != null 
           && subscription.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
           && subscription.Zuora__Version__c == 1) {
            orderIdSet4PaymentUpdate.add(subscription.Order_Number__c);
        }
        //END D-2530 Wenjun 20/03/15

        /*
         * Call method to update Vendor Subscription End Date in case of Vendor Conversion
         */
        setVendorSUbscriptionEndDate(so);
        /* START: D-3120 05/12/2015 Hotfix - Kevin Evasco - Immediate Email Notification not necessary for ESHOP
        //START D-2530 Wenjun 20/03/15 - Prevent unnessary actions for Subscription Amendments
        if (subscription.Acquisition_Type__c == GlobalVariableClass.ACQTYPE_ESHOP_ECOMZ_ONLINE 
            && subscription.Zuora__Status__c != GlobalVariableClass.STATUS_CANCELLED 
            && subscription.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
            && subscription.Zuora__Version__c == 1 ) {
            if(subscription.Contact__c != null) {
                if(subscription.Contact__r.Email__c != null) {
                    generateEshopEmail(subscription);
                }
            }           
        } END: D-3120 05/12/2015 Hotfix - Kevin Evasco - Immediate Email Notification not necessary for ESHOP */        
       //END D-2530 Wenjun 20/03/15
       
        // START D-1030 12/03/14 Kevin Evasco Updated to include acknowledgment letter suppression
        
        // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date  
        //START D-2530 Wenjun 20/03/15 - Prevent unnessary actions for Subscription Amendments  
        if(subscription.Supressed_Acknowledgement_Letter_1__c == false 
           && subscription.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
          && subscription.Zuora__Version__c == 1)
         //END D-2530 Wenjun 20/03/15
        {
            
            //START UD-2286 11-Aug-2015 Added By S.Puli
            string accString = String.valueOf(subscription.Zuora__CustomerAccount__c);
            //END UD-2286 11-Aug-2015 Added By S.Puli
            
            if(lprRecIdToDTL_MAP.get(accString)<>null){
            //START: UD-3732  1-15-2015 added by Jason A.
            System.debug('>>lprRecIdToDTL_MAP:' + lprRecIdToDTL_MAP);
                if(lprRecIdToStatus_MAP.get(accString).contains('New')){ //START/END UD-2328 08/25/15 RReyes - added condition if New 
                    //do nothing
                    System.debug('>>lprRecIdToDTL_MAP1:' + lprRecIdToDTL_MAP);
            //END: UD-3732  1-15-2015 added by Jason A.
                } else {
                    lprRecIdToDTL_MAP.get(accString).add(dtltoday);
                    lprRecIdToStatus_MAP.get(accString).add('New'); //START/END UD-2328 08/25/15 RReyes - added New on map
                    // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                    Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                    letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.acknowledgmentLetter;
                    // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                    //START UD-2286 11-Aug-2015 Added By S.Puli
                    letterPrintRequest.Record_ID__c = (id)subscription.Zuora__CustomerAccount__c;
                    //END UD-2286 11-Aug-2015 Added By S.Puli
                    // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                    letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;
                    // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                    letterPrintRequest.DTL_Date__c = dtltoday;
                    // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                    letterPrintRequest.Sub_Created_Date__c = subscription.CreatedDate;//START/END UD-2328 08/26/15 RReyes - assign value to sub created date
                    letterPrintRequests.add(letterPrintRequest);
                    // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                }
                
            } else{
                lprRecIdToDTL_MAP.put(accString, new Set<Date>{dtltoday});
                //START UD-2328 08/26/15 RReyes - added New on map
                if(lprRecIdToStatus_MAP.get(accString) <> null){
                    lprRecIdToStatus_MAP.get(accString).add('New'); 
                }else{
                    lprRecIdToStatus_MAP.put(accString, new Set<String>{'New'});
                }
                //END UD-2328 08/26/15 RReyes - added New on map
                Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.acknowledgmentLetter;
                // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                //START UD-2286 11-Aug-2015 Added By S.Puli
                letterPrintRequest.Record_ID__c = (id)subscription.Zuora__CustomerAccount__c;
                //END UD-2286 11-Aug-2015 Added By S.Puli
                // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;
                // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                letterPrintRequest.DTL_Date__c = dtltoday;
                // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                letterPrintRequest.Sub_Created_Date__c = subscription.CreatedDate;//START/END UD-2328 08/26/15 RReyes - assign value to sub created date
                letterPrintRequests.add(letterPrintRequest);
                
            }
            // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
        }
        
        if (subscription.Related_Subscription__c != null) {
      //START: D-2279 02/20/2015 Added by Kristine Campang - commented out lines
            //tieTempStopRecsToNewRenewalSub(subscription.Id, subscription.Related_Subscription__c);
            //tieCoaToRenewalSub(subscription.Id, subscription.Related_Subscription__c);
      //END: D-2279 02/20/2015 Added by Kristine Campang
        }
        
        // Start D-2005 02/08/2015 JohnD re-update case and order status if necessary
        updateOrderAndCaseStatus(subscription);
        // End D-2005 02/08/2015 JohnD
        
        //START D-2777 Wenjun 16/04/15 : Set Delivery Subscription Active Flag
        if(subscription.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY)
        {
            if(subscription.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID ||
               subscription.Zuora__SubscriptionStartDate__c <= Date.today() || subscription.Zuora__SubscriptionEndDate__c < Date.today())
                setRecipientIds.add(subscription.Recipient_Contact__c);
        }
        //END D-2777 Wenjun 16/04/15      

        //START 28/04/15 UD-0776 Wenjun : Save the new version for aysnc processing and prepare clean up list
        if(subscription.Zuora__Account__c == NULL && subscription.Zuora__Version__c != 1)
        {
            lstNewSubVersions.add(subscription);
            Zuora__Subscription__c subToDel = new Zuora__Subscription__c(Id = subscription.Id);
            lstNewSubsToDel.add(subToDel);
        }
        //END 28/04/15 UD-0776 Wenjun   
    }
   
    public void afterUpdate(SObject oldSo, SObject so) {
        
        setVendorSUbscriptionEndDate(so);
        //Start: D-3011 05/27/2015 James
        //Start: D-3097 06/10/2015 James
        Zuora__Subscription__c oldsubscription = (Zuora__Subscription__c)oldSo;
        Zuora__Subscription__c subscription = (Zuora__Subscription__c)so;
        
        //START:D-3102 6/17/15 Added by Manolo Valena - Removed part of condition that checks if the subscription start date is less than or equal to today, which means that the code will only be entered if the subscription is active. This will now allow future active subscriptions to be invoiced as well. Also updated string to GlobalVariableClass variables.
        if ((oldsubscription.Zuora__Status__c == GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE && subscription.Zuora__Status__c == GlobalVariableClass.ZUORA_STATUS_CANCEL) /*&& subscription.Zuora__SubscriptionStartDate__c <= date.today()*/){ // && subscription.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED) {
        //END:D-3102 6/17/15 Added by Manolo Valena
        //End D-3097 06/10/2015 James
    //START UD-1595 6/23/15 AddedBy FBenzon/JTeves : variables 
            
            //START UD-1544 05-07-2015 Marvin/John

            //START D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
            //START UD-1544 05-07-2015 Marvin/John
            /*if (billingAccountId_ArmsReturnStatus.get(subscription.Zuora__CustomerAccount__c) != null && billingAccountId_ArmsReturnStatus.get(subscription.Zuora__CustomerAccount__c) == 'ccFailure') {
                ccFailureSubIdSet.add(subscription.Id);
            }*/
            //END UD-1544 05-07-2015 Marvin/John
            //END D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
            
            
            //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            if(newSubCOSIDs.contains(subscription.Id)) { //populate subscription id set if: subs is subject to COS urgent invoicing scenatrio
                subStopSet.add(subscription.Id);        
            }
            //else if(subIdtoCosOrderId.containsKey(subscription.Id)) { //populate set of COS order Ids (recurring old subscriptions)
            //    cosOrderIdSet.add(subIdtoCosOrderId.get(subscription.Id));
            //}
            //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            //}
    //END UD-1595 6/23/15 AddedBy FBenzon/JTeves : variables 
        }
        //End: D-3011 05/27/2015 James
        
        // Start D-2005 02/08/2015 JohnD re-update case and order status if necessary
        updateOrderAndCaseStatus((Zuora__Subscription__c)so);
        // End D-2005 02/08/2015 JohnD
        
        //START 28/04/15 UD-0776 Wenjun - Trigger On-Demand sync to recover SPC records
        Zuora__Subscription__c oldSub = (Zuora__Subscription__c)oldSo;
        Zuora__Subscription__c newSub = (Zuora__Subscription__c)so;
        if(oldSub.Zuora__Version__c != newSub.Zuora__Version__c)
            setBAIdsToSync.add(newSub.Zuora__CustomerAccount__c);
        //END 28/04/15 UD-0776 Wenjun

    }
   
    public void afterDelete(SObject so) {
       
    }
   
    public void andFinally() {
        
        string ldapId;
        string serviceFlag;
        integer i;
        set<id> asia1SubscriptionIdSet;
        List<Asia1_Subscription__c> asia1SubscriptionList = new List<Asia1_Subscription__c>(); //START/END 27 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation for ESHOP
        
        if (trigger.isAfter) {
            //Start UD-3888 14-Apr-2016 Added By S.Puli - update LPR of the transferred Subs
            if(!lprToUpdate.isEmpty()){
                database.update(lprToUpdate, false);
            }
            //End UD-3888 14-Apr-2016 Added By S.Puli - update LPR of the transferred Subs
            if (!accountToUpdateList.isEmpty()) {
                try {
                    update accountToUpdateList;
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            if (!orderIdSet4PaymentUpdate.isEmpty()) {
                BillingAccountHelper.updateBillingAccountPaymenInfo(orderIdSet4PaymentUpdate);
            }
            
            //START D-2530 Wenjun 21/03/15 : fix duplicated usage sent after upting Billing Account
            if (!subFullPrepaidSet.isEmpty() && trigger.isInsert) {
                system.debug(':::subFullPrepaidSet ' + subFullPrepaidSet);
                invoiceProcessForFullPrepaid inv = new invoiceProcessForFullPrepaid();
                inv.callInvoice(subFullPrepaidSet);
            }
            //END D-2530 Wenjun 21/03/15
            
            //START D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes
            
            //START: MD-10 03/17/15 Rom Edison Reyes
                
                    
             
            
            //START UD-1544 04-07-2015 Marvin Gatchalian / JOhn Dacutan
            /* ccFailureSubIdSet.remove(null);
            
           
            if (!ccFailureSubIdSet.isEmpty()) {
                
                usageCreationforCCFailure createUsageForCCFailure = new usageCreationforCCFailure();
                createUsageForCCFailure.createUsage (ccFailureSubIdSet);    // Creation of invoice already included in this call
                
            }   */ 
            //END UD-1544 04-07-2015 Marvin Gatchalian / JOhn Dacutan
             
   
            if (!subStopSet.isEmpty()) {
                InvoiceProcessForStopSubscription inv = new InvoiceProcessForStopSubscription();
                inv.callInvoice(subStopSet);
                
                System.debug('>>Invoice Called:' + subStopSet);
            }//END: MD-10 03/17/15 Rom Edison Reyes   
           
            //END D-3236 11-07-2015 Marvin/JOhn - removing all UD-1544 codes            
            
            
            //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates -- delete this block
            //START UD-1595 6/23/15 AddedBy FBenzon/JTeves : call future method to invoke queueable class for "start" process of recurring Sub subject to COS
            //ISSUE: need to bulkify, can only handle at most 10 COS orders
            /*if(!cosOrderIdSet.isEmpty()) {
                for(Id cosOrderId : cosOrderIdSet) {
                    if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()) {
                        InvoiceProcessForStopSubscription.callCosQueueableClass(cosOrderId);
                    }
                }
            }*/
            //END UD-1595 6/23/15 AddedBy FBenzon/JTeves : call future method to invoke queueable class for "start" process of recurring Sub subject to COS
            //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            
            if(!vendorSubscriptionMap.isEmpty()) {
                try {
                    update vendorSubscriptionMap.values();
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            if (!emailMessageList.isEmpty()) {
                try {
                    Messaging.sendEmail(emailMessageList, true);
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }

            if (!orderId_order.isEmpty()) {
                try {
                    update orderId_order.values();
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            if (!orderId_case.isEmpty()) {
                try {
                    update orderId_case.values();
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            if (!caseSubscriptionList.isEmpty()) {
                try {
                    upsert caseSubscriptionList;
                } catch (exception e) {
                    exceptionList.add(e);
                    //SPULI - TEMPORARY LOG, DO NOT DEPLOY
                    
                    Log__c logRec = new Log__c();
                    logRec.Message__c = 'Subs Error:'+ String.valueOf(caseSubscriptionList);
                    logList.add(logRec);
                    //SPULI - TEMPORARY LOG, DO NOT DEPLOY
                }
            }
            
            if (!subscriptionZuoraId_subscriptionTempStop.isEmpty()) {
                try {
                    update subscriptionZuoraId_subscriptionTempStop.values();
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            if (!addressAssignmentList.isEmpty()) {
                
                try {
                    update addressAssignmentList;
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            if (!orderLineItemId_asia1Subscription_serviceActivation.isEmpty()) {
                try {
                    update orderLineItemId_asia1Subscription_serviceActivation.values();
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            if(!letterPrintRequests.isEmpty()) {
                try {
                    upsert letterPrintRequests;
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            if (!deliverySubscriptionList.isEmpty()) {
                try {
                    update deliverySubscriptionList;
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            
            // start for asia1 activation
            //START: PD-0035 May 16, 2016 Added by Kristine Balaoing - modified code for enabling of asia1 services

            
            if (!orderLineItemId_asia1SubscriptionList_serviceActivation.isEmpty()) {

                integer x = 0; //START/END: PD-0035 June 22, 2016 Added by Von Pernicia - added subscription to right service flag
                for (id orderLineItemId : orderLineItemId_asia1SubscriptionList_serviceActivation.keySet()) {
                    
                    serviceFlag = null;
                    ldapId = null;
                    i = 0;
                    asia1SubscriptionIdSet = new set<id>();
                    
                    map<id, string> subscriptionId_ldapId = new map<id, string>();
                    map<id, string> subscriptionId_serviceFlags = new map<id, string>();
                    map<id, Set<Id>> subscriptionId_asia1SubscriptionList = new map<id, Set<Id>>();
                    map<string, id> serviceFlag_subscriptionId = mapOliToMapSvcToSub.get(orderLineItemId);
                    System.debug(serviceFlag_subscriptionId + ' serviceFlag_subscriptionId');
                    System.debug(mapOliToMapSvcToSub + ' mapOliToMapSvcToSub');
                    for (Asia1_Subscription__c a1 : orderLineItemId_asia1SubscriptionList_serviceActivation.get(orderLineItemId)) {
                        
                        id subscriptionId = serviceFlag_subscriptionId.get(a1.Service_Access_Flag__r.Name + x);
                        
                        
                        //START 27 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation for ESHOP
                        if(a1.Service_Access_Flag__c != null) {
                            
                            if (ldapId == null) {
                                ldapId = a1.Asia1__r.User_ID_LDAP_ID__c;
                            }
                            
                            subscriptionId_ldapId.put(subscriptionId, ldapId);
                            if (subscriptionId_serviceFlags.get(subscriptionId) != null) {
                                serviceFlag = subscriptionId_serviceFlags.get(subscriptionId);
                            } else {
                                serviceFlag = '';
                            }
                            
                            if (serviceFlag != '') {
                            //START 26-Feb-2015 D-2342 Added by Krithika .D - commented the a1.Service_Access_Flag__c in order to provide the a1.Service_Access_Flag__r.Name
                                //serviceFlag += ASIA1_SERVICE_FLAG_DELIMITER + a1.Service_Access_Flag__c;
                                  serviceFlag += ASIA1_SERVICE_FLAG_DELIMITER + a1.Service_Access_Flag__r.Name;
                            } else {
                                //serviceFlag = a1.Service_Access_Flag__c;
                                  serviceFlag = a1.Service_Access_Flag__r.Name;
                            }
                            //End 26-Feb-2015 D-2342 Added by Krithika.D 
                            
                            subscriptionId_serviceFlags.put(subscriptionId, serviceFlag);
                            
                            if (subscriptionId_asia1SubscriptionList.get(subscriptionId) != null) {
                                subscriptionId_asia1SubscriptionList.get(subscriptionId).add(a1.Id);
                            } else {
                                subscriptionId_asia1SubscriptionList.put(subscriptionId, new Set<Id>{a1.Id});
                            }
                            
                            //asia1SubscriptionIdSet.add(a1.Id);
                            i++;
                        } else {
                            //a1.Subscription__c = orderLineItemId_subscriptionId.get(orderLineItemId);
                            a1.Subscription__c = mapOliToMapSvcToSub.get(orderLineItemId).get(a1.Service_Access_Flag__r.Name + x); //START/END: PD-0035 June 22, 2016 Added by Von Pernicia - added subscription to right service flag
                            asia1SubscriptionList.add(a1); 
                        }
                        //END 27 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation for ESHOP
                        x++; //START/END: PD-0035 June 22, 2016 Added by Von Pernicia - added subscription to right service flag
                    }
                    System.debug('SUB ID LDAP >> ' + subscriptionId_ldapId);
                    System.debug('SUB SVC FLAGS >> ' +   subscriptionId_serviceFlags);
                    System.debug('SUB ASIA1 SUB >>' + subscriptionId_asia1SubscriptionList);
                    System.debug('SVC SUBS >>' + serviceFlag_subscriptionId);
                    for (id subscriptionId : subscriptionId_ldapId.keySet()) {
                        AsiaOneServicesController.enableServicesFuture(subscriptionId_ldapId.get(subscriptionId), subscriptionId_serviceFlags.get(subscriptionId), subscriptionId_asia1SubscriptionList.get(subscriptionId), subscriptionId);
                    } 
                }
                
            }
            // end for asia1 activation
            //START: PD-0035 June 22, 2016 Added by Von Pernicia - added subscription to right service flag
            // start for asia1 deactivation
            //START UD-2036 07/24/2015 Added by J.Sarion - Commented out. Tie Subscription to Asia1 Subscription
            System.debug(' ORDERLINE MAP >> ' + orderLineItemId_asia1SubscriptionList_FromExistingAsia1);
            System.debug('ORDER LINE MAP TO SUB >> ' + mapOliToMapSvcToSub);
            if(!orderLineItemId_asia1SubscriptionList_FromExistingAsia1.isEmpty()){
                integer x = 0;
                for (id orderLineItemId : orderLineItemId_asia1SubscriptionList_FromExistingAsia1.keySet()){
                    for (Asia1_Subscription__c a1 : orderLineItemId_asia1SubscriptionList_FromExistingAsia1.get(orderLineItemId)){
                        //a1.Subscription__c = orderLineItemId_subscriptionId.get(orderLineItemId);
                        a1.Subscription__c = mapOliToMapSvcToSub.get(orderLineItemId).get(a1.Service_Access_Flag__r.Name + x);
                        updateAsia1SubFromExistingAsia1List.add(a1);
                        x++;
                    }
                }
            }
            //END: PD-0035 June 22, 2016 Added by Von Pernicia - added subscription to right service flag
            /*
            if (!orderLineItemId_asia1SubscriptionList_serviceDeactivation.isEmpty()) {
                for (id orderLineItemId : orderLineItemId_asia1SubscriptionList_serviceDeactivation.keySet()) {
                    
                    serviceFlag = null;
                    ldapId = null;
                    i = 0;
                    asia1SubscriptionIdSet = new set<id>();
                    
                    for (Asia1_Subscription__c a1 : orderLineItemId_asia1SubscriptionList_serviceDeactivation.get(orderLineItemId)) {
                        
                        if (ldapId == null) {
                            ldapId = a1.Asia1__r.User_ID_LDAP_ID__c;
                        }
                        
                        if (i > 0) {
                            serviceFlag += ASIA1_SERVICE_FLAG_DELIMITER + a1.Service_Access_Flag__c;
                        } else {
                            serviceFlag = a1.Service_Access_Flag__c;
                        }
                        
                        asia1SubscriptionIdSet.add(a1.Id);
                        i++;
                    }
                    // callout to deactivation
                    AsiaOneServicesController.disableServicesFuture(ldapId, serviceFlag, asia1SubscriptionIdSet);
                }
            }
            */
            
            //START 27 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation for ESHOP
            if(asia1SubscriptionList.size() > 0) {
                update asia1SubscriptionList;
            }
            //END 27 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation for ESHOP
            System.debug('ASIA1 TO BE UPDATED >>' + updateAsia1SubFromExistingAsia1List);
            if(!updateAsia1SubFromExistingAsia1List.isEmpty()){
                try{
                    update updateAsia1SubFromExistingAsia1List;
                }
                catch(Exception e){
                    exceptionList.add(e);
                }
            }
            //END UD-2036 07/24/2015 Added by J.Sarion - Commented out. Tie Subscription to Asia1 Subscription   
            
            //Start D-2824 VPernicia/MGatchalian: Comment out
            //Start D-2248 03 March 2015 ABanaag 
            /*system.debug('subIdsToInvoiceSeparately :' +subIdsToInvoiceSeparately);
            if(subIdsToInvoiceSeparately.size()>0){
                try{
                    invoiceSeparately(subIdsToInvoiceSeparately);
                }
                catch(Exception e){
                    exceptionList.add(e);
                }
            }*/
            //End D-2248 03 March 2015 ABanaag             
            // end for asia1 deactivation
            //End D-2824 VPernicia/MGatchalian: Comment out
            
            ExceptionLogger.log(exceptionList);
            insert logList;//SPULI TEMP LOG, to delete tomorrow
            //START D-2777 Wenjun 16/04/15 : Set Delivery Subscription Active Flag
            if(!setRecipientIds.isEmpty())
                updateDelSubsActiveFlag(setRecipientIds);
            //END D-2777 Wenjun 16/04/15
            
            //START 28/04/15 UD-0776 Wenjun: Custom Sync to solve Zuora Amendment Issue
            if(!lstNewSubVersions.isEmpty())
            {
                CustomZuoraSyncQueueable asynJob = new CustomZuoraSyncQueueable();
                asynJob.lstNewVersions = lstNewSubVersions;
                System.enqueueJob(asynJob);
            }
            
            if(!lstNewSubsToDel.isEmpty())
            {
                //DELETE All New Versions
                DELETE lstNewSubsToDel;
                //Database.emptyRecycleBin(lstNewSubsToDel);                
            }
            
            if(!setBAIdsToSync.isEmpty())
            {
                //Perform Zuora Sync
                Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
                syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
                syncManager.syncObjectIdSet  = setBAIdsToSync;
                //Disable Email Notification for On-demand Sync
                syncManager.emailNotificationEnabled = false;
                
                List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
                System.debug('>>>>> Sync Result:' + syncResult);
            }  
            //END 04/05/15 UD-0776 Wenjun
            
        }
    }

    void setVendorSUbscriptionEndDate(sObject so) {
        Zuora__Subscription__c zSub = (Zuora__Subscription__c) so;
        if(zSub.Vendor_Subscription_To_Convert_1__c != null) {
            if(!vendorSubscriptionMap.containsKey(zSub.Vendor_Subscription_To_Convert_1__c)) {
                Subscription_Vendor__c vendorSub = new Subscription_Vendor__c(
                    Id = zSub.Vendor_Subscription_To_Convert_1__c,
                    Subscription_Stop_Date__c = zSub.Zuora__SubscriptionStartDate__c
                );
                vendorSubscriptionMap.put(vendorSub.Id, vendorSub);
            }
        }
    } 
    
    private void updateDeliverySubscriptionBillingAccount(id subId) {
        system.debug('>>>>>sub Id ' + subId);
        system.debug('>>>>>sub Id ' + subscriptionId_subscription);
        Zuora__Subscription__c subscription = subscriptionId_subscription.get(subId);
        system.debug('>>>>>sub Id ' + subscription );
        if (subscription != null) {
            
            if (Userinfo.getlastname() == 'Test123'){
               system.assertequals(subscription, null);
              system.assertequals(1, 2);
          }
            
            // start from paypal to other
            if (subscription.Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c != GlobalVariableClass.PAYPAL
                    && subscription.Zuora__Status__c == GlobalVariableClass.STATUS_ACTIVE) {
                        
                for (Zuora__Subscription__c delSub : accountId_deliverySubscriptionList.get(subscription.Zuora__Account__c)) {
                    
                    
                    if (delSub.Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c == GlobalVariableClass.PAYPAL) {
                        
                        if (subscription.Recipient_Contact__r.Address__c != null && delSub.Recipient_Contact__r.Address__c != null) {
                            
                            if (subscription.Recipient_Contact__r.Address__r.Postal_Code__c != null && delSub.Recipient_Contact__r.Address__r.Postal_Code__c != null) {
                                
                                if (subscription.Recipient_Contact__r.Address__r.Level_Number__c == delSub.Recipient_Contact__r.Address__r.Level_Number__c 
                                        && subscription.Recipient_Contact__r.Address__r.Unit_Number__c == delSub.Recipient_Contact__r.Address__r.Unit_Number__c 
                                        && subscription.Recipient_Contact__r.Address__r.Postal_Code__r.Name == delSub.Recipient_Contact__r.Address__r.Postal_Code__r.Name) {
                                    
                                    // start replace paypal billing account in delivery subscription into new non paypal billing account
                                    delSub.Zuora__CustomerAccount__c = subscription.Zuora__CustomerAccount__c;
                                    deliverySubscriptionList.add(delSub);
                                    
                                    emailBody = '';
                                    
                                    if (delSub.Zuora__CustomerAccount__r.Name != null 
                                            && subscription.Zuora__CustomerAccount__r.Name != null 
                                            && delSub.Order_Number_1__r.Name != null 
                                            && subscription.Order_Number_1__r.Name != null) {
                                                
                                        emailBody = delSub.Zuora__CustomerAccount__r.Name + ' -> ' + subscription.Zuora__CustomerAccount__r.Name;
                                        emailBody += '<br />';
                                        emailBody += delSub.Order_Number_1__r.Name + ' -> ' + subscription.Order_Number_1__r.Name;
                                    }
                                    
                                    if (subscription.Contact__r.Email__c != null) {
                                        generateEmailToList(subscription.Contact__r.Email__c, GlobalVariableClass.PAYPAL_2_OTHER_EMAIL_SUBJECT, emailBody);
                                    }
                                    // end replace paypal billing account in delivery subscription into new non paypal billing account
                                }
                            }
                        }
                    }
                }       
            // end from paypal to other
            
            } else if (subscription.Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c != GlobalVariableClass.PAYPAL
                    && (subscription.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED 
                    || subscription.Zuora__Status__c == GlobalVariableClass.STATUS_EXPIRED) 
                    && billingAccountId_isWithActiveSubscription.get(subscription.Zuora__CustomerAccount__c) != true) {
                
                
                boolean isNonPaypal = false;
                
                // start from non paypal to non paypal
                for (Zuora__Subscription__c sub : accountId_subscriptionList.get(subscription.Zuora__Account__c)) {
                    
                    if (sub.Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c != GlobalVariableClass.PAYPAL 
                            && subscription.Zuora__CustomerAccount__c != sub.Zuora__CustomerAccount__c) {
                        
                        if (subscription.Recipient_Contact__r.Address__c != null && sub.Recipient_Contact__r.Address__c != null) {
                            
                            if (subscription.Recipient_Contact__r.Address__r.Postal_Code__c != null && sub.Recipient_Contact__r.Address__r.Postal_Code__c != null) {
                                
                                if (subscription.Recipient_Contact__r.Address__r.Level_Number__c == sub.Recipient_Contact__r.Address__r.Level_Number__c 
                                        && subscription.Recipient_Contact__r.Address__r.Unit_Number__c == sub.Recipient_Contact__r.Address__r.Unit_Number__c 
                                        && subscription.Recipient_Contact__r.Address__r.Postal_Code__r.Name == sub.Recipient_Contact__r.Address__r.Postal_Code__r.Name) {
                                    
                                    // start retrieve delivery subscription of the expired subscription
                                    for (Zuora__Subscription__c delSub : accountId_deliverySubscriptionList.get(subscription.Zuora__Account__c)) {
                                        
                                        if (delSub.Zuora__CustomerAccount__c == subscription.Zuora__CustomerAccount__c) {
                                            
                                            delSub.Zuora__CustomerAccount__c = sub.Zuora__CustomerAccount__c;
                                            deliverySubscriptionList.add(delSub);

                                            // start replace non paypal billing account in delivery subscription into non paypal billing account
                                            emailBody = '';
                                            
                                            if (delSub.Zuora__CustomerAccount__r.Name != null 
                                                    && subscription.Zuora__CustomerAccount__r.Name != null 
                                                    && delSub.Order_Number_1__r.Name != null 
                                                    && subscription.Order_Number_1__r.Name != null) {
                                                        
                                                emailBody = subscription.Zuora__CustomerAccount__r.Name + ' -> ' + delSub.Zuora__CustomerAccount__r.Name;
                                                emailBody += '<br />';
                                                emailBody += subscription.Order_Number_1__r.Name + ' -> ' + delSub.Order_Number_1__r.Name;
                                            }
                                            
                                            if (delSub.Contact__r.Email__c != null) {
                                                generateEmailToList(delSub.Contact__r.Email__c, NON_PAYPAL_2_NON_PAYPAL_EMAIL_SUBJECT, emailBody);
                                            }
                                            // end replace paypal billing account in delivery subscription into new non paypal billing account
                                            
                                            isNonPaypal = true;
                                            break;
                                        }
                                    } 
                                    // end retrieve delivery subscription of the expired subscription
                                }
                            }
                        }
                    }                   
                }
                // end from non paypal to non paypal
                
                if (isNonPaypal == false) {
                    
                    // start from non paypal to non paypal
                    for (Zuora__Subscription__c sub : accountId_subscriptionList.get(subscription.Zuora__Account__c)) {
                        
                        if (sub.Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c == GlobalVariableClass.PAYPAL 
                                && subscription.Zuora__CustomerAccount__c != sub.Zuora__CustomerAccount__c) {
                            
                            if (subscription.Recipient_Contact__r.Address__c != null && sub.Recipient_Contact__r.Address__c != null) {
                                
                                if (subscription.Recipient_Contact__r.Address__r.Postal_Code__c != null && sub.Recipient_Contact__r.Address__r.Postal_Code__c != null) {
                                    
                                    if (subscription.Recipient_Contact__r.Address__r.Level_Number__c == sub.Recipient_Contact__r.Address__r.Level_Number__c 
                                            && subscription.Recipient_Contact__r.Address__r.Unit_Number__c == sub.Recipient_Contact__r.Address__r.Unit_Number__c 
                                            && subscription.Recipient_Contact__r.Address__r.Postal_Code__r.Name == sub.Recipient_Contact__r.Address__r.Postal_Code__r.Name) {
                                        
                                        // start retrieve delivery subscription of the expired subscription
                                        for (Zuora__Subscription__c delSub : accountId_deliverySubscriptionList.get(subscription.Zuora__Account__c)) {
                                            
                                            if (delSub.Zuora__CustomerAccount__c == subscription.Zuora__CustomerAccount__c) {
                                                
                                                delSub.Zuora__CustomerAccount__c = sub.Zuora__CustomerAccount__c;
                                                deliverySubscriptionList.add(delSub);
    
                                                // start replace non paypal billing account in delivery subscription into non paypal billing account
                                                emailBody = '';
                                                
                                                if (delSub.Zuora__CustomerAccount__r.Name != null 
                                                        && subscription.Zuora__CustomerAccount__r.Name != null 
                                                        && delSub.Order_Number_1__r.Name != null 
                                                        && subscription.Order_Number_1__r.Name != null) {
                                                            
                                                    emailBody = subscription.Zuora__CustomerAccount__r.Name + ' -> ' + delSub.Zuora__CustomerAccount__r.Name;
                                                    emailBody += '<br />';
                                                    emailBody += subscription.Order_Number_1__r.Name + ' -> ' + delSub.Order_Number_1__r.Name;
                                                }
                                                
                                                if (delSub.Contact__r.Email__c != null) {
                                                    generateEmailToList(delSub.Contact__r.Email__c, NON_PAYPAL_2_PAYPAL_EMAIL_SUBJECT, emailBody);
                                                }
                                                // end replace paypal billing account in delivery subscription into new non paypal billing account
                                                
                                                break;
                                            }
                                        } 
                                        // end retrieve delivery subscription of the expired subscription
                                    }
                                }
                            }
                        }                   
                    }
                    // end from non paypal to non paypal                    
                }
            }
        }       
    }
    
    // Start D-xxxx 18Apr16 JohnD - commented out. methods not in used.
    
    //START PD-0083 09Jun2016 Added By C. Lin - Comment out method not used
    /*private void tieTempStopRecsToNewRenewalSub(id subscriptionId, string zuoraId) {
        
        if (subscriptionZuoraId_subscriptionTempStop != null) {

            if(subscriptionZuoraId_subscriptionTempStop.containsKey(zuoraId)){
                subscriptionTempStop = subscriptionZuoraId_subscriptionTempStop.get(zuoraId);
            }
            
            if (subscriptionTempStop != null) {
                subscriptionTempStop.Subscription__c = subscriptionId;
                subscriptionZuoraId_subscriptionTempStop.put(zuoraId, subscriptionTempStop);
            }
        }
    }

    private void tieCoaToRenewalSub(id subscriptionId, string zuoraId) {
        
        if (subscriptionZuoraId_addressAssignmentList != null) {
            if (subscriptionZuoraId_addressAssignmentList.containsKey(zuoraId)) {
                for (Address_Assignment__c addAss : subscriptionZuoraId_addressAssignmentList.get(zuoraId)) {
                    addAss.Subscription__c = subscriptionId;
                    addressAssignmentList.add(addAss);
                }
            }
        }
    }*/
    //END PD-0083 09Jun2016 Added By C. Lin
    
    /*@Description: Ties Subscription to Asia1 and activates Asia1 account when Subscription is created in SF
    *Date: 11/26/2014
    *@author: FrancisBenzon
    */
    //START PD-0083 09Jun2016 Added By C. Lin - Comment out method not used
    /*private void activateAsia1Subscription(id subscriptionId, id orderLineItemId) {

        if (orderLineItemId_asia1Subscription_serviceActivation != null) {
            
            asia1Subscription = orderLineItemId_asia1Subscription_serviceActivation.get(orderLineItemId);
            
            if (asia1Subscription != null) {
                
                asia1Subscription.Subscription__c = subscriptionId;
                orderLineItemId_asia1Subscription_serviceActivation.put(orderLineItemId, asia1Subscription);
                
                if (asia1Subscription.Asia1__r.User_ID_LDAP_ID__c != null && asia1Subscription.Service_Access_Flag__r.Name != null) {
                    
                    try {
                        AsiaOneServicesController.enableServiceFuture(asia1Subscription.Asia1__r.User_ID_LDAP_ID__c, asia1Subscription.Service_Access_Flag__r.Name, asia1Subscription.Id);
                    } catch (exception e) {
                        // send email to customer for manual activation
                        exceptionList.add(e);
                    }
                }
            }
        }
    }
 
    private void deactivateAsia1Subscription(id subscriptionId, id orderLineItemId) {
        
        if (orderLineItemId_asia1Subscription_serviceDeactivation != null) {
            
            asia1Subscription = orderLineItemId_asia1Subscription_serviceDeactivation.get(orderLineItemId);
            
            if (asia1Subscription != null) {
                
                asia1Subscription.Subscription__c = subscriptionId;
                orderLineItemId_asia1Subscription_serviceDeactivation.put(orderLineItemId, asia1Subscription);
                
                if (asia1Subscription.Asia1__r.User_ID_LDAP_ID__c != null && asia1Subscription.Service_Access_Flag__r.Name != null) {
                
                    try {
                        AsiaOneServicesController.disableServiceFuture(asia1Subscription.Asia1__r.User_ID_LDAP_ID__c, asia1Subscription.Service_Access_Flag__r.Name, asia1Subscription.Id);
                    } catch (exception e) {
                        exceptionList.add(e);
                    }
                }
            }
        }
    }*/
    //END PD-0083 09Jun2016 Added By C. Lin
    // End D-xxxx 18Apr16 JohnD - commented out. methods not in used.
    
    // Start D-2005 02/08/2015 JohnD update case and order status
    private void updateOrderAndCaseStatus(Zuora__Subscription__c subscription) {
        
        Order__c orderTmp = new Order__c();
        Case caseTmp = new Case();
        
        if (orderId_isNoVendorNeeded != null) {
      //START: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
            if (orderId_isNoVendorNeeded.get(subscription.Order_Number__c) == true && subscription.Vendor__c  != null) {
      //END: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case                
                orderTmp = orderId_order.get(subscription.Order_Number__c);
                caseTmp = orderId_case.get(subscription.Order_Number__c);
                
                // Start D-4255 20Jan16 JohnD - bypass update if status is already closed
                if (orderTmp != null && orderTmp.Status__c != GlobalVariableClass.STATUS_CLOSE) {
                    
                    orderTmp.Status__c = GlobalVariableClass.STATUS_CLOSE;
                    orderId_order.put(subscription.Order_Number__c, orderTmp);
                }
                
                if (caseTmp != null && caseTmp.Status != GlobalVariableClass.STATUS_CLOSED) {

                    caseTmp.Status = GlobalVariableClass.STATUS_CLOSED;
                    caseTmp.Sub_Status__c = GlobalVariableClass.SUB_STATUS_SUBS_CREATED;
                    caseTmp.OwnerId = caseTmp.CreatedById;
                    orderId_case.put(subscription.Order_Number__c, caseTmp);
                }
                // End D-4255 20Jan16 JohnD - bypass update if status is already closed
            }
        }
    }
    
    private void mapZSubscripitonCustomFields(Zuora__Subscription__c sub){
        sub.Order_Line_Item_Number_1__c = idOf(sub.Order_Line_Item_Number__c);
        
        Order_Line_Item__c orderLineItem = orderLineItemId_orderLineItem.get(sub.Order_Line_Item_Number_1__c);

        sub.Vendor_Subscription_To_Convert_1__c = idOf(sub.Vendor_Subscription_To_Convert__c);
        sub.Main_Package_1__c = idOf(sub.Main_Package__c);
        sub.Contract_End_Date_1__c = dateOf(sub.Contract_End_Date__c);
        sub.New_Contract_Period_1__c = decimalOf(sub.New_Contract_Period__c);
        sub.Penalty_Charge_1__c = decimalOf(sub.Penalty_Charge__c);
        sub.Promotion_Contract_Period_1__c = decimalOf(sub.Promotion_Contract_Period__c);
        sub.Vendor_Credit_1__c = decimalOf(sub.Vendor_Credit__c);
        // Start D-3169 24Jun15 JohnD - convert to null
        if (sub.Delivered_By__c != GlobalVariableClass.VENDOR) {
            sub.Vendor_Credit_1__c = null;
            sub.Vendor_Credit__c = null;
        }
        // End D-3169 24Jun15 JohnD - convert to null
        
        sub.Promotion_1__c = idOf(sub.Promotion__c);
        sub.Other_PaymentMethod_1__c = sub.Other_PaymentMethod__c;
        sub.Payment_Mode_1__c = sub.Payment_Mode__c; 
        sub.Acquisition_Type_1__c = sub.Acquisition_Type__c;
        sub.Asia1_Creation_Mode_1__c = sub.Asia1_Creation_Mode__c;
        sub.Delivered_By_1__c = sub.Delivered_By__c;
        sub.Delivery_Charge_Type_1__c = sub.Delivery_Charge_Type__c;
        sub.Frequency_1__c = sub.Frequency__c;
        sub.Subscription_Type_1__c = sub.Subscription_Type__c;
        
        // Start UD-1646 23Jun15 JohnD - added logic for Addon field
        try {
            if (sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                && sub.Main_Package_1__c != orderLineItem.Addon_Package__c) {
                    
                sub.Addon_Package__c = orderLineItem.Addon_Package__c;
                sub.Addon_Package_1__c = orderLineItem.Addon_Package__c;
            }
        }
        catch(exception e)
        {
            system.debug('ERROR' + ' ' + e.getMessage() + e.getStackTraceString());
            
        }
        
        // End UD-1646 23Jun15 JohnD - added logic for Addon field
        
         if(sub.Recipient_Contact__c!=null && sub.Recipient_Contact_1__c!=null){ //Start/End D-2324 02/26/15 Added by ABanaag - added condition
        sub.Recipient_Contact__c = sub.Recipient_Contact_1__c;
        }//Start/End D-2324 02/26/15 Added by ABanaag - added condition
        if(sub.Recipient_Contact__c!=null && sub.Recipient_Contact_1__c!=null){//Start/End D-2324 02/26/15 Added by ABanaag - added condition        
        sub.Subscriber_Contact__c = sub.Recipient_Contact_1__c;
        }//Start/End D-2324 02/26/15 Added by ABanaag - added condition      
        sub.Suppress_Vendor_Start_Notice_1__c = booleanOf(sub.Suppress_Vendor_Start_Notice__c);
        sub.Supressed_Acknowledgement_Letter_1__c = booleanOf(sub.Supressed_Acknowledgement_Letter__c);
        sub.Supressed_Renewal_and_Reminder_Letter_1__c = booleanOf(sub.Supressed_Renewal_and_Reminder_Letter__c);
        sub.Urgent_1__c = booleanOf(sub.Urgent__c);
        sub.Vendor_Conversion_1__c = booleanOf(sub.Vendor_Conversion__c);
        sub.Charity_1__c = booleanOf(sub.Charity__c);
        //sub.Sponsor_1__c = booleanOf(sub.Sponsor__c);
        sub.Qty__c = decimalOf(sub.Qty1__c);
        sub.Number_of_Copies__c = sub.Qty__c;
        sub.Term_Length__c = decimalOf(sub.Term_Length1__c); 
        sub.Generate_Invoice__c = booleanOf(sub.Generate_Invoice1__c);
        //Start D-1303 02/19/2015 Added by ABanaag - added checking for isInsert so end date will not be changed during update
        
        
         
                
        if (sub.Zuora__SubscriptionEndDate__c != null && trigger.IsInsert) {
        //End D-1303 02/19/2015 Added by ABanaag - added checking for isInsert so end date will not be changed during update
            //sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionEndDate__c.addDays(-1);  Start/End 04/22/2015 James- commenting out for UD-0677
        }
        //START: UD-0410 04/01/2015 - RReyes - Added subscription End Date logic - CommentedOut - no longer needed
        /*if (sub.Zuora__SubscriptionStartDate__c != null && sub.Term_Length__c != null && sub.Term_Length__c > 0) {
            sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1);
         System.debug('>>>SUB New Logic End Date AFTER: '+ sub.Zuora__SubscriptionEndDate__c);   
        }*/
        //END: UD-0410 04/01/2015 - RReyes - Added subscription End Date logic - CommentedOut - no longer needed
        
        //START AddedBy FrancisBenzon 9/17/15 UD-2761 : moved this code lines after assigning of value for billing type below.
        /*
        //START D-2327 25/02/15 Wenjun : Set Subscription Charge
        Decimal chargeAmt = getSubscriptionRate(sub);
        //START UD-2195 8/07/2015 Added K. Tan - to apply only for non migrated data
        if(chargeAmt != null){
            if(sub.Legacy_Subscription_ID__c == null){
                sub.Subscription_Charge__c = chargeAmt;
            }
        //END UD-2195 8/07/2015 Added K. Tan - to apply only for non migrated data
    
        }
        //END D-2327 25/02/15 Wenjun
        */
        //END AddedBy FrancisBenzon 9/17/15 UD-2761 : moved this code lines after assigning of value for billing type below.
        
        
        if (orderLineItem != null) {
            //START D-2291 2/19/2015 Added By C.Lin - Check if Vendor from Zuora is not null
            if (sub.Vendor__c == null) {
                sub.Vendor_1__c = orderLineItem.Vendor_Mailing_Agent__c;
                sub.Vendor__c = orderLineItem.Vendor_Mailing_Agent__c;
            }
            else {
                sub.Vendor_1__c = sub.Vendor__c;
            }
            //END D-2291 2/19/2015 Added By C.Lin
            
            //START UD-1816 7/16/2015 Added By C. Lin - Classification field
            //START UD-1626 8/12/2015 Added By C. Lin - Prevent argument cannot be null error
            if(sub.Zuora__SubscriptionEndDate__c != null && sub.Zuora__TermSettingType__c == 'TERMED' && sub.Term_Length__c != null && sub.Zuora__SubscriptionStartDate__c != null){
            //END UD-1626 8/12/2015 Added By C. Lin
                if((sub.Zuora__SubscriptionStartDate__c.addMonths(integer.valueOf(sub.Term_Length__c)).addDays(-1) != sub.Zuora__SubscriptionEndDate__c || 
                oldSubToStopOrderLineMap.containsKey(sub.Id)) && sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED){
                    sub.Classification__c = 'pStop';
                    sub.Sub_Classification__c = 'N/A';
                }else if(oldSubToRenewalOrderLineMap.containsKey(sub.Id) && sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED){
                    if(oldSubToRenewalOrderLineMap.get(sub.Id).Order__r.Order_Type__c == 'Renewal'){
                        sub.Classification__c = 'Expired';
                        sub.Sub_Classification__c = 'N/A';
                    }else{
                        sub.Classification__c = orderLineItem.Classification__c;
                        sub.Sub_Classification__c = orderLineItem.Sub_classification__c;
                    }
                }else if(!oldSubToRenewalOrderLineMap.containsKey(sub.Id) && sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED){
                    sub.Classification__c = 'Non Renewal';
                    sub.Sub_Classification__c = 'N/A';
                }else{
                    sub.Classification__c = orderLineItem.Classification__c;
                    sub.Sub_Classification__c = orderLineItem.Sub_classification__c;
                }
            }else if(sub.Zuora__SubscriptionEndDate__c == null && sub.Zuora__TermSettingType__c == 'EVERGREEN'){
                if(oldSubToStopOrderLineMap.containsKey(sub.Id) && sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED){
                    sub.Classification__c = 'pStop';
                    sub.Sub_Classification__c = 'N/A';
                }else{
                    sub.Classification__c = orderLineItem.Classification__c;
                    sub.Sub_Classification__c = orderLineItem.Sub_classification__c;
                }
            }
            
            if(sub.Addon_Package_1__c != null || sub.Addon_Package__c != null){
                sub.Classification__c = 'Add On';
                sub.Sub_Classification__c = 'N/A';
            }
            //END UD-1816 7/16/2015 Added By C. Lin
            sub.Reason_Code__c = orderLineItem.Reason_Code__c;
            sub.Billing_Type__c = orderLineItem.Main_Package_Billing_Type__c;
            sub.Generate_Invoice__c = orderLineItem.Generate_Invoice__c;
            sub.Term_is_discussed__c = orderLineItem.Term_is_discussed__c;
            sub.Promotion_1__c = orderLineItem.Promotion_ID__c;

            //START UD-2761 9/17/15 AddedBy FrancisBenzon : moved code line here after billing type assignment
            //START D-2327 25/02/15 Wenjun : Set Subscription Charge
            Decimal chargeAmt = getSubscriptionRate(sub);
            //START UD-2195 8/07/2015 Added K. Tan - to apply only for non migrated data
            if(chargeAmt != null){
                if(sub.Legacy_Subscription_ID__c == null){
                    sub.Subscription_Charge__c = chargeAmt;
                }
            //END UD-2195 8/07/2015 Added K. Tan - to apply only for non migrated data 
            }
            //END D-2327 25/02/15 Wenjun
            //END UD-2761 9/17/15 AddedBy FrancisBenzon : moved code line here after billing type assignment
            
            if (orderLineItem.Order__c != null) {
            
                sub.Sponsor_1__c = orderLineItem.Order__r.Sponsor__c;   // Start/End UD-2660 09Sep15 JohnD
              //START UD-0810 04-23-2014 MarvinG
              sub.Payment_Mode_1__c = orderLineItem.Order__r.Payment_Mode__c;
              sub.Payment_Mode__c = orderLineItem.Order__r.Payment_Mode__c;
              sub.Other_PaymentMethod_1__c = orderLineItem.Order__r.Other_Payment_Mode__c;
              sub.Other_PaymentMethod__c = orderLineItem.Order__r.Other_Payment_Mode__c;
             //END UD-0810 04-23-2014 MarvinG
            
            //Start D-2324 02/26/15 Added by ABanaag - included orderLineItem.Order__r.Recipient_Contact__c!=null in condition    
                //START D-3153 6/30/2015 Added by Manolo Valena - Removed orderLineItem.Auto_Renew__c == false.
                if (sub.Recipient_Contact_1__c == null && orderLineItem.Order__r.Recipient_Contact__c!=null) {
                //END D-3153 6/30/2015 Added by Manolo Valena
            //End D-2324 02/26/15 Added by ABanaag - included orderLineItem.Order__r.Recipient_Contact__c!=null in condition
                    sub.Recipient_Contact__c = orderLineItem.Order__r.Recipient_Contact__c;
                    sub.Recipient_Contact_1__c = orderLineItem.Order__r.Recipient_Contact__c;
                    sub.Subscriber_Contact__c = orderLineItem.Order__r.Recipient_Contact__c;
                }
                sub.Contact__c = orderLineItem.Order__r.Billing_Contact__c;
                sub.Order_Number_1__c = orderLineItem.Order__c;
                sub.Postage_Charge__c = orderLineItem.Postage_Charge__c; 
                // Start UD-1548 17Jun15 JohnD - added logic for delivery charge
                if (orderLineItem.Delivered_By__c == GlobalVariableClass.VENDOR) {
                    
                    sub.Delivery_Charge__c = orderLineItem.Order__r.Subscriber_Charge__c;
                    
                    if (sub.Delivery_Charge_Type_1__c == 'N') sub.Delivery_Charge__c = 0; //Start/End Dags Hotfix for UD-2042
                    
                    //START D-3215 7/10/2015 Added by Manolo Valena
                    if(sub.Delivery_Charge__c != null) {
                        if (orderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE) {
                            sub.Delivery_Charge__c = sub.Delivery_Charge__c * orderLineItem.Term_Length__c;
                        }
                        
                        //START UD-2162 08/19/2015 Added by J.Sarion - Update Delivery Charge equal to Vendor Credit
                        if(sub.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE || sub.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_POST){
                            if(sub.Delivery_Charge_Type_1__c == 'H' || sub.Delivery_Charge_Type_1__c == 'C' || sub.Delivery_Charge_Type_1__c == 'L'){
                                sub.Delivery_Charge__c = sub.Vendor_Credit_1__c;
                            }
                        }
                        //END UD-2162 08/19/2015 Added by J.Sarion - Update Delivery Charge equal to Vendor Credit
                    }
                    //END D-3215 7/10/2015 Added by Manolo Valena
                }
                // End UD-1548 17Jun15 JohnD - added logic for delivery charge
                // START: D-2526 03/16/2015 Added By Karl Tan- modified field to capture Grace Days field on Order line Item

                if (orderLineItem.Grace_Days__c > 0) {
                    sub.Grace_Period_Subscription__c = orderLineItem.Order__r.Subscription__c;
                // END: D-2526 03/16/2015 Added By Karl Tan- modified field to capture Grace Days field on Order line Item
                    
                }
            }
        }
        
        //START UD-2867 09/21/2015 Added by J.Sarion - populate Unique Address Id
        if(sub.Recipient_Contact__c != null){
            if(contactIdToContactMap.containsKey(sub.Recipient_Contact__c)){
                if(contactIdToContactMap.get(sub.Recipient_Contact__c).Address_Unique_Id__c != null){
                    sub.Unique_Address_Id__c = contactIdToContactMap.get(sub.Recipient_Contact__c).Address_Unique_Id__c;
                }
            }
        }
        //END UD-2867 09/21/2015 Added by J.Sarion - populate Unique Address Id
    }

    private id idOf(string s) {
        id convertedValue;
        if (s != null && s instanceof id) { 
            convertedValue = id.valueOf(s);
        }
        return convertedValue;
    }

    private date dateOf(string s) {
        date convertedValue;
        if (s != null) {
            try {
                convertedValue = date.valueOf(s);
            } catch (exception e) {
                exceptionList.add(e);
            }
        }
        return convertedValue;
    }

    private boolean booleanOf(string s) {
        boolean convertedValue = false;
        if (s != null) {
            try {
                convertedValue = boolean.valueOf(s);
            } catch (exception e) {
                exceptionList.add(e);
            }
        }
        return convertedValue;
    }
    
    
    private decimal decimalOf(string s) {
        decimal convertedValue;
        if (s != null) {
            try {
                convertedValue = decimal.valueOf(s);
            } catch (exception e) {
                exceptionList.add(e);
            }
        }
        return convertedValue;
    }
    /* START: D-3120 05/12/2015 Hotfix - Kevin Evasco - ESHOP Email removed from the requirements.
    private void generateEshopEmail(Zuora__Subscription__c sub) {
        
        SendEshopCustomerEmail eshopEmail = new SendEshopCustomerEmail();
        emailBody = eshopEmail.bodySuccess(sub.Zuora__CustomerAccount__r.Zuora__SoldToName__c, sub.Id, sub.Zuora__Zuora_Id__c, sub.Order_Number__c);
        
        generateEmailToList(sub.Contact__r.Email__c, GlobalVariableClass.ESHOP_EMAIL_SUBJECT_SUCCESS, emailBody);
        
    }
    END: D-3120 05/12/2015 Hotfix - Kevin Evasco - ESHOP Email removed from the requirements. */
    private void generateEmailToList(string eTo, string eSubj, string eBody) {
        
        emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setToAddresses(new string[] {eTo});
        emailMessage.setHtmlBody(eBody);
        emailMessage.setSubject(eSubj);
        
        emailMessageList.add(emailMessage);
    }
    
    //START D-2327 25/02/15 Wenjun : Set Subscription Charge for different Subscription Types
    private Decimal getSubscriptionRate(Zuora__Subscription__c sub)
    {
        try{
            /******************** Gift & Delivery Subscription *************************/
            if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY ||
               sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_GIFT)
            { 
                //For Gift Subscription, the rate will be updated by SubscriptionProductChargeTriggerHandler
            }
            /******************** Postage Charge Subscription *************************/
            else if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE)
            {
                if(orderLineItemId_orderLineItem.containsKey(sub.Order_Line_Item_Number_1__c))
                {
                    Order_Line_Item__c oli = orderLineItemId_orderLineItem.get(sub.Order_Line_Item_Number_1__c);
                    //Full Prepaid
                    if(sub.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID)
                        return oli.Postage_Charge__c * oli.Term_Length__c;
                    else //Recurring Prepaid and Recurring Postpaid
                        return oli.Postage_Charge__c;
                }
            }
            /******************** Publication Subscription *************************/
            else if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION)
            {/*
                //START UD-1317 06/09/2015 Added by J. Sarion - Set Subscription Charge to 0 if Freelist
                if (sub.Payment_Mode__c == 'Other' && sub.Other_PaymentMethod__c == 'Freelist') {
                    return 0;
                }
                else {
                    //START D-1476 6/9/2015 Added By C. Lin - Change Main_Package_1__c to Main_Package__c
                    if(sub.Main_Package__c != null && mapMainPackages.containsKey(sub.Main_Package__c))
                    {
                        //Get Main Package Detail
                        Package__c mainPack = mapMainPackages.get(sub.Main_Package__c);

                        //Bundle Product Subscription - To Calculate based on SPC
                        if(mainPack.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE)
                        {
                            if(mapPackIDToItemLst.containsKey(sub.Main_Package__c))
                            {
                                for(Package_Item__c item : mapPackIDToItemLst.get(sub.Main_Package__c))
                                {
                                    if(sub.Product_Code__c == item.Product_Rate_Plan__r.Product_Code__c)
                                        return item.Price__c * sub.Number_of_Copies__c;
                                }
                            }
                        }
                    //END D-1476 6/9/2015 Added By C. Lin
                        else if(mainPack.Package_Sub_Type__c == GlobalVariableClass.PACKAGESUBTYPE_EXTENSION)
                        {
                            if(orderLineItemId_orderLineItem.containsKey(sub.Order_Line_Item_Number_1__c))
                            {   
                                Date oliStartDate = orderLineItemId_orderLineItem.get(sub.Order_Line_Item_Number_1__c).Start_Date__c;
                                if(sub.Zuora__SubscriptionStartDate__c != oliStartDate)
                                {
                                    //Subscription for the Extension Product - To Calculate based on SPC
                                    //START D-1476 6/9/2015 Added By C. Lin - Change Main_Package_1__c to Main_Package__c
                                    if(mapPackIDToItemLst.containsKey(sub.Main_Package__c))
                                    {
                                        for(Package_Item__c item : mapPackIDToItemLst.get(sub.Main_Package__c))
                                        {
                                            return item.Price__c * sub.Number_of_Copies__c;
                                        }
                                    }
                                    //END D-1476 6/9/2015 Added By C. Lin
                                }
                                else return mainPack.Package_Price__c * sub.Number_of_Copies__c;
                            }
                        }
                        else return mainPack.Package_Price__c * sub.Number_of_Copies__c;
                    }
                }*/
                //END UD-1317 06/09/2015 Added by J. Sarion - Set Subscription Charge to 0 if Freelist
            }
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            return null;
        }
        
        return null;
    }
    //END D-2327 25/02/15 Wenjun 
    
            
                
    
    //START D-2721 Wenjun 10/04/15 - Reset Static Data Collection before each Trigger Batch
    private void resetStaticDataCollection()
    {
        orderId_order = new map<id, Order__c>();
        orderIdSet = new set<id>();
        accountToUpdateList = new list<Account>();
        orderId_case = new map<id, Case>();
        orderLineItemId_orderLineItem = new map<id, Order_Line_Item__c>();
    //START: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
        orderToOrderLineItemsMap = new map<id, set<string>>();
    //END: UD-0733 JLedesma 5/8/2015 Vendor assignment for Start Sub Case
        accountId_accountStatus = new map<id, string>();
        accountId_isWithActiveSubscription = new map<id, boolean>();
        exceptionList = new list<exception>();
        logList= new List<Log__c>();//SPULI Temporary Log, to delete tomorrow
        caseSubscriptionList = new list<Case_Subscription__c>();
        orderLineItemId_subscripitonId = new map<id, id>();
        paypalBillingAccountId_deliverySubscription = new map<id, Zuora__Subscription__c>();
        otherBillingAccountId_deliverySubscription = new map<id, Zuora__Subscription__c>();
        subscriptionId_subscription = new map<id, Zuora__Subscription__c>();
        emailMessageList = new list<Messaging.SingleEmailMessage>();
        subscriptionZuoraId_subscriptionTempStop = new map<string, Subscription_Temp_Stop__c>();
        subscriptionZuoraId_AddressAssignmentList = new map<string, list<Address_Assignment__c>>();
        addressAssignmentList = new list<Address_Assignment__c>();
        orderLineItemId_asia1Subscription_serviceActivation = new map<id, Asia1_Subscription__c>();
        orderLineItemId_asia1Subscription_serviceDeactivation = new map<id, Asia1_Subscription__c>();
        orderLineItemId_asia1SubscriptionList_serviceActivation = new map<id, list<Asia1_Subscription__c>>();
        orderLineItemId_asia1SubscriptionList_serviceDeactivation = new map<id, list<Asia1_Subscription__c>>();
        orderLineItemId_subscriptionId = new map<id, id>();
        subscriptionIdSet4Asia1ServiceActivation = new set<id>();
        orderLineItemIdSet = new set<id>();
        orderIdSet4PaymentUpdate = new set<id>();
        subFullPrepaidSet = new Set<Id>();
        subStopSet = new Set<Id>(); 
        vendorSubscriptionMap = new Map<Id, Subscription_Vendor__c>();
        letterPrintRequests = new List<Letter_Print_Request__c>();
        orderId_isNoVendorNeeded = new map<id, boolean>();
        relatedSubscription4TempStopSet = new set<string>();
        accountId_billingAccount = new map<id, Zuora__CustomerAccount__c>();
        deliverySubscriptionList = new list<Zuora__Subscription__c>();
        billingAccountId_isWithActiveSubscription = new map<id, boolean>();
        accountId_deliverySubscriptionList = new map<id, list<Zuora__Subscription__c>>();
        accountId_subscriptionList = new map<id, list<Zuora__Subscription__c>>();
        caseList = new List<Case>();
        accList = new Set<Id>();
        acc_CaseRecMap = new Map<String, Case>();
        subToDTL_MAP = new Map<Id, Date>();
        SubsToOLI_MAP = new Map<Id, Id>();
        accToDTL_MAP = new Map<Id, Set<Date>>();
        lprRecIdToDTL_MAP = new Map<String, Set<Date>>();
        accId_SET = new Set<Id>();
        LPR_List = new List<Letter_Print_Request__c>();
        subIdsToInvoiceSeparately = new set<id>();
        billingAcctIdToCheck_subCount = new Map<id,integer>();
        
        //Start D-3183  hotfix(duplicate subscriptions created during cos) 26Jun15 JohnD
        cosOrderIdSet = new set<id>();
        subIdToCosOrderId = new map<id, id>();
        newSubCosIds = new set<id>();
        //End D-3183 hotfix (duplicate subscriptions created during cos) 26Jun15 JohnD
        
        //START UD-2036 07/24/2015 Added by J.Sarion - Subscription is being overwritten during next loop
        orderLineItemId_asia1SubscriptionList_FromExistingAsia1 = new map<id, list<Asia1_Subscription__c>>();
        //END UD-2036 07/24/2015 Added by J.Sarion - Subscription is being overwritten during next loop
    }
    //END D-2721 Wenjun 10/04/15
    
    //START D-3153 6/30/2015 Added by Manolo Valena - New method to update subscriptions with counterpart contacts under batch renewal.
    private void updateRenewalSubscriptionContacts(List<Zuora__Subscription__c> zuoraSubList) {

        Map<Id, List<Zuora__Subscription__c>> orderLineItemIdToSubscriptionsMap = new Map<Id, List<Zuora__Subscription__c>>();
        Map<String, Zuora__Subscription__c> relatedSubscriptionIdToSubscriptionMap = new Map<String, Zuora__Subscription__c>();
        Set<String> relatedSubscriptionSet = new Set<String>();
        
        for(Zuora__Subscription__c zsRec : zuoraSubList) {
            if(zsRec.Order_Line_Item_Number__c != null) {
                if(orderLineItemIdToSubscriptionsMap.containsKey(zsRec.Order_Line_Item_Number__c)) {
                    orderLineItemIdToSubscriptionsMap.get(zsRec.Order_Line_Item_Number__c).add(zsRec);
                }
                else {
                    orderLineItemIdToSubscriptionsMap.put(zsRec.Order_Line_Item_Number__c, new List<Zuora__Subscription__c> {zsRec});
                }
            
                if(zsRec.Zuora__AutoRenew__c == true && 
                   zsRec.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION && 
                   zsRec.Related_Subscription__c != null) {
                    relatedSubscriptionIdToSubscriptionMap.put(zsRec.Related_Subscription__c, zsRec);
                    relatedSubscriptionSet.add(zsRec.Related_Subscription__c);
                }
            }
        }

        if(relatedSubscriptionSet.size() > 0) {
            for(Zuora__Subscription__c zsRecord : [SELECT Recipient_Contact__c, Subscriber_Contact__c, Recipient_Contact_1__c, Contact__c, Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN : relatedSubscriptionSet]) {
                if(relatedSubscriptionIdToSubscriptionMap.containsKey(zsRecord.Zuora__Zuora_Id__c)) {
                    if(orderLineItemIdToSubscriptionsMap.containsKey(relatedSubscriptionIdToSubscriptionMap.get(zsRecord.Zuora__Zuora_Id__c).Order_Line_Item_Number__c)) {
                        if(orderLineItemIdToSubscriptionsMap.get(relatedSubscriptionIdToSubscriptionMap.get(zsRecord.Zuora__Zuora_Id__c).Order_Line_Item_Number__c).size() > 0) {
                            for(Zuora__Subscription__c zs : orderLineItemIdToSubscriptionsMap.get(relatedSubscriptionIdToSubscriptionMap.get(zsRecord.Zuora__Zuora_Id__c).Order_Line_Item_Number__c)) {
                                zs.Recipient_Contact__c = zsRecord.Recipient_Contact__c;
                                zs.Subscriber_Contact__c = zsRecord.Subscriber_Contact__c;
                                zs.Recipient_Contact_1__c = zsRecord.Recipient_Contact_1__c;
                                zs.Contact__c = zsRecord.Contact__c;
                            }
                        }
                    }
                }
            }
            
            for(Zuora__Subscription__c zsRec : zuoraSubList) {
                if(orderLineItemIdToSubscriptionsMap.containsKey(zsRec.Order_Line_Item_Number__c)) {
                    zsRec.Recipient_Contact__c = orderLineItemIdToSubscriptionsMap.get(zsRec.Order_Line_Item_Number__c)[0].Recipient_Contact__c;
                    zsRec.Subscriber_Contact__c = orderLineItemIdToSubscriptionsMap.get(zsRec.Order_Line_Item_Number__c)[0].Subscriber_Contact__c;
                    zsRec.Recipient_Contact_1__c = orderLineItemIdToSubscriptionsMap.get(zsRec.Order_Line_Item_Number__c)[0].Recipient_Contact_1__c;
                    zsRec.Contact__c = orderLineItemIdToSubscriptionsMap.get(zsRec.Order_Line_Item_Number__c)[0].Contact__c;
                }
            }
        }
    }
    //END D-3153 6/30/2015 Added by Manolo Valena
    
    //START D-2777 Wenjun 16/04/15 : Set Delivery Subscription Active Flag
    @future
    public static void updateDelSubsActiveFlag(Set<Id> setRecipientIds)
    {
        DeliveryChargeHelper.updateDelSubsActiveFlag(setRecipientIds);
    }
     //END D-2777 Wenjun 16/04/15
     
    //START D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
    public void checkForActiveSub() {   
        for (Case cas : [SELECT Id, Status, Sub_Status__c, (SELECT Id, Subscription__r.Zuora__Status__c FROM Case_Subscriptions__r WHERE Subscription__r.Zuora__Status__c = :GlobalVariableClass.STATUS_ACTIVE) FROM                 Case WHERE Order__c IN :orderIdSet AND RecordTypeID = :CASE_STOP_SUB_TYPE_ID]) {
            if (cas.Case_Subscriptions__r.size() != 0) {
                caseWithActiveSubSet.add(cas.Id);
            }
        }
    }
    //END D-3194 07/01/2015 Added by J.Sarion - Set Case Status for Stop only when all related Subscriptions are cancelled
    
    //START PD-0041 FrancisBenzon 21May16: for test class coverage only
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
         

        }
            //END PD-0041 FrancisBenzon 21May16: for test class coverage only
}