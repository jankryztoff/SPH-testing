/**
 * Class Name: CreateGiftLettersBatchController 
 * @author: Jb Domingo
 * Date: 9/2/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class that generates letters for order line item gifts 
 * History: 11/23/2014 Kevin Evasco Applied new letter print approach. Inserts record to batch job scheduler instead of directly executing a batch job.
 * History: 12/05/2014 D-0797, D-0849 Kevin Evasco Used new Batch Job Scheduler constructor to enable storage of Session ID.
 * History: 02/03/2015 D-1982 Kevin Evasco - Updated to follow the letter type in SP_GenerateLetterPrintBatch
 */
public class CreateGiftLettersBatchController {
    //START:D-1022 12/3/14 Added by Manolo Valeña - Updated name of variable from "OrderList" to "OrderList1"
    public List<OrderObj> OrderList1;
    //END:D-1022 12/3/14 Added by Manolo Valeña
    
    public Id giftLetterBatchId {get; set;}
   
    public List<Order_Line_Item_Gift__c> orderLineItemGiftList;
    public List<Order_Line_Item_Gift__c> selectedOrderList;
    public List<Gift_Letter_Batch__c> giftLetterBatchList;
    public List<Map<String,sObject>> objectMapList;
    public Map<String,sObject> objectMap;  
    public String template {get; set;}
    
    public Id emailTemplateId;

    public Boolean showListofCustomers {get;set;}
    public Boolean showLetter {get; set;} 
    //REMOVED public Boolean overlapBatch{get;set;} //START 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
    
    // START : D-1630 1/23/2015 Alyana Navarro
    public Gift_Letter_Batch__c giftLetterBatch {get; set;}
    public String orderLineItemGiftId {get; set;}
    // END : D-1630 1/23/2015
    
    // START : D-1141 2/6/2015 Alyana Navarro
    public List<Order_Line_Item_Gift__c> oligToUpdate = new List<Order_Line_Item_Gift__c>();
    // END : D-1141 2/6/2015
    
    public CreateGiftLettersBatchController()
    {
        //REMOVED overlapBatch = false; //START 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
        giftLetterBatchId = apexpages.currentpage().getparameters().get('Id');
        orderLineItemGiftList = new List<Order_Line_Item_Gift__c>();
        // START : D-1630 1/27/2015 Alyana Navarro
        // START: Code Review Implementation 2/13/2015 JAlejandro
        if (giftLetterBatchId != null)
        {
            giftLetterBatch = [SELECT id, name, Letter_Template__c FROM Gift_Letter_Batch__c WHERE id =: giftLetterBatchId];
        } 
        // END: Code Review Implementation 2/13/2015 JAlejandro
        // END : D-1630 1/27/2015
        //START:D-1022 12/3/14 Added by Manolo Valeña - Updated name of variable from "OrderList" to "OrderList1"
        OrderList1 = new List<OrderObj>();
        //END:D-1022 12/3/14 Added by Manolo Valeña
    }
    
