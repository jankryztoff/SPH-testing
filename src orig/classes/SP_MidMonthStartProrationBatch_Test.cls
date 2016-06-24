/**
 * Class Name: <SP_MidMonthStartProrationBatch_Test>
 * @author: <CV Manawatao>
 * Date: <28/01/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for SP_MidMonthStartProrationBatch>
*/
@isTest (Seealldata = FALSE)
private class SP_MidMonthStartProrationBatch_Test {

    static testmethod void test1MidMonthStartProrationBatch() {

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

                Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
                insert dtl;
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    
                Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                acc.NRIC__c = 'T1234567R';
    
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                insert new List<sObject>{postal, acc, pack};
              
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                billAcc.Billing_Type__c = 'Full Prepaid';
                insert billAcc;
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                System.assertEquals(addressRec.Postal_Code__c, postal.Id);
     
                Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBER';
                key.Id__c = '123457397';
                key.Type__c = 'Number';
                //insert key;
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                // START : CCB 002 12/2/2014 Editedt By Alyana P. Navarro;
                RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
                con.RecordTypeId = rt.id;
                con.Recipient_Indicator__c = true;
                // END : CCB 002 12/2/2014
                insert con;
                
                System.assertEquals(con.AccountId, acc.Id);
    
                
                Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = con.Id;
                
                insert orderRec;
                
                Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
                cirPlanSched.Name = 'CIR Plan Schedule';
                cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
                cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
                cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
                cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                insert cirPlanSched;
                            
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                  
                /*Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                orderline.End_Date__c = date.newInstance(2014, 12, 2);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.
                 = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Earliest_Start_Date__c = date.today();
                orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = TRUE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                insert orderline;*/
              
                List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
                Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
                subs.Zuora__Account__c = acc.Id;
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
                //subs.Billing_Type__c = 'Recurring Prepaid';
                subs.Billing_Type__c = 'Full Prepaid';
                subs.Zuora__SubscriptionStartDate__c = date.today();
                subs.Subscription_Charge__c = 10.00;
                subs.Subscription_Type__c = 'Publication';
                subs.Subscription_Type_1__c = 'Publication';
                subs.Zuora__Status__c = 'Active';
                subs.Zuora__TermSettingType__c = 'EVERGREEN';
                subs.Grace_Period_Subscription__c = null;
                subs.Zuora__CustomerAccount__c =billAcc.Id;
                
                
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
                insert zProduct;
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.Name = 'RATE_PLAN_NAME';
                prdRatePlan.BillingType__c = 'Full Prepaid';
                prdRatePlan.RatePlanCode__c = 'BP';
                prdRatePlan.SubscriptionFrequency__c = '1';
                prdRatePlan.RatePlanType__c = 'Proration';
                prdRatePlan.RatePlanSubType__c = 'Standard';
                insert prdRatePlan;
                
                List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
                prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
                prpList[0].zqu__Deleted__c = FALSE;
                prpList[1].zqu__UOM__c = 'Credit Copy Sat';
                prpList[2].zqu__UOM__c = 'Credit Copy Sun';
                prpList[3].zqu__UOM__c = 'Credit Copy Month Test';
                prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
                prpList[4].PublicationCode__c = 'PUBX';
                prpList[0].Name = 'SPC_NAME';
                insert prpList;
                
                zqu__ProductRatePlanCharge__c prpc = prpList[4];
            
            
              
             //  List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];
               
          /*       
               
                List<BATCH_JOB_SCHEDULER__c> bjs = new List<BATCH_JOB_SCHEDULER__c>(1);
                bjs[0].SFDC_Job_id__c = 'SFDCJobid1234567890';
                bjs[0].Batch_Run_Date__c = date.today();
                insert bjs;
    */
                System.assertEquals(subs.Subscriber_Contact__c, con.Id);
                System.assertEquals(cas.Order__c, orderRec.Id);
                
    
                List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                    new Temp_Stop__c(
                        Case__c = cas.Id,
                        Temp_Stop_Qty__c = 5,
                        Temp_Stop_Date__c = date.today().adddays(1),
                        Restart_Date__c = date.today().adddays(30)
                    )
                };
                insert tempStops;
                
