/**
 * Class Name: SP_PopulateVDCCreditNotesTest
 * @author: Johnmar T. Diamante
 * Date: 2015/07/14
 * Requirement/Project Name: N/A
 * @description This class will test SP_PopulateVDCCreditNotes.
 *
 */
@isTest
 private class SP_PopulateVDCCreditNotesTest{
     
     static testmethod void SP_PopulateVDCCreditNotesTest1(){
     
     
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
        
        List<BT_CO_VBS_CreditDebit__c> bt_co_vbs_creditDebitList = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
        for (BT_CO_VBS_CreditDebit__c obj : bt_co_vbs_creditDebitList ) {
        obj.Note_Number__c = 12345;
        obj.Reason_Code__c = 'P';
        obj.Amt_Before_GST__c = 100.00;
        obj.GST_Amount__c = 200.00;
        obj.Publication_Code__c = 'TEST';
        obj.Posting_Date__c = date.today();
        obj.Job_Id__c = 'TEST';
        }
        Database.insert(bt_co_vbs_creditDebitList);
        
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(1);
        for(VDC_CREDITNOTE__c vc : vdc){
        vc.Credit_Note_Number__c = 123;
        vc.Credit_Debit_Indicator__c = 'C';
        }
        Database.insert(vdc);
        
        Set<Id> vdcId = new Set<Id>();
        for(VDC_CREDITNOTE__c vc : vdc){
        vdcId.add(vdc[0].Id);
        }
        
        List<VDC_CREDITNOTE__c> vdc1 = [SELECT Id, Vendor_Number__c, Job_Id__c, Credit_Note_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c FROM VDC_CREDITNOTE__c WHERE Id IN :vdcId];
       
        String batchCodeParam1 = 'SPOO1';
        
        test.startTest();

        SP_PopulateVDCCreditNotes batch = new SP_PopulateVDCCreditNotes(batchCodeParam1, bt_co_vbs_creditDebitList[0].id);

        database.executeBatch(batch, 200);
               
        Database.BatchableContext BC;
        batch.execute(BC, bt_co_vbs_creditDebitList);
        batch.finish(BC);
        test.stopTest();    
     
       }
       
       static testmethod void SP_PopulateVDCCreditNotesTest2(){
     
     
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
        
             Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
             database.insert(acc);
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             database.insert(billAcc);
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             database.insert(pack);
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today();
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(1);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Term_Length__c = 1;
             subscription[0].Term_Length1__c = '1'; 
             database.insert(subscription);
             
             List<Order__c> orders = TestDataFactory.createOrder(1);
             for(Order__c ord : orders){
             ord.Account__c = acc.id;
             ord.Order_Type__c = 'Renewal'; 
             ord.Base_Subscription__c = subscription[0].id;
             }      
             database.insert(orders);
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = orders[0].id;
             ordLineItem.Subscription__c = subscription[0].id;
             ordLineItem.Main_Package_ID__c = pack.id;
             ordLineItem.Start_Date__c = Date.Today().addDays(2);   
             database.insert(ordLineItem);
             
             System.assertNotEquals(null, subscription[0].id);
             
            
            Case cas_0 = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas_0.Order__c = orders[0].Id;
            insert cas_0; 
             
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            database.insert(pub);

            
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = 1;
             creditDebit.Pagination__c = 20.90;
             creditDebit.Insertion__c = 20.90;
             creditDebit.Delivery__c = 20.90;
             creditDebit.Manual_Amt__c = 20.90;
             creditDebit.Subscription__c = subscription[0].id;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             database.insert(creditDebit);

        
        List<BT_CO_VBS_CreditDebit__c> bt_co_vbs_creditDebitList = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
        for (BT_CO_VBS_CreditDebit__c obj : bt_co_vbs_creditDebitList ) {
        obj.Note_Number__c = 12345;
        obj.Reason_Code__c = 'P';
        obj.Amt_Before_GST__c = 100.00;
        obj.GST_Amount__c = 200.00;
        obj.Publication_Code__c = 'TEST';
        obj.Posting_Date__c = date.today();
        obj.Job_Id__c = 'TEST';
        }
        Database.insert(bt_co_vbs_creditDebitList);
        
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(1);
        for(VDC_CREDITNOTE__c vc : vdc){
        vc.Credit_Note_Number__c = 123;
        vc.Credit_Debit_Indicator__c = 'C';
        }
        Database.insert(vdc);
        
        VDC_CREDITNOTE__c vcred = new VDC_CREDITNOTE__c();
        vcred.Credit_Note_Number__c = 123;
        vcred.Credit_Debit_Indicator__c = 'C';
        Database.insert(vcred);
        
        Manual_Vendor_Credits_Debits__c mvcd = new Manual_Vendor_Credits_Debits__c();
        mvcd.Job_Id__c = 'SP003';
        mvcd.Credit_Debit_Indicator__c = 'C';
        mvcd.Credit_Debit_Vendor_Reason__c = '01';
        mvcd.Amt_After_GST__c =100.00;
        mvcd.Remarks__c = 'Remark';
        mvcd.Vendor__c = acc.id;
        mvcd.Case__c = cas_0.id;
        mvcd.Publication__c = pub.id;
        mvcd.Subscription__c = subscription[0].id;
        Database.insert(mvcd);

        
        Set<Id> vdcId = new Set<Id>();
        for(VDC_CREDITNOTE__c vc : vdc){
        vdcId.add(vdc[0].Id);
        }
        
        List<VDC_CREDITNOTE__c> vdc1 = [SELECT Id, Vendor_Number__c, Job_Id__c, Credit_Note_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c FROM VDC_CREDITNOTE__c WHERE Id IN :vdcId];
       
        String batchCodeParam1 = 'SPOO1';
        
        test.startTest();

        SP_PopulateVDCCreditNotes batch = new SP_PopulateVDCCreditNotes(batchCodeParam1, bt_co_vbs_creditDebitList[0].id, date.today(), date.today());
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(vcred);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(mvcd);
        database.executeBatch(batch, 200);
               
        Database.BatchableContext BC;
        batch.execute(BC, bt_co_vbs_creditDebitList);
        batch.finish(BC);
        test.stopTest();    
     
       }
       static testmethod void SP_PopulateVDCCreditNotesTestSP002(){
     
     
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
        
             Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
             database.insert(acc);
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             database.insert(billAcc);
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             database.insert(pack);
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today();
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(1);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Term_Length__c = 1;
             subscription[0].Term_Length1__c = '1'; 
             database.insert(subscription);
             
             List<Order__c> orders = TestDataFactory.createOrder(1);
             for(Order__c ord : orders){
             ord.Account__c = acc.id;
             ord.Order_Type__c = 'Renewal'; 
             ord.Base_Subscription__c = subscription[0].id;
             }      
             database.insert(orders);
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = orders[0].id;
             ordLineItem.Subscription__c = subscription[0].id;
             ordLineItem.Main_Package_ID__c = pack.id;
             ordLineItem.Start_Date__c = Date.Today().addDays(2);   
             database.insert(ordLineItem);
             
             System.assertNotEquals(null, subscription[0].id);
             
            
            Case cas_0 = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas_0.Order__c = orders[0].Id;
            insert cas_0; 
             
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            database.insert(pub);

            
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = 1.00;
             creditDebit.Pagination__c = 20.90;
             creditDebit.Insertion__c = 20.90;
             creditDebit.Delivery__c = 20.90;
             creditDebit.Manual_Amt__c = 20.90;
             creditDebit.Subscription__c = subscription[0].id;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             database.insert(creditDebit);

        
        List<BT_CO_VBS_CreditDebit__c> bt_co_vbs_creditDebitList = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
        for (BT_CO_VBS_CreditDebit__c obj : bt_co_vbs_creditDebitList ) {
        obj.Note_Number__c = 12345;
        obj.Reason_Code__c = 'P';
        obj.Amt_Before_GST__c = 100.00;
        obj.GST_Amount__c = 200.00;
        obj.Publication_Code__c = 'TEST';
        obj.Posting_Date__c = date.today();
        obj.Job_Id__c = 'TEST';
        }
        Database.insert(bt_co_vbs_creditDebitList);
        
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(1);
        for(VDC_CREDITNOTE__c vc : vdc){
        vc.Credit_Note_Number__c = 123;
        vc.Credit_Debit_Indicator__c = 'C';
        }
        Database.insert(vdc);
        
        VDC_CREDITNOTE__c vcred = new VDC_CREDITNOTE__c();
        vcred.Credit_Note_Number__c = 123;
        vcred.Credit_Debit_Indicator__c = 'C';
        vcred.Vendor_Number__c = '12345';
        vcred.Reason_Code_Category__c = 'Credit';
        vcred.Credit_Debit_Indicator__c = 'C';
        Database.insert(vcred);
        
        Manual_Vendor_Credits_Debits__c mvcd = new Manual_Vendor_Credits_Debits__c();
        mvcd.Job_Id__c = 'SP003';
        mvcd.Credit_Debit_Indicator__c = 'C';
        mvcd.Credit_Debit_Vendor_Reason__c = '01';
        mvcd.Amt_After_GST__c =100.00;
        mvcd.Remarks__c = 'Remark';
        mvcd.Vendor__c = acc.id;
        mvcd.Case__c = cas_0.id;
        mvcd.Publication__c = pub.id;
        mvcd.Subscription__c = subscription[0].id;
        Database.insert(mvcd);

        
        Set<Id> vdcId = new Set<Id>();
        for(VDC_CREDITNOTE__c vc : vdc){
        vdcId.add(vdc[0].Id);
        }
        
        List<VDC_CREDITNOTE__c> vdc1 = [SELECT Id, Vendor_Number__c, Job_Id__c, Credit_Note_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c FROM VDC_CREDITNOTE__c WHERE Id IN :vdcId];
       
        String batchCodeParam1 = 'SP002';
        Set<String> vendorNumberSetParam = new Set<String>();
        vendorNumberSetParam.add(vcred.Vendor_Number__c);
        Set<String> reasonCategorySetParam = new Set<String>();
        reasonCategorySetParam.add(vcred.Reason_Code_Category__c);
        Set<String> creditDebitIndicatorSetParam = new Set<String>();
        creditDebitIndicatorSetParam.add(vcred.Credit_Debit_Indicator__c);
        test.startTest();

        SP_PopulateVDCCreditNotes batch = new SP_PopulateVDCCreditNotes(batchCodeParam1, bt_co_vbs_creditDebitList[0].id, date.today(), date.today());
        SP_PopulateVDCCreditNotes.getCreditNotesMap(vendorNumberSetParam,reasonCategorySetParam,creditDebitIndicatorSetParam );
        SP_PopulateVDCCreditNotes.getReasonCodeCategory(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(vcred);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(mvcd);
        database.executeBatch(batch, 200);
               
        Database.BatchableContext BC;
        batch.execute(BC, bt_co_vbs_creditDebitList);
        batch.finish(BC);
        test.stopTest();    
     
       }
       static testmethod void SP_PopulateVDCCreditNotesTestAp2(){
     
     
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
        
             Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
             database.insert(acc);
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             database.insert(billAcc);
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             database.insert(pack);
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today();
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(1);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Term_Length__c = 1;
             subscription[0].Term_Length1__c = '1'; 
             database.insert(subscription);
             
             List<Order__c> orders = TestDataFactory.createOrder(1);
             for(Order__c ord : orders){
             ord.Account__c = acc.id;
             ord.Order_Type__c = 'Renewal'; 
             ord.Base_Subscription__c = subscription[0].id;
             }      
             database.insert(orders);
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = orders[0].id;
             ordLineItem.Subscription__c = subscription[0].id;
             ordLineItem.Main_Package_ID__c = pack.id;
             ordLineItem.Start_Date__c = Date.Today().addDays(2);   
             database.insert(ordLineItem);
             
             System.assertNotEquals(null, subscription[0].id);
             
            
            Case cas_0 = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas_0.Order__c = orders[0].Id;
            insert cas_0; 
             
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            database.insert(pub);

            
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = 1;
             creditDebit.Pagination__c = 20.90;
             creditDebit.Insertion__c = 20.90;
             creditDebit.Delivery__c = 20.90;
             creditDebit.Manual_Amt__c = 20.90;
             creditDebit.Subscription__c = subscription[0].id;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             database.insert(creditDebit);

        
        List<BT_CO_VBS_CreditDebit__c> bt_co_vbs_creditDebitList = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
        for (BT_CO_VBS_CreditDebit__c obj : bt_co_vbs_creditDebitList ) {
        obj.Note_Number__c = 12345;
        obj.Reason_Code__c = 'P';
        obj.Amt_Before_GST__c = 100.00;
        obj.GST_Amount__c = 200.00;
        obj.Publication_Code__c = 'TEST';
        obj.Posting_Date__c = date.today();
        obj.Job_Id__c = 'TEST';
        }
        Database.insert(bt_co_vbs_creditDebitList);
        
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(1);
        for(VDC_CREDITNOTE__c vc : vdc){
        vc.Credit_Note_Number__c = 123;
        vc.Credit_Debit_Indicator__c = 'C';
        }
        Database.insert(vdc);
        
        VDC_CREDITNOTE__c vcred = new VDC_CREDITNOTE__c();
        vcred.Credit_Note_Number__c = 123;
        vcred.Credit_Debit_Indicator__c = 'C';
        Database.insert(vcred);
        
        Manual_Vendor_Credits_Debits__c mvcd = new Manual_Vendor_Credits_Debits__c();
        mvcd.Job_Id__c = 'SP003';
        mvcd.Credit_Debit_Indicator__c = 'C';
        mvcd.Credit_Debit_Vendor_Reason__c = '01';
        mvcd.Amt_After_GST__c =100.00;
        mvcd.Remarks__c = 'Remark';
        mvcd.Vendor__c = acc.id;
        mvcd.Case__c = cas_0.id;
        mvcd.Publication__c = pub.id;
        mvcd.Subscription__c = subscription[0].id;
        Database.insert(mvcd);

        
        Set<Id> vdcId = new Set<Id>();
        for(VDC_CREDITNOTE__c vc : vdc){
        vdcId.add(vdc[0].Id);
        }
        
        List<VDC_CREDITNOTE__c> vdc1 = [SELECT Id, Vendor_Number__c, Job_Id__c, Credit_Note_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c FROM VDC_CREDITNOTE__c WHERE Id IN :vdcId];
       
        String batchCodeParam1 = 'SPOO1';
        
        test.startTest();

        SP_PopulateVDCCreditNotes batch = new SP_PopulateVDCCreditNotes(batchCodeParam1, bt_co_vbs_creditDebitList[0].id, date.today(), date.today());
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(vcred);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(mvcd);
        database.executeBatch(batch, 200);
               
        Database.BatchableContext BC;
        batch.execute(BC, bt_co_vbs_creditDebitList);
        batch.finish(BC);
        test.stopTest();    
     
       }
       static testmethod void SP_PopulateVDCCreditNotesTestSP002April(){
     
     
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
        
             Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
             database.insert(acc);
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             database.insert(billAcc);
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             database.insert(pack);
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today();
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(1);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Term_Length__c = 1;
             subscription[0].Term_Length1__c = '1'; 
             database.insert(subscription);
             
             List<Order__c> orders = TestDataFactory.createOrder(1);
             for(Order__c ord : orders){
             ord.Account__c = acc.id;
             ord.Order_Type__c = 'Renewal'; 
             ord.Base_Subscription__c = subscription[0].id;
             }      
             database.insert(orders);
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = orders[0].id;
             ordLineItem.Subscription__c = subscription[0].id;
             ordLineItem.Main_Package_ID__c = pack.id;
             ordLineItem.Start_Date__c = Date.Today().addDays(2);   
             database.insert(ordLineItem);
             
             System.assertNotEquals(null, subscription[0].id);
             
            
            Case cas_0 = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas_0.Order__c = orders[0].Id;
            insert cas_0; 
             
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            database.insert(pub);

            
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = 1.00;
             creditDebit.Pagination__c = 20.90;
             creditDebit.Insertion__c = 20.90;
             creditDebit.Delivery__c = 20.90;
             creditDebit.Manual_Amt__c = 20.90;
             creditDebit.Subscription__c = subscription[0].id;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             database.insert(creditDebit);

        
        List<BT_CO_VBS_CreditDebit__c> bt_co_vbs_creditDebitList = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
        for (BT_CO_VBS_CreditDebit__c obj : bt_co_vbs_creditDebitList ) {
        obj.Note_Number__c = 12345;
        obj.Reason_Code__c = 'P';
        obj.Amt_Before_GST__c = 100.00;
        obj.GST_Amount__c = 200.00;
        obj.Publication_Code__c = 'TEST';
        obj.Posting_Date__c = date.today();
        obj.Job_Id__c = 'TEST';
        }
        Database.insert(bt_co_vbs_creditDebitList);
        
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(1);
        for(VDC_CREDITNOTE__c vc : vdc){
        vc.Credit_Note_Number__c = 123;
        vc.Credit_Debit_Indicator__c = 'C';
        }
        Database.insert(vdc);
        
        VDC_CREDITNOTE__c vcred = new VDC_CREDITNOTE__c();
        vcred.Credit_Note_Number__c = 123;
        vcred.Credit_Debit_Indicator__c = 'C';
        vcred.Vendor_Number__c = '12345';
        vcred.Reason_Code_Category__c = 'Credit';
        vcred.Credit_Debit_Indicator__c = 'C';
        Database.insert(vcred);
        
        Manual_Vendor_Credits_Debits__c mvcd = new Manual_Vendor_Credits_Debits__c();
        mvcd.Job_Id__c = 'SP003';
        mvcd.Credit_Debit_Indicator__c = 'C';
        mvcd.Credit_Debit_Vendor_Reason__c = '01';
        mvcd.Amt_After_GST__c =100.00;
        mvcd.Remarks__c = 'Remark';
        mvcd.Vendor__c = acc.id;
        mvcd.Case__c = cas_0.id;
        mvcd.Publication__c = pub.id;
        mvcd.Subscription__c = subscription[0].id;
        Database.insert(mvcd);

        
        Set<Id> vdcId = new Set<Id>();
        for(VDC_CREDITNOTE__c vc : vdc){
        vdcId.add(vdc[0].Id);
        }
        
        List<VDC_CREDITNOTE__c> vdc1 = [SELECT Id, Vendor_Number__c, Job_Id__c, Credit_Note_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c FROM VDC_CREDITNOTE__c WHERE Id IN :vdcId];
       
        String batchCodeParam1 = 'SP002';
        Set<String> vendorNumberSetParam = new Set<String>();
        vendorNumberSetParam.add(vcred.Vendor_Number__c);
        Set<String> reasonCategorySetParam = new Set<String>();
        reasonCategorySetParam.add(vcred.Reason_Code_Category__c);
        Set<String> creditDebitIndicatorSetParam = new Set<String>();
        creditDebitIndicatorSetParam.add(vcred.Credit_Debit_Indicator__c);
        test.startTest();

        SP_PopulateVDCCreditNotes batch = new SP_PopulateVDCCreditNotes(batchCodeParam1, bt_co_vbs_creditDebitList[0].id, date.today(), date.today());
        SP_PopulateVDCCreditNotes.getCreditNotesMap(vendorNumberSetParam,reasonCategorySetParam,creditDebitIndicatorSetParam );
        SP_PopulateVDCCreditNotes.getReasonCodeCategory(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(vcred);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(mvcd);
        database.executeBatch(batch, 200);
               
        Database.BatchableContext BC;
        batch.execute(BC, bt_co_vbs_creditDebitList);
        batch.finish(BC);
        test.stopTest();    
     
       }
       static testmethod void SP_PopulateVDCCreditNotesTestAPRIL01(){
     
     
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
        
             Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
             database.insert(acc);
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             database.insert(billAcc);
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             database.insert(pack);
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today();
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(1);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Term_Length__c = 1;
             subscription[0].Term_Length1__c = '1'; 
             database.insert(subscription);
             
             List<Order__c> orders = TestDataFactory.createOrder(1);
             for(Order__c ord : orders){
             ord.Account__c = acc.id;
             ord.Order_Type__c = 'Renewal'; 
             ord.Base_Subscription__c = subscription[0].id;
             }      
             database.insert(orders);
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = orders[0].id;
             ordLineItem.Subscription__c = subscription[0].id;
             ordLineItem.Main_Package_ID__c = pack.id;
             ordLineItem.Start_Date__c = Date.Today().addDays(2);   
             database.insert(ordLineItem);
             
             System.assertNotEquals(null, subscription[0].id);
             
            
            Case cas_0 = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas_0.Order__c = orders[0].Id;
            insert cas_0; 
             
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            database.insert(pub);

            
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = null;
             creditDebit.Pagination__c = null;
             creditDebit.Insertion__c = null;
             creditDebit.Delivery__c = 20.90;
             creditDebit.Manual_Amt__c = 20.90;
             creditDebit.Subscription__c = subscription[0].id;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             database.insert(creditDebit);

        
        List<BT_CO_VBS_CreditDebit__c> bt_co_vbs_creditDebitList = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
        for (BT_CO_VBS_CreditDebit__c obj : bt_co_vbs_creditDebitList ) {
        obj.Note_Number__c = 12345;
        obj.Reason_Code__c = 'P';
        obj.Amt_Before_GST__c = 100.00;
        obj.GST_Amount__c = 200.00;
        obj.Publication_Code__c = 'TEST';
        obj.Posting_Date__c = date.today();
        obj.Job_Id__c = 'TEST';
        }
        Database.insert(bt_co_vbs_creditDebitList);
        
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(1);
        for(VDC_CREDITNOTE__c vc : vdc){
        vc.Credit_Note_Number__c = 123;
        vc.Credit_Debit_Indicator__c = 'C';
        }
        Database.insert(vdc);
        
        VDC_CREDITNOTE__c vcred = new VDC_CREDITNOTE__c();
        vcred.Credit_Note_Number__c = 123;
        vcred.Credit_Debit_Indicator__c = 'C';
        vcred.Vendor_Number__c = '12345';
        vcred.Reason_Code_Category__c = 'Credit';
        vcred.Credit_Debit_Indicator__c = 'C';
        Database.insert(vcred);
        
        Manual_Vendor_Credits_Debits__c mvcd = new Manual_Vendor_Credits_Debits__c();
        mvcd.Job_Id__c = 'SP003';
        mvcd.Credit_Debit_Indicator__c = 'C';
        mvcd.Credit_Debit_Vendor_Reason__c = '01';
        mvcd.Amt_After_GST__c =100.00;
        mvcd.Remarks__c = 'Remark';
        mvcd.Vendor__c = acc.id;
        mvcd.Case__c = cas_0.id;
        mvcd.Publication__c = pub.id;
        mvcd.Subscription__c = subscription[0].id;
        Database.insert(mvcd);

        
        Set<Id> vdcId = new Set<Id>();
        for(VDC_CREDITNOTE__c vc : vdc){
        vdcId.add(vdc[0].Id);
        }
        
        List<VDC_CREDITNOTE__c> vdc1 = [SELECT Id, Vendor_Number__c, Job_Id__c, Credit_Note_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c FROM VDC_CREDITNOTE__c WHERE Id IN :vdcId];
       
        String batchCodeParam1 = 'SP002';
        Set<String> vendorNumberSetParam = new Set<String>();
        vendorNumberSetParam.add(vcred.Vendor_Number__c);
        Set<String> reasonCategorySetParam = new Set<String>();
        reasonCategorySetParam.add(vcred.Reason_Code_Category__c);
        Set<String> creditDebitIndicatorSetParam = new Set<String>();
        creditDebitIndicatorSetParam.add(vcred.Credit_Debit_Indicator__c);
        test.startTest();

        SP_PopulateVDCCreditNotes batch = new SP_PopulateVDCCreditNotes(batchCodeParam1, bt_co_vbs_creditDebitList[0].id, date.today(), date.today());
        SP_PopulateVDCCreditNotes.getCreditNotesMap(vendorNumberSetParam,reasonCategorySetParam,creditDebitIndicatorSetParam );
        SP_PopulateVDCCreditNotes.getReasonCodeCategory(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(vcred);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(mvcd);
        database.executeBatch(batch, 200);
               
        Database.BatchableContext BC;
        batch.execute(BC, bt_co_vbs_creditDebitList);
        batch.finish(BC);
        test.stopTest();    
     
       }
       static testmethod void SP_PopulateVDCCreditNotesTestAPRIL02(){
     
     
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
        
             Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
             database.insert(acc);
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             database.insert(billAcc);
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             database.insert(pack);
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today();
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(1);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Term_Length__c = 1;
             subscription[0].Term_Length1__c = '1'; 
             database.insert(subscription);
             
             List<Order__c> orders = TestDataFactory.createOrder(1);
             for(Order__c ord : orders){
             ord.Account__c = acc.id;
             ord.Order_Type__c = 'Renewal'; 
             ord.Base_Subscription__c = subscription[0].id;
             }      
             database.insert(orders);
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = orders[0].id;
             ordLineItem.Subscription__c = subscription[0].id;
             ordLineItem.Main_Package_ID__c = pack.id;
             ordLineItem.Start_Date__c = Date.Today().addDays(2);   
             database.insert(ordLineItem);
             
             System.assertNotEquals(null, subscription[0].id);
             
            
            Case cas_0 = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas_0.Order__c = orders[0].Id;
            insert cas_0; 
             
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            database.insert(pub);

            
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = null;
             creditDebit.Pagination__c = null;
             creditDebit.Insertion__c = null;
             creditDebit.Delivery__c = null;
             creditDebit.Manual_Amt__c = 0;
             creditDebit.Subscription__c = null;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             //creditDebit.Manual_VDC_reason_code__c = '01';
             database.insert(creditDebit);

        
        List<BT_CO_VBS_CreditDebit__c> bt_co_vbs_creditDebitList = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
        for (BT_CO_VBS_CreditDebit__c obj : bt_co_vbs_creditDebitList ) {
        obj.Note_Number__c = 12345;
        obj.Reason_Code__c = 'P';
        obj.Amt_Before_GST__c = 100.00;
        obj.GST_Amount__c = 200.00;
        obj.Publication_Code__c = 'TEST';
        obj.Posting_Date__c = date.today();
        obj.Job_Id__c = 'TEST';
        }
        Database.insert(bt_co_vbs_creditDebitList);
        
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(1);
        for(VDC_CREDITNOTE__c vc : vdc){
        vc.Credit_Note_Number__c = 123;
        vc.Credit_Debit_Indicator__c = 'C';
        }
        Database.insert(vdc);
        
        VDC_CREDITNOTE__c vcred = new VDC_CREDITNOTE__c();
        vcred.Credit_Note_Number__c = 123;
        vcred.Credit_Debit_Indicator__c = 'C';
        vcred.Vendor_Number__c = '12345';
        vcred.Reason_Code_Category__c = 'Credit';
        vcred.Credit_Debit_Indicator__c = 'C';
        Database.insert(vcred);
        
        Manual_Vendor_Credits_Debits__c mvcd = new Manual_Vendor_Credits_Debits__c();
        mvcd.Job_Id__c = 'SP003';
        mvcd.Credit_Debit_Indicator__c = 'C';
        mvcd.Credit_Debit_Vendor_Reason__c = '01';
        mvcd.Amt_After_GST__c =100.00;
        mvcd.Remarks__c = 'Remark';
        mvcd.Vendor__c = acc.id;
        mvcd.Case__c = cas_0.id;
        mvcd.Publication__c = pub.id;
        mvcd.Subscription__c = subscription[0].id;
        Database.insert(mvcd);

        
        Set<Id> vdcId = new Set<Id>();
        for(VDC_CREDITNOTE__c vc : vdc){
        vdcId.add(vdc[0].Id);
        }
        
        List<VDC_CREDITNOTE__c> vdc1 = [SELECT Id, Vendor_Number__c, Job_Id__c, Credit_Note_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c FROM VDC_CREDITNOTE__c WHERE Id IN :vdcId];
       
        String batchCodeParam1 = 'SP002';
        Set<String> vendorNumberSetParam = new Set<String>();
        vendorNumberSetParam.add(vcred.Vendor_Number__c);
        Set<String> reasonCategorySetParam = new Set<String>();
        reasonCategorySetParam.add(vcred.Reason_Code_Category__c);
        Set<String> creditDebitIndicatorSetParam = new Set<String>();
        creditDebitIndicatorSetParam.add(vcred.Credit_Debit_Indicator__c);
        test.startTest();

        SP_PopulateVDCCreditNotes batch = new SP_PopulateVDCCreditNotes(batchCodeParam1, bt_co_vbs_creditDebitList[0].id, date.today(), date.today());
        SP_PopulateVDCCreditNotes.getCreditNotesMap(vendorNumberSetParam,reasonCategorySetParam,creditDebitIndicatorSetParam );
        SP_PopulateVDCCreditNotes.getReasonCodeCategory(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(vcred);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(mvcd);
        database.executeBatch(batch, 200);
               
        Database.BatchableContext BC;
        batch.execute(BC, bt_co_vbs_creditDebitList);
        batch.finish(BC);
        test.stopTest();    
     
       }
       static testmethod void SP_PopulateVDCCreditNotesTestAPRIL03(){
     
     
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
        
             Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
             database.insert(acc);
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             database.insert(billAcc);
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             database.insert(pack);
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today();
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(1);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Term_Length__c = 1;
             subscription[0].Term_Length1__c = '1'; 
             database.insert(subscription);
             
             List<Order__c> orders = TestDataFactory.createOrder(1);
             for(Order__c ord : orders){
             ord.Account__c = acc.id;
             ord.Order_Type__c = 'Renewal'; 
             ord.Base_Subscription__c = subscription[0].id;
             }      
             database.insert(orders);
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = orders[0].id;
             ordLineItem.Subscription__c = subscription[0].id;
             ordLineItem.Main_Package_ID__c = pack.id;
             ordLineItem.Start_Date__c = Date.Today().addDays(2);   
             database.insert(ordLineItem);
             
             System.assertNotEquals(null, subscription[0].id);
             
            
            Case cas_0 = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas_0.Order__c = orders[0].Id;
            insert cas_0; 
             
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            database.insert(pub);

            
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = null;
             creditDebit.Pagination__c = null;
             creditDebit.Insertion__c = null;
             creditDebit.Delivery__c = null;
             creditDebit.Manual_Amt__c = 1.00;
             creditDebit.Subscription__c = subscription[0].id;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             creditDebit.Manual_VDC_reason_code__c = '01';
             database.insert(creditDebit);

        
        List<BT_CO_VBS_CreditDebit__c> bt_co_vbs_creditDebitList = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
        for (BT_CO_VBS_CreditDebit__c obj : bt_co_vbs_creditDebitList ) {
        obj.Note_Number__c = 12345;
        obj.Reason_Code__c = 'P';
        obj.Amt_Before_GST__c = 100.00;
        obj.GST_Amount__c = 200.00;
        obj.Publication_Code__c = 'TEST';
        obj.Posting_Date__c = date.today();
        obj.Job_Id__c = 'TEST';
        }
        Database.insert(bt_co_vbs_creditDebitList);
        
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(1);
        for(VDC_CREDITNOTE__c vc : vdc){
        vc.Credit_Note_Number__c = 123;
        vc.Credit_Debit_Indicator__c = 'C';
        }
        Database.insert(vdc);
        
        VDC_CREDITNOTE__c vcred = new VDC_CREDITNOTE__c();
        vcred.Credit_Note_Number__c = 123;
        vcred.Credit_Debit_Indicator__c = 'C';
        vcred.Vendor_Number__c = '12345';
        vcred.Reason_Code_Category__c = 'Credit';
        vcred.Credit_Debit_Indicator__c = 'C';
        Database.insert(vcred);
        
        Manual_Vendor_Credits_Debits__c mvcd = new Manual_Vendor_Credits_Debits__c();
        mvcd.Job_Id__c = 'SP003';
        mvcd.Credit_Debit_Indicator__c = 'C';
        mvcd.Credit_Debit_Vendor_Reason__c = '01';
        mvcd.Amt_After_GST__c =100.00;
        mvcd.Remarks__c = 'Remark';
        mvcd.Vendor__c = acc.id;
        mvcd.Case__c = cas_0.id;
        mvcd.Publication__c = pub.id;
        mvcd.Subscription__c = subscription[0].id;
        Database.insert(mvcd);

        
        Set<Id> vdcId = new Set<Id>();
        for(VDC_CREDITNOTE__c vc : vdc){
        vdcId.add(vdc[0].Id);
        }
        
        List<VDC_CREDITNOTE__c> vdc1 = [SELECT Id, Vendor_Number__c, Job_Id__c, Credit_Note_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c FROM VDC_CREDITNOTE__c WHERE Id IN :vdcId];
       
        String batchCodeParam1 = 'SP002';
        Set<String> vendorNumberSetParam = new Set<String>();
        vendorNumberSetParam.add(vcred.Vendor_Number__c);
        Set<String> reasonCategorySetParam = new Set<String>();
        reasonCategorySetParam.add(vcred.Reason_Code_Category__c);
        Set<String> creditDebitIndicatorSetParam = new Set<String>();
        creditDebitIndicatorSetParam.add(vcred.Credit_Debit_Indicator__c);
        test.startTest();

        SP_PopulateVDCCreditNotes batch = new SP_PopulateVDCCreditNotes(batchCodeParam1, bt_co_vbs_creditDebitList[0].id, date.today(), date.today());
        SP_PopulateVDCCreditNotes.getCreditNotesMap(vendorNumberSetParam,reasonCategorySetParam,creditDebitIndicatorSetParam );
        SP_PopulateVDCCreditNotes.getReasonCodeCategory(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(creditDebit);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(vcred);
        SP_PopulateVDCCreditNotes.constructCreditNoteKey(mvcd);
        database.executeBatch(batch, 200);
               
        Database.BatchableContext BC;
        batch.execute(BC, bt_co_vbs_creditDebitList);
        batch.finish(BC);
        test.stopTest();    
     
       }
}