    public List<OrderObj> getOrderList1() 
    {
        //START: D-4268 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        Logger logger;
        
        if(!Test.isRunningTest()){
            logger = new Logger('CreateGiftLettersBatchController');
        }
        
        try
        {
      //START:D-1022 1/13/15 Added by Manolo Valeña - Updated SOQL Query to have Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c. This will replace the Gift Code and Promo Code text fields since both of them should be lookup fields.
        // END: Code Review Implementation 2/13/2015 JAlejandro
        if (giftLetterBatchId != null)
        {
            giftLetterBatchList = [SELECT Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c FROM Gift_Letter_Batch__c  WHERE Id =: giftLetterBatchId LIMIT 1]; 
        }
        // END: Code Review Implementation 2/13/2015 JAlejandro
        //END:D-1022 1/13/15 Added by Manolo Valeña
      
      if(GiftLetterBatchlist.size() > 0){
                //giftLetterBatchList = [SELECT Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c FROM Gift_Letter_Batch__c  WHERE Id =: giftLetterBatchId LIMIT 1];            
                
                String emailTemplateName = 'Gift - ' + giftLetterBatchList[0].Letter_Template__c;
                // START: Code Review Implementation 2/13/2015 JAlejandro
                List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
                if (emailTemplateName != null)
                {
                    emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = :emailTemplateName];
                } // END: Code Review Implementation 2/13/2015 JAlejandro
                if(emailTemplate != null && emailTemplate.size()>0)
                {
                    emailTemplateId = emailTemplate[0].Id;
                }
            
                //[JKVA 1127]updated for D-0618  
                //START:D-1022 12/3/14 Added by Manolo Valeña - Updated SOQL query to apply correct filter. Also added an if-else statement to cover the additional filter that if the Customer Account Number field has no value, the query will be different"        
                if (giftLetterBatchList[0].End_Date__c != null && giftLetterBatchList[0].Start_Date__c !=null && 
                    giftLetterBatchList[0].Gift__r.Gift_Code__c !=null && giftLetterBatchList[0].Promotion__r.Promotion_Code__c != null)
                {
                    if(giftLetterBatchList[0].Customer_Account_Number__c != null )// Code Review Implementation 2/13/2015 JAlejandro
                    {
                        orderLineItemGiftList = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c, Order_Line_Item__r.Order__r.Account__r.Sub_Group__c, //START D-4432 Gdelrosario : added to show sub group
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE promotion_gift__r.Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                          AND promotion_gift__r.Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                //END:D-1022 1/13/15 Added by Manolo Valeña
                          
                          AND order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c <=: giftLetterBatchList[0].End_Date__c
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new filter.
                                                AND Has_Letter_Attached__c = false
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                ORDER BY CreatedDate ASC];
                    }   
                    else
                    {
                        orderLineItemGiftList = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c, Order_Line_Item__r.Order__r.Account__r.Sub_Group__c, //START D-4432 Gdelrosario : added to show sub group
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE promotion_gift__r.Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                          AND promotion_gift__r.Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                //END:D-1022 1/13/15 Added by Manolo Valeña
                          
                          AND Order_Line_Item__r.Order__r.DTL_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c <=: giftLetterBatchList[0].End_Date__c
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new filter.
                                                AND Has_Letter_Attached__c = false
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                ORDER BY CreatedDate ASC];
                    }
                }// END: Code Review Implementation 2/13/2015 JAlejandro
                //END:D-1022 12/3/14 Added by Manolo Valeña
                                        
