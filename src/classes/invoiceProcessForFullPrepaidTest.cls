/**
* Class Name: <invoiceProcessForFullPrepaidTest>
* @author: <Patrick Pancho>
* Date: <02/04/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for invoiceProcessForFullPrepaid>
*/
@isTest(SeeAllData=true)
private class invoiceProcessForFullPrepaidTest {
    
    /*
    *Method to test the insert and select of order and zuora_subscription
    */
    static testMethod void testInvoiceProcessForFullPrepaidID() {
      
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        //addressRec.RecordType.Name = 
        insert addressRec;
        
        //Create Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
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
        insert zProduct;
        
        //Create Product Rate Plan
        List<zqu__ProductRatePlan__c> prdRatePlans = TestDataFactory.createProductRatePlan(4);
        for(zqu__ProductRatePlan__c prdRatePlan: prdRatePlans){
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
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
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Informed_Customer__c = TRUE;
        orderRec_0.Sub_Category__c ='Stop Subscription';
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Order_Type__c = 'Start';
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
        insert orderRec_0;
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec_0.Id;
        //orderline.End_Date__c = date.newInstance(2014, 12, 2);//jurna-10-22-2015
        orderline.End_Date__c = date.today()+5;//jurna-10-22-2015
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;  
        orderline.Asia1_Creation_Mode__c = 'Individual';
        orderline.Start_Date__c = date.today().addDays(2);
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
        insert orderline;
        
        //Create Subscriptions
        Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
        subRec.Zuora__Account__c = acc.Id;
        subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec_0.Id;
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
        
        subrec.Order_Line_Item_Number__c = orderline.id;
        subrec.Order_Line_Item_Number_1__c = orderline.id;
        subrec.Subscription_Type_1__c = billAcc.id;
        subrec.Zuora__CustomerAccount__c = billAcc.Id;
        subrec.Term_Length__c = null;
        subRec.Billing_Type__c = null;
        insert subRec;
        
        List<Order__c> orders = TestDataFactory.createOrder(4);
        for( Order__c order: orders)
        {
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Sub_Category__c ='Stop Subscription';
            order.Recipient_Contact__c = con.Id;
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
        orders[1].Delivery_Charge_Type__c = 'C' ;
        orders[2].Delivery_Charge_Type__c = 'L' ;
        orders[3].Delivery_Charge_Type__c = 'S' ;
        insert orders;
        
        System.debug('>>>RECIPIENT TYPE: '+ [SELECT Recipient_Type__c FROM Order__c]);
        System.debug('>>>RecordType: '+ addressRec.RecordType.Name);
        System.debug('>>>RecordTypeId: '+ addressRec.RecordTypeId);

        
        invoiceProcessForFullPrepaid ipffp = new invoiceProcessForFullPrepaid();
        ipffp.callInvoice(new Set<Id>{subRec.id});
        
        test.startTest();
        Id o1 = invoiceProcessForFullPrepaid.getUOM(prdRatePlans, orders[0]);
        Id o2 = invoiceProcessForFullPrepaid.getUOM(prdRatePlans, orders[1]);
        Id o3 = invoiceProcessForFullPrepaid.getUOM(prdRatePlans, orders[2]);
        test.stopTest(); 
        
    }
    /*
    *Method to test the Zuora object
    */
     static testMethod void createPayment(){
         Account acc = new Account();
         invoiceProcessForFullPrepaid inv = new invoiceProcessForFullPrepaid();
         List<Zuora.zObject> zObj = new List<Zuora.zObject>();
         Test.startTest();
         try{
         //kiko 4/14/2015 createPayment method does not specified to this class invoiceProcessForFullPrepaid
          //   invoiceProcessForFullPrepaid.createPayment(zObj); 
         }catch (Exception e){
              System.debug ('Error: ' + e);       
         }
         Test.stopTest();
     }   
    
 }