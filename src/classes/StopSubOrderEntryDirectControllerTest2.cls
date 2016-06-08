@isTest
private class StopSubOrderEntryDirectControllerTest2{

    @testSetup static void methodName() {
        Key_Id__c CS_keyId = new Key_Id__c();
        CS_keyId.Name = 'Package Item_Base Product';
        CS_keyId.Type__c = 'RecordType';
        CS_keyId.Id__c = '01290000001AgHhAAK';
        database.insert(CS_keyId);

        /*List<Key_Id__c> cSet = new List<Key_Id__c>();
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        List<Key_Id__c> keyList = [SELECT Name FROM Key_Id__c];
        Set<String> keyNames = new Set<String>();
        for(Key_Id__c keyRec : keyList) {
            keyNames.add(keyRec.Name);
        }
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            if(!keyNames.contains(keyIdNameArray[i])) {
                Key_Id__c keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
                cSet.add(keyId);
            }
        }
        insert cSet;*/

        
    }

    static testMethod void testStopSubOrderEntryDirectController(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);

        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        //prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cas.Status = 'Closed';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.publication_code__c = '01';
        database.insert(pub);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            cont.getOrder();
            
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
        test.stopTest();
    }
    
    static testMethod void testStopSubOrderEntryDirectControllerb(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        //prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cas.Status = 'Closed';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.publication_code__c = '01';
        database.insert(pub);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub); 
        //end test data 
        
        List<Order__c> order = TestDataFactory.createOrder(2);
            order[0].Account__c = acc.Id;
            order[0].case_record_type__c = 'Stop Subscription';
            order[0].status__c = 'Draft';
            order[0].Base_Subscription__c = subRecs.Id;
            order[1].Account__c = acc.Id;
            order[1].case_record_type__c = 'Stop Subscription';
            order[1].status__c = 'New';
            order[1].Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.order__c = order[0].Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            orderline.amount_to_refund__c = 10;
            database.insert(orderline); 
            
    
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('PARAMETER_ORDERID', order[0].ID);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            
            
           
            cont.getOrder();
            cont.getOli();
            
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.getSubscriptions();
            
        test.stopTest();
    }
    
    static testMethod void testStopSubOrderEntryDirectController2(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        //prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cas.Status = 'Closed';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            cont.getOrder();
            
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
        test.stopTest();
    }
    
    
    
    static testMethod void NewTest(){
        /*
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        

        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Add On';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    String subID1 = 'subRecs.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.subscription = subName1;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);           
            cont.isSRDValid(oliwrap1List);
            cont.checkRetention();
            cont.getGivenCopies(oliwrap1);
            cont.getSubStartDate(subID1);
            cont.getAdminFee(oliwrap1);
            cont.getRefund(oliwrap1);
            cont.getMissedCopies(oliwrap1);
            cont.removeSubscriptionRecord();
            cont.removeSubscriptionFromDB(oliwrap1List);
            cont.doSave();
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1; 
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 1.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
        */
    }
    
    static testMethod void NewTestI(){
        /*
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
    
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Add On';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    String subID1 = 'subRecs.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = pack.id;
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.subscription = subName1;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);           
            cont.isSRDValid(oliwrap1List);
            cont.checkRetention();
            cont.getGivenCopies(oliwrap1);
            cont.getSubStartDate(subID1);
            cont.getAdminFee(oliwrap1);
            cont.getRefund(oliwrap1);
            cont.getMissedCopies(oliwrap1);
            cont.removeSubscriptionRecord();
            cont.removeSubscriptionFromDB(oliwrap1List);
            cont.doSave();
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1; 
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 1.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
        */
    }
    
    static testMethod void NewTesth(){
        /*
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Add On';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    String subID1 = 'subRecs.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Date datetoday = date.today().addDays(7);
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            orderline.stop_request_date__c = date.today().addDays(5);
            database.insert(orderline);
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.id = subrecs.id;
            oliwrap1.oliFieldAccess = orderline;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);
            cont.relatedSubscriptionResultList = oliwrap1List;          
            //cont.isSRDValid(oliwrap1List);
            //cont.checkRetention();
            //cont.getGivenCopies(oliwrap1);
            //cont.getSubStartDate(subID1);
            //cont.getAdminFee(oliwrap1);
            cont.getRefund(oliwrap1);
            //cont.getMissedCopies(oliwrap1);
            //cont.removeSubscriptionRecord();
            //cont.removeSubscriptionFromDB(oliwrap1List);
            //cont.doSave();
            
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1;
            subwrap1.startDate = datetoday.toStartofMonth();
            subwrap1.packageBillingType = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 1.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
        */
    }
    
     static testMethod void NewTesth2(){
         /*
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Add On';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    String subID1 = 'subRecs.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Date datetoday = date.today().addDays(7);
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            orderline.stop_request_date__c = date.today().addDays(5);
            orderline.Fee_Override__c = true;
            database.insert(orderline);
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.id = subrecs.id;
            oliwrap1.oliFieldAccess = orderline;
            oliwrap1.feeOverride = orderline.Fee_Override__c; 
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);
            cont.relatedSubscriptionResultList = oliwrap1List;          
            //cont.isSRDValid(oliwrap1List);
            //cont.checkRetention();
            //cont.getGivenCopies(oliwrap1);
            //cont.getSubStartDate(subID1);
            //cont.getAdminFee(oliwrap1);
            cont.getRefund(oliwrap1);
            //cont.getMissedCopies(oliwrap1);
            //cont.removeSubscriptionRecord();
            //cont.removeSubscriptionFromDB(oliwrap1List);
            //cont.doSave();
            
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1;
            subwrap1.startDate = datetoday.toStartofMonth();
            subwrap1.packageBillingType = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 1.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
        */
    }
    
    static testMethod void NewTest_j(){
        /*
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Add On';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'Closed';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        
        database.insert(subRecs);
        
        
        
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    String subID1 = 'subRecs.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        test.startTest();
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            //cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Date datetoday = date.today().addDays(7);
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            
            orderline.stop_request_date__c = date.today().addDays(5);
            database.insert(orderline);
            
            //cont.getOrder();
            //cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            //cont.setSubscriptionRecords();
            //cont.isNoOpenCaseForSub(subName1);
            //cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.id = null;
            //oliwrap1.oliFieldAccess = orderline;
            //cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);
            cont.relatedSubscriptionResultList = oliwrap1List; 
            
            cont.setSubscriptionRecords();   
             
             
            //cont.checkDuplicateSubscription('subRecs.Id');      
            //cont.isSRDValid(oliwrap1List);
            //cont.checkRetention();
            //cont.getGivenCopies(oliwrap1);
            //cont.getSubStartDate(subID1);
            //cont.getAdminFee(oliwrap1);
            //cont.getRefund(oliwrap1);
            //cont.getMissedCopies(oliwrap1);
            //cont.removeSubscriptionRecord();
            //cont.removeSubscriptionFromDB(oliwrap1List);
            //cont.doSave();
            orderline.subscription__c = subRecs.Id;
            update orderline;
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1;
            subwrap1.startDate = datetoday.toStartofMonth();
            subwrap1.packageBillingType = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            //cont.allSubscriptionResultList = subwrap1List;
            //cont.createRecord(oliwrap1, subwrap1);
            //cont.saveAsDraft();
           // cont.doCancel();
            //cont.feeOverrideAmountCompare = 1.0;
           // cont.feeAdminAmountCompare = 1.0;
            //cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            //cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            //cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            //cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            //cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
           // cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
        */
    }
    
    static testMethod void NewTest_k(){
        /*
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE;
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'Closed';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        subRecs.Bundled_With__c = 'bun';
        database.insert(subRecs);
        
        
        
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    String subID1 = 'subRecs.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        test.startTest();
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            //cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Date datetoday = date.today().addDays(7);
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            
            orderline.stop_request_date__c = date.today().addDays(5);
            database.insert(orderline);
            
            subrecs.Order_Number_1__c = order.id;
            subrecs.Order_Number__c = order.id;
            update subrecs;
            
            //cont.getOrder();
            //cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            //cont.setSubscriptionRecords();
            //cont.isNoOpenCaseForSub(subName1);
            //cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.id = null;
            oliwrap1.orderNumber = order.id;
            oliwrap1.bundledWith = subrecs.Bundled_With__c;
            //oliwrap1.oliFieldAccess = orderline;
            //cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);
            cont.relatedSubscriptionResultList = oliwrap1List; 
            
            cont.setSubscriptionRecords();   
             
             
            //cont.checkDuplicateSubscription('subRecs.Id');      
            //cont.isSRDValid(oliwrap1List);
            //cont.checkRetention();
            //cont.getGivenCopies(oliwrap1);
            //cont.getSubStartDate(subID1);
            //cont.getAdminFee(oliwrap1);
            //cont.getRefund(oliwrap1);
            //cont.getMissedCopies(oliwrap1);
            //cont.removeSubscriptionRecord();
            //cont.removeSubscriptionFromDB(oliwrap1List);
            //cont.doSave();
            orderline.subscription__c = subRecs.Id;
            update orderline;
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1;
            subwrap1.startDate = datetoday.toStartofMonth();
            subwrap1.packageBillingType = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            //cont.allSubscriptionResultList = subwrap1List;
            //cont.createRecord(oliwrap1, subwrap1);
            //cont.saveAsDraft();
           // cont.doCancel();
            //cont.feeOverrideAmountCompare = 1.0;
           // cont.feeAdminAmountCompare = 1.0;
            //cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            //cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            //cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            //cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            //cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
           // cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
        */
    }
    
    static testMethod void NewTestb(){
        /*
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Add On';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    //String subName1 = subRecs.Name;
    String subName1 = 'subrecstest';
    //String subID1 = 'subRecs.id';
    String subID1 = 'caseSub.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.subscription = subName1;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);           
            cont.isSRDValid(oliwrap1List);
            cont.checkRetention();
            cont.getGivenCopies(oliwrap1);
            cont.getSubStartDate(subID1);
            cont.getAdminFee(oliwrap1);
            cont.getRefund(oliwrap1);
            cont.getMissedCopies(oliwrap1);
            cont.removeSubscriptionRecord();
            cont.removeSubscriptionFromDB(oliwrap1List);
            cont.doSave();
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1; 
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 1.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
        */
    }
    
    static testMethod void NewTestc(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Bundle';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);

        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        //prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);

        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Bundle Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        spc.PublicationCode__c = 'test';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    //String subName1 = subRecs.Name;
    String subName1 = 'subrecstest';
    //String subID1 = 'subRecs.id';
    String subID1 = 'caseSub.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            subRecs.Order_Line_Item_Number_1__c = orderline.id;
            subRecs.Order_Line_Item_Number__c = orderline.id;
            update subRecs;
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.subscription = subName1;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);           
            cont.isSRDValid(oliwrap1List);
            cont.checkRetention();
            cont.getGivenCopies(oliwrap1);
            cont.getSubStartDate(subID1);
            cont.getAdminFee(oliwrap1);
            cont.getRefund(oliwrap1);
            cont.getMissedCopies(oliwrap1);
            cont.removeSubscriptionRecord();
            cont.removeSubscriptionFromDB(oliwrap1List);
            cont.doSave();
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1; 
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 1.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
    }
    
    static testMethod void NewTestd(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        spc.PublicationCode__c = 'test';
        spc.Zuora__Model__c = 'NewModel';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    //String subName1 = 'subrecstest';
    //String subName1 = subrecs.id;
    //String subID1 = 'subRecs.id';
    String subID1 = 'caseSub.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
            test.startTest();
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            subRecs.Order_Line_Item_Number_1__c = orderline.id;
            subRecs.Order_Line_Item_Number__c = orderline.id;
            update subRecs;
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.subscription = subName1;
            oliwrap1.id = subrecs.id;
            //oliwrap1.subscription = subrecs.id;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);           
            cont.isSRDValid(oliwrap1List);
            cont.checkRetention();
            cont.getGivenCopies(oliwrap1);
            cont.getSubStartDate(subID1);
            cont.getAdminFee(oliwrap1);
            
            //cont.getRefund(oliwrap1);
            cont.getMissedCopies(oliwrap1);
            cont.removeSubscriptionRecord();
            //cont.removeSubscriptionFromDB(oliwrap1List);
            //cont.getPublication12OLIWrap(oliwrap1);
            cont.doSave();
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1; 
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            //cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 1.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            //cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            //cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            //cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            //cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
    }
    
    static testMethod void NewTeste(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        spc.PublicationCode__c = 'test';
        spc.Zuora__Model__c = 'NewModel';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    //String subName1 = 'subrecstest';
    //String subName1 = subrecs.id;
    //String subID1 = 'subRecs.id';
    String subID1 = 'caseSub.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
            test.startTest();
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            
            cont.getOrder();
            /*
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas); **/
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            /*
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            subRecs.Order_Line_Item_Number_1__c = orderline.id;
            subRecs.Order_Line_Item_Number__c = orderline.id;
            update subRecs; **/
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.subscription = subName1;
            oliwrap1.id = subrecs.id;
            //oliwrap1.subscription = subrecs.id;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);           
            cont.isSRDValid(oliwrap1List);
            cont.checkRetention();
            cont.getGivenCopies(oliwrap1);
            cont.getSubStartDate(subID1);
            cont.getAdminFee(oliwrap1);
            
            //cont.getRefund(oliwrap1);
            cont.getMissedCopies(oliwrap1);
            cont.removeSubscriptionRecord();
            //cont.removeSubscriptionFromDB(oliwrap1List);
            //cont.getPublication12OLIWrap(oliwrap1);
            cont.doSave();
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1; 
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            //cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 1.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            //cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            //cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            //cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            //cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
    }
    
    static testMethod void NewTestf(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        spc.PublicationCode__c = 'test';
        spc.Zuora__Model__c = 'NewModel';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    //String subName1 = 'subrecstest';
    //String subName1 = subrecs.id;
    //String subID1 = 'subRecs.id';
    String subID1 = 'caseSub.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
            test.startTest();
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            
            cont.getOrder();
            /*
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas); **/
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            /*
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
            subRecs.Order_Line_Item_Number_1__c = orderline.id;
            subRecs.Order_Line_Item_Number__c = orderline.id;
            update subRecs; **/
            
            cont.getOrder();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = subRecs.Id;
            cont.setSubscriptionRecords();
            cont.isNoOpenCaseForSub(subName1);
            cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.subscription = subName1;
            oliwrap1.id = subrecs.id;
            //oliwrap1.subscription = subrecs.id;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);           
            cont.isSRDValid(oliwrap1List);
            cont.checkRetention();
            cont.getGivenCopies(oliwrap1);
            cont.getSubStartDate(subID1);
            cont.getAdminFee(oliwrap1);
            
            //cont.getRefund(oliwrap1);
            cont.getMissedCopies(oliwrap1);
            cont.removeSubscriptionRecord();
            //cont.removeSubscriptionFromDB(oliwrap1List);
            //cont.getPublication12OLIWrap(oliwrap1);
            cont.doSave();
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1; 
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            //cont.saveAsDraft();
            cont.doCancel();
            cont.feeOverrideAmountCompare = 2.0;
            cont.feeAdminAmountCompare = 1.0;
            cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            //cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            //cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            //cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            //cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
    }
    
    static testMethod void NewTestg(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cas.AccountId = acc.id;
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today().addDays(2);
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Test';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        spc.PublicationCode__c = 'test';
        spc.Zuora__Model__c = 'NewModel';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        caseSub.Complaint_Copies__c = 12;
        database.insert(caseSub);
        //end test data 
    
    String subName1 = subRecs.Name;
    //String subName1 = 'subrecstest';
    //String subName1 = subrecs.id;
    //String subID1 = 'subRecs.id';
    String subID1 = 'caseSub.id';
    String billingAccount1 = 'billAcc.id';
    String packid1 = 'pack.id';
        
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
            test.startTest();
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            
            cont.getOrder();
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas); 
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            orderline.stop_request_date__c = date.today().addDays(2);
            database.insert(orderline);
            
            subRecs.Order_Line_Item_Number_1__c = orderline.id;
            subRecs.Order_Line_Item_Number__c = orderline.id;
            update subRecs; 
            
            //cont.getOrder();
            //cont.checkDuplicateSubscription('subRecs.Id');
            //cont.myId = subRecs.Id;
            //cont.setSubscriptionRecords();
            //cont.isNoOpenCaseForSub(subName1);
            //cont.getSelectedSubscription();
            StopSubOrderEntryDirectController.OrderLineItemWrapper oliwrap1 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            oliwrap1.subscription = subName1;
            oliwrap1.id = subrecs.id;
            oliwrap1.oliFieldAccess = orderline;
            //oliwrap1.subscription = subrecs.id;
            cont.isSRDValid(oliwrap1); 
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(oliwrap1);           
            //cont.isSRDValid(oliwrap1List);
            cont.checkRetention();
            //cont.getGivenCopies(oliwrap1);
            //cont.getSubStartDate(subID1);
            //cont.getAdminFee(oliwrap1);
            cont.checkExistingCOA(oliwrap1);
            
            //cont.getRefund(oliwrap1);
            //cont.getMissedCopies(oliwrap1);
            //cont.removeSubscriptionRecord();
            //cont.removeSubscriptionFromDB(oliwrap1List);
            //cont.getPublication12OLIWrap(oliwrap1);
            //cont.doSave();
            List<Case_Subscription__c> cassublist = new List<Case_Subscription__c>();
            cassublist.add(caseSub);
            
            StopSubOrderEntryDirectController.SubscriptionWrapper subwrap1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            subwrap1.billingAccount = billingAccount1; 
            List<StopSubOrderEntryDirectController.SubscriptionWrapper> subwrap1List = new List<StopSubOrderEntryDirectController.SubscriptionWrapper>();
            cont.allSubscriptionResultList = subwrap1List;
            cont.createRecord(oliwrap1, subwrap1);
            cont.countMissedCopies(cassublist);
            //cont.saveAsDraft();
            //cont.doCancel();
            //cont.feeOverrideAmountCompare = 2.0;
            //cont.feeAdminAmountCompare = 1.0;
            //cont.checkIfAllowableAmount();

            
           
            //To do Jams
            try{
            cont.getPublication12OLIWrap(oliwrap1);
            }catch(Exception e){
            } 
            try{
            //cont.getPublication(oliwrap1);
             }catch(Exception e){
            }
            try{
            //cont.isSRDValid(oliwrap1, nonPubList);
             }catch(Exception e){
            }
            try{
            //cont.earliestStart(packid1); 
             }catch(Exception e){
            }
            try{
            //cont.activateMaps(packid1); 
             }catch(Exception e){
            }
        test.stopTest();
    }
    
    
    
    
    
      static testMethod void NewTest2(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
                
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Name';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
                
        List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__Model__c = 'NewModel';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        spcList.add(spc);
        system.AssertNotEquals(spcList.size(), 0);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = spc.Zuora__ProductSKU__c;
        database.insert(zProduct);
        
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        //prdRatePlan[0].RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name= 'Name';
        prdRatePlan.zqu__Deleted__c = zProduct.zqu__Deleted__c;
        prdRatePlan.RatePlanType__c = 'Proration';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.zqu__EffectiveStartDate__c = date.Today();
        prdRatePlan.zqu__EffectiveEndDate__c = date.Today()+1;
        prdRatePlan.zqu__ZuoraId__c = [SELECT zqu__ZuoraId__c FROM zqu__ZProduct__c WHERE Id =: zProduct.id].id;
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
        
        //end test data 
        
    String subName1 = subRecs.Name;
    
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            StopSubOrderEntryDirectController.SubscriptionWrapper cont1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            StopSubOrderEntryDirectController.OrderLineItemWrapper cont2 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            cont2.subscription = 'subRecs.id';
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(cont2);    
            StopSubOrderEntryDirectController.AsiaRelatedListWrapper cont3 = new StopSubOrderEntryDirectController.AsiaRelatedListWrapper();
            cont.objcase = cas;
            cont.accountBackUp = acc;
            cont.date1 = date.Today();
            cont.publicationRec = pub[0];
            cont.caseRecordType = '';
            cont.category = '';
            cont.subCategory= '';
            cont.status= '';
            cont.caseOwner= '';
            cont.orderNumber= '';
            cont.subscriberAccount= '';
            cont.recipientName = '';
            cont1.tempStartDate = '';
            cont1.tempEndDate= '';
            cont1.tempStartDate = '';
            cont1.tempContractEnd= '';
            cont1.earliestStopDate = date.Today()+1;
            cont2.zuoraId = '';
            cont2.terminationReason= '';
            cont2.stopRequestDate = date.Today()+1;
            cont2.feeOverrideAmountHidden = 1.0;
            cont2.feeOverrideCheck = true;
            cont2.mainPackageName = '';
            cont2.contractEndDate = date.Today();
            cont2.prompt = true;
            cont2.copiesgiven = 1;
            cont2.copiesmissed = 1.0;
            cont2.amountpaid = 1.0;
            cont2.percopyrate = 1.0;
            cont2.others = 1.0;
            cont3.id = '';
            cont3.userId = '';
            cont3.serviceFlag = '';
            cont3.status = '';
            cont3.asiaSubscription = '';
            cont3.quantity = 1.0;
            
            
            
            test.stopTest();
         } 
        /* 
      static testMethod void NewTest3(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Add On';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
                
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Status = 'New';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Name = 'Name';
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
                
        List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__Model__c = 'NewModel';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        spcList.add(spc);
        system.AssertNotEquals(spcList.size(), 0);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = spc.Zuora__ProductSKU__c;
        database.insert(zProduct);
        
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        //prdRatePlan[0].RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name= 'Name';
        prdRatePlan.zqu__Deleted__c = zProduct.zqu__Deleted__c;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.RatePlanSubType__c = 'Standard';
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.zqu__EffectiveStartDate__c = date.Today();
        prdRatePlan.zqu__EffectiveEndDate__c = date.Today()+1;
        prdRatePlan.zqu__ZuoraId__c = [SELECT zqu__ZuoraId__c FROM zqu__ZProduct__c WHERE Id =: zProduct.id].id;
        database.insert(prdRatePlan);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        Integer counter = 0;
        List<publication__c> pub = TestDataFactory.createPublication(3);
        for(publication__c p: pub){
            p.publication_code__c = '01';
            p.Platform_Type__c = 'Print';
            if(counter==1){
                p.Platform_Type__c = 'All in One (AIO)';    
                p.Publication_Platform_AIO__c = 'Online';
            }
            counter++;
        }
        database.insert(pub);
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub[0].Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            test.startTest();
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            
        
        //end test data 
       
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            cont.checkDuplicateSubscription('subRecs.Id');
            cont.myId = 'subRecs.Id';
            
            cont.setSubscriptionRecords();
            cont.getPublication12(subRecs);
            test.stopTest();
         } 
  */
      static testMethod void newTestjd001(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        //prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cas.Status = 'Closed';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.publication_code__c = '01';
        database.insert(pub);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            List<Order_Line_Item__c> orderlineList = new List<Order_Line_Item__c>();
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Stop_Request_Date__c = date.Today()+20;
            orderline.Earliest_Stop_Date__c = date.Today()+21;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            orderlineList.add(orderline);
        
        Service_Access_Flag__c saf = new Service_Access_Flag__c();
        saf.Name = 'test name';
        insert saf;
        
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.ASIAONE_Legacy_Id__c = 'tsh4sa5';
        asia.Legacy_Created_Date__c = '1232014';
        asia.Legacy_Created_By__c = 'lando';
        asia.Legacy_Updated_Date__c = '11409';
        asia.Legacy_Updated_By__c = 'doland';
        asia.Display_Name__c = 'asiasd';
        asia.User_ID_LDAP_ID__c = 'ldap@sing.com';
        asia.Password__c = 'ddfdf5654';
        insert asia;
        
       List<Asia1_Subscription__c> asiasubList1 = [SELECT id, Service_Access_Flag__c, Service_Access_Flag__r.Name, Status__c, Subscription__c, Asia1__r.User_ID_LDAP_ID__c, Concurrent__c FROM Asia1_Subscription__c WHERE 
            Subscription__c =: subRecs.id];
       
        List<Asia1_Subscription__c> asiasubList = new List<Asia1_Subscription__c>();
        Asia1_Subscription__c asiasub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiasub.Asia1__c = asia.id;
        asiasub.Service_Access_Flag__c = saf.id;
        asiasub.Subscription__c = subRecs.id;
        asiasub.Status__c = 'Disabled';
        insert asiasub;   
        asiasubList.add(asiasub);
        
        List<String> idOfSubscription = new List<String>();
        idOfSubscription.add('asiasubList[0].id');
        
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            StopSubOrderEntryDirectController.OrderLineItemWrapper orderlinewrap = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            orderlinewrap.oliFieldAccess = orderline;
            orderlinewrap.id = orderline.subscription__c;
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> orderlinewrapList = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            orderlinewrapList.add(orderlinewrap);
            cont.relatedSubscriptionResultList = orderlinewrapList;
            cont.getRelatedAsia();
            StopSubOrderEntryDirectController.AsiaRelatedListWrapper asiarelwrap = new StopSubOrderEntryDirectController.AsiaRelatedListWrapper();
            asiarelwrap.id = asiasubList[0].id;
            List<StopSubOrderEntryDirectController.AsiaRelatedListWrapper> asiarelwrapList = new List<StopSubOrderEntryDirectController.AsiaRelatedListWrapper>();
            asiarelwrapList.add(asiarelwrap);
            cont.asiaResultList = asiarelwrapList;
            cont.asiaRelatedList = asiasubList;
            cont.getRelatedAsia();
            cont.removeRelatedAsia(idOfSubscription);
            
            try{
            cont.doSave();
            cont.checkFieldsInOrder(orderlineList);
            }catch(Exception e){}

            List<Order_Line_Item__c> oLineListNew = new List<Order_Line_Item__c>();
            for(Order_Line_Item__c wrap : orderlineList){
                wrap.Stop_Request_Date__c = wrap.Earliest_Stop_Date__c;
                wrap.fee_waiver__c = TRUE;
                oLineListNew.add(wrap);
            }
            system.debug('1==============================');
            cont.order = new Order__c();
            cont.order.Urgent_Stop__c = TRUE;
            cont.checkFieldsInOrder(oLineListNew);
            system.debug('2==============================');
            
        test.stopTest();
    }
    
    static testMethod void newTesthjl001(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'SubTypePub';
        key.Id__c = 'Publication';
        key.Type__c = 'Name';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__Deleted__c =false;
        zProduct.ProductCode__c = '01';
        zProduct.zqu__SKU__c = 'SKU01';
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.Name = 'Name';
        //prdRatePlan.RatePlanType__c = 'Proration';
        //prdRatePlan.RatePlanSubType__c = 'Standard';
        database.insert(prdRatePlan);

        //MC: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cas.Status = 'Closed';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.publicationcode__c = '01';
        database.insert(prpc);
        
        publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.publication_code__c = '01';
        database.insert(pub);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        database.insert(caseSub);
        
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = 'Stop Subscription';
            order.status__c = 'Draft';
            order.Base_Subscription__c = subRecs.Id;
            database.insert(order);
            
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            List<Order_Line_Item__c> orderlineList = new List<Order_Line_Item__c>();
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Stop_Request_Date__c = date.Today()+20;
            orderline.Earliest_Stop_Date__c = date.Today()+21;
            orderline.subscription__c = subRecs.Id;
            database.insert(orderline);
            orderlineList.add(orderline);
        
        Service_Access_Flag__c saf = new Service_Access_Flag__c();
        saf.Name = 'test name';
        insert saf;
        
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.ASIAONE_Legacy_Id__c = 'tsh4sa5';
        asia.Legacy_Created_Date__c = '1232014';
        asia.Legacy_Created_By__c = 'lando';
        asia.Legacy_Updated_Date__c = '11409';
        asia.Legacy_Updated_By__c = 'doland';
        asia.Display_Name__c = 'asiasd';
        asia.User_ID_LDAP_ID__c = 'ldap@sing.com';
        asia.Password__c = 'ddfdf5654';
        insert asia;
        
      /** List<Asia1_Subscription__c> asiasubList1 = [SELECT id, Service_Access_Flag__c, Service_Access_Flag__r.Name, Status__c, Subscription__c, Asia1__r.User_ID_LDAP_ID__c, Concurrent__c FROM Asia1_Subscription__c WHERE 
            Subscription__c =: subRecs.id];
       
        List<Asia1_Subscription__c> asiasubList = new List<Asia1_Subscription__c>();
        Asia1_Subscription__c asiasub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiasub.Asia1__c = asia.id;
        asiasub.Service_Access_Flag__c = saf.id;
        asiasub.Subscription__c = subRecs.id;
        asiasub.Status__c = 'Disabled';
        insert asiasub;   
        asiasubList.add(asiasub); **/

        List<Asia1_Subscription__c> asiasubList = TestDataFactory.createAsiaOneSubscription(2);
        asiasubList[0].Asia1__c = asia.id;
       asiasubList[0].Service_Access_Flag__c = saf.id;
       asiasubList[0].Subscription__c = subRecs.id;
       asiasubList[0].Status__c = 'Disabled';
       asiasubList[1].Asia1__c = asia.id;
       asiasubList[1].Service_Access_Flag__c = saf.id;
       asiasubList[1].Subscription__c = subRecs.id;
       asiasubList[1].Status__c = 'Disabled';
       insert asiasubList;

        List<String> idOfSubscription = new List<String>();
        idOfSubscription.add('asiasubList[0].id');
        
        test.startTest();
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            StopSubOrderEntryDirectController.OrderLineItemWrapper orderlinewrap = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            orderlinewrap.oliFieldAccess = orderline;
            orderlinewrap.id = subrecs.id;
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> orderlinewrapList = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            orderlinewrapList.add(orderlinewrap);
            cont.relatedSubscriptionResultList = orderlinewrapList;
            cont.getRelatedAsia();
            StopSubOrderEntryDirectController.AsiaRelatedListWrapper asiarelwrap = new StopSubOrderEntryDirectController.AsiaRelatedListWrapper();
            asiarelwrap.id = asiasubList[0].id;
            List<StopSubOrderEntryDirectController.AsiaRelatedListWrapper> asiarelwrapList = new List<StopSubOrderEntryDirectController.AsiaRelatedListWrapper>();
            asiarelwrapList.add(asiarelwrap);
            cont.asiaResultList = asiarelwrapList;
            cont.asiaRelatedList = asiasubList;
            cont.getRelatedAsia();
            cont.removeRelatedAsia(idOfSubscription);
            //cont.isSRDValidEqualAfterStart(subRecs, subRecsQ);

            try{
            cont.doSave();
            cont.checkFieldsInOrder(orderlineList);

            }catch(Exception e){}
            
            cont.setRefundToZero();
        test.stopTest();
    }
}