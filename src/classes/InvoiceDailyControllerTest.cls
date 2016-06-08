@isTest
private class InvoiceDailyControllerTest{
    static testMethod void testInvoiceController(){
        //start custom settings
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Account_Direct SPH Inter-Division';
        key.Id__c = '012N00000008l28IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Key_Id__c keyRec = new Key_Id__c();
        keyRec.Name = 'NEXT_RECIPIENT_NUMBER';
        keyRec.Id__c = '30000000';
        keyRec.Type__c = 'RecordType';
        database.insert(keyRec);
        
        Id addId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND Name = 'Overseas'].Id;
        
        Key_Id__c keyAdd = new Key_Id__c();
        keyAdd.Name = 'Address_Overseas';
        keyAdd.Id__c = addId;
        keyAdd.Type__c = 'RecordType';
        database.insert(keyAdd);
        
        Other__c other = new Other__c();
        other.Name = 'GST';
        other.Value__c = '5';
        database.insert(other);

        Other__c other1 = new Other__c();
        other1.Name = 'Invoice Total Lines';
        other1.Value__c = '10';
        database.insert(other1);
        
        Other__c other4 = new Other__c();
        other4.Name = 'Order_Type Renewal';
        other4.Value__c = 'Renewal';
        database.insert(other4);

        //April Veloso 11102015
        Other__c other2 = new Other__c();
        other2.Name = 'Invoice Total Package Char';
        other2.Value__c = '1';
        database.insert(other2);
        //end custom settings
        Other__c other3 = new Other__c();
        other3.Name = 'DTL';
        other3.Value__c = '23:59';
        database.insert(other3);    
        //start test data
        Country__c cou = TestDataFactory.createCountry(1)[0];
        database.insert(cou);
        
        City__c cit = TestDataFactory.createCity(1)[0];
        cit.Country__c = cou.id;
        cit.Flight_Number_1__c = 'Test1';
        database.insert(cit);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        database.insert(acc);
        
