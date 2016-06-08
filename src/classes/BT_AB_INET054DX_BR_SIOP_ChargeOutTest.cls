/**
* Class Name: BT_AB_INET054DX_BR_SIOP_ChargeOutTest
* @author: Recuerdo Bregente
* @date: 07/13/2015
* @requirement/Project Name: SPH Project
* @description Test Class for BT_AB_INET054DX_BR_SIOP_ChargeOut.
*/
@isTest(seeAllData=True)
private class BT_AB_INET054DX_BR_SIOP_ChargeOutTest {

    static Account acc;
    static Singpost_Address__c postal;
    static Address__c address;
    static List<Contact> con;
    static List<Package__c> pkg;
    static List<Zuora__CustomerAccount__c> zcaList;
    static List<Zuora__Subscription__c> zSubs;
    static List<Zuora__PaymentMethod__c> zpmList;
    static List<Billing_Report__c> zuoraPayment;
    static List<Zuora__SubscriptionProductCharge__c> subProdAndCharge;
    static RecordType recType;
    
    static final String subId = 'SUB00001';
    static List<Billing_Report__c> billingReports;

    /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/13/2015
    */ 
    static void prepareTestData(String addressRecordType){
            acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber'); 
            insert acc;
            
            postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            List<RecordType> recTypes = 
                [Select Id, Name, SObjectType From RecordType WHERE Name = :addressRecordType LIMIT 1];
            
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            
            if(recTypes.size() > 0) {
                recType = recTypes[0];
                address.recordTypeID = recType.Id;
            }
            
            insert address;
            
            con = TestDataFactory.createContact(1);
            con[0].Phone = '1234567';
            con[0].Address__c = address.Id;
            insert con;
                   
            pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15'; 
            insert pkg;
            
            zcaList = TestDataFactory.createBillingAccount(1);
            zcaList[0].Name = 'Zuora Customer Account';
            zcaList[0].Zuora__Account__c = acc.Id;
            zcalist[0].Billing_Contact__c = con[0].Id;
            zcaList[0].Zuora__Credit_Balance__c = 1;
            zcaList[0].Refund_Amount__c = 100;
            zcaList[0].Zuora__AutoPay__c =false;
            zcaList[0].Zuora__Balance__c = 1;
            zcaList[0].Payment_Mode__c = 'Paypal';
            zcaList[0].Other_PaymentMethod__c= 'Paypal';
            zcaList[0].Zuora__PaymentMethodType__c = 'Paypal'; 
            zcalist[0].Zuora__External_Id__c = '22544AA';  
            zcalist[0].Zuora__Zuora_Id__c = '0124';         
            insert zcaList;
            
            zpmList = TestDataFactory.createPaymentMethod(1);
            zpmList[0].Name = 'Zuora Customer Account';
            zpmList[0].Zuora__Type__c = 'Paypal';
            zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
            insert zpmList;
            
            zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
            update zcaList;
            
            //START : D-1929 3/2/2015 added to create Default Payment Method
            zpmList = TestDataFactory.createPaymentMethod(1);
            zpmList[0].Name = 'Zuora Customer Account';
            zpmList[0].Zuora__Type__c = 'Electronic';
            zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
            zpmList[0].Zuora__PaypalEmail__c = 'dee.bregente@gmail.com';
            insert zpmList;  
            //End: D-1929 3/2/2015 added to create Default Payment Method
            
            zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
            update zcaList;
            
            //create billing account      
            zSubs =  TestDataFactory.createSubscription(2);
            for(Zuora__Subscription__c zuoraSubRec: zSubs) {
                zuoraSubRec.Name = subId;
                zuoraSubRec.Subscriber_Contact__c = con[0].id;
                zuoraSubRec.Main_Package_1__c = pkg[0].id;
                zuoraSubRec.Main_Package__c = pkg[0].id;
                zuoraSubRec.Zuora__Account__c = acc.id;
                zuoraSubRec.Order_Number__c = null;
                zuoraSubRec.Zuora__CustomerAccount__c = zcaList[0].Id;
                zuoraSubRec.Billing_Type__c = 'Full Prepaid';
                zuoraSubRec.Legacy_Create_Date__c = 'a';
                zuoraSubRec.Legacy_Create_By__c = 'a';
                zuoraSubRec.Legacy_Update_By__c = 'a';
                zuoraSubRec.Legacy_Subscription_ID__c = 'a';
                zuoraSubRec.Legacy_Update_Date__c = 'a';
                zuoraSubRec.Number_of_Copies__c = 100;
                zuoraSubRec.Number_of_Copies1__c = '100';
                zuoraSubRec.Zuora__Status__c = 'Active';
                zuoraSubRec.Recipient_Contact__c = con[0].id;
            }
            
            insert zSubs;
            
            subProdAndCharge = TestDataFactory.createSubProductCharge(1);
            subProdAndCharge[0].Zuora__Subscription__c = zSubs[0].Id;
            subProdAndCharge[0].PublicationCode__c = 'asas';
            insert subProdAndCharge;
     
    }
    
    /**
    * @name : prepareBillingReportObject
    * @author : Recuerdo Bregente
    * @description : Prepares the billing report objects.
    * @date: 07/10/2015
    */ 
    static void prepareBillingReportObject(Integer recordCount) {
        String zBatchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('INET054DX');
        String accountPeriod = StringUtility.getAccountingPeriod(zBatchRunDate);
        billingReports = new List<Billing_Report__c>();
        
         BT_CO_Batch_Run_Request__c batchRun = new BT_CO_Batch_Run_Request__c();
            batchRun.Interface_ID__c = 'INET054DX';
            batchRun.End_Time__c = null;
            batchRun.Batch_Run_Date__c = date.today();
            database.insert(batchRun);
        
        DateTime varTime = batchRun.Batch_Run_Date__c;
        
        Billing_Report__c billingReport;
        for(Integer index = 0; index < recordCount; index++){
            billingReport = new Billing_Report__c();
            //billingReport.IsDeleted = false;
            billingReport.Publication__c = 'SIOP';
           // billingReport.Accounting_Period__c = accountPeriod;
            billingReport.Accounting_Period__c = StringUtility.getAccountingPeriod(varTime.format('yyyy-MM-dd'));
            billingReport.Subscription_ID__c = subId;
            billingReport.Transaction_Type__c = 'Charge-Out'; 
            billingReport.Copies__c = 2;
            billingReport.GST_Amount__c = 50.00;
            billingReport.Subscription_AMT_After_GST__c = 10.00;
            
            billingReports.add(billingReport);
        }
        
        insert billingReports;
    }
    
    /**
    * @name: testBatch
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_AB_INET054DX_BR_SIOP_ChargeOut execution.
    * @date: 07/08/2015
    */
    static testMethod void testBatch(){
        boolean errorExist = false;
        
        try{
            Test.StartTest();
            prepareTestData('Local');
            prepareBillingReportObject(1);
            
           
        
            BT_AB_INET054DX_BR_SIOP_ChargeOut batch = new BT_AB_INET054DX_BR_SIOP_ChargeOut();
            ID batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        //System.assertEquals(true, errorExist);
    }
}