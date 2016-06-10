/**
@Author <Rom Eidson Reyes>
@name <StopSubOrderEntryDirectViewCont_Test>
@CreateDate <02/12/2015>
@Description <Test Class for StopSubOrderEntryDirectViewController>
@Version <1.0>
@reference <none>
*/
@istest (SeeAllData = true)
private class StopSubOrderEntryDirectViewCont_Test {
        
    /**
    * test method for Submit() method with no case inserted
    * @name <testSubmitNoCase>
    * @param <none>
    * @return <none>
    * @throws exception-<exception description>
    * @see 
    */
    static testmethod void testSubmitNoCase()
    {
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c='P';
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Create Contact
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con: cons){
            con.Address__c = address.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        insert cons;
        
        //Create Zuora Customer Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        insert billAcc;

        //Create Order
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.Account__c = acc.Id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = cons[0].Id;
       order.Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONED;
       order.Eligible_for_Retention__c = TRUE;
       order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
       order.Billing_Account__c = billAcc.id;
       order.Billing_Contact__c = cons[1].id;
       order.Case_Record_Type__c = 'Complaint - Magazine';
       order.Billing_Type__c = 'Full Prepaid';
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Send_to_Retention__c = false;
       //order.Parent_Case__c = 'Parent Case';
       order.Urgent_Stop__c = false;
       order.isWaive__c = false;
       insert order;
        
       
        
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'The Straits Times Print';
        zProd.zqu__SKU__c = 'SKU-00000071';
        zProd.ProductCode__c = 'STSU';
        zProd.ProductType__c = 'Product';
        //zProd.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        insert zProd;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prPlan = TestDataFactory.createProductRatePlan(1)[0];
        prPlan.Name = 'Full Prepaid - 1 Yr';
        prPlan.RatePlanCode__c = 'STSUTFP';
        prPlan.RatePlanType__c = 'Bill Plan';
        //prPlan.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        prPlan.zqu__ZProduct__c = zProd.id;
        insert prPlan;
        
        //Create Package Item = Base Product
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prPlan.id;
        insert pItem;
        
        //Create Zuora Subscription
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c zSub : zSubs)
        {
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__Zuora_Id__c = '1123';
            //zSub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zSub.Subscriber_Contact__c = cons[0].Id;
            zSub.Number_of_Copies1__c = '2';
            zSub.Zuora__CustomerAccount__c = billAcc.Id;
            zSub.Recipient_Contact__c = cons[1].Id;
            zSub.Main_Package__c = pack.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Generate_Invoice1__c = 'false';
        }
        insert zSubs;
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Subscription__c = zSubs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        
        
         
        //Create SAF
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        //Create PAF
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //Create Asia1
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        asia1.Display_Name__c = 'Test';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';
        asia1.Contact__c = cons[0].Id;
        insert asia1;
         
        //Create Case
        Case case1 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        case1.Sub_Status__c = 'Waiting for Vendor Assignment';
        case1.Order__c = order.id;
        
              
        test.startTest();
        insert case1;
        insert orderline;
        