                List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                    new Subscription_Temp_Stop__c(
                        Subscription__c = subs.Id,
                        Temp_Stop__c = tempStops[0].Id
                    )
                };
                insert subTempStops;
    
                zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
                zUOM.zqu__Active__c = TRUE ; 
                zUOM.zqu__Uom_rounding_mode__c = 'Up';
                zUOM.zqu__Uom_precision__c = 2;
                zUOM.zqu__ZuoraId__c = 'test2';
                insert zUOM;
                
                Unit_of_Measure__c uom = new Unit_of_Measure__c();
                uom.Name = 'Unit_of_Measure_Test_123';
                uom.Used_for__c = 'Proration Charge Usage';
                insert uom;
                
                List<Publication__c> pubList = new List<Publication__c>();
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Name = 'Beat Harry';    
                pub.Publication_Code__c = 'ADHD';
                pub.Published_Days__c = 'YYYYYYN';
                pub.Publication_Type__c = 'N';
                pub.Frequency_Code__c = 'D';
                pubList.add(pub);
                insert pubList;
                
                List<Non_Publication_Day__c> nonPubList = new List<Non_Publication_Day__c>();
                Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                           
                nonpub.Non_Publication_Date__c = date.today();
                nonpub.Publication_Code__c = 'ADHD';
                nonpub.Publication__c = pub.Id;
                nonPubList.add(nonpub);
                insert nonPubList;
                
                List<Usage__c> usageList = new List<Usage__c>();
                Usage__c usa =  new Usage__c();
                usa.Subscription_Temp_Stop__c = subTempStops[0].id;
                usa.Unit_of_Measure__c = zUOM.id;
                usageList.add(usa);
                insert usageList;
            }
            
            Test.startTest();
           
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);
           
            Test.stopTest();
        
    }//end of test 
    
 
   static testmethod void unitTest1() {  // <-- This is the Original Test Method Signature
    
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

            Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];

            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcc.Billing_Type__c = 'Recurring Prepaid';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
 
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '123457397';
            key.Type__c = 'Number';
            //insert key;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Editedt By Alyana P. Navarro;
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
            
            Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
            cirPlanSched.Name = 'CIR Plan Schedule';
            cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
            cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
            cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
            cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            insert cirPlanSched;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;
   
           /* 
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amou.addDays(2)To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;.addDays(4)          orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Recurring Prepaid';
            insert orderline;
            */
          List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__Account__c = acc.Id;
            subs.Zuora__Zuora_Id__c = '1123';
            subs.Zuora__SubscriptionStartDate__c = date.today();
            //subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            //subs.Zuora__SubscriptionEndDate__c = date.today()+30;
            subs.Zuora__SubscriptionEndDate__c=date.today().addMonths(1).toStartofMonth().addDays(-1); //
            subs.Term_Length__c = null;
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
            
            subs.Subscription_Charge__c = 10.00;
            subs.Subscription_Type__c = 'Publication';
            subs.Subscription_Type_1__c = 'Publication';
            subs.Zuora__Status__c = 'Active';
            subs.Zuora__TermSettingType__c = 'EVERGREEN';
            
            subs.Grace_Period_Subscription__c = null;
            subs.Zuora__CustomerAccount__c =billAcc.Id;
            
            
            
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
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.BillingType__c = 'Full Prepaid';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.RatePlanType__c = 'Proration';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            insert prdRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
            prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
            prpList[0].zqu__Deleted__c = FALSE;
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test';
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            prpList[0].Name = 'SPC_NAME';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4];

            /*BATCH_JOB_SCHEDULER__c bjs = new BATCH_JOB_SCHEDULER__c();
            bjs.SFDC_Job_id__c = 'SFDCJobid1234567890';
            bjs.Batch_Run_Date__c = date.today();
            insert bjs;*/

            System.assertEquals(subs.Subscriber_Contact__c, con.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = date.today().adddays(1),
                    Restart_Date__c = date.today().adddays(30)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subs.Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;
            
            Unit_of_Measure__c uom = new Unit_of_Measure__c();
            uom.Name = 'Unit_of_Measure_Test_123';
            uom.Used_for__c = 'Proration Charge Usage';
            insert uom;
            
            List<Publication__c> pubList = new List<Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Beat Harry';    
            pub.Publication_Code__c = 'ADHD';
            pub.Published_Days__c = 'YYYYYYN';
            pub.Publication_Type__c = 'N';
            pub.Frequency_Code__c = 'D';
            pubList.add(pub);
            insert pubList;
            
            List<Non_Publication_Day__c> nonPubList = new List<Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                           
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'ADHD';
            nonpub.Publication__c = pub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Usage__c> usageList = new List<Usage__c>();
            Usage__c usa =  new Usage__c();
            usa.Subscription_Temp_Stop__c = subTempStops[0].id;
            usa.Unit_of_Measure__c = zUOM.id;
            usageList.add(usa);
            insert usageList;
        
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch();
            Database.BatchableContext bc;
            batch.execute(bc,subsList);
            //ID batchprocessid = Database.executeBatch(batch,200);
           //System.assertNotEquals(null, batchprocessid);


    }
    }// end of SP_MidMonthStartProrationBatchTest 

  static testmethod void unitofMeasurement2() {  // <-- This is the Original Test Method Signature
    
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

            Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];

            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcc.Billing_Type__c = 'Recurring Prepaid';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
 
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '123457397';
            key.Type__c = 'Number';
            //insert key;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Editedt By Alyana P. Navarro;
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Order_Type__c = 'Start';
            insert orderRec;
            
            Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
            cirPlanSched.Name = 'CIR Plan Schedule';
            cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
            cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
            cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
            cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            insert cirPlanSched;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;
            
            List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__Account__c = acc.Id;
            subs.Zuora__Zuora_Id__c = '1123';
            subs.Zuora__SubscriptionStartDate__c = date.today();
            //subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            //subs.Zuora__SubscriptionEndDate__c = date.today()+30;
            subs.Zuora__SubscriptionEndDate__c= date.today()+15; //
            subs.Term_Length__c = null;
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
            
            subs.Subscription_Charge__c = 10.00;
            subs.Subscription_Type__c = 'Publication';
            subs.Subscription_Type_1__c = 'Publication';
            subs.Zuora__Status__c = 'Active';
            subs.Zuora__TermSettingType__c = 'EVERGREEN';
            
            subs.Grace_Period_Subscription__c = null;
            subs.Zuora__CustomerAccount__c =billAcc.Id;
            
            
            
            subsList.add(subs);
            insert subsList;
            
            Order__c orderRec1 = new Order__c();
            orderRec1.Id = orderRec.Id;
            orderRec1.Base_Subscription__c = subsList[0].id;
            update orderRec1;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today().addDays(15);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
           // orderline.Amou.addDays(2)To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Recurring Prepaid';
            orderline.Start_Date__c = date.today().addDays(1);
            insert orderline;
            
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
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.BillingType__c = 'Full Prepaid';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.RatePlanType__c = 'Proration';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            insert prdRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
            prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
            prpList[0].zqu__Deleted__c = FALSE;
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test';
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            prpList[0].Name = 'SPC_NAME';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4];

            /*BATCH_JOB_SCHEDULER__c bjs = new BATCH_JOB_SCHEDULER__c();
            bjs.SFDC_Job_id__c = 'SFDCJobid1234567890';
            bjs.Batch_Run_Date__c = date.today();
            insert bjs;*/

            System.assertEquals(subs.Subscriber_Contact__c, con.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = date.today().adddays(1),
                    Restart_Date__c = date.today().adddays(30)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subs.Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;
            
            Unit_of_Measure__c uom = new Unit_of_Measure__c();
            uom.Name = 'Unit_of_Measure_Test_123';
            uom.Used_for__c = 'Postpaid Usage';
            insert uom;
            
            List<Publication__c> pubList = new List<Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Beat Harry';    
            pub.Publication_Code__c = 'ADHD';
            pub.Published_Days__c = 'YYYYYYN';
            pub.Publication_Type__c = 'N';
            pub.Frequency_Code__c = 'D';
            pubList.add(pub);
            insert pubList;
            
            List<Non_Publication_Day__c> nonPubList = new List<Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                           
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'ADHD';
            nonpub.Publication__c = pub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Usage__c> usageList = new List<Usage__c>();
            Usage__c usa =  new Usage__c();
            usa.Subscription_Temp_Stop__c = subTempStops[0].id;
            usa.Unit_of_Measure__c = zUOM.id;
            usageList.add(usa);
            insert usageList;
        
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch();
            Database.BatchableContext bc;
            batch.execute(bc,subsList);
            //ID batchprocessid = Database.executeBatch(batch,200);
           //System.assertNotEquals(null, batchprocessid);


    }
    }// end of SP_MidMonthStartProrationBatchTest
    static testmethod void unitofMeasurement3() {  // <-- This is the Original Test Method Signature
    
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

            Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];

            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcc.Billing_Type__c = 'Recurring Postpaid';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
 
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '123457397';
            key.Type__c = 'Number';
            //insert key;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Editedt By Alyana P. Navarro;
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
            
            Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
            cirPlanSched.Name = 'CIR Plan Schedule';
            cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
            cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
            cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
            cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            insert cirPlanSched;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;
        
            
            List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__Account__c = acc.Id;
            subs.Zuora__Zuora_Id__c = '1123';
            subs.Zuora__SubscriptionStartDate__c = date.today();
            //subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            //subs.Zuora__SubscriptionEndDate__c = date.today()+30;
            subs.Zuora__SubscriptionEndDate__c=date.today().addMonths(1).toStartofMonth().addDays(-1); //
            subs.Term_Length__c = null;
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
            
            subs.Subscription_Charge__c = 10.00;
            subs.Subscription_Type__c = 'Publication';
            subs.Subscription_Type_1__c = 'Publication';
            subs.Zuora__Status__c = 'Active';
            subs.Zuora__TermSettingType__c = 'EVERGREEN';
            
            subs.Grace_Period_Subscription__c = null;
            subs.Zuora__CustomerAccount__c =billAcc.Id;
            
            
            
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
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.BillingType__c = 'Full Prepaid';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.RatePlanType__c = 'Proration';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            insert prdRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
            prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
            prpList[0].zqu__Deleted__c = FALSE;
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test';
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            prpList[0].Name = 'SPC_NAME';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4];

            /*BATCH_JOB_SCHEDULER__c bjs = new BATCH_JOB_SCHEDULER__c();
            bjs.SFDC_Job_id__c = 'SFDCJobid1234567890';
            bjs.Batch_Run_Date__c = date.today();
            insert bjs;*/

            System.assertEquals(subs.Subscriber_Contact__c, con.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = date.today().adddays(1),
                    Restart_Date__c = date.today().adddays(30)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subs.Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;
            
            Unit_of_Measure__c uom = new Unit_of_Measure__c();
            uom.Name = 'Unit_of_Measure_Test_123';
            uom.Used_for__c = 'Non Chargeable Copy Usage';
            insert uom;
            
            List<Publication__c> pubList = new List<Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Beat Harry';    
            pub.Publication_Code__c = 'ADHD';
            pub.Published_Days__c = 'YYYYYYN';
            pub.Publication_Type__c = 'N';
            pub.Frequency_Code__c = 'D';
            pubList.add(pub);
            insert pubList;
            
            List<Non_Publication_Day__c> nonPubList = new List<Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                           
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'ADHD';
            nonpub.Publication__c = pub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Usage__c> usageList = new List<Usage__c>();
            Usage__c usa =  new Usage__c();
            usa.Subscription_Temp_Stop__c = subTempStops[0].id;
            usa.Unit_of_Measure__c = zUOM.id;
            usageList.add(usa);
            insert usageList;
        
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch();
            Database.BatchableContext bc;
            batch.execute(bc,subsList);
            //ID batchprocessid = Database.executeBatch(batch,200);
           //System.assertNotEquals(null, batchprocessid);


    }
    }// end of SP_MidMonthStartProrati

 static testmethod void testRecurring() {  // <-- This is the Original Test Method Signature
    
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

            Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];

            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcc.Billing_Type__c = 'Recurring Prepaid';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
 
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '123457397';
            key.Type__c = 'Number';
            //insert key;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Editedt By Alyana P. Navarro;
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Order_Type__c = 'Start';
            insert orderRec;
            
            Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
            cirPlanSched.Name = 'CIR Plan Schedule';
            cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
            cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
            cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
            cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            insert cirPlanSched;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;
            
            Date_Configuration__c thisDate = new Date_Configuration__c();
            thisDate.Date__c = date.Today()+60;
            thisDate.Name = 'Usage Reference Date';
            insert thisDate;
            
  //sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1) == sub.Zuora__SubscriptionEndDate__c)
          List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__Account__c = acc.Id;
            subs.Zuora__Zuora_Id__c = '1123';
            subs.Zuora__SubscriptionStartDate__c = date.Newinstance(2015, 08, 06);
            //subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            //subs.Zuora__SubscriptionEndDate__c = date.today()+30;
            subs.Zuora__SubscriptionEndDate__c = date.Newinstance(2015, 10, 05);
            subs.Term_Length__c = 2;
            subs.Term_Length1__c = '2';
            subs.Subscriber_Contact__c = con.Id;
            subs.Recipient_Contact__c = con.Id;
            subs.Recipient_Contact_1__c = ''+con.id;
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
            subs.Subscription_Charge__c = 10.00;
            subs.Subscription_Type__c = 'Publication';
            subs.Subscription_Type_1__c = 'Publication';
            subs.Zuora__Status__c = 'Active';
            subs.Zuora__TermSettingType__c = 'TERMED';
            subs.Grace_Period_Subscription__c = null;
            subs.Zuora__CustomerAccount__c =billAcc.Id;
            subsList.add(subs);
            insert subsList;
            
            Order__c orderRec1 = new Order__c();
            orderRec1.Id = orderRec.Id;
            orderRec1.Base_Subscription__c = subsList[0].id;
            update orderRec1;           

            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today().addDays(15);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Recurring Prepaid';
            orderline.Start_Date__c = date.today().addDays(1);
            insert orderline;           
            
            System.debug('subs.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(subs.Term_Length__c)).addDays(-1)' +subs.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(subs.Term_Length__c)).addDays(-1));
            System.debug('subs.Zuora__SubscriptionStartDate__c' + subs.Zuora__SubscriptionStartDate__c);
            System.debug('subs.Zuora__SubscriptionEndDate__c' +subs.Zuora__SubscriptionEndDate__c);
            
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
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.BillingType__c = 'Full Prepaid';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.RatePlanType__c = 'Proration';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            insert prdRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
            prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
            prpList[0].zqu__Deleted__c = FALSE;
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test';
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            prpList[0].Name = 'SPC_NAME';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4];

            /*BATCH_JOB_SCHEDULER__c bjs = new BATCH_JOB_SCHEDULER__c();
            bjs.SFDC_Job_id__c = 'SFDCJobid1234567890';
            bjs.Batch_Run_Date__c = date.today();
            insert bjs;*/

            System.assertEquals(subs.Subscriber_Contact__c, con.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = date.today().adddays(1),
                    Restart_Date__c = date.today().adddays(30)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subs.Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;
            
            Unit_of_Measure__c uom = new Unit_of_Measure__c();
            uom.Name = 'Unit_of_Measure_Test_123';
            uom.Used_for__c = 'Proration Charge Usage';
            insert uom;
            
            List<Publication__c> pubList = new List<Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Beat Harry';    
            pub.Publication_Code__c = 'ADHD';
            pub.Published_Days__c = 'YYYYYYN';
            pub.Publication_Type__c = 'N';
            pub.Frequency_Code__c = 'D';
            pubList.add(pub);
            insert pubList;
            
            List<Non_Publication_Day__c> nonPubList = new List<Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                           
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'ADHD';
            nonpub.Publication__c = pub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Usage__c> usageList = new List<Usage__c>();
            Usage__c usa =  new Usage__c();
            usa.Subscription_Temp_Stop__c = subTempStops[0].id;
            usa.Unit_of_Measure__c = zUOM.id;
            usageList.add(usa);
            insert usageList;
        
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch();
            Database.BatchableContext bc;
            batch.execute(bc,subsList);
            //ID batchprocessid = Database.executeBatch(batch,200);
           //System.assertNotEquals(null, batchprocessid);

        }
    }
    
    static testmethod void testRecurringPostpaid() {  
    
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

            Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];

            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcc.Billing_Type__c = 'Recurring Prepaid';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
 
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '123457397';
            key.Type__c = 'Number';
            //insert key;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Editedt By Alyana P. Navarro;
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Order_Type__c = 'Start';
            insert orderRec;
            
            Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
            cirPlanSched.Name = 'CIR Plan Schedule';
            cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
            cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
            cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
            cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            insert cirPlanSched;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;
   
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today().addDays(15);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            //orderline.Main_Package_Type__c = 'Recurring Postpaid';
            orderline.Main_Package_Billing_Type__c = 'Recurring Postpaid';
            orderline.Start_Date__c = date.today().addDays(1);
            insert orderline;
            
            Date_Configuration__c thisDate = new Date_Configuration__c();
            thisDate.Date__c =  date.Newinstance(2015, 10, 01);
            thisDate.Name = 'Usage Reference Date';
            insert thisDate;
            
                   
          List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__Account__c = acc.Id;
            subs.Zuora__Zuora_Id__c = '1123';
            subs.Zuora__SubscriptionStartDate__c = date.Newinstance(2015, 08, 10);
            //subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            //subs.Zuora__SubscriptionEndDate__c = date.today()+30;
            subs.Zuora__SubscriptionEndDate__c = date.Newinstance(2015, 10, 05);
            subs.Term_Length__c = 2;
            subs.Term_Length1__c = '2';
            subs.Subscriber_Contact__c = con.Id;
            subs.Recipient_Contact__c = con.Id;
            subs.Recipient_Contact_1__c = ''+con.id;
            subs.Main_Package_1__c = pack.id;
            subs.Zuora__Status__c = 'Active';
            subs.Order_Number__c = orderRec.Id;
            subs.Suppress_Vendor_Start_Notice__c = 'false';
            subs.Supressed_Acknowledgement_Letter__c = 'false';
            subs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subs.Urgent__c = 'false';
            subs.Vendor_Conversion__c = 'false';
            subs.Charity__c = 'false';
            subs.Billing_Type__c = 'Recurring Postpaid';
            subs.Subscription_Charge__c = 10.00;
            subs.Subscription_Type__c = 'Publication';
            subs.Subscription_Type_1__c = 'Publication';
            subs.Zuora__Status__c = 'Active';
            subs.Zuora__TermSettingType__c = 'Evergreen';
            subs.Grace_Period_Subscription__c = null;
            subs.Zuora__CustomerAccount__c =billAcc.Id;
            subsList.add(subs);
            insert subsList;
            
            
            /*System.debug('subs.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(subs.Term_Length__c)).addDays(-1)' +subs.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(subs.Term_Length__c)).addDays(-1));
            System.debug('subs.Zuora__SubscriptionStartDate__c' + subs.Zuora__SubscriptionStartDate__c);
            System.debug('subs.Zuora__SubscriptionEndDate__c' +subs.Zuora__SubscriptionEndDate__c);
            Date referenceDate = UsageHelper.getUsageReferenceDate();
            System.debug('referenceDate ' + referenceDate);*/
            
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
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.BillingType__c = 'REcurring Postpaid';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.RatePlanType__c = 'Proration';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            insert prdRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
            prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
            prpList[0].zqu__Deleted__c = FALSE;
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test';
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            prpList[0].Name = 'SPC_NAME';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4];

            /*BATCH_JOB_SCHEDULER__c bjs = new BATCH_JOB_SCHEDULER__c();
            bjs.SFDC_Job_id__c = 'SFDCJobid1234567890';
            bjs.Batch_Run_Date__c = date.today();
            insert bjs;*/

            System.assertEquals(subs.Subscriber_Contact__c, con.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = date.today().adddays(1),
                    Restart_Date__c = date.today().adddays(30)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subs.Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;
            
            Unit_of_Measure__c uom = new Unit_of_Measure__c();
            uom.Name = 'Unit_of_Measure_Test_123';
            uom.Used_for__c = 'Proration Charge Usage';
            insert uom;
            
            List<Publication__c> pubList = new List<Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Beat Harry';    
            pub.Publication_Code__c = 'ADHD';
            pub.Published_Days__c = 'YYYYYYN';
            pub.Publication_Type__c = 'N';
            pub.Frequency_Code__c = 'D';
            pubList.add(pub);
            insert pubList;
            
            List<Non_Publication_Day__c> nonPubList = new List<Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                           
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'ADHD';
            nonpub.Publication__c = pub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Usage__c> usageList = new List<Usage__c>();
            Usage__c usa =  new Usage__c();
            usa.Subscription_Temp_Stop__c = subTempStops[0].id;
            usa.Unit_of_Measure__c = zUOM.id;
            usageList.add(usa);
            insert usageList;
        
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch();
            Database.BatchableContext bc;
            batch.execute(bc,subsList);
            //ID batchprocessid = Database.executeBatch(batch,200);
           //System.assertNotEquals(null, batchprocessid);
        }

    }
    
     /* if (sub.Zuora__SubscriptionEndDate__c != null && sub.Term_Length__c != null 
                            && sub.Zuora__SubscriptionEndDate__c.monthsBetween(referenceDate) == 0 
                            && sub.Zuora__SubscriptionStartDate__c.addMonths(integer.valueOf(sub.Term_Length__c)).addDays(-1) == sub.Zuora__SubscriptionEndDate__c) */
     static testmethod void testRecurringPostpaid2() {  
    
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

            Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];

            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcc.Billing_Type__c = 'Recurring Prepaid';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            System.assertEquals(addressRec.Postal_Code__c, postal.Id);
 
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '123457397';
            key.Type__c = 'Number';
            //insert key;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Editedt By Alyana P. Navarro;
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            insert con;
            
            System.assertEquals(con.AccountId, acc.Id);

            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Order_Type__c = 'Start';
            insert orderRec;
            
            Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
            cirPlanSched.Name = 'CIR Plan Schedule';
            cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
            cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
            cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
            cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            insert cirPlanSched;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;
   
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today().addDays(15);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            //orderline.Main_Package_Type__c = 'Recurring Postpaid';
            orderline.Main_Package_Billing_Type__c = 'Recurring Postpaid';
            orderline.Start_Date__c = date.today().addDays(1);
            insert orderline;
            
            Date_Configuration__c thisDate = new Date_Configuration__c();
            thisDate.Date__c =  date.Newinstance(2015, 10, 01);
            thisDate.Name = 'Usage Reference Date';
            insert thisDate;
            
                   
          List<Zuora__Subscription__c> subsList = new List<Zuora__Subscription__c>(); 
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__Account__c = acc.Id;
            subs.Zuora__Zuora_Id__c = '1123';
            subs.Zuora__SubscriptionStartDate__c = date.Newinstance(2015, 08, 6);
            //subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            //subs.Zuora__SubscriptionEndDate__c = date.today()+30;
            subs.Zuora__SubscriptionEndDate__c = date.Newinstance(2015, 10, 05);
            subs.Term_Length__c = 2;
            subs.Term_Length1__c = '2';
            subs.Subscriber_Contact__c = con.Id;
            subs.Recipient_Contact__c = con.Id;
            subs.Recipient_Contact_1__c = ''+con.id;
            subs.Main_Package_1__c = pack.id;
            subs.Zuora__Status__c = 'Active';
            subs.Order_Number__c = orderRec.Id;
            subs.Suppress_Vendor_Start_Notice__c = 'false';
            subs.Supressed_Acknowledgement_Letter__c = 'false';
            subs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subs.Urgent__c = 'false';
            subs.Vendor_Conversion__c = 'false';
            subs.Charity__c = 'false';
            subs.Billing_Type__c = 'Recurring Postpaid';
            subs.Subscription_Charge__c = 10.00;
            subs.Subscription_Type__c = 'Publication';
            subs.Subscription_Type_1__c = 'Publication';
            subs.Zuora__Status__c = 'Active';
            subs.Zuora__TermSettingType__c = 'Evergreen';
            subs.Grace_Period_Subscription__c = null;
            subs.Zuora__CustomerAccount__c =billAcc.Id;
            subsList.add(subs);
            insert subsList;
            
            
            /*System.debug('subs.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(subs.Term_Length__c)).addDays(-1)' +subs.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(subs.Term_Length__c)).addDays(-1));
            System.debug('subs.Zuora__SubscriptionStartDate__c' + subs.Zuora__SubscriptionStartDate__c);
            System.debug('subs.Zuora__SubscriptionEndDate__c' +subs.Zuora__SubscriptionEndDate__c);
            Date referenceDate = UsageHelper.getUsageReferenceDate();
            System.debug('referenceDate ' + referenceDate);*/
            
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
            zSubProdCharge[0].PublicationCode__c = 'Code001';
            insert zSubProdCharge; 
              
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-0000075';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.BillingType__c = 'REcurring Postpaid';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.RatePlanType__c = 'Proration';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            insert prdRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
            prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
            prpList[0].zqu__Deleted__c = FALSE;
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test';
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            prpList[0].Name = 'SPC_NAME';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4];

            /*BATCH_JOB_SCHEDULER__c bjs = new BATCH_JOB_SCHEDULER__c();
            bjs.SFDC_Job_id__c = 'SFDCJobid1234567890';
            bjs.Batch_Run_Date__c = date.today();
            insert bjs;*/

            System.assertEquals(subs.Subscriber_Contact__c, con.Id);
            System.assertEquals(cas.Order__c, orderRec.Id);
            

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = date.today().adddays(1),
                    Restart_Date__c = date.today().adddays(30)
                )
            };
            insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subs.Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            insert subTempStops;

            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;
            
            Unit_of_Measure__c uom = new Unit_of_Measure__c();
            uom.Name = 'Unit_of_Measure_Test_123';
            uom.Used_for__c = 'Proration Charge Usage';
            insert uom;
            
            List<Publication__c> pubList = new List<Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Beat Harry';    
            pub.Publication_Code__c = 'ADHD';
            pub.Published_Days__c = 'YYYYYYN';
            pub.Publication_Type__c = 'N';
            pub.Frequency_Code__c = 'D';
            pubList.add(pub);
            insert pubList;
            
            List<Non_Publication_Day__c> nonPubList = new List<Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                           
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'ADHD';
            nonpub.Publication__c = pub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Usage__c> usageList = new List<Usage__c>();
            Usage__c usa =  new Usage__c();
            usa.Subscription_Temp_Stop__c = subTempStops[0].id;
            usa.Unit_of_Measure__c = zUOM.id;
            usageList.add(usa);
            insert usageList;
        
             List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>(1);
             try {
                    batchJobSchedulerList[0].SFDC_Job_id__c = '';
                    batchJobSchedulerList[0].Status__c = 'STARTED';
                    batchJobSchedulerList[0].Batch_Code__c = 'SP001';
                    batchJobSchedulerList[0].Batch_Run_Date__c = date.Today() +1;
                    insert batchJobSchedulerList;

            }
            catch (System.NullPointerException e) {       }
        
                    
            SP_MidMonthStartProrationBatch batch = new SP_MidMonthStartProrationBatch();
            Database.BatchableContext bc;
            batch.execute(bc,subsList);
            
            
           
            
            
           
            //ID batchprocessid = Database.executeBatch(batch,200);
           //System.assertNotEquals(null, batchprocessid);
            
           
    }
                    
}}