@isTest
private class UtilityTriggerTest3{
    static testmethod void unitTest(){
    
        
        Map<String, Map<String, Id>> rcTypeMap = new Map<String, Map<String, Id>>();
        for(RecordType rt : [SELECT Id, Name, SObjectType FROM RecordType]) {
            if(!rcTypeMap.containsKey(rt.SObjectType)) {
                rcTypeMap.put(rt.SObjectType, new Map<String, Id>());
            }
            rcTypeMap.get(rt.SObjectType).put(rt.Name, rt.Id);
        }
        //System.Assertequals(rcTypeMap,null);
     
        insert new List<Key_Id__c> {    
            new Key_Id__c(Name='GracePeriodDaysBeforeEndDate',Id__c='4'),
            new Key_Id__c(Name='Case_Recipient Contact Num',Id__c=rcTypeMap.get('Case').get('Recipient Contact Num')),
            new Key_Id__c(Name='Temp Stop Subscription',Id__c='012N00000008k0EIAQ'),
            new Key_Id__c(Name='Account_Direct Corporate',Id__c=rcTypeMap.get('Account').get('Direct Corporate')),
            new Key_Id__c(Name='Address_Overseas',Id__c=rcTypeMap.get('Address').get('Overseas')),
            new Key_Id__c(Name='Account_Direct Individual',Id__c=rcTypeMap.get('Account').get('Direct Individual')),
            new Key_Id__c(Name='Account_Mailing Agent',Id__c=rcTypeMap.get('Account').get('Mailing Agent')),
            new Key_Id__c(Name='Account_Vendor',Id__c=rcTypeMap.get('Account').get('Vendor')),
            new Key_Id__c(Name='Profile_System Administrator',Id__c=rcTypeMap.get('Profile').get('System Administrator')),
            new Key_Id__c(Name='Profile_Standard User',Id__c=rcTypeMap.get('Profile').get('Standard User')),
            new Key_Id__c(Name='Contact_Billing Contact',Id__c=rcTypeMap.get('Contact').get('Billing Contact'))
            //new Key_Id__c(Name='Cir Predefined Case Team',Id__c='Cir Planner')
        };
            
           
        
        
          /*  Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '1234567890';
            key.Type__c = 'Number';
            insert key; 
        */
            Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
            cirPlanSched.Name = 'CIR Plan Schedule';
            cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
            cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
            cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
            cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
            insert cirPlanSched;

        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = [Select Id From RecordType Where SObjectType='Contact' And Name='Customer Contact' LIMIT 1].id;
        con1.Billing_Indicator__c = true;
        con1.Recipient_Indicator__c = true;
        insert con1;
        
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        insert pack;
        
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con1.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        insert order;
        
        
        Zone__c zone = new Zone__c();
        insert zone;
        
        
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'BT Invest Test';
        zProd.zqu__ZuoraId__c = '2c92c0f84495ff400144a9c8701b012b';
        zProd.zqu__SKU__c = 'SKU-00000005';
        zProd.ProductCode__c = 'Test Code';
        zProd.ProductType__c = 'Test Type';
        insert zProd;
        
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = zone.id;
        zoneProd.Postage_Charge__c = 30;
        zoneProd.Product__c = zProd.Id;
        insert zoneProd;
        
        
        String ccrID;
        Zuora__CustomerAccount__c bAccount = TestDataFactory.createBillingAccount(1)[0];
        bAccount.Zuora__Account__c = acc.id;
        bAccount.Zuora__PaymentMethodType__c = 'Paypal';
        insert bAccount;
        
        
        for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, Billing_Account_Auto_Number__c FROM Zuora__CustomerAccount__c WHERE Id =: bAccount.Id Limit 1]){
            ccrID = zBillingAccount.Billing_Account_Auto_Number__c;
        }
            
        BT_CO_ARMS_CreateAccountBatchFile__c accBatchRecord = new BT_CO_ARMS_CreateAccountBatchFile__c();
        accBatchRecord.Status__c = 'sent';
        accBatchRecord.Name = 'Test 1';
        accBatchRecord.CCRID__c = ccrID;
        insert accBatchRecord;
        
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today();
        orderline.End_Date__c = date.today().addDays(2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
        pm.Zuora__BillingAccount__c = bAccount.Id;
        pm.Zuora__Type__c = 'Cash';
        insert pm;
        
        Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
        insert SubVend;
        
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec = TestDataFactory.createSubscription(1)[0];
        subRec.Zuora__Account__c = acc.Id;
        subRec.Order_Number__c = order.Id;
        subRec.Subscriber_Contact__c = con1.Id;
        subRec.Recipient_Contact__c = con1.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Order_Line_Item_Number__c = orderline.Id;
        subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
        subRec.Vendor_1__c = acc.id;
        insert subRec;   
        
        
        Case_Subscription__c caseSub = new Case_Subscription__c();
        caseSub.Account__c = acc.Id;
        caseSub.Address__c = addressRec.Id;
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subRec.Id;
        insert caseSub;  
        
       
        update con1;
        delete con1;
        
    }
}