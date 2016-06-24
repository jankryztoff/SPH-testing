/**
 * Class Name: SM_StartSubscriptionEntryController
 * @author: john dacutan
 * Date: 09/29/2014
 * Requirement/Project Name: SPH Project
 * @description : this class is use as a controller for the renewal Edit page of SM_StartSubscriptionEntry visualforce page
 * 
 * History: 01/07/2015 Wenjun : Postage Charges
 * History: D-1689 01/22/2015 Wenjun
 * History: D-2067 02/03/2015 Joban
 * History: Code Review(Null in where clause causes full table scans - 100K Record Issue Limit) 16-Feb-2015 Raviteja
 * History: Duplicate ARMS ID change (1. Ability to associate 1 ARMS ID to more than 1 Billing Account (update to the ARMS interface and removal of validation from SFDC) ) 14-Apr-2015 Raviteja
*/
public class SM_StartSubscriptionEntryController extends SM_SubscriptionHelper {

    // Start D-2157 02/10/2015 JohnD constant declaration
    final static string ADDRESS_RECORD_TYPE_NAME_LOCAL = 'Contact_Recordtype_Local';
    final static string VENDOR = 'Vendor';
    final static string DELIVERED_BY_MAILING_AGENT = 'Mailing Agent';
    final static string DELIVERED_BY_NONE = 'None';
    final static string DELIVERED_BY_VENDOR = 'Vendor';
    final static string DELIVERED_BY_BOTH = 'Vendor or Mailing Agent';
    // End D-2157 02/10/2015
    //START D-2376 02/25/2015 JTeves - add acct rect type constant
    final static string ACCT_RECORD_TYPE_SPH_INTER_DIV = 'Account_Direct SPH Inter-Division';
    //END D-2376 02/25/2015 JTeves
    //start D-0070 03-12-2015 ABanaag
    set<string> uniqueOptions  = new set<string>();
    //end D-0070 03-12-15 ABanaag
    
    String BusProfile; //Start/End Dags UD-2375 - Variable Declaration
    String DebtManagement; //Start/End Dags UD-2375 - Variable Declaration

    id orderId;
    id accountId;
    string parentCaseId;
    string parentCaseId1;
    //START UD-0707 5/7/15 AddedBy FrancisBenzon : var for contact Id - URL param
    public Id thiscontactId {get; set;}
    //END UD-0707 5/7/15 AddedBy FrancisBenzon : var for contact Id - URL param
    
    //start UD-0333 03/11/15 ABanaag
    public boolean charityField {get;set;}
    public boolean withNonCharityOli {get;set;}
    //end UD-0333 03/11/15 ABanaag
    //START: D-4618 04/22/2016 Added by Kristine Balaoing - added variables
    public Id addOnId {get; set;}
    //END: D-4618 04/22/2016 Added by Kristine Balaoing
    //START UD-1317 06/08/2015 Added by J. Sarion - Recalculate charges
    //Boolean isFreelist = false; /* START END UD-2951 1/10/2015 Gdelrosario : remove the isFreelist */
    Map<Id, Decimal> pkgIdToMainPriceMap = new Map<Id, Decimal>();
    Map<Id, Decimal> pkgIdToAddOnPriceMap = new Map<Id, Decimal>();
    //START D-3105 06/15/2015 Remove line. Will not set Postage Charge to 0
    //Map<Id, Decimal> oliIdToPostageChargeMap = new Map<Id, Decimal>();
    //END D-3105 06/15/2015 Remove line. Will not set Postage Charge to 0
    //END UD-1317 06/08/2015 Added by J. Sarion - Recalculate charges
    

    //START UD-2281 8/7/15 AddedBy FrancisBenzon : variable for Delivered by when save as draft
    Map<Id, String> oliId_DeliveredBy = new Map<Id, String>();
    //END UD-2281 8/7/15 AddedBy FrancisBenzon : variable for Delivered by when save as draft
    //START D-3382 CCB-135 04/Aug/15 Wenjun: Mailing Agent Assignment  
    public List<SelectOption> airlineAgents { get; set; }
    public String selectedMailingAgent { get; set; }
    public Boolean chooseAgent { get; set; }
    //END D-3382 CCB-135 04/Aug/15 Wenjun
    //START: D-4618 04-19-2016 Added by Kristine Balaoing - added variables for implementing asia1 for add on packages
    public Boolean hasDigitalPackage;
    //END: D-4618 04-19-2016 Added by Kristine Balaoing
    
    //START PD-0271 6June2016 FrancisBenzon: display error but display all accounts
    public String errorMessageARMS8 {get;set;}
    //END PD-0271 6June2016 FrancisBenzon: display error but display all accounts
    
    public SM_StartSubscriptionEntryController(){
        //START UD-0219 04/29/15 RReyes - Checks if Edit
        orderId = ApexPages.currentPage().getParameters().get('id');
        //END UD-0219 04/29/15 RReyes - Checks if Edit
        //START D-1317 Wenjun 09/02/15 : using sObject Field instead
        //fullPrepaid = '$0.00';
        //END D-1317 Wenjun 09/02/15
        isContactQueried = false;
        //Start UD-0333 03-13-15 ABanaag
        charityField = false;
        withNonCharityOli = false;
        //End UD-0333 03-13-15 ABanaag
    }
    /*
    public SM_StartSubscriptionEntryController(){
        
        orderId = ApexPages.currentPage().getParameters().get('id');
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
        
        if (parentCaseId != null) {
            string tmp = parentCaseId;
            tmp.toLowerCase();
            if (tmp == 'null') {
                parentCaseId = null;
            }
        }
    }
    */
    public boolean isFromAccount {get; set;}
    public boolean isContactQueried {get; set;}
    public Map<Id, Contact> contactsMap {get; set;}
    public Boolean result {get; set;}
    public transient string orderLineItemIdToBeRemoved { get; set; }
    public list<Order_Line_Item__c> orderLineItemList { get; set; }
    public string selectedOrderLineItem { get; set; }
    public string selectedPromotionId { get; set; }
    public string selectedPackageId { get; set; }
    public string selectedDeliveryChargeType { get; set; }
    public integer totalBillingAccounts { get; set; }
    public string parentId {get; set;}
    public integer maxNoOfGifts {get; set;}   
    //Start UD-0593 03-27-15 - ABanaag
    public integer selectedGifts {get;set;}
    //End UD-0593 03-27-15 - ABanaag

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
    //START D-0043 02-24-2015 MBG
    public integer quantity { get; set; }
    //END D-0043 02-24-2015 MBG
    
    //START:D-1629 2/5/15 Added by Manolo Vale?a - Added variable created by Joban.
    public boolean vendorEligibilityCheck{ get; set; }
    //END:D-1629 2/5/15 Added by Manolo Vale?a
    
    // end search variables
    // Start D-1326 01/15/2015 JohnD variable declaration to be used in search
    string recipientAddressRecordTypeName;
    // End D-1326

    // subscription details variables
    public Order_Line_Item__c orderLineItem { get; set; }
    public transient string selectedPackageName { get; set; }
    public transient boolean isAllInOne { get; set; }
    public list<SelectOption> deliveryMethod { get; set; }
    public id recipientAddressId;
    public string recipientAddressType;
    public boolean isReInitializedItem { get; set; }
    //start D-1394 02/05/15 added by ABanaag
        public boolean productIsMagazine { get; set; }
    //end D-1394 02/05/15 added by ABanaag    
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
    public boolean isDigital { get; set; } //START/END UD-3305 8/6/15 AddedBy FrancisBenzon : removed transient as flag is always set either T or F
    //Start D-1318/D-2196 02/10/2015-02/12/2015 Added by ABanaag/JohnD 
    public transient boolean addOnIsDigital { get; set; }
    //End D-1318/D-2196 02/10/2015-02/12/2015         
    public transient boolean isFromPromotion { get; set; }  
    public transient boolean isNewsPaper {get; set;}
    public transient boolean isMagazine {get; set;}
    // Start UD-1958 20Jul15 JohnD - removed "transient" keyword
    public boolean isOrderContainsVendorDelivery { get; set; } // Start/End UD-1431 08Jul15 JohnD
    // End UD-1958 20Jul15 JohnD - removed "transient" keyword
    // end renderers
    
    //for Eligibility Rule
    public transient Map<String, Set<String>> promotionCodeMap {get; set;}
    
    //D-0891
    //public string getRecordType {get; set;}
    //public string getbillingRecordType {get; set;}
    public string RecipientRecType {get; set;}
    public string BillingRecType {get; set;}
    //START: 12/3/2014 Added/Modified By: FrancisBenzon CCB.002
    public string CustomerContactRecType {get; set;}
    //start D-2390 02/27/15 added by ABanaag
    public boolean isFullPrepaid {get;set;}
    public string termLength {get;set;}
    //start D-2390 02/27/15 added by ABanaag
    //START UD-0204 3/19/15 AddedBy FrancisBenzon : rerender other payment method if existing account used is Other
    public boolean isOtherPayment {get;set;}
   //END UD-0204 3/19/15 AddedBy FrancisBenzon : rerender other payment method if existing account used is Other
    //START UD-3278 20Nov15 AddedBy FrancisBenzon : var
    public boolean renderCheckDetails {get;set;}
    //END UD-3278 20Nov15 AddedBy FrancisBenzon : var
    public string getRecordType() {
        RecipientRecType = (ConstantsSLB.getKeyId('Contact_Customer Contact'));
        return RecipientRecType;
    }
    
    public string getbillingRecordType() {
        BillingRecType = (ConstantsSLB.getKeyId('Contact_Customer Contact'));      
        return BillingRecType;
    }
    //END: 12/3/2014 Added/Modified By: FrancisBenzon CCB.002
    
    //Start D-1307 01-30-2015 Francis Benzon : Variable
    public Decimal subscriptionRate{get; set;}
    //End D-1307 01-30-2015 Francis Benzon : Variable
    // Start  UD-0759 Ronald Dagaraga New variable
    public decimal totalSubscriptionPrice { get; set; }
    // End 17Apr15 UD-0759 Ronald Dagaraga New variable
    
    /**
    * @description : This method will be called to initialize / retrieve
    *       all necessary data to be used in vf page before loading
    */
    public void initialize() {
    //Start UD-0593 03-27-15 - ABanaag
        selectedGifts =0;
    //End UD-0593 03-27-15 - ABanaag
        
        orderId = ApexPages.currentPage().getParameters().get('id');
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
        //START UD-0707 5/7/15 AddedBy FrancisBenzon : contactId URL Param
        thiscontactId = ApexPages.currentPage().getParameters().get('contactId');
        //END UD-0707 5/7/15 AddedBy FrancisBenzon : contactId URL Param
                        
        if(accountId != null){
            isFromAccount = true;
        }
        else {
            isFromAccount = false;
        }       
        if(thisOrder != null){
            if(thisOrder.Account__c != null){
                thisOrder.Status__c = 'New'; // Start/End UD-0105 06-03-2015 JohnD set status to New
            }           
        }
       
        //START: MD-12 03/21/2015 Added By Jeffrey Teves - move initializePaymentComponents() method above checkAndCreateOrder()
        initializePaymentComponents();
        checkAndCreateOrder();
        orderLineItemIdToBeRemoved = '';
        
        orderLineItem = new Order_Line_Item__c();
        orderLineItem.Start_Date__c = date.today();
        //START D-3305 8/3/15 AddedBy FrancisBenzon : reordered for reinitializing Asia1 components
        initializeAsia1Components();        
        retrieveOrderLineItems();
        //END D-3305 8/3/15 AddedBy FrancisBenzon : reordered for reinitializing Asia1 components
        //END: MD-12 03/21/2015 Added By Jeffrey Teves
        promotionCode_isEligible = new map<string, boolean>();   
        promotionCodeMap = new Map<String, Set<String>>();  
        
        /* START  UD-2951 1/10/2015 Gdelrosario : remove the code block */
        //START UD-1317 06/08/2015 Added by J. Sarion - Recalculate charges
        //if (thisOrder.Other_Payment_Mode__c == 'Freelist')
        //    isFreelist = true;
        //END UD-1317 06/08/2015 Added by J. Sarion - Recalculate charges
        /*  END UD-2951 1/10/2015 Gdelrosario : remove the code block */
    }
    

   /* public PageReference redirectArticle(){
        PageReference ref = new PageReference('/knowledge/publishing/articlePreview.apexp?id=kA2N00000004CIb&popup=true&pubstatus=o&preview=true');
        return ref;
    }*/
    
   @TestVisible  private void reInitializeItem() { // TestVisible Added for test class K.Tan 4/13/12016 d-4671
        
        orderLineItem = new Order_Line_Item__c();
        //Start UD-0333 03-13-15 ABanaag
        charityField = false;
        //End UD-0333 03-13-15 ABanaag
        promotionGifts = new list<GiftWrapper>(); 
        asia1SingleAccount = new Asia1__c(); 
        asia1Subscriptions = new list<Asia1Wrapper>();
        isReInitializedItem = true;
    }
    
   
    private void checkAndCreateOrder() {
        
        list<SObject> orderList = new list<SObject>();
        
        string queryStr = generateOrderSoqlStr();
        queryStr += ' where Order_Type__c = \'Start\' and (Status__c = \'Draft\' or Status__c = \'New\')';
        
        if (accountId != null) {
                queryStr += ' and Account__c = \'' + accountId + '\'';
        }
        
        if (orderId != null) {
            queryStr += ' and Id = \'' + orderId + '\'';
        }
        
        if (accountId != null || orderId != null) {
            orderList = database.query(queryStr);
        }

        if (orderList.size() == 0) {
            
            thisOrder = new Order__c();
            thisOrder.Account__c = accountId;
            thisOrder.Status__c = 'New'; // Start/End UD-0105 06-03-2015 JohnD set status to New
            thisOrder.Order_Type__c = 'Start';
//START UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid
            thisOrder.Total_Full_Prepaid__c = 0.00;
//END UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid
            //START: MD-12 03/21/2015 Added By JTeves - Set Credit Balance to Account - Total Credit Balance
            thisOrder.Credit_Balance__c = thisAccount.Total_Credit_Balance1__c;
            //END: MD-12 03/21/2015 Added By JTeves
            thisOrder.Delivery_Charge__c = 0;           
            // START : D-1033 12/11/2014 Alyana Navarro - validation if field needed to be zero.
            if(thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c == null){            
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            }
            // END : D-1033 12/11/14
            thisOrder.Parent_Case__c = parentCaseId;
            //START UD-2941 09/25/15 RReyes - autopopulate contact when case is created from contact
            if(thiscontactId != null || thiscontactId != 'null')
            {                 
                thisOrder.Recipient_Contact__c = thiscontactId;
                recipientContactId = thiscontactId;
            }
            else
            {             
                recipientContactId = thisOrder.Recipient_Contact__c;
            }
            //END UD-2941 09/25/15 RReyes - autopopulate contact when case is created from contact
            try {
                if(accountId!=null){
                insert thisOrder;
                refreshOrder();
                }
            } catch (exception e) {
                ApexPages.addMessages(e);
            }
        
        } else {
            thisOrder = (Order__c)orderList[0] ;    
            thisOrder.Status__c = 'New'; // Start/End UD-0105 06-03-2015 JohnD set status to New
            
            //START UD-0707 5/7/15 AddedBy FrancisBenzon : autopopulate contact if Case created from Parent Case 
            //Start MMallorca UD-1274 05/26/2015 Retrieve the current recipient contact
            if(orderId != null){
            //START: UD-1427 6/4/2015 K. Tan - Add method to cater auto population of recipient contact
                retrieveSelectedRecipientContact();
            }
            //END: UD-1427 6/4/2015 K. Tan - Add method to cater auto population of recipient contact
            //START UD-2941 09/25/15 RReyes - autopopulate contact when case is created from contact
            else{
                if(thiscontactId != null || thiscontactId != 'null')
                {                 
                    thisOrder.Recipient_Contact__c = thiscontactId;
                    recipientContactId = thiscontactId;
                }
                else
                {             
                    recipientContactId = thisOrder.Recipient_Contact__c;
                }
            } 
            //END UD-2941 09/25/15 RReyes - autopopulate contact when case is created from contact          
                        
            //End MMallorca UD-1274 05/26/2015
            //END UD-0707 5/7/15 AddedBy FrancisBenzon : autopopulate contact if Case created from Parent Case 
            //END 
            // Start D-2196 02/11/2015 JohnD variable assignment
            recipientAddressRecordTypeName = thisOrder.Recipient_Contact__r.Address__r.RecordType.Name;
            // End D-2196 02/11/2015 JohnD
            
            //START:D-3461 10/27/2015 Added by Manolo Valena
            if(orderId != null && thisOrder.Recipient_Contact__r.Address__r.RecordType.Name == GlobalVariableClass.STRING_AIRLINE) {    
                for(Order_Line_Item__c oliRec : [SELECT Vendor_Mailing_Agent__c FROM Order_Line_Item__c WHERE Order__c =: orderId AND Delivered_By__c =: GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT LIMIT 1]) {
                    selectedMailingAgent = oliRec.Vendor_Mailing_Agent__c;
                }
            }
            //END:D-3461 10/27/2015 Added by Manolo Valena
            
            refreshVfPageOrderDetails();
        }

    }

    private void refreshVfPageOrderDetails() {
        
        paymentMethodId = thisOrder.Payment_Method_ID__c;
        
        // recipient address related details
        if (thisOrder.Recipient_Contact__c != null) {
            recipientAddressId = thisOrder.Recipient_Contact__r.Address__c;
            recipientAddressType = thisOrder.Recipient_Contact__r.Address__r.Address_Type__c;
            
            // Start D-2157 02/10/2015 JohnD added condition for address record typ
            if (thisOrder.Recipient_Contact__r.Address__r.RecordType.Name != null  
                    && thisOrder.Recipient_Contact__r.Address__r.RecordType.Name != ConstantsSLB.getOther(ADDRESS_RECORD_TYPE_NAME_LOCAL)) {
                
                recipientAddressRecordTypeName = thisOrder.Recipient_Contact__r.Address__r.RecordType.Name;
                        
            } else if (thisOrder.Delivery_Charge_Type__c == null) {
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
            // End D-2157 02/10/2015 JohnD
        }
        // end recipient address related details
        
        // for billing account section
        
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
            fetchBillingAccount();
        }
        // end for billing account section          
    }
//START UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid
    private void refreshOrder() {
        // refresh order to reflect the charges
      
        // Start UD-1431 08Jul15 JohnD 
        string queryStr = generateOrderSoqlStr();
        queryStr += ' where Id = \'' + thisOrder.Id + '\'';
        list<SObject> orderList = database.query(queryStr);
        thisOrder = (Order__c)orderList[0];
        // End UD-1431 08Jul15 JohnD 
        // Start D-2196 02/11/2015 JohnD added variable assignment
        recipientAddressRecordTypeName = thisOrder.Recipient_Contact__r.Address__r.RecordType.Name;
        // End D-2196 02/11/2015 JohnD
        refreshVfPageOrderDetails();
    }

    /*
     * Description: This method will retrieve the charges applicable to the recipient contact.
     *      This method is invoke in changing the recipient contact from the VF page
    */
    public string recipientContactId { get; set; }

