/**
 * Class Name: <RetentionEligibilityTest>
 * @author: <JhustinPinoy>
 * Date: <10/02/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for RetentionEligibility>
 */

@isTest (Seealldata = TRUE)
private class RetentionEligibility_Test {
    /**
    *  To test RetentionEligibility
    *  @name testRetentionEligibility
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testRetentionEligibility(){
        
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) {
          
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
                       
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
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
            con.Recipient_Indicator__c = TRUE;
            Test.startTest();
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Subscriber_Charge__c = 10.00;
            insert orderRec;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = pack.Id;
            insert orderline;
            system.assertNotEquals(null, orderline);   
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                //subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                subRec.Order_Line_Item_Number__c = orderline.id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Zuora__CustomerAccount__c = billAcc.id;
                subRec.Number_of_Copies__c = 1;
                subRec.Number_of_Copies1__c = '1';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
         
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'PUB1';
            pub.Publication_Type__c = 'N';
            pub.Published_Days__c = 'NNNNYYY';
            insert new List<sObject>{cas, subrecs[0], pub};
           
            Date stpDate = date.newInstance(2020, 12, 30);
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = subRecs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            //Test.startTest();
            insert zSubProdCharge;  
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            insert prdRatePlan;
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
              
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Bundle_Item_No__c = 1;
            }
            //insert pItems; //CLin 25April2016
            
            RetentionEligibility rtnElg = new RetentionEligibility();
            //rtnElg.checkRetentionEligibilty(subRecs[0].Id, stpDate); //CLin 25April2016
            //rtnElg.checkIfDaily(subRecs[0].Id); //CLin 25April2016
            
            Test.stopTest();
        }
    }
    
    /**
    *  To test RetentionEligibility
    *  @name testRetentionEligibility2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testRetentionEligibility2(){
        
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) {
          
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
   
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
            con.Recipient_Indicator__c = TRUE;
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Subscriber_Charge__c = 15;
            insert orderRec;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = pack.Id;
            insert orderline;
            system.assertNotEquals(null, orderline);  
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                subRec.Order_Line_Item_Number__c = orderline.id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Zuora__CustomerAccount__c = billAcc.id;
                subRec.Number_of_Copies__c = 1;
                subRec.Number_of_Copies1__c = '1';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
         
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'PUB1';
            pub.Publication_Type__c = 'N';
            pub.Published_Days__c = 'NYYYYYN';
            insert new List<sObject>{cas, subrecs[0], pub};
           
            Date stpDate = date.newInstance(2020, 12, 30);
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = subRecs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            Test.startTest();
            insert zSubProdCharge;  
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            insert prdRatePlan;
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
            
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Bundle_Item_No__c = 1;
            }
            insert pItems;
            
            RetentionEligibility rtnElg = new RetentionEligibility();
            rtnElg.checkRetentionEligibilty(subRecs[0].Id, stpDate);
            rtnElg.checkIfDaily(subRecs[0].Id);
            
            Test.stopTest();
        }
    }
}