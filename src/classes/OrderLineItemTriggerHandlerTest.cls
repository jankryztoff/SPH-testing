/**
* Class Name: <OrderLineItemTriggerHandlerTest>
* @author: <Patrick Pancho>
* Date: <02/09/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for OrderLineItemTriggerHandler>
*/
@isTest(SeeAllData=true)
private class OrderLineItemTriggerHandlerTest {

    private static Account pAcc = null;
    //private static Account acc = null;
    private static Singpost_Address__c postal = null;
    private static Address__c addressRec = null;
    //private static Contact con = null;
    //private static Zuora__CustomerAccount__c billAcc = null;
    //private static Package__c pack = null;
    private static zqu__ZProduct__c zProduct = null;
    private static zqu__ProductRatePlan__c prdRatePlan = null;
    private static zqu__ProductRatePlanCharge__c prpc = null;
    private static Package_Item__c pItem = null;
    private static Promotion__c promoTmp = null;
    private static List<Order__c> orderList = null;
    //private static List<Case> caseList = null;
    //private static Subscription_Vendor__c subVendor = null;
    private static Subscription_Vendor_Publication__c svp = null;
    private static Publication__c newPublication = null;
    
    static testmethod void testInsert(){
        Test.startTest();
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        System.assertNotEquals(null, acc.id);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Order_Type__c = ConstantsSLB.getOther('Order_Type Start');
        order.Order_Type1__c = ConstantsSLB.getOther('Order_Type Start');
        insert order;
        System.assertNotEquals(null, order.id);
        
        Package__c pck= TestDataFactory.createPackage(1)[0];
        insert pck;
        System.assertNotEquals(null, pck.id);
        
        Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subVendor;
        System.assertNotEquals(null, subVendor.id);
        
        Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem.Order__c = order.id;
        ordLineItem.Main_Package_ID__c = pck.id;
        ordLineItem.Start_Date__c = Date.today()+2;
        ordLineItem.Vendor_Conversion__c = true;
        ordLineItem.Vendor_Subscription_ID__c = subVendor.id;
        insert ordLineItem;
        System.assertNotEquals(null, ordLineItem.id);
        
        Test.stopTest();
    }
    
    static testmethod void testUpdate(){
        
        
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert acc;
        System.assertNotEquals(null, acc.id);
        
        Account accVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert accVendor;
        System.assertNotEquals(null, accVendor.id);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Order_Type__c = ConstantsSLB.getOther('Order_Type COS_Quantity');
        order.Order_Type1__c = ConstantsSLB.getOther('Order_Type COS_Quantity');
        insert order;
        System.assertNotEquals(null, order.id);
        
        
        //Insert Case
        Case caseList = TestDataFactory.createCase(1, 'Complaint - Digital')[0];
        //caseList.Order__c = order.Id;
        Test.startTest();
        insert caseList;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        Package__c pck= TestDataFactory.createPackage(1)[0];
        insert pck;
        System.assertNotEquals(null, pck.id);
        
        Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subVendor;
        System.assertNotEquals(null, subVendor.id);
        
        Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem.Order__c = order.id;
        ordLineItem.Main_Package_ID__c = pck.id;
        ordLineItem.Start_Date__c = Date.today().addDays(1);
        ordLineItem.Vendor_Mailing_Agent__c = acc.id;
        ordLineItem.Vendor_Conversion__c = true;
        ordLineItem.Vendor_Subscription_ID__c = subVendor.id;
        ordLineItem.Case__c = caseList.id;
        ordLineItem.Based_Order_Line_Item__c = ordLineItem.id;//
        //ordLineItem.Reason_Code__c = 'test';//
        insert ordLineItem;
        System.assertNotEquals(null, ordLineItem.id);
        
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
                zuoSubList[0].Zuora__Account__c = acc.id;
                zuoSubList[0].Name= 'CS0000000110';
                zuoSubList[0].Number_of_Copies__c= 10;
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Next_Earliest_Start_Date__c= date.today();
                zuoSubList[0].Unique_Address_Id__c= 'asdasdasd';
                zuoSubList[0].Year_to_Date_Temp_Stop_Days__c= 2;
                zuoSubList[0].Previous_Year_Temp_Stop_Days__c= 2;
                zuoSubList[0].Legacy_Create_Date__c='2014-08-07';
                zuoSubList[0].Legacy_Create_By__c='test';
                zuoSubList[0].Legacy_Update_Date__c='test';
                zuoSubList[0].Legacy_Update_By__c='test';
                zuoSubList[0].Legacy_Subscription_ID__c='test';
                zuoSubList[0].Cheque_details__c='test';
                zuoSubList[0].DTL__c='test';
                zuoSubList[0].Paypal_Payment_Profile_Id__c='test';
                zuoSubList[0].Pub_Tag__c='test';
                zuoSubList[0].Subscribe_As__c='test';
                zuoSubList[0].Zuora__SubscriptionEndDate__c= null;
                zuoSubList[0].Subscription_Grace_Period_End_Date__c= 'test';
                zuoSubList[0].Gift_ID__c= 'test';
                zuoSubList[0].Redeem_Date__c= 'test';
                zuoSubList[0].Gift_ID_2__c= 'test';
                zuoSubList[0].Redeem_Date_2__c= 'test';
                zuoSubList[0].Subscriber_Contact__c= con.Id;
                zuoSubList[0].Recipient_Contact__c= con.Id;
                zuoSubList[0].Subscription_Charge__c= 223.0;
                zuoSubList[0].Term_Length__c= 2;
                zuoSubList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                zuoSubList[0].Main_Package__c = pck.Id;
                zuoSubList[0].Main_Package_1__c = pck.Id;
                zuoSubList[0].Billing_Type__c = 'Recurring Prepaid';
                zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
                zuoSubList[0].Order_Number_1__c = order.id;
                zuoSubList[0].Order_Number__c = order.id;
                zuoSubList[0].Zuora__Status__c = 'Active';
                zuoSubList[0].Order_Line_Item_Number_1__c = ordLineItem.id;
                zuoSubList[0].Order_Line_Item_Number__c = ordLineItem.id;
                insert zuoSubList;
        
        ordLineItem.Start_Date__c = Date.today().addDays(1);
        ordLineItem.Vendor_Mailing_Agent__c = accVendor.id;
        update ordLineItem;
        
        Test.stopTest();
    }
    