    public void populateRecipientContactRelatedDetails() {
        
        
                
        /** D-0922 Auto Populate Asia1 Details      */  
            if(!isContactQueried){
                contactsMap = new Map<Id, Contact>();
                List<Contact> conList = new List<Contact>();
                conList = [Select Id, Name, Email  From Contact Where AccountId=:accountId];
                for(Contact c:conList){
                    contactsMap.put(c.Id,c);
                }
                isContactQueried = true;
            }
        

            if(asia1SingleAccount == null){
                asia1SingleAccount = new Asia1__c();
            }
            if(thisOrder.Recipient_Contact__c != null&&contactsMap.containsKey(thisOrder.Recipient_Contact__c)){
                asia1SingleAccount.Email__c = contactsMap.get(thisOrder.Recipient_Contact__c).Email;
                if(contactsMap.get(thisOrder.Recipient_Contact__c).Email != '' && contactsMap.get(thisOrder.Recipient_Contact__c).Email != null){
                    //Start D-0071 UAT James Azana || D-2390 03-02/2015 ABanaag
                    asia1SingleAccount.User_ID_LDAP_ID__c = String.valueOf(contactsMap.get(thisOrder.Recipient_Contact__c).Email); //.substring(0, String.valueOf(contactsMap.get(thisOrder.Recipient_Contact__c).Email).indexOf('@',0)); 
                    //START D-1064 JB Domingo Replaced dots and spaces 
                    //String userLdap = asia1SingleAccount.User_ID_LDAP_ID__c.replace('.',''); 
                    //asia1SingleAccount.User_ID_LDAP_ID__c = userLdap.replaceAll(' ','');  
                    //End D-0071 UAT UAT James Azana || D-2390 03-02/2015 ABanaag
                    //END D-1064 JB Domingo                     
                }
                asia1SingleAccount.Display_Name__c = contactsMap.get(thisOrder.Recipient_Contact__c).Name;
                //START D-1064 JB Domingo Replaced dots and spaces              
                String displayName = asia1SingleAccount.Display_Name__c.replace('.','');                
                asia1SingleAccount.Display_Name__c = displayName.replaceAll(' ','');
                //END D-1064 JB Domingo                 
            }
            else{
                asia1SingleAccount.Email__c = '';
                asia1SingleAccount.User_ID_LDAP_ID__c = '';
                asia1SingleAccount.Display_Name__c = '';
            }
        
        // Start D-2664 02Apr15 JohnD retrieve default delivery charge type
        if (thisOrder.Recipient_Contact__c != null) {
            
            try {
                
                recipientAddressType = [select Address__r.Address_Type__c from Contact 
                    where Id = :thisOrder.Recipient_Contact__c].Address__r.Address_Type__c;
                    
                thisOrder.Delivery_Charge_Type__c = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
            
            } catch (exception e) {
                ExceptionLogger.log(new list<exception> { e });
            }
            
        }

        if (thisOrder.Delivery_Charge_Type__c != null) { 
        //Start D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
            if (selectedDeliveryChargeType == null)
                selectedDeliveryChargeType = thisOrder.Delivery_Charge_Type__c; 
        //END D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
        }
        
        // End D-2664 02Apr15 JohnD retrieve default delivery charge type

       
       //START D-3002 22-05-2015 Marvin G
        
           retrieveOrderLineItems();
           //START D-2879 05-09-2015 Marvin G
           //checkAndSetDeliveryType();    
           map<string, decimal> charges = getCharges(thisOrder.Recipient_Contact__c, 
           selectedDeliveryChargeType , subscriberCharge, vendorCredit);
           //END D-2879 05-09-2015 Marvin G
        
        //END D-3002 22-05-2015 Marvin G 
        
        // Start D-2157 02/11/2015 JohnD commented out. replaced by calling the computePrepaid method
        computePrepaid();
        // End D-2157 02/11/2015 JohnD
        
         
        thisOrder.Vendor_Credit__c = charges.get('VendorCredit');

        recipientContactId = thisOrder.Recipient_Contact__c;
        
        // Start D-1326 01/15/2015 JohnD retrieve the record type of the recipient
        if (thisOrder.Recipient_Contact__c != null) {
            
            try {
                
                recipientAddressRecordTypeName = thisOrder.Recipient_Contact__r.Address__r.REcordtype.Name;
                    //[select Address__r.RecordType.Name from Contact 
                       // where Id = :thisOrder.Recipient_Contact__c].Address__r.RecordType.Name;
               system.debug('\n\n *****DEBUG: recipientAddressRecordTypeName***** ' + recipientAddressRecordTypeName +'\n\n' );   
            } catch (exception e) {
                
                // Start D-2196 02/11/2015 JohnD replaced by exception handler
                ExceptionLogger.log(new list<exception> { e });
                // End D-2196 02/11/2015 JohnD
            }
        }
       // End D-1326

    }

    /*
     * Description: This method will retrieve all the order line items related to the Order.
     *      The list will be displayed on the Line Items section of the VF page
    */
    private void retrieveOrderLineItems() {
        isOrderContainsVendorDelivery = false; // Start/End UD-1431 08Jul15 JohnD 
        chooseAgent = false; //START END D-3382 CCB-135 Wenjun 04/Aug/15
        orderLineItemList = getOrderLineItems(thisOrder.Id);
        Set<ID> packageId = new Set<Id>();
        List<Package_Item__c> packageItemList = new List<Package_Item__c>(); 
        //Start UD-0333 30-16-15 ABanaag 
        withNonCharityOli = false;
    
        Map<String, Decimal> chargeMap = new Map<string,decimal>();
        //End UD-0333 30-16-15 ABanaag 
    
        //START UD-1317 06/08/2015 Added by J. Sarion - Set Package Id Set
        Set<Id> pkgIdAddOnPrepaidSet = new Set<Id>();
        Set<Id> pkgIdAddOnPostpaidSet = new Set<Id>();
        List<Package__c> packageList = new List<Package__c>();
        //END UD-1317 06/08/2015 Added by J. Sarion - Set Package Id Set
    
        if (orderLineItemList.size() > 0) {
            for(Order_Line_Item__c oli: orderLineItemList){
                packageId.add(oli.Main_Package_ID__c);
               
                //START UD-1317 06/08/2015 Added by J. Sarion - Set Package Id Set
                if (oli.Addon_Package__c != null) {
                    if (oli.Main_Package_Billing_Type__c == 'Recurring Prepaid')
                        pkgIdAddOnPrepaidSet.add(oli.Addon_Package__c);
                    if (oli.Main_Package_Billing_Type__c == 'Recurring Postpaid')
                        pkgIdAddOnPostpaidSet.add(oli.Addon_Package__c);
                }
                // Start UD-1431 08Jul15 JohnD - for subscriber and vendor charge field in VF page
                if (oli.Delivered_By__c == VENDOR) {
                    isOrderContainsVendorDelivery = true;
                }
                // End UD-1431 08Jul15 JohnD - for subscriber and vendor charge field in VF page
                
                //START D-3382 CCB-135 04/Aug/15 Wenjun: Mailing Agent Assignment for Airline Address Type
                if (oli.Delivered_By__c == DELIVERED_BY_MAILING_AGENT 
                    && recipientAddressRecordTypeName == GlobalVariableClass.STRING_AIRLINE) {
                    chooseAgent = true;
                    if(airlineAgents == null || airlineAgents.isEmpty())
                        airlineAgents = getAirlineMailingAgents();
                } 
                //END D-3382 CCB-135 04/Aug/15 Wenjun  
            }
            //End UD-0953 Karen Hung Add validation if delivered by is mailing agent 
            
            try{
                update thisOrder;
            }
            catch(Exception e){
            }
            //End UD-0333 03-16-15 ABanaag
            
            packageItemList = [Select Is_Newspaper__c, Is_Magazine__c From Package_Item__c Where Package__c IN: packageId];
            if(packageItemList.size() > 0){
                for(Package_Item__c packageItem: packageItemList){
                    If(packageItem.Is_Newspaper__c == true){
                    
                        isNewspaper = true;                             
                    }                       
                    Else if(packageItem.Is_Magazine__c == true){
                        isMagazine = true;
                    }
                }
            }
            
            //START UD-1317 06/08/2015 Added by J. Sarion - Map Package to price
            packageList = [SELECT Id, Package_Price__c FROM Package__c WHERE Id IN :packageId];
            for (Package__c pkg :packageList) {
                if (pkg.Package_Price__c != null)
                    pkgIdToMainPriceMap.put(pkg.Id, pkg.Package_Price__c);
            }
            
            if (!pkgIdAddOnPrepaidSet.isEmpty()) {
                retrievePackageSubscriptionRate(pkgIdAddOnPrepaidSet, 'Recurring Prepaid');
                for (Id pkgId :packageId_subscriptionCharge.keySet()) {
                    pkgIdToAddOnPriceMap.put(pkgId, packageId_subscriptionCharge.get(pkgId));
                }
            }
            if (!pkgIdAddOnPrepaidSet.isEmpty()) {
                retrievePackageSubscriptionRate(pkgIdAddOnPrepaidSet, 'Recurring Postpaid');
                for (Id pkgId :packageId_subscriptionCharge.keySet()) {
                    pkgIdToAddOnPriceMap.put(pkgId, packageId_subscriptionCharge.get(pkgId));
                }
            }
            //END UD-1317 06/08/2015 Added by J. Sarion - Map Package to price
        }
    }           

