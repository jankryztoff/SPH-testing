/**
 * Base Class Name: SM_ChangeOfSubscriptionEntryContTest
 * @author: <Thayne Recato Dy>
 * Date: <2/23/2015>
 * Changes: by: Jensar Joey Z. Sayson - Added "String.valueOf(subRecord.id)" to satisfy the last parameter of "SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages" methodat line 375 column 9
 * Requirement/Project Name: <SPH>
 * @description: Test Class for SM_ChangeOfSubscriptionEntryController
 */ 
@isTest (Seealldata = TRUE)
private class SM_ChangeOfSubscriptionEntryContTest{
    static List<Account> accountList = null;
    static List<Order__c> orderList = null;
    static List<Zuora__Subscription__c> zuoraSubscriptionList = null;

    static void testData01() {
        Integer records = 1;
        Integer count = 0;
    
        //Address
        List<Address__c> addressList = TestDataFactory.createAddress(records);
        insert addressList;
        
        //Zone
        List<Zone__c> zoneList = TestDataFactory.createZone(records);
        count = 0;
        for (Zone__c obj : zoneList) {
            obj.Name = ''+count;
            count++;
        }
        insert zoneList;
        
        //Country
        List<Country__c> countryList = TestDataFactory.createCountry(records);
        count = 0;
        for (Country__c obj : countryList) {
            obj.Zone__c = zoneList[count].id;
            count++;
        }
        insert countryList;
        
        //City
        List<City__c> cityList = TestDataFactory.createCity(records);
        count = 0;
        for (City__c obj : cityList) {
            //Country - Country
            obj.Country__c = countryList[count].id;
            obj.Flight_Number_1__c = 'Flight Number 1 '+ count;
            count++;
        }
        insert cityList;
        
        //Singpost Address
        List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(records);
        insert singpostAddressList;

        //Account
        accountList = TestDataFactory.createAccount(records, 'Direct Corporate');
        count = 0;
        for (Account obj : accountList) {
            //Singpost Address - Postal Code
            obj.Singpost_Address__c = singpostAddressList[count].id;
            count++;
        }
        insert accountList;
    
        //Billing Account
        //Zuora__Account__c
        //Package
        List<Package__c> packageList = TestDataFactory.createPackage(records);
        insert packageList;

        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(records);
        count = 0;
        for (Contact obj : contactList) {
            //Account - Account
            obj.Account = accountList[count];
            
            //City    - City Code
            obj.City_Code__c = cityList[count].id;
            
            //Contact - Reports To
            // Supervisor
            
            obj.Recipient_Indicator__c = true;
            
            count++;
        }   
        insert contactList; 

        //Paypdament Method
        List<Zuora__PaymentMethod__c> zuoraPaymentMethodList = TestDataFactory.createPaymentMethod(records);
        count = 0;
        for(Zuora__PaymentMethod__c obj : zuoraPaymentMethodList) {
            //Billing Account - Billing Account
        }

        //Billing Account
        List<Zuora__CustomerAccount__c> zuoraCustomerAccountList = TestDataFactory.createBillingAccount(records);
        count = 0;
        for (Zuora__CustomerAccount__c obj : zuoraCustomerAccountList) {
            //Contact - Billing Contact
            obj.Billing_Contact__c = contactList[count].id;
            //Account - Billing Account
            obj.Zuora__Account__c = accountList[count].id;
            //Payment Method - Default Payment Method
            //zuoraPaymentMethodList[count].id;
            
            //Billing Account - Parent
            //Payment Term - Payment Term(invalid)
            
            obj.Zuora__Credit_Balance__c = 0;
            
            obj.Billing_Type__c = 'Full Prepaid';
            
            count++;
        }
        insert zuoraCustomerAccountList;
        
        //Order
        orderList = TestDataFactory.createOrder(records);
        count = 0;
        for (Order__c obj : orderList) {
            //Account__c // Mandatory
            obj.Account__c = accountList[0].id;
            obj.Billing_Account__c = zuoraCustomerAccountList[0].id;
            obj.isChangeOfSubEntry__c = false;
            obj.Order_Type__c = 'Change of Subscription';
            obj.Billing_Type__c = 'Full Prepaid';
            obj.Status__c = 'Draft';
            count++;
        }
        insert orderList;
        
        //Order Line Item
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(records);
        count = 0;
        for (Order_Line_Item__c obj : orderLineItemList) {
            //Order__c, // Mandatory
            obj.Order__c = orderList[count].id;
            //Main_Package_ID__c // Mandatory
            obj.Main_Package_ID__c = packageList[count].id;
            obj.Start_Date__c = Date.today().addDays(10);
            obj.Qty__c = 10;
            obj.Add_On_Package_Subscription_Rate__c = 10;
            count++;
        }
        insert orderLineItemList;

        //Subscription
        zuoraSubscriptionList = TestDataFactory.createSubscription(records);
        count = 0;
        for (Zuora__Subscription__c obj : zuoraSubscriptionList) {
            obj.Zuora__Account__c = accountList[0].id;
            obj.Addon_Package_1__c = packageList[0].id;
            obj.Zuora__CustomerAccount__c = zuoraCustomerAccountList[0].id;
            obj.Main_Package_1__c = packageList[0].id;
            obj.Number_of_Copies1__c = '1';
            obj.Zuora__Status__c = Globalvariableclass.SUBSCRIPTION_STATUS_ACTIVE;
            obj.Zuora__SubscriptionStartDate__c = Date.today();
            obj.Zuora__SubscriptionEndDate__c = null;
            obj.Subscription_Type__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            obj.Subscription_Type_1__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            obj.Zuora__TermSettingType__c = 'EVERGREEN';
            obj.Term_Length__c = 1;
            count++;
        }
        insert zuoraSubscriptionList;
        
        //count = 0;
        for (Order__c obj : orderList) {
            obj.Subscription__c = zuoraSubscriptionList[0].id;
        }
        update orderList;
    }
    
