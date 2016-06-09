@isTest 
public class CaseTriggerHandlerTest2{
   
    @testSetup
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface();                 
        insert CustomSettingsDataFactory.createPlannerSched();
    } 
    
    static testMethod void testCaseTriggerHandlerTestSingle(){
            
        User userU = TestDataFactory.prepareTestusers();    
        
        System.runAs(userU){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
        
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = rec.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            database.insert(con2);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);

            //Start D-4452 02-Apr-2016 Added By S.Puli        
            Case casRec = new Case();
            casRec.Current_Date_for_Year_To_Date__c = 1;
            database.insert(casRec);
            
            Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
            tempS.Order__c = ord.Id;
            tempS.Case__c = casRec.Id;
            database.insert(tempS);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc[0].Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type_1__c = 'Publication';
            database.insert(sub);
            //End D-4452 02-Apr-2016 Added By S.Puli        
            test.startTest();
            
           
           // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
           // system.assertNotEquals(orders.Id, null);
            
            Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
            cas.Account__c = acc.id;
            cas.Account = acc;
            cas.recipient_address__c = ad.Id;
            cas.Order__c = ord.Id;
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
            cas.ContactID = con.Id;
            cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas.Contact_To_Update__c = con.id;
             //cas.Subscription_Name__c = sub.Id;
     
            database.insert(cas);
            
           /* Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Case__c = cas.Id;
            caseSub.Subscription__c = sub.Id;
            database.insert(caseSub);
            
            //System.assertEquals(cas.Order__r.Recipient_Type__c, 'Overseas');
            
            Usage__c u = new Usage__c();
            u.Case__c = cas.Id;
            u.Status__c = GlobalVariableClass.STATUS_NEW;
            u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
            u.Subscription_Id__c = sub.Name;
            database.insert(u);
            */
            cas.Subject = 'New Subject';
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
            cas.New_Address__c = ad.Id;
            database.update(cas);
            
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change in Address');
            cas.Sub_Status__c = GlobalVariableClass.URGENTCOAAPPROVED;
            cas.ContactID = con2.Id;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyID('Case_Adjustments');
            cas.Status = GlobalVariableClass.STATUS_PENDING;
            cas.Sub_Status__c = 'Approved';
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas.Rejected_Renewal__c = true;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            //Start D-4452 02-Apr-2016 Added By S.Puli
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            //cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            //cas.Status = 'Void';
            //database.update(cas);
            
            cas.Rejected_Renewal__c = true;
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
            cas.Requires_Urgent_Approval__c = true;
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            cas.Sub_Status__c = GlobalVariableClass.TEMP_STOP_APPROVED;
            cas.Order__c = ord.Id;
            cas.Temp_stop__c = tempS.Id;
            cas.Temp_Stop_Sub__c = sub.Id;
            cas.AccountId = acc.Id;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            //cas.Outcome__c = 'Retained';
            //cas.Urgent_Request__c = true;
            //cas.Sub_Status__c = 'Waiting for Urgent Stop Approval';
            //cas.Original_Owner__c = GlobalVariableClass.RECALLED;
           // database.update(cas); 
            //database.insert(cas);
            
            //Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            //caseSub.isComplaint__c = false;
            //caseSub.Case__c = cas.Id;
            //caseSub.Subscription__c = sub.Id;
            //database.insert(caseSub);
            //End D-4452 02-Apr-2016 Added By S.Puli        
            //System.assertEquals(cas.Order__r.Recipient_Type__c, 'Overseas');
            
            Usage__c u = new Usage__c();
            u.Case__c = cas.Id;
            u.Status__c = GlobalVariableClass.STATUS_NEW;
            u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
            u.Subscription_Id__c = sub.Name;
            try{
                database.insert(u);
            }catch(exception e){
                system.debug(e);
            }
            
            try{
                database.delete(cas); 
            }catch(exception e){
                system.debug(e);
            }
            test.StopTest();
        }   
    }
    
    //Start D-4452 02-Apr-2016 Added By S.Puli
    static testMethod void testCaseTriggerHandlerTestVoidCase(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        packageList[0].Package_Code__c = 'packsample';
        packageList[0].Subscription_Type__c = 'Termed';
        packageList[0].Package_Sub_Type__c = 'Single';
        packageList[0].Subscription_Period__c = '12';
        packageList[0].Billing_Type__c = 'Full Prepaid';
        insert packageList;
        
        //Start Prod Cat Setup
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0]; //try to loop with many product sub type
        zProduct.ProductPlatform__c = 'Print';
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.ProductCode__c = 'STSU';
        insert zProduct;
        
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.SubscriptionFrequency__c = '2';
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        insert prdRatePlan;
        
       
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'TestNAme';
        insert prodfam;
       
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = packageList[0].Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
        integer count = 0;
        for (Order_Line_Item__c obj : orderLineItemList) {
            obj.Order__c = ord.id;
            obj.Main_Package_ID__c = packageList[count].id;
            obj.Start_Date__c = Date.today().addDays(10);
            obj.Qty__c = 10;
            obj.Add_On_Package_Subscription_Rate__c = 10;
            
            count++;
        }
        insert orderLineItemList;
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Order_Line_Item_Number__c = string.valueof(orderLineItemList[0].Id);
        sub.Order_Line_Item_Number_1__c = orderLineItemList[0].Id;
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()+10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        database.insert(sub);
        //End D-4452 02-Apr-2016 Added By S.Puli 
        
        test.startTest();
        
       
       // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
       // system.assertNotEquals(orders.Id, null);
        CaseTriggerHandler.forcedDayOfMonth = 'Monday';
        Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cas.Account__c = acc.id;
        cas.Account = acc;
        cas.recipient_address__c = ad.Id;
        cas.Order__c = ord.Id;
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        cas.ContactID = con.Id;
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        cas.Contact_To_Update__c = con.id;
         //cas.Subscription_Name__c = sub.Id;
 
        database.insert(cas);
        
        CaseTriggerHandler.forcedDayOfMonth = 'Saturday';
        Case caseSat = TestDataFactory.createCase(1, 'Start Subscription')[0];
        caseSat.Account__c = acc.id;
        caseSat.Account = acc;
        caseSat.recipient_address__c = ad.Id;
        caseSat.Order__c = ord.Id;
        caseSat.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        caseSat.ContactID = con.Id;
        caseSat.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        caseSat.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        caseSat.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        caseSat.Contact_To_Update__c = con.id;
         //cas.Subscription_Name__c = sub.Id;
 
        database.insert(caseSat);
        
        
        CaseTriggerHandler.forcedDayOfMonth = 'Sunday';
        Case casSun = TestDataFactory.createCase(1, 'Start Subscription')[0];
        casSun.Account__c = acc.id;
        casSun.Account = acc;
        casSun.recipient_address__c = ad.Id;
        casSun.Order__c = ord.Id;
        casSun.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        casSun.ContactID = con.Id;
        casSun.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        casSun.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        casSun.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        casSun.Contact_To_Update__c = con.id;
         //cas.Subscription_Name__c = sub.Id;
 
        database.insert(casSun);
        
        CaseTriggerHandler.forcedDayOfMonth = 'Testday';
        Case casTest = TestDataFactory.createCase(1, 'Start Subscription')[0];
        casTest.Account__c = acc.id;
        casTest.Account = acc;
        casTest.recipient_address__c = ad.Id;
        casTest.Order__c = ord.Id;
        casTest.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        casTest.ContactID = con.Id;
        casTest.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        casTest.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        casTest.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        casTest.Contact_To_Update__c = con.id;
         //cas.Subscription_Name__c = sub.Id;
 
        database.insert(casTest);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Account__c = acc.Id;
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = sub.Id;
        caseSub.isComplaint__c = false;
        database.insert(caseSub);
        
        //System.assertEquals(cas.Order__r.Recipient_Type__c, 'Overseas');
        /*
        Usage__c u = new Usage__c();
        u.Case__c = cas.Id;
        u.Status__c = GlobalVariableClass.STATUS_NEW;
        u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
        u.Subscription_Id__c = sub.Name;
        database.insert(u);
        */
        cas.Subject = 'New Subject';
        cas.ContactID = con2.Id;
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
        cas.Rejected_Renewal__c = true;
        database.update(cas);
        //Start D-4452 02-Apr-2016 Added By S.Puli
        
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
        cas.Status = 'Void';
        database.update(cas);        
        
        database.delete(cas); 
        test.StopTest();
    }
    //End D-4452 02-Apr-2016 Added By S.Puli
    
   static testMethod void testCaseTriggerHandlerTestSingle2(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = (Id) ConstantsSLB.getKeyId('Address_Overseas');
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Order__c order = [SELECT Id, Recipient_Type__c FROM Order__c WHERE Id=:ord.Id];
        system.assertEquals(order.Recipient_Type__c, 'Overseas');
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Accountid = acc.Id;
        cas.Account__c = acc.id;
        cas.Account = acc;        
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        cas.recipient_address__c = ad.Id;
        cas.Order__c = order.Id;
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        cas.Contact_To_Update__c = con.id;
       
        test.startTest();
        //system.assertEquals(string.valueOF(cas.order__r.Recipient_Type__c), string.valueOF(cas.order__c )+string.valueOf(order.Recipient_Type__c));
        //system.assertEquals(1,2);
        database.insert(cas);
        
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change of Subscription');
        cas.Order__c = ord.Id;
        cas.Charges_Waived__c = true;
        cas.Sub_Status__c = 'Waiting for Urgent Approval';
        database.update(cas);
        
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
        database.update(cas);
        
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_CHANGE_OF_SUB_COMPLETED;
        database.update(cas);
        
        acc.RecordTypeId = (Id) ConstantsSLB.getKeyId('Account_Vendor Subscriber');
        database.update(acc);
        
        cas.Account = [SELECT Id, RecordType.Name FROM Account WHERE Id=:acc.Id];
        database.update(cas);
        
        database.delete(cas);
       
        test.StopTest();
    }
    
    static testMethod void testCaseTriggerHandlerTestSingle3(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);    
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today()-45;
        database.insert(sub);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Accountid = acc.Id;
        cas.Account__c = acc.id;
        cas.Account = acc;
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
        cas.recipient_address__c = ad.Id;
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        cas.Contact_To_Update__c = con.id;
        
        test.startTest();
        
        database.insert(cas);
        
        Usage__c u = new Usage__c();
        u.Case__c = cas.Id;
        u.Status__c = GlobalVariableClass.STATUS_NEW;
        u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
        u.Subscription_Id__c = sub.Name;
        u.Start_Date__c = date.today()-45;
        database.insert(u);
        
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Complaint_Newspaper');
        cas.Status = GlobalVariableClass.STATUS_CLOSED;
        database.update(cas);
        
        cas.Admin_Charges__c = 99;
        cas.Sub_Status__c = 'Waiting for Waiver Approval';
        cas.Record_Locked__c = true;
        database.update(cas);
        
        cas.Admin_Charges__c = 499;
        database.update(cas);
        
        cas.Admin_Charges__c = 1000;
        cas.Sub_Status__c = 'Request Recalled';
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
        cas.Urgent_Request__c = true;
        cas.Original_Owner__c = null;
        //database.update(cas);
        
        database.delete(cas);
       
        test.StopTest();
    }
    
    static testMethod void testCaseTriggerHandlerTestSingle4(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Next_Year_Temp_Stop_Days__c = null;
        sub.Year_to_Date_Temp_Stop_Days__c = null;
        database.insert(sub);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        database.insert(tempS);
        
        Order__c order = [SELECT id, Recipient_Type__c FROM Order__c WHERE id=:ord.Id AND Recipient_Type__c = 'Overseas'];
        system.assertEquals(order.Recipient_Type__c, 'Overseas');
        
        Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cas.recipient_address__c = ad.Id;
        cas.AccountId = acc.id;
        cas.Account = acc;
        cas.Account__c = acc.id;
        cas.Order__c = order.Id;
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        cas.Temp_stop__c = temps.id;
        cas.Temp_Stop_Sub__c = sub.Id;
        cas.Temp_Stop_Type__c = 'Create';
        cas.Sub_Status__c = 'Temp Stop Rejected';
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        cas.Contact_To_Update__c = con.id;
       // cas.Temp_Stop_Updated__c = tempS.Id;
 
        test.startTest();
        
        database.insert(cas);
        
        tempS.Case__c = cas.Id;
        database.update(tempS);
        
        sub.Next_Year_Temp_Stop_Days__c = null;
        sub.Year_to_Date_Temp_Stop_Days__c = null;
        database.update(sub);
        
        cas.recipient_address__c = ad.Id;
        cas.Order__c = order.Id;
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        cas.Temp_Stop_Sub__c = sub.Id;
        cas.Temp_Stop_Type__c = 'Update';
        cas.Temp_Stop_Updated__c = tempS.Id;
        cas.Next_Year_for_Year_To_Date__c = 30;
        cas.Sub_Status__c = 'Temp Stop Approved';
        
        database.update(cas);
        
        cas.Sub_Status__c = 'Temp Stop Rejected';
        database.update(cas);
        
        tempS.Case__c = cas.Id;
        database.update(tempS);
        
        sub.Next_Year_Temp_Stop_Days__c = null;
        sub.Year_to_Date_Temp_Stop_Days__c = null;
        database.update(sub);
        
        cas.recipient_address__c = ad.Id;
        cas.Order__c = order.Id;
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        cas.Temp_Stop_Sub__c = sub.Id;
        cas.Temp_Stop_Type__c = 'Cancel';
        cas.Temp_Stop_Updated__c = tempS.Id;
        cas.Next_Year_for_Year_To_Date__c = 30;
        cas.Sub_Status__c = 'Temp Stop Approved';
        cas.Temp_Stop__c = tempS.Id;
        
        database.update(cas);
        
        test.StopTest();
    }
  
    static testMethod void testCaseTriggerHandlerTestBulk(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas' LIMIT 1].Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Address__c = ad.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        database.insert(sub);
    //Start D-4452 02-Apr-2016 Added By S.Puli        
        //Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        //tempS.Order__c = ord.Id;
        
        //database.insert(tempS);
        
        Order__c order = [SELECT id, Recipient_Type__c FROM Order__c WHERE id=:ord.Id];
        system.assertEquals(order.Recipient_Type__c, 'Overseas');
        
        Case ca = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        ca.Next_Year_for_Year_To_Date__c = 5;
        database.insert(ca);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = order.Id;
        tempS.Case__c = ca.Id;
        database.insert(tempS);
    //End D-4452 02-Apr-2016 Added By S.Puli        
        Id CASE_START_SUB_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        Id CASE_TEMP_STOP_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
        Id news = ConstantsSLB.getKeyId('Complaint_Newspaper');
    
        List<Case> cas = TestDataFactory.createCase(200, 'Complaint - Magazine');
        Integer i = 0;
        for(Case c : cas){
            if(i==0){
                c.RecordTypeId = CASE_TEMP_STOP_TYPE_ID;
            }
            else if(i==1){
                c.RecordTypeId = CASE_START_SUB_TYPE_ID;
            }   
            else{
                c.RecordTypeId = news;  
            }
            c.recipient_address__c = ad.Id;
            c.Order__c = order.Id;
            c.AccountId = acc.Id;
            c.Temp_Stop__c = tempS.id;
            c.Temp_Stop_Updated__c = tempS.Id;
            c.Temp_Stop_Sub__c = sub.Id;
            c.Temp_Stop_Type__c = 'cancel';
            c.Next_Year_for_Year_To_Date__c = 2016;
            c.Current_Date_for_Year_To_Date__c = 2015;
            i++;
        }
        
        test.startTest();
        
        database.insert(cas);
        
        
        temps.Case__c = cas[0].id;
        update temps;
       
        
        cas[0].RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Refund');
        cas[0].Approved_Refund__c = true;
        cas[0].Sub_Status__c = 'Goodwill Approved';
        cas[0].Status = 'Closed';
        cas[0].AccountId = acc.id;
        cas[0].Account__c = acc.id;
        cas[0].Account = acc;
        cas[0].Contact_To_Update__c = con.id;
        database.update(cas);
        
        cas[1].RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        cas[1].Status = 'Closed';
        cas[1].Sub_Status__c = GlobalVariableClass.URGENT_START_REJECTED;
        cas[1].AccountId = acc.id;
        cas[1].Account__c = acc.id;
        cas[1].Account = acc;
        cas[1].Contact_To_Update__c = con.id;
        database.update(cas);
        
        database.delete(cas);
        
        test.StopTest();
    }   
    /***
    static testMethod void testCreateInvoiceAdjustment01() {
    
        //TestData
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas' LIMIT 1].Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Address__c = ad.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        database.insert(sub);
    //Start D-4452 02-Apr-2016 Added By S.Puli        
        Case casRec = new Case();
        casRec.Current_Date_for_Year_To_Date__c = 1;
        database.insert(casRec);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = casRec.Id;
        database.insert(tempS);

        Order__c order = [SELECT id, Recipient_Type__c FROM Order__c WHERE id=:ord.Id];
        system.assertEquals(order.Recipient_Type__c, 'Overseas');
        
        Id CASE_START_SUB_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        Id CASE_TEMP_STOP_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
        Id news = ConstantsSLB.getKeyId('Complaint_Newspaper');
    
        List<Case> cas = TestDataFactory.createCase(3, 'Complaint - Magazine');
        Integer i = 0;
        for(Case c : cas){
            if(i==0){
                c.RecordTypeId = CASE_TEMP_STOP_TYPE_ID;
            }
            else if(i==1){
                c.RecordTypeId = CASE_START_SUB_TYPE_ID;
            }   
            else{
                c.RecordTypeId = news;  
            }
            c.recipient_address__c = ad.Id;
            c.Order__c = order.Id;
            c.AccountId = acc.Id;
            c.Temp_Stop_Updated__c = tempS.Id;
            c.Temp_Stop_Sub__c = sub.Id;
            c.Temp_Stop_Type__c = 'Cancel';
            c.Temp_stop__c = temps.id;
            c.Current_Date_for_Year_To_Date__c = 1;
            i++;
        }
        database.insert(cas);
    
        Set<Id> adjustmentIdSet = new Set<Id>();
        
        for(Case c : cas){
            adjustmentIdSet.add(c.id);
        }
            
        //Test Proper
        Test.startTest();
        CaseTriggerHandler.createInvoiceAdjustment(adjustmentIdSet);
        Test.stopTest();
    }***/
    /***
    static testMethod void testCreateInvoiceAdjustment02() {
    
        //TestData
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas' LIMIT 1].Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Address__c = ad.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        database.insert(sub);
        
        Case casRec = new Case();
        casRec.Current_Date_for_Year_To_Date__c = 1;
        database.insert(casRec);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = casRec.Id;
        database.insert(tempS);
        
        Order__c order = [SELECT id, Recipient_Type__c FROM Order__c WHERE id=:ord.Id];
        system.assertEquals(order.Recipient_Type__c, 'Overseas');
        
        Id CASE_START_SUB_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        Id CASE_TEMP_STOP_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
        Id news = ConstantsSLB.getKeyId('Complaint_Newspaper');
    
        List<Case> cas = TestDataFactory.createCase(3, 'Complaint - Magazine');
        Integer i = 0;
        for(Case c : cas){
            if(i==0){
                c.RecordTypeId = CASE_TEMP_STOP_TYPE_ID;
            }
            else if(i==1){
                c.RecordTypeId = CASE_START_SUB_TYPE_ID;
            }   
            else{
                c.RecordTypeId = news;  
            }
            c.recipient_address__c = ad.Id;
            c.Order__c = order.Id;
            c.AccountId = acc.Id;
            c.Temp_Stop_Updated__c = tempS.Id;
            c.Temp_Stop_Sub__c = sub.Id;
            c.Temp_Stop_Type__c = 'Update';
            c.Temp_stop__c = temps.id;
            c.Current_Date_for_Year_To_Date__c = 1;
            i++;
        }
        database.insert(cas);
    
        Set<Id> adjustmentIdSet = new Set<Id>();
        
        for(Case c : cas){
            adjustmentIdSet.add(c.id);
        }
            
        //Test Proper
        Test.startTest();
        CaseTriggerHandler.createInvoiceAdjustment(adjustmentIdSet);
        Test.stopTest();
    }
    ***/
    //End D-4452 02-Apr-2016 Added By S.Puli
    /***
    static testMethod void testSetCaseYearToDate01() {
        
        //Test Data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Overseas' LIMIT 1].Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Address__c = ad.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        database.insert(sub);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        database.insert(tempS);
        
        Order__c order = [SELECT id, Recipient_Type__c FROM Order__c WHERE id=:ord.Id];
        system.assertEquals(order.Recipient_Type__c, 'Overseas');
        
        Id CASE_START_SUB_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
        Id CASE_TEMP_STOP_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
        Id news = ConstantsSLB.getKeyId('Complaint_Newspaper');
    
        //c.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && 
        //c.Status == GlobalVariableClass.STATUS_CLOSED && 
        //c.Sub_Status__c == 'Temp Stop Approved'){
        List<Case> cas = TestDataFactory.createCase(3, 'Complaint - Magazine');
        Integer i = 0;
        for(Case c : cas){
            if(i==0){
                c.RecordTypeId = CASE_TEMP_STOP_TYPE_ID;
            }
            else if(i==1){
                c.RecordTypeId = CASE_START_SUB_TYPE_ID;
            }   
            else{
                c.RecordTypeId = news;  
            }
            c.recipient_address__c = ad.Id;
            c.Order__c = order.Id;
            c.AccountId = acc.Id;
            c.Temp_Stop_Updated__c = tempS.Id;
            c.Temp_Stop_Sub__c = sub.Id;
            c.Temp_Stop_Type__c = 'cancel';
            i++;
        }
    //Start D-4452 02-Apr-2016 Added By S.Puli      
        cas[0].RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
        cas[0].Status = GlobalVariableClass.STATUS_CLOSED;
        cas[0].Sub_Status__c = 'Temp Stop Approved';
        cas[0].AccountId = acc.id;
        cas[0].Account__c = acc.id;
        cas[0].Account = acc;
        cas[0].Contact_To_Update__c = con.id;
        cas[0].Temp_Stop_Type__c = 'Create';
        cas[0].Current_Date_for_Year_To_Date__c = 1;
        Database.insert(cas);
    //End D-4452 02-Apr-2016 Added By S.Puli        
        Map<Id, Temp_Stop__c> caseToTempStopUpdatedMap = new Map<Id, Temp_Stop__c>();
        caseToTempStopUpdatedMap.put(cas[0].id, tempS);
        Set<String> pubCodeList = new Set<String>();
        Id subId = sub.id;
        Date start = Date.today();
        Date endDate = Date.today().addDays(1);
        Integer subYearToDateCount = 1;
        Integer subNextYearToDateCount = 1;
        Case caseRec = cas[0];
        
        List<Case> lstNewCases = cas;
        
        //Test Class
        CaseTriggerHandler testObj = new CaseTriggerHandler();
        
        //Set mapSub
        testObj.updateCaseYearToDateTempStop(lstNewCases);
        
        //Create
       // testObj.setCaseYearToDate(caseToTempStopUpdatedMap, pubCodeList, subId, start, endDate, subYearToDateCount, subNextYearToDateCount, caseRec);
        
        //Update
    }***/  
    
    static testMethod void testCaseTrigger() {
        try{
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber');
            database.insert(acc);
            
            RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
        
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = rec.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc[0].Id;
            sub.Next_Year_Temp_Stop_Days__c = null;
            sub.Year_to_Date_Temp_Stop_Days__c = null;
            database.insert(sub);
            
            Order__c orders = [SELECT id,Recipient_Type__c FROM Order__c WHERE Id=:ord.Id];
            system.assertNotEquals(orders.Id, null);
            system.assertEquals(orders.Recipient_Type__c, 'Overseas');
            
            Order_Line_Item_Vendor__c oliv = TestDataFactory.createOrderLineItemVendor(1)[0];
            oliv.Wrapper_Number__c = 5;
            oliv.Order__c = orders.Id;    
            database.insert(oliv);
            
            Case ca = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            ca.Next_Year_for_Year_To_Date__c = 5;
            database.insert(ca);
            
            Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
            tempS.Order__c = ord.Id;
            tempS.Case__c = ca.Id;
            database.insert(tempS);
            
            List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
            for(Zuora__SubscriptionProductCharge__c sp : spc){
                sp.Zuora__Subscription__c = sub.Id;
                sp.PublicationCode__c = 'N';
            }
            database.insert(spc);
            test.startTest();
            Integer counter = 0;
            List<Case> cases = TestDataFactory.createCase(11, 'Start Subscription');
//            List<Case> cases = TestDataFactory.createCase(11, 'Change of Subscription Packages');
            for(Case c : cases){
                c.recipient_address__c = ad.Id;
                c.Order__c = orders.Id;
                if(counter==0){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
                    c.Temp_Stop_Type__c = 'Cancel';
                    c.Requires_Urgent_Approval__c = true;
                    c.Status = 'Closed';
                }
                else if(counter==1){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
                    c.Temp_Stop_Type__c = 'Update';
                    c.Requires_Urgent_Approval__c = false;
                    c.Sub_Status__c = 'Urgent Start Approved';
                    c.Status = 'Closed';
                    c.Category__c = 'Subscription Request';
                    c.Sub_Category__c = 'Change of Subscription Packages';
                }
                else if(counter==2){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Complaint_Newspaper');
                    c.Temp_Stop_Type__c = 'Create';
                    c.Status = 'Closed';
                }
                else if(counter==3){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change in Address');
                    c.Temp_Stop_Type__c = 'Create';
                    c.Status = 'Closed';
                }
                else if(counter==4){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Stop');
                    c.Sub_Status__c = 'Subscription Stop Completed';
                    c.Sub_Status__c = 'Temp Stop Approved';
                    c.Status = 'Closed';
                }
                else if(counter==5){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
                    c.Temp_Stop_Type__c = 'Create';
                    c.Requires_Urgent_Approval__c = false;
                    c.Status = 'Pending';
                    c.Sub_Status__c = 'Ready for Subscription';
                    c.Category__c = 'Subscription Request';   
                    c.Sub_Category__c = 'Start Subscription';
                }
                else if(counter==6){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
                    c.Temp_Stop_Type__c = 'Update';
                    c.Requires_Urgent_Approval__c = false;
                    c.Sub_Status__c = 'Waiting for Urgent Start Approval';
                    c.Status = 'Pending';
                    c.Category__c = 'Subscription Request';
                    c.Sub_Category__c = 'Start Subscription';    
                }
                else if(counter==7){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
                    c.Temp_Stop_Type__c = 'Cancel';
                    c.Requires_Urgent_Approval__c = true;
                    c.Status = 'Pending';
                    c.Sub_Status__c = 'Waiting for Urgent Temp Stop/Restart Approval';
                    c.Origin = 'Email';
                }
                else if(counter==8){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change of Subscription');
                    c.Sub_Status__c = 'Waiting for Urgent Approval';
                    c.Status = 'Pending';
                }
                else if(counter==9){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case Renewal of Subscription');
                    c.Category__c = 'Subscription Request';
                    c.Sub_Category__c = 'Renewal of Subscription';
                    c.Sub_Status__c = 'Waiting for Urgent Start Approval';
                    c.Status = 'Pending';
                }
                else{
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change in Address');
                    c.Sub_Category__c = 'Change of Address';  
                    c.Status = 'Pending'; 
                    c.POP_Start_Date__c = date.today()+5;
                    c.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local'; 
                }
                c.ContactID = con.Id;
                c.Temp_Stop_Sub__c = sub.Id;
                c.Effective_Date__c = date.today()+1;
                c.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
                c.AccountId = acc.Id;
                c.Temp_Stop_Date__c = date.today()+1;
                c.Restart_Date__c = date.today()+5;
                c.Temp_Stop_Updated__c = tempS.Id;
                c.Qty__c = 3;
                c.Temp_Stop__c = tempS.Id;
                c.Next_Year_for_Year_To_Date__c = 5;
                c.Earliest_Stop_Date__c = date.today()+10;
                c.Stop_Request_Date__c = date.today()+2;
                c.Approval_Submitted__c = true;
                c.Vendor_Subscription_Created__c = false;
                //c.Account_Record_Type__c = GlobalVariableClass.VENDORSUB;
                counter++;
            }
            database.insert(cases);
            
            system.assertEquals(cases.size(), 11);
            system.assertEquals(cases[3].RecordTypeId, (Id) ConstantsSLB.getKeyId('Case_Change in Address'));
            
            List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
            for(Case_Subscription__c cs : caseSub){
                cs.Case__c = cases[3].Id;
                cs.Subscription__c = sub.Id;
            }
            database.insert(caseSub);
            
            Map<Id, Case> mapNewCases = new Map<Id, Case>();
            for(Case c : cases){
                mapNewCases.put(c.Id, c);
            }
            
            
                CaseTriggerHandler handler = new CaseTriggerHandler();
                handler.doBeforeInsert(cases);
                //handler.doAfterUpdate(cas,mapNewCases,cas,mapNewCases);
            test.stopTest();
        
        }catch(Exception e){}
    }
    
    static testMethod void testCaseTriggerHandlerTestDigiComp(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);

        //Start D-4452 02-Apr-2016 Added By S.Puli        
        Case casRec = new Case();
        casRec.Current_Date_for_Year_To_Date__c = 1;
        database.insert(casRec);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = casRec.Id;
        database.insert(tempS);
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        database.insert(billAcc);
        
        test.startTest();
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()-10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        
        database.insert(sub);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp : spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = 'N';
            sp.Name = GlobalVariableClass.GOODWILL_CREDIT + GlobalVariableClass.SPACE + GlobalVariableClass.COPY;
            sp.Zuora__Price__c = 0.5;
        }
        database.insert(spc);
        
        //End D-4452 02-Apr-2016 Added By S.Puli        
        
       
       // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
       // system.assertNotEquals(orders.Id, null);
        
        Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cas.Account__c = acc.id;
        cas.Account = acc;
        cas.recipient_address__c = ad.Id;
        cas.Order__c = ord.Id;
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Complaint Digital');
        cas.ContactID = con.Id;
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        cas.Contact_To_Update__c = con.id;
        cas.Subscription_Name__c = sub.Id;
        cas.Goodwill_Copies__c = 1;
        cas.Goodwill_Approval_Status__c = 'Approved';
        database.insert(cas);
        
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
        cas.Requires_Urgent_Approval__c = true;
        cas.Status = GlobalVariableClass.STATUS_CLOSED;
        cas.Sub_Status__c = GlobalVariableClass.TEMP_STOP_APPROVED;
        cas.Order__c = ord.Id;
        cas.Temp_stop__c = tempS.Id;
        cas.Temp_Stop_Sub__c = sub.Id;
        cas.AccountId = acc.Id;
        cas.Temp_Stop_Date__c = date.today()+1;
        database.update(cas);
        
        CaseTriggerHandler cth = new CaseTriggerHandler();
        //cth.getNextCase(sub.Id, cas);
        
        Test.StopTest();
  
    }
    
    static testMethod void testEnquiry(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);

        //Start D-4452 02-Apr-2016 Added By S.Puli        
        Case casRec = new Case();
        casRec.Current_Date_for_Year_To_Date__c = 1;
        database.insert(casRec);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = casRec.Id;
        database.insert(tempS);
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        database.insert(billAcc);
         test.startTest();
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()-10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        
        database.insert(sub);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp : spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = 'N';
            sp.Name = GlobalVariableClass.GOODWILL_CREDIT + GlobalVariableClass.SPACE + GlobalVariableClass.COPY;
            sp.Zuora__Price__c = 0.5;
        }
        database.insert(spc);
        
        //End D-4452 02-Apr-2016 Added By S.Puli        
        
       
       // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
       // system.assertNotEquals(orders.Id, null);
        
        Case casParent = TestDataFactory.createCase(1, 'Start Subscription')[0];
        casParent.Account__c = acc.id;
        casParent.Account = acc;
        casParent.recipient_address__c = ad.Id;
        casParent.Order__c = ord.Id;
        casParent.RecordTypeId = ConstantsSLB.getKeyId('Case_Enquiry');
        casParent.ContactID = con.Id;
        casParent.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        casParent.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        casParent.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        casParent.Contact_To_Update__c = con.id;
        casParent.Origin = GlobalVariableClass.Email_Preference;
        casParent.Goodwill_Copies__c = 1;
        casParent.Goodwill_Approval_Status__c = 'Approved';
        database.insert(casParent);
        //ParentId
        
        Case casChild = TestDataFactory.createCase(1, 'Start Subscription')[0];
        casChild.Account__c = acc.id;
        casChild.Account = acc;
        casChild.recipient_address__c = ad.Id;
        casChild.Order__c = ord.Id;
        casChild.RecordTypeId = ConstantsSLB.getKeyId('Case_Enquiry');
        casChild.ContactID = con.Id;
        casChild.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        casChild.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        casChild.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        casChild.Contact_To_Update__c = con.id;
        casChild.ParentId = casParent.Id;
        casChild.Goodwill_Copies__c = 1;
        casChild.Goodwill_Approval_Status__c = 'Approved';
        database.insert(casChild);
        
        Test.StopTest();
  
    }
    
    static testMethod void testUpdateSubEndDate(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        database.insert(pack);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = ord.Id;
        orderline.Main_Package_ID__c = pack.Id;
        database.insert(orderline);
        /***
        //Start D-4452 02-Apr-2016 Added By S.Puli        
        Case casRec = new Case();
        casRec.Current_Date_for_Year_To_Date__c = 1;
        database.insert(casRec);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = casRec.Id;
        database.insert(tempS);
        ***/
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        database.insert(billAcc);
         
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()-10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        sub.Order_Line_Item_Number_1__c = orderline.Id;
        
        database.insert(sub);
        
        Case casNotUrgent = TestDataFactory.createCase(1, 'Start Subscription')[0];
        casNotUrgent.Account__c = acc.id;
        casNotUrgent.Account = acc;
        casNotUrgent.recipient_address__c = ad.Id;
        casNotUrgent.Order__c = ord.Id;
        casNotUrgent.RecordTypeId = ConstantsSLB.getKeyId('Case_Enquiry');
        casNotUrgent.ContactID = con.Id;
        database.insert(casNotUrgent);
        
        test.startTest();
        
        casNotUrgent.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        casNotUrgent.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
        casNotUrgent.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
        casNotUrgent.Status = GlobalVariableClass.STATUS_PENDING;
        casNotUrgent.Urgent_Request__c = false;
        casNotUrgent.Approval_Submitted__c = true;
        casNotUrgent.Stop_Waive_Request__c = true;
        database.update(casNotUrgent);
        
        Test.StopTest();
  
    }
    
    static testMethod void testUpdateSubEndDateUrgent(){
        /*  
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        database.insert(pack);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = ord.Id;
        orderline.Main_Package_ID__c = pack.Id;
        database.insert(orderline);

        //Start D-4452 02-Apr-2016 Added By S.Puli        
        Case casRec = new Case();
        casRec.Current_Date_for_Year_To_Date__c = 1;
        try{
            database.insert(casRec);
        }catch(exception e){
            system.debug(e);
        }
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = casRec.Id;
        try{
            database.insert(tempS);
        }catch(exception e){
            system.debug(e);
        }
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        try{
            database.insert(billAcc);
        }catch(exception e){
            system.debug(e);
        }
         test.startTest();
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()-10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        sub.Order_Line_Item_Number_1__c = orderline.Id;
        
        try{
            database.insert(sub);
        }catch(exception e){
            system.debug(e);
        }
        
        Case casChild = TestDataFactory.createCase(1, 'Start Subscription')[0];
        casChild.Account__c = acc.id;
        casChild.Account = acc;
        casChild.recipient_address__c = ad.Id;
        casChild.Order__c = ord.Id;
        casChild.RecordTypeId = ConstantsSLB.getKeyId('Case_Enquiry');
        casChild.ContactID = con.Id;
        try{
            database.insert(casChild);
        }catch(exception e){
            system.debug(e);
        }
        
        Order_Line_Item__c oliStop = TestDataFactory.createOrderLineItem(1)[0];
        oliStop.Case__c = casChild.Id;
        oliStop.Stop_Request_Date__c = date.today()+2;
        oliStop.Main_Package_ID__c = pack.Id;
        oliStop.Order__c = ord.Id;
        try{
            database.insert(oliStop);
        }catch(exception e){
            system.debug(e);
        }
        
        casChild.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        casChild.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
        casChild.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
        casChild.Status = GlobalVariableClass.STATUS_PENDING;
        casChild.Urgent_Request__c = true;
        casChild.Approval_Submitted__c = true;
        try{
            database.update(casChild);
        }catch(exception e){
            system.debug(e);
        }
        
        Test.StopTest();
        */
    }
    
    static testMethod void testVendorStartSubCases(){
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Type__c = GlobalVariableClass.STRING_N;
        pub.Platform_Type__c = GlobalVariableClass.PLATFORM_PRINT;
        database.insert(pub);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Order_Line_Item_Vendor__c oliv = TestDataFactory.createOrderLineItemVendor(1)[0];
        oliv.Order__c = ord.Id;
        oliv.Publication__c = pub.Id;
        oliv.Start_Date__c = date.today()+1;
        oliv.Stop_Date__c = date.today()+365;
        database.insert(oliv);
        
        test.startTest();
        
        Case casNotUrgent = TestDataFactory.createCase(1, 'Start Subscription')[0];
        casNotUrgent.Account__c = acc.id;
        casNotUrgent.Account = acc;
        casNotUrgent.recipient_address__c = ad.Id;
        casNotUrgent.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
        casNotUrgent.ContactID = con.Id;
        casNotUrgent.Vendor_Subscription_Created__c = false;
        casNotUrgent.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBSCRIPTION;
        casNotUrgent.Order__c = ord.Id;
        database.insert(casNotUrgent);
        
        /**Subscription_Vendor_Publication__c svpub = TestDataFactory.createVendorPublication(1)[0];
        svpub.Account__c = acc.Id;
        svpub.Subscription_Vendor__c = venSub.Id;
        svpub.Mon__c = 1;
        svpub.Tue__c = 1;
        svpub.Wed__c = 1;
        svpub.Thu__c = 1;
        svpub.Fri__c = 1;
        svpub.Sat__c = 1;
        svpub.Sun__c = 0;
        svpub.PHd__c = 1;
        svpub.PHe__c = 0;
        database.insert(svpub);**/
        
        Test.StopTest();
  
    }
    
    static testMethod void testVendorStopSubCases(){
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Type__c = GlobalVariableClass.STRING_N;
        pub.Platform_Type__c = GlobalVariableClass.PLATFORM_PRINT;
        database.insert(pub);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        Order_Line_Item_Vendor__c oliv = TestDataFactory.createOrderLineItemVendor(1)[0];
        oliv.Order__c = ord.Id;
        oliv.Publication__c = pub.Id;
        oliv.Start_Date__c = date.today()+1;
        oliv.Stop_Date__c = date.today()+365;
        database.insert(oliv);
        
        Order__c ordStop = TestDataFactory.createOrder(1)[0];
        ordStop.Account__c = acc.Id;
        ordStop.Recipient_Contact__c = con.Id;
        database.insert(ordStop);
        
        Order_Line_Item_Vendor__c olivStop = TestDataFactory.createOrderLineItemVendor(1)[0];
        olivStop.Order__c = ordStop.Id;
        olivStop.Publication__c = pub.Id;
        olivStop.Start_Date__c = date.today()+1;
        database.insert(olivStop);
        
        test.startTest();
        
        Case casNotUrgent = TestDataFactory.createCase(1, 'Start Subscription')[0];
        casNotUrgent.Account__c = acc.id;
        casNotUrgent.Account = acc;
        casNotUrgent.recipient_address__c = ad.Id;
        casNotUrgent.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
        casNotUrgent.ContactID = con.Id;
        casNotUrgent.Vendor_Subscription_Created__c = false;
        casNotUrgent.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBSCRIPTION;
        casNotUrgent.Order__c = ord.Id;
        database.insert(casNotUrgent);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.Id;
        subVen.Subscription_Start_Date__c = date.today()+1;
        subVen.Subscription_Stop_Date__c = date.today()+365;
        subVen.Order_Number__c = ordStop.Id;
        subVen.Recipient__c = con.Id;
        database.insert(subVen);
        
        Case_Vendor_Subscription__c csVen = TestDataFactory.createCaseVendorSub(1)[0];
        csVen.Account__c = acc.Id;
        csVen.Case__c = casNotUrgent.Id;
        csVen.Subscription_Vendor__c = subVen.Id;
        csVen.Address__c = ad.Id;
        database.insert(csVen);
        
        casNotUrgent.Account__c = acc.id;
        casNotUrgent.Account = acc;
        casNotUrgent.recipient_address__c = ad.Id;
        casNotUrgent.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
        casNotUrgent.ContactID = con.Id;
        casNotUrgent.Vendor_Subscription_Created__c = false;
        casNotUrgent.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBSCRIPTION;
        casNotUrgent.Order__c = ordStop.Id;
        casNotUrgent.Status = GlobalVariableClass.STATUS_VOID;
        database.update(casNotUrgent);
        
        /**Subscription_Vendor_Publication__c svpub = TestDataFactory.createVendorPublication(1)[0];
        svpub.Account__c = acc.Id;
        svpub.Subscription_Vendor__c = venSub.Id;
        svpub.Mon__c = 1;
        svpub.Tue__c = 1;
        svpub.Wed__c = 1;
        svpub.Thu__c = 1;
        svpub.Fri__c = 1;
        svpub.Sat__c = 1;
        svpub.Sun__c = 0;
        svpub.PHd__c = 1;
        svpub.PHe__c = 0;
        database.insert(svpub);**/
        
        Test.StopTest();
  
    }
    
    static testMethod void testGetNextCase(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        database.insert(billAcc);
        
        test.startTest();
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()-10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        
        database.insert(sub);
        
        //End D-4452 02-Apr-2016 Added By S.Puli        
        
       
       // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
       // system.assertNotEquals(orders.Id, null);
        
        Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cas.Account__c = acc.id;
        cas.Account = acc;
        cas.recipient_address__c = ad.Id;
        cas.Order__c = ord.Id;
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Complaint Digital');
        cas.ContactID = con.Id;
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        cas.Contact_To_Update__c = con.id;
        cas.Subscription_Name__c = sub.Id;
        cas.Goodwill_Copies__c = 1;
        cas.Goodwill_Approval_Status__c = 'Approved';
        database.insert(cas);
        
        CaseTriggerHandler cth = new CaseTriggerHandler();
        cth.getNextCase(sub.Id, cas);
        Set<Id> cIds = new Set<Id>{cas.Id};
        CaseTriggerHandler.createInvoiceAdjustmentPStop(cIds);
        
        Test.StopTest();
  
    }
    
    static testMethod void testAssignVendor(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
        
        Postal_Zone__c post = new Postal_Zone__c();
        post.Postal_Sector__c = 'XX';
        post.Postal_Zone_Name__c = 'W';
        insert post;
        
        Singpost_Address__c sa = new Singpost_Address__c();
        sa.Name = 'XX1111';
        insert sa;
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        ad.Postal_Code__c = sa.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        database.insert(billAcc);
        
        test.startTest();
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()-10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        
        database.insert(sub);
        
        //End D-4452 02-Apr-2016 Added By S.Puli        
        
       
       // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
       // system.assertNotEquals(orders.Id, null);
        
        Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cas.Account__c = acc.id;
        cas.Account = acc;
        cas.recipient_address__c = ad.Id;
        cas.Order__c = ord.Id;
        cas.Recipient__c = con.Id;
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Complaint Digital');
        cas.ContactID = con.Id;
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
        cas.Subscription_Name__c = sub.Id;
        cas.Goodwill_Copies__c = 1;
        cas.Goodwill_Approval_Status__c = 'Approved';
        database.insert(cas);
        
        Test.StopTest();
  
    }
    
    static testMethod void testUpdateRecalledSubEndDate(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);
        
        
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()-10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        
        database.insert(sub);
        
        //End D-4452 02-Apr-2016 Added By S.Puli        
        
       
       // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
       // system.assertNotEquals(orders.Id, null);
        
        Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cas.Account__c = acc.id;
        cas.Account = acc;
        cas.recipient_address__c = ad.Id;
        cas.Order__c = ord.Id;
        cas.Recipient__c = con.Id;
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
        cas.ContactID = con.Id;
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
        cas.Status = 'New';
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
        cas.Subscription_Name__c = sub.Id;
        cas.Goodwill_Copies__c = 1;
        cas.Goodwill_Approval_Status__c = 'Approved';
        database.insert(cas);
        
        test.startTest();
        
        cas.Status = GlobalVariableClass.STATUS_CLOSED;
        cas.Sub_Status__c = GlobalVariableClass.REQUEST_RECALLED;
        cas.Approval_Submitted__c = false;
        update cas;
         
        Test.StopTest();
  
    } 
    
    static testMethod void testCaseTriggerHandlerTestSingleLatest(){
            
        User userU = TestDataFactory.prepareTestusers();    
        
        System.runAs(userU){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
        
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = rec.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            database.insert(con2);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);

            //Start D-4452 02-Apr-2016 Added By S.Puli        
            Case casRec = new Case();
            casRec.Current_Date_for_Year_To_Date__c = 1;
            database.insert(casRec);
            
            Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
            tempS.Order__c = ord.Id;
            tempS.Case__c = casRec.Id;
            database.insert(tempS);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc[0].Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type_1__c = 'Publication';
            database.insert(sub);
            //End D-4452 02-Apr-2016 Added By S.Puli        
            test.startTest();
            
           
           // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
           // system.assertNotEquals(orders.Id, null);
            
            Case cas = TestDataFactory.createCase(1, 'Renewal of Subscription')[0];
            cas.Account__c = acc.id;
            cas.Account = acc;
            cas.recipient_address__c = ad.Id;
            cas.Order__c = ord.Id;
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case Renewal of Subscription');
            cas.ContactID = con.Id;
            cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            cas.Sub_Category__c = GlobalVariableClass.RECTYPE_RENEWAL_OF_SUBSCRIPTION;
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
            cas.Status = GlobalVariableClass.STATUS_PENDING;
            cas.Contact_To_Update__c = con.id;
             //cas.Subscription_Name__c = sub.Id;
     
            database.insert(cas);
           
            
            Usage__c u = new Usage__c();
            u.Case__c = cas.Id;
            u.Status__c = GlobalVariableClass.STATUS_NEW;
            u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
            u.Subscription_Id__c = sub.Name;
            try{
                database.insert(u);
            }catch(exception e){
                system.debug(e);
            }
            
            try{
                database.delete(cas); 
            }catch(exception e){
                system.debug(e);
            }
            test.StopTest();
        }   
    }
    
    static testMethod void testCaseTriggerHandlerTestSingleHard(){
            
        User userU = TestDataFactory.prepareTestusers();    
        
        System.runAs(userU){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
        
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = rec.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            database.insert(con2);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);

            //Start D-4452 02-Apr-2016 Added By S.Puli        
            Case casRec = new Case();
            casRec.Current_Date_for_Year_To_Date__c = 1;
            database.insert(casRec);
            
            Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
            tempS.Order__c = ord.Id;
            tempS.Case__c = casRec.Id;
            database.insert(tempS);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc[0].Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type_1__c = 'Publication';
            database.insert(sub);
            //End D-4452 02-Apr-2016 Added By S.Puli        
            test.startTest();
            
           
           // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
           // system.assertNotEquals(orders.Id, null);
            
            Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
            cas.Account__c = acc.id;
            cas.Account = acc;
            cas.recipient_address__c = ad.Id;
            cas.Order__c = ord.Id;
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
            cas.ContactID = con.Id;
            cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas.Contact_To_Update__c = con.id;
            cas.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
             //cas.Subscription_Name__c = sub.Id;
     
            database.insert(cas);
            
            Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Case__c = cas.Id;
            caseSub.Subscription__c = sub.Id;
            caseSub.Account__c = acc.Id;
            database.insert(caseSub);
            
            
             /* 
            Usage__c u = new Usage__c();
            u.Case__c = cas.Id;
            u.Status__c = GlobalVariableClass.STATUS_NEW;
            u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
            u.Subscription_Id__c = sub.Name;
            database.insert(u);
            */
         /*   cas.Subject = 'New Subject';
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
            cas.New_Address__c = ad.Id;
            try {
                database.update(cas);
            }catch(exception e){
                System.debug(e);
            }
            */
            
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change in Address');
            cas.Sub_Status__c = GlobalVariableClass.URGENTCOAAPPROVED;
            cas.ContactID = con2.Id;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
          
            /*
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyID('Case_Adjustments');
            cas.Status = GlobalVariableClass.STATUS_PENDING;
            cas.Sub_Status__c = 'Approved';
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas.Rejected_Renewal__c = true;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            //Start D-4452 02-Apr-2016 Added By S.Puli
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            //cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            //cas.Status = 'Void';
            //database.update(cas);
            
            cas.Rejected_Renewal__c = true;
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
            cas.Requires_Urgent_Approval__c = true;
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            cas.Sub_Status__c = GlobalVariableClass.TEMP_STOP_APPROVED;
            cas.Order__c = ord.Id;
            cas.Temp_stop__c = tempS.Id;
            cas.Temp_Stop_Sub__c = sub.Id;
            cas.AccountId = acc.Id;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            */
            
            //cas.Outcome__c = 'Retained';
            //cas.Urgent_Request__c = true;
            //cas.Sub_Status__c = 'Waiting for Urgent Stop Approval';
            //cas.Original_Owner__c = GlobalVariableClass.RECALLED;
           // database.update(cas); 
            //database.insert(cas);
            
            //Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            //caseSub.isComplaint__c = false;
            //caseSub.Case__c = cas.Id;
            //caseSub.Subscription__c = sub.Id;
            //database.insert(caseSub);
            //End D-4452 02-Apr-2016 Added By S.Puli        
            //System.assertEquals(cas.Order__r.Recipient_Type__c, 'Overseas');
            
            Usage__c u = new Usage__c();
            u.Case__c = cas.Id;
            u.Status__c = GlobalVariableClass.STATUS_NEW;
            u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
            u.Subscription_Id__c = sub.Name;
            try{
                database.insert(u);
            }catch(exception e){
                system.debug(e);
            }
            
            try{
                database.delete(cas); 
            }catch(exception e){
                system.debug(e);
            }
            test.StopTest();
        }   
    }
    
    static testMethod void testCaseTriggerHandlerTestSingleSoft(){
            
        User userU = TestDataFactory.prepareTestusers();    
        
        System.runAs(userU){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
        
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = rec.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            database.insert(con2);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);

            //Start D-4452 02-Apr-2016 Added By S.Puli        
            Case casRec = new Case();
            casRec.Current_Date_for_Year_To_Date__c = 1;
            database.insert(casRec);
            
            Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
            tempS.Order__c = ord.Id;
            tempS.Case__c = casRec.Id;
            database.insert(tempS);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc[0].Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type_1__c = 'Publication';
            database.insert(sub);
            //End D-4452 02-Apr-2016 Added By S.Puli        
            
            Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
            subVen.Account__c = acc.Id;
            subVen.Subscription_Start_Date__c = date.today()+1;
            subVen.Subscription_Stop_Date__c = date.today()+365;
            subVen.Order_Number__c = ord.Id;
            subVen.Recipient__c = con.Id;
            database.insert(subVen);
        
            test.startTest();
            
           
           // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
           // system.assertNotEquals(orders.Id, null);
            
            Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
            cas.Account__c = acc.id;
            cas.Account = acc;
            cas.recipient_address__c = ad.Id;
            cas.Order__c = ord.Id;
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
            cas.ContactID = con.Id;
            cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas.Contact_To_Update__c = con.id;
            cas.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
             //cas.Subscription_Name__c = sub.Id;
     
            database.insert(cas);
            
            Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Case__c = cas.Id;
            caseSub.Subscription__c = sub.Id;
            caseSub.Account__c = acc.Id;
            database.insert(caseSub);
            
            Case_Vendor_Subscription__c csVen = TestDataFactory.createCaseVendorSub(1)[0];
            csVen.Account__c = acc.Id;
            csVen.Case__c = cas.Id;
            csVen.Subscription_Vendor__c = subVen.Id;
            csVen.Address__c = ad.Id;
            database.insert(csVen);
        
            
            
             /* 
            Usage__c u = new Usage__c();
            u.Case__c = cas.Id;
            u.Status__c = GlobalVariableClass.STATUS_NEW;
            u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
            u.Subscription_Id__c = sub.Name;
            database.insert(u);
            */
         /*   cas.Subject = 'New Subject';
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
            cas.New_Address__c = ad.Id;
            try {
                database.update(cas);
            }catch(exception e){
                System.debug(e);
            }
            */
            
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change in Address');
            cas.Sub_Status__c = GlobalVariableClass.URGENTCOAAPPROVED;
            cas.ContactID = con2.Id;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
          
            /*
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyID('Case_Adjustments');
            cas.Status = GlobalVariableClass.STATUS_PENDING;
            cas.Sub_Status__c = 'Approved';
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas.Rejected_Renewal__c = true;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            //Start D-4452 02-Apr-2016 Added By S.Puli
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            //cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            //cas.Status = 'Void';
            //database.update(cas);
            
            cas.Rejected_Renewal__c = true;
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
            cas.Requires_Urgent_Approval__c = true;
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            cas.Sub_Status__c = GlobalVariableClass.TEMP_STOP_APPROVED;
            cas.Order__c = ord.Id;
            cas.Temp_stop__c = tempS.Id;
            cas.Temp_Stop_Sub__c = sub.Id;
            cas.AccountId = acc.Id;
            try{
                database.update(cas);
            }catch(exception e){
                system.debug(e);
            }
            */
            
            //cas.Outcome__c = 'Retained';
            //cas.Urgent_Request__c = true;
            //cas.Sub_Status__c = 'Waiting for Urgent Stop Approval';
            //cas.Original_Owner__c = GlobalVariableClass.RECALLED;
           // database.update(cas); 
            //database.insert(cas);
            
            //Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            //caseSub.isComplaint__c = false;
            //caseSub.Case__c = cas.Id;
            //caseSub.Subscription__c = sub.Id;
            //database.insert(caseSub);
            //End D-4452 02-Apr-2016 Added By S.Puli        
            //System.assertEquals(cas.Order__r.Recipient_Type__c, 'Overseas');
            
            Usage__c u = new Usage__c();
            u.Case__c = cas.Id;
            u.Status__c = GlobalVariableClass.STATUS_NEW;
            u.Usage_Type__c = UsageHelper.USAGE_TYPE_NONDELIVERY;
            u.Subscription_Id__c = sub.Name;
            try{
                database.insert(u);
            }catch(exception e){
                system.debug(e);
            }
            
            try{
                database.delete(cas); 
            }catch(exception e){
                system.debug(e);
            }
            test.StopTest();
        }   
    }
    
    static testMethod void testCaseTriggerHandlerTestSingle2Even(){
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
        
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = (Id) ConstantsSLB.getKeyId('Address_Overseas');
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            database.insert(pack);
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = ord.Id;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Main_Package_Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
            database.insert(orderline);
            
            /*Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            database.insert(billAcc);
             
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__TermSettingType__c = 'Termed';
            sub.Term_Length1__c = '6';
            sub.Term_Length__c = 6;
            sub.Zuora__SubscriptionStartDate__c = date.today()-10;
            sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
            sub.Order_Line_Item_Number_1__c = orderline.Id;
            database.insert(sub);
            */
            
            Order__c order = [SELECT Id, Recipient_Type__c FROM Order__c WHERE Id=:ord.Id];
            system.assertEquals(order.Recipient_Type__c, 'Overseas');
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Accountid = acc.Id;
            cas.Account__c = acc.id;
            cas.Account = acc;        
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
            cas.recipient_address__c = ad.Id;
            cas.Order__c = order.Id;
            cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
            cas.Sub_Status__c = 'Waiting for Urgent Approval';
            cas.Contact_To_Update__c = con.id;
           
            test.startTest();
            //system.assertEquals(string.valueOF(cas.order__r.Recipient_Type__c), string.valueOF(cas.order__c )+string.valueOf(order.Recipient_Type__c));
            //system.assertEquals(1,2);
            database.insert(cas);
            
            cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change of Subscription');
            cas.Order__c = ord.Id;
            cas.Charges_Waived__c = true;
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            database.update(cas);
            test.StopTest();
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
            database.update(cas);
            
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_CHANGE_OF_SUB_COMPLETED;
            database.update(cas);
            
            acc.RecordTypeId = (Id) ConstantsSLB.getKeyId('Account_Vendor Subscriber');
            database.update(acc);
            
            cas.Account = [SELECT Id, RecordType.Name FROM Account WHERE Id=:acc.Id];
            database.update(cas);
            
            database.delete(cas);
           
        }
    }
    
    
    static testMethod void testUpdateRecalledSubEndDate1(){
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = rec.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            database.insert(pack);

            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc[0].Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__TermSettingType__c = 'Termed';
            sub.Term_Length1__c = '6';
            sub.Term_Length__c = 6;
            sub.Zuora__SubscriptionStartDate__c = date.today()-10;
            sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
            sub.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
            database.insert(sub);
            
            //End D-4452 02-Apr-2016 Added By S.Puli        
            
           
           // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
           // system.assertNotEquals(orders.Id, null);
            
            Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
            cas.Account__c = acc.id;
            cas.Account = acc;
            cas.recipient_address__c = ad.Id;
            cas.Order__c = ord.Id;
            cas.Recipient__c = con.Id;
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas.ContactID = con.Id;
            cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
            cas.Status = 'New';
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
            cas.Subscription_Name__c = sub.Id;
            cas.Goodwill_Copies__c = 1;
            cas.Goodwill_Approval_Status__c = 'Approved';
            database.insert(cas);
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = ord.Id;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Terminating_Reason__c = 'Payment failure - Credit card';
            orderline.Case__c = cas.Id;
            orderline.Subscription__c = sub.Id;
            database.insert(orderline);
            
            test.startTest();
            
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            cas.Sub_Status__c = GlobalVariableClass.REQUEST_RECALLED;
            cas.Approval_Submitted__c = false;
            update cas;
             
            Test.StopTest();
        }
       
    }
    
    static testMethod void testUpdateRecalledSubEndDate2(){
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU){
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            database.insert(acc);
            
            RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = rec.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            database.insert(pack);

            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc[0].Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Zuora__TermSettingType__c = 'Termed';
            sub.Term_Length1__c = '6';
            sub.Term_Length__c = 6;
            sub.Zuora__SubscriptionStartDate__c = date.today()-10;
            sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
            sub.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
            database.insert(sub);
            
            //End D-4452 02-Apr-2016 Added By S.Puli        
            
           
           // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
           // system.assertNotEquals(orders.Id, null);
            
            Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
            cas.Account__c = acc.id;
            cas.Account = acc;
            cas.recipient_address__c = ad.Id;
            cas.Order__c = ord.Id;
            cas.Recipient__c = con.Id;
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas.ContactID = con.Id;
            cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
            cas.Status = 'New';
            cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
            cas.Subscription_Name__c = sub.Id;
            cas.Goodwill_Copies__c = 1;
            cas.Goodwill_Approval_Status__c = 'Approved';
            database.insert(cas);
            
            Order_Line_Item_Vendor__c oliv = TestDataFactory.createOrderLineItemVendor(1)[0];
            oliv.Wrapper_Number__c = 5;
            oliv.Order__c = ord.Id;    
            database.insert(oliv);
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = ord.Id;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Terminating_Reason__c = 'Payment failure - Credit card';
            orderline.Case__c = cas.Id;
            orderline.Subscription__c = sub.Id;
            database.insert(orderline);
            
            test.startTest();
            
            cas.Status = GlobalVariableClass.STATUS_CLOSED;
            cas.Sub_Status__c = GlobalVariableClass.REQUEST_RECALLED;
            cas.Approval_Submitted__c = false;
            update cas;
             
            Test.StopTest();
        }
        
    }
    
    static testMethod void testCaseTriggerHandlerTestDigiComp1(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
    
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = rec.id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con2.Address__c = ad.Id;
        con2.AccountId = acc.Id;
        con2.Recipient_Indicator__c = true;
        database.insert(con2);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Recipient_Contact__c = con.Id;
        database.insert(ord);

        //Start D-4452 02-Apr-2016 Added By S.Puli        
        Case casRec = new Case();
        casRec.Current_Date_for_Year_To_Date__c = 1;
        database.insert(casRec);
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = casRec.Id;
        database.insert(tempS);
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill : billAcc){
            bill.Zuora__Account__c = acc.Id;
        }
        database.insert(billAcc);
        
        test.startTest();
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc[0].Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Zuora__TermSettingType__c = 'Termed';
        sub.Term_Length1__c = '6';
        sub.Term_Length__c = 6;
        sub.Zuora__SubscriptionStartDate__c = date.today()-10;
        sub.Zuora__SubscriptionEndDate__c = date.today().addMonths(6);
        
        database.insert(sub);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp : spc){
            sp.Zuora__Subscription__c = sub.Id;
            sp.PublicationCode__c = 'N';
            sp.Name = GlobalVariableClass.GOODWILL_CREDIT + GlobalVariableClass.SPACE + GlobalVariableClass.COPY;
            sp.Zuora__Price__c = 0.5;
        }
        database.insert(spc);
        
        //End D-4452 02-Apr-2016 Added By S.Puli        
        
       
       // Order__c orders = [SELECT id FROM Order__c WHERE Recipient_Type__c = 'Overseas' LIMIT 1];
       // system.assertNotEquals(orders.Id, null);
        
        Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cas.Account__c = acc.id;
        cas.Account = acc;
        cas.recipient_address__c = ad.Id;
        cas.Order__c = ord.Id;
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Complaint Digital');
        cas.ContactID = con.Id;
        cas.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        cas.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
        cas.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        cas.Contact_To_Update__c = con.id;
        cas.Subscription_Name__c = sub.Id;
        cas.Goodwill_Copies__c = 1;
        cas.Goodwill_Approval_Status__c = 'Approved';
        cas.Temp_Stop_Type__c = 'Create';
        database.insert(cas);
        
        cas.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
        cas.Requires_Urgent_Approval__c = true;
        cas.Status = GlobalVariableClass.STATUS_CLOSED;
        cas.Sub_Status__c = GlobalVariableClass.TEMP_STOP_APPROVED;
        cas.Order__c = ord.Id;
        cas.Temp_stop__c = tempS.Id;
        cas.Temp_Stop_Sub__c = sub.Id;
        cas.AccountId = acc.Id;
        cas.Temp_Stop_Date__c = date.today()+1;
        //cas.Temp_Stop_Type__c = 'Update';
        database.update(cas);
        
        CaseTriggerHandler cth = new CaseTriggerHandler();
        //cth.getNextCase(sub.Id, cas);
        
        Test.StopTest();
  
    }
    
    static testMethod void testCaseTrigger11() {
        try{
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber');
            database.insert(acc);
            
            RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Overseas'];
        
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = rec.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Recipient_Contact__c = con.Id;
            database.insert(ord);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc[0].Id;
            sub.Next_Year_Temp_Stop_Days__c = null;
            sub.Year_to_Date_Temp_Stop_Days__c = null;
            database.insert(sub);
            
            Order__c orders = [SELECT id,Recipient_Type__c FROM Order__c WHERE Id=:ord.Id];
            system.assertNotEquals(orders.Id, null);
            system.assertEquals(orders.Recipient_Type__c, 'Overseas');
            
            Order_Line_Item_Vendor__c oliv = TestDataFactory.createOrderLineItemVendor(1)[0];
            oliv.Wrapper_Number__c = 5;
            oliv.Order__c = orders.Id;    
            database.insert(oliv);
            
            Case ca = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            ca.Next_Year_for_Year_To_Date__c = 5;
            database.insert(ca);
            
            Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
            tempS.Order__c = ord.Id;
            tempS.Case__c = ca.Id;
            database.insert(tempS);
            
            List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
            for(Zuora__SubscriptionProductCharge__c sp : spc){
                sp.Zuora__Subscription__c = sub.Id;
                sp.PublicationCode__c = 'N';
            }
            database.insert(spc);
            test.startTest();
            Integer counter = 0;
            List<Case> cases = TestDataFactory.createCase(11, 'Start Subscription');
//            List<Case> cases = TestDataFactory.createCase(11, 'Change of Subscription Packages');
            for(Case c : cases){
                c.recipient_address__c = ad.Id;
                c.Order__c = orders.Id;
                if(counter==0){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
                    c.Temp_Stop_Type__c = 'Cancel';
                    c.Requires_Urgent_Approval__c = true;
                    c.Status = 'Closed';
                }
                else if(counter==1){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
                    c.Temp_Stop_Type__c = 'Update';
                    c.Requires_Urgent_Approval__c = false;
                    c.Sub_Status__c = 'Urgent Start Approved';
                    c.Status = 'Closed';
                    c.Category__c = 'Subscription Request';
                    c.Sub_Category__c = 'Change of Subscription Packages';
                }
                else if(counter==2){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Complaint_Newspaper');
                    c.Temp_Stop_Type__c = 'Create';
                    c.Status = 'Closed';
                }
                else if(counter==3){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change in Address');
                    c.Temp_Stop_Type__c = 'Create';
                    c.Status = 'Closed';
                }
                else if(counter==4){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Stop');
                    c.Sub_Status__c = 'Subscription Stop Completed';
                    //c.Sub_Status__c = 'Temp Stop Approved';
                    c.Status = 'Closed';
                }
                else if(counter==5){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
                    c.Temp_Stop_Type__c = 'Create';
                    c.Requires_Urgent_Approval__c = false;
                    c.Status = 'Pending';
                    c.Sub_Status__c = 'Ready for Subscription';
                    c.Category__c = 'Subscription Request';   
                    c.Sub_Category__c = 'Start Subscription';
                }
                else if(counter==6){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Start Sub');
                    c.Temp_Stop_Type__c = 'Update';
                    c.Requires_Urgent_Approval__c = false;
                    c.Sub_Status__c = 'Waiting for Urgent Start Approval';
                    c.Status = 'Pending';
                    c.Category__c = 'Subscription Request';
                    c.Sub_Category__c = 'Start Subscription';    
                }
                else if(counter==7){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
                    c.Temp_Stop_Type__c = 'Cancel';
                    c.Requires_Urgent_Approval__c = true;
                    c.Status = 'Pending';
                    c.Sub_Status__c = 'Waiting for Urgent Temp Stop/Restart Approval';
                    c.Origin = 'Email';
                }
                else if(counter==8){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change of Subscription');
                    c.Sub_Status__c = 'Waiting for Urgent Approval';
                    c.Status = 'Pending';
                }
                else if(counter==9){
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case Renewal of Subscription');
                    c.Category__c = 'Subscription Request';
                    c.Sub_Category__c = 'Renewal of Subscription';
                    c.Sub_Status__c = 'Waiting for Urgent Start Approval';
                    c.Status = 'Pending';
                }
                else{
                    c.RecordTypeId = (Id) ConstantsSLB.getKeyId('Case_Change in Address');
                    c.Sub_Category__c = 'Change of Address';  
                    c.Status = 'Pending'; 
                    c.POP_Start_Date__c = date.today()+5;
                    c.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local'; 
                }
                c.ContactID = con.Id;
                c.Temp_Stop_Sub__c = sub.Id;
                c.Effective_Date__c = date.today()+1;
                c.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
                c.AccountId = acc.Id;
                c.Temp_Stop_Date__c = date.today()+1;
                c.Restart_Date__c = date.today()+5;
                c.Temp_Stop_Updated__c = tempS.Id;
                c.Qty__c = 3;
                c.Temp_Stop__c = tempS.Id;
                c.Next_Year_for_Year_To_Date__c = 5;
                c.Earliest_Stop_Date__c = date.today()+10;
                c.Stop_Request_Date__c = date.today()+2;
                c.Approval_Submitted__c = true;
                c.Vendor_Subscription_Created__c = false;
                //c.Account_Record_Type__c = GlobalVariableClass.VENDORSUB;
                counter++;
            }
            database.insert(cases);
            
            Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
            subVen.Account__c = acc.Id;
            subVen.Subscription_Start_Date__c = date.today()+1;
            subVen.Subscription_Stop_Date__c = date.today()+365;
            subVen.Order_Number__c = ord.Id;
            subVen.Recipient__c = con.Id;
            database.insert(subVen);
            
            Case_Vendor_Subscription__c csVen = TestDataFactory.createCaseVendorSub(1)[0];
            csVen.Account__c = acc.Id;
            csVen.Case__c = cases[0].Id;
            csVen.Subscription_Vendor__c = subVen.Id;
            csVen.Address__c = ad.Id;
            database.insert(csVen);
            
            system.assertEquals(cases.size(), 11);
            system.assertEquals(cases[3].RecordTypeId, (Id) ConstantsSLB.getKeyId('Case_Change in Address'));
            
            List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
            for(Case_Subscription__c cs : caseSub){
                cs.Case__c = cases[3].Id;
                cs.Subscription__c = sub.Id;
            }
            database.insert(caseSub);
            
            Map<Id, Case> mapNewCases = new Map<Id, Case>();
            for(Case c : cases){
                mapNewCases.put(c.Id, c);
            }
            
            
                CaseTriggerHandler handler = new CaseTriggerHandler();
                handler.doBeforeInsert(cases);
                //handler.doAfterUpdate(cas,mapNewCases,cas,mapNewCases);
            test.stopTest();
        
        }catch(Exception e){}
    }
    
}