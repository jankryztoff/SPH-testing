/**
 * Class Name: <TEMPSTOP_DirectOrderEntryControllerTest>
 * @author: <JhustinPinoy>
 * Date: <8/30/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for TEMPSTOP_DirectOrderEntryController>
 */

@isTest (seeAllData= True)
private class TEMPSTOP_DirectOrderEntryControllerTest{
/*
//Commenting out as base class has been removed

    static testMethod void testTEMPSTOP_DirectOrderEntryController(){
        
        //Create a new user with Standard User Profile
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(u) {
    
            //insert Test Data
        //create Account
        Account newAccount = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
        newAccount.Name='TestAccount';
        newAccount.Phone='00000';
        insert newAccount;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;        
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = newAccount.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
        insert con;
        
        //create Order
        Order__c newOrder = TestDataFactory.createOrder(1)[0];
        //newOrder.Subscription_Start_Date__c = newPublication.Earliest_Start_Date__c;//no earliest start date on Order object
        newOrder.Order_Type__c = 'Start';
        newOrder.Status__c = 'Draft';
        newOrder.Account__c = newAccount.Id;
        newOrder.Informed_Customer__c = true;
        newOrder.Recipient_Contact__c = con.Id;
        insert newOrder;
        
        //create Case
        Case caseRecord = new Case(Subject= GlobalVariableClass.SUBJECT_START_SUBSCRIPTION,
        Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST,
        Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION,
        Status= GlobalVariableClass.STATUS_PENDING,
        Origin='Email',
        RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION),
        Order__c = newOrder.id);
        insert caseRecord; 
        
        List<Order__c> orderList = new List<Order__c>();
        orderList.add(newOrder);
            
        //create Temp Stop
        Temp_Stop__c TS = new Temp_Stop__c();    
        TS.Temp_Stop_Qty__c = 10000;
        insert TS;    
            
        //create Subscription Vendor
        Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
        SubVend.Name = 'Test Subscription Vendor';
        SubVend.Account__c = newAccount.Id;   
        insert SubVend;
            
        //create Case Vendor Subscription    
        Case_Vendor_Subscription__c CVS = TestDataFactory.createCaseVendorSub(1)[0];
        CVS.Case__c = caseRecord.Id;
        CVS.Account__c = newAccount.Id;    
        CVS.Subscription_Vendor__c = SubVend.Id; 
        insert CVS;    
            
        //create Vendor Temp Stop
        Vendor_Temp_Stop__c VTS = new Vendor_Temp_Stop__c();
        VTS.Subscription_Vendor__c = SubVend.Id;
        VTS.Temp_Stop__c = TS.Id;    
        insert VTS;                
            
            Test.startTest();
                PageReference pRef = Page.AccountEditOverride;
                Test.setCurrentPage(pRef);
                ApexPages.currentPage().getParameters().put('accountId', newAccount.Id);
                //ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(acc);
                //AccountEditOverrideController controller = new AccountEditOverrideController(stdCtrlr);
        
                TEMPSTOP_DirectOrderEntryController tempStopController = new TEMPSTOP_DirectOrderEntryController();
                tempStopController.getAccount();
                tempStopController.getCount();
                tempStopController.getSubscriptions();
                tempStopController.submit();
                tempStopController.incrementCounter(); 
                tempStopController.setSubscriptionRecords();
                tempStopController.removeSubscriptionRecord();
                tempStopController.setTempStopType('Update Temp Stop Request');
        }
    }//END testMethod testTEMPSTOP_DirectOrderEntryController()
    */
}//END TEMPSTOP_DirectOrderEntryControllerTest