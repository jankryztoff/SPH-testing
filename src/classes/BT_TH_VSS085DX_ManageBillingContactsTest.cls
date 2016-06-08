/**
* Class Name: BT_TH_VSS085DX_ManageBillingContactsTest
* @author: Ana Fe Dumangas    
* Date: 10/15/15
* @description: Test Class for BT_TH_VSS085DX_ManageBillingContacts
*/
@isTest
private class BT_TH_VSS085DX_ManageBillingContactsTest{
    static testMethod void testBT_TH_VSS085DX_ManageBillingContacts(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.HDS_Recipient_Id__c = null;    
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.HDS_Contact_Id__c = '123456';
        database.insert(con);
        
        List<BT_CO_VSS_ImportVendorSubscription__c> VSSImp = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        for(counter=0;counter<5;counter++){
            BT_CO_VSS_ImportVendorSubscription__c VSS = new BT_CO_VSS_ImportVendorSubscription__c();
            VSS.HdsContactId__c = con.HDS_Contact_Id__c;
            VSS.SubscriberUpdateIndicator__c = 'u';
            VSS.SubscriberOfficeTelephoneExtension__c = '123';
            VSSImp.add(VSS);
        }
        database.insert(VSSImp);
        
        BT_TH_VSS085DX_ManageMaps maps = new BT_TH_VSS085DX_ManageMaps();
        //end test data
        
        test.startTest();
            BT_TH_VSS085DX_ManageBillingContacts manageBC = new BT_TH_VSS085DX_ManageBillingContacts();
            manageBC.execute(VSSImp, maps);    
        test.stopTest();
    }
    
    static testMethod void testBT_TH_VSS085DX_ManageBillingContacts2(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.HDS_Recipient_Id__c = null;    
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Recipient_Number_Show__c = '123';
        database.insert(con);
        
        List<BT_CO_VSS_ImportVendorSubscription__c> VSSImp = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        for(counter=0;counter<5;counter++){
            BT_CO_VSS_ImportVendorSubscription__c VSS = new BT_CO_VSS_ImportVendorSubscription__c();
            VSS.crsmContactId__c = con.Recipient_Number_Show__c;
            VSS.SubscriberUpdateIndicator__c = 'u';
            VSS.SubscriberOfficeTelephoneExtension__c = '123';
            VSSImp.add(VSS);
        }
        database.insert(VSSImp);
        
        BT_TH_VSS085DX_ManageMaps maps = new BT_TH_VSS085DX_ManageMaps();
        //end test data
        
        test.startTest();
            BT_TH_VSS085DX_ManageBillingContacts manageBC = new BT_TH_VSS085DX_ManageBillingContacts();
            manageBC.execute(VSSImp, maps);    
        test.stopTest();
    }
    
    static testMethod void testBT_TH_VSS085DX_ManageBillingContacts3(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.HDS_Recipient_Id__c = null;    
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Recipient_Number_Show__c = '123';
        con.Recipient_Number__c = 123;
        database.insert(con);
        
        List<BT_CO_VSS_ImportVendorSubscription__c> VSSImp = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        for(counter=0;counter<5;counter++){
            BT_CO_VSS_ImportVendorSubscription__c VSS = new BT_CO_VSS_ImportVendorSubscription__c();
            VSS.crsmContactId__c = con.Recipient_Number_Show__c;
            VSS.SubscriberUpdateIndicator__c = 'u';
            VSS.SubscriberOfficeTelephoneExtension__c = '123';
            VSSImp.add(VSS);
        }
        database.insert(VSSImp);
        
        Contact c = [SELECT Recipient_Number_Show__c FROM Contact WHERE id=:con.Id];
        system.assertEquals(c.Recipient_Number_Show__c, VSSImp[0].CrsmContactId__c);
        
        BT_TH_VSS085DX_ManageMaps maps = new BT_TH_VSS085DX_ManageMaps();
        //end test data
        
        test.startTest();
            BT_TH_VSS085DX_ManageBillingContacts manageBC = new BT_TH_VSS085DX_ManageBillingContacts();
            manageBC.execute(VSSImp, maps);    
        test.stopTest();
    }
}