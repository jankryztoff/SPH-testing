/**
   @Author Val Lu
   @name Renewal_CancelSubscriptionTest
   @CreateDate 02/26/2015
   @Description To test Renewal_CancelSubscription class
   @Version <1.0>
  */
@isTest(SeeAllData = True)
private class Renewal_CancelSubscriptionTest{

    //Holds all testdata values
    static Map<String, SObject> sObjectMap_global;
   
    /**
    *  To test Renewal_CancelSubscriptionTest class
    *  @name testRenewalCancelSubscription1
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testRenewalCancelSubscription1(){
        try{    
            setAllData();
            Test.startTest();           
                Zuora__Subscription__c Subs = (Zuora__Subscription__c) sObjectMap_global.get('Zuora__Subscription__c');        
                Renewal_CancelSubscription.cancelAmendment(Subs.id,date.today().adddays(1));
            Test.stopTest();     
        }
        catch(Zuora.zRemoteException e){}
    }   
    
    /**
    *  To test Renewal_CancelSubscriptionTest class
    *  @name test_getSubscriptionParams
    *  @param none
    *  @return none
    *  @throws na
    */      
    static testMethod void test_getSubscriptionParams(){
         try{    
        
            setAllData();
            
            Test.startTest();            
                Zuora__Subscription__c Subs = (Zuora__Subscription__c) sObjectMap_global.get('Zuora__Subscription__c');        
                //Renewal_CancelSubscription.getSubscriptionParams(Subs.Id); //CLin 25April2016
                //List<Zuora.ZObject> zz = new List<Zuora.ZObject>(); //CLin 25April2016
                //Renewal_CancelSubscription.amendApiCall(zz); //CLin 25April2016
            Test.stopTest();
         }
        catch(Zuora.zRemoteException e){}
    }
    
    static testMethod void testMe01(){
        try{
            Test.startTest();
                //Renewal_CancelSubscription.getSubscriptionParams(null); //CLin 25April2016
            Test.stopTest();
        }
        catch(Zuora.zRemoteException e){}

    }
    
