@isTest
public class SP_DailySetSubActiveFlagTest{

    static testmethod void unitTest(){
    
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
        //List<Contact> contacts = TestDataFactory.createContactRecType(1, 'Billing Contact');
        /*for(Contact con: contacts){
            con.Recipient_Indicator__c = true;
        }
        insert contacts;*/
        
        List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        insert keyy;
        
        Contact cont = new Contact();
        cont.LastName = 'Sample Last';
        cont.Recipient_Indicator__c = true;
        cont.Mobile_Number__c = '123456'; 
        insert cont;
        
        /*List<Zuora__Subscription__c> subscriptions = TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c subs: subscriptions){
            subs.Zuora__SubscriptionStartDate__c = Date.today().addDays(30);
            subs.Zuora__SubscriptionEndDate__c = null;
            subs.Recipient_Contact__c = cont.id;
        }
        insert subscriptions;*/
        
        //create Account Records
        List<Account> accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;      
        
        //create Billing Account Records
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;   
       
        //create Main Package Records
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;
        
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
                //Zuora__Subscription__c Subs = new Zuora__Subscription__c();
                zuoSubList[0].Zuora__Account__c = accList[0].id;
                zuoSubList[0].Name= 'CS0000000110';
                zuoSubList[0].Number_of_Copies__c= 10;
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Next_Earliest_Start_Date__c= date.today();
                zuoSubList[0].Unique_Address_Id__c= 'asdasdasd';
                zuoSubList[0].Year_to_Date_Temp_Stop_Days__c= 2;
                zuoSubList[0].Previous_Year_Temp_Stop_Days__c= 2;
                zuoSubList[0].Legacy_Create_Date__c='2014-08-07';
                zuoSubList[0].Legacy_Create_By__c='test';
                zuoSubList[0].Legacy_Update_Date__c='test';
                zuoSubList[0].Legacy_Update_By__c='test';
                zuoSubList[0].Legacy_Subscription_ID__c='test';
                zuoSubList[0].Cheque_details__c='test';
                zuoSubList[0].DTL__c='test';
                zuoSubList[0].Paypal_Payment_Profile_Id__c='test';
                zuoSubList[0].Pub_Tag__c='test';
                zuoSubList[0].Subscribe_As__c='test';
                zuoSubList[0].Zuora__SubscriptionEndDate__c= null;
                zuoSubList[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(30);
                zuoSubList[0].Subscription_Grace_Period_End_Date__c= 'test';
                zuoSubList[0].Gift_ID__c= 'test';
                zuoSubList[0].Redeem_Date__c= 'test';
                zuoSubList[0].Gift_ID_2__c= 'test';
                zuoSubList[0].Redeem_Date_2__c= 'test';
                zuoSubList[0].Subscriber_Contact__c= cont.Id;
                zuoSubList[0].Recipient_Contact__c= cont.Id;
                zuoSubList[0].Subscription_Charge__c= 223.0;
                zuoSubList[0].Term_Length__c= 2;
                zuoSubList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                zuoSubList[0].Main_Package__c = packageList[0].Id;
                zuoSubList[0].Main_Package_1__c = packageList[0].Id;
                zuoSubList[0].Billing_Type__c = 'Recurring Prepaid';
                zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
                //zSubs.add(Subs);
                insert zuoSubList;
        
        Set<Id> selectiveIds = new Set<Id>();
        selectiveIds.add(cont.Id);
                
        SP_DailySetSubActiveFlag batch1 = new SP_DailySetSubActiveFlag(selectiveIds, Date.today().addDays(30));
        SP_DailySetSubActiveFlag batch2 = new SP_DailySetSubActiveFlag();
        SP_DailySetSubActiveFlag batch = new SP_DailySetSubActiveFlag(Date.today().addDays(30));
        ID batchProcessId = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchProcessId);
    }
    
