/**
 * Class Name: <Asia1Activation_Test>
 * @author: <accenture dev>
 * Date: <19/09/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for Asia1Activation>
*/

@isTest(Seealldata = false)

    public class SP_loadMonthlyUsageDataBatch_Test {
    
   static testmethod void test2() {
    
    
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock());

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
            
            Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;

            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};

            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;

            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;

            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
		//Start D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery
            /*Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '1234567890';
            key.Type__c = 'Number';
            insert key; */
		//End D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;              
            // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;            
            // END : CCB 002 12/2/2014
            insert con;

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

            /*Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;*/
            
            /*Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Vendor_Subscription_ID__c = subsVen.Id;
            oli.Main_Package_ID__c = pack.Id;
            oli.Vendor_Mailing_Agent__c = venAccount.Id;
            oli.DTL_Date__c= '14:00';
            insert oli;*/
            
            
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(1);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                //subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Zuora__SubscriptionEndDate__c = date.today()+30;
                subRec.Zuora__SubscriptionStartDate__c = date.today();
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                //subRec.Order_Line_Item_Number__c = oli.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            
             insert new List<sObject>{subrecs[0]};
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = subRecs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c = 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__ProductName__c = 'TEST NAME';
            zSubProdCharge[0].Product_Code__c = 'PUBX';
            zSubProdCharge[0].Zuora__Price__c = 20;
            zSubProdCharge[0].Zuora__BillingPeriod__c = 'Quarterly';
            zSubProdCharge[0].Zuora__Quantity__c = 18732;
            zSubProdCharge[0].Zuora__UOM__c ='ZuoraUOM';
            insert zSubProdCharge;
            
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
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test' ;
            
            
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4]; 

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    //Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = date.today().adddays(1),
                    Restart_Date__c = System.today().adddays(2)
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

            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            Test.startTest(); 
            insert zUOM;
            
            List<Usage__c> usageList = new List<Usage__c>();
            Usage__c usa = new Usage__c();
            usa.Unit_of_Measure__c = zUOM.id;
            usa.Send_to_Zuora_Time__c = date.today();
            usa.Status__c = 'New' ;
            usageList.add(usa);          
            insert usageList;
         

            List<Zuora__SubscriptionProductCharge__c> spcList = TestDataFactory.createSubProductCharge(1);
            
       
       SP_loadMonthlyUsageDataBatch batch = new SP_loadMonthlyUsageDataBatch();
       ID batchprocessid = Database.executeBatch(batch, 200);
       //Database.BatchableContext bc;
       //batch.execute(bc,usageList);
       Test.stopTest(); 
          }
          }catch(Zuora.zremoteException e) {
          }  
          

    }

    
    static testmethod void test3() {

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
            
           Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
           insert dtl;

            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};

            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;

            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;

            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
		//Start D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery
            /*Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '1111111123';
            key.Type__c = 'Number';
            insert key;*/
		//End D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;              
            // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Customer Contact'];
            con.RecordTypeId = rt.id;
            con.Recipient_Indicator__c = true;            
            // END : CCB 002 12/2/2014
            insert con;

            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
            
            Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
            cirPlanSched.Name = 'Test CIR Plan Schedule';
            cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
            cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
            cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
            cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            insert cirPlanSched;

            /*Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;*/
            
            /*Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Vendor_Subscription_ID__c = subsVen.Id;
            oli.Main_Package_ID__c = pack.Id;
            oli.Vendor_Mailing_Agent__c = venAccount.Id;
            oli.DTL_Date__c= '14:00';
            insert oli;*/
            
            
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(1);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                //subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Zuora__SubscriptionEndDate__c = date.today()+30;
                subRec.Zuora__SubscriptionStartDate__c = date.today();
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                //subRec.Order_Line_Item_Number__c = oli.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Zuora__CustomerAccount__c = billAcc.Id;
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            
             insert new List<sObject>{subrecs[0]};
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = subRecs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c = 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__ProductName__c = 'TEST NAME';
            zSubProdCharge[0].Product_Code__c = 'PUBX';
            zSubProdCharge[0].Zuora__Price__c = 20;
            zSubProdCharge[0].Zuora__BillingPeriod__c = 'Quarterly';
            zSubProdCharge[0].Zuora__Quantity__c = 18732;
            zSubProdCharge[0].Zuora__UOM__c ='ZuoraUOM';
            insert zSubProdCharge;
            
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
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test' ;
            
            
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4]; 

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    //Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = date.today().adddays(1),
                    Restart_Date__c = System.today().adddays(2)
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

            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            Test.startTest(); 
            insert zUOM;
            
            List<Usage__c> usageList = new List<Usage__c>();
		//Start D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery			
            Usage__c usageRec = new Usage__c();
            usageRec.Unit_of_Measure__c = zUOM.id;
            usageRec.Send_to_Zuora_Time__c = date.today();
            usageRec.Status__c = 'Failed' ;
            usageList.add(usageRec);
			
            insert usageList;
         
			Email__c e = new Email__c();
			e.Name = 'Usage Email';
			e.Email__c = 'testemailonly@noemail.com';
			insert e;
			
            List<Zuora__SubscriptionProductCharge__c> spcList = TestDataFactory.createSubProductCharge(1);
            
       
           SP_loadMonthlyUsageDataBatch batch = new SP_loadMonthlyUsageDataBatch();
           //ID batchprocessid = 
		   Database.executeBatch(batch, 200);
           //Database.BatchableContext bc;
           //batch.execute(bc,usageList);
		   
		   Set<String> fakeId = new Set<String>{'12345', '123478'};
		   SP_loadMonthlyUsageDataBatch batch2 = new SP_loadMonthlyUsageDataBatch(fakeId, 1);
           //ID batchprocessid2 = 
		   Database.executeBatch(batch2, 200);
           //batch2.execute(bc,usageList);

		   SP_loadMonthlyUsageDataBatch batch3 = new SP_loadMonthlyUsageDataBatch(fakeId, 2);
           //ID batchprocessid3 = 
		   Database.executeBatch(batch3, 200);
           //batch3.execute(bc,usageList);
		//End D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery		   
           Test.stopTest(); 
       
       }
       
   }//end of testmethod test2
    
    static testmethod void unitTest1() {  // <-- This is the Original Test Method Signature
    
        /*BT_CO_MIRO_SubscriptionIssueFile__c sif1 = new BT_CO_MIRO_SubscriptionIssueFile__c();
        sif1.Publication_Code__c = 'code';
        sif1.Publication_Issue_Date__c = System.Today();
        sif1.postal_sector__c = 'MN';
        sif1.vendor_number__c = '0001C';
        sif1.office_house_mail_indicator__c = 'Y';
        sif1.house_type__c = 'A';
        sif1.sub_channel_code__c = 'ABC';
        sif1.subscription_copies__c = 200;
        sif1.subscriber_count__c = 100;
        
        insert sif1;*/
        
        /*zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            Test.startTest(); 
            insert zUOM;
            
            List<Usage__c> usageList = new List<Usage__c>();
            Usage__c usa = new Usage__c();
            usa.Unit_of_Measure__c = zUOM.id;
            usa.Send_to_Zuora_Time__c = date.today();
            usa.Status__c = 'Failed' ;
            usageList.add(usa);          
            insert usageList;*/
        
        SP_loadMonthlyUsageDataBatch batch = new SP_loadMonthlyUsageDataBatch();
        //.BatchableContext bc;
       // batch.execute(bc,usageList);
        ID batchprocessid = Database.executeBatch(batch,200);
        System.assertNotEquals(null, batchprocessid);
    }
}//end of SP_loadMonthlyUsageDataBatchTest