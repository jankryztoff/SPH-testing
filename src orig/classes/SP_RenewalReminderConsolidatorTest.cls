/* April Veloso
   11/26/2015
   Test Class for SP_RenewalReminderConsolidator
*/

@isTest (seeAllData= false)
private class SP_RenewalReminderConsolidatorTest{
    static testMethod void TestSP_RenewalReminderConsolidatorTest() {
            
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            database.insert(key); 
            
            Other__c other = new Other__c();
            other.Name = 'DTL';
            other.Value__c = '23:59';
            database.insert(other); 
            
            Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
            cir.Name = 'CIR Plan Schedule';
            cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
            cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
            cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
            cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            database.insert(cir); 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.Vendor_Code__c = '01';
            database.insert(acc);
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            database.insert(address);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.id;
            con.HomePhone__c = '321324321434';
            con.Billing_Indicator__c = True;
            //contact1.Recipient_Indicator__c = true;
            con.Address__c = address.Id;
            database.insert(con);  
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            database.insert(billAcc);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            database.insert(pack);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack.Id;
            sub.Product_Code__c = '01';
            sub.Term_Length__c = 1;
            sub.Term_Length1__c = '1'; 
            sub.Main_Package_1__c = pack.Id;
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
            database.insert(sub);
            
            Letter_Print_Request__c letterPrintParent = new Letter_Print_Request__c();
            letterPrintParent.Billing_Account__c = billAcc.id;
            letterPrintParent.Language_Medium__c = 'M';
            database.insert(letterPrintParent);
            
            Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
            letterPrintRequest.Billing_Account__c = billAcc.id;
            letterPrintRequest.Language_Medium__c = 'M';
            letterPrintRequest.Parent_Letter_Print_Request__c =  letterPrintParent.id;
            letterPrintRequest.Status__c = 'New';
            letterPrintRequest.Type__c = 'Master';
            letterPrintRequest.Letter_Type__c = 'Acknowledgment Letter';
            letterPrintRequest.Status_Email__c = 'New';
            database.insert(letterPrintRequest);
            
            Id jobIdParam = acc.id;
            Database.BatchableContext BC;
            List<Letter_Print_Request__c> scope = [SELECT Id, Billing_Account__c, Language_Medium__c, Parent_Letter_Print_Request__c, Status__c,Type__c,Letter_Type__c FROM Letter_Print_Request__c where id =: letterPrintRequest.id];
            
            Test.startTest();    
                SP_RenewalReminderConsolidator batch = new SP_RenewalReminderConsolidator(jobIdParam, '', 'Acknowledgment Letter', '', true);
                database.executeBatch(batch, 200);
                batch.execute(BC, scope);
            Test.stopTest();
                 
    }
    static testMethod void TestSP_RenewalReminderConsolidatorTest2() {
            
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            database.insert(key); 
            
            Other__c other = new Other__c();
            other.Name = 'DTL';
            other.Value__c = '23:59';
            database.insert(other); 
            
            Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
            cir.Name = 'CIR Plan Schedule';
            cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
            cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
            cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
            cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            database.insert(cir); 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.Vendor_Code__c = '01';
            database.insert(acc);
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            database.insert(address);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.id;
            con.HomePhone__c = '321324321434';
            con.Billing_Indicator__c = True;
            //contact1.Recipient_Indicator__c = true;
            con.Address__c = address.Id;
            database.insert(con);  
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            database.insert(billAcc);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            database.insert(pack);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack.Id;
            sub.Product_Code__c = '01';
            sub.Term_Length__c = 1;
            sub.Term_Length1__c = '1'; 
            sub.Main_Package_1__c = pack.Id;
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
            database.insert(sub);
                       
            Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
            letterPrintRequest.Billing_Account__c = billAcc.id;
            letterPrintRequest.Language_Medium__c = 'M';
            letterPrintRequest.Parent_Letter_Print_Request__c =  null;
            letterPrintRequest.Status__c = 'New';
            letterPrintRequest.Type__c = 'Master';
            letterPrintRequest.Letter_Type__c = 'Acknowledgment Letter';
            letterPrintRequest.Status_Email__c = 'New';
            database.insert(letterPrintRequest);
            
            Id jobIdParam = acc.id;
            Database.BatchableContext BC;
            List<Letter_Print_Request__c> scope = [SELECT Id, Billing_Account__c, Language_Medium__c, Status__c,Type__c,Letter_Type__c, Parent_Letter_Print_Request__c FROM Letter_Print_Request__c where id =: letterPrintRequest.id];
            
            Test.startTest();    
            letterPrintRequest.Parent_Letter_Print_Request__c =  null;
            database.update(letterPrintRequest);
            SP_RenewalReminderConsolidator batch = new SP_RenewalReminderConsolidator(jobIdParam, '', 'Acknowledgment Letter', '', true);
            database.executeBatch(batch, 200);
            batch.execute(BC, scope);
            Test.stopTest();
        }
}
//(Id jobIdParam, String batchCodeParam, String letterTypeParam, String sessionIdParam, Boolean isApexJobSuccessfulParam)