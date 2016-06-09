/*
Author: Joyrem Zarmaine D. Ayuman
Date: Oct 15, 2015
Note: Additional for code coverage
*This is test class for SendEshopCustomerEmail
*/

@isTest (seeAllData= true)
public class SendEshopCustomerEmailTest{
    
    static testMethod void TestSendEShop(){
        try {
           // System.debug('Before new user');
            
            User u = TestDataFactory.prepareTestusers();
           
            
            database.insert(u);
            
           // System.debug('Before runAs(u)');
    
            System.runAs(u) {
                List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');   
            insert accList;
                   
            
              
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                //insert new List<sObject>{postal,acc, pkg[0]};
                insert postal;             
                    
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                List<Contact> con = TestDataFactory.createContact(1);
                con[0].Address__c = addressRec.Id;
               //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con[0].Recipient_Indicator__c = true;
                con[0].Phone = '1234567';
                con[0].AccountId = accList[0].Id;
                //con[0].Email = 'alfred.abrina@accenture.com';            
                insert con;            
             
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
            
                                   
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id;   
            
            insert billAccountList;       
            
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
                
            insert orderList;
                  
                             
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
            orderLineItemList[0].Start_Date__c = date.today()+2;
                 
            insert orderLineItemList;
            
             List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);          
            //zsubList = TestDataFactory.createSubscription(2);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';                
            zsubList[0].Email__c = con[0].Email;            
            //zsubList[0].Email__c = 'alfred.abrina@accenture.com';        
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';   
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Number_of_Copies__c = 100;
            zsubList[0].Qty__c = 20;
            insert zsubList;
    
                Case cas = new Case();
                cas.AccountId = accList[0].id;
                cas.Order__c = orderList[0].Id;
                cas.Origin = 'Phone';
                cas.Priority = 'Medium';
                cas.Date_Replaced__c = system.today();
                cas.Status = 'New';
                insert cas;
            
                
                //Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
                test.starttest();                      
                SendEshopCustomerEmail sendEshop = new SendEshopCustomerEmail();
                
               // sendEshop(zsubList);  
                
                sendEshop.SendEshopCustomerEmailFailure ('Email Error', 'alfred.abrina@accenture.com', 'CODE001'); 
                
                String success = sendEshop.BodySuccess('Success', 'sSFSubId', 'TestId',  'sOrderId'); 
                System.assertNotEquals(success, 'error');
                String error = sendEshop.BodyFailure('Body Failure', 'Code02');          
                System.assertNotEquals(error, 'success');
               // sendEshop.SendEshopCustomerEmail(zSubs[0]);     
                test.stoptest();           
           }
        }catch(Zuora.zRemoteException e) {System.debug(e);}  
    }                
        
    static testMethod void TestEmailisNotNull(){
        try {
           // System.debug('Before new user');
            
            User u = TestDataFactory.prepareTestusers();
            
            database.insert(u);
            
            System.runAs(u) {
                List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');   
            insert accList;
                   
            
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                //insert new List<sObject>{postal,acc, pkg[0]};
                insert postal;             
                    
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                List<Contact> con = TestDataFactory.createContact(1);
                con[0].Address__c = addressRec.Id;
               //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con[0].Recipient_Indicator__c = true;
                con[0].Phone = '1234567';
                con[0].AccountId = accList[0].Id;
                con[0].Email__c = 'alfred.abrina@accenture.com';            
                insert con;            
            
                    
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
            
                                   
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id;   
            billAccountList[0].Zuora__SoldToName__c = 'April';
            insert billAccountList;       
            
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
                
            insert orderList;
                  
                             
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
            orderLineItemList[0].Start_Date__c = date.today()+2;
                 
            insert orderLineItemList;
            
             List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);          
            //zsubList = TestDataFactory.createSubscription(2);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Contact__c = con[0].Id;    
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Number_of_Copies__c = 100;
            zsubList[0].Qty__c = 20;
            zsubList[0].Email__c = 'a@a.com';
            database.insert(zsubList);
    
    
            System.debug('zsub Contact Email1: ' + con[0].Email__c);
            System.debug('zsub Contact Email2: ' + zsubList[0].Contact__r.Email__c);
    
                Case cas = new Case();
                cas.AccountId = accList[0].id;
                cas.Order__c = orderList[0].Id;
                cas.Origin = 'Phone';
                cas.Priority = 'Medium';
                cas.Date_Replaced__c = system.today();
                cas.Status = 'New';
                insert cas;
                
             
                //Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
                test.starttest();                      
    
                
    
                SendEshopCustomerEmail sendEshop = new SendEshopCustomerEmail();
                //sendEshop.SendEshopCustomerEmail(zsubList[0]);
                sendEshop.SendEshopCustomerEmail ();
                //SendEshopCustomerEmail controller = new SendEshopCustomerEmail(Zuora__Subscription__ zsubList[0]);
                
                 
                test.stoptest();           
           }
        
        }catch(Zuora.zRemoteException e) {System.debug(e);} 
    }                
        
    static testMethod void TestEmailisNotNull02(){
        try {            
            User u = TestDataFactory.prepareTestusers();
            
            database.insert(u);
            
            System.runAs(u) {
                List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');   
                insert accList;
                    
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                //insert new List<sObject>{postal,acc, pkg[0]};
                insert postal;             
                    
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                List<Contact> con = TestDataFactory.createContact(1);
                con[0].Address__c = addressRec.Id;
               //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con[0].Recipient_Indicator__c = true;
                con[0].Phone = '1234567';
                con[0].AccountId = accList[0].Id;
                con[0].Email__c = 'alfred.abrina@accenture.com';            
                insert con;            
                        
                List<Package__c> packageList = TestDataFactory.createPackage(1);
                insert packageList;
                
                                       
                List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                billAccountList[0].Zuora__Account__c = accList[0].id;   
                billAccountList[0].Zuora__SoldToName__c = 'April';
                insert billAccountList;       
                
                       
                List<Order__c> orderList = TestDataFactory.createOrder(1);
                orderList[0].Account__c = accList[0].id;
                orderList[0].Subscriber_Charge__c = 100; 
                    
                insert orderList;
                      
                                 
                List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
                orderLineItemList[0].Order__c = orderList[0].id; 
                orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
                orderLineItemList[0].Start_Date__c = date.today()+2;
                     
                insert orderLineItemList;
                
                 List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);          
                //zsubList = TestDataFactory.createSubscription(2);
                //set values
                zsubList[0].Zuora__Account__c = accList[0].id;
                zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
                zsubList[0].Qty1__c ='20';  
                zsubList[0].Order_Number__c = orderList[0].id;        
                zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
                zsubList[0].Delivery_Charge__c = 200;
                zsubList[0].Product_Code__c = 'CD001';
                zsubList[0].Contact__c = con[0].Id;    
                zsubList[0].Subscription_Type_1__c = 'Publication';
                zsubList[0].Subscription_Type__c = 'Publication';
                zsubList[0].Number_of_Copies1__c =  '100';
                zsubList[0].Number_of_Copies__c = 100;
                zsubList[0].Qty__c = 20;
                zsubList[0].Email__c = 'a@a.com';
                database.insert(zsubList);
                
                System.debug('zsub Contact Email1: ' + con[0].Email__c);
                System.debug('zsub Contact Email2: ' + zsubList[0].Contact__r.Email__c);
    
                Case cas = new Case();
                cas.AccountId = accList[0].id;
                cas.Order__c = orderList[0].Id;
                cas.Origin = 'Phone';
                cas.Priority = 'Medium';
                cas.Date_Replaced__c = system.today();
                cas.Status = 'New';
                insert cas;
                
                test.starttest();
                
                SendEshopCustomerEmail sendEshop = new SendEshopCustomerEmail();
                //sendEshop.SendEshopCustomerEmail(zsubList[0]); //CLin 25April2016
                
                test.stoptest();           
           }
        
        }catch(Zuora.zRemoteException e) {System.debug(e);}  

    }
      
}