@isTest (seeAllData = false)
private class SP_PackingLabelBatchRecordCreationTest2 {
    static testmethod void testSP_PackingLabelBatchRecordCreation() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Name = 'name';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c company = new SPH_Company__c();
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Name = 'Name';
        database.insert(location);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Internal'].Id;
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = company.Id;
        ad.Location_Code__c = location.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
      
      counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Frequency__c = 'Mon - Sat';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Term_Length1__c = '0.0';
            sub.Qty1__c = '3.3';
            sub.Recipient_Contact__c = con.Id;
            sub.Zuora__Account__c = acc.Id;
            
        }
        database.insert(subs); 
            
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Base_Subscription__c = subs[0].id;
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+1;
            oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+2;
            if(counter==1){
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';    
            }
            counter++;
            }
        
        database.insert(ordLine);
        
        subs[0].Order_Line_Item_Number__c = ordLine[0].id;
        subs[1].Order_Line_Item_Number__c = ordLine[1].id;
        database.update(subs);
         
        counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.PublicationCode__c = '01';
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==2){
                sp.PublicationCode__c = '02';    
            }
            else if(counter==3){
                sp.PublicationCode__c = '03';    
            }
            else if(counter==4){
                sp.Zuora__Subscription__c = subs[1].Id;    
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(3);
        for(Publication__c p: pub){
            p.Publication_Code__c = '01';
            p.Earliest_Start_Date__c = date.today()+20;
            p.Publication_Type__c  = 'N';    
            p.Frequency_Code__c = 'Y';
            p.Published_Days__c = 'YYYYYYY';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c =  date.today();
            if (counter==1){
                p.Publication_Code__c = '02';
                p.Earliest_Start_Date__c = date.today()+19;
            }
            counter++;
        }
        database.insert(pub);
        
        counter=0;
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c np: nonPub){
            np.Publication__c = pub[0].id;
            np.Publication_Code__c = '02';
            np.Non_Publication_Date__c = date.today();
        }
        database.insert(nonPub);
        
        test.startTest();
            Database.BatchableContext BC;
            SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
            //batch.execute(BC,subs);
            database.executeBatch(batch, 200);
        test.stopTest();
    }
    
   static testmethod void testSP_PackingLabelBatchRecordCreation2() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Name = 'name';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c company = new SPH_Company__c();
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Name = 'Name';
        database.insert(location);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas'].Id;
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = company.Id;
        ad.Location_Code__c = location.Id;
        ad.Country__c = country.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.Salutation = 'hngsdglsdks';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
      
      counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Frequency__c = 'Mon - Sat';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Term_Length1__c = '0.0';
            sub.Qty1__c = '3.3';
            sub.Recipient_Contact__c = con.Id;
            sub.Other_PaymentMethod__c = 'Freelist';
            
        }
        database.insert(subs); 
            
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Base_Subscription__c = subs[0].id;
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+1;
            oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+2;
            if(counter==1){
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';    
            }
            counter++;
            }
        
        database.insert(ordLine);
        
        subs[0].Order_Line_Item_Number__c = ordLine[0].id;
        subs[1].Order_Line_Item_Number__c = ordLine[1].id;
        database.update(subs);
         
        counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.PublicationCode__c = '01';
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==2){
                sp.PublicationCode__c = '02';    
            }
            else if(counter==3){
                sp.PublicationCode__c = '03';    
            }
            else if(counter==4){
                sp.Zuora__Subscription__c = subs[1].Id;    
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(3);
        for(Publication__c p: pub){
            p.Publication_Code__c = '01';
            p.Earliest_Start_Date__c = date.today()+20;
            p.Publication_Type__c  = 'N';    
            p.Frequency_Code__c = 'Y';
            p.Published_Days__c = 'YYYYYYY';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c =  date.today();
            if (counter==1){
                p.Publication_Code__c = '02';
                p.Earliest_Start_Date__c = date.today()+19;
            }
            counter++;
        }
        database.insert(pub);
        
        counter=0;
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c np: nonPub){
            np.Publication__c = pub[0].id;
            np.Publication_Code__c = '02';
            np.Non_Publication_Date__c = date.today();
        }
        database.insert(nonPub);
        
        test.startTest();
            Database.BatchableContext BC;
            SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
            //batch.execute(BC,subs);
            database.executeBatch(batch, 200);
        test.stopTest();
    }
    
    static testmethod void testSP_PackingLabelBatchRecordCreation3() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Name = 'name';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c company = new SPH_Company__c();
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Name = 'Name';
        database.insert(location);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas'].Id;
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = company.Id;
        ad.Location_Code__c = location.Id;
        ad.Country__c = country.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.Salutation = 'hngsdglsdks';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
      
      counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Frequency__c = 'Mon - Sat';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Term_Length1__c = '0.0';
            sub.Qty1__c = '3.3';
            sub.Recipient_Contact__c = con.Id;
            sub.Other_PaymentMethod__c = 'Freelist';
            
        }
        database.insert(subs); 
            
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Base_Subscription__c = subs[0].id;
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+1;
            oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+2;
            if(counter==1){
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';    
            }
            counter++;
            }
        
        database.insert(ordLine);
        
        subs[0].Order_Line_Item_Number__c = ordLine[0].id;
        subs[1].Order_Line_Item_Number__c = ordLine[1].id;
        database.update(subs);
         
        counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.PublicationCode__c = '01';
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==2){
                sp.PublicationCode__c = '02';    
            }
            else if(counter==3){
                sp.PublicationCode__c = '03';    
            }
            else if(counter==4){
                sp.Zuora__Subscription__c = subs[1].Id;    
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(3);
        for(Publication__c p: pub){
            p.Publication_Code__c = '01';
            p.Earliest_Start_Date__c = date.today()+20;
            p.Publication_Type__c  = 'N';    
            p.Frequency_Code__c = 'W';
            p.Published_Days__c = 'YYYYYYY';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c =  date.today();
            if (counter==1){
                p.Publication_Code__c = '02';
                p.Earliest_Start_Date__c = date.today()+19;
                p.Frequency_Code__c = 'F';
            }
            counter++;
        }
        database.insert(pub);
        
        counter=0;
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c np: nonPub){
            np.Publication__c = pub[0].id;
            np.Publication_Code__c = '02';
            np.Non_Publication_Date__c = date.today();
        }
        database.insert(nonPub);
        
        test.startTest();
            Database.BatchableContext BC;
            SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
            //batch.execute(BC,subs);
            database.executeBatch(batch, 200);
        test.stopTest();
    }
    
  static testmethod void testSP_PackingLabelBatchRecordCreation4() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Name = 'name';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c company = new SPH_Company__c();
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Name = 'Name';
        database.insert(location);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas'].Id;
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = company.Id;
        ad.Location_Code__c = location.Id;
        ad.Country__c = country.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.Salutation = 'hngsdglsdks';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
      
      counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Frequency__c = 'Mon - Sat';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Term_Length1__c = '0.0';
            sub.Qty1__c = '3.3';
            sub.Recipient_Contact__c = con.Id;
            sub.Other_PaymentMethod__c = 'Freelist';
            
        }
        database.insert(subs); 
            
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Base_Subscription__c = subs[0].id;
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+1;
            oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+2;
            if(counter==1){
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';    
            }
            counter++;
            }
        
        database.insert(ordLine);
        
        subs[0].Order_Line_Item_Number__c = ordLine[0].id;
        subs[1].Order_Line_Item_Number__c = ordLine[1].id;
        database.update(subs);
         
        counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.PublicationCode__c = '01';
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==2){
                sp.PublicationCode__c = '02';    
            }
            else if(counter==3){
                sp.PublicationCode__c = '03';    
            }
            else if(counter==4){
                sp.Zuora__Subscription__c = subs[1].Id;    
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(3);
        for(Publication__c p: pub){
            p.Publication_Code__c = '01';
            p.Earliest_Start_Date__c = date.today()+20;
            p.Publication_Type__c  = 'N';    
            p.Frequency_Code__c = 'F';
            p.Published_Days__c = 'YYYYYYY';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c =  date.today();
            if (counter==1){
                p.Publication_Code__c = '02';
                p.Earliest_Start_Date__c = date.today()+19;
                p.Frequency_Code__c = 'F';
            }
            counter++;
        }
        database.insert(pub);
        
        counter=0;
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c np: nonPub){
            np.Publication__c = pub[0].id;
            np.Publication_Code__c = '02';
            np.Non_Publication_Date__c = date.today();
        }
        database.insert(nonPub);
        
        test.startTest();
            SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
            database.executeBatch(batch, 200);
        test.stopTest();
    }  
    
    static testmethod void testSP_PackingLabelBatchRecordCreation5() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Name = 'name';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c company = new SPH_Company__c();
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Name = 'Name';
        database.insert(location);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas'].Id;
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = company.Id;
        ad.Location_Code__c = location.Id;
        ad.Country__c = country.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.Salutation = 'hngsdglsdks';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
      
      counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Frequency__c = 'Mon - Sat';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Term_Length1__c = '0.0';
            sub.Qty1__c = '3.3';
            sub.Recipient_Contact__c = con.Id;
            sub.Other_PaymentMethod__c = 'Freelist';
            
        }
        database.insert(subs); 
            
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Base_Subscription__c = subs[0].id;
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+1;
            oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+2;
            if(counter==1){
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';    
            }
            counter++;
            }
        
        database.insert(ordLine);
        
        subs[0].Order_Line_Item_Number__c = ordLine[0].id;
        subs[1].Order_Line_Item_Number__c = ordLine[1].id;
        database.update(subs);
         
        counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.PublicationCode__c = '01';
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==2){
                sp.PublicationCode__c = '02';    
            }
            else if(counter==3){
                sp.PublicationCode__c = '03';    
            }
            else if(counter==4){
                sp.Zuora__Subscription__c = subs[1].Id;    
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(3);
        for(Publication__c p: pub){
            p.Publication_Code__c = '01';
            p.Earliest_Start_Date__c = date.today()+20;
            p.Publication_Type__c  = 'N';    
            p.Frequency_Code__c = 'M';
            p.Published_Days__c = 'YYYYYYY';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c =  date.today();
            if (counter==1){
                p.Publication_Code__c = '02';
                p.Earliest_Start_Date__c = date.today()+19;
                p.Frequency_Code__c = 'F';
            }
            counter++;
        }
        database.insert(pub);
        
        counter=0;
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c np: nonPub){
            np.Publication__c = pub[0].id;
            np.Publication_Code__c = '02';
            np.Non_Publication_Date__c = date.today();
        }
        database.insert(nonPub);
        
        test.startTest();
            SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
            database.executeBatch(batch, 200);
        test.stopTest();
    }  
    
    static testmethod void testSP_PackingLabelBatchRecordCreation6() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Name = 'name';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c company = new SPH_Company__c();
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Name = 'Name';
        database.insert(location);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas'].Id;
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = company.Id;
        ad.Location_Code__c = location.Id;
        ad.Country__c = country.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.Salutation = 'hngsdglsdks';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
      
      counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Frequency__c = 'Mon - Sat';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Term_Length1__c = '0.0';
            sub.Qty1__c = '3.3';
            sub.Recipient_Contact__c = con.Id;
            sub.Other_PaymentMethod__c = 'Freelist';
            
        }
        database.insert(subs); 
            
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Base_Subscription__c = subs[0].id;
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+1;
            oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+2;
            if(counter==1){
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';    
            }
            counter++;
            }
        
        database.insert(ordLine);
        
        subs[0].Order_Line_Item_Number__c = ordLine[0].id;
        subs[1].Order_Line_Item_Number__c = ordLine[1].id;
        database.update(subs);
         
        counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.PublicationCode__c = '01';
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==2){
                sp.PublicationCode__c = '02';    
            }
            else if(counter==3){
                sp.PublicationCode__c = '03';    
            }
            else if(counter==4){
                sp.Zuora__Subscription__c = subs[1].Id;    
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(3);
        for(Publication__c p: pub){
            p.Publication_Code__c = '01';
            p.Earliest_Start_Date__c = date.today()+20;
            p.Publication_Type__c  = 'N';    
            p.Frequency_Code__c = 'B';
            p.Published_Days__c = 'YYYYYYY';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c =  date.today();
            if (counter==1){
                p.Publication_Code__c = '02';
                p.Earliest_Start_Date__c = date.today()+19;
                p.Frequency_Code__c = 'F';
            }
            counter++;
        }
        database.insert(pub);
        
        counter=0;
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c np: nonPub){
            np.Publication__c = pub[0].id;
            np.Publication_Code__c = '02';
            np.Non_Publication_Date__c = date.today();
        }
        database.insert(nonPub);
        
        test.startTest();
            SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
            database.executeBatch(batch, 200);
        test.stopTest();
    }  
    
    static testmethod void testSP_PackingLabelBatchRecordCreation7() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Name = 'name';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c company = new SPH_Company__c();
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Name = 'Name';
        database.insert(location);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas'].Id;
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = company.Id;
        ad.Location_Code__c = location.Id;
        ad.Country__c = country.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.Salutation = 'hngsdglsdks';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
      
      counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Frequency__c = 'Mon - Sat';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Term_Length1__c = '0.0';
            sub.Qty1__c = '3.3';
            sub.Recipient_Contact__c = con.Id;
            sub.Other_PaymentMethod__c = 'Freelist';
            
        }
        database.insert(subs); 
            
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Base_Subscription__c = subs[0].id;
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+1;
            oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+2;
            if(counter==1){
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';    
            }
            counter++;
            }
        
        database.insert(ordLine);
        
        subs[0].Order_Line_Item_Number__c = ordLine[0].id;
        subs[1].Order_Line_Item_Number__c = ordLine[1].id;
        database.update(subs);
         
        counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.PublicationCode__c = '01';
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==2){
                sp.PublicationCode__c = '02';    
            }
            else if(counter==3){
                sp.PublicationCode__c = '03';    
            }
            else if(counter==4){
                sp.Zuora__Subscription__c = subs[1].Id;    
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(3);
        for(Publication__c p: pub){
            p.Publication_Code__c = '01';
            p.Earliest_Start_Date__c = date.today()+20;
            p.Publication_Type__c  = 'N';    
            p.Frequency_Code__c = 'Q';
            p.Published_Days__c = 'YYYYYYY';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c =  date.today();
            if (counter==1){
                p.Publication_Code__c = '02';
                p.Earliest_Start_Date__c = date.today()+19;
                p.Frequency_Code__c = 'F';
            }
            counter++;
        }
        database.insert(pub);
        
        counter=0;
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c np: nonPub){
            np.Publication__c = pub[0].id;
            np.Publication_Code__c = '02';
            np.Non_Publication_Date__c = date.today();
        }
        database.insert(nonPub);
        
        test.startTest();
            SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
            database.executeBatch(batch, 200);
        test.stopTest();
    }  
    
    static testmethod void testSP_PackingLabelBatchRecordCreation8() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        SPH_Section__c section = new SPH_Section__c();
        section.Name = 'name';
        database.insert(section);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Name';
        database.insert(dept);
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Name';
        database.insert(div);
        
        SPH_Company__c company = new SPH_Company__c();
        database.insert(company);
        
        SPH_Location__c location = new SPH_Location__c();
        location.Name = 'Name';
        database.insert(location);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'Singapore';
        database.insert(country);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas'].Id;
        ad.Section_Code__c = section.Id;
        ad.Department__c = dept.Id;
        ad.Division_Code__c = div.Id;
        ad.Company_Code__c = company.Id;
        ad.Location_Code__c = location.Id;
        ad.Country__c = country.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.Salutation = 'hngsdglsdks';
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
      
      counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Frequency__c = 'Mon - Sat';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Term_Length1__c = '0.0';
            sub.Qty1__c = '3.3';
            sub.Recipient_Contact__c = con.Id;
            sub.Other_PaymentMethod__c = 'Freelist';
            
        }
        database.insert(subs); 
            
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Base_Subscription__c = subs[0].id;
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli: ordLine){
            oli.Main_Package_ID__c = pack.Id;
            oli.Order__c = ord.id;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+1;
            oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id].Zuora__SubscriptionEndDate__c)+2;
            if(counter==1){
                oli.Main_Package_Product_Sub_Type__c = 'Magazine';    
            }
            counter++;
            }
        
        database.insert(ordLine);
        
        subs[0].Order_Line_Item_Number__c = ordLine[0].id;
        subs[1].Order_Line_Item_Number__c = ordLine[1].id;
        database.update(subs);
         
        counter = 0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.PublicationCode__c = '01';
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==2){
                sp.PublicationCode__c = '02';    
            }
            else if(counter==3){
                sp.PublicationCode__c = '03';    
            }
            else if(counter==4){
                sp.Zuora__Subscription__c = subs[1].Id;    
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(3);
        for(Publication__c p: pub){
            p.Publication_Code__c = '01';
            p.Earliest_Start_Date__c = date.today()+20;
            p.Publication_Type__c  = 'N';    
            p.Frequency_Code__c = 'H';
            p.Published_Days__c = 'YYYYYYY';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c =  date.today();
            if (counter==1){
                p.Publication_Code__c = '02';
                p.Earliest_Start_Date__c = date.today()+19;
                p.Frequency_Code__c = 'F';
            }
            counter++;
        }
        database.insert(pub);
        
        counter=0;
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c np: nonPub){
            np.Publication__c = pub[0].id;
            np.Publication_Code__c = '02';
            np.Non_Publication_Date__c = date.today();
        }
        database.insert(nonPub);
        
        test.startTest();
            SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
            database.executeBatch(batch, 200);
        test.stopTest();
    }  
       
}