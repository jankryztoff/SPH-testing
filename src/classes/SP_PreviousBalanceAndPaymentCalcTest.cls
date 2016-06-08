@isTest 
private class SP_PreviousBalanceAndPaymentCalcTest{
    static testMethod void testSP_PreviousBalanceAndPaymentCalculator() {
    
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
        
        List<Zuora__CustomerAccount__c> zcaList = TestDataFactory.createBillingAccount(1);
        for(Zuora__CustomerAccount__c billAcc: zcaList){
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Balance__c = 100;
        }
        database.insert(zcaList);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = zcaList[0].Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
         
        List<zqu__Quote__c> quoteList = TestDataFactory.createQuote(1);
        for(zqu__Quote__c zq: quoteList ){
        zq.zqu__Account__c = acc.id;
        zq.Order_Line_Item_Number_1__c = olis[0].id;
        zq.Order_Line_Item_Number__c = olis[0].id;
        }
        
        Database.insert(quoteList);
        
        List<zqu__QuoteCharge__c> zqCharge = TestDataFactory.createQuoteCharge(1);
        for(zqu__QuoteCharge__c zqc: zqCharge){
        zqc.zqu__Quote__c = quoteList[0].Id;
        }
        Database.insert(zqCharge);
        
        
        List<Zuora__Payment__c> zpc = TestDataFactory.createPayment(1);
        zpc[0].Zuora__BillingAccount__c = zcaList[0].Id;
        zpc[0].Zuora__Status__c = 'Processed';
        database.insert(zpc);
        
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test';
        zInvoice.Zuora__TotalAmount__c = 1.0;
        zInvoice.Total_Payment__c = 2.0;
        zInvoice.Zuora__Account__c = acc.id;
        zInvoice.Zuora__BillingAccount__c = zcaList[0].Id;
        Database.insert(zInvoice);   
        
        List<Zuora__PaymentInvoice__c> zpiList = TestDataFactory.createInvoicePayment(1);
        for(Zuora__PaymentInvoice__c zpi : zpiList){
        zpi.Zuora__Invoice__c = zInvoice.id;
        zpi.Zuora__Payment__c = zpc[0].id;
        }
        Database.insert(zpiList);   
        
        Set<Id> zcaId = new Set<Id>();
        for(Zuora__CustomerAccount__c billAcc: zcaList){
        zcaId.add(billAcc.Id);
        }
        
        
    
         test.startTest();
            SP_PreviousBalanceAndPaymentCalculator batch = new SP_PreviousBalanceAndPaymentCalculator();
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            batch.execute(BC, zcaList);
        test.stopTest();    
        }

        static testMethod void testSP_PreviousBalanceAndPaymentCalculator1() {
        try {
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
        
        Date xdate = System.Today();
        test.startTest();
            SP_PreviousBalanceAndPaymentCalculator batch1 = new SP_PreviousBalanceAndPaymentCalculator(xdate);
            database.executeBatch(batch1, 200);
        test.stopTest();
        
       } catch(Exception e){
       System.debug(e);
       }
        }
        
}