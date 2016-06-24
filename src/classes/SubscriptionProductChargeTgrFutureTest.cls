@isTest
public class SubscriptionProductChargeTgrFutureTest {
    
   //List of variables
    static List<Country__c> cntryList;
    static Account acnt;
    static List<Singpost_Address__c> singpostalList;
    static List<Address__c> addrList;
    static List<Contact> cntctList;
    static Zuora__CustomerAccount__c custAccount;
    static Package__c packge;
    static zqu__ZProduct__c zProducts;
    static zqu__ProductRatePlan__c prodRatePlan;
    static Product_Family__c prodFamily;
    static Package_Item__c packageItem;
    static Order__c orders;
    static List<Order_Line_Item__c> orderItemList;
    static Order_Line_Item__c ordLineItem;
    static Zuora__Subscription__c zuoraSubscription;
    static Promotion__c prom;
    static EmailTemplate validEmailTemplate;
    
    @testSetup 
    static void setupData() {
        
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface();  
        insert CustomSettingsDataFactory.createPlannerSched();
    }

    static void setUpTestData() {

        //Setup Country__c records
        cntryList = TestDataFactory.createCountry(2);
        cntryList[0].Country_Name__c = 'Quezon';
        cntryList[0].Code__c = 'QC';
        cntryList[1].Country_Name__c = 'Manila';
        cntryList[1].Code__c = 'XZ';
        insert cntryList;
        
        //Setup Account records
        acnt = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acnt.NRIC__c = 'T1234567R';
        acnt.Name = 'Test Account';
        acnt.Phone = '123-456';
        acnt.Email__c = 'test@test.com';
        acnt.Date_of_Birth__c = date.today();
        acnt.Gender__c = 'Male';
        acnt.Race__c = 'Chinese';
        acnt.Language__c = 'Others';
        acnt.Contact_Person__c = 'Contact Person';
        acnt.Sub_Group__c = 'Freelist(MY)';
        acnt.Generate_Account_Number__c = true;
        acnt.Renewal_Letter__c = 'Email';
        
        insert acnt;
        
        //Setup Postal records
        singpostalList = TestDataFactory.createSingpostAddress(2);
        singpostalList[0].Name = 'SPostal';
        singpostalList[0].House_Block_Number__c = 'TEST';
        singpostalList[0].Address_Type__c = 'A';
        singpostalList[0].Building_Name__c = 'Building';
        singpostalList[0].Street_Name__c = 'Street';
        singpostalList[1].Name = 'PPostal';
        singpostalList[1].House_Block_Number__c = 'TEST';
        singpostalList[1].Address_Type__c = 'A';
        singpostalList[1].Building_Name__c = 'Building';
        singpostalList[1].Street_Name__c = 'Street';
        insert singpostalList;
        
        //Address
        addrList = TestDataFactory.createAddress(2);
        addrList[0].Address_Type__c = 'A';
        addrList[0].Postal_Code__c = singpostalList[0].Id;
        addrList[0].Block_House_Number__c ='TEST';
        addrList[0].Level_Number__c ='xx';
        addrList[0].Unit_Number__c = 'yy';
        addrList[0].Country__c = cntryList[0].id;
        addrList[0].Address_1__c = 'Address 1';
        addrList[0].Address_2__c = 'Address 2';
        addrList[0].Address_3__c = 'Address 3';
        addrList[0].Address_4__c = 'Address 4';
        addrList[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        addrList[1].Address_Type__c = 'A';
        addrList[1].Postal_Code__c = singpostalList[1].Id;
        addrList[1].Block_House_Number__c ='TEST';
        addrList[1].Level_Number__c ='xx';
        addrList[1].Unit_Number__c = 'yy';
        addrList[1].Country__c = cntryList[1].id;
        addrList[1].Address_1__c = 'Address 1';
        addrList[1].Address_2__c = 'Address 2';
        addrList[1].Address_3__c = 'Address 3';
        addrList[1].Address_4__c = 'Address 4';
        addrList[1].RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        insert addrList; 
        
        //Setup Contact records
        cntctList = TestDataFactory.createContact(2);
        cntctList[0].Address__c = addrList[0].Id;
        cntctList[0].AccountId = acnt.Id;
        cntctList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        cntctList[0].Billing_Indicator__c = true;
        cntctList[0].FirstName = 'Test';
        cntctList[0].LastName = 'Contact';
        cntctList[0].Passport__c = 'PassTest';
        cntctList[0].HomePhone__c = '123 456';
        cntctList[0].Mobile_Number__c = '123456';
        cntctList[0].Email = 'test@test.com';
        cntctList[0].Recipient_Indicator__c = true;
        cntctList[1].Address__c = addrList[1].Id;
        cntctList[1].AccountId = acnt.Id;
        cntctList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        cntctList[1].Billing_Indicator__c = true;
        cntctList[1].FirstName = 'Test1';
        cntctList[1].LastName = 'Contact';
        cntctList[1].Email = 'test@test.com';
        cntctList[1].Recipient_Indicator__c = true;
        insert cntctList;
        
        String ZuoraExternalId = 'try1234';
        String ZuoraZuoraIdc = 'Test1';
        String PackageCodec   = 'afds132';
        String PromotionCodec = 'yasyd97';
        
        //Setup Zuora__CustomerAccount__c
        
       
    
          
        custAccount = TestDataFactory.createBillingAccount(1)[0];
        custAccount.Zuora__Account__c = acnt.Id;
        custAccount.Billing_Contact__c = cntctList[1].Id;
        custAccount.Zuora__Zuora_Id__c = ZuoraZuoraIdc;
        custAccount.Billing_Type__c = 'Full Prepaid';
        custAccount.Zuora__DefaultPaymentMethod__c = 'Other';
        custAccount.Zuora__AccountNumber__c = 'Test1';
        //custAccount.Zuora__PaymentMethod_Type__c = 'Credit Card';
        //Zuora__Default_Payment_Method__c = pm.id;
        
        insert custAccount;
        Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
        pm.Zuora__BillingAccount__c = custAccount.Id;
        pm.Zuora__Type__c = 'Cash';
        insert pm;
        custAccount.Zuora__Default_Payment_Method__c = pm.id;
        update custAccount;
        
       // update custAccount;
        //Setup Package records
        packge = TestDataFactory.createPackage(1)[0];
        packge.Billing_Type__c = 'Full Prepaid';
        packge.Package_Type__c = 'Grace Period';
        packge.Subscription_Period__c = '1';
        packge.Package_Code__c = PackageCodec;
        packge.Product_Family_Current_Package__c = 'test';
        insert packge;
        
        //Setup zqu__ZProduct__c records
        zProducts = TestDataFactory.createZProduct(1)[0];
        zProducts.ProductSubType__c = 'Magazine';
        zProducts.zqu__ZuoraId__c = 'Test';
        insert zProducts ;
        
        //Setup zqu__ProductRatePlan__c records
        prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
        prodRatePlan.zqu__ZProduct__c = zProducts.Id;
        prodRatePlan.RatePlanType__c= 'Proration';
        prodRatePlan.zqu__EffectiveStartDate__c= date.today();
        prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prodRatePlan.zqu__Deleted__c = false;
        prodRatePlan.zqu__ZuoraId__c = 'Test';
        insert prodRatePlan;
        
        //Setup Product_Family__c records
        prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'Trythis';
        prodFamily.Product_Family_Name__c = 'testtest';
        insert prodFamily;
        
        //Setup Package Item records
        packageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packageItem.Package__c = packge.id;
        packageItem.Product_Rate_Plan__c = prodRatePlan.id;
        packageItem.Name = 'Test Pack Item';
        packageItem.Product_Family__c = prodFamily.Id;
        insert packageItem;
        
        //Setup Order records
        orders = TestDataFactory.createOrder(1)[0];
        orders.Account__c = acnt.Id;
        orders.Informed_Customer__c = TRUE;
        orders.Order_Type__c = 'Renewal';
        orders.Status__c = 'Draft';
        orders.Eligible_for_Retention__c = TRUE;
        orders.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orders.Payment_Mode__c = 'Credit Card';
        orders.Billing_Account__c = custAccount.id;
        orders.Billing_Type__c = 'Full Prepaid';
        orders.Billing_Contact__c = cntctList[1].id;
        orders.Case_Record_Type__c = 'Complaint - Magazine';
        orders.Category__c = 'Subscription Request';
        orders.Sub_Category__c ='Stop Subscription';
        orders.Credit_Balance__c = 0;
        orders.Delivery_Charge__c = 0;
        orders.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orders.Order_Type__c = 'Change of Subscription Package';
        orders.PO_Number__c = 'PO00000';
        orders.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
        orders.Delivery_Charge_Type__c = 'C';
        orders.Subscriber_Charge__c = 10.00;
        insert orders;
        
        //Order Line Item
        orderItemList = new List<Order_Line_Item__c>(1);
        ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem.Order__c = orders.Id;
        ordLineItem.Start_Date__c = date.today().addDays(1);
        ordLineItem.End_Date__c = date.Today().addDays(4);
        ordLineItem.Main_Package_ID__c = packge.Id;
        ordLineItem.Term_Length__c = 0;
        ordLineItem.Main_Package_Period__c = 0;
        ordLineItem.Earliest_Start_Date__c = date.today();
        ordLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
        ordLineItem.Stop_Request_Date__c =  date.Today().addDays(4);
        ordLineItem.Terminating_Reason__c = 'Others';
        ordLineItem.Amount_To_Refund__c = 0;
        ordLineItem.Admin_Charge__c = 0;
        ordLineItem.Fee_Waiver__c = TRUE;
        ordLineItem.Fee_Override__c = FALSE;
        ordLineItem.Override_Reason__c = 'TEST';
        ordLineItem.Suppress_Notification_Stop__c = TRUE;
        ordLineItem.Main_Package_Type__c = 'Base';
        insert ordLineItem;
        orderItemList.add(ordLineItem);
        
        Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = cntctList[0].id);        
        insert asiaOneRecord;
        System.debug('***wendy : inserted asiaOneRecord');
        
        Service_Access_Flag__c saf = new Service_Access_Flag__c();
        saf.Name = 'test name';
        insert saf;
        System.debug('***wendy : inserted saf');
        
        Package_Access_Flag__c paf = new Package_Access_Flag__c();
        paf.Package_Service_Access_Flag__c = saf.id;
        paf.Package__c = packge.id;
        paf.No_of_Concurrent_Users__c = 1;
        insert paf;
        System.debug('***wendy : inserted paf' + paf.Package__c);
    }

