/**
* Class Name: ARMS_CreateAndUpdateTest
* @author: Accenture PDC - sudha kumari
* Date: 16.Feb.2015
* Requirement/Project Name: SF SPH
* @description: test class for ARMS_CreateAndUpdate
*/
@isTest (Seealldata = TRUE)
private class ARMS_CreateAndUpdateTest{
    
    private static List<BT_CO_ARMS_CreateCustAccountFile__c> createBT_CO_ARMS_CreateCustAccountFile() {
        List<BT_CO_ARMS_CreateCustAccountFile__c> BT_CO_ARMS_CreateCustAccountFileList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        
        BT_CO_ARMS_CreateCustAccountFile__c custAccFile = new BT_CO_ARMS_CreateCustAccountFile__c();
        custAccFile.Account_Type__c = '1';
        custAccFile.Address1__c = '2';
        custAccFile.Address2__c = '3';
        custAccFile.Address3__c = '4';
        custAccFile.Address4__c = '5';
        custAccFile.Approved_Debt_Exposure_Amount__c = '6';
        custAccFile.Block_House_Number__c = '7';
        custAccFile.Building_Secondary__c = '8';
        custAccFile.Business_Profile__c = '9';
        custAccFile.Business_Sector__c = '10';
        custAccFile.City_Zip__c = '11';
        custAccFile.Co_Attention_To_Indicator__c = '1';
        custAccFile.co_Attention_To_Party__c = '13';
        custAccFile.Company_Code__c = '14';
        custAccFile.Country__c = '15';
        custAccFile.Create_Id__c = '16';
        //custAccFile.CreatedById = null;
        //custAccFile.CreatedDate = null;
        custAccFile.Credit_Limit_External__c = '17';
        custAccFile.Credit_Limit_Internal__c = '18';
        custAccFile.Credit_Term__c = '19';
        custAccFile.Credit_Term_Reference__c = '20';
        custAccFile.Customer_Name1__c = '21';
        custAccFile.Customer_Name2__c = '22';
        custAccFile.Customer_Status__c = '23';
        custAccFile.Debt_Mgt_Treatment__c = '24';
        custAccFile.Floor_Number__c = '25';
        custAccFile.GST_OutOfScope_Indicator__c = '1';
        //custAccFile.Id = 0;
        custAccFile.ID_No__c = '27';
        custAccFile.ID_Type__c = '28';
        //custAccFile.IsDeleted = false;
        //custAccFile.LastModifiedById = null;
        //custAccFile.LastModifiedDate = null;
        //custAccFile.LastReferencedDate = null;
        //custAccFile.LastViewedDate = null;
        custAccFile.Name = '29';
        //custAccFile.OwnerId = null;        
        custAccFile.Passport_Country_Code__c = '30';
        custAccFile.PO_Box_No__c = '31';
        custAccFile.Postal_Code__c = '32';
        custAccFile.Record_Type__c = 'Detail';
        custAccFile.Reference_Key__c = '34';
        custAccFile.Retrieve_Account_Indicator__c = '1';
        custAccFile.SOA_Group__c = '36';
        custAccFile.SOA_Supression_Indicator__c = '1';
        //custAccFile.Sort_Order__c = '38';
        custAccFile.SPH_Staff_Indicator__c = '1';
        custAccFile.Status__c = '40';
        custAccFile.Street__c = '41';
        custAccFile.Sub_Contact_Designation__c = '42';
        custAccFile.Sub_Contact_Ext__c = '43';
        custAccFile.Sub_Contact_Name__c = '43';
        custAccFile.Sub_Contact_Type__c = '1';
        custAccFile.Sub_ContactNo_Email__c = '45';
        //custAccFile.SystemModstamp = null;
        custAccFile.Transient_Indicator__c = '1';
        custAccFile.Unique_Key__c = '48';
        custAccFile.Unit_No__c = '49';

        BT_CO_ARMS_CreateCustAccountFileList.add(custAccFile);
        
        return BT_CO_ARMS_CreateCustAccountFileList;
    }
    
    /*
    private static List<Zuora__CustomerAccount__c> createZuora__CustomerAccount() {
        List<Zuora__CustomerAccount__c> Zuora__CustomerAccountList = new List<Zuora__CustomerAccount__c>();
        Zuora__CustomerAccount__c cusAcc = new Zuora__CustomerAccount__c();
        //cusAcc.
        
        Zuora__CustomerAccountList.add(cusAcc);
        return Zuora__CustomerAccountList;
    }*/
    