    static testmethod void testDelete(){
        Test.startTest();
        
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert acc;
        System.assertNotEquals(null, acc.id);
        
        Account accVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert accVendor;
        System.assertNotEquals(null, accVendor.id);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Order_Type__c = ConstantsSLB.getOther('Order_Type COS_Package');
        order.Order_Type1__c = ConstantsSLB.getOther('Order_Type COS_Package');
        insert order;
        System.assertNotEquals(null, order.id);
        
        Package__c pck= TestDataFactory.createPackage(1)[0];
        insert pck;
        System.assertNotEquals(null, pck.id);
        
        Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subVendor;
        System.assertNotEquals(null, subVendor.id);
        
        Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem.Order__c = order.id;
        ordLineItem.Main_Package_ID__c = pck.id;
        ordLineItem.Start_Date__c = Date.today().addDays(1);
        ordLineItem.Vendor_Mailing_Agent__c = acc.id;
        ordLineItem.Vendor_Conversion__c = true;
        ordLineItem.Vendor_Subscription_ID__c = subVendor.id;
        ordLineItem.Reason_Code__c = 'test';
        insert ordLineItem;
        
        Order_Line_Item__c ordLineItem1 = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem1.Order__c = order.id;
        ordLineItem1.Main_Package_ID__c = pck.id;
        ordLineItem1.Start_Date__c = Date.today().addDays(1);
        ordLineItem1.Vendor_Mailing_Agent__c = acc.id;
        ordLineItem1.Vendor_Conversion__c = true;
        ordLineItem1.Vendor_Subscription_ID__c = subVendor.id;
        ordLineItem1.Based_Order_Line_Item__c = ordLineItem.id;
        ordLineItem1.Reason_Code__c = 'test';
        insert ordLineItem1;
        System.assertNotEquals(null, ordLineItem.id);
        
        delete ordLineItem;
        
        Test.stopTest();
    }
    static testmethod void toCoverlinesApril(){
        Test.startTest();
        
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert acc;
        System.assertNotEquals(null, acc.id);
        
        Account accVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert accVendor;
        System.assertNotEquals(null, accVendor.id);
        
        Singpost_Address__c postal1 = TestDataFactory.createSingpostAddress(1)[0];
        postal1.Building_Name__c = 'Ebloc2';
        insert postal1;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal1.id;
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
                    
        List<Order__c> order = TestDataFactory.createOrder(2);
        order[0].Account__c = acc.id;
        order[0].Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
        order[0].Order_Type1__c = ConstantsSLB.getOther('Order_Type Renewal');
        order[0].Urgent_Stop__c = true;
        order[0].isWaive__c = true;
        order[0].Base_Subscription__c = zSub.id;
        
        order[1].Account__c = acc.id;
        order[1].Order_Type__c = ConstantsSLB.getOther('Order_Type Start');
        order[1].Order_Type1__c = ConstantsSLB.getOther('Order_Type Start');
        order[1].Urgent_Stop__c = true;
        order[1].isWaive__c = true;
        order[1].Base_Subscription__c = zSub.id;
        insert order;
        //System.assertNotEquals(null, order.id);
                
        Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subVendor;
        System.assertNotEquals(null, subVendor.id);
        
        List<Order_Line_Item__c> ordLineItem = TestDataFactory.createOrderLineItem(2);
        ordLineItem[0].Order__c = order[0].id;
        ordLineItem[0].Main_Package_ID__c = pack.id;
        //ordLineItem.Start_Date__c = Date.today().addDays(1);
        ordLineItem[0].Vendor_Mailing_Agent__c = acc.id;
        ordLineItem[0].Vendor_Conversion__c = true;
        ordLineItem[0].Vendor_Subscription_ID__c = subVendor.id;
        ordLineItem[0].Reason_Code__c = 'test';
        ordLineItem[0].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
        
        ordLineItem[1].Order__c = order[1].id;
        ordLineItem[1].Main_Package_ID__c = pack.id;
        //ordLineItem.Start_Date__c = Date.today().addDays(1);
        ordLineItem[1].Vendor_Mailing_Agent__c = acc.id;
        ordLineItem[1].Vendor_Conversion__c = true;
        ordLineItem[1].Vendor_Subscription_ID__c = subVendor.id;
        ordLineItem[1].Reason_Code__c = 'test';
        ordLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
        insert ordLineItem;
        
        Order_Line_Item__c ordLineItem1 = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem1.Order__c = order[1].id;
        ordLineItem1.Main_Package_ID__c = pack.id;
        ordLineItem1.Start_Date__c = Date.today().addDays(1);
        ordLineItem1.Vendor_Mailing_Agent__c = acc.id;
        ordLineItem1.Vendor_Conversion__c = false;
        ordLineItem1.Vendor_Subscription_ID__c = null;//subVendor.id;
        ordLineItem1.Based_Order_Line_Item__c = ordLineItem[1].id;
        ordLineItem1.Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
        ordLineItem1.Reason_Code__c = 'test';
        insert ordLineItem1;
        //System.assertNotEquals(null, ordLineItem.id);
        
        delete ordLineItem;
        
        Test.stopTest();
    }

