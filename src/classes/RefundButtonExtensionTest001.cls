/* April Veloso
* 04/08/2016
* Base Class : RefundbuttonExtension
* Test Class : RefundButtonExtensionTest001
*/

@isTest
public class RefundButtonExtensionTest001{

	@testSetup
	static void setupData() {
		
		insert CustomSettingsDataFactory.createUom();
		insert CustomSettingsDataFactory.createUnit_of_Measure();
		insert CustomSettingsDataFactory.createPublic_Holiday_Pub_Indiators();
		insert CustomSettingsDataFactory.createProduct_Frequency();
		insert CustomSettingsDataFactory.createProduct_Code();
		insert CustomSettingsDataFactory.createPostage_Charge();
		insert CustomSettingsDataFactory.createMASS_CONFIG();
		insert CustomSettingsDataFactory.createKey_Id();
		insert CustomSettingsDataFactory.createError_Messages();
		insert CustomSettingsDataFactory.createOther();
		insert CustomSettingsDataFactory.createPlannerSched();
	}
	
            static testMethod void testCreditCardPaymentMethod001(){
            
                    User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
                    
                    System.runAs(u){
                    
                    Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
                    insert acct;
                    
                    Case c = TestDataFactory.createCase(1,'Refund')[0];
                    System.debug('Record Type ID:' + c.RecordTypeId);       
                    c.AccountId = acct.Id;
                    c.Case_Refund_Check__c = false;
                    c.Payment_Method_ID__c = '00001';
                    c.Approved_Refund__c = true;
                    c.Amount_to_Refund__c = 100;
                    c.Payee_Name__c = 'TestSample';
                    c.Payment_Mode__c = 'CreditCard';                
                    insert c;
                    
                    Package__c packageList = TestDataFactory.createPackage(1)[0];
                    insert packageList;
                    
                    Zuora__CustomerAccount__c billaccount = TestDataFactory.createBillingAccount(1)[0];
                    billaccount.Zuora__Account__c = acct.id;       
                    insert billaccount;
                    
                  
                    Zuora__PaymentMethod__c zpmethod = TestDataFactory.createPaymentMethod(1)[0];
                    zpmethod.Zuora__BillingAccount__c = billaccount.id;
                    zpmethod.Zuora__Type__c = 'Cash';
                    insert zpmethod;
                                      
                    
                    //Zuora__CustomerAccount__c zbaccount = TestDataFactory.createBillingAccount(1)[0];
                    //zbaccount.Zuora__Account__c = acct.id;
                    billaccount.Zuora__Zuora_Id__c = 'Test';
                    billaccount.Zuora__AccountNumber__c = 'Account';
                    billaccount.Zuora__Default_Payment_Method__c = zpmethod.id;
                    billaccount.Refund_Amount__c = 1000;
                    billaccount.Payment_Mode__c = 'Cash';
                    billaccount.Zuora__External_Id__c = 'Test Account 123';
                    billaccount.Zuora__Credit_Balance__c = 2000; //START/END UD-3092 AddedBy FrancisBenzon
                    billaccount.Zuora__DefaultPaymentMethod__c = 'CreditCard';
                    update billaccount;        
                    
                    
                    Order__c orderList = TestDataFactory.createOrder(1)[0];
                    orderList.Account__c = acct.id;
                    orderList.Subscriber_Charge__c = 100; 
                    insert orderList;
                    
                    Order_Line_Item__c orderLineItemList = TestDataFactory.createOrderLineItem(1)[0];
                    orderLineItemList.Order__c = orderList.id; 
                    orderLineItemList.Main_Package_ID__c = packageList.id;               
                    insert orderLineItemList;
                    
                    
                    Zuora__Subscription__c zsubList = TestDataFactory.createSubscription(1)[0];
                    zsubList.Zuora__Account__c = acct.id;       
                    zsubList.Zuora__CustomerAccount__c = billAccount.id;
                    zsubList.Qty1__c ='20';  
                    zsubList.Order_Number__c = orderList.id;        
                    zsubList.Order_Line_Item_Number__c = orderLineItemList.id;
                    zsubList.Delivery_Charge__c = 200;         
                    zsubList.Product_Code__c = 'CD001';
                    zsubList.Subscription_Type_1__c = 'Publication';
                    zsubList.Subscription_Type__c = 'Publication';
                    zsubList.Number_of_Copies1__c =  '100';
                    zsubList.Number_of_Copies__c = 100;
                    zsubList.Qty__c = 20;
                    insert zsubList;
                    
                    
                    Zuora__ZInvoice__c zinvoice = TestDataFactory.createInvoice(1)[0];
                    zinvoice.Name = 'INV000000XX';
                    zinvoice.Zuora__Zuora_Id__c = 'ZuoraTestId123';
                    zinvoice.Zuora__Account__c = acct.Id;
                    zinvoice.Zuora__Balance2__c = -10;
                    zinvoice.Refund_Indicator__c = FALSE;
                    insert zinvoice;
                    system.assertNotEquals(null, zinvoice);
                    
                    Invoice_Line_Item__c newlineitem = new Invoice_Line_Item__c();
                    newlineitem.Name = 'ILineItem1';
                    newlineitem.Invoice_ID__c = zinvoice.Zuora__Zuora_Id__c;
                    newlineitem.Charge_Amount__c = 100;
                    //Test.startTest(); 
                    insert newlineitem;
                    
                    Zuora__Refund__c thisRefund= testDataFactory.createRefund(1)[0];
                    thisRefund.Zuora__Account__c = acct.id;
                    thisRefund.Zuora__BillingAccount__c = billaccount.Id;
                    thisRefund.Case__c = c.Id;     
                    thisRefund.Case_1__c = c.Id;   
                    thisRefund.Subscription__c = zsubList.Id;        
                    thisRefund.Zuora__Amount__c = 100;
                    thisRefund.Payee__c = 'Payee';
                    thisRefund.Zuora__RefundDate__c = Date.Today()+5;
                    //thisRefund.Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c = '00NN0000000zZxc';        
                    insert thisRefund; 
                            
                    Zuora__Payment__c zpayment = TestdataFactory.createPayment(1)[0];
                    zpayment.Zuora__PaymentMethod__c = 'Paypal';
                    zpayment.Zuora__ReferenceId__c = '121dfd21';
                    zpayment.Zuora__BillingAccount__c = billaccount.id;
                    database.insert(zpayment);
                    
                    //try{
                    //Test.setMock(WebServiceMock.class, new zLoginMock());
                    Test.startTest();
                    PageReference pgRef = Page.RefundButton;
                    Test.setCurrentPage(pgRef);  
                    
                    
                    RefundButtonExtension refb = new RefundButtonExtension(new ApexPages.StandardController (c));        
                    refb.activateRefund();
                    Test.stopTest();
                  }
            }
            