    static testmethod void createCustomerWebservice() {
        
        //set BT_CO_ARMS_CreateCustAccountFile__c
        try{
        BT_CO_ARMS_CreateCustAccountFile__c custAccFile = createBT_CO_ARMS_CreateCustAccountFile()[0];
        //START: Tine Test Classes 04-24-2016 
            
            insert custAccFile;
        
        //END: Tine Test Classes 04-24-2016
        System.debug('custAccFile.Id: ' + custAccFile.Id);
        
        //set Account for Zuora__CustomerAccount__c
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'fdf';
        acc.Contact_Person__c = 'reer';
        insert acc;
        
        //set Zuora__CustomerAccount__c
        Zuora__CustomerAccount__c custAcc = TestDataFactory.createBillingAccount(1)[0];
        custAcc.Zuora__Account__c = acc.Id;
        insert custAcc;
        System.debug('custAcc.Id: ' + custAcc.Id);
        
        Set<Id> cusBatchId = new Set<Id>();
        cusBatchId.add(custAccFile.Id);
        
        Set<Id> baIdSet = new Set<Id>();
        baIdSet.add(custAcc.Id);
        
        
        //debug
        List<Zuora__CustomerAccount__c> billAccList = [Select Id, 
                Name, 
                ARMS_ID__c, 
                Zuora__Zuora_Id__c, 
                ARMS_Account_Number__c, 
                Zuora__AccountNumber__c, 
                Zuora__Account__r.AccountNumber, 
                ARMS_Debt_Management__c, 
                ARMS_Business_Profile__c, 
                ARMS_Customer_Number__c 
        From Zuora__CustomerAccount__c Where Id IN :baIdSet];
        
        System.debug('billAccList size: ' + billAccList.size());
        
        boolean check = billAccList<>null && billAccList.size()>0;
        System.debug('check: ' + check);
            
        //debug
        
        
        
            try {
                Test.startTest();
                    //SubscriptionTriggerHandler sth = new SubscriptionTriggerHandler();
                    //ARMS_CreateAndUpdate cau = new ARMS_CreateAndUpdate();
                    //cau.createCustomerWebservice(cusBatchId, baIdSet);
                    ARMS_CreateAndUpdate.createCustomerWebservice(cusBatchId, baIdSet);
                Test.stopTest();
            } catch(Zuora.zRemoteException e) {
                System.debug('zRemoteException: ' + e);
            }
        }catch(Exception e){
            System.debug('Error ' + e);
        }
        
        /*
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'fdf';
        acc.Contact_Person__c = 'reer';
        insert acc;
        
        Zuora__CustomerAccount__c ba = TestDataFactory.createbillingaccount(1)[0];
        ba.Zuora__Account__c = acc.Id;
        insert ba;
        
        Contact cont = TestDataFactory.createContact(1)[0];        
        cont.AccountId = acc.Id;
        cont.lastname = 'rert';
        cont.Recipient_Indicator__c = true;
        insert cont;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.account__c = acc.Id;
        order.Delivery_Charge__c= 32;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 12;
        order.Credit_Balance__c = 2;
        order.Order_Legacy_Id__c = 'df';
        order.Legacy_Create_Date__c = 'sdfds';
        order.Legacy_Create_By__c = 'dfdf';
        order.Legacy_Update_Date__c = 'fdgf';
        order.Legacy_Update_By__c = 'dfd';
        order.Informed_Customer__c = true;
        order.Sub_Category__c = 'Stop Subscription';
        order.Recipient_Contact__c = cont.id;
        insert order;
        
        Package__c pkg = new Package__c();
        pkg = TestDataFactory.createPackage(1)[0];
        pkg.Billing_Type__c = 'Add On';
        pkg.Package_Code__c = '5343';
        pkg.name = 'rwere';
        pkg.Effective_Start_Date__c = system.today();
        pkg.Effective_End_Date__c = system.today();
        insert pkg;
        
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.name = 'abs';
        zs.Unique_Address_Id__c='wewe';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Number_of_Copies__c = 23323223;
        zs.Next_Earliest_Start_Date__c = system.today();
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 2;
        zs.Legacy_Create_Date__c = 'xc';
        zs.Legacy_Create_By__c = 'wq';
        zs.Legacy_Update_Date__c = 'we';
        zs.Legacy_Update_By__c = 'wer';
        zs.Legacy_Subscription_ID__c = '234';
        zs.Cheque_details__c = 'ew';
        zs.DTL__c = 'rt';
        zs.Paypal_Payment_Profile_Id__c = 're';
        zs.Pub_Tag__c = 'reere';
        zs.Sponsored_Indicator__c = 'er';
        zs.Subscribe_As__c = 'rew';
        zs.Zuora__SubscriptionEndDate__c = date.Today().addDays(100);
        zs.Subscription_Grace_Period_End_Date__c = 'rty';
        zs.Gift_ID__c = 'ere';
        zs.Redeem_Date__c = 'ukvvgk';
        zs.Gift_ID_2__c = 'fdfs';
        zs.Redeem_Date_2__c = 'fsf';
        zs.Subscriber_Contact__c = cont.id;
        zs.Subscription_Charge__c = 43;
        zs.Term_Length__c = 43;
        zs.Main_Package_1__c = pkg.id;
        zs.Zuora__Zuora_Id__c = 'dsfdd';
        //zs.Number_of_Copies1__c = '10'
        //zs.Order_Number__c = 'sfdgdgdf';
        insert zs;  
        
        Test.startTest();
            //SubscriptionTriggerHandler sth = new SubscriptionTriggerHandler();
            
        Test.stopTest();
        */
    }
    
