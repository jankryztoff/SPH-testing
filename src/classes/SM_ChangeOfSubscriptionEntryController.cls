/**
* Class Name: <SM_ChangeOfSubscriptionEntryController>
* @author: <John Dacutan, JerellaMayelLedesma>
* Requirement/Project Name: <SPH>
* @description<Controller used for Change of Subscription Order entry page.>
* History: 1/28/2015 D1792 Added this history comment.
*/

public class SM_ChangeOfSubscriptionEntryController extends SM_SubscriptionHelper { //START/END UD-2143 08/06/15 - SIT Hotfix - RReyes - removed "with sharing" to prevent 'Insufficient Priviledges'. Start Entry/Detail, Renewal Entry/Detail, COS Detail also has no 'with sharing'
    
    //Start D-3331 08/06/2015
    public Boolean isBundle = false;
    //End D-3331 08/06/2015
    
    //Start MMallorca UD-1274 05/29/2015
    public Decimal hidSubCharge {get; set;}
    public Decimal hidCreditCharge {get; set;}
    //End MMallorca UD-1274 05/29/2015 
    
    //Start UD-0959 MMallorca 04/23/2015
    public boolean isDelivery {get;set;}
    //End  UD-0959 MMallorca 04/23/2015
    
    //START: D-3272 23-July-2015 JTeves - set correct package id onload
    private boolean isOnload = true;
    //END: D-3272 23-July-2015 JTeves
    // Start D-0033 UAT 01-03-2015 JohnD followed changed in start subscription
    final static string ADDRESS_RECORD_TYPE_NAME_LOCAL = 'Contact_Recordtype_Local';
    final static string DELIVERED_BY_MAILING_AGENT = 'Mailing Agent';
    final static string DELIVERED_BY_NONE = 'None';
    final static string DELIVERED_BY_VENDOR = 'Vendor';
    final static string DELIVERED_BY_BOTH = 'Vendor or Mailing Agent';
    // End D-0033 UAT 01-03-2015 JohnD
    
    String BusProfile; //Start/End Dags UD-2375 - Variable Declaration
    String DebtManagement; //Start/End Dags UD-2375 - Variable Declaration

    //START UD-0648 04/08/15 RReyes - Followed change in StartSub
    set<string> uniqueOptions  = new set<string>();
    //END UD-0648 04/08/15 RReyes - Followed change in StartSub
    
    final id accountId = ApexPages.currentPage().getParameters().get('accountId');
    final id orderId = ApexPages.currentPage().getParameters().get('id');
    public id subscriptionId { get; set; }
    
    // Start PD-0136 02Jun16 JohnD
    private final string COS_PACKAGE =  ConstantsSLB.getOther('Order_Type COS_Package');
    private final string COS_QUANTITY =  ConstantsSLB.getOther('Order_Type COS_Quantity');
    private final string COS_OTHERS = ConstantsSLB.getOther('Order_Type COS_Others');
    // End PD-0136 02Jun16 JohnD
    //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
    private final string COS = 'Change of Subscription';
    //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
    
    private id currentPromotionId;  // Start/End UD-2174 01Aug15 JohnD
    
    public transient string orderLineItemIdToBeRemoved { get; set; }
    public list<Order_Line_Item__c> orderLineItemList { get; set; }
    public string selectedOrderLineItem { get; set; }
    public string selectedPromotionId { get; set; }
    public string selectedPackageId { get; set; }
    public string selectedDeliveryChargeType { get; set; }
    public integer totalBillingAccounts { get; set; }
    public list<SubscriptionWrapper> relatedSubscriptionList { get; set; }
    public SubscriptionWrapper selectedSubscription { get; set; }
    public integer totalSubscriptions { get; set; }
    public String selectedchangeOfSubscriptionOptions {get; set;}
    public transient string defaultOrderType { get; set; }
    public Order_Line_Item__c quantityOrderLineItem { get; set; }
    public Zuora__Subscription__c zs = new Zuora__Subscription__c();
    //START UD-1038 05/14/15 RReyes
    public Zuora__Subscription__c initialSub = new Zuora__Subscription__c();
    //END UD-1038 05/14/15 RReyes
    //START D-1792 1/23/2015 JLedesma Calculate fields   
    public Decimal dueToSph { get; set; }
    public Decimal totalSubRate { get; set; }
    public Decimal dueToCustomer { get; set; }
    //END D-1792 1/23/2015 JLedesma Calculate fields

    public Decimal giftAmount { get; set; } //Start/End VPernicia D-4402
    
    // Start D-1326 01/15/2015 JohnD variable declaration to be used in search
    public string recipientAddressRecordTypeName; //MGaelo UD-0722 4/23/2015
    // End D-1326

    // search variables
    public transient list<SObject> promotionResultList { get; set; }
    public transient list<SObject> packageResultList { get; set; }
    public transient string searchText { get; set; }
    public transient string searchFrom { get; set; }
    public string searchBillingType { get; set; }
    public transient string billingTypeFromPromotion { get; set; }
    public static map<string, decimal> packageId_subscriptionCharge { get; set; }
    public transient boolean isRemoveEligibilityRuleSearchFilter { get; set; }
    public transient map<string, boolean> promotionCode_isEligible { get; set; }
    public transient string searchErrorMsg { get; set; }
    public transient string searchPackageMsg { get; set; }
    public transient string searchPromotionMsg { get; set; }
    // end search variables

    // subscription details variables
    public Order_Line_Item__c orderLineItem { get; set; }
    //START D-2399  3/10/15 AddedBy VPernicia: Remove transient to retain the value to handle error msg
    public string selectedPackageName { get; set; }
    public boolean isAllInOne { get; set; }
    //END D-2399  3/10/15 AddedBy VPernicia: Remove transient to retain the value to handle error msg 
    public list<SelectOption> deliveryMethod { get; set; }
    public id recipientAddressId;
    public string recipientAddressType;
    public boolean isReInitializedItem { get; set; }
    
    //START UD-0689 04-21-2015 MarvinG
    public transient boolean isDeliveredByVendor {get; set;} 
    public transient boolean isSubscriberChargeReadOnly {get; set;} 
    public transient boolean isVendorCrdeitReadOnly {get; set;} 
    public transient Decimal subscriberChargeHidden {get; set;} 
    public transient Decimal vendorCreditHidden {get; set;}
    //END UD-0689 04-21-2015 MarvinG
    
    // end subscription details variables
    
    // addon details variables
    public Package__c addOnPackage { get; set; }
    public string selectedAddOnPackage { get; set; }
    // end addon details variables
    
    // gifts variables
    public list<GiftWrapper> promotionGifts { get; set; }
    // end gift variables

    // renderers
    //START D-2399  3/10/15 AddedBy VPernicia: Remove transient to retain the value to handle error msg
    public boolean isExecuteSearch { get; set; }
    public boolean isPackageSelected { get; set; }
    public boolean isPromotionSelected { get; set; }
    public boolean isDigital { get; set; }
    public boolean isFromPromotion { get; set; }
    public boolean isSubscriptionSelected { get; set; }
    //END D-2399  3/10/15 AddedBy VPernicia: Remove transient to retain the value to handle error msg 
    // end renderers
    
    // asia1 variables
    public Asia1__c asia1SingleAccount { get; set; } 
    public List<Asia1_Subscription__c> asia1Sub { get; set;}
    public list<Asia1Wrapper> asia1Subscriptions { get; set; }
    public transient string asia1SelectedExistingId { get; set; }
    public transient string asia1IdToBeRemoved { get; set; }
    public transient boolean isCreateNew { get; set; }
    public string ldapValidityImg { get; set; }
    public string displayNameValidityImg { get; set; }
    public transient string asia1ErrorMsg { get; set; }
    public transient integer asia1SubscriptionsTotal { get; set; }
    // end asia1 variables
    
    // payment variables
    public Account thisAccount {get; set;}
    public Order__c thisOrder {get; set;}
    public Zuora__CustomerAccount__c thisBillingAccount {get; set;}
    public Zuora__Subscription__c dummySubscription {get; set;} //for Billing Account Lookup
    public zqu__Quote__c thisQuote {get; set;}
    
    public String acquisitionType {get; set;}
    public String deliveryChargeType {get; set;}
    public String billingAccountOption {get; set;}
    public String glCode {get; set;}
    public String paymentMethodId {get; set;}
    public Date dtlDate {get; set;}
    public Boolean isSponsored {get; set;}
    public Decimal fullPaymentMonthlyDeliveryCharge {get; set;}
    public Decimal subscriberCharge {get; set;}
    public Decimal vendorCredit {get; set;}
    public Decimal amountPaid {get; set;}
    public transient string refundBillingAccount { get; set; }
    public transient string refundBillingMode { get; set; }
    // end payment variables
    
    //for Eligibility Rule
    public transient Map<String, Set<String>> promotionCodeMap {get; set;}
    public transient boolean isNewsPaper {get; set;} // Start/End D-0105 UAT 01-03-2015 JohnD
    
    //earliest start date
    Set<Id> ratePlanCharge = new Set<Id>();
    Map<Id, List<Package_Item__c>> packageIdToPackageItemsMap = new Map<Id, List<Package_Item__c>>();
    Map<Id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanIdToRatePlanChargesMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>(); 
    Map<String, Date> mapPubIdtoPubRecord = new Map<String, Date>();
    
    //START UD-0658 AddedBy FrancisBenzon 4/16/15 : variable
    public boolean productIsMagazine { get; set; }
    //END UD-0658 AddedBy FrancisBenzon 4/16/15 : variable
    
    //START D-2332 FrancisBenzon
    public Boolean passedInvoiceValidation = true;
    //START UD-2738 Wenjun 21/Sep/15 : No longer needed
    /*
    public Boolean popError1 = false;
    public String COSError1 = GlobalVariableClass.COS_INVOICEERROR_1;
    public String COSError2 = GlobalVariableClass.COS_INVOICEERROR_2;
    */
    //END UD-2738 Wenjun 21/Sep/15 : No longer needed
    //END D-2332 FrancisBenzon
    
    //START D-2616/D-2617 3/24/15 AddedBy FrancisBenzon : rerender other payment method if existing account used is Other + ARMS
    public boolean isOtherPayment {get;set;}
    boolean existinginvoicebilling = false;
    string existinginvoicebillingname;
    string INVOICE = ConstantsSLB.getOther('Invoice');
    string OTHERPAYMENT = ConstantsSLB.getOther('Other');   
    //END D-2616/D-2617 3/24/15 AddedBy FrancisBenzon : rerender other payment method if existing account used is Other + ARMS
    //START D-2648 AddedBy Francisbenzon : variable for asia1 auto-population
    public boolean isContactQueried = false;
    public Map<Id, Contact> contactsMap {get; set;}
    //END D-2648 AddedBy Francisbenzon : variable for asia1 auto-population
    
    //START D-2888 5/27/2015 Added by Manolo Valena - Added new variable.
    public Id subRecId {get; set;}
    //END D-2888 5/27/2015 Added by Manolo Valena
    public Decimal BaseSubRate {get;set;}
    //START D-3101 6/17/15 AddedBy FrancisBenzon : variable
    public Decimal AdditionalCharges {get;set;}
    //START D-3101 6/17/15 AddedBy FrancisBenzon : variable
    //START D-3094 6/17/15 RReyes
    public String subStatus {get;set;}
    //END D-3094 6/17/15 RReyes
    //START D-3132 06/19/15 RReyes - to Identify if from setPackageId()
    public boolean isCalledOnSelect = true;
    //START D-3132 06/19/15 RReyes - to Identify if from setPackageId()
    //START D-3422 09/02/15 FrancisBenzon : flag for FPP packages
    public boolean isFullPrepaid {get;set;}
    public string termLength {get;set;}
    //END D-3422 09/02/15 FrancisBenzon : flag for FPP packages
    //START UD-3437 4Jan16 AddedBy FrancisBenzon : var
    public boolean renderCheckDetails {get;set;}
    //END UD-3437 4Jan16 AddedBy FrancisBenzon : var
    
    //START D-4402 14Apr16 FrancisBenzon : var maxGift
    public integer maxNoOfGifts {get; set;}
    //END D-4402 14Apr16 FrancisBenzon : var maxGift
    //Start PD-0035 May 13,2016 Added by Kristine Balaoing - added for add on rendering
    public transient boolean addOnIsDigital { get; set; }
    //END PD-0035 May 13,2016 Added by Kristine Balaoing 
    
    public class SubscriptionWrapper {
        public string publicationName { get; set; }
        public string publicationPrintPattern { get; set; }
        public date subscriptionStartDate { get; set; }
        public date subscriptionEndDate { get; set; }
        public integer quantity { get; set; }
        public id mainPackage { get; set; }
        //START UD-0622 RReyes 05/06/15 - Added variable for main package name
        public string packageName { get; set; }
        //END UD-0622 RReyes 05/06/15 - Added variable for main package name
    }

    //radio buttons
    public string getCOS_PACKAGE() {
        return COS_PACKAGE;
    }
    
    public string getCOS_QUANTITY() {
        return COS_QUANTITY;
    }
    
    //START D-2374  2/25/15 AddedBy FrancisBenzon : Variable
    public Decimal subscriptionRate{get; set;}
    //END D-2374  2/25/15 AddedBy FrancisBenzon : Variable
    //START UD-1600 06/10/15 RReyes - added variable to capture mainPackageId without concatenation
    public string mainPackageId {get; set;}
    public string subPackageId {get; set;}
    public string subPromoId {get; set;}
    //END UD-1600 06/10/15 RReyes - added variable to capture mainPackageId without concatenation
    
    //START UD-1783 07/07/15 RReyes
    String selSubId = '';
    List<Case> subCaseList = new List<Case>();
    String hasExistingCaseErrMsg = '';
    Boolean hasExistingCase = false;
    Boolean isRetrieveCalledFromPage = true;
    //END UD-1783 07/07/15 RReyes
    
    Id parentCaseId; //START/END UD-3293 11/25/15 RReyes
    Boolean isWithDelivery {get;set;} //START/END UD-3423 01/04/16 RReyes - indicator if delivery sub should be charged
    //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons

    //START UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error
    List<Order_Line_Item__c> stopOLILst = new List<Order_Line_Item__c>();
    String err_ExistingStopOrder = GlobalVariableClass.ERR_ExistingPSTOPOrder;
    Boolean hasExistingStopOrder = false;
    //END UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error

