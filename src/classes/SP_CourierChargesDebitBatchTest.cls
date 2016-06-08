/**
 * Class Name: <SP_CourierChargesDebitBatchTest>
 * @author: <JhustinPinoy>
 * Date: <10/09/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for SP_CourierChargesDebitBatch>
 */

@isTest (Seealldata = TRUE)
public class SP_CourierChargesDebitBatchTest {
    
    
    static testMethod void testSP_CourierChargesDebitBatch(){
        
        //Create a new user with Standard User Profile
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
            acc.Vendor_Group__c = 'A';
            
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
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
            
            Case casRec = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            casRec.Order__c = orderRec.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Vendor_1__c = acc.Id;
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
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            //cas.Order__c = orderRec.Id;
            cas.Courier_Fee__c = 10;
            cas.Paper_Fee__c = 50;
            cas.Subscription_Name__c = subrecs[0].Id;
            cas.Effective_Date__c = system.today();
            cas.Vendor_Chargeable_Courier__c = TRUE;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            insert new List<sObject>{casRec, subrecs[0], subrecs[1], subrecs[2], subrecs[3], cas, orderline};
            
            Test.startTest();
            SP_CourierChargesDebitBatch batch = new SP_CourierChargesDebitBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);
            Test.stopTest();
        }
    }
}