@isTest (seeAllData= true)
private class TEST_PdfCreationBatchTest{
    static testMethod void TestingTEST_PdfCreationBatch() {
    
        try{
         
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
        acc[0].Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc[0].id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc[0].Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc[0].id;
        ord.Order_Type__c = 'Change of Subscription'; 
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
         
           String User = '';
           String password1 = 'NewPass';
           String sessId = 'acc.id';
           Date prntletterbatchRun = Date.Today();
       
         test.startTest();
         
            TEST_PdfCreationBatch batch = new TEST_PdfCreationBatch(User, password1);
            TEST_PdfCreationBatch batch2 = new TEST_PdfCreationBatch(sessId, prntletterbatchRun);
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            batch.start(BC);
            batch.execute(BC, acc);
            batch.finish(BC);
        test.stopTest();   
        }catch(Exception e){
         System.debug(e);
        } 
        }
        
        static testMethod void TestingTEST_PdfCreationBatch2() {
    
         
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
        acc[0].Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc[0].id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc[0].Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc[0].id;
        ord.Order_Type__c = 'Change of Subscription'; 
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
         
           String User = '';
           String password1 = 'NewPass';
           String sessId = 'acc.id';
           Date prntletterbatchRun = Date.Today();
       
         test.startTest();
         
            TEST_PdfCreationBatch batch = new TEST_PdfCreationBatch(User, password1);
            TEST_PdfCreationBatch batch2 = new TEST_PdfCreationBatch(sessId, prntletterbatchRun);
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            batch.finish(BC);
        test.stopTest();    
        }
        
}