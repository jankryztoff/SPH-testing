public class UpdatePromotionGiftClass
{
    //Start: D-2908 James 05/18/2015 - update gift item stocks
    Double oQuantity;
    Double rQuantity;
    Double gIssued;
    Double gRedeemed;
    Double oQuantityTotal;
    Double rQuantityTotal;

    public void UpdatePromotionGift(List<Order_Line_Item_Gift__c> newOrderLineItemGifts)
    {
        //instantiate List of String and Map of Promotion_Gift__c with its corresponding Order_Line_Item_Gift__c id
        List<String> promoGiftIdList = new List<String>();
        
        //get an Id List of Promotion Gift from the trigger.new
        for (Order_Line_Item_Gift__c olig : newOrderLineItemGifts)
        {
            promoGiftIdList.add(olig.Promotion_Gift__c);
        }
        
        //query Promotion_Gift__c base on the List of Id
        List<Promotion_Gift__c> promoGiftList = [SELECT Name, Gift_Issued__c, Gift_Redeemed__c FROM Promotion_Gift__c WHERE Id =: promoGiftIdList];
        
        //loops all possible affected Promotion_Gift__c to be updated
        for(Promotion_Gift__c promoGift : promoGiftList)
        {
            oQuantityTotal = promoGift.Gift_Issued__c;
            rQuantityTotal = promoGift.Gift_Redeemed__c;
            //loops all trigger.new objects to get total quantities
            for(Order_Line_Item_Gift__c olig : newOrderLineItemGifts)
            {
                //filter only records that are related to the instantaneous Promotion_Gift__c
                if(olig.Promotion_Gift__c == promoGift.id)
                {
                    if(olig.Order_Quantity__c != Null)
                    {
                        oQuantityTotal = oQuantityTotal + olig.Order_Quantity__c;
                    }

                    if(olig.Redemption_Quantity__c != Null)
                    {
                        rQuantityTotal = rQuantityTotal + olig.Redemption_Quantity__c;
                    }
                }
            }
            //fills up total values of specific promoGift
            promoGift.Gift_Issued__c = oQuantityTotal;
            promoGift.Gift_Redeemed__c = rQuantityTotal;
        }
        update promoGiftList;
    }
    
    
    //added for deletion of order line item gift[GSantos 11/28/2014][for D-585]
    public void DecreaseQuantity(List<Order_Line_Item_Gift__c> deletedOrderLineItemGifts)
    {
        //instantiate List of String and Map of Promotion_Gift__c with its corresponding Order_Line_Item_Gift__c id
        List<String> promoGiftIdList = new List<String>();
        
        //get an Id List of Promotion Gift from the trigger.new
        for(Order_Line_Item_Gift__c delOrderLineItemGifts : deletedOrderLineItemGifts)
        {
            promoGiftIdList.add(delOrderLineItemGifts.Promotion_Gift__c);
        }
        
        //query Promotion_Gift__c base on the List of Id
        List<Promotion_Gift__c> promoGiftList = [SELECT Name, Gift_Issued__c, Gift_Redeemed__c FROM Promotion_Gift__c WHERE Id =: promoGiftIdList];
        
        //loops all possible affected Promotion_Gift__c to be updated
        for(Promotion_Gift__c promoGift : promoGiftList)
        {
            oQuantityTotal = promoGift.Gift_Issued__c;
            rQuantityTotal = promoGift.Gift_Redeemed__c;
            //loops all trigger.new objects to get total quantities
            for(Order_Line_Item_Gift__c delOrderLineItemGifts : deletedOrderLineItemGifts)
            {
                //filter only records that are related to the instantaneous Promotion_Gift__c
                if(delOrderLineItemGifts.Promotion_Gift__c == promoGift.id)
                {
                    if(delOrderLineItemGifts.Order_Quantity__c != Null)
                    {
                        oQuantityTotal = oQuantityTotal - delOrderLineItemGifts.Order_Quantity__c;
                    }

                    if(delOrderLineItemGifts.Redemption_Quantity__c != Null)
                    {
                        rQuantityTotal = rQuantityTotal - delOrderLineItemGifts.Redemption_Quantity__c;
                    }
                }
            }
            //fills up total values of specific promoGift
            promoGift.Gift_Issued__c = oQuantityTotal;
            promoGift.Gift_Redeemed__c = rQuantityTotal;
        }
        update promoGiftList;
    }
    //End: D-2908 James 05/18/2015
}