            static testMethod void testCreditCardPaymentMethodPaypal(){
            
                    User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
                    
                    System.runAs(u){
                    
                    Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
                    insert acct;
                    
                    Case c = TestDataFactory.createCase(1,'Refund')[0];
                    System.debug('Record Type ID:' + c.RecordTypeId);       
                    c.AccountId = acct.Id;
                    c.Case_Refund_Check__c = false;
                    c.Payment_Method_ID__c = '00001';
                    c.Approved_Refund__c = true;
                    c.Amount_to_Refund__c = 100;
                    c.Payee_Name__c = 'TestSample';
                    c.Payment_Mode__c = 'Paypal';                
                    insert c;
                    
                    Package__c packageList = TestDataFactory.createPackage(1)[0];
                    insert packageList;
                    
                    Zuora__CustomerAccount__c billaccount = TestDataFactory.createBillingAccount(1)[0];
                    billaccount.Zuora__Account__c = acct.id;       
                    insert billaccount;
                    
                  
                    Zuora__PaymentMethod__c zpmethod = TestDataFactory.createPaymentMethod(1)[0];
                    zpmethod.Zuora__BillingAccount__c = billaccount.id;
                    zpmethod.Zuora__Type__c = 'Cash';
                    insert zpmethod;
                                      
                    
                    //Zuora__CustomerAccount__c zbaccount = TestDataFactory.createBillingAccount(1)[0];
                    //zbaccount.Zuora__Account__c = acct.id;
                    billaccount.Zuora__Zuora_Id__c = 'Test';
                    billaccount.Zuora__AccountNumber__c = 'Account';
                    billaccount.Zuora__Default_Payment_Method__c = zpmethod.id;
                    billaccount.Refund_Amount__c = 1000;
                    billaccount.Payment_Mode__c = 'Cash';
                    billaccount.Zuora__External_Id__c = 'Test Account 123';
                    billaccount.Zuora__Credit_Balance__c = 2000; //START/END UD-3092 AddedBy FrancisBenzon
                    update billaccount;        
                    
                    
                    Order__c orderList = TestDataFactory.createOrder(1)[0];
                    orderList.Account__c = acct.id;
                    orderList.Subscriber_Charge__c = 100; 
                    insert orderList;
                    
                    Order_Line_Item__c orderLineItemList = TestDataFactory.createOrderLineItem(1)[0];
                    orderLineItemList.Order__c = orderList.id; 
                    orderLineItemList.Main_Package_ID__c = packageList.id;               
                    insert orderLineItemList;
                    
                    
                    Zuora__Subscription__c zsubList = TestDataFactory.createSubscription(1)[0];
                    zsubList.Zuora__Account__c = acct.id;       
                    zsubList.Zuora__CustomerAccount__c = billAccount.id;
                    zsubList.Qty1__c ='20';  
                    zsubList.Order_Number__c = orderList.id;        
                    zsubList.Order_Line_Item_Number__c = orderLineItemList.id;
                    zsubList.Delivery_Charge__c = 200;         
                    zsubList.Product_Code__c = 'CD001';
                    zsubList.Subscription_Type_1__c = 'Publication';
                    zsubList.Subscription_Type__c = 'Publication';
                    zsubList.Number_of_Copies1__c =  '100';
                    zsubList.Number_of_Copies__c = 100;
                    zsubList.Qty__c = 20;
                    insert zsubList;
                    
                    
                    Zuora__ZInvoice__c zinvoice = TestDataFactory.createInvoice(1)[0];
                    zinvoice.Name = 'INV000000XX';
                    zinvoice.Zuora__Zuora_Id__c = 'ZuoraTestId123';
                    zinvoice.Zuora__Account__c = acct.Id;
                    zinvoice.Zuora__Balance2__c = -10;
                    zinvoice.Refund_Indicator__c = FALSE;
                    insert zinvoice;
                    system.assertNotEquals(null, zinvoice);
                    
                    Invoice_Line_Item__c newlineitem = new Invoice_Line_Item__c();
                    newlineitem.Name = 'ILineItem1';
                    newlineitem.Invoice_ID__c = zinvoice.Zuora__Zuora_Id__c;
                    newlineitem.Charge_Amount__c = 100;
                    //Test.startTest(); 
                    insert newlineitem;
                    
                    Zuora__Refund__c thisRefund= testDataFactory.createRefund(1)[0];
                    thisRefund.Zuora__Account__c = acct.id;
                    thisRefund.Zuora__BillingAccount__c = billaccount.Id;
                    thisRefund.Case__c = c.Id;     
                    thisRefund.Case_1__c = c.Id;   
                    thisRefund.Subscription__c = zsubList.Id;        
                    thisRefund.Zuora__Amount__c = 100;
                    thisRefund.Payee__c = 'Payee';
                    thisRefund.Zuora__RefundDate__c = Date.Today()+5;
                    //thisRefund.Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c = '00NN0000000zZxc';        
                    insert thisRefund; 
                            
                    Zuora__Payment__c zpayment = TestdataFactory.createPayment(1)[0];
                    zpayment.Zuora__PaymentMethod__c = 'Paypal';
                    zpayment.Zuora__ReferenceId__c = '121dfd21';
                    zpayment.Zuora__BillingAccount__c = billaccount.id;
                    database.insert(zpayment);
                    
                    //try{
                    //Test.setMock(WebServiceMock.class, new zLoginMock());
                    Test.startTest();
                    PageReference pgRef = Page.RefundButton;
                    Test.setCurrentPage(pgRef);  
                    
                    
                    RefundButtonExtension refb = new RefundButtonExtension(new ApexPages.StandardController (c));        
                    refb.activateRefund();
                    Test.stopTest();
                    
                    //}catch(Exception e){
                    //}        
            
            }
     }
     static testMethod void testCreditCardPaymentMethodInvoice(){
            
                    User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
                    
                    System.runAs(u){
                    
                    Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
                    insert acct;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Street_Name__c = 'Street';
                    postal.Building_Name__c = 'building';
                    database.insert(postal);
                    
                    Country__c country = TestDataFactory.createCountry(1)[0];
                    country.Country_Name__c = 'country';
                    database.insert(country);
                    
                    Address__c add = TestDataFactory.createAddress(1)[0];
                    add.Block_House_Number__c = '10';
                    add.Postal_Code__c = postal.Id;
                    add.Level_Number__c = '12';
                    add.Unit_Number__c = '12';
                    add.Country__c = country.Id;
                    database.insert(add);
                    
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.Address__c = add.Id;
                    con.AccountId = acct.Id;
                    con.Recipient_Indicator__c = true;
                    database.insert(con);
                    
                    Case c = TestDataFactory.createCase(1,'Refund')[0];
                    System.debug('Record Type ID:' + c.RecordTypeId);       
                    c.AccountId = acct.Id;
                    c.Case_Refund_Check__c = false;
                    c.Payment_Method_ID__c = '00001';
                    c.Approved_Refund__c = true;
                    c.Amount_to_Refund__c = 100;
                    c.Payee_Name__c = 'TestSample';
                    c.Payment_Mode__c = 'Invoice'; 
                    c.ContactId = con.id;               
                    insert c;
                    
                    Package__c packageList = TestDataFactory.createPackage(1)[0];
                    insert packageList;
                    
                    Zuora__CustomerAccount__c billaccount = TestDataFactory.createBillingAccount(1)[0];
                    billaccount.Zuora__Account__c = acct.id;       
                    billaccount.Other_PaymentMethod__c = 'Invoice';
                    insert billaccount;
                    
                  
                    Zuora__PaymentMethod__c zpmethod = TestDataFactory.createPaymentMethod(1)[0];
                    zpmethod.Zuora__BillingAccount__c = billaccount.id;
                    zpmethod.Zuora__Type__c = 'Cash';
                    insert zpmethod;
                                      
                    
                    //Zuora__CustomerAccount__c zbaccount = TestDataFactory.createBillingAccount(1)[0];
                    //zbaccount.Zuora__Account__c = acct.id;
                    billaccount.Zuora__Zuora_Id__c = 'Test';
                    billaccount.Zuora__AccountNumber__c = 'Account';
                    billaccount.Zuora__Default_Payment_Method__c = zpmethod.id;
                    billaccount.Refund_Amount__c = 1000;
                    billaccount.Payment_Mode__c = 'Cash';
                    billaccount.Zuora__External_Id__c = 'Test Account 123';
                    billaccount.Zuora__Credit_Balance__c = 2000; //START/END UD-3092 AddedBy FrancisBenzon
                    update billaccount;        
                    
                    
                    Order__c orderList = TestDataFactory.createOrder(1)[0];
                    orderList.Account__c = acct.id;
                    orderList.Subscriber_Charge__c = 100; 
                    insert orderList;
                    
                    Order_Line_Item__c orderLineItemList = TestDataFactory.createOrderLineItem(1)[0];
                    orderLineItemList.Order__c = orderList.id; 
                    orderLineItemList.Main_Package_ID__c = packageList.id;               
                    insert orderLineItemList;
                    
                    
                    Zuora__Subscription__c zsubList = TestDataFactory.createSubscription(1)[0];
                    zsubList.Zuora__Account__c = acct.id;       
                    zsubList.Zuora__CustomerAccount__c = billAccount.id;
                    zsubList.Qty1__c ='20';  
                    zsubList.Order_Number__c = orderList.id;        
                    zsubList.Order_Line_Item_Number__c = orderLineItemList.id;
                    zsubList.Delivery_Charge__c = 200;         
                    zsubList.Product_Code__c = 'CD001';
                    zsubList.Subscription_Type_1__c = 'Publication';
                    zsubList.Subscription_Type__c = 'Publication';
                    zsubList.Number_of_Copies1__c =  '100';
                    zsubList.Number_of_Copies__c = 100;
                    zsubList.Qty__c = 20;
                    insert zsubList;
                    
                    
                    Zuora__ZInvoice__c zinvoice = TestDataFactory.createInvoice(1)[0];
                    zinvoice.Name = 'INV000000XX';
                    //zinvoice.Zuora__Zuora_Id__c = 'ZuoraTestId123';
                    zinvoice.Zuora__Account__c = acct.Id;
                    zinvoice.Zuora__Balance2__c = -10;
                    zinvoice.Refund_Indicator__c = FALSE;
                    //zinvoice.Zuora__BillingAccount__c = billaccount.id;
                    //zInvoice.Zuora__TotalAmount__c = 2.56;
                    insert zinvoice;
                    system.assertnotEquals(null, zinvoice.Zuora__Zuora_Id__c);
                    
                    Invoice_Line_Item__c newlineitem = new Invoice_Line_Item__c();
                    newlineitem.Name = 'ILineItem1';
                    newlineitem.Invoice_ID__c = zinvoice.Zuora__Zuora_Id__c;
                    newlineitem.Charge_Amount__c = 100;
                    //Test.startTest(); 
                    insert newlineitem;
                    
                    system.assertEquals(newlineitem.Invoice_ID__c, zinvoice.Zuora__Zuora_Id__c);
                    
                    Zuora__Refund__c thisRefund= testDataFactory.createRefund(1)[0];
                    thisRefund.Zuora__Account__c = acct.id;
                    thisRefund.Zuora__BillingAccount__c = billaccount.Id;
                    thisRefund.Case__c = c.Id;     
                    thisRefund.Case_1__c = c.Id;   
                    thisRefund.Subscription__c = zsubList.Id;        
                    thisRefund.Zuora__Amount__c = 100;
                    thisRefund.Payee__c = 'Payee';
                    thisRefund.Zuora__RefundDate__c = Date.Today()+5;
                    //thisRefund.Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c = '00NN0000000zZxc';        
                    insert thisRefund; 
                            
                    Zuora__Payment__c zpayment = TestdataFactory.createPayment(1)[0];
                    zpayment.Zuora__PaymentMethod__c = 'Paypal';
                    zpayment.Zuora__ReferenceId__c = '121dfd21';
                    zpayment.Zuora__BillingAccount__c = billaccount.id;
                    database.insert(zpayment);
                    
                    Zuora__SubscriptionProductCharge__c zsubProdcharge = Testdatafactory.createSubscriptionProductCharge(1)[0];
                    zsubProdcharge.Zuora__Price__c = 10.00;
                    zsubProdcharge.Zuora__Subscription__c= zsubList.id;
                    database.insert(zsubProdcharge);
                    
                    
                    //try{
                    //Test.setMock(WebServiceMock.class, new zLoginMock());
                    Test.startTest();
                    PageReference pgRef = Page.RefundButton;
                    Test.setCurrentPage(pgRef);  
                    
                    
                    RefundButtonExtension refb = new RefundButtonExtension(new ApexPages.StandardController (c));        
                    refb.activateRefund();
                    Test.stopTest();
                    
                    //}catch(Exception e){
                    //}        
            
            }
           }
}