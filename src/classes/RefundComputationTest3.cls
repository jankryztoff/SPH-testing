@isTest (seeAllData= false)
private class RefundComputationTest3 {
    static testMethod void testComputeRefundRecurringPrepaid(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);
        
        Key_Id__c keys = new Key_Id__c();
        keys.Name = 'Package Item_Base Product';
        keys.Type__c = 'RecordType';
        keys.Id__c = '012N00000008jCOIAY';
        database.insert(keys);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU';
        zp.ProductPlatform__c = 'All-In-One';
        database.insert(zp);
        
        Integer counter=0;
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pr:prp){
            if(counter==0){
                pr.RatePlanType__c = 'Bill Plan';
                pr.SubscriptionFrequency__c = '0';
            }
            else{
                pr.RatePlanType__c = 'Proration';
                pr.SubscriptionFrequency__c = '1';
            }
            pr.zqu__ZProduct__c = zp.Id;
            pr.Name = 'Name';
            pr.RatePlanSubType__c = 'Standard';
            pr.zqu__Deleted__c = false;
            counter++;
        }
        database.insert(prp);
        
        

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Main_Package__c = pack.Id;
        subRecs.Zuora__SubscriptionEndDate__c = date.today()+2; //joy
        subRecs.Term_Length1__c = '1';
        subRecs.Term_Length__c = 1;
        subRecs.Zuora__SubscriptionStartDate__c = date.today()+1;
        subRecs.Zuora__TermSettingType__c = GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED;
        subRecs.Billing_Type__c = 'Recurring Prepaid';
        //subRecs.Order_Line_Item_Number__c = orderline.Id;
        subRecs.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
        subRecs.Qty1__c = '3.3';
        subRecs.Qty__c = 3;
        subRecs.Number_of_Copies__c = 3;
        subRecs.Number_of_Copies1__c =  '3';
        subRecs.Delivered_By__c = 'Mailing Agent';
        subRecs.Frequency__c = 'Mon - Fri';
        subRecs.Frequency_1__c =  'Mon - Fri';
        database.insert(subRecs);
        
        system.debug(subRecs.Zuora__SubscriptionEndDate__c);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Base_Subscription__c = subRecs.id;// joy
        ord.Order_Type__c = 'Renewal'; //joy
        
        database.insert(ord);
        
       Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = ord.Id;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = date.today()+3;
        database.insert(orderline);
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = [SELECT Main_Package_1__c, Id FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Main_Package_1__c;
        packItem.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType='Package_Item__c' AND Name = 'Base Product'].Id;
        packItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(packItem);
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs.Id;
            if(counter==0){
                sp.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
            }
            else{
                sp.Zuora__Model__c = 'model';
            }
            sp.Zuora__ProductName__c = 'discount';
            sp.Zuora__EffectiveStartDate__c = date.today()+3;
            sp.Zuora__Quantity__c = 3;
            sp.Zuora__RatePlanName__c = 'Name';
            sp.Zuora__ProductSKU__c = 'SKU';
            sp.Zuora__UOM__c = 'CREDIT';
            sp.Zuora__Price__c = 100;
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(4);
        for(Publication__c p : pub){
            p.Publication_Code__c = 'N';
            if(counter==0){
                p.Platform_Type__c = 'Print';
            }
            else if(counter==1){
                p.Platform_Type__c = GlobalVariableClass.ONLINE;
            }
            else if(counter==2){
                p.Platform_Type__c = 'Smartphone';
            }
            else{
                p.Platform_Type__c = 'Tablet';
            }
            p.Publication_Type__c = 'M';
            p.Published_Days__c = 'YYYYYYY';
            p.Name = 'Name';
            counter++;
        }
        database.insert(pub);
        
        counter = 0;
        List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(8);
        for(zqu__ProductRatePlanCharge__c pro:zprpc){
            pro.zqu__ProductRatePlan__c = prp[1].Id;
            pro.PublicationCode__c = 'N';
            if(counter==0){
                pro.zqu__UOM__c = 'Credit Copy Weekday';   
            }
            else if(counter==1){
                pro.zqu__UOM__c = 'Credit Copy Sun';   
            }
            else if(counter==2){
                pro.zqu__UOM__c = 'Credit Copy Issue N';   
            }
            else if(counter==3){
                pro.zqu__UOM__c = 'Credit Copy Online';   
            }
            else if(counter==4){
                pro.zqu__UOM__c = 'Credit Copy Smartphone';   
            }
            else if(counter==5){
                pro.zqu__UOM__c = 'Credit Copy AIO Smartphon';
            }
            else if(counter==6){
                pro.zqu__UOM__c = 'Credit Copy Month N';
            }
            else{
                pro.zqu__UOM__c = 'Credit Copy AIO Name';
            }
            counter++;
        }
        database.insert(zprpc);
        
       
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
        for(Non_Publication_Day__c np:nonPub){
            np.Publication_Code__c = 'N'; 
            np.Publication__c =pub[0].Id;//joy  
        }
        database.insert(nonPub);
    
        test.startTest();
        try
        {
            //RefundComputation.computeRefund(subRecs.Id, date.today());
            RefundComputation.computeRefund(subRecs.id, subRecs.Zuora__SubscriptionStartDate__c);
            RefundComputation.getfirstDayOfTheMonth();
            RefundComputation.convertSubFreq(pub[0], prp[0]);
            RefundComputation.convertSubFreq(pub[1], prp[0]);
            RefundComputation.checkifRefundable(pub[0], prp[0], 'SUN');
            RefundComputation.computeMonthlyPayment(pub, 10);
            RefundComputation.copiesGivenSub(pub, date.today(), date.today()+2, nonPub);
            RefundComputation.getpending(pub[0]);
            RefundComputation.computeDiscount(pub, date.today(), date.today()+5);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }           
        test.stopTest();
    }
    
    static testmethod void testComputeRefundFullPrepaid(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);
        
        Key_Id__c keys = new Key_Id__c();
        keys.Name = 'Package Item_Base Product';
        keys.Type__c = 'RecordType';
        keys.Id__c = '012N00000008jCOIAY';
        database.insert(keys);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
      
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Price__c=100;
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU';
        zp.ProductPlatform__c = 'All-In-One';
        database.insert(zp);
        
        Integer counter=0;
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pr:prp){
            if(counter==0){
                pr.RatePlanType__c = 'Bill Plan';
                pr.SubscriptionFrequency__c = '2';
            }
            else{
                pr.RatePlanType__c = 'Proration';
                pr.SubscriptionFrequency__c = '3';
            }
            pr.zqu__ZProduct__c = zp.Id;
            pr.Name = 'Name';
            pr.RatePlanSubType__c = 'Standard';
            pr.zqu__Deleted__c = false;
            counter++;
        }
        database.insert(prp);
        
        

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Main_Package__c = pack.Id;
        subRecs.Zuora__SubscriptionEndDate__c = date.today()+2;
        //subRecs.Term_Length1__c = '30.30';
        //subRecs.Term_Length__c = 30;
        subRecs.Zuora__SubscriptionStartDate__c = date.today()+1;
        subRecs.Zuora__TermSettingType__c = GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED;
        subRecs.Billing_Type__c = 'Full Prepaid';
        //subRecs.Order_Line_Item_Number__c = orderline.Id;
        subRecs.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
        subRecs.Qty1__c = '3.3';
        subRecs.Qty__c = 3;
        subRecs.Number_of_Copies__c = 3;
        subRecs.Delivered_By__c = 'Mailing Agent';
        subRecs.Term_Length__c = 1;//joy
        subRecs.Term_Length1__c = '1';//joy
        subRecs.Frequency_1__c = GlobalVariableClass.FREQ_DEFAULT;
        database.insert(subRecs);
        
        system.debug(subRecs.Zuora__SubscriptionEndDate__c);
        
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Base_Subscription__c = subRecs.id;// joy
        ord.Order_Type__c = 'Renewal'; //joy
        
        database.insert(ord);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = ord.Id;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = date.today()+3;// joy
        database.insert(orderline);
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = [SELECT Main_Package_1__c, Id FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Main_Package_1__c;
        packItem.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType='Package_Item__c' AND Name = 'Base Product'].Id;
        packItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(packItem);
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs.Id;
            if(counter==0){
                sp.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
            }
            else{
                sp.Zuora__Model__c = 'model';
            }
            sp.Zuora__ProductName__c = 'discount';
            sp.Zuora__EffectiveStartDate__c = date.today()+3;
            sp.Zuora__Quantity__c = 3;
            sp.Zuora__RatePlanName__c = 'Name';
            sp.Zuora__ProductSKU__c = 'SKU';
            sp.Zuora__UOM__c = 'CREDIT';
            sp.Zuora__Price__c = 100;
            counter++;
        }
        database.insert(spc);
        set<string> uomSet = new set<string>();
                uomSet.add(spc[0].Zuora__UOM__c);             
                
        counter=0;
        List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(5);
        for(zqu__ProductRatePlanCharge__c pro:zprpc){
            pro.zqu__ProductRatePlan__c = prp[1].Id;
            pro.PublicationCode__c = 'N';
            if(counter==0){
                pro.zqu__UOM__c = 'Credit Copy Sat';   
            }
            else if(counter==1){
                pro.zqu__UOM__c = 'Credit Copy Tablet';   
            }
            else if(counter==2){
                pro.zqu__UOM__c = 'Credit Copy AIO Tablet';   
            }
            else if(counter==3){
                pro.zqu__UOM__c = 'Credit Copy AIO Online';   
            }
            else{
                pro.zqu__UOM__c = 'Credit Copy AIO Smartphon';   
            }
            counter++;
        }
        database.insert(zprpc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(6);
        for(Publication__c p : pub){
            p.Publication_Code__c = 'N';
            if(counter==0){
                p.Platform_Type__c = 'Print';
            }
            else if (counter==1){
                p.Platform_Type__c = 'All in One (AIO)';
                p.Publication_Platform_AIO__c = GlobalVariableClass.ONLINE;
            }
            else if (counter==1){
                p.Platform_Type__c = 'AIO Tablet';
            }
            else if(counter==2){
                p.Platform_Type__c = 'AIO Online';
            }
            else if (counter==3){
                p.Platform_Type__c = 'All in One (AIO)';
                p.Publication_Platform_AIO__c = GlobalVariableClass.SMARTPHONE;
            }
            else{
                p.Platform_Type__c = 'All in One (AIO)';
                p.Publication_Platform_AIO__c = GlobalVariableClass.TABLET;
            }
            p.Publication_Type__c = 'M';
            counter++;
        }
        database.insert(pub);
        
        Non_Publication_Day__c nonPub = TestDataFactory.createNonPublicationDay(1)[0];
        nonPub.Publication_Code__c = 'N';
        nonPub.Publication__c =pub[0].Id;//joy  
        database.insert(nonPub);
        
        Subscription_Temp_Stop__c stc = new Subscription_Temp_Stop__c();
        stc.Subscription__c = subRecs.Id;
        
        test.startTest();
        try
        {
            RefundComputation.computeRefund(subRecs.Id, date.today());  
            //RefundComputation.computeRefund(subRecs.id, subRecs.Zuora__SubscriptionStartDate__c);
            RefundComputation.computeMonthlyPayment(pub, 10);
            RefundComputation.retrieveValidPublications(pub, date.today());
            RefundComputation.convertSubFreq(pub[0], prp[0]);
            RefundComputation.convertSubFreq(pub[1], prp[0]);
            RefundComputation.computeDiscount(pub, date.today(), date.today()+5);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
            
           
           
        test.stopTest();
    }
    
    static testmethod void testSample()
    {
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);
        
        Key_Id__c keys = new Key_Id__c();
        keys.Name = 'Package Item_Base Product';
        keys.Type__c = 'RecordType';
        keys.Id__c = '012N00000008l2LIAQ';
        database.insert(keys);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Price__c=100.00;
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU';
        zp.ProductPlatform__c = 'All-In-One';
        database.insert(zp);
        
        Integer counter=0;
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pr:prp){
            if(counter==0){
                pr.RatePlanType__c = 'Bill Plan';
                pr.SubscriptionFrequency__c = '0';
            }
            else{
                pr.RatePlanType__c = 'Proration';
                pr.SubscriptionFrequency__c = '1';
            }
            pr.zqu__ZProduct__c = zp.Id;
            pr.Name = 'Name';
            pr.RatePlanSubType__c = 'Standard';
            pr.zqu__Deleted__c = false;
            counter++;
        }
        database.insert(prp);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        //ord.Base_Subscription__c = subRecs.id;// joy
        ord.Order_Type__c = 'Renewal'; //joy
        
        database.insert(ord);
        
       Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = ord.Id;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = date.today()+3;
        database.insert(orderline);

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Main_Package__c = pack.Id;
        subRecs.Zuora__SubscriptionEndDate__c = System.today()+2; //joy
        subRecs.Term_Length1__c = '1';
        subRecs.Term_Length__c = 1;
        subRecs.Zuora__SubscriptionStartDate__c = System.today();
        subRecs.Zuora__TermSettingType__c = GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED;
        subRecs.Billing_Type__c = 'Full Prepaid';             
        subRecs.Order_Line_Item_Number__c = orderline.Id;
        subRecs.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
        subRecs.Qty1__c = '3.3';
        subRecs.Qty__c = 3;
        subRecs.Number_of_Copies__c = 3;
        subRecs.Number_of_Copies1__c =  '3';
        subRecs.Delivered_By__c = 'Mailing Agent';//
        subRecs.Frequency__c = 'Mon - Fri';
        subRecs.Frequency_1__c =  'Mon - Fri';
        subRecs.Order_Line_Item_Number_1__c=orderline.id;
        subRecs.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
        subRecs.Delivered_By_1__c = 'Mailing Agent';
        database.insert(subRecs);
        
        system.debug(subRecs.Zuora__SubscriptionEndDate__c);
        
        
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = [SELECT Main_Package_1__c, Id FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Main_Package_1__c;
        packItem.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType='Package_Item__c' AND Name = 'Base Product'].Id;
        packItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(packItem);
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs.Id;
            if(counter==0){
                sp.Zuora__Model__c = 'model';
            }
            else{
                sp.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
            }
            sp.Zuora__ProductName__c = 'discount';
            sp.Zuora__EffectiveStartDate__c = date.today().addDays(-1);
            sp.Zuora__Quantity__c = 3;
            sp.Zuora__RatePlanName__c = 'Name';
            sp.Zuora__ProductSKU__c = 'SKU';
            sp.Zuora__UOM__c = 'CREDIT';
            sp.Zuora__Price__c = 100;
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(4);
        for(Publication__c p : pub){
            p.Publication_Code__c = 'D';
            if(counter==0){
                p.Platform_Type__c = 'Print';
            }
            else if(counter==1){
                //p.Platform_Type__c = GlobalVariableClass.ONLINE;
                p.Platform_Type__c = 'All in One (AIO)';
               
            }
            else if(counter==2){
                p.Platform_Type__c = 'Smartphone';
            }
            else{
                p.Platform_Type__c = 'Tablet';
            }
            p.Publication_Type__c = 'M';
            p.Published_Days__c = 'YYYYYYY';
            p.Frequency_Code__c='D';
            p.Name = 'Name';
            counter++;
        }
        database.insert(pub);
        
        counter = 0;
        List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(8);
        for(zqu__ProductRatePlanCharge__c pro:zprpc){
            pro.zqu__ProductRatePlan__c = prp[1].Id;
            pro.PublicationCode__c = 'D';
            if(counter==0){
                pro.zqu__UOM__c = 'Credit Copy Weekday';   
            }
            else if(counter==1){
                pro.zqu__UOM__c = 'Credit Copy Sun';   
            }
            else if(counter==2){
                pro.zqu__UOM__c = 'Credit Copy Issue D';   
            }
            else if(counter==3){
                pro.zqu__UOM__c = 'Credit Copy Online';   
            }
            else if(counter==4){
                pro.zqu__UOM__c = 'Credit Copy Smartphone';   
            }
            else if(counter==5){
                pro.zqu__UOM__c = 'Credit Copy AIO Smartphon';
            }
            else if(counter==6){
                pro.zqu__UOM__c = 'Credit Copy Month N';
            }
            /*else{
                pro.zqu__UOM__c = 'Credit Copy AIO Name';
                
            }*/
            else if(counter==7){
                pro.zqu__UOM__c = 'Credit Copy Tablet';
            }
            else if(counter==8) {
                pro.zqu__UOM__c = 'Credit Copy Sat';
            } 
             else if(counter==9) {
                pro.zqu__UOM__c = 'Credit Copy AIO Online';
            }
            else {
                pro.zqu__UOM__c = 'Credit Copy AIO Tablet';
            }
             
           
            
            counter++;
        }
        database.insert(zprpc);
        
       
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
        for(Non_Publication_Day__c np:nonPub){
            np.Publication_Code__c = 'D'; 
            np.Publication__c =pub[0].Id;//joy  
        }
        database.insert(nonPub);
    
        test.startTest();
            RefundComputation.computeRefund(subRecs.id, system.today().addDays(1));
            RefundComputation.computeDiscount(pub, system.today(), system.today().addDays(1));
            
           
          
           
        test.stopTest();
    }
    
     static testmethod void testSample2() //:p
    {
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);
        
        Key_Id__c keys = new Key_Id__c();
        keys.Name = 'Package Item_Base Product';
        keys.Type__c = 'RecordType';
        keys.Id__c = '012N00000008l2LIAQ';
        database.insert(keys);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Price__c=100.00;
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU';
        zp.ProductPlatform__c = 'All-In-One';
        database.insert(zp);
        
        Integer counter=0;
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pr:prp){
            if(counter==0){
                pr.RatePlanType__c = 'Bill Plan';
                pr.SubscriptionFrequency__c = '2';
            }
            else{
                pr.RatePlanType__c = 'Proration';
                pr.SubscriptionFrequency__c = '3';
            }
            pr.zqu__ZProduct__c = zp.Id;
            pr.Name = 'Name';
            pr.RatePlanSubType__c = 'Standard';
            pr.zqu__Deleted__c = false;
            counter++;
        }
        database.insert(prp);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        //ord.Base_Subscription__c = subRecs.id;// joy
        ord.Order_Type__c = 'Renewal'; //joy
        
        database.insert(ord);
        
       Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = ord.Id;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Start_Date__c = date.today()+3;
        database.insert(orderline);

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Main_Package__c = pack.Id;
        subRecs.Zuora__SubscriptionEndDate__c = System.today()+2; //joy
        subRecs.Term_Length1__c = '1';
        subRecs.Term_Length__c = 1;
        subRecs.Zuora__SubscriptionStartDate__c = System.today();
        subRecs.Zuora__TermSettingType__c = GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED;
        subRecs.Billing_Type__c = 'Recurring Prepaid';     
        //subRecs.Billing_Type__c = 'Full Prepaid';              
        subRecs.Order_Line_Item_Number__c = orderline.Id;
        subRecs.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
        subRecs.Qty1__c = '3.3';
        subRecs.Qty__c = 3;
        subRecs.Number_of_Copies__c = 3;
        subRecs.Number_of_Copies1__c =  '3';
        subRecs.Delivered_By__c = 'Mailing Agent';
        subRecs.Frequency__c = 'Mon - Fri';
        subRecs.Frequency_1__c =  'Mon - Fri';
        subRecs.Order_Line_Item_Number_1__c=orderline.id;
        subRecs.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
        subRecs.Delivered_By_1__c = 'Mailing Agent';
        subRecs.Postage_Charge__c = 3.50;
        database.insert(subRecs);
        
        system.debug(subRecs.Zuora__SubscriptionEndDate__c);
        
        
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = [SELECT Main_Package_1__c, Id FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Main_Package_1__c;
        packItem.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType='Package_Item__c' AND Name = 'Base Product'].Id;
        packItem.Product_Rate_Plan__c = prp[0].Id;
        database.insert(packItem);
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs.Id;
            if(counter==0){
                sp.Zuora__Model__c = 'model';
            }
            else{
                sp.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
            }
            sp.Zuora__ProductName__c = 'discount';
            sp.Zuora__EffectiveStartDate__c = date.today().addDays(-1);
            sp.Zuora__Quantity__c = 3;
            sp.Zuora__RatePlanName__c = 'Name';
            sp.Zuora__ProductSKU__c = 'SKU';
            sp.Zuora__UOM__c = 'CREDIT';
            sp.Zuora__Price__c = 100;
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(4);
        for(Publication__c p : pub){
            p.Publication_Code__c = 'D';
            if(counter==0){
                p.Platform_Type__c = 'Print';
            }
            else if(counter==1){
                p.Platform_Type__c = GlobalVariableClass.ONLINE;
            }
            else if(counter==2){
                p.Platform_Type__c = 'Smartphone';
            }
          /*  else{
                p.Platform_Type__c = 'Tablet';
            }*/
            
            else if(counter==3){
                p.Platform_Type__c = 'Tablet';
            }
            else{
                p.Platform_Type__c = 'All in One (AIO)';
              
                
            }
            p.Publication_Type__c = 'M';
            p.Published_Days__c = 'YYYYYYY';
            p.Frequency_Code__c='D';
            p.Name = 'Name';
            counter++;
        }
        database.insert(pub);
        
        counter = 0;
        List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(8);
        for(zqu__ProductRatePlanCharge__c pro:zprpc){
            pro.zqu__ProductRatePlan__c = prp[1].Id;
            pro.PublicationCode__c = 'D';
            if(counter==0){
                pro.zqu__UOM__c = 'Credit Copy Weekday';   
            }
            else if(counter==1){
                pro.zqu__UOM__c = 'Credit Copy Sun';   
            }
            else if(counter==2){
                pro.zqu__UOM__c = 'Credit Copy Issue N';   
            }
            else if(counter==3){
                pro.zqu__UOM__c = 'Credit Copy Online';   
            }
            else if(counter==4){
                pro.zqu__UOM__c = 'Credit Copy Smartphone';   
            }
            else if(counter==5){
                pro.zqu__UOM__c = 'Credit Copy AIO Smartphon';
            }
            else if(counter==6){
                pro.zqu__UOM__c = 'Credit Copy Month D';
            }
            else{
                pro.zqu__UOM__c = 'Credit Copy AIO Tablet';
                
            }
            counter++;
     
           
        }
        database.insert(zprpc);
        
       
        List<Non_Publication_Day__c> nonPub = TestDataFactory.createNonPublicationDay(1);
        for(Non_Publication_Day__c np:nonPub){
            np.Publication_Code__c = 'D'; 
            np.Publication__c =pub[0].Id; //joy  
        }
        database.insert(nonPub);
        
        
        Subscription_Temp_Stop__c stc = new Subscription_Temp_Stop__c();
        stc.Subscription__c = subRecs.Id;
        
        test.startTest();
            RefundComputation.computeRefund(subRecs.id, system.today().addDays(1));
            RefundComputation.computeDiscount(pub, system.today(), system.today().addDays(1));
            RefundComputation.checkifRefundable (pub[0], prp[0], 'test');
            RefundComputation.convertSubFreq(pub[0], prp[0]);
            RefundComputation.retrieveValidPublications(pub, date.today());
           
            RefundComputation.getLastDayOfTheMonth(date.today()+2);   
                       
        test.stopTest();
    }
    
    
   
  
    
}