@isTest
private class LP_May14GiftLetterControllerTest2{
    static testMethod void testLP_May14GiftLetterControllerLocal(){
        //start custom settings
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        /*Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '30012551';
        database.insert(key);*/
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'country';
        database.insert(country);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Block_House_Number__c = '10';
        add.Postal_Code__c = postal.Id;
        add.Level_Number__c = '12';
        add.Unit_Number__c = '12';
        add.Country__c = country.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.1';
        database.insert(subRecs);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subRecs.Id;
        order.Recipient_Contact__c = con.Id;
        database.insert(order);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.End_Date__c = orderline.Start_Date__c+2;
        orderline.Main_Package_ID__c = pack.Id;
        database.insert(orderline);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.1';
        sub.Order_Line_Item_Number__c = orderline.Id;
        sub.Subscription_Type__c = 'Publication';
        sub.Main_Package__c = pack.Id;
        database.insert(sub);
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        database.insert(gift);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '30';
        database.insert(prom);
        
        Promotion_Gift__c promG = TestDataFactory.createPromotionGift(1)[0];
        database.insert(promG);
        
        Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c();
        glb.End_Date__c = date.today()+30;
        glb.Start_Date__c = date.today()+1;
        glb.Gift__c = gift.Id;
        glb.Promotion__c = prom.Id;
        glb.Redemption_Start_Date__c = date.today()+3;
        glb.Redemption_End_Date__c = date.today()+3;
        database.insert(glb);
        
        Order_Line_Item_Gift__c olig = TestDataFactory.createItemGift(1)[0];
        olig.Order_Line_Item__c = orderline.Id;
        olig.Promotion_Gift__c = promG.Id;
        olig.Gift_Letter_Batch_Id__c = glb.Id;
        database.insert(olig);
        
        Attachment att = new Attachment();
        att.Name = 'Name';
        att.Body = blob.valueOf('body');
        att.ParentId = postal.Id;
        database.insert(att);
        //end test data
    
        test.startTest();
            PageReference pageRef = Page.LP_GiftLetterMag;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('id', olig.Id);
            
            LP_May14GiftLetterController cont = new LP_May14GiftLetterController();
            cont.initialize();
            cont.contactMailingAddress = '';
            cont.paymentAmount = 1;
            cont.expirationDate = null;
            cont.mailingCountry = '';
            cont.mailingBlk = ''; 
            cont.mailingStreet = '';
            cont.mailingLevel = '';
            cont.mailingUnit = '';
            cont.mailingBuilding = '';
            cont.mailingPostalCode = '';
            date dt = cont.Today;
        test.stopTest();
    }
    
    static testMethod void testLP_May14GiftLetterControllerOverseas(){
        //start custom settings
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        /*Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '30012551';
        database.insert(key);*/
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'country';
        database.insert(country);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Overseas'].Id;
        add.Address_1__c = 'ad1';
        add.Address_2__c = 'ad2';
        add.Address_3__c = 'ad3';
        add.Address_4__c = 'ad4';
        add.Country__c = country.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.1';
        database.insert(subRecs);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subRecs.Id;
        order.Recipient_Contact__c = con.Id;
        database.insert(order);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Bundle';
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Bundle Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.End_Date__c = orderline.Start_Date__c+2;
        orderline.Main_Package_ID__c = pack.Id;
        database.insert(orderline);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.1';
        sub.Order_Line_Item_Number__c = orderline.Id;
        sub.Subscription_Type__c = 'Publication';
        sub.Main_Package__c = pack.Id;
        database.insert(sub);
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        database.insert(gift);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '30';
        database.insert(prom);
        
        Promotion_Gift__c promG = TestDataFactory.createPromotionGift(1)[0];
        database.insert(promG);
        
        Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c();
        glb.End_Date__c = date.today()+30;
        glb.Start_Date__c = date.today()+1;
        glb.Gift__c = gift.Id;
        glb.Promotion__c = prom.Id;
        glb.Redemption_Start_Date__c = date.today()+3;
        glb.Redemption_End_Date__c = date.today()+3;
        database.insert(glb);
        
        Order_Line_Item_Gift__c olig = TestDataFactory.createItemGift(1)[0];
        olig.Order_Line_Item__c = orderline.Id;
        olig.Promotion_Gift__c = promG.Id;
        olig.Gift_Letter_Batch_Id__c = glb.Id;
        database.insert(olig);
        //end test data
    
        test.startTest();
            PageReference pageRef = Page.LP_GiftLetterMag;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('id', olig.Id);
            
            LP_May14GiftLetterController cont = new LP_May14GiftLetterController();
            cont.initialize();
        test.stopTest();
    }
    
