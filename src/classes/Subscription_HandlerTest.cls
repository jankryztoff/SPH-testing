/**********************************************************************/
/* Class Name:  Subscription_HandlerTest
/* Author: Marie Kristine Munda 
/* Description: A test class for Subscription_Handler
/* Date Last Modified: 02/09/2014
/**********************************************************************/

@isTest(seeAllData = True)

public class Subscription_HandlerTest {

            static testMethod void testSubscriptionHandler(){

                        //Create a new user with Standard User Profile
                        
                        User testUser; 
                        try{
                            testUser = [SELECT Id FROM User WHERE UserName = 'standard00000@test.com'];
                        } catch(Exception e){
                            testUser = new User(
                            Alias = 'stndrd',
                            Email='standarduser@test.com', 
                            EmailEncodingKey='UTF-8',
                            LastName='Test',
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US',
                            ProfileId = [SELECT id FROM Profile Where Name = 'Standard User' LIMIT 1].id,  //(Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName='standard00000@test.com'
                            );
                        } 
                        
                        System.runAs(testUser) {
                        
                        //Create account a
                        Account a = new Account();
                        a.Name = 'TestAccount';
                        insert a;
                        
                        //Create case ca
                        Case ca = new Case();
                        ca.RecordTypeId = ConstantsSLB.getKeyId('Renewal of Subscription');
                        ca.Account = a;
                        insert ca;
                        
                        //Create an Address record
                        Address__c addressList = TestDataFactory.createAddress(1)[0];
                        insert addressList;
                        
                        // Create Account 
                        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                        acc.NRIC__c = 'T1234567R';
                        insert acc;     
                        
                        //Create contact con
                        Contact con = TestDataFactory.createContact(1)[0];
                        con.AccountId = acc.Id;
                        con.Address__c = addressList.Id;
                        con.Recipient_Indicator__c = true;
                        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                        con.Billing_Indicator__c =true;
                        
                        insert con;
                        
                        //Create Package
                        Package__c pack = TestDataFactory.createPackage(1)[0];
                        insert pack;      
                        
                        //Create Promotion
                        Promotion__c prom = new Promotion__c(
                        Promotion_Code__c = 'Test Pcode',
                        Name = 'Test Promotion',
                        Effective_Start_Date__c = Date.today(),
                        Effective_End_Date__c = Date.today().addDays(5)
                        );
                        insert prom;    
                        /* 
                        List<Order__c> orderRec = TestDataFactory.createOrder(1);   
                        orderRec[0].Account__c = a.Id;
                        orderRec[0].Informed_Customer__c = TRUE;
                        orderRec[0].Recipient_Contact__c = con.Id;
                        insert orderRec[0];  */  
                        
                        // Create Billing Account 
                        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
                        ba = TestDataFactory.createBillingAccount(1)[0];
                        ba.Zuora__Account__c = acc.Id;
                        ba.Billing_Type__c = 'Full Prepaid';
                        ba.Zuora__DefaultPaymentMethod__c = 'Check';
                        
                        insert ba;   
                        
                        //Create order order
                        Order__c order = new Order__c();
                        order.Account__c = acc.Id;
                        order.Billing_Account__c = ba.Id;
                        order.Informed_Customer__c = true;
                        order.Recipient_Contact__c = con.Id;
                        order.Credit_Balance__c = 1.00;
                        order.Order_Type__c = 'Change of Subscription Package';
                        order.Status__c = 'Draft';
                        order.Billing_Type__c = 'Full Prepaid'; 
                        order.Delivery_Charge__c = 10000;
                        order.Credit_Balance__c = 90000;
                        order.Monthly_Delivery_Charge_for_Full_Payment__c = 100000;
                        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                        order.Billing_Contact__c = con.Id; 
                        order.FP_Del_Usage__c = 2;
                        order.Subscription_Start_Date__c = date.today()+1;
                        order.Payment_Mode__c = 'Check';
                        order.Payment_Method_ID__c = 'ABC123456798';
                        order.Subscriber_Charge__c = 200;
                        order.Delivery_Charge_Type__c = 'H';       
                        
                        insert order;
                        
                        
                        //Create Case
                        Case cas = TestDataFactory.createCase(1, 'Renewal of Subscription')[0];
                        cas.Order__c = order.Id;
                        
                        insert cas;     
                        
                        //Create Order_Line_Item__c
                        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                        orderline.Generate_Invoice__c = TRUE;
                        orderline.Order__c = order.id;
                        orderline.Start_Date__c = date.today().addDays(1);
                        orderline.Promotion_ID__c = prom.id;
                        orderline.Delivered_By__c = 'Mailing Agent';
                        orderline.Main_Package_ID__c =pack.id;
                        orderline.Grace_Days__c =2;
                        orderline.Case__c = cas.id;
                        //orderline.Main_Package_Billing_Type__c ='Full Prepaid';
                        
                        insert orderline;    
                        
                        // Create Invoice
                        /*Zuora__Zinvoice__c invoice = TestDataFactory.createInvoice(1)[0];
                        invoice.Zuora__Account__c = acc.id;
                        insert invoice;*/
                        
                        
                        //Create Subscription 
                        List <Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
                        for (Zuora__Subscription__c sub : subList) {
                        sub.Zuora__Account__c = acc.Id;
                        sub.Zuora__CustomerAccount__c = ba.Id;
                        sub.Zuora__SubscriptionEndDate__c = date.today()+30;  //date.newInstance(2014, 12, 2);
                        sub.Zuora__SubscriptionStartDate__c = date.today(); //date.newInstance(2014, 11, 2);
                        sub.Subscriber_Contact__c = con.Id;
                        sub.Term_Length__c = 2;
                        sub.Recipient_Contact__c = con.Id;
                        sub.Main_Package_1__c = pack.id;
                        sub.Zuora__Status__c = 'Active';
                        sub.Order_Number__c = order.Id;
                        sub.Zuora__CustomerAccount__c = ba.Id;
                        sub.Suppress_Vendor_Start_Notice__c = 'false';
                        sub.Supressed_Acknowledgement_Letter__c = 'false';
                        sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                        sub.Charity__c = 'false';
                        sub.Order_Line_Item_Number__c = orderline.Id;
                        sub.Promotion__c = prom.id;
                        sub.Promotion_1__c = prom.id;
                        sub.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);                
                        }
                        
                        
                        insert subList;
                        try{
                        Test.setMock(WebServiceMock.class, new zLoginMock()); 
                        String origin = 'Eshop';
                        
                        Test.startTest();                                
                        
                        Subscription_Handler subsHandler = new Subscription_Handler();
                        subsHandler.origin ='Renewal of Subscription';
                        subsHandler.Subscription_Handler_Direct(order);
                        subsHandler.CreateQuotes(order, origin);
                        //subsHandler.CreateQuotes(order,'ESHOP Webservice');
                        
                        list<Order__c> lOrder = new list<Order__c>(); 
                        subsHandler.OrderToCreate(lOrder);
                        
                        //START MD-28 02/Jul/2015 Wenjun: Remove Wrong Logic & Redundant Codes
                        //List<Zuora__Subscription__c> lSub = new List<Zuora__Subscription__c>();
                        //subsHandler.Update_Subscription_Orig_Fields(lSub);
                        //END MD-28 02/Jul/2015 Wenjun
                        
                        Test.stopTest();          
                        } catch (Exception e) {}                

                }//End of Systemrunas
          }//End of testSubscriptionHandler method
        
       static testMethod void testSubscriptionHandler2(){
                        
                        //Create a new user with Standard User Profile
                        
                        User testUser; 
                        try{
                            testUser = [SELECT Id FROM User WHERE UserName = 'standard00000@test.com'];
                        } catch(Exception e){
                            testUser = new User(
                            Alias = 'stndrd',
                            Email='standarduser@test.com', 
                            EmailEncodingKey='UTF-8',
                            LastName='Test',
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US',
                            ProfileId = [SELECT id FROM Profile Where Name = 'Standard User' LIMIT 1].id,  //(Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName='standard00000@test.com'
                            );
                        }
                        
                        System.runAs(testUser) {
                        
                        //Create account a
                        Account a = new Account();
                        a.Name = 'TestAccount';
                        insert a;
                        
                        //Create case ca
                        Case ca = new Case();
                        ca.RecordTypeId = ConstantsSLB.getKeyId('Renewal of Subscription');
                        ca.Account = a;
                        insert ca;
                        
                        //Create an Address record
                        Address__c addressList = TestDataFactory.createAddress(1)[0];
                        insert addressList;
                        
                        // Create Account 
                        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                        acc.NRIC__c = 'T1234567R';
                        insert acc;     
                        
                        //Create contact con
                        Contact con = TestDataFactory.createContact(1)[0];
                        con.AccountId = acc.Id;
                        con.Address__c = addressList.Id;
                        con.Recipient_Indicator__c = true;
                        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                        con.Billing_Indicator__c =true;
                        
                        insert con;
                        
                        //Create Package
                        Package__c pack = TestDataFactory.createPackage(1)[0];
                        insert pack;      
                        
                        //Create Promotion
                        Promotion__c prom = new Promotion__c(
                        Promotion_Code__c = 'Test Pcode',
                        Name = 'Test Promotion',
                        Effective_Start_Date__c = Date.today(),
                        Effective_End_Date__c = Date.today().addDays(5)
                        );
                        insert prom;    
                        /* 
                        List<Order__c> orderRec = TestDataFactory.createOrder(1);   
                        orderRec[0].Account__c = a.Id;
                        orderRec[0].Informed_Customer__c = TRUE;
                        orderRec[0].Recipient_Contact__c = con.Id;
                        insert orderRec[0];  */  
                        
                        // Create Billing Account 
                        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
                        ba = TestDataFactory.createBillingAccount(1)[0];
                        ba.Zuora__Account__c = acc.Id;
                        ba.Billing_Type__c = 'Full Prepaid';
                        ba.Zuora__DefaultPaymentMethod__c = 'Check';
                        
                        insert ba;   
                        
                        //Create order order
                        Order__c order = new Order__c();
                        order.Account__c = acc.Id;
                        order.Billing_Account__c = ba.Id;
                        order.Informed_Customer__c = true;
                        order.Recipient_Contact__c = con.Id;
                        order.Credit_Balance__c = 1.00;
                        order.Order_Type__c = 'Change of Subscription Package';
                        order.Status__c = 'Draft';
                        order.Billing_Type__c = 'Full Prepaid'; 
                        order.Delivery_Charge__c = 10000;
                        order.Credit_Balance__c = 90000;
                        order.Monthly_Delivery_Charge_for_Full_Payment__c = 100000;
                        order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account'; //april 'Create New Billing Account';
                        order.Billing_Contact__c = con.Id; 
                        order.FP_Del_Usage__c = 2;
                        order.Subscription_Start_Date__c = date.today()+1;
                        order.Payment_Mode__c = 'Check';
                        order.Payment_Method_ID__c = 'ABC123456798';
                        order.Subscriber_Charge__c = 200;
                        order.Delivery_Charge_Type__c = 'H';       
                        
                        insert order;
                        
                        
                        //Create Case
                        Case cas = TestDataFactory.createCase(1, 'Renewal of Subscription')[0];
                        cas.Order__c = order.Id;
                        
                        insert cas;     
                        
                        //Create Order_Line_Item__c
                        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                        orderline.Generate_Invoice__c = TRUE;
                        orderline.Order__c = order.id;
                        orderline.Start_Date__c = date.today().addDays(1);
                        orderline.Promotion_ID__c = prom.id;
                        orderline.Delivered_By__c = 'Mailing Agent';
                        orderline.Main_Package_ID__c =pack.id;
                        orderline.Grace_Days__c =2;
                        orderline.Case__c = cas.id;
                        //orderline.Main_Package_Billing_Type__c ='Full Prepaid';
                        
                        insert orderline;    
                        
                        // Create Invoice
                        /*Zuora__Zinvoice__c invoice = TestDataFactory.createInvoice(1)[0];
                        invoice.Zuora__Account__c = acc.id;
                        insert invoice;*/
                        
                        
                        //Create Subscription 
                        List <Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
                        for (Zuora__Subscription__c sub : subList) {
                        sub.Zuora__Account__c = acc.Id;
                        sub.Zuora__CustomerAccount__c = ba.Id;
                        sub.Zuora__SubscriptionEndDate__c = date.today()+30;  //date.newInstance(2014, 12, 2);
                        sub.Zuora__SubscriptionStartDate__c = date.today(); //date.newInstance(2014, 11, 2);
                        sub.Subscriber_Contact__c = con.Id;
                        sub.Term_Length__c = 2;
                        sub.Recipient_Contact__c = con.Id;
                        sub.Main_Package_1__c = pack.id;
                        sub.Zuora__Status__c = 'Active';
                        sub.Order_Number__c = order.Id;
                        sub.Zuora__CustomerAccount__c = ba.Id;
                        sub.Suppress_Vendor_Start_Notice__c = 'false';
                        sub.Supressed_Acknowledgement_Letter__c = 'false';
                        sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                        sub.Charity__c = 'false';
                        sub.Order_Line_Item_Number__c = orderline.Id;
                        sub.Promotion__c = prom.id;
                        sub.Promotion_1__c = prom.id;
                        sub.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);                
                        }
                        
                        
                        insert subList;
                        try{
                        Test.setMock(WebServiceMock.class, new zLoginMock()); 
                        String origin = 'ESHOP1';
                        
                        Test.startTest();                                
                        
                        Subscription_Handler subsHandler = new Subscription_Handler();
                        subsHandler.origin ='Renewal of Subscription';
                        subsHandler.Subscription_Handler_Direct(order);
                        subsHandler.CreateQuotes(order, origin);
                        //subsHandler.CreateQuotes(order,'ESHOP Webservice');
                        
                        list<Order__c> lOrder = new list<Order__c>(); 
                        subsHandler.OrderToCreate(lOrder);
                        
                        //START MD-28 02/Jul/2015 Wenjun: Remove Wrong Logic & Redundant Codes
                        //List<Zuora__Subscription__c> lSub = new List<Zuora__Subscription__c>();
                        //subsHandler.Update_Subscription_Orig_Fields(lSub);
                        //END MD-28 02/Jul/2015 Wenjun
                        
                        Test.stopTest();          
                        } catch (Exception e) {}                

                }//End of Systemrunas
          }//End of testSubscriptionHandler method
        
}//End of Subscription_HandlerTest