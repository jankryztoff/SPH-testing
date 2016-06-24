@isTest (seeAllData= true)
private class SendQuotesToZuora2Test{
    static testMethod void testSendQuotesToZuora() {
    
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__Account__c = acc.id;
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today()+1;
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Change of Subscription'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orders[0].Id;
        insert cas;
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Case__c = cas.id;
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = Date.Today()+2;          
        }
        database.insert(olis);
         
        List<zqu__Quote__c> quoteList = TestDataFactory.createQuote(1);
        for(zqu__Quote__c zq: quoteList ){
        zq.zqu__Account__c = acc.id;
        zq.Order_Line_Item_Number_1__c = olis[0].id;
        zq.Order_Line_Item_Number__c = olis[0].id;
        }
        
        Database.insert(quoteList);
        
        List<zqu__QuoteCharge__c> zqCharge = TestDataFactory.createQuoteCharge(1);
        for(zqu__QuoteCharge__c zqc: zqCharge){
        zqc.zqu__Quote__c = quoteList[0].Id;
        }
        Database.insert(zqCharge);
        
   
       list<Id> newlQuoteIds = new list<Id>();
       newlQuoteIds.add(acc.id);
       newlQuoteIds.add(billAcc.id);
       newlQuoteIds.add(quoteList[0].id);
       
       String newPaymentMode = 'Credit Card';
       String newPaymentModeOther = 'Test';
       String newDeliveryChargeType = 'Test';
       
       boolean newbCreateNewBillingAccount = true;
       boolean newbCreateDeliverySubscription = true;
       boolean newbPayDeliveryChargeNow = true;
       
       ID newExistingDeliverySubscriptionId = sub.id;
       ID newSFBillingAccount = billAcc.id;
       
       String newzBillingAccount = 'Test';
       Decimal SubscriberCharge = 1.1;
       
       Id newAccountId = acc.id;
       ID newOrderId = orders[0].id;
       
       decimal newDeliveryFPSubscriptionUsage = 1.1;
       
       string newCCPaymentMethodID = 'Test';

        test.startTest();
        SendQuotesToZuora2 sendQtoZ2 = new SendQuotesToZuora2();
        sendQtoZ2.RecievedData(newlQuoteIds , newPaymentMode , newPaymentModeOther , newDeliveryChargeType,newbCreateNewBillingAccount ,newbCreateDeliverySubscription ,newbPayDeliveryChargeNow ,newExistingDeliverySubscriptionId ,newSFBillingAccount,newzBillingAccount, SubscriberCharge,newAccountId,newOrderId ,newDeliveryFPSubscriptionUsage,newCCPaymentMethodID);

        test.stopTest();    
        }
        
}