@isTest(seealldata=true)
public class BatchPostageMonthlyUsageSchedTest{
    public static list<Zuora__Subscription__c> listsubscriptionRec = TestDataFactory.createSubscription(10);
    public static list<Zuora__Subscription__c> listsubscriptionRecForUpdate = new List<Zuora__Subscription__c>();
    static testmethod void test() {
        //Create Testing Data
        String ACC_RT_DI = (String) ConstantsSLB.getKeyId('Account_Direct Individual');
        String CON_RT_CUS = (String) ConstantsSLB.getKeyId('Contact_Customer Contact');
        //Create SFDC Account
        Account acc = new Account(Name = 'Test Account', RecordTypeId = ACC_RT_DI );
        insert acc;
        //Create Billing Accounts
        String defaultBatchNumber = 'Batch'+ConstantsSLB.getBillingBatch('Default');
        List<Zuora__CustomerAccount__c> lstBillingAccounts = new List<Zuora__CustomerAccount__c>();
        Zuora__CustomerAccount__c billAct1 = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Billing Account 1', Zuora__Zuora_Id__c='12345', 
                                                                     Zuora__DefaultPaymentMethod__c='CreditCard', Other_PaymentMethod__c='', Zuora__Batch__c = defaultBatchNumber);
        Zuora__CustomerAccount__c billAct2 = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Billing Account 2', Zuora__Zuora_Id__c='12346',
                                                                     Zuora__DefaultPaymentMethod__c='CreditCard', Other_PaymentMethod__c='', Zuora__Batch__c = defaultBatchNumber);
        Zuora__CustomerAccount__c billAct3 = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Billing Account 3', Zuora__Zuora_Id__c='12347',
                                                                     Zuora__DefaultPaymentMethod__c='Cash', Other_PaymentMethod__c='', Zuora__Batch__c = defaultBatchNumber);
        Zuora__CustomerAccount__c billAct4 = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Billing Account 4', Zuora__Zuora_Id__c='12348',
                                                                     Zuora__DefaultPaymentMethod__c='Other', Other_PaymentMethod__c='Invoice', Zuora__Batch__c = defaultBatchNumber);
        Zuora__CustomerAccount__c billAct5 = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Billing Account 5', Zuora__Zuora_Id__c='12349',
                                                                     Zuora__DefaultPaymentMethod__c='Other', Other_PaymentMethod__c='Paypal', Zuora__Batch__c = defaultBatchNumber);
         lstBillingAccounts.add(billAct1); 
         lstBillingAccounts.add(billAct2); 
         lstBillingAccounts.add(billAct3); 
         lstBillingAccounts.add(billAct4); 
         lstBillingAccounts.add(billAct5); 
         insert lstBillingAccounts;
         system.assertequals(5,lstBillingAccounts.size());
         //Create a Contact
         Contact contactRecord = new Contact(FirstName='First',LastName='Last',Salutation='MR.',RecordtypeId=CON_RT_CUS,AccountId=acc.ID,
                                                Email='test@email.com',Phone='22222',Billing_Indicator__c=true,Recipient_Indicator__c=true);
         insert contactRecord;
         system.assertequals('First',contactRecord.FirstName);
         //Create a Package
         Package__c packageRecord = new Package__c(Name='Test Package', Package_Type__c='Base',Subscription_Type__c='Termed', Package_Code__c='PackageCode',
                                                      Effective_Start_Date__c=date.today(), Effective_End_Date__c=date.today()+100, Subscription_Period__c='18');
         insert packageRecord; 
         system.assertequals('Test Package',packageRecord.Name);
         List<Zuora__Subscription__c> listSub = new List<Zuora__Subscription__c>(); 
         listSub.add(new Zuora__Subscription__c(Name='Test Subscription 1',Zuora__Account__c=acc.id, Zuora__CustomerAccount__c = billAct1.ID,Zuora__Zuora_Id__c='12345',
                                                   Next_Earliest_Start_Date__c = date.today()+30, Subscription_Charge__c=30.00,Billing_Type__c='Recurring Prepaid',
                                                   Subscriber_Contact__c=contactRecord.ID,Recipient_Contact__c=contactRecord.ID,Main_Package_1__c=packageRecord.ID,
                                                   Unique_Address_Id__c='UAID00000',Year_to_Date_Temp_Stop_Days__c=5,Previous_Year_Temp_Stop_Days__c=5,
                                                   Parent_Transaction_ID__c='IDxxxx',Delivery_Charge__c=200.00, Vendor_Credit_1__c=20000.00, 
                                                   Term_Length__c=10, Number_of_Copies__c=3, Zuora__SubscriptionEndDate__c=date.today()+100,Gift_ID__c='xxx',
                                                   Gift_ID_2__c='ID XX',Redeem_Date__c='10/24/2014',Redeem_Date_2__c='10/24/2014',
                                                   Sponsored_Indicator__c='N',Subscribe_As__c='ACN',Subscription_Grace_Period_End_Date__c='10/24/2014',
                                                   Zuora__SubscriptionStartDate__c=date.today(),Cheque_details__c='Cheque',DTL__c='xxx',Pub_Tag__c='Tag',
                                                   Legacy_Create_By__c='User', Legacy_Create_Date__c='10/24/2014',Paypal_Payment_Profile_Id__c='ID123',
                                                   Legacy_Subscription_ID__c='LSUB00000', Legacy_Update_By__c='User',Legacy_Update_Date__c='10/24/2014'));
        insert listSub;    
        // modify records to meet the batch query                                       
        for(Zuora__Subscription__c zuoraSubRec : listSub){
            zuoraSubRec.Billing_Type__c ='Recurring Prepaid';
            zuoraSubRec.Subscription_Type_1__c ='Postage';
            zuoraSubRec.Zuora__Status__c ='Active';
            listsubscriptionRecForUpdate.add(zuoraSubRec);
        }
        if(!listsubscriptionRecForUpdate.isEmpty()){
            update listsubscriptionRecForUpdate;    
        }
        Test.startTest();
        System.schedule('BatchPostageMonthlyUsageScheduler Test', '0 58 * * * ?', new BatchPostageMonthlyUsageScheduler());
        Test.stopTest(); 
        }
}