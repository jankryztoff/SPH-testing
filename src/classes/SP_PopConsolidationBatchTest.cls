/**
 * Class Name: <SP_PopConsolidationBatchTest>
 * @author: <JhustinPinoy>
 * Date: <10/03/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for SP_PopConsolidationBatch>
 */

@isTest 
public class SP_PopConsolidationBatchTest {
    
    
    static testMethod void testSP_PopConsolidationBatch(){
        
        //Create a new user with Standard User Profile
        Profile prof = [SELECT id FROM Profile where name='System Administrator'];
        system.assert(prof.id != null );
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.id, 
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
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
            
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            }
            insert pItems;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            
            Key_Id__c keyId  = new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER',Id__c='30465208', Type__c='Number');
            insert keyId;
            id rtId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            con.RecordTypeId = rtId ;
            con.Recipient_Indicator__c = true;
            // END :            
            insert con;
            
            List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role',       Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='30465208', Type__c='Number'),
            new Key_Id__c(Name='Account_Direct Corporate', Id__c=acc.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Account_Vendor Subscriber', Id__c=acc.id,Type__c='RecordType'),
            new Key_Id__c(Name='Account_Direct Individual', Id__c=acc.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=con.id ,Type__c='RecordType')
            };
           // kisList.add(keyId);
            Database.insert(kisList);
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
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
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            try
            {
                insert new List<sObject>{cas, subrecs[0], subrecs[1], subrecs[2], subrecs[3], orderline};
            } catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
            
            BT_CO_MIRO_SubscriptionIssueFile__c testSubscriptionFile = new 
                                                                        BT_CO_MIRO_SubscriptionIssueFile__c (house_type__c='1',
                                                                                                             office_house_mail_indicator__c = '1',
                                                                                                             postal_sector__c = '12',
                                                                                                             Publication_Code__c = '1234',
                                                                                                             Publication_Issue_Date__c = date.today(),
                                                                                                             vendor_number__c = '2456'
                                                                                                             );
            
            
            insert testSubscriptionFile;
            
            list<BT_CO_MIRO_SubscriptionIssueFile__c > listSubs = new list<BT_CO_MIRO_SubscriptionIssueFile__c > ();
            listSubs.add(testSubscriptionFile );
            
           Test.startTest();
          // try {
                
                SP_PopConsolidationBatch batch = new SP_PopConsolidationBatch(date.today());                        
                Database.executeBatch(batch);
          /* }
           catch(exception e) {
                 system.debug('\n\n ***error in batch *** ' + e.getMessage() + '\n\n ');             
                 system.debug('\n\n ***error in batch *** ' + e.getLineNumber() + '\n\n ');             
                 system.debug('\n\n ***error in batch *** ' + e.getStackTraceString() + '\n\n ');                                               
           }*/
           Test.stopTest();
        }
    }
    static testMethod void testSP_PopConsolidationBatch_2(){
        
        //Create a new user with Standard User Profile
        Profile prof = [SELECT id FROM Profile where name='System Administrator'];
        system.assert(prof.id != null );
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.id, 
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
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
            
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            }
            insert pItems;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            
            Key_Id__c keyId  = new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER',Id__c='30465208', Type__c='Number');
            insert keyId;
            id rtId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            con.RecordTypeId = rtId ;
            con.Recipient_Indicator__c = true;
            // END :            
            insert con;
            
            List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role',       Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='30465208', Type__c='Number'),
            new Key_Id__c(Name='Account_Direct Corporate', Id__c=acc.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Account_Vendor Subscriber', Id__c=acc.id,Type__c='RecordType'),
            new Key_Id__c(Name='Account_Direct Individual', Id__c=acc.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=con.id ,Type__c='RecordType')
            };
           // kisList.add(keyId);
            Database.insert(kisList);
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
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
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            try
            {
                insert new List<sObject>{cas, subrecs[0], subrecs[1], subrecs[2], subrecs[3], orderline};
            } catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
            
            BT_CO_MIRO_SubscriptionIssueFile__c testSubscriptionFile = new 
                                                                        BT_CO_MIRO_SubscriptionIssueFile__c (house_type__c='1',
                                                                                                             office_house_mail_indicator__c = '1',
                                                                                                             postal_sector__c = '12',
                                                                                                             Publication_Code__c = '1234',
                                                                                                             Publication_Issue_Date__c = date.today(),
                                                                                                             vendor_number__c = '2456'
                                                                                                             );
            
            
            insert testSubscriptionFile;
            
            list<BT_CO_MIRO_SubscriptionIssueFile__c > listSubs = new list<BT_CO_MIRO_SubscriptionIssueFile__c > ();
            listSubs.add(testSubscriptionFile );
            
           Test.startTest();
          // try {
                
                SP_PopConsolidationBatch batch = new SP_PopConsolidationBatch();                        
                Database.executeBatch(batch);
          /* }
           catch(exception e) {
                 system.debug('\n\n ***error in batch *** ' + e.getMessage() + '\n\n ');             
                 system.debug('\n\n ***error in batch *** ' + e.getLineNumber() + '\n\n ');             
                 system.debug('\n\n ***error in batch *** ' + e.getStackTraceString() + '\n\n ');                                               
           }*/
           Test.stopTest();
        }
    }
    
    
    
}