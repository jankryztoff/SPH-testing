@isTest
private class BT_AB_HDS038DX_ChangeOfAddressTest{
    static testMethod void testBT_AB_HDS038DX_ChangeOfAddress(){
        //custom settings setup 
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
        
        //create account
        //Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        //create address
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.id;
        database.insert(con);
        
  /**    //create case
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        //cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
        cas.Change_of_Address_Type__c = 'Change of Vendor';
        cas.Effective_Date__c = date.today()+1;
        cas.Contact_To_Update__c = con.id; //added
        cas.Subscription_Name__c = 
        cas.Vendor__c = acc.id; //added
        cas.Status = 'Closed';
        database.insert(cas); 
        
        //create address assignment
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Address__c = ad.Id;
        aa.Vendor__c = acc.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = date.today()+1;
        database.insert(aa);  **/
        
        //create billing account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
         
        //create zProduct
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        //zp.ProductFamily__c = 'BH';
        zp.ProductFamily__c = '01';
        database.insert(zp);
         
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        //create subscription
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Account__c = acc.id;
            sub.Main_Package__c = pack.Id;
            sub.Recipient_Contact__c = con.id;
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Product_Code__c = '01';
            sub.Zuora__SubscriptionStartDate__c = date.today()-10;
            sub.Term_Length__c = 1;
            sub.Term_Length1__c = '1';
        }
        database.insert(subs);
              
              
        //create case
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        //cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
        cas.Account__c = acc.id;
        cas.Change_of_Address_Type__c = 'Change of Vendor';
        cas.Effective_Date__c = date.today()+1;
        cas.Contact_To_Update__c = con.id; //added
        cas.Subscription_Name__c = subs[0].id;
        cas.Vendor__c = acc.id; //added
        cas.Status = 'Closed';
        database.insert(cas); 
        
        //create address assignment
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Address__c = ad.Id;
        aa.Vendor__c = acc.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = date.today()+1;
        database.insert(aa);
        
          //create case subscription
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(2);
        for(Case_Subscription__c cs: caseSubs){
            cs.Case__c = cas.Id;
            cs.Address__c = ad.id;
            cs.Account__c = acc.id;
            cs.Subscription__c = subs[0].Id;
            cs.isComplaint__c = true;
        }
        database.insert(caseSubs);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        pf.Product_Family__c = '01';
        database.insert(pf);
        
        //create publication
        List<Publication__c> pub = TestDataFactory.createPublication(1);
        //Publication__c pub = TestDataFactory.createPublication(1)[0];
        for(Publication__c pubs : pub) {
        pubs.Name = 'TestPub';
        pubs.Publication_Code__c = '01';
        pubs.Product_Family__c = '01';
        //pubs.Product_Family__c = 'BH';
        pubs.Platform_Type__c = 'Print';
        pubs.Publication_Type__c = 'N';
        pubs.Product_Family_Lookup__c = pf.Id;
        }
        database.insert(pub);
        
        Publication__c pubQ = [SELECT Product_Family__c FROM Publication__c WHERE Id=:pub[0].Id];
        Case_Subscription__c csQ = [SELECT Subscription__r.Product_Code__c FROM Case_Subscription__c WHERE Id=:caseSubs[0].Id];
        zqu__ZProduct__c zpQ = [SELECT ProductCode__c, ProductFamily__c FROM zqu__ZProduct__c WHERE id=:zp.Id];
        
        system.assertEquals(pubQ.Product_Family__c, '01');
        system.assertEquals(csQ.Subscription__r.Product_Code__c, '01');
        system.assertEquals(zpQ.ProductCode__c, '01');
        system.assertEquals(zpQ.ProductFamily__c, '01');
        
          List <Product_Publication__c> proPub =TestDataFactory.createProductPublication(1);
        for(Product_Publication__c pp: proPub) {
        pp.ZProduct__c = zp.Id; //zproduct   
        pp.Publication_Code__c = pub[0].id;    
        }
          insert proPub;
        
        //create product rate plan
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        database.insert(prp);
        
