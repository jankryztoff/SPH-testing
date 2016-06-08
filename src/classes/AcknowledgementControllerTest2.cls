@isTest(SeeAllData=false)

private class AcknowledgementControllerTest2{
    
    static testMethod void testAcknowledgementControllerLocalAd(){
        
        defaultCustomSetting(); //jurna-10-21-15
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'Building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Block_House_Number__c = '01';
        ad.Postal_Code__c = postal.Id;
        ad.Level_Number__c = '01';
        ad.Unit_Number__c = '01';
        ad.Country__c = country.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Sub_Status__c = 'Ready for Submission';
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack); 
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number_1__c = ordLine.Id; // jurna-10-21-15
            sub.Recipient_Contact__c = con.Id;
            sub.Contact__c = con.Id;
            sub.Main_Package__c = pack.Id;
            sub.Number_of_Copies__c = 3;
            sub.Qty1__c = '3';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Payment_Mode__c = 'Invoice';
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Term_Length1__c = '1';
            sub.Other_PaymentMethod__c = 'Invoice';
            if(counter==0){
                sub.Subscription_Type__c = 'Delivery';    
                //sub.Order_Line_Item_Number_1__c = ordLine.Id;
            }
            else if(counter==1){
                sub.Subscription_Type__c = 'Postage';    
            }
            counter++;
        }
        database.insert(subs);   
        
        counter=0;
        List<Order__c> ord = TestDataFactory.createOrder(2);
        for(Order__c order: ord) {
            order.Account__c = acc.Id;
            //or.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal'); // jurna-10-21-15
            order.Base_Subscription__c = subs[0].id; //jurna-10-21-15
            if (counter==0){
                order.Order_Type__c = ConstantsSLB.getOther('Change of Subscription');
            }
            else{
                 order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
            }
            counter++;
        }   
        database.insert(ord);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord[0].id;
            oli.Start_Date__c = date.Today()+10;
            if (counter==0){
                oli.Main_Package_Product_Sub_Type__c = 'Newspaper';

            }
            else{
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';
            }
            counter++;
        }
        database.insert(ordLine);
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[counter].Id;
            caseSub.Case__c = cas.Id;
            counter++;
        }
        database.insert(caseSubs);
        
        test.startTest();
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', billAcc.Id);   
            AcknowledgementController cont = new AcknowledgementController();
            cont.generateAcknowledgementController();
        test.stopTest();
    }
    
    //jurna
    static testMethod void testAcknowledgementControllerLocalAd2(){
        
        defaultCustomSetting(); //jurna-10-21-15
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'Building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Block_House_Number__c = '01';
        ad.Postal_Code__c = postal.Id;
        ad.Level_Number__c = '01';
        ad.Unit_Number__c = '01';
        ad.Country__c = country.Id;
        ad.Name = 'test';
        database.insert(ad);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Sub_Status__c = 'Ready for Submission';
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack); 
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number_1__c = ordLine.Id; // jurna-10-21-15
            sub.Recipient_Contact__c = con.Id;
            sub.Contact__c = con.Id;
            sub.Main_Package__c = pack.Id;
            sub.Number_of_Copies__c = 3;
            sub.Qty1__c = '3';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Payment_Mode__c = 'Invoice';
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Term_Length1__c = '1';
            sub.Other_PaymentMethod__c = 'Invoice';
            //sub.Term_Length__c = 1;
            //sub.Term_Length1__c = '1';
            if(counter==0){
                sub.Subscription_Type__c = 'Delivery';    
                //sub.Order_Line_Item_Number_1__c = ordLine.Id;
            }
            else if(counter==1){
                sub.Subscription_Type__c = 'Postage';    
            }
            counter++;
        }
        database.insert(subs);   
        
        counter=0;
        List<Order__c> ord = TestDataFactory.createOrder(2);
        for(Order__c order: ord) {
            order.Account__c = acc.Id;
            //or.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal'); // jurna-10-21-15
            order.Base_Subscription__c = subs[0].id; //jurna-10-21-15
            if (counter==0){
                order.Order_Type__c = ConstantsSLB.getOther('Change of Subscription');
            }
            else{
                 order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
            }
            counter++;
        }   
        database.insert(ord);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord[0].id;
            oli.Start_Date__c = date.Today()+10;
            if (counter==0){
                oli.Main_Package_Product_Sub_Type__c = 'Newspaper';

            }
            else{
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';
            }
            counter++;
        }
        database.insert(ordLine);
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[counter].Id;
            caseSub.Case__c = cas.Id;
            counter++;
        }
        database.insert(caseSubs);
        
        test.startTest();
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', billAcc.Id);       
            AcknowledgementController cont = new AcknowledgementController();
            cont.generateAcknowledgementController();
            //cont.firstRecipient = 'test';
        test.stopTest();
    }
    
    
    static testMethod void testAcknowledgementControllerOverseasAd(){
        
        defaultCustomSetting(); //jurna-10-21-15
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'Building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Block_House_Number__c = '01';
        ad.Postal_Code__c = postal.Id;
        ad.Level_Number__c = '01';
        ad.Unit_Number__c = '01';
        ad.Country__c = country.Id;
        ad.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND developerName='Overseas'].Id;
        ad.RecordType = [SELECT Id,developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Overseas'];
        ad.Address_1__c = 'Address 1';
        ad.Address_2__c = 'Address 2';
        ad.Address_3__c = 'Address 3';
        ad.Address_4__c = 'Address 4';
        database.insert(ad);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Sub_Status__c = 'Ready for Submission';
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
     
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number_1__c = ordLine.Id; // jurna-10-21-15
            sub.Recipient_Contact__c = con.Id;
            sub.Contact__c = con.Id;
            sub.Main_Package__c = pack.Id;
            sub.Number_of_Copies__c = 3;
            sub.Qty1__c = '3';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Payment_Mode__c = 'Invoice';
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Term_Length1__c = '1';
            sub.Other_PaymentMethod__c = 'Invoice';
            if(counter==0){
                sub.Subscription_Type__c = 'Delivery';    
                //sub.Order_Line_Item_Number_1__c = ordLine.Id;
            }
            else if(counter==1){
                sub.Subscription_Type__c = 'Postage';    
            }
            counter++;
        }
        database.insert(subs);   
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Order_Type__c = ConstantsSLB.getOther('Change of Subscription'); // jurna-10-21-15
        ord.Base_Subscription__c = subs[0].id; //jurna-10-21-15
        database.insert(ord);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = date.Today()+10;
            if (counter==0){
                oli.Main_Package_Product_Sub_Type__c = 'Newspaper';

            }
            else{
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';
            }
            counter++;
        }
        database.insert(ordLine);  
        
        system.assertEquals(ordLine[0].Start_Date__c, subs[0].Zuora__SubscriptionEndDate__c);
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[counter].Id;
            caseSub.Case__c = cas.Id;
            counter++;
        }
        database.insert(caseSubs);
        
        test.startTest();
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', billAcc.Id);       
            AcknowledgementController cont = new AcknowledgementController();
            cont.generateAcknowledgementController();
        test.stopTest();
    }
    
    static testMethod void testAcknowledgementControllerOverseasAd2(){
        
        defaultCustomSetting(); //jurna-10-21-15
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'Building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Block_House_Number__c = '01';
        ad.Postal_Code__c = postal.Id;
        ad.Level_Number__c = '01';
        ad.Unit_Number__c = '01';
        ad.Country__c = country.Id;
        ad.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND developerName='Overseas'].Id;
        ad.RecordType = [SELECT Id,developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Overseas'];
        ad.Address_1__c = 'Address 1';
        ad.Address_2__c = 'Address 2';
        ad.Address_3__c = 'Address 3';
        ad.Address_4__c = 'Address 4';
        database.insert(ad);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Account__c = acc.id;
        cas.Status = 'Closed';
        cas.Sub_Status__c = 'Ready for Submission';
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
     
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__Account__c = acc.id;
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number_1__c = ordLine.Id; // jurna-10-21-15
            sub.Recipient_Contact__c = con.Id;
            sub.Contact__c = con.Id;
            sub.Main_Package__c = pack.Id;
            sub.Number_of_Copies__c = 3;
            sub.Qty1__c = '3';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Payment_Mode__c = 'Invoice';
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Term_Length1__c = '1';
            sub.Other_PaymentMethod__c = 'Invoice';
            sub.Supressed_Acknowledgement_Letter_1__c = false;
            sub.Supressed_Acknowledgement_Letter__c = 'false';
            if(counter==0){
                sub.Subscription_Type__c = 'Delivery';    
                //sub.Order_Line_Item_Number_1__c = ordLine.Id;
            }
            else if(counter==1){
                sub.Subscription_Type__c = 'Postage';    
            }
            counter++;
        }
        database.insert(subs);   
        
        cas.Subscription_Name__c = subs[0].id;
        update cas;
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Order_Type__c = ConstantsSLB.getOther('Change of Subscription'); // jurna-10-21-15
        ord.Base_Subscription__c = subs[0].id; //jurna-10-21-15
        database.insert(ord);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = date.Today()+10;
            if (counter==0){
                oli.Main_Package_Product_Sub_Type__c = 'Newspaper';

            }
            else{
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';
            }
            counter++;
        }
        database.insert(ordLine);  
        
        system.assertEquals(ordLine[0].Start_Date__c, subs[0].Zuora__SubscriptionEndDate__c);
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Account__c = acc.Id;
            caseSub.Subscription__c = subs[counter].Id;
            caseSub.Case__c = cas.Id;
            counter++;
        }
        database.insert(caseSubs);
        counter = 0;
        for(counter=0;counter<5;){
        subs[counter].Recipient_Contact__c = null;
        counter++;
        }
            update subs;
        
        test.startTest();
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', billAcc.Id);       
            AcknowledgementController cont = new AcknowledgementController();
            //cont.SubscriptionList = subs;
            cont.generateAcknowledgementController();
            
            cont.SubscriptionList = subs;
            AcknowledgementController cont2 = new AcknowledgementController();
            cont2.generateAcknowledgementController();
        test.stopTest();
    }
    
    static testMethod void testAcknowledgementControllerInternalAd(){
        
        defaultCustomSetting(); //jurna-10-21-15
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'Building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Section_Name__c = 'section';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Department_Name__c = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c comp = new SPH_Company__c();
        comp.Company_Name__c = 'company';
        database.insert(comp);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Location_Name__c = 'location';
        database.insert(location);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Block_House_Number__c = '01';
        ad.Postal_Code__c = postal.Id;
        ad.Level_Number__c = '01';
        ad.Unit_Number__c = '01';
        ad.Country__c = country.Id;
        ad.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND developerName='Internal'].Id;
        ad.RecordType = [SELECT Id,developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Internal'];
        ad.Address_1__c = 'Address 1';
        ad.Address_2__c = 'Address 2';
        ad.Address_3__c = 'Address 3';
        ad.Address_4__c = 'Address 4';
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = comp.Id;
        ad.Location_Code__c = location.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Sub_Status__c = 'Ready for Submission';
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number_1__c = ordLine.Id; //jurna-10-21-15
            sub.Recipient_Contact__c = con.Id;
            sub.Contact__c = con.Id;
            sub.Main_Package__c = pack.Id;
            sub.Number_of_Copies__c = 3;
            sub.Qty1__c = '3';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Payment_Mode__c = 'Invoice';
            sub.Billing_Type__c = 'Full Prepaid';
            sub.Term_Length1__c = '1';
            sub.Other_PaymentMethod__c = 'Invoice';
            if(counter==0){
                sub.Subscription_Type__c = 'Delivery';    
            }
            else if(counter==1){
                sub.Subscription_Type__c = 'Postage';    
            }
            counter++;
        }
        database.insert(subs);  
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Order_Type__c = ConstantsSLB.getOther('Change of Subscription'); // jurna-10-21-15
        ord.Base_Subscription__c = subs[0].id; //jurna-10-21-15
        database.insert(ord);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = date.Today()+10;
            if (counter==0){
                oli.Main_Package_Product_Sub_Type__c = 'Newspaper';

            }
            else{
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';
            }
            counter++;
        }
        database.insert(ordLine);   
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[counter].Id;
            caseSub.Case__c = cas.Id;
            counter++;
        }
        database.insert(caseSubs);
        
        test.startTest();
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', billAcc.Id);       
            AcknowledgementController cont = new AcknowledgementController();
            cont.generateAcknowledgementController();
        test.stopTest();
    }
    
    static testMethod void testAcknowledgementControllerAirlineAd(){
        
        defaultCustomSetting();//jurna-10-21-15
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'Building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Section_Name__c = 'section';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Department_Name__c = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c comp = new SPH_Company__c();
        comp.Company_Name__c = 'company';
        database.insert(comp);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Location_Name__c = 'location';
        database.insert(location);
        
        City__c city = TestDataFactory.createCity(1)[0];
        city.City_Name__c = 'city name';
        city.Flight_Number_1__c = '123';
        city.Flight_Number_2__c = '456';
        city.Country__c = country.Id;
        database.insert(city);
        
        Packing_Grp__c packG = new Packing_Grp__c();
        packG.Airline__c = 'airline';
        database.insert(packG);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Block_House_Number__c = '01';
        ad.Postal_Code__c = postal.Id;
        ad.Level_Number__c = '01';
        ad.Unit_Number__c = '01';
        ad.Country__c = country.Id;
        ad.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND developerName='Airline'].Id;
        ad.RecordType = [SELECT Id,developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Airline'];
        ad.Address_1__c = 'Address 1';
        ad.Address_2__c = 'Address 2';
        ad.Address_3__c = 'Address 3';
        ad.Address_4__c = 'Address 4';
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = comp.Id;
        ad.Location_Code__c = location.id;
        ad.City__c = city.Id;
        ad.Packing_Code__c = packG.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.Id;
        con.HomePhone = '123';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Sub_Status__c = 'Ready for Submission';
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Promotion_Package__c prom = TestDataFactory.createPromotionPackage(1)[0];
        prom.Package_Name__c = pack.ID;
        database.insert(prom);
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number_1__c = ordLine.Id; //jurna-10-21-15
            sub.Recipient_Contact__c = con.Id;
            sub.Contact__c = con.Id;
            sub.Main_Package__c = pack.Id;
            sub.Number_of_Copies__c = 3;
            sub.Qty1__c = '3';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Payment_Mode__c = 'Credit Card';
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Term_Length1__c = '1';
            sub.Frequency__c = 'Mon - Fri';
            sub.New_Contract_Period__c = '3';
            if(counter==0){
                sub.Subscription_Type__c = 'Delivery';    
                //sub.Order_Line_Item_Number_1__c = ordLine.Id;
            }
            else if(counter==1){
                sub.Subscription_Type__c = 'Postage';    
            }
            counter++;
        }
        database.insert(subs);    
        
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Order_Type__c = ConstantsSLB.getOther('Change of Subscription'); // jurna-10-21-15
        ord.Base_Subscription__c = subs[0].id; // jurna-10-21-15
        database.insert(ord);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = date.Today()+10;
            if (counter==0){
                oli.Main_Package_Product_Sub_Type__c = 'Newspaper';

            }
            else{
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';
            }
            counter++;
        }
        database.insert(ordLine); 
        
        Zuora__Subscription__c subQ = [SELECT Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c FROM Zuora__Subscription__c WHERE Id =:subs[0].Id];
        //system.assertEquals(subQ.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c, GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE);
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[counter].Id;
            caseSub.Case__c = cas.Id;
            counter++;
        }
        database.insert(caseSubs);
        
        test.startTest();
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', billAcc.Id);       
            AcknowledgementController cont = new AcknowledgementController();
            cont.generateAcknowledgementController();
        test.stopTest();
    }
    
     static testMethod void testAcknowledgementControllerAirlineAd2(){
        
        defaultCustomSetting();//jurna-10-21-15
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'Building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Section_Name__c = 'section';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Department_Name__c = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c comp = new SPH_Company__c();
        comp.Company_Name__c = 'company';
        database.insert(comp);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Location_Name__c = 'location';
        database.insert(location);
        
        City__c city = TestDataFactory.createCity(1)[0];
        city.City_Name__c = 'city name';
        city.Flight_Number_1__c = '123';
        city.Flight_Number_2__c = '456';
        city.Country__c = country.Id;
        database.insert(city);
        
        Packing_Grp__c packG = new Packing_Grp__c();
        packG.Airline__c = 'airline';
        database.insert(packG);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Block_House_Number__c = '01';
        ad.Postal_Code__c = postal.Id;
        ad.Level_Number__c = '01';
        ad.Unit_Number__c = '01';
        ad.Country__c = country.Id;
        ad.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND developerName='Airline'].Id;
        ad.RecordType = [SELECT Id,developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Airline'];
        ad.Address_1__c = 'Address 1';
        ad.Address_2__c = 'Address 2';
        ad.Address_3__c = 'Address 3';
        ad.Address_4__c = 'Address 4';
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = comp.Id;
        ad.Location_Code__c = location.id;
        ad.City__c = city.Id;
        ad.Packing_Code__c = packG.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.Id;
        con.HomePhone = '123';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Sub_Status__c = 'Ready for Submission';
        database.insert(cas);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Promotion_Package__c prom = TestDataFactory.createPromotionPackage(1)[0];
        prom.Package_Name__c = pack.ID;
        database.insert(prom);
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number_1__c = ordLine.Id; //jurna-10-21-15
            sub.Recipient_Contact__c = con.Id;
            sub.Contact__c = con.Id;
            sub.Main_Package__c = pack.Id;
            sub.Number_of_Copies__c = 3;
            sub.Qty1__c = '3';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Payment_Mode__c = 'Credit Card';
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Term_Length1__c = '1';
            sub.Frequency__c = 'Mon - Fri';
            sub.New_Contract_Period__c = '3';
            if(counter==0){
                sub.Subscription_Type__c = 'Delivery';    
                //sub.Order_Line_Item_Number_1__c = ordLine.Id;
            }
            else if(counter==1){
                sub.Subscription_Type__c = 'Postage';    
            }
            counter++;
        }
        database.insert(subs);    
        
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Order_Type__c = ConstantsSLB.getOther('Change of Subscription'); // jurna-10-21-15
        ord.Base_Subscription__c = subs[0].id; // jurna-10-21-15
        database.insert(ord);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = date.Today()+10;
            if (counter==0){
                oli.Main_Package_Product_Sub_Type__c = 'Newspaper';

            }
            else{
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';
            }
            counter++;
        }
        database.insert(ordLine); 
        
        Zuora__Subscription__c subQ = [SELECT Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c FROM Zuora__Subscription__c WHERE Id =:subs[0].Id];
        //system.assertEquals(subQ.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c, GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE);
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[counter].Id;
            caseSub.Case__c = cas.Id;
            counter++;
        }
        database.insert(caseSubs);
        
        Datetime myDateTime = Datetime.newInstance(1960, 2, 17);
        
        test.startTest();
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('isRecovery', 'true'); 
            ApexPages.currentPage().getParameters().put('generationFrom', string.valueof(myDateTime));   
            ApexPages.currentPage().getParameters().put('generationTo', string.valueof(myDateTime.addDays(2)));        
            AcknowledgementController cont = new AcknowledgementController();
            cont.generateAcknowledgementController();
        test.stopTest();
    }
    
    //jurna-10-21-15
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
    }
}