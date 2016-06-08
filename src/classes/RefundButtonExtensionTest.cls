/**
       @Author Joy Suarez
       @name RefundButtonExtension_Test
       @CreateDate 2/24/2015
       @Description test class for RefundButtonExtension
       @Version <1.0>
       @reference <Referenced program names>
      */



    @isTest(SeeAllData=true)
    public class RefundButtonExtensionTest{

        /**
        *  To test RefundButtonExtension
        *  @name testRefundButtonExtension
        *  @param none
        *  @return none
        *  @throws na
        */ 
        static testMethod void testRefundButtonExtension(){
            
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
            c.Case_Refund_Check__c = true;
            c.Payment_Method_ID__c = '00001';
            c.Approved_Refund__c = true;
            c.Amount_to_Refund__c = 100;
            c.Payee_Name__c = 'TestSample';
            c.Payment_Mode__c = 'Cash';                
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
        }//END testMethod testRefundButtonExtension()
        
        static testMethod void testfalserefundcheck(){
            
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
            c.Payment_Mode__c = 'Cheque';                
            insert c;       
            
            Package__c packageList = TestDataFactory.createPackage(1)[0];
            insert packageList;
            
            Zuora__CustomerAccount__c billaccount = TestDataFactory.createBillingAccount(1)[0];
            billaccount.Zuora__Account__c = acct.id;       
            insert billaccount;
            
            
            
            Zuora__PaymentMethod__c zpmethod = TestDataFactory.createPaymentMethod(1)[0];
            zpmethod.Zuora__BillingAccount__c = billaccount.id;
            zpmethod.Zuora__Type__c = 'Check';
            insert zpmethod;
            
            
            
            //Zuora__CustomerAccount__c zbaccount = TestDataFactory.createBillingAccount(1)[0];
            //zbaccount.Zuora__Account__c = acct.id;
            billaccount.Zuora__Zuora_Id__c = 'Test';
            billaccount.Zuora__AccountNumber__c = 'Account';
            billaccount.Zuora__Default_Payment_Method__c = zpmethod.id;
            billaccount.Refund_Amount__c = 1000;
            billaccount.Payment_Mode__c = 'Check';
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

          
            }//END testMethod testfalserefundcheck()
            
      /*      static testMethod void testPaypalPaymentMethod(){
            
            Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
            insert acct;
            
            Case c = TestDataFactory.createCase(1,'Refund')[0];
            System.debug('Record Type ID:' + c.RecordTypeId);  
            c.RecordTypeId = ConstantsSLB.getKeyId('Case_Refund');     
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
            zpmethod.Zuora__Type__c = 'Paypal';         
            insert zpmethod;
            
            Zuora__Payment__c payment = new Zuora__Payment__c(); //fritz
            payment = null;
            
            //Zuora__CustomerAccount__c zbaccount = TestDataFactory.createBillingAccount(1)[0];
            //zbaccount.Zuora__Account__c = acct.id;
            billaccount.Zuora__Zuora_Id__c = 'Test';
            billaccount.Zuora__AccountNumber__c = 'Account';
            billaccount.Zuora__Default_Payment_Method__c = zpmethod.id;
            billaccount.Refund_Amount__c = 1000;
            billaccount.Payment_Mode__c = 'Paypal';
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
            
            Zuora__Refund__c thisRefund= testDataFactory.createRefund(1)[0];
            thisRefund.Zuora__Account__c = acct.id;
            thisRefund.Zuora__BillingAccount__c = billaccount.Id;
            thisRefund.Case__c = c.Id;     
            thisRefund.Case_1__c = c.Id;   
            //thisRefund.Zuora__External_Id__c = 'TestAccount';
            thisRefund.Subscription__c = zsubList.Id;        
            thisRefund.Zuora__Amount__c = 100;
            thisRefund.Payee__c = 'Payee';
            thisRefund.Zuora__RefundDate__c = Date.Today()+5;
            //thisRefund.Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c = '00NN0000000zZxc';        
            insert thisRefund; 
           
            
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

          
            }//END testMethod testPaypalPaymentMethod()
       */ 
        
        static testMethod void testInvoicePaymentMethod(){
        
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
            //START UD-3092 AddedBy FrancisBenzon
            List<Case> c = TestDataFactory.createCase(4,'Refund'); 
            List<Case> cNull = new List<Case>(); 
            //System.debug('Record Type ID:' + c.RecordTypeId);
            for(case cas:c){       
            cas.AccountId = acct.Id;
            //cas.Credit_Note_Number__c = 200;
            cas.Case_Refund_Check__c = false; 
            cas.Payment_Method_ID__c = '00001';
            cas.Approved_Refund__c = true;
            cas.Amount_to_Refund__c = 100;
            cas.Payee_Name__c = 'TestSample';
            cas.Payment_Mode__c = 'Invoice';                 
            }   
            c[0].Credit_Note_Number__c = integer.valueOf(GlobalVariableClass.REFUND_MINLIMIT);
            c[1].Credit_Note_Number__c = integer.valueOf(GlobalVariableClass.REFUND_MAXLIMIT);
            c[2].Credit_Note_Number__c = null;
            c[3].Credit_Note_Number__c = 0000399988; 
            insert c;       
            //END UD-3092 AddedBy FrancisBenzon
            Package__c packageList = TestDataFactory.createPackage(1)[0];
            insert packageList;
            
            Zuora__CustomerAccount__c billaccount = TestDataFactory.createBillingAccount(1)[0];
            billaccount.Zuora__Account__c = acct.id;       
            insert billaccount;
            
            
            
            Zuora__PaymentMethod__c zpmethod = TestDataFactory.createPaymentMethod(1)[0];
            zpmethod.Zuora__BillingAccount__c = billaccount.id;
            zpmethod.Zuora__Type__c = 'Invoice';
            insert zpmethod;
            
            
            
            //Zuora__CustomerAccount__c zbaccount = TestDataFactory.createBillingAccount(1)[0];
            //zbaccount.Zuora__Account__c = acct.id;
            billaccount.Zuora__Zuora_Id__c = 'Test';
            billaccount.Zuora__AccountNumber__c = 'Account';
            billaccount.Zuora__Default_Payment_Method__c = zpmethod.id;
            billaccount.Refund_Amount__c = 1000;
            billaccount.Payment_Mode__c = 'Cash';
            billaccount.Other_PaymentMethod__c = 'Invoice';
            billaccount.Zuora__External_Id__c = 'TestAccount';
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
            zsubList.Zuora__External_Id__c = 'TestAccount';
            insert zsubList;
            
            Zuora__Refund__c Rfund = new Zuora__Refund__c();
            Rfund.Zuora__Account__c = acct.id;
            Rfund.Zuora__BillingAccount__c = billaccount.Id;
            Rfund.Case__c = c[0].Id;        
            Rfund.Zuora__External_Id__c = 'TestAccount';
            Rfund.Subscription__c = zsubList.Id;        
            Rfund.Zuora__Amount__c = 100;
            Rfund.Payee__c = 'Payee';
            Rfund.Zuora__RefundDate__c = Date.Today()+5;
            
            insert Rfund;      
           
            
            Zuora__ZInvoice__c zinvoice = TestDataFactory.createInvoice(1)[0];
            zinvoice.Name = 'INV000000XX';
           // zinvoice.Zuora__BillingAccount__c = billaccount.Id;
            zinvoice.Zuora__Zuora_Id__c = 'ZuoraTestId123';
            zinvoice.Zuora__Account__c = acct.Id;
            zinvoice.Zuora__TaxAmount__c = 10;
            zinvoice.Zuora__AmountWithoutTax__c = 10;
            zinvoice.Zuora__Balance2__c = -20;
            zinvoice.Refund_Indicator__c = FALSE;
            zinvoice.Zuora__TotalAmount__c = -10;
            zinvoice.Zuora__DueDate__c = date.Today()+5;
            insert zinvoice;
            system.assertNotEquals(null, zinvoice);

            Invoice_Line_Item__c newlineitem = new Invoice_Line_Item__c();
            newlineitem.Name = 'ILineItem1';
            newlineitem.Invoice_ID__c = zinvoice.Zuora__Zuora_Id__c;
            newlineitem.Charge_Amount__c = 100;
            newlineitem.Subscription__c = zsubList.Id; //START/END UD-3092 AddedBy FrancisBenzon
            //Test.startTest(); 
            insert newlineitem;
                     
            //try{
            //Test.setMock(WebServiceMock.class, new zLoginMock());
            Test.startTest();
            PageReference pgRef = Page.RefundButton;
            Test.setCurrentPage(pgRef);
             

            RefundButtonExtension refb = new RefundButtonExtension(new ApexPages.StandardController (c[0]));                
            refb.activateRefund();
            RefundButtonExtension refb1 = new RefundButtonExtension(new ApexPages.StandardController (c[1]));                
            refb1.activateRefund();
            RefundButtonExtension refb2 = new RefundButtonExtension(new ApexPages.StandardController (c[2]));                
            refb2.activateRefund();
            Test.stopTest();
             
            //}catch(Exception e){
            
            }        

            
            }//END testMethod testInvoicePaymentMethod()
            
            static testMethod void testCreditCardPaymentMethod(){
            
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
        }//END testMethod testPaypalPaymentMethod()
        
      /*  static testMethod void testPaypalPaymentMethod(){
            
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
            c.Status = 'open';
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
            billaccount.Zuora__External_Id__c = '00NN0000000zZxc';
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
            zsubList.Zuora__CustomerAccount__c = billaccount.Id;
            zsubList.Qty1__c ='20';  
            zsubList.Order_Number__c = orderList.id;        
            zsubList.Order_Line_Item_Number__c = orderLineItemList.Id;
            zsubList.Delivery_Charge__c = 200;         
            zsubList.Product_Code__c = 'CD001';
            zsubList.Subscription_Type_1__c = 'Publication';
            zsubList.Subscription_Type__c = 'Publication';
            zsubList.Number_of_Copies1__c =  '100';
            zsubList.Number_of_Copies__c = 100;
            zsubList.Qty__c = 20;
            insert zsubList;
           
            
            Zuora__Refund__c thisRefund= testDataFactory.createRefund(1)[0];
            thisRefund.Zuora__Account__c = acct.id;
            thisRefund.Zuora__BillingAccount__c = billaccount.Id;
            //thisRefund.Case__c = c.Id;        
            //thisRefund.Zuora__External_Id__c = 'TestAccount';
            thisRefund.Subscription__c = zsubList.Id;        
            thisRefund.Zuora__Amount__c = 100;
            thisRefund.Payee__c = 'Payee';
            thisRefund.Zuora__RefundDate__c = Date.Today()+5;
            //thisRefund.Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c = '00NN0000000zZxc';        
            insert thisRefund;  
            
            
            /*
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
                     
            //try{
            //Test.setMock(WebServiceMock.class, new zLoginMock());
            Test.startTest();
            PageReference pgRef = Page.RefundButton;
            Test.setCurrentPage(pgRef); 
            ApexPages.currentPage().getParameters().put('id', c.Id);
            ApexPages.currentPage().getParameters().put('id', thisRefund.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(c); 
            
            RefundButtonExtension refb = new RefundButtonExtension(stdCtrlr);
            //refb.thisCase = c;         
            //RefundButtonExtension refb = new RefundButtonExtension(new ApexPages.StandardController (c));        
            refb.activateRefund();
            Test.stopTest();
             
            //}catch(Exception e){
            //}        

          }
        }//END testMethod testPaypalPaymentMethod()
       */ 
    }//END RefundButtonExtension_Test