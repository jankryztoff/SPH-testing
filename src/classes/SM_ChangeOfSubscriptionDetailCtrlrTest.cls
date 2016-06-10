@IsTest(SeeAllData=true) 
private class SM_ChangeOfSubscriptionDetailCtrlrTest {

    
    static Account vendorAcct;
    static Singpost_Address__c singPostAddr;
    static Address__c address;
    static Contact contact;
    static Contact recCon;
    
    static zqu__ZProduct__c zProduct;
    static zqu__ProductRatePlan__c prodRatePlan;
    static zqu__ProductRatePlanCharge__c prodRatePlanCharge;
    
    static Package__c aPackage;
    static Package_Item__c packageItem;
    static Order__c order;
    static Order_Line_Item__c orderLineItem;
    static Order_Line_Item_Gift__c orderLineItemGift;
    static Promotion_Gift__c promotionGift;
    
    static Service_Access_Flag__c saf;
    static Asia1__c asia1;
    static Asia1_Subscription__c asia1Subscription;
    
    static Vendor_Allocation__c vendorAlloc; 
    static Zuora__Subscription__c zouraSubscription;
    static Zuora__Subscription__c zouraSubscription2;
    static Case aCase;
    
    private static Zuora__CustomerAccount__c zCustAcc;
    
    static List<Id> oliId;
    
    static void setVendorAcct() {
        vendorAcct = TestDataFactory.createAccount(1, 'Vendor')[0]; 
        insert vendorAcct;
    }
    
    static void setSignPostAddr() {
        singPostAddr = TestDataFactory.createSingpostAddress(1)[0];
        singPostAddr.Name = 'SPostal';        
        singPostAddr.Address_Type__c = 'A';
        singPostAddr.House_Block_Number__c = 'TEST';
        insert singPostAddr;  
    }
    
    static void setAddress() {
        address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c = 'P';
        address.Postal_Code__c = singPostAddr.Id;
        address.Block_House_Number__c ='TEST';
        address.Level_Number__c ='xx';
        address.Unit_Number__c = 'yy';
        insert address;
    }
    
    static void setContact() {
        contact = TestDataFactory.createContact(1)[0];        
        contact.AccountId = vendorAcct.Id;
        contact.Address__c = address.Id;
        contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contact.Recipient_Indicator__c = true;
        contact.Recipient_Number__c = 12345;
        //contact.Recipient_Contact__c = 54321;
        
        insert contact;
    }
    
    static void setZProduct() {
        zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
    }
    
    static void setProductRatePlan() {
        prodRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prodRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prodRatePlan;
    }
    
    static void setProdRatePlancharge() {
        prodRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prodRatePlanCharge.zqu__ProductRatePlan__c = prodRatePlan.Id;
        insert prodRatePlanCharge;
    }
    
    static void setPackage() {
        aPackage = TestDataFactory.createPackage(1)[0]; 
        aPackage.Name = 'Pack name';
        aPackage.Billing_Type__c = 'Full Prepaid';
        aPackage.Package_Type__c = 'Base';
        aPackage.Subscription_Period__c = '18';
        aPackage.Package_Code__c = 'afds132';
        insert aPackage; 
    }
    
    static void setPackageItem() {
        packageItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem.Package__c = aPackage.Id;
        packageItem.Product_Rate_Plan__c = prodRatePlan.Id;
        insert packageItem;  
    }
    
    static void setCase() {
        aCase = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        aCase.Account = vendorAcct;
        //insert aCase;
    }
    
    static void setOrder() {
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorAcct.Id;        
        order.Recipient_Contact__c = contact.Id;        
        order.Order_Type__c = 'Change of Subscription Package';
        order.Status__c = 'Draft';        
        order.Informed_Customer__c = true;        
        order.Eligible_for_Retention__c = true;
        order.Payment_Mode__c = 'Credit Card';        
        //order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        //order.Billing_Account__c = billAcc.Id;
        //order.Billing_Contact__c = contact.Id;
        
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';     
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;        
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 200.00;
        order.Billing_Type__c = 'Full Prepaid';
        
        //order.Recipient_Contact__r.Id = contact.id;
        
        insert order;
        
        System.debug('ASM order.Id= ' + order.Id);
        Order__c orderDB = [Select Id From Order__c Where Order_Type__c= 'Change of Subscription Package' And Status__c= 'Draft' And Account__c= :vendorAcct.Id]; //Or Id= :order.Id
        System.assertEquals(orderDB.Id, order.Id);
        System.debug('ASM orderDB.Id = ' + orderDB.Id);
    }
    
