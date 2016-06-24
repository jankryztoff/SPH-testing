/*April Veloso
  10/19/2015
  Test class for StopSubOrderEntryDirectViewController
*/

@isTest (SeeallData=True)
public with sharing class StpSbOrdrEntryDirctViewCntrllrTest{

    public class AsiaRelatedListWrapper{
        public String id;
        public String userId;
        public String serviceFlag;
        public String status;
        public Decimal quantity;
        public String asiaSubscription;
    }

    static testmethod void test1(){
        try {
           // Test.setMock(WebServiceMock.class, new zLoginMock());   
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [SELECT id from Profile Where Name ='System Administrator'].id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardSP0256870@test.com'
            );
        
            System.runAs(u){
                
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
                //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                insert con;
                 
                List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                billAccountList[0].name = 'April Summer';
                //billAccountList [0].id = zInv.id;
                billAccountList[0].Zuora__Account__c = acc.id; 
                billAccountList[0].Billing_Contact__c = con.id;
                billAccountList[0].ARMS_Account_Number__c = '027101021';
                billAccountList[0].Other_PaymentMethod__c ='Invoice';
                billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                insert billAccountList;
                                      
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base Product';
                insert pack;
               
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Name = 'NUM124';
                zSub.Billing_Type__c = 'Full Prepaid';
                zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Account__c = acc.id;
                zSub.Zuora__Status__c = 'Cancelled';
                //zSub.Order_Line_Item_Number__c = orderLineItem.id;
                zSub.Recipient_Contact__c = con.id;
                zSub.Name = 'S0000000';
                //zSub.Order_Number__c = order.id;
                zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                zSub.Zuora__AutoRenew__c = False;
                zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                zSub.Number_of_Copies__c=100;
                zSub.Number_of_Copies1__c =  '100';
                zSub.Qty__c = 20;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Term_Length__c = 1;
                zSub.Term_Length1__c = '1';
                zSub.Main_Package_1__c = pack.id;
                zSub.Main_Package__c = pack.id;
                insert zSub; 
                                 
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Subscriber_Charge__c = 100.00;
                order.Base_Subscription__c = zSub.id;
                order.Status__c = 'Void';
                //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                order.Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                order.Urgent_Stop__c = true;
                order.isWaive__c = true;
                order.Case_Record_Type__c = 'Stop Subscription';
                order.Status__c = 'Draft';
                database.insert(order);
                
                List<Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(2);
                orderLineItem[0].Order__c = order.id;
                orderLineItem[0].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[0].Main_Package_ID__c = pack.id;
                orderLineItem[0].amount_to_refund__c = 100.00;
                orderLineItem[0].Subscription__c = zSub.id;
                orderLineItem[0].fee_override__c = true;
                orderLineItem[0].fee_override_amount__c = 5.00;
                
                orderLineItem[1].Order__c = order.id;
                orderLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[1].Main_Package_ID__c = pack.id;
                orderLineItem[1].amount_to_refund__c = 100.00;
                orderLineItem[1].Subscription__c = zSub.id;
                orderLineItem[1].fee_override__c = false;
                orderLineItem[1].admin_charge__c = 2.00;
                
                database.insert(orderLineItem);
                
                /* Zuora__subscription__C var = [SELECT Zuora__SubscriptionEndDate__c from Zuora__subscription__C where Id =: zSub.id];
                System.assertEquals(var.Zuora__SubscriptionEndDate__c, );*/
                                   
                List<Case> cs = TestDataFactory.createCase(2,'Complaint - Digital');                  
                cs[0].Sub_Status__c = 'Urgent Stop Rejected';
                cs[0].Stop_Waive_Request__c = true;
                
                cs[1].Sub_Status__c = 'Waived Rejected';
                cs[1].Stop_Waive_Request__c = true;
                database.insert(cs);
                
                Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
                asia1.Display_Name__c = 'Sph.ph';
                asia1.User_ID_LDAP_ID__c = 'Singapore';
                asia1.Password__c = 'Password123';
                database.insert(asia1);
                
                Asia1_Subscription__c asia1Sub = TestdataFactory.createAsiaOneSubscription(1)[0];
                asia1Sub.Subscription__c = zSub.id;
                asia1Sub.Asia1__c = asia1.id;
                database.insert(asia1Sub);
                
                Package_Access_Flag__c accessFlagPack = TestDataFactory.createPackageAccessFlag(1)[0];
                accessFlagPack.Package__c = pack.id;
                database.insert(accessFlagPack );
            
                ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.id);
                ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
                String packId = ''+pack.id;
                Test.startTest();
                
                StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
                controller.getAccount();
                controller.getCase(cs[0].id);
                controller.getCase();
                controller.getOrder();
                controller.getOrderLineItem();
                controller.getRelatedAsiaSubscription();
                PageReference do1 = controller.doEdit();
                controller.validateVoid(order);
                PageReference do2 = controller.voidStatus();
                controller.cancelSubscription();
                PageReference submit1 = controller.submit();
                controller.setCaseStatus(cs[0], order);
                PageReference do3 = controller.doCancel();

                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e) {

        }  
    }
   
   static testmethod void test2(){
        try {
                // Test.setMock(WebServiceMock.class, new zLoginMock());   
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [SELECT id from Profile Where Name ='System Administrator'].id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardSP03JB567@test.com'
                );
        
                System.runAs(u){
                
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
                
                 
                List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                billAccountList[0].name = 'April Summer';
                //billAccountList [0].id = zInv.id;
                billAccountList[0].Zuora__Account__c = acc.id; 
                billAccountList[0].Billing_Contact__c = con.id;
                billAccountList[0].ARMS_Account_Number__c = '027101021';
                billAccountList[0].Other_PaymentMethod__c ='Invoice';
                billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                insert billAccountList;
                                      
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base Product';
                insert pack;
               
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Name = 'NUM124';
                zSub.Billing_Type__c = 'Full Prepaid';
                zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Account__c = acc.id;
                zSub.Zuora__Status__c = 'Cancelled';
                zSub.Recipient_Contact__c = con.id;
                zSub.Name = 'S0000000';
                //zSub.Order_Number__c = order.id;
                zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                zSub.Zuora__AutoRenew__c = False;
                zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                zSub.Number_of_Copies__c=100;
                zSub.Number_of_Copies1__c =  '100';
                zSub.Qty__c = 20;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Term_Length__c = 1;
                zSub.Term_Length1__c = '1';
                zSub.Main_Package_1__c = pack.id;
                zSub.Main_Package__c = pack.id;
                insert zSub; 
              
              
                
                                  
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Subscriber_Charge__c = 100.00;
                order.Base_Subscription__c = zSub.id;
                order.Status__c = 'Void';
                //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                order.Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                order.Urgent_Stop__c = true;
                order.isWaive__c = true;
                insert order;
                
                List<Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(2);
                orderLineItem[0].Order__c = order.id;
                orderLineItem[0].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[0].Main_Package_ID__c = pack.id;
                orderLineItem[0].amount_to_refund__c = 100.00;
                orderLineItem[0].Subscription__c = zSub.id;
                orderLineItem[0].fee_override__c = true;
                orderLineItem[0].fee_override_amount__c = 5.00;
                
                orderLineItem[1].Order__c = order.id;
                orderLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[1].Main_Package_ID__c = pack.id;
                orderLineItem[1].amount_to_refund__c = 100.00;
                orderLineItem[1].Subscription__c = zSub.id;
                orderLineItem[1].fee_override__c = false;
                orderLineItem[1].admin_charge__c = 2.00;
                
                database.insert(orderLineItem);
                
                 zSub.Order_Line_Item_Number__c = orderLineItem[1].id;
                 database.update(zSub);

                List<Case> cs = TestDataFactory.createCase(2,'Complaint - Digital');
                cs[0].Sub_Status__c = 'Urgent Stop Rejected';
                cs[0].Stop_Waive_Request__c = true;
                
                cs[1].Sub_Status__c = 'Waived Rejected';
                cs[1].Stop_Waive_Request__c = true;
                database.insert(cs);
                
                Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
                asia1.Display_Name__c = 'Sph.ph';
                asia1.User_ID_LDAP_ID__c = 'Singapore';
                asia1.Password__c = 'Password123';
                database.insert(asia1);
                
                Asia1_Subscription__c asia1Sub = TestdataFactory.createAsiaOneSubscription(1)[0];
                asia1Sub.Subscription__c = zSub.id;
                asia1Sub.Asia1__c = asia1.id;
                database.insert(asia1Sub);
                
                Package_Access_Flag__c accessFlagPack = TestDataFactory.createPackageAccessFlag(1)[0];
                accessFlagPack.Package__c = pack.id;
                database.insert(accessFlagPack );
            
                 ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.id);
                 ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
            
                Test.startTest();
                
                StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
                controller.getAccount();
                controller.getCase(cs[0].id);
                controller.getCase();
                controller.getOrder();
                controller.getOrderLineItem();
                controller.getRelatedAsiaSubscription();
                PageReference do1 = controller.doEdit();
                controller.validateVoid(order);
                PageReference do2 = controller.voidStatus();
                controller.cancelSubscription();
                PageReference submit1 = controller.submit();
                controller.setCaseStatus(cs[0], order);
                PageReference do3 = controller.doCancel();
                
                Test.stopTest();
            }
        } catch(Zuora.zRemoteException e) {

        }  
    }
      
    static testmethod void testUrgentStoptoFalse(){
        try {
           // Test.setMock(WebServiceMock.class, new zLoginMock());   
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [SELECT id from Profile Where Name ='System Administrator'].id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardSP04KC2346@test.com'
                );

                System.runAs(u){
                
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
                
                 
                List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                billAccountList[0].name = 'April Summer';
                //billAccountList [0].id = zInv.id;
                billAccountList[0].Zuora__Account__c = acc.id; 
                billAccountList[0].Billing_Contact__c = con.id;
                billAccountList[0].ARMS_Account_Number__c = '027101021';
                billAccountList[0].Other_PaymentMethod__c ='Invoice';
                billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                insert billAccountList;
                                      
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base Product';
                insert pack;
               
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Name = 'NUM124';
                zSub.Billing_Type__c = 'Full Prepaid';
                zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Account__c = acc.id;
                zSub.Zuora__Status__c = 'Cancelled';
               // zSub.Order_Line_Item_Number__c = orderLineItem.id;
                zSub.Recipient_Contact__c = con.id;
                zSub.Name = 'S0000000';
                //zSub.Order_Number__c = order.id;
                zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                zSub.Zuora__AutoRenew__c = False;
                zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                zSub.Number_of_Copies__c=100;
                zSub.Number_of_Copies1__c =  '100';
                zSub.Qty__c = 20;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Term_Length__c = 1;
                zSub.Term_Length1__c = '1';
                zSub.Main_Package_1__c = pack.id;
                zSub.Main_Package__c = pack.id;
                insert zSub; 
              
                                  
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Subscriber_Charge__c = 100.00;
                order.Base_Subscription__c = zSub.id;
                order.Status__c = 'Void';
                //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                order.Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                order.Urgent_Stop__c = false;
                order.isWaive__c = true;
                insert order;
                
                List<Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(2);
                orderLineItem[0].Order__c = order.id;
                orderLineItem[0].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[0].Main_Package_ID__c = pack.id;
                orderLineItem[0].amount_to_refund__c = 100.00;
                orderLineItem[0].Subscription__c = zSub.id;
                orderLineItem[0].fee_override__c = true;
                orderLineItem[0].fee_override_amount__c = 5.00;
                
                orderLineItem[1].Order__c = order.id;
                orderLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[1].Main_Package_ID__c = pack.id;
                orderLineItem[1].amount_to_refund__c = 100.00;
                orderLineItem[1].Subscription__c = zSub.id;
                orderLineItem[1].fee_override__c = false;
                orderLineItem[1].admin_charge__c = 2.00;
                database.insert(orderLineItem);
                                   
                List<Case> cs = TestDataFactory.createCase(2,'Complaint - Digital');                  
                cs[0].Sub_Status__c = 'Urgent Stop Rejected';
                cs[0].Stop_Waive_Request__c = true;
                
                cs[1].Sub_Status__c = 'Waived Rejected';
                cs[1].Stop_Waive_Request__c = true;
                database.insert(cs);
                
                Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
                asia1.Display_Name__c = 'Sph.ph';
                asia1.User_ID_LDAP_ID__c = 'Singapore';
                asia1.Password__c = 'Password123';
                database.insert(asia1);
                
                Asia1_Subscription__c asia1Sub = TestdataFactory.createAsiaOneSubscription(1)[0];
                asia1Sub.Subscription__c = zSub.id;
                asia1Sub.Asia1__c = asia1.id;
                database.insert(asia1Sub);
                
                Package_Access_Flag__c accessFlagPack = TestDataFactory.createPackageAccessFlag(1)[0];
                accessFlagPack.Package__c = pack.id;
                database.insert(accessFlagPack );
            
                 ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.id);
                 ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
            
                Test.startTest();
                 
                StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
                controller.getAccount();
                controller.getCase(cs[0].id);
                controller.getCase();
                controller.getOrder();
                controller.getOrderLineItem();
                controller.getRelatedAsiaSubscription();
                PageReference do1 = controller.doEdit();
                controller.validateVoid(order);
                PageReference do2 = controller.voidStatus();
                controller.cancelSubscription();
                PageReference submit1 = controller.submit();
                controller.setCaseStatus(cs[0], order);
                PageReference do3 = controller.doCancel();
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e) {

        }  
      }
      
    static testmethod void testisWaivetoFalse(){
        try {
           // Test.setMock(WebServiceMock.class, new zLoginMock());   
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [SELECT id from Profile Where Name ='System Administrator'].id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardSP05KC0987@test.com'
                );
        
                System.runAs(u){
                
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
                
                 
                List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                billAccountList[0].name = 'April Summer';
                //billAccountList [0].id = zInv.id;
                billAccountList[0].Zuora__Account__c = acc.id; 
                billAccountList[0].Billing_Contact__c = con.id;
                billAccountList[0].ARMS_Account_Number__c = '027101021';
                billAccountList[0].Other_PaymentMethod__c ='Invoice';
                billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                insert billAccountList;
                                      
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base Product';
                insert pack;
               
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Name = 'NUM124';
                zSub.Billing_Type__c = 'Full Prepaid';
                zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Account__c = acc.id;
                zSub.Zuora__Status__c = 'Cancelled';
               // zSub.Order_Line_Item_Number__c = orderLineItem.id;
                zSub.Recipient_Contact__c = con.id;
                zSub.Name = 'S0000000';
                //zSub.Order_Number__c = order.id;
                zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                zSub.Zuora__AutoRenew__c = False;
                zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                zSub.Number_of_Copies__c=100;
                zSub.Number_of_Copies1__c =  '100';
                zSub.Qty__c = 20;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Term_Length__c = 1;
                zSub.Term_Length1__c = '1';
                zSub.Main_Package_1__c = pack.id;
                zSub.Main_Package__c = pack.id;
                insert zSub; 
              
                                  
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Subscriber_Charge__c = 100.00;
                order.Base_Subscription__c = zSub.id;
                order.Status__c = 'Void';
                //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                order.Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                order.Urgent_Stop__c = false;
                order.isWaive__c = false;
                insert order;
                
                List<Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(2);
                orderLineItem[0].Order__c = order.id;
                orderLineItem[0].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[0].Main_Package_ID__c = pack.id;
                orderLineItem[0].amount_to_refund__c = 100.00;
                orderLineItem[0].Subscription__c = zSub.id;
                orderLineItem[0].fee_override__c = true;
                orderLineItem[0].fee_override_amount__c = 5.00;
                
                orderLineItem[1].Order__c = order.id;
                orderLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[1].Main_Package_ID__c = pack.id;
                orderLineItem[1].amount_to_refund__c = 100.00;
                orderLineItem[1].Subscription__c = zSub.id;
                orderLineItem[1].fee_override__c = false;
                orderLineItem[1].admin_charge__c = 2.00;
                database.insert(orderLineItem);
                                   
                List<Case> cs = TestDataFactory.createCase(2,'Complaint - Digital');                  
                cs[0].Sub_Status__c = 'Urgent Stop Rejected';
                cs[0].Stop_Waive_Request__c = true;
                
                cs[1].Sub_Status__c = 'Waived Rejected';
                cs[1].Stop_Waive_Request__c = true;
                database.insert(cs);
                
                Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
                asia1.Display_Name__c = 'Sph.ph';
                asia1.User_ID_LDAP_ID__c = 'Singapore';
                asia1.Password__c = 'Password123';
                database.insert(asia1);
                
                Asia1_Subscription__c asia1Sub = TestdataFactory.createAsiaOneSubscription(1)[0];
                asia1Sub.Subscription__c = zSub.id;
                asia1Sub.Asia1__c = asia1.id;
                database.insert(asia1Sub);
                
                Package_Access_Flag__c accessFlagPack = TestDataFactory.createPackageAccessFlag(1)[0];
                accessFlagPack.Package__c = pack.id;
                database.insert(accessFlagPack );
            
                 ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.id);
                 ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
            
                Test.startTest();
                 
                StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
                controller.getAccount();
                controller.getCase(cs[0].id);
                controller.getCase();
                controller.getOrder();
                controller.getOrderLineItem();
                controller.getRelatedAsiaSubscription();
                PageReference do1 = controller.doEdit();
                controller.validateVoid(order);
                PageReference do2 = controller.voidStatus();
                controller.cancelSubscription();
                PageReference submit1 = controller.submit();
                controller.setCaseStatus(cs[0], order);
                PageReference do3 = controller.doCancel();
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e) {

        }  
    }
      
    static testmethod void testorderStatusNotVoid(){
        try {
           // Test.setMock(WebServiceMock.class, new zLoginMock());   
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [SELECT id from Profile Where Name ='System Administrator'].id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardSP06KC2456@test.com'
                );

                System.runAs(u){
                
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
                
                 
                List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                billAccountList[0].name = 'April Summer';
                //billAccountList [0].id = zInv.id;
                billAccountList[0].Zuora__Account__c = acc.id; 
                billAccountList[0].Billing_Contact__c = con.id;
                billAccountList[0].ARMS_Account_Number__c = '027101021';
                billAccountList[0].Other_PaymentMethod__c ='Invoice';
                billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                insert billAccountList;
                                      
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base Product';
                insert pack;
               
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Name = 'NUM124';
                zSub.Billing_Type__c = 'Full Prepaid';
                zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Account__c = acc.id;
                zSub.Zuora__Status__c = 'Cancelled';
               // zSub.Order_Line_Item_Number__c = orderLineItem.id;
                zSub.Recipient_Contact__c = con.id;
                zSub.Name = 'S0000000';
                //zSub.Order_Number__c = order.id;
                zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                zSub.Zuora__AutoRenew__c = False;
                zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                zSub.Number_of_Copies__c=100;
                zSub.Number_of_Copies1__c =  '100';
                zSub.Qty__c = 20;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Term_Length__c = 1;
                zSub.Term_Length1__c = '1';
                zSub.Main_Package_1__c = pack.id;
                zSub.Main_Package__c = pack.id;
                insert zSub; 
                                  
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Subscriber_Charge__c = 100.00;
                order.Base_Subscription__c = zSub.id;
                order.Status__c = 'Provisioning';
                //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                order.Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                order.Urgent_Stop__c = true;
                order.isWaive__c = true;
                database.insert(order);
                
                
                List<Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(2);
                orderLineItem[0].Order__c = order.id;
                orderLineItem[0].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[0].Main_Package_ID__c = pack.id;
                orderLineItem[0].amount_to_refund__c = 100.00;
                orderLineItem[0].Subscription__c = zSub.id;
                orderLineItem[0].fee_override__c = true;
                orderLineItem[0].fee_override_amount__c = 5.00;
                
                orderLineItem[1].Order__c = order.id;
                orderLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                orderLineItem[1].Main_Package_ID__c = pack.id;
                orderLineItem[1].amount_to_refund__c = 100.00;
                orderLineItem[1].Subscription__c = zSub.id;
                orderLineItem[1].fee_override__c = false;
                orderLineItem[1].admin_charge__c = 2.00;
                
                database.insert(orderLineItem);
                
               /* Zuora__subscription__C var = [SELECT Zuora__SubscriptionEndDate__c from Zuora__subscription__C where Id =: zSub.id];
                System.assertEquals(var.Zuora__SubscriptionEndDate__c, );*/
                                   
                List<Case> cs = TestDataFactory.createCase(2,'Complaint - Digital');                  
                cs[0].Sub_Status__c = 'Urgent Stop Rejected';
                cs[0].Stop_Waive_Request__c = true;
                
                cs[1].Sub_Status__c = 'Waived Rejected';
                cs[1].Stop_Waive_Request__c = true;
                database.insert(cs);
                
                Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
                asia1.Display_Name__c = 'Sph.ph';
                asia1.User_ID_LDAP_ID__c = 'Singapore';
                asia1.Password__c = 'Password123';
                database.insert(asia1);
                
                Asia1_Subscription__c asia1Sub = TestdataFactory.createAsiaOneSubscription(1)[0];
                asia1Sub.Subscription__c = zSub.id;
                asia1Sub.Asia1__c = asia1.id;
                database.insert(asia1Sub);
                
                Package_Access_Flag__c accessFlagPack = TestDataFactory.createPackageAccessFlag(1)[0];
                accessFlagPack.Package__c = pack.id;
                database.insert(accessFlagPack );
            
                 ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.id);
                 ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
            
                Test.startTest();
                
                StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
                controller.getAccount();
                controller.getCase(cs[0].id);
                controller.getCase();
                controller.getOrder();
                controller.getOrderLineItem();
                controller.getRelatedAsiaSubscription();
                PageReference do1 = controller.doEdit();
                controller.validateVoid(order);
               // PageReference do2 = controller.voidStatus();
                controller.cancelSubscription();
                PageReference submit1 = controller.submit();
                controller.setCaseStatus(cs[0], order);
                PageReference do3 = controller.doCancel();
                
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e) {

        }  
    }
}