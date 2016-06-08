@isTest (Seealldata = TRUE)
    public class STARTSUB_DirectOrderEntryControllerTest {
         static testMethod void testSTARTSUB_DirectOrderEntryController(){
         
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        database.insert(acc);
    
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
            
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true; 
        insert con;
    
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '2';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        database.insert(promo);
    
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today()+1;
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub.id;
        }      
        database.insert(orders);
        
        Zuora__Subscription__c subz = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE ID = : sub.Id];
             
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = subz.Zuora__SubscriptionEndDate__c+1;          
        }
        database.insert(olis);
        
        Test.startTest();
        
        //PageReference pRef = Page.STARTSUB_DirectOrderEntry;
        //Test.setCurrentPage(pRef);

        ApexPages.currentPage().getParameters().put('orderId', orders[0].Id);
        ApexPages.currentPage().getParameters().put('id', orders[0].Id);

        STARTSUB_DirectOrderEntryController startSubDir = new STARTSUB_DirectOrderEntryController();
        startSubDir.initializeData();
        startSubDir.initializeOrderLineItem();
        startSubDir.selectedPackageId =  Id.valueOf(pack.Id);
        startSubDir.populateSubscriptionDetail();
        startSubDir.addLineItem();
        startSubDir.removeLineItem();
       
             
        startSubDir.executeSearch();
        startSubDir.searchFrom = 'Package';
        startSubDir.executeSearch();
        startSubDir.searchFrom = 'Promotion';
        startSubDir.executeSearch();
             
        startSubDir.searchPackage();
        startSubDir.searchPromotion();
        startSubDir.populateAddOn();
        startSubDir.getPackageDetails();
        startSubDir.getPromotionPackages();
        startSubDir.populatePromotionGifts();
        
        Asia1__c asia1Account = new Asia1__c();
        startSubDir.asia1SingleAccount = asia1Account;
        
        startSubDir.validateNewAsia1Account();
        startSubDir.selectAsia1Source();
        
        try{
            startSubDir.addAsia1Account();    
        }catch(Exception e){}
    
        try{
            startSubDir.addAsia1ExistingAccount();    
        }catch(Exception e){}
        
        try{
            startSubDir.xx();    
        }catch(Exception e){}
        
    try{
          startSubDir.removeAsia1Subscription();    
        }catch(Exception e){}
        
        try{
          startSubDir.changeAsia1Mode();       
        }catch(Exception e){}
        
        try{
          startSubDir.getAsia1ExistingAccounts();       
        }catch(Exception e){}        
             
        
        STARTSUB_DirectOrderEntryController.GiftWrapper startSubDir_gw = new STARTSUB_DirectOrderEntryController.GiftWrapper();
        startSubDir_gw.selectGift = true;
        startSubDir_gw.promotionGift = null;
            
        STARTSUB_DirectOrderEntryController.Asia1Wrapper startSubDir_aw = new STARTSUB_DirectOrderEntryController.Asia1Wrapper();
        startSubDir_aw.asia1Id = 'test';
        startSubDir_aw.userId = 'test';
        startSubDir_aw.asia1Subscriptions = null;
        
        STARTSUB_DirectOrderEntryController.Asia1SubscriptionWrapper startSubDir_asw = new STARTSUB_DirectOrderEntryController.Asia1SubscriptionWrapper();
        startSubDir_asw.concurrent = 1;
        startSubDir_asw.serviceFlagId = 'test';
        startSubDir_asw.serviceFlagName = 'test';
        startSubDir_asw.status = 'test';
             
            
        Test.stopTest();
    
    }
    
         static testMethod void testSTARTSUB_DirectOrderEntryController2(){
         
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        database.insert(acc);
    
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
            
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true; 
        insert con;
    
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '2';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        database.insert(promo);
    
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        database.insert(pack);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today()+1;
        database.insert(sub);
        
         List<Service_Access_Flag__c> servAccess = Testdatafactory.createServiceAccessFlag(1);
         servAccess[0].Name = 'AccessOne';
         database.insert(servAccess);
        
         List<Asia1__c> asiaOne = Testdatafactory.createAsiaOne(1);
         asiaOne[0].Display_Name__c = 'Asia1';
         asiaOne[0].User_ID_LDAP_ID__c = 'UserLdap1';
         asiaOne[0].Password__c = 'ab12cd';
         database.insert(asiaOne);
            
         List<Asia1_Subscription__c> asiaOneSub= TestdataFactory.createAsiaOneSubscription(2);
         asiaOneSub[0].Asia1__c = asiaOne[0].id;
         asiaOneSub[0].Status__c = 'Enabled';
         asiaOneSub[0].Subscription__c = sub.id;
         asiaOneSub[0].Service_Access_Flag__c = servAccess[0].id;
         asiaOneSub[1].Asia1__c = asiaOne[0].id;
         asiaOneSub[1].Status__c = 'Enabled';
         asiaOneSub[1].Subscription__c = sub.id;
         asiaOneSub[1].Service_Access_Flag__c = servAccess[0].id;
         database.insert(asiaOneSub);
        
        List<Order__c> orders = TestDataFactory.createOrder(2);
        orders[0].Account__c = acc.id;
        orders[0].Order_Type__c = 'Renewal'; 
        orders[0].Base_Subscription__c = sub.id;
        orders[1].Account__c = acc.id;
        database.insert(orders);
        
        Zuora__Subscription__c subz = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE ID = : sub.Id];
             
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = subz.Zuora__SubscriptionEndDate__c+1;          
        }
        database.insert(olis);
              
        /*Service_Access_Flag__c servAccessFlag = TestdataFactory.createServiceAccessFlag(1)[0];
        database.insert(servAccessFlag);
        
        Package_Access_Flag__c accessFlag = new Package_Access_Flag__c ();
        accessFlag.Package_Service_Access_Flag__c = servAccessFlag.id;
        accessFlag.No_of_Concurrent_Users__c = 5;
        accessFlag.Package__c = pack.id;
        database.insert(accessFlag);*/
        
        
        Test.startTest();
        
        
        //PageReference pRef = Page.STARTSUB_DirectOrderEntry;
        //Test.setCurrentPage(pRef);

        ApexPages.currentPage().getParameters().put('orderId', orders[0].Id);
        ApexPages.currentPage().getParameters().put('id',orders[0].Id);
        STARTSUB_DirectOrderEntryController.retrieveRelatedPackages('promo.id');
        STARTSUB_DirectOrderEntryController startSubDir = new STARTSUB_DirectOrderEntryController();
        startSubDir.initializeData();
        startSubDir.initializeOrderLineItem();
        startSubDir.selectedPackageId =  Id.valueOf(pack.Id);
        startSubDir.populateSubscriptionDetail();
        startSubDir.addLineItem();
        startSubDir.removeLineItem();
        
         startSubDir.asia1SelectedExistingId = ''+asiaOne[0].id;
             
        startSubDir.executeSearch();
        startSubDir.searchFrom = 'Package';
        startSubDir.executeSearch();
        startSubDir.searchFrom = 'Promotion';
        startSubDir.executeSearch();
             
        startSubDir.searchPackage();
        startSubDir.searchPromotion();
        startSubDir.populateAddOn();
        startSubDir.getPackageDetails();
        startSubDir.getPromotionPackages();
        startSubDir.populatePromotionGifts();
        
        //Asia1__c asia1Account = new Asia1__c();
        startSubDir.asia1SingleAccount = asiaOne[0];
        startSubDir.asia1SingleSubscription = asiaOneSub[0];
        startSubDir.validateNewAsia1Account();
        startSubDir.selectAsia1Source();
        
        try{
            startSubDir.addAsia1Account();    
        }catch(Exception e){}
        
        try{
            startSubDir.addAsia1ExistingAccount();    
        }catch(Exception e){}
        
        try{
            startSubDir.xx();    
        }catch(Exception e){}
        
        try{
            startSubDir.removeAsia1Subscription();    
        }catch(Exception e){}
        
        try{
            startSubDir.changeAsia1Mode();       
        }catch(Exception e){}
        
        try{
            startSubDir.getAsia1ExistingAccounts();       
        }catch(Exception e){}        
             
        
        STARTSUB_DirectOrderEntryController.GiftWrapper startSubDir_gw = new STARTSUB_DirectOrderEntryController.GiftWrapper();
        startSubDir_gw.selectGift = true;
        startSubDir_gw.promotionGift = null;
            
        STARTSUB_DirectOrderEntryController.Asia1Wrapper startSubDir_aw = new STARTSUB_DirectOrderEntryController.Asia1Wrapper();
        startSubDir_aw.asia1Id = 'test';
        startSubDir_aw.userId = 'test';
        startSubDir_aw.asia1Subscriptions = null;
        
        STARTSUB_DirectOrderEntryController.Asia1SubscriptionWrapper startSubDir_asw = new STARTSUB_DirectOrderEntryController.Asia1SubscriptionWrapper();
        startSubDir_asw.concurrent = 1;
        startSubDir_asw.serviceFlagId = 'test';
        startSubDir_asw.serviceFlagName = 'test';
        startSubDir_asw.status = 'test';
        startSubDir.retrieveServiceFlags(pack.id);
        startSubDir.xx();
            
        Test.stopTest();
    
    }
}