@isTest
public class BT_AB_ARM067DX_ImportCirculationTest {

    static testmethod void testBT_AB_ARM067DX_ImportCirculation()
    {
        /*Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
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
        
        List<BT_CO_Batch_Run_Request__c> brrList = [SELECT Id, Batch_Run_Date__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = 'HDS036DX' AND End_Time__c = null ORDER BY CreatedDate DESC];
        DateTime batchRun;
        
        for (BT_CO_Batch_Run_Request__c brrRecord: brrList)
        {
            batchRun = brrRecord.Batch_Run_Date__c;
            break;
        }
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Case caseRec = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        caseRec.Credit_Note_Reason_Code__c = 'S1';
        caseRec.Pub_Type__c = 'NP';
        caseRec.AccountId = acc.id; 
        database.insert(caseRec);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        List<Credit_Note__c> CredNotelist = new List<Credit_Note__c>();
        Credit_Note__c crednote = new Credit_Note__c();
        //crednote.Net_Amount_After_GST__c = '100';
        crednote.Billing_Account__c = billAcc.id;
        //crednote.Related_Case__c = caseRec.id;
        CredNotelist.add(crednote);
        database.insert(CredNotelist);
        
         test.startTest();
         
            BT_AB_ARM067DX_ImportCirculationOrders batch = new BT_AB_ARM067DX_ImportCirculationOrders();
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            batch.execute(BC, CredNotelist);
        test.stopTest();  
        */
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        insert acc;
        System.assertEquals(acc.Vendor_Code__c, '01');
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.ARMS_Account_Number__c = 'Test01';
        insert billAcc;
        System.assertEquals(billAcc.Zuora__Account__c, acc.Id);
        
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
        invoice.Name = '1000001';
        invoice.Zuora__Zuora_Id__c ='10002';
        invoice.Immediate_CB__c = 'N';
        insert invoice;
        System.assertEquals(invoice.Immediate_CB__c, 'N');
        
        Credit_Note__c crednote = new Credit_Note__c();
        crednote.Credit_Note_Number__c = '26000001';
        crednote.Billing_Account__c = billAcc.id;
        crednote.Document_Date__c = date.today(); 
        crednote.Tax_Rate__c = 10;
        crednote.Source_Invoice__c = invoice.Id;
        insert crednote;
        System.assertEquals(crednote.Billing_Account__c, billAcc.id);
        
        List<Credit_Note__c> CredNotelist = new List<Credit_Note__c>();
        CredNotelist.add(crednote);
        
        Credit_Note_Item__c cni = new Credit_Note_Item__c();
        cni.Credit_Note__c = crednote.Id;
        cni.Amt_After_Tax__c = 3.74;
        cni.Amt_Before_Tax__c = 2.12;
        cni.Tax_Amt__c = 0.26;
        cni.Tax_Exempt_Amt__c = 0.0;
        insert cni;
        System.assertEquals(cni.Credit_Note__c, crednote.Id);
        
        Other__c other = new Other__c();
        other.Name='CN_NUMBER_MIN';
        other.Value__c = '26000000';
        insert other;
        
        Other__c other1 = new Other__c();
        other1.Name='CN_NUMBER_MAX';
        other1.Value__c = '26999999';
        insert other1;
        
        List<BatchInterface_Settings__c> bisList = new List<BatchInterface_Settings__c>();
        BatchInterface_Settings__c bis1 = new BatchInterface_Settings__c();
        bis1.Name = 'ApplicationJSON';
        bis1.Value__c='application/json';
        insert bis1;
        bisList.add(bis1);
        BatchInterface_Settings__c bis2 = new BatchInterface_Settings__c();
        bis2.Name = 'Content-Type';
        bis2.Value__c='ContentType';
        insert bis2;
        bisList.add(bis2);
        BatchInterface_Settings__c bis3 = new BatchInterface_Settings__c();
        bis3.Name = 'Endpoint Delegator';
        bis3.Value__c='http://tstcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis3;
        bisList.add(bis3);
        BatchInterface_Settings__c bis4 = new BatchInterface_Settings__c();
        bis4.Name = 'PostMethod';
        bis4.Value__c='POST';
        insert bis4;
        bisList.add(bis4);
        
        
     
        Test.StartTest();
            BT_AB_ARM067DX_ImportCirculationOrders batch = new BT_AB_ARM067DX_ImportCirculationOrders();
            database.executeBatch(batch, 20);
               
            Database.BatchableContext BC;
            batch.execute(BC, CredNotelist);
        Test.StopTest();
        
    }
    
}