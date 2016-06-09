/**
 * Class Name: <viewOrderForDirectSubscriptionController >
 * @author: <KristineJoyceCampang and JerellaLedesma>
 * Date: <8/6/2014>
 * Requirement/Project Name: <SPH>
 * @description<VisualForcePage viewOrderForDirectSubscriptionRO Controller>
 * 
 * History: 01/08/2015 Wenjun : Order Postage Charge Field Change
 */

public class viewOrderForDirectSubscriptionController {
    public Account parentAccount {get;set;}
    public Promotion__c promotion {get; set;}
    public Order__c order {get;set;}
    public List<Order_Line_Item__c> orderLineItemList {get; set;}
    public List<Order_Line_Item_Gift__c> giftList {get; set;}
    public List<Order_Line_Item_Gift__c> giftsToDisplay; 
    public Order_Line_Item__c orderLine {get; set;}
    public String currentlyClickedOrderLine {get; set;}
    public Map<Id, List<Order_Line_Item_Gift__c>> mapOrderLineItemWithOrderLineItemGift {get; set;}
    
    //List<Order_Line_Item__c> orderLineItemList; //Lists all orderlineitem record
    //Account parentAccount; //instantiates an account
     Set<Id> orderLineItemIdSet = new Set<Id>();
     Map<Id, Order_Line_Item__c> orderLineItemId_orderLineItem = new Map<Id, Order_Line_Item__c>();

    public viewOrderForDirectSubscriptionController(){
        mapOrderLineItemWithOrderLineItemGift = new Map<Id, List<Order_Line_Item_Gift__c>>();
        //Order__c order = new Order__c();
        Order_Line_Item__c orderLine= new Order_Line_Item__c();
        Id orderId = ApexPages.currentPage().getParameters().get('id');
        //Id orderId='a17N0000001w3fF';
        if(orderId != null)
            {
             //START 01/08/15 Wenjun - Postage Charges : Change to Total_Monthly_Postage_Charge__c instead of Postage_Charge__c   
             this.order = [SELECT Id, Name, Recipient_Contact__c,
                             Cost_Centre__c, Delivery_Charge_Type__c, Vendor_Credit__c, 
                             Total_Full_Prepaid_Charge__c, Total_Monthly_Recurring_Charge__c,  
                             Credit_Balance__c, Total_Monthly_Postage_Charge__c, Billing_Type__c,
                             Amount_Paid__c, Payment_Mode__c, Account__c, Billing_Contact__r.Name, 
                             Billing_Account__r.Name, Vendor_Sms_Remarks__c
                     		 FROM Order__c WHERE Id = :orderId];
             //END 01/08/15 Wenjun - Postage Charges        
            orderLineItemList = [SELECT Id, PO_Number__c, Penalty_Charge__c, New_Contract_Period__c, 
                                        Generate_Invoice__c, Auto_Renew__c, Supressed_Acknowledgement_Letter__c , Vendor_Conversion__c, 
                                        Name, Term_Length__c, Term_is_discussed__c, Addon_Package__c, Promotion_ID__r.Name, 
                                        Main_Package_ID__r.Name, Main_Package_Subscription_Rate__c , Main_Package_ID__r.ID, Qty__c, Start_Date__c, Suppress_Vendor_Start_notice__c , 
                                        Vendor_Subscription_ID__c , Earliest_Start_Date__c , Charity__c, Delivered_By__c , 
                                        End_Date__c, Main_Package_Type__c, Main_Package_Billing_Type__c, /*Subscription_Rate__c,*/ 
                                        Addon_Package__r.Package_Code__c, Addon_Package__r.Name from Order_Line_Item__c where Order__c = :order.Id];      
            this.orderLine = orderLineItemList.get(0);
            System.debug('>>>>>>>>> ' +orderLine);
             /**orderLineItemList = [SELECT Id,DTL_Date__c 
                                  FROM Order_Line_Item__c 
                                  WHERE Order__c = :order.Id];
            **/
            //Checks every Record in the Order Line Item List
            //adds its Ids to the Set
             for(Order_Line_Item__c orderLineItemRecord : orderLineItemList) 
                {
                    orderLineItemId_orderLineItem.put(orderLineItemRecord.Id, orderLineItemRecord);
                    orderLineItemIdSet.add(orderLineItemRecord.id); 
                }
            //Checks if the set contains a value
            //queried for all gifts and put it in a List
                if (orderLineItemIdSet.size()>0)
                    {
                        giftList = [SELECT Id, Gift_Name__c, Name, Type__c, Price__c, Order_Line_Item__c 
                                    FROM Order_Line_Item_Gift__c
                                    WHERE Order_Line_Item__c 
                                    IN:orderLineItemIdSet];
                    }   
                 //Iterates through the set
                 //Creates a map with the orderLineItem as the key and
                 //initiates an empty list as the value
                    for(Id orderLineItemId :orderLineItemIdSet)
                    {
                        mapOrderLineItemWithOrderLineItemGift.put(orderLineItemId,new List<Order_Line_Item_Gift__c>());
                    }
                 //Checks for every gift record in the List 
                 //Gets the list which is the key value
                 //and add the gift record to the list
                 //update the map with the current List
                    for(Order_Line_Item_Gift__c giftRecord :giftList)
                    {
                        List<Order_Line_Item_Gift__c> currentList = mapOrderLineItemWithOrderLineItemGift.get(giftRecord.Order_Line_Item__c);
                        currentList.add(giftRecord);
                        mapOrderLineItemWithOrderLineItemGift.put(giftRecord.Order_Line_Item__c,currentList);
                    }

              //Queried for the parent Account      
             parentAccount = [SELECT Id,Name,AccountNumber, Status__c 
                             FROM Account 
                             WHERE Id = :order.Account__c];
            }
        else
            {
                order = new Order__c();
            }
        
}  
                public List<Order_Line_Item_Gift__c> getGiftsToDisplay() {
                    return mapOrderLineItemWithOrderLineItemGift.get(orderLine.id);
                    }
                
                
                public void updateOrderLine(){
                         orderLine = orderLineItemId_orderLineItem.get((Id)currentlyClickedOrderLine); //Gets the orderLineObject
                    }
}