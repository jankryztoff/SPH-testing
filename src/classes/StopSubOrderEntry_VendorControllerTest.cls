/*
* Class Name: <StopSubOrderEntry_VendorControllerTest>
* @author: Reszel Garrie Pineda
* Date: <02/13/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for StopSubOrderEntry_VendorController>
*/
@isTest (seeAllData= True)
private class StopSubOrderEntry_VendorControllerTest {
    
    /* @description: This method checks StopSubOrderEntry_VendorController methods*/ 
    static testMethod void StopSubOrderEntry_VendorContTest() {   
        
        //test data creation
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
        
        sObjMap = TestDataFactory.createSubscriptionPackage();
        
        Test.startTest(); 
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c ='Print';
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Platform_Type__c ='Print';
        npub.Publish_Pattern__c = 'Weekdays';
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;      
        
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        orderLineItemList[0].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[0].Start_Date__c = date.today().addDays(2);
        orderLineItemList[0].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[0].Publication__c = pub.id;
        orderLineItemList[0].Stop_Request_Date__c = date.today();
        orderLineItemList[1].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[1].Start_Date__c = date.today().addDays(2);
        orderLineItemList[1].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[1].Publication__c = npub.id;
        orderLineItemList[1].Stop_Request_Date__c = date.today();
        insert orderLineItemList;
               
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;        
        insert sv;         
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[0].Account__c = sObjMap.get('Account').Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = sObjMap.get('Order__c').Id;
        svp[1].Publication__c = npub.Id;
        svp[1].Account__c = sObjMap.get('Account').Id;        
        insert svp;
        
        Case cas = (Case) sObjMap.get('Case');
        
        //end of test data creation        
        System.assertEquals(true, sObjMap.get('Account')<>null);
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef );
        ApexPages.currentPage().getParameters().put('accountId',sObjMap.get('Account').id);
        ApexPages.currentPage().getParameters().put('conId',sObjMap.get('Recipient Contact').id);
        ApexPages.currentPage().getParameters().put('orderId',sObjMap.get('Order__c').id);  
        ApexPages.currentPage().getParameters().put('recordtype',cas.RecordTypeId);
        
        StopSubOrderEntry_VendorController controller = new StopSubOrderEntry_VendorController();        
        
        controller.getAccount();
        controller.getContact();
        controller.pubObject = svp[0];
        controller.getPubSelections();
        controller.getOrder();
        controller.addLineItem();
        controller.checkDuplicatePublication(pub.id);
        controller.checkDuplicateOrderLineItem(orderLineItemList[0].id);        
        
