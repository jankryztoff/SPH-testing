@isTest
private class SP_PackingLabelAttachmentBatchTest3{
    static testMethod void testSP_PackingLabelAttachmentBatch(){
        //start custom settings
        List<Other__c> other = new List<Other__c>{new Other__c(Name = 'SP18_InitializedBatch', Value__c = '0'),
            new Other__c(Name = 'DTL', Value__c = '23:59')};
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name='Overseas'].Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.1';
        database.insert(sub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = sub.Id;
        database.insert(order);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:sub.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.Main_Package_Product_Sub_Type__c = 'Newspaper';
        database.insert(orderline);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Order_Line_Item_Number__c = orderline.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.1';
        subRecs.Delivered_By__c = 'Mailing Agent';
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Zuora__Account__c = acc.Id;
        database.insert(subRecs);
        
        Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
        pp.ZProduct__c = zProduct.Id;
        database.insert(pp);
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Issue_Date__c = date.today();
        packLabel.Subscription__c = subRecs.Id;
        packLabel.Mailing_Agent_Account_Number__c = '12356';
        database.insert(packLabel);
        //end test data
    
        test.startTest();
            SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch('', 2, '');
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();
    }
    
    static testMethod void testSP_PackingLabelAttachmentBatch2(){
        //start custom settings
        List<Other__c> other = new List<Other__c>{new Other__c(Name = 'SP18_InitializedBatch', Value__c = '0'),
            new Other__c(Name = 'DTL', Value__c = '23:59')};
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Airline_Indicator__c = true;
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name='Airline'].Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.1';
        database.insert(sub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = sub.Id;
        database.insert(order);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:sub.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.Main_Package_Product_Sub_Type__c = 'Newspaper';
        database.insert(orderline);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Order_Line_Item_Number__c = orderline.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.1';
        subRecs.Delivered_By__c = 'Mailing Agent';
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Zuora__Account__c = acc.Id;
        database.insert(subRecs);
        
        Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
        pp.ZProduct__c = zProduct.Id;
        database.insert(pp);
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Issue_Date__c = date.today();
        packLabel.Subscription__c = subRecs.Id;
        packLabel.Mailing_Agent_Account_Number__c = '12356';
        database.insert(packLabel);
        //end test data
    
        test.startTest();
            SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch('', 2, '');
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();
    }
       static testMethod void testSP_PackingLabelAttachmentBatchApril(){
        //start custom settings
        List<Other__c> other = new List<Other__c>{new Other__c(Name = 'SP18_InitializedBatch', Value__c = '0'),
            new Other__c(Name = 'DTL', Value__c = '23:59')};
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        acc.Airline_Indicator__c = true;
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name='Airline'].Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.1';
        database.insert(sub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = sub.Id;
        database.insert(order);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:sub.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Order_Line_Item_Number__c = orderline.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.1';
        subRecs.Delivered_By__c = 'Mailing Agent';
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Zuora__Account__c = acc.Id;
        database.insert(subRecs);
        
        Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
        pp.ZProduct__c = zProduct.Id;
        database.insert(pp);
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Issue_Date__c = date.today();
        packLabel.Subscription__c = subRecs.Id;
        packLabel.Mailing_Agent_Account_Number__c = '12356';
        database.insert(packLabel);
        //end test data
    
        Letter_Print_Batch__c letterPrint = new Letter_Print_Batch__c ();
        letterPrint.Initialization_Status__c = 'Active';
        letterPrint.Letter_Type__c = SP_GenerateLetterPrintBatch.packingLabelLetter;
        database.insert(letterPrint);
        
        DateTime datime =  date.today();
        String varString = ''+datime;
        String letterType = 'Packing_Label_Letter';
        Set<ID> setID = new Set<ID>();
        setID.add(packLabel.id);
        test.startTest();
            //SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch(varString ,'string', 2, 'string');
            SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch(varString ,letterType , 2, 'string',setID ); //april veloso 11252015
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();
    }
    static testMethod void testSP_PackingLabelAttachmentBatch3(){
        //start custom settings
        List<Other__c> other = new List<Other__c>{new Other__c(Name = 'SP18_InitializedBatch', Value__c = '0'),
            new Other__c(Name = 'DTL', Value__c = '23:59')};
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        acc.Airline_Indicator__c = true;
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name='Airline'].Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.1';
        database.insert(sub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = sub.Id;
        database.insert(order);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:sub.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Order_Line_Item_Number__c = orderline.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.1';
        subRecs.Delivered_By__c = 'Mailing Agent';
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Zuora__Account__c = acc.Id;
        database.insert(subRecs);
        
        Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
        pp.ZProduct__c = zProduct.Id;
        database.insert(pp);
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Issue_Date__c = date.today();
        packLabel.Subscription__c = subRecs.Id;
        packLabel.Mailing_Agent_Account_Number__c = '12356';
        database.insert(packLabel);
        //end test data
    
        test.startTest();
            SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch('', 2, '');
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();
    }
}