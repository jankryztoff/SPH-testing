@isTest
private class invoiceProcessForFullPrepaid_bulkTest {
    static void setupData() {
        
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface();  
        insert CustomSettingsDataFactory.createPlannerSched();
    }
    /*
    *Method to test the insert and select of order and zuora_subscription
    */
    static testMethod void testInvoiceProcessForFullPrepaidID() {
        setupData();
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
 
        Id devRecordTypeIdloc = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
        Id devRecordTypeIdint = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        List<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal.Id;
        //addressRec[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        addressRec[0].RecordTypeId = devRecordTypeIdloc;
        //addressRec.RecordType.Name = 
        addressRec[1].Address_Type__c='P';
        addressRec[1].Postal_Code__c = postal.Id;
        //addressRec[1].RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
        addressRec[1].RecordTypeId =devRecordTypeIdint; 
        insert addressRec;
        //System.debug('@@@' + addressRec[1].RecordType.Name);
        //Create Contact
        List<Contact> con = TestDataFactory.createContact(2);
        con[0].Address__c = addressRec[0].Id;
        con[0].AccountId = acc.Id;
        con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        
        con[1].Address__c = addressRec[1].Id;
        con[1].AccountId = acc.Id;
        con[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[1].Recipient_Indicator__c = true;
        //insert con;
        
        //Create Billing Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Name = 'TEST';     
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        insert pack;
        
        //Create zProduct
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductType__c = 'Charge';
        zProduct.ProductSubType__c = 'Delivery';
        zProduct.Name = 'Delivery Charge';
        insert zProduct;
        
        //Create Product Rate Plan
        List<zqu__ProductRatePlan__c> prdRatePlans = TestDataFactory.createProductRatePlan(4);
        for(zqu__ProductRatePlan__c prdRatePlan: prdRatePlans){
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.zqu__Deleted__c = false;
            
        }
        prdRatePlans[0].Name = 'Zero Charge Amount';
        prdRatePlans[1].Name = 'HDB DELIVERY CHARGE';
        prdRatePlans[2].Name = 'APT DELIVERY CHARGE';
        prdRatePlans[3].Name = 'LANDED DELIVERY CHARGE';
        
        insert prdRatePlans;
        
        //Create Product Rate Plan Charge
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlans[0].Id;
        insert prpc;
        
        //Create Package Item
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlans[0].Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        insert pItem;
        
        //Insert Promo
        Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
        promoTmp.Name = 'Promotions';
        promoTmp.Contract_Period__c ='12';
        promoTmp.Penalty_Charge__c = '100';     
        insert promoTmp;
        
        //Create Order
        List<Order__c> orderRec_0 = TestDataFactory.createOrder(2);
        orderRec_0[0].Account__c = acc.Id;
        orderRec_0[0].Informed_Customer__c = TRUE;
        orderRec_0[0].Sub_Category__c ='Stop Subscription';
        orderRec_0[0].Recipient_Contact__c = con[0].Id;
        orderRec_0[0].Order_Type__c = 'Start';
        orderRec_0[0].Status__c = 'Draft';
        orderRec_0[0].Credit_Balance__c = 0;
        orderRec_0[0].Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        orderRec_0[0].Delivery_Charge__c = 0;
        orderRec_0[0].Billing_Contact__c = null;
        orderRec_0[0].Delivery_Charge_Type__c = 'S' ;
        orderRec_0[0].Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orderRec_0[0].Check_Amount__c = 100;
        orderRec_0[0].Check_Issuing_Bank__c = 'BLANK';
        orderRec_0[0].Check_No__c = 'SPACE';
        orderRec_0[0].Check_Dated__c =  date.today();
        orderRec_0[0].Remarks_Check__c =  'TESTTESTTEST';
        orderRec_0[0].Zone_Charge__c = 0;
        orderRec_0[0].Subscriber_Charge__c = 0;
        orderRec_0[0].Vendor_Credit__c = 0;
        orderRec_0[0].Billing_Account__c = billAcc.id;
        orderRec_0[0].Other_Payment_Mode__c = 'Invoice';
        orderRec_0[0].Billing_Type__c = 'Full Prepaid';
        orderRec_0[0].Amount_Paid__c = 1;
        
        orderRec_0[1].Account__c = acc.Id;
        orderRec_0[1].Informed_Customer__c = TRUE;
        orderRec_0[1].Sub_Category__c ='Stop Subscription';
        orderRec_0[1].Recipient_Contact__c = con[1].Id;
        orderRec_0[1].Order_Type__c = 'Start';
        orderRec_0[1].Status__c = 'Draft';
        orderRec_0[1].Credit_Balance__c = 0;
        orderRec_0[1].Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        orderRec_0[1].Delivery_Charge__c = 0;
        orderRec_0[1].Billing_Contact__c = null;
        orderRec_0[1].Delivery_Charge_Type__c = 'S' ;
        orderRec_0[1].Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        //orderRec_0[1].Check_Amount__c = 100;
        orderRec_0[1].Check_Issuing_Bank__c = 'BLANK';
        orderRec_0[1].Check_No__c = 'SPACE';
        orderRec_0[1].Check_Dated__c =  date.today();
        orderRec_0[1].Remarks_Check__c =  'TESTTESTTEST';
        orderRec_0[1].Zone_Charge__c = 0;
        orderRec_0[1].Subscriber_Charge__c = 0;
        orderRec_0[1].Vendor_Credit__c = 0;
        orderRec_0[1].Billing_Account__c = billAcc.id;
        orderRec_0[1].Other_Payment_Mode__c = 'Invoice';
        orderRec_0[1].Billing_Type__c = 'Full Prepaid';
        insert orderRec_0;
        //System.debug('!!!' + orderRec_0[1].Recipient_Type__c);
        //Create Order Line Item
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(2);
        orderline[0].Order__c = orderRec_0[0].Id;
        //orderline[0].End_Date__c = date.newInstance(2014, 12, 2);//jurna-10-22-2015
        orderline[0].End_Date__c = date.today()+5;//jurna-10-22-2015
        orderline[0].Main_Package_ID__c = pack.Id;
        orderline[0].Term_Length__c = 0;
        orderline[0].Main_Package_Period__c = 0;  
        orderline[0].Asia1_Creation_Mode__c = 'Individual';
        orderline[0].Start_Date__c = date.today().addDays(2);
        orderline[0].Term_is_discussed__c = false;
        orderline[0].Is_Digital__c = TRUE;
        orderline[0].Promotion_ID__c = promoTmp.id;
        orderline[0].Penalty_Charge__c = 100;
        orderline[0].New_Contract_Period__c = 1;
        orderline[0].Main_Package_Subscription_Rate__c = 100;
        orderline[0].Qty__c = 1;
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Main_Package_Frequency__c = 'Default';
        orderline[0].Main_Package_Sub_Type__c = 'Single';
        orderline[0].Main_Package_Type__c = 'Base';
        orderline[0].Subscribed_as__c = 'New Buy';
        
        orderline[1].Order__c = orderRec_0[1].Id;
        //orderline[0].End_Date__c = date.newInstance(2014, 12, 2);//jurna-10-22-2015
        orderline[1].End_Date__c = date.today()+5;//jurna-10-22-2015
        orderline[1].Main_Package_ID__c = pack.Id;
        orderline[1].Term_Length__c = 0;
        orderline[1].Main_Package_Period__c = 0;  
        orderline[1].Asia1_Creation_Mode__c = 'Individual';
        orderline[1].Start_Date__c = date.today().addDays(2);
        orderline[1].Term_is_discussed__c = false;
        orderline[1].Is_Digital__c = TRUE;
        orderline[1].Promotion_ID__c = promoTmp.id;
        orderline[1].Penalty_Charge__c = 100;
        orderline[1].New_Contract_Period__c = 1;
        orderline[1].Main_Package_Subscription_Rate__c = 100;
        orderline[1].Qty__c = 1;
        orderline[1].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[1].Main_Package_Frequency__c = 'Default';
        orderline[1].Main_Package_Sub_Type__c = 'Single';
        orderline[1].Main_Package_Type__c = 'Base';
        orderline[1].Subscribed_as__c = 'New Buy';
        insert orderline;
        
        //Create Subscriptions
        List<Zuora__Subscription__c> subRec = TestDataFactory.createSubscription(2);
        subRec[0].Zuora__Account__c = acc.Id;
        subRec[0].Zuora__SubscriptionEndDate__c = date.today().addYears(12);
        subRec[0].Zuora__SubscriptionStartDate__c = date.today();
        subRec[0].Subscriber_Contact__c = con[0].Id;
        subRec[0].Recipient_Contact__c = con[0].Id;
        subRec[0].Main_Package_1__c = pack.id;
        subRec[0].Zuora__Status__c = 'Active';
        subRec[0].Order_Number__c = orderRec_0[0].Id;
        subRec[0].Suppress_Vendor_Start_Notice__c = 'false';
        subRec[0].Supressed_Acknowledgement_Letter__c = 'false';
        subRec[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec[0].Urgent__c = 'false';
        subRec[0].Vendor_Conversion__c = 'false';
        subRec[0].Charity__c = 'false';
        subRec[0].Legacy_Create_Date__c = 'date';
        subRec[0].Legacy_Create_By__c = 'a'; 
        subRec[0].Legacy_Update_By__c = 'a';
        subRec[0].Legacy_Subscription_ID__c = 'a';
        subRec[0].Legacy_Update_Date__c = 'a';
        subRec[0].Legacy_Update_By__c = 'a';
        subRec[0].Legacy_Subscription_ID__c = 'a';
        
        subrec[0].Order_Line_Item_Number__c = orderline[0].id;
        subrec[0].Order_Line_Item_Number_1__c = orderline[0].id;
        subrec[0].Subscription_Type_1__c = 'Delivery';
        subrec[0].Subscription_Type__c = 'Delivery';
        subrec[0].Zuora__CustomerAccount__c = billAcc.Id;
        subrec[0].Term_Length__c = null;
        subRec[0].Billing_Type__c = 'Full Prepaid';
        
        subRec[1].Zuora__Account__c = acc.Id;
        subRec[1].Zuora__SubscriptionEndDate__c = date.today().addYears(12);
        subRec[1].Zuora__SubscriptionStartDate__c = date.today();
        subRec[1].Subscriber_Contact__c = con[1].Id;
        subRec[1].Recipient_Contact__c = con[1].Id;
        subRec[1].Main_Package_1__c = pack.id;
        subRec[1].Zuora__Status__c = 'Active';
        subRec[1].Order_Number__c = orderRec_0[1].Id;
        subRec[1].Suppress_Vendor_Start_Notice__c = 'false';
        subRec[1].Supressed_Acknowledgement_Letter__c = 'false';
        subRec[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec[1].Urgent__c = 'false';
        subRec[1].Vendor_Conversion__c = 'false';
        subRec[1].Charity__c = 'false';
        subRec[1].Legacy_Create_Date__c = 'date';
        subRec[1].Legacy_Create_By__c = 'a'; 
        subRec[1].Legacy_Update_By__c = 'a';
        subRec[1].Legacy_Subscription_ID__c = 'a';
        subRec[1].Legacy_Update_Date__c = 'a';
        subRec[1].Legacy_Update_By__c = 'a';
        subRec[1].Legacy_Subscription_ID__c = 'a';
        
        subrec[1].Order_Line_Item_Number__c = orderline[1].id;
        subrec[1].Order_Line_Item_Number_1__c = orderline[1].id;
        subrec[1].Subscription_Type_1__c = 'Postage';
        subrec[1].Subscription_Type__c = 'Postage';
        subrec[1].Zuora__CustomerAccount__c = billAcc.Id;
        subrec[1].Term_Length__c = null;
        subRec[1].Billing_Type__c = 'Full Prepaid';
        insert subRec;
        
        List<Order__c> orders = TestDataFactory.createOrder(8);
        for( Order__c order: orders)
        {
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Sub_Category__c ='Stop Subscription';
            //order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Start';
            order.Status__c = 'Draft';
            order.Credit_Balance__c = 0;
            order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
            order.Delivery_Charge__c = 0;
            order.Billing_Contact__c = null;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Check_Amount__c = 100;
            order.Check_Issuing_Bank__c = 'BLANK';
            order.Check_No__c = 'SPACE';
            order.Check_Dated__c =  date.today();
            order.Remarks_Check__c =  'TESTTESTTEST';
            order.Zone_Charge__c = 0;
            order.Subscriber_Charge__c = 0;
            order.Vendor_Credit__c = 0;
            order.Billing_Account__c = billAcc.id;
            order.Other_Payment_Mode__c = 'Invoice'; 
            order.Billing_Type__c = 'Full Prepaid';
            //order.Recipient_Type__c = ConstantsSLB.getKeyId('AddLocal');
        }
        orders[0].Delivery_Charge_Type__c = 'H' ;
        orders[0].Recipient_Contact__c = con[0].Id;
        orders[1].Delivery_Charge_Type__c = 'C' ;
        orders[2].Delivery_Charge_Type__c = 'L' ;
        orders[2].Recipient_Contact__c = con[1].Id;
        orders[3].Delivery_Charge_Type__c = 'S' ;
        orders[4].Delivery_Charge_Type__c = 'L' ;
        orders[4].Recipient_Contact__c = con[0].Id;
        orders[5].Delivery_Charge_Type__c = 'C' ;
        orders[5].Recipient_Contact__c = con[0].Id;
        orders[6].Delivery_Charge_Type__c = 'S' ;
        orders[6].Recipient_Contact__c = con[0].Id;
        insert orders;
        
        System.debug('>>>RECIPIENT TYPE: '+ [SELECT Recipient_Type__c FROM Order__c]);
        //System.debug('>>>RecordType: '+ addressRec.RecordType.Name);
        //System.debug('>>>RecordTypeId: '+ addressRec.RecordTypeId);

        
        invoiceProcessForFullPrepaid_bulk ipffpb = new invoiceProcessForFullPrepaid_bulk();
        ipffpb.callInvoice(new Set<Id>{subRec[0].id, subRec[1].id, null});
        
        test.startTest();
        Id o1 = invoiceProcessForFullPrepaid.getUOM(prdRatePlans, orders[0]);
        Id o2 = invoiceProcessForFullPrepaid.getUOM(prdRatePlans, orders[1]);
        Id o3 = invoiceProcessForFullPrepaid.getUOM(prdRatePlans, orders[2]);
        test.stopTest(); 
        
        
    }
    
   
    
 }