public class Identify_Urgent_OrderLineItem {


    public Boolean Identify_Urgent_OrderLineItem (list<Order__c> lOrder, Boolean bDirect){
        if(bDirect){
            return IdentifyUrgent_Direct(lOrder);
        }else{
            return IdentifyUrgent_Vendor(lOrder);
        }
        
    }

    Public Boolean IdentifyUrgent_direct(list<Order__c> lOrder){
        boolean bUrgent;
        bUrgent = false;
        
        return bUrgent; 
    }

 

    Public Boolean IdentifyUrgent_Vendor(list<Order__c> lOrder){
        boolean bUrgent;
        bUrgent = false;
        list<Order_Line_Item_Vendor__c> lOrderLineItemVendor = new list<Order_Line_Item_Vendor__c>();
        for(Order_Line_Item_Vendor__c oliv: [SELECT Start_Date__c, Publication__r.Earliest_Start_Date__c, Urgent__c
                                             FROM Order_Line_Item_Vendor__c
                                             WHERE Order__c in: lOrder]){
                oliv.Urgent__c = false;
                if (oliv.Start_Date__c < oliv.Publication__r.Earliest_Start_Date__c){
                    oliv.Urgent__c = true;
                    bUrgent = true;
                }
                lOrderLineItemVendor.add(oliv);     
        
        }
        
        Update lOrderLineItemVendor;
        return bUrgent;
    }

}