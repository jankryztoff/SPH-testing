@isTest(seeAllData = true)
private class LP_CreditCardFailureControllerTesty{

    static testmethod void testLocal(){
    
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert acc;
        
        List<Address__c> addrs = TestDataFactory.createAddress(1);
        for(Address__c addr: addrs){
            addr.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Local' and SobjectType = 'Address__c'].Id;
        }
        insert addrs;
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        for(Contact contact: contacts){
            contact.Address__c = addrs[0].id;
        }
        insert contacts;
        
        Contact cont = TestDataFactory.createContact(1)[0];
        insert cont;
        
        
    
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
        for(Zuora__CustomerAccount__c bill: billAcc){
            bill.Zuora__Account__c = acc[0].id;
            bill.Billing_Contact__c = contacts[0].id;
        }
        insert billAcc;
        
               List<External_Payment__c> externalPayments = TestDataFactory.createExternalPayment(1);
        for(External_Payment__c extPayment: externalPayments){
            extPayment.Transaction_Type__c = 'F';
            extPayment.Billing_Account__c = billAcc[0].id;
        }
        insert externalPayments;
        
        List<Package__c> packs = TestDataFactory.createPackage(1);
        insert packs;
        
        List<Zuora__Subscription__c> subs= TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            sub.Recipient_Contact__c = cont.id;
            sub.Main_Package_1__c = packs[0].id;
            sub.Main_Package__c = packs[0].id;
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Contact__c = contacts[0].id;
            sub.Number_of_Copies1__c = '1';
            sub.Zuora__CustomerAccount__c = billAcc[0].id;
        }
        insert subs;
        
         Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test Invoice';
        zInvoice.Zuora__Account__c = acc[0].id;
        zInvoice.Zuora__Zuora_Id__c = 'TestZuora';
        zInvoice.Zuora__BillingAccount__c = billAcc[0].Id;
        zInvoice.Zuora__Balance2__c = 500;
        insert zInvoice;    
    
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = 'TestZuora'; //zInv.Zuora__Zuora_Id__c;
            invLineItem.Name = 'Test Invoice';
            invLineItem.Subscription__c = subs[0].id;
            invLineItem.Charge_Amount__c = 100.00;
            invLineItem.Tax_Amount__c = 10.00;
            insert invLineItem;
        
        List<Zuora__SubscriptionProductCharge__c> subsProdCharges = TestDataFactory.createSubProductCharge(1);
        for(Zuora__SubscriptionProductCharge__c subsProdCharge: subsProdCharges){
            subsProdCharge.Zuora__Subscription__c = subs[0].id;
            subsProdCharge.PublicationCode__c = 'Sample Pub Code';
        }
        insert subsProdCharges;
        
        Zuora__SubscriptionProductCharge__c zuoraProdCharge = new Zuora__SubscriptionProductCharge__c();
        zuoraProdCharge.Zuora__Subscription__c = subs[0].id;
        zuoraProdCharge.PublicationCode__c = 'Test';
        insert zuoraProdCharge;
            
        PageReference pgRef = Page.LP_CreditCardFailure;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', externalPayments[0].id);
        
