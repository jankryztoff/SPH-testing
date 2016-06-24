@isTest
public class SP_CancelSubscriptionInZuoraTest {
    
    static testMethod void testSP_CancelSubscriptionInZuoraTest(){
        
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
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
        sub[0].Zuora__CustomerAccount__c = billAcc.Id;
        sub[0].Main_Package__c = pack.Id;
        sub[0].Product_Code__c = '01';
        sub[0].Zuora__TermSettingType__c = 'Termed';
        sub[0].Term_Length__c = 1;
        sub[0].Term_Length1__c = '1'; 
        sub[0].Main_Package_1__c = pack.Id;
        sub[0].Zuora__SubscriptionStartDate__c = date.today();
        sub[0].Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub[0].id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub[0].id;  
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
        
        Test.startTest();
            
            SP_CancelSubscriptionInZuora batch = new SP_CancelSubscriptionInZuora();
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            //batch.execute(BC, sub);
            
        Test.stopTest();
        
    }
    
    static testMethod void testSP_CancelSubscriptionInZuoraTest2(){
        
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
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
        sub[0].Zuora__CustomerAccount__c = billAcc.Id;
        sub[0].Main_Package__c = pack.Id;
        sub[0].Product_Code__c = '01';
        sub[0].Zuora__TermSettingType__c = 'Termed';
        sub[0].Term_Length__c = 1;
        sub[0].Term_Length1__c = '1'; 
        sub[0].Main_Package_1__c = pack.Id;
        sub[0].Zuora__SubscriptionStartDate__c = date.today();
        sub[0].Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub[0].id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub[0].id;  
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
        
        Date newDate = sub[0].Zuora__SubscriptionEndDate__c;
        Boolean newBoolean = true;
        
        Test.startTest();
            
            SP_CancelSubscriptionInZuora batch1 = new SP_CancelSubscriptionInZuora(newDate, newBoolean);
            database.executeBatch(batch1, 200);
               
            Database.BatchableContext BC;
            //batch.execute(BC, sub);
            
        Test.stopTest();
        
    }
    
     static testMethod void testSP_CancelSubscriptionInZuoraTest3(){
        
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
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
        sub[0].Zuora__CustomerAccount__c = billAcc.Id;
        sub[0].Main_Package__c = pack.Id;
        sub[0].Product_Code__c = '01';
        sub[0].Zuora__TermSettingType__c = 'Termed';
        sub[0].Term_Length__c = 1;
        sub[0].Term_Length1__c = '1'; 
        sub[0].Main_Package_1__c = pack.Id;
        sub[0].Zuora__SubscriptionStartDate__c = date.today();
        sub[0].Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub[0].id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub[0].id;  
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
        
        Date newDate = sub[0].Zuora__SubscriptionEndDate__c;
        List<String> newList = new List<String>();
        newList.add(sub[0].Zuora__TermSettingType__c);
        newList.add(sub[0].Product_Code__c);
        Integer newInt = 1;
        
        Test.startTest();
            
            SP_CancelSubscriptionInZuora batch2 = new SP_CancelSubscriptionInZuora(newList, newInt, newDate);
            database.executeBatch(batch2, 200);
               
            Database.BatchableContext BC;
            //batch.execute(BC, sub);
            
        Test.stopTest();
        
    }
    
     
     static testMethod void testSP_CancelSubscriptionInZuoraTest4(){
        
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
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        date subStartDate = date.today().addDays(2);
        
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
        sub[0].Zuora__CustomerAccount__c = billAcc.Id;
        sub[0].Zuora__Account__c = acc.Id;
        sub[0].Main_Package__c = pack.Id;
        sub[0].Product_Code__c = '01';
        sub[0].Zuora__TermSettingType__c = 'Termed';
        sub[0].Term_Length__c = 1;
        sub[0].Term_Length1__c = '1'; 
        sub[0].Main_Package_1__c = pack.Id;
        sub[0].Zuora__SubscriptionStartDate__c = subStartDate;
        sub[0].Zuora__SubscriptionEndDate__c = subStartDate.addMonths(Integer.valueOf(1)).addDays(-1);
        sub[0].Zuora__Zuora_Id__c = 'test123';
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub[0].id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        Case cas = TestDataFactory.createcase(1, 'Complaint - Magazine')[0];
        cas.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Case' AND Name = 'Stop Subscription'].Id;
        cas.Account__c = acc.Id;
        cas.Billing_Account_Name__c = billAcc.Id;
        //cas.Contact_To_Update__c = con.Id;
        database.insert(cas);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub[0].id;  
        oli.Start_Date__c = Date.Today().addDays(2);
        oli.Case__c = cas.Id;
        oli.Stop_Request_Date__c = date.today().addDays(10);          
        }
        database.insert(olis);    

        String newString = sub[0].Zuora__TermSettingType__c;
        Test.startTest();
            
            SP_CancelSubscriptionInZuora batch3 = new SP_CancelSubscriptionInZuora(newString);
            Database.BatchableContext BC;
            batch3.start(BC);
            //batch3.execute(BC, sub);
            
        Test.stopTest();
        
    }
    
    static testMethod void testSP_CancelSubscriptionInZuoraTest5(){
        
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
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        date subStartDate = date.today().addDays(2);
        
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
        sub[0].Zuora__CustomerAccount__c = billAcc.Id;
        sub[0].Zuora__Account__c = acc.Id;
        sub[0].Main_Package__c = pack.Id;
        sub[0].Product_Code__c = '01';
        sub[0].Zuora__TermSettingType__c = 'Termed';
        sub[0].Term_Length__c = 1;
        sub[0].Term_Length1__c = '1'; 
        sub[0].Main_Package_1__c = pack.Id;
        sub[0].Zuora__SubscriptionStartDate__c = subStartDate;
        //sub[0].Zuora__SubscriptionEndDate__c = subStartDate.addMonths(Integer.valueOf(1)).addDays(-1);
        sub[0].Zuora__Zuora_Id__c = 'test123';
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub[0].id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        Case cas = TestDataFactory.createcase(1, 'Complaint - Magazine')[0];
        cas.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Case' AND Name = 'Stop Subscription'].Id;
        cas.Account__c = acc.Id;
        cas.Billing_Account_Name__c = billAcc.Id;
        cas.Case_Sub_Status__c = 'Case Created';
        //cas.Contact_To_Update__c = con.Id;
        database.insert(cas);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub[0].id;  
        oli.Start_Date__c = Date.Today().addDays(2);
        oli.Case__c = cas.Id;
        oli.Stop_Request_Date__c = date.today().addDays(10);          
        }
        database.insert(olis);    

        String newString = sub[0].Zuora__TermSettingType__c;
        Test.startTest();
            
            SP_CancelSubscriptionInZuora batch3 = new SP_CancelSubscriptionInZuora(newString);
            Database.BatchableContext BC;
            batch3.start(BC);
            //batch3.execute(BC, sub);
            
        Test.stopTest();
        
    }
    
}