    /*
     * Description: This method will add an order line item the the user when the user done populating
     *      the necessary information from the VF page. This item will be added and displayed
     *      on the Line Items section of the VF page
    */
    public void addOrderLineItem() {
    
    //Start UD-0593 03-27-15 - ABanaag
        selectedGifts = 0;
    //End UD-0593 03-27-15 - ABanaag
        boolean isPassedValidation = true;
        //START D-2057 JTeves 17/02/15 : Add Asia1 validation
        boolean isSelectedPackageDigital = false;
        //END D-2057 JTeves
        
        //START UD-3011 10/14/15 AddedBy francisBenzon : check Asia1 records vs quantity
        if(asia1SubscriptionsTotal != 0)
        {
            if(orderLineItem.Qty__c < asia1SubscriptionsTotal)
            {
                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Asia1vsQuantity')));
                isPassedValidation = false;
            }
        }
        //END UD-3011 10/14/15 AddedBy francisBenzon : check Asia1 records vs quantity
        
        /* validation */
        //START D-2759 Wenjun 13/04/15 - Validate if the New Order Line Item is with right Billing Type
        if (orderLineItemList != null && !orderLineItemList.isEmpty() && orderLineItem.Main_Package_Billing_Type__c != thisOrder.Billing_Type__c ) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_OLI_DIFF_BILLING_TYPE));
            isPassedValidation = false;
        }
        //END D-2759 Wenjun 13/04/15
        // check if package is from promotion
        list<string> packageIdpromotionId = selectedPackageId.split(':');
        
        //START D-2057 JTeves 17/02/15 : Add Asia1 validation
        if(packageIdpromotionId.size() > 0) {
        //Start DeliveredBy defect 03-12-15 ABanaag - no defect
            for(Package_Item__c pItem : [Select Is_Digital__c, Is_All_In_One__c FROM Package_Item__c WHERE Package__c = :packageIdpromotionId.get(0)]) {
                if(pItem.Is_Digital__c ) {
        //End D-0070 03-12-15 ABanaag - no defect
                    isSelectedPackageDigital = true;
                }
            }
        }
        //START UD-0224 3/5/15 Added By FrancisBenzon : added criteria for Asia error, Asia1 will not be required if creation should bulk
        //END UD-0224 3/5/15 Added By FrancisBenzon : added criteria for Asia error, Asia1 will not be required if creation should bulk
        //END D-2057 JTeves
        
        //START D-2927 05-15-2015 Marvin Gatchalian Add validation if there no Asia1 create when package selected is digital
        //START: Hot FIX UD-1425 K. Tan/ J.Sarion 5/29/2015 
        If (isSelectedPackageDigital && asia1SubscriptionsTotal <= 0 && orderLineItem.Asia1_Creation_Mode__c != GlobalVariableClass.STARTSUB_ASIA1_BULK){  
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('At least one asia1 id'))); 
            isPassedValidation = false; 
        }
        //END: Hot FIX UD-1425 K. Tan/ J.Sarion 5/29/2015   
        //START D-2927 05-15-2015 Marvin Gatchalian Add validation if there no Asia1 create when package selected is digital
         
    
        //START/END D-2881 06/01/15 RReyes - added condition if new contract period is 0 or null
        if (orderLineItem.Contract_End_Date__c == date.valueOf('1970-01-01') || orderLineItem.New_Contract_Period__c == 0 || orderLineItem.New_Contract_Period__c == null) {
            orderLineItem.Contract_End_Date__c = null;
        }

        if (orderLineItem.New_Contract_Period__c == 999) {
            orderLineItem.New_Contract_Period__c = null;
        }

        if (orderLineItem.Penalty_Charge__c == 9999999999999999.99) {
            orderLineItem.Penalty_Charge__c = null; 
        }
        
        //START: D-4618 May 15, 2016 Added by Kristine Balaoing - added validation for add on digital packages
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
        //END: D-4618 May 15, 2016 Added by Kristine Balaoing 
        // check if package is digital and have an asia1 subscription       
        if (isDigital == true && orderLineItem.Asia1_Creation_Mode__c == 'Individual' && asia1Subscriptions.size() == 0) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Required Asia1')));
            isPassedValidation = false;
        }
        // Check if the start subscription has a start date
         if (orderLineItem.Start_Date__c == null) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Start Sub Start date missing'))); 
            isPassedValidation = false;
        }
        // end of start date validation
        
        // Check if the Term Length is not null
        if ((orderLineItem.Term_Length__c < 1 || orderLineItem.Term_Length__c == null) 
                && orderLineItem.Main_Package_Sub_Type__c == 'Termed') {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Start Sub Term Length missing'))); 
            isPassedValidation = false;
        }
        // end of Term Length validation
        //START UD-0722 MGaelo 4/20/2015 Added Validation rule Unable to Delivered by Vendor if the Recipient is Overseas/Airlines/Internal
        If ((orderLineItem.Delivered_By__c == DELIVERED_BY_VENDOR || orderLineItem.Delivered_By__c == DELIVERED_BY_NONE) && recipientAddressRecordTypeName == ConstantsSLB.getOther('Contact_Recordtype_Overseas')){  
        ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Vendor for Overseas'))); 
                        isPassedValidation = false; 
        }
        
        If ((orderLineItem.Delivered_By__c == DELIVERED_BY_VENDOR || orderLineItem.Delivered_By__c == DELIVERED_BY_NONE) && recipientAddressRecordTypeName == ConstantsSLB.getOther('Contact_Recordtype_Airline')){  
        ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Vendor for Airlines'))); 
                        isPassedValidation = false; 
        }
        
        If ((orderLineItem.Delivered_By__c == DELIVERED_BY_VENDOR || orderLineItem.Delivered_By__c == DELIVERED_BY_NONE) && recipientAddressRecordTypeName == ConstantsSLB.getOther('Contact_Recordtype_Internal')){  
        ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Vendor for Internal'))); 
                        isPassedValidation = false; 
        }
        //END UD-0722 MGaelo 4/20/2015 Added Validation rule Unable to Delivered by Vendor if the Recipient is Overseas/Airlines/Internal
        //START UD-0292 3/12/15 Added By RonaldDagaraga/ABanaag : added criteria for Promotion Contract, Contract period is not required in other promotions
        // Check if the New Contract Period is not null

        if ((orderLineItem.New_Contract_Period__c == null || orderLineItem.New_Contract_Period__c < 1) 
                && orderLineItem.Promotion_ID__c != null) { 
                string isUnderContract; 
                try { 
                    isUnderContract = [select Contract__c from Promotion__c where Id = :orderLineItem.Promotion_ID__c].Contract__c; 
                    if (isUnderContract == 'Yes') { 
                        ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Start Sub New Contract Period missing'))); 
                        isPassedValidation = false; 
                        }
                    } catch (exception e) { 
                       ExceptionLogger.log(new list<exception>{ e });
                 }
        } 

        //End UD-0292 
        
        if (orderLineItem.Term_is_discussed__c != true && orderLineItem.Promotion_ID__c != null) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('Terms And Condition')));
            isPassedValidation = false;
        }
        //Start D-2390 03-0215 ABanaag - use string value to avoid Apex error: must resolve to string type
    //Start UD-0593 03-27-15 - ABanaag - place in try catch to avoid exception
        try{
            orderLineItem.Term_Length__c = integer.ValueOf(termLength);
        }
        catch(Exception e){
            orderLineItem.Term_Length__c = 0;
        }
        //START D-3231 07/07/15 Wenjun : Validate Subscription Periods Overlapping For Full Prepaid
        if(thisOrder.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID 
            && SM_SubscriptionHelper.isPartiallyOverlapping(orderLineItemList, orderLineItem))
        {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_SAME_ORDER_FFP));
            isPassedValidation = false; 
        }
        //END D-3231 07/07/15 Wenjun
    //End UD-0593 03-27-15 - ABanaag
        //End D-2390 03-0215 ABanaag - use string value to avoid Apex error: must resolve to string type        
        // end check if package is digital and have and asia1 subscription
        /* end validation */
        
        //START:D-4098 12/18/2015 Added by Manolo Valena
        if(SM_SubscriptionHelper.validateFutureDatedCOA(thisOrder.Recipient_Contact__c, null, GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION) != null) {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, SM_SubscriptionHelper.validateFutureDatedCOA(thisOrder.Recipient_Contact__c, null, GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION)));
            isPassedValidation = false;
        }
        //END:D-4098 12/18/2015 Added by Manolo Valena
        
        //START D-1317 Wenjun 09/02/15 : Restructure the code and catch exception
        try {   
            if (isPassedValidation == true) {
                 Contact recipientContact = new Contact();
                
                if (orderLineItem.Term_Length__c > 0 &&  orderLineItem.Start_Date__c != null) {
                    //START D-1303 1/16/2015 Added By C. Lin - Deduct 1 day from the End Date of the Order Line Item
                    orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addMonths((integer)orderLineItem.Term_Length__c).addDays(-1);
                    //END D-1303 1/16/2015 Added By C. Lin
                }
                
                if (orderLineItem.Main_Package_Subscription_Rate__c == null) {
                    orderLineItem.Main_Package_Subscription_Rate__c = 0;
                }

                //START 01/06/15 Wenjun - Postage Charges : calculate Postage Charge for this Order Item
                if(orderLineItem.Delivered_By__c == 'Mailing Agent')
                {
                    //Unit Postage Charge * Quanty
                    orderLineItem.Postage_Charge__c = 
                        PostageChargeHelper.getPostageChargeForLineItem(thisOrder.Recipient_Contact__c,orderLineItem) * orderLineItem.Qty__c;
                }
                //END 01/06/15 Wenjun
                //Start UD-0613 03-30-15 ABanaag - populate Add_On_Package_Subscription_Rate__c
                if(selectedAddOnPackage != null && addOnPackage != null && orderLineItem.Main_Package_Billing_Type__c != null ){
                    retrievePackageSubscriptionRate(new set<id>{addOnPackage.Id}, orderLineItem.Main_Package_Billing_Type__c);
                    if(!packageId_subscriptionCharge.isEmpty() && packageId_subscriptionCharge.get(addOnPackage.Id) != null){
                        orderLineItem.Add_On_Package_Subscription_Rate__c = packageId_subscriptionCharge.get(addOnPackage.Id);
                    }
                }
                //End UD-0613 03-30-15 ABanaag - populate Add_On_Package_Subscription_Rate__c
                //START UD-1826 addedBy FrancisBenzon : to render vendor credit and subcharge
                if(orderLineItem.Delivered_By__c == 'Vendor')
                {
                    isOrderContainsVendorDelivery = true;
                }
                //END UD-1826 addedBy FrancisBenzon : to render vendor credit and subcharge
                UPSERT orderLineItem;
                //START UD-2281 8/7/15 AddedBy FrancisBenzon : use this map on edit to render save deliveredBy by user
                if(orderLineItem.Delivered_By__c != null)
                {
                    oliId_DeliveredBy.put(orderLineItem.Id, orderLineItem.Delivered_By__c);
                }
                //END UD-2281 8/7/15 AddedBy FrancisBenzon : use this map on edit to render save deliveredBy by user
                //START UD-1317 06/08/2015 Added by J. Sarion - Map oli Id to Package Price
                pkgIdToMainPriceMap.put(orderLineItem.Main_Package_ID__c, orderLineItem.Main_Package_Subscription_Rate__c);
                if (orderLineItem.Add_On_Package_Subscription_Rate__c != null)
                    pkgIdToAddOnPriceMap.put(orderLineItem.Addon_Package__c, orderLineItem.Add_On_Package_Subscription_Rate__c);
                //END UD-1317 06/08/2015 Added by J. Sarion - Map oli Id to Package Price
                
                //START D-1967 Added by April Banaag - corrected condition to make sure Contract End Date is overwritten after initialization       
                if (orderLineItem.New_Contract_Period__c > 0 && orderLineItem.Start_Date__c != null && orderLineItem.Promotion_ID__c != null) {
                    //START D-1303 1/16/2015 Added By C. Lin - Deduct 1 day from the End Date of the Order Line Item
                    orderLineItem.Contract_End_Date__c = orderLineItem.Start_Date__c.addMonths((integer)orderLineItem.New_Contract_Period__c).addDays(-1);
                    //END D-1303 1/16/2015 Added By C. Lin
                }
                if (promotionGifts != null) {     
                //END D-1967 Added by April Banaag - corrected condition to make sure Contract End Date is overwritten after initialization 
                    // create order line item gifts
                    list<Order_Line_Item_Gift__c> orderLineItemGifts = new list<Order_Line_Item_Gift__c>();
                    
                    //Puplate Order Quantity based from the quantity in Order Line Item
                    for (GiftWrapper gw : promotionGifts) {
                        if (gw.selectGift) {
                            Order_Line_Item_Gift__c orderLineItemGift = new Order_Line_Item_Gift__c();
                            orderLineItemGift.Order_Line_Item__c = orderLineItem.Id;
                            orderLineItemGift.Promotion_Gift__c = gw.PromotionGift.Id;
                            //Start PD-0200 6/15/16 -L.Reyes Added to decrease Quantity Balance
                            orderLineItemGift.Order_Quantity__c = orderLineItem.Qty__c;
                            //End PD-0200 6/15/16 -L.Reyes Added to decrease Quantity Balance
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
                if (asia1Subscriptions.size() > 0) {
                    createAsia1Subscription(asia1Subscriptions, orderLineItem.Id);
                }
                
                //START 08/01/2015 Wenjun : Set Order Billing Type - Assumption: Order Lines Items will have the same Billing Type
                thisOrder.Billing_Type__c = orderLineItem.Main_Package_Billing_Type__c;
                //END 08/01/2015 Wenjun  
                               
                // calculate months
                if (orderLineItem.Main_Package_Billing_Type__c == 'Full Prepaid' && orderLineItem.End_Date__c != null 
                        && orderLineItem.Main_Package_Sub_Type__c == 'Termed') {
                            
                    thisOrder.FP_Del_Usage__c = CalculateCharges.getMonths(thisOrder.Id, recipientContact.Address__c, 
                            orderLineItem.Start_Date__c, orderLineItem.End_Date__c);
                }
                // end calculate months
                
                
                //START D-2879 05-09-2015 Marvin G
                // checkAndSetDeliveryType();   // Start/End UD-1431 JohnD - commented out 
                //END D-2879 05-09-2015 Marvin G
                
                update thisOrder;

                // START : D-1033 12/11/2014 Alyana Navarro - call method for delivery charge.
                computePrepaid();
                // END : D-1033 12/11/14

                //Start UD-678 VPernicia/MGatchalian 4/06/2015
                Quote_Handler QH = new Quote_Handler();
                QH.Create_Quotes(thisOrder, 'Start Subscription', orderLineItem.id);
                //End UD-678 VPernicia/MGatchalian 4/06/2015
                
                retrieveOrderLineItems();
                refreshOrder();
                reInitializeItem();
            } else {
                isReInitializedItem = false;
            }
            //START D-3305 8/6/15 AddedBy FrancisBenzon : reParentAsia1Subs if OLI is new
            if(isDigital){
                reParentAsia1SubToNewOLI();
            }
            //END D-3305 8/6/15 AddedBy FrancisBenzon : reParentAsia1Subs if OLI is new
        } 
        catch (exception e) {
            //START UD-0198 03-12-2015 Marvin Gatchalian
            deleteRelatedAsia1();
            //END UD-0198 03-12-2015 Marvin Gatchalian  
            ApexPages.addMessages(e);
        }
        //END D-1317 Wenjun 09/02/15
    }

    /*
     * Description: This method will retrieve the information of the selected Order Line Item and 
     *      populate the data on the Subscription Details Section of the VF page.
     *      This will allow the user to update the Order Line Item. Invoke when user click on the
     *      specific Order Line Item from the Line Item section of the VF page
    */
    public void retrieveOrderLineItem() {
    // Start D-2196 02/12/2015 JohnD added variable        
    //Start D-0070 03/12/2015 ABanaag
        List<Product_Publication__c> publicationDetailList = new List<Product_Publication__c>();
    //End D-0070 03-12-15 ABanaag
    // End D-2196 02/12/2015 JohnD        
        orderLineItem = getOrderLineItem(selectedOrderLineItem);
        
        // Start UD-0759 Ronald dagaraga for editing order line item 17Apr15
        if (orderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID){
            isFullPrepaid = true;
        }
        

        if (orderLineItem.Term_Length__c != null) {
            termLength = string.valueOf(orderLineItem.Term_Length__c);
        }

    
        subscriptionRate = orderLineItem.Main_Package_Subscription_Rate__c;
        if (orderLineItem.Add_On_Package_Subscription_Rate__c != null) {
            subscriptionRate += orderLineItem.Add_On_Package_Subscription_Rate__c;
        }
        
        totalSubscriptionPrice = orderLineItem.Total_Subscription_Rate__c;
        // Endt UD-0759 Ronald dagaraga for editing order line item 17Apr15
             
    //Start UD-0593 03-27-15 - ABanaag
        selectedGifts = [SELECT COUNT() FROM Order_Line_Item_Gift__c WHERE Order_Line_Item__c = :orderLineItem.id];
    //End UD-0593 03-27-15 - ABanaag
        // populate getter-setter variables
        selectedPackageName = orderLineItem.Main_Package_ID__r.Name;
        
        addOnPackage = new Package__c();
        promotionGifts = new list<GiftWrapper>();
        initializeAsia1Components();
        isDigital = false;
        productIsMagazine = false;  //Start/End D-0033 JohnD added variable
        selectedPackageId = orderLineItem.Main_Package_ID__c;
        deliveryMethod = new list<SelectOption>();
    // Start D-2196 02/12/2015 JohnD added variable
        Package__c pkg = new Package__c();
    // End D-2196 02/12/2015 JohnD        
        //START UD-3405 12/21/15 RReyes
         if(orderLineItem.Addon_Package__c != null){
            addOnPackage.Id = orderLineItem.Addon_Package__c;
            addOnPackage.Name = orderLineItem.Addon_Package__r.Name;
         }
        //END UD-3405 12/21/15 RReyes
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


        // Start D-2196 02/11/2015 JohnD added query
        set<id> productIds = new set<id>();
        try {
            pkg = [select Id, Package_Code__c, Name, Subscription_Type__c, 
                    Package_Sub_Type__c, Subscription_Period__c, Product_Family_Current_Package__c, Billing_Type__c, Package_Type__c, 
                    (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                    Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, RecordType.DeveloperName, 
                    Product_Rate_Plan__r.SubscriptionFrequency__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c  
                    from Package_Items__r) from Package__c where Id = :orderLineItem.Main_Package_ID__c];
        } catch (exception e) {
            ExceptionLogger.log(new list<exception> { e });
        }

        for (Package_Item__c tmp : pkg.Package_Items__r) {            
            productIds.add(tmp.Product_Rate_Plan__r.zqu__ZProduct__c);
            // Start D-0033 UAT 26-02-2015 JohnD added productMagazine 
            if (tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c == GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE) {
                productIsMagazine = true;
            }
            // End D-0033 UAT 26-02-2015 JohnD
        }
        
        //START SPH Code Review - 16-Feb-2015 Added by Raviteja - included if condition in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
        productIds.remove(null);
        //End SPH Code Review - 16-Feb-2015 Added by Raviteja
    //Start D-0070 03-12-2015 ABanaag
        try {
            //START UD-2281 8/7/15 AddedBy FrancisBenzon : order pub query by earliest start date
            publicationDetailList = [select Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c 
                    from Product_Publication__c where ZProduct__c in :productIds
                    AND Publication_Code__r.Earliest_Start_Date__c != Null 
                    order by Publication_Code__r.Earliest_Start_Date__c asc];
            //END UD-2281 8/7/15 AddedBy FrancisBenzon : order pub query by earliest start date
        } catch (exception e) {
            publicationDetailList = new List<Product_Publication__c>();
        }
        //End D-0070 03-12-2015 ABanaag
        // End D-2196 02/11/2015 JohnD

        
        if (orderLineItem.Is_Digital__c == true) {
            
            isDigital = true;
            list<Asia1Wrapper> tmpAsWrapper = new list<Asia1Wrapper>();
            
            map<id, Asia1Wrapper> asia1Id_asia1Subscriptions = new map<id, Asia1Wrapper>();
            
            for (Asia1_Subscription__c tmp : orderLineItem.Asia1_Subscriptions__r) {
                
                Asia1Wrapper tmpAw = new Asia1Wrapper();
                list<Asia1SubscriptionWrapper> tmpAsList = new list<Asia1SubscriptionWrapper>();
                Asia1SubscriptionWrapper tmpAs = new Asia1SubscriptionWrapper();
                
                if (asia1Id_asia1Subscriptions.get(tmp.Asia1__r.Id) != null) {
                    tmpAw = asia1Id_asia1Subscriptions.get(tmp.Asia1__c);
                    tmpAsList = tmpAw.asia1Subscriptions;
                }
                
                tmpAw.userId = tmp.Asia1__r.User_ID_LDAP_ID__c;
                tmpAw.asia1Id = tmp.Asia1__r.Id;
                
                tmpAs.serviceFlagId = tmp.Service_Access_Flag__c;
                tmpAs.serviceFlagName = tmp.Service_Access_Flag__r.Name;
                tmpAs.status = tmp.Status__c;
                if (tmp.Concurrent__c != null) {
                    tmpAs.concurrent = integer.valueOf(tmp.Concurrent__c);
                }
                
                tmpAsList.add(tmpAs);
                tmpAw.asia1Subscriptions = tmpAsList;
                asia1Id_asia1Subscriptions.put(tmp.Asia1__c, tmpAw);
            }
            
            
            for (id tmp : asia1Id_asia1Subscriptions.keySet()) {
                tmpAsWrapper.add(asia1Id_asia1Subscriptions.get(tmp));
            }
            
            
           
            asia1Subscriptions = tmpAsWrapper;
            asia1SubscriptionsTotal = asia1Subscriptions.size();            
        }
        
        //START D-0070 03-12-15 defect ABanaag
        uniqueOptions = new set<string>();
        // Start D-0033 UAT 26-02-2015 JohnD revised logic implemented in getting the delivered by value
           deliveryMethod.add(new SelectOption(DELIVERED_BY_NONE, DELIVERED_BY_NONE));
            uniqueOptions.add(DELIVERED_BY_NONE);
       
        if(publicationDetailList.size()>0){
            for(Product_Publication__c pubDetail : publicationDetailList){
                if (pubDetail.Publication_Code__c != null 
                && pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c != null) {
                
                    if (pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == DELIVERED_BY_BOTH 
                            || pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == null) {
                      // Start UD-0759 4/17/2015 ronald dagaraga new criteria for edit record not to have defaulta value
                      if (orderId == null){  //START/END: UD-0219 RReyes Changed validation criteria to orderId.
                        orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;}
                      // End UD-0759 4/17/2015 ronald dagaraga new criteria for edit record not to have defaulta value  
                        if(!uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
                            deliveryMethod.add(new SelectOption(DELIVERED_BY_MAILING_AGENT, DELIVERED_BY_MAILING_AGENT));
                            uniqueOptions.add(DELIVERED_BY_MAILING_AGENT);
                        }
                    
                        if(!uniqueOptions.CONTAINS(DELIVERED_BY_VENDOR)){
                            deliveryMethod.add(new SelectOption(DELIVERED_BY_VENDOR, DELIVERED_BY_VENDOR));
                            uniqueOptions.add(DELIVERED_BY_VENDOR);
                        }
                                                                                        
                    } else {
                        //START UD-2281 8/17/15 AddedBy FrancisBenzon : maintain deliveredBy inputted by user
                        if(orderLineItem.Delivered_By__c == null)
                        {
                            orderLineItem.Delivered_By__c = pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c;
                        }     
                        //END UD-2281 8/17/15 AddedBy FrancisBenzon : maintain deliveredBy inputted by user
                        if(!uniqueOptions.CONTAINS(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c)){
                        deliveryMethod.add(new SelectOption(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c, 
                                pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c));
                                uniqueOptions.add(pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c);
                        }
                    }
        
                }
            }
        }       
        //END D-0070 03-12-15 defect ABanaag       
        // End D-0033 UAT 26-02-2015 JohnD     
        // end populate getter-setter variables
        //START UD-2281 8/7/15 AddedBy FrancisBenzon : default deliveredBy by the value that user 
        if(oliId_DeliveredBy.containsKey(orderLineItem.Id))
        {
            orderLineItem.Delivered_By__c = oliId_DeliveredBy.get(orderLineItem.Id);
        }
        //END UD-2281 8/7/15 AddedBy FrancisBenzon : default deliveredBy by the value that user
    }
    
    /**
    * @description : Action to be called when Remove button clicked
    *           on Line Item section of of the VF Page
    */
    public void removeLineItem() {
        
        deleteRelatedOrderLineItemRelatedObjects(orderLineItemIdToBeRemoved);
        delete [select id from Order_Line_Item__c where Id = :orderLineItemIdToBeRemoved];
        retrieveOrderLineItems();
        
        //START D-2879 05-09-2015 Marvin G
        // checkAndSetDeliveryType();   // Start/End UD-1431 JohnD - commented out 
        //END D-2879 05-09-2015 Marvin G
        
        //START D-1317 Wenjun 09/02/15 : Recalculate Charges when removing Order Line Items
        computePrepaid();
        //END D-1317 Wenjun 09/02/15
        refreshOrder();
        
        if (orderLineItem.Id == orderLineItemIdToBeRemoved) {
            reInitializeItem();
        }
    }

    /**
    * @description : Action to be called when Update Line Item button clicked
    *           on Subscription Details section of of the VF Page
    */
    public void updateOrderLineItem() {
        //START D-3305 8/6/15 AddedBy FrancisBenzon :no need to delete Asia1 and Asia1 Sub during update, delete only OLI and OLIGifts
        //deleteRelatedOrderLineItemRelatedObjects(orderLineItem.Id);
        //START UD-3166 10/28/15 AddedBy FrancisBenzon : same with oob validation to prevent lost data during update of oli.
        if(orderLineItem.Start_Date__c <= date.today()) 
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('StartSubStartDateValue')));
        }
        else {
            //START UD-3545 1/12/2016 Added by J.Sarion - Set/Delete Asia1 Subscriptions clicking Update Line Item button
            removeAsia1SubscriptionBulk();
            //END UD-3545 1/12/2016 Added by J.Sarion - Set/Delete Asia1 Subscriptions clicking Update Line Item button
            try{         
                delete [select id from Order_Line_Item_Gift__c where Order_Line_Item__c = :orderLineItem.Id]; 
                delete [select id from Order_Line_Item__c where Id = :orderLineItem.Id];
            }
            catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
            //END D-3305 8/6/15 AddedBy FrancisBenzon :no need to delete Asia1 and Asia1 Sub during update, delete only OLI and OLIGifts
            orderLineItem.Id = null;
            //START D-3231 Wenjun 08/07/15 : refresh Existing Order List before addOrderLineItem method                         
            retrieveOrderLineItems();
            addOrderLineItem();         
            //END D-3231 Wenjun 08/07/15
            //START UD-3545 1/12/2016 Added by J.Sarion - Set/Delete Asia1 Subscriptions clicking Update Line Item button
            asia1Subscriptions = new list<Asia1Wrapper>();
            asia1SubscriptionsTotal = 0;
            //END UD-3545 1/12/2016 Added by J.Sarion - Set/Delete Asia1 Subscriptions clicking Update Line Item button
        }
        //END UD-3166 10/28/15 AddedBy FrancisBenzon : same with oob validation to prevent lost data during update of oli.      
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
    * @description : This method will retrieve and sum-up the related List Price field from Product Rate Plan object
    *           and map it to its corresponding Package.
    */      
    private static void retrievePackageSubscriptionRate(set<id> packageIds, string billingType) {
        packageId_subscriptionCharge = SM_SubscriptionHelper.getPackageSubscriptionRate(packageIds, billingType); 
    }

    
    public void searchPackage() {
        
        packageId_subscriptionCharge = new map<string, decimal>();
        
        if (searchText.length() > 1) {
            
            //Start D-1624 01/21/2015 Added by James Aza?a: Get Product Family of Added Package
            set<id> packIds = new set<id>();
            if(orderLineItemList.size() > 0){
                List<Order_Line_Item__c> ordList = new List<Order_Line_Item__c>();
                ordList = [Select Id, Main_Package_ID__r.Product_Family_Current_Package__c From Order_Line_Item__c Where Order__c = :thisOrder.Id];
                Map<Id, String> ordMAP = new Map<Id, String>();
                if(ordList<>null && ordList.size()>0){
                    for(Order_Line_Item__c ord : ordList){
                            ordMAP.put(ord.Id, ord.Main_Package_ID__r.Product_Family_Current_Package__c);
                    }
                }     

                List<Product_Family__c> prodFamList = new List<Product_Family__c>();
                prodFamList = [Select id, Name, Product_Family__c from Product_Family__c where Name IN :ordMAP.values()];
                Map<Id, String> prodFamMAP = new Map<Id, String>();
                if(prodFamList<>null && prodFamList.size()>0){
                    for(Product_Family__c pf : prodFamList){
                        prodFamMAP.put(pf.Id, pf.Product_Family__c);
                    }
                }  

                string addonPack = (ConstantsSLB.getKeyId('Add On'));
                string productFam = '%' + prodFamMAP.values() + '%';
                productFam = productFam.replaceAll('[()]', '');
                List<Package__c> packList = [Select id, Package_Type__c, Product_Family_Current_Package__c, Eligible_Product_Family_for_Add_On_Pack__c from Package__c where Package_Type__c = :addonPack and (NOT Eligible_Product_Family_for_Add_On_Pack__c like :productFam)];

                if(packList<>null && packList.size()>0){
                    for(Package__c pk : packList){
                        packIds.add(pk.Id);
                    }
                }
             }          
            //End D-1624 01/21/2015 Added by James Aza?a
            
            //START UAT D-0080 Marvin Gatchalian - added Package_Price__c as this is where subscription rate will be based.
            string qry = 'select Id, Package_Price__c, Name, Package_Type__c, Subscription_Type__c, Subscription_Period__c from Package__c where Name like \'%' + searchText + '%\'';
            //Start D-1560 D-1564 01/13/2015 Updated by James Aza?a: Exclude inactive Packages
            //Start D-1624 01/21/2015 Updated by James Aza?a: Exclude Add On Packages with different Product Family
            //START:D-0051 2/25/15 Added by Manolo Vale?a - Removed 'and Number_Of_Promotions__c < 1' from the query to allow users to search for packages that are also attached to a promotion.
            //START: UD-1242 06/08/2015 Updated by Jean Cariño - Modified the query to add filter on the Package Type
            qry += ' and Id NOT IN :packIds and Effective_Start_Date__c <= TODAY and Effective_End_Date__c >= TODAY and Billing_Type__c=\'' + searchBillingType + '\' and Package_Type__c != \'Add On\' and Package_Type__c != \'Grace Period\'' + ' limit 101'; //D - 2067 - 02-03/2015 - Joban - Modified the query to add the '=' operator 
            //END: UD-1242 06/08/2015 Updated by Jean Cariño
            //END:D-0051 2/25/15 Added by Manolo Vale?a
            //End D-1624 01/21/2015
            //End D-1560 D-1564 01/13/2015 Updated by James Aza?a
            packageResultList = Database.query(qry);
            //END UAT D-0080 Marvin Gatchalian - added Package_Price__c as this is where subscription rate will be based.
            
            if (packageResultList.size() > 0) {
                
                set<id> packageIds = new set<id>();
                for (SObject tmp : packageResultList) {
                    packageIds.add((Id)tmp.get('Id'));
                }
                
                retrievePackageSubscriptionRate(packageIds, searchBillingType);
            }
        }
    }
    
    public void searchPromotion() {
       
        promotionResultList = new list<SObject>();
        // Start D-1326 01/15/2015 JohnD Added logic that airline and overseas subscriber is not allowed for a promotion
        
        
        if (recipientAddressRecordTypeName != ConstantsSLB.getOther('Contact_Recordtype_Airline') 
                && recipientAddressRecordTypeName != ConstantsSLB.getOther('Contact_Recordtype_Overseas')) {
                  
            //instantiate variable param KCampang
            Map<String, Set<String>> mapPromoCodeContract = new Map<String, Set<String>>();
            if (searchText.length() > 1) {
                            
                string qry = 'select Promotion__c promoId, Promotion__r.Promotion_Code__c promoCode, Promotion__r.Name promoName, Promotion__r.Effective_Start_Date__c promoStartDate, Promotion__r.Effective_End_Date__c promoEndDate, ';
                qry += 'Promotion__r.Contract_Period__c promoContractPeriod from Promotion_Package__c where Promotion__r.Name like \'%' + searchText + '%\'';
                //Start D-1536 01/13/2015 Updated by James Aza?a: Exclude inactive Promotions
                //Start D-1544 01/16/2015 Updated by James Aza?a: Exclude Promotions where Active = false
                qry +=' and Promotion__r.Active__c = true and Promotion__r.Effective_Start_Date__c <= TODAY and Promotion__r.Effective_End_Date__c >= TODAY and Package_Name__r.Billing_Type__c=\'' + searchBillingType + '\' group by Promotion__c, Promotion__r.Effective_Start_Date__c,';//D - 2067 - 02-03/2015 - Joban - Modified the query to add the '=' operator
                //End D-1544 01/16/2015 Updated by James Aza?a
                //End D-1536 01/13/2015 Updated by James Aza?a
                
                
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
                    
                    //START:D-1629 2/5/15 Added by Manolo Vale?a - Added vdr for the new parameter of getEligibility method.
                    vdr = vnd(vendorEligibilityCheck);
                    promotionCodeMap = pRule.getEligibility(accountId, 'Add', mapPromoCodeContract, null, null, vdr);
                    //END:D-1629 2/5/15 Added by Manolo Vale?a
                    
                    for(String promoCode : promotionCodeMap.Keyset()){
                        if(promotionCodeMap.get(promoCode )!=null){
                            promotionCode_isEligible.put(promoCode , true);
                            promotionCode_isEligible.put(promoCode , true);
                        }
                        else{
                            promotionCode_isEligible.put(promoCode , false);
                        }
                    }
                    
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
    
    /************ end search functionality ***************/
    //START:D-1629 2/5/15 Added by Manolo Vale?a - Added static variable.
    static boolean vdr;
    //END:D-1629 2/5/15 Added by Manolo Vale?a
    
    //START:D-1629 2/5/15 Added by Manolo Vale?a - Convert boolean to static.
    private static boolean vnd(boolean v) 
    {
        return v;
    }
    //END:D-1629 2/5/15 Added by Manolo Vale?a
    
    @remoteAction
    public static string retrieveRelatedPackages(string promotionId, string billingType, String accountId, String action, String isEligibilityChecked) {
         
          String returnStr;
          Boolean isChecked; 
         //Start UD-0375 03-16-15 ABanaag - fixed by Manolo; change from on to true
         if(isEligibilityChecked == 'true'){
             isChecked = true;
         }
         //End UD-0375 03-16-15 ABanaag - fixed by Manolo
         else{
             isChecked = false;
         }
       
        if(isChecked == true){
            
            returnStr = SM_SubscriptionHelper.getRelatedPackages(promotionId, billingType);
        }
        else{
            //START:D-1629 2/5/15 Added by Manolo Vale?a - added vdr for the new parameter of getRelatedPackages method.
            //START D-2888 5/27/2015 Added by Manolo Valena - Added null for the new parameter of the method accepting the subscriptionId.
            returnStr = SM_SubscriptionHelper.getRelatedPackages(promotionId, billingType, accountId, action, vdr, null);
            //END D-2888 5/27/2015 Added by Manolo Valena
            //END:D-1629 2/5/15 Added by Manolo Vale?a
        }
        return returnStr;
    }
    //[JaSar] Check if there's an existing Subscription with same Address and Product Family
    public void checkAddressAndProductFamily() {     
        //Start UD-0333 03-13-2015 ABanaag
        orderLineItem.Charity__c = charityField;
        //End UD-0333 03-13-2015 ABanaag
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<zqu__ZProduct__c> zProductList = new List<zqu__ZProduct__c>();
        Set<String> productCodeSet = new Set<String>();
        Set<Id> addressIdSet = new Set<Id>();
        Set<String> productFamilySet = new Set<String>();
        Boolean isSameAddress = false;
        Boolean isSameProductFamily = false;
        result = false;
        Package__c pkg;
        Contact contact;
        
        //START UD1276 GDELROSARIO : added this to auto popuaate vendor for DIRECT SUBSCIRBER
        
                try {
                 Subscription_Vendor__c subVen = [SELECT Name,Vendor__c FROM Subscription_Vendor__c WHERE Id =: orderLineItem.Vendor_Subscription_ID__c ];        
                
                 orderLineItem.Vendor_Mailing_Agent__c = subVen.Vendor__c;
                 update orderLineItem;
            }catch(exception e){ 
                e.getStackTraceString();
            }
        
        //END UD 1276
        if (accountId != null) {
            subList = [SELECT Id, Name, Product_Code__c, Recipient_Contact__r.Address__c FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active' AND Zuora__Account__c = :accountId];
        }
            
        for (Zuora__Subscription__c sub :subList) {
            productCodeSet.add(sub.Product_Code__c);
            addressIdSet.add(sub.Recipient_Contact__r.Address__c);
        }
        
        if(productCodeSet != null) {
            zProductList = [SELECT Id, Name, ProductFamily__c, ProductCode__c FROM zqu__ZProduct__c WHERE ProductCode__c = :productCodeSet];
        }
            
        for (zqu__ZProduct__c zProduct :zProductList) {
            if (zProduct.ProductFamily__c != null) {
                productFamilySet.add(zProduct.ProductFamily__c);
            }
        }
        
        if (thisOrder.Recipient_Contact__c != null) {
            contact = [SELECT Id, Name, Address__c FROM Contact WHERE Id = :thisOrder.Recipient_Contact__c limit 1];
        }    
        if (!addressIdSet.isEmpty()) {
            if(contact != null && contact.Address__c != null) {
            if (addressIdSet.contains(contact.Address__c)) {
                isSameAddress = true;
            }
            }
        } 
         
        if (orderLineItem.Main_Package_ID__c != null) {
            pkg = [SELECT Id, Name, Product_Family_Current_Package__c FROM Package__c WHERE Id = :orderLineItem.Main_Package_ID__c];
            
            //START UD-3895 3/31/2016 Added by J.Sarion - moved code inside if condition when pkg is not null
            if (productFamilySet.contains(pkg.Product_Family_Current_Package__c)) {
                isSameProductFamily = true;
            }
            //END UD-3895 3/31/2016 Added by J.Sarion - moved code inside if condition when pkg is not null
        }
        
        if (isSameAddress && isSameProductFamily) {           
            result = true;
        }      
        
        try {
            update thisOrder;
        } catch(Exception e){
            ExceptionLogger.log(new list<exception> { e }); // Start/End D-2960 06Apr15 JohnD added log
        }
    }
    
    
    public void populateAddOn() {
        
        isPromotionSelected = true;
        
        //START: D-1329 12/22/14 Added by S.Puli to catch error
        try {
            if(selectedAddOnPackage<>null){
                orderLineItem.Addon_Package__c = selectedAddOnPackage;
            }
        } catch (exception e){
        }
        //END: D-1329 12/22/14 Added by S.Puli
        
        
        try {
            // Start UD-0759 Ronald Dagaraga Added package price on addonPackage //End 17Apr15
            addOnPackage = [select Id, Name, Package_Price__c, (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c  
                from Package_Items__r limit 1) from Package__c where Id = :selectedAddOnPackage];
                
            for (Package_Item__c tmp : addOnPackage.Package_Items__r) {
                orderLineItem.Add_On_Package_Product_Sub_Type__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c;
                orderLineItem.Add_On_Package_Product_Platform__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c;
                //Start D-1318/D-2196 02/10/2015/02/12/2015 Added by ABanaag/John - check if add on is digital
                if (tmp.Is_Digital__c == true) {
                    addOnIsDigital = true;
                    //START: D-4618 04/20/2016 Added by Kristine Balaoing - set oli to digital when 
                    orderLineItem.Is_Digital__c = true;
                    //END: D-4618 04/20/2016 Added by Kristine Balaoing
                }
                //End D-1318/D-2196 02/10/2015/02/12/2015 Added by ABanaag/John - check if add on is digital                
                
            }
            
            retrievePackageSubscriptionRate(new set<id>{addOnPackage.Id}, orderLineItem.Main_Package_Billing_Type__c);
            orderLineItem.Add_On_Package_Subscription_Rate__c = packageId_subscriptionCharge.get(addOnPackage.Id);
            
            // Start UD-0759 Ronald Dagaraga For Addonpackage package price 17Apr15
            if (addOnPackage.Package_Price__c != null) {
                subscriptionRate += addOnPackage.Package_Price__c;
            }
             // End UD-0759 Ronald Dagaraga For Addonpackage package price 17Apr15
            
        } catch (exception e) {
            addOnPackage = new Package__c();
        }
    //START: D-4618 04/20/2016 Added by Kristine Balaoing - retrieve newly added add on
        retrieveNewlyAddedAddOn();
    }

   @testVisible private void eraseCheckDetails() {
   //END: D-4618 04/20/2016 Added by Kristine Balaoing
        thisOrder.Check_Issuing_Bank__c = null;
        thisOrder.Check_No__c = null;
        thisOrder.Check_Dated__c = null;
        thisOrder.Check_Amount__c = null;
        thisOrder.Remarks_Check__c = null;
    }

    public PageReference save() {
        
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
                //Start MMallorca UD-1736 Add Bus Prof and Debt Mana for filter 06/30/2015
                if(searchCustTick == false && thisOrder.Create_ARMS_Customer_Account__c == false && thisOrder.Business_Profile__c == 'NONE' && thisOrder.Debt_Management_Treatment__c == 'NONE'){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS search for ARMS customer contact'));
                    ApexPages.addMessage(myMsg);
                    return null; 
        
                }else if((accNum != null || accNum != '') && (accTextName != null || accTextName != '') && searchAcctTick == false && thisOrder.Create_ARMS_Customer_Account__c  == false  && thisOrder.Business_Profile__c == 'NONE' && thisOrder.Debt_Management_Treatment__c == 'NONE'){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ''+ ConstantsSLB.getErrorMessage('ARMS search for arms account'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }  
                //End MMallorca UD-1736 06/30/2015
                //START UD-2390 08/19/2015 RReyes - Check if "Create New ARMS Customer & Account account" when creating New ARMS account
                if(thisOrder.Create_ARMS_Customer_Account__c == false && searchCustTick == false && (accNum == null || accNum == '') && (accTextName == null || accTextName == '')){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('Check New ARMS Account'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                //END UD-2390 08/19/2015 RReyes - Check if "Create New ARMS Customer & Account account" when creating New ARMS account
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
                
                If (thisOrder.ARMS_Account_Number__c <> null){
                    if (thisOrder.Debt_Management_Treatment__c <> DebtManagement) {
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('ARMS Debt Management') + GlobalVariableClass.BUSDEBT2  + DebtManagement + ')');
                            ApexPages.addMessage(myMsg);
                            return null;
                            thisOrder.Debt_Management_Treatment__c = DebtManagement;
                    }
            List<Zuora__CustomerAccount__c> updateOtherBillingAcc = [Select Id, ARMS_Business_Profile__c, ARMS_Debt_Management__c, ARMS_Account_Number__c, ARMS_Customer_Number__c From Zuora__CustomerAccount__c Where Zuora__Account__c = :thisOrder.Account__c AND ARMS_Customer_Number__c = :thisOrder.Customer_No__c ];
                    List<Zuora__CustomerAccount__c> OtherBillingAcctoUpdate = new List<Zuora__CustomerAccount__c>();
                                for(Zuora__CustomerAccount__c billacct : updateOtherBillingAcc) {
                                billacct.ARMS_Business_Profile__c = BusProfile;
                                billacct.ARMS_Debt_Management__c = DebtManagement;
                                billacct.ARMS_Account_Number__c = thisOrder.ARMS_Account_Number__c;
                                OtherBillingAcctoUpdate.add(billacct);
                            }
                            if(OtherBillingAcctoUpdate.size() > 0){update OtherBillingAcctoUpdate;}
                }
                //END UD-2805 Added by Dags Updated the conditions for UD-2375
             
            }
            
            //START:UD-2239 8/7/2015 Added by Manolo Valena - Added error message to prevent saving order if Billing Contact is null.
            if(thisOrder.Billing_Contact__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('Billing Contact Required'));
                ApexPages.addMessage(myMsg);
                return null;
            }
            //END:UD-2239 8/7/2015 Added by Manolo Valena
            //START UD-2370 8/19/15 addedBy FrancisBenzon : catch force input of wrong Billing Contact
            else {
                Contact inputtedContact = [Select AccountId, Billing_Indicator__c From Contact Where Id = :thisOrder.Billing_Contact__c];
                if(inputtedContact.AccountId != accountId || inputtedContact.Billing_Indicator__c == false)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.INVALID_BILLINGCONTACT)));
                    return null;
                }
            }
            //END UD-2370 8/19/15 addedBy FrancisBenzon : catch force input of wrong Billing Contact
            //START UD-2389 08/19/2015 RReyes - prevents save when payment mode = Other and Other Payment Mode is null
            if(thisOrder.Payment_Mode__c == 'Other' && (thisOrder.Other_Payment_Mode__c == '' || thisOrder.Other_Payment_Mode__c == null)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('Other Payment Mode is Null'));
                ApexPages.addMessage(myMsg);
                return null;
            }
            //END UD-2389 08/19/2015 RReyes - prevents save when payment mode = Other and Other Payment Mode is null
        }
         //END UD-1214 
        
        //START D-3382 CCB-135 04/Aug/15 Wenjun: Add Query Fields
         if(chooseAgent && (selectedMailingAgent == NULL || selectedMailingAgent == ''))
         {
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_CHOOSE_MAILING_AGENT));
            return null;  
         }
         //END D-3382 CCB-135 04/Aug/15 Wenjun
         
        //START UD-1488 06/08/2015 KAREN HUNG added validation: Business Profile and Debt Management Treatment cannnot be  "NONE" if payment method is invoice. 
        if((thisOrder.Business_Profile__c =='NONE' || thisOrder.Debt_Management_Treatment__c == 'NONE') && (thisOrder.Payment_Mode__c == 'Other' && thisOrder.Other_Payment_Mode__c == 'Invoice')){
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,ConstantsSLB.getErrorMessage('ARMSBusProfDebtMgt'));
            ApexPages.addMessage(myMsg1);
            return null;
        }
        //END UD-1488 06/08/2015 KAREN HUNG

       //START UD-1287 6/1/2015 Jean/Gio : Added validation rule for Saving Payment Method ID
        if(billingAccountOption == 'createNew'){
            if (thisOrder.Payment_Mode__c == 'Credit Card'){
                if(thisOrder.Payment_Method_ID__c == null || thisOrder.Payment_Method_ID__c == ''){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ ConstantsSLB.getErrorMessage('NoPaymentMethodID'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }    
            }   
        }            
        //END UD-1287
        parentId = ApexPages.currentPage().getParameters().get('def_parent_id');
               
         //START UD-0204 3/17/15 AddedBy FrancisBenzon : variable set of MainPackageBillingType
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
        //Start UD-0698 Added by Ronald dagaraga 4/10/2015
        String error_InternalPaymentMode = GlobalVariableClass.ERROR_INTERNALPAYMENTMODE_INVOICE;
        Set<String> otherPaymentInternalModeSet = new Set<String>{enets, externalParties, ipp};
        //End UD-0698 Added by Ronald dagaraga 4/10/2015
        Set<String> paymentModeSet = new Set<String>{cash, check};
        //Start D-3269 7/23/15 AddedBy FrancisBenzon : removed external parties and internal charge payment mode
        Set<String> otherPaymentModeSet = new Set<String>{enets, ipp};
        //End D-3269 7/23/15 AddedBy FrancisBenzon : removed external parties and internal charge payment mode
        //END UD-0204 3/17/15 AddedBy FrancisBenzon : variable set of MainPackageBillingType
        
        // update
        thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType;
        //START D-3001 22-05-2015 Marvin G
        //populateRecipientContactRelatedDetails();
        // START D-3030 K. Tan/ Marvin G. Additional line item for the defect 
         thisOrder.vendor_Credit__c = vendorCredit; 
        // END D-3030 K. Tan/ Marvin G. Additional line item for the defect          
         
         
        //END D-3001 22-05-2015 Marvin G
        thisOrder.Status__c = 'Draft';
        // thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account'; // Start/End UD-2614 06Sep15 JohnD - commented out
        //thisOrder.Delivery_Charge__c = 0;
        // Start UD-2614 06Sep15 JohnD - added logic
        if (billingAccountOption == 'createNew') {
            thisOrder.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        } else if (billingAccountOption == 'useExisting') {
            thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        }
        // End UD-2614 06Sep15 JohnD - added logic
        
        // additional fields to populate        
        thisOrder.Account_Name__c = thisOrder.Account__r.name;
        thisOrder.Account_Number__c = thisOrder.Account__r.AccountNumber;        
        thisOrder.PO_Number__c = orderLineItem.PO_Number__c;
        
        try{
            thisOrder.Billing_Account_ID__c = thisOrder.Billing_Account__c;
            if(thisBillingAccount.Zuora__Credit_Balance__c != null){
                thisOrder.Credit_Amount__c = thisBillingAccount.Zuora__Credit_Balance__c;
            } else {
                thisOrder.Credit_Amount__c = 0;
            }
        } catch(Exception e){
        }                                
        
        try{     
            if(thisOrder.Payment_Mode__c == null){
                if(thisBillingAccount.Zuora__PaymentMethod_Type__c != null){
                    thisOrder.Billing_Type__c = thisBillingAccount.Zuora__PaymentMethod_Type__c;
                }
            }
        } catch(Exception e){
        }
        // end 
        
        //START D-3223 07/09/15 RReyes - validates if order has billing account
        if(!hasBillingAccount('START', thisOrder)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('No Billing Account')));
            return null; 
        }
        //END D-3223 07/09/15 RReyes - validates if order has billing account 

        if(billingAccountOption == 'useExisting' && thisOrder.Billing_Account__c == NULL){
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.WARNING, 'Please complete the Billing Details.')); 
        }
        else if(billingAccountOption == NULL){
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.WARNING, 'Please complete the Billing Details.')); 
        }
        else if(billingAccountOption == 'createNew' && thisOrder.Payment_Mode__c == NULL){
            ApexPages.addMessage(new APexPages.Message(ApexPages.severity.WARNING, 'Please complete the Billing Details.')); 
        }//START: UD-0673 04/13/2015 RReyes - Added validation to prevent saving with incomplete Check details/ Amount due
        //START UD-3278 20Nov15 AddedBy FrancisBenzon : added new validation        
        // Start UD-3278 27Nov15 JohnD - commented out string.valueof criteria it will lead to null pointer    
        //START D-4153 21-Dec-2015 Added By S.Puli/JohnD
        else if(thisOrder.Payment_Mode__c == 'Check' &&  (thisOrder.Check_Issuing_Bank__c == null || thisOrder.Check_No__c == null || thisOrder.Check_Dated__c == null ||
                thisOrder.Check_Amount__c == null /*|| String.valueOf(thisOrder.Check_Issuing_Bank__c) == '' ||  String.valueOf(thisOrder.Check_No__c) == '' ||  
                String.valueOf(thisOrder.Check_Dated__c) == '' ||  String.valueOf(thisOrder.Check_Amount__c) == ''*/) && renderCheckDetails != null && renderCheckDetails){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please complete check details');
            ApexPages.addMessage(myMsg);
        } 
        //END D-4153 21-Dec-2015 Added By S.Puli/JohnD
        // End UD-3278 27Nov15 JohnD - commented out string.valueof criteria it will lead to null pointer
        /*else if(thisOrder.Payment_Mode__c == 'Check' &&  thisOrder.Check_Amount__c != null && thisOrder.Check_Amount__c < thisOrder.Full_Prepaid_Inc_Del_Charge__c){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Amount must be greater than total amount due.');
                    ApexPages.addMessage(myMsg);
        }*/
        //END UD-3278 20Nov15 AddedBy FrancisBenzon : added new validation
        //END: UD-0673 04/13/2015 RReyes - Added validation to prevent saving with incomplete Check details/ Amount due
        else{
            
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
                    //thisOrder.Other_Payment_Mode__c = null;
                    thisOrder.Amount_Paid__c = null;
                    eraseCheckDetails();
                }
                
            } else if (billingAccountOption == 'useExisting') {
                // thisOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account'; // Start/End UD-2614 09Sep15 JohnD - moved above
                thisOrder.Payment_Method_ID__c = null;
                // Start D-3402 17Aug15 JohnD - revised logic in retrieving billing contact. commented out previous logic
                //START/END UD-0204 FrancisBenzon : commented out below code line
                /*
                Id ContactRecordType = ConstantsSLB.getKeyId('Contact_Customer Contact');               
                //START CCB.002 Modified by: Francis Benzon  
                try {
                    Contact billCon = [SELECT Id FROM Contact WHERE AccountId = :accountId AND RecordTypeId = :ContactRecordType AND Billing_Indicator__c = true LIMIT 1];                      
                    if(billCon.Id != null || billCon.Id != ''){
                        thisOrder.Billing_Contact__c = billCon.Id;
                    }else{
                        thisOrder.Billing_Contact__c = null;
                    }
                }
                catch(exception e) {
                    Contact billCon = new Contact();
                }
                */ 
                //END CCB.002 Modified by: Francis Benzon
                if (thisOrder.Billing_Account__c != null) {
                    try {
                        thisOrder.Billing_Contact__c = [select Billing_Contact__c from zuora__CustomerAccount__c where Id = :thisOrder.Billing_Account__c].Billing_Contact__c;
                    } catch (exception e) {
                        thisOrder.Billing_Contact__c = null;
                    }
                }
                // End D-3402 17Aug15 JohnD - revised logic in retrieving billing contact. commented out previous logic
                //START UD-0673 04/13/15 RReyes - Added condition to prevent check details from being erased
                if(thisOrder.Payment_Mode__c != 'Check'){
                         eraseCheckDetails(); 
                   }
                //END UD-0673 04/13/15 RReyes
                //START D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to blank if payment mode is not "Other"
                if (thisOrder.Payment_Mode__c != 'Other'){
                thisOrder.Other_Payment_Mode__c = '';}
                //END D-3039 06/03/15 RReyes - Set Other_Payment_Mode__c to null if payment mode is not "Other"
            }
            //START UD-3278 20Nov15 AddedBy FrancisBenzon : check CHEQUE AMOUNT   
            // Start UD-3278 27Nov15 JohnD - slightly modified expression
            //START D-4153 21-Dec-2015 Added By S.Puli/JohnD
            if(renderCheckDetails != null && renderCheckDetails == false && thisOrder.Total_Due_to_SPH__c != null && thisOrder.Total_Due_to_SPH__c != 0  && thisOrder.Payment_Mode__c == GlobalVariableClass.CHEQUE)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantsSLB.getErrorMessage('ReselectCheckBillingAccount')));
                return null;
            }
            // End UD-3278 27Nov15 JohnD - slightly modified expression
            
            if(thisOrder.Payment_Mode__c == GlobalVariableClass.CHEQUE && thisOrder.Check_Amount__c < thisOrder.Total_Due_to_SPH__c && renderCheckDetails != null && renderCheckDetails)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('ChequeAmountChecking')));
                return null;
            }
            //END D-4153 21-Dec-2015 Added By S.Puli/JohnD
            //END UD-3278 20Nov15 AddedBy FrancisBenzon : check CHEQUE AMOUNT
            try {
                //Start D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
                computePrepaid();
                //Start D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
                
                //START D-3002 22-05-2015 Marvin G   
                 selectedDeliveryChargeType  = thisOrder.Delivery_Charge_Type__c;

                // Start D-3169 24Jun15 JohnD - revised logic in getting the subscriber charge and vendor credit
                
                list<Order_Line_Item__c> oliListTmp = [select id from Order_Line_Item__c where Order__c = :thisOrder.Id and Delivered_By__c = :GlobalVariableClass.VENDOR limit 1];
                
                if (oliListTmp != null && !oliListTmp.isEmpty()) {
                    map<string, decimal> charges = getCharges(thisOrder.Recipient_Contact__c, 
                               selectedDeliveryChargeType , thisOrder.Subscriber_Charge__c, vendorCredit);   // Start/End hotfix 26Jun15 JohnD - replaced subscriberCharge to thisOrder.Subscriber_Charge__c in the parameter
                    
                    thisOrder.Subscriber_Charge__c = charges.get('SubscriberCharge');
                    thisOrder.Vendor_Credit__c = charges.get('VendorCredit');
                
                } else {
                
                    thisOrder.Subscriber_Charge__c = null;
                    thisOrder.Vendor_Credit__c = null;
                
                }
                // End D-3169 24Jun15 JohnD - revised logic in getting the subscriber charge and vendor credit
                
                     
        


                 //END D-3002 22-05-2015 Marvin G
                update thisOrder;
                if(thisOrder.Id != null){
                    //START UD-0204 3/17/15 AddedBy FrancisBenzon : if List of OLI has Recurring, throw validation
                    oliList = getOrderLineItems(thisOrder.Id);
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
                            //Start UD-0698 Added by Ronald dagaraga 4/10/2015
                            If (thisaccount.recordtypeid == ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')) {
                               if(paymentModeSet.contains(thisOrder.Payment_Mode__c) || (thisOrder.Payment_Mode__c == otherPaymentMode && otherPaymentInternalModeSet.contains(thisOrder.Other_Payment_Mode__c)))
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(error_InternalPaymentMode)));
                                    return null;
                                } 
                             }  
                             else {
                                if(paymentModeSet.contains(thisOrder.Payment_Mode__c) || (thisOrder.Payment_Mode__c == otherPaymentMode && otherPaymentModeSet.contains(thisOrder.Other_Payment_Mode__c)))
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(error_PaymentMode)));
                                    return null;
                                }           
                             }
                             //End UD-0698 Added by Ronald dagaraga 4/10/2015
                        }                    
                    }
                    //END UD-0204 3/17/15 AddedBy FrancisBenzon : if List of OLI has Recurring, throw validation
                   
                }
                
                //Start UD-678 VPernicia/MGatchalian 4/06/2015: Update quote Billing contact
                
                    //Start UD-1560 and UD-1562 K. Tan - to select billing Account with the same Billing type of Order Line Item
                    if(thisOrder.Billing_Account__c != null){
                    
                        List<Zuora__Subscription__c>  zsub = [SELECT Id, Zuora__CustomerAccount__c, Billing_Type__c FROM Zuora__Subscription__c WHERE Zuora__CustomerAccount__c =: thisOrder.Billing_Account__c  AND Billing_Type__c != null AND Zuora__Status__c = 'Active' LIMIT 1] ;
                        
                        if(oliList.size()>0 && zsub != null && !zsub.isEmpty()){ //START/END D-3297 7/29/15 AddedBy FrancisBenzon : avoid apex error
                            if(oliList[0].Main_Package_Billing_Type__c <> zsub[0].Billing_Type__c){
                                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR,('Select Billing Account with has a Billing Type that is equal to Main Package Billing Type')));    
                                return null;
                            }
                            
                        }
                            
                    }
                    //END UD-1560 and UD-1562 K. Tan / - to select billing Account with the same Billing type of Order Line Item           
                list<id> lstofOrderLine = new list<id>();
            
                for (Order_Line_Item__c OliLists: [select id, (select id from Order_Line_Item_Gifts__r) from Order_Line_Item__c where Order__c =: thisOrder.id]) {
                    lstofOrderLine.add(OliLists.id);
                    
                    for (Order_Line_Item_Gift__c OliGiftList: OliLists.Order_Line_Item_Gifts__r) {
                        lstofOrderLine.add(OliGiftList.id);
                    }
                }
                
                //START UD-3339 12/02/2015 RReyes
                try{
                    if(thisOrder!= null && (thisOrder.Name != null && thisOrder.Name != '')){
                        Set<Id> setAsia1Id = new Set<Id>();
                        for(Asia1__c as1 :[SELECT Id FROM Asia1__c WHERE Order_Number__c =:thisOrder.Name]){
                            if(as1.Id != null){
                                setAsia1Id.add(as1.Id);
                            }
                        }   
                        if(setAsia1Id.size() > 0){
                            for(Asia1_Subscription__c as1Sub:[SELECT Id, Asia1__c FROM Asia1_Subscription__c WHERE Asia1__c IN:setAsia1Id]){
                                if(as1Sub.Asia1__c != null){
                                    if(setAsia1Id.contains(as1Sub.Asia1__c)){
                                        setAsia1Id.remove(as1Sub.Asia1__c);
                                    }
                                }
                            }
                        }
                        if(setAsia1Id.size() > 0){
                            delete [SELECT id FROM Asia1__c WHERE Id IN:setAsia1Id AND Status__c = 'Pending Creation'];
                        }
                    }
                }catch(exception e){
                    System.debug('ASIA1 DELETION FAILED: ' + e);
                }
                //END UD-3339 12/02/2015 RReyes
                
                list<zqu__Quote__c> QuoteListBillingContact = new list<zqu__Quote__c>();
                //Start D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
                list<zqu__QuoteCharge__c> QuoteChargeList = new list<zqu__QuoteCharge__c>();
                set<id> QuoteListBillingContactIds = new set<id>();
                //START D-3231 Wenjun 08/07/15
                Set<ID> setOLIForN = new Set<ID>();
                //END D-3231 Wenjun 08/07/15
                
                //START D-3002 22-05-2015 MarvinG
                set<id> QuoteDeliverAndPostageIDs = new set<id>();
                //END D-3002 22-05-2015 MarvinG
                
                //START UD-1317 06/08/2015 Added by J. Sarion - Create new quotes for Freelist to Other Payment Method]
                List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
                
                if (!lstofOrderLine.isEmpty()) {
                    quoteList = [select id, zqu__BillToContact__c, Subscription_Type__c,
                    zqu__PaymentTerm__c, Subscriber_Charge__c, Delivery_Charge_Type__c, zqu__PaymentMethod__c, 
                    Payment_Mode__c, Other_PaymentMethod__c,Order_Line_Item_Number_1__c //START END D-3231 Wenjun 08/07/15 - Add Order Line Item Number
                    from zqu__Quote__c where Order_Line_Item_Number_1__c in: lstofOrderLine];
                }
              
                /* START  UD-2951 / UD-3054 1/10/2015 Gdelrosario : change the condition and update the code block to update postage to 0 */
                if (thisOrder.Payment_Mode__c == 'Other' && thisOrder.Other_Payment_Mode__c == 'Freelist') {
                
                    List<Order_Line_Item__c> updatePostCharge = new List<Order_Line_Item__c>();
                    //START: UD-3064 10/20/15 Added by Manolo Valena
                    Set<Id> setOliId = new Set<Id>();
                    //END: UD-3064 10/20/15 Added by Manolo Valena
                    delete quoteList;
                    
                    for (Order_Line_Item__c oli :oliList) {
                        oli.Postage_Charge__c = 0;  
                        updatePostCharge.add(oli);
                    }
                    
                    update updatePostCharge;
                    queryOrder(); 
                    
                    for (Order_Line_Item__c updatedOli :[select id from Order_Line_Item__c where Order__c = :thisOrder.Id]){
                        Quote_Handler QH = new Quote_Handler();
                        QH.Create_Quotes(thisOrder, 'Start Subscription', updatedOli.id);
                        //START: UD-3064 10/20/15 Added by Manolo Valena
                        setOliId.add(updatedOli.id);
                        //END: UD-3064 10/20/15 Added by Manolo Valena
                    }
                    
                    //START: UD-3064 10/20/15 Added by Manolo Valena
                    if(!setOliId.isEmpty()){
                        quoteList = [SELECT id, zqu__BillToContact__c, Subscription_Type__c, zqu__PaymentTerm__c, 
                                            Subscriber_Charge__c, Delivery_Charge_Type__c, zqu__PaymentMethod__c, 
                                            Payment_Mode__c, Other_PaymentMethod__c,Order_Line_Item_Number_1__c
                                     FROM zqu__Quote__c 
                                     WHERE Order_Line_Item_Number_1__c IN: setOliId];
                    }
                    
                    for (zqu__Quote__c quote : quoteList) {
                        quote.Vendor_Credit__c = thisOrder.Vendor_Credit__c;
                        quote.zqu__BillToContact__c = thisOrder.Billing_Contact__c;
                        quote.Payment_Mode__c = thisOrder.Payment_Mode__c;
                        quote.zqu__PaymentMethod__c = thisOrder.Payment_Mode__c;
                        quote.Delivery_Charge_Type__c = thisOrder.Delivery_Charge_Type__c;
                        quote.Subscriber_Charge__c = thisOrder.Subscriber_Charge__c;
                        quote.Other_PaymentMethod__c = thisOrder.Other_Payment_Mode__c;

                        if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
                            quote.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBL;
                        }
                        else if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
                            quote.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBH;
                        }
                        else if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
                            quote.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_GOVT;   
                        }
                        else {
                            quote.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_NORM;
                        }

                        QuoteListBillingContact.add(quote);
                            
                        if (quote.Subscription_Type__c == 'Publication' && quote.Other_PaymentMethod__c == 'Freelist') {
                            QuoteDeliverAndPostageIDs.add(quote.id);
                        }
                    }

                    list<zqu__QuoteCharge__c> QuoteChargeListDelAndPostal = new list<zqu__QuoteCharge__c>();
                    
                    for(zqu__QuoteCharge__c qc : [SELECT ID, Name, zqu__EffectivePrice__c, zqu__UOM__c, zqu__ListPrice__c, 
                                                         zqu__ListPriceDisplay__c, zqu__Quote__r.Subscription_Type__c 
                                                  FROM zqu__QuoteCharge__c 
                                                  WHERE zqu__Quote__c IN: QuoteDeliverAndPostageIDs]) {
      
                        if (qc.zqu__Quote__r.Subscription_Type__c == 'Publication' && qc.Name != 'Adjustment') {
                            qc.zqu__ListPriceDisplay__c = 0;
                            qc.zqu__EffectivePrice__c = 0;
                        }       
                        QuoteChargeListDelAndPostal.add(qc);
                    }
                    update QuoteListBillingContact;
                    update QuoteChargeListDelAndPostal;
                    //END: UD-3064 10/20/15 Added by Manolo Valena
                }
                /* END UD-2951 /UD-3054 1/10/2015 Gdelrosario : change the condition and update the code block to update postage to 0 */
                else {
                    for (zqu__Quote__c quote :quoteList) {
                        //START D-3002 22-05-2015 MarvinG
                        //START D-3030 26-05-2015 MarvinG
                        //if (quote.Subscription_Type__c == 'Delivery' || quote.Subscription_Type__c == 'Postage') {
                        if (quote.Subscription_Type__c == 'Delivery') {
                        //END D-3030 26-05-2015 MarvinG
                            QuoteDeliverAndPostageIDs.add(quote.id);
                        }

                         quote.Vendor_Credit__c = thisOrder.Vendor_Credit__c;
                        //END D-3002 22-05-2015 MarvinG
                        system.debug('\n\n quote.Subscription_Type__c= ' + thisOrder + '\n\n');
                        quote.zqu__BillToContact__c = thisOrder.Billing_Contact__c;
                        quote.Payment_Mode__c = thisOrder.Payment_Mode__c;
                        quote.zqu__PaymentMethod__c = thisOrder.Payment_Mode__c;
                        quote.Delivery_Charge_Type__c = thisOrder.Delivery_Charge_Type__c;
                        quote.Subscriber_Charge__c = thisOrder.Subscriber_Charge__c;
                        quote.Other_PaymentMethod__c = thisOrder.Other_Payment_Mode__c;

                        //START D-2847 05-06-2015 von/Marvin G
                        if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
                            quote.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBL;
                        }
                        else if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
                            quote.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_SUBH;
                        }
                        else if(thisOrder.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
                            quote.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_GOVT;   
                        }
                        else {
                            quote.zqu__PaymentTerm__c = GlobalVariableClass.PAYMENT_TERM_NORM;
                        }
                        //END D-2847 05-06-2015 von/Marvin G

                        QuoteListBillingContact.add(quote);
                        system.debug('\n\n quote.Subscription_Type__c= ' + quote.Subscription_Type__c + '\n\n');
                        system.debug('\n\n quote.Delivery_Charge_Type__c= ' + quote.Delivery_Charge_Type__c + '\n\n');
                        if(quote.Subscription_Type__c=='Delivery' && quote.Delivery_Charge_Type__c=='S')
                            QuoteListBillingContactIds.add(quote.id);
                            
                        //START UD-1317 06/05/2015 Added by J. Sarion - Set Price to 0 for Publications with Delivery Charge Type = N
                        if (quote.Subscription_Type__c == 'Publication' && quote.Other_PaymentMethod__c == 'Freelist') {
                            QuoteDeliverAndPostageIDs.add(quote.id);
                        }
                        //END UD-1317 06/05/2015 Added by J. Sarion - Set Price to 0 for Publications with Delivery Charge Type = N
                    }
                    //START D-3231 Wenjun 08/07/15 : Set Overlapped Subs with Delivery Charge Type as N
                    if(thisOrder.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID && oliList.size() > 1 
                    && thisOrder.Delivery_Charge_Type__c != 'N' && thisOrder.Delivery_Charge_Type__c != 'Z')
                    {
                        Order_Line_Item__c masterOli = SM_SubscriptionHelper.getLongestOrderLineItem(oliList);
                        if(masterOli != NULL)
                        {
                            for(Order_Line_Item__c oli : oliList)
                            {
                                if(oli.ID != masterOli.ID)
                                    setOLIForN.add(oli.ID);
                            }
                            
                            for (zqu__Quote__c quote :quoteList) {
                                if(setOLIForN.contains(quote.Order_Line_Item_Number_1__c))
                                    quote.Delivery_Charge_Type__c = 'N';
                            }
                        }
                    }
                    //END D-3231 Wenjun 08/07/15

                        for(zqu__QuoteCharge__c qc : [SELECT ID, zqu__EffectivePrice__c, zqu__UOM__c, zqu__ListPrice__c, zqu__ListPriceDisplay__c 
                        from zqu__QuoteCharge__c Where zqu__Quote__c in : QuoteListBillingContactIds]){
                            decimal subCharge = thisOrder.Subscriber_Charge__c;
                            qc.zqu__EffectivePrice__c = (!qc.zqu__UOM__c.contains('Credit')) ? subCharge : -subCharge;
                            qc.zqu__ListPriceDisplay__c = (!qc.zqu__UOM__c.contains('Credit')) ? subCharge : -subCharge;
                          
                            QuoteChargeList.add(qc);
                        }

                        //START D-3002 22-05-2015 MarvinG
                        list<zqu__QuoteCharge__c> QuoteChargeListDelAndPostal = new list<zqu__QuoteCharge__c>();
                        
                        
                        //START UD-1317 06/08/2015 Added by J. Sarion - Set Price to 0
                        //START D-3231 Wenjun 08/07/15 : Set Overlapped Subs with Delivery Charge Type as N
                        for(zqu__QuoteCharge__c qc : [SELECT ID, Name, zqu__EffectivePrice__c, zqu__UOM__c, zqu__ListPrice__c, 
                                        zqu__ListPriceDisplay__c, zqu__Quote__r.Subscription_Type__c,zqu__Quote__r.Order_Line_Item_Number_1__c  
                                        from zqu__QuoteCharge__c Where zqu__Quote__c in : QuoteDeliverAndPostageIDs]){
                                        
                            decimal subCharge = thisOrder.Subscriber_Charge__c;

                            if(setOLIForN.contains(qc.zqu__Quote__r.Order_Line_Item_Number_1__c) 
                            && qc.zqu__Quote__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY)
                            {
                                qc.zqu__ListPriceDisplay__c = 0;
                                qc.zqu__EffectivePrice__c = 0;
                            }
                            else if( qc.Name == GlobalVariableClass.DUMMY_CHARGE) {
                                qc.zqu__ListPriceDisplay__c = 0;
                                qc.zqu__EffectivePrice__c = 0;
                            }
                        //END D-3231 Wenjun 08/07/15
                            //start added to avoid attempt to de-reference null
                            else if (qc.zqu__UOM__c <> null && qc.zqu__UOM__c.contains('Credit') && qc.zqu__Quote__r.Subscription_Type__c == 'Delivery') {
                            //end added to avoid attempt to de-reference null
                                qc.zqu__ListPriceDisplay__c = subCharge * -1;
                                qc.zqu__EffectivePrice__c = subCharge * -1;
                            }
                            else {
                                  qc.zqu__ListPriceDisplay__c = subCharge;
                                  qc.zqu__EffectivePrice__c = subCharge;
                                  
                                  if (qc.zqu__Quote__r.Subscription_Type__c == 'Publication') {
                                      qc.zqu__ListPriceDisplay__c = 0;
                                      qc.zqu__EffectivePrice__c = 0;
                                  }
                            }              
                            QuoteChargeListDelAndPostal.add(qc);
                        }
                        //END UD-1317 06/08/2015 Added by J. Sarion - Set Price to 0
                          
                        
                    update QuoteListBillingContact;
                    update QuoteChargeList;
                    update QuoteChargeListDelAndPostal;
                    //END D-3002 22-05-2015 MarvinG   
                    
                                                                    //Start D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
                    //End UD-678 VPernicia/MGatchalian 4/06/2015: Update quote Billing contact
                }
                //END UD-1317 06/08/2015 Added by J. Sarion - Create new quotes for Freelist to Other Payment Method
                
                string retUrl = '/apex/SM_StartSubscriptionDetail?id=' + thisOrder.Id + '&accountId=' + thisOrder.Account__c
                                                    + '&def_parent_id=' + parentId;
                
                PageReference pgRef = new PageReference(retUrl);
                pgRef.setRedirect(true);
                
                return pgRef;
                
            } 
            catch (exception e) {
                ApexPages.addMessages(e);
                system.debug(':::ERROR ' + e + ' ' + e.getStacktraceString());
            }    
        }
        return null;
    }
    
    public PageReference cancel() {
        
        if (thisOrder.Status__c == 'New') {
            delete [select id from Order_Line_Item__c where Order__c = :thisOrder.Id];
            delete [select id from Order__c where Id = :thisOrder.Id];
            //START D-3305 8/6/15 AddedBy Francisbenzon : delete Asia1 when user cancels order
            deleteRelatedAsia1();
            //END D-3305 8/6/15 AddedBy Francisbenzon : delete Asia1 when user cancels order
        }
        
        string retURl = '/' + thisOrder.Account__c;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
    }

    // start gifts
    public class GiftWrapper {
        
        public boolean selectGift { get; set; }
        public Promotion_Gift__c promotionGift { get; set; }
    } 
    
    public void  populatePromotionGifts() {
        
        promotionGifts = new list<GiftWrapper>();
        
        //D-0739 && D-0742 && D-0720 [Jayson S] Get Maximum No. of Gifts
        Promotion__c promo = [SELECT Id, Maximum_No_of_gifts_allowed__c FROM Promotion__c WHERE Id = :selectedPromotionId];
        
        if(promo.Maximum_No_of_gifts_allowed__c != null){
            maxNoOfGifts = integer.valueOf(promo.Maximum_No_of_gifts_allowed__c);
        }
        
        // Start UD-2236 07Aug15 JohnD - replaced "Balance_Quantity__c" to "Balance_Quantity_New__c"
        for (Promotion_Gift__c pg : [select Id, Gift__c, Gift__r.Name, Gift__r.Gift_Type__c, Gift__r.Gift_Cost__c, 
                Balance_Quantity_New__c, Gift__r.One_Time_Charge__c from Promotion_Gift__c where Promotion__c = :selectedPromotionId]) {
                    
            GiftWrapper gw = new GiftWrapper();
            gw.selectGift = false;
            gw.promotionGift = pg;
            
            promotionGifts.add(gw); 
        }
        // End UD-2236 07Aug15 JohnD - replaced "Balance_Quantity__c" to "Balance_Quantity_New__c"
    }
    // end gifst

    public void populateSubscriptionDetail() {
    //Start UD-0593 03-27-15 - ABanaag
        selectedGifts = 0;
    //End UD-0593 03-27-15 - ABanaag
        set<id> packageIds = new set<id>();
        set<id> productIds = new set<id>();
        isDigital = false;
        isFromPromotion = false;
    //Start D-0070 03-12-15 ABanaag 
        List<Product_Publication__c> publicationDetailList = new List<Product_Publication__c>();
    //End D-0070 03-12-15 ABanaag 
        isAllInOne = false;
        deliveryMethod = new list<SelectOption>();
        orderLineItem = new Order_Line_Item__c();       
        initializeAsia1Components();
        //start D-1394 02/05/15 added by ABanaag
        productIsMagazine = false;
        //end D-1394 02/05/15 added by ABanaag
        //start D-2390 02/27/15 added by ABanaag
        isFullPrepaid = false;
        //end D-2390 02/27/15 added by ABanaag
        
        // check if package is from promotion
        list<string> packageIdpromotionId = selectedPackageId.split(':');
        id pkgId = packageIdpromotionId[0];
        // end check if package is from promotion
        
        //START UD-0198 03-12-2015 Marvin Gatchalian
        deleteRelatedAsia1();
        //END UD-0198 03-12-2015 Marvin Gatchalian   
        addOnPackage = new Package__c(); //START/END UD-3405 RReyes 12/21/15
        
        //START UAT D-0080 Marvin Gatchalian - added Package_Price__c as this is where subscription rate will be based.
        //START D-1689 22/01/15 Wenjun : Fetch Package Item Record Type
        //START D-1624 29/1/16 MGaelo for Add On filter criteria: Product Family added Product_Family_Current_Package__c
        //// Start/End D-3072 UAT 08-06-2015 Gdelrosario added Product_Rate_Plan__r.RatePlanType__c field in the 
        Package__c pkg = [select Id, Package_Price__c, Package_Code__c, Name, Subscription_Type__c, 
                Package_Sub_Type__c, Subscription_Period__c, Product_Family_Current_Package__c, Billing_Type__c, Package_Type__c, 
                (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, RecordType.DeveloperName, 
                Product_Rate_Plan__r.SubscriptionFrequency__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c,Product_Rate_Plan__r.RatePlanType__c 
                from Package_Items__r) from Package__c where Id = :pkgId];
        //END D-1624 29/1/16 MGaelo for Add On filter criteria: Product Family added Product_Family_Current_Package__c
        //END D-1689 22/01/15 Wenjun
        //END UAT D-0080 Marvin Gatchalian - added Package_Price__c as this is where subscription rate will be based.
        
        //start D-2390 02/27/15 added by ABanaag
        if(pkg.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID){
            isFullPrepaid = true;
        }
        //end D-2390 02/27/15 added by ABanaag        
        
        // invoke package subscription rate retrieval        
        packageIds.add(pkgId);
        retrievePackageSubscriptionRate(packageIds, searchBillingType);
        // end invoke package subscription rate retrieval 
        
        selectedPackageName = pkg.Name;
        orderLineItem.Order__c = thisOrder.Id;
        
        //START UAT D-0080 Marvin Gatchalian - added Package_Price__c as this is where subscription rate will be based.
        orderLineItem.Main_Package_Subscription_Rate__c = pkg.Package_Price__c;
        //orderLineItem.Main_Package_Subscription_Rate__c = packageId_subscriptionCharge.get(pkgId);
        //END UAT D-0080 Marvin Gatchalian - added Package_Price__c as this is where subscription rate will be based.
        
        //Start D-1307 01-30-2015 FrancisBenzon : dummy field for base value of subscription rate plan, called in vfPage
        // Start D-0105 UAT 01-03-2015 JohnD assign subscriptionRate for VF page
        //Start MMallorca D-3053 06/18/2015 as per GIO
        subscriptionRate = pkg.Package_Price__c;
        //End MMallorca D-3053 06/18/2015 as per GIO
        // End D-0105 UAT 01-03-2015 JohnD
        //End D-1307  01-30-2015 FrancisBenzon : dummy field for base value of subscription rate plan, called in vfPage
        
        //START UD1276 5/27/2015 GdelRosario : added for auto populate of Parent ID       
        try{
            Account acnt = [SELECT Id,Name,ParentId,RecordTypeId 
                            FROM Account 
                            WHERE Id =: thisOrder.Account__c
                            AND ParentId != null];
         
                orderLineItem.Parent_Account__c = acnt.ParentId; 
            
        }catch(exception e){
            e.getStackTraceString();
        }
       
        
        //END UD1276    
        
        orderLineItem.Main_Package_ID__c = pkgId; 
        orderLineItem.Qty__c = 1;
        orderLineItem.Main_Package_Billing_Type__c = pkg.Billing_Type__c;
        orderLineItem.Main_Package_Frequency__c = 'Default';
        orderLineItem.Main_Package_Sub_Type__c = pkg.Subscription_Type__c;
        orderLineItem.Main_Package_Type__c = pkg.Package_Type__c;
        orderLineItem.Subscribed_as__c = 'New Buy';
        //START D-1624 29/1/16 MGaelo for Add On filter criteria: Product Family added Product_Family_Current_Package__c
        orderLineItem.Main_Package_Product_Family__c = pkg.Product_Family_Current_Package__c;
        //END D-1624 29/1/16 MGaelo for Add On filter criteria: Product Family added Product_Family_Current_Package__c
        try
        {
                totalSubscriptionPrice = pkg.Package_Price__c * orderLineItem.Qty__c; // Start UD-0759 Ronald Dagaraga //End 17Apr15 - added variable
        }
        catch(Exception e) {}
        
        if (pkg.Subscription_Period__c != null && pkg.Subscription_Period__c != 'N/A') {
            orderLineItem.Main_Package_Period__c = integer.valueOf(pkg.Subscription_Period__c);
            orderLineItem.Term_Length__c =  integer.valueOf(pkg.Subscription_Period__c);
        } else {
            orderLineItem.Main_Package_Period__c = 0;
            orderLineItem.Term_Length__c = 0;
        }
        //Start D-2390 03-0215 ABanaag - use string value to avoid Apex error: must resolve to string type
        termLength = string.valueOf(orderLineItem.Term_Length__c);
        //End D-2390 03-0215 ABanaag - use string value to avoid Apex error: must resolve to string type        
        for (Package_Item__c tmp : pkg.Package_Items__r) {
            
            productIds.add(tmp.Product_Rate_Plan__r.zqu__ZProduct__c);
            
            //START D-1689 22/01/15 Wenjun : The following logic shall only be applicable for "Product" 
            //Logic: isDigital, isAllInOne, Main_Package_Frequency__c, Main_Package_Product_Sub_Type__c and Main_Package_Product_Platform__c
            if(tmp.RecordType.DeveloperName.contains('Product'))
            {
                if (tmp.Is_Digital__c == true) {
                    isDigital = true;
                    orderLineItem.Is_Digital__c = true;
                }
                
                if (tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c == 'All-In-One') {
                    isAllInOne = true;
                    orderLineItem.Is_All_In_One__c = true; // Start/End D-0033 UAT 26-02-2015 JohnD set the field to true
                }
                //start D-1394 02/05/15 Added by ABanaag
                if (tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c == GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE) {
                    productIsMagazine = true;
                }
                //end D-1394 02/05/15 Added by ABanaag
                //start D-1311 02/05/2015 added by ABanaag
                else if (tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c == GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER) {
                    orderLineItem.delivered_by__c = GlobalVariableClass.OLIDELIVEREDBY_VENDOR;
                }
                //end D-1311 02/05/2015 added by ABanaag
                
                //START D-3072 Gdelrosario 6/8/2015 : check if bill run or proaction

                //Start Ronald Dagaraga UD-0217 18/03/2015 MAke sure that Subcription Frequency is equal Main package Frequency
                if (tmp.Product_Rate_Plan__r.SubscriptionFrequency__c != null) {
                        if(tmp.Product_Rate_Plan__r.RatePlanType__c  == GlobalVariableClass.RATE_TYPE_BILL_RUN || tmp.Product_Rate_Plan__r.RatePlanType__c  == GlobalVariableClass.RATE_TYPE_PRORATION){
                   orderLineItem.Main_Package_Frequency__c = ConstantsSLB.getProductFrequency(tmp.Product_Rate_Plan__r.SubscriptionFrequency__c); 
                }
                //End Ronald Dagaraga UD-0217 18/03/2015 MAke sure that Subcription Frequency is equal Main package Frequency
                     }
                
                //END D-3072
                orderLineItem.Main_Package_Product_Sub_Type__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c;
                orderLineItem.Main_Package_Product_Platform__c = tmp.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c;
            }
            //END D-1689 22/01/15 Wenjun
        }
        
        // retrieve earliest publication date and direct sub delivery method
        // assumption: all publications related to the package have the same delivery method
        
        //START SPH Code Review - 16-Feb-2015 Added by Raviteja - included if condition in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
        productIds.remove(null);
        //End SPH Code Review - 16-Feb-2015 Added by Raviteja 
        //Start D-0070 03-12-15 ABanaag
        try {
            publicationDetailList = [select Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c 
                    from Product_Publication__c where ZProduct__c in :productIds
                    AND Publication_Code__r.Earliest_Start_Date__c != Null 
                    order by Publication_Code__r.Earliest_Start_Date__c asc];
        } catch (exception e) {
            publicationDetailList = new List<Product_Publication__c>();
        }
        // end retrieve earliest publication date
        if(publicationDetailList.size()>0){ //Start/End  UD-0375 03-16-15 ABanaag - catch listindexoutofbounds
            orderLineItem.Earliest_Start_Date__c = publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c;
            orderLineItem.Start_Date__c = publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c;
            orderLineItem.Direct_Sub_Delivery_Method__c = publicationDetailList[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;             
        } //Start/End  UD-0375 03-16-15 ABanaag - catch listindexoutofbounds
    //End D-0070 03-12-15 ABanaag        
        if (orderLineItem.Start_Date__c != null && orderLineItem.Term_Length__c > 0) {
            //START D-1303 1/16/2015 Added By C. Lin - Deduct 1 day from the End Date of the Order Line Item
            orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addMonths(integer.valueOf(orderLineItem.Term_Length__c)).addDays(-1);
            //END D-1303 1/16/2015 Added By C. Lin
        }
        
        //START D-0070 defect 03-12-15 ABanaag
        uniqueOptions = new set<string>();
        // Start D-0033 UAT 26-02-2015 JohnD revised logic implemented in getting the delivered by value
        deliveryMethod.add(new SelectOption(DELIVERED_BY_NONE, DELIVERED_BY_NONE));
        uniqueOptions.add(DELIVERED_BY_NONE);
        
        
        if(publicationDetailList.size()>0){
            for(Product_Publication__c pubDetail : publicationDetailList){
                if (pubDetail.Publication_Code__c != null 
                && pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c != null) {
                
                    if (pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == DELIVERED_BY_BOTH 
                            || pubDetail.Publication_Code__r.Direct_Sub_Delivery_Method__c == null) {
                       
                     if (OrderLineItem.Delivered_By__c ==null) { 
                        orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
                        }
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
                //START UD-0587 04/07/2015 ABanaag - set default values of picklist
                }
              
                if(uniqueOptions.CONTAINS(DELIVERED_BY_VENDOR)){
                  // Start UD-0759 4/17/2015 ronald dagaraga new criteria for edit record not to have defaulta value
                  //START: UD-3358 12/4/15 Added by Manolo Valena
                  if (orderId == null || (orderId != null && orderLineItem.Id == null)){  //START/END: UD-0219 RReyes Changed validation criteria to orderId.
                  //END: UD-3358 12/4/15 Added by Manolo Valena
                    orderLineItem.Delivered_By__c = DELIVERED_BY_VENDOR;
                }
                // End UD-0759 4/17/2015 ronald dagaraga new criteria for edit record not to have defaulta value
                }
                else if(uniqueOptions.CONTAINS(DELIVERED_BY_MAILING_AGENT)){
                // Start UD-0759 4/17/2015 ronald dagaraga new criteria for edit record not to have defaulta value
                    //START: UD-3358 12/4/15 Added by Manolo Valena
                    if (orderId == null || (orderId != null && orderLineItem.Id == null)){  //START/END: UD-0219 RReyes Changed validation criteria to orderId.
                    //END: UD-3358 12/4/15 Added by Manolo Valena
                   orderLineItem.Delivered_By__c = DELIVERED_BY_MAILING_AGENT;
                   }
                // End UD-0759 4/17/2015 ronald dagaraga new criteria for edit record not to have defaulta value   
                 }
                else if(uniqueOptions.CONTAINS(DELIVERED_BY_NONE)){
                   orderLineItem.Delivered_By__c = DELIVERED_BY_NONE;
                }
             
                //END UD-0587 04/07/2015 ABanaag - set default values of picklist
            }
        }
        
        //END D-0070 03-12-15 ABanaag
        
        // retrieve promotion contract period and penalty charge
        if (packageIdpromotionId.size() > 1) {            
            isFromPromotion = true;
            id proId = packageIdpromotionId[1];
            
            try {
                Decimal temp;               
                //START D-2048 2/2/2015 Added By C. Lin - Penalty Charge Override should be the Penalty Charge if available.
                Promotion__c promoTmp = [select Id, Contract_Period__c, Penalty_Charge__c, Penalty_Charge_Override__c from Promotion__c where Id = :proId];
                //END D-2048 2/2/2015 Added By C. Lin
                
                orderLineItem.Promotion_ID__c = promoTmp.Id;
                
                try{
                    //START D-2048 2/2/2015 Added By C. Lin - Penalty Charge Override should be the Penalty Charge if available.
                    if(promoTmp.Penalty_Charge_Override__c != NULL){
                        orderLineItem.Penalty_Charge__c = promoTmp.Penalty_Charge_Override__c;
                    }else{
                        orderLineItem.Penalty_Charge__c = decimal.valueOf(promoTmp.Penalty_Charge__c);
                    }
                    //END D-2048 2/2/2015 Added By C. Lin
                } catch(Exception e){
                    orderLineItem.Penalty_Charge__c = 0.00;
                }
                
                try{
                    orderLineItem.New_Contract_Period__c = integer.valueOf(promoTmp.Contract_Period__c);
                } catch(Exception e){
                    orderLineItem.New_Contract_Period__c = 0;
                }
                //Start D-0070 03-12-15 ABanaag
        if(publicationDetailList.size()>0){
                    if(publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c != null) {
                         //START D-1303 1/16/2015 Added By C. Lin - Deduct 1 day from the End Date of the Order Line Item
                         //START D-2881 06/01/15 RReyes - sets contract end date to null if contract period is 0
                         if(orderLineItem.New_Contract_Period__c == 0 || orderLineItem.New_Contract_Period__c == null){
                             orderLineItem.Contract_End_Date__c = null;
                         }else{
                         orderLineItem.Contract_End_Date__c = publicationDetailList[0].Publication_Code__r.Earliest_Start_Date__c.addMonths(integer.valueOf(orderLineItem.New_Contract_Period__c)).addDays(-1);
                         }   
                         //END D-2881 06/01/15 RReyes - sets contract end date to null if contract period is 0   
                         //END D-1303 1/16/2015 Added By C. Lin
                }
                }
        //End D-0070 03-12-15 ABanaag
            } catch (exception e) {
                
                // Start D-0105 UAT 01-03-2015 JohnD log exception
                ExceptionLogger.log(new list<exception> { e });
                // End D-0105 UAT 01-03-2015 JohnD                
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
    }   

    // start asia1 components
    public Asia1__c asia1SingleAccount { get; set; } 
    //public list<Asia1Wrapper> asia1Subscriptions = new list<Asia1Wrapper>();
    public list<Asia1Wrapper> asia1Subscriptions { get; set; }
    //public Asia1_Subscription__c asia1SingleSubscription { get; set; }
    public transient string asia1SelectedExistingId { get; set; }
    public transient string asia1IdToBeRemoved { get; set; }
    //public transient string selectedPackageId { get; set; }
    public transient boolean isCreateNew { get; set; }
    public string ldapValidityImg { get; set; }
    public string displayNameValidityImg { get; set; }
    public transient string asia1ErrorMsg { get; set; }
    public transient integer asia1SubscriptionsTotal { get; set; }
    //START: D-4618 04/20/2016 Added by Kristine Balaoing
    @testVisible private boolean isAsia1Validated = false;
    //END: D-4618 04/20/2016 Added by Kristine Balaoing
    

    private void initializeAsia1Components() {
        isCreateNew = true;
        asia1Subscriptions = new list<Asia1Wrapper>();
        asia1SingleAccount = new Asia1__c();
        ldapValidityImg = '/s.gif';
        displayNameValidityImg = '/s.gif';
    }
   
 //START: D-4618 04/20/2016 Added by Kristine Balaoing - added method for add asia1 existing accounts   
 public void addAsia1ExistingAccount() {
     
        retrieveAddOn(selectedAddOnPackage);
        list<string> packageIdpromotionId = selectedPackageId.split(':');
        //System.assertEquals(null, packageIdpromotionId[0]);
        //System.assertEquals(1,2);
        
        for (Asia1__c tmpAsia1 : [select Id, User_ID_LDAP_ID__c from Asia1__c where Id = :asia1SelectedExistingId]) {   // Start/End D-3374 12Aug15 JohnD - converted to for loop
            //START D-3289 07/28/2015 Added by Dags - Check enabled Service Flags
            Map<String, Object> userDetailsMap = new Map<String, Object>();   
            userDetailsMap = AsiaOneServicesController.verifyUser2(tmpAsia1.User_ID_LDAP_ID__c, null);
            SM_SubscriptionHelper.enabledServices = string.valueOf(userDetailsMap.get('Service'));
            //END D-3289 07/28/2015 Added by Dags - Check enabled Service Flags
            
            //START UD-0163 03-18-2015 Marvin Gatchalian        

            for (Asia1Wrapper asia1wrapper : createAsia1SubscriptionFromAccessFlag(tmpAsia1.User_ID_LDAP_ID__c, tmpAsia1.Id, packageIdpromotionId[0])){
                asia1Subscriptions.add(asia1wrapper);
            }
            //END UD-0163 03-18-2015 Marvin Gatchalian
            //START: D-4618 Added by Kristine Balaoing May 6, 2016 - added logic to add asia1 sub of add on
            //System.assertEquals(null, asia1Subscriptions);
            //retrieveNewlyAddedAddOn();
            //System.assertEquals(null, asia1Subscriptions);
            //END: D-4618 Added by Kristine Balaoing May 6, 2016
            
            
            asia1SubscriptionsTotal = asia1Subscriptions.size();
        }    // Start/End D-3374 12Aug15 JohnD - converted to for loop
        //createAsia1SubscriptionFromAccessFlag(tmpAsia1.User_ID_LDAP_ID__c, tmpAsia1.Id, selectedPackageId);
    }    
    
    /*
     * This method will create a new asia 1 account
    */
    public void addAsia1NewAccount(){
    
        retrieveAddOn(selectedAddOnPackage);
        if (selectedPackageId != null){
            
            
            //hasDigitalPackage = true;
            list<string> packageIdpromotionId = selectedPackageId.split(':'); 
            //START: D-4618 04-19-2016 Added by Kristine Balaoing - added string for addon package id
            
            //END: D-4618 04-19-2016 Added by Kristine Balaoing
            //START UD-3896 3/31/2016 Added by J.Sarion - check if password is null
            isAsia1Validated = false;
            system.debug('>>>>>isAsia1Validated ' + isAsia1Validated);
            system.debug('>>>>>asia1SingleAccount.Password__c ' + asia1SingleAccount.Password__c);
            validateNewAsia1Account();
            system.debug('>>>>>isAsia1Validated ' + isAsia1Validated);
            system.debug('>>>>>asia1SingleAccount.Password__c ' + asia1SingleAccount.Password__c);
            if (isAsia1Validated == true && asia1SingleAccount.Password__c != null && asia1SingleAccount.Password__c != '') {
                
                asia1SingleAccount.id = null;
                asia1SingleAccount.Status__c = 'Pending Creation';
                asia1SingleAccount.Contact__c = recipientContactId;
        //Start D-0198 03/12/15 Marvin Gatchalian / A Banaag
                asia1SingleAccount.Order_Number__c = thisOrder.name;
            //End D-0198 03/12/15 Marvin Gatchalian / ABanaag
                try {
                
                    insert asia1SingleAccount;
                    //Start D-2176 02/11/2015 Added by April Banaag - add newly created Asia1 record to list instead of overwriting  the list
                    for (Asia1Wrapper asia1wrapper : createAsia1SubscriptionFromAccessFlag(asia1SingleAccount.User_ID_LDAP_ID__c, asia1SingleAccount.Id, packageIdpromotionId[0])){
                        asia1Subscriptions.add(asia1wrapper);
                    }
                    asia1SubscriptionsTotal = asia1Subscriptions.size();
                    //End D-2176 02/11/2015 Added by April Banaag - add newly created Asia1 record to list instead of overwriting  the list
                    // reset asia1 single account
                    asia1SingleAccount = new Asia1__c();
                    // end reset asia1 single account
            
                    ldapValidityImg = '/s.gif';
                    displayNameValidityImg = '/s.gif';
                } catch (exception e) {
                    if(userInfo.getLastName() == 'Balaoing'){
                        System.assertEquals(null, e);
                    }
                    ApexPages.addMessages(e);
                }
            }
            else if(asia1SingleAccount.Password__c == null || asia1SingleAccount.Password__c == '') {
                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'Password is required'));
                //ApexPages.addMessages('Password is required');
                if(userinfo.getLastName()== 'Sarion') {
                    //system.assertequals(null, asia1SingleAccount.Password__c);
                    //system.assertequals('', asia1SingleAccount.Password__c);
                }
            }
            //END UD-3896 3/31/2016 Added by J.Sarion - check if password is null
        }
    //END: D-4618 04/20/2016 Added by Kristine Balaoing
        //START: D-4618 04/19/2016 Added by Kristine Balaoing - added logic for asia1 for add on packages
        /*if (selectedAddOnPackage != null){
            
            list<string> addOnId = selectedAddOnPackage.split(':'); 
            if(userInfo.getLastName() == 'Balaoing'){
                //System.assertEquals(null, addOnId);
            }
            //START: D-4618 04-19-2016 Added by Kristine Balaoing - added string for addon package id
            
            //END: D-4618 04-19-2016 Added by Kristine Balaoing
            //START UD-3896 3/31/2016 Added by J.Sarion - check if password is null
            //isAsia1Validated = false;
            system.debug('>>>>>isAsia1Validated ' + isAsia1Validated);
            system.debug('>>>>>asia1SingleAccount.Password__c ' + asia1SingleAccount.Password__c);
            if(!hasDigitalPackage){
                isAsia1Validated = false;
                validateNewAsia1Account();
            }
            system.debug('>>>>>isAsia1Validated ' + isAsia1Validated);
            system.debug('>>>>>asia1SingleAccount.Password__c ' + asia1SingleAccount.Password__c);
            if (isAsia1Validated == true && asia1SingleAccount.Password__c != null && asia1SingleAccount.Password__c != '') {
                
                if(!hasDigitalPackage){
                    asia1SingleAccount.id = null;
                    asia1SingleAccount.Status__c = 'Pending Creation';
                    asia1SingleAccount.Contact__c = recipientContactId;
            //Start D-0198 03/12/15 Marvin Gatchalian / A Banaag
                    asia1SingleAccount.Order_Number__c = thisOrder.name;
            //End D-0198 03/12/15 Marvin Gatchalian / ABanaag
                }
                try {
                    if(!hasDigitalPackage){
                        insert asia1SingleAccount;
                    }
                    //Start D-2176 02/11/2015 Added by April Banaag - add newly created Asia1 record to list instead of overwriting  the list
                    for (Asia1Wrapper asia1wrapper : createAsia1SubscriptionFromAccessFlag(asia1SingleAccount.User_ID_LDAP_ID__c, asia1SingleAccount.Id, addOnId[0])){
                        asia1Subscriptions.add(asia1wrapper);
                    }
                    asia1SubscriptionsTotal = asia1Subscriptions.size();
                    //End D-2176 02/11/2015 Added by April Banaag - add newly created Asia1 record to list instead of overwriting  the list
                    
                    // reset asia1 single account
                    asia1SingleAccount = new Asia1__c();
                    // end reset asia1 single account
            
                    ldapValidityImg = '/s.gif';
                    displayNameValidityImg = '/s.gif';
                   
                } catch (exception e) {
                    if(userInfo.getLastName() == 'Balaoing'){
                        System.assertEquals(null, e);
                    }
                    ApexPages.addMessages(e);
                }
            }
            else if(asia1SingleAccount.Password__c == null || asia1SingleAccount.Password__c == '') {
                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'Password is required'));
                //ApexPages.addMessages('Password is required');
                if(userinfo.getLastName() == 'Sarion') {
                    //system.assertequals(null, asia1SingleAccount.Password__c);
                    //system.assertequals('', asia1SingleAccount.Password__c);
                }
            }
            //END UD-3896 3/31/2016 Added by J.Sarion - check if password is null
        }*/
        //END: D-4618 04/19/2016 Added by Kristine Balaoing
    }

    public void validateNewAsia1Account() {
        
        //boolean returnValue;
        // check require fields
        if (asia1SingleAccount.User_ID_LDAP_ID__c != null && asia1SingleAccount.Display_Name__c != null) {
            
            map<string, object> validationResult = validateAsia1Account(asia1SingleAccount.User_ID_LDAP_ID__c, 
                    asia1SingleAccount.Display_Name__c);
            
            ldapValidityImg = (string)validationResult.get('ldap');
            displayNameValidityImg = (string)validationResult.get('username');
            
            isAsia1Validated = (boolean)validationResult.get('success');
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
        
        //return returnValue;
    }

    public void removeAsia1Subscription() {
        
        integer i = 0;
        
        for (i = 0; i < asia1Subscriptions.size(); i++) {   
            if (asia1Subscriptions.get(i).asia1Id == asia1IdToBeRemoved) {
                asia1Subscriptions.remove(i);
            }
        }
        //START UD-3339 12/02/2015 RReyes
        List<Asia1_Subscription__c> tmpAsia1Sub = [SELECT Id FROM Asia1_Subscription__c WHERE Asia1__c =:asia1IdToBeRemoved];
        
        if(tmpAsia1Sub.size() == 0){
            delete [select id from Asia1__c where Id = :asia1IdToBeRemoved and Status__c = 'Pending Creation'];
        }
        //END UD-3339 12/02/2015 RReyes
    }
    
    
    public list<SelectOption> getAsia1ExistingAccounts() {
        
        set<id> tmpAsia1Ids = new set<id>();
        for (Asia1Wrapper tmpw : asia1Subscriptions) {
            tmpAsia1Ids.add(tmpw.asia1Id);
        }
        
        list<SelectOption> options = new list<SelectOption>();
        
        //START UD-3454 01/06/15 RReyes - added condition if Asia1 is not Disabled
        String disabled = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
        for (Asia1__c asia1 : [select Id, User_ID_LDAP_ID__c from Asia1__c where Contact__r.Account.Id = :accountId  and Id not in :tmpAsia1Ids  and status__c!=:disabled]) {
            options.add(new SelectOption(asia1.Id, asia1.User_ID_LDAP_ID__c));
        }
        //END UD-3454 01/06/15 RReyes - added condition if Asia1 is not Disabled
        return options;
    }
    // end asia1 components

    // payment components
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
    
    private void initializePaymentComponents() {
        try {
            //START D-2376 02/25/2015 JTeves -  added RecordTypeId in Query
            //START: MD-12 03/21/2015 JTeves - added Total Credit Balance in Query
            thisAccount = [SELECT Id, Name, AccountNumber, Total_Credit_Balance1__c, RecordTypeId FROM Account WHERE Id = :accountId];
            //END: MD-12 03/21/2015 JTeves - added Total Credit Balance in Query
            //END D-2376 02/25/2015 JTeves
        }
        catch(Queryexception e) {
            //no matching acct / no passed accunt id
            thisAccount = new Account();
        }
        dummySubscription = new Zuora__Subscription__c();
        thisQuote = new zqu__Quote__c();
    }
     
    public List<SelectOption> getAcquisitionTypes() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Zuora__Subscription__c.Acquisition_Type_1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }   
        return options;
    }
    
    public List<SelectOption> getDeliveryChargeTypes() {
        List<SelectOption> chargeTypes = new List<SelectOption>();
        //dependent on recipient type
        
        // Start UD-1431 07Jul15 JohnD
        string defaultType;
        
        if (recipientAddressType != null) {
            defaultType = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
        }
        // End UD-1431 07Jul15 JohnD
        
        // Start D-2157 02/10/2015 JohnD added condition and logic within it 
        if (recipientAddressRecordTypeName != null && recipientAddressRecordTypeName != ConstantsSLB.getOther(ADDRESS_RECORD_TYPE_NAME_LOCAL)) { 
            
            chargeTypes.add(new SelectOption('N', 'N'));
        
        } else {
            
            if (defaultType != null) {
                chargeTypes.add(new SelectOption(defaultType, defaultType));
            } else {
                chargeTypes.add(new SelectOption('', ''));
                chargeTypes.add(new SelectOption('H', 'H'));
                chargeTypes.add(new SelectOption('C', 'C'));
                chargeTypes.add(new SelectOption('L', 'L'));
                // Start UD-1431 07Jul15 JohnD - added condition
                if (recipientAddressType != null) {
                    ApexPages.addMessage(new APexPages.Message(ApexPages.severity.WARNING, ConstantsSLB.getErrorMessage('Invalid Address Type')));
                }
                // End UD-1431 07Jul15 JohnD - added condition
            }
            
            chargeTypes.add(new SelectOption('S', 'S'));
            chargeTypes.add(new SelectOption('N', 'N'));
            chargeTypes.add(new SelectOption('Z', 'Z'));
            chargeTypes.add(new SelectOption('9', '9'));
            
        }
        // End D-2157 02/10/2015 JohnD        
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
        //START UD-3278 20Nov15 AddedBy FrancisBenzon : initialize  
        renderCheckDetails = false;     
        //END UD-3278 20Nov15 AddedBy FrancisBenzon : initialize
        //START UD-0204  3/19/15 AddedBy FrancisBenzon :default boolean to false
        isOtherPayment = false;
        //END UD-0204  3/19/15 AddedBy FrancisBenzon :default boolean to false
        if (thisOrder.Billing_Account__c != null) {
            //START/END UD-0204 3/19/15 AddedBy FrancisBenzon : added Other_PaymentMethod__c field in query
            thisBillingAccount = [SELECT Id, Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__r.Zuora__Type__c, Name,         Zuora__PaymentMethod_Type__c, Zuora__Credit_Balance__c, 
                    Payment_Mode__c , Other_PaymentMethod__c
                    FROM Zuora__CustomerAccount__c WHERE Id = :thisOrder.Billing_Account__c];
            
           //START:D-0852/12022014/K.Tan,B. Ventura/Pull payment mode on orderEntry Screen
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
                //START UD-0204 3/19/15 AddedBy FrancisBenzon : to populate other Payment method 
                isOtherPayment = true;
                if(thisBillingAccount.Other_PaymentMethod__c != null)
                {
                    thisOrder.Other_Payment_Mode__c = thisBillingAccount.Other_PaymentMethod__c;
                }
                else{
                    thisOrder.Other_Payment_Mode__c  = 'Invoice';
                }
                //END UD-0204 3/19/15 AddedBy FrancisBenzon : to populate other Payment method              
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'PayPal'){
                thisOrder.Payment_Mode__c = 'PayPal';
            }
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'WireTransfer'){
                thisOrder.Payment_Mode__c = 'Wire Transfer';
            }
            //START UD-0204  3/19/15 AddedBy FrancisBenzon : consider Check in retrieval
            else if(thisBillingAccount.Zuora__DefaultPaymentMethod__c == 'Check')
            {
                //START UD-3278 20Nov15 AddedBy FrancisBenzon : check if cb > subrate
                if(thisOrder.Credit_Balance__c < thisOrder.Total_Full_Prepaid_Charge__c)
                {
                    renderCheckDetails= true;
                }
                //END UD-3278 20Nov15 AddedBy FrancisBenzon : check if cb > subrate
                thisOrder.Payment_Mode__c = 'Check';
            }
            //END UD-0204  3/19/15 AddedBy FrancisBenzon : consider Check in retrieval
            else{
                thisOrder.Payment_Mode__c = '';
            }
        } else{
            thisOrder.Payment_Mode__c = '';
        }
      //End D-0852  
      //START D-3039 06/04/15 RReyes - sets Other_Payment_Mode__c to blank when Payment_Mode__c is not 'Other'
      if(thisOrder.Payment_Mode__c != 'Other'){
          thisOrder.Other_Payment_Mode__c  = '';
      }
      //END D-3039 06/04/15 RReyes - sets Other_Payment_Mode__c to blank when Payment_Mode__c is not 'Other'      
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
        if(thisOrder.Billing_Account__c == null){
            thisOrder.Payment_Mode__c = null;
        }
    }
    
    public void clearOtherPaymentMethod() {
        thisOrder.Other_Payment_Mode__c = null;
        thisOrder.Billing_Account__c = null;
    }
  
    // end payemnt components
    
    //START ADD srpuli 10/08/2014 ARMS Component
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

        billAccName = null;
        billAcc = true;
    }

    
    public void searchCusName(){
        //START UD-3054 10/9/15 AddedBy FrancisBenzon : no BA Invoice creation if no OLI 
        Boolean enterSearch = true;
        if(orderLineItemList.size() == 0)
        {           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('ARMS Create OLI first')));
            enterSearch = false;
        }
        //END UD-3054 10/9/15 AddedBy FrancisBenzon : no BA Invoice creation if no OLI
        if(enterSearch)
        {
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


                wwwSphComArWsWsdlCam.CAMSOAP CusRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();


                wwwSphComArWsWsdlCam.SearchCustomerResponseType cusResp = CusRespCAM.SearchCustomer(searchCusReq);

                if(cusResp<>null){
                    if(cusResp.CusSrchResp<>null){
                        //START PD-0271 6June2016 FrancisBenzon: display error but display all accounts
                        if(cusResp.CusSrchResp.RtnSts == '0' || cusResp.CusSrchResp.RtnSts == '8'){
                        
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
                                    awCus.arPOC = a.Attn;
                                    awCus.arBusProf = a.BizP;
                                    awCus.isTick = false;
                                    
                                    if(cusResp.CusSrchResp.RtnSts == '8')
                                    {
                                        errorMessageARMS8 = cusResp.CusSrchResp.RtnMsg;
                                    }
                                    
                                    arCusList.add(awCus);
                                }
                                if(arCusList<>null){
                                    armsCusWrapList = arCusList;
                                    //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
                                    searchCustTick=true;
                                    //END UD-1214
                                }
                            }       

                        } else if ((cusResp.CusSrchResp.RtnSts <> '0' && cusResp.CusSrchResp.RtnSts <> '8') || cusResp.CusSrchResp.RtnSts == null){
                            //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
                            searchCustTick=false;
                            //END UD-1214
                            displayCusErr = true;
                            CBdisable = false;
                            errorMsg = cusResp.CusSrchResp.RtnMsg;
                            thisOrder.Debt_Management_Treatment__c = 'SUBH';
                            thisOrder.Business_Profile__c = 'NORM';

                        }
                        //END PD-0271 6June2016 FrancisBenzon: display error but display all accounts
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
        
        
    }
    
    public void searchAccName(){
        //START UD-3054 10/9/15 AddedBy FrancisBenzon : no BA Invoice creation if no OLI.
        if(orderLineItemList.size() == 0)
        {           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage('ARMS Create OLI first')));
        }
        //END UD-3054 10/9/15 AddedBy FrancisBenzon : no BA Invoice creation if no OLI.         
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
                        if(accResp.AccSrchResp.RtnSts == '0' && accResp.AccSrchResp.SysId == ConstantsSLB.getOther('ARMS_SysId')){
                            //START UD-1214 5/21/2015 Gdelrosario (6/4/2015) : added flag for Search Acc ARM button
                            searchAcctTick =true;
                            //END UD-1214

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
                    //START D-2760 17-Apr-2015 Added by Raviteja  - Commented for as part of the duplicate ARMS ID changes                    
                    thisOrder.Business_Profile__c = awl.arBusProf; 
                    //End D-2760 17-Apr-2015 Added by Raviteja 
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
    //END srpuli 10/08/2014

    /*
     * Defect : D-0712
     * Added By : Alyana P. Navarro
     */
    public String hidSubCharge {get; set;}
    //START UD-1826 AddedBy FrancisBenzon : flag if del charge type is S
    public Boolean delChargeType_S {get;set;}
    //END UD-1826 AddedBy FrancisBenzon : flag if del charge type is S
    //START D-1317 Wenjun 09/02/15 : Rewrite this method using sObject Field and Optimize Codes
    public void computePrepaid(){
        // Start D-2664 01Apr15 JohnD renamed variable
        //START UD-1826 AddedBy FrancisBenzon : flag if del charge type is S
        if(selectedDeliveryChargeType == 'S')
        {
            delChargeType_S = true;
        }
        else {
            delChargeType_S = false;
        }
        //END UD-1826 AddedBy FrancisBenzon : flag if del charge type is S
        //Start D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
            thisOrder.Delivery_Charge_Type__c = selectedDeliveryChargeType;
        //Start D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
        Map<String, Decimal> chargeMap = getCharges(thisOrder.Recipient_Contact__c, thisOrder.Delivery_Charge_Type__c, null, null);
        Date earliestStartDate = Date.today().addYears(100);
        Date latestEndDate = Date.today().addYears(-100);
        Integer monthsBetween;
        boolean isDeliveryNeeded = false;
        // End D-2664 01Apr15 JohnD renamed variable
//START UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid
        Decimal totalPostageCharge = 0.00;        
        Decimal totalSubscriptionRate = 0.00;
//END UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid 
        
        //Determine the total duration by getting earliest start date and latest end date
        //START: D-0097 02-26-2015 Marvin Gatchalian - Add this line to get updated Order Line Item List
        orderLineItemList = getOrderLineItems(thisOrder.Id);
        //END: D-0097 02-26-2015 Marvin Gatchalian - Add this line to get updated Order Line Item List
        
        //START: D-3984 11/27/15 Added by Manolo Valena
        Set<Id> packageIdSet = new Set<Id>();
        Set<String> packageItemRecTypeSet = new Set<String>{'Base Product', 'Bundle Product', 'Extension Product'};
        Map<Id, Id> OLIIdToPackageIdMap = new Map<Id, Id>();
        List<Product_Code__c> prodCodes = Product_Code__c.getall().values();
        Set<String> CProductCodeSet = new Set<String>();
        Map<Id, Boolean> packageToIsNoDelMap = new Map<Id, Boolean>();
        Integer finalCount = 0;
        Boolean isWithDelivery = true;
        //END: D-3984 11/27/15 Added by Manolo Valena
        
        for(Order_Line_Item__c orderLineItem : orderLineItemList){
            //START UD-1317 06/06/2015 Added by J. Sarion - Set Subscription Rate and Postage Charge to 0 for Freelist
            if (thisOrder.Other_Payment_Mode__c == 'Freelist') {
                orderLineItem.Main_Package_Subscription_Rate__c = 0;
                orderLineItem.Add_On_Package_Subscription_Rate__c = 0;
                //START D-3105 06/15/2015 Remove line. Will not set Postage Charge to 0
                //orderLineItem.Postage_Charge__c = 0;
                //END D-3105 06/15/2015 Remove line. Will not set Postage Charge to 0
            }
            else {
                if (pkgIdToMainPriceMap.containsKey(orderLineItem.Main_Package_ID__c) && pkgIdToMainPriceMap.get(orderLineItem.Main_Package_ID__c) != null && orderLineItem.Main_Package_Subscription_Rate__c == 0)
                    orderLineItem.Main_Package_Subscription_Rate__c = pkgIdToMainPriceMap.get(orderLineItem.Main_Package_ID__c);
                if (orderLineItem.Addon_Package__c != null) {
                    if (pkgIdToAddOnPriceMap.containsKey(orderLineItem.Addon_Package__c) && pkgIdToAddOnPriceMap.get(orderLineItem.Addon_Package__c) != null && orderLineItem.Add_On_Package_Subscription_Rate__c == 0)
                        orderLineItem.Add_On_Package_Subscription_Rate__c = pkgIdToAddOnPriceMap.get(orderLineItem.Addon_Package__c);
                }
                //START D-3105 06/15/2015 Remove line. Will not set Postage Charge to 0
                //if (oliIdToPostageChargeMap.containsKey(orderLineItem.Id) && oliIdToPostageChargeMap.get(orderLineItem.Id) != null && orderLineItem.Postage_Charge__c == 0)
                    //orderLineItem.Postage_Charge__c = oliIdToPostageChargeMap.get(orderLineItem.Id);
                //END D-3105 06/15/2015 Remove line. Will not set Postage Charge to 0
            }
            //END UD-1317 06/06/2015 Added by J. Sarion - Set Subscription Rate and Postage Charge to 0 for Freelist
        
//START UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid
            //START UD-1317 06/08/2015 Added by J.Sarion - Set Subscription Rate and Postage Charge to 0 for Freelist
            if (orderLineItem.Total_Postage_Charge__c != null)
                totalPostageCharge += orderLineItem.Total_Postage_Charge__c;
            if (orderLineItem.Main_Package_Subscription_Rate__c != null)
                totalSubscriptionRate += (orderLineItem.Main_Package_Subscription_Rate__c * orderLineItem.Qty__c);
            if (orderLineItem.Add_On_Package_Subscription_Rate__c != null)
                totalSubscriptionRate += (orderLineItem.Add_On_Package_Subscription_Rate__c * orderLineItem.Qty__c);
            //END UD-1317 06/08/2015 Added by J.Sarion - Set Subscription Rate and Postage Charge to 0 for Freelist
//END UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid
            if(orderLineItem.start_date__c < earliestStartDate)
                earliestStartDate = orderLineItem.start_date__c;
            if(orderLineItem.end_date__c > latestEndDate)
                latestEndDate = orderLineItem.end_date__c;
            
            //START D-3382 CCB-135 04/Aug/15 Wenjun: Mailing Agent Assignment  
            if (orderLineItem.Delivered_By__c == DELIVERED_BY_MAILING_AGENT 
                && recipientAddressRecordTypeName == GlobalVariableClass.STRING_AIRLINE) 
            {
                if(selectedMailingAgent != null)
                    orderLineItem.Vendor_Mailing_Agent__c = selectedMailingAgent != null ? ID.valueOf(selectedMailingAgent) : null;
            } 
            //END D-3382 CCB-135 04/Aug/15 Wenjun

            //START: D-3984 11/27/15 Added by Manolo Valena
            if(orderLineItem.Main_Package_ID__c != null) {
                packageIdSet.add(orderLineItem.Main_Package_ID__c);
                OLIIdToPackageIdMap.put(orderLineItem.Id, orderLineItem.Main_Package_ID__c);
            }
            //END: D-3984 11/27/15 Added by Manolo Valena
        }
        
        //START: D-3984 11/27/15 Added by Manolo Valena
        for(Product_Code__c pcRec : prodCodes) {
            CProductCodeSet.add(pcRec.Product_Code__c);
        }
        
        if(packageIdSet.size() > 0) {
            for(Package__c packageRecord : [SELECT Id, Name, (SELECT Id, Product_Rate_Plan__r.Product_Code__c 
                                                              FROM Package_Items__r 
                                                              WHERE RecordType.Name IN: packageItemRecTypeSet) 
                                            FROM Package__c 
                                            WHERE Id IN: packageIdSet]) {
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
                        packageToIsNoDelMap.put(packageRecord.Id, true);
                    }
                    else {
                        packageToIsNoDelMap.put(packageRecord.Id, false);
                    }
                }
            }
            
            if(OLIIdToPackageIdMap.keySet().size() > 0) {
                for(Id oliIdS : OLIIdToPackageIdMap.keySet()) {
                    if(packageToIsNoDelMap.containsKey(OLIIdToPackageIdMap.get(oliIdS))) {
                        if(packageToIsNoDelMap.get(OLIIdToPackageIdMap.get(oliIdS)) == true) {
                            finalCount = finalCount + 1;
                        }
                    }
                }
                
                if(finalCount == OLIIdToPackageIdMap.keySet().size()) {
                    isWithDelivery = false;
                }
            }
        }
        //END: D-3984 11/27/15 Added by Manolo Valena
        
        //START UD-1317 06/06/2015 Added by J. Sarion - Set Subscription Rate and Postage Charge to 0 for Freelist
        // Start hotfix 18Jul15 JohnD - added try-catch
        //START:D-3571 9/25/15 Added by Manolo Valena - Removed try catch as this method is already being invoked within a try catch in the save method. This should also be removed because even if the error is being catched here, the whole method is still being considered as having no error.
        //try {
        //END:D-3571 9/25/15 Added by Manolo Valena
        //START UD-3399 RReyes 12/21/15 - added if condition before updating records
        if(orderLineItemList.size() > 0)
            update orderLineItemList;
        
        //START UD-3895 4/3/2016 Added by J.Sarion - set try catch
        if(thisOrder != null) {
            Boolean isSuccess = false;
            for (Integer i = 1; i < 5; i++) {
                try {
                    update thisOrder;
                    isSuccess = true;
                }
                catch(DMLException e) {
                    String error = (String) e.getDmlMessage(0);
                    if(!error.contains('UNABLE_TO_LOCK_ROW')) {
                        isSuccess = true;
                    }
                }
                if(isSuccess)
                    break;
            }
            if(!isSuccess)
                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'An error was encountered during the creation of Order.'));
        }
        //END UD-3895 4/3/2016 Added by J.Sarion - set try catch
        
        //END UD-3399 RReyes 12/21/15 - added if condition before updating records
        //START:D-3571 9/25/15 Added by Manolo Valena
        //} catch (exception e) {
            //ApexPages.addMessages(e); 
        //}
        //END:D-3571 9/25/15 Added by Manolo Valena
        
        // End hotfix 18Jul15 JohnD - added try-catch
        //START D-3105 06/15/2015 Added By J.Sarion - Remove line
        //retrieveOrderLineItems();
        //END D-3105 06/15/2015 Added By J.Sarion - Remove line
        //END UD-1317 06/06/2015 Added by J. Sarion - Set Subscription Rate and Postage Charge to 0 for Freelist
       
       //START D-2369 02-26-2015 Marvin Gatchalian
        if (orderLineItemList.size() > 0) { //Start/END UD-0720 ABanaag 04/09/2015
            thisOrder.Months_Between_Start_End__c = orderLineItemList[0].Term_Length__c;
        }
        //END D-2369 02-26-2015 Marvin Gatchalian
        // Start D-2157 02/11/2015 JohnD retrieve latest field
        try {
            // Start D-2664 01Apr15 JohnD retrieve related order line item with delivered by vendor
            for (Order_Line_Item__c tmpOli : [select Id from Order_Line_Item__c where Order__c = :thisOrder.Id 
                    and Delivered_By__c = :DELIVERED_BY_VENDOR limit 1]) {
                        
                isDeliveryNeeded = true;        
            }
            // End D-2664 01Apr15 JohnD retrieve related order line item with delivered by vendor
        } catch (exception e) {
            ExceptionLogger.log(new list<exception>{ e });
        } 
        // End D-2157 02/11/2015 JohnD
    
        if (isDeliveryNeeded == false || selectedDeliveryChargeType == 'N') { // Start/End D-2664 02Apr15 JohnD
        
            thisOrder.Subscriber_Charge__c = 0.0;
        
        // START : D-1033 12/11/14 Alyana Navarro - added selectedDeliveryChargeType H, L, and N in If statement        
        } else if(selectedDeliveryChargeType == 'S' || selectedDeliveryChargeType == '9'){
            //START: D-1313 / 12-22-2014 added by S.Puli - criteria to avoid null hidSubCharge
            if(hidSubCharge != null && hidSubCharge != 'null' && hidSubCharge != ''){
                thisOrder.Subscriber_Charge__c = Decimal.valueOf(hidSubCharge);
                //Start MMallorca UD-1826 14/07/2015
                // thisOrder.Vendor_Credit__c = Decimal.valueOf(hidSubCharge); // Start/End UD-1958 21Jul15 JohnD - commented out
                //End MMallorca UD-1826 14/07/2015
            } else {
                //Start D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
                //thisOrder.Subscriber_Charge__c = 0.0;
                //END D-2788 04/27/15 Added by ABanaag - Update Monthly_Delivery_Charge_for_Full_Payment__c
            }
            //END: D-1313 / 12-22-2014 added by S.Puli
        } else if(selectedDeliveryChargeType == 'C' || selectedDeliveryChargeType == 'H' || selectedDeliveryChargeType == 'Z' || selectedDeliveryChargeType == 'L'){                     
            
    // Start D-2664 02Apr15 JohnD 
            subscriberCharge = chargeMap.get('SubscriberCharge');
            thisOrder.Subscriber_Charge__c = subscriberCharge;
    // End D-2664 02Apr15 JohnD
 
        }
        
        
        // END : D-1033 12/11/14 Alyana Navarro
     
        //START D-3231 Wenjun 08/07/15: Update Delivery Fee Calculation Logic
        /*
        setMonthlyDeliveryChargeForFullPrepaid(); // Start/End D-2664 02Apr15 JohnD added call
        
        // Start UD0715 29Apr15 JohnD added call 
        map<string, decimal> deliveryCharges = FullPrepaidDeliveryChargeCalculator.calculate(thisOrder.Id, thisOrder.Subscriber_Charge__c);
        thisOrder.Full_Prepaid_Delivery_Charge__c =  deliveryCharges.get(GlobalVariableClass.BILLING_TYPE_FULL);
        thisOrder.Recurring_Delivery_Charge__c = deliveryCharges.get(GlobalVariableClass.BILLING_TYPE_RECURRING); 
        */
        thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0.0;  
        thisOrder.Recurring_Delivery_Charge__c = thisOrder.Subscriber_Charge__c;
        
        if (thisOrder.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE)
        {
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = thisOrder.Subscriber_Charge__c;
            
            Order_Line_Item__c masterOli = SM_SubscriptionHelper.getLongestOrderLineItem(orderLineItemList);
            
            if(masterOli != NULL)
            {
                //START UD-1997 07/21/15 RReyes - added condition if sub charge and term length is not null before executing expression
                if(thisOrder.Subscriber_Charge__c != null &&  masterOli.Term_Length__c != null){ 
                    //START: D-3984 11/27/15 Added by Manolo Valena
                    if(isWithDelivery) {    
                        thisOrder.Full_Prepaid_Delivery_Charge__c = thisOrder.Subscriber_Charge__c * masterOli.Term_Length__c;
                    }
                    else {
                        thisOrder.Full_Prepaid_Delivery_Charge__c = 0;
                    }
                    //END: D-3984 11/27/15 Added by Manolo Valena
                }
                else{
                    thisOrder.Full_Prepaid_Delivery_Charge__c = 0.0;
                }//END UD-1997 07/21/15 RReyes - added condition if sub charge and term length is not null before executing expression
            }   
            else    
                thisOrder.Full_Prepaid_Delivery_Charge__c = 0.0;
        }
        else
            thisOrder.Full_Prepaid_Delivery_Charge__c = 0.0;
        //END D-3231 Wenjun 08/07/15
        // End UD0715 29Apr15 JohnD added call 
