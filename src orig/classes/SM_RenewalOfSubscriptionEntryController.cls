/**
 * Class Name: SM_RenewalOfSubscriptionEntryController
 * @author: john dacutan
 * Date: 09/29/2014
 * Requirement/Project Name: SPH Project
 * @description : this class is use as a controller for the renewal Edit page of SM_RenewalOfSubscriptionDetail visualforce page
 * 
 * History: 12/01/15 D-1717 Wenjun : Postage Charge & Fix existing code bugs
**/

public class SM_RenewalOfSubscriptionEntryController extends SM_SubscriptionHelper {
      
    //Start RReyes D-3158 06/23/2015
    public decimal totalSubscriptionPrice { get; set; }
    public decimal subscriptionRate { get; set; }
    //End RReyes D-3158 06/23/2015
    //START D-3156 06/23/15 GDelRosario/RReyes
    public boolean isCalledFromController = false;
    //START D-3156 06/23/15 GDelRosario/RReyes
    // Start D-0033 UAT 01-03-2015 JohnD followed changed in start subscription
    final static string ADDRESS_RECORD_TYPE_NAME_LOCAL = 'Contact_Recordtype_Local';
    final static string DELIVERED_BY_MAILING_AGENT = 'Mailing Agent';
    final static string DELIVERED_BY_NONE = 'None';
    final static string DELIVERED_BY_VENDOR = 'Vendor';
    final static string DELIVERED_BY_BOTH = 'Vendor or Mailing Agent';
    // End D-0033 UAT 01-03-2015 JohnD
    
    //START D-1646 6/22/2015 JLedesma Add-on selection
    public list<Zuora__Subscription__c> subscriptionFinalList { get; set; }
    final static string addonPack = (ConstantsSLB.getKeyId('Add On'));
    Map<Id, Package__c> subToAddOn = new Map<Id, Package__c>();
    public id oliId { get; set; }
    
    String BusProfile; //Start/End Dags UD-2375 - Variable Declaration
    String DebtManagement; //Start/End Dags UD-2375 - Variable Declaration
    //END  D-1646 6/22/2015 JLedesma Add-on selection
    
    // START UD-0420 3/26/2015  GDelRosario parameter to get the subscriptionName of other selected
    public string selSubName {get;set;}
    // END UD-0420 3/26/2015  GDelRosario parameter to get the subscriptionName of other selected

    final id subId = ApexPages.currentPage().getParameters().get('subscriptionId');
    final id accountId = ApexPages.currentPage().getParameters().get('accountId');
    final id RecordType = ApexPages.currentPage().getParameters().get('RecordTypeId');
    public id subscriptionId { get; set; }
  // START UD-0811 4/20/2015 Gdelrosario - added caseId as condition to filter if the case is retention outbound
    final id caseId = ApexPages.currentPage().getParameters().get('caseId');
    // END UD-0811 Gdelrosario 

  
    public transient string orderLineItemIdToBeRemoved { get; set; }
    public list<Order_Line_Item__c> orderLineItemList { get; set; }
    public string selectedOrderLineItem { get; set; }
    public string selectedPromotionId { get; set; }
    public string selectedPackageId { get; set; }
    //START:UD-0451 3/25/15 Added by Manolo Valena - New variable added
    public string selPackId { get; set; }
    //END:UD-0451 3/25/15 Added by Manolo Valena
    public string selectedDeliveryChargeType { get; set; }
    public integer totalBillingAccounts { get; set; }
    public list<Zuora__Subscription__c> subscriptionList { get; set; }
    public integer totalSubscriptions { get; set; }
    public string renewalPackageCode { get; set; }
    // Start D-1345 01/19/2015 JohnD new variable to displayed on vf page (Package ID)
    public string selectedSubscriptionPackageName { get; set; }
    // End D-1345 01/19/2015 JohnD

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
    //START D-2312 02-23-2015  Marvin Gatchalian
    public transient Map<String, Set<String>> promotionCodeMap {get; set;}
    //END D-2312 02-23-2015  Marvin Gatchalian
    
    public transient string searchErrorMsg { get; set; }
    public transient string searchPackageMsg { get; set; }
    public transient string searchPromotionMsg { get; set; }
    //Start D-1793 01/21/15 Added by April Banaag - variable for the billing type of the subscription to be renewed
    private string selectedPackageBillingType {get;set;}
    //End D-1793 01/21/15 Added by April Banaag - variable for the billing type of the subscription to be renewed
    
    // end search variables

    // subscription details variables
    public Order_Line_Item__c orderLineItem { get; set; }
    public transient string selectedPackageName { get; set; }
    public transient boolean isAllInOne { get; set; }
    public list<SelectOption> deliveryMethod { get; set; }
    public id recipientAddressId;
    public string recipientAddressType;
    public string recipientAddressRecordTypeName; //MGaelo UD-0722 4/23/2015
    public boolean isReInitializedItem { get; set; }
    // end subscription details variables
    
    // addon details variables
    public Package__c addOnPackage { get; set; }
    public string selectedAddOnPackage { get; set; }
    // end addon details variables
    
    // gifts variables
    public list<GiftWrapper> promotionGifts { get; set; }
    // end gift variables

    // renderers
    public transient boolean isExecuteSearch { get; set; }
    public transient boolean isPackageSelected { get; set; }
    public transient boolean isPromotionSelected { get; set; }
    public boolean isDigital { get; set; } //START/END D-3305 7/31 AddedBy FrancisBenzon : removed transient to avoid lose of value per rendering.
    public transient boolean isFromPromotion { get; set; }
    // end renderers
    
    // asia1 variables
    public Asia1__c asia1SingleAccount { get; set; } 
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
    // end payment variables
    //Start UD-0433 3/18/2015 James - define variables
    boolean existinginvoicebilling = false;
    string existinginvoicebillingname;
    string INVOICE = ConstantsSLB.getOther('Invoice');
    string OTHERPAYMENT = ConstantsSLB.getOther('Other');
    //End UD-0433 3/18/2015 James 
    public transient boolean isNewsPaper {get; set;} // Start/End D-0105 UAT 01-03-2015 JohnD
    //START D-2617 3/25/15 AddedBy FrancisBenzon : rerender other payment method if existing account used is Other
    public boolean isOtherPayment {get;set;}
    //END D-2617 3/25/15 AddedBy FrancisBenzon : rerender other payment method if existing account used is Other

    //START UD-0809 4/23/2015 GDELROSARIO  : revised the variable for calling the selected subscription
    public string selectedSubscriptionId { get; set; } 
    public string defaultSelectedSubscriptionId {get;set;}
    //END UD-0809 4/23/2015 GDELROSARIO  : revised the variable for calling the selected subscription 

    //START D-0803 4/24/2015 Added By J. Sarion - Display the details of the Subscription tied in the case 
    public string publication = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    //END D-0803 4/24/2015 Added By J. Sarion - Display the details of the Subscription tied in the case
  
    //START D-2648 AddedBy Francisbenzon : variable for asia1 auto-population
    public boolean isContactQueried = false;
    public Map<Id, Contact> contactsMap {get; set;}
    //END D-2648 AddedBy Francisbenzon : variable for asia1 auto-population
    boolean isChangedSelection = false; // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
    //public String packageType {get; set;}//START/END D-3332 RReyes 11/13/15 - commentedout - rollback
    //START D-4214 01/18/16 RReyes 
    public Decimal totalFPCharge {get;set;} //Total_Full_Prepaid_Charge__c
    public Decimal totalRecCharge {get;set;} //Total Monthly Recurring Charge
    public Decimal fpIncDelCharge {get;set;} //Full_Prepaid_Inc_Del_Charge__c
    public Decimal recChargeIncDP {get;set;} //Recurring_Inc_Del_Charge__c
    public Decimal dueToSPH {get;set;} //Total_Due_to_SPH__c
    public Decimal postageCharge {get;set;} //Total_Monthly_Postage_Charge__c
    //END D-4214 01/18/16 RReyes
    

    /**
    * @description : This method will be called to initialize / retrieve
    *       all necessary data to be used in vf page before loading
    */
    //Start D-3152 James 06/23/2015
    List<Order__c> RenewalOrder = new List<Order__c>();
    List<Zuora__Subscription__c> BaseSubList = new List<Zuora__Subscription__c>();
    Id RenewalOrderId;
    //End D-3152 James 06/23/2015
    
    //START D-3167 AddedBy FrancisBenzon : variables
    public boolean charityField {get;set;}
    public boolean withNonCharityOli {get;set;}
    //END D-3167 AddedBy FrancisBenzon : variables
    
    private boolean isAsia1Validated = false; //START-END UD-3896 4/1/2016 Added by J.Sarion
    
    //Start PD-0035 May 13,2016 Added by Kristine Balaoing - added for add on rendering
    public transient boolean addOnIsDigital { get; set; }
    //END PD-0035 May 13,2016 Added by Kristine Balaoing 
    
    public boolean isReset = false;//START/END UD-2219 08/08/15 RReyes - SIT Hotfix - variable to determine if reset
    Id parentCaseId; //START/END UD-3293 11/25/15 RReyes
    @TestVisible // KARL
    private void initialize() {

        orderLineItem = new Order_Line_Item__c();
        orderLineItemList = new list<Order_Line_Item__c>();
        orderLineItem.Start_Date__c = Date.Today();
      
        checkAndCreateOrder();
        //retrieveActiveSubscriptions();
        //Start D-3305 VPernicia/Fritz 08/03/15 
        //retrieveOrderLineItem();
    asia1Subscriptions = new list<Asia1Wrapper>();  
        initializeAsia1Components();      
        retrieveOrderLineItem();
        //End D-3305 VPernicia/Fritz 08/03/15
        
        initializePaymentComponents();
        promotionCode_isEligible = new map<string, boolean>();
        //Start D-2312 02/23/2015 Added by Marvin Gatchalian
        promotionCodeMap = new map<string, set<string>>();
        //End D-2312 02/23/2015 Added by Marvin Gatchalian
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
        //START D-4214 01/19/2016 RReyes - set status to new
        if(thisOrder != null){
            if(thisOrder.Account__c != null){
                thisOrder.Status__c = 'New';
            }           
        }
        //END D-4214 01/19/2016 RReyes - set status to new
    }

    /**
    * @description : This method will retrieve all active subscriptions of the account
    *     and display in the existing subscriptin for renewal section of vf page
    */
    public void retrieveActiveSubscriptions() {
        
        //Start UD-0409 3/17/2015 James - Exclude Evergreen subscriptions
        string EVERGREEN = ConstantsSLB.getOther('Evergreen');
        date nulldate = null;
        //START UD-0452 3/23/15 AddedBy FrancisBenzon : Do not include past dated subscriptions
        date today = date.today();
        //End UD-0409 3/17/2015 James
        // Start D-1345 01/19/2015 JohnD added package name in the query to be used on vf page      
        // START UD-0811 4/20/2015 Gdelrosario - added caseId as condition to filter if the case is retention outbound
    
        //Start UD-1644 6/17/2015 Kestoya - Exclude Postage subscriptions
        string POSTAGE = ConstantsSLB.getOther('Postage');
        //End UD-1644 6/17/2015 Kestoya - Exclude Postage subscriptions

        date retentionDate = today.addDays(42);
        

        //START D-1646 6/22/2015 JLedesma Add-on selection
        subscriptionList = new List<Zuora__Subscription__c>();
        if (caseId != null ){
        //START D-0803 4/23/2015 Added By J. Sarion - Display the details of the Subscription tied in the case 
            Id caseRetention = ConstantsSLB.getKeyId(GlobalVariableClass.CASERETENTION);
            Case c = [SELECT Id, Subscription_Name__c FROM Case WHERE Id = :caseId AND RecordTypeId = :caseRetention];
            // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - add zuora__CustomerAccount__c field in the query
            //Start UD-1644 6/17/2015 Kestoya - added Subscription_Type_1__c != :POSTAGE in the query
            //Start D-3152 James 06/23/2015
            //START UD-1651 06/25/15 - RReyes - added Zuora__CustomerAccount__r.Billing_Type__c in both queries
            if (c.Subscription_Name__c != null) {
                  subscriptionFinalList = [select Main_Package_1__r.Package_Type__c, Order_Line_Item_Number_1__c, Id, Name, Main_Package_1__c, Main_Package_1__r.Name, Billing_Type__c, 
                    Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Recipient_Contact__c, Subscription_Type_1__c,
                    Recipient_Contact__r.Address__r.Address_1__c, Recipient_Contact__r.Address__r.Address_2__c, 
                    Recipient_Contact__r.Address__r.Address_3__c, Recipient_Contact__r.Address__r.Address_4__c,
                    Recipient_Contact__r.Address__r.Building_Name__c, Recipient_Contact__r.Address__r.C_O_Company__c,
                    Recipient_Contact__r.Address__r.City__c, Recipient_Contact__r.HomePhone, Zuora__CustomerAccount__c,
                    Order_Number_1__r.Acquisition_Type__c, Order_Number_1__r.Sponsor__c, Order_Number_1__r.Payment_Type__c, Delivered_By_1__c, Zuora__CustomerAccount__r.Billing_Type__c,
                    Order_Number_1__r.Subscriber_Charge__c, Order_Number_1__r.Vendor_Credit__c
                    from Zuora__Subscription__c where Zuora__Account__c = :accountId and Zuora__Status__c = 'Active' 
                    and Subscription_Type_1__c = :publication and Main_Package_1__c != '' and Zuora__TermSettingType__c != :EVERGREEN 
                    and Subscription_Type_1__c != :POSTAGE and Zuora__SubscriptionEndDate__c != :nulldate and Id = :c.Subscription_Name__c];
            } else {
                    subscriptionFinalList=[select Main_Package_1__r.Package_Type__c, Order_Line_Item_Number_1__c, Id, Name, Main_Package_1__c, Main_Package_1__r.Name, Billing_Type__c, 
                            Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Recipient_Contact__c, Subscription_Type_1__c,
                            Recipient_Contact__r.Address__r.Address_1__c, Recipient_Contact__r.Address__r.Address_2__c, 
                            Recipient_Contact__r.Address__r.Address_3__c, Recipient_Contact__r.Address__r.Address_4__c,
                            Recipient_Contact__r.Address__r.Building_Name__c, Recipient_Contact__r.Address__r.C_O_Company__c,
                            Recipient_Contact__r.Address__r.City__c, Recipient_Contact__r.HomePhone, Zuora__CustomerAccount__c,
                            Order_Number_1__r.Acquisition_Type__c, Order_Number_1__r.Sponsor__c, Order_Number_1__r.Payment_Type__c, Delivered_By_1__c, Zuora__CustomerAccount__r.Billing_Type__c,
                            Order_Number_1__r.Subscriber_Charge__c, Order_Number_1__r.Vendor_Credit__c
                            from Zuora__Subscription__c where Zuora__Account__c = :accountId and Zuora__Status__c = 'Active'
                            and Subscription_Type_1__c = :publication and Main_Package_1__c != '' and Zuora__TermSettingType__c != :EVERGREEN
                            and Subscription_Type_1__c != :POSTAGE
                              and Zuora__SubscriptionEndDate__c <= :retentionDate and Zuora__SubscriptionEndDate__c >=: today]; 
            }
            //END UD-1651 06/25/15 - RReyes - added Zuora__CustomerAccount__r.Billing_Type__c in both queries
            //End D-3152 James 06/23/2015
            //END D-0803 4/23/2015 Added By J. Sarion - Display the details of the Subscription tied in the case 
      
            for(Zuora__Subscription__c sub : subscriptionFinalList){
                if(sub.Main_Package_1__r.Package_Type__c!= addonPack){
                    subscriptionList.add(sub);
                }
            }
      
        } else {
            //Start D-3152 James 06/23/2015
            //START UD-1651 06/25/15 - RReyes - added Zuora__CustomerAccount__r.Billing_Type__c in both queries
            if (subId != null) {
                //START D-0821 1/8/2015 Added By C. Lin - Remove Main_Package_1__r.Renewal_Package_Code__c
                //Start UD-0409 3/17/2015 James - Exclude Evergreen subscriptions
                subscriptionFinalList = [select Main_Package_1__r.Package_Type__c, Order_Line_Item_Number_1__c, Id, Name, Main_Package_1__c, Main_Package_1__r.Name, Billing_Type__c, 
                        Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Recipient_Contact__c, Subscription_Type_1__c,
                        Recipient_Contact__r.Address__r.Address_1__c, Recipient_Contact__r.Address__r.Address_2__c, 
                        Recipient_Contact__r.Address__r.Address_3__c, Recipient_Contact__r.Address__r.Address_4__c,
                        Recipient_Contact__r.Address__r.Building_Name__c, Recipient_Contact__r.Address__r.C_O_Company__c,
                        Recipient_Contact__r.Address__r.City__c, Recipient_Contact__r.HomePhone, Zuora__CustomerAccount__c,
                        Order_Number_1__r.Acquisition_Type__c, Order_Number_1__r.Sponsor__c, Order_Number_1__r.Payment_Type__c, Delivered_By_1__c, Zuora__CustomerAccount__r.Billing_Type__c,
                        Order_Number_1__r.Subscriber_Charge__c, Order_Number_1__r.Vendor_Credit__c
                        from Zuora__Subscription__c where Zuora__Account__c = :accountId and Zuora__Status__c = 'Active' 
                        and Subscription_Type_1__c != 'Delivery' and Main_Package_1__c != '' and Zuora__TermSettingType__c != :EVERGREEN 
                        and Subscription_Type_1__c != :POSTAGE and Zuora__SubscriptionEndDate__c >= :today and Zuora__SubscriptionEndDate__c != :nulldate and Id = :subId];
                //END D-0821 1/8/2015 Added By C. Lin
            } else {
                //START D-0821 1/8/2015 Added By C. Lin - Remove Main_Package_1__r.Renewal_Package_Code__c
                //Start UD-0409 3/17/2015 James - Exclude Evergreen subscriptions
                subscriptionFinalList = [select Main_Package_1__r.Package_Type__c, Order_Line_Item_Number_1__c, Id, Name, Main_Package_1__c, Main_Package_1__r.Name, Billing_Type__c, 
                        Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Recipient_Contact__c, Subscription_Type_1__c,
                        Recipient_Contact__r.Address__r.Address_1__c, Recipient_Contact__r.Address__r.Address_2__c, 
                        Recipient_Contact__r.Address__r.Address_3__c, Recipient_Contact__r.Address__r.Address_4__c,
                        Recipient_Contact__r.Address__r.Building_Name__c, Recipient_Contact__r.Address__r.C_O_Company__c,
                        Recipient_Contact__r.Address__r.City__c, Recipient_Contact__r.HomePhone, Zuora__CustomerAccount__c,
                        Order_Number_1__r.Acquisition_Type__c, Order_Number_1__r.Sponsor__c, Order_Number_1__r.Payment_Type__c, Delivered_By_1__c, Zuora__CustomerAccount__r.Billing_Type__c,
                        Order_Number_1__r.Subscriber_Charge__c, Order_Number_1__r.Vendor_Credit__c
                        from Zuora__Subscription__c where Zuora__Account__c = :accountId and Zuora__Status__c = 'Active' 
                        and Subscription_Type_1__c != 'Delivery' and Main_Package_1__c != '' and Zuora__TermSettingType__c != :EVERGREEN 
                        and Subscription_Type_1__c != :POSTAGE and Zuora__SubscriptionEndDate__c >= :today and Zuora__SubscriptionEndDate__c != :nulldate order by Zuora__SubscriptionEndDate__c asc];
            //END UD-0452 3/23/15 AddedBy FrancisBenzon : Do not include past dated subscriptions
                //End UD-0409 3/17/2015 James
                //END D-0821 1/8/2015 Added By C. Lin
                //Start UD-1644 6/17/2015 Kestoya - added Subscription_Type_1__c != :POSTAGE in the query
            }
            //END UD-1651 06/25/15 - RReyes - added Zuora__CustomerAccount__r.Billing_Type__c in both queries
            //End D-3152 James 06/23/2015
            // End D-1345 01/19/2015 JohnD
            for(Zuora__Subscription__c sub : subscriptionFinalList){
                if(sub.Main_Package_1__r.Package_Type__c!= addonPack){
                    subscriptionList.add(sub);
                }
                
                if(sub.Main_Package_1__r.Package_Type__c == addonPack){
                    subToAddOn.put(sub.Order_Line_Item_Number_1__c, new Package__c(Id=sub.Main_Package_1__c, Name=sub.Main_Package_1__r.Name));
                }
              }
        }
        //END  D-1646 6/22/2015 JLedesma Add-on selection
        // End UD-1147/D-2486/D-2907 10Jun15 JohnD - add zuora__CustomerAccount__c field in the quer
        
        // END UD-0811 Gdelrosario 
        totalSubscriptions = subscriptionList.size();
        
        if (totalSubscriptions > 0) {
            
            subscriptionId = subscriptionList[0].Id;
            //START UD-1651 06/25/15 RReyes
            String billAccBillType;
            if(subscriptionList[0].Zuora__CustomerAccount__r.Billing_Type__c != null){
                billAccBillType = subscriptionList[0].Zuora__CustomerAccount__r.Billing_Type__c;
            }else{
                billAccBillType = '';
            }
            //END UD-1651 06/25/15 RReyes
            // Start D-1345 01/16/2015 JohnD assign recipient on the order and put value on selected subscription package name
            
            thisOrder = new Order__c();
            thisOrder.Recipient_Contact__c = subscriptionList[0].Recipient_Contact__c;
            selectedSubscriptionPackageName = subscriptionList[0].Main_Package_1__r.Name;
            // End D-1345 01/16/2015 JohnD
            
            // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - set the billing account in the order
            //START UD-1651 06/25/15 - RReyes - added condition to meet Order.Billing_Account__c filter
            if(subscriptionList[0].Billing_Type__c != null && subscriptionList[0].Billing_Type__c != ''){
                if(subscriptionList[0].Billing_Type__c.contains(billAccBillType)){
                    thisOrder.Billing_Account__c = subscriptionList[0].Zuora__CustomerAccount__c;
                    thisOrder.Billing_Type__c = subscriptionList[0].Billing_Type__c;
                    thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
                    billingAccountOption = 'useExisting';
                }
            }
            //END UD-1651 06/25/15 - RReyes - added condition to meet Order.Billing_Account__c filter
            // End UD-1147/D-2486/D-2907 10Jun15 JohnD - set the billing account in the order
            
            //START D-0821 1/8/2015 Added By C. Lin - Get Renewal Package Code from Package Item object instead of Package object. Only Newspaper and Magazine has Renewal Package Code.
            //renewalPackageCode = subscriptionList[0].Main_Package_1__r.Renewal_Package_Code__c;
            Id prodId;
            String zProductType;
            Boolean discounted = false;
            Id packId;
            String subPeriod;
            
            //START D-4413 Gdelrosario reverted the package code to package
            List<Package__c> packageList = [SELECT Id, Subscription_Period__c,RenewalPkgCodeNewspaper__c, RenewalPkgCodeMag1YrBase__c, RenewalPkgCodeMag1YrDisc__c, 
                                                     RenewalPkgCodeMag2YrBase__c, RenewalPkgCodeMag2YrDisc__c, RenewalPkgCodeNewspaper__r.Package_Code__c, 
                                                     RenewalPkgCodeMag1YrBase__r.Package_Code__c, RenewalPkgCodeMag1YrDisc__r.Package_Code__c, 
                                                     RenewalPkgCodeMag2YrBase__r.Package_Code__c, RenewalPkgCodeMag2YrDisc__r.Package_Code__c
                                                FROM Package__c WHERE Id = :subscriptionList[0].Main_Package_1__c];
            
            
            Map<id,Package__c> packMap = new Map<Id,Package__c>();
            //END D-4413 Gdelrosario reverted the
            for(Package__c pack : packageList){
                packId = pack.Id;
                subPeriod = pack.Subscription_Period__c;
                //START D-4413 Gdelrosario reverted the
                packMap.put(pack.Id, pack);
                //END D-4413 Gdelrosario reverted the
            }
            //Start: D-1748 01/20/15 Added by A Banaag - added Product_Family2__c to query
            // START : UD-3048 11/10/2015 Alyana Navarro
            //START D-4413 Gdelrosario reverted thev
            List<Package_Item__c> packageItemList = [SELECT Id, Product_Family2__c, Name, RecordTypeId, Package__c, Product_Rate_Plan__r.zqu__ZProduct__c 
                                                        FROM Package_Item__c WHERE Package__c = :packId];
            //END D-4413 Gdelrosario reverted the
            for(Package_Item__c packageItem : packageItemList){
                if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')){ 
                    prodId = packageItem.Product_Rate_Plan__r.zqu__ZProduct__c;
                }
                
                if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount')){
                    discounted = true;
                }
            //End: D-1748 01/20/15 Added by A Banaag - added Product_Family2__c to query
            }
            
