@isTest (Seealldata = False)
public class SP_MidMonthTempStopBatch_SelectAccsTest{
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    
    static testmethod void test01(){
        
        defaultCustomSetting();
        
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='Name', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        Date_Configuration__c dateconfi = new Date_Configuration__c();
        dateconfi.name = 'name';
        dateconfi.Date__c = date.Today();
        insert dateconfi;
        
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = 'AccntSet';
        
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123';
        database.insert(billAcc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.Address__c = address.Id;
        //con.Billing_Indicator__c = True;
        con.Recipient_Indicator__c = true;
        database.insert(con);  
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
        database.insert(orderRec);
        
        
        
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        temp[0].Restart_Date__c = date.today()+10;
        temp[0].Temp_Stop_Date__c = date.today()+1;
        temp[0].Qty__c = 3;
        temp[0].Cancelled__c  = false;
        
        temp[1].Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31);
        temp[1].Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 12, 31);
        temp[1].Qty__c = 3;
        temp[1].Cancelled__c  = false;
        database.insert(temp);
        
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Order__c = orderRec.Id;
        cas.Temp_Stop__c = temp[1].Id;
        cas.Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31);
        cas.Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 12, 31);
        cas.Temp_Stop_Type__c = 'new';
        database.insert(cas);
        //system.assertEquals('cancelled', temp[1].Temp_Stop_Status__c);

        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.ProductPlatform__c = 'Print';
        database.insert(zProduct);
            
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        database.insert(prdRatePlan);
            
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        database.insert(prpc);
            
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
        for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        }
        database.insert(pItems);
       
        
         List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
         subRecs[0].Zuora__Account__c = acc.Id;
         subRecs[0].Name = 'TestName';
         subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
         subRecs[0].Order_Number_1__c = orderRec.Id;
         subRecs[0].Order_Number__c = orderRec.Id;
         subRecs[0].Term_Length__c = 0;
         subRecs[0].Term_Length1__c = '0';
         subRecs[0].Main_Package_1__c = pack.id;
         subRecs[0].Main_Package__c = pack.Id;
         subRecs[0].Zuora__SubscriptionStartDate__c = Date.Today();
         subRecs[0].Zuora__SubscriptionEndDate__c = date.Today()+1;
         subRecs[0].Recipient_Contact__c = con.Id;
         subRecs[0].Zuora__Status__c = 'Active';
         subRecs[0].Frequency_1__c = 'Default';
         subRecs[0].Frequency__c = 'Default';
         
         
         subRecs[1].Name = 'TestName';
         subRecs[1].Zuora__Account__c = acc.Id;
         subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
         subRecs[1].Order_Number_1__c = orderRec.Id;
         subRecs[1].Order_Number__c = orderRec.Id;
         subRecs[1].Term_Length__c = 0;
         subRecs[1].Term_Length1__c = '0';
         subRecs[1].Main_Package_1__c = pack.id;
         subRecs[1].Main_Package__c = pack.Id;
         subRecs[1].Zuora__SubscriptionStartDate__c = Date.Today();
         subRecs[1].Zuora__SubscriptionEndDate__c = date.Today()+1;
         subRecs[1].Recipient_Contact__c = con.Id;
         subRecs[1].Zuora__Status__c = 'Active';
         subRecs[1].Frequency_1__c = 'Default';
         subRecs[1].Frequency__c = 'Default';
         database.insert(subRecs);
        
         
        List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp[0].Id;
        subTemp.Subscription__c = subRecs[0].Id;
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp[1].Id;
        subTemp2.Subscription__c = subRecs[0].Id; //todo
        database.insert(subTemp2);
            
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        spc[0].Zuora__Subscription__c = subRecs[0].Id;
        spc[0].PublicationCode__c = '01';
        spc[0].Name = 'Credit Copy';
        
        spc[1].Zuora__Subscription__c = subRecs[1].Id;
        spc[1].PublicationCode__c = '01';
        spc[1].Name = 'Credit Copy';
        
        database.insert(spc);
          
        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Credit Copy';
        usage.Quantity__c = 3;
        database.insert(usage);
         
         set<String> AccntSet = new set<string>();
         AccntSet.add('acc.Id');
                
        
        subtempstopList.add(subTemp);
        subtempstopList.add(subTemp2);    
        
        list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__c, 
        Subscription__r.Zuora__Account__c, Subscription__r.Name, Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
        Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Subscription__r.Number_of_Copies__c,
        Subscription__r.Ph_d__c, Subscription__r.Ph_e__c FROM Subscription_Temp_Stop__c WHERE Id =: subTemp.Id];   
        test.startTest();
            Database.BatchableContext bc;
            SP_MidMonthTempStopBatch_SelectAccs  batch = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
            id batchID = database.executeBatch(batch, 200);
            batch.execute(bc, listtemp);
            system.assert(batchId<>null);
            
            //SP_MidMonthTempStopBatch_SelectAccs  batch1 = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
            
        test.stopTest();
        
      }
      
      static testmethod void test02(){
        
        defaultCustomSetting();
        
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='Name', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = 'AccntSet';
        
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123';
        database.insert(billAcc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.Address__c = address.Id;
        //con.Billing_Indicator__c = True;
        con.Recipient_Indicator__c = true;
        database.insert(con);  
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
        database.insert(orderRec);
        
        /*Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Order__c = orderRec.Id;
        database.insert(cas);*/
        
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        temp[0].Restart_Date__c =  referenceDate.addMonths(2).toStartofMonth().addDays(-1);
        temp[0].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
        temp[0].Qty__c = 3;
        temp[0].Cancelled__c  = false;
        
        temp[1].Restart_Date__c = referenceDate.addMonths(1).toStartofMonth().addDays(-10);
        temp[1].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
        temp[1].Qty__c = 3;
        temp[1].Cancelled__c  = false;
        database.insert(temp);
        
        //system.assertEquals(null, temp[0].Temp_Stop_Status__c);

        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.ProductPlatform__c = 'Print';
        database.insert(zProduct);
            
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        database.insert(prdRatePlan);
            
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        database.insert(prpc);
            
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
        for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        }
        database.insert(pItems);
       
        
         List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
         subRecs[0].Zuora__Account__c = acc.Id;
         subRecs[0].Name = 'TestName';
         subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
         subRecs[0].Order_Number_1__c = orderRec.Id;
         subRecs[0].Order_Number__c = orderRec.Id;
         subRecs[0].Term_Length__c = 0;
         subRecs[0].Term_Length1__c = '0';
         subRecs[0].Main_Package_1__c = pack.id;
         subRecs[0].Main_Package__c = pack.Id;
         subRecs[0].Zuora__SubscriptionStartDate__c = Date.Today();
         subRecs[0].Zuora__SubscriptionEndDate__c = date.Today()+1;
         subRecs[0].Recipient_Contact__c = con.Id;
         subRecs[0].Zuora__Status__c = 'Active';
         subRecs[0].Frequency_1__c = 'Default';
         subRecs[0].Frequency__c = 'Default';
         
         
         subRecs[1].Name = 'TestName';
         subRecs[1].Zuora__Account__c = acc.Id;
         subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
         subRecs[1].Order_Number_1__c = orderRec.Id;
         subRecs[1].Order_Number__c = orderRec.Id;
         subRecs[1].Term_Length__c = 0;
         subRecs[1].Term_Length1__c = '0';
         subRecs[1].Main_Package_1__c = pack.id;
         subRecs[1].Main_Package__c = pack.Id;
         subRecs[1].Zuora__SubscriptionStartDate__c = Date.Today();
         subRecs[1].Zuora__SubscriptionEndDate__c = date.Today()+1;
         subRecs[1].Recipient_Contact__c = con.Id;
         subRecs[1].Zuora__Status__c = 'Active';
         subRecs[1].Frequency_1__c = 'Default';
         subRecs[1].Frequency__c = 'Default';
         database.insert(subRecs);
        
         
        List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp[0].Id;
        subTemp.Subscription__c = subRecs[0].Id;
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp[1].Id;
        subTemp2.Subscription__c = subRecs[1].Id;
        database.insert(subTemp2);
            
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        spc[0].Zuora__Subscription__c = subRecs[0].Id;
        spc[0].PublicationCode__c = '01';
        spc[0].Name = 'Credit Copy';
        
        spc[1].Zuora__Subscription__c = subRecs[1].Id;
        spc[1].PublicationCode__c = '01';
        spc[1].Name = 'Credit Copy';
        
        database.insert(spc);
          
        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Credit Copy';
        usage.Quantity__c = 3;
        database.insert(usage);
         
         set<String> AccntSet = new set<string>();
         AccntSet.add('acc.Id');
                
        
        subtempstopList.add(subTemp);
        subtempstopList.add(subTemp2);    
        
        list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__c, 
        Subscription__r.Zuora__Account__c, Subscription__r.Name, Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
        Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Subscription__r.Number_of_Copies__c,
        Subscription__r.Ph_d__c, Subscription__r.Ph_e__c FROM Subscription_Temp_Stop__c WHERE Id =: subTemp.Id];   
        test.startTest();
            Database.BatchableContext bc;
            SP_MidMonthTempStopBatch_SelectAccs  batch = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
            id batchID = database.executeBatch(batch, 200);
            batch.execute(bc, listtemp);
            system.assert(batchId<>null);
            
            //SP_MidMonthTempStopBatch_SelectAccs  batch1 = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
            
        test.stopTest();
        
      }
      
      static testmethod void test03(){
        
        defaultCustomSetting();
        
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='Name', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = 'AccntSet';
        
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123';
        database.insert(billAcc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.Address__c = address.Id;
        //con.Billing_Indicator__c = True;
        con.Recipient_Indicator__c = true;
        database.insert(con);  
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
        database.insert(orderRec);
        
        /*Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Order__c = orderRec.Id;
        database.insert(cas);*/
        
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        temp[0].Restart_Date__c =  referenceDate.toStartOfMonth();//referenceDate.addMonths(2).toStartofMonth().addDays(-1);
        temp[0].Temp_Stop_Date__c = referenceDate.addMonths(-2).toStartofMonth().addDays(-1);//referenceDate.toStartOfMonth();
        temp[0].Qty__c = 3;
        temp[0].Cancelled__c  = false;
        
        temp[1].Restart_Date__c = referenceDate.addMonths(1).toStartofMonth().addDays(-10);
        temp[1].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
        temp[1].Qty__c = 3;
        temp[1].Cancelled__c  = false;
        database.insert(temp);
        
        //system.assertEquals(null, temp[0].Temp_Stop_Status__c);

        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.ProductPlatform__c = 'Print';
        database.insert(zProduct);
            
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        database.insert(prdRatePlan);
            
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        database.insert(prpc);
            
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
        for (Package_Item__c pItem : pItems) {
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        }
        database.insert(pItems);
       
        
         List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
         subRecs[0].Zuora__Account__c = acc.Id;
         subRecs[0].Name = 'TestName';
         subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
         subRecs[0].Order_Number_1__c = orderRec.Id;
         subRecs[0].Order_Number__c = orderRec.Id;
         subRecs[0].Term_Length__c = 0;
         subRecs[0].Term_Length1__c = '0';
         subRecs[0].Main_Package_1__c = pack.id;
         subRecs[0].Main_Package__c = pack.Id;
         subRecs[0].Zuora__SubscriptionStartDate__c = Date.Today();
         subRecs[0].Zuora__SubscriptionEndDate__c = date.Today()+1;
         subRecs[0].Recipient_Contact__c = con.Id;
         subRecs[0].Zuora__Status__c = 'Active';
         subRecs[0].Frequency_1__c = 'Default';
         subRecs[0].Frequency__c = 'Default';
         
         
         subRecs[1].Name = 'TestName';
         subRecs[1].Zuora__Account__c = acc.Id;
         subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
         subRecs[1].Order_Number_1__c = orderRec.Id;
         subRecs[1].Order_Number__c = orderRec.Id;
         subRecs[1].Term_Length__c = 0;
         subRecs[1].Term_Length1__c = '0';
         subRecs[1].Main_Package_1__c = pack.id;
         subRecs[1].Main_Package__c = pack.Id;
         subRecs[1].Zuora__SubscriptionStartDate__c = Date.Today();
         subRecs[1].Zuora__SubscriptionEndDate__c = date.Today()+1;
         subRecs[1].Recipient_Contact__c = con.Id;
         subRecs[1].Zuora__Status__c = 'Active';
         subRecs[1].Frequency_1__c = 'Default';
         subRecs[1].Frequency__c = 'Default';
         database.insert(subRecs);
        
         
        List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp[0].Id;
        subTemp.Subscription__c = subRecs[0].Id;
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp[1].Id;
        subTemp2.Subscription__c = subRecs[1].Id;
        database.insert(subTemp2);
            
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        spc[0].Zuora__Subscription__c = subRecs[0].Id;
        spc[0].PublicationCode__c = '01';
        spc[0].Name = 'Credit Copy';
        
        spc[1].Zuora__Subscription__c = subRecs[1].Id;
        spc[1].PublicationCode__c = '01';
        spc[1].Name = 'Credit Copy';
        
        database.insert(spc);
          
        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp.Id;
        usage.UOM__c = 'Credit Copy';
        usage.Quantity__c = 3;
        database.insert(usage);
         
         set<String> AccntSet = new set<string>();
         AccntSet.add('acc.Id');
                
        
        subtempstopList.add(subTemp);
        subtempstopList.add(subTemp2);    
        
        list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__c, 
        Subscription__r.Zuora__Account__c, Subscription__r.Name, Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
        Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Subscription__r.Number_of_Copies__c,
        Subscription__r.Ph_d__c, Subscription__r.Ph_e__c FROM Subscription_Temp_Stop__c WHERE Id =: subTemp.Id];   
        test.startTest();
            Database.BatchableContext bc;
            SP_MidMonthTempStopBatch_SelectAccs  batch = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
            id batchID = database.executeBatch(batch, 200);
            batch.execute(bc, listtemp);
            system.assert(batchId<>null);
            
            //SP_MidMonthTempStopBatch_SelectAccs  batch1 = new SP_MidMonthTempStopBatch_SelectAccs(AccntSet);
            
        test.stopTest();
        
      }
       static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
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
  }