/**
@Author <Marie Munda/ Rom Edison Reyes>
@name <UpdateSubscriptionClassTest>
@CreateDate <02/05/2015>
@Description <Test class for UpdateSubscriptionClass>
@Version <1.0>
@reference <>
*/
@isTest(seeAllData = TRUE)
private class UpdateSubscriptionClassTest {
    
    /**
    * Test method for Start Order, Vendor = null, with package items
    * @name <startVendorFalseActiveWithPackItem>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void startVendorFalseActiveWithPackItem()
    {
    //Test Data 
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    insert postal;  
        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
        
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    insert pack;
    //insert new List<sObject>{postal, acc, pack};
    
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    zProduct.zqu__SKU__c = 'SKU00000106';
    zProduct.ProductPlatform__c = 'All-in-One';
    zProduct.ProductType__c = 'Product';
    insert zProduct;
            
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanCode__c = 'BHAOFP12NPP2AD';
        prdRatePlan.RatePlanType__c = 'Bill Plan';   
    insert prdRatePlan;
            
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
            
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        //pItem.Product_Platform__c = 'All-In-One';
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.Recipient_Indicator__c = true; //START/END CCB.002 Modified by: Francis Benzon
    insert con;
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge_Override__c = 100;
        promo.Penalty_Charge__c = '100';
    insert promo;
    
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Subscriber_Charge__c = 100;
        orderRec.Account__c = acc.Id;
        orderRec.Order_Type__c = 'Start';
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
                
    Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orderRec.Id;
    
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack.Id;
    insert orderline;
    
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Main_Package__c = String.valueOf(pack.Id);
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = null;
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Number_of_Copies1__c = '100';
    }
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    subRecs[2].Billing_Type__c = 'Full Prepaid';
    subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Test.startTest();
    insert subRecs;

    System.debug('>>>debugpackageitems:'+ pack.id + ' subrecs:' + subRecs[0].Main_Package__c);
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
    
    /**
    * Test method for Start Order, Vendor = null,Inactive
    * @name <startVendorFalseInactive>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void startVendorFalseInactive()
    {
    //Create Singpost Address  
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    
    //Create Account        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    
    //Create Package
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    insert new List<sObject>{postal, acc, pack};
    
    //Create ZProduct
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    insert zProduct;
    
    //Create Product Rate Plan        
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
    prdRatePlan.zqu__ZProduct__c = zProduct.Id;
    insert prdRatePlan;
    
    //Create Product Rate Plan Charge        
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
    prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
    

    //Create Package Item        
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    
    //Create Zuora Customer Account
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    billAcc.Zuora__Account__c = acc.Id;
    insert billAcc;
        
    //Create Address        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
    addressRec.Address_Type__c='P';
    addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    //Create Contact
    Contact con = TestDataFactory.createContact(1)[0];
    con.Address__c = addressRec.Id;
    con.AccountId = acc.Id;
    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    con.Recipient_Indicator__c = true;
    insert con;
    
   //Create Promotion
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
    promo.Contract__c = 'Yes';
    promo.Contract_Period__c = '2';
    promo.Penalty_Charge_Override__c = 100;
    promo.Penalty_Charge__c = '100';
    insert promo;

    //Create Order
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
    orderRec.Subscriber_Charge__c = 100;
    orderRec.Account__c = acc.Id;
    orderRec.Order_Type__c = 'Start';
    orderRec.Informed_Customer__c = TRUE;
    orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
    
    //Create Case
    Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
    cas.Order__c = orderRec.Id;
    insert cas;
    
    //Create Order Line Item
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    orderline.Order__c = orderRec.Id;
    orderline.Start_Date__c = date.today().addDays(1);
    orderline.End_Date__c = date.today().addDays(30);
    orderline.Main_Package_ID__c = pack.Id;
    insert orderline;
    
    //Create Zuora Subscription    
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Inactive';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Number_of_Copies1__c = '100';
    }
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    //subRecs[2].Billing_Type__c = 'Full Prepaid';
    //subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Test.startTest();
    insert subRecs;
    
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
    
    /**
    * Test method for Start Order, Vendor = null, with empty account
    * @name <startVendorFalseAccountEmpty>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void startVendorFalseAccountEmpty()
    {
    //Create Singpost Address  
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    
    //Create Account        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    
    //Create Package
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    insert new List<sObject>{postal, acc, pack};
    
    //Create ZProduct
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    insert zProduct;
    
    //Create Product Rate Plan        
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
    prdRatePlan.zqu__ZProduct__c = zProduct.Id;
    insert prdRatePlan;
    
    //Create Product Rate Plan Charge        
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
    prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
    

    //Create Package Item        
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    
    //Create Zuora Customer Account
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    billAcc.Zuora__Account__c = acc.Id;
    insert billAcc;
        
    //Create Address        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
    addressRec.Address_Type__c='P';
    addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    //Create Contact
    Contact con = TestDataFactory.createContact(1)[0];
    con.Address__c = addressRec.Id;
    con.AccountId = acc.Id;
    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    con.Recipient_Indicator__c = true;
    insert con;
    
   //Create Promotion
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
    promo.Contract__c = 'Yes';
    promo.Contract_Period__c = '2';
    promo.Penalty_Charge_Override__c = 100;
    promo.Penalty_Charge__c = '100';
    insert promo;

    //Create Order
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
    orderRec.Subscriber_Charge__c = 100;
    orderRec.Account__c = acc.Id;
    orderRec.Order_Type__c = 'Start';
    orderRec.Informed_Customer__c = TRUE;
    orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
    
    //Create Case
    Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
    cas.Order__c = orderRec.Id;
    insert cas;
    
    //Create Order Line Item
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    orderline.Order__c = orderRec.Id;
    orderline.Start_Date__c = date.today().addDays(1);
    orderline.End_Date__c = date.today().addDays(30);
    orderline.Main_Package_ID__c = pack.Id;
    insert orderline;
    
    //Create Zuora Subscription    
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
    for (Zuora__Subscription__c subRec : subRecs) {
        //subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        //subRec.Main_Package__c
        subRec.Zuora__Status__c = 'Inactive';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Number_of_Copies1__c = '100';
    }
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    //subRecs[2].Billing_Type__c = 'Full Prepaid';
    //subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Test.startTest();
    insert subRecs;
    
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
    
    /**
    * Start | Vendor = true | Active | Product Platform = All In One
    * @name <startVendorTrueActiveAllInOne>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void startVendorTrueActiveAllInOne()
    {
    //Test Data
    
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    insert postal;  
        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
        
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    insert pack;
    //insert new List<sObject>{postal, acc, pack};
    
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    zProduct.zqu__SKU__c = 'SKU00000106';
    zProduct.ProductPlatform__c = 'All-in-One';
    zProduct.ProductType__c = 'Product';
    insert zProduct;
            
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanCode__c = 'BHAOFP12NPP2AD';
        prdRatePlan.RatePlanType__c = 'Bill Plan';   
    insert prdRatePlan;
            
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
            
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        //pItem.Product_Platform__c = 'All-In-One';
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.Recipient_Indicator__c = true; //START/END CCB.002 Modified by: Francis Benzon
    insert con;
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge_Override__c = 100;
        promo.Penalty_Charge__c = '100';
    insert promo;

    
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Subscriber_Charge__c = 100;
        orderRec.Account__c = acc.Id;
        orderRec.Order_Type__c = 'Start';
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
                
    Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orderRec.Id;
    
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack.Id;
    insert orderline;
    
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Main_Package__c = String.valueOf(pack.Id);
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'true';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Number_of_Copies1__c = '100';
    }
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    subRecs[2].Billing_Type__c = 'Full Prepaid';
    subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Test.startTest();
    insert subRecs;

    System.debug('>>>debugpackageitems:'+ pack.id + ' subrecs:' + subRecs[0].Main_Package__c);
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
    
    /**
    * //Start | Vendor = true | Active | Product Platform = Print
    * @name <startVendorFalseActiveWithPackItem>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void startVendorTrueActivePrint()
    {
    //Test Data
    
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    insert postal;  
        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
        
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    insert pack;
    //insert new List<sObject>{postal, acc, pack};
    
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    zProduct.zqu__SKU__c = 'SKU00000106';
    zProduct.ProductPlatform__c = 'Print';
    zProduct.ProductType__c = 'Product';
    insert zProduct;
            
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanCode__c = 'BHAOFP12NPP2AD';
        prdRatePlan.RatePlanType__c = 'Bill Plan';   
    insert prdRatePlan;
            
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
            
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        //pItem.Product_Platform__c = 'All-In-One';
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.Recipient_Indicator__c = true; //START/END CCB.002 Modified by: Francis Benzon
    insert con;
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge_Override__c = 100;
        promo.Penalty_Charge__c = '100';
    insert promo;

    
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Subscriber_Charge__c = 100;
        orderRec.Account__c = acc.Id;
        orderRec.Order_Type__c = 'Start';
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
                
    Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orderRec.Id;
    
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack.Id;
    insert orderline;
    
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Main_Package__c = String.valueOf(pack.Id);
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'true';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Number_of_Copies1__c = '100';
    }
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    subRecs[2].Billing_Type__c = 'Full Prepaid';
    subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Test.startTest();
    insert subRecs;

    System.debug('>>>debugpackageitems:'+ pack.id + ' subrecs:' + subRecs[0].Main_Package__c);
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
    
    /**
    * Start | Vendor = true | Active | Product Platform = Online
    * @name <startVendorFalseActiveWithPackItem>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void startVendorTrueActiveOnline()
    {
    //Test Data
    
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    insert postal;  
        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
        
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    insert pack;
    //insert new List<sObject>{postal, acc, pack};
    
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    zProduct.zqu__SKU__c = 'SKU00000106';
    zProduct.ProductPlatform__c = 'Online';
    zProduct.ProductType__c = 'Product';
    insert zProduct;
            
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanCode__c = 'BHAOFP12NPP2AD';
        prdRatePlan.RatePlanType__c = 'Bill Plan';   
    insert prdRatePlan;
            
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
            
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.Recipient_Indicator__c = true; //START/END CCB.002 Modified by: Francis Benzon
    insert con;
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge_Override__c = 100;
        promo.Penalty_Charge__c = '100';
    insert promo;

    
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Subscriber_Charge__c = 100;
        orderRec.Account__c = acc.Id;
        orderRec.Order_Type__c = 'Start';
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
                
    Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orderRec.Id;
    
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack.Id;
    insert orderline;
    
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Main_Package__c = String.valueOf(pack.Id);
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'true';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Number_of_Copies1__c = '100';
    }
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    subRecs[2].Billing_Type__c = 'Full Prepaid';
    subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Test.startTest();
    insert subRecs;

    System.debug('>>>debugpackageitems:'+ pack.id + ' subrecs:' + subRecs[0].Main_Package__c);
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
    
    /**
    * Renewal | Vendor = true | Active | Product Platform = Online
    * @name <startVendorFalseActiveWithPackItem>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void renewalVendorTrueActiveOnline()
    {
    //Test Data
    
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    insert postal;  
        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
        
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    pack.Effective_End_Date__c = date.today();
    insert pack;
    //insert new List<sObject>{postal, acc, pack};
    
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    zProduct.zqu__SKU__c = 'SKU00000106';
    zProduct.ProductPlatform__c = 'Online';
    zProduct.ProductType__c = 'Product';
    insert zProduct;
            
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanCode__c = 'BHAOFP12NPP2AD';
        prdRatePlan.RatePlanType__c = 'Bill Plan';   
    insert prdRatePlan;
            
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
            
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.Recipient_Indicator__c = true; //START/END CCB.002 Modified by: Francis Benzon
    insert con;
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge_Override__c = 100;
        promo.Penalty_Charge__c = '100';
    insert promo;
    
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__SubscriptionStartDate__c = date.today();
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Main_Package__c = String.valueOf(pack.Id);
        subRec.Zuora__Status__c = 'Active';
        //subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'true';
        subRec.Charity__c = 'false';
        //subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.today();
        subRec.Number_of_Copies1__c = '100';
        subRec.Term_Length__c = 1;
        subRec.Term_Length1__c = '1';
        }
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    subRecs[2].Billing_Type__c = 'Full Prepaid';
    subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Subscriber_Charge__c = 100;
        orderRec.Order_Type__c = 'Renewal';
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
        orderRec.Base_Subscription__c = subRecs[0].id;
        orderRec.Order_Type__c= 'Renewal';
    insert orderRec;
                
    Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orderRec.Id;
    
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = date.today().addDays(2);
        orderline.Subscription__c = subRecs[0].id;
        //insert orderline; //CLin 25April2016
    
    Test.startTest();
    insert subRecs;

    System.debug('>>>debugpackageitems:'+ pack.id + ' subrecs:' + subRecs[0].Main_Package__c);
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    //System.assertEquals('', error); //CLin 25April2016
    }
    
    /**
    * Change of Subscription Package | Vendor = true | Active | Product Platform = Online
    * @name <changeSubPackVendorTrueActiveOnline>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void changeSubPackVendorTrueActiveOnline()
    {
    //Test Data
    
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    insert postal;  
        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
        
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    insert pack;
    //insert new List<sObject>{postal, acc, pack};
    
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    zProduct.zqu__SKU__c = 'SKU00000106';
    zProduct.ProductPlatform__c = 'Online';
    zProduct.ProductType__c = 'Product';
    insert zProduct;
            
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanCode__c = 'BHAOFP12NPP2AD';
        prdRatePlan.RatePlanType__c = 'Bill Plan';   
    insert prdRatePlan;
            
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
            
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.Recipient_Indicator__c = true; //START/END CCB.002 Modified by: Francis Benzon
    insert con;
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge_Override__c = 100;
        promo.Penalty_Charge__c = '100';
    insert promo;

    
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Subscriber_Charge__c = 100;
        orderRec.Order_Type__c = 'Change of Subscription Package';
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
                
    Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orderRec.Id;
    
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack.Id;
    insert orderline;
    
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Main_Package__c = String.valueOf(pack.Id);
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'true';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Number_of_Copies1__c = '100';
    }
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    subRecs[2].Billing_Type__c = 'Full Prepaid';
    subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Test.startTest();
    insert subRecs;

    System.debug('>>>debugpackageitems:'+ pack.id + ' subrecs:' + subRecs[0].Main_Package__c);
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
    
    /**
    * Change of Subscription Package | Vendor = true | Active | Product Platform = Online
    * @name <changeSubPackVendorTrueActiveOnlineWithCase>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void changeSubPackVendorTrueActiveOnlineWithCase()
    {
    //Test Data
    
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    insert postal;  
        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
        
    List<Package__c> pack = new List<Package__c>();
    pack = TestDataFactory.createPackage(2);
    insert pack;
    //insert new List<sObject>{postal, acc, pack};
    
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    zProduct.zqu__SKU__c = 'SKU00000106';
    zProduct.ProductPlatform__c = 'Online';
    zProduct.ProductType__c = 'Product';
    insert zProduct;
            
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanCode__c = 'BHAOFP12NPP2AD';
        prdRatePlan.RatePlanType__c = 'Bill Plan';   
    insert prdRatePlan;
            
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
            
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack[0].Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    insert pItems;
    Test.startTest();
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.Recipient_Indicator__c = true; //START/END CCB.002 Modified by: Francis Benzon
    insert con;
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge_Override__c = 100;
        promo.Penalty_Charge__c = '100';
    insert promo;

    //Test.startTest();
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
    orderRec.Account__c = acc.Id;
    orderRec.Subscriber_Charge__c = 100;
    orderRec.Order_Type__c = 'Change of Subscription Package';
    orderRec.Informed_Customer__c = TRUE;
    orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
     
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    orderline.Order__c = orderRec.Id;
    orderline.Start_Date__c = date.today().addDays(1);
    orderline.End_Date__c = date.today().addDays(30);
    orderline.Main_Package_ID__c = pack[0].Id;
    orderline.Qty__c = 3;
    insert orderline;
        
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack[0].id;
        subRec.Main_Package__c = String.valueOf(pack[0].Id);
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Order_Number_1__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'true';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Subscription_Type__c = 'Publication';
        subRec.Number_of_Copies1__c = '100';
    }
    
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    //subRecs[2].Billing_Type__c = 'Full Prepaid';
    //subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Zuora__Subscription__c subRec2 = TestDataFactory.createSubscription(1)[0];    
        subRec2.Zuora__Account__c = acc.Id;
        subRec2.Zuora__CustomerAccount__c = billAcc.Id;
        subRec2.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec2.Subscriber_Contact__c = con.Id;
        subRec2.Recipient_Contact__c = con.Id;
        subRec2.Main_Package_1__c = pack[1].id;
        subRec2.Main_Package__c = String.valueOf(pack[1].Id);
        subRec2.Zuora__Status__c = 'Active';
        subRec2.Order_Number__c = orderRec.Id;
        subRec2.Order_Number_1__c = orderRec.Id;
        subRec2.Suppress_Vendor_Start_Notice__c = 'false';
        subRec2.Supressed_Acknowledgement_Letter__c = 'false';
        subRec2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec2.Urgent__c = 'false';
        subRec2.Vendor_Conversion__c = 'true';
        subRec2.Charity__c = 'false';
        subRec2.Order_Line_Item_Number__c = orderline.Id;
        subRec2.Promotion__c = promo.id;
        subRec2.Promotion_1__c = promo.id;
        subRec2.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec2.Subscription_Type__c = 'Publication';
        subRec2.Billing_Type__c = 'Full Prepaid';
        subRec2.Number_of_Copies1__c = '100';   
        //insert subRec2; //CLin 25April2016
  
    /*Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
    cas.Order__c = orderRec.Id;
    cas.AccountId = acc.id;
    insert cas;*/    
        
