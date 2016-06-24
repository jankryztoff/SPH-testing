global class SubscriptionOrderLineItemBatchFix implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Delivered_By_1__c, Vendor_1__c,
                                            Order_Line_Item_Number_1__r.Id
                                        FROM Zuora__Subscription__c 
                                        WHERE Delivered_By_1__c = 'Vendor' 
                                            AND Order_Line_Item_Number_1__r.Delivered_By__c != 'Vendor' 
                                            AND (Subscription_Type_1__c = 'Publication' OR Subscription_Type_1__c = 'Delivery')
                                            AND Recipient_Contact__r.Address__r.RecordType.Name = 'Local' 
                                            AND Order_Line_Item_Number_1__c != NULL]);
    }
    
    global void execute(Database.BatchableContext bc, List<Zuora__Subscription__c> subs){
        Map<Id, Zuora__Subscription__c> oliSubMap = new Map<Id, Zuora__Subscription__c>(); 
        
        Set<Id> oliIDs = new Set<Id>();
        for(Zuora__Subscription__c sub: subs){
            oliIDs.add(sub.Order_Line_Item_Number_1__r.Id);
        }
        
        Map<Id, Order_Line_Item__c> oliList = new Map<Id, Order_Line_Item__c>(
                                            [SELECT Id, Delivered_By__c, Direct_Sub_Delivery_Method__c, Vendor_Mailing_Agent__c, Order_Line_Item_Legacy_Id__c
                                            FROM Order_Line_Item__c
                                            WHERE Id IN :oliIDs AND Delivered_By__c = 'Mailing Agent']);
        
        for(Zuora__Subscription__c sub: subs){
            oliSubMap.put(sub.Order_Line_Item_Number_1__r.Id, sub);
        }
        
        List<Order_Line_Item__c> toUpdate;
        
        for(Order_Line_Item__c oli: oliList.values()){
            oli.Delivered_By__c = 'Vendor';
    		oli.Direct_Sub_Delivery_Method__c = 'Vendor';
    		oli.Vendor_Mailing_Agent__c = oliSubMap.get(oli.Id).Vendor_1__c;
    		toUpdate.add(oli);
        }
        
        update toUpdate;
        
        
        /*List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        Set<Id> oliSet = new Set<Id>();
        for (Zuora__Subscription__c updateSubs : subs){
        	Order_Line_Item__c oli = new Order_Line_Item__c();
        	if (updateSubs.Order_Line_Item_Number_1__r.Delivered_By__c == 'Mailing Agent' && updateSubs.Delivered_By_1__c == 'Vendor'){
        		oli.Id = updateSubs.Order_Line_Item_Number_1__c;
        		oli.Delivered_By__c = 'Vendor';
        		oli.Direct_Sub_Delivery_Method__c = 'Vendor';
        		oli.Vendor_Mailing_Agent__c = updateSubs.Vendor_1__c;
        	}
    		if(!oliSet.contains(oli.Id))
    			oliList.add(oli);
        }
        
        update oliList;
        update subs;*/
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}