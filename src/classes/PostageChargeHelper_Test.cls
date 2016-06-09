/**
 * Class Name: <PostageChargeHelper_Test>
 * @author: <Jean Cariño>
 * Date: <11/02/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for PostageChargeHelper>
*/

@isTest(SeeAllData = True)
private class PostageChargeHelper_Test{
    public static testMethod void unitTest() {
    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            insert postal;

            Account acct = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
            insert acct;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acct.Id;
            billAcc.Name = 'TESTtest';
            billAcc.Zuora__DefaultPaymentMethod__c ='Other';
            insert billAcc;
            
            Zone__c zoneRec = new Zone__c();
            zoneRec.Name = 'D';
            zoneRec.Zone_Name_External_Id__c = '123';
            insert zoneRec;
            
            Country__c cntry = TestDataFactory.createCountry(1)[0];
            cntry.Account__c = acct.id;
            cntry.Zonal_Code__c = 'D';
            insert cntry;
  
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            addressRec.Country__c = cntry.id;
            insert addressRec;
    
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountID = acct.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;

            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acct.id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id; 
            orderRec.Subscriber_Charge__c = 10.00;
            insert orderRec;

            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';
            pack.Name = 'Test Package';
            pack.Subscription_Period__c = '2';
            insert pack;

            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
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
            
            Order_Line_Item__c orderline1 = TestDataFactory.createOrderLineItem(1)[0];
            orderline1.Order__c = orderRec.Id;
            orderline1.Start_Date__c = date.today().addDays(1);
            orderline1.End_Date__c = date.today().addDays(30);
            orderline1.Main_Package_ID__c = pack.Id;
            orderline1.Term_Length__c = 0;
            orderline1.Main_Package_Period__c = 0;
            orderline1.Earliest_Start_Date__c = date.today();
            orderline1.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1.Terminating_Reason__c = 'Others';
            orderline1.Amount_To_Refund__c = 0;
            orderline1.Admin_Charge__c = 0;
            orderline1.Fee_Waiver__c = FALSE;
            orderline1.Fee_Override__c = TRUE;
            orderline1.Override_Reason__c = 'TEST';
            orderline1.Suppress_Notification_Stop__c = TRUE;
            orderline1.Main_Package_Type__c = 'Base';
            
            List<Order_Line_Item__c> oli = new List<Order_Line_Item__c>();
            oli.add(orderline1);
            insert oli;              
     
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs .Zuora__Account__c = acct.Id;
            subs.Zuora__Zuora_Id__c = '1123';
            subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subs.Subscriber_Contact__c = con.Id;
            subs.Recipient_Contact__c = con.Id;
            subs.Main_Package_1__c = pack.id;
            subs.Zuora__Status__c = 'Active';
            subs.Order_Number__c = orderRec.Id;
            subs.Suppress_Vendor_Start_Notice__c = 'false';
            subs.Supressed_Acknowledgement_Letter__c = 'false';
            subs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subs.Urgent__c = 'false';
            subs.Vendor_Conversion__c = 'false';
            subs.Charity__c = 'false';
            subs.Billing_Type__c = 'Full Prepaid';
            subs.Order_Line_Item_Number__c = orderline.id;
            subs.Subscription_Type_1__c = 'Publication';
            subs.Subscription_Type__c = 'Publication';
            subs.Zuora__Status__c = 'Active';
            subs.Zuora__CustomerAccount__c = billAcc.id;
            insert subs;

            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = subs.id;
            zSubProdCharge[0].Zuora__RatePlanName__c = 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__ProductName__c = 'TEST NAME';
            zSubProdCharge[0].Product_Code__c = 'PUB1';
            zSubProdCharge[0].Zuora__Price__c = 20;
            zSubProdCharge[0].Zuora__BillingPeriod__c = 'Quarterly';
            insert zSubProdCharge;
   
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductCode__c = '123';
            zProduct.zqu__SKU__c = '321';
            zProduct.ProductType__c = 'abc';
            insert zProduct;
   
            Zone_Product__c zoneProd = new Zone_Product__c();
            zoneProd.Zone__c = zoneRec.id;
            zoneProd.Product__c = zProduct.id;
            zoneProd.Postage_Charge__c = 10.00;
            zoneProd.Effective_Start_Date__c = Date.today();
            insert zoneProd;

            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.BillingType__c = 'Full Prepaid';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.BillingPeriod__c = '2';
            insert prdRatePlan;

            Package_Item__c packitem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            packitem.Package__c = pack.id;
            packitem.Product_Rate_Plan__c = prdRatePlan.id;
            insert packitem;

           Map<Id, Id> ordercontact = new Map<Id, Id>();
           ordercontact.put(orderRec.id, con.id);
            Map<Id, Order_Line_Item__c> ordercontact1 = new Map<Id, Order_Line_Item__c>();
            ordercontact1.put(orderline.id,orderline); 
            Set<Id> newset = new Set<Id>();
            newset.add(orderline.id);
            Map<Id, Set<Id>> newMapSet = new Map<Id, Set<Id>>();
            newMapSet.put(orderline.id,newset);
            Map<Id, String> newMapSet1 = new Map<Id, String>();
            newMapSet1.put(orderline.id,'Test');
           /*System.assertEquals([SELECT Name, Id,  Package__r.Id, RecordType.DeveloperName,
                                           Product_Rate_Plan__r.zqu__ZProduct__r.Id
                                           FROM Package_Item__c WHERE Package__c = :pack.Id]+'>>>' + 
                                           [select Id, Address__c, Address__r.Address_Type__c, Zone__c from Contact where Id = :con.Id]
                                           , 
             ' '+[SELECT Zone__r.Name, Product__c, Effective_Start_Date__c FROM Zone_Product__c WHERE Id =:zoneProd.Id][0].Zone__r.Name+ '>>>'
             +PostageChargeHelper.getZProductIDsByPackageIDs(new List<Id> {orderline.Main_Package_ID__c})
             );*/      
        Test.StartTest();
            PostageChargeHelper.getPostageChargeForLineItem(con.id,orderline);
            PostageChargeHelper.getPostageChargesForLineItems(ordercontact,oli);
            try{
            PostageChargeHelper.getPostageChargeForLineItemRenewalLetter(ordercontact1,ordercontact);
            }catch(Exception e){}
            try{
            PostageChargeHelper.getZProductIDsByPackageIDsForRenewalLetter(newMapSet);
            }catch(Exception e){}
            try{
            PostageChargeHelper.calculatePostageChargeRenewalLetter(newMapSet1,newMapSet);
            }catch(Exception e){}
        Test.StopTest();
    }
}