        //create product rate plan charge
        zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.PublicationCode__c = '01';
        database.insert(prpc);
        
        //create package item
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prp.Id;
        database.insert(pItem);
        
        //test
        test.startTest();
            BT_AB_HDS038DX_ChangeOfAddress batch = new BT_AB_HDS038DX_ChangeOfAddress();
            Id batchID = database.executeBatch(batch, 200);
            system.assert(batchID <> null);
        test.stopTest();
    }
    
    static testMethod void testBT_AB_HDS038DX_ChangeOfAddress2(){
        //custom settings setup 
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
        
        //create account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        //create address
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        database.insert(con);
        
       
         //create billing account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
         
        //create zProduct
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        zp.ProductFamily__c = '01';
        database.insert(zp);
         
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        //create subscription
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack.Id;
            sub.Main_Package_1__c = pack.Id; //jams10152015
            sub.Product_Code__c = '01';
            sub.Zuora__SubscriptionStartDate__c = date.today()+1;
        }
        database.insert(subs);
        
        //create case
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local'; 
        cas.Effective_Date__c = date.today()+3; 
        cas.Subscription_Name__c = subs[0].id; //jams10152015
        cas.Status = 'Closed';
        database.insert(cas);
             
        //create address assignment
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Address__c = ad.Id;
        aa.Vendor__c = acc.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = date.today()+1;
        database.insert(aa);
        
        
        //create case subscription
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(2);
        for(Case_Subscription__c cs: caseSubs){
            cs.Case__c = cas.Id;
            cs.Subscription__c = subs[0].Id;
        }
        database.insert(caseSubs);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        pf.Product_Family__c = '01';
        database.insert(pf);
        
        //create publication
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        pub.Product_Family__c = '01';
        pub.Platform_Type__c = 'Print';
        pub.Publication_Type__c = 'N';
        pub.Product_Family_Lookup__c = pf.Id;
        database.insert(pub);
        
        //create product rate plan
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        database.insert(prp);
        
        //create product rate plan charge
        zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.PublicationCode__c = '01';
        database.insert(prpc);
        
        //create package item
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prp.Id;
        database.insert(pItem);
        
        //test
        test.startTest();
            BT_AB_HDS038DX_ChangeOfAddress batch = new BT_AB_HDS038DX_ChangeOfAddress();
            Id batchID = database.executeBatch(batch, 200);
            system.assert(batchID <> null);
        test.stopTest();
    }
        static testMethod void newTest(){
          //custom settings setup 
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
            database.insert(acc);
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordtypeId = [SELECT Id, Name from RecordType Where Name = 'Internal'].id;
            database.insert(ad);
            
             //create contact
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = ad.id;
            con.RecordTypeId = [SELECT Id From RecordType WHERE sObjectType = 'Contact' and Name ='Customer Contact'].id;
            database.insert(con);
            
            Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
            cas.AccountId = acc.id;
            database.insert(cas); 
            
            Address_Assignment__c aa = new Address_Assignment__c();
            aa.Case__c = cas.Id;
            aa.Address__c = ad.Id;
            aa.Vendor__c = acc.Id;
            aa.Contact__c = con.Id;
            aa.Effective_Date__c = date.today();
            database.insert(aa);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            database.insert(billAcc);
            
            zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
            zp.ProductCode__c = '02';
            zp.ProductFamily__c = 'BT';
            database.insert(zp);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            database.insert(pack);
            
            List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(1);
            for(Zuora__Subscription__c sub: subs){
            sub.Name = acc.id;
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Account__c = acc.id;
            sub.Main_Package__c = pack.Id;
            sub.Recipient_Contact__c = con.id;
            sub.Product_Code__c = '02';
            sub.Zuora__Status__c = 'Active';
            }
            database.insert(subs);
            
            cas.Subscription_Name__c = subs[0].id;
            database.update(cas);
            
            List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(1);
            for(Case_Subscription__c cs: caseSubs){
            cs.Case__c = cas.Id;
            cs.Account__c = acc.id;
            cs.isComplaint__c = False;
            cs.Address__c = ad.id;
            cs.Subscription__c = subs[0].Id;
            }
            database.insert(caseSubs);

            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Product_Family__c = '02';
            pub.Name = '';
            database.insert(pub);
            
            List <Product_Publication__c> proPub =TestDataFactory.createProductPublication(1);
            for(Product_Publication__c pp: proPub) {
            pp.ZProduct__c = zp.Id; //zproduct   
            pp.Publication_Code__c = pub.id;    
            }
            insert proPub;
            
            zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
            prp.zqu__ZProduct__c = zp.Id;
            database.insert(prp);
            
            zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prp.Id;
            database.insert(prpc);
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prp.Id;
            database.insert(pItem);
            
            
            test.startTest();
            BT_AB_HDS038DX_ChangeOfAddress batch = new BT_AB_HDS038DX_ChangeOfAddress();
            Id batchID = database.executeBatch(batch, 200);
            system.assert(batchID <> null);
            test.stopTest();
            }
            
        static testMethod void newTest02(){

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
        
        //create account
        //Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        //create address
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.id;
        database.insert(con);
                
        //create billing account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
         
        //create zProduct
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductType__c = 'Product';
        zp.ProductCode__c = 'BT';
        zp.ProductFamily__c = 'BT';
        database.insert(zp);
         
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        //create subscription        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Account__c = acc.id;
            sub.Main_Package__c = pack.Id;        
            sub.Main_Package_1__c = pack.Id;
            sub.Recipient_Contact__c = con.id;
            sub.Frequency_1__c = 'Mon-Fri';
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__SubscriptionStartDate__c = date.today()-10;
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Term_Length__c = 1;
            sub.Term_Length1__c = '1';
            sub.Product_Code__c = 'BT';
        }
        database.insert(subs);
              
        //create case
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cas.Account__c = acc.id;
        cas.Change_of_Address_Type__c = 'Change of Vendor';
        cas.Effective_Date__c = date.today()+1;
        cas.Contact_To_Update__c = con.id; //added
        cas.Subscription_Name__c = subs[0].id;
        cas.Vendor__c = acc.id; //added
        cas.Status = 'Closed';
        database.insert(cas); 
        
        //create address assignment
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Address__c = ad.Id;
        aa.Vendor__c = acc.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = date.today()+1;
        database.insert(aa);
        
          //create case subscription
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(2);
        for(Case_Subscription__c cs: caseSubs){
            cs.Case__c = cas.Id;
            cs.Address__c = ad.id;
            cs.Account__c = acc.id;
            cs.Subscription__c = subs[0].Id;
            cs.isComplaint__c = true;
        }
        database.insert(caseSubs);
        
        //create publication
         List<Publication__c> pub = TestDataFactory.createPublication(1);
        //Publication__c pub = TestDataFactory.createPublication(1)[0];
        for(Publication__c pubs : pub) {
        pubs.Name = 'TestPub';
        pubs.Publication_Code__c = 'BH';
        pubs.Product_Family__c = 'BT';
        pubs.Published_Days__c = 'YYYYYNN';
        pubs.Platform_Type__c = 'Print';
        pubs.Publication_Type__c = 'N';
        }
        database.insert(pub);
        
        
        List <Product_Publication__c> proPub =TestDataFactory.createProductPublication(1);
        for(Product_Publication__c pp: proPub) {
        pp.ZProduct__c = zp.Id; //zproduct   
        pp.Publication_Code__c = pub[0].id;    
        }
          insert proPub;
        
        //create product rate plan
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        database.insert(prp);
        
        //create product rate plan charge
        zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.PublicationCode__c = '01';
        database.insert(prpc);
        
        //create package item
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prp.Id;
        database.insert(pItem);
        
        //test
        test.startTest();
            BT_AB_HDS038DX_ChangeOfAddress batch = new BT_AB_HDS038DX_ChangeOfAddress();
            Id batchID = database.executeBatch(batch, 200);
            system.assert(batchID <> null);
        test.stopTest();
        }
}