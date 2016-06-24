@isTest
private class InvoiceControllerTest2{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
    }
    
    static testMethod void testInvoiceController(){
        //start custom settings
        //Key_Id__c key = new Key_Id__c();
        //key.Name = 'Account_Direct SPH Inter-Division';
        //key.Id__c = '012N00000008l28IAA';
        //key.Type__c = 'RecordType';
        //database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        //April Veloso 11102015
        Other__c other1 = new Other__c();
        other1.Name = 'Invoice Total Lines';
        other1.Value__c = '10';
        database.insert(other1);

        //April Veloso 11102015
        Other__c other2 = new Other__c();
        other2.Name = 'Invoice Total Package Char';
        other2.Value__c = '1';
        database.insert(other2);
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        database.insert(postal);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = postal.Id;
        add.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND Name = 'Internal'].Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Payment_Mode__c = 'CreditCard';
        billAcc.Zuora__Balance__c = 103;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Recurring';
        billAcc.Billing_Contact__c = con.Id;
        database.insert(billAcc);
        
        Attachment att = new Attachment();
        att.ParentId = postal.Id;
        att.Name = 'hdfh';
        att.Body = blob.valueOf('body');
        database.insert(att);
        
        Zuora__ZInvoice__c inv = TestDataFactory.createInvoice(1)[0];
        inv.Zuora__BillingAccount__c = billAcc.Id;
        inv.Zuora__DueDate__c = date.today();
        inv.Zuora__TotalAmount__c = 100;
        inv.Zuora__InvoiceDate__c = date.today();
        inv.ARMS_Invoice_ID__c = '123456';
        inv.Zuora__PaymentAmount__c = 25;
        inv.Zuora__Zuora_Id__c = '123456';
        inv.Previous_Balance__c = '100';
        database.insert(inv);
        
        List<Invoice_Line_Item__c> invLI = new List<Invoice_Line_Item__c>{
        new Invoice_Line_Item__c(Invoice_ID__c = inv.Zuora__Zuora_Id__c, 
        //UOM__c = 'NO CREDIT',
        UOM__c = 'UOM CREDIT',
        Charge_Amount__c = 100,
        Subscription_Number__c = '123', Tax_Amount__c = 20),
        new Invoice_Line_Item__c(Invoice_ID__c = inv.Zuora__Zuora_Id__c, 
        //UOM__c = 'NO CREDIT',
        UOM__c = 'UOM CREDIT',
        Charge_Amount__c = 100,
        Subscription_Number__c = '123', Tax_Amount__c = 20)
        };
        database.insert(invLI);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Name = '123';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Main_Package_1__c = pack.id;    //April Veloso 11102015
        subRecs.Main_Package__c = pack.id;        //April Veloso 11102015
        database.insert(subRecs);
        //end test data
    
        test.startTest();
            pageReference pageRef = page.InvoiceTaxTemplate;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', inv.Id);
            
            InvoiceController cont = new InvoiceController();
            
            billAcc.ARMS_Account_Number__c = '123456';
            billAcc.Other_PaymentMethod__c = 'Invoice';
            billAcc.ARMS_Total_Outstanding_Amount__c = 10;
            billAcc.Attention_To_Care_Of_Salutation__c = 'MS';
            database.update(billAcc);
            
            inv.ARMS_Invoice_ID__c = '123';
            inv.ARMS_Invoice_ID__c = null;
            database.update(inv);
            
            invLI[0].Applied_To_Invoice_Item_ID__c = '123';
            invLI[1].Applied_To_Invoice_Item_ID__c = '123';
            database.update(invLI);
            
            InvoiceController cont2 = new InvoiceController();
            
            invLI[0].Charge_Amount__c = -1; 
            invLI[1].Charge_Amount__c = -1; 
            database.update(invLI);
            
            billAcc.Billing_Type__c = 'Full Prepaid';
            database.update(billAcc);
            
            InvoiceController cont3 = new InvoiceController();  
            
            invLI[0].Charge_Amount__c = 50; 
            invLI[1].Charge_Amount__c = 50; 
            database.update(invLI);  
            
            subRecs.Subscription_Type__c = 'Gift'; 
            database.update(subRecs);
            
            InvoiceController cont4 = new InvoiceController();   
            
            invLI[0].Applied_To_Invoice_Item_ID__c = null;
            invLI[1].Applied_To_Invoice_Item_ID__c = null;
            invLI[0].Charge_Amount__c = -1; 
            invLI[1].Charge_Amount__c = -1;   
            database.update(invLI);  
            
            subRecs.Subscription_Type__c = 'Postage'; 
            database.update(subRecs);
            
            InvoiceController cont5 = new InvoiceController();    
            
            invLI[0].UOM__c = 'NO CREDIT';
            invLI[1].UOM__c = 'NO CREDIT';
            invLI[0].Tax_Amount__c = 0;
            invLI[1].Tax_Amount__c = 0; 
            invLI[0].Service_Start_Date__c = date.today(); 
            invLI[1].Service_Start_Date__c = date.today();
            invLI[0].Service_End_Date__c = date.today()+35; 
            invLI[1].Service_End_Date__c = date.today()+35;    
            database.update(invLI);
            
            subRecs.Subscription_Type__c = 'Delivery';
            subRecs.PO_Number__c = '123';
            subRecs.Billing_Type__c = 'Recurring Prepaid';
            database.update(subRecs);
            
            InvoiceController cont6 = new InvoiceController();
            cont6.IsRecurring('');
            cont6.isRecipientOverseas = false;
        test.stopTest();
    }
    
    static testMethod void testInvoiceController2(){
        //start custom settings
        //Key_Id__c key = new Key_Id__c();
        //key.Name = 'Account_Direct SPH Inter-Division';
        //key.Id__c = '012N00000008l28IAA';
        //key.Type__c = 'RecordType';
        //database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        //April Veloso 11102015
        Other__c other1 = new Other__c();
        other1.Name = 'Invoice Total Lines';
        other1.Value__c = '10';
        database.insert(other1);

        //April Veloso 11102015
        Other__c other2 = new Other__c();
        other2.Name = 'Invoice Total Package Char';
        other2.Value__c = '1';
        database.insert(other2);
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        database.insert(postal);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = postal.Id;
        add.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND Name = 'Internal'].Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Payment_Mode__c = 'CreditCard';
        billAcc.Zuora__Balance__c = 103;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Recurring';
        billAcc.Billing_Contact__c = con.Id;
        database.insert(billAcc);
        
        Attachment att = new Attachment();
        att.ParentId = postal.Id;
        att.Name = 'hdfh';
        att.Body = blob.valueOf('body');
        database.insert(att);
        
        Zuora__ZInvoice__c inv = TestDataFactory.createInvoice(1)[0];
        inv.Zuora__BillingAccount__c = billAcc.Id;
        inv.Zuora__DueDate__c = date.today();
        inv.Zuora__TotalAmount__c = 360;
        inv.Zuora__InvoiceDate__c = date.today();
        inv.ARMS_Invoice_ID__c = '123456';
        inv.Zuora__PaymentAmount__c = 25;
        inv.Zuora__Zuora_Id__c = '123456';
        inv.Previous_Balance__c = '100';
        database.insert(inv);
        
        List<Invoice_Line_Item__c> invLI = new List<Invoice_Line_Item__c>{
        new Invoice_Line_Item__c(Invoice_ID__c = inv.Zuora__Zuora_Id__c, 
        //UOM__c = 'NO CREDIT',
        UOM__c = 'UOM CREDIT',
        Charge_Amount__c = 100,
        Subscription_Number__c = '123', Tax_Amount__c = 20),
        new Invoice_Line_Item__c(Invoice_ID__c = inv.Zuora__Zuora_Id__c, 
        //UOM__c = 'NO CREDIT',
        UOM__c = 'UOM CREDIT',
        Charge_Amount__c = 100,
        Subscription_Number__c = '123', Tax_Amount__c = 20),
        new Invoice_Line_Item__c(Invoice_ID__c = inv.Zuora__Zuora_Id__c, 
        //UOM__c = 'NO CREDIT',
        UOM__c = 'Copy',
        Charge_Amount__c = 100,
        Subscription_Number__c = '123', Tax_Amount__c = 20)
        };
        
        database.insert(invLI);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Name = '123';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Main_Package_1__c = pack.id;    //April Veloso 11102015
        subRecs.Main_Package__c = pack.id;        //April Veloso 11102015
        subRecs.Recipient_Contact__c = con.Id;
        database.insert(subRecs);
        //end test data
    
        test.startTest();
            pageReference pageRef = page.InvoiceTaxTemplate;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', inv.Id);
            
            InvoiceController cont = new InvoiceController();
            
            billAcc.ARMS_Account_Number__c = '123456';
            billAcc.Other_PaymentMethod__c = 'Invoice';
            billAcc.ARMS_Total_Outstanding_Amount__c = 10;
            billAcc.Attention_To_Care_Of_Salutation__c = 'MS';
            database.update(billAcc);
            
            inv.ARMS_Invoice_ID__c = '123';
            inv.ARMS_Invoice_ID__c = null;
            database.update(inv);
            
            invLI[0].Applied_To_Invoice_Item_ID__c = '123';
            invLI[1].Applied_To_Invoice_Item_ID__c = '123';
            database.update(invLI);
            
            InvoiceController cont2 = new InvoiceController();
            
            invLI[0].Charge_Amount__c = -1; 
            invLI[1].Charge_Amount__c = -1; 
            database.update(invLI);
            
            billAcc.Billing_Type__c = 'Full Prepaid';
            database.update(billAcc);
            
            InvoiceController cont3 = new InvoiceController();  
            
            invLI[0].Charge_Amount__c = 50; 
            invLI[1].Charge_Amount__c = 50; 
            database.update(invLI);  
            
            subRecs.Subscription_Type__c = 'Gift'; 
            database.update(subRecs);
            
            InvoiceController cont4 = new InvoiceController();   
            
            invLI[0].Applied_To_Invoice_Item_ID__c = null;
            invLI[1].Applied_To_Invoice_Item_ID__c = null;
            invLI[0].Charge_Amount__c = -1; 
            invLI[1].Charge_Amount__c = -1;   
            database.update(invLI);  
            
            subRecs.Subscription_Type__c = 'Postage'; 
            database.update(subRecs);
            
            InvoiceController cont5 = new InvoiceController();    
            
            invLI[0].UOM__c = 'NO CREDIT';
            invLI[1].UOM__c = 'NO CREDIT';
            invLI[0].Tax_Amount__c = 0;
            invLI[1].Tax_Amount__c = 0; 
            invLI[0].Service_Start_Date__c = date.today(); 
            invLI[1].Service_Start_Date__c = date.today();
            invLI[0].Service_End_Date__c = date.today()+35; 
            invLI[1].Service_End_Date__c = date.today()+35;    
            database.update(invLI);
            
            subRecs.Subscription_Type__c = 'Delivery';
            subRecs.PO_Number__c = '123';
            subRecs.Billing_Type__c = 'Recurring Prepaid';
            database.update(subRecs);
            
            InvoiceController cont6 = new InvoiceController();
            cont6.IsRecurring('');
            cont6.isRecipientOverseas = false;
        test.stopTest();
    }
    
}