   static testmethod void toCoverlinesApril2(){
        Test.startTest();
        
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert acc;
        System.assertNotEquals(null, acc.id);
        
        Account accVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert accVendor;
        System.assertNotEquals(null, accVendor.id);
        
        Singpost_Address__c postal1 = TestDataFactory.createSingpostAddress(1)[0];
        postal1.Building_Name__c = 'Ebloc2';
        insert postal1;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal1.id;
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
        
        List<Order__c> order = TestDataFactory.createOrder(2);
        order[0].Account__c = acc.id;
        order[0].Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
        order[0].Order_Type1__c = ConstantsSLB.getOther('Order_Type Renewal');
        order[0].Urgent_Stop__c = true;
        order[0].isWaive__c = true;
        //order[0].Base_Subscription__c = zSub.id;
        
        order[1].Account__c = acc.id;
        order[1].Order_Type__c = ConstantsSLB.getOther('Order_Type Start');
        order[1].Order_Type1__c = ConstantsSLB.getOther('Order_Type Start');
        order[1].Urgent_Stop__c = true;
        order[1].isWaive__c = true;
        //order[1].Base_Subscription__c = zSub.id;
        insert order;
        //System.assertNotEquals(null, order.id);
                
        Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subVendor;
        System.assertNotEquals(null, subVendor.id);
        
        List<Order_Line_Item__c> ordLineItem = TestDataFactory.createOrderLineItem(2);
        ordLineItem[0].Order__c = order[0].id;
        ordLineItem[0].Main_Package_ID__c = pack.id;
        //ordLineItem.Start_Date__c = Date.today().addDays(1);
        ordLineItem[0].Vendor_Mailing_Agent__c = acc.id;
        ordLineItem[0].Vendor_Conversion__c = true;
        //ordLineItem[0].Vendor_Subscription_ID__c = subVendor.id;
        ordLineItem[0].Reason_Code__c = 'test';
        
        ordLineItem[0].Vendor_Subscription_ID__c = subVendor.id;
        ordLineItem[1].Vendor_Subscription_ID__c = subVendor.id;      
        
        ordLineItem[1].Order__c = order[1].id;
        ordLineItem[1].Main_Package_ID__c = pack.id;
        //ordLineItem.Start_Date__c = Date.today().addDays(1);
        ordLineItem[1].Vendor_Mailing_Agent__c = acc.id;
        ordLineItem[1].Vendor_Conversion__c = true;
        //ordLineItem[1].Vendor_Subscription_ID__c = subVendor.id;
        ordLineItem[1].Reason_Code__c = 'test';
        //ordLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
        insert ordLineItem;
       
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Name = 'NUM124';
        zSub.Billing_Type__c = 'Full Prepaid';
        zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
        zSub.Subscription_Type_1__c = 'Publication';
        zSub.Subscription_Type__c = 'Publication';
        zSub.Zuora__Account__c = acc.id;
        zSub.Zuora__Status__c = 'Cancelled';
        zSub.Order_Line_Item_Number__c = ordLineItem[0].id;
        zSub.Order_Line_Item_Number_1__c = ordLineItem[0].id;
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
                    
        order[0].Base_Subscription__c = zSub.id;
        order[1].Base_Subscription__c = zSub.id;
        update order;
        
        ordLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
        ordLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
        update ordLineItem;
        
        
        
        
        Order_Line_Item__c ordLineItem1 = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem1.Order__c = order[1].id;
        ordLineItem1.Main_Package_ID__c = pack.id;
        ordLineItem1.Start_Date__c = Date.today().addDays(1);
        ordLineItem1.Vendor_Mailing_Agent__c = acc.id;
        ordLineItem1.Vendor_Conversion__c = false;
        ordLineItem1.Vendor_Subscription_ID__c = null;//subVendor.id;
        ordLineItem1.Based_Order_Line_Item__c = ordLineItem[1].id;
        ordLineItem1.Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
        ordLineItem1.Reason_Code__c = 'test';
        insert ordLineItem1;
        //System.assertNotEquals(null, ordLineItem.id);
        
        delete ordLineItem;
        
        Test.stopTest();
    }
    
