@isTest(SeeAllData=true)	// do not remove seealldata. it is needed for zuora object
private class InvoicePostProcessingForDirectCorpTest {

    static void setUpData() {
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        String rtId = AccountRecordTypeInfo.get('Direct Corporate').getRecordTypeId(); 

        /*Key_Id__c keyId = new Key_Id__c();
        keyId.Name = 'Account_Direct Corporate';
        keyId.Type__c = 'RecordType';
        keyId.Id__c = rtId;
        insert keyId;*/
        

        Account acc = new Account();
        acc.Name = 'Test Account Name';
        acc.RecordTypeId = rtId;
        acc.Email__c = 'test@email.com';
        insert acc;
    
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);          
        
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Name = 'Test Billing Account';
        billingAccount.Zuora__Account__c = acc.Id;
        billingAccount.Billing_Type__c = 'Full Prepaid';
        billingAccount.Billing_Contact__c = con1.Id;
        insert billingAccount;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        //order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billingAccount.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        database.insert(order);


    }
    
    static testMethod void setUpDataforNegative() {
         
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Promotion__c promo = new Promotion__c();
        promo.Name = 'promotor';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        database.insert(promo);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c
                            FROM Package__c
                            WHERE Id =: pack.id];
        
        System.assertEquals('Add On', myPack.Package_Type__c);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 10000;
        billAcc.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_PROVISIONED;
        order.Order_Type__c = ConstantsSLB.getOther('Order_Type COS_Quantity');
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        database.insert(order);

        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        //orderline.Case__c = cas.id;
        //orderline.Vendor_Mailing_Agent__c = venAccount.Id;
        //orderline.Vendor_Subscription_ID__c = subsVen.Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);

        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.Order_Line_Item_Number_1__c = orderline.Id;
        database.insert(quote);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = 'test data';
        //subRecord.Order__c = order.id;
        subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');//ConstantsSLB.getkeyid(GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION);
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__CustomerAccount__c = billAcc.Id; 
        database.insert(subRecord);
        
        order.Subscription__c = subRecord.Id;
        database.update(order);
        
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        inv.Zuora__BillingAccount__c = billAcc.Id;
        inv.Zuora__Account__c = acc.ID;
        insert inv;
        
        map<string, id> baZuoraId_accountId = new map<string, id>();
        baZuoraId_accountId.put(billAcc.Zuora__Zuora_Id__c, acc.Id);
        
        Test.startTest();
            Set<String> setSub = new Set<String>();
            setSub.add(inv.ID);
            invoicePostProcessingForDirectCorp controler = new invoicePostProcessingForDirectCorp(setSub);         
			invoicePostProcessingForDirectCorp.mapBAZuoraIdToAccountId = baZuoraId_accountId;
			
            Zuora.zObject zObject = new Zuora.zObject('Invoice');
            zObject.setValue('AccountId', billAcc.Zuora__Zuora_Id__c);
			zObject.setValue('Amount', -1);
			zObject.setValue('Balance', 10);
            list<Zuora.zObject> zObjectTrans = new list<Zuora.zObject>();
            zObjectTrans.add(zObject);
            invoicePostProcessingForDirectCorp.transferCreditBalances(zObjectTrans, new ZuoraCallOut());
            invoicePostProcessingForDirectCorp.applyCreditBalance(zObjectTrans, new ZuoraCallOut());
            invoicePostProcessingForDirectCorp.updateInvPrevBalanceForCorp(zObjectTrans, new ZuoraCallOut());
            invoicePostProcessingForDirectCorp.processPayment(zObjectTrans, new ZuoraCallOut());
			invoicePostProcessingForDirectCorp.convertNegativeInvoiceToCB(zObjectTrans, new ZuoraCallOut());
            
            List<Map<String, Object>> negativeInvoiceMapList = new List<Map<String, Object>>();
            negativeInvoiceMapList.add(new Map<String, Object>{inv.Zuora__Zuora_Id__c=>inv});
            invoicePostProcessingForDirectCorp.updateInvoiceImmediateCB(negativeInvoiceMapList);
            
            Set<Id> setSFAccountIDs = new Set<Id>(); 
            setSFAccountIDs.add(acc.id);
            system.debug('>>>>>>> :: '+ [SELECT Zuora__AccountNumber__c, Zuora__External_Id__c, Zuora__Credit_Balance__c, Zuora__Account__c, Other_PaymentMethod__c,
                       Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c, 
                       Zuora__Balance__c, Payment_Mode__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN: setSFAccountIDs]);

        Test.stopTest();

        
    }
    
    
    static testMethod  void insertInvoice() {
        setUpData();
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        Set<String> invoiceSet = new Set<String>();

        Zuora__CustomerAccount__c newBillingAcc = [Select Name from Zuora__CustomerAccount__c where Name=: 'Test Billing Account'];
        
        for(integer i=0; i<=100; i++){
            Zuora__ZInvoice__c invoiceRec = new Zuora__ZInvoice__c(); 
            invoiceRec.Name = 'Test Invoice';
            invoiceRec.Zuora__Zuora_Id__c = '1234567890';
            invoiceRec.Zuora__BillingAccount__c = newBillingAcc.Id; 
            invoiceList.add(invoiceRec);
        }

        test.startTest();
        //Test.setMock(WebServiceMock.class, new zLoginMock());
    
        //Zuora.zApi zApiInstance = new Zuora.zApi();
        insert invoiceList;
        test.stopTest();
    }
    
    static testMethod void unitTest2(){
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Promotion__c promo = new Promotion__c();
        promo.Name = 'promotor';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        database.insert(promo);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c
                            FROM Package__c
                            WHERE Id =: pack.id];
        
        System.assertEquals('Add On', myPack.Package_Type__c);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 10000;
        billAcc.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        //order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        database.insert(order);

        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        //orderline.Case__c = cas.id;
        //orderline.Vendor_Mailing_Agent__c = venAccount.Id;
        //orderline.Vendor_Subscription_ID__c = subsVen.Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);

        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.Order_Line_Item_Number_1__c = orderline.Id;
        database.insert(quote);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = '11111';
        //subRecord.Order__c = order.id;
        subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');//ConstantsSLB.getkeyid(GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION);
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__CustomerAccount__c = billAcc.Id;
        subRecord.Zuora__Zuora_Id__c = 'test data';
        database.insert(subRecord);
        
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Zuora__Zuora_Id__c = '11111';
        inv.Zuora__BillingAccount__c = billAcc.Id;
        inv.Zuora__Account__c = acc.ID;
        insert inv;
        
        map<string, id> baZuoraId_accountId = new map<string, id>();
        baZuoraId_accountId.put(billAcc.Zuora__Zuora_Id__c, acc.Id);
        
        Test.startTest();
            Set<String> setSub = new Set<String>();
            setSub.add(inv.ID);
            invoicePostProcessingForDirectCorp controler = new invoicePostProcessingForDirectCorp(setSub);         
			invoicePostProcessingForDirectCorp.mapBAZuoraIdToAccountId = baZuoraId_accountId;
			
            Zuora.zObject zObject = new Zuora.zObject('Invoice');
            zObject.setValue('AccountId', billAcc.Zuora__Zuora_Id__c);
            zObject.setValue('AccountId', billAcc.Zuora__Zuora_Id__c);
			zObject.setValue('Amount', -1);
			zObject.setValue('Balance', 10);
            list<Zuora.zObject> zObjectTrans = new list<Zuora.zObject>();
            zObjectTrans.add(zObject);
            invoicePostProcessingForDirectCorp.transferCreditBalances(zObjectTrans, new ZuoraCallOut());
            invoicePostProcessingForDirectCorp.applyCreditBalance(zObjectTrans, new ZuoraCallOut());
            invoicePostProcessingForDirectCorp.updateInvPrevBalanceForCorp(zObjectTrans, new ZuoraCallOut());
            invoicePostProcessingForDirectCorp.processPayment(zObjectTrans, new ZuoraCallOut());
            
            List<Map<String, Object>> negativeInvoiceMapList = new List<Map<String, Object>>();
            negativeInvoiceMapList.add(new Map<String, Object>{inv.Zuora__Zuora_Id__c=>inv});
            invoicePostProcessingForDirectCorp.updateInvoiceImmediateCB(negativeInvoiceMapList);
            
            Set<Id> setSFAccountIDs = new Set<Id>(); 
            setSFAccountIDs.add(acc.id);
            system.debug('>>>>>>> :: '+ [SELECT Zuora__AccountNumber__c, Zuora__External_Id__c, Zuora__Credit_Balance__c, Zuora__Account__c, Other_PaymentMethod__c,
                       Zuora__DefaultPaymentMethod__c, Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c, 
                       Zuora__Balance__c, Payment_Mode__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN: setSFAccountIDs]);

        Test.stopTest();
    }
    
    
}