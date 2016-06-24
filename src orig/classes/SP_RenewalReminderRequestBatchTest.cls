/*
 * Class Name: SP_RenewalReminderRequestBatchTest
 * @description: Test class for SP_

RenewalReminderRequestBatch


 */

@isTest(seeAllData = false)
public class SP_RenewalReminderRequestBatchTest {

    // Test Dat
    static Account acc;
    static Contact con;
    static zqu__ZProduct__c zProd;
    static zqu__ProductRatePlan__c zProdRate;
    static Package__c pack;
    static Order__c order;
    static List<Order_Line_Item__c> orderLineItem;
    static List<Zuora__CustomerAccount__c> zuoraCustomerAccount;
    static List<Zuora__Subscription__c> zSub;
    
    
    
    /**
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/24/2015
    */ 
    //static void prepareTestData(){
    static testmethod void testSP_RenewalReminderRequestBatch(){
           
            defaultCustomSetting();
            acc = new Account(
                Name = 'Test Account',
                Email__c = 'sample@email.com',
                Mobile__c = '1234567',
                Renewal_Letter__c = GlobalVariableClass.REFERENCE_HARD_COPY
            );
            
            insert acc;
            
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            //insert con;
            
                   
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            insert pack;
                       
            order = new Order__c();
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Delivery_Charge__c = 100.00;
            order.Credit_Balance__c = 20.00;
            //insert order;
            
            orderLineItem = TestDataFactory.createOrderLineItem(1);
            //orderLineItem[0].Order__c = order.id;
            orderLineItem[0].Main_Package_ID__c = pack.id;
            orderLineItem[0].Start_Date__c = date.today()+2;
            //insert orderLineItem;
            
            zuoraCustomerAccount = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount) {
            obj.Zuora__Account__c = acc.id;
            obj.Billing_Contact__c = con.id;
            obj.Zuora__DefaultPaymentMethod__c = 'Other';
            obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount;
            
            zSub = TestDataFactory.createSubscription(1);
            zSub[0].Subscription_Type_1__c = 'Publication';
            zSUb[0].Subscription_Type__c = 'Publication';
            zSub[0].Zuora__CustomerAccount__c = zuoraCustomerAccount[0].id;
            zSub[0].Zuora__Account__c = acc.id;
            zSub[0].Zuora__Status__c = 'Active';
            zSub[0].Order_Line_Item_Number__c = orderLineItem[0].id;
            zSub[0].Order_Line_Item_Number_1__c = orderLineItem[0].id;
            zSub[0].Recipient_Contact__c = con.id;
            zSub[0].Name = 'S0000000';
            zSub[0].Order_Number__c = order.id;
            zSUb[0].Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub[0].Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub[0].Zuora__AutoRenew__c = False;
            zSub[0].Supressed_Renewal_and_Reminder_Letter_1__c = False;
            insert zSub; 
            
            Product_Family__c prodFam = TestdataFactory.createProductFamily(1)[0];
            prodFam.Product_Family__c = 'BH';
            database.insert(prodFam);
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Test';
            pub.Publication_Code__c ='XY23';
            pub.Platform_Type__c = 'Print';
            pub.Publication_Type__c = 'N';
            pub.Product_Family__c = 'BH';
            pub.Product_Family_Lookup__c = prodFam.id;
            database.insert(pub);
            
            List<zqu__ZProduct__c> zProduct = TestDataFactory.createZProduct(2);
            zProduct[0].ProductCode__c = 'XY23';
            zProduct[0].ProductType__c = 'Product';
            zProduct[0].ProductFamily__c = 'BH';
            
            zProduct[1].ProductCode__c = 'XY23';
            zProduct[1].ProductType__c = 'Product';
            zProduct[1].ProductFamily__c = 'BH';
            database.insert(zProduct);
            
            List<Product_Publication__c> prodPub = TestDataFactory.createProductPublication(2);
            prodPub[0].ZProduct__c = zProduct[0].id;
            prodPub[0].publication_code__c = pub.id;
            
            prodPub[1].ZProduct__c = zProduct[1].id;
            prodPub[1].publication_code__c = pub.id;
            database.insert(prodPub);
            
            zqu__ProductRatePlan__c prdrateplan = TestDataFactory.createProductRatePlan(1)[0];
            prdrateplan.RatePlanType__c = 'Bill Plan';
            prdrateplan.zqu__ZProduct__c = zProduct[0].id;
            database.insert(prdrateplan);
            
            zqu__ProductRatePlanCharge__c prodRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
            prodRatePlanCharge.PublicationCode__c = 'XY23';
            prodRatePlanCharge.zqu__ProductRatePlan__c= prdrateplan.id;
            database.insert(prodRatePlanCharge);
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = prdrateplan.id;
            database.insert(packItem);
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub[0].Id];                    
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub[0].Id);
            Database.BatchableContext BC;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
            SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
            br.execute(BC,zSubList);
            
    }
    static testmethod void testSP_RenewalReminderRequestBatchApril(){
            defaultCustomSetting();
            acc = new Account(
                    Name = 'Test Account',
                    Email__c = 'sample@email.com',
                    Mobile__c = '1234567',
                    Renewal_Letter__c = GlobalVariableClass.REFERENCE_HARD_COPY
             );
            
            insert acc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.Recipient_Indicator__c = true;
            //insert con1;
            
            zqu__ZProduct__c zProd1 = TestDataFactory.createZProduct(1)[0];
            insert zProd1;
            
            zqu__ProductRatePlan__c zProdRate1 = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate1.zqu__ZProduct__c = zProd1.id;
            insert zProdRate1;
            
            Product_Publication__c prodPub1 = TestDataFactory.createProductPublication(1)[0];
            prodPub1.ZProduct__c = zProd1.id;
            insert prodPub1;
            
            Package__c pack1 = TestDataFactory.createPackage(1)[0];
            pack1.Name = 'Pack name';
           pack1.Billing_Type__c = 'Full Prepaid';
           insert pack1;
            
            Package_Item__C packItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem1.Package__c = pack1.id;
            packItem1.Product_Rate_Plan__c = zProdRate1.id;
            insert packItem1;
            
            Order__c order1 = new Order__c();
            order1.Account__c = acc.Id;
            order1.Informed_Customer__c = TRUE;
            order1.Recipient_Contact__c = con1.Id;
            order1.Delivery_Charge__c = 100.00;
            order1.Credit_Balance__c = 20.00;
            //insert order1;
            
            List<Order_Line_Item__c> orderLineItem1 = TestDataFactory.createOrderLineItem(1);
            //orderLineItem1[0].Order__c = order1.id;
            orderLineItem1[0].Main_Package_ID__c = pack1.id;
            orderLineItem1[0].Start_Date__c = date.today()+2;
            //insert orderLineItem1;
            
            List<Zuora__CustomerAccount__c> zuoraCustomerAccount1 = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount1) {
                obj.Zuora__Account__c = acc.id;
                obj.Billing_Contact__c = con1.id;
                obj.Zuora__DefaultPaymentMethod__c = 'Other';
                obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount1;
            
            Zuora__Subscription__c zSub1 = TestDataFactory.createSubscription(1)[0];
            zSub1.Subscription_Type_1__c = 'Publication';
            zSUb1.Subscription_Type__c = 'Publication';
            zSub1.Zuora__CustomerAccount__c = zuoraCustomerAccount1[0].id;
            zSub1.Zuora__Account__c = acc.id;
            zSub1.Zuora__Status__c = 'Active';
            zSub1.Order_Line_Item_Number__c = orderLineItem1[0].id;
            zSub1.Order_Line_Item_Number_1__c = orderLineItem1[0].id;
            zSub1.Recipient_Contact__c = con1.id;
            zSub1.Name = 'S0000000';
            zSub1.Order_Number__c = order1.id;
            zSUb1.Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub1.Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub1.Zuora__AutoRenew__c = False;
            zSub1.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub1.Product_Code__c = 'Pubc'; // jurna
            zSub1.Main_Package_1__c = pack1.id; //jurna   
            zSub1.Main_Package__c = pack1.id; //jurna
            insert zSub1; 
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub1.Id];      
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub1.Id);
           // Database.BatchableContext BC; //jurna removed
            Integer daysBeforeExpiration = 1;
            Date batchRunDate = date.today();
            Integer batchCount = 1;
            String batchCodeParam = 'Final';
            String letterType = SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
            String sessionId = 'Start';
           
           SP_RenewalReminderRequestBatch br  = new SP_RenewalReminderRequestBatch(letterType, daysBeforeExpiration, subsIds, batchRunDate, batchCount, sessionId, batchCodeParam); //jurna removed
             database.executeBatch(br, 200); //jurna
            //SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
           // br.execute(BC,zSubList); //jurna removed
            
    }
    
    //jurna
    static testmethod void testSP_RenewalReminderRequestBatchApril2(){
            defaultCustomSetting();
            acc = new Account(
                    Name = 'Test Account',
                    Email__c = 'sample@email.com',
                    Mobile__c = '1234567',
                    Renewal_Letter__c = GlobalVariableClass.REFERENCE_HARD_COPY
             );
            
            insert acc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.Recipient_Indicator__c = true;
            //insert con1;
            
            zqu__ZProduct__c zProd1 = TestDataFactory.createZProduct(1)[0];
            insert zProd1;
            
            zqu__ProductRatePlan__c zProdRate1 = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate1.zqu__ZProduct__c = zProd1.id;
            insert zProdRate1;
            
            Product_Publication__c prodPub1 = TestDataFactory.createProductPublication(1)[0];
            prodPub1.ZProduct__c = zProd1.id;
            insert prodPub1;
            
            Package__c pack1 = TestDataFactory.createPackage(1)[0];
            pack1.Name = 'Pack name';
           pack1.Billing_Type__c = 'Full Prepaid';
           insert pack1;
            
            Package_Item__C packItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem1.Package__c = pack1.id;
            packItem1.Product_Rate_Plan__c = zProdRate1.id;
            insert packItem1;
            
            Order__c order1 = new Order__c();
            order1.Account__c = acc.Id;
            order1.Informed_Customer__c = TRUE;
            order1.Recipient_Contact__c = con1.Id;
            order1.Delivery_Charge__c = 100.00;
            order1.Credit_Balance__c = 20.00;
            //insert order1;
            
            List<Order_Line_Item__c> orderLineItem1 = TestDataFactory.createOrderLineItem(1);
            //orderLineItem1[0].Order__c = order1.id;
            orderLineItem1[0].Main_Package_ID__c = pack1.id;
            orderLineItem1[0].Start_Date__c = date.today()+2;
            //insert orderLineItem1;
            
            List<Zuora__CustomerAccount__c> zuoraCustomerAccount1 = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount1) {
                obj.Zuora__Account__c = acc.id;
                obj.Billing_Contact__c = con1.id;
                obj.Zuora__DefaultPaymentMethod__c = 'Other';
                obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount1;
            
            Zuora__Subscription__c zSub1 = TestDataFactory.createSubscription(1)[0];
            zSub1.Subscription_Type_1__c = 'Publication';
            zSUb1.Subscription_Type__c = 'Publication';
            zSub1.Zuora__CustomerAccount__c = zuoraCustomerAccount1[0].id;
            zSub1.Zuora__Account__c = acc.id;
            zSub1.Zuora__Status__c = 'Active';
            zSub1.Order_Line_Item_Number__c = orderLineItem1[0].id;
            zSub1.Order_Line_Item_Number_1__c = orderLineItem1[0].id;
            zSub1.Recipient_Contact__c = con1.id;
            zSub1.Name = 'S0000000';
            zSub1.Order_Number__c = order1.id;
            zSUb1.Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub1.Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub1.Zuora__AutoRenew__c = False;
            zSub1.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub1.Product_Code__c = 'Pubc'; // jurna
            zSub1.Main_Package_1__c = pack1.id; //jurna   
            zSub1.Main_Package__c = pack1.id; //jurna
            insert zSub1; 
            
             Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = zuoraCustomerAccount1[0].id;
         letterPrintRequest.Type__c = SP_RenewalReminderConsolidator.LPR_TYPE_DETAIL; 
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest.Status_Email__c = SP_GenerateLetterPrintBatch.newValue;
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(zSub1.ID);
         letterPrintRequest.Language_Medium__c = 'C';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = zuoraCustomerAccount1[0].id;
         letterPrintRequest2.Type__c = SP_RenewalReminderConsolidator.LPR_TYPE_DETAIL; 
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest2.Status_Email__c = SP_GenerateLetterPrintBatch.newValue;
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(zSub1.ID);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub1.Id];      
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub1.Id);
           // Database.BatchableContext BC; //jurna removed
            Integer daysBeforeExpiration = null;
            Date batchRunDate = date.today();
            Integer batchCount = 1;
            String batchCodeParam = 'SP022';
            String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
            String sessionId = 'Start';
           Test.startTest();
           SP_RenewalReminderRequestBatch br  = new SP_RenewalReminderRequestBatch(letterType, daysBeforeExpiration, subsIds, batchRunDate, batchCount, sessionId, batchCodeParam); //jurna removed
             database.executeBatch(br, 200); //jurna
            //SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
           // br.execute(BC,zSubList); //jurna removed
           
            
            
    }
    
    //jurna
    static testmethod void testSP_RenewalReminderRequestBatchApril2B(){
            defaultCustomSetting();
            acc = new Account(
                    Name = 'Test Account',
                    Email__c = 'sample@email.com',
                    Mobile__c = '1234567',
                    Renewal_Letter__c = GlobalVariableClass.REFERENCE_HARD_COPY
             );
            
            insert acc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.Recipient_Indicator__c = true;
            //insert con1;
            
            zqu__ZProduct__c zProd1 = TestDataFactory.createZProduct(1)[0];
            insert zProd1;
            
            zqu__ProductRatePlan__c zProdRate1 = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate1.zqu__ZProduct__c = zProd1.id;
            insert zProdRate1;
            
            Product_Publication__c prodPub1 = TestDataFactory.createProductPublication(1)[0];
            prodPub1.ZProduct__c = zProd1.id;
            insert prodPub1;
            
            Package__c pack1 = TestDataFactory.createPackage(1)[0];
            pack1.Name = 'Pack name';
           pack1.Billing_Type__c = 'Full Prepaid';
           pack1.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BUNDLE;
           insert pack1;
            
            Package_Item__C packItem1 = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
            packItem1.Package__c = pack1.id;
            packItem1.Product_Rate_Plan__c = zProdRate1.id;
            insert packItem1;
            
            Order__c order1 = new Order__c();
            order1.Account__c = acc.Id;
            order1.Informed_Customer__c = TRUE;
            order1.Recipient_Contact__c = con1.Id;
            order1.Delivery_Charge__c = 100.00;
            order1.Credit_Balance__c = 20.00;
            //insert order1;
            
            List<Order_Line_Item__c> orderLineItem1 = TestDataFactory.createOrderLineItem(1);
            //orderLineItem1[0].Order__c = order1.id;
            orderLineItem1[0].Main_Package_ID__c = pack1.id;
            orderLineItem1[0].Start_Date__c = date.today()+2;
            //insert orderLineItem1;
            
            List<Zuora__CustomerAccount__c> zuoraCustomerAccount1 = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount1) {
                obj.Zuora__Account__c = acc.id;
                obj.Billing_Contact__c = con1.id;
                obj.Zuora__DefaultPaymentMethod__c = 'Other';
                obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount1;
            
            Zuora__Subscription__c zSub1 = TestDataFactory.createSubscription(1)[0];
            zSub1.Subscription_Type_1__c = 'Publication';
            zSUb1.Subscription_Type__c = 'Publication';
            zSub1.Zuora__CustomerAccount__c = zuoraCustomerAccount1[0].id;
            zSub1.Zuora__Account__c = acc.id;
            zSub1.Zuora__Status__c = 'Active';
            zSub1.Order_Line_Item_Number__c = orderLineItem1[0].id;
            zSub1.Order_Line_Item_Number_1__c = orderLineItem1[0].id;
            zSub1.Recipient_Contact__c = con1.id;
            zSub1.Name = 'S0000000';
            zSub1.Order_Number__c = order1.id;
            zSUb1.Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub1.Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub1.Zuora__AutoRenew__c = False;
            zSub1.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub1.Product_Code__c = 'Pubc'; // jurna
            zSub1.Main_Package_1__c = pack1.id; //jurna   
            zSub1.Main_Package__c = pack1.id; //jurna
            insert zSub1; 
            
             Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = zuoraCustomerAccount1[0].id;
         letterPrintRequest.Type__c = SP_RenewalReminderConsolidator.LPR_TYPE_DETAIL; 
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest.Status_Email__c = SP_GenerateLetterPrintBatch.newValue;
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(zSub1.ID);
         letterPrintRequest.Language_Medium__c = 'C';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = zuoraCustomerAccount1[0].id;
         letterPrintRequest2.Type__c = SP_RenewalReminderConsolidator.LPR_TYPE_DETAIL; 
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest2.Status_Email__c = SP_GenerateLetterPrintBatch.newValue;
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(zSub1.ID);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub1.Id];      
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub1.Id);
           // Database.BatchableContext BC; //jurna removed
            Integer daysBeforeExpiration = null;
            Date batchRunDate = date.today();
            Integer batchCount = 1;
            String batchCodeParam = 'SP022';
            String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
            String sessionId = 'Start';
           Test.startTest();
           SP_RenewalReminderRequestBatch br  = new SP_RenewalReminderRequestBatch(letterType, daysBeforeExpiration, subsIds, batchRunDate, batchCount, sessionId, batchCodeParam); //jurna removed
             database.executeBatch(br, 200); //jurna
            //SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
           // br.execute(BC,zSubList); //jurna removed
           
            
            
    }
    
    
    //jurna
    static testmethod void testSP_RenewalReminderRequestBatchApril2C(){
            defaultCustomSetting();
            acc = new Account(
                    Name = 'Test Account',
                    Email__c = 'sample@email.com',
                    Mobile__c = '1234567',
                    Renewal_Letter__c = 'email'
             );
            
            insert acc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.Recipient_Indicator__c = true;
            //insert con1;
            
            zqu__ZProduct__c zProd1 = TestDataFactory.createZProduct(1)[0];
            insert zProd1;
            
            zqu__ProductRatePlan__c zProdRate1 = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate1.zqu__ZProduct__c = zProd1.id;
            insert zProdRate1;
            
            Product_Publication__c prodPub1 = TestDataFactory.createProductPublication(1)[0];
            prodPub1.ZProduct__c = zProd1.id;
            insert prodPub1;
            
            Package__c pack1 = TestDataFactory.createPackage(1)[0];
            pack1.Name = 'Pack name';
           pack1.Billing_Type__c = 'Full Prepaid';
           pack1.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BUNDLE;
           insert pack1;
            
            Package_Item__C packItem1 = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
            packItem1.Package__c = pack1.id;
            packItem1.Product_Rate_Plan__c = zProdRate1.id;
            insert packItem1;
            
            Order__c order1 = new Order__c();
            order1.Account__c = acc.Id;
            order1.Informed_Customer__c = TRUE;
            order1.Recipient_Contact__c = con1.Id;
            order1.Delivery_Charge__c = 100.00;
            order1.Credit_Balance__c = 20.00;
            //insert order1;
            
            List<Order_Line_Item__c> orderLineItem1 = TestDataFactory.createOrderLineItem(1);
            //orderLineItem1[0].Order__c = order1.id;
            orderLineItem1[0].Main_Package_ID__c = pack1.id;
            orderLineItem1[0].Start_Date__c = date.today()+2;
            //insert orderLineItem1;
            
            List<Zuora__CustomerAccount__c> zuoraCustomerAccount1 = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount1) {
                obj.Zuora__Account__c = acc.id;
                obj.Billing_Contact__c = con1.id;
                obj.Zuora__DefaultPaymentMethod__c = 'Other';
                obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount1;
            
            Zuora__Subscription__c zSub1 = TestDataFactory.createSubscription(1)[0];
            zSub1.Subscription_Type_1__c = 'Publication';
            zSUb1.Subscription_Type__c = 'Publication';
            zSub1.Zuora__CustomerAccount__c = zuoraCustomerAccount1[0].id;
            zSub1.Zuora__Account__c = acc.id;
            zSub1.Zuora__Status__c = 'Active';
            zSub1.Order_Line_Item_Number__c = orderLineItem1[0].id;
            zSub1.Order_Line_Item_Number_1__c = orderLineItem1[0].id;
            zSub1.Recipient_Contact__c = con1.id;
            zSub1.Name = 'S0000000';
            zSub1.Order_Number__c = order1.id;
            zSUb1.Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub1.Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub1.Zuora__AutoRenew__c = False;
            zSub1.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub1.Product_Code__c = 'Pubc'; // jurna
            zSub1.Main_Package_1__c = pack1.id; //jurna   
            zSub1.Main_Package__c = pack1.id; //jurna
            insert zSub1; 
            
             Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = zuoraCustomerAccount1[0].id;
         letterPrintRequest.Type__c = SP_RenewalReminderConsolidator.LPR_TYPE_DETAIL; 
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest.Status_Email__c = SP_GenerateLetterPrintBatch.newValue;
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(zSub1.ID);
         letterPrintRequest.Language_Medium__c = 'C';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = zuoraCustomerAccount1[0].id;
         letterPrintRequest2.Type__c = SP_RenewalReminderConsolidator.LPR_TYPE_DETAIL; 
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest2.Status_Email__c = SP_GenerateLetterPrintBatch.newValue;
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(zSub1.ID);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub1.Id];      
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub1.Id);
           // Database.BatchableContext BC; //jurna removed
            Integer daysBeforeExpiration = null;
            Date batchRunDate = date.today();
            Integer batchCount = 1;
            String batchCodeParam = 'SP022';
            String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
            String sessionId = 'Start';
           Test.startTest();
           SP_RenewalReminderRequestBatch br  = new SP_RenewalReminderRequestBatch(letterType, daysBeforeExpiration, subsIds, batchRunDate, batchCount, sessionId, batchCodeParam); //jurna removed
             database.executeBatch(br, 200); //jurna
            //SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
           // br.execute(BC,zSubList); //jurna removed
           
            
            
    }
    
    //jurna
    static testmethod void testSP_RenewalReminderRequestBatchApril3(){
            defaultCustomSetting();
            acc = new Account(
                    Name = 'Test Account',
                    Email__c = 'sample@email.com',
                    Mobile__c = '1234567',
                    Renewal_Letter__c = GlobalVariableClass.REFERENCE_HARD_COPY
             );
            
            insert acc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.Recipient_Indicator__c = true;
            //insert con1;
            
            zqu__ZProduct__c zProd1 = TestDataFactory.createZProduct(1)[0];
            insert zProd1;
            
            zqu__ProductRatePlan__c zProdRate1 = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate1.zqu__ZProduct__c = zProd1.id;
            insert zProdRate1;
            
            Product_Publication__c prodPub1 = TestDataFactory.createProductPublication(1)[0];
            prodPub1.ZProduct__c = zProd1.id;
            insert prodPub1;
            
            Package__c pack1 = TestDataFactory.createPackage(1)[0];
            pack1.Name = 'Pack name';
           pack1.Billing_Type__c = 'Full Prepaid';
           insert pack1;
            
            Package_Item__C packItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem1.Package__c = pack1.id;
            packItem1.Product_Rate_Plan__c = zProdRate1.id;
            insert packItem1;
            
            Order__c order1 = new Order__c();
            order1.Account__c = acc.Id;
            order1.Informed_Customer__c = TRUE;
            order1.Recipient_Contact__c = con1.Id;
            order1.Delivery_Charge__c = 100.00;
            order1.Credit_Balance__c = 20.00;
            //insert order1;
            
            List<Order_Line_Item__c> orderLineItem1 = TestDataFactory.createOrderLineItem(1);
            //orderLineItem1[0].Order__c = order1.id;
            orderLineItem1[0].Main_Package_ID__c = pack1.id;
            orderLineItem1[0].Start_Date__c = date.today()+2;
            orderLineItem1[0].Main_Package_Product_Sub_Type__c = 'Magazine';
            //insert orderLineItem1;
            
            List<Zuora__CustomerAccount__c> zuoraCustomerAccount1 = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount1) {
                obj.Zuora__Account__c = acc.id;
                obj.Billing_Contact__c = con1.id;
                obj.Zuora__DefaultPaymentMethod__c = 'Other';
                obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount1;
            
            Zuora__Subscription__c zSub1 = TestDataFactory.createSubscription(1)[0];
            zSub1.Subscription_Type_1__c = 'Publication';
            zSUb1.Subscription_Type__c = 'Publication';
            zSub1.Zuora__CustomerAccount__c = zuoraCustomerAccount1[0].id;
            zSub1.Zuora__Account__c = acc.id;
            zSub1.Zuora__Status__c = 'Active';
            zSub1.Order_Line_Item_Number__c = orderLineItem1[0].id;
            zSub1.Order_Line_Item_Number_1__c = orderLineItem1[0].id;
            zSub1.Recipient_Contact__c = con1.id;
            zSub1.Name = 'S0000000';
            zSub1.Order_Number__c = order1.id;
            zSUb1.Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub1.Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub1.Zuora__AutoRenew__c = False;
            zSub1.Supressed_Renewal_and_Reminder_Letter__c = 'False';
            zSub1.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub1.Product_Code__c = 'Pubc'; // jurna
            zSub1.Main_Package_1__c = pack1.id; //jurna   
            zSub1.Main_Package__c = pack1.id; //jurna
            zSub1.Zuora__TermSettingType__c='TERMED';
            zSub1.is1stPDFGenerated__c = False;
            zSub1.is1stNotifEmailSent__c = FALSE;
            insert zSub1; 
            
           
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub1.Id];      
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub1.Id);
           // Database.BatchableContext BC; //jurna removed
            Integer daysBeforeExpiration = null;
            Date batchRunDate = date.today();
            Integer batchCount = 1;
            String batchCodeParam = 'SP022';
            String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            String sessionId = 'Start';
          // Test.startTest();
           //SP_RenewalReminderRequestBatch br  = new SP_RenewalReminderRequestBatch(letterType, daysBeforeExpiration, subsIds, batchRunDate, batchCount, sessionId, batchCodeParam); //jurna removed
             //database.executeBatch(br, 200); //jurna
            //SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
           // br.execute(BC,zSubList); //jurna removed
           
        //defaultCustomSetting();
        String letType2 = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
                
        Test.startTest();
        //run for firstRenewalReminderForNewspaper
        //SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType2, 1, System.today(), 1, '1000000', 'SP022');
        //ID batchId = Database.executeBatch(renewalBatch, 200);
        
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        //batchJobSched.SFDC_Job_id__c = batchId;
        batchJobSched.Batch_Run_Date__c = System.today();
        batchJobSched.Batch_Code__c='SP022';
        insert batchJobSched;
        Test.stopTest();
            
    }
    
    //jurna
    static testmethod void testSP_RenewalReminderRequestBatchApril4(){
            defaultCustomSetting();
            acc = new Account(
                    Name = 'Test Account',
                    Email__c = 'sample@email.com',
                    Mobile__c = '1234567',
                    Renewal_Letter__c = GlobalVariableClass.REFERENCE_HARD_COPY
             );
            
            insert acc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.Recipient_Indicator__c = true;
            //insert con1;
            
            zqu__ZProduct__c zProd1 = TestDataFactory.createZProduct(1)[0];
            insert zProd1;
            
            zqu__ProductRatePlan__c zProdRate1 = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate1.zqu__ZProduct__c = zProd1.id;
            insert zProdRate1;
            
            Product_Publication__c prodPub1 = TestDataFactory.createProductPublication(1)[0];
            prodPub1.ZProduct__c = zProd1.id;
            insert prodPub1;
            
            Package__c pack1 = TestDataFactory.createPackage(1)[0];
            pack1.Name = 'Pack name';
           pack1.Billing_Type__c = 'Full Prepaid';
           insert pack1;
            
            Package_Item__C packItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem1.Package__c = pack1.id;
            packItem1.Product_Rate_Plan__c = zProdRate1.id;
            insert packItem1;
            
            Order__c order1 = new Order__c();
            order1.Account__c = acc.Id;
            order1.Informed_Customer__c = TRUE;
            order1.Recipient_Contact__c = con1.Id;
            order1.Delivery_Charge__c = 100.00;
            order1.Credit_Balance__c = 20.00;
            //insert order1;
            
            List<Order_Line_Item__c> orderLineItem1 = TestDataFactory.createOrderLineItem(1);
            //orderLineItem1[0].Order__c = order1.id;
            orderLineItem1[0].Main_Package_ID__c = pack1.id;
            orderLineItem1[0].Start_Date__c = date.today()+2;
            orderLineItem1[0].Main_Package_Product_Sub_Type__c = 'Magazine';
            //insert orderLineItem1;
            
            List<Zuora__CustomerAccount__c> zuoraCustomerAccount1 = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount1) {
                obj.Zuora__Account__c = acc.id;
                obj.Billing_Contact__c = con1.id;
                obj.Zuora__DefaultPaymentMethod__c = 'Other';
                obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount1;
            
            Zuora__Subscription__c zSub1 = TestDataFactory.createSubscription(1)[0];
            zSub1.Subscription_Type_1__c = 'Publication';
            zSUb1.Subscription_Type__c = 'Publication';
            zSub1.Zuora__CustomerAccount__c = zuoraCustomerAccount1[0].id;
            zSub1.Zuora__Account__c = acc.id;
            zSub1.Zuora__Status__c = 'Active';
            zSub1.Order_Line_Item_Number__c = orderLineItem1[0].id;
            zSub1.Order_Line_Item_Number_1__c = orderLineItem1[0].id;
            zSub1.Recipient_Contact__c = con1.id;
            zSub1.Name = 'S0000000';
            zSub1.Order_Number__c = order1.id;
            zSUb1.Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub1.Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub1.Zuora__AutoRenew__c = False;
            zSub1.Supressed_Renewal_and_Reminder_Letter__c = 'False';
            zSub1.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub1.Product_Code__c = 'Pubc'; // jurna
            zSub1.Main_Package_1__c = pack1.id; //jurna   
            zSub1.Main_Package__c = pack1.id; //jurna
            zSub1.Zuora__TermSettingType__c='TERMED';
            zSub1.is1stPDFGenerated__c = False;
            zSub1.is1stNotifEmailSent__c = FALSE;
            insert zSub1; 
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub1.Id];      
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub1.Id);
           // Database.BatchableContext BC; //jurna removed
            Integer daysBeforeExpiration = null;
            Date batchRunDate = date.today();
            Integer batchCount = 1;
            String batchCodeParam = 'SP023';
            String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
            String sessionId = 'Start';
          // Test.startTest();
           //SP_RenewalReminderRequestBatch br  = new SP_RenewalReminderRequestBatch(letterType, daysBeforeExpiration, subsIds, batchRunDate, batchCount, sessionId, batchCodeParam); //jurna removed
             //database.executeBatch(br, 200); //jurna
            //SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
           // br.execute(BC,zSubList); //jurna removed
           
        //defaultCustomSetting();
        String letType2 = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
                
        Test.startTest();
        //run for firstRenewalReminderForNewspaper
        //SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType2, 1, System.today(), 1, '1000000', 'SP022');
        //ID batchId = Database.executeBatch(renewalBatch, 200);
        
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        //batchJobSched.SFDC_Job_id__c = batchId;
        batchJobSched.Batch_Run_Date__c = System.today();
        batchJobSched.Batch_Code__c='SP023';
        insert batchJobSched;
        Test.stopTest();
            
    }
    
    //jurna
    static testmethod void testSP_RenewalReminderRequestBatchApril5(){
            defaultCustomSetting();
            acc = new Account(
                    Name = 'Test Account',
                    Email__c = 'sample@email.com',
                    Mobile__c = '1234567',
                    Renewal_Letter__c = GlobalVariableClass.REFERENCE_HARD_COPY
             );
            
            insert acc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.Recipient_Indicator__c = true;
            //insert con1;
            
            zqu__ZProduct__c zProd1 = TestDataFactory.createZProduct(1)[0];
            insert zProd1;
            
            zqu__ProductRatePlan__c zProdRate1 = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate1.zqu__ZProduct__c = zProd1.id;
            insert zProdRate1;
            
            Product_Publication__c prodPub1 = TestDataFactory.createProductPublication(1)[0];
            prodPub1.ZProduct__c = zProd1.id;
            insert prodPub1;
            
            Package__c pack1 = TestDataFactory.createPackage(1)[0];
            pack1.Name = 'Pack name';
           pack1.Billing_Type__c = 'Full Prepaid';
           insert pack1;
            
            Package_Item__C packItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem1.Package__c = pack1.id;
            packItem1.Product_Rate_Plan__c = zProdRate1.id;
            insert packItem1;
            
            Order__c order1 = new Order__c();
            order1.Account__c = acc.Id;
            order1.Informed_Customer__c = TRUE;
            order1.Recipient_Contact__c = con1.Id;
            order1.Delivery_Charge__c = 100.00;
            order1.Credit_Balance__c = 20.00;
            //insert order1;
            
            List<Order_Line_Item__c> orderLineItem1 = TestDataFactory.createOrderLineItem(1);
            //orderLineItem1[0].Order__c = order1.id;
            orderLineItem1[0].Main_Package_ID__c = pack1.id;
            orderLineItem1[0].Start_Date__c = date.today()+2;
            orderLineItem1[0].Main_Package_Product_Sub_Type__c = 'Magazine';
            //insert orderLineItem1;
            
            List<Zuora__CustomerAccount__c> zuoraCustomerAccount1 = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount1) {
                obj.Zuora__Account__c = acc.id;
                obj.Billing_Contact__c = con1.id;
                obj.Zuora__DefaultPaymentMethod__c = 'Other';
                obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount1;
            
            Zuora__Subscription__c zSub1 = TestDataFactory.createSubscription(1)[0];
            zSub1.Subscription_Type_1__c = 'Publication';
            zSUb1.Subscription_Type__c = 'Publication';
            zSub1.Zuora__CustomerAccount__c = zuoraCustomerAccount1[0].id;
            zSub1.Zuora__Account__c = acc.id;
            zSub1.Zuora__Status__c = 'Active';
            zSub1.Order_Line_Item_Number__c = orderLineItem1[0].id;
            zSub1.Order_Line_Item_Number_1__c = orderLineItem1[0].id;
            zSub1.Recipient_Contact__c = con1.id;
            zSub1.Name = 'S0000000';
            zSub1.Order_Number__c = order1.id;
            zSUb1.Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub1.Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub1.Zuora__AutoRenew__c = False;
            zSub1.Supressed_Renewal_and_Reminder_Letter__c = 'False';
            zSub1.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub1.Product_Code__c = 'Pubc'; // jurna
            zSub1.Main_Package_1__c = pack1.id; //jurna   
            zSub1.Main_Package__c = pack1.id; //jurna
            zSub1.Zuora__TermSettingType__c='TERMED';
            zSub1.is1stPDFGenerated__c = False;
            zSub1.is1stNotifEmailSent__c = FALSE;
            insert zSub1; 
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub1.Id];      
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub1.Id);
           // Database.BatchableContext BC; //jurna removed
            Integer daysBeforeExpiration = null;
            Date batchRunDate = date.today();
            Integer batchCount = 1;
            String batchCodeParam = 'SP024';
            String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
            String sessionId = 'Start';
          // Test.startTest();
           //SP_RenewalReminderRequestBatch br  = new SP_RenewalReminderRequestBatch(letterType, daysBeforeExpiration, subsIds, batchRunDate, batchCount, sessionId, batchCodeParam); //jurna removed
             //database.executeBatch(br, 200); //jurna
            //SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
           // br.execute(BC,zSubList); //jurna removed
           
        //defaultCustomSetting();
        String letType2 = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
                
        Test.startTest();
        //run for firstRenewalReminderForNewspaper
        //SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType2, 1, System.today(), 1, '1000000', 'SP022');
        //ID batchId = Database.executeBatch(renewalBatch, 200);
        
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        //batchJobSched.SFDC_Job_id__c = batchId;
        batchJobSched.Batch_Run_Date__c = System.today();
        batchJobSched.Batch_Code__c='SP024';
        insert batchJobSched;
        Test.stopTest();
            
    }
    
    //jurna
    static testmethod void testSP_RenewalReminderRequestBatchApril6(){
            defaultCustomSetting();
            acc = new Account(
                    Name = 'Test Account',
                    Email__c = 'sample@email.com',
                    Mobile__c = '1234567',
                    Renewal_Letter__c = GlobalVariableClass.REFERENCE_HARD_COPY
             );
            
            insert acc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.Recipient_Indicator__c = true;
            //insert con1;
            
            zqu__ZProduct__c zProd1 = TestDataFactory.createZProduct(1)[0];
            insert zProd1;
            
            zqu__ProductRatePlan__c zProdRate1 = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate1.zqu__ZProduct__c = zProd1.id;
            insert zProdRate1;
            
            Product_Publication__c prodPub1 = TestDataFactory.createProductPublication(1)[0];
            prodPub1.ZProduct__c = zProd1.id;
            insert prodPub1;
            
            Package__c pack1 = TestDataFactory.createPackage(1)[0];
            pack1.Name = 'Pack name';
           pack1.Billing_Type__c = 'Full Prepaid';
           insert pack1;
            
            Package_Item__C packItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem1.Package__c = pack1.id;
            packItem1.Product_Rate_Plan__c = zProdRate1.id;
            insert packItem1;
            
            Order__c order1 = new Order__c();
            order1.Account__c = acc.Id;
            order1.Informed_Customer__c = TRUE;
            order1.Recipient_Contact__c = con1.Id;
            order1.Delivery_Charge__c = 100.00;
            order1.Credit_Balance__c = 20.00;
            //insert order1;
            
            List<Order_Line_Item__c> orderLineItem1 = TestDataFactory.createOrderLineItem(1);
            //orderLineItem1[0].Order__c = order1.id;
            orderLineItem1[0].Main_Package_ID__c = pack1.id;
            orderLineItem1[0].Start_Date__c = date.today()+2;
            orderLineItem1[0].Main_Package_Product_Sub_Type__c = 'Magazine';
            //insert orderLineItem1;
            
            List<Zuora__CustomerAccount__c> zuoraCustomerAccount1 = TestDataFactory.createBillingAccount(1);
            for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount1) {
                obj.Zuora__Account__c = acc.id;
                obj.Billing_Contact__c = con1.id;
                obj.Zuora__DefaultPaymentMethod__c = 'Other';
                obj.Payment_Mode__c = 'Other';
            }
            insert zuoraCustomerAccount1;
            
            Zuora__Subscription__c zSub1 = TestDataFactory.createSubscription(1)[0];
            zSub1.Subscription_Type_1__c = 'Publication';
            zSUb1.Subscription_Type__c = 'Publication';
            zSub1.Zuora__CustomerAccount__c = zuoraCustomerAccount1[0].id;
            zSub1.Zuora__Account__c = acc.id;
            zSub1.Zuora__Status__c = 'Active';
            zSub1.Order_Line_Item_Number__c = orderLineItem1[0].id;
            zSub1.Order_Line_Item_Number_1__c = orderLineItem1[0].id;
            zSub1.Recipient_Contact__c = con1.id;
            zSub1.Name = 'S0000000';
            zSub1.Order_Number__c = order1.id;
            zSUb1.Zuora__SubscriptionStartDate__c = date.today().addDays(43);
            zSub1.Zuora__SubscriptionEndDate__c = date.today()+42;
            zSub1.Zuora__AutoRenew__c = False;
            zSub1.Supressed_Renewal_and_Reminder_Letter__c = 'False';
            zSub1.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub1.Product_Code__c = 'Pubc'; // jurna
            zSub1.Main_Package_1__c = pack1.id; //jurna   
            zSub1.Main_Package__c = pack1.id; //jurna
            zSub1.Zuora__TermSettingType__c='TERMED';
            zSub1.is1stPDFGenerated__c = False;
            zSub1.is1stNotifEmailSent__c = FALSE;
            insert zSub1; 
            
            List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number_1__c,
            is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
            Zuora__Account__r.Renewal_Letter__c, Zuora__SubscriptionEndDate__c
            FROM Zuora__Subscription__c 
            WHERE Id =: zSub1.Id];      
            
            Set<Id> subsIds = new Set<Id>();
            subsIds.add(zSub1.Id);
           // Database.BatchableContext BC; //jurna removed
            Integer daysBeforeExpiration = null;
            Date batchRunDate = date.today();
            Integer batchCount = 1;
            String batchCodeParam = 'SP025';
            String letterType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
            String sessionId = 'Start';
          // Test.startTest();
           //SP_RenewalReminderRequestBatch br  = new SP_RenewalReminderRequestBatch(letterType, daysBeforeExpiration, subsIds, batchRunDate, batchCount, sessionId, batchCodeParam); //jurna removed
             //database.executeBatch(br, 200); //jurna
            //SP_RenewalReminderRequestBatch br = new SP_RenewalReminderRequestBatch('test', 1, subsIds, date.today(), 1, 'test', 'test'); //joy
           // br.execute(BC,zSubList); //jurna removed
           
        //defaultCustomSetting();
        String letType2 = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
                
        Test.startTest();
        //run for firstRenewalReminderForNewspaper
        //SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType2, 1, System.today(), 1, '1000000', 'SP022');
        //ID batchId = Database.executeBatch(renewalBatch, 200);
        
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        //batchJobSched.SFDC_Job_id__c = batchId;
        batchJobSched.Batch_Run_Date__c = System.today();
        batchJobSched.Batch_Code__c='SP025';
        insert batchJobSched;
        Test.stopTest();
            
    }

  /*  static testmethod void testSP_RenewalReminderRequestBatch(){
        prepareTestData();
        zSub = [SELECT Id, Order_Line_Item_Number_1__r.Main_Package_ID__r.Id,
               is1stPDFGenerated__c, is2ndPDFGenerated__c, is1stNotifEmailSent__c, is2ndNotifEmailSent__c,
               Zuora__Account__r.Renewal_Letter__c
               FROM Zuora__Subscription__c 
               WHERE Id =: zSub[0].Id];
        
        Database.BatchableContext BC;
        String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
        SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType, null, System.Today(), 1, '1000000', 'SP022');
        
        renewalBatch.execute(BC, zSub);
        
        
        
        System.assertNotEquals(null, renewalBatch);
     }
     */
    static testmethod void firstMagTest(){
            defaultCustomSetting();
            String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
           
            Test.startTest();
            //run for firstRenewalReminderForNewspaper
            SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType, null, System.Today(), 1, '1000000', 'SP022');
            String batchId = Database.executeBatch(renewalBatch);
            
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchId;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            Test.stopTest();
          
    } 
     
    static testmethod void secMagTest(){
       defaultCustomSetting();
        String letType = SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine;
                
        Test.startTest();
        //run for firstRenewalReminderForNewspaper
        SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType, null, System.Today(), 1, '1000000', 'SP022');
        String batchId = Database.executeBatch(renewalBatch);
        
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchId;
        batchJobSched.Batch_Run_Date__c = System.today();
        insert batchJobSched;
        Test.stopTest();
   
    } 
    
    //jurna
    static testmethod void secMagTest2(){
       defaultCustomSetting();
        String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
                
        Test.startTest();
        //run for firstRenewalReminderForNewspaper
        SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType, 1, System.today()+3, 1, '1000000', 'SP022');
        String batchId = Database.executeBatch(renewalBatch);
        
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchId;
        batchJobSched.Batch_Run_Date__c = System.today();
        insert batchJobSched;
        Test.stopTest();
   
    }
   
    
    static testmethod void firstNewsTest(){
        defaultCustomSetting();
        String letType = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
                
        Test.startTest();
        //run for firstRenewalReminderForNewspaper
        SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType, null, System.Today(), 1, '1000000', 'SP022');
        String batchId = Database.executeBatch(renewalBatch);
        
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchId;
        batchJobSched.Batch_Run_Date__c = System.today();
        insert batchJobSched;
        Test.stopTest();
   
    } 
    
       
    static testmethod void secNewsTest(){
        defaultCustomSetting();
        
        String letType = SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper;
                
        Test.startTest();
        //run for firstRenewalReminderForNewspaper
        SP_RenewalReminderRequestBatch renewalBatch = new SP_RenewalReminderRequestBatch(letType, null, System.Today(), 1, '1000000', 'SP022');
        String batchId = Database.executeBatch(renewalBatch);
        
        BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
        batchJobSched.SFDC_Job_id__c = batchId;
        batchJobSched.Batch_Run_Date__c = System.today();
        
        insert batchJobSched;
        Test.stopTest();
    }
    
   
   static void defaultCustomSetting()
    {
        Manual_Batch_Run_Dates__c mBRDate = new Manual_Batch_Run_Dates__c();
        mBRDate.Name = 'ManualBatchRun';
        mBRDate.Batch_Run_Date__c = Date.Today();
        database.insert(mBRDate); //PD-0147
        
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        /*
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
                keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
            insert keyId;
        }
        */
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59'};
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
                otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
            insert otherC;
        }
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
        insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
            batchInterfaceSetting.Name = 'Endpoint Delegator';
            batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
    }
    
    
}