    static testMethod void testLP_May14GiftLetterControllerInternal(){
        //start custom settings
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        /*Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '30012551';
        database.insert(key);*/
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Section_Name__c = 'section';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Department_Name__c = 'department';
        database.insert(dept);
        
        SPH_Division__c division = new SPH_Division__c();
        division.Name = 'division';
        database.insert(division);
        
        SPH_Company__c company = new SPH_Company__c();
        company.Company_Name__c = 'company';
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Location_Name__c = 'location';
        database.insert(location);
       
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Internal'].Id;
        add.Section_Code__c = section.Id;
        add.Department__c = dept.Id;
        add.Division_Code__c = division.Id;
        add.Company_Code__c = company.Id;
        add.Location_Code__c = location.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.1';
        database.insert(subRecs);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subRecs.Id;
        order.Recipient_Contact__c = con.Id;
        database.insert(order);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        database.insert(pack);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.End_Date__c = orderline.Start_Date__c+2;
        orderline.Main_Package_ID__c = pack.Id;
        database.insert(orderline);
        
        Promotion_Gift__c promG = TestDataFactory.createPromotionGift(1)[0];
        database.insert(promG);
        
        Order_Line_Item_Gift__c olig = TestDataFactory.createItemGift(1)[0];
        olig.Order_Line_Item__c = orderline.Id;
        olig.Promotion_Gift__c = promG.Id;
        database.insert(olig);
        //end test data
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        database.insert(gift);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '30';
        database.insert(prom);
        
                
        Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c();
        glb.End_Date__c = date.today()+30;
        glb.Start_Date__c = date.today()+1;
        glb.Gift__c = gift.Id;
        glb.Promotion__c = prom.Id;
        glb.Redemption_Start_Date__c = date.today()+3;
        glb.Redemption_End_Date__c = date.today()+3;
        database.insert(glb);
               
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
    
        test.startTest();
            PageReference pageRef = Page.LP_GiftLetterMag;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('id', olig.Id);
            ApexPages.currentPage().getParameters().put('giftLetterBatchId',glb.id);
            
            LP_May14GiftLetterController cont = new LP_May14GiftLetterController();
            cont.initialize();
        test.stopTest();
    }
    
    static testMethod void testLP_May14GiftLetterControllerAirline(){
        //start custom settings
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        /*Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '30012551';
        database.insert(key);*/
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Airline_Indicator__c = true;
        database.insert(acc);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'country';
        database.insert(country);
        
        City__c city = TestDataFactory.createCity(1)[0];
        city.City_Name__c = 'City';
        city.Flight_Number_1__c = '123456';
        city.Flight_Number_2__c = '456789';
        city.Country__c = country.Id;
        database.insert(city);
        
        Packing_Grp__c packC = new Packing_Grp__c();
        packC.Airline__c = '12345';
        database.insert(packC);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Airline'].Id;
        add.City__c = city.Id;
        add.Packing_Code__c = packC.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.1';
        database.insert(subRecs);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subRecs.Id;
        order.Recipient_Contact__c = con.Id;
        database.insert(order);

        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);

        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);

        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.End_Date__c = orderline.Start_Date__c+2;
        orderline.Main_Package_ID__c = pack.Id;
        database.insert(orderline);
        
        Promotion_Gift__c promG = TestDataFactory.createPromotionGift(1)[0];
        database.insert(promG);
        
        Order_Line_Item_Gift__c olig = TestDataFactory.createItemGift(1)[0];
        olig.Order_Line_Item__c = orderline.Id;
        olig.Promotion_Gift__c = promG.Id;
        database.insert(olig);
        //end test data
    
        test.startTest();
            PageReference pageRef = Page.LP_GiftLetterMag;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('id', olig.Id);
            
            
            try {
            LP_May14GiftLetterController cont = new LP_May14GiftLetterController();
            cont.initialize();
            cont.setFields();
            cont.address1 = 'address1';
            cont.address1 = 'address2';
            cont.address1 = 'address3';
            cont.address1 = 'address4';
            cont.address1 = 'address5';
            }catch (exception e) {
            }
            
        test.stopTest();
    }
}