    /**
    *  To test Renewal_CancelSubscriptionTest class
    *  @name testRenewalCancelSubscription2
    *  @param none
    *  @return none
    *  @throws na
    */     
    static testMethod void testRenewalCancelSubscription2(){
 
        try{
            //Create Account a
            Account acc = new Account();
            acc.Name = 'TestAccount';
            insert acc;
            
            //Adding Billing Contact Records
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
            billingAcc.Zuora__Account__c = acc.id;
            billingAcc.Billing_Type__c = 'Full Prepaid';
            insert billingAcc ;
              
            //Create an Address record
            Address__c address = TestDataFactory.createAddress(1)[0];
            
            //create contact c
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.Id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            //Create new Order order
            Order__c order = new Order__c();
            order.Account__c = acc.id;
            order.Delivery_Charge__c = 1.00;
            order.Subscriber_Charge__c = 1.00;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 12.00;
            order.Credit_Balance__c = 1.00;
            order.Informed_Customer__c = true;
            order.Recipient_Contact__c = con.id;
            order.Order_Type__c = 'Change of Subscription Package';
            order.Status__c = 'Draft';
            insert order;
    
            //create package
            Package__c pack = new Package__c();
            pack.Package_Type__c = 'Base';
            pack.Name = 'TestPackageName';
            pack.Subscription_Type__c = 'Termed';
            pack.Channel_Direct__c = true;
            pack.Channel_E_shop_overseas__c = true;
            pack.Channel_E_shop_private__c = true;
            pack.Channel_E_shop_public__c = true;
            pack.Subscription_Period__c = '35';
            pack.Package_Code__c = 'SamplePackageCode';
            pack.Effective_Start_Date__c = date.Today();
            pack.Effective_End_Date__c = date.Today() + 30;
            insert pack;
            
            //System.assertNotEquals(null, pack.id);
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert new List<sObject>{cas};
                
            //System.assertNotEquals(null, cas.id);
                
            //Create order line item
            Order_Line_Item__c oli = new Order_Line_Item__c();
            oli.Earliest_Start_Date__c = date.Today();
            oli.Start_Date__c = date.Today().addDays(1);
            oli.Main_Package_Period__c = 35;
            oli.Qty__c = 1;
            oli.Main_Package_ID__c = pack.id;
            oli.Delivered_By__c = 'Vendor'; 
            oli.Main_Package_Billing_Type__c = 'Full Prepaid';
            oli.Main_Package_Type__c = 'Base';
            oli.Main_Package_Frequency__c = 'Default';
            oli.Term_Length__c = 2;
            oli.Order__c = order.id;
            insert oli;
            
            System.assertNotEquals(null, oli.id);
            
            //Create subscrption subs
            List<Zuora__Subscription__c> Subs = TestDataFactory.createSubscription(1);
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con.Id;
            Subs[0].Recipient_Contact__c = con.Id;
            Subs[0].Main_Package_1__c = pack.id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Subscription_Type__c = 'Publication';
            Subs[0].Zuora__Status__c= 'Active';
            Subs[0].Zuora__CustomerAccount__c = billingAcc.Id;
            Subs[0].Zuora__Zuora_Id__c = 'testzuoraid';
            Subs[0].Zuora__SubscriptionEndDate__c = date.today() + 30;
            insert Subs;
            Test.startTest();
        
            System.assertNotEquals(null, Subs[0].id);
        
            //Renewal_CancelSubscription.getSubscriptionParams(Subs[0].id); //CLin 25April2016
            Renewal_CancelSubscription.cancelAmendment(Subs[0].id,date.today().adddays(1));
            Test.stopTest();
        }
        catch(Zuora.zRemoteException e){}    
    }
    
    
    static void setAllData(){
        //Reset data holder values
        sObjectMap_global = null;
        sObjectMap_global = new Map<String, SObject>();
        //Create Account a
        Account acc = new Account();
        acc.Name = 'TestAccount';
        insert acc;
        
        //Adding Billing Contact Records
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acc.id;
        billingAcc.Billing_Type__c = 'Full Prepaid';
        insert billingAcc ;
        
             
        //Create an Address record
        Address__c address = TestDataFactory.createAddress(1)[0];
        
        //create contact c
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = address.Id;
        con.Recipient_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
        
        //Create new Order order
        Order__c order = new Order__c();
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 1.00;
        order.Subscriber_Charge__c = 1.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 12.00;
        order.Credit_Balance__c = 1.00;
        order.Informed_Customer__c = true;
        order.Recipient_Contact__c = con.id;
        order.Order_Type__c = 'Change of Subscription Package';
        order.Status__c = 'Draft';
        insert order;

        //create package
        Package__c pack = new Package__c();
        pack.Package_Type__c = 'Base';
        pack.Name = 'TestPackageName';
        pack.Subscription_Type__c = 'Termed';
        pack.Channel_Direct__c = true;
        pack.Channel_E_shop_overseas__c = true;
        pack.Channel_E_shop_private__c = true;
        pack.Channel_E_shop_public__c = true;
        pack.Subscription_Period__c = '35';
        pack.Package_Code__c = 'SamplePackageCode';
        pack.Effective_Start_Date__c = date.Today();
        pack.Effective_End_Date__c = date.Today() + 30;
        insert pack;
        
        //Create order line item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = date.Today();
        oli.Start_Date__c = date.Today().addDays(1);
        oli.Main_Package_Period__c = 35;
        oli.Qty__c = 1;
        oli.Main_Package_ID__c = pack.id;
        oli.Delivered_By__c = 'Vendor'; 
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Term_Length__c = 2;
        oli.Order__c = order.id;
        insert oli;
        
        System.assertNotEquals(null, oli.id);
        
        //Create subscrption subs
        List<Zuora__Subscription__c> Subs = TestDataFactory.createSubscription(1);
        Subs[0].Zuora__Account__c = acc.id;
        Subs[0].Order_Line_Item_Number__c = oli.Id;
        Subs[0].Order_Number__c = order.Id;
        Subs[0].Subscriber_Contact__c = con.Id;
        Subs[0].Recipient_Contact__c = con.Id;
        Subs[0].Main_Package_1__c = pack.id;
        Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
        Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
        Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        Subs[0].Urgent__c = 'false';
        Subs[0].Vendor_Conversion__c = 'false';
        Subs[0].Charity__c = 'false';
        Subs[0].Subscription_Type__c = 'Publication';
        Subs[0].Zuora__Status__c= 'Active';
        Subs[0].Zuora__CustomerAccount__c = billingAcc.Id;
        sObjectMap_global.put('Zuora__Subscription__c', Subs[0]);
        insert Subs;    
        
    }
}