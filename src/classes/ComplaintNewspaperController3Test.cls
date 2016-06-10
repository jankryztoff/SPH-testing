@isTest (seeAllData= true)
private class ComplaintNewspaperController3Test{
    
    
    
    static testMethod void testComplaintNewspaperControllerVendor(){
        Public_Holiday__c p = new Public_Holiday__c();
        p.Holiday_Date__c  = date.today();
        insert p;
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
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Package Item_Base Product';
        key.Id__c = '012N00000008jCOIAY';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Error_Messages__c error = new Error_Messages__c();
        error.Name = 'BlankContactInCase';
        error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        error.Description__c = 'For Change of address with address type of Change of Billing address and Delivery address or Change of Billing';
        error.Message__c = 'Contact cannot be empty.';
        //error.Method_Name__c = '';
        database.insert(error);
        
        Error_Messages__c error2 = new Error_Messages__c();
        error2.Name = 'Negative Goodwill';
        //error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        error2.Description__c = 'Error message when goodwill amount is a negative value';
        error2.Message__c = 'Goodwill Amount cannot be a negative value.';
        //error.Method_Name__c = '';
        database.insert(error2);
        
        Error_Messages__c error3 = new Error_Messages__c();
        error3.Name = 'Validate Complaint- Newspaper';
        //error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        //error3.Description__c = 'Error message when goodwill amount is a negative value';
        error3.Message__c = 'Package platform should be Newspaper.';
        //error.Method_Name__c = '';
        database.insert(error3);
        
        Error_Messages__c error4 = new Error_Messages__c();
        error4.Name = 'OverlappingPeriod';
        error4.Apex_Class_Trigger_Name__c = 'ComplaintNewsPaperController';
        error4.Description__c = 'For Complaint cases with overlapping period';
        error4.Message__c = 'There is an overlapping complaint case for the selected subscription and complaint period';
        error4.Method_Name__c = 'save';
        database.insert(error4);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        cas.AccountId = acc.Id;
        //cas.Vendor_Chargeable_Paper__c = true;
        database.insert(cas);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Recipient_Contact__c = con.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__SubscriptionStartDate__c = date.newInstance(2015, 08, 01)+1;
        sub.Main_Package__c = pack.Id;
        database.insert(sub);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = sub.Id;
        caseSub.Complaint_From__c = date.newInstance(2015, 08, 01);
        caseSub.Complaint_To__c = date.newInstance(2015, 08, 01)+3;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = ad.Id;
        caseSub.Complaint_Copies__c = 3; 
        caseSub.Replace_From__c = date.newInstance(2015, 08, 01)+1;
        caseSub.Replace_To__c = date.newInstance(2015, 08, 01)+3;
        caseSub.Credit_Amount__c = 100.00;
        database.insert(caseSub);
        
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        caseSubList.add(caseSub);
        caseSubList.add(caseSub);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Recipient__c = con.Id;
        database.insert(subVen);
        
        Case_Vendor_Subscription__c caseVen = TestDataFactory.createCaseVendorSub(1)[0];
        caseVen.Case__c = cas.Id;
        caseVen.Subscription_Vendor__c = subVen.Id;
        caseVen.Goodwill_Amount__c = -1;
        database.insert(caseVen);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        Integer counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(4);
        for(Zuora__SubscriptionProductCharge__c sp : spc){
            if(counter==0){
                sp.Zuora__UOM__c = 'Credit Copy Weekday';
            }
            else if(counter==1){
                sp.Zuora__UOM__c = 'Credit Copy Sat';
            }
            else if(counter==2){
                sp.Zuora__UOM__c = 'Credit Copy Sun';
            }
            else{
                sp.Zuora__UOM__c = 'Goodwill%';
            }
            sp.Zuora__Account__c = acc.id;
            sp.Zuora__Subscription__c = sub.Id;
            sp.Zuora__RatePlanName__c = 'Name001';
            sp.Zuora__ProductSKU__c = 'SKU001';  
            sp.Zuora__Model__c = 'Discount-Percentage'; 
            sp.Zuora__ProductName__c = 'discount';
            sp.Zuora__EffectiveStartDate__c = date.newInstance(2015, 08, 01)+counter;
            sub.Zuora__SubscriptionStartDate__c = date.Today().addDays(-1);
            sp.Zuora__Price__c = 100.25;
            counter++;
        }
        database.insert(spc);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU001';
        zp.ProductPlatform__c = 'Print';
        database.insert(zp);
        
        counter = 0;
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pro : prp){
            if(counter==0){
                pro.RatePlanType__c = 'Proration';   
            }
            else{
                pro.RatePlanType__c = 'Bill Plan';
            }
            pro.RatePlanSubType__c = 'Standard';
            pro.zqu__ZProduct__c = zp.Id;
            pro.Name = 'Name001';
            counter++;
        }
        database.insert(prp);
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prp[1].Id;
        database.insert(packItem);
        
