/** 
    * class Name: AutoApproverTest
    * @author: C. Lin
    * Date: 13April2016
    * @description: Test Class for AutoApprover
    * @history:
    * Erika Hidalgo   05/10/2016    
    */

    @isTest (seeAllData = true)
    public  without sharing class AutoApproverTest {
        static testMethod void ApproveTest(){
            
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
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            database.insert(acc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Bundle';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'PKGCD001';
            insert pack;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
            billAcc.Billing_Contact__c = con.id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__DefaultPaymentMethod__c = 'Cash';
            insert billAcc;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Billing_Account__c = billAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Order_Type__c = 'Start';
            insert order;

            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2017, 12, 2);
            orderline.Start_Date__c = date.today()+1;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Bundle';
            insert orderline;
            
            List<Zuora__Subscription__c> subRecsList = TestDataFactory.createSubscription(2);
            subRecsList[0].Zuora__Account__c = acc.Id;
            subRecsList[0].Zuora__Zuora_Id__c = '1123';
            subRecsList[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecsList[0].Subscriber_Contact__c = con.Id;
            subRecsList[0].Recipient_Contact__c = con.Id;
            subRecsList[0].Main_Package_1__c = pack.id;
            subRecsList[0].Zuora__Status__c = 'Active';
            subRecsList[0].Order_Number__c = order.Id;
            subRecsList[0].Order_Number_1__c = order.id;
            subRecsList[0].Suppress_Vendor_Start_Notice__c = 'false';
            subRecsList[0].Supressed_Acknowledgement_Letter__c = 'false';
            subRecsList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecsList[0].Urgent__c = 'false';
            subRecsList[0].Vendor_Conversion__c = 'false';
            subRecsList[0].Charity__c = 'false';
            subRecsList[0].Billing_Type__c = 'Full Prepaid';
            subRecsList[0].Order_Line_Item_Number__c = orderline.id;
            subRecsList[0].Subscription_Type_1__c = 'Publication';
            subRecsList[0].Subscription_Type__c = 'Publication';
            subRecsList[0].Zuora__Status__c = 'Active';
            subRecsList[0].Generate_Invoice1__c = 'false';
            subRecsList[0].Zuora__CustomerAccount__c = billAcc.Id;
            
            subRecsList[1].Zuora__Account__c = acc.Id;
            subRecsList[1].Zuora__Zuora_Id__c = '1123';
            subRecsList[1].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecsList[1].Subscriber_Contact__c = con.Id;
            subRecsList[1].Recipient_Contact__c = con.Id;
            subRecsList[1].Main_Package_1__c = pack.id;
            subRecsList[1].Zuora__Status__c = 'Active';
            subRecsList[1].Order_Number__c = order.Id;
            subRecsList[1].Order_Number_1__c = order.id;
            subRecsList[1].Suppress_Vendor_Start_Notice__c = 'false';
            subRecsList[1].Supressed_Acknowledgement_Letter__c = 'false';
            subRecsList[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecsList[1].Urgent__c = 'false';
            subRecsList[1].Vendor_Conversion__c = 'false';
            subRecsList[1].Charity__c = 'false';
            subRecsList[1].Billing_Type__c = 'Full Prepaid';
            subRecsList[1].Order_Line_Item_Number__c = orderline.id;
            subRecsList[1].Subscription_Type_1__c = 'Publication';
            subRecsList[1].Subscription_Type__c = 'Publication';
            subRecsList[1].Zuora__Status__c = 'Active';
            subRecsList[1].Generate_Invoice1__c = 'false';
            subRecsList[1].Zuora__CustomerAccount__c = billAcc.Id;
            
            insert subRecsList;
            system.assertEquals(subRecsList[0].Zuora__CustomerAccount__c, billAcc.Id);
            
            List<Case> caseRecList = TestDataFactory.createCase(2, 'Change of Subscription');
            caseRecList[0].Temp_Stop_Sub__c = subRecsList[0].Id;
            caseRecList[0].Temp_Stop_Date__c = date.today();
            caseRecList[0].Restart_Date__c = date.today() + 10;
            caseRecList[0].Temp_Stop_Type__c = 'New';
            caseRecList[0].Requires_Urgent_Approval__c = TRUE;
            caseRecList[0].Status = 'Pending';
            caseRecList[0].Request_for_Waiving_of_Admin_Charge__c = FALSE;
            caseRecList[0].Sub_Status__c = 'Change of Subscription Completed';
            
            caseRecList[1].Temp_Stop_Sub__c = subRecsList[1].Id;
            caseRecList[1].Temp_Stop_Date__c = date.today();
            caseRecList[1].Restart_Date__c = date.today() + 10;
            caseRecList[1].Temp_Stop_Type__c = 'New';
            caseRecList[1].Requires_Urgent_Approval__c = TRUE;
            caseRecList[1].Status = 'Pending';
            caseRecList[1].Request_for_Waiving_of_Admin_Charge__c = FALSE;
            caseRecList[1].Sub_Status__c = 'Change of Subscription Completed';
            insert caseRecList;
            
            Zuora__SubscriptionProductCharge__c spc = new Zuora__SubscriptionProductCharge__c();
            spc.Name = 'Subscription Product & Charge Test';
            spc.Zuora__Subscription__c = subRecsList[0].Id;
            spc.Zuora__Zuora_Id__c = '000001234';
            spc.Zuora__Account__c = acc.Id;
            insert spc;
            

            approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();     
            req1.setComments('Submitting record for approval.');
            req1.setSubmitterId(testUser.Id);
            req1.setObjectId(caseRecList[0].id);
            req1.setProcessDefinitionNameOrId('CS_UrgentChangeOfSubOnRequest');
            req1.setSkipEntryCriteria(true);
            approval.ProcessResult result = Approval.process(req1);
            
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();// Instantiate the new ProcessWorkitemRequest object and populate it
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(newWorkItemIds.get(0));// Use the ID from the newly created item to specify the item to be worked
            Approval.ProcessResult result2 =  Approval.process(req2);// Submit the request for approval
            
            Set<Id> tsCaseIdsForApproveSet = new Set<Id>();
            tsCaseIdsForApproveSet.add(caseRecList[0].Id);
            
            test.startTest();
            System.enqueueJob(new AutoApprover(tsCaseIdsForApproveSet, 'Approved'));
            test.stopTest();
        }
        static testMethod void ApproveTest1(){
            
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
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            database.insert(acc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Bundle';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'PKGCD001';
            insert pack;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
            billAcc.Billing_Contact__c = con.id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__DefaultPaymentMethod__c = 'Cash';
            insert billAcc;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Billing_Account__c = billAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Order_Type__c = 'Start';
            insert order;

            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2017, 12, 2);
            orderline.Start_Date__c = date.today()+1;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Bundle';
            insert orderline;
            
            List<Zuora__Subscription__c> subRecsList = TestDataFactory.createSubscription(2);
            subRecsList[0].Zuora__Account__c = acc.Id;
            subRecsList[0].Zuora__Zuora_Id__c = '1123';
            subRecsList[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecsList[0].Subscriber_Contact__c = con.Id;
            subRecsList[0].Recipient_Contact__c = con.Id;
            subRecsList[0].Main_Package_1__c = pack.id;
            subRecsList[0].Zuora__Status__c = 'Active';
            subRecsList[0].Order_Number__c = order.Id;
            subRecsList[0].Order_Number_1__c = order.id;
            subRecsList[0].Suppress_Vendor_Start_Notice__c = 'false';
            subRecsList[0].Supressed_Acknowledgement_Letter__c = 'false';
            subRecsList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecsList[0].Urgent__c = 'false';
            subRecsList[0].Vendor_Conversion__c = 'false';
            subRecsList[0].Charity__c = 'false';
            subRecsList[0].Billing_Type__c = 'Full Prepaid';
            subRecsList[0].Order_Line_Item_Number__c = orderline.id;
            subRecsList[0].Subscription_Type_1__c = 'Publication';
            subRecsList[0].Subscription_Type__c = 'Publication';
            subRecsList[0].Zuora__Status__c = 'Active';
            subRecsList[0].Generate_Invoice1__c = 'false';
            subRecsList[0].Zuora__CustomerAccount__c = billAcc.Id;
            
            subRecsList[1].Zuora__Account__c = acc.Id;
            subRecsList[1].Zuora__Zuora_Id__c = '1123';
            subRecsList[1].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecsList[1].Subscriber_Contact__c = con.Id;
            subRecsList[1].Recipient_Contact__c = con.Id;
            subRecsList[1].Main_Package_1__c = pack.id;
            subRecsList[1].Zuora__Status__c = 'Active';
            subRecsList[1].Order_Number__c = order.Id;
            subRecsList[1].Order_Number_1__c = order.id;
            subRecsList[1].Suppress_Vendor_Start_Notice__c = 'false';
            subRecsList[1].Supressed_Acknowledgement_Letter__c = 'false';
            subRecsList[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecsList[1].Urgent__c = 'false';
            subRecsList[1].Vendor_Conversion__c = 'false';
            subRecsList[1].Charity__c = 'false';
            subRecsList[1].Billing_Type__c = 'Full Prepaid';
            subRecsList[1].Order_Line_Item_Number__c = orderline.id;
            subRecsList[1].Subscription_Type_1__c = 'Publication';
            subRecsList[1].Subscription_Type__c = 'Publication';
            subRecsList[1].Zuora__Status__c = 'Active';
            subRecsList[1].Generate_Invoice1__c = 'false';
            subRecsList[1].Zuora__CustomerAccount__c = billAcc.Id;
            insert subRecsList;
            system.assertEquals(subRecsList[0].Zuora__CustomerAccount__c, billAcc.Id);
            
            List<Case> caseRecList = TestDataFactory.createCase(2, 'Change of Subscription');
            caseRecList[0].Temp_Stop_Sub__c = subRecsList[0].Id;
            caseRecList[0].Temp_Stop_Date__c = date.today();
            caseRecList[0].Restart_Date__c = date.today() + 10;
            caseRecList[0].Temp_Stop_Type__c = 'New';
            caseRecList[0].Requires_Urgent_Approval__c = TRUE;
            caseRecList[0].Status = 'Pending';
            caseRecList[0].Request_for_Waiving_of_Admin_Charge__c = FALSE;
            caseRecList[0].Sub_Status__c = 'Change of Subscription Completed';
            
            caseRecList[1].Temp_Stop_Sub__c = subRecsList[1].Id;
            caseRecList[1].Temp_Stop_Date__c = date.today();
            caseRecList[1].Restart_Date__c = date.today() + 10;
            caseRecList[1].Temp_Stop_Type__c = 'New';
            caseRecList[1].Requires_Urgent_Approval__c = TRUE;
            caseRecList[1].Status = 'Pending';
            caseRecList[1].Request_for_Waiving_of_Admin_Charge__c = FALSE;
            caseRecList[1].Sub_Status__c = 'Change of Subscription Completed';
            insert caseRecList;
            system.assertEquals(caseRecList.size(), 2);
            
            Zuora__SubscriptionProductCharge__c spc = new Zuora__SubscriptionProductCharge__c();
            spc.Name = 'Subscription Product & Charge Test';
            spc.Zuora__Subscription__c = subRecsList[0].Id;
            spc.Zuora__Zuora_Id__c = '000001234';
            spc.Zuora__Account__c = acc.Id;
            insert spc;
            

            approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();     
            req1.setComments('Submitting record for approval.');
            req1.setSubmitterId(testUser.Id);
            req1.setObjectId(caseRecList[0].id);
            req1.setProcessDefinitionNameOrId('CS_UrgentChangeOfSubOnRequest');
            req1.setSkipEntryCriteria(true);
            approval.ProcessResult result = Approval.process(req1);
            
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();// Instantiate the new ProcessWorkitemRequest object and populate it
            req2.setComments('Approve request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(newWorkItemIds.get(0));// Use the ID from the newly created item to specify the item to be worked
            Approval.ProcessResult result2 =  Approval.process(req2);// Submit the request for approval
            
            
            Set<Id> tsCaseIdsForApproveSet = new Set<Id>();
            tsCaseIdsForApproveSet.add(caseRecList[0].Id);
            
            test.startTest();
            System.enqueueJob(new AutoApprover(tsCaseIdsForApproveSet, 'Reject'));
            test.stopTest();
            
            
        }
    }