    static void setOrderLineItem() {
        orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem.Order__c = order.Id;
        orderLineItem.Case__c = aCase.Id; 
        orderLineItem.Vendor_Mailing_Agent__c = vendorAcct.Id;
        
        orderLineItem.Main_Package_ID__c = aPackage.Id;
        orderLineItem.Main_Package_Type__c = 'Base';
        orderLineItem.Main_Package_Period__c = 0;
        //orderLineItem.Main_Package_Billing_Type__c = bt; //NOTE        
        
        orderLineItem.Start_Date__c = Date.today().addDays(1);
        orderLineItem.End_Date__c = Date.Today().addDays(2);                
        orderLineItem.Earliest_Start_Date__c = Date.today();
        orderLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderLineItem.Stop_Request_Date__c =  Date.Today().addDays(4);
        
        orderLineItem.Term_Length__c = 0;
        orderLineItem.Terminating_Reason__c = 'Others';
        orderLineItem.Amount_To_Refund__c = 0;
        orderLineItem.Admin_Charge__c = 0;
        orderLineItem.Fee_Waiver__c = true;
        orderLineItem.Fee_Override__c = false;
        orderLineItem.Override_Reason__c = 'TEST';
        orderLineItem.Suppress_Notification_Stop__c = TRUE; 
        
        orderLineItem.Is_Digital__c = true;
        insert orderLineItem;
    }
    
    static void setOrderLineItem2() {
        orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem.Order__c = order.Id;
        //orderLineItem.Case__c = aCase.Id; 
        orderLineItem.Vendor_Mailing_Agent__c = vendorAcct.Id;
        
        orderLineItem.Main_Package_ID__c = aPackage.Id;
        orderLineItem.Main_Package_Type__c = 'Base';
        orderLineItem.Main_Package_Period__c = 0;
        //orderLineItem.Main_Package_Billing_Type__c = bt; //NOTE        
        
        orderLineItem.Start_Date__c = Date.today().addDays(1);
        orderLineItem.End_Date__c = Date.Today().addDays(2);                
        orderLineItem.Earliest_Start_Date__c = Date.today();
        orderLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderLineItem.Stop_Request_Date__c =  Date.Today().addDays(4);
        
        orderLineItem.Term_Length__c = 0;
        orderLineItem.Terminating_Reason__c = 'Others';
        orderLineItem.Amount_To_Refund__c = 0;
        orderLineItem.Admin_Charge__c = 0;
        orderLineItem.Fee_Waiver__c = true;
        orderLineItem.Fee_Override__c = false;
        orderLineItem.Override_Reason__c = 'TEST';
        orderLineItem.Suppress_Notification_Stop__c = TRUE; 
        
        orderLineItem.Is_Digital__c = true;
        insert orderLineItem;
    }
    
    static void setPromotionGift() {
        promotionGift = new Promotion_Gift__c();
        insert promotionGift;
    }
    
    static void setOrderLineItemGift() {
        /*
        orderLineItemGift = TestDataFactory.createItemGift(1)[0];
        orderLineItemGift.Order_Line_Item__c = orderLineItem.Id;
        orderLineItemGift.Promotion_Gift__c = promotionGift.Id;
        insert orderLineItemGift;
        */ 
    }
    
    static void setZuoCustAcc() {
        zCustAcc = TestDataFactory.createBillingAccount(1)[0];
        zCustAcc.Zuora__Account__c = vendorAcct.Id;      
        zCustAcc.Zuora__DefaultPaymentMethod__c = 'Credit Card'; 
        zCustAcc.Zuora__Credit_Balance__c = 1000;
        //zCustAcc.
        insert zCustAcc;
    }
    
    static void setZuoSub() {
        zouraSubscription = TestDataFactory.createSubscription(1)[0];        
        zouraSubscription.Zuora__Zuora_Id__c = 'zouraId';
        zouraSubscription.Zuora__Status__c = 'Active';
        zouraSubscription.Zuora__Account__c = vendorAcct.Id;
        zouraSubscription.Zuora__SubscriptionStartDate__c = Date.today();
        zouraSubscription.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);        
        
        zouraSubscription.Subscriber_Contact__c = contact.Id;
        zouraSubscription.Recipient_Contact__c = contact.Id;       
        
