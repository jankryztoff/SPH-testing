@isTest
private class BT_TH_VSS085DX_ManageRecipientConTest{
    static testMethod void testBT_TH_VSS085DX_ManageRecipientContacts(){
        //start test data
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.HDS_Recipient_Id__c = null;
         database.insert(acc);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.HDS_Contact_Id__c = '123456';
         con.Recipient_Number__c = 1;
         database.insert(con);
        
        List<BT_CO_VSS_ImportVendorSubscription__c> recordsList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        BT_CO_VSS_ImportVendorSubscription__c ivs = new BT_CO_VSS_ImportVendorSubscription__c();
        ivs.HdsRecipientId__c = acc.HDS_Recipient_Id__c;
        ivs.HdsContactId__c = con.HDS_Contact_Id__c;
        ivs.RecipientUpdateIndicator__c = 'U';
        ivs.RecipientOfficeTelephoneExtension__c = '123456';
        ivs.CrsmContactId__c = '1';
        recordsList.add(ivs);
        database.insert(recordsList);
        
        BT_TH_VSS085DX_ManageMaps mapManager = new BT_TH_VSS085DX_ManageMaps();
        //end test data
    
        test.startTest();
        BT_TH_VSS085DX_ManageRecipientContacts mrc = new BT_TH_VSS085DX_ManageRecipientContacts();
        mrc.execute(recordsList, mapManager);
        
        recordsList[0].HdsContactId__c = '123';
        database.update(recordsList[0]);
        
        BT_TH_VSS085DX_ManageRecipientContacts mrc2 = new BT_TH_VSS085DX_ManageRecipientContacts();
        mrc2.execute(recordsList, mapManager);
        
        recordsList[0].HdsContactId__c = null;
        ivs.CrsmContactId__c = null;
        database.update(recordsList[0]);
        
        BT_TH_VSS085DX_ManageRecipientContacts mrc3 = new BT_TH_VSS085DX_ManageRecipientContacts();
        mrc3.execute(recordsList, mapManager);
        test.stopTest();
    }
}