/**
 * Class Name: <PackageEligibilityCheck>
 * @author: <Jessica Palapal>
 * Date: <10/22/2014>
 * Requirement/Project Name: <SPH>
 * @description: Test Class for PackageEligibilityCheck
 */
 
@isTest
private class PackageEligibilityCheckTest{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createOther();
    }  
    
    static testMethod void test(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardSPX15@test.com'
        );
        
        System.runAs(testUser) {
        
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Generate_Account_Number__c = TRUE;
            insert acc;
            
            Promotion__c promo = new Promotion__c();
            promo.Name = 'promotor';
            promo.Promotion_Code__c = 'yasyd97';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(1);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            insert promo;
             
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Bundled';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
            promopack.Promotion__c = promo.id;
            promopack.Package_Name__c = pack.id;
            insert promopack;
            
            Eligibility_Rule__c eli = new Eligibility_Rule__c();
            eli.Name = 'elitset';
            eli.Customer_Status__c = 'New customer';
            eli.Action__c = 'Add';
            eli.Effective_Start_Date__c = date.today();
            eli.Effective_End_Date__c = date.today().addDays(1);
            eli.Condition__c = '<';
            eli.Contract_Subscription_Rule__c = 'Subscription End Date';
            insert eli;
            
            List<Promotion_Eligibility_Rule__c>  promEli = TestDataFactory.createPromEligibilityRule(1);
            promEli[0].Eligibility_Rule__c = eli.id;
            promEli[0].Date__c = date.today();
            promEli[0].Package_List__c = pack.id;
            promEli[0].Promotion__c = promo.id;
            insert promEli;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
            
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            }
            insert pItems;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Name = 'billibong';
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__DefaultPaymentMethod__c ='Other';
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
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Type__c ='Full Prepaid';
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Subscriber_Charge__c = 10.00;
            //order.Postage_Charge__c = 200.00;
            insert order;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
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
            orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
            subRecs[0].Zuora__Account__c = acc.Id;
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
            subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
            subRecs[0].Number_of_Copies1__c = '100';
            subRecs[1].Zuora__Account__c = acc.Id;
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
            subRecs[1].Order_Line_Item_Number__c = orderline.id;
            subRecs[1].Subscription_Type_1__c = 'Publication';
            subRecs[1].Subscription_Type__c = 'Publication';
            subRecs[1].Zuora__Status__c = 'Active';
            subRecs[1].Order_Number_1__c = order.id;
            subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[1].Number_of_Copies1__c = '100';
            Test.startTest();
            insert subRecs;

           PackageEligibilityCheck.PackageEligibilityCheckRequest packReq = new PackageEligibilityCheck.PackageEligibilityCheckRequest();
           PackageEligibilityCheck.PackageEligibilityCheckResponse response =  PackageEligibilityCheck.processRequest(packReq);
           Test.stopTest();
           }
            }
         catch(Zuora.zRemoteException e) {
          }
    }
    static testMethod void test2(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardSPX16@test.com'
        );
        
        System.runAs(testUser) {
        
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.Generate_Account_Number__c = TRUE;
            acc.NRIC__c = 'T1234567R';
            insert acc;
			
			acc = [select Id, Account_Auto_Number__c, NRIC__c from Account where Id = :acc.Id];
            
            Promotion__c promo = new Promotion__c();
            promo.Name = 'promotor';
            promo.Promotion_Code__c = 'yasyd97';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(1);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            insert promo;
             
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Bundled';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
            promopack.Promotion__c = promo.id;
            promopack.Package_Name__c = pack.id;
            insert promopack;
            
            Eligibility_Rule__c eli = new Eligibility_Rule__c();
            eli.Name = 'elitset';
            eli.Customer_Status__c = 'New customer';
            eli.Action__c = 'Add';
            eli.Effective_Start_Date__c = date.today();
            eli.Effective_End_Date__c = date.today().addDays(1);
            eli.Condition__c = '<';
            eli.Contract_Subscription_Rule__c = 'Subscription End Date';
            insert eli;
            
            List<Promotion_Eligibility_Rule__c>  promEli = TestDataFactory.createPromEligibilityRule(1);
            promEli[0].Eligibility_Rule__c = eli.id;
            promEli[0].Date__c = date.today();
            promEli[0].Package_List__c = pack.id;
            promEli[0].Promotion__c = promo.id;
            insert promEli;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
            
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            }
            insert pItems;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Name = 'billibong';
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__DefaultPaymentMethod__c ='Other';
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
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Type__c ='Full Prepaid';
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Subscriber_Charge__c = 10.00;
            //order.Postage_Charge__c = 200.00;
            insert order;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
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
            orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
            subRecs[0].Zuora__Account__c = acc.Id;
            subRecs[0].Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
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
            subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
            subRecs[0].Number_of_Copies1__c = '100';
            subRecs[1].Zuora__Account__c = acc.Id;
            subRecs[1].Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
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
            subRecs[1].Order_Line_Item_Number__c = orderline.id;
            subRecs[1].Subscription_Type_1__c = 'Publication';
            subRecs[1].Subscription_Type__c = 'Publication';
            subRecs[1].Zuora__Status__c = 'Active';
            subRecs[1].Order_Number_1__c = order.id;
            subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[1].Number_of_Copies1__c = '100';
            
            Test.startTest();
            insert subRecs;
           PackageEligibilityCheck.PackageEligibilityCheckRequest packReq = new PackageEligibilityCheck.PackageEligibilityCheckRequest();
           packReq.packageId = pack.Package_Code__c;
           packReq.PromotionId = promo.Promotion_Code__c;
           packReq.Action = 'CAN ADD';
           packReq.SubscriptionId = subRecs[0].Zuora__Zuora_Id__c;
           packReq.SubscriberId = acc.Account_Auto_Number__c;
           packReq.contractPeriod = promo.Contract_Period__c;
           packReq.VendorConversion = 'y';
           PackageEligibilityCheck.PackageEligibilityCheckResponse response =  PackageEligibilityCheck.processRequest(packReq);
           
           packReq.Action = 'CAN CHANGE';
           response =  PackageEligibilityCheck.processRequest(packReq);
           
           Test.stopTest();
            }
             }
         catch(Zuora.zRemoteException e) {
          }
        }
    static testMethod void test5(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            insert postal;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec; 
    
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.Generate_Account_Number__c = TRUE;
            insert acc;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            insert con;
            
            test.StartTest();
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            insert billAcc;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Billing_Contact__c = con.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Subscriber_Charge__c = 10.0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.Delivery_Charge_Type__c = 'C';
            insert order;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';
            pack.Name = 'packs';
            pack.Package_Code__c = '32456dsf';
            pack.Subscription_Type__c = 'Termed';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today();
            pack.Subscription_Period__c = '2';
            insert pack;
            
            //Order Line Item
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Main_Package_ID__c = pack.Id;
            insert orderline;
            
            Promotion__c promo = TestDataFactory.createPromotion(1)[0];
            promo.Name = 'promolicious';
            promo.Promotion_Code__c = '34567dh';
            promo.Effective_Start_Date__c = date.today();
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            promo.Effective_End_Date__c = date.today()+10;
            insert promo;
            
            
            Eligibility_Rule__c eli = new Eligibility_Rule__c();
            eli.Name = 'elitset';
            eli.Customer_Status__c = 'New customer';
            eli.Action__c = 'Add';
            eli.Effective_Start_Date__c = date.today();
            eli.Effective_End_Date__c = date.today().addDays(1);
            eli.Condition__c = '<';
            eli.Contract_Subscription_Rule__c = 'Subscription End Date';
            insert eli;
            
            List<Promotion_Eligibility_Rule__c>  promEli = TestDataFactory.createPromEligibilityRule(1);
            promEli[0].Eligibility_Rule__c = eli.id;
            promEli[0].Date__c = date.today();
            promEli[0].Package_List__c = pack.id;
            promEli[0].Promotion__c = promo.id;
            insert promEli;
            
            Zuora__Subscription__c Sub = TestDataFactory.createSubscription(1)[0];
            Sub.Zuora__CustomerAccount__c = billAcc.id;
            Sub.Zuora__Account__c = acc.id;
            Sub.Zuora__CustomerAccount__c = billAcc.Id;
            Sub.Zuora__Account__c = acc.Id;
            Sub.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            Sub.Subscriber_Contact__c = con.Id;
            Sub.Recipient_Contact__c = con.Id;
            Sub.Main_Package_1__c = pack.id;
            Sub.Main_Package__c = String.valueOf(pack.Id);
            Sub.Zuora__Status__c = 'Active';
            Sub.Order_Number__c = order.Id;
            Sub.Suppress_Vendor_Start_Notice__c = 'false';
            Sub.Supressed_Acknowledgement_Letter__c = 'false';
            Sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Sub.Urgent__c = 'false';
            Sub.Vendor_Conversion__c = null;
            Sub.Charity__c = 'false';
            Sub.Order_Line_Item_Number__c = orderline.Id;
            Sub.Promotion__c = promo.id;
            Sub.Promotion_1__c = promo.id;
            Sub.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
            Sub.Number_of_Copies1__c = '100';
            insert Sub;

            /*Map<String, SObject> sObjMap = new Map<String, SObject>(); 
            sObjMap = TestDataFactory.createSubscriptionPackage(); 
            Zuora__Subscription__c subRecs = (Zuora__Subscription__c ) sObjMap.get('Zuora__Subscription__c');
            Test.startTest();
            insert subRecs;*/ 
            
            PackageEligibilityCheck.PackageEligibilityCheckRequest packReq = new PackageEligibilityCheck.PackageEligibilityCheckRequest();
               packReq.packageId = pack.Package_Code__c;
               packReq.PromotionId = promo.Promotion_Code__c;
               packReq.Action = 'CAN CHANGE';
               packReq.SubscriptionId = Sub.id;
               packReq.contractPeriod = promo.Contract_Period__c;
               packReq.VendorConversion = 'y';
               PackageEligibilityCheck.PackageEligibilityCheckResponse response =  PackageEligibilityCheck.processRequest(packReq);

			   packReq.SubscriptionId = null;
			   packReq.VendorConversion = 'n';
               response =  PackageEligibilityCheck.processRequest(packReq);

            Test.stopTest();
             }
         catch(Zuora.zRemoteException e) {
          }
            }
    static testMethod void test6(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
            /*Map<String, SObject> sObjMap = new Map<String, SObject>(); 
            sObjMap = TestDataFactory.createSubscriptionPackage(); 
            Zuora__Subscription__c subRecs = (Zuora__Subscription__c ) sObjMap.get('Zuora__Subscription__c');
            //List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(1);
            Test.startTest();
            insert subRecs; */
            
                Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
                acc.Name = 'testtest';
                acc.Generate_Account_Number__c = TRUE;
                insert acc;
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                //addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
    
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                con.Phone = '1234567';
                con.AccountId = acc.Id;
                insert con;            
    
                //create order
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Billing_Type__c = 'Full Prepaid';
                order.Recipient_Contact__c = con.Id;
                System.debug('DEBUG con.Id' + con.Id);
                order.Informed_Customer__c = True;
                insert order;   
                
                test.StartTest();
                
                //create case
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                insert cas;
                
                //create Package
                
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                insert pack;
                
                //create Order Line Item
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.Start_Date__c = date.today()+1;
                orderline.End_Date__c = date.today() +5;
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
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                insert orderline;
                    
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];   
                billingAcc.Zuora__Account__c = acc.Id;
                billingAcc.Billing_Type__c = 'Full Prepaid';
                insert billingAcc;
                
               Zuora__Subscription__c Sub = new Zuora__Subscription__c();
               Sub.Zuora__CustomerAccount__c = billingAcc.id;
               Sub.Zuora__Account__c = acc.id;
               Sub.Name= 'TEST';
               Sub.Order_Number__c = order.id;
               Sub.Order_Number_1__c = order.id;
               Sub.Next_Earliest_Start_Date__c= date.today();
               Sub.Subscribe_As__c='test';
               Sub.Zuora__SubscriptionStartDate__c= date.today().addDays(1);
               Sub.Zuora__SubscriptionEndDate__c= date.today().addDays(30);
               Sub.Subscription_Grace_Period_End_Date__c= 'test';
               Sub.Subscriber_Contact__c= con.Id;
               Sub.Recipient_Contact__c= con.Id;
               Sub.Subscription_Charge__c= 223.0;
               Sub.Term_Length__c= 2;
               Sub.Order_Line_Item_Number__c= orderline.id;
               Sub.Zuora__Zuora_Id__c= 'test';
               Sub.Delivered_by_1__c = 'Mailing Agent';
               Sub.Billing_Type__c = 'Full Prepaid';
               insert Sub;
            
               Promotion__c promo = TestDataFactory.createPromotion(1)[0];
               promo.Name = 'promolicious';
               promo.Promotion_Code__c = '34567dh';
               promo.Effective_Start_Date__c = date.today();
               promo.Contract__c = 'Yes';
               promo.Contract_Period__c = '2';
               promo.Effective_End_Date__c = date.today()+10;
               insert promo;
    
               Promotion_Package__c promoPack = TestDataFactory.createPromotionPackage(1)[0]; 
               promoPack.Promotion__c = promo.id;
               promoPack.Package_Name__c = pack.id;
               insert promoPack;
    
               PackageEligibilityCheck.PackageEligibilityCheckRequest packReq = new PackageEligibilityCheck.PackageEligibilityCheckRequest();
               packReq.packageId = pack.Package_Code__c;
               packReq.PromotionId = promo.Promotion_Code__c;
               packReq.Action = 'CAN ADD';
               packReq.SubscriptionId = Sub.id;
               packReq.contractPeriod = promo.Contract_Period__c;
               packReq.VendorConversion = 'y';
               PackageEligibilityCheck.PackageEligibilityCheckResponse response =  PackageEligibilityCheck.processRequest(packReq);
               Test.stopTest();
      }
         catch(Zuora.zRemoteException e) {
          }
    }

}