        zouraSubscription.Zuora__CustomerAccount__c = zCustAcc.Id;
        zouraSubscription.Main_Package_1__c = aPackage.Id;
        zouraSubscription.Order_Number__c = order.Id;
        zouraSubscription.Order_Number_1__c = order.Id;
        zouraSubscription.Order_Line_Item_Number__c = orderLineItem.Id;
        //zouraSubscription.Order_Line_Item_Number__c = 'orderLineItemNo';
        zouraSubscription.Order_Line_Item_Number_1__c = orderLineItem.Id;
        
        zouraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zouraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zouraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zouraSubscription.Urgent__c = 'false';
        
        zouraSubscription.Vendor_Conversion__c = 'false';
        //zouraSubscription.Vendor__c = 'vendorC_test';
        zouraSubscription.Vendor__c = vendorAcct.Id;
        zouraSubscription.Vendor_1__c = vendorAcct.Id;         
        zouraSubscription.Charity__c = 'false';
        
        zouraSubscription.Billing_Type__c = 'Full Prepaid'; //NOTE       
        zouraSubscription.Subscription_Type__c = 'Publication';
        zouraSubscription.Subscription_Type_1__c = 'Publication'; 
        zouraSubscription.Number_of_Copies__c = 100;    
        zouraSubscription.Number_of_Copies1__c = '120';
        zouraSubscription.Qty__c = 7;
        zouraSubscription.Qty1__c = '7';
        
        
        insert zouraSubscription;
        System.debug('zouraSubscription1: >>> ' + zouraSubscription);
        order.Subscription__c = zouraSubscription.Id; //NOTE
        //order.Billing_Account__c
        update order;
    }
    
    static void setZuoSub2() {
        System.debug('start zuosub2 1');
        zouraSubscription2 = TestDataFactory.createSubscription(1)[0];        
        zouraSubscription2.Zuora__Zuora_Id__c = 'zouraId2';
        zouraSubscription2.Zuora__Status__c = 'Active';
        zouraSubscription2.Zuora__Account__c = vendorAcct.Id;
        zouraSubscription2.Zuora__SubscriptionStartDate__c = Date.today();
        zouraSubscription2.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);        
        
        zouraSubscription2.Subscriber_Contact__c = contact.Id;
        zouraSubscription2.Recipient_Contact__c = contact.Id;       
        
        zouraSubscription2.Zuora__CustomerAccount__c = zCustAcc.Id;
        zouraSubscription2.Zuora__CustomerAccount__c = 'a0MN0000000m1IhMAI';
        zouraSubscription2.Main_Package_1__c = aPackage.Id;
        zouraSubscription2.Order_Number__c = order.Id;
        zouraSubscription2.Order_Number_1__c = order.Id;
        zouraSubscription2.Order_Line_Item_Number__c = orderLineItem.Id;
        zouraSubscription.Order_Line_Item_Number__c = 'orderLineItemNo';
        zouraSubscription2.Order_Line_Item_Number_1__c = orderLineItem.Id;
        
        zouraSubscription2.Suppress_Vendor_Start_Notice__c = 'false';
        zouraSubscription2.Supressed_Acknowledgement_Letter__c = 'false';
        zouraSubscription2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zouraSubscription2.Urgent__c = 'false';
        
        zouraSubscription2.Vendor_Conversion__c = 'false';
        zouraSubscription.Vendor__c = 'vendorC_test';
        zouraSubscription2.Vendor__c = vendorAcct.Id;
        zouraSubscription2.Vendor_1__c = vendorAcct.Id;         
        zouraSubscription2.Charity__c = 'false';
        
        zouraSubscription2.Billing_Type__c = 'Full Prepaid'; //NOTE       
        zouraSubscription2.Subscription_Type__c = 'Publication';
        zouraSubscription2.Subscription_Type_1__c = 'Publication'; 
        zouraSubscription2.Number_of_Copies__c = 100;    
        zouraSubscription2.Number_of_Copies1__c = '120';
        
        zouraSubscription2.Qty__c = 7;
        zouraSubscription2.Qty1__c = '7';
        System.debug('start zuosub2 2');
        
        insert zouraSubscription2;
        System.debug('zouraSubscription2: >>> ' + zouraSubscription2);
        //order.Subscription__c = zouraSubscription.Id; //NOTE
        //order.Billing_Account__c
        //update order;
    }
    
    
    
    
    
    static void setServiceAccessFlag() {
        saf = TestDataFactory.createServiceAccessFlag(1)[0];
        saf.Flag_Code__c = 'SAFCode';
        saf.Flag_Description__c = 'SAFDescription';
        insert saf; 
    }
    
    static void setAsiaOne() {
        asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = contact.Id;       
        asia1.Display_Name__c = 'Test';
        asia1.User_ID_LDAP_ID__c = 'test@email.com';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';        
        insert asia1;
    }
    
    static void setAsiaOneSub() {
        asia1Subscription = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Subscription.Asia1__c = asia1.Id;               
        asia1Subscription.Order_Line_Item__c = orderLineItem.Id;
        asia1Subscription.Subscription__c = zouraSubscription.Id; 
        asia1Subscription.Service_Access_Flag__c = saf.Id;
        asia1Subscription.Status__c = 'Enabled';
        insert asia1Subscription;
    }
    
    static void setUpData() {
                
        setVendorAcct();
        setSignPostAddr();
        setAddress();
        setContact();
        setZProduct();
        setProductRatePlan();
        setProdRatePlancharge();
        setPackage();
        setPackageItem();
        setCase();
        setOrder();
        setOrderLineItem();
        setPromotionGift();
        setZuoCustAcc();
        setZuoSub();        
        setServiceAccessFlag();
        setAsiaOne();
        setAsiaOneSub();
                
        /*
        vendorAlloc = TestDataFactory.createVendorAlloc(1)[0];   
        vendorAlloc.Vendor_Account__c = vendorAcct.Id;
        vendorAlloc.SingPost_Address__c = singPostAddr.Id;
        vendorAlloc.Effective_Start_Date__c = Date.today();
        insert vendorAlloc;
        */
    }
    
    static testMethod void coverAllData(){
        System.debug('coverAllData() start');
        Test.startTest();
        SM_ChangeOfSubscriptionDetailController sm_cosdc = new SM_ChangeOfSubscriptionDetailController();
        
        sm_cosdc.selectedOrderLineItem = 'churva';
/*        
        public list<Order_Line_Item__c> orderLineItemList { get; set; }
        public Order__c thisOrder { get; set; }
        public Order_Line_Item__c orderLineItem { get; set; }
        public Order_Line_Item__c oli { get; set; }
        public list<Order_Line_Item_Gift__c> promotionGifts { get; set; }
        public list<Asia1Wrapper> asia1Subscriptions { get; set; }
        public date dtlDate { get; set; }
        public transient boolean isFromPromotion { get; set; }
        public transient boolean isDigital { get; set; }
        public Zuora__Subscription__c sub { get; set;}
        public SubscriptionWrapper selectedSubscription { get; set; }
        public list<SubscriptionWrapper> relatedSubscriptionList { get; set; }
        public string selectedPackageId { get; set; }
        public Zuora__Subscription__c zs;
        //added 10242014
        public Map<Id, Date> mapId_StartDate = new Map<Id, Date>();
*/        
        Test.stopTest();
        System.debug('coverAllData() end');
    }
    
    static testMethod void retrieveOrderTest(){
        System.debug('retrieveOrderTest() start');
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            setUpData();            
            Test.startTest();
            
            PageReference pRef = new Pagereference('/apex/SM_ChangeOfSubscriptionDetail?id=' + order.Id + '&accountId=' + vendorAcct.Id);
            Test.setCurrentPage(pRef);
            
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            csdc.retrieveOrder();
            csdc.void();
            csdc.edit();   
            
            Test.stopTest();   
            System.debug('retrieveOrderTest() end');
        //} catch(Zuora.zRemoteException e) {
        } catch(Exception e) {
            System.debug('zRemoteException: ' + e);            
        }
    }
    
       
    static testMethod void submitTest(){
        //static void submitTest(){
        System.debug('submitTest() start');
        //try {
            //Test.setMock(WebServiceMock.class, new MockHttpResponseGenerator());
            Test.setMock(WebServiceMock.class, new zLoginMock());
            //setUpData();
        
            setVendorAcct();
            setPackage();
            setSignPostAddr();
            setAddress();
            setContact();
            System.debug('recCon.Recipient_Contact__c: ' + contact.Recipient_Contact__c);
            setCase();
            insert aCase;            
            setOrder();
            setOrderLineItem();
            
            System.debug('contact: >>> ' + contact);
            System.debug('order: >>> ' + order);
            
            Test.startTest();
            
            PageReference pRef = new Pagereference('/apex/SM_ChangeOfSubscriptionDetail?id=' + order.Id + '&accountId=' + vendorAcct.Id);
            Test.setCurrentPage(pRef);
                
            SM_ChangeOfSubscriptionDetailController csdc;        
            try {
                System.debug('submitTest() 1');
                csdc = new SM_ChangeOfSubscriptionDetailController(); 
                csdc.thisOrder = order;
                csdc.orderLineItem = orderLineItem;  
                System.debug('order.Recipient_Contact__r.Id: >>> ' + order.Recipient_Contact__r.Id);            
                System.debug('order.Recipient_Contact__c: >>> ' + order.Recipient_Contact__c);
                System.debug('csdc.thisOrder: >>> ' + csdc.thisOrder);
                System.debug('csdc.thisOrder.Recipient_Contact__r.Id: >>> ' + csdc.thisOrder.Recipient_Contact__r.Id);
                System.debug('csdc.thisOrder.Recipient_Contact__c: >>> ' + order.Recipient_Contact__c);
                System.debug('submitTest() 2');
            } catch(Zuora.zRemoteException e) {
                System.debug('Error1: ' + e);
            }                  
            System.debug('submitTest() 3');
            csdc.submit();         
            System.debug('submitTest() 4');
            
            Test.stopTest();      
            System.debug('submitTest() end');            
        //} catch(Zuora.zRemoteException e) {    
        //} catch(Exception e) {
        //    System.debug('zRemoteException: ' + e);
        //}
    }
    
    
    static testMethod void getUserIdDisableSvcInAsia1Test(){
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            System.debug('getUserIdDisableSvcInAsia1Test() start');
            setUpData();
            
            Test.startTest();
            
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController(); 
            csdc.getUserIdDisableSvcInAsia1(order.Subscription__c);        
                        
            Test.stopTest();       
            System.debug('getUserIdDisableSvcInAsia1Test() end');
        //} catch(Zuora.zRemoteException e) {
        } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
    }
    
    /*
    static testMethod void retrieveOrderLineItemsTest() {
        System.debug('retrieveOrderLineItemsTest() start');
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            setUpData();
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            csdc.retrieveOrderLineItems();            
            
        } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
        System.debug('retrieveOrderLineItemsTest() end');
    }*/
    
    
    static testMethod void retrieveOrderLineItemTest() {
        System.debug('retrieveOrderLineItemTest() start');
        try {
            //Test.setMock(WebServiceMock.class, new MockHttpResponseGenerator());
            Test.setMock(WebServiceMock.class, new zLoginMock());
            setUpData();
            
            Test.startTest();
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            csdc.retrieveOrderLineItem();
            Test.stopTest();
            
        } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
        System.debug('retrieveOrderLineItemTest() end');
    }
    
    static testMethod void retrieveRelatedSubscriptionsTest() {
        System.debug('retrieveRelatedSubscriptionsTest() start');
        try {
            //Test.setMock(WebServiceMock.class, new MockHttpResponseGenerator());
            Test.setMock(WebServiceMock.class, new zLoginMock());
            setUpData();
            /*
            setVendorAcct();
            setSignPostAddr();
            setAddress();
            setContact();
            setZProduct();
            setProductRatePlan();
            setProdRatePlancharge();
            setPackage();
            setPackageItem();
            //setCase();
            setOrder();
            setOrderLineItem2();
            setPromotionGift();
            setZuoCustAcc();
            setZuoSub();
            //setServiceAccessFlag();
            //setAsiaOne();
            //setAsiaOneSub();
            */
            System.debug('after zuosub1 1');
            //setZuoSub2();
            System.debug('after zuosub2 1');
            
            Test.startTest();
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            csdc.thisOrder = order;
            System.debug('after zuosub2 2');
            System.debug('zs: >>> ' + [select Id, Recipient_Contact__c, Cost_Center__c, Number_of_Copies__c,
                                        Main_Package_1__c, Zuora__SubscriptionStartDate__c, 
                                        Zuora__SubscriptionEndDate__c, Order_Number_1__c, 
                                        Delivery_Charge_Type_1__c, Zuora__CustomerAccount__r.Name, 
                                        Zuora__CustomerAccount__r.Payment_Mode__c, Main_Package_1__r.Name  
                                        from Zuora__Subscription__c where Id = : csdc.thisOrder.Subscription__c]);
            
            Zuora__Subscription__c zs;
            zs = [select Id, Recipient_Contact__c, Cost_Center__c, Number_of_Copies__c,
                    Main_Package_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                    Order_Number_1__c, Delivery_Charge_Type_1__c, Zuora__CustomerAccount__r.Name, 
                    Zuora__CustomerAccount__r.Payment_Mode__c, Main_Package_1__r.Name  
                    from Zuora__Subscription__c where Id = :csdc.thisOrder.Subscription__c];
            System.debug('zs1: >>> ' + zs);
            System.debug('zs1: >>> ' + zs.Number_of_Copies__c);
            System.debug('setZuoSub2: >>> ' + zouraSubscription2);
            //System.debug('zs1: >>> ' + zs.Number_of_Copies1__c);
            //System.debug('zs1: >>> ' + zs.Qty__c);
            System.debug('after zuosub2 3');
            for(Zuora__Subscription__c zSubz : [select Main_Package_1__c, Number_of_Copies__c, Zuora__SubscriptionStartDate__c, 
                        Zuora__SubscriptionEndDate__c, Main_Package_1__r.Name from Zuora__Subscription__c 
                                                where Order_Number_1__c = :zs.Order_Number_1__c and Id != :zs.Id]) {
                        System.debug('zSubz.value: >>> ' + zSubz);                                        
                                                }
            System.debug('after zuosub2 4');
                       
            System.debug('zouraSubscription.Number_of_Copies1__c: >>> ' + zouraSubscription.Number_of_Copies1__c);
            System.debug('zouraSubscription.Number_of_Copies__c: >>> ' + zouraSubscription.Number_of_Copies__c);
            System.debug('order1: >>> ' + order);
            System.debug('order1: >>> ' + order.Subscription__c);
            System.debug('csdc.thisOrder.Subscription__c: >>> ' + csdc.thisOrder.Subscription__c);
            System.debug('after zuosub2 5');
            csdc.retrieveRelatedSubscriptions();
            Test.stopTest();
            System.debug('after zuosub2 6');
        } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
        System.debug('retrieveRelatedSubscriptionsTest() end');
    }
    
    static testMethod void creditBalanceTest() {
        System.debug('creditBalanceTest() start');
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            setUpData();
            
            Test.startTest();
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            csdc.thisOrder = order;
            csdc.creditBalance(order.Id);
            Test.stopTest();
            
        } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
        System.debug('creditBalanceTest() end');
    }
    
    static testMethod void doCancelTest() {
        System.debug('doCancelTest() start');
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            setUpData();
            
            Test.startTest();
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            csdc.thisOrder = order;
            csdc.doCancel();
            Test.stopTest();
            
            } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
        System.debug('doCancelTest() end');
    }
    
    static testMethod void voidTest1() {
        System.debug('voidTest1() start');
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            //setUpData();
            setVendorAcct();
            setPackage();
            setSignPostAddr();
            setAddress();
            setContact();
            setCase();
            insert aCase;  
            setOrder();
            setOrderLineItem();
            
            PageReference pRef = new Pagereference('/apex/SM_ChangeOfSubscriptionDetail?id=' + order.Id + '&accountId=' + vendorAcct.Id);
            Test.setCurrentPage(pRef);
            
            
            
            Test.startTest();
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            csdc.thisOrder = order;
            
            System.debug('Case: >>> ' + [select Case__c from Order_Line_Item__c where Order__c = :order.Id limit 1].Case__c);
            
            csdc.void();
            Test.stopTest();
            } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
        System.debug('voidTest1() end');
    }
    
    static testMethod void voidTest2() {
        System.debug('voidTest2() start');
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            setUpData();
   
            
            PageReference pRef = new Pagereference('/apex/SM_ChangeOfSubscriptionDetail?id=' + order.Id + '&accountId=' + vendorAcct.Id);
            Test.setCurrentPage(pRef);
            
            Test.startTest();
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            order.Status__c = 'Cancelled';
            orderLineItem.Case__c = null;
            //update orderLineItem;
            
            csdc.thisOrder = order;
            csdc.void();
            Test.stopTest();
            } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
        System.debug('voidTest2() end');
    }
    
    /* Template
    static testMethod void retrieveOrderLineItemsTest() {
        System.debug('retrieveOrderLineItemsTest() start');
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            setUpData();
            Test.startTest();
            SM_ChangeOfSubscriptionDetailController csdc = new SM_ChangeOfSubscriptionDetailController();
            Test.stopTest();
            } catch(Exception e) {
            System.debug('zRemoteException: ' + e);
        }
        System.debug('retrieveOrderLineItemsTest() end');
    }
    */
    
}