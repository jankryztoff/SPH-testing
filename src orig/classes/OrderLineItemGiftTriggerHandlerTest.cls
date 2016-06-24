/**
   @Author <Marjorie Gaelo>
   @name <OrderLineItemGiftTriggerHandlerTest >
   @CreateDate <2/3/2015>
   @Description <Test Class for OrderLineItemGiftTriggerHandler>
   @Version <1.0>
   @reference <Referenced program names>
  */
@isTest
private class OrderLineItemGiftTriggerHandlerTest {
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createOther();
    }
    
     /**
    *  @description This method executes during class instantiation.  
    *  @name <testOrderLineItemGiftTrigger>
    */
    static  testmethod void  testOrderLineItemGiftTrigger(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
    acc.Name = 'TEST';
    acc.NRIC__c = 'T1234567R';
    insert acc;
    
    Order__c order = TestDataFactory.createOrder(1)[0];
    order.Account__c = acc.id;
    order.Delivery_Charge__c = 4;
    order.Order_Legacy_Id__c = '3421';
    order.Legacy_Create_By__c = '1';
    order.Legacy_Create_Date__c = '1';
    order.Legacy_Update_By__c = '1';
    order.Legacy_Update_Date__c = '1';
    order.Monthly_Delivery_Charge_for_Full_Payment__c = 4;
    order.Credit_Balance__c =1;
    insert order;
    
    
    Package__c pack = TestDataFactory.createPackage(1)[0];
    pack.Package_Type__c = 'Base';
    pack.Name = 'testpackaA';
    pack.Package_Code__c = 'pcode2';
    pack.Subscription_Type__c = 'Termed';
    pack.Subscription_Period__c= '1';
    pack.Effective_End_Date__c = date.today().addDays(20);
    pack.Effective_Start_Date__c = date.today();
    insert pack;
    
    Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
    oli.Earliest_Start_Date__c = date.today();
    oli.Start_Date__c =  date.today().addDays(2);
    oli.order__c = order.id;
    oli.Main_Package_ID__c = pack.id;
    oli.Main_Package_Period__c = 1;
    oli.Qty__c = 1;
    oli.Term_Length__c = 1;
    oli.Main_Package_Billing_Type__c = 'Full Prepaid';
    oli.Main_Package_Type__c = 'Base';
    oli.Main_Package_Frequency__c = 'Default';
    oli.Delivered_By__c = 'None';
    insert oli;
    
    Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
    promgift.Gift_Inventory__c = 1;
    promgift.Gift_Issued__c = 1;
    promgift.Gift_Redeemed__c = 1;
    insert promgift;
    
    Order_Line_Item_Gift__c oligift = TestDataFactory.createItemGift(1)[0];
    oligift.Order_Line_Item__c = oli.id;
    oligift.Promotion_Gift__c = promgift.id;
    oligift.Redemption_Date__c = date.today();
    oligift.Redemption_Quantity__c = 5;
    
    Test.startTest();
    insert oligift;
    update oligift;
    delete oligift;
    Test.stopTest();
    
    OrderLineItemGiftTriggerHandler oligtHandler = new OrderLineItemGiftTriggerHandler();
    oligtHandler.runBeforeInsertTrigger();
    oligtHandler.runBeforeUpdateTrigger();
    oligtHandler.runBeforeDeleteTrigger();
    oligtHandler.runAfterInsertTrigger();
    oligtHandler.runAfterUpdateTrigger();
    oligtHandler.runAfterDeleteTrigger();
    
    }
    
    
}