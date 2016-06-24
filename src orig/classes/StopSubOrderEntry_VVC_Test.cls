/*
*@date: 02/19/2015
*@description: Test class for StopSubOrderEntry_ViewVendorController 
*/
@isTest (seeAllData= True)
Public Class StopSubOrderEntry_VVC_Test {
    /*
    Static testMethod void TestStopSubOrderEntry_ViewVendorController() { 
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
       
        sObjMap = TestDataFactory.createSubscriptionPackage(); 
        Test.startTest(); 
      
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'N';
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;      
        
        Order_Line_Item_Vendor__c orderLineItemList = TestDataFactory.createOrderLineItemVendor(1)[0];
            orderLineItemList.Order__c = sObjMap.get('Order__c').Id;
            orderLineItemList.Start_Date__c = date.today()+1;
            orderLineItemList.Stop_Date__c = date.today().addDays(2);
            orderLineItemList.Publication__c = pub.id;
            orderLineItemList.Stop_Request_Date__c = date.today();
            orderLineItemList.Additional_Termination_Comment_del__c = 'Test1';
            orderLineItemList.Stop_Request_Date__c = date.today()+1;
         insert orderLineItemList;
        
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;
        insert sv;
         
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = sObjMap.get('Order__c').Id;
        svp[1].Publication__c = npub.Id;
        insert svp;
        
                               
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId',sObjMap.get('Account').id);
        ApexPages.currentPage().getParameters().put('orderId',sObjMap.get('Order__c').id);
        //ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Account_Direct Corporate'));
        
        StopSubOrderEntry_ViewVendorController controller = new StopSubOrderEntry_ViewVendorController();
        try{
            controller.getOrder();   
            controller.getAccount();
            controller.cancel();
            controller.edit();
            controller.voidStatus();
        }catch (Exception e){
            
        }
        Test.stopTest();
    }   
    Static testMethod void TestStopSubOrderEntry_ViewVendorController2() { 
       Map<String, SObject> sObjMap = new Map<String, SObject>(); 
       
        sObjMap = TestDataFactory.createSubscriptionPackage(); 
      
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB2';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'N';
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB2';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB2';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;      
        
        Order_Line_Item_Vendor__c orderLineItemList = TestDataFactory.createOrderLineItemVendor(1)[0];
            orderLineItemList.Order__c = sObjMap.get('Order__c').Id;
            orderLineItemList.Start_Date__c = date.today()+1;
            orderLineItemList.Stop_Date__c = date.today().addDays(2);
            orderLineItemList.Publication__c = pub.id;
            orderLineItemList.Stop_Request_Date__c = date.today();
            orderLineItemList.Additional_Termination_Comment_del__c = 'Test13';
            orderLineItemList.Stop_Request_Date__c = date.today();
            orderLineItemList.Additional_Termination_Comment_del__c  = null;
        insert orderLineItemList;
        
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;
        insert sv;
         
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(1);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = npub.Id;
        insert svp;
        
        Test.startTest();                       
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId',sObjMap.get('Account').id);
        ApexPages.currentPage().getParameters().put('orderId',sObjMap.get('Order__c').id);
        //ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Account_Direct Corporate'));        
        StopSubOrderEntry_ViewVendorController controller = new StopSubOrderEntry_ViewVendorController();
      
        try{
            controller.createOrderLine(svp[0]);
        }catch (Exception e){
        
        }
        controller.submit();
        Test.stopTest();
    }
    /*
     Static testMethod void TestFailEntry1() { 
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
       
        sObjMap = TestDataFactory.createSubscriptionPackage(); 
        
      
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'N';
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;      
        
        Order_Line_Item_Vendor__c orderLineItemList = TestDataFactory.createOrderLineItemVendor(1)[0];
            orderLineItemList.Order__c = sObjMap.get('Order__c').Id;
            orderLineItemList.Start_Date__c = date.today()+1;
            orderLineItemList.Stop_Date__c = date.today().addDays(2);
            orderLineItemList.Publication__c = pub.id;
            orderLineItemList.Stop_Request_Date__c = date.today();
            orderLineItemList.Additional_Termination_Comment_del__c = 'Test1';
            orderLineItemList.Stop_Request_Date__c = date.today()+1;
         insert orderLineItemList;
        
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;
        insert sv;
         
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = sObjMap.get('Order__c').Id;
        svp[1].Publication__c = npub.Id;
        insert svp;
        
        Test.startTest();                        
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId',sObjMap.get('Account').id);
        
        StopSubOrderEntry_ViewVendorController controller = new StopSubOrderEntry_ViewVendorController();
        try{
            controller.getOrder();   
            controller.getAccount();
            controller.cancel();
            controller.edit();
            controller.voidStatus();
        }catch (Exception e){
            
        }
        Test.stopTest();
       }    
        Static testMethod void TestFailEntry2() { 
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
       
        sObjMap = TestDataFactory.createSubscriptionPackage(); 
        
      
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'N';
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;      
        
        Order_Line_Item_Vendor__c orderLineItemList = TestDataFactory.createOrderLineItemVendor(1)[0];
            orderLineItemList.Order__c = sObjMap.get('Order__c').Id;
            orderLineItemList.Start_Date__c = date.today()+1;
            orderLineItemList.Stop_Date__c = date.today().addDays(2);
            orderLineItemList.Publication__c = pub.id;
            orderLineItemList.Stop_Request_Date__c = date.today();
            orderLineItemList.Additional_Termination_Comment_del__c = 'Test1';
            orderLineItemList.Stop_Request_Date__c = date.today()+1;
         insert orderLineItemList;
        
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;
        insert sv;
         
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = sObjMap.get('Order__c').Id;
        svp[1].Publication__c = npub.Id;
        insert svp;
        
        Test.startTest();                        
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('orderId',sObjMap.get('Order__c').id);         
        StopSubOrderEntry_ViewVendorController controller = new StopSubOrderEntry_ViewVendorController();
        try{
            controller.getOrder();   
            controller.getAccount();
            controller.cancel();
            controller.edit();
            controller.voidStatus();
        }catch (Exception e){
            System.debug ('Error encountered: ' + e);    
        }
        Test.stopTest();
       }
        */
      
}