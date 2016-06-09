@isTest(seeAllData = true)
private class CreateVendorOrderEntryControllerTest2{
    
    private static String sphSysAd = ConstantsSLB.getKeyId('Profile_System Administrator');
    private static String caseRenewId = ConstantsSLB.getKeyId('Case Renewal of Subscription');
    private static User usrTst;
    
    /**
    *  To will create test data
    *  @name createTestData
    *  @param none
    *  @return none
    *  @throws na
    */    
    private static void createTestData() {
        //test User - change to appropriate Profile
        usrTst = new User(
                     alias = 'testuser', 
                     email = 'testUser123@salesforce.com', 
                     emailencodingkey = 'UTF-8', 
                     firstname = 'Insert', 
                     lastname = 'Tester', 
                     languagelocalekey = 'en_US', 
                     localesidkey = 'en_US', 
                     profileid = sphSysAd,
                     //UserRoleId = '',
                     timezonesidkey = 'America/Los_Angeles', 
                     username = 'testUser123@salesforce.com');
    }
    
    /**
    *  To test CreateVendorOrderEntryController class
    *  @name testCreateVendorEntry1
    *  @param none
    *  @return none
    *  @throws na
    */    
    
    static testMethod void testCreateVendorEntry1() { 
        createTestData();

        system.runAs(usrTst) {
        
            //insert test data
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            insert accList;
            
            system.assertNotEquals(null, accList[0].id);
            system.assertNotEquals(null, accList[1].id);
            
            List<Order__c> orderList = TestDataFactory.createOrder(2);
            //set order values
            orderList[0].Account__c = accList[0].id;
            orderList[0].Status__c = 'Draft';
            orderList[0].DTL_Date__c = date.today();
            orderList[1].Account__c = accList[1].id;
            orderList[1].Status__c = 'Draft';
            insert orderList;
            
            system.assertNotEquals(null, orderList[0].id);
            system.assertNotEquals(null, orderList[1].id);
            
            //sunday publication
            Publication__c sundayPub = TestDataFactory.createPublication(1)[0];
            sundayPub.Product_Family__c = 'ABCDE';
            sundayPub.Published_Days__c = 'YYYYYYY';
            sundayPub.Publication_Type__c = 'Y';
            sundayPub.Sunday_Publication__c = null;
            insert sundayPub;
            
            system.assertNotEquals(null, sundayPub.id);
            
            //create publications
            List<Publication__c> publicationList = TestDataFactory.createPublication(3);
            publicationList[0].Product_Family__c = 'ABCDE';
            publicationList[0].Published_Days__c = 'YYYYYYY';
            publicationList[0].Publication_Type__c = 'Y';
            publicationList[1].Product_Family__c = 'VWXYZ';
            publicationList[1].Published_Days__c = 'YYYYYYY';
            publicationList[1].Publication_Type__c = 'N';
            publicationList[2].Product_Family__c = 'QRSTU';
            publicationList[2].Published_Days__c = 'YYYYYYY';
            publicationList[2].Publication_Type__c = 'N';
            insert publicationList;
            
            system.assertNotEquals(null, publicationList[0].id);
            system.assertNotEquals(null, publicationList[1].id);
            system.assertNotEquals(null, publicationList[2].id);
            
            //create oliv
            List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(3);
            orderLineItemList[0].Order__c = orderList[0].id;
            orderLineItemList[0].Start_Date__c = date.today().addDays(1);
            orderLineItemList[0].Stop_Date__c = date.today().addDays(2);
            orderLineItemList[1].Order__c = orderList[0].id;
            orderLineItemList[1].Start_Date__c = date.today().addDays(1);
            orderLineItemList[1].Stop_Date__c = date.today().addDays(2);
            orderLineItemList[2].Order__c = orderList[0].id;
            orderLineItemList[2].Start_Date__c = date.today().addDays(1);
            orderLineItemList[2].Stop_Date__c = date.today().addDays(2);
            
            //set specialPublications
            //orderLineItemList[0].Publication__c = publicationList[0].Id;
            //orderLineItemList[1].Publication__c = publicationList[1].Id;
            //orderLineItemList[2].Publication__c = publicationList[2].Id;
            
            //set Wrapper_Number__c
            orderLineItemList[0].Wrapper_Number__c = 1;
            orderLineItemList[1].Wrapper_Number__c = 6;
            orderLineItemList[2].Wrapper_Number__c = 0;
            insert orderLineItemList;
            
            system.assertNotEquals(null, orderLineItemList[0].id);
            system.assertNotEquals(null, orderLineItemList[1].id);
            system.assertNotEquals(null, orderLineItemList[2].id);
            
            test.startTest();
            
            //set page - account passed - remove publication
            PageReference pageRef1 = Page.CreateVendorOrderEntry;
            pageRef1.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef1);
            CreateVendorOrderEntryController createVendorEntry1 = new CreateVendorOrderEntryController();
            createVendorEntry1.index = '1';
            createVendorEntry1.removePub();
            createVendorEntry1.pub = publicationList[0];
            createVendorEntry1.oli = orderLineItemList[0];
            
            //set page - no account passed
            PageReference pageRef2 = Page.CreateVendorOrderEntry;
            Test.setCurrentPage(pageRef2);
            CreateVendorOrderEntryController createVendorEntry2 = new CreateVendorOrderEntryController();
            createVendorEntry2.addOrder();
            
            //set page - no account passed - no order
            PageReference pageRef3 = Page.CreateVendorOrderEntry;
            pageRef3.getParameters().put('accountid', accList[1].Id);
            Test.setCurrentPage(pageRef3);
            CreateVendorOrderEntryController createVendorEntry3 = new CreateVendorOrderEntryController();
            
            //set page - account passed - save draft
            PageReference pageRef4 = Page.CreateVendorOrderEntry;
            pageRef4.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef4);
            CreateVendorOrderEntryController createVendorEntry4 = new CreateVendorOrderEntryController();
            createVendorEntry4.saveDraft();
            
