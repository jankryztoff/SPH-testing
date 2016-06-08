@isTest
private class SubscriptionProductChargeHelperTest {
    
    static testMethod void testSubscriptionProductChargeHelper01() {
    
        //Test Data
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        Zuora__SubscriptionProductCharge__c subProdCharge1 = new Zuora__SubscriptionProductCharge__c(
            Zuora__ProductName__c='SIT - Discount', Zuora__ExtendedAmount__c=1, Zuora__Price__c = 10
        );
        subProdChargeList.add(subProdCharge1);
                
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> spcMap = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        spcMap.put(TestUtility.getFakeId(Zuora__SubscriptionProductCharge__c.SObjectType), subProdChargeList);
    
        SubscriptionProductChargeHelper.calculatePubCharge(spcMap);
        
        
    }    
}