//START UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid
        //START UD-1317 06/06/2015 Added by J. Sarion - Added Freelist 
        //START UD-2951 12/10/2015 Gdelrosario : changed the == to !=
        if (totalSubscriptionRate > 0 || thisOrder.Other_Payment_Mode__c != 'Freelist') {
        //END UD-2951 12/10/2015 Gdelrosario : changed the == to !=    
            thisOrder.Total_Full_Prepaid__c = totalPostageCharge + totalSubscriptionRate + thisOrder.Full_Prepaid_Delivery_Charge__c;
            //Start MMallorca D-3053  Add recurring in filter for computing full inc charge 06/18/2015
            if(thisOrder.Billing_Type__c == 'Recurring Prepaid' || thisOrder.Billing_Type__c == 'Recurring Postpaid'){
                thisOrder.Total_Full_Prepaid__c = 0.00;
            }
            else{
                thisOrder.Total_Full_Prepaid__c = totalPostageCharge + totalSubscriptionRate + thisOrder.Full_Prepaid_Delivery_Charge__c;
            }
        //End MMallorca D-13053 06/18/2015
        //END UD-1317 06/06/2015 Added by J. Sarion - Added Freelist 
        }
        else 
        //Start MMallorca D-3053 Add bracket 06/18/2015
        {
            thisOrder.Total_Full_Prepaid__c = 0.00;
        }
        //End MMallorca D-3053 06/18/2015
        //END UD-1317 06/06/2015 Added by J. Sarion - Added Freelist 
