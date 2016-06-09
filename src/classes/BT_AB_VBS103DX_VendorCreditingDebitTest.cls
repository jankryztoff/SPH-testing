/**
Class Name: BT_AB_VBS103DX_VendorCreditingDebitTest
@author: Accenture IDC (Sudha Kumari)
Date: 02/11/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_VBS103DX_VendorCreditingDebiting

Additional for code coverage : Joyrem Zarmaine D. Ayuman
**/
@isTest (Seealldata = true)
private class BT_AB_VBS103DX_VendorCreditingDebitTest {

    static testmethod void unitTest1(){
        /*
        BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;
        */
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
        
        /*List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        for (BA_INT_DATA_POOL__c dpl : datapoolList ){
            dpl.Name = 'Test';
            dpl.job_id__c = '1';
            dpl.group_id__c = 'Detail';
            dpl.run_for_date__c = Date.today();      
            dpl.insert_time__c = DateTime.now(); 
            dpl.export_data__c = 'TESTtest'; 
        }
        Database.insert(datapoolList);*/
        
        test.starttest();
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,10);        
        test.stoptest();
    }//end of unitTest1

    static testmethod void unitTest2(){
        /**BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;**/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'commission';
        insert vmd;
 
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        for (BA_INT_DATA_POOL__c dpl : datapoolList ){
            dpl.Name = 'Test';
            dpl.job_id__c = '1';
            dpl.group_id__c = 'Detail';
            dpl.run_for_date__c = Date.today();      
            dpl.insert_time__c = DateTime.now(); 
            dpl.export_data__c = 'TESTtest'; 
        }
        Database.insert(datapoolList);
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
    }
    static testmethod void unitTest3(){
        /**BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;**/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'pagination';
        insert vmd;
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
    }
    static testmethod void unitTest4(){
        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'pagination';
        insert vmd;
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
    }
    static testmethod void unitTest5(){
        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'delivery rate';
        insert vmd;
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
    }
    static testmethod void unitTest6(){
        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'insertion';
        insert vmd;
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
    }
    static testmethod void unitTest7(){
        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'delivery fee';
        insert vmd;
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
    }
    static testmethod void unitTest8(){
        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'miscellaneous';
        insert vmd;
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
    }
    static testmethod void unitTest9(){
        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'handling fee';
        insert vmd;
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
    }
    static testmethod void unitTest10(){
        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Amount_Type__c = 'sssss';
        insert vmd;
        test.starttest();    
        BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
        database.executeBatch(vcd,200);        
        test.stoptest();
        }
     static testmethod void unitTest11(){
     
          List<BT_CO_VBS_CreditDebit__c> vbs = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
              for ( BT_CO_VBS_CreditDebit__c creditdebit : vbs){
                  creditdebit.Credit_Debit__c = 'C';
                  creditdebit.Vendor_Group__c = 'E';
                  creditdebit.Vendor_Number__c = 'test';
                  creditdebit.Note_Number__c = 100;
                  creditdebit.Reason_Code__c = 'P';
                  creditdebit.Amt_Before_GST__c = 100.00;
                  creditdebit.GST_Amount__c = 200.00;
                  creditdebit.Publication_Code__c = 'TEST';
                  creditdebit.Posting_Date__c = date.today();
                  creditdebit.Job_Id__c = 'TEST';
                  //creditdebit.IsDeleted = FALSE;
              }
          insert vbs;
          
          test.starttest();
          BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
             
             Database.BatchableContext BC;
             vcd.start(BC);
             vcd.execute(BC,vbs);
             vcd.finish(BC);
         test.stoptest();
     }
     
     static testmethod void unitTest12(){
     
          List<BT_CO_VBS_CreditDebit__c> vbs = TestDataFactory.createBT_CO_VBS_CreditDebit(1);
              for ( BT_CO_VBS_CreditDebit__c creditdebit : vbs){
                  creditdebit.Credit_Debit__c = 'C';
                  creditdebit.Vendor_Group__c = 'E';
                  creditdebit.Vendor_Number__c = 'test';
                  creditdebit.Note_Number__c = 100;
                  creditdebit.Reason_Code__c = 'P';
                  creditdebit.Amt_Before_GST__c = 100.00;
                  creditdebit.GST_Amount__c = 200.00;
                  creditdebit.Publication_Code__c = 'TEST';
                  creditdebit.Posting_Date__c = date.today();
                  creditdebit.Job_Id__c = 'TEST';
              }
          insert vbs;
          
          BT_CO_Batch_Run_Request__c brc = new BT_CO_Batch_Run_Request__c();
          brc.Interface_ID__c  = 'VBS103DX';
          brc.End_Time__c = null;
          brc.Batch_Run_Date__c = date.today()+24;
          insert brc;
          
         test.starttest();    
            BT_AB_VBS103DX_VendorCreditingDebiting vcd = new BT_AB_VBS103DX_VendorCreditingDebiting();
            database.executeBatch(vcd,200);        
         test.stoptest();
                 
     }
}