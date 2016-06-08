/**********************************************************************/
/* Class Name:  PromotionTriggerHandlerTest
/* @author: Marie Kristine Munda
/* Description: A test class for PromotionTriggerHandler Class
/* Date Last Modified: 07/08/2015
/**********************************************************************/

@isTest (Seealldata = TRUE)
private class PromotionTriggerHandlerTest{
        
    private static List<Promotion__c> promoList;  
    private static List<Promotion__c> newPromoList;
    private static List<Order_Line_Item__c> oliList;
    private static List<Package__c> pkgList;
    private static List<Order__c> orderRecord;
    private static List<Zuora__Subscription__c> sublist;
    private static PromotionTriggerHandler pth;
    
    /** 
    * @date 07/08/2015
    * @description This method prepares the data for this test class.
    */
    static void prepareTestData() {
       /****************************** Test Data Creation ****************************/
       /*   Insert code statements that inserts Data                                 */
       /*   needed by Base Class.                                                    */
       /******************************************************************************/
        
       Integer count = 0;
       promoList = new List<Promotion__c>();
       pkgList = new List<Package__c>();
       orderRecord = new List<Order__c>();
       sublist = new List<Zuora__Subscription__c>();
       oliList = new List<Order_Line_Item__c>();
       pth = new PromotionTriggerHandler();
   
       // Insert Account
       Account acct = new Account(
            Name = 'Test Account'
        );
        
       insert acct;
        
       //Create Singapore postal 
       Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
       insert postal;
       
       //Create Adress   
       Address__c addressRec = TestDataFactory.createAddress(1)[0];
       addressRec.Address_Type__c='P';
       addressRec.Postal_Code__c = postal.Id;
       insert addressRec;
        
       // Create Contact
       Contact con = TestDataFactory.createContact(1)[0];
       con.Address__c = addressRec.Id;
       con.AccountId = acct.Id;
       con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
       con.Recipient_Indicator__c = true;          
       insert con;
        
       //Create Package    
       List<Package__c> packageList = TestDataFactory.createPackage(1);
       for(Package__c item : packageList){
             item.name = 'sample package';
             item.Package_Type__c = 'Discount';
             item.Package_Sub_Type__c = 'Tiered';
             item.Package_code__c = 'T0013ABS';
             item.Effective_Start_Date__c = date.today();
             item.Effective_End_Date__c = date.today().addDays(1);    
       }        
       insert packageList ;
        
       for(Integer i = 0; i < 200; i++){
            pkgList.add(
                new Package__c(
                    Name = 'Test Pkg' + i,
                    Package_Code__c = '000123' + i,
                    Effective_Start_Date__c = Date.today(),
                    Effective_End_Date__c = Date.today().addDays(5)
                    )
                );
       }
        insert pkgList;
        
        Set<Id> packageIds= new Set<Id>();
            for(Package__c pkg: pkgList){
                packageIds.add(pkg.id);
            }
   
        //List Promotion
        promoList = TestDataFactory.createPromotion(1);
        for(Promotion__c item:promoList){
            item.Promotion_Code__c = 'Promo Code';
            item.Name = 'Test Promo';
            item.Effective_Start_Date__c = Date.today();
            item.Effective_End_Date__c = Date.today().addDays(5);
            item.Contract__c='No';
           
        }
        insert promoList;
        
        System.assertEquals('Promo Code', promoList[0].Promotion_Code__c);
         
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acct.id;
        insert billAccountList;
        
                   
        // Create New promo
        newPromoList = new List<Promotion__c>();
        for(Integer i =0; i<200; i++){
            newPromoList.add(
                new Promotion__c(
                    Promotion_Code__c = 'PromoCode',
                    Name = 'Test Promotion2',
                    Effective_Start_Date__c = Date.today(),
                    Effective_End_Date__c = Date.today().addDays(5),
                    Contract__c ='No'
                    )
                );
         }
         insert newPromoList;
         System.assertEquals('Test Promotion2', newPromoList[0].Name );
        
        Set<Id> promoIds = new Set<Id>();
        for(Promotion__c prm : newPromoList){
                promoIds.add(prm.id);
        }
        
        
        //Create Order
        count = 0;
        orderRecord = TestDataFactory.createOrder(1);
        for (Order__c orderRec: orderRecord){
                orderRec.Id = orderRecord[count].Id;
                orderRec.Account__c = acct.Id;
                orderRec.Informed_Customer__c = true;
                orderRec.Recipient_Contact__c = con.Id;
                orderRec.Credit_Balance__c = 150.0; 
                orderRec.Delivery_Charge__c = 50.0; 
                orderRec.Monthly_Delivery_Charge_for_Full_Payment__c = 10.0;
                orderRec.Subscriber_Charge__c = 100;
                count++;
            }
        insert orderRecord;
        system.assertNotEquals(null, orderRecord);          
        
        for(Integer i = 0; i < 100; i++){
            oliList.add(
                new Order_Line_Item__c(
                    Promotion_ID__c = newPromoList[i].Id,
                    Order__c = orderRecord[0].Id,
                    Delivered_By__c = 'Mailing Agent',
                    Main_Package_Billing_Type__c = 'Recurring Prepaid',
                    Main_Package_Frequency__c = 'TestPackFreq',
                    Main_Package_Sub_Type__c = 'TestSubType',
                    Main_Package_Type__c = 'TestPackType',
                    End_Date__c = Date.today().addDays(30),
                    Main_Package_ID__c = pkgList[i].Id    
                )
            );
        }
        insert oliList;  
       
        //New Orderlineitem
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli: orderLineItems){
           oli.Order__c = orderRecord[count].Id; 
           oli.Main_Package_ID__c = PackageList[count].id;
           count++;
        }
        insert orderLineItems;
        
