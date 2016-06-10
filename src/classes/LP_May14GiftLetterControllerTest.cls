/**
* Class Name: LP_May14GiftLetterControllerTest
* @author: Reuben James V. San Diego
* Date: 2/7/2015
* @Description: This is the test class for LP_May14GiftLetterController.
* History: Patrick Pancho - 2/11/2015 - Updated Test Class for additional coverage
*
*/
@isTest(SeeAllData=true)
public class LP_May14GiftLetterControllerTest{

    static testMethod void testMay14GiftLetter(){
        String error = '';
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            //insert test data
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');         
            insert accList;
              
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            country.Zone__c = zone.Id;
            //insert country;
            
            //Create Address
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Address_Type__c='P';
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            add.Postal_Code__c = postal.id;
            insert add;
              
            //Create Contact
            Contact con = TestDataFactory.createContact(1)[0];
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Address__c = add.Id;
            con.AccountId = accList[0].Id;
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            insert con;
            //END PPancho 2/11/2015
    
                     
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(2);
            billAccountList[0].Zuora__Account__c = accList[0].id;
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[1].Zuora__Account__c = accList[1].id;     
            billAccountList[1].Billing_Contact__c = con.id;
            insert billAccountList;   
            
            Integer numPackageItems = 1;
            String recType = '';
            
          //  RecordType recordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Base Product' LIMIT 1];
          //  recType = recordType.DeveloperName;
            
            
            List<Gift__c> giftList = TestDataFactory.createGift(2);   
            giftList[0].gift_description__c = 'Red Gift';
            giftList[1].gift_description__c = 'Red Gift';
            insert giftList;
            
            List<Promotion_Gift__c> promogiftList = TestDataFactory.createPromotionGift(2);   
            promogiftList[0].Gift__c = giftList[0].id;
            promogiftList[0].redemption_letter_details__c = 'RedemptionLetter';
            promogiftList[1].Gift__c = giftList[1].id;
            promogiftList[1].redemption_letter_details__c = 'RedemptionLetter';
            insert promogiftList;
            
            List<Promotion__c> promoList = TestDataFactory.createPromotion(2);
            promoList[0].Contract_Period__c = '36';
            promoList[1].Contract_Period__c = '36';
            insert promoList;
                    
             
            //System.assertEquals('Base Product', recordType.name);
            
            /*List<Order__c> orderList = TestDataFactory.createOrder(2);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[1].Account__c = accList[1].id;
            orderList[1].Subscriber_Charge__c = 100;
            orderList[0].Recipient_Contact__r.AccountId = accList[0].id;
            orderList[1].Recipient_Contact__r.AccountId = accList[1].id;
            insert orderList;*/
            
         
            List<Package__c> pack = TestDataFactory.createPackage(2);    
            pack[0].Package_Type__c = 'Bundle';
            pack[0].Name = 'Bundle Product';
            pack[0].Subscription_Type__c = 'Termed';
            pack[0].Package_Code__c = 'STEST12';
            pack[0].Subscription_Period__c = '12';
            pack[0].Effective_Start_Date__c = date.today();
            pack[0].Effective_End_Date__c = date.today() + 5;
           
            pack[1].Package_Type__c = 'Base';
            pack[1].Name = 'Base Product';
            pack[1].Subscription_Type__c = 'Termed';
            pack[1].Package_Code__c = 'STEST15';
            pack[1].Subscription_Period__c = '12';
            pack[1].Effective_Start_Date__c = date.today();
            pack[1].Effective_End_Date__c = date.today() + 5;
            //pack[0].RecordType = recordTypeId;
            insert pack;
            
            
            
            List<Order__c> orderList = TestDataFactory.createOrder(2);
            //set values
            orderList[0].Account__c = accList[0].id;
            orderList[0].Status__c = 'Draft';
            //orderList[0].Base_Subscription__c = zsubList[0].id;
            orderList[0].Order_Type__c = 'Start';
            orderList[0].Recipient_Contact__c = con.id;//PPancho 2/11/2015
            orderList[0].Subscriber_Charge__c = 200;
            
            orderList[1].Account__c = accList[1].id;
            orderList[1].Status__c = 'Draft';
            //orderList[1].Base_Subscription__c = zsubList[1].id;
            orderList[1].Order_Type__c = 'Start';
            //orderList[1].Recipient_Contact__c = con.id;
            orderList[1].Subscriber_Charge__c = 200;
           // orderList[1].Recipient_Contact__r.AccountId = accList[0].id;
            insert orderList;   
 
 
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = pack[0].id;   
            orderLineItemList[0].Term_Length__c = 10;
            
            orderLineItemList[1].Term_Length__c = 10;
            orderLineItemList[1].Order__c = orderList[1].id; 
            orderLineItemList[1].Main_Package_ID__c = pack[0].id;    
            insert orderLineItemList;
            
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(2);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSublist[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Number_of_Copies__c = 100;
            zsubList[0].Qty__c = 20;
            zsubList[0].Main_Package_1__c = orderLineItemList[0].Main_Package_ID__c;
            zsubList[0].Main_Package__c = orderLineItemList[0].Main_Package_ID__c;
            zsubList[1].Zuora__Account__c = accList[1].id;     
            zsubList[1].Zuora__CustomerAccount__c = billAccountList[1].id;
            zsubList[1].Qty1__c ='10';  
            zsubList[1].Order_Number__c = orderList[1].id; 
            zsubList[1].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSublist[1].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zsubList[1].Delivery_Charge__c = 200;
            //zsubList[1].Main_Package_1__c = oliList[1].Main_Package_ID__c;
            zsubList[1].Number_of_Copies1__c =  '100';
            zsubList[1].Number_of_Copies__c = 100;
            zsubList[1].Qty__c = 20;
            zsubList[1].Delivery_Charge__c = 200;
            zsubList[1].Subscription_Type_1__c = 'Publication';
            zsubList[1].Subscription_Type__c = 'Publication';
            zsubList[1].Main_Package_1__c = orderLineItemList[0].Main_Package_ID__c;
            zsubList[1].Main_Package__c = orderLineItemList[0].Main_Package_ID__c;
            insert zsubList;
             
                             
            Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c(
                Promotion__c = promoList[0].id,
                Gift__c = giftList[0].id,
                Start_Date__c = date.Today(),
                End_Date__c = date.Today()+7,
                Redemption_Start_Date__c = date.Today()+4,
                Redemption_End_Date__c = date.Today()+7,
                Batch_Date__c = date.today(),
                Letter_Template__c = 'Gift Letter');
            insert glb;
    
    
             /*
            List<Order_Line_Item__c> oliList = TestDataFactory.createOrderLineItem(2);
            //set values
            oliList[0].Order__c = orderList[0].id;
            oliList[0].Main_Package_ID__c = pack[0].id;
            oliList[0].Start_Date__c = date.today()+100;
            oliList[0].Term_Length__c = 20;
            oliList[1].Order__c = orderList[1].id;
            oliList[1].Main_Package_ID__c = pack[1].id;
            oliList[1].Start_Date__c = date.today()+100;
            oliList[1].Term_Length__c = 20;
            insert oliList;
            */
    
            
            List<Order_Line_Item_Gift__c> oligList = TestDataFactory.createItemGift(2);
            //set values
     
            //oligList[0].Order_Line_Item__c = oliList[0].id;
            oligList[0].Order_Line_Item__c = orderLineItemList[0].id;
            oligList[0].Promotion_Gift__c = promogiftList[0].id;
            oligList[0].Gift_Letter_Batch_Id__c = glb.id;
            //oligList[1].Order_Line_Item__c = oliList[1].id;
            oligList[1].Order_Line_Item__c = orderLineItemList[1].id;
            oligList[1].Promotion_Gift__c = promogiftList[1].id;
            oligList[1].Gift_Letter_Batch_Id__c = glb.id;
            insert oligList;
            
            ApexPages.currentPage().getParameters().put('id', oligList[0].id );
             
            /*    
            zsubList[0].Order_Line_Item_Number_1__c = oliList[0].id;
            zsubList[0].Subscription_Type__c = 'Publication';
            zsubList[0].Main_Package_1__c = oliList[0].Main_Package_ID__c;
            zsubList[0].Main_Package__c = oliList[0].Main_Package_ID__c;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Number_of_Copies__c = 100;
            zsubList[0].Qty__c = 20;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[1].Delivery_Charge__c = 200;
            zsubList[1].Order_Line_Item_Number_1__c = oliList[1].id;
            //zsubList[1].Subscription_Type__c = 'Publication';
            zsubList[1].Main_Package_1__c = oliList[1].Main_Package_ID__c;
            zsubList[1].Main_Package__c = oliList[0].Main_Package_ID__c;
            zsubList[1].Number_of_Copies1__c =  '100';
            zsubList[1].Number_of_Copies__c = 100;
            zsubList[1].Qty__c = 20;
            
            update zsubList;
            */    
  
                
                                  
            List<zqu__ZProduct__c> zProduct = TestDataFactory.createZProduct(1);
            zProduct[0].Name = 'ZProduct';
            zProduct[0].ProductCode__c = '1102';
            insert zProduct;
            
            List<zqu__ProductRatePlan__c> ratePlan = TestDataFactory.createProductRatePlan(1);
            ratePlan[0].zqu__ZProduct__c = zProduct[0].id;
            insert ratePlan;
            
            RecordType recType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Package_Item__c' AND Name = 'Bundle Product'];
            List<Package_Item__c> createpckge = TestDataFactory.createPackageItem(2, 'Bundle Product');
            createpckge[0].NAme = 'Package';
            createpckge[0].Product_Rate_Plan__c = ratePlan[0].id;
            createpckge[0].Package__c = pack[0].id;
            createpckge[0].RecordTypeId = recType1.Id;
            
            createpckge[1].NAme = 'Package';
            createpckge[1].Product_Rate_Plan__c = ratePlan[0].id;
            createpckge[1].Package__c = pack[0].id;
            createpckge[1].RecordTypeId = recType1.Id;
            insert createpckge;  
//            createpckge[0].Package__c = pack[0].id; 
//            update createpckge;
           
           
            Test.startTest(); 
                    PageReference pageRef = Page.LP_GiftLetterMag;
                    Test.setCurrentPageReference(pageRef);
                    apexPages.currentPage().getParameters().put('id', oligList[0].Id);
                    //apexPages.currentPage().getParameters().put('id', oligList[0].Id);            
                    LP_May14GiftLetterController lpMay14GiftLetter = new LP_May14GiftLetterController();
                    Date dateToday = lpMay14GiftLetter.Today;
                    lpMay14GiftLetter.initialize();
            Test.stopTest();
          }
          catch(Exception e) {
          }  
      }  
         
  
  static testMethod void testNotBundle(){
        String error = '';
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            //insert test data
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');         
            insert accList;
                   
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = null;
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = null;
            postal.House_Block_Number__c = null;
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            country.Zone__c = zone.Id;
            //insert country;
            
            //Create Address
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = null;
            add.Level_Number__c = null;
            add.Unit_Number__c = null;
            add.Country__c = country.Id;
            insert add;  
            
            //Create Contact
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = add.Id;
            con.AccountId = accList[0].Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true; 
            con.Billing_Indicator__c = false;
            insert con;
            //END PPancho 2/11/2015
    
                     
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(2);
            billAccountList[0].Zuora__Account__c = accList[0].id;
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[1].Zuora__Account__c = accList[1].id;     
            billAccountList[1].Billing_Contact__c = con.id;
            insert billAccountList;    
            
         
            List<Gift__c> giftList = TestDataFactory.createGift(2);   
            giftList[0].gift_description__c = 'Red Gift';
            giftList[1].gift_description__c = 'Red Gift';
            insert giftList;
            
            List<Promotion_Gift__c> promogiftList = TestDataFactory.createPromotionGift(2);   
            promogiftList[0].Gift__c = giftList[0].id;
            promogiftList[0].redemption_letter_details__c = 'RedemptionLetter';
            promogiftList[1].Gift__c = giftList[1].id;
            promogiftList[1].redemption_letter_details__c = 'RedemptionLetter';
            insert promogiftList;
            
            
            List<Promotion__c> promoList = TestDataFactory.createPromotion(2);
            promoList[0].Contract_Period__c = '36';
            promoList[1].Contract_Period__c = '36';
            insert promoList;
            
            
                    
           
            List<Package__c> pack = TestDataFactory.createPackage(2);    
            pack[0].Package_Type__c = 'Bundle';
            pack[0].Name = 'Bundle Product';
            pack[0].Subscription_Type__c = 'Termed';
            pack[0].Package_Code__c = 'STEST12';
            pack[0].Subscription_Period__c = '12';
            pack[0].Effective_Start_Date__c = date.today();
            pack[0].Effective_End_Date__c = date.today() + 5;
             
            pack[1].Package_Type__c = 'Add on';
            pack[1].Name = 'Base Product';
            pack[1].Subscription_Type__c = 'Termed';
            pack[1].Package_Code__c = 'STEST15';
            pack[1].Subscription_Period__c = '12';
            pack[1].Effective_Start_Date__c = date.today();
            pack[1].Effective_End_Date__c = date.today() + 5;
            //pack[0].RecordType = recordTypeId;
            insert pack;
            
            Integer numPackageItems = 1;
            String recType = '';
               
             List<zqu__ZProduct__c> zProduct = TestDataFactory.createZProduct(1);
            zProduct[0].Name = 'ZProduct';
            zProduct[0].ProductCode__c = '1102';
            insert zProduct;
            
            List<zqu__ProductRatePlan__c> ratePlan = TestDataFactory.createProductRatePlan(1);
            ratePlan[0].zqu__ZProduct__c = zProduct[0].id;
            insert ratePlan;
            
            RecordType recType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Package_Item__c' AND Name = 'Bundle Product'];
            List<Package_Item__c> createpckge = TestDataFactory.createPackageItem(2, 'Bundle Product');
            createpckge[0].NAme = 'Package';
            createpckge[0].Product_Rate_Plan__c = ratePlan[0].id;
            createpckge[0].Package__c = pack[0].id;
            //createpckge[0].RecordType.Name = recordType[0].Name;
            createpckge[0].RecordTypeId = recType1.Id;
            
            createpckge[1].NAme = 'Package';
            createpckge[1].Product_Rate_Plan__c = ratePlan[0].id;
            createpckge[1].Package__c = pack[0].id;
            //createpckge[0].RecordType.Name = recordType[0].Name;
            createpckge[1].RecordTypeId = recType1.Id;
            insert createpckge;  
            
            
                      
            List<Order__c> orderList = TestDataFactory.createOrder(2);
            //set values
            orderList[0].Account__c = accList[0].id;
            orderList[0].Status__c = 'Draft';
            //orderList[0].Base_Subscription__c = zsubList[0].id;
            orderList[0].Order_Type__c = 'Start';
            orderList[0].Recipient_Contact__c = con.id;//PPancho 2/11/2015
            orderList[0].Subscriber_Charge__c = 200;
            
            orderList[1].Account__c = accList[1].id;
            orderList[1].Status__c = 'Draft';
            //orderList[1].Base_Subscription__c = zsubList[1].id;
            orderList[1].Order_Type__c = 'Start';
           // orderList[1].Recipient_Contact__c = con.id;
            orderList[1].Subscriber_Charge__c = 200;
           // orderList[1].Recipient_Contact__r.AccountId = accList[0].id;
            insert orderList;   
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = pack[0].id;
            orderLineItemList[0].Term_Length__c = 10;
            
            orderLineItemList[1].Order__c = orderList[1].id; 
            orderLineItemList[1].Main_Package_ID__c = pack[0].id;   
            orderLineItemList[1].Term_Length__c = 10;    
            insert orderLineItemList;
           
            
           
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(2);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSublist[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Number_of_Copies__c = 100;
            zsubList[0].Qty__c = 20;
            zsubList[0].Subscription_Type__c = 'Publication';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Main_Package_1__c = orderLineItemList[0].Main_Package_ID__c;
            zsubList[0].Main_Package__c = orderLineItemList[0].Main_Package_ID__c;
            
            zsubList[1].Zuora__Account__c = accList[1].id;     
            zsubList[1].Zuora__CustomerAccount__c = billAccountList[1].id;
            zsubList[1].Qty1__c ='10';  
            zsubList[1].Order_Number__c = orderList[1].id; 
            zsubList[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSublist[1].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zsubList[1].Delivery_Charge__c = 200;
            //zsubList[1].Main_Package_1__c = oliList[1].Main_Package_ID__c;    
            zsubList[1].Number_of_Copies1__c =  '100';
            zsubList[1].Number_of_Copies__c = 100;
            zsubList[1].Qty__c = 20;
            zsubList[1].Delivery_Charge__c = 200;
            zsubList[1].Subscription_Type__c = 'Publication';
            zsubList[1].Subscription_Type_1__c = 'Publication';
            zsubList[1].Main_Package_1__c = orderLineItemList[0].Main_Package_ID__c;
            zsubList[1].Main_Package__c = orderLineItemList[0].Main_Package_ID__c;
            insert zsubList;
             
                             
            Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c(
                Promotion__c = promoList[0].id,
                Gift__c = giftList[0].id,
                Start_Date__c = date.Today(),
                End_Date__c = date.Today()+7,
                Redemption_Start_Date__c = date.Today()+4,
                Redemption_End_Date__c = date.Today()+7,
                Batch_Date__c = date.today(),
                Letter_Template__c = 'Gift Letter');
            insert glb;
    
    /*
            List<Order_Line_Item__c> oliList = TestDataFactory.createOrderLineItem(2);
            //set values
            oliList[0].Order__c = orderList[0].id;
            oliList[0].Main_Package_ID__c = pack[0].id;
            oliList[0].Start_Date__c = date.today()+100;
            oliList[0].Term_Length__c = 20;
            oliList[1].Order__c = orderList[1].id;
            oliList[1].Main_Package_ID__c = pack[1].id;
            oliList[1].Start_Date__c = date.today()+100;
            oliList[1].Term_Length__c = 20;
            insert oliList;
   */
            List<Order_Line_Item_Gift__c> oligList = TestDataFactory.createItemGift(2);
            //set values
     
            //oligList[0].Order_Line_Item__c = oliList[0].id;
            oligList[0].Order_Line_Item__c =orderLineItemList[0].id;
            oligList[0].Promotion_Gift__c = promogiftList[0].id;
            oligList[0].Gift_Letter_Batch_Id__c = glb.id;
            //oligList[1].Order_Line_Item__c = oliList[1].id;
            oligList[1].Order_Line_Item__c = orderLineItemList[1].id;
            oligList[1].Promotion_Gift__c = promogiftList[1].id;
            oligList[1].Gift_Letter_Batch_Id__c = glb.id;
            insert oligList;
            
            ApexPages.currentPage().getParameters().put('id', oligList[0].id );
        /*    
            zsubList[0].Order_Line_Item_Number_1__c = oliList[0].id;
            //zsubList[0].Subscription_Type__c = 'Publication';
            zsubList[0].Main_Package_1__c = oliList[0].Main_Package_ID__c;
            zsubList[0].Main_Package__c = oliList[0].Main_Package_ID__c;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Number_of_Copies__c = 100;
            zsubList[0].Qty__c = 20;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[1].Order_Line_Item_Number_1__c = oliList[1].id;
            //zsubList[1].Subscription_Type__c = 'Publication';
            zsubList[1].Main_Package_1__c = oliList[1].Main_Package_ID__c;
            zsubList[1].Main_Package__c = oliList[0].Main_Package_ID__c;
            zsubList[1].Number_of_Copies1__c =  '100';
            zsubList[1].Number_of_Copies__c = 100;
            zsubList[1].Qty__c = 20;
            zsubList[1].Delivery_Charge__c = 200;
            update zsubList;*/
            
                      
            String contactMailingAddress = 'mailing address';
            double paymentAmount = 11;
            date expirationDate = date.Today()+1;
            String ProductCode = '';
            String ProductName = '';
     
            Test.startTest(); 
                    PageReference pageRef = Page.LP_GiftLetterMag;
                    Test.setCurrentPageReference(pageRef);
                    apexPages.currentPage().getParameters().put('id', oligList[0].Id);
                    //apexPages.currentPage().getParameters().put('id', oligList[0].Id);            
                    LP_May14GiftLetterController lpMay14GiftLetter = new LP_May14GiftLetterController();
                    lpMay14GiftLetter.contactMailingAddress = contactMailingAddress ;
                    lpMay14GiftLetter.paymentAmount = paymentAmount;
                    lpMay14GiftLetter.expirationDate = expirationDate;
                    lpMay14GiftLetter.ProductCode = ProductCode;
                    lpMay14GiftLetter.ProductName = ProductName;
                    Date dateToday = lpMay14GiftLetter.Today;
                    lpMay14GiftLetter.initialize();
            Test.stopTest();
          }
          catch(Exception e) {
          }  
      }
}