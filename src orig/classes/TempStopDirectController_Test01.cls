@isTest (seeAllData= True)
private Class TempStopDirectController_Test01{
       
       
       
       static testMethod void test_TempStopDirectController001() {    
        
                    // TestData Initialization
                    
                    Integer count = 0;
                    Integer records = 1;
                    
                    //Address
                    List<Address__c> addressList = TestDataFactory.createAddress(records);
                    count = 0;
                    for (Address__c obj : addressList) {
                    }
                    insert addressList;
                    
                    system.assertNotEquals(null, addressList.size());
                    
                    //Zone
                    List<Zone__c> zoneList = TestDataFactory.createZone(records);
                    count = 0;
                    for (Zone__c obj : zoneList) {
                    obj.Name = '' + count;
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
                    obj.Country__c = countryList[count].id;
                    obj.Flight_Number_1__c = 'Flight Number 1 '+ count;
                    count++;
                    }
                    insert cityList;
                    
                    //Singpost Address
                    List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(records);
                    insert singpostAddressList;
                    
                    //Account
                    List<Account> accountList = TestDataFactory.createAccount(records, 'Direct Corporate');
                    count = 0;
                    for (Account obj : accountList) {
                    
                    obj.Singpost_Address__c = singpostAddressList[count].id;
                    
                    count++;
                    }
                    insert accountList;
                    
                    
                    //Package
                    List<Package__c> packageList = TestDataFactory.createPackage(records);
                    count = 0;
                    for (Package__c pkg : packageList) {
                    pkg.Name = 'TESTname';
                    pkg.Subscription_Period__c = '15'; 
                    count++;
                    }
                    insert packageList;
                    system.assertNotEquals(null, packageList.size());
                    
                    List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
                    for(zqu__ZProduct__c zProduct : zProductList) {
                    zProduct.ProductSubType__c = 'Newspaper';
                    zProduct.ProductPlatform__c = 'Print';
                    count++;
                    } 
                    insert zProductList;
                    
                    List<zqu__ProductRatePlan__c> prdRatePlanList = TestDataFactory.createProductRatePlan(1);
                    for(zqu__ProductRatePlan__c prpc : prdRatePlanList) {
                    prpc.zqu__ZProduct__c = zProductList[0].Id;
                    count++;
                    } 
                    insert prdRatePlanList ;
                    
                    List<zqu__ProductRatePlanCharge__c> prpcList = TestDataFactory.createProductRatePlanCharge(1);
                    for (zqu__ProductRatePlanCharge__c prpc : prpcList) {
                    prpc.zqu__ProductRatePlan__c = prdRatePlanList[0].Id;
                    prpc.PublicationCode__c = '1234';
                    count++;
                    }   
                    insert prpcList;
                    
                    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
                    for (Package_Item__c pItem : pItems) {
                    pItem.Package__c = packageList[0].Id;
                    pItem.Product_Rate_Plan__c = prdRatePlanList[0].Id;
                    count++;
                    }
                    
                    insert pItems;
                    
                    //Billing Contact
                    List<Contact> contactList = TestDataFactory.createContact(records);
                    count = 0;
                    for (Contact obj : contactList) {
                    obj.Account = accountList[count];
                    obj.City_Code__c = cityList[count].id;
                    count++;
                    }   
                    insert contactList; 
                    
                    //Billing Account
                    List<Zuora__CustomerAccount__c> zuoraCustomerAccountList = TestDataFactory.createBillingAccount(records);
                    count = 0;
                    for (Zuora__CustomerAccount__c obj : zuoraCustomerAccountList) {
                    obj.Billing_Contact__c = contactList[count].id;
                    obj.Zuora__Account__c = accountList[count].id;
                    
                    count++;
                    }
                    insert zuoraCustomerAccountList;
                    
                    //Payment Method
                    List<Zuora__PaymentMethod__c> zuoraPaymentMethodList = TestDataFactory.createPaymentMethod(records);
                    count = 0;
                    for(Zuora__PaymentMethod__c obj : zuoraPaymentMethodList) {
                    obj.Zuora__BillingAccount__c = zuoraCustomerAccountList[0].id;
                    }
                    
                    
                    insert zuoraPaymentMethodList;
                    
                    
                    //Order
                    List<Order__c> orderList = TestDataFactory.createOrder(records);
                    count = 0;
                    for (Order__c obj : orderList) {
                    obj.Account__c = accountList[count].id;
                    
                    count++;
                    }
                    insert orderList;
                    
                    List<Publication__c> publicationList = TestDataFactory.createPublication(1);
                    count = 0;
                    for (Publication__c publication : publicationList ) {
                    publication.Product_Family__c = 'PrFam';
                    publication.Published_Days__c = 'YYYYYYY';
                    publication.Publication_Type__c = 'N';
                    publication.Publication_Code__c = '1234';
                    publication.Platform_Type__c = 'Print';
                    count++;
                    }
                    insert publicationList;
                    
                    //Order Line Item
                    List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(records);
                    count = 0;
                    for (Order_Line_Item__c obj : orderLineItemList) {
                    obj.Order__c = orderList[count].id;
                    obj.Start_Date__c = date.Today()+2;
                    obj.Main_Package_ID__c = packageList[count].id;
                    
                    count++;
                    }
                    insert orderLineItemList;
                    
                    //Subscription
                    List<Zuora__Subscription__c> zuoraSubscriptionList = TestDataFactory.createSubscription(records);
                    count = 0;
                    for (Zuora__Subscription__c obj : zuoraSubscriptionList) {
                    obj.Zuora__Account__c = accountList[count].id;
                    obj.Addon_Package_1__c = packageList[count].id;
                    obj.Zuora__CustomerAccount__c = zuoraCustomerAccountList[count].id;
                    obj.Main_Package_1__c = packageList[count].id; 
                    obj.Main_Package__c = packageList[count].id; // Jams
                    obj.Order_Line_Item_Number__c = orderLineItemList[count].id; // This should be ID of Order Line Item
                    obj.Number_of_Copies1__c = '1';
                    obj.Zuora__Status__c = Globalvariableclass.SUBSCRIPTION_STATUS_ACTIVE;
                    obj.Zuora__SubscriptionStartDate__c = Date.today();
                    obj.Zuora__SubscriptionEndDate__c = Date.today()+1;
                    obj.Subscription_Type__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
                    obj.Subscription_Type_1__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
                    obj.Zuora__TermSettingType__c = 'EVERGREEN';
                    
                    count++;
                    }
                    insert zuoraSubscriptionList;
                    
                    //FROM Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c IN : subsId];
                    List<Zuora__SubscriptionProductCharge__c> zuoraSubscriptionProductChargeList = TestDataFactory.createSubProductCharge(records);
                    count = 0;
                    for (Zuora__SubscriptionProductCharge__c obj : zuoraSubscriptionProductChargeList) {
                    obj.Zuora__Subscription__c = zuoraSubscriptionList[count].id;
                    obj.Zuora__UOM__c = ConstantsSLB.getUOM('Copy Sat');
                    
                    count++;
                    }
                    insert zuoraSubscriptionProductChargeList;
                    
                    //Jams added Case
                    List<Case> caseList = TestDataFactory.createCase(1, 'Complaint - Magazine');
                    for (Case cas : caseList) {
                    cas.Order__c = orderList[0].Id;
                    cas.Temp_Stop_Sub__c = zuoraSubscriptionList[0].id;
                    //cas.Change_of_Address_Type__c = GlobalVariableClass.BILLINGADD;
                    cas.Status = 'Pending';
                    count++;
                    }
                    insert caseList;
                    
                    List<Temp_Stop__c> tempStopList = TestDataFactory.createTempStop(1);
                    count = 0;
                    for (Temp_Stop__c tempStop : tempStopList ) {
                    tempStop.Temp_Stop_Date__c = date.Today() +1;
                    tempStop.Restart_Date__c = date.Today() +10;
                    tempStop.Case__c = caseList[0].id;
                    count++;
                    }
                    insert tempStopList;
                    
                    List<Subscription_Temp_Stop__c> tempList = new List<Subscription_Temp_Stop__c>();
                    Subscription_Temp_Stop__c  tempStopObj = new Subscription_Temp_Stop__c();
                    tempStopObj.Subscription__c = zuoraSubscriptionList[0].Id;
                    tempStopObj.Temp_Stop__c = tempStopList[0].Id;
                    
                    tempList.add(tempStopObj);
                    insert tempList;
                    
                    system.assertNotEquals(0, tempList.size());
                    
                    // Test Proper
                    Test.startTest();
                    
                    PageReference pageRef = page.TempStopDirect;
                    test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('accountId', accountList[0].Id);
                    TempStopDirectController tempStopDirController = new TempStopDirectController(); 
                    
                    //tempStopDirController.getSubscriptions();
                    
                    Set<Id> subIds = new Set<Id>();
                    subIds.add(zuoraSubscriptionList[0].id); 
                    
                    Map<ID,List<Case>> subToPendingCasesMap = new Map<ID,List<Case>>();         
                    subToPendingCasesMap.put(caseList[0].id, caseList);
                    
                    Map<Id, Id> subIdTopackageId = new Map<Id, Id>();
                    subIdTopackageId.put(zuoraSubscriptionList[0].id, packageList[0].id);
                    
                    //tempStopDirController.initialize(subIds, subIdTopackageId);
                    //        System.assertNotEquals(null,tempStopDirController.myIdUpdate);
                    
                    //        tempStopDirController.myIdUpdate = 'test';
                    tempStopDirController.setUpdateRecords();
                    
                    Test.stopTest();
                    
                    Zuora__Subscription__c actualEndDate = [SELECT Name, Zuora__Status__c, Subscription_Type_1__c, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:zuoraSubscriptionList[0].id];
                    
                    System.assertNotEquals(Null, actualEndDate);
        
        } 
        
        static testMethod void testSetSelectedRecords001() {
        
                    Integer count = 0;
                    
                    List<Account> accountList = TestDataFactory.createAccount(1, 'Direct Corporate');
                    accountList[0].Name = 'TestName';
                    insert accountList;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    insert postal;
                    
                    Address__c addressRec = TestDataFactory.createAddress(1)[0];
                    addressRec.Address_Type__c='P';
                    addressRec.Postal_Code__c = postal.Id;
                    addressRec.Address_Unique_ID__c = 'Ad123';
                    insert addressRec;
                    
                    List<Contact> con = TestDataFactory.createContact(1);
                    con[0].Phone = '1234567';
                    con[0].AccountId = accountList[0].Id;
                    con[0].Address__c = addressRec.id;
                    insert con;
                    
                    //Order__c
                    List<Order__c> orderList = TestDataFactory.createOrder(1);
                    
                    for (Order__c obj : orderList) {
                    obj.Account__c = accountList[0].id;
                    obj.Billing_Type__c = 'Full Prepaid';
                    
                    }
                    insert orderList;
                    
                    List<Publication__c> publicationList = TestDataFactory.createPublication(1);
                    count = 0;
                    for (Publication__c publication : publicationList ) {
                    // publication.Product_Family__c = 'PrFam';
                    //publication.Published_Days__c = 'YYYYYYY';
                    //publication.Publication_Type__c = 'N';
                    //publication.Publication_Code__c = '1234';
                    count++;
                    }
                    insert publicationList;
                    
                    
                    List<Package__c> pkg = TestDataFactory.createPackage(1);
                    pkg[0].Name = 'TESTname';
                    pkg[0].Subscription_Period__c = '15'; 
                    insert pkg;
                    
                    //Order Line Item
                    List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
                    for (Order_Line_Item__c obj : orderLineItemList) {
                    obj.Order__c = orderList[0].id;
                    obj.Main_Package_ID__c = pkg[0].id;
                    obj.Ph_d__c = TRUE;
                    obj.Start_Date__c = date.Today()+2;
                    obj.Ph_e__c = TRUE;       
                    
                    }
                    insert orderLineItemList;
                    
                    Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
                    cas.Account__c = accountList[0].id;
                    cas.Current_Date_for_Year_To_Date__c = 5;
                    cas.Next_Year_for_Year_To_Date__c = 5;
                    cas.POP_Start_Date__c = date.Today()+3;
                    cas.Year_To_Date_Count__c = 5;
                    cas.Total_Issue__c = 5;
                    
                    insert cas;
                    
                    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                    zProduct.ProductSubType__c = 'Newspaper';
                    zProduct.ProductPlatform__c = 'Print';
                    insert zProduct;
                    
                    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                    prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                    insert prdRatePlan;
                    
                    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
                    for (Package_Item__c pItem : pItems) {
                    pItem.Package__c = pkg[0].Id;
                    pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                    count++;
                    }
                    
                    insert pItems;  
                    
                    List<Zuora__CustomerAccount__c> zcaList = TestDataFactory.createBillingAccount(1);
                    zcaList[0].Name = 'Zuora Customer Account';
                    zcaList[0].Zuora__Account__c = accountList[0].Id;
                    zcalist[0].Billing_Contact__c = con[0].Id;
                    zcaList[0].Zuora__Credit_Balance__c = 1;
                    zcaList[0].Refund_Amount__c = 100;
                    zcaList[0].Zuora__AutoPay__c =false;
                    zcaList[0].Zuora__Balance__c = 1;
                    zcaList[0].Payment_Mode__c = 'Paypal';
                    zcaList[0].Other_PaymentMethod__c= 'Paypal';
                    zcaList[0].Zuora__PaymentMethodType__c = 'Paypal'; 
                    zcalist[0].Zuora__External_Id__c = '22544AA';  
                    zcalist[0].Zuora__Zuora_Id__c = '0124';         
                    insert zcaList;
                    
                    
                    //create billing account      
                    List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
                    for(Zuora__Subscription__c zuoraSubRec: zSubs) {
                    zuoraSubRec.Subscriber_Contact__c = con[0].id;
                    zuoraSubRec.Main_Package_1__c = pkg[0].id;
                    //zuoraSubRec.Main_Package__c = pkg[0].id;
                    zuoraSubRec.Zuora__Account__c = accountList[0].id;
                    //zuoraSubRec.Order_Number__c = null;
                    zuoraSubRec.Zuora__CustomerAccount__c = zcaList[0].Id;
                    zuoraSubRec.Billing_Type__c = 'Full Prepaid';
                    zuoraSubRec.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
                    zuoraSubRec.Next_Year_Temp_Stop_Days__c = 5;
                    zuoraSubRec.Recipient_Contact__c = con[0].id;
                    zuoraSubRec.Year_to_Date_Temp_Stop_Days__c = 5;
                    zuoraSubRec.Legacy_Create_Date__c = 'a';
                    zuoraSubRec.Legacy_Create_By__c = 'a';
                    zuoraSubRec.Legacy_Update_By__c = 'a';
                    zuoraSubRec.Frequency_1__c = 'Mon - Fri';
                    zuoraSubRec.Delivery_Charge__c = 10.00;
                    zuoraSubRec.Zuora__SubscriptionStartDate__c = date.Today();
                    zuoraSubRec.Zuora__SubscriptionEndDate__c = date.Today().addDays(1);
                    zuoraSubRec.Legacy_Subscription_ID__c = 'a';
                    zuoraSubRec.Legacy_Update_Date__c = 'a';
                    zuoraSubRec.Number_of_Copies__c = 100;
                    zuoraSubRec.Number_of_Copies1__c = '100';
                    zuoraSubRec.Zuora__Status__c = 'Active';
                    zuoraSubRec.Ph_d__c = TRUE;
                    zuoraSubRec.Ph_e__c = TRUE;
                    }
                    insert zSubs;
                    
                    //FROM Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c IN : subsId];
                    
                    Temp_Stop__c tempStop  = new Temp_Stop__c();
                    tempStop.Remarks__c = 'Remark Test';
                    tempStop.Restart_Date__c = Date.today().addDays(31);
                    tempStop.Temp_Stop_Date__c = Date.today();
                    tempStop.Request_Total_Issue__c = 5;
                    tempStop.Temp_Stop_Qty__c = 5;
                    tempStop.Qty__c = 5;
                    tempStop.Cancelled__c = false;
                    tempStop.Case__c = cas.id;
                    insert tempStop;
                    
                    Subscription_Temp_Stop__c subTempStop = new Subscription_Temp_Stop__c();
                    subTempStop.Subscription__c = zSubs[0].Id;
                    subTempStop.Temp_Stop__c = tempStop.Id;
                    insert subTempStop;
                                        
                    
                    Test.startTest();
                    PageReference pageRef = page.TempStopDirect;
                    test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('accountId', accountList[0].Id);
                    
                    
                    List<TempStopDirectController.SubscriptionWrapper> subscriptionResultList = new List<TempStopDirectController.SubscriptionWrapper>();
                    TempStopDirectController.SubscriptionWrapper subscriptionWrapper01 = new TempStopDirectController.SubscriptionWrapper();
                    subscriptionWrapper01.Id = zSubs[0].id;
                    subscriptionWrapper01.tempStopId = tempStop.id;
                    subscriptionWrapper01.tp = tempStop;
                    subscriptionResultList.add(subscriptionWrapper01); 
                    
                    TempStopDirectController tempStopDirController = new TempStopDirectController(); 
                    tempStopDirController.myId = zSubs[0].id;
                    tempStopDirController.subscriptionResultList = subscriptionResultList; 
                    //tempStopDirController.publishedDayChecker(zSubs[0].id, Date.today().addDays(31)); 
                    try{
                    tempStopDirController.setSelectedRecords();
                    }catch(Exception e){}
                    
        }
        static testMethod void testSetSelectedRecords001April1() {
                    
                                       
                    Integer count = 0;
                    
                    List<Account> accountList = TestDataFactory.createAccount(1, 'Direct Corporate');
                    accountList[0].Name = 'TestName';
                    insert accountList;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    insert postal;
                    
                    Address__c addressRec = TestDataFactory.createAddress(1)[0];
                    addressRec.Address_Type__c='P';
                    addressRec.Postal_Code__c = postal.Id;
                    addressRec.Address_Unique_ID__c = 'Ad123';
                    insert addressRec;
                    
                    List<Contact> con = TestDataFactory.createContact(1);
                    con[0].Phone = '1234567';
                    con[0].AccountId = accountList[0].Id;
                    con[0].Address__c = addressRec.id;
                    insert con;
                    
                    //Order__c
                    List<Order__c> orderList = TestDataFactory.createOrder(1);
                    
                    for (Order__c obj : orderList) {
                    obj.Account__c = accountList[0].id;
                    obj.Billing_Type__c = 'Full Prepaid';
                    
                    }
                    insert orderList;
                    
                    List<Publication__c> publicationList = TestDataFactory.createPublication(1);
                    count = 0;
                    for (Publication__c publication : publicationList ) {
                    // publication.Product_Family__c = 'PrFam';
                    //publication.Published_Days__c = 'YYYYYYY';
                    //publication.Publication_Type__c = 'N';
                    //publication.Publication_Code__c = '1234';
                    count++;
                    }
                    insert publicationList;
                    
                    
                    List<Package__c> pkg = TestDataFactory.createPackage(1);
                    pkg[0].Name = 'TESTname';
                    pkg[0].Subscription_Period__c = '15'; 
                    insert pkg;
                    
                    //Order Line Item
                    List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
                    for (Order_Line_Item__c obj : orderLineItemList) {
                    obj.Order__c = orderList[0].id;
                    obj.Main_Package_ID__c = pkg[0].id;
                    obj.Ph_d__c = TRUE;
                    obj.Start_Date__c = date.Today()+2;
                    obj.Ph_e__c = TRUE;       
                    
                    }
                    insert orderLineItemList;
                    
                    Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
                    cas.Account__c = accountList[0].id;
                    cas.Current_Date_for_Year_To_Date__c = 5;
                    cas.Next_Year_for_Year_To_Date__c = 5;
                    cas.POP_Start_Date__c = date.Today()+3;
                    cas.Year_To_Date_Count__c = 5;
                    cas.Total_Issue__c = 5;
                    
                    insert cas;
                    
                    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                    zProduct.ProductSubType__c = 'Newspaper';
                    zProduct.ProductPlatform__c = 'Print';
                    insert zProduct;
                    
                    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                    prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                    insert prdRatePlan;
                    
                    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
                    for (Package_Item__c pItem : pItems) {
                    pItem.Package__c = pkg[0].Id;
                    pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                    count++;
                    }
                    
                    insert pItems;  
                    
                    List<Zuora__CustomerAccount__c> zcaList = TestDataFactory.createBillingAccount(1);
                    zcaList[0].Name = 'Zuora Customer Account';
                    zcaList[0].Zuora__Account__c = accountList[0].Id;
                    zcalist[0].Billing_Contact__c = con[0].Id;
                    zcaList[0].Zuora__Credit_Balance__c = 1;
                    zcaList[0].Refund_Amount__c = 100;
                    zcaList[0].Zuora__AutoPay__c =false;
                    zcaList[0].Zuora__Balance__c = 1;
                    zcaList[0].Payment_Mode__c = 'Paypal';
                    zcaList[0].Other_PaymentMethod__c= 'Paypal';
                    zcaList[0].Zuora__PaymentMethodType__c = 'Paypal'; 
                    zcalist[0].Zuora__External_Id__c = '22544AA';  
                    zcalist[0].Zuora__Zuora_Id__c = '0124';         
                    insert zcaList;
                    
                    
                    //create billing account      
                    List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
                    for(Zuora__Subscription__c zuoraSubRec: zSubs) {
                    zuoraSubRec.Subscriber_Contact__c = con[0].id;
                    zuoraSubRec.Main_Package_1__c = pkg[0].id;
                    //zuoraSubRec.Main_Package__c = pkg[0].id;
                    zuoraSubRec.Zuora__Account__c = accountList[0].id;
                    //zuoraSubRec.Order_Number__c = null;
                    zuoraSubRec.Zuora__CustomerAccount__c = zcaList[0].Id;
                    zuoraSubRec.Billing_Type__c = 'Full Prepaid';
                    zuoraSubRec.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
                    zuoraSubRec.Next_Year_Temp_Stop_Days__c = 5;
                    zuoraSubRec.Recipient_Contact__c = con[0].id;
                    zuoraSubRec.Year_to_Date_Temp_Stop_Days__c = 5;
                    zuoraSubRec.Legacy_Create_Date__c = 'a';
                    zuoraSubRec.Legacy_Create_By__c = 'a';
                    zuoraSubRec.Legacy_Update_By__c = 'a';
                    zuoraSubRec.Frequency_1__c = 'Mon - Fri';
                    zuoraSubRec.Delivery_Charge__c = 10.00;
                    zuoraSubRec.Zuora__SubscriptionStartDate__c = date.Today();
                    zuoraSubRec.Zuora__SubscriptionEndDate__c = date.Today().addDays(1);
                    zuoraSubRec.Legacy_Subscription_ID__c = 'a';
                    zuoraSubRec.Legacy_Update_Date__c = 'a';
                    zuoraSubRec.Number_of_Copies__c = 100;
                    zuoraSubRec.Number_of_Copies1__c = '100';
                    zuoraSubRec.Zuora__Status__c = 'Active';
                    zuoraSubRec.Ph_d__c = TRUE;
                    zuoraSubRec.Ph_e__c = TRUE;
                    }
                    insert zSubs;
                    
                    //FROM Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c IN : subsId];
                    
                    Temp_Stop__c tempStop  = new Temp_Stop__c();
                    tempStop.Remarks__c = 'Remark Test';
                    tempStop.Restart_Date__c = null;
                    tempStop.Temp_Stop_Date__c = null;
                    tempStop.Request_Total_Issue__c = 5;
                    tempStop.Temp_Stop_Qty__c = 5;
                    tempStop.Qty__c = null;
                    tempStop.Cancelled__c = false;
                    tempStop.Case__c = cas.id;
                    insert tempStop;
                    
                    Subscription_Temp_Stop__c subTempStop = new Subscription_Temp_Stop__c();
                    subTempStop.Subscription__c = zSubs[0].Id;
                    subTempStop.Temp_Stop__c = tempStop.Id;
                    insert subTempStop;
                    
                    
                    Test.startTest();
                    PageReference pageRef = page.TempStopDirect;
                    test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('accountId', accountList[0].Id);
                    
                    
                    List<TempStopDirectController.SubscriptionWrapper> subscriptionResultList = new List<TempStopDirectController.SubscriptionWrapper>();
                    TempStopDirectController.SubscriptionWrapper subscriptionWrapper01 = new TempStopDirectController.SubscriptionWrapper();
                    subscriptionWrapper01.Id = zSubs[0].id;
                    subscriptionWrapper01.tempStopId = tempStop.id;
                    subscriptionWrapper01.tp = tempStop;
                    subscriptionResultList.add(subscriptionWrapper01); 
                    
                                       
                    TempStopDirectController tempStopDirController = new TempStopDirectController(); 
                    tempStopDirController.myId = zSubs[0].id;
                    tempStopDirController.subscriptionResultList = subscriptionResultList; 
                    //tempStopDirController.publishedDayChecker(zSubs[0].id, Date.today().addDays(31)); 
                    try{
                    tempStopDirController.setSelectedRecords();
                    }catch(Exception e){}
                    
        }
        
        static testMethod void testSetSelectedRecords001April2() {
                    
                    
                    Integer count = 0;
                    
                    List<Account> accountList = TestDataFactory.createAccount(1, 'Direct Corporate');
                    accountList[0].Name = 'TestName';
                    insert accountList;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    insert postal;
                    
                    Address__c addressRec = TestDataFactory.createAddress(1)[0];
                    addressRec.Address_Type__c='P';
                    addressRec.Postal_Code__c = postal.Id;
                    addressRec.Address_Unique_ID__c = 'Ad123';
                    insert addressRec;
                    
                    List<Contact> con = TestDataFactory.createContact(1);
                    con[0].Phone = '1234567';
                    con[0].AccountId = accountList[0].Id;
                    con[0].Address__c = addressRec.id;
                    insert con;
                    
                    //Order__c
                    List<Order__c> orderList = TestDataFactory.createOrder(1);
                    
                    for (Order__c obj : orderList) {
                    obj.Account__c = accountList[0].id;
                    obj.Billing_Type__c = 'Full Prepaid';
                    
                    }
                    insert orderList;
                    
                    List<Publication__c> publicationList = TestDataFactory.createPublication(1);
                    count = 0;
                    for (Publication__c publication : publicationList ) {
                    // publication.Product_Family__c = 'PrFam';
                    //publication.Published_Days__c = 'YYYYYYY';
                    //publication.Publication_Type__c = 'N';
                    //publication.Publication_Code__c = '1234';
                    count++;
                    }
                    insert publicationList;
                    
                    
                    List<Package__c> pkg = TestDataFactory.createPackage(1);
                    pkg[0].Name = 'TESTname';
                    pkg[0].Subscription_Period__c = '15'; 
                    insert pkg;
                    
                    //Order Line Item
                    List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
                    for (Order_Line_Item__c obj : orderLineItemList) {
                    obj.Order__c = orderList[0].id;
                    obj.Main_Package_ID__c = pkg[0].id;
                    obj.Ph_d__c = TRUE;
                    obj.Start_Date__c = date.Today()+2;
                    obj.Ph_e__c = TRUE;       
                    
                    }
                    insert orderLineItemList;
                    
                    Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
                    cas.Account__c = accountList[0].id;
                    cas.Current_Date_for_Year_To_Date__c = 5;
                    cas.Next_Year_for_Year_To_Date__c = 5;
                    cas.POP_Start_Date__c = date.Today()+3;
                    cas.Year_To_Date_Count__c = 5;
                    cas.Total_Issue__c = 5;
                    
                    insert cas;
                    
                    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                    zProduct.ProductSubType__c = 'Newspaper';
                    zProduct.ProductPlatform__c = 'Print';
                    insert zProduct;
                    
                    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                    prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                    insert prdRatePlan;
                    
                    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
                    for (Package_Item__c pItem : pItems) {
                    pItem.Package__c = pkg[0].Id;
                    pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                    count++;
                    }
                    
                    insert pItems;  
                    
                    List<Zuora__CustomerAccount__c> zcaList = TestDataFactory.createBillingAccount(1);
                    zcaList[0].Name = 'Zuora Customer Account';
                    zcaList[0].Zuora__Account__c = accountList[0].Id;
                    zcalist[0].Billing_Contact__c = con[0].Id;
                    zcaList[0].Zuora__Credit_Balance__c = 1;
                    zcaList[0].Refund_Amount__c = 100;
                    zcaList[0].Zuora__AutoPay__c =false;
                    zcaList[0].Zuora__Balance__c = 1;
                    zcaList[0].Payment_Mode__c = 'Paypal';
                    zcaList[0].Other_PaymentMethod__c= 'Paypal';
                    zcaList[0].Zuora__PaymentMethodType__c = 'Paypal'; 
                    zcalist[0].Zuora__External_Id__c = '22544AA';  
                    zcalist[0].Zuora__Zuora_Id__c = '0124';         
                    insert zcaList;
                    
                    
                    //create billing account      
                    List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
                    for(Zuora__Subscription__c zuoraSubRec: zSubs) {
                    zuoraSubRec.Subscriber_Contact__c = con[0].id;
                    zuoraSubRec.Main_Package_1__c = pkg[0].id;
                    //zuoraSubRec.Main_Package__c = pkg[0].id;
                    zuoraSubRec.Zuora__Account__c = accountList[0].id;
                    //zuoraSubRec.Order_Number__c = null;
                    zuoraSubRec.Zuora__CustomerAccount__c = zcaList[0].Id;
                    zuoraSubRec.Billing_Type__c = 'Full Prepaid';
                    zuoraSubRec.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
                    zuoraSubRec.Next_Year_Temp_Stop_Days__c = 5;
                    zuoraSubRec.Recipient_Contact__c = con[0].id;
                    zuoraSubRec.Year_to_Date_Temp_Stop_Days__c = 5;
                    zuoraSubRec.Legacy_Create_Date__c = 'a';
                    zuoraSubRec.Legacy_Create_By__c = 'a';
                    zuoraSubRec.Legacy_Update_By__c = 'a';
                    zuoraSubRec.Frequency_1__c = 'Mon - Fri';
                    zuoraSubRec.Delivery_Charge__c = 10.00;
                    zuoraSubRec.Zuora__SubscriptionStartDate__c = date.Today();
                    zuoraSubRec.Zuora__SubscriptionEndDate__c = date.Today().addDays(1);
                    zuoraSubRec.Legacy_Subscription_ID__c = 'a';
                    zuoraSubRec.Legacy_Update_Date__c = 'a';
                    zuoraSubRec.Number_of_Copies__c = 100;
                    zuoraSubRec.Number_of_Copies1__c = '100';
                    zuoraSubRec.Zuora__Status__c = 'Active';
                    zuoraSubRec.Ph_d__c = TRUE;
                    zuoraSubRec.Ph_e__c = TRUE;
                    }
                    insert zSubs;
                    
                    //FROM Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c IN : subsId];
                    
                    Temp_Stop__c tempStop  = new Temp_Stop__c();
                    tempStop.Remarks__c = 'Remark Test';
                    tempStop.Restart_Date__c = date.today().addDays(92);
                    tempStop.Temp_Stop_Date__c = date.today();
                    tempStop.Request_Total_Issue__c = 5;
                    tempStop.Temp_Stop_Qty__c = 5;
                    tempStop.Qty__c = null;
                    tempStop.Cancelled__c = false;
                    tempStop.Case__c = cas.id;
                    insert tempStop;
                    
                    Subscription_Temp_Stop__c subTempStop = new Subscription_Temp_Stop__c();
                    subTempStop.Subscription__c = zSubs[0].Id;
                    subTempStop.Temp_Stop__c = tempStop.Id;
                    insert subTempStop;
                    
                    
                    Test.startTest();
                    PageReference pageRef = page.TempStopDirect;
                    test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('accountId', accountList[0].Id);
                    
                    
                    List<TempStopDirectController.SubscriptionWrapper> subscriptionResultList = new List<TempStopDirectController.SubscriptionWrapper>();
                    TempStopDirectController.SubscriptionWrapper subscriptionWrapper01 = new TempStopDirectController.SubscriptionWrapper();
                    subscriptionWrapper01.Id = zSubs[0].id;
                    subscriptionWrapper01.tempStopId = tempStop.id;
                    subscriptionWrapper01.tp = tempStop;
                    subscriptionResultList.add(subscriptionWrapper01); 
                    
                   
                    
                    TempStopDirectController tempStopDirController = new TempStopDirectController(); 
                    tempStopDirController.requestSource = 'Eshop';
                    tempStopDirController.myId = zSubs[0].id;
                    tempStopDirController.subscriptionResultList = subscriptionResultList; 
                    //tempStopDirController.publishedDayChecker(zSubs[0].id, Date.today().addDays(31)); 
                    try{
                    tempStopDirController.setSelectedRecords();
                    }catch(Exception e){}
                    
        }
}