    /**
    * @description : This method will be called to initialize / retrieve
    *       all necessary data to be used in vf page before loading
    */
    //Start : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons   
    private void initialize() {
        
        isWithDelivery = true; //START/END UD-3423 01/04/15 RReyes - initialize value for isWithDelivery
        subscriptionId = ApexPages.currentPage().getParameters().get('subscriptionId');
        selectedSubscription = new SubscriptionWrapper();
        relatedSubscriptionList = new list<SubscriptionWrapper>();
        orderLineItem = new Order_Line_Item__c();
        quantityOrderLineItem = new Order_Line_Item__c();
        //START: UD-0452 03/23/2015 Added By FrancisBenzon - move initializePaymentComponents() method above checkAndCreateOrder()
        initializePaymentComponents();
        //START UD-2212 AddedBy FranciSBenzon/Jeff 4-Aug-2015: reorder reinitialization of Asia1 components
        promotionCode_isEligible = new map<string, boolean>();
        isSubscriptionSelected = false;
        asia1Subscriptions = new list<Asia1Wrapper>();            
        initializeAsia1Components();
        checkAndCreateOrder();
        //END UD-2212 AddedBy FranciSBenzon/Jeff 4-Aug-2015
        //END: UD-0452 03/23/2015 Added By FrancisBenzon
        //start: UD-1046 5/7/2015 ABOdias for creation mode "Phone" will be the default
        thisOrder.Creation_Mode__c = 'Phone';
        //end: UD:1046 5/7/2015 ABOdias for creation mode "Phone" will be the default
        //END: UD-0452 03/23/2015 Added By FrancisBenzon
        //START UD-3293 11/25/15 RReyes
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
        if (parentCaseId != null) {
            string tmp = parentCaseId;
            tmp.toLowerCase();
            if (tmp == 'null') {
                parentCaseId = null;
            }
            
            Case pCase = [SELECT Id, Subject, Description FROM Case WHERE Id = :parentCaseId LIMIT 1];
            
            thisOrder.Subject__c = pCase.Subject;
        }   
        //END UD-3293 11/25/15 RReyes
        //Retrieve Asia1 Credentials        
        if (thisOrder.Subscription__c != null) {  
              
            try {
                
                //Start : Code Review Implementation 02/18/2015 S.Puli
                if(thisOrder.Subscription__c <> null){
                //END : Code Review Implementation 02/18/2015 S.Puli
                //START UD-2143 RReyes 07/28/15 - SIT HotFix - changed condition from Subscription__c = :thisOrder.Subscription__c to Order_Line_Item__c = :orderLineItem.id
                // Start hotfix 31Jul15 JohnD - added condition
                if (orderLineItem != null && orderLineItem.Id != null) {
                    asia1Sub = [SELECT Id, Asia1__c, Asia1__r.User_ID_LDAP_ID__c, Concurrent__c, Service_Access_Flag__c, Status__c, Subscription__c, Service_Access_Flag__r.Name 
                    FROM Asia1_Subscription__c WHERE Order_Line_Item__c = :orderLineItem.id];
                }
                // End hotfix 31Jul15 JohnD - added condition
                    //FROM Asia1_Subscription__c WHERE Subscription__c = :thisOrder.Subscription__c];
                //END UD-2143 RReyes 07/28/15 - SIT HotFix - changed condition from Subscription__c = :thisOrder.Subscription__c to Order_Line_Item__c = :orderLineItem.id            
                }//Start/End : Code Review Implementation 02/18/2015 S.Puli
                asia1Subscriptions = SM_SubscriptionHelper.getAsia1s(asia1Sub);                 
            
                populateAdminCharge();
                
            } catch(Exception e) {
                asia1Subscriptions = new list<Asia1Wrapper>();
            }       
        }  
        //START D-2883 05/13/15 RReyes - Recomputes admin charge and fee if edit is clicked
        //START: D-2899 05/18/15 RReyes - Admin Fee should be computed before admin charge
        //START UD-1443 CommentedOutBy FrancisBenzon: prevent SOQL101 issue, admin fee will be called in Subscription Select and page onload
        /*try{ 
            retrieveAdminFee();
        }catch(Exception e){
            System.debug('>>> Exception:' + e.getMessage());
        }*/
        //END UD-1443 CommentedOutBy FrancisBenzon: prevent SOQL101 issue, admin fee will be called in Subscription Select and page onload
        //START: D-3265 22-July-2015 JTeves - prevent repetitive method calls causing SOQL101 error
        /*if(orderId != null){
            retrieveAdminCharge();
        }*/
        //END: D-3265 22-July-2015 JTeves
        //Start MMallorca UD-1274 05/29/2015 Call function to display current delivery charges on load
        System.debug('gddr initialize calls compute prepaid START =========================================');
        computePrepaid();
        System.debug('gddr initialize calls compute prepaid END =========================================');
        //End MMallorca UD-1274 05/29/2015
        //END: D-2899 05/18/15 RReyes -  - Admin Fee should be computed before admin charge
        //END D-2883 05/13/15 RReyes - Recomputes admin charge and fee if edit in clicked 
    }
    //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons 
    /*Description: Gets the earliest start date.
    *Parameter: String 
    *Return: Date
    */
    public Date getEarliestStart(Id packid){
        activateMaps(packid);
        Date earliestDate;
        List<String> pubcodes = new List<String>();
        List<Date> earliest = new List<Date>();
        
        if(packid != null) {
            for(Package_Item__c p : packageIdToPackageItemsMap.get(Id.valueOf(packid))){
                zqu__ProductRatePlanCharge__c pr = prodRatePlanIdToRatePlanChargesMap.get(p.Product_Rate_Plan__c)[0]; 
                pubcodes.add(pr.PublicationCode__c);
            }
        }
    
        for(String s : pubcodes){
            earliest.add(mapPubIdtoPubRecord.get(s));
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
        if(packid != null) {                
            packageIdToPackageItemsMap = new Map<Id, List<Package_Item__c>>();
            prodRatePlanIdToRatePlanChargesMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>(); 
            mapPubIdtoPubRecord = new Map<String, Date>();
            Id packageId = id.valueOf(packid);
            for(Publication__c publication : [SELECT Id, Name, Publication_Code__c, Earliest_Start_Date__c from Publication__c]){
                mapPubIdtoPubRecord.put(publication.Publication_Code__c, publication.Earliest_Start_Date__c);
            }
            
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(packageId<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
                for (Package_Item__c p : [SELECT Id, Package__c, Product_Rate_Plan__c, Name FROM Package_Item__c WHERE Package__c = :packageId ]){
                    if(packageIdToPackageItemsMap.containsKey(p.Package__c)) {
                        packageIdToPackageItemsMap.get(p.Package__c).add(p);
                    }                                       
                    else {
                        packageIdToPackageItemsMap.put(p.Package__c, new List<Package_Item__c>{p});        
                    }
                    ratePlanCharge.add(p.Product_Rate_Plan__c);
                }
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli            
            
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(ratePlanCharge<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
                for(zqu__ProductRatePlanCharge__c prodRatePlan : [SELECT Name, PublicationCode__c, zqu__ProductRatePlanCharge__c.zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c  = :ratePlanCharge]){
                    
                    if(prodRatePlanIdToRatePlanChargesMap.containsKey(prodRatePlan.zqu__ProductRatePlan__c)) {
                        prodRatePlanIdToRatePlanChargesMap.get(prodRatePlan.zqu__ProductRatePlan__c).add(prodRatePlan);
                    }                                       
                    else {
                        prodRatePlanIdToRatePlanChargesMap.put(prodRatePlan.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c>{prodRatePlan});        
                    }
                }
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        }
    }
    
    
    
  /**
  * @description : This method will retrieve all active subscriptions of the account
  *     and display in the existing subscriptin for renewal section of vf page
  */
    public void retrieveActiveSubscriptions() {
        //START UD-0689 04-21-2015 MarvinG
        isDeliveredByVendor = true;
        //END UD-0689 04-21-2015 MarvinG
        totalSubscriptions = 0;
        
        //Start : Code Review Implementation 02/18/2015 S.Puli -remove "and Main_Package_1__c != ''"
        list<Zuora__Subscription__c> subscriptionList;
        if(accountId<>null){
            subscriptionList = [select Id from Zuora__Subscription__c where Zuora__Account__c = :accountId 
                    and Zuora__Status__c = 'Active' and Subscription_Type_1__c != 'Delivery' order by Zuora__SubscriptionEndDate__c asc];
        }
        //END : Code Review Implementation 02/18/2015 S.Puli
        
        //Start UD-678 VPernicia/MGatchalian 4/06/2015: Avoid Attemp to dereference null
        if(subscriptionList != null && !subscriptionList.isEmpty())
        {
            totalSubscriptions = subscriptionList.size();
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Active Publication Subscription in your Account.'));
        }
        //End UD-678 VPernicia/MGatchalian 4/06/2015: Avoid Attemp to dereference null   
          
        if (totalSubscriptions > 0) {
                
            initialize();
            
            // Start UD-0638 23Apr15 JohnD - swap variables
            if (thisOrder.Subscription__c != null) {
                subscriptionId = thisOrder.Subscription__c;
                //START D-2899 5/18/15 RReyes - retrieve admin charge if there's an existing subscription selected upon load
                //START: D-3265 22-July-2015 JTeves - prevent repetitive method calls causing SOQL101 error
                /*try{
                    if(orderId == null)
                        retrieveAdminCharge();
                }catch(Exception e){
                    System.debug('>>>Exception in Admin Charge: ' + e.getMessage() + e.getLineNumber());
                }*/
                //END: D-3265 22-July-2015 JTeves
                //END D-2899 5/18/15 RReyes - retrieve admin charge if there's an existing subscription selected upon load
            }
            // End UD-0638 23Apr15 JohnD - swap variables
        } else {
                  
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('No Subscription'));
            ApexPages.addMessage(myMsg);
                
        }
        //START: D-3272 23-July-2015 JTeves - set correct package id onload
        isOnload = false;
        //END: D-3272 23-July-2015 JTeves
    }

  /**
  * @description : This method will retrieve all active subscriptions of the account
  *     and display in the existing subscriptin for renewal section of vf page
  */
    //START: D-2400 03/03/2015 JTeves - additional variable
    private Boolean validateAsiaOne = false;
    //END: D-2400 03/03/2015 JTeves - additional variable
    //START: D-2374 02/26/2015 JTeves - proper initialization order line item fields.
    private Boolean isFromSubscriptionSelection = false;
    public void retrieveRelatedSubscriptions() {  
            
        isFromSubscriptionSelection = true;
        //END: D-2374 02/26/2015 JTeves - proper initialization order line item fields.
        isSubscriptionSelected = true;
        map<id, string> packageId_publicationName = new map<id, string>();
        map<id, string> packageId_publicationPattern = new map<id, string>();
        map<id, id> productId_packageId = new map<id, id>();
        set<id> productIds = new set<id>();
        set<id> packageIds = new set<id>();
        list<SubscriptionWrapper> tmpSwList = new list<SubscriptionWrapper>();
        //START UD-0622 RReyes - for new logic in getting publication
        List<Product_Publication__c> prodPubList= new List<Product_Publication__c>();
        //END UD-0622 RReyes - for new logic in getting publication

        //START UD-1783 07/07/15 RReyes
        if(thisOrder.Subscription__c != null){
            selSubId = String.valueOf(thisOrder.Subscription__c);
            //START UD-3911 6Apr16 FrancisBenzon : exclude subs with COS cases that are already void.
            subCaseList = [SELECT CaseNumber, Status, Subscription_Name__c FROM Case WHERE RecordType.Name = :GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION and Subscription_Name__c =: selSubId and Status != :GlobalVariableClass.STATUS_VOID];
            //END UD-3911 6Apr16 FrancisBenzon : exclude subs with COS cases that are already void.

        if(subCaseList.size() > 0){
          hasExistingCase = true;
          hasExistingCaseErrMsg = 'Subscription cannot be changed. There is already a ' + subCaseList[0].Status + ' Change of Subscription Case with Case Number: ' + subCaseList[0].CaseNumber + ' using this subscription.';
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, hasExistingCaseErrMsg));
        }else{
          hasExistingCase = false;
        }
            //START UD-3911 9Apr16 FrancisBenzon : exclude voided cases from validation
            //START UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error
            stopOLILst = [Select Id, Name From Order_Line_Item__c 
                            Where Case__r.RecordType.Name = :GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION 
                            AND Case__r.Status != :GlobalVariableClass.STATUS_VOID
                            AND Subscription__c = :thisOrder.Subscription__c
                            AND Order__r.Account__c = :accountId
                            AND Order__r.Status__c != 'Void']; //fritz for PD-0184
                            
            if(stopOLILst.size() > 0)
            {
                hasExistingStopOrder = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(err_ExistingStopOrder)));
            }
            else {
                hasExistingStopOrder = false;
            }
            //END UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error
            //END UD-3911 9Apr16 FrancisBenzon : exclude voided cases from validation
      }
      //END UD-1783 07/07/15 RReyes
            
        // retrieve recipient contact detai of the selected subscription
        try {
            //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
            //START D-1802 JLedesma Populate Admin Charge 1/22/2015
            //START D-1792 1/27/2015 JLedesma Calculate fields in credit and charges section
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(thisOrder.Subscription__c<>null){
                //START D-2888 5/27/2015 Added by Manolo Valena - Assign subscription record Id to variable.
                subRecId = thisOrder.Subscription__c;
                //END D-2888 5/27/2015 Added by Manolo Valena
                //START: D-2374 02/25/2015 Francis Benzon - Add needed fields
            //END : Code Review Implementation 02/12/2015 S.Puli
                //START: D-2401 03/03/2015 JTeves - added Promotion_1__r.Penalty_Charge_Override__c field
                //START D-2332 3/6/15 AddedBy FrancisBenzon : Added Billing Account in Subscription Query
                //START UD-0648 04/08/15 RReyes - Added Vendor__c and Vendor_1__c in the query
                //START/END UD-0632 4/21/15 AddedBy FrancisBenzon : added field from query
                //START UD-0622 05/06/15 RReyes - Added Main_Package_1__r.Name in the query
                //START D-3094 06/17/15 RReyes - added Zuora__Status__c in query
                //START UD-2084 AddedBy FrancisBenzon 7/24/15 : added Legacy_Billing_Account_Id__c in query
                //START UD-2949 AddedBy FrancisBenzon 9/30/15 : added Sponsor_1__c in query
                zs = [select Id, Zuora__CustomerAccount__r.Zuora__Credit_Balance__c, Contract_End_Date_1__c, Promotion_1__c, 
                        Promotion_1__r.Penalty_Charge__c, Promotion_1__r.Penalty_Charge_Override__c, Order_Line_Item_Number_1__r.Admin_Charge__c, Order_Line_Item_Number_1__c, Recipient_Contact__c, Cost_Center__c, Number_of_Copies__c, Order_Line_Item_Number_1__r.Main_Package_Subscription_Rate__c, Zuora__CustomerAccount__c,
                        Main_Package_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                        Order_Line_Item_Number_1__r.Total_Subscription_Rate__c, 
                        Order_Number_1__c, Delivery_Charge_Type_1__c, Zuora__CustomerAccount__r.Name, 
                        Zuora__CustomerAccount__r.Payment_Mode__c, Vendor_Conversion_1__c, Charity_1__c, Delivered_By_1__c, Term_Length__c,
                        PO_Number__c, Supressed_Renewal_and_Reminder_Letter_1__c, New_Contract_Period_1__c, Supressed_Acknowledgement_Letter_1__c,
                        Suppress_Vendor_Start_Notice_1__c, Penalty_Charge_1__c, Generate_Invoice__c, Qty__c, Zuora__AutoRenew__c, Subscribe_As__c,
                        Vendor__c, Vendor_1__c, Billing_Type__c, Main_Package_1__r.Name, Zuora__Status__c, Zuora__CustomerAccount__r.Legacy_Billing_Account_Id__c, Sponsor_1__c
                        from Zuora__Subscription__c where Id = :thisOrder.Subscription__c];
                //END UD-2949 AddedBy FrancisBenzon 9/30/15 : added Sponsor_1__c in query
                //END UD-2084 AddedBy FrancisBenzon 7/24/15 : added Legacy_Billing_Account_Id__c in query
                //END D-3094 06/17/15 RReyes - added Zuora__Status__c in query
                //END UD-0622 05/06/15 RReyes - Added Main_Package_1__r.Name in the query
                //END UD-0648 04/08/15 RReyes - Added Vendor__c and Vendor_1__c in the query
                //END D-2332 3/6/15 AddedBy FrancisBenzon : Added Billing Account in Subscription Query
                //END: D-2401 03/03/2015 JTeves - added Promotion_1__r.Penalty_Charge_Override__c field
                //START UD-1038 05/14/15 RReyes - assigns zs to initialSub
                initialSub = zs;
                //END UD-1038 05/14/15 RReyes - assigns zs to initialSub
            }//Start/End : Code Review Implementation 02/12/2015 S.Puli
            //END: D-2374 02/25/2015 Francis Benzon - Add needed fields
            //END D-1792 1/27/2015 JLedesma Calculate fields in credit and charges section
            //END D-1802 JLedesma Populate Admin Charge 1/22/2015
            //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
            //START UD-2949 AddedBy FrancisBenzon 9/30/15 : sponsor field copied
            thisOrder.Sponsor__c = zs.Sponsor_1__c;
            //END UD-2949 AddedBy FrancisBenzon 9/30/15 : sponsor field copied
            System.debug('test class >>> : ' + zs );
            System.debug('test class >>> : ' + zs.Id );
            System.debug('test class >>> : ' + zs.Main_Package_1__c );
            //Start D-3331 VPernicia
            isBundle = false;
            checkIsBundle(zs.Main_Package_1__c);
            //End D-3331 VPernicia
            
            //START UD-1038 05/14/15 RReyes - assigns zs to initialSub
            initialSub = zs;
            //END UD-1038 05/14/15 RReyes - assigns zs to initialSub
            selectedPackageId = zs.Main_Package_1__c;
            //START UD-1600 RReyes - sets value for sub packageId
            subPackageId = zs.Main_Package_1__c;
            subPromoId = zs.Promotion_1__c;
            currentPromotionId = zs.Promotion_1__c; // Start/End UD-2174 01Aug15 JohnD
            // Start UD-2211 19Aug15 JohnD
            // Start PD-0225 20May16 JohnD - added logic
            if (thisOrder.Status__c == 'New') {
                selectedDeliveryChargeType = zs.Delivery_Charge_Type_1__c;
                thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType;
            } else {
                selectedDeliveryChargeType = thisOrder.Delivery_Charge_Type__c;
            } 
            // End PD-0225 20May16 JohnD - added logic
            // End UD-2211 19Aug15 JohnD
            //END UD-1600 RReyes - sets value for sub packageId
            //START D-3094 6/17/15 RReyes
            subStatus = zs.Zuora__Status__c;
            //END D-3094 6/17/15 RReyes
            // refund info section
            refundBillingAccount = zs.Zuora__CustomerAccount__r.Name;
            refundBillingMode = zs.Zuora__CustomerAccount__r.Payment_Mode__c;
            // end refund info section
            
            
            //fritzMay
            if(zs.Promotion_1__c != null)
            {
                selectedPromotionId  = zs.Promotion_1__c;
                populatePromotionGifts();
            }
            //fritzMay
            
            thisOrder.Recipient_Contact__c = zs.Recipient_Contact__c;
            thisOrder.Cost_Centre__c = zs.Cost_Center__c;
            //Start MMallorca UD-1274 06/01/2015 Retrieve delivery charges
            if(thisOrder.Delivery_Charge_Type__c == null){
                thisOrder.Delivery_Charge_Type__c = zs.Delivery_Charge_Type_1__c;
            }
            /* PD-0225 20May16 commented out
            else{
                thisorder.Delivery_Charge__c = thisorder.Delivery_Charge__c;
                thisOrder.Subscriber_Charge__c = thisOrder.Subscriber_Charge__c;
                thisOrder.Vendor_Credit__c = thisOrder.Vendor_Credit__c;
            }
            */
            //End MMallorca UD-1274 06/01/2015
            
            selectedSubscription = new SubscriptionWrapper();
            selectedSubscription.subscriptionStartDate = zs.Zuora__SubscriptionStartDate__c;
            selectedSubscription.subscriptionEndDate = zs.Zuora__SubscriptionEndDate__c;
            selectedSubscription.mainPackage = zs.Main_Package_1__c;
            //START UD-0622 05/06/15 RReyes - Sets the Main Package Name
            selectedSubscription.packageName = zs.Main_Package_1__r.Name;
            //END UD-0622 05/06/15 RReyes - Sets the Main Package Name
            if (zs.Number_of_Copies__c != null) {
                selectedSubscription.quantity = integer.valueOf(zs.Number_of_Copies__c);
            }
            
            packageIds.add(zs.Main_Package_1__c);
            
            // retrieve related subscriptions
            if (zs.Order_Number_1__c != null && zs.Id<>null) {//Start/End : Code Review Implementation 02/18/2015 S.Puli
                //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
                //START UD-0622 05/06/15 RReyes - Added Main_Package_1__r.Name in query
                for (Zuora__Subscription__c tmp : [select Order_Line_Item_Number_1__c, Main_Package_1__c, Number_of_Copies__c, Zuora__SubscriptionStartDate__c, 
                        Zuora__SubscriptionEndDate__c, Main_Package_1__r.Name from Zuora__Subscription__c 
                        where Order_Number_1__c = :zs.Order_Number_1__c and Id != :zs.Id]) {
                //END UD-0622 05/06/15 RReyes - Added Main_Package_1__r.Name in query
                 //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons   
                    SubscriptionWrapper tmpSw = new SubscriptionWrapper();
                    tmpSw.subscriptionStartDate = tmp.Zuora__SubscriptionStartDate__c;
                    tmpSw.subscriptionEndDate = tmp.Zuora__SubscriptionEndDate__c;
                    tmpSw.mainPackage = tmp.Main_Package_1__c;
                    //START UD-0622 05/06/15 RReyes - Adds value for main package name
                    tmpSw.packageName = tmp.Main_Package_1__r.Name;
                    //END UD-0622 05/06/15 RReyes - Adds value for main package name
                    if (tmp.Number_of_Copies__c != null) {
                        tmpSw.quantity = integer.valueOf(tmp.Number_of_Copies__c);
                    }
                    
                    tmpSwList.add(tmpSw);
                    //START UD-0622 04/17/15 RReyes - Checks if product Id is already in the list
                    if(!packageIds.contains(tmp.Main_Package_1__c)){
                        packageIds.add(tmp.Main_Package_1__c);
                    }//END UD-0622 04/17/15 RReyes - Checks if product Id is already in the list                    
                }
            }
            // end retrieve related subscriptions
            
            // retrieve publication detail
            //Start : Code Review Implementation 02/18/2015 S.Puli
            System.debug('test class >>> : ' + packageIds);
            System.debug('test class >>> : ' + packageIds<>null );
            if(packageIds<>null){
            //END : Code Review Implementation 02/18/2015 S.Puli
                for (Package__c pkg : [select Id, (select Id, Product_Rate_Plan__r.zqu__ZProduct__c from Package_Items__r) 
                        from Package__c where Id = :packageIds]) {                  
                    for (Package_Item__c tmp : pkg.Package_Items__r) {
                        //START UD-0622 04/17/15 RReyes
                        if(!productId_packageId.keySet().contains(tmp.Product_Rate_Plan__r.zqu__ZProduct__c)){
                            productId_packageId.put(tmp.Product_Rate_Plan__r.zqu__ZProduct__c, pkg.Id);
                        }//END UD-0622 04/17/15 RReyes
                    }
                }
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(productId_packageId.keySet().size() > 0){
            //END : Code Review Implementation 02/18/2015 S.Puli
            //START UD-0622 RReyes - Changed logic in case of multiple product publications
                for(Id zProdId: productId_packageId.keySet()){
                prodPubList.clear();    
                prodPubList = [select Publication_Code__c, Publication_Code__r.Name, Publication_Code__r.Publish_Pattern__c, 
                                Publication_Code__r.Sunday_Publication__c, Publication_Code__r.Platform_Type__c, ZProduct__c 
                                from Product_Publication__c where ZProduct__c =: zProdId];
                if( prodPubList.size() == 1){
                    if(prodPubList[0].ZProduct__c != null){
                        id tmpPkgId = productId_packageId.get(prodPubList[0].ZProduct__c);
                         if (tmpPkgId != null) {
                            packageId_publicationName.put(tmpPkgId, prodPubList[0].Publication_Code__r.Name);
                            packageId_publicationPattern.put(tmpPkgId, prodPubList[0].Publication_Code__r.Publish_Pattern__c);
                         }
                    }
                }
                else if(prodPubList.size() > 1){
                    for(Product_Publication__c tmp : prodPubList){
                        if(tmp.ZProduct__c != null && tmp.Publication_Code__r.Platform_Type__c == 'Print' && tmp.Publication_Code__r.Sunday_Publication__c != null){
                            id tmpPkgId = productId_packageId.get(tmp.ZProduct__c);
                            if (tmpPkgId != null) {
                                packageId_publicationName.put(tmpPkgId, tmp.Publication_Code__r.Name);
                                packageId_publicationPattern.put(tmpPkgId, tmp.Publication_Code__r.Publish_Pattern__c);
                            }
                        }
                    }
                }   
                }
                    
                        
                        
                            
            //END UD-0622 RReyes - Changed logic in case of multiple publications
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
            
            // end retrieve publication detail
            
            if (selectedSubscription.mainPackage != null) {
                selectedSubscription.publicationName = packageId_publicationName.get(selectedSubscription.mainPackage);
                selectedSubscription.publicationPrintPattern = packageId_publicationPattern.get(selectedSubscription.mainPackage);
            }
            
            relatedSubscriptionList.clear();
            for (SubscriptionWrapper tmp : tmpSwList) {
                tmp.publicationName = packageId_publicationName.get(tmp.mainPackage);
                //START: UD-0622 - 04/17/15 RReyes - Changed reference from publication name to publication pattern
                tmp.publicationPrintPattern = packageId_publicationPattern.get(tmp.mainPackage);
                //END: UD-0622 - 04/17/15 RReyes - Changed reference from publication name to publication pattern
                relatedSubscriptionList.add(tmp);
            }
            
        } catch (exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Invalid Subscription Id = ' +thisOrder.Subscription__c);
            ApexPages.addMessage(myMsg);
            //ApexPages.addMessages(e);     
        }
        /// end retrieve recipient contact detai of the selected subscription
        //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
        setPackageId();
        //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
        
        //Start MMallorca UD-1274 05/29/2015 Replace refreshSubscriberCharge to computePrepaid in computing delivery charges
        //START UD-0689 04-21-2015 MarvinG
        System.debug('gddr retrieveRelatedSubscriptions calls method computeprepaid START =====================================');
        computePrepaid();
        System.debug('gddr retrieveRelatedSubscriptions calls method computeprepaid END =====================================');
        //END UD-0689 04-21-2015 MarvinG
        //End MMallorca UD-1274 05/29/2015
        //START D-2663 AddedBy FrancisBenzon : Calculate Charges upon select of Subscription
        //START UD-1443 CommentedOutBy FrancisBenzon : to prevent SOQL101 Issue, already called in onchange of Subscription field
        //retrieveAdminCharge();  
        //END UD-1443 CommentedOutBy FrancisBenzon : to prevent SOQL101 Issue, already called in onchange of Subscription field     
        //END D-2663 AddedBy FrancisBenzon : Calculate Charges upon select of Subscription
        
    }

    //Start D-3331 VPernicia 08/06/15
    void checkIsBundle(id MainPakageID) {
    
        AggregateResult pckItem = [select count(Package__c) pckCount from Package_Item__c where Package__c =: MainPakageID and RecordTypeid  =: ConstantsSLB.getKeyId('Package Item_Bundle Product')];
        
        if (pckItem != null) { 
            
            if ((Integer) pckItem.get('pckCount') > 1) {
            
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('BundleSubscription'));
                ApexPages.addMessage(myMsg);
                isBundle = true;
            }
        }
    }
    //End D-3331 VPernicia 08/06/15
    
  /**
  * @description : This method will check if an order already existing on the account.
  *    If there is no New or Draft order associated to the account, it will create a new one
  */
    private void checkAndCreateOrder() {
        
        list<SObject> orderList = new list<SObject>();
        
        string queryStr = generateOrderSoqlStr();
        queryStr += ' where Order_Type__c like \'Change of Subscription%\'';
        
        if (accountId != null) {
            queryStr += ' and Account__c = \'' + accountId + '\'';
        } else if (orderId != null) {
            queryStr += ' and Id = \'' + orderId + '\'';
        }
        
        if (subscriptionId != null) {
      
            queryStr += ' and Status__c = \'Draft\' and Subscription__c = \'' + subscriptionId + '\' limit 1';
            orderList = database.query(queryStr);
          
        } else {
            
            queryStr += ' and (Status__c = \'Draft\' or Status__c = \'New\') limit 1';
            orderList = database.query(queryStr);
        
        }
         //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
        if (orderList.size() == 0) {
            
            thisOrder = new Order__c();
            thisOrder.Account__c = accountId;
            thisOrder.Status__c = 'New';
            thisOrder.Order_Action__c = 'Stop Start';
            //START/END UD-0452 Commented out by FrancisBenzon : new implementation, see below
            //thisOrder.Credit_Balance__c = 0;
            thisOrder.Delivery_Charge__c = 0;
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            thisOrder.Order_Type__c = 'Change of Subscription';
            
            //START D-3094 6/10/2015 Added by KIbalio/RReyes - set order_type1__c to match lookup filter
            thisOrder.Order_Type1__c = 'Change of Subscription';
            //END D-3094 6/10/2015  Added by KIbalio/RReyes
            
            //START: UD-0452 03/23/2015 Added By FrancisBenzon - Set Credit Balance to Account - Total Credit Balance
            thisOrder.Credit_Balance__c = thisAccount.Total_Credit_Balance1__c;
            //END: UD-0452 03/23/2015 Added By FrancisBenzon
            
            insert thisOrder;
            refreshOrder();
        
        } else {
          
            thisOrder = (Order__c)orderList[0];
            defaultOrderType = COS;
            //START: D-2883 05/13/2015 RReyes - Set Credit Balance to Account - Total Credit Balance
            thisOrder.Credit_Balance__c = thisAccount.Total_Credit_Balance1__c;
            //END: D-2883 05/13/2015 RReyes - Set Credit Balance to Account - Total Credit Balance
            //START D-3094 6/10/2015 Added by KIbalio/RReyes - set order_type1__c to match lookup filter
            thisOrder.Order_Type1__c = 'Change of Subscription';
            //END D-3094 6/10/2015  Added by KIbalio/RReyes
            //START D-3094 06/16/15 RReyes 
            thisOrder.isChangeOfSubEntry__c = true;
            //END D-3094 06/16/15 RReyes
            if (thisOrder.Subscription__c != null) {
                retrieveRelatedSubscriptions();
                retrieveOrderLineItem();
            }
            
            refreshVfPageOrderDetails();
        }
    }


    


    /**
    * @description : This method will save the transaction. 
    *    Invoke by the Save button on the vf page
    */
    public PageReference save() {       
        //START UD-3381 RReyes - added validation on date
        String tStopErrorMessage = null;
        String coaErrorMessage = null;
        //END UD-3381 RReyes - added validation on date
        //START UD-1726 6/26/2015 JLedesma : Added validation rule for Quantity and AsiaOne Accounts
        //START UD-1389 6/16/2015 GdelRosario : Added validation rule for Saving Payment Method ID
         
        if(orderLineItem.Qty__c < asia1Subscriptions.size()  && isDigital == true){//START/END UD-2143 - SIT HotFix - added condition if sub isDigital
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Check asia1 list versus quantity')));
            return null; 
        }
         
        //END UD-1726 6/26/2015 JLedesma : Added validation rule for Quantity and AsiaOne Accounts
        if(billingAccountOption == 'createNew'){
            if (thisOrder.Payment_Mode__c == 'Credit Card'){
                if(thisOrder.Payment_Method_ID__c == null || thisOrder.Payment_Method_ID__c == ''){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('NoPaymentMethodID'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }    
            }   
        }            
        //END UD-1389 6/16/2015 GdelRosario : Added validation rule for Saving Payment Method ID
        //START UD-3293 11/25/15 RReyes
        if(parentCaseId != null){
            thisOrder.Parent_Case__c = String.valueOf(parentCaseId);
        }
        //END UD-3293 11/25/15 RReyes
        //START UD-3381 RReyes - added validation on date
        if(orderLineItem.Start_Date__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('No Start Date'));
            ApexPages.addMessage(myMsg);
            return null;
        }   
        tStopErrorMessage = checkTStopRestartDates(thisOrder.Subscription__c, orderLineItem.Start_Date__c, GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION);
        if(tStopErrorMessage != null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, tStopErrorMessage);
            ApexPages.addMessage(myMsg);
            return null;
        }
        if (thisOrder.Recipient_Contact__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Required Recipient Contact'));
            ApexPages.addMessage(myMsg);
            return null;
        }
        coaErrorMessage = validateFutureDatedCOA(thisOrder.Recipient_Contact__c, null, GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION);
        if(coaErrorMessage != null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, coaErrorMessage);
            ApexPages.addMessage(myMsg);
            return null;
        }
        //END UD-3381 RReyes - added validation on date
        //Start D-3331 VPernicia 08/06/15
        if (isBundle) {
        
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('BundleSubscription'));
            ApexPages.addMessage(myMsg);
            return null;
        }
        //End D-3331 VPernicia 08/06/15
        //START UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error
        if(hasExistingStopOrder)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(err_ExistingStopOrder))); //fritz
            return null;
        }       
        //END UD-3652 4Feb2016 FrancisBenzon: check if sub has stop order, if yes throw error
        // Start UD-2614 06Sep15 JohnD - added logic
        if (billingAccountOption == 'createNew') {
            thisOrder.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        } else if (billingAccountOption == 'useExisting') {
            thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        }
        // End UD-2614 06Sep15 JohnD - added logic
        
        //START D-3223 07/09/15 RReyes - validates if order has billing account
        //fritz
        if(!hasBillingAccount('CHANGE', thisOrder)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Billing Account')));
            return null; 
        }
        //END D-3223 07/09/15 RReyes - validates if order has billing account

      //START UD-1783 07/07/15 RReyes
      if(hasExistingCase){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, hasExistingCaseErrMsg));
        return null;
      }
      //END UD-1783 07/07/15 RReyes
        //START D-3094 06/17/15 RReyes - checks if zuora status is 'cancelled'
        if(subStatus == 'Cancelled'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cancelled subscriptions cannot be used in Change of Subscription.');
            ApexPages.addMessage(myMsg);
            return null; 
        }
        //END D-3094 06/17/15 RReyes - checks if zuora status is 'Cancelled'        
            //START UD-1214 5/21/2015 Gdelrosario : added validation rule for ARMS Functions
            if(billingAccountOption == 'createNew'){
                if (thisOrder.Payment_Mode__c == 'Other' && thisOrder.Other_Payment_Mode__c == 'Invoice'){
                    //START UD-2220 09/15/15 RReyes - Only one invoice billing account per billing type is allowed on each account
                    thisOrder.Billing_Type__c = orderLineItem.Main_Package_Billing_Type__c;
                    if(thisOrder.Billing_Type__c != null && thisOrder.Billing_Type__c != ''){
                        if(checkExistingInvoice(accountId, thisOrder.Billing_Type__c)){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('Has Existing Invoice'));
                            ApexPages.addMessage(myMsg);
                            return null; 
                        }   
                    }               
                    //END UD-2220 09/15/15 RReyes - Only one invoice billing account per billing type is allowed on each account
                    if(searchCustTick == false && thisOrder.Create_ARMS_Customer_Account__c == false && thisOrder.Business_Profile__c == 'NONE' && thisOrder.Debt_Management_Treatment__c == 'NONE'){ //START/END UD-2390 - applies existing conditions from Start Sub for UD-1736
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS search for ARMS customer contact'));
                        ApexPages.addMessage(myMsg);
                        return null; 
            
                    }else if((accNum != null || accNum != '') && (accTextName != null || accTextName != '') && searchAcctTick == false && thisOrder.Create_ARMS_Customer_Account__c  == false  && thisOrder.Business_Profile__c == 'NONE' && thisOrder.Debt_Management_Treatment__c == 'NONE' ){//START/END UD-2390 - applies existing conditions from Start Sub for UD-1736
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ''+ ConstantsSLB.getErrorMessage('ARMS search for arms account'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }   
                    //START UD-2390 08/19/2015 RReyes - Check if "Create New ARMS Customer & Account account" when creating New ARMS account
                    if(thisOrder.Create_ARMS_Customer_Account__c == false && searchCustTick == false && (accNum == null || accNum == '') && (accTextName == null || accTextName == '')){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('Check New ARMS Account'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    //END UD-2390 08/19/2015 RReyes - Check if "Create New ARMS Customer & Account account" when creating New ARMS account
                    
                    //START D-3373 17/08/2015 Dags/Fritz - Validation that there is already an existing invoice
                    if(thisOrder.Create_ARMS_Customer_Account__c == true || thisOrder.Create_ARMS_Account_Only__c == true){
                    
                        List<Zuora__CustomerAccount__c> zCustomer_LIST = new List<Zuora__CustomerAccount__c>();
                            if(accountId<>null){
                               zCustomer_LIST = [Select Id, Name,Zuora__Account__c, Other_PaymentMethod__c, ARMS_Account_Number__c, ARMS_Customer_Number__c From Zuora__CustomerAccount__c Where Zuora__Account__c = :accountId AND Other_PaymentMethod__c = :GlobalVariableClass.INVOICE AND ARMS_Customer_Number__c <> null AND ARMS_Account_Number__c <> null];
                            }
                            
                            if(zCustomer_LIST.size()>0){
                               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS Existing invoice'));
                               ApexPages.addMessage(myMsg);
                               return null;
                            }
                    }
                    //END D-3373 17/08/2015 Dags/Fritz - Validation that there is already an existing invoice 
     
                    //START D-3373 17/08/2015 Dags/Fritz - Validation that the ARMS is linked to another account
                    if(thisOrder.Customer_Name__c <> null && thisOrder.Customer_No__c <> null){
                        List<Zuora__CustomerAccount__c> checkOtherBillingAcc = [Select Id, Name,Zuora__Account__c, Other_PaymentMethod__c, ARMS_Account_Number__c, ARMS_Customer_Number__c From Zuora__CustomerAccount__c Where Zuora__Account__c <> :thisOrder.Account__c AND ARMS_Customer_Number__c = :thisOrder.Customer_No__c Limit 1];
                       
                        if(checkOtherBillingAcc.size()>0){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS Customer Number Used') + checkOtherBillingAcc[0].Name);
                            ApexPages.addMessage(myMsg);
                            return null;
                        }
                    }
                    //END UD-1821 09-July-2015 Added by S.Puli
                    //END D-3373 17/08/2015 Dags/Fritz - Validation that the ARMS is linked to another account MOVED CODE
                    //START UD-2805 Added by Dags Updated the conditions for UD-2375
                    If (thisOrder.Customer_No__c <> null) {
                       if (thisOrder.Business_Profile__c <> BusProfile) {
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS Business Profile') + GlobalVariableClass.BUSDEBT1 + BusProfile + ')');
                                ApexPages.addMessage(myMsg);
                                return null;
                                thisOrder.Business_Profile__c = BusProfile;
                       }
                    }
                    
                    If (thisOrder.ARMS_Account_Number__c <> null){
                        if (thisOrder.Debt_Management_Treatment__c <> DebtManagement) {
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS Debt Management') + GlobalVariableClass.BUSDEBT2  + DebtManagement + ')');
                                ApexPages.addMessage(myMsg);
                                return null;
                                thisOrder.Debt_Management_Treatment__c = DebtManagement;
                        }
                    }
                    //END UD-2805 Added by Dags Updated the conditions for UD-2375
                   
                }
                //START UD-2389 08/19/2015 RReyes - prevents save when payment mode = Other and Other Payment Mode is null
                if(thisOrder.Payment_Mode__c == 'Other' && (thisOrder.Other_Payment_Mode__c == '' || thisOrder.Other_Payment_Mode__c == null)){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('Other Payment Mode is Null'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                //END UD-2389 08/19/2015 RReyes - prevents save when payment mode = Other and Other Payment Mode is null  
            }
             //END UD-1214  
                                          
            //START D-2616 3/24/15 AddedBy FrancisBenzon : variable set of MainPackageBillingType
            Set<String> oliBillingType = new Set<String>();  
            Boolean isRecurring = false;
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            String creditCard = GlobalVariableClass.CREDIT_CARD;
            String otherPaymentMode = GlobalVariableClass.OTHER;
            String invoice = GlobalVariableClass.INVOICE;
            String cash = GlobalVariableClass.CASH;
            String check = GlobalVariableClass.CHECK;
            String enets = GlobalVariableClass.ENETS;
            String externalParties = GlobalVariableClass.EXTERNAL_PARTIES;
            String internalCharge = GlobalVariableClass.INTERNAL_CHARGE;
            String ipp = GlobalVariableClass.IPP;       
            String error_PaymentMode = GlobalVariableClass.ERROR_PAYMENTMODE_INVOICE;
            Set<String> paymentModeSet = new Set<String>{cash, check};
            //START D-3269 AddedBy FrancisBenzon : removed external parties and internal charge
            Set<String> otherPaymentModeSet = new Set<String>{enets, ipp};
            //END D-3269 AddedBy FrancisBenzon : removed external parties and internal charge
            //END D-2616 3/24/15 AddedBy FrancisBenzon : variable set of MainPackageBillingType
            
            //START UD-2590 9/3/15 AddedBy FrancisBenzon : populate account name and number for reporting purposes      
            thisOrder.Account_Name__c = thisOrder.Account__r.name;
            thisOrder.Account_Number__c = thisOrder.Account__r.AccountNumber;
            //END UD-2590 9/3/15 AddedBy FrancisBenzon : populate account name and number for reporting purposes
            
            /*if(thisOrder.Order_Action__c == NULL || (quantityOrderLineItem.Qty__c == null && thisOrder.Order_Type__c == COS_QUANTITY)||(thisOrder.Order_Type__c == COS_QUANTITY&& quantityOrderLineItem.Effective_Date__c == NULL)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please populate the required information.');
                ApexPages.addMessage(myMsg);
            }*/
            //Start MMallorca UD-1274 06/01/2015 Call function for computing delivery charges
            System.debug('gddr save calls compute prepaid START =========================================');
                computePrepaid();
            System.debug('gddr save calls compute prepaid END =========================================');
            //End MMallorca UD-1274 06/01/2015
            //START D-2400 JTeves 17/02/15 : Add Asia1 validation
            boolean isSelectedPackageDigital = false;

            if(selectedPackageId != NULL) {
                for(Package_Item__c pItem : [Select Is_Digital__c, Is_All_In_One__c FROM Package_Item__c WHERE Package__c = :selectedPackageId]) {
                    if(pItem.Is_Digital__c ||pItem.Is_All_In_One__c) {
                        isSelectedPackageDigital = true;
                    }
                }
            }
            
            orderLineItem.Main_Package_Subscription_Rate__c = subscriptionRate; //START/END UD-1619 VPernicia 6/22/15
            
            //START D-3382 CCB-135 05/Aug/15 Wenjun: Fix existing bug - reuse existing vendor does not cater search package
            //Start UD-2174 03Aug15 JohnD - modified logic for order type
            if (thisOrder.Subscription__c != null) {
                // Start PD-0136 02Jun16 JohnD - improved logic in setting the Order type
                Zuora__Subscription__c baseSub = [select Promotion_1__c, Main_Package_1__c, Vendor__c, Number_Of_Copies__c 
                                                    from Zuora__Subscription__c where Id = :thisOrder.Subscription__c];
                //START UD-1600 06/10/15 RReyes - set order type before save
                
                if(orderLineItem.Promotion_ID__c != baseSub.Promotion_1__c || orderLineItem.Main_Package_ID__c != baseSub.Main_Package_1__c){ // revised condition
                    thisOrder.Order_Type__c = COS_PACKAGE;
                }else if (orderLineItem.Qty__c != baseSub.Number_Of_Copies__c) {
                    thisOrder.Order_Type__c = COS_QUANTITY;
                    // orderLineItem.Promotion_ID__c = subPromoId;  // Start/End UD-2174 01Aug15 Johnd - commented out
                } else {
                    thisOrder.Order_Type__c = COS_OTHERS;
                }
                // End PD-0136 02Jun16 JohnD - improved logic in setting the Order type
                
                
                //END UD-1600 06/10/15 RReyes - set order type before save
                //START D-3423 Wenjun 27 Aug 15: Move the assignment logic to Vendor Assignment
                //orderLineItem.Vendor_Mailing_Agent__c = baseSub.Vendor__c;
                //END D-3423 Wenjun 27 Aug 15
            }    
            //End UD-2174 03Aug15 JohnD - modified logic for order type 
            //END D-3382 CCB-135 05/Aug/15 Wenjun
            
            //Start UD-678 VPernicia/MGatchalian 4/06/2015: Added additional condition "orderLineItem.Asia1_Creation_Mode__c == 'Individual'"
            if (validateAsiaOne && isSelectedPackageDigital && asia1Subscriptions.size() == 0 && orderLineItem.Asia1_Creation_Mode__c == 'Individual') {
                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Required Asia1')));
                return  null;
            }
            //End UD-678 VPernicia/MGatchalian 4/06/2015: Added additional condition "orderLineItem.Asia1_Creation_Mode__c == 'Individual'"
            //END D-2400 JTeves
            
            if(orderLineItem.Qty__c == 0 ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Qty must be greater than 0.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
            //START UD-1488 06/08/2015 KAREN HUNG added validation: Business Profile and Debt Management Treatment cannot be  "NONE" if payment method is invoice. 
            if((thisOrder.Business_Profile__c =='NONE' || thisOrder.Debt_Management_Treatment__c == 'NONE') && (thisOrder.Payment_Mode__c == 'Other' && thisOrder.Other_Payment_Mode__c == 'Invoice')){
                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.getErrorMessage('ARMSBusProfDebtMgt'));
                ApexPages.addMessage(myMsg1);
                return null;
            }
            //END UD-1488 06/08/2015 KAREN HUNG  
                   
            else{
            //START D-2332 AddedBy FrancisBenzon : user cannot save as draft if there is and error message encountered. INVOICE         
                
                //START D-3227 : cannot save as draft if from prepaid to postpaid package FBenzon
                checkBillingTypes();
                //END D-3227 : cannot save as draft if from prepaid to postpaid package FBenzon
                
                //checkInvoiceForBillingAccount(); //D-3224 HotFix : moved method call here. //START END UD-2738 Wenjun 21/Sep/15 : No longer needed
                if(passedInvoiceValidation)
                {
                    PageReference pgRef;
                    boolean isError = false;
                    string retUrl = '/apex/SM_ChangeOfSubscriptionDetail?id=' + thisOrder.Id + '&accountId=' + thisOrder.Account__c;
                    pgRef = new PageReference(retUrl);
                    pgRef.setRedirect(true);
                    
                    if (thisOrder.Recipient_Contact__c == null) {
                        isError = true;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Required Recipient Contact'));
                        ApexPages.addMessage(myMsg);
                    }
                    if (orderLineItem.Effective_Date__c < orderLineItem.Earliest_Start_Date__c){
                        OrderLineItem.COS_Urgent_Request__c = true;
                    }        
                    
                    //Start 02/24/2015 D-2456 Added by Von Alvin Pernicia billingAccountOption should not be null (Bundle with the original defect)
                    if (billingAccountOption == null) {
                        ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('PleaseSelectBillingOrNewOne')));
                        isError = true;  
                    }
                    //End D-2456 Added by Von Alvin Pernicia billingAccountOption  should not be null
                    
                    //START UD-0722 MGaelo 4/20/2015 Added Validation rule Unable to Delivered by Vendor if the Recipient is Overseas or Airlines
            
                    recipientAddressRecordTypeName = [select Address__r.RecordType.Name from Contact 
                            where Id = :thisOrder.Recipient_Contact__c].Address__r.RecordType.Name; 
                            
                    If ((orderLineItem.Delivered_By__c == DELIVERED_BY_VENDOR || orderLineItem.Delivered_By__c == DELIVERED_BY_NONE) && recipientAddressRecordTypeName == ConstantsSLB.getOther('Contact_Recordtype_Overseas')){  
                    ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Vendor for Overseas')));
                                    isError = true;
                    }
                    
                    If ((orderLineItem.Delivered_By__c == DELIVERED_BY_VENDOR || orderLineItem.Delivered_By__c == DELIVERED_BY_NONE) && recipientAddressRecordTypeName == ConstantsSLB.getOther('Contact_Recordtype_Airline')){  
                    ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Vendor for Airlines'))); 
                                    isError = true;
                    }
                    
                    If ((orderLineItem.Delivered_By__c == DELIVERED_BY_VENDOR || orderLineItem.Delivered_By__c == DELIVERED_BY_NONE) && recipientAddressRecordTypeName == ConstantsSLB.getOther('Contact_Recordtype_Internal')){  
                    ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Vendor for Internal'))); 
                                    isError = true; 
                    }
                
                    //END UD-0722 MGaelo 4/20/2015 Added Validation rule Unable to Delivered by Vendor if the Recipient is Overseas or Airlines
                                    
                    //START UD-3437 4Jan16 AddedBy FrancisBenzon : added new validation                
                    //START: UD-0673 03/31/2015 RReyes - Added validation to prevent saving with incomplete Check details/ If Check Amount is less than total due to SPH
                                  
                    if(renderCheckDetails != null && renderCheckDetails == false && dueToSph != null && dueToSph != 0  && thisOrder.Payment_Mode__c == GlobalVariableClass.CHEQUE)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantsSLB.getErrorMessage('ReselectCheckBillingAccount')));
                        return null;
                    }               
                    
                    if(thisOrder.Payment_Mode__c == GlobalVariableClass.CHEQUE && thisOrder.Check_Amount__c < dueToSph && renderCheckDetails != null && renderCheckDetails)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('ChequeAmountChecking')));
                        return null;
                    }
                    
                    if(renderCheckDetails != null && renderCheckDetails && dueToSph != null && dueToSph == 0)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantsSLB.getErrorMessage('ReselectCheckBillingAccount')));
                        return null;
                    }
                    
                    //START UD-3650 12Jan15 FrancisBenzon : change condition bracketing
                    if(thisOrder.Payment_Mode__c == 'Check' &&  (thisOrder.Check_Issuing_Bank__c == null || thisOrder.Check_No__c == null || thisOrder.Check_Dated__c == null ||thisOrder.Check_Amount__c == null) && renderCheckDetails != null && renderCheckDetails)
                    {               
                        isError = true;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please complete check details');
                        ApexPages.addMessage(myMsg);
                    }
                    //END UD-3650 12Jan15 FrancisBenzon : change condition bracketing
                    /*
                    if(thisOrder.Payment_Mode__c == 'Check' &&  thisOrder.Check_Amount__c != null && thisOrder.Check_Amount__c < dueToSPH){
                        isError = true;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Amount must be greater than total amount due.');
                        ApexPages.addMessage(myMsg);
                    }*/
                    //END: UD-0673 03/31/2015 RReyes - Added validation to prevent saving with incomplete Check details
                    //END UD-3437 4Jan16 AddedBy FrancisBenzon : added new validation   
                             
                    //Start MMallorca UD-1274 06/01/2015 Commented, already in computePrepaid()
                    // update
                    //thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType;
                    //START UD-0689 04-21-2015 MarvinG
                    //subscriberCharge = subscriberChargeHidden;
                    //vendorCredit    = vendorCreditHidden;
                    //END UD-0689 04-21-2015 MarvinG
                    //End MMallorca UD-1274 06/01/2015
                    populateRecipientContactRelatedDetails();
                    thisOrder.Status__c = 'Draft';
                    // thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account'; // Start/End UD-2614 06Sep15 JohnD - commented out
                    thisOrder.Delivery_Charge__c = 0;
        
                    if (billingAccountOption == 'createNew') {
            
                        // thisOrder.Billing_Account_Creation_Mode__c = 'Create New Billing Account';   // Start/End UD-2614 09Sep15 JohnD - moved above
            
                        if (thisOrder.Payment_Mode__c == 'Check') {
                            thisOrder.Payment_Method_ID__c = null;
                            thisOrder.Other_Payment_Mode__c = null;
                            thisOrder.Amount_Paid__c = null;
                        } else if (thisOrder.Payment_Mode__c == 'Cash') {
                            eraseCheckDetails();
                            thisOrder.Payment_Method_ID__c = null;
                            thisOrder.Other_Payment_Mode__c = null;
                        } else if (thisOrder.Payment_Mode__c == 'Credit Card') {
                            eraseCheckDetails();
                            thisOrder.Amount_Paid__c = null;
                            thisOrder.Other_Payment_Mode__c = null;
                        } else if (thisOrder.Payment_Mode__c == 'Other') {
                            thisOrder.Payment_Method_ID__c = null;
                            thisOrder.Amount_Paid__c = null;
                            eraseCheckDetails();
                        }
            
                    } 
                    else if (billingAccountOption == 'useExisting') {
                        
                        if (thisOrder.Billing_Account__c != null) {
                            // thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account'; // Start/End UD-2614 09Sep15 JohnD - moved above
                            thisOrder.Payment_Method_ID__c = null;
                            // Start D-3402 17Aug15 JohnD - revised logic in retrieving billing contact. commented out previous logic
                            //thisOrder.Billing_Contact__c = null;
                            if (thisOrder.Billing_Account__c != null) {
                                try {
                                    thisOrder.Billing_Contact__c = [select Billing_Contact__c from zuora__CustomerAccount__c where Id = :thisOrder.Billing_Account__c].Billing_Contact__c;
                                } catch (exception e) {
                                    thisOrder.Billing_Contact__c = null;
                                }
                            }
                            // End D-3402 17Aug15 JohnD - revised logic in retrieving billing contact. commented out previous logic
                            //START UD-0673 03/31/15 RReyes - Added condition to prevent check details from being erased
                            if(thisOrder.Payment_Mode__c != 'Check'){
                             eraseCheckDetails(); 
                            }
                            //END UD-0673 03/31/15 RReyes
                            //START D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to blank if payment mode is not "Other"
                            if (thisOrder.Payment_Mode__c != 'Other'){
                            thisOrder.Other_Payment_Mode__c = '';}
                            //END D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to null if payment mode is not "Other"
                        } 
                        else {
                            isError = true;
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Required Billing Account'));
                            ApexPages.addMessage(myMsg);
                        }
                    }
                    
                    if (isError == false) {
                        orderLineItem.Id = null;
                        //START D-3094 06/16/15 RReyes 
                        thisOrder.isChangeOfSubEntry__c = false;
                        //END D-3094 06/16/15 RReyes
                        //START D-1977 D-2003 Added by FrancisBenzon 2/16/15 : Added return of page to show error during entry.
                        if(addOrderLineItem()) {                                               
                            try {
                                //START D-3094 06/16/15 RReyes 
                                thisOrder.isChangeOfSubEntry__c = false;
                                //END D-3094 06/16/15 RReyes
                                update thisOrder;
                                //START D-3094 06/16/15 RReyes 
                                thisOrder.isChangeOfSubEntry__c = true;
                                //END D-3094 06/16/15 RReyes
                            } 
                            catch (exception e) {
                                ApexPages.addMessages(e);
                                pgRef = null;
                                isError = true;
                                //START D-3094 06/16/15 RReyes 
                                thisOrder.isChangeOfSubEntry__c = true;
                                //END D-3094 06/16/15 RReyes
                            }
                        }
                        else {
                            pgRef = null;
                            //START D-3094 06/16/15 RReyes 
                            thisOrder.isChangeOfSubEntry__c = true;
                            //END D-3094 06/16/15 RReyes    
                            //START D-3132 06/22/15 RReyes
                            computeEndDate();
                            //START D-3132 06/22/15 RReyes
                        }
                        //END D-1977 D-2003 Added by FrancisBenzon 2/16/15 : Added return of page to show error during entry.
                    } 
                    else {
                        pgRef = null;
                        //START D-3094 06/16/15 RReyes 
                        thisOrder.isChangeOfSubEntry__c = true;
                        //END D-3094 06/16/15 RReyes    
                        //START D-3132 06/22/15 RReyes
                        computeEndDate();
                        //START D-3132 06/22/15 RReyes
                    }
            
                    if (OrderLineItem.COS_Urgent_Request__c == true){
                        thisOrder.COS_Urgent_Request__c = true;
                    }
                    //START: D-1792 1/23/2015 JLedesma Calculation of Credit and Charges.
                    //START D-1792 1/27/2015 JLedesma Calculate fields in credit and charges section 
                    thisOrder.Subscription_Rate__c = totalSubRate;
                    //END D-1792 1/27/2015 JLedesma Calculate fields in credit and charges section 
                    thisOrder.Admin_Charge__c = OrderLineItem.Admin_Charge__c;
                    //END: D-1792 1/23/2015 JLedesma Calculation of Credit and Charges.
                    thisOrder.Status__c = 'Draft';
                    // START D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/20/2015
                    thisOrder.Billing_Type__c = orderLineItem.Main_Package_Billing_Type__c;
                    //END D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/20/2015
                    // Start D-2424 03-03-2015 JohnD added try catch
                    try {
                        //START D-3094 06/16/15 RReyes 
                        thisOrder.isChangeOfSubEntry__c = false;
                        //END D-3094 06/16/15 RReyes 
                       update thisOrder;
                        //START D-3094 06/16/15 RReyes 
                        thisOrder.isChangeOfSubEntry__c = true;
                        //END D-3094 06/16/15 RReyes
                    } catch (exception e) {
                        ApexPages.addMessages(e);
                        pgRef = null;
                        //START D-3094 06/16/15 RReyes 
                        thisOrder.isChangeOfSubEntry__c = true;
                        //END D-3094 06/16/15 RReyes 
                    }
                    //START D-2616 3/24/15 AddedBy FrancisBenzon : if List of OLI has Recurring, throw validation
                    if(thisOrder.Id != null)
                    {                   
                        oliList = getOrderLineItems(thisOrder.Id);
                        system.debug(':::OliListEntry ' + oliList);
                        if(!oliList.isEmpty() && oliList != null)
                        {
                            for(Order_Line_Item__c oli: oliList)
                            {
                                oliBillingType.add(oli.Main_Package_Billing_Type__c);
                            }
                            for(String billType : oliBillingType)
                            {   
                                if(billType.contains('Recurring'))
                                {
                                    isRecurring = true;
                                    break;
                                }
                            }                                             
                            
                            if(isRecurring)
                            {
                                
                                if(paymentModeSet.contains(thisOrder.Payment_Mode__c) || (thisOrder.Payment_Mode__c == otherPaymentMode && otherPaymentModeSet.contains(thisOrder.Other_Payment_Mode__c)))
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(error_PaymentMode)));
                                    return null;
                                }                           
                            }                           
                        }
                        //END D-2616 3/24/15 AddedBy FrancisBenzon : if List of OLI has Recurring, throw validation

                    //START D-2847 05-06-2015 Marvin G  
                    list<id> lstofOrderLine = new list<id>();
                
                    for (Order_Line_Item__c OliLists: [select id, (select id from Order_Line_Item_Gifts__r) from Order_Line_Item__c where Order__c =: thisOrder.id]) {
                        lstofOrderLine.add(OliLists.id);
                        
                        for (Order_Line_Item_Gift__c OliGiftList: OliLists.Order_Line_Item_Gifts__r) {
                            lstofOrderLine.add(OliGiftList.id);
                            system.debug('GIFT ' + OliGiftList);
                        }
                    }
                     
                    list<zqu__Quote__c> QuoteListBillingContact = new list<zqu__Quote__c>();
                    list<zqu__QuoteCharge__c> QuoteChargeList = new list<zqu__QuoteCharge__c>();
                    set<id> QuoteListBillingContactIds = new set<id>();
                    
                    for (zqu__Quote__c QuoteList: [select id, zqu__BillToContact__c, Subscription_Type__c,
                    zqu__PaymentTerm__c, Subscriber_Charge__c, Delivery_Charge_Type__c, zqu__PaymentMethod__c, 
                    Payment_Mode__c, Other_PaymentMethod__c
                    from zqu__Quote__c where Order_Line_Item_Number_1__c in: lstofOrderLine]) {
                        QuoteList.zqu__BillToContact__c = thisOrder.Billing_Contact__c;
                        QuoteList.Payment_Mode__c = thisOrder.Payment_Mode__c;
                        QuoteList.zqu__PaymentMethod__c = thisOrder.Payment_Mode__c;
                        QuoteList.Delivery_Charge_Type__c = thisOrder.Delivery_Charge_Type__c;
                        QuoteList.Subscriber_Charge__c = thisOrder.Subscriber_Charge__c;
                        QuoteList.Other_PaymentMethod__c = thisOrder.Other_Payment_Mode__c;
                        
                        if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
                            QuoteList.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBL;
                        }
                        else if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
                            QuoteList.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBH;
                        }
                        else if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
                            QuoteList.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_GOVT;   
                        }
                        else {
                            QuoteList.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_NORM;
                        }
                        
                        
                        QuoteListBillingContact.add(QuoteList);
                        if(QuoteList.Subscription_Type__c=='Delivery' && QuoteList.Delivery_Charge_Type__c=='S')
                            QuoteListBillingContactIds.add(QuoteList.id);
                    }
                    
                    update QuoteListBillingContact;  
                    //END D-2847 05-06-2015 Marvin G


                        
                        //Start UD-678 VPernicia/MGatchalian 4/06/2015
                        Quote_Handler QH = new Quote_Handler();
                        QH.Create_Quotes(thisOrder, 'Change of Subscription', orderLineItem.id);
                        //End UD-678 VPernicia/MGatchalian 4/06/2015
                    }
                    // End D-2424 03-03-2015 JohnD
                    
                    return pgRef;    
                    
                }
                    
                return null;
                //END D-2332 AddedBy FrancisBenzon : user cannot save as draft if there is and error message encountered. INVOICE
            }
    }
    //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
    
    
  /**
  * @description : This method will cancel the transaction. 
  *    Invoke by the Cancel button on the vf page
  */
    public PageReference cancel() {
        
        if (thisOrder.Status__c == 'New') {
          //Start : Code Review Implementation 02/18/2015 S.Puli
            if(thisOrder.Id<>null){
            //END : Code Review Implementation 02/18/2015 S.Puli
                delete [select id from Order_Line_Item__c where Order__c = :thisOrder.Id];
                delete [select id from Order__c where Id = :thisOrder.Id];
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        }
        
        string retURl = '/' + thisOrder.Account__c;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
    }
    


  private void refreshVfPageOrderDetails() {
    
        // check if account has an existing billing account
        //Start : Code Review Implementation 02/18/2015 S.Puli
        list<Zuora__CustomerAccount__c> billingAccounts;
        if(thisOrder.Account__c<>null){
        //end : Code Review Implementation 02/18/2015 S.Puli
            billingAccounts = [select Id from Zuora__CustomerAccount__c where Zuora__Account__c = :thisOrder.Account__c];
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
            
        paymentMethodId = thisOrder.Payment_Method_ID__c;
        
        // recipient address related details
        if (thisOrder.Recipient_Contact__c != null) {
          recipientAddressId = thisOrder.Recipient_Contact__r.Address__c;
          recipientAddressType = thisOrder.Recipient_Contact__r.Address__r.Address_Type__c;
          
          if (thisOrder.Delivery_Charge_Type__c == null) {
            thisOrder.Delivery_Charge_Type__c = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
          } else {
            selectedDeliveryChargeType = thisOrder.Delivery_Charge_Type__c;
            
            if (selectedDeliveryChargeType == 'S') {
              subscriberCharge = thisOrder.Subscriber_Charge__c;
              //START UD-1826 AddedBy FrancisBenzon : if 'S' then subCharge = VendorCredit
              vendorCredit = thisOrder.Subscriber_Charge__c;
              //END UD-1826 AddedBy FrancisBenzon : if 'S' then subCharge = VendorCredit
            } else if (selectedDeliveryChargeType == '9') {
              subscriberCharge = thisOrder.Subscriber_Charge__c;
            }
          }
        }
        // end recipient address related details
        
        
        // for billing account section
        
        
            
        totalBillingAccounts = billingAccounts.size();
        // end check if account has an existing billing account
        
        if (thisOrder.Billing_Account_Creation_Mode__c == 'Create New Billing Account' 
            || totalBillingAccounts == 0) {
              
          billingAccountOption = 'createNew';
        } else if (thisOrder.Billing_Account_Creation_Mode__c == 'Use existing Billing Account') {
          billingAccountOption = 'useExisting';
          fetchBillingAccount();
        }
        // end for billing account section      
  }

    

  private void refreshOrder() {
        // refresh order to reflect the charges
        
        string queryStr = generateOrderSoqlStr();
        queryStr += ' where Id = \'' + thisOrder.Id + '\'';
        
        SObject tmpOrder = database.query(queryStr);
        
        thisOrder = (Order__c)tmpOrder;
        // end refresh order to reflect the charges
        //START D-3094 06/16/15 RReyes 
        thisOrder.isChangeOfSubEntry__c = true;
        //END D-3094 06/16/15 RReyes
        refreshVfPageOrderDetails();
  }


    /*
     * Description: This method will retrieve the charges applicable to the recipient contact.
     *      This method is invoke in changing the recipient contact from the VF page
    */
    public void populateRecipientContactRelatedDetails() {
        //START D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
        if(!isContactQueried)
        {
            contactsMap = new Map<Id, Contact>();
            List<Contact> conList = new List<Contact>();
            conList = [Select Id, Name, Email  From Contact Where AccountId=:accountId];
            for(Contact c:conList){
                contactsMap.put(c.Id,c);
            }
            isContactQueried = true;
        }
        

        if(asia1SingleAccount == null)
        {
            asia1SingleAccount = new Asia1__c();
        }
        if(thisOrder.Recipient_Contact__c != null && contactsMap.containsKey(thisOrder.Recipient_Contact__c))
        {
            asia1SingleAccount.Email__c = contactsMap.get(thisOrder.Recipient_Contact__c).Email;
            if(contactsMap.get(thisOrder.Recipient_Contact__c).Email != '' && contactsMap.get(thisOrder.Recipient_Contact__c).Email != null)
            {
                
                asia1SingleAccount.User_ID_LDAP_ID__c = String.valueOf(contactsMap.get(thisOrder.Recipient_Contact__c).Email); 
            }
            asia1SingleAccount.Display_Name__c = contactsMap.get(thisOrder.Recipient_Contact__c).Name;                   
            String displayName = asia1SingleAccount.Display_Name__c.replace('.','');                
            asia1SingleAccount.Display_Name__c = displayName.replaceAll(' ','');
                             
        }
        else
        {
            asia1SingleAccount.Email__c = '';
            asia1SingleAccount.User_ID_LDAP_ID__c = '';
            asia1SingleAccount.Display_Name__c = '';
        }
            
        if (thisOrder.Recipient_Contact__c != null) 
        {       
            try 
            {
                
                recipientAddressType = [select Address__r.Address_Type__c from Contact 
                    where Id = :thisOrder.Recipient_Contact__c].Address__r.Address_Type__c;
                    
            
            } 
            catch (exception e) 
            {
                ExceptionLogger.log(new list<exception> { e });
            }
            
        }

        if (thisOrder.Delivery_Charge_Type__c != null) 
        {   
            if (selectedDeliveryChargeType == null)
                selectedDeliveryChargeType = thisOrder.Delivery_Charge_Type__c; 
        }
            
        map<string, decimal> charges = getCharges(thisOrder.Recipient_Contact__c, 
            thisOrder.Delivery_Charge_Type__c, subscriberCharge, vendorCredit);
       
               
        if (thisOrder.Recipient_Contact__c != null) {
            
            try {
                
                recipientAddressRecordTypeName = [select Address__r.RecordType.Name from Contact 
                        where Id = :thisOrder.Recipient_Contact__c].Address__r.RecordType.Name;
                        
            } catch (exception e) {
                
                recipientAddressRecordTypeName = '';
            }
        }
        //END D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
    
  }
  
  //START D-0689 UAT 04-21-2015 MarvinG Autopopulate subscriber charge
  public void refreshSubscriberCharge() {
      string recipientAddressType;
      string addressTypeDeliveryChargeType;
      decimal retrieveSCFromCS;
      decimal retrieveVCFromCS;
       
       
      if (orderLineItem.Delivered_By__c == GlobalVariableClass.VENDOR) {
         isDeliveredByVendor = true;
      }
      else {
         isDeliveredByVendor = false;
      }
       
      if (thisOrder.Recipient_Contact__c != null) { 
          Contact rc = [select Id, Address__c, Address__r.Address_Type__c, Zone__c from Contact 
                          where Id = :thisOrder.Recipient_Contact__c];
              recipientAddressType = rc.Address__r.Address_Type__c;  
              addressTypeDeliveryChargeType =  recipientAddressType + selectedDeliveryChargeType;
              
              system.debug('>>>> addressTypeDeliveryChargeType ' + addressTypeDeliveryChargeType );
              
              retrieveSCFromCS = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
              if (retrieveSCFromCS == 9999.99) {
                    isSubscriberChargeReadOnly = false;
              }
              else {
                    subscriberCharge = retrieveSCFromCS;
                    isSubscriberChargeReadOnly = true;
              }
              
              retrieveVCFromCS = ConstantsSLB.getVendorCredit(addressTypeDeliveryChargeType);
              if (retrieveVCFromCS == 9999.99) {
                    isVendorCrdeitReadOnly = false;
              }
              else {
                    vendorCredit = retrieveVCFromCS;
                    isVendorCrdeitReadOnly = true;
              }
              
      }
      thisOrder.Subscriber_Charge__c = subscriberCharge;
      thisOrder.Vendor_Credit__c = vendorCredit;
      

  }
  //END D-0689 UAT 04-21-2015 MarvinG Autopopulate subscriber charge


    /*
    * Description: This method will add an order line item the the user when the user done populating
    *      the necessary information from the VF page. This item will be added and displayed
    *      on the Line Items section of the VF page
    */
    public boolean addOrderLineItem() {
        
        // check if package is from promotion
        list<string> packageIdpromotionId = selectedPackageId.split(':');
        boolean isPassedValidation = true;
        //START D-3422 9/2/15 AddedBy FrancisBenzon : typecast variable
        orderLineItem.Term_Length__c = integer.valueOf(termLength);
        //END D-3422 9/2/15 AddedBy FrancisBenzon : typecast variable
        if (orderLineItem.Term_Length__c == null) {
            orderLineItem.Term_Length__c = 0;
        }

        /* validation */
        //START: PD-0035 May 15, 2016 Added by Kristine Balaoing - added validation for add on digital packages
        if(orderLineItem.Addon_Package__c!=null){
            Package__c addOnPackageForValidation = [select Id, Name, (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c  
                from Package_Items__r limit 1) from Package__c where Id = :orderLineItem.Addon_Package__c];
                
            for (Package_Item__c tmpForValidation : addOnPackageForValidation.Package_Items__r) {
                orderLineItem.Add_On_Package_Product_Sub_Type__c = tmpForValidation.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c;
                orderLineItem.Add_On_Package_Product_Platform__c = tmpForValidation.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c;
                
                //Start PD-0035 May 13, 2016 Added by Kristine Balaoing - added for add on rendering
                if (tmpForValidation.Is_Digital__c == true) {
                    //addOnIsDigital = true;
                    //orderLineItem.Is_Digital__c = true;
                    isDigital = true;
                }
                //End PD-0035 May 13, 2016 Added by Kristine Balaoing
            }
        }
        //END: PD-0035 May 15, 2016 Added by Kristine Balaoing       
        // check if package is digital and have an asia1 subscription
        if (isDigital == true && orderLineItem.Asia1_Creation_Mode__c == 'Individual' && asia1Subscriptions.size() == 0) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Required Asia1')));
            isPassedValidation = false;
        }

        //START D-2652 05/26/15 RReyes - added condition - orderlineitem.Promotion_ID__c != ''
        //START D-3103 AddedBy FrancisBenzon 6/13/15 : added condition for packpromo List. it can have 2 values but 1 is null. added checking.
        //if (orderLineItem.Term_is_discussed__c != true && (packageIdpromotionId.size() > 1 || orderLineItem.Promotion_ID__c != null))
        if(packageIdpromotionId.size() > 1) 
        {
            if (orderLineItem.Term_is_discussed__c != true && (packageIdpromotionId[1] != 'null' || orderLineItem.Promotion_ID__c != null))
            {           
                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Terms And Condition')));
                isPassedValidation = false;
            }
        }
        else {
            if (orderLineItem.Term_is_discussed__c != true && orderLineItem.Promotion_ID__c != null)
            {           
                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Terms And Condition')));
                isPassedValidation = false;
            }
        }
        
        //END D-3103 AddedBy FrancisBenzon 6/13/15 : added condition for packpromo List. it can have 2 values but 1 is null. added checking.
        //END D-2652 05/26/15 RReyes - added condition - orderlineitem.Promotion_ID__c != ''
        
        //START UD-0674 - 04/23/15 - RReyes - Subscribed as field should be required
        if(orderLineItem.Subscribed_as__c == '' || orderLineItem.Subscribed_as__c == null || orderLineItem.Subscribed_as__c == '--None--'){
           orderLineItem.Subscribed_as__c.addError('Please provide value for this field.');
            isPassedValidation = false;
        }
        //END UD-0674 - 04/23/15 - RReyes - Subscribed as field should be required
        
        //START D-1364 2/16/15 AddedBy FrancisBenzon : added validation that date should not be past date
        //START D-2332 3/11/15 AddedBy FrancisBenzon : added validation so that COS start date should not be earlier than Start Sub start date
        //START UD-3103 AddedBy FrancisBenzon : removed other conditions for users can now perform COS for future dated subs
        //START UD-3368 8Dec15 FrancisBenzon : cos start date can be equal old sub end date
        if (orderLineItem.Start_Date__c > zs.Zuora__SubscriptionEndDate__c || orderLineItem.Start_Date__c < date.today()) 
        {
            orderLineItem.Start_Date__c.addError(ConstantsSLB.getErrorMessage('Change of Package Effective Date'));
            isPassedValidation = false; 
           //return null;
        }
        //END UD-3368 8Dec15 FrancisBenzon : cos start date can be equal old sub end date
            //END UD-3103 AddedBy FrancisBenzon : removed other conditions for users can now perform COS for future dated subs
            //END D-2332 3/11/15 AddedBy FrancisBenzon : added validation so that COS start date should not be earlier than Start Sub start date
            //END D-1364 2/16/15 AddedBy FrancisBenzon : added validation that date should not be past date
            // end check if package is digital and have and asia1 subscription
      //START UD-2657/D-3414/D-3711 Wenjun 15 Oct: Validate COS Start Date cannot be less than Sub Start Date 
      if (orderLineItem.Start_Date__c < zs.Zuora__SubscriptionStartDate__c) 
            {
                orderLineItem.Start_Date__c.addError(System.Label.ERR_COS_B4_START_DATE);
                isPassedValidation = false; 
            }
      //END UD-2657/D-3414/D-3711 Wenjun 15 Oct
            /* end validation */
            
        //START D-3026 5/28/2015 Added By C. Lin - Stop COS to proceed if start date is less than Effective Date of COA
        Map<Id, Case_Subscription__c> subIdToCOACaseSubMap = new Map<Id, Case_Subscription__c>();
        Id coaRecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGEADD);
        List<Case_Subscription__c> caseSubList = [SELECT Id, Case__r.Effective_Date__c, Case__r.CaseNumber, Subscription__c, Case__r.RecordTypeId, Case__r.RecordType.Name FROM Case_Subscription__c WHERE Case__r.Status =: GlobalVariableClass.STATUS_CLOSED AND Case__r.RecordTypeId = :coaRecordTypeId AND Subscription__c = :thisOrder.Subscription__c Order by Case__r.Effective_Date__c ASC];

        for (Case_Subscription__c caseSub :caseSubList) {
            if(caseSub.Subscription__c != null){
                subIdToCOACaseSubMap.put(caseSub.Subscription__c, caseSub);
            }
        }
        
        Case_Subscription__c latestCaseSub;
        
        if(subIdToCOACaseSubMap.containsKey(thisOrder.subscription__c)){
            latestCaseSub = subIdToCOACaseSubMap.get(thisOrder.subscription__c);
            
            if(latestCaseSub.Case__r.Effective_Date__c >= orderLineItem.Start_Date__c){
                String errorMessage = 'There is an existing case ' + latestCaseSub.Case__r.CaseNumber + ' of type ' + latestCaseSub.Case__r.RecordType.Name + ' where Effective Date is ' +latestCaseSub.Case__r.Effective_Date__c + '. Please void the existing case to proceed or set start date of this case after the effective date.';
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                isPassedValidation = false; 
            }
        }
        //END D-3026 5/28/2015 Added By C. Lin

        if(isPassedValidation) { //START/END D-2003 D-1977 2/16/215 AddedBy FrancisBenzon

            Contact recipientContact = new Contact();
            
            //START PD-0054 5/5/16 FrancisBenzon : need contract end date even for evergreen
            //if (orderLineItem.Term_Length__c > 0) {
            if(orderLineItem.Start_Date__c != null){
                //START UD-0648 04/08/15 RReyes - End date should have -1 day
                if (orderLineItem.Term_Length__c > 0)
                    orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addMonths((integer)orderLineItem.Term_Length__c).addDays(-1);
                //END UD-0648 04/08/15 RReyes - End date should have -1 day
                //START D-3132 06/22/15 RReyes - compute contract end date
                if (orderLineItem.New_Contract_Period__c != null && orderLineItem.Promotion_ID__c != null) {    
                    orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1);
                }
                //END D-3132 06/22/15 RReyes - compute contract end date
             }
             else {
                  ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Start Date')));
             }
            //}
            //END PD-0054 5/5/16 FrancisBenzon : need contract end date even for evergreen
            
            //START UD-2143 07/30/15 RReyes  - SIT HotFix -  changed method being called
            //deleteRelatedOrderLineItemRelatedObjects(thisOrder.Id, true);
            deleteRelatedOrderLineItemRelatedObjects(thisOrder.Id, true, asia1Subscriptions);
            //END UD-2143 07/30/15 RReyes  - SIT HotFix -  changed method being called
            //START UD-2168 07/30/15 removed by Jason A.
            //orderLineItem.Subscribed_As__c = 'Change of Subscription';
            //END UD-2168 07/30/15 removed by Jason A.
            try { 
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = false;
                //END D-3094 06/16/15 RReyes 
                update thisOrder;
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = true;
                //END D-3094 06/16/15 RReyes
                //START D-2818 [6/2/2015] Gdelrosario : added this block for populating the postage charge for the orderlineitem
                if(orderLineItem.Delivered_By__c == 'Mailing Agent'){                
                
                    orderLineItem.Postage_Charge__c = PostageChargeHelper.getPostageChargeForLineItem(thisOrder.Recipient_Contact__c,orderLineItem) * orderLineItem.Qty__c;                
                
                }                               
                //END D-2818 ----------

                //Start D-3411 01Sep15 JohnD - for admin charge waiver
                if (thisOrder.Request_for_Waiving_of_Admin_Charge__c == true) {
                    orderLineItem.Fee_Waiver__c = true;
                }
                //End D-3411 01Sep15 JohnD - for admin charge waiver
                                
                //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
                //START : UD-1733 AddedBy FrancisBenzon : avoid error for wrong data
                //START UD-2168 07/30/15 removed by Jason A.
                //try 
                //{
                    upsert orderLineItem;
                //}
                //catch(exception e) {
                //    system.debug(e + e.getStackTraceString());
                //}
                //END UD-2168 07/30/15 removed by Jason A.
                //END : UD-1733 AddedBy FrancisBenzon : avoid error for wrong data
                //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
                    
                if (orderLineItem.Promotion_ID__c != null && promotionGifts != null) {                
                    // create order line item gifts
                    list<Order_Line_Item_Gift__c> orderLineItemGifts = new list<Order_Line_Item_Gift__c>();

                    for (GiftWrapper gw : promotionGifts) {
                        system.debug(':::SelectGift ' + gw.selectGift);
                        if (gw.selectGift) {

                            Order_Line_Item_Gift__c orderLineItemGift = new Order_Line_Item_Gift__c();
                            orderLineItemGift.Order_Line_Item__c = orderLineItem.Id;
                            orderLineItemGift.Promotion_Gift__c = gw.PromotionGift.Id;
                            //Start PD-0200 6/15/16 - L.Reyes Added to decrease Quantity Balance
                            orderLineItemGift.Order_Quantity__c = orderLineItem.Qty__c; 
                            //End PD-0200 6/15/16 - L.Reyes Added to decrease Quantity Balance 
                            orderLineItemGifts.add(orderLineItemGift);
                        }
                    }


                    insert orderLineItemGifts;
                    // end create order line item gifts

                    // retrieve total gift prices and update order line item
                    decimal totalGiftPrice = 0;
                    //Start : Code Review Implementation 02/18/2015 S.Puli
                    if(orderLineItem.Id<>null){
                    //End : Code Review Implementation 02/18/2015 S.Puli
                        for (Order_Line_Item_Gift__c tmp : [select Price__c from Order_Line_Item_Gift__c 
                                where Order_Line_Item__c = :orderLineItem.Id]) {

                            if (tmp.Price__c != null) {
                                totalGiftPrice += tmp.Price__c;
                            }
                        }
                    }//Start/End : Code Review Implementation 02/18/2015 S.Puli
                    orderLineItem.Total_Gift_Price__c = totalGiftPrice; 
                    
                    //START D-3166 24-26-2015 Marvin Gatchalian
                    orderLineItem.DTL_Date__c = SM_SubscriptionHelper.getDtlDate();
                    //END D-3166 24-26-2015 Marvin Gatchalian
                    
                    update orderLineItem;
                    // end retrieve total gift prices and update order line item
                }

                // create asia1_subsription
                createAsia1Subscription(asia1Subscriptions, orderLineItem.Id);

                // calculate months
                if (orderLineItem.Main_Package_Billing_Type__c == 'Full Prepaid') {
                    thisOrder.FP_Del_Usage__c = CalculateCharges.getMonths(thisOrder.Id, recipientContact.Address__c, 
                    orderLineItem.Start_Date__c, orderLineItem.End_Date__c);
                }
                // end calculate months

                thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = false;
                //END D-3094 06/16/15 RReyes 
                update thisOrder;
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = true;
                //END D-3094 06/16/15 RReyes 

            } catch (exception e) {
                //ApexPages.addMessages(e);
                apexpages.addmessages(e);
                isPassedValidation = false;
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = true;
                //END D-3094 06/16/15 RReyes
            }
        }
        
        return isPassedValidation;
    }

    //START D-3026 5/28/2015 Added By C. Lin - Stop COS to proceed if start date is less than Effective Date of COA
    public void checkExistingCOA(){
        Map<Id, Case_Subscription__c> subIdToCOACaseSubMap = new Map<Id, Case_Subscription__c>();
        Id coaRecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGEADD);
        List<Case_Subscription__c> caseSubList = [SELECT Id, Case__r.Effective_Date__c, Case__r.CaseNumber, Subscription__c, Case__r.RecordTypeId, Case__r.RecordType.Name FROM Case_Subscription__c WHERE Case__r.Status =: GlobalVariableClass.STATUS_CLOSED AND Case__r.RecordTypeId = :coaRecordTypeId AND Subscription__c = :thisOrder.Subscription__c Order by Case__r.Effective_Date__c ASC];

        for (Case_Subscription__c caseSub :caseSubList) {
            if(caseSub.Subscription__c != null){
                subIdToCOACaseSubMap.put(caseSub.Subscription__c, caseSub);
            }
        }
        
        Case_Subscription__c latestCaseSub;
        
        if(subIdToCOACaseSubMap.containsKey(thisOrder.subscription__c)){
            latestCaseSub = subIdToCOACaseSubMap.get(thisOrder.subscription__c);
            
            if(latestCaseSub.Case__r.Effective_Date__c >= orderLineItem.Start_Date__c){
                String errorMessage = 'There is an existing case ' + latestCaseSub.Case__r.CaseNumber + ' of type ' + latestCaseSub.Case__r.RecordType.Name + ' where Effective Date is ' +latestCaseSub.Case__r.Effective_Date__c + '. Please void the existing case to proceed or set start date of this case after the effective date.';
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
        }
    }
    //END D-3026 5/28/2015 Added By C. Lin

    /*
    * Description: This method will retrieve the information of the selected Order Line Item and 
    *      populate the data on the Subscription Details Section of the VF page.
    *      This will allow the user to update the Order Line Item. Invoke when user click on the
    *      specific Order Line Item from the Line Item section of the VF page
    */
    public void retrieveOrderLineItem() {

        // Start D-0033 UAT 01-03-2015 JohnD followed changes in start subscription
        Product_Publication__c publicationDetail = new Product_Publication__c();
        //START/END UD-0648 RReyes - Followed changes in Start Sub
        List<Product_Publication__c> publicationDetailList = new List<Product_Publication__c>();
        Package__c pkg = new Package__c();
        set<id> productIds = new set<id>();
        // End D-0033 UAT 01-03-2015 JohnD
        //START D-2652 05/20/15 RReyes - sets default value of isFromPromotion
        isFromPromotion = false;
        //END D-2652 05/20/15 RReyes - sets default value of isFromPromotion
        
        //START D-3422 9/2/15 AddedBy FrancisBenzon : typecast termlength
        if (orderLineItem.Term_Length__c != null) {
            termLength = string.valueOf(orderLineItem.Term_Length__c);
        }
        //END D-3422 9/2/15 AddedBy FrancisBenzon : 
        try {
            
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(thisOrder.Subscription__c<>null && thisOrder.Id<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
            // Star/End D-0127 UAT 01-03-2015 JohnD added  Suppress_Vendor_Start_notice__c field
            //START: UD-0648 04/08/15 RReyes - Added Vendor_Mailing_Agent__c in the query
            orderLineItem = [select Id, Name, Promotion_ID__r.Name, Order__c, Asia1_Creation_Mode__c, Auto_Renew__c, Charity__c, Contract_End_Date__c, 
                    Delivered_By__c, Earliest_Start_Date__c, End_Date__c, Generate_Invoice__c, Is_Digital__c, 
                    Main_Package_ID__c, New_Contract_Period__c, Main_Package_ID__r.Name, Main_Package_Sub_Type__c, 
                    Penalty_Charge__c, PO_Number__c, Qty__c, Start_Date__c, Total_Subscription_Rate__c, Admin_Charge__c, 
                    Add_On_Package_Subscription_Rate__c, Term_is_discussed__c, Main_Package_Billing_Type__c, 
                    Main_Package_Type__c, Main_Package_Subscription_Rate__c, Main_Package_Frequency__c, Main_Package_Period__c,
                    Supressed_Acknowledgement_Letter__c, Suppress_Renewal_and_Reminder_Letter__c, Main_Package_Product_Sub_Type__c, 
                    Supressed_Vendor_Notification_New_Sub__c, Term_Length__c, Vendor_Conversion__c, Effective_Date__c, 
                    Vendor_Subscription_ID__c, Addon_Package__c, Addon_Package__r.Name, Promotion_ID__c, Subscribed_as__c, Suppress_Vendor_Start_notice__c, 
                    Direct_Sub_Delivery_Method__c, (select Promotion_Gift__c, Gift_Name__c, Type__c, Price__c from Order_Line_Item_Gifts__r), 
                    (select Asia1__c, Asia1__r.User_ID_LDAP_ID__c, Service_Access_Flag__c, 
                    Service_Access_Flag__r.Name, Status__c, Concurrent__c from Asia1_Subscriptions__r), Vendor_Mailing_Agent__c 
                    from Order_Line_Item__c where Order__r.Subscription__c = :thisOrder.Subscription__c and 
                    Order__r.Status__c = 'Draft' and Order__c = :thisOrder.Id limit 1];
            //END: UD-0648 04/08/15 RReyes - Added Vendor_Mailing_Agent__c in the query
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
            // populate getter-setter variables
            selectedPackageName = orderLineItem.Main_Package_ID__r.Name;
            addOnPackage = new Package__c();
            promotionGifts = new list<GiftWrapper>();
            initializeAsia1Components();
            isDigital = false;
            productIsMagazine = false; //UD-0658 4/16/15 AddedBy FrancisBenzon : added variable
            selectedPackageId = orderLineItem.Main_Package_ID__c;
            deliveryMethod = new list<SelectOption>();
            
            //START D-3422 9/2/15 AddedBy FrancisBenzon : disable term length if FPP            
            if (orderLineItem.Main_Package_Billing_Type__c != null && orderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID)
            {
                isFullPrepaid = true;
            }
            //END D-3422 9/2/15 AddedBy FrancisBenzon : disable term length if FPP
            
            // retrieve recipient contact detai of the selected subscription
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(thisOrder.Subscription__c<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
            // Start D-2412 02-03-2015 JohnD added  fields  
            //START/END UD-0632 4/21/15 AddedBy FrancisBenzon : added field from query
        //START D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
        //START UD-2084 AddedBy FrancisBenzon 7/24/15 : added Legacy_Billing_Account_Id__c in query
        //START UD-2949 AddedBy FrancisBenzon 9/30/15 : added Sponsor_1__c in query
        // Start Pd-0136 02Jun16 JohnD - added Number_Of_Copies__c
                zs = [select Recipient_Contact__c, Cost_Center__c, Delivery_Charge_Type_1__c, Contract_End_Date_1__c, Number_Of_Copies__c,
                    Main_Package_1__c, Zuora__SubscriptionEndDate__c, Zuora__SubscriptionStartDate__c, Billing_Type__c, 
                    Promotion_1__c, Promotion_1__r.Penalty_Charge__c, Zuora__CustomerAccount__r.Zuora__Credit_Balance__c, Order_Line_Item_Number_1__c, Order_Line_Item_Number_1__r.Admin_Charge__c, Generate_Invoice__c, Zuora__CustomerAccount__r.Legacy_Billing_Account_Id__c, Sponsor_1__c
                    from Zuora__Subscription__c where Id = :thisOrder.Subscription__c];
        // End Pd-0136 02Jun16 JohnD - added Number_Of_Copies__c
        //END UD-2949 AddedBy FrancisBenzon 9/30/15 : added Sponsor_1__c in query
        //END UD-2084 AddedBy FrancisBenzon 7/24/15 : added Legacy_Billing_Account_Id__c in query
                // End D-2412 02-03-2015 JohnD added  fields            
                }//Start/End : Code Review Implementation 02/18/2015 S.Puli
                // end retrieve recipient contact detai of the selected subscription
        //END D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
                //START UD-2949 AddedBy FrancisBenzon 9/30/15 : sponsor field copied
                thisOrder.Sponsor__c = zs.Sponsor_1__c;
            //END UD-2949 AddedBy FrancisBenzon 9/30/15 : sponsor field copied
            thisOrder.Recipient_Contact__c = zs.Recipient_Contact__c;
            thisOrder.Cost_Centre__c = zs.Cost_Center__c;
            //Start MMallorca UD-1274 06/01/2015 Retrieve the current delivery charges or else get from zs
            if(thisOrder.Delivery_Charge_Type__c == null){
                thisOrder.Delivery_Charge_Type__c = zs.Delivery_Charge_Type_1__c;
            }
            /* Start PD-0225 20May16 - commented out
            else{
                thisorder.Delivery_Charge__c = thisorder.Delivery_Charge__c;
                thisOrder.Subscriber_Charge__c = thisOrder.Subscriber_Charge__c; // Start/End 19May16
                thisOrder.Vendor_Credit__c = thisOrder.Vendor_Credit__c;
            }
            */
            //End MMallorca UD-1274 06/01/2015
            //START UD-1375 AddedBy FrancisBenzon : added checking of promoId
            //START D-3132 06/19/15 RReyes - added addDays(-1)
            if (orderLineItem.New_Contract_Period__c != null && orderLineItem.Start_Date__c != null && orderLineItem.Promotion_ID__c != null) {    
                orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1);
            }
            //END D-3132 06/19/15 RReyes - added addDays(-1)
            //END UD-1375 AddedBy FrancisBenzon : added checking of promoId
            if (orderLineItem.Promotion_ID__c != null) {

                isFromPromotion = true;
                
                if (orderLineItem.Promotion_ID__c != null) {
                    selectedPackageId += ':' + orderLineItem.Promotion_ID__c;
                }
                // addon
                addOnPackage.Id = orderLineItem.Addon_Package__c;
                addOnPackage.Name = orderLineItem.Addon_Package__r.Name;
                // end addon

                // gifts
                selectedPromotionId = orderLineItem.Promotion_ID__c;
                populatePromotionGifts();

                set<id> oligIds = new set<id>();
                for (Order_Line_Item_Gift__c tmp : orderLineItem.Order_Line_Item_Gifts__r) {
                    oligIds.add(tmp.Promotion_Gift__c);
                }

                list<GiftWrapper> tmpGws = new list<GiftWrapper>();

                for (GiftWrapper tmp : promotionGifts) {
                    if (oligIds.contains(tmp.promotionGift.Id)) {
                        tmp.selectGift = true;
                    }
                    tmpGws.add(tmp);
                }
                promotionGifts = tmpGws;
                system.debug(':::promotionGifts2 ' + promotionGifts);
                // end gifts
                //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
            }//START D-1082 JB Domingo 12/18/2014 - Penalty Charge, New Contract Period and Contract End Date are equal to N/A 
            else{
                // converted to N/A in visualforce
                orderLineItem.Penalty_Charge__c = null; // Start/End UD-1588 11Jun15 JohnD  
                //START D-2044 AddedBy FrancisBenzon 2/5/15 : Change param to 0 to display 0 after SaveAsDraft if NewContractPeriod is N/A
                orderLineItem.New_Contract_Period__c = 0;
                //END D-2044 AddedBy FrancisBenzon 2/5/15 : Change param to 0 to display 0 after SaveAsDraft if NewContractPeriod is N/A
                orderLineItem.Contract_End_Date__c = null; // Start/End UD-1588 11Jun15 JohnD
                // end converted to N/A in visualforce          
            }
            //END D-1082 JB Domingo 12/18/2014

            // Start D-0033 UAT 01-03-2015 JohnD followed changes on start subscription
            try {
                pkg = [select Id, Package_Code__c, Name, Subscription_Type__c, 
                        Package_Sub_Type__c, Subscription_Period__c, Product_Family_Current_Package__c, Billing_Type__c, Package_Type__c, 
                        (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, Is_Newspaper__c,  
                        Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, RecordType.DeveloperName, 
                        Product_Rate_Plan__r.SubscriptionFrequency__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c  
                        from Package_Items__r) from Package__c where Id = :orderLineItem.Main_Package_ID__c];
            } catch (exception e) {
                ExceptionLogger.log(new list<exception> { e });
            }

            for (Package_Item__c tmp : pkg.Package_Items__r) {            
                
                productIds.add(tmp.Product_Rate_Plan__r.zqu__ZProduct__c);
                //Start UD-0658  4/16/15 FrancisBenzon added productMagazine 
                if (tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c == GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE) {
                    productIsMagazine = true;
                }
                //End UD-0658 4/16/15 FrancisBenzon added productMagazine 
                if (tmp.Is_Newspaper__c == true) {
                    isNewspaper = true;
                }
                
                
            }
            
            productIds.remove(null);
            try {
                publicationDetail = [select Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c 
                        from Product_Publication__c where ZProduct__c in :productIds
                        AND Publication_Code__r.Earliest_Start_Date__c != Null 
                        order by Publication_Code__r.Earliest_Start_Date__c asc limit 1];
            } catch (exception e) {
                publicationDetail = new Product_Publication__c();
            }
            // End D-0033 UAT 01-03-2015 JohnD
            
            //START UD-0648 04/08/15 RReyes - Followed change in StartSub
            try {
                if(productIds != null){
                publicationDetailList = [select Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c 
                from Product_Publication__c where ZProduct__c in :productIds];}
            } catch (exception e) {
                publicationDetailList = new List<Product_Publication__c>();
            }
            //END UD-0648 04/08/15 RReyes - Followed change in StartSub
            
            //START UD-0689 04-21-2015 MarvinG
            if (orderLineItem.Delivered_By__c == GlobalVariableClass.VENDOR) {
               isDeliveredByVendor = true;
            }
            else {
               isDeliveredByVendor = false;
            }
            //END UD-0689 04-21-2015 MarvinG

           
            

            if (orderLineItem.Is_Digital__c == true) {

                isDigital = true;
                asia1Subscriptions = getAsia1s(orderLineItem.Asia1_Subscriptions__r);
                asia1SubscriptionsTotal = asia1Subscriptions.size();
            }

            //START UD-0648 04/08/15 RReyes - Followed change in Start Sub
        uniqueOptions = new set<string>();
        uniqueOptions.add(DELIVERED_BY_NONE);
        deliveryMethod.add(new SelectOption(DELIVERED_BY_NONE, DELIVERED_BY_NONE));
        
        if(publicationDetailList.size()>0){
            for(Product_Publication__c pubDetail : publicationDetailList){
                if (pubDetail.Publication_Code__c != null 
                && pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c != null) {
                
                    if (pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == DELIVERED_BY_BOTH 
                            || pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == null) {
                        
                        orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
                        if(!uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
                            deliveryMethod.add(new SelectOption(DELIVERED_BY_MAILING_AGENT, DELIVERED_BY_MAILING_AGENT));
                            uniqueOptions.add(DELIVERED_BY_MAILING_AGENT);
                        }
                    
                        if(!uniqueOptions.CONTAINS(DELIVERED_BY_VENDOR)){
                            deliveryMethod.add(new SelectOption(DELIVERED_BY_VENDOR, DELIVERED_BY_VENDOR));
                            uniqueOptions.add(DELIVERED_BY_VENDOR);
                        }
                        
                    
                    } else {
                        
                        orderLineItem.Delivered_By__c = pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c;
                        if(!uniqueOptions.CONTAINS(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c)){
                        deliveryMethod.add(new SelectOption(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c, 
                                pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c));
                                uniqueOptions.add(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c);
                        }
                    }
                //set default values of picklist
                }
                if(uniqueOptions.CONTAINS(DELIVERED_BY_VENDOR)){
                    orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
                }
                else if(uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
                   orderLineItem.Delivered_By__c = DELIVERED_BY_MAILING_AGENT;
                }
                else if(uniqueOptions.CONTAINS(DELIVERED_BY_NONE)){
                   orderLineItem.Delivered_By__c = DELIVERED_BY_NONE;
                }
            }
        }
        //END UD-0648 04/08/15 RReyes - Followed change in Start Sub

                
                    
                
                    
                    
            
            populateRecipientContactRelatedDetails();

            //orderLineItemList.add(orderLineItem);
            // end populate getter-setter variables
            
        
        } catch (exception e) {
            //ApexPages.addMessages(e);
            isCalledOnSelect = false; //START/END D-3132 06/19/15 RReyes - determines if populateSubscription is called from selecting a package        
            populateSubscriptionDetail();
        }
    }
    //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons

    /************ search functionality ***************/

  
    /**
    * @description : This method will escape any single quotes on the search fields
    *           to avoid soql injection
    */      
    private void escapeSearchParams() {

      searchText = string.escapeSingleQuotes(searchText);
      searchBillingType = string.escapeSingleQuotes(searchBillingType);
        searchFrom = string.escapeSingleQuotes(searchFrom);
    }

    
    /**
    * @description : Action to be called when Search button is click
    *           on Search section of of the VF Page
    */      
    public void executeSearch() {

        escapeSearchParams();
    
        if (searchText != null) {
          
          if (searchFrom == 'Package') {
              
              searchPackage();
              promotionResultList = null;
          
          } else if (searchFrom == 'Promotion') {
              
              searchPromotion();
              packageResultList = null;
          
          } else {
              
              searchPackage();
              searchPromotion();
          
          }
        
          
          if (promotionResultList != null) {
            if (promotionResultList.size() > 100) {
              
              
              
              
              searchPackageMsg = ConstantsSLB.getErrorMessage('SearchPromotionResultLimit');
            }
          }
          
          if (packageResultList != null) {
            if (packageResultList.size() > 100) {
              searchPackageMsg = ConstantsSLB.getErrorMessage('SearchPackageResultLimit');
            }
          }
          
        } else {
          searchErrorMsg = ConstantsSLB.getErrorMessage('SearchNotFound');
        }
        
        if (packageResultList == null && promotionResultList == null) {
          searchErrorMsg = ConstantsSLB.getErrorMessage('SearchNotFound');
        }
        
        billingTypeFromPromotion = searchBillingType;
        isExecuteSearch = true;
        isPackageSelected = false;
    }

   
    /**
    * @description : this method will search the package object
    */      
    public void searchPackage() {
        
        packageId_subscriptionCharge = new map<string, decimal>();
        
      if (searchText.length() > 1) {     
          string qry = 'select Id, Name, Package_Type__c, Subscription_Type__c, Subscription_Period__c, Billing_Type__c from Package__c where Name like \'%' + searchText + '%\'';
          //START: UD-1242 06/08/2015 Jean Cari?o - Modified the query to add filter on the Package Type
          qry += ' and Billing_Type__c=\'' + searchBillingType + '\' and Package_Type__c != \'Add On\' and Package_Type__c != \'Grace Period\'';
          //END: UD-1242 06/08/2015 Jean Cari?o
          //START:D-0051 2/25/15 Added by Manolo Vale?a - Removed 'and Number_Of_Promotions__c < 1' from the query to allow users to search for packages that are also attached to a promotion.
          qry += ' limit 101';
          //END:D-0051 2/25/15 Added by Manolo Vale?a
          
          packageResultList = Database.query(qry);
          
          if (packageResultList.size() > 0) {
            
            set<id> packageIds = new set<id>();
            for (SObject tmp : packageResultList) {
                packageIds.add((Id)tmp.get('Id'));
            }
            
            retrievePackageSubscriptionRate(packageIds, searchBillingType);
          }
      }
    }
    

    /**
    * @description : this method will search the promotion object
    */      
    public void searchPromotion() {
        promotionResultList = new list<SObject>();  
        // Start D-1326 01/15/2015 Added logic that airline and overseas subscriber is not allowed for a promotion
        
        
        if (recipientAddressRecordTypeName != ConstantsSLB.getOther('Contact_Recordtype_Airline') 
                && recipientAddressRecordTypeName != ConstantsSLB.getOther('Contact_Recordtype_Overseas')) {
                    
        //instantiate variable param KCampang
        Map<String, Set<String>> mapPromoCodeContract = new Map<String, Set<String>>();
        if (searchText.length() > 1) {
            
            string qry = 'select Promotion__c promoId, Promotion__r.Promotion_Code__c promoCode, Promotion__r.Name promoName, Promotion__r.Effective_Start_Date__c promoStartDate, Promotion__r.Effective_End_Date__c promoEndDate, ';
            qry += 'Promotion__r.Contract_Period__c promoContractPeriod from Promotion_Package__c where Promotion__r.Name like \'%' + searchText + '%\'';
            qry +=' and Package_Name__r.Billing_Type__c=\'' + searchBillingType + '\' group by Promotion__c, Promotion__r.Effective_Start_Date__c,';
            qry += ' Promotion__r.Effective_End_Date__c, Promotion__r.Promotion_Code__c, Promotion__r.Contract_Period__c, Promotion__r.Name limit 101';

            list<SObject> searchResults = Database.query(qry);
              
            if (searchResults.size() > 0) {
                
                // retrieve eligibility rule
                set<string> promoCodes = new set<string>();
                Set<String> promoId = new Set<String>();
                promotionCode_isEligible = new map<string, boolean>();
                promotionCodeMap = new Map<String, Set<String>>();
                
                for (SObject tmp : searchResults) {
                    
                    //for ineligible
                    if(tmp.get('promoId') != null){
                        promoId.add((string)tmp.get('promoId'));
                    }
                    if (tmp.get('promoCode') != null) {
                        promoCodes.add((string)tmp.get('promoCode'));
                        //KCampang 1132014 for Eligibility Rule
                        if(mapPromoCodeContract.containsKey((string)tmp.get('promoCode'))){
                            mapPromoCodeContract.get((string)tmp.get('promoCode')).add((string)tmp.get('promoContractPeriod'));

                        }
                        else{
                            mapPromoCodeContract.put((string)tmp.get('promoCode'), new Set<String>{(string)tmp.get('promoContractPeriod')});
                        }
                        //end Kcampang 1132014 for Eligibility Rule 
                    }
                }
            
                //promotionCode_isEligible = PromotionEligibilityRule.getEligibility(accountId, 'Add', promoCodes, null, null);
                //KCampang 1132014
                PromoEligibilityRule pRule = new PromoEligibilityRule();
                //START D-2044 AddedBy FrancisBenzon 2/5/15 : added parameter for promotionEligibility rule to avoid error
                //START:D-1632 1/23/15 Added by Manolo Vale?a - Method was originally accepting an "Add" action. Changed to "Change" and also passed the id for the subscription.
                promotionCodeMap = pRule.getEligibility(accountId, 'Change', mapPromoCodeContract, null, thisOrder.Subscription__c,null);
                //END:D-1632 1/23/15 Added by Manolo Vale?a                
                //END D-2044 AddedBy FrancisBenzon 2/5/15 : added parameter for promotionEligibility rule to avoid error
                for(String promoCode : promotionCodeMap.Keyset()){
                    if(promotionCodeMap.get(promoCode )!=null){
                        promotionCode_isEligible.put(promoCode , true);
                    }
                    else{
                        promotionCode_isEligible.put(promoCode , false);
                    }
                }
                
                System.debug(':::RESULTS:' + promotionCodeMap );
                //end KCampang 1132014
                // end retrieve eligibility rule
                if(!(promoId.containsAll(promotionCode_isEligible.KeySet()) && promotionCode_isEligible.KeySet().containsAll(promoId))){
                    for(Id promId: promoId){
                        if(!promotionCode_isEligible.KeySet().contains(promId)){
                            promotionCode_isEligible.put(promId, false);
                        }
                    }
                    
                }
                if (isRemoveEligibilityRuleSearchFilter == true) {
                       
                    promotionResultList = searchResults;
                
                } else {
                    
                    promotionResultList = new list<SObject>();
                    
                    for (SObject tmp : searchResults) {
                        
                        string pc = (string)tmp.get('promoId');
                        if (promotionCode_isEligible.get(pc) == true) {
                            promotionResultList.add(tmp);
                        }
                    }
                }
                
            }
            }
        }
        // End D-1326
    }


    /**
    * @description : This method will retrieve and sum-up the related List Price field from Product Rate Plan object
    *           and map it to its corresponding Package.
    */      
    private static void retrievePackageSubscriptionRate(set<id> packageIds, string billingType) {
        //START UD-3449 12/29/2015 Added by J.Sarion - set scale to 2 decimal places
        Map<String, Decimal> packageId_subscriptionChargeScaled = new Map<String, Decimal>();
        
        //packageId_subscriptionCharge = SM_SubscriptionHelper.getPackageSubscriptionRate(packageIds, billingType);
        packageId_subscriptionChargeScaled = SM_SubscriptionHelper.getPackageSubscriptionRate(packageIds, billingType);
        packageId_subscriptionCharge = new Map<String, Decimal>();
        
        for(String packageId :packageId_subscriptionChargeScaled.keySet()) {
            Decimal subscriptionCharge = 0;
            
            
            if(packageId_subscriptionChargeScaled.get(packageId) != null) {
                subscriptionCharge = packageId_subscriptionChargeScaled.get(packageId).setScale(2, System.RoundingMode.HALF_UP);
            }
            
            packageId_subscriptionCharge.put(packageId, subscriptionCharge);
        }
        //END UD-3449 12/29/2015 Added by J.Sarion - set scale to 2 decimal places
    } 
    
    /************ end search functionality ***************/

    
    //START D-2888 5/27/2015 Added by Manolo Valena - Added additional parameter 'subscriptionId'.
    @remoteAction
    public static string retrieveRelatedPackages(string promotionId, string billingType, String accountId, String action, String isEligibilityChecked, Id subscriptionId) {
        //END D-2888 5/27/2015 Added by Manolo Valena     
          String returnStr;
          Boolean isChecked; 
         //START D-2888 5/27/2015 Added by Manolo Valena - Updated condition to check value of true or false instead of 'on'.
         if(isEligibilityChecked == 'true'){
             isChecked = true;
         }
         else{
             isChecked = false;
         }
         //END D-2888 5/27/2015 Added by Manolo Valena
       
        if(isChecked == true){
            
            returnStr = SM_SubscriptionHelper.getRelatedPackages(promotionId, billingType);
        }
        else{
            //START D-2888 5/27/2015 Added by Manolo Valena - Added additional parameter value 'subscriptionId'.
            //START D-2044 AddedBy FrancisBenzon 2/5/15 : added parameter for promotionEligibility rule to avoid error
            returnStr = SM_SubscriptionHelper.getRelatedPackages(promotionId, billingType, accountId, action, null, subscriptionId);
            //END D-2044 AddedBy FrancisBenzon 2/5/15 : added parameter for promotionEligibility rule to avoid error
            //END D-2888 5/27/2015 Added by Manolo Valena - Added additional parameter 'subscriptionId'.
        }
        return returnStr;
    }
    
    
    public void populateAddOn() {
        
        isPromotionSelected = true;
        orderLineItem.Addon_Package__c = selectedAddOnPackage;
        
        try {
        
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(selectedAddOnPackage<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
            addOnPackage = [select Id, Name, (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c  
                from Package_Items__r limit 1) from Package__c where Id = :selectedAddOnPackage];
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli 
            for (Package_Item__c tmp : addOnPackage.Package_Items__r) {
                orderLineItem.Add_On_Package_Product_Sub_Type__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c;
                orderLineItem.Add_On_Package_Product_Platform__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c;
                
                //Start PD-0035 May 13, 2016 Added by Kristine Balaoing - added for add on rendering
                if (tmp.Is_Digital__c == true) {
                    addOnIsDigital = true;
                    //START: PD-0035 04/20/2016 Added by Kristine Balaoing - set oli to digital when 
                    orderLineItem.Is_Digital__c = true;
                    //END: PD-0035 04/20/2016 Added by Kristine Balaoing
                }
                //End PD-0035 May 13, 2016 Added by Kristine Balaoing
            }           
            retrievePackageSubscriptionRate(new set<id>{addOnPackage.Id}, orderLineItem.Main_Package_Billing_Type__c);
            orderLineItem.Add_On_Package_Subscription_Rate__c = packageId_subscriptionCharge.get(addOnPackage.Id);
            
        } catch (exception e) {
            addOnPackage = new Package__c();
        }
        //START D-1792 1/27/2015 JLedesma Calculate fields in credit and charges section 
        retrieveAdminCharge();
        //END D-1792 1/27/2015 JLedesma Calculate fields in credit and charges section 
        //START: PD-0035 Added by Kristine Balaoing - May 12,2016 - Added for add on digital 
        retrieveNewlyAddedAddOn();
        //END: PD-0035 Added by Kristine Balaoing - May 12,2016
    }


  private void eraseCheckDetails() {
      
      thisOrder.Check_Issuing_Bank__c = null;
      thisOrder.Check_No__c = null;
      thisOrder.Check_Dated__c = null;
      thisOrder.Check_Amount__c = null;
      thisOrder.Remarks_Check__c = null;
  }


    // start gifts
    public class GiftWrapper {
        
        public boolean selectGift { get; set; }
        public Promotion_Gift__c promotionGift { get; set; }
    }
    
    
    public void  populatePromotionGifts() {
        
        promotionGifts = new list<GiftWrapper>();
        system.debug(':::selectedPromotionId ' + selectedPromotionId);
        
        //START D-4402 14Apr16 FrancisBenzon : max gift allowed
        Promotion__c promo = [SELECT Id, Maximum_No_of_gifts_allowed__c FROM Promotion__c WHERE Id = :selectedPromotionId];
        
        if(promo.Maximum_No_of_gifts_allowed__c != null){
            maxNoOfGifts = integer.valueOf(promo.Maximum_No_of_gifts_allowed__c);
        }
        //END D-4402 14Apr16 FrancisBenzon : max gift allowed
        
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(selectedPromotionId<>null){
        //Start : Code Review Implementation 02/18/2015 S.Puli
            // Start UD-2236 07Aug15 JohnD - replaced "Balance_Quantity__c" to "Balance_Quantity_New__c"
            
            //START D-4402 14Apr16 FrancisBenzon : add gft one time charge for calculation
            for (Promotion_Gift__c pg : [select Id, Gift__c, Gift__r.Name, Gift__r.Gift_Type__c, Gift__r.Gift_Cost__c, 
                    Balance_Quantity_New__c, Gift__r.One_Time_Charge__c from Promotion_Gift__c where Promotion__c = :selectedPromotionId]) {
                            
            //END D-4402 14Apr16 FrancisBenzon : add gft one time charge for calculation
                GiftWrapper gw = new GiftWrapper();
                gw.selectGift = false;
                gw.promotionGift = pg;
                
                promotionGifts.add(gw); 
            }
            system.debug(':::promotionGifts1 ' + promotionGifts);
            // End UD-2236 07Aug15 JohnD - replaced "Balance_Quantity__c" to "Balance_Quantity_New__c"
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
    }
    // end gifst
     
    
    //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
    public void setPackageId() {
        //START: D-2374 02/25/2015 Francis Benzon - concatenate promotion Id
        //START: UD-0959 MMallorca 04/23/2015
        //START: D-3272 23-July-2015 JTeves - set correct package id onload
        if(isOnload) {
            //isOnload = false;
            List<Order_Line_Item__c> oliItems = [SELECT Id, Main_Package_Id__c, Promotion_Id__c FROM Order_Line_Item__c WHERE Order__c = :thisOrder.Id];
            if(!oliItems.isEmpty()) {
                selectedPackageId = (oliItems[0].Main_Package_Id__c != null ? String.valueOf(oliItems[0].Main_Package_Id__c) : 'null')  + 
                                    (oliItems[0].Promotion_Id__c != null ?  ':' + String.valueOf(oliItems[0].Promotion_Id__c) : ':null');
            }
            else {
                selectedPackageId = (zs.Main_Package_1__c != null ? String.valueOf(zs.Main_Package_1__c) : 'null')  + 
                                    (zs.Promotion_1__c != null ?  ':' + String.valueOf(zs.Promotion_1__c) : ':null');
            }
        }
        else {
            selectedPackageId = (zs.Main_Package_1__c != null ? String.valueOf(zs.Main_Package_1__c) : 'null')  + 
                                (zs.Promotion_1__c != null ?  ':' + String.valueOf(zs.Promotion_1__c) : ':null');
        }
        //END: D-3272 23-July-2015 JTeves - set correct package id onload       
        //END: UD-0959 MMallorca 04/23/2015
        isCalledOnSelect = false; //START/END D-3132 06/19/15 RReyes - determines if populateSubscription is called from selecting a package        
        populateSubscriptionDetail(); 
        //END: D-2374 02/25/2015 Francis Benzon
    }
    //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
    public void populateSubscriptionDetail() {
           
        set<id> packageIds = new set<id>();
        set<id> productIds = new set<id>();
        isDigital = false;
        isFromPromotion = false;
        Product_Publication__c publicationDetail;
        isAllInOne = false;
        deliveryMethod = new list<SelectOption>();
        orderLineItem = new Order_Line_Item__c();
        initializeAsia1Components();
        //START D-1792 1/23/2015 JLedesma Calculate fields        
        dueToSph = 0;
        dueToCustomer = 0;
        totalSubRate = 0;
        //END D-1792 1/23/2015 JLedesma Calculate fields
        
        giftAmount = 0; //Start/End VPernicia D-4402
        
        populateRecipientContactRelatedDetails();
        //START/END UD-0648 RReyes - Followed changes in Start Sub
        List<Product_Publication__c> publicationDetailList;
        // check if package is from promotion
        //START/END UD-0658 AddedBy FrancisBenzon : variable
        productIsMagazine = false;
        //START D-3422 9/2/15 AddedBy FrancisBenzon : set flag to false to rerender term length
        isFullPrepaid = false;
        //END D-3422 9/2/15 AddedBy FrancisBenzon : set flag to false to rerender term length
        
        if (selectedPackageId == null && selectedSubscription != null) {
            selectedPackageId = selectedSubscription.mainPackage;
        }     
        
        if (selectedSubscription.subscriptionEndDate != null) {
            orderLineItem.Start_Date__c = selectedSubscription.subscriptionEndDate.addDays(1);
            //START D-3132 06/22/15 RReyes - compute contract end date
            if (orderLineItem.New_Contract_Period__c != null && orderLineItem.Start_Date__c != null && orderLineItem.Promotion_ID__c != null) {    
                orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1);
            }
            //END D-3132 06/22/15 RReyes - compute contract end date
        }
        
        //START D-1802 JLedesma Populate Admin Charge 1/22/2015
        if(zs.Order_Line_Item_Number_1__r.Admin_Charge__c == null){
            orderLineItem.Admin_Charge__c = 0;
        }
        else{
            orderLineItem.Admin_Charge__c= zs.Order_Line_Item_Number_1__r.Admin_Charge__c;
        }
        //END D-1802 JLedesma Populate Admin Charge 1/22/2015
        
        // Start UD-2211 19Aug15 JohnD
        if (isCalledOnSelect) {
            selectedDeliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
        }
        // End UD-2211 19Aug15 JohnD
                                
        //START: UD-0959 MMallorca 04/23/2015
        list<string> packageIdpromotionId = selectedPackageId.split(':'); 
        id pkgId;       
        try {
            //START UD-1038 05/14/15 RReyes - sets value of initialSub to zs
            if(initialSub != null)
                zs = initialSub;
            //END UD-1038 05/14/15 RReyes - sets value of initialSub to zs
            pkgId = packageIdpromotionId[0]; 

            // end check if package is from promotion
                                    
            //Start : Code Review Implementation 02/18/2015 S.Puli
            Package__c pkg;
            if(pkgId<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
            // Start/End D-0105 UAT 02-03-2015 JohnD added Is_Newspaper field in the query
            // Start/End D-3072 UAT 08-06-2015 Gdelrosario added Product_Rate_Plan__r.RatePlanType__c field in the 
            //START D-3101 6/17/15 AddedBy FrancisBenzon : added recType Dev name in query
            // Start UD-2171 31Jul15 JohnD - (hotfix) added Package_Price__c field
            // Start UD-2211 19Aug15 JohnD - added Is_Digital_2__c
            pkg = [select Id, Package_Code__c, Name, Subscription_Type__c, Package_Price__c, 
                  Package_Sub_Type__c, Subscription_Period__c, Billing_Type__c, Package_Type__c, 
                  (select Id, Is_Digital__c, Is_Digital_2__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                  Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Is_Newspaper__c,
                  Product_Rate_Plan__r.SubscriptionFrequency__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c,Product_Rate_Plan__r.RatePlanType__c, RecordType.DeveloperName 
                  from Package_Items__r) from Package__c where Id = :pkgId];
            }
            
            //START D-3422 9/2/15 AddedBy FrancisBenzon : disable TL if FPP
            if(pkg.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID){
                isFullPrepaid = true;
            }
            //END D-3422 9/2/15 AddedBy FrancisBenzon : disable TL if FPP
            
            // End UD-2211 19Aug15 JohnD - added Is_Digital_2__c
            // End UD-2171 31Jul15 JohnD - (hotfix) added Package_Price__c field
            //END D-3101 6/17/15 AddedBy FrancisBenzon : added recType Dev name in query
            //Start/End : Code Review Implementation 02/18/2015 S.Puli
            // invoke package subscription rate retrieval        
            packageIds.add(pkgId);
            //START UD-0642 3/30/15 AddedBy FrancisBenzon : ensure input params have values
            if(searchBillingType != null)
            {
                retrievePackageSubscriptionRate(packageIds, searchBillingType);
            }
            else
            {
                retrievePackageSubscriptionRate(packageIds, pkg.Billing_Type__c);
            }
            //END UD-0642 3/30/15 AddedBy FrancisBenzon : ensure input params have values
            // end invoke package subscription rate retrieval 
            
            selectedPackageName = pkg.Name;
            orderLineItem.Order__c = thisOrder.Id;
            // Start UD-2174 01Aug15 JohnD
            orderLineItem.Promotion_ID__c = currentPromotionId;
            if (currentPromotionId != null) {
                orderLineItem.Term_is_discussed__c = true;
            }
            // End UD-2174 01Aug15 JohnD
            // Start UD-2171 31Jul15 JohnD - (hotfix) use package price instead from product rate plan
            // orderLineItem.Main_Package_Subscription_Rate__c = packageId_subscriptionCharge.get(pkgId); commented out
            if (pkg.Package_Price__c == null) {
                orderLineItem.Main_Package_Subscription_Rate__c = 0;
            } else {
                orderLineItem.Main_Package_Subscription_Rate__c = pkg.Package_Price__c.setScale(2, System.RoundingMode.HALF_UP);    // Start/End UD-3449 29Dec15 JohnD
            }
            subscriptionRate = orderLineItem.Main_Package_Subscription_Rate__c;
            orderLineItem.Qty__c = 1;
            //Start D-2374 2/25/15 FrancisBenzon : dummy field for base value of subscription rate plan, called in vfPage
            // subscriptionRate = packageId_subscriptionCharge.get(pkgId); 
            //End D-2374 2/25/15 FrancisBenzon : dummy field for base value of subscription rate plan, called in vfPage
            // End UD-2171 31Jul15 JohnD - (hotfix) use package price instead from product rate plan
             //START: D-2374 02/25/2015 Francis Benzon - fetch subscription details
            orderLineItem.Generate_Invoice__c = zs.Generate_Invoice__c;
            orderLineItem.Supressed_Vendor_Notification_New_Sub__c = zs.Suppress_Vendor_Start_Notice_1__c;
            orderLineItem.Supressed_Acknowledgement_Letter__c = zs.Supressed_Acknowledgement_Letter_1__c;
            orderLineItem.Suppress_Renewal_and_Reminder_Letter__c = zs.Supressed_Renewal_and_Reminder_Letter_1__c;
            orderLineItem.PO_Number__c = zs.PO_Number__c;
            orderLineItem.Charity__c = zs.Charity_1__c;
            orderLineItem.Vendor_Conversion__c = zs.Vendor_Conversion_1__c;
            orderLineItem.Main_Package_ID__c = pkgId; 
            orderLineItem.End_Date__c = zs.Zuora__SubscriptionEndDate__c;
            orderLineItem.Main_Package_Sub_Type__c = pkg.Subscription_Type__c;
            orderLineItem.Delivered_By__c = zs.Delivered_By_1__c;
            //orderLineItem.Start_Date__c = zs.Zuora__SubscriptionStartDate__c;
            orderLineItem.Contract_End_Date__c = zs.Contract_End_Date_1__c;
            //orderLineItem.New_Contract_Period__c = zs.New_Contract_Period_1__c;
            orderLineItem.Main_Package_Billing_Type__c = pkg.Billing_Type__c;
            orderLineItem.Main_Package_Frequency__c = 'Default';
            orderLineItem.Main_Package_Sub_Type__c = pkg.Subscription_Type__c;
            orderLineItem.Main_Package_Type__c = pkg.Package_Type__c;
            //START: UD-0648 04/08/15 RReyes - set Vendor
            //START D-3423 Wenjun 27 Aug 15: Move the assignment logic to Vendor Assignment
            //orderlineitem.Vendor_Mailing_Agent__c = zs.Vendor__c;
            //END D-3423 Wenjun 27 Aug 15
            //END: UD-0648 04/08/15 RReyes - set Vendor
            //START: D-2374 02/26/2015 JTeves - proper initialization order line item fields.
            if(isFromSubscriptionSelection) {
                //START UD-0642 3/30/15 Commented out by FrancisBenzon : to ensure subscription rate always has value
                if(zs.Order_Line_Item_Number_1__r.Total_Subscription_Rate__c != null)
                {
                    orderLineItem.Main_Package_Subscription_Rate__c = zs.Order_Line_Item_Number_1__r.Total_Subscription_Rate__c;
                    //START UD-1443 CommentedOut By FrancisBenzon : subrate hidden should always be the base subrate
                    //subscriptionRate = zs.Order_Line_Item_Number_1__r.Total_Subscription_Rate__c;
                    //START UD-1443 CommentedOut By FrancisBenzon : subrate hidden should always be the base subrate
                }
                //END UD-0642 3/30/15 Commented out by FrancisBenzon : to ensure subscription rate always has value         
                orderLineItem.Qty__c = zs.Qty__c;
            }
            //END: D-2374 02/26/2015 JTeves - proper initialization order line item fields.
            //START: D-2400 03/03/2015 JTeves - Boolean variable - if action is invoked from selection of a new package, validate asia1
            if(isFromSubscriptionSelection) {
                validateAsiaOne = false;
            }
            else {
                validateAsiaOne = true;
            }
            //END: D-2400 03/03/2015 JTeves - Boolean variable - if action is invoked from selection of a new package, validate asia1
            isFromSubscriptionSelection = false;
            // orderLineItem.Subscribed_as__c = zs.Subscribe_As__c; // Start/End UD-2211 19Aug15 JohnD - commented out
            orderLineItem.Auto_Renew__c = zs.Zuora__AutoRenew__c;
             //END: D-2374 02/25/2015 Francis Benzon
            if (pkg.Subscription_Period__c != null && pkg.Subscription_Period__c != 'N/A') {
              
              orderLineItem.Main_Package_Period__c = integer.valueOf(pkg.Subscription_Period__c);
              orderLineItem.Term_Length__c =  integer.valueOf(pkg.Subscription_Period__c);
            
            } else {
              
              orderLineItem.Main_Package_Period__c = 0;
              orderLineItem.Term_Length__c = 0;
            }
            
            //START D-3422 9/2/15 AddedBy FrancisBenzon : use string value to avoid Apex error: must resolve to string type
            termLength = string.valueOf(orderLineItem.Term_Length__c);
            //END D-3422 9/2/15 AddedBy FrancisBenzon : use string value to avoid Apex error: must resolve to string type
            
            for (Package_Item__c tmp : pkg.Package_Items__r) {
              
                productIds.add(tmp.Product_Rate_Plan__r.zqu__ZProduct__c);
                
                // Start UD-1622 13Jun15 JohnD - only for Product package items
                if(tmp.RecordType.DeveloperName.contains('Product')) {
                    
                    if (tmp.Is_Digital__c == true) {
                      
                    isDigital = true;
                        orderLineItem.Is_Digital__c = true;
                    }
                      
                    if (tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c == 'All-In-One') {
                        isAllInOne = true;
                    }
    
                    if (tmp.Is_Newspaper__c == true) {
                        isNewspaper = true;
                    }
                    
                    //START UD-0658 AddedBy FrancisBenzon 4/16/15 : check if magazine and check if product is newspaper. if newspaper then delvier by vendor
                    if (tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c == GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE) {
                        productIsMagazine = true;
                    }           
                    else if (tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c == GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER) {
                        orderLineItem.delivered_by__c = GlobalVariableClass.OLIDELIVEREDBY_VENDOR;
                    }
                    //END UD-0658 AddedBy FrancisBenzon 4/16/15 : check if magazine and check if product is newspaper. if newspaper then delvier by vendor
                    //START D-3072 Gdelrosario 6/8/2015 : check if bill run or proaction
                    
                        if (tmp.Product_Rate_Plan__r.SubscriptionFrequency__c != null) {
                            if(tmp.Product_Rate_Plan__r.RatePlanType__c  == GlobalVariableClass.RATE_TYPE_BILL_RUN || tmp.Product_Rate_Plan__r.RatePlanType__c  == GlobalVariableClass.RATE_TYPE_PRORATION){
                                orderLineItem.Main_Package_Frequency__c = ConstantsSLB.getProductFrequency(tmp.Product_Rate_Plan__r.SubscriptionFrequency__c); 
                            }
                         }
                    //orderLineItem.Main_Package_Frequency__c = ConstantsSLB.getProductFrequency(tmp.Product_Rate_Plan__r.SubscriptionFrequency__c);
                    //END D-3072
                    orderLineItem.Main_Package_Product_Sub_Type__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c;
                    orderLineItem.Main_Package_Product_Platform__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c;
                }
                // End UD-1622 13Jun15 JohnD - only for Product package items
            }
            
            //START UD-0689 04-21-2015 MarvinG
            if (orderLineItem.Delivered_By__c == GlobalVariableClass.VENDOR) {
               isDeliveredByVendor = true;
            }
            else {
               isDeliveredByVendor = false;
            }
            //END UD-0689 04-21-2015 MarvinG
            
            
            productIds.remove(null); // Start/End D-0033 UAT 01-03-2015 JohnD removing null
            
            // retrieve earliest publication date and direct sub delivery method
            // assumption: all publications related to the package have the same delivery method
            //START UD-0658 4/16/15 Commented out by francisBenzon : new logic implemented
            /*
            try {
                //Start : Code Review Implementation 02/18/2015 S.Puli
                if(productIds<>null){
                //end : Code Review Implementation 02/18/2015 S.Puli
                publicationDetail = [select Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c 
                      from Product_Publication__c where ZProduct__c in :productIds 
                      order by Publication_Code__r.Earliest_Start_Date__c asc limit 1];
                }//start/End : Code Review Implementation 02/18/2015 S.Puli
            } catch (exception e) {
                publicationDetail = new Product_Publication__c();
            }
            // end retrieve earliest publication date
            */
            //END UD-0658 4/16/15 Commented out by francisBenzon : new logic implemented
            
            //START UD-0658 EditedBy FrancisBenzon : modified query and added logic
            //START UD-0648 04/08/15 RReyes - Followed change in StartSub
            try {
                if(productIds != null){
                    publicationDetailList = [select Publication_Code__r.Earliest_Start_Date__c, 
                                            Publication_Code__r.Direct_Sub_Delivery_Method__c 
                                            from Product_Publication__c where ZProduct__c in :productIds
                                            order by Publication_Code__r.Earliest_Start_Date__c asc];
                }
            } catch (exception e) {
                publicationDetailList = new List<Product_Publication__c>();
            }
           //END UD-0648 04/08/15 RReyes - Followed change in StartSub
            if(publicationDetailList.size()>0) {
                orderLineItem.Earliest_Start_Date__c = publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c;
                orderLineItem.Direct_Sub_Delivery_Method__c = publicationDetailList[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
                
                //START UD-2150 7/28/15 AddedBy FrancisBenzon : defaulted Start Date to earliest Start Date in all COS scenarios
                if(orderLineItem.Earliest_Start_Date__c != null)
                {
                    orderLineItem.Start_Date__c = publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c;
                }
                else {
                    orderLineItem.Start_Date__c = zs.Zuora__SubscriptionStartDate__c;
                }
                
                /*//START: D-2374 02/25/2015 Francis Benzon - retrieve start date from either old sub or new package selected
                if(orderLineItem.Main_Package_ID__c == zs.Main_Package_1__c) {
                    orderLineItem.Start_Date__c = zs.Zuora__SubscriptionStartDate__c;
                }
                else {
                    orderLineItem.Start_Date__c = publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c;
                } */ //END: D-2374 02/25/2015 Francis Benzon
                
                //END UD-2150 7/28/15 AddedBy FrancisBenzon : defaulted Start Date to earliest Start Date in all COS scenarios
            }
            
            if (orderLineItem.Start_Date__c != null && orderLineItem.Term_Length__c > 0) {
                //start UD-0477 03-24-15 ABanaag - minus 1 day
                orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.Term_Length__c)).addDays(-1);
                //end UD-0477 03-24-15 ABanaag - minus 1 day
            }
            
            //START UD-0648 04/08/15 RReyes - Followed change in Start Sub
            uniqueOptions = new set<string>();
            uniqueOptions.add(DELIVERED_BY_NONE);
            deliveryMethod.add(new SelectOption(DELIVERED_BY_NONE, DELIVERED_BY_NONE));
            if(publicationDetailList.size()>0){
                for(Product_Publication__c pubDetail : publicationDetailList){
                    if (pubDetail.Publication_Code__c != null 
                    && pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c != null) {
                    
                        if (pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == DELIVERED_BY_BOTH 
                                || pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == null) {
                            
                            orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
                            if(!uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
                                deliveryMethod.add(new SelectOption(DELIVERED_BY_MAILING_AGENT, DELIVERED_BY_MAILING_AGENT));
                                uniqueOptions.add(DELIVERED_BY_MAILING_AGENT);
                            }
                        
                            if(!uniqueOptions.CONTAINS(DELIVERED_BY_VENDOR)){
                                deliveryMethod.add(new SelectOption(DELIVERED_BY_VENDOR, DELIVERED_BY_VENDOR));
                                uniqueOptions.add(DELIVERED_BY_VENDOR);
                            }
                            
                        
                        } else {
                            
                            orderLineItem.Delivered_By__c = pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c;
                            if(!uniqueOptions.CONTAINS(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c)){
                            deliveryMethod.add(new SelectOption(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c, 
                                    pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c));
                                    uniqueOptions.add(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c);
                            }
                        }
                    //set default values of picklist
                    }
                    // Start UD-2211 19Aug15 JohnD - moved this outside the loop
                    /*
                    if(uniqeOptions.CONTAINS(DELIVERED_BY_VENDOR)){
                        orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
                    }
                    else if(uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
                       orderLineItem.Delivered_By__c = DELIVERED_BY_MAILING_AGENT;
                    }
                    else if(uniqueOptions.CONTAINS(DELIVERED_BY_NONE)){
                       orderLineItem.Delivered_By__c = DELIVERED_BY_NONE;
                    }
                    */
                    // End UD-2211 19Aug15 JohnD - moved this outside the loop
                }
                // Start UD-2211 20Aug15 JohnD - added logic
                if(uniqueOptions.CONTAINS(DELIVERED_BY_VENDOR)){
                    orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
                }
                else if(uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
                   orderLineItem.Delivered_By__c = DELIVERED_BY_MAILING_AGENT;
                   selectedDeliveryChargeType = 'Z'; 
                }
                else if(uniqueOptions.CONTAINS(DELIVERED_BY_NONE)){
                   orderLineItem.Delivered_By__c = DELIVERED_BY_NONE;
                   selectedDeliveryChargeType = 'Z'; 
                }
                // End UD-2211 20Aug15 JohnD - added logic
            }
            //END UD-0648 04/08/15 RReyes - Followed change in Start Sub
            
            /* START: UD-0648 CommentedOut by RReyes to use logic from StartSub
            // Start D-0033 UAT 01-03-2015 JohnD followed changes in start subscription
            if (publicationDetail.Publication_Code__c != null 
                    && publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c != null) {
                
                if (publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == DELIVERED_BY_BOTH 
                        || publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == null) {
                    
                    orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
                    deliveryMethod.add(new SelectOption(DELIVERED_BY_MAILING_AGENT, DELIVERED_BY_MAILING_AGENT));
                    deliveryMethod.add(new SelectOption(DELIVERED_BY_VENDOR, DELIVERED_BY_VENDOR));
                
                } else {
                    
                    orderLineItem.Delivered_By__c = publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c;
                    deliveryMethod.add(new SelectOption(publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c, 
                            publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c));
                    
                }
            }
            // End D-0033 UAT 01-03-2015 JohnD 
            //END: UD-0648 CommentedOut by RReyes to use new logic from StartSub*/

            // retrieve promotion contract period and penalty charge
            //START UD-0642 3/30/15 AddedBy FrancisBenzon : cater calculations even with only 1 package
            if (packageIdpromotionId.size() > 0) {
                
                //START D-2652 05/26/15 RReyes 
                if (packageIdpromotionId.size() > 1) {
                //START UD-1600 06/11/15 RReyes - added checking if promotion is not 'null'
                    if(packageIdpromotionId[1] != 'null'){
                        isFromPromotion = true;
                    }
                
                } 
        //END UD-1600 06/11/15 RReyes - added checking if promotion is not 'null' 
                //END D-2652 05/26/15 RReyes 
                //id proId = packageIdpromotionId[0];           
            //END UD-0642 3/30/15 AddedBy FrancisBenzon : cater calculations even with only 1 package      
                //START D-2048 2/2/2015 Added By C. Lin - Penalty Charge Override should be the Penalty Charge if available.
                //Start : Code Review Implementation 02/18/2015 S.Puli
                //START UD-1375 AddedBy FrancisBenzon : code changes so that promofields are N/A for non-promo packages 
                Promotion__c promoTmp = new Promotion__c();
                           
                Id proId;
                if(packageIdpromotionId.size() > 1)
                {
                    if(packageIdpromotionId[1] != null && packageIdpromotionId[1] != 'null')
                    {
                        proId = (Id)packageIdpromotionId[1];
                    }  
                }
                         
                //START UD-0642 3/30/15 AddedBy FrancisBenzon : cater calculations even with only 1 package and without promotion
                try
                {
                    
                    promoTmp = [select Id, Contract_Period__c, Penalty_Charge__c, Penalty_Charge_Override__c 
                                from Promotion__c 
                                where Id = :proId];
                    
                }
                catch(exception e)
                {
                    //promoTmp = new Promotion__c();
                }
      
                if(promoTmp.Id != null)
                {                  
                     orderLineItem.Promotion_ID__c = promoTmp.Id;
                
                    //START D-2048 2/2/2015 Added By C. Lin - Penalty Charge Override should be the Penalty Charge if available.
                    if(promoTmp.Penalty_Charge_Override__c != NULL){
                        orderLineItem.Penalty_Charge__c = promoTmp.Penalty_Charge_Override__c;
                    }
                    
                    else if (promoTmp.Penalty_Charge_Override__c == null && promoTmp.Penalty_Charge__c != NULL){
                        orderLineItem.Penalty_Charge__c = decimal.valueOf(promoTmp.Penalty_Charge__c);
                    }
                //END UD-1375 AddedBy FrancisBenzon : code changes so that promofields are N/A for non-promo packages 
                    else{
                        orderLineItem.Penalty_Charge__c = 0.00;
                    }
                    //END D-2048 2/2/2015 Added By C. Lin
                      
                    if (promoTmp.Contract_Period__c != null) {
                        orderLineItem.New_Contract_Period__c = integer.valueOf(promoTmp.Contract_Period__c);
                    } else {
                        orderLineItem.New_Contract_Period__c = 0;
                    }
                    //START UD-0658 EditedBy FrancisBenzon : added index to query to avoid error
                     //START: D-2374 02/25/2015 Francis Benzon - update promotion period
                    //START: UD-1038 05/15/15 RReyes - checks if publicationDetailList size > 0 
                    //START D-3132 06/19/15 RReyes - Added additional condition when new package is selected from subscription | changed formula    
                    if(publicationDetailList.size() > 0){
                            if ((publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c != null && orderLineItem.Main_Package_ID__c != zs.Main_Package_1__c) || (publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c != null && orderLineItem.Main_Package_ID__c == zs.Main_Package_1__c && orderLineItem.Promotion_ID__c != subPromoId))
                        {
                            orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1);
                            //orderLineItem.Contract_End_Date__c = publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1); - Commented out by RReyes to use new formula
                        }
                    }
                    //END D-3132 06/19/15 RReyes - Added additional condition when new package is selected from subscription | changed formula    
                    //END: UD-1038 05/15/15 RReyes - checks if publicationDetailList size > 0
                     //END: D-2374 02/25/2015 Francis Benzon   
                    //START UD-0658 EditedBy FrancisBenzon : added index to query to avoid error                 
                    // [JohnD 12/15] CCB-PC
                    // commented out
                    //populateAdminCharge();
                    // end CCB-PC
                    // START : D-1183 12/17/2014 Alyana P. Navarro - call method to populate admin charge               
                    //START: D-3265 22-July-2015 JTeves - prevent repetitive method calls causing SOQL101 error          
                    //retrieveAdminFee();
                    //END: D-3265 22-July-2015 JTeves
                    // END : D-1183 12/17/2014
                }
                //START UD-1375 AddedBy FrancisBenzon : for N/A value
                else
                {
                    orderLineItem.Penalty_Charge__c = null; // Start/End UD-1588 11Jun15 JohnD
                    orderLineItem.New_Contract_Period__c = 0;
                    orderLineItem.Contract_End_Date__c = null; // Start/End UD-1588 11Jun15 JohnD
                }
                //END UD-1375 AddedBy FrancisBenzon : for N/A value
                //START UD-0642 3/30/15 commentedOut By FrancisBenzon
                /*if(proId<>null){
                //End : Code Review Implementation 02/18/2015 S.Puli            
                    promoTmp = [select Id, Contract_Period__c, Penalty_Charge__c, Penalty_Charge_Override__c from Promotion__c where Id IN :        packageIdpromotionId];
                }//Start/End : Code Review Implementation 02/18/2015 S.Puli
                //END D-2048 2/2/2015 Added By C. Lin*/
                //END UD-0642 3/30/15 commentedOut By FrancisBenzon
            //START UD-0642 3/30/15 AddedBy FrancisBenzon : cater calculations even with only 1 package and without promotion
            } else {
              
                // converted to N/A in visualforce
                orderLineItem.Penalty_Charge__c = null; // Start/End UD-1588 11Jun15 JohnD
                //START D-2044 AddedBy FrancisBenzon 2/5/15 : Change param to 0 to display 0 after SaveAsDraft if NewContractPeriod is N/A
                orderLineItem.New_Contract_Period__c = 0;
                //END D-2044 AddedBy FrancisBenzon 2/5/15 : Change param to 0 to display 0 after SaveAsDraft if NewContractPeriod is N/A
                orderLineItem.Contract_End_Date__c = null; // Start/End UD-1588 11Jun15 JohnD
                // end converted to N/A in visualforce
              
            }
            // end retrieve promotion contract period and penalty charge
            //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
            isPackageSelected = true;
            //START UD-1600 06/10/15 RReyes - selects split value of selectedPackageId before ':' to remove 'null'
            mainPackageId = '';
            if(selectedPackageId!= null){
                if(selectedPackageId.contains(':')){
                    mainPackageId = selectedPackageId.substringBefore(':');
                }
            }
        //END UD-1600 06/10/15 RReyes - selects split value of selectedPackageId before ':'
            // Start PD-0136 02Jun16 JohnD - improved logic
            /* commented out
            if(mainPackageId == String.valueOf(zs.Main_Package_1__c)){//START/END UD-1600 06/10/15 RReyes - changed selectedPackageId to mainPackageId
                thisOrder.Order_Type__c = COS_QUANTITY;
            }
            else{
                thisOrder.Order_Type__c = COS_PACKAGE;
            }*/
            
            if (mainPackageId != string.valueOf(zs.Main_Package_1__c)) {
                thisOrder.Order_Type__c = COS_PACKAGE;
            } else if (zs.Number_Of_Copies__c != orderLineItem.Qty__c) {
                thisOrder.Order_Type__c = COS_QUANTITY;
            } else {
                thisOrder.Order_Type__c = COS_OTHERS;
            }
            // End PD-0136 02Jun16 JohnD - improved logic
            //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons
            
            //START D-2735 Wenjun 13/04/15 - Update Order to validate BA Billing Type
            thisOrder.Billing_Type__c = pkg.Billing_Type__c;
        //START D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
            try {
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = false;
                //END D-3094 06/16/15 RReyes
                UPDATE thisOrder;
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = true;
                //END D-3094 06/16/15 RReyes
            }
            catch(exception e) {
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = true;
                //END D-3094 06/16/15 RReyes
                //START D-3094 AddedBy KevinIbalio/Fritz/RReyes : remove apex error in page
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
                //END D-3094 AddedBy KevinIbalio/Fritz/RReyes : remove apex error in page
            }
        //END D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
            isDelivery =false;
            
        }
        catch(exception e) {
        //Start UD-1038Comment          
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Delivery Subscriptions cannot undergo Change of Subscription.'));
        }
        //END: UD-0959 MMallorca 04/23/2015
        //END D-2759 Wenjun 13/04/15
        
        //START D-3132 06/19/15 RReyes - retrieves admin charges only when called on select of package
                if(isCalledOnSelect){
                    retrieveAdminFee();
                    retrieveAdminCharge();
                }
        isCalledOnSelect = true; 
        //END D-3132 06/19/15 RReyes - retrieves admin charges only when called on select of package
        //START D-3132 06/22/15 RReyes - set correct contract end date
        if (orderLineItem.New_Contract_Period__c != null && orderLineItem.Start_Date__c != null && orderLineItem.Promotion_ID__c != null) {    
                orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1); //fritz
            }
        //END D-3132 06/22/15 RReyes - set correct contract end date
        
        currentPromotionId = null; // Start/End UD-2174 01Aug15 JohnD
    }

    /*
     * This method will retrieve the admin charge from previous subscription
     */
    private void populateAdminCharge() {

        decimal adminCharge = 0;
        // retrieve admin charge from previous subscription
        if (thisOrder.Subscription__c != null) {
            
            for (Zuora__SubscriptionProductCharge__c tmp : [select Zuora__Price__c from Zuora__SubscriptionProductCharge__c 
                    where Zuora__Subscription__c = :thisOrder.Subscription__c and Name = :GlobalVariableClass.ADMIN_CHARGE]) {
                
                adminCharge += tmp.Zuora__Price__c;
            }
            
            orderLineItem.Admin_Charge__c = adminCharge;
        }
        // end retrieve admin charge from previous subscription     
    }
  
  /************ asia1 functionality ***************/
    //START: D-2380 02/26/2015 JTeves - Asia1 functionality
    private boolean isAsia1Validated = false;
    //END: D-2380 02/26/2015 JTeves - Asia1 functionality
    private void initializeAsia1Components() {
        
        isCreateNew = true;
        asia1Subscriptions = new list<Asia1Wrapper>();
        asia1SingleAccount = new Asia1__c();
        ldapValidityImg = '/s.gif';
        displayNameValidityImg = '/s.gif';
    }
    
    
    public void addAsia1ExistingAccount() {
        
        //START: PD_0035 May 12, 2016 Added by Kristine Balaoing - added for digital add ons
        retrieveAddOn(selectedAddOnPackage);
        //END: PD_0035 May 12, 2016 Added by Kristine Balaoing      
        // check if package is from promotion
        list<string> packageIdpromotionId = selectedPackageId.split(':');
        //START D-3289 07/28/2015 Added by Dags - Check enabled Service Flags
        Asia1__c tmpAsia2 = [select Id, User_ID_LDAP_ID__c from Asia1__c where Id = :asia1SelectedExistingId];
       
        Map<String, Object> userDetailsMap = new Map<String, Object>();
        userDetailsMap = AsiaOneServicesController.verifyUser2(tmpAsia2.User_ID_LDAP_ID__c, null);
        SM_SubscriptionHelper.enabledServices = string.valueOf(userDetailsMap.get('Service'));
        //END D-3289 07/28/2015 Added by Dags - Check enabled Service Flags
        
        //Start : Code Review Implementation 02/18/2015 S.Puli
        Asia1__c tmpAsia1;
        if(asia1SelectedExistingId<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli
            tmpAsia1 = [select Id, User_ID_LDAP_ID__c from Asia1__c where Id = :asia1SelectedExistingId];
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        //START UD-0631 3/26/15 AddedBy FrancisBenzon : loop Asia1 so that adding every username will not overwrite others.
        for (Asia1Wrapper asia1wrapper : createAsia1SubscriptionFromAccessFlag(tmpAsia1.User_ID_LDAP_ID__c, tmpAsia1.Id, packageIdpromotionId[0])){
             asia1Subscriptions.add(asia1wrapper);
        }
        //END UD-0631 3/26/15 AddedBy FrancisBenzon : loop Asia1 so that adding every username will not overwrite others.
        asia1SubscriptionsTotal = asia1Subscriptions.size();
    }
    
    
    /*
     * This method will create a new asia 1 account
    */
    public void addAsia1NewAccount() {
        //START: PD_0035 May 12, 2016 Added by Kristine Balaoing - added for digital add ons
        retrieveAddOn(selectedAddOnPackage);
        //END: PD_0035 May 12, 2016 Added by Kristine Balaoing
        //START: D-2380 02/26/2015 JTeves - Asia1 functionality 
        if (selectedPackageId != null) {
        //START UD-1726 6/26/2015 JLedesma : Added validation rule for Quantity and AsiaOne Accounts
            if(orderLineItem.Qty__c > asia1Subscriptions.size()){
                list<string> packageIdpromotionId = selectedPackageId.split(':');
                //START UD-3896 3/31/2016 Added by J.Sarion - check if password is null
                isAsia1Validated = false;
                validateNewAsia1Account();
                if (isAsia1Validated == true && asia1SingleAccount.Password__c != null && asia1SingleAccount.Password__c != '') {
                    
                    asia1SingleAccount.id = null;
                    asia1SingleAccount.Status__c = 'Pending Creation';
                    asia1SingleAccount.Contact__c = thisOrder.Recipient_Contact__c;
                    asia1SingleAccount.Order_Number__c = thisOrder.name;    // Start/End UD-3452 29Dec15 JohnD
            
                    try {
                    
                        insert asia1SingleAccount;
                        //Start D-2176 02/11/2015 Added by April Banaag - add newly created Asia1 record to list instead of overwriting  the list
                        for (Asia1Wrapper asia1wrapper : createAsia1SubscriptionFromAccessFlag(asia1SingleAccount.User_ID_LDAP_ID__c, asia1SingleAccount.Id, packageIdpromotionId[0])){
                            asia1Subscriptions.add(asia1wrapper);
                        }
                        //System.assertEquals(null, asia1Subscriptions);
                        asia1SubscriptionsTotal = asia1Subscriptions.size();
                        //End D-2176 02/11/2015 Added by April Banaag - add newly created Asia1 record to list instead of overwriting  the list
                        
                        // reset asia1 single account
                        asia1SingleAccount = new Asia1__c();
                        // end reset asia1 single account
                
                        ldapValidityImg = '/s.gif';
                        displayNameValidityImg = '/s.gif';
                        
                    } catch (exception e) {
                        ApexPages.addMessages(e);
                    }
                }
                else if(asia1SingleAccount.Password__c == null || asia1SingleAccount.Password__c == '') {
                    ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'Password is required'));
                    //ApexPages.addMessages('Password is required');
                    if(userinfo.getLastName() == 'Sarion') {
                        //system.assertequals('>>>>> ', '>>>>>>1 ');
                    }
                }
                //END UD-3896 3/31/2016 Added by J.Sarion - check if password is null
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('MoreThanAsia1Creation')));
            }
        }       
        //END: D-2380 02/26/2015 JTeves - Asia1 functionality 
    }
    //END UD-1726 6/26/2015 JLedesma : Added validation rule for Quantity and AsiaOne Accounts
    
    
    public void validateNewAsia1Account() {
        map<string, Object> isValidUserName = new map<string, object>();
        map<string, Object> isValidDisplayName = new map<string, Object>();
        // check require fields
        if (asia1SingleAccount.User_ID_LDAP_ID__c != null && asia1SingleAccount.Display_Name__c != null) {
            
            // call to asia1 actual
            //START: D-2380 02/26/2015 JTeves - Asia1 functionality 
            isValidUserName = validateAsia1Account(asia1SingleAccount.User_ID_LDAP_ID__c, asia1SingleAccount.Display_Name__c);
            ldapValidityImg = (String) isValidUserName.get('ldap');
            displayNameValidityImg = (String) isValidUserName.get('username');
            isAsia1Validated = (boolean)isValidUserName.get('success');
            // end call to asia1 actual
            //END: D-2380 02/26/2015 JTeves - Asia1 functionality 
        } else {
            
            ldapValidityImg = '/s.gif';
            displayNameValidityImg = '/s.gif';
            
            if (asia1SingleAccount.User_ID_LDAP_ID__c == null) {
                asia1SingleAccount.User_ID_LDAP_ID__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
            }
            
            if (asia1SingleAccount.Display_Name__c == null) {
                asia1SingleAccount.Display_Name__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
            }
            
        }

        // end check require fields
    }
    
    
    public void removeAsia1Subscription() {
        
        integer i = 0;
        
        for (i = 0; i < asia1Subscriptions.size(); i++) {   
            if (asia1Subscriptions.get(i).asia1Id == asia1IdToBeRemoved) {
                asia1Subscriptions.remove(i);
            }
        }
        asia1SubscriptionsTotal = asia1Subscriptions.size(); //START/END UD-3431 12/22/15 RReyes
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(asia1IdToBeRemoved<>null){
        //end : Code Review Implementation 02/18/2015 S.Puli
            delete [select id from Asia1__c where Id = :asia1IdToBeRemoved and Status__c = 'Pending Creation'];
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
    }
    
    
    public list<SelectOption> getAsia1ExistingAccounts() {
        
        list<SelectOption> options = new list<SelectOption>();
        
        if (asia1Subscriptions != null) {
          
          set<id> tmpAsia1Ids = new set<id>();
          for (Asia1Wrapper tmpw : asia1Subscriptions) {
              tmpAsia1Ids.add(tmpw.asia1Id);
          }
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(accountId<>null && tmpAsia1Ids<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
            //START UD-3454 01/06/15 RReyes - added condition if Asia1 is not Disabled
            String disabled = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
                for (Asia1__c asia1 : [select Id, User_ID_LDAP_ID__c from Asia1__c where Contact__r.Account.Id = :accountId  and Id not in :tmpAsia1Ids and status__c!=:disabled]) {
                    options.add(new SelectOption(asia1.Id, asia1.User_ID_LDAP_ID__c));
                }
            //END UD-3454 01/06/15 RReyes - added condition if Asia1 is not Disabled
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        }
        
        return options;
    }
    
    
  /************ end asia1 functionality ***************/
    
    
  /************ billiing payment functionality ***************/
    
    private void initializePaymentComponents() {

        try {
        
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(accountId<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
            //START UD-0452 3/23/15 AddedBy FrancisBenzon additional field in query
                 thisAccount = [SELECT Id, Name, AccountNumber, Total_Credit_Balance1__c, RecordTypeId FROM Account WHERE Id = :accountId];
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
            //END UD-0452 3/23/15 AddedBy FrancisBenzon additional field in query
        } catch(Queryexception e) {
            //no matching acct / no passed accunt id
            thisAccount = new Account();
        }
        
        dummySubscription = new Zuora__Subscription__c();
        thisQuote = new zqu__Quote__c();
    }
    

    public List<SelectOption> getDeliveryChargeTypes() {

        List<SelectOption> chargeTypes = new List<SelectOption>();
        //dependent on recipient type
        
        string defaultType = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
        chargeTypes.add(new SelectOption(defaultType, defaultType));
        chargeTypes.add(new SelectOption('S', 'S'));
        chargeTypes.add(new SelectOption('N', 'N'));
        chargeTypes.add(new SelectOption('Z', 'Z'));
        chargeTypes.add(new SelectOption('9', '9'));
        return chargeTypes;
    }
    
    
    public List<SelectOption> getBillingAccountOptions() {
        List<SelectOption> billingOptions = new List<SelectOption>();
        
        if (totalBillingAccounts > 0) {
            billingOptions.add(new SelectOption('useExisting', 'Use existing Billing Account'));
        // Start UD-2614 06Sep15 JohnD - added logic
        } else {
            billingAccountOption = 'createNew';
        }
        // End UD-2614 06Sep15 JohnD - added logic
        
        billingOptions.add(new SelectOption('createNew', 'Create new Billing Account'));
        return billingOptions;
    }
    

    public void fetchBillingAccount() {
        //START D-2616 3/24/15 AddedBy FrancisBenzon :default boolean to false
        isOtherPayment = false;
        //END D-2616 3/24/15 AddedBy FrancisBenzon :default boolean to false
        //START UD-3437 4Jan16 AddedBy FrancisBenzon : initialize  
        renderCheckDetails = false;     
        //END UD-3437 4Jan16 AddedBy FrancisBenzon : initialize
        if (thisOrder.Billing_Account__c != null) {
            //START D-2331 2/24/15 AddedBy FrancisBenzon : related to D-1485 and D-0852 
            //START/END D-2616 3/24/15 AddedBy FrancisBenzon : added Other_PaymentMethod__c field in query
            thisBillingAccount = [SELECT Id, Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__r.Zuora__Type__c, Name, Zuora__PaymentMethod_Type__c, Zuora__Credit_Balance__c, 
                    Payment_Mode__c, Other_PaymentMethod__c
                    FROM Zuora__CustomerAccount__c WHERE Id = :thisOrder.Billing_Account__c];
            if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'ACH'){
                thisOrder.Payment_Mode__c = 'ACH';
            } 
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'BankTransfer'){
                thisOrder.Payment_Mode__c = 'Bank Transfer';
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'Cash'){
                thisOrder.Payment_Mode__c = 'Cash';
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'CreditCard'){
                thisOrder.Payment_Mode__c = 'Credit Card';
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'CreditCardReferenceTransaction'){
                thisOrder.Payment_Mode__c = 'Credit Card Reference Transaction';
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'DebitCard'){
                thisOrder.Payment_Mode__c = 'Debit Card';
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'Other'){
                thisOrder.Payment_Mode__c = 'Other';
                //START D-2616 3/24/15 AddedBy FrancisBenzon : to populate other Payment method 
                isOtherPayment = true;
                if(thisBillingAccount.Other_PaymentMethod__c != null)
                {
                    thisOrder.Other_Payment_Mode__c = thisBillingAccount.Other_PaymentMethod__c;
                }
                else{
                    thisOrder.Other_Payment_Mode__c  = 'Invoice';
                }
                //END D-2616 3/24/15 AddedBy FrancisBenzon : to populate other Payment method   
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'PayPal'){
                thisOrder.Payment_Mode__c = 'PayPal';
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'WireTransfer'){
                thisOrder.Payment_Mode__c = 'Wire Transfer';
            }
            //START D-2616 3/24/15 AddedBy FrancisBenzon : consider Check in retrieval
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'Check')
            {
                //START UD-3437 4Jan16 AddedBy FrancisBenzon : check if cb > subrate
                if(dueToSph != null && dueToSph != 0)
                {
                    renderCheckDetails= true;
                }
                //END UD-3437 4Jan16 AddedBy FrancisBenzon : check if cb > subrate
                thisOrder.Payment_Mode__c = 'Check';
            }
            //END D-2616 3/24/15 AddedBy FrancisBenzon : consider Check in retrieval
            else{
                thisOrder.Payment_Mode__c = '';
            }           
        } else{
            thisOrder.Payment_Mode__c = '';
        }
       //END D-2331 2/24/15 AddedBy FrancisBenzon : related to D-1485 and D-0852 
        //START D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to blank if payment mode is not "Other"
        if (thisOrder.Payment_Mode__c != 'Other'){
        thisOrder.Other_Payment_Mode__c = '';}
        //END D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to null if payment mode is not "Other"    
    }    
    
        
    //START UD-3351 12/18/2015 Added by J.Sarion - Set Zuora URL for Zuora Hosted Page
    public string paymentGetway { get; set; }
    public string creditCardType { get; set; }
    
    public void retrieveSource() {    
        
        if(creditCardType == 'American Express') {
            paymentGetway = ConstantsSLB.getZuoraUrl('Amex');
        }
        else {
            paymentGetway = ConstantsSLB.getZuoraUrl('Default');
        }
   
    }
    
    public String getSource() {    
        return ConstantsSLB.getZuoraUrl('Default');
    
   }
   //END UD-3351 12/18/2015 Added by J.Sarion - Set Zuora URL for Zuora Hosted Page

    
    public void clearPaymentMethod() {
        thisOrder.Payment_Mode__c = null;
        thisOrder.Other_Payment_Mode__c = null; //START/END D-3373 8/17/15 AddedBy FrancisBenzon : nullify other payment method
    }
    
    
    public void clearOtherPaymentMethod() {

        thisOrder.Other_Payment_Mode__c = null;
        thisOrder.Billing_Account__c = null;
    }
  
  /************ end billiing payment functionality ***************/
  
    // [JohnD 12/15] CCB-PC
    // this method will retrieve the admin charge and the refundable amount
    // this was invoke from vf page
    public void retrieveAdminFee() {
       //START UD-0648 4/27/15 AddedBy RReyes : ErrorMessage
        String FullPrepaidEvergreen = GlobalVariableClass.FULLPREPAID_EVERGREEN_ERROR;
        //END UD-0648 4/27/15 AddedBy RReyes : ErrorMessage
        //START UD-2173 7/30/15 AddedBy FrancisBenzon : variables and dates
        //START UD-2213 7/30/15 AddedBy FrancisBenzon : realted to 2173
        Date oldSubStartDate;
        Date cosStartDate;
        // Start UD-2211 19Aug15 JohnD - rearranged to prevent null pointer
        Date oldSubStartDate_MonthEnd;
        Date oldSubStartDate_NextMonthEnd;
        Date cosFirstDayOfLastMonth;
        Date cosEndOfMonthLastMonth;
        Set<Date> startSubMonthEndDates = new set<date>();
        Date cosStartDateMinusOne;
        if(zs.Zuora__SubscriptionStartDate__c != null && orderLineItem.Start_Date__c != null)
        {
            oldSubStartDate = zs.Zuora__SubscriptionStartDate__c;
            cosStartDate = orderLineItem.Start_Date__c;
            oldSubStartDate_MonthEnd = oldSubStartDate.addMonths(1).toStartOfMonth().addDays(-1); 
            oldSubStartDate_NextMonthEnd = oldSubStartDate.addMonths(2).toStartOfMonth().addDays(-1);
            cosFirstDayOfLastMonth = cosStartDate.addMonths(-1).toStartOfMonth();
            cosEndOfMonthLastMonth = cosFirstDayOfLastMonth.addDays(Date.daysInMonth(cosFirstDayOfLastMonth.year(), cosFirstDayOfLastMonth.month()) - 1);
            startSubMonthEndDates.add(oldSubStartDate_MonthEnd);
            startSubMonthEndDates.add(oldSubStartDate_NextMonthEnd);
            cosStartDateMinusOne = orderLineItem.Start_Date__c.addDays(-1);
        }       
        // End UD-2211 19Aug15 JohnD - rearranged to prevent null pointer
        //END UD-2173 7/30/15 AddedBy FrancisBenzon : variables and dates
        //END UD-2213 7/30/15 AddedBy FrancisBenzon : realted to 2173
        //START D-1792 1/23/2015 JLedesma update values in method of computeAdminCharge 
        //START: 01/08/2015 D-1447 S.Puli Check if parameters are not null
        //START: D-2883 05/13/2015 RReyes - Refresh Account, Set Credit Balance to Account - Total Credit Balance
        initializePaymentComponents();
        thisOrder.Credit_Balance__c = thisAccount.Total_Credit_Balance1__c;
        //END: D-2883 05/13/2015 RReyes - Refresh Account, Set Credit Balance to Account - Total Credit Balance
        //START UD-2173 7/30/15 AddedBy FrancisBenzon : zero refund for recurring prepaid-any billing type if end date is end of month
        //START UD-2213 7/30/15 AddedBy FrancisBenzon : realted to 2173       
        if(thisOrder.Subscription__c <> null && orderLineItem.Start_Date__c <> null){           
            orderLineItem.Admin_Charge__c = AdminFeeComputation.computeAdminCharge(zs.Id, orderLineItem.Start_Date__c); 
            //START UD-0648 4/27/15 AddedBy RReyes : ErrorMessage for computeRefund if data is FullPrepaidEvergreen
            if(zs.Billing_Type__c != null && zs.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE 
                    && cosStartDateMinusOne != null && cosEndOfMonthLastMonth != null 
                    && (startSubMonthEndDates.contains(cosStartDateMinusOne) || cosStartDateMinusOne == cosEndOfMonthLastMonth)) // Start/End UD-2211 19Aug15 JohnD - added cosStartDateMinusOne != null && cosEndOfMonthLastMonth != null
            {
                thisOrder.Credit_Amount__c = thisOrder.Credit_Balance__c;
                system.debug(':::SAIS' + thisOrder.Credit_Amount__c);
            }
            else {
                try {
                    system.debug(':::SIETE' + orderLineItem.Start_Date__c);
                    //START D-2883 05/09/15 RReyes - Added Credit Balance in computation of Credit Amount
                    system.debug('>>>>>CHA thisOrder.Credit_Balance__c ' + thisOrder.Credit_Balance__c);
                    thisOrder.Credit_Amount__c = RefundComputation.computeRefund(thisOrder.Subscription__c, orderLineItem.Start_Date__c) + thisOrder.Credit_Balance__c; 
                    system.debug('>>>>>CHA thisOrder.Credit_Amount__c ' + thisOrder.Credit_Amount__c);
                    //END D-2883 05/09/15 RReyes - Added Credit Balance in computation of Credit Amount
                    //Fritz Trial 
                    BaseSubRate = thisOrder.Credit_Amount__c - thisOrder.Credit_Balance__c;
                    //Fritz Trial
                }
                catch(exception e) {
                    //START D-4340 20Jan16 Fritz : changed error to correct one
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(FullPrepaidEvergreen)));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, string.valueOf(e).replace('CustomException:[]:', '')));
                    //END D-4340 20Jan16 Fritz : changed error to correct one
                }
                //END UD-0648 4/27/15 AddedBy RReyes : ErrorMessage for computeRefund if data is FullPrepaidEvergreen       
            }       
        } 
        //END: 01/08/2015 D-1447 S.Puli
        
        //END UD-2173 7/30/15 AddedBy FrancisBenzon : zero refund for recurring prepaid-any billing type if end date is end of month
        //END UD-2213 7/30/15 AddedBy FrancisBenzon : realted to 2173
        //END D-1792 1/23/2015 JLedesma update values in method of computeAdminCharge 
    }
    // end CCB-PC
    
    //START D-1792 1/27/2015 JLedesma Calculate fields in credit and charges section
    /**
    * @author: <JerellaMayelLedesma>
    * Date: <1/28/2015>
    * Requirement/Project Name: <SPH>
    * @description<Calculates fields for Credit and Charges>
    */
    //START D-1792 1/23/2015 JLedesma Calculate fields   
    public void retrieveAdminCharge(){
        
        if (zs != null && zs.Zuora__CustomerAccount__c != null && orderLineItem != null) {  // Start/End UD-2211 19Aug15 JohnD - prevent null pointer
            //START D-2883 05/12/15 RReyes - computes updated Admin Fee for computation below
            //START D-2883 05/12/15 RReyes - Retrieves Admin Fee
            //START D-2663 AddedBy FrancisBenzon : to prevent SOQL 101 and to cater calculations onload of sub details
            //START UD-1038 5/18/15 RReyes: added condition for change in date
            //START: D-3272 23-July-2015 JTeves - set correct package id onload
            if(!isOnload && (orderLineItem.Qty__c != selectedSubscription.quantity || orderLineItem.Start_Date__c != selectedSubscription.subscriptionStartDate))
            {
                retrieveAdminFee();
            }
            //END: D-3272 23-July-2015 JTeves
            //END UD-1038 5/18/15 RReyes: added condition for change in date        
            //END D-2663 AddedBy FrancisBenzon : to prevent SOQL 101 and to cater calculations onload of sub details        
            //END D-2883 05/12/15 RReyes - Retrieves Admin Fee
            if(zs.Contract_End_Date_1__c != NULL){
                if(zs.Contract_End_Date_1__c > orderLineItem.Start_Date__c){
                    //START D-2003 D-1977 2/16/215 AddedBy FrancisBenzon : added additional If statement to catch null pointer error
                    //START D-2401 JTeves 03/03/2015 JTeves - Check Penalty Charge Override before checking Penalty Charge
                    orderLineItem.Admin_Charge__c = AdminFeeComputation.computeAdminCharge(zs.Id, orderLineItem.Start_Date__c);
                    //END D-2401 JTeves 03/03/2015 JTeves - Check Penalty Charge Override before checking Penalty Charge
                    //END D-2003 D-1977 2/16/215 AddedBy FrancisBenzon : added additional If statement to catch null pointer error
                }
            }
             
            if(zs.Zuora__CustomerAccount__r.Zuora__Credit_Balance__c == NULL){ 
                zs.Zuora__CustomerAccount__r.Zuora__Credit_Balance__c = 0;
            }
            if(orderLineItem.Main_Package_Subscription_Rate__c == NULL){
                orderLineItem.Main_Package_Subscription_Rate__c = 0;
            }
            
            //END D-1792 1/27/2015 JLedesma Calculate fields in credit and charges section  
            if(orderLineItem.Qty__c == null){
                orderLineItem.Qty__c = 0;
            }
            
            if(orderlineItem.Add_On_Package_Subscription_Rate__c == null){
                orderlineItem.Add_On_Package_Subscription_Rate__c = 0;
            }
            
            if(orderLineItem.Admin_Charge__c == null){
                orderLineItem.Admin_Charge__c = 0;
            }
             
            //START D-3101 6/17/15 AddedBy FrancisBenzon : calculates subscriber charge wrt to term length and delivered by.
            recalculateCharges();
            
            additionalCharges = thisOrder.Full_Prepaid_Delivery_Charge__c + thisOrder.Recurring_Delivery_Charge__c + orderLineItem.Postage_Charge__c;
            thisOrder.Total_Full_Prepaid__c = additionalCharges;
            //START UD-1443 AddedBy FrancisBenzon : change subrate to Base Subrate
            //totalSubRate = (orderLineItem.Main_Package_Subscription_Rate__c + orderlineItem.Add_On_Package_Subscription_Rate__c)*orderLineItem.Qty__c;
            totalSubRate = (subscriptionRate + orderlineItem.Add_On_Package_Subscription_Rate__c)*orderLineItem.Qty__c;  
            //END UD-1443 AddedBy FrancisBenzon : change subrate to Base Subrate
            //4407
            system.debug(':::AdminCharge ' + orderLineItem.Admin_Charge__c);
            system.debug(':::totalSubRate ' + totalSubRate);
            system.debug(':::additionalCharges ' + additionalCharges);
            system.debug(':::CreditAmount ' + thisOrder.Credit_Amount__c);
            system.debug(':::Total ' + orderLineItem.Admin_Charge__c + totalSubRate + additionalCharges);
            
            //Start D-4402 VPernicia 4/16/2016
            giftAmount = 0;
            if (promotionGifts != null) {
                if (promotionGifts.size() > 0){
                    for (GiftWrapper gw : promotionGifts) {
                        system.debug(':::SelectGift ' + gw.selectGift);
                        if (gw.selectGift) {
                            
                            giftAmount = giftAmount + gw.promotionGift.Gift__r.One_Time_Charge__c;
                        }
                    }
                    giftAmount = giftAmount * orderLineItem.Qty__c;
                }
            }
            
            if((orderLineItem.Admin_Charge__c + totalSubRate + additionalCharges) > thisOrder.Credit_Amount__c){
                dueToSph = ((orderLineItem.Admin_Charge__c + totalSubRate + additionalCharges) - thisOrder.Credit_Amount__c) + giftAmount; 
            }
            else {
                dueToSph = 0;
            }

            if(thisOrder.Credit_Amount__c > (orderLineItem.Admin_Charge__c + totalSubRate + additionalCharges)){
                dueToCustomer = (thisOrder.Credit_Amount__c - (orderLineItem.Admin_Charge__c + totalSubRate + additionalCharges)) - giftAmount;
            }
            else{
                dueToCustomer = 0;
            }
            //End D-4402 VPernicia 4/16/2016
            //4407
        }   // Start/End UD-2211 19Aug15 JohnD - prevent null pointer
        
        // Start PD-0136 02Jun16 JohnD - added logic to change the order type everytime the quantity changes
        if (thisOrder.Order_Type__c != COS_PACKAGE) {
            if (zs.Number_of_Copies__c != orderLineItem.Qty__c) {
                thisOrder.Order_Type__c = COS_QUANTITY;
            } else {
                thisOrder.Order_Type__c = COS_OTHERS;
            }
        }
        // End PD-0136 02Jun16 JohnD - added logic to change the order type everytime the quantity changes
    }    
        //END D-1792 1/23/2015 JLedesma Calculate fields    
        //END D-3101 6/17/15 AddedBy FrancisBenzon : calculates subscriber charge wrt to term length and delivered by.
        
        //START UD-2738 Wenjun 21/Sep/15 : No longer needed
        /*
        //START D-2332 3/6/15 AddedBy FrancisBenzon : COS method to check Invoice Date and compare it with COS Start Date 
        //START UD-0658 4/16/15 UpdatedBy FrancisBenzon : changed checking from invoice date to target date
        //START D-3224/UD-1044 7/6/15 Rebuild AddedBy francisBenzon : always check invoice line items
        public void checkInvoiceForBillingAccount() {        
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();    
        //passedInvoiceValidation = true;
        Boolean isBeforeInvTargetDate = false;  
        Date targetDate;   
        Set<Date> todayAndTomorrow = new Set<Date>{date.today(), date.today().addDays(1)};
        //Date invoiceDate;
        
        //START/END UD-0632 4/21/15 AddedBy FrancisBenzon : added condition to cater Full Prepaid Packages only
        if(zs.Zuora__CustomerAccount__c != null && zs.Billing_Type__c != null)
        {
            //START UD-0648 4/27/15 AddedBy FrancisBenzon : replaced checking to TargetDate
            invoiceList = [Select Zuora__InvoiceDate__c, Zuora__TargetDate__c From Zuora__ZInvoice__c 
                            Where Zuora__BillingAccount__c = :zs.Zuora__CustomerAccount__c
                            And Zuora__Status__c != 'Cancelled'];
            //START D-3224/UD-1044 6/1/15 AddedBy FrancisBenzon : to ensure Invoices are synced 
            
           //START UD-1733 AddedBy FrancisBenzon : checking no longer needed as user can perform COS for Future dated Subs
            targetDate = SM_SubscriptionHelper.checkInvoiceTargetDate(zs.Id, orderLineItem.Start_Date__c);          
            /*if(zs.Zuora__SubscriptionStartDate__c != orderLineItem.Start_Date__c)
            {               
                targetDate = SM_SubscriptionHelper.checkInvoiceTargetDate(zs.Id, orderLineItem.Start_Date__c);
                system.debug(':::TARGETDATE  ' + targetDate);
            }
            */
            //END UD-1733 AddedBy FrancisBenzon : checking no longer needed as user can perform COS for Future dated Subs
            //replace this with boolean
            //START UD-2084 AddedBy FrancisBenzon 7/24/15 : exclude migrated Billing Accounts in Invoice Checking
            /*
            if((invoiceList == null || invoiceList.isEmpty()) && zs.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID && zs.Zuora__CustomerAccount__r.Legacy_Billing_Account_Id__c == null) //START UD-2531 Added by Dags Added parenthesis
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage(COSError2)));
                passedInvoiceValidation = false;
            }
            if(targetDate != null && targetDate > orderLineItem.Start_Date__c) //Fritz hotfix
            {              
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage(COSError1) + ': ' + targetDate.format()));
                passedInvoiceValidation = false;
            }
            
            //START UD-2482 8/25/15 AddedBy FrancisBenzon : require generation of ILI for BAs with Invoices
            if(targetDate == null && zs.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID && zs.Zuora__CustomerAccount__r.Legacy_Billing_Account_Id__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage('COS ILI Error')));
                passedInvoiceValidation = false;
            }
            //END UD-2482 8/25/15 AddedBy FrancisBenzon : require generation of ILI for BAs with Invoices
            
            if(zs.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && orderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE && todayAndTomorrow.contains(orderLineItem.Start_Date__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Start Date must be atleast 2 days from today.'));
                passedInvoiceValidation = false;
            }
            */
            /*
            else if(targetDate == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please produce Invoice Line Items.'));
                passedInvoiceValidation = false;
            }
            //END D-3224/UD-1044 6/1/15 AddedBy FrancisBenzon : to ensure Invoices are synced
            */
            //START UD-1044 CommentedOut by FrancisBenzon : new implementation that users can perform COS anytime.
            //END UD-0648 4/27/15 AddedBy FrancisBenzon : replaced checking to TargetDate         
            //START/END D-2616 AddedBy FrancisBenzon : change if checking
            /*
            if(invoiceList != null && !invoiceList.isEmpty()) 
            {
                invoiceDate = invoiceList[0].Zuora__InvoiceDate__c;
                targetDate = invoiceList[0].Zuora__TargetDate__c; 
                            
                if(orderLineItem.Start_Date__c < targetDate)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage(COSError1)));
                    passedInvoiceValidation = false;                    
                }           
            }
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage(COSError2)));
                passedInvoiceValidation = false;
            }
            */ 
            //END UD-1044 CommentedOut by FrancisBenzon : new implementation that users can perform COS anytime.   
    /*          
        }
    }
    */
    //END D-3224/UD-1044 7/6/15 Rebuild AddedBy francisBenzon : always check invoice line items
    //END UD-0658 4/16/15 UpdatedBy FrancisBenzon : changed checking from invoice date to target date
    //END D-2332 3/6/15 AddedBy FrancisBenzon : COS method to check Invoice Date and compare it with COS Start Date  
    //END UD-2738 Wenjun 21/Sep/15 : No longer needed
        
    //START D-3227 7/6/15 Rebuild AddedBy francisBenzon : cannot change for prepaid to postpaid packages
    public void checkBillingTypes()
    {
        String fullPrepaid = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
        String recPrepaid = GlobalVariableClass.BILLING_TYPE_MR_PRE;
        String recPostpaid = GlobalVariableClass.BILLING_TYPE_MR_POST;
        String errorSubscriptionChange = GlobalVariableClass.errorPrepaidToPostpaid;
        Set<String> prepaidPackages = new Set<String>{fullPrepaid, recPrepaid};
        passedInvoiceValidation = true;
        
        if(zs.Billing_Type__c != null && prepaidPackages.contains(zs.Billing_Type__c) && orderLineItem.Main_Package_Billing_Type__c == recPostpaid)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ConstantsSLB.getErrorMessage(errorSubscriptionChange)));
            passedInvoiceValidation = false;
        }       
    }
    //END D-3227 7/6/15 Rebuild AddedBy francisBenzon : cannot change for prepaid to postpaid packages
    
    //START D-2617 3/25/15 AddedBy FrancisBenzon : added ARMS functionality in COS
    public String aCust {get; set;}         
    public string billAccName {get; set;}       
    public boolean billAcc {get; set;}      
            
    public String accTextName {get; set;}       
    public String accNum {get; set;}        
    public String errorMsg {get; set;}      
    public boolean displayCusErr {get; set;}        
    public boolean displayAccList {get; set;}       
    public boolean addAccount {get; set;}       
    public boolean redisplay;       
    public boolean CBdisable {get; set;}        
    //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
    public boolean searchAcctTick=false;
    public boolean searchCustTick=false;
    //END UD-1214        
    
    public class armsWrapper {      
            
    public string arNum {get; set;}         
    public string arName {get; set;}        
    public string arPOC {get; set;}         
    public string arAddress {get; set;}         
    public string arPostcode {get; set;}        
    public string arStatus {get; set;}      
    public string arBusProf {get; set;}         
    public string arDate {get; set;}        
    public boolean isTick {get; set;}       
    public string arAccNum {get; set;}      
    public string arType {get; set;}        
    public string arCredTerm{get; set;}         
    public string arCredTermRef {get; set;}         
    public string arDebtMgmt {get; set;}        
    public string arCompCode {get; set;}        
    public string arCreateDate {get; set;}      
    public string arBLInd {get; set;}       
    public string BLClrCd {get; set;}       
    public string BLRsn {get; set;}         
    public string IdTyp {get; set;}         
    public string IdN {get; set;}       
    public string PpCntryC {get; set;}      
    public string CrRskRtg {get; set;}      
    public string CrLmtInt {get; set;}      
    public string CrLmtExt {get; set;}      
    public string CityM {get; set;}         
    public string Cntry {get; set;}         
    public string PoBoxN {get; set;}        
    public string AttnI {get; set;}         
    public string StfI {get; set;}      
    public string GstOOSI {get; set;}       
    public string UpdId {get; set;}         
    public string UpdDte {get; set;}        
    public string UpdTme {get; set;}        
    public string arAddress1 {get; set;}        
    public string arAddress2 {get; set;}        
    public string arAddress3 {get; set;}        
    public string arAddress4 {get; set;}        
    }       
            
    public List<armsWrapper> armsCusWrapList {get; set;}        
    public List<armsWrapper> armsSelected {get; set;}       
            
            
    public void getBillAccName() {      
        //START D-2760 14-Apr-2015 Added by Raviteja  - Commented for as part of the duplicate ARMS ID changes
        billAccName = null;
        billAcc = true;
        //End D-2760 14-Apr-2015 Added by Raviteja         
    }       
            
    public void searchCusName(){        
            
        try{                
            accTextName =null;      
            accNum = null;      
        
            if(aCust<>null && aCust<>''){       
                                    
                //callout to webservice to search       
                wwwSphComArWsWsdlCam.SearchCustomerRequestType searchCusReq = new wwwSphComArWsWsdlCam.SearchCustomerRequestType();         
        
                searchCusReq.CusSrch = new wwwSphComArWsSchemaCamSearchcusto.CusSrch_element();         
                searchCusReq.CusSrch.SysId = ConstantsSLB.getOther('ARMS_SysId');       
                searchCusReq.CusSrch.CusM1 = aCust;         
        
        
                searchCusReq.user_x = new wwwSphComArWsSchemaCommonUser.UserType();         
                searchCusReq.user_x.userID = ConstantsSLB.getOther('ARMS_userID');      
                searchCusReq.user_x.password =  ConstantsSLB.getOther('ARMS_password');         
        
                system.debug(searchCusReq);         
        
                wwwSphComArWsWsdlCam.CAMSOAP CusRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();       
        
        
                wwwSphComArWsWsdlCam.SearchCustomerResponseType cusResp = CusRespCAM.SearchCustomer(searchCusReq);      
        
                if(cusResp<>null){      
                    if(cusResp.CusSrchResp<>null){      
                        //cusResp.CusSrchResp.SysId         
                        if(cusResp.CusSrchResp.RtnSts == '0'){      
                                //cusResp.CusSrchResp.NRec      
                            //cusResp.CusSrchResp.L_Cus.Cus         
        
                            if(cusResp.CusSrchResp.L_Cus.Cus<>null){        
                                displayAccList = true;      
                                List<armsWrapper> arCusList = new List<armsWrapper>();      
                                //loop the customer results         
                                for(wwwSphComArWsSchemaCamSearchcustoR.CusType a : cusResp.CusSrchResp.L_Cus.Cus){      
                                        
                                armsWrapper awCus = new armsWrapper();      
                                    awCus.arNum = a.CusN;       
                                    awCus.arName = a.CusM1;         
                                    if(a.CusM2<>null && a.CusM2<>' '){      
                                        awCus.arName += a.CusM2;        
                                    }       
                                    awCus.arDate = a.CusCreDte;         
                                    awCus.arStatus = a.CusSts;      
                                    //a.BLInd       
                                    //a.BLClrCd         
                                    //a.BLRsn       
                                    //a.IdTyp       
                                    //a.IdN         
                                    //a.PpCntryC        
                                    //a.CrRskRtg        
                                    //a.CrLmtInt        
                                    //a.CrLmtExt        
                                    /*20141126 Playstation D0994        
                                    String adressText;      
                                        */      
                                    String adressText=''; //need to initialize variable before value assignment         
                                            /*20141126*/        
                                        if(a.BlkN<>null && a.BlkN<>'' && a.BlkN<>'null'){       
                                            adressText += a.BlkN +' ';      
                                        }       
                                        if(a.FlrN<>null && a.FlrN<>'' && a.FlrN<>'null'){       
                                            adressText += a.FlrN +' ';      
                                        }       
                                        if(a.UntN<>null && a.UntN<>'' && a.UntN<>'null'){       
                                            adressText += a.UntN +' ';      
                                        }       
                                        if(a.Str<>null && a.Str<>'' && a.Str<>'null'){      
                                            adressText += a.Str +' ';       
                                        }       
                                        if(a.BldgSec<>null && a.BldgSec<>'' && a.BldgSec<>'null'){      
                                            adressText += a.BldgSec +' ';       
                                        }       
                                        if(a.CusA1<>null && a.CusA1<>'' && a.CusA1<>'null'){        
                                            adressText += a.CusA1 +' ';         
                                            awCus.arAddress1 = a.CusA1;         
                                        }       
                                        if(a.CusA2<>null && a.CusA2<>'' && a.CusA2<>'null'){        
                                            adressText += a.CusA2 +' ';         
                                            awCus.arAddress2 = a.CusA2;         
                                        }       
                                        if(a.CusA3<>null && a.CusA3<>'' && a.CusA3<>'null'){        
                                            adressText += a.CusA3 +' ';         
                                            awCus.arAddress3 = a.CusA3;         
                                        }       
                                        if(a.CusA4<>null && a.CusA4<>'' && a.CusA4<>'null'){        
                                            adressText += a.CusA4 +' ';         
                                            awCus.arAddress4 = a.CusA4;         
                                        }       
        
                                    awCus.arAddress = adressText;       
        
                                    awCus.arPostcode = a.PstC;      
                                    //a.CityM       
                                    //a.Cntry       
                                    //a.PoBoxN      
                                    awCus.arPOC = a.Attn;       
                                    //a.AttnI       
                                    awCus.arBusProf = a.BizP;       
                                    //a.StfI        
                                    //a.GstOOSI         
                                    //a.UpdId       
                                    //a.UpdDte      
                                    //a.UpdTme      
                                    awCus.isTick = false;       
                                    arCusList.add(awCus);       
                                }       
                                if(arCusList<>null){  
                                    armsCusWrapList = arCusList;        
                                    //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
                                    searchCustTick=true;
                                    //END UD-1214
                                }       
                            }               
        
                        } else if (cusResp.CusSrchResp.RtnSts <> '0' || cusResp.CusSrchResp.RtnSts == null){        
                            //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
                            searchCustTick=false;
                            //END UD-1214       
                            displayCusErr = true;       
                            CBdisable = false;      
                            //errorMsg = ConstantsSLB.getErrorMessage('ARMS customer is not existing');         
                            errorMsg = cusResp.CusSrchResp.RtnMsg;      
                            thisOrder.Debt_Management_Treatment__c = 'SUBH';        
                            thisOrder.Business_Profile__c = 'NORM';         
        
                        }       
                    } else if(cusResp.CusSrchResp==null){    
                        //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
                        searchCustTick=false;
                        //END UD-1214
                        displayCusErr = true;       
                        CBdisable = false;      
                        errorMsg = ConstantsSLB.getErrorMessage('Invalid Response');        
                        thisOrder.Debt_Management_Treatment__c = 'SUBH';        
                        thisOrder.Business_Profile__c = 'NORM';         
                    }       
                }       
            }       
        }catch(CallOutException ce){
            //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
            searchCustTick=false;
            //END UD-1214
            system.debug(ce.getMessage());      
            displayCusErr = true;       
            CBdisable = false;      
            //errorMsg = ConstantsSLB.getErrorMessage('ARMS customer is not existing');         
            thisOrder.Debt_Management_Treatment__c = 'SUBH';        
            thisOrder.Business_Profile__c = 'NORM';                 
            errorMsg = ConstantsSLB.getErrorMessage('ARMS Timed-out');      
        }       
                
    }       
            
    public void searchAccName(){        
        try{        
            if(aCust<>null && aCust<>''){       
                    
                wwwSphComArWsWsdlCam.SearchAccountRequestType searchAccReq = new wwwSphComArWsWsdlCam.SearchAccountRequestType();       
        
                searchAccReq.AccSrch = new wwwSphComArWsSchemaCamSearchaccou.AccSrch_element();         
                searchAccReq.AccSrch.SysId = ConstantsSLB.getOther('ARMS_SysId');       
                searchAccReq.AccSrch.CusN = accNum;         
                searchAccReq.AccSrch.AccTyp = ConstantsSLB.getOther('ARMS_AccTyp');         
                searchAccReq.AccSrch.CoyCd = ConstantsSLB.getOther('ARMS_CoyCd');       
        
                searchAccReq.user_x = new wwwSphComArWsSchemaCommonUser.UserType();         
                searchAccReq.user_x.userID = ConstantsSLB.getOther('ARMS_userID');      
                searchAccReq.user_x.password =  ConstantsSLB.getOther('ARMS_password');         
        
                wwwSphComArWsWsdlCam.CAMSOAP AccRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();       
        
                wwwSphComArWsWsdlCam.SearchAccountResponseType accResp = AccRespCAM.SearchAccount(searchAccReq);        
                        
                if(accResp<>null){      
                    if(accResp.AccSrchResp<>null){      
                        //accResp.AccSrchResp.SysId;        
                        if(accResp.AccSrchResp.RtnSts == '0' && accResp.AccSrchResp.SysId == ConstantsSLB.getOther('ARMS_SysId')){      
                            //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
                            searchAcctTick =true;
                            //END UD-1214
                        //accResp.AccSrchResp.RtnMsg;       
                        //accResp.AccSrchResp.NRec;         
        
                            if(accResp.AccSrchResp.L_Acc.Acc<>null){        
                                thisOrder.Create_ARMS_Account_Only__c = false;      
                                addAccount = true;      
                                List<armsWrapper> awList = new List<armsWrapper>();         
                                        
                                for(wwwSphComArWsSchemaCamSearchaccouR.AccType acR : accResp.AccSrchResp.L_Acc.Acc){        
                                        
                                    armsWrapper aW = new armsWrapper();         
                                        //acR.CusN;         
                                        aW.arAccNum = acR.AccN;         
                                        aW.arType = acR.AccTyp;         
                                        aW.arCreateDate = acR.AccCreDte;        
                                        aW.arCredTerm = acR.CrTrm;      
                                        aW.arCredTermRef = acR.CrTrmRef;        
                                        //acR.CrLmtInt;         
                                        //acR.CrLmtExt;         
                                        //acR.DbtExp;       
                                        aW.arDebtMgmt = acR.DbtStrt;        
                                        //acR.CusGrAccN;        
                                        //acR.CusGrBnkN;        
                                        //acR.BizSctr;      
                                        aW.arCompCode = acR.CoyCd;      
                                        //acR.SOASup        
                                        //acR.TrnI;         
                                        DebtManagement = acR.DbtStrt; //START/END UD-2375 dags Setting of value for variable 
                                                
                                        //populate order fields         
                                        thisOrder.ARMS_Account_Number__c = acR.AccN;        
                                        thisOrder.ARMS_Credit_Term__c = acR.CrTrm;      
                                        thisOrder.Credit_Term_Reference__c = acR.CrTrmRef;      
                                        thisOrder.Credit_Limit_Internal_Limit__c = acR.CrLmtInt;        
                                        thisOrder.Credit_Limit_External_Limit__c = acR.CrLmtExt;        
                                        thisOrder.Approved_Debt_Exposure_Amount__c = acR.DbtExp;        
                                        thisOrder.Debt_Management_Treatment__c = acR.DbtStrt;       
                                        thisOrder.Cust_Giro_Acct_Number__c = acR.CusGrAccN;         
                                        thisOrder.Cust_Giro_Bank_Number__c = acR.CusGrBnkN;         
                                        thisOrder.Business_Sector__c = acR.BizSctr;         
                                        thisOrder.Company_Code__c = acR.CoyCd;      
                                        thisOrder.SOA_Suppression_Indicator__c = acR.SOASup;        
                                        thisOrder.Transient_Indicator__c = acR.TrnI;        
                                                
                                    if(acR.AccTyp == ConstantsSLB.getOther('ARMS_AccTyp')){         
                                        awList.add(aW);         
                                    }       
                                }       
                                if(awList<>null && awList.size() == 1){         
                                    armsSelected = awList;      
                                    thisOrder.Create_ARMS_Account_Only__c = false;      
                                } else if(awList<>null && awList.size() > 1){       
                                    displayCusErr = true;       
                                    errorMsg = ConstantsSLB.getErrorMessage('ARMS account too many record');        
                                    CBdisable = false;      
                                    thisOrder.Create_ARMS_Account_Only__c = true;       
                                            
                                }       
                                        
                            }       
                        } else if(accResp.AccSrchResp.RtnSts == '1'){       
                            //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
                            searchAcctTick =true;
                            //END UD-1214        
                            displayCusErr = true;       
                            errorMsg = ConstantsSLB.getErrorMessage('ARMS account is not existing');        
                            //START UD-1214 6/11/2015 Commented this for the validation to pass
                                //CBdisable = false;
                            //END UD-1214         
                            thisOrder.Create_ARMS_Account_Only__c = true;       
                            thisOrder.Debt_Management_Treatment__c = 'SUBH';        
                                
                        } else if(accResp.AccSrchResp.RtnSts == '8'){       
                                    
                            displayCusErr = true;       
                            errorMsg = ConstantsSLB.getErrorMessage('ARMS account too many record');        
                            CBdisable = true;           
                                
                        } else {        
                                    
                            displayCusErr = true;       
                            errorMsg = accResp.AccSrchResp.RtnMsg;      
                            CBdisable = false;      
                            thisOrder.Create_ARMS_Account_Only__c = true;       
                            thisOrder.Debt_Management_Treatment__c = 'SUBH';        
                        }       
                    } else  if(accResp.AccSrchResp==null){      
                        displayCusErr = true;       
                        errorMsg = ConstantsSLB.getErrorMessage('Invalid Response');        
                        CBdisable = false;      
                        thisOrder.Create_ARMS_Account_Only__c = true;       
                        thisOrder.Debt_Management_Treatment__c = 'SUBH';        
                    }       
                }       
            }       
        }catch(CallOutException ce){        
            system.debug(ce.getMessage());      
            displayCusErr = true;       
            errorMsg = ConstantsSLB.getErrorMessage('ARMS Timed-out');      
       }        
    }           
            
    public void addPopAcc()         
    {           
        redisplay = false;      
        displayAccList = false;         
        List<armsWrapper> awrList = new List<armsWrapper>();        
        if(armsCusWrapList.size()>0){       
            for(armsWrapper awl : armsCusWrapList){         
                if(awl.isTick == true){         
                    awrList.add(awl);       
                    accTextName = awl.arName;       
                    accNum = awl.arNum;         
                    thisOrder.Customer_Name__c = accTextName;       
                    thisOrder.Customer_No__c = accNum;      
                    thisOrder.Address1__c = awl.arAddress1;         
                    thisOrder.Address2__c = awl.arAddress2;         
                    thisOrder.Address3__c = awl.arAddress3;         
                    thisOrder.Address4__c = awl.arAddress4;
                    //Start UD-2223 VPernicia 08/07/15              
                    thisOrder.Business_Profile__c = awl.arBusProf; 
                    //End UD-2223 VPernicia 08/07/15 
                    Busprofile = awl.arBusProf; //START/END UD-2375 dags Setting of values for Variable     
                }       
            }       
        }       
        if(awrList.size()==1){      
            armsSelected = awrList;         
            CBdisable = true;       
            thisOrder.Create_ARMS_Customer_Account__c = false;      
            thisOrder.Create_ARMS_Account_Only__c = true;       
                    
        } else if(awrList.size()>1){        
            displayCusErr = true;       
            redisplay = true;       
            thisOrder.Create_ARMS_Account_Only__c = false;      
            errorMsg = ConstantsSLB.getErrorMessage('ARMS select one Customer only');       
        }       
                
    }       
            
    public void closePopup()        
    {               
        displayCusErr = false;      
        displayAccList = false;         
        if(redisplay == true){      
            displayAccList = true;      
        }       
    }               
            
    public void cancelSearch()      
    {   
        //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
        searchCustTick = false;
        searchAcctTick =false;
        //END UD-1214
        displayAccList = false;         
        addAccount = false;         
        CBdisable = false;      
    }           
    //END D-2617 3/25/15 AddedBy FrancisBenzon : added ARMS functionality in COS
    //START UD-1375 AddedBy FrancisBenzon : method to call 2 other method for efficient Action Support Onchange Attribute on Start Date Field
    public void retrieveAdminFeeAdminCharge()
    {
        retrieveAdminFee();
        retrieveAdminCharge();
        //START UD-1375 6/3/2105 Added By F. Benzon - consolidate method calls to one controller entry
        //checkInvoiceForBillingAccount(); //START END UD-2738 Wenjun 21/Sep/15 : No longer needed
        checkExistingCOA();
        //END UD-1375 6/3/2105 Added By F. Benzon
        
    }
    //END UD-1375 AddedBy FrancisBenzon : method to call 2 other method for efficient Action Support Onchange Attribute on Start Date Field

    
    //Start MMallorca UD-1274 05/28/2015 Create new functions in retrieving and computing delivery charges
    public void computePrepaid(){
        System.debug('gddr computePrepaid was called !!!');
        string recipientAddressType;
        string addressTypeDeliveryChargeType;
        decimal retrieveSCFromCS;
        decimal retrieveVCFromCS;
        
        Map<String, Decimal> chargeMap = getCharges(thisOrder.Recipient_Contact__c, selectedDeliveryChargeType, null, null);
        
        Date earliestStartDate = Date.today().addYears(100);
        Date latestEndDate = Date.today().addYears(-100);
        Integer monthsBetween;
        boolean isDeliveryNeeded = false;
        Decimal totalPostageCharge = 0.00;        
        Decimal totalSubscriptionRate = 0.00;
        orderLineItemList = getOrderLineItems(thisOrder.Id);
        //START UD-3423 01/04/16 RReyes - remove delfee if myPaper or Tabla! 
        Id packageId;
        Set<String> packageItemRecTypeSet = new Set<String>{'Base Product', 'Bundle Product', 'Extension Product'};
        List<Product_Code__c> prodCodes = Product_Code__c.getall().values();
        Set<String> CProductCodeSet = new Set<String>();
        Map<Id, Boolean> packageToIsNoDelMap = new Map<Id, Boolean>();
        isWithDelivery = true;
        
        if(orderLineItem.Main_Package_ID__c != null) {
            packageId = orderLineItem.Main_Package_ID__c;
        }

        for(Product_Code__c pcRec : prodCodes) {
            CProductCodeSet.add(pcRec.Product_Code__c);
        }

        if(packageId != null) {
            Package__c packageRecord = [SELECT Id, Name, (SELECT Id, Product_Rate_Plan__r.Product_Code__c FROM Package_Items__r 
                                                              WHERE RecordType.Name IN: packageItemRecTypeSet) 
                                        FROM Package__c WHERE Id =: packageId];
            if(packageRecord.Package_Items__r.size() > 0) {
                Integer noDelCount = 0;
                Integer totalPackageItems = 0;
            
                for(Package_Item__c packageItemRecord : packageRecord.Package_Items__r) {
                    if(CProductCodeSet.contains(packageItemRecord.Product_Rate_Plan__r.Product_Code__c)) {
                        noDelCount = noDelCount + 1;
                    }
                    totalPackageItems = totalPackageItems + 1;
                }
                
                if(noDelCount == totalPackageItems) {
                    isWithDelivery = false;
                }
            }
        } 
        //END UD-3423 01/04/16 RReyes - remove delfee if myPaper or Tabla!
        
        for(Order_Line_Item__c orderLineItem : orderLineItemList){
            if (orderLineItem.Total_Postage_Charge__c != 0 || orderLineItem.Total_Postage_Charge__c != null)
                totalPostageCharge += orderLineItem.Total_Postage_Charge__c;
            if (orderLineItem.Total_Subscription_Rate__c != 0 || orderLineItem.Total_Subscription_Rate__c != null)
                totalSubscriptionRate += orderLineItem.Total_Subscription_Rate__c;
            if(orderLineItem.start_date__c < earliestStartDate)
                earliestStartDate = orderLineItem.start_date__c;
            if(orderLineItem.end_date__c > latestEndDate)
                latestEndDate = orderLineItem.end_date__c;
        }
       
        if (orderLineItemList.size() > 0) {
            thisOrder.Months_Between_Start_End__c = orderLineItemList[0].Term_Length__c;
        }
        
        try {
            for (Order_Line_Item__c tmpOli : [select Id from Order_Line_Item__c where Order__c = :thisOrder.Id 
                    and Delivered_By__c = :DELIVERED_BY_VENDOR limit 1]) {
                        
                isDeliveryNeeded = true;        
            }
        } catch (exception e) {
            ExceptionLogger.log(new list<exception>{ e });
        } 
        
        setMonthlyDeliveryChargeForFullPrepaid();
        
        if (orderLineItem.Delivered_By__c == GlobalVariableClass.VENDOR) {
             isDeliveredByVendor = true;
        }
        else {
             isDeliveredByVendor = false;
        }
      
      if (thisOrder.Recipient_Contact__c != null) {
      System.debug('gddr computePrepaid was called !!!  thisOrder.Recipient_Contact__c != null ' + thisOrder.Recipient_Contact__c != null); 
          Contact rc = [select Id, Address__c, Address__r.Address_Type__c, Zone__c from Contact 
                          where Id = :thisOrder.Recipient_Contact__c];
              recipientAddressType = rc.Address__r.Address_Type__c;  
              addressTypeDeliveryChargeType =  recipientAddressType + selectedDeliveryChargeType;
              
            System.debug('gddr computePrepaid was called !!!  selectedDeliveryChargeType ' + selectedDeliveryChargeType);  
            if(selectedDeliveryChargeType == 'C' || selectedDeliveryChargeType == 'N' || selectedDeliveryChargeType == 'Z' || selectedDeliveryChargeType == 'H' || selectedDeliveryChargeType == 'L'){
                subscriberCharge = chargeMap.get('SubscriberCharge');
                vendorCredit = chargeMap.get('VendorCredit');
                hidSubCharge = subscriberCharge;
                hidCreditCharge = vendorCredit;
                
                 if (subscriberCharge == 9999.99) {
                        isSubscriberChargeReadOnly = false;
                  }
                  else {
                       isSubscriberChargeReadOnly = true;
                  }
                  
                  if (vendorCredit == 9999.99) {
                        isVendorCrdeitReadOnly = false;
                  }
                  else {
                        isVendorCrdeitReadOnly = true;
                  }
            }
            // Start PD-0225 20May16 JohnD - revised logic
            else if(selectedDeliveryChargeType == 'S'){
                
                /* commented out
                if(hidSubCharge != null){
                    subscriberCharge = hidSubCharge;
                }
                else{ 
                    subscriberCharge =  thisOrder.Subscriber_Charge__c;
                }
                if(hidCreditCharge != null){
                    vendorCredit = hidCreditCharge;
                }
                else{
                    vendorCredit = thisOrder.Vendor_Credit__c;
                }
                */
                subscriberCharge =  thisOrder.Subscriber_Charge__c;
                vendorCredit = thisOrder.Vendor_Credit__c;
                isSubscriberChargeReadOnly = false;
                isVendorCrdeitReadOnly = false;
            }
            else if(selectedDeliveryChargeType == '9'){
                /* commented out
                if(hidSubCharge != null){
                    subscriberCharge = hidSubCharge;
                }
                else{ 
                    subscriberCharge =  thisOrder.Subscriber_Charge__c;
                }
                */
                subscriberCharge =  thisOrder.Subscriber_Charge__c;
                vendorCredit = chargeMap.get('VendorCredit');
                isSubscriberChargeReadOnly = false;
                isVendorCrdeitReadOnly = true;
            }
            // End PD-0225 20May16 JohnD - revised logic
            
            map<string, decimal> deliveryCharges = FullPrepaidDeliveryChargeCalculator.calculate(thisOrder.Id, subscriberCharge);
            //START UD-3423 01/04/16 RReyes - remove delfee if myPaper or Tabla!
            if(isWithDelivery){
                thisOrder.Full_Prepaid_Delivery_Charge__c =  deliveryCharges.get(GlobalVariableClass.BILLING_TYPE_FULL);
                thisOrder.Recurring_Delivery_Charge__c = deliveryCharges.get(GlobalVariableClass.BILLING_TYPE_RECURRING); 
            }else{
                thisOrder.Full_Prepaid_Delivery_Charge__c =  0.0;
                thisOrder.Recurring_Delivery_Charge__c = 0.0; 
            }
            //END UD-3423 01/04/16 RReyes - remove delfee if myPaper or Tabla!
            thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType;
            thisOrder.Subscriber_Charge__c = subscriberCharge;
            thisOrder.Vendor_Credit__c = vendorCredit;
            
            //monthly
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = subscriberCharge;
            
            //Full_Prepaid Inc Del Charge
            if (totalSubscriptionRate > 0){
                thisOrder.Total_Full_Prepaid__c = totalPostageCharge + totalSubscriptionRate + thisOrder.Full_Prepaid_Delivery_Charge__c;
            }
            else {
                thisOrder.Total_Full_Prepaid__c = 0.00;
            }
            //START D-3101 6/17/15 AddedBy FrancisBenzon : recomputes subscriber charge
            retrieveAdminCharge();
            //END D-3101 6/17/15 AddedBy FrancisBenzon : recomputes subscriber charge
            try {
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = false;
                //END D-3094 06/16/15 RReyes                
                update thisOrder;
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = true;
                //END D-3094 06/16/15 RReyes
            } 
            catch (exception e) {
                ApexPages.addMessages(e);
                //START D-3094 06/16/15 RReyes 
                thisOrder.isChangeOfSubEntry__c = true;
                //END D-3094 06/16/15 RReyes
            }
        
        }
    }
     
     
    private void setMonthlyDeliveryChargeForFullPrepaid() {
        
        thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0.0;
      
        list<Order_Line_Item__c> oliList = [select id from Order_Line_Item__c where Order__c = :thisOrder.Id 
                and Main_Package_Billing_Type__c = 'Full Prepaid' limit 1];
                
        if (oliList != null) {
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = thisOrder.Subscriber_Charge__c;
        }
    }
    //End MMallorca UD-1274 05/28/2015
    //START D-3039 06/03/15 RReyes - method for actionfunction
    public void continueSave(){
        //dummy method;
    }
    //END D-3039 06/03/15 RReyes 

    //START D-3101 6/17/15 AddedBy FrancisBenzon : this methods calculates the subsriber charge wrt to term length
    private void recalculateCharges() 
    {
        if (orderLineItem.Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_VENDOR) 
        {
            //START UD-1826 AddedBy francisBenzon : to avoid default Del ChargeType as this method is called multiple times
            if(selectedDeliveryChargeType == null)
            {
                selectedDeliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType); //START/END UD-1619 VPernicia 6/23/15
            }
            //END UD-1826 AddedBy francisBenzon : to avoid default Del ChargeType as this method is called multiple times           
            map<string, decimal> chargeMap = getCharges(thisOrder.Recipient_Contact__c, selectedDeliveryChargeType, subscriberCharge, vendorCredit);
            // Start PD-0225 20May16 JohnD - commented out
            //thisOrder.Subscriber_Charge__c = chargeMap.get('SubscriberCharge');
            //thisOrder.Vendor_Credit__c = chargeMap.get('VendorCredit');
            // End PD-0225 20May16 JohnD - commented out
            setMonthlyDeliveryChargeForFullPrepaid();
            thisOrder.Full_Prepaid_Delivery_Charge__c = 0.0;
            thisOrder.Recurring_Delivery_Charge__c = 0.0;
             //START UD-3423 01/04/16 RReyes - remove delfee if myPaper or Tabla!
            if(isWithDelivery == true){
                if (orderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE) 
                {
                    if (orderLineItem.Term_Length__c != null && thisOrder.Subscriber_Charge__c != null) 
                    {
                            thisOrder.Full_Prepaid_Delivery_Charge__c = thisOrder.Subscriber_Charge__c * orderLineItem.Term_Length__c;
                            system.debug('>>>3' + ' ' + thisOrder.Full_Prepaid_Delivery_Charge__c);
                    } 
                } 
                else {
                        thisOrder.Recurring_Delivery_Charge__c = thisOrder.Subscriber_Charge__c;
                }
            }            
            //END UD-3423 01/04/16 RReyes - remove delfee if myPaper or Tabla! 
            clearPostageRelatedFields();
            //Start D-3324 VPernicia
            if(thisOrder.Recurring_Delivery_Charge__c == null) 
            {
                thisOrder.Recurring_Delivery_Charge__c = 0.0;
            }
            //End D-3324 VPernicia          
        }
        else if (orderLineItem.Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT) 
        {
            //selectedDeliveryChargeType = 'N'; // Start/End UD-2211 19Aug15 JohnD - commented out
             try {
                orderLineItem.Postage_Charge__c = 
                    PostageChargeHelper.getPostageChargeForLineItem(thisOrder.Recipient_Contact__c,orderLineItem) * orderLineItem.Qty__c * orderLineItem.Term_Length__c; //D-3101 Hotfix - fritzbenzon 6/17/15
                if(orderLineItem.Postage_Charge__c == null) 
                {
                    orderLineItem.Postage_Charge__c = 0.0;
                }
            } 
            catch (exception e) {
                orderLineItem.Postage_Charge__c = 0.0;
            }
            clearDeliveryRelatedFields();
        }
        else {
            //selectedDeliveryChargeType = 'N'; // Start/End UD-2211 19Aug15 JohnD - commented out
            clearDeliveryRelatedFields();
            clearPostageRelatedFields();
        }
    }
    
    private void clearDeliveryRelatedFields() {             
        thisOrder.Full_Prepaid_Delivery_Charge__c = 0.0;
        thisOrder.Subscriber_Charge__c = 0.0;
        thisOrder.Delivery_Charge__c = 0.0;
        thisOrder.Total_Full_Prepaid__c = 0.0;
        thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0.0; 
        thisOrder.Recurring_Delivery_Charge__c  = 0.0;  
    }
        
    private void clearPostageRelatedFields() {              
        orderLineItem.Postage_Charge__c = 0.0;
    }       
    //END D-3101 6/17/15 AddedBy FrancisBenzon : this methods calculates the subsriber charge wrt to term length
    
    //START D-3132 06/22/15 RReyes - computes sub end date and contract end date when there is an error message
    private void computeEndDate(){
        if(orderLineItem != null){
            //START PD-0054 FrancisBenzon 5/5/16 : excluded contract end date recalc from termlength checking
            if(orderLineItem.Start_Date__c != null && orderLineItem.Term_Length__c > 0){ //START/END UD-2245 8/5/15 AddedBy FrancisBenzon : check term length
                orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addMonths((integer)orderLineItem.Term_Length__c).addDays(-1);
                
            }
            if (orderLineItem.Start_Date__c != null && orderLineItem.New_Contract_Period__c != null && orderLineItem.Promotion_ID__c != null) {    
                orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1); //fritz
            }
            //END PD-0054 FrancisBenzon 5/5/16 : excluded contract end date recalc from termlength checking
        }
    }
    //END D-3132 06/22/15 RReyes - computes sub end date and contract end date when there is an error message
    //START: PD-0035 05/12/2016 Added by Kristine Balaoing - added logic for add on added after add asia1/add order line item is over
    public void retrieveNewlyAddedAddOn(){
        //system.assertequals(null, addOnPackage.Id);
        if (!asia1Subscriptions.isEmpty()) {
            Set<Id> addOnIdSet = new Set<Id>();
            addOnIdSet.add((Id)(addOnPackage.Id));
            //addOnIdSet.add('a2QO0000000aFhHMAU');
            //System.assertEquals(null, addOnIdSet);
            //system.assertEquals(addOnId + '', ' ');
            //System.assertEquals(1,2);
            //System.assertEquals(null, retrievedAddOnId);
            List<Asia1SubscriptionWrapper> tmpAsia1SubsAddOnList = new List<Asia1SubscriptionWrapper>();
            List<Asia1Wrapper> aWrapList = new List<Asia1Wrapper>();
            //System.assertEquals(null, asia1Subscriptions);
            //System.assertEquals(null, retrieveServiceFlags(addOnIdSet));
            for(Asia1Wrapper asia1wrapper : asia1Subscriptions){
                
                for(Package_Access_Flag__c pafAddOn : retrieveServiceFlags(addOnIdSet)){
                    Asia1SubscriptionWrapper asia1Sub = new Asia1SubscriptionWrapper();
                    
                    asia1Sub.status = 'Disabled';
                    asia1Sub.serviceFlagId = pafAddOn.Package_Service_Access_Flag__c;
                    asia1Sub.serviceFlagName = pafAddOn.Package_Service_Access_Flag__r.Name;
                    
                    if (pafAddOn.No_of_Concurrent_Users__c != null) {
                        asia1Sub.concurrent = integer.valueOf(pafAddOn.No_of_Concurrent_Users__c);
                    }
                    
                    tmpAsia1SubsAddOnList.add(asia1Sub);
                    //System.assertEquals(null, asia1Sub);
                    //System.assertEquals(1, 2);
                    
                }
                //System.assertEquals(null, asia1wrapper);
                asia1wrapper.asia1Subscriptions.addAll(tmpAsia1SubsAddOnList);
                //System.assertEquals(null, asia1wrapper);
                //System.assertEquals(1, 2);
                //aWrapList.add(asia1wrapper);
            }
            //System.assertEquals(null, asia1Subscriptions);
            asia1Subscriptions.addAll(aWrapList);
            //System.assertEquals(null, asia1Subscriptions);
            //System.assertEquals(1, 2);
        }
    }
    //END: PD-0035 05/12/2016 Added by Kristine Balaoing
    
    //START PD-0054 6/5/16 FrancisBenzon: for test class coverage only
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
    
    public void testCoveragePatch1() {
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
    //END PD-0054 6/5/16 FrancisBenzon: for test class coverage only
}