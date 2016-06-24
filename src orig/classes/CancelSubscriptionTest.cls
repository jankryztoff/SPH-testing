/**
 * Class Name: <CancelSubscriptionTest>
 * @author: <JhustinPinoy>
 * Date: <10/02/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for CancelSubscription>
 */

@isTest (Seealldata = TRUE)
public class CancelSubscriptionTest {
    
    
    static testMethod void testCancelSubscription(){
        
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
            postal.Name = '01';
            insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Account_Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            

            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            //insert new List<sObject>{postal, acc, pack};
            
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
            billAcc.Zuora__DefaultPaymentMethod__c =  GlobalVariableClass.CREDITCARD;
            billAcc.Zuora__Account__c = acc.id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            insert billAcc ;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //START CCB.002 Modified by: Francis Benzon
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
                        
            /*Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            insert cas;
            
            //create Subscription record
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__Account__c = acc.Id;
            sub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            sub.Subscriber_Contact__c = con.Id;
            sub.Recipient_Contact__c = con.Id;
            sub.Main_Package_1__c = pack.id;
            sub.Zuora__Status__c = 'Active';
            sub.Order_Number__c = orderRec.Id;
            sub.Suppress_Vendor_Start_Notice__c = 'false';
            sub.Supressed_Acknowledgement_Letter__c = 'false';
            sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            sub.Urgent__c = 'false';
            sub.Vendor_Conversion__c = 'false';
            sub.Charity__c = 'false';
            sub.Billing_Type__c = 'Full Prepaid';
            insert sub;
            
            //create Case_Subscription__c
            Case_Subscription__c cs = TestDataFactory.createCaseSubscription(1)[0];
            cs.Case__c = cas.Id;
            cs.Account__c = acc.Id;
            cs.Subscription__c = sub.Id;
            insert cs;*/
            
            Case c = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            //c.Order__c = orderRec.Id;
            insert c;
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(1);
            for(Zuora__Subscription__c subRecs : subList){
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__SubscriptionEndDate__c = date.today();
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = orderRec.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
            }
            insert subList;
            
            //create Case_Subscription__c
            Case_Subscription__c csub = TestDataFactory.createCaseSubscription(1)[0];
            csub.Case__c = c.Id;
            csub.Account__c = acc.Id;
            csub.Subscription__c = subList[0].Id;
            insert csub;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today()+20;
            orderline.Main_Package_ID__c = pack.Id;
            insert orderline;
            
            //insert new List<sObject>{cas, subrecs[0], subrecs[1], subrecs[2], subrecs[3], orderline};
            
            String zuoraId = '2c92c0f8489db3ba0148a08143pp3638b';
            Date stopDate = system.today();
            Date stpReqDate = date.today();
            Date formatDate = date.today()+3;
            
            Test.startTest();
            
            CancelSubscription cancelSubs = new CancelSubscription();
            CancelSubscription.createCancelAmendment(zuoraId, stopDate);
            CancelSubscription.formatDateToZuora(formatDate);
            CancelSubscription.amendForSubCancelation(zuoraId, stopDate);
            cancelSubs.checkDeliveryCharge(subList[0].Id, stpReqDate);
            
            Test.stopTest();
        }
    }
}