        Test.startTest();    
        LP_CreditCardFailureController ccfailureController = new LP_CreditCardFailureController();
        ccfailureController.initialize();
        Test.stopTest();
    }
    
    static testmethod void testAirline(){
    
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert acc;
        
        List<Address__c> addrs = TestDataFactory.createAddress(1);
        for(Address__c addr: addrs){
            addr.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Airline' and SobjectType = 'Address__c'].Id;
        }
        insert addrs;
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        for(Contact contact: contacts){
            contact.Address__c = addrs[0].id;
        }
        insert contacts;
        
        Contact cont = TestDataFactory.createContact(1)[0];
        insert cont;
    
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
        for(Zuora__CustomerAccount__c bill: billAcc){
            bill.Zuora__Account__c = acc[0].id;
            bill.Billing_Contact__c = contacts[0].id;
        }
        insert billAcc;
        
        List<External_Payment__c> externalPayments = TestDataFactory.createExternalPayment(1);
        for(External_Payment__c extPayment: externalPayments){
            extPayment.Transaction_Type__c = 'F';
            extPayment.Billing_Account__c = billAcc[0].id;
        }
        insert externalPayments;
        
        List<Package__c> packs = TestDataFactory.createPackage(1);
        insert packs;
        
        List<Zuora__Subscription__c> subs= TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            sub.Recipient_Contact__c = cont.id;
            sub.Main_Package_1__c = packs[0].id;
            sub.Contact__c = contacts[0].id;
            sub.Number_of_Copies1__c = '1';
            sub.Zuora__CustomerAccount__c = billAcc[0].id;
        }
        insert subs;
        
        List<Zuora__SubscriptionProductCharge__c> subsProdCharges = TestDataFactory.createSubProductCharge(1);
        for(Zuora__SubscriptionProductCharge__c subsProdCharge: subsProdCharges){
            subsProdCharge.Zuora__Subscription__c = subs[0].id;
            subsProdCharge.PublicationCode__c = 'Sample Pub Code';
        }
        insert subsProdCharges;
            
        PageReference pgRef = Page.LP_CreditCardFailure;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', externalPayments[0].id);
        
        Test.startTest();    
        LP_CreditCardFailureController ccfailureController = new LP_CreditCardFailureController();
        ccfailureController.initialize();
        ccfailureController.HomeNumber = '';
        ccfailureController.OfficeNumber = '';
        ccfailureController.MobileNumber = '';
        ccfailureController.mailingStreet = '';
        ccfailureController.contactMailingAddress = '';
        ccfailureController.mailingCity = '';
        ccfailureController.mailingPostalCode = '';
        ccfailureController.mailingCountry = '';
        ccfailureController.mailingBlk = '';
        ccfailureController.mailingLevel = '';
        ccfailureController.mailingUnit = '';
        ccfailureController.mailingBuilding= '';
        Test.stopTest();
    }
    
    static testmethod void testOverseas(){
    
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert acc;
        
        List<Address__c> addrs = TestDataFactory.createAddress(1);
        for(Address__c addr: addrs){
            addr.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Overseas' and SobjectType = 'Address__c'].Id;
        }
        insert addrs;
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        for(Contact contact: contacts){
            contact.Address__c = addrs[0].id;
        }
        insert contacts;
        
        Contact cont = TestDataFactory.createContact(1)[0];
        insert cont;
    
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
        for(Zuora__CustomerAccount__c bill: billAcc){
            bill.Zuora__Account__c = acc[0].id;
            bill.Billing_Contact__c = contacts[0].id;
        }
        insert billAcc;
        
        List<External_Payment__c> externalPayments = TestDataFactory.createExternalPayment(1);
        for(External_Payment__c extPayment: externalPayments){
            extPayment.Transaction_Type__c = 'F';
            extPayment.Billing_Account__c = billAcc[0].id;
        }
        insert externalPayments;
        
        List<Package__c> packs = TestDataFactory.createPackage(1);
        insert packs;
        
        List<Zuora__Subscription__c> subs= TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            sub.Recipient_Contact__c = cont.id;
            sub.Main_Package_1__c = packs[0].id;
            sub.Contact__c = contacts[0].id;
            sub.Number_of_Copies1__c = '1';
            sub.Zuora__CustomerAccount__c = billAcc[0].id;
            sub.Contact__c = contacts[0].id;
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
        }
        insert subs;
        
        List<Zuora__SubscriptionProductCharge__c> subsProdCharges = TestDataFactory.createSubProductCharge(1);
        for(Zuora__SubscriptionProductCharge__c subsProdCharge: subsProdCharges){
            subsProdCharge.Zuora__Subscription__c = subs[0].id;
            subsProdCharge.PublicationCode__c = 'Sample Pub Code';
        }
        insert subsProdCharges;
            
        PageReference pgRef = Page.LP_CreditCardFailure;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', externalPayments[0].id);
        
        Test.startTest();    
        LP_CreditCardFailureController ccfailureController = new LP_CreditCardFailureController();
        ccfailureController.initialize();
        Test.stopTest();
    }      
    
    static testmethod void testInternal(){
    
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert acc;
        
        List<Address__c> addrs = TestDataFactory.createAddress(1);
        for(Address__c addr: addrs){
            addr.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Internal' and SobjectType = 'Address__c'].Id;
        }
        insert addrs;
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        for(Contact contact: contacts){
            contact.Address__c = addrs[0].id;
        }
        insert contacts;
        
        //Contact cont = TestDataFactory.createContact(1)[0];
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.LastName = 'Sample Last';
        cont.Address__c = addrs[0].id;
        insert cont;
        
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
        for(Zuora__CustomerAccount__c bill: billAcc){
            bill.Zuora__Account__c = acc[0].id;
            bill.Billing_Contact__c = cont.id;
        }
        insert billAcc;
        
        List<External_Payment__c> externalPayments = TestDataFactory.createExternalPayment(1);
        for(External_Payment__c extPayment: externalPayments){
            extPayment.Transaction_Type__c = 'F';
            extPayment.Billing_Account__c = billAcc[0].id;
        }
        insert externalPayments;
        
        List<Package__c> packs = TestDataFactory.createPackage(1);
        insert packs;
        
        List<Zuora__Subscription__c> subs= TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            sub.Recipient_Contact__c = cont.id;
            sub.Main_Package_1__c = packs[0].id;
            sub.Contact__c = contacts[0].id;
            sub.Number_of_Copies1__c = '1';
            sub.Zuora__CustomerAccount__c = billAcc[0].id;
        }
        insert subs;
        
        List<Zuora__SubscriptionProductCharge__c> subsProdCharges = TestDataFactory.createSubProductCharge(1);
        for(Zuora__SubscriptionProductCharge__c subsProdCharge: subsProdCharges){
            subsProdCharge.Zuora__Subscription__c = subs[0].id;
            subsProdCharge.PublicationCode__c = 'Sample Pub Code';
        }
        insert subsProdCharges;
            
        PageReference pgRef = Page.LP_CreditCardFailure;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', externalPayments[0].id);
        
        Test.startTest();    
        LP_CreditCardFailureController ccfailureController = new LP_CreditCardFailureController();
        ccfailureController.initialize();
        Test.stopTest();
    }     
}