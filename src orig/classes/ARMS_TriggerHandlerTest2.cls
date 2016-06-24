@isTest 
public class ARMS_TriggerHandlerTest2{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createPlannerSched();  
    }  
    
    static testMethod void testSingleInsertUpdateDelete(){
        //START: Tine Test Classes 04/25/2016
        try{
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.Staff_ID__c = 'ID001';
            database.insert(acc);
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = [SELECT id,DeveloperName FROM RecordType WHERE SObjectType = 'Address__c' AND DeveloperName = 'Local' LIMIT 1].Id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.FirstName='fname';
            con.LastName='lname'; 
            con.AccountId = acc.Id;
            con.Billing_Indicator__c = true;
            con.Address__c = ad.Id;
            con.Office_Number__c = '123';
            con.HomePhone__c = '1234';
            con.Mobile_Number__c = '123456789';
            con.Fax__c = '123';
            con.Office_Extension__c = '123';
            database.insert(con);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
            ord.Account__c = acc.Id;
            ord.Billing_Contact__c = con.Id;
            database.insert(ord);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Billing_Contact__c = con.Id;
            billAcc.ExistingBillingContact__c = con.Id;
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.ARMS_Business_Profile__c = 'NORM';
            billAcc.ARMS_Debt_Management__c = 'NORM';
            billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
            
            test.startTest();
            //START: Tine Test Classes 04/25/2016 
            
            database.insert(billAcc);
            
            //END: Tine Test Classes 04/25/2016 
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Order_Number_1__c = ord.Id;
            database.insert(sub);
            
            BT_CO_ARMS_CreateCustAccountFile__c bt = new BT_CO_ARMS_CreateCustAccountFile__c();
            bt.Customer_Name1__c = billAcc.Name;
            bt.Unique_Key__c = 'Test';
            bt.Sub_Contact_Ext__c = con.Office_Extension__c;
            //START: Tine Test Classes 04/25/2016
            
            database.insert(bt);
        
            List<BT_CO_ARMS_CreateCustAccountFile__c>  btc = [SELECT Id, Unique_Key__c FROM BT_CO_ARMS_CreateCustAccountFile__c  WHERE id =: bt.Id AND CreatedDate = Today];
            System.assertEquals(btc.size(), 1);
        
        
            billAcc.Name = 'UpdateSample';
            billAcc.Payment_Mode__c = GlobalVariableClass.OTHER;
            billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
            billAcc.ARMS_Customer_Number__c = '123';
            billAcc.ARMS_Account_Number__c = '123';
            billAcc.ARMS_Business_Profile__c = 'NORM';
            billAcc.ARMS_Debt_Management__c = 'NORM';
            billAcc.ARMS_Account_Type__c = 'New Type';
            billAcc.ARMS_Return_Message__c = 'Test';
            /*database.update(billAcc);*/
            
            /*ad.RecordTypeId = [SELECT id,DeveloperName FROM RecordType WHERE SObjectType = 'Address__c' AND DeveloperName = 'Overseas' LIMIT 1].Id;
            database.update(ad);
            
            con.Address__c = ad.Id;
            database.update(con); */
            
            billAcc.Other_PaymentMethod__c = 'Invoice';
            billAcc.ARMS_ID__c = null;
            billAcc.ARMS_Account_Number__c = null;
            billAcc.Billing_Contact__c = con.Id;
            /*database.update(billAcc);*/
            
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcc.Other_PaymentMethod__c = 'Invoice';
            billAcc.ARMS_ID__c = null;
            billAcc.ARMS_Account_Number__c = null;
            /*database.update(billAcc);*/
            
            billAcc.Other_PaymentMethod__c = null;
            billAcc.Billing_Contact__c = null;
            /*database.update(billAcc);*/
        
            //END: Tine Test Classes 04/25/2016
            /*database.delete(billAcc);*/
        }catch(Exception e){
            System.debug('Error ' + e);
        }
      
        test.stopTest();
    }
    
    static testMethod void testSingleInsertUpdateDelete2(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT id,DeveloperName FROM RecordType WHERE SObjectType = 'Address__c' AND DeveloperName = 'Overseas' LIMIT 1].Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.FirstName='fname';
        con.LastName='lname'; 
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        con.Address__c = ad.Id;
        con.Passport__c = 'pass123';
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        ord.Account__c = acc.Id;
        ord.Billing_Contact__c = con.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Billing_Contact__c = con.Id;
        billAcc.ExistingBillingContact__c = con.Id;
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Business_Profile__c = 'NORM';
        billAcc.ARMS_Debt_Management__c = 'SUBH';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        
        test.startTest();
        
        /*database.insert(billAcc);*/
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Order_Number_1__c = ord.Id;
        //START: Tine test classes 04/24/2016
        try{
            database.insert(sub);
        }catch(Exception e){
            System.debug(e);
        }
        
        BT_CO_ARMS_CreateCustAccountFile__c bt = new BT_CO_ARMS_CreateCustAccountFile__c();
        bt.Customer_Name1__c = billAcc.Name;
        bt.Unique_Key__c = 'Test';
        database.insert(bt);
        
        List<BT_CO_ARMS_CreateCustAccountFile__c>  btc = [SELECT Id FROM BT_CO_ARMS_CreateCustAccountFile__c  WHERE id =: bt.Id AND CreatedDate = Today];
        System.assertEquals(btc.size(), 1);
        
        billAcc.Name = 'UpdateSample';
        billAcc.Payment_Mode__c = GlobalVariableClass.OTHER;
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc.ARMS_Customer_Number__c = '123';
        billAcc.ARMS_Account_Number__c = '123';
        billAcc.ARMS_Business_Profile__c = 'NORM';
        billAcc.ARMS_Debt_Management__c = 'NORM';
        billAcc.ARMS_Account_Type__c = 'New Type';
        billAcc.ARMS_Return_Message__c = 'Test';
         /*database.update(billAcc);*/
        
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.ARMS_ID__c = null;
        billAcc.ARMS_Account_Number__c = null;
        billAcc.Billing_Contact__c = con.Id;
         /*database.update(billAcc);*/
        
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.ARMS_ID__c = null;
        billAcc.ARMS_Account_Number__c = null;
         /*database.update(billAcc);*/
        
        billAcc.Other_PaymentMethod__c = null;
        billAcc.Billing_Contact__c = null;
         /*database.update(billAcc);*/
        
        /*database.delete(billAcc);*/
      
        test.stopTest();
    }
    
    static testMethod void testSingleInsertUpdateDelete3(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Airline_Indicator__c = true;
        database.insert(acc);
        
        City__c city = TestDataFactory.createCity(1)[0];
        city.City_Name__c = 'City Name';
        city.Flight_Number_1__c = 'F123';
        database.insert(city);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT id,DeveloperName FROM RecordType WHERE SObjectType = 'Address__c' AND DeveloperName = 'Airline' LIMIT 1].Id;
        ad.City__c = city.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.FirstName='fname';
        con.LastName='lname'; 
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        con.Address__c = ad.Id;
        con.NRIC__c = 'G1314243K';
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        ord.Account__c = acc.Id;
        ord.Billing_Contact__c = con.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Billing_Contact__c = con.Id;
        billAcc.ExistingBillingContact__c = con.Id;
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Business_Profile__c = 'NORM';
        billAcc.ARMS_Debt_Management__c = 'SUBL';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        
        test.startTest();
        
         /*database.insert(billAcc);*/
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Order_Number_1__c = ord.Id;
        try{
            database.insert(sub);
        }catch(Exception e){
            System.debug('Error ' + e);
        }
        
        BT_CO_ARMS_CreateCustAccountFile__c bt = new BT_CO_ARMS_CreateCustAccountFile__c();
        bt.Customer_Name1__c = billAcc.Name;
        bt.Unique_Key__c = 'Test';
        database.insert(bt);
        
        List<BT_CO_ARMS_CreateCustAccountFile__c>  btc = [SELECT Id FROM BT_CO_ARMS_CreateCustAccountFile__c  WHERE id =: bt.Id AND CreatedDate = Today];
        System.assertEquals(btc.size(), 1);
        
        billAcc.Name = 'UpdateSample';
        billAcc.Payment_Mode__c = GlobalVariableClass.OTHER;
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc.ARMS_Customer_Number__c = '123';
        billAcc.ARMS_Account_Number__c = '123';
        billAcc.ARMS_Business_Profile__c = 'NORM';
        billAcc.ARMS_Debt_Management__c = 'NORM';
        billAcc.ARMS_Account_Type__c = 'New Type';
        billAcc.ARMS_Return_Message__c = 'Test';
        //START: Tine Test Classes - 04/25/2016
         /*database.update(billAcc);*/
        
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.ARMS_ID__c = null;
        billAcc.ARMS_Account_Number__c = null;
        billAcc.Billing_Contact__c = con.Id;
         /*database.update(billAcc);*/
        
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.ARMS_ID__c = null;
        billAcc.ARMS_Account_Number__c = null;
         /*database.update(billAcc);*/
        
        billAcc.Other_PaymentMethod__c = null;
        billAcc.Billing_Contact__c = null;
         /*database.update(billAcc);*/
        
        /*database.delete(billAcc);*/
        //END: Tine Test Classes 04/25/2016
        test.stopTest();
    }
    
    static testMethod void testSingleInsertUpdateDelete4(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT id,DeveloperName FROM RecordType WHERE SObjectType = 'Address__c' AND DeveloperName = 'Internal' LIMIT 1].Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.FirstName='fname';
        con.LastName='lname'; 
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        con.Address__c = ad.Id;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        ord.Account__c = acc.Id;
        ord.Billing_Contact__c = con.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Billing_Contact__c = con.Id;
        billAcc.ExistingBillingContact__c = con.Id;
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Business_Profile__c = 'NORM';
        billAcc.ARMS_Debt_Management__c = 'NORM';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        
        test.startTest();
        
         /*database.insert(billAcc);*/
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Order_Number_1__c = ord.Id;
        try{
            database.insert(sub);
        }catch(Exception e){
            System.debug('Error ' + e);
        }
        
        BT_CO_ARMS_CreateCustAccountFile__c bt = new BT_CO_ARMS_CreateCustAccountFile__c();
        bt.Customer_Name1__c = billAcc.Name;
        bt.Unique_Key__c = 'Test';
        database.insert(bt);
        
        List<BT_CO_ARMS_CreateCustAccountFile__c>  btc = [SELECT Id FROM BT_CO_ARMS_CreateCustAccountFile__c  WHERE id =: bt.Id AND CreatedDate = Today];
        System.assertEquals(btc.size(), 1);
        
        billAcc.Name = 'UpdateSample';
        billAcc.Payment_Mode__c = GlobalVariableClass.OTHER;
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc.ARMS_Customer_Number__c = '123';
        billAcc.ARMS_Account_Number__c = '123';
        billAcc.ARMS_Business_Profile__c = 'NORM';
        billAcc.ARMS_Debt_Management__c = 'NORM';
        billAcc.ARMS_Account_Type__c = 'New Type';
        billAcc.ARMS_Return_Message__c = 'Test';
         /*database.update(billAcc);*/
        
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.ARMS_ID__c = null;
        billAcc.ARMS_Account_Number__c = null;
        billAcc.Billing_Contact__c = con.Id;
         /*database.update(billAcc);*/
        
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.ARMS_ID__c = null;
        billAcc.ARMS_Account_Number__c = null;
         /*database.update(billAcc);*/
        
        billAcc.Other_PaymentMethod__c = null;
        billAcc.Billing_Contact__c = null;
         /*database.update(billAcc);*/
        
        /*database.delete(billAcc);*/
      
        test.stopTest();
    }

    static testMethod void testBulkInsertUpdateDelete(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT id,DeveloperName FROM RecordType WHERE SObjectType = 'Address__c' AND DeveloperName = 'Local' LIMIT 1].Id;
        database.insert(ad);
        
        Zuora__CustomerAccount__c billA = TestDataFactory.createBillingAccount(1)[0];
        billA.Zuora__Account__c = acc.Id;
        database.insert(billA);
        
        Zuora__PaymentMethod__c payMethod = TestDataFactory.createPaymentMethod(1)[0];
        payMethod.Zuora__BillingAccount__c = billA.Id;
        payMethod.Zuora__External_Id__c = '123456789';
        database.insert(payMethod);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.FirstName='fname';
        con.LastName='lname'; 
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        con.Address__c = ad.Id;
        con.Office_Extension__c = '122';
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        ord.Account__c = acc.Id;
        ord.Billing_Contact__c = con.Id;
        database.insert(ord);
        
        Integer i=0;
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(200);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
            bill.ARMS_Customer_Number__c = '123';
            bill.ARMS_Account_Number__c = null;
            bill.Zuora__Default_Payment_Method__c = payMethod.Id;
            bill.ARMS_Business_Profile__c = 'GOVT';
            bill.ARMS_Debt_Management__c = 'GOVT';
            bill.Billing_Contact__c = con.Id;
            bill.ARMS_Account_Required__c = false;
        }
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.AccountID = acc.Id;
        cas.Category__c = 'Subscription Request';
        cas.Sub_Category__c = 'Change of Credit Card';
        cas.Payment_Method_ID__c = payMethod.Zuora__External_Id__c;
        database.insert(cas);
       
        test.startTest();
        
        database.insert(billAcc);
        
        BT_CO_ARMS_CreateCustAccountFile__c bt = new BT_CO_ARMS_CreateCustAccountFile__c();
        bt.Customer_Name1__c = billAcc[0].Name;
        bt.Unique_Key__c = 'Test';
        database.insert(bt);
        
        List<BT_CO_ARMS_CreateCustAccountFile__c>  btc = [SELECT Id FROM BT_CO_ARMS_CreateCustAccountFile__c  WHERE id =: bt.Id AND CreatedDate = Today];
        System.assertEquals(btc.size(), 1);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Order_Number_1__c = ord.Id;
        //START: Tine Test classes 04/24/2016
        try{
            database.insert(sub);
        }catch(Exception e){
            System.debug('Error ' + e);
        }
        //END: Tine Test classes 04/24/2016
        billAcc[0].Name = 'UpdateSample';
        billAcc[0].ARMS_Account_Required__c = true;
        billAcc[0].Payment_Mode__c = GlobalVariableClass.OTHER;
        billAcc[0].Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc[0].ARMS_Business_Profile__c = 'NORM';
        billAcc[0].ARMS_Debt_Management__c = 'NORM';
        billAcc[0].ARMS_Customer_Number__c = null;
        billAcc[0].ARMS_Account_Number__c = null;
        billAcc[0].Billing_Contact__c = con.Id;
         /*database.update(billAcc);*/
        //END: Tine Test classes 04/24/2016
        /*database.delete(billAcc);*/
        
        ARMS_TriggerHandler arms = new ARMS_TriggerHandler();
        
        arms.runBeforeInsertTrigger();
        arms.runBeforeUpdateTrigger();
        arms.runBeforeDeleteTrigger();
        arms.runAfterInsertTrigger();
        arms.runAfterUpdateTrigger();
        arms.runAfterDeleteTrigger();
        
        test.stopTest();
    }
}