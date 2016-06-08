@isTest(SeeAllData=false)

private class SP_PackingLabelAttachmentBatchTest2{
    static testMethod void testSP_PackingLabelAttachmentBatch(){
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'),
            new Other__c(Name='SP18_InitializedBatch', Value__c='0')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.RecordTypeId = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Account' AND RecordType.Name = 'Direct Corporate'].Id;
        acc.RecordType = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Account' AND RecordType.Name = 'Direct Corporate'];
        acc.RecordType.Name = 'Direct Corporate';
        acc.Airline_Indicator__c = true;
        database.insert(acc);
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        acc2.RecordTypeId = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Account' AND RecordType.Name = 'Direct SPH Inter-Division'].Id;
        acc2.RecordType = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Account' AND RecordType.Name = 'Direct SPH Inter-Division'];
        acc2.RecordType.Name = 'Direct SPH Inter-Division';
        //acc2.Airline_Indicator__c = true;
        database.insert(acc2);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Address__C' AND RecordType.Name = 'Overseas'].Id;
        ad.RecordType = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Address__C' AND RecordType.Name = 'Overseas'];
        ad.RecordType.Name = 'Overseas';
        database.insert(ad);
        
        Address__c ad2 = TestDataFactory.createAddress(1)[0];
        ad2.RecordTypeId = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Address__C' AND RecordType.Name = 'Airline'].Id;
        ad2.RecordType = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Address__C' AND RecordType.Name = 'Airline'];
        ad2.RecordType.Name = 'Airline';
        database.insert(ad2);
        
        List<Contact> con = TestDataFactory.createContactRecType(2, 'Customer Contact');
        con[0].Address__c = ad.Id;
        con[1].Address__c = ad2.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
        ordLine.Order__c = ord.Id;
        ordLine.Main_Package_ID__c = pack.Id;
        database.insert(ordLine);
        
        counter=0;
        List<Zuora__Subscription__c> subs =  TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Order_Line_Item_Number__c = ordLine.Id;
            sub.Delivered_By__c = 'Mailing Agent';
            sub.Recipient_Contact__c = con[0].Id;
            sub.Zuora__Account__c = acc2.Id;
            if(counter==1){
                sub.Recipient_Contact__c = con[1].Id;
                sub.Zuora__Account__c = acc.Id;
            }
            counter++;
        }
        database.insert(subs);
        
        //Zuora__Subscription__c subsQ = [SELECT ];
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscription__c = subs[0].Id;
        database.insert(packLabel);
        
        Packing_Label_Batch__c packLabel1 = new Packing_Label_Batch__c();
        packLabel1.Subscription__c = subs[1].Id;
        database.insert(packLabel1);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        database.insert(zp);
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        database.insert(prp);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prp.Id;
        database.insert(pItem);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Type__c = 'N';
        database.insert(pub);
        
        //List<Product_Publication__c> proPub = TestDataFactory.createProductPublication(3);
        //for(Product_Publication__c pp : proPub){
            //pp.ZProduct__c = zp.Id;
            //pp.Publication_Code__c = pub.Id;
        //}
        Product_Publication__c proPub = TestDataFactory.createProductPublication(1)[0];
        proPub.ZProduct__c = zp.Id;
        proPub.Publication_Code__c = pub.Id;
        database.insert(proPub);
    
        test.startTest();
            SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch('lettertype', 2, 'sessionID');
            id batchID = database.executeBatch(batch, 200);
            system.assert(batchID <> null);
        test.stopTest();
    }
    
    static testMethod void testSP_PackingLabelAttachmentBatch2(){
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'),
            new Other__c(Name='SP18_InitializedBatch', Value__c='0')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.RecordTypeId = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Account' AND RecordType.Name = 'Direct Corporate'].Id;
        acc.RecordType = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Account' AND RecordType.Name = 'Direct Corporate'];
        acc.RecordType.Name = 'Direct Corporate';
        acc.Airline_Indicator__c = true;
        database.insert(acc);
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        acc2.RecordTypeId = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Account' AND RecordType.Name = 'Direct SPH Inter-Division'].Id;
        acc2.RecordType = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Account' AND RecordType.Name = 'Direct SPH Inter-Division'];
        acc2.RecordType.Name = 'Direct SPH Inter-Division';
        //acc2.Airline_Indicator__c = true;
        database.insert(acc2);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Address__C' AND RecordType.Name = 'Overseas'].Id;
        ad.RecordType = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Address__C' AND RecordType.Name = 'Overseas'];
        ad.RecordType.Name = 'Overseas';
        database.insert(ad);
        
        Address__c ad2 = TestDataFactory.createAddress(1)[0];
        ad2.RecordTypeId = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Address__C' AND RecordType.Name = 'Airline'].Id;
        ad2.RecordType = [SELECT Id, RecordType.Name FROM RecordType WHERE SObjectType = 'Address__C' AND RecordType.Name = 'Airline'];
        ad2.RecordType.Name = 'Airline';
        database.insert(ad2);
        
        List<Contact> con = TestDataFactory.createContactRecType(2, 'Customer Contact');
        con[0].Address__c = ad.Id;
        con[1].Address__c = ad2.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
        ordLine.Order__c = ord.Id;
        ordLine.Main_Package_ID__c = pack.Id;
        database.insert(ordLine);
        
        counter=0;
        List<Zuora__Subscription__c> subs =  TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Order_Line_Item_Number__c = ordLine.Id;
            sub.Delivered_By__c = 'Mailing Agent';
            sub.Recipient_Contact__c = con[0].Id;
            sub.Zuora__Account__c = acc2.Id;
            if(counter==1){
                sub.Recipient_Contact__c = con[1].Id;
                sub.Zuora__Account__c = acc.Id;
            }
            counter++;
        }
        database.insert(subs);
        
        //Zuora__Subscription__c subsQ = [SELECT ];
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscription__c = subs[0].Id;
        database.insert(packLabel);
        
        Packing_Label_Batch__c packLabel1 = new Packing_Label_Batch__c();
        packLabel1.Subscription__c = subs[1].Id;
        database.insert(packLabel1);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        database.insert(zp);
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        database.insert(prp);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prp.Id;
        database.insert(pItem);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Type__c = 'M';
        database.insert(pub);
        
        //List<Product_Publication__c> proPub = TestDataFactory.createProductPublication(3);
        //for(Product_Publication__c pp : proPub){
            //pp.ZProduct__c = zp.Id;
            //pp.Publication_Code__c = pub.Id;
        //}
        Product_Publication__c proPub = TestDataFactory.createProductPublication(1)[0];
        proPub.ZProduct__c = zp.Id;
        proPub.Publication_Code__c = pub.Id;
        database.insert(proPub);
    
        test.startTest();
            SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch('lettertype', 2, 'sessionID');
            id batchID = database.executeBatch(batch, 200);
            system.assert(batchID <> null);
        test.stopTest();
    }
}