    static User createUser() {
        UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
                       EmailEncodingKey='UTF-8', LastName='Testing123', 
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                       ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
                       UserName='testDeploymentUserJS00@sph.com', Title='Testing123');
        insert usr;

        return usr;
    }

    //@Description: tests if updating the zuora subscription will trigger methods
    //              before and after trigger update is set to FALSE.
    //@Parameters: none
    //@Return type: none
    static testMethod void testSingleInsertUpdate(){        
        User usr = createUser();
        
        //The test will run as the user created.
        System.runAs(usr) {
            setUpTestData();
            Zuora__Subscription__c sobj = new Zuora__Subscription__c();
            Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
            
            SubscriptionTriggerHandler subhandler = new SubscriptionTriggerHandler();
            subhandler.beforeDelete(sobj);
            SubscriptionTriggerHandler subhandler2 = new SubscriptionTriggerHandler();
            subhandler.afterDelete(sobj2);
            
            subhandler.testCoveragePatch();
            
            SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
            SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = FALSE;
            
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            //acctVendor.Ven
            insert acctVendor;
            
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = cntctList[0].id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
            
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
            
            Package_Access_Flag__c paf = new Package_Access_Flag__c();
            paf.Package_Service_Access_Flag__c = saf.id;
            paf.Package__c = packge.id;
            paf.No_of_Concurrent_Users__c = 1;
            insert paf;
            System.debug('***wendy : inserted paf' + paf.Package__c);
            
            List<Asia1_Subscription__c> tmpList = new List<Asia1_Subscription__c>();
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = ordLineItem.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            tmpList.add(tmp);
            Asia1_Subscription__c tmp1 = new Asia1_Subscription__c();
            tmp1.Asia1__c = asiaOneRecord.id;
            tmp1.Order_Line_Item__c = ordLineItem.id;
            tmp1.Service_Access_Flag__c = saf.id;
            tmp1.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
            tmpList.add(tmp1);
            insert tmpList; 
            System.debug('***wendy : inserted tmp');
            
            //create subscription vendor
            //Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            ////SubVend.Name = 'Test Subscription Vendor';
            //insert SubVend;
            //System.debug('***wendy : inserted tmp');
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            caseRec.Status = 'Pending';
            caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
            insert caseRec;   
            System.debug('***wendy : caseRec'); 
            
            Subscription_Vendor__c venSub = new Subscription_Vendor__c();
            venSub = TestDataFactory.createSubscriptionVendor(1)[0];
            insert venSub;
            
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acnt.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            //zua.Zuora__PaymentMethodType__c = 'Paypal';
            insert zua; 
            System.debug('***wendy : inserted zua');
            String ZuoraExternalId = 'try1234';
            Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acnt.Id;
            subRec.Order_Line_Item_Number__c = ordLineItem.Id;
            subRec.Subscriber_Contact__c = cntctList[0].Id;
            subRec.Recipient_Contact__c = cntctList[0].Id;
            subRec.Main_Package_1__c = packge.Id;
            subRec.Main_Package__c = packge.Id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Order_Number__c = orders.Id;
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Subscription_Type__c = 'Publication';
            subRec.Subscription_Type_1__c = 'Publication';
            subRec.Zuora__SubscriptionEndDate__c= date.today().addDays(30);        
            subRec.Zuora__TermSettingType__c = 'TERMED';
            subRec.Term_Length__c = 1;
            subRec.Zuora__SubscriptionStartDate__c = date.today();
            subRec.Zuora__CustomerAccount__c = custAccount.Id;
            subRec.Contact__c = cntctList[0].id;
            subRec.Zuora__External_Id__c = ZuoraExternalId;
            subRec.Zuora__Zuora_Id__c = ZuoraExternalId;
            subRec.Order_Line_Item_Number_1__c = ordLineItem.Id;
            subRec.Delivered_By__c = 'Vendor';
            subRec.Vendor_Subscription_To_Convert_1__c = venSub.id;
            subRec.Term_Length__c = 12;
            subRec.Zuora__TermSettingType__c = 'EVERGREEN';
             
            
            test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec 
            insert subRec; 
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acnt.Id;
            order.Recipient_Contact__c = cntctList[1].Id;
            order.Informed_Customer__c = True;
            insert order;
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
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
            orderline.Start_Date__c = date.today()+5;
            orderline.Subscription_Name__c = subRec.name;
            orderline.Main_Package_Subscription_Rate__c  = 10;
            orderline.Qty__c = 1;
            insert orderline;
            subRec.Zuora__Status__c = 'Cancelled';
            subRec.Recipient_Contact__c = null;
            subRec.Subscription_Charge__c = null;
            update subRec;
            
            subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
            subRec.Zuora__SubscriptionStartDate__c = Date.today().addMonths(-Integer.valueOf(subRec.Term_Length__c));
            subRec.Zuora__SubscriptionEndDate__c = Date.today();
         
            SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
            SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;    
            subRec.Vendor__c = acctVendor.Id+'';
           // update subRec; // venor cdannot be empty error
            
            SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
            handler.runBeforeUpdateTrigger();
            handler.runAfterUpdateTrigger();
            //TEST: if 
            
            handler.runBeforeInsertTrigger();
            handler.runBeforeDeleteTrigger();
            handler.runAfterInsertTrigger();
            handler.runAfterDeleteTrigger();
            
            List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
            Zuora__SubscriptionProductCharge__c subProdCharge1 = new Zuora__SubscriptionProductCharge__c(
                Zuora__ProductName__c='SIT - Charge', Zuora__ExtendedAmount__c=100, Zuora__Price__c = 10, Zuora__Type__c = GlobalVariableClass.SPC_TYPE_RECURRING, Zuora__Subscription__c = subRec.Id
            );
            subProdChargeList.add(subProdCharge1);
            
            subProdCharge1 = new Zuora__SubscriptionProductCharge__c(
                Zuora__ProductName__c='SIT - Disc', Zuora__Price__c = 10, Product_Code__c = 'DISC', Zuora__Type__c = GlobalVariableClass.SPC_TYPE_RECURRING, Zuora__Subscription__c = subRec.Id
            );
            subProdChargeList.add(subProdCharge1);
            
            insert subProdChargeList;
            
            Set<Id> setSubId = new Set<Id>();
            setSubId.add(subRec.Id);
            
            SubscriptionProductChargeTriggerFuture.updateSubscriptionChargePublication(setSubId);
            
            test.stoptest();  
        }
    }
}