/**
     * Test Class Name: BillingAccountHelperTest
     * @author: John Patrick L. Ocariz
     * @base class: BillingAccountHelper
     * Date: 02/05/2015    
     */    


@isTest (SeeAllData = true)
private class BillingAccountHelperTest {
    
   /*  Description of the purpose of the classthe method. 
    *  @name <testupdateBillingAccountPaymentInfo_01>
    *  @description - test method with the following conditions:
    *                       tmp.Payment_Mode__c == 'Other' && tmp.Other_Payment_Mode__c == 'Invoice') 
    *                       tmp.Create_ARMS_Customer_Account__c == true || tmp.Create_ARMS_Account_Only__c == true) 
    *  @param <void>>
    *  @return <none> - 
    *  @throws exception-<none>
    *
    * code taken from SM_ChangeOfSubscriptionEntryContTest (test data)
    */
  
    static testmethod void testupdateBillingAccountPaymentInfo_01(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        insert pack;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        //create zuora account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.Zuora__DefaultPaymentMethod__c = 'check';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
     
        insert billAcc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        Order__c order = TestDataFactory.createOrder(1)[0]; 
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Subscriber_Charge__c = 200.00;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.CreatedById = billAcc.Id;        
        //all order ARMS fields
        order.ARMS_Account_Number__c = '1110000';
        order.ARMS_Account_ID__c = '00000';
        order.ARMS_Credit_Term__c = 'ABC';        
        //additional fields        
        order.Customer_No__c = '12345';
        order.Billing_Type__c = 'Full Prepaid';
        order.Debt_Management_Treatment__c = 'asg';
        order.Business_Profile__c = 'sample business profile';
        order.Cust_Giro_Acct_Number__c = '110000000';
        order.Cust_Giro_Bank_Number__c = '00100';
        order.Credit_Limit_External_Limit__c = '250000.00';
        order.Credit_Limit_Internal_Limit__c = '560000.00';
        order.Credit_Term_Reference__c = '0';
        order.Customer_No__c = '000000069';
        order.Payment_Mode__c = 'Other';
        order.Other_Payment_Mode__c = 'Invoice';        
        order.Approved_Debt_Exposure_Amount__c = '12345';
        order.Business_Sector__c = 'IT';
        order.Company_Code__c = 'ACN';
        order.SOA_Suppression_Indicator__c = 'A';
        order.Transient_Indicator__c = 'A';            
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = true;      
        insert order;        
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        //orderline.order
        insert orderline;
        
        //create subscriptions               
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        subRecs[0].Zuora__Account__c = acc.Id;
        subRecs[0].Zuora__CustomerAccount__c = billAcc.Id;
        subRecs[0].Zuora__Zuora_Id__c = '1123';
        subRecs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs[0].Subscriber_Contact__c = con.Id;
        subRecs[0].Recipient_Contact__c = con.Id;
        subRecs[0].Main_Package_1__c = pack.id;
        subRecs[0].Zuora__Status__c = 'Active';
        subRecs[0].Order_Number__c = order.Id;
        subRecs[0].Suppress_Vendor_Start_Notice__c = 'false';
        subRecs[0].Supressed_Acknowledgement_Letter__c = 'false';
        subRecs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs[0].Urgent__c = 'false';
        subRecs[0].Vendor_Conversion__c = 'false';
        subRecs[0].Charity__c = 'false';        
        subRecs[0].Order_Line_Item_Number__c = orderline.id;
        subRecs[0].Subscription_Type_1__c = 'Publication';
        subRecs[0].Subscription_Type__c = 'Publication';
        subRecs[0].Zuora__Status__c = 'Active';
        subRecs[0].Order_Number_1__c = order.id;
        
        subRecs[1].Zuora__Account__c = acc.Id;
        subRecs[1].Zuora__Zuora_Id__c = '1123';
        //subRecs[1].Zuora__CustomerAccount__c = billAcc[0].Id;
        subRecs[1].Zuora__SubscriptionEndDate__c = date.today().addDays(31);
        subRecs[1].Subscriber_Contact__c = con.Id;
        subRecs[1].Recipient_Contact__c = con.Id;
        subRecs[1].Main_Package_1__c = pack.id;
        subRecs[1].Zuora__Status__c = 'Active';
        subRecs[1].Order_Number__c = order.Id;
        subRecs[1].Suppress_Vendor_Start_Notice__c = 'false';
        subRecs[1].Supressed_Acknowledgement_Letter__c = 'false';
        subRecs[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs[1].Urgent__c = 'false';
        subRecs[1].Vendor_Conversion__c = 'false';
        subRecs[1].Charity__c = 'false';
        subRecs[1].Billing_Type__c = 'Full Prepaid';
        subRecs[1].Order_Line_Item_Number__c = orderline.id;
        subRecs[1].Subscription_Type_1__c = 'Publication';
        subRecs[1].Subscription_Type__c = 'Publication';
        subRecs[1].Zuora__Status__c = 'Active';
        subRecs[1].Order_Number_1__c = order.id;
        subRecs[1].Zuora__CustomerAccount__c = billAcc.id;              
        
        System.assertEquals(pack.id, subRecs[0].Main_Package_1__c);
        try{
            Test.setMock(WebServiceMock.class, new zLoginMock());
        test.startTest();
            insert subRecs;     
           
            Id testorderId = order.Id;
            
            set<id> testorderIdSet = new set<id>();
            testorderIdSet.add(testorderId);
            
            BillingAccountHelper.updateBillingAccountPaymenInfo(testorderIdSet);             
        
        test.stopTest();
        }catch(Exception e){
        }        
    }
    
   /*
    *  @name <testupdateBillingAccountPaymentInfo_01>
    *  @description - test method with the following conditions:
    *                       tmp.Create_ARMS_Customer_Account__c == false|| tmp.Create_ARMS_Account_Only__c == false)
                            billingAccountIdWithAccountSet.size() > 0 
    *  @param <void>>
    *  @return <none> - 
    *  @throws exception-<none>
    *
    * code taken from SM_ChangeOfSubscriptionEntryContTest (test data)
    */
    
   
       
    static testmethod void testupdateBillingAccountPaymentInfo_02(){
    try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
       
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        insert pack;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        //create zuora account
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
        billAcc[0].Zuora__Account__c = acc.Id;
        billAcc[0].ARMS_Account_Type__c = 'Savings';
        billAcc[0].Zuora__DefaultPaymentMethod__c  = 'creditcard';
        billAcc[0].Billing_Type__c = 'Full Prepaid';
        billAcc[0].ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc[0].ARMS_Debt_Management__c = 'picklist data type??';
        billAcc[0].ARMS_ID__c = '00002';
        billAcc[0].Zuora__AccountNumber__c = '12345667';
        billAcc[0].Zuora__BillToAddress1__c = 'Address1';
        billAcc[0].Zuora__BillToAddress2__c = 'Address2';
        billAcc[0].Zuora__BillToPostalCode__c = '1900';
        billAcc[0].Zuora__BillToCity__c = 'New York';
        billAcc[0].Zuora__BillToName__c = 'John Smith';
     
        insert billAcc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.Id;
        order.Subscriber_Charge__c = 200.00;
        order.Informed_Customer__c = TRUE;
        order.Billing_Type__c = 'Full Prepaid';
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
        order.Billing_Account__c = billAcc[0].id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.CreatedById = billAcc.Id;        
        //all order ARMS fields
        order.ARMS_Account_Number__c = '1110000';
        order.ARMS_Account_ID__c = '00000';
        order.ARMS_Credit_Term__c = 'ABC';        
        //additional fields        
        order.Customer_No__c = '12345';
        order.Debt_Management_Treatment__c = 'asg';
        order.Business_Profile__c = 'sample business profile';
        order.Cust_Giro_Acct_Number__c = '110000000';
        order.Cust_Giro_Bank_Number__c = '00100';
        order.Credit_Limit_External_Limit__c = '250000.00';
        order.Credit_Limit_Internal_Limit__c = '560000.00';
        order.Credit_Term_Reference__c = '0';
        order.Customer_No__c = '000000069';
        order.Payment_Mode__c = 'Other';
        order.Other_Payment_Mode__c = 'Invoice';        
        order.Approved_Debt_Exposure_Amount__c = '12345';
        order.Business_Sector__c = 'IT';
        order.Company_Code__c = 'ACN';
        order.SOA_Suppression_Indicator__c = 'A';
        order.Transient_Indicator__c = 'A';     
        order.Create_ARMS_Customer_Account__c = false;
        order.Create_ARMS_Account_Only__c = false;
        order.Account__c = acc.Id;       
        insert order;        
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        //orderline.order
        insert orderline;
        
        //create subscriptions               
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        subRecs[0].Zuora__Account__c = acc.Id;
        subRecs[0].Zuora__CustomerAccount__c = billAcc[0].Id;
        subRecs[0].Zuora__Zuora_Id__c = '1123';
        subRecs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs[0].Subscriber_Contact__c = con.Id;
        subRecs[0].Recipient_Contact__c = con.Id;
        subRecs[0].Main_Package_1__c = pack.id;
        subRecs[0].Zuora__Status__c = 'Active';
        subRecs[0].Order_Number__c = order.Id;
        subRecs[0].Suppress_Vendor_Start_Notice__c = 'false';
        subRecs[0].Supressed_Acknowledgement_Letter__c = 'false';
        subRecs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs[0].Urgent__c = 'false';
        subRecs[0].Vendor_Conversion__c = 'false';
        subRecs[0].Charity__c = 'false';
        subRecs[0].Billing_Type__c = 'Full Prepaid';
        subRecs[0].Order_Line_Item_Number__c = orderline.id;
        subRecs[0].Subscription_Type_1__c = 'Publication';
        subRecs[0].Subscription_Type__c = 'Publication';
        subRecs[0].Zuora__Status__c = 'Active';
        subRecs[0].Order_Number_1__c = order.id;
        
        subRecs[1].Zuora__Account__c = acc.Id;
        subRecs[1].Zuora__CustomerAccount__c = billAcc[0].Id;
        subRecs[1].Zuora__Zuora_Id__c = '1123';
        subRecs[1].Zuora__SubscriptionEndDate__c = date.today().addDays(31);
        subRecs[1].Subscriber_Contact__c = con.Id;
        subRecs[1].Recipient_Contact__c = con.Id;
        subRecs[1].Main_Package_1__c = pack.id;
        subRecs[1].Zuora__Status__c = 'Active';
        subRecs[1].Order_Number__c = order.Id;
        subRecs[1].Suppress_Vendor_Start_Notice__c = 'false';
        subRecs[1].Supressed_Acknowledgement_Letter__c = 'false';
        subRecs[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs[1].Urgent__c = 'false';
        subRecs[1].Vendor_Conversion__c = 'false';
        subRecs[1].Charity__c = 'false';
        subRecs[1].Billing_Type__c = 'Full Prepaid';
        subRecs[1].Order_Line_Item_Number__c = orderline.id;
        subRecs[1].Subscription_Type_1__c = 'Publication';
        subRecs[1].Subscription_Type__c = 'Publication';
        subRecs[1].Zuora__Status__c = 'Active';
        subRecs[1].Order_Number_1__c = order.id;
        //subRecs[1].Zuora__CustomerAccount__c = billAcc[0].id;       
        
        test.startTest();
        insert subRecs;
                 
            Id testorderId = order.Id;
            
            set<id> testorderIdSet = new set<id>();
            testorderIdSet.add(testorderId);
            
            BillingAccountHelper.updateBillingAccountPaymenInfo(testorderIdSet); 
        
        
        test.stopTest();
        }catch (Exception e) {
       } 
    }    
            
    /*
    *  @name <testupdateBillingAccountPaymentInfo_01>
    *  @description - test method with the following conditions:
                        tmp.Payment_Mode__c == 'Cash'
                        billingAccountId_orderId.size() > 0
    *  @param <void>>
    *  @return <none> - 
    *  @throws exception-<none>
    *
    * code taken from SM_ChangeOfSubscriptionEntryContTest (test data)
    */
        
  
    static testmethod void testupdateBillingAccountPaymentInfo_03(){
    try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        insert pack;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        //create zuora account
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
        billAcc[0].Zuora__Account__c = acc.Id;
        billAcc[0].ARMS_Account_Type__c = 'Savings';
        billAcc[0].Zuora__DefaultPaymentMethod__c  = 'Cash';
        billAcc[0].Billing_Type__c = 'Full Prepaid';
        billAcc[0].ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc[0].ARMS_Debt_Management__c = 'picklist data type??';
        billAcc[0].ARMS_ID__c = '00002';
        billAcc[0].Zuora__AccountNumber__c = '12345667';
        billAcc[0].Zuora__BillToAddress1__c = 'Address1';
        billAcc[0].Zuora__BillToAddress2__c = 'Address2';
        billAcc[0].Zuora__BillToPostalCode__c = '1900';
        billAcc[0].Zuora__BillToCity__c = 'New York';
        billAcc[0].Zuora__BillToName__c = 'John Smith';
     
        insert billAcc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        Order__c order = TestDataFactory.createOrder(1)[0]; 
        order.Payment_Mode__c = 'Cash';
        order.Billing_Type__c = 'Full Prepaid';
        order.Account__c = acc.Id;
        order.Subscriber_Charge__c = 200.00;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
        order.Billing_Account__c = billAcc[0].id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //ord.CreatedById = billAcc.Id;        
        //all order ARMS fields
        order.ARMS_Account_Number__c = '1110000';
        order.ARMS_Account_ID__c = '00000';
        order.ARMS_Credit_Term__c = 'ABC';        
        //additional fields        
        order.Customer_No__c = '12345';
        order.Debt_Management_Treatment__c = 'asg';
        order.Business_Profile__c = 'sample business profile';
        order.Cust_Giro_Acct_Number__c = '110000000';
        order.Cust_Giro_Bank_Number__c = '00100';
        order.Credit_Limit_External_Limit__c = '250000.00';
        order.Credit_Limit_Internal_Limit__c = '560000.00';
        order.Credit_Term_Reference__c = '0';
        order.Customer_No__c = '000000069';            
        order.Approved_Debt_Exposure_Amount__c = '12345';
        order.Business_Sector__c = 'IT';
        order.Company_Code__c = 'ACN';
        order.SOA_Suppression_Indicator__c = 'A';
        order.Transient_Indicator__c = 'A';            
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = true;
        insert order;        
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        System.assertEquals(order.Id, cas.Order__c);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        //orderline.order
        insert orderline;
        
        //create subscriptions               
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        subRecs[0].Zuora__Account__c = acc.Id;
        subRecs[0].Zuora__CustomerAccount__c = billAcc[0].Id;
        subRecs[0].Zuora__Zuora_Id__c = '1123';
        subRecs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs[0].Subscriber_Contact__c = con.Id;
        subRecs[0].Recipient_Contact__c = con.Id;
        subRecs[0].Main_Package_1__c = pack.id;
        subRecs[0].Zuora__Status__c = 'Active';
        subRecs[0].Order_Number__c = order.Id;
        subRecs[0].Suppress_Vendor_Start_Notice__c = 'false';
        subRecs[0].Supressed_Acknowledgement_Letter__c = 'false';
        subRecs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs[0].Urgent__c = 'false';
        subRecs[0].Vendor_Conversion__c = 'false';
        subRecs[0].Charity__c = 'false';
        subRecs[0].Billing_Type__c = 'Full Prepaid';
        subRecs[0].Order_Line_Item_Number__c = orderline.Id;
        subRecs[0].Subscription_Type_1__c = 'Publication';
        subRecs[0].Subscription_Type__c = 'Publication';
        subRecs[0].Zuora__Status__c = 'Active';
        subRecs[0].Order_Number_1__c = order.id;
        
        subRecs[1].Zuora__Account__c = acc.Id;
        subRecs[1].Zuora__CustomerAccount__c = billAcc[0].Id;
        subRecs[1].Zuora__Zuora_Id__c = '1123';
        subRecs[1].Zuora__SubscriptionEndDate__c = date.today().addDays(31);
        subRecs[1].Subscriber_Contact__c = con.Id;
        subRecs[1].Recipient_Contact__c = con.Id;
        subRecs[1].Main_Package_1__c = pack.id;
        subRecs[1].Zuora__Status__c = 'Active';
        subRecs[1].Order_Number__c = order.Id;
        subRecs[1].Suppress_Vendor_Start_Notice__c = 'false';
        subRecs[1].Supressed_Acknowledgement_Letter__c = 'false';
        subRecs[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs[1].Urgent__c = 'false';
        subRecs[1].Vendor_Conversion__c = 'false';
        subRecs[1].Charity__c = 'false';
        subRecs[1].Billing_Type__c = 'Full Prepaid';
        subRecs[1].Order_Line_Item_Number__c = orderline.id;
        subRecs[1].Subscription_Type_1__c = 'Publication';
        subRecs[1].Subscription_Type__c = 'Publication';
        subRecs[1].Zuora__Status__c = 'Active';
        subRecs[1].Order_Number_1__c = order.id;
        //subRecs[1].Zuora__CustomerAccount__c = billAcc[0].id;       
        
        test.startTest();
        insert subRecs;      
        
            Id testorderId = order.Id;
            
            set<id> testorderIdSet = new set<id>();
            testorderIdSet.add(testorderId);
            //System.AssertEquals(testorderObj.Payment_Mode__c+':::::'+testOrderObj.Other_Payment_Mode__c+':::'+testOrderIdSet,' ');
            
            BillingAccountHelper.updateBillingAccountPaymenInfo(testorderIdSet); 
        
        
        test.stopTest();
         }catch (Exception e) {
       } 
    } 


    static testmethod void updateBillingAccountForRenewCheque(){
     try{
            Test.setMock(WebServiceMock.class, new zLoginMock());
                      
            Account account = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert account;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = account.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
                  
        
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = account.Id;
            order.Customer_No__c = '123'; 
            order.Payment_Mode__c = 'Cash';
            order.Other_Payment_Mode__c = 'Invoice';
            order.Check_Issuing_Bank__c = 'Test';
            order.Check_No__c = '1000';
            order.Check_Dated__c = date.today();
            order.Check_Amount__c = 1000;
            order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
            order.Payment_Mode__c = 'Check';
            insert order;
                                
            List<Zuora__CustomerAccount__c> billingAcc = TestDataFactory.createBillingAccount(1);
            billingAcc[0].Zuora__Account__c = account.Id;
            billingAcc[0].Zuora__Zuora_Id__c = 'Id';
            billingAcc[0].Cheque_Date__c = order.Check_Dated__c;
            billingAcc[0].Cheque_No__c = decimal.valueOf(order.Check_No__c);
            billingAcc[0].Bank__c = order.Check_Issuing_Bank__c;
            insert billingAcc;     
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(1);
            subRecs[0].Zuora__Account__c = account.Id;
            subRecs[0].Zuora__CustomerAccount__c = billingAcc[0].Id;
            subRecs[0].Zuora__Zuora_Id__c = '1123';
            subRecs[0].Recipient_Contact__c = con.id;
            subRecs[0].Order_Number_1__c = order.id;
            insert subRecs;    
            
            test.startTest();             
           
            Id orderId = order.Id;
            set<id> billingAccountIdSet = new set<id>();           
            billingAccountIdSet.add(orderId);
           
            BillingAccountHelper.updateBillingAccountForRenewCheque(billingAccountIdSet); 
            test.stopTest();
         }catch (Exception e){}
        
     }
    
    static testmethod void updateSphPaymentMethod(){
     try{
            Test.setMock(WebServiceMock.class, new zLoginMock());
             
            
         
            Account account = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert account;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = account.Id;
            insert con; 
        
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = account.Id;
            order.Customer_No__c = '123'; 
            
            order.Other_Payment_Mode__c = 'Invoice';
            order.Payment_Mode__c = 'Other';
            insert order;
                                
            List<Zuora__CustomerAccount__c> billingAcc = TestDataFactory.createBillingAccount(1);
            billingAcc[0].Zuora__Account__c = account.Id;
            billingAcc[0].Zuora__Zuora_Id__c = 'Id';
            billingAcc[0].Zuora__DefaultPaymentMethod__c = 'Test';
            insert billingAcc;     
           
               list<Zuora.zObject> zObjectList = new list<Zuora.zObject>();
            Zuora.zObject zObject = new Zuora.zObject('Account');
            zObject.setValue('Id', billingAcc[0].Zuora__Zuora_Id__c);
            zObject.setValue('Other_PaymentMethod__c', 'Invoice');
            zObjectList.add(zObject);
            
            test.startTest();             
           
            Id orderId = order.Id;
            set<id> billingAccountIdSet = new set<id>();           
            billingAccountIdSet.add(orderId);
           
            BillingAccountHelper.updateSphPaymentMethod(billingAccountIdSet); 
            test.stopTest();
         }catch (Exception e){}
        
     }    
    

        
}