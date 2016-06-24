@isTest (Seealldata = false)
public class SP_MidMonthTempStopBatch_SelectAccsTest{
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    
    static void defaultCustomSetting(){
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ ){
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        //List<Other__c> otherList = new List<Other__c>();
        //for(Integer i = 0 ; i < orderCNameArray.size(); i++ ){
        //    otherC = new Other__c();
        //    otherC.Name = orderCNameArray[i];
        //    otherC.Value__c = orderCValueArray[i];
        //    otherList.add(otherC);
        //}
        //insert otherList;
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
        cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
        cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
        cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
        cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
        cirPlannerSchedule.Sun_Start_Time__c = System.Now();
        cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
        cirPlannerSchedule.Name = 'CIR Plan Schedule';
        insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
    }

    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       //Generate a map of tokens for all the Record Types for the desired object
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

       //Retrieve the record type id by name
       return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }

    static testmethod void test01(){
        defaultCustomSetting();
        
        //Key_Id__c key = new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', 
        //                              Id__c = '012N00000008ibwIAA', 
        //                              Type__c = 'Record Type');
        //insert key;
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c(Name = 'CIR Plan Schedule1',
                                                                  Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0),
                                                                  Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0),
                                                                  Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0),
                                                                  Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0),
                                                                  Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0),
                                                                  Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0));
        insert(cir);

        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c(Name = 'Endpoint Delegator',
                                                                                          Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator');
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c(Name = 'A',
                                                                      Default_Delivery_Charge_Type__c = 'C');
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c(Name ='AC',
                                                              Vendor_Credit__c = 9.00,
                                                              Subscriber_Charge__c = 9.00);
        insert delCharge;
        
        //Other__c otherrec = new Other__c(Name='Name', 
        //                                 Value__c='23:59');
        //insert(otherrec);
        
        Date_Configuration__c dateconfi = new Date_Configuration__c(Name = 'name',
                                                                    Date__c = date.Today());
        insert dateconfi;
    
        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = getObjectRecordTypeId(Account.SObjectType,'Direct Corporate'),
                                  Email__c = 'sample@email.com',
                                  Mobile__c = '1234567',
                                  AccountNumber = 'subscriberId',
                                  Contact_Person__c = 'Contact Person');
        insert acc;

        //Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //insert(acc);

        Country__c countryRecord = new Country__c(Name = 'Test Country', 
                                                   Country_Name__c = 'Country Test');
        insert countryRecord;

        Address__c addressRecord = new Address__c(Name = 'Test Address', 
                                                  Country__c = countryRecord.id);   
        insert addressRecord;
		
        Key_Id__c keyId = new Key_Id__c();
        	keyId.Name = 'NEXT_RECIPIENT_NUMBER';
        	keyId.Id__c = '30465967';
       	insert keyId;

        Contact con = new Contact(AccountId = acc.Id,
                                  FirstName = 'Test',
                                  LastName = 'Account',
                                  Phone = '0917911312',
                                  Recipient_Indicator__c = true,
                                  Address__c = addressRecord.Id);
        insert con;
        
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Name = 'Test Billing Account',
                                                                          Zuora__Account__c = acc.id,
                                                                          Billing_Contact__c = con.id,
                                                                          Zuora__Status__c = 'Active');
        insert billAcc;
        
        Package__c packageRecord = new Package__c(Name = 'Test Package', 
                                                  Package_Type__c = 'Grace Period',
                                                  Subscription_Type__c = 'Termed', 
                                                  Package_Code__c = 'PackageCode',
                                                  Effective_Start_Date__c = date.today(), 
                                                  Effective_End_Date__c = date.today()+100, 
                                                  Subscription_Period__c = '1');
        insert packageRecord;
        
        Other__c othr = new Other__c();
        	othr.Name = 'DTL';
        	othr.Value__c = '23:59';
       	insert othr;
        
        Other__c othr2 = new Other__c();
          othr2.Name = 'Order_Type Renewal';
          othr2.Value__c = 'Renewal';
        insert othr2;

        Zuora__Subscription__c subscriptionRecord1 = new Zuora__Subscription__c(Name = 'Test Subscription', 
                                                        Zuora__Zuora_Id__c = 'ZID',
                                                        Next_Earliest_Start_Date__c = date.today()+30,
                                                        Unique_Address_Id__c = 'UAID00000', 
                                                        Zuora__Version__c = 1, 
                                                        Delivery_Charge__c = 200.00, 
                                                        Vendor_Credit_1__c = 20000.00,
                                                        Term_Length__c = 10, 
                                                        Number_of_Copies__c = 3, 
                                                        Zuora__SubscriptionEndDate__c = date.today()+100,
                                                        Zuora__SubscriptionStartDate__c = date.today(),  
                                                        Legacy_Create_By__c = 'User', 
                                                        Legacy_Create_Date__c = '10/24/2014',
                                                        Legacy_Subscription_ID__c = 'LSUB00000', 
                                                        Legacy_Update_By__c = 'User',
                                                        Legacy_Update_Date__c = '10/24/2014', 
                                                        Number_of_Copies1__c = '1',
                                                        Zuora__CustomerAccount__c = billAcc.Id,
                                                        Main_Package_1__c = packageRecord.Id,
                                                        Zuora__Account__c = acc.Id,
                                                        Subscription_Type_1__c = 'Publication',
                                                        Recipient_Contact__c = con.Id);
        insert subscriptionRecord1;
        
        Order__c orderRecord = new Order__c(Credit_Balance__c = 20000.00, 
                                            Delivery_Charge__c = 100.00,
                                            Monthly_Delivery_Charge_for_Full_Payment__c = 100.00,
                                            Account__c = acc.Id,
                                            Informed_Customer__c = TRUE,
                                            Recipient_Contact__c = con.Id,
                                            Subscriber_Account__c = acc.Id,
                                            Base_Subscription__c = subscriptionRecord1.Id);
        insert orderRecord;
        
        Temp_Stop__c temp = new Temp_Stop__c(Restart_Date__c = date.today()+10,
                                             Temp_Stop_Date__c = date.today()+1,
                                             Qty__c = 3,
                                             Cancelled__c = false);
        insert(temp);
        
        Case cas = new Case(Order__c = orderRecord.Id,
                            Temp_Stop__c = temp.Id,
                            Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31),
                            Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 12, 31),
                            Temp_Stop_Type__c = 'new');
        insert(cas);

        zqu__ZProduct__c zProductRecord = new zqu__ZProduct__c(Name='Test Quote Wizard', 
                                                               zqu__SKU__c='SKU',
                                                               ProductCode__c='Product Code', 
                                                               zqu__ZuoraId__c='ZID',
                                                               ProductType__c='Product Type',
                                                               ProductPlatform__c = 'All-In-One'); 
        insert zProductRecord;

        zqu__ProductRatePlan__c productRatePlanRecord = new zqu__ProductRatePlan__c(Name = 'Test Product Rate Plan', 
                                                                                    RatePlanCode__c = 'TestRatePlan',
                                                                                    zqu__ZuoraId__c = 'ZID', 
                                                                                    RatePlanType__c = 'Proration',
                                                                                    zqu__ZProduct__c = zProductRecord.Id);
        insert productRatePlanRecord;

        zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge', 
                                                                                                       zqu__ZuoraId__c = 'ZID',
                                                                                                       zqu__ProductRatePlan__c = productRatePlanRecord.Id);
        insert productRatePlanChargeRecord;

        Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item', 
                                                                RecordTypeId = getObjectRecordTypeId(Package_Item__c.SObjectType,'Base Product'),
                                                                Package__c = packageRecord.Id,
                                                                Bundle_Item_No__c = 8,
                                                                Duration_in_months__c='10',
                                                                Effective_Start_Month__c='1',
                                                                Product_Rate_Plan__c = productRatePlanRecord.Id);
        insert packageItemRecord;  

        Order_Line_Item__c orderline = new Order_Line_Item__c(Order__c = orderRecord.Id,
                                                              Main_Package_ID__c = packageRecord.Id,
                                                              Term_Length__c = 0,
                                                              Main_Package_Period__c = 0,
                                                              Earliest_Start_Date__c = date.today(),
                                                              Earliest_Stop_Date__c =date.newInstance(2016, 12, 2),
                                                              Stop_Request_Date__c = date.newInstance(2016, 12, 2),
                                                              Terminating_Reason__c = 'Others',
                                                              Amount_To_Refund__c = 0,
                                                              Admin_Charge__c = 0,
                                                              Fee_Override__c = TRUE,
                                                              Override_Reason__c = 'TEST',
                                                              Suppress_Notification_Stop__c = TRUE,
                                                              Delivered_By__c = 'Vendor',
                                                              Main_Package_Type__c = 'Base',
                                                              Start_Date__c = date.today(),
                                                              Main_Package_Billing_Type__c = 'Full Prepaid',
                                                              End_Date__c = date.newInstance(2016, 12, 2));
        insert orderline;

        Zuora__Subscription__c subscriptionRecord = new Zuora__Subscription__c(Name = 'Test Subscription', 
                                                        Zuora__Zuora_Id__c = 'ZID',
                                                        Next_Earliest_Start_Date__c = date.today()+30,
                                                        Unique_Address_Id__c = 'UAID00000', 
                                                        Zuora__Version__c = 1, 
                                                        Delivery_Charge__c = 200.00, 
                                                        Vendor_Credit_1__c = 20000.00,
                                                        Term_Length__c = 10, 
                                                        Number_of_Copies__c = 3, 
                                                        Zuora__SubscriptionEndDate__c = date.today()+100,
                                                        Zuora__SubscriptionStartDate__c = date.today(),  
                                                        Legacy_Create_By__c = 'User', 
                                                        Legacy_Create_Date__c = '10/24/2014',
                                                        Legacy_Subscription_ID__c = 'LSUB00000', 
                                                        Legacy_Update_By__c = 'User',
                                                        Legacy_Update_Date__c = '10/24/2014', 
                                                        Number_of_Copies1__c = '1',
                                                        Zuora__CustomerAccount__c = billAcc.Id,
                                                        Main_Package_1__c = packageRecord.Id,
                                                        Zuora__Account__c = acc.Id,
                                                        Subscription_Type_1__c = 'Publication',
                                                        Recipient_Contact__c = con.Id,
                                                        Order_Line_Item_Number_1__c = orderline.Id);
        insert subscriptionRecord;
         
        List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 

        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c(Temp_Stop__c = temp.Id,
                                                                          Subscription__c = subscriptionRecord.Id);
        subtempstopList.add(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c(Temp_Stop__c = temp.Id,
                                                                           Subscription__c = subscriptionRecord.Id);
        subtempstopList.add(subTemp2); 
        insert subtempstopList;

            
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);

        Zuora__SubscriptionProductCharge__c subProductChargeRecord = new Zuora__SubscriptionProductCharge__c(Name='Credit Copy1', 
                                                                                                             Zuora__Zuora_Id__c='ZID',
                                                                                                             Zuora__Subscription__c = subscriptionRecord.Id,
                                                                                                             PublicationCode__c = '01');
        spc.add(subProductChargeRecord);

        Zuora__SubscriptionProductCharge__c subProductChargeRecord1 = new Zuora__SubscriptionProductCharge__c(Name='Credit Copy2', 
                                                                                                             Zuora__Zuora_Id__c='ZID',
                                                                                                             Zuora__Subscription__c = subscriptionRecord.Id,
                                                                                                             PublicationCode__c = '02');
        spc.add(subProductChargeRecord1);
        insert spc;
          
        Usage__c usage = new Usage__c(Subscription_Temp_Stop__c = subTemp2.Id,
                                      UOM__c = 'Credit Copy',
                                      Quantity__c = 3);
        insert(usage);
         
        Set<String> accntSet = new Set<string>();
        accntSet.add('acc.Id');
        
        list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, 
                                                           Subscription__c, Subscription__r.Zuora__Account__c, Subscription__r.Name, 
                                                           Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                                                           Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, 
                                                           Subscription__r.Number_of_Copies__c,Subscription__r.Ph_d__c, Subscription__r.Ph_e__c 
                                                    FROM Subscription_Temp_Stop__c 
                                                    WHERE Id =: subTemp.Id];  

        test.startTest();
            Database.BatchableContext bc;
            SP_MidMonthTempStopBatch_SelectAccs  batch = new SP_MidMonthTempStopBatch_SelectAccs(accntSet);
            id batchID = database.executeBatch(batch, 200);
            batch.execute(bc, listtemp);
            //SP_MidMonthTempStopBatch_SelectAccs  batch1 = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
        test.stopTest();
      }
      
    //static testmethod void test02(){
    //    defaultCustomSetting();

    //    Key_Id__c key = new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', Id__c = '123462697', Type__c = 'Number');
    //    insert key;

    //    Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
    //    cir.Name = 'CIR Plan Schedule';
    //    cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
    //    cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
    //    cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //    cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
    //    cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //    cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //    database.insert(cir);

    //    List<Other__c> otherList = new List<Other__c>{
    //        new Other__c(Name='Name', Value__c='23:59')
    //    };
    //    database.insert(otherList);

    //    BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
    //    bs.Name = 'Endpoint Delegator';
    //    bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
    //    database.insert(bs);

    //    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //    database.insert(acc);

    //    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    //    billAcc.Zuora__Account__c = acc.Id;
    //    billAcc.Zuora__AccountNumber__c = '123';
    //    database.insert(billAcc);

    //    Address__c address = TestDataFactory.createAddress(1)[0];
    //    database.insert(address);

    //    Contact con = TestDataFactory.createContact(1)[0];
    //    con.AccountId = acc.id;
    //    con.Address__c = address.Id;
    //    //con.Billing_Indicator__c = True;
    //    con.Recipient_Indicator__c = true;
    //    database.insert(con);  

    //    Package__c pack = TestDataFactory.createPackage(1)[0];
    //    database.insert(pack);
    //    pack.Package_Type__c = 'Grace Period';
    //    pack.Subscription_Period__c='1';
    //    update pack;

    //    Order__c orderRec = TestDataFactory.createOrder(1)[0];
    //    orderRec.Account__c = acc.Id;
    //    orderRec.Informed_Customer__c = TRUE;
    //    orderRec.Recipient_Contact__c = con.Id;
    //    database.insert(orderRec);

    //    /*Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
    //    cas.Order__c = orderRec.Id;
    //    database.insert(cas);*/

    //    List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
    //    temp[0].Restart_Date__c =  referenceDate.addMonths(2).toStartofMonth().addDays(-1);
    //    temp[0].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
    //    temp[0].Qty__c = 3;
    //    temp[0].Cancelled__c  = false;

    //    temp[1].Restart_Date__c = referenceDate.addMonths(1).toStartofMonth().addDays(-10);
    //    temp[1].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
    //    temp[1].Qty__c = 3;
    //    temp[1].Cancelled__c  = false;
    //    database.insert(temp);

    //    //system.assertEquals(null, temp[0].Temp_Stop_Status__c);

    //    zqu__ZProduct__c zProductRecord = new zqu__ZProduct__c(Name='Test Quote Wizard', 
    //                                                           zqu__SKU__c='SKU',
    //                                                           ProductCode__c='Product Code', 
    //                                                           zqu__ZuoraId__c='ZID',
    //                                                           ProductType__c='Product Type',
    //                                                           ProductPlatform__c = 'All-In-One'
    //                                                           ); 
    //    insert zProductRecord;

    //    zqu__ProductRatePlan__c productRatePlanRecord = new zqu__ProductRatePlan__c(Name = 'Test Product Rate Plan', 
    //                                                                                RatePlanCode__c = 'TestRatePlan',
    //                                                                                zqu__ZuoraId__c = 'ZID', 
    //                                                                                RatePlanType__c = 'Proration',
    //                                                                                zqu__ZProduct__c = zProductRecord.Id);
    //    insert productRatePlanRecord;
            
    //    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
    //    prpc.zqu__ProductRatePlan__c = productRatePlanRecord.Id;
    //    database.insert(prpc);
            
    //    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    //    for (Package_Item__c pItem : pItems) {
    //        pItem.Package__c = pack.Id;
    //        pItem.Product_Rate_Plan__c = productRatePlanRecord.Id;
    //        //pItem.Is_All_In_One__c = true;
    //    }
    //    database.insert(pItems);

    //    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
    //    subRecs[0].Zuora__Account__c = acc.Id;
    //    subRecs[0].Name = 'TestName';
    //    subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
    //    subRecs[0].Order_Number_1__c = orderRec.Id;
    //    subRecs[0].Order_Number__c = orderRec.Id;
    //    subRecs[0].Term_Length__c = 0;
    //    subRecs[0].Term_Length1__c = '0';
    //    subRecs[0].Main_Package_1__c = pack.Id;
    //    subRecs[0].Main_Package__c = pack.Id;
    //    subRecs[0].Zuora__SubscriptionStartDate__c = Date.Today();
    //    subRecs[0].Zuora__SubscriptionEndDate__c = date.Today()+1;
    //    subRecs[0].Recipient_Contact__c = con.Id;
    //    subRecs[0].Zuora__Status__c = 'Active';
    //    subRecs[0].Frequency_1__c = 'Default';
    //    subRecs[0].Frequency__c = 'Default';
    //    subRecs[1].Name = 'TestName';
    //    subRecs[1].Zuora__Account__c = acc.Id;
    //    subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
    //    subRecs[1].Order_Number_1__c = orderRec.Id;
    //    subRecs[1].Order_Number__c = orderRec.Id;
    //    subRecs[1].Term_Length__c = 0;
    //    subRecs[1].Term_Length1__c = '0';
    //    subRecs[1].Zuora__SubscriptionStartDate__c = Date.Today();
    //    subRecs[1].Zuora__SubscriptionEndDate__c = date.Today()+1;
    //    subRecs[1].Recipient_Contact__c = con.Id;
    //    subRecs[1].Zuora__Status__c = 'Active';
    //    subRecs[1].Frequency_1__c = 'Default';
    //    subRecs[1].Frequency__c = 'Default';
    //    database.insert(subRecs);
         
    //    List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 
    //    Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
    //    subTemp.Temp_Stop__c = temp[0].Id;
    //    subTemp.Subscription__c = subRecs[0].Id;
    //    database.insert(subTemp);

    //    Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
    //    subTemp2.Temp_Stop__c = temp[1].Id;
    //    subTemp2.Subscription__c = subRecs[1].Id;
    //    database.insert(subTemp2);
            
    //    List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
    //    spc[0].Zuora__Subscription__c = subRecs[0].Id;
    //    spc[0].PublicationCode__c = '01';
    //    spc[0].Name = 'Credit Copy';

    //    spc[1].Zuora__Subscription__c = subRecs[1].Id;
    //    spc[1].PublicationCode__c = '01';
    //    spc[1].Name = 'Credit Copy';

    //    database.insert(spc);
          
    //    Usage__c usage = new Usage__c();
    //    usage.Subscription_Temp_Stop__c = subTemp2.Id;
    //    usage.UOM__c = 'Credit Copy';
    //    usage.Quantity__c = 3;
    //    database.insert(usage);
         
    //    set<String> AccntSet = new set<string>();
    //    AccntSet.add('acc.Id');
    //    subtempstopList.add(subTemp);
    //    subtempstopList.add(subTemp2);    

    //    list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__c, 
    //    Subscription__r.Zuora__Account__c, Subscription__r.Name, Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
    //    Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Subscription__r.Number_of_Copies__c,
    //    Subscription__r.Ph_d__c, Subscription__r.Ph_e__c FROM Subscription_Temp_Stop__c WHERE Id =: subTemp.Id];   
    //    test.startTest();
    //        Database.BatchableContext bc;
    //        SP_MidMonthTempStopBatch_SelectAccs  batch = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
    //        id batchID = database.executeBatch(batch, 200);
    //        batch.execute(bc, listtemp);
    //        system.assert(batchId<>null);
    //        //SP_MidMonthTempStopBatch_SelectAccs  batch1 = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
    //    test.stopTest();
    //}
      
    //static testmethod void test03(){
    //    defaultCustomSetting();

    //    Key_Id__c key = new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', Id__c = '123462697', Type__c = 'Number');
    //    insert key;

    //    Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
    //    cir.Name = 'CIR Plan Schedule';
    //    cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
    //    cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
    //    cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //    cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
    //    cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //    cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
    //    database.insert(cir);

    //    List<Other__c> otherList = new List<Other__c>{
    //        new Other__c(Name='Name', Value__c='23:59')
    //    };
    //    database.insert(otherList);

    //    BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
    //    bs.Name = 'Endpoint Delegator';
    //    bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
    //    database.insert(bs);

    //    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //    database.insert(acc);

    //    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    //    billAcc.Zuora__Account__c = acc.Id;
    //    billAcc.Zuora__AccountNumber__c = '123';
    //    database.insert(billAcc);

    //    Address__c address = TestDataFactory.createAddress(1)[0];
    //    database.insert(address);

    //    Contact con = TestDataFactory.createContact(1)[0];
    //    con.AccountId = acc.id;
    //    con.Address__c = address.Id;
    //    //con.Billing_Indicator__c = True;
    //    con.Recipient_Indicator__c = true;
    //    database.insert(con);  

    //    Package__c pack = TestDataFactory.createPackage(1)[0];
    //    database.insert(pack);
    //    pack.Package_Type__c = 'Grace Period';
    //    pack.Subscription_Period__c='1';
    //    update pack;

    //    Order__c orderRec = TestDataFactory.createOrder(1)[0];
    //    orderRec.Account__c = acc.Id;
    //    orderRec.Informed_Customer__c = TRUE;
    //    orderRec.Recipient_Contact__c = con.Id;
    //    database.insert(orderRec);

    //    /*Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
    //    cas.Order__c = orderRec.Id;
    //    database.insert(cas);*/

    //    List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
    //    temp[0].Restart_Date__c =  referenceDate.toStartOfMonth();//referenceDate.addMonths(2).toStartofMonth().addDays(-1);
    //    temp[0].Temp_Stop_Date__c = referenceDate.addMonths(-2).toStartofMonth().addDays(-1);//referenceDate.toStartOfMonth();
    //    temp[0].Qty__c = 3;
    //    temp[0].Cancelled__c  = false;

    //    temp[1].Restart_Date__c = referenceDate.addMonths(1).toStartofMonth().addDays(-10);
    //    temp[1].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
    //    temp[1].Qty__c = 3;
    //    temp[1].Cancelled__c  = false;
    //    database.insert(temp);

    //    //system.assertEquals(null, temp[0].Temp_Stop_Status__c);

    //    zqu__ZProduct__c zProductRecord = new zqu__ZProduct__c(Name='Test Quote Wizard', 
    //                                                           zqu__SKU__c='SKU',
    //                                                           ProductCode__c='Product Code', 
    //                                                           zqu__ZuoraId__c='ZID',
    //                                                           ProductType__c='Product Type',
    //                                                           ProductPlatform__c = 'All-In-One'
    //                                                           ); 
    //    insert zProductRecord;

    //    zqu__ProductRatePlan__c productRatePlanRecord = new zqu__ProductRatePlan__c(Name = 'Test Product Rate Plan', 
    //                                                                                RatePlanCode__c = 'TestRatePlan',
    //                                                                                zqu__ZuoraId__c = 'ZID', 
    //                                                                                RatePlanType__c = 'Proration',
    //                                                                                zqu__ZProduct__c = zProductRecord.Id);
    //    insert productRatePlanRecord;
            
    //    zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
    //    prpc.zqu__ProductRatePlan__c = productRatePlanRecord.Id;
    //    database.insert(prpc);
            
    //    List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
    //    for (Package_Item__c pItem : pItems) {
    //        pItem.Package__c = pack.Id;
    //        pItem.Product_Rate_Plan__c = productRatePlanRecord.Id;
    //        //pItem.Is_All_In_One__c = true;
    //    }
    //    database.insert(pItems);

    //    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
    //    subRecs[0].Zuora__Account__c = acc.Id;
    //    subRecs[0].Name = 'TestName';
    //    subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
    //    subRecs[0].Order_Number_1__c = orderRec.Id;
    //    subRecs[0].Order_Number__c = orderRec.Id;
    //    subRecs[0].Term_Length__c = 0;
    //    subRecs[0].Term_Length1__c = '0';
    //    subRecs[0].Main_Package_1__c = pack.Id;
    //    subRecs[0].Main_Package__c = pack.Id;
    //    subRecs[0].Zuora__SubscriptionStartDate__c = Date.Today();
    //    subRecs[0].Zuora__SubscriptionEndDate__c = date.Today()+1;
    //    subRecs[0].Recipient_Contact__c = con.Id;
    //    subRecs[0].Zuora__Status__c = 'Active';
    //    subRecs[0].Frequency_1__c = 'Default';
    //    subRecs[0].Frequency__c = 'Default';
    //    subRecs[1].Name = 'TestName';
    //    subRecs[1].Zuora__Account__c = acc.Id;
    //    subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
    //    subRecs[1].Order_Number_1__c = orderRec.Id;
    //    subRecs[1].Order_Number__c = orderRec.Id;
    //    subRecs[1].Term_Length__c = 0;
    //    subRecs[1].Term_Length1__c = '0';
    //    subRecs[1].Zuora__SubscriptionStartDate__c = Date.Today();
    //    subRecs[1].Zuora__SubscriptionEndDate__c = date.Today()+1;
    //    subRecs[1].Recipient_Contact__c = con.Id;
    //    subRecs[1].Zuora__Status__c = 'Active';
    //    subRecs[1].Frequency_1__c = 'Default';
    //    subRecs[1].Frequency__c = 'Default';
    //    database.insert(subRecs);

    //    List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 
    //    Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
    //    subTemp.Temp_Stop__c = temp[0].Id;
    //    subTemp.Subscription__c = subRecs[0].Id;
    //    database.insert(subTemp);

    //    Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
    //    subTemp2.Temp_Stop__c = temp[1].Id;
    //    subTemp2.Subscription__c = subRecs[1].Id;
    //    database.insert(subTemp2);
            
    //    List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
    //    spc[0].Zuora__Subscription__c = subRecs[0].Id;
    //    spc[0].PublicationCode__c = '01';
    //    spc[0].Name = 'Credit Copy';

    //    spc[1].Zuora__Subscription__c = subRecs[1].Id;
    //    spc[1].PublicationCode__c = '01';
    //    spc[1].Name = 'Credit Copy';

    //    database.insert(spc);
          
    //    Usage__c usage = new Usage__c();
    //    usage.Subscription_Temp_Stop__c = subTemp.Id;
    //    usage.UOM__c = 'Credit Copy';
    //    usage.Quantity__c = 3;
    //    database.insert(usage);
         
    //    set<String> AccntSet = new set<string>();
    //    AccntSet.add('acc.Id');
    //    subtempstopList.add(subTemp);
    //    subtempstopList.add(subTemp2);    

    //    list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__c, 
    //    Subscription__r.Zuora__Account__c, Subscription__r.Name, Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
    //    Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Subscription__r.Number_of_Copies__c,
    //    Subscription__r.Ph_d__c, Subscription__r.Ph_e__c FROM Subscription_Temp_Stop__c WHERE Id =: subTemp.Id];   

    //    test.startTest();
    //        Database.BatchableContext bc;
    //        SP_MidMonthTempStopBatch_SelectAccs  batch = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
    //        id batchID = database.executeBatch(batch, 200);
    //        batch.execute(bc, listtemp);
    //        system.assert(batchId<>null);
    //        //SP_MidMonthTempStopBatch_SelectAccs  batch1 = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
    //    test.stopTest();
    //}
}