        controller.pub = pub;
        controller.counter = 1;
        controller.nonPublicationRecordList = nonPubList;
        Test.stopTest();
    }//end of StopSubOrderEntry_VendorContTest()
    
    /* @description: This method checks StopSubOrderEntry_VendorController methods*/ 
    static testMethod void StopSubOrderEntry_VendorContTest2() {   
        
        //test data creation
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
        
        sObjMap = TestDataFactory.createSubscriptionPackage();
        
        Test.startTest();   
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c ='Print';
        pub.Publish_Pattern__c = 'Weekdays';
        pubList.add(pub);
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Platform_Type__c ='Print';
        npub.Publish_Pattern__c = 'Weekdays';
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;        
        
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        orderLineItemList[0].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[0].Start_Date__c = date.today().addDays(2);
        orderLineItemList[0].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[0].Publication__c = pub.id;
        orderLineItemList[0].Stop_Request_Date__c = date.today();
        orderLineItemList[1].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[1].Start_Date__c = date.today().addDays(2);
        orderLineItemList[1].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[1].Publication__c = npub.id;
        orderLineItemList[1].Stop_Request_Date__c = date.today();
        insert orderLineItemList;
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;        
        insert sv;         
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[0].Account__c = sObjMap.get('Account').Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = sObjMap.get('Order__c').Id;
        svp[1].Publication__c = npub.Id;
        svp[1].Account__c = sObjMap.get('Account').Id;        
        insert svp;
        //end of test data creation
        System.assertEquals(true, sObjMap.get('Recipient Contact')<>null);
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef );
        ApexPages.currentPage().getParameters().put('accountId',sObjMap.get('Account').id);
        ApexPages.currentPage().getParameters().put('conId',sObjMap.get('Recipient Contact').id);
        ApexPages.currentPage().getParameters().put('orderId',sObjMap.get('Order__c').id);
        
        StopSubOrderEntry_VendorController controller = new StopSubOrderEntry_VendorController();
        controller.getAccount();
        controller.getContact();
        controller.pubObject = svp[0];
        controller.getPubSelections();
        controller.getOrder();
        controller.addLineItem();
        controller.edit();
        controller.earliestStopDate();
        
        try{
            controller.submit();
        }catch(Exception ex){
            System.Debug(ex.getMessage());
        }        
        
        Test.stopTest();
    }//end of StopSubOrderEntry_VendorContTest2()
    
    /* @description: This method checks StopSubOrderEntry_VendorController methods*/ 
    static testMethod void StopSubOrderEntry_VendorContTest3() {   
        
        //test data creation
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
        
        sObjMap = TestDataFactory.createSubscriptionPackage();
        
        Test.startTest();   
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c ='Print';
        pub.Publish_Pattern__c = 'Weekdays';
        pubList.add(pub);
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Platform_Type__c ='Print';
        npub.Publish_Pattern__c = 'Weekdays';
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;        
        
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        orderLineItemList[0].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[0].Start_Date__c = date.today().addDays(2);
        orderLineItemList[0].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[0].Publication__c = pub.id;
        orderLineItemList[0].Stop_Request_Date__c = date.today();
        orderLineItemList[1].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[1].Start_Date__c = date.today().addDays(2);
        orderLineItemList[1].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[1].Publication__c = npub.id;
        orderLineItemList[1].Stop_Request_Date__c = date.today();
        insert orderLineItemList;
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;        
        insert sv;         
        System.assertEquals(true, sv<>null);
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[0].Account__c = sObjMap.get('Account').Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = sObjMap.get('Order__c').Id;
        svp[1].Publication__c = npub.Id;
        svp[1].Account__c = sObjMap.get('Account').Id;        
        insert svp;
        //end of test data creation        
        
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef );
        ApexPages.currentPage().getParameters().put('accountId',sObjMap.get('Account').id);
        ApexPages.currentPage().getParameters().put('conId',sObjMap.get('Recipient Contact').id);
        ApexPages.currentPage().getParameters().put('orderId',sObjMap.get('Order__c').id);
        
        StopSubOrderEntry_VendorController controller = new StopSubOrderEntry_VendorController();
        
        controller.getPubSelections();
        controller.saveDraft();
        controller.cancel();
        controller.removePub();           
        controller.voidStatus();
        
        Test.stopTest();
    }//end of StopSubOrderEntry_VendorContTest3()
    
    /* @description: This method checks StopSubOrderEntry_VendorController methods*/ 
    static testMethod void StopSubOrderEntry_VendorContTest4() {   
        
        //test data creation
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
        
        sObjMap = TestDataFactory.createSubscriptionPackage();
        
        Test.startTest();   
        
        Order__c order = (Order__c) sObjMap.get('Order__c');
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        update order;    
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c ='Print';
        pub.Publish_Pattern__c = 'Weekdays';
        pubList.add(pub);
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Platform_Type__c ='Print';
        npub.Publish_Pattern__c = 'Weekdays';
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;        
        
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        orderLineItemList[0].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[0].Start_Date__c = date.today().addDays(2);
        orderLineItemList[0].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[0].Publication__c = pub.id;
        orderLineItemList[1].Stop_Request_Date__c = date.today().addDays(-2);
        orderLineItemList[1].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[1].Start_Date__c = date.today().addDays(2);
        orderLineItemList[1].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[1].Publication__c = npub.id;
        orderLineItemList[1].Stop_Request_Date__c = date.today().addDays(-2);
        insert orderLineItemList;
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;        
        insert sv;         
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[0].Account__c = sObjMap.get('Account').Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = sObjMap.get('Order__c').Id;
        svp[1].Publication__c = npub.Id;
        svp[1].Account__c = sObjMap.get('Account').Id;        
        insert svp;
        
                //end of test data creation
        System.assertEquals(true, svp<>null);
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef );
        ApexPages.currentPage().getParameters().put('accountId',sObjMap.get('Account').id);
        ApexPages.currentPage().getParameters().put('conId',sObjMap.get('Recipient Contact').id);
        ApexPages.currentPage().getParameters().put('orderId',sObjMap.get('Order__c').id);
        ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Complaint - Magazine'));
        
        StopSubOrderEntry_VendorController controller = new StopSubOrderEntry_VendorController();
        
        controller.pubObject = svp[0];    
        controller.getPubSelections();
        controller.saveDraft();
        controller.cancel();
        
        controller.voidStatus();
        
        Test.stopTest();
    }//end of StopSubOrderEntry_VendorContTest4()
     static testMethod void StopSubOrderEntry_VendorContTestApril() {   
        
        //test data creation
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
        
        sObjMap = TestDataFactory.createSubscriptionPackage();
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
        insert address;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = address.id;
        con.Recipient_Indicator__c = true;
       // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;

        Test.startTest();   
        
        Order__c order = (Order__c) sObjMap.get('Order__c');
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        update order;    
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c ='Print';
        pub.Publish_Pattern__c = 'Weekdays';
        pubList.add(pub);
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'N';
        npub.Platform_Type__c ='Print';
        npub.Publish_Pattern__c = 'Weekdays';
        pubList.add(npub);
        insert pubList;            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;        
        
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        orderLineItemList[0].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[0].Start_Date__c = date.today().addDays(2);
        orderLineItemList[0].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[0].Publication__c = pub.id;
        orderLineItemList[1].Stop_Request_Date__c = date.today().addDays(-2);
        orderLineItemList[1].Order__c = sObjMap.get('Order__c').Id;
        orderLineItemList[1].Start_Date__c = date.today().addDays(2);
        orderLineItemList[1].Stop_Date__c = date.today().addDays(4);
        orderLineItemList[1].Publication__c = npub.id;
        orderLineItemList[1].Stop_Request_Date__c = date.today().addDays(-2);
        insert orderLineItemList;
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = sObjMap.get('Account').Id;        
        sv.Recipient__c = con.id;
        insert sv;         
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = sObjMap.get('Order__c').Id;
        svp[0].Publication__c = pub.Id;
        svp[0].Account__c = sObjMap.get('Account').Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = sObjMap.get('Order__c').Id;
        svp[1].Publication__c = npub.Id;
        svp[1].Account__c = sObjMap.get('Account').Id;        
        insert svp;
        
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        cas.Status = 'Closed';
        cas.Recordtypeid = [SELECT id, Name from RecordType where sObjectType ='Case' and Name ='Change of Address/Vendor' LIMIT 1].id;
        database.insert(cas);
        
        Case_Vendor_Subscription__c caseVenSub = TestDataFactory.createCaseVendorSub(1)[0];
        caseVenSub.Account__c = sObjMap.get('Account').Id;
        caseVenSub.Case__c = cas.id; 
        casevenSub.Subscription_Vendor__c = sv.id;
        casevenSub.Address__c = address.id;
        database.insert(caseVenSub);
        
        //end of test data creation
        System.assertEquals(true, svp<>null);
        PageReference pageRef = new Pagereference('/apex/StopSubOrderEntry_Vendor_View');
        Test.setCurrentPage(pageRef );
        ApexPages.currentPage().getParameters().put('accountId',sObjMap.get('Account').id);
        ApexPages.currentPage().getParameters().put('conId',sObjMap.get('Recipient Contact').id);
        ApexPages.currentPage().getParameters().put('orderId',sObjMap.get('Order__c').id);
        ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Complaint - Magazine'));
        
        StopSubOrderEntry_VendorController controller = new StopSubOrderEntry_VendorController();
        
        controller.pubObject = svp[0];    
        controller.getPubSelections();
        controller.saveDraft();
        controller.cancel();
        
        controller.voidStatus();
        
        Test.stopTest();
    }//end of StopSubOrderEntry_VendorContTestApril
}//end of StopSubOrderEntry_VendorControllerTest