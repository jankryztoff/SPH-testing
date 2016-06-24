/**
 * History: D-1757 14/01/2015 Wenjun : Postage Charge
 * History: Code Review(Null in where clause causes full table scans - 100K Record Issue Limit) 17-Feb-2015 Raviteja 
 **/ 
global class StopSubOrderEntryDirectController{
    public List<Order_Line_Item__c> existingOLIList {get; set;}
    public Date dateToday {get; set;}
    public static StopSubOrderEntryDirectController controller = new StopSubOrderEntryDirectController();
    public Boolean isBundle {get; set;} 
    public Order__c order {get; set;}
    public Case objcase {get;set;}
    public String myId {get; set;}       
    public List<Zuora__Subscription__c> subscriptionResultList { get; set; } 
    public List<Asia1_Subscription__c> asiaRelatedList { get; set; }
    public Account account {get; set;}
    public Account accountBackUp {get; set;}
    public List<String> subscriptionId = new List<String>();
    AsiaRelatedListWrapper asiaWrapper;    
    public date date1 {get; set;}
    public List<Order_Line_Item__c> orderLineItemRecordList;
    public Boolean existingFlag = false;
    RetentionEligibility retEligibile= new RetentionEligibility();
    public Boolean retention {get; set;}
    public Boolean Send_to_Retention {get; set;}
    public List<Package_Access_Flag__c> pafList;
    public Map<String, Zuora__SubscriptionProductCharge__c> subProdChargeMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    public Map<String, zqu__ProductRatePlan__c> prodRatePlanMap = new Map<String, zqu__ProductRatePlan__c>();
    public Map<String, zqu__ProductRatePlanCharge__c> prodRatePlanChargeMap = new Map<String, zqu__ProductRatePlanCharge__c>();
    public Map<String, Publication__c> publicationMap = new Map<String, Publication__c>();
    public Map<String, OrderLineItemWrapper> copyRelatedSubscriptionMap = new Map<String, OrderLineItemWrapper>();
    public Map<String, SubscriptionWrapper> allSubscriptionMap = new Map<String, SubscriptionWrapper>();
    public Map<String, List<Order_Line_Item__c>> existingOliMap = new Map<String, List<Order_Line_Item__c>>();
    public Map<Id, Decimal> pendingcopiesmap{get;set;}
    public Map<Publication__c, Decimal> givencopiesmap{get;set;}
    Set<Id> ratePlanCharge = new Set<Id>();
    Map<Id, List<Package_Item__c>> packageIdToPackageItemsMap = new Map<Id, List<Package_Item__c>>();
    Map<Id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanIdToRatePlanChargesMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>(); 
    Map<String, Date> mapPubIdtoPubRecord = new Map<String, Date>();
    public Publication__c publicationRec {get; set;}
    // ------------  Order Fields  ------------ //
    public String caseRecordType {get; set;}
    public String category {get; set;}
    public String subCategory {get; set;}
    public String status {get; set;}
    public String caseOwner {get; set;}
    public String orderNumber {get; set;}
    public String subscriberAccount {get; set;}
    public String recipientName {get; set;}
    
    //START D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
    public Set<Id> oliIdForBundleSet = new Set<Id>();
    public Set<Id> subIdForBundleSet = new Set<Id>();
    public String orderType1 = 'Stop';
    //END D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
    
    //START UD-3911 FrancisBenzon 8Apr16 updated list
    //START UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error
    List<Order_Line_Item__c> cosOliList = new List<Order_Line_Item__c>();
    Set<String> COSOrderTypes = new Set<String>{GlobalVariableClass.COS_PACKAGE, GlobalVariableClass.COS_QUANTITY};
    Boolean hasExistingCOSOrder = false;
    String err_ExistingCOSOrder = GlobalVariableClass.ERR_ExistingCOSOrder;
    //END UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error
    //END UD-3911 FrancisBenzon 8Apr16 updated list
  //START:D-3330 8/17/15 Added by Manolo Valena
  public Map<Id, Id> subToOLIMap = new Map<Id, Id>();
  //END:D-3330 8/17/15 Added by Manolo Valena
  
    //Start VPernicia D-0077 5/4/2015
    public Boolean isError {get; set;} 
    //End VPernicia D-0077 5/4/2015
    String parentCaseId;
    //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
    Map<String, Case_Subscription__c> subNameToCOACaseSubMap = new Map<String, Case_Subscription__c>();
    //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
    //START UD-2738 Wenjun 21/Sep/15 : No longer needed
    /*
    //START D-3224 Rebuild AddedBy FrancisBenzon : variable for error message
    public final String stopTargetDateError = GlobalVariableClass.invoiceTargetDateForStop; //D-3224 change errormessage
    //START D-3224 Rebuild AddedBy FrancisBenzon : variable for error message
    */
    //END UD-2738 Wenjun 21/Sep/15 : No longer needed
    //START: UD-3852 2-24-2016 Added by Kristine Balaoing - added variables for admin fee charging
    Map<Id, Boolean> oliToIsAdminFeeCharged = new Map<Id, Boolean>();
    //END: UD-3852 2-24-2016 Added by Kristine Balaoing
    
    //START UD-3088 3/30/2016 Added by J.Sarion
    Contact con = new Contact();
    String contactId; 
    //END UD-3088 3/30/2016 Added by J.Sarion
    
    // ------------  Subscription Wrapper  ------------ //
    public class SubscriptionWrapper{ 
        public Boolean enableAddButton {get; set;}      
        public String id {get; set;}
        public String zuoraId {get; set;}
        public String subscription {get; set;}
        public String type {get; set;}
        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public Date contractEnd {get; set;}
        public Decimal quantity {get; set;}
        public String dowPattern {get; set;}
        public String recipientName {get; set;}
        public String recipientNumber {get; set;}
        public String billingAccount {get; set;}
        public String ratePlan {get; set;}  
        public String tempStartDate {get; set;}
        public String tempEndDate {get; set;}    
        public String tempContractEnd {get; set;}
        public Date earliestStopDate {get; set;}
        public String orderNumber {get; set;}
        public String packageType {get; set;}
        public String mainPackage {get; set;}
        public String mainPackageName {get; set;}
        public String bundledWith {get; set;}
        public String subscriptionType {get; set;}
        public String packageBillingType {get; set;}
        public String packageSubType {get; set;}
        
        //START: D-4097 12/17/15 Added by Manolo Valena
        public String recipientId {get; set;}
        //END: D-4097 12/17/15 Added by Manolo Valena
        
    //START:D-3344 8/10/15 Added by Manolo Valena
        public String promotion {get; set;}
    //END:D-3344 8/10/15 Added by Manolo Valena
        //START: UD-3852 2-24-2016 Added by Kristine Balaoing - added variables for admin fee charging of bundled subscriptions
        public String orderLineItem1 {get; set;}
        //END: UD-3852 2-24-2016 Added by Kristine Balaoing
    }
    
    SubscriptionWrapper SubscriptionWrapper {get; set;}    
    public List<SubscriptionWrapper> allSubscriptionResultList {get; set;}
    
    // ------------  Order Line Item Wrapper  ------------ //
    public class OrderLineItemWrapper{
        public String id {get; set;}
        public String OLIid {get; set;}
        public String zuoraId {get; set;}
        public Boolean enableRemoveButton {get; set;}
        public String subscription {get; set;}
        public Date earliestStopDate {get; set;}
        public Date stopRequestDate {get; set;}
        public String terminationReason {get; set;}
        public Decimal refund {get; set;}
        public Decimal adminFee {get; set;}
        public Boolean feeWaiver {get; set;}
        public Boolean feeOverride {get; set;}
        //START UD-0364 4/7/2015 MGaelo added feeOverrideAmount 
        //START:D-2795 5/18/15 Added by Manolo Valena - Updated from Decimal to String
        public String feeOverrideAmount {get; set;}
        //END:D-2795 5/18/15 Added by Manolo Valena
        public Decimal feeOverrideAmountHidden { get; set; }
        public Boolean feeOverrideCheck {get; set;}
        //END UD-0364 4/7/2015 MGaelo added feeOverrideAmount 
        public String overrideReason {get; set;}
        public Boolean suppressNotification {get; set;}
        public String orderNumber {get; set;}
        public String packageType {get; set;}
        public String mainPackageId {get; set;}
        public String mainPackageName {get; set;}
        public Date contractEndDate {get; set;}
        public Boolean prompt {get; set;}
        public String bundledWith {get; set;}
        public String subscriptionType {get; set;}
        public Boolean inputState {get; set;}
        public Order_Line_Item__c oliFieldAccess {get; set;}
        public Integer copiesgiven{get;set;}
        public Decimal copiesmissed{get;set;}
        public Decimal copiespending1{get;set;}
        public Decimal copiespending2{get;set;}
        public Decimal amountpaid{get;set;}
        public Decimal percopyrate{get;set;}
        public Decimal others {get;set;}
        public String publication1 {get; set;}
        public String publication2 {get; set;}
    
    //START:D-3344 8/10/15 Added by Manolo Valena
    public Boolean underPromotion {get; set;}
    //END:D-3344 8/10/15 Added by Manolo Valena
    //START: UD-3852 2-24-2016 Added by Kristine Balaoing - added variables for admin fee charging for bundled subscriptions 
    public String oli1 {get; set;}
    //END: UD-3852 2-24-2016 Added by Kristine Balaoing
    }
    
    OrderLineItemWrapper oLineWrapper {get; set;}
    public List<OrderLineItemWrapper> relatedSubscriptionResultList {get; set;}
    //public List<OrderLineItemWrapper> copyRelatedSubscriptionList {get; set;}
    public List<OrderLineItemWrapper> deletedSubscriptionList {get; set;}
    public List<Publication__c> publications{get;set;}
    Public String orderId;
    // ------------  Asia Related List Wrapper  ------------ //
    public class AsiaRelatedListWrapper{
        public String id {get; set;}
        public String userId {get; set;}
        public String serviceFlag {get; set;}
        public String status {get; set;}
        public Decimal quantity {get; set;}
        public String asiaSubscription {get; set;}
    }
    public List<AsiaRelatedListWrapper> asiaResultList {get; set;}    
    
    /* Description: Method constructor for class.
     * Parameter:
     * Return:
     */
    
    //START UD-2738 Wenjun 21/Sep/15 : Code Optimization - No Longer Used
    /*
    //Start: UD-0393 05/04/2015 James - add validation between stop request date and last invoice date
    public boolean passedInvoiceValidation = true;
    public Datetime targetDate;
    //End: UD-0393 05/04/2015 James
    */
    //END UD-2738 Wenjun 21/Sep/15 
    
    public StopSubOrderEntryDirectController(){   
        //START UD-3088 3/30/2016 Added by J.Sarion - get contact
        system.debug('>>>>>contactId ' + contactId);
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        system.debug('>>>>>contactId ' + contactId);
        //system.assertequals('contactId ' + contactId, 'parentCaseId ' + parentCaseId);
        if(contactId != '' && contactId != null) {
            //system.assertequals('>>>>> 123', '>>>>>qwe');
            con = [SELECT Id, Billing_Indicator__c, Recipient_Indicator__c FROM Contact WHERE Id = :contactId];
        }
        //END UD-3088 3/30/2016 Added by J.Sarion - get contact
        
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
        if (parentCaseId != null) {
            string tmp = parentCaseId;
            tmp.toLowerCase();
            
            if (tmp == 'null') {
                parentCaseId = null;
            }
        }
        //system.assertequals('>>>>> 123', '>>>>>qwe');
        deletedSubscriptionList = new List<OrderLineItemWrapper>();
        relatedSubscriptionResultList = new List<OrderLineItemWrapper>();
        retention = false;
        dateToday = date.today();                                     
        isBundle = true;                 
        getAccount();
        getSubscriptions();   
        pendingcopiesmap = new Map<Id, Decimal>();    
        givencopiesmap =  new Map<Publication__c, Decimal>(); 
               
    }   
    
    /*Description: Method for getting existing Order
     *Parameter:
     *Return:
     */
    public void getOrder(){
        orderId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ORDERID);
        try{
        //Start 04/07/2015 UD-0386 - UD-0782  M.Valena - James
        order = [SELECT id, name, owner.name, account__c, status__c, case_record_type__c, category__c, sub_category__c, Eligible_for_Retention__c, Send_to_Retention__c, Parent_Case__c
                 FROM Order__c
                 WHERE account__c =: account.id  AND case_record_type__c =: GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION 
                 AND status__c =: GlobalVariableClass.STATUS_DRAFT];
                 //OR status__c =: GlobalVariableClass.STATUS_PENDING)];
        //End 04/07/2015 UD-0386 - UD-0782 - M.Valena - James
        orderId = order.id;  
        } catch(Exception e){
            system.debug('No drafted order.');
        }
        if(order == null){
            if(orderId == null){
                setOrder();
            } else {               
                order = [SELECT id, name, owner.name, account__c, status__c, case_record_type__c, category__c, sub_category__c, 
                         Eligible_for_Retention__c, Send_to_Retention__c, Parent_Case__c
                         FROM Order__c
                         WHERE id =: orderId];
                retention = order.Eligible_for_Retention__c;
                Send_to_Retention = order.Send_to_Retention__c;
                getOLI(); 
            }
        } else {
            retention = order.Eligible_for_Retention__c;
            Send_to_Retention = order.Send_to_Retention__c;
            getOLI();    
        }        
    }       
    
    /*Description: Method for getting existing Order Line Item record
     *Parameter:
     *Return:
     */
     //START UD-0364 4/14/2015 MGaelo Added Fee_Override_Amount__c
    public void getOLI(){
        existingOLIList = [SELECT id, name, subscription__r.name, subscription__c, earliest_stop_date__c, stop_request_date__c,
                           terminating_reason__c, amount_to_refund__c, admin_charge__c, fee_waiver__c, fee_override__c, Fee_Override_Amount__c,
                           override_reason__c, Suppress_Notification_Stop__c, main_package_type__c, Main_Package_ID__c,
                           order__c, subscription__r.order_number__c, Publication_1__c, Publication_2__c, Pending_Copies__c, Pending_Copies_2__c,
                           //START:D-3344 8/10/15 Added by Manolo Valena
               subscription__r.Promotion_1__c
               //END:D-3344 8/10/15 Added by Manolo Valena
               FROM Order_Line_Item__c
                           WHERE order__c =: order.id];               
     //END UD-0364 4/14/2015 MGaelo Added Fee_Override_Amount__c                                               
        for(Order_Line_Item__c existingOLine : existingOLIList){
            oLineWrapper = new OrderLineItemWrapper();
            oLineWrapper.oliFieldAccess = new Order_Line_Item__c(); 
            oLineWrapper.OLIid = existingOLine.id;
            oLineWrapper.id = existingOLine.subscription__c;
            oLineWrapper.subscription = existingOLine.subscription__r.name;
            oLineWrapper.oliFieldAccess.stop_request_date__c = existingOLine.stop_request_date__c;
            oLineWrapper.oliFieldAccess.terminating_reason__c = existingOLine.terminating_reason__c;
            //START UD-2226 8/4/2015 Added By C. Lin - refund amount cannot be null
      if(existingOLine.amount_to_refund__c != null){
        oLineWrapper.refund = existingOLine.amount_to_refund__c;
      }else{
        oLineWrapper.refund = 0;
      }
      //END UD-2226 8/4/2015 Added By C. Lin
            oLineWrapper.adminFee = existingOLine.admin_charge__c;
            oLineWrapper.feeWaiver = existingOLine.fee_waiver__c;
            oLineWrapper.feeOverride = existingOLine.fee_override__c;
            //START UD-0364 4/7/2015 MGaelo added feeOverrideAmount 
            //START:D-2795 5/18/15 Added by Manolo Valena - Added condition on when the feeOverrideAmount variable will be updated.
            if(existingOline.fee_override_amount__c != 0.00) {
                oLineWrapper.feeOverrideAmount = String.valueOf(existingOLine.fee_override_amount__c);
            }
            //END:D-2795 5/18/15 Added by Manolo Valena
            //END UD-0364 4/7/2015 MGaelo added feeOverrideAmount

      //START:D-3344 8/10/15 Added by Manolo Valena
      oLineWrapper.underPromotion = false;
      if(existingOline.subscription__r.Promotion_1__c != null) {
        oLineWrapper.underPromotion = true;
      }
      //END:D-3344 8/10/15 Added by Manolo Valena
      
            oLineWrapper.overrideReason = existingOLine.override_reason__c;
            oLineWrapper.suppressNotification = existingOLine.Suppress_Notification_Stop__c;
            oLineWrapper.enableRemoveButton = false;
            oLineWrapper.inputState = false;
            oLineWrapper.orderNumber = existingOLine.subscription__r.order_number__c;
            oLineWrapper.packageType = existingOLine.Main_Package_Type__c;
            oLineWrapper.mainPackageId = existingOLine.Main_Package_ID__c;  
            oLineWrapper.earliestStopDate = existingOLine.earliest_stop_date__c;              
            oLinewrapper.publication1 = existingOLine.Publication_1__c;
            oLinewrapper.publication2 = existingOLine.Publication_2__c;
            oLinewrapper.copiespending1 = existingOLine.Pending_Copies__c;
            oLinewrapper.copiespending2 = existingOLine.Pending_Copies_2__c;
            //oLineWrapper.stopRequestDate = existingOLine.stop_request_date__c;
            //copyRelatedSubscriptionList.add(oLineWrapper);
            copyRelatedSubscriptionMap.put(oLineWrapper.id, oLineWrapper);
            relatedSubscriptionResultList.add(oLineWrapper);
        }
        getRelatedAsia();
        existingFlag = true;
    }
    
    /*Description: Method for setting values for new Order record
     *Parameter:
     *Return:
     */
    public void setOrder(){
        string recordTypeId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_RECORDTYPE);
        try{
            RecordType recordType = [SELECT Name FROM RecordType WHERE Id =: recordTypeId];
            order = new Order__c();
            order.account__c = account.id;
            order.status__c = GlobalVariableClass.STATUS_NEW;
            order.case_record_type__c = recordType.Name;
            order.category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            order.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
            order.credit_balance__c = 0;
            order.delivery_charge__c = 0;
            order.monthly_delivery_charge_for_full_payment__c = 0;
            order.Parent_Case__c = parentCaseId;
            //START: D-0823 12/16/14 Added by April Banaag - to set order type
            order.Order_Type__c = 'Stop';
            //END: D-0823 12/16/14 Added by April Banaag - to set order type
        }catch(exception e){
            //errorhandling
        }
        
    }
    
    /*Description: Method for getting existing account.
     *Parameter:
     *Return:
     */
    public void getAccount(){
        try {            
            String accountId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ACCOUNTID);
            if(accountId != null){
                account = [SELECT name, id, total_credit_balance__c FROM Account WHERE id = :accountId];
            }
        } catch (Exception e) {
            system.debug('No account record selected');
        }
    }
    
    /*Description: Method for getting subscriptions of account and setting it to wrapper
     *Parameter:
     *Return:
     */
    public void getSubscriptions(){   
        Zuora__SubscriptionProductCharge__c subProdCharge = new Zuora__SubscriptionProductCharge__c();
        zqu__ProductRatePlan__c prodRatePlan = new zqu__ProductRatePlan__c();
        zqu__ProductRatePlanCharge__c prodRatePlanCharge = new zqu__ProductRatePlanCharge__c();
        Publication__c publicationRec = new Publication__c();
        //START D-4080 11/12/2015 Gdelrosario : added instanttiation for code review
        List <Publication__c> publication = new List<Publication__c>();
        //END D-4080 11/12/2015 added instanttiation for code review         
        Set<id> subscriptionIdSet = new Set<id>();
        Set<String> ratePlanName = new Set<String>();
        Set<String> ratePlanId = new Set<String>();
        Set<String> publicationCodeSet = new Set<String>();
        Set<Id> packIdSet = new Set<Id>();
        pafList = new List<Package_Access_Flag__c>();
        Set<String> SVCSet = new Set<String>();
        String ratePlan;
        //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
                                      
        allSubscriptionResultList = new List<SubscriptionWrapper>();
        //START D-1757 14/01/15 Wenjun: only retreive "Publication" subscriptions
        //Start UD-0782 04/07/2015 James - exclude expired subscriptions
        // Start UD-0912 04/23/2015 Arvin - Change query to include Evergreen Subscription. SUbscription End Date must include Null
        // Start UD-2564 9/3/2015 Karl Tan Added logic for display
        subscriptionResultList = [SELECT id, name, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Order_Number__c,
                                  Contract_End_Date_1__c , Zuora__Account__r.name, Zuora__CustomerAccount__r.name, Recipient_Contact__r.FirstName, 
                                  Recipient_Contact__r.LastName, Recipient_Contact__r.Mobile_Number__c, Bundled_With__c, Zuora__Zuora_Id__c,
                                  Main_Package_1__r.package_type__c, Main_Package_1__c, Main_Package_1__r.name,Frequency_1__c, Number_of_Copies__c,
                                  Subscription_Type_1__c, Main_Package_1__r.Billing_Type__c, Main_Package_1__r.Package_Sub_Type__c, Product_Code__c,
                                  //START:D-3330 8/17/15 Added by Manolo Valena
        // END UD-2564 9/3/2015 Karl Tan Added logic for display
                  //START:D-3344 8/10/15 Added by Manolo Valena
                  //START:UD-3143 10/26/2015 Added by Manolo Valena - Added Recipient_Contact__r.Recipient_Number__c.
                  //START: D-4097 12/17/15 Added by Manolo Valena
                  //START UD-3088 3/30/2016 Added by J.Sarion
                  Promotion_1__c, Order_Line_Item_Number_1__c, Recipient_Contact__r.Recipient_Number__c, Recipient_Contact__c, Contact__c 
                  //END UD-3088 3/30/2016 Added by J.Sarion
                  //END: D-4097 12/17/15 Added by Manolo Valena
                  //END:UD-3143 10/26/2015 Added by Manolo Valena
                  //END:D-3344 8/10/15 Added by Manolo Valena
                  //END:D-3330 8/17/15 Added by Manolo Valena
                  FROM Zuora__Subscription__c 
                                  WHERE Zuora__Account__c = :account.id AND Subscription_Type_1__c = : ConstantsSLB.getkeyid('SubTypePub')
                                  AND Zuora__Status__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE AND (Zuora__SubscriptionEndDate__c > today OR Zuora__SubscriptionEndDate__c = Null)];
        
        //system.debug('@@@MC1'+ account.id);
        //system.debug('@@@MC2'+ ConstantsSLB.getkeyid('SubTypePub'));
        //system.debug('@@@MC3'+ GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE);
        //system.debug('@@@MC4'+ Zuora__SubscriptionEndDate__c);

        system.debug('@@@subscriptionResultList'+subscriptionResultList);

        //END UD-0912 04/23/2015 Arvin
        //End UD-0782 04/07/2015 James
        //END D-1757 14/01/15 Wenjun
        for(Zuora__Subscription__c sub : subscriptionResultList){
            subscriptionIdSet.add(sub.id);
            packIdSet.add(sub.Main_Package_1__c);

      
      //START:D-3330 8/17/15 Added by Manolo Valena   
      subToOLIMap.put(sub.Id, sub.Order_Line_Item_Number_1__c);
      //END:D-3330 8/17/15 Added by Manolo Valena
        }
        //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
        caseSubList = [SELECT Id, Case__r.Effective_Date__c, Subscription__c, Case__r.CaseNumber, Case__r.RecordType.Name, Subscription__r.Name FROM Case_Subscription__c WHERE Case__r.Status =: GlobalVariableClass.STATUS_CLOSED AND Case__r.RecordType.Name = 'Change of Address/Vendor' AND Subscription__c IN :subscriptionIdSet Order by Case__r.Effective_Date__c ASC];

        for (Case_Subscription__c caseSub :caseSubList) {
            system.debug('>>>>>caseSub ' + caseSub);
            subNameToCOACaseSubMap.put(caseSub.Subscription__r.Name, caseSub);
        }
        //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
        //START SPH Code Review - 17-Feb-2015 Added by Raviteja - included remove(null) in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
        packIdSet.remove(null);
        //End SPH Code Review - 17-Feb-2015 Added by Raviteja 
        pafList = [SELECT Id, Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, No_of_Concurrent_Users__c, Package__c
                   FROM Package_Access_Flag__c WHERE Package__c IN :packIdSet];
         for(Package_Access_Flag__c psaf : pafList){
             SVCSet.add(psaf.Package_Service_Access_Flag__r.Name);
         }                                             
        
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c
                                                                       FROM Zuora__SubscriptionProductCharge__c 
                                                                       WHERE Zuora__Subscription__c IN :subscriptionIdSet];
        
        for(Zuora__SubscriptionProductCharge__c subProdCha : subProdChargeList){
            ratePlanName.add(subProdCha.Zuora__RatePlanName__c);
            subProdChargeMap.put(subProdCha.Zuora__Subscription__c, subProdCha);
        }
        
        // Start UD-0077 JohnD 22Mar15 added filter criteria to excluded deleted zproduct in the query
        List<zqu__ProductRatePlan__c> ratePlanList = [SELECT id, name, SubscriptionFrequency__c
                                                      FROM zqu__ProductRatePlan__c 
                                                      WHERE name IN :ratePlanName and zqu__ZProduct__r.zqu__Deleted__c = false];
        // End UD-0077 22Mar15 added filter criteria to excluded deleted zproduct in the query                                              
        
        for(zqu__ProductRatePlan__c ratePlanAccess : ratePlanList){
            ratePlanId.add(ratePlanAccess.id);
            prodRatePlanMap.put(ratePlanAccess.name, ratePlanAccess);
        }
        
        List<zqu__ProductRatePlanCharge__c> publicationCode = [SELECT publicationcode__c, zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c 
                                                               WHERE zqu__ProductRatePlan__c IN :ratePlanId];
        
        for(zqu__ProductRatePlanCharge__c pubCodeAccess : publicationCode){
            publicationCodeSet.add(pubCodeAccess.publicationcode__c);
            prodRatePlanChargeMap.put(pubCodeAccess.id, pubCodeAccess);
        }
        
        //START SPH Code Review - 17-Feb-2015 Added by Raviteja - included remove(null) in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
        publicationCodeSet.remove(Null);
        //End SPH Code Review - 17-Feb-2015 Added by Raviteja 

        publication = [SELECT ID, Name, earliest_start_date__c, publication_code__c FROM publication__c 
                       WHERE publication_code__c IN :publicationCodeSet];
                    
        for(Publication__c pub : publication){
            publicationMap.put(pub.publication_code__c,pub);
            publicationMap.put(pub.Name ,pub);
        }
                       
        for(Integer counter = publication.size() - 1; counter >= 0; counter--){
            if(publication[counter].publication_code__c == null){
                publication.remove(counter);
            }
        }
        // Start UD-2564 9/3/2015 Karl Tan Added logic for display
        List<Package_Item__c> packList = [Select ID, Name, Package__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__r.ProductCode__c FROM Package_Item__c WHERE Package__c =: packIdSet];
        
        Map<Id, List<Package_Item__c>> packageIdToPackItemMap = new Map<Id, List<Package_Item__c>>();
        
        for(Package_Item__c packItem : packList){
            if(packageIdToPackItemMap.containsKey(packItem.Package__c)){
                packageIdToPackItemMap.get(packItem.Package__c).add(packItem);
            }
            else{
                packageIdToPackItemMap.put(packItem.Package__c, new List<Package_Item__c> {packItem});
            }
        }       
        //system.assertequals('>>>>> 123', '>>>>>qwe');
        for(Zuora__Subscription__c sub : subscriptionResultList){
            //START UD-3088 3/30/2016 Added by J.Sarion - Check if from contact
            if(contactId !=  '' && contactId != null) {
                if(con.Recipient_Indicator__c) {
                    if(con.Billing_Indicator__c) {
                        if(sub.Recipient_Contact__c != con.Id && sub.Contact__c != con.Id)
                            continue;
                    }
                    else {
                        if(sub.Recipient_Contact__c != con.Id)
                            continue;
                    }
                }
                if(con.Billing_Indicator__c) {
                    if(sub.Contact__c != con.Id)
                        continue;
                }
            }
            //END UD-3088 3/30/2016 Added by J.Sarion - Check if from contact
            
            subscriptionWrapper = new SubscriptionWrapper();
            for(Package_Item__c pckItem: packageIdToPackItemMap.get(sub.Main_Package_1__c)){
                    if(pckItem.Product_Rate_Plan__r.zqu__ZProduct__r.ProductCode__c == sub.Product_Code__c) {
                        ratePlan = pckItem.Product_Rate_Plan__r.Name;
                    }
                
            }           
            
            if(subProdChargeMap.containsKey(sub.id)){
                subProdCharge = subProdChargeMap.get(sub.id);
                //ratePlan = subProdCharge.Zuora__RatePlanName__c;
                if(prodRatePlanMap.containsKey(subProdCharge.Zuora__RatePlanName__c)){
                    prodRatePlan = prodRatePlanMap.get(subProdCharge.Zuora__RatePlanName__c);
                   /* if(prodRatePlan.SubscriptionFrequency__c == '0'){
                        subscriptionWrapper.dowPattern = GlobalVariableClass.FREQUENCY_DEFAULT;
                    } else if(prodRatePlan.SubscriptionFrequency__c == '1'){
                        subscriptionWrapper.dowPattern = GlobalVariableClass.FREQUENCY_MONFRI;
                    } else if(prodRatePlan.SubscriptionFrequency__c == '2'){
                        subscriptionWrapper.dowPattern = GlobalVariableClass.FREQUENCY_FRISUN;
                    } else if(prodRatePlan.SubscriptionFrequency__c == '3'){
                        subscriptionWrapper.dowPattern = GlobalVariableClass.FREQUENCY_SATSUN;
                    } else {
                        subscriptionWrapper.dowPattern = '';
                    }*/
                    if(prodRatePlanChargeMap.containsKey(prodRatePlan.name)){
                        prodRatePlanCharge = prodRatePlanChargeMap.get(prodRatePlan.name);
                        if(publicationMap.containsKey(prodRatePlanCharge.publicationcode__c)){
                            publicationRec = publicationMap.get(prodRatePlanCharge.publicationcode__c);
                            subscriptionWrapper.earliestStopDate = publicationRec.earliest_start_date__c;
                        }
                    }
                }
            } else {
                ratePlan = '';
            }            
            subscriptionWrapper.dowPattern = sub.Frequency_1__c;
            // END UD-2564 9/3/2015 Karl Tan Added logic for display
            subscriptionWrapper.packageBillingType = sub.Main_Package_1__r.Billing_Type__c;
            subscriptionWrapper.packageSubType = sub.Main_Package_1__r.Package_Sub_Type__c;   
            subscriptionWrapper.mainPackageName = sub.Main_Package_1__r.name;            
            subscriptionWrapper.id = sub.id;
            subscriptionWrapper.subscription = sub.name;
            subscriptionWrapper.zuoraId = sub.Zuora__Zuora_Id__c;         
            subscriptionWrapper.type = sub.main_package_1__r.package_type__c; 
            subscriptionWrapper.endDate = sub.Zuora__SubscriptionEndDate__c;
            subscriptionWrapper.startDate = sub.Zuora__SubscriptionStartDate__c;
            subscriptionWrapper.contractEnd = sub.Contract_End_Date_1__c;                 
            subscriptionWrapper.quantity = sub.Number_of_Copies__c;            
            subscriptionWrapper.recipientName = sub.Recipient_Contact__r.firstname + ' ' + sub.Recipient_Contact__r.lastname;
            //START:UD-3143 10/26/2015 Added by Manolo Valena - Updated to have the recipient number instead of mobile number.
            subscriptionWrapper.recipientNumber = String.valueOf(sub.Recipient_Contact__r.Recipient_Number__c);
            //subscriptionWrapper.recipientNumber = sub.Recipient_Contact__r.Mobile_Number__c;
            //END:UD-3143 10/26/2015 Added by Manolo Valena
            subscriptionWrapper.billingAccount = sub.Zuora__CustomerAccount__r.name;
            subscriptionWrapper.ratePlan = ratePlan;
            subscriptionWrapper.enableAddButton = false;            
            subscriptionWrapper.packageType = sub.Main_Package_1__r.Package_Type__c;
            subscriptionWrapper.mainPackage = sub.Main_package_1__c;
            subscriptionWrapper.orderNumber = sub.Order_Number__c;
            subscriptionWrapper.bundledWith = sub.Bundled_With__c;
            subscriptionWrapper.subscriptionType = sub.subscription_type_1__c;
            
            //START: D-4097 12/17/15 Added by Manolo Valena
            subscriptionWrapper.recipientId = sub.Recipient_Contact__c;
            //END: D-4097 12/17/15 Added by Manolo Valena
            
      //START:D-3344 8/10/15 Added by Manolo Valena
      subscriptionWrapper.promotion = sub.Promotion_1__c;
      //END:D-3344 8/10/15 Added by Manolo Valena
      //START: UD-3852 2-24-2016 Added by Kristine Balaoing - added variables for admin fee charging for bundled subscriptions
      subscriptionWrapper.orderLineItem1 = sub.Order_Line_Item_Number_1__c;
      //END: UD-3852 2-24-2016 Added by Kristine Balaoing
      
            allSubscriptionResultList.add(SubscriptionWrapper);
            allSubscriptionMap.put(subscriptionWrapper.id, subscriptionWrapper);
        }        
        
        if (subscriptionResultList.size() == 0){
            subscriptionResultList = null;
        }
    }
    
    // START : UD-0386 3/25/2015 Alyana Navarro - Code for preparing data and validating if there is open case for sub
    public String errorMessage;
    public List<Order_Line_Item__c> orderLineItemList;
    public List<Case_Subscription__c> caseSubList;
    public List<Case> caseList;
    
    public void getExisitingRelatedRecords(){
        caseList = new List<Case>();
        caseSubList = new List<Case_Subscription__c>();
        orderLineItemList = new List<Order_Line_Item__c>();     
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();     
        
    //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
    //START UD-2647 09/09/15 RReyes - added void in condition
        caseList = [SELECT id, RecordType.Name, AccountId, Subscription_Name__r.Name, Order__c, CaseNumber
                    FROM Case 
                    WHERE (Status !=: GlobalVariableClass.STATUS_CLOSE AND Status !=: GlobalVariableClass.STATUS_CLOSED AND Status !=: GlobalVariableClass.STATUS_VOID) AND AccountId =: account.id AND RecordType.Name != 'Change of Address/Vendor'];
    //END UD-2647 09/09/15 RReyes - added void in condition
    //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription

        for(Case caseRec : caseList){
            caseIdSet.add(caseRec.id);
            orderIdSet.add(caseRec.Order__c);
        }

        caseSubList = [SELECT id, name, Case__c, Case__r.CaseNumber, Case__r.RecordType.Name, Subscription__r.Name 
                       FROM Case_Subscription__c 
                       WHERE Case__c =: caseIdSet];             
        
        orderLineItemList = [SELECT id, name, Subscription__r.Name, Subscription_Name__c, Case__r.CaseNumber, Case__r.RecordType.Name 
                             FROM Order_Line_Item__c 
                             WHERE Order__c IN: orderIdSet];               
    }
    
    public Boolean isNoOpenCaseForSub(String subName){
        errorMessage = '';
        Boolean flag = true;                
        
        for(Order_Line_Item__c orderLineItem : orderLineItemList){
            if(subName == orderLineItem.Subscription__r.Name || subName == orderLineItem.Subscription_Name__c){
                flag = false;
                errorMessage = 'There is an open case ' + orderLineItem.Case__r.CaseNumber + ' of type ' + orderLineItem.Case__r.RecordType.Name +'. Please complete or cancel the open case to proceed the request.';
                break;
            }
        }
        
        if(flag){
            for(Case_Subscription__c caseSub : caseSubList){
                if(subName == caseSub.Subscription__r.Name){
                    flag = false;
                    errorMessage = 'There is an open case ' + caseSub.Case__r.CaseNumber + ' of type ' + caseSub.Case__r.RecordType.Name +'. Please complete or cancel the open case to proceed the request.';
                    break;
                }
            }
        }
        
        if(flag){
            for(Case caseRec : caseList){
                if(subName == caseRec.Subscription_Name__r.Name){
                    flag = false;
                    errorMessage = 'There is an open case ' + caseRec.CaseNumber + ' of type ' + caseRec.RecordType.Name +'. Please complete or cancel the open case to proceed the request.';
                    break;
                }
            }
        }
        
        return flag;
    }
    // END : UD-0386 3/25/2015 Alyana Navarro
    
    /*Description: Method for getting selected subscription and setting it to wrapper
     *Parameter:
     *Return:
     */
    public void setSubscriptionRecords(){
        getExisitingRelatedRecords(); // START-END : UD-0386 3/27/2015 Alyana Navarro - Call method that query data.
        Integer counter = 0;      
        Package__c packageType;
    
    //START:D-3330 8/18/15 Added by Manolo Valena
    Map<Id, List<Publication__c>> bundlePublications = new Map<Id, List<Publication__c>>();
    //END:D-3330 8/18/15 Added by Manolo Valena
        //START UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error     
        String accountId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ACCOUNTID);
        //START UD-3911 FrancisBenzon 9Apr16 : consider if case not void
        /*cosOrderList = [Select Id, Name From Order__c
                        Where Order_Type__c IN :COSOrderTypes
                        AND Account__c = :accountId
                        AND Subscription__c = :myId];*/   

        try
        {
            cosOliList = [Select Id From Order_Line_Item__c Where Order__r.Order_Type__c IN :COSOrderTypes
                        and Order__r.Subscription__c = :myId and Case__r.Status != :GlobalVariableClass.STATUS_VOID 
                        and Order__r.Account__c = :accountId
                        and Order__r.Status__c != 'Void']; //START/END Fritz for PD-0184
                        //Start/End UD-3911  14Apr16 FrancisBenzon :Update account
        }catch(exception e) {           
            cosOliList = new List<Order_Line_Item__c>();
        }
        
        if(cosOliList.size() > 0)
        {           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(err_ExistingCOSOrder)));
            return;
        }
        //END UD-3911 FrancisBenzon 9Apr16 : consider if case not void
        //END UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error
        try {         
            Zuora__Subscription__c subscription = [SELECT id, name, Main_Package_1__r.Package_Type__c, Main_Package_1__c, Subscription_Type_1__c,
                                               Main_Package_1__r.name, Order_Number__c, Contract_End_Date_1__c, Bundled_With__c, Zuora__Zuora_Id__c,
                         //START:D-3330 8/18/15 Added by Manolo Valena
                         Order_Line_Item_Number_1__c
                         //END:D-3330 8/18/15 Added by Manolo Valena
                                               FROM Zuora__Subscription__c WHERE id = :myId];
            publications = getPublication12(subscription);
            
            String publication1;
            String publication2;
            //D-0881 Changed elseif from == to >=
            if(publications.size() == 1){
                publication1 = publications[0].name;
            }else if(publications.size() >= 2){
                publication1 = publications[0].name;
                publication2 = publications[1].name;
            }
            
      //START:D-3330 8/18/15 Added by Manolo Valena
      bundlePublications = getPublicationsBundle(subscription);
      //END:D-3330 8/18/15 Added by Manolo Valena

            try{
                packageType = [SELECT Package_Type__c, Billing_Type__c FROM Package__c WHERE id =: subscription.Main_Package_1__c];
                for(SubscriptionWrapper sub : allSubscriptionResultList){

                    oLineWrapper = new OrderLineItemWrapper();
                    //START: UD-3852 2-24-2016 Added by Kristine Balaoing - added variables for admin fee charging of bundled subscriptions
                    oLineWrapper.oli1 = sub.orderLineItem1;
                    //END: UD-3852 2-24-2016 Added by Kristine Balaoing
                    system.debug('sample ' + sub.orderNumber + ' ' + subscription.Order_Number__c + ' ' + sub.bundledWith + ' ' + subscription.Bundled_With__c + ' ' + sub.id + ' ' + myId);
                    if(packageType.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON){                        
                        if(checkDuplicateSubscription(subscription.id)){
                            // START : UD-0386 3/27/2015 Alyana Navarro - Added condition to validate if there is open cases for sub
                            if(isNoOpenCaseForSub(subscription.name)){
                                oLineWrapper.id = subscription.id;                    
                                oLineWrapper.subscription = subscription.name;
                                oLineWrapper.enableRemoveButton = false;         
                                     
                                oLineWrapper.orderNumber = subscription.Order_Number__c;
                                oLineWrapper.packageType = subscription.Main_Package_1__r.Package_Type__c;
                                if(subscription.Main_Package_1__c != null || subscription.Main_Package_1__c != ''){
                                    oLineWrapper.mainPackageId = subscription.Main_Package_1__c;
                                }
                                oLineWrapper.earliestStopDate = earliestStart(subscription.Main_Package_1__c);
                                oLineWrapper.prompt = false;
                                oLineWrapper.inputState = false;
                                oLineWrapper.mainPackageName = subscription.Main_Package_1__r.name;
                                oLineWrapper.oliFieldAccess = new Order_Line_Item__c();
                                oLineWrapper.zuoraId = subscription.Zuora__Zuora_Id__c;
                                oLineWrapper.subscriptionType = subscription.subscription_type_1__c;
                                oLineWrapper.publication1 = publication1;
                                oLineWrapper.publication2 = publication2;
                
                //START:D-3344 8/10/15 Added by Manolo Valena
                oLineWrapper.underPromotion = false;
                if(sub.promotion != null) {
                  oLineWrapper.underPromotion = true;
                }
                //END:D-3344 8/10/15 Added by Manolo Valena
                
                //START:D-3330 8/17/15 Added by Manolo Valena
                oLineWrapper.bundledWith = subscription.Bundled_With__c;
                //END:D-3330 8/17/15 Added by Manolo Valena
                
                                relatedSubscriptionResultList.add(oLineWrapper);
            
                                break;
                            } else {
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                                ApexPages.addMessage(myMsg);
                            }
                            // END : UD-0386 3/27/2015 Alyana Navarro
                        }
                    } else if (((sub.orderNumber == subscription.Order_Number__c && sub.bundledWith == subscription.Bundled_With__c) || sub.id == myId) 
                                && (packageType.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BASE || packageType.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE 
                                || packageType.Package_Type__c == GlobalVariableClass.PACKAGETYPE_DISCOUNT)){
                        if(checkDuplicateSubscription(sub.id)){
                            // START : UD-0386 3/27/2015 Alyana Navarro - Added condition to validate if there is open cases for sub
                            if(isNoOpenCaseForSub(sub.subscription)){
                                oLineWrapper.id = sub.id;
                                oLineWrapper.subscription = sub.subscription;
                                oLineWrapper.enableRemoveButton = false;
                                oLineWrapper.orderNumber = sub.orderNumber;
                                     
                                oLineWrapper.packageType = sub.packageType;
                                oLineWrapper.mainPackageId = sub.mainPackage;
                                
                                if(sub.mainPackage != null || sub.mainPackage != ''){
                                    oLineWrapper.earliestStopDate = earliestStart(sub.mainPackage);
                                }
                                oLineWrapper.mainPackageName = sub.mainPackageName;
                                oLineWrapper.ZuoraId = sub.zuoraId;
                                oLineWrapper.inputState = false;
                                oLineWrapper.subscriptionType = sub.subscriptionType;
                                oLineWrapper.publication1 = publication1;
                                oLineWrapper.publication2 = publication2;
                                oLineWrapper.oliFieldAccess = new Order_Line_Item__c();
                                
                //START:D-3344 8/10/15 Added by Manolo Valena
                oLineWrapper.underPromotion = false;
                if(sub.promotion != null) {
                  oLineWrapper.underPromotion = true;
                }
                //END:D-3344 8/10/15 Added by Manolo Valena
                
                //START:D-3330 8/17/15 Added by Manolo Valena
                oLineWrapper.bundledWith = subscription.Bundled_With__c;
                //END:D-3330 8/17/15 Added by Manolo Valena
                
                //START:D-3330 8/18/15 Added by Manolo Valena
                                    //Start UD-1906 VPernicia 08/20/15
                                    set<string> setPlatformType = new set<string>();
                                    
                                    if(sub.packageType == GlobalVariableClass.PACKAGETYPE_BUNDLE) {
                                        if(bundlePublications.get(sub.Id).size() >= 2) {
                                            for (Publication__c pubs: bundlePublications.get(sub.Id)) {
                                                            
                                                if (pubs.Platform_Type__c == GlobalVariableClass.PLATFORM_PRINT && !setPlatformType.Contains(GlobalVariableClass.PLATFORM_PRINT)) {
                                                    oLineWrapper.publication1 = pubs.name;
                                                    setPlatformType.add(pubs.Platform_Type__c);
                                                }
                                                
                                                if (pubs.Platform_Type__c == GlobalVariableClass.PLATFORM_AIO_PUB && !setPlatformType.Contains(GlobalVariableClass.PLATFORM_AIO_PUB) && pubs.Publication_Platform_AIO__c == GlobalVariableClass.PLATFORM_ONLINE) {
                                                    oLineWrapper.publication2 = pubs.name;
                                                    setPlatformType.add(pubs.Platform_Type__c);
                                                }
                                            }
                                        }
                                        else if(bundlePublications.get(sub.Id).size() == 1) {
                                            oLineWrapper.publication1 = bundlePublications.get(sub.Id)[0].Name;
                                            oLineWrapper.publication2 = null;
                                        }
                                    }
                                    //End UD-1906 VPernicia 08/20/15
                //END:D-3330 8/18/15 Added by Manolo Valena
                
                                counter++;
                                relatedSubscriptionResultList.add(oLineWrapper);
                            } else {
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                                ApexPages.addMessage(myMsg);
                            }
                            // END : UD-0386 3/27/2015 Alyana Navarro
                        }
                        
                        if(counter > 1){
                            oLineWrapper.prompt = true;
                        }
                    }
                    system.debug(relatedSubscriptionResultList);
                }                                                           
                getRelatedAsia();      
            
            } catch(Exception e2){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No Main Package associated with the selected Subscription.');
                ApexPages.addMessage(myMsg);              
               
            }
        } catch (exception e1) {
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Subscription Id.');
           ApexPages.addMessage(myMsg);              
        }
        
    }   
    
    /*Description: Method for getting specific subscription from the list of selected subscritpion
     *Parameter:
     *Return:
     */
    public OrderLineItemWrapper getSelectedSubscription(){
 
        OrderLineItemWrapper subscription = new OrderLIneItemWrapper();
        for(OrderLineItemWrapper relSubs : relatedSubscriptionResultList){
            if(relSubs.id == myId){
                subscription = relSubs;
                break;
            } 
        }        
        return subscription;
    }
    
    /*Description: Method for validating Stop Request Date value.
     *Parameter: OrderLineItemWrapper
     *Return: Boolean
     */
    public Boolean isSRDValid(OrderLineItemWrapper subscription){
        Boolean flag = true;
        if(subscription.oliFieldAccess.stop_request_date__c <= system.today()){
            //subscription.oliFieldAccess.stop_request_date__c = null;
            flag = false;
        }
        return flag;
    }
    
    /*Description: Method for validating Stop Request Date value if not null
     *Parameter: List<OrderLineItemWrapper>
     *Return: Boolean
     */
    public Boolean isSRDValid(List<OrderLineItemWrapper> subscription){
        
        Boolean flag = true;
        for(orderLineItemWrapper oLine : subscription){
            if(oLine.oliFieldAccess.stop_request_date__c == null){
                flag = false;
            }
        }
        return flag;
    }
    
    /*Description: Method for validating Stop Request Date value if not non-publication date
     *Parameter: OrderLineItemWrapper, List<Non_Publication_Day__c>
     *Return: Boolean
     */
    public Boolean isSRDValid(OrderLineItemWrapper subscription, List<Non_Publication_Day__c> nonPubDates){
        
        Boolean flag = true;
        for(Non_Publication_Day__c nonPub : nonPubDates){
            //if(subscription.stopRequestDate == nonPub.Non_Publication_Date__c){                // From subscription.stopRequestDate to subscription.oliFieldAccess.stopRequestDate
            if(subscription.oliFieldAccess.stop_request_date__c == nonPub.Non_Publication_Date__c){   // MBG: modified 10.18.2014, to fix stopdate comparison
                flag = false;
            }
        }
        
        return flag;
    }
    
  //START:UD-3387 12/16/15 Added by Manolo Valena
    public Boolean isSRDValidEqualAfterStart(List<OrderLineItemWrapper> subscriptionList, List<SubscriptionWrapper> allSubResultList) {
        Boolean isEqualAfterStart = true;
        if(subscriptionList.size() > 0 && allSubResultList.size() > 0) {
            for(OrderLineItemWrapper subR : subscriptionList) {
                for (SubscriptionWrapper subWrapperR : allSubResultList) {
                    if(subWrapperR.subscription == subR.subscription) { 
                        if(subR.oliFieldAccess.stop_request_date__c < subWrapperR.startDate) {
                            isEqualAfterStart = false;
                            break;
                        }
                    }
                }
            }
        }
        return isEqualAfterStart;
    }
    //END:UD-3387 12/16/15 Added by Manolo Valena
    
    //START: D-4097 12/17/15 Added by Manolo Valena
    public String isAfterTStop(List<OrderLineItemWrapper> subscriptionList, List<SubscriptionWrapper> allSubResultList) {
        Map<Id, Date> subToSRDMap = new Map<Id, Date>();
        Map<Id, Date> subToLatestRestartDateMap = new Map<Id, Date>();
        Date errorDate = null;
        String errorMessage = null;
        
        if(subscriptionList.size() > 0 && allSubResultList.size() > 0) {
            for(OrderLineItemWrapper subRec : subscriptionList) {
                subToSRDMap.put(subRec.id, subRec.oliFieldAccess.stop_request_date__c);
            }
            
            if(subToSRDMap.keySet().size() > 0) {
                for(Temp_Stop__c tsRecord : [SELECT Id, Restart_Date__c, Case__c, Case__r.Temp_Stop_Sub__c  
                                             FROM Temp_Stop__c 
                                             WHERE Case__r.RecordType.Id =: ConstantsSLB.getKeyId(GlobalVariableClass.CASETEMPSTOP) 
                                             AND Case__r.Status =: GlobalVariableClass.STATUS_CLOSED 
                                             AND Case__r.Temp_Stop_Sub__c IN: subToSRDMap.keySet() 
                                             AND Cancelled__c = false 
                                             ORDER BY Restart_Date__c DESC NULLS LAST]) {
                    if(tsRecord.Restart_Date__c != null) {
                        if(subToLatestRestartDateMap.containsKey(tsRecord.Case__r.Temp_Stop_Sub__c)) {  
                            if(tsRecord.Restart_Date__c > subToLatestRestartDateMap.get(tsRecord.Case__r.Temp_Stop_Sub__c)) {
                                subToLatestRestartDateMap.put(tsRecord.Case__r.Temp_Stop_Sub__c, tsRecord.Restart_Date__c);
                            }
                        }
                        else {
                            subToLatestRestartDateMap.put(tsRecord.Case__r.Temp_Stop_Sub__c, tsRecord.Restart_Date__c);
                        }
                    }
                }
            }
            
            if(subToLatestRestartDateMap.keySet().size() > 0) {
                for(OrderLineItemWrapper subR : subscriptionList) {
                    for(SubscriptionWrapper subWrapperR : allSubResultList) {
                        if(subWrapperR.subscription == subR.subscription) {
                            if(subToLatestRestartDateMap.containsKey(subR.Id)) {
                                if(subToLatestRestartDateMap.get(subR.Id) > subR.oliFieldAccess.stop_request_date__c) {
                                    if(errorDate == null) { 
                                        errorDate = subToLatestRestartDateMap.get(subR.Id);
                                        errorMessage = 'There is a pending Temp Stop for this subscription. You shall either amend / cancel the pending Temp Stop before continuing or change the Stop Date to ' + errorDate + ' onwards.';
                                    }
                                    else {
                                        if(subToLatestRestartDateMap.get(subR.Id) > errorDate) {
                                            errorDate = subToLatestRestartDateMap.get(subR.Id);
                                            errorMessage = 'There is a pending Temp Stop for this subscription. You shall either amend / cancel the pending Temp Stop before continuing or change the Stop Date to ' + errorDate + ' onwards.';
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return errorMessage;
    }
    //END: D-4097 12/17/15 Added by Manolo Valena
    
    /*Description: Method for getting Non-Publication Dates
     *Parameter: OrderLineItemWrapper
     *Return: List<Non_Publication_Day__c>
     */
    public List<Non_Publication_Day__c> getPublication(OrderLineItemWrapper subscription){
        List<Non_Publication_Day__c> nonPub = new List<Non_Publication_Day__c>();
        SubscriptionUtil subU = new SubscriptionUtil();
        Integer counter = -1;
        subU.getSubToPub(subscription.id);
        for(Non_Publication_Day__c nonPubRec : subU.nonPubDates){
            nonPub.add(nonPubRec);
        }
        
        return nonPub;
    }
    
    public List<Publication__c> getPublication12(Zuora__Subscription__c subscription){
        //Zuora__SubscriptionProductCharge__c subProdCharge = new Zuora__SubscriptionProductCharge__c();
        //zqu__ProductRatePlan__c prodRatePlan = new zqu__ProductRatePlan__c();
        //zqu__ProductRatePlanCharge__c prodRatePlanCharge = new zqu__ProductRatePlanCharge__c();
        system.debug('IDIDIDIDIDID ' + subscription);
        List <Publication__c> publicationRec = new List <Publication__c>();
        //START D-4080 Gdelrosario : added instantiation for code review
        List <Publication__c> publication = new List<Publication__c>(); 
        //END D-4080 Gdelrosario : added instantiation for code review           
        Set<id> subscriptionIdSet = new Set<id>();
        Set<String> ratePlanName = new Set<String>();
        Set<String> ratePlanId = new Set<String>();
        Set<String> publicationCodeSet = new Set<String>();
        
        /*for(Zuora__Subscription__c sub : subscriptionResultList){
            subscriptionIdSet.add(sub.id);
            packIdSet.add(sub.Main_Package_1__c);
        }*/
        //START SPH Code Review - 17-Feb-2015 Added by Raviteja - included comments for SOQL and if condition in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit             
        //START: D-1448 1/7/2015 Added by Kristine Campang - added field query for new PC approach
        /*List<Zuora__SubscriptionProductCharge__c> subProdChargePubList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__ProductSKU__c
                                                                       FROM Zuora__SubscriptionProductCharge__c 
                                                                       WHERE Zuora__Subscription__c = :subscription.Id]; */
        List<Zuora__SubscriptionProductCharge__c> subProdChargePubList = New List<Zuora__SubscriptionProductCharge__c>();
        if(subscription.Id != Null){
        subProdChargePubList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__ProductSKU__c
                                                                       FROM Zuora__SubscriptionProductCharge__c 
                                                                       //START:D-3634 9/30/15 Added by Manolo Valena
                                                                       WHERE Zuora__Subscription__c =: subscription.Id
                                                                       AND Zuora__Model__c !=: GlobalVariableClass.SPC_MODEL_DISCOUNT];
                                                                       //END:D-3634 9/30/15 Added by Manolo Valena        
        }
        //End SPH Code Review - 17-Feb-2015 Added by Raviteja
        for(Zuora__SubscriptionProductCharge__c subProdCha : subProdChargePubList){
            ratePlanName.add(subProdCha.Zuora__RatePlanName__c);
            subProdChargeMap.put(subProdCha.Zuora__Subscription__c, subProdCha);
        }
        
        List<zqu__ProductRatePlan__c> ratePlanList = [SELECT id, name, SubscriptionFrequency__c,zqu__ZProduct__r.zqu__SKU__c
                                                      FROM zqu__ProductRatePlan__c 
                                                      WHERE name IN :ratePlanName AND zqu__ZProduct__r.zqu__SKU__c = :subProdChargePubList[0].Zuora__ProductSKU__c and RatePlanType__c = 'Proration' AND RatePlanSubType__c = 'Standard'];
        
        //END: D-1448 1/7/2015 Added by Kristine Campang - added field query for new PC approach
        
        for(zqu__ProductRatePlan__c ratePlanAccess : ratePlanList){
            ratePlanId.add(ratePlanAccess.id);
            prodRatePlanMap.put(ratePlanAccess.name, ratePlanAccess);
        }
        
        List<zqu__ProductRatePlanCharge__c> publicationCode = [SELECT publicationcode__c, zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c 
                                                               WHERE zqu__ProductRatePlan__c IN :ratePlanId];
        
        for(zqu__ProductRatePlanCharge__c pubCodeAccess : publicationCode){
            publicationCodeSet.add(pubCodeAccess.publicationcode__c);
            prodRatePlanChargeMap.put(pubCodeAccess.id, pubCodeAccess);
        }        
        //START SPH Code Review - 17-Feb-2015 Added by Raviteja - included remove(null) in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
         publicationCodeSet.remove(Null);
        //End SPH Code Review - 17-Feb-2015 Added by Raviteja 
            //Start UD-1906 VPernicia 08/20/15
            publicationRec = [SELECT ID, Name, earliest_start_date__c, publication_code__c, Platform_Type__c, Publication_Platform_AIO__c FROM publication__c 
                           WHERE publication_code__c IN :publicationCodeSet order by Platform_Type__c];
            system.debug('publications ' + publicationRec);
            
            List <Publication__c> publicationRec2 = new List <Publication__c>();
            set<string> setPlatformType = new set<string>();
            
            if (publicationRec.size() > 2) {
                
                for (Publication__c pubs: publicationRec) {
                
                    if (pubs.Platform_Type__c == GlobalVariableClass.PLATFORM_PRINT && !setPlatformType.Contains(GlobalVariableClass.PLATFORM_PRINT)) {
                        publicationRec2.add(pubs);
                        setPlatformType.add(pubs.Platform_Type__c);
                    }
                    
                    if (pubs.Platform_Type__c == GlobalVariableClass.PLATFORM_AIO_PUB && !setPlatformType.Contains(GlobalVariableClass.PLATFORM_AIO_PUB) && pubs.Publication_Platform_AIO__c == GlobalVariableClass.PLATFORM_ONLINE) {
                        publicationRec2.add(pubs);
                        setPlatformType.add(pubs.Platform_Type__c);
                    }
                }
                
            } else {
                
                publicationRec2 = publicationRec;
            }
            
            return publicationRec2;
            //End UD-1906 VPernicia 08/20/15
    }
    
  //START:D-3330 8/18/15 Added by Manolo Valena
  public Map<Id, List<Publication__c>> getPublicationsBundle(Zuora__Subscription__c subscription) {
    Set<Id> subIdSet = new Set<Id>();
    Map<Id, Set<String>> subToPubCodesMap = new Map<Id, Set<String>>();
    Set<String> pubCodesSet = new Set<String>();
    Map<String, Publication__c> pubCodeToPubRecMap = new Map<String, Publication__c>();
    Map<Id, List<Publication__c>> subToPubsMap = new Map<Id, List<Publication__c>>();
    
    if(subscription.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE) {
      if(subscription.Order_Line_Item_Number_1__c != NULL) {
        for(Zuora__Subscription__c zSubRec : [SELECT Id 
                            FROM Zuora__Subscription__c 
                            WHERE Order_Line_Item_Number_1__c =: subscription.Order_Line_Item_Number_1__c 
                            AND Main_Package_1__r.Package_Type__c =: GlobalVariableClass.PACKAGETYPE_BUNDLE 
                            AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION]) {                     
          subIdSet.add(zSubRec.Id);
        }
        
        if(subIdSet.size() > 0) {
          for(Zuora__SubscriptionProductCharge__c spcRec : [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__ProductSKU__c, PublicationCode__c
                                    FROM Zuora__SubscriptionProductCharge__c 
                                    WHERE Zuora__Subscription__c IN: subIdSet]) {
            if(spcRec.PublicationCode__c != NULL) {
              if(subToPubCodesMap.containsKey(spcRec.Zuora__Subscription__c)) {
                subToPubCodesMap.get(spcRec.Zuora__Subscription__c).add(spcRec.PublicationCode__c);
              }
              else {
                subToPubCodesMap.put(spcRec.Zuora__Subscription__c, new Set<String>{spcRec.PublicationCode__c});
              }
              pubCodesSet.add(spcRec.PublicationCode__c);
            }
          }
          
          if(pubCodesSet.size() > 0) {
                            // Start UD-1906 VPernicia 08/20/15
                            for(Publication__c pubRec : [SELECT Id, Name, Publication_Code__c, Platform_Type__c, Publication_Platform_AIO__c 
                                                         FROM Publication__c 
                                                         WHERE Publication_Code__c IN: pubCodesSet order by Platform_Type__c]) {
                                pubCodeToPubRecMap.put(pubRec.Publication_Code__c, pubRec);
                            }
                            // End UD-1906 VPernicia 08/20/15
            if(subToPubCodesMap.keySet().size() > 0) {
              for(Id subId : subToPubCodesMap.keySet()) {
                for(String pubCode : subToPubCodesMap.get(subId)) {
                  if(pubCodeToPubRecMap.containsKey(pubCode)) {
                    if(subToPubsMap.containsKey(subId)) {
                      subToPubsMap.get(subId).add(pubCodeToPubRecMap.get(pubCode));
                    }
                    else {
                      subToPubsMap.put(subId, new List<Publication__c>{pubCodeToPubRecMap.get(pubCode)});
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return subToPubsMap;
  }
  //END:D-3330 8/18/15 Added by Manolo Valena
  
    public List<Publication__c> getPublication12OLIWrap(OrderLineItemWrapper subscription){
        //Zuora__SubscriptionProductCharge__c subProdCharge = new Zuora__SubscriptionProductCharge__c();
        //zqu__ProductRatePlan__c prodRatePlan = new zqu__ProductRatePlan__c();
        //zqu__ProductRatePlanCharge__c prodRatePlanCharge = new zqu__ProductRatePlanCharge__c();
        system.debug('IDIDIDIDIDID ' + subscription);
        List <Publication__c> publicationRec = new List <Publication__c>();
        //START D-4080 11/12/2015 Gdelrosario : added instantiation for code review
        List <Publication__c> publication = new List<Publication__c>(); 
        //END D-4080 11/12/2015 Gdelrosario : added instantiation for code review           
        Set<id> subscriptionIdSet = new Set<id>();
        Set<String> ratePlanName = new Set<String>();
        Set<String> ratePlanId = new Set<String>();
        Set<String> publicationCodeSet = new Set<String>();
        
        /*for(Zuora__Subscription__c sub : subscriptionResultList){
            subscriptionIdSet.add(sub.id);
            packIdSet.add(sub.Main_Package_1__c);
        }*/
        //START SPH Code Review - 17-Feb-2015 Added by Raviteja - included comments for SOQL and if condition in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit       
         
        //START: D-1448 1/7/2015 Added by Kristine Campang - added field query for new PC approach
        /*List<Zuora__SubscriptionProductCharge__c> subProdChargeList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__ProductSKU__c
                                                                       FROM Zuora__SubscriptionProductCharge__c 
                                                                       WHERE Zuora__Subscription__c = :subscription.Id]; */
        
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = New List<Zuora__SubscriptionProductCharge__c>();
        if(subscription.Id != Null){
        subProdChargeList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__ProductSKU__c
                                                                       FROM Zuora__SubscriptionProductCharge__c 
                                                                       //START:D-3634 9/30/15 Added by Manolo Valena
                                                                       WHERE Zuora__Subscription__c =: subscription.Id
                                                                       AND Zuora__Model__c !=: GlobalVariableClass.SPC_MODEL_DISCOUNT];
                                                                       //END:D-3634 9/30/15 Added by Manolo Valena        
        }
        //End SPH Code Review - 17-Feb-2015 Added by Raviteja
        for(Zuora__SubscriptionProductCharge__c subProdCha : subProdChargeList){
            ratePlanName.add(subProdCha.Zuora__RatePlanName__c);
            subProdChargeMap.put(subProdCha.Zuora__Subscription__c, subProdCha);
        }
        
        List<zqu__ProductRatePlan__c> ratePlanList = [SELECT id, name, SubscriptionFrequency__c
                                                      FROM zqu__ProductRatePlan__c 
                                                      WHERE name IN :ratePlanName AND zqu__ZProduct__r.zqu__SKU__c = :subProdChargeList[0].Zuora__ProductSKU__c and RatePlanType__c = 'Proration' AND RatePlanSubType__c = 'Standard'];
        
        for(zqu__ProductRatePlan__c ratePlanAccess : ratePlanList){
            ratePlanId.add(ratePlanAccess.id);
            prodRatePlanMap.put(ratePlanAccess.name, ratePlanAccess);
        }
        
        List<zqu__ProductRatePlanCharge__c> publicationCode = [SELECT publicationcode__c, zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c 
                                                               WHERE zqu__ProductRatePlan__c IN :ratePlanId ];
        //END: D-1448 1/7/2015 Added by Kristine Campang - added field query for new PC approach
        
        for(zqu__ProductRatePlanCharge__c pubCodeAccess : publicationCode){
            publicationCodeSet.add(pubCodeAccess.publicationcode__c);
            prodRatePlanChargeMap.put(pubCodeAccess.id, pubCodeAccess);
        }
        //START SPH Code Review - 17-Feb-2015 Added by Raviteja - included remove(null) in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
        publicationCodeSet.remove(Null);
        //End SPH Code Review - 17-Feb-2015 Added by Raviteja 
            //Start UD-1906 VPernicia 08/20/15
            publicationRec = [SELECT ID, Name, earliest_start_date__c, publication_code__c, Platform_Type__c, Publication_Platform_AIO__c FROM publication__c 
                           WHERE publication_code__c IN :publicationCodeSet order by Platform_Type__c];
            system.debug('publications ' + publicationRec);
            
             List <Publication__c> publicationRec2 = new List <Publication__c>();
            set<string> setPlatformType = new set<string>();
            
            if (publicationRec.size() > 2) {
                
                for (Publication__c pubs: publicationRec) {
                
                    if (pubs.Platform_Type__c == GlobalVariableClass.PLATFORM_PRINT && !setPlatformType.Contains(GlobalVariableClass.PLATFORM_PRINT)) {
                        publicationRec2.add(pubs);
                        setPlatformType.add(pubs.Platform_Type__c);
                    }
                    
                    if (pubs.Platform_Type__c == GlobalVariableClass.PLATFORM_AIO_PUB && !setPlatformType.Contains(GlobalVariableClass.PLATFORM_AIO_PUB) && pubs.Publication_Platform_AIO__c == GlobalVariableClass.PLATFORM_ONLINE) {
                        publicationRec2.add(pubs);
                        setPlatformType.add(pubs.Platform_Type__c);
                    }
                    
                }
                
            } else {
                
                publicationRec2 = publicationRec;
            }
            
            return publicationRec2;
            //End UD-1906 VPernicia 08/20/15
    }
    
    /*Description: Method for checking if elligible for retention
     *Parameter: 
     *Return: 
     */
    public void checkRetention(){ 
        //START UD-2738 Wenjun 21/Sep/15 : No longer needed
        /*
        //START D-3224 Rebuild AddedBy FrancisBenzon : variable
        Date invoiceTargetDate;     
        passedInvoiceValidation = true;
        //END D-3224 Rebuild AddedBy FrancisBenzon : variable_
        */
        //END UD-2738 Wenjun 21/Sep/15 : No longer needed   
        
        orderLineItemWrapper subscription = getSelectedSubscription();
        //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
        checkExistingCOA(subscription);
        //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
            
        Set<Id> setTrue = new Set<Id>();
        
        //START: UD-2984 10/7/15 Added by Manolo Valena
        Set<Id> subRecIds = new Set<Id>();
        Map<Id, Date> subToDateMap = new Map<Id, Date>();
        Map<Id, Boolean> checkRetentionResultsMap = new Map<Id, Boolean>();
        //END: UD-2984 10/7/15 Added by Manolo Valena
         
        //START UD-2657/D-3414/D-3711 Wenjun 15 Oct: Validate Stop Date cannot be less than Sub Start Date + Code Optimization       
        //Start MMallorca Add statement when stop request date is deleted, reorder criterias D-3116 06/25/2015
        //Valdiations
        if(subscription.oliFieldAccess.stop_request_date__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_NO_STOP_DATE));
            return;
        }
        
        if(!isSRDValid(subscription)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_STOP_DATE_B4_TODAY));
            return;
        }
        
        if(!isSRDValid(subscription, getPublication(subscription))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_STOP_DATE_NON_PUB));
            return;
        }
        
        //Validate Subscription Start Date
        for (SubscriptionWrapper subWrapper : allSubscriptionResultList) {
            if (subWrapper.subscription == subscription.subscription) {
                if(subscription.oliFieldAccess.stop_request_date__c < subWrapper.startDate ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_STOP_B4_START_DATE));
                    return;
                }
                break;
            }
        }
        
        //START: D-4097 12/17/15 Added by Manolo Valena
        for (SubscriptionWrapper subWrapper : allSubscriptionResultList) {
            if (subWrapper.subscription == subscription.subscription) {
                if(SM_SubscriptionHelper.checkTStopRestartDates(subWrapper.id, subscription.oliFieldAccess.stop_request_date__c, GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION) != null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, SM_SubscriptionHelper.checkTStopRestartDates(subWrapper.id, subscription.oliFieldAccess.stop_request_date__c, GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION)));
                    return;
                }
                break;
            }
        }
        //END: D-4097 12/17/15 Added by Manolo Valena
        
        //Processing after passing all validations
        for(OrderLineItemWrapper oLine : relatedSubscriptionResultList){    
            //START: UD-2984 10/7/15 Added by Manolo Valena
            subRecIds.add(oLine.id);
            subToDateMap.put(oLine.id, oLine.oliFieldAccess.stop_request_date__c);
            //END: UD-2984 10/7/15 Added by Manolo Valena
        }
        
        //START: UD-2984 10/7/15 Added by Manolo Valena
        if(!subRecIds.isEmpty() && !subToDateMap.isEmpty()) {
            checkRetentionResultsMap = retEligibile.checkRetentionEligibiltyMultipleSubscriptions(subRecIds, subToDateMap); 
            if(!checkRetentionResultsMap.isEmpty()) {
                for(Id subRId : checkRetentionResultsMap.keySet()) {
                    if(checkRetentionResultsMap.get(subRId) == true) 
                        setTrue.add(subRId);
                }
                
                retention = setTrue.isEmpty() ? false : true;
            }
        }
        //END: UD-2984 10/7/15 Added by Manolo Valena
                 
        getAdminFee(subscription);
        //START UD-2549 3/18/2016 Added by J.Sarion - get refund
        if(subscription.oliFieldAccess.Terminating_Reason__c == 'Payment failure - Credit card' || subscription.oliFieldAccess.Terminating_Reason__c == 'Payment failure - PayPal') {
            subscription.refund = 0.00;
        }
        else {
            getRefund(subscription);
        }
        //END UD-2549 3/18/2016 Added by J.Sarion - get refund
        getMissedCopies(subscription);
        
       //END UD-2657/D-3414/D-3711 Wenjun 15 Oct
       
        //START UD-2738 Wenjun 21/Sep/15 : No longer needed
        /*
        //START D-3224 Rebuild AddedBy FrancisBenzon : validate target date vs stop date
        //START UD-2659 RReyes - changed condition
        invoiceTargetDate = SM_SubscriptionHelper.checkInvoiceTargetDate(subscription.Id, subscription.oliFieldAccess.stop_request_date__c);
        if(invoiceTargetDate != null && invoiceTargetDate >  subscription.oliFieldAccess.stop_request_date__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage(stopTargetDateError)));
            passedInvoiceValidation = false;
        }
        //END UD-2659 RReyes - changed condition
        //END D-3224 Rebuild AddedBy FrancisBenzon : validate target date vs stop date
        */
        //END UD-2738 Wenjun 21/Sep/15 : No longer needed
        
        //End MMallorca D-3116 06/25/2015
        //START:UD-1364 6/2/2015 Added by Manolo Valena - Commented out code that invokes "checkInvoiceForBillingAccount" method by James. To be Removed.
        //Start: UD-0393 05/04/2015 James - add validation between stop request date and last invoice date
        /*if(subscription.oliFieldAccess.stop_request_date__c != null){
            checkInvoiceForBillingAccount(subscription);
        }*/
        //End: UD-0393 05/04/2015 James
        //END:UD-1364 6/2/2015 Added by Manolo Valena
    }   

    public void getGivenCopies(OrderLineItemWrapper subscription){
        Date Startdate = getSubStartDate(subscription.id);
        for(OrderLineItemWrapper relSub : relatedSubscriptionResultList){
            if(relSub.id == subscription.id){
                    if (subscription.oliFieldAccess.stop_request_date__c > Startdate){
                            givencopiesmap = refundcomputation.givencopiesmap;
                     }       
                    else{
                        relSub.copiesgiven = 0;
                    }
                    
            }
        }
    }
    public Date getSubStartDate(String subid){
        Date stdate;
        List<Zuora__Subscription__c> zsubs = new List<Zuora__Subscription__c>([Select Id, Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c Where Id = :subid]);
        for(Zuora__Subscription__c zsub :zsubs){   
            stdate = zsub.Zuora__SubscriptionStartDate__c;
        }    
       return stdate;
    }
       
    
    /*Description: Method for getting Admin Fee
     *Parameter: OrderLineItemWrapper
     *Return:
     */
    public void getAdminFee(OrderLineItemWrapper subscription){
        
        for(OrderLineItemWrapper relSub : relatedSubscriptionResultList){
            if(relSub.id == subscription.id){
        //START: UD-3852 2-24-2016 Added by Kristine Balaoing - modified logif for admin fee charging on bundled subscriptions
                if(relSub.packageType == GlobalVariableClass.PACKAGETYPE_BUNDLE){
                    if(!oliToIsAdminFeeCharged.containsKey(subToOLIMap.get(relSub.Id))){
                        relSub.adminFee = AdminFeeComputation.computeAdminCharge(subscription.id, subscription.oliFieldAccess.stop_request_date__c);
                        oliToIsAdminFeeCharged.put(subToOLIMap.get(relSub.Id), true);
                    }else{
                        relSub.adminFee = 0.00;
                    }
                }else{
                    relSub.adminFee = AdminFeeComputation.computeAdminCharge(subscription.id, subscription.oliFieldAccess.stop_request_date__c);
                }
            //END: UD-3852 2-24-2016 Added by Kristine Balaoing
        }
        }
    }
    
    
    /*Description: Method for getting Refund
     *Parameter: OrderLineItemWrapper
     *Return:
     */
    public void getRefund(OrderLineItemWrapper subscription){
    
        //Start VPernicia D-0077 5/4/2015
        isError = false;
        //End VPernicia D-0077 5/4/2015      
        
        //START UD-2012 7/21/2015 Added by Manolo Valena - Removed fix for UD-0760.
        //START UD-0760 7/14/2015 Added by Manolo Valena
        /*Id subCustAccount;
        Boolean isPaid = true;
        Integer invRecExisting = 0;
        Date zTargetDate = subscription.oliFieldAccess.stop_request_date__c.toStartOfMonth();
        Date zInvoiceDate = subscription.oliFieldAccess.stop_request_date__c.addMonths(1).toStartOfMonth().addDays(-1);
        Date subStartDate;
        
        for(Zuora__Subscription__c zSubRec : [SELECT Zuora__CustomerAccount__c, Billing_Type__c, Zuora__SubscriptionStartDate__c 
                                              FROM Zuora__Subscription__c 
                                              WHERE Id =: subscription.Id 
                                              AND Billing_Type__c =: GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID
                                              LIMIT 1]) {
            subCustAccount = zSubRec.Zuora__CustomerAccount__c;
            subStartDate = zSubRec.Zuora__SubscriptionStartDate__c;
        }
        
        if(subCustAccount != null) {
            if(subscription.oliFieldAccess.stop_request_date__c.month() != subStartDate.month()) {
                for(Zuora__ZInvoice__c invRec : [SELECT Zuora__TargetDate__c, Zuora__Balance2__c 
                                                 FROM Zuora__ZInvoice__c 
                                                 WHERE Zuora__BillingAccount__c =: subCustAccount
                                                 AND Zuora__TargetDate__c =: zTargetDate
                                                 ORDER BY Zuora__TargetDate__c DESC 
                                                 LIMIT 1]) {
                    if(invRec.Zuora__Balance2__c != 0.00 || 
                      (invRec.Zuora__Balance2__c == 0.00 && 
                       subscription.oliFieldAccess.stop_request_date__c.month() != invRec.Zuora__TargetDate__c.month())) {
                        isPaid = false;
                    }
                    invRecExisting = 1;
                }
            }
            else {
                for(Zuora__ZInvoice__c invRec : [SELECT Zuora__TargetDate__c, Zuora__Balance2__c 
                                                 FROM Zuora__ZInvoice__c 
                                                 WHERE Zuora__BillingAccount__c =: subCustAccount
                                                 AND Zuora__InvoiceDate__c =: zInvoiceDate
                                                 ORDER BY Zuora__TargetDate__c DESC 
                                                 LIMIT 1]) {
                    if(invRec.Zuora__Balance2__c != 0.00 || 
                      (invRec.Zuora__Balance2__c == 0.00 && 
                       subscription.oliFieldAccess.stop_request_date__c.month() != subStartDate.month())) {
                        isPaid = false;
                    }
                    invRecExisting = 1;
                }
            }
            
            if(invRecExisting == 0) {
                isPaid = false;
            }
        }*/
        //END UD-0760 7/14/2015 Added by Manolo Valena
        //END UD-2012 7/21/2015 Added by Manolo Valena
        
        RefundComputation.orderType = orderType1; //START-END D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
        for(OrderLineItemWrapper relSub : relatedSubscriptionResultList){
            if(relSub.id == subscription.id){
                //START D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
                system.debug('>>>>>oliIdForBundleSet ' + oliIdForBundleSet);
                if(subIdForBundleSet.contains(relSub.Id)){
                    oliIdForBundleSet.remove(relSub.bundledWith);
                }
                RefundComputation.oliIdForBundleSetRC = oliIdForBundleSet;
                system.debug('>>>>>RefundComputation.oliIdForBundleSetRC ' + RefundComputation.oliIdForBundleSetRC);
                //END D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
                //START UD-0760 7/14/2015 Added by Manolo Valena
                //if(isPaid) { //START/END UD-2012 7/21/2015 Added by Manolo Valena - Removed fix for UD-0760
                    relSub.refund = RefundComputation.computeRefund(subscription.id, subscription.oliFieldAccess.stop_request_date__c);
          //START UD-2226 8/4/2015 Added By C. Lin - refund amount cannot be null
          if(relSub.refund == null){
            relSub.refund = 0;
          }
          //END UD-2226 8/4/2015 Added By C. Lin
                    pendingcopiesmap = RefundComputation.pendingcopiesmap;
                    
                    publications = getPublication12OLIWrap(relSub);
                    //D-0881 Changed if from == to >=
                    
                    //Start VPernicia D-0077 5/4/2015: Add additional condition to if Sub End Date is Greater than to stop date.     
                    
                    if (isError == true) {
                        
                        break;
                    }
                    
                    Date endSubDate;
                    //START UD-2528 8/27/2015 Added by Manolo Valena
                    Boolean isRecurringPrepaidFirstOfMonth = false;
                    //END UD-2528 8/27/2015 Added by Manolo Valena
                    for (SubscriptionWrapper sub : allSubscriptionResultList) {
                    
                        if (sub.subscription == relSub.subscription) {
                            endSubDate = sub.endDate;
                        }
                        
                        //START UD-2528 8/27/2015 Added by Manolo Valena
                        if(relSub.id == sub.id) {
                            if(subscription.oliFieldAccess.stop_request_date__c == subscription.oliFieldAccess.stop_request_date__c.toStartOfMonth() &&
                               //Start UD-2685 VPernicia 09/15/15
                               //subscription.oliFieldAccess.stop_request_date__c.month() > sub.startDate.month() &&
                               //subscription.oliFieldAccess.stop_request_date__c.year() >= sub.startDate.year() &&
                               subscription.oliFieldAccess.stop_request_date__c >= sub.startDate &&
                               //End UD-2685 VPernicia 09/15/15
                               sub.packageBillingType == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID) {
                                relSub.refund = 0;
                                isRecurringPrepaidFirstOfMonth = true;
                            }
                        }
                        //END UD-2528 8/27/2015 Added by Manolo Valena
                    }
                    
                    try {
                        if (endSubDate >= relSub.oliFieldAccess.stop_request_date__c || endSubDate == null || relSub.oliFieldAccess.stop_request_date__c == null) {
                           
                            if(publications.size() >= 2){
                                relSub.copiespending1 = RefundComputation.getpending(publications[0]);
                                relSub.copiespending2 = RefundComputation.getpending(publications[1]);
                            }
                            else if(publications.size() == 1) {
                                relSub.copiespending1 = RefundComputation.getpending(publications[0]);
                            }
                            
                            //START UD-2528 8/27/2015 Added by Manolo Valena
                            if(isRecurringPrepaidFirstOfMonth == true) {
                                relSub.copiespending1 = 0;
                                relSub.copiespending2 = 0;
                            }
                            //END UD-2528 8/27/2015 Added by Manolo Valena
                            
                            isError = false;
                        } else {
                            isError = true;
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Stop Request Date should not be greater than to Subscription End Date');
                            ApexPages.addMessage(myMsg);
                            relSub.copiespending1 = 0;
                            relSub.copiespending2 = 0; 
                        }
                    } catch(exception e) {
                        publications = new List<Publication__c>();          
                    }
                    //End VPernicia D-0077 5/4/2015: Add additional condition to if Sub End Date is Greater than to stop date.
                //START UD-2012 7/21/2015 Added by Manolo Valena - Removed fix for UD-0760.
                /*}
                else {
                    relSub.copiespending1 = 0;
                    relSub.copiespending2 = 0; 
                    relSub.refund = 0;
                    
                    Date endSubDateNoRefund;
                    
                    for (SubscriptionWrapper sub : allSubscriptionResultList) {
                        if (sub.subscription == relSub.subscription) {
                            endSubDateNoRefund = sub.endDate;
                        }
                    }
                    
                    if(relSub.oliFieldAccess.stop_request_date__c > endSubDateNoRefund) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, GlobalVariableClass.STOPDATE_ERROR);
                        ApexPages.addMessage(myMsg);
                    }
                }*/
                //END UD-0760 7/14/2015 Added by Manolo Valena
                //END UD-2012 7/21/2015 Added by Manolo Valena - Removed fix for UD-0760.
                
                //START D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
                if(relSub.bundledWith != null || relSub.bundledWith != ''){
                    if(!oliIdForBundleSet.contains(relSub.bundledWith)){
                        subIdForBundleSet.add(relSub.Id);
                    }
                    oliIdForBundleSet.add(relSub.bundledWith);
                    system.debug('>>>>>oliIdForBundleSet ' + oliIdForBundleSet);
                }
                //END D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
            }
        }        
    }
    
    public void getMissedCopies(OrderLineItemWrapper subscription){
         for(OrderLineItemWrapper relSub : relatedSubscriptionResultList){
            if(relSub.id == subscription.id){
                List<Case_Subscription__c> casesub = new List<Case_Subscription__c>([Select Case__c, Case_Record_Type_ID__c, Complaint_Copies__c, Subscription__c FROM  Case_Subscription__c WHERE Subscription__c = :relSub.id AND Case_Record_Type_ID__c = :ConstantsSLB.getKeyId('Complaint_Newspaper')]);      
                if(casesub.size() > 0){
                    Decimal missedcopies = countMissedCopies(casesub);
                    relSub.copiesmissed = missedcopies;
                }
                else{
                    relSub.copiesmissed = 0;
                    
                } 
               
            }
        }
    
    
    }
    public Decimal countMissedCopies(List<Case_Subscription__c> casesubs){
        Decimal missedcopies = 0;
        for(Case_Subscription__c casesub : casesubs){
           
            missedcopies += casesub.Complaint_Copies__c;
        
        }
        return missedcopies;
    
    }
    
    /*Description: Method for removing selected subscritpion from list
     *Parameter: 
     *Return:
     */
    public void removeSubscriptionRecord(){
           
        system.debug('-----------------------' + isBundle);
        List<Integer> indexToBeRemoved = new List<Integer>();
        List<String> idOfSubscription = new List<String>();
        //START UD-0564 3/24/2015 Added By C. Lin - Added error handling for myId is null. List has no rows for assignment to SObject error.
        try{
            Zuora__Subscription__c subscription = [SELECT id, name, Main_Package_1__r.package_type__c,  Order_Number__c, Bundled_With__c FROM Zuora__Subscription__c WHERE id = :myId];
            
            //START SPH Code Review - 17-Feb-2015 Added by Raviteja - included Comments for SOQL and  included if condition in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
            // Package__c packageType = [SELECT Package_Type__c FROM Package__c WHERE id =: subscription.Main_Package_1__c];
            Package__c packageType = New Package__c();
            if(subscription.Main_Package_1__c != null){
                packageType = [SELECT Package_Type__c FROM Package__c WHERE id =: subscription.Main_Package_1__c Limit 1];        
             }
            //End SPH Code Review - 17-Feb-2015 Added by Raviteja  
            try{
                for(Integer counter = 0; counter < relatedSubscriptionResultList.size(); counter++){                  
                    if(packageType.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON){
                        if(subscription.order_number__c == relatedSubscriptionResultList[counter].orderNumber && subscription.bundled_with__c == relatedSubscriptionResultList[counter].bundledWith){                      
                            indexToBeRemoved.add(counter);
                            idOfSubscription.add(relatedSubscriptionResultList[counter].id);
                        }
                    } else if(packageType.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BASE || packageType.Package_Type__c == GlobalVariableClass.PACKAGETYPE_DISCOUNT || packageType.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE){ 
                        if((subscription.order_number__c == relatedSubscriptionResultList[counter].orderNumber && subscription.bundled_with__c == relatedSubscriptionResultList[counter].bundledWith)
                           && (relatedSubscriptionResultList[counter].packageType == GlobalVariableClass.PACKAGETYPE_BASE 
                           || relatedSubscriptionResultList[counter].packageType == GlobalVariableClass.PACKAGETYPE_BUNDLE 
                           || relatedSubscriptionResultList[counter].packageType == GlobalVariableClass.PACKAGETYPE_DISCOUNT)){
                                         
                           indexToBeRemoved.add(counter);
                           idOfSubscription.add(relatedSubscriptionResultList[counter].id);
                        }
                    } 
                    //Added by Pepper 10/29/2014           
                    if(relatedSubscriptionResultList[counter].enableRemoveButton == true){
                           indexToBeRemoved.add(counter);
                           idOfSubscription.add(relatedSubscriptionResultList[counter].id);            
                    }
                    
                }
        
        //START:D-3330 8/17/15 Added by Manolo Valena
        Set<Integer> uniqueIndexSet = new Set<Integer>();
        uniqueIndexSet.addAll(indexToBeRemoved);
        indexToBeRemoved.clear();
        indexToBeRemoved.addAll(uniqueIndexSet);
        //END:D-3330 8/17/15 Added by Manolo Valena
        
                for(Integer counter = indexToBeRemoved.size() - 1; counter >= 0; counter--){
                    deletedSubscriptionList.add(relatedSubscriptionResultList[counter]);
                    relatedSubscriptionResultList.remove(indexToBeRemoved[counter]);                
                }
                
                //START D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
                oliIdForBundleSet.remove(subscription.Bundled_With__c);
                //END D-3842 10/30/2015 Added by J.Sarion - Add Delivery fee to only 1 sub for bundle subscriptions
            
            } catch (Exception e){
                system.debug('------------------ No Subscription Record ' + relatedSubscriptionResultList + ' ------------------');
            }
        } catch (Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Invalid Subscription'));
            ApexPages.addMessage(myMsg);
        }
        //END UD-0564 3/24/2015 Added By C. Lin
            
        removeRelatedAsia(idOfSubscription);
    }
    
    /*Description: Method for removing selected subscription from database
     *Parameter: List<OrderLineItemWrapper>
     *Return:
     */
    public void removeSubscriptionFromDB(List<OrderLineItemWrapper> deletedOLine){        
        List<Order_Line_Item__c> newOrderLine = new List<Order_Line_Item__c>();          
        
        for(OrderLineItemWrapper delOLine : deletedOLine){
            if(copyRelatedSubscriptionMap.containsKey(delOLine.id)){
                newOrderLine.add(new Order_Line_Item__c(id = delOLine.oLIid));
            }                  
        }                     
        
        delete newOrderLine;
    }
    
    /*Description: Method for getting related Asia 1 Subscription of selected subscription
     *Parameter: 
     *Return:
     */
    public void getRelatedAsia(){
        asiaRelatedList = new List<Asia1_Subscription__c>();
        
        asiaResultList = new List<AsiaRelatedListWrapper>();
        List<Asia1_Subscription__c> asiaRelatedTempList = new List<Asia1_Subscription__c>();
        Set<String> subId = new Set<String>();
        Map<string, list<Asia1_Subscription__c>> asia1RelatedMap = new Map<string, list<Asia1_Subscription__c>>();
        
        for (OrderLineItemWrapper oLineWrap : relatedSubscriptionResultList) { 
            // Start D-2213 02/13/2015 JohnD filter null value
            if (oLineWrap.id != null) {  
                subId.add(oLineWrap.id); 
            }
            // End D-2213 02/13/2015 JohnD 
        } 
            //START UD-1744 6/29/2015 - JLedesma - Asia 1 details on Save as Draft
            asiaRelatedList = [SELECT id, Service_Access_Flag__c, Service_Access_Flag__r.Name, Status__c, Subscription__c, Asia1__r.User_ID_LDAP_ID__c, Concurrent__c FROM Asia1_Subscription__c WHERE 
            Subscription__c IN : subId];        //this blocks groups all related asia1 record per subscription
            //END UD-1744 6/29/2015 - JLedesma - Asia 1 details on Save as Draft
        for( Asia1_Subscription__c a : asiaRelatedList){
            if(asia1RelatedMap.containsKey(a.Subscription__c)){
                //the subscription already exits, then get the previous list and add the new asia1 to the list
                asiaRelatedTempList = new List<Asia1_Subscription__c>();
                asiaRelatedTempList = asia1RelatedMap.get(a.Subscription__c);
                asiaRelatedTempList.add(a);
                asia1RelatedMap.put(a.Subscription__c,asiaRelatedTempList);
            } else {
                asiaRelatedTempList = new List<Asia1_Subscription__c>();                
                asiaRelatedTempList.add(a);
                asia1RelatedMap.put(a.Subscription__c,asiaRelatedTempList);
            }
        }
        
        try{
            for(Integer counter = 0; counter < relatedSubscriptionResultList.size(); counter++){                                       
                if(asia1RelatedMap.isEmpty() != true){
                
                    if(asia1RelatedMap.containsKey(relatedSubscriptionResultList[counter].id)){
                                            
                        asiaRelatedTempList = asia1RelatedMap.get(relatedSubscriptionResultList[counter].id);
                        
                        for(Integer innerCounter = 0; innerCounter < asiaRelatedTempList.size(); innerCounter++){
                           
                            asiaWrapper = new AsiaRelatedListWrapper();
                            asiaWrapper.id = asiaRelatedTempList[innerCounter].id;
                            asiaWrapper.status = asiaRelatedTempList[innerCounter].Status__c;
                            asiaWrapper.asiaSubscription = asiaRelatedTempList[innerCounter].Subscription__c;                           
                            asiaWrapper.userId = asiaRelatedTempList[innerCounter].Asia1__r.User_ID_LDAP_ID__c;                                                 
                            
                            //START D-1677: Marvin Gatcthalian
                               //START UD-1744 6/29/2015 - JLedesma - Asia 1 details on Save as Draft
                                asiaWrapper.quantity = integer.valueOf(asiaRelatedTempList[innerCounter].Concurrent__c);
                                asiaWrapper.serviceFlag = asiaRelatedTempList[innerCounter].Service_Access_Flag__r.Name;
                                //END D-1677: Marvin Gatcthalian
                                //END UD-1744 6/29/2015 - JLedesma - Asia 1 details on Save as Draft
                            asiaResultList.add(asiaWrapper);
                        }
                    }
                }
            }
            
        } catch (Exception e){
            system.debug('------------------ No Asia Related List for ' + myId + ' ------------------');
        }                
    }
    
    /*Description: Method for removing related Asia 1 subscription of selected subscripion
     *Parameter: List<String>
     *Return:
     */
    public void removeRelatedAsia(List<String> idOfSubscription){        
        asiaResultList = new List<AsiaRelatedListWrapper>();
        
        //START UD-0564 3/24/2015 Added By C. Lin - Fixed query in a for loop. For Too many query rows: 50001
        asiaResultList = new List<AsiaRelatedListWrapper>();
        List<Asia1_Subscription__c> asiaRelatedTempList = new List<Asia1_Subscription__c>();
        Set<String> subsId = new Set<String>();
        Map<string, List<Asia1_Subscription__c>> asia1RelatedMap = new Map<string, List<Asia1_Subscription__c>>();
        //END UD-0564 3/24/2015 Added By C. Lin
        
        try{
            //START UD-0564 3/24/2015 Added By C. Lin - Fixed query in a for loop. For Too many query rows: 50001
            for(OrderLineItemWrapper oliWrap : relatedSubscriptionResultList){
                if (oliWrap.Id != null) {
                    subsId.add(oliWrap.Id);
                }
            }
            
            asiaRelatedList = [SELECT Id, Service_Access_Flag__c, Status__c, Subscription__c FROM Asia1_Subscription__c WHERE Subscription__c IN : subsId];
            
            for(Asia1_Subscription__c a : asiaRelatedList){
                if(asia1RelatedMap.containsKey(a.Subscription__c)){
                    //the subscription already exits, then get the previous list and add the new asia1 to the list
                    asiaRelatedTempList = new List<Asia1_Subscription__c>();
                    asiaRelatedTempList = asia1RelatedMap.get(a.Subscription__c);
                    asiaRelatedTempList.add(a);
                    asia1RelatedMap.put(a.Subscription__c, asiaRelatedTempList);
                } else {
                    asiaRelatedTempList = new List<Asia1_Subscription__c>();                
                    asiaRelatedTempList.add(a);
                    asia1RelatedMap.put(a.Subscription__c, asiaRelatedTempList);
                }
            }
            
            for(Integer counter = 0; counter < allSubscriptionResultList.size(); counter++){
                if(!asia1RelatedMap.isEmpty()){
                    if(asia1RelatedMap.containsKey(relatedSubscriptionResultList[counter].id)){
                        asiaRelatedTempList = asia1RelatedMap.get(relatedSubscriptionResultList[counter].id);
                        
                        for(Integer innerCounter = 0; innerCounter < asiaRelatedTempList.size(); innerCounter++){
                            asiaWrapper = new AsiaRelatedListWrapper();
                            asiaWrapper.id = asiaRelatedTempList[innerCounter].id;
                            asiaWrapper.serviceFlag = asiaRelatedTempList[innerCounter].Service_Access_Flag__c;
                            asiaWrapper.status = asiaRelatedTempList[innerCounter].Status__c;
                            asiaWrapper.asiaSubscription = asiaRelatedTempList[innerCounter].Subscription__c;
                            asiaResultList.add(asiaWrapper);
                        }
                    }
                }
            }
            //END UD-0564 3/24/2015 Added By C. Lin
        } catch (Exception e){
            system.debug('------------------ No Asia Related List for ' + myId + ' ------------------');
        }
    }
    
    /*Description: Method for validating duplicate selected subscription
     *Parameter: String
     *Return: Boolean
     */
    public Boolean checkDuplicateSubscription(String id){
        Boolean flag = true;
        for(OrderLineItemWrapper sub : relatedSubscriptionResultList){
            if(sub.id == id){
                flag = false;
            }
        }        
        return flag;
    }    
    
    /*Description: Method for inserting/updating Order and Order Line Item Records
     *Parameter:
     *Return:
     */
    
    public boolean doSave(){    
        
        boolean returnValue = true;
        SubscriptionWrapper allSubscriptionTempList;
        if(existingFlag == false){
            insert order;
        }
        
        removeSubscriptionFromDB(deletedSubscriptionList);
        orderLineItemRecordList = new List<Order_Line_Item__c>();
        for(OrderLineItemWrapper OLIWrapper : relatedSubscriptionResultList){
            
            if(allSubscriptionMap.containsKey(OLIWrapper.id)){
                allSubscriptionTempList = new SubscriptionWrapper();
                allSubscriptionTempList = allSubscriptionMap.get(OLIWrapper.id);
                
                orderLineItemRecordList.add(createRecord(OLIWrapper, allSubscriptionTempList));
            }        
        }   
        checkFieldsInOrder(orderLineItemRecordList);
        
        
        try {
            if(!(orderLineItemRecordList == null)){            
                update order;            
                if(existingFlag){               
                    upsert orderLineItemRecordList;
                } else{
                    insert orderLineItemRecordList;
                }           
            }  
        }
        catch(exception e) {
                
            orderLineItemRecordList = new List<Order_Line_Item__c>();
            ApexPages.addMessages(e); 
            returnValue = false;
        }
        
        return returnValue;
    }
    
    /*Description: Method for mapping of Order Line Item Records
     *Parameter: OrderLineItemWrapper, SubscriptionWrapper
     *Return: Order_Line_Item__c
     */
    public Order_Line_Item__c createRecord(OrderLineItemWrapper  OLIWrapper, SubscriptionWrapper subWrapper){
        Order_Line_Item__c OLIinstance = new Order_Line_Item__c();        
        if(existingFlag && OLIWrapper.OLIid != null){
            OLIinstance.id = OLIWrapper.OLIid;
        } else {            
            OLIinstance.order__c = order.id;            
        }        
        
        if(OLIWrapper.subscriptionType == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY){           
            OLIinstance.Main_Package_Frequency__c = null;
        } else {
            OLIinstance.Main_Package_Frequency__c = subWrapper.dowPattern;
        }
        
        if(subWrapper.dowPattern == null){
            OLIinstance.Main_Package_Frequency__c = 'null';
        }
        
        OLIinstance.Subscription_Name__c = OLIWrapper.subscription;
        OLIinstance.Subscription__c = OLIWrapper.id;
        OLIinstance.earliest_stop_date__c = OLIWrapper.earliestStopDate;
        OLIinstance.Stop_Request_Date__c = OLIWrapper.oliFieldAccess.stop_request_date__c;
        OLIinstance.Terminating_Reason__c = OLIWrapper.oliFieldAccess.terminating_reason__c;
        //START UD-2226 8/4/2015 Added By C. Lin - refund amount cannot be null
    if(OLIWrapper.refund != null){
      OLIinstance.Amount_To_Refund__c = OLIWrapper.refund;
    }else{
      OLIinstance.Amount_To_Refund__c = 0;
    }
    //END UD-2226 8/4/2015 Added By C. Lin
        OLIinstance.Admin_Charge__c = OLIWrapper.adminFee;
        
    //START:D-3344 8/10/15 Added by Manolo Valena
    OLIinstance.Fee_Waiver__c = false;
    if(OLIWrapper.feeWaiver != null) {
      OLIinstance.Fee_Waiver__c = OLIWrapper.feeWaiver;
    }
    
    OLIinstance.Fee_Override__c = false;
    if(OLIWrapper.feeOverride != null) {
      OLIinstance.Fee_Override__c = OLIWrapper.feeOverride;
    }
    //END:D-3344 8/10/15 Added by Manolo Valena
    
        //START UD-0364 4/7/2015 MGaelo added feeOverrideAmount 
        //START:D-2795 5/18/15 Added by Manolo Valena - Added condition on when the Fee Override Amount field will be udpated.
        if((OLIWrapper.feeOverride == true && OLIWrapper.feeOverrideAmountHidden != 0.00)) {
            OLIinstance.Fee_Override_Amount__c = OLIWrapper.feeOverrideAmountHidden;
        }
        else if(OLIWrapper.feeOverride == false) {
            OLIinstance.Fee_Override_Amount__c = null;
        }
        //END:D-2795 5/18/15 Added by Manolo Valena
        //END UD-0364 4/7/2015 MGaelo added feeOverrideAmount 
        OLIinstance.Override_Reason__c = OLIWrapper.overrideReason;
        OLIinstance.Suppress_Notification_Stop__c = OLIWrapper.suppressNotification; 
        OLIinstance.Delivered_By__c = 'asd';   
        OLIinstance.Main_Package_Billing_Type__c = subWrapper.packageBillingType;
        //system.debug('asdadasdsadxxxxxxxxxxx ' + publicationRec.Name);
        OLIinstance.Publication_1__c = OLIWrapper.publication1;
        OLIinstance.Publication_2__c = OLIWrapper.publication2;
        OLIinstance.Pending_Copies__c = OLIWrapper.copiespending1;
        OLIinstance.Pending_Copies_2__c = OLIWrapper.copiespending2;
        if(subWrapper.dowPattern == null){
            subWrapper.dowPattern = 'null';
        }        
        if(subWrapper.packageSubType != null){
            OLIinstance.Main_Package_Sub_Type__c = subWrapper.packageSubType;
        } else {
            OLIinstance.Main_Package_Sub_Type__c = 'null';
        }
        OLIinstance.Main_Package_Type__c = OLIWrapper.packageType;
        OLIinstance.Main_Package_ID__c = OLIWrapper.mainPackageId;
        
        return OLIinstance;   
    }
    
    /*Description: Method for checking records if urgent or f ee waived
     *Parameter: List<Order_Line_Item__c>
     *Return:
     */
    public void checkFieldsInOrder(List<Order_Line_Item__c> oLineList){   
        // START : D-1359 2/12/2015 Alyana Navarro
        Boolean isUrgent = false;
        Boolean isWaived = false;
        for(Order_Line_Item__c wrap : oLineList){
            if(wrap.Stop_Request_Date__c <= wrap.Earliest_Stop_Date__c){ // Start/End D-2768 17Apr15 JohnD - added =
                wrap.Urgent_Stop__c = TRUE;
                order.Urgent_Stop__c = TRUE;
                isUrgent = true;
            }
            if(wrap.fee_waiver__c == TRUE){
                order.isWaive__c = TRUE;
                wrap.Fee_Waiver__c = TRUE;
                isWaived = true;
            }
        }
        
        if(!isUrgent){
            order.Urgent_Stop__c = false;
        }
        if(!isWaived){
            order.isWaive__c = false;
        }
        // END : D-1359 2/12/2015
    }  
    
    /*Description: Gets the earliest start date.
    *Parameter: String 
    *Return: Date
    */
    public Date earliestStart (String packid){
        activateMaps(packid);
        Date earliestDate;
        List<String> pubcodes = new List<String>();
        List<Date> earliest = new List<Date>();
        
        for(Package_Item__c p : packageIdToPackageItemsMap.get(Id.valueOf(packid))){
            //Start MMallorca UD-0787 get all the pub details
            for(Integer ctr= 0; ctr < prodRatePlanIdToRatePlanChargesMap.get(p.Product_Rate_Plan__c).size();ctr++){ 
            //End  MMallorca UD-0787
                if (prodRatePlanIdToRatePlanChargesMap.get(p.Product_Rate_Plan__c) != null) {
                    //Start MMallorca UD-0787 Update selection of pubs
                    zqu__ProductRatePlanCharge__c pr = prodRatePlanIdToRatePlanChargesMap.get(p.Product_Rate_Plan__c)[ctr]; 
                    //End  MMallorca UD-0787
                    pubcodes.add(pr.PublicationCode__c);
                }
            //Start MMallorca UD-0787
            }
            //End  MMallorca UD-0787
        }
       
        
        for(String s : pubcodes){
            //START:D-3570 9/17/15 Added by Manolo Valena - Added if condition to avoid processing null pubcodes.
            if(s != null) {
                earliest.add(mapPubIdtoPubRecord.get(s));
            }
            //END:D-3570 9/17/15 Added by Manolo Valena
        }
        
        
        if(earliest.size()>0){    
            earliest.sort();
            earliestDate = earliest[0];
        }
        else{
            earliestDate = NULL;
        }   
        return(earliestDate);
        
    }
    
    /*Description: Sets the records for the maps to be used
    *Parameter: String
    *Return: NA
    */   
    public void activateMaps(String packid){
        packageIdToPackageItemsMap = new Map<Id, List<Package_Item__c>>();
        prodRatePlanIdToRatePlanChargesMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>(); 
        mapPubIdtoPubRecord = new Map<String, Date>();
        Id packageId = id.valueOf(packid);
        for(Publication__c publication : [SELECT Id, Name, Publication_Code__c, Earliest_Start_Date__c from Publication__c]){
            mapPubIdtoPubRecord.put(publication.Publication_Code__c, publication.Earliest_Start_Date__c);
        }
        
        for (Package_Item__c p : [SELECT Id, Package__c, Product_Rate_Plan__c, Name FROM Package_Item__c WHERE Package__c = :packageId ]){
            if(packageIdToPackageItemsMap.containsKey(p.Package__c)) {
                packageIdToPackageItemsMap.get(p.Package__c).add(p);
            }                                       
            else {
                packageIdToPackageItemsMap.put(p.Package__c, new List<Package_Item__c>{p});        
            }
            ratePlanCharge.add(p.Product_Rate_Plan__c);
        }
        
        //START SPH Code Review - 17-Feb-2015 Added by Raviteja - included remove(null) in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
        ratePlanCharge.remove(null);
        //End SPH Code Review - 17-Feb-2015 Added by Raviteja 

        for(zqu__ProductRatePlanCharge__c prodRatePlan : [SELECT Name, PublicationCode__c, zqu__ProductRatePlanCharge__c.zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c  = :ratePlanCharge]){
            if(prodRatePlanIdToRatePlanChargesMap.containsKey(prodRatePlan.zqu__ProductRatePlan__c)) {
                prodRatePlanIdToRatePlanChargesMap.get(prodRatePlan.zqu__ProductRatePlan__c).add(prodRatePlan);
            }                                       
            else {
                prodRatePlanIdToRatePlanChargesMap.put(prodRatePlan.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c>{prodRatePlan});        
            }
        }
    }
     
    /*Description: Method for redirecting from Edit Mode to View Mode
     *Parameter:
     *Return: PageReference
     */
    
    //START UD-2738 Wenjun 21/Sep/15 : Code Optimization - No Longer Used
    /*
    //Start: UD-0393 05/04/2015 James - add validation between stop request date and last invoice date
    public void checkInvoiceForBillingAccount(orderLineItemWrapper subscription){ 
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        passedInvoiceValidation = true;
        List<Zuora__Subscription__c> AddedSub = [SELECT Zuora__CustomerAccount__c, Billing_Type__c, Zuora__CustomerAccount__r.Name FROM Zuora__Subscription__c WHERE Name = :subscription.subscription Limit 1];
        if(AddedSub.size() > 0){
            if(AddedSub[0].Zuora__CustomerAccount__c != null && AddedSub[0].Billing_Type__c != null && AddedSub[0].Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID){
                invoiceList = [SELECT Zuora__InvoiceDate__c, Zuora__TargetDate__c FROM Zuora__ZInvoice__c WHERE Zuora__BillingAccount__c = :AddedSub[0].Zuora__CustomerAccount__c AND Zuora__Status__c != 'Cancelled' ORDER BY Zuora__TargetDate__c Desc LIMIT 1];
                if(invoiceList.size() > 0) {
                    targetDate = invoiceList[0].Zuora__TargetDate__c;
                    if(subscription.oliFieldAccess.stop_request_date__c < targetDate){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage('Stop Sub Invoice Error') + ': ' + targetDate.format('dd/MM/yyyy')));
                        passedInvoiceValidation = false;
                    }           
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage('COS Invoice Error2')));
                    passedInvoiceValidation = false;
                }
            }
        }
    }   
    //End: UD-0393 05/04/2015 James
    */
    //END UD-2738 Wenjun 21/Sep/15 : Code Optimization - No Longer Used
    
    public PageReference saveAsDraft(){
        order.Parent_Case__c = parentCaseId; 
        //id parentId = ApexPages.currentPage().getParameters().get('def_parent_id');
        system.debug('ASASASASASASASASASASA    ' + isSRDValid(relatedSubscriptionResultList));
        
        //START:D-2795 5/18/15 Added by Manolo Valena - New variables.
        List<Id> recs = new List<Id>();
        List<Id> recs2 = new List<Id>();
        //END:D-2795 5/18/15 Added by Manolo Valena
        //START:D-3344 8/10/15 Added by Manolo Valena
    List<Id> recs3 = new List<Id>();
    //END:D-3344 8/10/15 Added by Manolo Valena
        //START:D-2795 5/18/15 Added by Manolo Valena - Error message when save as draft button is clicked.
        for(OrderLineItemWrapper oliWrap : relatedSubscriptionResultList){
      //Start UD-2225 VPernicia 08/04/15
      if(!isSRDValid(oliWrap, getPublication(oliWrap))){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('Non Publication Date'));
        ApexPages.addMessage(msg);
        return null;
        break;
      }
      //End UD-2225 VPernicia 08/04/15
            if(oliWrap.feeOverride == true) {
                //START:UD-2074 7/25/15 Added by Manolo Valena - Updated conditions.  
                Decimal negOne = 0.00;
                if(oliWrap.feeOverrideAmount == null || oliWrap.feeOverrideAmount == GlobalVariableClass.EMPTYSTR) {
                    negOne = -1.00;
                }
                else {
                    negOne = Decimal.valueOf(oliWrap.feeOverrideAmount);
                } 
                if(oliWrap.feeOverrideAmountHidden != null && oliWrap.feeOverrideAmountHidden != 0.00) {
                    if(oliWrap.feeOverrideAmountHidden > oliWrap.adminFee) {
                        recs.add(oliWrap.Id);
                    }
                }
                else if((oliWrap.feeOverrideAmountHidden == null && (oliWrap.feeOverrideAmount == null || negOne < 0.00)) || 
                        (oliWrap.feeOverrideAmountHidden < 0.00 && (oliWrap.feeOverrideAmount == null || negOne < 0.00)) ||
                        (oliWrap.feeOverrideAmountHidden != null && (oliWrap.feeOverrideAmount == null || negOne < 0.00)) ||
                        (oliWrap.feeOverrideAmountHidden > 0.00 && (oliWrap.feeOverrideAmount == null || negOne < 0.00))) {
                    recs2.add(oliWrap.Id);    
                }
                //END:UD-2074 7/25/15 Added by Manolo Valena
        //START:D-3344 8/10/15 Added by Manolo Valena
        if(oliWrap.feeOverrideAmountHidden < 0.00) {
          recs3.add(oliWrap.Id);
        }
        //END:D-3344 8/10/15 Added by Manolo Valena
            }
            //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
            Case_Subscription__c latestCaseSub;
            
            if (subNameToCOACaseSubMap.containsKey(oliWrap.subscription)) {
                latestCaseSub = subNameToCOACaseSubMap.get(oliWrap.subscription);
                if (latestCaseSub.Case__r.Effective_Date__c >= oliWrap.oliFieldAccess.stop_request_date__c) {
                    //START: D-4097 12/17/15 Added by Manolo Valena
                    String errorMessage = 'There is a future COA transaction with effective date on ' + latestCaseSub.Case__r.Effective_Date__c + ' for the selected recipient contact. You shall void the existing COA transaction in order to proceed.';
                    //END: D-4097 12/17/15 Added by Manolo Valena

                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                    ApexPages.addMessage(myMsg);
                    return null;
                    break;
                }
            }
            //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
        }
        
        if(recs.size() > 0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'Fee Override Amount must be less than the Admin Fee.');
            ApexPages.addMessage(msg);
            return null;
        }
        if(recs2.size() > 0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter a Fee Override Amount.');
            ApexPages.addMessage(msg);
            return null;
        }
        //END:D-2795 5/18/15 Added by Manolo Valena
        //START:D-3344 8/10/15 Added by Manolo Valena - Error message when fee override amount is less than 0.
    if(recs3.size() > 0) {
      ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('FeeOverridePositiveAmount'));
      ApexPages.addMessage(msg);
      return null;
    }
    //END:D-3344 8/10/15 Added by Manolo Valena
    
        if(!isSRDValid(relatedSubscriptionResultList)){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('InvalidStopRequestDate'));
            ApexPages.addMessage(msg);
            return null;
        }
        
    //START:UD-3387 12/16/15 Added by Manolo Valena
        if(!isSRDValidEqualAfterStart(relatedSubscriptionResultList, allSubscriptionResultList)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_STOP_B4_START_DATE));
            return null;
        }
        //END:UD-3387 12/16/15 Added by Manolo Valena
        
        //START: D-4097 12/17/15 Added by Manolo Valena
        if(isAfterTStop(relatedSubscriptionResultList, allSubscriptionResultList) != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, isAfterTStop(relatedSubscriptionResultList, allSubscriptionResultList)));
            return null;
        }
        //END: D-4097 12/17/15 Added by Manolo Valena
        
        if(relatedSubscriptionResultList.size() == 0){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('No Subscription Selected'));
            ApexPages.addMessage(msg);
            return null;
        }
        //START:UD-1364 6/2/2015 Added by Manolo Valena - Commented out condition by James. To be removed.
        //Start: UD-0393 05/04/2015 James - add validation between stop request date and last invoice date
        /*if(passedInvoiceValidation == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage('Stop Sub Invoice Error')));
            return null;
        }*/
        //End: UD-0393 05/04/2015 James
        //END:UD-1364 6/2/2015 Added by Manolo Valena        
        
        //Start VPernicia D-0077 5/4/2015: add validation to check if Subscription End Date is greater than Stop Request Date
        if (isError == true) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Stop Request Date should not be greater than to Subscription End Date');
            ApexPages.addMessage(myMsg);  
            return null; 
        }
        //End VPernicia D-0077 5/4/2015: add validation to check if Subscription End Date is greater than Stop Request Date
        
        //START UD-2738 Wenjun 21/Sep/15 : No longer needed
        /*
            //START D-3224 Rebuild AddedBy FrancisBenzon : do not redirect if error
            if(passedInvoiceValidation == false)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage(stopTargetDateError)));
                return null;
            }
            //END D-3224 Rebuild AddedBy FrancisBenzon : do not redirect if error
        */
        //END UD-2738 Wenjun 21/Sep/15 : No longer needed
      
    //START:D-3330 8/17/15 Added by Manolo Valena
    Map<Id, List<OrderLineItemWrapper>> OLIToBundSubsMap = new Map<Id, List<OrderLineItemWrapper>>();
    Set<Date> uniqueDate; 
    Set<String> errSet = new Set<String>();
    //START: UD-3852 2-24-2016 Added by Kristine Balaoing - added variables for admin fee charging on bundled subscriptions
    Set<Boolean> feewaiverSet;
    Set<Boolean> feeOverrideValSet;
    Boolean isPerStpDate = false;
    Boolean isFeeWaiverDiff = false;
    Boolean isOverrideValueDiff = false;
    
    for(OrderLineItemWrapper oliwRec : relatedSubscriptionResultList) {
      if(subToOLIMap.containsKey(oliwRec.Id) && oliwRec.packageType == GlobalVariableClass.PACKAGETYPE_BUNDLE) {
        if(OLIToBundSubsMap.containsKey(subToOLIMap.get(oliwRec.Id))) {
          OLIToBundSubsMap.get(subToOLIMap.get(oliwRec.Id)).add(oliwRec);
        }
        else {
          OLIToBundSubsMap.put(subToOLIMap.get(oliwRec.Id), new List<OrderLineItemWrapper>{oliwRec});
        }
      }
    }
    
    if(OLIToBundSubsMap.keySet().size() > 0) {
        for(Id oliId : OLIToBundSubsMap.keySet()) {
            uniqueDate = new Set<Date>(); 
            feewaiverSet = new Set<Boolean>();
            feeOverrideValSet = new Set<Boolean>();
            
            for(OrderLineItemWrapper bundSubRec : OLIToBundSubsMap.get(oliId)) {
                uniqueDate.add(bundSubRec.oliFieldAccess.stop_request_date__c);
                feewaiverSet.add(bundSubRec.feeWaiver);
                feeOverrideValSet.add(bundSubRec.feeOverride);
            }

            if(uniqueDate.size() !=1){
                isPerStpDate = true;
            }
            if(feewaiverSet.size() !=1){
                isFeeWaiverDiff = true;
            }
            if(feeOverrideValSet.size() != 1){
                isOverrideValueDiff = true;
            }
                      
            if(isPerStpDate || isFeeWaiverDiff || isOverrideValueDiff) {
                Integer count = 0;
                String err = GlobalVariableClass.PACKAGETYPE_BUNDLE + GlobalVariableClass.COLON + GlobalVariableClass.SPACE;
                for(OrderLineItemWrapper bundSubRec : OLIToBundSubsMap.get(oliId)) {
                    count++;
                    if(OLIToBundSubsMap.get(oliId).size() != count) {
                        err = err + bundSubRec.subscription + GlobalVariableClass.COMMA + GlobalVariableClass.SPACE;
                    }
                    else {
                        err = err + bundSubRec.subscription + GlobalVariableClass.SPACE;
                    }
                }
                errSet.add(err);
            }
        }
    }
    
    if(errSet.size() > 0) {
        if(isPerStpDate){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage('BundleStopSubscriptionError')));
        }
        if(isFeeWaiverDiff){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage('BundleStopSubsFeeWaiverDifferenceError')));
        }
        if(isOverrideValueDiff){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage('BundleStopSubsOverrideValDiffError')));
        }
        for(String errMess : errSet) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, errMess));
        }
        return null;
    //END: UD-3852 2-24-2016 Added by Kristine Balaoing
    }
    //END:D-3330 8/17/15 Added by Manolo Valena
      
        if(order.status__c == GlobalVariableClass.STATUS_NEW){
            order.status__c = GlobalVariableClass.STATUS_DRAFT;
        }
        order.Eligible_for_Retention__c = retention;
        if(Send_to_Retention != null){
            order.Send_to_Retention__c = Send_to_Retention;
        }else{
            order.Send_to_Retention__c = false;
        }
        
        if (doSave() == true) {
                string retUrl = GlobalVariableClass.PAGEREFERENCE_TOVIEW + GlobalVariableClass.PARAMETER_ORDERID + '=' + order.Id + '&' 
                                + GlobalVariableClass.PARAMETER_ACCOUNTID + '=' + account.id + '&def_parent_id=' + parentCaseId;
                
                PageReference pgRef = new PageReference(retUrl);
                pgRef.setRedirect(true);
                return pgRef;
        
        } else {
                return null;
        }
    } 
    
    /*Description: Method for cancelling transaction
     *Parameter:
     *Return: PageReference
     */
    public PageReference doCancel(){
        PageReference pgRef;
        if(order.id == null){
            try {                       
                string retUrl = '/' + account.id;                
                pgRef = new PageReference(retUrl);
                pgRef.setRedirect(true);                                            
            } catch (exception e) {
                ApexPages.addMessages(e);
                return null;
            }
        } else {
        //START:D-2795 5/18/15 James
            if(order.status__c == 'Draft'){
                try {                       
                    string retUrl = '/' + account.id;                
                    pgRef = new PageReference(retUrl);
                    pgRef.setRedirect(true);                                            
                } catch (exception e) {
                    ApexPages.addMessages(e);
                    return null;
                }
            }else{
                try {                       
                    string retUrl = GlobalVariableClass.PAGEREFERENCE_TOVIEW + GlobalVariableClass.PARAMETER_ORDERID + '=' + order.Id + '&' 
                                + GlobalVariableClass.PARAMETER_ACCOUNTID + '=' + account.id;
                
                    pgRef = new PageReference(retUrl);
                    pgRef.setRedirect(true);                
                } catch (exception e) {
                    ApexPages.addMessages(e);
                    return null;
                }
            }
        }
        //End:D-2795 5/18/15 James
        return pgRef;
    }
    
    //START:D-2795 5/18/15 Added by Manolo Valena - New variables.
    public Decimal feeOverrideAmountCompare {get; set;}
    public Decimal feeAdminAmountCompare {get; set;}
    //END:D-2795 5/18/15 Added by Manolo Valena - Updated from Decimal to String
    
    //START:D-2795 5/18/15 Added by Manolo Valena - Method to check override values.
    public void checkIfAllowableAmount() {
        if(feeOverrideAmountCompare > feeAdminAmountCompare) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'Fee Override Amount must be less than the Admin Fee.');
            ApexPages.addMessage(msg);
        }
    }
    //END:D-2795 5/18/15 Added by Manolo Valena  
    //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
    public void checkExistingCOA (OrderLineItemWrapper oliWrapper) {
        Case_Subscription__c latestCaseSub;
        
        if (subNameToCOACaseSubMap.containsKey(oliWrapper.subscription)) {
            latestCaseSub = subNameToCOACaseSubMap.get(oliWrapper.subscription);
            if (latestCaseSub.Case__r.Effective_Date__c >= oliWrapper.oliFieldAccess.stop_request_date__c) {
                //START: D-4097 12/17/15 Added by Manolo Valena
                String errorMessage = 'There is a future COA transaction with effective date on ' + latestCaseSub.Case__r.Effective_Date__c + ' for the selected recipient contact. You shall void the existing COA transaction in order to proceed.';
                //END: D-4097 12/17/15 Added by Manolo Valena

                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription

    //START UD-2549 3/24/2016 Added by J.Sarion - set refund to 0
    public void setRefundToZero() {
        OrderLineItemWrapper oliWrapper = getSelectedSubscription();
        if(oliWrapper.oliFieldAccess.terminating_reason__c == 'Payment failure - PayPal' || oliWrapper.oliFieldAccess.terminating_reason__c == 'Payment failure - Credit card') {
            oliWrapper.refund = 0.00;
        }
        else {
            if(oliWrapper.oliFieldAccess.stop_request_date__c != null) {
                getRefund(oliWrapper);
            }
            else {
                oliWrapper.refund = 0.00;
            }
        }
    }
    //END UD-2549 3/24/2016 Added by J.Sarion - set refund to 0
}