//END UD-1112 05/06/2015 Added by J.Sarion - Populate Total Full Prepaid
        // Start UD-0161 UAT 03-03-2015 MarvinG add try catch
        
        //START:D-3571 9/25/15 Added by Manolo Valena - Removed try catch as this method is already being invoked within a try catch in the save method. This should also be removed because even if the error is being catched here, the whole method is still being considered as having no error.
        //try {
        //END:D-3571 9/25/15 Added by Manolo Valena
            update thisOrder;
        //START:D-3571 9/25/15 Added by Manolo Valena    
        //} catch (exception e) {
        //    ApexPages.addMessages(e);
        //}
        //END:D-3571 9/25/15 Added by Manolo Valena
        
        // End UD-0161 UAT 03-03-2015 MarvinG
        //START: UD-1625 Jean CariÃ±o 06/19/2015
        queryOrder();
        //END: UD-1625 Jean CariÃ±o 06/19/2015
    }
    //END D-1317 Wenjun 09/02/15
    
    // [JohnD 12/04] CC022
    public void retrieveLatestRecipientContact() {
        list<Contact> rContactList = [select Id from Contact where AccountId = :accountId 
                and Recipient_Indicator__c = true order by CreatedDate desc limit 1];
                
        if (rContactList.size() > 0) {
            thisOrder.Recipient_Contact__c = rContactList[0].Id;
        }
    }
    //START: UD-1427 6/4/2015 K. Tan - Add method to cater auto population of recipient contact
    public void retrieveSelectedRecipientContact() {       
        Order__c rOrderContact = [select Id, Recipient_Contact__c from Order__c where Id = :orderId];
                
        if (rOrderContact.Recipient_Contact__c != null) {
            thisOrder.Recipient_Contact__c = rOrderContact.Recipient_Contact__c;
        }
    }   
    //END: UD-1427 6/4/2015 K. Tan - Add method to cater auto population of recipient contact
    
     public void retrieveLatestBillingContact() {
        
        list<Contact> bContactList = [select Id from Contact where AccountId = :accountId 
                and Billing_Indicator__c = true order by CreatedDate desc limit 1];
                
        if (bContactList.size() > 0) {
            thisOrder.Billing_Contact__c = bContactList[0].Id;
        }
    }
    
    // end CC022
    //START D-3305 8/6/15 AddedBy FrancisBenzon : reParent Asia1 to new OLI after Update Line Item
    public void reParentAsia1SubToNewOLI()
    {
        List<Asia1__c> createdAsia1s = new List<Asia1__c>();
        List<Asia1_Subscription__c> asia1SubsReParent = new List<Asia1_Subscription__c>();
        List<Asia1_Subscription__c> asia1SubsToUpdate = new List<Asia1_Subscription__c>();
        if (thisOrder.name <> null) 
        {
            createdAsia1s = [Select Id FROM Asia1__c WHERE Order_Number__c =: thisOrder.name];
            if(!createdAsia1s.isEmpty())
            {
                asia1SubsReParent = [Select Id, Order_Line_Item__c From Asia1_Subscription__c Where Asia1__c IN :createdAsia1s];
                if(!asia1SubsReParent.isEmpty() && orderLineItem.Id != null)
                {
                    for(Asia1_Subscription__c aSubs : asia1SubsReParent) 
                    {
                        if(aSubs.Order_Line_Item__c == null)
                        {
                            aSubs.Order_Line_Item__c  = orderLineItem.Id;
                            asia1SubsToUpdate.add(aSubs);
                        }
                    }
                    try
                    {
                        update asia1SubsToUpdate;
                    }
                    catch(exception e)
                    {
                        system.debug('ERROR: ' + e.getMessage() + e.getStackTraceString());
                    }
                }
            }
        }
    }
    //END D-3305 8/6/15 AddedBy FrancisBenzon : reParent Asia1 to new OLI after Update Line Item
    //START UD-0198 03-12-2015 Marvin Gatchalian /ABanaag
    public void deleteRelatedAsia1() 
    {
        //START: UD-0487 3/31/15 Added by Manolo Valena - Updated method to filter asia1 accounts to be deleted. Only delete asia1 records that do not have any asia1 subscription record connected to it yet.
        List<Asia1__c> asia1Delete = new List<Asia1__c>();
        if (thisOrder.name <> null) 
        {
            for(Asia1__c a : [SELECT Id, (SELECT Id FROM Asia1_Subscriptions__r) FROM Asia1__c WHERE Order_Number__c =: thisOrder.name])
            {
                if(a.Asia1_Subscriptions__r.size() == 0)
                {
                    asia1Delete.add(a);
                }
            }
            if(asia1Delete.size() > 0) //START/END UD-1997 added condition to check if list is not empty before deleting
                delete asia1Delete;
        }
        //END: UD-0487 3/31/15 Added by Manolo Valena
    }
    //END UD-0198 03-12-2015 Marvin Gatchalian/ABanaag 
    
