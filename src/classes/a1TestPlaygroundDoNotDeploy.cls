@isTest
private class a1TestPlaygroundDoNotDeploy {
//test
    @testSetup static void methodName() {
   		
   		insert CustomSettingsDataFactory.createSpecial_Product_Families();
   		insert CustomSettingsDataFactory.createPublic_Holiday_Pub_Indiators();
   		insert CustomSettingsDataFactory.createProduct_Frequency();
   		insert CustomSettingsDataFactory.createProduct_Code();
   		insert CustomSettingsDataFactory.createPostage_Charge();
   		insert CustomSettingsDataFactory.createOther();
   		insert CustomSettingsDataFactory.createKey_Id();
   		insert CustomSettingsDataFactory.createPlannerSched();
    }

	
    static testMethod void testStopSubOrderEntryDirectController(){
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = add.Id;
        con.Billing_Indicator__c = true;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        database.insert(pack);

        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.publication_code__c = '01';
        database.insert(pub);
        
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


		Product_Publication__c productPub = new Product_Publication__c();
		productPub.Publication_Code__c = pub.Id;
		productPub.ZProduct__c = zProduct.Id;
		database.insert(productPub);

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
        
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = add.Id;
        caseSub.isComplaint__c = true;
        //database.insert(caseSub);
        //end test data 
    
        test.startTest();
        pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
        test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
        ApexPages.currentPage().getParameters().put('contactId', con.Id);
        ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
        
        StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
        cont.getOrder();

            StopSubOrderEntryDirectController.SubscriptionWrapper cont1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            StopSubOrderEntryDirectController.OrderLineItemWrapper cont2 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            cont2.subscription = 'subRecs.id';
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(cont2);    
            StopSubOrderEntryDirectController.AsiaRelatedListWrapper cont3 = new StopSubOrderEntryDirectController.AsiaRelatedListWrapper();
            cont.objcase = cas;
            cont.accountBackUp = acc;
            cont.date1 = date.Today();
            cont.publicationRec = pub;
            cont.caseRecordType = '';
            cont.category = '';
            cont.subCategory= '';
            cont.status= '';
            cont.caseOwner= '';
            cont.orderNumber= '';
            cont.subscriberAccount= '';
            cont.recipientName = '';
            cont.originalAdminFee = 1;
            cont.isError = false;
			cont1.enableAddButton = false;     
			cont1.id = '';
			cont1.zuoraId = '';
			cont1.subscription = '';
			cont1.type = '';
			cont1.startDate = date.today();
			cont1.endDate = date.today();
			cont1.contractEnd = date.today();
			cont1.quantity = 1;
			cont1.dowPattern = '';
			cont1.recipientName = '';
			cont1.recipientNumber = '';
			cont1.billingAccount = '';
			cont1.ratePlan = '';
			cont1.tempStartDate = '';
			cont1.tempEndDate = '';
			cont1.tempContractEnd = '';
			cont1.earliestStopDate = date.today();
			cont1.orderNumber = '';
			cont1.packageType = '';
			cont1.mainPackage = '';
			cont1.mainPackageName = '';
			cont1.bundledWith = '';
			cont1.subscriptionType = '';
			cont1.packageBillingType = '';
			cont1.packageSubType = '';
			cont1.recipientId = '';
			cont1.promotion = '';
			cont1.orderLineItem1 = '';
			cont1.bundledWith = '';
			cont1.subscriptionType = '';
			cont2.originalAdminFee = 1;
			cont2.oli1 = '';
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
            
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.case_record_type__c = 'Stop Subscription';
        order.status__c = 'Draft';
        order.Base_Subscription__c = subRecs.Id;
        database.insert(order);
        
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
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
    
    /*
    
     static testMethod void NewTest3(){
             
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            database.insert(add);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = add.Id;
            con.Billing_Indicator__c = true;
            con.Recipient_Indicator__c = true;
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
            order.case_record_type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION; 
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
            
            test.startTest();
            
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
           
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
            
            
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            //cont.order= order;
             //cont.order.Id = order.Id;
             
             
            StopSubOrderEntryDirectController.SubscriptionWrapper cont1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
            StopSubOrderEntryDirectController.OrderLineItemWrapper cont2 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            cont2.subscription = 'subRecs.id';
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(cont2);    
            StopSubOrderEntryDirectController.AsiaRelatedListWrapper cont3 = new StopSubOrderEntryDirectController.AsiaRelatedListWrapper();
            
            //cont.StopSubOrderEntryDirectController();
             try{
                 cont.getAccount();
             }catch(Exception e){
                 
             }
            
            cont.order = order;
            try{
                 cont.doCancel();
             }catch(Exception e){
                 
             }
            
            
             
             
             test.stopTest();
         }
    static testMethod void NewTest4(){

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
            order.case_record_type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION; 
            order.status__c = 'New';
            order.Base_Subscription__c = subRecs.Id;
            order.Urgent_Stop__c=false;
            order.isWaive__c=false;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            orderline.Stop_Request_Date__c=date.today();
            orderline.Earliest_Stop_Date__c = date.today();
            orderline.fee_waiver__c=true;
            database.insert(orderline);
            
            list<Order_Line_Item__c> orderlineList = new list<Order_Line_Item__c>();
            orderlineList.add(orderline);
            
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
            cont2.feeOverride= true;
            cont2.feeOverrideAmount = GlobalVariableClass.EMPTYSTR;
            cont2.feeOverrideAmountHidden=100.00;
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(cont2);    
            StopSubOrderEntryDirectController.AsiaRelatedListWrapper cont3 = new StopSubOrderEntryDirectController.AsiaRelatedListWrapper();
            
             try{
                 cont.getAccount();
             }catch(Exception e){
                 
             }
            
            cont.order = order;
            cont.checkFieldsInOrder(orderlineList);
            try{
                
                 cont.saveAsDraft();
            }catch(Exception e){
               
            }
            
            try{
                
                 cont.doCancel();
             }catch(Exception e){
                 
             }
            
            
             
             
             test.stopTest();
        
    }
    
     static testMethod void NewTest5(){

            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            database.insert(add);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = add.Id;
            con.Recipient_Indicator__c=true;
            con.Billing_Indicator__c= true;
            database.insert(con);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            database.insert(billAcc);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON;
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
             
            test.startTest();
            
            pageReference currentPage = Page.StopSub_Order_Entry_Direct_Edit;
            test.setCurrentPage(currentPage);
           
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', acc.Id);
            ApexPages.currentPage().getParameters().put('recordtype', cas.RecordTypeId);
           
            ApexPages.currentPage().getParameters().put('contactId',con.Id);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.case_record_type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION; 
            order.status__c = 'New';
            order.Base_Subscription__c = subRecs.Id;
            order.Urgent_Stop__c=false;
            order.isWaive__c=false;
            database.insert(order);
            
            cas.Order__c = order.id;
            database.update(cas);
            
            
            Zuora__Subscription__c subRecsQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id Limit 1];
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = subRecsQ.Zuora__SubscriptionEndDate__c.addDays(1);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.subscription__c = subRecs.Id;
            orderline.Stop_Request_Date__c=date.today();
            orderline.Earliest_Stop_Date__c = date.today();
            orderline.fee_waiver__c=true;
            database.insert(orderline);
            
            list<Order_Line_Item__c> orderlineList = new list<Order_Line_Item__c>();
            orderlineList.add(orderline);
            
            ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.id);
            StopSubOrderEntryDirectController cont = new StopSubOrderEntryDirectController();
            
            StopSubOrderEntryDirectController.SubscriptionWrapper cont1 = new StopSubOrderEntryDirectController.SubscriptionWrapper();
           
            StopSubOrderEntryDirectController.OrderLineItemWrapper cont2 = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
            cont2.subscription = 'subRecs.id';
            cont2.feeOverride= true;
            cont2.feeOverrideAmount = GlobalVariableClass.EMPTYSTR;
            cont2.feeOverrideAmountHidden=100.00;
            List<StopSubOrderEntryDirectController.OrderLineItemWrapper> oliwrap1List = new List<StopSubOrderEntryDirectController.OrderLineItemWrapper>();
            oliwrap1List.add(cont2);    
            StopSubOrderEntryDirectController.AsiaRelatedListWrapper cont3 = new StopSubOrderEntryDirectController.AsiaRelatedListWrapper();
            
            cont.myId = subRecs.Id;
            
            try{
                cont.getOrder();
                cont.getSubscriptions();
            }catch(Exception e){
                
            }
            
            test.stopTest();
        
    }
    
    static testMethod void testStopSubOrderEntryDirectController2(){

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

    
    static testMethod void NewTestc(){
 
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
            oliwrap1.feeOverride=true;
            oliwrap1.feeOverrideAmount=GlobalVariableClass.EMPTYSTR;
            oliwrap1.feeOverrideAmountHidden= 5.0;
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
            
            String isStopAfter = cont.isAfterTStop(oliwrap1List, subwrap1List);
            Boolean isSRValid = cont.isSRDValidEqualAfterStart(oliwrap1List, subwrap1List);
            
            
           
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
            database.update(cas); ** /
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
            update subRecs; ** /
            
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
            database.update(cas); ** /
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
            update subRecs; ** /
            
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
            cont.setRefundToZero();

            
           
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
            Boolean isSRValid = cont.isSRDValidEqualAfterStart(oliwrap1List, subwrap1List);
            String isStopAfter = cont.isAfterTStop(oliwrap1List, subwrap1List);
            Date testDate = cont.earliestStart(pack.Id);
            
           
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
        */  
}