            //set page - account passed - save Draft - cancel
            PageReference pageRef5 = Page.CreateVendorOrderEntry;
            pageRef5.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef5);
            CreateVendorOrderEntryController createVendorEntry5 = new CreateVendorOrderEntryController();
            createVendorEntry5.saveDraft();
            createVendorEntry5.cancel();
            
            //set page - account passed - save Draft - refresh
            PageReference pageRef6 = Page.CreateVendorOrderEntry;
            pageRef6.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef6);
            CreateVendorOrderEntryController createVendorEntry6 = new CreateVendorOrderEntryController();
            createVendorEntry6.saveDraft();
            createVendorEntry6.index = '1';
            createVendorEntry6.refreshStyleClass();
            
            //set page - account passed - submit
            PageReference pageRef7 = Page.CreateVendorOrderEntry;
            pageRef7.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef7);
            CreateVendorOrderEntryController createVendorEntry7 = new CreateVendorOrderEntryController();
            createVendorEntry7.submit();
            
            //set page - account passed - save - edit
            PageReference pageRef8 = Page.CreateVendorOrderEntry;
            pageRef8.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef8);
            CreateVendorOrderEntryController createVendorEntry8 = new CreateVendorOrderEntryController();
            createVendorEntry8.saveDraft();
            createVendorEntry8.edit();
            
            //set page - account passed - save draft - no publication
            PageReference pageRef9 = Page.CreateVendorOrderEntry;
            pageRef9.getParameters().put('accountid', accList[1].Id);
            Test.setCurrentPage(pageRef9);
            CreateVendorOrderEntryController createVendorEntry9 = new CreateVendorOrderEntryController();
            createVendorEntry9.saveDraft();

                        //set page - account passed - change publication
            PageReference pageRef10 = Page.CreateVendorOrderEntry;
            pageRef10.getParameters().put('accountid', accList[1].Id);
            Test.setCurrentPage(pageRef10);
            CreateVendorOrderEntryController createVendorEntry10 = new CreateVendorOrderEntryController();
            
            //set OrWrapper
            List<CreateVendorOrderEntryController.OrWrapper> OWList1 = new List<CreateVendorOrderEntryController.OrWrapper>();
            CreateVendorOrderEntryController.OrWrapper OW1;
            OW1 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[0]);
            OW1.counterWrap = (Integer) orderLineItemList[0].Wrapper_Number__c;
            OW1.oLine.Publication__c = publicationList[0].id;
            OWList1.add(OW1);
            OW1 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[1]);
            OW1.counterWrap = (Integer) orderLineItemList[1].Wrapper_Number__c;
            //OW1.oLine.Publication__c = publicationList[1].id;
            OWList1.add(OW1);
            OW1 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[2]);
            OW1.counterWrap = (Integer) orderLineItemList[2].Wrapper_Number__c;
            //OW1.oLine.Publication__c = publicationList[2].id;
            OWList1.add(OW1); 
            
            createVendorEntry10.orWrapperList = OWList1;
            createVendorEntry10.index = '1';
            createVendorEntry10.changePublication();
            
            //set page - account passed - populate delivery charge
            PageReference pageRef11 = Page.CreateVendorOrderEntry;
            pageRef11.getParameters().put('accountid', accList[1].Id);
            Test.setCurrentPage(pageRef11);
            CreateVendorOrderEntryController createVendorEntry11 = new CreateVendorOrderEntryController();
            createVendorEntry11.populateDeliveryCharge();
            
            //set page - no account passed - ow.counterWrap > counter
            PageReference pageRef12 = Page.CreateVendorOrderEntry;
            Test.setCurrentPage(pageRef12);
            CreateVendorOrderEntryController createVendorEntry12 = new CreateVendorOrderEntryController();
            
            List<CreateVendorOrderEntryController.OrWrapper> OWList2 = new List<CreateVendorOrderEntryController.OrWrapper>();
            CreateVendorOrderEntryController.OrWrapper OW2;
            OW2 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[1]);
            OW2.counterWrap = (Integer) orderLineItemList[1].Wrapper_Number__c;
            OW2.oLine.Start_Date__c = Date.today().addDays(2);
            OW2.oLine.Stop_Date__c = Date.today().addDays(1);
            OW2.oLine.Publication__c = sundayPub.id;
            OWList2.add(OW2);
            OW2.counterWrap = (Integer) orderLineItemList[1].Wrapper_Number__c;
            OW2.oLine.Start_Date__c = Date.today().addDays(1);
            OW2.oLine.Stop_Date__c = Date.today().addDays(2);
            OWList2.add(OW2);
            OW2 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[2]);
            OW2.counterWrap = (Integer) orderLineItemList[2].Wrapper_Number__c;
            OWList2.add(OW2); 
            createVendorEntry12.orWrapperList = OWList2;
            createVendorEntry12.counter = 0;
            createVendorEntry12.addOrder();
 
            //set page - save draft - Error: 'Please enter Start and Stop Date'
            PageReference pageRef14 = Page.CreateVendorOrderEntry;
            pageRef14.getParameters().put('accountid', accList[1].Id);
            Test.setCurrentPage(pageRef14);
            CreateVendorOrderEntryController createVendorEntry14 = new CreateVendorOrderEntryController();
            
            List<CreateVendorOrderEntryController.OrWrapper> OWList4 = new List<CreateVendorOrderEntryController.OrWrapper>();
            CreateVendorOrderEntryController.OrWrapper OW4;
            OW4 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[1]);
            OW4.counterWrap = (Integer) orderLineItemList[1].Wrapper_Number__c;
            OW4.oLine.Start_Date__c = NULL;
            OW4.oLine.Stop_Date__c = NULL;
            OW4.oLine.Publication__c = sundayPub.id;
            OWList4.add(OW4);
            OW4.counterWrap = (Integer) orderLineItemList[2].Wrapper_Number__c;
            OW4.oLine.Start_Date__c = NULL;
            OW4.oLine.Stop_Date__c = NULL;
            OWList4.add(OW4);
                
            createVendorEntry14.orWrapperList = OWList4;
            createVendorEntry14.saveDraft();
            
            
            //set page - save draft - Error: 'Please enter a valid number of publications!'
            PageReference pageRef13 = Page.CreateVendorOrderEntry;
            pageRef13.getParameters().put('accountid', accList[1].Id);
            Test.setCurrentPage(pageRef13);
            CreateVendorOrderEntryController createVendorEntry13 = new CreateVendorOrderEntryController();
            
            List<CreateVendorOrderEntryController.OrWrapper> OWList3 = new List<CreateVendorOrderEntryController.OrWrapper>();
            CreateVendorOrderEntryController.OrWrapper OW3;
            OW3 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[1]);
            OW3.counterWrap = (Integer) orderLineItemList[1].Wrapper_Number__c;
            OW3.oLine.Mon__c = 0;
            OW3.oLine.Tue__c = 0;
            OW3.oLine.Wed__c = 0;
            OW3.oLine.Thu__c = 0;
            OW3.oLine.Fri__c = 0;
            OW3.oLine.Sat__c = 0;
            OW3.oLine.Sun__c = 0;
            OW3.oLine.Publication__c = sundayPub.id;
            OWList3.add(OW3);
            OW3 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[2]);
            OW3.counterWrap = (Integer) orderLineItemList[2].Wrapper_Number__c;
            OW3.oLine.Mon__c = 0;
            OW3.oLine.Tue__c = 0;
            OW3.oLine.Wed__c = 0;
            OW3.oLine.Thu__c = 0;
            OW3.oLine.Fri__c = 0;
            OW3.oLine.Sat__c = 0;
            OW3.oLine.Sun__c = 0;
            OWList3.add(OW3); 
            
            createVendorEntry13.order = orderList[0];
            createVendorEntry13.index = '1';
            createVendorEntry13.orWrapperList = OWList3;
            createVendorEntry13.submit();
            createVendorEntry13.populateDeliveryCharge();
            createVendorEntry13.edit();
            createVendorEntry13.changePublication();
        }
        test.stopTest();
    }
    
    static testMethod void testCreateVendorEntry2() { 
        createTestData();

        system.runAs(usrTst) {
        
            //insert test data
            List<Account> accList = TestDataFactory.createAccount(3, 'Direct Corporate');   
            insert accList;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = accList[0].id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            system.assertNotEquals(null, accList[0].id);
            system.assertNotEquals(null, accList[1].id);
            
            List<Order__c> orderList = TestDataFactory.createOrder(3);
            //set order values
            orderList[0].Account__c = accList[0].id;
            orderList[0].Status__c = 'Draft';
            orderList[0].DTL_Date__c = date.today();
            orderList[0].Recipient_Contact__c = con.id;
            orderList[1].Account__c = accList[1].id;
            orderList[1].Status__c = 'Draft';
            orderList[2].Account__c = accList[2].id;
            orderList[2].Status__c = 'Draft';
            insert orderList;
            
            system.assertNotEquals(null, orderList[0].id);
            system.assertNotEquals(null, orderList[1].id);
            system.assertNotEquals(null, orderList[2].id);
            
            //sunday publication
            Publication__c sundayPub = TestDataFactory.createPublication(1)[0];
            sundayPub.Product_Family__c = 'ABCDE';
            sundayPub.Published_Days__c = 'YYYYYYY';
            sundayPub.Publication_Type__c = 'N';
            sundayPub.Platform_Type__c = 'Print';
            insert sundayPub;
            
            system.assertNotEquals(null, sundayPub.id);
            
            //create publications
            List<Publication__c> publicationList = TestDataFactory.createPublication(3);
            publicationList[0].Product_Family__c = 'ABCDE';
            publicationList[0].Published_Days__c = 'YYYYYYY';
            publicationList[0].Publication_Type__c = 'N';
            publicationList[0].Platform_Type__c = 'Print';
            publicationList[0].Sunday_Publication__c = sundayPub.id;
            publicationList[1].Product_Family__c = 'VWXYZ';
            publicationList[1].Published_Days__c = 'YYYYYYY';
            publicationList[1].Publication_Type__c = 'N';
            publicationList[1].Platform_Type__c = 'Print';
            publicationList[1].Sunday_Publication__c = sundayPub.id;
            publicationList[2].Product_Family__c = 'QRSTU';
            publicationList[2].Published_Days__c = 'YYYYYYY';
            publicationList[2].Publication_Type__c = 'N';
            publicationList[2].Platform_Type__c = 'Print';
            publicationList[2].Sunday_Publication__c = sundayPub.id;
            insert publicationList;
            
            system.assertNotEquals(null, publicationList[0].id);
            system.assertNotEquals(null, publicationList[1].id);
            system.assertNotEquals(null, publicationList[2].id);
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Product_Family__c = 'ABCDE';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Publication_Type__c = 'N';
            pub.Sunday_Publication__c = null;
            pub.Platform_Type__c = 'Print';
            insert pub;
            
            system.assertNotEquals(null, pub.id);
            
            //create oliv
            List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(3);
            orderLineItemList[0].Order__c = orderList[0].id;
            orderLineItemList[0].Start_Date__c = date.today().addDays(1);
            orderLineItemList[0].Stop_Date__c = date.today().addDays(2);
            orderLineItemList[0].Publication__c = publicationList[0].id;
            orderLineItemList[1].Order__c = orderList[0].id;
            orderLineItemList[1].Start_Date__c = date.today().addDays(1);
            orderLineItemList[1].Stop_Date__c = date.today().addDays(2);
            orderLineItemList[1].Publication__c = publicationList[1].id;
            orderLineItemList[2].Order__c = orderList[0].id;
            orderLineItemList[2].Start_Date__c = date.today().addDays(1);
            orderLineItemList[2].Stop_Date__c = date.today().addDays(2);
            orderLineItemList[2].Publication__c = pub.id;
            
            //set specialPublications
            //orderLineItemList[0].Publication__c = publicationList[0].Id;
            //orderLineItemList[1].Publication__c = publicationList[1].Id;
            //orderLineItemList[2].Publication__c = publicationList[2].Id;
            
            //set Wrapper_Number__c
            orderLineItemList[0].Wrapper_Number__c = 1;
            orderLineItemList[1].Wrapper_Number__c = 6;
            orderLineItemList[2].Wrapper_Number__c = 0;
            insert orderLineItemList;
            
            system.assertNotEquals(null, orderLineItemList[0].id);
            system.assertNotEquals(null, orderLineItemList[1].id);
            system.assertNotEquals(null, orderLineItemList[2].id);
            
            test.startTest();
            
            //set page - account passed - remove publication
            PageReference pageRef1 = Page.CreateVendorOrderEntry;
            pageRef1.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef1);
            CreateVendorOrderEntryController createVendorEntry1 = new CreateVendorOrderEntryController();
            createVendorEntry1.index = '1';
            createVendorEntry1.removePub();
            
            //set page - no account passed
            PageReference pageRef2 = Page.CreateVendorOrderEntry;
            Test.setCurrentPage(pageRef2);
            CreateVendorOrderEntryController createVendorEntry2 = new CreateVendorOrderEntryController();
            createVendorEntry2.addOrder();
            
            PageReference pageRef15 = Page.CreateVendorOrderEntry;
            pageRef15.getParameters().put('accountid', null);
            Test.setCurrentPage(pageRef15);
            CreateVendorOrderEntryController createVendorEntry15 = new CreateVendorOrderEntryController();
            
            //set OrWrapper
            List<CreateVendorOrderEntryController.OrWrapper> OWList4 = new List<CreateVendorOrderEntryController.OrWrapper>();
            CreateVendorOrderEntryController.OrWrapper OW4;
            OW4 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[1]);
            OW4.counterWrap = (Integer) orderLineItemList[1].Wrapper_Number__c;
            OW4.oLine.Mon__c = 1;
            OW4.oLine.Tue__c = 1;
            OW4.oLine.Wed__c = 1;
            OW4.oLine.Thu__c = 1;
            OW4.oLine.Fri__c = 1;
            OW4.oLine.Sat__c = 1;
            OW4.oLine.Sun__c = 1;
            //OW4.oLine.Publication__c = publicationList[0].id;
            OWList4.add(OW4);
            OW4 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[2]);
            OW4.counterWrap = (Integer) orderLineItemList[2].Wrapper_Number__c;
            OW4.oLine.Mon__c = 0;
            OW4.oLine.Tue__c = 0;
            OW4.oLine.Wed__c = 0;
            OW4.oLine.Thu__c = 0;
            OW4.oLine.Fri__c = 0;
            OW4.oLine.Sat__c = 0;
            OW4.oLine.Sun__c = 0;
            OWList4.add(OW4);
            OW4 = new CreateVendorOrderEntryController.OrWrapper(orderLineItemList[0]);
            OW4.counterWrap = (Integer) orderLineItemList[0].Wrapper_Number__c;
            OWList4.add(OW4); 
            
            createVendorEntry15.order = orderList[0];
            createVendorEntry15.index = '1';
            createVendorEntry15.orWrapperList = OWList4;
            createVendorEntry15.submit();
            createVendorEntry15.populateDeliveryCharge();
            createVendorEntry15.edit();
            createVendorEntry15.changePublication();
            
            test.stopTest();
                  
        }
    }
}