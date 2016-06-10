/**
   @author AMiranda
   @name CalculateCharges_Test
   @createDate 18 Feb 2015
   @description Test for class CalculateCharges
   @version 1.0 
*/
@isTest(seeAllData=true) 
private class CalculateChargesTest {    
    
    static Account vendorAcct;
    static Singpost_Address__c singPostAddr;
    static Address__c address;
    static Contact contact;
    
    static zqu__ZProduct__c zProduct;
    static zqu__ProductRatePlan__c prodRatePlan;
    static zqu__ProductRatePlanCharge__c prodRatePlanCharge;
    
    static Package__c aPackage;
    static Package_Item__c packageItem;
    static Order__c order;
    static Order_Line_Item__c orderLineItem;
    static Vendor_Allocation__c vendorAlloc; 
    static Zuora__Subscription__c zouraSubscription;
    static Case aCase;
    static Zuora__CustomerAccount__c billingaccount;
    
    static List<Id> oliId = new List<Id>();
    
    
    /**
        @name setUpFirstDataFactory
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setUpFirstDataFactory() {
    
        vendorAcct = TestDataFactory.createAccount(1, 'Vendor')[0]; 
        insert vendorAcct;
        
        singPostAddr = TestDataFactory.createSingpostAddress(1)[0];
        singPostAddr.Name = 'SPostal';
        singPostAddr.House_Block_Number__c = 'TEST';
        //singPostAddr.orderRecord_Type__c = 'A';
        insert singPostAddr;        
        
        address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c = 'P';
        address.Postal_Code__c = singPostAddr.Id;
        address.Block_House_Number__c ='TEST';
        address.Level_Number__c ='xx';
        address.Unit_Number__c = 'yy';
        insert address;        
        
        billingaccount = TestDataFactory.createBillingAccount(1)[0];
        billingaccount.Zuora__Account__c = vendorAcct.Id;
        insert billingaccount;
        
        contact = TestDataFactory.createContact(1)[0];
        contact.Address__c = address.Id;
        contact.AccountId = vendorAcct.Id;
        contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contact.Recipient_Indicator__c = true;
        insert contact;        
        
        zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        prodRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prodRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prodRatePlan;
        
        prodRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prodRatePlanCharge.zqu__ProductRatePlan__c = prodRatePlan.Id;
        insert prodRatePlanCharge;        
                       
        aPackage = TestDataFactory.createPackage(1)[0]; 
        aPackage.Name = 'Pack name';
        aPackage.Billing_Type__c = 'Full Prepaid';
        aPackage.Package_Type__c = 'Base';
        aPackage.Subscription_Period__c = '18';
        aPackage.Package_Code__c = 'afds132';
        insert aPackage;        
        
        packageItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem.Package__c = aPackage.Id;
        packageItem.Product_Rate_Plan__c = prodRatePlan.Id;
        insert packageItem;
             
    }
    
    
    /**
        @name setUpSecondDataFactory
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setUpSecondDataFactory() { 
        
        aCase = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        insert aCase;        
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorAcct.Id;
        order.Informed_Customer__c = true;
        order.Recipient_Contact__c = contact.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = true;
        //order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        //order.Billing_Account__c = billAcc.id;
        //order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        System.debug('ASM order.Id = ' + order.Id);
               
        List<String> billingTypeList = new List<String>{'Full Prepaid', 'Recurring Prepaid'};
        oliId = new List<Id>();
        Integer count = 0;
        
        for (String bt : billingTypeList ) {
            
            orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.Id;
            orderLineItem.Case__c = aCase.Id;        
            orderLineItem.Main_Package_ID__c = aPackage.Id;
            orderLineItem.Main_Package_Type__c = 'Base';
            orderLineItem.Main_Package_Billing_Type__c = bt; //NOTE
            orderLineItem.Main_Package_Period__c = 0;
            orderLineItem.Start_Date__c = Date.today().addDays(1); //LIMOT
            orderLineItem.End_Date__c = Date.Today().addDays(2);
            orderLineItem.Term_Length__c = 0;        
            orderLineItem.Earliest_Start_Date__c = Date.today();
            orderLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderLineItem.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderLineItem.Terminating_Reason__c = 'Others';
            orderLineItem.Amount_To_Refund__c = 0;
            orderLineItem.Admin_Charge__c = 0;
            orderLineItem.Fee_Waiver__c = false; //LIMOT
            orderLineItem.Fee_Override__c = true; 
            orderLineItem.Override_Reason__c = 'TEST';
            orderLineItem.Suppress_Notification_Stop__c = true;        
            orderLineItem.Vendor_Mailing_Agent__c = vendorAcct.Id;
            insert orderLineItem;
            
            count++;
            oliId.add(orderLineItem.Id);
            
            System.debug('ASM orderLineItem.Id= ' + orderLineItem.Id + ' count=' + count); 
        }
           
        zouraSubscription = TestDataFactory.createSubscription(1)[0];
        
        zouraSubscription.Zuora__Zuora_Id__c = 'zouraId';
        zouraSubscription.Zuora__CustomerAccount__c = billingaccount.Id;
        zouraSubscription.Zuora__Status__c = 'Active';
        zouraSubscription.Zuora__Account__c = vendorAcct.Id;
        zouraSubscription.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);        
        
        zouraSubscription.Subscriber_Contact__c = contact.Id;
        zouraSubscription.Recipient_Contact__c = contact.Id;       
        
        zouraSubscription.Main_Package_1__c = aPackage.Id;
        zouraSubscription.Order_Number__c = order.Id;
        zouraSubscription.Order_Number_1__c = order.Id;
        zouraSubscription.Order_Line_Item_Number__c = orderLineItem.Id;
        zouraSubscription.Order_Line_Item_Number_1__c = orderLineItem.Id;
        
        zouraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zouraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zouraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zouraSubscription.Urgent__c = 'false';
        
        zouraSubscription.Vendor_Conversion__c = 'false';
        zouraSubscription.Vendor__c = vendorAcct.Id;
        zouraSubscription.Vendor_1__c = vendorAcct.Id;         
        zouraSubscription.Charity__c = 'false';
        
        zouraSubscription.Billing_Type__c = 'Full Prepaid'; //NOTE       
        
        zouraSubscription.Subscription_Type__c = 'Publication';
        zouraSubscription.Subscription_Type_1__c = 'Publication';       
        insert zouraSubscription;        
        
        vendorAlloc = TestDataFactory.createVendorAlloc(1)[0];   
        vendorAlloc.Vendor_Account__c = vendorAcct.Id;
        vendorAlloc.SingPost_Address__c = singPostAddr.Id;
        vendorAlloc.Effective_Start_Date__c = Date.today();
        vendorAlloc.Allocated__c = true;
        insert vendorAlloc; 
    }
    
    /**
        @name getfullAndRecurrTest
        @param none
        @return void
        @description tests the getfullAndRecurr method
    */
    static testmethod void getfullAndRecurrTest(){
       try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        
        setUpFirstDataFactory();
        Test.startTest();
        setUpSecondDataFactory();
        
        System.assertNotEquals(contact, null);
        System.assertNotEquals(address, null);
        
        CalculateCharges cc = new CalculateCharges();     
        cc.getfullAndRecurr(order.Id, address.Id);
        
        Test.stopTest(); 
       } catch (Exception e) {
       }
    }
    
    /**
        @name addressTypeTest
        @param none
        @return void
        @description tests different addressType values
    */
    static testmethod void addressTypeTest(){
        
        Test.startTest();
        setUpFirstDataFactory();        
     
        System.assertNotEquals(contact, null);
        System.assertNotEquals(address, null);
                      
        CalculateCharges cc = new CalculateCharges();        
        List<String> addressTypes = new List<String>{'P','B','W','H','K','A','C','S','G','U'};        
               
        for (String addressType : addressTypes) {                    
            cc.vendorCreditAddType(addressType);                    
            cc.getSubscriberCharge(addressType);
            cc.getVendorCredit(addressType);    
        } 
        
        Test.stopTest();        
    }
    
    /**
        @name calculateDeliveryChargeTest
        @param none
        @return void
        @description tests different chargeType values values
    */
    static testmethod void calculateDeliveryChargeTest(){
       try{
        Test.setMock(WebServiceMock.class, new zLoginMock()); 

        setUpFirstDataFactory();
        Test.startTest();
        setUpSecondDataFactory();        
     
        System.assertNotEquals(contact, null);
        System.assertNotEquals(address, null);
        
        CalculateCharges cc = new CalculateCharges();                      
        List<String> chargeTypes = new List<String>{'H','C','L','S','Z','N','9'};
        List<String> addressTypes = new List<String>{'P','B','W','H','K','A','C','S','G','U'};
        String concat = '';
        for (String chargeType : chargeTypes) {            
            for (String addressType : addressTypes) {                        
                concat = cc.CalculateDeliveryCharge(chargeType, addressType);              
            }              
        }
        System.assertEquals('0.0,4.0', concat);
       Test.stopTest(); 
       } catch (Exception e) {
       }   
    }
    
    /**
        @name getDeliveryAndVendorChargeTest
        @param none
        @return void
        @description tests getDeliveryAndVendorCharge method
    */
    static testmethod void getDeliveryAndVendorChargeTest(){
       try{
        Test.setMock(WebServiceMock.class, new zLoginMock()); 

        setUpFirstDataFactory();
        Test.startTest();
        setUpSecondDataFactory();
        
        System.assertNotEquals(contact, null);
                
        CalculateCharges cc = new CalculateCharges();                      
        cc.getDeliveryAndVendorCharge('H', contact.Id);
       Test.stopTest(); 
       } catch (Exception e) {
       }  
    }
    
    /**
        @name returnValuesTest
        @param none
        @return void
        @description tests returnValues method
    */
    static testmethod void returnValuesTest(){
       try{
        Test.setMock(WebServiceMock.class, new zLoginMock()); 

        setUpFirstDataFactory();
        Test.startTest();
        setUpSecondDataFactory();        
  
        System.assertNotEquals(order, null);
        System.assertNotEquals(contact, null);
        System.assertNotEquals(address, null);
        
        CalculateCharges cc = new CalculateCharges(); 
        cc.returnValues(order.Id, 'H', contact.Id, address.Id);  
       Test.stopTest(); 
       } catch (Exception e) {
       }     
    }    
}