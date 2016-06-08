/**
 * Class Name: AdminFeeComputationTest
 * @author: Leuwend Job Hapa
 * Date: 01/23/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test Class for AdminFeeComputation
 *
 */

@isTest(seeAllData=True)
private class AdminFeeComputation_Test {
    /**
    *  To test AdminFeeComputation
    *  @name testAdminFeeComputation2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    
    static Map<String, Date> subZuoraIdToEarliestDateMap = new Map<String, Date>();
    
    static testMethod void testAdminFeeComputation2()
    {
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
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
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true; 
            insert con;
            
            Promotion__c promo = TestDataFactory.createPromotion(1)[0];
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
          //promo.Penalty_Charge__c = '100.00';
            promo.Penalty_Charge_Override__c = 100;
            
            insert promo;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Subscriber_Charge__c = 100.00;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today()+1;
            orderline.End_Date__c = date.today().addDays(3);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Promotion_ID__c = promo.Id;
            insert orderline;
            system.assertNotEquals(null, orderline);  
            
            Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Order_Line_Item_Number__c = orderline.Id;
                subRec.Promotion__c = promo.id;
              //subRec.Penalty_Charge__c = '100.00';
                subRec.Promotion_1__c = promo.id;
                subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
                subRec.Contract_End_Date__c = String.valueOf(date.newInstance(2014, 12, 12));
                subRec.Billing_Type__c = 'Full Prepaid';
                subRec.Zuora__CustomerAccount__c = billAcc.Id;  
            Test.startTest();
                subRec.Zuora__Zuora_Id__c ='2c92c0f8535f8de8015364bcf6161d23';
                subRec.Number_of_Copies1__c = '100';
                subRec.Number_of_Copies__c = 100;
                subRec.Qty__c = 20;
            insert subRec;
            
            Date stopReqDate = Date.newInstance(2014, 12, 12);
            subZuoraIdToEarliestDateMap.put(subRec.Zuora__Zuora_Id__c, stopReqDate);
            AdminFeeComputation AFC = new AdminFeeComputation();
            Decimal returnValue = AdminFeeComputation.computeAdminCharge(subRec.id, stopReqDate);
            
            System.AssertEquals(100.00,returnValue);
            Test.stopTest();
    }
    /**
    *  To test AdminFeeComputation
    *  @name testAdminFeeComputation3
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testAdminFeeComputation3()
    {          
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
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
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true; 
            insert con;
            
            Promotion__c promo = TestDataFactory.createPromotion(1)[0];
            promo.Penalty_Charge__c = '100';
            promo.Promotion_Code__c = 'testCode';
            promo.Penalty_Charge_Add_On__c = '100';
            //promo.Penalty_Charge_Override__c = 100.00;
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            insert promo;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Subscriber_Charge__c = 100.00;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today()+1;
            orderline.End_Date__c = date.today().addDays(3);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Promotion_ID__c = promo.Id;
            insert orderline;
            system.assertNotEquals(null, orderline); 
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
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
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Number_of_Copies1__c = '100';
                subRec.Number_of_Copies__c = 100;
                subRec.Qty__c = 20;
                //subRec.Zuora__Zuora_Id__c ='2c92c0f8535f8de8015364bcf6161d23';
              //subRec.Delivery_Charge__c = 100.00;
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
            Test.startTest();
            insert subRecs;
            
            /**for(Zuora__Subscription__c sub: subRecs){
            List<Zuora__Subscription__c> zuoraSub = [SELECT Id, Contract_End_Date_1__c, Promotion_1__c, Promotion__c FROM Zuora__Subscription__c WHERE Id=:sub.Id];
            System.AssertEquals('',zuoraSub[0].Promotion_1__c + ' ' + zuoraSub[0].Promotion__c);
            } */
            //subZuoraIdToEarliestDateMap.put(subRec.Zuora__Zuora_Id__c, stopReqDate);
            Date stopReqDate = Date.newInstance(2014, 12, 12);
            Date stopDate = Date.newInstance(2014, 11, 11);
            Date contractEndDate = Date.newInstance(2014, 12, 12);

            AdminFeeComputation.computeAdminCharge(subRecs[0].id, stopReqDate);
            AdminFeeComputation AFC = new AdminFeeComputation();
            AdminFeeComputation.checkIfWithin(stopDate, contractEndDate);
            
