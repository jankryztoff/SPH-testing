@isTest (SeeAllData = false)
private class BillingAccountHelperTest2 {
    static testmethod void testUpdateBillingAccountPaymenInfo(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        database.insert(con);
        
        Integer counter = 0;
        List<Order__c> ords = TestDataFactory.createOrder(10);
        for(Order__c ord: ords){
            ord.Account__c = acc.Id;
            ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            ord.Payment_Mode__c = 'Other';
            ord.Other_Payment_Mode__c = 'Invoice';
            ord.Create_ARMS_Customer_Account__c = true;
            //ord.Customer_No__c = '01';
            ord.Business_Profile__c = 'GOVT';
            //ord.Debt_Management_Treatment__c = '01';
            ord.Billing_Contact__c = con.Id;
            if(counter==0){
                ord.Create_ARMS_Customer_Account__c = false;    
            }
            else if(counter==5){
                ord.Payment_Mode__c = 'Check';
                ord.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
                ord.Other_Payment_Mode__c = null;
            }
            else if(counter==9){
                ord.Payment_Mode__c = 'Cash';
                ord.Other_Payment_Mode__c = null;
            }
            counter++;
        }
        database.insert(ords);
        
        Set<Id> ordIds = new Set<Id>();
        for(Order__c ordId: ords){
            ordIds.add(ordId.Id);
        }
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Order_Number_1__c = ords[2].Id;
            sub.Billing_Type__c = 'Full Prepaid';
        }
        database.insert(subs);
        
