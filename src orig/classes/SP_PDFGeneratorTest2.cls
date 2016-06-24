@isTest
private class SP_PDFGeneratorTest2 {
    
    static testMethod void testCreditNote() {
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        system.assert(accQ.AccountNumber<>null);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
    
        test.startTest();
        Try{
            SP_PDFGenerator.insertAttachment(parentIdList, 'Credit_Notes', letterSubTypeMap,date.today(),date.today()+2,true);
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void testAcknowledgment_Letter() {
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.AccountNumber = '123';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        test.startTest();
        Try{
            SP_PDFGenerator.insertAttachment(parentIdList, 'Credit_Notes', letterSubTypeMap,date.today()+1,date.today()+2,true);
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void testSecond_Renewal_Reminder_for_Newspaper() {
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.AccountNumber = '123';
        database.insert(acc);
        parentIdList.add(acc.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
    
        test.startTest();
        Try{
             SP_PDFGenerator.insertAttachment(parentIdList, 'Second_Renewal_Reminder_for_Newspaper', letterSubTypeMap,date.today()+1,date.today()+2,true);
      
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void testInvoice_Letter() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.AccountNumber = '123';
        database.insert(acc);
        parentIdList.add(acc.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
    
        test.startTest();
        Try{
           SP_PDFGenerator.insertAttachment(parentIdList, 'Invoice_Letter', letterSubTypeMap,date.today()+1,date.today()+2,true);
         
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void testAirline_Subscription_Wrapper() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscriber_Account_Number__c = accQ.AccountNumber;
        database.insert(packLabel);
        parentIdList.add(packLabel.Id);
    
        test.startTest();
        Try{
         SP_PDFGenerator.insertAttachment(parentIdList, 'Airline_Subscription_Wrapper', letterSubTypeMap,date.today()+1,date.today()+2,true);
            
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void testPacking_Label_Letter() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscriber_Account_Number__c = accQ.AccountNumber;
        database.insert(packLabel);
        parentIdList.add(packLabel.Id);
    
        test.startTest();
        Try{
        SP_PDFGenerator.insertAttachment(parentIdList, 'Packing_Label_Letter', letterSubTypeMap,date.today()+1,date.today()+2,true);
           
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void testFirst_Renewal_Reminder_for_Magazine() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscriber_Account_Number__c = accQ.AccountNumber;
        database.insert(packLabel);
        parentIdList.add(packLabel.Id);
    
        test.startTest();
        Try{
        SP_PDFGenerator.insertAttachment(parentIdList, 'First_Renewal_Reminder_for_Magazine', letterSubTypeMap,date.today()+1,date.today()+2,true);
           
            test.stoptest();
        }
        catch(Exception e){}
    }
    //jurna
    static testMethod void testFirst_Renewal_Reminder_for_Magazine2() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscriber_Account_Number__c = accQ.AccountNumber;
        database.insert(packLabel);
        parentIdList.add(packLabel.Id);
    
        test.startTest();
        SP_PDFGenerator spGen = new SP_PDFGenerator();
        
        Try{
        
        SP_PDFGenerator.insertAttachment(parentIdList, 'First_Renewal_Reminder_for_Magazine', letterSubTypeMap,date.today()+1,date.today()+2,true);
           
            test.stoptest();
        }
        catch(Exception e){}
    }
    
     static testMethod void testFAILED_PAYPAL_NOTIFICATION() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
            Zuora__Payment__c paymentRecord = new Zuora__Payment__c();
            paymentRecord.Zuora__BillingAccount__c = billAcc.id;
            paymentRecord.Name='TestPayment';
            paymentRecord.Zuora__Amount__c=100.00;
            paymentRecord.Zuora__PaymentMethod__c='Payment Method';
            paymentRecord.Zuora__EffectiveDate__c = date.today();
            paymentRecord.Zuora__Type__c = 'Electronic';
            paymentRecord.Zuora__Status__c = 'Error';
            paymentRecord.Is_PDF_Generated__c = false;
            database.insert(paymentRecord);
            
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        parentIdList.add(paymentRecord.Id);
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscriber_Account_Number__c = accQ.AccountNumber;
        database.insert(packLabel);
        parentIdList.add(packLabel.Id);
    
        test.startTest();
        Try{
        SP_PDFGenerator.insertAttachment(parentIdList, 'PayPal_Failure_Notification', letterSubTypeMap,date.today()+1,date.today()+2,true);
           
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void testacknowledgmentLetter() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscriber_Account_Number__c = accQ.AccountNumber;
        database.insert(packLabel);
        parentIdList.add(packLabel.Id);
    
        test.startTest();
        Try{
        SP_PDFGenerator.insertAttachment(parentIdList, 'Acknowledgment_Letter', letterSubTypeMap,date.today()+1,date.today()+2,true);
           
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void giftLetter() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        database.insert(con);  
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        
        Attachment attach= new Attachment();
        attach.Parentid = con.id;
        
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        parentIdList.add(attach.id);
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscriber_Account_Number__c = accQ.AccountNumber;
        database.insert(packLabel);
        parentIdList.add(packLabel.Id);
    
        test.startTest();
        Try{
        SP_PDFGenerator.insertAttachment(parentIdList, 'Gift_SPHM_(Eng)', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Gift_SPH_Mag_w/o_Date_(Eng)', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Gift_Retention_(Eng)', letterSubTypeMap,date.today()+1,date.today()+2,true);   
        SP_PDFGenerator.insertAttachment(parentIdList, 'Gift_IPP_(Eng)', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Gift_Premium_(Chi)', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Gift_Premium_(Eng)', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Credit_Card_Failure_Notification', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Second_Renewal_Reminder_for_Magazine', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'First_Renewal_Reminder_for_Newspaper', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Overseas_Newspaper_Report_Hard_Copy', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Overseas_Newspaper_Wrapper', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Magazine_Internal_Wrapper', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Airline_Subscription_Report_Hard_Copy', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Airline_Subscription_Wrapper', letterSubTypeMap,date.today()+1,date.today()+2,true);
            test.stoptest();
        }
        catch(Exception e){}
    }
    
    static testMethod void giftLettertest() {
        Integer counter = 0;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        List<String> parentIdList = new List<String>();
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
    
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote.Credit_Note_Number__c = '123';
        database.insert(creditNote);
        parentIdList.add(creditNote.Id);
        letterSubTypeMap.put(creditNote.Id, new List<String>{'LetterType'});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = '123';
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        database.insert(con);  
        
        Account accQ = [SELECT AccountNumber FROM Account WHERE Id =: acc.Id];
        parentIdList.add(accQ.AccountNumber);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        parentIdList.add(billAcc.Id);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c =  billAcc.Id;
        database.insert(sub);
        parentIdList.add(sub.Id);
        letterSubTypeMap.put(sub.Id, new List<String>{'LetterType2'});
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
        
        counter=0;
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(2);
        for(Zuora__ZInvoice__c zi: invoice){
            if(counter==1){
                zi.ARMS_Invoice_ID__c = 'inv001';
            }
            zi.Zuora__InvoiceDate__c = date.today();
            counter++;
        }
        database.insert(invoice);
        
        Attachment attach= new Attachment();
        attach.Parentid = con.id;
        
        parentIdList.add(invoice[0].Id);
        parentIdList.add(invoice[1].Id);
        parentIdList.add(attach.id);
        //Zuora__ZInvoice__c invoiceQ = [SELECT ARMS_Invoice_ID__c FROM Zuora__ZInvoice__c WHERE id=: invoice[1].Id];
        //system.assertEquals(invoiceQ.ARMS_Invoice_ID__c, 'inv001');
        
        Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
        packLabel.Subscriber_Account_Number__c = accQ.AccountNumber;
        database.insert(packLabel);
        parentIdList.add(packLabel.Id);
    
        test.startTest();
        Try{
        SP_PDFGenerator.insertAttachment(parentIdList, 'Overseas_Newspaper_Report_Hard_Copy', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Overseas_Newspaper_Wrapper', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Magazine_Internal_Wrapper', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Airline_Subscription_Report_Hard_Copy', letterSubTypeMap,date.today()+1,date.today()+2,true);
        SP_PDFGenerator.insertAttachment(parentIdList, 'Airline_Subscription_Wrapper', letterSubTypeMap,date.today()+1,date.today()+2,true);
            test.stoptest();
        }
        catch(Exception e){}
    }

}