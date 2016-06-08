@isTest(seeAllData=true)
private class PackingLabelsControllerTest{
    static testMethod void testPackingLabelsControllerOverseas(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.AccountNumber = 'unique123456';
        insert acc;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
        insert add;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.Recipient_Number__c = 123456;
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        counter=0;
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(6);
        for(Zuora__Subscription__c sub:subRecs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.subscription_type__c = 'Publication';
            sub.Recipient_Contact__c = con.Id;
            sub.Zuora__SubscriptionEndDate__c = date.today();
            sub.Qty1__c = '3';
            sub.Frequency__c = GlobalVariableClass.FREQUENCY_MONFRI;
            if(counter==1){
                sub.Frequency__c = GlobalVariableClass.FREQUENCY_FRISUN;
            }
            else if(counter==2){
                sub.Frequency__c = GlobalVariableClass.FREQUENCY_SATSUN;
            }
            else if(counter==3){
                sub.Frequency__c = 'Mon-Sat';
            }
            else if(counter==4){
                sub.Frequency__c = GlobalVariableClass.FREQUENCY_DEFAULT;
            }
            counter++;
        }
        insert subRecs;
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs[counter].Id;
            sp.Zuora__UOM__c = 'UOM001';
            sp.PublicationCode__c = 'BH';
            if(counter==0){
                sp.PublicationCode__c = 'ZB';  
            }
            else if(counter==1){
                sp.PublicationCode__c = 'TM';   
            }
            else if(counter==2){
                sp.PublicationCode__c = 'BT';   
            }
            else if(counter==3){
                sp.PublicationCode__c = 'ST';   
            }
            else if(counter==4){
                sp.PublicationCode__c = 'NP';   
            }
            else if(counter==5){
                sp.Zuora__Subscription__c = subRecs[0].Id; 
                sp.PublicationCode__c = 'WB';   
            }
            counter++;
        }
        insert spc;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = 'BH';
        pub.Platform_Type__c = 'Print';
        insert pub;
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id=:acc.Id];
        
        List<Packing_Label_Batch__c> plb = new List<Packing_Label_Batch__c>();
        for(counter=0;counter<6;counter++){
            Packing_Label_Batch__c p = new Packing_Label_Batch__c();
            p.Subscription__c = subRecs[counter].Id; 
            p.Subscriber_Account_Number__c = accQ.AccountNumber;
            plb.add(p);  
        }
        insert plb;
        
        Set<String> subIdSet = new Set<String>();
        for(Zuora__Subscription__c sub:subRecs){
            subIdSet.add(sub.Id);
        }
        //end test data
    
        test.startTest();
            PageReference pageRef = Page.AirlineSubscriptions;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('issueDate', string.valueOf(system.now()));
            ApexPages.currentPage().getParameters().put('id', plb[0].Id);
        
            PackingLabelsController cont = new PackingLabelsController();
            cont.overseasReportHardCopy(subIdSet);
            cont.initializeOSW();
            cont.initializeAirline();
        test.stopTest();
    }
    
    static testMethod void testPackingLabelsControllerAirline(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.AccountNumber = 'unique123456';
        acc.Airline_Indicator__c = true;
        insert acc;
        
        Packing_Grp__c pGRP = new Packing_Grp__c();
        pGRP.Packing_Code__c = '001';
        pGRP.Packing_Group_Description__c = 'Description';
        insert pGRP;
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Code__c = '6000';
        country.Country_Name__c = 'Country';
        insert country;
        
        Country__c cq = [SELECT Country_Name__c FROM Country__c Where id=:country.Id];
        system.assertNotEquals(cq.Country_Name__c, null);
        
        City__c city = TestDataFactory.createCity(1)[0];
        city.Flight_Number_1__c = 'F123';
        city.Flight_Number_2__c = 'F456';
        city.Name = 'City';
        city.Country__c = country.Id;
        insert city;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
        add.Packing_Code__c = pGRP.ID;
        add.Country__c = country.Id;
        add.City__c = city.Id;
        insert add;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.Recipient_Number__c = 123456;
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
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
        
        counter=0;
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(6);
        for(Zuora__Subscription__c sub:subRecs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.subscription_type__c = 'Publication';
            sub.Recipient_Contact__c = con.Id;
            sub.Zuora__SubscriptionEndDate__c = date.today();
            sub.Qty1__c = '3';
            sub.Zuora__Account__c = acc.Id;
            sub.Main_Package__c = pack.Id;
            sub.Frequency__c = GlobalVariableClass.FREQUENCY_MONFRI;
            if(counter==1){
                sub.Frequency__c = GlobalVariableClass.FREQUENCY_FRISUN;
            }
            else if(counter==2){
                sub.Frequency__c = GlobalVariableClass.FREQUENCY_SATSUN;
            }
            else if(counter==3){
                sub.Frequency__c = 'Mon-Sat';
            }
            else if(counter==4){
                sub.Frequency__c = GlobalVariableClass.FREQUENCY_DEFAULT;
            }
            counter++;
        }
        insert subRecs;
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(6);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs[counter].Id;
            sp.Zuora__UOM__c = 'UOM001';
            sp.PublicationCode__c = 'BH';
            if(counter==0){
                sp.PublicationCode__c = 'ZB';  
            }
            else if(counter==1){
                sp.PublicationCode__c = 'TM';   
            }
            else if(counter==2){
                sp.PublicationCode__c = 'BT';   
            }
            else if(counter==3){
                sp.PublicationCode__c = 'ST';   
            }
            else if(counter==4){
                sp.PublicationCode__c = 'NP';   
            }
            else if(counter==5){
                sp.Zuora__Subscription__c = subRecs[0].Id; 
                sp.PublicationCode__c = 'WB';   
            }
            counter++;
        }
        insert spc;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = 'BH';
        pub.Platform_Type__c = 'Print';
        insert pub;
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id=:acc.Id];
        
        List<Packing_Label_Batch__c> plb = new List<Packing_Label_Batch__c>();
        for(counter=0;counter<6;counter++){
            Packing_Label_Batch__c p = new Packing_Label_Batch__c();
            p.Subscription__c = subRecs[counter].Id; 
            p.Subscriber_Account_Number__c = accQ.AccountNumber;
            p.Recipient_Type__c = 'Airline';
            p.Mailing_Agent_Account_Number__c = accQ.AccountNumber;
            p.Issue_Date__c = date.today();
            plb.add(p);  
        }
        insert plb;
        
        Set<String> subIdSet = new Set<String>();
        for(Zuora__Subscription__c sub:subRecs){
            subIdSet.add(sub.Id);
        }
        //end test data
    
        test.startTest();
            PageReference pageRef = Page.AirlineSubscriptions;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('issueDate', string.valueOf(system.now()));
            ApexPages.currentPage().getParameters().put('id', plb[0].Id);
        
            PackingLabelsController cont = new PackingLabelsController();
            cont.overseasReportHardCopy(subIdSet);
            cont.initializeOSW();
            cont.airlineReportHardCopy();
            cont.initializeAirline();
            cont.initializeMagazineWrap();
            cont.querySub('local', '');
            cont.querySub('internal', '');
            cont.querySub('airline', '');
            cont.querySub('overseas', '');
            cont.pubCode = '';
            cont.address1 = '';
            cont.address2 = '';
            cont.address3 = '';
            cont.address4 = '';
            cont.address5 = '';
            
            ApexPages.currentPage().getParameters().put('id', acc.Id);
            PackingLabelsController cont2 = new PackingLabelsController();
            cont2.airlineReportHardCopy();
        test.stopTest();
    }
}