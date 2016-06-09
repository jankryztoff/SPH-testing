@isTest (Seealldata = FALSE)
public class SP_MidMonthTempStopBatchTest2{
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    
    static testmethod void testSP_MidMonthTempStopBatch(){
        Integer counter;
        defaultCustomSetting();
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        counter=0;
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        for(Temp_Stop__c tmp: temp){
            tmp.Restart_Date__c = date.today()+2;
            tmp.Temp_Stop_Date__c = date.today()+1;
            tmp.Qty__c = 3;
            if(counter==1){
                tmp.Restart_Date__c = date.today()+12;
            }
            counter++;
        }
        database.insert(temp);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123';
        database.insert(billAcc);
        
        counter=0;
        List<Package__c> pack = TestDataFactory.createPackage(2);
        for(Package__c p: pack){
            if(counter==1){
                p.Package_Type__c = 'Discount';
                p.Package_Sub_Type__c = 'Single';
            }
            counter++;
        }
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductSubType__c = 'Newspaper';
        zp.ProductPlatform__c = 'Print';
        database.insert(zp);
        
        counter=0;
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
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack[0].Id;
        pItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(pItem);
        
        /*Package_Item__c pItem2 = TestDataFactory.createPackageItem(1,'Discount')[0];
        pItem2.Package__c = pack[1].Id;
        pItem2.Product_Rate_Plan__c = prp[1].Id;
        database.insert(pItem2); */
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack[0].Id;
            sub.Frequency__c = 'Mon - Fri';
            if(counter==1){
                sub.Main_Package__c = pack[1].Id;
            }
            counter++;
        }
        database.insert(subs);
    
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp[0].Id;
        subTemp.Subscription__c = subs[0].Id;
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp[1].Id;
        subTemp2.Subscription__c = subs[1].Id;
        database.insert(subTemp2);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            sp.PublicationCode__c = 'ST';
            sp.Name = 'Credit Copy';
        }
        database.insert(spc); 
        
        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Credit Copy';
        usage.Quantity__c = 3;
        database.insert(usage);

        List<Publication__c> newPublication = TestDataFactory.createPublication(2);

        insert newPublication;
        
        test.startTest();
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            id batchID = database.executeBatch(batch, 200);
            system.assert(batchId<>null);
        test.stopTest();
    }
    
    static testmethod void testSP_MidMonthTempStopBatch2(){
        Integer counter;
        defaultCustomSetting();
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        Date stpDate = Date.newInstance(2016, 03, 29);
        Date resDate = Date.newInstance(2016, 04, 05);
        
        Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
        temp.Restart_Date__c = resDate;
        temp.Temp_Stop_Date__c = stpDate;
        temp.Qty__c = 3;
        //temp.Cancelled__c  = true;
        database.insert(temp);
 
        Temp_Stop__c temp2 = TestDataFactory.createTempStop(1)[0]; 
        temp2.Restart_Date__c = date.today().addMonths(-1);
        temp2.Temp_Stop_Date__c = date.today().addMonths(-2);   
        temp2.Qty__c = 3;
        //temp.Cancelled__c  = true;
        database.insert(temp2);          
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];   
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0]; 
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123'; 
        database.insert(billAcc);
        
        counter=0;
        List<Package__c> pack = TestDataFactory.createPackage(2);
        for(Package__c p: pack){
            if(counter==1){
                p.Package_Type__c = 'Discount';
                p.Package_Sub_Type__c = 'Single';
            }
            counter++;
        }
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductSubType__c = 'Newspaper';
        zp.ProductPlatform__c = 'All-In-One';
        database.insert(zp);
        
        counter=0;
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
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack[0].Id;
        pItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(pItem);
        
        /*Package_Item__c pItem2 = TestDataFactory.createPackageItem(1,'Discount')[0];
        pItem2.Package__c = pack[1].Id;
        pItem2.Product_Rate_Plan__c = prp[1].Id;
        database.insert(pItem2); */
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack[0].Id;
            sub.Frequency__c = 'Mon - Fri';
            if(counter==1){
                sub.Main_Package__c = pack[1].Id;
            }
            counter++;
        }
        database.insert(subs);
    
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp2.Id;
        subTemp.Subscription__c = subs[0].Id; 
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp.Id;
        subTemp2.Subscription__c = subs[0].Id;    
        database.insert(subTemp2);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id; 
            sp.PublicationCode__c = 'ST'; 
            sp.Name = 'Credit Copy'; 
        }
        database.insert(spc);

        List<Usage__c> usageList = new List<Usage__c>();

        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Weekday';
        usage.Quantity__c = 3;
        usageList.add(usage);

        Usage__c usage1 = new Usage__c();
        usage1.Subscription_Temp_Stop__c = subTemp2.Id;
        usage1.UOM__c = 'Weekend';
        usage1.Quantity__c = 3;
        usageList.add(usage1);

        Usage__c usage2 = new Usage__c();
        usage2.Subscription_Temp_Stop__c = subTemp2.Id;
        usage2.UOM__c = 'Sat';
        usage2.Quantity__c = 3;
        usageList.add(usage2);

        Usage__c usage3 = new Usage__c();
        usage3.Subscription_Temp_Stop__c = subTemp2.Id;
        usage3.UOM__c = 'Sun';
        usage3.Quantity__c = 3;
        usageList.add(usage3);

        Usage__c usage4 = new Usage__c();
        usage4.Subscription_Temp_Stop__c = subTemp2.Id;
        usage4.UOM__c = 'Online';
        usage4.Quantity__c = 3;
        usageList.add(usage4);

        Usage__c usage5 = new Usage__c();
        usage5.Subscription_Temp_Stop__c = subTemp2.Id;
        usage5.UOM__c = 'Tablet';
        usage5.Quantity__c = 3;
        usageList.add(usage5);

        Usage__c usage6 = new Usage__c();
        usage6.Subscription_Temp_Stop__c = subTemp2.Id;
        usage6.UOM__c = 'SmartPhone';
        usage6.Quantity__c = 3;
        usageList.add(usage6);

        Usage__c usage7 = new Usage__c();
        usage7.Subscription_Temp_Stop__c = subTemp2.Id;
        usage7.UOM__c = 'AIO Online';
        usage7.Quantity__c = 3;
        usageList.add(usage7);

        Usage__c usage8 = new Usage__c();
        usage8.Subscription_Temp_Stop__c = subTemp2.Id;
        usage8.UOM__c = 'AIO Tablet';
        usage8.Quantity__c = 3;
        usageList.add(usage8);

        Usage__c usage9 = new Usage__c();
        usage9.Subscription_Temp_Stop__c = subTemp2.Id;
        usage9.UOM__c = 'AIO Smartphone';
        usage9.Quantity__c = 3;
        usageList.add(usage9);

        database.insert(usageList);

        List<Publication__c> newPublication = TestDataFactory.createPublication(2);

        insert newPublication;

        List<Subscription_Temp_Stop__c> tempQ = [SELECT Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Status__c FROM  Subscription_Temp_Stop__c WHERE Id=:subTemp.Id OR Id=:subTemp2.Id];
        system.debug(tempQ[0]);
        system.debug(tempQ[1]);
        
        test.startTest();
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            id batchID = database.executeBatch(batch, 200);
            system.assert(batchId<>null);
        test.stopTest();
    }
    
    static testmethod void newTest(){
    
    defaultCustomSetting();
    
    try{
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
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact2(1)[0];
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
        
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Order__c = orderRec.Id;
        database.insert(cas);
        
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        temp[0].Restart_Date__c = date.today();
        temp[0].Temp_Stop_Date__c = date.today()-1;
        temp[0].Qty__c = 3;
        temp[0].Cancelled__c  = false;
        temp[1].Restart_Date__c = date.today()+4;
        temp[1].Temp_Stop_Date__c = date.today()+1;
        temp[1].Qty__c = 3;
        temp[1].Cancelled__c  = false;
        database.insert(temp);
        
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
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        database.insert(billAcc);
        
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
         database.insert(subRecs);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = orderRec.Id;
         orderline.Start_Date__c = date.today().addDays(2);
         orderline.End_Date__c = date.today().addDays(30);
         orderline.Main_Package_ID__c = pack.Id;
         database.insert(orderline);
         
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
        spc[0].PublicationCode__c = 'ST';
        spc[0].Name = 'Credit Copy';
        database.insert(spc);
          
        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Credit Copy';
        usage.Quantity__c = 3;
        database.insert(usage);

        List<Publication__c> newPublication = TestDataFactory.createPublication(2);

        insert newPublication;
         
                
        test.startTest();
        subtempstopList.add(subTemp);
        subtempstopList.add(subTemp2);
        
                
            //SP_MidMonthTempStopBatch batch1 = new SP_MidMonthTempStopBatch();
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            id batchID = database.executeBatch(batch, 200);
            //system.assert(batchId<>null);
            
            Set<String> referenceIds1 = new Set<String>();
            referenceIds1.add('billAcc.id');
            Integer type = 1;
            
            SP_MidMonthTempStopBatch batch1 = new SP_MidMonthTempStopBatch(referenceIds1, type);
        test.stopTest();
        }catch(Exception e){
        System.Debug(e);
        }
    }
    
    static testmethod void newTest02(){
    
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
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact2(1)[0];
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
        
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Order__c = orderRec.Id;
        database.insert(cas);
        
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        temp[0].Restart_Date__c = referenceDate.toStartOfMonth()-1;
        temp[0].Temp_Stop_Date__c = referenceDate.toStartOfMonth()-2;
        temp[0].Qty__c = 3;
        temp[0].Cancelled__c  = false;
        temp[1].Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31);
        temp[1].Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 1, 1);
        temp[1].Qty__c = 3;
        temp[1].Cancelled__c  = false;
        database.insert(temp);
        
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
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        database.insert(billAcc);
        
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
         database.insert(subRecs);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = orderRec.Id;
         orderline.Start_Date__c = date.today().addDays(2);
         orderline.End_Date__c = date.today().addDays(30);
         orderline.Main_Package_ID__c = pack.Id;
         database.insert(orderline);
         
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
        spc[0].PublicationCode__c = 'ST';
        spc[0].Name = 'Credit Copy';
        spc[1].Zuora__Subscription__c = subRecs[1].Id;
        spc[1].PublicationCode__c = 'ST';
        spc[1].Name = 'Credit Copy';
        database.insert(spc);
          
        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Credit Copy';
        usage.Quantity__c = 1;
        database.insert(usage);
        
        List<Publication__c> newPublication = TestDataFactory.createPublication(2);

        insert newPublication;
                
        test.startTest();
        subtempstopList.add(subTemp);
        subtempstopList.add(subTemp2);
        
                
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            id batchID = database.executeBatch(batch, 200);
            //system.assert(batchId<>null);
            
            
        test.stopTest();
    }
    
    static testmethod void newTest03(){
    
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
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact2(1)[0]; 
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        temp[0].Restart_Date__c = referenceDate.toStartOfMonth();
        temp[0].Temp_Stop_Date__c = referenceDate.toStartOfMonth()-1;
        temp[0].Qty__c = 3;
        temp[0].Cancelled__c  = false;
        temp[1].Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31);
        temp[1].Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 1, 1);  
        temp[1].Qty__c = 3;
        temp[1].Cancelled__c  = false;
        database.insert(temp);
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];   
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp[0].Id;
        subTemp.Subscription__c = sub.Id;
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp[1].Id;
        subTemp2.Subscription__c = sub.Id;
        database.insert(subTemp2);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = 'ST';
            sp.Name = 'Credit Copy';
        }
        database.insert(spc);
        
        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Credit Copy';
        usage.Quantity__c = 3;
        database.insert(usage);
        
        List<Subscription_Temp_Stop__c> tempQ = [SELECT Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Status__c FROM  Subscription_Temp_Stop__c WHERE Id=:subTemp.Id OR Id=:subTemp2.Id];
        system.debug(tempQ[0]);
        system.debug(tempQ[1]);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Change of Subscription'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Order__c = orders[0].Id;
        database.insert(cas);
        
        
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
        
        List<Publication__c> newPublication = TestDataFactory.createPublication(2);

        insert newPublication;

        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
        
        List<Zuora__Subscription__c> subList1 = [SELECT Id, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c, Frequency_1__c FROM Zuora__Subscription__c WHERE Id =:sub.id];
             
         test.startTest();
         
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            id batchID = database.executeBatch(batch, 200);
            //system.assert(batchId<>null);
            
        test.stopTest();    
    }
    
    static testmethod void newTest03B(){
    
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
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact2(1)[0]; 
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        temp[0].Restart_Date__c = referenceDate.toStartOfMonth();
        temp[0].Temp_Stop_Date__c = referenceDate.toStartOfMonth()-1;
        temp[0].Qty__c = 3;
        temp[0].Cancelled__c  = false;
        temp[1].Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31);
        temp[1].Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 1, 1);  
        temp[1].Qty__c = 3;
        temp[1].Cancelled__c  = false;
        database.insert(temp);
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];   
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp[0].Id;
        subTemp.Subscription__c = sub.Id;
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp[1].Id;
        subTemp2.Subscription__c = sub.Id;
        database.insert(subTemp2);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = 'ST';
            sp.Name = 'Online';
        }
        database.insert(spc);
        
        Usage__c usage = new Usage__c();
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Online';
        usage.Quantity__c = 3;
        database.insert(usage);
        
        List<Subscription_Temp_Stop__c> tempQ = [SELECT Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Status__c FROM  Subscription_Temp_Stop__c WHERE Id=:subTemp.Id OR Id=:subTemp2.Id];
        system.debug(tempQ[0]);
        system.debug(tempQ[1]);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Change of Subscription'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Order__c = orders[0].Id;
        database.insert(cas);
        
        
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
        
        List<Publication__c> newPublication = TestDataFactory.createPublication(2);

        insert newPublication;

        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
        
        List<Zuora__Subscription__c> subList1 = [SELECT Id, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c, Frequency_1__c FROM Zuora__Subscription__c WHERE Id =:sub.id];
             
         test.startTest();
         
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            //batch.createusage(subTemp2, 3, 'Online');
            id batchID = database.executeBatch(batch, 200);
            //system.assert(batchId<>null);
            
        test.stopTest();    
    }
    
    
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
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
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password','Grace Number of Days for Temp Stop'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password','8'}; 
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;

        Date_Configuration__c dteConfig = new Date_Configuration__c();
        dteConfig.Date__c = Date.newInstance(2016, 04, 30);
        dteConfig.Name = 'Usage Reference Date';

        insert dteConfig;
        
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

    static testmethod void testSP_MidMonthTempStopBatch3(){
        Integer counter;
        defaultCustomSetting();
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        Date stpDate = Date.newInstance(2016, 03, 29);
        Date resDate = Date.newInstance(2016, 04, 09);
        
        Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
        temp.Restart_Date__c = resDate;
        temp.Temp_Stop_Date__c = stpDate;
        temp.Qty__c = 3;
        //temp.Cancelled__c  = true;  
        database.insert(temp);
 
        Temp_Stop__c temp2 = TestDataFactory.createTempStop(1)[0]; 
        temp2.Restart_Date__c = date.today().addMonths(-1);
        temp2.Temp_Stop_Date__c = date.today().addMonths(-2);   
        temp2.Qty__c = 3;
        //temp.Cancelled__c  = true;
        database.insert(temp2);          
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];   
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0]; 
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123'; 
        database.insert(billAcc);
        
        counter=0;
        List<Package__c> pack = TestDataFactory.createPackage(2);
        for(Package__c p: pack){
            if(counter==1){
                p.Package_Type__c = 'Discount';
                p.Package_Sub_Type__c = 'Single';
            }
            counter++;
        }
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductSubType__c = 'Newspaper';
        zp.ProductPlatform__c = 'All-In-One';
        database.insert(zp);
        
        counter=0;
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
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack[0].Id;
        pItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(pItem);
        
        /*Package_Item__c pItem2 = TestDataFactory.createPackageItem(1,'Discount')[0];
        pItem2.Package__c = pack[1].Id;
        pItem2.Product_Rate_Plan__c = prp[1].Id;
        database.insert(pItem2); */
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack[0].Id;
            sub.Frequency__c = 'Mon - Fri';
            if(counter==1){
                sub.Main_Package__c = pack[1].Id;
            }
            counter++;
        }
        database.insert(subs);
    
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp2.Id;
        subTemp.Subscription__c = subs[0].Id; 
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp.Id;
        subTemp2.Subscription__c = subs[0].Id;    
        database.insert(subTemp2);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            sp.PublicationCode__c = 'ST';
            sp.Name = 'Credit Copy';
        }
        database.insert(spc);
        
        List<Usage__c> usageList = new List<Usage__c>();
        
        Usage__c usage1 = new Usage__c();
        usage1.Subscription_Temp_Stop__c = subTemp2.Id;
        usage1.UOM__c = 'Weekend';
        usage1.Quantity__c = 3;
        usageList.add(usage1);

        Usage__c usage2 = new Usage__c();
        usage2.Subscription_Temp_Stop__c = subTemp2.Id;
        usage2.UOM__c = 'Sat';
        usage2.Quantity__c = 3;
        usageList.add(usage2);

        Usage__c usage3 = new Usage__c();
        usage3.Subscription_Temp_Stop__c = subTemp2.Id;
        usage3.UOM__c = 'Sun';
        usage3.Quantity__c = 3;
        usageList.add(usage3);

        Usage__c usage4 = new Usage__c();
        usage4.Subscription_Temp_Stop__c = subTemp2.Id;
        usage4.UOM__c = 'Online';
        usage4.Quantity__c = 3;
        usageList.add(usage4);

        Usage__c usage5 = new Usage__c();
        usage5.Subscription_Temp_Stop__c = subTemp2.Id;
        usage5.UOM__c = 'Tablet';
        usage5.Quantity__c = 3;
        usageList.add(usage5);

        Usage__c usage6 = new Usage__c();
        usage6.Subscription_Temp_Stop__c = subTemp2.Id;
        usage6.UOM__c = 'SmartPhone';
        usage6.Quantity__c = 3;
        usageList.add(usage6);

        Usage__c usage7 = new Usage__c();
        usage7.Subscription_Temp_Stop__c = subTemp2.Id;
        usage7.UOM__c = 'AIO Online';
        usage7.Quantity__c = 3;
        usageList.add(usage7);

        Usage__c usage8 = new Usage__c();
        usage8.Subscription_Temp_Stop__c = subTemp2.Id;
        usage8.UOM__c = 'AIO Tablet';
        usage8.Quantity__c = 3;
        usageList.add(usage8);

        Usage__c usage9 = new Usage__c();
        usage9.Subscription_Temp_Stop__c = subTemp2.Id;
        usage9.UOM__c = 'AIO Smartphone';
        usage9.Quantity__c = 3;
        usageList.add(usage9);

        Usage__c usage = new Usage__c(); 
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Weekday'; 
        usage.Quantity__c = 3;
        usageList.add(usage); 

        database.insert(usageList);

        List<Publication__c> newPublication = TestDataFactory.createPublication(2);

        insert newPublication;

        List<Subscription_Temp_Stop__c> tempQ = [SELECT Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Status__c FROM  Subscription_Temp_Stop__c WHERE Id=:subTemp.Id OR Id=:subTemp2.Id];
        system.debug(tempQ[0]);
        system.debug(tempQ[1]);
        
        test.startTest();
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            id batchID = database.executeBatch(batch, 200);
            //system.assert(batchId<>null);
        test.stopTest();
    }

    static testmethod void testSP_MidMonthTempStopBatch4(){
        Integer counter;
        defaultCustomSetting();
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        Date stpDate = Date.newInstance(2016, 03, 29);
        Date resDate = Date.newInstance(2016, 04, 09);
        
        Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
        temp.Restart_Date__c = resDate;
        temp.Temp_Stop_Date__c = stpDate;
        temp.Qty__c = 3;
        //temp.Cancelled__c  = true;  
        database.insert(temp);
 
        Temp_Stop__c temp2 = TestDataFactory.createTempStop(1)[0]; 
        temp2.Restart_Date__c = date.today().addMonths(-1);
        temp2.Temp_Stop_Date__c = date.today().addMonths(-2);   
        temp2.Qty__c = 3;
        //temp.Cancelled__c  = true;
        database.insert(temp2);          
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];   
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0]; 
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123'; 
        database.insert(billAcc);
        
        counter=0;
        List<Package__c> pack = TestDataFactory.createPackage(2);
        for(Package__c p: pack){
            if(counter==1){
                p.Package_Type__c = 'Discount';
                p.Package_Sub_Type__c = 'Single';
            }
            counter++;
        }
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductSubType__c = 'Newspaper';
        zp.ProductPlatform__c = 'Print';
        database.insert(zp);
        
        counter=0;
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
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack[0].Id;
        pItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(pItem);
        
        /*Package_Item__c pItem2 = TestDataFactory.createPackageItem(1,'Discount')[0];
        pItem2.Package__c = pack[1].Id;
        pItem2.Product_Rate_Plan__c = prp[1].Id;
        database.insert(pItem2); */
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack[0].Id;
            sub.Frequency__c = 'Mon - Fri';
            if(counter==1){
                sub.Main_Package__c = pack[1].Id;
            }
            counter++;
        }
        database.insert(subs);
    
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = temp2.Id;
        subTemp.Subscription__c = subs[0].Id; 
        database.insert(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = temp.Id;
        subTemp2.Subscription__c = subs[0].Id;    
        database.insert(subTemp2);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            sp.PublicationCode__c = 'ST';
            sp.Name = 'No Credit Copy Sun';
        }
        database.insert(spc);
        
        List<Usage__c> usageList = new List<Usage__c>();
        
        Usage__c usage1 = new Usage__c();
        usage1.Subscription_Temp_Stop__c = subTemp2.Id;
        usage1.UOM__c = 'Weekend';
        usage1.Quantity__c = 3;
        usageList.add(usage1);

        Usage__c usage2 = new Usage__c();
        usage2.Subscription_Temp_Stop__c = subTemp2.Id;
        usage2.UOM__c = 'Sat';
        usage2.Quantity__c = 3;
        usageList.add(usage2);

        Usage__c usage3 = new Usage__c();
        usage3.Subscription_Temp_Stop__c = subTemp2.Id;
        usage3.UOM__c = 'Sun';
        usage3.Quantity__c = 3;
        usageList.add(usage3);

        Usage__c usage4 = new Usage__c();
        usage4.Subscription_Temp_Stop__c = subTemp2.Id;
        usage4.UOM__c = 'Online';
        usage4.Quantity__c = 3;
        usageList.add(usage4);

        Usage__c usage5 = new Usage__c();
        usage5.Subscription_Temp_Stop__c = subTemp2.Id;
        usage5.UOM__c = 'Tablet';
        usage5.Quantity__c = 3;
        usageList.add(usage5);

        Usage__c usage6 = new Usage__c();
        usage6.Subscription_Temp_Stop__c = subTemp2.Id;
        usage6.UOM__c = 'SmartPhone';
        usage6.Quantity__c = 3;
        usageList.add(usage6);

        Usage__c usage7 = new Usage__c();
        usage7.Subscription_Temp_Stop__c = subTemp2.Id;
        usage7.UOM__c = 'AIO Online';
        usage7.Quantity__c = 3;
        usageList.add(usage7);

        Usage__c usage8 = new Usage__c();
        usage8.Subscription_Temp_Stop__c = subTemp2.Id;
        usage8.UOM__c = 'AIO Tablet';
        usage8.Quantity__c = 3;
        usageList.add(usage8);

        Usage__c usage9 = new Usage__c();
        usage9.Subscription_Temp_Stop__c = subTemp2.Id;
        usage9.UOM__c = 'AIO Smartphone';
        usage9.Quantity__c = 3;
        usageList.add(usage9);

        Usage__c usage = new Usage__c(); 
        usage.Subscription_Temp_Stop__c = subTemp2.Id;
        usage.UOM__c = 'Weekday'; 
        usage.Quantity__c = 3;
        usageList.add(usage); 

        database.insert(usageList);

        List<Publication__c> newPublication = TestDataFactory.createPublication(2);

        insert newPublication;

        List<Subscription_Temp_Stop__c> tempQ = [SELECT Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Status__c FROM  Subscription_Temp_Stop__c WHERE Id=:subTemp.Id OR Id=:subTemp2.Id];
        system.debug(tempQ[0]);
        system.debug(tempQ[1]);
        
        test.startTest();
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            id batchID = database.executeBatch(batch, 200);
            //system.assert(batchId<>null);
        test.stopTest();
    }
    
    static testmethod void testSP_MidMonthTempStopBatch5(){
        Integer counter;
        defaultCustomSetting();
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Date_Configuration__c dateConfig = [SELECT Id, Date__c FROM Date_Configuration__c WHERE Name = 'Usage Reference Date'];
        dateConfig.Date__c = date.Today().addMonths(9);
        update dateConfig;
        system.debug('>>>>>test ' + dateConfig);
        Date stpDate = Date.newInstance(2016, 03, 29);
        Date resDate = Date.newInstance(2016, 04, 09);
        
        Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
        temp.Restart_Date__c = Date.Today().toStartOfMonth().addMonths(8).addDays(10);
        temp.Temp_Stop_Date__c = Date.Today().toStartOfMonth().addMonths(8);
        temp.Qty__c = 1;
        temp.Cancelled__c  = false;  
        database.insert(temp);
 
        Temp_Stop__c temp2 = TestDataFactory.createTempStop(1)[0]; 
        temp2.Restart_Date__c = Date.Today().toStartOfMonth().addMonths(7).addDays(10);
        temp2.Temp_Stop_Date__c = Date.Today().toStartOfMonth().addMonths(7).addDays(5);
        temp2.Qty__c = 1;
        temp2.Cancelled__c  = false;
        database.insert(temp2);
        
        List<Temp_Stop__c> tempList = TestDataFactory.createTempStop(4);
        //temp stop less than grace days within same month
        tempList[0].Restart_Date__c = Date.Today().toStartOfMonth().addMonths(8).addDays(5);
        tempList[0].Temp_Stop_Date__c = Date.Today().toStartOfMonth().addMonths(8);
        tempList[0].Qty__c = 1;
        tempList[0].Cancelled__c  = false;
        //temp stop more than grace days within same month
        tempList[1].Restart_Date__c = Date.Today().toStartOfMonth().addMonths(8).addDays(10);
        tempList[1].Temp_Stop_Date__c = Date.Today().toStartOfMonth().addMonths(8);
        tempList[1].Qty__c = 1;
        tempList[1].Cancelled__c  = false;
        //temp stop less than grace days across months
        tempList[2].Restart_Date__c = Date.Today().toStartOfMonth().addMonths(9).addDays(2);
        tempList[2].Temp_Stop_Date__c = Date.Today().toStartOfMonth().addMonths(9).addDays(-3);
        tempList[2].Qty__c = 1;
        tempList[2].Cancelled__c  = false;
        //temp stop more than grace days across months
        tempList[3].Restart_Date__c = Date.Today().toStartOfMonth().addMonths(9).addDays(10);
        tempList[3].Temp_Stop_Date__c = Date.Today().toStartOfMonth().addMonths(9).addDays(-3);
        tempList[3].Qty__c = 1;
        tempList[3].Cancelled__c  = false;
        
        insert tempList;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];   
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0]; 
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123'; 
        database.insert(billAcc);
        
        counter=0;
        List<Package__c> pack = TestDataFactory.createPackage(2);
        for(Package__c p: pack){
            if(counter==1){
                p.Package_Type__c = 'Discount';
                p.Package_Sub_Type__c = 'Single';
            }
            counter++;
        }
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductSubType__c = 'Newspaper';
        zp.ProductPlatform__c = 'Print';
        database.insert(zp);
        
        counter=0;
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
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack[0].Id;
        pItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(pItem);
        
        /*Package_Item__c pItem2 = TestDataFactory.createPackageItem(1,'Discount')[0];
        pItem2.Package__c = pack[1].Id;
        pItem2.Product_Rate_Plan__c = prp[1].Id;
        database.insert(pItem2); */
        
        counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack[0].Id;
            sub.Frequency__c = 'Mon - Fri';
            if(counter==1){
                sub.Main_Package__c = pack[1].Id;
            }
            sub.Qty1__c = '1';
            sub.Qty__c = 1;
            sub.Zuora__SubscriptionStartDate__c = Date.Today().toStartOfMonth().addMonths(7);
            sub.Term_Length1__c = '12';
            sub.Term_Length__c = 12;
            sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1);
            counter++;
        }
        database.insert(subs);
    
        List<Subscription_Temp_Stop__c> subTempList = new List<Subscription_Temp_Stop__c>();
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Temp_Stop__c = tempList[2].Id;
        subTemp.Subscription__c = subs[0].Id; 
        subTempList.add(subTemp);
        
        Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
        subTemp2.Temp_Stop__c = tempList[3].Id;
        subTemp2.Subscription__c = subs[0].Id;    
        subTempList.add(subTemp2);
        
        Subscription_Temp_Stop__c subTemp3 = new Subscription_Temp_Stop__c();
        subTemp3.Temp_Stop__c = temp.Id;
        subTemp3.Subscription__c = subs[0].Id;    
        subTempList.add(subTemp3);
        
        insert subTempList;
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            sp.PublicationCode__c = 'ST';
            sp.Name = 'No Credit Copy Sun';
        }
        database.insert(spc);

        List<Subscription_Temp_Stop__c> tempQ = [SELECT Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Status__c FROM  Subscription_Temp_Stop__c WHERE Id=:subTemp.Id OR Id=:subTemp2.Id];
        system.debug(tempQ[0]);
        system.debug(tempQ[1]);
        
        List<Usage__c> usageList = new List<Usage__c>();
        
        Usage__c usage1 = new Usage__c();
        usage1.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage1.UOM__c = 'Weekend';
        usage1.Quantity__c = 3;
        usageList.add(usage1);

        Usage__c usage2 = new Usage__c();
        usage2.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage2.UOM__c = 'Sat';
        usage2.Quantity__c = 3;
        usageList.add(usage2);

        Usage__c usage3 = new Usage__c();
        usage3.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage3.UOM__c = 'Sun';
        usage3.Quantity__c = 3;
        usageList.add(usage3);

        Usage__c usage4 = new Usage__c();
        usage4.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage4.UOM__c = 'Online';
        usage4.Quantity__c = 3;
        usageList.add(usage4);

        Usage__c usage5 = new Usage__c();
        usage5.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage5.UOM__c = 'Tablet';
        usage5.Quantity__c = 3;
        usageList.add(usage5);

        Usage__c usage6 = new Usage__c();
        usage6.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage6.UOM__c = 'Smartphone';
        usage6.Quantity__c = 3;
        usageList.add(usage6);

        Usage__c usage7 = new Usage__c();
        usage7.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage7.UOM__c = 'AIO Online';
        usage7.Quantity__c = 3;
        usageList.add(usage7);

        Usage__c usage8 = new Usage__c();
        usage8.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage8.UOM__c = 'AIO Tablet';
        usage8.Quantity__c = 3;
        usageList.add(usage8);

        Usage__c usage9 = new Usage__c();
        usage9.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage9.UOM__c = 'AIO Smartphone';
        usage9.Quantity__c = 3;
        usageList.add(usage9);

        Usage__c usage10 = new Usage__c(); 
        usage10.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage10.UOM__c = 'Weekday'; 
        usage10.Quantity__c = 3;
        usageList.add(usage10);
        
        Usage__c usage11 = new Usage__c();
        usage11.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage11.UOM__c = 'Copy Weekend';
        usage11.Quantity__c = 3;
        usageList.add(usage11);

        Usage__c usage12 = new Usage__c();
        usage12.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage12.UOM__c = 'Copy Sat';
        usage12.Quantity__c = 3;
        usageList.add(usage12);

        Usage__c usage13 = new Usage__c();
        usage13.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage13.UOM__c = 'Copy Sun';
        usage13.Quantity__c = 3;
        usageList.add(usage13);

        Usage__c usage14 = new Usage__c();
        usage14.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage14.UOM__c = 'Copy Online';
        usage14.Quantity__c = 3;
        usageList.add(usage14);

        Usage__c usage15 = new Usage__c();
        usage15.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage15.UOM__c = 'Copy Tablet';
        usage15.Quantity__c = 3;
        usageList.add(usage15);

        Usage__c usage16 = new Usage__c();
        usage16.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage16.UOM__c = 'Copy Smartphone';
        usage16.Quantity__c = 3;
        usageList.add(usage16);

        Usage__c usage17 = new Usage__c();
        usage17.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage17.UOM__c = 'Copy AIO Online';
        usage17.Quantity__c = 3;
        usageList.add(usage17);

        Usage__c usage18 = new Usage__c();
        usage18.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage18.UOM__c = 'Copy AIO Tablet';
        usage18.Quantity__c = 3;
        usageList.add(usage18);

        Usage__c usage19 = new Usage__c();
        usage19.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage19.UOM__c = 'Copy AIO Smartphone';
        usage19.Quantity__c = 3;
        usageList.add(usage19);

        Usage__c usage20 = new Usage__c(); 
        usage20.Subscription_Temp_Stop__c = subTempList[0].Id;
        usage20.UOM__c = 'Copy Weekday'; 
        usage20.Quantity__c = 3;
        usageList.add(usage20);

        database.insert(usageList);
        
        test.startTest();
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            id batchID = database.executeBatch(batch, 200);
            //system.assert(batchId<>null);
        test.stopTest();
    }
}