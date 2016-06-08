/**
 * Class Name: STARTSUB_DirectOrderEntryController
 * @author 
 * Date: 2014.07.28
 * Requirement: Start Subscription Order Entry
 * @description This class is use as an apex controller of STARTSUB_DirectOrderEntry VF page.
 *
 */


/*
* ------Revision------
* Version 1.0: Pilot Release
* By: <Developer � Name>
* Description:
*/

public with sharing class STARTSUB_DirectOrderEntryController {

    /*
    * @variable orderLineItemId_lineItemList :
    * @variable selectedPromotionId : hidden field on vf page that hold the promotion id
    *           that been selected to toggle the package list
    * @variable selectedPackageId : hidden field on vf page that hold the pacakge id selected from
    *           vf page to retrieve the details to be populated on the subscription details section 
    */
    id orderId = ApexPages.currentPage().getParameters().get('id');
    id accountId;
    public transient list<Order_Line_Item__c> orderLineItemList { get; set; }
    public transient string selectedPromotionId { get; set; }
    public transient string selectedPackageId { get; set; }
    public transient string orderLineItemIdRemoval { get; set; }
    
    // search variables
    public transient list<SObject> promotionResultList { get; set; }
    public transient list<SObject> packageResultList { get; set; }
    public transient string searchText { get; set; }
    public transient string searchFrom { get; set; }
    public transient string searchBillingType { get; set; }
    // end search variables
    
    // subscription details variables
    public Order_Line_Item__c orderLineItem { get; set; }
    public transient string selectedPackageName { get; set; }
    // end subscription details variables
    
    // addon details variables
    public Package__c addOnPackage { get; set; }
    public string selectedAddOnPackage { get; set; }
    // end addon details variables
    
    // gifts variables
    public list<GiftWrapper> promotionGifts { get; set; }
    // end gift variables
    
    // asia1 accounts
    public list<Asia1__c> asia1Accounts { get; set; }
    public Asia1__c asia1SingleAccount { get; set; } 
    public list<Asia1Wrapper> asia1Subscriptions { get; set; }
    public Asia1_Subscription__c asia1SingleSubscription { get; set; }
    public transient string selectedAsia1Creation { get; set; }
    public transient string asia1CreationMode { get; set; }
    public transient string asia1SelectedExistingId { get; set; }
    public transient string asia1IdToBeRemoved { get; set; }
    // end asia1 accounts
    
    // renderers
    public transient boolean isExecuteSearch { get; set; }
    public transient boolean isPackageSelected { get; set; }
    public transient boolean isPackageFromPromotion { get; set; }
    public transient boolean isPromotionSelected { get; set; }
    public transient boolean isDigital { get; set; }
    public transient boolean isAsia1Existing { get; set; }
    public transient boolean isAsia1Individual { get; set; }
    // end renderers
    
    
    public void xx() {
        
        accountId = [select Account__c from Order__c where Id = :orderId].Account__c;
        asia1Accounts = new list<Asia1__c>();
        asia1SingleAccount = new Asia1__c();
        asia1Subscriptions = new list<Asia1Wrapper>();
        asia1SingleSubscription = new Asia1_Subscription__c();
        isAsia1Existing = false;
        isAsia1Individual = true;
    }
    
    
    public void initializeData() {
        initializeOrderLineItem();
        //orderId = 'a17N0000001w3Cg';
    }
    
    
    public void initializeOrderLineItem() {
        orderLineItem = new Order_Line_Item__c();
    }
    
    public void populateSubscriptionDetail() {
        
        Package__c pkg = [select Id, Package_Code__c, Name from Package__c where Id = :selectedPackageId];
        selectedPackageName = pkg.Name;
        orderLineItem.Main_Package_ID__c = selectedPackageId;
        isPackageSelected = true;
        
        if (pkg.Promotion_Package__r.size() > 0) {
            
        }
    }
    
    /**
    * @description : Action to be called when Add Line Item button clicked
    *           on Line Item section of of the VF Page
    */
    public void addLineItem() {
        
        //orderId = 'a17N0000001w3Cg';
        
        // for testing
        orderLineItemList = [select Id, Name, Promotion_ID__r.Name, Main_Package_ID__r.Name, 
                Qty__c, Start_Date__c, End_Date__c, Main_Package_Type__c, Main_Package_Billing_Type__c, /*Subscription_Rate__c,*/ 
                Addon_Package__r.Package_Code__c, Addon_Package__r.Name, (select Gift_Name__c, Type__c, Price__c from Order_Line_Item_Gifts__r) 
                from Order_Line_Item__c where Order__c = :orderId];
        
        
        //system.debug('>>> ' + orderLineItemList[0].Order_Line_Item_Gifts__r);
        // end for testing
        
        
        // save order line item
        
        
        // save order line item gift
    }
    
    
    /**
    * @description : Action to be called when Remove button clicked
    *           on Line Item section of of the VF Page
    */
    public void removeLineItem() {
        // delete the order line item
    }
    

    /**
    * @description : Action to be called when Promotion Result (row) is click
    *           on Search section of of the VF Page
    */
    public list<Promotion_Package__c> getPromotionPackages() {
        
        list<Promotion_Package__c> promotionPackageList = new list<Promotion_Package__c>();
        
        // query the promotion packages based on the selectedPromotionId variable
        promotionPackageList = [select Package_Name__c, Package_Name__r.Name, Package_Name__r.Package_Type__c, 
                Package_Name__r.Subscription_Type__c from Promotion_Package__c 
                where Promotion__c = :selectedPromotionId];
        
        return promotionPackageList;
    }
    
    
    /**
    * @description : Action to be called when Package Result (row) is click
    *           on Search section of of the VF Page
    */
    public Order__c getPackageDetails() {
        
        return null;
    }

 
    /**
    * @description : Action to be called when Search button is click
    *           on Search section of of the VF Page
    */      
    public void executeSearch() {
        
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
        
        isExecuteSearch = true;
        isPackageSelected = false;
    }
    
    
    public void searchPackage() {
        String qryEsc;
        
        
        string qry = 'select Id, Name, Package_Type__c, Subscription_Type__c, Subscription_Period__c from Package__c where Name like \'%' + searchText + '%\'';
        qryEsc = String.escapeSingleQuotes(qry);
        //qry.escapeSingleQuotes();
        packageResultList = Database.query(qry);
    }
    
    
    public void searchPromotion() {
        
        String qryEsc;
        
        
        string qry = 'select Promotion__c, Promotion__r.Name, Promotion__r.Effective_Start_Date__c, Promotion__r.Effective_End_Date__c, ';
        qryEsc = String.escapeSingleQuotes(qry);
        qry += 'Promotion__r.Contract_Period__c, Package_Name__c from Promotion_Package__c where Promotion__r.Name like \'%' + searchText + '%\'';
        //qry +=' and Package_Name__r.Billing_Type__c=\'' + searchBillingType + '\'';
        promotionResultList = Database.query(qry);
        
        if (promotionResultList.size() == 0) {
            promotionResultList = null;
        }
        
    }
    
    @remoteAction
    public static string retrieveRelatedPackages(string promotionId) {
        
        list<Promotion_Package__c> promotionPackages =    [select Package_Name__c, Package_Name__r.Name, Package_Name__r.Package_Type__c, 
                Package_Name__r.Subscription_Type__c, Package_Name__r.Subscription_Period__c 
                from Promotion_Package__c where Promotion__c = :promotionId];
        
        return JSON.serialize(promotionPackages);
    }
    
    
    public void populateAddOn() {
        
        try {
            addOnPackage = [select Id, Name from Package__c where Name = :selectedAddOnPackage limit 1];
        } catch (exception e) {
            addOnPackage = new Package__c();
        }
    }
    
    
    
    // start gifts
    public class GiftWrapper {
        
        public boolean selectGift { get; set; }
        public Promotion_Gift__c promotionGift { get; set; }
    }
    
    
    public void  populatePromotionGifts() {
        
        promotionGifts = new list<GiftWrapper>();
        
        for (Promotion_Gift__c pg : [select Gift__c, Gift__r.Name, Gift__r.Gift_Type__c, Gift__r.Gift_Cost__c, 
                Balance_Quantity__c from Promotion_Gift__c where Promotion__c = :selectedPromotionId]) {
                    
            GiftWrapper gw = new GiftWrapper();
            gw.selectGift = false;
            gw.promotionGift = pg;
            
            promotionGifts.add(gw); 
        }
        
        isPromotionSelected = true;
    }
    // end gifst
    
    
    // start asia1
    public class Asia1Wrapper  {
        public string userId { get; set; }
        public string asia1Id { get; set; }
        public list<Asia1SubscriptionWrapper> asia1Subscriptions { get; set; } 
    }
    
    
    public class Asia1SubscriptionWrapper {
        public string serviceFlagId { get; set; }
        public string serviceFlagName { get; set; }
        public string status { get; set; }
        public integer concurrent { get; set; }
    }
    
    
    public void addAsia1Account() {
        asia1Accounts.add(asia1SingleAccount);
        asia1SingleAccount = new Asia1__c();
    }
    
    
    public void addAsia1ExistingAccount() {
        //asia1SelectedExistingId = 'a0AN0000002ZQYm';
        Asia1__c tmpAsia1 = [select Id, User_ID_LDAP_ID__c from Asia1__c where Id = :asia1SelectedExistingId];

        Asia1Wrapper newAsia1Subscription = new Asia1Wrapper();
        newAsia1Subscription.userId = tmpAsia1.User_ID_LDAP_ID__c;
        newAsia1Subscription.asia1Id = tmpAsia1.Id;
        
        list<Asia1SubscriptionWrapper> tmpAsia1Subscriptions = new list<Asia1SubscriptionWrapper>();
        
        for (Package_Access_Flag__c paf : retrieveServiceFlags(selectedPackageId)) {
            
            Asia1SubscriptionWrapper tmpAsia1Sub = new Asia1SubscriptionWrapper();
            
            tmpAsia1Sub.status = 'Enabled';
            tmpAsia1Sub.serviceFlagId = paf.Package_Service_Access_Flag__c;
            tmpAsia1Sub.serviceFlagName = paf.Package_Service_Access_Flag__r.Name;
            
            if (paf.No_of_Concurrent_Users__c != null) {
                tmpAsia1Sub.concurrent = integer.valueOf(paf.No_of_Concurrent_Users__c);
            }
            
            tmpAsia1Subscriptions.add(tmpAsia1Sub);
        }
        
        newAsia1Subscription.asia1Subscriptions = tmpAsia1Subscriptions;
        
        asia1Subscriptions.add(newAsia1Subscription);
        
    }
    

    public void validateNewAsia1Account() {
        
        
        // check require fields
        if (asia1SingleAccount.User_ID_LDAP_ID__c == null) {
            //system.assert(false);
            asia1SingleAccount.User_ID_LDAP_ID__c.addError('Required Field.');
        }
        
        if (asia1SingleAccount.Display_Name__c == null) {
            asia1SingleAccount.Display_Name__c.addError('Requireed Field.');
        }
        
        if (asia1SingleAccount.Password__c == null) {
            asia1SingleAccount.Password__c.addError('Required Field.');
        }
        
        if (asia1SingleAccount.Email__c == null) {
            asia1SingleAccount.Email__c.addError('Required Field.');
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
    }
    
    
    public void selectAsia1Source() {
        
        isAsia1Individual = true;
        
        if (selectedAsia1Creation == 'new') {
            isAsia1Existing = false;
        } else {
            isAsia1Existing = true;
        }
    }
    
    
    public list<Package_Access_Flag__c> retrieveServiceFlags(id pkgId) {
        
        return [select Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, 
                No_of_Concurrent_Users__c from Package_Access_Flag__c where Package__c = :pkgId];
        
    }
    
    public void changeAsia1Mode() {
        
        if (asia1CreationMode == 'bulk') {
            isAsia1Individual = false;
        } else {
            isAsia1Individual = true;
        }
    }
    
    public list<SelectOption> getAsia1ExistingAccounts() {
        
        set<id> tmpAsia1Ids = new set<id>();
        for (Asia1Wrapper tmpw : asia1Subscriptions) {
            tmpAsia1Ids.add(tmpw.asia1Id);
        }
        
        list<SelectOption> options = new list<SelectOption>();
        
        
        for (Asia1__c asia1 : [select Id, User_ID_LDAP_ID__c from Asia1__c where Contact__r.Account.Id = :accountId and Id not in :tmpAsia1Ids]) {
            options.add(new SelectOption(asia1.Id, asia1.User_ID_LDAP_ID__c));
        }
        
        return options;
    }
    // end asia1
}