        //Create Asia1 Subscription
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];   
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Subscription__c = zSubs[0].Id;
        asia1Sub.Status__c = 'Enabled';
        asia1Sub.Order_Line_Item__c = orderline.Id;
        asia1Sub.Service_Access_Flag__c = SAF.Id;
        asia1Sub.Concurrent__c = 20;
        insert asia1sub;
               
        PageReference pageRef = Page.StopSub_Order_Entry_Direct_View;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
        PageReference pageRefResult = controller.submit();
        System.assertNotEquals(null, pageRefResult);
        System.debug('>>>testSubmitWithNoCase' + pageRefResult);
        test.stopTest();
    }
    
    /**
    * test method for Submit() method with case inserted
    * @name <testSubmitWithCase>
    * @param <none>
    * @return <none>
    * @throws exception-<exception description>
    * @see 
    */
    static testmethod void testSubmitWithCase()
    {       
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c='P';
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Create Contact
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con: cons){
            con.Address__c = address.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        insert cons;
        
        //Create Zuora Customer Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        insert billAcc;

        //Create Order
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.Account__c = acc.Id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = cons[0].Id;
       order.Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONED;
       order.Eligible_for_Retention__c = TRUE;
       order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
       order.Billing_Account__c = billAcc.id;
       order.Billing_Contact__c = cons[1].id;
       order.Case_Record_Type__c = 'Complaint - Magazine';
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Billing_Type__c = 'Full Prepaid';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Send_to_Retention__c = false;
       //order.Parent_Case__c = 'Parent Case';
       order.Urgent_Stop__c = false;
       order.isWaive__c = false;
       insert order;
        
       
        
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'The Straits Times Print';
        zProd.zqu__SKU__c = 'SKU-00000071';
        zProd.ProductCode__c = 'STSU';
        zProd.ProductType__c = 'Product';
        //zProd.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        insert zProd;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prPlan = TestDataFactory.createProductRatePlan(1)[0];
        prPlan.Name = 'Full Prepaid - 1 Yr';
        prPlan.RatePlanCode__c = 'STSUTFP';
        prPlan.RatePlanType__c = 'Bill Plan';
        //prPlan.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        prPlan.zqu__ZProduct__c = zProd.id;
        insert prPlan;
        
        //Create Package Item = Base Product
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prPlan.id;
        insert pItem;
        
        //Create Zuora Subscription
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c zSub : zSubs)
        {
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__Zuora_Id__c = '1123';
            //zSub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zSub.Subscriber_Contact__c = cons[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc.Id;
            zSub.Recipient_Contact__c = cons[1].Id;
            zSub.Main_Package__c = pack.id;
            zSub.Number_of_Copies1__c = '2';
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Generate_Invoice1__c = 'false';
        }
        insert zSubs;
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Subscription__c = zSubs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        
        
         
        //Create SAF
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        //Create PAF
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //Create Asia1
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        asia1.Display_Name__c = 'Test';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';
        asia1.Contact__c = cons[0].Id;
        insert asia1;
         
        //Create Case
        Case case1 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        case1.Sub_Status__c = 'Urgent Stop Rejected'; //GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
        case1.Order_Number__c = order.id;
        
              
        test.startTest();
        insert case1;
        insert orderline;
               
        
        
        Boolean isExisting;
        List<Case> existingCase = new LIst<Case>();
        try{
            existingCase = [SELECT id, Sub_Status__c FROM Case WHERE Order_Number__c =: order.id];
            isExisting = true;
        } catch(Exception e){
            isExisting = false;
            System.debug('>>>EXCEPTION:' + e.getMessage());
        }
        System.debug('>>>isExisting:'+ isExisting);
        

        
        //Create Asia1 Subscription
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];   
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Subscription__c = zSubs[0].Id;
        asia1Sub.Status__c = 'Enabled';
        asia1Sub.Order_Line_Item__c = orderline.Id;
        asia1Sub.Service_Access_Flag__c = SAF.Id;
        asia1Sub.Concurrent__c = 20;
        insert asia1sub;
               
        PageReference pageRef = Page.StopSub_Order_Entry_Direct_View;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
        PageReference pageRefResult = controller.submit();
        controller.setCaseStatus(case1, order);
        System.assertNotEquals(null, pageRefResult);
        System.debug('>>>testSubmitWithCase' + pageRefResult);
        test.stopTest();
    }
    
    static testmethod void testSubmitWithCase2()
    {       
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c='P';
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Create Contact
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con: cons){
            con.Address__c = address.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        insert cons;
        
        //Create Zuora Customer Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        insert billAcc;

        //Create Order
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.Account__c = acc.Id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = cons[0].Id;
       order.Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONED;
       order.Eligible_for_Retention__c = TRUE;
       order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
       order.Billing_Account__c = billAcc.id;
       order.Billing_Contact__c = cons[1].id;
       order.Case_Record_Type__c = 'Complaint - Magazine';
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Billing_Type__c = 'Full Prepaid';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Send_to_Retention__c = false;
       //order.Parent_Case__c = 'Parent Case';
       order.Urgent_Stop__c = false;
       order.isWaive__c = false;
       insert order;
        
       
        
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'The Straits Times Print';
        zProd.zqu__SKU__c = 'SKU-00000071';
        zProd.ProductCode__c = 'STSU';
        zProd.ProductType__c = 'Product';
        //zProd.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        insert zProd;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prPlan = TestDataFactory.createProductRatePlan(1)[0];
        prPlan.Name = 'Full Prepaid - 1 Yr';
        prPlan.RatePlanCode__c = 'STSUTFP';
        prPlan.RatePlanType__c = 'Bill Plan';
        //prPlan.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        prPlan.zqu__ZProduct__c = zProd.id;
        insert prPlan;
        
        //Create Package Item = Base Product
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prPlan.id;
        insert pItem;
        
        //Create Zuora Subscription
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c zSub : zSubs)
        {
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__Zuora_Id__c = '1123';
            //zSub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zSub.Subscriber_Contact__c = cons[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc.Id;
            zSub.Recipient_Contact__c = cons[1].Id;
            zSub.Main_Package__c = pack.id;
            zSub.Number_of_Copies1__c = '2';
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Generate_Invoice1__c = 'false';
        }
        insert zSubs;
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Subscription__c = zSubs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        
        
         
        //Create SAF
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        //Create PAF
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //Create Asia1
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        asia1.Display_Name__c = 'Test';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';
        asia1.Contact__c = cons[0].Id;
        insert asia1;
         
        //Create Case
        Case case1 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        case1.Sub_Status__c = 'Waived Rejected'; //GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
        case1.Order_Number__c = order.id;
        
              
        test.startTest();
        insert case1;
        insert orderline;
               
        
        
        Boolean isExisting;
        List<Case> existingCase = new LIst<Case>();
        try{
            existingCase = [SELECT id, Sub_Status__c FROM Case WHERE Order_Number__c =: order.id];
            isExisting = true;
        } catch(Exception e){
            isExisting = false;
            System.debug('>>>EXCEPTION:' + e.getMessage());
        }
        System.debug('>>>isExisting:'+ isExisting);
        

        
        //Create Asia1 Subscription
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];   
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Subscription__c = zSubs[0].Id;
        asia1Sub.Status__c = 'Enabled';
        asia1Sub.Order_Line_Item__c = orderline.Id;
        asia1Sub.Service_Access_Flag__c = SAF.Id;
        asia1Sub.Concurrent__c = 20;
        insert asia1sub;
               
        PageReference pageRef = Page.StopSub_Order_Entry_Direct_View;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
        PageReference pageRefResult = controller.submit();
        controller.setCaseStatus(case1, order);
        System.assertNotEquals(null, pageRefResult);
        System.debug('>>>testSubmitWithCase' + pageRefResult);
        test.stopTest();
    }
    /**
    * test method to test VoidStatus() method
    * @name <testVoidStatus>
    * @param <none>
    * @return <none>
    * @throws exception-<exception description>
    * @see 
    */
    static testmethod void testVoidStatus()
    {
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c='P';
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Create Contact
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con: cons){
            con.Address__c = address.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        insert cons;
        
        //Create Zuora Customer Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        insert billAcc;

        //Create Order
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.Account__c = acc.Id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = cons[0].Id;
       order.Status__c = 'draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
       order.Billing_Account__c = billAcc.id;
       order.Billing_Contact__c = cons[1].id;
       order.Case_Record_Type__c = 'Complaint - Magazine';
       order.Billing_Type__c = 'Full Prepaid';
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Send_to_Retention__c = false;
       //order.Parent_Case__c = 'Parent Case';
       order.Urgent_Stop__c = false;
       order.isWaive__c = false;
       insert order;
                      
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'The Straits Times Print';
        zProd.zqu__SKU__c = 'SKU-00000071';
        zProd.ProductCode__c = 'STSU';
        zProd.ProductType__c = 'Product';
        //zProd.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        insert zProd;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prPlan = TestDataFactory.createProductRatePlan(1)[0];
        prPlan.Name = 'Full Prepaid - 1 Yr';
        prPlan.RatePlanCode__c = 'STSUTFP';
        prPlan.RatePlanType__c = 'Bill Plan';
        //prPlan.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        prPlan.zqu__ZProduct__c = zProd.id;
        insert prPlan;
        
        //Create Package Item = Base Product
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prPlan.id;
        insert pItem;
        
        //Create Zuora Subscription
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c zSub : zSubs)
        {
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__Zuora_Id__c = '1123';
            //zSub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zSub.Subscriber_Contact__c = cons[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc.Id;
            zSub.Recipient_Contact__c = cons[1].Id;
            zSub.Number_of_Copies1__c = '2';
            zSub.Main_Package__c = pack.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Generate_Invoice1__c = 'false';
        }
        insert zSubs;
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Subscription__c = zSubs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
            
        //Create SAF
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        //Create PAF
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //Create Asia1
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        asia1.Display_Name__c = 'Test';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';
        asia1.Contact__c = cons[0].Id;
        insert asia1;
         
        //Create Case
        Case case1 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        case1.Sub_Status__c = 'Waiting for Vendor Assignment';
        case1.Order__c = order.id;
        
              
        test.startTest();
        insert case1;
        insert orderline;
        
        //Create Asia1 Subscription
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];   
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Subscription__c = zSubs[0].Id;
        asia1Sub.Status__c = 'Enabled';
        asia1Sub.Order_Line_Item__c = orderline.Id;
        asia1Sub.Service_Access_Flag__c = SAF.Id;
        asia1Sub.Concurrent__c = 20;
        insert asia1sub;
               
        PageReference pageRef = Page.StopSub_Order_Entry_Direct_View;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
        System.debug('>>>Order Status Before:' + order.Status__c);
        controller.order = order;
        Boolean error = false;
        PageReference pageRefResultSubmit;
        PageReference pageRefResultVoid;
        try{
        pageRefResultSubmit = controller.submit();
        pageRefResultVoid = controller.voidStatus();
        System.debug('>>>Order Status Before:' + controller.order.Status__c);
        }
        catch(exception e)
        {
            error = true;
            System.debug('Error:'+ e.getStackTraceString());
        }
        System.assertNotEquals(null, pageRefResultSubmit );
        test.stopTest();
    }

    /**
    * test method to test DoCancel() method
    * @name <testDoCancel>
    * @param <none>
    * @return <none>
    * @throws exception-<exception description>
    * @see 
    */
    static testmethod void testDoCancel()
    {
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c='P';
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Create Contact
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con: cons){
            con.Address__c = address.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        insert cons;
        
        //Create Zuora Customer Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        insert billAcc;

        //Create Order
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.Account__c = acc.Id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = cons[0].Id;
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
       order.Billing_Account__c = billAcc.id;
       order.Billing_Contact__c = cons[1].id;
       order.Case_Record_Type__c = 'Complaint - Magazine';
       order.Billing_Type__c = 'Full Prepaid';
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Send_to_Retention__c = false;
       //order.Parent_Case__c = 'Parent Case';
       order.Urgent_Stop__c = false;
       order.isWaive__c = false;
       insert order;
                      
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'The Straits Times Print';
        zProd.zqu__SKU__c = 'SKU-00000071';
        zProd.ProductCode__c = 'STSU';
        zProd.ProductType__c = 'Product';
        //zProd.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        insert zProd;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prPlan = TestDataFactory.createProductRatePlan(1)[0];
        prPlan.Name = 'Full Prepaid - 1 Yr';
        prPlan.RatePlanCode__c = 'STSUTFP';
        prPlan.RatePlanType__c = 'Bill Plan';
        //prPlan.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        prPlan.zqu__ZProduct__c = zProd.id;
        insert prPlan;
        
        //Create Package Item = Base Product
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prPlan.id;
        insert pItem;
        
        //Create Zuora Subscription
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c zSub : zSubs)
        {
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__Zuora_Id__c = '1123';
            //zSub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zSub.Subscriber_Contact__c = cons[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc.Id;
            zSub.Number_of_Copies1__c = '2';
            zSub.Recipient_Contact__c = cons[1].Id;
            zSub.Main_Package__c = pack.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Generate_Invoice1__c = 'false';
        }
        insert zSubs;
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Subscription__c = zSubs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        order.Billing_Type__c = 'Full Prepaid';
        orderline.Amount_To_Refund__c = 0;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
               
        //Create SAF
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        //Create PAF
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //Create Asia1
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        asia1.Display_Name__c = 'Test';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';
        asia1.Contact__c = cons[0].Id;
        insert asia1;
         
        //Create Case
        Case case1 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        case1.Sub_Status__c = 'Waiting for Vendor Assignment';
        case1.Order__c = order.id;
        
              
        test.startTest();
        insert case1;
        insert orderline;
        
        //Create Asia1 Subscription
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];   
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Subscription__c = zSubs[0].Id;
        asia1Sub.Status__c = 'Enabled';
        asia1Sub.Order_Line_Item__c = orderline.Id;
        asia1Sub.Service_Access_Flag__c = SAF.Id;
        asia1Sub.Concurrent__c = 20;
        insert asia1sub;
               
        PageReference pageRef = Page.StopSub_Order_Entry_Direct_View;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
        PageReference pageRefResult = controller.doCancel();
        System.debug('>>>testDoCancel:' + pageRefResult);
        System.assertNotEquals(null, pageRefResult);
        test.stopTest();
    }

    /**
    * test method to test DoEdit() method
    * @name <testDoEdit>
    * @param <none>
    * @return <none>
    * @throws exception-<exception description>
    * @see 
    */
    static testmethod void testDoEdit()
    {
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c='P';
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Create Contact
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con: cons){
            con.Address__c = address.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        insert cons;
        
        //Create Zuora Customer Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        insert billAcc;

        //Create Order
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.Account__c = acc.Id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = cons[0].Id;
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
       order.Billing_Account__c = billAcc.id;
       order.Billing_Contact__c = cons[1].id;
       order.Case_Record_Type__c = 'Complaint - Magazine';
       order.Category__c = 'Subscription Request';
       order.Billing_Type__c = 'Full Prepaid';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Send_to_Retention__c = false;
       //order.Parent_Case__c = 'Parent Case';
       order.Urgent_Stop__c = false;
       order.isWaive__c = false;
       insert order;
                      
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'The Straits Times Print';
        zProd.zqu__SKU__c = 'SKU-00000071';
        zProd.ProductCode__c = 'STSU';
        zProd.ProductType__c = 'Product';
        //zProd.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        insert zProd;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prPlan = TestDataFactory.createProductRatePlan(1)[0];
        prPlan.Name = 'Full Prepaid - 1 Yr';
        prPlan.RatePlanCode__c = 'STSUTFP';
        prPlan.RatePlanType__c = 'Bill Plan';
        //prPlan.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        prPlan.zqu__ZProduct__c = zProd.id;
        insert prPlan;
        
        //Create Package Item = Base Product
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prPlan.id;
        insert pItem;
        
        Order_Line_Item__c orderline2 = TestDataFactory.createOrderLineItem(1)[0];
        orderline2.Order__c = order.Id;
        orderline2.Main_Package_ID__c = pack.Id;
        orderline2.Start_Date__c = date.Today().addDays(1);
        insert orderline2;
        
        //Create Zuora Subscription
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c zSub : zSubs)
        {
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__Zuora_Id__c = '1123';
            //zSub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zSub.Subscriber_Contact__c = cons[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc.Id;
            zSub.Recipient_Contact__c = cons[1].Id;
            zSub.Main_Package__c = pack.id;
            zSub.Number_of_Copies1__c = '2';
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Generate_Invoice1__c = 'false';
            /*zSub.Order_Line_Item_Number__c = orderline2.Id;            
            zSub.Order_Line_Item_Number_1__c = orderline2.Id;*/
            
        }
        insert zSubs;
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Subscription__c = zSubs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;        
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
               
        //Create SAF
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        //Create PAF
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //Create Asia1
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        asia1.Display_Name__c = 'Test';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';
        asia1.Contact__c = cons[0].Id;
        insert asia1;
         
        //Create Case
        Case case1 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        case1.Sub_Status__c = 'Waiting for Vendor Assignment';
        case1.Order__c = order.id;
                 
        test.startTest();
        insert case1;
        insert orderline;
        
        
        //Create Asia1 Subscription
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];   
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Subscription__c = zSubs[0].Id;
        asia1Sub.Status__c = 'Enabled';
        asia1Sub.Order_Line_Item__c = orderline.Id;
        asia1Sub.Service_Access_Flag__c = SAF.Id;
        asia1Sub.Concurrent__c = 20;
        insert asia1sub;
               
        PageReference pageRef = Page.StopSub_Order_Entry_Direct_View;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
        PageReference pageRefResult = controller.doEdit();
        System.assertNotEquals(null, pageRefResult);
        System.debug('>>>testDoEdit:' + pageRefResult);
        test.stopTest();
    }
    
    /**
    * testmethod to subwith with OLI list
    * @name <testOliList>
    * @param <none>
    * @return <none>
    * @throws exception-<exception description>
    * @see 
    */
    static testmethod void testOliList()
    {
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c='P';
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Create Contact
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con: cons){
            con.Address__c = address.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        insert cons;
        
        //Create Zuora Customer Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        insert billAcc;

        //Create Order
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.Account__c = acc.Id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = cons[0].Id;
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
       order.Billing_Account__c = billAcc.id;
       order.Billing_Contact__c = cons[1].id;
       order.Case_Record_Type__c = 'Complaint - Magazine';
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Billing_Type__c = 'Full Prepaid';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Send_to_Retention__c = false;
       //order.Parent_Case__c = 'Parent Case';
       order.Urgent_Stop__c = false;
       order.isWaive__c = false;
       insert order;
                      
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'The Straits Times Print';
        zProd.zqu__SKU__c = 'SKU-00000071';
        zProd.ProductCode__c = 'STSU';
        zProd.ProductType__c = 'Product';
        //zProd.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        insert zProd;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prPlan = TestDataFactory.createProductRatePlan(1)[0];
        prPlan.Name = 'Full Prepaid - 1 Yr';
        prPlan.RatePlanCode__c = 'STSUTFP';
        prPlan.RatePlanType__c = 'Bill Plan';
        //prPlan.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        prPlan.zqu__ZProduct__c = zProd.id;
        insert prPlan;
        
        //Create Package Item = Base Product
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prPlan.id;
        insert pItem;
        
        //Create Zuora Subscription
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c zSub : zSubs)
        {
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__Zuora_Id__c = '1123';
            //zSub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zSub.Subscriber_Contact__c = cons[0].Id;
            zSub.Recipient_Contact__c = cons[1].Id;
            zSub.Zuora__CustomerAccount__c = billAcc.Id;
            zSub.Main_Package__c = pack.id;
            zSub.Number_of_Copies1__c = '2';
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Generate_Invoice1__c = 'false';
        }
        
        insert zSubs;
        
        //Create Order Line Item
        List<Order_Line_Item__c> orderlines = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c orderline: orderlines)
        {
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Subscription__c = zSubs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        }
        orderlines[0].Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderlines[0].Earliest_Stop_Date__c = Date.Today();
        insert orderlines;
        zSubs[0].Order_Line_Item_Number__c = orderlines[0].Id;
        zSubs[0].Order_Line_Item_Number_1__c = orderlines[0].Id;
        
        update zsubs[0];
        //Create SAF
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        //Create PAF
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //Create Asia1
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        asia1.Display_Name__c = 'Test';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';
        asia1.Contact__c = cons[0].Id;
        insert asia1;
         
        //Create Case
        Case case1 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        case1.Sub_Status__c = 'Waiting for Vendor Assignment';
        case1.Order__c = order.id;  
        test.startTest();         
                
        insert case1;
        
       
        
        //Create Asia1 Subscription
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];   
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Subscription__c = zSubs[0].Id;
        asia1Sub.Status__c = 'Enabled';
        asia1Sub.Order_Line_Item__c = orderlines[0].Id;
        asia1Sub.Service_Access_Flag__c = SAF.Id;
        asia1Sub.Concurrent__c = 20;
        insert asia1sub;
               
        PageReference pageRef = Page.StopSub_Order_Entry_Direct_View;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
        PageReference pageRefResult = controller.submit();
        System.assertNotEquals(null, pageRefResult);
        System.debug('>>>testOliList: ' + pageRefResult);
        test.stopTest();
    }
    
    
    /**
    * test method to test doedit() and doCancel() methods
    * @name <testDoEditCancelNull>
    * @param <none>
    * @return <none>
    * @throws exception-<exception description>
    * @see 
    */
    static testmethod void testDoEditCancelNull()
    {          
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c='P';
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Create Contact
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con: cons){
            con.Address__c = address.Id;
            con.AccountId = acc.Id;          
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        insert cons;
        
        //Create Zuora Customer Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        insert billAcc;

        //Create Order
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.Account__c = acc.Id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = cons[0].Id;
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
       order.Billing_Account__c = billAcc.id;
       order.Billing_Contact__c = cons[1].id;
       order.Case_Record_Type__c = 'Complaint - Magazine';
       order.Billing_Type__c = 'Full Prepaid';
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Send_to_Retention__c = false;
       //order.Parent_Case__c = 'Parent Case';
       order.Urgent_Stop__c = false;
       order.isWaive__c = false;
       insert order;
                      
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        insert pack;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'The Straits Times Print';
        zProd.zqu__SKU__c = 'SKU-00000071';
        zProd.ProductCode__c = 'STSU';
        zProd.ProductType__c = 'Product';
        //zProd.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        insert zProd;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prPlan = TestDataFactory.createProductRatePlan(1)[0];
        prPlan.Name = 'Full Prepaid - 1 Yr';
        prPlan.RatePlanCode__c = 'STSUTFP';
        prPlan.RatePlanType__c = 'Bill Plan';
        //prPlan.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        prPlan.zqu__ZProduct__c = zProd.id;
        insert prPlan;
        
        //Create Package Item = Base Product
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prPlan.id;
        insert pItem;
        
        //Create Zuora Subscription
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c zSub : zSubs)
        {
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__Zuora_Id__c = '1123';
            //zSub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zSub.Subscriber_Contact__c = cons[0].Id;
            zSub.Recipient_Contact__c = cons[1].Id;
            zSub.Main_Package__c = pack.id;
            zSub.Zuora__CustomerAccount__c = billAcc.Id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Number_of_Copies1__c = '2';
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Generate_Invoice1__c = 'false';
        }
        insert zSubs;
        
        //Create Order Line Item
        List<Order_Line_Item__c> orderlines = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c orderline: orderlines)
        {
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.Today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Subscription__c = zSubs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;        
        orderline.Admin_Charge__c = 0;
        orderline.Start_Date__c = date.Today().addDays(1);
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        }
        orderlines[0].Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderlines[0].Earliest_Stop_Date__c = Date.Today();
        //Create SAF
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        //Create PAF
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //Create Asia1
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        asia1.Display_Name__c = 'Test';
        asia1.Email__c = 'test@email.com' ;
        asia1.Password__c = 'aBcD3Fg';
        asia1.Contact__c = cons[0].Id;
        insert asia1;
         
        //Create Case
        Case case1 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        case1.Sub_Status__c = 'Waiting for Vendor Assignment';
        case1.Order__c = order.id;
    
        test.startTest();
        insert orderlines;
        insert case1;
        
        //Create Asia1 Subscription
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];   
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Subscription__c = zSubs[0].Id;
        asia1Sub.Status__c = 'Enabled';
        asia1Sub.Order_Line_Item__c = orderlines[0].Id;
        asia1Sub.Service_Access_Flag__c = SAF.Id;
        asia1Sub.Concurrent__c = 20;
        insert asia1sub;
        
        PageReference pageRef = Page.StopSub_Order_Entry_Direct_View;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
        StopSubOrderEntryDirectViewController controller = new StopSubOrderEntryDirectViewController();
        PageReference pageRefResult = controller.doEdit();
        controller.doCancel();
        controller.cancelSubscription();
        System.debug('>>>testDoEditDoCancelNull: ' + pageRefResult);
        System.assertEquals(null, pageRefResult);
        test.stopTest();
    }
    
}