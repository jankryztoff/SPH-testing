/**
* Class Name: viewOrderForDirectSubscriptionTest
* @author: Marie Kristine Munda
* Date: 2/06/2014
* @Description: This class is used to code coverage of the viewOrderForDirectSubscriptionController class.
* History: 
*
*/
@isTest(seeAllData = TRUE)


public class viewOrderForDirectSubscriptionTest{
   /**
   *  To test viewOrderForDirectSubscriptionTest
   *  @name testViewOrderForDirect
   *  @param none
   *  @return none
   *  @throws na
   **/  
  
   public static testMethod void testViewOrderForDirect(){
   
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
        
         //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );   
        System.runAs(testUser) {
    
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert venAccount ;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        insert pack;
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subsVen;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
            postal.Name = 'Test Postal';
            postal.Building_Name__c = 'Test Building';
            postal.Street_Name__c = 'Test Street';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
        insert acc;
            
        Country__c countr = TestDataFactory.createCountry(1)[0];
            countr.Country_Name__c = 'Test Country';
        insert countr;
                
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Block_House_Number__c = 'Sample';
            addressRec.Address_Type__c= 'P';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Level_Number__c = 'AB';
            addressRec.Unit_Number__c = 'abcdef';
            addressRec.Country__c = countr.Id;
        insert addressRec;    
            
        Contact conList = TestDataFactory.createContact(1)[0];
            conList.LastName = 'Gonzales';
            conList.Address__c = addressRec.Id;
            conList.AccountId = acc.Id;
            conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList.Recipient_Indicator__c = true;
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        //billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Billing_Type__c= 'Full Prepaid';
        insert billAcc;
         
       Promotion__c promo = TestDataFactory.createPromotion(1)[0];
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            promo.Penalty_Charge_Override__c = 100;
       insert promo;     
            
       Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = conList.Id;
            orderRec.Subscriber_Charge__c = 15;
       insert orderRec;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
        insert cas;
            
         // Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);   
            for(Order_Line_Item__c item :orderline){ 
                item.Order__c = orderRec.Id;
                item.End_Date__c = date.today();
                item.Main_Package_ID__c = pack.Id;
                item.Case__c = cas.id;
                item.Vendor_Mailing_Agent__c = venAccount.Id;
                item.Vendor_Subscription_ID__c = subsVen.Id;
                item.New_Contract_Period__c =12;
                item.Is_Digital__c = true;
        }
        insert orderline;
        system.assertNotEquals(null, orderline);  
                        
    //Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
     List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c sub : subRecs) {
                sub.Zuora__Account__c = acc.Id;
                sub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.id;
                sub.Zuora__Status__c = 'Active';
                sub.Order_Number__c = orderRec.Id;
                sub.Suppress_Vendor_Start_Notice__c = 'false';
                sub.Supressed_Acknowledgement_Letter__c = 'false';
                sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                sub.Charity__c = 'false';
                sub.Order_Line_Item_Number__c = orderline[0].Id;
                sub.Promotion__c = promo.id;
                sub.Promotion_1__c = promo.id;
                sub.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
                sub.Zuora__CustomerAccount__c = billAcc.Id;
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Full Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Full Prepaid';
            
     Promotion_Gift__c promogift = TestDataFactory.createPromotionGift(1)[0];
     insert promogift;
    
    //Order_Line_Item_Gift__c oliGift = TestDataFactory.createItemGift(1)[0];
     //Order_Line_Item_Gift__c oliGift = TestDataFactory.createItemGift(1)[0];
        List<Order_Line_Item_Gift__c> oliGift = TestDataFactory.createItemGift(1);
        for(Order_Line_Item_Gift__c olig: oliGift){
        olig.Order_Line_Item__c = orderline[0].id;
        olig.Promotion_Gift__c = promogift.id;
        }   
     insert oliGift; 
     
        //PageReference pRef = Page.viewOrderForDirectSubscriptionRO;
        //Test.setCurrentPage(pRef);
        //ApexPages.currentPage().getParameters().put('Id', orderRec.Id);
        //viewOrderForDirectSubscriptionController controller = new viewOrderForDirectSubscriptionController();
        //controller.getGiftsToDisplay();
        
      Test.startTest();
      insert subRecs;    
      PageReference pRef = Page.viewOrderForDirectSubscriptionRO;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('Id', orderRec.Id);
      viewOrderForDirectSubscriptionController controller = new viewOrderForDirectSubscriptionController();
      //controller.currentlyClickedOrderLine = 'test';
      controller.updateOrderLine();
      Controller.getGiftsToDisplay(); 
      Test.stopTest();
      
     
      
      
          }
          }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
  
  }