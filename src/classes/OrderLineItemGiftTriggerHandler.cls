public class OrderLineItemGiftTriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    //START UD-2970 09/18/15 RReyes
    List<Promotion_Gift__c> promoGiftList = new List<Promotion_Gift__c>();
    Map<Id, Id> mapPromoGiftToGift = new Map<Id, Id>();
    //END UD-2970 09/18/15 RReyes
    
  //START 18/02/15 Wenjun : Fix Code Bug - Incorrect referring to PackageItemTriggerHandler
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !OrderLineItemGiftTriggerHandler.isBeforeInsertTriggerCalled;
        OrderLineItemGiftTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !OrderLineItemGiftTriggerHandler.isBeforeUpdateTriggerCalled;
        OrderLineItemGiftTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !OrderLineItemGiftTriggerHandler.isBeforeDeleteTriggerCalled;
        OrderLineItemGiftTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !OrderLineItemGiftTriggerHandler.isAfterInsertTriggerCalled;
        OrderLineItemGiftTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !OrderLineItemGiftTriggerHandler.isAfterUpdateTriggerCalled;
        OrderLineItemGiftTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !OrderLineItemGiftTriggerHandler.isAfterDeleteTriggerCalled;
        OrderLineItemGiftTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    //END 18/02/15 Wenjun
    
    public void bulkBefore() {
        //START UD-2970 09/18/15 RReyes
        promoGiftList = [SELECT Id, Gift__c FROM Promotion_Gift__c];
        for(Promotion_Gift__c promoGift : promoGiftList){
            if(!mapPromoGiftToGift.keyset().contains(promoGift.Id)){
                mapPromoGiftToGift.put(promoGift.Id, promoGift.Gift__c);
            }
        }
        //END UD-2970 09/18/15 RReyes
    }
        
    public void bulkAfter() {
        //start here
        if(trigger.isUpdate){
            List<Order_Line_Item_Gift__c> orderLineItemGiftList = trigger.new;
            UpdatePromotionGiftClass upg = new UpdatePromotionGiftClass();
            upg.UpdatePromotionGift(orderLineItemGiftList);
        }
    }
    
    public void beforeInsert(SObject so) {
       //START UD-2970 09/18/15 RReyes
        populateGiftID(so);
       //END UD-2970 09/18/15 RReyes  
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        //START UD-2970 09/18/15 RReyes
        populateGiftID(so);
        //END UD-2970 09/18/15 RReyes 
    }
    
    public void beforeDelete(SObject so) {
      
    }
    
    public void afterInsert(SObject so) {
        
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        
    }
    //START UD-2970 09/18/15 RReyes
    public void populateGiftID(SObject so){
        Order_Line_Item_Gift__c oliGift = (Order_Line_Item_Gift__c)so;
        if(oliGift.Promotion_Gift__c != null){
            if(mapPromoGiftToGift.containsKey((id)oliGift.Promotion_Gift__c)){
                oliGift.Gift_ID__c = mapPromoGiftToGift.get((id)oliGift.Promotion_Gift__c);
            }
        }   
    }
    //END UD-2970 09/18/15 RReyes
}