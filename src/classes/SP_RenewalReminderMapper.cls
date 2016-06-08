/*
 * Class Name: SP_RenewalReminderHelper
 * @author: Kevin H. Evasco
 * Date: 11/23/2015
 * Project/Requirement: Letter Printing - Renewal Reminder Helper
 * @description This class creates the Letter Print Request to Recipient/Order Line Item/Subscription Mapping
 * 
 * History: 11/23/2015 Kevin Evasco Created Utility Class
 */
 
 
public class SP_RenewalReminderMapper {
    
    //START: D-4262 1-12-2016 Added by Kristine Balaoing - added logging mechanism 
    public static List<Exception> exceptionList = new List<Exception>();
    //END: D-4262 1-12-2016 Added by Kristine Balaoing
    
    public class RenewalSubscriptionGroup {
        public Map<Id,Set<Id>> masterLPRId_orderLineItemIdList_map = new Map<Id,Set<Id>>();
        public Map<Id,List<Zuora__Subscription__c>> orderLineItemId_subscriptionList_map = new Map<Id,List<Zuora__Subscription__c>>();
    }

    public static RenewalSubscriptionGroup initializeRenewalSubscriptionGroup(List<Letter_Print_Request__c> detailLetterPrintRequestsParam, Map<Id,Zuora__Subscription__c> subscriptionMapParam){
        Map<Id,Set<Id>> masterLPRId_orderLineItemIdList_map = new Map<Id,Set<Id>>();
        Map<Id,List<Zuora__Subscription__c>> orderLineItemId_subscriptionList_map = new Map<Id,List<Zuora__Subscription__c>>();
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing -added logging mechanism
        try{
            
            for(Letter_Print_Request__c detailLPR : detailLetterPrintRequestsParam){
                if(masterLPRId_orderLineItemIdList_map.get(detailLPR.Parent_Letter_Print_Request__c) == null)
                    masterLPRId_orderLineItemIdList_map.put(detailLPR.Parent_Letter_Print_Request__c, new Set<Id>());
                    
                Zuora__Subscription__c lprSubscription = subscriptionMapParam.get(detailLPR.Record_Id__c);
                masterLPRId_orderLineItemIdList_map.get(detailLPR.Parent_Letter_Print_Request__c)
                    .add(lprSubscription.Order_Line_Item_Number_1__c);
                
                if(orderLineItemId_subscriptionList_map.get(lprSubscription.Order_Line_Item_Number_1__c) == null)
                    orderLineItemId_subscriptionList_map.put(lprSubscription.Order_Line_Item_Number_1__c, new List<Zuora__Subscription__c>());
                orderLineItemId_subscriptionList_map.get(lprSubscription.Order_Line_Item_Number_1__c).add(lprSubscription);
            }
            
        }catch(Exception e){
            exceptionList.add(e);
        }
            
            RenewalSubscriptionGroup grouping = new RenewalSubscriptionGroup();
            grouping.masterLPRId_orderLineItemIdList_map = masterLPRId_orderLineItemIdList_map;
            grouping.orderLineItemId_subscriptionList_map = orderLineItemId_subscriptionList_map;
        
        
        ExceptionLogger.log(exceptionList);
        
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
        return grouping;
    }

    public static Map<Id, Set<Id>> groupOrderLineItemsByRecipient(List<Zuora__Subscription__c> subscriptionListParam) {
        Map<Id, Set<Id>> recipientId_orderLineItemIds_map = new Map<Id, Set<Id>>();
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing
        try{
            for(Zuora__Subscription__c subElem : subscriptionListParam){
                if(recipientId_orderLineItemIds_map.get(subElem.Recipient_Contact__c) == null)
                    recipientId_orderLineItemIds_map.put(subElem.Recipient_Contact__c, new Set<Id>());
                recipientId_orderLineItemIds_map.get(subElem.Recipient_Contact__c).add(subElem.Order_Line_Item_Number_1__c);
            }
        }catch(Exception e){
            exceptionList.add(e);
            
        }
        
        ExceptionLogger.log(exceptionList);
        
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
        
        return recipientId_orderLineItemIds_map;
    }

    public static Map<Id,Zuora__Subscription__c> getSubscriptionMap(List<Letter_Print_Request__c> detailLetterPrintRequestsParam){
        Set<Id> subscriptionIdSet = new Set<Id>();
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing - added logging mechanism
        try{
            for(Letter_Print_Request__c detailLetterPrintRequest : detailLetterPrintRequestsParam){
                subscriptionIdSet.add(detailLetterPrintRequest.Record_Id__c);
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
        
        return new Map<Id,Zuora__Subscription__c>([SELECT Id, Order_Line_Item_Number_1__c, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Id IN :subscriptionIdSet]);
    }   
}