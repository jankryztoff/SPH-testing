/**
   @Author Val Lu
   @name CreateAdHocPaymentTest
   @CreateDate 02/26/2015
   @Description To test CreateAdHocPayment class
   @Version <1.0>
  */
@isTest(seeAllData = TRUE)
Private class CreateAdHocPaymentTest{
    /**
    *  To test CreateAdHocPayment class
    *  @name testCreateAdHocPayment1
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testCreateAdHocPayment1(){
    
        Account acct = new Account();
        Contact con = new Contact();
        Decimal Amount;
        Date PaymentDate;
        String paymentMethod;
        String myDate;
        String paymentMethodId;
        String cashId;
        String checkId;
        String chequeNo;
        Zuora__CustomerAccount__c billingAcc = new Zuora__CustomerAccount__c();     
        Zuora__Payment__c pmt = new Zuora__Payment__c();  
        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        
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
        
        //The test will run as the user created.        
        System.runAs(u) {
        
            //create vendor subscriber acct        
            acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];        
            insert acct;
            
            system.assertNotEquals(null, acct.id);
            
            //create contact        
            con = TestDataFactory.createContact(1)[0];        
            con.AccountId = acct.Id;        
            insert con;
            
            system.assertNotEquals(null, con.id);
             
            //create billing acct        
            billingAcc = TestDataFactory.createBillingAccount(1)[0];        
            billingAcc.Zuora__Account__c = acct.Id;  
            billingAcc.Zuora__External_Id__c = ConstantsSLB.getKeyId('BAZuoraExternalID');  
            billingAcc.Zuora__Zuora_Id__c = ConstantsSLB.getKeyId('BAZuoraExternalID');
            insert billingAcc; 
            
            system.assertNotEquals(null, billingAcc.id);
    
                
            //create payment
            pmt = TestDataFactory.createPayment(1)[0];        
            pmt.Zuora__BillingAccount__c = billingAcc.id;        
            pmt.Zuora__Account__c = acct.id;     
            insert pmt;  
            
            system.assertNotEquals(null, pmt.id);
            
            try{  
                test.setMock(WebServiceMock.class, new zApiTest());
                Test.startTest(); 
                                       
                //initialize page and controllers            
                PageReference pgRef1 = Page.AdHocPayment;
                pgRef1.getParameters().put('id', billingAcc.Id); 
                Test.setCurrentPage(pgRef1);  
                ApexPages.currentPage().getParameters().put('id', billingAcc.Id);            
        
                // Test for Amount==0 ***************************
                PaymentDate = Date.newInstance(2008, 2, 10);
                Amount = 0; 
                paymentMethod = 'Cash';
                chequeNo = '';
                
                ApexPages.StandardController stdCtrlr1 = new ApexPages.StandardController(billingAcc); 
                
                system.assertNotEquals(null, stdCtrlr1);
                
                CreateAdHocPayment cahp1 = new CreateAdHocPayment (stdCtrlr1); 
                cahp1.PaymentDate = PaymentDate;
                cahp1.Amount = Amount;
                cahp1.paymentMethod = paymentMethod;
                cahp1.ChequeNo = chequeNo;
                cahp1.getPaymentMode();
                cahp1.CreateAdHocPayment();   
                
                // Test for PaymentDate==null ***************************
                PaymentDate = null;
                Amount = 1000; 
                paymentMethod = 'Cash';
                chequeNo = '';
                
                ApexPages.StandardController stdCtrlr2 = new ApexPages.StandardController(billingAcc); 
                
                system.assertNotEquals(null, stdCtrlr2);
                
                CreateAdHocPayment cahp2 = new CreateAdHocPayment (stdCtrlr2); 
                cahp2.PaymentDate = PaymentDate;
                cahp2.Amount = Amount;
                cahp2.paymentMethod = paymentMethod;
                cahp2.ChequeNo = chequeNo;
                cahp2.getPaymentMode();
                cahp2.CreateAdHocPayment();  
    
                // Test for PaymentDate!=null ***************************
                PaymentDate = Date.newInstance(2008, 2, 10);
                Amount = 1000; 
                paymentMethod = 'Cash';
                chequeNo = '';
                
                ApexPages.StandardController stdCtrlr3 = new ApexPages.StandardController(billingAcc); 
                
                system.assertNotEquals(null, stdCtrlr3);
                
                CreateAdHocPayment cahp3 = new CreateAdHocPayment (stdCtrlr3); 
                cahp3.PaymentDate = PaymentDate;
                cahp3.Amount = Amount;
                cahp3.paymentMethod = paymentMethod;
                cahp3.ChequeNo = chequeNo;
                cahp3.getPaymentMode();
                cahp3.CreateAdHocPayment();  
    
                // Test for paymentMethod=='Cheque' ***************************
                PaymentDate = Date.newInstance(2008, 2, 10);
                Amount = 1000; 
                paymentMethod = 'Cheque';
                chequeNo = '';
                
                ApexPages.StandardController stdCtrlr4 = new ApexPages.StandardController(billingAcc); 
                CreateAdHocPayment cahp4 = new CreateAdHocPayment (stdCtrlr4); 
                
                system.assertNotEquals(null, stdCtrlr4);
                
                cahp4.PaymentDate = PaymentDate;
                cahp4.Amount = Amount;
                cahp4.paymentMethod = paymentMethod;
                cahp4.ChequeNo = chequeNo;
                cahp4.getPaymentMode();
                cahp4.CreateAdHocPayment();  
     
                // Test for paymentMethod == 'Cash' && ChequeNo != '' ***************************
                PaymentDate = Date.newInstance(2008, 2, 10);
                Amount = 1000; 
                paymentMethod = 'Cash';
                chequeNo = '1101';
                
                ApexPages.StandardController stdCtrlr5 = new ApexPages.StandardController(billingAcc); 
                CreateAdHocPayment cahp5 = new CreateAdHocPayment (stdCtrlr5); 
                
                system.assertNotEquals(null, stdCtrlr5);
                
                cahp5.PaymentDate = PaymentDate;
                cahp5.Amount = Amount;
                cahp5.paymentMethod = paymentMethod;
                cahp5.ChequeNo = chequeNo;
                cahp5.getPaymentMode();
                cahp5.CreateAdHocPayment();  
                
                
                Test.stopTest(); 
            }
            catch(Exception e){
            }
            
      }  
    }
    
    static testMethod void testCreateAdHocPayment2(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        //end test data
        try{
          test.setMock(WebServiceMock.class, new zApiTest());
          test.startTest();
              ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(billAcc); 
              CreateAdHocPayment cont = new CreateAdHocPayment (stdCtrlr); 
              cont.paymentMethod = 'Cheque';
              cont.PaymentDate = date.today()-2;
              cont.Amount = 5;
              cont.ChequeNo = '';
              cont.CreateAdHocPayment();
              cont.ChequeDate = null;
              cont.Bank = '';
              cont.Type = '';
          test.stopTest();
        }
        catch(Exception e){
      }
      }

    /**
    *  This will create the adhoc payment
    *  @name CreateAP
    *  @param Date paymentDate, integer amount, string paymentMethod,string chequeNo, Zuora__CustomerAccount__c billingAcc
    *  @return none
    *  @throws na
    */    
    private void CreateAP(Date paymentDate, integer amount, string paymentMethod,string chequeNo, Zuora__CustomerAccount__c billingAcc)
    {
            ApexPages.StandardController stdCtrlr5 = new ApexPages.StandardController(billingAcc); 
            CreateAdHocPayment cahp5 = new CreateAdHocPayment (stdCtrlr5); 
            cahp5.PaymentDate = paymentDate;
            cahp5.Amount = amount;
            cahp5.paymentMethod = paymentMethod;
            cahp5.ChequeNo = chequeNo;
            cahp5.getPaymentMode();
            cahp5.CreateAdHocPayment();         
    }
        
    static testMethod void testCreateAdHocPaymentApril(){    
        Account acct = new Account();
        Contact con = new Contact();
        Decimal Amount;
        Date PaymentDate;
        String paymentMethod;
        String myDate;
        String paymentMethodId;
        String cashId;
        String checkId;
        String chequeNo;
        Zuora__CustomerAccount__c billingAcc = new Zuora__CustomerAccount__c();     
        Zuora__Payment__c pmt = new Zuora__Payment__c();  
        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        
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
        
        //The test will run as the user created.        
        System.runAs(u) {
        
            //create vendor subscriber acct        
            acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];        
            insert acct;
            
            system.assertNotEquals(null, acct.id);
            
            //create contact        
            con = TestDataFactory.createContact(1)[0];        
            con.AccountId = acct.Id;        
            insert con;
            
            system.assertNotEquals(null, con.id);
             
            //create billing acct        
            billingAcc = TestDataFactory.createBillingAccount(1)[0];        
            billingAcc.Zuora__Account__c = acct.Id;  
            billingAcc.Zuora__External_Id__c = ConstantsSLB.getKeyId('BAZuoraExternalID');  
            billingAcc.Zuora__Zuora_Id__c = ConstantsSLB.getKeyId('BAZuoraExternalID');
            insert billingAcc; 
            
            system.assertNotEquals(null, billingAcc.id);
    
                
            //create payment
            pmt = TestDataFactory.createPayment(1)[0];        
            pmt.Zuora__BillingAccount__c = billingAcc.id;        
            pmt.Zuora__Account__c = acct.id;     
            insert pmt;  
            
            system.assertNotEquals(null, pmt.id);
            
            try{  
                test.setMock(WebServiceMock.class, new zApiTest());
                Test.startTest(); 
                                       
                //initialize page and controllers            
                PageReference pgRef1 = Page.AdHocPayment;
                pgRef1.getParameters().put('id', billingAcc.Id); 
                Test.setCurrentPage(pgRef1);  
                ApexPages.currentPage().getParameters().put('id', billingAcc.Id);            
        
                // Test for Amount==0 ***************************
                PaymentDate = Date.newInstance(2008, 2, 10);
                Amount = 0; 
                paymentMethod = 'Cheque';
                chequeNo = '';
                
                ApexPages.StandardController stdCtrlr1 = new ApexPages.StandardController(billingAcc); 
                
                system.assertNotEquals(null, stdCtrlr1);
                
                CreateAdHocPayment cahp1 = new CreateAdHocPayment (stdCtrlr1); 
                cahp1.PaymentDate = PaymentDate;
                cahp1.Amount = Amount;
                cahp1.paymentMethod = paymentMethod;
                cahp1.ChequeNo = chequeNo;
                cahp1.getPaymentMode();
                cahp1.CreateAdHocPayment();   
                
                             
                Test.stopTest(); 
            }
            catch(Exception e){
            }
            
      }  
    }
    static testMethod void testCreateAdHocPaymentApril2(){    
        Account acct = new Account();
        Contact con = new Contact();
        Decimal Amount;
        Date PaymentDate;
        String paymentMethod;
        String myDate;
        String paymentMethodId;
        String cashId;
        String checkId;
        String chequeNo;
        Zuora__CustomerAccount__c billingAcc = new Zuora__CustomerAccount__c();     
        Zuora__Payment__c pmt = new Zuora__Payment__c();  
        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        
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
        
        //The test will run as the user created.        
        System.runAs(u) {
        
            //create vendor subscriber acct        
            acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];        
            insert acct;
            
            system.assertNotEquals(null, acct.id);
            
            //create contact        
            con = TestDataFactory.createContact(1)[0];        
            con.AccountId = acct.Id;        
            insert con;
            
            system.assertNotEquals(null, con.id);
             
            //create billing acct        
            billingAcc = TestDataFactory.createBillingAccount(1)[0];        
            billingAcc.Zuora__Account__c = acct.Id;  
            billingAcc.Zuora__External_Id__c = ConstantsSLB.getKeyId('BAZuoraExternalID');  
            billingAcc.Zuora__Zuora_Id__c = ConstantsSLB.getKeyId('BAZuoraExternalID');
            insert billingAcc; 
            
            system.assertNotEquals(null, billingAcc.id);
    
                
            //create payment
            pmt = TestDataFactory.createPayment(1)[0];        
            pmt.Zuora__BillingAccount__c = billingAcc.id;        
            pmt.Zuora__Account__c = acct.id;     
            insert pmt;  
            
            system.assertNotEquals(null, pmt.id);
            
            try{  
                test.setMock(WebServiceMock.class, new zApiTest());
                Test.startTest(); 
                                       
                //initialize page and controllers            
                PageReference pgRef1 = Page.AdHocPayment;
                pgRef1.getParameters().put('id', billingAcc.Id); 
                Test.setCurrentPage(pgRef1);  
                ApexPages.currentPage().getParameters().put('id', billingAcc.Id);            
        
                // Test for Amount==0 ***************************
                PaymentDate = Date.newInstance(2008, 2, 10);
                Amount = 10; 
                paymentMethod = 'Cheque';
                chequeNo = '';
                
                ApexPages.StandardController stdCtrlr1 = new ApexPages.StandardController(billingAcc); 
                
                system.assertNotEquals(null, stdCtrlr1);
                
                CreateAdHocPayment cahp1 = new CreateAdHocPayment (stdCtrlr1); 
                cahp1.PaymentDate = PaymentDate;
                cahp1.Amount = Amount;
                cahp1.paymentMethod = paymentMethod;
                cahp1.ChequeNo = chequeNo;
                cahp1.ChequeDate = date.today().addDays(30);
                cahp1.getPaymentMode();
                cahp1.CreateAdHocPayment();   
                
                             
                Test.stopTest(); 
            }
            catch(Exception e){
            }
            
      }  
    }
    static testMethod void testCreateAdHocPaymentApril3(){    
        Account acct = new Account();
        Contact con = new Contact();
        Decimal Amount;
        Date PaymentDate;
        String paymentMethod;
        String myDate;
        String paymentMethodId;
        String cashId;
        String checkId;
        String chequeNo;
        Zuora__CustomerAccount__c billingAcc = new Zuora__CustomerAccount__c();     
        Zuora__Payment__c pmt = new Zuora__Payment__c();  
        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        
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
        
        //The test will run as the user created.        
        System.runAs(u) {
        
            //create vendor subscriber acct        
            acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];        
            insert acct;
            
            system.assertNotEquals(null, acct.id);
            
            //create contact        
            con = TestDataFactory.createContact(1)[0];        
            con.AccountId = acct.Id;        
            insert con;
            
            system.assertNotEquals(null, con.id);
             
            //create billing acct        
            billingAcc = TestDataFactory.createBillingAccount(1)[0];        
            billingAcc.Zuora__Account__c = acct.Id;  
            billingAcc.Zuora__External_Id__c = ConstantsSLB.getKeyId('BAZuoraExternalID');  
            billingAcc.Zuora__Zuora_Id__c = ConstantsSLB.getKeyId('BAZuoraExternalID');
            insert billingAcc; 
            
            system.assertNotEquals(null, billingAcc.id);
    
                
            //create payment
            pmt = TestDataFactory.createPayment(1)[0];        
            pmt.Zuora__BillingAccount__c = billingAcc.id;        
            pmt.Zuora__Account__c = acct.id;     
            insert pmt;  
            
            system.assertNotEquals(null, pmt.id);
            
            try{  
                test.setMock(WebServiceMock.class, new zApiTest());
                Test.startTest(); 
                                       
                //initialize page and controllers            
                PageReference pgRef1 = Page.AdHocPayment;
                pgRef1.getParameters().put('id', billingAcc.Id); 
                Test.setCurrentPage(pgRef1);  
                ApexPages.currentPage().getParameters().put('id', billingAcc.Id);            
        
                // Test for Amount==0 ***************************
                PaymentDate = null;
                Amount = null; 
                paymentMethod = 'Cheque';
                chequeNo = '112540';
                
                ApexPages.StandardController stdCtrlr1 = new ApexPages.StandardController(billingAcc); 
                
                system.assertNotEquals(null, stdCtrlr1);
                
                CreateAdHocPayment cahp1 = new CreateAdHocPayment (stdCtrlr1); 
                cahp1.PaymentDate = PaymentDate;
                cahp1.Amount = Amount;
                cahp1.paymentMethod = paymentMethod;
                cahp1.ChequeNo = chequeNo;
                cahp1.Bank = 'BDO';
                cahp1.ChequeDate = null;
                cahp1.chqDate = ''+date.today();
                cahp1.getPaymentMode();
                cahp1.paymentMethod = paymentMethod;
                cahp1.CreateAdHocPayment();   
                
                             
                Test.stopTest(); 
            }
            catch(Exception e){
            }
            
      }  
    }
}