    //Test.startTest();
    insert subRecs;
    //orderRec.Subscription__c = subRec2.id; //CLin 25April2016
    //update orderRec; //CLin 25April2016
    
    System.debug('>>>debugpackageitems:'+ pack[0].id + ' subrecs:' + subRecs[0].Main_Package__c);
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
    
    /**
    * Change of Subscription Package | Vendor = true | Active | Product Platform = Online
    * @name <changeSubPackVendorTrueActiveOnlineWithCaseOldNotNew>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testMethod void changeSubPackVendorTrueActiveOnlineWithCaseOldNotNew()
    {
    //Test Data
    
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    insert postal;  
        
    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
        
    List<Package__c> packs =TestDataFactory.createPackage(2);
    insert packs;
    //insert new List<sObject>{postal, acc, pack};
        
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    zProduct.zqu__SKU__c = 'SKU00000106';
    zProduct.ProductPlatform__c = 'Online';
    zProduct.ProductType__c = 'Product';
    insert zProduct;
            
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanCode__c = 'BHAOFP12NPP2AD';
        prdRatePlan.RatePlanType__c = 'Bill Plan';   
    insert prdRatePlan;
            
    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
    insert prpc;
            
    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    for (Package_Item__c pItem : pItems) {
        pItem.Package__c = packs[0].Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    }
    pItems[0].Package__c = packs[0].Id;   
    pItems[1].Package__c = packs[1].Id;
    insert pItems;
    
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.Recipient_Indicator__c = true; //START/END CCB.002 Modified by: Francis Benzon
    insert con;
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge_Override__c = 100;
        promo.Penalty_Charge__c = '100';
    insert promo;

   
    Order__c orderRec = TestDataFactory.createOrder(1)[0];
    orderRec.Account__c = acc.Id;
    orderRec.Subscriber_Charge__c = 100;
    orderRec.Order_Type__c = 'Change of Subscription Package';
    orderRec.Informed_Customer__c = TRUE;
    orderRec.Recipient_Contact__c = con.Id;
    insert orderRec;
     
    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    orderline.Order__c = orderRec.Id;
    orderline.Start_Date__c = date.today().addDays(1);
    orderline.End_Date__c = date.today().addDays(30);
    orderline.Main_Package_ID__c = packs[0].Id;
    insert orderline;
        
    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
    for (Zuora__Subscription__c subRec : subRecs) {
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = packs[0].id;
        subRec.Main_Package__c = String.valueOf(packs[1].Id);
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'true';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subRec.Promotion__c = promo.id;
        subRec.Promotion_1__c = promo.id;
        subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
        subRec.Subscription_Type__c = 'Publication';
        subRec.Number_of_Copies1__c = '100';
    }
    
    subRecs[0].Billing_Type__c = 'Full Prepaid';
    subRecs[1].Billing_Type__c = 'Recurring Prepaid';
    //subRecs[2].Billing_Type__c = 'Full Prepaid';
    //subRecs[3].Billing_Type__c = 'Recurring Prepaid';
    
    Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
    cas.Order__c = orderRec.Id;
    cas.AccountId = acc.id;
    insert cas;    
        
    Test.startTest();
    insert subRecs;      
    orderRec.Subscription__c = subRecs[0].id; 
    update orderRec;
         
    System.debug('>>>debugpackageitems:'+ packs[0].id + ' subrecs:' + subRecs[0].Main_Package__c);
    UpdateSubscriptionClass upsubs = new UpdateSubscriptionClass() ;
    String error = '';
        try{
            upsubs.UpdateSubscription(subRecs);
        }catch (exception e)
        {
            error = e.getMessage();
        }
    Test.stopTest();   
    System.assertEquals('', error);
    }
  
}