@isTest
private class BT_TH_VSS085DX_ManageAddressesTest{
    static testmethod void BT_TH_VSS085DX_ManageAddressesTest(){
     Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.HDS_Recipient_Id__c = null;    
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '12345';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        database.insert(postal);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        database.insert(addressRec);
        
        /*Contact con = TestDataFactory.createContact(1)[0];
        con.HDS_Contact_Id__c = '123456';
        database.insert(con);*/
        
      
        List<BT_CO_VSS_ImportVendorSubscription__c> VSSImp = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        for(counter=0;counter<5;counter++){
            BT_CO_VSS_ImportVendorSubscription__c VSS = new BT_CO_VSS_ImportVendorSubscription__c();
            //VSS.HdsContactId__c = con.HDS_Contact_Id__c;
            //VSS.SubscriberUpdateIndicator__c = 'u';
            VSS.SubscriberOfficeTelephoneExtension__c = '123';
            VSS.SubscriberHouseBlockNumber__c = postal.House_Block_Number__c;
            VSS.RecipientHouseBlockNumber__c = '80';
            VSS.subscriberPostalCode__c = '12345';
            VSS.RecipientPostalCode__c = '12345';
            VSS.SubscriberLevel__c = '10';
            VSS.RecipientLevel__c = '15';
            VSS.SubscriberUnit__c = '20';
            VSS.RecipientUnit__c = '30';
            VSSImp.add(VSS);
        }
        database.insert(VSSImp);
        
        BT_TH_VSS085DX_ManageMaps maps = new BT_TH_VSS085DX_ManageMaps();
        //end test data
        
        test.startTest();
            BT_TH_VSS085DX_ManageAddresses manageAdd = new BT_TH_VSS085DX_ManageAddresses();
            manageAdd.execute(VSSImp, maps);    
        test.stopTest();
    
    
    }//end BT_TH_VSS085DX_ManageAddressesTest
}//end BT_TH_VSS085DX_ManageAddressesTest