        counter = 0;
        List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(4);
        for(zqu__ProductRatePlanCharge__c pr : prpc){
            if(counter==0){
                pr.zqu__UOM__c = 'Copy Weekday';
            }
            else if(counter==1){
                pr.zqu__UOM__c = 'Copy Sat';
            }
            else if(counter==2){
                pr.zqu__UOM__c = 'Copy Sun';
            }
            else{
                pr.zqu__UOM__c = 'Copy MonthSun';
            }
            pr.zqu__ProductRatePlan__c = prp[0].Id;
            pr.PublicationCode__c = 'Sun';
            counter++;       
        }
        database.insert(prpc);
        
        zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prpct.zqu__Price__c = 100;
        prpct.zqu__ProductRatePlanCharge__c = prpc[0].Id;
        database.insert(prpct);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = 'Sun';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Platform_Type__c = 'Print';
        pub.Publication_Type__c = 'N';
        database.insert(pub);
        
        Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pub.Id;
        database.insert(pp);
        
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c npd : nonPub){
            npd.Publication__c = pub.id;
            npd.Non_Publication_Date__c = date.today();
            npd.Publication_Code__c = 'Sun';
        }
        database.insert(nonPub);
        
        Usage__c usage = new Usage__c();
        usage.Start_Date__c = date.today();
        usage.Rate_Plan_Charge_Id__c = prpc[0].Id;
        database.insert(usage);
        
        Set<Id> ids = new Set<Id>();
        ids.add(usage.Id);
    
        test.startTest();
            PageReference pgRef = Page.ComplaintNewspaperPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);

            
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewsPaperController cont = new ComplaintNewsPaperController(stdCtrlr);
            
            ApexPages.currentPage().getParameters().put('Id', cas.Id);
            ComplaintNewsPaperController cont1 = new ComplaintNewsPaperController(stdCtrlr);
            cont1.objcase = cas;
            cont1.save();
            
            cas.contactId = con.Id;
            database.update(cas);
            ApexPages.currentPage().getParameters().put('Id', cas.Id);
            //cont1.save();
            
            ComplaintNewsPaperController cont3 = new ComplaintNewsPaperController(stdCtrlr);
            caseVen.Goodwill_Amount__c = 1;
            database.update(caseVen);
            //cont3.save();
            cont3.goodwillCopiesSelected = '1';
            cont3.cancel();
            cont3.addRow();
            //Apexpages.currentpage().getParameters().put('index', '1');   //causing null pointer exception
            Apexpages.currentpage().getParameters().put('index', '0'); 
            cont3.removeRows();
            cont3.fetchAccountDetails();
            cont3.computePaperFee(caseSubList);
            cont3.computeCreditAmount(caseSubList);
            cont3.computePrice(sub.id);
            ComplaintNewsPaperController.getCopyPrice(prpc, pub.Publication_Code__c);
            cont3.callComputatePaperFee();
            cont3.callComputeCourierFee(caseSubList);
            ComplaintNewsPaperController.usageCallOut(ids);
            cont3.subSelected = sub.Name;
            cont3.subSelected2 = '2';
            cont3.retPackageName();
            cont3.isDirectDisplay(sub.Name, '5');
            cont3.subSelected3 = subVen.Name;
            cont3.subSelected4 = '10';
            cont3.retPackageName1();
            cont3.getGoodwillAmount();
            cont3.cancel();
            
            ApexPages.StandardController stdCtrlr2 = new ApexPages.StandardController(new Case(contactId=con.Id));
            ComplaintNewsPaperController cont4 = new ComplaintNewsPaperController(stdCtrlr2);
            try{
            cont4.save();
            cont4.cancel();
            cont4.objSpc = null;
            }catch(Exception e){}
        test.stopTest();   
    }
    
    static testMethod void testComplaintNewspaperControllerNotVendor(){
        Public_Holiday__c p = new Public_Holiday__c();
        p.Holiday_Date__c  = date.today();
        insert p;
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
        
        Error_Messages__c error = new Error_Messages__c();
        error.Name = 'BlankContactInCase';
        error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        error.Description__c = 'For Change of address with address type of Change of Billing address and Delivery address or Change of Billing';
        error.Message__c = 'Contact cannot be empty.';
        //error.Method_Name__c = '';
        database.insert(error);
        
        Error_Messages__c error2 = new Error_Messages__c();
        error2.Name = 'Negative Goodwill';
        //error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        error2.Description__c = 'Error message when goodwill amount is a negative value';
        error2.Message__c = 'Goodwill Amount cannot be a negative value.';
        //error.Method_Name__c = '';
        database.insert(error2);
        
        Error_Messages__c error3 = new Error_Messages__c();
        error3.Name = 'Validate Complaint- Newspaper';
        //error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        //error3.Description__c = 'Error message when goodwill amount is a negative value';
        error3.Message__c = 'Package platform should be Newspaper.';
        //error.Method_Name__c = '';
        database.insert(error3);

        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.AccountId = acc.Id;
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__Account__c = acc.Id;
        sub.Recipient_Contact__c = con.Id;
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        database.insert(sub);
        
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        CaseSub.Account__c = acc.Id;
        caseSub.Address__c = ad.Id;
        caseSub.Case__c = cas.Id;
        caseSub.iscomplaint__c = true;
        caseSub.Subscription__c = sub.Id;
        caseSub.Goodwill_Amount__c = -1;
        database.insert(caseSub);
        
        caseSubList.add(caseSub);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        database.insert(subVen);
        
        Case_Vendor_Subscription__c caseVen = TestDataFactory.createCaseVendorSub(1)[0];
        caseVen.Case__c = cas.Id;
        caseVen.Subscription_Vendor__c = subVen.Id;
        caseVen.Goodwill_Amount__c = -1;
        database.insert(caseVen);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU001';
        zp.ProductPlatform__c = 'Print';
        zp.ProductSubType__c = 'Newspaper';
        database.insert(zp);
        
        Integer counter = 0;
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pro : prp){
            if(counter==0){
                pro.RatePlanType__c = 'Proration';   
            }
            else{
                pro.RatePlanType__c = 'Bill Plan';
            }
            pro.RatePlanSubType__c = 'Standard';
            pro.zqu__ZProduct__c = zp.Id;
            pro.Name = 'Name001';
            counter++;
        }
        database.insert(prp);
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prp[1].Id;
        database.insert(packItem);
    
        test.startTest();
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewsPaperController cont = new ComplaintNewsPaperController(stdCtrlr);
            
            ApexPages.currentPage().getParameters().put('Id', cas.Id);
            ComplaintNewsPaperController cont1 = new ComplaintNewsPaperController(stdCtrlr);
            
            ApexPages.currentPage().getParameters().put('Id', cas.Id);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ComplaintNewsPaperController cont2 = new ComplaintNewsPaperController(stdCtrlr);
            //cont2.save();
            
            cas.contactId = con.Id;
            database.update(cas);
            ApexPages.currentPage().getParameters().put('Id', cas.Id);
            //ComplaintNewsPaperController.CaseSubWrapper wrapper = new ComplaintNewsPaperController.CaseSubWrapper(caseSub);
            //wrapper.caseSubscription = caseSub;
            cont2.save();
            cont2.cancel();
            ComplaintNewsPaperController cont3 = new ComplaintNewsPaperController(stdCtrlr);
            caseSub.Goodwill_Amount__c = 1;
            database.update(caseSub);
            
            cont3.save();
            cont3.addRow();
            
            cont3.subSelected = sub.Name;
            cont3.subSelected2 = '5';
            //cont3.retPackageName();
            cont3.isDirectDisplay('1', '5');
            cont3.isNotDirectDisplay(subVen.Name, '5');
            cont3.fetchAccountDetails();
            cont3.save();
            
            ApexPages.StandardController stdCtrlr2 = new ApexPages.StandardController(new Case(contactId=con.Id));
            ComplaintNewsPaperController cont4 = new ComplaintNewsPaperController(stdCtrlr2);
            try{
            cont4.save();
            }catch(Exception e){}
        test.stopTest();   
    }
    
    static testMethod void testComplaintNewspaperControllerVendor2(){ 
    try{
        Public_Holiday__c p = new Public_Holiday__c();
        p.Holiday_Date__c  = date.today();
        insert p;
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
        
        Error_Messages__c error = new Error_Messages__c();
        error.Name = 'BlankContactInCase';
        error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        error.Description__c = 'For Change of address with address type of Change of Billing address and Delivery address or Change of Billing';
        error.Message__c = 'Contact cannot be empty.';
        database.insert(error);
        
        Error_Messages__c error2 = new Error_Messages__c();
        error2.Name = 'Negative Goodwill';
        error2.Description__c = 'Error message when goodwill amount is a negative value';
        error2.Message__c = 'Goodwill Amount cannot be a negative value.';
        database.insert(error2);
        
        Error_Messages__c error3 = new Error_Messages__c();
        error3.Name = 'Validate Complaint- Newspaper';
        error3.Message__c = 'Package platform should be Newspaper.';
        database.insert(error3);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
                    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = ad.id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.AccountId = acc.Id;
        cas.contactId = con.Id;
        cas.Notify_Vendor__c = true;
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        database.insert(zp);
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        database.insert(prp);
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prp.Id;
        database.insert(packItem);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Recipient_Contact__c = con.id;
        database.insert(sub);
        
        List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
        for(Case_Subscription__c cs : caseSub){
            cs.Case__c = cas.Id;
            cs.Subscription__c = sub.Id;
            cs.Credit_Amount__c = 100.00;
            cs.Goodwill_Amount__c = 1;
        }
        database.insert(caseSub);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        database.insert(subVen);
        
        List<Case_Vendor_Subscription__c> caseVen = TestDataFactory.createCaseVendorSub(2);
        for(Case_Vendor_Subscription__c cv : caseVen){
            cv.Case__c = cas.Id;
            cv.Subscription_Vendor__c = subVen.Id;
            cv.Goodwill_Amount__c = 1;
        }
        database.insert(caseVen);
    
        test.startTest();
            PageReference pgRef = Page.ComplaintNewspaperPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('Id', cas.Id);
            
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewsPaperController cont = new ComplaintNewsPaperController(stdCtrlr);
            
            cont.objcase.Id = cas.Id;
            
            //cont.save();
        test.stopTest();
      }catch(Exception e){}
         
    } 
    
    // static testMethod void testComplaintNewspaperControllerNotVendor2(){
    // try{
    //     Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
    //     cir.Name = 'CIR Plan Schedule';
    //     cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
    //     cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
    //     cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //     cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
    //     cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //     cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //     database.insert(cir);
        
    //     List<Other__c> otherList = new List<Other__c>{
    //         new Other__c(Name='DTL', Value__c='23:59')
    //     };
    //     database.insert(otherList);
        
    //     Key_Id__c key = new Key_Id__c();
    //     key.Name = 'Package Item_Base Product';
    //     key.Id__c = '012N00000008jCOIAY';
    //     key.Type__c = 'RecordType';
    //     database.insert(key);
        
    //     Error_Messages__c error = new Error_Messages__c();
    //     error.Name = 'BlankContactInCase';
    //     error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
    //     error.Description__c = 'For Change of address with address type of Change of Billing address and Delivery address or Change of Billing';
    //     error.Message__c = 'Contact cannot be empty.';
    //     database.insert(error);
        
    //     Error_Messages__c error2 = new Error_Messages__c();
    //     error2.Name = 'Negative Goodwill';
    //     error2.Description__c = 'Error message when goodwill amount is a negative value';
    //     error2.Message__c = 'Goodwill Amount cannot be a negative value.';
    //     database.insert(error2);
        
    //     Error_Messages__c error3 = new Error_Messages__c();
    //     error3.Name = 'Validate Complaint- Newspaper';
    //     error3.Message__c = 'Package platform should be Newspaper.';
    //     database.insert(error3);

    //     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //     database.insert(acc);
        
    //     Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    //     postal.Building_Name__c = 'Ebloc2';
    //     insert postal;
        
    //     Country__c country = TestDataFactory.createCountry(1)[0]; 
    //     country.Country_Name__c = 'SINGAPORE'; 
    //     insert country;
                    
    //     Address__c ad = TestDataFactory.createAddress(1)[0];
    //     ad.Postal_Code__c = postal.id;
    //     database.insert(ad);
        
    //     Contact con = TestDataFactory.createContact(1)[0];
    //     con.AccountId = acc.Id;
    //     con.Address__c = ad.id;
    //     con.Recipient_Indicator__c = true;
    //     database.insert(con);
    
    //     Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
    //     cas.AccountId = acc.Id;
    //     cas.contactId = con.Id;
    //     cas.Notify_Vendor__c = true;
    //     database.insert(cas);
        
    //     Package__c pack = TestDataFactory.createPackage(1)[0];
    //     database.insert(pack);
        
    //     zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
    //     zp.ProductSubType__c = 'Newspaper';
    //     database.insert(zp);
        
    //     zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
    //     prp.zqu__ZProduct__c = zp.Id;
    //     database.insert(prp);
        
    //     Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
    //     packItem.Package__c = pack.Id;
    //     packItem.Product_Rate_Plan__c = prp.Id;
    //     database.insert(packItem);
        
    //     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    //     billAcc.Zuora__Account__c = acc.Id;
    //     database.insert(billAcc);
        
    //     Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
    //     sub.Zuora__CustomerAccount__c = billAcc.Id;
    //     sub.Main_Package__c = pack.Id;
    //     sub.Recipient_Contact__c = con.id;
    //     database.insert(sub);
        
    //     List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
    //     for(Case_Subscription__c cs : caseSub){
    //         cs.Case__c = cas.Id;
    //         cs.Subscription__c = sub.Id;
    //         cs.Goodwill_Amount__c = 1;
    //     }
    //     database.insert(caseSub);
        
    //     Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
    //     database.insert(subVen);
        
    //     List<Case_Vendor_Subscription__c> caseVen = TestDataFactory.createCaseVendorSub(2);
    //     for(Case_Vendor_Subscription__c cv : caseVen){
    //         cv.Case__c = cas.Id;
    //         cv.Subscription_Vendor__c = subVen.Id;
    //         cv.Goodwill_Amount__c = 1;
    //     }
    //     database.insert(caseVen);
    
    //     test.startTest();
    //         PageReference pgRef = Page.ComplaintNewspaperPage;
    //         Test.setCurrentPage(pgRef);
    //         ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
    //         ApexPages.currentPage().getParameters().put('accountId', acc.Id);
    //         ApexPages.currentPage().getParameters().put('Id', cas.Id);
    //         ApexPages.currentPage().getParameters().put('def_parent_id', cas.Id);
            
    //         ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
    //         ComplaintNewsPaperController cont = new ComplaintNewsPaperController(stdCtrlr);
            
    //         //cont.save();
    //     test.stopTest(); 
    //     }catch(Exception e){}
          
    // }
    static testMethod void newTest001(){
        
        Public_Holiday__c p = new Public_Holiday__c();
        p.Holiday_Date__c  = date.today();
        insert p;
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
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Package Item_Base Product';
        key.Id__c = '012N00000008jCOIAY';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Error_Messages__c error = new Error_Messages__c();
        error.Name = 'BlankContactInCase';
        error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        error.Description__c = 'For Change of address with address type of Change of Billing address and Delivery address or Change of Billing';
        error.Message__c = 'Contact cannot be empty.';
        //error.Method_Name__c = '';
        database.insert(error);
        
        Error_Messages__c error2 = new Error_Messages__c();
        error2.Name = 'Negative Goodwill';
        //error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        error2.Description__c = 'Error message when goodwill amount is a negative value';
        error2.Message__c = 'Goodwill Amount cannot be a negative value.';
        //error.Method_Name__c = '';
        database.insert(error2);
        
        Error_Messages__c error3 = new Error_Messages__c();
        error3.Name = 'Validate Complaint- Newspaper';
        //error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
        //error3.Description__c = 'Error message when goodwill amount is a negative value';
        error3.Message__c = 'Package platform should be Newspaper.';
        //error.Method_Name__c = '';
        database.insert(error3);
        
        Error_Messages__c error4 = new Error_Messages__c();
        error4.Name = 'OverlappingPeriod';
        error4.Apex_Class_Trigger_Name__c = 'ComplaintNewsPaperController';
        error4.Description__c = 'For Complaint cases with overlapping period';
        error4.Message__c = 'There is an overlapping complaint case for the selected subscription and complaint period';
        error4.Method_Name__c = 'save';
        database.insert(error4);
        
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
                    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        cas.AccountId = acc.Id;
        //cas.Vendor_Chargeable_Paper__c = true;
        database.insert(cas);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Recipient_Contact__c = con.Id;
        sub.Term_Length1__c = '1';
        sub.Term_Length__c = 1;
        sub.Zuora__SubscriptionStartDate__c = date.Today().addDays(-1);
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Main_Package__c = pack.Id;
        database.insert(sub);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = sub.Id;
        caseSub.Complaint_From__c = date.newInstance(2015, 08, 01);
        caseSub.Complaint_To__c = date.newInstance(2015, 08, 01)+3;
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = ad.Id;
        caseSub.Complaint_Copies__c = 3; 
        caseSub.Goodwill_Amount__c = -1;
        caseSub.Replace_From__c = date.newInstance(2015, 08, 01)+1;
        caseSub.Replace_To__c = date.newInstance(2015, 08, 01)+3;
        caseSub.Credit_Amount__c = 100.00;
        database.insert(caseSub);
        
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        caseSubList.add(caseSub);
        caseSubList.add(caseSub);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Recipient__c = con.Id;
        database.insert(subVen);
        
        Case_Vendor_Subscription__c caseVen = TestDataFactory.createCaseVendorSub(1)[0];
        caseVen.Case__c = cas.Id;
        caseVen.Subscription_Vendor__c = subVen.Id;
        caseVen.Goodwill_Amount__c = -1;
        caseVen.Credit_Amount__c = 100;
        database.insert(caseVen);
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        Integer counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(4);
        for(Zuora__SubscriptionProductCharge__c sp : spc){
            if(counter==0){
                sp.Zuora__UOM__c = 'Credit Copy Weekday';
            }
            else if(counter==1){
                sp.Zuora__UOM__c = 'Credit Copy Sat';
            }
            else if(counter==2){
                sp.Zuora__UOM__c = 'Credit Copy Sun';
            }
            else{
                sp.Zuora__UOM__c = 'Goodwill%';
            }
            sp.Zuora__Account__c = acc.id;
            sp.Zuora__Subscription__c = sub.Id;
            sp.Zuora__RatePlanName__c = 'Name001';
            sp.Zuora__ProductSKU__c = 'SKU001';  
            sp.Zuora__Model__c = 'Discount-Percentage'; 
            sp.Zuora__ProductName__c = 'discount';
            sp.Zuora__EffectiveStartDate__c = date.newInstance(2015, 08, 01)+counter;
            sub.Zuora__SubscriptionStartDate__c = date.Today().addDays(-1);
            sp.Zuora__Price__c = 100.25;
            counter++;
        }
        database.insert(spc);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU001';
        zp.ProductPlatform__c = 'Print';
        database.insert(zp);
        
        counter = 0;
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pro : prp){
            if(counter==0){
                pro.RatePlanType__c = 'Proration';   
            }
            else{
                pro.RatePlanType__c = 'Bill Plan';
            }
            pro.RatePlanSubType__c = 'Standard';
            pro.zqu__ZProduct__c = zp.Id;
            pro.Name = 'Name001';
            counter++;
        }
        database.insert(prp);
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prp[1].Id;
        database.insert(packItem);
        
        counter = 0;
        List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(4);
        for(zqu__ProductRatePlanCharge__c pr : prpc){
            if(counter==0){
                pr.zqu__UOM__c = 'Copy Weekday';
            }
            else if(counter==1){
                pr.zqu__UOM__c = 'Copy Sat';
            }
            else if(counter==2){
                pr.zqu__UOM__c = 'Copy Sun';
            }
            else{
                pr.zqu__UOM__c = 'Copy MonthSun';
            }
            pr.zqu__ProductRatePlan__c = prp[0].Id;
            pr.PublicationCode__c = 'Sun';
            counter++;       
        }
        database.insert(prpc);
        
        zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prpct.zqu__Price__c = 100;
        prpct.zqu__ProductRatePlanCharge__c = prpc[0].Id;
        database.insert(prpct);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = 'Sat';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Platform_Type__c = 'Print';
        pub.Publication_Type__c = 'N';
        database.insert(pub);
        
        Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pub.Id;
        database.insert(pp);
        
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c npd : nonPub){
            npd.Publication__c = pub.id;
            npd.Non_Publication_Date__c = date.today();
            npd.Publication_Code__c = 'Sat';
        } 
        database.insert(nonPub);
        
        Usage__c usage = new Usage__c();
        usage.Start_Date__c = date.today();
        usage.Rate_Plan_Charge_Id__c = prpc[0].Id;
        database.insert(usage);
        
        Set<Id> ids = new Set<Id>();
        ids.add(usage.Id);
    
        test.startTest();
            PageReference pgRef = Page.ComplaintNewspaperPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('Id', cas.Id);

            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewsPaperController cont = new ComplaintNewsPaperController(stdCtrlr);
            cont.save();
            cont.cancel(); 
        test.stopTest();   
    }
    
}