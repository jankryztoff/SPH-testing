/**
 * Class Name: <SP_GracePeriodSubscriptionBatch_Test>
 * @author: <Jean Cariño>
 * Date: <27/02/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for SP_GracePeriodSubscriptionBatch>
*/

@isTest (Seealldata = true)
private class SP_GracePeriodSubscriptionBatch_Test {
    static testmethod void test1() {
    
            prepareTestData();

            SP_GracePeriodSubscriptionBatch batch = new SP_GracePeriodSubscriptionBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);
            System.assertNotEquals(null, batchprocessid);
            
            }
            
            
            
           private static void prepareTestData(){
            
           User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [Select Id From Profile Where Name = 'CSO Admin' LIMIT 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) { 

            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Recurring Prepaid';
            insert billAcc;

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Grace Period';
            pack.Name = 'Test Package';
            pack.Package_Code__c = 'Package_Code_1234567890';
            pack.Subscription_Period__c = '1';
            insert pack;
            
            /*Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;*/
            
            /*Other__c other = new Other__c();
            other.Name = 'DTL';
            other.Value__c = '23:59';
            insert(other); */
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            /*
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '123457397';
            key.Type__c = 'Number';
            insert key;
            */
            
            
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Billing_Account__c = billAcc.Id;
            orderRec.Billing_Type__c = 'Recurring Prepaid';
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Order_Type__c = 'Start';
            insert orderRec;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = Date.today().addDays(4); //date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today().addDays(1);
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            //orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+1;
            insert orderline;
            
            /*Key_Id__c key1 = new Key_Id__c();
            key1.Name = 'GracePeriodDaysBeforeEndDate';
            key1.type__c = 'Integer';
            key1.id__c = '4';
            insert key1;*/
            
            List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__Account__c = acc.Id;
            subs.Zuora__CustomerAccount__c = billAcc.Id;
            subs.Number_of_Copies1__c = '2';
            subs.Order_Number_1__c = orderRec.Id;
            subs.Zuora__Zuora_Id__c = '1123';
            subs.Zuora__SubscriptionEndDate__c = date.today().addDays(Integer.valueOf(ConstantsSLB.getKeyId('GracePeriodDaysBeforeEndDate')));
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
            subs.Billing_Type__c = 'Recurring Prepaid';
            subs.Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            subs.Order_Line_Item_Number_1__c = orderline.id;
            subs.Subscription_Charge__c = 10.00;
            subs.Subscription_Type__c = 'Publication';
            subs.Subscription_Type_1__c = 'Publication';
            subs.Delivery_Charge_Type__c = '100';
            subs.Zuora__AutoRenew__c = False; 
            subs.Grace_Period_Subscription__c = null;
            subs.Sponsor_1__c = true;
            subs.Term_Length__c = 0;
            subsList.add(subs);            
            insert subsList;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Name = 'SPC_NAME';
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = subsList[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c = 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__ProductName__c = 'TEST NAME';
            zSubProdCharge[0].Product_Code__c = 'PUBX';
            zSubProdCharge[0].Zuora__Price__c = 20;
            zSubProdCharge[0].Zuora__BillingPeriod__c = 'Quarterly';
            zSubProdCharge[0].Zuora__Quantity__c = 18732;
            zSubProdCharge[0].Zuora__UOM__c ='ZuoraUOM';
            zSubProdCharge[0].Zuora__Type__c = 'Usage';
            insert zSubProdCharge; 
              
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-0000075';
            ZpRODUCT.ProductFamily__c = 'BH';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            insert prdRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
            prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
            prpList[0].zqu__Deleted__c = FALSE;
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test' ;
            
            
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            prpList[0].Name = 'SPC_NAME';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4];
            
            Product_Family__c prodFam = new Product_Family__c();
            prodFam.Product_Family__c = 'Product_Family_Test_123';
            prodFam.Product_Family_Name__c = 'Product_Family_Name_Test_123';
            insert prodFam;
            
            /*Package_Product_Family__c ppf = new Package_Product_Family__c();
            ppf.Package_Name__c = pack.id;
            ppf.Product_Family__c = prodFam.id;
            insert ppf;
            */
            BATCH_JOB_SCHEDULER__c bjs = new BATCH_JOB_SCHEDULER__c();
            bjs.SFDC_Job_id__c = 'SP001';//'SFDCJobid1234567890';
            bjs.Batch_Run_Date__c = date.today();
            bjs.Batch_Code__c = 'SP001';
            insert bjs;
            
            Grace_Period__c gperiod = new Grace_Period__c();
            gperiod.Product_Family__c = prodFam.id;
            gperiod.Grace_Days__c = 10;
            gperiod.Effective_From__c = date.today();
            gperiod.Efffective_To__c = date.today().addDays(1);
            insert gperiod;
            
            //insert new Key_Id__c(Id__c='4',Name='GracePeriodDaysBeforeEndDate');
            
            /*Test.startTest();
            
            
            /*System.assertEquals([SELECT id, name, main_package_1__c, subscription_type_1__c,
                     zuora__subscriptionStartDate__c, Zuora__Account__c, Order_Line_Item_Number_1__c,
                     zuora__subscriptionEndDate__c, Recipient_Contact__c, Order_Number_1__c,
                     Grace_Period_Subscription__c,
                     Recipient_Contact__r.Address__r.RecordTypeId, Order_Number_1__r.Delivery_Charge_Type__c,
                     Sponsor_1__c, Term_Length__c
                     FROM Zuora__Subscription__c 
                     WHERE zuora__status__c = 'Active' AND  Zuora__SubscriptionEndDate__c =: date.today().addDays(Integer.valueOf(ConstantsSLB.getKeyId('GracePeriodDaysBeforeEndDate')))
                     AND Zuora__AutoRenew__c = FALSE] +'', 
                     
                     [SELECT zuora__status__c, Zuora__SubscriptionEndDate__c, Zuora__AutoRenew__c 
                     FROM Zuora__Subscription__c 
                     ] +
                     
                     '  ' + date.today().addDays(4));
            
            SP_GracePeriodSubscriptionBatch batch = new SP_GracePeriodSubscriptionBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);
           
            Test.stopTest();
            */
          }         
     }
}