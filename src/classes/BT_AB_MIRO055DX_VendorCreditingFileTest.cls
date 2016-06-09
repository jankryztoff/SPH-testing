@isTest 
public class BT_AB_MIRO055DX_VendorCreditingFileTest {
        static testMethod void testBT_AB_MIRO055DX_VendorCreditingFile() {
        
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
        
        
        
        List<Account> accList = TestDataFactory.createAccount(1, 'Vendor');
        accList[0].recordTypeId = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Vendor'].id;
        accList[0].Name = 'Vendor';
        accList[0].Vendor_Code__c = '01';
        accList[0].Active__c = true;
        accLIst[0].Vendor_group__c = '1';
        database.insert(accList);
        
        
        BT_CO_MIRO_SubscriptionIssueFile__c sif1 = new BT_CO_MIRO_SubscriptionIssueFile__c();
        sif1.Publication_Code__c = 'code';
        sif1.Publication_Issue_Date__c = System.Today();
        sif1.postal_sector__c = 'MN';
        sif1.vendor_number__c = '01';
        sif1.office_house_mail_indicator__c = 'Y';
        sif1.house_type__c = 'A';
        sif1.sub_channel_code__c = 'ABC';
        sif1.subscription_copies__c = 200;
        sif1.subscriber_count__c = 100;
        
        insert sif1;
        
        //AggregateResult ar = [SELECT Publication_Code__c,Publication_Issue_Date__c,postal_sector__c,vendor_number__c,office_house_mail_indicator__c,house_type__c,
        //            sub_channel_code__c,sum(subscription_copies__c),count(subscriber_count__c) FROM BT_CO_MIRO_SubscriptionIssueFile__c where CreatedDate = :dateTime.now() AND Vendor_Number__c =:accList[0].Vendor_Code__c and Vendor_Number__c != 'MLAGN' and subscription_copies__c > 0 group by Publication_Code__c,Publication_Issue_Date__c,postal_sector__c,vendor_number__c, office_house_mail_indicator__c,house_type__c,sub_channel_code__c];
        //system.assertEquals(ar, null);
        
        
        
        test.startTest();
         
            BT_AB_MIRO055DX_VendorCreditingFile batch = new BT_AB_MIRO055DX_VendorCreditingFile();
            database.executeBatch(batch, 200);
            //Database.BatchableContext BC;
            //batch.execute(BC, accList);
        test.stopTest();    
        }

    static testMethod void testBT_AB_MIRO055DX_VendorCreditingFile2() {
        
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
        
        RecordType accRec = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Mailing_Agent'];
        
        List<Account> accList = TestDataFactory.createAccount(2, 'Mailing_Agent');
        accList[0].RecordTypeId = accRec.id;
        accList[0].Name = 'Mailing_Agent';
        accList[0].Mailing_Agent_Code__c = 'MLAGN';
       // accList[0].Vendor_group__c = 'H';
        accList[0].Active__c = true;

        database.insert(accList);
        
        system.assertNotEquals(accList.size(), 0);
        
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Internal'];
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.recordType = rt;
        database.insert(ad);
        
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Contact');
        for(Contact con: conList){
        con.AccountId = accList[0].id;
        con.Address__c =ad.id;
        }
        database.insert(conList);
        
        
        
        BT_CO_MIRO_SubscriptionIssueFile__c sif1 = new BT_CO_MIRO_SubscriptionIssueFile__c();
        sif1.Publication_Code__c = '03';
        sif1.Publication_Issue_Date__c = date.Today();
        sif1.postal_sector__c = 'AB';
        sif1.office_house_mail_indicator__c = 'A';
        sif1.house_type__c = 'A';
        sif1.sub_channel_code__c = 'ABC';
        sif1.vendor_number__c = '03';
        sif1.subscription_copies__c = 2;
        
        insert sif1;
        
        BA_INT_DATA_POOL__c datapoolHRecord = new BA_INT_DATA_POOL__c();
        
        datapoolHRecord.name = 'MIRO055DX';
        datapoolHRecord.job_id__c = 'MIRO055DX';
        datapoolHRecord.group_id__c = 'Master';
        datapoolHRecord.run_for_date__c = Date.today();      
        datapoolHRecord.insert_time__c = DateTime.now(); 
        datapoolHRecord.export_data__c = 'H,' + DateTime.now();       
        
        insert datapoolHRecord;   
        test.startTest();
        
        Set<Id> accID = new Set<Id>();
        accID.add(accList[0].id);
        
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE Id IN:accID AND Name = 'Mailing_Agent'];
        system.assertNotEquals(accountList, null); 
        
            BT_AB_MIRO055DX_VendorCreditingFile batch = new BT_AB_MIRO055DX_VendorCreditingFile();
            Id batchID = database.executeBatch(batch, 200);

        test.stopTest();    
        }
    
    static testMethod void testBT_AB_MIRO055DX_VendorCreditingFile3() {
        
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
        
        RecordType accRec = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Vendor'];
        
        List<Account> accList = TestDataFactory.createAccount(2, 'Vendor');
        accList[0].RecordTypeId = accRec.id;
        accList[0].Name = 'Vendor';
        accList[0].Vendor_group__c = 'A';
        accList[0].Active__c = true;
        accList[0].Vendor_Code__c = '01';

        database.insert(accList);
        
        system.assertNotEquals(accList.size(), 0);
        
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Internal'];
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.recordType = rt;
        database.insert(ad);
        
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Contact');
        for(Contact con: conList){
        con.AccountId = accList[0].id;
        con.Address__c =ad.id;
        }
        database.insert(conList);
        
        
        
        BT_CO_MIRO_SubscriptionIssueFile__c sif1 = new BT_CO_MIRO_SubscriptionIssueFile__c();
        sif1.Publication_Code__c = '03';
        sif1.Publication_Issue_Date__c = date.Today();
        sif1.postal_sector__c = 'AB';
        sif1.office_house_mail_indicator__c = 'A';
        sif1.house_type__c = 'A';
        sif1.sub_channel_code__c = 'ABC';
        sif1.vendor_number__c = '03';
        sif1.subscription_copies__c = 2;
        
        insert sif1;
        
        BA_INT_DATA_POOL__c datapoolHRecord = new BA_INT_DATA_POOL__c();
        
        datapoolHRecord.name = 'MIRO055DX';
        datapoolHRecord.job_id__c = 'MIRO055DX';
        datapoolHRecord.group_id__c = 'Master';
        datapoolHRecord.run_for_date__c = Date.today();      
        datapoolHRecord.insert_time__c = DateTime.now(); 
        datapoolHRecord.export_data__c = 'H,' + DateTime.now();       
        
        insert datapoolHRecord;   
        test.startTest();
        
        Set<Id> accID = new Set<Id>();
        accID.add(accList[0].id);
        
        String interfaceId = 'MIRO055DX';
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId); 
        
        List<BT_CO_MIRO_SubscriptionIssueFile__c> btcoSub = [SELECT CreatedDate FROM BT_CO_MIRO_SubscriptionIssueFile__c WHERE CreatedDate = : Datetime.valueOfGmt(batchRunDate+' 00:00:00') ];
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE Id IN:accID AND Name = 'Vendor'];
        system.assertNotEquals(accountList, null); 
        
            BT_AB_MIRO055DX_VendorCreditingFile batch = new BT_AB_MIRO055DX_VendorCreditingFile();
            Id batchID = database.executeBatch(batch, 200);

        test.stopTest();    
        }
}