    private static Order__c createOrder(Account acc, Contact con, Contact con1, Zuora__CustomerAccount__c billAcc) {
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        order.Business_Profile__c = 'NORMAL';
        //order.Postage_Charge__c = 200.00;
        
        return order;
    }
    
    private static Account createAccountDummy() {
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        
        return acc;
    }
    
    private static Contact  createContact(Account acc, Address__c addressRec) {
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        
        return con;
    }
    
    private static Address__c createAddressRec(Singpost_Address__c postal, Country__c country) {
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = country.Id;
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        
        return addressRec ;
    }
    
    private static Singpost_Address__c createPostal() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        
        return postal;
    }
    
    private static Country__c createCountry() {
        Country__c country = new Country__c();
        country.Name = 'ZZ';
        country.Code__c = 'ZZ';
        country.Country_Name__c = 'ZZambia';
     
         return country;
    }
    
    static testmethod void createAccount() {
        
        
            Account acc = createAccountDummy();
            insert acc;
            //insert acc;
            
            Singpost_Address__c postal = createPostal();
            insert postal;            
            
            Country__c country = createCountry();
            insert country ;
            
            Address__c addressRec = createAddressRec(postal, country);
            insert addressRec;
            
            Contact con = createContact(acc, addressRec);
            insert con;
        
            Contact con1 = createContact(acc, addressRec);
            insert con1;
        
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            insert billAcc;
           
            //SET Order__c
            Order__c order = createOrder(acc, con, con1, billAcc);
            //START: Tine Test class 04/24/2016
            try{
                insert order;
            }catch(Exception e){
                System.debug('Error ' + e);
            }
            
        //SET orderIdSet
        set<id> orderIdSet = new set<id>();
        orderIdSet.add(order.Id);
        
        //SET billingAccountId_paymentInfoWrapper
        //ARMS_CreateAndUpdate.PaymentInfoWrapper pIW = new ARMS_CreateAndUpdate.PaymentInfoWrapper();
        map<id, ARMS_CreateAndUpdate.PaymentInfoWrapper> billingAccountId_paymentInfoWrapper = new map<id, ARMS_CreateAndUpdate.PaymentInfoWrapper>();
        
        //SET billingAccountId_billingAccount
        Map<Id, Zuora__CustomerAccount__c> billingAccountId_billingAccount = new Map<Id, Zuora__CustomerAccount__c>();
        billingAccountId_billingAccount.put(billAcc.Id, billAcc);
        
        //SET billingAccountId_Order
        map<id, Order__c> billingAccountId_Order = new map<id, Order__c>();
        billingAccountId_Order.put(order.Id, order);
        
        
        try {
            Test.startTest();
                ARMS_CreateAndUpdate cAu = new ARMS_CreateAndUpdate();
                cAu.createAccount(orderIdSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper , billingAccountId_Order);
                //ARMS_CreateAndUpdate.createAccount(orderIdSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper , billingAccountId_Order);
            Test.stopTest();
        } catch(Zuora.zRemoteException e) {
            System.debug('zRemoteException: ' + e);
        }
    }
    
           
}