/**
 * Class Name: SP_RenewalOfSubscriptionBatchProcessTest
 * @author: Accenture IDC (Shruti Kishore)
 * Date: 24/02/2015
 * Requirement/Project Name: SPH
 * @description Test Class for SP_RenewalOfSubscriptionBatchProcess
 */
@isTest
class SP_RenewalOfSubscriptionBatchProcessTest{
 
   /*static testMethod void testStart() {
    
    Test.startTest();
    
    Account acc = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
       insert acc;
       
       
       
       Package__c pack = new Package__c();
       pack = TestDataFactory.createPackage(1)[0];
       pack.Package_Type__c = 'Base';
       pack.Name = 'Test Package';
       insert pack;
       
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
       
       Country__c cntry = TestDataFactory.createCountry(1)[0];
       cntry.Account__c = acc.id;
       cntry.Zonal_Code__c = 'D';
       insert cntry;
       
       Address__c addressRec = TestDataFactory.createAddress(1)[0];
       addressRec.Address_Type__c = 'A';
       addressRec.Postal_Code__c = postal.Id;
       addressRec.Block_House_Number__c ='TEST';
       addressRec.Level_Number__c ='xx';
       addressRec.Unit_Number__c = 'yy';
       addressRec.Country__c = cntry.id;
       insert addressRec;
       
       
       Contact con = TestDataFactory.createContact(1)[0];
       con.Address__c = addressRec.Id;
       con.AccountID = acc.Id;
       con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
       con.Recipient_Indicator__c = true;
       con.Mobile_Number__c = '9096996126';
       insert con;
       
       Order__c order = TestDataFactory.createOrder(1)[0]; 
       order.Account__c = acc.id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = con.Id; 
       order.Credit_Balance__c = 800;
       order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
       order.Delivery_Charge__c = 20;
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
       insert order;
       
      
       
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderLine.Start_Date__c= date.today().addDays(1);
       orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = FALSE;
        orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        
        insert orderline;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        insert billAcc;
       
       Zuora__Subscription__c zs = new Zuora__Subscription__c();
       zs.Name='Zuora';  
       zs.Main_Package_isNull__c = 'false';
       zs.Main_Package_1__c = pack.id;
       zs.Subscription_Type_1__c = 'Publication';
       zs.Zuora__SubscriptionEndDate__c = date.today().addDays(30); 
       zs.Zuora__Zuora_Id__c ='1123';
       zs.Recipient_Contact__c= con.id;
       zs.Order_Number_1__c = order.id;
       zs.Order_Line_Item_Number_1__c = orderline.id;
       zs.Year_to_Date_Temp_Stop_Days__c = 10;
       zs.Previous_Year_Temp_Stop_Days__c= 8;
       zs.Zuora__Account__c = acc.id;
       zs.Zuora__AutoRenew__c = true;
       zs.Zuora__CustomerAccount__c = billAcc.id;
       zs.Number_of_Copies__c = 1;
       zs.Number_of_Copies1__c = '1';
       insert zs;
       List<Zuora__Subscription__c> lstSubs = new List<Zuora__Subscription__c>();
       lstSubs.add(zs);
      
     Database.BatchableContext BC;
     SP_RenewalOfSubscriptionBatchProcess sp = new SP_RenewalOfSubscriptionBatchProcess(); 
     sp.start(BC);
    
    Test.stopTest();       
    
    
    } */
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
    }  

   static testMethod void testExecute() {
   
       Integer daysBeforeEndDate = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubEndDate_RenewalOfSub'));
       Date endDate = Date.today().addDays(daysBeforeEndDate);
   
       Account acc = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
       insert acc;
       
       List<Package__c> pack = TestDataFactory.createPackage(2);
       pack[0].Package_Type__c = 'Base';
       pack[0].Name = 'Test Package';
       pack[0].Subscription_Period__c = '1';
       insert pack;
       
       Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
       postal.Name = 'SPostal';
       postal.House_Block_Number__c = 'TEST';
       postal.Address_Type__c = 'A';
       insert postal;
       
       Country__c cntry = TestDataFactory.createCountry(1)[0];
       cntry.Account__c = acc.id;
       cntry.Zonal_Code__c = 'D';
       insert cntry;
       
       Address__c addressRec = TestDataFactory.createAddress(1)[0];
       addressRec.Address_Type__c = 'A';
       addressRec.Postal_Code__c = postal.Id;
       addressRec.Block_House_Number__c ='TEST';
       addressRec.Level_Number__c ='xx';
       addressRec.Unit_Number__c = 'yy';
       addressRec.Country__c = cntry.id;
       insert addressRec;
       
       Contact con = TestDataFactory.createContact(1)[0];
       con.Address__c = addressRec.Id;
       con.AccountID = acc.Id;
       con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
       con.Recipient_Indicator__c = true;
       con.Mobile_Number__c = '9096996126';
       insert con;
       
       Order__c order = TestDataFactory.createOrder(1)[0]; 
       order.Account__c = acc.id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = con.Id; 
       order.Credit_Balance__c = 800;
       order.Order_Type__c = 'Renewal';
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Delivery_Charge__c = 20;
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       insert order;
       
       Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
       orderline.Order__c = order.Id;
       orderLine.Start_Date__c= date.today().addDays(1);
       orderline.End_Date__c = Date.Today().addDays(100);
       orderline.Main_Package_ID__c = pack[0].Id;
       orderline.Term_Length__c = 0;
       orderline.Main_Package_Period__c = 0;
       orderline.Terminating_Reason__c = 'Others';
       orderline.Amount_To_Refund__c = 0;
       orderline.Admin_Charge__c = 0;
       orderline.Fee_Waiver__c = FALSE;
       orderline.Fee_Override__c = TRUE;
       orderline.Override_Reason__c = 'TEST';
       orderline.Suppress_Notification_Stop__c = TRUE;
       orderline.Main_Package_Type__c = 'Base';
       insert orderline;
        
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       billAcc.Zuora__Account__c = acc.id;
       insert billAcc;
       
       Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
       zs.Name='Zuora';  
       zs.Main_Package_isNull__c = 'FALSE';
       zs.Main_Package_1__c = pack[0].id;
       zs.Main_Package__c = String.ValueOf(pack[0].id);
       zs.Addon_Package_1__c = pack[1].id;
       zs.Addon_Package__c = pack[1].id;
       zs.Subscription_Type_1__c = 'Publication';
       zs.Zuora__SubscriptionEndDate__c = date.today().addDays(daysBeforeEndDate); 
       zs.Zuora__Zuora_Id__c ='1123';
       zs.Recipient_Contact__c= con.id;
       zs.Order_Number_1__c = order.id;
       zs.Order_Line_Item_Number_1__c = orderline.id;
       zs.Year_to_Date_Temp_Stop_Days__c = 10;
       zs.Previous_Year_Temp_Stop_Days__c= 8;
       zs.Zuora__Account__c = acc.id;
       zs.Zuora__AutoRenew__c = true;
       zs.Zuora__CustomerAccount__c = billAcc.id;
       zs.Number_of_Copies__c = 1;
       zs.Number_of_Copies1__c = '1';
       zs.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
       insert zs;
       
       List<Zuora__Subscription__c> lstSubs = new List<Zuora__Subscription__c>();
       lstSubs.add(zs);
    
       List<Zuora__Subscription__c> listSubs = [SELECT Id, name, Main_Package_isNull__c, main_package_1__c, subscription_type_1__c, zuora__subscriptionStartDate__c,
                            zuora__subscriptionEndDate__c, Zuora__Zuora_Id__c, Recipient_Contact__c, Order_Number_1__c, Order_Line_Item_Number_1__c,
                            Year_to_Date_Temp_Stop_Days__c, Previous_Year_Temp_Stop_Days__c, Zuora__Account__c, Zuora__AutoRenew__c
                            FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active' AND  Zuora__AutoRenew__c = true
                            /*AND Zuora__SubscriptionEndDate__c = :endDate*/ AND Main_Package_isNull__c ='FALSE' AND ID =: zs.id];
                            
       System.AssertNotEquals(0, listSubs.size());
       
       zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
       zp.ProductSubType__c = 'Newspaper';
       zp.ProductPlatform__c = 'Print';
       database.insert(zp);
        
       Integer counter = 0;
       List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
       for(zqu__ProductRatePlan__c pr: prp){
            pr.zqu__ZProduct__c = zp.Id;
            if(counter==0){
                pr.RatePlanType__c = 'Bill Plan';
            }
            else{
                pr.RatePlanType__c = 'Discount';
            }
            counter++;
       }
       database.insert(prp);
       
       Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
       packItem.RecordTypeID = [SELECT Id FROM RecordType WHERE sObjectType='Package_Item__c' AND Name='Base Product'].Id;
       packItem.Package__c = pack[0].Id;
       packItem.Product_Rate_Plan__c = prp[0].Id;
       insert packItem;
                 
            Set<Id> setPackageIDs = new Set<Id>();
            Set<Id> setOldOrderIDs = new Set<Id>();
            Set<Id> setOldLineItemIDs = new Set<Id>();
            Set<String> selectiveID = new Set<String>();
            Map<Id,String> oliIDtoZuoraIDmap = new Map<Id, String>();
            
            for(Zuora__Subscription__c sub : listSubs)
            {
                setOldOrderIDs.add(sub.Order_Number_1__c); 
                setOldLineItemIDs.add(sub.Order_Line_Item_Number_1__c);
                setPackageIDs.add(sub.main_package_1__c);  
                oliIDtoZuoraIDmap.put(sub.Order_Line_Item_Number_1__c, sub.Zuora__Zuora_Id__c);
                selectiveID.add(string.valueOf(sub.Id));
            }
            //selectiveID.add(String.ValueOf(listSubs[0].Id));
            //selectiveID.add(String.ValueOf(zs.Id));
                               
        /*Database.BatchableContext BC;                   
        SP_RenewalOfSubscriptionBatchProcess spr = new SP_RenewalOfSubscriptionBatchProcess();
        spr.execute(BC,listSubs); */
        
        Test.startTest();

        SP_RenewalOfSubscriptionBatchProcess batch = new SP_RenewalOfSubscriptionBatchProcess(selectiveID);
        Id batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        
        batch.generateRenewalPackageMap(setPackageIDs);
        
        SP_RenewalOfSubscriptionBatchProcess batch2 = new SP_RenewalOfSubscriptionBatchProcess(date.today().addDays(2));
         
        SP_RenewalOfSubscriptionBatchProcess batch3 = new SP_RenewalOfSubscriptionBatchProcess();
       
        Test.stopTest();
    
    }
    
    static testMethod void testExecute2() {
   
       Integer daysBeforeEndDate = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubEndDate_RenewalOfSub'));
       Date endDate = Date.today().addDays(daysBeforeEndDate);
   
       Account acc = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
       insert acc;
       
       List<Package__c> pack = TestDataFactory.createPackage(2);
       pack[0].Package_Type__c = 'Base';
       pack[0].Name = 'Test Package';
       pack[0].Subscription_Period__c = '12';
       insert pack;
       
       Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
       postal.Name = 'SPostal';
       postal.House_Block_Number__c = 'TEST';
       postal.Address_Type__c = 'A';
       insert postal;
       
       Country__c cntry = TestDataFactory.createCountry(1)[0];
       cntry.Account__c = acc.id;
       cntry.Zonal_Code__c = 'D';
       insert cntry;
       
       Address__c addressRec = TestDataFactory.createAddress(1)[0];
       addressRec.Address_Type__c = 'A';
       addressRec.Postal_Code__c = postal.Id;
       addressRec.Block_House_Number__c ='TEST';
       addressRec.Level_Number__c ='xx';
       addressRec.Unit_Number__c = 'yy';
       addressRec.Country__c = cntry.id;
       insert addressRec;
       
       Contact con = TestDataFactory.createContact(1)[0];
       con.Address__c = addressRec.Id;
       con.AccountID = acc.Id;
       con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
       con.Recipient_Indicator__c = true;
       con.Mobile_Number__c = '9096996126';
       insert con;
       
       Order__c order = TestDataFactory.createOrder(1)[0]; 
       order.Account__c = acc.id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = con.Id; 
       order.Credit_Balance__c = 800;
       order.Order_Type__c = 'Renewal';
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Delivery_Charge__c = 20;
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       insert order;
       
       Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
       orderline.Order__c = order.Id;
       orderLine.Start_Date__c= date.today().addDays(1);
       orderline.End_Date__c = Date.Today().addDays(100);
       orderline.Main_Package_ID__c = pack[0].Id;
       orderline.Term_Length__c = 0;
       orderline.Main_Package_Period__c = 0;
       orderline.Terminating_Reason__c = 'Others';
       orderline.Amount_To_Refund__c = 0;
       orderline.Admin_Charge__c = 0;
       orderline.Fee_Waiver__c = FALSE;
       orderline.Fee_Override__c = TRUE;
       orderline.Override_Reason__c = 'TEST';
       orderline.Suppress_Notification_Stop__c = TRUE;
       orderline.Main_Package_Type__c = 'Base';
       insert orderline;
        
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       billAcc.Zuora__Account__c = acc.id;
       insert billAcc;
       
       Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
       zs.Name='Zuora';  
       zs.Main_Package_isNull__c = 'FALSE';
       zs.Main_Package_1__c = pack[0].id;
       zs.Main_Package__c = String.ValueOf(pack[0].id);
       zs.Addon_Package_1__c = pack[1].id;
       zs.Addon_Package__c = pack[1].id;
       zs.Subscription_Type_1__c = 'Publication';
       zs.Zuora__SubscriptionEndDate__c = date.today().addDays(daysBeforeEndDate); 
       zs.Zuora__Zuora_Id__c ='1123';
       zs.Recipient_Contact__c= con.id;
       zs.Order_Number_1__c = order.id;
       zs.Order_Line_Item_Number_1__c = orderline.id;
       zs.Year_to_Date_Temp_Stop_Days__c = 10;
       zs.Previous_Year_Temp_Stop_Days__c= 8;
       zs.Zuora__Account__c = acc.id;
       zs.Zuora__AutoRenew__c = true;
       zs.Zuora__CustomerAccount__c = billAcc.id;
       zs.Number_of_Copies__c = 1;
       zs.Number_of_Copies1__c = '1';
       zs.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
       insert zs;
       
       List<Zuora__Subscription__c> lstSubs = new List<Zuora__Subscription__c>();
       lstSubs.add(zs);
    
       List<Zuora__Subscription__c> listSubs = [SELECT Id, name, Main_Package_isNull__c, main_package_1__c, subscription_type_1__c, zuora__subscriptionStartDate__c,
                            zuora__subscriptionEndDate__c, Zuora__Zuora_Id__c, Recipient_Contact__c, Order_Number_1__c, Order_Line_Item_Number_1__c,
                            Year_to_Date_Temp_Stop_Days__c, Previous_Year_Temp_Stop_Days__c, Zuora__Account__c, Zuora__AutoRenew__c
                            FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active' AND  Zuora__AutoRenew__c = true
                            /*AND Zuora__SubscriptionEndDate__c = :endDate*/ AND Main_Package_isNull__c ='FALSE' AND ID =: zs.id];
                            
       System.AssertNotEquals(0, listSubs.size());
       
       zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
       zp.ProductSubType__c = 'Magazine';
       zp.ProductPlatform__c = 'Print';
       database.insert(zp);
        
       Integer counter = 0;
       List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
       for(zqu__ProductRatePlan__c pr: prp){
            pr.zqu__ZProduct__c = zp.Id;
            if(counter==0){
                pr.RatePlanType__c = 'Bill Plan';
            }
            else{
                pr.RatePlanType__c = 'Discount';
            }
            counter++;
       }
       database.insert(prp);
       
       Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
       packItem.RecordTypeID = [SELECT Id FROM RecordType WHERE sObjectType='Package_Item__c' AND Name='Base Product'].Id;
       packItem.Package__c = pack[0].Id;
       packItem.Product_Rate_Plan__c = prp[0].Id;
       insert packItem;
                 
            Set<Id> setPackageIDs = new Set<Id>();
            Set<Id> setOldOrderIDs = new Set<Id>();
            Set<Id> setOldLineItemIDs = new Set<Id>();
            Set<String> selectiveID = new Set<String>();
            Map<Id,String> oliIDtoZuoraIDmap = new Map<Id, String>();
            
            for(Zuora__Subscription__c sub : listSubs)
            {
                setOldOrderIDs.add(sub.Order_Number_1__c); 
                setOldLineItemIDs.add(sub.Order_Line_Item_Number_1__c);
                setPackageIDs.add(sub.main_package_1__c);  
                oliIDtoZuoraIDmap.put(sub.Order_Line_Item_Number_1__c, sub.Zuora__Zuora_Id__c);
                selectiveID.add(string.valueOf(sub.Id));
            }

        Test.startTest();

        SP_RenewalOfSubscriptionBatchProcess batch = new SP_RenewalOfSubscriptionBatchProcess(selectiveID);
        Id batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        
        batch.generateRenewalPackageMap(setPackageIDs);
        
        SP_RenewalOfSubscriptionBatchProcess batch2 = new SP_RenewalOfSubscriptionBatchProcess(date.today().addDays(2));
         
        SP_RenewalOfSubscriptionBatchProcess batch3 = new SP_RenewalOfSubscriptionBatchProcess();
       
        Test.stopTest();
    
    }
    
    static testMethod void testExecute3() {
   
       Integer daysBeforeEndDate = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubEndDate_RenewalOfSub'));
       Date endDate = Date.today().addDays(daysBeforeEndDate);
   
       Account acc = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
       insert acc;
       
       List<Package__c> pack = TestDataFactory.createPackage(2);
       pack[0].Package_Type__c = 'Base';
       pack[0].Name = 'Test Package';
       pack[0].Subscription_Period__c = '24';
       insert pack;
       
       Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
       postal.Name = 'SPostal';
       postal.House_Block_Number__c = 'TEST';
       postal.Address_Type__c = 'A';
       insert postal;
       
       Country__c cntry = TestDataFactory.createCountry(1)[0];
       cntry.Account__c = acc.id;
       cntry.Zonal_Code__c = 'D';
       insert cntry;
       
       Address__c addressRec = TestDataFactory.createAddress(1)[0];
       addressRec.Address_Type__c = 'A';
       addressRec.Postal_Code__c = postal.Id;
       addressRec.Block_House_Number__c ='TEST';
       addressRec.Level_Number__c ='xx';
       addressRec.Unit_Number__c = 'yy';
       addressRec.Country__c = cntry.id;
       insert addressRec;
       
       Contact con = TestDataFactory.createContact(1)[0];
       con.Address__c = addressRec.Id;
       con.AccountID = acc.Id;
       con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
       con.Recipient_Indicator__c = true;
       con.Mobile_Number__c = '9096996126';
       insert con;
       
       Order__c order = TestDataFactory.createOrder(1)[0]; 
       order.Account__c = acc.id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = con.Id; 
       order.Credit_Balance__c = 800;
       order.Order_Type__c = 'Renewal';
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Delivery_Charge__c = 20;
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       insert order;
       
       Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
       orderline.Order__c = order.Id;
       orderLine.Start_Date__c= date.today().addDays(1);
       orderline.End_Date__c = Date.Today().addDays(100);
       orderline.Main_Package_ID__c = pack[0].Id;
       orderline.Term_Length__c = 0;
       orderline.Main_Package_Period__c = 0;
       orderline.Terminating_Reason__c = 'Others';
       orderline.Amount_To_Refund__c = 0;
       orderline.Admin_Charge__c = 0;
       orderline.Fee_Waiver__c = FALSE;
       orderline.Fee_Override__c = TRUE;
       orderline.Override_Reason__c = 'TEST';
       orderline.Suppress_Notification_Stop__c = TRUE;
       orderline.Main_Package_Type__c = 'Base';
       insert orderline;
        
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       billAcc.Zuora__Account__c = acc.id;
       insert billAcc;
       
       Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
       zs.Name='Zuora';  
       zs.Main_Package_isNull__c = 'FALSE';
       zs.Main_Package_1__c = pack[0].id;
       zs.Main_Package__c = String.ValueOf(pack[0].id);
       zs.Addon_Package_1__c = pack[1].id;
       zs.Addon_Package__c = pack[1].id;
       zs.Subscription_Type_1__c = 'Publication';
       zs.Zuora__SubscriptionEndDate__c = date.today().addDays(daysBeforeEndDate); 
       zs.Zuora__Zuora_Id__c ='1123';
       zs.Recipient_Contact__c= con.id;
       zs.Order_Number_1__c = order.id;
       zs.Order_Line_Item_Number_1__c = orderline.id;
       zs.Year_to_Date_Temp_Stop_Days__c = 10;
       zs.Previous_Year_Temp_Stop_Days__c= 8;
       zs.Zuora__Account__c = acc.id;
       zs.Zuora__AutoRenew__c = true;
       zs.Zuora__CustomerAccount__c = billAcc.id;
       zs.Number_of_Copies__c = 1;
       zs.Number_of_Copies1__c = '1';
       zs.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
       insert zs;
       
       List<Zuora__Subscription__c> lstSubs = new List<Zuora__Subscription__c>();
       lstSubs.add(zs);
    
       List<Zuora__Subscription__c> listSubs = [SELECT Id, name, Main_Package_isNull__c, main_package_1__c, subscription_type_1__c, zuora__subscriptionStartDate__c,
                            zuora__subscriptionEndDate__c, Zuora__Zuora_Id__c, Recipient_Contact__c, Order_Number_1__c, Order_Line_Item_Number_1__c,
                            Year_to_Date_Temp_Stop_Days__c, Previous_Year_Temp_Stop_Days__c, Zuora__Account__c, Zuora__AutoRenew__c
                            FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active' AND  Zuora__AutoRenew__c = true
                            /*AND Zuora__SubscriptionEndDate__c = :endDate*/ AND Main_Package_isNull__c ='FALSE' AND ID =: zs.id];
                            
       System.AssertNotEquals(0, listSubs.size());
       
       zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
       zp.ProductSubType__c = 'Magazine';
       zp.ProductPlatform__c = 'Print';
       database.insert(zp);
        
       Integer counter = 0;
       List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
       for(zqu__ProductRatePlan__c pr: prp){
            pr.zqu__ZProduct__c = zp.Id;
            if(counter==0){
                pr.RatePlanType__c = 'Bill Plan';
            }
            else{
                pr.RatePlanType__c = 'Discount';
            }
            counter++;
       }
       database.insert(prp);
       
       Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
       packItem.RecordTypeID = [SELECT Id FROM RecordType WHERE sObjectType='Package_Item__c' AND Name='Base Product'].Id;
       packItem.Package__c = pack[0].Id;
       packItem.Product_Rate_Plan__c = prp[0].Id;
       insert packItem;
                 
            Set<Id> setPackageIDs = new Set<Id>();
            Set<Id> setOldOrderIDs = new Set<Id>();
            Set<Id> setOldLineItemIDs = new Set<Id>();
            Set<String> selectiveID = new Set<String>();
            Map<Id,String> oliIDtoZuoraIDmap = new Map<Id, String>();
            
            for(Zuora__Subscription__c sub : listSubs)
            {
                setOldOrderIDs.add(sub.Order_Number_1__c); 
                setOldLineItemIDs.add(sub.Order_Line_Item_Number_1__c);
                setPackageIDs.add(sub.main_package_1__c);  
                oliIDtoZuoraIDmap.put(sub.Order_Line_Item_Number_1__c, sub.Zuora__Zuora_Id__c);
                selectiveID.add(string.valueOf(sub.Id));
            }

        Test.startTest();

        SP_RenewalOfSubscriptionBatchProcess batch = new SP_RenewalOfSubscriptionBatchProcess(selectiveID);
        Id batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        
        batch.generateRenewalPackageMap(setPackageIDs);
        
        SP_RenewalOfSubscriptionBatchProcess batch2 = new SP_RenewalOfSubscriptionBatchProcess(date.today().addDays(2));
         
        SP_RenewalOfSubscriptionBatchProcess batch3 = new SP_RenewalOfSubscriptionBatchProcess();
       
        Test.stopTest();
    }
    static testMethod void testExecute4() {
        Integer daysBeforeEndDate = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubEndDate_RenewalOfSub'));
       Date endDate = Date.today().addDays(daysBeforeEndDate);
   
       Account acc = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
       insert acc;
       
       List<Package__c> pack = TestDataFactory.createPackage(2);
       pack[0].Package_Type__c = 'Base';
       pack[0].Name = 'Test Package';
       pack[0].Subscription_Period__c = '24';
       insert pack;
       
       Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
       postal.Name = 'SPostal';
       postal.House_Block_Number__c = 'TEST';
       postal.Address_Type__c = 'A';
       insert postal;
       
       Zone__c zo = new Zone__c();
       zo.Name = 'R';
       insert zo;
       
       Country__c cntry = TestDataFactory.createCountry(1)[0];
       cntry.Account__c = acc.id;
       cntry.Zonal_Code__c = 'D';
       cntry.Zone__c = zo.Id;
       insert cntry;
       
       Address__c addressRec = TestDataFactory.createAddress(1)[0];
       addressRec.Address_Type__c = 'A';
       addressRec.Postal_Code__c = postal.Id;
       addressRec.Block_House_Number__c ='TEST';
       addressRec.Level_Number__c ='xx';
       addressRec.Unit_Number__c = 'yy';
       addressRec.Country__c = cntry.id;
       insert addressRec;
       
       Contact con = TestDataFactory.createContact(1)[0];
       con.Address__c = addressRec.Id;
       con.AccountID = acc.Id;
       con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
       con.Recipient_Indicator__c = true;
       con.Mobile_Number__c = '9096996126';
       insert con;
       
       Order__c order = TestDataFactory.createOrder(1)[0]; 
       order.Account__c = acc.id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = con.Id; 
       order.Credit_Balance__c = 800;
       order.Order_Type__c = 'Renewal';
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Delivery_Charge__c = 20;
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       insert order;
       
       Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
       orderline.Order__c = order.Id;
       orderLine.Start_Date__c= date.today().addDays(1);
       orderline.End_Date__c = Date.Today().addDays(100);
       orderline.Main_Package_ID__c = pack[0].Id;
       orderline.Term_Length__c = 0;
       orderline.Main_Package_Period__c = 0;
       orderline.Terminating_Reason__c = 'Others';
       orderline.Amount_To_Refund__c = 0;
       orderline.Admin_Charge__c = 0;
       orderline.Fee_Waiver__c = FALSE;
       orderline.Fee_Override__c = TRUE;
       orderline.Override_Reason__c = 'TEST';
       orderline.Suppress_Notification_Stop__c = TRUE;
       orderline.Main_Package_Type__c = 'Base';
       insert orderline;
        
       Order_Line_Item__c orderline1 = TestDataFactory.createOrderLineItem(1)[0];
       orderline1.Order__c = order.Id;
       orderLine1.Start_Date__c= date.today().addDays(1);
       orderline1.End_Date__c = Date.Today().addDays(100);
       orderline1.Main_Package_ID__c = pack[0].Id;
       orderline1.Term_Length__c = 0;
       orderline1.Main_Package_Period__c = 0;
       orderline1.Terminating_Reason__c = 'Others';
       orderline1.Amount_To_Refund__c = 0;
       orderline1.Admin_Charge__c = 0;
       orderline1.Fee_Waiver__c = FALSE;
       orderline1.Fee_Override__c = TRUE;
       orderline1.Override_Reason__c = 'TEST';
       orderline1.Suppress_Notification_Stop__c = TRUE;
       orderline1.Main_Package_Type__c = 'Base';
       insert orderline1;
       
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       billAcc.Zuora__Account__c = acc.id;
       insert billAcc;
       
       Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
       zs.Name='Zuora';  
       zs.Main_Package_isNull__c = 'FALSE';
       zs.Main_Package_1__c = pack[0].id;
       zs.Main_Package__c = String.ValueOf(pack[0].id);
       zs.Addon_Package_1__c = pack[1].id;
       zs.Addon_Package__c = pack[1].id;
       zs.Subscription_Type_1__c = 'Publication';
       zs.Zuora__SubscriptionEndDate__c = date.today().addDays(daysBeforeEndDate); 
       zs.Zuora__Zuora_Id__c ='1123';
       zs.Recipient_Contact__c= con.id;
       zs.Order_Number_1__c = order.id;
       zs.Order_Line_Item_Number_1__c = orderline.id;
       zs.Year_to_Date_Temp_Stop_Days__c = 10;
       zs.Previous_Year_Temp_Stop_Days__c= 8;
       zs.Zuora__Account__c = acc.id;
       zs.Zuora__AutoRenew__c = true;
       zs.Zuora__CustomerAccount__c = billAcc.id;
       zs.Number_of_Copies__c = 1;
       zs.Number_of_Copies1__c = '1';
       zs.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
       insert zs;
       
       List<Zuora__Subscription__c> lstSubs = new List<Zuora__Subscription__c>();
       lstSubs.add(zs);
    
       List<Zuora__Subscription__c> listSubs = [SELECT Id, name, Main_Package_isNull__c, main_package_1__c, subscription_type_1__c, zuora__subscriptionStartDate__c,
                            zuora__subscriptionEndDate__c, Zuora__Zuora_Id__c, Recipient_Contact__c, Order_Number_1__c, Order_Line_Item_Number_1__c,
                            Year_to_Date_Temp_Stop_Days__c, Previous_Year_Temp_Stop_Days__c, Zuora__Account__c, Zuora__AutoRenew__c
                            FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active' AND  Zuora__AutoRenew__c = true
                            /*AND Zuora__SubscriptionEndDate__c = :endDate*/ AND Main_Package_isNull__c ='FALSE' AND ID =: zs.id];
                            
       System.AssertNotEquals(0, listSubs.size());
       
       zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
       zp.ProductSubType__c = 'Magazine';
       zp.ProductPlatform__c = 'Print';
       database.insert(zp);
        
       Integer counter = 0;
       List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
       for(zqu__ProductRatePlan__c pr: prp){
            pr.zqu__ZProduct__c = zp.Id;
            if(counter==0){
                pr.RatePlanType__c = 'Bill Plan';
            }
            else{
                pr.RatePlanType__c = 'Discount';
            }
            counter++;
       }
       database.insert(prp);
       
       Zone_Product__c zp1 = new Zone_Product__c();
       zp1.Product__c = zp.Id;
       zp1.Postage_Charge__c = 5.9;
       zp1.Effective_Start_Date__c = Date.Today();
       zp1.Zone__c = zo.Id;
       insert zp1;
       
       Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
       packItem.RecordTypeID = [SELECT Id FROM RecordType WHERE sObjectType='Package_Item__c' AND Name='Base Product'].Id;
       packItem.Package__c = pack[0].Id;
       packItem.Product_Rate_Plan__c = prp[0].Id;
       insert packItem;
       
       Set<Id> oldItmIds = new Set<Id>();
       Set<Id> packageIds = new Set<Id>();
       packageIds.add(packItem.Id);
       oldItmIds.add(orderline.Id);
       oldItmIds.add(orderline1.Id);
       Map<Id,Id> ordercontactMap = new Map<Id,Id>();
       ordercontactMap.put(order.Id, order.Recipient_Contact__c);
       Map<Id,sObject> mapOldOrderIdToNewOrder = new Map<Id,sObject>();
       mapOldOrderIdToNewOrder.put(order.Id,order);
       
       Test.StartTest();
       SP_RenewalOfSubscriptionBatchProcess sp_subscriptionrenewal = new SP_RenewalOfSubscriptionBatchProcess();
       sp_subscriptionrenewal.cloneExistingItems(oldItmIds, packageIds, mapOldOrderIdToNewOrder, ordercontactMap);
       Test.stopTest();
       
       
       
       
    }
}