    /* static void createTestData() {
        //Create Parent Account
        pAcc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        pAcc.Name = 'TEST PARENT';
        pAcc.AccountNumber = '1234567890';
        pAcc.NRIC__c = 'T1234567R';
        insert pAcc;
        
        //Create Account
        acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        acc.ParentId = pAcc.Id;
        insert acc;
        
        //Create Singpost Address
        postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        //Create Contact
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        //Create Billing Account
        billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Name = 'TEST';     
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Create Package
        pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        //pack.Package_Code__c = 'SAMPLE';
        pack.Subscription_Type__c = 'Termed';
        pack.Package_Sub_Type__c = 'Single';
        pack.Subscription_Period__c = '2';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create Publication
        newPublication = TestDataFactory.createPublication(1)[0];
        //newPublication.Earliest_Start_Date__c = Date.Today();
        newPublication.Publication_Code__c = '2';
        newPublication.Published_Days__c = 'YYYYYYN';
        newPublication.Publication_Type__c = 'N';
        newPublication.Direct_Sub_Delivery_Method__c = 'Vendor';
        newPublication.Vendor_Sub_Delivery_Method__c = 'Vendor';
        newPublication.Product_Category__c = 'Magazine';
        insert newPublication;
        
        //Create zProduct
        zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        //Create Product Rate Plan
        prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        
        //Create Product Rate Plan Charge
        prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        //Create Package Item
        pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        insert pItem;
        
        //Insert Promo
        promoTmp = TestDataFactory.createPromotion(1)[0]; 
        promoTmp.Name = 'Promotions';
        promoTmp.Contract_Period__c ='12';
        promoTmp.Penalty_Charge__c = '100';     
        insert promoTmp;
        
        //Create Order
        orderList = new List<Order__c>();
        for(Order__c orderRec_0 : TestDataFactory.createOrder(4)) {
            orderRec_0.Account__c = acc.Id;
            orderRec_0.Informed_Customer__c = TRUE;
            orderRec_0.Sub_Category__c ='Stop Subscription';
            orderRec_0.Recipient_Contact__c = con.Id;
            //orderRec_0.Order_Type__c = 'Start';
            orderRec_0.Status__c = 'Draft';
            orderRec_0.Credit_Balance__c = 0;
            orderRec_0.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
            orderRec_0.Delivery_Charge__c = 0;
            orderRec_0.Billing_Contact__c = null;
            orderRec_0.Delivery_Charge_Type__c = 'S' ;
            orderRec_0.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            orderRec_0.Check_Amount__c = 100;
            orderRec_0.Check_Issuing_Bank__c = 'BLANK';
            orderRec_0.Check_No__c = 'SPACE';
            orderRec_0.Check_Dated__c =  date.today();
            orderRec_0.Remarks_Check__c =  'TESTTESTTEST';
            orderRec_0.Zone_Charge__c = 0;
            orderRec_0.Subscriber_Charge__c = 0;
            orderRec_0.Vendor_Credit__c = 0;
            orderRec_0.Billing_Account__c = billAcc.id;
            orderRec_0.Other_Payment_Mode__c = 'Invoice';
            orderRec_0.Billing_Type__c = 'Full Prepaid';
            
            orderList.add(orderRec_0);
        }
        //orderList[0].Order_Type__c = ConstantsSLB.getOther('Order_Type Start');
        //orderList[1].Order_Type__c = ConstantsSLB.getOther('Order_Type COS_Quantity');
        //orderList[2].Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
        //orderList[3].Order_Type__c = ConstantsSLB.getOther('Order_Type Stop');
        //insert orderList;
        
        //Insert Case
        caseList = TestDataFactory.createCase(4, 'Complaint - Magazine');
        //caseList[0].Order__c = orderList[0].Id;
        //caseList[1].Order__c = orderList[1].Id;
        //caseList[2].Order__c = orderList[2].Id;
        //caseList[3].Order__c = orderList[3].Id;
        //insert caseList;
        
        //Insert Vendor Subscription
        subVendor = new Subscription_Vendor__c();
        subVendor.Account__c = pAcc.id;
        subVendor.Status__c = 'Active';
        insert subVendor;
        
        //Insert Subscription Vendor Publication
        svp = new Subscription_Vendor_Publication__c();
        svp.Subscription_Vendor__c = subVendor.Id;
        svp.Publication__c = newPublication.Id;
        insert svp;
        
        //Create Order Line Items
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c orderline : TestDataFactory.createOrderLineItem(2)) {
            orderline.End_Date__c = date.today() +30;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;  
            orderline.Asia1_Creation_Mode__c = 'Individual';
            orderline.Start_Date__c = date.today();
            orderline.Term_is_discussed__c = false;
            orderline.Is_Digital__c = TRUE;
            orderline.Promotion_ID__c = promoTmp.id;
            orderline.Penalty_Charge__c = 100;
            orderline.New_Contract_Period__c = 1;
            orderline.Main_Package_Subscription_Rate__c = 100;
            orderline.Qty__c = 1;
            orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline.Main_Package_Frequency__c = 'Default';
            orderline.Main_Package_Sub_Type__c = 'Single';
            orderline.Main_Package_Type__c = 'Base';
            orderline.Subscribed_as__c = 'New Buy';
            //orderLine.Case__c = caseList[3].Id;
            orderLine.Order__c = orderList[3].Id;
            orderLine.Vendor_Mailing_Agent__c = acc.Id;
            
            oliList.add(orderline);
        }
        
        //Create Subscription
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
        subRec.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderList[0].Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Legacy_Create_Date__c = 'date';
        subRec.Legacy_Create_By__c = 'a'; 
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subRec.Legacy_Update_Date__c = 'a';
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subrec.Order_Line_Item_Number__c = oliList[0].id;
        subrec.Order_Line_Item_Number_1__c = oliList[0].id;
        subrec.Zuora__CustomerAccount__c = billAcc.id;
        insert subrec;
    } */
    
/*    static testMethod void TestOrderLineItemTriggerHandler() {
        
        createTestData();
        
        //Create Order Line Items
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c orderline : TestDataFactory.createOrderLineItem(8)) {
            //orderline.Order__c = orderRec_0.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;  
            orderline.Asia1_Creation_Mode__c = 'Individual';
            orderline.Start_Date__c = date.today();
            orderline.Term_is_discussed__c = false;
            orderline.Is_Digital__c = TRUE;
            orderline.Promotion_ID__c = promoTmp.id;
            orderline.Penalty_Charge__c = 100;
            orderline.New_Contract_Period__c = 1;
            orderline.Main_Package_Subscription_Rate__c = 100;
            orderline.Qty__c = 1;
            orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline.Main_Package_Frequency__c = 'Default';
            orderline.Main_Package_Sub_Type__c = 'Single';
            orderline.Main_Package_Type__c = 'Base';
            orderline.Subscribed_as__c = 'New Buy';
            //orderLine.Case__c = cas.Id;
            
            oliList.add(orderline);
        }
        
        oliList[0].Order__c = orderList[0].Id;
        oliList[0].Case__c = caseList[0].Id;
        
        oliList[1].Order__c = orderList[0].Id;
        oliList[1].Case__c = caseList[0].Id;
        
        oliList[2].Order__c = orderList[1].Id;
        oliList[2].Case__c = caseList[1].Id;
        
        oliList[3].Order__c = orderList[1].Id;
        oliList[3].Case__c = caseList[1].Id;
        
        oliList[4].Order__c = orderList[2].Id;
        oliList[4].Case__c = caseList[2].Id;
        
        oliList[5].Order__c = orderList[2].Id;
        oliList[5].Case__c = caseList[2].Id;
        
        oliList[6].Order__c = orderList[3].Id;
        oliList[6].Case__c = caseList[3].Id;
        
        oliList[7].Order__c = orderList[3].Id;
        oliList[7].Case__c = caseList[3].Id;
        
        
        Test.startTest();
        insert oliList;
        
        //Create Subscription
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionStartDate__c = date.newInstance(2014, 11, 2);
        subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderList[0].Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Legacy_Create_Date__c = 'date';
        subRec.Legacy_Create_By__c = 'a'; 
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subRec.Legacy_Update_Date__c = 'a';
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subrec.Order_Line_Item_Number__c = oliList[0].id;
        subrec.Order_Line_Item_Number_1__c = oliList[0].id;
            

        insert subrec;
        
        
        //Update
        oliList[1].Based_Order_Line_Item__c = oliList[0].Id;
        oliList[1].Vendor_Conversion__c = true;
        oliList[1].Vendor_Subscription_ID__c = subVendor.Id;
        
        oliList[2].Based_Order_Line_Item__c = oliList[0].Id;
        update oliList;
        
        //Delete
        delete oliList[2];
        
        
        //Test Classify
        //OrderLineItemTriggerHandler handler = new OrderLineItemTriggerHandler();
        //orderRec_0.Order_Type__c = ConstantsSLB.getOther('Order_Type COS_Quantity');
        //update orderRec_0;
        
        //handler.classify(oliList[0]);
        Test.stopTest();
    }
*/    
   /* static testMethod void Test_StartOrderType() {
        //Create Test Data
        createTestData();
        
        //Create Order
        orderList[0].Order_Type__c = ConstantsSLB.getOther('Order_Type Start');
        insert orderList[0];
        
        //Create Case
        caseList[0].Order__c = orderList[0].Id;
        insert caseList[0];
        
        //Create Order Line Items
        //Create Order Line Items
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c orderline : TestDataFactory.createOrderLineItem(2)) {
            //orderline.Order__c = orderRec_0.Id;
            orderline.End_Date__c = date.today() +30;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;  
            orderline.Asia1_Creation_Mode__c = 'Individual';
            orderline.Start_Date__c = date.today();
            orderline.Term_is_discussed__c = false;
            orderline.Is_Digital__c = TRUE;
            orderline.Promotion_ID__c = promoTmp.id;
            orderline.Penalty_Charge__c = 100;
            orderline.New_Contract_Period__c = 1;
            orderline.Main_Package_Subscription_Rate__c = 100;
            orderline.Qty__c = 1;
            orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline.Main_Package_Frequency__c = 'Default';
            orderline.Main_Package_Sub_Type__c = 'Single';
            orderline.Main_Package_Type__c = 'Base';
            orderline.Subscribed_as__c = 'New Buy';
            orderLine.Case__c = caseList[0].Id;
            orderLine.Order__c = orderList[0].Id;
            orderLine.Vendor_Mailing_Agent__c = acc.Id;
            
            oliList.add(orderline);
        }

        Test.startTest();
        //Insert Order Line Item/s
        insert oliList;
        
        //Create Subscription
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionStartDate__c = date.today();
        subRec.Zuora__SubscriptionEndDate__c = date.Today() +30;
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderList[0].Id;
        subRec.Order_Number_1__c = orderList[0].Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Legacy_Create_Date__c = 'date';
        subRec.Legacy_Create_By__c = 'a'; 
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subRec.Legacy_Update_Date__c = 'a';
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subrec.Order_Line_Item_Number__c = oliList[0].id;
        subrec.Order_Line_Item_Number_1__c = oliList[0].id;
        subrec.Subscription_Type__c = 'Publication';
        insert subrec;
        
        orderList[0].Subscription__c = subrec.Id;
        update orderList[0];
        
        //Update Order Line Item/s
        oliList[1].Based_Order_Line_Item__c = oliList[0].Id;
        oliList[1].Vendor_Conversion__c = true;
        oliList[1].Vendor_Subscription_ID__c = subVendor.Id;
        update oliList[1];
        
        
        
        //Delete Order Line Item/s
        delete oliList[1];
        Test.stopTest();
    }
    
    static testMethod void Test_COSQuantityOrderType() {
        //Create Test Data
        createTestData();
        
        //Create Order
        orderList[1].Order_Type__c = ConstantsSLB.getOther('Order_Type COS_Quantity');
        insert orderList[1];
        
        //Create Case
        caseList[1].Order__c = orderList[1].Id;
        insert caseList[1];
        
        //Create Order Line Items
        //Create Order Line Items
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c orderline : TestDataFactory.createOrderLineItem(2)) {
            //orderline.Order__c = orderRec_0.Id;
            orderline.End_Date__c = date.today() +30;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;  
            orderline.Asia1_Creation_Mode__c = 'Individual';
            orderline.Start_Date__c = date.today();
            orderline.Term_is_discussed__c = false;
            orderline.Is_Digital__c = TRUE;
            orderline.Promotion_ID__c = promoTmp.id;
            orderline.Penalty_Charge__c = 100;
            orderline.New_Contract_Period__c = 1;
            orderline.Main_Package_Subscription_Rate__c = 100;
            orderline.Qty__c = 1;
            orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline.Main_Package_Frequency__c = 'Default';
            orderline.Main_Package_Sub_Type__c = 'Single';
            orderline.Main_Package_Type__c = 'Base';
            orderline.Subscribed_as__c = 'New Buy';
            orderLine.Case__c = caseList[1].Id;
            orderLine.Order__c = orderList[1].Id;
            orderLine.Vendor_Mailing_Agent__c = acc.Id;
            
            oliList.add(orderline);
        }

        Test.startTest();
        //Insert Order Line Item/s
        insert oliList;
        
        //Create Subscription
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionStartDate__c = date.today();
        subRec.Zuora__SubscriptionEndDate__c = date.Today() +10;
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderList[1].Id;
        subRec.Order_Number_1__c = orderList[1].Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Legacy_Create_Date__c = 'date';
        subRec.Legacy_Create_By__c = 'a'; 
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subRec.Legacy_Update_Date__c = 'a';
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subrec.Order_Line_Item_Number__c = oliList[0].id;
        subrec.Order_Line_Item_Number_1__c = oliList[0].id;
        subrec.Subscription_Type__c = 'Publication';
        insert subrec;
        
        orderList[1].Subscription__c = subrec.Id;
        update orderList[1];
        
        
        //Update Order Line Item/s
        oliList[1].Based_Order_Line_Item__c = oliList[0].Id;
        oliList[1].Vendor_Conversion__c = true;
        oliList[1].Vendor_Subscription_ID__c = subVendor.Id;
        update oliList[1];
        
        
        
        //Delete Order Line Item/s
        delete oliList[1];
        Test.stopTest();
    }
    
    static testMethod void Test_StopOrderType() {
        //Create Test Data
        createTestData();
        
        //Create Order
        orderList[3].Order_Type__c = ConstantsSLB.getOther('Order_Type Stop');
        insert orderList[3];
        
        //Create Case
        caseList[3].Order__c = orderList[3].Id;
        insert caseList[3];
        
        //Create Order Line Items
        //Create Order Line Items
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c orderline : TestDataFactory.createOrderLineItem(2)) {
            //orderline.Order__c = orderRec_0.Id;
            orderline.End_Date__c = date.today() +30;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;  
            orderline.Asia1_Creation_Mode__c = 'Individual';
            orderline.Start_Date__c = date.today();
            orderline.Term_is_discussed__c = false;
            orderline.Is_Digital__c = TRUE;
            orderline.Promotion_ID__c = promoTmp.id;
            orderline.Penalty_Charge__c = 100;
            orderline.New_Contract_Period__c = 1;
            orderline.Main_Package_Subscription_Rate__c = 100;
            orderline.Qty__c = 1;
            orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline.Main_Package_Frequency__c = 'Default';
            orderline.Main_Package_Sub_Type__c = 'Single';
            orderline.Main_Package_Type__c = 'Base';
            orderline.Subscribed_as__c = 'New Buy';
            orderLine.Case__c = caseList[3].Id;
            orderLine.Order__c = orderList[3].Id;
            orderLine.Vendor_Mailing_Agent__c = acc.Id;
            
            oliList.add(orderline);
        }


        Test.startTest();
        //Insert Order Line Item/s
        insert oliList;
        
        //Create Subscription
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionStartDate__c = date.today();
        subRec.Zuora__SubscriptionEndDate__c = date.today() +30;
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderList[3].Id;
        subRec.Order_Number_1__c = orderList[3].Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Legacy_Create_Date__c = 'date';
        subRec.Legacy_Create_By__c = 'a'; 
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subRec.Legacy_Update_Date__c = 'a';
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subrec.Order_Line_Item_Number__c = oliList[0].id;
        subrec.Order_Line_Item_Number_1__c = oliList[0].id;
        subrec.Subscription_Type__c = 'Publication';
        insert subrec;
        
        orderList[3].Subscription__c = subrec.Id;
        update orderList[3];
        
        
        //Update Order Line Item/s
        //oliList[1].Based_Order_Line_Item__c = oliList[0].Id;
        //oliList[1].Vendor_Conversion__c = true;
        //oliList[1].Vendor_Subscription_ID__c = subVendor.Id;
        update oliList[1];
        
        
        
        //Delete Order Line Item/s
        delete oliList[1];
        Test.stopTest();
    } 
    
    static testMethod void Test_RenewalOrderType() {

        //Create Account
        Account acc;
        acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        //Create Contact
        Contact con;
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        //Create Billing Account
        Zuora__CustomerAccount__c billAcc;
        billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Name = 'TEST';     
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        insert billAcc;
        
        //Create zProduct
        zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductPlatform__c = 'Print';
        insert zProduct;
        
        //Create Product Rate Plan
        prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        
        //Create Product Rate Plan Charge
        prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        //Create Package
        Package__c pack;
        pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        //pack.Package_Code__c = 'SAMPLE';
        pack.Subscription_Type__c = 'Termed';
        pack.Package_Sub_Type__c = 'Single';
        pack.Subscription_Period__c = '2';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        insert pack;
        
        
        //Create Package Item
        pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        insert pItem;
        
        //Create Subscription
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionStartDate__c = date.today();
        subRec.Zuora__SubscriptionEndDate__c = date.today()+30;
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        //subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Legacy_Create_Date__c = 'date';
        subRec.Legacy_Create_By__c = 'a'; 
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subRec.Legacy_Update_Date__c = 'a';
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subrec.Subscription_Type__c = 'Publication';
        subRec.Zuora__CustomerAccount__c = billAcc.id;
        insert subrec;
        
        //Create Order
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Informed_Customer__c = TRUE;
        orderRec_0.Sub_Category__c ='Stop Subscription';
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
        orderRec_0.Status__c = 'Active';
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        orderRec_0.Delivery_Charge__c = 0;
        orderRec_0.Billing_Contact__c = null;
        orderRec_0.Delivery_Charge_Type__c = 'S' ;
        orderRec_0.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orderRec_0.Check_Amount__c = 100;
        orderRec_0.Check_Issuing_Bank__c = 'BLANK';
        orderRec_0.Check_No__c = 'SPACE';
        orderRec_0.Check_Dated__c =  date.today();
        orderRec_0.Remarks_Check__c =  'TESTTESTTEST';
        orderRec_0.Zone_Charge__c = 0;
        orderRec_0.Subscriber_Charge__c = 0;
        orderRec_0.Vendor_Credit__c = 0;
        orderRec_0.Billing_Account__c = billAcc.id;
        orderRec_0.Other_Payment_Mode__c = 'Invoice';
        orderRec_0.Base_Subscription__c = subrec.Id;
        orderRec_0.Billing_Type__c = 'Full Prepaid';
        insert orderRec_0;
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.End_Date__c = date.today() +30;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;  
        orderline.Asia1_Creation_Mode__c = 'Individual';
        orderline.Term_is_discussed__c = false;
        orderline.Is_Digital__c = TRUE;
        //orderline.Promotion_ID__c = promoTmp.id;
        orderline.Penalty_Charge__c = 100;
        orderline.New_Contract_Period__c = 1;
        orderline.Main_Package_Subscription_Rate__c = 100;
        orderline.Qty__c = 1;
        orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline.Main_Package_Frequency__c = 'Default';
        orderline.Main_Package_Sub_Type__c = 'Single';
        orderline.Main_Package_Type__c = 'Base';
        orderline.Subscribed_as__c = 'New Buy';
        //orderLine.Case__c = caseList[2].Id;
        orderLine.Order__c = orderRec_0.Id;
        orderLine.Start_Date__c = date.today();
        insert orderLine;
        
    }*/
}