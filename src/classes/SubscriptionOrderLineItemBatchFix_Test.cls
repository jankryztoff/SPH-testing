@isTest(seeAllData=true)
public class SubscriptionOrderLineItemBatchFix_Test {

    @isTest
    public static void testBatch(){
        Test.startTest();
        Map<String, SObject> testDataMap = TestDataFactory.createSubscriptionPackageUpdated();
        
        Order_Line_Item__c oli = (Order_Line_Item__c) testDataMap.get('Order_Line_Item__c');
        oli.Delivered_By__c = 'Mailing Agent';
        update oli;
        
        Zuora__Subscription__c sub = (Zuora__Subscription__c) testDataMap.get('Zuora__Subscription__c');
        sub.Delivered_By_1__c = 'Vendor';
        sub.Subscription_Type_1__c = 'Publication';
        insert sub;
        
        Address__c add = (Address__c) testDataMap.get('Address__c');
        add.RecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Local' LIMIT 1].get(0);
        update add;
        
        SubscriptionOrderLineItemBatchFix batch = new SubscriptionOrderLineItemBatchFix();
        
        Database.executeBatch(batch);
        Test.stopTest();
    }

}