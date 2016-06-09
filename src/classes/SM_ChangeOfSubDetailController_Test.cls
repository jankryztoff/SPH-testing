@isTest(seeAllData=true)
private class SM_ChangeOfSubDetailController_Test {
    static testMethod void testSMChangeOfSubscriptionDetailController(){
        
        //create account a
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        //create case ca
        Case ca = new Case();
        ca.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
        ca.Account = a;
        insert ca;
        
        //create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        
        //create contact c
        Contact c = TestDataFactory.createContact(1)[0];
        c.AccountId = a.Id;
        c.Address__c = addressList[0].Id;
        c.Recipient_Indicator__c = true;
        insert c;
        
        //create order o
        Order__c o = new Order__c();
        o.Account__c = a.id;
        o.Delivery_Charge__c = 1.00;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 12.00;
        o.Credit_Balance__c = 1.00;
        o.Informed_Customer__c = true;
        o.Recipient_Contact__c = c.id;
        o.Order_Type__c = 'Change of Subscription Package';
        o.Status__c = 'Draft';
        insert o;
        
        //create package
        Package__c p = new Package__c();
        p.Package_Type__c = 'Base';
        P.Name = 'TestPackageName';
        p.Subscription_Type__c = 'Termed';
        p.Channel_Direct__c = true;
        p.Channel_E_shop_overseas__c = true;
        p.Channel_E_shop_private__c = true;
        p.Channel_E_shop_public__c = true;
        p.Subscription_Period__c = '35';
        p.Package_Code__c = 'SamplePackageCode';
        p.Effective_Start_Date__c = date.Today();
        p.Effective_End_Date__c = date.Today() + 30;
        insert p;
        
        //create order line item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Case__c = ca.id;
        oli.Earliest_Start_Date__c = date.Today();
        oli.Start_Date__c = date.Today().addDays(1);
        oli.Main_Package_Period__c = 35;
        oli.Qty__c = 1;
        oli.Main_Package_ID__c = p.id;
        oli.Delivered_By__c = 'Vendor'; 
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Order__c = o.id;
        insert oli;
        //insert ca;
        
        /*
        //create subscrption s
        Zuora__Subscription__c s = new Zuora__Subscription__c();
    insert s;        
    */
  
        SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
        SM_SubscriptionHelper subHelper = new SM_SubscriptionHelper();
        
        //set current page parameters        
        PageReference pr = new Pagereference('/apex/SM_ChangeOfSubscriptionDetail?id=' + o.Id + '&accountId=' + o.Account__c);
        //PageReference pageRef = new Pagereference('/apex/SM_ChangeOfSubscriptionDetail');
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('id',o.id);
        ApexPages.currentPage().getParameters().put('accountId',a.id);
       
        //System.AssertEquals(0,ApexPages.currentPage().Messages().size());
        controller.retrieveOrder();
        
        //System.assertNotEquals(null, controller.thisOrder);
        
        SM_ChangeOfSubscriptionDetailController.SubscriptionWrapper page = new SM_ChangeOfSubscriptionDetailController.SubscriptionWrapper();
        
        string queryStr = SM_SubscriptionHelper.generateOrderSoqlStr();
        queryStr += ' where (Order_Type__c = \'Change of Subscription Package\' and Account__c = \'' + a.id  + '\' and Status__c =\'Draft\')';
        queryStr += ' or Id = \'' + o.id  + '\' limit 1';
        
        
        list<SObject> orderList = new list<SObject>();
        Order__c thisOrder = new Order__c();
        orderList = database.query(queryStr);
        controller.thisOrder = (Order__c)orderList[0];
               
        controller.edit();
    }
}