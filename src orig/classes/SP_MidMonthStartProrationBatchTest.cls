@isTest (Seealldata = false)
public class SP_MidMonthStartProrationBatchTest {

    static testmethod void test1MidMonthStartProrationBatch() {
    
    defaultCustomSetting();
    
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
           
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            //create Account
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            //create Package
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '1';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.Name = 'Name';
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
            
            //RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Customer Contact' LIMIT 1];
         
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today().addDays(2);
            orderline.End_Date__c = date.Today()+10; /*date.newInstance(2014, 12, 2);*/
            orderline.Main_Package_ID__c = pack.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Zuora__SubscriptionStartDate__c = date.today().addDays(30);
                subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(15);                
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
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Postpaid';
            
           
            insert new List<sObject>{cas, orderline, subrecs[0], subrecs[1], subrecs[2], subrecs[3]};
            
            System.assertEquals(subRecs[0].Subscriber_Contact__c, con.Id);
            System.assertEquals(orderline.Order__c, orderRec.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = System.today(),
                    Restart_Date__c = System.today().addDays(2)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subRecs[0].Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

           
            //insert  ZUnitOfMeasure
            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;            

            Zuora__SubscriptionProductCharge__c spcList = TestDataFactory.createSubProductCharge(1)[0];
            spcList.Name = 'Test Subscription Product Charge';
            spcList.Zuora__Zuora_Id__c = 'ZID';
            spcList.Zuora__Subscription__c = subRecs[1].Id;
            spcList.Zuora__Type__c = 'One-Time';
            spcList.Zuora__Type__c = 'Usage';
            spcList.PublicationCode__c = 'ST';
            spcList.Zuora__UOM__c = 'Copy Weekday';
            insert spcList;

            Test.startTest();
            Set<String> referenceIdsAsId = new Set<String>();
            referenceIdsAsId.add(subrecs[0].Id);
           
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch(referenceIdsAsId, 1);
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            
            Database.BatchableContext BC;
            batch.execute(BC, subRecs);
            Test.stopTest();
        
    }
    
    static testmethod void test1MidMonthStartProrationBatch1() {
    
    defaultCustomSetting();
    
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
           
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            //create Account
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            //create Package
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '1';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.Name = 'Name';
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
            
            //RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Customer Contact' LIMIT 1];
         
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today().addDays(2);
            orderline.End_Date__c = date.Today()+10; /*date.newInstance(2014, 12, 2);*/
            orderline.Main_Package_ID__c = pack.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Zuora__SubscriptionStartDate__c = date.today().addDays(30);
                subRec.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
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
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
           
            insert new List<sObject>{cas, orderline, subrecs[0], subrecs[1], subrecs[2], subrecs[3]};
            
            System.assertEquals(subRecs[0].Subscriber_Contact__c, con.Id);
            System.assertEquals(orderline.Order__c, orderRec.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = System.today(),
                    Restart_Date__c = System.today().addDays(2)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subRecs[0].Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

           
            //insert  ZUnitOfMeasure
            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;            

            Zuora__SubscriptionProductCharge__c spcList = TestDataFactory.createSubProductCharge(1)[0];
            spcList.Name = 'Test Subscription Product Charge';
            spcList.Zuora__Zuora_Id__c = 'ZID';
            spcList.Zuora__Subscription__c = subRecs[0].Id;
            spcList.Zuora__Type__c = 'One-Time';
            spcList.Zuora__Type__c = 'Usage';
            spcList.PublicationCode__c = 'ST';
            spcList.Zuora__UOM__c = 'Copy Weekday';
            insert spcList;

            Test.startTest();
            Set<String> referenceIdsAsString = new Set<String>();
            referenceIdsAsString.add(string.valueof(subrecs[0].Id));
           
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch(referenceIdsAsString, 2);
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            
            Database.BatchableContext BC;
            batch.execute(BC, subRecs);
            Test.stopTest();
        
    }
    
    static testmethod void test1MidMonthStartProrationBatch2() {
    
    defaultCustomSetting();
    
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
           
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            //create Account
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            //create Package
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '1';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.Name = 'Name';
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
            
            //RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Customer Contact' LIMIT 1];
         
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today().addDays(2);
            orderline.End_Date__c = date.Today()+10; /*date.newInstance(2014, 12, 2);*/
            orderline.Main_Package_ID__c = pack.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.today().addMonths(2).toStartofMonth().addDays(-1); 
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
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
           
            insert new List<sObject>{cas, orderline, subrecs[0], subrecs[1], subrecs[2], subrecs[3]};
            
            System.assertEquals(subRecs[0].Subscriber_Contact__c, con.Id);
            System.assertEquals(orderline.Order__c, orderRec.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = System.today(),
                    Restart_Date__c = System.today().addDays(2)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subRecs[0].Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

           
            //insert  ZUnitOfMeasure
            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;            

            Zuora__SubscriptionProductCharge__c spcList = TestDataFactory.createSubProductCharge(1)[0];
            spcList.Name = 'Test Subscription Product Charge';
            spcList.Zuora__Zuora_Id__c = 'ZID';
            spcList.Zuora__Subscription__c = subRecs[1].Id;
            spcList.Zuora__Type__c = 'One-Time';
            spcList.Zuora__Type__c = 'Usage';
            spcList.PublicationCode__c = 'ST';
            spcList.Zuora__UOM__c = 'Copy Weekday';
            insert spcList;

            Test.startTest();
            
           
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            
            Database.BatchableContext BC;
            batch.execute(BC, subRecs);
            Test.stopTest();
     }
     
     static testmethod void test1MidMonthStartProrationBatch3() {
    
    defaultCustomSetting();
    
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
           
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            //create Account
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            //create Package
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '1';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.Name = 'Name';
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
            
            //RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Customer Contact' LIMIT 1];
         
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today().addDays(2);
            orderline.End_Date__c = date.Today()+10; /*date.newInstance(2014, 12, 2);*/
            orderline.Main_Package_ID__c = pack.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Zuora__SubscriptionStartDate__c = Date.newInstance(2015,10,12);
                subRec.Zuora__SubscriptionEndDate__c = Date.newInstance(2015,12,11);
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
                subRec.Zuora__TermSettingType__c = 'TERMED';
                subRec.Term_Length__c = 2;
                subRec.Term_Length1__c = '2';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
           
            insert new List<sObject>{cas, orderline, subrecs[0], subrecs[1], subrecs[2], subrecs[3]};
            
            System.assertEquals(subRecs[0].Subscriber_Contact__c, con.Id);
            System.assertEquals(orderline.Order__c, orderRec.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = System.today(),
                    Restart_Date__c = System.today().addDays(2)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subRecs[0].Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

           
            //insert  ZUnitOfMeasure
            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;            

            Zuora__SubscriptionProductCharge__c spcList = TestDataFactory.createSubProductCharge(1)[0];
            spcList.Name = 'Test Subscription Product Charge';
            spcList.Zuora__Zuora_Id__c = 'ZID';
            spcList.Zuora__Subscription__c = subRecs[0].Id;
            spcList.Zuora__Type__c = 'One-Time';
            spcList.Zuora__Type__c = 'Usage';
            spcList.PublicationCode__c = 'ST';
            spcList.Zuora__UOM__c = 'Copy Weekday';
            insert spcList;

            Test.startTest();
            Set<String> referenceIdsAsString = new Set<String>();
            referenceIdsAsString.add(string.valueof(subrecs[0].Id));
           
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch(referenceIdsAsString, 2);
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            
            Database.BatchableContext BC;
            batch.execute(BC, subRecs);
            Test.stopTest();
        
    }
    
    static testmethod void test1MidMonthStartProrationBatch4() {
    
    defaultCustomSetting();
    
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
           
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            //create Account
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            //create Package
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '1';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.Name = 'Name';
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
            
            //RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Customer Contact' LIMIT 1];
         
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today().addDays(2);
            orderline.End_Date__c = date.Today()+10; /*date.newInstance(2014, 12, 2);*/
            orderline.Main_Package_ID__c = pack.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Zuora__SubscriptionStartDate__c = Date.newInstance(2015,9,12);
                subRec.Zuora__SubscriptionEndDate__c = Date.newInstance(2015,11,30);
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
                subRec.Zuora__TermSettingType__c = 'TERMED';
                subRec.Term_Length__c = 2;
                subRec.Term_Length1__c = '2';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Postpaid';
            
           
            insert new List<sObject>{cas, orderline, subrecs[0], subrecs[1], subrecs[2], subrecs[3]};
            
            System.assertEquals(subRecs[0].Subscriber_Contact__c, con.Id);
            System.assertEquals(orderline.Order__c, orderRec.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = System.today(),
                    Restart_Date__c = System.today().addDays(2)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subRecs[0].Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

           
            //insert  ZUnitOfMeasure
            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;            

            Zuora__SubscriptionProductCharge__c spcList = TestDataFactory.createSubProductCharge(1)[0];
            spcList.Name = 'Test Subscription Product Charge';
            spcList.Zuora__Zuora_Id__c = 'ZID';
            spcList.Zuora__Subscription__c = subRecs[3].Id;
            spcList.Zuora__Type__c = 'One-Time';
            spcList.Zuora__Type__c = 'Usage';
            spcList.PublicationCode__c = 'ST';
            spcList.Zuora__UOM__c = 'Copy Weekday';
            insert spcList;

            Test.startTest();
            Set<String> referenceIdsAsString = new Set<String>();
            referenceIdsAsString.add(string.valueof(subrecs[0].Id));
           
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch(referenceIdsAsString, 2);
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            
            Database.BatchableContext BC;
            batch.execute(BC, subRecs);
            Test.stopTest();
        
    }
    static testmethod void test1MidMonthStartProrationBatch5() {
    
    defaultCustomSetting();
    
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
           
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            //create Account
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            //create Package
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '1';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.Name = 'Name';
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
            
            //RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Customer Contact' LIMIT 1];
         
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today().addDays(2);
            orderline.End_Date__c = date.Today()+10; /*date.newInstance(2014, 12, 2);*/
            orderline.Main_Package_ID__c = pack.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
                subRec.Zuora__SubscriptionStartDate__c = Date.newInstance(2015,9,31);
                subRec.Zuora__SubscriptionEndDate__c = Date.newInstance(2015,11,30);
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
                subRec.Zuora__TermSettingType__c = 'TERMED';
                subRec.Term_Length__c = 2;
                subRec.Term_Length1__c = '2';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Postpaid';
            
           
            insert new List<sObject>{cas, orderline, subrecs[0], subrecs[1], subrecs[2], subrecs[3]};
            
            System.assertEquals(subRecs[0].Subscriber_Contact__c, con.Id);
            System.assertEquals(orderline.Order__c, orderRec.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = System.today(),
                    Restart_Date__c = System.today().addDays(2)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subRecs[0].Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

           
            //insert  ZUnitOfMeasure
            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;            

            Zuora__SubscriptionProductCharge__c spcList = TestDataFactory.createSubProductCharge(1)[0];
            spcList.Name = 'Test Subscription Product Charge';
            spcList.Zuora__Zuora_Id__c = 'ZID';
            spcList.Zuora__Subscription__c = subRecs[3].Id;
            spcList.Zuora__Type__c = 'One-Time';
            spcList.Zuora__Type__c = 'Usage';
            spcList.PublicationCode__c = 'ST';
            spcList.Zuora__UOM__c = 'Copy Weekday';
            insert spcList;

            Test.startTest();
            Set<String> referenceIdsAsString = new Set<String>();
            referenceIdsAsString.add(string.valueof(subrecs[0].Id));
           
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch(referenceIdsAsString, 2);
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            
            Database.BatchableContext BC;
            batch.execute(BC, subRecs);
            Test.stopTest();
        
    }


    static void defaultCustomSetting()
    {
        Batch_Configuration_Settings__c batchSettings;
        String spcIdentifier;
        Integer year;
        Integer month;
        Zuora__SubscriptionProductCharge__c spc;
        Usage__c usage;
        Integer type;
        
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        /*
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        */
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
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
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
        
         Date_Configuration__c dateConfig = new Date_Configuration__c();
         dateConfig.Name = 'Usage Reference Date';
        dateConfig.Date__c = date.today();
        insert dateConfig;
        
        List<Unit_of_Measure__c> uomList = new List<Unit_of_Measure__c>();
        Unit_of_Measure__c uom = new Unit_of_Measure__c();
        uom.Name = 'Copy Weekday';
        uom.Issue_Days__c = 'Monday,Tuesday,Wednesday,Thursday,Friday';
        uom.Used_for__c = 'Proration Charge Usage';
        uomList.add(uom);
        
        uom = new Unit_of_Measure__c();
        uom.Name = 'Issue Weekday';
        uom.Issue_Days__c = 'Monday,Tuesday,Wednesday,Thursday,Friday';
        uom.Used_for__c = 'Postpaid Usage';
        uomList.add(uom);
        
        uom = new Unit_of_Measure__c();
        uom.Name = 'Credit Copy Weekday';
        uom.Issue_Days__c = 'Monday,Tuesday,Wednesday,Thursday,Friday';
        uom.Used_for__c = 'Proration Credit Usage';
        uomList.add(uom);
        
        uom = new Unit_of_Measure__c();
        uom.Name = 'No Credit Copy Weekday';
        uom.Issue_Days__c = 'Monday,Tuesday,Wednesday,Thursday,Friday';
        uom.Used_for__c = 'Non Chargeable Copy Usage';
        uomList.add(uom);
        
        insert uomList;
    }

}