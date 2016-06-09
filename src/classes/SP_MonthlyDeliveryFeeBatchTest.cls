/**
 * Class Name: <SP_MonthlyDeliveryFeeBatchTest>
 * @author: <Joyrem Zarmaine D. Ayuman>
 * Requirement/Project Name: <SPH>

 * @description<Test Class for SP_MonthlyDeliveryFeeBatch>


 */

@isTest (Seealldata = False)
public class SP_MonthlyDeliveryFeeBatchTest {
  
          
    static testMethod void testSP_MonthlyDeliveryFeeBatch(){
        
        Date monthStart = Date.today().toStartOfMonth();
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date monthEnd = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl; 
    
        //List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        //insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
         
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        insert conList;
        
               
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        //billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc.Zuora__Credit_Balance__c = 1;
        insert billAcc;
        
        
        
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
        zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = monthStart;
        //zuoSubList[0].Zuora__SubscriptionEndDate__c = null;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+100; // joy
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        //zuoSubList[0].Order_Number_1__c = orderRec.id; //joy
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        insert zuoSubList;
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = accList[0].Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        orderRec.Base_Subscription__c = zuoSubList[0].id; // joy
        insert orderRec;
        
       /* Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        //orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.Start_Date__c = date.today();
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = packageList[0].Id;
        orderline.Main_Package_Billing_Type__c = 'Recurring Prepaid';
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        insert orderline;*/
         
        Test.startTest();
        SP_MonthlyDeliveryFeeBatch batch = new SP_MonthlyDeliveryFeeBatch();
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
     }
        
     static testMethod void testSP_MonthlyDeliveryFeeBatch01(){
        
        Date monthStart = Date.today().toStartOfMonth();
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date monthEnd = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        //List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        //insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        accList[0].Vendor_Group__c = '1';
        accList[0].Vendor_Code__c = '1';
        insert accList;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        insert conList;
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        insert billAcc;
        
         
        
        List<BT_CO_VSS_CreditDebit__c> lstVSSRecords = TestDataFactory.createBT_CO_VSS_CreditDebit(200);
        for(BT_CO_VSS_CreditDebit__c btVSS: lstVSSRecords ){
        btVSS.Copies__c = 10;
        btVSS.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
        btVSS.Delivery__c = 2;
        btVSS.Posting_Date__c = monthEnd;
        btVSS.Recipient_Contact__c = conList[0].Id;
        btVSS.Total_Amount__c = 2;
        btVSS.Vendor_Group__c = '1';
        btVSS.Vendor_Number__c = '1';
        btVSS.Job_Id__c = 'SP011'; 
        }
  
        insert lstVSSRecords;
         
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c zuoSub : zuoSubList){
        zuoSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSub.Recipient_Contact__c= conList[0].Id;
        zuoSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
        zuoSub.Vendor_1__c = accList[0].Id;
        zuoSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSub.Zuora__SubscriptionStartDate__c = monthStart;
        //zuoSub.Zuora__SubscriptionEndDate__c = monthStart;
        zuoSub.Zuora__SubscriptionEndDate__c = date.today()+100;
        zuoSub.Main_Package__c = packageList[0].Id;
        zuoSub.Zuora__CustomerAccount__c = billAcc.id;
        zuoSub.Zuora__Account__c = accList[0].id;
        zuoSub.Subscriber_Contact__c= conList[0].Id; 
        zuoSub.Number_of_Copies__c= 10; 
        zuoSub.Vendor_Credit_1__c = 2;
        zuoSub.Vendor_1__c = accList[0].Id;
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        }
          
        insert zuoSubList;
        
         Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = accList[0].Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        orderRec.Base_Subscription__c = zuoSubList[0].id; 
        insert orderRec;
        
        /* Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = orderRec.Id;
         orderline.Start_Date__c = Date.Today().addDays(1);
         orderline.End_Date__c = Date.Today().addDays(100);
         orderline.Main_Package_ID__c = packageList[0].Id;
         orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
         insert orderline;*/
         
        Test.startTest();
        Map<ID, Zuora__Subscription__c> mapPreRecipientToDelSub1 = new Map<ID, Zuora__Subscription__c>();
        mapPreRecipientToDelSub1.put(conList[0].Id, zuoSubList[0]);
        
