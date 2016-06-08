/* April Veloso
   11/26/2015
   Test class for SP_RenewalReminderHelper
*/

@isTest
private class SP_RenewalReminderHelperTest{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createBatchInterface();        
        insert CustomSettingsDataFactory.createPlannerSched();
    } 
    
    public static Map<Id, List<Zuora__Subscription__c>> parentLPRSubscriptionListMap;
    public static Set<Id> setId = new Set<Id>();
    public static List<Letter_Print_Request__c> scope;
    public static List<Zuora__Subscription__c> zSubList;
    public static Map<Id,String> subscriptionId_languageMediumMapParam = new Map<Id,String>();
    public static Map<String, zqu__ZProduct__c> productMap = new Map<String, zqu__ZProduct__c>();
    public static Map<Id, Package__c> mainPackageMap = new Map<Id, Package__c>();


    static testMethod void TestSP_RenewalReminderHelperTestMagazine () {
        dataPreparation('Magazine', 'Vendor', true);
        Test.startTest();
        SP_RenewalReminderHelper renewalReminderHelper = new SP_RenewalReminderHelper();
        SP_RenewalReminderHelper.getSubscriptionLanguageMediumMap(setId);
        SP_RenewalReminderHelper.getFinalLanguageMedium(scope, 'E');
        SP_RenewalReminderHelper.getFinalLanguageMedium(zSubList, subscriptionId_languageMediumMapParam);
        //SP_RenewalReminderHelper.getrecipientDeliveryPostageFeeMap(parentLPRSubscriptionListMap);
        SP_RenewalReminderHelper.getSuspendedOrderLineItemSet(zSubList, productMap,System.today() ,false, 'N');
        SP_RenewalReminderHelper.getOrderLineItemWithInvalidPackage(zSubList);
        SP_RenewalReminderHelper.getRenewalRates(zSubList,mainPackageMap,productMap);
        SP_RenewalReminderHelper.getSubscriptionTableLabel('Magazine',productMap, mainPackageMap, zSubList);
        Test.stopTest();
     }
     
     static testMethod void TestSP_RenewalReminderHelperTestNewspaper () {
        dataPreparation('Newspaper', 'Vendor', true);
        Test.startTest();
        SP_RenewalReminderHelper renewalReminderHelper = new SP_RenewalReminderHelper();
        SP_RenewalReminderHelper.getSubscriptionLanguageMediumMap(setId);
        SP_RenewalReminderHelper.getFinalLanguageMedium(scope, 'E');
        SP_RenewalReminderHelper.getFinalLanguageMedium(zSubList, subscriptionId_languageMediumMapParam);
        SP_RenewalReminderHelper.getrecipientDeliveryPostageFeeMap(parentLPRSubscriptionListMap);
        SP_RenewalReminderHelper.getSuspendedOrderLineItemSet(zSubList, productMap,System.today() ,false, 'N');
        SP_RenewalReminderHelper.getOrderLineItemWithInvalidPackage(zSubList);
        SP_RenewalReminderHelper.getRenewalRates(zSubList,mainPackageMap,productMap);
        SP_RenewalReminderHelper.getSubscriptionTableLabel('Newspaper',productMap, mainPackageMap, zSubList);
        Test.stopTest();
     }                      
     
    static testMethod void TestgetSuspendedOrderLineItemSetMag() {
        dataPreparation('Magazine', 'Mailing Agent', true);
        Test.startTest();
        system.debug('>>>>>CHA parentLPRSubscriptionListMap : ' + parentLPRSubscriptionListMap); //CHACHA
        SP_RenewalReminderHelper.getrecipientDeliveryPostageFeeMap(parentLPRSubscriptionListMap);
        SP_RenewalReminderHelper.getSuspendedOrderLineItemSet(zSubList, productMap,System.today().addDays(-37) ,true, 'N');
        Test.stopTest();
    }
    
    static testMethod void TestgetSuspendedOrderLineItemSetNews() {
        dataPreparation('Newspaper', 'Vendor', false);
        Test.startTest();
        SP_RenewalReminderHelper.getSuspendedOrderLineItemSet(zSubList, productMap,System.today().addDays(-37) ,true, 'N');
        SP_RenewalReminderHelper.getRenewalRates(zSubList,mainPackageMap,productMap);
        Test.stopTest();
    }
    
    static testMethod void TestgetSuspendedOrderLineItemSetNewsBatchModeY() {
        dataPreparation('Newspaper', 'Vendor', true);
        Test.startTest();
        Date dateParam = System.today().addDays(-37);
        system.debug('>>>>>CHA dateParam: ' + dateParam);
        SP_RenewalReminderHelper.getSuspendedOrderLineItemSet(zSubList, productMap,dateParam ,true, 'Y');
        Test.stopTest();
    }
    
    static testMethod void TestWithProdCode() {
        dataPreparation('Newspaper', 'Vendor', true);
        Product_Code__c prodCode = new Product_Code__c();
        prodCode.Name = 'Cod1Name';
        prodCode.Product_Code__c = 'Cod1';
        database.insert(prodCode);
        
        Test.startTest();
        SP_RenewalReminderHelper.getrecipientDeliveryPostageFeeMap(parentLPRSubscriptionListMap);
        Test.stopTest();
    }
    
    static testMethod void TestgetFinalLanguageMedium() {
        dataPreparation('Newspaper', 'Vendor', true);       
        Test.startTest();
        SP_RenewalReminderHelper.getFinalLanguageMedium(null, subscriptionId_languageMediumMapParam);
        Test.stopTest();
    }
    
    static void dataPreparation(string productType, String deliverBy, Boolean samePckRenewNews) {
        Renewal_Notifications__c theDay = new Renewal_Notifications__c();
        theDay.Name = 'Renewal Notifications Values';
        theDay.X1st_Notification_Magazine__c = 42;
        theDay.X2nd_Notification_Magazine__c = 14;
        theDay.X1st_Notification_Newspaper__c = 42;
        theDay.X2nd_Notification_Newspaper__c = 14;
        database.insert(theDay);
        
                Other__c other = new Other__c();
                other.Name = 'DTL';
                other.Value__c = '23:59';
                insert(other); 
                
                Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
                cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
                cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
                cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Sun_Start_Time__c = System.Now();
                cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Name = 'CIR Plan Schedule';
                insert cirPlannerSchedule;

                    // Test.setMock(WebServiceMock.class, new zLoginMock());   
                    User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
                    
                    System.runAs(u){
                    
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
                        insert acc;
                        
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Building_Name__c = 'Ebloc2';
                        insert postal;
                        
                        Country__c country = TestDataFactory.createCountry(1)[0]; 
                        country.Country_Name__c = 'SINGAPORE'; 
                        insert country;
                        
                        Address__c address = TestDataFactory.createAddress(1)[0];
                        //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                        address.Block_House_Number__c =  'TEST';
                        address.Postal_Code__c = postal.id;
                        address.Level_Number__c = '17';
                        address.Unit_Number__c = 'Unit 5';
                        address.Country__c = country.id;
                        
                        //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
                        
                        insert address;
                        
                        Contact con = TestDataFactory.createContact(1)[0];
                        con.AccountId = acc.Id;
                        con.Address__c = address.id;
                        con.Recipient_Indicator__c = true;
                        // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                        insert con;
                        
                        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                        billAccountList[0].name = 'April Summer';
                        //billAccountList [0].id = zInv.id;
                        billAccountList[0].Zuora__Account__c = acc.id; 
                        billAccountList[0].Billing_Contact__c = con.id;
                        billAccountList[0].ARMS_Account_Number__c = '027101021';
                        billAccountList[0].Other_PaymentMethod__c ='Invoice';
                        billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                        billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                        billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                        insert billAccountList;
                                  
                        Package__c pack = TestDataFactory.createPackage(1)[0];
                        pack.Effective_End_Date__c = date.today().addDays(30);
                        pack.Package_Type__c = 'Base Product';
                        pack.Same_Pck_Renewal_Newspaper__c = samePckRenewNews;
                        insert pack;
                        
                       /* Order__c ord = TestDataFactory.createOrder(1)[0];
                        ord.Account__c = acc.Id;
                        ord.Informed_Customer__c = TRUE;
                        ord.Recipient_Contact__c = con.Id;
                        ord.Subscriber_Charge__c = 100.00;
                        insert ord;
                        
                        Order_Line_Item__c orderLine = TestDataFactory.createOrderLineItem(1)[0];
                        orderLine.Order__c = ord.id;
                        orderLine.Main_Package_ID__c = pack.id;
                        orderLine.amount_to_refund__c = 100.00;
                        orderLine.fee_override__c = true;
                        orderLine.fee_override_amount__c = 5.00;
                        database.insert(orderLine);*/
                  
                        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                        zSub.Name = 'NUM124';
                        zSub.Billing_Type__c = 'Full Prepaid';
                        zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                        zSub.Subscription_Type_1__c = 'Publication';
                        zSub.Subscription_Type__c = 'Publication';
                        zSub.Zuora__Account__c = acc.id;
                        zSub.Zuora__Status__c = 'Cancelled';
                        zSub.Recipient_Contact__c = con.id;
                        zSub.Name = 'S0000000';
                        //zSub.Order_Number__c = order.id;
                        zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                        zSub.Zuora__SubscriptionEndDate__c = date.Today().addDays(42);
                        zSub.Zuora__AutoRenew__c = False;
                        zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                        zSub.Number_of_Copies__c=100;
                        zSub.Number_of_Copies1__c =  '100';
                        zSub.Qty__c = 20;
                        zSub.Subscription_Type_1__c = 'Publication';
                        zSub.Subscription_Type__c = 'Publication';
                        zSub.Term_Length__c = 1;
                        zSub.Term_Length1__c = '1';
                        zSub.Main_Package_1__c = pack.id;
                        zSub.Main_Package__c = pack.id;
                        zSub.Delivered_By__c = deliverBy;
                        zSUb.Product_Code__c = 'Cod1';
                        zSUb.Delivery_Charge_Type__c = 'H';
                        insert zSub; 
                        
                        List<Order__c> order = TestDataFactory.createOrder(2);
                        order[0].Account__c = acc.Id;
                        order[0].Informed_Customer__c = TRUE;
                        order[0].Recipient_Contact__c = con.Id;
                        order[0].Subscriber_Charge__c = 100.00;
                        order[0].Base_Subscription__c = zSub.id;
                        order[0].Status__c = 'Void';
                        //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                        order[0].Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                        order[0].Urgent_Stop__c = true;
                        order[0].isWaive__c = true;
                        order[0].Delivery_Charge_Type__c = 'H';
                        
                        order[1].Account__c = acc.Id;
                        order[1].Informed_Customer__c = TRUE;
                        order[1].Recipient_Contact__c = con.Id;
                        order[1].Subscriber_Charge__c = 100.00;
                        order[1].Base_Subscription__c = zSub.id;
                        order[1].Status__c = 'Void';
                        //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                        order[1].Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                        order[1].Urgent_Stop__c = true;
                        order[1].isWaive__c = true;
                        insert order;
                        
                        List<Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(2);
                        orderLineItem[0].Order__c = order[0].id;
                        orderLineItem[0].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                        orderLineItem[0].Main_Package_ID__c = pack.id;
                        orderLineItem[0].amount_to_refund__c = 100.00;
                        orderLineItem[0].Subscription__c = zSub.id;
                        orderLineItem[0].fee_override__c = true;
                        orderLineItem[0].fee_override_amount__c = 5.00;
                        orderLineItem[0].Main_Package_Product_Sub_Type__c = productType;
                        
                        orderLineItem[1].Order__c = order[1].id;
                        orderLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                        orderLineItem[1].Main_Package_ID__c = pack.id;
                        orderLineItem[1].amount_to_refund__c = 100.00;
                        orderLineItem[1].Subscription__c = zSub.id;
                        orderLineItem[1].fee_override__c = true;
                        orderLineItem[1].fee_override_amount__c = 5.00;
                        orderLineItem[1].Main_Package_Product_Sub_Type__c = 'subType';
                        database.insert(orderLineItem);
                        
                        zSub.Order_Number_1__c = order[0].id;
                        zSub.Order_Line_Item_Number__c = orderLineItem[0].id;
                        zSub.Order_Line_Item_Number_1__c = orderLineItem[0].id;
                        database.update(zSub);
                        
                        List<Zuora__SubscriptionProductCharge__c> SubscriptionProductCharge = TestDataFactory.createSubscriptionProductCharge(2);
                        SubscriptionProductCharge[0].Zuora__Subscription__c= zSub.id;
                        SubscriptionProductCharge[0].PublicationCode__c = 'Cod1';
                        
                        SubscriptionProductCharge[1].Zuora__Subscription__c= zSub.id;
                        SubscriptionProductCharge[1].PublicationCode__c = 'Cod2';
                        database.insert(SubscriptionProductCharge);
                        
                        List<Publication__c> pub = TestDataFactory.createPublication(2);
                        pub[0].Publication_Code__c = 'Cod1';
                        pub[1].Publication_Code__c = 'Cod2';
                        database.insert(pub);
                        
                         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                        letterPrintRequest.Billing_Account__c = billAccountList[0].id;
                        letterPrintRequest.Language_Medium__c = 'M';
                        letterPrintRequest.Parent_Letter_Print_Request__c =  null;
                        letterPrintRequest.Status__c = 'New';
                        letterPrintRequest.Type__c = 'Master';
                        letterPrintRequest.Letter_Type__c = 'Acknowledgment Letter';
                        letterPrintRequest.Status_Email__c = 'New';
                        database.insert(letterPrintRequest);
                        
                        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                        zProduct.ProductCode__c = 'Cod1';
                        database.insert(zProduct);
                        
                        parentLPRSubscriptionListMap = new Map<Id, List<Zuora__Subscription__c>>();
                        system.debug('>>>>>CHA letterPrintRequest: ' + letterPrintRequest); //CHACHA
                        scope = [SELECT Id, Billing_Account__c, Language_Medium__c, Status__c, Type__c, 
                                                                        Letter_Type__c, Parent_Letter_Print_Request__c
                                                               FROM Letter_Print_Request__c where id =: letterPrintRequest.id];
                        system.debug('>>>>>CHA zSub : ' + zSub); //CHACHA
                        zSubList = [SELECT Id, Order_Line_Item_Number__c, Order_Line_Item_Number_1__c, 
                                                                        Recipient_Contact__c, Recipient_Contact__r.Recipient_Contact__c, 
                                                                        Delivered_By__c, Product_Code__c, 
                                                                        Order_Number_1__r.Delivery_Charge_Type__c, Zuora__SubscriptionEndDate__c,
                                                                        Main_Package_1__r.Effective_End_Date__c, 
                                                                        Main_Package_Product_Sub_Type_Mapping__c, 
                                                                        Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c,
                                                                        Delivery_Charge_Type__c,
                                                                        Recipient_Contact__r.address__c, Recipient_Contact__r.Address__r.Address_Type__c
                                                                 FROM Zuora__Subscription__c where id =: zSub.id];
                        
                        system.debug('>>>>>CHA scope : ' + scope); //CHACHA
                        for (Letter_Print_Request__c LPR :scope) {
                            system.debug('>>>>>CHA LPR.Parent_Letter_Print_Request__c : ' + LPR.Parent_Letter_Print_Request__c); //CHACHA
                            system.debug('>>>>>CHA zSubList : ' + zSubList); //CHACHA
                            parentLPRSubscriptionListMap.put(LPR.Parent_Letter_Print_Request__c, zSubList );
                        }
                        
                        setId.add(zSub.id);
                        subscriptionId_languageMediumMapParam = new Map<Id,String>();
                        subscriptionId_languageMediumMapParam.put(zSub.id, 'E');
                        
                        productMap.put('Cod1', ZProduct);
                        mainPackageMap.put(pack.id, pack);

                    }
            
    }
    /*
    static testMethod void TestSP_RenewalReminderHelperTestNewspaper() {
                Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBER';
                key.Id__c = '30012551';
                insert(key); 
                
                
                Other__c other = new Other__c();
                other.Name = 'DTL';
                other.Value__c = '23:59';
                insert(other); 
                
                Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
                cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
                cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
                cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Sun_Start_Time__c = System.Now();
                cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Name = 'CIR Plan Schedule';
                insert cirPlannerSchedule;
                
                try {
                    // Test.setMock(WebServiceMock.class, new zLoginMock());   
                    User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
                    
                    System.runAs(u){
                    
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
                        insert acc;
                        
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Building_Name__c = 'Ebloc2';
                        insert postal;
                        
                        Country__c country = TestDataFactory.createCountry(1)[0]; 
                        country.Country_Name__c = 'SINGAPORE'; 
                        insert country;
                        
                        Address__c address = TestDataFactory.createAddress(1)[0];
                        //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                        address.Block_House_Number__c =  'TEST';
                        address.Postal_Code__c = postal.id;
                        address.Level_Number__c = '17';
                        address.Unit_Number__c = 'Unit 5';
                        address.Country__c = country.id;
                        
                        //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
                        
                        insert address;
                        
                        Contact con = TestDataFactory.createContact(1)[0];
                        con.AccountId = acc.Id;
                        con.Address__c = address.id;
                        con.Recipient_Indicator__c = true;
                        // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                        insert con;
                        
                        
                        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                        billAccountList[0].name = 'April Summer';
                        //billAccountList [0].id = zInv.id;
                        billAccountList[0].Zuora__Account__c = acc.id; 
                        billAccountList[0].Billing_Contact__c = con.id;
                        billAccountList[0].ARMS_Account_Number__c = '027101021';
                        billAccountList[0].Other_PaymentMethod__c ='Invoice';
                        billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                        billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                        billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                        insert billAccountList;
                              
                        
                        Package__c pack = TestDataFactory.createPackage(1)[0];
                        pack.Effective_End_Date__c = date.today().addDays(30);
                        pack.Package_Type__c = 'Base Product';
                        insert pack;
                        
                       /* Order__c ord = TestDataFactory.createOrder(1)[0];
                        ord.Account__c = acc.Id;
                        ord.Informed_Customer__c = TRUE;
                        ord.Recipient_Contact__c = con.Id;
                        ord.Subscriber_Charge__c = 100.00;
                        insert ord;
                        
                        Order_Line_Item__c orderLine = TestDataFactory.createOrderLineItem(1)[0];
                        orderLine.Order__c = ord.id;
                        orderLine.Main_Package_ID__c = pack.id;
                        orderLine.amount_to_refund__c = 100.00;
                        orderLine.fee_override__c = true;
                        orderLine.fee_override_amount__c = 5.00;
                        database.insert(orderLine);
                  
                        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                        zSub.Name = 'NUM124';
                        zSub.Billing_Type__c = 'Full Prepaid';
                        zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                        zSub.Subscription_Type_1__c = 'Publication';
                        zSub.Subscription_Type__c = 'Publication';
                        zSub.Zuora__Account__c = acc.id;
                        zSub.Zuora__Status__c = 'Cancelled';
                        zSub.Recipient_Contact__c = con.id;
                        zSub.Name = 'S0000000';
                        //zSub.Order_Number__c = order.id;
                        zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                        zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                        zSub.Zuora__AutoRenew__c = False;
                        zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                        zSub.Number_of_Copies__c=100;
                        zSub.Number_of_Copies1__c =  '100';
                        zSub.Qty__c = 20;
                        zSub.Subscription_Type_1__c = 'Publication';
                        zSub.Subscription_Type__c = 'Publication';
                        zSub.Term_Length__c = 1;
                        zSub.Term_Length1__c = '1';
                        zSub.Main_Package_1__c = pack.id;
                        zSub.Main_Package__c = pack.id;
                        zSub.Delivered_By__c = 'Vendor';
                        zSUb.Product_Code__c = 'Cod1';
                        insert zSub; 
                        
                        List<Order__c> order = TestDataFactory.createOrder(2);
                        order[0].Account__c = acc.Id;
                        order[0].Informed_Customer__c = TRUE;
                        order[0].Recipient_Contact__c = con.Id;
                        order[0].Subscriber_Charge__c = 100.00;
                        order[0].Base_Subscription__c = zSub.id;
                        order[0].Status__c = 'Void';
                        //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                        order[0].Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                        order[0].Urgent_Stop__c = true;
                        order[0].isWaive__c = true;
                        order[0].Delivery_Charge_Type__c = 'H';
                        
                        order[1].Account__c = acc.Id;
                        order[1].Informed_Customer__c = TRUE;
                        order[1].Recipient_Contact__c = con.Id;
                        order[1].Subscriber_Charge__c = 100.00;
                        order[1].Base_Subscription__c = zSub.id;
                        order[1].Status__c = 'Void';
                        //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                        order[1].Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                        order[1].Urgent_Stop__c = true;
                        order[1].isWaive__c = true;
                        insert order;
                        
                        List<Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(2);
                        orderLineItem[0].Order__c = order[0].id;
                        orderLineItem[0].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                        orderLineItem[0].Main_Package_ID__c = pack.id;
                        orderLineItem[0].amount_to_refund__c = 100.00;
                        orderLineItem[0].Subscription__c = zSub.id;
                        orderLineItem[0].fee_override__c = true;
                        orderLineItem[0].fee_override_amount__c = 5.00;
                        orderLineItem[0].Main_Package_Product_Sub_Type__c = 'Newspaper';
                        
                        orderLineItem[1].Order__c = order[1].id;
                        orderLineItem[1].Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                        orderLineItem[1].Main_Package_ID__c = pack.id;
                        orderLineItem[1].amount_to_refund__c = 100.00;
                        orderLineItem[1].Subscription__c = zSub.id;
                        orderLineItem[1].fee_override__c = true;
                        orderLineItem[1].fee_override_amount__c = 5.00;
                        orderLineItem[1].Main_Package_Product_Sub_Type__c = 'subType';
                        database.insert(orderLineItem);
                        
                        zSub.Order_Number_1__c = order[0].id;
                        zSub.Order_Line_Item_Number__c = orderLineItem[0].id;
                        zSub.Order_Line_Item_Number_1__c = orderLineItem[0].id;
                        database.update(zSub);
                        
                        List<Zuora__SubscriptionProductCharge__c> SubscriptionProductCharge = TestDataFactory.createSubscriptionProductCharge(2);
                        SubscriptionProductCharge[0].Zuora__Subscription__c= zSub.id;
                        SubscriptionProductCharge[0].PublicationCode__c = 'Cod1';
                        
                        SubscriptionProductCharge[1].Zuora__Subscription__c= zSub.id;
                        SubscriptionProductCharge[1].PublicationCode__c = 'Cod2';
                        database.insert(SubscriptionProductCharge);
                        
                        List<Publication__c> pub = TestDataFactory.createPublication(2);
                        pub[0].Publication_Code__c = 'Cod1';
                        pub[1].Publication_Code__c = 'Cod2';
                        database.insert(pub);
                        
                         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                        letterPrintRequest.Billing_Account__c = billAccountList[0].id;
                        letterPrintRequest.Language_Medium__c = 'M';
                        letterPrintRequest.Parent_Letter_Print_Request__c =  null;
                        letterPrintRequest.Status__c = 'New';
                        letterPrintRequest.Type__c = 'Master';
                        letterPrintRequest.Letter_Type__c = 'Acknowledgment Letter';
                        letterPrintRequest.Status_Email__c = 'New';
                        database.insert(letterPrintRequest);
                        
                        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                        zProduct.ProductCode__c = 'Cod1';
                        database.insert(zProduct);
                        
                        List<Letter_Print_Request__c> scope = [SELECT Id, Billing_Account__c, Language_Medium__c, Status__c,Type__c,Letter_Type__c, Parent_Letter_Print_Request__c FROM Letter_Print_Request__c where id =: letterPrintRequest.id];
                        List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number__c, Order_Line_Item_Number_1__c, Recipient_Contact__c, Delivered_By__c, Product_Code__c, Order_Number_1__r.Delivery_Charge_Type__c, Zuora__SubscriptionEndDate__c,
                        Main_Package_1__r.Effective_End_Date__c, Main_Package_Product_Sub_Type_Mapping__c, Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c  from Zuora__Subscription__c where id =: zSub.id];
                        Set<Id> setId = new Set<Id>();
                        setId.add(zSub.id);
                        Map<Id,String> subscriptionId_languageMediumMapParam = new Map<Id,String>();
                        subscriptionId_languageMediumMapParam.put(zSub.id, 'E');
                        Map<String, zqu__ZProduct__c> productMap = new Map<String, zqu__ZProduct__c>();
                        productMap.put('Cod1', ZProduct);
                        Map<Id, Package__c> mainPackageMap = new Map<Id, Package__c>();
                        mainPackageMap.put(pack.id, pack);
                        Test.startTest();
                            SP_RenewalReminderHelper renewalReminderHelper = new SP_RenewalReminderHelper();
                            SP_RenewalReminderHelper.getSubscriptionLanguageMediumMap(setId);
                            SP_RenewalReminderHelper.getFinalLanguageMedium(scope, 'E');
                            SP_RenewalReminderHelper.getFinalLanguageMedium(zSubList, subscriptionId_languageMediumMapParam);
                            //SP_RenewalReminderHelper.getrecipientDeliveryPostageFeeMap(zSubList);
                            SP_RenewalReminderHelper.getSuspendedOrderLineItemSet(zSubList, productMap);
                            SP_RenewalReminderHelper.getOrderLineItemWithInvalidPackage(zSubList);
                            SP_RenewalReminderHelper.getRenewalRates(zSubList,mainPackageMap,productMap);
                        Test.stopTest();
                }
         }catch(Zuora.zRemoteException e) {} 
         
    } */
  /*APRIL
    static testMethod void TestSP_RenewalReminderHelperTestListPackage() {
                Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBER';
                key.Id__c = '30012551';
                insert(key); 
                
                
                Other__c other = new Other__c();
                other.Name = 'DTL';
                other.Value__c = '23:59';
                insert(other); 
                
                Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
                cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
                cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
                cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Sun_Start_Time__c = System.Now();
                cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Name = 'CIR Plan Schedule';
                insert cirPlannerSchedule;
                
                try {
                    // Test.setMock(WebServiceMock.class, new zLoginMock());   
                    User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
                    
                    System.runAs(u){
                    
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
                        insert acc;
                        
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Building_Name__c = 'Ebloc2';
                        insert postal;
                        
                        Country__c country = TestDataFactory.createCountry(1)[0]; 
                        country.Country_Name__c = 'SINGAPORE'; 
                        insert country;
                        
                        Address__c address = TestDataFactory.createAddress(1)[0];
                        //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                        address.Block_House_Number__c =  'TEST';
                        address.Postal_Code__c = postal.id;
                        address.Level_Number__c = '17';
                        address.Unit_Number__c = 'Unit 5';
                        address.Country__c = country.id;
                        
                        //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
                        
                        insert address;
                        
                        Contact con = TestDataFactory.createContact(1)[0];
                        con.AccountId = acc.Id;
                        con.Address__c = address.id;
                        con.Recipient_Indicator__c = true;
                        // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                        insert con;
                        
                        
                        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                        billAccountList[0].name = 'April Summer';
                        //billAccountList [0].id = zInv.id;
                        billAccountList[0].Zuora__Account__c = acc.id; 
                        billAccountList[0].Billing_Contact__c = con.id;
                        billAccountList[0].ARMS_Account_Number__c = '027101021';
                        billAccountList[0].Other_PaymentMethod__c ='Invoice';
                        billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                        billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                        billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                        insert billAccountList;
                                  
                        Package__c packParent = TestDataFactory.createPackage(1)[0];
                        database.insert(packParent);          
                       
                        List<Package__c> pack = TestDataFactory.createPackage(2);
                        pack[0].Effective_End_Date__c = date.today().addDays(30);
                        pack[0].Package_Type__c = 'Base Product';
                        pack[0].RenewalPkgCodeMag1YrBase__c = packParent.id;
                        pack[0].RenewalPkgCodeMag2YrBase__c = packParent.id;
                        pack[0].RenewalPkgCodeMag1YrDisc__c = packParent.id;
                        pack[0].RenewalPkgCodeMag2YrDisc__c = packParent.id;
                        
                        pack[1].Effective_End_Date__c = date.today().addDays(39);
                        pack[1].Package_Type__c = 'Base Product';
                        pack[1].Same_Pck_Renewal_Mag_1_Yr_Base__c = true;
                        pack[1].Same_Pck_Renewal_Mag_2_Yr_Base__c = true;
                        pack[1].Same_Pck_Renewal_Mag_1_Yr_Disc__c = true;
                        pack[1].Same_Pck_Renewal_Mag_2_Yr_Disc__c = true;
                        insert pack;
                        
                                     
                        List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(2);
                        zSub[0].Name = 'NUM124';
                        zSub[0].Billing_Type__c = 'Full Prepaid';
                        zSub[0].Zuora__CustomerAccount__c = billAccountList[0].id;
                        zSub[0].Subscription_Type_1__c = 'Publication';
                        zSub[0].Subscription_Type__c = 'Publication';
                        zSub[0].Zuora__Account__c = acc.id;
                        zSub[0].Zuora__Status__c = 'Cancelled';
                        zSub[0].Recipient_Contact__c = con.id;
                        zSub[0].Zuora__SubscriptionStartDate__c = date.Today() + 1;
                        zSub[0].Zuora__SubscriptionEndDate__c = date.Today() + 5;
                        zSub[0].Zuora__AutoRenew__c = False;
                        zSub[0].Supressed_Renewal_and_Reminder_Letter_1__c = False;
                        zSub[0].Number_of_Copies__c=100;
                        zSub[0].Number_of_Copies1__c =  '100';
                        zSub[0].Qty__c = 20;
                        zSub[0].Term_Length__c = 1;
                        zSub[0].Term_Length1__c = '1';
                        zSub[0].Main_Package_1__c = pack[0].id;
                        zSub[0].Main_Package__c = pack[0].id;
                        zSub[0].Delivered_By__c = 'Vendor';
                        zSub[0].Product_Code__c = 'Cod1';
                        
                        zSub[1].Name = 'NUM125';
                        zSub[1].Billing_Type__c = 'Full Prepaid';
                        zSub[1].Zuora__CustomerAccount__c = billAccountList[0].id;
                        zSub[1].Subscription_Type_1__c = 'Publication';
                        zSub[1].Subscription_Type__c = 'Publication';
                        zSub[1].Zuora__Account__c = acc.id;
                        zSub[1].Zuora__Status__c = 'Cancelled';
                        zSub[1].Recipient_Contact__c = con.id;
                        zSub[1].Zuora__SubscriptionStartDate__c = date.Today() + 1;
                        zSub[1].Zuora__SubscriptionEndDate__c = date.Today() + 5;
                        zSub[1].Zuora__AutoRenew__c = False;
                        zSub[1].Supressed_Renewal_and_Reminder_Letter_1__c = False;
                        zSub[1].Number_of_Copies__c=100;
                        zSub[1].Number_of_Copies1__c =  '100';
                        zSub[1].Qty__c = 20;
                        zSub[1].Term_Length__c = 1;
                        zSub[1].Term_Length1__c = '1';
                        zSub[1].Main_Package_1__c = pack[1].id;
                        zSub[1].Main_Package__c = pack[1].id;
                        zSub[1].Delivered_By__c = 'Vendor';
                        zSub[1].Product_Code__c = 'Cod1';
                        insert zSub; 
                        
                        List<Order__c> order = TestDataFactory.createOrder(2);
                        order[0].Account__c = acc.Id;
                        order[0].Informed_Customer__c = TRUE;
                        order[0].Recipient_Contact__c = con.Id;
                        order[0].Subscriber_Charge__c = 100.00;
                        order[0].Base_Subscription__c = zSub[0].id;
                        order[0].Status__c = 'Void';
                        //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                        order[0].Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                        order[0].Urgent_Stop__c = true;
                        order[0].isWaive__c = true;
                        order[0].Delivery_Charge_Type__c = 'H';
                        
                        order[1].Account__c = acc.Id;
                        order[1].Informed_Customer__c = TRUE;
                        order[1].Recipient_Contact__c = con.Id;
                        order[1].Subscriber_Charge__c = 100.00;
                        order[1].Base_Subscription__c = zSub[1].id;
                        order[1].Status__c = 'Void';
                        //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                        order[1].Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                        order[1].Urgent_Stop__c = true;
                        order[1].isWaive__c = true;
                        order[1].Delivery_Charge_Type__c = 'H';
                        insert order;
                        
                        List<Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(2);
                        orderLineItem[0].Order__c = order[0].id;
                        orderLineItem[0].Start_Date__c = zSub[0].Zuora__SubscriptionEndDate__c.addDays(1);
                        orderLineItem[0].Main_Package_ID__c = pack[0].id;
                        orderLineItem[0].amount_to_refund__c = 100.00;
                        orderLineItem[0].Subscription__c = zSub[0].id;
                        orderLineItem[0].fee_override__c = true;
                        orderLineItem[0].fee_override_amount__c = 5.00;
                        orderLineItem[0].Main_Package_Product_Sub_Type__c = 'Magazine';
                        
                        orderLineItem[1].Order__c = order[1].id;
                        orderLineItem[1].Start_Date__c = zSub[1].Zuora__SubscriptionEndDate__c.addDays(1);
                        orderLineItem[1].Main_Package_ID__c = pack[1].id;
                        orderLineItem[1].amount_to_refund__c = 100.00;
                        orderLineItem[1].Subscription__c = zSub[1].id;
                        orderLineItem[1].fee_override__c = true;
                        orderLineItem[1].fee_override_amount__c = 5.00;
                        orderLineItem[1].Main_Package_Product_Sub_Type__c = 'Magazine';
                        database.insert(orderLineItem);
                        
                        zSub[0].Order_Number_1__c = order[0].id;
                        zSub[0].Order_Line_Item_Number__c = orderLineItem[0].id;
                        zSub[0].Order_Line_Item_Number_1__c = orderLineItem[0].id;
                        
                        zSub[1].Order_Number_1__c = order[1].id;
                        zSub[1].Order_Line_Item_Number__c = orderLineItem[1].id;
                        zSub[1].Order_Line_Item_Number_1__c = orderLineItem[1].id;
                        
                        database.update(zSub);
                        
                        List<Zuora__SubscriptionProductCharge__c> SubscriptionProductCharge = TestDataFactory.createSubscriptionProductCharge(2);
                        SubscriptionProductCharge[0].Zuora__Subscription__c= zSub[0].id;
                        SubscriptionProductCharge[0].PublicationCode__c = 'Cod1';
                        
                        SubscriptionProductCharge[1].Zuora__Subscription__c= zSub[1].id;
                        SubscriptionProductCharge[1].PublicationCode__c = 'Cod2';
                        
                        database.insert(SubscriptionProductCharge);
                        
                        List<Publication__c> pub = TestDataFactory.createPublication(2);
                        pub[0].Publication_Code__c = 'Cod1';
                        pub[1].Publication_Code__c = 'Cod2';
                        database.insert(pub);
                        
                        Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                        letterPrintRequest.Billing_Account__c = billAccountList[0].id;
                        letterPrintRequest.Language_Medium__c = 'M';
                        letterPrintRequest.Parent_Letter_Print_Request__c =  null;
                        letterPrintRequest.Status__c = 'New';
                        letterPrintRequest.Type__c = 'Master';
                        letterPrintRequest.Letter_Type__c = 'Acknowledgment Letter';
                        letterPrintRequest.Status_Email__c = 'New';
                        database.insert(letterPrintRequest);
                        
                        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                        zProduct.ProductCode__c = 'Cod1';
                        database.insert(zProduct);
                        
                        List<Letter_Print_Request__c> scope = [SELECT Id, Billing_Account__c, Language_Medium__c, Status__c,Type__c,Letter_Type__c, Parent_Letter_Print_Request__c FROM Letter_Print_Request__c where id =: letterPrintRequest.id];
                 //       List<Zuora__Subscription__c> zSubList = [SELECT Id, Order_Line_Item_Number__c, Order_Line_Item_Number_1__c, Recipient_Contact__c, Delivered_By__c, Product_Code__c, Order_Number_1__r.Delivery_Charge_Type__c, Zuora__SubscriptionEndDate__c,
                 //       Main_Package_1__r.Effective_End_Date__c, Main_Package_Product_Sub_Type_Mapping__c, Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c  from Zuora__Subscription__c where id =: zSub.id];
                        Set<Id> setId = new Set<Id>();
                        setId.add(zSub[0].id);
                        setId.add(zSub[1].id);
                       
                        Map<Id,String> subscriptionId_languageMediumMapParam = new Map<Id,String>();
                        subscriptionId_languageMediumMapParam.put(zSub[0].id, 'E');
                        subscriptionId_languageMediumMapParam.put(zSub[1].id, 'E');
                      
                        Map<String, zqu__ZProduct__c> productMap = new Map<String, zqu__ZProduct__c>();
                        productMap.put('Cod1', ZProduct);
                        Map<Id, Package__c> mainPackageMap = new Map<Id, Package__c>();
                        mainPackageMap.put(pack[0].id, pack[0]);
                        mainPackageMap.put(pack[1].id, pack[1]);
                        
                        Test.startTest();
                            SP_RenewalReminderHelper renewalReminderHelper = new SP_RenewalReminderHelper();
                            SP_RenewalReminderHelper.getSubscriptionLanguageMediumMap(setId);
                            SP_RenewalReminderHelper.getFinalLanguageMedium(scope, 'E');
                            SP_RenewalReminderHelper.getFinalLanguageMedium(zSub, subscriptionId_languageMediumMapParam);
                            SP_RenewalReminderHelper.getrecipientDeliveryPostageFeeMap(zSub);
                            SP_RenewalReminderHelper.getSuspendedOrderLineItemSet(zSub, productMap);
                            SP_RenewalReminderHelper.getOrderLineItemWithInvalidPackage(zSub);
                            SP_RenewalReminderHelper.getRenewalRates(zSub,mainPackageMap,productMap);
                        Test.stopTest();
                }
         }catch(Zuora.zRemoteException e) {} 
    }APRIL*/
}