            Test.stopTest();
    }
    /**
    *  To test AdminFeeComputation
    *  @name testAdminFeeComputation4
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testAdminFeeComputation4()
    {
       
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
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
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true; 
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Subscriber_Charge__c = 100.00;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today()+1;
            orderline.End_Date__c = date.today().addDays(3);
            orderline.Main_Package_ID__c = pack.Id;
            insert orderline;
            system.assertNotEquals(null, orderline);  
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Order_Line_Item_Number__c = orderline.Id;
                subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Number_of_Copies1__c = '100';
                subRec.Number_of_Copies__c = 100;
                subRec.Qty__c = 20;
                subRec.Zuora__Zuora_Id__c ='2c92c0f8535f8de8015364bcf6161d23';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            Test.startTest();
            insert subRecs;
            
            Date stopReqDate = Date.newInstance(2014, 12, 12);
            Date stopDate = Date.newInstance(2015, 01, 01);
            Date contractEndDate = Date.newInstance(2014, 12, 12);
            //subZuoraIdToEarliestDateMap.put(subRec.Zuora__Zuora_Id__c, stopReqDate);
            AdminFeeComputation.computeAdminCharge(subRecs[0].id, stopReqDate);
            AdminFeeComputation AFC = new AdminFeeComputation();
            AdminFeeComputation.checkIfWithin(stopDate, contractEndDate);
            
            Test.stopTest();
    }
    
    static testMethod void testPenaltyChargeOverrideIsNull()
    {
       
             Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
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
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true; 
            insert con;
            
            Promotion__c promo = TestDataFactory.createPromotion(1)[0];
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            promo.Penalty_Charge__c = '100.00';
          //promo.Penalty_Charge_Override__c = 100;
            
            insert promo;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Subscriber_Charge__c = 100.00;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today()+1;
            orderline.End_Date__c = date.today().addDays(3);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Promotion_ID__c = promo.Id;
            insert orderline;
            system.assertNotEquals(null, orderline);  
            
            Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Order_Line_Item_Number__c = orderline.Id;
                subRec.Promotion__c = promo.id;
              //subRec.Penalty_Charge__c = '100.00';
                subRec.Promotion_1__c = promo.id;
                subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
                subRec.Contract_End_Date__c = String.valueOf(date.newInstance(2014, 12, 12));
                subRec.Billing_Type__c = 'Full Prepaid';
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Zuora__Zuora_Id__c ='2c92c0f8535f8de8015364bcf6161d23';
            Test.startTest();
                subRec.Number_of_Copies1__c = '100';
                subRec.Number_of_Copies__c = 100;
                subRec.Qty__c = 20;
            insert subRec;
            
            Date stopReqDate = Date.newInstance(2014, 12, 12);
            subZuoraIdToEarliestDateMap.put(subRec.Zuora__Zuora_Id__c, stopReqDate);
            AdminFeeComputation AFC = new AdminFeeComputation();
            Decimal returnValue = AdminFeeComputation.computeAdminCharge(subRec.id, stopReqDate);
            
            System.AssertEquals(100.00,returnValue);
            Test.stopTest();
    }
    
    static testMethod void testPenaltyChargeOverrideIsAndPenaltyChargeIsNull()
    {
        
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
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
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true; 
            insert con;
            
            Promotion__c promo = TestDataFactory.createPromotion(1)[0];
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
          //promo.Penalty_Charge__c = '100.00';
          //promo.Penalty_Charge_Override__c = 100;
            
            insert promo;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Subscriber_Charge__c = 100.00;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today()+1;
            orderline.End_Date__c = date.today().addDays(3);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Promotion_ID__c = promo.Id;
            insert orderline;
            system.assertNotEquals(null, orderline);  
            
            Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Order_Line_Item_Number__c = orderline.Id;
                subRec.Promotion__c = promo.id;
              //subRec.Penalty_Charge__c = '100.00';
                subRec.Promotion_1__c = promo.id;
                subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
                subRec.Contract_End_Date__c = String.valueOf(date.newInstance(2014, 12, 12));
                subRec.Billing_Type__c = 'Full Prepaid';
                subRec.Zuora__Zuora_Id__c ='2c92c0f8535f8de8015364bcf6161d23';
                subRec.Zuora__CustomerAccount__c = billAcc.Id;  
                subRec.Number_of_Copies1__c = '100';
                subRec.Number_of_Copies__c = 100;
                subRec.Qty__c = 20;
            insert subRec;
            
            Date stopReqDate = Date.newInstance(2014, 12, 12);
            subZuoraIdToEarliestDateMap.put(subRec.Zuora__Zuora_Id__c, stopReqDate);
            AdminFeeComputation AFC = new AdminFeeComputation();
            Decimal returnValue = AdminFeeComputation.computeAdminCharge(subRec.id, stopReqDate);
            
            System.AssertEquals(0,returnValue);
    }
    
    static testMethod void testException(){
        test.startTest();
            try{
                AdminFeeComputation.computeAdminChargeBulk(subZuoraIdToEarliestDateMap);
                AdminFeeComputation.computeAdminCharge(null, date.today());
                
            }
            catch(Exception e){}
        test.stopTest();
    }

}