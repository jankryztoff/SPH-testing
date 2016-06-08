/*April Veloso
 10/20/2015
 Test class for BT_AB_MIRO055DX_VendorCreditingFileFinal
*/

@isTest(SeeAllData=False)
private class BT_AB_MIRO055DX_VendorCreditingFileFTest {

    static testmethod void testBT_AB_MIRO055DX_VendorCreditingFileF(){
                
                BatchInterface_Settings__c batchInterface = new BatchInterface_Settings__c();
                batchInterface.Name = 'Endpoint Delegator';
                batchInterface.Value__c = 'Delegate';
                database.insert(batchInterface);
                
                Integration_Settings__c integ = new Integration_Settings__c();
                integ.Name = 'Endpoint Delegator';
                integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
                database.insert(integ);
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                ACC.Airline_Indicator__c = true;
                insert acc;
                //objectMap.put('Account', acc);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.publication_code__c = '1424';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                BT_CO_MIRO_SubscriptionIssueFile__c btsubscription = new BT_CO_MIRO_SubscriptionIssueFile__c();
                btsubscription.Publication_Code__c = '1424';
                btsubscription.Vendor_Number__c = 'MLAGN';
                btsubscription.subscription_copies__c = 5;
                database.insert(btsubscription);
                
                DateTime startTime = date.today();
                DateTime endTime = date.today()+1;
                
                
                
                Test.startTest();
                BT_AB_MIRO055DX_VendorCreditingFileFinal batch = new BT_AB_MIRO055DX_VendorCreditingFileFinal(startTime, endTime);
                ID batchprocessid = Database.executeBatch(batch, 100);
                system.assertNotEquals(null, batchprocessid);
                Test.stopTest();
     }      
     static testmethod void testBT_AB_MIRO055DX_VendorCreditingFileF2(){
                
                BatchInterface_Settings__c batchInterface = new BatchInterface_Settings__c();
                batchInterface.Name = 'Endpoint Delegator';
                batchInterface.Value__c = 'Delegate';
                database.insert(batchInterface);
                
                Integration_Settings__c integ = new Integration_Settings__c();
                integ.Name = 'Endpoint Delegator';
                integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
                database.insert(integ);
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                RecordType rectype1 =  [Select Id, Name From RecordType Where SObjectType='Account' And Name = 'Vendor' LIMIT 1];
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                acc.RecordTypeId = rectype1.id;
                acc.Airline_Indicator__c = true;
                acc.Active__C = true;
                acc.Vendor_Group__c = 'M';
                acc.Vendor_code__c = 'AR124';
                insert acc;
                //objectMap.put('Account', acc);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.publication_code__c = '1424';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                BT_CO_MIRO_SubscriptionIssueFile__c btsubscription = new BT_CO_MIRO_SubscriptionIssueFile__c();
                btsubscription.Publication_Code__c = '1424';
                btsubscription.Vendor_Number__c = 'MLAGN';
                btsubscription.subscription_copies__c = 5;
                database.insert(btsubscription);
                
                DateTime startTime = date.today();
                DateTime endTime = date.today()+1;
                
                
                
                Test.startTest();
                BT_AB_MIRO055DX_VendorCreditingFileFinal batch = new BT_AB_MIRO055DX_VendorCreditingFileFinal(startTime, endTime);
                ID batchprocessid = Database.executeBatch(batch, 100);
                system.assertNotEquals(null, batchprocessid);
                Test.stopTest();
     }          
     static testmethod void testBT_AB_MIRO055DX_VendorCreditingFileF3(){
                
                BatchInterface_Settings__c batchInterface = new BatchInterface_Settings__c();
                batchInterface.Name = 'Endpoint Delegator';
                batchInterface.Value__c = 'Delegate';
                database.insert(batchInterface);
                
                Integration_Settings__c integ = new Integration_Settings__c();
                integ.Name = 'Endpoint Delegator';
                integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
                database.insert(integ);
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                RecordType rectype1 =  [Select Id, Name From RecordType Where SObjectType='Account' And Name = 'Mailing Agent' LIMIT 1];
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                acc.RecordTypeId = rectype1.id;
                acc.Airline_Indicator__c = true;
                acc.Active__C = true;
                acc.Vendor_Group__c = 'M';
                acc.Vendor_code__c = 'AR124';
                acc.mailing_agent_code__c = 'mailing12';
                insert acc;
                //objectMap.put('Account', acc);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.publication_code__c = '1424';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                BT_CO_MIRO_SubscriptionIssueFile__c btsubscription = new BT_CO_MIRO_SubscriptionIssueFile__c();
                btsubscription.Publication_Code__c = '1424';
                btsubscription.Vendor_Number__c = 'MLAGN';
                btsubscription.subscription_copies__c = 5;
                database.insert(btsubscription);
                
                DateTime startTime = date.today();
                DateTime endTime = date.today()+1;
                
                
                
                Test.startTest();
                BT_AB_MIRO055DX_VendorCreditingFileFinal batch = new BT_AB_MIRO055DX_VendorCreditingFileFinal(startTime, endTime);
                ID batchprocessid = Database.executeBatch(batch, 100);
                system.assertNotEquals(null, batchprocessid);
                Test.stopTest();
     }
    
         static testmethod void testBT_AB_MIRO055DX_VendorCreditingFileF4(){
                
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };    
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
                
        Postal_Zone__c PostalZone = new Postal_Zone__c();
        PostalZone.postal_sector__c = 'AB';
        PostalZone.Name = 'PostalZone';
        PostalZone.Postal_Zone_Name__c = 'Postal123';
        database.insert(PostalZone);
        
        Publication__c pub = new Publication__c();
        pub.publication_code__c = '1234';
        pub.Earliest_Start_Date__c = Date.newInstance(2017, 08, 18);
        pub.Published_Days__c = 'NNNNNNN';
        pub.Publication_Type__c = 'A';
        insert pub;
        
        BT_CO_MIRO_SubscriptionIssueFile__c subs = new BT_CO_MIRO_SubscriptionIssueFile__c();
        subs.Publication_Code__c = '1234';
        subs.Publication_Issue_Date__c = date.today();
        subs.postal_sector__c = 'AB';
        subs.vendor_number__c = 'MLAGN';
        subs.office_house_mail_indicator__c = 'A';
        subs.house_type__c = 'A';
        subs.sub_channel_code__c = 'ABC';
        subs.subscription_copies__c = 2;
        subs.subscriberId__c = 'subs123';
        insert subs;
             
        DateTime startTime = date.today();
        DateTime endTime = date.today()+1;
             
        test.startTest();
         
            BT_AB_MIRO055DX_VendorCreditingFileFinal batch = new BT_AB_MIRO055DX_VendorCreditingFileFinal(startTime, endTime);
            database.executeBatch(batch, 200);
             
        test.stopTest();    
     }
    
}