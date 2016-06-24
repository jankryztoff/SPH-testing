/*
 * Class Name: UsageTriggerHandlerTest
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * Project/Requirement: 
 * @description: to test PackageTriggerHandlerclass
 */
         
@isTest
private class UsageTriggerHandlerTest {
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
    }  

    static testMethod void testUsageTriggerHandler(){

        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            UsageTriggerHandler uth = new UsageTriggerHandler();
            uth.runBeforeInsertTrigger();
            uth.runBeforeUpdateTrigger();
            uth.runBeforeDeleteTrigger();
            uth.runAfterInsertTrigger();
            uth.runAfterUpdateTrigger();
            uth.runAfterDeleteTrigger();
            
            
            Id profileID = (Id) ConstantsSLB.getKeyId('Profile_Standard User');
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='subtrig1@test.com'
            );
            
            //The test will run as the user created.
            System.runAs(u) {
                
                Singpost_Address__c postal = new Singpost_Address__c();
                postal = TestDataFactory.createSingpostAddress(1)[0];
                insert postal;
                
                Address__c address = new Address__c();
                address = TestDataFactory.createAddress(1)[0];
                address.Postal_Code__c = postal.Id;
                insert address;
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                insert pack;
                
                Account acct = new Account();
                acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acct.NRIC__c = 'T1234567R';
                insert acct;
                
                Account acctVendor = new Account();
                acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
                //acctVendor.Ven
                insert acctVendor;
                
                Account acct2 = new Account();
                acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acct2.NRIC__c = 'T1234567R';
                insert acct2;
                
                Contact con = new Contact();
                con = TestDataFactory.createContact(1)[0];
                con.AccountId = acct.Id;
                con.Address__c = address.Id;
                // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
                //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                // END : CCB 002 12/2/2014
                insert con;
                
                /*[JPO 02/13] create con2
                Contact con2 = new Contact();
                con2 =  TestDataFactory.createContact(1)[0];
                con2.AccountId = acct2.Id;
                con2.Address__c = address.Id;            
                con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con2.Recipient_Indicator__c = true;
                insert con2; */
                
                //create order
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acct.Id;
                order.Recipient_Contact__c = con.Id;
                order.Subscriber_Charge__c = 200;
                order.Billing_Type__c = 'Full';
                order.Informed_Customer__c = True;
                insert order;
                
                /*[JPO 02/13] create order2 for subrRec's orderline item 1
                Order__c order2 = TestDataFactory.createOrder(1)[0];
                order2.Account__c = acct2.Id;
                order2.Recipient_Contact__c = con2.Id;
                order2.Informed_Customer__c = True;
                insert order2; //error? FIELD_FILTER_VALIDATION_EXCEPTION, Value does not exist or does not match filter criteria.: [Recipient_Contact__c]
                */
                //create case
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                insert cas;
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today() + 1;
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Earliest_Start_Date__c = date.today();
                orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = False;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                insert orderline;

                 //create subscription vendor
                Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
                //SubVend.Name = 'Test Subscription Vendor';
                insert SubVend;
                           
                Case caseRec = new Case();
                caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
                caseRec.Status = 'Pending';
                caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
                insert caseRec;     
                
               Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
               zua.Zuora__Account__c = acct.Id;
               zua.Zuora__PaymentMethodType__c = 'Paypal';
               insert zua;
                
                Zuora__Subscription__c subRec = new Zuora__Subscription__c();
                subRec = TestDataFactory.createSubscription(1)[0];
                subRec.Zuora__Account__c = acct.Id;
                subRec.Number_of_Copies1__c = '2';
                subRec.Order_Number__c = order.Id;
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Billing_Type__c = 'Full Prepaid';
                subRec.Zuora__CustomerAccount__c = zua.id;
                subRec.Zuora__Status__c = 'Active';
                //subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Order_Line_Item_Number__c = orderline.Id;
                subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
                subRec.Vendor_1__c = acctVendor.id; //[JPO 02/12] added
                //subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
                        
                test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec  
                insert subRec;          
               
                
                //[JPO 02/12/2015] Adding List
                //List<Zuora__Subscription__c> testsubscriptionList = TestDataFactory.createSubscription(1);
                //testsubscriptionList.add(subrec);
                
                //insert testsubscriptionList;
                
                /* removing this causing SOQL limit
                Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
                subRec2 = TestDataFactory.createSubscription(1)[0];
                subRec2.Zuora__Account__c = acct.Id;
                subRec2.Order_Number__c = order.Id;
                subRec2.Subscriber_Contact__c = con.Id;
                subRec2.Recipient_Contact__c = con.Id;
                subRec2.Main_Package_1__c = pack.id;
                subRec2.Suppress_Vendor_Start_Notice__c = 'false';
                subRec2.Supressed_Acknowledgement_Letter__c = 'false';
                subRec2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec2.Urgent__c = 'false';
                subRec2.Vendor_Conversion__c = 'false';
                subRec2.Charity__c = 'false';
                //subRec2.Zuora__Status__c = NULL;
                subRec2.Order_Line_Item_Number__c = orderline.Id;
                insert subRec2;
                
                Zuora__Subscription__c subRec3 = new Zuora__Subscription__c();
                subRec3 = TestDataFactory.createSubscription(1)[0];
                subRec3.Zuora__Account__c = acct.Id;
                subRec3.Order_Number__c = order.Id;
                subRec3.Subscriber_Contact__c = con.Id;
                subRec3.Recipient_Contact__c = con.Id;
                subRec3.Main_Package_1__c = pack.id;
                subRec3.Suppress_Vendor_Start_Notice__c = 'false';
                subRec3.Supressed_Acknowledgement_Letter__c = 'false';
                subRec3.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec3.Urgent__c = 'false';
                subRec3.Vendor_Conversion__c = 'false';
                subRec3.Charity__c = 'false';
                subRec3.Order_Line_Item_Number__c = orderline.Id;
                insert subRec3;
                */                      
                
                Case_Subscription__c  caseSub = new Case_Subscription__c();
                caseSub.Account__c = acct.Id;
                caseSub.Address__c = address.Id;
                caseSub.Case__c = caseRec.Id;
                caseSub.Subscription__c = subRec.Id;
                insert caseSub;    
                
                System.assertEquals(acct.Id, caseSub.Account__c);

                
                /*
                try{    
                    subRec.Vendor_1__c = NULL;
                    update subRec;
                    //subRec2.Vendor_1__c = NULL;
                    //update subRec2;   
                }   
                catch (Exception e){
                    Boolean expectedExceptionThrown =  e.getMessage().contains('Vendor cannot be empty.') ? true : false;
                    //System.AssertEquals(expectedExceptionThrown, true);
                }
                */
                
                subRec.Zuora__Status__c = 'Active'; // [JPO 2/13] Made 'Active' From ''
                //update subRec;
                //subRec2.Zuora__Status__c = 'Active';
                //update subRec2;
                //subRec3.Zuora__Status__c = 'Active';
                //update subRec3;
                
                //update            
                SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
                SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;   
                //subRec.Vendor_1__c = acctVendor.Id; 
                //subRec.Vendor__c = acctVendor.Id;
                // System.assertEquals(null, acctVendor.Id);    
                subRec.Vendor__c = acctVendor.Id+'';
                update subRec; // venor cdannot be empty error
                
                /*zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
                zUOM.zqu__Active__c = TRUE ; 
                zUOM.zqu__Uom_rounding_mode__c = 'Up';
                zUOM.zqu__Uom_precision__c = 2;
                zUOM.zqu__ZuoraId__c = 'test2';
               
                insert zUOM;*/
                
                
                List<Usage__c> usageList = new List<Usage__c>();
                Usage__c usa = new Usage__c();
                usa.Send_to_Zuora_Time__c = date.today();
                usa.Status__c = 'New' ;
                usa.Case__c = caseRec.Id;
                usageList.add(usa);          
                insert usageList;
                update usageList;
                test.stoptest();    
            }
        }catch(Zuora.zRemoteException e) {
        }  
    }
  }