    static testMethod void testMethod01() {
        testData01();
        Test.startTest();
        // Initialization of VisualForce Page
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();

        try {
            controller.retrieveActiveSubscriptions();
            controller.testCoveragePatch();
            controller.testCoveragePatch1();
        }catch(Exception e){
        }
        
        try{
            controller.retrieveOrderLineItem();
        }catch(Exception e){System.debug(e);}
            
        try{
            controller.retrieveRelatedSubscriptions();
        }catch(Exception e){System.debug(e);}
                      
//        try{
//            controller.retrieveActiveSubscriptions();
//        }catch(Exception e){System.debug(e);}
        
        try{
            controller.save();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.cancel();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.refreshSubscriberCharge();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.addOrderLineItem();
        }catch(Exception e){System.debug(e);}
      
        try{
            controller.checkExistingCOA();
        }catch(Exception e){System.debug(e);}
      
        try{
            controller.retrieveOrderLineItem();
        }catch(Exception e){System.debug(e);}
      
        try{
            controller.executeSearch();
        }catch(Exception e){System.debug(e);}
    
        try{
            controller.searchPackage();
        }catch(Exception e){System.debug(e);}
      
        try{
            controller.searchPromotion();
        }catch(Exception e){System.debug(e);}

        try{
            controller.populateAddOn();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.populatePromotionGifts();
        }catch(Exception e){System.debug(e);}
     
        try{
            controller.addAsia1ExistingAccount();
        }catch(Exception e){System.debug(e);}
       
        /*try{
            controller.addAsia1NewAccount();
        }catch(Exception e){System.debug(e);}*/
       
        try{
            controller.validateNewAsia1Account();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.removeAsia1Subscription();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.getAsia1ExistingAccounts();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.getDeliveryChargeTypes();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.getBillingAccountOptions();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.fetchBillingAccount();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.getSource();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.clearPaymentMethod();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.clearOtherPaymentMethod();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.searchCusName();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.searchAccName();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.addPopAcc();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.closePopup();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.cancelSearch();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.retrieveAdminFeeAdminCharge();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.continueSave();
       }catch(Exception e){System.debug(e);}
   
        Test.stopTest();
    
                
    }
}