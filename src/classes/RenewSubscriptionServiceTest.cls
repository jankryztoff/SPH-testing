/*
* Class Name: <RenewSubscriptionServiceTest>
* @author: Reszel Garrie Pineda
* Date: 2/26/2015
* Modified By: Christian C. Coquilla
* Modified Date: 6/19/2015
* Requirement/Project Name: <SPH>
* @description: Test class for RenewSubscriptionService
*/
@isTest (seeAllData = false)
private class RenewSubscriptionServiceTest {
    
    @testSetup
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface();                 
        insert CustomSettingsDataFactory.createPlannerSched();
    }
    
    public class RenewSubscriptionServiceResponse {
        String svc_status;
        String error_code;
        String error_message = '';
        String orderid;
        String debug = '';
    }
    
    public class RenewSubscriptionServiceRequest {
        String subscriptionId;
        String subscriberId;
        String packageCode;
        String billingAccountNumber;
        String paymentMethodId;
        String subscriptionEndDate;
        String subscriptionStartDate;   
        String contractEndDate;  
        List<String> giftCode;
        String paypalBAID;
        String paypalEmail;
     
    }
    
    static testMethod void testProcessRequest01() {
        //defaultCustomSetting();
        
        RenewSubscriptionService.RenewSubscriptionServiceRequest request = 
                new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        
        
        RenewSubscriptionService.RenewSubscriptionServiceResponse res = RenewSubscriptionService.processRequest(request);
        
        System.assertNotEquals(null, res, 'This should not return to null Since this contains Error Information.');
    }
    
    static testmethod void testisValidTrue1(){
        //defaultCustomSetting();
    
            //test data creation
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'TEST';
            acc.NRIC__c = 'T1234567R';
            
            insert acc;
            
            Promotion__c promo = new Promotion__c();
            promo.Name = 'Promotion';
            promo.Promotion_Code__c = 'yasyd97';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(1);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            promo.Penalty_Charge__c = '100';
            promo.Penalty_Charge_Override__c = 500.00;
            insert promo;
            
            //Package__c pack = new Package__c();
            Package__c pack = TestDataFactory.createPackage(1)[0];      
            pack.Billing_Type__c = 'Full Prepaid';        
            pack.Effective_End_Date__c = date.today().addDays(31);
            pack.Effective_Start_Date__c = date.today();
            pack.Subscription_Period__c = '12';
            pack.Package_Type__c = 'Discount';
            pack.Package_Sub_Type__c = 'Tiered';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
            promopack.Promotion__c = promo.id;
            promopack.Package_Name__c = pack.id;
            insert promopack;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'Product SKU';
            zProduct.ProductType__c = 'Magazine';
            insert zProduct;

            //START KINGSLEY
            Billing_Batch__c billingBatch = new Billing_Batch__c();
                billingBatch.Next_Batch_Number__c   = 14;
                billingBatch.Batch__c               = '13,14,15';
                billingBatch.Name                   = 'Full Prepaid';
            insert billingBatch;

            //END KINGSLEY
            //
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__Credit_Balance__c = 50000.00;
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
            database.insert(con);
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            insert con1;            
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            order.Category__c = 'Subscription Request';
            order.Billing_Type__c = 'Full Prepaid';
            order.Eligible_for_Retention__c = TRUE;
            order.Informed_Customer__c = TRUE;
            order.Sub_Category__c ='Stop Subscription';
            order.Recipient_Contact__c = con.Id;
            order.Status__c = GlobalVariableClass.STATUS_DRAFT;
            order.Check_Amount__c = 100;
            order.Check_Issuing_Bank__c = 'BLANK';
            order.Check_No__c = 'SPACE';
            order.Check_Dated__c = date.today();
            order.Remarks_Check__c = 'TESTTESTTEST';     
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Check';
            order.Billing_Account__c = billAcc.id;     
            order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            order.Credit_Balance__c = 0;
            order.Delivery_Charge_Type__c = 'S';
            order.Subscriber_Charge__c = 2000.00;
            order.Vendor_Credit__c = 10000.00;
            order.Credit_Balance__c = 20000.00;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Billing_Contact__c= con1.id;
            order.Order_Type__c = 'Renewal';
            insert order;
            
            
            Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
            subRecord.Zuora__Account__c = acc.Id;
            subRecord.Zuora__CustomerAccount__c = billAcc.id; 
            subRecord.Number_of_Copies1__c = '2';      
            subRecord.Order_Number_1__c = order.id;
            subRecord.Subscriber_Contact__c = con.Id;
            subRecord.Recipient_Contact__c = con.Id;
            subRecord.Term_Length__c = 1.00;
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
            subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
            subRecord.Zuora__SubscriptionStartDate__c = date.today();
            //subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2015, 12, 02);
            subRecord.Zuora__SubscriptionEndDate__c = date.today().addMonths(Integer.ValueOf(pack.Subscription_Period__c));
            subRecord.Contract_End_Date_1__c = date.today().addDays(10);
            subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
            subRecord.Main_Package_1__c = pack.id;        
            subRecord.Subscription_Type__c = 'Publication';
            subRecord.Subscription_Type_1__c = 'Publication';
            subRecord.Promotion_1__c = promo.id;
            subRecord.Postage_Charge__c = 200;
            //subRecord.Grace_Period_Subscription__c = subRecord.id;
            subRecord.Zuora__SubscriptionStartDate__c = date.today();
            subRecord.Term_Length1__c = '1.3';
           insert subRecord;
    
            Product_Family__c prodFamily = new Product_Family__c();
            prodFamily.Product_Family__c = 'CODEFAMILY2424';
            prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
            insert prodFamily;
                    
            List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
            for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
                spc.Name = 'Sub Product Charge Test';
                spc.Zuora__Subscription__c = subRecord.id;
                spc.Zuora__RatePlanName__c = 'Sample Rate'; 
                spc.Zuora__ProductSKU__c = 'Product SKU'; 
            }
            insert subProductCharge;
                          
            List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(2);
            productRatePlan[0].zqu__ZProduct__c = zProduct.Id;
            productRatePlan[0].RatePlanType__c = 'Bill Plan';
            productRatePlan[1].zqu__ZProduct__c = zProduct.Id;
            productRatePlan[1].RatePlanType__c = 'Discount';
            insert productRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(2);
            productRatePlanCharge[0].zqu__ProductRatePlan__c = productRatePlan[0].Id;
            productRatePlanCharge[1].zqu__ProductRatePlan__c = productRatePlan[1].Id;        
            insert productRatePlanCharge;        
                    
            Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            pItem.Package__c = pack.Id;
            pItem.Product_Rate_Plan__c = productRatePlan[0].Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            insert pItem;
            
            Package_Item__c pItemd = TestDataFactory.createPackageItem(1, 'Discount')[0];
            pItemd.Package__c = pack.Id;
            pItemd.Product_Rate_Plan__c = productRatePlan[1].Id;
            pItemd.Duration_in_months__c = '3';
            pItemd.Effective_Start_Month__c = '3';
            insert pItemd;
            
            order.Subscription__c = subRecord.id;
            order.Base_Subscription__c= subRecord.id;
            update order;
            
            //date SubscriptionStartDate = [SELECT Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c
             //                           WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionStartDate__c;
                                        
            date SubscriptionStartDate = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c
                                        WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionEndDate__c;
           
            //date SubscriptionEndDate = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c
            //                            WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionEndDate__c;
            date SubscriptionEndDate = SubscriptionStartDate.addMonths(Integer.ValueOf(pack.Subscription_Period__c));
            
            System.AssertEquals(true, SubscriptionEndDate <> null);
            
            //System.AssertEquals(date.today(), SubscriptionStartDate);
            //System.assertEquals((date.today()), SubscriptionEndDate);
            
            Test.startTest();
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];    
            oli.Earliest_Start_Date__c = null;
            oli.Start_Date__c = SubscriptionStartDate+1;   
            oli.End_Date__c = SubscriptionEndDate; 
            oli.Fee_Waiver__c = TRUE;
            oli.Order__c = order.id;
            oli.Main_Package_ID__c = pack.id;
            oli.Main_Package_Period__c = 1;
            oli.Qty__c = 1;
            oli.Term_Length__c = 1;
            oli.Main_Package_Billing_Type__c = 'Full Prepaid';
            oli.Main_Package_Type__c = 'Base';
            oli.Main_Package_Frequency__c = 'Default';
            oli.Delivered_By__c = 'None';
            //oli.Promotion_ID__c = promo.id;//
            //oli.Addon_Package__c = pack.id;
            oli.Term_is_discussed__c = TRUE;
            oli.Is_Digital__c = TRUE;
            oli.Delivered_By__c = 'Mailing Agent';
            insert oli;
            //end of test data creation
            
            //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c);
            RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
            
            subRecord.Zuora__SubscriptionEndDate__c = null;
            oli.Start_Date__c = null;        
            oli.End_Date__c = null;
            //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c);
            //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/RenewSubscriptionService/*';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            
            RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
            rssr.subscriptionId = '' +subRecord.id;
            rssr.subscriberId = '' +subRecord.id;
            //rssr.subscriberId = '30075166';
            rssr.billingAccountNumber = '' + billAcc.id;
            
             
            RenewSubscriptionService.getSubscription(String.valueOf(subRecord.id));
            RenewSubscriptionService.getOrder(String.valueOf(order.Id));
            RenewSubscriptionService.getOrderLineItem(String.valueOf(oli.Id));
            String newString = RenewSubscriptionService.getRenewalPackageCode(pack);
            RenewSubscriptionService.getRenewalPackageCode(pack);
            RenewSubscriptionService.getBillingAccount(String.valueOf(subRecord.Zuora__Zuora_Id__c));
            //RenewSubscriptionService.getAccount(String.valueOf(acc.id));                                                     
            RenewSubscriptionService.getRecipientContact(con.id);      
                
            RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
            String jsonStr = JSON.serialize(rssr);
            esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
            RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
    
            Test.stopTest();
            
    }
        
    static testmethod void testisValidTrue2(){
        //defaultCustomSetting();
        
                //test data creation
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = '1234';
                insert postal;
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.Name = 'TEST';
                acc.NRIC__c = 'T1234567R';
                acc.Generate_Account_Number__c = true;
                insert acc;
                
                Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc2.Name = 'TEST';
                acc2.NRIC__c = 'T1234567R';
                acc2.Generate_Account_Number__c = true;
                insert acc2;
                
                Promotion__c promo = new Promotion__c();
                promo.Name = 'Promotion';
                promo.Promotion_Code__c = 'yasyd97';
                promo.Effective_Start_Date__c = date.today();
                promo.Effective_End_Date__c = date.today().addDays(1);
                promo.Contract__c = 'Yes';
                promo.Contract_Period__c = '2';
                promo.Penalty_Charge__c = '100';
                promo.Penalty_Charge_Override__c = 500.00;
                insert promo;
                
                //Package__c pack = new Package__c();
                Package__c pack = TestDataFactory.createPackage(1)[0];      
                pack.Billing_Type__c = 'Full Prepaid';        
                pack.Effective_End_Date__c = date.today()+1;
                pack.Effective_Start_Date__c = date.today();
                pack.Subscription_Period__c = '12';
                pack.Package_Type__c = 'Discount';
                pack.Package_Sub_Type__c = 'Tiered';
                pack.Package_Code__c = 'afds132';
                insert pack;
                
                Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
                promopack.Promotion__c = promo.id;
                promopack.Package_Name__c = pack.id;
                insert promopack;
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                zProduct.zqu__SKU__c = 'Product SKU';
                zProduct.ProductType__c = 'Magazine';
                insert zProduct;
                   
                //START KINGSLEY
                Billing_Batch__c billingBatch = new Billing_Batch__c();
                    billingBatch.Next_Batch_Number__c   = 14;
                    billingBatch.Batch__c               = '13,14,15';
                    billingBatch.Name                   = 'Full Prepaid';
                insert billingBatch;

                //END KINGSLEY
                //
                     
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__Credit_Balance__c = 50000.00;
                //billAcc.Zuora__Default_Payment_Method__c = payMet1.id;
                billAcc.Zuora__Zuora_Id__c = '63gf45';
                insert billAcc;
                
                Zuora__PaymentMethod__c payMet = new Zuora__PaymentMethod__c();
                payMet.Zuora__BillingAccount__c = billAcc.id;
                payMet.Zuora__External_Id__c = '00dg8';
                insert payMet;
            
                billAcc.Zuora__Default_Payment_Method__c = payMet.id;
                update billAcc;
                
              //subscription.Zuora__CustomerAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c == null)  
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
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
                insert con1;            
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
                order.Category__c = 'Subscription Request';
                order.Billing_Type__c = 'Full Prepaid';
                order.Eligible_for_Retention__c = TRUE;
                order.Informed_Customer__c = TRUE;
                order.Sub_Category__c ='Stop Subscription';
                order.Recipient_Contact__c = con.Id;
                order.Status__c = GlobalVariableClass.STATUS_DRAFT;
                order.Check_Amount__c = 100;
                order.Check_Issuing_Bank__c = 'BLANK';
                order.Check_No__c = 'SPACE';
                order.Check_Dated__c = date.today();
                order.Remarks_Check__c = 'TESTTESTTEST';     
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Check';
                order.Billing_Account__c = billAcc.id;     
                order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
                order.Credit_Balance__c = 0;
                order.Delivery_Charge_Type__c = 'S';
                order.Subscriber_Charge__c = 2000.00;
                order.Vendor_Credit__c = 10000.00;
                order.Credit_Balance__c = 20000.00;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Billing_Contact__c= con1.id;
                //order.Order_Type__c = 'Renewal';
                insert order;
                
                /*FROM Zuora__Subscription__c WHERE 
                    Zuora__Zuora_Id__c = :subscriptionId AND             -OK
                    Status_Formula__c = 'Active' AND                     -OK
                    Main_Package_1__r.Effective_End_Date__c >= :Date.Today() AND    
                    Main_Package_1__r.Effective_Start_Date__c <= :Date.Today()*/
                Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
                subRecord.Zuora__Account__c = acc.Id;
                subRecord.Zuora__CustomerAccount__c = billAcc.id; 
                subRecord.Number_of_Copies1__c = '2';      
                subRecord.Order_Number_1__c = order.id;
                subRecord.Subscriber_Contact__c = con.Id;
                subRecord.Recipient_Contact__c = con.Id;
                subRecord.Term_Length__c = null;
                //subRecord.Main_Package_1__c = pack.id;
                subRecord.Main_Package__c = pack.id;
                //subRecord.Zuora__Status__c = 'Cancelled';
                subRecord.Zuora__Status__c = 'Active';
                subRecord.Suppress_Vendor_Start_Notice__c = 'false';
                subRecord.Supressed_Acknowledgement_Letter__c = 'false';
                subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecord.Urgent__c = 'false';
                subRecord.Vendor_Conversion__c = 'false';
                subRecord.Charity__c = 'false';
                subRecord.Billing_Type__c = 'Full Prepaid';
                subRecord.Bundled_With__c = 'TEST';
               // subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
               // subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
                subRecord.Zuora__SubscriptionStartDate__c = date.today();
                //subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2015, 12, 02);
                //subRecord.Zuora__SubscriptionEndDate__c = date.today().addMonths(Integer.ValueOf(pack.Subscription_Period__c));
                subRecord.Zuora__SubscriptionEndDate__c = date.today()+60;
                subRecord.Contract_End_Date_1__c = date.today().addDays(10);
               // subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
                    
                subRecord.Subscription_Type__c = 'Publication';
                subRecord.Subscription_Type_1__c = 'Publication';
                subRecord.Promotion_1__c = promo.id;
                subRecord.Postage_Charge__c = 200;
                //subRecord.Grace_Period_Subscription__c = subRecord.id;
                subRecord.Zuora__SubscriptionStartDate__c = date.today();
                subRecord.Term_Length1__c = '1.3';  
                
                Account acc2Q = [SELECT Account_Auto_Number__c FROM Account WHERE Id=:acc2.Id];   
                subRecord.Zuora__Zuora_Id__c = acc2Q.Account_Auto_Number__c;
                insert subRecord;
                
                Test.startTest(); 
                /*IF( Zuora__SubscriptionStartDate__c > Zuora__SubscriptionEndDate__c, "Deleted", 
                    IF(Zuora__SubscriptionEndDate__c < TODAY(), IF(Zuora__Status__c = "Cancelled" , "Terminated", "Expired"), 
                        IF(Zuora__SubscriptionStartDate__c > TODAY(), "Future Active", "Active" ) 
                    ) 
                )*/
                System.debug('subRecord.Zuora__Zuora_Id__c' +subRecord.Zuora__Zuora_Id__c);
                System.debug('Status_Formula__c' + subRecord.Status_Formula__c);
                
                System.debug('pack.Effective_End_Date__c' +pack.Effective_End_Date__c);
        
                Product_Family__c prodFamily = new Product_Family__c();
                prodFamily.Product_Family__c = 'CODEFAMILY2424';
                prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
                insert prodFamily;
                        
                List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
                for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
                    spc.Name = 'Sub Product Charge Test';
                    spc.Zuora__Subscription__c = subRecord.id;
                    spc.Zuora__RatePlanName__c = 'Sample Rate'; 
                    spc.Zuora__ProductSKU__c = 'Product SKU'; 
                }
                insert subProductCharge;
                              
                List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(2);
                productRatePlan[0].zqu__ZProduct__c = zProduct.Id;
                productRatePlan[0].RatePlanType__c = 'Bill Plan';
                productRatePlan[1].zqu__ZProduct__c = zProduct.Id;
                productRatePlan[1].RatePlanType__c = 'Discount';
                insert productRatePlan;
                
                List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(2);
                productRatePlanCharge[0].zqu__ProductRatePlan__c = productRatePlan[0].Id;
                productRatePlanCharge[1].zqu__ProductRatePlan__c = productRatePlan[1].Id;        
                insert productRatePlanCharge;        
                        
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = productRatePlan[0].Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                insert pItem;
                
                Package_Item__c pItemd = TestDataFactory.createPackageItem(1, 'Discount')[0];
                pItemd.Package__c = pack.Id;
                pItemd.Product_Rate_Plan__c = productRatePlan[1].Id;
                pItemd.Duration_in_months__c = '3';
                pItemd.Effective_Start_Month__c = '3';
                insert pItemd;
                
                order.Subscription__c = subRecord.id;
                order.Base_Subscription__c= subRecord.id;
                update order;
                
                date SubscriptionStartDate = [SELECT Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c
                                            WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionStartDate__c;
               
                //date SubscriptionEndDate = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c
                //                            WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionEndDate__c;
                date SubscriptionEndDate = SubscriptionStartDate.addMonths(Integer.ValueOf(pack.Subscription_Period__c));
              
                
                Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];    
                oli.Earliest_Start_Date__c = null;
                oli.Start_Date__c = SubscriptionStartDate+1;   
                oli.End_Date__c = SubscriptionEndDate; 
                oli.Fee_Waiver__c = TRUE;
                oli.Order__c = order.id;
                oli.Main_Package_ID__c = pack.id;
                oli.Main_Package_Period__c = 1;
                oli.Qty__c = 1;
                oli.Term_Length__c = 1;
                oli.Main_Package_Billing_Type__c = 'Full Prepaid';
                oli.Main_Package_Type__c = 'Base';
                oli.Main_Package_Frequency__c = 'Default';
                oli.Delivered_By__c = 'None';
                //oli.Promotion_ID__c = promo.id;//
                //oli.Addon_Package__c = pack.id;
                oli.Term_is_discussed__c = TRUE;
                oli.Is_Digital__c = TRUE;
                oli.Delivered_By__c = 'Mailing Agent';
                insert oli;
                //end of test data creation
                
                
                                          
                
                
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c);
                RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
             
                oli.Start_Date__c = null;        
                oli.End_Date__c = null;
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c);
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
                
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                req.requestURI = '/services/apexrest/RenewSubscriptionService/*';
                req.httpMethod = 'POST';
                RestContext.request = req;
                RestContext.response= res;
                
                Account expAccount = [SELECT Id, AccountNumber, Account_Auto_Number__c FROM Account WHERE Id=:acc.id LIMIT 1];
                Zuora__Subscription__c expSub= [SELECT Id, Status_Formula__c FROM Zuora__Subscription__c WHERE Id=:subRecord.id LIMIT 1];
                System.debug('Status_Formula__c' + expSub.Status_Formula__c);
                
                List<String> giftList = new List<String>{'testGift01'};
                
                RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
                rssr.subscriptionId = '' +subRecord.Zuora__Zuora_Id__c;
                rssr.subscriberId = expAccount.Account_Auto_Number__c; //'' + expAccount.AccountNumber; 
                rssr.billingAccountNumber = null;//'63gf45';
                rssr.giftCode = giftList;
                //rssr.paypalBAID = billAcc.Id;
                //rssr.subscriberId = '30075166';
            
                 
                //RenewSubscriptionService.getSubscription(String.valueOf(subRecord.id));
                RenewSubscriptionService.getOrder(String.valueOf(order.Id));
                RenewSubscriptionService.getOrderLineItem(String.valueOf(oli.Id));
                String newString = RenewSubscriptionService.getRenewalPackageCode(pack);
                RenewSubscriptionService.getRenewalPackageCode(pack);
                RenewSubscriptionService.getBillingAccount(String.valueOf(subRecord.Zuora__Zuora_Id__c));
                //RenewSubscriptionService.getAccount(String.valueOf(acc.id));                                                     
                RenewSubscriptionService.getRecipientContact(con.id);      
                    
                RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
                String jsonStr = JSON.serialize(rssr);
                esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
                RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
        
                Test.stopTest();
                
    }//end of testRenewSubscriptionServiceNeg to do
    
    static testmethod void testisValidTrue3(){
        //defaultCustomSetting();
        
                //test data creation
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = '1234';
                insert postal;
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.Name = 'TEST';
                acc.NRIC__c = 'T1234567R';
                acc.Generate_Account_Number__c = true;
                insert acc;
                
                Promotion__c promo = new Promotion__c();
                promo.Name = 'Promotion';
                promo.Promotion_Code__c = 'yasyd97';
                promo.Effective_Start_Date__c = date.today();
                promo.Effective_End_Date__c = date.today().addDays(1);
                promo.Contract__c = 'Yes';
                promo.Contract_Period__c = '2';
                promo.Penalty_Charge__c = '100';
                promo.Penalty_Charge_Override__c = 500.00;
                insert promo;
                
                //Package__c pack = new Package__c();
                Package__c pack = TestDataFactory.createPackage(1)[0];      
                pack.Billing_Type__c = 'Recurring Prepaid';        
                pack.Effective_End_Date__c = date.today()+1;
                pack.Effective_Start_Date__c = date.today();
                pack.Subscription_Period__c = '12';
                pack.Package_Type__c = 'Discount';
                pack.Package_Sub_Type__c = 'Tiered';
                pack.Package_Code__c = 'afds132';
                insert pack;
                
                Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
                promopack.Promotion__c = promo.id;
                promopack.Package_Name__c = pack.id;
                insert promopack;
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                zProduct.zqu__SKU__c = 'Product SKU';
                zProduct.ProductType__c = 'Magazine';
                insert zProduct;
                    
                //START KINGSLEY
                Billing_Batch__c billingBatch = new Billing_Batch__c();
                    billingBatch.Next_Batch_Number__c   = 14;
                    billingBatch.Batch__c               = '13,14,15';
                    billingBatch.Name                   = 'Full Prepaid';
                insert billingBatch;

                //END KINGSLEY
                //
                        
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__Credit_Balance__c = 50000.00;
                //billAcc.Zuora__Default_Payment_Method__c = payMet1.id;
                billAcc.Zuora__Zuora_Id__c = '63gf45';
                insert billAcc;
                
                Zuora__PaymentMethod__c payMet = new Zuora__PaymentMethod__c();
                payMet.Zuora__BillingAccount__c = billAcc.id;
                payMet.Zuora__External_Id__c = '00dg8';
                insert payMet;
            
                billAcc.Zuora__Default_Payment_Method__c = payMet.id;
                update billAcc;
                
              //subscription.Zuora__CustomerAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c == null)  
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
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
                insert con1;            
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
                order.Category__c = 'Subscription Request';
                order.Billing_Type__c = 'Full Prepaid';
                order.Eligible_for_Retention__c = TRUE;
                order.Informed_Customer__c = TRUE;
                order.Sub_Category__c ='Stop Subscription';
                order.Recipient_Contact__c = con.Id;
                order.Status__c = GlobalVariableClass.STATUS_DRAFT;
                order.Check_Amount__c = 100;
                order.Check_Issuing_Bank__c = 'BLANK';
                order.Check_No__c = 'SPACE';
                order.Check_Dated__c = date.today();
                order.Remarks_Check__c = 'TESTTESTTEST';     
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Check';
                order.Billing_Account__c = billAcc.id;     
                order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
                order.Credit_Balance__c = 0;
                order.Delivery_Charge_Type__c = 'S';
                order.Subscriber_Charge__c = 2000.00;
                order.Vendor_Credit__c = 10000.00;
                order.Credit_Balance__c = 20000.00;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Billing_Contact__c= con1.id;
                //order.Order_Type__c = 'Renewal';
                insert order;
                
                /*FROM Zuora__Subscription__c WHERE 
                    Zuora__Zuora_Id__c = :subscriptionId AND             -OK
                    Status_Formula__c = 'Active' AND                     -OK
                    Main_Package_1__r.Effective_End_Date__c >= :Date.Today() AND    
                    Main_Package_1__r.Effective_Start_Date__c <= :Date.Today()*/
                Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
                subRecord.Zuora__Account__c = acc.Id;
                subRecord.Zuora__CustomerAccount__c = billAcc.id; 
                subRecord.Number_of_Copies1__c = '2';      
                subRecord.Order_Number_1__c = order.id;
                subRecord.Subscriber_Contact__c = con.Id;
                subRecord.Recipient_Contact__c = con.Id;
                subRecord.Term_Length__c = null;
                //subRecord.Main_Package_1__c = pack.id;
                subRecord.Main_Package__c = pack.id;
                subRecord.Zuora__Status__c = 'Cancelled';
                subRecord.Suppress_Vendor_Start_Notice__c = 'false';
                subRecord.Supressed_Acknowledgement_Letter__c = 'false';
                subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecord.Urgent__c = 'false';
                subRecord.Vendor_Conversion__c = 'false';
                subRecord.Charity__c = 'false';
                subRecord.Billing_Type__c = 'Full Prepaid';
                subRecord.Bundled_With__c = 'TEST';
               // subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
               // subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
                subRecord.Zuora__SubscriptionStartDate__c = date.today();
                //subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2015, 12, 02);
                //subRecord.Zuora__SubscriptionEndDate__c = date.today().addMonths(Integer.ValueOf(pack.Subscription_Period__c));
                subRecord.Zuora__SubscriptionEndDate__c = date.today()+60;
                subRecord.Contract_End_Date_1__c = date.today().addDays(10);
               // subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
                    
                subRecord.Subscription_Type__c = 'Publication';
                subRecord.Subscription_Type_1__c = 'Publication';
                subRecord.Promotion_1__c = promo.id;
                subRecord.Postage_Charge__c = 200;
                //subRecord.Grace_Period_Subscription__c = subRecord.id;
                insert subRecord;
                
                Test.startTest(); 
                /*IF( Zuora__SubscriptionStartDate__c > Zuora__SubscriptionEndDate__c, "Deleted", 
                    IF(Zuora__SubscriptionEndDate__c < TODAY(), IF(Zuora__Status__c = "Cancelled" , "Terminated", "Expired"), 
                        IF(Zuora__SubscriptionStartDate__c > TODAY(), "Future Active", "Active" ) 
                    ) 
                )*/
                System.debug('subRecord.Zuora__Zuora_Id__c' +subRecord.Zuora__Zuora_Id__c);
                System.debug('Status_Formula__c' + subRecord.Status_Formula__c);
                
                System.debug('pack.Effective_End_Date__c' +pack.Effective_End_Date__c);
        
                Product_Family__c prodFamily = new Product_Family__c();
                prodFamily.Product_Family__c = 'CODEFAMILY2424';
                prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
                insert prodFamily;
                        
                List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
                for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
                    spc.Name = 'Sub Product Charge Test';
                    spc.Zuora__Subscription__c = subRecord.id;
                    spc.Zuora__RatePlanName__c = 'Sample Rate'; 
                    spc.Zuora__ProductSKU__c = 'Product SKU'; 
                }
                insert subProductCharge;
                              
                List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(2);
                productRatePlan[0].zqu__ZProduct__c = zProduct.Id;
                productRatePlan[0].RatePlanType__c = 'Bill Plan';
                productRatePlan[1].zqu__ZProduct__c = zProduct.Id;
                productRatePlan[1].RatePlanType__c = 'Discount';
                insert productRatePlan;
                
                List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(2);
                productRatePlanCharge[0].zqu__ProductRatePlan__c = productRatePlan[0].Id;
                productRatePlanCharge[1].zqu__ProductRatePlan__c = productRatePlan[1].Id;        
                insert productRatePlanCharge;        
                        
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = productRatePlan[0].Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                insert pItem;
                
                Package_Item__c pItemd = TestDataFactory.createPackageItem(1, 'Discount')[0];
                pItemd.Package__c = pack.Id;
                pItemd.Product_Rate_Plan__c = productRatePlan[1].Id;
                pItemd.Duration_in_months__c = '3';
                pItemd.Effective_Start_Month__c = '3';
                insert pItemd;
                
                order.Subscription__c = subRecord.id;
                order.Base_Subscription__c= subRecord.id;
                update order;
                
                date SubscriptionStartDate = [SELECT Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c
                                            WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionStartDate__c;
               
                //date SubscriptionEndDate = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c
                //                            WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionEndDate__c;
                date SubscriptionEndDate = SubscriptionStartDate.addMonths(Integer.ValueOf(pack.Subscription_Period__c));
              
                
                Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];    
                oli.Earliest_Start_Date__c = null;
                oli.Start_Date__c = SubscriptionStartDate+1;   
                oli.End_Date__c = SubscriptionEndDate; 
                oli.Fee_Waiver__c = TRUE;
                oli.Order__c = order.id;
                oli.Main_Package_ID__c = pack.id;
                oli.Main_Package_Period__c = 1;
                oli.Qty__c = 1;
                oli.Term_Length__c = 1;
                oli.Main_Package_Billing_Type__c = 'Full Prepaid';
                oli.Main_Package_Type__c = 'Base';
                oli.Main_Package_Frequency__c = 'Default';
                oli.Delivered_By__c = 'None';
                //oli.Promotion_ID__c = promo.id;//
                //oli.Addon_Package__c = pack.id;
                oli.Term_is_discussed__c = TRUE;
                oli.Is_Digital__c = TRUE;
                oli.Delivered_By__c = 'Mailing Agent';
                insert oli;
                //end of test data creation
                
                
                                          
                
                
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c);
                RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
             
                oli.Start_Date__c = null;        
                oli.End_Date__c = null;
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c);
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
                
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                req.requestURI = '/services/apexrest/RenewSubscriptionService/*';
                req.httpMethod = 'POST';
                RestContext.request = req;
                RestContext.response= res;
                
                Account expAccount = [SELECT Id, AccountNumber, Account_Auto_Number__c FROM Account WHERE Id=:acc.id LIMIT 1];
                Zuora__Subscription__c expSub= [SELECT Id, Status_Formula__c FROM Zuora__Subscription__c WHERE Id=:subRecord.id LIMIT 1];
                System.debug('Status_Formula__c' + expSub.Status_Formula__c);
                
                RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
                rssr.subscriptionId = '' +subRecord.Zuora__Zuora_Id__c;
                //rssr.subscriptionId = '123456';
                rssr.subscriberId = '' + expAccount.AccountNumber; //acc.Account_Auto_Number__c;
                rssr.billingAccountNumber = '63gf45';
                //rssr.subscriberId = '30075166';
            
                 
                //RenewSubscriptionService.getSubscription(String.valueOf(subRecord.id));
                RenewSubscriptionService.getOrder(String.valueOf(order.Id));
                RenewSubscriptionService.getOrderLineItem(String.valueOf(oli.Id));
                String newString = RenewSubscriptionService.getRenewalPackageCode(pack);
                RenewSubscriptionService.getRenewalPackageCode(pack);
                RenewSubscriptionService.getBillingAccount(String.valueOf(subRecord.Zuora__Zuora_Id__c));
                //RenewSubscriptionService.getAccount(String.valueOf(acc.id));                                                     
                RenewSubscriptionService.getRecipientContact(con.id);      
                    
                RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
                String jsonStr = JSON.serialize(rssr);
                esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
                RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
        
                Test.stopTest();
                
    }//end of testRenewSubscriptionServiceNeg to do
    
    static testmethod void testSubscriptionNull(){
        //defaultCustomSetting();
        
                //test data creation
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = '1234';
                insert postal;
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.Name = 'TEST';
                acc.NRIC__c = 'T1234567R';
                acc.Generate_Account_Number__c = true;
                insert acc;
                
                Promotion__c promo = new Promotion__c();
                promo.Name = 'Promotion';
                promo.Promotion_Code__c = 'yasyd97';
                promo.Effective_Start_Date__c = date.today();
                promo.Effective_End_Date__c = date.today().addDays(1);
                promo.Contract__c = 'Yes';
                promo.Contract_Period__c = '2';
                promo.Penalty_Charge__c = '100';
                promo.Penalty_Charge_Override__c = 500.00;
                insert promo;
                
                //Package__c pack = new Package__c();
                Package__c pack = TestDataFactory.createPackage(1)[0];      
                pack.Billing_Type__c = 'Recurring Prepaid';        
                pack.Effective_End_Date__c = date.today()+1;
                pack.Effective_Start_Date__c = date.today();
                pack.Subscription_Period__c = '12';
                pack.Package_Type__c = 'Discount';
                pack.Package_Sub_Type__c = 'Tiered';
                pack.Package_Code__c = 'afds132';
                insert pack;
                
                Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
                promopack.Promotion__c = promo.id;
                promopack.Package_Name__c = pack.id;
                insert promopack;
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                zProduct.zqu__SKU__c = 'Product SKU';
                zProduct.ProductType__c = 'Magazine';
                insert zProduct;
                  
                //START KINGSLEY
                Billing_Batch__c billingBatch = new Billing_Batch__c();
                    billingBatch.Next_Batch_Number__c   = 14;
                    billingBatch.Batch__c               = '13,14,15';
                    billingBatch.Name                   = 'Full Prepaid';
                insert billingBatch;

                //END KINGSLEY
                //
                      
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__Credit_Balance__c = 50000.00;
                //billAcc.Zuora__Default_Payment_Method__c = payMet1.id;
                billAcc.Zuora__Zuora_Id__c = '63gf45';
                insert billAcc;
                
                Zuora__PaymentMethod__c payMet = new Zuora__PaymentMethod__c();
                payMet.Zuora__BillingAccount__c = billAcc.id;
                payMet.Zuora__External_Id__c = '00dg8';
                insert payMet;
            
                billAcc.Zuora__Default_Payment_Method__c = payMet.id;
                update billAcc;
                
              //subscription.Zuora__CustomerAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c == null)  
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
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
                insert con1;            
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
                order.Category__c = 'Subscription Request';
                order.Billing_Type__c = 'Full Prepaid';
                order.Eligible_for_Retention__c = TRUE;
                order.Informed_Customer__c = TRUE;
                order.Sub_Category__c ='Stop Subscription';
                order.Recipient_Contact__c = con.Id;
                order.Status__c = GlobalVariableClass.STATUS_DRAFT;
                order.Check_Amount__c = 100;
                order.Check_Issuing_Bank__c = 'BLANK';
                order.Check_No__c = 'SPACE';
                order.Check_Dated__c = date.today();
                order.Remarks_Check__c = 'TESTTESTTEST';     
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Check';
                order.Billing_Account__c = billAcc.id;     
                order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
                order.Credit_Balance__c = 0;
                order.Delivery_Charge_Type__c = 'S';
                order.Subscriber_Charge__c = 2000.00;
                order.Vendor_Credit__c = 10000.00;
                order.Credit_Balance__c = 20000.00;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Billing_Contact__c= con1.id;
                //order.Order_Type__c = 'Renewal';
                insert order;
                
                /*FROM Zuora__Subscription__c WHERE 
                    Zuora__Zuora_Id__c = :subscriptionId AND             -OK
                    Status_Formula__c = 'Active' AND                     -OK
                    Main_Package_1__r.Effective_End_Date__c >= :Date.Today() AND    
                    Main_Package_1__r.Effective_Start_Date__c <= :Date.Today()*/
                Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
                subRecord.Zuora__Account__c = acc.Id;
                subRecord.Zuora__CustomerAccount__c = billAcc.id; 
                subRecord.Number_of_Copies1__c = '2';      
                subRecord.Order_Number_1__c = order.id;
                subRecord.Subscriber_Contact__c = con.Id;
                subRecord.Recipient_Contact__c = con.Id;
                subRecord.Term_Length__c = null;
                //subRecord.Main_Package_1__c = pack.id;
                subRecord.Main_Package__c = pack.id;
                subRecord.Zuora__Status__c = 'Cancelled';
                subRecord.Suppress_Vendor_Start_Notice__c = 'false';
                subRecord.Supressed_Acknowledgement_Letter__c = 'false';
                subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecord.Urgent__c = 'false';
                subRecord.Vendor_Conversion__c = 'false';
                subRecord.Charity__c = 'false';
                subRecord.Billing_Type__c = 'Full Prepaid';
                subRecord.Bundled_With__c = 'TEST';
               // subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
               // subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
                subRecord.Zuora__SubscriptionStartDate__c = date.today();
                //subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2015, 12, 02);
                //subRecord.Zuora__SubscriptionEndDate__c = date.today().addMonths(Integer.ValueOf(pack.Subscription_Period__c));
                subRecord.Zuora__SubscriptionEndDate__c = date.today()+60;
                subRecord.Contract_End_Date_1__c = date.today().addDays(10);
               // subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
                    
                subRecord.Subscription_Type__c = 'Publication';
                subRecord.Subscription_Type_1__c = 'Publication';
                subRecord.Promotion_1__c = promo.id;
                subRecord.Postage_Charge__c = 200;
                //subRecord.Grace_Period_Subscription__c = subRecord.id;
                insert subRecord;
                
                Test.startTest(); 
                /*IF( Zuora__SubscriptionStartDate__c > Zuora__SubscriptionEndDate__c, "Deleted", 
                    IF(Zuora__SubscriptionEndDate__c < TODAY(), IF(Zuora__Status__c = "Cancelled" , "Terminated", "Expired"), 
                        IF(Zuora__SubscriptionStartDate__c > TODAY(), "Future Active", "Active" ) 
                    ) 
                )*/
                System.debug('subRecord.Zuora__Zuora_Id__c' +subRecord.Zuora__Zuora_Id__c);
                System.debug('Status_Formula__c' + subRecord.Status_Formula__c);
                
                System.debug('pack.Effective_End_Date__c' +pack.Effective_End_Date__c);
        
                Product_Family__c prodFamily = new Product_Family__c();
                prodFamily.Product_Family__c = 'CODEFAMILY2424';
                prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
                insert prodFamily;
                        
                List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
                for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
                    spc.Name = 'Sub Product Charge Test';
                    spc.Zuora__Subscription__c = subRecord.id;
                    spc.Zuora__RatePlanName__c = 'Sample Rate'; 
                    spc.Zuora__ProductSKU__c = 'Product SKU'; 
                }
                insert subProductCharge;
                              
                List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(2);
                productRatePlan[0].zqu__ZProduct__c = zProduct.Id;
                productRatePlan[0].RatePlanType__c = 'Bill Plan';
                productRatePlan[1].zqu__ZProduct__c = zProduct.Id;
                productRatePlan[1].RatePlanType__c = 'Discount';
                insert productRatePlan;
                
                List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(2);
                productRatePlanCharge[0].zqu__ProductRatePlan__c = productRatePlan[0].Id;
                productRatePlanCharge[1].zqu__ProductRatePlan__c = productRatePlan[1].Id;        
                insert productRatePlanCharge;        
                        
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = productRatePlan[0].Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                insert pItem;
                
                Package_Item__c pItemd = TestDataFactory.createPackageItem(1, 'Discount')[0];
                pItemd.Package__c = pack.Id;
                pItemd.Product_Rate_Plan__c = productRatePlan[1].Id;
                pItemd.Duration_in_months__c = '3';
                pItemd.Effective_Start_Month__c = '3';
                insert pItemd;
                
                order.Subscription__c = subRecord.id;
                order.Base_Subscription__c= subRecord.id;
                update order;
                
                date SubscriptionStartDate = [SELECT Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c
                                            WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionStartDate__c;
               
                //date SubscriptionEndDate = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c
                //                            WHERE Id =: subRecord.Id limit 1][0].Zuora__SubscriptionEndDate__c;
                date SubscriptionEndDate = SubscriptionStartDate.addMonths(Integer.ValueOf(pack.Subscription_Period__c));
              
                
                Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];    
                oli.Earliest_Start_Date__c = null;
                oli.Start_Date__c = SubscriptionStartDate+1;   
                oli.End_Date__c = SubscriptionEndDate; 
                oli.Fee_Waiver__c = TRUE;
                oli.Order__c = order.id;
                oli.Main_Package_ID__c = pack.id;
                oli.Main_Package_Period__c = 1;
                oli.Qty__c = 1;
                oli.Term_Length__c = 1;
                oli.Main_Package_Billing_Type__c = 'Full Prepaid';
                oli.Main_Package_Type__c = 'Base';
                oli.Main_Package_Frequency__c = 'Default';
                oli.Delivered_By__c = 'None';
                //oli.Promotion_ID__c = promo.id;//
                //oli.Addon_Package__c = pack.id;
                oli.Term_is_discussed__c = TRUE;
                oli.Is_Digital__c = TRUE;
                oli.Delivered_By__c = 'Mailing Agent';
                insert oli;
                //end of test data creation
                
                
                                          
                
                
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c);
                RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
             
                oli.Start_Date__c = null;        
                oli.End_Date__c = null;
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c);
                //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
                
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                req.requestURI = '/services/apexrest/RenewSubscriptionService/*';
                req.httpMethod = 'POST';
                RestContext.request = req;
                RestContext.response= res;
                
                Account expAccount = [SELECT Id, AccountNumber, Account_Auto_Number__c FROM Account WHERE Id=:acc.id LIMIT 1];
                Zuora__Subscription__c expSub= [SELECT Id, Status_Formula__c FROM Zuora__Subscription__c WHERE Id=:subRecord.id LIMIT 1];
                System.debug('Status_Formula__c' + expSub.Status_Formula__c);
                
                RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
                //rssr.subscriptionId = '' +subRecord.Zuora__Zuora_Id__c;
                rssr.subscriptionId = '123456';
                rssr.subscriberId = '123456'; //'' + expAccount.AccountNumber; //acc.Account_Auto_Number__c;
                rssr.billingAccountNumber = '63gf45';
                //rssr.subscriberId = '30075166';
            
                 
                //RenewSubscriptionService.getSubscription(String.valueOf(subRecord.id));
                RenewSubscriptionService.getOrder(String.valueOf(order.Id));
                RenewSubscriptionService.getOrderLineItem(String.valueOf(oli.Id));
                String newString = RenewSubscriptionService.getRenewalPackageCode(pack);
                RenewSubscriptionService.getRenewalPackageCode(pack);
                RenewSubscriptionService.getBillingAccount(String.valueOf(subRecord.Zuora__Zuora_Id__c));
                //RenewSubscriptionService.getAccount(String.valueOf(acc.id));                                                     
                RenewSubscriptionService.getRecipientContact(con.id);      
                    
                RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
                String jsonStr = JSON.serialize(rssr);
                esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
                RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
        
                Test.stopTest();
                
    }
    
    /*Added By Charles Lin testProcessRequestMethod()*/
    static testmethod void testProcessRequestMethod(){
        //defaultCustomSetting();
        
        //test data creation
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Generate_Account_Number__c = true;
        insert acc;
        
        /*Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'TEST';
        acc2.NRIC__c = 'T1234567R';
        acc2.Generate_Account_Number__c = true;
        insert acc2;*/
        
        /*Promotion__c promo = new Promotion__c();
        promo.Name = 'Promotion';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge__c = '100';
        promo.Penalty_Charge_Override__c = 500.00;
        insert promo;*/
        
        Package__c pack = TestDataFactory.createPackage(1)[0];      
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today()+1;
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '12';
        pack.Package_Type__c = 'Discount';
        pack.Package_Sub_Type__c = 'Tiered';
        pack.Package_Code__c = 'afds132';
        insert pack;
        
        /*Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        insert promopack;*/
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        zProduct.ProductType__c = 'Magazine';
        insert zProduct;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Zuora__Zuora_Id__c = '63gf45';
        billAcc.Zuora__External_Id__c = '00dg7';
        insert billAcc;
        
        //START KINGSLEY
        Billing_Batch__c billingBatch = new Billing_Batch__c();
            billingBatch.Next_Batch_Number__c   = 14;
            billingBatch.Batch__c               = '13,14,15';
            billingBatch.Name                   = 'Full Prepaid';
        insert billingBatch;

        //END KINGSLEY
        //
        
        Zuora__PaymentMethod__c payMet = new Zuora__PaymentMethod__c();
        payMet.Zuora__BillingAccount__c = billAcc.id;
        payMet.Zuora__External_Id__c = '00dg8';
        insert payMet;
    
        billAcc.Zuora__Default_Payment_Method__c = payMet.id;
        update billAcc;
        
        Zone__c zoneRec = new Zone__c();
        zoneRec.Name = '0';
        insert zoneRec;
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Zone__c = zoneRec.Id;
        zoneProd.Product__c = zProduct.Id;
        zoneProd.Postage_Charge__c = 0.00;
        zoneProd.Effective_Start_Date__c = Date.Today();
        insert zoneProd;
        
        Country__c countryRec = new Country__c();
        countryRec.Name = 'SF';
        countryRec.Country_Name__c = 'San Fo';
        countryRec.Code__c = 'SF';
        countryRec.Zone__c = zoneRec.Id;
        insert countryRec;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Country__c = countryRec.Id;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        /*Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;*/
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Category__c = 'Subscription Request';
        order.Billing_Type__c = 'Full Prepaid';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con.id;
        insert order;
        
        Date SubscriptionStartDate = date.today();
        Date SubscriptionEndDate = SubscriptionStartDate.addMonths(Integer.ValueOf(pack.Subscription_Period__c));
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];    
        oli.Earliest_Start_Date__c = null;
        oli.Start_Date__c = SubscriptionStartDate+1;   
        oli.End_Date__c = SubscriptionEndDate; 
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Term_is_discussed__c = TRUE;
        oli.Is_Digital__c = TRUE;
        oli.Delivered_By__c = 'Mailing Agent';
        insert oli;
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id; 
        subRecord.Number_of_Copies1__c = '2';      
        subRecord.Order_Number__c = order.id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Order_Line_Item_Number__c = oli.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Term_Length__c = null;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Main_Package__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today()+60;
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        //subRecord.Promotion_1__c = promo.id;
        subRecord.Postage_Charge__c = 200;
        subRecord.Term_Length1__c = '1.3';  
        
        //Account acc2Q = [SELECT Account_Auto_Number__c FROM Account WHERE Id=:acc2.Id];   
        subRecord.Zuora__Zuora_Id__c = 'subZuoraId12345';
        insert subRecord;
        
        System.debug('subRecord.Zuora__Zuora_Id__c' +subRecord.Zuora__Zuora_Id__c);
        System.debug('Status_Formula__c' + subRecord.Status_Formula__c);
        System.debug('pack.Effective_End_Date__c' +pack.Effective_End_Date__c);

        /*Product_Family__c prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'CODEFAMILY2424';
        prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
        insert prodFamily;*/
        
        /*List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Name = 'Sub Product Charge Test';
            spc.Zuora__Subscription__c = subRecord.id;
            spc.Zuora__RatePlanName__c = 'Sample Rate'; 
            spc.Zuora__ProductSKU__c = 'Product SKU'; 
        }
        insert subProductCharge;*/
        
        List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
        productRatePlan[0].zqu__ZProduct__c = zProduct.Id;
        productRatePlan[0].RatePlanType__c = 'Bill Plan';
        productRatePlan[0].SubscriptionFrequency__c = '0';
        productRatePlan[0].BillingType__c = 'Full Prepaid';
        productRatePlan[0].BillingPeriod__c = '12';
        /*productRatePlan[1].zqu__ZProduct__c = zProduct.Id;
        productRatePlan[1].RatePlanType__c = 'Discount';
        productRatePlan[1].SubscriptionFrequency__c = '0';
        productRatePlan[1].BillingType__c = 'Full Prepaid';
        productRatePlan[1].BillingPeriod__c = '12';*/
        insert productRatePlan;
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
        productRatePlanCharge[0].zqu__ProductRatePlan__c = productRatePlan[0].Id;
        //productRatePlanCharge[1].zqu__ProductRatePlan__c = productRatePlan[1].Id;        
        insert productRatePlanCharge;
        Test.startTest();
        system.debug('>>>CHA -----Pack Item-----');
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = productRatePlan[0].Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        insert pItem;
        system.debug('>>>CHA -----Testinggggg-----');
        /*Package_Item__c pItemd = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItemd.Package__c = pack.Id;
        pItemd.Product_Rate_Plan__c = productRatePlan[1].Id;
        pItemd.Duration_in_months__c = '3';
        pItemd.Effective_Start_Month__c = '3';
        insert pItemd;*/
        system.debug('>>>CHA -----After PI-----');
        /*order.Subscription__c = subRecord.id;
        order.Base_Subscription__c= subRecord.id;
        update order;*/
        //end of test data creation
        
        //RenewSubscriptionService.repopulateOrderLineItemStartDate(order.Id, oli.Start_Date__c, pack);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RenewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Account expAccount = [SELECT Id, AccountNumber, Account_Auto_Number__c FROM Account WHERE Id=:acc.id LIMIT 1];
        //Zuora__Subscription__c expSub= [SELECT Id, Status_Formula__c FROM Zuora__Subscription__c WHERE Id=:subRecord.id LIMIT 1];
        //System.debug('Status_Formula__c' + expSub.Status_Formula__c);
        
        RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
        rssr.subscriptionId = '' + subRecord.Zuora__Zuora_Id__c;
        rssr.subscriberId = expAccount.Account_Auto_Number__c;
        rssr.billingAccountNumber = '63gf45';
        
        //RenewSubscriptionService.getOrder(String.valueOf(order.Id));
        //RenewSubscriptionService.getOrderLineItem(String.valueOf(oli.Id));
        //String newString = RenewSubscriptionService.getRenewalPackageCode(pack);
        //RenewSubscriptionService.getRenewalPackageCode(pack);
        //RenewSubscriptionService.getBillingAccount(String.valueOf(subRecord.Zuora__Zuora_Id__c));
        //RenewSubscriptionService.getRecipientContact(con.id);      
        system.debug('>>>CHA -----HELLO000-----');
        
        RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(rssr);
        esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        system.debug('>>>CHA +++ limits.getQueries()' + limits.getQueries());
        //Test.startTest(); 
        system.debug('>>>CHA -----HELLO-----');
        //System.assertEquals(100, Limits.getQueries());
        system.debug('>>>CHA limits.getQueries()' + limits.getQueries());
        RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
        Test.stopTest();
    }
    
    /*Added By Charles Lin testAccNull()*/
    static testmethod void testAccNull(){
        
        RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
        rssr.subscriptionId = 'abcd1234';
        rssr.subscriberId = 'abcd1234';
        rssr.billingAccountNumber = 'abcd1234';
        
        RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(rssr);
        esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        
        Test.startTest();
        
        RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
        
        Test.stopTest();
    }
    
    /*Added By Charles Lin testSubNull()*/
    static testmethod void testSubNull(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Generate_Account_Number__c = true;
        insert acc;
        
        Account expAccount = [SELECT Id, AccountNumber, Account_Auto_Number__c FROM Account WHERE Id=:acc.id LIMIT 1];
        
        RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
        rssr.subscriptionId = 'abcd1234';
        rssr.subscriberId = expAccount.Account_Auto_Number__c;
        rssr.billingAccountNumber = 'abcd1234';
        
        RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(rssr);
        esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        
        Test.startTest();
        
        RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
        
        Test.stopTest();
    }
    
    /*Added By Charles Lin testSubAccUnequal()*/
    static testmethod void testSubAccUnequal(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Generate_Account_Number__c = true;
        insert acc;
        
        Account acc1 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc1.Name = 'TESTAcc';
        acc1.NRIC__c = 'T1234567R';
        acc1.Generate_Account_Number__c = true;
        insert acc1;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        insert postal;
        
        //START KINGSLEY
        Billing_Batch__c billingBatch = new Billing_Batch__c();
            billingBatch.Next_Batch_Number__c   = 14;
            billingBatch.Batch__c               = '13,14,15';
            billingBatch.Name                   = 'Full Prepaid';
        insert billingBatch;

        //END KINGSLEY
        //
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Zuora__Zuora_Id__c = '63gf45';
        billAcc.Zuora__External_Id__c = '00dg7';
        insert billAcc;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];      
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today()+1;
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '12';
        pack.Package_Type__c = 'Discount';
        pack.Package_Sub_Type__c = 'Tiered';
        pack.Package_Code__c = 'afds132';
        insert pack;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Category__c = 'Subscription Request';
        order.Billing_Type__c = 'Full Prepaid';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con.id;
        insert order;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];    
        oli.Earliest_Start_Date__c = null;
        oli.Start_Date__c = date.today()+1;   
        oli.End_Date__c = date.today()+60;
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Term_is_discussed__c = TRUE;
        oli.Is_Digital__c = TRUE;
        oli.Delivered_By__c = 'Mailing Agent';
        insert oli;
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;    
        subRecord.Order_Number__c = order.id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Order_Line_Item_Number__c = oli.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Term_Length__c = 12;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Main_Package__c = pack.id;
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today()+60;
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Postage_Charge__c = 200;
        subRecord.Term_Length1__c = '12';
        subRecord.Zuora__Zuora_Id__c = 'subZuoraId12345';
        insert subRecord;
        
        Account expAccount = [SELECT Id, AccountNumber, Account_Auto_Number__c FROM Account WHERE Id=:acc1.id LIMIT 1];
        
        RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
        rssr.subscriptionId = 'subZuoraId12345';
        rssr.subscriberId = expAccount.Account_Auto_Number__c;
        rssr.billingAccountNumber = 'abcd1234';
        
        RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(rssr);
        esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        
        Test.startTest();
        
        RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
        
        Test.stopTest();
    }
    
    /*Added By Charles Lin testWithGraceSub()*/
    static testmethod void testWithGraceSub(){
        
        //test data creation
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Generate_Account_Number__c = true;
        insert acc;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];      
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today()+1;
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '12';
        pack.Package_Type__c = 'Discount';
        pack.Package_Sub_Type__c = 'Tiered';
        pack.Package_Code__c = 'afds132';
        insert pack;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        zProduct.ProductType__c = 'Magazine';
        insert zProduct;
        
        //START KINGSLEY
        Billing_Batch__c billingBatch = new Billing_Batch__c();
            billingBatch.Next_Batch_Number__c   = 14;
            billingBatch.Batch__c               = '13,14,15';
            billingBatch.Name                   = 'Full Prepaid';
        insert billingBatch;

        //END KINGSLEY
        //
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Zuora__Zuora_Id__c = '63gf45';
        billAcc.Zuora__External_Id__c = '00dg7';
        insert billAcc;
        
        Zuora__PaymentMethod__c payMet = new Zuora__PaymentMethod__c();
        payMet.Zuora__BillingAccount__c = billAcc.id;
        //payMet.Zuora__External_Id__c = '00dg8';
        insert payMet;
    
        //billAcc.Zuora__Default_Payment_Method__c = payMet.id;
        //update billAcc;
        
        Zone__c zoneRec = new Zone__c();
        zoneRec.Name = '0';
        insert zoneRec;
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Zone__c = zoneRec.Id;
        zoneProd.Product__c = zProduct.Id;
        zoneProd.Postage_Charge__c = 0.00;
        zoneProd.Effective_Start_Date__c = Date.Today();
        insert zoneProd;
        
        Country__c countryRec = new Country__c();
        countryRec.Name = 'SF';
        countryRec.Country_Name__c = 'San Fo';
        countryRec.Code__c = 'SF';
        countryRec.Zone__c = zoneRec.Id;
        insert countryRec;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Country__c = countryRec.Id;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Category__c = 'Subscription Request';
        order.Billing_Type__c = 'Full Prepaid';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con.id;
        insert order;
        
        Date SubscriptionStartDate = date.today();
        Date SubscriptionEndDate = SubscriptionStartDate.addMonths(Integer.ValueOf(pack.Subscription_Period__c));
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];    
        oli.Earliest_Start_Date__c = null;
        oli.Start_Date__c = SubscriptionStartDate+1;   
        oli.End_Date__c = SubscriptionEndDate; 
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Term_is_discussed__c = TRUE;
        oli.Is_Digital__c = TRUE;
        oli.Delivered_By__c = 'Mailing Agent';
        insert oli;
        
        List<Zuora__Subscription__c> subRecord = TestDataFactory.createSubscription(1);
        subRecord[0].Zuora__Account__c = acc.Id;
        subRecord[0].Zuora__CustomerAccount__c = billAcc.id; 
        subRecord[0].Number_of_Copies1__c = '2';      
        subRecord[0].Order_Number__c = order.id;
        subRecord[0].Order_Number_1__c = order.id;
        subRecord[0].Order_Line_Item_Number__c = oli.id;
        subRecord[0].Subscriber_Contact__c = con.Id;
        subRecord[0].Recipient_Contact__c = con.Id;
        subRecord[0].Term_Length__c = null;
        subRecord[0].Main_Package_1__c = pack.id;
        subRecord[0].Main_Package__c = pack.id;
        subRecord[0].Zuora__Status__c = 'Active';
        subRecord[0].Suppress_Vendor_Start_Notice__c = 'false';
        subRecord[0].Supressed_Acknowledgement_Letter__c = 'false';
        subRecord[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord[0].Urgent__c = 'false';
        subRecord[0].Vendor_Conversion__c = 'false';
        subRecord[0].Charity__c = 'false';
        subRecord[0].Billing_Type__c = 'Full Prepaid';
        subRecord[0].Bundled_With__c = 'TEST';
        subRecord[0].Zuora__SubscriptionStartDate__c = date.today();
        subRecord[0].Zuora__SubscriptionEndDate__c = null;
        subRecord[0].Contract_End_Date_1__c = date.today().addDays(10);
        subRecord[0].Subscription_Type__c = 'Publication';
        subRecord[0].Subscription_Type_1__c = 'Publication';
        subRecord[0].Postage_Charge__c = 200;
        subRecord[0].Term_Length1__c = '1.3';
        subRecord[0].Zuora__Zuora_Id__c = 'subZuoraId12345';
        insert subRecord;
        
        List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
        productRatePlan[0].zqu__ZProduct__c = zProduct.Id;
        productRatePlan[0].RatePlanType__c = 'Bill Plan';
        productRatePlan[0].SubscriptionFrequency__c = '0';
        productRatePlan[0].BillingType__c = 'Full Prepaid';
        productRatePlan[0].BillingPeriod__c = '12';
        insert productRatePlan;
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
        productRatePlanCharge[0].zqu__ProductRatePlan__c = productRatePlan[0].Id;      
        insert productRatePlanCharge;
        Test.startTest();
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = productRatePlan[0].Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        insert pItem;
        //end of test data creation
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RenewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Account expAccount = [SELECT Id, AccountNumber, Account_Auto_Number__c FROM Account WHERE Id=:acc.id LIMIT 1];
        
        RenewSubscriptionServiceRequest rssr = new RenewSubscriptionServiceRequest();
        rssr.subscriptionId = '' + subRecord[0].Zuora__Zuora_Id__c;
        rssr.subscriberId = expAccount.Account_Auto_Number__c;
        rssr.billingAccountNumber = null;
        rssr.paypalBAID = 'ppBA123';
        rssr.paypalEmail  = 'test123@test.com';
        RenewSubscriptionService.isPaypal = true;

        RenewSubscriptionService.RenewSubscriptionServiceRequest esReq2 = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(rssr);
        esReq2 = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        
        //Test.startTest();
        RenewSubscriptionService.RenewSubscriptionServiceResponse response = RenewSubscriptionService.processRequest(esReq2);
        Test.stopTest();
    }
}//end of RenewSubscriptionServiceTest