// Start D-2664 02Apr15 JohnD added method
    //START D-3231 Wenjun 08/07/15 - Not in use
    /*
    private void setMonthlyDeliveryChargeForFullPrepaid() {
        
        thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = 0.0;
      
        list<Order_Line_Item__c> oliList = [select id from Order_Line_Item__c where Order__c = :thisOrder.Id 
                and Main_Package_Billing_Type__c = 'Full Prepaid' limit 1];
                
        if (oliList != null && !oliList.isEmpty()) {
            
            thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c = thisOrder.Subscriber_Charge__c;
        }
    } 
    */
    //END D-3231 Wenjun 08/07/15 - Not in use
// End D-2664 02Apr15 JohnD added method
    //START: UD-1625 Jean CariÃ±o 06/19/2015
        private void queryOrder() {

            string queryStr = generateOrderSoqlStr();
            queryStr += ' where Id = \'' + thisOrder.Id + '\'';
                
            SObject tmpOrder = database.query(queryStr);
                
            thisOrder = (Order__c)tmpOrder;     
        }
    //END: UD-1625 Jean CariÃ±o 06/19/2015 

    //START D-3382 CCB-135 04/Aug/15 Wenjun: Get Mailing Agents
    public List<SelectOption> getAirlineMailingAgents()
    {
        List<SelectOption> selectOptions = new List<SelectOption>();
        selectOptions.add(new SelectOption('','--None--'));
        for(Account mAgent : [SELECT ID, Name, Type FROM ACCOUNT WHERE Recordtype.DeveloperName = 'Mailing_Agent' 
                              AND type = 'Airline' AND Active__c = true order by Name])
        {
            selectOptions.add(new SelectOption(mAgent.ID,mAgent.Name));
        }
        return selectOptions;
    }
    //END D-3382 CCB-135 04/Aug/15 Wenjun
    
    //START UD-3339 12/02/2015 RReyes
    public void removeAsia1SubscriptionBulk() {     
        //START UD-3545 1/12/2016 Added by J.Sarion - Set/Delete Asia1 Subscriptions after clicking Update Line Item button
        //if(orderlineitem.Qty__c > 10 && asia1Subscriptions.size() > 0){
            integer i = 0;  
            Set<Id> setAsia1Ids = new Set<Id>();
            Set<Id> setAsia1SubIds = new Set<Id>();
            Map<Id, Set<Id>> asia1IdToAsia1SubIdSetMap = new Map<Id, Set<Id>>();
            for (i = 0; i < asia1Subscriptions.size(); i++) {   
                if (asia1Subscriptions.get(i).asia1Id != null && asia1Subscriptions.get(i).asia1Id != '') {
                    setAsia1Ids.add(asia1Subscriptions.get(i).asia1Id);
                }
            }
            //asia1Subscriptions = new list<Asia1Wrapper>();
            //asia1SubscriptionsTotal = 0;
            if(orderlineItem != null && orderlineItem.Id != null){
                if(setAsia1Ids.size() > 0){
                    for(Asia1_Subscription__c as1Sub:[SELECT Id, Asia1__c, Order_Line_Item__c FROM Asia1_Subscription__c WHERE Asia1__c IN:setAsia1Ids]){
                        if(as1Sub.Asia1__c != null){
                            if(as1Sub.Order_Line_Item__c == orderlineItem.Id){
                                setAsia1SubIds.add(as1Sub.Id);
                            }
                            else {
                                if(asia1IdToAsia1SubIdSetMap.containsKey(as1Sub.Asia1__c)) {
                                    asia1IdToAsia1SubIdSetMap.get(as1Sub.Asia1__c).add(as1Sub.Id);
                                }
                                else {
                                    asia1IdToAsia1SubIdSetMap.put(as1Sub.Asia1__c, new Set<Id> {as1Sub.Id});
                                }
                            }
                        }
                    }
                }
                
                if(!asia1IdToAsia1SubIdSetMap.isEmpty()) {
                    for(Id keyId :asia1IdToAsia1SubIdSetMap.keySet()) {
                        setAsia1Ids.remove(keyId);
                    }   
                }
                
                if(setAsia1SubIds.size() > 0){
                    delete [SELECT id FROM Asia1_Subscription__c WHERE Id IN:setAsia1SubIds];
                }
                if(orderlineitem.Qty__c > 10) {
                    if(setAsia1Ids.size() > 0){
                        delete [SELECT id FROM Asia1__c WHERE Id IN:setAsia1Ids AND Status__c = 'Pending Creation'];
                    }
                    asia1Subscriptions = new list<Asia1Wrapper>();
                    asia1SubscriptionsTotal = 0;
                }
            }
        //}
        //END UD-3545 1/12/2016 Added by J.Sarion - Set/Delete Asia1 Subscriptions after clicking Update Line Item button
    }
    //END UD-3339 12/02/2015 RReyes
    //START: D-4816 04/21/2016 Added by Kristine Balaoing - added logic for add on added after add asia1/add order line item is over
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
    //END: D-4816 04/21/2016 Added by Kristine Balaoing
}