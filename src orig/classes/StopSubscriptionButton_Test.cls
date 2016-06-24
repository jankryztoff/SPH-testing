/**
   @Author Joy Suarez
   @name StopSubscriptionButton_Test
   @CreateDate 2/25/2015
   @Description test class for StopSubscriptionButton
   @Version <1.0>
   @reference <Referenced program names>
  */

@isTest(seeAllData=false)
public class StopSubscriptionButton_Test {
    /**
    *  To test StopSubscriptionButton
    *  @name testStopSubscriptionButton
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testStopSubscriptionButton()
    {
        /*
        Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            insert(key); 
        */

        Other__c other = new Other__c();
           other.Name = 'DTL';
           other.Value__c = '23:59';
           insert(other); 


        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
       
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
                
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Order__c = orders[0].id;
        insert cas; 
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Case__c = cas.id;
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Stop_Request_Date__c = date.Today()+3;
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
         
        Map<Id,Date> zSub_StopDate_Map1 = new Map<Id,Date>();
        zSub_StopDate_Map1.put(olis[0].Subscription__c, olis[0].Stop_Request_Date__c);    
        
        Test.startTest();
       
            
        StopSubscriptionButton stopSubButton = new StopSubscriptionButton();
        StopSubscriptionButton.stopSub(String.valueOf(cas.Id));
        
        //SM_SubscriptionCancellationHelper.cancelSubscriptions(zSub_StopDate_Map1,'Stop Subscription');
        Test.stopTest();
    }
    /**
    *  To test StopSubscriptionButton
    *  @name testStopSubscriptionButton2
    *  @param none
    *  @return none
    *  @throws na
    */ 
      static testMethod void testStopSubscriptionButton2()
    {
        /*
        Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            insert(key); 
        */

        Other__c other = new Other__c();
           other.Name = 'DTL';
           other.Value__c = '23:59';
           insert(other

); 




        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        insert acc;

        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        insert pack;

        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true; 
        insert con;
                                   
        zqu__ProductRatePlanCharge__c newRatePlan = TestDataFactory.createProductRatePlanCharge(1)[0];
        newRatePlan.Name = 'Admin Charge';
        newRatePlan.zqu__Deleted__c = false;
        newRatePlan.zqu__ZuoraId__c = 'Zuora1';
        insert newRatePlan;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
            
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        system.assertNotEquals(null, prdRatePlan);    
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        insert billAcc;
        
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionStartDate__c = date.today();
                subRec.Zuora__SubscriptionEndDate__c = date.today()+1;
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
                subRec.Zuora__CustomerAccount__c  = billAcc.id;
                subrec.Number_of_Copies__c = 1;
                subRec.Number_of_Copies1__c = '1';
                subRec.Qty__c = 10;
                subRec.Qty1__c = '10';
                subRec.Term_Length__c = 1;
                subRec.Term_Length1__c = '1';
                subRec.Zuora__Zuora_Id__c = null;
            }
            
       insert subRecs;   
       
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Subscriber_Charge__c = 100.00;
        order.Base_Subscription__c = subRecs[0].id;
        order.Status__c = 'Void';
        order.Order_Type__c = 'Change of Subscription'; //= ConstantsSLB.getOther('Order_Type Renewal');
        order.Urgent_Stop__c = true;
        order.isWaive__c = true;
        insert order;
        
        
       Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
       insert cas; 
        
         
       Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
       orderline.Order__c = order.Id;
       orderline.End_Date__c = date.today().addDays(90);
       orderline.Main_Package_ID__c = pack.Id;
       orderline.Subscription__c = subRecs[0].id;
       orderline.Stop_Request_Date__c = Date.today().addDays(1);
       orderline.Start_Date__c = date.Today()+2;
       orderline.Case__c = cas.id;
       insert orderline;
       
       
       
       Test.startTest();
      
       
       StopSubscriptionButton stopSubButton = new StopSubscriptionButton();
       StopSubscriptionButton.stopSub(String.valueOf(cas.Id));
       Test.stopTest();
      }
      static testMethod void testStopSubscriptionButtonisSuccessFalse()
    {
        /*
        Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            insert(key); 
        */

        Other__c other = new Other__c();
           other.Name = 'DTL';
           other.Value__c = '23:59';
           insert(other); 


        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
       
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
                
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        Case cas = TestDataFactory.createCase(1, 'Change of Subscription')[0];
        cas.AccountId = acc.id;
        cas.Order__c = orders[0].id;
        insert cas; 
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Case__c = cas.id;
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Stop_Request_Date__c = date.Today()+3;
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
         
        Map<Id,Date> zSub_StopDate_Map1 = new Map<Id,Date>();
        zSub_StopDate_Map1.put(olis[0].Subscription__c, olis[0].Stop_Request_Date__c);    
        
        Test.startTest();
       
        SM_SubscriptionCancellationHelper.isSuccess = false;    
        StopSubscriptionButton stopSubButton = new StopSubscriptionButton();
        StopSubscriptionButton.stopSub(String.valueOf(cas.Id));
        
        //SM_SubscriptionCancellationHelper.cancelSubscriptions(zSub_StopDate_Map1,'Stop Subscription');
        Test.stopTest();
    }
}