        //List Subscription
        List<Zuora__Subscription__c> subscriptionList = TestDataFactory.createSubscription(1);
        for(Zuora__Subscription__c subscript: subscriptionList){
            subscript.Zuora__Account__c = acct.id;
            subscript.Zuora__CustomerAccount__c = billAccountList[0].id;
            subscript.Qty1__c ='20';  
            subscript.Order_Number__c = orderRecord[0].id;   
            subscript.Order_Line_Item_Number__c = orderLineItems[0].id;
            subscript.Delivery_Charge__c = 200;
            subscript.Number_of_Copies1__c =  '100';
            subscript.Number_of_Copies__c = 100;
            subscript.Zuora__Status__c = 'Active';
            subscript.Qty__c = 20;
        }
        
        insert subscriptionList;
        System.assertNotEquals(NULL,subscriptionList[0].Zuora__Status__c);
    }
    
    
    /************************************/
    /* This method tests the code quality of PromotionTriggerHandler class.
    /************************************/
    static testmethod void  testPromotionTriggerHandler(){
        boolean errorExist = false;
        try{
            prepareTestData();
            Test.startTest();
        
            Promotion__c prom = promoList[0];
            prom.Id = null;
            prom.Promotion_Code__c =  'PromoCode';            
            insert prom;
            System.assertEquals(prom.Promotion_Code__c , 'PromoCode');     
            
            update prom;
            /**
            delete oliList;
            delete prmList;*/
            Test.stopTest();
          }catch(Zuora.zRemoteException e){
            errorExist = true;
          }
        
            
            pth.runBeforeInsertTrigger();
            pth.runBeforeUpdateTrigger();
            pth.runBeforeDeleteTrigger();
            pth.runAfterInsertTrigger();
            pth.runAfterUpdateTrigger();
            pth.runAfterDeleteTrigger();
            
            delete newPromoList;
            
            System.assertEquals(false, errorExist);
    
   }//End of testPromotionTriggerHandler Method 
          

}//End of PromotionTriggerHandlerTest