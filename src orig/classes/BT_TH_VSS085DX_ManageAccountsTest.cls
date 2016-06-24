/*April Veloso
  11/3/2015
  Test class for BT_TH_VSS085DX_ManageAccounts
*/

@isTest(SeeAllData = False)
private class BT_TH_VSS085DX_ManageAccountsTest{
    static testMethod void testT_TH_VSS085DX_ManageAccountsTest(){
    
        
                BT_CO_VSS_ImportVendorSubscription__c btcc = new BT_CO_VSS_ImportVendorSubscription__c();
                btcc.HdsRecipientId__c = 'HdsRecipientId';
                btcc.CrsmAccountId__c = 'CrsmAccountId';
                btcc.SubscriberName__c = 'SubscriberName';
                btcc.SubscriberLevel__c = 'ABC';
                btcc.SubscriberUnit__c = 'Unit';
                btcc.SubscriberPostalCode__c = 'Postal';
                btcc.subscriberStreetCode__c = 'Street';
                btcc.subscriberBuildingCode__c = 'CODE23';
                btcc.subscriberHouseBlockNumber__c ='Block12';
                btcc.subscriberResidentTelephoneNumber__c = '2535555';
                btcc.subscriberOfficeTelephoneNumber__c = '2503214';
                btcc.subscriberOfficeTelephoneExtension__c = '25031211';
                btcc.subscriberFaxNumber__c = '2501111';
                btcc.subscriberHandphoneNumber__c = '09177751245';
                btcc.subscriberEmail__c ='subscriberEmail@email.com';
                btcc.SubscriberNric__c = 'nric';
                btcc.SubscriberCompanyName__c = 'SPH';
                btcc.SubscriberSalutation__c = 'Mr';
                btcc.SubscriberUpdateIndicator__c = 'Y';
                btcc.HdsComplimentaryTypeName__c ='HdsComplimentaryTypeName';
                database.insert(btcc);
          
                
                List<BT_CO_VSS_ImportVendorSubscription__c> btccList = [SELECT HdsRecipientId__c, 
                CrsmAccountId__c, SubscriberName__c, SubscriberLevel__c, SubscriberUnit__c, subscriberStreetCode__c,
                SubscriberPostalCode__c,subscriberBuildingCode__c,subscriberHouseBlockNumber__c,
                subscriberResidentTelephoneNumber__c,subscriberOfficeTelephoneNumber__c,
                subscriberOfficeTelephoneExtension__c, subscriberFaxNumber__c, subscriberHandphoneNumber__c,
                subscriberEmail__c, SubscriberNric__c,SubscriberCompanyName__c,SubscriberSalutation__c,
                SubscriberUpdateIndicator__c, HdsComplimentaryTypeName__c FROM BT_CO_VSS_ImportVendorSubscription__c WHERE Id =: btcc.id];
                 
                BT_TH_VSS085DX_ManageMaps mapManager = new BT_TH_VSS085DX_ManageMaps();
                
                Test.startTest();
                    BT_TH_VSS085DX_ManageAccounts manageaccounts = new BT_TH_VSS085DX_ManageAccounts();
                    manageaccounts.execute(btccList, mapManager);
                Test.stopTest();
    
    
    
    }
    
}