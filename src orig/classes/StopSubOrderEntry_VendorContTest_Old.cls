/**
 * Class Name: <StopSubOrderEntry_VendorControllerTest>
 * @author: <KimSaclag>
 * Date: <10/22/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for StopSubOrderEntry_VendorController>
 */
 
@isTest (seeAllData= True)
private class StopSubOrderEntry_VendorContTest_Old {

    private static String sphSysAd = ConstantsSLB.getKeyId('Profile_System Administrator');
    private static String caseRenewId = ConstantsSLB.getKeyId('Case_Stop');
    private static User usrTest;
    
    private static void createTestData() {
        //test User - change to appropriate Profile
        usrTest = new User(
            alias = 'testuser', 
            email = 'testUser123@salesforce.com', 
            emailencodingkey = 'UTF-8', 
            firstname = 'Insert', 
            lastname = 'Tester', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = sphSysAd,
            timezonesidkey = 'America/Los_Angeles',
            username = 'testUser123@salesforce.com');   
    }
           
    static testMethod void StopSubOrderEntry_VendorControllerTest() {
/*      
        createTestData();
         
        //insert test data
        List<Account> accList = TestDataFactory.createAccount(2, 'Vendor Subscriber');   
        insert accList;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        List<Contact> conList = TestDataFactory.createContact(1);
        // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
        //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
        conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        conList[0].Recipient_Indicator__c = true;
        // END : CCB 002 12/2/2014
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec.Id;
        insert conList;

        /*List<Order__c> orderList = TestDataFactory.createOrder(2);
        //set order values
        orderList.Recipient_Contact__c = conList[0].Id;
        orderList[0].Account__c = accList[0].id;
        orderList[0].Status__c = 'Draft';
        orderList[0].Informed_Customer__c = True;
        //orderList[0].Recipient_Contact__c = conList[0].id;
        orderList[1].Account__c = accList[1].id;
        orderList[1].Status__c = 'Draft';
        orderList[1].Informed_Customer__c = True;
        //orderList[1].Recipient_Contact__c = conList[0].id;
        insert orderList;*/
/*        
        //Order__c orderRec = TestDataFactory.createOrder(1)[0];
        List<Order__c> orderList = TestDataFactory.createOrder(1);
        orderList[0].Account__c = accList[0].Id;
        orderList[0].Informed_Customer__c = TRUE;
        orderList[0].Recipient_Contact__c = conList[0].Id;
        insert orderList;
        
        //create publications
        List<Publication__c> publicationList = TestDataFactory.createPublication(2);
        publicationList[0].Product_Family__c = 'test2';
        publicationList[0].Published_Days__c = 'YYYYYYY';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'test';
        publicationList[1].Published_Days__c = 'YYYYYYY';
        publicationList[1].Publication_Type__c = 'A';
        insert publicationList;
        
        //create Vendorpublications
        List<Subscription_Vendor_Publication__c> venPublicationList = TestDataFactory.createVendorPublication(2);
        //venPublicationList[0].Publication__c = 'The Straits Times';
        venPublicationList[0].Mon__c = 7;
        //venPublicationList[1].Publication__c = 'New Family';
        venPublicationList[1].Mon__c = 7;
        insert venPublicationList;
        
        //create oliv
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
            oliv.Order__c = orderList[0].id;
        }
        
        //set specialPublications
        orderLineItemList[0].Publication__c = publicationList[0].Id;
        
        //set Wrapper_Number__c
        orderLineItemList[1].Wrapper_Number__c = 1;
        //insert orderLineItemList;
        
        test.startTest();
        system.runAs(usrTest) {
            
            //set page - account passed - remove publication
            PageReference pageRef = Page.StopSubOrderEntry_Vendor_Edit;
            pageRef.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef);
            StopSubOrderEntry_VendorController createVendorEntry = new StopSubOrderEntry_VendorController();
            //set index
            createVendorEntry.index = '1';
            createVendorEntry.removePub();
            
            //set page - no account passed
            PageReference pageRef2 = Page.StopSubOrderEntry_Vendor_Edit;
            Test.setCurrentPage(pageRef2);
            StopSubOrderEntry_VendorController createVendorEntry2 = new StopSubOrderEntry_VendorController();
            createVendorEntry2.edit();

            //set page - no account passed - no order
            PageReference pageRef3 = Page.StopSubOrderEntry_Vendor_Edit;
            pageRef3.getParameters().put('accountid', accList[1].Id);
            Test.setCurrentPage(pageRef3);
            StopSubOrderEntry_VendorController createVendorEntry3 = new StopSubOrderEntry_VendorController();

            //set page - account passed - save draft
            PageReference pageRef4 = Page.StopSubOrderEntry_Vendor_Edit;
            pageRef4.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef4);
            StopSubOrderEntry_VendorController createVendorEntry4 = new StopSubOrderEntry_VendorController();
            createVendorEntry4.saveDraft();

            //set page - account passed - save Draft - cancel
            PageReference pageRef5 = Page.StopSubOrderEntry_Vendor_Edit;
            pageRef5.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef5);
            StopSubOrderEntry_VendorController createVendorEntry5 = new StopSubOrderEntry_VendorController();
            createVendorEntry5.saveDraft();
            createVendorEntry5.cancel();

            //set page - account passed - save Draft - refresh
            PageReference pageRef6 = Page.StopSubOrderEntry_Vendor_Edit;
            pageRef6.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef6);
            StopSubOrderEntry_VendorController createVendorEntry6 = new StopSubOrderEntry_VendorController();
            createVendorEntry6.saveDraft();
            createVendorEntry6.index = '1';

            //set page - account passed - submit
            PageReference pageRef7 = Page.StopSubOrderEntry_Vendor_Edit;
            pageRef7.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef7);
            StopSubOrderEntry_VendorController createVendorEntry7 = new StopSubOrderEntry_VendorController();
            createVendorEntry7.submit();

            //set page - account passed - save - edit
            PageReference pageRef8 = Page.StopSubOrderEntry_Vendor_Edit;
            pageRef8.getParameters().put('accountid', accList[0].Id);
            Test.setCurrentPage(pageRef8);
            StopSubOrderEntry_VendorController createVendorEntry8 = new StopSubOrderEntry_VendorController();
            createVendorEntry8.saveDraft();
            createVendorEntry8.edit();
            
            //set page - account passed - save draft - no publication
            PageReference pageRef9 = Page.StopSubOrderEntry_Vendor_Edit;
            pageRef9.getParameters().put('accountid', accList[1].Id);
            Test.setCurrentPage(pageRef9);
            StopSubOrderEntry_VendorController createVendorEntry9 = new StopSubOrderEntry_VendorController();
            createVendorEntry9.saveDraft();

        }
         test.stopTest();
*/
    } 
    
}