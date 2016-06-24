/**
 * Trigger Name: BT_AT_VSS085DX_ImportVendorSubscription
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
 * History: 2015/05/22 Renino Niefes splitted the code into multiple trigger handlers
 * History: 2015/05/25 Renino Niefes added Subscription Vendor Manager
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW  
 */

trigger BT_AT_VSS085DX_ImportVendorSubscription on BT_CO_VSS_ImportVendorSubscription__c (before insert, before update) 
{
    List<BT_CO_VSS_ImportVendorSubscription__c> recordsListValid = new List<BT_CO_VSS_ImportVendorSubscription__c>();
    List<BT_CO_VSS_ImportVendorSubscription__c> recordsList = trigger.new; 
        
    BT_TH_VSS085DX_ManageMaps mapManager = new BT_TH_VSS085DX_ManageMaps();
    
    BT_TH_VSS085DX_Validations validator = new BT_TH_VSS085DX_Validations();
    recordsListValid = validator.validateRecords(recordsList, mapManager);
    
    BT_TH_VSS085DX_ManageAddresses addressManager = new BT_TH_VSS085DX_ManageAddresses();
    addressManager.execute(recordsListValid, mapManager);
    
    BT_TH_VSS085DX_ManageAccounts accountManager = new BT_TH_VSS085DX_ManageAccounts();
    accountManager.execute(recordsListValid, mapManager);

    BT_TH_VSS085DX_ManageRecipientContacts recipientContactManager = new BT_TH_VSS085DX_ManageRecipientContacts();
    recipientContactManager.execute(recordsListValid, mapManager);
    
    BT_TH_VSS085DX_ManageBillingContacts billContactManager = new BT_TH_VSS085DX_ManageBillingContacts();
    billContactManager.execute(recordsListValid, mapManager);
    
    BT_TH_VSS085DX_ManageSubscriptions subscriptionManager = new BT_TH_VSS085DX_ManageSubscriptions();
    subscriptionManager.execute(recordsListValid, mapManager);
    
    BT_TH_VSS085DX_ManageSubVenPublications subVenPublicationManager = new BT_TH_VSS085DX_ManageSubVenPublications();
    subVenPublicationManager.execute(recordsListValid, mapManager);
    
    BT_TH_VSS085DX_ManageOrders orderManager = new BT_TH_VSS085DX_ManageOrders();
    orderManager.execute(recordsListValid, mapManager);
}