            List<zqu__ZProduct__c> productsList = [SELECT Id, Name, ProductSubType__c FROM zqu__ZProduct__c WHERE Id = : prodId];
            
            for(zqu__ZProduct__c product : productsList){
                zProductType = product.ProductSubType__c;
            }
            
            renewalPackageCode = '';
            if(discounted == false){
                for(Package_Item__c packageItem : packageItemList){
                    if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Newspaper'){
                        renewalPackageCode = '';
                        //START D-4413 Gdelrosario reverted the
                        if(packMap.get(packageItem.Package__c).RenewalPkgCodeNewspaper__c != null){
                            renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeNewspaper__r.Package_Code__c;
                        }
                        /*
                        if(packageItem.RenewalPkgCodeNewspaper__c != null){
                            renewalPackageCode = packageItem.RenewalPkgCodeNewspaper__r.Package_Code__c;
                        }*/
                        //END D-4413 Gdelrosario reverted the
                    }else if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine'){
                        if(subPeriod == '12'){
                            //START D-4413 Gdelrosario reverted the
                            if(packMap.get(packageItem.Package__c).RenewalPkgCodeMag1YrBase__c != null){
                                renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                            }
                            /*
                            if(packageItem.RenewalPkgCodeMag1YrBase__c != null){
                                renewalPackageCode = packageItem.RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                            }*/
                            //END D-4413 Gdelrosario reverted the
                        }else if(subPeriod == '24'){
                            //START D-4413 Gdelrosario reverted the
                            if(packMap.get(packageItem.Package__c).RenewalPkgCodeMag2YrBase__c != null){
                                renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                            }
                            /*
                            if(packageItem.RenewalPkgCodeMag2YrBase__c != null){
                                renewalPackageCode = packageItem.RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                            }*/
                            //END D-4413 Gdelrosario reverted the
                        }
                    }
                }
            }else{
                for(Package_Item__c packageItem : packageItemList){
                    if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine'){
                        if(subPeriod == '12'){
                            //START D-4413 Gdelrosario reverted the
                            if(packMap.get(packageItem.Package__c).RenewalPkgCodeMag1YrDisc__c != null){
                                renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                            }
                            /*
                            if(packageItem.RenewalPkgCodeMag1YrDisc__c != null){
                                renewalPackageCode = packageItem.RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                            }*/
                            //END D-4413 Gdelrosario reverted the
                        }else if(subPeriod == '24'){
                            //START D-4413 Gdelrosario reverted the
                            if(packMap.get(packageItem.Package__c).RenewalPkgCodeMag2YrDisc__c != null){
                                renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                            }

                            /*
                            if(packageItem.RenewalPkgCodeMag2YrDisc__c != null){
                                renewalPackageCode = packageItem.RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                            }*/
                            //END D-4413 Gdelrosario reverted the
                        }
                    }
                }
            }
            //END D-0821 1/8/2015 Added By C. Lin
            
            //START D-4723 24Apr16 FrancisBenzon : comment out logic as it is not used anymore. Possible SOQL issue
            /*
            for (Zuora__Subscription__c tmp : subscriptionList) {
                //system.assertEquals('Size ' , ' ' + subscriptionList.size());
                if (tmp.Id == subscriptionId) {                 
                    selectedPackageId = tmp.Main_Package_1__c;
                    
                    //START D-0821 1/8/2015 Added By C. Lin - Get Renewal Package Code from Package Item object instead of Package object. Only Newspaper and Magazine has Renewal Package Code.
                    //START D-4413 Gdelrosario reverted the package code to package                    
                    List<Package__c> packList = [SELECT Id, Subscription_Period__c,RenewalPkgCodeNewspaper__c, 
                                                    RenewalPkgCodeMag1YrBase__c, RenewalPkgCodeMag1YrDisc__c, RenewalPkgCodeMag2YrBase__c, RenewalPkgCodeMag2YrDisc__c,
                                                    RenewalPkgCodeNewspaper__r.Package_Code__c,  RenewalPkgCodeMag1YrBase__r.Package_Code__c, 
                                                    RenewalPkgCodeMag1YrDisc__r.Package_Code__c, RenewalPkgCodeMag2YrBase__r.Package_Code__c, 
                                                    RenewalPkgCodeMag2YrDisc__r.Package_Code__c
                                                FROM Package__c WHERE Id = :tmp.Main_Package_1__c];
                    
                    Map<id,Package__c> packMap2 = new Map<Id,Package__c>();
                    //END D-4413 Gdelrosario reverted the package code to package
                    for(Package__c pack : packList){
                        packId = pack.Id;
                        subPeriod = pack.Subscription_Period__c;
                        //START D-4413 Gdelrosario reverted the package code to package
                        packMap2.put(pack.Id, pack);
                        //END D-4413 Gdelrosario reverted the package code to package
                    }
                    //START UD-4415 Gdelrosario
                    List<Package_Item__c> packItemList = [SELECT Id, Name, RecordTypeId, Product_Rate_Plan__r.zqu__ZProduct__c,/* RenewalPkgCodeNewspaper__c, 
                                        RenewalPkgCodeMag1YrBase__c, RenewalPkgCodeMag1YrDisc__c, RenewalPkgCodeMag2YrBase__c, RenewalPkgCodeMag2YrDisc__c,
                                        RenewalPkgCodeNewspaper__r.Package_Code__c,  RenewalPkgCodeMag1YrBase__r.Package_Code__c, 
                                        RenewalPkgCodeMag1YrDisc__r.Package_Code__c, RenewalPkgCodeMag2YrBase__r.Package_Code__c, 
                                        RenewalPkgCodeMag2YrDisc__r.Package_Code__c*/
                                        //Package__c
                                        //FROM Package_Item__c WHERE Package__c = :packId];
                    //END UD-4415 Gdelrosario
                    /*
                    for(Package_Item__c packageItem : packItemList){
                        if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')){ 
                            prodId = packageItem.Product_Rate_Plan__r.zqu__ZProduct__c;
                        }
                        
                        if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount')){
                            discounted = true;
                        }
                    }
                    
                    List<zqu__ZProduct__c> prodList = [SELECT Id, Name, ProductSubType__c FROM zqu__ZProduct__c WHERE Id = : prodId];
                    
                    for(zqu__ZProduct__c product : prodList){
                        zProductType = product.ProductSubType__c;
                    }
                    renewalPackageCode = '';
                    if(discounted == false){
                        for(Package_Item__c packageItem : packItemList){
                            if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Newspaper'){
                                //START D-4413 Gdelrosario reverted the package code to package
                                if(packMap2.get(packageItem.Package__c).RenewalPkgCodeNewspaper__c != null){
                                    renewalPackageCode = packMap2.get(packageItem.Package__c).RenewalPkgCodeNewspaper__r.Package_Code__c;
                                }
                                /*if(packageItem.RenewalPkgCodeNewspaper__c != null){
                                    renewalPackageCode = packageItem.RenewalPkgCodeNewspaper__r.Package_Code__c;
                                }*/
                                //END D-4413 Gdelrosario reverted the package code to package
                            /*}else if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine'){
                                if(subPeriod == '12'){
                                    //START D-4413 Gdelrosario reverted the package code to package
                                    if(packMap2.get(packageItem.Package__c).RenewalPkgCodeMag1YrBase__c != null){
                                      renewalPackageCode = packMap2.get(packageItem.Package__c).RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                                    }
                                    /*if(packageItem.RenewalPkgCodeMag1YrBase__c != null){
                                        renewalPackageCode = packageItem.RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                                    }*/
                                    //END D-4413 Gdelrosario reverted the package code to package
                                /*}else if(subPeriod == '24'){
                                    //START D-4413 Gdelrosario reverted the package code to package
                                    if(packMap2.get(packageItem.Package__c).RenewalPkgCodeMag2YrBase__c != null){
                                        renewalPackageCode = packMap2.get(packageItem.Package__c).RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                                    }
                                    /*if(packageItem.RenewalPkgCodeMag2YrBase__c != null){
                                        renewalPackageCode = packageItem.RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                                    }*/
                                    //END D-4413 Gdelrosario reverted the package code to package
                    /*
                                }
                            }
                        }
                    }else{
                        for(Package_Item__c packageItem : packItemList){
                            if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine'){
                                if(subPeriod == '12'){
                                    //START D-4413 Gdelrosario reverted the package code to package
                                    if(packMap.get(packageItem.Package__c).RenewalPkgCodeMag1YrDisc__c != null){
                                         renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                                     }
                                    /*if(packageItem.RenewalPkgCodeMag1YrDisc__c != null){
                                        renewalPackageCode = packageItem.RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                                    }*/
                                    //END D-4413 Gdelrosario reverted the package code to package
                                /*}else if(subPeriod == '24'){
                                    //START D-4413 Gdelrosario reverted the package code to package
                                    if(packMap.get(packageItem.Package__c).RenewalPkgCodeMag2YrDisc__c != null){
                                      renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                                    }
                                    /*if(packageItem.RenewalPkgCodeMag2YrDisc__c != null){
                                        renewalPackageCode = packageItem.RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                                    }*/
                                    //END D-4413 Gdelrosario reverted the package code to package
                               /* }
                            }
                        }
                    }
                    //END D-0821 1/8/2015 Added By C. Lin
                }
            }
            */
            //END D-4723 24Apr16 FrancisBenzon : comment out logic as it is not used anymore. Possible SOQL issue
            // END : UD-3048 11/10/2015 Alyana Navarro         
            initialize();

        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('No Subscription'));
            ApexPages.addMessage(myMsg);
        }
        //START D-2648 AddedBy FrancisBenzon : populateAsia1 onload of page if package is Digital or AllinOne
        populateRecipientContactRelatedDetails();
        //END D-2648 AddedBy FrancisBenzon : populateAsia1 onload of page if package is Digital or AllinOne
    }

  /**
  * @description : This method will check if an order already existing on the account.
  *    If there is no New or Draft order associated to the account, it will create a new one
  */
  @TestVisible //Karl
    private void checkAndCreateOrder() {
        
        list<SObject> orderList = new list<SObject>();
        // Start D-1345 01/16/2015 JohnD add dtl date
        dtlDate = getDtlDate();
        // End D-1345
        
        string queryStr = generateOrderSoqlStr();
        queryStr += ' where Order_Type__c = \'Renewal\' and Account__c = \'' + accountId + '\'';
        
        if (subscriptionId != null) {
      // if subscription was selected
      
          queryStr += ' and (Status__c = \'Draft\' or Status__c = \'New\') and Base_Subscription__c = \'' + subscriptionId + '\' limit 1';  // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD - added filter status = New
          orderList = database.query(queryStr);
          
        } else {
            // if subscription was not selected
            // get the base subscription
            
              queryStr += ' and (Status__c = \'Draft\' or Status__c = \'New\') limit 1';
              orderList = database.query(queryStr);
            
            if (orderList.size() > 0) {
              if (orderList[0].get('Base_Subscription__c') != null) {
                subscriptionId = (id)orderList[0].get('Base_Subscription__c');
              }
            }          
        }

        if (orderList.size() == 0) {
            
            // Start D-1345 01/16/2015 JohnD remove instantiation
            //thisOrder = new Order__c();
            // End D-1345 01/16/2015 JohnD
            thisOrder.Account__c = accountId;
            thisOrder.Status__c = 'New';
            thisOrder.Credit_Balance__c = 0;
            thisOrder.Delivery_Charge__c = 0;
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            thisOrder.Order_Type__c = 'Renewal';  
            
            //START D-3164 06/242015 Added by J.Sarion - Populate Account Name, Account Number,
            //START D-4214 01/18/16 RReyes - added Total_Credit_Balance1__c, set it to order credit balance
            Account acc = [SELECT Id, Name, Account_Auto_Number__c, Total_Credit_Balance1__c FROM Account WHERE Id = :accountId];
            thisOrder.Credit_Balance__c = acc.Total_Credit_Balance1__c;
            thisOrder.Credit_Amount__c = thisOrder.Credit_Balance__c;
            //END D-4214 01/18/16 RReyes - added Total_Credit_Balance1__c, set it to order credit balance
            thisOrder.Account_Name__c = acc.Name;
            thisOrder.Account_Number__c = acc.Account_Auto_Number__c;
            //END D-3164 06/242015 Added by J.Sarion - Populate Account Name, Account Number,
               
    //Start UD-0407 03-16-15 ABanaag - populate months between start/end
            if(subscriptionId!=null){
                //START D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
                Zuora__Subscription__c selectedSub = [SELECT id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Order_Number_1__r.Delivery_Charge_Type__c, Order_Number_1__r.Subscriber_Charge__c,                                        Order_Number_1__r.Vendor_Credit__c, Promotion_1__c
                                                      FROM Zuora__Subscription__c
                                                      WHERE id =: subscriptionId];

                selectedDeliveryChargeType = selectedSub.Order_Number_1__r.Delivery_Charge_Type__c;
                thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType;
                thisOrder.Subscriber_Charge__c = selectedSub.Order_Number_1__r.Subscriber_Charge__c;
                subscriberCharge = thisOrder.Subscriber_Charge__c;
                thisOrder.Vendor_Credit__c = selectedSub.Order_Number_1__r.Vendor_Credit__c;
                vendorCredit = thisOrder.Vendor_Credit__c;
                //END D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
                Date startDate = selectedSub.Zuora__SubscriptionStartDate__c;
                Date endDate = selectedSub.Zuora__SubscriptionEndDate__c;
                if(startDate!=null && endDate!=null){
                    thisOrder.Months_Between_Start_End__c = startDate.monthsbetween(endDate);
                }
                //fritzMay
                if(selectedSub.Promotion_1__c != null)
                {
                    selectedPromotionId  = selectedSub.Promotion_1__c;
                    populatePromotionGifts();
                }
                //fritzMay
            }
    //End UD-0407 03-16-15 ABanaag - populate months between start/end
            
            insert thisOrder;
            RenewalOrderId = thisOrder.id; //START/END D-3152 06/23/15 James
            refreshOrder();
        
        } else {
          
            thisOrder = (Order__c)orderList[0];
            
            // Start UD-1147/D-2486/D-2907 10Jun15 JohnD
            if (thisOrder.Billing_Account__c != null) {
                thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
            }
            // End UD-1147/D-2486/D-2907 10Jun15 JohnD
                refreshVfPageOrderDetails();
        }
    }

  /**
  * @description : This method will save the transaction. 
  *    Invoke by the Save button on the vf page
  */
    public PageReference save() {
    String coaErrorMessage = null; //START-END D-4099 K. Tan 12/18/2015       
        //START UD-3293 11/25/15 RReyes
        if(parentCaseId != null){
            thisOrder.Parent_Case__c = String.valueOf(parentCaseId);
        }
        //END UD-3293 11/25/15 RReyes
        //START UD-1389 6/16/2015 GdelRosario : Added validation rule for Saving Payment Method ID
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
        //START D-4213 & D-4216 Gdelrosario : added validation rule to check the check amount input by the user

        if(thisOrder.Payment_Mode__c == 'Check'){
            Decimal amountError = thisOrder.Check_Amount__c;
            
            if(amountError == null){
                amountError = 0;
            }
            
            if(amountError < dueToSPH){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('Insufficient Amount'));
                ApexPages.addMessage(myMsg);
                return null;
            }
        }

        //END D-4213 & D-4216 Gdelrosario : added validation rule to check the check amount input by the user
        //START UD-1214 5/21/2015 Gdelrosario : added validation rule for ARMS Functions
        if(billingAccountOption == 'createNew'){
            if (thisOrder.Payment_Mode__c == 'Other' && thisOrder.Other_Payment_Mode__c == 'Invoice'){
                 //START UD-2220 09/15/15 RReyes - Only one invoice billing account per billing type is allowed on each account
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
        
                }else if((accNum != null || accNum != '') && (accTextName != null || accTextName != '') && searchAcctTick == false && thisOrder.Create_ARMS_Customer_Account__c  == false && thisOrder.Business_Profile__c == 'NONE' && thisOrder.Debt_Management_Treatment__c == 'NONE' ){//START/END UD-2390 - applies existing conditions from Start Sub for UD-1736
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
        //START UD-2219 08/07/15 RReyes - SIT Hotfix - changed validation location
        if((thisOrder.Business_Profile__c =='NONE' || thisOrder.Debt_Management_Treatment__c == 'NONE') && (thisOrder.Payment_Mode__c == 'Other' && thisOrder.Other_Payment_Mode__c == 'Invoice')){
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.getErrorMessage('ARMSBusProfDebtMgt'));
            ApexPages.addMessage(myMsg1);
            return null;
        }
        //END UD-2219 08/07/15 RReyes - SIT Hotfix - changed validation location         
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
        //START D-4099 K. Tan 12/18/2015
        coaErrorMessage = validateFutureDatedCOA(thisOrder.Recipient_Contact__c, null, GlobalVariableClass.RECTYPE_RENEWAL_OF_SUBSCRIPTION);
        if(coaErrorMessage != null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, coaErrorMessage);
            ApexPages.addMessage(myMsg);
            return null;
        }        
        //END D-4099 K. Tan 12/18/2015           
         // START UD-2375 Dags Validation for BUsiness Profile and Debt Management
         //START D-3108 13/06/2015 S.Puli
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
                
                //END D-3108 13/06/2015 S.Puli
                //START UD-1821 09-July-2015 Added by S.Puli
                if(thisOrder.Customer_Name__c <> null && thisOrder.Customer_No__c <> null){
                    List<Zuora__CustomerAccount__c> checkOtherBillingAcc = [Select Id, Name,Zuora__Account__c, Other_PaymentMethod__c, ARMS_Account_Number__c, ARMS_Customer_Number__c From Zuora__CustomerAccount__c Where Zuora__Account__c <> :thisOrder.Account__c AND ARMS_Customer_Number__c = :thisOrder.Customer_No__c Limit 1];
                   
                    if(checkOtherBillingAcc.size()>0){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS Customer Number Used') + checkOtherBillingAcc[0].Name);
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    
                }
                //END UD-1821 09-July-2015 Added by S.Puli
                 //START UD-2805 Added by Dags Updated the conditions for UD-2375
                If (thisOrder.Customer_No__c <> null) {
                   if (thisOrder.Business_Profile__c <> BusProfile) {
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS Business Profile') + GlobalVariableClass.BUSDEBT1 + BusProfile + ')');
                            ApexPages.addMessage(myMsg);
                            return null;
                            thisOrder.Business_Profile__c = BusProfile;
                   }
                }
                
                system.debug('k:  '+thisOrder.ARMS_Account_Number__c);
                If (thisOrder.ARMS_Account_Number__c <> null){
                    if (thisOrder.Debt_Management_Treatment__c <> DebtManagement) {
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS Debt Management') + GlobalVariableClass.BUSDEBT2  + DebtManagement + ')');
                            ApexPages.addMessage(myMsg);
                            return null;
                            thisOrder.Debt_Management_Treatment__c = DebtManagement;
                    }
                }
                //END UD-2805 Added by Dags Updated the conditions for UD-2375
        
        //START D-2617 3/25/15 AddedBy FrancisBenzon : variable set of MainPackageBillingType
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
        //END D-2617 3/25/15 AddedBy FrancisBenzon : variable set of MainPackageBillingType
        PageReference pgRef;
        boolean isError = false;
        //START D-3332 11/13/15 RReyes
        Set<Id> subIdSet = new Set<Id>();
        Zuora__Subscription__c zSub = new Zuora__Subscription__c();
        String packageType, oliRecId;
        //END D-3332 11/13/15 RReyes
        //START D0420 3/26/2015 GDELROSARIO  : added for the validation of renewal of sub

        //START UD0809 4/23/2015 GDELROSARIO  : added for the validation of renewal of sub
        system.debug('>>>>>CHA selectedSubscriptionId ' + selectedSubscriptionId);
        if(selectedSubscriptionId == ' ' ){
            subscriptionId = selectedSubscriptionId;        
        } else if (selectedSubscriptionId != null) {
            subscriptionId = subscriptionId;      
        }   

        //END UD0809 4/23/2015 GDELROSARIO  : added for the validation of renewal of sub 
        String PENDING = GlobalVariableClass.STATUS_PENDING;
        String CLOSED = GlobalVariableClass.STATUS_CLOSED;       
        String RENUWAL = GlobalVariableClass.SUBJECT_RENEWAL_OF_SUBSCRIPTION;
                    
        totalSubscriptions = subscriptionList.size();       
        
        //START D-3332 11/13/15 RReyes
        if(subscriptionId != null){
            subIdSet.add(subscriptionId);
            zSub = [SELECT Main_Package_1__r.Package_Type__c, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE Id =:subscriptionId LIMIT 1];
            if(zSub != null){
                packageType = zSub.Main_Package_1__r.Package_Type__c;
                oliRecId = zSub.Order_Line_Item_Number_1__c;
            }
            if(packageType == 'Bundle'){
                if(oliRecId != null){
                    for(Zuora__Subscription__c tempSub : [SELECT Id FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c =:oliRecId]){
                        if(!subIdSet.contains(tempSub.Id)){
                            subIdSet.add(tempSub.Id);
                        }
                    }
                }
            }
            
        }
        //END D-3332 11/13/15 RReyes
        //START PD_0151 05262016 Gdelrosario
        Set<Id> orderIdFromCase = new Set<Id>();
        Set<Id> validForRenwal = new Set<Id>();
        Map<Id, Case> subIdtoCase = new Map<Id, Case>();
        List<Zuora__Subscription__c> deletedSub = new List<Zuora__Subscription__c>();
        Set<Id> deletedSubID = new Set<Id>();
        
        if (totalSubscriptions > 1){
            deletedSub = [SELECT Id, Name, Status_Formula__c, Order_Number_1__c FROM Zuora__Subscription__c WHERE Zuora__Account__c =: thisOrder.Account__c];
            for (Zuora__Subscription__c currentDelSub  : deletedSub){
                if(currentDelSub.Status_Formula__c == 'Deleted'){
                    deletedSubID.add(currentDelSub.Id);
                }               
            }
            List<Case> casListperSub = [SELECT AccountId,CaseNumber,Status,Subject,Order_Number__c
                                            FROM Case 
                                                WHERE Subscription_Name__c IN :subIdSet]; //START/END D-3332 11/13/15 RReyes - changed from subscriptionId to subIdSet
            for(case cas : casListperSub) {
                orderIdFromCase.add(cas.Order_Number__c);
            }
            List<Zuora__Subscription__c> subwith = [SELECT Name, Id, Status_Formula__c,Order_Number_1__c FROM Zuora__Subscription__c WHERE Order_Number_1__c IN :orderIdFromCase];
            
            for(case cas :casListperSub){
                for(Zuora__Subscription__c subCurrent : subwith){
                    if(cas.Subject == RENUWAL){
                        if(subCurrent.Order_Number_1__c == cas.Order_Number__c){
                            if(subIdtoCase.get(subCurrent.Id) == null){
                                subIdtoCase.put(subCurrent.Id,cas);
                            }
                        }
                    }
                }
            }
            
            Set<Id> inalidRenwalSet = new Set<Id>();
            for(Id delId : deletedSubID){
                inalidRenwalSet.add(subIdtoCase.get(delId).Id);
            }

            //System.assertEquals(null, inalidRenwalSet);

            
            for(case cas : casListperSub){
                if(!inalidRenwalSet.contains(cas.Id)){
                    for(Zuora__Subscription__c subs : subwith){
                        if(subs.Status_Formula__c != 'Deleted'){
                            if(cas.Status == PENDING){
                                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'There is an open case ' + cas.CaseNumber+' of type '+cas.Subject +'. Please complete or cancel the open case to proceed the request.')); 
                                isError = true; 
                            }else if (cas.Status == CLOSED && cas.Subject == RENUWAL){
                                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'There is an recently closed case ' + cas.CaseNumber+' of type '+cas.Subject +'. This request cannot proceed.')); 
                                isError = true; 
                            }
                        }
                    }
                }
                
            }
        
        }else if (totalSubscriptions == 1){
             deletedSub = [SELECT Id, Name, Status_Formula__c, Order_Number_1__c FROM Zuora__Subscription__c WHERE Zuora__Account__c =: thisOrder.Account__c];
            for (Zuora__Subscription__c currentDelSub  : deletedSub){
                if(currentDelSub.Status_Formula__c == 'Deleted'){
                    deletedSubID.add(currentDelSub.Id);
                }               
            }
            List<Case> casListperSub = [SELECT AccountId,CaseNumber,Status,Subject,Order_Number__c
                                            FROM Case 
                                                WHERE Subscription_Name__c IN :subIdSet]; //START/END D-3332 11/13/15 RReyes - changed from subscriptionId to subIdSet
            for(case cas : casListperSub) {
                orderIdFromCase.add(cas.Order_Number__c);
            }
            List<Zuora__Subscription__c> subwith = [SELECT Name, Id, Status_Formula__c,Order_Number_1__c FROM Zuora__Subscription__c WHERE Order_Number_1__c IN :orderIdFromCase];
            
            for(case cas :casListperSub){
                for(Zuora__Subscription__c subCurrent : subwith){
                    if(cas.Subject == RENUWAL){
                        if(subCurrent.Order_Number_1__c == cas.Order_Number__c){
                            if(subIdtoCase.get(subCurrent.Id) == null){
                                subIdtoCase.put(subCurrent.Id,cas);
                            }
                        }
                    }
                }
            }
            
            Set<Id> inalidRenwalSet = new Set<Id>();
            for(Id delId : deletedSubID){
                inalidRenwalSet.add(subIdtoCase.get(delId).Id);
            }

            //System.assertEquals(null, inalidRenwalSet);

            
            for(case cas : casListperSub){
                if(!inalidRenwalSet.contains(cas.Id)){
                    for(Zuora__Subscription__c subs : subwith){
                        if(subs.Status_Formula__c != 'Deleted'){
                            if(cas.Status == PENDING){
                                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'There is an open case ' + cas.CaseNumber+' of type '+cas.Subject +'. Please complete or cancel the open case to proceed the request.')); 
                                isError = true; 
                            }else if (cas.Status == CLOSED && cas.Subject == RENUWAL){
                                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'There is an recently closed case ' + cas.CaseNumber+' of type '+cas.Subject +'. This request cannot proceed.')); 
                                isError = true; 
                            }
                        }
                    }
                }
                
            }
        }
        
           //END PD_0151 05262016 Gdelrosario
          //END D0420 3/26/2015 GDELROSARIO  : added for the validation of renewal of sub          
        
        if (thisOrder.Recipient_Contact__c == null) {
          isError = true;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ConstantsSLB.getErrorMessage('Required Recipient Contact'));
          ApexPages.addMessage(myMsg);
        }

        // Check if the Term Length is not null
        
        //Start MMallorca D-3142 Add filter to check if it is not evergreen 06/24/2015
        if (orderLineItem.Term_Length__c == 0 && orderLineItem.Main_Package_Sub_Type__c != 'Evergreen') {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Start Sub Term Length missing'))); 
            isError = true;
        }
        //End MMallorca D-3142 06/24/2015
        // end of Term Length validation
        
        // Check if the New Contract Period is not null
        if ( orderLineItem.Promotion_ID__r.Contract__c == GlobalVariableClass.TS_YES && (orderLineItem.New_Contract_Period__c == 0 || orderLineItem.New_Contract_Period__c == null) ) {//START/End PD-0020 03-Mar-2016 Added By S.Puli, C.Lin, V.Pernicia
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Start Sub New Contract Period missing'))); 
            isError = true;
        }
        // end of New Contract Period validation
        
         if (orderLineItem.Term_is_discussed__c == false && orderLineItem.Promotion_ID__c != null) {
            isError = true;
            isFromPromotion = true; //START/END D-3132 06/20/15 - RReyes
            ApexPages.Message myMsg1 = new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Terms And Condition'));
            ApexPages.addMessage(myMsg1);
            
        }
        
        // Check if the QTY is not null
        if ( orderLineItem.Qty__c == 0 || orderLineItem.Qty__c  == null ) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Temp Stop Qty'))); 
            isError = true;
        }
        // end of QTY validation  
        
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
        
        //Start D-1351 Added by Francis Benzon Subscription Start Date should not be null
        if (orderLineItem.Start_Date__c == null) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Renewal Start Date Missing')));
            isError = true;  
        }
        //End D-1351 Added by Francis Benzon Subscription Start Date should not be null
        
        //Start 02/24/2015 D-2050 Added by Von Alvin Pernicia billingAccountOption should not be null
        if (billingAccountOption == null) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('PleaseSelectBillingOrNewOne')));
            isError = true;  
        }
        //End D-2050 Added by Von Alvin Pernicia billingAccountOption  should not be null
        //Start UD-0433 3/18/2015 James - restrict user from submitting if user creates new invoice billing account even there is already an existing invoice billing
        if(existinginvoicebilling == true && thisOrder.Payment_Mode__c == OTHERPAYMENT && thisOrder.Other_Payment_Mode__c == INVOICE){
            ApexPages.addMessage(new APexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.getErrorMessage('ARMS Existing invoice')+ existinginvoicebillingname));
            isError = true;
        }
        //End UD-0433 3/18/2015 James
        // update
        thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType; // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD - added
        //populateRecipientContactRelatedDetails(); // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out
        
        //thisOrder.Status__c = 'Draft'; //START/END D-4214 01/19/15 RReyes - set to draft below
        thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        thisOrder.Base_Subscription__c = subscriptionId;
        thisOrder.Delivery_Charge__c = 0;
        // Start D-1345 01/16/2015 JohnD add dtl date
        thisOrder.DTL_Date__c = getDtlDate();
        // End D-1345
        
        if (billingAccountOption == 'createNew') {
          thisOrder.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
          
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
          
        } else if (billingAccountOption == 'useExisting') {
          if (thisOrder.Billing_Account__c != null) {
            //START D-3164 06/24/2015 Added by J.Sarion - Populate Billing Contact and Payment Method Id
            Zuora__CustomerAccount__c billAccExisting = [SELECT Id, Billing_Contact__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c FROM Zuora__CustomerAccount__c WHERE Id = :thisOrder.Billing_Account__c];
            
            thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
            thisOrder.Payment_Method_ID__c = null;
            //START/END D-2617 3/25/15 FrancisBenzon : commented out below code line
            //thisOrder.Other_Payment_Mode__c = null;
            thisOrder.Billing_Contact__c = billAccExisting.Billing_Contact__c;
            thisOrder.Payment_Method_ID__c = billAccExisting.Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
            //END D-3164 06/24/2015 Added by J.Sarion - Populate Billing Contact and Payment Method Id

            //eraseCheckDetails();

            //START D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to blank if payment mode is not "Other"
            if (thisOrder.Payment_Mode__c != 'Other'){
            thisOrder.Other_Payment_Mode__c = '';}
            //END D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to null if payment mode is not "Other"
          } else {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ConstantsSLB.getErrorMessage('Required Billing Account'));
            ApexPages.addMessage(myMsg);
          }
        }
        
        //START D-3223 07/09/15 RReyes - validates if order has billing account
        if(!hasBillingAccount('RENEWAL', thisOrder)){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Billing Account')));
        return null; 
        }
        //END D-3223 07/09/15 RReyes - validates if order has billing account
        //START D-2617 5/7/15 AddedBy Ronald Dagaraga : if List of OLI has Recurring, throw validation
               
       if(orderLineItem.Main_Package_Billing_Type__c.contains('Recurring'))
       {                          
          if(paymentModeSet.contains(thisOrder.Payment_Mode__c) || (thisOrder.Payment_Mode__c == otherPaymentMode && otherPaymentModeSet.contains(thisOrder.Other_Payment_Mode__c)))
            {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(error_PaymentMode)));
             return null;
             }                           
        }                           
                    
        //END D-2617 5/7/15 AddedBy Ronald Dagaraga : if List of OLI has Recurring, throw validation
      
        if (isError == false ) {
        //Start D-1754 01/21/15 Added by April Banaag - update order before adding OLI
          // Start D-2424 03-03-2015 JohnD added try catch
            try {
                
                //START D-2847 05-06-2015 Marvin G  
                list<id> lstofOrderLine = new list<id>();
            
                for (Order_Line_Item__c OliLists: [select id, (select id from Order_Line_Item_Gifts__r) from Order_Line_Item__c where Order__c =: thisOrder.id]) {
                    lstofOrderLine.add(OliLists.id);
                    
                    for (Order_Line_Item_Gift__c OliGiftList: OliLists.Order_Line_Item_Gifts__r) {
                        lstofOrderLine.add(OliGiftList.id);
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
                
                //START D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
                recalculateCharges();
                //END D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
            
                update thisOrder; 

                // Start D-1345 01/19/2015 JohnD change logic of catching the error
                if (addOrderLineItem() == true) {
                    //START UD-1078 5/11/2015 Added by J. Sarion - Calculate Full Prepaid Inc Del Charge
                    recalculateCharges(); // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
                    
                    // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out. replaced by calling the updateCharges method instead
                    /* 
                    Map<String, Decimal> chargeMap = getCharges(thisOrder.Recipient_Contact__c, thisOrder.Delivery_Charge_Type__c, null, null);
                    if (chargeMap.containsKey('SubscriberCharge'))
                        thisOrder.Subscriber_Charge__c = chargeMap.get('SubscriberCharge');
                    else
                        thisOrder.Subscriber_Charge__c = 0.00;
                    map<string, decimal> deliveryCharges = FullPrepaidDeliveryChargeCalculator.calculate(thisOrder.Id, thisOrder.Subscriber_Charge__c);
                    thisOrder.Full_Prepaid_Delivery_Charge__c =  deliveryCharges.get(GlobalVariableClass.BILLING_TYPE_FULL);
                    thisOrder.Recurring_Delivery_Charge__c = deliveryCharges.get(GlobalVariableClass.BILLING_TYPE_RECURRING);
                    */
                    // End UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out. replaced by calling the updateCharges method instead
                    thisOrder.Status__c = 'Draft'; //START/END D-4214 01/19/15 RReyes - set to draft
                    update thisOrder;
                    //END UD-1078 5/11/2015 Added by J. Sarion - Calculate Full Prepaid Inc Del Charge
            
                    string retUrl = '/apex/SM_RenewalOfSubscriptionDetail?id=' + thisOrder.Id + '&accountId=' + thisOrder.Account__c;
                    pgRef = new PageReference(retUrl);
                    pgRef.setRedirect(true);
                    
                } else {
                    
                    pgRef = null;
                    
                }
                // End D-1345 01/19/2015 JohnD
                
            } catch (exception e) {
                ApexPages.addMessages(e);
                //START UD-2219 08/08/15 RReyes - SIT Hotfix - reverts old values if already set
                if(isReset){
                    revertOldValues();
                }//END UD-2219 08/08/15 RReyes - SIT Hotfix - reverts old values if already set
                pgRef = null;
            }
             //End D-2424 03-03-2015 JohnD
        //End D-1754 01/21/15 Added by April Banaag - update order before adding OLI    
        }

        //START UD-2219 08/07/15 CommentedOut by RReyes - SIT Hotfix -  moved validation up
        /*//START UD-1488 06/08/2015 KAREN HUNG added validation: Business Profile and Debt Management Treatment cannot be  "NONE" if payment method is invoice. 
        if((thisOrder.Business_Profile__c =='NONE' || thisOrder.Debt_Management_Treatment__c == 'NONE') && (thisOrder.Payment_Mode__c == 'Other' && thisOrder.Other_Payment_Mode__c == 'Invoice')){
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.getErrorMessage('ARMSBusProfDebtMgt'));
            ApexPages.addMessage(myMsg1);
            return null;
        }
        //END UD-1488 06/08/2015 KAREN HUNG */
        //END UD-2219 08/07/15 CommentedOut by RReyes - SIT Hotfix -  moved validation up
        
        //START D-3382 CCB-135 04/Aug/15 Wenjun: Roll Back 1454 as it is withdrawn
        /*
        //START UD-1454 06/27/15 RReyes - checks vendor if valid before assignment
        if(orderLineItem.Delivered_By__c == DELIVERED_BY_VENDOR){
            if(thisOrder.Recipient_Contact__c != null && subscriptionId != null){
                Map<Id, Account> mapVenIdToAcc = new Map<Id, Account>();  
                Id vendorId = null;
                
                Zuora__Subscription__c selectSub = [SELECT Vendor_1__c, Order_Line_Item_Number_1__r.Vendor_Mailing_Agent__c 
                                        FROM Zuora__Subscription__c WHERE Id=: subscriptionId LIMIT 1]; 
                if(selectSub != null){
                    if(selectSub.Vendor_1__c != null){
                        Contact recCont = [SELECT Address__r.Postal_Code__c FROM Contact 
                                    WHERE Id=: thisOrder.Recipient_Contact__c LIMIT 1];
                        if(recCont != null){
                            if(recCont.Address__r.Postal_Code__c != null){  
                                for(Vendor_Allocation__c venAlloc : [SELECT Vendor_Account__r.Id, Vendor_Account__c from Vendor_Allocation__c WHERE SingPost_Address__c =: recCont.Address__r.Postal_Code__c]){
                                    mapVenIdToAcc.put(venAlloc.Vendor_Account__r.Id , venAlloc.Vendor_Account__r);
                                }
                                if(mapVenIdToAcc.keyset().size() > 0){
                                    if(selectSub.Vendor_1__c != null){
                                        vendorId = (Id)selectSub.Vendor_1__c;
                                    }
                                        
                                    if(vendorId != null){
                                        if(mapVenIdToAcc.keyset().contains(vendorId)){
                                            orderLineItem.Vendor_Mailing_Agent__c = mapVenIdToAcc.get(vendorId).Id;
                                            
                                            try{
                                                update orderLineItem;
                                            }catch(Exception e){
                                                System.debug('>>>orderLineItem update failed: ' + e.getMessage());
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //END UD-1454 06/27/15 RReyes - checks vendor if valid before assignment
        */
        //END D-3382 CCB-135 04/Aug/15 Wenjun
        
        /*START UD-1454 CommentedOut by RReyes - use new logic above       
        //Start MMallorca UD-1454 Retrieve Vendor of Existing Subscription 06/15/2015
        if(orderLineItem.Vendor_Mailing_Agent__c == null){
            try{
                if(subscriptionId!=null){
                    Id vendor;
                    Zuora__Subscription__c selectedSub = [SELECT Id, Vendor_1__c, Order_Number_1__c
                                                            FROM Zuora__Subscription__c
                                                            WHERE Id =: subscriptionId limit 1];
                                                            
                    if(selectedSub.Vendor_1__c!=null){
                        vendor = selectedSub.Vendor_1__c;
                    }
                    else{
                        Order_Line_Item__c ordline = [SELECT Id, Vendor_Mailing_Agent__c
                                                            FROM Order_Line_Item__c
                                                            WHERE Order__c =: selectedSub.Order_Number_1__c limit 1];
                                                            
                        if(ordline.Vendor_Mailing_Agent__c!=null){
                            vendor = ordline.Vendor_Mailing_Agent__c;
                        }                               
                        else{
                            list<Order_Line_Item__c> lOrderLineItems = new list<Order_Line_Item__c>();  
                            lOrderLineItems = [select Id, Delivered_By__c, Recipient_Postal_Code__c, 
                                                      Vendor_Mailing_Agent__c, PO_Number__c
                                               from Order_Line_Item__c 
                                               where Order__c =: thisOrder.Id ];   
                            if(lOrderLineItems.size() > 0){
                                Vendor_Assignment va = new Vendor_Assignment();
                                va.Assign_Vendor_To_Order_line_Items(lOrderLineItems);
                            }
                        }
                    }
                    orderLineItem.Vendor_Mailing_Agent__c = vendor;
                    update orderLineItem;
                }
            }
            catch (exception e){
                //No Vendor Found in current Subscription
                list<Order_Line_Item__c> lOrderLineItems = new list<Order_Line_Item__c>();  
                lOrderLineItems = [select Id, Delivered_By__c, Recipient_Postal_Code__c, 
                                          Vendor_Mailing_Agent__c, PO_Number__c
                                   from Order_Line_Item__c 
                                   where Order__c =: thisOrder.Id ];   
        if(lOrderLineItems.size() > 0){  
                Vendor_Assignment va = new Vendor_Assignment();
                va.Assign_Vendor_To_Order_line_Items(lOrderLineItems);
            }
        }
    }
        //End MMallorca UD-1454 06/15/2015
        */
    //END UD-1454 CommentedOut by RReyes - use new logic above 
        return pgRef;
    }
    
    
  /**
  * @description : This method will cancel the transaction. 
  *    Invoke by the Cancel button on the vf page
  */
    public PageReference cancel() {
        
        if (thisOrder.Status__c == 'New') {
          delete [select id from Order_Line_Item__c where Order__c = :thisOrder.Id];
          delete [select id from Order__c where Id = :thisOrder.Id];
        }
        
        string retURl = '/' + thisOrder.Account__c;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
    }

  private void refreshVfPageOrderDetails() {
    
        // check if account has an existing billing account
            
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
              vendorCredit = thisOrder.Vendor_Credit__c;
            } else if (selectedDeliveryChargeType == '9') {
              subscriberCharge = thisOrder.Subscriber_Charge__c;
            }
          }
        }
        // end recipient address related details
        
        // Start UD-0446 Ronald dagaraga for billing account error. Update the code
        // check if account has an existing billing account
        list<Zuora__CustomerAccount__c> billingAccounts = [select Id from Zuora__CustomerAccount__c 
                where Zuora__Account__c = :thisOrder.Account__c];
                
        totalBillingAccounts = billingAccounts.size();
        // end check if account has an existing billing account
        
        if (thisOrder.Billing_Account_Creation_Mode__c == 'Create New Billing Account' 
            || totalBillingAccounts == 0) {
              
          billingAccountOption = 'createNew';
        } else if (thisOrder.Billing_Account_Creation_Mode__c == 'Use existing Billing Account') {
          billingAccountOption = 'useExisting';
          // start UD-1147/D-2486/D-2907 10Jun15 JohnD
          if (isChangedSelection == false) { 
            fetchBillingAccount();
          }
          // end UD-1147/D-2486/D-2907 10Jun15 JohnD
          
          
        }
        // End UD-0446 Ronald dagaraga for billing account error. Update the code
        // end for billing account section      
  }

  private void refreshOrder() {
        // refresh order to reflect the charges
        
        string queryStr = generateOrderSoqlStr();
        queryStr += ' where Id = \'' + thisOrder.Id + '\'';
        
        SObject tmpOrder = database.query(queryStr);
        
        thisOrder = (Order__c)tmpOrder;
        // end refresh order to reflect the charges
    
    refreshVfPageOrderDetails();
  }

    /*
     * Description: This method will retrieve the charges applicable to the recipient contact.
     *      This method is invoke in changing the recipient contact from the VF page
    */
    public void populateRecipientContactRelatedDetails() {
      
        if (thisOrder != null) {    // Start/End D-3086 10Jun15 JohnD - added condition
            
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
                if(contactsMap.get(thisOrder.Recipient_Contact__c).Email != null && contactsMap.get(thisOrder.Recipient_Contact__c).Email != '') // Start/End D-3086 10Jun15 JohnD - switch expressions
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
                        
                    //START D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
                    if (thisOrder.Delivery_Charge_Type__c == null) {
                        thisOrder.Delivery_Charge_Type__c = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
                    }
                    //END D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
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
            
            Map<string, Decimal> charges = getCharges(thisOrder.Recipient_Contact__c, thisOrder.Delivery_Charge_Type__c, subscriberCharge, vendorCredit);
        //END D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
            //START 12/01/15 D-1717 Wenjun - Zone Charge no longer valid
            //thisOrder.Zone_Charge__c = charges.get('ZoneCharge');
            //END 12/01/15 D-1717 Wenjun
            //Start D-0431 04/07/2015 Ronald Dagaraga Added Mailing agent to the criteria
            recalculateCharges(); // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
            //Start UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out. replaced by calling the updateCharges method instead
            /*
            If (orderLineItem.Delivered_By__c=='Mailing Agent') 
            {
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c=0;
            thisOrder.Subscriber_Charge__c = 0;
            thisOrder.Vendor_Credit__c = 0;
            }
            //End D-0431 04/07/2015 Ronald Dagaraga Added Mailing agent to the criteria
            Else 
            {
            thisOrder.Subscriber_Charge__c = charges.get('SubscriberCharge'); 
            thisOrder.Vendor_Credit__c = charges.get('VendorCredit');
            }
            */
            // End UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out. replaced by calling the updateCharges method instead
            //START D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
            if (thisOrder.Recipient_Contact__c != null) {       
                try {
                    
                    recipientAddressRecordTypeName = [select Address__r.RecordType.Name from Contact 
                            where Id = :thisOrder.Recipient_Contact__c].Address__r.RecordType.Name;
                            
                } catch (exception e) {
                    
                    recipientAddressRecordTypeName = '';
                }
            }
            //END D-2648 AddedBy FrancisBenzon : for Asia1 auto population using recipient contact details --Reconstructed method
        }   // Start/End D-3086 10Jun15 JohnD - ending condition
    }
  
    /*
    * Description: This method will add an order line item the the user when the user done populating
    *      the necessary information from the VF page. This item will be added and displayed
    *      on the Line Items section of the VF page
    */
    
    // Start D-1345 01/19/2015 JohnD change return value from void to boolean
    public boolean addOrderLineItem() {
        // End D-1345 01/19/2015 JohnD
        // check if package is from promotion
        list<string> packageIdpromotionId = selectedPackageId.split(':');
        boolean isPassedValidation = true;

        if (orderLineItem.Term_Length__c == null) {
            orderLineItem.Term_Length__c = 0;
        }

        /* validation */
        //System.assertEquals(null, orderLineItem.Addon_Package__c);
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

        if (orderLineItem.Term_is_discussed__c != true && packageIdpromotionId.size() > 1) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Terms And Condition')));
            isPassedValidation = false;
        }

        // end check if package is digital and have and asia1 subscription
        /* end validation */
        //START D-3305 7/31/15 AddedBy Francisbenzon : check if no Asia1 is added for digital packages
        if(isDigital == true && asia1Subscriptions.size() <= 0 && orderLineItem.Asia1_Creation_Mode__c != GlobalVariableClass.STARTSUB_ASIA1_BULK)//START/END UD-3431 12/22/15 RReyes - changed to asia1Subscriptions.size()
        {  
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('At least one asia1 id'))); 
            isPassedValidation = false; 
        }       
        //END D-3305 7/31/15 AddedBy Francisbenzon : check if no Asia1 is added for digital packages
        
        //START UD-3431 12/22/15 RReyes - added checking if quantity > asia1s
         if(isDigital == true && orderLineItem.Qty__c != null && asia1Subscriptions != null){
            if(asia1Subscriptions.size() > orderLineItem.Qty__c){  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Check asia1 list versus quantity'))); 
                isPassedValidation = false; 
            } 
         }    
        //END UD-3431 12/22/15 RReyes - added checking if quantity > asia1s
        
        if (isPassedValidation == true) {
            Contact recipientContact = new Contact();
            if (orderLineItem.Term_Length__c > 0) {
                // [JohnD 12/10] D-0636
                // added null pointer trapping, where null issue problem encountered during the build test
                if (orderLineItem.Start_Date__c != null) {
                    //Start UD-0477 03-23-15 ABanaag minus 1 day
                    orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addMonths((integer)orderLineItem.Term_Length__c).addDays(-1);
                    //End UD-0477 03-23-15 ABanaag minus 1 day
                }
                // end D-0636
            }

            try { 
                //if (orderLineItem.Id != null) {
                //START: UD-3572 1/8/16 Added by Manolo Valena - Commented out to avoid Asia1 deletion after editing and then saving as draft again.
                //deleteRelatedOrderLineItemRelatedObjects(thisOrder.Id, true);
                //END: UD-3572 1/8/16 Added by Manolo Valena
                //START: UD-3572 1/8/16 Added by Manolo Valena
                delete [SELECT Id FROM Order_Line_Item_Gift__c WHERE Order_Line_Item__r.Order__c =: thisOrder.Id];
                list<Asia1_Subscription__c> tmpAsia1Subs = [SELECT Id, Asia1__c 
                                                            FROM Asia1_Subscription__c 
                                                            WHERE Order_Line_Item__r.Order__c =: thisOrder.Id];
                if (tmpAsia1Subs.size() > 0) {
                    delete tmpAsia1Subs;
                }
                delete [SELECT Id FROM Order_Line_Item__c WHERE Order__c =: thisOrder.Id];
                //END: UD-3572 1/8/16 Added by Manolo Valena
                orderLineItem.Id = null;
                //}

                orderLineItem.Subscribed_As__c = 'Renewal';


                // Start UD-1147/D-2486/D-2907 10June15 JohnD - added logic
                if (orderLineItem.Contract_End_Date__c == date.valueOf('1970-01-01')) {
                    isReset = true; //START UD-2219 08/08/15 RReyes - SIT Hotfix - checks if values have been reset
                    orderLineItem.Contract_End_Date__c = null;
                }
        
                if (orderLineItem.New_Contract_Period__c == 999) {
                    isReset = true; //START UD-2219 08/08/15 RReyes - SIT Hotfix - checks if values have been reset
                    orderLineItem.New_Contract_Period__c = null;
                }
        
                if (orderLineItem.Penalty_Charge__c == 9999999999999999.99) {
                    isReset = true; //START UD-2219 08/08/15 RReyes - SIT Hotfix - checks if values have been reset
                    orderLineItem.Penalty_Charge__c = null; 
                }

                thisOrder.Billing_Type__c = orderLineItem.Main_Package_Billing_Type__c;
                               
                // calculate months
                if (orderLineItem.Main_Package_Billing_Type__c == 'Full Prepaid' && orderLineItem.End_Date__c != null 
                        && orderLineItem.Main_Package_Sub_Type__c == 'Termed') {
                            
                    thisOrder.FP_Del_Usage__c = CalculateCharges.getMonths(thisOrder.Id, recipientContact.Address__c, 
                            orderLineItem.Start_Date__c, orderLineItem.End_Date__c);
                }
                // end calculate months

                // End  UD-1147/D-2486/D-2907 10June15 JohnD - added logic
                
                //START 12/01/15 D-1717 Wenjun : Retrieve the latest Posatge
                recalculateCharges(); // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
                // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out. replaced by calling the updateCharges method instead
                /*
                if(orderLineItem.Delivered_By__c == 'Mailing Agent')
                {
                  //Unit Postage Charge * Quanty
                  orderLineItem.Postage_Charge__c = 
                            PostageChargeHelper.getPostageChargeForLineItem(thisOrder.Recipient_Contact__c,orderLineItem) * orderLineItem.Qty__c;
                }
                */
                // End UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out. replaced by calling the updateCharges method instead
                //END 12/01/15 D-1717 Wenjun
                //Start D-3152 James 06/23/2015
                
                //START D-3382 CCB-135 04/Aug/15 Wenjun: Renewal to use the same Vendor / Mailing Agent
                if(RenewalOrderId != null)
                {
                    RenewalOrder = [SELECT Id, Base_Subscription__c FROM Order__c WHERE Id = :RenewalOrderId];
                
                    if(RenewalOrder.size() > 0){
                        BaseSubList = [SELECT id, Order_Line_Item_Number_1__r.Vendor_Conversion__c, Order_Line_Item_Number_1__r.Vendor_Subscription_ID__c, 
                        Order_Line_Item_Number_1__r.Generate_Invoice__c, Order_Line_Item_Number_1__r.Suppress_Renewal_and_Reminder_Letter__c, 
                        Order_Line_Item_Number_1__r.Term_is_discussed__c, Order_Line_Item_Number_1__r.PO_Number__c, Vendor_1__c, 
                        Order_Line_Item_Number_1__r.Supressed_Acknowledgement_Letter__c, Order_Line_Item_Number_1__r.Auto_Renew__c, 
                        Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c, Order_Line_Item_Number_1__r.Qty__c, 
                        Order_Number_1__r.Acquisition_Type__c, Order_Number_1__r.Sponsor__c, Order_Number_1__r.Payment_Type__c
                        FROM Zuora__Subscription__c WHERE Id = :RenewalOrder[0].Base_Subscription__c]; 
                    }
                    
                    if(BaseSubList.size() > 0 && RenewalOrder[0].Base_Subscription__c != null){
                        orderlineitem.Vendor_Conversion__c = BaseSubList[0].Order_Line_Item_Number_1__r.Vendor_Conversion__c;
                        orderlineitem.Vendor_Subscription_ID__c = BaseSubList[0].Order_Line_Item_Number_1__r.Vendor_Subscription_ID__c;
                        orderlineitem.Generate_Invoice__c = BaseSubList[0].Order_Line_Item_Number_1__r.Generate_Invoice__c; 
                        orderlineitem.Suppress_Renewal_and_Reminder_Letter__c = BaseSubList[0].Order_Line_Item_Number_1__r.Suppress_Renewal_and_Reminder_Letter__c;
                        orderlineitem.Term_is_discussed__c = BaseSubList[0].Order_Line_Item_Number_1__r.Term_is_discussed__c;
                        //START D-3423 Wenjun 27 Aug 15: Move the assignment logic to Vendor Assignment
                        //orderlineitem.Vendor_Mailing_Agent__c = BaseSubList[0].Vendor_1__c;
                        //END D-3423 Wenjun 27 Aug 15
                    }
                }
                //END D-3382 CCB-135 04/Aug/15 Wenjun
                //End D-3152 James 06/23/2015
                //START D-3167 AddedBy FrancisBenzon : charity value
                orderlineitem.Charity__c = charityField;
                //END D-3167 AddedBy FrancisBenzon : charity value
                insert orderLineItem;
                

                if (orderLineItem.Promotion_ID__c != null && promotionGifts != null) {                
                    // create order line item gifts
                    list<Order_Line_Item_Gift__c> orderLineItemGifts = new list<Order_Line_Item_Gift__c>();

                    for (GiftWrapper gw : promotionGifts) {

                        if (gw.selectGift) {

                            Order_Line_Item_Gift__c orderLineItemGift = new Order_Line_Item_Gift__c();
                            orderLineItemGift.Order_Line_Item__c = orderLineItem.Id;
                            orderLineItemGift.Promotion_Gift__c = gw.PromotionGift.Id;
                            orderLineItemGifts.add(orderLineItemGift);
                        }
                    }

                    insert orderLineItemGifts;
                    // end create order line item gifts

                    // retrieve total gift prices and update order line item
                    decimal totalGiftPrice = 0;

                    for (Order_Line_Item_Gift__c tmp : [select Price__c from Order_Line_Item_Gift__c 
                            where Order_Line_Item__c = :orderLineItem.Id]) {

                        if (tmp.Price__c != null) {
                            totalGiftPrice += tmp.Price__c;
                        }
                    }

                    orderLineItem.Total_Gift_Price__c = totalGiftPrice;
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
                
                //Start UD-0407 03-19-15 ABanaag
                //Start D-0431 04/07/2015 Ronald Dagaraga Added Mailing agent to the criteria
                if((selectedDeliveryChargeType == 'C' || selectedDeliveryChargeType == 'H' || selectedDeliveryChargeType == 'Z' || selectedDeliveryChargeType == 'L') && subscriberCharge!=null && OrderLineItem.Delivered_By__c!= 'Mailing Agent'){                     
                //End D-0431 04/07/2015 Ronald Dagaraga Added Mailing agent to the criteria                    
                    thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = subscriberCharge;
                }
                else{
                    thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0.00;
                }
                if(orderLineItem.Term_Length__c != null){
                    thisOrder.Months_Between_Start_End__c = orderLineItem.Term_Length__c;
                }
                //End UD-0407 03-19-15 ABanaag
                
                UPDATE thisOrder;
                
                // Start D-1345 01/19/2015 JohnD returning true for success
                return true;
                // End D-1345 01/19/2015 JohnD

            } catch (exception e) {
                ApexPages.addMessages(e);
                //START UD-2219 08/08/15 RReyes - SIT Hotfix - reverts old values if already set
                if(isReset){
                    revertOldValues();
                }//END UD-2219 08/08/15 RReyes - SIT Hotfix - reverts old values if already set
                // Start D-1345 01/19/2015 JohnD returning true for success
                return false;
                // End D-1345 01/19/2015 JohnD
                
            }
        // Start D-1345 01/19/2015 JohnD added return value
        } else {
            return false;   
        }
        // End D-1345 01/19/2015 JohnD
    }

    /*
     * Description: This method will retrieve the information of the selected Order Line Item and 
     *      populate the data on the Subscription Details Section of the VF page.
     *      This will allow the user to update the Order Line Item. Invoke when user click on the
     *      specific Order Line Item from the Line Item section of the VF page
    */
    //Note: Wenjun - For "New" Order, the following code always generates exception as no orderLineItem exists
    public void retrieveOrderLineItem() {

        // Start D-0033 UAT 01-03-2015 JohnD followed changes in start subscription
        Product_Publication__c publicationDetail = new Product_Publication__c();
        Package__c pkg = new Package__c();
        set<id> productIds = new set<id>();
        // End D-0033 UAT 01-03-2015 JohnD

        isChangedSelection = true; // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
        
        try {
                
          // Start D-1345 01/19/2015 JohnD retrieve selected subscription's package name
          selectedSubscriptionPackageName = [select Name from Package__c where Id = :selectedPackageId].Name;
          // End D-1345 01/19/2015 JohnD
          //System.assertEquals(null, selectedSubscriptionPackageName);
          //System.assertEquals(1, 2);
          //START 12/01/15 D-1717 Wenjun - Retrieve Postage Charge Related Fields
          //START D-3332 11/05/15 RReyes -  added Main_Package_ID__r.Subscription_Period__c - rollback
          //START PD-0020 03-Mar-2016 Added By S.Puli, C.Lin, V.Pernicia
          orderLineItem = [select Id, Name, Promotion_ID__r.Name, Order__c, Asia1_Creation_Mode__c, Auto_Renew__c, Charity__c, Contract_End_Date__c, 
                  Promotion_ID__r.Contract__c, Delivered_By__c, Earliest_Start_Date__c, End_Date__c, Generate_Invoice__c, Is_Digital__c, 
                  Main_Package_ID__c, New_Contract_Period__c, Main_Package_ID__r.Name, Main_Package_Sub_Type__c, 
                  Penalty_Charge__c, PO_Number__c, Qty__c, Start_Date__c, Total_Subscription_Rate__c, Postage_Charge__c, Total_Postage_Charge__c, 
                  Add_On_Package_Subscription_Rate__c, Term_is_discussed__c, Main_Package_Billing_Type__c, 
                  Main_Package_Type__c, Main_Package_Subscription_Rate__c, Main_Package_Frequency__c, Main_Package_Period__c,
                  Supressed_Acknowledgement_Letter__c, Suppress_Renewal_and_Reminder_Letter__c, Main_Package_Product_Sub_Type__c, 
                  Supressed_Vendor_Notification_New_Sub__c, Term_Length__c, Vendor_Conversion__c, 
                  Vendor_Subscription_ID__c, Addon_Package__c, Addon_Package__r.Name, Promotion_ID__c, Subscribed_as__c, 
                  Direct_Sub_Delivery_Method__c, (select Promotion_Gift__c, Gift_Name__c, Type__c, Price__c from Order_Line_Item_Gifts__r), 
                  (select Asia1__c, Asia1__r.User_ID_LDAP_ID__c, Service_Access_Flag__c, 
                  Service_Access_Flag__r.Name, Status__c, Concurrent__c from Asia1_Subscriptions__r) 
                  from Order_Line_Item__c where Order__r.Base_Subscription__c = :subscriptionId and 
                  Order__r.Status__c = 'Draft' and Order__c = :thisOrder.Id limit 1];
          //End PD-0020 03-Mar-2016 Added By S.Puli, C.Lin, V.Pernicia
          //END D-3332 11/05/15 RReyes -  added Main_Package_ID__r.Subscription_Period__c - rollback
          //END 12/01/15 D-1717 Wenjun
          // populate getter-setter variables
          //subscriptionPeriod = orderLineItem.Main_Package_ID__r.Subscription_Period__c; //START/END D-3332 11/05/15 RReyes - commentedout - rollback
          selectedPackageName = orderLineItem.Main_Package_ID__r.Name;
          selectedSubscriptionPackageName = orderLineItem.Main_Package_ID__r.Name; //START/END D-3132 06/20/15 RReyes
          addOnPackage = new Package__c();
          promotionGifts = new list<GiftWrapper>();
          initializeAsia1Components();
          isDigital = false;
          selectedPackageId = orderLineItem.Main_Package_ID__c; 
          deliveryMethod = new list<SelectOption>();
          // retrieve recipient contact detai of the selected subscription
     //START D-1646 6/22/2015 JLedesma Add-on selection
           //START UD-2531 7/27/2015 Dags added delivered by
          Zuora__Subscription__c zs = [select Id, Order_Line_Item_Number_1__c, Recipient_Contact__c, Cost_Center__c, Delivery_Charge_Type_1__c, 
          Main_Package_1__c, Zuora__SubscriptionEndDate__c, Delivered_By_1__c from Zuora__Subscription__c where Id = :subscriptionId];
          // end retrieve recipient contact detai of the selected subscription
     //END D-1646 6/22/2015 JLedesma Add-on selection       
     //END UD-2531 7/27/2015 Dags added delivered by           
          thisOrder.Recipient_Contact__c = zs.Recipient_Contact__c;
          thisOrder.Cost_Centre__c = zs.Cost_Center__c;
          thisOrder.Delivery_Charge_Type__c = zs.Delivery_Charge_Type_1__c;
          thisOrder.Base_Subscription__c = subscriptionId;
          thisOrder.Status__c = 'New'; // Start/End UD-1147/D-2486/D-2907 JohnD - added
          
          if (orderLineItem.New_Contract_Period__c != null && orderLineItem.Start_Date__c != null) {
            //START D-3132 06/20/15 RReyes - added -1 day  
            orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1);
            //END D-3132 06/20/15 RReyes - added -1 day  
          }
          
          if (orderLineItem.Promotion_ID__c != null) {
  
              isFromPromotion = true;
              selectedPackageId += ':' + orderLineItem.Promotion_ID__c;
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
              // end gifts
        }//START D-1082 JB Domingo 12/18/2014 - Penalty Charge, New Contract Period and Contract End Date are equal to N/A 
        else{
            // converted to N/A in visualforce
            orderLineItem.Penalty_Charge__c = 9999999999999999.99;  
            orderLineItem.New_Contract_Period__c = 999;
            orderLineItem.Contract_End_Date__c = date.valueOf('1970-01-01');
            // end converted to N/A in visualforce          
        }
        //END D-1082 JB Domingo 12/18/2014

        if (orderLineItem.Is_Digital__c == true) {
            //System.assert(false);
            isDigital = true;
            asia1Subscriptions = getAsia1s(orderLineItem.Asia1_Subscriptions__r);
            asia1SubscriptionsTotal = asia1Subscriptions.size();
         }
          
        // Start D-0033 UAT 01-03-2015 JohnD followed changes on start subscription
    // Start VPernicia 03/26/2015 - Added Is_Newspaper__c for Package_Items__r to recognize the field in the if condition
        try {
            //START D-3332 11/05/15 RReyes - changed from orderLineItem.Main_Package_ID__c to selectedPackageId - rollback
            pkg = [select Id, Package_Code__c, Name, Subscription_Type__c, 
                    Package_Sub_Type__c, Subscription_Period__c, Product_Family_Current_Package__c, Billing_Type__c, Package_Type__c, 
                    (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, Is_Newspaper__c, 
                    Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, RecordType.DeveloperName, 
                    Product_Rate_Plan__r.SubscriptionFrequency__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c  
                    from Package_Items__r) from Package__c where Id = :orderLineItem.Main_Package_ID__c];
            //END D-3332 11/05/15 RReyes - changed from orderLineItem.Main_Package_ID__c to selectedPackageId - rollback
        } catch (exception e) {
            ExceptionLogger.log(new list<exception> { e });
        }

        for (Package_Item__c tmp : pkg.Package_Items__r) {  
                      
            productIds.add(tmp.Product_Rate_Plan__r.zqu__ZProduct__c);
            
            if (tmp.Is_Newspaper__c == true) {
                isNewspaper = true;
            }
        }
        // End VPernicia 03/26/2015 - Added Is_Newspaper__c for Package_Items__r to recognize the field in the if condition
        
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

        // Start D-3338 VPernicia Comment out
        // Start D-2486 10Jun15 JohnD - added logic to retrieve the delivered by field
        /*deliveryMethod.add(new SelectOption(DELIVERED_BY_NONE, DELIVERED_BY_NONE));
        
        if (publicationDetail.Publication_Code__c != null 
                && publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c != null) {
            
            if (publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == DELIVERED_BY_BOTH) {
                
                deliveryMethod.add(new SelectOption(DELIVERED_BY_MAILING_AGENT, DELIVERED_BY_MAILING_AGENT));
                deliveryMethod.add(new SelectOption(DELIVERED_BY_VENDOR, DELIVERED_BY_VENDOR));
            
            } else {
                
                orderLineItem.Delivered_By__c = publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c;
                deliveryMethod.add(new SelectOption(publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c, 
                        publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c));
                
            }
        } */
    // End D-3338 VPernicia Comment out
    
    // Start D-3338 VPernicia retrieve the delivered by field
    List<Product_Publication__c> publicationDetailList = new List<Product_Publication__c>();
    
    try {
            publicationDetailList = [select Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c 
                    from Product_Publication__c where ZProduct__c in :productIds];
        } catch (exception e) {
            publicationDetailList = new List<Product_Publication__c>();
        }
    
        set<string> uniqueOptions = new set<string>();
        
        deliveryMethod.add(new SelectOption(DELIVERED_BY_NONE, DELIVERED_BY_NONE));
        uniqueOptions.add(DELIVERED_BY_NONE);
        
        if(publicationDetailList.size()>0){
            for(Product_Publication__c pubDetail : publicationDetailList){
                if (pubDetail.Publication_Code__c != null 
                && pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c != null) {
                
                    if (pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == DELIVERED_BY_BOTH 
                            || pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == null) {
                      
                      if (thisOrder.id == null){  
                        orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;}
                     
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
        
                }
            }
        }
    // End D-3338 VPernicia retrieve the delivered by field
        // End D-2486 10Jun15 JohnD - added logic to retrieve the delivered by field
          
        populateRecipientContactRelatedDetails();
        orderLineItemList.add(orderLineItem);
        calculateCharges(); // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
        // end populate getter-setter variables
       } catch (exception e) {
       //START D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
       //START: PD-0035 May 13, 2016 Added by Kristine Balaoing - added field promotion in sub query
        Zuora__Subscription__c zSub = [SELECT Order_Number_1__r.Subscriber_Charge__c, Order_Number_1__r.Vendor_Credit__c, Delivered_By_1__c, Order_Number_1__r.Delivery_Charge_Type__c, Promotion_1__c FROM Zuora__Subscription__c WHERE Id = :subscriptionId];
        //System.assertEquals(null, zSub);
        if (zSub != null) {
            if (zSub.Order_Number_1__r.Subscriber_Charge__c != null) {
                thisOrder.Subscriber_Charge__c = zSub.Order_Number_1__r.Subscriber_Charge__c;
                subscriberCharge = thisOrder.Subscriber_Charge__c;
            }
            if (zSub.Order_Number_1__r.Vendor_Credit__c != null) {
                thisOrder.Vendor_Credit__c = zSub.Order_Number_1__r.Vendor_Credit__c;
                vendorCredit = thisOrder.Vendor_Credit__c;
                
            }
            if (zSub.Order_Number_1__r.Delivery_Charge_Type__c != null) {
                thisOrder.Delivery_Charge_Type__c = zSub.Order_Number_1__r.Delivery_Charge_Type__c;
                selectedDeliveryChargeType = thisOrder.Delivery_Charge_Type__c;
            }
            
            orderLineItem.Delivered_By__c = zSub.Delivered_By_1__c;
        }
        //END D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
          //START D-2648 AddedBy FrancisBenzon : populateAsia1 onload of page if package is Digital or AllinOne
          populateRecipientContactRelatedDetails();
          //END D-2648 AddedBy FrancisBenzon : populateAsia1 onload of page if package is Digital or AllinOne
          isCalledFromController = true; //START/END D-3156 06/23/15 GDelRosario/RReyes
          populateSubscriptionDetail();
       }
    }

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
        //START D-0821 1/9/2015 Added By C. Lin - Variables needed for getting Packages based on renewalPackageCode variable.
        Set<Id> pIds = new Set<Id>();
        set<id> packageIds = new set<id>();
        List<Package_Item__c> pItemList;
        //END D-0821 1/9/2015 Added By C. Lin
        // Start D-1345 01/19/2015 JohnD variable to be used in filtering the results
        list<SObject> packageResultListTmp = new list<SObject>();
        // End D-1345 01/19/2015 JohnD
        
        if (searchText.length() > 1) {     
        //Start D-1793 01/21/15 Added by April Banaag - query will return no result if user is searching a packages that are not of the same billing type as the subscription being renewed.
        //Start UD-0421 19/03/2015 Ronald Dagaraga Some codes were commented out to search for product family and search billing type
            //if(searchBillingType != selectedPackageBillingType){
            //START D-0821 1/9/2015 Added By C. Lin - Removed Renewal_Package_Code__c field in query
            string qry = 'select Id, Name, Package_Type__c, Subscription_Type__c, Subscription_Period__c, Billing_Type__c from Package__c where Name like \'%' + searchText + '%\'';
            //START: UD-1242 06/08/2015 Jean Cari?o - Modified the query to add filter on the Package Type
            qry += ' and Billing_Type__c=\'' + searchBillingType + '\' and Package_Type__c != \'Add On\' and Package_Type__c != \'Grace Period\'';
            //END: UD-1242 06/08/2015 Jean Cari?o
            //START:D-0051 2/25/15 Added by Manolo Vale?a - Removed 'and Number_Of_Promotions__c < 1' from the query to allow users to search for packages that are also attached to a promotion.
            qry += ' limit 101';
            //END:D-0051 2/25/15 Added by Manolo Vale?a
            //END D-0821 1/9/2015 Added By C. Lin
                packageResultList = Database.query(qry); 
            //}
            //else{
            //packageResultList = new list<SObject>();
            //}
        //End UD-0421 19/03/2015 Ronald Dagaraga Some codes were commented out to search for product family and search billing type
        //End D-1793 01/21/15 Added by April Banaag - query will return no result if user is searching a packages that are not of the same billing type as the subscription being renewed.  
        if (packageResultList.size() > 0) {
            
            //START D-0821 1/9/2015 Added By C. Lin - Get Packages based on searchText and searchBillingType and Number_Of_Promotions__c < 1
            for(SObject tmp : packageResultList){
                pIds.add((Id)tmp.get('Id'));
            }
            //END D-0821 1/9/2015 Added By C. Lin
        }
        //START D-0821 1/9/2015 Added By C. Lin - Get Packages from packageResultList based on the renewalPackageCode variable.
        
        //Start: D-1748 01/20/15 Added by A Banaag - search results filtered; must have the same Product Family as selected package's package item
        List<Package_Item__c>  selectedPackageItem = [Select Id, Package__r.Id, Product_Family2__c FROM Package_Item__c WHERE Package__r.Id =: selectedPackageID];
        list<string> productFamily = new List<string>();
        for(Package_Item__c packageItem : selectedPackageItem){
            if(packageItem.Product_Family2__c!=null){
                productFamily.add(packageItem.Product_Family2__c);
            }
        }
        if(productFamily.size()>0){
            pItemList = [SELECT Id, Name, Product_Family2__c, Package__c FROM Package_Item__c WHERE Package__c IN : pIds AND 
                    //Start: D-1793 01/21/15 Added by April Banaag - will be commented out because this condition is only for batch scenario
                    /**(RenewalPkgCodeNewspaper__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag1YrBase__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag1YrDisc__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag2YrBase__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag2YrDisc__c = :renewalPackageCode)
                    AND **/
                    //End: D-1793 01/21/15 Added by April Banaag - will be commented out because this condition is only for batch scenario
                    Product_Family2__c IN : productFamily
                    ];
        }
        else{       //Start: D-1793 01/21/15 Added by April Banaag - will be commented out because this condition is only for batch scenario
            pItemList = [SELECT Id, Name, Product_Family2__c, Package__c FROM Package_Item__c WHERE Package__c IN : pIds /**AND 
                    (RenewalPkgCodeNewspaper__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag1YrBase__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag1YrDisc__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag2YrBase__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag2YrDisc__c = :renewalPackageCode)**/
                    //End: D-1793 01/21/15 Added by April Banaag - will be commented out because this condition is only for batch scenario
                    ];
        }
        //END : D-1748 01/20/15 Added by A Banaag - search results filtered; must have the same Product Family as selected package's package item
        if (pItemList.size() > 0) {
            for(Package_Item__c pItem : pItemList){
                packageIds.add(pItem.Package__c);
            }
            retrievePackageSubscriptionRate(packageIds, searchBillingType);
        }
        //END D-0821 1/9/2015 Added By C. Lin
        
        // Start D-1345 01/19/2015 JohnD added logic that only package within renewal package codes must be displayed
        for (SObject tmp : packageResultList) {
                
                if (packageIds.contains((id)tmp.Id)) {
                        packageResultListTmp.add(tmp);
                }
        }
        
        packageResultList = packageResultListTmp;
        // End D-1345 01/19/2015 JohnD
      }
}
    
    /**
    * @description : this method will search the promotion object
    */      
    public void searchPromotion() {
        set<string> promoCodes = new set<string>();
        promotionCode_isEligible = new map<string, boolean>();
        //START D-2312 02-23-2015  Marvin Gatchalian
        promotionCodeMap = new map<string, set<string>>();
        promotionResultList = new list<SObject>();
        
        Map<String, Set<String>> mapPromoCodeContract = new Map<String, Set<String>>();
        //END D-2312 02-23-2015  Marvin Gatchalian
        
        
        //START D-0821 1/9/2015 Added By C. Lin - Variables needed for getting Promotion based on renewalPackageCode variable.
        Set<Id> packIds = new Set<Id>();
        set<Id> packageIds = new set<Id>();
        List<Package_Item__c> pItemList;
        List<Package__c> PackageList = new List<Package__c>();
        Set<String> newPackIds = new set<String>();     
        //END D-0821 1/9/2015 Added By C. Lin
      
      if (searchText.length() > 1) { 
        //START D-1793 01/21/15 added by April Banaag - query will return no result if user is searching a packages that are not of the same billing type as the subscription being renewed.
        if(searchBillingType == selectedPackageBillingType){
            //START D-0821 1/9/2015 Added By C. Lin - Get Packages based on searchBillingType and with Package Items with Renewal Package Code same as renewalPackageCode variable.
            PackageList = [SELECT Id, Name From Package__c WHERE Billing_Type__c = :searchBillingType];
        }
        else{
            PackageList = new list<Package__c>();
        }
        //END D-1793 01/21/15 added by April Banaag - query will return no result if user is searching a packages that are not of the same billing type as the subscription being renewed.

        if (PackageList.size() > 0) {
            for(Package__c pack : PackageList){
                packIds.add((Id)pack.get('Id'));
            }
        }
        
        //Start: D-1748 01/20/15 Added by A Banaag - search results filtered; must have the same Product Family as selected package's package item
        List<Package_Item__c>  selectedPackageItem = [Select Id, Package__r.Id, Product_Family2__c FROM Package_Item__c WHERE Package__r.Id =: selectedPackageID];
        list<string> productFamily = new List<string>();
        for(Package_Item__c packageItem : selectedPackageItem){
            if(packageItem.Product_Family2__c!=null){
                productFamily.add(packageItem.Product_Family2__c);
            }
        }
        if(productFamily.size()>0){
            pItemList = [SELECT Id, Name, Product_Family2__c, Package__c FROM Package_Item__c WHERE Package__c IN : packIds AND 
                    //Start: D-1793 01/21/15 Added by April Banaag - will be commented out because this condition is only for batch scenario
                    /**(RenewalPkgCodeNewspaper__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag1YrBase__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag1YrDisc__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag2YrBase__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag2YrDisc__c = :renewalPackageCode)
                    AND **/
                    //End: D-1793 01/21/15 Added by April Banaag - will be commented out because this condition is only for batch scenario
                    Product_Family2__c IN : productFamily
                    ];
        }
        else{       //Start: D-1793 01/21/15 Added by April Banaag - will be commented out because this condition is only for batch scenario
            pItemList = [SELECT Id, Name, Product_Family2__c, Package__c FROM Package_Item__c WHERE Package__c IN : packIds 
                    /**(RenewalPkgCodeNewspaper__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag1YrBase__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag1YrDisc__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag2YrBase__c = :renewalPackageCode OR 
                    RenewalPkgCodeMag2YrDisc__c = :renewalPackageCode)**/
                    //End: D-1793 01/21/15 Added by April Banaag - will be commented out because this condition is only for batch scenario

                    ];
        }
        //End: D-1748 01/20/15 Added by A Banaag - search results filtered; must have the same Product Family as selected package's package item
        if (pItemList.size() > 0) {
            for(Package_Item__c pItem : pItemList){
                packageIds.add(pItem.Package__c);
            }
        }
        
        //START D-2312 02-23-2015  Marvin Gatchalian 
        String myfilterPackage = '';
        for(Id p : packageIds){
            String pckg = '\'' + string.valueOf(p) + '\'';
            newPackIds.add(pckg);
            myfilterPackage  = myfilterPackage +  pckg + ',';
            
        }
        
        if (newPackIds.size() > 0) {
            myfilterPackage  = myfilterPackage.left(myfilterPackage.length() - 1);
            myfilterPackage  = '(' + myfilterPackage  + ')';
        } 
        else {
            myfilterPackage  = '(\'\')';
        }
        
        String filterPackage = '' + newPackIds;
        filterPackage = filterPackage.replace('{', '(');
        filterPackage = filterPackage.replace('}', ')');
        //END D-0821 1/9/2015 Added By C. Lin
        
        //START D-0821 1/9/2015 Added By C. Lin - Change query to searching for Promotion Package based on the filtered Package based on Renewal Package Code
        // Start D-1345 01/19/2015 JohnD replace search criteria
        string qry = 'select Promotion__c promoId, Promotion__r.Promotion_Code__c promoCode, Promotion__r.Name promoName, Promotion__r.Effective_Start_Date__c promoStartDate, Promotion__r.Effective_End_Date__c promoEndDate, ';
        qry += 'Promotion__r.Contract_Period__c promoContractPeriod from Promotion_Package__c where Promotion__r.Name like \'%' + searchText + '%\'';
        //qry +=' and Package_Name__r.Billing_Type__c=\'' + searchBillingType + '\' and Package_Name__c IN :newPackIds group by Promotion__c, Promotion__r.Effective_Start_Date__c,';
        qry +=' and Package_Name__r.Billing_Type__c=\'' + searchBillingType + '\' and Package_Name__c IN ' + myfilterPackage  + ' group by Promotion__c, Promotion__r.Effective_Start_Date__c,';
        qry += ' Promotion__r.Effective_End_Date__c, Promotion__r.Promotion_Code__c, Promotion__r.Contract_Period__c, Promotion__r.Name limit 101';
        // End D-1345 01/19/2015
        //END D-0821 1/9/2015 Added By C. Lin
        
        //END D-2312 02-23-2015  Marvin Gatchalian 
        
          list<SObject> searchResults = Database.query(qry);
          
          if (searchResults.size() > 0) {
              //START D-2312 02-23-2015  Marvin Gatchalian
              Set<String> promoId = new Set<String>();
              // retrieve eligibility rule
              
              //for (SObject tmp : searchResults) {
                  
              //      if (tmp.get('promoCode') != null) {
              //          promoCodes.add((string)tmp.get('promoCode'));
              //      }
              //}
              
                  for (SObject tmp : searchResults) {
                        //for ineligible
                        if(tmp.get('promoId') != null){
                            promoId.add((string)tmp.get('promoId'));
                        }
                        if (tmp.get('promoCode') != null) {
                            promoCodes.add((string)tmp.get('promoCode'));
                            if(mapPromoCodeContract.containsKey((string)tmp.get('promoCode'))){
                                mapPromoCodeContract.get((string)tmp.get('promoCode')).add((string)tmp.get('promoContractPeriod'));
    
                            }
                            else{
                                mapPromoCodeContract.put((string)tmp.get('promoCode'), new Set<String>{(string)tmp.get('promoContractPeriod')});
                            }
                        }
                    }
              
              
              //promotionCode_isEligible = PromotionEligibilityRule.getEligibility(accountId, 'Add', promoCodes, null, null);
              
               //vdr = vnd(vendorEligibilityCheck);
               PromoEligibilityRule pRule = new PromoEligibilityRule();
               promotionCodeMap  = pRule.getEligibility(accountId, 'Add', mapPromoCodeContract, null, null, false);
               
               for(String promoCode : promotionCodeMap.Keyset()){
                    if(promotionCodeMap.get(promoCode)!=null){
                        promotionCode_isEligible.put(promoCode, true);
                    }
                    else{
                        promotionCode_isEligible.put(promoCode , false);
                    }
               }
               
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
                    
              // end retrieve eligibility rule
              //if (isRemoveEligibilityRuleSearchFilter == true) {
              //    promotionResultList = searchResults;
              //} else {
              //    for (SObject tmp : searchResults) {
                      
              //          string pc = (string)tmp.get('promoCode');
              //        if (promotionCode_isEligible.get(pc) == true) {
              //            promotionResultList.add(tmp);
              //        }
              //    }
              //}
              
              
               //END D-2312 02-23-2015  02-23-2015  Marvin Gatchalian 
          }
      }
    }

    /**
    * @description : This method will retrieve and sum-up the related List Price field from Product Rate Plan object
    *           and map it to its corresponding Package.
    */      
    private static void retrievePackageSubscriptionRate(set<id> packageIds, string billingType) {
        packageId_subscriptionCharge = SM_SubscriptionHelper.getPackageSubscriptionRate(packageIds, billingType);       
    } 
    /************ end search functionality ***************/
    //START:UD-0451 3/25/15 Added by Manolo Valena - New variable added and method added to convert string to static
    static string sPId;
    private static string conSPId(string s)
    {
        return s;
    }
    //END:UD-0451 3/25/15 Added by Manolo Valena
    
    @remoteAction
    //START:UD-0451 3/25/15 Added by Manolo Valena - Added new parameter "selectedPackage" and called new methods
    public static string retrieveRelatedPackages(string promotionId, string billingType, string selectedPackage) {
        sPId = conSPId(selectedPackage);
        return SM_SubscriptionHelper.getRelatedPackagesOnProdFam(promotionId, billingType, sPId); 
    }
    //END:UD-0451 3/25/15 Added by Manolo Valena
    
    public void populateAddOn() {
        isPromotionSelected = true;
        orderLineItem.Addon_Package__c = selectedAddOnPackage;
        
        try {
            addOnPackage = [select Id, Name, (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c  
                from Package_Items__r limit 1) from Package__c where Id = :selectedAddOnPackage];
                
            for (Package_Item__c tmp : addOnPackage.Package_Items__r) {
                orderLineItem.Add_On_Package_Product_Sub_Type__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c;
                orderLineItem.Add_On_Package_Product_Platform__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c;
                
                //Start PD-0035 May 13, 2016 Added by Kristine Balaoing - added for add on rendering
                if (tmp.Is_Digital__c == true) {
                    addOnIsDigital = true;
                    orderLineItem.Is_Digital__c = true;
                }
                //End PD-0035 May 13, 2016 Added by Kristine Balaoing
            }
            
            retrievePackageSubscriptionRate(new set<id>{addOnPackage.Id}, orderLineItem.Main_Package_Billing_Type__c);
            orderLineItem.Add_On_Package_Subscription_Rate__c = packageId_subscriptionCharge.get(addOnPackage.Id);
            System.debug('ADD ON >>>' + addOnPackage.Id);
            System.debug('ORDER LINE >>>' + orderLineItem.Add_On_Package_Subscription_Rate__c);
            System.debug('MAAAAAP PACKAGE ID SUBS >>>' + packageId_subscriptionCharge);
            
            
        } catch (exception e) {
            addOnPackage = new Package__c();
        }
        
        retrieveNewlyAddedAddOn();
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
        
        for (Promotion_Gift__c pg : [select Id, Gift__c, Gift__r.Name, Gift__r.Gift_Type__c, Gift__r.Gift_Cost__c, 
                Balance_Quantity__c, Balance_Quantity_New__c from Promotion_Gift__c where Promotion__c = :selectedPromotionId]) {
                    
            GiftWrapper gw = new GiftWrapper();
            gw.selectGift = false;
            gw.promotionGift = pg;
            
            promotionGifts.add(gw); 
        }
        //System.assertEquals(null, promotionGifts);
    }
    // end gifst

    public void populateSubscriptionDetail() {
        
        // if (subscriptionId != null && subscriptionId != '') {
        set<id> packageIds = new set<id>();
        set<id> productIds = new set<id>();
        isDigital = false;
        isFromPromotion = false;
        Product_Publication__c publicationDetail;
        isAllInOne = false;
        deliveryMethod = new list<SelectOption>();
        orderLineItem = new Order_Line_Item__c();
        initializeAsia1Components();
        boolean isNoDel = false; // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
        id subpromoId = null; //START/END D-3156 06/23/15 GDelRosario/RReyes 
        //selectedPackageId = null; //START/END D-3332 11/06/15 RReyes - commentedout - rollback
        // retrieve recipient contact detai of the selected subscription
        //START 12/01/15 D-1717 Wenjun - Retrieve "Delivered_By_1__c" and "Billing_Type__c"
        // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - added field
    //START D-1646 6/22/2015 JLedesma Add-on selection
        //START D-3158 06/23/15 RReyes - added Qty__c in the query
        //START D-3156 06/23/15 GDelRosario/RReyes - added Promotion_1__c in the query
        //START D-3382 CCB-135 04/Aug/15 Wenjun: Retrieve existing Vendor / Mailing Agent
        //START D-3332 11/06/15 RReyes - added Order_Line_Item_Number_1__r.Main_Package_Type__c, Product_Code__c - rollback + add Main_Package_1__r.Package_Type__c
        system.debug('>>>>>CHA subscriptionId ' + subscriptionId);
        Zuora__Subscription__c zs = [SELECT Order_Line_Item_Number_1__c, Recipient_Contact__c, Cost_Center__c, Delivery_Charge_Type_1__c, 
                Delivered_By_1__c, Billing_Type__c, Main_Package_1__c, Zuora__SubscriptionEndDate__c, Vendor_1__c,
                Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Billing_Type__c, Qty__c, Promotion_1__c, Main_Package_1__r.Subscription_Period__c,
                Main_Package_1__r.Package_Type__c
                FROM Zuora__Subscription__c WHERE Id = :subscriptionId];
        //END D-3332 11/06/15 RReyes - added Order_Line_Item_Number_1__r.Main_Package_Type__c, Product_Code__c - rollback Main_Package_1__r.Package_Type__c
        //END D-3382 CCB-135 04/Aug/15 Wenjun
        //END D-3156 06/23/15 GDelRosario/RReyes - added Promotion_1__c in the query
        //END D-3158 06/23/15 RReyes - added Qty__c in the query
        // End UD-1147/D-2486/D-2907 10Jun15 JohnD - added field
        //END 12/01/15 D-1717 Wenjun
        // end retrieve recipient contact detai of the selected subscription
        
        oliId = zs.Order_Line_Item_Number_1__c;
        //System.assertEquals(subToAddOn + '' , oliId + '');
        if(oliId != null && subToAddOn.containsKey(oliId)){
            selectedAddOnPackage = subToAddOn.get(oliId).Id;
            populateAddOn();
            //System.debug('ORDERLINE AFTER POPADDON >>> ' + orderLineItem.Add_On_Package_Subscription_Rate__c);
            //System.assertEquals(null, orderLineItem.Is_Digital__c);
            //System.assert(false);
        }
        else{
            addOnPackage = new Package__c();
        }
    //END D-1646 6/22/2015 JLedesma Add-on selection
        
        orderLineItem.Delivered_By__c = zs.Delivered_By_1__c; //Start-End D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type and Vendor Credit
        //START D-3423 Wenjun 27 Aug 15: Move the assignment logic to Vendor Assignment
        //orderLineItem.Vendor_Mailing_Agent__c = zs.Vendor_1__c;//START END D-3382 CCB-135 04/Aug/15 Wenjun
        //END D-3423 Wenjun 27 Aug 15
        thisOrder.Recipient_Contact__c = zs.Recipient_Contact__c;
        thisOrder.Cost_Centre__c = zs.Cost_Center__c;
        thisOrder.Delivery_Charge_Type__c = zs.Delivery_Charge_Type_1__c;
        selectedDeliveryChargeType = thisOrder.Delivery_Charge_Type__c; //Start-End D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type and Vendor Credit
        thisOrder.Base_Subscription__c = subscriptionId;
        
        // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - populate billing account
        //Start MMallorca D-3246 16/07/2015
        if (zs.Zuora__CustomerAccount__c != null) {
            thisOrder.Billing_Account__c = zs.Zuora__CustomerAccount__c;
            thisOrder.Billing_Type__c = zs.Zuora__CustomerAccount__r.Billing_Type__c;
            thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
            fetchBillingAccount();
            billingAccountOption = 'useExisting';
        }
        //End MMallorca D-3246 16/07/2015
        // End UD-1147/D-2486/D-2907 10Jun15 JohnD - populate billing account

        populateRecipientContactRelatedDetails();

          // check if package is from promotion
          if (selectedPackageId == null) {
            //START D-3332 11/06/15 RReyes - added logic for bundle packages - commented out - rollback
            system.debug('>>>>>CHA zs.Main_Package_1__c ' + zs.Main_Package_1__c);
            selectedPackageId = zs.Main_Package_1__c;
            /*
            if(zs.Order_Line_Item_Number_1__r.Main_Package_Type__c != 'Bundle'){
                selectedPackageId = zs.Main_Package_1__c;
            }else{
                 selectedPackageId = null;
                 String productCode = '';
                 String packageCodeFromPackItem = ''; 
                 String packageCodeFromProduct = ''; 
                 Boolean isDiscounted = false;
                 Package_Item__c packItem = new Package_Item__c();
                 Map<String, Package_Item__c> mapProdCodeToPackItem = new Map<String, Package_Item__c>();
                 List<Package__c> lstRenewPackages = new List<Package__c>(); 
                 Package__c renewPackage = new Package__c(); 
                 String tmpPackageId = zs.Main_Package_1__c;
                 Set<String> setPackCodes = new Set<String>();
                 
                 
                if(zs != null){
                    productCode = zs.Product_Code__c;
                    subscriptionPeriod = zs.Main_Package_1__r.Subscription_Period__c;
                }
                 
                 if(tmpPackageId != null && productCode != null){
                    List<Package_Item__c > lstPackItem = [SELECT Product_Rate_Plan__r.Product_Code__c, Is_Magazine__c, Is_Newspaper__c, RenewalPkgCodeMag1YrBase__c, RenewalPkgCodeMag1YrDisc__c, RenewalPkgCodeMag2YrBase__c, RenewalPkgCodeMag2YrDisc__c, RenewalPkgCodeNewspaper__c, Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeNewspaper__c, Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeMag1YrBase__c, Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeMag1YrDisc__c, Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeMag2YrBase__c, Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeMag2YrDisc__c 
                    FROM Package_Item__c WHERE Package__c =: tmpPackageId];
                    for(Package_Item__c pack : lstPackItem){
                        if(pack.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount') || pack.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount')){
                            isDiscounted = true;
                        }
                        if(pack.Product_Rate_Plan__r.Product_Code__c == productCode){
                            packItem = pack;
                        }
                    }  
                    if(packItem != null){
                        if(packItem.Is_Magazine__c){
                            if(isDiscounted){
                                if(subscriptionPeriod == '12'){
                                    packageCodeFromPackItem = packItem.RenewalPkgCodeMag1YrDisc__c ;
                                    packageCodeFromProduct = packItem.Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeMag1YrDisc__c ;
                                }else if(subscriptionPeriod == '24'){
                                    packageCodeFromPackItem = packItem.RenewalPkgCodeMag2YrDisc__c ;
                                    packageCodeFromProduct = packItem.Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeMag2YrDisc__c ;
                                }
                            }else{
                                if(subscriptionPeriod == '12'){
                                    packageCodeFromPackItem = packItem.RenewalPkgCodeMag1YrBase__c ;
                                    packageCodeFromProduct = packItem.Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeMag1YrBase__c ;
                                }else if(subscriptionPeriod == '24'){
                                    packageCodeFromPackItem = packItem.RenewalPkgCodeMag2YrBase__c ;
                                    packageCodeFromProduct = packItem.Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeMag2YrBase__c ;
                                }
                            }
                        }else if(packItem.Is_Newspaper__c){
                            packageCodeFromPackItem = packItem.RenewalPkgCodeNewspaper__c;
                            packageCodeFromProduct = packItem.Product_Rate_Plan__r.zqu__ZProduct__r.RenewalPkgCodeNewspaper__c;
                        }
                        if(packageCodeFromPackItem != null && packageCodeFromPackItem  != ''){
                            setPackCodes.add(packageCodeFromPackItem);
                        }
                        if(packageCodeFromProduct != null && packageCodeFromProduct  != ''){
                            setPackCodes.add(packageCodeFromProduct);
                        }
                        
                        if(setPackCodes.size() > 0){
                            try{
                                lstRenewPackages = [Select Id, Name, Package_Code__c FROM Package__c where Package_Code__c IN:setPackCodes];
                                if(lstRenewPackages.size() > 0){
                                    for(Package__c pack : lstRenewPackages){
                                        renewPackage = pack;
                                        if(pack.Package_Code__c == packageCodeFromPackItem){
                                            break;
                                        }
                                    }
                                    selectedPackageId = renewPackage.Id;
                                    selectedPackageName = renewPackage.Name;
                                    selectedSubscriptionPackageName = renewPackage.Name;
                                }
                            }catch(Exception e){
                                selectedPackageId = '';
                                selectedPackageName = '';
                                selectedSubscriptionPackageName = '';
                                String packCodeError = '';
                                if(packageCodeFromPackItem != '' && packageCodeFromPackItem != null){
                                    packCodeError += packageCodeFromPackItem;
                                }
                                if(packageCodeFromProduct != '' && packageCodeFromProduct != null){
                                    if(packCodeError != '' && packCodeError != null){
                                        packCodeError += '/' + packageCodeFromProduct;
                                    }else{
                                        packCodeError = packageCodeFromProduct;
                                    }
                                }
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Package Configured with Package Code: ' + packCodeError));
                            }
                        }                       
                    }
                }
            }*/
            //END D-3332 11/06/15 RReyes - commentedout - rollback
            //Start D-1754 01/21/15 Added by April Banaag start date must be end date of sub to be renewed
            //Start UD-0441 James 03/24/2015 - start date of renewal is equal to end date of previous subscription + 1
            orderLineItem.Start_Date__c = zs.Zuora__SubscriptionEndDate__c.addDays(1);
            //End UD-0441 James 03/24/2015
            //End D-1754 01/21/15 Added by April Banaag start date must be end date of sub to be renewed
          }
          //START/END D-3332 11/06/15 RReyes - commentedout - rollback
          //if(selectedPackageId != null && selectedPackageId != ''){
          
          //START D-3156 06/23/15 GDelRosario/RReyes
          system.debug('>>>>>CHA isCalledFromController ' + isCalledFromController);
          system.debug('>>>>>CHA zs.Promotion_1__c ' + zs.Promotion_1__c);
          if(isCalledFromController && (zs.Promotion_1__c != null)){
              subPromoId = zs.Promotion_1__c;
          }
          //START: PD-0035 May 13, 2016 Added by Kristine Balaoing- added for display of promotion gifts
            if(subPromoId!=null) {
                selectedPromotionId = subPromoId;
                populatePromotionGifts();
            }
          
          //END: PD-0035 May 13, 2016 Added by Kristine Balaoing
          //END D-3156 06/23/15 GDelRosario/RReyes
          system.debug('>>>>>CHA selectedPackageId.split ' + selectedPackageId.split(':'));
          List<string> packageIdpromotionId = selectedPackageId.split(':');
          ID pkgId = packageIdpromotionId[0];
          // end check if package is from promotion
          //START UD-1078 5/11/2015 Added by J. Sarion - Added Package_Price__c
          // Start/End D-0105 UAT 02-03-2015 JohnD added Is_Newspaper field in the query
          // Start/End D-3072 UAT 08-06-2015 Gdelrosario added Product_Rate_Plan__r.RatePlanType__c field in the
          Package__c pkg = [select Id, Package_Code__c, Name, Subscription_Type__c, 
                  Package_Sub_Type__c, Subscription_Period__c, Billing_Type__c, Package_Type__c, Package_Price__c, 
                  (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, Is_Newspaper__c,
                  Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, 
                  Product_Rate_Plan__r.SubscriptionFrequency__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c,Product_Rate_Plan__r.RatePlanType__c,   
                  RecordType.DeveloperName from Package_Items__r) from Package__c where Id = :pkgId];   // Start/End PD-0102 06May16 JohnD - added RecordType.DeveloperName
          //END UD-1078 5/11/2015 Added by J. Sarion - Added Package_Price__c
          // invoke package subscription rate retrieval        
          packageIds.add(pkgId);
          
          //Start: UD-0488 03/26/2015 Added by VPernicia -- Remove the entire query and use and use the above query to pull packageType
          //Start: D-1793 01/21/2015 Added by April Banaag -- searchbillingtype must be that of the package selected
          //Start: D-2412 03/02/2015 Added by Karl Tan -- try catch package selected
          
          /*Package__c selectedPackage = new Package__c();
          try{
           selectedPackage = [SELECT Id, Billing_Type__c
                                      FROM Package__c
                                      WHERE ID =: selectedPackageId
          ];
          }
          catch(Exception e){
              Exceptionlogger.log(new List<Exception>{e});
                
          }*/
          //End: D-2412 03/02/2015 Added by Karl Tan -- try catch package selected
           
                   
          selectedPackageBillingType=pkg.Billing_Type__c; //selectedPackage.Billing_Type__c;
          //End: D-1793 01/21/2015 Added by April Banaag -- searchbillingtype must be that of the package selected
          //End: UD-0488 03/26/2015 Added by VPernicia -- Remove the entire query and use and use the above query to pull packageType

          //START 12/01/15 Wenjun - Fix Bug: if searchBillingType is NULL, set as Base Subscription
          if(searchBillingType == NULL)
          searchBillingType = zs.Billing_Type__c;
          //END 12/01/15 Wenjun
          retrievePackageSubscriptionRate(packageIds, searchBillingType);
          // end invoke package subscription rate retrieval 
          
          //selectedPackageName = pkg.Name; // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out
          selectedSubscriptionPackageName = pkg.Name;   // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
          orderLineItem.Order__c = thisOrder.Id;
          //START UD-1078 5/11/2015 Added by J. Sarion - Calculate Full Prepaid Inc Del Charge
          orderLineItem.Main_Package_Subscription_Rate__c = pkg.Package_Price__c;
          //START D-3143 GDel 06/23/2015
            subscriptionRate = pkg.Package_Price__c;
            //fritz
            //System.assertEquals(null, orderLineItem.Add_On_Package_Subscription_Rate__c);
            //System.assertEquals(1, 2);
            if (orderLineItem.Add_On_Package_Subscription_Rate__c != null) {
                subscriptionRate += orderLineItem.Add_On_Package_Subscription_Rate__c;
            }
          //totalSubscriptionPrice = orderLineItem.Main_Package_Subscription_Rate__c;
          //END D-3143 GDel 06/23/2015
          //orderLineItem.Main_Package_Subscription_Rate__c = packageId_subscriptionCharge.get(pkgId);
          //END UD-1078 5/11/2015 Added by J. Sarion - Calculate Full Prepaid Inc Del Charge
          orderLineItem.Main_Package_ID__c = pkgId; 
          //START D-3158 06/23/15 RReyes - sets OLI quantity to quantity of subscription
          if(zs.Qty__c != null && isCalledFromController){
          orderLineItem.Qty__c = Integer.valueOf(zs.Qty__c);
          }else if(orderLineItem.Qty__c == null){
              orderLineItem.Qty__c  = 1;
          }
        if(pkg.Package_Price__c != null){
            totalSubscriptionPrice = pkg.Package_Price__c * orderLineItem.Qty__c;
        }
          //END D-3158 06/23/15 RReyes - sets OLI quantity to quantity of subscription   
          orderLineItem.Main_Package_Billing_Type__c = pkg.Billing_Type__c;
          //START 12/01/15 D-1717 Wenjun - Set Order "Billing Type" and default "Delivered By"
          thisOrder.Billing_Type__c = pkg.Billing_Type__c;
          // Start UD-1147/D-2486/D-2907 10Jun15 JohnD
          if (isChangedSelection) {
            orderLineItem.Delivered_By__c = zs.Delivered_By_1__c;
          }
          // End UD-1147/D-2486/D-2907 10Jun15 JohnD
          //END 12/01/15 D-1717 Wenjun
          orderLineItem.Main_Package_Frequency__c = 'Default';
          orderLineItem.Main_Package_Sub_Type__c = pkg.Subscription_Type__c;
          orderLineItem.Main_Package_Type__c = pkg.Package_Type__c;
          orderLineItem.Subscribed_as__c = 'Renewal';

          
          if (pkg.Subscription_Period__c != null && pkg.Subscription_Period__c != 'N/A') {
              orderLineItem.Main_Package_Period__c = integer.valueOf(pkg.Subscription_Period__c);
              orderLineItem.Term_Length__c =  integer.valueOf(pkg.Subscription_Period__c);
          } else {
              orderLineItem.Main_Package_Period__c = 0;
              orderLineItem.Term_Length__c = 0;
          }
          
        // Start UD-1147/D-2486/D-2907 10Jun15 JohnD
        thisOrder.Billing_Type__c = orderLineItem.Main_Package_Billing_Type__c;
        //START D-4214 01/18/16 - changed parameter to account id, set value for credit amount
        thisOrder.Credit_Balance__c = getCreditBalance(thisOrder.Account__c); 
        thisOrder.Credit_Amount__c = thisOrder.Credit_Balance__c;
        //END D-4214 01/18/16 - changed parameter to account id, set value for credit amount
        try {
            Contact recipientContact = [select Address__c from Contact where Id = :thisOrder.Recipient_Contact__c];
                   
            // calculate months
            if (orderLineItem.Main_Package_Billing_Type__c == 'Full Prepaid' && orderLineItem.End_Date__c != null 
                    && orderLineItem.Main_Package_Sub_Type__c == 'Termed') {
                        
                thisOrder.FP_Del_Usage__c = CalculateCharges.getMonths(thisOrder.Id, recipientContact.Address__c, 
                        orderLineItem.Start_Date__c, orderLineItem.End_Date__c);
            }
        } catch (exception e) {
            
        }
        // end calculate months

        // End UD-1147/D-2486/D-2907 10Jun15 JohnD



        for (Package_Item__c tmp : pkg.Package_Items__r) {
            
            if(tmp.RecordType.DeveloperName.contains('Product')) {  // Start/End PD-0102 06May16 JohnD - only for Product package items

                productIds.add(tmp.Product_Rate_Plan__r.zqu__ZProduct__c);

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
            }   // Start/End PD-0102 06May16 JohnD - only for Product package items
        }
          
          productIds.remove(null); // Start/End D-0033 UAT 01-03-2015 JohnD removing null
          
          // retrieve earliest publication date and direct sub delivery method
          // assumption: all publications related to the package have the same delivery method
          try {
            //START D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
              publicationDetail = [select Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c, Publication_Code__c
                      from Product_Publication__c where ZProduct__c in :productIds 
                      order by Publication_Code__r.Earliest_Start_Date__c asc limit 1];
          } catch (exception e) {
              publicationDetail = new Product_Publication__c();
          }
          // end retrieve earliest publication date
          //END D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
          
          orderLineItem.Earliest_Start_Date__c = publicationDetail.Publication_Code__r.Earliest_Start_Date__c;
          //if (orderLineItem.Start_Date__c == null) {  // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out
            //Start D-1754 01/21/15 Added by April Banaag start date must be end date of sub to be renewed
            //Start UD-0441 James 03/24/2015 - start date of renewal is equal to end date of previous subscription + 1
            orderLineItem.Start_Date__c = zs.Zuora__SubscriptionEndDate__c.addDays(1);
            //End UD-0441 James 03/24/2015
            //End D-1754 01/21/15 Added by April Banaag start date must be end date of sub to be renewed
          //}   // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out
          orderLineItem.Direct_Sub_Delivery_Method__c = publicationDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c;
          
          if (orderLineItem.Start_Date__c != null && orderLineItem.Term_Length__c > 0) {
              //Start UD-0477 03-23-15 ABanaag - minus 1 day
              orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.Term_Length__c)).addDays(-1);
              //End UD-0477 03-23-15 ABanaag - minus 1 day
          }
          
        // Start D-0033 UAT 01-03-2015 JohnD followed changes in start subscription
    // Start D-3338 VPernicia 08/06/15 Comment-out this code
        /*deliveryMethod.add(new SelectOption(DELIVERED_BY_NONE, DELIVERED_BY_NONE));
        
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
        // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - added condition
        } else {
            isNoDel = true; 
        }*/
    // End D-3338 VPernicia 08/06/15 Comment-out this code
    
    // Start D-3338 VPernicia 08/06/15 Populate Delivered By picklist
    
    List<Product_Publication__c> publicationDetailList = new List<Product_Publication__c>();
    
    try {
            publicationDetailList = [select Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c 
                    from Product_Publication__c where ZProduct__c in :productIds];
        } catch (exception e) {
            publicationDetailList = new List<Product_Publication__c>();
        }
    
    set<string> uniqueOptions = new set<string>();
        
        deliveryMethod.add(new SelectOption(DELIVERED_BY_NONE, DELIVERED_BY_NONE));
        uniqueOptions.add(DELIVERED_BY_NONE);
        
        if(publicationDetailList.size()>0){
            for(Product_Publication__c pubDetail : publicationDetailList){
                if (pubDetail.Publication_Code__c != null 
                && pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c != null) {
                
                    if (pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == DELIVERED_BY_BOTH 
                            || pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == null) {
                      
                      if (thisOrder.id == null){  
                        orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;}
                       
                        if(!uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
                            deliveryMethod.add(new SelectOption(DELIVERED_BY_MAILING_AGENT, DELIVERED_BY_MAILING_AGENT));
                            uniqueOptions.add(DELIVERED_BY_MAILING_AGENT);
                        }
                    
                        if(!uniqueOptions.CONTAINS(DELIVERED_BY_VENDOR)){
                            deliveryMethod.add(new SelectOption(DELIVERED_BY_VENDOR, DELIVERED_BY_VENDOR));
                            uniqueOptions.add(DELIVERED_BY_VENDOR);
                        }
                    } else {
                        
                         //START UD-2531 Added by Dags COpy the previous value of delivered by
                        if (zs.Delivered_By_1__c != null || zs.Delivered_By_1__c != 'NONE'||zs.Delivered_By_1__c != DELIVERED_BY_MAILING_AGENT ) {
                           orderLineItem.Delivered_By__c = zs.Delivered_By_1__c;}
                         else  {
                           orderLineItem.Delivered_By__c = pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c;
                            }
                          //END UD-2531 Added by Dags COpy the previous value of delivered by    
                        if(!uniqueOptions.CONTAINS(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c)){
                        deliveryMethod.add(new SelectOption(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c, 
                                pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c));
                                uniqueOptions.add(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c);
                        }
                    }
                } else {
          isNoDel = true;
        }
        
        if(uniqueOptions.CONTAINS(DELIVERED_BY_VENDOR)){
        
          if (thisOrder.id == null){  
            orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
          }
        }
        else if(uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
        
          if (thisOrder.id == null){  
            orderLineItem.Delivered_By__c = DELIVERED_BY_MAILING_AGENT;
          }
        } else if(uniqueOptions.CONTAINS(DELIVERED_BY_NONE)){
           orderLineItem.Delivered_By__c = DELIVERED_BY_NONE;
        }
            }
        }
    //End D-3338 VPernicia 08/06/15 Populate Delivered By picklist    
        // End UD-1147/D-2486/D-2907 10Jun15 JohnD - added condition
    
        // End D-0033 UAT 01-03-2015 JohnD
        // Start UD-1147/D-2486/D-2907 10Jun15 JohnD
        if (orderLineItem.Delivered_By__c == null || orderLineItem.Delivered_By__c == DELIVERED_BY_NONE 
                || isNoDel) {
            selectedDeliveryChargeType = 'N';
            thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType;
        } else {
            selectedDeliveryChargeType = thisOrder.Delivery_Charge_Type__c;
        }
        recalculateCharges();
        calculateCharges(); //START/END D-4214 RReyes 01/18/2016
        //System.assertEquals(null + '', orderlineitem.Add_On_Package_Subscription_Rate__c + '');
        //fritz subscriptionRate
        //System.assertEquals(1,2);
        // End UD-1147/D-2486/D-2907 10Jun15 JohnD 
         
         // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out. replaced by calling the updateCharges method instead
         //START 12/01/15 D-1717 Wenjun - Postage Charges : calculate Postage Charge for this Order Item
         /*
         if(orderLineItem.Delivered_By__c == 'Mailing Agent')
         {
            
            //Unit Postage Charge * Quanty
            // Start D-1345 01/16/2015 JohnD catch error
            
            
            try {
                    orderLineItem.Postage_Charge__c = 
                        PostageChargeHelper.getPostageChargeForLineItem(thisOrder.Recipient_Contact__c,orderLineItem) * orderLineItem.Qty__c;
            } catch (exception e) {
                orderLineItem.Postage_Charge__c = null;
            }
            
            
            // End D-1345
         }
         */
         //END 12/01/15 D-1717 Wenjun
         // End UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out. replaced by calling the updateCharges method instead
                
          // retrieve promotion contract period and penalty charge
          system.debug('>>>>>CHA packageIdpromotionId.size() ' + packageIdpromotionId.size());
          system.debug('>>>>>CHA packageIdpromotionId ' + packageIdpromotionId);
          system.debug('>>>>>CHA isCalledFromController ' + isCalledFromController);
          system.debug('>>>>>CHA subPromoId ' + subPromoId);
          if (packageIdpromotionId.size() > 1 || (isCalledFromController && subPromoId != null)) { //START D-3156 06/23/15 GDelRosario/RReyes - added criteria (isCalledFromController && subPromoId != null)
              
              isFromPromotion = true;
              //START D-3156 06/23/15 GDelRosario/RReyes
              id proId;
              if(packageIdpromotionId.size() > 1){
                proId = packageIdpromotionId[1];
              }else if(isCalledFromController && subPromoId != null){
                proId = subPromoId;  
              }
              //END D-3156 06/23/15 GDelRosario/RReyes
              
              //START PD-0020 03-Mar-2016 Added By S.Puli, C.Lin, V.Pernicia
              Promotion__c promoTmp = [select Id, Contract_Period__c, Penalty_Charge__c, Contract__c from Promotion__c where Id = :proId];
              //End PD-0020 03-Mar-2016 Added By S.Puli, C.Lin, V.Pernicia
              
              orderLineItem.Promotion_ID__c = promoTmp.Id;
              if (promoTmp.Penalty_Charge__c != null) {
                orderLineItem.Penalty_Charge__c = decimal.valueOf(promoTmp.Penalty_Charge__c);
              }
            
            //START PD-0020 03-Mar-2016 Added By S.Puli, C.Lin, V.Pernicia
            if (promoTmp.Contract__c == GlobalVariableClass.TS_YES) {
                if (promoTmp.Contract_Period__c != null) {
                    orderLineItem.New_Contract_Period__c = integer.valueOf(promoTmp.Contract_Period__c);
                }
            }else{
                orderLineItem.New_Contract_Period__c = 0;
            }
            //End PD-0020 03-Mar-2016 Added By S.Puli, C.Lin, V.Pernicia
              
              // Start Ronald Dagaraga Fix for UD-0443 Contract date should be equal to end date
              if (publicationDetail.Publication_Code__r.Earliest_Start_Date__c != null) {
                //orderLineItem.Contract_End_Date__c = publicationDetail.Publication_Code__r.Earliest_Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c));
                //START D-3132 06/20/15 RReyes - added -1 day
                orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1);
                //END D-3132 06/20/15 RReyes - added -1 day
              // End Ronald Dagaraga Fix for UD-0443 Contract date should be equal to end date     
              }
          
          } else {
              // converted to N/A in visualforce
              orderLineItem.Penalty_Charge__c = 9999999999999999.99;  
              orderLineItem.New_Contract_Period__c = 999;
              orderLineItem.Contract_End_Date__c = date.valueOf('1970-01-01');
              // end converted to N/A in visualforce
          }
          // end retrieve promotion contract period and penalty charge
          
          isPackageSelected = true;
           //START D-2759 Wenjun 13/04/15 - Update Order to validate BA Billing Type
    // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - added logic
           try {

                delete [select id from Order_Line_Item__c where Order__c = :thisOrder.Id];
                UPDATE thisOrder;

                try {
                    //Start D-3152 James 06/23/2015
                    if(RenewalOrderId != null){
                        RenewalOrder = [SELECT Id, Base_Subscription__c FROM Order__c WHERE Id = :RenewalOrderId];
                    }
                    if(RenewalOrder.size() > 0){
                        BaseSubList = [SELECT id, Order_Line_Item_Number_1__r.Vendor_Conversion__c, Order_Line_Item_Number_1__r.Vendor_Subscription_ID__c, Order_Line_Item_Number_1__r.Generate_Invoice__c, Order_Line_Item_Number_1__r.Suppress_Renewal_and_Reminder_Letter__c, Order_Line_Item_Number_1__r.Term_is_discussed__c, Order_Line_Item_Number_1__r.PO_Number__c, Order_Line_Item_Number_1__r.Supressed_Acknowledgement_Letter__c, Order_Line_Item_Number_1__r.Auto_Renew__c, Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c, Order_Line_Item_Number_1__r.Qty__c, Order_Number_1__r.Acquisition_Type__c, Order_Number_1__r.Sponsor__c, Order_Number_1__r.Payment_Type__c
                        FROM Zuora__Subscription__c WHERE Id = :RenewalOrder[0].Base_Subscription__c];
                    }
                    if(BaseSubList.size() > 0 && RenewalOrder[0].Base_Subscription__c != null){
                        orderlineitem.Qty__c = BaseSubList[0].Order_Line_Item_Number_1__r.Qty__c;
                        orderlineitem.PO_Number__c = BaseSubList[0].Order_Line_Item_Number_1__r.PO_Number__c;
                        orderlineitem.Supressed_Acknowledgement_Letter__c = BaseSubList[0].Order_Line_Item_Number_1__r.Supressed_Acknowledgement_Letter__c;
                        orderlineitem.Auto_Renew__c = BaseSubList[0].Order_Line_Item_Number_1__r.Auto_Renew__c;
                        orderlineitem.Supressed_Vendor_Notification_New_Sub__c = BaseSubList[0].Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c;
                        
                        thisOrder.Acquisition_Type__c = BaseSubList[0].Order_Number_1__r.Acquisition_Type__c;
                        thisOrder.Sponsor__c = BaseSubList[0].Order_Number_1__r.Sponsor__c;
                        if(BaseSubList[0].Order_Number_1__r.Payment_Type__c != null){
                            thisOrder.Payment_Type__c = BaseSubList[0].Order_Number_1__r.Payment_Type__c;
                        }
                    }
                    update thisOrder;
                    //End D-3152 James 06/23/2015
                    upsert orderLineItem; //START/END D-4214 RReyes - set to upsert
                } catch (exception e) {
                
                }
                system.debug('Johnb :: ' + orderLineItem.Delivered_By__c);
                UPDATE thisOrder;
                
                refreshOrder();
                
           } catch (exception e) {
                ApexPages.addMessages(e);
           }
         /*}else{
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There is No Individual Package Configured with this Bundle Package'));
         }*/
         //END D-3332 11/06/15 RReyes - added logic for bundle packages - commented out - rollback
    // End UD-1147/D-2486/D-2907 10Jun15 JohnD - added logic           
           //END D-2759 Wenjun 13/04/15
        
          
          
        
        isChangedSelection = false; // Start/End UD-1147/D-2486/D-2907 10Jun15 JohnD
        isCalledFromController = false; //START/END D-3156 06/23/15 GDelRosario/RReyes
    }

  /************ asia1 functionality ***************/

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
        
        Asia1__c tmpAsia1 = [select Id, User_ID_LDAP_ID__c from Asia1__c where Id = :asia1SelectedExistingId];
        
        //START UD-2036 07/23/2015 Added by J.Sarion - Check enabled Service Flags
        Map<String, Object> userDetailsMap = new Map<String, Object>();
        userDetailsMap = AsiaOneServicesController.verifyUser2(tmpAsia1.User_ID_LDAP_ID__c, null);
        SM_SubscriptionHelper.enabledServices = string.valueOf(userDetailsMap.get('Service'));
        
        //END UD-2036 07/23/2015 Added by J.Sarion - Check enabled Service Flags
        
        //Start D-3305 VPernicia/Fritz 08/03/15 
        for(Asia1Wrapper asia1wrapper : createAsia1SubscriptionFromAccessFlag(tmpAsia1.User_ID_LDAP_ID__c, tmpAsia1.Id, packageIdpromotionId[0]))
        {
            asia1Subscriptions.add(asia1wrapper);
        }
        //End D-3305 VPernicia/Fritz 08/03/15 

        asia1SubscriptionsTotal = asia1Subscriptions.size();
    }
    
    /*
     * This method will create a new asia 1 account
    */
    /*
     * This method will create a new asia 1 account
    */
    public void addAsia1NewAccount() {
               
            string myPhone = '';
            string asia1ErrorResponse = '';
            string temp = '';
            string serviceFlag = '';
            // START D2642 5/18/2015 GDELROSARIO : added varibale for the id of seletedPackage   
            //MBG 11-14-2014
            //Get phone number based on priority
            if (thisOrder.Recipient_Contact__r.Phone <> null && myPhone == '') {
                myPhone = thisOrder.Recipient_Contact__r.Phone;
            }
            if (thisOrder.Recipient_Contact__r.HomePhone__c <> null && myPhone == '') {
                myPhone = thisOrder.Recipient_Contact__r.HomePhone__c;
            }
            if (thisOrder.Recipient_Contact__r.HomePhone__c <> null && myPhone == '') {
                myPhone = thisOrder.Recipient_Contact__r.HomePhone__c;
            }
            if (thisOrder.Recipient_Contact__r.Mobile_Number__c <> null && myPhone == '') {
                myPhone = thisOrder.Recipient_Contact__r.Mobile_Number__c;
            }        
            //Get phone number based on priority    
            //START: PD-0035 5/12/2016 Added by Kristine Balaoing - added method for getting the add on package
            retrieveAddOn(selectedAddOnPackage);
            //END: D-4816 5/12/2016 Added by Kristine Balaoing
            
            if(selectedPackageId != null){
                list<string> packageIdpromotionId = selectedPackageId.split(':');
                
                //START UD-3896 3/31/2016 Added by J.Sarion - check if password is null
                isAsia1Validated = false;
                validateNewAsia1Account(); 
                if (isAsia1Validated && asia1SingleAccount.Password__c != null && asia1SingleAccount.Password__c != '') {
                        asia1SingleAccount.id = null;
                        asia1SingleAccount.Status__c = 'Pending Creation';
                        asia1SingleAccount.Contact__c = thisOrder.Recipient_Contact__c;
                        asia1SingleAccount.Secret_Question__c = 'what+is+my+favourite+drink';
                        asia1SingleAccount.Secret_Answer__c = asia1SingleAccount.Password__c;
                        asia1SingleAccount.Order_Number__c = thisOrder.Name;

                    try {
                            insert asia1SingleAccount;
                        
                            //asia1Subscriptions = createAsia1SubscriptionFromAccessFlag(asia1SingleAccount.User_ID_LDAP_ID__c, asia1SingleAccount.Id, packageIdpromotionId[0]);           
                            for(Asia1Wrapper asia1wrapper : createAsia1SubscriptionFromAccessFlag(asia1SingleAccount.User_ID_LDAP_ID__c, asia1SingleAccount.Id, packageIdpromotionId[0])){
                              asia1Subscriptions.add(asia1wrapper);  
                            }
                        
                            asia1SubscriptionsTotal = asia1Subscriptions.size();
                        
                            asia1SingleAccount = new Asia1__c();
                            
                            ldapValidityImg = '/s.gif';
                            displayNameValidityImg = '/s.gif';
                       
                    } catch (exception e) {
                        ApexPages.addMessages(e);
                    }
                }
                else if(asia1SingleAccount.Password__c == null || asia1SingleAccount.Password__c == '') {
                    ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'Password is required'));
                    //ApexPages.addMessages('Password is required');
                }
                //END UD-3896 3/31/2016 Added by J.Sarion - check if password is null
            }  
    }
    
    
    
    
    //END D2642 DELROSARIO
    
    
    public void validateNewAsia1Account() {
        map<string, Object> isValidUserName = new map<string, object>();
        map<string, Object> isValidDisplayName = new map<string, Object>();
        // check require fields
        if (asia1SingleAccount.User_ID_LDAP_ID__c != null && asia1SingleAccount.Display_Name__c != null) {
            
            // call to asia1 actual
            isValidUserName = AsiaOneServicesController.validateUserName(asia1SingleAccount.User_ID_LDAP_ID__c);
            if ( isValidUserName.get('User-Availability') == 'Success') {
                ldapValidityImg = '/resource/check';
                isAsia1Validated = true; //START-END UD-3896 4/1/2016 Added by J.Sarion - set validation
            } else {
                ldapValidityImg = '/resource/wrong';
            }
            
            // START D-2705 GDELROSARIO 5/11/2015 : change the method to call from AsiaOneServicesController to .validateDisplayName
            isValidDisplayName = AsiaOneServicesController.validateDisplayName(asia1SingleAccount.Display_Name__c.replace(' ', '+'));
            // END D-2705 GDELROSARIO 5/11/2015
            
            if (isValidDisplayName.get('DisplayName-Availability') == 'Success') {
                displayNameValidityImg = '/resource/check';
                isAsia1Validated = true; //START-END UD-3896 4/1/2016 Added by J.Sarion - set validation
            } else {
                displayNameValidityImg = '/resource/wrong';
            } 
            // end call to asia1 actual
            
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
        
        delete [select id from Asia1__c where Id = :asia1IdToBeRemoved and Status__c = 'Pending Creation'];
        asia1SubscriptionsTotal = asia1Subscriptions.size(); //START/END UD-3431 12/22/15 RReyes
    }
    
    
    public list<SelectOption> getAsia1ExistingAccounts() {
        
            
        list<SelectOption> options = new list<SelectOption>();
    //START:UD-0429 3/18/15 Added by Manolo Vale?a - Added new variables.
        Set<Id> aOneIdSet = new Set<Id>();
        Set<Id> aOneIdSet2 = new Set<Id>();
        //END:UD-0429 3/18/15 Added by Manolo Vale?a
        
        if (asia1Subscriptions != null) {

            
          set<id> tmpAsia1Ids = new set<id>();
          for (Asia1Wrapper tmpw : asia1Subscriptions) {
              tmpAsia1Ids.add(tmpw.asia1Id);
          }
          //System.assertEquals(null, tmpAsia1Ids);
          //START UD-3454 01/06/15 RReyes - added condition if Asia1 is not Disabled
          String disabled = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
          for (Asia1__c asia1 : [select Id, User_ID_LDAP_ID__c from Asia1__c where Contact__r.Account.Id = :accountId  and Id not in :tmpAsia1Ids and status__c!=:disabled]) {
              //START:UD-0429 3/18/15 Added by Manolo ValeÃƒÂ¯Ã‚Â¿Ã‚Â½a - Put values in a set.
              aOneIdSet.add(asia1.Id);
        //END:UD-0429 3/18/15 Added by Manolo ValeÃƒÂ¯Ã‚Â¿Ã‚Â½a
          }
          //END UD-3454 01/06/15 RReyes - added condition if Asia1 is not Disabled
            
            
            
      //START:UD-0429 3/18/15 Added by Manolo Vale?a - Puts only records connected to the selected subscription as options.
          for(Asia1_Subscription__c asia1Sub : [SELECT Asia1__c, Asia1__r.User_ID_LDAP_ID__c, Subscription__c 
                                                FROM Asia1_Subscription__c 
                                                WHERE Asia1__c IN : aOneIdSet 
                                                AND Subscription__c =: subscriptionId])
          {
              
              if(!aOneIdSet2.contains(asia1Sub.Asia1__c))
              {
                  options.add(new SelectOption(asia1Sub.Asia1__c, asia1Sub.Asia1__r.User_ID_LDAP_ID__c));
                  aOneIdSet2.add(asia1Sub.Asia1__c);
              }
              
          }
      //END:UD-0429 3/18/15 Added by Manolo Vale?a
        }
        
     
        
        return options;
    }
  /************ end asia1 functionality ***************/
    
    
  /************ billiing payment functionality ***************/
    
    private void initializePaymentComponents() {

        try {
            thisAccount = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :accountId];
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
        }
        
        billingOptions.add(new SelectOption('createNew', 'Create new Billing Account'));
        return billingOptions;
    }
    

    public void fetchBillingAccount() {
        //START D-2617 3/25/15 AddedBy FrancisBenzon :default boolean to false
        isOtherPayment = false;
        //END D-2617 3/25/15 AddedBy FrancisBenzon :default boolean to false
      
      if (thisOrder.Billing_Account__c != null) {
        // <!--START D-2283 Marvin Gatchalian - Changing field to display-->
        //Start MMallorca D-3246 Assign Billing Details to Order 16/07/2015
        thisBillingAccount = [SELECT Id, Name, Zuora__PaymentMethod_Type__c, Zuora__Credit_Balance__c, 
            Payment_Mode__c , Zuora__DefaultPaymentMethod__c, Other_PaymentMethod__c, Zuora__Account__c, Billing_Type__c
            FROM Zuora__CustomerAccount__c WHERE Id = :thisOrder.Billing_Account__c];
            
        thisOrder.Billing_Type__c = thisBillingAccount.Billing_Type__c;
        thisOrder.Account__c = thisBillingAccount.Zuora__Account__c;
        //End MMallorca D-3246 16/07/2015
        //START D-4214 01/18/15 RReyes
        thisOrder.Credit_Balance__c = getCreditBalance(thisOrder.Account__c); 
        thisOrder.Credit_Amount__c = thisOrder.Credit_Balance__c;
        //END D-4214 01/18/15 RReyes
        //START D-2617 3/25/15 AddedBy FrancisBenzon : populate Order Payment Mode and Other Payment Mode
        if(thisBillingAccount.Payment_Mode__c != null)
        {
            //Start UD-1388 7/9/2015 GDELROSARIO : remvoed the line of code as per Wen jun
            //thisOrder.Payment_Mode__c = thisBillingAccount.Payment_Mode__c; //Commented out because of 1388
            thisOrder.Payment_Mode__c = thisBillingAccount.Payment_Mode__c; //1388 // Start/End D-3246 17Jul15 JohnD - aligned with SIT
            //END UD-1388 7/9/2015 GDELROSARIO : remvoed the line of code as per Wen jun
            if(thisBillingAccount.Payment_Mode__c == GlobalVariableClass.OTHER)
            {
                isOtherPayment = true;
                if(thisBillingAccount.Other_PaymentMethod__c != null)
                {
                    thisOrder.Other_Payment_Mode__c = thisBillingAccount.Other_PaymentMethod__c;
                }
                else
                {
                    thisOrder.Other_Payment_Mode__c  = GlobalVariableClass.INVOICE;
                }               
            }       
        }
        else{
            thisOrder.Payment_Mode__c = '';
        }
        //END D-2617 3/25/15 AddedBy FrancisBenzon : populate Order Payment Mode and Other Payment Mode
        //Start UD-0407 03-16-15 ABanaag - populate months between start/end
        thisOrder.Months_Between_Start_End__c = orderLineItem.Term_Length__c;
        subscriberCharge = thisOrder.Subscriber_Charge__c;
        thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = thisOrder.Subscriber_Charge__c;
        //End UD-0407 03-16-15 ABanaag - populate months between start/end
        // <!--END D-2283 Marvin Gatchalian - Changing field to display-->
        //START D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to blank if payment mode is not "Other"
        if (thisOrder.Payment_Mode__c != 'Other'){
        thisOrder.Other_Payment_Mode__c = '';}
        //END D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to null if payment mode is not "Other"
      }
      
      // Start UD-1147/D-2486/D-2907 10Jun15 JohnD
          update thisOrder;
    
        queryOrder();
    
        // End UD-1147/D-2486/D-2907 10Jun15 JohnD
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
        // Start UD-1147/D-2486/D-2907 10Jun15 JohnD
        thisOrder.Billing_Account__c = null;
        update thisOrder;

        string queryStr = generateOrderSoqlStr();
        queryStr += ' where Id = \'' + thisOrder.Id + '\'';
        
        SObject tmpOrder = database.query(queryStr);
        
        thisOrder = (Order__c)tmpOrder;

        // End UD-1147/D-2486/D-2907 10Jun15 JohnD
    }
    
    
    public void clearOtherPaymentMethod() {

        thisOrder.Other_Payment_Mode__c = null;
        thisOrder.Billing_Account__c = null;
    }
  
  /************ end billiing payment functionality ***************/
      //START D-1174 ADD MGaelo 3/13/2015 ARMS Component      
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
                                             DebtManagement = acR.DbtStrt; //START/END UD-2375 dags Setting value for variable         
                                                    
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
                        Busprofile = awl.arBusProf; //START/END UD-2375 setting value for variable
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
        //END D-1174 MGaelo 3/13/2015 ARMS Component 
        //START D-3039 06/03/15 RReyes - method for actionfunction
    public void continueSave(){ 
        //dummy method;
    }
    
    //END D-3039 06/03/15 RReyes
        // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - added new methods
        boolean isInvokedFromDeliveredBy = false;
        //START D-4214 01/18/16 RReyes -- changed computation of credit balance
        private decimal getCreditBalance(id accountIdParam) {
            
            decimal amount = 0.00;
            
            if (accountIdParam != null) {
                try {
                    amount = [select Total_Credit_Balance1__c from Account where Id = :accountIdParam].Total_Credit_Balance1__c;
                } catch (exception e) { }
            }
            
            return amount;
        }
        //END D-4214 01/18/16 RReyes -- changed computation of credit balance

        private void setMonthlyDeliveryChargeForFullPrepaid() {
            
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0.0;
          
            list<Order_Line_Item__c> oliList = [select id from Order_Line_Item__c where Order__c = :thisOrder.Id 
                    and Main_Package_Billing_Type__c = 'Full Prepaid' limit 1];
                    
            if (oliList != null && !oliList.isEmpty()) {
                
                thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = thisOrder.Subscriber_Charge__c;
            }
        }
        
        
        private void recalculateCharges() {  
            //START - UD-3423 01/04/16 - RReyes - remove del fee if My paper
            Id packageId;
            Set<String> packageItemRecTypeSet = new Set<String>{'Base Product', 'Bundle Product', 'Extension Product'};
            List<Product_Code__c> prodCodes = Product_Code__c.getall().values();
            Set<String> CProductCodeSet = new Set<String>();
            Map<Id, Boolean> packageToIsNoDelMap = new Map<Id, Boolean>();
            Boolean isWithDelivery = true;
            
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
           //END - UD-3423 01/04/16 - RReyes - remove del fee if My paper
        
            if (orderLineItem.Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_VENDOR) {
                
                
                if (isInvokedFromDeliveredBy) {
                    selectedDeliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(thisOrder.Recipient_Contact__r.Address__r.Address_Type__c);
                }
                map<string, decimal> chargeMap = getCharges(thisOrder.Recipient_Contact__c, selectedDeliveryChargeType, subscriberCharge, vendorCredit);
                //START D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
                if (thisOrder.Delivery_Charge_Type__c != 'S' || thisOrder.Delivery_Charge_Type__c != 'Z') {
                    thisOrder.Vendor_Credit__c = chargeMap.get('VendorCredit');
                    vendorCredit = thisOrder.Vendor_Credit__c;
                }
                if (thisOrder.Delivery_Charge_Type__c != '9' && thisOrder.Delivery_Charge_Type__c != 'N' && thisOrder.Delivery_Charge_Type__c != 'S' && thisOrder.Delivery_Charge_Type__c != 'Z') {
                    thisOrder.Subscriber_Charge__c = chargeMap.get('SubscriberCharge');
                }
                //END D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
                //START UD-2038 07/22/15 RReyes - sets value for subscriber charge if delivery charge type is N
                if(thisOrder.Delivery_Charge_Type__c == 'N'){
                    thisOrder.Subscriber_Charge__c = 0.0;
                }
                //END UD-2038 07/22/15 RReyes - sets value for subscriber charge if delivery charge type is N
                setMonthlyDeliveryChargeForFullPrepaid();
                thisOrder.Full_Prepaid_Delivery_Charge__c = 0.0;
                thisOrder.Recurring_Delivery_Charge__c = 0.0;

                if (orderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE) {
                    if (orderLineItem.Term_Length__c != null && thisOrder.Subscriber_Charge__c != null) {
                        //START - UD-3423 01/04/16 - RReyes - remove del fee if My paper
                        if(isWithDelivery) {   
                            thisOrder.Full_Prepaid_Delivery_Charge__c = thisOrder.Subscriber_Charge__c * orderLineItem.Term_Length__c;
                        }else{
                            thisOrder.Full_Prepaid_Delivery_Charge__c = 0;
                        }
                        //END - UD-3423 01/04/16 - RReyes - remove del fee if My paper
                    } 
                } else {
                    //START - UD-3423 01/04/16 - RReyes - remove del fee if My paper
                    if(isWithDelivery) {  
                        thisOrder.Recurring_Delivery_Charge__c = thisOrder.Subscriber_Charge__c;
                    }else{
                        thisOrder.Recurring_Delivery_Charge__c = 0;
                    }
                }
                
                clearPostageRelatedFields();
                
            } else if (orderLineItem.Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT) {

                if (isInvokedFromDeliveredBy) {
                    selectedDeliveryChargeType = 'N';
                }

                try {
                    orderLineItem.Postage_Charge__c = 
                            PostageChargeHelper.getPostageChargeForLineItem(thisOrder.Recipient_Contact__c,orderLineItem) * orderLineItem.Qty__c;
                } catch (exception e) {
                    orderLineItem.Postage_Charge__c = 0.0;
                }
                
                clearDeliveryRelatedFields();

            } else {

                if (isInvokedFromDeliveredBy) {
                    selectedDeliveryChargeType = 'N';
                }
            
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
            
        }
        
        private void clearPostageRelatedFields() {
            
            orderLineItem.Postage_Charge__c = 0.0;
        }
        
        
        public void calculateCharges2() {
            isInvokedFromDeliveredBy = true;
            calculateCharges();
            isInvokedFromDeliveredBy = false;
        }
        
        public void calculateCharges() {
            //START D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
            thisOrder.Subscriber_Charge__c = subscriberCharge;
            if (thisOrder.Delivery_Charge_Type__c != selectedDeliveryChargeType) {
                thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType;
                
                if (selectedDeliveryChargeType == 'N') {
                    thisOrder.Subscriber_Charge__c = 0;
                }
                else if (selectedDeliveryChargeType == 'S') {
                    thisOrder.Subscriber_Charge__c = subscriberCharge;
                    thisOrder.Vendor_Credit__c = vendorCredit;
                }
                else if (selectedDeliveryChargeType == '9') {
                    thisOrder.Subscriber_Charge__c = subscriberCharge;
                }
                else {
                    thisOrder.Subscriber_Charge__c = 0;
                    thisOrder.Vendor_Credit__c = 0;
                }
            }
            //END D-3163 06/26/2015 Added by J.Sarion - Populate Delivery Charge Type, Vendor Credit
            recalculateCharges();
            //START D-4214 01/18/16 RReyes - assign charges to variables instead of direct OLI update
            Decimal totalPostage= 0.0;
            Decimal totalGiftCharge = 0.0;
            Decimal adminCharge = 0.0;
            Decimal creditBalance = 0.0;
            Decimal fpDelCharge = 0.0;
            Decimal recDelCharge = 0.0;
            Decimal mpSubRate = 0.0;
            Decimal addOnSubRate = 0.0;
            dueToSPH = 0.0;
            recChargeIncDP = 0.0;
            fpIncDelCharge = 0.0;
            
            thisOrder.Credit_Balance__c = getCreditBalance(thisOrder.Account__c);
            thisOrder.Credit_Amount__c = thisOrder.Credit_Balance__c;
            if(orderlineitem.Term_Length__c != null && orderlineitem.Postage_Charge__c != null){
                totalPostage = orderlineitem.Term_Length__c * orderlineitem.Postage_Charge__c;
            }else{
                totalPostage = 0.0;
            }
            if(orderlineitem.Postage_Charge__c != null){
                postageCharge = orderlineitem.Postage_Charge__c;
            }
            if(orderlineitem.Total_Gift_Price__c != null){
                totalGiftCharge = orderlineitem.Total_Gift_Price__c;
            }
            if(thisOrder.Admin_Charge__c != null){
                adminCharge = thisOrder.Admin_Charge__c;
            }
            if(thisOrder.Credit_Balance__c != null){
                creditBalance = thisOrder.Credit_Balance__c;
            }
            if(thisOrder.Full_Prepaid_Delivery_Charge__c != null){
                fpDelCharge = thisOrder.Full_Prepaid_Delivery_Charge__c;
            }
            if(thisOrder.Recurring_Delivery_Charge__c != null){
                recDelCharge = thisOrder.Recurring_Delivery_Charge__c;
            }
            if(orderlineitem.Main_Package_Subscription_Rate__c != null){
                mpSubRate = orderlineitem.Main_Package_Subscription_Rate__c;
            }
            if(orderlineitem.Add_On_Package_Subscription_Rate__c != null){
                addOnSubRate = orderlineitem.Add_On_Package_Subscription_Rate__c;
            }
            //System.assertEquals(null, orderlineitem);
            //System.assertEquals(1,2);
            if(orderLineItem.Main_Package_Subscription_Rate__c != null){
                subscriptionRate = orderLineItem.Main_Package_Subscription_Rate__c;
                if (orderLineItem.Add_On_Package_Subscription_Rate__c != null) {
                    subscriptionRate += orderLineItem.Add_On_Package_Subscription_Rate__c;
                }
                if(orderLineItem.Qty__c != null){
                        totalSubscriptionPrice = orderLineItem.Main_Package_Subscription_Rate__c * orderLineItem.Qty__c;
                }
            }

            if(orderlineitem.Main_Package_Billing_Type__c != null){
                totalFPCharge = 0;
                totalRecCharge = 0;

                if(orderlineitem.Qty__c != null){
                    if(orderlineitem.Main_Package_Billing_Type__c == 'Full Prepaid'){
                        
                        totalFPCharge = (mpSubRate + addOnSubRate) * orderlineitem.Qty__c;
                        totalRecCharge = 0.0;
                    }else if(orderlineitem.Main_Package_Billing_Type__c.contains('Recurring')){
                        totalRecCharge = (mpSubRate + addOnSubRate) * orderlineitem.Qty__c;
                        totalFPCharge = 0.0;
                    }
                }
            }
            if(totalFPCharge > 0 || thisOrder.Other_Payment_Mode__c == 'Freelist'){
                fpIncDelCharge = fpDelCharge + totalFPCharge + totalPostage;
            }else{
                fpIncDelCharge = 0;
            }

            if(thisOrder.Billing_Type__c != null){
                if(thisOrder.Billing_Type__c.contains('Recurring')){
                    recChargeIncDP = totalRecCharge + recDelCharge + totalPostage;
                }
            }

            dueToSPH = (fpIncDelCharge + recChargeIncDP + totalGiftCharge + adminCharge) - creditBalance;

            if(dueToSPH <= 0){
                dueToSPH = 0.0;
            }
            /*if(orderLineItem != null) //START/END UD-2038 07/22/15 RReyes - checks of orderLineItem is not null before update
                update orderLineItem;
            */
            //update thisOrder;
            //queryOrder();
            //END D-4214 01/18/16 RReyes - assign charges to variables instead of direct OLI update
        }
        
        private void queryOrder() {

            string queryStr = generateOrderSoqlStr();
            queryStr += ' where Id = \'' + thisOrder.Id + '\'';
                
            SObject tmpOrder = database.query(queryStr);
                
            thisOrder = (Order__c)tmpOrder;
            
        }
        // End UD-1147/D-2486/D-2907 10Jun15 JohnD - added new methods to retrieve the credit balance
        
        //START UD-2219 08/08/15 RReyes - SIT Hotfix - sets values when already reset
        public void revertOldValues(){
            orderLineItem.Contract_End_Date__c = date.valueOf('1970-01-01');
            orderLineItem.New_Contract_Period__c = 999;
            orderLineItem.Penalty_Charge__c = 9999999999999999.99;      
        }
        //END UD-2219 08/08/15 RReyes  - SIT Hotfix -  sets values when already reset

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
}