                                        /*
                                        AND promotion_gift__r.Redemption_Start_Date__c =: giftLetterBatchList[0].Redemption_Start_Date__c
                                        AND promotion_gift__r.Redemption_End_Date__c =: giftLetterBatchList[0].Redemption_End_Date__c
                                        
                                        AND promotion_gift__r.Promotion__r.Effective_Start_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                        AND promotion_gift__r.Promotion__r.Effective_End_Date__c <=: giftLetterBatchList[0].End_Date__c
                                        */
             }                                                   
        }
        catch(exception e)
        {
            logger.log(e);
            logger.save();
        }
        
        //END: D-4268 1-13-2016 Added by Kristine Balaoing
        
        //START:D-1022 12/3/14 Added by Manolo Valeña - Updated name of variable from "OrderList" to "OrderList1"
        if(OrderList1.isEmpty() && !orderLineItemGiftList.isEmpty()) 
        {
            OrderList1 = new List<OrderObj>();
            for(Order_Line_Item_Gift__c ord : orderLineItemGiftList) {
                OrderList1.add(new OrderObj(ord));
            }
        }
        return OrderList1;
        //END:D-1022 12/3/14 Added by Manolo Valeña
    }
    
     
    public class OrderObj{
        public Order_Line_Item_Gift__c ord{get; set;}
        public Boolean selected{get; set;}

        public OrderObj(Order_Line_Item_Gift__c o) {
            ord = o;
            selected = false;
        }
    }
       
    public void generateGiftLetter()
    {
        Set<Id> promoGiftIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> orderLineItemIdSet = new Set<Id>();
        Set<Id> giftIdSet = new Set<Id>();
        Set<Id> promotionIdSet = new Set<Id>();
        Set<Id> packageIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> addressIdSet = new Set<Id>();
        Set<Id> singpostAddressIdSet = new Set<Id>();
        Set<Id> subscriptionIdSet = new Set<Id>();
        Set<string> pubCodeSet = new Set<string>();
        Set<string> ratePlanChargeSet = new Set<string>();
        
        Map<Id,Promotion_Gift__c> promoGiftMap = new Map<Id,Promotion_Gift__c>();
        Map<Id,Gift__c> giftMap = new Map<Id,Gift__c>();
        Map<Id,Promotion__c> promoMap = new Map<Id,Promotion__c>();
        Map<Id,Package__c> packageMap = new Map<Id,Package__c>();
        Map<Id,Order__c> orderMap = new Map<Id,Order__c>();
        Map<Id,Account> accountMap = new Map<Id, Account>();
        Map<Id,Contact> contactMap = new Map<Id, Contact>();
        Map<Id,Order_Line_Item__c> orderLineItemMap = new Map<Id,Order_Line_Item__c>();
        Map<Id,Address__c> addressMap = new Map<Id,Address__c>();
        Map<Id,Singpost_Address__c> singpostAddressMap = new Map<Id,Singpost_Address__c>();
        Map<Id,Zuora__Subscription__c> subscriptionMap = new Map<Id,Zuora__Subscription__c>();
        Map<Id, Zuora__SubscriptionProductCharge__c> subProdChargeMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
        Map<String , Publication__c> publicationMap = new Map<String, Publication__c>();       
        Map<String,sObject> objectMap;  
        Map<String, zqu__ProductRatePlanCharge__c> productRatePlanChargeMap = new Map<String, zqu__ProductRatePlanCharge__c>();
        
        List<Promotion_Gift__c> promoGiftList;
        List<Gift__c> giftList;
        List<Promotion__c> promotionList;
        List<Package__c> packageList;
        List<Order__c> orderList;
        List<Account> accountList;
        List<Contact> contactList;
        List<Order_Line_Item__c> orderLineItemList;
        List<Address__c> addressList;
        List<Singpost_Address__c> singpostAddressList;
        List<Zuora__Subscription__c> subscriptionList;
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList;
        List<Publication__c> publicationList;
        List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList;
        //List<Map<String,sObject>> objectMapList;
        List<Attachment> attachmentList = new List<Attachment>(); 
        
        selectedOrderList = new List<Order_Line_Item_Gift__c>();
        
        
        //START: D-4268 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        Logger logger; 
        
        if(!Test.isRunningTest()){
        logger = new Logger('SP_PackingLabelBatchRecordCreation', 'SP052');
        }
        
        try{
            for(OrderObj o: getOrderList1()) {
                if(o.selected == true) {
                    selectedOrderList.add(o.ord);
                }
            }
                    
            for(Order_Line_Item_Gift__c olig: selectedOrderList)
            {
                promoGiftIdSet.add(olig.Promotion_Gift__r.Id);
                orderLineItemIdSet.add(olig.Order_Line_Item__r.Id);
                packageIdSet.add(olig.Order_Line_Item__r.Main_Package_ID__r.Id);
            }
            // START: Code Review Implementation 2/13/2015 JAlejandro
            if (!orderLineItemIdSet.isEmpty())
            {
                orderLineItemList = [SELECT Id, Order__r.Id, Subscription__r.Id FROM Order_Line_Item__c WHERE Id IN: orderLineItemIdSet];
                if(orderLineItemList != NULL)
                {
                    for(Order_Line_Item__c oli : orderLineItemList)
                    {
                        orderIdSet.add(oli.Order__r.Id);
                        orderLineItemMap.put(oli.Id, oli);
                        subscriptionIdSet.add(oli.Subscription__r.Id);              
                    }
                }
            }
            
            if (!promoGiftIdSet.isEmpty())
            {
            promoGiftList = [SELECT Id, Gift__r.Id, Promotion__r.Id, Redemption_Letter_Details__c FROM Promotion_Gift__c WHERE Id IN :promoGiftIdSet];    if(promoGiftList != NULL)
                {  
                    for(Promotion_Gift__c pg : promoGiftList)
                    {
                        giftIdSet.add(pg.Gift__r.Id);    
                        promotionIdSet.add(pg.Promotion__r.Id);
                        promoGiftMap.put(pg.Id, pg);
                    }
                }   
            }
            
            if (!giftIdSet.isEmpty() )
            {
                giftList = [SELECT Id, Name, Gift_Cost__c, Gift_Code__c, Gift_description__c FROM Gift__c WHERE Id IN :giftIdSet];
                if(giftList != NULL)
                {
                    for(Gift__c g : giftList)
                    {
                        giftMap.put(g.Id, g);   
                    }
                }
            }
            
            if (!promotionIdSet.isEmpty())
            {
                promotionList = [SELECT Id, Contract_Period__c FROM Promotion__c WHERE Id IN :promotionIdSet];
                if(promotionList != NULL)
                {
                    for(Promotion__c pr : promotionList)
                    {
                        promoMap.put(pr.Id, pr);  
                    }
                }
            }
            
            if (!packageIdSet.isEmpty())
            {
                packageList = [SELECT Id, Name FROM Package__c WHERE Id IN :packageIdSet];
                if(packageList != NULL)
                {
                    for(Package__c pa : packageList)
                    {
                        packageMap.put(pa.Id, pa);  
                    }
                }
            }
            
            if (!orderIdSet.isEmpty())
            {
                orderList = [SELECT Id, Name, Account__r.Id, Billing_Contact__r.Id, Subscription__r.Id, Total_Monthly_Recurring_Charge__c, Monthly_Delivery_Charge_for_Full_Payment__c FROM Order__c WHERE Id IN: orderIdSet];
                if(orderList != NULL)
                    {
                        for(Order__c order : orderList)
                        {
                            orderMap.put(order.Id, order);
                            accountIdSet.add(order.Account__r.Id);
                            contactIdSet.add(order.Billing_Contact__r.Id);
                            subscriptionIdSet.add(order.Subscription__r.Id);
                        }
                    }
            }
            
            if (!accountIdSet.isEmpty())
            {
                accountList = [SELECT Id, AccountNumber FROM Account WHERE Id IN: accountIdSet];
                if(accountList != NULL)
                {
                    for(Account acc : accountList)
                    {
                        accountMap.put(acc.Id, acc);
                    }
                }
            }
            
            if (!contactIdSet.isEmpty())
            {
                contactList = [SELECT Id, FirstName, LastName, Address__r.Id, Salutation FROM Contact WHERE Id IN: contactIdSet];
                if(contactList != NULL)
                {
                    for(Contact c : contactList)
                    {
                        contactMap.put(c.Id, c);
                        addressIdSet.add(c.Address__r.Id);
                    }
         
                }
            }
            
            if (!subscriptionIdSet.isEmpty())
            {
                subscriptionList = [SELECT Id, Name, Zuora__SubscriptionStartDate__c, Subscription_Charge__c, Term_Length__c FROM Zuora__Subscription__c WHERE Id IN: subscriptionIdSet];
                if(subscriptionList != NULL)
                {        
                    for(Zuora__Subscription__c subscription : subscriptionList)
                    {
                        subscriptionMap.put(subscription.Id, subscription);
                    }
                }
        
                subProdChargeList = [SELECT Zuora__Subscription__c, Zuora__RatePlanName__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN: subscriptionIdSet];
                if(subProdChargeList != NULL)
                {       
                    for(Zuora__SubscriptionProductCharge__c subProdCharge: subProdChargeList)
                    {
                        subProdChargeMap.put(subProdCharge.Zuora__Subscription__c, subProdCharge);
                        ratePlanChargeSet.add(subProdCharge.Zuora__RatePlanName__c);
                    }
                }
            }
            
            if (!ratePlanChargeSet.isEmpty())
            {
                prodRatePlanChargeList = [SELECT Id, Name, zqu__ProductRatePlan__c, PublicationCode__c FROM zqu__ProductRatePlanCharge__c WHERE Name IN: ratePlanChargeSet]; 
                if(prodRatePlanChargeList != NULL)
                {
                    for(zqu__ProductRatePlanCharge__c prodRatePlanCharge:prodRatePlanChargeList)
                    {
                        productRatePlanChargeMap.put(prodRatePlanCharge.Name, prodRatePlanCharge);
                        pubCodeSet.add(prodRatePlanCharge.PublicationCode__c);
                    }
                }
            }
            
            if (!pubCodeSet.isEmpty())
            {
                publicationList = [SELECT Name, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN: pubCodeSet];  
                if(publicationList != NULL)
                {
                    for(Publication__c publication : publicationList)
                    {
                        publicationMap.put(publication.Publication_Code__c, publication);
                    }
                }
            }
            
            if (!addressIdSet.isEmpty())
            {
                addressList = [SELECT Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id FROM Address__c WHERE Id IN: addressIdSet];    
                
                if(addressList != NULL)
                {       
         
                    for(Address__c address : addressList)
                    {
                        addressMap.put(address.Id, address);
                        singpostAddressIdSet.add(address.Postal_Code__r.Id);
                    }
                }
            }
            
            if (!singpostAddressIdSet.isEmpty())
            {
                singpostAddressList = [SELECT Id, Name FROM Singpost_Address__c WHERE Id IN: singpostAddressIdSet];
                if(singpostAddressList != NULL)
                {
                    for(Singpost_Address__c singpostAddress : singpostAddressList)
                    {
                        singpostAddressMap.put(singpostAddress.Id, singpostAddress);
                    }
                }
            }
            
            objectMapList = new List<Map<String,sObject>>(); 
            Promotion_Gift__c pg;
            Order_Line_Item__c orderLineItem;
            Order__c order;
            Contact con;
            Address__c address; 
            Zuora__Subscription__c subscription; 
            Zuora__SubscriptionProductCharge__c subProdCharge;

            for(Order_Line_Item_Gift__c olig: selectedOrderList)
            {   // START : D-1141 2/6/2015 Alyana Navarro
                olig.Gift_Letter_Batch_Id__c = giftLetterBatchId;
                oligToUpdate.add(olig);
                // END : D-1141 2/6/2015
                objectMap = new Map<String, sObject>();
                objectMap.put('Order_Line_Item_Gift__c', olig);
                
                if(promoGiftMap != NULL)
                {
                    pg = promoGiftMap.get(olig.Promotion_Gift__r.Id);
     
                    objectMap.put('Promotion_Gift__c',pg);
                }
                if(promoMap != NULL)
                {
                    Promotion__c pr = promoMap.get(pg.Promotion__r.Id);
     
                    objectMap.put('Promotion__c',pr);            
                }
                if(giftMap != NULL)
                {    
                    if(pg != NULL)
                    {
                        Gift__c g = giftMap.get(pg.Gift__r.Id);
     
                        objectMap.put('Gift__c',g);
                    }
                }
                if(packageMap != NULL)
                {
                    Package__c pa = packageMap.get(olig.Order_Line_Item__r.Main_Package_ID__r.Id);
     
                    objectMap.put('Package__c',pa);
     
                }
                if(orderLineItemMap != NULL)
                {
                    orderLineItem = orderLineItemMap.get(olig.Order_Line_Item__r.Id);
                    objectMap.put('Order_Line_Item__c', orderLineItem);
                }
                if(orderMap != NULL)
                {  
                    if(orderLineItem != NULL)
                    {
                        order = orderMap.get(orderLineItem.Order__r.Id);
     
     
                        objectMap.put('Order__c', order);
                    }
                }
                if(accountMap != NULL)
                { 
                    if(order != NULL)
                    {           
                        Account acc = accountMap.get(order.Account__r.Id);
                        objectMap.put('Account', acc);
     
                    }
                }
                if(contactMap != NULL)
                {  
                    if(order != NULL)
                    {            
                        con = contactMap.get(order.Billing_Contact__r.Id);
                        objectMap.put('Contact', con);
     
                    }
                }
                if(subscriptionMap != NULL)
                {
                    if(orderLineItem != NULL)
                    {
                        subscription = subscriptionMap.get(orderLineItem.Subscription__r.Id);
                        objectMap.put('Zuora__Subscription__c',subscription);
     
                    }
                }
                
                if(subProdChargeMap != NULL)
                {
                    if(subscription != NULL)
                    {
                        subProdCharge = subProdChargeMap.get(subscription.Id);
                    }
                }
                
                if(productRatePlanChargeMap != NULL)
                {
                    if(subProdCharge != NULL)
                    {
                        zqu__ProductRatePlanCharge__c productRatePlan = productRatePlanChargeMap.get(subProdCharge.Zuora__RatePlanName__c);
                        objectMap.put('zqu__ProductRatePlanCharge__c',productRatePlan);
                        if(productRatePlan != NULL) 
                        {
                            Publication__c publication = publicationMap.get(productRatePlan.PublicationCode__c);
                            objectMap.put('Publication__c',publication);
                        }
                    }
                }
                
                if(addressMap != NULL)
                {
                    if(con != NULL)
                    {
                        address = addressMap.get(con.Address__r.Id);
                        objectMap.put('Address__c',address);                    
                    }
                }
                if(singpostAddressMap != NULL)
                {       
                    if(address != NULL)
                    {
     
                        Singpost_Address__c singpostAddress = singpostAddressMap.get(address.Postal_Code__r.Id);
                        objectMap.put('Singpost_Address__c',singpostAddress);
                    }
                }
     
                objectMapList.add(objectMap);
            }
            // START : D-1141 2/6/2015 Alyana Navarro
            Database.update(oligToUpdate);
            // END : D-1141 2/6/2015
        }catch(Exception e){
            logger.log(e);
            logger.save();
        }
        //END: D-4268 1-13-2016 Added by Kristine Balaoing
    }

    public pageReference generateGiftLetterBatch()
    {
    //START:D-1022 1/13/15 Added by Manolo Valeña - Updated SOQL Query to have Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c. This will replace the Gift Code and Promo Code text fields since both of them should be lookup fields.
        PageReference pageRef;
        //START 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
        /* REMOVED FOR UD-0960 and UD-0829
        if (giftLetterBatchId != null)
        {
                giftLetterBatchList = [SELECT Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c FROM Gift_Letter_Batch__c  WHERE Id =: giftLetterBatchId LIMIT 1]; 
                //END:D-1022 1/13/15 Added by Manolo Valeña
            
            //START:D-1022 1/13/15 Added by Manolo Valeña - Updated SOQL Query to have Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c. This will replace the Gift Code and Promo Code text fields since both of them should be lookup fields.
            List<Gift_Letter_Batch__c> overlapGiftLetterBatchlist = new List<Gift_Letter_Batch__c>(); 
                if (!giftLetterBatchList.isEmpty() && giftLetterBatchList[0].Redemption_End_Date__c != null && giftLetterBatchList[0].Redemption_Start_Date__c !=null && giftLetterBatchList[0].Gift__r.Gift_Code__c !=null && giftLetterBatchList[0].Promotion__r.Promotion_Code__c != null && giftLetterBatchList[0].Customer_Account_Number__c != null && giftLetterBatchId != null)
                {
                    overlapGiftLetterBatchlist = [SELECT Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, Promo_Code__c, Gift_Code__c, Start_Date__c, End_Date__c FROM Gift_Letter_Batch__c 
                                                    WHERE Redemption_Start_Date__c <: giftLetterBatchList[0].Redemption_Start_Date__c
                                AND Redemption_End_Date__c >: giftLetterBatchList[0].Redemption_End_Date__c
                                                    
                                //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                                AND Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                                AND Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                    //END:D-1022 1/13/15 Added by Manolo Valeña
                                
                                AND Customer_Account_Number__c =: giftLetterBatchList[0].Customer_Account_Number__c
                                                    AND Id !=: giftLetterBatchId];
                }
                //END:D-1022 1/13/15 Added by Manolo Valeña
            
                if(overlapGiftLetterBatchlist.size() > 0)
                { 
                    overlapBatch = true;
                }
                else
                { 
                    overlapBatch = false;
                    createGiftLetter();
                }            
                
                pageRef = new PageReference('/'+giftLetterBatchId);
                pageRef.setRedirect(true);  
        }
        REMOVED FOR UD-0960 and UD-0829 */
        //START: D-4268 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        Logger loggerFinish; 
            
        if(!Test.isRunningTest()){
        loggerFinish = new Logger('SP_PackingLabelAttachmentBatch', 'SP021');
        }
        
        try{
            createGiftLetter();
            pageRef = new PageReference('/'+giftLetterBatchId);
            pageRef.setRedirect(true); 
        }catch(Exception e){
            loggerFinish.log(e);
            loggerFinish.save();
        }
        
        //END: D-4268 1-13-2016 Added by Kristine Balaoing
        //END 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
        return pageRef;
    }
    
    public void createGiftLetter()
    {
        showListofCustomers = FALSE;
        showLetter = TRUE;    
        //REMOVED generateGiftLetter(); //START/END 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
        template = '';    
        //List<Attachment> attachmentList = new List<Attachment>(); 
        List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>();
        //if(objectMapList != null)
        //{
            /*
            for(Map<String, sObject> objectMap : objectMapList)
            {
                Attachment attachment = new Attachment();
                Blob body; 

                body = Blob.toPdf(displayPreview(objectMap)); 
                
                attachment.Body = body;
                attachment.Name = 'Order Line Item Gift.pdf';
                attachment.IsPrivate = false;
                attachment.ParentId = objectMap.get('Order_Line_Item_Gift__c').Id;
                attachmentList.add(attachment);
               
                template += 'Order Line Item Gift ID: ' + objectMap.get('Order_Line_Item_Gift__c').Id + '<br/>';
                template += displayPreview(objectMap);
            }
            try
            {
                insert attachmentList;        
            }
            catch(Exception e)
            {      
            }
            */
            
            //START: 1/27/2015 D-1982 Kevin Evasco - Updated to follow the letter type in SP_GenerateLetterPrintBatch
            String pdfGeneratorKey;         
            
            if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_GIFT_LETTER)
            {               
                pdfGeneratorKey = SP_GenerateLetterPrintBatch.giftLetter;
            }
            //START:D-2218 2/13/15 Added by Manolo Valeña - Removed as it is now the same as the first condition.      
            /*else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_PRESENT_LETTER)
            {               
                pdfGeneratorKey = SP_GenerateLetterPrintBatch.presentGift;
            }*/  
            //END:D-2218 2/13/15 Added by Manolo Valeña   
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_SUBSCRIPTION_LETTER)
            {               
                pdfGeneratorKey = SP_GenerateLetterPrintBatch.subscriptionLetter;
            }   
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_RENEWAL_LETTER)
            {               
                pdfGeneratorKey = SP_GenerateLetterPrintBatch.giftRenewalLetter;
            }   
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_REDEMPTION_LETTER)
            {               
                pdfGeneratorKey = SP_GenerateLetterPrintBatch.giftRedemptionLetter;
            }
            //START:D-2218 2/13/15 Added by Manolo Valeña - Added additional conditions for the 2 new templates that will be added.
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_PREMIUM_CHINA)
            {               
                pdfGeneratorKey = SP_GenerateLetterPrintBatch.giftPremiumChina;
            }
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_PREMIUM_ENGLISH)
            {               
                pdfGeneratorKey = SP_GenerateLetterPrintBatch.giftPremiumEnglish;
            }
            //END:D-2218 2/13/15 Added by Manolo Valeña
            
            
            //START 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
            List<Order_Line_Item_Gift__c> oligToUpdate = new List<Order_Line_Item_Gift__c>();
            Set<Id> orderLineItemIdSet = new Set<Id>();         
            for(OrderObj o: OrderList1) {
                if(o.selected == true) {
                    orderLineItemIdSet.add(o.ord.Id);
                    oligToUpdate.add(o.ord);
                }
            }                   
            
            for(Order_Line_Item_Gift__c olig: oligToUpdate)
            {   // START : D-1141 2/6/2015 Alyana Navarro
                olig.Gift_Letter_Batch_Id__c = giftLetterBatchId;
            }
            
            update oligToUpdate;
            
            for(Id idElement : orderLineItemIdSet)
            {           
                Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                letterPrintRequest.Letter_Type__c = pdfGeneratorKey;
                letterPrintRequest.Record_ID__c = idElement;
                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;

                letterPrintRequests.add(letterPrintRequest);
            }
            //END 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
            if(letterPrintRequests.size() > 0)
            {
                insert letterPrintRequests;
            }                        
            
            // START 12/05/2014 D-0797, D-0849 Kevin Evasco Updated Batch Job Scheduler constructor to enable storage of Session ID.
            
            if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_GIFT_LETTER)
            {                             
                SP_BatchJobSchedulerService.processRequest('SP034','Start', null, UserInfo.getSessionId());
            }
            //START:D-2218 2/13/15 Added by Manolo Valeña - Removed as it is now the same as the first condition.     
            /*else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_PRESENT_LETTER)
            {               
                SP_BatchJobSchedulerService.processRequest('SP035','Start', null, UserInfo.getSessionId());
            }*/   
            //END:D-2218 2/13/15 Added by Manolo Valeña 
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_SUBSCRIPTION_LETTER)
            {               
                SP_BatchJobSchedulerService.processRequest('SP036','Start', null, UserInfo.getSessionId());
            }   
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_RENEWAL_LETTER)
            {               
                SP_BatchJobSchedulerService.processRequest('SP037','Start', null, UserInfo.getSessionId());
            }   
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_REDEMPTION_LETTER)
            {               
                SP_BatchJobSchedulerService.processRequest('SP038','Start', null, UserInfo.getSessionId());
            }
            //START:D-2218 2/13/15 Added by Manolo Valeña - Added additional conditions for the 2 new templates that will be added. 
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_PREMIUM_CHINA)
            {               
                SP_BatchJobSchedulerService.processRequest('SP040','Start', null, UserInfo.getSessionId());
            }
            else if(giftLetterBatchList[0].Letter_Template__c == GlobalVariableClass.LP_GIFT_PREMIUM_ENGLISH)
            {               
                SP_BatchJobSchedulerService.processRequest('SP041','Start', null, UserInfo.getSessionId());
            }     
            //END:D-2218 2/13/15 Added by Manolo Valeña
            // END 12/05/2014 D-0797, D-0849 Kevin Evasco Updated Batch Job Scheduler constructor to enable storage of Session ID
            //END: 1/27/2015 D-1982 Kevin Evasco - Updated to follow the letter type in SP_GenerateLetterPrintBatch  
        //}
    }
    
    public void previewPage() 
    {
        //START: D-4268 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        List<Exception> exceptionList = new List<Exception>();
        try{
            showListofCustomers = FALSE;
            showLetter = TRUE;
            generateGiftLetter();
            if(objectMapList != NULL && !objectMapList.isEmpty())
            {
                template = displayPreview(objectMapList.get(0));        
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        //END: D-4268 1-13-2016 Added by Kristine Balaoing
    }
    
    
    public String displayPreview(Map<String, sObject> valuesToParseMap)
    {
        String result;
        try 
        {            
            DateTime today = System.Today();
            // START: Code Review Implementation 2/13/2015 JAlejandro
            if (emailTemplateId != null)
            {
                result = [SELECT Body FROM EmailTemplate WHERE Id = :emailTemplateId].Body;                        
                Integer startIndex = 0;
                Integer endIndex = 0;
                String oldValue, actualValue, fieldName;
                integer counter = 0;
                
                while(true)
                {          
                    startIndex = result.indexOf('{{') + 2;  
                    
                    if(counter> 50 || startIndex == 1)
                    {
                        break;
                    }
                    counter++;
                    endIndex = result.indexOf('}}') + 2;
                    oldValue = result.subString(startIndex - 2, endIndex);
                    
                    if(oldValue.equals('{{Today}}'))
                    {
                        result = result.replace(oldValue, today.format('MMMM d, YYYY'));
                    }
                    else
                    {
                        String insideValue = result.subString(startIndex, endIndex - 2);
                        String[] values = insideValue.split('\\.');            
                        String objName = values[0];
                        fieldName = values[1];   
                        
                        if(fieldName.equals('MailingAddress'))
                        {
                            Address__c address = (Address__c)valuesToParseMap.get('Address__c');
                            Singpost_Address__c postalCode = (Singpost_Address__c)valuesToParseMap.get('Singpost_Address__c');
                            
                            if(address != null && postalCode != null)
                            {  
                                result = result.replace(oldValue, address.block_house_number__c + ' '  + address.Street_Name__c + '<br/>' 
                                                            + '#' + address.level_number__c + ' - ' + address.unit_number__c + '<br/>' 
                                                            + address.Building_Name__c + '<br/>SINGAPORE' + ' ' + postalCode.name);
                            }
                            else
                            {
                                result = result.replace(oldValue, 'null'); 
                            }
                        } 
                        else if(fieldName.indexOf('Date') > -1 )
                        {              
                            sObject so1 = valuesToParseMap.get(objName);                                 
                            actualValue = String.valueOf(so1.get(fieldName));                   
                            result = result.replace(oldValue, actualValue.substring(0,10));                                                                              
                        }
                        else
                        {
                            if(valuesToParseMap.containsKey(objName)) 
                            {
                                sObject so1 = valuesToParseMap.get(objName);                                
                                actualValue = String.valueOf(so1.get(fieldName));
                                
                                if(actualValue != null)
                                {
                                    result = result.replace(oldValue, actualValue);     
                                }
                                else
                                {
                                    result = result.replace(oldValue, 'null');   
                                }                                             
                            }
                            else
                            {
                                result = result.replace(oldValue, 'null');  
                            }
                        }              
                    }     
                }
            }// END: Code Review Implementation 2/13/2015 JAlejandro
        }
        catch(Exception e) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }   
        return result;
    }   
    
    public void showCustomerList()
    {
        showLetter = FALSE;
        showListofCustomers = TRUE;
    }
    
    public pageReference cancel()
    {
        PageReference pageRef = new PageReference('/'+giftLetterBatchId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}