    static testmethod void unitTest2(){
    
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
        //List<Contact> contacts = TestDataFactory.createContactRecType(1, 'Billing Contact');
        /*for(Contact con: contacts){
            con.Recipient_Indicator__c = true;
        }
        insert contacts;*/
        
        List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        insert keyy;
        
        Contact cont = new Contact();
        cont.LastName = 'Sample Last';
        cont.Recipient_Indicator__c = true;
        cont.Mobile_Number__c = '123456'; 
        insert cont;
        
        /*List<Zuora__Subscription__c> subscriptions = TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c subs: subscriptions){
            subs.Zuora__SubscriptionStartDate__c = Date.today().addDays(30);
            subs.Zuora__SubscriptionEndDate__c = null;
            subs.Recipient_Contact__c = cont.id;
        }
        insert subscriptions;*/
        
        //create Account Records
        List<Account> accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;      
        
        //create Billing Account Records
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;   
       
        //create Main Package Records
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;
        
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
                //Zuora__Subscription__c Subs = new Zuora__Subscription__c();
                zuoSubList[0].Zuora__Account__c = accList[0].id;
                zuoSubList[0].Name= 'CS0000000110';
                zuoSubList[0].Number_of_Copies__c= 10;
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Next_Earliest_Start_Date__c= date.today();
                zuoSubList[0].Unique_Address_Id__c= 'asdasdasd';
                zuoSubList[0].Year_to_Date_Temp_Stop_Days__c= 2;
                zuoSubList[0].Previous_Year_Temp_Stop_Days__c= 2;
                zuoSubList[0].Legacy_Create_Date__c='2014-08-07';
                zuoSubList[0].Legacy_Create_By__c='test';
                zuoSubList[0].Legacy_Update_Date__c='test';
                zuoSubList[0].Legacy_Update_By__c='test';
                zuoSubList[0].Legacy_Subscription_ID__c='test';
                zuoSubList[0].Cheque_details__c='test';
                zuoSubList[0].DTL__c='test';
                zuoSubList[0].Paypal_Payment_Profile_Id__c='test';
                zuoSubList[0].Pub_Tag__c='test';
                zuoSubList[0].Subscribe_As__c='test';
                zuoSubList[0].Zuora__SubscriptionEndDate__c= Date.today().addDays(-1);
                zuoSubList[0].Zuora__SubscriptionStartDate__c = Date.today();
                zuoSubList[0].Subscription_Grace_Period_End_Date__c= 'test';
                zuoSubList[0].Gift_ID__c= 'test';
                zuoSubList[0].Redeem_Date__c= 'test';
                zuoSubList[0].Gift_ID_2__c= 'test';
                zuoSubList[0].Redeem_Date_2__c= 'test';
                zuoSubList[0].Subscriber_Contact__c= cont.Id;
                zuoSubList[0].Recipient_Contact__c= cont.Id;
                zuoSubList[0].Recipient_Contact_1__c = cont.Id;
                zuoSubList[0].Subscription_Charge__c= 223.0;
                zuoSubList[0].Term_Length__c= 2;
                zuoSubList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                zuoSubList[0].Main_Package__c = packageList[0].Id;
                zuoSubList[0].Main_Package_1__c = packageList[0].Id;
                zuoSubList[0].Billing_Type__c = 'Recurring Prepaid';
                zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
                //zSubs.add(Subs);
                insert zuoSubList;
        
        Set<Id> selectiveIds = new Set<Id>();
        selectiveIds.add(cont.Id);
                
        SP_DailySetSubActiveFlag batch1 = new SP_DailySetSubActiveFlag(selectiveIds, Date.today());
        SP_DailySetSubActiveFlag batch2 = new SP_DailySetSubActiveFlag();
        SP_DailySetSubActiveFlag batch = new SP_DailySetSubActiveFlag(Date.today());
        ID batchProcessId = Database.executeBatch(batch1, 200);
        System.assertNotEquals(null, batchProcessId);
    }
}