        SP_MonthlyDeliveryFeeBatch batch = new SP_MonthlyDeliveryFeeBatch();
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
        }
        
    static testMethod void testSP_MonthlyDeliveryFeeBatch02(){
        
        Date monthStart = Date.today().toStartOfMonth();
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date monthEnd = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        //List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        //insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        accList[0].Vendor_Group__c = '1';
        accList[0].Vendor_Code__c = '1';
        insert accList;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        insert conList;
        
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        insert billAcc;
        
         
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        for (Zuora__Subscription__c zuoSub : zuoSubList){ 
        zuoSub.Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
        zuoSub.Recipient_Contact__c= conList[0].Id;
        zuoSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
        zuoSub.Vendor_1__c = accList[0].Id;
        zuoSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSub.Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
        zuoSub.Zuora__SubscriptionStartDate__c = monthEnd;
        //zuoSub.Zuora__SubscriptionEndDate__c = null;
        zuoSub.Zuora__SubscriptionEndDate__c = date.today()+100;
        zuoSub.Main_Package__c = packageList[0].Id;
        //zuoSub.Order_Number_1__c = orderRec.id;
        zuoSub.Zuora__CustomerAccount__c = billAcc.id;
        zuoSub.Zuora__Account__c = accList[0].id;
        zuoSub.Subscriber_Contact__c= conList[0].Id; 
        zuoSub.Number_of_Copies__c= 10; 
        zuoSub.Vendor_Credit_1__c = 2;
        zuoSub.Vendor_1__c = accList[0].Id;
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
         }
        
        insert zuoSubList;
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = accList[0].Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        orderRec.Base_Subscription__c = zuoSubList[0].id; 
        insert orderRec;
        
        /*Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = orderRec.Id;
         orderline.Start_Date__c = Date.Today().addDays(1);
         orderline.End_Date__c = Date.Today().addDays(100);
         orderline.Main_Package_ID__c = packageList[0].Id;
         orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
         insert orderline;*/
           
         
        Test.startTest();
        SP_MonthlyDeliveryFeeBatch batch = new SP_MonthlyDeliveryFeeBatch();
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
        }
        
    static testMethod void testSP_MonthlyDeliveryFeeBatch03(){
        
        Date monthStart = Date.today().toStartOfMonth();
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date monthEnd = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        //List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        //insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        accList[0].Vendor_Group__c = '1';
        accList[0].Vendor_Code__c = '1';
        insert accList;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        List<Contact> conList = new List<Contact>();
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = accList[0].Id;
        con.Address__c = addressRec.Id;
        con.Recipient_Indicator__c = true;
        con.LastName = 'Last Name';
        con.FirstName = 'First Name';
        con.Phone = '1234567';
        con.Billing_Indicator__c = TRUE;
        con.Mobile_Number__c = '09155568874'; 
        con.Mobile_Number_2__c = '09112234567';
        
        conList.add(con);
        insert conList;
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        insert billAcc;
        
         
           
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        for (Zuora__Subscription__c zuoSub : zuoSubList){ 
        zuoSub.Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
        zuoSub.Recipient_Contact__c= conList[0].Id;
        zuoSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
        zuoSub.Vendor_1__c = accList[0].Id;
        zuoSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_CANCEL;
        zuoSub.Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
        zuoSub.Zuora__SubscriptionStartDate__c = monthStart.addDays(2);
        zuoSub.Zuora__SubscriptionEndDate__c = date.today()+100;
        zuoSub.Main_Package__c = packageList[0].Id;
        //zuoSub.Order_Number_1__c = orderRec.id;
        zuoSub.Zuora__CustomerAccount__c = billAcc.id;
        zuoSub.Zuora__Account__c = accList[0].id;
        zuoSub.Subscriber_Contact__c= conList[0].Id; 
        zuoSub.Number_of_Copies__c= 10; 
        zuoSub.Vendor_Credit_1__c = 2;
        zuoSub.Vendor_1__c = accList[0].Id;
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';

         }
        
        insert zuoSubList;
        
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = accList[0].Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        orderRec.Base_Subscription__c = zuoSubList[0].id; 
        insert orderRec;
        
       /* Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = orderRec.Id;
         orderline.Start_Date__c = Date.Today().addDays(1);
         orderline.End_Date__c = Date.Today().addDays(100);
         orderline.Main_Package_ID__c = packageList[0].Id;
         orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
         insert orderline;*/
        
         
        Test.startTest();
        SP_MonthlyDeliveryFeeBatch batch = new SP_MonthlyDeliveryFeeBatch();
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }
    
    static testMethod void testSP_MonthlyDeliveryFeeBatch04(){
                
        //-FROM Base Code
        Date monthStart = Date.today().toStartOfMonth();
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date monthEnd = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        //List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        //insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        //List<Account> accList = TestDataFactory.createAccount(3, 'Vendor');
            //RecordType = Vendor
            RecordType myRT1 = [select Id, Name from RecordType where SobjectType = 'Account' AND Name = 'Vendor' limit 1];        
        accList[0].RecordTypeId = myRT1.id;
        accList[0].NRIC__c = 'T1234567R';
        accList[0].Vendor_Group__c = '1';
        accList[0].Vendor_Code__c = '1';
        insert accList;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        //SELECT ID FROM Contact WHERE Recipient_Indicator__c = true'
        List<Contact> conList = TestDataFactory.createContact(2);
            conList[0].AccountId = accList[0].Id;
            conList[0].Address__c = addressRec.Id;
            conList[0].Recipient_Indicator__c = true;
            conList[0].LastName = 'Last Name';
            conList[0].FirstName = 'First Name';
            conList[0].Phone = '1234567';
            conList[0].Billing_Indicator__c = TRUE; 
            conList[0].Mobile_Number__c = '09155568874'; 
            conList[0].Mobile_Number_2__c = '09112234567';
            //
            conList[1].AccountId = accList[0].Id;
            conList[1].Address__c = addressRec.Id;
            conList[1].Recipient_Indicator__c = true;
            conList[1].LastName = 'Last Name';
            conList[1].FirstName = 'First Name';
            conList[1].Phone = '1234567';
            conList[1].Billing_Indicator__c = TRUE; 
            conList[1].Mobile_Number__c = '09155568874'; 
            conList[1].Mobile_Number_2__c = '09112234567';
        insert conList;
       
       
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        insert billAcc;
        
        
        //TODO
        //Order_Line_Item__c  vma1 = [SELECT Id, Name, Vendor_Mailing_Agent__c FROM Order_Line_Item__c WHERE Vendor_Mailing_Agent__c != null LIMIT 1];
                
        
        
        List<BT_CO_VSS_CreditDebit__c> lstVSSRecords = TestDataFactory.createBT_CO_VSS_CreditDebit(200);
        for(BT_CO_VSS_CreditDebit__c btVSS: lstVSSRecords ){
            btVSS.Copies__c = 10;
            btVSS.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
            btVSS.Delivery__c = 2;
            btVSS.Posting_Date__c = monthEnd;
            btVSS.Recipient_Contact__c = conList[0].Id;
            btVSS.Total_Amount__c = 2;
            btVSS.Vendor_Group__c = '1';
            btVSS.Vendor_Number__c = '1';
            btVSS.Job_Id__c = 'SP011'; 
        }
  
        insert lstVSSRecords;
        
        /* FROM Zuora__Subscription__c WHERE
               Recipient_Contact__c in :lstContacts AND
               Subscription_Type_1__c = :SUB_TYPE_DEL AND
               Vendor_1__c != null*/
              
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c zuoSub : zuoSubList){        
            zuoSub.Main_Package__c = packageList[0].Id;           
            zuoSub.Zuora__CustomerAccount__c = billAcc.id;            
            //Recipient_Contact__c in :lstContacts
            zuoSub.Recipient_Contact__c= conList[0].Id;
            //Subscription_Type_1__c = :SUB_TYPE_DEL
            zuoSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
            zuoSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
            //Zuora__Status__c = :ACTIVE
            zuoSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
            zuoSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            zuoSub.Zuora__SubscriptionStartDate__c = monthStart;
            zuoSub.Zuora__SubscriptionEndDate__c = date.today()+100;
                        //Vendor_1__c != null
            zuoSub.Vendor_1__c = accList[0].Id;
            zuoSub.Vendor__c = accList[0].Id;
        
            zuoSub.Zuora__Account__c = accList[0].id;
            zuoSub.Subscriber_Contact__c= conList[0].Id; 
            zuoSub.Number_of_Copies__c= 10; 
            zuoSub.Vendor_Credit_1__c = 2;
        //TODO
            //zuoSub.Order_Line_Item_Number__c = orderline.id; 
            //zuoSub.Order_Line_Item_Number_1__c =orderline.id;//joy
            zuoSubList[0].Term_Length__c = 1;
            zuoSubList[0].Term_Length1__c = '1';
                                        //TODO
        }
        zuoSubList[2].Recipient_Contact__c= conList[1].Id;
        zuoSubList[2].Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
        zuoSubList[2].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_CANCEL;
          
        insert zuoSubList;
        
         
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = accList[0].Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        orderRec.Base_Subscription__c = zuoSubList[0].id; 
        insert orderRec;
        
       /* Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = packageList[0].Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        orderline.Vendor_Mailing_Agent__c = accList[0].Id;                 //TODO
        insert orderline;*/
                 
         
        Test.startTest();
        SP_MonthlyDeliveryFeeBatch batch = new SP_MonthlyDeliveryFeeBatch(Date.today().addMonths(1));
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        //System.assertNotEquals(0, batch.getRelatedCOAs(lstPubSubs).size());
        
        Test.stopTest();
    }
    
    /*FROM Case_Subscription__c WHERE Subscription__c in :lstPubSubs AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       AND Case__r.Effective_Date__c > :monthStart AND Case__r.Effective_Date__c <= :monthEnd
                       AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD 
                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC
                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR)])*/
    static testMethod void testGetRelatedCOAs01() {
        
        //-FROM Base Code
        Date monthStart = Date.today().toStartOfMonth();
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date monthEnd = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        //List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        //insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        //List<Account> accList = TestDataFactory.createAccount(3, 'Vendor');
            //RecordType = Vendor
            RecordType myRT1 = [select Id, Name from RecordType where SobjectType = 'Account' AND Name = 'Vendor' limit 1];        
        accList[0].RecordTypeId = myRT1.id;
        accList[0].NRIC__c = 'T1234567R';
        accList[0].Vendor_Group__c = '1';
        accList[0].Vendor_Code__c = '1';
        insert accList;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.RecordTypeId = addressRT.id;
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        //SELECT ID FROM Contact WHERE Recipient_Indicator__c = true'
        List<Contact> conList = TestDataFactory.createContact(2);
            conList[0].AccountId = accList[0].Id;
            conList[0].Address__c = addressRec.Id;
            conList[0].Recipient_Indicator__c = true;
            conList[0].LastName = 'Last Name';
            conList[0].FirstName = 'First Name';
            conList[0].Phone = '1234567';
            conList[0].Billing_Indicator__c = TRUE; 
            conList[0].Mobile_Number__c = '09155568874'; 
            conList[0].Mobile_Number_2__c = '09112234567';
            //
            conList[1].AccountId = accList[0].Id;
            conList[1].Address__c = addressRec.Id;
            conList[1].Recipient_Indicator__c = true;
            conList[1].LastName = 'Last Name';
            conList[1].FirstName = 'First Name';
            conList[1].Phone = '1234567';
            conList[1].Billing_Indicator__c = TRUE; 
            conList[1].Mobile_Number__c = '09155568874'; 
            conList[1].Mobile_Number_2__c = '09112234567';
        insert conList;
       
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        insert billAcc;
        
        
        //TODO
        //Order_Line_Item__c  vma1 = [SELECT Id, Name, Vendor_Mailing_Agent__c FROM Order_Line_Item__c WHERE Vendor_Mailing_Agent__c != null LIMIT 1];
                
        
        
        List<BT_CO_VSS_CreditDebit__c> lstVSSRecords = TestDataFactory.createBT_CO_VSS_CreditDebit(200);
        for(BT_CO_VSS_CreditDebit__c btVSS: lstVSSRecords ){
            btVSS.Copies__c = 10;
            btVSS.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
            btVSS.Delivery__c = 2;
            btVSS.Posting_Date__c = monthEnd;
            btVSS.Recipient_Contact__c = conList[0].Id;
            btVSS.Total_Amount__c = 2;
            btVSS.Vendor_Group__c = '1';
            btVSS.Vendor_Number__c = '1';
            btVSS.Job_Id__c = 'SP011'; 
        }
  
        insert lstVSSRecords;
        
        /* FROM Zuora__Subscription__c WHERE
               Recipient_Contact__c in :lstContacts AND
               Subscription_Type_1__c = :SUB_TYPE_DEL AND
               Vendor_1__c != null*/
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c zuoSub : zuoSubList){        
            zuoSub.Main_Package__c = packageList[0].Id;           
            zuoSub.Zuora__CustomerAccount__c = billAcc.id;            
            
            zuoSub.Recipient_Contact__c= conList[0].Id;
            
            zuoSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
            zuoSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
            
            zuoSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
            zuoSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            zuoSub.Zuora__SubscriptionStartDate__c = monthStart;
            
            //zuoSub.Zuora__SubscriptionEndDate__c = Date.Today().addDays(1);
            zuoSub.Zuora__SubscriptionEndDate__c = Date.Today().addDays(2);
            zuoSub.Vendor_1__c = accList[0].Id;
            zuoSub.Vendor__c = accList[0].Id;
        
            zuoSub.Zuora__Account__c = accList[0].id;
            zuoSub.Subscriber_Contact__c= conList[0].Id; 
            zuoSub.Number_of_Copies__c= 10; 
            zuoSub.Vendor_Credit_1__c = 2;
        //TODO
            //zuoSub.Order_Line_Item_Number__c = orderline.id; 
            zuoSubList[0].Term_Length__c = 1;
            zuoSubList[0].Term_Length1__c = '1';
                                                    //TODO
        }
        zuoSubList[2].Recipient_Contact__c= conList[1].Id;
        zuoSubList[2].Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
        zuoSubList[2].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_CANCEL;
          
        insert zuoSubList;
    
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = accList[0].Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        orderRec.Base_Subscription__c = zuoSubList[0].id; 
        orderRec.Order_Type__c = ConstantsSLB.getOther('Change of Subscription');
        //orderRec.Recipient_Type__c = 'Overseas';
        insert orderRec;
        
        
        /*Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        //orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.Start_Date__c = Date.Today().addDays(3);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = packageList[0].Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        orderline.Vendor_Mailing_Agent__c = accList[0].Id;                 //TODO
        insert orderline;*/
        
        //Cir_Planner_Schedule__c
        Cir_Planner_Schedule__c cps = new Cir_Planner_Schedule__c(Name='CIR Plan Schedule', Mon_Fri_End_Time__c=Date.today(),
                Mon_Fri_Start_Time__c=Date.today(),Sat_PH_End_Time__c=Date.today(),Sat_PH_Start_Time__c=Date.today(),
                Sun_End_Time__c=Date.today(),Sun_Start_Time__c=Date.today());
        Database.insert(cps);

    
        List<Case> caseList = TestDataFactory.createCase(2, 'Start Subscription');
        for (Case c : caseList) {
            c.Status = GlobalVariableClass.STATUS_CLOSED;
            c.Effective_Date__c = Date.today().addMonths(1).toStartOfMonth().addDays(1);
            c.Order__c = orderRec.id;                                    //TODO
            c.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        }
        Database.insert(caseList);
        
        List<Case_Subscription__c> caseSubscriptionList = TestDataFactory.createCaseSubscription(2);
            caseSubscriptionList[0].Case__c = caseList[0].id;
            caseSubscriptionList[0].Subscription__c = zuoSubList[0].id;
            caseSubscriptionList[0].Account__c = accList[0].id;
            caseSubscriptionList[0].isComplaint__c = FALSE;
            //
            caseSubscriptionList[1].Case__c = caseList[1].id;
            caseSubscriptionList[1].Subscription__c = zuoSubList[1].id;
            caseSubscriptionList[1].Account__c = accList[0].id;
            caseSubscriptionList[1].isComplaint__c = FALSE;
        Database.insert(caseSubscriptionList);
                 
        List<Zuora__Subscription__c> lstPubSubs = new List<Zuora__Subscription__c>();
            lstPubSubs.add(zuoSubList[0]);
            lstPubSubs.add(zuoSubList[1]);
            
        Test.startTest();
        SP_MonthlyDeliveryFeeBatch batch = new SP_MonthlyDeliveryFeeBatch(Date.today().addMonths(1));
        //ID batchprocessid = Database.executeBatch(batch, 200); 
        //System.assertNotEquals(null, batchprocessid);
        batch.getRelatedCOAs(lstPubSubs);
        Test.stopTest();
        
        
        Set<String> selectiveIds = new Set<String>();
        selectiveIds.add('test');
        
        SP_MonthlyDeliveryFeeBatch batch2 = new SP_MonthlyDeliveryFeeBatch(selectiveIds, date.today());
        
    }
}