        try{
            Test.setMock(WebServiceMock.class, new zLoginMock());
            test.startTest();
                BillingAccountHelper.updateBillingAccountPaymenInfo(ordIds);
            test.stopTest();  
        }
        catch(Zuora.zAPIException e){}
    }    
    
    static testmethod void testUpdateBillingAccountToZuora(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        database.insert(con);
        
        Integer counter = 0;
        List<Order__c> ords = TestDataFactory.createOrder(10);
        for(Order__c ord: ords){
            ord.Account__c = acc.Id;
            ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            ord.Payment_Mode__c = 'Other';
            ord.Other_Payment_Mode__c = 'Invoice';
            ord.Create_ARMS_Customer_Account__c = true;
            //ord.Customer_No__c = '01';
            ord.Business_Profile__c = 'GOVT';
            //ord.Debt_Management_Treatment__c = '01';
            ord.Billing_Contact__c = con.Id;
            if(counter==0){
                ord.Create_ARMS_Customer_Account__c = false;    
            }
            else if(counter==9){
                ord.Payment_Mode__c = 'Cash';
                ord.Other_Payment_Mode__c = null;
            }
            counter++;
        }
        database.insert(ords);
        
        Set<Id> ordIds = new Set<Id>();
        for(Order__c ordId: ords){
            ordIds.add(ordId.Id);
        }
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'check';
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Order_Number_1__c = ords[2].Id;
            sub.Billing_Type__c = 'Full Prepaid';
        }
        database.insert(subs);
        
        Map<Id, Id> billingAccountId_orderId = new Map<Id, Id>();
        billingAccountId_orderId.put(billAcc.Id, ords[2].Id);
    
        try{
            Test.setMock(WebServiceMock.class, new zLoginMock());
            test.startTest();
                BillingAccountHelper.updateBillingAccountToZuora(billingAccountId_orderId);
            test.stopTest();  
        }
        catch(Zuora.zAPIException e){}
    }
    
    static testmethod void testUpdateBillingAccountToZuoraAndSfdc(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        database.insert(con);
        
        Integer counter = 0;
        List<Order__c> ords = TestDataFactory.createOrder(10);
        for(Order__c ord: ords){
            ord.Account__c = acc.Id;
            ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            ord.Payment_Mode__c = 'Other';
            ord.Other_Payment_Mode__c = 'Invoice';
            ord.Create_ARMS_Customer_Account__c = true;
            //ord.Customer_No__c = '01';
            ord.Business_Profile__c = 'GOVT';
            //ord.Debt_Management_Treatment__c = '01';
            ord.Billing_Contact__c = con.Id;
            if(counter==0){
                ord.Create_ARMS_Customer_Account__c = false;    
            }
            else if(counter==9){
                ord.Payment_Mode__c = 'Cash';
                ord.Other_Payment_Mode__c = null;
            }
            counter++;
        }
        database.insert(ords);
        
        Set<Id> ordIds = new Set<Id>();
        for(Order__c ordId: ords){
            ordIds.add(ordId.Id);
        }
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'cheque';
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Order_Number_1__c = ords[2].Id;
            sub.Billing_Type__c = 'Full Prepaid';
        }
        database.insert(subs);
        
        Map<Id, Id> billingAccountId_orderId = new Map<Id, Id>();
        billingAccountId_orderId.put(billAcc.Id, ords[2].Id);
        
        Set<Id> billingAccountId = new Set<Id>();
        billingAccountId.add(billAcc.Id);
        
        Map<id, string> billId_ARMSAccountNumber =  new Map<id, string>();
        billId_ARMSAccountNumber.put(billAcc.Id, '');
        
        Map<id, string> billId_ARMSCustomerNumber =  new Map<id, string>();
        billId_ARMSCustomerNumber.put(billAcc.Id, '');
        
        Map<id, string> billId_CreatorID =  new Map<id, string>();
        billId_CreatorID.put(billAcc.Id, '');
        
        Map<id, string> billId_ARMSDebtManagement =  new Map<id, string>();
        billId_ARMSDebtManagement.put(billAcc.Id, '');
        
        Map<id, string> billId_ARMSBusinessProfile =  new Map<id, string>();
        billId_ARMSBusinessProfile.put(billAcc.Id, '');
        
        Map<id, string> billId_ARMSID =  new Map<id, string>();
        billId_ARMSID.put(billAcc.Id, '');
        
        Map<id, string> billId_CustGiroAcctNumber =  new Map<id, string>();
        billId_CustGiroAcctNumber.put(billAcc.Id, '');
        
        Map<id, string> billId_CustGiroBankNumber =  new Map<id, string>();
        billId_CustGiroBankNumber.put(billAcc.Id, '');
        
        Map<id, string> billId_CreditLimitExternal =  new Map<id, string>();
        billId_CreditLimitExternal.put(billAcc.Id, '2.2');
        
        Map<id, string> billId_CreditLimitInternal =  new Map<id, string>();
        billId_CreditLimitInternal.put(billAcc.Id, '3.3');
        
        Map<id, string> billId_CreditTermRefererence =  new Map<id, string>();
        billId_CreditTermRefererence.put(billAcc.Id, '3.3');
        
        try{
            Test.setMock(WebServiceMock.class, new zLoginMock());
            test.startTest();
                BillingAccountHelper.updateBillingAccountToZuoraAndSfdc(billingAccountId, billId_ARMSAccountNumber, billId_ARMSCustomerNumber, billId_CreatorID, billId_ARMSDebtManagement, billId_ARMSBusinessProfile, billId_ARMSID, billId_CustGiroAcctNumber, billId_CustGiroBankNumber, billId_CreditLimitExternal, billId_CreditLimitInternal, billId_CreditTermRefererence, billingAccountId_orderId);
            test.stopTest();  
        }
        catch(Zuora.zAPIException e){}   
    }
    
    static testmethod void testUpdateDefaultPaymentMethod(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        database.insert(con);
        
        Integer counter = 0;
        List<Order__c> ords = TestDataFactory.createOrder(10);
        for(Order__c ord: ords){
            ord.Account__c = acc.Id;
            ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            ord.Payment_Mode__c = 'Other';
            ord.Other_Payment_Mode__c = 'Invoice';
            ord.Create_ARMS_Customer_Account__c = true;
            //ord.Customer_No__c = '01';
            ord.Business_Profile__c = 'GOVT';
            //ord.Debt_Management_Treatment__c = '01';
            ord.Billing_Contact__c = con.Id;
            if(counter==0){
                ord.Create_ARMS_Customer_Account__c = false;    
            }
            else if(counter==9){
                ord.Payment_Mode__c = 'Cash';
                ord.Other_Payment_Mode__c = null;
            }
            counter++;
        }
        database.insert(ords);
        
        Set<Id> ordIds = new Set<Id>();
        for(Order__c ordId: ords){
            ordIds.add(ordId.Id);
        }
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'cheque';
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Order_Number_1__c = ords[2].Id;
            sub.Billing_Type__c = 'Full Prepaid';
        }
        database.insert(subs);
        
        Set<Id> billingAccountId_orderId = new Set<Id>();
        billingAccountId_orderId.add(billAcc.Id);
    
        test.startTest();
            try{
                BillingAccountHelper.updateDefaultPaymentMethod(billingAccountId_orderId);
            }
            catch(Zuora.zAPIException e){}
        test.stopTest();  
    }
}