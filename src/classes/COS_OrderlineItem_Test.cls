/**
* Class Name: COS_OrderlineItem_Test
* @Description: This class is used for the code coverage of the COS_OrderlineItem class.
*/
@isTest (SeeAllData = true)
private class COS_OrderlineItem_Test
{

/**
* method to test the whole class 
* @name COS_OrderlineItemTest
* @param none
* @return none
*/
    static testMethod void COS_OrderlineItemTest() {
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
     Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
          //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Grace Period';
            packagee.Billing_Type__c = 'Full Prepaid' ;
            packagee.Package_Sub_Type__c = 'Single';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
        }
        insert packages;
        
         List<Contact> contactList = TestDataFactory.createContact(1);
        count = 0;
        for(Contact obj : contactList ) {
            obj.AccountId = accounts[count].id;
            obj.Recipient_Indicator__c = True;
            count++;
        }
        insert contactList;   
        
         //zqu__ZProduct__c
        List<zqu__ZProduct__c> products = TestDataFactory.createZProduct(1);
        insert products; 
        
         //Product_Rate_Plan__c
        List<zqu__ProductRatePlan__c> productPlans = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c productPlan: productPlans){
            productPlan.RatePlanType__c = 'Proration';
            productPlan.zqu__ZProduct__c = products[0].id;
        }
        insert productPlans;
         
        //Product_Family__c
        Product_Family__c productFamily = new Product_Family__c();
        productFamily.Product_Family__c = 'Sample Product Family';
        insert productFamily;
        
        
      //Postal__c
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;
        
        //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id; 
            ord.Recipient_Contact__c = contactList[count].id;
        }
        insert orders;
        
        //Zuora__CustomerAccount__c
        List<Zuora__CustomerAccount__c> zuoraCustomerAccount = TestDataFactory.createBillingAccount(1);
        count = 0;
        for(Zuora__CustomerAccount__c obj : zuoraCustomerAccount) {
            obj.Zuora__Account__c = accounts[count].id;
            obj.Billing_Contact__c = contactList[0].id;
            count++;
        }
        insert zuoraCustomerAccount;
        
         //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            
        }        
        insert orderLineItems;
        
        //Promotion__c
        List<Promotion__c> promotions = TestDataFactory.createPromotion(1);
        for(Promotion__c promotion: promotions){
            promotion.Contract_Period__c = '36';
        }
        insert promotions;  
        
         // Zuora__Subscription__c   
        List<Zuora__Subscription__c> zuoraSubscriptionList = TestDataFactory.createSubscription(1);
        count = 0;
        for (Zuora__Subscription__c obj : zuoraSubscriptionList ) {
            
            obj.Zuora__CustomerAccount__c = zuoraCustomerAccount[count].id;
            obj.Zuora__Account__c = accounts[count].id;
            obj.Contact__c = contactList[count].id;
            obj.Penalty_Charge_1__c = 100.00;
            obj.Frequency_1__c = 'Fri - Sun';
            obj.Zuora__SubscriptionStartDate__c = Date.today();
            obj.Zuora__SubscriptionEndDate__c = Date.today().addDays(15); 
            obj.Zuora__TermSettingType__c = 'EVERGREEN';
            obj.Asia1_Creation_Mode_1__c = 'Bulk';
            obj.Term_is_discussed__c = True;
            obj.Generate_Invoice__c = True;
            obj.Zuora__AutoRenew__c = True;
            obj.Promotion_Contract_Period_1__c = 1;
            obj.PO_Number__c = 'TEST';
            obj.Delivered_By_1__c = 'Vendor';
            obj.New_Contract_Period_1__c = 2;
            obj.Promotion_1__c = promotions[count].id;
            obj.Main_Package_1__c = packages[count].id;
            obj.Charity_1__c = True;
            obj.Number_of_Copies__c = 7;           
            obj.Suppress_Grace_Allocation__c = True;
            obj.Supressed_Acknowledgement_Letter_1__c = True;
            obj.Order_Line_Item_Number__c = orderLineItems[count].id;
            obj.Order_Number_1__c = orders[count].id;
            //obj.Order_Line_Item_Number_1__c = orderLineItems[count].id;          
            obj.Recipient_Contact__c = contactList[0].id; //contact
            count++;
       }

        insert zuoraSubscriptionList;
         COS_OrderlineItem co = new COS_OrderlineItem();
     
    Test.StartTest();
    system.assertEquals(1,zuoraSubscriptionList.size());
    COS_OrderlineItem.setOrderLineItemFields(zuoraSubscriptionList[0].id);     
    
    Test.StopTest();      
        
    
          }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
            

}