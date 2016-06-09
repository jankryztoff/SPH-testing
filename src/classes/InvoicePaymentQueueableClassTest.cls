/*
 * Class Name: InvoicePaymentQueueableClass
 * @author: Francis Vincent Bagtas
 * Date: 4/12/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for InvoicePaymentQueueableClass
 */

@isTest(seeAllData = true)	// DO NOT REMOVE sealldata=true. needed for zuora objects
public class InvoicePaymentQueueableClassTest {

   static testMethod void unitTest1(){
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
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
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c FROM Package__c WHERE Id =: pack.id];
        
        System.assertEquals('Base', myPack.Package_Type__c);
        
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
        billAcc.Zuora__Zuora_Id__c = 'test data';
        billAcc.Zuora__External_Id__c = 'test data';
        billAcc.Zuora__Credit_Balance__c = 100000;
        billAcc.Zuora__DefaultPaymentMethod__c = GlobalVariableClass.CHEQUE;
        database.insert(billAcc);
        
        Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
        paymentMethod.Name = ResponseUtility.generateExternalId();
        paymentMethod.Zuora__BillingAccount__c = billAcc.Id;
        paymentMethod.Zuora__External_Id__c = ResponseUtility.generateExternalId();
        database.insert(paymentMethod);
        
        billAcc.Zuora__Default_Payment_Method__c = paymentMethod.Id;
        database.update(billAcc);
        
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
        order.Sub_Category__c ='Start Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 10000;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Amount_Paid__c = 10000;
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        order.Payment_Mode__c = GlobalVariableClass.CHEQUE;
        database.insert(order);

        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);

        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.Order_Line_Item_Number_1__c = orderline.Id;
        database.insert(quote);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
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

        Test.startTest();
        Set<Id> setSub = new Set<Id>();
        setSub.add(subRecord.id);
        ResponseUtility.usedNegativeResponse = true;
        ResponseUtility.zuoraAccountId = billAcc.Zuora__Zuora_Id__c;
        InvoicePaymentQueueableClass controler = new InvoicePaymentQueueableClass(setSub);
        //ResponseUtility.usedNegativeResponse = false;      

        Zuora.zObject zObject = new Zuora.zObject('Invoice');
        zObject.setValue('AccountId', billAcc.Zuora__External_Id__c);
        list<Zuora.zObject> zObjectTrans = new list<Zuora.zObject>();
        zObjectTrans.add(zObject);
        controler.transferCreditBalances(zObjectTrans, new ZuoraCallOut());
        controler.applyCreditBalance(zObjectTrans, new ZuoraCallOut());
        controler.updateInvPrevBalance(zObjectTrans, new ZuoraCallOut());
        controler.processPayment(zObjectTrans, new ZuoraCallOut());
        Test.stopTest();
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
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c FROM Package__c WHERE Id =: pack.id];
        
        System.assertEquals('Base', myPack.Package_Type__c);
        
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
        billAcc.Zuora__Zuora_Id__c = 'test data';
        billAcc.Zuora__External_Id__c = 'test data';
        billAcc.Zuora__Credit_Balance__c = 100000;
        billAcc.Zuora__DefaultPaymentMethod__c =  GlobalVariableClass.CASH;
        database.insert(billAcc);
        
        Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
        paymentMethod.Name = ResponseUtility.generateExternalId();
        paymentMethod.Zuora__BillingAccount__c = billAcc.Id;
        paymentMethod.Zuora__External_Id__c = ResponseUtility.generateExternalId();
        database.insert(paymentMethod);
        
        billAcc.Zuora__Default_Payment_Method__c = paymentMethod.Id;
        database.update(billAcc);
        
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
        order.Sub_Category__c ='Start Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 10000;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Amount_Paid__c = 10000;
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        order.Payment_Mode__c = GlobalVariableClass.CASH;
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        order.Payment_Mode__c = GlobalVariableClass.CASH;
        database.insert(order);

        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);

        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.Order_Line_Item_Number_1__c = orderline.Id;
        database.insert(quote);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
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

        Test.startTest();
        Set<Id> setSub = new Set<Id>();
        setSub.add(subRecord.id);
        ResponseUtility.usedNegativeResponse = true;
        ResponseUtility.zuoraAccountId = billAcc.Zuora__Zuora_Id__c;
        InvoicePaymentQueueableClass controler = new InvoicePaymentQueueableClass(setSub);
        //ResponseUtility.usedNegativeResponse = false;      

        Zuora.zObject zObject = new Zuora.zObject('Invoice');
        zObject.setValue('AccountId', billAcc.Zuora__External_Id__c);
        list<Zuora.zObject> zObjectTrans = new list<Zuora.zObject>();
        zObjectTrans.add(zObject);
        controler.transferCreditBalances(zObjectTrans, new ZuoraCallOut());
        controler.applyCreditBalance(zObjectTrans, new ZuoraCallOut());
        controler.updateInvPrevBalance(zObjectTrans, new ZuoraCallOut());
        controler.processPayment(zObjectTrans, new ZuoraCallOut());
        Test.stopTest();
    }

   static testMethod void unitTest2B(){
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
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
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c FROM Package__c WHERE Id =: pack.id];
        
        System.assertEquals('Base', myPack.Package_Type__c);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAccR = TestDataFactory.createBillingAccount(1)[0];
        billAccR.Zuora__Account__c = acc.Id;
        billAccR.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_PRE;
        billAccR.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        billAccR.Zuora__External_Id__c = billAccR.Zuora__Zuora_Id__c;
        billAccR.Zuora__Credit_Balance__c = 1;
        billAccR.Zuora__DefaultPaymentMethod__c =  GlobalVariableClass.CASH;
        database.insert(billAccR);

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Zuora_Id__c = 'test data';
        billAcc.Zuora__External_Id__c = 'test data';
        billAcc.Zuora__Credit_Balance__c = 5;
        billAcc.Zuora__DefaultPaymentMethod__c =  GlobalVariableClass.CASH;
        database.insert(billAcc);
        
        Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
        paymentMethod.Name = ResponseUtility.generateExternalId();
        paymentMethod.Zuora__BillingAccount__c = billAcc.Id;
        paymentMethod.Zuora__External_Id__c = ResponseUtility.generateExternalId();
        database.insert(paymentMethod);
        
        billAcc.Zuora__Default_Payment_Method__c = paymentMethod.Id;
        database.update(billAcc);
        
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
        order.Sub_Category__c ='Start Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 10000;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Amount_Paid__c = 10000;
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        order.Payment_Mode__c = GlobalVariableClass.CASH;
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        order.Payment_Mode__c = GlobalVariableClass.CASH;
        database.insert(order);

        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);

        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.Order_Line_Item_Number_1__c = orderline.Id;
        database.insert(quote);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
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

        Test.startTest();
        Set<Id> setSub = new Set<Id>();
        setSub.add(subRecord.id);
        ResponseUtility.usedNegativeResponse = true;
        ResponseUtility.zuoraAccountId = billAcc.Zuora__Zuora_Id__c;
        InvoicePaymentQueueableClass controler = new InvoicePaymentQueueableClass(setSub);
        //ResponseUtility.usedNegativeResponse = false;      

        Zuora.zObject zObject = new Zuora.zObject('Invoice');
        zObject.setValue('AccountId', billAcc.Zuora__External_Id__c);
        list<Zuora.zObject> zObjectTrans = new list<Zuora.zObject>();
        zObjectTrans.add(zObject);
        controler.transferCreditBalances(zObjectTrans, new ZuoraCallOut());
        controler.applyCreditBalance(zObjectTrans, new ZuoraCallOut());
        controler.updateInvPrevBalance(zObjectTrans, new ZuoraCallOut());
        controler.processPayment(zObjectTrans, new ZuoraCallOut());
        Test.stopTest();
    }
        
   static testMethod void unitTest3(){
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
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
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c FROM Package__c WHERE Id =: pack.id];
        
        System.assertEquals('Base', myPack.Package_Type__c);
        
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
        billAcc.Zuora__Zuora_Id__c = 'test data';
        billAcc.Zuora__External_Id__c = 'test data';
        billAcc.Zuora__Credit_Balance__c = 100000;
        billAcc.Zuora__DefaultPaymentMethod__c = GlobalVariableClass.OTHER;
        billAcc.Other_PaymentMethod__c = 'eNets';
        database.insert(billAcc);
        
        Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
        paymentMethod.Name = ResponseUtility.generateExternalId();
        paymentMethod.Zuora__BillingAccount__c = billAcc.Id;
        paymentMethod.Zuora__External_Id__c = ResponseUtility.generateExternalId();
        database.insert(paymentMethod);
        
        billAcc.Zuora__Default_Payment_Method__c = paymentMethod.Id;
        database.update(billAcc);
        
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
        order.Sub_Category__c ='Start Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 10000;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Amount_Paid__c = 10000;
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        order.Payment_Mode__c = GlobalVariableClass.OTHER;
       
        database.insert(order);

        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);

        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.Order_Line_Item_Number_1__c = orderline.Id;
        database.insert(quote);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
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

        Test.startTest();
        Set<Id> setSub = new Set<Id>();
        setSub.add(subRecord.id);
        ResponseUtility.usedNegativeResponse = true;
        ResponseUtility.zuoraAccountId = billAcc.Zuora__Zuora_Id__c;
        InvoicePaymentQueueableClass controler = new InvoicePaymentQueueableClass(setSub);
        //ResponseUtility.usedNegativeResponse = false;      

        Zuora.zObject zObject = new Zuora.zObject('Invoice');
        zObject.setValue('AccountId', billAcc.Zuora__External_Id__c);
        list<Zuora.zObject> zObjectTrans = new list<Zuora.zObject>();
        zObjectTrans.add(zObject);
        controler.transferCreditBalances(zObjectTrans, new ZuoraCallOut());
        controler.applyCreditBalance(zObjectTrans, new ZuoraCallOut());
        controler.updateInvPrevBalance(zObjectTrans, new ZuoraCallOut());
        controler.processPayment(zObjectTrans, new ZuoraCallOut());
        Test.stopTest();
    }
    
   static testMethod void unitTest4(){
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
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
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c FROM Package__c WHERE Id =: pack.id];
        
        System.assertEquals('Base', myPack.Package_Type__c);
        
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
        billAcc.Zuora__Zuora_Id__c = 'test data';
        billAcc.Zuora__External_Id__c = 'test data';
        billAcc.Zuora__Credit_Balance__c = 100000;
        billAcc.Zuora__DefaultPaymentMethod__c = GlobalVariableClass.CREDITCARD;
        database.insert(billAcc);
        
        Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
        paymentMethod.Name = ResponseUtility.generateExternalId();
        paymentMethod.Zuora__BillingAccount__c = billAcc.Id;
        paymentMethod.Zuora__External_Id__c = ResponseUtility.generateExternalId();
        database.insert(paymentMethod);
        
        billAcc.Zuora__Default_Payment_Method__c = paymentMethod.Id;
        database.update(billAcc);
        
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
        order.Sub_Category__c ='Start Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 10000;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Amount_Paid__c = 10000;
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        order.Payment_Mode__c = GlobalVariableClass.CREDITCARD;
        database.insert(order);

        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
        database.insert(orderline);

        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.Order_Line_Item_Number_1__c = orderline.Id;
        database.insert(quote);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
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

        Test.startTest();
        Set<Id> setSub = new Set<Id>();
        setSub.add(subRecord.id);
        ResponseUtility.usedNegativeResponse = true;
        ResponseUtility.zuoraAccountId = billAcc.Zuora__Zuora_Id__c;
        InvoicePaymentQueueableClass controler = new InvoicePaymentQueueableClass(setSub);
        //ResponseUtility.usedNegativeResponse = false;      

        Zuora.zObject zObject = new Zuora.zObject('Invoice');
        zObject.setValue('AccountId', billAcc.Zuora__External_Id__c);
        list<Zuora.zObject> zObjectTrans = new list<Zuora.zObject>();
        zObjectTrans.add(zObject);
        controler.transferCreditBalances(zObjectTrans, new ZuoraCallOut());
        controler.applyCreditBalance(zObjectTrans, new ZuoraCallOut());
        controler.updateInvPrevBalance(zObjectTrans, new ZuoraCallOut());
        controler.processPayment(zObjectTrans, new ZuoraCallOut());
        Test.stopTest();
    }         
}