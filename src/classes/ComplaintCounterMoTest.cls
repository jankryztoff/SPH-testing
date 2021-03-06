/**
 * Class Name: ComplaintCounterMoTest
 * @author: Karl Tan
 * Date: <4/11/2016>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for complaintCounterMo
 */

@isTest (Seealldata = TRUE)
public class ComplaintCounterMoTest {
    
    
    static testMethod void testcomplaintCounterMo(){
            
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
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
        
        /*RecordType rt = new RecordType();
        rt.Name = 'Overseas';
        rt
        insert rt;*/
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = (Id) ConstantsSLB.getKeyId('Address_Overseas');
        //ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Overseas').getRecordTypeId();
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Order__c order = [SELECT Id, Recipient_Type__c FROM Order__c WHERE Id=:ord.Id];
        system.assertEquals(order.Recipient_Type__c, 'Overseas');
        
        List<Case> caseList = TestDataFactory.createCase(1, 'Complaint - Newspaper');
        Datetime yesterday = Datetime.now().addDays(-113);
        
        for(Case cas : caseList ){
            cas.Accountid = acc.Id;
            cas.Account__c = acc.id;
            cas.Account = acc;        
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
            cas.recipient_address__c = ad.Id;
            cas.Order__c = order.Id;
            cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas.Contact_To_Update__c = con.id;
            cas.ContactId = con.id;
        }
        
        List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(1);
            for(Zuora__Subscription__c subRecs : subList){
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__SubscriptionEndDate__c = date.today();
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
            }
            //insert subList;

            
        test.startTest();
        //system.assertEquals(string.valueOF(cas.order__r.Recipient_Type__c), string.valueOF(cas.order__c )+string.valueOf(order.Recipient_Type__c));
        //system.assertEquals(1,2);

        database.insert(caseList);
        database.insert(subList[0]);
        
        complaintCounterMo complaint = new complaintCounterMo();
        complaint.complaintCounter(caseList);
        test.StopTest();            
            
    
        
    }
}