        Account accVendor = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        database.insert(accVendor);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        
        database.insert(postal);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Country__c = cou.id;
        add.Postal_Code__c = postal.Id;
        add.Address_1__c = 'Address1';
        add.Address_2__c = 'Address2';
        add.Address_3__c = 'Address3';
        add.Address_4__c = 'Address4';
        add.City__c = cit.id;
        add.Level_Number__c = '00';
        add.Unit_Number__c = '00';
        add.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND Name = 'Overseas'].Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Account = accVendor;
        con.Address__c = add.Id;
        con.Recipient_Indicator__c = True;
        database.insert(con);
        System.debug('@@@@@@@' + con.Account);
        
       
        

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.billing_Account_Name_2__c  = billAcc.Name;
        billAcc.Payment_Mode__c = 'CreditCard';
        billAcc.Zuora__Balance__c = 103;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Recurring';
        billAcc.Billing_Contact__c = con.Id;
        billAcc.ARMS_Account_Number__c = '123456';
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.ARMS_Total_Outstanding_Amount__c = 10;
        billAcc.Attention_To_Care_Of_Salutation__c = 'MS';
        billAcc.Bank__c = 'TestBank';
        billAcc.ARMS_Total_Outstanding_Amount__c = 10;
        billAcc.Zuora__Balance__c = 10;
        database.insert(billAcc);

        Attachment att = new Attachment();
        att.ParentId = postal.Id;
        att.Name = 'hdfh';
        att.Body = blob.valueOf('body');
        database.insert(att);
 
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        

    
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        //orderRec.Informed_Customer__c = TRUE;
        //orderRec.Recipient_Contact__c = con.Id;
        orderRec.Delivery_Charge__c = 4;
        orderRec.Order_Legacy_Id__c = '3421';
        orderRec.Legacy_Create_By__c = '1';
        orderRec.Legacy_Create_Date__c = '1';
        orderRec.Legacy_Update_By__c = '1';
        orderRec.Legacy_Update_Date__c = '1';
        orderRec.Monthly_Delivery_Charge_for_Full_Payment__c = 4;
        orderRec.Credit_Balance__c =1;
        orderRec.Subscriber_charge__c = 100;
        database.insert(orderRec);
        
        System.debug('@@@' + orderRec.Order_Type__c);
        
        Order_Line_Item__c orderline2 = TestDataFactory.createOrderLineItem(1)[0];
        orderline2.Order__c = orderRec.Id;
        orderline2.End_Date__c = date.newInstance(2014, 12, 2);
        orderline2.Main_Package_ID__c = pack.Id;
        orderline2.Term_Length__c = 0;
        orderline2.Main_Package_Period__c = 0;
        orderline2.Earliest_Start_Date__c = date.today();
        orderline2.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline2.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline2.Terminating_Reason__c = 'Others';
        orderline2.Amount_To_Refund__c = 0;
        orderline2.Admin_Charge__c = 0;
        orderline2.Fee_Waiver__c = TRUE;
            //orderline2.Fee_Override__c = TRUE;
        orderline2.Fee_Override__c = FALSE;
        orderline2.Override_Reason__c = 'TEST';
        orderline2.Suppress_Notification_Stop__c = TRUE;
        orderline2.Main_Package_Type__c = 'Base';
        orderline2.Start_Date__c = date.today().addDays(2);
        orderline2.End_Date__c = Date.Today().addDays(10);
        database.insert(orderline2);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Name = '123';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Main_Package_1__c = pack.id;  
        subRecs.Order_Number__c = orderRec.Id;
        subRecs.Order_Line_Item_Number__c = orderline2.Id;
        subRecs.Main_Package__c = pack.id; 
        subRecs.Billing_Type__c = 'Recurring Prepaid';
        subRecs.PO_Number__c = 'Test';        
        subRecs.Recipient_Contact__c = con.id;
        database.insert(subRecs);
                
        Daily_Invoice__c dailyInv = new Daily_Invoice__c ();
        dailyInv.Billing_Account__c = billAcc.id;
        dailyInv.Total_Amt__c = 25;
        dailyInv.Invoice_Date__c = Date.today();
        dailyInv.Payment_Amt__c = 10;
        dailyInv.Prev_Bal__c = 5; 
        
        database.insert(dailyInv);
        
        Zuora__ZInvoice__c inv = TestDataFactory.createInvoice(1)[0];
        inv.Zuora__BillingAccount__c = billAcc.Id;
        inv.Zuora__DueDate__c = date.today();
        inv.Zuora__TotalAmount__c = 100;
        inv.Zuora__InvoiceDate__c = date.today();
        inv.ARMS_Invoice_ID__c = '123456';
        inv.Zuora__PaymentAmount__c = 25;
        inv.Zuora__Zuora_Id__c = '123456';
        inv.Daily_Invoice__c = dailyInv.id;
        database.insert(inv);
        
        List<Invoice_Line_Item__c> invLI = new List<Invoice_Line_Item__c>{
        new Invoice_Line_Item__c(Invoice_ID__c = inv.Zuora__Zuora_Id__c, 
        //UOM__c = 'NO CREDIT',
        UOM__c = 'UOM CREDIT', Applied_To_Invoice_Item_ID__c = null,
        Charge_Amount__c = 1, Subscription__c = subRecs.id,
        Subscription_Number__c = '123', Product_Name__c = 'Admin Charge',
        Tax_Amount__c = 20),new Invoice_Line_Item__c(Invoice_ID__c = inv.Zuora__Zuora_Id__c, 
        //UOM__c = 'NO CREDIT',
        UOM__c = 'UOM CREDIT',
        Charge_Amount__c = 1, Subscription__c = subRecs.id,
        Applied_To_Invoice_Item_ID__c = '12345', Subscription_Number__c = '123', Product_Name__c = 'Admin Charge',
        Tax_Amount__c = 20)
        };
        database.insert(invLI);
        //end test data
    
        test.startTest();
            pageReference pageRef = page.InvoiceTaxTemplate;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', dailyInv.Id);
            
            
            InvoiceDailyController cont = new InvoiceDailyController();
            
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
            
            InvoiceDailyController cont2 = new InvoiceDailyController();
            
            invLI[0].Charge_Amount__c = -1; 
            invLI[1].Charge_Amount__c = -1; 
            database.update(invLI);
            
            billAcc.Billing_Type__c = 'Full Prepaid';
            database.update(billAcc);
            
            InvoiceDailyController cont3 = new InvoiceDailyController();  
            
            invLI[0].Charge_Amount__c = 50; 
            invLI[1].Charge_Amount__c = 50; 
            database.update(invLI);  
            
            subRecs.Subscription_Type__c = 'Gift'; 
            database.update(subRecs);
            
            InvoiceDailyController cont4 = new InvoiceDailyController();   
            
            invLI[0].Applied_To_Invoice_Item_ID__c = null;
            invLI[1].Applied_To_Invoice_Item_ID__c = null;
            invLI[0].Charge_Amount__c = -1; 
            invLI[1].Charge_Amount__c = -1;   
            database.update(invLI);  
            
            subRecs.Subscription_Type__c = 'Postage'; 
            database.update(subRecs);
            
            InvoiceDailyController cont5 = new InvoiceDailyController();    
            
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
            
            InvoiceDailyController cont6 = new InvoiceDailyController();
            cont6.IsRecurring('');
            cont6.isRecipientOverseas = true;
            
        test.stopTest();
    }
}